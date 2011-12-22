(function(window) {
    /*jshint browser:true*/
    /*global QUnit */
    'use strict';
    var maybeInjectTestsFromQueryString;

    var logs = ["begin", "testStart", "testDone", "log",
                "moduleStart", "moduleDone", "done"];
    var nothing = function() {};
    for (var i = 0; i < logs.length; i++) {
	//QUnit[logs[i]] = nothing;
    }

    /**
     * Check if test runner was requested with
     * ?injects={tests-to-be-injected}. Inject any such tests.
     */
    maybeInjectTestsFromQueryString = function() {
        var qs = window.location.search || null;
        if (!qs) {
            return;
        }
        qs = /[?&]injects=([^&]+)/.exec(qs);
        if (qs) {
            window._injectTests(decodeURIComponent(qs[1]));
        }

    };

    /**
     * Inject a javascript file (with testcases) into the document, in
     * order to execute the testcases.
     *
     * @param   {String}   tests comma-separated list of javascript filenames.
     * @returns {Function}       empty function (to silence phantomjs warning)
     */
    window._injectTests = function(tests) {
        var i, length, script, _onerror;

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

    maybeInjectTestsFromQueryString();
})(this);
