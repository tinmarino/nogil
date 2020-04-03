use lib 'lib';
use Slang::Nogil;
use Test;

plan 8;

my $sigil = 11;
is $sigil, 11, 'Yes sigil, Yes my';

my a = 12;
is a, 12, 'No sigil, Yes my';
a = 12.1;
is a, 12.1, 'No sigil, reassginment';
is $a, 12.1, 'No sigil, binds to $';
is "interpol $a", "interpol 12.1", 'No sigil, interpolation';

# This one is Undecalred routine
#b = 12.3;

$b = 13;
is $b, 13, 'Yes sigil, No my';


my x1 = 13; my x2 = 12;
is x1 + x2, 25, 'Sum';


#my ($c, $d) = 14, 15;
#is $c, 14, 'Tuple assign 1';
#is $d, 15, 'Tuple assign 2';


my €europe = 15;
is €europe, 15, 'European (€) sigil';

# TODO remove the nomy
#nomy c = 14;
#is c, 14, 'No sigil, No my';

#print = 15;


done-testing;
