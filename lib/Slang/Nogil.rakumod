use nqp;



sub mysub($a, $b) {
    say "Call my sub $a, $b";
}

sub EXPORT(|) {


role Nogil::Grammar {
    # No declarator -> my
    token scope_declarator:sym<nomy> {
        'nomy' <scoped('my')>
        { say "IN token nomy"; }
    }


    # Stolen from NQP::Grammar.nqp or Perl6::Grammar
    my %assignment := %('prec'=>'i=', 'assoc'=>'right');
    token infix:sym<=>  {
        <sym> <O(|%assignment, :op<mysub>)>  # P6store
        { say "My infix 1 is called"; }
    }

    #token infix:<=>(Mu \a, Mu \b) is raw {
    #    say "My infix 1 is called";
    #    nqp::p6store(a, b)
    #}
    # No sigil -> $
    #token sigil { <[$@%&]> | <nogil> }
    #token nogil { <?> }
}

role Nogil::Actions {
    # Required method finder
    sub lk(Mu \h, \k) { nqp::atkey(nqp::findmethod(h, 'hash')(h), k); }

    method infex:sym<=>($/) {
    }

    method scope_declarator:sym<nomy>($/) {
        nqp::say("No my");
        $*SCOPE = 'my';
        make $<scoped>.ast;
    }

    method nogil($/) {
        say 'Make no sigl';
        make '$';
    }

    #method declarator('') { return declarator('my'); }
}


$*LANG.define_slang(
    'MAIN',
    $*LANG.slang_grammar('MAIN').^mixin(Nogil::Grammar),
    $*LANG.slang_actions('MAIN').^mixin(Nogil::Actions),
);

{}

} # End export




=begin pod

=head1 NAME

Slang::Nogil - No-Si-gils !

=head1 SYNOPSIS


=head1 NOTES


In nqp/HLL/Actions.nqp:
    method O($/) {
        make %*SPEC;
    }

=end pod
