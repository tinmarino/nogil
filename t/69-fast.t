use lib 'lib';
use lib 't/lib';
use Test;
#use Slang::Nogil;
#use TestUse;

plan :skip-all<Dev tests>;

#proto sub postcircumfix:<[ ]> (|) is export {*}
multi postcircumfix:<[ ]> ( Str:D $s is rw, Int:D $i --> Str ) is rw is export {
   return $s.substr-rw: $i, 1;
}
multi postcircumfix:<[ ]>(Str $string, Int:D $index) is export {
    say "Post Int";
    $string.substr-rw($index, 1);
}
multi postcircumfix:<[ ]>(Str $string, Range:D $slice) is export {
    say "Post Range";
    $string.substr-rw($slice);
}


my $str = "0123456";
say $str[3];
$str[3] = "b";
say $str[3..5];
$str[3..5] = "uio";
say $str[3..5];
say $str;

=begin pod
my @arr = [1, 2, 3, 4];
#say .signature for Array.^method_table{'AT-POS'}.candidates ;
say .signature for Array.^method_table{'AT-POS'}.candidates ;
#say .signature for @arr.^method_table{'AT-POS'}.candidates ;
##say @arr.WHAT;
say @arr[1];
#my $idx = -1;
#say @arr[$idx];
say @arr[-1];
@arr[-1] = 30;
say @arr[-3..-1];

@arr[-3..-1] = [18, 19, 20];
say @arr[-3..-1];
say @arr;
#say @arr[1, 2, 3, -1; 1; 2];
=end pod
