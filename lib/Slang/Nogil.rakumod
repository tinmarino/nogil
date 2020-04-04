# No unit module here otherwise symbol badly exported
use Slang::Nogil::Util;
use nqp;
use QAST:from<NQP>;

# Save: main raku grammar
my $grammar = my $main-grammar = $*LANG.slang_grammar('MAIN');
my $actions = my $main-actions = $*LANG.slang_actions('MAIN');

# Slang grammar
role NogilGrammar {
    # Variable
    method variable {
        my $res := $main-grammar.^find_method('variable')(self);
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

    token scope_declarator:sym<nomy> {
        <nomy_declarator>
    }

    token nomy_declarator {
        # Leave the {}
        {}
        :my $*SCOPE = 'my';
        <DECL=declarator>
        {}
    }

    # For debug
    method term:sym<name> {
        # CallSame
        my $res := $main-grammar.^find_method('term:sym<name>')(self);

        # Get type
        my $match = lk($res, 'longname') ?? lk($res, 'longname').Str !! '';
        my $type = nqp-type $match;

        if $type == SIG {
            $res := $main-grammar.^find_method('term:sym<variable>')(self);
            $res := $res.^mixin(Sigilizer);
            #$res := self.fails;
            return $res;
        }

        # Fake fail because declaration
        my $bol = $type == NOT;
        if $res && nqp::findmethod($res, 'hash') {
            my %h = gh $res;
            $bol = $bol && lk($res, 'args');
        } else {
            $bol = False;
        }
        if $bol {
            # I want to fail, hopefully <scope_declarator> or <variable>
            $res := self.fails;
            return $res;
        }
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
        my $res := $/;
        sk($res, 'sigil', '$');

        $res := $res.^mixin(Sigilizer);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        $res := callwith($res);
        return $res;
    }

    method sigil(Mu $/){ return $/.^mixin(Sigilizer); }

    method term:sym<name>(Mu $/) {
        # <longname> <args>?
        my $match = $/.Str;
        $match := lk($/, 'longname').Str if lk($/, 'longname');
        my $type = nqp-type $match;
        if $type == SIG {
            return QAST::Var.new( :name('$' ~ $match) );
        }

        ## Also should not fail if param
        my $bol = $type == NOT;
        $bol = $bol && lk($/, 'args');
        if $bol {
            return nqp-create-var('$' ~ $match);
        }
        nextsame;
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
