#!/usr/bin/env bash
# SAFE-005：泄漏夜跑 manifest 门禁
#
# 用法：./tests/run-safe-leak-nightly-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_LEAK_DOC:-analysis/safe-leak-nightly-v1.md}"
MANIFEST="${SHUX_LEAK_MANIFEST:-tests/baseline/safe-leak-nightly.tsv}"
MIN_CASES=3

# shellcheck source=tests/lib/safe-leak.sh
. tests/lib/safe-leak.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== SAFE-005: leak nightly manifest ==="
for f in "$DOC" "$MANIFEST" tests/lib/safe-leak.sh tests/run-safe-leak-nightly.sh; do
  if [ ! -f "$f" ]; then
    echo "safe-leak-nightly gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$item_id" in
    read_path|asan|cases|report|schedule)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    lib|gate|runner)
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    workflow)
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing workflow $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing workflow $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_*)
      if [ ! -f "$anchor" ]; then
        echo "safe-leak FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    probe)
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing probe $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-leak FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-leak FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "safe-leak-nightly gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in leak nightly ASAN report runnable SHUX_LEAK_NIGHTLY; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "safe-leak-nightly gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if ! grep -qF 'run-safe-leak-nightly.sh' .github/workflows/ci-nightly.yml 2>/dev/null; then
  echo "safe-leak-nightly gate FAIL: ci-nightly.yml missing leak runner" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  echo "safe-leak-nightly gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "safe-leak-nightly manifest OK (cases=${CASE_N})"

if [ "$(uname -s)" = "Linux" ] && safe_leak_asan_ok; then
  SHUX_BIN="${SHUX:-}"
  if [ -z "$SHUX_BIN" ]; then
    for cand in ./compiler/shux-c ./compiler/shux; do
      if native_shu "$cand"; then
        SHUX_BIN="$cand"
        break
      fi
    done
  fi
  if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
    echo "=== SAFE-005: leak nightly smoke (1 case) ==="
    make -C compiler -q 2>/dev/null || make -C compiler
    # F-03 v2：heap 已纯 .sx，不再 ensure heap.o
    if safe_leak_run_sx "$SHUX_BIN" tests/leak/no_leak_heap.sx case_heap; then
      echo "safe-leak-nightly smoke OK"
    else
      echo "safe-leak-nightly gate FAIL: smoke" >&2
      exit 1
    fi
  else
    echo "safe-leak-nightly gate SKIP smoke (no native shux)" >&2
  fi
else
  echo "safe-leak-nightly gate SKIP smoke (non-Linux or no ASAN)" >&2
fi

echo "safe-leak-nightly gate OK"
