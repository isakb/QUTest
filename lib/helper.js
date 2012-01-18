(function(window) {
    'use strict';
    var onWindowLoad = window.onload,
        document = window.document,
        QUnit = window.QUnit;

    QUnit.config.autostart = false;

    /**
     * Inject javascript files (with testcases) into the document, in
     * order to execute the testcases.
     *
     * @param   {Array}    tests array of script URLs
     */
    window._injectTests = function(tests) {
        var i, length, src, script, checkIfDone,
            numLoading = tests.length;

        checkIfDone = function(ieScript) {
            return function() {
                if (ieScript) {
                    // IE checks
                    if (ieScript.readyState !== 'loaded' &&
                        ieScript.readyState !== 'complete'){
                        return; // not really done yet.
                    }
                    ieScript.onreadystatechange = null;
                }
                numLoading -= 1;
                if (numLoading <= 0) {
                    QUnit.start();
                }
            };
        };

        for (i = 0, length = tests.length; i < length; i++) {
            src = tests[i];
            script = document.createElement('SCRIPT');
            script.type = 'text/javascript';
            if (script.readyState){ // Internet Exlorer
                script.onreadystatechange = checkIfDone(script);
            } else { // Other browsers
                script.onload = checkIfDone();
            }
            script.setAttribute('src', src);
            document.body.appendChild(script);
        }
    };

    /**
     * Check if test runner was requested with
     * ?injects={tests-to-be-injected}. Inject any such tests.
     */
    var injectTestsFromQueryString = function() {
        var qs = window.location.search || null;
        if (!qs) {
            return;
        }
        qs = /[?&]injects=([^&]+)/.exec(qs);
        if (qs) {
            window._injectTests(decodeURIComponent(qs[1]).split(','));
        }
    };

    window.onload = function() {
        if (onWindowLoad) {
            onWindowLoad.call(window);
        }
        injectTestsFromQueryString();
    };

})(this);
