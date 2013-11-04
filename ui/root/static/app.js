var dyatelApp = angular.module('dyatelApp', [
	'ui.bootstrap',
	'ngRoute',
	'dyatelControllers',
]);

dyatelApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/home',            { templateUrl: '/static/p/home.htm',       controller: 'HomePageCtrl' }).
	when('/users',           { templateUrl: '/static/p/users.htm',      controller: 'UsersListCtrl' }).
	when('/users/:userId',   { templateUrl: '/static/p/user.htm',       controller: 'UserDetailCtrl' }).
	when('/provisions',      { templateUrl: '/static/p/provisions.htm', controller: 'ProvisionsListCtrl' }).
	when('/provisions/:pId', { templateUrl: '/static/p/provision.htm',  controller: 'ProvisionDetailCtrl' }).
	when('/cgroups',         { templateUrl: '/static/p/cgroups.htm',    controller: 'CallGroupsListCtrl' }).
	when('/cgroups/:grpId',  { templateUrl: '/static/p/cgroup.htm',     controller: 'CallGroupDetailCtrl' }).
	when('/pgroups',         { templateUrl: '/static/p/pgroups.htm',    controller: 'PickupGroupsListCtrl' }).
	when('/pgroups/:grpId',  { templateUrl: '/static/p/pgroup.htm',     controller: 'PickupGroupDetailCtrl' }).
	otherwise({ redirectTo: '/home' });
}]);

