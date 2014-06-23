
var dyatelControllers = angular.module('dyatelControllers', [ 'ngGrid', 'ngCookies', 'dyatelCommon' ]);

dyatelControllers.controller('NavbarCtrl', function($scope, $http) {
	$http.get('/id').success(function(data) {
		$scope.user = data;
	});
});

dyatelControllers.controller('HomePageCtrl', function($scope, $http) {
});


/* * * * * * * * * * Users * * * * * * * * * */

dyatelControllers.directive('divertionIcon', function () {
	return {
		restrict: 'EA',
		template: '<abbr class="divertion" ng-show="show" ng-style="getStyle()" title="Divertion on \'{{ lng }}\'">{{ shrt }}</abbr>',
		replace: true,
		scope: {
			type: '@divertionIcon',
			show: '=',
		},
		link: function ($scope, element, attrs) {
			if($scope.type == 'offline') {
				$scope.clr = '#555';
				$scope.lng = 'Offline';
				$scope.shrt = 'X';
			}
			if($scope.type == 'noans') {
				$scope.clr = '#44A';
				$scope.lng = 'No Answer';
				$scope.shrt = 'N';
			}
			$scope.getStyle = function() {
				return {
					'color': $scope.clr,
				};
			};
		},
	}
});

dyatelControllers.directive('dirnum', function ($http) {
	return {
		restrict: 'E',
		templateUrl: '/static/p/dirnum.htm',
		scope: {
			dirNum: '=',
			numType: '@',
			ro: '=numReadonly',
			anyChange: '&',
		},
		link: function ($scope, element, attrs) {
			$scope.warns = '';
			$scope.numCahnge = function() {
				$http.get('/a/directory/conflicts/' + $scope.dirNum.num).success(function(data) {
					$scope.warns = data.conflicts ? 'Conflicts: ' + data.conflicts : '';
				});
				if($scope.numType)
					$scope.dirNum.numtype = $scope.numType;
				console.log('scope.numCahnge: ' + $scope.anyChange);
				if($scope.anyChange)
					 $scope.anyChange({field: 'num'});
			};
			$scope.descrChange = function() {
				console.log('scope.descrCahnge: ' + $scope.anyChange);
				if($scope.anyChange)
					 $scope.anyChange({field: 'descr'});
			};
		},
	}
});

