**QUTest** is a *QUnit* based unit test runner. It was mainly created for
simplifying the execution of unit tests from the command line with
*phantomjs*.

# Running tests from the command line

In order to run tests with *phantomjs* from the commandline you need to
install *phantomjs* on your machine, and then run:  
`./run TESTFILE_1 [...[TESTFILE_N]]`

For example:
`./run example-test-*`

Instructions for building *phantomjs* are found there:
http://code.google.com/p/phantomjs/wiki/BuildInstructions

On *Mac* or *Windows*, you can use the binaries from here:
http://code.google.com/p/phantomjs/downloads/list

Your testcases should be written in *JavaScript* (or possibly compiled
from e.g. *CoffeeScript* to *JavaScript*) and can make use of either or
both of *QUnit* and *Pavlov*.


It's possible to customize ouput a bit, e.g.:  
`./run example-test-*.js --show-colors=0 --show-passed-tests=1`

(Check the CONFIG in `test-runner.coffee` for more possible configurations.)


# Running tests from any web browser

You can also run the tests from any browser.

(For your convenience, when tests are executed with phantomjs from the
command line the test runner will also print the corresponding URL for
the tests, so that you can easily run the tests in your browser(s) as
well.)

To run the bundled test examples, open this URL in your web browser:

`file://`**cwd**`/test.html?injects=example-test-qunit.js,example-test-pavlov.js`
(**cwd** should be the full path to the current directory.)

For your convenience, run something like this from your terminal:
`x-www-browser file://$(pwd)/test.html?injects=$(echo *.js | tr ' ' ,)`

Replace *x-www-browser* with *open* in OS X.


# Testing QUTest

QUTest itself is automatically tested on BuildHive.

[![Build Status](https://buildhive.cloudbees.com/job/isakb/job/QUTest/badge/icon)](https://buildhive.cloudbees.com/job/isakb/job/QUTest/)