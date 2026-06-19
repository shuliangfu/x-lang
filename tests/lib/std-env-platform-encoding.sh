#!/usr/bin/env bash
# std-env-platform-encoding.sh — STD-132 manifest 与烟测辅助

STD_ENV_PLATFORM_ENCODING_PREFIX="${SHUX_STD132_ENV_PLATFORM_ENCODING_PREFIX:-shux: [SHUX_STD132_ENV_PLATFORM_ENCODING]}"

# 校验 manifest 条目；echo 缺失数。
std_env_platform_encoding_symbols_ok() {
  local mod_su="$1"
  local env_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_su" 2>/dev/null; then
          echo "std-env-platform-encoding FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/env/env.c) path="$env_c" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-env-platform-encoding FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-env-platform-encoding FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_env_platform_encoding_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_env_pe_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-env-platform-encoding FAIL: compile $src" >&2
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

# 链接 env.o 运行 C 金样。
std_env_platform_encoding_run_c_smoke() {
  local env_o="$1"
  local src="tests/env/platform_encoding_smoke_ok.c"
  local out="/tmp/shux_std_env_pe_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t env_platform_encoding_smoke_c(void);' \
      'int main(void) { return env_platform_encoding_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$env_o" 2>/dev/null; then
    echo "std-env-platform-encoding FAIL: link C smoke" >&2
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
std_env_platform_encoding_emit_report() {
  echo "${STD_ENV_PLATFORM_ENCODING_PREFIX} status=$1 c=$2 su=$3 skip=$4"
}
