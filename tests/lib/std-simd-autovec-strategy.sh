#!/usr/bin/env bash
# std-simd-autovec-strategy.sh — STD-153 manifest、烟测与 perf 辅助
#
# 用法（source 后）：
#   std_simd_autovec_symbols_ok MOD_X SIMD_X SIMD_GLUE TSV [DOC]
#   std_simd_autovec_platform_key
#   std_simd_autovec_perf_thresholds VECTORS platform_key
#   std_simd_autovec_run_c_smoke
#   std_simd_autovec_run_x_smoke XLANG_BIN X
#   std_simd_autovec_run_perf XLANG_ASM dot_min ss_min
#   std_simd_autovec_emit_report status run obs skip [host]
# Honesty: run=/obs=/skip= (check/C/perf = obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD153_PREFIX="${XLANG_STD153_SIMD_AUTovec_PREFIX:-xlang: [XLANG_STD153_SIMD_AUTovec]}"

# 校验 manifest；echo 缺失数。DOC（可选）用于 section 锚，默认 archive 闸门 DOC。
std_simd_autovec_symbols_ok() {
  local mod_x="$1"
  local simd_x="$2"
  local simd_glue="$3"
  local tsv="$4"
  local doc="${5:-analysis/archive/std/std-simd-autovec-strategy-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-simd-autovec FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/simd/simd.c|std/simd/simd.x|std/simd/simd_os_glue.c) path="$simd_x" ;;
        esac
        if [ "$path" = "std/simd/mod.x" ]; then path="$mod_x"; fi
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
        # Single authority: gate DOC (archive by default). Ban live/archive dual grep.
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-simd-autovec FAIL: missing section '$anchor' in $doc" >&2
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

# Observational C smoke against an existing simd.o only.
# Refuse soft ensure_std_c_o rebuild (gate never rebuilds host .o).
# PLATFORM: SHARED archaeology — host-C path is observational only.
std_simd_autovec_run_c_smoke() {
  local smoke_c="tests/std-simd/autovec_strategy_ok.c"
  local exe="/tmp/xlang_std153_simd_autovec_c_$$"
  local simd_o="std/simd/simd.o"
  if [ ! -f "$simd_o" ]; then
    return 1
  fi
  if ! cc -std=c11 -Wall -Wextra -o "$exe" "$smoke_c" "$simd_o" 2>/dev/null; then
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

# Compile and run .x smoke via product XLANG_BIN -L . -o; expect exit 0.
# Refuse soft RUN_XLANG remap / soft ensure rebuild (gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — product honesty path; SIMD needs asm backend.
std_simd_autovec_run_x_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std153_simd_autovec_x_$$"
  local log="/tmp/xlang_std153_simd_autovec_build_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-simd-autovec FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-simd-autovec FAIL: compile $src" >&2
    tail -n 12 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-simd-autovec FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 运行 dot + shuffle/select perf；阈值为 0 则 skip；bench 不可运行／低于阈值时 return 1（闸门软 SKIP）。
std_simd_autovec_run_perf() {
  local xlang_asm="$1"
  local dot_min="$2"
  local ss_min="$3"
  local dot_ok=1
  local ss_ok=1
  if awk -v d="$dot_min" 'BEGIN { exit (d + 0 > 0.001) ? 0 : 1 }'; then
    set +e
    local dot_out
    dot_out=$(XLANG="$xlang_asm" XLANG_LINK_XLANG="$xlang_asm" XLANG_SIMD_DOT_MIN_RATIO="$dot_min" XLANG_SIMD_DOT_FAIL=1 \
      ./tests/run-perf-simd-dot.sh 2>&1)
    local dot_ec=$?
    set -e
    if [ "$dot_ec" -ne 0 ]; then
      if echo "$dot_out" | grep -qE 'SKIP|FAIL: compile'; then
        echo "std-simd-autovec WARN: dot perf skipped (bench unavailable)" >&2
        dot_ok=0
      else
        echo "std-simd-autovec WARN: dot perf below ${dot_min}" >&2
        echo "$dot_out" | tail -6 >&2
        dot_ok=0
      fi
    fi
  fi
  if awk -v s="$ss_min" 'BEGIN { exit (s + 0 > 0.001) ? 0 : 1 }'; then
    set +e
    local ss_out
    ss_out=$(XLANG="$xlang_asm" XLANG_LINK_XLANG="$xlang_asm" XLANG_SIMD_SS_MIN_RATIO="$ss_min" XLANG_SIMD_SS_FAIL=1 \
      ./tests/run-perf-simd-shuffle-select.sh 2>&1)
    local ss_ec=$?
    set -e
    if [ "$ss_ec" -ne 0 ]; then
      if echo "$ss_out" | grep -qE 'SKIP|FAIL: compile'; then
        echo "std-simd-autovec WARN: shuffle/select perf skipped" >&2
        ss_ok=0
      else
        echo "std-simd-autovec WARN: shuffle/select perf below ${ss_min}" >&2
        echo "$ss_out" | tail -6 >&2
        ss_ok=0
      fi
    fi
  fi
  if [ "$dot_ok" -eq 1 ] && [ "$ss_ok" -eq 1 ]; then
    return 0
  fi
  return 1
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o autovec_strategy.x; check/C/perf = obs.
# Optional host= kept for platform archaeology (not a hard-green field).
std_simd_autovec_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  local host="${5:-}"
  if [ -n "$host" ]; then
    echo "${STD153_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip} host=${host}"
  else
    echo "${STD153_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
  fi
}
