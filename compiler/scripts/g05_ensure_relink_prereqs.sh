#!/bin/bash
# g05_ensure_relink_prereqs.sh — G-05 100%：依赖齐备（纯 shell，不调用 make）
#
# 职责：
#   1) 加载 g05_relink_env.sh 清单
#   2) 热路径 C 源用 cc 强制重编（对齐历史 ensure 的 -B runtime / glue）
#   3) 检查 G05_OBJS 全部存在；缺失则失败并提示冷启动（Makefile 仅冷启动）
#
# 用法（compiler/ 目录）：
#   sh scripts/g05_ensure_relink_prereqs.sh
#
# 环境：
#   G05_SKIP_HOT_REBUILD=1  跳过热路径 cc 重编（仅检查）
#   G05_CC                  覆盖编译器（默认 cc）
#   XLANG_G05_PREFER_X_O     L2：优先 .x→C(-E)→.o（失败回退 seed；见 analysis/G-02f-L2-x-o-pilot.md）
#                           默认=1（G-02f-437 默认化）；=0 回退纯 seed C 路径
#                           TUs：labi L0+rt 7+L2 thin 17（G-02f-256～436）

set -e
cd "$(dirname "$0")/.."

echo "g05_ensure_relink_prereqs: load env (shell, no make)"
# shellcheck disable=SC2046
eval "$(bash scripts/g05_relink_env.sh)"

# wave940: warm catalog cache once for the whole g05 ensure ladder.
# Without this, every ensure_host_cc_seed_o.sh try-* call re-parses all mk
# files via driver_seed_obj_catalog.sh. On Windows MinGW/Git Bash that is
# ~3min per call × ~15 calls = g05 appears "hung" (no gcc, only bash).
# bootstrap_driver_seed.sh already warms this cache (line 83-97); g05 must
# do the same since it is invoked independently after bootstrap.
# PLATFORM: SHARED — same mk parse on Darwin/Linux/Windows MSYS2.
if [ -z "${XLANG_CATALOG_CACHE_FILE:-}" ] || [ ! -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
  _g05_cat_cache="${TMPDIR:-/tmp}/xlang_g05_catalog_$$.txt"
  if bash scripts/driver_seed_obj_catalog.sh --shell >"${_g05_cat_cache}" \
    2>/tmp/xlang_g05_cat_err_$$.txt; then
    export XLANG_CATALOG_CACHE_FILE="${_g05_cat_cache}"
    echo "g05_ensure_relink_prereqs: catalog cache warm OK (${XLANG_CATALOG_CACHE_FILE})"
  else
    echo "g05_ensure_relink_prereqs: WARN catalog warm failed (try-* will re-expand)" >&2
    cat /tmp/xlang_g05_cat_err_$$.txt 2>/dev/null || true
    rm -f "${_g05_cat_cache}" /tmp/xlang_g05_cat_err_$$.txt
    _g05_cat_cache=""
  fi
  # shellcheck disable=SC2064
  trap 'if [ -n "${_g05_cat_cache:-}" ]; then rm -f "${_g05_cat_cache}" /tmp/xlang_g05_cat_err_$$.txt; fi' EXIT HUP INT TERM
else
  echo "g05_ensure_relink_prereqs: catalog cache reuse OK (${XLANG_CATALOG_CACHE_FILE})"
fi

# Why: Windows MSYS2/MinGW ships gcc only (no cc alias). Honor caller-provided
#      $CC (e.g. CC=gcc exported by Windows build env), then G05_CC override,
#      then fall back to cc for POSIX. Without this, g05 hot-rebuild emits
#      "cc: command not found" on Windows.
CC="${G05_CC:-${CC:-cc}}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
# PLATFORM: MACOS — match macho.x LC_BUILD_VERSION minos 11.0.0 (same authority
# as ensure_host_cc_seed_o.sh / cc_inc_tu.sh). Host-cc refreshes done here (e.g.
# the runtime_asm_io_stubs.o seed-newer rule) otherwise stamp minos=<host SDK>
# and ld warns "newer macOS version than being linked" on every product /
# user-program link. Do not -w swallow; do not raise macho.x minos to 26.0.
case "$(uname -s 2>/dev/null)" in
  Darwin)
    case " $BASE_CFLAGS " in
      *" -mmacosx-version-min="*) ;;
      *) BASE_CFLAGS="$BASE_CFLAGS -mmacosx-version-min=11.0" ;;
    esac
    ;;
esac

# Stage 12.2.1: XLANG_FORBID_HOST_CC gate (no-op when flag unset; zero impact
# on normal builds). When XLANG_FORBID_HOST_CC=1, replaces $CC with a wrapper
# that logs and blocks all host-CC invocations — builds the zero-CC problem map.
# PLATFORM: SHARED.
. "$(dirname "$0")/forbid_host_cc.sh"

# 与 Makefile RUNTIME_DRIVER_NO_C_CFLAGS 一致（runtime.c → runtime_driver_no_c.o）
# Cap residual 数据在 RT_SEED_SLICE_OBJS（g05_relink_env）；runtime 开 XLANG_RT_*_FROM_X。
# 须含 PARSE_DIAG_FROM_X：parse_diag 只在 src/runtime/rt_parse_diag.o，禁止再 merge 进 no_c（否则 Darwin 双符号）。
RUNTIME_DRIVER_NO_C_CFLAGS="-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C -DXLANG_RT_ARENA_BUF_FROM_X -DXLANG_RT_EMIT_STATE_FROM_X -DXLANG_RT_PREAMBLE_FROM_X -DXLANG_RT_STACK_FROM_X -DXLANG_RT_PARSE_DIAG_FROM_X"

if [ ! -f "${G05_BOOTSTRAP:-bootstrap_xlangc}" ] && [ ! -f xlang ] && [ ! -f xlang-c ]; then
  echo "g05_ensure_relink_prereqs: missing bootstrap binary (bootstrap_xlangc/xlang/xlang-c)" >&2
  echo "  cold-start: ./xbuild bootstrap-driver-seed   # preferred (shell; Makefile deleted wave941)" >&2
  exit 1
fi

# Stage 12.2.3: pure-ld partial-merge helper (replaces $CC -r -nostdlib in
# prefer hybrid merges; zero-CC when XLANG_ZERO_CC_LD=1, else $CC -r zero
# regression). PLATFORM: SHARED.
. scripts/pure_ld_shared.sh

# Stage 12.0.5: strip ambient tree PREFER_ASM_O unless ALLOW_TREE (G.7).
# Prefer families re-scope PREFER inside pure_asm subshells. PLATFORM: SHARED.
xlang_strip_tree_prefer_asm_unless_allowed

# --- 热路径：直接 cc -c（不经 make）；G-02e-22：.inc 走 cc_inc_tu ---
g05_cc_c() {
  # $1 = .o  $2 = .c|.inc  [$3...] = extra cflags
  _o="$1"
  _c="$2"
  shift 2
  if [ ! -f "$_c" ]; then
    echo "g05_ensure_relink_prereqs: missing source $_c" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$_o")"
  case "$_c" in
    *.inc)
      echo "g05_ensure: cc_inc_tu $_c → $_o"
      # shellcheck disable=SC2086
      bash scripts/cc_inc_tu.sh "$_c" "$_o" "$@"
      ;;
    *)
      echo "g05_ensure: cc -c $_c → $_o"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS "$@" -c -o "$_o" "$_c"
      ;;
  esac
}

# G-02f-256/257/258 / L2：.x → xlang -backend c -E → cc -c → .o
# Stage 12.0.5：pure_asm_x_to_o is G.7 authority for freestanding .x→.o.
# Prefer-family pure-asm product default (authorized 2026-08-12, peer of
# PREFER_ASM_O_RT / PREFER_ASM_O_LABI):
#   · XLANG_PREFER_ASM_O_G05 defaults to 1 → scoped XLANG_PREFER_ASM_O=1 for
#     pure_asm_x_to_o only (subshell; does NOT leak tree-level PREFER_ASM_O).
#   · reject panic/__error/weak polish fail/rename → fall through -E+$CC.
#   · Escape: XLANG_PREFER_ASM_O_G05=0 → historic -E+$CC. Ambient tree PREFER
#     does NOT re-enable pure-asm unless XLANG_ALLOW_TREE_PREFER_ASM=1.
#   · Ban: tree PREFER_ASM_O=1 product default (hard strip + family=0);
#     pipeline_abi mega pure-asm product skip (Cap residual gap; opaque WEAK
#     surface closed in runtime_driver_abi.from_x.c; hang wall closed 2026-08-12).
# 返回 0 成功；失败不删既有 .o（调用方回退 seed）。
# $1=.x  $2=.o  [$3...]=extra cflags for cc
# 环境：G05_X_O_WEAK=1 时给顶层函数加 __attribute__((weak))
#       （strict_glue 等与 bootstrap_seed_pipeline_filtered 同名符号需 weak，对齐 seed）
# True if OBJ defines SYM as a text symbol (Darwin nm prefixes '_').
# Reject incomplete -E fallbacks that still exit 0 after a silent
# parse-drop of a dest-buffer export (P4bh `break` nest). PLATFORM: SHARED.
g05_obj_defines() {
  _g05_obj="$1"
  _g05_sym="$2"
  # Linux nm: "ADDR T name" or "T name"; Darwin: "ADDR T _name".
  # G05_X_O_WEAK may stamp W rather than T.
  nm -gU "$_g05_obj" 2>/dev/null | grep -E " [TWtw] (_)?${_g05_sym}\$" >/dev/null
}

