/* seeds/labi_freestanding_list.from_x.c — G-02f-276 P2 link_abi L7 freestanding list pure → R2 full
 * Logic source: src/runtime/labi_freestanding_list.x
 * Hybrid: SHUX_LABI_FREESTANDING_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14 / wave117 / wave136）：公共业务符号由 full .x 提供：
 *   labi_fs_env_freestanding
 *   labi_fs_io_sym_{count,at} + labi_fs_panic_sym
 *   labi_fs_ensure_catalog_{count,step_at}
 *   labi_fs_ensure_{out_base,src_rel,stem}
 *   labi_fs_{crt0,io}_{out_base,src_rel}
 *   + labi_fs_heap_{c_needle,o_sym}_* + labi_fs_memcpy_face_sym_* (wave117 tables)
 *   + link_abi_{generated_c,user_o}_needs_libc_heap
 *   + link_abi_user_o_needs_freestanding_nostdlib_face
 *   + wave136 labi_fs_gen_{fs,random,time,runtime}_needle_* +
 *     link_abi_generated_c_needs_{fs,random,time,runtime} pure orch
 *   + wave137 labi_fs_gen_{zlib,zstd,brotli}_needle_* +
 *     link_abi_generated_c_needs_{zlib,zstd,brotli} pure orch
 * Cap residual：ensure/cc/spawn IO；contains_substr / undef_sym 探针仍 mega。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_freestanding_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>

/* Cap residual (mega always): file scan + nm UNDEF probes used by pure needs orch. */
int link_abi_generated_c_contains_substr(const char *c_path, const char *needle);
int shux_link_obj_needs_undef_sym(const char *user_o, const char *sym);

#ifndef SHUX_LABI_FREESTANDING_LIST_FROM_X

/* ---- env ---- */
const char *labi_fs_env_freestanding(void) {
  return "SHUX_FREESTANDING";
}

/* ---- freestanding_io probe symbols (any undef → needs io) ---- */
int labi_fs_io_sym_count(void) {
  return 13;
}

const char *labi_fs_io_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "shux_sys_write";
  if (i == 1)
    return "shux_sys_read";
  if (i == 2)
    return "shux_sys_close";
  if (i == 3)
    return "shux_sys_exit";
  if (i == 4)
    return "shux_sys_open";
  if (i == 5)
    return "shux_sys_openat";
  if (i == 6)
    return "shux_sys_mmap";
  if (i == 7)
    return "shux_sys_munmap";
  if (i == 8)
    return "shux_sys_socket";
  if (i == 9)
    return "shux_sys_connect";
  if (i == 10)
    return "shux_sys_bind";
  if (i == 11)
    return "shux_sys_listen";
  if (i == 12)
    return "shux_sys_accept";
  return NULL;
}

/* ---- freestanding panic probe ---- */
const char *labi_fs_panic_sym(void) {
  return "shux_panic_";
}

/* ---- ensure catalog: out basename + asm source under compiler dir ---- */
int labi_fs_ensure_catalog_count(void) {
  return 2;
}

int labi_fs_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                   const char **src_rel_out) {
  if (i < 0 || i >= 2)
    return 0;
  if (i == 0) {
    if (stem_out)
      *stem_out = "crt0_user";
    if (out_base_out)
      *out_base_out = "crt0_user.o";
    if (src_rel_out)
      *src_rel_out = "src/asm/crt0_user_x86_64.s";
    return 1;
  }
  if (i == 1) {
    if (stem_out)
      *stem_out = "freestanding_io";
    if (out_base_out)
      *out_base_out = "freestanding_io.o";
    if (src_rel_out)
      *src_rel_out = "src/asm/freestanding_io_x86_64.s";
    return 1;
  }
  return 0;
}

const char *labi_fs_ensure_out_base(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "crt0_user.o";
  if (i == 1)
    return "freestanding_io.o";
  return NULL;
}

const char *labi_fs_ensure_src_rel(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "src/asm/crt0_user_x86_64.s";
  if (i == 1)
    return "src/asm/freestanding_io_x86_64.s";
  return NULL;
}

const char *labi_fs_ensure_stem(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "crt0_user";
  if (i == 1)
    return "freestanding_io";
  return NULL;
}

/* convenience accessors matching historic names */
const char *labi_fs_crt0_out_base(void) { return "crt0_user.o"; }
const char *labi_fs_crt0_src_rel(void) { return "src/asm/crt0_user_x86_64.s"; }
const char *labi_fs_io_out_base(void) { return "freestanding_io.o"; }
const char *labi_fs_io_src_rel(void) { return "src/asm/freestanding_io_x86_64.s"; }

