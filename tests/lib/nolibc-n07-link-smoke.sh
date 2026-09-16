#!/usr/bin/env bash
# nolibc-n07-link-smoke.sh — NL-07 v3: bootstrap nostdlib minimal link smoke
# (Linux x86_64).
#
# Usage (source then call):
#   . tests/lib/nolibc-n07-link-smoke.sh
#   nolibc_n07_run_bootstrap_link_smoke || exit 1
#
# Env:
#   XLANG_NOLIBC_N07_LINK_SMOKE_WITH_PANIC=1 — also link runtime_panic.o (default)
#
# Honesty (2026-08-27): do NOT rely on xlang_compiler_make alone for
# bootstrap_nostdlib_stubs.o — post-MG try-heat can return 0 without creating
# the leaf (portable false-green under soft die). Live authority =
# bootstrap_nostdlib_shared.sh ensure_* + verify files exist.
# PLATFORM: LINUX freestanding smoke.

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"

nolibc_n07_run_bootstrap_link_smoke() {
  local cc="${CC:-cc}"
  local compiler_dir="${1:-compiler}"
  local smoke_c="${2:-tests/fixtures/nolibc-n07-bootstrap-smoke.c}"
  local out_bin="${3:-/tmp/xlang_n07_bootstrap_smoke}"
  local build_dir
  local rc=0
  local with_panic="${XLANG_NOLIBC_N07_LINK_SMOKE_WITH_PANIC:-1}"
  local shared="scripts/bootstrap_nostdlib_shared.sh"

  if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
    echo "nolibc-n07-link-smoke: SKIP (need Linux x86_64)" >&2
    return 0
  fi

  build_dir="$(mktemp -d /tmp/xlang_n07_smoke.XXXXXX)"
  # shellcheck disable=SC2064
  trap "rm -rf '$build_dir'" RETURN

  # Force rebuild on this host arch (avoid macOS .o mixed into Linux link).
  # PLATFORM: LINUX.
  rm -f \
    "$compiler_dir/src/asm/bootstrap_nostdlib_stubs.o" \
    "$compiler_dir/src/asm/freestanding_io_x86_64.o" \
    "$compiler_dir/src/asm/crt0_x86_64.o" \
    "$compiler_dir/runtime_panic.o" 2>/dev/null || true

  # G.7: stubs + freestanding_io live in bootstrap_nostdlib_shared.sh.
  if [ ! -f "$compiler_dir/$shared" ]; then
    echo "nolibc-n07-link-smoke FAIL: missing $compiler_dir/$shared" >&2
    return 1
  fi
  (
    cd "$compiler_dir" || exit 1
    # shellcheck disable=SC1090
    . "$shared"
    ensure_freestanding_io_x86_64_obj
    ensure_bootstrap_nostdlib_stubs_obj
  ) || {
    echo "nolibc-n07-link-smoke FAIL: shared ensure freestanding_io/stubs" >&2
    return 1
  }

  # crt0 + runtime_panic via 0-make hub; verify leaves exist (no false OK).
  if ! XLANG_COMPILER_DIR="$compiler_dir" xlang_compiler_make \
    src/asm/crt0_x86_64.o runtime_panic.o; then
    echo "nolibc-n07-link-smoke FAIL: xlang_compiler_make crt0/runtime_panic" >&2
    return 1
  fi

  for f in \
    "$compiler_dir/src/asm/crt0_x86_64.o" \
    "$compiler_dir/src/asm/freestanding_io_x86_64.o" \
    "$compiler_dir/src/asm/bootstrap_nostdlib_stubs.o" \
    "$compiler_dir/runtime_panic.o"; do
    if [ ! -f "$f" ]; then
      echo "nolibc-n07-link-smoke FAIL: missing object after ensure: $f" >&2
      return 1
    fi
  done

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
