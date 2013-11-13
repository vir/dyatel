
var dyatelControllers = angular.module('dyatelControllers', [ 'ngGrid' ]);

dyatelControllers.controller('NavbarCtrl', function($scope, $http) {
	$http.get('/id').success(function(data) {
		$scope.user = data;
	});
});

dyatelControllers.controller('HomePageCtrl', function($scope, $http) {
});


/* * * * * * * * * * Users * * * * * * * * * */

dyatelControllers.controller('UserDetailCtrl', function($scope, $routeParams, $http, $location) {
	if($routeParams.userId == 'new') {
		$scope.existingUser = false;
		$scope.title += 'New user';
	} else {
		$http.get('/a/users/' + $routeParams.userId).success(function(data) {
			$scope.user = data.user;
			$scope.existingUser = true;
//			$scope.title += data.user.num + ': ' + data.user.descr;
			$scope.Title.set(data.user.num + ': ' + data.user.descr);
		});
		$http.get('/a/provisions/list?uid=' + $routeParams.userId).success(function(data) {
			$scope.provisions = data.rows;
		});
		$http.get('/a/morenums/list?uid=' + $routeParams.userId).success(function(data) {
			$scope.morenums = data.rows;
		});
		$http.get('/a/regs/list?uid=' + $routeParams.userId).success(function(data) {
			$scope.regs = data.rows;
		});
	}
	$scope.saveUser = function() {
		$scope.user.save=1;
		$http({
			url: $scope.existingUser ? '/a/users/' + $routeParams.userId : '/a/users/create',
			method: "POST",
			data: $.param($scope.user), // use jQuery to url-encode object
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
			alert('Saved user');
		}).error(function (data, status, headers, config) {
			alert('Error: ' + status);
		});
		delete $scope.user.save;
	};
	$scope.deleteUser = function() {
		$http({
			url: '/a/users/delete?uid=' + $routeParams.userId,
			method: "POST",
			data: "delete=1",
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
			alert('User deleted');
			$location.path('/a/users/list');
			$scope.$apply();
		}).error(function (data, status, headers, config) {
			alert('Error: ' + status);
		});
	};
	$scope.randomPassword = function(len, charset) {
		var result = [];
		charset = charset || 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		while(--len) {
			result.push(charset.charAt(Math.floor(Math.random() * charset.length)));
		}
		return result.join('');
	};
});

dyatelControllers.controller('UsersListCtrl', function($scope, $http) {
	$http.get('/a/users/list').success(function(data) {
		$scope.myData = data.users;
	});
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'num', displayName:'Number', cellTemplate: '<a ng-href="#/users/{{row.getProperty(\'id\')}}">{{row.getProperty(col.field)}}</a>'},
			{field:'descr', displayName:'Name'},
		],
		showFilter: true,
	};
});


/* * * * * * * * * * Call Groups * * * * * * * * * */

dyatelControllers.controller('CallGroupsListCtrl', function($scope, $http) {
	$http.get('/a/cgroups/list').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'num', displayName:'Number', cellTemplate: '<a ng-href="#/cgroups/{{row.getProperty(\'id\')}}">{{row.getProperty(col.field)}}</a>'},
			{field:'descr', displayName:'Name'},
		],
		showFilter: true,
	};
});

dyatelControllers.controller('CallGroupDetailCtrl', function($scope, $routeParams, $http) {
	if($routeParams.userId == 'new') {
		$scope.existingGrp = false;
	} else {
		$http.get('cgroups/' + $routeParams.grpId).success(function(data) {
			$scope.grp = data.grp;
			$scope.members = data.members;
			$scope.existingGrp = true;
		});
	}
	// members list
	$scope.gridOptions = {
		data: 'members',
		showFilter: true,
	};
});


/* * * * * * * * * * Pickup Groups * * * * * * * * * */

dyatelControllers.controller('PickupGroupsListCtrl', function($scope, $http) {
	$http.get('/a/pgroups/list').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'id', displayName:'Id', cellTemplate: '<a ng-href="#/pgroups/{{row.getProperty(\'id\')}}">{{row.getProperty(col.field)}}</a>'},
			{field:'descr', displayName:'Name'},
		],
		showFilter: true,
	};
});

dyatelControllers.controller('PickupGroupDetailCtrl', function($scope, $routeParams, $http) {
});


/* * * * * * * * * * Provision * * * * * * * * * */

dyatelControllers.controller('ProvisionsListCtrl', function($scope, $http) {
});
dyatelControllers.controller('ProvisionDetailCtrl', function($scope, $routeParams, $http) {
});

