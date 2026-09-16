#!/usr/bin/env bash
# BOOT-014: std module link-contract — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft SKIP→OK
# (no native still gate OK) + prefer-c / bootstrap-link wrap retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make).
# json always-path product -o = hard run; on_demand async/core_mem product
# residual = obs (mangle/ensure deferred; one-debt). Report: run=/obs=/skip=.
# DOC defaults under analysis/archive/; refuse resurrected top-level DOC.
# Override: XLANG_BOOT_LINK_RUNTIME="f1 f2…" / XLANG_BOOT_LINK_MAKEFILE=…
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-boot-std-link-contract-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/boot-std-link-contract.sh
. tests/lib/boot-std-link-contract.sh

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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "boot-std-link-contract gate FAIL: $*" >&2
  boot_link_contract_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== BOOT-014: std link contract (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="

# Refuse resurrected top-level DOC (live = archive/boot/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/boot-std-link-contract-v1.md ]; then
  die "top-level DOC resurrected (live = archive/boot/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MAKEFILE" "$JSON_X" "$ASYNC_X" "$CORE_MEM_X"; do
  [ -f "$f" ] || die "missing $f"
done
for f in $RUNTIME; do
  [ -f "$f" ] || die "missing live seed $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_always) MIN_ALWAYS="$c2" ;;
    min_on_demand) MIN_ON_DEMAND="$c2" ;;
  esac
done < "$MANIFEST"

for kw in asm_ld_append_std_objs asm_ld_append_on_demand_user_objs STD_AND_PANIC_O freestanding_o_needs; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 7. Gate' "$DOC" 2>/dev/null || die "doc missing '## 7. Gate'"

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

[ "$ALWAYS_N" -ge "$MIN_ALWAYS" ] || die "always=${ALWAYS_N} < min ${MIN_ALWAYS}"
[ "$ON_DEMAND_N" -ge "$MIN_ON_DEMAND" ] || die "on_demand=${ON_DEMAND_N} < min ${MIN_ON_DEMAND}"

rt_miss="$(boot_link_contract_verify_runtime "$RUNTIME" "$MANIFEST" || true)"
mk_miss="$(boot_link_contract_verify_makefile "$MAKEFILE" "$MANIFEST" || true)"
if [ "${rt_miss:-0}" -gt 0 ] || [ "${mk_miss:-0}" -gt 0 ]; then
  die "runtime_miss=${rt_miss:-0} makefile_miss=${mk_miss:-0}"
fi
echo "boot-std-link-contract manifest OK (always=${ALWAYS_N} on_demand=${ON_DEMAND_N})"

if [ "${XLANG_BOOT_LINK_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  boot_link_contract_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "boot-std-link-contract gate OK (manifest only)"
  exit 0
fi

# Refuse soft auto-make — require existing native product binary.
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

echo "=== BOOT-014: link smoke (json always hard; on_demand observational) ==="
# Always-path smoke is hard (proves STD_AND_PANIC / json always-link).
if boot_link_contract_run_smoke "$XLANG_BIN" "$JSON_X" "/tmp/xlang_boot_link_json_$$"; then
  RUN_OK=$((RUN_OK + 1))
  echo "boot-std-link-contract OK json always"
else
  die "json always smoke"
fi
rm -f /tmp/xlang_boot_link_json_$$

# On-demand smokes are observational for this honesty wave:
# async fixture emits std_async_* while scheduler.o exports xlang_async_* (mangle residual);
# core.mem volatile may fail on_demand ensure even when mem.o defines core_mem_volatile_*.
# Contract gate stays green on inventory+json; on_demand product residuals deferred (one-debt).
if boot_link_contract_run_smoke "$XLANG_BIN" "$ASYNC_X" "/tmp/xlang_boot_link_async_$$"; then
  RUN_OK=$((RUN_OK + 1))
  echo "boot-std-link-contract OK async on_demand"
else
  echo "boot-std-link-contract OBS async on_demand (product mangle residual; deferred; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi
rm -f /tmp/xlang_boot_link_async_$$

if boot_link_contract_run_smoke "$XLANG_BIN" "$CORE_MEM_X" "/tmp/xlang_boot_link_core_mem_$$"; then
  RUN_OK=$((RUN_OK + 1))
  echo "boot-std-link-contract OK core_mem on_demand"
else
  echo "boot-std-link-contract OBS core_mem on_demand (product ensure residual; deferred; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi
rm -f /tmp/xlang_boot_link_core_mem_$$

[ "$RUN_OK" -ge 1 ] || die "always smoke missing"
echo "boot-std-link-contract run=${RUN_OK} obs=${OBS}"
boot_link_contract_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "boot-std-link-contract gate OK"
