#!/bin/sh
# xlang_compile_std_fs_formal.sh — formal std/fs/fs.o for -backend asm product link
#
# Why (root): std.fs is skipped for asm co-emit (pipeline_codegen_dep_skip_asm_user_std_fs).
# Compiling mod.x as the *entry* TU on Linux emits libc name collisions (stat/sendfile/sync)
# and use-before-declare of posix_fadvise. Product user -o (entry = test main + import
# "std.fs") emits a KEEP_C order that host-cc accepts.
#
# Authority: same product sources (std/fs/mod.x + posix via import); vehicle is only a
# compile driver, not a second API surface (G.7).
#
# PLATFORM: LINUX|MACOS (POSIX formal; Windows gold N/A for this path).
#
# Usage: xlang_compile_std_fs_formal.sh <out.o>
# Env: XLANG=compiler binary (default ./xlang_asm → ./xlang → ./xlang-c)
# wave826: FORCE-thin mtime skip when formal_mod ensure dispatches here (not physical delete).
set -e

out_o="$1"
if [ -z "$out_o" ]; then
  echo "usage: xlang_compile_std_fs_formal.sh <out.o>" >&2
  exit 1
fi

# wave826: FORCE-thin mtime for formal_mod fs leaf (G.7 shell owns source freshness).
# Catalog sources: std/fs/mod.x + posix.x (vehicle imports std.fs). PLATFORM: SHARED.
if [ "${FORCE:-0}" != "1" ] && [ -f "$out_o" ]; then
  _fs_stale=0
  for _s in ../std/fs/mod.x ../std/fs/posix.x std/fs/mod.x std/fs/posix.x \
            seeds/runtime_dir_cap.from_x.c include/xlang_dir_cap.h \
            ../compiler/seeds/runtime_dir_cap.from_x.c ../compiler/include/xlang_dir_cap.h; do
    if [ -f "$_s" ] && [ "$_s" -nt "$out_o" ]; then
      _fs_stale=1
      break
    fi
  done
  if [ "$_fs_stale" = "0" ]; then
    # Only skip if at least one real source path exists (avoid skip when tree missing).
    if [ -f ../std/fs/mod.x ] || [ -f std/fs/mod.x ]; then
      echo "xlang_compile_std_fs_formal: skip up-to-date $out_o (formal_mod/fs)" >&2
      exit 0
    fi
  fi
fi

XLANG_BIN="${XLANG:-./xlang_asm}"
[ -x "$XLANG_BIN" ] || XLANG_BIN="./xlang"
[ -x "$XLANG_BIN" ] || XLANG_BIN="./xlang_asm"
[ -x "$XLANG_BIN" ] || XLANG_BIN="./xlang-c"
[ -x "$XLANG_BIN" ] || { echo "xlang_compile_std_fs_formal.sh: no xlang binary" >&2; exit 1; }

# PLATFORM: LINUX — GNU_SOURCE + tolerate emit order of libc decls in KEEP_C.
# -Wno-implicit-function-declaration: posix_fadvise etc. may appear after first use.
CFLAGS="-I.. -I. -Iinclude -Isrc -fPIE -ffunction-sections -fdata-sections"
CFLAGS="$CFLAGS -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function"
CFLAGS="$CFLAGS -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers"
CFLAGS="$CFLAGS -Wno-unused-but-set-variable -Wno-type-limits -Wno-visibility"
CFLAGS="$CFLAGS -Wno-incompatible-pointer-types -Wno-incompatible-pointer-types-discards-qualifiers"
CFLAGS="$CFLAGS -Wno-implicit-function-declaration -Wno-builtin-declaration-mismatch"
case "$(uname -s 2>/dev/null)" in
  Linux) CFLAGS="-D_GNU_SOURCE $CFLAGS" ;;
  # PLATFORM: MACOS — match macho.x LC_BUILD_VERSION minos 11.0.0.
  Darwin) CFLAGS="$CFLAGS -mmacosx-version-min=11.0" ;;
esac

tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t xlangfs)
trap 'rm -rf "$tmp_dir" 2>/dev/null || true' EXIT INT TERM

# Vehicle: entry main + import("std.fs") → same co-emit path as tests/fs/main.x.
# Keep body minimal (match tests/fs/main.x) so typeck/pipeline stays green on mac+Ubuntu.
vehicle="$tmp_dir/fs_vehicle.x"
cat >"$vehicle" <<'EOF'
// Formal fs.o vehicle — not a product API. Compiles import("std.fs") like user -o.
// PLATFORM: SHARED — driver only; symbols come from std/fs/mod.x + posix.
const fs = import("std.fs");

function main(): i32 {
  let h: i32 = fs.invalid();
  return if (h != -1) { 1 } else { 0 }
}
EOF
log="$tmp_dir/xlang.log"
# -o fails at final link sometimes; XLANG_KEEP_C keeps full product C.
XLANG_KEEP_C=1 "$XLANG_BIN" -backend c -L .. -o "$tmp_dir/try.out" "$vehicle" \
  >"$log" 2>&1 || true

kept=$(grep -E 'kept generated C:|keeping generated C:' "$log" 2>/dev/null \
  | sed -n 's/.*generated C: //p' | tail -1)
if [ -z "$kept" ] || [ ! -f "$kept" ] || [ ! -s "$kept" ]; then
  echo "xlang_compile_std_fs_formal.sh: no KEEP_C from vehicle (see $log)" >&2
  tail -30 "$log" >&2 || true
  exit 1
fi

gen_c="$tmp_dir/fs_formal.c"
cp "$kept" "$gen_c"
rm -f "$kept" 2>/dev/null || true

