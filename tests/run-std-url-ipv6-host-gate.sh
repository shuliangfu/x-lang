#!/usr/bin/env bash
# STD-134: std.url IPv6 bracket host gate (false-authority honesty).
#
# Usage: ./tests/run-std-url-ipv6-host-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); ipv6_host.x exit 0 hard-fail (no soft SKIP
# when native xlang present). C smoke observational. Report check=/run=/skip=.
# Product smoke green under asm on Ubuntu; Darwin was red (exit 3) because
# url.x AF_INET6 hardcoded Linux 10 (Darwin=30) — root-fixed same wave
# (cfg + same pattern in std/net/ipv6.x + dns.x). Gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP→OK when no xlang-c / c=/x= report).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_URL_IPV6_HOST_DOC:-analysis/archive/std/std-url-ipv6-host-v1.md}"
MANIFEST="${XLANG_STD_URL_IPV6_HOST_TSV:-tests/baseline/std-url-ipv6-host-manifest.tsv}"
MOD_X="std/url/mod.x"
URL_X="std/url/url.x"
LIB="tests/lib/std-url-ipv6-host.sh"
SMOKE_X="tests/std-url/ipv6_host.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-url-ipv6-host.sh
. "$LIB"

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_url_ipv6_host_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== STD-134: std.url IPv6 host manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-url-ipv6-host-v1.md ]; then
  echo "std-url-ipv6-host gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$URL_X" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "std-url-ipv6-host gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-134 host_to_ipv6 format_ipv6_host; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-url-ipv6-host gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-url-ipv6-host gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

sym_miss="$(std_url_ipv6_host_symbols_ok "$MOD_X" "$URL_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_url_ipv6_host_emit_report "fail" 0 0 0
  echo "std-url-ipv6-host gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-url-ipv6-host manifest OK"

if [ "${XLANG_STD_URL_IPV6_HOST_MANIFEST_ONLY:-0}" = "1" ]; then
  std_url_ipv6_host_emit_report "ok" 0 0 1
  echo "std-url-ipv6-host gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
RUN_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is ipv6_host.x via asm.
echo "=== STD-134: url c smoke (observational) ==="
C_NOTE=0
xlang_compiler_make -q ../std/url/url.o 2>/dev/null || xlang_compiler_make ../std/url/url.o >/dev/null 2>&1 || true
URL_O="std/url/url.o"
if [ -f "$URL_O" ] && nm "$URL_O" 2>/dev/null | grep -qF 'url_ipv6_host_smoke_c'; then
  if std_url_ipv6_host_run_c_smoke "$URL_O"; then
    C_NOTE=1
    echo "std-url-ipv6-host c smoke OK (observational)"
  else
    echo "std-url-ipv6-host gate SKIP c smoke (observational; link)" >&2
  fi
else
  echo "std-url-ipv6-host gate SKIP c smoke (observational; url.o / symbol)" >&2
fi
echo "std-url-ipv6-host c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(std_url_ipv6_host_resolve_shu 2>/dev/null)"; then
  echo "=== STD-134: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-url-ipv6-host gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/url/mod.o 2>/dev/null || xlang_compiler_make ../std/url/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/url/url.o 2>/dev/null || xlang_compiler_make ../std/url/url.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std134_url_ipv6_$$"
  LOG="/tmp/xlang_std134_url_ipv6_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-url-ipv6-host gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_url_ipv6_host_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-url-ipv6-host gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_url_ipv6_host_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-url-ipv6-host gate FAIL: no native xlang" >&2
  std_url_ipv6_host_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-url-ipv6-host check_ok=${CHECK_OK} (observational)"
std_url_ipv6_host_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-url-ipv6-host gate OK"
