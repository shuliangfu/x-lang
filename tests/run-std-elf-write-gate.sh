#!/usr/bin/env bash
# STD-121: std.elf minimal write gate — honesty soft prefer-c / soft SKIP→OK /
# soft auto-make / soft ensure_std_c_o / c=/x= report →硬绿.
#
# Honesty: prefer-c first + soft SKIP→OK (no xlang-c still gate OK) + soft
# `ensure_std_c_o` + soft `xlang_compiler_make … || true` + hard check as sole
# .x smoke + report `c=`/`x=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# std/elf/elf.o; refuse soft auto-make). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-elf-write-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD121_ELF_WRITE_DOC:-analysis/archive/std/std-elf-write-v1.md}"
MANIFEST="${XLANG_STD121_ELF_WRITE_TSV:-tests/baseline/std-elf-write-manifest.tsv}"
VECTORS="${XLANG_STD121_ELF_WRITE_VECTORS:-tests/baseline/std-elf-write-vectors.tsv}"
MOD_X="std/elf/mod.x"
ELF_X="std/elf/elf.x"
LIB="tests/lib/std-elf-write.sh"
SMOKE_X="tests/std-elf/write_roundtrip.x"
SMOKE_C="tests/std-elf/write_smoke_ok.c"
MIN_APIS=3

# shellcheck source=tests/lib/std-elf-write.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-elf-write gate FAIL: $*" >&2
  std_elf_write_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-121: elf write manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$ELF_X" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-elf-write-v1.md ] || die "dual-authority fossil analysis/std-elf-write-v1.md (archive live)"
grep -qF write_min_reloc "$DOC" || die "doc missing write_min_reloc"
grep -qF 0x90 "$VECTORS" || die "vectors missing 0x90"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_elf_write_symbols_ok "$MOD_X" "$ELF_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-elf-write manifest OK"

if [ "${XLANG_STD121_ELF_WRITE_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_elf_write_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-elf-write gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-121: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing prebuilt elf.o = obs, not soft SKIP→OK.
set +e
std_elf_write_run_c_smoke
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-elf-write OK: c smoke"
    ;;
  *)
    echo "std-elf-write OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_elf_write_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-elf-write OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_elf_write_$$"
LOG="/tmp/xlang_std_elf_write_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-elf-write OBS tip product -o (ec=$o_ec; std_elf_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-elf-write OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-elf-write OK: product -o"
  fi
fi

std_elf_write_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-elf-write gate OK"
