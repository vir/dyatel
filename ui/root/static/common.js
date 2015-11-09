var dyatelCommon = angular.module('dyatelCommon', [ 'ngSanitize', 'ui.bootstrap.typeahead' ]);

dyatelCommon.filter('unsafe', function($sce) {
	return function(val) {
		return $sce.trustAsHtml(val);
	};
});

dyatelCommon.directive('focusMe', function ($timeout) {
	return {
		link: function (scope, element, attrs, model) {
			$timeout(function () {
				element[0].focus();
			});
		}
	};
});

dyatelCommon.filter('capitalize', function() {
	return function(input, scope) {
		return input.substring(0,1).toUpperCase()+input.substring(1);
	}
});

dyatelCommon.directive('markdown', function($sanitize) {
	var converter = new Showdown.converter();
	return {
		restrict: 'AE',
		link: function(scope, element, attrs, model) {
			if (attrs.markdown) {
				attrs.$observe('markdown', function(v) {
					element.html(v ? $sanitize(converter.makeHtml(v)) : '');
				});
			} else {
				element.html($sanitize(converter.makeHtml(element.text())));
			}
		},
	};
});

// http://uncorkedstudios.com/blog/multipartformdata-file-upload-with-angularjs
dyatelCommon.directive('fileModel', ['$parse', function ($parse) {
	return {
		restrict: 'A',
		link: function(scope, element, attrs) {
			var model = $parse(attrs.fileModel);
			var modelSetter = model.assign;
			element.bind('change', function(){
				scope.$apply(function(){
					modelSetter(scope, element[0].files[0]);
				});
			});
		}
	};
}]);

dyatelCommon.service('fileUpload', ['$http', function ($http) {
	this.uploadFileToUrl = function(file, uploadUrl, params){
		var fd = new FormData();
		console.log('file is ' + JSON.stringify(file));
		fd.append('file', file);
		if(params) {
			for (var k in params){
				if (params.hasOwnProperty(k)) {
					fd.append(k, params[k]);
				}
			}
		}
		return $http.post(uploadUrl, fd, {
			transformRequest: angular.identity,
			headers: {'Content-Type': undefined }
		});
	}
}]);

/* input with type="num" will have number selection typeahead */
dyatelCommon.directive('input', function($compile, $http) {
	var ds = function (a) {
		var url = '/u/phonebook/search?' + $.param({ q: a, loc: 1, more: 1, pvt: 1, com: 1 }, true); // use jQuery to url-encode object
		return $http.get(url).then(function (response) {
			return response.data.result.map(function(a) { return {
				num: a.num,
				label: a.num + ' ' + a.descr,
			}});
		});
	};
	return {
		restrict: 'E',
		terminal: true,
		priority: 1000,
		compile: function(element, attrs) {
			if(attrs.type != 'num')
				return;
			element.attr('typeahead', "x.num as x.label for x in numLookupDataSource($viewValue) | limitTo:20");
			element.attr('type', 'text');
			return {
				pre: function preLink(scope, iElement, iAttrs, controller) {  },
				post: function postLink(scope, iElement, iAttrs, controller) {
					scope.numLookupDataSource = ds; // Yes, i am adding it to parent scope. Shame on me.
					$compile(iElement)(scope);
				}
			};
		},
	};
});

