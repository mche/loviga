my $uid = $c->auth_user->{id}
  if $c->is_user_authenticated;
my $has_transport = $c->stash('есть транспорт') // $c->app->models->{'Transport'}->есть_транспорт( $uid )
  if $uid;
my $has_ask = $c->stash('есть мои заявки') // $c->app->models->{'Ask'}->есть_мои_заявки($uid)
  if $uid;
my $has_new_ask = $c->stash('есть новые заявки') // $c->app->models->{'Ask'}->есть_новые_заявки($uid)
  if $uid;
$c->layout('main', handler=>'ep', 'title-only'=>'Начало');

#~ div({}, $c->include('forms/search', handler=>'cgi.pl',)),

#~ div({}, $c->include('main/top-category-list', handler=>'cgi.pl',)),

$uid 
  ? ul(
  
  $has_new_ask
  ? li({-class=>"inline",},
    a({-href=>$c->url_for('заявки на мой транспорт')->query(s=>10), -class=>"btn-large green darken-2",}, "Новые заявки на мой транспорт ($has_new_ask)"),
  ) : (),
  
  li({-class=>"inline",},
    $has_transport
    ? a({-href=>$c->url_for('мой транспорт'), -class=>"btn-large green darken-2",}, "Мой транспорт ($has_transport)")
    : a({-href=>$c->url_for('форма нового транспорта'), -class=>"btn-large green darken-2",}, "Могу предложить транспортную услугу"),
  ),
  li({-class=>"inline",},
    $has_ask
    ? a({-href=>$c->url_for('мои заявки'), -class=>"btn-large green darken-2",},
      #~ i({-class=>"material-icons",}, 'description'),
      span({}, "Мои заявки на транспорт ($has_ask)",),
    )
    : a({-href=>$c->url_for('поиск транспорта'), -class=>"btn-large green darken-2",},
      #~ i({-class=>"material-icons",}, 'description'),
      span({}, 'Мне нужен транспорт',),
    ),
  ),
  )
  : $c->include('main/home-nonauth', handler=>'cgi.pl'), 


