## Warning

* Unexplained: Do not use unit moduel in the main module. Otherwise, symbols are badly exported


## Introspection

### Introspection Grammar

```raku
$grammar.^trace-on
```

### Actions inspection


## Comments on code

```raku
method term:sym<name>(Mu $/) {
    #= <longname> <args>
}


sub EXPORT(|) {
    # Integrate slang to Raku main language (i.e not to regex or quote)
    $*LANG.define_slang('MAIN', $grammar, $actions);

    # Return empty hash -> specify that we’re not exporting anything extra
    return {};
}
```
