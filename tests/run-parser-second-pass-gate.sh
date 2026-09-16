#!/usr/bin/env bash
# build_asm/parser.o second-pass smoke honesty gate.
#
# ENTRY_MODULE_ONLY + SKIP_TYPECK must emit non-empty __text (historical
# ast_pool truncated-module stub left wave309). Strict link still uses
# parser_x.o; this gate keeps experimental/second pass from regressing
# to an empty parser.o.
#
# Honesty: soft XLANG_PARSER_SECOND_PASS_FAIL retired — compile/empty/
# unexpected-U/__text/combined soft die→exit0 were portable false-green.
# Live authority: tests/baseline/parser-second-pass.tsv (EMIT_HEAVY mins) +
# analysis/archive/phase/phase-parser-soft-fail0-honesty.md ## Gate.
# Stretch/combined_audit under-target = observational (eng matrix T=no).
#
# Report: text=/combined=/nm=/obs=/skip=
# PLATFORM: LINUX gold · DARWIN N/A (honest skip).
# Usage:
#   ./tests/run-parser-second-pass-gate.sh
#   XLANG_PARSER_SECOND_PASS_EMIT_HEAVY=1 ./tests/run-parser-second-pass-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-parser-soft-fail0-honesty.md"
ENG_DOC="analysis/archive/eng/eng-quality-gate-v1.md"
PREFIX="xlang: [XLANG_PARSER_SECOND_PASS]"

TEXT_OK=0
COMBINED_OK=0
NM_OK=0
OBS=0
SKIP=1

