#!/usr/bin/env bash
# G-FFI-5: business tests no bare extern + §8 std business unsafe freeze.
#
# Honesty: soft XLANG_G_FFI5_FAIL retired — missing allowlist/baseline was
# portable false-green (soft die→exit0). Live authority: archive DOC + TSV
# baselines + hard-delegate wrap gate. Refuse compiler/Makefile resurrect.
# LANG-007 / xlang check residual stays deferred (tip skip; check gate paused).
#
# Usage: ./tests/run-g-ffi-5-business-no-bare-extern-gate.sh
# Env:
#   XLANG_G_FFI5_MANIFEST_ONLY=1       — DOC + TSV + static scans only (no wrap)
#   XLANG_G_FFI5_STRICT_ZERO_UNSAFE=1  — require zero std business unsafe (end-state)
#
# Report: doc=/allow=/baseline=/bare=/freeze=/wrap=/skip=
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-g-ffi-5.md"
ALLOW="tests/baseline/g-ffi-5-business-extern-allowlist.tsv"
STD_BASE="tests/baseline/g-ffi-5-std-business-unsafe-baseline.tsv"
PREFIX="xlang: [XLANG_G_FFI5]"

DOC_OK=0
ALLOW_OK=0
BASELINE_OK=0
BARE_OK=0
FREEZE_OK=0
WRAP_OK=0
SKIP=1

