# Slang::Nogil

Raku slang permitting __Not__ to use sigils

```raku
use Slang::Nogil;
nogil = 3;
say nogil + 39;  # OUTPUT: 42
say $nogil;  # OUTPUT: 3
say "Interpolate $nogil";  # OUTPUT: "Interpolate 3"
say "Interpolate {nogil * 10 + 12}";   # OUTPUT: "Interpolate 42"
```

```raku
use Slang::Nogil;
local = "value";
say local;  # OUTPUT: "value"

sub fct(param) {
    say param;
}
fct("argument");  # OUTPUT: "argument"
```


## Features
> If you're going through hell, keep going (Winston Churchill)

"Nogil" variables are hidden [scalar](https://docs.raku.org/type/Scalar) variables.
You can refer to them with or without the scalar sigil '$'.
For example, you can [interpolate](https://docs.raku.org/language/101-basics#interpolation) them prefixing by a '$' in double quoted strings.


### Feature: Nogil

### Feature: Autovivify scalars

Scalars are autodeclared to an Raku Any instance. which is augmented to get '' and 0 and default Str and Int.



### Feature: Pragma

Some [pragmas](https://docs.raku.org/language/pragmas) are added to the importing scope:

* [no strict](https://docs.raku.org/language/pragmas#strict): can declare without `my`:

```raku
say varname = 42;  # OUTPUTS: 42
```

* [MONKEY](https://docs.raku.org/language/pragmas#MONKEY): can use [EVAL](https://docs.raku.org/routine/EVAL) and [augment](https://docs.raku.org/syntax/augment)

* [lib](https://docs.raku.org/language/pragmas#lib): '.', 'lib', 't', 't/lib': can import module in those directories


## Alternatives
> A tool is only worth by the hand that animates it (Marshall of Lattre)

1. [sigilless](https://opensource.com/article/18/9/using-sigils-perl-6) variables:

```raku
my \foo = $ = 41;                # a sigilless scalar variable
my \bar = @ = 1,2,3,4,5;         # a sigilless array
my \baz = % = a => 42, b => 666; # a sigilless hash
```

2. [lvalue](http://www.dlugosz.com/Perl6/web/lvalues.html) routines:
With the [is rw](https://docs.raku.org/routine/is%20rw) [trait](https://docs.raku.org/language/traits):

```raku
my $var = 1;
sub fct is rw { $var; }           # Note the is tw trait
fct() = 2;                        # Note the necessary ()
say fct;                          # OUTPUTS: 2
```


## Why are sigils useful anyway ?
> Doubtless this is somewhat interesting to someone somewhere, but we'll restrain ourselves from talking about them somehow (TimToady)

__Brief:__ Sigils can be seem as type declaration. They permit compiler optimisation and avoid user error at compile time.

Note that this plugin only aliases the scalar sigil (by void).
You are strongly recommended to keep using the `@`, `%` and `&` sigils.
If those are absent from your code, guess you are writing, like most of us, "baby Raku" and losing some awesome compiler optimisations.

1. Syntactic disambiguation : you can call a variable whatever you want, even if there happens to be a keyword with that name
    * Here: routines (`&`) and sigless (`\\`) variables override nosig (``) variables.
2. Readability : the data in the program stands out thanks to the sigil
    * Here: the way of the poet is in your palm. Never say the aggresive: "it doesn't make sense" and prefer the humble "I don't understand".
3. Defining assignment semantics : in Perl 6 assignment means "copy in to", thus my @a = @b means iterate @b and put each thing in it into @a, thus any future assignments to @b will not affect @a
    * Here: `=` assign `:=` bind. I think ...
4. Restricting what can be bound there : only Positional things to @, for example
    * Here: you can by default affect anything to a scalar. Same for a nogil. Just take care to give transform it to the good type before (ex `var-hash = %(1=>2, 3=>4)`). Some [containerisation](https://docs.raku.org/language/containers) (object reference)
5. In the case of the $, controlling what will be considered a single item
    * Here: use nogil or scalar.
6. In the case of @ on a signature parameter, causing an incoming Seq to be cached
    * Here: `var-array = @(1..3)`. But then you may get it trouble to iterate or push. If using a list, you better explicit it to the compiler.
7. Interpolation in double quoted strings
    * Here: use the `$` or `{}` construct

Source: [jnthn](https://stackoverflow.com/questions/50399784)


## Links
> I don't know, Lord, if you are happy with me; but I am very happy with You (Louis Bourdaloue)

* [Grammar: European sigil €](https://raku-musings.com/eu.html) -> from the time `token sigil` was a proto
* [Grammar: Slang Mouq Tuto](https://mouq.github.io/slangs.html) -> aimed at `use v5`, shows very well the skeleton
* [QAST: QASTalicious](http://blogs.perl.org/users/zoffix_znet/2018/01/perl-6-core-hacking-qastalicious.html) -> list QAST operations
* [Array: Negative Array indexing](https://andrewshitov.com/2018/01/07/18-implementing-negative-array-subscripts-in-perl-6/) -> Show the code related to `@arr[-1]`
* [Array: multi order](https://stackoverflow.com/questions/61179059): where clause is called first. Try `no precompilation` in module
* [Str: Slice like Array: At](https://stackoverflow.com/questions/41689023/) -> FETCH
* [Str: Str as Array: Assign](https://stackoverflow.com/questions/45292437/) -> STORE
* [Str: Pythonic](https://github.com/raku-community-modules/perl6-Pythonic-Str) -> Operator overload `postcircumfix:<[ ]>`
* [Nogil Tests]()
