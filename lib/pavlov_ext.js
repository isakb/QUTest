(function() {
    'use strict';

    var adapterMethods = {
        compile: pavlov.adapter.compile
    };

    pavlov._examples = [];

    // Extend pavlov in order to expose loaded examples, under pavlov._examples
    pavlov.util.extend(pavlov.adapter, {
        compile: function(suiteName, examples) {
            var parseExamples = function(examples, prefix) {
                prefix = prefix || '';

                pavlov.util.each(examples, function() {
                    pavlov._examples.push(prefix + this.name);
                    if (this.children && this.children.length) {
                        parseExamples(this.children, prefix + this.name);
                    }
                });
            };

            parseExamples(examples);
            return adapterMethods.compile(suiteName, examples);
        }
    });

    // Extend pavlov to assert a namespace has all of its methods tested
    pavlov.extendAssertions({
        isFullyTested: function(actual, expected, message) {
            var example = this,
                result = true,
                namespace = actual,
                namespaceName,
                methodsNotTested = [],
                _ = window.Klarna._;

            expected = expected || [];
            if (namespace instanceof Array) {
                namespaceName = namespace[1];
                namespace = namespace[0];
            } else {
                namespaceName = namespace._namespace || 'unknown';
            }

            if (!_.contains(pavlov._examples, namespace._namespace)) {
                methodsNotTested.push(namespaceName);
            } else {
                _.each(namespace, function(value, key) {
                    if (typeof value === 'function') {
                        if (!_.contains(pavlov._examples, namespaceName + '.' + key)) {
                            methodsNotTested.push(key);
                        }
                    }
                });
            }

            methodsNotTested = _.difference(methodsNotTested, expected);

            if (methodsNotTested.length) {
                _.each(methodsNotTested, function(method) {
                    var required = 5,
                    i = required;

                    // Create some pressure.
                    // If no tests have been defined for a method,
                    // require at least [require] as penalty.
                    while (i--) {
                        example.fail('.' + method + ' is missing ' + required + ' tests');
                    }
                });
            } else {
                this.pass(message);
            }
        }
    });

})();
