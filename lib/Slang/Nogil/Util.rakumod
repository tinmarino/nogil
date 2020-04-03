unit module Slang::Nogil::Util;

use nqp;

# TODO verbose from stdin
my $verbose = 1;
sub log(**@args) is export {say |@args if $verbose;}

sub sigilize(Str $name) is export {
    my $res = $name;
    my $c-first = $res.substr(0, 1);
    $res.substr-rw(0, 1) = '$' if $c-first eq '€';
    $res.substr-rw(0, 0) = '$' if $c-first ~~  / <alpha> /;
    return $res;
}

# Str -> '$'
role Sigilizer is export {
    method Str() {
        return nqp::unbox_s( sigilize(callsame) );
    }
}

# Helper: Gtt Hash, Look Key, Set Key
sub gh(Mu \h) is export { nqp::findmethod(h, 'hash')(h); }
sub lk(Mu \h, \k) is export { nqp::atkey(gh(h), k); }
sub sk(Mu \h, \k, \v) is export { nqp::bindkey(gh(h), k, v); }

sub get-stack is export {
    my $bt = Backtrace.new;
    my $subnames = [];
    $subnames.push($bt.list[$_].subname) for 0..10;
    return $subnames
}

sub by-variable() is export {
    # 1me 2sigil 3varaible 4term:sym<variable> 5term <- variable in EXPR or declarator
    my $stack = get-stack;
    my $res = so($stack ∩ ('variable', 'param_var'));
    $res = $res && 'desigilname' ∉ $stack;
    $res = $res && 'special_variable' ∉ $stack;
    #$res = $res && 'term:sym<variable>' ∉ $stack;
    #log "Variable: ", $res, " <- ", $stack;
    return so($res);
}


sub by-parameter is export {
    # Avoid: get-stack by-parameter  longname parameter signature
    # Permit: get-stack by-parameter  longname typename type_constraint parameter
    my $stack = get-stack;
    my $res = 'parameter' ∈ $stack;
    $res = $res && 'typename' ∉ $stack;
    #$res = $res || 'term:sym<name>' ∈ $stack;
    #log "Parameter: ", $res, " <- ", $stack;
    return $res;
}


## Export constant
#my module EXPORTHOW {
#
#}

#    method ^find_method(Mu:U \this, Mu $name) {
#      say $name;
#      callsame;
#    }
#
#    method ^publish_method_cache(Mu:U \this) {
#        # Suppress this, so we always hit find_method.
#    }
