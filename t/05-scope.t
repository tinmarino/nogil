use lib 'lib';
use Slang::Nogil;
use Test;

plan :skip-all<Current known bugs>;
;

# 1
# Autovivication is creating Any, I want ''
# is not-existing1, '', 'Aucovivicate: start with ""';

# 2
# Scope if parameter has the same name as lexical varaible higher, it should hide it
