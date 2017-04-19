(function () {
'use strict';

var moduleName = "RightSideNav";

var templateCache = ["/controllers/sidenav/templates.html"];

var Controll = function  ($scope, $attrs, $http, $window, $timeout, loadTemplateCache, $q) {// , ArrayStorage
  //~ console.log("RightSideNav Controll starting...", $attrs);
  var ctrl = this;
  ctrl.$attrs = $attrs;
  loadTemplateCache.split(templateCache, 1).then(function (proms) {ctrl.ready = true; });
  
  //~ ctrl.data = $window.ArrayStorage;//
  //~ console.log(ctrl.data);
    
};

/*=============================================================*/

angular.module(moduleName, ['load.templateCache' ])//, 'ArrayStorage'
//~ angular.module('main')

.controller('Controll'+moduleName, Controll)

;

}());