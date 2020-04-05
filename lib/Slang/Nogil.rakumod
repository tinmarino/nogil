use Slang::Nogil::Util;
use nqp;
use QAST:from<NQP>;

# Save: main raku grammar
my $grammar = my $main-grammar = $*LANG.slang_grammar('MAIN');
my $actions = my $main-actions = $*LANG.slang_actions('MAIN');


role NogilGrammar {
    method term:sym<name> {
        # CallSame
        my $res := $main-grammar.^find_method('term:sym<name>')(self);

        # Get known types
        my ($longname, @types) = longname-n-type($res);

        # If Existing as Routine or Sigless -> Nothing to do
        if (SUB, SLE) ∩ @types { return $res; }

        # If Declared -> Sigilize me
        if SCA ∈ @types {
            $res := $main-grammar.^find_method('term:sym<variable>')(self);
            $res := $res.^mixin(Sigilizer);
            return $res;
        }

        # If Declaring -> Fake fail
        if lk($res, 'args') { return self.fails; }

        # Nothing to do -> Will fail
        return $res;
    };

    method variable {
        #| Prefix variable Match with a '$'
        my $res := $main-grammar.^find_method('variable')(self);
        # Clause if POD
        return $res if $*LEFTSIGIL eq '=';
        # Sigilize
        $res := $res.^mixin(Sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        return $res;
    }

    token longname {
        #| Restrict longname in parameter: removing the 'just a longname error'
        <name> <!{ by-parameter }> [ <?before ':' <.+alpha+[\< \[ \« ]>> <!RESTRICTED> <colonpair> ]*
    }

    # Sigil
    method sigil { return self.sigil-my.^mixin(Sigilizer); }
    token sigil-my {
        | <[$@%&]>
        | <?{ by-variable }> <nogil>
    }
    token nogil { '€' | <?> }

    # Helper
    token fails { <!> }
    token succed { <?> }
}


role NogilActions {
    INIT {
        $*W.do_pragma('', 'strict', 0, ());
        $*W.do_pragma('', 'MONKEY', 1, ());
        $*W.do_pragma('', 'lib', 1, nqp::list('.'.IO, 'lib'.IO, 't'.IO, 't/lib'.IO));
    }

    method variable(Mu $/){
        # Play change, TODO this destroys the % & sigils
        my $ast := $/;
        my $sigil = str-key($ast, 'sigil');
        $sigil = '$' unless $sigil;
        sk($ast, 'sigil', $sigil);
        $ast := $ast.^mixin(Sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        nextwith($ast);
    }

    method sigil(Mu $/){ return $/.^mixin(Sigilizer); }

    method term:sym<name>(Mu $/) {
        my ($longname, @types) = longname-n-type($/);
        my $args = lk($/, 'args');

        # If Existing as Routine or Sigless -> Nothing to do
        if (SUB, SLE) ∩ @types { nextsame; }

        # If Declared -> Sigilize me
        if SCA ∈ @types { return QAST::Var.new( :name('$' ~ $longname) ); }

        ## Should not fail if param
        if $args { return nqp-create-var('$' ~ $longname); }

        # Nothing to do -> Fail as "Routine undeclared"
        nextsame;
    }
}


# Mix with user main language
$grammar = $grammar.^mixin(NogilGrammar);
$actions = $actions.^mixin(NogilActions);
sub EXPORT(|) { $*LANG.define_slang('MAIN', $grammar, $actions); return {}; }

#$grammar.^trace-on;
#$actions.^trace-on;

=begin pod

=head1 NAME
Slang::Nogil: Si - No - Si - No - Sigils !

=end pod
