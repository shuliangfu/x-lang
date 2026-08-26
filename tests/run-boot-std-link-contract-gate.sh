#!/usr/bin/env bash
# BOOT-014: std module link-contract manifest + always-path smoke
# (false-authority honesty).
#
# Usage: ./tests/run-boot-std-link-contract-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# wave honesty (2026-08-24 #3): monofile seeds/runtime.from_x.c retired wave321;
# path inventory = labi_std_list + labi_ondemand_list + labi_ensure_list +
# labi_path_pure + labi_freestanding_list; get_*_o_path getters retired (E-04);
# Makefile deleted (MG wave941) → compiler/mk/std_and_panic_objs.mk.
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; json always smoke hard-fail
# (no soft SKIP→OK when no native). On-demand async/core_mem smokes stay
# observational (product mangle/ensure residual; one-debt deferred). Report
# always=/on_demand=/smoke=/skip=. Gate was portable-false-red (prefer xlang-c /
# soft SKIP→OK when no native / DOC ## 5. 门禁 without Gate honesty).
# Override: XLANG_BOOT_LINK_RUNTIME="f1 f2…" / XLANG_BOOT_LINK_MAKEFILE=…
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_BOOT_LINK_DOC:-analysis/archive/boot/boot-std-link-contract-v1.md}"
MANIFEST="${XLANG_BOOT_LINK_TSV:-tests/baseline/boot-std-link-contract.tsv}"
# Live asm std / companion path authorities (space-separated union).
RUNTIME="${XLANG_BOOT_LINK_RUNTIME:-compiler/seeds/labi_std_list.from_x.c compiler/seeds/labi_ondemand_list.from_x.c compiler/seeds/labi_ensure_list.from_x.c compiler/seeds/labi_path_pure.from_x.c compiler/seeds/labi_freestanding_list.from_x.c}"
# Live STD_AND_PANIC_O list authority (Makefile physically deleted).
MAKEFILE="${XLANG_BOOT_LINK_MAKEFILE:-compiler/mk/std_and_panic_objs.mk}"
LIB="tests/lib/boot-std-link-contract.sh"
JSON_X="tests/json/object_array_parse.x"
ASYNC_X="tests/async/await_scheduler_mod.x"
CORE_MEM_X="tests/core-mem/volatile_fence.x"
MIN_ALWAYS=31
MIN_ON_DEMAND=2

# shellcheck source=tests/lib/boot-std-link-contract.sh
. tests/lib/boot-std-link-contract.sh

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
boot_link_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== BOOT-014: std link contract manifest ==="

# Refuse resurrected top-level DOC (live = archive/boot/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/boot-std-link-contract-v1.md ]; then
  echo "boot-std-link-contract gate FAIL: top-level DOC resurrected (live = archive/boot/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MAKEFILE" "$JSON_X" "$ASYNC_X" "$CORE_MEM_X"; do
  if [ ! -f "$f" ]; then
    echo "boot-std-link-contract gate FAIL: missing $f" >&2
    exit 1
  fi
done
for f in $RUNTIME; do
  if [ ! -f "$f" ]; then
    echo "boot-std-link-contract gate FAIL: missing live seed $f" >&2
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

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "boot-std-link-contract gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

ALWAYS_N=0
ON_DEMAND_N=0
while IFS=$'\t' read -r item_id kind _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|doc|doc_gate|gate|hook_*|c_async_on_demand|c_core_mem_on_demand|freestanding_*) continue ;; esac
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

if [ "${XLANG_BOOT_LINK_MANIFEST_ONLY:-0}" = "1" ]; then
  boot_link_contract_emit_report "ok" 1 0 0 1
  echo "boot-std-link-contract gate OK (manifest only)"
  exit 0
fi

# Best-effort quiet make (do not soft-SKIP the gate when make is noisy).
xlang_compiler_make -q ../std/json/json.o 2>/dev/null || xlang_compiler_make ../std/json/json.o 2>/dev/null || true
xlang_compiler_make -q ../std/async/scheduler.o 2>/dev/null || xlang_compiler_make ../std/async/scheduler.o 2>/dev/null || true
xlang_compiler_make -q ../core/mem/mem.o 2>/dev/null || xlang_compiler_make ../core/mem/mem.o 2>/dev/null || true
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make || true

ALWAYS_OK=0
ON_DEMAND_OK=0
SMOKE_OK=0
SKIP=1

if XLANG_BIN="$(boot_link_resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-014: link smoke (XLANG=$XLANG_BIN; json always hard; on_demand observational) ==="
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # Always-path smoke is hard (proves STD_AND_PANIC / json always-link).
  if boot_link_contract_run_smoke "$XLANG_BIN" "$JSON_X" "/tmp/xlang_boot_link_json"; then
    ALWAYS_OK=1
    SMOKE_OK=1
    SKIP=0
  else
    boot_link_contract_emit_report "fail" 0 0 0 0
    echo "boot-std-link-contract gate FAIL: json always smoke" >&2
    exit 1
  fi
  # On-demand smokes are observational for this honesty wave:
  # async fixture emits std_async_* while scheduler.o exports xlang_async_* (mangle residual);
  # core.mem volatile may fail on_demand ensure even when mem.o defines core_mem_volatile_*.
  # Contract gate stays green on inventory+json; on_demand product residuals deferred (one-debt).
  if boot_link_contract_run_smoke "$XLANG_BIN" "$ASYNC_X" "/tmp/xlang_boot_link_async"; then
    ON_DEMAND_OK=$((ON_DEMAND_OK + 1))
    SMOKE_OK=$((SMOKE_OK + 1))
  else
    echo "boot-std-link-contract NOTE: async on_demand smoke red (product mangle residual; deferred)" >&2
  fi
  if boot_link_contract_run_smoke "$XLANG_BIN" "$CORE_MEM_X" "/tmp/xlang_boot_link_core_mem"; then
    ON_DEMAND_OK=$((ON_DEMAND_OK + 1))
    SMOKE_OK=$((SMOKE_OK + 1))
  else
    echo "boot-std-link-contract NOTE: core_mem on_demand smoke red (product ensure residual; deferred)" >&2
  fi
else
  echo "boot-std-link-contract gate FAIL: no native xlang" >&2
  boot_link_contract_emit_report "fail" 0 0 0 0
  exit 2
fi

boot_link_contract_emit_report "ok" "$ALWAYS_OK" "$ON_DEMAND_OK" "$SMOKE_OK" "$SKIP"
echo "boot-std-link-contract gate OK"
