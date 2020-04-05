use lib 'lib';
use Slang::Nogil;
use Test;

plan :skip-all<Current known bugs>;

# 1
# Autovivication is creating Any, I want ''
# is not-existing1, '', 'Aucovivicate: start with ""';

# 2
# Scope if parameter has the same name as lexical varaible higher, it should hide it

# 3 Conflict
# TODO thinking it is a FCT
# A real assignement 
# sub ident { return 'function'; }
#ident = 'scalar2';

# 3 conflifct cannot assign a function. Think about what to do
#sub ident { return 'function'; }
#ident = 'scalar';


# Idea: Add to tests
# Warning statemetn in sink context, list afectation in sink context
# Pb : I don't know how to  catch compile warning
