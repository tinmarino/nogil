# No unit module here otherwise symbol badly exported
use Slang::Nogil::Util;
use nqp;
use QAST:from<NQP>;


# Save: main raku grammar
my $grammar = my $main-grammar = $*LANG.slang_grammar('MAIN');
my $actions = my $main-actions = $*LANG.slang_actions('MAIN');

# Slang grammar
role NogilGrammar { #is TracedRoleHOW {
    # Variable
    method variable_declarator {
        my $method := $main-grammar.^find_method('variable_declarator');
        my $res := $method(self);
        return $res;
    }
    method variable {
        my $method := $main-grammar.^find_method('variable');
        my $res := $method(self);
        # Pod ?
        return $res if $*LEFTSIGIL eq '=';
        $res := $res.^mixin(Sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        return $res;
    }

    # Sigil
    method sigil { return self.sigil-my.^mixin(Sigilizer); }
    token sigil-my {
        | <[$@%&]>
        | <?{ by-variable }> <nogil>
    }
    token nogil { '€' | <?> }

    # For debug
    method term:sym<name> {
        #say "\n\nCalling my term:sym<name>:";
        my $match = '';
        my $is-var = False;
        my $res;
        # Cheat
        try {
            my $method := $main-grammar.^find_method('term:sym<name>');
            $res := $method(self);
            
            $match = lk($res, 'longname').Str if lk($res, 'longname');
            sub evaluate($name, Mu $value, $has_value, $hash) {
                return 1 unless $hash && $hash<scope> && $hash<scope> eq 'lexical';
                if $name eq '$' ~ $match {
                    #say $name;
                    $is-var = True;
                }
                return 1;
            }
            $*W.walk_symbols(&evaluate) if $match;
        }

        if $is-var {
            #say "Parse: in fake variable";
            my $method := $main-grammar.^find_method('term:sym<variable>');
            $res := $method(self);
            $res := $res.^mixin(Sigilizer);
            #$res := self.fails;
        }

        #say "Parsed term:", $res.Str;
        return $res;
    };

    token fails { <!> }
    token succed { <?> }

    token longname {
        # Restrict longname in parameter: removing the 'just a longname error'
        <name> <!{ by-parameter }> [ <?before ':' <.+alpha+[\< \[ \« ]>> <!RESTRICTED> <colonpair> ]*
    }
}

# Slang actions
role NogilActions {
    INIT {
        $*W.do_pragma('', 'strict', 0, ());
        $*W.do_pragma('', 'MONKEY', 1, ());
        $*W.do_pragma('', 'lib', 1, nqp::list('.'.IO, 'lib'.IO, 't'.IO, 't/lib'.IO));
    }

    method variable(Mu $/){
        # Play change, TODO this destroys the % & sigils
        sk($/, 'sigil', '$');

        my $res := $/;
        #say "Action Var" ~ $/.Str;
        $res := $res.^mixin(Sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        $res := callwith($res);
        #say "Action var: ", $res.dump;
        return $res;
    }

    method sigil(Mu $/){ return $/.^mixin(Sigilizer); }

    method term:sym<name>(Mu $/) {
        my $match = $/.Str;
        #log "\nAction term:", $/.Str;
        $match := lk($/, 'longname') if lk($/, 'longname');
        my $is-var = False;
        sub evaluate($name, Mu $value, $has_value, $hash) {
            return 1 unless $hash && $hash<scope> && $hash<scope> eq 'lexical';
            if $name eq '$' ~ $match {
                $is-var = True;
            }
            return 1;
        }
        $*W.walk_symbols(&evaluate) if $match;
        my $res;
        if $is-var {
            $res := QAST::Var.new( :name('$' ~ $match) );
        } else {
            $res := callsame;
        }
        #log "Actioned term:\n", $res.dump;
        return $res;
    }
}


# Mix
$grammar = $grammar.^mixin(NogilGrammar);
$actions = $actions.^mixin(NogilActions);

#$grammar.^trace-on;
#$actions.^trace-on;

sub EXPORT(|) { $*LANG.define_slang('MAIN', $grammar, $actions); return {}; }

=begin pod
=head1 NAME
Slang::Nogil: Si - No - Si - No - Sigils !
=end pod
