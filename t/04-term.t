use lib 'lib';
use Slang::Nogil;
use Test;

plan 11;

my sigless = 10;
is $sigless + 1, 11, 'Op: Sigiless + 1';
is $sigless + sigless * 2 + 1, 31, 'Op: Sigiless + sigless * 2 + 1';

my x1 = 13; my x2 = 12;
is x1 + x2, 25, 'Op: x1 + x2';

my ($tup1, $tup2) = (1,2), (3, 4);
is (tup1, $tup2), ($tup1, tup2), 'My: Tuple with Vs without';

nosig = 41;
is nosig, 41, 'NoMy nosig';
is nosig, $nosig, 'NoMy nosig: with Vs without';

## Assign tuple without sigil
my (tup1, tup2) = (1,2), (3, 4);
is (tup2, $tup1), ((3,4), (1,2)), 'Tuple My';
is ($tup1, $tup2), (tup1, tup2), 'with Vs without';

(  tup43   , tup44   ) =  (  '1'  ,   '2'), ('3',    '4');
is ($tup44, tup43), (('3', '4'), ('1', '2')), 'Tuple declaration no my';

strnum1 = "45"; strnum2 = '55';
is strnum1 + strnum2, 100, 'Aucoconvert';

newvar++;  # 1
newvar += 10;  # 11
newvar = newvar - 1; # 10
newvar = newvar * 10 + 2 * newvar - 20;  # 100;
is newvar, 100, 'Autovivivate in Arith';

done-testing;
