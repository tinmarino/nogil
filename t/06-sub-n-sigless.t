use lib 'lib';
use Slang::Nogil;
use Test;

plan 7;

##################################################
# Util
var = 10;
is var, 10, 'Util ' ~ '-' x 20;


##################################################
# Sub
sub fct { return 61; }
is fct, 61, 'Routine ' ~ '-' x 20;

# Method and multi
class Obj {
    proto method work(|) {*}
    multi method work(1) {1}
    multi method work(2) {2}
    method no-param {61};
    method has-param(param) {param+62};
}
obj = Obj.new;
is obj.work(1), 1, 'Multi: method 1';
is obj.work(2), 2, 'Multi: method 2';
is obj.no-param, 61, 'Method: no param';
is obj.has-param(var), 72, 'Method: has param';


##################################################
# Sigless
my \sigless = 62;
is sigless, 62, 'Sigless ' ~ '-' x 20;
