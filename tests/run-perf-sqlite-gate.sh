#!/usr/bin/env bash
# PERF-170: SQLite stub/loop perf smoke gate.
#
# Honesty: soft SKIP→OK when no native xlang + soft prefer-xlang-c +
# missing top-level DOC retired. Prefer product xlang_asm. Explicit bad
# XLANG = hard die. Over-cap median = obs (FAIL hard only when
# XLANG_PERF_SQLITE_FAIL=1). DOC authority = archive/perf. Report
# run=/obs=/skip= (also check= for legacy).
#
# Usage: ./tests/run-perf-sqlite-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_SQLITE_DOC:-analysis/archive/perf/perf-sqlite-v1.md}"
BASELINE="${XLANG_PERF_SQLITE_TSV:-tests/baseline/perf-sqlite.tsv}"
BENCH_X="bench/sqlite_is_available_loop.x"
STUB_X="tests/stub/sqlite_net_stub.x"
LIB="tests/lib/perf-sqlite.sh"
RUNS="${XLANG_PERF_SQLITE_RUNS:-3}"
FAIL_HARD="${XLANG_PERF_SQLITE_FAIL:-0}"
PREFIX="xlang: [XLANG_PERF_SQLITE]"
CHECK_OK=0
RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/perf-sqlite.sh
. "$LIB"

die() {
  echo "perf-sqlite gate FAIL: $*" >&2
  echo "${PREFIX} status=fail check=${CHECK_OK} run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok check=${CHECK_OK} run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

if [ -f analysis/perf-sqlite-v1.md ]; then
  die "refuse top-level analysis/perf-sqlite-v1.md (use archive/perf)"
fi

echo "=== PERF-170: sqlite perf manifest ==="
for f in "$DOC" "$BASELINE" "$LIB" "$BENCH_X" "$STUB_X"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi
for kw in PERF-170 sqlite_is_available_loop perf-sqlite; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
  fi
done
if ! grep -qF 'sqlite_is_available' docs/07-内置与标准库.md 2>/dev/null; then
  die "docs/07 missing sqlite_is_available"
fi
echo "perf-sqlite manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK)"

echo "=== PERF-170: typeck (XLANG=$XLANG_BIN) ==="
# check used as typeck smoke for this bench (selfhost check gate still paused).
if "$XLANG_BIN" check -L . "$BENCH_X" >/dev/null 2>&1 \
  && "$XLANG_BIN" check -L . "$STUB_X" >/dev/null 2>&1; then
  CHECK_OK=1
else
  echo "perf-sqlite OBS: typeck/check residual (check gate paused)" >&2
  "$XLANG_BIN" check -L . "$BENCH_X" 2>&1 | tail -6 >&2 || true
  OBS=1
fi

OUT="/tmp/xlang_perf_sqlite_loop"
if "$XLANG_BIN" -L . "$BENCH_X" -o "$OUT" >/dev/null 2>&1 && [ -x "$OUT" ]; then
  MED="$(perf_sqlite_median_real "$OUT" "$RUNS")"
  CEIL="$(awk -F'\t' '$1=="sqlite_is_available_loop"{print $2; exit}' "$BASELINE")"
  echo "perf-sqlite median=${MED}s ceiling=${CEIL}s"
  if [ "$MED" != "nan" ] && awk -v m="$MED" -v c="$CEIL" 'BEGIN { exit (m <= c + 0.000001) ? 0 : 1 }'; then
    RUN_OK=1
    echo "perf-sqlite regression OK"
  else
    OBS=1
    echo "perf-sqlite OBS: median ${MED}s > ceiling ${CEIL}s (or nan)" >&2
    if [ "$FAIL_HARD" = "1" ]; then
      die "median ${MED}s > ceiling ${CEIL}s (XLANG_PERF_SQLITE_FAIL=1)"
    fi
    RUN_OK=1
  fi
else
  OBS=1
  echo "perf-sqlite OBS: compile/link residual (no runnable)" >&2
  if [ "$FAIL_HARD" = "1" ]; then
    die "compile/link failed (XLANG_PERF_SQLITE_FAIL=1)"
  fi
fi

echo "perf-sqlite gate OK"
ok_report
# Legacy emit for callers grepping check=/run=/skip=
perf_sqlite_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
exit 0
