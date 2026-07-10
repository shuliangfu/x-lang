#!/usr/bin/env bash
# BOOT-014：std 模块链接契约门禁（runtime.c ↔ manifest ↔ Makefile）
#
# 用法：./tests/run-boot-std-link-contract-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT_LINK_DOC:-analysis/boot-std-link-contract-v1.md}"
MANIFEST="${SHUX_BOOT_LINK_TSV:-tests/baseline/boot-std-link-contract.tsv}"
RUNTIME="${SHUX_BOOT_LINK_RUNTIME:-compiler/seeds/runtime.from_x.c}"
MAKEFILE="${SHUX_BOOT_LINK_MAKEFILE:-compiler/Makefile}"
LIB="tests/lib/boot-std-link-contract.sh"
JSON_X="tests/json/object_array_parse.x"
ASYNC_X="tests/async/await_scheduler_mod.x"
CORE_MEM_X="tests/core-mem/volatile_fence.x"
MIN_ALWAYS=31
MIN_ON_DEMAND=2

# shellcheck source=tests/lib/boot-std-link-contract.sh
. tests/lib/boot-std-link-contract.sh

echo "=== BOOT-014: std link contract manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNTIME" "$MAKEFILE" "$JSON_X" "$ASYNC_X" "$CORE_MEM_X"; do
  if [ ! -f "$f" ]; then
    echo "boot-std-link-contract gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_always) MIN_ALWAYS="$c2" ;;
    min_on_demand) MIN_ON_DEMAND="$c2" ;;
  esac
done < "$MANIFEST"

for kw in asm_ld_append_std_objs asm_ld_append_on_demand_user_objs STD_AND_PANIC_O freestanding_o_needs; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-std-link-contract gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

ALWAYS_N=0
ON_DEMAND_N=0
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|doc|gate|hook_*|c_async_on_demand|c_core_mem_on_demand|freestanding_*) continue ;; esac
  case "$kind" in
    std_always|compiler) ALWAYS_N=$((ALWAYS_N + 1)) ;;
    std_on_demand) ON_DEMAND_N=$((ON_DEMAND_N + 1)) ;;
  esac
done < "$MANIFEST"

if [ "$ALWAYS_N" -lt "$MIN_ALWAYS" ]; then
  echo "boot-std-link-contract gate FAIL: always=${ALWAYS_N} < min ${MIN_ALWAYS}" >&2
  exit 1
fi
if [ "$ON_DEMAND_N" -lt "$MIN_ON_DEMAND" ]; then
  echo "boot-std-link-contract gate FAIL: on_demand=${ON_DEMAND_N} < min ${MIN_ON_DEMAND}" >&2
  exit 1
fi

rt_miss="$(boot_link_contract_verify_runtime "$RUNTIME" "$MANIFEST" || true)"
mk_miss="$(boot_link_contract_verify_makefile "$MAKEFILE" "$MANIFEST" || true)"
if [ "${rt_miss:-0}" -gt 0 ] || [ "${mk_miss:-0}" -gt 0 ]; then
  boot_link_contract_emit_report "fail" 0 0 0 1
  echo "boot-std-link-contract gate FAIL: runtime_miss=${rt_miss:-0} makefile_miss=${mk_miss:-0}" >&2
  exit 1
fi
echo "boot-std-link-contract manifest OK (always=${ALWAYS_N} on_demand=${ON_DEMAND_N})"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

ALWAYS_OK=1
ON_DEMAND_OK=0
SMOKE_OK=0
SKIP=1
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-014: link smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q ../std/json/json.o 2>/dev/null || make -C compiler ../std/json/json.o 2>/dev/null || true
  make -C compiler -q ../std/async/scheduler.o 2>/dev/null || make -C compiler ../std/async/scheduler.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if boot_link_contract_run_smoke "$SHUX_BIN" "$JSON_X" "/tmp/shux_boot_link_json"; then
    SMOKE_OK=1
  else
    boot_link_contract_emit_report "fail" "$ALWAYS_OK" 0 0 0
    exit 1
  fi
  if boot_link_contract_run_smoke "$SHUX_BIN" "$ASYNC_X" "/tmp/shux_boot_link_async"; then
    ON_DEMAND_OK=1
    SMOKE_OK=2
  else
    boot_link_contract_emit_report "fail" "$ALWAYS_OK" 0 1 0
    exit 1
  fi
  if boot_link_contract_run_smoke "$SHUX_BIN" "$CORE_MEM_X" "/tmp/shux_boot_link_core_mem"; then
    ON_DEMAND_OK=2
    SMOKE_OK=3
  else
    boot_link_contract_emit_report "fail" "$ALWAYS_OK" 1 2 0
    exit 1
  fi
  SKIP=0
else
  echo "boot-std-link-contract gate SKIP smoke (no native shux-c)" >&2
fi

boot_link_contract_emit_report "ok" "$ALWAYS_OK" "$ON_DEMAND_OK" "$SMOKE_OK" "$SKIP"
echo "boot-std-link-contract gate OK"
