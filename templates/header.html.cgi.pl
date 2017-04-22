my $signed = $c->auth_user->{id}
  if $c->is_user_authenticated;
my $has_transport = $c->stash('есть транспорт') // $c->app->models->{'Transport'}->есть_транспорт( $signed )
  if $signed;
my $has_asked = $c->stash('есть обработанные заявки') // $c->app->models->{'Ask'}->есть_заявки($signed)
  if $signed;
my $has_new_ask = $c->stash('есть новые заявки') // $c->app->models->{'Ask'}->есть_новые_заявки($signed)
  if $signed;
my $has_my_ask = $c->stash('есть мои заявки') // $c->app->models->{'Ask'}->есть_мои_заявки($signed)
  if $signed;

header(
div({-class=>"header clearfix",},

nav({-class=>"top"},
div({-class=>"nav-wrapper",},
  div({-class=>"logo left",},
    a({-href=>"/", -class=>"brand-logo1 btn-floating btn-large teal lighten-1",},
      #~ img({-src=>"/i/truck-48-237857.png", -alt=>"", -style=>"width:70%; vertical-align: middle;"}),
      img({-src=>"/i/logo/lovigazel.png", -alt=>"", -style=>"width:70%; vertical-align: middle;"}),
      #~ i({-class=>"material-icons  black-text",}, 'home'),
    ),
  ),#$c->config('Проект') <i class="material-icons">album</i>
  
  h1({-class=>"left white-text"}, $c->stash('header-title') || $c->title || $c->config('Проект')),
  
  #~ div({-class=>"form-search right", -style=>"width: 55%; margin-right: 0;"}, $c->include('forms/search',),),
  ul({-class=>"left grey-text"},
    li({},
      a({-href=>"javascript:",},
        i({-class=>"material-icons",}, 'search'),
        span({}, "Поиск транспорта"),
      ),
      
    ),
  ),
  
  ul({-class000=>"fixed-action-btn horizontal click-to-toggle", -style=>"position:absolute; top: 0px; right: 0px;",},#hide-on-med-and-down0100
    $signed
    ? li({-class=>"notifications-container", }, a({-class=>"button-collapse000 btn-floating btn-large black right-side full hide-on-large-only000", -style=>"", 'data-activates'=>"right-side-top-nav", -href=>"#", },#'cachedAjaxScript'=>"/js/materialize/sideNav.js",
      #~ ($has_new_ask || 1) && span({-class=>"notifications-container", },
       span({-class=>"notifications-icon overlay grow infinite yellow darken-2 white-text ".($has_new_ask || 'hide'), -style=>"right: 10px; top: 10px;"}, ''),#span({-class=>"notifications-icon-count"},'!')
       #~ span({-class=>"notification-inner",},    )
      #~ ),
      i({-class=>"material-icons teal lighten-1 black-text",},'menu'),#
      
      
      
    ),
    
  )
    : $c->match->endpoint && $c->match->endpoint->name ne 'profile'
      ? li({},
          a({-class=>"btn-large000 black-text000 teal000 lighten-1000", -href=>$c->url_for('profile')->query(from=>$c->url_for->path), -title=>"Вход/Регистрация",},#btn-large000 black-text000 teal000 lighten-1000
            #~ i({-class=>"material-icons",}, 'exit_to_app'),
            i({-class=>"icon-login-1", -style=>"display: inline; vertical-align: middle;"}, ''),
            span({-class=>"hide-on-small-only",}, 'Вход/Регистрация',),
            
          ),
        )# icon 
        
      : (),
  ),
  
  $c->stash("контент в верхней навигации") && div({-class=>"right"}, $c->stash("контент в верхней навигации")),
  

),
),

#~ $c->stash('javascripts', $c->stash('javascripts') ? () : []) && undef,
#~ push(@{$c->stash('javascripts')}, "/controllers/sidenav/sidenav.js") && undef,

#~ div({'ng-module'=>"RightSideNav", }, 
#~ div({'ng-controller'=>"ControllRightSideNav as ctrl",}, 

($signed || '') && div({-id=>"right-side-top-nav", -class=>"side-nav", },
  
  ul({-style=>"margin:0;",},#jq-dropdown-menu
  
  li({},# только если есть?
    a({-href=>$c->url_for('поиск транспорта'),},
      i({-class=>"material-icons",}, 'search'),
      span({}, "Поиск транспорта",),
    )
  ),
  
  li({},
    $has_transport
    ? a({-href=>$c->url_for('мой транспорт'),},
      img({-src=>"/i/truck-48-237857.png", -alt=>"",}),
    "Мой транспорт ($has_transport)",
    )
    : a({-href=>$c->url_for('форма нового транспорта'),},
      img({-src=>"/i/truck-48-237857.png", -alt=>"",}),
      'Предложить транспортную услугу',
    )
    ,
  ),
  
($has_new_ask || $has_asked || '') && li({},
    a({-href=>$c->url_for('заявки на мой транспорт')->query($has_new_ask ? ('s'=>10) : ('s'=>60)), -class=>"notifications-container000", },
      i({-class=>"icon-hand-paper-o fs14",}, ''),
      
      span({-class=>"notifications-container", },
        span({-class=>"notifications-icon overlay yellow darken-2 white-text ".($has_new_ask || 'hide')}, ''),#span({-class=>"notifications-icon-count"},'!')
        span({-class=>"notification-inner",},
          span("Спрос на мой транспорт ($has_new_ask/$has_asked)"),
        ),
      ),
      #~ span({-class=>"bubble red",}, '&nbsp;'),
    ),
  ),
  
  li({},# только если есть?
    $has_my_ask
    ? a({-href=>$c->url_for('мои заявки'),},
      i({-class=>"material-icons",}, 'description'),
      span({}, "Мои заявки на транспорт ($has_my_ask)",),
    )
    : a({-href=>$c->url_for('поиск транспорта'),},
      i({-class=>"material-icons",}, 'description'),
      span({}, 'Мне нужен транспорт',),
    ),
  ),
  
  li({}, a({-class00=>"btn-floating btn green-grey", -href=>$c->url_for('profile')->query(from=>$c->url_for->path),}, i({-class=>"material-icons",}, 'person'), 'Профиль', ), ),
  
  li({}, a({-class00=>"btn-floating btn green-grey", -href=>$c->url_for('logout')->query(from=>$c->url_for->path),}, i({-class=>"material-icons",}, 'lock_outline'), 'Выход', )),
  
  
  
  li(
    a({-class=>"dropdown-button", -href=>"#!", 'data-activates'=>"dropdown123"}, 'Еще ...',
      i({-class=>"material-icons right000",}, 'arrow_drop_down'),
    ),
  ),
  ul({-id=>'dropdown123', -class=>'dropdown-content',},
    li(a({-href=>"#!",}, 'Первый туда'),),
    li(a({-href=>"#!",}, 'Второй сюда'),),
    li(a({-href=>"#!",}, 'Третий оттуда'),),
  ),
  #~ map {li({}, a({-href=>"#$_", -class=>"waves-effect waves-teal",}, "еще пункт...$_"))} (3..10),
),
#~ div({'ng-if'=>"ctrl.ready", 'ng-include'=>" 'sidenav/main' "}, ''),
),
#~ ),),

),
),

#~ div({-id=>"jq-dropdown-topmenu-button", -class=>"jq-dropdown jq-dropdown-tip jq-dropdown-anchor-right",},
  
#~ ),
