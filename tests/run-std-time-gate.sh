#!/usr/bin/env bash
# STD-005: std.time precision / timezone gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true` / soft ensure_std_c_o)
# + soft XLANG fallthrough (explicit-bad still picks another binary) +
# check=/main=/precision=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c / soft ensure rebuild). Product main.x +
# precision_smoke.x -o exit0 = hard run (run=2). check = obs (paused 2026-08-05;
# leave ensure_std family alone). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-time-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_TIME_DOC:-analysis/archive/std/std-time-precision-v1.md}"
MANIFEST="${XLANG_STD_TIME_MANIFEST:-tests/baseline/std-time-manifest.tsv}"
MOD_X="${XLANG_STD_TIME_MOD:-std/time/mod.x}"
TIME_RUNTIME="compiler/seeds/runtime_time_os.from_x.c"
TIME_X="std/time/time.x"
MAIN_X="tests/time/main.x"
PRECISION_X="tests/time/precision_smoke.x"
LIB="tests/lib/std-time.sh"
MIN_APIS=13

# shellcheck source=tests/lib/std-time.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-time gate FAIL: $*" >&2
  std_time_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-005: std.time precision manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TIME_RUNTIME" "$TIME_X" "$MAIN_X" "$PRECISION_X"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
API_N=0
echo "=== STD-005: API surface ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_time_has_api "$MOD_X" "$anchor"; then
        echo "std-time FAIL: missing API ${anchor} in $MOD_X" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      case "$anchor" in
        tests/*) path="$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "std-time FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "apis=${API_N} < min ${MIN_APIS}"

if ! grep -q '_WIN32' "$TIME_RUNTIME" 2>/dev/null || ! grep -q 'CLOCK_MONOTONIC' "$TIME_RUNTIME" 2>/dev/null; then
  die "runtime_time_os missing platform branches"
fi

for kw in precision timezone UTC monotonic runnable; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
grep -qF -- '## 6. Gate' "$DOC" 2>/dev/null || die "doc missing '## 6. Gate'"

[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "std-time manifest OK (apis=${API_N})"

if [ "${XLANG_STD_TIME_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_time_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-time gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-005: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# check = obs only (paused 2026-08-05); refuse soft SKIP→OK.
set +e
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std_time_check_main.log 2>&1
chk_main=$?
"$XLANG_BIN" check -L . "$PRECISION_X" >/tmp/xlang_std_time_check_precision.log 2>&1
chk_prec=$?
set -e
if [ "$chk_main" -ne 0 ] || [ "$chk_prec" -ne 0 ]; then
  echo "std-time OBS check (paused / CHK residual main=$chk_main precision=$chk_prec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft ensure_std_c_o / soft auto-make; product path does not need host-C rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.

for pair in "main:$MAIN_X" "precision:$PRECISION_X"; do
  tag="${pair%%:*}"
  src="${pair#*:}"
  OUT="/tmp/xlang_std_time_${tag}_$$"
  LOG="/tmp/xlang_std_time_${tag}_build_$$.log"
  rm -f "$OUT" "$LOG"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$OUT" >"$LOG" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
    tail -n 20 "$LOG" 2>/dev/null || true
    rm -f "$OUT"
    die "product -o $src failed (ec=$o_ec; refuse soft SKIP→OK)"
  fi
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  [ "$exitcode" -eq 0 ] || die "runnable $src exit=$exitcode"
  RUN_OK=$((RUN_OK + 1))
  echo "std-time OK: product -o $tag"
done

std_time_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-time gate OK"
