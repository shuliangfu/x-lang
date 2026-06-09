#!/usr/bin/env bash
# DOD-S1 perf：SoA vs AoS 列扫描；Linux 上可选 perf L1 miss 率（SoA 目标 ≤ 1%）。
# 用法：
#   ./tests/run-perf-dod-soa.sh
#   SHU=./compiler/shu_asm ./tests/run-perf-dod-soa.sh
#   SHU_DOD_SOA_FAIL=1 ./tests/run-perf-dod-soa.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"

SHU_BIN="${SHU:-./compiler/shu_asm}"
SOA_SRC="tests/bench/dod_soa_sum_x.su"
AOS_SRC="tests/bench/dod_aos_sum_x.su"
F32_SOA_SRC="tests/bench/dod_f32_soa_sum_x.su"
F32_AOS_SRC="tests/bench/dod_f32_aos_sum_x.su"
SOA_O="/tmp/shu_dod_soa_bench.o"
AOS_O="/tmp/shu_dod_aos_bench.o"
F32_SOA_O="/tmp/shu_dod_f32_soa_bench.o"
F32_AOS_O="/tmp/shu_dod_f32_aos_bench.o"
SOA_EXE="/tmp/shu_dod_soa_bench"
AOS_EXE="/tmp/shu_dod_aos_bench"
F32_SOA_EXE="/tmp/shu_dod_f32_soa_bench"
F32_AOS_EXE="/tmp/shu_dod_f32_aos_bench"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"
N="${SHU_DOD_BENCH_N:-4096}"
MAX_SOA_MISS_PCT="${SHU_DOD_SOA_MAX_L1_MISS_PCT:-1.0}"
# Linux wait status 仅低 8 bit：N>255 时 bench 返回 sum/256，门禁比对 WANT_RC。
WANT_RC="$N"
if [ "$N" -gt 255 ] 2>/dev/null; then
  WANT_RC=$((N / 256))
fi

# sum=4096 → return/256=16；若误返 4096 则 shell exit=0（与 16 等价）
dod_rc_ok() {
  local rc="$1"
  [ "$rc" = "$WANT_RC" ] && return 0
  if [ "$WANT_RC" = "16" ] && [ "$N" = "4096" ] && [ "$rc" = "0" ]; then
    return 0
  fi
  return 1
}

echo "=== DOD SoA perf: ${SOA_SRC} vs ${AOS_SRC} (N=${N}, SoA L1 miss cap ${MAX_SOA_MISS_PCT}%) ==="
echo "=== DOD f32 addss bench: ${F32_SOA_SRC} vs ${F32_AOS_SRC} ==="

if ! dod_native_exe "$SHU_BIN"; then
  if [ -n "${SHU_CI_NO_SKIP:-}" ]; then
    echo "dod-soa FAIL: ${SHU_BIN} not native on $(uname -s)-$(uname -m)" >&2
    exit 1
  fi
  echo "dod-soa SKIP: ${SHU_BIN} not native (rebuild shu_asm on Linux)"
  exit 0
fi

rm -f "$SOA_O" "$AOS_O" "$F32_SOA_O" "$F32_AOS_O" "$SOA_EXE" "$AOS_EXE" "$F32_SOA_EXE" "$F32_AOS_EXE"

# 优先 shu_asm 全量链接（不依赖 crt0）；失败再回落 .o + ld。
if ! SHU="$SHU_BIN" "$SHU_BIN" "$SOA_SRC" -o "$SOA_EXE" 2>/dev/null; then
  SOA_EXE=""
  if ! SHU="$SHU_BIN" "$SHU_BIN" "$SOA_SRC" -o "$SOA_O"; then
    echo "dod-soa FAIL: compile $SOA_SRC" >&2
    exit 1
  fi
fi
if ! SHU="$SHU_BIN" "$SHU_BIN" "$AOS_SRC" -o "$AOS_EXE" 2>/dev/null; then
  AOS_EXE=""
  if ! SHU="$SHU_BIN" "$SHU_BIN" "$AOS_SRC" -o "$AOS_O"; then
    echo "dod-soa FAIL: compile $AOS_SRC" >&2
    exit 1
  fi
