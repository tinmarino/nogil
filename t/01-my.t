use lib 'lib';
use Slang::Nogil;
use test-util;
use Test;

my $a = 11;
is $a, 11, 'Yes sigil, Yes my';

my a = 12;
is a, 12, 'No sigil, Yes my';

# TODO $a = 11 and should be 12

$b = 13;
is $b, 13, 'Yes sigil, No my';

# TODO remove the my
my c = 14;
is c, 14, 'No sigil, No my';

sub fct(Str param) {
    return param ~ 'fctfy';
}
is fct('arg'), 'argfctfy', 'No sigil: function parameters';

# use MONKEY
augment class Int {
    method is-answer { self == 42 }
}
ok 42.is-answer, 'Use monkey: can augment';

# use lib t/lib
is from-test-util, 'from test-util', 'Use lib t/lib';
# use experimental :macros :pack :cached
#my $called;
#macro called() {
#    $called++;
#    quasi { "Called" }
#};
#say called() ~ " $called times";
#say called() ~ " $called times";

