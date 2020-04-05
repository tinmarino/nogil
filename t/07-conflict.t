use lib 'lib';
use Slang::Nogil;
use Test;

plan 11;

##################################################
# Name conflict
# Scalar
ident = 'scalar1';
is ident, 'scalar1', 'Nosig assign';
$ident = 'scalar2';
is ident, 'scalar2', 'Scalar assign';
is $ident, 'scalar2', 'Nosig same';

# Sub
sub ident { return 'function'; }
is &ident(), 'function', 'Function call';
is ident, 'function', 'Function precedence';

# Arr
@ident = 'arr' xx 2;
is @ident, ('arr', 'arr'), 'Array assgin';

# Hash
%ident = <a 1 b 2>;
is %ident, %(a=>1, b=>2), 'Hash assign';

# Sigless (priority over fct)
sigless = 'scalar';
is sigless, 'scalar', 'Nogsig';
my \sigless = 'sigless';
is sigless, 'sigless', 'Sigless';

# Sigless with container (overwriten by a scalar, default behavior)
cont = 'scalar';
my \cont = $ = 'container';
is cont, 'container', 'Sigless container';
cont = 'scalar';
is cont, 'scalar', 'Sigless container is overwritten';
