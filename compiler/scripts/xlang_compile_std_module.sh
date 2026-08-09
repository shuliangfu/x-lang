#!/bin/sh
# xlang_compile_std_module.sh — formal std/core module .o via -x -E + cc -c (F 闭合)
#
# 【Why 根源】G-02a 删除 C 前端后，-E-extern 模式不可用（runtime.c 在
# XLANG_NO_C_FRONTEND 定义时直接报 BLD001）。-x -E 走 .x pipeline 路径，
# 生成等价的瘦 C TU（含 extern 前向声明），功能等价于旧 -E-extern。
#
# 替代 *_import_alias.c C 桩。两种模块架构：
#   1. import binding 模式（heap/map/set）：mod.x 用 `const impl = import("std.module.libc")`，
#      impl .x 用路径提取前缀（std_heap_libc_*），不传 -lib-name。
#   2. extern function 模式（tar/csv/json/...）：mod.x 用 `extern function foo_c()`，
#      impl .x 用 -lib-name "" 产出裸符号（foo_c），匹配 mod.x 的 extern 调用。
#      需传 --bare-impl 参数启用此模式。
# cc -c 编译为 .o，多文件时用 ld -r 合并。
#
# Usage (cwd = compiler/):
#   xlang_compile_std_module.sh [--bare-impl] <out.o> <x1> [x2] ...   # legacy explicit
#   xlang_compile_std_module.sh ensure <out.o>                        # wave812 catalog
#   xlang_compile_std_module.sh auto <out.o>                          # alias of ensure
#   xlang_compile_std_module.sh list                                  # catalog keys
#   xlang_compile_std_module.sh --check                               # catalog + thin greps
#
# wave812 (G.7 有则补全): formal_mod product table lives here — bare flag + sources
# + fs_formal dispatch. Makefile thin-calls `ensure $@` only.
# wave826 (G.7 有则补全): FORCE dep-thin — Makefile prereqs are FORCE + script only;
# shell owns catalog source mtime (skip up-to-date). NOT physical delete; thin edges
# + B2 try-heat + mk lists still form std_core_product_make_graph residual.
# wave894 (G.7 有则补全): make-graph inventory → mk/formal_mod_product_objs.mk;
# Makefile multi-target $(FORMAL_MOD_PRODUCT_OBJS) FORCE thin ensure only.
#
# 约定：mod.x 编译为带前缀符号（std_<module>_*）。
#   --bare-impl：非 mod.x 文件用 -lib-name ""（裸符号）；否则用路径提取前缀。
# 环境：XLANG=编译器路径（默认 ./xlang → ./xlang_asm → ./xlang-c）
# PLATFORM: SHARED — catalog + compile body; host-cc CFLAGS may add LINUX -D_GNU_SOURCE.
set -e

# ---------------------------------------------------------------------------
# wave812: formal_mod shell-primary catalog (G.7 有则补全; not physical delete)
# Spec line: kind|bare|src1[|src2...]
#   kind = mod (this script body) | fs_formal (xlang_compile_std_fs_formal.sh)
#   bare = 0|1  (--bare-impl for non-mod.x / extern-function modules)
# Keys accept: ../std/.../x.o | std/.../x.o | *std/.../x.o
# ---------------------------------------------------------------------------

formal_mod_key_for_out() {
  _o="$1"
  case "$_o" in
    ../std/string/string.o|std/string/string.o|*std/string/string.o) printf '%s' "std/string/string.o" ;;
    ../std/heap/heap.o|std/heap/heap.o|*std/heap/heap.o) printf '%s' "std/heap/heap.o" ;;
    ../std/heap/page_mmap.o|std/heap/page_mmap.o|*std/heap/page_mmap.o) printf '%s' "std/heap/page_mmap.o" ;;
    ../std/sys/sys.o|std/sys/sys.o|*std/sys/sys.o) printf '%s' "std/sys/sys.o" ;;
    ../std/sys/linux.o|std/sys/linux.o|*std/sys/linux.o) printf '%s' "std/sys/linux.o" ;;
    ../core/mem/mem.o|core/mem/mem.o|*core/mem/mem.o) printf '%s' "core/mem/mem.o" ;;
    ../core/types/types.o|core/types/types.o|*core/types/types.o) printf '%s' "core/types/types.o" ;;
    ../core/option/option.o|core/option/option.o|*core/option/option.o) printf '%s' "core/option/option.o" ;;
    ../core/result/result.o|core/result/result.o|*core/result/result.o) printf '%s' "core/result/result.o" ;;
    ../core/debug/debug.o|core/debug/debug.o|*core/debug/debug.o) printf '%s' "core/debug/debug.o" ;;
    ../core/slice/mod.o|core/slice/mod.o|*core/slice/mod.o) printf '%s' "core/slice/mod.o" ;;
    ../std/map/map.o|std/map/map.o|*std/map/map.o) printf '%s' "std/map/map.o" ;;
    ../std/set/set.o|std/set/set.o|*std/set/set.o) printf '%s' "std/set/set.o" ;;
    ../std/vec/vec.o|std/vec/vec.o|*std/vec/vec.o) printf '%s' "std/vec/vec.o" ;;
    ../std/thread/thread.o|std/thread/thread.o|*std/thread/thread.o) printf '%s' "std/thread/thread.o" ;;
    ../std/time/time.o|std/time/time.o|*std/time/time.o) printf '%s' "std/time/time.o" ;;
    ../std/random/random.o|std/random/random.o|*std/random/random.o) printf '%s' "std/random/random.o" ;;
    ../std/env/env.o|std/env/env.o|*std/env/env.o) printf '%s' "std/env/env.o" ;;
    ../std/fs/fs.o|std/fs/fs.o|*std/fs/fs.o) printf '%s' "std/fs/fs.o" ;;
    ../std/sync/sync.o|std/sync/sync.o|*std/sync/sync.o) printf '%s' "std/sync/sync.o" ;;
    ../std/queue/queue.o|std/queue/queue.o|*std/queue/queue.o) printf '%s' "std/queue/queue.o" ;;
    ../std/encoding/encoding.o|std/encoding/encoding.o|*std/encoding/encoding.o) printf '%s' "std/encoding/encoding.o" ;;
    ../std/base64/base64.o|std/base64/base64.o|*std/base64/base64.o) printf '%s' "std/base64/base64.o" ;;
    ../std/crypto/crypto.o|std/crypto/crypto.o|*std/crypto/crypto.o) printf '%s' "std/crypto/crypto.o" ;;
    ../std/log/log.o|std/log/log.o|*std/log/log.o) printf '%s' "std/log/log.o" ;;
    ../std/test/test.o|std/test/test.o|*std/test/test.o) printf '%s' "std/test/test.o" ;;
    ../std/atomic/atomic.o|std/atomic/atomic.o|*std/atomic/atomic.o) printf '%s' "std/atomic/atomic.o" ;;
    ../std/hash/hash.o|std/hash/hash.o|*std/hash/hash.o) printf '%s' "std/hash/hash.o" ;;
    ../std/math/math.o|std/math/math.o|*std/math/math.o) printf '%s' "std/math/math.o" ;;
    ../std/sort/sort.o|std/sort/sort.o|*std/sort/sort.o) printf '%s' "std/sort/sort.o" ;;
    ../std/ffi/ffi.o|std/ffi/ffi.o|*std/ffi/ffi.o) printf '%s' "std/ffi/ffi.o" ;;
    ../std/context/context.o|std/context/context.o|*std/context/context.o) printf '%s' "std/context/context.o" ;;
    ../std/error/error.o|std/error/error.o|*std/error/error.o) printf '%s' "std/error/error.o" ;;
    ../std/json/json.o|std/json/json.o|*std/json/json.o) printf '%s' "std/json/json.o" ;;
    ../std/csv/csv.o|std/csv/csv.o|*std/csv/csv.o) printf '%s' "std/csv/csv.o" ;;
    ../std/dynlib/dynlib.o|std/dynlib/dynlib.o|*std/dynlib/dynlib.o) printf '%s' "std/dynlib/dynlib.o" ;;
    ../std/http/http.o|std/http/http.o|*std/http/http.o) printf '%s' "std/http/http.o" ;;
    ../std/tar/tar.o|std/tar/tar.o|*std/tar/tar.o) printf '%s' "std/tar/tar.o" ;;
    *) printf '%s' "" ;;
  esac
}