/* ---- wave117: heap / nostdlib face pure tables + orch ---- */
int labi_fs_heap_c_needle_count(void) { return 9; }
const char *labi_fs_heap_c_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "malloc";
  if (i == 1)
    return "calloc";
  if (i == 2)
    return "realloc";
  if (i == 3)
    return "posix_memalign";
  if (i == 4)
    return "heap_alloc_c";
  if (i == 5)
    return "heap_free_c";
  if (i == 6)
    return "heap_realloc_c";
  if (i == 7)
    return "heap_alloc_zeroed_c";
  if (i == 8)
    return "getenv";
  return NULL;
}
int labi_fs_heap_o_sym_count(void) { return 6; }
const char *labi_fs_heap_o_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "malloc";
  if (i == 1)
    return "calloc";
  if (i == 2)
    return "realloc";
  if (i == 3)
    return "free";
  if (i == 4)
    return "posix_memalign";
  if (i == 5)
    return "getenv";
  return NULL;
}
int labi_fs_memcpy_face_sym_count(void) { return 3; }
const char *labi_fs_memcpy_face_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "memcpy";
  if (i == 1)
    return "memcmp";
  if (i == 2)
    return "memset";
  return NULL;
}

/* Pure orch: table + Cap residual contains_substr. PLATFORM: SHARED. */
int link_abi_generated_c_needs_libc_heap(const char *c_path) {
  int n;
  int i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_heap_c_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_heap_c_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}

/* Pure orch: table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_libc_heap(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_fs_heap_o_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_fs_heap_o_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* Pure orch: heap + mem* face. PLATFORM: LINUX freestanding face / SHARED tables. */
int link_abi_user_o_needs_freestanding_nostdlib_face(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  if (link_abi_user_o_needs_libc_heap(user_o) != 0)
    return 1;
  n = labi_fs_memcpy_face_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_fs_memcpy_face_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave136: generated-C string needs pure cold twin (tables + orch). */
int labi_fs_gen_fs_needle_count(void) {
  return 5;
}
const char *labi_fs_gen_fs_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "fs_open_read_c";
  if (i == 1)
    return "fs_last_error_c";
  if (i == 2)
    return "fs_close_c";
  if (i == 3)
    return "fs_read_c";
  if (i == 4)
    return "fs_write_c";
  return NULL;
}
int labi_fs_gen_random_needle_count(void) {
  return 3;
}
const char *labi_fs_gen_random_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "random_rng_smoke_c";
  if (i == 1)
    return "random_fill_bytes_c";
  if (i == 2)
    return "random_u64_c";
  return NULL;
}
int labi_fs_gen_time_needle_count(void) {
  return 10;
}
const char *labi_fs_gen_time_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_time_now_monotonic_ns";
  if (i == 1)
    return "std_time_sleep_ms";
  if (i == 2)
    return "std_time_duration_ns";
  if (i == 3)
    return "std_time_now_wall_ns";
  if (i == 4)
    return "std_time_format_timezone_smoke";
  if (i == 5)
    return "time_now_monotonic_ns_c";
  if (i == 6)
    return "time_sleep_ms_c";
  if (i == 7)
    return "time_duration_ns_c";
  if (i == 8)
    return "time_now_wall_ns_c";
  if (i == 9)
    return "time_format_timezone_smoke_c";
  return NULL;
}
int labi_fs_gen_runtime_needle_count(void) {
  return 3;
}
const char *labi_fs_gen_runtime_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "runtime_crash_evidence_collect_c";
  if (i == 1)
    return "runtime_panic";
  if (i == 2)
    return "runtime_abort";
  return NULL;
}
int link_abi_generated_c_needs_fs(const char *c_path) {
  int n, i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_gen_fs_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_gen_fs_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}
int link_abi_generated_c_needs_random(const char *c_path) {
  int n, i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_gen_random_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_gen_random_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}
int link_abi_generated_c_needs_time(const char *c_path) {
  int n, i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_gen_time_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_gen_time_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}
int link_abi_generated_c_needs_runtime(const char *c_path) {
  int n, i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_gen_runtime_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_gen_runtime_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}

