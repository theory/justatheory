JSAN.addRepository('../lib').use('Test.Builder');
var test_num = 1;
// Utility testing functions.
var T = new Test.Builder();
T.plan({ tests: 2 });

var test = Test.Builder.create();
try { test.plan(7) }
catch (ex) {
    T.ok(ex.message.match(/plan\(\) doesn\'t understand 7/), 'bad plan()');
}

try { test.plan({wibble: 7}) }
catch (ex) {
    T.ok(ex.message.match(/plan\(\) doesn\'t understand wibble 7/), 'bad plan()');
}

// Hack to prevent "No tests run" message".
test.SkipAll = true;
