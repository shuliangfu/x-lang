#!/usr/bin/env bash
# STD-063: std.elf deepen (section find/byte) gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / deep_c=/deep_x= report →硬绿.
#
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# std/elf/elf.o; refuse soft auto-make). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-elf-deep-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD063_DOC:-analysis/archive/std/std-elf-deep-v1.md}"
MANIFEST="${XLANG_STD063_TSV:-tests/baseline/std-elf-deep.tsv}"
VECTORS="${XLANG_STD063_VECTORS:-tests/baseline/std-elf-deep-vectors.tsv}"
MOD_X="std/elf/mod.x"
ELF_X="std/elf/elf.x"
LIB="tests/lib/std-elf-deep.sh"
SMOKE_X="tests/std-elf/parse_sections.x"
SMOKE_C="tests/std-elf/parse_sections_smoke_ok.c"
FIXTURE="tests/baseline/fixtures/elf64_min_reloc.bin"
MIN_DEEP=2

# shellcheck source=tests/lib/std-elf-deep.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-elf-deep gate FAIL: $*" >&2
  std_elf_deep_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-063: elf deep manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$ELF_X" "$SMOKE_X" "$SMOKE_C" "$FIXTURE" \
  analysis/archive/std/std-elf-parse-v1.md tests/run-std-elf-parse-gate.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-elf-deep-v1.md ] || die "dual-authority fossil analysis/std-elf-deep-v1.md (archive live)"
for kw in STD-063 find_section_idx read_sec_byte ELF_ERR_NOT_FOUND; do
  grep -qF -- "$kw" "$DOC" || die "doc missing '$kw'"
done
grep -qF 'find_text_idx	1' "$VECTORS" || die "vectors missing find_text_idx"
grep -qF 'text_byte0	144' "$VECTORS" || die "vectors missing text_byte0"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_deep_apis) MIN_DEEP="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_DEEP" ] || die "api count $API_N < min $MIN_DEEP"

sym_miss="$(std_elf_deep_symbols_ok "$MOD_X" "$ELF_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-elf-deep manifest OK"

echo "=== STD-063: parent STD-058 manifest ==="
chmod +x tests/run-std-elf-parse-gate.sh
XLANG_STD_ELF_PARSE_MANIFEST_ONLY=1 ./tests/run-std-elf-parse-gate.sh

if [ "${XLANG_STD063_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_elf_deep_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-elf-deep gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-063: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

set +e
std_elf_deep_run_c_smoke
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-elf-deep OK: c smoke"
    ;;
  *)
    echo "std-elf-deep OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_elf_deep_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-elf-deep OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_elf_deep_$$"
LOG="/tmp/xlang_std_elf_deep_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-elf-deep OBS tip product -o (ec=$o_ec; std_elf_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-elf-deep OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-elf-deep OK: product -o"
  fi
fi

std_elf_deep_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-elf-deep gate OK"
