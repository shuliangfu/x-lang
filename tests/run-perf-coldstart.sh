#!/usr/bin/env bash
# B-BOOT：hello stripped 冷启动中位数（NEXT §1.2）
# P6：S4 freestanding return42/hello（-freestanding -backend asm）冷启动 + stripped 体积（Linux x86_64）
#
# 用法：./tests/run-perf-coldstart.sh [--bench]
# 环境：
#   SHU_COLDSTART_FREESTANDING_ONLY=1 — 仅跑 freestanding（CI 在 shu_asm 就绪后）
#   SHU_COLDSTART_STD_ONLY=1 — 仅跑 std hello（早期 CI）
# 门禁（可选）：
#   SHU_PERF_FAIL_ON_COLDSTART_REGRESSION=1 — 实测 ≤ tests/baseline/coldstart-perf.tsv
#   SHU_PERF_UPDATE_COLDSTART_BASELINE=1 — 刷新基线
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

HELLO_SRC="examples/hello.su"
OUT="/tmp/shu_coldstart_hello"
FS_HELLO_SRC="tests/freestanding/hello/main.su"
FS_HELLO_OUT="/tmp/shu_coldstart_fs_hello"
FS_RV42_SRC="tests/freestanding/return42/main.su"
FS_RV42_OUT="/tmp/shu_coldstart_fs_return42"
BASELINE="tests/baseline/coldstart-perf.tsv"
RUNS="${SHU_COLDSTART_RUNS:-20}"
DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHU_PERF_FAIL_ON_COLDSTART_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0
FS_ONLY="${SHU_COLDSTART_FREESTANDING_ONLY:-0}"
STD_ONLY="${SHU_COLDSTART_STD_ONLY:-0}"

SHU_BIN="${SHU:-./compiler/shu}"

# 用 perf_counter 测进程启动+执行；单位微秒；第三参为期望 exit code（默认 0）
measure_median_us() {
  local exe="$1"
  local expect_rc="${2:-0}"
  python3 - "$exe" "$RUNS" "$expect_rc" <<'PY'
import statistics, subprocess, sys, time
exe, runs_s, expect_s = sys.argv[1], sys.argv[2], sys.argv[3]
runs = int(runs_s)
expect = int(expect_s)
times = []
for _ in range(runs):
    t0 = time.perf_counter()
    r = subprocess.run([exe], capture_output=True)
    dt = (time.perf_counter() - t0) * 1e6
    if r.returncode != expect:
        sys.stderr.write(r.stderr.decode("utf-8", "replace"))
        sys.exit(1)
    times.append(dt)
med = statistics.median(times)
print(f"{med:.1f}")
PY
}

# 从 baseline tsv 读取某 metric 的上限（第二列）
baseline_cap() {
  local key="$1"
  [ -f "$BASELINE" ] || return 0
  awk -F'\t' -v k="$key" '$1==k{print $2; exit}' "$BASELINE"
}

# 门禁：实测 value 须 ≤ cap（用于 us 与 bytes）
check_le_cap() {
  local label="$1" value="$2" cap="$3"
  [ -n "$cap" ] || return 0
  local ok
  ok=$(python3 - "$value" "$cap" <<'PY'
import sys
val, cap = float(sys.argv[1]), float(sys.argv[2])
print("1" if val <= cap else "0")
PY
)
  if [ "$ok" != "1" ]; then
    echo "coldstart FAIL: ${label}=${value} > cap ${cap} ($BASELINE)" >&2
    exit 1
  fi
}

# 探测编译器是否支持 -freestanding -backend asm
freestanding_shu_can_build() {
  local shu="$1"
  local probe_out="/tmp/shu_coldstart_fs_probe_$$"
  [ -n "$shu" ] && [ -x "$shu" ] || return 1
  if "$shu" -freestanding -backend asm "$FS_RV42_SRC" -o "$probe_out" 2>/dev/null; then
    rm -f "$probe_out"
    return 0
  fi
  return 1
}

# 选择 freestanding 编译器：优先 shu_asm，再 SHU_BIN
pick_freestanding_shu() {
  if [ -n "${SHU:-}" ] && freestanding_shu_can_build "$SHU"; then
    echo "$SHU"
    return 0
  fi
  if freestanding_shu_can_build "./compiler/shu_asm"; then
    echo "./compiler/shu_asm"
    return 0
  fi
  if freestanding_shu_can_build "$SHU_BIN"; then
    echo "$SHU_BIN"
    return 0
  fi
  return 1
}

