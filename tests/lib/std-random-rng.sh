#!/usr/bin/env bash
# std-random-rng.sh — STD-130 manifest 与烟测辅助

STD_RANDOM_RNG_PREFIX="${SHUX_STD130_RANDOM_RNG_PREFIX:-shux: [SHUX_STD130_RANDOM_RNG]}"

# 校验 manifest 条目。
std_random_rng_symbols_ok() {
  local mod_sx="$1"
  local random_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|struct_rng)
        if ! grep -qE "(function|struct) ${anchor}" "$mod_sx" 2>/dev/null; then
          echo "std-random-rng FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/random/random.c|std/random/random.sx) path="$random_c" ;;
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
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测；失败时打印 build.log 尾部。
std_random_rng_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_random_rng_$$"
  local log="/tmp/shux_std_random_rng_build_$$.log"
  if ! "$shux" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "std-random-rng FAIL: compile $src" >&2
    tail -12 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
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

# 链接 random.o + runtime_random_fill.o 运行 C smoke。
std_random_rng_run_c_smoke() {
  local random_o="$1"
  local src="tests/random/rng_smoke_ok.c"
  local out="/tmp/shux_std_random_rng_c_$$"
  local fill_o=""
  if [ -f compiler/runtime_random_fill.o ]; then
    fill_o="compiler/runtime_random_fill.o"
  elif [ -f "$(cd compiler && pwd)/runtime_random_fill.o" ]; then
    fill_o="$(cd compiler && pwd)/runtime_random_fill.o"
  else
    make -C compiler runtime_random_fill.o >/dev/null 2>&1 || true
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

# 输出 gate 报告。
std_random_rng_emit_report() {
  echo "${STD_RANDOM_RNG_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
