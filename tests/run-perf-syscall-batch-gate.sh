#!/usr/bin/env bash
# PERF-008: syscall batch manifest gate.
#
# Honesty: soft XLANG_SYSCALL_BATCH_FAIL:-0 smoke previously left over-cap /
# batch≥ref unchecked; soft SKIP→OK / runner-non-fatal soft green retired.
# Prefer product xlang_asm. DOC authority = archive/perf. Strace smoke
# over-cap = obs via runner (FAIL=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-syscall-batch-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-syscall-batch.sh
. tests/lib/perf-syscall-batch.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_SYSCALL_BATCH_DOC:-analysis/archive/perf/perf-syscall-batch-v1.md}"
MANIFEST="${XLANG_PERF_SYSCALL_BATCH_TSV:-tests/baseline/perf-syscall-batch.tsv}"
BASELINE="${XLANG_SYSCALL_BATCH_BASELINE:-tests/baseline/syscall-batch-perf.tsv}"
LIB="tests/lib/perf-syscall-batch.sh"
RUNNER="tests/run-perf-syscall-batch.sh"
ZC5="tests/run-zc5-gate.sh"
MIN_CASES=4
PREFIX="xlang: [XLANG_SYSCALL_BATCH]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-syscall-batch gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-syscall-batch-v1.md ]; then
  die "refuse top-level analysis/perf-syscall-batch-v1.md (use archive/perf)"
fi

echo "=== PERF-008: syscall batch manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$RUNNER" "$ZC5"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASES=0
echo "=== PERF-008: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case|cap_row)
      CASES=$((CASES + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing case $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if ! awk -F'\t' -v c="$anchor" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
        echo "perf-syscall-batch FAIL: baseline missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script|hook_script)
      path="$anchor"
      case "$kind" in
        script|hook_script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "perf-syscall-batch FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "perf-syscall-batch FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'perf-syscall-batch.sh' "$ZC5" 2>/dev/null; then
  echo "perf-syscall-batch FAIL: $ZC5 must source perf-syscall-batch.sh" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_sb_report_emit' "$ZC5" 2>/dev/null; then
  echo "perf-syscall-batch FAIL: $ZC5 must call perf_sb_report_emit" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_sb_report_emit' "$RUNNER" 2>/dev/null; then
  echo "perf-syscall-batch FAIL: $RUNNER must call perf_sb_report_emit" >&2
  MISS=$((MISS + 1))
fi

if [ "$CASES" -lt "$MIN_CASES" ]; then
  die "cases=${CASES} < min ${MIN_CASES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi

for kw in syscall batch readv splice strace; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "perf-syscall-batch manifest OK (cases=${CASES})"
RUN_OK=1

# Explicit bad XLANG still hard-dies even when strace smoke is N/A.
if [ -n "${XLANG:-}" ]; then
  resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
fi

chmod +x "$RUNNER"
if perf_sb_strace_probe_ok; then
  echo "=== PERF-008: syscall batch strace smoke ==="
  XLANG_GATE=""
  if ! XLANG_GATE="$(resolve_shu)"; then
    die "no native xlang for strace smoke (refuse soft SKIP→OK)"
  fi
  set +e
  XLANG="$XLANG_GATE" XLANG_LINK_XLANG="$XLANG_GATE" XLANG_SYSCALL_BATCH_FAIL=0 \
    ./"$RUNNER" >/tmp/perf_syscall_batch_smoke.log 2>&1
  smoke_rc=$?
  set -e
  tail -20 /tmp/perf_syscall_batch_smoke.log || true
  if [ "$smoke_rc" -ne 0 ]; then
    die "syscall-batch smoke hard-fail rc=${smoke_rc}"
  fi
  grep -qF "$PREFIX" /tmp/perf_syscall_batch_smoke.log || \
    die "missing $PREFIX in runner output"
  if grep -q 'OBS:' /tmp/perf_syscall_batch_smoke.log; then
    OBS=1
    echo "perf-syscall-batch strace smoke OBS (see runner log)" >&2
  fi
  echo "perf-syscall-batch strace smoke OK"
else
  SKIP=1
  echo "perf-syscall-batch gate SKIP strace smoke (need Linux + strace)" >&2
fi

ok_report
echo "perf-syscall-batch gate OK"
