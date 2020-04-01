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
    my $res = so(get-stack() ∩ ('variable', 'param_var'));
    return so($res);
}


sub by-parameter {
    # Avoid: get-stack by-parameter  longname parameter signature
    # Permit: get-stack by-parameter  longname typename type_constraint parameter
    my $stack = get-stack;
    my $res = 'parameter' ∈ $stack;
    $res = $res && 'typename' ∉ $stack;
    log $res, " <- ", $stack;
    return $res;
}

sub EXPORT(|) {


my $main-grammar = $*LANG.slang_grammar('MAIN');
my $main-actions = $*LANG.slang_actions('MAIN');

role Nogil::NogilGrammar {
    token sigil {
        | <[$@%&]>
        | <?{ by-variable }> <nogil>
    }

    token nogil {
        | '€'
        | <?>
        {log "No sigil $/"; } }

    token longname {
        # Restrict longname in parameter: removing the 'just a longname error'
        <name> <!{ by-parameter }> [ <?before ':' <.+alpha+[\< \[ \« ]>> <!RESTRICTED> <colonpair> ]*
    }
        #token parameter {
        #    <param_var>
        #}

        #token parameter:sym<param_var> {
        #    #say "Calling next"; 
        #    <param_var>
        #    #<Grammar::parameter>
        #    ##my $cursor = $main-grammar.^find_method('parameter');
        #    ##return $cursor if $cursor();
        #    ##say "Raw param_var";
        #    #my $cursor = self.proxy_param_var;
        #    #return $cursor;
        #}

    token term:sym<nomy_declarator> {
        [ <?> ] # | 'bb = 15']
        { say "IN nomy"; }

        :my $*SCOPE = 'my';
        :my $*VARIABLE = '';
        <variable_declarator>
    }
}

role Nogil::NogilActions {
    sub lk(Mu \h, \k) { nqp::atkey(nqp::findmethod(h, 'hash')(h), k); }

    INIT {
        $*W.do_pragma('', 'strict', 0, ());
        $*W.do_pragma('', 'MONKEY', 1, ());
        $*W.do_pragma('', 'lib', 1, nqp::list('.'.IO, 'lib'.IO, 't'.IO, 't/lib'.IO));
    }
    method sigil(Mu $/) {
        my $res = make $/;
        # TODO see if that can be in Raku way
        my $nogil = lk($/, 'nogil');
        $res = make $nogil.made if $nogil;
        #say "Action -> $res";
        #$res = make '$';
        return $res;
    }

    method nogil(Mu $/){
        make '$';
    }
    

    #method variable(Mu $/) {
    #    say "Variable $/";
    #    return make $/.made;
    #}


    #method scope_declarator:sym<nomy>(Mu $/) {
    #    make lk($/, 'scoped').made;
    #}
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