# Authority body sources (match historic Makefile recipe args, not always full prereqs).
formal_mod_spec_for_key() {
  case "$1" in
    # G.7: string.o authority = xlang_compile_std_string_o.sh (Mac std_string_* wrappers
    # + runtime_string_fast bare ABI). formal_mod generic path lacks Mac objcopy rename
    # completeness for entry-only -x -E; dual path caused L4 run-string BLD001.
    # PLATFORM: SHARED — same dedicated vehicle as fs_formal pattern.
    std/string/string.o) printf '%s' "string_formal|0|" ;;
    std/heap/heap.o) printf '%s' "mod|0|../std/heap/mod.x|../std/heap/libc.x|../std/heap/ops.x" ;;
    std/heap/page_mmap.o) printf '%s' "mod|0|../std/heap/page_mmap.x" ;;
    std/sys/sys.o) printf '%s' "mod|0|../std/sys/mod.x" ;;
    std/sys/linux.o) printf '%s' "mod|0|../std/sys/linux.x" ;;
    core/mem/mem.o) printf '%s' "mod|0|../core/mem/mod.x" ;;
    core/types/types.o) printf '%s' "mod|0|../core/types/mod.x" ;;
    core/option/option.o) printf '%s' "mod|0|../core/option/mod.x" ;;
    core/result/result.o) printf '%s' "mod|0|../core/result/mod.x" ;;
    core/debug/debug.o) printf '%s' "mod|0|../core/debug/mod.x" ;;
    core/slice/mod.o) printf '%s' "mod|0|../core/slice/mod.x" ;;
    std/map/map.o) printf '%s' "mod|1|../std/map/mod.x" ;;
    std/set/set.o) printf '%s' "mod|1|../std/set/mod.x" ;;
    std/vec/vec.o) printf '%s' "mod|0|../std/vec/mod.x" ;;
    std/thread/thread.o) printf '%s' "mod|0|../std/thread/mod.x" ;;
    std/time/time.o) printf '%s' "mod|1|../std/time/mod.x" ;;
    std/random/random.o) printf '%s' "mod|1|../std/random/mod.x|../std/random/random.x" ;;
    std/env/env.o) printf '%s' "mod|0|../std/env/mod.x" ;;
    std/fs/fs.o) printf '%s' "fs_formal|0|" ;;
    std/sync/sync.o) printf '%s' "mod|1|../std/sync/mod.x|../std/sync/sync.x" ;;
    std/queue/queue.o) printf '%s' "mod|1|../std/queue/mod.x|../std/queue/queue.x" ;;
    std/encoding/encoding.o) printf '%s' "mod|1|../std/encoding/mod.x|../std/encoding/encoding.x" ;;
    std/base64/base64.o) printf '%s' "mod|1|../std/base64/mod.x|../std/base64/base64.x" ;;
    std/crypto/crypto.o) printf '%s' "mod|1|../std/crypto/mod.x|../std/crypto/core.x|../std/crypto/aes_gcm.x|../std/crypto/chacha20_poly1305.x|../std/crypto/chacha20_aead.x|../std/crypto/ed25519.x" ;;
    std/log/log.o) printf '%s' "mod|1|../std/log/mod.x|../std/log/log.x" ;;
    std/test/test.o) printf '%s' "mod|1|../std/test/mod.x|../std/test/test.x" ;;
    std/atomic/atomic.o) printf '%s' "mod|1|../std/atomic/mod.x|../std/atomic/atomic.x" ;;
    std/hash/hash.o) printf '%s' "mod|1|../std/hash/mod.x|../std/hash/hash.x" ;;
    std/math/math.o) printf '%s' "mod|1|../std/math/mod.x|../std/math/math.x" ;;
    std/sort/sort.o) printf '%s' "mod|0|../std/sort/mod.x|../std/sort/sort.x" ;;
    std/ffi/ffi.o) printf '%s' "mod|1|../std/ffi/mod.x|../std/ffi/ffi.x" ;;
    std/context/context.o) printf '%s' "mod|1|../std/context/mod.x|../std/context/context.x" ;;
    std/error/error.o) printf '%s' "mod|0|../std/error/mod.x" ;;
    std/json/json.o) printf '%s' "mod|1|../std/json/mod.x|../std/json/json.x" ;;
    std/csv/csv.o) printf '%s' "mod|1|../std/csv/mod.x|../std/csv/csv.x" ;;
    std/dynlib/dynlib.o) printf '%s' "mod|1|../std/dynlib/mod.x|../std/dynlib/dynlib.x" ;;
    std/http/http.o) printf '%s' "mod|1|../std/http/mod.x|../std/http/http.x" ;;
    std/tar/tar.o) printf '%s' "mod|1|../std/tar/mod.x|../std/tar/tar.x" ;;
    *) printf '%s' "" ;;
  esac
}

formal_mod_all_keys() {
  printf '%s\n' \
    std/string/string.o \
    std/heap/heap.o \
    std/heap/page_mmap.o \
    std/sys/sys.o \
    std/sys/linux.o \
    core/mem/mem.o \
    core/types/types.o \
    core/option/option.o \
    core/result/result.o \
    core/debug/debug.o \
    core/slice/mod.o \
    std/map/map.o \
    std/set/set.o \
    std/vec/vec.o \
    std/thread/thread.o \
    std/time/time.o \
    std/random/random.o \
    std/env/env.o \
    std/fs/fs.o \
    std/sync/sync.o \
    std/queue/queue.o \
    std/encoding/encoding.o \
    std/base64/base64.o \
    std/crypto/crypto.o \
    std/log/log.o \
    std/test/test.o \
    std/atomic/atomic.o \
    std/hash/hash.o \
    std/math/math.o \
    std/sort/sort.o \
    std/ffi/ffi.o \
    std/context/context.o \
    std/error/error.o \
    std/json/json.o \
    std/csv/csv.o \
    std/dynlib/dynlib.o \
    std/http/http.o \
    std/tar/tar.o
}

