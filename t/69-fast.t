use lib 'lib';
use Slang::Nogil;
use Test;

plan 0;

toto = 42;
toto = 43;
say 12 + toto;
say toto;

sub fct-nsig-ntype(param3) {
    say param3;
}
fct-nsig-ntype("azeaze");