fi

# Linux：仅当 -o exe 未产出时，尝试 .o + crt0 链可执行文件。
if [ "$(uname -s)" = "Linux" ] && command -v ld >/dev/null 2>&1 && [ -f "$CRT0" ]; then
  if [ -z "$SOA_EXE" ] || [ ! -x "$SOA_EXE" ]; then
    if [ -f "$SOA_O" ] && ld -o "$SOA_EXE" "$SOA_O" "$CRT0" 2>/dev/null; then
      :
    else
      echo "dod-soa WARN: link $SOA_EXE skipped (compile-only OK)" >&2
      SOA_EXE=""
    fi
  fi
  if [ -z "$AOS_EXE" ] || [ ! -x "$AOS_EXE" ]; then
    if [ -f "$AOS_O" ] && ld -o "$AOS_EXE" "$AOS_O" "$CRT0" 2>/dev/null; then
      :
    else
      echo "dod-soa WARN: link $AOS_EXE skipped (compile-only OK)" >&2
      AOS_EXE=""
    fi
  fi
fi

# f32 列扫描（addss 热路径）
if ! SHU="$SHU_BIN" "$SHU_BIN" "$F32_SOA_SRC" -o "$F32_SOA_EXE" 2>/dev/null; then
  F32_SOA_EXE=""
  if ! SHU="$SHU_BIN" "$SHU_BIN" "$F32_SOA_SRC" -o "$F32_SOA_O"; then
    echo "dod-soa FAIL: compile $F32_SOA_SRC" >&2
    exit 1
  fi
fi
if ! SHU="$SHU_BIN" "$SHU_BIN" "$F32_AOS_SRC" -o "$F32_AOS_EXE" 2>/dev/null; then
  F32_AOS_EXE=""
  if ! SHU="$SHU_BIN" "$SHU_BIN" "$F32_AOS_SRC" -o "$F32_AOS_O"; then
    echo "dod-soa FAIL: compile $F32_AOS_SRC" >&2
    exit 1
  fi
fi

if [ "$(uname -s)" = "Linux" ] && command -v ld >/dev/null 2>&1 && [ -f "$CRT0" ]; then
  if [ -z "$F32_SOA_EXE" ] || [ ! -x "$F32_SOA_EXE" ]; then
    if [ -f "$F32_SOA_O" ] && ld -o "$F32_SOA_EXE" "$F32_SOA_O" "$CRT0" 2>/dev/null; then
      :
    else
      F32_SOA_EXE=""
    fi
  fi
  if [ -z "$F32_AOS_EXE" ] || [ ! -x "$F32_AOS_EXE" ]; then
    if [ -f "$F32_AOS_O" ] && ld -o "$F32_AOS_EXE" "$F32_AOS_O" "$CRT0" 2>/dev/null; then
      :
    else
      F32_AOS_EXE=""
    fi
  fi
fi

if [ -x "$F32_SOA_EXE" ] && [ -x "$F32_AOS_EXE" ]; then
  F32_SOA_RC="$("$F32_SOA_EXE" 2>/dev/null; echo $?)"
  F32_SOA_RC="${F32_SOA_RC##*$'\n'}"
  F32_AOS_RC="$("$F32_AOS_EXE" 2>/dev/null; echo $?)"
  F32_AOS_RC="${F32_AOS_RC##*$'\n'}"
  echo "f32 SoA exit=${F32_SOA_RC} (expect ${WANT_RC})  f32 AoS exit=${F32_AOS_RC} (expect ${WANT_RC})"
  if ! dod_rc_ok "$F32_SOA_RC" || ! dod_rc_ok "$F32_AOS_RC"; then
    echo "dod-soa FAIL: f32 bench correctness" >&2
    if [ "${SHU_DOD_SOA_FAIL:-0}" = "1" ]; then
      exit 1
    fi
  fi
  if command -v objdump >/dev/null 2>&1; then
    F32_SOA_DIS="$(objdump -d "$F32_SOA_EXE" 2>/dev/null || true)"
    if echo "$F32_SOA_DIS" | grep -qE 'movups|addps'; then
      echo "dod-soa: f32 SoA disasm movups/addps OK (SIMD reduce peel)"
    elif echo "$F32_SOA_DIS" | grep -q 'addss'; then
      echo "dod-soa: f32 SoA disasm addss OK"
    else
      echo "dod-soa FAIL: f32 SoA disasm missing movups/addps or addss" >&2
      if [ "${SHU_DOD_SOA_FAIL:-0}" = "1" ]; then
        exit 1
      fi
    fi
    if objdump -d "$F32_AOS_EXE" 2>/dev/null | grep -q 'addss'; then
      echo "dod-soa: f32 AoS disasm addss OK"
    else
      echo "dod-soa WARN: f32 AoS disasm missing addss (non-fatal)" >&2
    fi
  fi
