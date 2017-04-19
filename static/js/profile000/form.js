(function () {
  'use strict';
  
  
  var formProfileControll = function ($scope, $attrs, $element, $http, $window) {//
    var self = this;
    console.log("formProfileControll started");
    
    $scope.formData = {"names": []};
    
    self.Submit = function () {
      //~ return console.log($scope.formData);
      $http.post($attrs.action, $scope.formData).then(function (resp) {
        console.log(resp.data);
        if (resp.data.redirect) $window.location.href = resp.data.redirect;
        if (resp.data.error) self.error = resp.data.error;
      });
      
    };
    
    self.Validate = function () {
      if ($scope.formProfile.$pristine) return false;
      return true;
      
    };
    
    //~ self.Submit=function(){
      //~ console.log($scope.formData);
      //~ console.log($scope.formProfile);//angular.toJson(
    //~ }
    
  };
  
  angular.module('formProfile', [])
  
  .controller('formProfileControll', formProfileControll);

}());