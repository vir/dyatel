
var dyatelControllers = angular.module('dyatelControllers', [ 'ngGrid' ]);

dyatelControllers.controller('NavbarCtrl', function($scope, $location) {
});

dyatelControllers.controller('HomePageCtrl', function($scope, $http) {
});

dyatelControllers.controller('UserDetailCtrl', function($scope, $routeParams, $http, $location) {
	if($routeParams.userId == 'new') {
		$scope.existingUser = false;
	} else {
		$http.get('users/' + $routeParams.userId).success(function(data) {
			$scope.user = data.user;
			$scope.existingUser = true;
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

dyatelControllers.controller('ProvisionsListCtrl', function($scope, $http) {  });
dyatelControllers.controller('ProvisionDetailCtrl', function($scope, $http) {  });
dyatelControllers.controller('CallGroupsListCtrl', function($scope, $http) {  });
dyatelControllers.controller('CallGroupDetailCtrl', function($scope, $http) {  });
dyatelControllers.controller('PickupGroupsListCtrl', function($scope, $http) {  });
dyatelControllers.controller('PickupGroupDetailCtrl', function($scope, $http) {  });

