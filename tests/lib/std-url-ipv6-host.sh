#!/usr/bin/env bash
# std-url-ipv6-host.sh — STD-134 manifest 与烟测辅助

STD_URL_IPV6_HOST_PREFIX="${SHUX_STD134_URL_IPV6_HOST_PREFIX:-shux: [SHUX_STD134_URL_IPV6_HOST]}"

# 校验 manifest 条目；echo 缺失数。
std_url_ipv6_host_symbols_ok() {
  local mod_x="$1"
  local url_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-url-ipv6-host FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/url/url_glue.c) path="$url_x" ;;
          std/url/url.x) path="$url_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-url-ipv6-host FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-url-ipv6-host FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .x 烟测。
std_url_ipv6_host_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_url_ipv6_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-url-ipv6-host FAIL: compile $src" >&2
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

# 链接 url.o 运行 C 金样。
std_url_ipv6_host_run_c_smoke() {
  local url_o="$1"
  local src="tests/std-url/ipv6_host_smoke_ok.c"
  local out="/tmp/shux_std_url_ipv6_c_$$"
  if [ ! -f "$src" ]; then
    printf '%s\n' \
      '#include <stdint.h>' \
      'extern int32_t url_ipv6_host_smoke_c(void);' \
      'int main(void) { return url_ipv6_host_smoke_c() != 0; }' > "$src"
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$url_o" 2>/dev/null; then
    echo "std-url-ipv6-host FAIL: link C smoke" >&2
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
std_url_ipv6_host_emit_report() {
  echo "${STD_URL_IPV6_HOST_PREFIX} status=$1 c=$2 x=$3 skip=$4"
}
