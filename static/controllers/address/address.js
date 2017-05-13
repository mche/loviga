(function () {
'use strict';
/*
Адресный компонент
  
Второй адресный компонент для формы заявки, когда сначала поле города, затем поле улицы
*/

var moduleName='address.select';
var module = angular.module(moduleName, ['ui.select', 'appRoutes']);
  
var Controll = function ($scope, $attrs, AddressLib) {//loadTemplateCache
  var $ctrl = this;
  $ctrl.$attrs = $attrs;
  
  var lib = new AddressLib($ctrl, $scope);
  
  $ctrl.$onInit = function() {
    $ctrl.ready = true;
  };
  
  
  $ctrl.SearchAddress = function(select) {
    lib.SearchAddress(select, 'поиск адреса');
  };
  
  $ctrl.clearAddr = function(select) {
    lib.ClearAddr(select);
  };
  
  $ctrl.removeAddr = function(idx) {
    lib.RemoveAddr(idx);
  };
  
  $ctrl.addrTop = function (idx, check) {// проверка тоже тут
    $ctrl.AddrTop(idx, check);
  };
  
  $ctrl.addrUp = function (idx, check) {// проверка тоже тут
    lib.AddrUp(idx, check);
  };
  
  $ctrl.addrDown = function (idx) {
    lib.AddrDown(idx);
  };
  
  $ctrl.disableAddr = function (idx) {
    lib.DisableAddr(idx);
    
  };
  
  $ctrl.isDisabled = function(select) {
    lib.IsDisabled(select);
  };

};
/*----------------------------------------------------------------------------
Компонент
Раздельно город/улица
------------------------------------------------------------------------------*/
var Controll2 = function ($scope, $attrs, AddressLib) {//loadTemplateCache
  var $ctrl = this;
  $ctrl.$attrs = $attrs;
  
  var lib = new AddressLib($ctrl, $scope);
  
  $ctrl.$onInit = function() {
    $ctrl.ready = true;
  };
  
  
  $ctrl.SearchAddress = function(select, url_for) {
    lib.SearchAddress(select, url_for);
  };
  
  $ctrl.clearAddr = function(select) {
    lib.ClearAddr(select);
  };
  
  $ctrl.removeAddr = function(idx) {
    lib.RemoveAddr(idx);
  };
  
  $ctrl.addrTop = function (idx, check) {// проверка тоже тут
    $ctrl.AddrTop(idx, check);
  };
  
  $ctrl.addrUp = function (idx, check) {// проверка тоже тут
    lib.AddrUp(idx, check);
  };
  
  $ctrl.addrDown = function (idx) {
    lib.AddrDown(idx);
  };
  
  $ctrl.disableAddr = function (idx) {
    lib.DisableAddr(idx);
    
  };
  
  $ctrl.isDisabled = function(select) {
    lib.IsDisabled(select);
  };

};

/*-----------------------------------------------------------------------------------------------
Разделяемая библиотека для двух компонентов
--------------------------------------------------------------------------------------------------*/
var Lib = function($http, $q, $timeout, appRoutes ) {
//~ console.log("SearchTransportLib starting...");
var regExp = {
  tokens: /"[^"]+"|[^"]+/g,
  quote: /\s*"\s*/g,
  space: /\s+/g,
  space_bound: /^\s+|\s+$/g,
  //~ latin: /[a-z]/i,
  clean: /[^\s\dа-я-"]+/gi
};
  
//~ var hidden_re = /^_/;
var methods = {

parseTokens: function(text){
    var token, data = [];
    while ((token = regExp.tokens.exec(text))  !== null ) {
      var str = token[0].replace(regExp.space_bound, "");
      str = str.replace(regExp.space, " ");
      str = str.replace(regExp.clean, "");
      if (regExp.quote.test(str)) {
        data.push(str.replace(regExp.quote, ""));
      } else {
        Array.prototype.push.apply(data, str.split(regExp.space));
      }
      
    }
  return data;
},
  
addr_http_then_cb: function($ctrl, $scope) {return function (resp){// self lib method return function!
  $ctrl.select.choices = resp.data;
  $ctrl.cancelerHttp = undefined;
};},
  
SearchAddress: function($ctrl, $scope, select, url_for) {
  var text = select.search;
  //~ $ctrl.data = [];
  if (text.length === 0) select.choices = [];
  var data = methods.parseTokens(text);


  if (!data[0] || data[0].length < 3) return;// || !/\w/.test(text)
  //~ if (regExp.latin.test(data[0])) return;
  
  var query = {q: data};
  if ($ctrl.cancelerHttp) $ctrl.cancelerHttp.resolve();
  $ctrl.cancelerHttp = $q.defer();
  $ctrl.select = select;
  $http.get(
    appRoutes.url_for(url_for), //$attrs.searchAddressUrl,
    {params: query, timeout: $ctrl.cancelerHttp.promise}
  ).then(methods.addr_http_then_cb($ctrl, $scope));
  //~ return ;
},

ClearAddr: function($ctrl, $scope, select) {
  select.selected = {};
},
  
RemoveAddr: function($ctrl, $scope, idx) {
  if ($ctrl.data.length == 1) {
    $ctrl.data[0] = {};
    return;
  }
  $ctrl.data.splice(idx, 1);
},

AddrTop: function ($ctrl, $scope, idx, check) {// проверка тоже тут
  if (check) return idx !== 0; // вообще с нулевой в последнюю позицию перемещает хорошо
  $ctrl.data.move(idx, 0);
},
  
AddrUp: function ($ctrl, $scope, idx, check) {// проверка тоже тут
  if (check) return idx !== 0; // вообще с нулевой в последнюю позицию перемещает хорошо
  $ctrl.data.move(idx, idx-1);
},
  
AddrDown: function ($ctrl, $scope, idx) {
  $ctrl.data.move(idx, idx+1);
},
  
DisableAddr: function ($ctrl, $scope, idx) {
  $ctrl.data[idx].disabled = !$ctrl.data[idx].disabled;
},
  
IsDisabled: function($ctrl, $scope, select) {
  if (!select.selected) return false;
  return !!select.selected.disabled;
}

};


return function($ctrl, $scope) {//constructor
  //~ console.log("SearchTransportLib new instance...");
  var lib = this;
  //~ var scopeDESTROY = function () {
  //~ };
  //~ $scope.$on('$destroy', scopeDESTROY);
  angular.forEach(methods, function(val, key) {
    //~ if(hidden_re.test(key)) return;
    lib[key] = function () {return val($ctrl, $scope, arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);};
    //~ lib[key] = val;
  });
};
};


/*========================================================================*/

module

.factory('AddressLib', Lib)

.component('addressSelect', {
  templateUrl: "address/select",
  bindings: {
      data: '<',
      disabled: '<'

  },
  controller: Controll
})

.component('addressSelect2', {
  templateUrl: "address/select2",
  bindings: {
      data: '<',
      disabled: '<'

  },
  controller: Controll2
})

;

}());