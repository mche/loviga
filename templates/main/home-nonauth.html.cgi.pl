

h1({-class=>"center",},"Заказать машину на сервисе грузоперевозок и услуг техники - “Лови Газель”"),

div({-class=>"row",},

div({-class=>"col s12 m4",},
  img({-src=>"/i/collage1.png", -class=>"yellow", -style=>"width:100%;", -alt=>"замечательный коллаж"}, ''),

),

ul({-class=>"col s12 m8 collection", -style=>"border: none;",},
  li({-class=>"collection-item right-align", -style=>"border: none;",}, a({-class=>"btn-large", -href=>$c->url_for('profile')->query(from=>$c->url_for->path), -title=>"Вход/Регистрация",},
    #~ i({-class=>"material-icons",}, 'exit_to_app'),
    i({-class=>"icon-login-1", -style=>"display: inline; vertical-align: middle;"}, ''),
    span({}, 'Вход / Регистрация',),
    
  ),),
  
  li({-class=>"collection-item right-align",}, 
  #~ <a href='https://play.google.com/store/apps/details?id=ru.lovigazel.test&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='' src=''/></a>
  
    a({-href=>"https://play.google.com/store/apps/details?id=ru.lovigazel.test",  -target=>"_blank",  -title=>"Загрузить андроид-приложение",},
      #~ i({-class=>"material-icons",}, 'exit_to_app'),
      #~ img({-src=>"/i/logo/google-play.png", -class=>"white000", -style=>"height: 3rem;vertical-align: middle;", -alt=>"android google play"}, ''),
      img({-src=>"https://play.google.com/intl/es_es/badges/images/generic/ru_badge_web_generic.png",  -alt=>"Доступно в Google Play"}, ''),
      #~ span({}, 'Загрузить Android-приложение',),
      
    ),
  ),
),

),

p("Сервис “Лови Газель” представляет собой систему размещения и поиска предложений и спроса услуг по грузоперевозке и оказания услуг по работе специальной техники. Система состоит из сайта и Android приложения Google Play."),

p("Используя “Лови газель” вы можете найти или получить предложение по предоставлению грузового, пассажирского, специального транспорта или техники."),

h2("Сервис “Лови Газель” - связующее звено между заказчиком и исполнителем на рынке транспортных услуг"),

table({},
  thead({},
    Tr({},
      th({-class=>"center", -style=>"width:50%; padding: 0.7rem;"}, "Владелец техники, исполнитель транспортных услуг"),
      th({-class=>"center", -style=>"padding: 0.7rem;"}, "Заказчик техники, потребитель транспортных услуг"),
    ),
  ),
  tbody({},
    Tr({},
      td({-style=>"vertical-align:top;"},
        ol({},
          li({}, "У вас есть транспорт или спецтехника и Вы хотите предложить услугу."),
          li({}, "Вы регистрируете данные своего транспорта в сервисе для работы в городе и регионе, где вы можете его предоставить."),
          li({}, "Заказчики транспотрных услуг находят ваш транспорт через поисковую форму и связываются с вами по телефону."),
          li({}, "Заказчики размещают на сервисе свои заявки на будущие сроки исполнения и вам приходят уведомления о потенциальных заявках на ваш транспорт."),
        ),
      ),
      td({-style=>"vertical-align:top;"},
        ol({},
          li({}, "У вас есть потребность в перевозке грузов, работе спецтехники, прочих транспортных услуг."),
          li({}, "Можно без регистрации воспользоваться поиском транспортного средства / спецтехники / услуги и связаться с найденным исполнителем по его телефону."),
          li({}, "Вы можете создать аккаунт этого сервиса и сохранить свою заявку на транспорт. Заявка будет предложена соответсвующим исполнителям. Заинтересованные исполнители свяжутся с вами по телефону, указанному в вашей заявке."),
          
        ),
      ),
    ),
    
    
  ),

),