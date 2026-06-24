#!/usr/bin/env bash
# std-encoding-extra.sh — STD-127 manifest 与烟测辅助

STD_ENCODING_EXTRA_PREFIX="${SHUX_STD127_ENCODING_EXTRA_PREFIX:-shux: [SHUX_STD127_ENCODING_EXTRA]}"

# 校验 manifest 条目。
std_encoding_extra_symbols_ok() {
  local mod_sx="$1"
  local encoding_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_sx" 2>/dev/null; then
          echo "std-encoding-extra FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/encoding/encoding.c|std/encoding/encoding.sx) path="$encoding_c" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-encoding-extra FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-encoding-extra FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_encoding_extra_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_encoding_extra_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-encoding-extra FAIL: compile $src" >&2
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

# 链接 encoding.o 运行 C smoke。
std_encoding_extra_run_c_smoke() {
  local encoding_o="$1"
  local src="tests/encoding/extra_smoke_ok.c"
  local out="/tmp/shux_std_encoding_extra_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t encoding_extra_smoke_c(void);' \
      'int main(void) { return encoding_extra_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$encoding_o" 2>/dev/null; then
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
std_encoding_extra_emit_report() {
  echo "${STD_ENCODING_EXTRA_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
