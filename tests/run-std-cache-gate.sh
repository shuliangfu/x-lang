#!/usr/bin/env bash
# STD-087: std.cache gate — honesty residual soft auto-make →硬绿.
#
# Honesty: residual soft auto-make (`xlang_compiler_make … cache.o/time.o/
# runtime_time_os.o || true` before host-C cc) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c). Product
# lru_pool_smoke.x -o exit0 = hard run. check residual = obs (paused
# 2026-08-05). Host-C archaeology = obs only (prebuilt cache.o + time.o +
# runtime_time_os.o; refuse rebuild). Report: run=/obs=/skip=.
# Keep ## 3. Gate. Keep keywords STD-087 / new_lru / put / acquire /
# mark_unhealthy.
# formal_mod: mod.x prefix + cache.x --bare-impl (was std_x bare → std_cache_* UNDEF).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-cache-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_CACHE_DOC:-analysis/archive/std/std-cache-v1.md}"
MANIFEST="${XLANG_STD_CACHE_MANIFEST:-tests/baseline/std-cache-manifest.tsv}"
MOD_X="std/cache/mod.x"
CACHE_X="std/cache/cache.x"
LIB="tests/lib/std-cache.sh"
SMOKE_X="tests/std-cache/lru_pool_smoke.x"
SMOKE_C="tests/std-cache/cache_smoke_ok.c"
README="std/cache/README.md"
MIN_APIS=10

# shellcheck source=tests/lib/std-cache.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-cache gate FAIL: $*" >&2
  std_cache_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-087: std.cache manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CACHE_X" "$SMOKE_X" "$SMOKE_C" "$README"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-cache-v1.md ] || die "dual-authority fossil analysis/std-cache-v1.md (archive live)"

for kw in STD-087 new_lru put acquire mark_unhealthy; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null && ! grep -qF -- "$kw" "$MANIFEST" 2>/dev/null; then
    die "doc/manifest missing '$kw'"
  fi
done

grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

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

sym_miss="$(std_cache_symbols_ok "$MOD_X" "$CACHE_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-cache manifest OK"

if [ "${XLANG_STD_CACHE_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_cache_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-cache gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-087: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing prebuilt .o = obs, not soft SKIP→OK.
set +e
std_cache_host_c_obs "$SMOKE_C"
c_rc=$?
set -e
# Presence / C-smoke success is not a green signal (product honesty is lru_pool_smoke.x).
if [ "$c_rc" -ne 0 ]; then
  echo "std-cache OBS host-C (rc=$c_rc; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
else
  echo "std-cache OBS host-C c smoke present (not a green signal; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_cache_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-cache OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Product lru_pool_smoke.x -o exit0 = hard (leave product UNDEF as a later knife).
# PLATFORM: SHARED — refuse soft SKIP→OK. G.7: lib std_cache_run_smoke.
if std_cache_run_smoke "$XLANG_BIN" "$SMOKE_X" "lru_pool"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-cache OK: product lru_pool_smoke"
else
  die "product -o failed (refuse soft SKIP→OK)"
fi

std_cache_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-cache gate OK"
