#!/usr/bin/env perl
# migrate_array_slice_syntax.pl — 将类型语法 T[N] / T[] 批量改为 T[N] / T[]（C 风格）。
# 不修改数组字面量 [1, 2, 3]、下标 arr[i]、空字面量 = []。
# 支持 .x / .md / .c / .h / .sh / .py 等文本源。
# 用法：perl scripts/migrate_array_slice_syntax.pl [--check] [path...]
use strict;
use warnings;
use File::Find;

my $check = 0;
my @roots;
for (@ARGV) {
    if ($_ eq '--check') { $check = 1; next; }
    push @roots, $_;
}
@roots = ('.') unless @roots;

my @TYPE_KW = qw(u8 i32 i64 u32 u64 usize isize bool f32 f64 void);
my $tk = join '|', @TYPE_KW;

my @EXT = qw(x md c h sh py tsv pl mdc);
my $ext_re = join '|', @EXT;

sub suffix_dims {
    my ($prefix) = @_;
    my @sizes = ($prefix =~ /\[(\d+)\]/g);
    return join('', map { '[' . $_ . ']' } @sizes);
}

sub migrate_text {
    my ($s) = @_;
    my $orig = $s;

    $s =~ s/\[\]T(<[^>]+>)/T[]$1/g;
    $s =~ s/\[\]($tk)(<[^>]+>)/${1}[]$2/g;
    $s =~ s/\[(\d+)\](\*+(?:$tk|[A-Za-z_][A-Za-z0-9_.]*))/${2}[$1]/g;

    $s =~ s/((?:\[\d+\])+)(($tk)\b)/$2 . suffix_dims($1)/ge;
    $s =~ s/((?:\[\d+\])+)([A-Z][A-Za-z0-9_]*)/$2 . suffix_dims($1)/ge;

    $s =~ s/\[(\d+)\]($tk)\b/${2}[$1]/g;
    $s =~ s/\[(\d+)\]([A-Za-z_][A-Za-z0-9_.]*)/${2}[$1]/g;
    $s =~ s/\[\]($tk)\b/${1}[]/g;
    $s =~ s/\[\]([A-Za-z_][A-Za-z0-9_.]*)/${1}[]/g;

    $s =~ s/\[N\]($tk)\b/${1}[N]/g;
    $s =~ s/\[N\]([A-Za-z_][A-Za-z0-9_.]*)/${1}[N]/g;
    $s =~ s/\[N\]T/T[N]/g;
    $s =~ s/\[\]T/T[]/g;

    return ($s, $s ne $orig);
}

sub should_process {
    my ($path) = @_;
    return 0 unless $path =~ /\.(?:$ext_re)\z/;
    return 0 if $path =~ m/_gen(?:2)?\.c\z/;
    return 0 if $path =~ m/_gen\.c\z/;
    return 0 if $path =~ m/\/precomp_data\.h\z/;
    return 1;
}

sub process_file {
    my ($path) = @_;
    return unless should_process($path);
    open my $fh, '<', $path or return;
    local $/;
    my $text = <$fh>;
    close $fh;
    my ($new, $changed) = migrate_text($text);
    return unless $changed;
    if ($check) {
        print "would change: $path\n";
        return;
    }
    open my $out, '>', $path or die "write $path: $!";
    print $out $new;
    close $out;
    print "migrated: $path\n";
}

find(
    {
        wanted => sub {
            return if -d $_;
            my $p = $File::Find::name;
            return if $p =~ m/\/\.[^\/]+/;
            return if $p =~ m/\/node_modules\//;
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
