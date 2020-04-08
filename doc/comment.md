## Warning

* Unexplained: Do not use unit module in the main module. Otherwise, symbols are badly exported


## Introspection

### Introspection Grammar

```raku
# Trace
$grammar.^trace-on

# Cursor keys
try { for $res.hash -> $k, $v { $k.Str.say }; }
```

### Actions inspection


## Warnings:

* Warn01: Affecting a Nogil variable with the same name as a function (or sigless). The function (or sigless) will eclipse your variable if used with nogil.

## Comments on code

```raku
# Grammar
# If Declaring or Declared -> Fake fail So I can call term:sym<variable>
if lk($res, 'args') { return self.fails; }


# Actions
method term:sym<name>(Mu $/) {
    #= <longname> <args>
}
```
