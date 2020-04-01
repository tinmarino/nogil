use nqp;
use QAST:from<NQP>;

my $verbose = 1;
sub log(**@args){ say @args if $verbose;}

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
    log "Variable: ", $res, " <- ", $stack;
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

sub EXPORT(|) {


my $main-grammar = $*LANG.slang_grammar('MAIN');
my $main-actions = $*LANG.slang_actions('MAIN');

role Nogil::NogilGrammar {
    token sigil {
        | <[$@%&]>
        | <?{ by-variable }> <nogil> {}
    }

    token nogil {
        | '€'
        | <?>
        {log "No sigil:", get-stack; }
    }

    token longname {
        # Restrict longname in parameter: removing the 'just a longname error'
        <name> <!{ by-parameter }> [ <?before ':' <.+alpha+[\< \[ \« ]>> <!RESTRICTED> <colonpair> ]*
    }
}

role Nogil::NogilActions {
    sub lk(Mu \h, \k) { nqp::atkey(nqp::findmethod(h, 'hash')(h), k); }

    INIT {
        $*W.do_pragma('', 'strict', 0, ());
        $*W.do_pragma('', 'MONKEY', 1, ());
        $*W.do_pragma('', 'lib', 1, nqp::list('.'.IO, 'lib'.IO, 't'.IO, 't/lib'.IO));
    }
}


my $grammar = $main-grammar.^mixin(Nogil::NogilGrammar);
my $actions = $main-actions.^mixin(Nogil::NogilActions);
$*LANG.define_slang('MAIN', $grammar, $actions);

class Metamodel::ClassHOW {
    method  { self == 42 }
}

return {};
}


=begin pod
=head1 NAME
Slang::Nogil: Si - No - Si - No - Sigils !
=end pod
