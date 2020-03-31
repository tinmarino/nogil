use nqp;
use QAST:from<NQP>;

my $verbose = 0;
sub log(**@args){ say @args if $verbose;}

sub called-by-variable() {
    # 1me 2sigil 3varaible 4term:sym<variable> 5term <- variable in EXPR or declarator
    # TODO document param_var trace
    my $bt = Backtrace.new;
    my $subname = $bt.list[3].subname;
    log "At least trying ", $subname, " <- ", $bt;
    my $res = $subname ∈ ('variable', 'param_var');
    log $res;
    return $res;
}

sub EXPORT(|) {

role Nogil::NogilGrammar {
    token sigil {
        | <[$@%&]>
        | <?{ called-by-variable }> <nogil>
    }

    token nogil {
        <?> # <?before <.identifier> > 
        {log "No sigil $/"; } }
}

role Nogil::NogilActions {
    sub lk(Mu \h, \k) { nqp::atkey(nqp::findmethod(h, 'hash')(h), k); }

    INIT {
        $*W.do_pragma('', 'strict', 0, ());
        $*W.do_pragma('', 'MONKEY', 1, ());
        $*W.do_pragma('', 'lib', 1, nqp::list('.'.IO, 'lib'.IO, 't'.IO, 't/lib'.IO));
        #$*W.do_pragma('', 'experimental', 1, ('macros'));
        #my $match = $*LANG.parse('use experimental :macros;');
        #say "Match: $match";

        #use experimental :macros;
        #my $lex := $*W.cur_lexpad();
        #$lex.symbol('EXPERIMENTAL-PACK') := 1;

        #my $comp_unit := self.load_module($/, $name, %cp, self.cur_lexpad);
        #$RMD("Performing imports for '$name'") if $RMD;
        #self.do_import($/, $comp_unit.handle, $name, $arglist);
        #say "Sym {%sym}";
        #my $nqplist = nqp::gethllsym('nqp', 'nqplist');
        #say "List $nqplist";
        #$*W.find_symbol($nqplist(['EXPERIMENTAL-PACK']));
    }
    method sigil(Mu $/) {
        # Necessary
        # TODO codument why this not work
        # my $nogil = $<nogil>;
        my $res = make $/;
        my $nogil = lk($/, 'nogil');
        $res = make $nogil.made if $nogil;
        return $res;
    }

    method nogil(Mu $/){
        make '$';
    }
}


my $grammar = $*LANG.slang_grammar('MAIN').^mixin(Nogil::NogilGrammar);
my $actions = $*LANG.slang_actions('MAIN').^mixin(Nogil::NogilActions);
$*LANG.define_slang('MAIN', $grammar, $actions);

return {};
}


=begin pod

=head1 NAME

Slang::Nogil - No - Si - No - Sigils !

=head1 SYNOPSIS


=end pod
