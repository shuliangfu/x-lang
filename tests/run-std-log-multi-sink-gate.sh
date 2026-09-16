#!/usr/bin/env bash
# STD-053: std.log multi-sink + level filter gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# level_filter.x -o exit0 = hard run (run=1). check / host-C archaeology = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-log-multi-sink-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_LOG_MULTI_SINK_DOC:-analysis/archive/std/std-log-multi-sink-v1.md}"
MANIFEST="${XLANG_STD_LOG_MULTI_SINK_TSV:-tests/baseline/std-log-multi-sink.tsv}"
VECTORS="${XLANG_STD_LOG_MULTI_SINK_VECTORS:-tests/baseline/std-log-multi-sink-vectors.tsv}"
MOD_X="std/log/mod.x"
LOG_X="std/log/log.x"
LOG_RUNTIME="compiler/seeds/runtime_log_os.from_x.c"
LIB="tests/lib/std-log-multi-sink.sh"
SMOKE_X="tests/std-log/level_filter.x"
SMOKE_C="tests/std-log/multi_sink_ok.c"
MIN_APIS=6
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-log-multi-sink.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-log-multi-sink gate FAIL: $*" >&2
  std_log_multi_sink_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-053: log multi-sink manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$LOG_X" "$LOG_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-053 SINK_STDERR XLANG_LOG_MIN_LEVEL Cookbook; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"
grep -qF '[INFO] sink_ok' "$VECTORS" 2>/dev/null || die "vectors missing human_file"

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
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        die "missing api $anchor"
      fi
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_log_multi_sink_symbols_ok "$MOD_X" "$LOG_X" "$LOG_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-log-multi-sink manifest OK"

if [ "${XLANG_STD_LOG_MULTI_SINK_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_log_multi_sink_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-log-multi-sink gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-053: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# Host-C archaeology = obs only; refuse soft ensure/auto-make rebuild.
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_log_multi_sink_run_c_smoke; then
  echo "std-log-multi-sink c smoke OK (observational)"
else
  echo "std-log-multi-sink OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std053_log_ms_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-log-multi-sink OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std053_log_ms_$$"
LOG="/tmp/xlang_std053_log_ms_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-log-multi-sink OK: product -o"

std_log_multi_sink_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-log-multi-sink gate OK"
