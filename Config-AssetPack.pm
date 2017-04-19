[ # cpanm JavaScript::Minifier::XS CSS::Sass CSS::Minifier::XS
  'AssetPack::Che' => {
    pipes => [qw(Sass Css JavaScript HTML CombineFile)],
    CombineFile => {
      url_lines =>{# только для morbo
        'controllers/transport/list.html'=>"@@@ transport/list",
        'controllers/ask/form.html'=>"@@@ ask/form",
        'controllers/ask/list.html'=>"@@@ ask/list",
        'controllers/ask/me-list.html'=>"@@@ ask/me-list",
        'controllers/ask/item.html'=>"@@@ ask/item",
        'controllers/ask/show-tel.html'=>"@@@ ask/show-tel",
        'controllers/states/tel-results.html'=>"@@@ states/tel-results",
        'controllers/states/icon.html'=>"@@@ states/icon",
        'controllers/transport/search.html'=> "@@@ transport/search",
        #~ 'controllers/transport/search/item-detail.html'=> "@@@ transport/search/item-detail",
        'controllers/transport/category/list.html'=> "@@@ transport/category/list",
        'controllers/address/address.html'=>"@@@ address.select", # адресный компонент
        #~ 'controllers/address/ui-select.tpls.html'=> "@@@ просто разделитель",# там свои разделители
        'controllers/address/materialize/select.tpl.html'=> "@@@ materialize/select.tpl.html",#
        'controllers/address/materialize/match.tpl.html'=> "@@@ materialize/match.tpl.html",#
        'controllers/address/materialize/choices.tpl.html'=> "@@@ materialize/choices.tpl.html",#
        'controllers/address/materialize/no-choice.tpl.html'=> "@@@ materialize/no-choice.tpl.html",#
        
        'controllers/transport/form.html'=>"@@@ transport/form",
        'controllers/tel/tel-list.html'=>"@@@ tel.list",
        'controllers/transport/category/list.html'=>"@@@ transport/category/list", 
        'controllers/img-upload-list/img-upload-list.html'=>"@@@ img.upload.list",
        'controllers/rating-stars/directive.html'=>"@@@ rating-stars-directive.html",
        'controllers/states/list.html'=>"@@@ states/list",
        'controllers/tel/tel-show-list.html'=>"@@@ tel/show-list",
        'controllers/profile/form-auth.html'=>"@@@ profile/form-auth",
        'controllers/profile/form-oauth.html'=>"@@@ profile/form-oauth",
        'controllers/profile/form.html'=>"@@@ profile/form",
        'controllers/profile/oauth.html' => "@@@ profile/oauth",
        'controllers/transport/status.html' => "@@@ transport/status",
        'controllers/address/type.html'=> "@@@ address/type",
        'controllers/transport/search/results.html'=> "@@@ transport/search/results",
        'controllers/transport/search/show-tel.html'=>"@@@ transport/search/show-tel",
        'controllers/transport/item-detail.html'=>"@@@ transport/item-detail",
      },
      gzip => {min_size => 1000},
    },
    HTML => {minify_opts=>{remove_newlines => 0,}},# чета при удалении переводов строк  проблемы
    process => [# хэшреф убрал для последовательности
      ['ui-select/address.css'=> "controllers/address/address.css",],#lib/angular-ui-select/dist/materialize.css
      ['rating-stars.css'=> "controllers/rating-stars/style.scss",],
      ['rating-stars.js'=> qw(
        controllers/rating-stars/module.js
        controllers/rating-stars/controller.js
        controllers/rating-stars/directive.js
      
      ),],
      ['address/ui-select.html'=> qw(
        controllers/address/materialize/select.tpl.html
        controllers/address/materialize/match.tpl.html
        controllers/address/materialize/choices.tpl.html
        controllers/address/materialize/no-choice.tpl.html
        ),
      ],
      #~ ['ask/list.css'=> qw(
      #~ css/fontello/fontello.css
      #~ )],
      ['ask/list.html'=> qw(
        controllers/ask/list.html
        controllers/transport/item-detail.html
      
      )],
      ['ask/list.js' => qw(
        controllers/phone-input/phone-input.js
        rating-stars.js
        controllers/states/data.js
        controllers/transport/item-detail.js
        controllers/ask/list.js
      ),],
      ['ask/me-list.css'=> qw(
        rating-stars.css
      ),],
      ['ask/me-list.html'=> qw(
        controllers/ask/me-list.html
        controllers/ask/item.html
        controllers/ask/show-tel.html
        controllers/rating-stars/directive.html
        controllers/states/list.html
        controllers/states/tel-results.html
        controllers/tel/tel-show-list.html
        controllers/states/icon.html
      ),],
      ['ask/me-list.js'=> qw(
        controllers/phone-input/phone-input.js
        rating-stars.js
        controllers/states/data.js
        controllers/states/list.js
        controllers/states/tel-results.js
        controllers/states/icon.js
        controllers/tel/tel-show-list.js
        controllers/ask/item.js
        controllers/ask/show-tel.js
        controllers/ask/me-list.js
        
      ),],
      #~ 'ask/form.js' => [ это есть transport/search.js
      
      ['materialize.js'=>qw(
      
        lib/materialize/js/initial.js
        lib/materialize/js/jquery.easing.1.3.js
        lib/materialize/js/animation.js
        lib/materialize/js/velocity.min.js
        lib/materialize/js/global.js

        lib/materialize/js/hammer.min.js
        lib/materialize/js/jquery.hammer.js

        lib/materialize/js/modal.js

        lib/materialize/js/tabs.js

        lib/materialize/js/waves.js

        lib/materialize/js/sideNav.js

        lib/materialize/js/forms.js
      )],

                    #~ lib/materialize/js/dropdown.js
                                  #~ lib/materialize/js/collapsible.js
                    #~ lib/materialize/js/materialbox.js
        #~ lib/materialize/js/parallax.js
                    #~ lib/materialize/js/tooltip.js
                    #~ lib/materialize/js/toasts.js
                    #~ lib/materialize/js/scrollspy.js
                    #~ lib/materialize/js/slider.js
        #~ lib/materialize/js/cards.js
        #~ lib/materialize/js/chips.js
      #~ lib/materialize/js/pushpin.js
      #~ lib/materialize/js/buttons.js
      #~ lib/materialize/js/transitions.js
        #~ lib/materialize/js/scrollFire.js
        #~ lib/materialize/js/date_picker/picker.js
        #~ lib/materialize/js/date_picker/picker.date.js
        #~ lib/materialize/js/character_counter.js
        #~ lib/materialize/js/carousel.js
        #~ lib/materialize/js/tapTarget.js
      
      ['lib.js'=> grep !/^\s*#/, qw(
        lib/angular/angular.js
#lib/jquery/jquery.min.js
        lib/jquery/dist/jquery.min.js
        materialize.js
        controllers/template-cache/script.js
        js/jquery.autocomplete.js
        ),
        #js/searchcomplete.js
        #~ lib/materialize/js/bin/materialize.js
        #~ lib/materialize/js/sideNav.js
        #~ "controllers/array-storage/array-storage.js",
        # !!! внимание минификация через uglify, проблемы с точками-запятой
        # вручную убрал блоки кода по picker.date.js и picker.js (там была ошибка, дважды повтор)
        #~ "lib/ng-module/ng-module.js",# больше одного ng-app (делать ng-module и разделять ng-controller
      ],
      
      ['main.js' => qw(
        js/main.js
        js/app.js
        js/routes.js
        js/user.js
        ),
      
      ],
      ['transport/list.html'=> qw(
        controllers/transport/list.html
        controllers/transport/status.html
      ),],
      ['transport/list.js' => qw(
        controllers/transport/status.js
        controllers/transport/list.js
      ),],
      
      ['transport/search.css'=> qw(
        ui-select/address.css
        rating-stars.css
        
      ),],
      ['transport/search.html'=> qw(
        controllers/transport/search.html
        controllers/transport/search/results.html
        controllers/transport/search/show-tel.html
        controllers/ask/form.html
        controllers/transport/item-detail.html
        controllers/transport/category/list.html
        controllers/address/address.html
        address/ui-select.html
        controllers/rating-stars/directive.html
        controllers/states/list.html
        controllers/states/tel-results.html
        controllers/states/icon.html
        controllers/tel/tel-show-list.html
        controllers/address/type.html
        ),
          #~ "controllers/address/ui-select.tpls.html", разделители шаблонов схлопнулись
      ],
      ['datetime.picker.js'=> grep !/^\s*#/, qw(
#внимание-минификация-через-uglify-нет-точек-с-запятой
#-хе-новая-версия-прошла
        lib/materialize/js/date_picker/picker.min.js
#-делал-исправления-в-материализованном-календаре-по-отображению-месяца-и-навигации
        lib/materialize/js/date_picker/picker.date.min.js
#не-материализ!
        lib/materialize/js/date_picker/picker.time.min.js
        lib/materialize/js/date_picker/ru_RU.js
      
      )],
      ['transport/search.js'=> grep !/^#/, qw(
        controllers/transport/category/list.js
        controllers/address/select.js
        controllers/address/address.js
        controllers/address/type.js
        controllers/phone-input/phone-input.js
        js/util/detectmobilebrowser.js
        rating-stars.js
        controllers/states/data.js
        controllers/states/list.js
        controllers/states/tel-results.js
        controllers/states/icon.js
        controllers/tel/tel-show-list.js
        controllers/transport/item-detail.js
#controllers/ask/services.js
        controllers/transport/search/results.js
        controllers/transport/search/show-tel.js
        controllers/ask/form.js
        controllers/transport/search.js
        datetime.picker.js
        lib/angular-sanitize/angular-sanitize.js
        ),
        #lib/angular-ui-select/dist/select.js переместил в controllers/address/
        #~ "lib/pickadate/lib/picker.js",
        #~ "lib/pickadate/lib/picker.date.js",
        #~ "lib/jquery.scrollTo/jquery.scrollTo.js",
      ],
      
      ['transport/form.css'=> qw(
        ui-select/address.css
      
      ),],
      ['transport/form.html'=> qw(
        controllers/transport/form.html
        controllers/tel/tel-list.html
        controllers/transport/category/list.html
        controllers/img-upload-list/img-upload-list.html
        controllers/address/address.html
        address/ui-select.html
        controllers/transport/status.html
        controllers/address/type.html
        ),
      ],
      ['transport/form.js' => qw(
        lib/ng-file-upload/ng-file-upload-all.min.js
        controllers/img-upload-list/img-upload-list.js
        controllers/transport/category/list.js
        js/util/array-move.js
        controllers/address/select.js
        controllers/address/address.js
        controllers/address/type.js
        controllers/phone-input/phone-input.js
        controllers/tel/tel-list.js
        controllers/transport/status.js
        controllers/transport/form.js
        ),
        #lib/angular-ui-select/dist/select.js переместил в controllers/address/
      ],
      
      ['profile/form.html'=>qw(
      controllers/profile/form.html
      controllers/profile/oauth.html
      )],
      ['profile/form.js' => grep !/^#/, qw(
        #~lib/angular-md5/angular-md5.js
        lib/jquery-md5/jquery.md5.js
        controllers/phone-input/phone-input.js
        controllers/profile/lib.js
        controllers/profile/form.js
        ),
      ],
      
      ['profile/form-auth.html'=>qw(
      controllers/profile/form-auth.html
      controllers/profile/form-oauth.html
      )],
      ['profile/form-auth.js' => 
        #~ "lib/angular-md5/angular-md5.js",
        qw(
        lib/jquery-md5/jquery.md5.js
        controllers/phone-input/phone-input.js
        controllers/profile/lib.js
        controllers/profile/form-auth.js
        
        ),
      ],
      
      [ 'main.css'=> grep !/^#/, qw(
        https://fonts.googleapis.com/icon?family=Material+Icons
        https://fonts.googleapis.com/css?family=Roboto:400,700
#android/lib/onsenui/css/onsenui.css
#android/lib/onsenui/css/onsen-css-components-default.css
        sass/main.scss
        css/fontello/fontello.css
        
        ),
        #lib/font-awesome/scss/font-awesome.scss
        #https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css
        # материализные стили импортированы там
        #~ "lib/pickadate/lib/themes/default.css",
        #~ "lib/pickadate/lib/themes/default.date.css",
      ],#
      
      ['top-search.json'=>qw(controllers/transport/category/search.json)],
      ['transport/category/tree.json'=>qw(controllers/transport/category/tree.json)],

