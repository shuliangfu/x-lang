#!/usr/bin/env perl
# extract_pipeline_glue_types.pl — 从 pipeline_gen.c 抽取 glue+ast_pool 独立 TU 所需类型/extern，不含 .su 函数体。
# 用法：perl scripts/extract_pipeline_glue_types.pl pipeline_gen.c > build_asm/pipeline_glue_types.inc
use strict;
use warnings;

my $path = shift @ARGV or die "usage: $0 pipeline_gen.c\n";
open my $fh, '<', $path or die "open $path: $!\n";

my $in_body = 0;
my $brace   = 0;

while (my $line = <$fh>) {
    last if $line =~ /^#include "pipeline_glue\.c"/;

    if (!$in_body) {
        if ($line =~ /^#include/ || $line =~ /^typedef/ || $line =~ /^struct .*;\s*$/) {
            print $line;
            next;
        }
        if ($line =~ /^enum / && $line !~ /\(/) {
            print $line;
            next;
        }
        if ($line =~ /^extern .+;\s*$/) {
            print $line;
            next;
        }
        if ($line =~ /^static inline .+;\s*$/) {
            print $line;
            next;
        }
        if ($line =~ /^static inline .+\{/) {
            print $line;
            next;
        }
        if ($line =~ /^struct .+\{.*\};\s*$/) {
            print $line;
            next;
        }
        if ($line =~ /^\/\*/ || $line =~ /^\s*\*\/\s*$/ || $line =~ /^\s*\*\s/) {
            print $line;
            next;
        }
        if ($line =~ /parser_[a-zA-Z0-9_]+\([^;]*\)\s*\{/) {
            $in_body = 1;
            $brace = ($line =~ tr/{//) - ($line =~ tr/}//);
            next;
        }
        if ($line =~ /^[a-zA-Z_][\w\s\*]*\([^;]*\)\s*\{/) {
            $in_body = 1;
            $brace = ($line =~ tr/{//) - ($line =~ tr/}//);
            next;
        }
        if ($line =~ /^[a-zA-Z_][\w\s\*]*\([^;]*\)\s*$/) {
            my $next = <$fh>;
            if (defined $next && $next =~ /^\s*\{/) {
                $in_body = 1;
                $brace = ($next =~ tr/{//) - ($next =~ tr/}//);
                next;
            }
            print $line;
            print $next if defined $next;
            next;
        }
        print $line if $line =~ /\S/;
        next;
    }

    $brace += ($line =~ tr/{//) - ($line =~ tr/}//);
    $in_body = 0 if $brace <= 0;
}

close $fh;
