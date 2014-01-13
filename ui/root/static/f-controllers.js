
var ctrlrModule = angular.module('userControllers', [ 'ngGrid' ]);

function typicalController(url, columnDefs, $scope, $http, cb) {
	$http.get(url).success(function(data) {
		$scope.myData = data.rows;
		if(cb)
			cb();
	});
	$scope.sel = [ ];
	$scope.gridOptions = {
		data: 'myData',
		columnDefs: columnDefs,
		showFilter: true,
		multiSelect: false,
		selectedItems: $scope.sel,
	};

	$scope.bSave = function() {
		$scope.sel[0].action = 'save';
		$http({
			url: url,
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
			url: url,
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
}

ctrlrModule.controller('NavbarCtrl', function($scope, $http) {
	$http.get('/id').success(function(data) {
		$scope.user = data;
	});
});

ctrlrModule.controller('HomePageCtrl', function($scope, $http) {
});

ctrlrModule.controller('PricesCtrl', function($scope, $http) {
	typicalController('/f/prices', [
		{field:'pref', displayName:'Префикс'},
		{field:'descr', displayName:'Описание'},
		{field:'price', displayName:'Цена', cellTemplate: '<span>{{ row.getProperty(col.field) }}</span>'},
	], $scope, $http);
});

ctrlrModule.controller('ReportsCtrl', function($scope, $http) {
});


ctrlrModule.controller('GroupsCtrl', function($scope, $http) {
	$scope.noGroup = [ ];
	var putUsers = function() {
		$scope.users.forEach(function(u) {
			if(u[3]) {
				$scope.grpMap[u[3]].members.push(u);
			} else {
				$scope.noGroup.push(u);
			}
		});
	};

	typicalController('/f/groups', [
		{field:'name', displayName:'Название'},
		{field:'sortkey', displayName:'Ключ сортировки'},
		{field:'members', displayName:'Сотрудники', cellTemplate: '<span><span class="member" ng-repeat="m in row.getProperty(col.field)">{{m[1]}}</span></span>'},
	], $scope, $http, function() {
		$scope.grpMap = { };
		$scope.myData.forEach(function(x) {
			x.members = [ ];
			$scope.grpMap[x.id] = x;
		});
		if($scope.users)
			putUsers();
	});
	$http.get('/f/users').success(function(data) {
		$scope.users = data.rows;
		$scope.usrMap = { };
		$scope.users.forEach(function(u) {
			$scope.usrMap[u[0]] = u;
		});
		if($scope.grpMap)
			putUsers();
	});
	$scope.onDrop = function(from, toGrp) {
		var fromGrp = from[0];
		var uid = from[1];
//		alert('onDrop user ' + uid + ' from grp ' + fromGrp + ' to ' + toGrp);
		if(fromGrp == toGrp)
			return;
		$http({
			url: '/f/groups',
			method: "POST",
			data: $.param({
				action: 'setGroup',
				uid: uid,
				grp: toGrp,
			}, true), // use jQuery to url-encode object
			headers: {'Content-Type': 'application/x-www-form-urlencoded'}
		}).success(function (data, status, headers, config) {
			var u = $scope.usrMap[uid];
			var srcColl = fromGrp ? $scope.grpMap[fromGrp].members : $scope.noGroup;
			var dstColl = toGrp ? $scope.grpMap[toGrp].members : $scope.noGroup;
			var idx = srcColl.indexOf(u);
			dstColl.push(srcColl.splice(idx, 1)[0]);
		}).error(function (data, status, headers, config) {
			alert('Error: ' + status);
		});
	};
	/*
	$scope.dropSuccessHandler = function(ev, idx, grp, uid) {
		alert('drop: ' + idx + 'th user with uid ' + uid + ' from group ' + grp);
	};
	*/
});


