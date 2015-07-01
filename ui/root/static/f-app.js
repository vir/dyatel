var dyatelApp = angular.module('dyatelApp', [
	'ui.bootstrap',
	'ngRoute',
	'ngDragDrop',
	'userControllers',
]);

dyatelApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/home',            { templateUrl: '/static/a/home.htm',       controller: 'HomePageCtrl',           title: 'Start page' }).
	when('/prices',          { templateUrl: '/static/f/prices.htm',     controller: 'PricesCtrl',             title: 'Цены' }).
	when('/show',            { templateUrl: '/static/f/show.htm',       controller: 'ShowCtrl',               title: 'Просмотр' }).
	when('/reports',         { templateUrl: '/static/f/reports.htm',    controller: 'ReportsCtrl',            title: 'Отчёты' }).
	when('/groups',          { templateUrl: '/static/f/groups.htm',     controller: 'GroupsCtrl',             title: 'Отделы' }).
	otherwise({ redirectTo: '/home' });
	//$locationProvider.html5Mode( true );
}]);

dyatelApp.factory('Title', function() {
	var title = '';
	return {
		get: function() { return title; },
		set: function(t) { title = t; },
	};
});

dyatelApp.run(['Title', '$rootScope', function(Title, $rootScope) {
	$rootScope.Title = Title;
	$rootScope.$on('$routeChangeSuccess', function (event, current, previous) {
		Title.set(current.$$route.title);
	});
}]);

