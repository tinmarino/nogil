# No unit module here otherwise symbol badly exported
use Slang::Nogil::Util;
use nqp;
use QAST:from<NQP>;


# Save: main raku grammar
my $grammar = my $main-grammar = $*LANG.slang_grammar('MAIN');
my $actions = my $main-actions = $*LANG.slang_actions('MAIN');


# Slang grammar
role NogilGrammar {
    method variable_declarator {
        my $method := $main-grammar.^find_method('variable_declarator');
        my $res := $method(self);
        return $res;
    }

    method variable {
        my $method := $main-grammar.^find_method('variable');
        my $res := $method(self);
        if $*LEFTSIGIL eq '=' {
            return $res;
        }
        $res := $res.^mixin(sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);

        #nqp::bindattr_s($res.made, $res.made.WHAT, '$!name', $res.Str);
        return $res;
    }

    method sigil {
        my $res;
        # Bind
        #$res := self.sigil-my;
        $res := self.sigil-my.^mixin(sigilizer);
        return $res;
    }

    token sigil-my {
        | <[$@%&]> |
        <?{ by-variable }>
        <nogil>
    }

    token nogil {
        | '€'
        | <?>
        {log "No sigil:", get-stack; }
    }

    #token term:sym<name> {
    #    # Line 3125
    #};


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

        my $res := $/.^mixin(sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        $res := callwith($res);
        return $res;
    }

    method sigil(Mu $/){
        my $res := $/.^mixin(sigilizer);
        return $res;
    }
}


# Mix
$grammar = $grammar.^mixin(NogilGrammar);
$actions = $actions.^mixin(NogilActions);


sub EXPORT(|) {
    # Integrate slang to Raku main language (i.e not to regex or quote)
    $*LANG.define_slang('MAIN', $grammar, $actions);

    # Return empty hash -> specify that we’re not exporting anything extra
    return {};
}


=begin pod
=head1 NAME
Slang::Nogil: Si - No - Si - No - Sigils !
=end pod