dyatelControllers.controller('UserDetailCtrl', function($scope, $routeParams, $http, $location, $modal, $filter) {
	$scope.possibleBadges = [ 'admin', 'finance' ];
	$scope.badges = { };
	if($routeParams.userId == 'new') {
		$scope.existingUser = false;
		$scope.title += 'New user';
	} else {
		$http.get('/a/users/' + $routeParams.userId).success(function(data) {
			$scope.user = data.user;
			$scope.existingUser = true;
			$scope.user.badges.forEach(function(b) {
				$scope.badges[b] = true;
			});
			$scope.navigation = data.navigation;
			$scope.Title.set(data.user.num.num + ': ' + data.user.num.descr);
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
		$scope.user.badges = [ ];
		$scope.possibleBadges.forEach(function(b) {
			if($scope.badges[b])
				$scope.user.badges.push(b);
		});
		$http({
			url: $scope.existingUser ? '/a/users/' + $routeParams.userId : '/a/users/create',
			method: "POST",
			data: $.param({
				num: $scope.user.num.num,
				descr: $scope.user.num.descr,
				alias: $scope.user.alias,
				domain: $scope.user.domain,
				password: $scope.user.password,
				nat_support: $scope.user.nat_support,
				nat_port_support: $scope.user.nat_port_support,
				media_bypass: $scope.user.media_bypass,
				dispname: $scope.user.dispname,
				login: $scope.user.login,
				badges: $scope.user.badges,
//				fingrp: $scope.user.fingrp,
				secure: $scope.user.secure,
				save: 1,
			}, true), // use jQuery to url-encode object
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
			$location.path('/users/' + data.user.id);
		}).error(function (data, status, headers, config) {
			alert('Error: ' + status + "\n" + data);
		});
	};
	$scope.deleteUser = function() {
		$http({
			url: '/a/users/delete?uid=' + $routeParams.userId,
			method: "POST",
			data: "delete=1",
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
			alert('User deleted');
			$location.path('/users');
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

	$scope.editOthernums = function() {
		var modalInstance = $modal.open({
			templateUrl: '/static/p/user_morenums.htm',
			controller: function($scope, $modalInstance, uid) {
				$http.get('/a/morenums/list?uid=' + uid).success(function(data) {
					$scope.myData = data.rows;
				});
				$scope.selection = [ ];
				$scope.gridOptions = {
					data: 'myData',
					columnDefs: [
					  { field: 'numkind.descr', displayName: 'Kind' },
						{ field: 'val', displayName: 'Number' },
						{ field: 'descr', displayName: 'Description' },
						{ field: null, displayName: 'Divertion', cellTemplate: '<i show="row.getProperty(\'div_offline\')" divertion-icon="offline" ></i> <i show="row.getProperty(\'div_noans\')" divertion-icon="noans" ></i><span ng-show="row.getProperty(\'div_noans\')">{{row.getProperty(\'timeout\')}}</span>' },
					],
					showFilter: true,
					multiSelect: false,
					selectedItems: $scope.selection,
				};
				$scope.ok = function () {
					$modalInstance.close($scope.selected.item);
				};
				$scope.cancel = function () {
					$modalInstance.dismiss('cancel');
				};
			},
			resolve: {
				uid: function () {
					return $routeParams.userId;
				}
			},
		});
	};

	$scope.editBLFs = function() {
		var modalInstance = $modal.open({
			templateUrl: '/static/p/user_blfs.htm',
			controller: function($scope, $modalInstance, items) {
				$scope.items = items;
				$scope.ok = function () {
					$modalInstance.close($scope.selected.item);
				};
				$scope.cancel = function () {
					$modalInstance.dismiss('cancel');
				};
			},
			resolve: {
				items: function () {
					return $scope.items;
				}
			}
		});
	};

	$scope.usersSource = function(a) {
		var url = '/a/users/list?' + $.param({ q: a }, true); // use jQuery to url-encode object
		return $http.get(url).then(function (response) {
//		console.log('response: ' + angular.toJson(response));
			var users = $filter('filter')(response.data.users, a);
			return $filter('limitTo')(users, 15).map(function(a) { return {
				id: a.id,
				label: a.num.num + ' ' + a.num.descr,
			}});
		});
	};
	$scope.userSelectionDone = function(item) {
//	console.log('selected: ' + angular.toJson(item));
		$location.path('/users/' + item.id).replace();
	};
});

dyatelControllers.controller('UsersListCtrl', function($scope, $http, $timeout, $filter) {
	$scope.filterOptions = {
		filterText: "",
		useExternalFilter: true,
	};
	$scope.$watch('filterOptions', function (newVal, oldVal) {
		if (newVal !== oldVal) {
			$scope.updateResults();
		}
	}, true);
	$scope.updateResults = function() {
		if($scope.getDataTimeout)
			$timeout.cancel($scope.getDataTimeout);
		$scope.getDataTimeout = $timeout(function() {
			$scope.getData();
		}, 500);
		$scope.$on('$destroy', function() {
			$timeout.cancel($scope.getDataTimeout);
		});
	};
	$scope.getData = function() {
		var q = $scope.filterOptions.filterText ? '?' + $.param({ q: $scope.filterOptions.filterText }, true) : '';
		$http.get('/a/users/list' + q).success(function(data) {
			//$scope.myData = data.users;
			$scope.myData = $filter('filter')(data.users, $scope.filterOptions.filterText);
		});
	};
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'num', displayName:'Number', cellTemplate: '<a ng-href="#/users/{{row.getProperty(\'id\')}}">{{row.getProperty(col.field).num}}</a>', width:'10%'},
			{             displayName:'Name', cellTemplate: '<a ng-href="#/users/{{row.getProperty(\'id\')}}">{{row.getProperty(\'num\').descr}}</a>', width:'58%'},
			{field:'login', displayName:'Login', width:'15%'},
			{field:'badges', displayName:'Badges', cellTemplate: '<span><div class="mybadge" ng-repeat="b in row.getProperty(\'badges\')">{{b}}</div></span>', width:'15%'},
		],
		filterOptions: $scope.filterOptions,
//		showFilter: true,
	};
	$scope.getData();
});


/* * * * * * * * * * Call Groups * * * * * * * * * */

dyatelControllers.controller('CallGroupsListCtrl', function($scope, $http) {
	$http.get('/a/cgroups/list').success(function(data) {
		$scope.myData = data.rows;
	});
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


/* * * * * * * * * * IVR * * * * * * * * * */

function dyatelIvrCommonController($scope, $http, urlBase) {
	$scope.selection = [ ];
	$http.get(urlBase + 'list').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'num.num', displayName:'Number', width:'20%'},
			{field:'num.descr', displayName:'Description'},
		],
		multiSelect: false,
		selectedItems: $scope.selection,
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
	};
	$scope.onNew = function() {
		var newRow = { id: 'create', num: {num:'', numtype:'ivr', desc:''}, changed: true };
		$scope.myData.push(newRow);
		var index = $scope.myData.indexOf(newRow);
		console.log('index: ' + index);
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
			num: $scope.selection[0].num.num,
			descr: $scope.selection[0].num.descr,
		};
		$.each($scope.selection[0], function(key, value) { // XXX depends on jQuery
				if(key === 'id' || key === 'changed' || key === 'num')
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
}

dyatelControllers.controller('IvrAAsCtrl', function($scope, $http) {
	dyatelIvrCommonController($scope, $http, '/a/ivr/aa/');
});

dyatelControllers.controller('IvrMDsCtrl', function($scope, $http) {
	dyatelIvrCommonController($scope, $http, '/a/ivr/md/');
});

/* CDR */

dyatelControllers.controller('CdrsCtrl', function($scope, $http) {
	$scope.filter = { empty: true };
	$scope.selection = [ ];
	$scope.calllog = [ ];
	$scope.totalServerItems = 0;
	$scope.pagingOptions = {
		pageSizes: [100, 200, 500, 1000, 2000],
		pageSize: 500,
		currentPage: 1
	};
	$scope.getData = function() {
		var query = $.param($scope.filter, true); // use jQuery to url-encode object
		$http.get('/a/cdrs/list?page=' + $scope.pagingOptions.currentPage + '&perpage=' + $scope.pagingOptions.pageSize + '&' + query).success(function(data) {
			$scope.myData = data.rows;
			$scope.totalServerItems = data.totalrows;
			if (!$scope.$$phase) {
				$scope.$apply();
			}
		});
	};
	$scope.$watch('pagingOptions', function (newVal, oldVal) {
		if (newVal !== oldVal && newVal.currentPage !== oldVal.currentPage) {
			$scope.getData();
		}
	}, true);
	$scope.$watch('selection', function (newVal, oldVal) {
		if (newVal[0] && newVal[0].billid) {
			$http.get('/a/cdrs/calllog/' + newVal[0].billid).success(function(data) {
				$scope.calllog = data.rows;
			});
		} else {
			$scope.calllog = [ ];
		}
	}, true);
	$scope.formatCalled = function(row) {
		var c = row.getProperty('called');
		var f = row.getProperty('calledfull');
		if(null === f || f.length === 0 || c === f)
			return c;
		if(c.length + f.length <= 10)
			return c + ' (' + f + ')';
		return '<abbr title="' + f + '">' + c + '</abbr>';
	};
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
//			{field:'id', displayName:'id'},
			{field:'ts', displayName:'Timestamp', cellTemplate:'<abbr title="{{row.getProperty(\'ts\')}}">{{row.getProperty(\'ts\').substr(11,8)}}</abbr>' },
			{field:'chan', displayName:'Channel', cellTemplate:"<span>{{row.getProperty('chan')}}  <abbr class=\"pull-right\" title=\"{{row.getProperty('direction')}}\">{{ {'incoming':'&lt;&lt;&lt;', 'outgoing':'&gt;&gt;&gt;'}[row.getProperty('direction')] }}</abbr></span>" },
			{field:'address', displayName:'Address'},
//			{field:'direction', displayName:'Direction'},
			{field:'billid', displayName:'Billid'},
			{field:'caller', displayName:'Caller'},
			{displayName:'Called', cellTemplate:'<div class="ngCellText" ng-bind-html="formatCalled(row) | unsafe"></div>'},
			{field:'duration', displayName:'Duration'},
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
	$scope.getData();
});

/* Status */

dyatelControllers.controller('StatusCtrlOverview', function($scope, $routeParams, $http) {
	$scope.data = [ ];
	var uri = '/a/status/overview';
	$scope.rp = $routeParams;
	if($routeParams.f)
		uri += '?filter=' + $routeParams.f;
	$http.get(uri).success(function(data) {
		$scope.data = data.result;
	});
});

dyatelControllers.controller('StatusCtrlModule', function($scope, $routeParams, $http) {
	$scope.data = [ ];
	$scope.colDefs = [ ];
	$scope.hist_length = 10;
	$http.get('/a/status/detail/' + $routeParams.module).success(function(data) {
		$scope.data = data.result[0];
		$scope.colDefs = $scope.data.format.map(function(x) {
			return { field: x };
		});
		$scope.colDefs.unshift({field: 'row_id'});
	});
	$scope.gridOptions = {
		data: 'data.rows',
		columnDefs: 'colDefs',
	};
});

dyatelControllers.controller('StatusCtrlNav2', function($scope, $routeParams, $cookieStore) {
	$scope.history = $cookieStore.get('statushistory');
	if($scope.history)
		$scope.history = $scope.history.filter(function(x) { return x && x != $routeParams.module });
	else
		$scope.history = [ ];
	if($routeParams.module)
		$scope.history.unshift($routeParams.module);
	while($scope.history.length > $scope.hist_length)
		$scope.history.pop();
	$cookieStore.put('statushistory', $scope.history);
});

/* Schedule */
dyatelControllers.directive('datepickerFormatString', function (dateFilter) {
	return {
		restrict: 'A',
		require: 'ngModel',
		priority: -100,
		link: function ($scope, element, attrs, ngModel) {
			var format = attrs.datepickerFormatString;
			if(!format)
				format = 'yyyy-MM-dd';
			ngModel.$parsers.unshift(function (val) {
				return dateFilter(val, format);
			});
		},
	};
});
dyatelControllers.directive('timepickerFormatString', function (dateFilter) {
	return {
		restrict: 'A',
		require: 'ngModel',
		priority: -100,
		link: function ($scope, element, attrs, ngModel) {
			var format = attrs.datepickerFormatString;
			if(!format)
				format = 'hh:mm:ss';
			ngModel.$parsers.unshift(function (val) {
				return dateFilter(val, format);
			});
		},
	};
});

dyatelControllers.controller('ScheduleCtrl', function($scope, $http) {
	$scope.myData = [ ];
	$scope.wdays = [ 'вс', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб' ];
	$scope.anymday = $scope.anywday = false;
	$http.get('/a/schedule/list').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.selection = [ ];
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{ field: 'prio', displayName: 'Priority' },
			{ field: 'mday', displayName: 'Start date' },
			{ field: 'days', displayName: 'Days' },
			{ field: 'dow',  displayName: 'Week days' },
			{ field: 'tstart', displayName: 'Start time' },
			{ field: 'tend', displayName: 'End time' },
			{ field: 'mode', displayName: 'Mode' },
//			{field:'num', displayName:'Number'},
//			{field:'', displayName:'', cellTemplate: '<a ng-href="#/cgroups/{{row.getProperty(\'id\')}}">{{row.getProperty(col.field)}}</a>'},
//			{field:'descr', displayName:'Description'},
		],
		multiSelect: false,
		selectedItems: $scope.selection,
	};
});

dyatelControllers.controller('ConfigCtrl', function($scope, $http) {
	$scope.defs = [ ];
	$scope.conf = { };
	$http.get('/a/config/defs').success(function(data) {
		$scope.defs = data.defs;
		$scope.defs.forEach(function(e) {
			e.isopen = false;
			$scope.conf[e.section] = { params: { } };
		});
	});
	$scope.loadGroup = function(sec) {
		console.log('Loading group ' + sec);
		$http.get('/a/config/section/' + sec).success(function(data) {
			$scope.conf[sec] = data.row ? data.row : { params: { } };
		});
	};
	$scope.saveGroup = function(sec) {
		console.log('Loading group ' + sec);
		$http({
			url: '/a/config/section/' + sec,
			method: "POST",
			data: $.param($scope.conf[sec].params, true), // use jQuery to url-encode object
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
		}).error(function (data, status, headers, config) {
			alert('Error: ' + status + "\n" + data);
		});
	};
});
dyatelControllers.controller('ConfigAccordionLoadingController', function($scope) {
	$scope.$watch('d.isopen', function(n, o) {
		if(n) {
			$scope.loadGroup($scope.d.section);
		}
	});
});


