(function(window) {
    'use strict';
    /*global QUnit*/

    var document = window.document,
        _load = QUnit.load;

    // Temporarily force QUnit to wait until we explicitly run
    // QUnit.load() later - when all our tests have loaded.
    QUnit.load = function() {};

    /**
     * Inject javascript files (with testcases) into the document, in
     * order to execute the testcases.
     *
     * @param   {String}   tests comma-separated list of script URLs
     * @returns {Function}       empty function (to silence phantomjs warning)
     */
    window._injectTests = function(tests) {
        var i, length, src, script, done, loading;
        if (typeof tests !== 'string') {
            throw new Error('Bad argument');
        }
        tests = tests.split(',');
        loading = tests.slice(0); // The files to load, that are not yet loaded.

        done = function(src, ieScript) {
            var idx;
            if (ieScript) {
                // IE checks
                if (ieScript.readyState !== 'loaded' &&
                    ieScript.readyState !== 'complete'){
                    return; // not really done yet.
                }
                ieScript.onreadystatechange = null;
            }
            idx = loading.indexOf(src);
            if (idx !== -1) {
                loading.splice(idx, 1);
            }
            if (loading.length === 0) {
                // All scripts are loaded; start running QUnit tests.
                QUnit.load = _load;
                QUnit.load();
            }
        };

        for (i = 0, length = tests.length; i < length; i++) {
            src = tests[i];
            script = document.createElement('SCRIPT');

            // Occasionally necessary acc. to Andrei's tests, but
            // might now work anyway?:
            script.type = 'text/javascript';

            if (script.readyState){ // Internet Exlorer
                script.onreadystatechange = done(src, script);
            } else { // Other browsers
                script.onload = done(src);
            }
            script.setAttribute('src', src);
            document.body.appendChild(script);
        }
        return function() {}; // phantomjs expects us to return a function
    };

    /**
     * Check if test runner was requested with
     * ?injects={tests-to-be-injected}. Inject any such tests.
     */
    var maybeInjectTestsFromQueryString = function() {
        var qs = window.location.search || null;
        if (!qs) {
            return;
        }
        qs = /[?&]injects=([^&]+)/.exec(qs);
        if (qs) {
            window._injectTests(decodeURIComponent(qs[1]));
        }
    };

    maybeInjectTestsFromQueryString();

})(this);