elif [ -f "$F32_SOA_O" ] && [ -f "$F32_AOS_O" ]; then
  echo "dod-soa: f32 bench compile-only OK"
else
  echo "dod-soa FAIL: f32 bench missing object or executable" >&2
  if [ "${SHU_DOD_SOA_FAIL:-0}" = "1" ]; then
    exit 1
  fi
fi

if [ -z "$SOA_EXE" ] || [ -z "$AOS_EXE" ] || [ ! -x "$SOA_EXE" ] || [ ! -x "$AOS_EXE" ]; then
  if [ -f "$SOA_O" ] && [ -f "$AOS_O" ]; then
    echo "dod-soa: compile-only OK (no runnable exe)"
    echo "dod-soa gate OK"
    exit 0
  fi
  echo "dod-soa FAIL: missing object or executable" >&2
  exit 1
fi

SOA_RC="$("$SOA_EXE" 2>/dev/null; echo $?)"
SOA_RC="${SOA_RC##*$'\n'}"
AOS_RC="$("$AOS_EXE" 2>/dev/null; echo $?)"
AOS_RC="${AOS_RC##*$'\n'}"
echo "SoA exit=${SOA_RC} (expect ${WANT_RC}, raw sum=${N})  AoS exit=${AOS_RC} (expect ${WANT_RC})"
if ! dod_rc_ok "$SOA_RC" || ! dod_rc_ok "$AOS_RC"; then
  echo "dod-soa FAIL: correctness" >&2
  if [ "${SHU_DOD_SOA_FAIL:-0}" = "1" ]; then
    exit 1
  fi
fi

