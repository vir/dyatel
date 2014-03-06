var dyatelCommon = angular.module('dyatelCommon', [ 'ngSanitize' ]);

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

