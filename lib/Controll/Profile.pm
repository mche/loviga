package Controll::Profile;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Plugin::RoutesAuthDBI::Util qw(load_class);
use Mojo::Util qw(hmac_sha1_sum);
#~ use JSON::PP;

#~ my $JSON  = JSON::PP->new->utf8(0);

has oauth => sub {shift->access->plugin->oauth};
has model => sub {shift->app->models->{'Profile'}};
has captcha_path => sub {my $c = shift; return sprintf("%s/%s/%s", $c->config('mojo_home'), $c->config->{mojo_static_paths}[0], 'captcha');};

sub index {
  my $c = shift;
  #~ my $r = $c->dbh->selectall_arrayref($c->sth->sth('profile oauth.users'), {Slice=>{}}, ($c->auth_user->{id}));
  return $c->render('profile/sign',
    title=>'Вход',
    'header-title' => 'Вход и регистрация',
    assets => ['profile/form-auth.js'],
    #~ captcha_path => $c->url_for('captcha'),
  )
    unless $c->is_user_authenticated;
  $c->render(
  'header-title' => 'Мой профиль',
  assets => ['profile/form.js',],
  );
}

sub captcha {
=pod
1. периодически обновлять файлы капчей запуском scripts/captcha.pl --count=...
2. На файлы капчей делать шифрованные ссылки и их обязательно удалять 
3. Шифр ссылки состоит из 3х частей: код капчи, случайная соль, серверная строка

Заход сюда без входных параметров:
1. Прочитать каталог папчей без ссылок, случайный файл
1. создать шифр
2. создать ссылку
вернуть {captcha=>undef, solt=>..., digest=>...,}

заход сюда для проверки капчи

=cut
  my ($c, $captcha) = @_;
  my $dir = $c->captcha_path;
  
  if ($captcha) {# проверка капчи не просто так
    if ($captcha->{digest}) {
      # ссылка должна быть!
      return 0
        unless -l "$dir/$captcha->{digest}.png";
      
      unlink "$dir/$captcha->{digest}.png"
        or $c->app->log->error("Не смог удалить ссылку на капчу: $!");
    }
    
    return 0
      unless $captcha->{code} && $captcha->{solt};
    
    return $c->captcha_digest($captcha->{code}, $captcha->{solt}) eq $captcha->{digest};
    
  }
  
  my @files = map utf8::decode($_) && (/([а-я0-9a-z]+\.png)$/i)[0], `find $dir -type f`;# `ls $dir`;
  my $file = $files[int rand @files];
  chomp $file;
  my $code = ($file =~ /([а-я0-9a-z]+)/)[0];
  my ($digest, $solt,) = $c->captcha_digest($code);
  #~ system("cd $dir && ln -s $file $digest.png") == 0
    #~ or $c->app->log->error("Не смог создать ссылку на капчу [$dir/$file]: $? $!");
  symlink "$dir/$file", "$dir/$digest.png";
  return {code=>'', solt=>$solt, digest=>$digest};
  
  #~ $c->render(text=>join("\n", @files));
}

sub  captcha_digest {
  my ($c, $code, $solt) = @_;
  my $msk = time()-2*60*60;# московское время на 5 минут действия шифра #(rand =~ /^[0\.]+(\d+)/)[0];
  return undef
    if $solt && $solt < $msk ;
  $solt ||= $msk+5*60;
  my $digest = hmac_sha1_sum $code.$solt, '$%^hjk6f';
  return wantarray ? ($digest, $solt) : $digest;
}

sub save {
  my $c = shift;
  my $json = $c->req->json;
  my $data = $json || $c->req->params->to_hash;
  
  my $p = $c->auth_user;
  $data->{id} = $p->{id};
  my $tx_db = $c->model->dbh->begin;
  my $model_logins = $c->access->plugin->model('Logins');
  local $model_logins->{dbh} = $tx_db;# временно переключить модель на транзакцию
  local $c->model->{dbh} = $tx_db;# временно переключить модель на транзакцию
  
  my $success;
  my $pw = delete @$data{qw(pw)};
  my $login = delete @$data{qw(login)};
  if ($pw && scalar(grep /\w+/, @$pw) eq 2 && $login eq $p->{login} ) {# изменить пароль
    return $c->render(json=>{error=>"Пароль короткий (6)",})
      if length $pw->[1] < 6;
    $model_logins->upd_pass(old_pass=> $pw->[0], new_pass=>$pw->[1], login=>$login,)
      or return $c->render(json=>{error=>"Неверный старый пароль",});
    $success = "Пароль изменен";
  }
  my $new_login;
  if ($login && $p->{login} && $login ne $p->{login}) {# изменить логин
    return $c->render(json=>{error=>"Логин короткий (7)",})
      if length $login < 7;
    return $c->render(json=>{error=>"Логин используется",})
      if $model_logins->login(undef, $login);
    $new_login = $model_logins->upd_login(old_login=> $p->{login}, new_login=>$login, old_pass=> $pw->[0],)
      or return $c->render(json=>{error=>"Неверный старый пароль",});
    $success = "Логин изменен";
  }
  
  
  if ($login && $pw && !$pw->[0] && $pw->[1] ) {# новый логин
    return $c->render(json=>{error=>"Логин короткий (7)",})
      if length $login < 7;
    return $c->render(json=>{error=>"Логин используется",})
      if $model_logins->login(undef, $login);
    return $c->render(json=>{error=>"Пароль короткий (6)",})
      if length $pw->[1] < 6;
    #~ $c->model->новый_логин($login, $pw->[1]);
    $new_login = $model_logins->new_login($login, $pw->[1]);
    $c->model->связь($p->{id} => $new_login->{id});
    $success = "Логин создан";
    #~ delete @$login{qw(ts)};
  }
  
  $data = $c->model->сохранить($data);
  $tx_db->commit;
  delete @$data{qw(ts)};
  
  return $c->render(json=>{success=>$success || "Сохранено успешно", data=>$data, $new_login ? (login=>$new_login->{login}) : (),}) #redirect=>$c->url_for('profile'),
    if $json;
  
  $c->render('profile/index');
}

