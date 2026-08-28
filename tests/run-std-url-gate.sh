#!/usr/bin/env bash
# STD-076: std.url gate — honesty residual soft auto-make →硬绿.
#
# Honesty: residual soft auto-make (`xlang_compiler_make … url.o || true`
# before host-C cc) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c). Product roundtrip.x -o exit0 = hard run.
# check residual = obs (paused 2026-08-05). Host-C archaeology = obs only
# (prebuilt .o; refuse rebuild). Report: run=/obs=/skip=. Keep ## 3. Gate.
# Keep keywords STD-076 / parse / build / query_encode / resolve / IPv6.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-url-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_URL_DOC:-analysis/archive/std/std-url-v1.md}"
MANIFEST="${XLANG_STD_URL_MANIFEST:-tests/baseline/std-url-manifest.tsv}"
VECTORS="${XLANG_STD_URL_VECTORS:-tests/baseline/std-url-vectors.tsv}"
MOD_X="std/url/mod.x"
URL_X="std/url/url.x"
LIB="tests/lib/std-url.sh"
SMOKE_X="tests/std-url/roundtrip.x"
SMOKE_C="tests/std-url/url_smoke_ok.c"
README="std/url/README.md"
MIN_APIS=6

# shellcheck source=tests/lib/std-url.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-url gate FAIL: $*" >&2
  std_url_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-076: std.url manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$URL_X" "$SMOKE_X" "$SMOKE_C" "$README"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-url-v1.md ] || die "dual-authority fossil analysis/std-url-v1.md (archive live)"

for kw in STD-076 parse build query_encode resolve IPv6; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
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

sym_miss="$(std_url_symbols_ok "$MOD_X" "$URL_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-url manifest OK"

if [ "${XLANG_STD_URL_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_url_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-url gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-076: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing prebuilt .o = obs, not soft SKIP→OK.
set +e
std_url_host_c_obs "$SMOKE_C"
c_rc=$?
set -e
# Presence / C-smoke success is not a green signal (product honesty is roundtrip.x).
if [ "$c_rc" -ne 0 ]; then
  echo "std-url OBS host-C (rc=$c_rc; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
else
  echo "std-url OBS host-C c smoke present (not a green signal; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_url_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-url OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Product roundtrip.x -o exit0 = hard (leave product UNDEF as a later knife).
# PLATFORM: SHARED — refuse soft SKIP→OK. G.7: lib std_url_run_smoke.
if std_url_run_smoke "$XLANG_BIN" "$SMOKE_X" "roundtrip"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-url OK: product roundtrip"
else
  die "product -o failed (refuse soft SKIP→OK)"
fi

std_url_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-url gate OK"
