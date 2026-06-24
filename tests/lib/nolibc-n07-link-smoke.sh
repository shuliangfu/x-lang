#!/usr/bin/env bash
# nolibc-n07-link-smoke.sh — NL-07 v3：bootstrap nostdlib 最小链入烟测（Linux x86_64）。
#
# 用法（source 后调用）：
#   . tests/lib/nolibc-n07-link-smoke.sh
#   nolibc_n07_run_bootstrap_link_smoke || exit 1
#
# 环境：
#   SHUX_NOLIBC_N07_LINK_SMOKE_WITH_PANIC=1 — 额外链入 runtime_panic.o

# 在 Linux x86_64 上编译并链入 crt0 + freestanding_io + bootstrap 桩 + smoke main_entry。
nolibc_n07_run_bootstrap_link_smoke() {
  local cc="${CC:-cc}"
  local compiler_dir="${1:-compiler}"
  local smoke_c="${2:-tests/fixtures/nolibc-n07-bootstrap-smoke.c}"
  local out_bin="${3:-/tmp/shux_n07_bootstrap_smoke}"
  local build_dir
  local rc=0
  local with_panic="${SHUX_NOLIBC_N07_LINK_SMOKE_WITH_PANIC:-1}"

  if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
    echo "nolibc-n07-link-smoke: SKIP (need Linux x86_64)" >&2
    return 0
  fi

  build_dir="$(mktemp -d /tmp/shux_n07_smoke.XXXXXX)"
  # shellcheck disable=SC2064
  trap "rm -rf '$build_dir'" RETURN

  # 强制在本机架构重编，避免 macOS 宿主 .o 混入 Docker/Linux 链。
  rm -f \
    "$compiler_dir/src/asm/bootstrap_nostdlib_stubs.o" \
    "$compiler_dir/src/asm/freestanding_io_x86_64.o" \
    "$compiler_dir/src/asm/crt0_x86_64.o" \
    "$compiler_dir/runtime_panic.o" 2>/dev/null || true

  if ! make -C "$compiler_dir" \
    src/asm/crt0_x86_64.o \
    src/asm/freestanding_io_x86_64.o \
    src/asm/bootstrap_nostdlib_stubs.o \
    runtime_panic.o >/dev/null 2>&1; then
    echo "nolibc-n07-link-smoke FAIL: make bootstrap objects" >&2
    return 1
  fi

  if [ ! -f "$smoke_c" ]; then
    echo "nolibc-n07-link-smoke FAIL: missing $smoke_c" >&2
    return 1
  fi

  if ! "$cc" -c -o "$build_dir/smoke.o" "$smoke_c" 2>"$build_dir/compile.err"; then
    echo "nolibc-n07-link-smoke FAIL: compile smoke main" >&2
    tail -5 "$build_dir/compile.err" 2>/dev/null || true
    return 1
  fi

  local link_objs=(
    "$compiler_dir/src/asm/crt0_x86_64.o"
    "$compiler_dir/src/asm/freestanding_io_x86_64.o"
    "$compiler_dir/src/asm/bootstrap_nostdlib_stubs.o"
    "$build_dir/smoke.o"
  )
  if [ "$with_panic" = "1" ]; then
    link_objs+=("$compiler_dir/runtime_panic.o")
  fi

  rm -f "$out_bin" 2>/dev/null || true
  if ! "$cc" -nostdlib -static -Wl,--gc-sections -o "$out_bin" "${link_objs[@]}" 2>"$build_dir/link.err"; then
    echo "nolibc-n07-link-smoke FAIL: nostdlib link" >&2
    head -20 "$build_dir/link.err" 2>/dev/null || true
    return 1
  fi

  if ! file "$out_bin" 2>/dev/null | grep -q 'statically linked'; then
    echo "nolibc-n07-link-smoke FAIL: not statically linked ($out_bin)" >&2
    file "$out_bin" 2>/dev/null || true
    return 1
  fi

  if readelf -d "$out_bin" 2>/dev/null | grep -q NEEDED; then
    echo "nolibc-n07-link-smoke FAIL: dynamic NEEDED present" >&2
    readelf -d "$out_bin" 2>/dev/null | grep NEEDED || true
    return 1
  fi

  "$out_bin" || rc=$?
  rm -f "$out_bin" 2>/dev/null || true
  if [ "$rc" -ne 0 ]; then
    echo "nolibc-n07-link-smoke FAIL: exit $rc (expected 0)" >&2
    return 1
  fi

  echo "nolibc-n07-link-smoke OK (crt0 + stubs + smoke main_entry, statically linked)"
  return 0
}
