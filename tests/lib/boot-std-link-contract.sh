#!/usr/bin/env bash
# boot-std-link-contract.sh — BOOT-014 live link-path contract helpers
#
# Usage (after source):
#   boot_link_contract_verify_runtime RUNTIME_FILES TSV
#   boot_link_contract_verify_makefile MK_FILE TSV
#   boot_link_contract_emit_report status always_ok on_demand_ok smoke_ok skip
#
# wave honesty (2026-08-24): RUNTIME_FILES is a space-separated live labi seed
# union (std_list + ondemand + ensure + path_pure + freestanding). Monofile
# seeds/runtime.from_x.c retired wave321. Dead get_*_o_path getters are "-";
# live xlang_runtime_*_o_path getters stay. MK_FILE =
# compiler/mk/std_and_panic_objs.mk (Makefile deleted MG wave941).
# PLATFORM: SHARED archaeology.

BOOT_LINK_PREFIX="${XLANG_BOOT_STD_LINK_CONTRACT_PREFIX:-xlang: [XLANG_BOOT_STD_LINK_CONTRACT]}"

# Return 0 if needle appears in any file listed in space-separated haystack.
boot_link_any_file_has() {
  local needle="$1"
  local hay="$2"
  local f
  for f in $hay; do
    if [ -f "$f" ] && grep -qF "$needle" "$f" 2>/dev/null; then
      return 0
    fi
  done
  return 1
}

# Verify live labi seeds contain getter / obj_rel / path-like trigger.
# RUNTIME_FILES: space-separated seed paths. Echo miss count; return 0 iff miss=0.
boot_link_contract_verify_runtime() {
  local rt_files="$1"
  local tsv="$2"
  local miss=0
  local item_id kind getter obj_rel trigger _lf _notes
  while IFS=$'\t' read -r item_id kind getter obj_rel trigger _lf _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|doc|gate|hook_*|c_async_on_demand|c_core_mem_on_demand) continue ;; esac
    case "$kind" in
      std_always|compiler|std_on_demand|freestanding)
        if [ -n "$getter" ] && [ "$getter" != "-" ]; then
          if ! boot_link_any_file_has "$getter" "$rt_files"; then
            echo "boot-std-link-contract FAIL: live seeds missing getter $getter ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        if [ -n "$obj_rel" ] && [ "$obj_rel" != "-" ]; then
          if ! boot_link_any_file_has "$obj_rel" "$rt_files"; then
            echo "boot-std-link-contract FAIL: live seeds missing obj $obj_rel ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        # Skip linker-flag triggers (-lc / -lpthread / …); only path or symbol needles.
        if [ -n "$trigger" ] && [ "$trigger" != "-" ] && [[ "$trigger" != -* ]]; then
          if ! boot_link_any_file_has "$trigger" "$rt_files"; then
            echo "boot-std-link-contract FAIL: live seeds missing trigger $trigger ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Verify mk/std_and_panic_objs.mk STD_AND_PANIC_O contains each std_always /
# always-linked compiler obj_rel (on_demand scheduler / core_mem / freestanding
# skipped; on-demand-only compiler glues use kind std_on_demand in TSV).
boot_link_contract_verify_makefile() {
  local mk="$1"
  local tsv="$2"
  local miss=0
  local item_id kind _getter obj_rel _t _lf _notes
  local line
  # Concatenate base STD_AND_PANIC_O= and any += lines (LINUX freestanding).
  line="$(grep -E '^STD_AND_PANIC_O[[:space:]]*(\+?=)' "$mk" 2>/dev/null | tr '\n' ' ')"
  if [ -z "$line" ]; then
    echo "boot-std-link-contract FAIL: STD_AND_PANIC_O not in $mk" >&2
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
            echo "boot-std-link-contract FAIL: STD_AND_PANIC_O missing $obj_rel ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run a link smoke; return 0 on success.
boot_link_contract_run_smoke() {
  local xlang="$1"
  local x="$2"
  local out="$3"
  rm -f "$out"
  if ! "$xlang" -L . "$x" -o "$out" >/tmp/boot_link_smoke.log 2>&1; then
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

# Emit structured report line.
boot_link_contract_emit_report() {
  local status="$1"
  local always_ok="$2"
  local on_demand_ok="$3"
  local smoke_ok="$4"
  local skip="$5"
  echo "${BOOT_LINK_PREFIX} status=${status} always=${always_ok} on_demand=${on_demand_ok} smoke=${smoke_ok} skip=${skip}"
}
