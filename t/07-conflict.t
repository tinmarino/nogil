use lib 'lib';
use Slang::Nogil;
use Test;

plan 18;

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
## Sub: and Nogil (get warning)
{
    sub ident2 { return 'function2'; }
    EVAL q/use Slang::Nogil; no strict; ident2 = 42;/;
    is ident2, 'function2', 'Function precedence order';
    CONTROL { when CX::Warn {
            ok .message ~~ / "Warn01" /, 'Warn01';
            .resume;
    } }
}
## Sub: param
param = 71;
sub fct(param){ return param }
is fct(12), 12, 'Function param scope inner';
is param, 71, 'Function param scope outer';

# Eval
{
    EVAL q/use Slang::Nogil; no strict; ident3 = 3;/;
    is ident3, '3', 'Eval1';
    {
        EVAL q/use Slang::Nogil; no strict; ident4 = 4;/;
        is ident4, '4', 'Eval2';
        {
            EVAL q/use Slang::Nogil; EVAL 'use Slang::Nogil; ident5 = 5;';/;
            is ident5, '5', 'Eval3';
        }
    }
}

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
