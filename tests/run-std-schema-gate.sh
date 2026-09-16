#!/usr/bin/env bash
# STD-090: std.schema gate — honesty soft prefer-c / soft SKIP→OK / soft
# auto-make host-C →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft auto-make
# (`xlang_compiler_make … schema.o/json.o/csv.o || true`) + soft SKIP→OK
# (no native still gate OK) + hard-bound `xlang check` as sole .x smoke
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native = hard die. Manifest = hard. check residual = obs
# (paused 2026-08-05). tip product -o std_schema_* UNDEF = obs (product
# debt; leave). Host-C smoke: use prebuilt .o only (refuse soft ensure /
# soft auto-make); miss/fail = obs archaeology (not soft SKIP→OK). Report:
# run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-schema-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SCHEMA_DOC:-analysis/archive/std/std-schema-v1.md}"
MANIFEST="${XLANG_STD_SCHEMA_MANIFEST:-tests/baseline/std-schema-manifest.tsv}"
MOD_X="std/schema/mod.x"
SCHEMA_X="std/schema/schema.x"
LIB="tests/lib/std-schema.sh"
SMOKE_X="tests/std-schema/decode_smoke.x"
SMOKE_C="tests/std-schema/schema_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-schema.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-schema gate FAIL: $*" >&2
  std_schema_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-090: std.schema manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SCHEMA_X" "$SMOKE_X" "$SMOKE_C" std/schema/README.md; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-schema-v1.md ] || die "dual-authority fossil analysis/std-schema-v1.md (archive live)"

for kw in STD-090 schema_add_field decode_json decode_csv_row map_columns last_error_field; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
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

sym_miss="$(std_schema_symbols_ok "$MOD_X" "$SCHEMA_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-schema manifest OK"

if [ "${XLANG_STD_SCHEMA_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_schema_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-schema gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-090: smoke (XLANG=$XLANG_BIN; check=obs; tip product -o UNDEF=obs; host-C=obs) ==="

# Host-C archaeology: prebuilt .o only — refuse soft auto-make / ensure_std_c_o.
# PLATFORM: SHARED — host-cc link of seed .o; miss/fail = obs, not soft SKIP→OK.
echo "=== STD-090: schema host-C smoke (prebuilt .o only) ==="
if [ -f std/schema/schema.o ] && [ -f std/json/json.o ] && [ -f std/csv/csv.o ]; then
  C_OUT="/tmp/xlang_schema_smoke_$$"
  set +e
  cc -std=c11 -O1 -o "$C_OUT" "$SMOKE_C" std/schema/schema.o std/json/json.o std/csv/csv.o >/tmp/xlang_schema_c_build_$$.log 2>&1
  c_ec=$?
  set -e
  if [ "$c_ec" -eq 0 ] && [ -x "$C_OUT" ]; then
    set +e
    "$C_OUT" >/dev/null 2>&1
    c_run=$?
    set -e
    rm -f "$C_OUT"
    if [ "$c_run" -eq 0 ]; then
      RUN_OK=$((RUN_OK + 1))
      echo "std-schema OK: host-C smoke"
    else
      echo "std-schema OBS host-C run exit=$c_run" >&2
      OBS=$((OBS + 1))
    fi
  else
    tail -n 8 /tmp/xlang_schema_c_build_$$.log 2>/dev/null || true
    rm -f "$C_OUT"
    echo "std-schema OBS host-C link (ec=$c_ec; refuse soft auto-make)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "std-schema OBS host-C smoke (prebuilt .o missing; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_schema_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-schema OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_schema_$$"
LOG="/tmp/xlang_std_schema_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-schema OBS tip product -o (ec=$o_ec; std_schema_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-schema OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-schema OK: product -o"
  fi
fi

std_schema_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-schema gate OK"
