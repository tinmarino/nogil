use lib 'lib';
use Slang::Nogil;
use Test;
plan 1;

my ($tup1, $tup2) = (1,2), (3, 4);
is (tup1, $tup2), ($tup1, tup2), 'Tuple with Vs without';
