#!/usr/bin/env perl
# patch_export_gen_structs.pl — ensure export fields exist in ignored *_gen.c snapshots
# (pipeline_gen.c etc. are gitignored; Ubuntu hosts keep stale layouts without is_export.)
use strict;
use warnings;

my @files = @ARGV;
if (!@files) {
  @files = (
    "compiler/pipeline_gen.c",
    "compiler/parser_gen.c",
    "compiler/typeck_gen.c",
    "compiler/driver_gen.c",
    "compiler/codegen_gen.c",
    "compiler/lsp_diag_gen.c",
    "compiler/driver_compile_gen.c",
    "compiler/driver_run_gen.c",
    "compiler/driver_emit_gen.c",
  );
}

for my $f (@files) {
  next unless -f $f;
  open my $fh, "<", $f or die $!;
  local $/; my $s = <$fh>; close $fh;
  my $orig = $s;

  # Func: append is_export after is_variadic if missing
  $s =~ s/
    (struct\s+ast_Func\s*\{[^}]*is_variadic;\s*)
    (?!int32_t\s+is_export;)
  /$1int32_t is_export; /x
    unless $s =~ /struct\s+ast_Func\s*\{[^}]*is_export/;

  # StructLayout: append is_export after repr_compatible
  $s =~ s/
    (struct\s+ast_StructLayout\s*\{[^}]*repr_compatible;\s*)
    (?!int32_t\s+is_export;)
  /$1int32_t is_export; /x
    unless $s =~ /struct\s+ast_StructLayout\s*\{[^}]*is_export/;

  # Module: pending_export before num_module_enums
  $s =~ s/
    (struct\s+ast_Module\s*\{[^}]*pending_interrupt;\s*)
    (?!int32_t\s+pending_export;)
  /$1int32_t pending_export; /x
    unless $s =~ /struct\s+ast_Module\s*\{[^}]*pending_export/;

  # TOKEN_EXPORT at end of TokenKind (before closing }; of enum) if missing
  # Only if TOKEN_STRING is last before }
  if ($s !~ /token_TokenKind_TOKEN_EXPORT/) {
    $s =~ s/(token_TokenKind_TOKEN_STRING)(\s*\};)/$1, token_TokenKind_TOKEN_EXPORT$2/;
  }

  if ($s ne $orig) {
    open my $out, ">", $f or die $!;
    print $out $s;
    close $out;
    print "patched $f\n";
  } else {
    print "ok $f\n";
  }
}