# приложение
['ng-cordova-oauth.js'=>qw(
android/lib/ng-cordova-oauth/src/utility.js
android/lib/ng-cordova-oauth/src/oauth.google.js
android/lib/ng-cordova-oauth/src/oauth.mailru.js
android/lib/ng-cordova-oauth/src/oauth.vkontakte.js
android/lib/ng-cordova-oauth/src/oauth.yandex.js
android/lib/ng-cordova-oauth/src/oauth.js
android/lib/ng-cordova-oauth/src/plugin.js
)],# в oauth.js закомментировал ненужные сайты
['android/app.js'=>qw(
android/js/app.js
android/js/services.js
android/js/controllers.js

)],
['android/main.js'=> grep !/^#/, qw(
android/lib/angular/angular.js
android/lib/angular-sanitize/angular-sanitize.js
android/lib/ngstorage/ngStorage.js
android/lib/angular-animate/angular-animate.js
#android/lib/angular-ui-router/release/angular-ui-router.js
android/lib/jquery/dist/jquery.js
materialize.js

android/lib/onsenui/js/onsenui.js
android/lib/onsenui/js/angular-onsenui.js

#cordova-apps/ionic-lovigazel/www/lib/ionic/js/ionic.js
#ordova-apps/ionic-lovigazel/www/lib/ionic/js/ionic-angular.js

android/lib/ngCordova/dist/ng-cordova.js
ng-cordova-oauth.js

controllers/template-cache/script.js
###шаблоны_прогреса_свои_
js/user.js
js/debug.js
js/routes.js
js/app.js

android/app.js

#android/lib/angular-cookies-mirror/angular-cookies-mirror.min.js

#profile/form-auth.js
lib/jquery-md5/jquery.md5.js
controllers/phone-input/phone-input.js
controllers/profile/lib.js
controllers/profile/form-auth.js
controllers/profile/form.js

#поиск/заявка
controllers/transport/category/list.js
controllers/address/select.js
controllers/address/address.js
controllers/address/type.js
datetime.picker.js
#
#библиотека-по-поиску
controllers/transport/search.js
controllers/states/data.js
controllers/states/list.js
controllers/states/tel-results.js
controllers/states/icon.js
controllers/tel/tel-show-list.js
controllers/transport/item-detail.js
controllers/transport/search/results.js
controllers/transport/search/show-tel.js
controllers/ask/form.js

#заявки/список
rating-stars.js
controllers/ask/list.js

#трансп/форм
lib/ng-file-upload/ng-file-upload-all.min.js
controllers/img-upload-list/img-upload-list.js
controllers/tel/tel-list.js
controllers/transport/status.js
js/util/array-move.js
controllers/transport/form.js

#трансп/список
controllers/transport/status.js
controllers/transport/list.js

#спрос/список
controllers/ask/item.js
controllers/ask/me-list.js
controllers/ask/show-tel.js

)],#android/main.js

