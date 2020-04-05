use lib 'lib';
use Slang::Nogil;
use Test;

plan :skip-all<For dev only>;

local = "value";
say local;

sub fct(param) {
    say param;
}
fct("argument");