sub sign {# name=>'обычная авторизация/регистрация'
  my $c = shift;
  
  return $c->redirect_to('profile')
    if $c->is_user_authenticated;
  
  my $json = $c->req->json;
  my $data = $json || $c->req->params->to_hash;

  my $check = $c->проверить_логин($data);
  
  if ($check->{ok}) {
    $check->{ok}{redirect} = $check->{redirect} 
      || $c->app->models->{'Ask'}->есть_новые_заявки( $check->{ok}{id})
        ? $c->url_for('заявки на мой транспорт')
        : $c->app->models->{'Transport'}->есть_транспорт( $check->{ok}{id}) # $c->stash('есть транспорт') || 
          ? $c->url_for('мой транспорт')
          : $c->app->models->{'Ask'}->есть_мои_заявки( $check->{ok}{id}) #$c->stash('есть мои заявки')
            ? $c->url_for('мои заявки')
            : $c->url_for('home');
    $check->{ok}{uid} = $check->{ok}{id};
    
    return $c->render(json=> $check->{ok})
      if $json;
    
    return $c->redirect_to($check->{ok}{redirect});
    
  }
  
  if ($check->{new}) {
    $check->{new}{redirect} = $check->{redirect} || $c->url_for('profile');
    $check->{new}{uid} = $check->{new}{id};
    return $c->render( json => $check->{new} )
      if $json;
    return $c->redirect_to($check->{new}{redirect});
  }
  
  return $c->render(json=>$check)
    if $json;
  return $c->render(%$check);
  
}

sub проверить_логин {
  my ($c, $data) = @_;
  
  my $model_profiles = $c->access->plugin->model('Profiles');
  my $model_logins = $c->access->plugin->model('Logins');
  #~ my $model_refs = $c->access->plugin->model('Refs');
  
  return +{error=>"Нет данных для авторизации"}
    unless $data->{login};
  
  $data->{remem} ||= {map {$_=>$data->{$_}} grep($data->{$_}, qw(code solt digest))};
  if ($data->{remem} && keys %{$data->{remem}}) {# ввел код забытия пароля
    if ((scalar(grep($_ ne '', @{$data->{remem}}{qw(code solt digest)})) eq 3) && $c->captcha_digest($data->{remem}{code}, $data->{remem}{solt}) eq $data->{remem}{digest}) {
      my $p = $model_profiles->get_profile(undef, $data->{login})
        or return +{error=>"Неверный логин/пароль"};
      load_class('Digest::MD5');
      my $l =$model_logins->upd_pass(new_pass=>Digest::MD5::md5_hex($data->{remem}{code}), login=>$data->{login},);
      $c->authenticate(undef, undef, $p);# закинуть в сессию
      return +{ok=>{%$p}, redirect=>$c->url_for('profile')->query(pw=>$data->{remem}{code}),};
    }
    return +{error=>"Неверный проверочный код",};
  }
  
  unless ($data->{passwd}) {# без пароля - не помнит
    my $p = $model_profiles->get_profile(undef, $data->{login});# если профиля нет, пофиг пусть пытается вводить код
    my $code = (rand =~ /(\d{6})/)[0]
      if $p;
    my ($digest, $solt,) = $c->captcha_digest($code || (rand =~ /(\d{6,})/)[0]);
    load_class('RFC::RFC822::Address')
      or $c->app->log->debug("Не установлен модуль RFC::RFC822::Address?")
      and return +{error=>"Ошибка выполнения запроса, будет скоро исправлена"};
    if (RFC::RFC822::Address::valid($data->{login}) && $code) {
      load_class('Email')
        or die "Где модуль Email?";
      my $smtp = $c->config->{smtp};
      my $email = Email->new(
        ssl => $smtp->{ssl},
        host=>$smtp->{host},
        port=>$smtp->{port},
        smtp_user =>$smtp->{user},
        smtp_pw =>$smtp->{pw},
      );
      my $url =  $c->url_for('обычная авторизация/регистрация')->query(login=>$data->{login}, code=>$code, solt=>$solt, digest=>$digest)->to_abs;
      my $date = $c->_time_fmt($solt)." MSK";
      my $send = eval {$email->send(
        subject => "Восстановление пароля",
        from => $smtp->{user},
        to => $data->{login},
        #~ cc=>'info@',
        body =><<END_HTML,
<div>Ваш новый пароль: <strong>$code</strong></div>
<div>
  Можно войти по <a href="$url">этой ссылке</a> <span>(до $date)<span>
</div>
<div>С уважением,<br/>
сервис грузопереревозок <a href="@{[ $c->url_for('/')->to_abs ]}">ЛовиГазель</a></div>
END_HTML
      )};
      $c->app->log->debug($send || $@);
      return +{remem => {code=>'', solt=>$solt, digest=>$digest}, success => "Введите полученный пароль или перейдите по ссылке в высланном сообщении",};
    }
    
    return +{error => "Логин некорректен для восстановления",};
  }
  
  if (my $p = $model_profiles->get_profile(undef, $data->{login})) {
    #~ or return {error=>"Неверный логин/пароль"};
  #~ if ($p->{id}) {
    return {error=>"Неверный логин/пароль"}
      unless $p->{pass} eq $data->{passwd};
    
    return {error=>"Логин заблокирован"}
      if $p->{disable};
    
    $c->authenticate(undef, undef, $p);# закинуть в сессию
    
    return {ok=>{%$p}};
  }
  
  unless ($data->{captcha} && $c->captcha($data->{captcha})) {
    my $captcha = $c->captcha();
    $captcha->{error} = "Еще раз код"
      if $data->{captcha}{digest};# || $data->{captcha}{code};
    return $captcha;
    
  }
  
  return {error=>"Пароль короткий (6)"}
    unless length($data->{passwd}) > 5;
  return {error=>"Логин короткий (7)",}
      if length $data->{login} < 7;
  
  # новый профиль
  my $p = $model_profiles->new_profile(['новый', 'пользователь']);# массив имен пустой
  my $l =$model_logins->new_login($data->{login}, $data->{passwd});
  $c->model->связь($p->{id} => $l->{id});
  $c->authenticate(undef, undef, $p);# закинуть в сессию
  return {new=>{%$p}};
}