# PLATFORM: LINUX — codegen_is_libc_conflicting_extern_name skips the XLANG
# sendfile redecl (Darwin socket.h 6-arg vs i64*/u8* is a hard conflict).
# Leftover fs_libc_sendfile 4-arg calls still need a prototype; include
# <sys/sendfile.h> (same class as compile_std_module snprintf → stdio.h).
# Darwin 6-arg FFI is unused (fs_libc_sendfile_mac returns -1); socket.h
# already provides sendfile(2) via net Cap. Do not file-wide #define sendfile.
case "$(uname -s 2>/dev/null)" in
  Linux)
    if grep -qE '\bsendfile[[:space:]]*\(' "$gen_c" 2>/dev/null \
       && ! grep -qE '#include[[:space:]]*<sys/sendfile\.h>' "$gen_c" 2>/dev/null; then
      _sf_inc=$(grep -n '^#include' "$gen_c" 2>/dev/null | tail -1 | cut -d: -f1)
      [ -n "$_sf_inc" ] || _sf_inc=1
      {
        head -n "$_sf_inc" "$gen_c"
        echo '/* PLATFORM: LINUX — libc sendfile after dropping conflicting XLANG extern */'
        echo '#include <sys/sendfile.h>'
        tail -n +"$((_sf_inc + 1))" "$gen_c"
      } >"$tmp_dir/gen_sendfile.c" && mv "$tmp_dir/gen_sendfile.c" "$gen_c"
    fi
    ;;
esac

raw_o="$tmp_dir/fs_formal_raw.o"
# shellcheck disable=SC2086
if ! cc -c $CFLAGS "$gen_c" -o "$raw_o" 2>"$tmp_dir/cc.err"; then
  echo "xlang_compile_std_fs_formal.sh: cc -c failed for KEEP_C" >&2
  tail -40 "$tmp_dir/cc.err" >&2 || true
  exit 1
fi

# Cap residual 9.1.10: merge xlang_dir_* into fs.o so KEEP_C U opendir faces
# resolve without libc (G.7 single Cap body in xlang_dir_cap.h).
# PLATFORM: SHARED face; LINUX Cap / POSIX fallback inside header.
_dir_cap_c="seeds/runtime_dir_cap.from_x.c"
if [ ! -f "$_dir_cap_c" ]; then
  _dir_cap_c="../compiler/seeds/runtime_dir_cap.from_x.c"
fi
if [ -f "$_dir_cap_c" ]; then
  _dir_cap_o="$tmp_dir/runtime_dir_cap.o"
  # shellcheck disable=SC2086
  if ! cc -c $CFLAGS "$_dir_cap_c" -o "$_dir_cap_o" 2>"$tmp_dir/dir_cap.err"; then
    echo "xlang_compile_std_fs_formal.sh: cc -c dir Cap failed" >&2
    tail -40 "$tmp_dir/dir_cap.err" >&2 || true
    exit 1
  fi
  _merged="$tmp_dir/fs_formal_merged.o"
  if ! ld -r -o "$_merged" "$raw_o" "$_dir_cap_o" 2>"$tmp_dir/dir_ld.err"; then
    echo "xlang_compile_std_fs_formal.sh: ld -r dir Cap failed" >&2
    tail -20 "$tmp_dir/dir_ld.err" >&2 || true
    exit 1
  fi
  raw_o="$_merged"
fi

# Drop vehicle main + foreign co-emits so fs.o is a pure library face.
# KEEP_C vehicle co-emits core_result_* / std_io_* / std_error_* / std_context_* as
# global T; product companions push error.o + io stubs → multi-def if left global.
# G.7 complete authority ≡ formal_mod leaf export (std_fs_* only).
# PLATFORM: LINUX|ELF — objcopy strip main + localize foreign.
# PLATFORM: MACOS|DARWIN — no objcopy; ld -r -exported_symbols_list keep std_fs_*.
if command -v objcopy >/dev/null 2>&1; then
  cp "$raw_o" "$out_o"
  objcopy --strip-symbol=main "$out_o" 2>/dev/null || true
  nm "$out_o" 2>/dev/null | awk '/ [TDB] / { print $3 }' | while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    bare="$sym"
    case "$sym" in
      _*) bare="${sym#_}" ;;
    esac
    case "$bare" in
      std_fs_*) continue ;;
      core_*|std_*)
        objcopy --localize-symbol="$sym" "$out_o" 2>/dev/null || true
        ;;
      main)
        objcopy --strip-symbol="$sym" "$out_o" 2>/dev/null || true
        ;;
    esac
  done
else
  # PLATFORM: MACOS — export only std_fs_* product API (drops main + foreign T).
  _exp_list="$tmp_dir/fs_export_std_fs.txt"
  : >"$_exp_list"
  nm "$raw_o" 2>/dev/null | awk '/ [TDB] / { print $3 }' | while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    bare="$sym"
    case "$sym" in
      _*) bare="${sym#_}" ;;
    esac
    case "$bare" in
      std_fs_*)
        printf '%s\n' "$sym" >>"$_exp_list"
        ;;
    esac
  done
  if [ -s "$_exp_list" ] && ld -r -exported_symbols_list "$_exp_list" -o "$out_o" "$raw_o" 2>"$tmp_dir/fs_exp.err"; then
    :
  else
    echo "xlang_compile_std_fs_formal.sh: Mac export filter failed" >&2
    head -8 "$tmp_dir/fs_exp.err" 2>/dev/null >&2 || true
    cp "$raw_o" "$out_o"
  fi
fi

if ! nm "$out_o" 2>/dev/null | grep -q 'std_fs_invalid'; then
  echo "xlang_compile_std_fs_formal.sh: missing std_fs_invalid in $out_o" >&2
  exit 1
fi

echo "xlang_compile_std_fs_formal.sh: OK -> $out_o"
