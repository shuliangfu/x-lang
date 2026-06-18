#!/usr/bin/env bash
# std-simd-autovec-strategy.sh — STD-153 manifest、烟测与 perf 辅助
#
# 用法（source 后）：
#   std_simd_autovec_symbols_ok MOD_SU SIMD_C TSV
#   std_simd_autovec_platform_key
#   std_simd_autovec_perf_thresholds VECTORS platform_key
#   std_simd_autovec_run_c_smoke
#   std_simd_autovec_run_su_smoke SHU_BIN SU SIMD_O
#   std_simd_autovec_run_perf SHU_ASM dot_min ss_min
#   std_simd_autovec_emit_report status c_ok su_ok perf_ok skip host

STD153_PREFIX="${SHU_STD153_SIMD_AUTovec_PREFIX:-shu: [SHU_STD153_SIMD_AUTovec]}"

# 校验 manifest；echo 缺失数。
std_simd_autovec_symbols_ok() {
  local mod_su="$1"
  local simd_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-simd-autovec FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/simd/simd.c" ]; then path="$simd_c"; fi
        if [ "$path" = "std/simd/mod.su" ]; then path="$mod_su"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-simd-autovec FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-simd-autovec FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-simd-autovec-strategy-v1.md" 2>/dev/null; then
          echo "std-simd-autovec FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 返回 OS-ARCH 平台键（如 Darwin-arm64）。
std_simd_autovec_platform_key() {
  local os arch
  os="$(uname -s 2>/dev/null || echo Unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  case "$arch" in
    aarch64) arch="arm64" ;;
  esac
  echo "${os}-${arch}"
}

# 从向量表读取 perf 阈值；echo "dot ss"。
std_simd_autovec_perf_thresholds() {
  local tsv="$1"
  local key="$2"
  local dot=0.0 ss=0.0
  local plat min_dot min_ss
  while IFS=$'\t' read -r plat min_dot min_ss _notes; do
    [ -z "${plat:-}" ] && continue
    case "$plat" in \#*) continue ;; esac
    if [ "$plat" = "$key" ] || [ "$plat" = "*" ]; then
      dot="$min_dot"
      ss="$min_ss"
      [ "$plat" = "$key" ] && break
    fi
  done < "$tsv"
  echo "$dot $ss"
}

# 编译并运行 C 烟测。
std_simd_autovec_run_c_smoke() {
  local smoke_c="tests/std-simd/autovec_strategy_ok.c"
  local exe="/tmp/shu_std153_simd_autovec_c_$$"
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/simd/simd.o
  local simd_o
  simd_o="$(cd compiler && pwd)/../std/simd/simd.o"
  if ! cc -std=c11 -Wall -Wextra -o "$exe" "$smoke_c" "$simd_o" 2>/dev/null; then
    echo "std-simd-autovec FAIL: compile C smoke" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-simd-autovec FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 编译并运行 .su 烟测。
std_simd_autovec_run_su_smoke() {
  local shu="$1"
  local src="$2"
  local simd_o="$3"
  local exe="/tmp/shu_std153_simd_autovec_su_$$"
  if ! "$shu" -L . "$src" -o "$exe" "$simd_o" >/dev/null 2>&1; then
    echo "std-simd-autovec FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-simd-autovec FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 运行 dot + shuffle/select perf；阈值为 0 则 skip；bench 不可运行时不失败。
std_simd_autovec_run_perf() {
  local shu_asm="$1"
  local dot_min="$2"
  local ss_min="$3"
  local dot_ok=1
  local ss_ok=1
  if awk -v d="$dot_min" 'BEGIN { exit (d + 0 > 0.001) ? 0 : 1 }'; then
    set +e
    local dot_out
    dot_out=$(SHU="$shu_asm" SHU_SIMD_DOT_MIN_RATIO="$dot_min" SHU_SIMD_DOT_FAIL=1 \
      ./tests/run-perf-simd-dot.sh 2>&1)
    local dot_ec=$?
    set -e
    if [ "$dot_ec" -ne 0 ]; then
      if echo "$dot_out" | grep -qE 'SKIP|FAIL: compile'; then
        echo "std-simd-autovec WARN: dot perf skipped (bench unavailable)" >&2
        dot_ok=1
      else
        echo "std-simd-autovec FAIL: dot perf below ${dot_min}" >&2
        echo "$dot_out" | tail -6 >&2
        return 1
      fi
    fi
  fi
  if awk -v s="$ss_min" 'BEGIN { exit (s + 0 > 0.001) ? 0 : 1 }'; then
    set +e
    local ss_out
    ss_out=$(SHU="$shu_asm" SHU_SIMD_SS_MIN_RATIO="$ss_min" SHU_SIMD_SS_FAIL=1 \
      ./tests/run-perf-simd-shuffle-select.sh 2>&1)
    local ss_ec=$?
    set -e
    if [ "$ss_ec" -ne 0 ]; then
      if echo "$ss_out" | grep -qE 'SKIP|FAIL: compile'; then
        echo "std-simd-autovec WARN: shuffle/select perf skipped" >&2
        ss_ok=1
      else
        echo "std-simd-autovec FAIL: shuffle/select perf below ${ss_min}" >&2
        echo "$ss_out" | tail -6 >&2
        return 1
      fi
    fi
  fi
  if [ "$dot_ok" -eq 1 ] && [ "$ss_ok" -eq 1 ]; then
    return 0
  fi
  return 1
}

# 输出结构化报告行。
std_simd_autovec_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local perf_ok="$4"
  local skip="$5"
  local host="$6"
  echo "${STD153_PREFIX} status=${status} c=${c_ok} su=${su_ok} perf=${perf_ok} skip=${skip} host=${host}"
}
