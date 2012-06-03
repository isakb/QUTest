#!/bin/bash

cd `dirname $0`
. tap-functions
cd ..

plan_no_plan

_simple() {
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
}

_color() {
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


    diag "Testing with example-test-qunit-only-passing.js"
    output=`./run example-test-qunit-only-passing.js \
                --show_colors=true \
            | tr "\n" "%"`

    like "$output" \
        "\[32m%6 / 6 assertions ok.+\[0m" \
        "output assertion summary in green color"

    like "$output" \
        "\[32m%[^%]+%3 / 3 testcases passed.+\[0m" \
        "output testacase summary in green color"

}


#_simple
_color

