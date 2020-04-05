unit module Slang::Nogil::Util;
use nqp;
use QAST:from<NQP>;

# TODO verbose from stdin
my $verbose = 0;
our constant SIG is export = 1;
our constant FCT is export = 2;
our constant NOT is export = 3;
sub log(**@args) is export {say |@args if $verbose;}

#= Get Hash, Look Key, Set Key, Get Key as String
sub gh(Mu \h) is export { nqp::findmethod(h, 'hash')(h); }
sub lk(Mu \h, \k) is export { nqp::atkey(gh(h), k); }
sub sk(Mu \h, \k, \v) is export { nqp::bindkey(gh(h), k, v); }
sub str-key(Mu \h, \k) is export {
    my $obj = lk(h, k);
    return '' unless $obj;
    return $obj.Str;
}


sub get-stack is export {
    my $bt = Backtrace.new;
    my $subnames = [];
    $subnames.push($bt.list[$_].subname) for 0..10;
    return $subnames
}


sub sigilize(Str $name) is export {
    #= Prefix '$' if no sigil
    my $res = $name;
    my $c-first = $res.substr(0, 1);
    $res.substr-rw(0, 1) = '$' if $c-first eq '€';
    $res.substr-rw(0, 0) = '$' if $c-first ~~  / <alpha> /;
    return $res;
}


role Sigilizer is export {
    #= Str -> '$'
    method Str() { return nqp::unbox_s( sigilize(callsame) ); }
}

sub by-variable() is export {
    #= Is called by <variable> ?
    #= 1me 2sigil 3varaible 4term:sym<variable> 5term <- variable in EXPR or declarator
    my $stack = get-stack;
    my $res = so($stack ∩ ('variable', 'param_var'));
    $res = $res && 'desigilname' ∉ $stack;
    $res = $res && 'special_variable' ∉ $stack;
    return so($res);
}


sub by-parameter is export {
    #= Is called by <parameter> ?
    #= Avoid: get-stack by-parameter  longname parameter signature
    #= Permit: get-stack by-parameter  longname typename type_constraint parameter
    my $stack = get-stack;
    my $res = 'parameter' ∈ $stack;
    $res = $res && 'typename' ∉ $stack;
    return $res;
}


sub longname-n-type(Mu $obj) is export {
    #= Retrieve s_longname and its e_type <- from NQPMath or QAST
    my $longname = $obj.Str;
    my $o_longname = lk($obj, 'longname');
    $longname = $o_longname.Str if $o_longname;
    return $longname, nqp-type($longname);
}

sub nqp-create-var($name) is export {
    #= New assigned variable: `my $name = '';`
    my $res := QAST::Op.new(
        :op('bind'),
        QAST::Var.new( :$name, :scope('lexical'), :decl('var'), :returns(str) ),
        QAST::SVal.new( :value('') )
    );
    return $res;
}


sub nqp-type(Mu $arg-check) is export {
    my $res = NOT;
    return $res unless $arg-check;
    my $to-check = $arg-check.Str;
    return $res unless $to-check;
    sub evaluate($name, Mu $value, $has_value, $hash) {
        if $name eq '$' ~ $to-check { $res = SIG; return False; }
        if $name eq '&' ~ $to-check { $res = FCT; return False; }
        return True;
    }
    try { $*W.walk_symbols(&evaluate) if $to-check; }
    return $res;
}
