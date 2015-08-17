var dyatelApp = angular.module('dyatelApp', [
	'ui.bootstrap',
	'ngRoute',
	'dyatelControllers',
	'ui.utils',
]);

dyatelApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/home',            { templateUrl: '/static/a/home.htm',       controller: 'HomePageCtrl',           title: 'Start page' }).
	when('/users',           { templateUrl: '/static/a/users.htm',      controller: 'UsersListCtrl',          title: 'Users' }).
	when('/users/:userId',   { templateUrl: '/static/a/user.htm',       controller: 'UserDetailCtrl',         title: 'User' }).
	when('/regs',            { templateUrl: '/static/a/regs.htm',       controller: 'RegsListCtrl',           title: 'Active registrations' }).
	when('/provisions',      { templateUrl: '/static/a/provisions.htm', controller: 'ProvisionsListCtrl',     title: 'Provisions' }).
	when('/provisions/:pId', { templateUrl: '/static/a/provision.htm',  controller: 'ProvisionDetailCtrl',    title: 'Provision' }).
	when('/cgroups',         { templateUrl: '/static/a/cgroups.htm',    controller: 'CallGroupsListCtrl',     title: 'Call groups' }).
	when('/cgroups/:grpId',  { templateUrl: '/static/a/cgroup.htm',     controller: 'CallGroupDetailCtrl',    title: 'Call group' }).
	when('/pgroups',         { templateUrl: '/static/a/pgroups.htm',    controller: 'PickupGroupsListCtrl',   title: 'Pickup groups' }).
	when('/pgroups/:grpId',  { templateUrl: '/static/a/pgroup.htm',     controller: 'PickupGroupDetailCtrl',  title: 'Pickup group' }).
	when('/ivr-aas',         { templateUrl: '/static/a/ivr-aas.htm',    controller: 'IvrAAsCtrl',             title: 'IVR - AA' }).
	when('/ivr-mds',         { templateUrl: '/static/a/ivr-mds.htm',    controller: 'IvrMDsCtrl',             title: 'IVR - MD' }).
	when('/cdr',             { templateUrl: '/static/a/cdrs.htm',       controller: 'CdrsCtrl',               title: 'Call detail records' }).
	when('/status',          { templateUrl: '/static/a/status.htm',     controller: 'StatusCtrlOverview',     title: 'Engine status' }).
	when('/status/:module',  { templateUrl: '/static/a/status_m.htm',   controller: 'StatusCtrlModule',       title: 'Engine status' }).
	when('/schedule',        { templateUrl: '/static/a/schedule.htm',   controller: 'ScheduleCtrl',           title: 'Schedule' }).
	when('/config',          { templateUrl: '/static/a/config.htm',     controller: 'ConfigCtrl',             title: 'Configuration' }).
//	when('/fictive',         { templateUrl: '/static/a/fictive.htm',    controller: 'FictiveCtrl',            title: 'Fictive numbers' }).
	when('/fictive/:num?',    { templateUrl: '/static/a/fictive.htm',    controller: 'FictiveCtrl',            title: 'Fictive numbers' }).
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
		if(current.$$route) {
			Title.set(current.$$route.title);
			$rootScope.helpLink = current.$$route.templateUrl.replace(/.*\/(\w+)\/(\w+)/, function(_, sec, page) { return sec.toUpperCase() + page.charAt(0).toUpperCase() + page.slice(1); });
		}
	});
}]);

