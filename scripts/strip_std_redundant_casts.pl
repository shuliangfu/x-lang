#!/usr/bin/env perl
# strip_std_redundant_casts.pl — std 收短：删除冗余 as（编译器已支持隐式拓宽/空指针/指针算术）。
# 规则：
#   - 下标 [i as usize]、指针 ptr + n as usize、实参 , n as usize
#   - 整数字面量 N as usize / 0xN as usize（保留 X as usize as *T 双转）
#   - 空指针 == 0 as *T、return 0 as *T
#   - let/const : usize = N as usize
# 不修改：变量 cast（len as usize）、位运算 as u8/u32、指针↔整数 as i64、struct as *u8。
# 用法：perl scripts/strip_std_redundant_casts.pl [--check] [path...]
use strict;
use warnings;
use File::Find;

my $check = 0;
my @roots;
for (@ARGV) {
    if ($_ eq '--check') { $check = 1; next; }
    push @roots, $_;
}
@roots = ('std') unless @roots;

sub strip_text {
    my ($s) = @_;
    my $orig = $s;
    my $n     = 0;
    my $total = 0;
    do {
        $n = 0;
        # 下标：buf[i as usize] → buf[i]
        while ( $s =~ s/\[([^\[\]]+?) as usize\]/[$1]/g ) { $n++; }

        # 指针算术：*ptr + n as usize / &arr[0] + n as usize
        while (
            $s =~ s/
                (\*[A-Za-z_][A-Za-z0-9_]*|\&[A-Za-z_][A-Za-z0-9_]*(?:\[[^\]]+\])?)
                \s*\+\s*
                ([^,+]+?)
                \ as\ usize\b
            /$1 + $2/gx
          )
        {
            $n++;
        }

        # 实参：仅整数字面量 , N as usize) / ,
        while ( $s =~ s/,(\s*(?:0x[0-9a-fA-F]+|\d+)) as usize(\)|,)/,$1$2/g ) { $n++; }

        # 整数字面量 as usize（跳过 ident as usize；保留 as usize as *T/i64）
        while (
            $s =~ s/
                (?<![A-Za-z_\]\)])
                ((?:0x[0-9a-fA-F]+|\d+))
                \ as\ usize\b
                (?! \s+ as )
            /$1/gx
          )
        {
            $n++;
        }

        # 空指针比较 / return
        while ( $s =~ s/(==|!=)(\s*)0 as \*[A-Za-z_][A-Za-z0-9_]*/$1${2}0/g ) { $n++; }
        while ( $s =~ s/\breturn(\s+)0 as \*[A-Za-z_][A-Za-z0-9_]*/return${1}0/g ) { $n++; }

        # : usize = N as usize（字面量规则通常已覆盖，留作兜底）
        while ( $s =~ s/(:\s*usize\s*=\s*)(\d+) as usize\b/${1}${2}/g ) { $n++; }

        $total += $n;
    } while ( $n > 0 );
    return ( $s, $s ne $orig );
}

sub process_file {
    my ($path) = @_;
    return unless $path =~ /\.sx\z/;
    open my $fh, '<', $path or return;
    local $/; my $text = <$fh>;
    close $fh;
    my ( $new, $changed ) = strip_text($text);
    return unless $changed;
    if ($check) {
        print "would strip: $path\n";
        return;
    }
    open my $out, '>', $path or die "write $path: $!";
    print $out $new;
    close $out;
    print "stripped: $path\n";
}

find(
    {
        wanted => sub {
            return if -d $_;
            my $p = $File::Find::name;
            return if $p =~ m/\/\.[^\/]+/;
            process_file($p);
        },
        no_chdir => 1,
    },
    grep { -d $_ } @roots
);

for my $f (@roots) {
    next unless -f $f;
    process_file($f);
}
