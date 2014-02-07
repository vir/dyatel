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

			transferChan: function(chan, other) {
				alert('Unimplemented CTI.transferChan(' + chan + ', ' + other + ') called');
			},

			conference: function(chan, other) {
				alert('Unimplemented CTI.conference(' + chan + ', ' + other + ') called');
			},

			eventHandler: function(name, handlerFunc, stateFunc) {
				var es = new EventSource('/u/eventsource/' + name, { withCredentials: true });
				es.addEventListener('message', function (e) {
					if(e.data === 'keepalive')
						return;
					if(e.data === 'testevent') {
						console.log('Got testevent');
						return;
					}
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

ctrlrModule.filter('capitalize', function() {
	return function(input, scope) {
		return input.substring(0,1).toUpperCase()+input.substring(1);
	}
});

ctrlrModule.controller('CallDlgCtrl', function($scope, $modalInstance, $timeout, CTI, num, activeCall, usage) {
	$scope.num = num;
	$scope.activeCall = activeCall;
	$scope.info = 'No info';
	$scope.log = 'ok\n';
	var targetIsAChannel = -1 !== $scope.num.indexOf('/');
	$scope.buttons = { };

	var focusId;
	if(! targetIsAChannel) {
		$scope.buttons.call = function() {
			CTI.newCall($scope.num);
			$modalInstance.close('call');
		};
		focusId = '#btn-call';
	}
	if($scope.activeCall) {
		$scope.log += 'Active call: ' + angular.toJson($scope.activeCall) + "\r\n";
		$scope.buttons.transfer = function() {
			if(targetIsAChannel)
				CTI.transferChan($scope.activeCall.chan, $scope.num);
			else
				CTI.transferCall($scope.activeCall.chan, $scope.num);
			$modalInstance.close('transfer');
		};
		if(usage === 'dnd')
			focusId = '#btn-transfer';
	}
	if(targetIsAChannel) {
		$scope.buttons.conference = function() {
			CTI.conference($scope.activeCall.chan, $scope.num);
			$modalInstance.close('conf');
		};
	}
	$scope.btnCancel = function () {
		$modalInstance.dismiss('cancel');
	};
	$scope.log += 'Buttons: ' + angular.toJson($scope.buttons) + "\r\n";
	$timeout(function () {
		$(focusId).focus();
	});
});

ctrlrModule.controller('HomePageCtrl', function($scope, $http, $modal, $timeout, CTI) {
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
			controller: 'CallDlgCtrl',
			resolve: {
				num: function () { return o.num; },
				activeCall: function () { return $scope.linetracker.length ? $scope.linetracker[0] : null; },
				usage: function() { return o.op; },
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
		if(state)
			$timeout.cancel($scope.testEventTimeout);
	});

	// Connection loopback test
	$scope.testEvent = function() {
		return $http({
			method: 'POST',
			url: '/u/eventsource/testevent',
			data: $.param({ event: 'testevent' }),
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function(data) {
			console.log('Posted testevent');
		});
	};
	$scope.testEventTimeout = $timeout(function() {
		if(! $scope.connected)
			$scope.testEvent();
	}, 500);

	// Calls drag-and-drop support
	$scope.onDrop = function(obj, what, target) {
		console.log('Dropped ' + obj.direction + ' channel ' + obj.chan + ' on ' + what + ' ' + target);
		var modalInstance = $modal.open({
			templateUrl: '/static/u/calldialog.htm',
			controller: 'CallDlgCtrl',
			resolve: {
				num: function () { return target; },
				activeCall: function () { return $scope.linetracker.length ? $scope.linetracker[0] : null; },
				usage: function() { return 'dnd' },
			},
		});
	};
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



