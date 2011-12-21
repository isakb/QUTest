module("example");

test("null should be null", function() {
    equal(null, null);
});

// Just to demonstrate failure
test("true should be false", function() {
    equal(true, false);
});
