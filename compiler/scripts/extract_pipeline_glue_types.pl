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
        # 单行 static inline 保留；多行函数体（如 shulang_panic_）整段跳过。
        if ($line =~ /^static inline .+\{.*\}\s*$/) {
            print $line;
            next;
        }
        if ($line =~ /^static inline .+\{/) {
            $in_body = 1;
            $brace = ($line =~ tr/{//) - ($line =~ tr/}//);
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
        # 多行签名后单独一行 {，或 extract 漏掉函数头时丢弃 orphaned body 行。
        if ($line =~ /^\s*\{/) {
            $in_body = 1;
            $brace = ($line =~ tr/{//) - ($line =~ tr/}//);
            next;
        }
        if ($line =~ /^\s+return\b/ || $line =~ /^\s*\}\s*$/) {
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

# pipeline_glue_standalone TU：ast_pool 依赖但不在 pipeline_gen 前缀中的 runtime 符号（勿重复 pipeline_gen 已有声明）。
my $types_so_far = do { local $/; open my $tf, '<', $path; <$tf> // '' };
if ($types_so_far !~ /driver_diagnostic_asm_elf_unresolved_patch\s*\(/) {
  print <<'EOF';
/** ast_pool standalone：resolve_patches / asm_driver_current_dep_path_for_codegen 依赖。 */
extern void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t name_len);
EOF
}
if ($types_so_far !~ /driver_get_current_dep_path_for_codegen\s*\(/) {
  print <<'EOF';
extern uint8_t *driver_get_current_dep_path_for_codegen(void);
EOF
}
