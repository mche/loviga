(function () {
'use strict';

var Controll = function ($scope, $timeout, $http, appRoutes) {
  var $ctrl = this;
  //~ $ctrl.$attrs = $attrs;
  
  $ctrl.$onInit = function () {
    if ($ctrl.level === undefined) $ctrl.level = 0;
    $ctrl.isTopLevel = ($ctrl.level === 0);
    
    if ($ctrl.isTopLevel) {//$ctrl.data === undefined
      $http.get($ctrl.staticData ? appRoutes.url_for('категории транспорта') : appRoutes.url_for('данные категорий транспорта')).then(function (resp) {
        $ctrl.data = resp.data;
        $ctrl.InitData();
      });
    } else {
      $timeout(function(){$ctrl.InitData();});
    }
  };
  
  $ctrl.InitData = function() {
    
    if(!$ctrl.param) $ctrl.param =  {};
    if(!$ctrl.category) $ctrl.category =  {};
    if(!$ctrl.category.selectedIdx) $ctrl.category.selectedIdx =[];
    if(!$ctrl.category.selected) $ctrl.category.selected = {};
    if(!$ctrl.category.finalCategory) $ctrl.category.finalCategory = {};

    $ctrl.parentSelectedItem = $ctrl.category.selected;
    
    
    var selectedIdx = $ctrl.category.selectedIdx[$ctrl.level];
    if (selectedIdx !== undefined) {
      $ctrl.selectedItem = $ctrl.data[selectedIdx]; // индекс позиция на текущем уровне
      $ctrl.SetFinalCategory();
      $ctrl.category.selected = $ctrl.selectedItem;
    }

    $ctrl.ready = true;

  };
  /*
  $ctrl.InitData0000 = function() {
    
    if ($ctrl.level === undefined) $ctrl.level = 0;
    $ctrl.selected = $ctrl.category.selectedIdx[$ctrl.level]; // индекс позиция на текущем уровне
    //~ $ctrl.ToggleSelect($ctrl.data[$ctrl.selected]);
    $ctrl.SetFinalCategory();
    if ($ctrl.selected) $ctrl.category.selected = $ctrl.data[$ctrl.selected];// item
    
    $ctrl.ready = true;
    
  };
  
  $ctrl.SetFinalCategory000 = function () {
    var final = $ctrl.selected !== undefined && $ctrl.data[$ctrl.selected] && ((!$ctrl.data[$ctrl.selected].childs) || $ctrl.data[$ctrl.selected].childs.length === 0);
    if ( final ) {// нет потомков - это финал в родительский контроллер
      $ctrl.category.finalCategory = $ctrl.data[$ctrl.selected];// item
    } else {
      $ctrl.category.finalCategory = {};
    }
  
  };*/
  
  $ctrl.SetFinalCategory = function () {
      var final1 = $ctrl.selectedItem && (!$ctrl.selectedItem.childs || $ctrl.selectedItem.childs.length === 0);
      if ( final1 ) {// нет потомков - это финал в родительский контроллер
        $ctrl.category.finalCategory = $ctrl.selectedItem;
      } else {
        $ctrl.category.finalCategory = {};
      }
  };
  
  /*
  $ctrl.ToggleSelect000 = function (item) {
    if ($ctrl.disabled) return false;
    var idx = $ctrl.data.indexOf(item);
    
    if ($ctrl.selected !== undefined && $ctrl.selected == idx) {// сброс
      $ctrl.selected = undefined;
      $ctrl.category.selectedIdx = $ctrl.category.selectedIdx.splice(0, $ctrl.level);
      $ctrl.category.finalCategory = {};
      $ctrl.category.selected = $ctrl.SelectedCategory();
      //~ $ctrl.category.current = {};
      return true;
    }
    
    // Выключил 16-01-2017
    //~ if (item.hasOwnProperty('_count') && !item._count) return;
    
    $ctrl.selected =  idx;
    $ctrl.category.selectedIdx[$ctrl.level] = idx;
    $ctrl.SetFinalCategory();
    $ctrl.category.selected = $ctrl.data[$ctrl.selected];// item
    //~ $ctrl.category.current = $ctrl.data[idx];
  };*/

  $ctrl.ToggleSelect = function (item, event) {
    if ($ctrl.disabled || item.disabled) return false;//
    var idx = $ctrl.data.indexOf(item);
    
    if ($ctrl.selectedItem && $ctrl.selectedItem.id) {// сброс && $ctrl.selected == idx
      $ctrl.selectedItem = undefined;
      $ctrl.category.selectedIdx.splice($ctrl.level, 1000);
      $ctrl.SetFinalCategory();// после $ctrl.selectedItem = undefined;
      $ctrl.category.selected = $ctrl.parentSelectedItem;
      //~ return false;
    }
    else {
      // Выключил 16-01-2017
      //~ if (item.hasOwnProperty('_count') && !item._count) return;
      $ctrl.category.selectedIdx[$ctrl.level] = idx;
      $ctrl.selectedItem =  item;
      $ctrl.category.selected = item;// item
      $ctrl.SetFinalCategory();
    }
    
    //~ $ctrl.EmitEvent();// поменять сборку пути
    
    return true;
  };
/*
  $ctrl.SelectedCategory000 = function () {
    var data = $ctrl.data,
      curr;
    angular.forEach($ctrl.category.selectedIdx, function(idx) {
      curr = data[idx];
      data = curr.childs;
    });
    //~ $ctrl.category.selected = curr;
    return curr;
  };
  
  
  
  $ctrl.filterSelected000 = function(item, index, array) {
    //~ console.log("фильрация списка", item);
    if (!!item.disabled) return false;
    if ($ctrl.selected === undefined || $ctrl.data[$ctrl.selected] === item) return true;
    return false;
  };*/
  
  $ctrl.filterSelected = function(item, index, array) {
    //~ console.log("фильрация списка", item);
    if (!!item.disabled) return false;
    //~ if (item['new']) console.log("new!");//return true;
    if ($ctrl.selectedItem === undefined || $ctrl.selectedItem === item) return true;
    return false;
  };
  
  $ctrl.ExpandIf = function(item){
    if (!$ctrl.ready) return false;
    if (($ctrl.selectedItem && $ctrl.selectedItem === item) || $ctrl.param.expandAll) return true;
    return false;
  };
  
  $ctrl.ItemImg = function (item) {
    return appRoutes.url_for('картинка категории', [item._img_url || 'default.png']);
  };
  
  //~ if ($ctrl.data === undefined) {CategoryData.get($ctrl.staticData, function (resp) {$ctrl.data = resp.data; $ctrl.Init();});} 
  //~ else {$ctrl.Init();}

  
};

/*
var serviceData = function($http, appRoutes) {//$q, 
  
  this.get = function(staticData){
    return $http.get(staticData ? appRoutes.url_for('категории транспорта') : appRoutes.url_for('данные категорий транспорта'));//{"cache": true}
    //~ .then(http_then_cb);
  };
  
};
*/

angular.module('transport.category.list', ['appRoutes'])
//~ .config( function( $compileProvider ){
  //~ console.log($compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|tel|file|javascript):/));
//~ })
.component('transportCategoryList', {// много раз повторяется и шаблон проще жестко здесь зашить
  templateUrl: "transport/category/list",
  //~ templateUrl: "/controllers/transport/category/list.html",
  //~ function ($attrs) {
    //~ console.log("component categoryList templateUrl:", $attrs);
    //~ this.xTemplateUrl = $attrs.xTemplateUrl;
    //~ return $attrs.xTemplateUrl;
  //~ },
  bindings: {
      staticData: '<',// boolean влияет на получение корневых данных дерева (статика или с динамическим подсчетом)
      disabled: '<',
      data: '<', // массив-данные потомков для уровня
      level: '<', // текущий уровень дерева 0,1,2.... по умочанию верний - нулевой
      category: '<' // {} внешние данные (нужен проброс) а именно:
          //~ selectedIdx: '=', // двунаправленный массив предустановленных позиций списков [1,0,2] - выбрать вторую поз на 0 уровне, первую - на 1 уровне, третью на третьем уровне
          //~ finalCategory: '=' // если дошел до вершины любой ветки - установить ее узел
      //~ , dataUrl: '<'
  },
  controller: Controll
})

//~ .service('CategoryData', serviceData)

;

}());