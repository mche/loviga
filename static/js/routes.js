(function () {'use strict'; try {
/*
*/

var moduleName = "appRoutes";

try {
  if (angular.module(moduleName)) return;
} catch(err) { /* ok */ }


var module = angular.module(moduleName, []);

var routes = {
  //~ 'foo bar': 'foo=:foo/bar=:bar',
  'assets': '/assets/*topic',// не трогай
  'категории транспорта': '/assets/transport/category/tree.json', // без счета
  //~ 'конфиг приложения': "/:platform/app-config.json",
  'старт приложения': "/app/start/:platform",
  'шаблоны приложения': "/assets/:platform/templates.html",
  'страницы приложения': "/:platform/templates/:page",
  'отладка приложения': "/remote/log",
  'картинка капчи': "/captcha/:digest.png",
  'картинка лого': "/i/logo/lovigazel.png",
  'картинка категории':'/i/t/c/:img',
  'картинка транспорта':'/i/t/u/:uid/:img',
  'site logo': "/i/logo/:name.png",
  'внешние профили': "/oauth/data",// из плугина RoutesAuthDBI
  'oauth-login': "/oauth/login/:site",
  'oauth profile': "/oauth/profile/:site",
  'oauth-detach': "/oauth/detach/:site",
  'релогин': "/reauth/cookie", // из плугина RoutesAuthDBI для мобил
  'yandex profile avatar': "https://avatars.mds.yandex.net/get-yapic/:default_avatar_id/islands-50",
  'logout':"/logout",
  
  "поиск транспорта":   "/search",
   "обычная авторизация/регистрация":   "/profile/sign",
   "профиль сохранить": "/profile",
  "данные профиля": "/profile/data",
   "мой транспорт":   "/transport",
   "список транспорта":    "/transport/list",
   "статус транспорта":   "/transport/status/:id",
  "отключение транспорта": "/transport/disabled/:id",
   "данные категорий транспорта": "/transport/category/data",
   "форма транспорта": "/transport/form/:id",
   "форма нового транспорта": '/transport/form',
   "данные формы транспорта":   "/transport/form/data/:id",
   "сохранить транспорт":   "/transport/form/save",
   "сохранить картинку транспорта": "/transport/form/img",
   "найти транспорт":  "/transport/search",
   "количество адресных типов":  "/transport/search/addr_type",
   "телефон транспорта":   "/transport/show/tel",
   "показ транспорта":   "/transport/show/:id",
   "показ транспорта для заявки":  "/transport/show/:id/:ask",
   "позиция транспорта":   "/transport/:id",
   "поиск адреса":  "/address/search",
   "поиск адреса/город":  "/address/search_1",
   "поиск адреса/улица":  "/address/search_2",
   //"типы адресов":    "/address/types",
   "сохранить заявку":    "/ask/store",
   "сохранить состояние заявки":  "/ask/store/state",
   "мои заявки":    "/ask",
   "список моих заявок":    "/ask/list",
   "форма заявки":   "/ask/form/:id",
   "данные формы заявки":   "/ask/form/data/:id",
   "заявки на мой транспорт":    "/ask/me",
   "телефон заявки":  '/ask/show/tel',
   "список заявок на мой транспорт":    "/ask/me/data",
   "позиция заявки":   "/ask/:id",
   // приложения
   //~ "счетчики": '/count',
   "app logout": '/logout/:platform'
  
},
  arr_re = new RegExp('[:*]\\w+', 'g'),
  _baseURL = '';

var baseURL = function  (base) {// set/get base URL prefix
  if (base === undefined) return _baseURL;
  _baseURL = base;
  return base;
  
};

var url_for = function (route_name, captures, param) {
  var pattern = routes[route_name];
  if(!pattern) {
    //~ console.log("[angular.appRoutes] Has none route for the name: "+route_name);
    //~ return baseURL()+route_name;
    return undefined;
  }

  if ( captures === undefined ) captures = [];
  if ( !angular.isObject(captures) ) captures = [captures];
  if ( angular.isArray(captures) ) {
    var replacer = function () {
      var c =  captures.shift();
      if(c === undefined) c='';
      return c;
    }; 
    pattern = pattern.replace(arr_re, replacer);
  } else {
    angular.forEach(captures, function(value, placeholder) {
      var re = new RegExp('[:*]' + placeholder, 'g');
      pattern = pattern.replace(re, value);
    });
    pattern = pattern.replace(/[:*][^/.]+/g, ''); // Clean not replaces placeholders
  }
  
  if ( param === undefined ) return baseURL()+pattern;
  if ( !angular.isObject(param) ) return baseURL()+pattern + '?' + param;
  var query = [];
  angular.forEach(param, function(value, name) {
    if ( angular.isArray(value) ) { angular.forEach(value, function(val) {query.push(name+'='+val);}); }
    else { query.push(name+'='+value); }
  });
  if (!query.length) return baseURL()+pattern;
  return baseURL()+pattern + '?' + query.join('&');
};


var factory = {
  routes: routes,
  baseURL: baseURL,// set/get
  url_for: url_for
};

module

.run(function ($window) {
  $window['angular.'+moduleName] = factory;
})

.factory(moduleName, function () {
  return factory;
})

;

} catch(err) {console.log("Ошибка компиляции маршрутов"+err.stack);}
}());