die() {
  echo "g-ffi-5 business FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} allow=${ALLOW_OK:-0} baseline=${BASELINE_OK:-0} bare=${BARE_OK:-0} freeze=${FREEZE_OK:-0} wrap=${WRAP_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

echo "=== G-FFI-5: business no bare extern + §8 freeze (honesty) ==="
# Refuse top-level DOC resurrect (live = archive/phase/).
if [ -f analysis/phase-g-ffi-5.md ]; then
  die "top-level analysis/phase-g-ffi-5.md resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi

for f in "$DOC" "$ALLOW" "$STD_BASE"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'G-FFI-5' "$DOC" || die "doc missing G-FFI-5 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"
DOC_OK=1

[ -f tests/run-g-ffi-5-std-wrap-gate.sh ] || die "missing std wrap gate"
ALLOW_OK=1
BASELINE_OK=1

is_allowlisted() {
  local f="$1"
  # shellcheck disable=SC2162
  while IFS=$'\t' read tid path rest; do
    [ -z "${tid:-}" ] && continue
    case "$tid" in \#*) continue ;; esac
    [ "$path" = "$f" ] && return 0
  done < "$ALLOW"
  return 1
}

# ── business tests: extern 文件必须含 unsafe 或在 allowlist ──
echo "=== G-FFI-5: business tests no bare extern calls ==="
MISS=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in
    tests/unsafe/*|tests/probes/*|tests/kernel/*|tests/ffi/*) continue ;;
  esac
  if ! grep -qE '^[[:space:]]*extern ' "$f"; then
    continue
  fi
  if is_allowlisted "$f"; then
    continue
  fi
  if ! grep -q 'unsafe' "$f"; then
    echo "  bare-extern (no unsafe): $f" >&2
    MISS=$((MISS + 1))
  fi
done <<EOF
$(find tests -name '*.x' 2>/dev/null | sort)
EOF

[ "$MISS" -eq 0 ] || die "$MISS business test(s) have extern without unsafe (add unsafe or allowlist)"
BARE_OK=1
echo "g-ffi-5 business tests: no bare extern OK"

# ── 安全路线 §8：std **业务层** unsafe 债务冻结 / 终局清零 ──
# 基础设施边界（syscall/FFI/OS/IO 底座）允许 unsafe，不计入业务债：
#   sys, ffi, heap, crypto, dynlib, process, thread, sync, atomic, channel,
#   net, http, fs, path, runtime, log, time, random, env, backtrace, compress, db, sqlite
echo "=== G-FFI-5: std business unsafe policy (excl infra boundary) ==="
is_infra_boundary() {
  case "$1" in
    std/sys/*|std/ffi/*|std/heap/*|std/crypto/*|std/dynlib/*|std/process/*| \
    std/thread/*|std/sync/*|std/atomic/*|std/channel/*|std/net/*|std/http/*| \
    std/fs/*|std/path/*|std/runtime/*|std/log/*|std/time/*|std/random/*| \
    std/env/*|std/backtrace/*|std/compress/*|std/db/*|std/sqlite/*) return 0 ;;
    *) return 1 ;;
  esac
}

BASE_TMP=$(mktemp)
CUR_TMP=$(mktemp)
trap 'rm -f "$BASE_TMP" "$CUR_TMP"' EXIT

# shellcheck disable=SC2162
while IFS=$'\t' read tid path rest; do
  [ -z "${tid:-}" ] && continue
  case "$tid" in \#*) continue ;; esac
  [ -n "$path" ] || continue
  if is_infra_boundary "$path"; then
    continue
  fi
  printf '%s\n' "$path"
done < "$STD_BASE" | sort -u > "$BASE_TMP"
BASE_N=$(wc -l < "$BASE_TMP" | tr -d ' ')

: > "$CUR_TMP"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if is_infra_boundary "$f"; then
    continue
  fi
  if grep -q 'unsafe' "$f"; then
    printf '%s\n' "$f" >> "$CUR_TMP"
  fi
done <<EOF
$(find std -name '*.x' 2>/dev/null | sort)
EOF
CUR_N=$(wc -l < "$CUR_TMP" | tr -d ' ')
echo "g-ffi-5 §8: current unsafe files=$CUR_N baseline=$BASE_N"

if [ "${XLANG_G_FFI5_STRICT_ZERO_UNSAFE:-0}" = "1" ]; then
  if [ "$CUR_N" -ne 0 ]; then
    while IFS= read -r f; do
      echo "  std unsafe (strict zero): $f" >&2
    done < "$CUR_TMP"
    die "$CUR_N std business .x still use unsafe (STRICT_ZERO_UNSAFE=1)"
  fi
  echo "g-ffi-5 §8 STRICT zero unsafe OK"
else
  NEW=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if ! grep -qxF "$f" "$BASE_TMP"; then
      echo "  NEW std unsafe (not in baseline): $f" >&2
      NEW=$((NEW + 1))
    fi
  done < "$CUR_TMP"
  [ "$NEW" -eq 0 ] || die "$NEW new std business .x gained unsafe (shrink baseline only when clearing debt)"
  CLEARED=0
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if [ -f "$p" ] && ! grep -q 'unsafe' "$p"; then
      echo "  progress: baseline path cleared unsafe: $p"
      CLEARED=$((CLEARED + 1))
    fi
  done < "$BASE_TMP"
  echo "g-ffi-5 §8 freeze OK (debt frozen; cleared_scan=$CLEARED; STRICT_ZERO_UNSAFE=1 for end-state)"
fi
FREEZE_OK=1

if [ "${XLANG_G_FFI5_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "g-ffi-5 business-no-bare-extern gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} allow=${ALLOW_OK} baseline=${BASELINE_OK} bare=${BARE_OK} freeze=${FREEZE_OK} wrap=0 skip=${SKIP} host=$(ci_host_summary) mode=manifest"
  exit 0
fi

# ── 挂接既有 std wrap（hard）──
chmod +x tests/run-g-ffi-5-std-wrap-gate.sh
./tests/run-g-ffi-5-std-wrap-gate.sh || die "std wrap gate failed"
WRAP_OK=1
SKIP=0

echo "g-ffi-5 business-no-bare-extern gate OK"
echo "${PREFIX} status=ok doc=${DOC_OK} allow=${ALLOW_OK} baseline=${BASELINE_OK} bare=${BARE_OK} freeze=${FREEZE_OK} wrap=${WRAP_OK} skip=${SKIP} host=$(ci_host_summary)"
