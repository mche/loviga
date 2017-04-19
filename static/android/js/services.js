(function () {
'use strict';

angular.module('main')
.service('Util', function($window, $localStorage, Debug ){// $templateCache, 
    
/* Установить плугин
    cordova plugin add https://github.com/moderna/cordova-plugin-cache.git --save
*/
    this.clearCache = function (data) {// data - новые данные
        var success = function(status) {
            var msg = 'Кэш приложения очищен: ' + status;
            Debug.log(msg);
            //~ ons.notification.alert(msg);
            angular.forEach(data, function(value, key) {
              //~ console.log("json config ["+key+"]="+value);
              $localStorage.CONFIG[key] = value;
            });
            //~ ons.notification.alert("Новая версия приложения будет установлена. Запустите заново.", {title: "Новая версия", callback: function () {navigator.app.exitApp();}});
            navigator.app.exitApp();
            
        };
        var error = function(status) {
            var msg = 'Ошибка очистки кэша приложения: ' + status;
            Debug.log(msg);
            ons.notification.confirm(msg);
        };

        $window.cache.clear( success, error );
        
    };
    
    this.platform = function () {
      /*  platform 	string 	Possible values are: “opera”, “firefox”, “safari”, “chrome”, “ie”, “android”, “blackberry”, “ios” or “wp”.    */
      if ( ons.platform.isAndroid() || ons.platform.isAndroidPhone() || ons.platform.isAndroidTablet() ) return 'android';
      if ( ons.platform.isIOS() || ons.platform.isIPad() ) return 'ios';
      return 'other';
      
    };
    
})
/*========================================================================*/
.service('InitApp', function ($http, $localStorage, $sessionStorage, Util, appRoutes, loadTemplateCache, User, Debug) {//
  var $service = this;

  $localStorage.$default({"CONFIG": {"VERSION": 0}});
  
  //~ var process_app_data = function(resp) {
    
  //~ };
  
  this.checkVersion = function (data) {
    //~ Debug.log("Проверка версии...");
    //~ $http.get(appRoutes.url_for('конфиг приложения', Util.platform())+'?_='+(new Date().getTime().toString()), {"cache": false})// работает
    //~ .then( process_app_data );
    Debug.log("Сверка конфига приложения ", data, $localStorage.CONFIG);
    //~ console.log("Сверка конфига приложения "+data);
    
    if (!$localStorage.CONFIG.VERSION) {
      angular.forEach(data, function(value, key) {
        //~ console.log("json config ["+key+"]="+value);
        $localStorage.CONFIG[key] = value;
      });
      //~ scope.cacheReady = true;
      //~ $service.loadTemplates(scope);
      return;
    }
    
    if ( $localStorage.CONFIG.VERSION < data.VERSION ) {
      Debug.log("Сброс кэша версии: текущая: ", $localStorage.CONFIG.VERSION, "новая: ", data.VERSION);
      //~ $window.clearCacheExitApp = 'exit';
      ons.notification.alert("Новая версия приложения будет установлена. Запустите заново.", {"title": "Новая версия " + data.VERSION, buttonLabels: ['Отлично'], "callback": function () {
        Util.clearCache(data);// асинхронно!
        //~ $window.navigator.app.exitApp();
        //~ navigator.app.exitApp();
      }});
      return;
    }
    
    Debug.log("Версия приложения/кэша не изменилась ");
    //~ scope.cacheReady = true;
    //~ $service.loadTemplates(scope);
    
    
  };
  
  this.loadTemplates = function() {
    return loadTemplateCache.split(appRoutes.url_for('шаблоны приложения', Util.platform()), 1);
      //~ .then(function(proms) {scope.templatesReady = true;});
  };
  
  this.getProfile = function (scope, param) {
    Debug.log("Проверка входа, получение профиля+конфига приложения+счетчиков записей...");
    //~ return $http.get(appRoutes.url_for('счетчики')+'?_='+(new Date().getTime().toString()), {"cache": false})// работает
    return $http.get(appRoutes.url_for('старт приложения', Util.platform(), param))
      .then( function(resp) {
        Debug.log("InitApp.getProfile resp ", resp.data);
        User.profile(resp.data.profile);
        if (resp.data.count) User.count(resp.data.count);
        if (resp.data.app) $service.checkVersion(resp.data.app);
        //~ delete resp.data.profile;
        //~ ons['приложение'].count = resp.data;
      });
      
  };
  this.logout = function() {
    return $http.get(appRoutes.url_for('app logout', [Util.platform()])).then(function(resp) {
      User.profile({});
      User.count({});
    },
    function(error) { Debug.log("Ошибка запроса: ", error); }
    );
    
    
  };
    /*
    this.initSplitter = function (scope) {// загрузить два шаблона из кэша
        var spl = document.querySelector('#'+CONFIG.splitter.id);
        var side = spl.left || spl.right; // ons-splitter-side
        //~ console.log('Splitter menu side'+side);//spl['left']._page);//Object.keys(spl.left._page).join(';'));
        //~ side.side = CONFIG.menu.side;
        side.load(scope.$templateCache.get('url:menu'));
        spl.content.load(scope.$templateCache.get('url:main-content'));
    };
    */
    /*
    this.initNavigator = function (scope) {// загрузить шаблон из кэша 
        var nav = document.querySelector('#'+CONFIG.navigator.id);
        nav.pushPage(scope.$templateCache.get('url:main'));
        
    };
    */
    //~ this.initTabbar = function (scope) {/* кэш шаблонов не работает */
        //~ var tb = $('#'+CONFIG.tabbar.id+" ons-tab");
        
        //~ console.log('Ons-tab'+tb.eq(0).html());
        //~ return;
        
        //~ for (name in CONFIG.tabbar.tabs) {
            
            //~ var onstab = $('<ons-tab>').attr('page', CONFIG.urls.root+CONFIG.urls.base+'/templates/'+CONFIG.tabbar.tabs[name]).attr('label', name);
            //~ console.log("New tab: "+onstab);
            //~ tb.append(onstab);
            //~ ons.compile(onstab[0]); //
        //~ }
    //~ };
    //~ this.loadTemplates = function () {
        //~ var tpl = $('<script>').attr('id', 'task-item').attr('ajax-content', CONFIG.urls.root+CONFIG.urls.base+'/templates/'+"task-item.html").addClass('ajaxContent-wrapper').attr('type',"text/ng-template");
        //~ $('body').append(tpl);
        //~ ons.compile(tpl[0]);
    //~ };
})
/*
.directive('ajaxContent', function() {// $http, $sce
  return {
    //~ scope: {}
    link: function(scope, element, attributes) {
    //~ scope.myNgInit()(element);
      console.log('Директива ajaxContent '+Object.keys(attributes).join(';'));
      
      //~ var url = element.attr('loadContentURL');
      var url = attributes.ajaxContent;
      //~ var id = element.attr('id');
      if (url) {
        //~ $http.get(url, {cache: true})
          //~ .then(function (success) {
            //~ var remote = $('<div>'+success.data+'</div>').addClass('load-content-done');//$sce.trustAsHtml(
            //~ console.log(remote);
            //~ element.append(remote);// Insert to the DOM first 
            //~ ons.compile(remote[0]); // The argument must be a HTMLElement object
          //~ },
          //~ function (error) {
            //~ console.log('Fail loading remote content');
            //~ console.log(error);
          //~ }
        //~ );
        jQuery.ajax({
          url: url,
          cache: true,
          dataType: "html",
          crossDomain: true,
          ifModified: true,//(default: false)
          success: function (data, textStatus, jqXHR ) {
            var remote = $('<div>'+data+'</div>').addClass('ajax-content-done');//$sce.trustAsHtml(
            //~ console.log(remote);
            element.append(remote);// Insert to the DOM first 
            ons.compile(remote[0]); // The argument must be a HTMLElement object
          },
          error:function (jqXHR, textStatus, StringerrorThrown ) {
            //~ console.log();
            ons.notification.alert('Ошибка загрузки ресурса: '+jqXHR.status+' '+textStatus+" "+StringerrorThrown);
          },
          
        });
        //~ console.log('Send req: ' + url);
      }
      else {
        console.log('нет атрибута ajaxContent="http..."');
      }
    }
  };
})*/
/*
.directive('clearCacheExitApp', function(CONFIG, $localStorage, Util) {
  return {
    //~ scope: {}
    link: function(scope, element, attributes) {
        Util.clearCache();
        $localStorage.config = CONFIG;
        //~ console.log('Закрыл приложение для перезапуска');
        if (attributes.clearCacheExitApp == 'exit') {
            ons.notification.alert("Переустановлена новая версия приложения. Запустите заново.", {callback: function () {navigator.app.exitApp();}});
            
        }
    }
  };
})
*/
/*
.factory('myTemplates000', function ($templateCache, CONFIG) {
    return function () {//.attr('type',"text/ng-template")
        //~ var t = $('<ons-template>').attr('id', "new_task.html").attr('ng-include', "https://calculate/onsen/templates/new_task.html");
      //~ $('body').append(t);
      //~ ons.compile(t[0]); // The argument must be a HTMLElement object
    };
})
*/
//============================================================
.service('arrayStorage', function () {
    //~ console.log("Service [] started");
    var $this = this;
    this._data = {};
    
    this._init = function (key) {
        if ($this._data[key] === undefined) {
            $this._data[key] = [];
        }
        return $this;
    };
    
    this.get = function (key, idx) {
        $this._init(key);
        if (idx === undefined) {
            return $this._data[key];
        }
        return $this._data[key][idx];
    };
    this.push = function (key, arr) {
        $this._init(key);
        Array.prototype.push.apply($this._data[key], arr);
        return $this._data[key];
    };
    this.unshift = function (key, arr) {
        $this._init(key);
        Array.prototype.unshift.apply($this._data[key], arr);
        return $this._data[key];
    };
    
})
//============================================================
/*
.component('taskList', {
    templateUrl: 'task_list_template',// <script type="text/ng-template" id="task_list_template">
    
    //~ template: function ($element, $attrs, $templateCache) {//
        //~ console.log("taskList component template");
        //~ return $templateCache.get('task_list_template') || '<div>Нет шаблона</div>';
      //~ },
      
    //~ template: '<h2>Список</h2><ons-list>'+
    //~ <task-detail ng-repeat="item in $ctrl.list" task="list" on-delete="$ctrl.delete(hero)" on-update="$ctrl.update(hero, prop, value)"></task-detail>',
    controller: function ($scope, $element, $attrs, arrayStorage, $http, CONFIG, myStorage, $templateCache) {
        console.log("taskList component controller start: "+Object.keys($attrs).join(';'));
        var self = this;
        self.$attrs = $attrs;
        self.tasks = arrayStorage.get('tasks');
        if ($attrs.fetchData) {//этот атрибут только для одного таба
            var url = CONFIG.urls.root+CONFIG.urls.base+'/tasks.json';
    
            $http.get(url).then(function(response) {
                console.log("Закачал задачи: "+response.data);
                self.tasks = arrayStorage.push('tasks', response.data);
              },
              function (error) {
                console.log('Ошибка загрузки задач ['+url+"]: "+error.status+" "+error.statusText);
              }
            );
        }
        
        self.filterStatus = function(item, index, array) {
            //~ console.log("filterStatus value: "+item+"; index: "+index+"status:"+self.$attrs.taskStatus);
            if (self.$attrs.taskStatus == 'completed') {
                return item.completed;
            } else if (self.$attrs.taskStatus == 'pending') {
                return ! item.completed;
            }
            return false;
        };
        
        self.Delete = function (item) {
            var idx = self.tasks.indexOf(item);
            console.log("delete item: "+idx);
            //~ $http.delete(...).then(function() {
                
                if (idx >= 0) {
                  self.tasks.splice(idx, 1);
                }
            //~ });
        };
        self.Edit = function (item) {
          var idx = self.tasks.indexOf(item);
          console.log("edit item: "+idx);
          myStorage.set('current task idx', idx);
          //~ document.querySelector('#'+CONFIG.navigator.id).pushPage('taskFormPage');
          document.querySelector('#'+CONFIG.navigator.id).pushPage($templateCache.get('url:form_task'));
          //~ document.querySelector('#task_form_idx').val(idx);
          //~ document.querySelector('#TaskFormPage').append(form);
          //~ ons.compile(form[0]);
          //~ self.form = form;
        };

    }
  })
//========================================================================
.component('taskForm', { // <task-form></task-form>
    templateUrl: 'task_form_template',// <script type="text/ng-template" id="task_list_template">
    controller: function ($scope, $element, $attrs, arrayStorage, myStorage, CONFIG) {
        console.log("taskForm component controller start: "+Object.keys($attrs).join(';'));
        var self = this;
        self.idx = myStorage.get('current task idx');
        self.$attrs = $attrs;
        self.task = arrayStorage.get('tasks', self.idx);
        if (self.task === undefined) {
          //~ self.tasks[self.idx]
          self.toolbarTitle = "Новая задача";
          self.task = {};
        } else {
          self.toolbarTitle = "Редактирование задачи "+self.idx;
        }
        self.task._idx = self.idx;
        self.Save = function () {
          console.log("Сохранить: "+ Object.keys(self.task).join(';'));
          if (self.task._idx == 'new') {
            arrayStorage.unshift('tasks', [self.task]);
          }
          document.querySelector('#'+CONFIG.navigator.id).popPage();
        };
    }
})
*/
//========================================================================
.factory('myStorage', function() {
  var data = {};
  
  return {
    set: function(name, val) {
      data[name] = val;
    },
    
    get: function (name) {
      return data[name];
      
    }
    
  };
  
})

;

}());