
var dyatelControllers = angular.module('dyatelControllers', [ 'ngGrid' ]);

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

dyatelControllers.controller('UserDetailCtrl', function($scope, $routeParams, $http, $location, $modal) {
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


/* * * * * * * * * * IVR * * * * * * * * * */

dyatelControllers.controller('IvrAAsCtrl', function($scope, $http) {
	$scope.selection = [ ];
	$http.get('/a/ivr/aa/list').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'num', displayName:'Number'},
			{field:'descr', displayName:'Description'},
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
		var newRow = { id: 'create', changed: true };
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
		$scope.selection[0].action = 'save';
		$http({
			method: 'POST',
			url: '/a/ivr/aa/' + $scope.selection[0].id,
			data: $.param($scope.selection[0]), // XXX depends on jQuery
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function(data) {
			alert(angular.toJson(data));
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
				url: '/a/ivr/aa/delete',
				data: 'id=' + $scope.selection[0].id,
				headers: {'Content-Type': 'application/x-www-form-urlencoded'}
			}).success(delRow);
		}
	};
});

dyatelControllers.controller('IvrMDsCtrl', function($scope, $http) {
	$scope.selection = [ ];
	$http.get('/a/ivr/md/list').success(function(data) {
		$scope.myData = data.rows;
	});
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: [
			{field:'num', displayName:'Number'},
//			{field:'', displayName:'', cellTemplate: '<a ng-href="#/cgroups/{{row.getProperty(\'id\')}}">{{row.getProperty(col.field)}}</a>'},
			{field:'descr', displayName:'Description'},
		],
		multiSelect: false,
		selectedItems: $scope.selection,
	};
});

/* CDR */

dyatelControllers.controller('CdrsCtrl', function($scope, $http) {
/*	$http.get('/a/cdrs/list').success(function(data) {
		$scope.myData = data.rows;
	});
	*/
	$scope.selection = [ ];
	$scope.totalServerItems = 0;
	$scope.pagingOptions = {
		pageSizes: [250, 500, 1000],
		pageSize: 250,
		currentPage: 1
	};
	$scope.getData = function(pageSize, page) {
		$http.get('/a/cdrs/list?page=' + page + '&perpage=' + pageSize).success(function(data) {
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
			{field:'called', displayName:'Called'},
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
	$scope.getData($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage);
});


