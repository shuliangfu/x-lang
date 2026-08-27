#!/usr/bin/env bash
# B-19: std.sys unified os_write / write_stdout platform smoke (honesty).
#
# Honesty: soft XLANG_SYS_PLATFORM_WRITE_FAIL retired — missing compiler /
# compile/run failure was portable false-green (soft die→exit0). Prefer
# xlang_asm; pin XLANG_LINK_XLANG. Live DOC = archive phase; refuse top-level
# DOC / compiler/Makefile resurrect. Hard-delegate B-19 facade.
#
# Usage: ./tests/run-sys-platform-write-gate.sh
# Env:
#   XLANG_B19_SYS_PLATFORM_WRITE_MANIFEST_ONLY=1  — DOC + facade only (no -o)
#
# Report: doc=/facade=/run=/skip=
# PLATFORM: SHARED archaeology (LINUX freestanding / DARWIN hosted).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-b19-sys-platform-write.md"
X="tests/sys/sys_platform_write_unified.x"
FACADE_GATE="tests/run-b19-sys-mod-facade-gate.sh"
PREFIX="xlang: [XLANG_B19_SYS_PLATFORM_WRITE]"

DOC_OK=0
FACADE_OK=0
RUN_OK=0
SKIP=1

die() {
  echo "sys-platform-write-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} facade=${FACADE_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

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
resolve_shu() {
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

echo "=== B-19: std.sys platform write unified (honesty) ==="

# Refuse top-level DOC resurrect (live = archive/phase/).
if [ -f analysis/phase-b19-sys-platform-write.md ]; then
  die "top-level analysis/phase-b19-sys-platform-write.md resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi

[ -f "$DOC" ] || die "missing $DOC"
[ -f "$X" ] || die "missing $X"
grep -qF 'B-19' "$DOC" || die "doc missing B-19 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"
DOC_OK=1

chmod +x "$FACADE_GATE"
"$FACADE_GATE" || die "B-19 facade gate failed"
FACADE_OK=1

if [ "${XLANG_B19_SYS_PLATFORM_WRITE_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "sys-platform-write-gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} facade=${FACADE_OK} run=0 skip=${SKIP} host=$(ci_host_summary) mode=manifest"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

OS="$(uname -s)"
OUT="/tmp/xlang_sys_platform_write.$$.out"
LOG="/tmp/xlang_sys_platform_write.$$.log"
rm -f "$OUT" 2>/dev/null || true

EXTRA=()
# PLATFORM: LINUX — freestanding write path (align BOOT-029 / sys_write_freestanding).
# PLATFORM: MACOS|DARWIN — hosted -o (no freestanding).
if [ "$OS" = "Linux" ]; then
  EXTRA=(-freestanding -backend asm)
fi

echo "=== B-19: write smoke (XLANG=$XLANG_BIN; ${EXTRA[*]:-hosted}) ==="
if [ "${#EXTRA[@]}" -gt 0 ]; then
  if ! "$XLANG_BIN" "${EXTRA[@]}" -o "$OUT" "$X" 2>"$LOG"; then
    tail -n 12 "$LOG" 2>/dev/null || true
    rm -f "$OUT" 2>/dev/null || true
    die "compile $X on $OS"
  fi
else
  if ! $RUN_XLANG -o "$OUT" "$X" 2>"$LOG"; then
    tail -n 12 "$LOG" 2>/dev/null || true
    rm -f "$OUT" 2>/dev/null || true
    die "compile $X on $OS"
  fi
fi

[ -x "$OUT" ] || die "no executable $OUT"

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true
[ "$rc" -eq 0 ] || die "expected exit 0, got $rc on $OS"

RUN_OK=1
SKIP=0
echo "sys-platform-write-gate OK (std.sys write_stdout unified on $OS)"
echo "${PREFIX} status=ok doc=${DOC_OK} facade=${FACADE_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
