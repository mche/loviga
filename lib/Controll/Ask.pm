package Controll::Ask;
use Mojo::Base 'Mojolicious::Controller';
#~ use Model::Ask;
#~ use Model::Transport;
#~ use Model::Transport::Category;
#~ use Model::Address;

#~ my $model = Model::Ask->new;
has model => sub {shift->app->models->{'Ask'}};
#~ my $model_category = Model::Transport::Category->new;
#~ my $model_addr = Model::Address->new;
#~ my $model_t = Model::Transport->new;
has model_transport => sub {shift->app->models->{'Transport'}};
has model_category => sub {shift->app->models->{'Transport::Category'}};
has model_addr => sub {shift->app->models->{'Address'}};

has uid => sub {my $auth = shift->auth_user; $auth && $auth->{id};};
#~ has user_or_guest => sub {my $c = shift; $c->auth_user || $c->access->plugin->guest->current($c) || $c->access->plugin->guest->store($c)
   #~ || $c->app->log->error("Не определился пользователь/гость")
    #~ && undef;
#~ };

my %errs = (
  address=>'адрес',
  addr_type=>'тип',
  category=>'категория ТС',
  date=>'дата',
  tel=>'телефон',
);
sub store {
  my $c = shift;
  my $data = $c->req->json
    or return $c->render(text=>"Передай параметры поиска в JSON");
  
  my $errs = Mojo::Collection->new(grep !$data->{$_}, keys %errs);
  
  return $c->render(json=>{err=>$errs->map( sub {sprintf("Где %s?", $errs{$_})})->to_array})
    if @$errs;
  
  my $uid = $c->uid
    or return $c->render(json=> {error=>"Ошибка с пользователем"});
  
  return $c->render(json=> {error=>"403 forbidden or 404 not found or 500 :("})
    if $data->{'id'} && !eval{$c->model->связь_получить($c->uid, $data->{'id'})};
  
  delete @$data{ grep ! defined $data->{$_}, keys %$data }
    unless $data->{'id'};
  
  delete @$data{ qw(addr_type category address) }
    if $data->{'transport'};
  
  my $ask = eval {$c->model->сохранить($data)}
    or $c->app->log->error($@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {err=>"Ошибка БД"});
  
  #~ $ask->{'связь'} = 
  $c->model->связь($uid, $ask->{id});
  $ask->{status} = $c->model->состояние_заявки($ask->{id}) || 50;# новая - активная
  $ask->{location} = $c->url_for('мои заявки')->query(s => $ask->{status});
  
  delete @$ask{qw(ts)};
  
  return $c->render(json=>$ask);
  
}

sub index {
    my $c = shift;
  # "список"=>$list, 
  $c->render(
    title=> "Мои заявки",
    handler=>"ep",
    #~ stylesheets => ["ask/list.css",],
    assets=>["ask/list.js",],
  );
  
}

sub list {# данные для списка
  my $c = shift;
  my $list = $c->model->список($c->uid);
  $c->развернуть_позиции($list);
  $c->render(json=>$list);
}

sub развернуть_позиции {# для списков
  my ($c, $list) = (shift, shift);
  my $opts = ref $_[0] eq 'HASH' ? shift : {@_};# телефоны=>1 - XXX;
  return unless @$list;
  my $sth = $c->model_category->sth('родители категории');
  map {
    my $item = $_;
    $_->{"категории"} = $c->model_category->dbh->selectall_arrayref($sth, { Slice => {}, }, ($_->{category}) x 1);
    $_->{"адрес"} = $c->адрес($_->{address});
    # подставить картинку из категории
    $_->{img_url} = do {
      my $img = (map $_->{img}, grep $_->{img}, reverse @{$_->{"категории"}})[0];
      #~ $img && sprintf("%s/%s", $c->config('Категории транспорта')->{img_path}, $img);
    };
    
    if ($opts->{'телефоны'}) { $item->{tel} =~ s/.{2}(.{2})$/XX$1/; }
    
    delete @$item{qw(ts)};
  } @$list;
}

sub form {
  my $c = shift;
  $c->render(
    handler => "ep",
    title => "Поиск транспорта",#$c->stash('id') ? 
    stylesheets => ["transport/search.css",],#/lib/angular-ui-select/dist/materialize.css
    assets => ["transport/search.js",],
    
  );
}

