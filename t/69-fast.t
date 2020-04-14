use lib 'lib';
use lib 't/lib';
use Test;
use Slang::Nogil;
#use TestUse;

plan :skip-all<Dev tests>;
# Multi method works but not proto method

# Multi
class Obj {
    proto method work(|) {*}
    multi method work(toto) { say 1 };
}
obj = Obj.new;
obj.work(1);
