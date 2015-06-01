#!/usr/bin/perl
use warnings;
use strict;

use Test::More;

my %tests = (
    '5.020' => [
        [ ':prototype',
          'sub func : prototype($$) {} prototype \&func', '$$' ],
        [ 'drand48',
          'use Config; $Config{randfunc}', 'Perl_drand48' ],
        [ '%slice',
          'my %h = my @l = qw(a A b B); join ":", %h{qw(a b)}, %l[0, 3]',
          'a:A:b:B:0:a:3:B'],
        [ 'unicode6.3',
          'my $i; /\p{Age: 6.3}/ and $i++ for map chr, 0 .. 0xffff; $i', 5 ],
        [ '\p{Unicode}',
          'scalar grep $_ =~ /\p{Unicode}/, "a", "\N{U+0FFFFF}"', 2 ],
        # TODO: 'utf8-locale'.
    ],


    '5.018' => [
        [ 'computed-labels',
          'my $x = "A"; B:while (1) { A:while (1) { last $x++ }}; 1', 1],
    ],

    '5.014' => [
        [ '?^',
          '"Ab" =~ /(?i)a(?^)b/', 1],
        [ '/r',
          'my $x = "abc"; $x =~ s/c/d/r', 'abd'],
        [ '/a',
          '"\N{U+0e0b}" =~ /^\w$/a', q()],
        [ '/u',
          '"\xa0\xe0" =~ /\w/u', 1],
        [ 'auto-deref',
          'my ($x, $y, $z) = ([10, 20, 30], {a=>10, b=>20}, [10, 20]);'
          . 'push $z, 30;'
          . '(join ":", keys $x) . (join ":", sort keys $y) . "@$z"',
          '0:1:2a:b10 20 30' ],
        [ '^GLOBAL_PHASE',
          '${^GLOBAL_PHASE}', 'RUN'],
        [ '\o',
          '"\o{10}"', chr 8 ],
        [ 'package-block',
          'package My::Number { sub eleven { 11 } } My::Number::eleven()',
          11 ],
    ],

    '5.012' => [
        [ 'package-version',
          'package Local::V 4.3; 1', 1],
        [ '...',
          'my $x = 0; if ($x) { ... } else { 1 }', 1],
        [ 'each-array',
          'my $r; my @x = qw(a b c); while (my ($i, $v) = each @x) '
          . ' { $r .= $i . $v; } $r', '0a1b2c'],
        [ 'keys-array',
          'my @x = qw(a b c); join q(), keys @x', '012'],
        [ 'values-array',
          'my @x = qw(a b c); join q(), values @x', 'abc'],
        [ 'delete-local',
          'our %x = (a=>10, b=>20); {delete local $x{a};'
          . ' die if exists $x{a}};$x{a}', 10],
        [ 'length-undef',
          'length undef', undef],
        [ '\N',
          '"\n" !~ /\N/', 1],
        [ 'while-readdir',
          join(' ',
               'use FindBin; use File::Spec;',
               'opendir my $DIR, $FindBin::Bin or die $!;',
               'my $c = 0;',
               '$_ eq ("File::Spec"->splitpath($0))[-1]',
               'and ++$c while readdir $DIR;',
               '$c'),
          1 ],
    ],

    '5.010' => [
        [ '//',
          'undef // 1', 1],
        [ '?PARNO',
          '"abad" =~ /^(.).(?1).$/', 1],
        [ '?<>',
          '"a1b1" =~ /(?<b>.)b\g{b}/;', 1],
        [ '?|',
          '"abc" =~ /(?|(x)|(b))/ ? $1 : undef', 'b'],
        [ 'quant+',
          '"xaabbaa" =~ /a*+a/;', q()],
        [ 'regex-verbs',
          '', ],
        [ '\K',
          '(my $x = "abc") =~ s/a\Kb/B/; $x', 'aBc'],
        [ '\R',
          'grep $_ =~ /^\R$/, "\x0d", "\x0a", "\x0d\x0a"', 3],
        [ '\gN',
          '"aba" =~ /(a)b\g{1}/;', 1],
        [ 'readline()',
          'local *ARGV = *DATA{IO}; chomp(my $x = readline()); $x', 'readline default'],
        [ 'stack-file-test',
          '-e -f $^X', 1],
        [ 'recursive-sort',
          'sub re {$a->[0] <=> $b->[0] '
          . 'or re(local $a = [$a->[1]], local $b = [$b->[1]])}'
          . 'join q(), map @$_, sort re ([1,2], [1,1], [2,1], [2,0])',
          '11122021'],
        [ '/p',
          '"abc" =~ /b/p;${^PREMATCH}', 'a'],
    ],
);

my $count = 0;

for my $version (keys %tests) {
    my $vf = sprintf '%.3f', $version;
    my @triples = @{ $tests{$version} };
    my $can = eval { require ( 0 + $version) };
    $count += $can ? 2 * @triples : @triples;
    for my $triple (@triples) {
        my $value = eval "use Syntax::Construct qw($triple->[0]);$triple->[1]";
        if ($can) {
            is($@, q(), "no error $triple->[0]");
            is($value, $triple->[2], $triple->[0]);
        } else {
            like($@,
                 qr/^Unsupported construct \Q$triple->[0]\E at \(eval [0-9]+\) line 1 \(Perl $vf\)\n/,
                 $triple->[0]);
        }
    }
}

done_testing($count);


__DATA__
readline default

=for completness
    '5.014' => [
        [ '/l',
        [ '/d',

    '5.020' => [
        [ 'utf8-locale',

=cut