sub _time_fmt {
  my ($c, $time) = @_;
  my ($sec,$min,$hour,$mday,$mon,$year,) = localtime( $time );#$wday,$yday,$isdst
  $mon++;
  $year += 1900;
  return sprintf("%s.%s.%s %s:%s:%s", length($mday) eq 1 ? "0$mday" : $mday, length($mon) eq 1 ? "0$mon" : $mon, $year, length($hour) eq 1 ? "0$hour" : $hour, length($min) eq 1 ? "0$min" : $min, length($sec) eq 1 ? "0$sec" : $sec );
}

sub out {# толлько для приложения, логаут из сайта в модулеMojolicious/Plugin/RoutesAuthDBI/OAuth.pm
  my $c = shift;
  $c->logout;
  $c->render(json=>{logout=>'ok'});
}

sub data {# редактирование профиля
  my $c = shift;
  my $profile = {%{$c->auth_user}};
  delete @$profile{qw(ts)};
  #~ $profile->{auth_cookie} = $c->access->auth_cookie($c);
  $c->render(json=>$profile);
}

sub app_start {# при запуске приложения
  my $c = shift;

  my $uid = $c->auth_user->{id}
    if $c->is_user_authenticated;
  
  my %data = ();
  if ($uid) {
    
    my $profile = {%{$c->auth_user}};
    delete @$profile{qw(ts)};
    $profile->{auth_cookie} = $c->access->auth_cookie($c);
    $data{profile} = $profile;
    
    
    if ($c->vars('count')) {
      my $model_trans = $c->app->models->{'Transport'};
      my $model_ask = $c->app->models->{'Ask'};
      
      my $has_transport = $model_trans->есть_транспорт($uid);
      $c->stash('есть транспорт'=> $has_transport // 0);
      $data{count}{transport} = $has_transport // 0;
      
      # обработанные заявки
      my $has_asked = $model_ask->есть_заявки($uid)
        if $has_transport;
      $c->stash('есть обработанные заявки'=> $has_asked // 0);
      $data{count}{asked} = $has_asked // 0;
      
      # вновь поступившие заявки
      my $has_new_ask = $model_ask->есть_новые_заявки($uid)
        if $has_transport;
      $c->stash('есть новые заявки'=> $has_new_ask // 0);
      $data{count}{new_ask} = $has_new_ask // 0;
      
      my $has_my_ask = $model_ask->есть_мои_заявки($uid);
      $c->stash('есть мои заявки'=> $has_my_ask // 0);
      $data{count}{my_ask} = $has_my_ask // 0;
    }
  }

  $data{app} = $c->app->json->decode($c->model->app_config(scalar $c->vars('platform')))
    if $c->vars('app');

  
  
  $c->render(json=>\%data);
}



1;