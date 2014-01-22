var dyatelApp = angular.module('dyatelApp', [
	'ui.bootstrap',
	'ngRoute',
	'dyatelControllers',
	'ui.utils',
]);

dyatelApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/home',            { templateUrl: '/static/p/home.htm',       controller: 'HomePageCtrl',           title: 'Start page' }).
	when('/users',           { templateUrl: '/static/p/users.htm',      controller: 'UsersListCtrl',          title: 'Users' }).
	when('/users/:userId',   { templateUrl: '/static/p/user.htm',       controller: 'UserDetailCtrl',         title: 'User' }).
	when('/provisions',      { templateUrl: '/static/p/provisions.htm', controller: 'ProvisionsListCtrl',     title: 'Provisions' }).
	when('/provisions/:pId', { templateUrl: '/static/p/provision.htm',  controller: 'ProvisionDetailCtrl',    title: 'Provision' }).
	when('/cgroups',         { templateUrl: '/static/p/cgroups.htm',    controller: 'CallGroupsListCtrl',     title: 'Call groups' }).
	when('/cgroups/:grpId',  { templateUrl: '/static/p/cgroup.htm',     controller: 'CallGroupDetailCtrl',    title: 'Call group' }).
	when('/pgroups',         { templateUrl: '/static/p/pgroups.htm',    controller: 'PickupGroupsListCtrl',   title: 'Pickup groups' }).
	when('/pgroups/:grpId',  { templateUrl: '/static/p/pgroup.htm',     controller: 'PickupGroupDetailCtrl',  title: 'Pickup group' }).
	when('/ivr-aas',         { templateUrl: '/static/p/ivr-aas.htm',    controller: 'IvrAAsCtrl',             title: 'IVR - AA' }).
	when('/ivr-mds',         { templateUrl: '/static/p/ivr-mds.htm',    controller: 'IvrMDsCtrl',             title: 'IVR - MD' }).
	when('/cdr',             { templateUrl: '/static/p/cdrs.htm',       controller: 'CdrsCtrl',               title: 'Call detail records' }).
	when('/status',          { templateUrl: '/static/p/status.htm',     controller: 'StatusCtrlOverview',     title: 'Engine status' }).
	when('/status/:module',  { templateUrl: '/static/p/status_m.htm',   controller: 'StatusCtrlModule',       title: 'Engine status' }).
	when('/schedule',        { templateUrl: '/static/p/schedule.htm',   controller: 'ScheduleCtrl',           title: 'Schedule' }).
	otherwise({ redirectTo: '/home' });
	//$locationProvider.html5Mode( true );
}]);

dyatelApp.factory('Title', function() {
	var title = '';
	return {
		get: function() { return 'DYATEL: ' + title; },
		set: function(t) { title = t; },
	};
});

dyatelApp.run(['Title', '$rootScope', function(Title, $rootScope) {
	$rootScope.Title = Title;
	$rootScope.$on('$routeChangeSuccess', function (event, current, previous) {
		if(current.$$route)
			Title.set(current.$$route.title);
	});
}]);

