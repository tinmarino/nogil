unit module Slang::Nogil::Nocomp;
no precompilation;
use MONKEY-TYPING;

augment class Array { 
    multi method AT-POS(Array:D: Int:D $pos where $pos < 0) {
        nextwith($pos + self.elems);
    }

    multi method ASSIGN-POS(Array:D: Int:D $pos, Mu \assignee where $pos < 0) {
        nextwith($pos + self.elems, assignee);
    }
}
