'<footer class="page-footer">',
div({-class=>"container",}, $c->content('footer')
 ||
  div({-class=>"row",
    #~ div({-class=>"col l4 s12",},
              #~ <h5 class="white-text">J проекту</h5>
              #~ <p class="grey-text text-lighten-4"></p>

    #~ ),
    div({-class=>"col s12",},
      h4({-class=>"white-text",},"Дружите с нами в социальных сетях"),
      ul({},
        li({}, a({-href=>"https://vk.com/lovigazel", -target=>"_blank", -class=>"btn waves-effect waves-light",}, img({-src=>"/i/logo/vkontakte.png", -class=>"circle white", -style=>"height: 40px; vertical-align: middle;", -alt=>"vkontakte logo"}), span({-class=>"",}, "ontakte")),),
        
        
        
      ),
    ),
  ),
  div({-class=>"footer-copyright",},
    div({-class=>"",}, "© 2017 LoviGazel Inc. Права защищены."),
  ),
),

'</footer>',