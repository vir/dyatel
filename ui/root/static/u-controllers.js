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
				return $http({
					method: 'POST',
					url: '/u/cti/transfer',
					data: $.param({ chan: chan, target: num }),
					headers: {'Content-Type': 'application/x-www-form-urlencoded'}
				});
			},

			transferChan: function(chan, other) {
				return $http({
					method: 'POST',
					url: '/u/cti/transfer2',
					data: $.param({ chan: chan, target: other }),
					headers: {'Content-Type': 'application/x-www-form-urlencoded'}
				});
			},

			conference: function(chan, other) {
				return $http({
					method: 'POST',
					url: '/u/cti/conference',
					data: $.param({ chan: chan, target: other }),
					headers: {'Content-Type': 'application/x-www-form-urlencoded'}
				});
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

var ctrlrModule = angular.module('userControllers', [ 'ngGrid', 'dyatelServices', 'dyatelCommon' ]);

ctrlrModule.controller('NavbarCtrl', function($scope, $http) {
	$http.get('/id').success(function(data) {
		$scope.user = data;
	});
});

ctrlrModule.directive('fullscreen', function() {
	return {
		restrict: 'E',
		replace: true,
		scope: {
		},
		link: function (scope, element, attrs, model) {
			var el = document.documentElement;
			var rfs = el.requestFullScreen || el.webkitRequestFullScreen || el.mozRequestFullScreen || el.msRequestFullScreen;
			var cfs = document.exitFullscreen || document.webkitExitFullscreen || document.mozCancelFullScreen || document.msExitFullscreen;
			if(rfs && cfs) {
				scope.fs = function(st) {
					if(st)
						rfs.call(document.documentElement);
					else
						cfs.call(document);
				};
			}
		},
		template: '<i ng-click="toggle()" title="{{title}}" ng-class="{\'flaticon-fullscreen2\':state, \'flaticon-fullscreen3\':!state}"></i>',
		controller: function($scope) {
			$scope.state = false;
			$scope.title = 'Full screen';
			$scope.toggle = function() {
				$scope.state = !$scope.state;
				if($scope.fs)
					$scope.fs($scope.state);
				$scope.title = $scope.state ? 'Exit full screen' : 'Full screen';
			};
		},
	};
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
				activeCall: function () { return obj; },
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
	$scope.section = 'all';
	$scope.selection = [ ];
	$scope.totalServerItems = 0;
	$scope.pagingOptions = {
		pageSizes: [50, 100, 200, 500],
		pageSize: 50,
		currentPage: 1
	};
	$scope.getData = function(pageSize, page) {
		$http.get('/u/cdr/list/' + $scope.section + '?page=' + page + '&perpage=' + pageSize).success(function(data) {
			$scope.myData = data.rows;
			$scope.totalServerItems = data.totalrows;
			if (!$scope.$$phase) {
				$scope.$apply();
			}
		});
	};
	$scope.$watch('pagingOptions', function (newVal, oldVal) {
		if (newVal !== oldVal && newVal.currentPage !== oldVal.currentPage) {
			$scope.getData($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage);
		}
	}, true);
	$scope.setSection = function(s) {
		$scope.section = s;
		$scope.getData($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage);
	};
	$scope.formatPeer = function(row) {
		var inc = 'outgoing' === row.getProperty('direction');
		var dir = inc
			? '<abbr title="Incoming"><i class="flaticon-arrow219"></i></abbr> '
			: '<abbr title="Outgoing"><i class="flaticon-arrow217"></i></abbr> ';
		var peer;
		if(inc) {
			peer = row.getProperty('caller');
		} else {
			var c = row.getProperty('called');
			var f = row.getProperty('calledfull');
			if(null === f || f.length === 0 || c === f)
				peer = c;
			else if(c.length + f.length <= 10)
				peer = c + ' (' + f + ')';
			else
				peer = '<abbr title="' + f + '">' + c + '</abbr>';
		}
		return dir + ' ' + peer;
	};
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
//			{field:'id', displayName:'id'},
			{field:'ts', displayName:'Time', cellTemplate:'<div class="ngCellText"><abbr title="{{row.getProperty(\'ts\')}}">{{row.getProperty(\'ts\').substr(8,11)}}</abbr></div>' },
			{field:'billid', displayName:'Billid'},
			{displayName:'Peer', cellTemplate:'<div class="ngCellText" ng-bind-html="formatPeer(row) | unsafe"></div>'},
//			{field:'direction', displayName:'Direction'},
//			{field:'caller'}, {field:'called'},
//			{field:'duration', displayName:'Duration'},
			{field:'billtime', displayName:'Bill Time'},
			{field:'ringtime', displayName:'Ring Time'},
			{field:'status', displayName:'Status'},
			{field:'reason', displayName:'Reason'},
//			{field:'ended', displayName:'ended'},
//			{field:'callid', displayName:'callid'},

//			{field:'id', displayName:'Id', cellTemplate: '<a ng-href="#/pgroups/{{row.getProperty(\'id\')}}">{{row.getProperty(col.field)}}</a>'},
		],
		showFilter: true,
		multiSelect: false,
		selectedItems: $scope.selection,
		enablePaging: true,
		showFooter: true,
		totalServerItems: 'totalServerItems',
		pagingOptions: $scope.pagingOptions,
	};
	$scope.getData($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage);
});