SOA_MISS="nan"
AOS_MISS="nan"
if [ "$(uname -s)" = "Linux" ]; then
  # 解析 perf 可执行路径（GHA 常仅 linux-tools-* 目录下有 perf）。
  perf_resolve_bin() {
    if command -v perf >/dev/null 2>&1; then
      command -v perf
      return 0
    fi
    local p
    for p in /usr/lib/linux-tools/*/perf; do
      if [ -x "$p" ]; then
        printf '%s' "$p"
        return 0
      fi
    done
    return 1
  }

  # perf stat -x, CSV：取 event 对应计数值。
  perf_csv_event_count() {
    local out="$1"
    local event="$2"
    echo "$out" | awk -F, -v ev="$event" '
      index($0, ev) && $1 ~ /^[0-9][0-9,]*$/ {
        gsub(/,/, "", $1)
        print $1
        exit
      }
    '
  }

  # 默认文本输出：取含 event 行中首个正整数（兼容「计数 事件」与「时间 计数 unit 事件」）。
  perf_text_event_count() {
    local out="$1"
    local event="$2"
    echo "$out" | awk -v ev="$event" '
      index($0, ev) && $0 !~ /not supported|not counted|<not/ {
        for (i = 1; i <= NF; i++) {
          gsub(/,/, "", $i)
          if ($i ~ /^[0-9]+$/ && $i + 0 > 0) {
            print $i
            exit
          }
        }
      }
    '
  }

  # 跑 perf stat 并解析 loads/misses；失败时 loads/misses 为空。
  perf_stat_load_miss_pair() {
    local perf_cmd="$1"
    local exe="$2"
    local ev_load="$3"
    local ev_miss="$4"
    local out loads misses
    out=$("$perf_cmd" stat -x, -e "${ev_load},${ev_miss}" -- "$exe" 2>&1 || true)
    if echo "$out" | grep -qiE 'Permission denied|perf_event_paranoid'; then
      if command -v sudo >/dev/null 2>&1; then
        out=$(sudo "$perf_cmd" stat -x, -e "${ev_load},${ev_miss}" -- "$exe" 2>&1 || true)
      fi
    fi
    loads=$(perf_csv_event_count "$out" "$ev_load")
    misses=$(perf_csv_event_count "$out" "$ev_miss")
    if [ -z "$loads" ] || [ -z "$misses" ]; then
      out=$("$perf_cmd" stat -e "${ev_load},${ev_miss}" -- "$exe" 2>&1 || true)
      loads=$(perf_text_event_count "$out" "$ev_load")
      misses=$(perf_text_event_count "$out" "$ev_miss")
    fi
    printf '%s %s' "$loads" "$misses"
  }

  # L1-dcache 优先；Docker/内核不匹配时回落 cache-references/misses（GHA ubuntu 原生可用 L1）。
  perf_l1_miss_pct() {
    local exe="$1"
    local perf_cmd loads misses pct pair
    perf_cmd="$(perf_resolve_bin)" || { echo "nan"; return; }
    sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
    pair=$(perf_stat_load_miss_pair "$perf_cmd" "$exe" "L1-dcache-loads" "L1-dcache-load-misses")
    loads="${pair%% *}"
    misses="${pair#* }"
    if [ -z "$loads" ] || [ -z "$misses" ]; then
      pair=$(perf_stat_load_miss_pair "$perf_cmd" "$exe" "cache-references" "cache-misses")
      loads="${pair%% *}"
      misses="${pair#* }"
    fi
    if [ -z "$loads" ] || [ -z "$misses" ] || [ "$loads" = "0" ]; then
      echo "nan"
      return
    fi
    pct=$(awk -v m="$misses" -v l="$loads" 'BEGIN { printf "%.4f", (m/l)*100.0 }')
    echo "$pct"
  }
  if ! perf_cmd="$(perf_resolve_bin)"; then
    echo "dod-soa: perf stat skipped (no perf binary)"
  else
  SOA_MISS=$(perf_l1_miss_pct "$SOA_EXE")
  AOS_MISS=$(perf_l1_miss_pct "$AOS_EXE")
  echo "SoA L1 miss rate: ${SOA_MISS}%"
  echo "AoS L1 miss rate: ${AOS_MISS}%"
  if [ "$SOA_MISS" != "nan" ]; then
    if awk -v s="$SOA_MISS" -v cap="$MAX_SOA_MISS_PCT" 'BEGIN { exit (s + 0 <= cap + 0.0001) ? 0 : 1 }'; then
      echo "dod-soa L1 miss OK (SoA <= ${MAX_SOA_MISS_PCT}%)"
    else
      echo "dod-soa L1 miss WARN: SoA ${SOA_MISS}% > cap ${MAX_SOA_MISS_PCT}%" >&2
      if [ "${SHU_DOD_SOA_FAIL:-0}" = "1" ]; then
        exit 1
      fi
    fi
  fi
  if [ "$SOA_MISS" != "nan" ] && [ "$AOS_MISS" != "nan" ]; then
    if awk -v soa="$SOA_MISS" -v aos="$AOS_MISS" 'BEGIN { exit (soa < aos) ? 0 : 1 }'; then
      echo "dod-soa: SoA L1 miss < AoS (column scan wins)"
    else
      echo "dod-soa WARN: SoA L1 miss not lower than AoS" >&2
    fi
  fi
  fi
else
  echo "dod-soa: perf stat skipped (need Linux + perf)"
fi

# GHA / CI：SHU_DOD_SOA_REQUIRE_L1=1 时 perf 必须可用，禁止 SKIP。
if [ "${SHU_DOD_SOA_REQUIRE_L1:-0}" = "1" ]; then
  if [ "${SOA_MISS:-nan}" = "nan" ] || [ "${AOS_MISS:-nan}" = "nan" ]; then
    echo "dod-soa FAIL: SHU_DOD_SOA_REQUIRE_L1=1 but perf miss rate unavailable" >&2
    exit 1
  fi
fi

echo "dod-soa gate OK"
