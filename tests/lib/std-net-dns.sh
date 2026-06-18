#!/usr/bin/env bash
# std-net-dns.sh — STD-029 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_net_dns_symbols_ok MOD_SU NET_C TSV
#   std_net_dns_run_smoke SHU_BIN SU TAG
#   std_net_dns_emit_report status resolve_ok main_ok skip

STD_NET_DNS_PREFIX="${SHU_STD_NET_DNS_PREFIX:-shu: [SHU_STD_NET_DNS]}"

# 校验 manifest symbol/file/api；echo 缺失数。
std_net_dns_symbols_ok() {
  local mod_su="$1"
  local net_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-net-dns FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/net/net.c) mod_path="$net_c" ;;
          *) mod_path="$mod_su" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-net-dns FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-net-dns FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .su（须已 ensure net.o）。
std_net_dns_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shu_std_net_dns_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-net-dns FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-net-dns FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-net-dns FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_net_dns_emit_report() {
  local status="$1"
  local resolve_ok="$2"
  local main_ok="$3"
  local skip="$4"
  echo "${STD_NET_DNS_PREFIX} status=${status} resolve=${resolve_ok} main=${main_ok} skip=${skip}"
}
