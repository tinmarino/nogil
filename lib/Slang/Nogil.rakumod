use Slang::Nogil::Util;
use MONKEY;
use nqp;
use QAST:from<NQP>;

# Save: main raku grammar
my $main-grammar = $*LANG.slang_grammar('MAIN');
my $main-actions = $*LANG.slang_actions('MAIN');


role NogilGrammar {
    method term:sym<name> {
        #= The new term will be term:sym<variable>, after a fails
        # CallSame
        my $res := $main-grammar.^find_method('term:sym<name>')(self);

        # Get known types
        my ($longname, @types) = longname-n-type($res);

        # If Existing as Routine or Sigless -> Usually Nothing to do
        if (SUB, SLE) ∩ @types {
            # If defining easily toto=12 even if a function -> Next
            if str-key($res, 'args') ~~ /^ \s* '='/ {
                self.nogil-warn('Warn01: You are affecting a variable with same name as a function: "' ~ $longname ~ '"');
                return self.fails;
            }
            return $res;
        }

        # Next -> term:sym<variable>
        return self.fails;
    };


    method variable {
        #| Prefix variable Match with a '$'
        my $res := $main-grammar.^find_method('variable')(self);
        # Clause if POD
        return $res if $*LEFTSIGIL eq '=';
        # Sigilize
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        return $res.^mixin(Sigilizer);
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
    method nogil-warn(Str $msg) {
        my $line = HLL::Compiler.lineof(self.orig(), self.from(), :cache(1));
        my $file = ~nqp::getlexdyn('$?FILES');
        warn $msg ~ "; in $line;";
    }
}


role NogilActions {
    INIT {
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
}

# Autodecl
augment class Any {
    method Str { '' }
    method Int { 0 }
}

# Mix with user main language
sub EXPORT(|) {

    # Nogil
    return {} if $main-grammar ~~ NogilGrammar;
    $*LANG.refine_slang('MAIN', NogilGrammar, NogilActions);
    return {};
}

#$*LANG.slang_grammar('MAIN').^mixin(NogilGrammar).^trace-on;
#$*LANG.slang_actions('MAIN').^mixin(NogilActions).^trace-on;

=begin pod

=head1 NAME
Slang::Nogil: Si - No - Si - No - Sigils !

=end pod
