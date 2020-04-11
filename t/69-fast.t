use lib 'lib';
use Slang::Nogil;
use Test;

plan :skip-all<For dev only>;

# Autodeclare Int
res-str = "a" ~ auto-str ~ "b";
say res-str;
