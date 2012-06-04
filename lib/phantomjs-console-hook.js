(function(window) {
    "use strict";

    window._phantomJSMessageQueue = [];

    ['moduleStart',
     'moduleDone',
     'testStart',
     'testDone',
     'log',
     'done'
    ].map(function(name) {
        window.QUnit[name](function(context) {
            context.action = name;
            window._phantomJSMessageQueue.push(context);
        });
    });

}(this));
