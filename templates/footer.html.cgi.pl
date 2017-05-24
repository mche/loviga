footer({-class=>"page-footer teal darken-2"},
div({-class=>"container",}, # $c->content('footer000') ||
  div({-class=>"row",},

    div({-class=>"col l7 m7 s12",},
      h4({-class=>"white-text",},"Дружите с нами в социальных сетях"),
      ul({-class=>"",},
        li({-class=>"inline",}, a({-href=>"https://vk.com/lovigazel", -target=>"_blank", -class=>"btn000 white-text waves-effect waves-light",}, img({-src=>"/i/logo/vkontakte.png", -class=>"circle white", -style=>"height: 40px; vertical-align: middle;", -alt=>"vkontakte logo"}), span({-class=>"",}, "ontakte")),),
        
        li({-class=>"inline",}, a({-href=>"https://ok.ru/lovigazel", -target=>"_blank", -class=>"btn000 white-text waves-effect waves-light",}, img({-src=>"/i/logo/odnoklassniki.png", -class=>"circle white", -style=>"height: 40px; vertical-align: middle;", -alt=>"odnoklassniki logo"}), span({-class=>"",}, "лассники")),),
        
      ),
    ),
    div({-class=>"col l5 m5 s12",},
      a({-class=>"btn fs8 black", -href=>"https://play.google.com/store/apps/details?id=ru.lovigazel",  -target=>"_blank",  -title=>"Загрузить андроид-приложение",},
        img({-src=>"/i/logo/google-play.png", -class=>"white000", -style=>"height: 2rem;vertical-align: middle;", -alt=>"android google play"}, ''),
        span({}, 'Загрузить Android-приложение',),
        
      ),

    ),
  ).
  div({-class=>"footer-copyright",},
    div({-class=>"center",}, "© 2017 LoviGazel Inc. Права защищены."),
  ),
),

),