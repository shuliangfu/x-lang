#!/usr/bin/env perl
# Hoist scattered ast_pipeline_* / ast_ast_arena_* extern decls to the head of
# pipeline_gen.c (after PipelineDepCtx).
#
# wave967: pipeline_glue.c left wave309 — do NOT scan deleted glue for
# prototypes (silent -f skip was fake authority). Authority = decls already
# present in the gen TU (pipeline.x -E-extern / runtime_pipeline_abi link).
# PLATFORM: SHARED — archaeology honesty; Stage2 / glue_types path.
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $gen_path = $ARGV[0] or die "usage: hoist_pipeline_prototypes.pl pipeline_gen.c\n";

# wave967: refuse resurrected pipeline_glue.c fossils as a second prototype
# authority (G.7) — check before idempotent early-exit so archaeology stays honest.
my $glue_path = abs_path(dirname($gen_path) . '/pipeline_glue.c');
if (-e $glue_path) {
  die "hoist_pipeline_prototypes: REFUSED pipeline_glue.c at $glue_path\n"
    . "  (retired wave309; do not scrape deleted mega glue — fake dual authority)\n"
    . "  Live: decls in gen TU + runtime_pipeline_abi / pipeline.x pure-extern.\n";
}

open my $gf, '<', $gen_path or die "open $gen_path: $!\n";
local $/;
my $src = <$gf>;
close $gf;

exit 0 if index($src, "/* hoisted ast_pipeline */") >= 0;

my @decls = ($src =~ /^extern .*(?:ast_pipeline_\w+|ast_ast_arena_\w+)\([^;]*\);\n/mg);

my %seen;
@decls = grep { !$seen{$_}++ } @decls;
exit 0 unless @decls;

my $block = "/* hoisted ast_pipeline */\n" . join("", @decls) . "\n";
$src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$block/s
  or die "hoist_pipeline_prototypes: PipelineDepCtx anchor not found\n";

open my $out, '>', $gen_path or die "write $gen_path: $!\n";
print $out $src;
close $out;