formal_mod_out_for_key() {
  # Makefile targets use ../ prefix from compiler/
  case "$1" in
    core/*) printf '../%s' "$1" ;;
    std/*) printf '../%s' "$1" ;;
    *) printf '../%s' "$1" ;;
  esac
}

formal_mod_list() {
  formal_mod_all_keys | while IFS= read -r _k; do
    _sp="$(formal_mod_spec_for_key "$_k")"
    printf '%s  %s\n' "$_k" "$_sp"
  done
}

formal_mod_check() {
  _bad=0
  _n=0
  _here="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
  _mk="$_here/../Makefile"
  [ -f "$_mk" ] || _mk="$_here/Makefile"
  while IFS= read -r _k; do
    _n=$((_n + 1))
    _sp="$(formal_mod_spec_for_key "$_k")"
    if [ -z "$_sp" ]; then
      echo "formal_mod --check: empty spec for $_k" >&2
      _bad=1
      continue
    fi
    _kind="${_sp%%|*}"
    _rest="${_sp#*|}"
    _bare="${_rest%%|*}"
    _srcs="${_rest#*|}"
    if [ "$_kind" = "fs_formal" ]; then
      if [ ! -x "$_here/xlang_compile_std_fs_formal.sh" ] && [ ! -f "$_here/xlang_compile_std_fs_formal.sh" ]; then
        echo "formal_mod --check: missing xlang_compile_std_fs_formal.sh" >&2
        _bad=1
      fi
    elif [ "$_kind" = "string_formal" ]; then
      # PLATFORM: SHARED — string.o vehicle = xlang_compile_std_string_o.sh
      if [ ! -x "$_here/xlang_compile_std_string_o.sh" ] && [ ! -f "$_here/xlang_compile_std_string_o.sh" ]; then
        echo "formal_mod --check: missing xlang_compile_std_string_o.sh" >&2
        _bad=1
      fi
      for _s in ../std/string/mod.x ../std/string/string.x; do
        if [ ! -f "$_here/$_s" ] && [ ! -f "$_s" ]; then
          echo "formal_mod --check: missing source $_s for $_k" >&2
          _bad=1
        fi
      done
    else
      _old_ifs=$IFS
      IFS='|'
      # shellcheck disable=SC2086
      set -- $_srcs
      IFS=$_old_ifs
      for _s in "$@"; do
        [ -n "$_s" ] || continue
        if [ ! -f "$_here/$_s" ] && [ ! -f "$_s" ]; then
          echo "formal_mod --check: missing source $_s for $_k" >&2
          _bad=1
        fi
      done
    fi
    _tgt="$(formal_mod_out_for_key "$_k")"
    # Makefile thin-call: ensure|auto only (wave812); FORCE dep-thin (wave826).
    # wave894: multi-target $(FORMAL_MOD_PRODUCT_OBJS) + mk list (no per-leaf target line).
    # Accept A) legacy per-leaf `^OUT:` FORCE+ensure, or B) OUT in mk list + multi-target rule.
    if [ -f "$_mk" ]; then
      _fm_mk="$_here/../mk/formal_mod_product_objs.mk"
      [ -f "$_fm_mk" ] || _fm_mk="$_here/mk/formal_mod_product_objs.mk"
      _ok_leaf=0
      if awk -v tgt="$_tgt" '
        $0 ~ ("^" tgt ":") {
          line=$0
          if (line !~ /FORCE/) { exit 1 }
          if (line ~ /\.x([[:space:]]|$)/) { exit 1 }
          hit=1; next
        }
        hit && /^[^#[:space:]]/ { exit 1 }
        hit && /xlang_compile_std_module\.sh/ {
          if ($0 ~ /ensure|auto/) { found=1; exit 0 }
        }
        hit && /xlang_compile_std_fs_formal\.sh/ {
          if (tgt ~ /fs\/fs\.o/) { found=1; exit 0 }
        }
        END { exit found ? 0 : 1 }
      ' "$_mk" 2>/dev/null; then
        _ok_leaf=1
      elif [ -f "$_fm_mk" ] \
        && grep -qF "$_tgt" "$_fm_mk" \
        && grep -qE '\$\(FORMAL_MOD_PRODUCT_OBJS\):[[:space:]]*FORCE' "$_mk" \
        && awk '
          /\$\(FORMAL_MOD_PRODUCT_OBJS\):/ { hit=1; next }
          hit && /^[^#[:space:]\t]/ { exit 1 }
          hit && /xlang_compile_std_module\.sh/ && /ensure|auto/ { found=1; exit 0 }
          END { exit found ? 0 : 1 }
        ' "$_mk"; then
        _ok_leaf=1
      fi
      if [ "$_ok_leaf" -ne 1 ]; then
        echo "formal_mod --check: Makefile/mk $_tgt must FORCE + ensure|auto (wave826/wave894)" >&2
        _bad=1
      fi
    fi
  done <<'KEYS'
std/string/string.o
std/heap/heap.o
std/heap/page_mmap.o
std/sys/sys.o
std/sys/linux.o
core/mem/mem.o
core/types/types.o
core/option/option.o
core/result/result.o
core/debug/debug.o
core/slice/mod.o
std/map/map.o
std/set/set.o
std/vec/vec.o
std/thread/thread.o
std/time/time.o
std/random/random.o
std/env/env.o
std/fs/fs.o
std/sync/sync.o
std/queue/queue.o
std/encoding/encoding.o
std/base64/base64.o
std/crypto/crypto.o
std/log/log.o
std/test/test.o
std/atomic/atomic.o
std/hash/hash.o
std/math/math.o
std/sort/sort.o
std/ffi/ffi.o
std/context/context.o
std/error/error.o
std/json/json.o
std/csv/csv.o
std/dynlib/dynlib.o
std/http/http.o
std/tar/tar.o
KEYS
  if [ "$_n" -ne 38 ]; then
    echo "formal_mod --check: expected 38 keys, counted $_n" >&2
    _bad=1
  fi
  if [ "$_bad" -ne 0 ]; then
    echo "formal_mod --check: FAIL" >&2
    return 1
  fi
  echo "formal_mod --check: OK (38 leaves; catalog + mk list + multi-target FORCE+ensure wave894; not physical delete)"
  return 0
}

# Mode dispatch (wave812). Legacy [--bare-impl] OUT sources remains supported.
BARE_IMPL=0
case "${1:-}" in
  list)
    formal_mod_list
    exit 0
    ;;
  --check)
    formal_mod_check
    exit $?
    ;;
  ensure|auto)
    if [ -z "${2:-}" ]; then
      echo "usage: xlang_compile_std_module.sh ensure <out.o>" >&2
      exit 1
    fi
    out_o="$2"
    _key="$(formal_mod_key_for_out "$out_o")"
    if [ -z "$_key" ]; then
      echo "xlang_compile_std_module.sh ensure: unknown formal_mod leaf: $out_o" >&2
      exit 3
    fi
    _spec="$(formal_mod_spec_for_key "$_key")"
    _kind="${_spec%%|*}"
    _rest="${_spec#*|}"
    _bare="${_rest%%|*}"
    _srcs="${_rest#*|}"
    if [ "$_kind" = "fs_formal" ]; then
      # PLATFORM: SHARED — fs formal vehicle authority stays in dedicated script.
      _fs_sh="$(dirname "$0")/xlang_compile_std_fs_formal.sh"
      [ -f "$_fs_sh" ] || _fs_sh="./xlang_compile_std_fs_formal.sh"
      exec sh "$_fs_sh" "$out_o"
    fi
    if [ "$_kind" = "string_formal" ]; then
      # PLATFORM: SHARED — string.o authority = xlang_compile_std_string_o.sh
      # (Mac wrappers + runtime_string_fast; G.7 single vehicle, no dual formal_mod body).
      _str_sh="$(dirname "$0")/xlang_compile_std_string_o.sh"
      [ -f "$_str_sh" ] || _str_sh="./xlang_compile_std_string_o.sh"
      # Dedicated script ignores out path; always writes $ROOT/std/string/string.o
      exec sh "$_str_sh"
    fi
    BARE_IMPL="$_bare"
    # Rebuild positional args as sources for shared compile body below (out_o already set).
    # PLATFORM: SHARED — catalog sources use ../std|core paths from compiler/ cwd.
    _fm_srcs=""
    _old_ifs=$IFS
    IFS='|'
    for _s in $_srcs; do
      [ -n "$_s" ] || continue
      if [ -z "$_fm_srcs" ]; then
        _fm_srcs="$_s"
      else
        _fm_srcs="$_fm_srcs $_s"
      fi
    done
    IFS=$_old_ifs
    if [ -z "$_fm_srcs" ]; then
      echo "xlang_compile_std_module.sh ensure: no sources for $_key" >&2
      exit 1
    fi
    # wave826: FORCE-thin mtime — shell owns catalog source freshness (G.7).
    # Makefile always invokes via FORCE; skip recompile when OUT is newer than all
    # catalog sources. FORCE=1 forces rebuild (tests / explicit). PLATFORM: SHARED.
    if [ "${FORCE:-0}" != "1" ] && [ -f "$out_o" ]; then
      _fm_stale=0
      for _s in $_fm_srcs; do
        [ -n "$_s" ] || continue
        if [ -f "$_s" ] && [ "$_s" -nt "$out_o" ]; then
          _fm_stale=1
          break
        fi
      done
      if [ "$_fm_stale" = "0" ]; then
        echo "xlang_compile_std_module: skip up-to-date $out_o (formal_mod/$_key)" >&2
        exit 0
      fi
    fi
    # shellcheck disable=SC2086
    set -- $_fm_srcs
    ;;
  --bare-impl)
    BARE_IMPL=1
    shift
    out_o="$1"
    shift
    if [ -z "$out_o" ] || [ "$#" -lt 1 ]; then
      echo "usage: xlang_compile_std_module.sh [--bare-impl] <out.o> <x1> [x2] ..." >&2
      exit 1
    fi
    ;;
  *)
    out_o="$1"
    shift
    if [ -z "$out_o" ] || [ "$#" -lt 1 ]; then
      echo "usage: xlang_compile_std_module.sh [--bare-impl|ensure|list|--check] ..." >&2
      exit 1
    fi
    ;;
esac

# 【Why 根源】优先 ./xlang（.x pipeline，支持 -x -E）；LEGACY xlang-c 不支持 -x 选项。
# G-02a 后 -E-extern 不可用，必须用 -x -E 走 .x pipeline，故 ./xlang 优先。
# XLANG 可能是项目根目录相对路径（./compiler/xlang），Makefile 在 compiler/ 下执行时
# 该路径不存在，需回退到 compiler/ 本地的 ./xlang。
# wave812: string.o historic Makefile host-pick (xlang_asm→xlang) is already covered
# by this ladder + XLANG env; no second ladder in Makefile.
XLANG_BIN="${XLANG:-./xlang}"
[ -x "$XLANG_BIN" ] || XLANG_BIN="./xlang"
[ -x "$XLANG_BIN" ] || XLANG_BIN="./xlang_asm"
[ -x "$XLANG_BIN" ] || XLANG_BIN="./xlang-c"
[ -x "$XLANG_BIN" ] || XLANG_BIN="../compiler/xlang"
[ -x "$XLANG_BIN" ] || { echo "xlang_compile_std_module.sh: no xlang/xlang_asm/xlang-c found" >&2; exit 1; }

# 【Why 根源】-x -E 生成瘦 C TU（emit_c_only=1 + emit_extern_imports=1），
# import 用 extern 声明，不内联 deps。mod.x 带前缀产出 std_<module>_* 用户 API。
# --bare-impl 模式下 impl .x 用 -lib-name "" 产出裸符号（如 tar_read_header_c）；
# 否则 impl .x 用路径提取前缀（如 std_heap_libc_heap_arena64_alloc_c），匹配 import binding。
# CFLAGS 抑制 warning（-x -E 生成的 C 有大量 extern 前向声明）。
# -ffunction-sections -fdata-sections：配合 freestanding 链接的 --gc-sections，
# 移除 std/sys/linux.o 等模块中未被引用的 hosted libc 函数（open/mmap 等），
# 使 freestanding -nostdlib 链接不因 transitive libc 符号失败。
# PLATFORM: LINUX — -D_GNU_SOURCE so formal std.fs.posix (posix_fadvise, etc.) compile
# under gcc -Werror=implicit-function-declaration; macOS clang accepts without it.
# PLATFORM: SHARED — -Wno-implicit-function-declaration: -x -E emits extern calls to
# cross-module APIs (e.g. std/net/mod.x calls std_io_read_fixed_fd) but codegen does
# not always emit forward extern decls. Tolerate like xlang_compile_std_fs_formal.sh
# (posix_fadvise etc.). Same for -Wno-builtin-declaration-mismatch (libc name clashes).
CFLAGS="-I.. -I. -Iinclude -Isrc -fPIE -ffunction-sections -fdata-sections -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits -Wno-visibility -Wno-incompatible-pointer-types -Wno-incompatible-pointer-types-discards-qualifiers -Wno-implicit-function-declaration -Wno-builtin-declaration-mismatch"
case "$(uname -s 2>/dev/null)" in
  Linux) CFLAGS="-D_GNU_SOURCE $CFLAGS" ;;
esac
if cc -v 2>&1 | grep -q clang; then
  CFLAGS="$CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses"
fi

tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t xlangmod)
trap 'if [ -n "${XLANG_DEBUG_KEEP_TMP:-}" ]; then echo "DEBUG kept tmp_dir=$tmp_dir" >&2; else rm -rf "$tmp_dir" 2>/dev/null || true; fi' EXIT INT TERM

# 【Why 根源】旧 seed（bootstrap_xlangc）不支持 -lib-name flag（ treats it as a file path,
# outputs "io error: cannot read file '-lib-name'" and exits 0）。但其无前缀逻辑也产出裸符号
# （函数名本身已含 module_ 前缀），故不加 -lib-name 即可匹配 mod.x 的 extern 调用。
# 新编译器需 -lib-name "" 抑制 xlang_entry_lib_name_from_path 的路径前缀，否则符号被双重前缀化。
LIB_NAME_SUPPORTED=0
probe_x="$tmp_dir/probe.x"
probe_c="$tmp_dir/probe.c"
probe_err="$tmp_dir/probe.err"
printf 'function probe_fn(): i32 { return 0; }\n' > "$probe_x"
# 产品 x-pipeline 当前不识别 -lib-name（会当文件路径 → IO001）；仅 C 前端 RUN_CC 支持。
# 误判会把 -lib-name 传给 x 路径，或跳过 bare 后处理 → 双前缀符号（std_sync_sync_mutex_*）。
if "$XLANG_BIN" -x -E -lib-name "" "$probe_x" >"$probe_c" 2>"$probe_err" \
  && grep -q 'probe_fn' "$probe_c" \
  && ! grep -q 'cannot read file' "$probe_err" \
  && ! grep -q 'IO001' "$probe_err"; then
  LIB_NAME_SUPPORTED=1
fi

obj_files=""
idx=0
for x_path in "$@"; do
  # Makefile 在 compiler/ 下执行；输入须为 ../std/...（-L .. 不解析入口路径）
  case "$x_path" in
    std/*) x_path="../$x_path" ;;
  esac
  gen_c="$tmp_dir/mod_${idx}.c"
  obj="$tmp_dir/mod_${idx}.o"
  # 【Why 根源】mod.x 是模块入口，编译为带前缀符号（std_<module>_*）。
  # --bare-impl 模式下，impl .x 用 -lib-name "" 产出裸符号（匹配 mod.x 的 extern 调用）；
  # 否则 impl .x 用路径提取前缀（匹配 mod.x 的 import binding 调用）。
  base_name=$(basename "$x_path")
  # 【Why 根源】产品 -x -E 对无 main 库模块常中途截断 out_buf（4KiB 对齐截断、
  # 半个函数体）。-o *.o 路径 emit 完整 C（cc 可能因 Arena64 标签失败，但 XLANG_KEEP_C
  # 保留完整源）。优先 -o + KEEP_C，失败再回退 -E。
  emit_ok=0
  use_direct_o=0
  # 产品 std .o：Linux 默认 asm 对 string 等库模块体不完整（运行时 SIGSEGV）；强制 -backend c。
  # -o 无 main 时链失败但 XLANG_KEEP_C 保留完整 C；再 cc -c 落地。
  BACKEND_ARGS=""
  if [ -n "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
    BACKEND_ARGS="-backend ${XLANG_FORCE_LINK_BACKEND}"
  else
    case "$(uname -s 2>/dev/null)" in
      Linux|Darwin) BACKEND_ARGS="-backend c" ;;
    esac
  fi
  # PLATFORM: SHARED — NEVER rm /tmp/xlang_xlang_x.*.c globally: bstrict concurrent
  # user -o and std compile race-delete each other's KEEP_C temps (mac L4 true-cold).
  # shellcheck: empty -lib-name needs quoted empty string
  if [ "$base_name" != "mod.x" ] && [ "$BARE_IMPL" = "1" ] && [ "$LIB_NAME_SUPPORTED" = "1" ]; then
    XLANG_KEEP_C=1 "$XLANG_BIN" $BACKEND_ARGS -L .. -lib-name "" -o "$tmp_dir/try_${idx}.o" "$x_path" \
      >"$tmp_dir/xlangc_${idx}.log" 2>&1 || true
  else
    XLANG_KEEP_C=1 "$XLANG_BIN" $BACKEND_ARGS -L .. -o "$tmp_dir/try_${idx}.o" "$x_path" \
      >"$tmp_dir/xlangc_${idx}.log" 2>&1 || true
  fi
  # 优先：-o 已直接产出可用 .o（无 Arena64 冲突时）。
  # bare-impl 且无 -lib-name：
  #   - 产品 C 后端 -o/KEEP_C 常带路径前缀（std_crypto_core_*）→ 须 gen_c 剥前缀
  #   - 若 KEEP_C 完整则优先 C 路径；asm 裸 .o 仅作次选
  # 旧逻辑一律拒绝 direct .o 再走 -x -E，而 -E 对 preamble 在 ~20KiB 处截断 → crypto.o 假死。
  # bare-impl 子文件（core.x 等）：mod.x 以裸名 crypto_mem_eq_c 声明，
  # 产品 C 后端常仍 emit 路径前缀 std_crypto_core_*（即便 -lib-name "" / LIB_NAME_SUPPORTED）。
  # 必须剥前缀，否则 ld 得 U crypto_mem_eq_c 与 T std_crypto_core_crypto_mem_eq_c 双轨。
  bare_need_strip=0
  if [ "$base_name" != "mod.x" ] && [ "$BARE_IMPL" = "1" ]; then
    bare_need_strip=1
  fi
  # KEEP_C 路径：从本 invocation 的 log 取路径（勿 ls /tmp 抢别人的 temp）
  kept0=$(grep -E 'kept generated C:|keeping generated C:' "$tmp_dir/xlangc_${idx}.log" 2>/dev/null \
    | sed -n 's/.*generated C: //p' | tail -1)
  if [ -n "$kept0" ] && [ -f "$kept0" ] && [ -s "$kept0" ] && tail -c 80 "$kept0" | grep -q '}'; then
    cp "$kept0" "$gen_c"
    emit_ok=1
    # 只删本路径，勿通配
    rm -f "$kept0" 2>/dev/null || true
  fi
  if [ "$emit_ok" != "1" ] && [ -f "$tmp_dir/try_${idx}.o" ] && [ -s "$tmp_dir/try_${idx}.o" ]; then
    if [ "$bare_need_strip" = "1" ]; then
      strip_pref_probe=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|\.x$||' -e 's|/|_|g')
      has_prefixed=0
      if [ -n "$strip_pref_probe" ] && command -v nm >/dev/null 2>&1; then
        if nm "$tmp_dir/try_${idx}.o" 2>/dev/null | grep -q " T ${strip_pref_probe}_"; then
          has_prefixed=1
        fi
      fi
      if [ "$has_prefixed" != "1" ]; then
        # 已是裸符号（asm -o）或无可检测前缀：直接用 .o
        bare_need_strip=0
        use_direct_o=1
        emit_ok=1
        obj="$tmp_dir/try_${idx}.o"
      fi
      # has_prefixed=1：保留 bare_need_strip，走下方 KEEP_C / -E 剥前缀
    else
      use_direct_o=1
      emit_ok=1
      obj="$tmp_dir/try_${idx}.o"
    fi
  fi
  # mod.x 用户 API 须为 <root>_<module>_*（import 调用约定）。
  # PLATFORM: SHARED — std/foo → std_foo_*; core/slice → core_slice_* (NOT std_slice_*).
  # 产品 Linux asm/KEEP_C 常产裸名 len_i32；objcopy 重命名与 mac C 路径对齐。
  # G.7: length.x U core_slice_len_i32 while formal mod.o had bare len_i32 → BLD001.
  if [ "$use_direct_o" = "1" ] && [ "$base_name" = "mod.x" ] \
     && [ -f "$obj" ] && command -v nm >/dev/null 2>&1; then
    mod_leaf=$(basename "$(dirname "$x_path")")
    case "$mod_leaf" in
      ''|.) mod_leaf=$(basename "$x_path" .x) ;;
    esac
    # Path root: ../core/slice/mod.x → core; ../std/env/mod.x → std.
    mod_root=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|/.*||')
    case "$mod_root" in
      core) mod_pref="core_${mod_leaf}_" ;;
      std)  mod_pref="std_${mod_leaf}_" ;;
      *)    mod_pref="std_${mod_leaf}_" ;;
    esac
    if [ -n "$mod_leaf" ] && ! nm "$obj" 2>/dev/null | grep -q " T ${mod_pref}"; then
      if command -v objcopy >/dev/null 2>&1; then
        nm "$obj" 2>/dev/null | awk '/ [TDB] / { print $3 }' | while IFS= read -r sym; do
          [ -n "$sym" ] || continue
          case "$sym" in
            "${mod_pref}"*) continue ;;
            _"${mod_pref}"*) continue ;;
            # Already product-prefixed (co-emitted deps) or compiler noise.
            core_*|std_*|_core_*|_std_*) continue ;;
            # 跳过 C 内部/编译器符号
            _Z*|.L*|L0*|__*) continue ;;
          esac
          # Mach-O 可能带前导 _
          bare="$sym"
          case "$sym" in
            _*) bare="${sym#_}" ;;
          esac
          case "$bare" in
            "${mod_pref}"*|core_*|std_*) continue ;;
          esac
          if [ "$bare" != "$sym" ]; then
            objcopy --redefine-sym "${sym}=_${mod_pref}${bare}" "$obj" 2>/dev/null || true
          else
            objcopy --redefine-sym "${sym}=${mod_pref}${bare}" "$obj" 2>/dev/null || true
          fi
        done
      fi
      if ! nm "$obj" 2>/dev/null | grep -q " T ${mod_pref}"; then
        # 重命名失败：放弃 direct .o，改走 C/KEEP_C 前缀路径
        use_direct_o=0
        emit_ok=0
        obj="$tmp_dir/mod_${idx}.o"
      fi
    fi
  fi
  if [ "$emit_ok" != "1" ]; then
    kept=$(grep -E 'kept generated C:|keeping generated C:' "$tmp_dir/xlangc_${idx}.log" 2>/dev/null \
      | sed -n 's/.*generated C: //p' | tail -1)
    if [ -n "$kept" ] && [ -f "$kept" ] && [ -s "$kept" ]; then
      if tail -c 80 "$kept" | grep -q '}' ; then
        cp "$kept" "$gen_c"
        emit_ok=1
        rm -f "$kept" 2>/dev/null || true
      fi
    fi
  fi
  # bare-impl 需剥前缀且无完整 C：再试 -backend c KEEP_C
  if [ "$emit_ok" != "1" ] && [ "$bare_need_strip" = "1" ]; then
    XLANG_KEEP_C=1 "$XLANG_BIN" -backend c -L .. -o "$tmp_dir/try_c_${idx}.o" "$x_path" \
      >"$tmp_dir/xlangc_c_${idx}.log" 2>&1 || true
    kept=$(grep -E 'kept generated C:|keeping generated C:' "$tmp_dir/xlangc_c_${idx}.log" 2>/dev/null \
      | sed -n 's/.*generated C: //p' | tail -1)
    if [ -n "$kept" ] && [ -f "$kept" ] && [ -s "$kept" ]; then
      if tail -c 80 "$kept" | grep -q '}' ; then
        cp "$kept" "$gen_c"
        emit_ok=1
        rm -f "$kept" 2>/dev/null || true
      fi
    fi
  fi
  if [ "$emit_ok" != "1" ]; then
    # 回退 -E：拒绝明显截断（尾部无 } 或半截 token）
    if [ "$base_name" != "mod.x" ] && [ "$BARE_IMPL" = "1" ] && [ "$LIB_NAME_SUPPORTED" = "1" ]; then
      if ! "$XLANG_BIN" -backend c -x -E -lib-name "" -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/xlangc_${idx}.log"; then
        if ! "$XLANG_BIN" -x -E -lib-name "" -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/xlangc_${idx}.log"; then
          echo "xlang_compile_std_module.sh: -o and -x -E failed for $x_path" >&2
          cat "$tmp_dir/xlangc_${idx}.log" >&2
          exit 1
        fi
      fi
    else
      if ! "$XLANG_BIN" -backend c -x -E -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/xlangc_${idx}.log"; then
        if ! "$XLANG_BIN" -x -E -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/xlangc_${idx}.log"; then
          echo "xlang_compile_std_module.sh: -o and -x -E failed for $x_path" >&2
          cat "$tmp_dir/xlangc_${idx}.log" >&2
          exit 1
        fi
      fi
    fi
    if [ -s "$gen_c" ] && tail -c 80 "$gen_c" | grep -q '}'; then
      # 拒绝半截 struct/标识符（历史 20KiB 截断）
      if ! tail -c 1 "$gen_c" | grep -q '[[:space:];}]' \
         && ! tail -c 40 "$gen_c" | grep -qE '([;}][[:space:]]*)$'; then
        echo "xlang_compile_std_module.sh: -E output looks truncated for $x_path" >&2
        exit 1
      fi
      emit_ok=1
    elif [ -s "$gen_c" ]; then
      echo "xlang_compile_std_module.sh: -E output incomplete (no closing brace) for $x_path" >&2
      exit 1
    fi
  fi
  # bare-impl：产品 x-pipeline 无 -lib-name 时，codegen 用路径导出前缀
  # （std/base64/base64.x → std_base64_base64_…）。mod.x 的 extern 是裸名
  # base64_encode_standard_c。在 gen_c 齐备后剥前缀（须在 -E 回退之后）。
  if [ "$bare_need_strip" = "1" ] && [ -f "$gen_c" ] && [ -s "$gen_c" ]; then
    strip_pref=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|\.x$||' -e 's|/|_|g')
    if [ -n "$strip_pref" ]; then
      perl -i -pe "s/\\b\Q${strip_pref}_\E//g" "$gen_c" 2>/dev/null || \
        sed -i.bak "s/${strip_pref}_//g" "$gen_c" 2>/dev/null || true
      dir_pref=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|/[^/]*$||' -e 's|/|_|g')
      if [ -n "$dir_pref" ] && [ "$dir_pref" != "$strip_pref" ]; then
        perl -i -pe "s/\\b\Q${dir_pref}_\E//g" "$gen_c" 2>/dev/null || \
          sed -i.bak "s/${dir_pref}_//g" "$gen_c" 2>/dev/null || true
      fi
      rm -f "${gen_c}.bak" 2>/dev/null || true
    fi
  fi
  # 已有直接 .o：跳过 gen_c 后处理与二次 cc
  if [ "$use_direct_o" = "1" ]; then
    if [ -z "$obj_files" ]; then
      obj_files="$obj"
    else
      obj_files="$obj_files $obj"
    fi
    idx=$((idx + 1))
    continue
  fi
  # PLATFORM: SHARED — rt_preamble injects weak std_vec_len_empty / std_vec_vec_len_empty
  # for programs that never link std/vec/vec.o. std/vec/mod.x provides strong defs in the
  # same TU → Clang/GCC redefinition error on host-cc path (Darwin always; Linux when
  # forced -backend c). Authority: strip preamble weak bodies when strong defs exist
  # (same pattern as xlang_compile_std_x.sh args_iter_*).
  if [ -f "$gen_c" ] && [ -s "$gen_c" ]; then
    if grep -qE '__attribute__\(\(weak\)\).*std_vec_len_empty' "$gen_c" 2>/dev/null \
      && grep -qE '^int32_t std_vec_len_empty\(' "$gen_c" 2>/dev/null; then
      sed -e '/__attribute__((weak)) int32_t std_vec_len_empty(void)/d' \
          -e '/__attribute__((weak)) int32_t std_vec_vec_len_empty(void)/d' \
          "$gen_c" >"$gen_c.strip" && mv "$gen_c.strip" "$gen_c"
    fi
  fi
  # PLATFORM: SHARED — generic weak-stub dedup after --bare-impl prefix strip.
  # After stripping the path prefix (e.g. std_context_context_), a weak preamble stub
  # can collide with a strong def that was previously differently-named
  # (context.x: weak ctx_background_c + stripped std_context_context_ctx_background_c
  # -> ctx_background_c both weak and strong -> cc redefinition). Two-pass: grep strong
  # def names, then drop matching weak stub lines.
  if [ -f "$gen_c" ] && [ -s "$gen_c" ]; then
    strong_names=$(grep -E '^[A-Za-z_][A-Za-z0-9_ *]* [A-Za-z_][A-Za-z0-9_]*[(][^)]*[)] *[{{]?[[:space:]]*$' "$gen_c" \
      | grep -v 'weak' \
      | sed -n 's/.*[[:space:]]\([A-Za-z_][A-Za-z0-9_]*\)(.*/\1/p' \
      | sort -u)

    if [ -n "$strong_names" ]; then
      : > "$gen_c.dedup_script"
      # For each strong def name, remove weak stub lines that define the same name.
      # Pattern: __attribute__((weak))... <name>( — one sed -e per name.
      echo "$strong_names" > "$gen_c.strong_names"
      awk 'NR==FNR { strong[$0]=1; next }
        /^__attribute__..weak../ {
          if (match($0, /[ ][A-Za-z_][A-Za-z0-9_]*[(]/)) {
            nm = substr($0, RSTART+1, RLENGTH-2)
            if (nm in strong) { skip=1; if (/[}]/) skip=0; next }
          }
        }
        skip { if (/[}]/) skip=0; next }
        { print }
      ' "$gen_c.strong_names" "$gen_c" > "$gen_c.dedup" 2>/dev/null && mv "$gen_c.dedup" "$gen_c"
      rm -f "$gen_c.strong_names"
    fi
  fi
  # 【Why 根源】-E 对跨模块 struct（如 heap_libc_Arena64）常只在「形参列表内」
  # 写出 `struct Foo`，未给文件级 forward。C 规定形参内的 struct 标签作用域仅限该
  # 声明 → 原型与定义各得一个不同 incomplete 类型 → conflicting types for 'fn'。
  # 在首个非预处理行前注入 `struct Foo;` 使整 TU 共享同一标签。
  # codegen 对 dep struct 正确 emit forward 后本段可删。
  if command -v perl >/dev/null 2>&1; then
    fwd_tmp="$tmp_dir/fwd_${idx}.h"
    perl -ne 'while (/struct\s+([A-Za-z_][A-Za-z0-9_]*)/g) { print "$1\n" if $1 ne "std_io_driver_Buffer" }' \
      "$gen_c" 2>/dev/null | sort -u >"$tmp_dir/structs_${idx}.txt" || true
    if [ -s "$tmp_dir/structs_${idx}.txt" ]; then
      : >"$fwd_tmp"
      while IFS= read -r sn; do
        [ -n "$sn" ] || continue
        # 已有完整定义或已有文件级 forward 则跳过
        if grep -E "struct[[:space:]]+${sn}[[:space:]]*[{;]" "$gen_c" >/dev/null 2>&1; then
          continue
        fi
        # 仅当只在形参/指针处出现（无 { 体）时补 forward
        if grep -E "struct[[:space:]]+${sn}[[:space:]]*\*" "$gen_c" >/dev/null 2>&1; then
          printf 'struct %s;\n' "$sn" >>"$fwd_tmp"
        fi
      done <"$tmp_dir/structs_${idx}.txt"
      # 双名对齐：entry 形参常 emit `struct heap_libc_Arena64`，dep 体为
      # `struct std_heap_libc_LibcArena64`。#define 标签别名使 `struct heap_libc_Arena64`
      # 展开为同一标签，避免 GCC 14 incompatible pointer types 当 error。
      if grep -q 'std_heap_libc_LibcArena64' "$gen_c" \
         && grep -q 'heap_libc_Arena64' "$gen_c"; then
        # 勿再 emit incomplete `struct heap_libc_Arena64;`（会与 #define 冲突）
        if [ -f "$fwd_tmp" ]; then
          grep -v '^struct heap_libc_Arena64;$' "$fwd_tmp" >"$fwd_tmp.f" 2>/dev/null || true
          mv "$fwd_tmp.f" "$fwd_tmp" 2>/dev/null || true
        fi
        printf '%s\n' \
          '/* xlang_compile_std_module: Arena64 tag alias (import path vs short) */' \
          '#define heap_libc_Arena64 std_heap_libc_LibcArena64' \
          >>"$fwd_tmp"
      fi
      if [ -s "$fwd_tmp" ]; then
        # 插在最后一个 #include 之后；若无 include 则插文件首
        merged="$tmp_dir/gen_fwd_${idx}.c"
        if grep -q '^#include' "$gen_c"; then
          # 在最后一个 #include 行后插入
          awk -v fwd="$fwd_tmp" '
            /^#include/ { last=NR }
            { lines[NR]=$0 }
            END {
              for (i=1;i<=NR;i++) {
                print lines[i]
                if (i==last) {
                  while ((getline l < fwd) > 0) print l
                  close(fwd)
                }
              }
            }' "$gen_c" >"$merged" && mv "$merged" "$gen_c"
        else
          cat "$fwd_tmp" "$gen_c" >"$merged" && mv "$merged" "$gen_c"
        fi
      fi
    fi
  fi

  # 【Why 根源】codegen bug workaround (2026-07-19): when a struct field type is
  # another user struct (e.g. std/net/mod.x SocketAddrV4 { addr: Ipv4Addr, port: u32 }),
  # codegen -x -E emits only forward `struct Foo;` declaration but not the complete
  # definition. cc then fails with "incomplete result type 'struct Foo' in function
  # definition". Workaround: extract all `export struct Foo { ... }` from mod.x
  # source, convert XLANG types to C types, inject the missing complete definitions
  # right after the last #include (only for structs whose complete body is absent).
  # PLATFORM: SHARED — runs only on mod.x entry file; impl .x (--bare-impl) skipped.
  if [ "$base_name" = "mod.x" ] && command -v perl >/dev/null 2>&1; then
    mod_x_src="$x_path"
    case "$mod_x_src" in
      std/*) mod_x_src="../$mod_x_src" ;;
    esac
    if [ -f "$mod_x_src" ]; then
      mod_leaf_x=$(basename "$(dirname "$mod_x_src")")
      mod_root_x=$(printf '%s' "$mod_x_src" | sed -e 's|^\.\./||' -e 's|/.*||')
      case "$mod_root_x" in
        core) mod_pref_x="core_${mod_leaf_x}_" ;;
        std)  mod_pref_x="std_${mod_leaf_x}_" ;;
        *)    mod_pref_x="std_${mod_leaf_x}_" ;;
      esac
      inject_tmp="$tmp_dir/inject_structs_${idx}.h"
      perl -e '
        use strict;
        my ($prefix, $src) = @ARGV;
        open(my $fh, "<", $src) or exit 0;
        my %type_map = (
          u8 => "uint8_t", u16 => "uint16_t", u32 => "uint32_t", u64 => "uint64_t",
          i8 => "int8_t",  i16 => "int16_t",  i32 => "int32_t",  i64 => "int64_t",
          f32 => "float", f64 => "double", usize => "size_t", isize => "ssize_t",
          bool => "_Bool",
        );
        sub to_c_type {
          my $t = shift; $t =~ s/^\s+|\s+$//g; $t =~ s/;$//;
          if ($t =~ /^\*(.*)$/) { return to_c_type($1) . " *"; }
          if ($t =~ /^(.+)\[(\d+)\]$/) { return to_c_type($1) . "[" . $2 . "]"; }
          if (exists $type_map{$t}) { return $type_map{$t}; }
          return "struct ${prefix}${t}";
        }
        my $in_struct = 0; my $name; my @fields;
        while (my $line = <$fh>) {
          if (!$in_struct && $line =~ /^export struct ([A-Za-z_][A-Za-z0-9_]*) \{/) {
            $name = $1; @fields = (); $in_struct = 1; next;
          }
          if ($in_struct) {
            if ($line =~ /^\}/) {
              print "struct ${prefix}${name} {\n";
              for my $f (@fields) { print "  $f;\n"; }
              print "};\n"; $in_struct = 0;
            } elsif ($line =~ /^\s*(\w+)\s*:\s*(.+)$/) {
              my $fname = $1; my $ftype = $2; $ftype =~ s/\s+$//; $ftype =~ s/;$//;
              push @fields, to_c_type($ftype) . " " . $fname;
            }
          }
        }
      ' "$mod_pref_x" "$mod_x_src" >"$inject_tmp" 2>/dev/null || true
      # Filter inject_tmp: keep only structs whose complete body is MISSING from gen_c.
      # Detection covers three cases:
      #   1. forward `struct Foo;` exists but `struct Foo {` does not
      #   2. only used in function signatures (e.g. `struct Foo std_net_local_addr(...)`)
      #      with no forward decl and no complete def (codegen bug — emit just sig)
      #   3. struct already has complete body in gen_c → skip (no duplicate)
      # Also synthesizes xlang_slice_<pref>_<Struct> slice types when codegen omits them
      # (codegen emits xlang_slice_uint8_t etc. but skips user-struct slices).
      # Also patches codegen bug: `struct Foo _rc = 0;` → `struct Foo _rc = {0};`
      # (struct local var initialized with int literal instead of compound literal).
      if [ -f "$gen_c" ] && command -v perl >/dev/null 2>&1; then
        # Patch struct-local-var init from `= 0` to `= {0}` (only when LHS is `struct ...`)
        # Allow leading whitespace (function body indentation).
        perl -i -pe 's/^(\s*struct\s+[A-Za-z_][A-Za-z0-9_]*\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*)0\s*;/${1}\{0\};/g' "$gen_c" 2>/dev/null || true
      fi
      if [ -s "$inject_tmp" ] && [ -f "$gen_c" ]; then
        filtered="$tmp_dir/inject_filtered_${idx}.h"
        perl -e '
          use strict;
          my ($gen_c, $inject, $pref) = @ARGV;
          open(my $gf, "<", $gen_c) or exit 0;
          my (%has_full, %slice_seen);
          while (my $l = <$gf>) {
            if ($l =~ /^struct (\Q$pref\E[A-Za-z_][A-Za-z0-9_]*) \{/) { $has_full{$1} = 1; }
            if ($l =~ /^struct (xlang_slice_\Q$pref\E[A-Za-z_][A-Za-z0-9_]*) \{/) { $has_full{$1} = 1; }
            while ($l =~ /xlang_slice_(\Q$pref\E[A-Za-z_][A-Za-z0-9_]*)/g) {
              $slice_seen{$1} = 1;
            }
          }
          close($gf);
          # First: emit xlang_slice_<name> syntheses for missing slice types.
          for my $sname (sort keys %slice_seen) {
            next if exists $has_full{"xlang_slice_" . $sname};
            # sname = std_net_TcpStream → element type = struct std_net_TcpStream
            print "struct xlang_slice_${sname} { struct ${sname} *data; size_t length; };\n";
          }
          # Second: emit missing export struct bodies from mod.x.
          open(my $in, "<", $inject) or exit 0;
          my $in_body = 0; my $name; my $buf = "";
          while (my $l = <$in>) {
            if (!$in_body && $l =~ /^struct (\Q$pref\E[A-Za-z_][A-Za-z0-9_]*) \{/) {
              $name = $1; $buf = $l; $in_body = 1; next;
            }
            if ($in_body) {
              $buf .= $l;
              if ($l =~ /^\};/) {
                if (!exists $has_full{$name}) { print $buf; }
                $in_body = 0;
              }
            }
          }
          close($in);
        ' "$gen_c" "$inject_tmp" "$mod_pref_x" >"$filtered" 2>/dev/null || true
        if [ -s "$filtered" ]; then
          merged="$tmp_dir/gen_inj_${idx}.c"
          if grep -q '^#include' "$gen_c"; then
            awk -v inj="$filtered" '
              /^#include/ { last=NR }
              { lines[NR]=$0 }
              END {
                for (i=1;i<=NR;i++) {
                  print lines[i]
                  if (i==last) {
                    while ((getline l < inj) > 0) print l
                    close(inj)
                  }
                }
              }' "$gen_c" >"$merged" && mv "$merged" "$gen_c"
          else
            cat "$filtered" "$gen_c" >"$merged" && mv "$merged" "$gen_c"
          fi
        fi
      fi
    fi
  fi

  # PLATFORM: MACOS — macOS lacks objcopy (Linux path renames bare → std_<mod>_*
  # in the .o). Without a rename, product links fail on missing std_<mod>_*.
  #
  # Root authority map (do NOT stack two rename strategies on one symbol):
  #   1) rt_preamble may already `#define bare std_<mod>_bare` so the bare C
  #      definition *is* the namespaced object symbol after preprocessing.
  #   2) Linux: objcopy --redefine-sym bare=std_<mod>_bare (post-cc).
  #   3) macOS (this block): thin wrapper `std_<mod>_bare(...){ return bare(...); }`
  #      only when (1) did not already claim the namespaced symbol.
  #
  # Symptom that was wrong: generating (3) for symbols under (1) → host-cc
  # redefinition of `std_heap_alloc_size_zero` (heap/mod.x).
  # G.7: single predicate — skip wrapper iff namespaced form already owned.
  # Linux objcopy path remains the ELF authority; this is the Mach-O twin.
  if ! command -v objcopy >/dev/null 2>&1 && [ -f "$gen_c" ] && [ -s "$gen_c" ]; then
    case "$base_name" in
      mod.x)
        _wrap_leaf=$(basename "$(dirname "$x_path")")
        _wrap_root=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|/.*||')
        case "$_wrap_root" in
          core) _wrap_pref="core_${_wrap_leaf}_" ;;
          *)    _wrap_pref="std_${_wrap_leaf}_" ;;
        esac
        if [ -n "$_wrap_pref" ] && [ "$_wrap_pref" != "_" ]; then
          python3 - "$gen_c" "$_wrap_pref" <<'PYEOF' >>"$gen_c.append_wrappers.c" 2>/dev/null && cat "$gen_c.append_wrappers.c" >>"$gen_c" && rm -f "$gen_c.append_wrappers.c" || true
import re, sys
# PLATFORM: MACOS — thin namespaced wrappers; skip when preamble #define already
# owns pref+name (bare def expands to that symbol). Mirrors Linux "nm already
# has mod_pref → skip objcopy" per-symbol.
gen_c_path, pref = sys.argv[1], sys.argv[2]
with open(gen_c_path, 'r') as f:
    s = f.read()
# Simple identifier #define bare → expansion (rt_preamble product aliases).
_define_re = re.compile(
    r'^#define\s+([A-Za-z_][A-Za-z0-9_]*)\s+([A-Za-z_][A-Za-z0-9_]*)\s*$',
    re.M,
)
defines = {m.group(1): m.group(2) for m in _define_re.finditer(s)}
_func_def_re = re.compile(
    r'^(?P<ret>(?:struct\s+\w+|(?:u?int(?:8|16|32|64)?_t|void|int|size_t|char|float|double|ssize_t|uintptr_t|intptr_t)[\s\*]*))\s+'
    r'(?P<name>[a-z_][a-zA-Z_0-9]*)\s*'
    r'\((?P<args>[^)]*)\)\s*\{',
    re.M
)
def _extract_arg_names(args_str):
    args_str = args_str.strip()
    if args_str == 'void' or args_str == '':
        return ''
    names = []
    for part in args_str.split(','):
        part = part.strip()
        if part == '...':
            names.append('...')
            continue
        part_clean = re.sub(r'\[[^\]]*\]', '', part)
        tokens = part_clean.split()
        if not tokens:
            names.append('')
            continue
        names.append(tokens[-1].lstrip('*'))
    return ', '.join(names)
# Strong defs already present under this module prefix (or any std_/core_).
existing_ns = set()
for fm in _func_def_re.finditer(s):
    n = fm.group('name')
    if n.startswith(pref) or n.startswith(('core_', 'std_', 'xlang_')):
        existing_ns.add(n)
_skip_prefixes = ('core_', 'std_', 'xlang_', '__')
out_lines = []
for fm in _func_def_re.finditer(s):
    fname = fm.group('name')
    if fname.startswith(_skip_prefixes) or fname == 'main':
        continue
    ns = pref + fname
    # Never redefine an existing namespaced body.
    if ns in existing_ns:
        continue
    # rt_preamble may `#define bare product_sym`. After preprocess the bare
    # definition *is* product_sym — emitting another `ns` body redefines it
    # when product_sym == ns (heap: alloc_size_zero → std_heap_alloc_size_zero).
    # When product_sym is some other std_/core_ symbol, bare is not a free
    # link name either; skip inventing pref+fname on top.
    exp = defines.get(fname)
    if exp is not None:
        if exp == ns:
            continue
        if exp.startswith(('std_', 'core_', 'xlang_')):
            continue
    fret = fm.group('ret').strip()
    fargs = fm.group('args').strip()
    farg_names = _extract_arg_names(fargs)
    decl_args = 'void' if (fargs == '' or fargs == 'void') else fargs
    if fret == 'void':
        out_lines.append(f'{fret} {ns}({decl_args}) {{ {fname}({farg_names}); }}')
    else:
        out_lines.append(f'{fret} {ns}({decl_args}) {{ return {fname}({farg_names}); }}')
if out_lines:
    print('/* Namespaced wrappers — macOS twin of Linux objcopy; skip if #define owns ns. */')
    print('\n'.join(out_lines))