die() {
  echo "parser-second-pass-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail text=${TEXT_OK:-0} combined=${COMBINED_OK:-0} nm=${NM_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

report_ok() {
  echo "${PREFIX} status=ok text=${TEXT_OK:-0} combined=${COMBINED_OK:-0} nm=${NM_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate$' "$DOC" || die "doc missing ## Gate honesty section"
[ -f "$ENG_DOC" ] || die "missing $ENG_DOC"
grep -qE '^## Gate$' "$ENG_DOC" || die "eng doc missing ## Gate honesty section"
if [ -f analysis/phase-parser-soft-fail0-honesty.md ]; then
  die "top-level analysis/phase-parser-soft-fail0-honesty.md resurrected (live = archive/phase/)"
fi
if [ -f analysis/eng-quality-gate-v1.md ]; then
  die "top-level analysis/eng-quality-gate-v1.md resurrected (live = archive/eng/)"
fi

# x_len must match symbol name length; drift makes combined metrics blind.
if [ "${XLANG_PARSER_SAFE_HELPER_LEN_GATE:-1}" = "1" ]; then
  chmod +x tests/run-parser-safe-helper-len-gate.sh 2>/dev/null || true
  ./tests/run-parser-safe-helper-len-gate.sh
fi

# EMIT_HEAVY: symbol integrity (BOOT-008). Child soft FAIL already retired.
if [ "${XLANG_PARSER_THIN_GLUE_SYMBOL_INTEGRITY:-1}" = "1" ]; then
  chmod +x tests/run-parser-thin-glue-symbol-integrity-gate.sh 2>/dev/null || true
  ./tests/run-parser-thin-glue-symbol-integrity-gate.sh
fi

EMIT_HEAVY=${XLANG_PARSER_SECOND_PASS_EMIT_HEAVY:-0}
WPO_DCE=${XLANG_PARSER_SECOND_PASS_WPO_DCE:-0}
if [ "$EMIT_HEAVY" = "1" ]; then
  # parser.o: slice delegate + safe_helper real-emit floor.
  # WPO_DCE=1 intentionally shrinks parser.o __text; keep a non-empty floor
  # and rely on combined (parser.o + thin_glue) as the mass hard gate.
  if [ "$WPO_DCE" = "1" ]; then
    MIN_TEXT="${XLANG_PARSER_SECOND_PASS_MIN_TEXT:-2048}"
  else
    MIN_TEXT="${XLANG_PARSER_SECOND_PASS_MIN_TEXT:-10000}"
  fi
  # combined: parser.o + thin_glue; after full parser_x link thin_glue no longer
  # carries seed parse_into_buf C (~9KB), so default combined floor is 125KB.
  MIN_COMBINED="${XLANG_PARSER_SECOND_PASS_MIN_COMBINED:-125000}"
  # stretch: audit bytes including parser_x-side parse_into_buf C (~9434B);
  # tracking only (not a link object).
  STRETCH_COMBINED="${XLANG_PARSER_SECOND_PASS_STRETCH_COMBINED:-150000}"
  SEED_PARSE_METRIC_BYTES="${XLANG_PARSER_SECOND_PASS_SEED_METRIC_BYTES:-9434}"
else
  MIN_TEXT="${XLANG_PARSER_SECOND_PASS_MIN_TEXT:-16}"
  MIN_COMBINED=0
  STRETCH_COMBINED=0
  SEED_PARSE_METRIC_BYTES=0
fi
EH_SUFFIX=""
[ "$EMIT_HEAVY" = "1" ] && EH_SUFFIX=", EMIT_HEAVY"
[ "$EMIT_HEAVY" = "1" ] && [ "$WPO_DCE" = "1" ] && EH_SUFFIX="${EH_SUFFIX}, WPO_DCE=1"
# Match build_xlang_asm compile_x (must run under compiler/).
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "parser-second-pass-gate: N/A on Darwin (Linux covers second-pass emit)"
  report_ok
  exit 0
fi

COMP_IN="./xlang_asm"
if [ -n "${XLANG_PARSER_SECOND_PASS_COMPILER:-}" ]; then
  case "${XLANG_PARSER_SECOND_PASS_COMPILER}" in
    compiler/*) COMP_IN="./${XLANG_PARSER_SECOND_PASS_COMPILER#compiler/}" ;;
    *) COMP_IN="${XLANG_PARSER_SECOND_PASS_COMPILER}" ;;
  esac
fi
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh
COMP_PATH="compiler/$COMP_IN"
[ -x "$COMP_PATH" ] || COMP_PATH="$COMP_IN"
if [ ! -x "$COMP_PATH" ] || ! comp_riscv64_native_xlang "$COMP_PATH"; then
  SKIP=1
  echo "parser-second-pass-gate: SKIP (no native $COMP_IN; seed/C-only build)"
  echo "parser-second-pass-gate OK (SKIP no native xlang_asm)"
  report_ok
  exit 0
fi

TMP="/tmp/xlang_parser_second_pass_gate.$$.o"
rm -f "$TMP" 2>/dev/null || true

echo "parser-second-pass-gate: compile parser.x (ENTRY_MODULE_ONLY + SKIP_TYPECK${EH_SUFFIX}) with compiler/$COMP_IN ..."
PASS_ENV="env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1"
if [ "$EMIT_HEAVY" = "1" ]; then
  PASS_ENV="$PASS_ENV XLANG_ASM_ENTRY_EMIT_HEAVY=1"
  if [ "$WPO_DCE" = "1" ]; then
    PASS_ENV="$PASS_ENV XLANG_ASM_WPO_DCE=1"
  else
    PASS_ENV="$PASS_ENV XLANG_ASM_WPO_DCE=0"
  fi
fi
if ! (
  cd compiler
  $PASS_ENV \
    "$COMP_IN" -backend asm -o "$TMP" $LIBROOT src/parser/parser.x
) > /tmp/xlang_parser_sp_gate.log 2>&1; then
  echo "parser-second-pass-gate FAIL: compile command failed" >&2
  tail -n 12 /tmp/xlang_parser_sp_gate.log 2>/dev/null || true
  rm -f "$TMP" /tmp/xlang_parser_sp_gate.log 2>/dev/null || true
  die "compile command failed"
fi

if grep -q 'asm_codegen_elf_o failed' /tmp/xlang_parser_sp_gate.log 2>/dev/null; then
  echo "parser-second-pass-gate FAIL: asm_codegen_elf_o failed in log" >&2
  tail -n 8 /tmp/xlang_parser_sp_gate.log 2>/dev/null || true
  rm -f "$TMP" /tmp/xlang_parser_sp_gate.log 2>/dev/null || true
  die "asm_codegen_elf_o failed"
fi

if [ ! -s "$TMP" ]; then
  rm -f "$TMP" /tmp/xlang_parser_sp_gate.log 2>/dev/null || true
  die "empty output $TMP"
fi

TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
if [ -z "$TEXT_HEX" ]; then
  TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
fi
TEXT=$(perl -e 'print hex(shift)' "$TEXT_HEX" 2>/dev/null || echo 0)

# EMIT_HEAVY: report thin_glue __text (progress only; not in hard min alone).
GLUE_TEXT=0
GLUE_OBJ="compiler/parser_asm_thin_glue.o"
if [ "$EMIT_HEAVY" = "1" ] && [ -f "$GLUE_OBJ" ]; then
  GLUE_HEX=$(objdump -h "$GLUE_OBJ" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  if [ -z "$GLUE_HEX" ]; then
    GLUE_HEX=$(objdump -h "$GLUE_OBJ" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  fi
  GLUE_TEXT=$(perl -e 'print hex(shift)' "$GLUE_HEX" 2>/dev/null || echo 0)
fi
# audit: dynamic seed parse_into_buf C size (thin_glue with/without NO_SEED).
if [ "$EMIT_HEAVY" = "1" ] && [ "${XLANG_PARSER_SECOND_PASS_SEED_METRIC_DYNAMIC:-1}" = "1" ]; then
  SEED_METRIC_TMP="/tmp/xlang_parser_seed_metric.$$.o"
  SEED_METRIC_TMP2="/tmp/xlang_parser_seed_metric_noseed.$$.o"
  THIN_SRC="compiler/seeds/parser_asm_thin_c.from_x.c"
  if [ -f "$THIN_SRC" ] && command -v cc >/dev/null 2>&1; then
    if cc -Wall -Icompiler -Icompiler/include -Icompiler/src -Icompiler/src/lexer \
      -c -o "$SEED_METRIC_TMP" "$THIN_SRC" 2>/dev/null \
      && cc -Wall -Icompiler -Icompiler/include -Icompiler/src -Icompiler/src/lexer \
        -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -c -o "$SEED_METRIC_TMP2" "$THIN_SRC" 2>/dev/null; then
      SH=$(objdump -h "$SEED_METRIC_TMP" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
      SN=$(objdump -h "$SEED_METRIC_TMP2" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
      if [ -n "$SH" ] && [ -n "$SN" ]; then
        SEED_PARSE_METRIC_BYTES=$(perl -e 'print hex(shift)-hex(shift)' "$SH" "$SN" 2>/dev/null || echo "$SEED_PARSE_METRIC_BYTES")
        [ "${SEED_PARSE_METRIC_BYTES:-0}" -lt 0 ] 2>/dev/null && SEED_PARSE_METRIC_BYTES=0
      fi
    fi
  fi
  rm -f "$SEED_METRIC_TMP" "$SEED_METRIC_TMP2" 2>/dev/null || true
fi
COMBINED_TEXT=$((TEXT + GLUE_TEXT))
COMBINED_AUDIT=$((COMBINED_TEXT + SEED_PARSE_METRIC_BYTES))
TEXT_SUFFIX=""
[ "$EMIT_HEAVY" = "1" ] && TEXT_SUFFIX=" (thin_glue=${GLUE_TEXT}B combined=${COMBINED_TEXT}B audit=${COMBINED_AUDIT}B)"

# EMIT_HEAVY: thin delegates must bl→*_glue; allowlist catches c_len trunc
# (garbage short names), not legitimate link-time UNDEFs from heavy emit.
# G.7: single authority = this case list (short + module-prefixed families).
if [ "$EMIT_HEAVY" = "1" ] && [ -f "$TMP" ]; then
  NM_BAD=0
  while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    # Families: thin/glue, ast_*/ast_ast_*, pipeline_*, fs_*/std_fs_*,
    # lexer_*/lexer_lexer_*, libc mem*, xlang_panic*/trait_*. Comments must
    # not sit between | continuations (bash case syntax).
    case "$sym" in
      parser_*_glue|\
      parser_asm_*|\
      parser_lex_from_*|\
      parser_lex_copy_from_collect_imports|\
      parser_slice_from_buf|\
      parser_diagnostic_*|\
      parser_report_*|\
      ast_arena_*|\
      ast_pool_*|\
      ast_*|\
      pipeline_*|\
      compound_assign_token_to_expr_kind_from_glue|\
      fs_*|\
      std_fs_*|\
      lexer_*|\
      memcpy|memmove|memset|memcmp|\
      ref_is_null|\
      xlang_panic*|\
      xlang_trait_*)
        ;;
      *)
        echo "parser-second-pass-gate FAIL: unexpected U $sym (delegate c_len trunc?)" >&2
        NM_BAD=1
        ;;
    esac
  done <<EOF
