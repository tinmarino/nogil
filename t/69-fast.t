use lib 'lib';
use Slang::Nogil;
use Test;

plan :skip-all<For dev only>;

sub ident { say "In "; return 12; }
ident = 42;
say ident;
