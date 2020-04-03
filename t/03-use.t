use lib 'lib';
use Slang::Nogil;
use test-util;
use Test;

plan 3;

# use MONKEY
augment class Int {
    method is-answer { self == 212 }
}
ok 212.is-answer, 'Use monkey: can augment';

# use lib t/lib
is from-test-util, 'from test-util', 'Use lib t/lib';

# no strict
$not-strict = 42;
is $not-strict, 42, 'No strict';

# use experimental :macros :pack :cached
#my $called;
#macro called() {
#    $called++;
#    quasi { "Called" }
#};
#say called() ~ " $called times";
#say called() ~ " $called times";

done-testing;
