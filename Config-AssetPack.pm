[ # cpanm JavaScript::Minifier::XS CSS::Sass CSS::Minifier::XS
  'AssetPack::Che' => {
    pipes => [qw(Sass Css JavaScript HTML CombineFile)],
    CombineFile => {
      version=>"2017-09-08T10:00",
      url_lines =>{# только для morbo
        'c/transport/list.html'=>"@@@ transport/list",
        'c/ask/form.html'=>"@@@ ask/form",
        'c/ask/list.html'=>"@@@ ask/list",
        'c/ask/me-list.html'=>"@@@ ask/me-list",
        'c/ask/item.html'=>"@@@ ask/item",
        'c/ask/show-tel.html'=>"@@@ ask/show-tel",
        'c/states/tel-results.html'=>"@@@ states/tel-results",
        'c/states/icon.html'=>"@@@ states/icon",
        'c/transport/search.html'=> "@@@ transport/search",
        #~ 'c/transport/search/item-detail.html'=> "@@@ transport/search/item-detail",
        'c/transport/category/list.html'=> "@@@ transport/category/list",
        'c/address/address.html'=>"@@@ address/select", # адресный компонент
        'c/address/address2.html'=>"@@@ address/select2", # 
        #~ 'c/address/ui-select.tpls.html'=> "@@@ просто разделитель",# там свои разделители
        'c/address/materialize/select.tpl.html'=> "@@@ materialize/select.tpl.html",#
        'c/address/materialize/match.tpl.html'=> "@@@ materialize/match.tpl.html",#
        'c/address/materialize/choices.tpl.html'=> "@@@ materialize/choices.tpl.html",#
        'c/address/materialize/no-choice.tpl.html'=> "@@@ materialize/no-choice.tpl.html",#
        
        'c/transport/form.html'=>"@@@ transport/form",
        'c/tel/tel-list.html'=>"@@@ tel.list",
        'c/transport/category/list.html'=>"@@@ transport/category/list", 
        'c/img-upload-list/img-upload-list.html'=>"@@@ img.upload.list",
        'c/rating-stars/directive.html'=>"@@@ rating-stars-directive.html",
        'c/states/list.html'=>"@@@ states/list",
        'c/tel/tel-show-list.html'=>"@@@ tel/show-list",
        'c/profile/form-auth.html'=>"@@@ profile/form-auth",
        'c/profile/form-oauth.html'=>"@@@ profile/form-oauth",
        'c/profile/form.html'=>"@@@ profile/form",
        'c/profile/oauth.html' => "@@@ profile/oauth",
        'c/transport/status.html' => "@@@ transport/status",
        'c/address/type.html'=> "@@@ address/type",
        'c/transport/search/results.html'=> "@@@ transport/search/results",
        'c/transport/search/show-tel.html'=>"@@@ transport/search/show-tel",
        'c/transport/item-detail.html'=>"@@@ transport/item-detail",
      },
      gzip => {min_size => 1000},
    },
    HTML => {minify_opts=>{remove_newlines => 0,}},# чета при удалении переводов строк  проблемы
    process => [# хэшреф убрал для последовательности
      ['ui-select/address.css'=> "c/address/address.css",],#lib/angular-ui-select/dist/materialize.css
      ['rating-stars.css'=> "c/rating-stars/style.scss",],
      ['rating-stars.js'=> qw(
        c/rating-stars/module.js
        c/rating-stars/controller.js
        c/rating-stars/directive.js
      
      ),],
      ['address/ui-select.html'=> qw(
        c/address/materialize/select.tpl.html
        c/address/materialize/match.tpl.html
        c/address/materialize/choices.tpl.html
        c/address/materialize/no-choice.tpl.html
        ),
      ],
      #~ ['ask/list.css'=> qw(
      #~ css/fontello/fontello.css
      #~ )],
      ['ask/list.html'=> qw(
        c/ask/list.html
        c/transport/item-detail.html
      
      )],
      ['ask/list.js' => qw(
        c/phone-input/phone-input.js
        rating-stars.js
        c/states/data.js
        c/transport/item-detail.js
        c/ask/list.js
      ),],
      ['ask/me-list.css'=> qw(
        rating-stars.css
      ),],
      ['ask/me-list.html'=> qw(
        c/ask/me-list.html
        c/ask/item.html
        c/ask/show-tel.html
        c/rating-stars/directive.html
        c/states/list.html
        c/states/tel-results.html
        c/tel/tel-show-list.html
        c/states/icon.html
      ),],
      ['ask/me-list.js'=> qw(
        c/phone-input/phone-input.js
        rating-stars.js
        c/states/data.js
        c/states/list.js
        c/states/tel-results.js
        c/states/icon.js
        c/tel/tel-show-list.js
        c/ask/item.js
        c/ask/show-tel.js
        c/ask/me-list.js
        
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
        
        lib/materialize/js/dropdown.js
        lib/materialize/js/collapsible.js
        
        
        
      )],

                    #~ 
                                  #~ 
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
        c/template-cache/script.js
        js/jquery.autocomplete.js
        ),
        #js/searchcomplete.js
        #~ lib/materialize/js/bin/materialize.js
        #~ lib/materialize/js/sideNav.js
        #~ "c/array-storage/array-storage.js",
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
        c/transport/list.html
        c/transport/status.html
      ),],
      ['transport/list.js' => qw(
        c/transport/status.js
        c/transport/list.js
      ),],
      
      ['transport/search.css'=> qw(
        ui-select/address.css
        rating-stars.css
        
      ),],
      ['transport/search.html'=> qw(
        c/transport/search.html
        c/transport/search/results.html
        c/transport/search/show-tel.html
        c/ask/form.html
        c/transport/item-detail.html
        c/transport/category/list.html
        c/address/address.html
        c/address/address2.html
        address/ui-select.html
        c/rating-stars/directive.html
        c/states/list.html
        c/states/tel-results.html
        c/states/icon.html
        c/tel/tel-show-list.html
        c/address/type.html
        ),
          #~ "c/address/ui-select.tpls.html", разделители шаблонов схлопнулись
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
        c/transport/category/list.js
        c/address/select.js
        c/address/address.js
        c/address/type.js
        c/phone-input/phone-input.js
        js/util/detectmobilebrowser.js
        rating-stars.js
        c/states/data.js
        c/states/list.js
        c/states/tel-results.js
        c/states/icon.js
        c/tel/tel-show-list.js
        c/transport/item-detail.js
#c/ask/services.js
        c/transport/search/results.js
        c/transport/search/show-tel.js
        c/ask/form.js
        c/transport/search.js
        datetime.picker.js
        lib/angular-sanitize/angular-sanitize.js
        ),
        #lib/angular-ui-select/dist/select.js переместил в c/address/
        #~ "lib/pickadate/lib/picker.js",
        #~ "lib/pickadate/lib/picker.date.js",
        #~ "lib/jquery.scrollTo/jquery.scrollTo.js",
      ],
      
      ['transport/form.css'=> qw(
        ui-select/address.css
      
      ),],
      ['transport/form.html'=> qw(
        c/transport/form.html
        c/tel/tel-list.html
        c/transport/category/list.html
        c/img-upload-list/img-upload-list.html
        c/address/address.html
        address/ui-select.html
        c/transport/status.html
        c/address/type.html
        ),
      ],
      ['transport/form.js' => qw(
        lib/ng-file-upload/ng-file-upload-all.min.js
        c/img-upload-list/img-upload-list.js
        c/transport/category/list.js
        js/util/array-move.js
        c/address/select.js
        c/address/address.js
        c/address/type.js
        c/phone-input/phone-input.js
        c/tel/tel-list.js
        c/transport/status.js
        c/transport/form.js
        ),
        #lib/angular-ui-select/dist/select.js переместил в c/address/
      ],
      
      ['profile/form.html'=>qw(
      c/profile/form.html
      c/profile/oauth.html
      )],
      ['profile/form.js' => grep !/^#/, qw(
        #~lib/angular-md5/angular-md5.js
        lib/jquery-md5/jquery.md5.js
        c/phone-input/phone-input.js
        c/profile/lib.js
        c/profile/form.js
        ),
      ],
      
      ['profile/form-auth.html'=>qw(
      c/profile/form-auth.html
      c/profile/form-oauth.html
      )],
      ['profile/form-auth.js' => 
        #~ "lib/angular-md5/angular-md5.js",
        qw(
        lib/jquery-md5/jquery.md5.js
        c/phone-input/phone-input.js
        c/profile/lib.js
        c/profile/form-auth.js
        
        ),
      ],
      
      [ 'main.css'=> grep !/^#/, qw(
        #https://fonts.googleapis.com/icon?family=Material+Icons
        fonts/material-icons/material-icons.css
        #https://fonts.googleapis.com/css?family=Roboto:400,700
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
      
      ['top-search.json'=>qw(c/transport/category/search.json)],
      ['transport/category/tree.json'=>qw(c/transport/category/tree.json)],

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

c/template-cache/script.js
###шаблоны_прогреса_свои_
js/user.js
js/debug.js
js/routes.js
js/app.js

android/app.js

#android/lib/angular-cookies-mirror/angular-cookies-mirror.min.js

#profile/form-auth.js
lib/jquery-md5/jquery.md5.js
c/phone-input/phone-input.js
c/profile/lib.js
c/profile/form-auth.js
c/profile/form.js

#поиск/заявка
c/transport/category/list.js
c/address/select.js
c/address/address.js
c/address/type.js
datetime.picker.js
#
#библиотека-по-поиску
c/transport/search.js
c/states/data.js
c/states/list.js
c/states/tel-results.js
c/states/icon.js
c/tel/tel-show-list.js
c/transport/item-detail.js
c/transport/search/results.js
c/transport/search/show-tel.js
c/ask/form.js

#заявки/список
rating-stars.js
c/ask/list.js

#трансп/форм
lib/ng-file-upload/ng-file-upload-all.min.js
c/img-upload-list/img-upload-list.js
c/tel/tel-list.js
c/transport/status.js
js/util/array-move.js
c/transport/form.js

#трансп/список
c/transport/status.js
c/transport/list.js

#спрос/список
c/ask/item.js
c/ask/me-list.js
c/ask/show-tel.js

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


c/profile/form-auth.html
c/profile/form-oauth.html
c/profile/form.html
c/profile/oauth.html

#поиск/заявка
c/transport/category/list.html
c/address/address.html
c/address/address2.html
address/ui-select.html
c/address/type.html
c/ask/form.html
c/states/list.html
c/tel/tel-show-list.html
c/transport/item-detail.html
c/transport/search/results.html
c/transport/search/show-tel.html
c/rating-stars/directive.html

#заявки/список
c/ask/list.html

#трансп/форма
c/tel/tel-list.html
c/img-upload-list/img-upload-list.html
c/transport/status.html
c/transport/form.html

#трансп/список
c/transport/list.html
c/transport/status.html

#спрос/список
c/ask/me-list.html
c/ask/item.html
c/ask/show-tel.html
c/states/tel-results.html
c/states/icon.html

)],
    ],
  },
];