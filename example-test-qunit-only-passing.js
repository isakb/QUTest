test("something", function() {
    ok(true);
});

test("a couple of assertions", function() {
    ok(true);
    ok(true);
});

test("whatever", function() {
    ok(true, 'assertion 1');
    ok(true, 'assertion 2');
    ok(true, '... and the last assertion');
});