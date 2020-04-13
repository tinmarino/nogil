unit module Salng::Nogil::Augment;
use MONKEY-TYPING;

# Autodecl
augment class Any {
    method Str { '' }
    method Int { 0 }
}

# Index strings
augment class Str {
    method AT-POS($pos) is rw {
        return-rw Proxy.new:
            FETCH => -> $me { self.substr: $pos, 1 },
            STORE => -> $me, $x {
                $!value.substr-rw($pos, 1 ) = $x;
            };
    }
}
