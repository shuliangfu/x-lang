#!/usr/bin/env bash
# SAFE-007：崩溃最小证据包 manifest 门禁
#
# 用法：./tests/run-safe-crash-evidence-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_SAFE_CRASH_DOC:-analysis/safe-crash-evidence-v1.md}"
MANIFEST="${SHUX_SAFE_CRASH_MANIFEST:-tests/baseline/safe-crash-evidence.tsv}"
MIN_CASES=2

# shellcheck source=tests/lib/safe-crash.sh
. tests/lib/safe-crash.sh

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

echo "=== SAFE-007: crash evidence manifest ==="
for f in "$DOC" "$MANIFEST" std/backtrace/mod.x compiler/seeds/runtime_backtrace_platform.from_x.c \
  compiler/seeds/runtime_panic.from_x.c tests/crash/evidence_manual.x tests/ub/div_zero.x; do
  if [ ! -f "$f" ]; then
    echo "safe-crash-evidence gate FAIL: missing $f" >&2
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
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      if ! grep -qE "function ${anchor}\\(" std/backtrace/mod.x 2>/dev/null; then
        echo "safe-crash FAIL: missing API $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "safe-crash FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ "$item_id" = "impl_c" ]; then
        if ! grep -qF 'shux_crash_evidence_collect_c' compiler/seeds/runtime_backtrace_platform.from_x.c 2>/dev/null; then
          echo "safe-crash FAIL: missing collect impl" >&2
          MISS=$((MISS + 1))
        fi
      fi
      if [ "$item_id" = "impl_panic" ]; then
        if ! grep -qF 'shux_crash_evidence_collect_c' compiler/seeds/runtime_panic.from_x.c 2>/dev/null; then
          echo "safe-crash FAIL: panic hook missing" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    script)
      if [ ! -f "$src" ]; then
        echo "safe-crash FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "safe-crash FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$src" ]; then
        echo "safe-crash FAIL: missing xref $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing xref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-crash FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-crash FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "safe-crash-evidence gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in crash evidence SHUX_CRASH_EVIDENCE bundle runnable replay; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "safe-crash-evidence gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "safe-crash-evidence gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "safe-crash-evidence manifest OK (cases=${CASE_N})"

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
  chmod +x tests/run-safe-crash-evidence.sh
  if SHUX="$SHUX_BIN" SHUX_CRASH_EVIDENCE=1 ./tests/run-safe-crash-evidence.sh | tee /tmp/safe_crash_smoke.log; then
    grep -q 'safe-crash-evidence OK' /tmp/safe_crash_smoke.log
  else
    echo "safe-crash-evidence gate FAIL: runner" >&2
    exit 1
  fi
else
  echo "safe-crash-evidence gate SKIP runner (no native shux)" >&2
fi

echo "safe-crash-evidence gate OK"
