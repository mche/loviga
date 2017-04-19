package Controll::Transport;
use Mojo::Base 'Mojolicious::Controller';
#~ use Model::Transport;
#~ use Model::Transport::Category;
#~ use Model::Address;
#~ use Model::Ask;
use Mojo::Home;
use Mojo::Util qw(steady_time);
use Mojo::Asset::File; # удалять файлы

#~ my $model = Model::Transport->new; # синглтон самого базового DBIx::Mojo::Model уже инициализирован! в плугине RoutesAuthDBI
#~ my $model_category = Model::Transport::Category->new;
#~ my $model_addr = Model::Address->new;
#~ my $model_ask = Model::Ask->new;
my $asset_img = Mojo::Asset::File->new;
my $img_path;# дальше ИД пользователя и его файлы

has model => sub {shift->app->models->{'Transport'}};
has model_category => sub {shift->app->models->{'Transport::Category'}};
has model_ask => sub {shift->app->models->{'Ask'}};
has model_addr => sub {shift->app->models->{'Address'}};

has static_dir => sub { shift->config('mojo_static_paths')->[0]; };
has uid => sub {my $auth = shift->auth_user; $auth && $auth->{id};};
has user_or_guest => sub {my $c = shift; $c->auth_user || $c->access->plugin->guest->current($c) || $c->access->plugin->guest->store($c)
   || $c->app->log->error("Не определился пользователь/гость")
    && undef;
};

sub new {
  my $c = shift->SUPER::new(@_);
  $img_path = $c->config('Транспорт')->{img_path};
  $asset_img->path(sprintf("%s/%s%s/", $c->config('mojo_home'), $c->static_dir, $img_path, ));#$remove
  
  return $c;
}

sub index {
  my $c = shift;
  
  return $c->redirect_to('форма нового транспорта')
    unless $c->stash('есть транспорт') // $c->model->есть_транспорт( $c->uid );
  
  #~ return $c->redirect_to('форма транспорта')
    #~ unless $c->stash('есть транспорт');
  
  $c->render(
    title=> "Мой транспорт и услуги",
    handler=>"ep",
    assets=>["transport/list.js",],
    #~ "контент в верхней навигации"=>sprintf('<a class000="btn btn-large black-text teal lighten-1" href="%s"><i class="material-icons">add</i><span>Добавить</span></a>', $c->url_for("форма транспорта", id=>0))
  );
}

sub item {
  my $c = shift;
  my $id = $c->vars('id')
    or return $c->reply->exception('Ошибка ИДа позиции');
  my $ask = $c->vars('ask');
  
  my $data = $c->_item($id, $ask);
  
  $c->app->log->error(@$data)
    and return $c->reply->exception($data->[0])
    if ref $data eq 'ARRAY';
  
  $c->stash(
    'title'=>"Транспорт",
    'header-title'=>"транспорт",
    'данные' => $data,
  );
  $c->render;
};

sub _item {# полный набор данных для заявки ask, связанной с этим транспортом id
  my ($c, $id, $ask) = @_;
  my $data = eval {$c->model->позиция_без_доступа($id)}
    or return ['Ошибка БД позиции', $@, ];#$c->model->dbh->db->dbh->errstr
  
  my $ref_ask_ok = $ask && eval {$c->model->связь_получить($c->uid, $ask)};
  
  return ['Ошибка БД с доступом',]
    if $ask && !$ref_ask_ok;
  
  if ($ref_ask_ok) {# если заявка твоя показать телефоны
    #~ $data->{"заказчик"} = $ref_ask->{id1};
    $data->{"показы телефонов"} = $c->model->показы_телефонов($id, $c->uid) || [];
    #~ delete @$_{qw(upd_ts ts)} for @{$data->{"показы телефонов"}};
  }
  
  $data->{"типы адреса"} = $c->model->типы_адреса_позиции($id);
  $c->развернуть_позиции($data, 'телефоны'=>1);# не тут разворачивать?
  $data->{'адрес'} = $c->model_addr->полный_адрес_формат($c->model->первый_адрес($id))->{full};
  
  return $data;
}

sub list {# данные для списка
  my $c = shift;
  my $list = $c->model->список($c->uid);
  $c->развернуть_позиции($list);
  $c->render(json=>$list);
}

sub status {
  my $c = shift;
  #~ my $data = $c->req->json
    #~ or return $c->reply->exception('Передай данные в JSON');
  
  my $id = $c->vars('id');
  
  my $status = eval{$c->model->изменить_статус($c->uid, $id,)}
    or $c->app->log->error($@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {err=>"Ошибка БД"});
  
  $c->render(json=>$status);
  
}

