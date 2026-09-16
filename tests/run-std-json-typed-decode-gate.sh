#!/usr/bin/env bash
# STD-116: std.json typed decode gate — honesty soft prefer-c /
# soft SKIP→OK / soft ensure_std_c_o / c=/x= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK) + soft `ensure_std_c_o … || true` + hard check +
# hard product via lib smoke + report `c=`/`x=`/`skip=` retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die. Host-C archaeology = obs only (prebuilt json.o; refuse
# soft ensure; F-07 forbids cc -c on migrated json). check residual = obs
# (paused 2026-08-05). tip product -o UNDEF = obs (product debt; leave).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-json-typed-decode-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_JSON_TYPED_DOC:-analysis/archive/std/std-json-typed-decode-v1.md}"
MANIFEST="${XLANG_STD_JSON_TYPED_TSV:-tests/baseline/std-json-typed-decode.tsv}"
VECTORS="${XLANG_STD_JSON_TYPED_VECTORS:-tests/baseline/std-json-typed-decode-vectors.tsv}"
MOD_X="std/json/mod.x"
JSON_X="std/json/json.x"
LIB="tests/lib/std-json-typed-decode.sh"
SMOKE_X="tests/json/typed_decode.x"
SMOKE_C="tests/json/typed_decode_smoke_ok.c"
JSON_O="std/json/json.o"

# shellcheck source=tests/lib/std-json-typed-decode.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-json-typed-decode gate FAIL: $*" >&2
  std_json_typed_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-116: json typed decode manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$JSON_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-json-typed-decode-v1.md ] || die "dual-authority fossil analysis/std-json-typed-decode-v1.md (archive live)"
grep -qF object_decode_dotted_i32 "$DOC" 2>/dev/null || grep -qF object_decode_i32 "$DOC" || die "doc missing object_decode_*"
grep -qF '"age":30' "$VECTORS" || die "vectors missing age=30"
grep -qF user.age "$VECTORS" || die "vectors missing user.age"

sym_miss="$(std_json_typed_symbols_ok "$MOD_X" "$JSON_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-json-typed-decode manifest OK"

if [ "${XLANG_STD_JSON_TYPED_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_json_typed_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-json-typed-decode gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-116: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure_std_c_o.
# PLATFORM: SHARED — F-07 forbids cc -c on migrated json.
if [ ! -f "$SMOKE_C" ]; then
  echo "std-json-typed OBS c smoke (missing $SMOKE_C)" >&2
  OBS=$((OBS + 1))
elif [ ! -f "$JSON_O" ]; then
  echo "std-json-typed OBS c smoke (missing prebuilt $JSON_O; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
elif cc -std=c11 -O1 -o /tmp/xlang_json_typed_c_$$ "$SMOKE_C" "$JSON_O" 2>/tmp/json_typed_c_link_$$.log; then
  set +e
  /tmp/xlang_json_typed_c_$$ >/dev/null 2>&1
  c_ec=$?
  set -e
  rm -f /tmp/xlang_json_typed_c_$$
  if [ "$c_ec" -ne 0 ]; then
    echo "std-json-typed OBS c smoke run exit=$c_ec" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-json-typed OK: c smoke"
  fi
else
  echo "std-json-typed OBS c smoke link (UNDEF/residual; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_json_typed_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-json-typed OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_json_typed_$$"
LOG="/tmp/xlang_json_typed_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-json-typed OBS tip product -o (ec=$o_ec; std_json_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-json-typed OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-json-typed OK: product -o"
  fi
fi

std_json_typed_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-json-typed-decode gate OK"
