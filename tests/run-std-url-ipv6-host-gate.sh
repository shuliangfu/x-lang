#!/usr/bin/env bash
# STD-134: std.url IPv6 host — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product
# ipv6_host.x -o exit0 = hard run (run+=). check + host-C = obs
# (existing .o only; no soft rebuild). Report: run=/obs=/skip=. G.7: complete
# existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-url-ipv6-host-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_URL_IPV6_HOST_DOC:-analysis/archive/std/std-url-ipv6-host-v1.md}"
MANIFEST="${XLANG_STD_URL_IPV6_HOST_TSV:-tests/baseline/std-url-ipv6-host-manifest.tsv}"
MOD_X="std/url/mod.x"
URL_X="std/url/url.x"
LIB="tests/lib/std-url-ipv6-host.sh"
SMOKE_X="tests/std-url/ipv6_host.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-url-ipv6-host.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-url-ipv6-host gate FAIL: $*" >&2
  std_url_ipv6_host_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== STD-134: std.url IPv6 host manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-url-ipv6-host-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$URL_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-134 host_to_ipv6 format_ipv6_host; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

sym_miss="$(std_url_ipv6_host_symbols_ok "$MOD_X" "$URL_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-url-ipv6-host manifest OK"

if [ "${XLANG_STD_URL_IPV6_HOST_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_url_ipv6_host_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-url-ipv6-host gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-134: smoke (XLANG=$XLANG_BIN; check/C obs; ipv6_host product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std134_chk.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-url-ipv6-host OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Observational host-C archaeology (existing .o only; no soft auto-make).
# PLATFORM: SHARED archaeology — product honesty is ipv6_host.x via asm.
echo "=== STD-134: url c smoke (observational; no soft rebuild) ==="
URL_O="std/url/url.o"
if [ -f "$URL_O" ] && nm "$URL_O" 2>/dev/null | grep -qF 'url_ipv6_host_smoke_c'; then
  if std_url_ipv6_host_run_c_smoke "$URL_O"; then
    echo "std-url-ipv6-host c smoke OK (observational)"
  else
    echo "std-url-ipv6-host OBS c smoke (archaeology residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "std-url-ipv6-host OBS c smoke (no existing .o / symbol; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

OUT="/tmp/xlang_std134_url_ipv6_$$"
LOG="/tmp/xlang_std134_url_ipv6_build_$$.log"
if "$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
  exitcode=0
  "$OUT" >/dev/null 2>&1 || exitcode=$?
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "ipv6_host.x exit=$exitcode (expect $SMOKE_EXPECT; refuse soft SKIP→OK)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-url-ipv6-host OK: ipv6_host"
else
  tail -20 "$LOG" 2>/dev/null >&2 || true
  die "ipv6_host.x link (refuse soft SKIP→OK)"
fi

std_url_ipv6_host_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-url-ipv6-host gate OK (host=$(ci_host_summary))"