sub disabled {
  my $c = shift;
  #~ my $data = $c->req->json
    #~ or return $c->reply->exception('Передай данные в JSON');
  
  my $id = $c->vars('id');
  
  my $data = eval{$c->model->изменить_отключение($c->uid, $id,)}
    or $c->app->log->error($@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {err=>"Ошибка БД"});
  
  $c->render(json=>$data);
  
}

sub развернуть_позиции {# для списков
  my $c = shift;
  my $list = ref $_[0] eq 'ARRAY' ? shift : [ shift ];
  my $opts = ref $_[0] eq 'HASH' ? shift : {@_};# телефоны=>1 - сохранить; поиск=>1 - флаг поиска
  return unless @$list;
  my $sth = $c->model_category->sth('родители категории');
  map {
    my $item = $_;
    $_->{"категории"} = $c->model_category->dbh->selectall_arrayref($sth, { Slice => {}, }, ($_->{category}) x 1);
    # подставить картинку или из категории
    #~ $_->{img_url} = do {
      #~ my $img = ${$_->{img}}[0];
      #~ $img && sprintf("%s/%s/%s", $img_path, $_->{uid} || $c->uid, $img);
    #~ } if $_->{img};
    #~ $_->{img_url} ||= do {
      #~ my $img = (map $_->{img}, grep $_->{img}, reverse @{$_->{"категории"}})[0];
      #~ $img && sprintf("%s/%s", $c->config('Категории транспорта')->{img_path}, $img);
    #~ };
    #~ $_->{img_category} = (map $_->{img}, grep $_->{img}, reverse @{$_->{"категории"}})[0];
    
    #~ $_->{img_path} =  sprintf("%s/%s/", $img_path, $_->{uid} || $c->uid,)
      #~ if $_->{img_url};
    
    unless ($opts->{'телефоны'}) {$item->{tel}[$_] =~ s/.{2}(.{2})$/XX$1/ for (0..$#{$_->{tel} || []});}
    delete @$item{qw(ts status_ts)};
    delete @$item{qw(tel descr)}
      if $opts->{'поиск'} && !defined$item->{'status'} ;# undef && 0 
  } @$list;
}

my %errs = (
  addr_type => 'тип адреса',
  address => 'адрес',
  category => 'категория',
  date => 'дата',
);
sub search {
  my $c = shift;
  my $data = $c->req->json
    or return $c->render(text=>"Передай параметры поиска в JSON");
  
  my $errs = Mojo::Collection->new(grep !$data->{$_}, keys %errs);
  
  return $c->render(json=>{err=>$errs->map( sub {sprintf("Где %s?", $errs{$_})})->to_array})
    if @$errs;
  
  #~ return $c->местный_транспорт($data)
    #~ if $data->{addr_type} eq 1;
  
  #~ return $c->межгород_транспорт($data)
    #~ if $data->{addr_type} eq 2;
  
  #~ return $c->загран_транспорт($data)
    #~ if $data->{addr_type} eq 3;
  
  return $c->поиск_транспорта($data)
  
  #~ return $c->render(json=>$data);
}

=pod
sub местный_транспорт {# поиск при переключателе 
  my ($c, $data) = @_;
  
  #~ my $full = eval {$c->model_addr->полный_адрес($data->{address})}
    #~ or $c->app->log->error($@, $c->model_addr->dbh->db->dbh->errstr)
    #~ and return $c->render(json=>{err=>"Ошибка БД для полного адреса"});
  
  # нужно определить город/район
  #~ for (my $i = @{$full->{SHORTNAME}}-1; $i >= 0; $i--) {
    #~ $full->{local_uuid} = $full->{AOGUID}[$i]
      #~ and last
      #~ if $full->{SHORTNAME}[$i] ~~ ['р-н','г',];
  #~ }
  
  #~ return $c->render(json=>{err=>"Не локальный адрес, укажите в адресе район или населенный пункт"})
    #~ unless $full->{local_uuid};
  
  my $search = eval {$c->model->поиск_транспорта($data->{category}, $data->{addr_type}, $data->{address}, $data->{date})}
    or $c->app->log->error($@, $c->model->dbh->db->dbh->errstr)
    and return $c->render(json=>{err=>"Ошибка БД для локального поиска"});
    
  $c->развернуть_позиции($search, 1);
  
  $c->render(json=>$search);
}
=cut

sub поиск_транспорта {
  my ($c, $data) = @_;
  
  my $search = eval {$c->model->поиск_транспорта($data->{category}, $data->{addr_type}, $data->{address}, $data->{date})}
    or $c->app->log->error($@,)# $c->model->dbh->db->dbh->errstr
    and return $c->render(json=>{err=>"Ошибка БД для поиска транспорта"});
  
  $c->развернуть_позиции($search, 'поиск'=>1);
  
  $c->render(json=>$search);
  
}

#~ sub загран_транспорт {shift->межгород_транспорт(@_);}

sub show {# показ в поиске, дополнительные поля
  my $c = shift;
  my $id = $c->vars('id');
  
  my $addr = eval {$c->model->первый_адрес($id)}
    or $c->app->log->error("Данные транспорта: ", $@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=>{err=>"Ошибка БД для позиции транспорта"});
  
  my $faddr = $c->model_addr->полный_адрес_формат($addr);
  
  #~ my $showtel = ($c->uid && eval {$c->model->показы_телефонов($id, $c->uid)}) || [];
  
  $c->render(json=>{'адрес'=>$faddr, });#@$showtel ? ("показы телефонов" => $showtel) : ()
}

sub show_full {# полностью транспорт для заявки
  my $c = shift;
  #~ my $post = $c->req->json;
    #~ or return $c->reply->exception('Передай данные в JSON');
  
  my $id = $c->stash('id');# || $post->{id};
  my $ask = $c->stash('ask');#  || $post->{ask};
  
  return $c->render(json=> {error=>"Не указаны данные"})
    unless $id && $ask;
  
  my $data = $c->_item($id, $ask);
  $c->app->log->error(@$data)
    and return $c->render(json=> {error=>$data->[0]})
    if ref $data eq 'ARRAY';
  $data->{'ид заявки'} = $ask;
  $c->render(json=>$data);
}

sub tel {# показать один телефон по его индексу в массиве с сохранением в спец таблице (см. модель)
  my $c = shift;
  my $data = $c->req->json
    or return $c->reply->exception('Передай данные в JSON');
  
  return $c->render(json=> {error=>"Не указаны данные"})
    unless ($data->{object} || $data->{id}) && ( $data->{tel_idx} || ($data->{tel} && $data->{result}) );
  
  #~ my $user_or_guest = $c->user_or_guest
  $c->uid
    or return $c->render(json=> {error=>'Чтобы посмотреть телефон, пожалуйста', doLogin=>"войдите/зарегистрируйтесь на сервисе"});
  
  delete @$data{ grep /^_/, keys %$data};
  
  my $tel = eval {$c->model->результат_показа_телефона({'object'=>$data->{object} || $data->{id}, 'tel'=>$data->{tel}, 'caller'=>$c->uid, 'result'=>$data->{result},})} #$user_or_guest->{id}
    or $c->app->log->error("Показ телефона: ", $@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {error=>"Ошибка БД"})
    if $data->{tel} && $data->{result};
  
  $tel ||= eval {$c->model->показ_телефона($data->{object} || $data->{id}, $data->{tel_idx}, )} #$user_or_guest->{id}
    or $c->app->log->error("Показ телефона: ", $@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {error=>"Ошибка БД"});  
  
  my $ask = $data->{ask};
  #~ $c->app->log->error($c->dumper($ask));
  if ( $ask && $c->uid && !$ask->{id} || (eval { $c->model->связь_получить($c->uid, $ask->{id}) } || delete $ask->{id}) ) {# сохранить по какой заявке результат
    $ask->{tel} ||= '';
    #~ $data->{ask}{transport} ||= $tel->{object};
    delete @$ask{ grep !defined $ask->{$_}, keys %$ask };
    
    if ($ask = eval {$c->model_ask->сохранить($ask)}) {
      $c->model->связь($c->uid, $ask->{id});
      #~ $c->model->связь_удалить( {'id1'=>$tel->{object}, 'id2'=> $ask->{id},} );# связь транспорт/заявка возникает на этапе триггеров
      #~ $c->model->связь( $ask->{id}, $tel->{object}, );# от заявки к транспорту (если исполнитель найдет заявку - от транспорта к заявке)
      #~ $tel->{ask} = $ask;
      # перекинуть связь транспорт->заявка наоборот заявка->транспорт
      my $r = eval { $c->model->связь_получить($tel->{object}, $ask->{id},) }
        or $c->app->log->error($@, )
        and return $c->render(json=> {error=>"Ошибка БД"});
      $c->model->связь_обновить($r->{id}, $ask->{id}, $tel->{object}, );
      
      eval {$c->model_ask->сохранить_состояние({"заявка"=>$ask->{id}, "установил" => $c->uid, "состояние"=>$tel->{result},})} # "транспорт"=>$tel->{object}, 
        or $c->app->log->error("Состояние заявки: ", $@)#, $c->model->dbh->db->dbh->errstr
        and return $c->render(json=> {error=>"Ошибка БД"});
      
      $tel->{location} = $c->url_for("мои заявки")->query(s => $tel->{result});# статус принятые
    }
  } else {
    $tel->{'показы этого телефона'} = eval {$c->model->показы_телефонов($data->{object} || $data->{id}, $c->uid, $tel->{tel})}
      or $c->app->log->error("Показ телефона: ", $@);#$c->model->dbh->db->dbh->errstr
    #~ delete @$_{qw(ts caller object)}
      #~ for @{$tel->{'показы этого телефона'} || []};
  }
  
  delete @$tel{qw(ts caller object)};
  #~ $tel->{_success} = 'ok';

  #~ return $c->render(json=> {error=>$user_or_guest});
  
  $c->render(json=> $tel);
  
}

sub addr_type {
  my $c = shift;
  my $cat = $c->vars(qw (c cat));
    #~ or return $c->render(json=>[{text=>"Ошибка: не указана категория"}]);
  
  return $c->render(json=>$c->model_addr->addr_type)
    unless $cat;
  
  my $ret = eval{$c->model->количество_адресных_типов($cat)}
    or $c->app->log->error($@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {err=>"Ошибка БД"});
  
  $c->render(json=>$ret);
}

sub form {
  my $c = shift;
  
  $c->render(
    handler => "ep",
    title => "Форма транспорта",#$c->stash('id') ? 
    stylesheets => ["transport/form.css", ],#/lib/angular-ui-select/dist/materialize.css
    assets => ["transport/form.js",],
    #~ has_transport => $c->model->есть_транспорт($c->uid),
    
  );# stash id
  
}

sub form_data {
  my $c = shift;
  
  my $id = $c->vars('id');
  #~ my $id = $c->stash('id00');
  
  my $pos = eval {$c->model->позиция($id, $c->uid)}
    or $c->app->log->error($@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=>{err=>"Ошибка БД для позиции транспорта"})
    if $id;
  
  if ($pos && $pos->{id}) {
    #~ $c->app->log->debug($c->dumper($pos));
    # индексный путь категории нужен
    # для автоматического разворачивания связанных списков категорий транспорта в форме редактирования
    $pos->{_selected_category} = $c->model_category->индексный_путь_категории($pos->{category});
    $pos->{img} = [map +{name=>$_, }, @{$pos->{img} || []}];# убрать _img_url и вообще хэш _img_url=> "$img_path/@{[$c->uid]}/$_"
    my $arr_idx_addr = 0;
    $pos->{address} = [map {
      my $addr = $c->model_addr->полный_адрес($_);
      my $full = $c->model_addr->полный_адрес_формат($addr);
      $full->{disabled} = $pos->{address_dsbl} && $pos->{address_dsbl}[$arr_idx_addr++];
      $full;
    } @{$pos->{address}}];
    
  } else {# новая позиция для ангулярной формы
    
    my $table_cols = $c->model->_table_type_cols();
    $pos->{$_} = $table_cols->{$_}{data_type} eq 'ARRAY' ? [] : undef
      for keys %$table_cols;
    $pos->{tel} = [''];
    $pos->{address} = [{}];
    #~ $pos->{img} = [{}];
    #~ $pos->{addr_type} = [];
    if (my $sel_cat = $c->vars('c')) {
      $pos->{_selected_category} = eval {$c->model_category->индексный_путь_категории($sel_cat)};
    } else { $pos->{_selected_category} ||= [];}
  }
  delete @$pos{qw(ts status_ts)};
  
  $pos->{tel} ||= [''];
  $pos->{img} ||= [];
  $pos->{addr_type} ||= [];
  
  
  $c->render(json=>$pos);# _selected_category => []
}


sub save {
  my $c = shift;
  
  my $data = $c->req->json
    or return $c->reply->exception('Передай данные в JSON');
    
  
  return $c->render(json=> {error=>"403 forbidden or 404 not found or 500 wrong :("})
    if $data->{'id'} && !eval{$c->model->позиция($data->{'id'}, $c->uid)};

    
  return $c->render(json=> {error=>"Не указана категория транспорта"})
    unless $data->{'category'};
  
  my $addr = $data->{address} && ref $data->{address} eq 'ARRAY' && [map $_->{uuid}, grep $_->{uuid},  @{$data->{address}}];
  
  return $c->render(json=> {error=>"Не указан адрес"})
    unless $addr && @$addr;
  
  $data->{address_dsbl} = [map sprintf("%s", $_->{disabled} || 0), grep $_->{uuid},  @{$data->{address}}];
  
  $data->{address} = $addr;
  
  return $c->render(json=> {error=>"Не указаны действия адресов"})
    unless $data->{addr_type} && ref $data->{addr_type} eq 'ARRAY' && scalar grep $_, @{$data->{addr_type}};
  
  $data->{addr_type} = [map $_  ? 1 : 0, @{$data->{addr_type}}];
  
  my $tel = $data->{tel} && ref $data->{tel} eq 'ARRAY' && [grep /\d{10}/, @{$data->{tel}}];
  
  return $c->render(json=> {error=>"Не указан телефон"})
    unless $tel && @$tel;
  
  
  if (my @test_tel = @{$c->model->проверка_телефонов($c->uid, $tel)}) {
    return $c->render(json=> {error=>"Телефон [@test_tel] используется"});
  }
  
  $data->{tel} = $tel;
  
  
  $data->{img} = [map $_->{name}, grep $_->{name},  @{$data->{img}}]
    if $data->{img} && ref $data->{img} eq 'ARRAY';
  
  #~ delete $data->{$_} for grep /^_/ || !defined $data->{$_}, keys %$data;
  delete @$data{ grep /^_/ || !defined $data->{$_}, keys %$data };
  #~ $c->app->log->debug($c->dumper($data));
  my $trans = eval {$c->model->сохранить($data)}
    or $c->app->log->error($c->dumper($data), $@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=> {error=>"Ошибка БД"});
  #~ $trans->{'связь'} = 
  $c->model->связь($c->uid, $trans->{id});
  #~ delete @{$trans->{'связь'}}{qw(ts)};
  delete @$trans{qw(ts)};
  $trans->{success} = "Успешно сохранено!";
  $trans->{redirect} = $c->url_for('мой транспорт')->fragment("transport".$trans->{id})
    if ($c->stash('есть транспорт') // $c->model->есть_транспорт( $c->uid )) > 1;
  $c->render( json=> $trans );
  
}

sub img {
  my $c = shift;
  
  my $json = $c->req->json;
    #~ or return $c->reply->exception('Передай данные в JSON');
  
  #~ $c->app->log->error($c->dumper($json));
  
  my $remove = ($json && $json->{'remove_img'}) // $c->vars('remove_img');
  my $id = ($json && ($json->{'param'} && $json->{'param'}{'id'}) || $json->{'param[id]'}) // $c->vars('id') // $c->vars('param[id]');
  undef $id
    if $id eq 'null';
  my $idx = ($json && $json->{'idx'}) // $c->vars('idx');
  my $msg = {};
  
  eval {$c->model->связь($c->uid, $id,)}
    or $c->app->log->error($@, )#$c->model->dbh->db->dbh->errstr
    and return $c->render(json=>{error=>"Ошибка БД для позиции транспорта"})
    if $id;
  
  if ($remove) {#
    my $path = $asset_img->path;
    $asset_img->path(sprintf("%s%s/%s", $path, $c->uid, $remove))->move_to('/dev/null');
    $asset_img->path($path);
    
    $c->model->удалить_картинку($remove, $id)
      and $msg->{'удалил'} = $remove
      if $id;
  }
  
  if (my $img = $c->req->upload('img')) {
    #~ or return $c->render(json=> {error=>"нет картинки"});
    my $name = steady_time().".".$img->filename;
    my $dir = sprintf("%s/%s%s/%s", $c->config('mojo_home'), $c->static_dir, $img_path, $c->uid);
    `mkdir -p $dir`;
    $img->move_to("$dir/$name");
    $msg->{name} = $name;
    
     #~ $c->app->log->error($idx+1, $name, $id);
     
    $c->model->сохранить_картинку($idx+1, $name, $id)
      and $msg->{'сохранил в позиции'} = $idx+1
      if $id && defined $idx;
  }
  
  #~ my $dir = sprintf("/%s%s/%s", $c->static_dir, $img_path);
  $c->render(json=>$msg);# убрать _img_url _img_url=> "$img_path/@{[$c->uid]}/$name"

}


1;