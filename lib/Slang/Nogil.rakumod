use Slang::Nogil::Grammar;
use Slang::Nogil::Actions;
require Slang::Nogil::Nocomp;   # @arr[-1] at runtime
use Slang::Nogil::Augment;      # Autovivication

# Mix with user main language
sub EXPORT(|) {
    # Nogil
    return {} if $*LANG.slang_grammar('MAIN') ~~ NogilGrammar;
    $*LANG.refine_slang('MAIN', NogilGrammar, NogilActions);
    return {};
}

#$*LANG.slang_grammar('MAIN').^mixin(NogilGrammar).^trace-on;
#$*LANG.slang_actions('MAIN').^mixin(NogilActions).^trace-on;

=begin pod

=head1 NAME
Slang::Nogil: Si - No - Si - No - Sigils !

=end pod
