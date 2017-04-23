(function () {'use strict'; try {

angular.module('main')

.controller('navControll', function ($scope, Debug) {//InitApp
  Debug.log('navControll started ');
  //~ InitApp.initNavigator($scope); // загрузить два шаблона из кэша
  $scope.Init = function() {//ng-init
    //~ InitApp.checkVersion($scope);
  //~ Debug.log('Init navControll');
  };
  
})
//=========================================================
.controller('loaderControll', function($scope, appRoutes, InitApp, Util, Debug) {// $localStorage, $sce - из angular-sanitize.js!
  var ctrl = this;
  Debug.log('loaderControll starting...');
  /*---------------------------------------------------------------*/
  appNavigator.pagesFilter = function(key, val){
    var p = appNavigator.pages.filter(function(page){
      return page.data && page.data[key] && (val === undefined || page.data[key] == val);
    }).shift();
    return p;
  };
  
  
  appNavigator.popToPage = function(page) {
    var steps = appNavigator.pages.length - appNavigator.pages.indexOf(page);
    var popPage = function(){if(steps--) appNavigator.popPage().then(popPage);};
    popPage();
    //~ appNavigator.popPage().then();
    //~ while (steps--) appNavigator.popPage();
  };
  
  appNavigator.firstPage = function(tpl, cb){
    appNavigator.pages.length = 1;// resetToPage('')
    return appNavigator.resetToPage('layout/menu.html')
      .then(function(){
        appMenu.content.load(tpl)// не катит {"data":}
          .then(function(){
            if (cb) cb();
          });
      });
  };
  /*-------------------------------------------------------------------*/
  $scope.Include = function () {//ng-include
    return appRoutes.url_for('страницы приложения', [Util.platform(), 'loader.html']);//start
    //~ return Util.pageUrlOrCache('loader') || 'loader';
  };
  
  $scope.Init = function() {//ng-init
    //~ InitApp.checkVersion($scope);
    InitApp.getProfile($scope, {"app":1, "count": 1}).then(function() {
      InitApp.loadTemplates().then(function() {$scope.appReady = true;});
    });
    
    Debug.log('Async InitApp done');
  };
  
  $scope.isReady = function () {
    //~ var ready = $scope.cacheReady && $scope.templatesReady && ons['приложение'].profile; // appNavigator.count уст в InitApp.checkLogin(appNavigator)
    Debug.log("Все готово? "+$scope.appReady);
    if ($scope.appReady && ctrl.Ready) ctrl.Ready();
    return $scope.appReady;
  };
  
  ctrl.Ready = function() {
    Debug.log("ГОТОВО");
    //~ delete ctrl.Ready;
    delete $scope.isReady;
    $('div[ng-controller="loaderControll"]').remove();

    //~ if($scope.uid) {
      //~ appNavigator.resetToPage(appRoutes.url_for('шаблоны приложения', [Util.platform(), 'layout-menu']));//home
    //~ appNavigator.resetToPage(Util.pageUrlOrCache('layout-menu') || 'layout-menu');
    appNavigator.resetToPage('layout/menu.html', {data:{foo:"bar"}});
    //~ } else {
      //~ appNavigator.resetToPage(appRoutes.url_for('шаблоны приложения', [Util.platform(), 'login']));
    //~ }
  };
})
//=========================================================
.controller('loginControll', function($scope, $timeout, InitApp, User, Debug) {//  $localStorage, $timeout, $compile,$sessionStorage, 
  var ctrl = this;
  
  $scope.toolbarTitle = ['Вход'];

  Debug.log('loginControll starting...');
  //~ $timeout(function() {// https://onsen.io/blog/lets-make-an-angularjs-custom-directive/
    //~ var DOM = $('form-auth').get(0);
    //~ var $e =$compile(DOM)($scope);
    //~ angular.element($('form-auth')).replaceWith($e);
    
  //~ });
  
  ctrl.Init= function() {
    if (User.profile('id')) {appMenu.content.load('page/home.html');}//Util.pageUrlOrCache('home') || 
    else {  $timeout(function(){
      $scope.param = {"mobile": true};
      ctrl.ready = true;
      
      
    });  }
  };
  
  ctrl.LoginSuccess = function (resp_data) {
    //~ $sessionStorage.uid = resp_data.uid;// счетчики?
    //~ if (resp_data.uid) {
      InitApp.getProfile($scope, {"app":1, "count": 1})
      .then( function () {
        var pages = appNavigator.pages.length;
        //~ Debug.log('LoginSuccess uid=', resp_data.uid, " страниц в стеке:", pages);
        //~ appNavigator.resetToPage(appRoutes.url_for('шаблоны приложения', [Util.platform(), 'home']));
        if (pages == 1) appMenu.content.load('page/home.html');// зашел с главной
        appNavigator.popPage();
      });
    //~ }
  };
  
})

//=========================================================
.controller('homeControll', function($scope, Debug) {
  Debug.log('homeControll starting...');
  var ctrl = this;
  $scope.toolbarTitle = ['Лови Газель'];
  
  
  ctrl.Init = function () {
    ctrl.ready=true;
    
  };

})
//=========================================================
.controller('mSearchControll', function($scope, $timeout, SearchTransportLib, Debug) {//AskFormData, $compile
  Debug.log('mSearchControll starting...');// +angular.element($('ons-page'))  [ng-controller="mSearchControll as ctrl"]
  var ctrl = this;
  ctrl.$scope = $scope;
  
  var lib = new SearchTransportLib(ctrl, $scope);
  
  ctrl.Init = function () {
    $timeout(function() {
      ctrl.ask = appNavigator.topPage.data && appNavigator.topPage.data.ask;
      //~ Debug.log("заявка в поиске", ctrl.ask);
      $scope.toolbarTitle = ctrl.ask ? ['Моя заявка'] : ['Поиск транспорта'];
      //~ $scope.toolbarCenter = {'Добавить': function(){}};
      ctrl.param = {"id":0, "selectedCategory":0, "searchResults": undefined};
      if (ctrl.ask) ctrl.param.id = ctrl.ask.id;
      ctrl.ready = true;
    });
  };
  
  ctrl.SetSearchResults = function (res) {// callback для <ask-form>
    lib.SetSearchResults(res);
  };
  
  ctrl.Search = function (ask) {// компонент ask-form передает данные заявки // callback для <ask-form>
    ctrl.ask = ctrl.ask || ask;
    //~ console.log("Поиск "+ angular.toJson(ask));
    lib.Search(ask);
    //~ catch (err) { console.log(err.trace); }
  };
  
  ctrl.ShowItem = function (item) {// callback для <transport-search-results> ПЛЮС исп для  <ask-form>!!
    lib.ShowItem(item);
    Debug.log("mSearchControll", item);
    $timeout(function() {appNavigator.pushPage('page/transport/item-detail.html', {"data":{"item": item, "ask":ctrl.ask}});});
  };
  
  ctrl.ShowTransport = function (transport) {// callback для <ask-form>
    ctrl.ShowItem(transport);
    
  };
  
  ctrl.Login = function () {
    //~ appMenu.content.load('page/login.html');
    appNavigator.pushPage('page/login.html');
  };
  
  ctrl.ShowSearchResults = function(){
    //~ Debug.log("mSearchControll.ShowSearchResults"+angular.toJson(res));
    //~ if ( res === 0 ) ctrl.searchResults = undefined;
    //~ else if (res !== undefined) {ctrl.searchResults = res;}
    //~ if ( !ctrl.searchResults || !ctrl.searchResults.length ) return;
    if ( !$scope.searchResults || !$scope.searchResults.length ) return;
    
    appNavigator.pushPage('page/transport/search/results.html', {"data": {"results":$scope.searchResults, "ask":ctrl.ask, "mSearchControll":ctrl}});
    
  };
  
  ctrl.onSaveAsk = function(resp_data) {//сохранил заявку
    Debug.log("mSearchControll.onSaveAsk", resp_data);
    //~ var page = appNavigator.topPage
    //~ var status = resp_data.status;
    //~ var param = page.data && page.data.ctrl && page.data.ctrl.$scope && page.data.ctrl.$scope.param;// это параметр в списке моих заявок
    //~ if (status && param) param.resetTab = status;
    
    $timeout(function(){
      appNavigator.firstPage('page/ask/list.html').then(function(){
        appNavigator.topPage.data = {"status": resp_data.status};
      });
    });
      
  };
  
  ctrl.SetState = function(states_list){
    var status = states_list[states_list.length-1]['код состояния'];
    //~ $timeout(function(){
      appNavigator.firstPage('page/ask/list.html').then(function(){
        appNavigator.topPage.data = {"status": status};
      });
    //~ });
  };
  
})
//=========================================================

.controller('searchResultsControll', function($scope, $http, $q, $timeout, SearchTransportLib, appRoutes, Debug) {//, Util, 
  var ctrl = this;
  Debug.log('searchResultsControll starting...');
  $scope.toolbarTitle = ['Поиск','Результаты'];
  var lib = new SearchTransportLib(ctrl, $scope);
  
  ctrl.Init = function() {
    $timeout(function() {
      $scope.searchResults = appNavigator.topPage.data.results;
      $scope.ask = appNavigator.topPage.data.ask;
      ctrl.ready = true;
    });
  };
  
  ctrl.ShowItem = function (item) {// callback для <transport-search-results> ПЛЮС исп для  <ask-form>!!
    //~ Debug.log("searchResultsControll.ShowItem: "+angular.toJson(item));
    lib.ShowItem(item);
    $timeout(function() {appNavigator.pushPage('page/transport/item-detail.html', {"data":{"item": item, "ask": $scope.ask}});});
    
    

  };
  
  ctrl.ClearResults = function() {
    //~ lib.ClearSearchResults();
    var parent = appNavigator.topPage.data.mSearchControll;
    parent.SetSearchResults(0);
    parent.param.scrollToSave = true;
    appNavigator.popPage();
  };
  
})

//=========================================================

.controller('transportItemDetailControll', function($scope, $http, $q, $timeout, appRoutes, Debug) {//, Util, 
  var ctrl = this;
  Debug.log('transportItemDetailControll starting...');
  $scope.toolbarTitle = ['Поиск','Транспорт/Услуга'];
  
  ctrl.Init = function() {
    $timeout(function() {
      $scope.data = appNavigator.topPage.data.item;
      $scope.ask = appNavigator.topPage.data.ask;
      $scope.param = {"mobile": true,};
      ctrl.ready = true;
    });
  };
  
  ctrl.ShowTel = function(idx){
    //~ Debug.log("transportItemDetailControll.ShowTel: "+idx);
    $scope.data.showTel = {"tel_idx":idx+1, "id": $scope.data.id};
    appNavigator.pushPage('page/transport/show-tel.html', {"data": {"transport":$scope.data, "ask": $scope.ask}});
  };
  
  ctrl.Login = function() {
    appNavigator.pushPage('page/login.html');
  };
  
  
})

//=========================================================

.controller('TransportShowTelControll', function($scope, $http, $q, $timeout, appRoutes, Debug) {//, Util, 
  var ctrl = this;
  Debug.log('transportItemDetailControll starting...');
  $scope.toolbarTitle = ['Транспорт', 'Телефон'];
  
  ctrl.Init = function() {
    $timeout(function() {
      $scope.transport = appNavigator.topPage.data.transport;
      $scope.ask = appNavigator.topPage.data.ask;
      //~ console.log("transportItemDetailControll ask "+angular.toJson($scope.ask));
      $scope.param = {"mobile": true,};
      ctrl.ready = true;
    });
  };
  
  /*
  ctrl.AskData = function() {// вернуть заявку
    //~ var ask = appNavigator.pages[appNavigator.pages.length - 1 - 2].data.ask;// отмотать шаги для заявки
    var ask = appNavigator.pagesFilter("mSearchControll").data.ask;// отмотать шаги для заявки
    //~ Debug.log("TransportShowTelControll Заявка: ", ask);
    return ask;
  };*/
  
  ctrl.ShowTelClose = function (resp_data){
    if (!resp_data || !resp_data.location) return appNavigator.popPage();
    //~ appNavigator.resetToPage('page/ask/list.html');// принятая заявка
    /*
    var p = appNavigator.pagesFilter("AskListControll");
     if (p) {// если добавлял заявку из списка
      //~ if (!p.data) p.data = {};
      //~ p.data.status = 60;
      appNavigator.popToPage(p);
      return;
      //~ appNavigator.popPage().then(function(){appNavigator.popPage()});
    }*/
    /*если принята заявка просто из поиска*/
    //~ $timeout(function(){
      appNavigator.pages.length = 1;// resetToPage('')
      
      appNavigator.resetToPage('layout/menu.html').then(function(){
        appMenu.content.load('page/ask/list.html')
          .then(function(){
            //~ if (!appNavigator.topPage.data) appNavigator.topPage.data = {};
            //~ appNavigator.topPage.data.status = 60;
            //~ console.log("Список заявок страница"+appNavigator.topPage);
          });
      });
    //~ });
  };
  
  ctrl.Login = function() {
    appNavigator.pushPage('page/login.html');
  };
  
})

//=========================================================

.controller('AskListControll', function($scope, $timeout, Debug, AskListLib) {//appRoutes, Util, 
  var ctrl = this;
  Debug.log("AskListControll starting...");
  var lib = new AskListLib(ctrl, $scope);
  ctrl.$scope = $scope;
  
  ctrl.Init = function() {
    $timeout(function () {
      var status = appNavigator.topPage.data && appNavigator.topPage.data.status;
      $scope.toolbarTitle = ['Мои заявки'];
      $scope.param = {"status": status || 60};
      ctrl.ready = true;
    });
  };
  
  ctrl.OpenAsk = function(ask) {
    appNavigator.pushPage('page/transport/search.html', {"data": {"ask":ask, "AskListControll": ctrl}});
  };
  
  ctrl.NewAsk = function() {
    appNavigator.pushPage('page/transport/search.html', {"data": {"AskListControll": ctrl}});
    //~ appMenu.content.load('page/transport/search.html');
  };
  
  ctrl.ShowTransport = function (ask) {// оказать транспорт, но на входе заявка
    var transport = lib.ShowTransport(ask);
    $timeout(function() { appNavigator.pushPage('page/transport/item-detail.html', {"data":{"item": transport}}); });
  };
  
})
//=========================================================

.controller('AskMeListControll', function($scope, $timeout, Debug, User) {//appRoutes, Util, 
  var ctrl = this;
  ctrl.$scope = $scope;
  Debug.log("AskMeListControll starting...");
  
  //~ console.log("AskMeListControll data"+angular.toJson(appMenu));
  
  ctrl.Init = function() {
    $timeout(function() {
      var status = appNavigator.topPage.data && appNavigator.topPage.data.status;
      $scope.toolbarTitle = ['Заявки на мой транспорт'];
      $scope.param = {"status": User.count('new_ask') ? 10 : status || 60};
      ctrl.ready = true;
    });
  };
  
  ctrl.OpenAsk = function(ask) {
    appNavigator.pushPage('page/ask/item.html', {"data": {"ask":ask, "AskMeListControll":ctrl}});
  };
  
})

//=========================================================

.controller('AskItemControll', function($scope, $timeout, Debug) {//appRoutes, Util, 
  var ctrl = this;
  //~ var lib = new AskMeListLib(ctrl, $scope);
  Debug.log("AskItemControll starting...");
  
  ctrl.Init = function() {
    $timeout(function() {
      $scope.toolbarTitle = ['Заявка на мой транспорт'];
      $scope.param = {"mobile": true};
      $scope.ask = appNavigator.topPage.data.ask;
      ctrl.ready = true;
    });
  };
  
  ctrl.ShowTel = function(ask) {
    //~ lib.GetShowTel(ask, function (resp_data) {
      appNavigator.pushPage('page/ask/show-tel.html', {"data": {"ask":ask, "AskItemControll": ctrl}});
    //~ });
    
  };
  
  ctrl.SetStates = function(list_states){// из сп-ка состояний заявки
    // нужно в me-list переинициировать табы
    //~ var list_page = appNavigator.pages[appNavigator.pages.length - 2];
    //~ console.log("Reset ask States"+Object.keys(list_page));// angular.toJson(list_states)
    var status = list_states[list_states.length-1]['код состояния'];
    //~ var p = appNavigator.pages.filter(function(page){ return page.data && page.data.AskMeListControll; }).shift();
    var p = appNavigator.pagesFilter("AskMeListControll");
    if (p) p.data.AskMeListControll.$scope.param.resetTab = status;
    appNavigator.popPage();
  };
  
})
//=========================================================

.controller('AskShowTelControll', function($scope, $timeout, Debug) {//appRoutes, Util, 
  var ctrl = this;
  //~ var lib = new AskMeListLib(ctrl, $scope);
  Debug.log("AskShowTelControll starting...");
  
  ctrl.Init = function() {
    $timeout(function() {
      $scope.toolbarTitle = ['Заявка', 'Телефон'];
      $scope.param = {"mobile": true};
      $scope.ask = appNavigator.topPage.data.ask;
      ctrl.ready = true;
    });
  };
  
  ctrl.ShowTelResult = function(resp_data, ask) {
    ask = ask || $scope.ask;
    //~ if(!resp_data.location) return appNavigator.popPage();// вернуться в позицию
    //~ lib.ShowTelResult(result, ask, ctrl.ShowTelResultClose);
    // по последнему состоянию
    //~ console.log("ShowTelResult" +angular.toJson(ask));
    var status = ask['состояния'] && ask['состояния'][ask['состояния'].length-1]['код состояния'];
    if ([30,40,60].filter(function(val){ return val == status; }).length) {
      //~ var p = appNavigator.pages.filter(function(page){ return page.data && page.data.AskMeListControll; }).shift();
      ask.tel = ask.showTel.tel;
      delete ask.showTel;
      var p = appNavigator.pagesFilter("AskMeListControll");
      if (p) {
        p.data.AskMeListControll.$scope.param.resetTab = status;
        appNavigator.popToPage(p);
        //~ appNavigator.popPage().then(function(){appNavigator.popPage()});
      }
      
    }
    else {appNavigator.popPage();}
  };
  
  ctrl.ShowTelClose = function() {
    appNavigator.popPage();// вернуться в позицию
    
  };
  
})
//=========================================================

.controller('TransportFormControll', function($scope, $timeout, Debug) {//appRoutes, Util, 
  var ctrl = this;
  Debug.log("TransportFormControll starting...");
  
  ctrl.Init = function() {
    $timeout(function() {
      $scope.toolbarTitle = ['Форма транспорта'];
      $scope.param = {"id": 0};// cnt не нужен в transport-form  "cnt": User.count('transport') || 0
      var data = appNavigator.topPage.data;
      if (data && data.item) $scope.param.id = data.item.id;
      Debug.log("Параметры формы транспорта", $scope.param);
      ctrl.ready = true;
    });
  };
  
  ctrl.Save = function (resp_data) {
    //~ Debug.log("Сохранен транспорт: ", resp_data);
    $timeout(function(){
      appNavigator.pages.length = 1;// resetToPage('')
      appNavigator.resetToPage('layout/menu.html').then(function(){
        appMenu.content.load('page/transport/list.html');
      });
    });
    
  };
  
})

//=========================================================

.controller('TransportListControll', function($scope, Debug) {//appRoutes, Util,, User
  var ctrl = this;
  Debug.log("TransportListControll starting...");
  
  ctrl.Init = function() {
    $scope.toolbarTitle = ['Мой транспорт и услуги'];
    $scope.param = {};// cnt не нужен в transport-form
    ctrl.ready = true;
  };
  
  ctrl.OpenTransport = function(it){
    //~ Debug.log("Транспорт из списка ", it);
    appNavigator.pushPage('page/transport/form.html', {"data": {"item": it}});
    
  };
  
  ctrl.NewTransport = function(){
    appNavigator.pushPage('page/transport/form.html');
    
  };
  
})

//=========================================================

.controller('menuController', function($scope, $timeout) {//  InitApp, User, Debug, Util
  var ctrl = this;
  
  ctrl.$onInit = function(){
    ctrl.ready=true;
  };
  
  ctrl.Init000 = function(splitter){
    //~ $scope.param={};//"splitter": appMenu  appMenu is not defined
    //~ console.log(splitter);
    $timeout(function(){
      $scope.param={"splitter": splitter};//"splitter": appMenu  appMenu is not defined
      
    });
  };
})
//=========================================================
.controller('ProfileControll', function($scope, $http, $timeout, Util, User) {
  var ctrl = this;
  
  ctrl.Init = function(){
    //~ ProfileData.oauth().then(function(resp) {
      //~ $scope.oauth = resp.data;
    $timeout( function() {
      $scope.toolbarTitle = ['Профиль'];
      $scope.profile = User.profile();
      $scope.param = {"mobile": true};
      ctrl.ready = true;
    });
    //~ });
  };
  
  
  
  
})


/*=========================================================*/
.component('appToolbar', {
  templateUrl: "layout/toolbar.html",
  bindings: {
    title: '<',
    center: '<'
  },
  controller: function($scope, $timeout, $localStorage, Util, appRoutes, User) {//$sessionStorage, 
    var $ctrl = this;
    
    $ctrl.$onInit = function() {
      $timeout(function() {
        //~ $ctrl.title = $ctrl.title || $scope.toolbarTitle || [];
        $ctrl.title = $ctrl.title || [];
        $ctrl.navPages = appNavigator.pages.length;
        if ($ctrl.navPages > 1) $ctrl.title.unshift($localStorage.CONFIG.appName);
        //~ console.log("appToolbar title: "+angular.toJson($ctrl.title));
        //~ console.log("appToolbar center: "+angular.toJson($ctrl.center));
        $ctrl.ready = true;
      });
    };
    
    $ctrl.toggleMenu = function() {
      appMenu.right.toggle();
    };
    
    $ctrl.Home = function(idx){//
      if (idx > 0) return;
      appMenu.content.load('page/home.html');//Util.pageUrlOrCache('home') || 
    };
    
    $ctrl.Login = function(flag) {// не исп
      if(flag) return User.profile('id') || appMenu.content.page == 'page/login.html';// не нужен для залогина
      appMenu.content.load('page/login.html');
    };
    
    $ctrl.Back = function (){
      appNavigator.popPage();
    };
    
    $ctrl.srcLogo = function () {
      return appRoutes.url_for('картинка лого');
    };
  }
})

/*=========================================================*/
.component('menuNav', {
  templateUrl: "layout/nav.html",
  bindings: {
    param:'<',
  },
  controller: function($scope, $element, $timeout, InitApp, User, Debug, Util) {//$sessionStorage, 
    var $ctrl = this;
    $scope.User = User;
    
    $ctrl.$onInit000 = function() {
      $timeout(function() {
        //~ console.log("menuNav"+$($element[0]).closest('ons-splitter').get(0).ng339);
        //~ console.log("menuNav"+);
        //~ if(!$ctrl.param) $ctrl.param = {};
        //~ if(!$ctrl.param.splitter) $ctrl.param.splitter = appMenu;
        console.log(appMenu);
        
      });
    };
    
    $ctrl.Init = function(splitter) {
      $timeout(function() {
        console.log("menuNav"+splitter);
        $ctrl.ready = true;
      });
    };
      
  
  //~ console.log("menuController "+appNavigator.pages[0]);
  
    $ctrl.loadContent = function(page) {
      //~ Debug.log("Загрузка из меню ", page);
      //~ appMenu.content.load(page).then(function() {appMenu.right.close();});
      appMenu.right.close();
      appNavigator.pushPage(page).then(function() {});
    };
    
    $ctrl.Logout = function () {
      InitApp.logout()
        .then(function() {
          appMenu.content.load('page/home.html').then(function() {
            appMenu.right.close();
          });//Util.pageUrlOrCache('home') || 
        });
    };
    
    $ctrl.Login = function() {//
        //~ if(flag) return User.profile('id') || appMenu.content.page == 'page/login.html';// не нужен для залогина
        appMenu.content.load('page/login.html').then(function() {
            appMenu.right.close();
          });
      };
    
    $ctrl.clearCache = function () {
      Util.clearCache();
    };
    
    $ctrl.CloseApp = function () {
      //~ Debug.log("CloseApp: ", navigator.app);
      navigator.app.exitApp();
      
    };
    
    
  }
})
/*
.directive('appToolbar0000', function() {//компонент не пошел лишний тэг обрубает стили тулбара онсена (и внутри и снаружи шаблона) в родительском контроллере ставить $scope.toolbarTitle = [...] без корневого названия
  return {
    templateUrl: 'layout/toolbar.html',
    controllerAs: '$ctrl',// в шаблоне
    //~ bindToController: {
      //~ title: '<',
      //~ center: '<'
    //~ },
    //~ restrict: 'E',
    //~ scope: {},
    controller: function($scope, $timeout, $localStorage, Util, appRoutes, User) {//$sessionStorage, 
      var $ctrl = this;
      
      $ctrl.Init = function() {
        $timeout(function() {
          //~ $ctrl.title = $ctrl.title || $scope.toolbarTitle || [];
          $ctrl.title = $ctrl.title || [];
          $ctrl.navPages = appNavigator.pages.length;
          if ($ctrl.navPages > 1) $ctrl.title.unshift($localStorage.CONFIG.appName);
          console.log("appToolbar title: "+angular.toJson($ctrl.title));
          console.log("appToolbar center: "+angular.toJson($ctrl.center));
          $ctrl.ready = true;
        });
      };
      
      $ctrl.toggleMenu = function() {
        appMenu.right.toggle();
      };
      
      $ctrl.Home = function(idx){//
        if (idx > 0) return;
        appMenu.content.load('page/home.html');//Util.pageUrlOrCache('home') || 
      };
      
      $ctrl.Login = function(flag) {//
        if(flag) return User.profile('id') || appMenu.content.page == 'page/login.html';// не нужен для залогина
        appMenu.content.load('page/login.html');
      };
      
      $ctrl.Back = function (){
        appNavigator.popPage();
      };
      
      $ctrl.srcLogo = function () {
        return appRoutes.url_for('картинка лого');
      };
    }
  };
})
*/
//===============================================================

//==============================================================
;
} catch(err){console.log("Ошибка в контроллерах приложения"+err.stack);}
}());
