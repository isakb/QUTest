(function() {
    'use strict';

    var each,
        contains,
        indexOf,
        adapterMethods = {
            compile: pavlov.adapter.compile
        };

    each = function(obj, iterator) {
        return pavlov.util.each(obj, function(key, val) {
            iterator.call(this, val, key);
        });
    };
    indexOf = pavlov.util.indexOf = function(obj, target) {
        var result = -1,
            nativeIndexOf = Array.prototype.indexOf;
        if (obj == null) {
            return -1;
        }
        if (nativeIndexOf && obj.indexOf === nativeIndexOf) {
            return obj.indexOf(target);
        }
        each(obj, function(value, index) {
            if (value === target &&
                result === -1) {
                result = index;
            }
        });
        return result;
    };

    contains = pavlov.util.contains = function(obj, target) {
        return (indexOf(obj, target) !== -1);
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
                methodsNotTested = [];

            expected = expected || [];
            if (namespace instanceof Array) {
                namespaceName = namespace[1];
                namespace = namespace[0];
            } else {
                namespaceName = namespace._namespace || 'unknown';
            }

            if (!contains(pavlov._examples, namespace._namespace)) {
                methodsNotTested.push(namespaceName);
            } else {
                each(namespace, function(value, key) {
                    if (typeof value === 'function') {
                        if (!contains(pavlov._examples, namespaceName + '.' + key)) {
                            methodsNotTested.push(key);
                        }
                    }
                });
            }

            each(methodsNotTested, function(method) {
                var i = indexOf(expected, method);
                if (i !== -1) {
                    methodsNotTested.splice(i, 1);
                }
            });

            if (methodsNotTested.length) {
                each(methodsNotTested, function(method) {
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
