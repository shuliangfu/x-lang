#!/usr/bin/env bash
# boot-std-link-contract.sh — BOOT-014 runtime.c 链接契约校验辅助
#
# 用法（source 后）：
#   boot_link_contract_verify_runtime RUNTIME_C TSV
#   boot_link_contract_verify_makefile MAKEFILE TSV
#   boot_link_contract_emit_report status always_ok on_demand_ok smoke_ok skip

BOOT_LINK_PREFIX="${SHUX_BOOT_STD_LINK_CONTRACT_PREFIX:-shux: [SHUX_BOOT_STD_LINK_CONTRACT]}"

# 校验 runtime.c 含 getter 与 obj_rel；on_demand/freestanding 含 trigger。
# echo 缺失数；成功返回 0。
boot_link_contract_verify_runtime() {
  local rt="$1"
  local tsv="$2"
  local miss=0
  local item_id kind getter obj_rel trigger _lf _notes
  while IFS=$'\t' read -r item_id kind getter obj_rel trigger _lf _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|doc|gate|hook_*|c_async_on_demand|c_core_mem_on_demand) continue ;; esac
    case "$kind" in
      std_always|compiler|std_on_demand|freestanding)
        if [ -n "$getter" ] && [ "$getter" != "-" ]; then
          if ! grep -qF "$getter" "$rt" 2>/dev/null; then
            echo "boot-std-link-contract FAIL: runtime missing getter $getter ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        if [ -n "$obj_rel" ] && [ "$obj_rel" != "-" ]; then
          if ! grep -qF "$obj_rel" "$rt" 2>/dev/null; then
            echo "boot-std-link-contract FAIL: runtime missing obj $obj_rel ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        if [ -n "$trigger" ] && [ "$trigger" != "-" ]; then
          if ! grep -qF "$trigger" "$rt" 2>/dev/null; then
            echo "boot-std-link-contract FAIL: runtime missing trigger $trigger ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验 compiler/Makefile STD_AND_PANIC_O 含各 std_always .o（不含 on_demand scheduler）。
boot_link_contract_verify_makefile() {
  local mk="$1"
  local tsv="$2"
  local miss=0
  local item_id kind _getter obj_rel _t _lf _notes
  local line
  line="$(grep '^STD_AND_PANIC_O' "$mk" 2>/dev/null | head -1)"
  if [ -z "$line" ]; then
    echo "boot-std-link-contract FAIL: STD_AND_PANIC_O not in Makefile" >&2
    echo 1
    return 1
  fi
  while IFS=$'\t' read -r item_id kind _getter obj_rel _t _lf _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|doc|gate|hook_*|c_async_on_demand|c_core_mem_on_demand|async_sched|core_mem|freestanding_*) continue ;; esac
    case "$kind" in
      std_always|compiler)
        if [ -n "$obj_rel" ] && [ "$obj_rel" != "-" ]; then
          if ! echo "$line" | grep -qF "$obj_rel"; then
            echo "boot-std-link-contract FAIL: Makefile missing $obj_rel ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行链接烟测；成功返回 0。
boot_link_contract_run_smoke() {
  local shux="$1"
  local x="$2"
  local out="$3"
  rm -f "$out"
  if ! "$shux" -L . "$x" -o "$out" >/tmp/boot_link_smoke.log 2>&1; then
    cat /tmp/boot_link_smoke.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "boot-std-link-contract FAIL: $x exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
boot_link_contract_emit_report() {
  local status="$1"
  local always_ok="$2"
  local on_demand_ok="$3"
  local smoke_ok="$4"
  local skip="$5"
  echo "${BOOT_LINK_PREFIX} status=${status} always=${always_ok} on_demand=${on_demand_ok} smoke=${smoke_ok} skip=${skip}"
}
