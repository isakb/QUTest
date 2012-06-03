#!/bin/bash

cd `dirname $0`
. tap-functions
cd ..

plan_no_plan

#
# No color output
#
diag "Simple no-color tests with example-test-pavlov.js"
output=`./run example-test-pavlov.js \
            --show_colors=false`

like "$output" \
     "10 / 11 assertions ok, in [0-9]+ ms\." \
     "output assertion summary"

like "$output" \
    "10 / 11 testcases passed \(0 with warnings\); 1 testcases failed." \
    "output testcase summary"

like "$output" \
    "\[FAIL\] A feature .+ 'Not Implemented' if .+" \
    "output failed testcase"

unlike "$output" \
    "\[PASS\]" \
    "don't output passed testcases"
#
# Color
#
diag "Color tests, also passed, with example-test-pavlov.js"
output=`./run example-test-pavlov.js \
            --show_passed_tests=true \
            --show_colors=true \
        | tr "\n" "%"`

like "$output" \
     "10 / 11 assertions ok, in [0-9]+ ms\." \
     "output assertion summary in red color"

like "$output" \
    "10 / 11 testcases passed \(0 with warnings\); 1 testcases failed." \
    "output testcase summary in red color"

like "$output" \
    "\[31m\[FAIL\] A feature .+\[0m" \
    "output failed testcase info in red color"

like "$output" \
    "\[PASS\]" \
    "also output passed testcases"

#
# Only passing tests
#
diag "Testing with example-test-qunit-only-passing.js"
output=`./run example-test-qunit-only-passing.js \
            --show_colors=true \
        | tr "\n" "%"`

like "$output" \
    "\[32m%6 / 6 assertions ok.+\[0m" \
    "output assertion summary in green color"

like "$output" \
    "\[32m%[^%]+%3 / 3 testcases passed.+\[0m" \
    "output testcase summary in green color"

#
# Many files at once, more details
#
diag "Testing with many files (*.js). Show more details about failures."
output=`./run *.js \
            --show_colors=false \
            --show_passed_tests=false \
            --show_details=true \
        | tr "\n" "%"`

like "$output" \
    "378 / 391 assertions ok" \
    "assertion summary correct; all assertions run"

like "$output" \
    "46 / 55 testcases passed \(0 with warnings\); 9 testcases failed\." \
    "testcase summary correct; all testcases run"

like "$output" \
    "↪ each test .+%        ✘ url from .+, Expected: .+; Actual: .+%        ✘ Expected " \
    "show failing testcases' assertions"

unlike "$output" \
    "✔ OK" \
    "don't include details about valid assertions"

#
# Even more details
#
diag "Testing with many files (*.js). More details also about valid assertions."
output=`./run *.js \
            --show_colors=false \
            --show_passed_tests=true \
            --show_details=true \
        | tr "\n" "%"`

like "$output" \
    "✔ OK" \
    "include details about valid assertions"