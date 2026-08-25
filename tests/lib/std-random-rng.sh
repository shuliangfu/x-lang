#!/usr/bin/env bash
# std-random-rng.sh — STD-130 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_random_rng_symbols_ok MOD_X RANDOM_X TSV
#   std_random_rng_run_smoke XLANG_BIN X TAG
#   std_random_rng_run_c_smoke RANDOM_O
#   std_random_rng_emit_report status check_ok rt_ok main_ok skip

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_RANDOM_RNG_PREFIX="${XLANG_STD130_RANDOM_RNG_PREFIX:-xlang: [XLANG_STD130_RANDOM_RNG]}"

# 校验 manifest 条目。
std_random_rng_symbols_ok() {
  local mod_x="$1"
  local random_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|struct_rng)
        if ! grep -qE "(function|struct) ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-random-rng FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/random/random.c|std/random/random.x) path="$random_c" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-random-rng FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-random-rng FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script)
        # Gate script verifies section anchors in DOC; scripts listed for inventory.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_random_rng_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_random_rng_${tag}_$$"
  local log="/tmp/xlang_std_random_rng_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-random-rng FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-random-rng FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-random-rng FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-random-rng FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 链接 random.o + runtime_random_fill.o 运行 C smoke（观测；非硬绿）。
std_random_rng_run_c_smoke() {
  local random_o="$1"
  local src="tests/random/rng_smoke_ok.c"
  local out="/tmp/xlang_std_random_rng_c_$$"
  local fill_o=""
  if [ -f compiler/runtime_random_fill.o ]; then
    fill_o="compiler/runtime_random_fill.o"
  elif [ -f "$(cd compiler && pwd)/runtime_random_fill.o" ]; then
    fill_o="$(cd compiler && pwd)/runtime_random_fill.o"
  else
    xlang_compiler_make runtime_random_fill.o >/dev/null 2>&1 || true
    fill_o="compiler/runtime_random_fill.o"
  fi
  if [ ! -f "$fill_o" ]; then
    echo "std-random-rng FAIL: missing runtime_random_fill.o" >&2
    return 1
  fi
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t random_rng_smoke_c(void);' \
      'int main(void) { return random_rng_smoke_c() != 0; }' > "$src"
  fi
  local ld_extra=""
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) ld_extra="-lbcrypt" ;;
  esac
  if ! cc -std=c11 -O1 -o "$out" "$src" "$random_o" "$fill_o" $ld_extra 2>/dev/null; then
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_random_rng_emit_report() {
  local status="$1"
  local check_ok="$2"
  local rt_ok="$3"
  local main_ok="$4"
  local skip="$5"
  echo "${STD_RANDOM_RNG_PREFIX} status=${status} check=${check_ok} rt=${rt_ok} main=${main_ok} skip=${skip}"
}