/* wave137: compress lib generated_c needs pure (cold twin). */
int labi_fs_gen_zlib_needle_count(void) {
  return 7;
}
const char *labi_fs_gen_zlib_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "_compress2";
  if (i == 1)
    return "_deflate";
  if (i == 2)
    return "_inflate";
  if (i == 3)
    return "_uncompress";
  if (i == 4)
    return "compress2";
  if (i == 5)
    return "deflateInit";
  if (i == 6)
    return "inflateInit";
  return NULL;
}
int labi_fs_gen_zstd_needle_count(void) {
  return 5;
}
const char *labi_fs_gen_zstd_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "ZSTD_compress";
  if (i == 1)
    return "ZSTD_decompress";
  if (i == 2)
    return "ZSTD_create";
  if (i == 3)
    return "ZSTD_free";
  if (i == 4)
    return "ZSTD_isError";
  return NULL;
}
int labi_fs_gen_brotli_needle_count(void) {
  return 2;
}
const char *labi_fs_gen_brotli_needle_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "BrotliEncoder";
  if (i == 1)
    return "BrotliDecoder";
  return NULL;
}
int link_abi_generated_c_needs_zlib(const char *c_path) {
  int n, i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_gen_zlib_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_gen_zlib_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}
int link_abi_generated_c_needs_zstd(const char *c_path) {
  int n, i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_gen_zstd_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_gen_zstd_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}
int link_abi_generated_c_needs_brotli(const char *c_path) {
  int n, i;
  if (!c_path || !c_path[0])
    return 0;
  n = labi_fs_gen_brotli_needle_count();
  for (i = 0; i < n; i++) {
    const char *needle = labi_fs_gen_brotli_needle_at(i);
    if (needle && needle[0] && link_abi_generated_c_contains_substr(c_path, needle) != 0)
      return 1;
  }
  return 0;
}


#else
const char *labi_fs_env_freestanding(void);
int labi_fs_io_sym_count(void);
const char *labi_fs_io_sym_at(int i);
const char *labi_fs_panic_sym(void);
int labi_fs_ensure_catalog_count(void);
int labi_fs_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                   const char **src_rel_out);
const char *labi_fs_ensure_out_base(int i);
const char *labi_fs_ensure_src_rel(int i);
const char *labi_fs_ensure_stem(int i);
const char *labi_fs_crt0_out_base(void);
const char *labi_fs_crt0_src_rel(void);
const char *labi_fs_io_out_base(void);
const char *labi_fs_io_src_rel(void);
int labi_fs_heap_c_needle_count(void);
const char *labi_fs_heap_c_needle_at(int i);
int labi_fs_heap_o_sym_count(void);
const char *labi_fs_heap_o_sym_at(int i);
int labi_fs_memcpy_face_sym_count(void);
const char *labi_fs_memcpy_face_sym_at(int i);
int link_abi_generated_c_needs_libc_heap(const char *c_path);
int link_abi_user_o_needs_libc_heap(const char *user_o);
int link_abi_user_o_needs_freestanding_nostdlib_face(const char *user_o);
/* wave136: C-path PRIMARY OS/fs generated_c needs pure (L7). */
int labi_fs_gen_fs_needle_count(void);
const char *labi_fs_gen_fs_needle_at(int i);
int labi_fs_gen_random_needle_count(void);
const char *labi_fs_gen_random_needle_at(int i);
int labi_fs_gen_time_needle_count(void);
const char *labi_fs_gen_time_needle_at(int i);
int labi_fs_gen_runtime_needle_count(void);
const char *labi_fs_gen_runtime_needle_at(int i);
int link_abi_generated_c_needs_fs(const char *c_path);
int link_abi_generated_c_needs_random(const char *c_path);
int link_abi_generated_c_needs_time(const char *c_path);
int link_abi_generated_c_needs_runtime(const char *c_path);
/* wave137: compress lib generated_c needs pure (L7). */
int labi_fs_gen_zlib_needle_count(void);
const char *labi_fs_gen_zlib_needle_at(int i);
int labi_fs_gen_zstd_needle_count(void);
const char *labi_fs_gen_zstd_needle_at(int i);
int labi_fs_gen_brotli_needle_count(void);
const char *labi_fs_gen_brotli_needle_at(int i);
int link_abi_generated_c_needs_zlib(const char *c_path);
int link_abi_generated_c_needs_zstd(const char *c_path);
int link_abi_generated_c_needs_brotli(const char *c_path);
#endif

int labi_freestanding_list_slice_marker(void) {
  return 1;
}