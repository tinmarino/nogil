unit module Slang::Nogil::Grammar;
use Slang::Nogil::Util;
use nqp;
use QAST:from<NQP>;  # HLL::Compiler

my $main-grammar = $*LANG.slang_grammar('MAIN');

role NogilGrammar is export {
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
    # TODO The before saves for proto method work(|) {*}
    # but better <?before <ident>>. I don't knwo why the last is not working
    token nogil { '€' | <?> <?before <-[()\s]>  >}

    # Helper
    token fails { <!> }
    token succed { <?> }
    method nogil-warn(Str $msg) {
        my $line = HLL::Compiler.lineof(self.orig(), self.from(), :cache(1));
        my $file = ~nqp::getlexdyn('$?FILES');
        warn $msg ~ "; in $line;";
    }
}
