#!/usr/bin/env perl
# patch_export_gen_structs.pl — ensure export support in ignored *_gen.c snapshots
# (pipeline_gen.c / lexer_gen.c are gitignored; Ubuntu hosts often keep stale layouts.)
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
  local $/;
  my $s = <$fh>;
  close $fh;
  my $orig = $s;

  # Func: append is_export after is_variadic if missing
  if ($s !~ /struct\s+ast_Func\s*\{[^}]*is_export/) {
    $s =~ s/(struct\s+ast_Func\s*\{[^}]*is_variadic;\s*)/$1int32_t is_export; /x;
  }

  # StructLayout: append is_export after repr_compatible
  if ($s !~ /struct\s+ast_StructLayout\s*\{[^}]*is_export/) {
    $s =~ s/(struct\s+ast_StructLayout\s*\{[^}]*repr_compatible;\s*)/$1int32_t is_export; /x;
  }

  # Module: pending_export before num_module_enums
  if ($s !~ /struct\s+ast_Module\s*\{[^}]*pending_export/) {
    $s =~ s/(struct\s+ast_Module\s*\{[^}]*pending_interrupt;\s*)/$1int32_t pending_export; /x;
  }

  # TOKEN_EXPORT at end of TokenKind if missing
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

# lexer_gen.c: keyword "export" (bytes e x p o r t = 101,120,112,111,114,116)
my $lex = "compiler/lexer_gen.c";
if (-f $lex) {
  open my $fh, "<", $lex or die $!;
  local $/;
  my $s = <$fh>;
  close $fh;
  my $orig = $s;

  if ($s !~ /101, 120, 112, 111, 114, 116/) {
    my $block_kw = <<'BLOCK';
  if (len == 6 && lexer_match_keyword(data, start, 6, &((struct xlang_slice_uint8_t){ .data = (uint8_t[]){ 101, 120, 112, 111, 114, 116 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EXPORT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
  }
BLOCK
    my $block_buf = <<'BLOCK';
  if (len == 6 && lexer_match_keyword_buf(data, data_len, start, 6, &((struct xlang_slice_uint8_t){ .data = (uint8_t[]){ 101, 120, 112, 111, 114, 116 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EXPORT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
  }
BLOCK
    # Insert after each TOKEN_SPAWN return block (two paths: match_keyword / match_keyword_buf)
    my $n = 0;
    $s =~ s{
      (token_TokenKind_TOKEN_SPAWN,\s*\.line\s*=\s*line0,\s*\.col\s*=\s*col0,\s*\.int_val\s*=\s*0,\s*\.float_val\s*=\s*0\.0,\s*\.ident\s*=\s*0,\s*\.ident_len\s*=\s*0\s*\};\s*return\s*t;\s*\})
    }{
      $n++;
      my $ins = ($n == 1) ? $block_kw : $block_buf;
      "$1\n$ins";
    }gex;

    if ($s !~ /101, 120, 112, 111, 114, 116/) {
      # fallback: after first TOKEN_EXTERN keyword block
      $s =~ s{
        (token_TokenKind_TOKEN_EXTERN,\s*\.line\s*=\s*line0,\s*\.col\s*=\s*col0,\s*\.int_val\s*=\s*0,\s*\.float_val\s*=\s*0\.0,\s*\.ident\s*=\s*0,\s*\.ident_len\s*=\s*0\s*\};\s*return\s*t;\s*\})
      }{$1\n$block_kw}x;
    }
  }

  if ($s ne $orig) {
    open my $out, ">", $lex or die $!;
    print $out $s;
    close $out;
    print "patched $lex (export keyword)\n";
  } else {
    print(($s =~ /101, 120, 112, 111, 114, 116/)
      ? "ok $lex (export keyword present)\n"
      : "warn $lex (export keyword still missing)\n");
  }
}
