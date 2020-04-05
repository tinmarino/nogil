use lib 'lib';
use Slang::Nogil;
use Test;

plan 2;

##################################################
# Sub
sub fct { return 61; }
is fct, 61, 'Routine ' ~ '-' x 20;

##################################################
# Sigless
my \sigless = 62;
is sigless, 62, 'Sigless ' ~ '-' x 20;
