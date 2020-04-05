# Slang::Nogil

Raku slang permiting __Not__ to use sigils

```raku
use Slang::Nogil;
my a = 3; say a;  # OUTPUT: 3
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


### Alternatives

1. [sigless](https://opensource.com/article/18/9/using-sigils-perl-6) variables:

```raku
my \foo = $ = 41;                # a sigilless scalar variable
my \bar = @ = 1,2,3,4,5;         # a sigilless array
my \baz = % = a => 42, b => 666; # a sigilless hash
```

2. [lvalue](http://www.dlugosz.com/Perl6/web/lvalues.html) routines:
With the [is rw](https://docs.raku.org/routine/is%20rw) [trait](https://docs.raku.org/language/traits).



### Why are sigils useful anyway ?

From [jnthn](https://stackoverflow.com/questions/50399784):

1. Syntactic disambiguation : you can call a variable whatever you want, even if there happens to be a keyword with that name
2. Readability : the data in the program stands out thanks to the sigil
3. Defining assignment semantics : in Perl 6 assignment means "copy in to", thus my @a = @b means iterate @b and put each thing in it into @a, thus any future assignments to @b will not affect @a
4. Restricting what can be bound there : only Positional things to @, for example
5. In the case of the $, controlling what will be considered a single item
6. In the case of @ on a signature parameter, causing an incoming Seq to be cached
7. Interpolation in string: Now you have to use `{}`


### Links

* [European sigil €](https://raku-musings.com/eu.html) -> from the time `token sigil` was a proto
* [Slang Mouq Tuto](https://mouq.github.io/slangs.html) -> aimed at `use v5`, shows very well the skeleton

