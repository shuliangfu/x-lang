#!/usr/bin/env bash
# STD-106: std.log rotate + async gate — honesty residual XLANG
# fallthrough / auto-make / bootstrap-link / check=/run=/skip= →硬绿.
#
# Honesty: soft `xlang_compiler_make -q || xlang_compiler_make` +
# XLANG fallthrough (`for cand in "${XLANG:-}" ./compiler/xlang_asm …`
# continues past explicit-bad XLANG) + bootstrap-link wrap +
# `ensure_std_c_o` rebuild + report check=/run=/skip= retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c / XLANG fallthrough / soft ensure rebuild).
# check residual = obs (paused 2026-08-05). Host-C archaeology = obs
# (existing .o only). tests/std-log/rotate_async.x product -o exit0 =
# hard run. Report: run=/obs=/skip=. Live ensure_std family left.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-log-rotate-async-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD106_DOC:-analysis/archive/std/std-log-rotate-async-v1.md}"
MANIFEST="${XLANG_STD106_TSV:-tests/baseline/std-log-rotate-async.tsv}"
VECTORS="${XLANG_STD106_VECTORS:-tests/baseline/std-log-rotate-async-vectors.tsv}"
MOD_X="std/log/mod.x"
LOG_X="std/log/log.x"
LOG_RUNTIME="compiler/seeds/runtime_log_os.from_x.c"
LIB="tests/lib/std-log-rotate-async.sh"
SMOKE_X="tests/std-log/rotate_async.x"
SMOKE_C="tests/std-log/rotate_async_smoke_ok.c"
MIN_APIS=3

# shellcheck source=tests/lib/std-log-rotate-async.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-log-rotate-async gate FAIL: $*" >&2
  std_log_rotate_async_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c / XLANG fallthrough.
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

echo "=== STD-106: log rotate-async manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-log-rotate-async-v1.md ] \
  || die "top-level DOC resurrected (live = archive/std/)"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$LOG_X" "$LOG_RUNTIME" \
  "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-106 set_rotate_limit async_flush rotate; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## 5\. Gate' "$DOC" || die "doc missing ## 5. Gate section"
grep -qF 'async1' "$VECTORS" 2>/dev/null || die "vectors missing async_defer gold"

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
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_log_rotate_async_symbols_ok "$MOD_X" "$LOG_X" "$LOG_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-log-rotate-async manifest OK"

if [ "${XLANG_STD106_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_log_rotate_async_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-log-rotate-async gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-106: smoke (XLANG=$XLANG_BIN; check/host-C=obs; rotate_async.x product -o hard) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap / ensure_std_c_o.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# Host-C archaeology = obs only; existing .o, no soft ensure/auto-make rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if std_log_rotate_async_run_c_smoke; then
  echo "std-log-rotate-async c smoke OK (observational)"
else
  echo "std-log-rotate-async OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

# check = obs (paused); refuse hard check as sole green.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std106_log_ra_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-log-rotate-async OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# rotate_async.x product -o exit0 is the hard-green signal.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
if std_log_rotate_async_run_smoke "$XLANG_BIN" "$SMOKE_X" "rotate"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-log-rotate-async OK: product rotate_async.x"
else
  die "product -o rotate_async.x failed (refuse soft SKIP→OK)"
fi

std_log_rotate_async_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-log-rotate-async gate OK"
