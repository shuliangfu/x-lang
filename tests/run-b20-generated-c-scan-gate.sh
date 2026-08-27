#!/usr/bin/env bash
# B-20 v1: generated_c_needs_* on-demand scan must not use fopen
# (read_file/POSIX). Soft XLANG_B20_GENERATED_C_SCAN_FAIL retired (hard die).
#
# Fake-authority honesty: monofile retired → live = labi_freestanding_list.
# wave honesty (2026-08-24 #6 / 2026-08-27): seeds/runtime.from_x.c retired
# wave321; authority = link_abi_generated_c_contains_any_substr +
# link_abi_generated_c_needs_* / xlang_generated_c_needs_async_scheduler in
# labi_freestanding_list.from_x.c (via runtime_read_file_malloc; refuse
# monofile resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

RT="${XLANG_B20_RT:-compiler/seeds/labi_freestanding_list.from_x.c}"
HELPER="${XLANG_B20_HELPER:-link_abi_generated_c_contains_any_substr}"
PREFIX="xlang: [XLANG_B20]"

die() {
  echo "b20-generated-c-scan-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail scan=${SCAN_OK:-0} linkabi=${LINKABI_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

SCAN_OK=0
LINKABI_OK=0
SKIP=1

echo "=== B-20: generated_c_needs_* scan (labi_freestanding; monofile retired) ==="

# wave321: monofile retired — refuse resurrect (was soft-SKIP fake green).
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (needs_* live = labi_freestanding_list)"
fi

[ -f "$RT" ] || die "missing live seed $RT"
grep -qF "$HELPER" "$RT" || die "missing $HELPER helper in $RT"

# Six on-demand scanners (async uses xlang_generated_c_needs_* name) must not fopen.
scan_one() {
  local fn="$1"
  local pat="$2"
  local block
  block=$(awk "/^int ${pat}\\(/,/^}/" "$RT" | head -40)
  [ -n "$block" ] || die "missing body for ${fn} (${pat})"
  if echo "$block" | grep -q 'fopen'; then
    die "generated_c_needs_${fn} still uses fopen"
  fi
  if echo "$block" | grep -qE 'runtime_read_file_malloc|link_abi_generated_c_contains_any_substr'; then
    echo "b20 OK ${fn}: read_file/substr path"
  else
    echo "b20 OK ${fn}: no fopen (stub/orch)"
  fi
}

scan_one async_scheduler xlang_generated_c_needs_async_scheduler
scan_one core_builtin link_abi_generated_c_needs_core_builtin
scan_one core_mem link_abi_generated_c_needs_core_mem
scan_one db_kv link_abi_generated_c_needs_db_kv
scan_one db_arrow link_abi_generated_c_needs_db_arrow
scan_one core_slice link_abi_generated_c_needs_core_slice
SCAN_OK=1

# Live link ABI object is the product compile face (runtime.o monofile era retired).
# G.7: tests hub xlang_compiler_make；禁裸 make -C，MF phys-del.
# PLATFORM: SHARED — hub routes to ensure_host_cc_seed_o try-heat.
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if ! xlang_compiler_make src/runtime_link_abi.o 2>/tmp/b20_link_abi_o.log; then
  die "ensure src/runtime_link_abi.o (xlang_compiler_make)"
fi
LINKABI_OK=1
SKIP=0

echo "b20-generated-c-scan-gate OK (labi_freestanding needs_* via read_file, no fopen)"
echo "${PREFIX} status=ok scan=${SCAN_OK} linkabi=${LINKABI_OK} skip=${SKIP} host=$(ci_host_summary)"