sub form_data {# для формы
  my $c = shift;
  my $data1 = {address => [{}],};
  if (my $sel_cat = $c->vars('c')) {
    $data1->{_selected_category} = eval {$c->model_category->индексный_путь_категории($sel_cat)};
  }
  
  $c->uid || 
    return $c->render(json=>$data1);
  
  my $id = $c->vars('id');
  
  my $data = eval {$c->model->позиция( $id, $c->uid,)}
    or $c->app->log->error($@)#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=>$data1)
    if $id;
  
  # индексный путь категории нужен
  # для автоматического разворачивания связанных списков категорий транспорта в форме редактирования транспорта
  if ($data && $data->{id}) {
    #~ $c->app->log->debug($c->dumper($data));
    $data->{_selected_category} = $c->model_category->индексный_путь_категории($data->{category});
    $data->{address} = [$c->адрес($data->{address})];
    
    $data->{"состояния"} = $c->состояния($id,);
    #~ $data->{transport} = $data->{"состояния"}[-1]{"транспорт"}
      #~ if $data->{"состояния"} && @{$data->{"состояния"}} && $data->{"состояния"}[-1]{"код состояния"} > 50;
    
    #~ (delete @$_{qw(ts)} || 1)
      #~ and ($_->{'кнопка'} = $c->model->кнопка_состояния($_->{'код состояния'},))
      #~ for @{$data->{"состояния"}};
    
    
    unshift @{$data->{"состояния"}}, {"код состояния"=>1, "состояние"=>"Создание", "дата"=>$data->{"дата создания"}, };# первым"кнопка"=>$c->model->кнопка_состояния(10),
    push @{$data->{"состояния"}}, {"код состояния"=>$data->{"код состояния"}, "состояние"=>$data->{"состояние"}, "дата"=>$data->{"дата"}, }#"кнопка"=>$c->model->кнопка_состояния($data->{"код состояния"}), 
      unless $data->{transport}; # текущее состояние внизу, если последнее состояние не отменило транспорт
    
    delete @$data{ ("код состояния", "состояние") }
      if $data->{transport};
    
  } else {# новая позиция
    my $table_cols = $c->model->_table_type_cols();
    $data->{$_} = $table_cols->{$_}{data_type} eq 'ARRAY' ? [] : undef
      for keys %$table_cols;
    push @{$data->{address}}, {};
    
    $data->{_selected_category} = $data1->{_selected_category};
  }
  delete @$data{qw(ts)};
  $c->render(json=>$data);
}

#~ sub states {# 
#~ }

sub адрес {
  my ($c, $auuid) = @_;
  my $addr = $c->model_addr->полный_адрес($auuid);
  $c->model_addr->полный_адрес_формат($addr);
}

sub состояния {# заявки
  my ($c, $ask_id) = @_;
  my $states = $c->model->состояния_заявки($ask_id,) || [];
  delete @$_{qw(ts)}
      #~ and ($_->{'кнопка'} = $c->model->кнопка_состояния($_->{'код состояния'},))
    for @$states;
  return $states;
}

sub me {# заявки на мой транспорт
  my $c = shift;
    $c->render(
    title=> "Заявки на мой транспорт",
    handler=>"ep",
    stylesheets => ["ask/me-list.css",],
    assets=>["ask/me-list.js",],
  );
}

sub me_data {# данные для списка заявки на мой транспорт
  my $c = shift;
  my $data = $c->model->список_для_моего_транспорта($c->uid);
  $c->развернуть_позиции($data);
  #~ for my $item (@$data) {
    #~ push @{$item->{"состояния"} ||= []}, map {delete @$_{qw(ts)}; $_;} @{$c->model->состояния_заявки_по_транспорту($item->{id}, $_) || []}
      #~ for  @{$item->{"транспорт"}};
  $_->{"состояния"} = $c->состояния($_->{id})
    for @$data;
  my $new_ask = $c->model->новые_заявки_для_моего_транспорта($c->uid);
  $c->развернуть_позиции($new_ask, 'телефоны' => 1);
  $_->{"состояния"} = #delete $_->{"состояние/заявка"} ? $c->состояния($_->{id}) : 
    [{"код состояния"=>10, "дата состояния"=> delete $_->{"дата состояния"}, "установил"=>1}] # эмуляция нового состояния
    for @$new_ask;
  #~ }
  push @$data, @$new_ask;
  $_->{"показы телефонов"} = $c->model_transport->показы_телефонов($_->{id}, $c->uid)
    #~ and map {delete @$_{qw(caller object ts)}} @{$_->{"показы телефонов"}}
    for @$data;
  $c->render(json=>$data);
}

