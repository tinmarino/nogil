use nqp;
use QAST:from<NQP>;

my $verbose = 1;
sub log(**@args){ say |@args if $verbose;}

# Helper: Str -> '$'
role Nogil::StrGil {
    method Str() {
        return nqp::unbox_s( sigilize(callsame) );
    }
}

# Helper: Look Key, Set Key
sub lk(Mu \h, \k) { nqp::atkey(nqp::findmethod(h, 'hash')(h), k); }
sub sk(Mu \h, \k, \v) { nqp::bindkey(nqp::findmethod(h, 'hash')(h), k, v); }

sub get-stack {
    my $bt = Backtrace.new;
    my $subnames = [];
    $subnames.push($bt.list[$_].subname) for 0..10;
    return $subnames
}

sub by-variable() {
    # 1me 2sigil 3varaible 4term:sym<variable> 5term <- variable in EXPR or declarator
    my $stack = get-stack;
    my $res = so($stack ∩ ('variable', 'param_var'));
    $res = $res && 'desigilname' ∉ $stack;
    $res = $res && 'special_variable' ∉ $stack;
    #$res = $res && 'term:sym<variable>' ∉ $stack;
    #log "Variable: ", $res, " <- ", $stack;
    return so($res);
}


sub by-parameter {
    # Avoid: get-stack by-parameter  longname parameter signature
    # Permit: get-stack by-parameter  longname typename type_constraint parameter
    my $stack = get-stack;
    my $res = 'parameter' ∈ $stack;
    $res = $res && 'typename' ∉ $stack;
    #$res = $res || 'term:sym<name>' ∈ $stack;
    log "Parameter: ", $res, " <- ", $stack;
    return $res;
}

sub sigilize(Str $name) {
    my $res = $name;
    my $c-first = $res.substr(0, 1);
    $res.substr-rw(0, 1) = '$' if $c-first eq '€';
    $res.substr-rw(0, 0) = '$' if $c-first ~~  / <alpha> /;
    return $res;

}

sub EXPORT(|) {

# Save: main raku grammar
my $main-grammar = $*LANG.slang_grammar('MAIN');
my $main-actions = $*LANG.slang_actions('MAIN');

# Slang grammar
role Nogil::NogilGrammar {

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
        $res := $res.^mixin(Nogil::StrGil);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);

        #nqp::bindattr_s($res.made, $res.made.WHAT, '$!name', $res.Str);
        return $res;
    }

    method sigil {
        my $res;
        # Bind
        #$res := self.sigil-my;
        $res := self.sigil-my.^mixin(Nogil::StrGil);
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
role Nogil::NogilActions {
    INIT {
        $*W.do_pragma('', 'strict', 0, ());
        $*W.do_pragma('', 'MONKEY', 1, ());
        $*W.do_pragma('', 'lib', 1, nqp::list('.'.IO, 'lib'.IO, 't'.IO, 't/lib'.IO));
    }

    method variable(Mu $/){
        # Play change, TODO this destroys the % & sigils
        sk($/, 'sigil', '$');

        my $res := $/.^mixin(Nogil::StrGil);
        $*LEFTSIGIL := sigilize($*LEFTSIGIL).substr(0, 1);
        $res := callwith($res);
        return $res;
    }

    method sigil(Mu $/){
        my $res := $/.^mixin(Nogil::StrGil);
        return $res;
    }
}


# Mix
my $grammar = $main-grammar.^mixin(Nogil::NogilGrammar);
my $actions = $main-actions;#.^mixin(Nogil::NogilActions);
$*LANG.define_slang('MAIN', $grammar, $actions);

# Return empty hash -> specify that we’re not exporting anything extra
return {};
}


=begin pod
=head1 NAME
Slang::Nogil: Si - No - Si - No - Sigils !
=end pod
