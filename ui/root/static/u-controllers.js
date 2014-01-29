angular.module('dyatelServices', [], function($provide) {
	$provide.factory('CTI', ['$http', '$rootScope', function($http, $rootScope) {
		var inst = {

			newCall: function(num) {
				console.log('CTI.newCall(' + num + ') called');
				var postdata = {
					called: num,
					linehint: 'xz',
				};
				return $http({
					method: 'POST',
					url: '/u/cti/call',
					data: $.param(postdata),
					headers: {'Content-Type': 'application/x-www-form-urlencoded'}
				}).success(function(data) {
					console.log('Call result: ' + angular.toJson(data));
				});
			},

			transferCall: function(chan, num) {
				alert('Unimplemented CTI.transferCall(' + chan + ', ' + num + ') called');
			},

			eventHandler: function(name, handlerFunc, stateFunc) {
				var es = new EventSource('/u/eventsource/' + name);
				es.addEventListener('message', function (e) {
					if(e.data === 'keepalive' || e.data === 'testevent')
						return;
					$rootScope.$apply(function() {
						handlerFunc(JSON.parse(e.data));
					});
				});
				if(stateFunc) {
					es.onopen = function() {
						$rootScope.$apply(function() {
							stateFunc(true);
						});
					};
					es.onerror = function() {
						$rootScope.$apply(function() {
							stateFunc(false);
						});
					};
				}
				return es;
			},

		};
		return inst;
	}]);
});

var ctrlrModule = angular.module('userControllers', [ 'ngGrid', 'dyatelServices' ]);

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

ctrlrModule.controller('HomePageCtrl', function($scope, $http, $modal, CTI) {
	$scope.phone = '';
	$scope.linetracker = [ ];
	$scope.blfs = [ ];
	$scope.connected = false;

	$scope.selectionDone = function (item) {
		$scope.phone = item.num;
		$scope.doCall(item);
	};
	$scope.dataSource = function (a) {
		var url = '/u/phonebook/search?' + $.param({ q: a, loc: 1, more: 1, pvt: 1, com: 1 }, true); // use jQuery to url-encode object
		return $http.get(url).then(function (response) {
			return response.data.result.map(function(a) { return {
				num: a.num,
				label: a.num + ' ' + a.descr,
			}});
		});
	};
	$scope.doCall = function(o) {
		if(! o.num.length)
			return;
		var modalInstance = $modal.open({
			templateUrl: '/static/u/calldialog.htm',
			controller: function($scope, $modalInstance, num, calls) {
				$scope.num = num;
				$scope.calls = calls;
				$scope.info = 'No info :(';
				$scope.log = 'ok\n';

				$scope.btnNewCall = function() {
					CTI.newCall($scope.num);
					$modalInstance.close('newCall');
				};
				$scope.btnTransfer = function() {
					CTI.transferCall($scope.calls[0].chan, $scope.num);
					$modalInstance.close('newCall');
				};
				$scope.btnCancel = function () {
					$modalInstance.dismiss('cancel');
				};
			},
			resolve: {
				num: function () { return o.num; },
				calls: function() { return $scope.linetracker; },
			},
		});
		//alert('call: ' + angular.toJson(o));
		return false;
	};

	$scope.updateLinetracker = function() {
		$http.get('/u/linetracker').success(function (data) {
			$scope.linetracker = data.rows;
		});
	};
	$scope.updateBLFs = function() {
		$http.get('/u/cti/blfs').success(function (data) {
			$scope.blfs = data.rows;
		});
	};

	$scope.updateLinetracker();
	$scope.updateBLFs();

	$scope.es = CTI.eventHandler('home', function(msg) {
		if(msg.event === 'linetracker')
			$scope.updateLinetracker();
		else if(msg.event === 'blf_state')
			$scope.updateBLFs();
		else
			console.log('Unknown event received: ' + JSON.stringify(msg));
	}, function(state) {
		$scope.connected = state;
	});
});

ctrlrModule.controller('PhoneBookCtrl', function($scope, $http, $timeout, CTI) {
	$scope.filterOptions = {
		filterText: "",
		useExternalFilter: true,
		cb_local: true,
		cb_more: true,
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
			more: $scope.filterOptions.cb_more ? 1 : 0,
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

	$scope.call = function(arg) {
		CTI.newCall(arg);
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
		columnDefs: [
			{ field: 'descr', displayName: 'Description' },
			{ field: 'num', displayName: 'Number' },
			{ displayName: 'Action', cellTemplate: '<span>{{row.getProperty(\'src\')}} {{row.getProperty(\'numkind\')}} <button ng-click="call(row.getProperty(\'num\'))">Call</button></span>' },
		],
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



