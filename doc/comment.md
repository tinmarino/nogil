## Warning

* Unexplained: Do not use unit module in the main module. Otherwise, symbols are badly exported


## Introspection

### Generic

```raku
# See methods and their output
for $obj.^methods -> $meth { say $meth, " = ", $meth($obj) }

# Attributes
for $obj.^attributes -> $attr { say $attr, " = ", $attr.get_value($obj) }

# Multi signature
say .signature for @arr.^method_table{'AT-POS'}.candidates ;
```

### Grammar

```raku
# Trace
$grammar.^trace-on

# Cursor keys
try { for $res.hash -> $k, $v { $k.Str.say }; }
```

### Actions


## Warnings:

* Warn01: Affecting a Nogil variable with the same name as a function (or sigless). The function (or sigless) will eclipse your variable if used with nogil.

## Comments on code

```raku
# Grammar
# If Declaring or Declared -> Fake fail So I can call term:sym<variable>

# If Declared or Declaring -> Next
# Got replaced by a fails in all cases -> Autodeclare
if SCA ∈ @types || lk($res, 'args') { self.fails }
# Nothing to do -> Will fail
return $res;


# Actions
method term:sym<name>(Mu $/) {
    #= <longname> <args>
}

# World
my Mu $nqplist := nqp::gethllsym(nqp, 'nqplist');
my $info = $*W.find_symbol($nqplist(['Any']), :setting-only);

```
