package Controll::Main;
use Mojo::Base 'Mojolicious::Controller';

#~ has dbh => sub { shift->app->dbh->{'main'} };
has model_category => sub{ shift->app->models->{'Transport::Category'};}; # синглтон самого базового DBIx::Mojo::Model уже инициализирован! в плугине RoutesAuthDBI
has top_category => sub {shift->model_category->топ_категории_счет()};

#~ sub new {
  #~ my $self = shift->SUPER::new(@_);
  #~ $dbh = $self->app->dbh->{'main'};
  #~ return $self;
#~ }

#~ sub search {# просто маршрут на форму заявки
  #~ my $c = shift;
  #~ $c->render(#'main/search',
  #~ title=>'Поиск транспорта',
  #~ 'header-title' => $c->config('Проект'),
  #~ handler=>'ep',
  #~ stylesheets => ["transport/search.css",],#/lib/angular-ui-select/dist/materialize.css
  #~ assets => ['transport/search.js', ],#$c->auth_user ? () : 'profile.form-auth.js',
  #~ );
#~ }

sub index {
  my $c = shift;
  #~ $c->index;
  return $c->render('main/home',
    #~ handler=>'ep',
    'head-title' => 'Грузоперевозки - спецтехника - размещение - поиск - заказ',
    'meta-description'=> "Система размещения и поиска предложений и спроса услуг по грузоперевозке и оказания услуг по работе специальной техники. Заказчик и исполнитель транспортных услуг находят друг друга.",
    'meta-keywords'=>"сервис грузоперевозок, автотехника, услуги транспорта, найти, заказать, разместить". join(', ', map $_->{title}, @{$c->топ_категории}),
    'топ-категории'=>$c->top_category,
  );
    #~ if $c->is_user_authenticated;
}

=pod
sub count {# легкий подсчет транспортов и заявок
  my $c = shift;
  return $c->render( json=>{uid => undef, profile=>{}, }, )
    unless $c->is_user_authenticated;
  my $uid = $c->auth_user->{id};
  my $model_trans = $c->app->models->{'Transport'};
  my $model_ask = $c->app->models->{'Ask'};
  
  my $has_transport = $model_trans->есть_транспорт($uid);
  $c->stash('есть транспорт'=> $has_transport // 0);
  
  # обработанные заявки
  my $has_asked = $model_ask->есть_заявки($uid)
    if $has_transport;
  $c->stash('есть обработанные заявки'=> $has_asked // 0);
  
  # вновь поступившие заявки
  my $has_new_ask = $model_ask->есть_новые_заявки($uid)
    if $has_transport;
  $c->stash('есть новые заявки'=> $has_new_ask // 0);
  
  my $has_my_ask = $model_ask->есть_мои_заявки($uid);
  $c->stash('есть мои заявки'=> $has_my_ask // 0);
  
  my $data = {%{$c->auth_user}, count=>{ transport=>$has_transport // 0, asked=>$has_asked // 0, new_ask=>$has_new_ask // 0, my_ask=>$has_my_ask // 0}, _ts => scalar localtime(time-2*60*60), };
  delete @$data{qw(ts)};
  $data->{uid} = $data->{id};
  
  return  $c->render(json=>$data,);
}
=cut

sub remote_log {
  my $c = shift;
  
  my $uid = $c->auth_user->{id}
    if $c->is_user_authenticated;
  
  my $data = $c->req->json
    or return $c->render(json=>{error=>"Нет JSON данных"});
  
  $c->app->log->remote_log($uid ? $uid : 'nouser', $c->dumper($data));
  $c->render(json=>{});
  
}

#~ sub search000 {
  #~ my $c = shift;
  #~ $c->title('Результаты поиска');
  #~ $c->content('main.left'=>$c->title);
  #~ my $q = $c->vars('q')
    #~ or return;
  
  #~ my $t = $c->vars('t');
  #~ my $tab = $c->dbh->selectrow_hashref("select * from vinylhub.tab_sphinx where id=?",undef, ($t))
    #~ if $t;
  #~ $c->stash('table' => $tab)
    #~ if $tab;
  #~ $c->stash('rows' => $c->dbh->selectall_arrayref("select t.* from pllua.sphinx(?) s join discogs.$tab->{tab} t on s.id=t.aid;", {Slice => {}}, ("SELECT *, weight() as w FROM idx1 WHERE MATCH('$q') AND tab_id=$t LIMIT 0,10")))
    #~ and return
    #~ if $tab;
  #~ $c->stash('group' => $c->dbh->selectall_hashref("select attr[1] as tab_id, attr[2] as count, t.tab, t.\"таблица\"  from pllua.sphinx(?) s join vinylhub.tab_sphinx t on s.attr[1]::int=t.id;", 'tab_id', undef, ("SELECT tab_id, COUNT(*) FROM idx1 WHERE MATCH('$q') GROUP BY tab_id")));#SELECT *  FROM idx1 WHERE MATCH('алла') LIMIT 10
#~ }


#~ sub sign000 {
  #~ my $c = shift;
  #~ $c->redirect_to('profile')
    #~ if $c->auth_user;
#~ }

sub trace {
  my $c = shift;
  #~ $c->render;
}

sub trace2 {
  my $c = shift;
  $c->render('main/trace');
}

sub prepared_st {
  my $c = shift;
  $c->render(format=>'txt',); #$c->access->plugin->oauth->model->dict, 
}

1;

__DATA__
@@ main/prepared_st.txt.cgi.pl
#
$c->dumper($c->dbh->selectall_arrayref('select * from pg_prepared_statements;', {Slice=>{}},), $c->dbh->{queue}),
,
