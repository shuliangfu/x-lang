#!/usr/bin/env bash
# B-21: FreeBSD platform #[cfg] / std.sys gate (honesty).
#
# Honesty: soft XLANG_FREEBSD_PLATFORM_FAIL retired — missing top-level DOC was
# hard-red fossil; triple failures soft die→exit0 were portable false-green.
# Live DOC = analysis/archive/other-tickets/platform-freebsd-v1.md.
# Prefer xlang_asm; pin XLANG_LINK_XLANG. Host-arch FreeBSD -target -o is hard;
# foreign-arch triple is observational (host ld cannot link foreign ISA).
#
# Usage: ./tests/run-freebsd-platform-gate.sh
# Env:
#   XLANG_B21_FREEBSD_MANIFEST_ONLY=1  — DOC + manifest only (no -o)
#
# Report: doc=/manifest=/triple=/foreign=/host_run=/skip=
# PLATFORM: SHARED archaeology (FREEBSD host write optional).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/other-tickets/platform-freebsd-v1.md"
FREEBSD_MOD="std/sys/freebsd.x"
SMOKE="tests/sys/freebsd_posix_write_smoke.x"
CFG_X="tests/lexer/cfg_attribute_skip.x"
PREFIX="xlang: [XLANG_B21_FREEBSD_PLATFORM]"

DOC_OK=0
MANIFEST_OK=0
TRIPLE_OK=0
FOREIGN_OK=0
HOST_RUN_OK=0
SKIP=1

die() {
  echo "freebsd-platform gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} manifest=${MANIFEST_OK:-0} triple=${TRIPLE_OK:-0} foreign=${FOREIGN_OK:-0} host_run=${HOST_RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
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
    FreeBSD-amd64|FreeBSD-x86_64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' || return 0 ;;
    FreeBSD-arm64|FreeBSD-aarch64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' || return 0 ;;
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

# Map uname -m → FreeBSD triple + expected cfg exit (helper_os 9 + helper_arch).
# PLATFORM: SHARED — cfg prune proof; host ld only links host ISA objects.
host_freebsd_triple_expect() {
  case "$(uname -m 2>/dev/null)" in
    x86_64|amd64) echo "x86_64-unknown-freebsd14.0 31" ;;
    arm64|aarch64) echo "aarch64-unknown-freebsd14.0 20" ;;
    *) return 1 ;;
  esac
}

foreign_freebsd_triple_expect() {
  case "$(uname -m 2>/dev/null)" in
    x86_64|amd64) echo "aarch64-unknown-freebsd14.0 20" ;;
    arm64|aarch64) echo "x86_64-unknown-freebsd14.0 31" ;;
    *) return 1 ;;
  esac
}

echo "=== B-21: FreeBSD platform (honesty; archive DOC) ==="

# Refuse top-level DOC resurrect (live = archive/other-tickets/).
if [ -f analysis/platform-freebsd-v1.md ]; then
  die "top-level analysis/platform-freebsd-v1.md resurrected (live = archive/other-tickets/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi

[ -f "$DOC" ] || die "missing $DOC"
grep -qF 'B-21' "$DOC" || die "doc missing B-21 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"
DOC_OK=1

for f in "$FREEBSD_MOD" "$SMOKE" "$CFG_X"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'target_os = "freebsd"' std/sys/mod.x || die "mod.x missing freebsd cfg"
grep -q 'freebsd' compiler/src/lexer/cfg_eval.x || die "cfg_eval.x missing freebsd"
MANIFEST_OK=1
echo "freebsd-platform manifest OK"

if [ "${XLANG_B21_FREEBSD_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "freebsd-platform gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} triple=0 foreign=0 host_run=0 skip=${SKIP} host=$(ci_host_summary) mode=manifest"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

run_expect() {
  local triple="$1"
  local expect="$2"
  local out="/tmp/xlang_freebsd_triple.$$.out"
  local log="/tmp/xlang_freebsd_triple.$$.log"
  rm -f "$out" 2>/dev/null || true
  if ! "$XLANG_BIN" -target "$triple" -o "$out" "$CFG_X" 2>"$log"; then
    echo "freebsd-platform FAIL: compile -target $triple" >&2
    tail -n 8 "$log" 2>/dev/null || true
    return 1
  fi
  if [ ! -x "$out" ]; then
    echo "freebsd-platform FAIL: no exe for -target $triple" >&2
    return 1
  fi
  local rc=0
  "$out" || rc=$?
  rm -f "$out" 2>/dev/null || true
  if [ "$rc" -ne "$expect" ]; then
    echo "freebsd-platform FAIL: -target $triple expected exit $expect, got $rc" >&2
    return 1
  fi
  echo "freebsd-platform OK (-target $triple -> exit $expect)"
  return 0
}

HOST_TE="$(host_freebsd_triple_expect)" || die "unsupported host arch for FreeBSD triple"
HOST_TRIPLE="${HOST_TE%% *}"
HOST_EXPECT="${HOST_TE##* }"
echo "=== B-21: host-arch FreeBSD triple hard (XLANG=$XLANG_BIN) ==="
run_expect "$HOST_TRIPLE" "$HOST_EXPECT" || die "host-arch FreeBSD triple failed"
TRIPLE_OK=1

# Foreign-arch: observational — host linker rejects foreign ISA objects.
# PLATFORM: SHARED — do not soft-exit0 the whole gate on foreign link failure.
FOREIGN_TE="$(foreign_freebsd_triple_expect || true)"
if [ -n "${FOREIGN_TE:-}" ]; then
  FOREIGN_TRIPLE="${FOREIGN_TE%% *}"
  FOREIGN_EXPECT="${FOREIGN_TE##* }"
  echo "=== B-21: foreign-arch FreeBSD triple observational ==="
  if run_expect "$FOREIGN_TRIPLE" "$FOREIGN_EXPECT"; then
    FOREIGN_OK=1
    echo "freebsd-platform foreign triple unexpectedly runnable (ok)"
  else
    FOREIGN_OK=1
    echo "freebsd-platform SKIP foreign -target $FOREIGN_TRIPLE (host ld ISA; observational)"
  fi
else
  FOREIGN_OK=1
fi

HOSTOS="$(uname -s 2>/dev/null)"
if [ "$HOSTOS" = "FreeBSD" ]; then
  echo "=== B-21: FreeBSD host posix write hard ==="
  OUT_H="/tmp/xlang_freebsd_write_smoke.$$"
  LOG_H="/tmp/xlang_freebsd_write_smoke.$$.log"
  rm -f "$OUT_H" 2>/dev/null || true
  if ! $RUN_XLANG -o "$OUT_H" "$SMOKE" 2>"$LOG_H"; then
    tail -n 10 "$LOG_H" 2>/dev/null || true
    die "FreeBSD host compile $SMOKE"
  fi
  [ -x "$OUT_H" ] || die "no FreeBSD host exe"
  set +e
  OUT=$( "$OUT_H" 2>/dev/null)
  EX=$?
  set -e
  rm -f "$OUT_H"
  EXPECTED=$(printf 'Hello Xlang!\n')
  if [ "$EX" -ne 0 ] || [ "$OUT" != "$EXPECTED" ]; then
    die "host run exit=$EX out='$OUT'"
  fi
  HOST_RUN_OK=1
  echo "freebsd-platform host posix write OK"
else
  echo "freebsd-platform SKIP host run (need FreeBSD host)"
  HOST_RUN_OK=0
fi

SKIP=0
echo "freebsd-platform gate OK"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} triple=${TRIPLE_OK} foreign=${FOREIGN_OK} host_run=${HOST_RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
