//~ (function () {
//~ 'use strict';

//~ ons['приложение']={};

ons.bootstrap('main', ['onsen', 'ngSanitize', 'ngCordova', 'ngCordovaOauth', 'ngStorage', 'loadTemplateCache', 'AppTplCache', 'appRoutes', 'User', 'Debug',
/* профиль и вход */
'phone.input', 'formAuth', 'formProfile', 
/* поиск/заявка */
'transport.category.list', 'address.select', 'AddressType', 'States', 'tel-show-list', 'SearchTransport', 'AskForm', 'TransportSearchResults', 'TransportItemDetail',
/* заявки/список */ 'AskList',
/* трансп/форм */ 'tel.list', 'img.upload.list', 'TransportStatus', 'TransportForm',
/* трансп/список */ 'TransportList',
/*  спрос/список */ 'AskItem', 'AskMeList'
])//
//~ .constant('CONFIG', {dataURL:'https://lovigazel.ru/assets/app-config.json'})
.config(function($sceDelegateProvider, $qProvider) {//$cookiesMirrorProvider 
    $sceDelegateProvider.resourceUrlWhitelist([
        'self',
        'https://lovigazel.ru/**'
    ]);
    //~ $qProvider.errorOnUnhandledRejections(false);
    //~ $cookiesMirrorProvider.track('ELK');
    
})
.run(function(appRoutes, loadTemplateCache, Debug) {
    appRoutes.baseURL('https://lovigazel.ru');
    Debug.param('enable', true);
    //~ loadTemplateCache.config('debug', true);
});

$(document).ready (function (){ 
    //~ ons.notification.alert('Document ready!');
    //~ console.log('Document ready!');
    
});

document.addEventListener('deviceready', function (){
    //~ console.log('Device ready!');
    
    //Android only:
     //~ var ref = cordova.InAppBrowser.open('http://materializecss.com', '_self', 'location=no,hardwareback=no');
    
});

//~ }());