PYEOF
        fi
        ;;
    esac
  fi

  if ! cc $CFLAGS -c "$gen_c" -o "$obj" 2>"$tmp_dir/cc_${idx}.log"; then
    echo "xlang_compile_std_module.sh: cc -c failed for $x_path" >&2
    # 显示首个 error
    grep -m1 'error:' "$tmp_dir/cc_${idx}.log" >&2 || cat "$tmp_dir/cc_${idx}.log" >&2
    exit 1
  fi
  if [ -z "$obj_files" ]; then
    obj_files="$obj"
  else
    obj_files="$obj_files $obj"
  fi
  idx=$((idx + 1))
done

# 单文件直接移到输出；多文件 ld -r 合并
if [ "$idx" -eq 1 ]; then
  mv "$obj_files" "$out_o"
else
  # 【Why 根源】ld -r 合并多 .o 为一个可重定位 .o。
  # Linux GNU ld 用 --allow-multiple-definition 兼容 weak / co-emitted 重复定义；
  # macOS Mach-O ld 无此选项，且对 KEEP_C 共发射的 import 强符号（如 core_mem_*
  # 在 heap mod+libc+ops 三 TU）硬失败。PLATFORM: LINUX 走 allow-multiple；
  # PLATFORM: MACOS 在 ld -r 失败后回退 libtool -static（产出 ar，产品链仍接受）。
  LD_R_FLAGS="-r"
  if ld --help 2>&1 | grep -q 'allow-multiple-definition'; then
    LD_R_FLAGS="-r --allow-multiple-definition"
  fi
  if ! ld $LD_R_FLAGS -o "$out_o" $obj_files 2>"$tmp_dir/ld.log"; then
    if command -v libtool >/dev/null 2>&1 \
      && libtool -static -o "$out_o" $obj_files 2>>"$tmp_dir/ld.log"; then
      :
    else
      echo "xlang_compile_std_module.sh: ld -r failed" >&2
      cat "$tmp_dir/ld.log" >&2
      exit 1
    fi
  fi
