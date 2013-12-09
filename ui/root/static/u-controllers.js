
var ctrlrModule = angular.module('userControllers', [ 'ngGrid' ]);

ctrlrModule.controller('NavbarCtrl', function($scope, $http) {
	$http.get('/id').success(function(data) {
		$scope.user = data;
	});
});

ctrlrModule.directive('focusMe', function ($timeout) {
	return {
		link: function (scope, element, attrs, model) {
			$timeout(function () {
				element[0].focus();
			});
		}
	};
});

ctrlrModule.controller('HomePageCtrl', function($scope, $http) {
});

ctrlrModule.controller('PhoneBookCtrl', function($scope, $http, $timeout) {
	$scope.filterOptions = {
		filterText: "",
		useExternalFilter: true,
		cb_local: true,
		cb_private: true,
		cb_common: true,
	};
	$scope.pagingOptions = {
		totalServerItems: 0,
		pageSizes: [5, 10, 20],
		pageSize: 5,
		currentPage: 1
	};

	$scope.getData = function() {
		var url = '/u/phonebook/search?' + $.param({
			q: $scope.filterOptions.filterText,
//			p: $scope.pagingOptions.currentPage,
//			pp: $scope.pagingOptions.pageSize,
			loc: $scope.filterOptions.cb_local ? 1 : 0,
			pvt: $scope.filterOptions.cb_private ? 1 : 0,
			com: $scope.filterOptions.cb_common ? 1 : 0,
		}, true); // use jQuery to url-encode object
		$http.get(url).success(function(data) {
			$scope.pagingOptions.totalServerItems = data.rows;
			$scope.myData = data.result;
		});
	};
	$scope.updateResults = function() {
		//$scope.getData();
		if($scope.getDataTimeout)
			$timeout.cancel($scope.getDataTimeout);
		$scope.getDataTimeout = $timeout(function() {
			$scope.getData();
		}, 500);
		$scope.$on('$destroy', function() {
			$timeout.cancel($scope.getDataTimeout);
		});
	};

	$scope.$watch('pagingOptions', function (newVal, oldVal) {
		if (newVal !== oldVal && newVal.currentPage !== oldVal.currentPage) {
			$scope.updateResults();
		}
	}, true);
	$scope.$watch('filterOptions', function (newVal, oldVal) {
		if (newVal !== oldVal) {
			$scope.updateResults();
		}
	}, true);

	$scope.getData();

	$scope.selection = [ ];
	$scope.gridOptions = {
		data: 'myData',
//		enablePaging: true,
//		showFooter: true,
		totalServerItems:'pagingOptions.totalServerItems',
		pagingOptions: $scope.pagingOptions,
		filterOptions: $scope.filterOptions,
		multiSelect: false,
		selectedItems: $scope.selection,
	};
});

ctrlrModule.controller('CallListCtrl', function($scope, $http) {
});

ctrlrModule.controller('MyPhoneCtrl', function($scope, $http) {
});

ctrlrModule.controller('MyAbbrsCtrl', function($scope, $http) {
});



