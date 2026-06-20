#!/usr/bin/env bash
# SAFE-006：数据竞争检测实验线 manifest 门禁
#
# 用法：./tests/run-safe-race-detect-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_RACE_DOC:-analysis/safe-race-detect-v1.md}"
MANIFEST="${SHUX_RACE_MANIFEST:-tests/baseline/safe-race-detect.tsv}"
MIN_CASES=2

# shellcheck source=tests/lib/safe-race.sh
. tests/lib/safe-race.sh

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

echo "=== SAFE-006: race detect manifest ==="
for f in "$DOC" "$MANIFEST" tests/lib/safe-race.sh tests/run-safe-race-detect.sh; do
  if [ ! -f "$f" ]; then
    echo "safe-race-detect gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable report SHUX_RACE_DETECT T1-tsan-probe; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "safe-race-detect gate FAIL: doc missing '$kw'" >&2
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
TRACK_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$item_id" in
    read_path|tsan|cases|report|schedule)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    track_*)
      TRACK_N=$((TRACK_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing track $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    probe)
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing probe $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    lib|runner|gate)
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing ref $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    workflow)
      if [ ! -f "$src" ]; then
        echo "safe-race FAIL: missing workflow $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "safe-race FAIL: doc missing workflow $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_*)
      if [ ! -f "$anchor" ]; then
        echo "safe-race FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "safe-race-detect gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$TRACK_N" -lt 4 ]; then
  echo "safe-race-detect gate FAIL: tracks=${TRACK_N} < 4" >&2
  exit 1
fi
if ! grep -qF 'safe_race_emit_report' tests/run-safe-race-detect.sh 2>/dev/null; then
  echo "safe-race-detect gate FAIL: runner must emit report" >&2
  MISS=$((MISS + 1))
fi
if [ "$MISS" -gt 0 ]; then
  echo "safe-race-detect gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "safe-race-detect manifest OK (cases=${CASE_N} tracks=${TRACK_N})"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then SHUX_BIN="$cand"; break; fi
  done
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== SAFE-006: runnable report ==="
  chmod +x tests/run-safe-race-detect.sh
  set +e
  SHUX="$SHUX_BIN" tests/run-safe-race-detect.sh >/tmp/safe_race_smoke.log 2>&1
  _race_rc=$?
  set -e
  if [ "$_race_rc" -ne 0 ]; then
    cat /tmp/safe_race_smoke.log >&2
    echo "safe-race-detect gate FAIL: runner" >&2
    exit 1
  fi
  if ! grep -q 'SHUX_RACE_DETECT' /tmp/safe_race_smoke.log; then
    cat /tmp/safe_race_smoke.log >&2
    echo "safe-race-detect gate FAIL: missing report prefix" >&2
    exit 1
  fi
else
  echo "safe-race-detect gate SKIP bench (no native shux)" >&2
fi

echo "safe-race-detect gate OK"