ctrlrModule.controller('MyPhoneCtrl', function($scope, $http) {
});

ctrlrModule.controller('MyAbbrsCtrl', function($scope, $http) {
});

ctrlrModule.controller('MyBLFsCtrl', function($scope, $http) {
	var urlBase = '/u/blfs/';
	$scope.selection = [ ];
	$http.get(urlBase + 'list').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'key', displayName:'Key', width:'15%'},
			{field:'num', displayName:'Number', width:'15%'},
			{field:'label', displayName:'Label'},
		],
		multiSelect: false,
		selectedItems: $scope.selection,
		/*
		rowTemplate:
			'<div style="height: 100%" ng-class="{changed: !!row.getProperty(\'changed\')}">' +
				'<div ng-repeat="col in renderedColumns" ng-class="col.colIndex()" class="ngCell">' +
					'<div ng-cell></div>' +
				'</div>' +
			'</div>',
		beforeSelectionChange: function() {
			$scope.editForm.$pristine = true;
			return true;
		},
		*/
	};
	$scope.onNew = function() {
		var newRow = { id: 'create', key:1, num:'', label:'', changed: true };
		if($scope.myData.length)
			newRow.key = parseFloat($scope.myData[$scope.myData.length - 1].key) + 1;
		$scope.myData.push(newRow);
		var index = $scope.myData.indexOf(newRow);
		var e = $scope.$on('ngGridEventData', function() {
			$scope.gridOptions.selectItem(index, true);
			var grid = $scope.gridOptions.ngGrid;
			grid.$viewport.scrollTop((grid.rowMap[index] + 1) * grid.config.rowHeight);
//			e();
		});
	};
	$scope.onSave = function() {
		var saveData = {
			action: 'save',
			key: $scope.selection[0].key,
			num: $scope.selection[0].num,
			label: $scope.selection[0].label,
		};
		$.each($scope.selection[0], function(key, value) { // XXX depends on jQuery
				if(key === 'id' || key === 'changed')
					return;
				saveData[key] = value;
		});
		$http({
			method: 'POST',
			url: urlBase + $scope.selection[0].id,
			data: $.param(saveData), // XXX depends on jQuery
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function(data) {
			//alert(angular.toJson(data));
			if(data.obj) {
				for(k in data.obj) {
					$scope.selection[0][k] = data.obj[k];
				}
			}
			$scope.selection[0].changed = false;
		});
	};
	$scope.onDelete = function() {
		var delRow = function() {
			var index = $scope.myData.indexOf($scope.selection[0]);
			$scope.gridOptions.selectItem(index, false);
			$scope.myData.splice(index, 1);
		};
		if(isNaN(parseFloat($scope.selection[0].id)))
			delRow();
		else {
			$http({
				method: 'POST',
				url: urlBase + 'delete',
				data: 'id=' + $scope.selection[0].id,
				headers: {'Content-Type': 'application/x-www-form-urlencoded'}
			}).success(delRow);
		}
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
});