fi

# 【Why 根源】-x -E 对 std/*/mod.x 当前常产出裸符号 free/open/close 等，链入用户
# exe 后覆盖 libc 同名符号（hello 在 hash_sip_free_c↔free 无限递归 SIGSEGV）。
# 在 .o 落地后把与 libc 冲突的裸符号重命名为 std_<leaf>_*_api，避免污染。
# 与上方 pre-cc 改名双保险：若某路径未走 pre-cc（旧 gen）仍可后处理。
# 真前缀收敛后（codegen 对 entry 正确应用 path lib_name）本段可删。
if command -v nm >/dev/null 2>&1 && command -v objcopy >/dev/null 2>&1 && [ -f "$out_o" ]; then
  leaf=$(basename "$(dirname "$out_o")")
  case "$leaf" in
    ''|.) leaf=$(basename "$out_o" .o) ;;
  esac
  # PLATFORM: SHARED — product prefix for core/* and std/* formal .o after KEEP_C/cc.
  # out: ../core/slice/mod.o → core_slice_*; ../std/env/env.o → std_env_*.
  # Skip symbols already core_*/std_* (co-emitted deps). G.7 complete authority for
  # core.slice length.x: bare len_i32 must become core_slice_len_i32.
  out_rel=$(printf '%s' "$out_o" | sed -e 's|^\.\./||')
  out_root=$(printf '%s' "$out_rel" | sed -e 's|/.*||')
  case "$out_root" in
    core) prod_pref="core_${leaf}_" ;;
    std)  prod_pref="std_${leaf}_" ;;
    *)    prod_pref="" ;;
  esac
  if [ -n "$prod_pref" ] && ! nm "$out_o" 2>/dev/null | grep -q " T ${prod_pref}"; then
    nm "$out_o" 2>/dev/null | awk '/ [TDB] / { print $3 }' | while IFS= read -r sym; do
      [ -n "$sym" ] || continue
      case "$sym" in
        "${prod_pref}"*|_"${prod_pref}"*) continue ;;
        core_*|std_*|_core_*|_std_*) continue ;;
        _Z*|.L*|L0*|__*|_*_c|args_*|ctx_*|io_*|process_*) continue ;;
      esac
      bare="$sym"
      case "$sym" in
        _*) bare="${sym#_}" ;;
      esac
      case "$bare" in
        "${prod_pref}"*|core_*|std_*) continue ;;
      esac
      if [ "$bare" != "$sym" ]; then
        objcopy --redefine-sym "${sym}=_${prod_pref}${bare}" "$out_o" 2>/dev/null || true
      else
        objcopy --redefine-sym "${sym}=${prod_pref}${bare}" "$out_o" 2>/dev/null || true
      fi
    done
  fi
  # PLATFORM: SHARED — core.slice co-emits core_option_* bodies; when both mod.o and
  # option.o are pushed (--allow-multiple-definition) the wrong is_some/unwrap can win
  # (Ubuntu length.x asm exit 4 after i32 path). Localize co-emitted option APIs so
  # option.o remains the global authority; internal get_* still bind locally. G.7.
  if [ "$out_root" = "core" ] && [ "$leaf" = "slice" ]; then
    nm "$out_o" 2>/dev/null | awk '/ [TDB] / { print $3 }' | while IFS= read -r sym; do
      bare="$sym"
      case "$sym" in
        _*) bare="${sym#_}" ;;
      esac
      case "$bare" in
        core_option_*)
          objcopy --localize-symbol="$sym" "$out_o" 2>/dev/null || true
          ;;
      esac
    done
  fi
  for clash in free open close malloc realloc calloc getcwd chdir pipe exit getenv setenv unsetenv getpid getppid waitpid exec; do
    if nm "$out_o" 2>/dev/null | grep -q " T ${clash}$"; then
      # Prefer product export std_<leaf>_<clash> (e.g. std_env_getenv). *_api was a
      # historical clash guard; product import-binding calls std_env_getenv not *_api.
      # PLATFORM: SHARED — Ubuntu asm -o of mod.x often emits bare names; mac may prefix.
      prod="std_${leaf}_${clash}"
      if nm "$out_o" 2>/dev/null | grep -q " T ${prod}$"; then
        objcopy --redefine-sym "${clash}=std_${leaf}_${clash}_api" "$out_o" 2>/dev/null || true
      else
        objcopy --redefine-sym "${clash}=${prod}" "$out_o" 2>/dev/null || true
      fi
    fi
  done
  # PLATFORM: SHARED — env product surface: bare getenv_exists/z/ptr/temp_dir/iter*
  # are not in the libc-clash list above; import calls std_env_*. Complete the rename.
  if [ "$leaf" = "env" ]; then
    for bare in getenv getenv_exists getenv_z getenv_ptr setenv unsetenv temp_dir \
                iter iter_count iter_next args_iter args_iter_count args_iter_next; do
      if nm "$out_o" 2>/dev/null | grep -q " T ${bare}$"; then
        objcopy --redefine-sym "${bare}=std_env_${bare}" "$out_o" 2>/dev/null || true
      fi
      if nm "$out_o" 2>/dev/null | grep -q " T std_env_${bare}_api$"; then
        objcopy --redefine-sym "std_env_${bare}_api=std_env_${bare}" "$out_o" 2>/dev/null || true
      fi
    done
  fi
  # heap import-binding：impl 常产出裸 heap_alloc_c，用户/co-emit 与 http.o 等要
  # std_heap_libc_heap_alloc_c。只要 .o 有 T heap_alloc_c 且缺 std 前缀名就补别名
  # （勿仅依赖本 TU 的 U 引用——单文件 heap.o 落地时往往没有 U）。
  if nm "$out_o" 2>/dev/null | grep -q " T heap_alloc_c$" \
     && ! nm "$out_o" 2>/dev/null | grep -q " T std_heap_libc_heap_alloc_c$"; then
    alias_c="$tmp_dir/heap_alloc_alias.c"
    alias_o="$tmp_dir/heap_alloc_alias.o"
    printf '%s\n' \
      '#include <stddef.h>' \
      '#include <stdint.h>' \
      'extern uint8_t *heap_alloc_c(size_t size);' \
      'uint8_t *std_heap_libc_heap_alloc_c(size_t size) { return heap_alloc_c(size); }' \
      >"$alias_c"
    if cc -fPIE -c "$alias_c" -o "$alias_o" 2>/dev/null; then
      merged="$tmp_dir/heap_merged.o"
      if ld -r -o "$merged" "$out_o" "$alias_o" 2>/dev/null; then
        mv "$merged" "$out_o"
      fi
    fi
  fi
fi

echo "xlang_compile_std_module.sh: OK ($idx files -> $out_o)"