# 单条 freestanding 冷启动：label src out expect_rc us_metric bytes_metric
# 成功写全局 FS_LAST_MED_US / FS_LAST_SIZE；失败时 FS_CASE_SKIP=1
coldstart_freestanding_one() {
  local label="$1" src="$2" out="$3" expect_rc="$4" us_key="$5" bytes_key="$6"
  local fs_shu med size
  FS_CASE_SKIP=0
  FS_LAST_MED_US=""
  FS_LAST_SIZE=""
  if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
    echo "coldstart ${label}: skip (host is not Linux)"
    FS_CASE_SKIP=1
    return 0
  fi
  if [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
    echo "coldstart ${label}: skip (freestanding 仅 x86_64 Linux; host=$(uname -m))"
    FS_CASE_SKIP=1
    return 0
  fi
  fs_shu=$(pick_freestanding_shu) || {
    echo "coldstart ${label}: skip (no shu with -freestanding -backend asm; try shu_asm)"
    FS_CASE_SKIP=1
    return 0
  }
  if ! "$fs_shu" -freestanding -backend asm "$src" -o "$out" 2>/dev/null; then
    echo "coldstart ${label}: skip (build failed with $fs_shu)"
    FS_CASE_SKIP=1
    return 0
  fi
  strip "$out" 2>/dev/null || true
  if [ ! -x "$out" ]; then
    echo "coldstart ${label}: skip (not executable after build)"
    FS_CASE_SKIP=1
    return 0
  fi
  med=$(measure_median_us "$out" "$expect_rc")
  size=$(wc -c <"$out" | tr -d ' ')
  FS_LAST_MED_US="$med"
  FS_LAST_SIZE="$size"
  echo "coldstart ${label}: median ${med}us stripped_size=${size}B runs=${RUNS} (via ${fs_shu})"
  if [ "$DO_BENCH" = "1" ]; then
    echo "${us_key}	${med}"
    echo "${bytes_key}	${size}"
  fi
  if [ "$PERF_FAIL" = "1" ]; then
    check_le_cap "$us_key" "$med" "$(baseline_cap "$us_key")"
    check_le_cap "$bytes_key" "$size" "$(baseline_cap "$bytes_key")"
  fi
}

MED_US=""
FS_RV42_MED_US=""
FS_RV42_SIZE=""
FS_MED_US=""
FS_SIZE=""

# ── std hello（含 std.io，动态链接）──
if [ "$FS_ONLY" != "1" ]; then
  "$SHU_BIN" -L . "$HELLO_SRC" -o "$OUT"
  strip "$OUT" 2>/dev/null || true
  [ -x "$OUT" ] || { echo "coldstart: failed to build $OUT"; exit 1; }

  MED_US=$(measure_median_us "$OUT" 0)
  SIZE=$(wc -c <"$OUT" | tr -d ' ')
  echo "coldstart hello: median ${MED_US}us stripped_size=${SIZE}B runs=${RUNS}"

  if [ "$DO_BENCH" = "1" ]; then
    echo "=== B-BOOT coldstart bench ==="
    echo "hello_stripped_us	${MED_US}"
  fi

  if [ "$PERF_FAIL" = "1" ]; then
    check_le_cap "hello_stripped_us" "$MED_US" "$(baseline_cap hello_stripped_us)"
  fi
fi

# ── S4 freestanding（按需 io/panic 链入；return42 最小）──
FS_ANY_SKIP=0
if [ "$STD_ONLY" != "1" ]; then
  coldstart_freestanding_one "fs_return42" "$FS_RV42_SRC" "$FS_RV42_OUT" 42 \
    "fs_return42_stripped_us" "fs_return42_stripped_bytes"
  if [ "$FS_CASE_SKIP" = "1" ]; then
    FS_ANY_SKIP=1
  else
    FS_RV42_MED_US="$FS_LAST_MED_US"
    FS_RV42_SIZE="$FS_LAST_SIZE"
  fi

  coldstart_freestanding_one "fs_hello" "$FS_HELLO_SRC" "$FS_HELLO_OUT" 0 \
    "fs_hello_stripped_us" "fs_hello_stripped_bytes"
  if [ "$FS_CASE_SKIP" = "1" ]; then
    FS_ANY_SKIP=1
  else
    FS_MED_US="$FS_LAST_MED_US"
    FS_SIZE="$FS_LAST_SIZE"
  fi

  if [ "$FS_ONLY" = "1" ] && [ "$PERF_FAIL" = "1" ] && [ "$FS_ANY_SKIP" = "1" ]; then
    echo "coldstart FAIL: SHU_COLDSTART_FREESTANDING_ONLY=1 but freestanding build skipped" >&2
    exit 1
  fi
fi

if [ "${SHU_PERF_UPDATE_COLDSTART_BASELINE:-0}" = "1" ]; then
  mkdir -p "$(dirname "$BASELINE")"
  {
    echo "# shu coldstart bench 上限；门禁：实测 ≤ 本列值（us 或 bytes）"
    echo "# 更新：SHU_PERF_UPDATE_COLDSTART_BASELINE=1 ./tests/run-perf-coldstart.sh --bench"
    echo "# hello：含 std.io；fs_*：-freestanding nostdlib static（Linux x86_64，优先 shu_asm）"
    if [ -n "$MED_US" ]; then
      echo "hello_stripped_us	${MED_US}"
    elif [ -f "$BASELINE" ]; then
      awk -F'\t' '$1=="hello_stripped_us"' "$BASELINE"
    fi
    if [ -n "$FS_RV42_MED_US" ]; then
      echo "fs_return42_stripped_us	${FS_RV42_MED_US}"
      echo "fs_return42_stripped_bytes	${FS_RV42_SIZE}"
    elif [ -f "$BASELINE" ]; then
      awk -F'\t' '$1=="fs_return42_stripped_us" || $1=="fs_return42_stripped_bytes"' "$BASELINE"
    fi
    if [ -n "$FS_MED_US" ]; then
      echo "fs_hello_stripped_us	${FS_MED_US}"
      echo "fs_hello_stripped_bytes	${FS_SIZE}"
    elif [ -f "$BASELINE" ]; then
      awk -F'\t' '$1=="fs_hello_stripped_us" || $1=="fs_hello_stripped_bytes"' "$BASELINE"
    fi
  } >"$BASELINE"
  echo "updated $BASELINE"
fi

echo "coldstart OK"
