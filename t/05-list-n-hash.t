use lib 'lib';
use Slang::Nogil;
use Test;

plan 18;

##################################################
# Util
sub warns-like (&code, $test, Str $desc) {
    my ($did-warn, $message) = False;
    &code();
    CONTROL { when CX::Warn { $did-warn = True; $message = .message; .resume } }

    subtest $desc => {
        plan 2;
        ok $did-warn, 'code threw a warning';
        cmp-ok $message, '~~', $test, 'warning message passes test';
    }
}


##################################################
# List
is (1,2), (2,1).reverse, ().^name ~' ' ~ '-' x 20;

# Array decl
a = 51; b = 52;
my @a = (1, 2, 3); my @b = 1..3;
is @a, @b, 'Array sigil';
is (a, b), (51, 52), 'Keep nogil';

# Bad decl (nogig)
#= With Warning Useless use of constant integer in sink context because 2, 3, 4 useless (Nice).
EVAL q/use Slang::Nogil; v-last = 1, 2, 3, 4;/;
is v-last, 1, 'Assign coma nogil';
is v-last.WHAT, Int, 'Assign coma nogil, WHAT';

# Good decl, same name (array)
my @v-last = 1, 2, 3, 4;
is @v-last, (1,2,3,4), 'Assign coma array';

# List op
my @c = (1, 2) Z (3, 4);
a-zip = @c;
is @c, ((1, 3), (2, 4)), 'Zip operator: array';
is a-zip, (1,3 ; 2,4), 'Zip operator: nogil';

# Statement list
ok (42) eqv $(my $v51 = 42; $v51;), 'Statement in list: scalar';
ok (42) eqv $(v-in-list = 42; v-in-list;), 'Statement in list: nogil';


##################################################
# Hash
my %h1 = <a b c d e f>;
is %h1.keys.sort, ('a', 'c', 'e'), %().^name ~' ' ~ '-' x 20;

# Asign
%h-asgn = a => 'b', c => 'd', e => 'f';
is %h-asgn, %( a => 'b', c => 'd', e => 'f' ), 'Asign %';
# Warns sink context
EVAL q/use Slang::Nogil; h-asgn = a => 'b', c => 'd', e => 'f';/;
is h-asgn, %(a => 'b'), 'Asign nogil';
is h-asgn.WHAT, Pair, 'Asign nogil.WHAT -> Pair';
is %h-asgn, %( a => 'b', c => 'd', e => 'f' ), '% not changed';

# Containerize
h-cont = %(a => 'b', c => 'd', e => 'f');
is h-cont.WHAT, Hash, 'Hash container can be (nogil)';
is h-cont<a>, 'b', 'Associative indexing (nogil)';

# Slice Asign
h-slice<a b c> = 2 xx *;
is h-slice, {a => 2, b => 2, c => 2}, 'Slice Assign';


done-testing;