g05_try_x_to_o() {
  _xsrc="$1"
  _xout="$2"
  shift 2
  _xxlang=""
  if [ -x ./xlang ]; then
    _xxlang=./xlang
  elif [ -x ./xlang-c ]; then
    _xxlang=./xlang-c
  elif [ -x ./bootstrap_xlangc ]; then
    _xxlang=./bootstrap_xlangc
  else
    return 1
  fi
  if [ ! -f "$_xsrc" ]; then
    return 1
  fi
  mkdir -p "$(dirname "$_xout")"
  # Prefer-family pure-asm default via XLANG_PREFER_ASM_O_G05 (default 1).
  # When G05=0: unset ambient PREFER unless ALLOW_TREE (close tree leak).
  # PLATFORM: SHARED · G.7 pure_asm_x_to_o sole authority.
  if (
    if [ "${XLANG_PREFER_ASM_O_G05:-1}" = "1" ]; then
      export XLANG_PREFER_ASM_O=1
    elif [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" != "1" ]; then
      unset XLANG_PREFER_ASM_O
    fi
    pure_asm_x_to_o "$_xout" "$_xsrc"
  ); then
    return 0
  fi
  # Historic: -E → prologue → $CC -c
  # BSD/macOS mktemp 要求 X 串在模板末尾；勿用 XXXXXX.c
  _xtmp=$(mktemp "${TMPDIR:-/tmp}/g05_x.XXXXXX") || return 1
  # 优先默认 -E（Linux 上 -backend c -E 可能 SIGSEGV）；再回退 -backend c -E。
  # Ubuntu 主机偶发 -E SIGSEGV：最多 5 次重试（对齐 prove harness b12bf000）。
  # PLATFORM: SHARED harness
  # shellcheck disable=SC2086
  _e_ok=0
  for _e_try in 1 2 3 4 5; do
    if "$_xxlang" -E "$_xsrc" >"$_xtmp" 2>/dev/null && [ -s "$_xtmp" ]; then
      _e_ok=1
      break
    fi
    : >"$_xtmp"
    if "$_xxlang" -backend c -E "$_xsrc" >"$_xtmp" 2>/dev/null && [ -s "$_xtmp" ]; then
      _e_ok=1
      break
    fi
    : >"$_xtmp"
  done
  if [ "$_e_ok" != "1" ]; then
    rm -f "$_xtmp"
    return 1
  fi
  if [ "${G05_X_O_WEAK:-0}" = "1" ]; then
    # 仅改非 static 的简单返回类型函数定义行（-E 产物形态）
    # G-02f-335/336：含 uint8_t * / char * / int64_t 返回（diag_color_prefix / get_source_len 等）
    perl -i -pe 's/^((?:void|int64_t|int32_t|int|size_t|uint32_t|uint64_t|uint8_t \*|uint8_t|const char \*|char \*))\s+(\w+)\s*\(/XLANG_WEAK $1 $2(/' "$_xtmp" || true
  fi
  # G-02f-458: 前端 *_gen.c .o 的符号重命名
  # 格式：G05_X_O_SYM_RENAME="old1:new1,old2:new2,..."
  # 将 -E 输出中的 .x 函数名重命名为 gen.c 期望的符号名（模块前缀+函数名）
  if [ -n "${G05_X_O_SYM_RENAME:-}" ]; then
    _old_ifs="$IFS"
    IFS=','
    for _pair in $G05_X_O_SYM_RENAME; do
      _old_name="${_pair%%:*}"
      _new_name="${_pair#*:}"
      if [ -n "$_old_name" ] && [ -n "$_new_name" ] && [ "$_old_name" != "$_new_name" ]; then
        perl -i -pe "s/\\b${_old_name}\\b/${_new_name}/g" "$_xtmp" || true
      fi
    done
    IFS="$_old_ifs"
  fi
  # G-02f-332/334：-E 缺 ssize_t / open 原型；前置 POSIX 头，并删掉 -E 里冲突的 libc extern
  {
    echo '/* g05_try_x_to_o prologue (G-02f-332/334 + uio/poll) */'
    echo '#include <stddef.h>'
    echo '#include <stdint.h>'
    echo '#include <sys/types.h>'
    echo '#include <stdlib.h>'
    echo '#include <string.h>'
    echo '#include <stdio.h>'
    # G05_X_O_WEAK perl marks defs XLANG_WEAK; the define authority is this
    # header (PLATFORM: SHARED — Darwin ld + Ubuntu ld.bfd both honor the
    # __attribute__((weak)) branch). P9a stretch_audit was the first lane to
    # reach the -E fallback with weak marking on (PEL always won pure-asm).
    echo '#include <xlang_weak.h>'
    # Cap residual 10.7.2 (slice18): Track L -E may embed CRASH_EVIDENCE snprintf;
    # redirect at compile face (same authority as driver_leaf_x_to_o prologue).
    # PLATFORM: SHARED — Cap header under compiler/include.
    echo '#include <xlang_fmt_cap.h>'
    echo '#undef snprintf'
    echo '#define snprintf xlang_snprintf'
    echo '#ifdef _WIN32'
    # PLATFORM: WINDOWS — twin of ensure_host_cc_seed_o rt-prefer prologue.
    echo '#include "win32_compat.h"'
    echo '#else'
    echo '#include <unistd.h>'
    echo '#include <fcntl.h>'
    echo '#include <errno.h>'
    # PLATFORM: POSIX — -E preamble 内联 xlang_sys_readv/writev/poll 需原型；
    # 下方 sed 会删掉 -E 自带 #include <poll.h> 等，故在 prologue 补齐。
    echo '#include <sys/uio.h>'
    echo '#include <poll.h>'
    # Cap residual 9.1.10: fmt walk *u8 wrappers via xlang_dir_cap.h (no libc opendir).
    echo '#include <xlang_dir_cap.h>'
    echo 'static inline uint8_t *xlang_fmt_opendir(uint8_t *name) {'
    echo '  return name ? (uint8_t *)xlang_dir_open((const char *)(void *)name) : (uint8_t *)0;'
    echo '}'
    echo 'static inline int32_t xlang_fmt_closedir(uint8_t *dirp) {'
    echo '  return dirp ? (int32_t)xlang_dir_close((void *)dirp) : (int32_t)-1;'
    echo '}'
    echo 'static inline int32_t xlang_fmt_access(uint8_t *path, int32_t mode) {'
    echo '  return path ? (int32_t)access((const char *)path, (int)mode) : (int32_t)-1;'
    echo '}'
    echo 'static inline uint8_t *xlang_fmt_readdir_name(uint8_t *dirp) {'
    echo '  char *n;'
    echo '  if (!dirp) return (uint8_t *)0;'
    echo '  n = xlang_dir_readdir_name((void *)dirp);'
    echo '  return (uint8_t *)(void *)n;'
    echo '}'
    echo '#endif'
    # PLATFORM: SHARED — Cap residual 9.7.1: opaque *u8 stream face → fd-handle.
    # Authority: include/xlang_driver_stream_cap.h (handle = fd+1, NULL invalid;
    # std fds 0/1/2 never closed). Write/open/close route through the Cap
    # authorities (xlang_io_write / xlang_io_open_write / xlang_proc_close_fd),
    # so generated TUs carry zero stdio UNDEFs. Signatures stay `uint8_t *` —
    # .x consumers are source-compatible.
    echo '#include "xlang_driver_stream_cap.h"'
    echo 'static inline int32_t xlang_driver_fputs_opaque(uint8_t *s, uint8_t *stream) {'
    echo '  int fd = xlang_driver_handle_to_fd(stream);'
    echo '  if (!s || fd < 0) return -1;'
    echo '  return (int32_t)xlang_io_write(fd, s, strlen((const char *)(void *)s));'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_stdout_ptr(void) {'
    echo '  return xlang_driver_handle_from_fd(1);'
    echo '}'
    echo 'static inline int32_t xlang_driver_fclose_opaque(uint8_t *stream) {'
    echo '  return (int32_t)xlang_driver_handle_close(stream);'
    echo '}'
    echo 'static inline int32_t xlang_driver_fwrite_opaque(uint8_t *data, int32_t len, uint8_t *stream) {'
    echo '  long n;'
    echo '  int fd;'
    echo '  if (!data || len < 0 || !stream) return 1;'
    echo '  if (len == 0) return 0;'
    echo '  fd = xlang_driver_handle_to_fd(stream);'
    echo '  if (fd < 0) return 1;'
    echo '  n = xlang_io_write(fd, data, (size_t)len);'
    echo '  return n == (size_t)len ? 0 : 1;'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_fopen_write_opaque(uint8_t *path) {'
    echo '  int fd;'
    echo '  if (!path) return (uint8_t *)0;'
    echo '  fd = xlang_io_open_write((const char *)(void *)path);'
    echo '  return fd < 0 ? (uint8_t *)0 : xlang_driver_handle_from_fd(fd);'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_stderr_ptr(void) {'
    echo '  return xlang_driver_handle_from_fd(2);'
    echo '}'
    echo 'static inline void xlang_driver_fflush_stdout(void) {'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_fopen_wb_opaque(uint8_t *path) {'
    echo '  int fd;'
    echo '  if (!path) return (uint8_t *)0;'
    echo '  fd = xlang_io_open_write((const char *)(void *)path);'
    echo '  return fd < 0 ? (uint8_t *)0 : xlang_driver_handle_from_fd(fd);'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_fdopen_wb_opaque(int32_t fd) {'
    echo '  if (fd < 0) return (uint8_t *)0;'
    echo '  return xlang_driver_handle_from_fd(fd);'
    echo '}'
    # PLATFORM: SHARED — wave79 Cap residual: libc realpath as opaque *u8 for pure
    # xlang_path_try_realpath_inplace (runtime_pipeline_abi.x). .x must not name char*
    # realpath (labi_path_io clash note); non-POSIX returns null → pure leaves path.
    # POSIX/APPLE: realpath from unistd/stdlib (prologue includes them above).
    echo '#if defined(_POSIX_VERSION) || defined(__APPLE__)'
    echo 'static inline uint8_t *xlang_driver_realpath_opaque(uint8_t *path, uint8_t *resolved) {'
    echo '  char *r;'
    echo '  if (!path || !resolved) return (uint8_t *)0;'
    echo '  r = realpath((const char *)(void *)path, (char *)(void *)resolved);'
    echo '  return (uint8_t *)(void *)r;'
    echo '}'
    echo '#else'
    echo 'static inline uint8_t *xlang_driver_realpath_opaque(uint8_t *path, uint8_t *resolved) {'
    echo '  (void)path; (void)resolved;'
    echo '  return (uint8_t *)0;'
    echo '}'
    echo '#endif'
    # PLATFORM: SHARED — wave84 Cap residual: function address as *u8 for pure
    # pipeline_run_x_thread_fn_ptr / xlang_asm_codegen_elf_o_thread_fn_ptr
    # (runtime_pipeline_abi.x). .x cannot form function-pointer constants (&fn);
    # pure thin surface owns the product names; cast residual stays in this harness
    # (same pattern as stdout_ptr / realpath_opaque). Cold twin under seed #ifndef FROM_X.
    # Match pure .x export: *u8 arg / *u8 return (not void* — gcc conflicts with pure body).
    echo 'extern uint8_t *pipeline_run_x_thread_fn(uint8_t *);'
    echo 'extern uint8_t *xlang_asm_codegen_elf_o_thread_fn(uint8_t *);'
    echo 'static inline uint8_t *xlang_driver_pipeline_run_x_thread_fn_ptr(void) {'
    echo '  return (uint8_t *)(void *)pipeline_run_x_thread_fn;'
    echo '}'
    echo 'static inline uint8_t *xlang_driver_asm_elf_o_thread_fn_ptr(void) {'
    echo '  return (uint8_t *)(void *)xlang_asm_codegen_elf_o_thread_fn;'
    echo '}'
    # Strip -E #include + libc redecls that clash with prologue headers.
    # PLATFORM: SHARED harness — G.7 product authority for libc skip is
    # codegen_is_libc_conflicting_extern_name (codegen.x + seed). After wave30,
    # mkstemp/rename are in that predicate; sed lines below stay as defense for
    # cold/old xlang -E, opendir opaque (intentionally NOT in product skip), and
    # xlang_fmt_*/xlang_driver_* harness helpers defined as static inline above.
    sed -e '/^#include /d' \
        -e '/^extern ssize_t read(/d' \
        -e '/^extern ssize_t write(/d' \
        -e '/^extern int32_t open(/d' \
        -e '/^extern int open(/d' \
        -e '/^extern int32_t fcntl(/d' \
        -e '/^extern int fcntl(/d' \
        -e '/^extern int32_t close(/d' \
        -e '/^extern int close(/d' \
        -e '/^extern uint8_t \* calloc(/d' \
        -e '/^extern uint8_t \* malloc(/d' \
        -e '/^extern void free(/d' \
        -e '/^extern uint8_t \* memcpy(/d' \
        -e '/^extern void \* memcpy(/d' \
        -e '/^extern int32_t memcmp(/d' \
        -e '/^extern int memcmp(/d' \
        -e '/^extern char \* getenv(/d' \
        -e '/^extern uint8_t \* getenv(/d' \
        -e '/^extern char \* getcwd(/d' \
        -e '/^extern uint8_t \* getcwd(/d' \
        -e '/^extern int32_t unlink(/d' \
        -e '/^extern int unlink(/d' \
        -e '/^extern size_t strlen(/d' \
        -e '/^extern int32_t strcmp(/d' \
        -e '/^extern int strcmp(/d' \
        -e '/^extern int32_t strncmp(/d' \
        -e '/^extern int strncmp(/d' \
        -e '/^extern uint8_t \* strstr(/d' \
        -e '/^extern char \* strstr(/d' \
        -e '/^extern uint8_t \* memset(/d' \
        -e '/^extern void \* memset(/d' \
        -e '/^extern int32_t setenv(/d' \
        -e '/^extern int setenv(/d' \
        -e '/^extern uint8_t \* strerror(/d' \
        -e '/^extern char \* strerror(/d' \
        -e '/^extern int32_t system(/d' \
        -e '/^extern int system(/d' \
        -e '/^extern int32_t fputs(/d' \
        -e '/^extern int fputs(/d' \
        -e '/^extern uint8_t \* opendir(/d' \
        -e '/^extern void \* opendir(/d' \
        -e '/^extern DIR \* opendir(/d' \
        -e '/^extern int32_t closedir(/d' \
        -e '/^extern int closedir(/d' \
        -e '/^extern int32_t access(/d' \
        -e '/^extern int access(/d' \
        -e '/^extern uint8_t \* xlang_fmt_opendir(/d' \
        -e '/^extern int32_t xlang_fmt_closedir(/d' \
        -e '/^extern int32_t xlang_fmt_access(/d' \
        -e '/^extern uint8_t \* xlang_fmt_readdir_name(/d' \
        -e '/^extern int32_t xlang_driver_fputs_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_stdout_ptr(/d' \
        -e '/^extern int32_t xlang_driver_fclose_opaque(/d' \
        -e '/^extern int32_t xlang_driver_fwrite_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_fopen_write_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_stderr_ptr(/d' \
        -e '/^extern void xlang_driver_fflush_stdout(/d' \
        -e '/^extern uint8_t \* xlang_driver_fopen_wb_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_fdopen_wb_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_realpath_opaque(/d' \
        -e '/^extern uint8_t \* xlang_driver_pipeline_run_x_thread_fn_ptr(/d' \
        -e '/^extern uint8_t \* xlang_driver_asm_elf_o_thread_fn_ptr(/d' \
        -e '/^extern int32_t mkstemp(/d' \
        -e '/^extern int mkstemp(/d' \
        -e '/^extern int32_t rename(/d' \
        -e '/^extern int rename(/d' \
        "$_xtmp"
  } >"${_xtmp}.full" && mv "${_xtmp}.full" "$_xtmp"
  # shellcheck disable=SC2086
  # -x c：mktemp 无扩展名时 clang 否则不当作 C 源
  if ! $CC $BASE_CFLAGS "$@" -x c -c -o "$_xout" "$_xtmp"; then
    rm -f "$_xtmp"
    return 1
  fi
  rm -f "$_xtmp"
  return 0
}

# G-02f-257：1:1 L2 表项 — $1=.o $2=.x $3=seed.c $4=label
# PREFER_X_O=1 时优先 .x；失败或未设则 seed cc。
g05_ensure_l2_or_seed() {
  _l2_o="$1"
  _l2_x="$2"
  _l2_seed="$3"
  _l2_label="$4"
  if [ ! -f "$_l2_o" ] \
    || { [ -f "$_l2_seed" ] && [ "$_l2_seed" -nt "$_l2_o" ]; } \
    || { [ -f "$_l2_x" ] && [ "$_l2_x" -nt "$_l2_o" ]; }; then
    _l2_done=0
    if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_l2_x" ]; then
      if g05_try_x_to_o "$_l2_x" "$_l2_o"; then
        echo "g05_ensure: $_l2_o ← $_l2_x (G-02f-257 L2 prefer .x: $_l2_label)"
        _l2_done=1
      else
        echo "g05_ensure: L2 prefer .x failed for $_l2_label; fallback seed" >&2
      fi
    fi
    if [ "$_l2_done" = "0" ] && [ -f "$_l2_seed" ]; then
      echo "g05_ensure: cc -c $_l2_seed → $_l2_o ($_l2_label seed)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -c -o "$_l2_o" "$_l2_seed"
    fi
  fi
}

if [ "${G05_SKIP_HOT_REBUILD:-}" != "1" ]; then
  echo "g05_ensure_relink_prereqs: hot rebuild (cc, no make)"
  # Cap 9.1.8 Darwin/Windows relink provider freshness: g05 MAIN_LINK_O carries
  # runtime_asm_io_stubs.o (weak xlang_sys_write/read/writev for rt_entry.x SHARED
  # Cap leaf; freestanding_io strong twin is Linux-x86_64-only). The g05 path does
  # not run build_xlang_asm.sh (its seed-newer rule lives there), so refresh here
  # with the same command; also keeps the 9.5.3 Cap print template current in the
  # product link. Same flags as build_xlang_asm.sh line ~5294.
  # PLATFORM: SHARED compile (slot only linked on MACOS|WINDOWS; Linux rebuild is
  # a harmless SHARED-surface compile validation).
  if [ -f seeds/runtime_asm_io_stubs.from_x.c ] && { [ ! -f runtime_asm_io_stubs.o ] || [ seeds/runtime_asm_io_stubs.from_x.c -nt runtime_asm_io_stubs.o ]; }; then
    echo "g05_ensure: cc seeds/runtime_asm_io_stubs.from_x.c → runtime_asm_io_stubs.o (seed-newer refresh)"
    # shellcheck disable=SC2086
    $CC $BASE_CFLAGS -fPIE -c seeds/runtime_asm_io_stubs.from_x.c -o runtime_asm_io_stubs.o
  fi
  # wave765 G.7: labi multi-slice product PREFER → ensure try-labi-prefer
  # (single body; L0..L9+L8b+L8c + rest FROM_X → cc -r; cold full seed fallback).
  # Leaf = src/runtime_link_abi.o (R1_CORE cold twin). No dual inline hybrid.
  # residual: ~~pipeline_abi/ldpc~~(wave767) · target_cpu (rt multi-slice → wave766).
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    echo "g05_ensure: try-labi-prefer src/runtime_link_abi.o (wave765)"
    XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
      CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
      bash scripts/ensure_host_cc_seed_o.sh try-labi-prefer src/runtime_link_abi.o \
      || echo "g05_ensure: try-labi-prefer failed (non-fatal if unused)" >&2
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; labi prefer residual" >&2
  fi
  # wave766 G.7: rt multi-slice product PREFER → ensure try-rt-prefer
  # (single body; content..dispatch + rest FROM_X → cc -r; RT_SEED_SLICE external;
  # cold full seed + NO_C fallback). Leaf = src/runtime_driver_no_c.o
  # (R1_MAIN_RUNTIME cold twin). No dual inline hybrid.
  # residual: ~~pipeline_abi/ldpc~~(wave767) · target_cpu · pure-ld · physical delete.
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    echo "g05_ensure: try-rt-prefer src/runtime_driver_no_c.o (wave766)"
    XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
      CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
      RUNTIME_DRIVER_NO_C_CFLAGS="$RUNTIME_DRIVER_NO_C_CFLAGS" \
      bash scripts/ensure_host_cc_seed_o.sh try-rt-prefer src/runtime_driver_no_c.o \
      || echo "g05_ensure: try-rt-prefer failed (non-fatal if unused)" >&2
    # 7.4.4 配套基建 (2026-09-10): G05_OBJS also links the five STANDALONE rt
    # seed slices (rt_arena_buf/rt_emit_state/rt_preamble/rt_stack/rt_parse_diag
    # via _RT_SEED_SLICE_OBJS) but nothing in the g05 chain refreshed them —
    # only the asm-strict lane's ensure_rt_seed_slice_objs did. A stale slice
    # survived g05 green and broke the link later (rt_emit_state trap: new seed
    # functions missing until a manual rm+try-heat). Delegate to the existing
    # rt-slice family authority (seed -nt .o → cc -c). PLATFORM: SHARED.
    echo "g05_ensure: rt-slice standalone refresh (G05_OBJS members)"
    bash scripts/ensure_host_cc_seed_o.sh rt-slice \
      || echo "g05_ensure: rt-slice refresh failed (non-fatal if unused)" >&2
    # Same class: driver_x.o compiles from driver_gen.c (gen-x family), but a
    # driver_gen.c regen above never re-triggered the .o in the warm g05 path
    # (2026-09-10 trap: pin gained a helper, gen refreshed, .o stayed old).
    # try-heat dispatches the gen-x ladder (driver_gen.c → driver_x.o).
    echo "g05_ensure: driver_x.o gen-x refresh (driver_gen.c staleness)"
    bash scripts/ensure_host_cc_seed_o.sh try-heat driver_x.o \
      || echo "g05_ensure: driver_x.o refresh failed (non-fatal if unused)" >&2
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; rt prefer residual" >&2
  fi
  # wave767 G.7: pipeline_abi product PREFER → ensure try-pipeline-abi-prefer
  # (single body; full .x WEAK + rest FROM_X → cc -r; cold + USE_X_PIPELINE).
  # Leaf = src/runtime_pipeline_abi.o (R1_EXTRA_CFLAGS cold twin). No dual inline hybrid.
  # residual: target_cpu · other L2 · pure-ld · physical delete.
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    echo "g05_ensure: try-pipeline-abi-prefer src/runtime_pipeline_abi.o (wave767)"
    XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
      CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
      RUNTIME_PIPELINE_ABI_CFLAGS="${RUNTIME_PIPELINE_ABI_CFLAGS:--DXLANG_USE_X_PIPELINE}" \
      bash scripts/ensure_host_cc_seed_o.sh try-pipeline-abi-prefer src/runtime_pipeline_abi.o \
      || echo "g05_ensure: try-pipeline-abi-prefer failed (non-fatal if unused)" >&2
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; pipeline_abi prefer residual" >&2
  fi
  # wave764 G.7: R3_COLD nine product PREFER → ensure try-r3-prefer family
  # (single body wave763/764; full→thin ladder + cold). No dual inline hybrid
  # for rio / rdabi / rdd / simd_* / backend_* (deleted below / here).
  # Membership = catalog R3_COLD_SEED_OBJS (lists = mk; no second .o list).
  # residual: ~~labi/rt/pipeline_abi/ldpc~~ · target_cpu.
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    echo "g05_ensure: r3-prefer-family R3_COLD_SEED_OBJS (wave764)"
    XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
      CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
      bash scripts/ensure_host_cc_seed_o.sh r3-prefer-family \
      || echo "g05_ensure: r3-prefer-family failed (non-fatal if unused)" >&2
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; R3_COLD prefer residual" >&2
  fi
  # wave767 G.7: ldpc product PREFER → ensure try-ldpc-prefer
  # (single body; thin .x WEAK + rest L2_LSP_CTX → cc -r; cold plain seed).
  # Leaf = src/lsp/lsp_diag_pipeline_ctx.o (R1_MISC_BASENAME cold twin).
  # residual: ~~target_cpu~~(wave768) · other L2 · pure-ld · physical delete.
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    echo "g05_ensure: try-ldpc-prefer src/lsp/lsp_diag_pipeline_ctx.o (wave767)"
    XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
      CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
      bash scripts/ensure_host_cc_seed_o.sh try-ldpc-prefer src/lsp/lsp_diag_pipeline_ctx.o \
      || echo "g05_ensure: try-ldpc-prefer failed (non-fatal if unused)" >&2
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; ldpc prefer residual" >&2
  fi
  # wave768 G.7: target_cpu product PREFER → ensure try-target-cpu-prefer
  # (single body; flags.x + rest pure FROM_X → cc -r; cold pure seed).
  # Leaf = src/driver/target_cpu.o (R1_SEED_MAP cold twin). No dual inline hybrid.
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    echo "g05_ensure: try-target-cpu-prefer src/driver/target_cpu.o (wave768)"
    XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
      CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
      bash scripts/ensure_host_cc_seed_o.sh try-target-cpu-prefer src/driver/target_cpu.o \
      || echo "g05_ensure: try-target-cpu-prefer failed (non-fatal if unused)" >&2
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; target_cpu prefer residual" >&2
  fi
  # wave769 G.7: L2 asm three product PREFER → ensure try-l2-asm-prefer
  # (table body; thin .x + rest FROM_X → cc -r; cold ensure_one).
  # Leaves: user_asm_seed_bridge · backend_x86_64_enc_c · asm_backend_compat_stubs.
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    for _l2_asm_o in \
      src/asm/user_asm_seed_bridge.o \
      src/asm/backend_x86_64_enc_c.o \
      src/asm/asm_backend_compat_stubs.o; do
      echo "g05_ensure: try-l2-asm-prefer $_l2_asm_o (wave769)"
      XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
        CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
        bash scripts/ensure_host_cc_seed_o.sh try-l2-asm-prefer "$_l2_asm_o" \
        || echo "g05_ensure: try-l2-asm-prefer failed for $_l2_asm_o (non-fatal if unused)" >&2
    done
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; L2 asm prefer residual" >&2
  fi
  # wave770 G.7: async three product PREFER → ensure try-async-prefer
  # (table body; full .x + rest FROM_X → cc -r; cold ensure_one).
  # Leaves: async_liveness · async_cps_codegen · async_asm_pool.
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    for _async_o in \
      src/async/async_liveness.o \
      src/async/async_cps_codegen.o \
      src/async/async_asm_pool.o; do
      echo "g05_ensure: try-async-prefer $_async_o (wave770)"
      XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
        CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
        bash scripts/ensure_host_cc_seed_o.sh try-async-prefer "$_async_o" \
        || echo "g05_ensure: try-async-prefer failed for $_async_o (non-fatal if unused)" >&2
    done
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; async prefer residual" >&2
  fi
  # wave771 G.7: other L2 four product PREFER → ensure try-other-l2-prefer
  # (table body; thin/full .x + rest FROM_X → cc -r; slc named-weak; cold ensure_one).
  # Leaves: seed_link_compat · strict_glue_stubs · fmt_check_cmd_driver · lsp_diag.
  # residual: physical delete (~~fmt_check_cmd.o dual~~ wave775).
  # PLATFORM: SHARED product daily path · default PREFER=1 (g05 historic).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    for _ol2_o in \
      src/seed_link_compat.o \
      src/runtime_driver_strict_glue_stubs.o \
      src/driver/fmt_check_cmd_driver.o \
      src/lsp/lsp_diag.o; do
      echo "g05_ensure: try-other-l2-prefer $_ol2_o (wave771)"
      XLANG_G05_PREFER_X_O="${XLANG_G05_PREFER_X_O:-1}" \
        CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
        bash scripts/ensure_host_cc_seed_o.sh try-other-l2-prefer "$_ol2_o" \
        || echo "g05_ensure: try-other-l2-prefer failed for $_ol2_o (non-fatal if unused)" >&2
    done
  else
    echo "g05_ensure: missing ensure_host_cc_seed_o.sh; other-l2 prefer residual" >&2
  fi
  # wave304 G.7 8.3.6: pipeline_glue_strict_minimal seed shell retired
  # (0 residual T after wave303; product g05 no longer host-cc or links it).
  # PLATFORM: SHARED freestanding 8.3.6 shell retire.

  # G-02e / wave762 G.7: typeck_f64_bits pure .s via try-r2 (single R2 body).
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    echo "g05_ensure: try-r2 src/typeck/typeck_f64_bits.o (wave762)"
    CC="$CC" CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}" \
      bash scripts/ensure_host_cc_seed_o.sh try-r2 src/typeck/typeck_f64_bits.o \
      || echo "g05_ensure: try-r2 typeck_f64_bits failed (non-fatal if unused)" >&2
  else
    _f64s=""
    case "${G05_UNAME_S:-$(uname -s)}/${G05_UNAME_M:-$(uname -m)}" in
      Linux/x86_64) _f64s=src/typeck/typeck_f64_bits_x86_64.s ;;
      Linux/aarch64) _f64s=src/typeck/typeck_f64_bits_aarch64_elf.s ;;
      Darwin/arm64) _f64s=src/typeck/typeck_f64_bits_arm64.s ;;
      Darwin/x86_64) _f64s=src/typeck/typeck_f64_bits_x86_64.s ;;
    esac
    if [ -n "$_f64s" ] && [ -f "$_f64s" ]; then
      if [ ! -f src/typeck/typeck_f64_bits.o ] || [ "$_f64s" -nt src/typeck/typeck_f64_bits.o ]; then
        echo "g05_ensure: cc -c $_f64s → src/typeck/typeck_f64_bits.o"
        pure_as_compile src/typeck/typeck_f64_bits.o "$_f64s"
      fi
    fi
  fi
  # G-02f-256/257 L2 表：1:1 pure TUs（默认 seed；PREFER_X_O=1 优先 .x）
  g05_ensure_l2_or_seed \
    src/lsp/lsp_diag_pipeline_sizes_nostub.o \
    src/lsp/lsp_diag_pipeline_sizes.x \
    seeds/lsp_diag_pipeline_sizes.from_x.c \
    "sizes_nostub"
  # ~~G-02f-6 / G-02f-257 target_cpu dual hybrid~~ wave768 → try-target-cpu-prefer above
  # ~~R2 async three dual hybrid~~ wave770 → try-async-prefer above
  # wave309 G.7 8.3 structure floor leave: product pure-ld no longer links
  # pipeline_x / filtered / standalone mega. pipeline_glue.c / ast_pool.c /
  # glue_standalone seed permanently absent — always skip (do not gate on
  # deleted paths; dead -f checks hid the honesty message). PLATFORM: SHARED.
  echo "g05_ensure: skip pipeline_x.o host-cc (wave309 product mega retired)"
  echo "g05_ensure: skip pipeline_glue_standalone (wave309 product shell retire)"
  # wave309: Darwin product no longer consumes bootstrap_seed_pipeline_filtered.o.
  if [ -f pipeline_x.o ] && [ "${XLANG_FILTER_PIPELINE_FORCE:-0}" = "1" ]; then
    _filt=build_asm/bootstrap_seed_pipeline_filtered.o
    echo "g05_ensure: $_filt ← filter (FORCE only; product link empty wave309)"
    if ! bash scripts/filter_bootstrap_seed_pipeline_o.sh ensure "$_filt"; then
      echo "g05_ensure: WARN filter $_filt failed (product does not link it)" >&2
    fi
  else
    echo "g05_ensure: skip pipeline filtered (wave309 product mega retired)"
  fi
  # Class-G trio: filter against seed_host partial only (catalog in filter script).
  _partial=build_asm/seed_host/asm_backend_partial.o
  if [ -f "$_partial" ]; then
    for _out in \
      build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o \
      build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o \
      build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o
    do
      # Skip ensure when SRC not yet present (cold partial trees); catalog ensure
      # would try-heat — only call when matching SRC exists (historical g05 gate).
      case "$_out" in
        *user_asm_seed_bridge*) _src=src/asm/user_asm_seed_bridge.o ;;
        *compat_stubs*) _src=src/asm/asm_backend_compat_stubs.o ;;
        *backend_x86_64*) _src=src/asm/backend_x86_64_enc_c.o ;;
        *) _src= ;;
      esac
      if [ -n "$_src" ] && [ -f "$_src" ]; then
        echo "g05_ensure: $_out ← filter_bootstrap_seed_against_partial_o.sh ensure (no make)"
        if ! bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure "$_out"; then
          echo "g05_ensure: WARN filter $_out failed (Darwin USER_ASM dual-def risk)" >&2
        fi
      fi
    done
  fi
  # ~~simd_enc / simd_loop / backend_* dual hybrid~~ wave764 → r3-prefer-family above
  # (R3_COLD catalog; G.7 single body; no second full/thin ladder here).

  # G-02f-10 / G-02f-333：parser_asm_parse_expr_link.o
  # 默认整 seed（SKIP_X）；PREFER_X_O=1 时 .x thin（debug_enabled 门闩）+ seed-rest ld -r
  _pel=seeds/parser_asm_parse_expr_link.from_x.c
  _pel_x=src/asm/parser_asm_parse_expr_link.x
  _pel_o=src/asm/parser_asm_parse_expr_link.o
  if [ -f "$_pel" ]; then
    if [ ! -f "$_pel_o" ] || [ "$_pel" -nt "$_pel_o" ] \
      || { [ -f "$_pel_x" ] && [ "$_pel_x" -nt "$_pel_o" ]; }; then
      _pel_done=0
      if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_pel_x" ]; then
        _pel_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pel_thin.XXXXXX") || true
        _pel_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_pel_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_pel_thin_o" ] && [ -n "$_pel_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_pel_x" "$_pel_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS \
               -DXLANG_L2_PEL_THIN_FROM_X -c -o "$_pel_rest_o" "$_pel" \
          && pure_ld_partial_merge "$_pel_o" "$_pel_thin_o" "$_pel_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_pel_o ← $_pel_x + seed-rest (G-02f-333 L2 hybrid parse_expr_link thin)"
          _pel_done=1
        else
          echo "g05_ensure: L2 hybrid parse_expr_link failed; fallback full seed" >&2
        fi
        rm -f "$_pel_thin_o" "$_pel_rest_o"
      fi
      if [ "$_pel_done" = "0" ]; then
        echo "g05_ensure: $_pel_o ← seed (G-02f-10 SKIP_X)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS -c -o "$_pel_o" "$_pel"
      fi
    fi
  fi
  # G-02f-10 / G-02f-279～319：parser_asm_thin_glue.o ← thin seed（默认整 TU；prefer 时 P1–P7+P9+P10 hybrid）
  # P8 seed_parse：产品仍 NO_SEED_PARSE（parse_into_buf 由 parser_x 提供）；仅 smoke -c，不 ld -r 进产品 glue
  # P9 stretch+suite hybrid；P10 glue tail hybrid（G-02f-319）
  _pthin=seeds/parser_asm_thin_c.from_x.c
  _pthin_p1_seed=seeds/pthin_lex_skip.from_x.c
  # 7.2.1 P1b Route C + B-minus: lex_skip .x bodies (kind/copy/skip walks)
  _pthin_p1b_x=src/asm/pthin_lex_skip.x
  _pthin_p2_seed=seeds/pthin_let_alias.from_x.c
  # 7.2.1 P2b B-minus: let/alias .x bodies (top_level_let + type_alias dest-buffer)
  _pthin_p2b_x=src/asm/pthin_let_alias.x
  _pthin_p3_seed=seeds/pthin_type_ref.from_x.c
  # 7.2.1 P3b/P3c/P3d/P3e Route C: type_ref .x bodies (kind / dyn / TypeKind / vector ident / type-inst mangle / consume_qualified / TYPE_DYN wrap)
  _pthin_p3b_x=src/asm/pthin_type_ref.x
  _pthin_p4p_seed=seeds/pthin_expr_primary.from_x.c
  # 7.2.1 P4b Route C: primary .x bodies (ident spelling / asm-option-bit)
  _pthin_p4pb_x=src/asm/pthin_expr_primary.x
  _pthin_p4u_seed=seeds/pthin_expr_unary.from_x.c
  # 7.2.1 P4ub Route C: unary .x bodies (TOKEN→ExprKind)
  _pthin_p4ub_x=src/asm/pthin_expr_unary.x
  _pthin_p4b_seed=seeds/pthin_expr_binop.from_x.c
  # 7.2.1 P4bb/P4bc/P4bd Route C: binop .x bodies (TOKEN→ExprKind + wrap + parse dest-buffer)
  _pthin_p4bb_x=src/asm/pthin_expr_binop.x
  _pthin_p4as_seed=seeds/pthin_expr_as_suffix.from_x.c
  # 7.2.1 P4as/P4ad Route C: as_suffix .x bodies (TRY_PROPAGATE + EXPR_AS wrap + parse dest-buffer)
  _pthin_p4as_x=src/asm/pthin_expr_as_suffix.x
  _pthin_p4t_seed=seeds/pthin_expr_ternary.from_x.c
  # 7.2.1 P4tb/P4tc Route C: ternary wrap + assign wrap dest-buffer
  _pthin_p4tb_x=src/asm/pthin_expr_ternary.x
  _pthin_p5_seed=seeds/pthin_ctrl.from_x.c
  # 7.2.1 P5b/P5c/P5d/P5e/P5f/P5g Route C: ctrl .x bodies (brace skip / kw /
  # scan_sync / realign / dest-tag / parse_if_expr / match wrap)
  _pthin_p5b_x=src/asm/pthin_ctrl.x
  _pthin_p6_seed=seeds/pthin_fn_block.from_x.c
  # 7.2.1 P6b/P6c/P6d B-minus: fn_block .x bodies (name-match trio + packed/soa + library wrap)
  _pthin_p6b_x=src/asm/pthin_fn_block.x
  _pthin_p7_seed=seeds/pthin_simd.from_x.c
  # 7.2.1 P7b Route C: simd .x bodies (ident pack / callee name fill)
  _pthin_p7b_x=src/asm/pthin_simd.x
  _pthin_p8_seed=seeds/pthin_seed_parse.from_x.c
  _pthin_p9_seed=seeds/pthin_stretch.from_x.c
  # G-02f-318a / 7.2.1 B-minus pilot (RFC §5c): stretch-audit .x thin + lexer-step bridge
  _pthin_p9a_x=src/asm/pthin_stretch_audit.x
  _pthin_p9a_bridge=seeds/parser_asm_lex_step_bridge.from_x.c
  # 7.2.1 Route C productize: stretch lite .x (no bridge; pure scalar tables)
  _pthin_p9b_x=src/asm/pthin_stretch.x
  _pthin_p10_seed=seeds/pthin_glue.from_x.c
  # 7.2.1 P10b B-minus: glue .x bodies (skip_one_function_full walk)
  _pthin_p10b_x=src/asm/pthin_glue.x
  _pthin_p11_seed=seeds/pthin_imports.from_x.c
  # 7.2.1 P11b/P11c/P11d B-minus: imports .x bodies (skip_imports + consume_path/try_skip + collect_imports)
  _pthin_p11b_x=src/asm/pthin_imports.x
  _pthin_p12_seed=seeds/pthin_skip_tl.from_x.c
  # 7.2.1 P12b–P12i B-minus: skip_tl .x bodies (struct/enum/extern + impl header + generic_bound_scan + enum_register + parse_one_extern_skip + parse_one_extern_and_add + skip_name_is_self + self_matches_for)
  _pthin_p12b_x=src/asm/pthin_skip_tl.x
  _pthin_p13_seed=seeds/pthin_try_skip_allow.from_x.c
  # 7.2.1 P13b B-minus: try_skip_allow .x bodies (padding paren walk)
  _pthin_p13b_x=src/asm/pthin_try_skip_allow.x
  _pthin_p14_seed=seeds/pthin_skip_if.from_x.c
  # 7.2.1 P14b/P14c B-minus: skip_if .x bodies (trait/impl + if-core/statement + enum register)
  _pthin_p14b_x=src/asm/pthin_skip_if.x
  _pthin_p15_seed=seeds/pthin_library.from_x.c
  # 7.2.1 P15b B-minus: library .x bodies (library_scan walk)
  _pthin_p15b_x=src/asm/pthin_library.x
  _pthin_p16_seed=seeds/pthin_diag_pipeline.from_x.c
  _pthin_p17_seed=seeds/pthin_diag_late.from_x.c
  # 7.2.1 P17b/P17c B-minus: diag_late .x bodies (after_structs + fail)
  # + G.7 diag_skip_let_const_buf trampoline over P18b into
  _pthin_p17b_x=src/asm/pthin_diag_late.x
  _pthin_p18_seed=seeds/pthin_body_tl.from_x.c
  # 7.2.1 P18b Route C + B-minus: body_tl .x bodies (scalar table + skip walks)
  _pthin_p18b_x=src/asm/pthin_body_tl.x
  _pthin_p19_seed=seeds/pthin_helpers.from_x.c
  # 7.2.1 P19b Route C: helpers .x bodies (kind/copy/pos/match-kw)
  _pthin_p19b_x=src/asm/pthin_helpers.x
  _pthin_p20_seed=seeds/pthin_foundation.from_x.c
  if [ -f "$_pthin" ]; then
    if [ ! -f parser_asm_thin_glue.o ] || [ "$_pthin" -nt parser_asm_thin_glue.o ] \
      || { [ -f "$_pthin_p1_seed" ] && [ "$_pthin_p1_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p1b_x" ] && [ "$_pthin_p1b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p2_seed" ] && [ "$_pthin_p2_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p2b_x" ] && [ "$_pthin_p2b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p3_seed" ] && [ "$_pthin_p3_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p3b_x" ] && [ "$_pthin_p3b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4p_seed" ] && [ "$_pthin_p4p_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4pb_x" ] && [ "$_pthin_p4pb_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4u_seed" ] && [ "$_pthin_p4u_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4ub_x" ] && [ "$_pthin_p4ub_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4b_seed" ] && [ "$_pthin_p4b_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4bb_x" ] && [ "$_pthin_p4bb_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4as_seed" ] && [ "$_pthin_p4as_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4as_x" ] && [ "$_pthin_p4as_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4t_seed" ] && [ "$_pthin_p4t_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p4tb_x" ] && [ "$_pthin_p4tb_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p5_seed" ] && [ "$_pthin_p5_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p5b_x" ] && [ "$_pthin_p5b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p6_seed" ] && [ "$_pthin_p6_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p6b_x" ] && [ "$_pthin_p6b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p7_seed" ] && [ "$_pthin_p7_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p7b_x" ] && [ "$_pthin_p7b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p8_seed" ] && [ "$_pthin_p8_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p9_seed" ] && [ "$_pthin_p9_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p9a_x" ] && [ "$_pthin_p9a_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p9a_bridge" ] && [ "$_pthin_p9a_bridge" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p9b_x" ] && [ "$_pthin_p9b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p10_seed" ] && [ "$_pthin_p10_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p10b_x" ] && [ "$_pthin_p10b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p11_seed" ] && [ "$_pthin_p11_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p11b_x" ] && [ "$_pthin_p11b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p12_seed" ] && [ "$_pthin_p12_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p12b_x" ] && [ "$_pthin_p12b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p13_seed" ] && [ "$_pthin_p13_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p13b_x" ] && [ "$_pthin_p13b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p14_seed" ] && [ "$_pthin_p14_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p14b_x" ] && [ "$_pthin_p14b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p15_seed" ] && [ "$_pthin_p15_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p15b_x" ] && [ "$_pthin_p15b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p16_seed" ] && [ "$_pthin_p16_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p17_seed" ] && [ "$_pthin_p17_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p17b_x" ] && [ "$_pthin_p17b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p18_seed" ] && [ "$_pthin_p18_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p18b_x" ] && [ "$_pthin_p18b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p19_seed" ] && [ "$_pthin_p19_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p19b_x" ] && [ "$_pthin_p19b_x" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f "$_pthin_p20_seed" ] && [ "$_pthin_p20_seed" -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_glue_tail_slice.inc ] && [ seeds/parser_asm/parser_asm_glue_tail_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_library_wrap_slice.inc ] && [ seeds/parser_asm/parser_asm_library_wrap_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_body_tl_slice.inc ] && [ seeds/parser_asm/parser_asm_body_tl_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_imports_slice.inc ] && [ seeds/parser_asm/parser_asm_imports_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_skip_tl_slice.inc ] && [ seeds/parser_asm/parser_asm_skip_tl_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_helpers_slice.inc ] && [ seeds/parser_asm/parser_asm_helpers_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_lex_skip_slice.inc ] && [ seeds/parser_asm/parser_asm_lex_skip_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_foundation_slice.inc ] && [ seeds/parser_asm/parser_asm_foundation_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_primary_slice.inc ] && [ seeds/parser_asm/parser_asm_primary_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_finish_struct_lit_slice.inc ] && [ seeds/parser_asm/parser_asm_finish_struct_lit_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_diag_pipeline_slice.inc ] && [ seeds/parser_asm/parser_asm_diag_pipeline_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_diag_late_slice.inc ] && [ seeds/parser_asm/parser_asm_diag_late_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_try_skip_allow_slice.inc ] && [ seeds/parser_asm/parser_asm_try_skip_allow_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_skip_if_slice.inc ] && [ seeds/parser_asm/parser_asm_skip_if_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -f seeds/parser_asm/parser_asm_match_subject_slice.inc ] && [ seeds/parser_asm/parser_asm_match_subject_slice.inc -nt parser_asm_thin_glue.o ]; } \
      || { [ -n "$(find seeds/parser_asm/ -name '*.inc' -newer parser_asm_thin_glue.o -print -quit 2>/dev/null)" ]; }; then
      # PLATFORM: SHARED — monothin #includes the .inc files above; hybrid pthin_*
      # .c mtimes alone miss glue_tail/library_wrap edits (Ubuntu UNDEF after M2 re-pin).
      _pthin_done=0
      if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && { [ -f "$_pthin_p1_seed" ] || [ -f "$_pthin_p2_seed" ] || [ -f "$_pthin_p3_seed" ] || [ -f "$_pthin_p4p_seed" ] || [ -f "$_pthin_p4u_seed" ] || [ -f "$_pthin_p4b_seed" ] || [ -f "$_pthin_p4as_seed" ] || [ -f "$_pthin_p4t_seed" ] || [ -f "$_pthin_p5_seed" ] || [ -f "$_pthin_p6_seed" ] || [ -f "$_pthin_p7_seed" ] || [ -f "$_pthin_p9_seed" ] || [ -f "$_pthin_p10_seed" ] || [ -f "$_pthin_p11_seed" ] || [ -f "$_pthin_p12_seed" ] || [ -f "$_pthin_p13_seed" ] || [ -f "$_pthin_p14_seed" ] || [ -f "$_pthin_p15_seed" ] || [ -f "$_pthin_p16_seed" ] || [ -f "$_pthin_p17_seed" ] || [ -f "$_pthin_p18_seed" ] || [ -f "$_pthin_p19_seed" ] || [ -f "$_pthin_p20_seed" ]; }; then
        _pthin_p1_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p1.XXXXXX") || true
        _pthin_p1b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p1b_thin.XXXXXX") || true
        _pthin_p2_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p2.XXXXXX") || true
        _pthin_p2b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p2b_thin.XXXXXX") || true
        _pthin_p3_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p3.XXXXXX") || true
        _pthin_p3b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p3b_thin.XXXXXX") || true
        _pthin_p4p_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4p.XXXXXX") || true
        _pthin_p4pb_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4pb_thin.XXXXXX") || true
        _pthin_p4u_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4u.XXXXXX") || true
        _pthin_p4ub_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4ub.XXXXXX") || true
        _pthin_p4b_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4b.XXXXXX") || true
        _pthin_p4bb_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4bb.XXXXXX") || true
        _pthin_p4as_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4as.XXXXXX") || true
        _pthin_p4asb_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4asb.XXXXXX") || true
        _pthin_p4t_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4t.XXXXXX") || true
        _pthin_p4tb_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p4tb.XXXXXX") || true
        _pthin_p5_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p5.XXXXXX") || true
        _pthin_p5b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p5b_thin.XXXXXX") || true
        _pthin_p6_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p6.XXXXXX") || true
        _pthin_p6b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p6b_thin.XXXXXX") || true
        _pthin_p7_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p7.XXXXXX") || true
        _pthin_p7b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p7b_thin.XXXXXX") || true
        _pthin_p9_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p9.XXXXXX") || true
        _pthin_p9a_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p9a_thin.XXXXXX") || true
        _pthin_p9a_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p9a.XXXXXX") || true
        _pthin_p9b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p9b_thin.XXXXXX") || true
        _pthin_p10_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p10.XXXXXX") || true
        _pthin_p10b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p10b_thin.XXXXXX") || true
        _pthin_p11_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p11.XXXXXX") || true
        _pthin_p11b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p11b_thin.XXXXXX") || true
        _pthin_p12_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p12.XXXXXX") || true
        _pthin_p12b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p12b_thin.XXXXXX") || true
        _pthin_p13_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p13.XXXXXX") || true
        _pthin_p13b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p13b_thin.XXXXXX") || true
        _pthin_p14_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p14.XXXXXX") || true
        _pthin_p14b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p14b_thin.XXXXXX") || true
        _pthin_p15_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p15.XXXXXX") || true
        _pthin_p15b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p15b_thin.XXXXXX") || true
        _pthin_p16_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p16.XXXXXX") || true
        _pthin_p17_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p17.XXXXXX") || true
        _pthin_p17b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p17b_thin.XXXXXX") || true
        _pthin_p18_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p18.XXXXXX") || true
        _pthin_p18b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p18b_thin.XXXXXX") || true
        _pthin_p19_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p19.XXXXXX") || true
        _pthin_p19b_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p19b_thin.XXXXXX") || true
        _pthin_p20_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p20.XXXXXX") || true
        _pthin_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_rest.XXXXXX") || true
        _pthin_p1_ok=0
        _pthin_p1b_ok=0
        _pthin_p2_ok=0
        _pthin_p2b_ok=0
        _pthin_p3_ok=0
        _pthin_p3b_ok=0
        _pthin_p4p_ok=0
        _pthin_p4pb_ok=0
        _pthin_p4u_ok=0
        _pthin_p4ub_ok=0
        _pthin_p4b_ok=0
        _pthin_p4bb_ok=0
        _pthin_p4as_ok=0
        _pthin_p4asb_ok=0
        _pthin_p4t_ok=0
        _pthin_p4tb_ok=0
        _pthin_p5_ok=0
        _pthin_p5b_ok=0
        _pthin_p6_ok=0
        _pthin_p6b_ok=0
        _pthin_p7_ok=0
        _pthin_p7b_ok=0
        _pthin_p9_ok=0
        _pthin_p9a_ok=0
        _pthin_p9a_audit_ok=0
        _pthin_p9b_ok=0
        _pthin_p10_ok=0
        _pthin_p10b_ok=0
        _pthin_p11_ok=0
        _pthin_p11b_ok=0
        _pthin_p12_ok=0
        _pthin_p12b_ok=0
        _pthin_p13_ok=0
        _pthin_p13b_ok=0
        _pthin_p14_ok=0
        _pthin_p14b_ok=0
        _pthin_p15_ok=0
        _pthin_p15b_ok=0
        _pthin_p16_ok=0
        _pthin_p17_ok=0
        _pthin_p17b_ok=0
        _pthin_p18_ok=0
        _pthin_p18b_ok=0
        _pthin_p19_ok=0
        _pthin_p19b_ok=0
        _pthin_p20_ok=0
        _pthin_rest_defs="-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE"
        # P1 C is compiled after P9a so P1b BODIES_FROM_X can require the
        # lexer-step bridge (skip_balanced U symbols). See P1b block below.
        # PLATFORM: SHARED — 7.2.1 P2b/P2c/P2d B-minus (2026-09-16).
        # pthin_let_alias.x holds dest-buffer parse_one_top_level_let and
        # parse_one_type_alias (P9a peek/step; P9a is linked later into
        # the same thin_glue, same as P6e/P7d/P4ud). BODIES is a separate
        # define so a missing parse_x keeps the C parse twins without
        # dropping the P2 seed TU. COND is a further separate define
        # (P6e PARSE_LAYOUT pattern) so a missing parse_cond_expr_x keeps
        # the C cond twin without dropping P2b. BRACKET is a further
        # separate define so a missing body_let_bracket_x keeps the C
        # bracket twin without dropping P2b/P2c. Cold: no define, full .inc.
        _pthin_p2_extra=""
        if [ -n "$_pthin_p2b_thin_o" ] && [ -f "$_pthin_p2b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p2b_x" "$_pthin_p2b_thin_o" \
            && g05_obj_defines "$_pthin_p2b_thin_o" "parser_asm_parse_one_top_level_let_x_into_c" \
            && g05_obj_defines "$_pthin_p2b_thin_o" "parser_asm_parse_one_type_alias_x_into_c"; then
            _pthin_p2b_ok=1
            _pthin_p2_extra="-DXLANG_PTHIN_LET_ALIAS_BODIES_FROM_X"
            if g05_obj_defines "$_pthin_p2b_thin_o" "parser_asm_parse_cond_expr_x_into_c"; then
              _pthin_p2_extra="$_pthin_p2_extra -DXLANG_PTHIN_LET_ALIAS_COND_FROM_X"
              if g05_obj_defines "$_pthin_p2b_thin_o" "parser_asm_parse_body_let_bracket_compound_init_ref_x_into_c"; then
                _pthin_p2_extra="$_pthin_p2_extra -DXLANG_PTHIN_LET_ALIAS_BRACKET_FROM_X"
                echo "g05_ensure: P2b/P2c/P2d let/alias bodies ← $_pthin_p2b_x (7.2.1 B-minus)"
              else
                echo "g05_ensure: P2b/P2c let/alias bodies ← $_pthin_p2b_x (P2d body_let_bracket C twin)"
              fi
            else
              echo "g05_ensure: P2b let/alias bodies ← $_pthin_p2b_x (P2c parse_cond_expr C twin)"
            fi
          else
            echo "g05_ensure: P2b let/alias .x thin failed or missing parse_x; P2 C twins stay full" >&2
          fi
        fi
        if [ -n "$_pthin_p2_o" ] && [ -f "$_pthin_p2_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p2_extra -c -o "$_pthin_p2_o" "$_pthin_p2_seed"; then
            _pthin_p2_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_LET_ALIAS_FROM_X"
            echo "g05_ensure: P2 let/alias ← $_pthin_p2_seed (G-02f-279 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P3b/P3c/P3d/P3e/P3g/P3h/P3i/P3j/P3k/P3l Route C (2026-09-13/15/16).
        # pthin_type_ref.x holds kind / dyn / builtin TypeKind / vector ident
        # plus type-inst mangle dest-buffer, consume_qualified / angle close,
        # TYPE_DYN wrap dest-buffer, P3g postfix array/slice dest-buffer,
        # P3h prefix `[N]T` / `[]T` dest-buffer, P3i type-position
        # `function(...): Ret` dest-buffer, P3j prefix `*T` dest-buffer,
        # P3k IDENT `Linear(T)` dest-buffer, P3l builtin vec-token
        # dest-buffer, P3m alloc_vector_type_ref, P3n builtin scalar tokens,
        # P3o IDENT named / dyn / impl peel dest-buffer, P3p IDENT
        # generic `<T,U>` type-arg dest-buffer, P3q IDENT vector
        # spelling consume dest-buffer, P3r parse_type_ref_impl
        # dispatcher dest-buffer (ptr shim still C; P3f ban stays),
        # and P3s alloc_pointee dest-buffer (C holds name[256];
        # IDENT consume_qualified stays on the published C face).
        # Runs before P3 C so BODIES_FROM_X skips the portable .inc region.
        # POSTFIX / PREFIX / FN / STAR / LINEAR / VEC / ALLOC_VEC / SCALAR / NAMED / GENERIC / IDENT_VEC / IMPL / POINTEE are separate defines (P6e PARSE_LAYOUT / P2c COND)
        # so a missing postfix_x / prefix_x / fn_x / star_x / linear_x / vec_x / alloc_x / scalar_x / named_x / generic_x / ident_vec_x / impl_x / pointee_x keeps that C twin without dropping
        # P3b–P3e. No lexer-step bridge. Cold: no define, full .inc.
        _pthin_p3_extra=""
        if [ -n "$_pthin_p3b_thin_o" ] && [ -f "$_pthin_p3b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p3b_x" "$_pthin_p3b_thin_o" \
            && g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_append_type_inst_mangle_into_c"; then
            _pthin_p3b_ok=1
            _pthin_p3_extra="-DXLANG_PTHIN_TYPE_REF_BODIES_FROM_X"
            _pthin_p3_lane="P3b/P3c/P3d/P3e"
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_postfix_slice_x_into_c" \
              && g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_postfix_array_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_POSTFIX_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3g"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_prefix_array_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_PREFIX_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3h"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_fn_type_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_FN_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3i"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_star_type_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_STAR_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3j"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_linear_type_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_LINEAR_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3k"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_builtin_vec_type_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_VEC_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3l"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_alloc_vector_type_ref_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_ALLOC_VEC_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3m"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_builtin_scalar_type_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_SCALAR_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3n"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_peel_dyn_impl_prefix_x_into_c" \
              && g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_named_type_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_NAMED_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3o"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_named_generic_args_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_GENERIC_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3p"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_vector_type_ref_from_ident_spelling_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_IDENT_VEC_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3q"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_type_ref_impl_x_into_c" \
              && g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_parse_type_ref_impl_ident_x"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_IMPL_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3r"
            fi
            if g05_obj_defines "$_pthin_p3b_thin_o" "parser_asm_alloc_pointee_type_ref_x_into_c"; then
              _pthin_p3_extra="$_pthin_p3_extra -DXLANG_PTHIN_TYPE_REF_POINTEE_FROM_X"
              _pthin_p3_lane="$_pthin_p3_lane/P3s"
            fi
            echo "g05_ensure: ${_pthin_p3_lane} type_ref bodies ← $_pthin_p3b_x (7.2.1 Route C)"
          else
            echo "g05_ensure: P3b type_ref .x thin failed or missing mangle_into; P3 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p3_o" ] && [ -f "$_pthin_p3_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p3_extra -c -o "$_pthin_p3_o" "$_pthin_p3_seed"; then
            _pthin_p3_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_TYPE_REF_FROM_X"
            echo "g05_ensure: P3 type_ref ← $_pthin_p3_seed (G-02f-280 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P4b/P4be/P4bf/P4bg/P4bh/P4bi/P4bm/P4bn/P4bo/P4bp Route C (2026-09-13/15/16).
        # pthin_expr_primary.x holds IDENT spelling probes, the asm!
        # options bit table, suffix_loop, IDENT/INT heads, P4bh
        # remaining parse_primary dest-buffer, P4bi
        # parse_struct_lit_fields dest-buffer, P4bm STRING decode
        # dest-buffer (append_byte stays C), P4bn finish_from_type_ident
        # dest-buffer (C holds name[256]), P4bo parse_asm_bang
        # dest-buffer (C holds tmpl[256]+regs[128]), P4bp parse_unsafe
        # dest-buffer, P4bq lbrace_looks_like_block / empty_ident_braces
        # dest-buffer (C trampoline passes struct_field_value_depth), and
        # P4br ident_pre_dispatch dest-buffer (C holds tmpl[256]+regs[128]).
        # P4be completed TOKEN/writer
        # pins so `-E` typeck of suffix_loop passes (was XT001 undeclared
        # names). P4bf publishes next_lex from the C trampoline (C-twin
        # stop contract) so IDENT callers do not re-parse `mod.fn(...)`
        # until RSS blows up. P4bg dispatches ident_x_into_c (zeros THEN
        # set_var_name so arena zeros do not wipe var_name_len). P4bh
        # dest-buffers remaining primary arms (STRING/RETURN/PANIC/paren/
        # array/LBRACE); MATCH/AT stay C ptr shims. P4bi dest-buffers
        # parse_struct_lit_fields (C trampoline holds name[256]). Incomplete
        # -E that still exits 0 without parse_struct_lit_fields_x falls
        # back to the C twin (same class as P5i g05_obj_defines).
        # Cold: no define, full .inc.
        # P3c mangle trampoline in primary.inc needs TYPE_REF_BODIES too.
        _pthin_p4p_extra=""
        if [ -n "$_pthin_p4pb_thin_o" ] && [ -f "$_pthin_p4pb_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p4pb_x" "$_pthin_p4pb_thin_o" \
            && g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_parse_primary_x_into_c" \
            && g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_parse_struct_lit_fields_x_into_c"; then
            _pthin_p4pb_ok=1
            _pthin_p4p_extra="-DXLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X"
            if g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_parse_anonymous_struct_lit_x_into_c"; then
              _pthin_p4p_extra="$_pthin_p4p_extra -DXLANG_PTHIN_EXPR_PRIMARY_ANON_STRUCT_FROM_X"
            fi
            if g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_string_lit_decode_span_x_into_c"; then
              _pthin_p4p_extra="$_pthin_p4p_extra -DXLANG_PTHIN_EXPR_PRIMARY_STRING_DECODE_FROM_X"
            fi
            if g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_finish_struct_lit_from_type_ident_x_into_c"; then
              _pthin_p4p_extra="$_pthin_p4p_extra -DXLANG_PTHIN_EXPR_PRIMARY_FINISH_TYPE_IDENT_FROM_X"
            fi
            if g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_primary_parse_asm_bang_x_into_c"; then
              _pthin_p4p_extra="$_pthin_p4p_extra -DXLANG_PTHIN_EXPR_PRIMARY_ASM_BANG_FROM_X"
            fi
            if g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_primary_parse_unsafe_x_into_c"; then
              _pthin_p4p_extra="$_pthin_p4p_extra -DXLANG_PTHIN_EXPR_PRIMARY_UNSAFE_FROM_X"
              if g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_primary_lbrace_looks_like_block_x_into_c" \
                && g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_primary_empty_ident_braces_x_into_c"; then
                _pthin_p4p_extra="$_pthin_p4p_extra -DXLANG_PTHIN_EXPR_PRIMARY_LBRACE_LOOKAHEAD_FROM_X"
                if g05_obj_defines "$_pthin_p4pb_thin_o" "parser_asm_ident_pre_dispatch_x_into_c"; then
                  _pthin_p4p_extra="$_pthin_p4p_extra -DXLANG_PTHIN_EXPR_PRIMARY_IDENT_PRE_DISPATCH_FROM_X"
                  echo "g05_ensure: P4b–P4bi/P4bj/P4bm/P4bn/P4bo/P4bp/P4bq/P4br primary + anon-struct + STRING decode + finish_type_ident + asm_bang + unsafe + lbrace lookahead + ident_pre_dispatch ← $_pthin_p4pb_x"
                else
                  echo "g05_ensure: P4b–P4bi/P4bj/P4bm/P4bn/P4bo/P4bp/P4bq primary + anon-struct + STRING decode + finish_type_ident + asm_bang + unsafe + lbrace lookahead ← $_pthin_p4pb_x (P4br ident_pre_dispatch C twin)"
                fi
              else
                echo "g05_ensure: P4b–P4bi/P4bj/P4bm/P4bn/P4bo/P4bp primary + anon-struct + STRING decode + finish_type_ident + asm_bang + unsafe ← $_pthin_p4pb_x (P4bq lbrace C twin)"
              fi
            else
              echo "g05_ensure: P4b/P4be/P4bf/P4bg/P4bh/P4bi/P4bj/P4bm/P4bn/P4bo primary bodies ← $_pthin_p4pb_x (7.2.1 Route C; P4bp unsafe C twin)"
            fi
          else
            echo "g05_ensure: P4b primary .x thin failed or missing parse_primary/struct_lit_fields dest-buffer; P4 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p4p_o" ] && [ -f "$_pthin_p4p_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p4p_extra $_pthin_p3_extra -c -o "$_pthin_p4p_o" "$_pthin_p4p_seed"; then
            _pthin_p4p_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_EXPR_PRIMARY_FROM_X"
            echo "g05_ensure: P4 primary ← $_pthin_p4p_seed (G-02f-282 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P4ub/P4uc/P4ud Route C (2026-09-13/15).
        # pthin_expr_unary.x holds TOKEN→ExprKind + wrap dest-buffer +
        # parse_unary dest-buffer (P9a peek/step; primary ptr shim).
        # Runs before P4u C so BODIES_FROM_X skips the portable .inc
        # region. No lexer-step bridge. Cold: no define, full .inc.
        _pthin_p4u_extra=""
        if [ -n "$_pthin_p4ub_thin_o" ] && [ -f "$_pthin_p4ub_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p4ub_x" "$_pthin_p4ub_thin_o"; then
            _pthin_p4ub_ok=1
            _pthin_p4u_extra="-DXLANG_PTHIN_EXPR_UNARY_BODIES_FROM_X"
            echo "g05_ensure: P4ub/P4uc/P4ud unary bodies ← $_pthin_p4ub_x (7.2.1 Route C)"
          else
            echo "g05_ensure: P4ub unary .x thin failed; P4u C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p4u_o" ] && [ -f "$_pthin_p4u_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p4u_extra -c -o "$_pthin_p4u_o" "$_pthin_p4u_seed"; then
            _pthin_p4u_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_EXPR_UNARY_FROM_X"
            echo "g05_ensure: P4 unary ← $_pthin_p4u_seed (G-02f-283 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P4bb/P4bc/P4bd Route C (2026-09-13/15).
        # pthin_expr_binop.x holds TOKEN→ExprKind + wrap + parse dest-buffer.
        # Runs before P4b C so BODIES_FROM_X skips the portable .inc
        # region. No lexer-step bridge. Cold: no define, full .inc.
        # Setter pipeline_expr_set_binop_operands_c lives in the P4b
        # seed (inject-only pabi does not pick up new rest symbols).
        _pthin_p4b_extra=""
        if [ -n "$_pthin_p4bb_thin_o" ] && [ -f "$_pthin_p4bb_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p4bb_x" "$_pthin_p4bb_thin_o"; then
            _pthin_p4bb_ok=1
            _pthin_p4b_extra="-DXLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X"
            echo "g05_ensure: P4bb/P4bc/P4bd binop bodies ← $_pthin_p4bb_x (7.2.1 Route C)"
          else
            echo "g05_ensure: P4bb binop .x thin failed; P4b C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p4b_o" ] && [ -f "$_pthin_p4b_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p4b_extra -c -o "$_pthin_p4b_o" "$_pthin_p4b_seed"; then
            _pthin_p4b_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_EXPR_BINOP_FROM_X"
            echo "g05_ensure: P4 binop ← $_pthin_p4b_seed (G-02f-284 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P4as/P4ad Route C (2026-09-15/16).
        # pthin_expr_as_suffix.x holds TRY_PROPAGATE + EXPR_AS wrap dest-buffer
        # plus parse dest-buffer (P9a peek/step; type_ref ptr shim in primary).
        # Runs before P4as C so BODIES_FROM_X skips the portable wrap twins
        # and the parse body. set_unary lives in the P4u seed (G.7 unary
        # operand slot; do not FORCE pabi mega). set_as lives in this seed.
        # Cold: no define, full .inc.
        _pthin_p4as_extra=""
        if [ -n "$_pthin_p4asb_thin_o" ] && [ -f "$_pthin_p4as_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p4as_x" "$_pthin_p4asb_thin_o"; then
            _pthin_p4asb_ok=1
            _pthin_p4as_extra="-DXLANG_PTHIN_EXPR_AS_SUFFIX_BODIES_FROM_X"
            echo "g05_ensure: P4as/P4ad as_suffix wrap+parse ← $_pthin_p4as_x (7.2.1 Route C)"
          else
            echo "g05_ensure: P4as as_suffix .x thin failed; P4as C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p4as_o" ] && [ -f "$_pthin_p4as_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p4as_extra -c -o "$_pthin_p4as_o" "$_pthin_p4as_seed"; then
            _pthin_p4as_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_EXPR_AS_SUFFIX_FROM_X"
            echo "g05_ensure: P4 as_suffix ← $_pthin_p4as_seed (G-02f-285 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P4tb/P4tc/P4td/P4te (2026-09-16).
        # pthin_expr_ternary.x holds EXPR_TERNARY wrap + assign wrap
        # dest-buffer + parse_ternary dest-buffer + parse_assign
        # dest-buffer. Runs before P4t C so BODIES_FROM_X skips the
        # portable wrap twins and the parse bodies. No lexer-step
        # bridge. set_if lives in the P5 seed (G.7 if_* slots);
        # set_binop lives in the P4bc seed (G.7 left/right slots; do
        # not FORCE pabi mega; do not extend P4bc wrap with line/col).
        # Cold: no define, full .inc.
        _pthin_p4t_extra=""
        if [ -n "$_pthin_p4tb_thin_o" ] && [ -f "$_pthin_p4tb_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p4tb_x" "$_pthin_p4tb_thin_o"; then
            _pthin_p4tb_ok=1
            _pthin_p4t_extra="-DXLANG_PTHIN_EXPR_TERNARY_BODIES_FROM_X"
            echo "g05_ensure: P4tb/P4tc/P4td/P4te ternary wrap+parse ← $_pthin_p4tb_x (7.2.1 Route C)"
          else
            echo "g05_ensure: P4tb ternary .x thin failed; P4t C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p4t_o" ] && [ -f "$_pthin_p4t_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p4t_extra -c -o "$_pthin_p4t_o" "$_pthin_p4t_seed"; then
            _pthin_p4t_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_EXPR_TERNARY_FROM_X"
            echo "g05_ensure: P4 ternary ← $_pthin_p4t_seed (G-02f-285 seed slice)"
          fi
        fi
        # P5 C is compiled after P9a (P5d realign .x calls the bridge
        # peek family). See the P5b/P5c/P5d block below.
        # PLATFORM: SHARED — 7.2.1 P6b/P6c/P6d/P6e/P6f/P6g/P6h B-minus
        # (2026-09-15 / 2026-09-16). pthin_fn_block.x holds the three
        # struct-layout name matchers, packed/soa modifier predicates,
        # library-shape wrap, parse_struct_record_layout dest-buffer
        # (P9a peek/step; P9a is linked later into the same thin_glue,
        # same as P7d/P4ud), block_from_res dest-buffer (P6f),
        # library remaining compositor dest-buffer (P6g), and
        # one_function_buf header dest-buffer (P6h).
        # PARSE_LAYOUT is a separate define so a missing parse_x keeps
        # the C parse twin without dropping P6b/P6c/P6d.
        # BLOCK_FROM_RES is an independent sibling after PARSE_LAYOUT
        # so a missing fill_x keeps the C twin without dropping P6e.
        # LIBRARY is an independent sibling after BLOCK_FROM_RES so a
        # missing finish_x keeps the C twin without dropping P6f.
        # ONEFUNC_BUF_HDR is an independent sibling after LIBRARY so a
        # missing header_x keeps the C twin without dropping P6g.
        # Cold: no define, full .inc.
        _pthin_p6_extra=""
        if [ -n "$_pthin_p6b_thin_o" ] && [ -f "$_pthin_p6b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p6b_x" "$_pthin_p6b_thin_o" \
            && g05_obj_defines "$_pthin_p6b_thin_o" "parser_asm_struct_layout_first_name_match_idx_c"; then
            _pthin_p6b_ok=1
            _pthin_p6_extra="-DXLANG_PTHIN_FN_BLOCK_BODIES_FROM_X"
            if g05_obj_defines "$_pthin_p6b_thin_o" "parser_asm_parse_struct_record_layout_x_into_c"; then
              _pthin_p6_extra="$_pthin_p6_extra -DXLANG_PTHIN_FN_BLOCK_PARSE_LAYOUT_FROM_X"
              echo "g05_ensure: P6b/P6c/P6d/P6e fn_block bodies ← $_pthin_p6b_x (7.2.1 B-minus)"
            else
              echo "g05_ensure: P6b/P6c/P6d fn_block bodies ← $_pthin_p6b_x (P6e parse C twin)"
            fi
            if g05_obj_defines "$_pthin_p6b_thin_o" "parser_asm_fill_block_const_let_from_res_x_into_c"; then
              _pthin_p6_extra="$_pthin_p6_extra -DXLANG_PTHIN_FN_BLOCK_BLOCK_FROM_RES_FROM_X"
              echo "g05_ensure: P6f block_from_res ← $_pthin_p6b_x (7.2.1 B-minus)"
            else
              echo "g05_ensure: P6f block_from_res C twin (missing fill_x)"
            fi
            if g05_obj_defines "$_pthin_p6b_thin_o" "parser_asm_parse_one_function_library_finish_x_into_c"; then
              _pthin_p6_extra="$_pthin_p6_extra -DXLANG_PTHIN_FN_BLOCK_LIBRARY_FROM_X"
              echo "g05_ensure: P6g library remaining compositor ← $_pthin_p6b_x (7.2.1 B-minus)"
            else
              echo "g05_ensure: P6g library remaining compositor C twin (missing finish_x)"
            fi
            if g05_obj_defines "$_pthin_p6b_thin_o" "parser_asm_parse_one_function_buf_header_x_into_c"; then
              _pthin_p6_extra="$_pthin_p6_extra -DXLANG_PTHIN_FN_BLOCK_ONEFUNC_BUF_HDR_FROM_X"
              echo "g05_ensure: P6h one_function_buf header ← $_pthin_p6b_x (7.2.1 B-minus)"
            else
              echo "g05_ensure: P6h one_function_buf header C twin (missing header_x)"
            fi
          else
            echo "g05_ensure: P6b fn_block .x thin failed or missing layout match; P6 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p6_o" ] && [ -f "$_pthin_p6_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p6_extra -c -o "$_pthin_p6_o" "$_pthin_p6_seed"; then
            _pthin_p6_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_FN_BLOCK_FROM_X"
            echo "g05_ensure: P6 fn/block ← $_pthin_p6_seed (G-02f-287 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P7b/P7c/P7d Route C (2026-09-13 / 2026-09-15 / 2026-09-16).
        # pthin_simd.x holds ident pack / callee name fill / callee+CALL wrap
        # plus parse_at_simd_builtin dest-buffer (P9a peek/step; expr ptr
        # shim). Runs before P7 C so BODIES_FROM_X skips the portable .inc
        # region. P9a is linked later into the same thin_glue (same as
        # P4ud/P4bh). Cold: no define, full .inc.
        _pthin_p7_extra=""
        if [ -n "$_pthin_p7b_thin_o" ] && [ -f "$_pthin_p7b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p7b_x" "$_pthin_p7b_thin_o" \
            && g05_obj_defines "$_pthin_p7b_thin_o" "parser_asm_parse_at_simd_builtin_x_into_c"; then
            _pthin_p7b_ok=1
            _pthin_p7_extra="-DXLANG_PTHIN_SIMD_BODIES_FROM_X"
            echo "g05_ensure: P7b/P7c/P7d simd bodies ← $_pthin_p7b_x (7.2.1 Route C)"
          else
            echo "g05_ensure: P7b simd .x thin failed or missing parse dest-buffer; P7 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p7_o" ] && [ -f "$_pthin_p7_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p7_extra -c -o "$_pthin_p7_o" "$_pthin_p7_seed"; then
            _pthin_p7_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_SIMD_FROM_X"
            echo "g05_ensure: P7 simd ← $_pthin_p7_seed (G-02f-288 seed slice)"
          fi
        fi
        # G-02f-318a / 7.2.1 B-minus pilot (RFC §5c): lexer-step BRIDGE is
        # the peek/step authority used by dest-buffer parse (P4ud/P4bh/P5/P7d).
        # Compile the bridge even when stretch-audit .x thin fails (audit
        # mega -E typeck/check_block flakes; coupling it with && dropped
        # peek/step from the product glue and UNDEF'd every dest-buffer
        # lane). STRETCH_AUDIT_FROM_X still requires the audit .x thin.
        # PLATFORM: SHARED
        _pthin_p9_extra=""
        if [ -n "$_pthin_p9a_o" ] && [ -f "$_pthin_p9a_bridge" ]; then
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p9a_o" "$_pthin_p9a_bridge"; then
            _pthin_p9a_ok=1
            echo "g05_ensure: P9a lexer-step bridge ← $_pthin_p9a_bridge (7.2.1 B-minus)"
          else
            echo "g05_ensure: P9a lexer-step bridge -c failed; peek/step stay absent" >&2
          fi
        fi
        if [ "$_pthin_p9a_ok" = "1" ] && [ -n "$_pthin_p9a_thin_o" ] && [ -f "$_pthin_p9a_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p9a_x" "$_pthin_p9a_thin_o"; then
            _pthin_p9a_audit_ok=1
            _pthin_p9_extra="-DXLANG_PTHIN_STRETCH_AUDIT_FROM_X"
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_STRETCH_AUDIT_FROM_X"
            echo "g05_ensure: P9a stretch_audit ← $_pthin_p9a_x (7.2.1 B-minus)"
          else
            echo "g05_ensure: P9a stretch_audit .x thin failed; audit C twin stays (bridge still linked)" >&2
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P1b/P1c/P1d/P1e/P1f/P1g Route C + B-minus (2026-09-13/15/16).
        # pthin_lex_skip.x holds kind predicates, buf copies, B-minus
        # skip_balanced/generic_into, P1c generic_count (peek+step via
        # P9a bridge; dest buffers for pending names), P1d ASI
        # advance_past_stmt_semicolon / advance_past_cond_rparen, P1e
        # parse_peek_function_name / first_token_kind (C twins in
        # helpers.inc trampoline when this define is set on P19), P1f
        # copy_token_bytes buf-path (128-byte zero-fill; slice trampoline
        # stays in imports.inc), and P1g register_pending (guards + call
        # register_type_params_c; C owns g_gp_pending_*).
        # PENDING is a separate define so a missing pending_x keeps the C
        # twin without dropping P1b–f.
        # Runs after P9a so BODIES_FROM_X is only set when the bridge
        # will be linked (otherwise skip_balanced/count/ASI/peek would UNDEF).
        # Cold: no define, full .inc. Do not add P9a as a hard gate to P19.
        _pthin_p1_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ -n "$_pthin_p1b_thin_o" ] && [ -f "$_pthin_p1b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p1b_x" "$_pthin_p1b_thin_o"; then
            _pthin_p1b_ok=1
            _pthin_p1_extra="-DXLANG_PTHIN_LEX_SKIP_BODIES_FROM_X"
            if g05_obj_defines "$_pthin_p1b_thin_o" "xlang_generic_func_register_pending_type_params_x_into_c"; then
              _pthin_p1_extra="$_pthin_p1_extra -DXLANG_PTHIN_LEX_SKIP_PENDING_FROM_X"
              echo "g05_ensure: P1b/P1c/P1d/P1e/P1f/P1g lex_skip bodies ← $_pthin_p1b_x (7.2.1 B-minus + register_pending)"
            else
              echo "g05_ensure: P1b/P1c/P1d/P1e/P1f lex_skip bodies ← $_pthin_p1b_x (P1g register_pending C twin)"
            fi
          else
            echo "g05_ensure: P1b lex_skip .x thin failed; P1 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p1_o" ] && [ -f "$_pthin_p1_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p1_extra -c -o "$_pthin_p1_o" "$_pthin_p1_seed"; then
            _pthin_p1_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_LEX_SKIP_FROM_X"
            echo "g05_ensure: P1 lex/skip ← $_pthin_p1_seed (G-02f-281 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 Route C productize (2026-09-12).
        # pthin_stretch.x already holds the 13 lite scalar-table bodies.
        # Runs BEFORE P9 C so LITE_FROM_X skips emit_heavy_stretch_slice.inc
        # (same skip-include pattern as P9a/suite).
        # M2 class B (2026-09-16): kw_spell u8[360] standalone -c green.
        # In-chain stretch.o is NOT the hello SEGV producer — Ubuntu this-SHA
        # + P9b LITE_FROM_X = L2 5/5 with Lxml_ cells in the product.
        # Darwin hello SIGSEGV (lexer_skip slice.data = lexer.pos, 0x5012
        # or 0x72) reproduces with skip_tl asm and C stretch twin (P9b skip).
        # Producer = ARM64 asm of parser_asm_generic_bound_scan_into_c
        # (pthin_skip_tl.x) → peek_kind. Re-enable P9b try (peer of other
        # P*b; WEAK). Darwin PREFER_ASM g05 of skip_tl stays leftover.
        # token.h stays classify-enum authority via P9 C _Static_assert.
        if [ -n "$_pthin_p9b_thin_o" ] && [ -f "$_pthin_p9b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p9b_x" "$_pthin_p9b_thin_o"; then
            _pthin_p9b_ok=1
            _pthin_p9_extra="$_pthin_p9_extra -DXLANG_PTHIN_STRETCH_LITE_FROM_X"
            echo "g05_ensure: P9b stretch lite ← $_pthin_p9b_x (7.2.1 Route C productize)"
          else
            echo "g05_ensure: P9b stretch .x thin failed; P9 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p9_o" ] && [ -f "$_pthin_p9_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p9_extra -c -o "$_pthin_p9_o" "$_pthin_p9_seed"; then
            _pthin_p9_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_STRETCH_FROM_X"
            echo "g05_ensure: P9 stretch+suite ← $_pthin_p9_seed (G-02f-318 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P5b/P5c Route C + P5d/P5e/P5f/P5g/P5h/P5i/P5j B-minus + P5k T-shrink.
        # pthin_ctrl.x holds comment-aware brace skip / kw_at_pos /
        # scan_sync pos + the six-stage realign walk + dest-typed enum
        # tag scan (P5e; C trampoline holds ename[256]) + parse_if_expr
        # (P5f) + match wrap-family dest-buffer (P5g; VAR trampoline
        # holds name[256]) + parse_match_subject dest-buffer (P5h) +
        # parse_match_struct_fields dest-buffer (P5i; field wrap src
        # trampoline holds name[256]) + parse_match_into dest-buffer
        # (P5j; C trampoline holds 16-pattern pack + name[128]) + P5k
        # leftover if_stmt C-twin T-shrink (requires parse_if_stmt_x).
        # P5d/P5f/P5h/P5i/P5j require the P9a lexer-step bridge (peek family +
        # cursor trio; otherwise those would UNDEF), so this lane runs
        # AFTER P9a and gates on its ok flag. Incomplete -E that still
        # exits 0 without parse_match_into_x / parse_if_stmt_x falls back to the C twin
        # (same class as P7d g05_obj_defines). P19 scalars
        # (pos_before_run / lex_at_token_pos / ident_is_unsafe_kind /
        # rewind_kind) resolve from pthin_helpers.x or the P19 cold C
        # twins. Runs before P5 C so BODIES_FROM_X skips the portable
        # .inc region. Cold: no define, full .inc.
        _pthin_p5_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p1b_ok" = "1" ] && [ -n "$_pthin_p5b_thin_o" ] && [ -f "$_pthin_p5b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p5b_x" "$_pthin_p5b_thin_o" \
            && g05_obj_defines "$_pthin_p5b_thin_o" "parser_asm_parse_match_subject_x_into_c" \
            && g05_obj_defines "$_pthin_p5b_thin_o" "parser_asm_parse_match_struct_fields_x_into_c" \
            && g05_obj_defines "$_pthin_p5b_thin_o" "parser_asm_parse_match_into_x_into_c" \
            && g05_obj_defines "$_pthin_p5b_thin_o" "parser_asm_parse_if_stmt_x_into_c"; then
            _pthin_p5b_ok=1
            _pthin_p5_extra="-DXLANG_PTHIN_CTRL_BODIES_FROM_X"
            echo "g05_ensure: P5b/P5c/P5d/P5e/P5f/P5g/P5h/P5i/P5j/P5k ctrl bodies ← $_pthin_p5b_x (7.2.1 Route C scan_sync + B-minus realign + dest enum tag + parse_if_expr + match wrap + match subject parse + match struct fields + match into + if_stmt T-shrink)"
          else
            echo "g05_ensure: P5b ctrl .x thin failed or missing match-subject/struct-fields/into/if_stmt dest-buffer; P5 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p5_o" ] && [ -f "$_pthin_p5_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p5_extra -c -o "$_pthin_p5_o" "$_pthin_p5_seed"; then
            _pthin_p5_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_CTRL_FROM_X"
            echo "g05_ensure: P5 ctrl ← $_pthin_p5_seed (G-02f-286 seed slice)"
          fi
        fi
        # P10 C is compiled after P12b (skip_one_function_full .x calls
        # P12b skip_one_extern). See P10b block below.
        # PLATFORM: SHARED — 7.2.1 P11b/P11c/P11d B-minus (2026-09-13).
        # pthin_imports.x holds skip_imports + consume_path/try_skip +
        # collect_imports. Requires P9a lexer-step bridge (otherwise
        # peek/step would UNDEF). copy_slice / stretch validate resolve
        # from P1b / P9b (or their cold C twins). P1f copy_token_bytes
        # buf-path resolves from pthin_lex_skip.x (slice trampoline in
        # this .inc). Runs before P11 C so BODIES_FROM_X skips the
        # portable .inc region. Cold: no define, full .inc. Do not reuse
        # XLANG_PTHIN_IMPORTS_FROM_X.
        _pthin_p11_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] \
          && [ -n "$_pthin_p11b_thin_o" ] && [ -f "$_pthin_p11b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p11b_x" "$_pthin_p11b_thin_o"; then
            _pthin_p11b_ok=1
            _pthin_p11_extra="-DXLANG_PTHIN_IMPORTS_BODIES_FROM_X"
            echo "g05_ensure: P11b/P11c/P11d imports bodies ← $_pthin_p11b_x (7.2.1 B-minus skip_imports/consume_path/try_skip/collect_imports)"
          else
            echo "g05_ensure: P11b imports .x thin failed; P11 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p11_o" ] && [ -f "$_pthin_p11_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p11_extra -c -o "$_pthin_p11_o" "$_pthin_p11_seed"; then
            _pthin_p11_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_IMPORTS_FROM_X"
            echo "g05_ensure: P11 imports ← $_pthin_p11_seed (G-02f-320 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P12b–P12m B-minus (2026-09-13 / P12m 2026-09-15).
        # pthin_skip_tl.x holds skip_one_struct/enum/extern + impl header
        # + generic_bound_scan + enum_register + parse_one_extern_skip
        # + parse_one_extern_and_add + skip_name_is_self + self_matches_for
        # + named_eq_self + rewrite_self + register_type_params +
        # type_param_index + concrete_implements_trait +
        # bound_check_type_args.
        # Requires P9a lexer-step bridge AND P1b skip_balanced /
        # skip_generic_angle / copy_slice (otherwise those would UNDEF).
        # Runs before P12 C so BODIES_FROM_X skips the portable .inc
        # region. Cold: no define, full .inc. Do not reuse
        # XLANG_PTHIN_SKIP_TL_FROM_X. Do not open a new P12c–m lane.
        _pthin_p12_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p1b_ok" = "1" ] \
          && [ -n "$_pthin_p12b_thin_o" ] && [ -f "$_pthin_p12b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p12b_x" "$_pthin_p12b_thin_o"; then
            _pthin_p12b_ok=1
            _pthin_p12_extra="-DXLANG_PTHIN_SKIP_TL_BODIES_FROM_X"
            if g05_obj_defines "$_pthin_p12b_thin_o" "xlang_skip_trait_check_param_shape_x_into_c"; then
              _pthin_p12_extra="$_pthin_p12_extra -DXLANG_PTHIN_SKIP_TL_TRAIT_SHAPE_FROM_X"
              echo "g05_ensure: P12b–P12u/P12v skip_tl + param/ret_shape ← $_pthin_p12b_x"
            else
              echo "g05_ensure: P12b–P12u skip_tl bodies ← $_pthin_p12b_x (P12v param_shape C twin)"
            fi
          else
            echo "g05_ensure: P12b skip_tl .x thin failed; P12 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p12_o" ] && [ -f "$_pthin_p12_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p12_extra -c -o "$_pthin_p12_o" "$_pthin_p12_seed"; then
            _pthin_p12_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_SKIP_TL_FROM_X"
            echo "g05_ensure: P12 skip_tl ← $_pthin_p12_seed (G-02f-321 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P10b B-minus (2026-09-13).
        # pthin_glue.x holds skip_one_function_full. Requires P9a lexer-step
        # bridge AND P1b skip_balanced AND P12b skip_one_extern (otherwise
        # those would UNDEF). Runs before P10 C so BODIES_FROM_X skips the
        # portable .inc region. Cold: no define, full .inc. Do not reuse
        # XLANG_PTHIN_GLUE_FROM_X. Compile after P12b so _pthin_p12b_ok is set.
        _pthin_p10_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p1b_ok" = "1" ] \
          && [ "$_pthin_p12b_ok" = "1" ] \
          && [ -n "$_pthin_p10b_thin_o" ] && [ -f "$_pthin_p10b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p10b_x" "$_pthin_p10b_thin_o"; then
            _pthin_p10b_ok=1
            _pthin_p10_extra="-DXLANG_PTHIN_GLUE_BODIES_FROM_X"
            echo "g05_ensure: P10b glue bodies ← $_pthin_p10b_x (7.2.1 B-minus)"
          else
            echo "g05_ensure: P10b glue .x thin failed; P10 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p10_o" ] && [ -f "$_pthin_p10_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p10_extra -c -o "$_pthin_p10_o" "$_pthin_p10_seed"; then
            _pthin_p10_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_GLUE_FROM_X"
            echo "g05_ensure: P10 glue tail ← $_pthin_p10_seed (G-02f-319 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P13b/P13c B-minus (2026-09-13).
        # pthin_try_skip_allow.x holds the padding paren walk plus
        # write_result fields store and parse_into core (tri-state gate).
        # Requires P9a lexer-step bridge AND P1b skip_balanced (otherwise
        # those would UNDEF). Runs before P13 C so BODIES_FROM_X skips
        # the portable .inc region. Cold: no define, full .inc. Do not
        # reuse XLANG_PTHIN_TRY_SKIP_ALLOW_FROM_X.
        _pthin_p13_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p1b_ok" = "1" ] \
          && [ -n "$_pthin_p13b_thin_o" ] && [ -f "$_pthin_p13b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p13b_x" "$_pthin_p13b_thin_o"; then
            _pthin_p13b_ok=1
            _pthin_p13_extra="-DXLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X"
            echo "g05_ensure: P13b/P13c try_skip_allow bodies ← $_pthin_p13b_x (7.2.1 B-minus padding + write_result/parse_into)"
          else
            echo "g05_ensure: P13b try_skip_allow .x thin failed; P13 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p13_o" ] && [ -f "$_pthin_p13_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p13_extra -c -o "$_pthin_p13_o" "$_pthin_p13_seed"; then
            _pthin_p13_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_TRY_SKIP_ALLOW_FROM_X"
            echo "g05_ensure: P13 try_skip_allow ← $_pthin_p13_seed (G-02f-322 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P14b/P14c B-minus (2026-09-13/15).
        # pthin_skip_if.x holds trait/impl + if-core/statement walks
        # and module_try_register_enum_name. Requires P9a lexer-step
        # bridge AND P1b skip_balanced (otherwise skip_balanced would
        # UNDEF). Runs before P14 C so BODIES_FROM_X skips the portable
        # .inc region. Cold: no define, full .inc.
        _pthin_p14_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p1b_ok" = "1" ] \
          && [ -n "$_pthin_p14b_thin_o" ] && [ -f "$_pthin_p14b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p14b_x" "$_pthin_p14b_thin_o"; then
            _pthin_p14b_ok=1
            _pthin_p14_extra="-DXLANG_PTHIN_SKIP_IF_BODIES_FROM_X"
            echo "g05_ensure: P14b/P14c skip_if bodies ← $_pthin_p14b_x (7.2.1 B-minus)"
          else
            echo "g05_ensure: P14b skip_if .x thin failed; P14 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p14_o" ] && [ -f "$_pthin_p14_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p14_extra -c -o "$_pthin_p14_o" "$_pthin_p14_seed"; then
            _pthin_p14_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_SKIP_IF_FROM_X"
            echo "g05_ensure: P14 skip_if ← $_pthin_p14_seed (G-02f-323 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P15b B-minus (2026-09-13).
        # pthin_library.x holds library_scan. Requires P9a lexer-step
        # bridge AND P1b copies (otherwise peek/step/copy would UNDEF).
        # Runs before P15 C so BODIES_FROM_X skips the portable .inc
        # region. Cold: no define, full .inc. Do not reuse
        # XLANG_PTHIN_LIBRARY_FROM_X.
        _pthin_p15_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p1b_ok" = "1" ] \
          && [ -n "$_pthin_p15b_thin_o" ] && [ -f "$_pthin_p15b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p15b_x" "$_pthin_p15b_thin_o"; then
            _pthin_p15b_ok=1
            _pthin_p15_extra="-DXLANG_PTHIN_LIBRARY_BODIES_FROM_X"
            echo "g05_ensure: P15b library bodies ← $_pthin_p15b_x (7.2.1 B-minus scan)"
          else
            echo "g05_ensure: P15b library .x thin failed; P15 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p15_o" ] && [ -f "$_pthin_p15_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p15_extra -c -o "$_pthin_p15_o" "$_pthin_p15_seed"; then
            _pthin_p15_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_LIBRARY_FROM_X"
            echo "g05_ensure: P15 library ← $_pthin_p15_seed (G-02f-324 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p16_o" ] && [ -f "$_pthin_p16_seed" ]; then
          # shellcheck disable=SC2086
          # NO_SEED_PARSE：抑制 slice 内 parser_get_module_* 别名（产品由 parser_x.o 提供；G-02f-326）
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE \
               -c -o "$_pthin_p16_o" "$_pthin_p16_seed"; then
            _pthin_p16_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_DIAG_PIPELINE_FROM_X"
            echo "g05_ensure: P16 diag_pipeline ← $_pthin_p16_seed (G-02f-325 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P18b/P18c/P18d Route C + B-minus.
        # pthin_body_tl.x holds is_fn_sig_scalar + diag/body skip walks +
        # skip_one_top_level let/const + cfg_skip + diag_first_ident +
        # P010–P014 reports + onefunc_param_name_dup.
        # Requires P9a lexer-step bridge AND P14b skip_one_if_statement
        # AND P12b skip_one_struct AND P10b skip_one_function_full
        # (otherwise those would UNDEF). Runs after P10b/P12b/P14b so
        # those ok flags are set; before P18 C so BODIES_FROM_X skips
        # the portable .inc region. Cold: no define, full .inc. Do not
        # reuse XLANG_PTHIN_BODY_TL_FROM_X. 有则补全 P18b, no new P-lane.
        _pthin_p18_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p14b_ok" = "1" ] \
          && [ "$_pthin_p12b_ok" = "1" ] && [ "$_pthin_p10b_ok" = "1" ] \
          && [ -n "$_pthin_p18b_thin_o" ] && [ -f "$_pthin_p18b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p18b_x" "$_pthin_p18b_thin_o"; then
            _pthin_p18b_ok=1
            _pthin_p18_extra="-DXLANG_PTHIN_BODY_TL_BODIES_FROM_X"
            echo "g05_ensure: P18b/P18c/P18d body_tl bodies ← $_pthin_p18b_x (7.2.1 B-minus P010-P014/dup)"
          else
            echo "g05_ensure: P18b body_tl .x thin failed; P18 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p18_o" ] && [ -f "$_pthin_p18_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p18_extra -c -o "$_pthin_p18_o" "$_pthin_p18_seed"; then
            _pthin_p18_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_BODY_TL_FROM_X"
            echo "g05_ensure: P18 body_tl ← $_pthin_p18_seed (G-02f-327 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P17b B-minus + P17c G.7 (2026-09-13).
        # pthin_diag_late.x holds after_structs + fail_at_token_kind.
        # P17c: diag_skip_let_const_buf trampolines over P18b into
        # (no new .x export; G.7 kill of the buf C walk twin).
        # Requires P9a + P1b + P12b + P18b (peek/step, is_pointee,
        # skip_one_struct, is_fn_sig/body_skip/diag_skip). Moved after
        # P18b so _pthin_p18b_ok is set before BODIES_FROM_X. Cold: no
        # define, full .inc. Do not reuse XLANG_PTHIN_DIAG_LATE_FROM_X.
        _pthin_p17_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ "$_pthin_p1b_ok" = "1" ] \
          && [ "$_pthin_p12b_ok" = "1" ] && [ "$_pthin_p18b_ok" = "1" ] \
          && [ -n "$_pthin_p17b_thin_o" ] && [ -f "$_pthin_p17b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p17b_x" "$_pthin_p17b_thin_o"; then
            _pthin_p17b_ok=1
            _pthin_p17_extra="-DXLANG_PTHIN_DIAG_LATE_BODIES_FROM_X"
            echo "g05_ensure: P17b/P17c diag_late bodies ← $_pthin_p17b_x (7.2.1 B-minus after_structs/fail + G.7 buf trampoline)"
          else
            echo "g05_ensure: P17b diag_late .x thin failed; P17 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p17_o" ] && [ -f "$_pthin_p17_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p17_extra -c -o "$_pthin_p17_o" "$_pthin_p17_seed"; then
            _pthin_p17_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_DIAG_LATE_FROM_X"
            echo "g05_ensure: P17 diag_late ← $_pthin_p17_seed (G-02f-326 seed slice)"
          fi
        fi
        # PLATFORM: SHARED — 7.2.1 P19b/P19c/P19d/P19e/P19f Route C
        # (2026-09-12/13/14/16). pthin_helpers.x holds kind predicates,
        # pos-before-run, buf copy, match-kw byte probe, run_len extra
        # cases, lex_at_token pos, rewind kind, struct_field_name,
        # ident_is_unsafe, (P19e) align_lex in place, and (P19f)
        # parse_block_return_end_tail decide+flags. P19e/P19f need the
        # P9a peek family + cursor trio, so this lane gates on
        # _pthin_p9a_ok exactly like the P5d/P12b lanes (cold or P9a
        # failure keeps the full .inc twin). Runs before P19 C so
        # BODIES_FROM_X skips the portable .inc region. Stretch
        # field-name / compact run_len tables come from P9b (or P9 lite C);
        # do not add more bridges here. Do not open a new P-lane.
        _pthin_p19_extra=""
        if [ "$_pthin_p9a_ok" = "1" ] && [ -n "$_pthin_p19b_thin_o" ] && [ -f "$_pthin_p19b_x" ]; then
          if G05_X_O_WEAK=1 g05_try_x_to_o "$_pthin_p19b_x" "$_pthin_p19b_thin_o"; then
            _pthin_p19b_ok=1
            _pthin_p19_extra="-DXLANG_PTHIN_HELPERS_BODIES_FROM_X"
            echo "g05_ensure: P19b/P19c/P19d/P19e/P19f helpers bodies ← $_pthin_p19b_x (7.2.1 Route C kind/copy/pos/match-kw + run_len extra/lex_at_token/rewind + struct_field_name/ident_is_unsafe + align_lex + parse_block_return_end_tail)"
          else
            echo "g05_ensure: P19b helpers .x thin failed; P19 C twin stays full" >&2
          fi
        fi
        if [ -n "$_pthin_p19_o" ] && [ -f "$_pthin_p19_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_p19_extra $_pthin_p1_extra -c -o "$_pthin_p19_o" "$_pthin_p19_seed"; then
            _pthin_p19_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_HELPERS_FROM_X"
            echo "g05_ensure: P19 helpers ← $_pthin_p19_seed (G-02f-328 seed slice)"
          fi
        fi
        if [ -n "$_pthin_p20_o" ] && [ -f "$_pthin_p20_seed" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               -c -o "$_pthin_p20_o" "$_pthin_p20_seed"; then
            _pthin_p20_ok=1
            _pthin_rest_defs="$_pthin_rest_defs -DXLANG_PTHIN_FOUNDATION_FROM_X"
            echo "g05_ensure: P20 foundation ← $_pthin_p20_seed (G-02f-329 seed slice)"
          fi
        fi
        # G-02f-289 P8：仅 smoke -c（不进产品 hybrid ld -r；产品 rest 仍 NO_SEED_PARSE）
        if [ -f "$_pthin_p8_seed" ]; then
          _pthin_p8_smoke=$(mktemp "${TMPDIR:-/tmp}/g05_pthin_p8_smoke.XXXXXX") || true
          # shellcheck disable=SC2086
          if [ -n "$_pthin_p8_smoke" ] \
            && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
                 -c -o "$_pthin_p8_smoke" "$_pthin_p8_seed"; then
            echo "g05_ensure: P8 seed_parse smoke -c OK ← $_pthin_p8_seed (G-02f-289; not in product glue)"
          else
            echo "g05_ensure: P8 seed_parse smoke -c failed (non-fatal for product NO_SEED_PARSE glue)" >&2
          fi
          rm -f "$_pthin_p8_smoke"
        fi
        # 拼 hybrid link 列表（P8 smoke-only 不入）
        _pthin_link=""
        if [ "$_pthin_p1_ok" = "1" ]; then
          _pthin_link="$_pthin_p1_o"
        fi
        if [ "$_pthin_p1b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p1b_thin_o"
        fi
        if [ "$_pthin_p3_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p3_o"
        fi
        if [ "$_pthin_p3b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p3b_thin_o"
        fi
        if [ "$_pthin_p2_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p2_o"
        fi
        if [ "$_pthin_p2b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p2b_thin_o"
        fi
        if [ "$_pthin_p6_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p6_o"
        fi
        if [ "$_pthin_p6b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p6b_thin_o"
        fi
        if [ "$_pthin_p4as_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4as_o"
        fi
        if [ "$_pthin_p4asb_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4asb_thin_o"
        fi
        if [ "$_pthin_p4p_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4p_o"
        fi
        if [ "$_pthin_p4pb_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4pb_thin_o"
        fi
        if [ "$_pthin_p4u_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4u_o"
        fi
        if [ "$_pthin_p4ub_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4ub_thin_o"
        fi
        if [ "$_pthin_p4b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4b_o"
        fi
        if [ "$_pthin_p4bb_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4bb_thin_o"
        fi
        if [ "$_pthin_p4t_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4t_o"
        fi
        if [ "$_pthin_p4tb_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p4tb_thin_o"
        fi
        if [ "$_pthin_p5_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p5_o"
        fi
        if [ "$_pthin_p5b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p5b_thin_o"
        fi
        if [ "$_pthin_p7_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p7_o"
        fi
        if [ "$_pthin_p7b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p7b_thin_o"
        fi
        if [ "$_pthin_p9_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p9_o"
        fi
        if [ "$_pthin_p9a_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p9a_o"
        fi
        if [ "$_pthin_p9a_audit_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p9a_thin_o"
        fi
        if [ "$_pthin_p9b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p9b_thin_o"
        fi
        if [ "$_pthin_p11_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p11_o"
        fi
        if [ "$_pthin_p11b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p11b_thin_o"
        fi
        if [ "$_pthin_p12_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p12_o"
        fi
        if [ "$_pthin_p12b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p12b_thin_o"
        fi
        if [ "$_pthin_p14_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p14_o"
        fi
        if [ "$_pthin_p14b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p14b_thin_o"
        fi
        if [ "$_pthin_p15_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p15_o"
        fi
        if [ "$_pthin_p15b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p15b_thin_o"
        fi
        if [ "$_pthin_p16_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p16_o"
        fi
        if [ "$_pthin_p17_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p17_o"
        fi
        if [ "$_pthin_p17b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p17b_thin_o"
        fi
        if [ "$_pthin_p18_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p18_o"
        fi
        if [ "$_pthin_p18b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p18b_thin_o"
        fi
        if [ "$_pthin_p19_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p19_o"
        fi
        if [ "$_pthin_p19b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p19b_thin_o"
        fi
        if [ "$_pthin_p20_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p20_o"
        fi
        if [ "$_pthin_p13_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p13_o"
        fi
        if [ "$_pthin_p13b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p13b_thin_o"
        fi
        if [ "$_pthin_p10_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p10_o"
        fi
        if [ "$_pthin_p10b_ok" = "1" ]; then
          _pthin_link="$_pthin_link $_pthin_p10b_thin_o"
        fi
        # G-02f-330：全产品切片齐（P1–P7+P9–P20）时 mega rest 无全局 T，跳过 rest 编译与 ld -r
        _pthin_full=0
        if [ "$_pthin_p1_ok" = "1" ] && [ "$_pthin_p2_ok" = "1" ] && [ "$_pthin_p3_ok" = "1" ] \
          && [ "$_pthin_p4p_ok" = "1" ] && [ "$_pthin_p4u_ok" = "1" ] && [ "$_pthin_p4b_ok" = "1" ] \
          && [ "$_pthin_p4as_ok" = "1" ] && [ "$_pthin_p4t_ok" = "1" ] && [ "$_pthin_p5_ok" = "1" ] \
          && [ "$_pthin_p6_ok" = "1" ] && [ "$_pthin_p7_ok" = "1" ] && [ "$_pthin_p9_ok" = "1" ] \
          && [ "$_pthin_p10_ok" = "1" ] && [ "$_pthin_p11_ok" = "1" ] && [ "$_pthin_p12_ok" = "1" ] \
          && [ "$_pthin_p13_ok" = "1" ] && [ "$_pthin_p14_ok" = "1" ] && [ "$_pthin_p15_ok" = "1" ] \
          && [ "$_pthin_p16_ok" = "1" ] && [ "$_pthin_p17_ok" = "1" ] && [ "$_pthin_p18_ok" = "1" ] \
          && [ "$_pthin_p19_ok" = "1" ] && [ "$_pthin_p20_ok" = "1" ] && [ -n "$_pthin_link" ]; then
          _pthin_full=1
        fi
        if [ "$_pthin_full" = "1" ]; then
          # shellcheck disable=SC2086
          if pure_ld_partial_merge parser_asm_thin_glue.o $_pthin_link 2>/dev/null; then
            echo "g05_ensure: parser_asm_thin_glue.o ← P1–P7+P9–P20 only (G-02f-330 omit empty rest; P8 smoke-only)"
            _pthin_done=1
          fi
        elif { [ "$_pthin_p1_ok" = "1" ] || [ "$_pthin_p2_ok" = "1" ] || [ "$_pthin_p3_ok" = "1" ] || [ "$_pthin_p4p_ok" = "1" ] || [ "$_pthin_p4u_ok" = "1" ] || [ "$_pthin_p4b_ok" = "1" ] || [ "$_pthin_p4as_ok" = "1" ] || [ "$_pthin_p4t_ok" = "1" ] || [ "$_pthin_p5_ok" = "1" ] || [ "$_pthin_p6_ok" = "1" ] || [ "$_pthin_p7_ok" = "1" ] || [ "$_pthin_p9_ok" = "1" ] || [ "$_pthin_p10_ok" = "1" ] || [ "$_pthin_p11_ok" = "1" ] || [ "$_pthin_p12_ok" = "1" ] || [ "$_pthin_p13_ok" = "1" ] || [ "$_pthin_p14_ok" = "1" ] || [ "$_pthin_p15_ok" = "1" ] || [ "$_pthin_p16_ok" = "1" ] || [ "$_pthin_p17_ok" = "1" ] || [ "$_pthin_p18_ok" = "1" ] || [ "$_pthin_p19_ok" = "1" ] || [ "$_pthin_p20_ok" = "1" ]; } \
          && [ -n "$_pthin_rest_o" ] && [ -n "$_pthin_link" ]; then
          # shellcheck disable=SC2086
          if $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
               $_pthin_rest_defs -c -o "$_pthin_rest_o" "$_pthin"; then
            _pthin_rest_t=$(nm -gU "$_pthin_rest_o" 2>/dev/null | awk '$2=="T"{c++} END{print c+0}')
            # shellcheck disable=SC2086
            if [ "${_pthin_rest_t:-1}" = "0" ]; then
              if pure_ld_partial_merge parser_asm_thin_glue.o $_pthin_link 2>/dev/null; then
                echo "g05_ensure: parser_asm_thin_glue.o ← hybrid slices only (rest T=0 omit; G-02f-330)"
                _pthin_done=1
              fi
            elif pure_ld_partial_merge parser_asm_thin_glue.o $_pthin_link "$_pthin_rest_o" 2>/dev/null; then
              echo "g05_ensure: parser_asm_thin_glue.o ← hybrid slices + thin rest (G-02f-330 partial; rest T=$_pthin_rest_t)"
              _pthin_done=1
            fi
          fi
        fi
        if [ "$_pthin_done" = "0" ]; then
          echo "g05_ensure: parser thin P1–P7+P9–P20 hybrid failed; fallback full seed" >&2
        fi
        rm -f "$_pthin_p1_o" "$_pthin_p1b_thin_o" "$_pthin_p2_o" "$_pthin_p2b_thin_o" "$_pthin_p3_o" "$_pthin_p3b_thin_o" "$_pthin_p4p_o" "$_pthin_p4pb_thin_o" "$_pthin_p4u_o" "$_pthin_p4ub_thin_o" "$_pthin_p4b_o" "$_pthin_p4bb_thin_o" "$_pthin_p4as_o" "$_pthin_p4asb_thin_o" "$_pthin_p4t_o" "$_pthin_p4tb_thin_o" "$_pthin_p5_o" "$_pthin_p5b_thin_o" "$_pthin_p6_o" "$_pthin_p6b_thin_o" "$_pthin_p7_o" "$_pthin_p7b_thin_o" "$_pthin_p9_o" "$_pthin_p9a_thin_o" "$_pthin_p9a_o" "$_pthin_p9b_thin_o" "$_pthin_p10_o" "$_pthin_p10b_thin_o" "$_pthin_p11_o" "$_pthin_p11b_thin_o" "$_pthin_p12_o" "$_pthin_p12b_thin_o" "$_pthin_p13_o" "$_pthin_p13b_thin_o" "$_pthin_p14_o" "$_pthin_p14b_thin_o" "$_pthin_p15_o" "$_pthin_p15b_thin_o" "$_pthin_p16_o" "$_pthin_p17_o" "$_pthin_p17b_thin_o" "$_pthin_p18_o" "$_pthin_p18b_thin_o" "$_pthin_p19_o" "$_pthin_p19b_thin_o" "$_pthin_p20_o" "$_pthin_rest_o"
      fi
      if [ "$_pthin_done" = "0" ]; then
        echo "g05_ensure: parser_asm_thin_glue.o ← thin seed (G-02f-10)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm \
          -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE \
          -c -o parser_asm_thin_glue.o "$_pthin"
      fi
    fi
  fi
  # G-02f-11 / G-02f-335～346：diag.o
  # 默认整 seed；PREFER_X_O=1 时 diag_thin.x（76 门闩：+ code_table/entry/stdio）+ seed-rest ld -r
  _diag=seeds/diag.from_x.c
  _diag_thin_x=src/diag_thin.x
  _diag_o=src/diag.o
  if [ -f "$_diag" ]; then
    if [ ! -f "$_diag_o" ] || [ "$_diag" -nt "$_diag_o" ] \
      || { [ -f "$_diag_thin_x" ] && [ "$_diag_thin_x" -nt "$_diag_o" ]; }; then
      _diag_done=0
      if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_diag_thin_x" ]; then
        _diag_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_diag_thin.XXXXXX") || true
        _diag_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_diag_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_diag_thin_o" ] && [ -n "$_diag_rest_o" ] \
          && G05_X_O_WEAK=1 g05_try_x_to_o "$_diag_thin_x" "$_diag_thin_o" \
          && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_L2_DIAG_THIN_FROM_X \
               -c -o "$_diag_rest_o" "$_diag" \
          && pure_ld_partial_merge "$_diag_o" "$_diag_thin_o" "$_diag_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_diag_o ← $_diag_thin_x + seed-rest (G-02f-347/420/421 L2 hybrid diag thin)"
          _diag_done=1
        else
          echo "g05_ensure: L2 hybrid diag thin failed; fallback full seed" >&2
        fi
        rm -f "$_diag_thin_o" "$_diag_rest_o"
      fi
      if [ "$_diag_done" = "0" ]; then
        echo "g05_ensure: $_diag_o ← seed (G-02f-11)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_diag_o" "$_diag"
      fi
    fi
  fi
  # G-02f-11 / G-02f-332：x_seed_bridge.o
  # 默认整 seed；PREFER_X_O=1 时 .x thin（heap/io 桩）+ seed-rest（C 尾）ld -r
  _xsb=seeds/x_seed_bridge.from_x.c
  _xsb_x=src/x_seed_bridge.x
  _xsb_o=src/x_seed_bridge.o
  if [ -f "$_xsb" ]; then
    if [ ! -f "$_xsb_o" ] || [ "$_xsb" -nt "$_xsb_o" ]       || { [ -f "$_xsb_x" ] && [ "$_xsb_x" -nt "$_xsb_o" ]; }; then
      _xsb_done=0
      if [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && [ -f "$_xsb_x" ]; then
        _xsb_thin_o=$(mktemp "${TMPDIR:-/tmp}/g05_xsb_thin.XXXXXX") || true
        _xsb_rest_o=$(mktemp "${TMPDIR:-/tmp}/g05_xsb_rest.XXXXXX") || true
        # shellcheck disable=SC2086
        if [ -n "$_xsb_thin_o" ] && [ -n "$_xsb_rest_o" ]           && G05_X_O_WEAK=1 g05_try_x_to_o "$_xsb_x" "$_xsb_thin_o"           && $CC $BASE_CFLAGS -I. -Iinclude -Isrc -DXLANG_L2_X_SEED_BRIDGE_THIN_FROM_X                -c -o "$_xsb_rest_o" "$_xsb"           && pure_ld_partial_merge "$_xsb_o" "$_xsb_thin_o" "$_xsb_rest_o" 2>/dev/null; then
          echo "g05_ensure: $_xsb_o ← $_xsb_x + seed-rest (G-02f-332 L2 hybrid x_seed_bridge thin)"
          _xsb_done=1
        else
          echo "g05_ensure: L2 hybrid x_seed_bridge failed; fallback full seed" >&2
        fi
        rm -f "$_xsb_thin_o" "$_xsb_rest_o"
      fi
      if [ "$_xsb_done" = "0" ]; then
        echo "g05_ensure: $_xsb_o ← seed (G-02f-11)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_xsb_o" "$_xsb"
      fi
    fi
  fi
  # ~~G-02f-440 seed_link_compat dual hybrid~~ wave771 → try-other-l2-prefer above
  # ~~G-02f-258 strict_glue dual hybrid~~ wave771 → try-other-l2-prefer above
  # ~~G-02f-350/410 fmt_check_cmd_driver dual hybrid~~ wave771 → try-other-l2-prefer above
  # ~~G-02f-15 / wave536 lsp_diag dual hybrid~~ wave771 → try-other-l2-prefer above
  # ~~G-02f-442/441/439 L2 asm dual hybrid~~ wave769 → try-l2-asm-prefer above
  # G-02f-16：x_frontend_link_alias 产品 seed
  _xfla=seeds/x_frontend_link_alias.from_x.c
  if [ -f "$_xfla" ]; then
    if [ ! -f x_frontend_link_alias.o ] || [ "$_xfla" -nt x_frontend_link_alias.o ]; then
      echo "g05_ensure: x_frontend_link_alias.o ← seed (G-02f-16)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o x_frontend_link_alias.o "$_xfla"
    fi
  fi
  # Track L：driver 叶子 + lsp_io_std_heap 构建链退役 — 仅 .x→.o 或 seeds/* 冷启动
  # 不再读取工作区 pinned driver_*_gen.c / lsp_io_std_heap_gen.c
  for _leaf_pair in \
    "src/driver/fmt.x|driver_fmt_x.o|cmd_fmt:driver_cmd_fmt|seeds/driver_fmt_gen.linux.x86_64.c" \
    "src/driver/check.x|driver_check_x.o|cmd_check:driver_cmd_check|seeds/driver_check_gen.linux.x86_64.c" \
    "src/driver/test.x|driver_test_x.o|cmd_test:driver_cmd_test|seeds/driver_test_gen.linux.x86_64.c" \
    "src/driver/build.x|driver_build_x.o|cmd_build:build_cmd_build|seeds/driver_build_gen.linux.x86_64.c" \
    "src/driver/run.x|driver_run_x.o|run_eq_word:driver_run_eq_word,cmd_run:driver_cmd_run|seeds/driver_run_gen.linux.x86_64.c" \
    "src/driver/compile.x|driver_compile_x.o|compile_dispatch_asm_backend:driver_compile_dispatch_asm_backend,compile_dispatch_emit_c_path:driver_compile_dispatch_emit_c_path,eq_minus_o:driver_eq_minus_o,eq_minus_L:driver_eq_minus_L,eq_minus_backend:driver_eq_minus_backend,eq_minus_target:driver_eq_minus_target,eq_minus_target_cpu:driver_eq_minus_target_cpu,eq_print_target_cpu:driver_eq_print_target_cpu,eq_minus_O:driver_eq_minus_O,eq_flto:driver_eq_flto,eq_minus_freestanding:driver_eq_minus_freestanding,eq_legacy_f32_abi:driver_eq_legacy_f32_abi,eq_fsanitize_address:driver_eq_fsanitize_address,eq_asm_word:driver_eq_asm_word,eq_c_word:driver_eq_c_word,path_ends_x:driver_path_ends_x,target_has_arm:driver_target_has_arm,run_compiler_full_x_post_parse:driver_run_compiler_full_x_post_parse,run_compiler_full_x:driver_run_compiler_full_x|seeds/driver_compile_gen.linux.x86_64.c" \
    "src/driver/emit.x|driver_emit_x.o|emit_copy_lib_roots_to_ctx:driver_emit_copy_lib_roots_to_ctx,run_x_emit_x:driver_run_x_emit_x,dispatch_x_emit_to_c:driver_dispatch_x_emit_to_c,emit_state_key:driver_emit_state_key,pipeline_dep_ctx_fill_for_emit:driver_pipeline_dep_ctx_fill_for_emit|seeds/driver_emit_gen.linux.x86_64.c" \
    "src/lsp/lsp_io.x|lsp_io_x.o|std_io_read:io_read,std_io_write:io_write,std_heap_alloc_usize:typeck_std_heap_alloc,std_heap_free_u8_ptr:typeck_std_heap_free,typeck_std_heap_alloc:lsp_io_std_heap_std_heap_alloc,typeck_std_heap_free:lsp_io_std_heap_std_heap_free|seeds/lsp_io_gen.linux.x86_64.c" \
    "src/lsp/lsp_io_std_heap.x|lsp_io_std_heap_x.o|std_heap_alloc:lsp_io_std_heap_std_heap_alloc,std_heap_alloc_zeroed:lsp_io_std_heap_std_heap_alloc_zeroed,std_heap_free:lsp_io_std_heap_std_heap_free|seeds/lsp_io_std_heap_gen.linux.x86_64.c"
  do
    _leaf_x="${_leaf_pair%%|*}"
    _leaf_rest="${_leaf_pair#*|}"
    _leaf_o="${_leaf_rest%%|*}"
    _leaf_rest2="${_leaf_rest#*|}"
    _leaf_rename="${_leaf_rest2%%|*}"
    _leaf_seed="${_leaf_rest2#*|}"
    if [ ! -f "$_leaf_o" ] || { [ -f "$_leaf_x" ] && [ "$_leaf_x" -nt "$_leaf_o" ]; }; then
      if [ -f scripts/driver_leaf_x_to_o.sh ]; then
        # shellcheck disable=SC2086
        DRIVER_SUBCMD_DIRS="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/lsp -L src/preprocess -L src/driver" \
          BASE_CFLAGS="$BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS" \
          bash scripts/driver_leaf_x_to_o.sh "$_leaf_x" "$_leaf_o" "$_leaf_rename" "$_leaf_seed" \
          || echo "g05_ensure: Track L leaf failed for $_leaf_o" >&2
      elif [ "${XLANG_G05_PREFER_X_O:-1}" = "1" ] && G05_X_O_SYM_RENAME="$_leaf_rename" g05_try_x_to_o "$_leaf_x" "$_leaf_o"; then
        echo "g05_ensure: $_leaf_o ← $_leaf_x (Track L PREFER_X_O)"
      elif [ -f "$_leaf_seed" ]; then
        echo "g05_ensure: cc -c $_leaf_seed → $_leaf_o (Track L cold seed)"
        # shellcheck disable=SC2086
        $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -c -o "$_leaf_o" "$_leaf_seed"
      fi
    fi
  done
  # parser_x.o cold path (wave324 M4 7.2.2 + residual pin authority).
  # PLATFORM: SHARED — product authority = seeds/parser_gen.linux.x86_64.c.
  # Full tip -E assemble of parser.x drops surgical seed leaves (generic_bound_scan,
  # dest IF last-dest, region ASI, …) and has produced host-C `return (struct ){`.
  # Default (XLANG_PARSER_FROM_X unset/0): when parser_x.o is missing, always restore
  # the product pin over any local tip-assemble artifact, then cc. Surgical work must
  # land in the committed seed (same commit as parser.x); gitignored local gen is not
  # product authority on cold missing-.o. Tip assemble only with XLANG_PARSER_FROM_X=1.
  # G.7: one cold path; do not auto-assemble parser.x on every missing .o.
  if [ ! -f parser_x.o ]; then
    if [ "${XLANG_PARSER_FROM_X:-0}" = "1" ] && [ -f scripts/ensure_migrate_gen.sh ]; then
      echo "g05_ensure: ensure_migrate_gen parser (opt-in XLANG_PARSER_FROM_X=1; tip assemble)"
      bash scripts/ensure_migrate_gen.sh parser \
        || echo "g05_ensure: ensure_migrate_gen parser failed (will try pin/local)" >&2
      if [ ! -s parser_gen.c ] && [ -f seeds/parser_gen.linux.x86_64.c ]; then
        cp -f seeds/parser_gen.linux.x86_64.c parser_gen.c
        echo "g05_ensure: parser_gen.c ← product pin seed (opt-in assemble empty → pin)"
      fi
    elif [ -f seeds/parser_gen.linux.x86_64.c ]; then
      # Pin-first cold: wipe stale tip-assemble / drifted gitignored gen.
      cp -f seeds/parser_gen.linux.x86_64.c parser_gen.c
      echo "g05_ensure: parser_gen.c ← product pin seed (cold missing parser_x.o; no tip assemble)"
    fi
  fi
  if [ -f parser_gen.c ]; then
    if [ ! -f parser_x.o ] || [ parser_gen.c -nt parser_x.o ]; then
      echo "g05_ensure: cc -c parser_gen.c → parser_x.o (pin/cold)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -c -o parser_x.o parser_gen.c
    fi
  fi
  # LANG-007 + typeck_x.o cold path (wave322 M4 7.4.1).
  # PLATFORM: SHARED — true cold deletes typeck_x.o; host-local typeck_gen.c is gitignored
  # and may be stale. Prefer ensure_migrate_gen typeck (typeck.x -E + companions assemble)
  # when a product -E binary exists; archaeology seed only if assemble cannot run.
  # G.7: do not blind-cp pin over a fresher .x assemble.
  if [ ! -f typeck_x.o ]; then
    if [ -f scripts/ensure_migrate_gen.sh ]; then
      echo "g05_ensure: ensure_migrate_gen typeck (cold: missing typeck_x.o; prefer .x assemble)"
      bash scripts/ensure_migrate_gen.sh typeck \
        || echo "g05_ensure: ensure_migrate_gen typeck failed (will try pin/local)" >&2
    fi
    if [ ! -s typeck_gen.c ] && [ -f seeds/typeck_gen.linux.x86_64.c ]; then
      cp -f seeds/typeck_gen.linux.x86_64.c typeck_gen.c
      echo "g05_ensure: typeck_gen.c ← archaeology seed (cold egg; no assemble)"
    fi
  fi
  if [ -f typeck_gen.c ] && [ -f scripts/patch_typeck_gen_lang007.py ]; then
    _tg_before=$(wc -c < typeck_gen.c | tr -d ' ')
    python3 scripts/patch_typeck_gen_lang007.py || true
    _tg_after=$(wc -c < typeck_gen.c | tr -d ' ')
    if [ "$_tg_before" != "$_tg_after" ] || [ ! -f typeck_x.o ] || [ typeck_gen.c -nt typeck_x.o ]; then
      echo "g05_ensure: cc -c typeck_gen.c → typeck_x.o (LANG-007 / assemble)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -c -o typeck_x.o typeck_gen.c
    fi
  fi
  # codegen_x.o cold path (wave323 M4 7.4.2).
  # PLATFORM: SHARED — prefer ensure_migrate_gen codegen (codegen.x -E + Cap residual)
  # when a product -E binary exists; archaeology seed only if assemble cannot run.
  # G.7: do not blind-cp pin over a fresher .x assemble.
  if [ ! -f codegen_x.o ]; then
    if [ -f scripts/ensure_migrate_gen.sh ]; then
      echo "g05_ensure: ensure_migrate_gen codegen (cold: missing codegen_x.o; prefer .x assemble)"
      bash scripts/ensure_migrate_gen.sh codegen \
        || echo "g05_ensure: ensure_migrate_gen codegen failed (will try pin/local)" >&2
    fi
    if [ ! -s codegen_gen.c ] && [ -f seeds/codegen_gen.linux.x86_64.c ]; then
      cp -f seeds/codegen_gen.linux.x86_64.c codegen_gen.c
      echo "g05_ensure: codegen_gen.c ← archaeology seed (cold egg; no assemble)"
    fi
  fi
  if [ -f codegen_gen.c ]; then
    if [ ! -f codegen_x.o ] || [ codegen_gen.c -nt codegen_x.o ]; then
      echo "g05_ensure: cc -c codegen_gen.c → codegen_x.o (assemble / cold)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -c -o codegen_x.o codegen_gen.c
    fi
  fi
  # G-02e：产品链 C 源缺失或比 .o 新时强制重编（并入/删 TU 后跨机 git pull 必走此路径）
  # shellcheck disable=SC2086
  for o in $G05_OBJS; do
    c="${o%.o}.c"
    inc="${o%.o}.inc"
    src=""
    if [ -f "$c" ]; then
      src="$c"
    elif [ -f "$inc" ]; then
      src="$inc"
    fi
    # special: runtime_driver_no_c.o 源是 runtime.c（上面已热编）
    case "$o" in
      # 已在热路径专用 flags / .x seed 编译
      src/runtime_driver_no_c.o|src/runtime_pipeline_abi.o|src/runtime_link_abi.o|src/runtime_io_abi.o|src/runtime_driver_abi.o|src/runtime_driver_diagnostic.o|src/lsp/lsp_diag_pipeline_ctx.o|src/typeck/typeck_f64_bits.o|src/lsp/lsp_diag_pipeline_sizes_nostub.o|src/driver/target_cpu.o|src/asm/simd_enc.o|src/asm/simd_loop.o|src/asm/backend_enc_dispatch.o|src/asm/backend_arch_emit_dispatch.o|src/asm/backend_try_inline_dispatch.o|src/asm/backend_call_dispatch.o|src/asm/parser_asm_parse_expr_link.o|parser_asm_thin_glue.o|src/diag.o|src/x_seed_bridge.o|src/seed_link_compat.o|src/runtime_driver_strict_glue_stubs.o|src/driver/fmt_check_cmd_driver.o|src/lsp/lsp_diag.o|src/asm/user_asm_seed_bridge.o|src/asm/asm_backend_compat_stubs.o|src/asm/backend_x86_64_enc_c.o|x_frontend_link_alias.o|driver_fmt_x.o|driver_check_x.o|driver_test_x.o|lsp_io_x.o|lsp_io_std_heap_x.o|driver_build_x.o|driver_run_x.o|build_asm/*|*.s) continue ;;
    esac

    if [ -n "$src" ]; then
      if [ ! -f "$o" ] || [ "$src" -nt "$o" ]; then
        g05_cc_c "$o" "$src"
      fi
    fi
  done
fi

# --- Darwin bridge (PLATFORM: MACOS) ---
# g05_relink_env USER_ASM_LINK lists build_asm/asm_experimental_symbol_bridge.o for
# Darwin (weak platform_macho_write_macho_o_to_buf). bootstrap-driver-seed does not
# always emit it; after true L4 wipe g05 would MISSING and stop. Build from seed when
# listed in G05_OBJS — same source as build_xlang_asm ensure_asm_experimental_symbol_bridge_obj.
case " $G05_OBJS " in
  *" build_asm/asm_experimental_symbol_bridge.o "*)
    if [ ! -f build_asm/asm_experimental_symbol_bridge.o ] \
      && [ -f seeds/asm_experimental_symbol_bridge.from_x.c ]; then
      mkdir -p build_asm
      echo "g05_ensure: asm_experimental_symbol_bridge.o ← seed (Darwin cold L4)"
      bash scripts/cc_inc_tu.sh seeds/asm_experimental_symbol_bridge.from_x.c \
        build_asm/asm_experimental_symbol_bridge.o
    fi
    ;;
esac

# --- NL-07 L10: nostdlib companions for product g05 (PLATFORM: LINUX) ---
# G.7: scripts/bootstrap_nostdlib_shared.sh (same freestanding/stubs/atoi as build_xlang_asm).
# Only when G05_OBJS lists them (g05_relink_env after bootstrap_wants_nostdlib).
case " $G05_OBJS " in
  *" src/asm/freestanding_io_x86_64.o "*|*" src/asm/bootstrap_nostdlib_stubs.o "*|*" atoi_stub.o "*)
    # shellcheck disable=SC1091
    . scripts/bootstrap_nostdlib_shared.sh
    echo "g05_ensure: nostdlib companions (freestanding_io + stubs + weak atoi)"
    ensure_freestanding_io_x86_64_obj
    ensure_bootstrap_nostdlib_stubs_obj
    # Capture stdout (atoi path); progress already on stderr.
    _g05_atoi="$(ensure_atoi_stub_obj)"
    # If policy skipped atoi (strong T in runtime_panic), drop from list so miss check passes.
    if [ -z "$_g05_atoi" ]; then
      G05_OBJS="$(printf '%s\n' "$G05_OBJS" | sed 's/[[:space:]]atoi_stub\.o//g')"
    fi
    ;;
esac

# --- asm_full_link_stubs.o freshness check (PLATFORM: WINDOWS | MSYS | MINGW) ---
# Why: PE/MinGW has no weak function symbols (XLANG_WEAK expands empty; stubs are
#      strong). If user_asm_seed_bridge.o is rebuilt (e.g. .x changed) and
#      introduces a new U symbol matching gen_asm_full_link_stubs.pl regex
#      (platform_coff_*, arch_*, peephole_*, enc_*, ...), the existing
#      asm_full_link_stubs.o may be stale — missing the new stub — causing
#      the final g05 link to fail with "undefined reference" on PE. On ELF
#      (Linux/macOS) weak stubs mask this because real impls override, so the
#      race is Windows-only. The Makefile rule regenerates stubs only when its
#      .o prerequisites are newer, but within a single g05 run that rebuilds
#      user_asm_seed_bridge.o the stubs rule may not fire in the right order.
#      Fix at the root: regenerate stubs here (idempotent — gen_asm_full_link_stubs.pl
#      now writes a temp file and replaces only on content change; no-op when
#      symbol set is unchanged, so mtime stays stable and no spurious rebuilds).
#      Mirror of Makefile L1503-1509 stubs recipe. G.7: single authority is
#      gen_asm_full_link_stubs.pl; this is the shell-path equivalent of the
#      Makefile rule, not a second generator.
mkdir -p build_asm/seed_host
if [ -f build_asm/seed_host/asm_backend_partial.o ] && [ -x scripts/gen_asm_full_link_stubs.pl ]; then
  # G.7: single scan inventory = catalog DRIVER_SEED_HOST_STUBS_SCAN_BASE
  # (mk/driver_seed_export_lists.mk → ASM_GLUE_STANDALONE_O empty since wave309).
  # Do NOT hardcode pipeline_glue_standalone.o — seed retired; nm on missing .o
  # was soft Darwin noise on every g05. Mirror bootstrap_driver_seed_host_stubs.sh.
  # PLATFORM: SHARED.
  _g05_stubs_cat_query() {
    if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
      sed -n "s|^$1=||p" "${XLANG_CATALOG_CACHE_FILE}" | tail -n 1
    else
      bash scripts/driver_seed_obj_catalog.sh --shell 2>/dev/null \
        | sed -n "s|^$1=||p" | tail -n 1
    fi
  }
  _stubs_scan="$(_g05_stubs_cat_query DRIVER_SEED_HOST_STUBS_SCAN_BASE)"
  if [ -z "$_stubs_scan" ]; then
    echo "g05_ensure: WARN stubs scan base empty (catalog); skip asm_full_link_stubs regen" >&2
  else
    # Optional peers under seed_host (same order as bootstrap_driver_seed_host_stubs).
    [ -f build_asm/seed_host/asm_full.o ] && _stubs_scan="build_asm/seed_host/asm_full.o $_stubs_scan"
    _stubs_scan="build_asm/seed_host/asm_backend_partial.o $_stubs_scan"
    # Drop missing paths so gen_asm_full_link_stubs never nm-errors on retired leaves.
    _stubs_scan_present=""
    for _so in $_stubs_scan; do
      if [ -f "$_so" ]; then
        _stubs_scan_present="${_stubs_scan_present} ${_so}"
      else
        echo "g05_ensure: stubs scan skip missing ${_so}" >&2
      fi
    done
    _stubs_scan="${_stubs_scan_present# }"
    if [ -n "$_stubs_scan" ] && perl scripts/gen_asm_full_link_stubs.pl build_asm/seed_host/asm_full_link_stubs.c $_stubs_scan 2>&1; then
      if [ build_asm/seed_host/asm_full_link_stubs.c -nt build_asm/seed_host/asm_full_link_stubs.o ] 2>/dev/null; then
        echo "g05_ensure: cc -c build_asm/seed_host/asm_full_link_stubs.o (stubs.c updated)" >&2
        $CC $BASE_CFLAGS -c -o build_asm/seed_host/asm_full_link_stubs.o build_asm/seed_host/asm_full_link_stubs.c
      fi
    fi
  fi
fi

# --- Win Class AB: drop empty wpo_thin.o (0-byte traps; PREFER thin HARD BAN / CG002 on PE) ---
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    if [ -f src/runtime_pipeline_abi_asm_wpo_thin.o ] && [ ! -s src/runtime_pipeline_abi_asm_wpo_thin.o ]; then
      rm -f src/runtime_pipeline_abi_asm_wpo_thin.o
      echo "g05_ensure: rm empty runtime_pipeline_abi_asm_wpo_thin.o (Class AB)" >&2
    fi
    ;;
esac

# --- Win assign overrides (Class R wave767) ---
# PE first-wins: build src/win_assign_{var,field,index,deref}_override.o from seeds when on
# Windows so g05_relink_env can prepend them. No-op on Darwin/Linux.
# PLATFORM: WINDOWS | MSYS | MINGW.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*)
    for _pair in       "seeds/win_assign_var_override.c|src/win_assign_var_override.o"       "seeds/win_assign_field_override.c|src/win_assign_field_override.o"       "seeds/win_assign_index_override.c|src/win_assign_index_override.o"       "seeds/win_assign_deref_override.c|src/win_assign_deref_override.o"       "seeds/win_struct_let_init_override.c|src/win_struct_let_init_override.o"       "seeds/win_copy_large_struct_override.c|src/win_copy_large_struct_override.o"       "seeds/win_simd_splat_override.c|src/win_simd_splat_override.o"       "seeds/win_vector_type_let_init_override.c|src/win_vector_type_let_init_override.o"       "seeds/win_simd_select_shuffle_fma_override.c|src/win_simd_select_shuffle_fma_override.o"       "seeds/win_asm_parser_override.c|src/win_asm_parser_override.o"       "seeds/win_m8_tail_override.c|src/win_m8_tail_override.o"       "seeds/win_wpo_collect_walk_override.c|src/win_wpo_collect_walk_override.o"       "seeds/win_wpo_pgo_emit_override.c|src/win_wpo_pgo_emit_override.o"
    do
      _src="${_pair%%|*}"
      _out="${_pair#*|}"
      if [ -f "$_src" ]; then
        if [ ! -s "$_out" ] || [ "$_src" -nt "$_out" ]; then
          echo "g05_ensure: cc -c $_out (Win assign override)" >&2
          mkdir -p "$(dirname "$_out")"
          # shellcheck disable=SC2086
          if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o "$_out" "$_src"; then
            echo "g05_ensure: WARN Win override cc failed: $_src" >&2
          fi
        fi
      fi
    done
    ;;
esac

# --- Class S: ast_gen2.o for Win LEGACY g05 (link END) ---
# g05_relink_env defaults XLANG_LEGACY_C_FRONTEND=1 on Windows; LEGACY G05_OBJS
# ends with ast_gen2.o. Build it here so leftover-safe relink does not MISSING.
# PLATFORM: WINDOWS | when LEGACY explicitly on.
if [ "${XLANG_NO_C_SEED_LINK:-0}" != "1" ] && [ "${XLANG_LEGACY_C_FRONTEND:-0}" = "1" ]; then
  if [ -f ast_gen2.c ]; then
    if [ ! -s ast_gen2.o ] || [ ast_gen2.c -nt ast_gen2.o ]; then
      echo "g05_ensure: cc -c ast_gen2.o (LEGACY)" >&2
      # shellcheck disable=SC2086
      if ! $CC $BASE_CFLAGS -I. -Iinclude -Isrc -c -o ast_gen2.o ast_gen2.c; then
        echo "g05_ensure: WARN ast_gen2.cc failed" >&2
      fi
    fi
  fi
fi

# --- 齐备检查 ---
mkdir -p build_asm/seed_host
miss=0
# shellcheck disable=SC2086
for o in $G05_OBJS; do
  if [ ! -f "$o" ]; then
    echo "g05_ensure_relink_prereqs: MISSING $o" >&2
    miss=$((miss + 1))
  fi
done

if [ "$miss" -ne 0 ]; then
  echo "g05_ensure_relink_prereqs: $miss object(s) missing" >&2
  echo "  G-05 产品路径不调用 make 编 .o；请先冷启动补齐依赖图：" >&2
  echo "    ./xbuild bootstrap-driver-seed" >&2
  echo "    # 或叶透传（已有 build_asm/ 时）：" >&2
  echo "    ./xbuild compiler-make build-seed-asm-host pipeline_x.o driver_x.o" >&2
  exit 1
fi

n=$(echo "$G05_OBJS" | wc -w | tr -d ' ')
echo "g05_ensure_relink_prereqs OK ($n objs present, host=${G05_UNAME_S:-?}/${G05_UNAME_M:-?})"
