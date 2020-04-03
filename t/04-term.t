use lib 'lib';
use Slang::Nogil;
use Test;

plan 4;
my sigless = 10;
is $sigless + 1, 11, 'Op: Sigiless + 1';
is $sigless + sigless * 2 + 1, 31, 'Op: Sigiless + sigless * 2 + 1';

my x1 = 13; my x2 = 12;
is x1 + x2, 25, 'Op: x1 + x2';

my ($tup1, $tup2) = (1,2), (3, 4);
is (tup1, $tup2), ($tup1, tup2), 'My: Tuple with Vs without';

# TODO 1
## Assign tuple without sigil
## Warning Use of uninitialized value $tup1 of type Any in string context.
#my (typ1, tup2) = (1,2), (3, 4);
#is ($tup1, $tup2), (tup1, tup2), 'Tuple with Vs without';

# TODO nomy fails
