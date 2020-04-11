use lib 'lib';
use Slang::Nogil;
use Test;

plan 15;

# Old declaration
my $sigil = 11;
is $sigil, 11, 'Yes sigil, Yes my';

# Basic declaration
my sigless = 12;
is sigless, 12, 'No sigil, Yes my';
is $sigless, 12, 'No sigil, same';
is "interpol $sigless", "interpol 12", 'No sigil, interpolation';

# Without my
$b = 13;
is $b, 13, 'Yes sigil, No my';
is b, 13, 'No sigil, same';

# Tuple assignment
my (tup1, tup2) = (14, 15, 'str'), 16;
is tup1, (14, 15, 'str'), 'Tuple assign 1';
is tup2, 16, 'Tuple assign 2';

# Array
my arr = (1, 2, 3, 4);
is arr, (1, 2, 3, 4), 'Array assign';
is $arr, arr, 'Array with, without sigil';

# Hash
my hsh = %(1=>2, 3=>4);
is hsh, %(1=>2, 3=>4), 'Hash assign';
is hsh, $hsh, 'Hash without, with sigil';

# European sigil (jsut for fun)
my €europe = 15;
is €europe, 15, 'European (€) sigil';

# Autodeclare
## Int
res-int = ++auto-int + ++auto-int + ++auto-int; # 1 + 2 + 3
is res-int, 6, 'Autodeclare: Int';
## Str
res-str = "a" ~ auto-str ~ "b";
is res-str, 'ab', 'Autodeclaratino: Str';


done-testing;