my %state_errs = (
  "заявка"=>"ид заявки",
  "код состояния"=>"ид состояния",
);
sub store_state {# сохранить состояние заявки
  my $c = shift;
  my $data = $c->req->json
    or return $c->render(text=>"Передай параметры поиска в JSON");
  
  my $errs = Mojo::Collection->new(grep !$data->{$_}, keys %state_errs);
  
  return $c->render(json=>{err=>$errs->map( sub {sprintf("Где [%s]?", $state_errs{$_})})->to_array})
    if @$errs;
  
  #~ my $uid = $c->uid
    #~ or return $c->render(json=> {error=>"Ошибка с пользователем"});
  
  
  return $c->render(json=> {err=>"403 forbidden or 404 not found or 500 server error :("})
    unless eval {$c->model->доступ_к_состояниям_заявки($c->uid, $data->{'заявка'})}
      || $c->app->log->error($@, ) || 1;#$c->model->dbh->db->dbh->errstr
    #~ if $data->{'id'} && !eval{$c->model->позиция($data->{'заявка'}, $c->uid)};
  
  delete @$data{ grep ! defined $data->{$_}, keys %$data };
  
  $data->{"состояние"} ||= $data->{"код состояния"};
  $data->{"состояние"} += $data->{"оценка"} || 0;
  $data->{"установил"} = $c->uid;
  
  my $state = eval {$c->model->сохранить_состояние($data)}
    or $c->app->log->error($@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {err=>"Ошибка БД"});
  
  my $transport = $data->{transport}# проверить что транспорт этого пользователя
    if $data->{transport} && eval { $c->model->связь_получить($c->uid, $data->{transport}) };
  
  if ( $transport && $data->{"код состояния"} && $data->{"код состояния"} ~~ [30,40,60] ) {
    #~ $c->model->связь_удалить( {'id1'=>$transport, 'id2'=> $data->{'заявка'},} );# связь транспорт/заявка возникает на этапе триггеров
    #~ $c->model->связь( $data->{'заявка'}, $transport );# от заявки к транспорту (если исполнитель найдет заявку - от транспорта к заявке)
    # перекинуть связь транспорт->заявка наоборот заявка->транспорт
    my $r = eval { $c->model->связь_получить($transport, $data->{'заявка'}) }
      or $c->app->log->error($@, )
      and return $c->render(json=> {err=>"Ошибка БД"});
    $c->model->связь_обновить($r->{id},$data->{'заявка'}, $transport, );
    
  }
  
  my $states = $c->состояния($state->{"заявка"});
  return $c->render(json=> {"состояния"=>$states});
}

sub item {
  my $c = shift;
  
}

sub tel {# показать один телефон по его индексу в массиве с сохранением в спец таблице (см. модель)
  my $c = shift;
  my $data = $c->req->json
    or return $c->reply->exception('Передай данные в JSON');
  
  return $c->render(json=> {error=>"Не указаны данные"})
    unless $data->{object} || $data->{id};
  
  #~ my $user_or_guest = $c->user_or_guest
  $c->uid
    or return $c->render(json=> {error=>"Чтобы посмотреть телефон, пожалуйста, <a href='/profile'>войдите/зарегистрируйтесь на сервисе</a>"});
  
  delete @$data{ grep /^_/, keys %$data};
  
  my $tel = eval {$c->model->результат_показа_телефона({'object'=>$data->{object} || $data->{id}, 'tel'=>$data->{tel}, 'caller'=>$c->uid, 'result'=>$data->{result},})} #$user_or_guest->{id}
    or $c->app->log->error("Показ телефона: ", $@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {error=>"Ошибка БД"})
    if $data->{tel} && $data->{result};
  
  $tel ||= eval {$c->model->показ_телефона($data->{object} || $data->{id}, )} #$user_or_guest->{id}
    or $c->app->log->error("Показ телефона: ", $@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {error=>"Ошибка БД"});
  
  my $transport = $data->{transport}# проверить что транспорт этого пользователя
    if $data->{transport} && eval { $c->model->связь_получить($c->uid, $data->{transport}) };
  #~ $c->app->log->error($c->dumper($ask));
  if ( $transport && $tel->{result} && $tel->{result} ~~ [30,40,60] ) {
    #~ $c->model->связь_удалить( {'id1'=>$transport, 'id2'=> $tel->{object},} );# связь транспорт/заявка возникает на этапе триггеров
    #~ $c->model->связь( $tel->{object}, $transport);# от заявки к транспорту (если исполнитель найдет заявку - от транспорта к заявке)
    # перекинуть связь транспорт->заявка наоборот заявка->транспорт
    my $r = eval { $c->model->связь_получить($transport, $tel->{object},) }
      or $c->app->log->error($@, )
      and return $c->render(json=> {error=>"Ошибка БД"});
    $c->model->связь_обновить($r->{id}, $tel->{object}, $transport, );
    
    my $state = eval {$c->model->сохранить_состояние({"заявка"=>$tel->{object}, "установил" => $c->uid, "состояние"=>$tel->{result},})} # "транспорт"=>$tel->{object}, 
      or $c->app->log->error("Состояние заявки: ", $@, )#$c->model->dbh->db->dbh->errstr
      and return $c->render(json=> {error=>"Ошибка БД"});
    
    #~ $tel->{location} = $c->url_for("заявки на мой транспорт")->query(s => $tel->{result})
      #~ if $tel->{result} eq 60;# статус принятые
    #~ $tel->{remove} = 1;
    $tel->{'состояния'} = $c->состояния($tel->{object});#$state->{"заявка"}
    $tel->{transport} = $transport;
  }
  $tel->{"показы телефонов"} = $c->model_transport->показы_телефонов($data->{object}, $c->uid);
  
  delete @$tel{qw(ts caller upd_ts)};
  #~ $tel->{_success} = 'ok';

  #~ return $c->render(json=> {error=>$user_or_guest});
  
  $c->render(json=> $tel);
  
}

1;