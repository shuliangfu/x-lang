#!/usr/bin/env bash
# STD-079: std.security gate — honesty residual soft auto-make →硬绿.
#
# Honesty: residual soft auto-make (`xlang_compiler_make … security.o || true`
# before host-C cc, plus lib auto-make of crypto.o) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c). Product
# roundtrip.x -o exit0 = hard run. check residual = obs (paused 2026-08-05).
# Host-C archaeology = obs only (prebuilt .o; refuse rebuild). Report:
# run=/obs=/skip=. Keep ## 3. Gate. Keep keywords STD-079 / ct_compare /
# hkdf / secure_zero / sensitive_lock / mem_eq.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-security-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SECURITY_DOC:-analysis/archive/std/std-security-v1.md}"
MANIFEST="${XLANG_STD_SECURITY_MANIFEST:-tests/baseline/std-security-manifest.tsv}"
VECTORS="${XLANG_STD_SECURITY_VECTORS:-tests/baseline/std-security-vectors.tsv}"
MOD_X="std/security/mod.x"
SEC_X="std/security/security.x"
LIB="tests/lib/std-security.sh"
SMOKE_X="tests/std-security/roundtrip.x"
SMOKE_C="tests/std-security/security_smoke_ok.c"
README="std/security/README.md"
MIN_APIS=10

# shellcheck source=tests/lib/std-security.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-security gate FAIL: $*" >&2
  std_security_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-079: std.security manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SEC_X" "$SMOKE_X" "$SMOKE_C" "$README"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-security-v1.md ] || die "dual-authority fossil analysis/std-security-v1.md (archive live)"

for kw in STD-079 ct_compare hkdf secure_zero sensitive_lock mem_eq; do
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

sym_miss="$(std_security_symbols_ok "$MOD_X" "$SEC_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-security manifest OK"

if [ "${XLANG_STD_SECURITY_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_security_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-security gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-079: smoke (XLANG=$XLANG_BIN; host-C=obs; check=obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing prebuilt .o = obs, not soft SKIP→OK.
set +e
std_security_host_c_obs "$SMOKE_C"
c_rc=$?
set -e
# Presence / C-smoke success is not a green signal (product honesty is roundtrip.x).
if [ "$c_rc" -ne 0 ]; then
  echo "std-security OBS host-C (rc=$c_rc; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
else
  echo "std-security OBS host-C c smoke present (not a green signal; refuse soft auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_security_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-security OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Product roundtrip.x -o exit0 = hard (leave product UNDEF as a later knife).
# PLATFORM: SHARED — refuse soft SKIP→OK. G.7: lib std_security_run_smoke.
if std_security_run_smoke "$XLANG_BIN" "$SMOKE_X" "roundtrip"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-security OK: product roundtrip"
else
  die "product -o failed (refuse soft SKIP→OK)"
fi

std_security_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-security gate OK"
