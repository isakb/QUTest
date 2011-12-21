**QUTest** is a *QUnit* based unit test runner. It was mainly created for
simplifying the execution of unit tests from the command line with
*phantomjs*.

# Running tests from the command line

In order to run tests with *phantomjs* from the commandline you need to
install *phantomjs* on your machine, and then run:  
`./run TESTFILE_1 [...[TESTFILE_N]]`


Instructions for building *phantomjs* are found there:
http://code.google.com/p/phantomjs/wiki/BuildInstructions

On *Mac* or *Windows*, you can use the binaries from here:
http://code.google.com/p/phantomjs/downloads/list

Your testcases should be written in *JavaScript* (or possibly compiled
from e.g. *CoffeeScript* to *JavaScript*) and can make use of either or
both of *QUnit* and *Pavlov*.


It's possible to customize ouput a bit, e.g.:  
`./run test*.js --show-colors=0 --show-page-console=1 --show-passed-tests=1`

(Check the CONFIG in `test-runner.coffee` for more possible configurations.)


# Running tests from any web browser

You can also run the tests from any browser.

Example: To run tests from *./example.js* and *./example2.js*, open this
URL in your web browser:

`file://` **pwd** `/test.html?injects=example.js,example2.js`

(Replace **pwd** with the full path to the current directory.)


For your convenience, when tests are executed with phantomjs from the
command line the test runner will also print the corresponding URL for
the tests, so that you can easily run the tests in your browser(s) as
well.

