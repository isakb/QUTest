(function(window) {
    'use strict';

    /**
     * Inject a javascript file (with testcases) into the document, in
     * order to execute the testcases.
     *
     * @param   {String}   tests comma-separated list of javascript filenames.
     * @returns {Function}       empty function (to silence phantomjs warning)
     */
    window._injectTests = function(tests) {
        var i, length, script;

        if (typeof tests !== 'string') {
            throw new Error('Bad argument');
        }
        tests = tests.split(',');
        for (i = 0, length = tests.length; i < length; i++) {
            script = document.createElement('SCRIPT');
            script.type = 'text/javascript';
            script.setAttribute('src', tests[i]);
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
