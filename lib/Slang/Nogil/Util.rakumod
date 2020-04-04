unit module Slang::Nogil::Util;

use nqp;
use QAST:from<NQP>;

# TODO verbose from stdin
my $verbose = 0;
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

# Get Hash, Look Key, Set Key
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


sub nqp-create-var($name) is export {
	# Assign a return a default variable
	log "Createing $name -------------------------------";
    my $res := QAST::Op.new(
        :op('bind'),
        QAST::Var.new( :name('$toto'), :scope('lexical'), :decl('var'), :returns(int) ),
        QAST::IVal.new( :value(0) )
    );
	log "Created \$toto";
	return $res;
}


our constant SIG is export = 1;
our constant FCT is export = 2;
our constant NO is export = 3;


sub nqp-type(Mu $arg-check) is export {
	my $res = NO;
	return $res unless $arg-check;
	my $to-check = $arg-check.Str;
	return $res unless $to-check;
	sub evaluate($name, Mu $value, $has_value, $hash) {
		#return 1 unless $hash && $hash<scope> && $hash<scope> eq 'lexical';
		if $name eq '$' ~ $to-check { $res = SIG; return 0; }
		if $name eq '&' ~ $to-check { $res = FCT; return 0; }
		return 1;
	}
	try { $*W.walk_symbols(&evaluate) if $to-check; }
	log "Type $to-check is $res --------------------------", get-stack;
	return $res;
}

# Debugging
sub dump-nqphash(Mu $hash) is export {
    log "Dumping:";
    for $hash {
        log(nqp::iterkey_s($_), ' => ', nqp::iterval($_));
    }
}
