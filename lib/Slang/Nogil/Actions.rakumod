unit module Slang::Nogil::Actions;
use Slang::Nogil::Util;
use QAST:from<NQP>;
use nqp;

role NogilActions is export {
    LEAVE {
        #= Pragma at runtime
        $*W.do_pragma('', 'strict', 0, ());
        $*W.do_pragma('', 'MONKEY', 1, ());
        $*W.do_pragma('', 'lib', 1, nqp::list('.'.IO, 'lib'.IO, 't'.IO, 't/lib'.IO));
    }

    method variable(Mu $/){
        # Play change, TODO this destroys the % & sigils
        my $sigil = str-key($/, 'sigil') || '$';
        sk($/, 'sigil', $sigil);
        $/ := $/.^mixin(Sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        nextwith($/);
    }

    method sigil(Mu $/){ return $/.^mixin(Sigilizer); }

    method term:sym<name>(Mu $/) {
        my ($longname, @types) = longname-n-type($/);
        my $args = lk($/, 'args');

        # If Existing as Routine or Sigless -> Nothing to do
        if (SUB, SLE) ∩ @types { nextsame }

        # Sigilize me
        return QAST::Var.new(:node($/), :name('$' ~ $longname) );
    }


    method postcircumfix:sym<[ ]>(Mu $in) {
        #= Authorize @arr[-1]
        if $in and my $semilist := lk($in, 'semilist') {
            sk($in, 'semilist', $semilist.^mixin(Positiver));
        }
        nextsame;
    }
}