['android/main.css'=>grep !/^#/, qw(

#main.css
android/lib/onsenui/css/onsenui.css
android/lib/onsenui/css/onsen-css-components-default.css
android/sass/main.scss
#cordova-apps/ionic-lovigazel/www/css/ionic.app.css
main.css
ui-select/address.css
rating-stars.css

)],#
#~ ['app/config.json'=>qw(android/app-config.json)], # отдельно для изменения версий и очистки кэша
['android/templates.html'=>grep !/^#/, qw(

android/templates/layout/menu.html
android/templates/layout/toolbar.html
android/templates/layout/nav.html
android/templates/login.html
android/templates/home.html
android/templates/profile.html
android/templates/progress.html
android/templates/transport/search.html
android/templates/transport/item-detail.html
android/templates/transport/search/results.html
android/templates/transport/show-tel.html
android/templates/transport/form.html
android/templates/transport/list.html
android/templates/ask/list.html
android/templates/ask/me-list.html
android/templates/ask/show-tel.html
android/templates/ask/item.html


#cordova-apps/ionic-lovigazel/www/templates/browse.html
#cordova-apps/ionic-lovigazel/www/templates/login.html
#cordova-apps/ionic-lovigazel/www/templates/menu.html
#cordova-apps/ionic-lovigazel/www/templates/playlist.html
#cordova-apps/ionic-lovigazel/www/templates/playlists.html
#cordova-apps/ionic-lovigazel/www/templates/search.html


controllers/profile/form-auth.html
controllers/profile/form-oauth.html
controllers/profile/form.html
controllers/profile/oauth.html

#поиск/заявка
controllers/transport/category/list.html
controllers/address/address.html
address/ui-select.html
controllers/address/type.html
controllers/ask/form.html
controllers/states/list.html
controllers/tel/tel-show-list.html
controllers/transport/item-detail.html
controllers/transport/search/results.html
controllers/transport/search/show-tel.html
controllers/rating-stars/directive.html

#заявки/список
controllers/ask/list.html

#трансп/форма
controllers/tel/tel-list.html
controllers/img-upload-list/img-upload-list.html
controllers/transport/status.html
controllers/transport/form.html

#трансп/список
controllers/transport/list.html
controllers/transport/status.html

#спрос/список
controllers/ask/me-list.html
controllers/ask/item.html
controllers/ask/show-tel.html
controllers/states/tel-results.html
controllers/states/icon.html

)],
    ],
  },
];