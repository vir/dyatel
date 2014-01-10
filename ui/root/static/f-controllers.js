
var ctrlrModule = angular.module('userControllers', [ 'ngGrid' ]);

ctrlrModule.controller('NavbarCtrl', function($scope, $http) {
	$http.get('/id').success(function(data) {
		$scope.user = data;
	});
});

ctrlrModule.controller('HomePageCtrl', function($scope, $http) {
});

ctrlrModule.controller('PricesCtrl', function($scope, $http) {
	$http.get('/f/prices').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.sel = [ ];
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'pref', displayName:'Префикс'},
			{field:'descr', displayName:'Описание'},
			{field:'price', displayName:'Цена', cellTemplate: '<span>{{ row.getProperty(col.field) }}</span>'},
		],
		showFilter: true,
		multiSelect: false,
		selectedItems: $scope.sel,
	};

	$scope.bSave = function() {
		$scope.sel[0].action = 'save';
		$http({
			url: '/f/prices',
			method: "POST",
			data: $.param($scope.sel[0], true), // use jQuery to url-encode object
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
			$scope.sel[0].id = data.obj.id;
		}).error(function (data, status, headers, config) {
			alert('Error: ' + status);
		});
		delete $scope.sel[0].action;
	};

	$scope.bNew = function() {
		var e = $scope.$on('ngGridEventData', function() {
			$scope.gridOptions.selectItem(0, true);
			$scope.gridOptions.ngGrid.$viewport.scrollTop(0);
			e();
		});
		$scope.myData.unshift({ id: 'new' });
	};

	$scope.bDel = function() {
		$http({
			url: '/f/prices',
			method: "POST",
			data: $.param({
				id: $scope.sel[0].id,
				action: 'delete',
			}, true), // use jQuery to url-encode object
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
			var deleteIndex = $scope.myData.indexOf($scope.sel[0]);
			if(deleteIndex > -1)
				$scope.myData.splice(deleteIndex,1);
		}).error(function (data, status, headers, config) {
			alert('Error: ' + status);
		});
	};

});

ctrlrModule.controller('ShowCtrl', function($scope, $http) {
	$scope.date = {
		begin: '',
		end: '',
	};
});

ctrlrModule.controller('ReportsCtrl', function($scope, $http) {
});

ctrlrModule.controller('GroupsCtrl', function($scope, $http) {
});


