use lib 'lib';
use Slang::Nogil;
use Test;

plan 0;

my $azerty = 12;
say azerty, 42;

# TODO 
## Warning Use of uninitialized value $tup1 of type Any in string context.
#is ($tup1, $tup2), (tup1, tup2), 'Tuple with Vs without';

# New fail TODO Undeclared routine
#nomy = 12.1;
#is $nomy, 12.1, 'No sigil, reassginment';

# New fail TODO  Undeclared routine
#my x1 = 13; my x2 = 12;
#is x1 + x2, 25, 'Sum';