$(nm -u "$TMP" 2>/dev/null | awk '{print $2}' | sort -u)
EOF
  if [ "$NM_BAD" -eq 1 ]; then
    rm -f "$TMP" /tmp/xlang_parser_sp_gate.log 2>/dev/null || true
    die "unexpected undefined symbols (delegate c_len trunc?)"
  fi
  NM_OK=1
else
  NM_OK=1
fi

rm -f "$TMP" /tmp/xlang_parser_sp_gate.log 2>/dev/null || true

if [ "${TEXT:-0}" -lt "$MIN_TEXT" ] 2>/dev/null; then
  die "__text=${TEXT}B < min ${MIN_TEXT}B${TEXT_SUFFIX}"
fi
TEXT_OK=1

if [ "$EMIT_HEAVY" = "1" ] && [ "${COMBINED_TEXT:-0}" -lt "$MIN_COMBINED" ] 2>/dev/null; then
  die "combined=${COMBINED_TEXT}B < min_combined ${MIN_COMBINED}B${TEXT_SUFFIX}"
fi
if [ "$EMIT_HEAVY" = "1" ]; then
  COMBINED_OK=1
else
  COMBINED_OK=1
fi

# Stretch / baseline under-target: observational only (eng matrix T=no).
if [ "$EMIT_HEAVY" = "1" ] && [ "${STRETCH_COMBINED:-0}" -gt 0 ] 2>/dev/null; then
  if [ "${COMBINED_AUDIT:-0}" -lt "$STRETCH_COMBINED" ] 2>/dev/null; then
    echo "parser-second-pass-gate OBS STRETCH: combined_audit=${COMBINED_AUDIT}B < stretch ${STRETCH_COMBINED}B${TEXT_SUFFIX}" >&2
    OBS=1
  fi
