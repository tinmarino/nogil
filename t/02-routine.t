use lib 'lib';
use Slang::Nogil;
use test-util;
use Test;

plan 6;


# Funtion
sub fct-sig-ntype($param2) {
    return $param2 ~ 'fctfy2';
}
is fct-sig-ntype('arg2'), 'arg2fctfy2', 'Function parameters: YES sigil, NO type constraint';

sub fct-sig-type(Int $param-int) {
    return $param-int;
}
is fct-sig-type(201), 201, 'Function parameters: YES sigil, YES type constraint';

sub fct-nsig-ntype(param3) {
    return param3 ~ '-fctfy-nsig-ntype';
}
is fct-nsig-ntype('arg'), 'arg-fctfy-nsig-ntype', 'Function parameters: NO sigl, NO type constraint';

sub fct-nsig-type(Str param4) {
    return param4 ~ '-fctfy-nsig-type';
}
is fct-nsig-type('arg'), 'arg-fctfy-nsig-type', 'Function parameters: NO sigl, NO type constraint';


# Class member and method
class TropLaClass {
    has member;
    method join(a, b) { return a ~ b; }
    method add(Int a) { return a + 1; }
}

my trop-la-class = TropLaClass.new;
is trop-la-class.join(2, 3), "23", 'Method parameters: YES type';
is trop-la-class.add(21), 22, 'Method parameters: NO type';


done-testing;
