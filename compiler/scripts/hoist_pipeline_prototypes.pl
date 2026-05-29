#!/usr/bin/env perl
# 将 pipeline_gen.c 中散落的 ast_pipeline_* / ast_ast_arena_* extern 声明，
# 以及 pipeline_glue.c 中 ast_pipeline_* 实现的原型，提升到 pipeline_gen.c 头部。
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $gen_path = $ARGV[0] or die "usage: hoist_pipeline_prototypes.pl pipeline_gen.c\n";
open my $gf, '<', $gen_path or die "open $gen_path: $!\n";
local $/;
my $src = <$gf>;
close $gf;

exit 0 if index($src, "/* hoisted ast_pipeline */") >= 0;

my @decls = ($src =~ /^extern .*(?:ast_pipeline_\w+|ast_ast_arena_\w+)\([^;]*\);\n/mg);

my $glue_path = abs_path(dirname($gen_path) . '/pipeline_glue.c');
if (-f $glue_path) {
  open my $gl, '<', $glue_path or die "open $glue_path: $!\n";
  my $glue = do { local $/; <$gl> };
  close $gl;
  while ($glue =~ /((?:void|int32_t|int|uint8_t|struct\s+ast_\w+\s*\*?)\s+(ast_pipeline_\w+)\s*\((?:[^()]*|\([^()]*\))*\))\s*\{/gs) {
    push @decls, "extern $1;\n";
  }
}

my %seen;
@decls = grep { !$seen{$_}++ } @decls;
exit 0 unless @decls;

my $block = "/* hoisted ast_pipeline */\n" . join("", @decls) . "\n";
$src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$block/s
  or die "hoist_pipeline_prototypes: PipelineDepCtx anchor not found\n";

open my $out, '>', $gen_path or die "write $gen_path: $!\n";
print $out $src;
close $out;
