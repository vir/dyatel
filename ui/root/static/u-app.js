var dyatelApp = angular.module('dyatelApp', [
	'ui.bootstrap',
	'ngRoute',
	'ngDragDrop',
	'userControllers',
	'ngCookies',
	'pascalprecht.translate',
]);

dyatelApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/home',            { templateUrl: '/static/u/home.htm',       controller: 'HomePageCtrl',           title: 'Моя телефония' }).
	when('/phonebook',       { templateUrl: '/static/u/phonebook.htm',  controller: 'PhoneBookCtrl',          title: 'Телефонная книга' }).
	when('/calllist',        { templateUrl: '/static/u/calllist.htm',   controller: 'CallListCtrl',           title: 'История вызовов' }).
	when('/calllist/:billid',{ templateUrl: '/static/u/calllist.htm',   controller: 'CallListCtrl',           title: 'История вызовов' }).
	when('/myphone',         { templateUrl: '/static/u/myphone.htm',    controller: 'MyPhoneCtrl',            title: 'Мой телефон' }).
	when('/myabbrs',         { templateUrl: '/static/u/myabbrs.htm',    controller: 'MyAbbrsCtrl',            title: 'Сокращенные номера' }).
	when('/blfs',            { templateUrl: '/static/u/blfs.htm',       controller: 'MyBLFsCtrl',             title: 'BLF' }).
	when('/go/:action*',     { template: ' ', controller: 'GoRedirCtrl', reloadOnSearch: true, caseInsensitiveMatch: true, }).
	otherwise({ redirectTo: '/home' });
	//$locationProvider.html5Mode( true );
}]);

dyatelApp.config(['$translateProvider', function($translateProvider) {
	$translateProvider.useStaticFilesLoader({
		prefix: '/static/locale-',
		suffix: '.json'
	});
	$translateProvider.useCookieStorage();
//	$translateProvider.preferredLanguage('en');
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
		if(current.$$route) {
			Title.set(current.$$route.title);
			$rootScope.helpLink = current.$$route.templateUrl.replace(/.*\/(\w+)\/(\w+)/, function(_, sec, page) { return sec.toUpperCase() + page.charAt(0).toUpperCase() + page.slice(1); });
		}
	});
}]);

