#!/usr/bin/env bash
# PERF-170：SQLite stub/loop 性能烟测门禁
#
# 1) manifest + docs/07 锚点
# 2) typeck tests/bench/sqlite_is_available_loop.su
# 3) 可选 runnable：median ≤ tests/baseline/perf-sqlite.tsv
#
# 用法：./tests/run-perf-sqlite-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_PERF_SQLITE_DOC:-analysis/perf-sqlite-v1.md}"
BASELINE="${SHU_PERF_SQLITE_TSV:-tests/baseline/perf-sqlite.tsv}"
BENCH_SU="tests/bench/sqlite_is_available_loop.su"
STUB_SU="tests/stub/sqlite_net_stub.su"
LIB="tests/lib/perf-sqlite.sh"
RUNS="${SHU_PERF_SQLITE_RUNS:-3}"

# shellcheck source=tests/lib/perf-sqlite.sh
. "$LIB"

echo "=== PERF-170: sqlite perf manifest ==="
for f in "$DOC" "$BASELINE" "$LIB" "$BENCH_SU" "$STUB_SU"; do
  if [ ! -f "$f" ]; then
    echo "perf-sqlite gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in PERF-170 sqlite_is_available_loop perf-sqlite; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-sqlite gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done
if ! grep -qF 'sqlite_is_available' docs/07-内置与标准库.md 2>/dev/null; then
  echo "perf-sqlite gate FAIL: docs/07 missing sqlite_is_available" >&2
  exit 1
fi
echo "perf-sqlite manifest OK"

CHECK_OK=0
RUN_OK=0
SKIP=1

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if perf_sqlite_native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== PERF-170: typeck (SHU=$SHU_BIN) ==="
  if "$SHU_BIN" check -L . "$BENCH_SU" >/dev/null 2>&1 \
    && "$SHU_BIN" check -L . "$STUB_SU" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "perf-sqlite gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$BENCH_SU" 2>&1 | tail -6 >&2 || true
    perf_sqlite_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  OUT="/tmp/shu_perf_sqlite_loop"
  if "$SHU_BIN" -L . "$BENCH_SU" -o "$OUT" >/dev/null 2>&1 && [ -x "$OUT" ]; then
    MED="$(perf_sqlite_median_real "$OUT" "$RUNS")"
    CEIL="$(awk -F'\t' '$1=="sqlite_is_available_loop"{print $2; exit}' "$BASELINE")"
    echo "perf-sqlite median=${MED}s ceiling=${CEIL}s"
    if [ "$MED" != "nan" ] && awk -v m="$MED" -v c="$CEIL" 'BEGIN { exit (m <= c + 0.000001) ? 0 : 1 }'; then
      RUN_OK=1
      echo "perf-sqlite regression OK"
    else
      echo "perf-sqlite gate FAIL: median ${MED}s > ceiling ${CEIL}s" >&2
      perf_sqlite_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "perf-sqlite gate SKIP runnable (check passed)" >&2
  fi
else
  echo "perf-sqlite gate SKIP typeck (no native shu)" >&2
fi

perf_sqlite_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "perf-sqlite gate OK"