fi

BASELINE_FILE="${XLANG_PARSER_SECOND_PASS_BASELINE:-tests/baseline/parser-second-pass.tsv}"
if [ "$EMIT_HEAVY" = "1" ] && [ -f "$BASELINE_FILE" ]; then
  BASELINE_MIN_O=$(awk -F'\t' '$1=="min_parser_o_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE_FILE" 2>/dev/null)
  if [ -z "$BASELINE_MIN_O" ]; then
    BASELINE_MIN_O=$(awk -F'\t' '$1=="parser_o_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE_FILE" 2>/dev/null)
  fi
  if [ -n "$BASELINE_MIN_O" ] && [ "${TEXT:-0}" -lt "$BASELINE_MIN_O" ] 2>/dev/null; then
    echo "parser-second-pass-gate OBS BASELINE: parser.o __text=${TEXT}B < min ${BASELINE_MIN_O}B${TEXT_SUFFIX}" >&2
    OBS=1
  fi
fi

SKIP=0
if [ "$EMIT_HEAVY" = "1" ]; then
  echo "parser-second-pass-gate OK (__text=${TEXT}B >= ${MIN_TEXT}B, combined=${COMBINED_TEXT}B >= ${MIN_COMBINED}B, audit=${COMBINED_AUDIT}B stretch=${STRETCH_COMBINED}B, EMIT_HEAVY=${EMIT_HEAVY})"
else
  echo "parser-second-pass-gate OK (__text=${TEXT}B >= ${MIN_TEXT}B, EMIT_HEAVY=${EMIT_HEAVY})"
fi
report_ok
exit 0
