$c->layout('main', handler=>'ep', );
  #~ unless $c->req->headers->to_hash->{'X-Content-Only'};
my $error = $c->vars('error', 'err');

$error && div({-style=>"color:red;"}, 'Ошибка авторизации: ', $error),

#~ $c->req->headers->to_hash->{'X-Content-Only'} && $c->asset('profile.form-auth.js'),
h2({-class=>"center",}, 'Вход и регистрация'),

div({-class=>"row", "ng-app"=>"formAuth", "ng-controller"=>"formAuthControll as ctrl",}, 
  #~ div({-class=>"col m6 s12"},
    #~ div({-class=>"card teal lighten-5",},
      #~ div({-class=>"card-content",},
        #~ h2({-class=>"center",}, 'Использовать аккаунты сайтов'),
        #~ ul({-class=>"collection",},
          #~ map (li({-class=>"collection-item",},
            #~ a({-class=>"btn-floating btn-large000 ".($_->{btn_class} || 'white'), -href=>$c->url_for('oauth-login', site=> $_->{name})->query(redirect=>'home'), -style=>"line-height: normal;",},
              #~ img({-src=>"/img/logo/$_->{name}.png", -style=>"width: 100%; vertical-align: middle;".($_->{logo} && $_->{logo}{style}), -alt=>"$_->{name} logo",}, ''),
              ###i({-class=>"large material-icons",}, "filter_$_->{id}"),),
              
            #~ ), span($_->{title} || $_->{name}),
          #~ ), grep($_->{id}, values %{$c->oauth2->providers})),#@{$c->stash('sites')}),
          
        #~ ),
      #~ ),
    #~ ),
  #~ ),
  div({'ng-hide'=>"ctrl.ready", 'ng-include'=>" 'progress/load' ",}, ''),
  div({-class=>"col l8 m12 s12"},
    
    #~ h4('Авторизация/регистрация'),
      #~ form({-id00=>"formAuth", -class=>"", -method=>"post", -action000=>$c->url_for("обычная авторизация/регистрация"), },
        
        #~ div({'ng-if'=>"ctrl.ready", 'ng-include'=>" 'profile/form-auth' "}, ''),
        form_auth({'ng-if'=>"ctrl.ready",}, ''),
      #~ ),
    ul({-class=>"collection card",}, 
      li({-class=>"collection-item",}, "Для входа укажите свой логин - email-адрес или телефон в формате (ХХХ) ХХХ-ХХ-ХХ"),
      li({-class=>"collection-item",}, "Для новой регистрации укажите логин. Можно использовать email-адрес или телефон в формате (ХХХ) ХХХ-ХХ-ХХ. После проверки логина потребуется ввести антибот-капча-код"),
    ),
  ),
  div({-class=>"col l4 m12 s12"},
    
    form_oauth({'ng-if'=>"ctrl.ready",}, ''),
    ul({-class=>"collection card",}, 
      li({-class=>"collection-item",}, "Для входа можно использовать регистрации других сайтов: Google.com, Yandex.ru, Mail.ru, Vkontakte.ru"),
      li({-class=>"collection-item",}, "Для новой регистрации можно использовать регистрации других сайтов: Google.com, Yandex.ru, Mail.ru, Vkontakte.ru . После такой регистрации также возможно добавить логин/пароль в своем профиле."),
    ),
  ),
),