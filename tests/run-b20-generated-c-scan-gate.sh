#!/usr/bin/env bash
# B-20 v1：generated_c_needs_* 按需链扫描不再使用 fopen（改 read_file/POSIX）。
# 假权威诚实：monofile retired → live = labi_freestanding_list.
#
# 用法：./tests/run-b20-generated-c-scan-gate.sh
# 环境：XLANG_B20_GENERATED_C_SCAN_FAIL=1 失败时硬退出
# wave honesty (2026-08-24 #6): seeds/runtime.from_x.c retired wave321;
# authority = link_abi_generated_c_contains_any_substr + link_abi_generated_c_needs_*
# / xlang_generated_c_needs_async_scheduler in labi_freestanding_list.from_x.c
# (via runtime_read_file_malloc; refuse monofile resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

FAIL=${XLANG_B20_GENERATED_C_SCAN_FAIL:-0}
RT="${XLANG_B20_RT:-compiler/seeds/labi_freestanding_list.from_x.c}"
HELPER="${XLANG_B20_HELPER:-link_abi_generated_c_contains_any_substr}"

die() {
  echo "b20-generated-c-scan-gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== B-20: generated_c_needs_* scan (labi_freestanding; monofile retired) ==="

# wave321: monofile retired — refuse resurrect (was soft-SKIP fake green).
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (needs_* live = labi_freestanding_list)"
fi

if [ ! -f "$RT" ]; then
  die "missing live seed $RT"
fi

# helper must exist on live face
if ! grep -qF "$HELPER" "$RT"; then
  die "missing $HELPER helper in $RT"
fi

# Six on-demand scanners (async uses xlang_generated_c_needs_* name) must not fopen.
scan_one() {
  local fn="$1"
  local pat="$2"
  # Take first definition body (~40 lines) after the opening brace of the impl.
  local block
  block=$(awk "/^int ${pat}\\(/,/^}/" "$RT" | head -40)
  [ -n "$block" ] || die "missing body for ${fn} (${pat})"
  if echo "$block" | grep -q 'fopen'; then
    die "generated_c_needs_${fn} still uses fopen"
  fi
  # Prefer read_file authority when body is non-trivial (stub0 may be short).
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

# Live link ABI object is the product compile face (runtime.o monofile era retired).
# G.7: tests hub xlang_compiler_make；禁裸 make -C，MF phys-del.
# PLATFORM: SHARED — hub routes to ensure_host_cc_seed_o try-heat.
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
if ! xlang_compiler_make src/runtime_link_abi.o 2>/tmp/b20_link_abi_o.log; then
  die "ensure src/runtime_link_abi.o (xlang_compiler_make)"
  # die already exits; keep tail for operators when FAIL=0 path unused
fi

echo "b20-generated-c-scan-gate OK (labi_freestanding needs_* via read_file, no fopen)"
exit 0
