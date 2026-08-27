#!/usr/bin/env bash
# B-02: #[cfg] follows `-target` triple (cross OS/arch prune smoke).
#
# Honesty: soft XLANG_CFG_TARGET_TRIPLE_FAIL retired — foreign-arch ld failure
# was portable false-green (soft die→exit0). Prefer xlang_asm; pin
# XLANG_LINK_XLANG.
#
# Same-arch cross-OS `-o`+run is HARD (cfg OS prune proven on host ld).
# Cross-arch triples are OBSERVATIONAL: host ld cannot link foreign ELF/Mach-O
# (not soft false-green; report obs=).
#
# Usage: ./tests/run-cfg-target-triple-gate.sh
# Report: os=/obs=/skip=
# PLATFORM: SHARED archaeology (LINUX/DARWIN host; cross-arch = obs).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/lexer/cfg_attribute_skip.x"
PREFIX="xlang: [XLANG_B02_CFG_TARGET_TRIPLE]"
OS_OK=0
OBS=0
SKIP=1

die() {
  echo "cfg-target-triple-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail os=${OS_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
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

# Compile+run one triple; return 0 on expect match.
run_expect() {
  local triple="$1"
  local expect="$2"
  local out="/tmp/xlang_cfg_triple.$$.${triple}.out"
  rm -f "$out" 2>/dev/null || true
  if ! "$XLANG" -target "$triple" -o "$out" "$X" 2>/tmp/xlang_cfg_triple.log; then
    echo "cfg-target-triple-gate: compile failed -target $triple" >&2
    tail -n 6 /tmp/xlang_cfg_triple.log 2>/dev/null || true
    rm -f "$out" 2>/dev/null || true
    return 1
  fi
  if [ ! -x "$out" ]; then
    echo "cfg-target-triple-gate: no executable for -target $triple" >&2
    rm -f "$out" 2>/dev/null || true
    return 1
  fi
  local rc=0
  "$out" || rc=$?
  rm -f "$out" 2>/dev/null || true
  if [ "$rc" -ne "$expect" ]; then
    echo "cfg-target-triple-gate: -target $triple expected exit $expect, got $rc" >&2
    return 1
  fi
  echo "cfg-target-triple-gate OK (-target $triple -> exit $expect)"
  return 0
}

echo "=== B-02: #[cfg] follows -target triple (honesty) ==="

[ -f "$X" ] || die "missing $X"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi

OS="$(uname -s)"
ARCH="$(uname -m 2>/dev/null || echo unknown)"
case "$OS" in
  Darwin|Linux|FreeBSD) ;;
  *)
    SKIP=1
    echo "cfg-target-triple-gate OK (unsupported host $OS)"
    echo "${PREFIX} status=ok os=0 obs=0 skip=${SKIP} host=$(ci_host_summary)"
    exit 0
    ;;
esac

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Hard = same host-arch cross-OS (cfg OS prune; host ld can link).
# Obs = foreign arch (host ld cannot link foreign object) — not soft green.
HARD_TRIPLES=()
OBS_TRIPLES=()
case "$ARCH" in
  arm64|aarch64)
    HARD_TRIPLES=(
      "aarch64-apple-darwin:16"
      "aarch64-unknown-linux-gnu:18"
      "aarch64-unknown-freebsd14.0:20"
    )
    OBS_TRIPLES=(
      "x86_64-unknown-linux-gnu:29"
      "x86_64-apple-darwin:27"
      "x86_64-unknown-freebsd14.0:31"
    )
    ;;
  x86_64|amd64)
    HARD_TRIPLES=(
      "x86_64-unknown-linux-gnu:29"
      "x86_64-apple-darwin:27"
      "x86_64-unknown-freebsd14.0:31"
    )
    OBS_TRIPLES=(
      "aarch64-unknown-linux-gnu:18"
      "aarch64-apple-darwin:16"
      "aarch64-unknown-freebsd14.0:20"
    )
    ;;
  *)
    die "unsupported host arch $ARCH"
    ;;
esac

for te in "${HARD_TRIPLES[@]}"; do
  t="${te%%:*}"
  e="${te##*:}"
  run_expect "$t" "$e" || die "hard same-arch -target $t (expect $e)"
  OS_OK=$((OS_OK + 1))
done

for te in "${OBS_TRIPLES[@]}"; do
  t="${te%%:*}"
  e="${te##*:}"
  if run_expect "$t" "$e"; then
    # Unexpected: foreign arch linked+ran — still count as os ok, no obs.
    OS_OK=$((OS_OK + 1))
  else
    echo "cfg-target-triple-gate OBS: cross-arch -target $t (host ld; expect was $e)"
    OBS=$((OBS + 1))
  fi
done

[ "$OS_OK" -ge 3 ] || die "same-arch cross-OS count $OS_OK < 3"
[ "$OBS" -ge 1 ] || true  # obs may be 0 if foreign arch somehow works

SKIP=0
echo "cfg-target-triple-gate OK (#[cfg] follows -target on $OS/$ARCH; os=${OS_OK} obs=${OBS})"
echo "${PREFIX} status=ok os=${OS_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
