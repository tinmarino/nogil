use lib 'lib';
use Slang::Nogil;
use Test;

plan 4;

my $a = 11;
is $a, 11, 'Yes sigil, Yes my';

my a = 12;
is a, 12, 'No sigil, Yes my';

# TODO $a = 11 and should be 12

$b = 13;
is $b, 13, 'Yes sigil, No my';

my €europe = 14;
is €europe, 14, 'European (€) sigil';

# TODO remove the nomy
#nomy c = 14;
#is c, 14, 'No sigil, No my';

#print = 15;


done-testing;
