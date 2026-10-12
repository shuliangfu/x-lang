/* G-02f-343/344/345 / R2 thin full：PREFER hybrid thin 由 src/runtime_driver_abi_thin.x；
 * rest XLANG_L2_RDABI_THIN_FROM_X（无 pure-dup _impl；slice_marker + Cap residual 体）。
 * pure 深迁：scan/has/argv_collect/target_os/fail/smoke/peek/entry_len_i32/large_stack orch
 *   + getenv 门闩（force_c / asm skip / emit_heavy / module_only / metric / no_large_stack /
 *   sanitize_address env）
 *   + 数值 env（parse_u32 + stack_limit_want_bytes + phase_timing_enabled）在 thin.x；
 *   + wave1 Cap residual pure：9× flag-slot BSS 权威在 thin.x；FROM_X 无 pure-dup flag_slot _impl；
 *   + wave2 Cap residual pure：path/len BSS 权威在 thin.x（dep path · entry_source_len ·
 *     path_last_preprocess_len）；FROM_X 无 pure-dup path/len store/load _impl；
 *   + wave3 Cap residual pure：format print 权威在 thin.x（check_ok / fail rc·path /
 *     smoke parse·typeck：append_* + diag_report*，无 va_list reportf）；FROM_X 无 pure-dup
 *     print/fail format _impl；
 *   + wave4 Cap residual pure：defines_set_at（G.7 xlang_ptr_slot_set）+ os_define_lit
 *     字面量表在 thin.x；FROM_X 无 pure-dup set_at/os_lit _impl；
 *   + wave5 Cap residual pure：phase timing BSS + begin/end 在 thin.x；FROM_X 无 pure-dup
 *     begin/end _impl；
 *   + wave6 Cap residual pure：phase_timing_flush 在 thin.x（whole-ms append + diag_report）；
 *     FROM_X 无 pure-dup flush _impl；
 *   + wave7 Cap residual pure：compile_phase_now_sec 在 thin.x（→ xlang_driver_wall_clock_sec）；
 *     FROM_X 无 pure-dup now_sec _impl；gettimeofday/time 永久 OS 面 xlang_driver_wall_clock_sec；
 *   + wave8 Cap residual pure：call_fn 编排 pure；间接调用永久 OS 面 xlang_driver_call_fn_void_arg；
 *     FROM_X rest 无 pure-dup call_fn _impl；
 *   + wave9 Cap residual pure：bump_stack_limit orch pure；setrlimit 永久 OS 面 xlang_driver_bump_stack_limit；
 *     FROM_X rest 无 pure-dup setrlimit/to_impl _impl；
 *   + wave10 Cap residual pure：uname host defines → 永久 OS 面 xlang_driver_argv_append_uname；
 *     FROM_X rest 无 pure-dup append_uname _impl；struct utsname 不进 .x；
 *   + wave11 Cap residual pure：path-read IO → 永久 OS 面 xlang_driver_path_read_preprocess_malloc；
 *     FROM_X rest 无 pure-dup path_read _impl；file view + preprocess 不进 .x；
 *   + wave12 Cap residual pure：pthread 创建 → 永久 OS 面 xlang_driver_run_thread_on_large_stack_pthread；
 *     FROM_X rest 无 pure-dup pthread _impl；pthread_attr/posix_memalign 不进 .x；
 *   + wave13 Cap residual pure：entry_source_len load debug note 在 thin.x
 *     （XLANG_DEBUG_PIPE truthy → append_* + diag_report；no va_list reportf）；
 *     FROM_X rest 无 pure-dup load_and_maybe_debug _impl；cold keeps integer-note twin；
 *   + wave14 Cap residual pure：rt_asm_stub GAS 行表 + out_append_cstr 在 thin.x
 *     （data[9MiB]+i32 len 宿主布局 LE；无 memcpy/strlen）；FROM_X 无 pure-dup gas/append；
 *   + wave15 Cap residual pure：rt_entry 缓冲槽 + path_max/entry_dir 在 thin.x
 *     （u8[N] BSS；fmt_argv 见 wave21）；FROM_X 无 pure-dup entry/path buf slots；
 *   + wave16 Cap residual pure：driver_x_emit work BSS + get/set/reset/cleanup 在 thin.x
 *     （p raw u8[208]+xlang_ptr_slot_* · i32[17] · usize[5]；free+dep_ctx destroy）；FROM_X 无 pure-dup work；
 *   + wave17 Cap residual pure：driver_asm_work BSS + get/set/reset/cleanup 在 thin.x
 *     （p raw u8[200] 25×ptr · i32[16] · usize[4]；free+dep_ctx+fclose；tmp_path[0] clear）；FROM_X 无 pure-dup asm work；
 *   + wave18 Cap residual pure：driver_parsed_work BSS + get/set/reset/cleanup 在 thin.x
 *     （p raw u8[192] 24×ptr · i32[14] · usize[4]；free+dep_ctx+fclose cf；unlink tmp_c；tmp slots clear）；FROM_X 无 pure-dup parsed work；
 *   + wave19 Cap residual pure：driver_pipeline_dep_ctx i32 字段 get/set 在 thin.x
 *     （LP64 固定 offsetof + wave14 LE load/store；无 C 结构体）；
 *     FROM_X 无 pure-dup dep_ctx field _impl；
 *   + wave20 Cap residual pure：driver_preamble_{io_net,fs_path}_line_at/count 在 thin.x
 *     （G.7 xlang_ptr_slot_get + always-seed *_lines_raw；巨型表仍 rt_preamble）；
 *     FROM_X 无 pure-dup line_at/count；
 *   + wave21 Cap residual pure：driver_entry_fmt_argv_slot 在 thin.x
 *     （u8 lit BSS "xlang"/"fmt" + 2× LP64 ptr slots via G.7 xlang_ptr_slot_set；无 *u8[2] lit）；
 *     FROM_X 无 pure-dup fmt_argv；
 *   + wave22 Cap residual pure：driver_preamble_fputs 在 thin.x
 *     （null 守卫 + g05 prologue xlang_driver_fputs_opaque FILE* cast；.x 无 FILE*）；
 *     FROM_X 无 pure-dup fputs；
 *   + wave23 Cap residual pure：calloc 族 + driver_asm_pctx_apply_host_defaults 在 thin.x
 *     （libc calloc/malloc/memset + pipeline_sizeof_*；host #ifdef → 永久 OS residual helper）；
 *     FROM_X 无 pure-dup calloc/host_defaults；
 *   + wave24 Cap residual pure：outbuf free/len/data + ptr/size table free/get/set
 *     + diag_snapshot_free 在 thin.x（配对 wave23 calloc；G.7 xlang_ptr_slot_* + LE usize）；
 *     FROM_X 无 pure-dup free/get/set；
 *   + wave25 Cap residual pure：tmp path BSS 槽（asm 64B + parsed 64B/256B）在 thin.x；
 *     open_out 始终 seed 且只经 accessor 写 buf；FROM_X 无 pure-dup tmp 槽；
 *   + wave26 Cap residual pure：driver_parsed_fclose / fclose_rc / write_out 在 thin.x
 *     （g05 stdout_ptr + fclose/fwrite opaque；write_io_net/fs_path 仍 rt_preamble）；
 *     FROM_X 无 pure-dup fclose/write_out；
 *   + wave27 Cap residual pure：driver_parsed_open_out_file 在 thin.x
 *     （stdout 门控 pure；mkstemp/rename/close/unlink + g05 fopen_write_opaque；
 *      永久 OS residual xlang_driver_tmp_prefix 藏 XLANG_TMP_PREFIX #ifdef）；
 *     FROM_X 无 pure-dup open_out；
 *   + wave28 Cap residual pure：driver_parsed_invoke_cc 在 thin.x
 *   + wave31 Cap residual pure：deps_has_std_io_{core,driver} + apply_preamble_skip
 *     + maybe_dump_prep 在 thin.x（G.7 ptr_slot + strcmp；mask bits=codegen.h；
 *       dump 无 va_list）；FROM_X 无 pure-dup；
 *   + wave32 Cap residual pure：driver_parsed field accessors + try_c_after_pp 在 thin.x
 *     （LP64 offsetof DriverCompileParsedAbi + LE i32 / G.7 ptr；lib_roots=p+16；
 *       opt default BSS "2"；try_c_after_pp 产品 NO_C 固定 -2）；FROM_X 无 pure-dup；
 *     （std .o path pack + set/clear user .o + xlang_invoke_cc + fail/KEEP_C cleanup；
 *      c_paths[1] via G.7 xlang_ptr_slot_set；无 va_list reportf）；
 *     FROM_X 无 pure-dup invoke_cc；
 *   + wave33 Cap residual pure：driver_x_emit clear/bind/take/get/lib_root_at/
 *     effective_lib_roots + try_extern_via_cparser 在 thin.x
 *     （G.7 xlang_ptr_slot_* on always-seed c_path_cell / lib_roots_raw / path+lib slots；
 *       Cap-global-bss data 仍 rt_emit_state；path/scan/n/want slots always-seed）；
 *     FROM_X 无 pure-dup clear/bind/take/get/effective/try_extern；
 *   + wave34 Cap residual pure：driver_asm try_c stubs + use_compiler_impl_c +
 *     bind_lib_roots + argv0 + collect_defines/defines_as_u8/ndefines_get 在 thin.x
 *     （产品 NO_C 固定 -2/-1/0；one_root BSS + G.7；defines 表 BSS 64×LP64 +
 *       pure argv_collect_defines）；FROM_X 无 pure-dup；
 *   + wave35 Cap residual pure：driver_typeck_ndep_set / dep_ptrs_set +
 *     driver_diag_push_file / restore + driver_dispatch_lib_root_at / opt_default 在 thin.x
 *     （G.7 typeck_ndep_store + dep_module/arena_set；diag_push_file/restore；
 *       G.7 xlang_ptr_slot_get；opt default 共用 wave32 BSS lit "2"）；FROM_X 无 pure-dup；
 *   + wave36 Cap residual pure：driver_dispatch_lib_roots_from_key +
 *     driver_dispatch_run_compiler_parsed 在 thin.x
 *     （BSS 16×512 + 16×LP64 roots；G.7 driver_lib_roots_from_key；
 *       BSS pack DriverCompileParsedAbi 176B + driver_run_compiler_parsed；
 *       opt default 共用 wave32 lit "2"）；FROM_X 无 pure-dup；
 *   + wave37 Cap residual pure：driver_arena/module_static_{slot,size} +
 *     driver_run_stack_esc_gate_on_large_stack + driver_parser_diag_fail_tok_kind 在 thin.x
 *     （always-seed Cap-global base + Cap-fn-ptr fn_ptr residual；BSS pack slice +
 *       parser_diag_fail_at_token_kind；固定 128MiB/2MiB）；FROM_X 无 pure-dup；
 *   + wave38 Cap residual pure：driver_asm_elf_ctx_free + driver_parse_into_buf_rc 在 thin.x
 *     （free 配对 wave23 elf_ctx_calloc；Cap-struct-return residual
 *       xlang_parser_parse_into_buf_rc 藏 parser_ParseIntoResult）；FROM_X 无 pure-dup；
 *   + wave39 Cap residual pure：driver_stdio_stdout + driver_asm_fwrite +
 *     driver_x_emit_fwrite_stdout 在 thin.x
 *     （g05 stdout_ptr + fwrite_opaque；Cap OS residual xlang_driver_fwrite_stdout_n
 *       藏 xlang_io_write(1,…) Cap io 写与字节数返回 ABI；9.7.1 起无 libc FILE star）；
 *     FROM_X 无 pure-dup；
 *   + wave40 Cap residual pure：driver_stdio_stderr + driver_asm_fflush_stdout +
 *     driver_asm_fopen_wb + driver_asm_write_metric_o 在 thin.x
 *     （g05 stderr_ptr / fflush_stdout / fopen_wb_opaque；write_metric pure orch
 *       fopen_wb + fwrite 1×0 + fclose_opaque）；FROM_X 无 pure-dup；
 *   + wave41 Cap residual pure：driver_asm_mkstemp_fdopen 在 thin.x
 *     （null + SHARED gate xlang_driver_asm_mkstemp_fdopen_enabled→1；
 *       template pure tmp_prefix+"xlang_asm_XXXXXX"；mkstemp/close/unlink；
 *       g05 xlang_driver_fdopen_wb_opaque）；FROM_X 无 pure-dup；
 *   + wave42 Cap residual pure：driver_exec_compiled_body 在 thin.x
 *     （null/argc + G.7 path_is_non_exe pure；Cap residual
 *       xlang_driver_exec_scan_out_path_opaque + xlang_driver_exec_spawn_wait）；
 *   + wave43 Cap residual pure：driver_dispatch_sibling_try_spawn 在 thin.x
 *     （null/argc + G.7 driver_argv0_basename_is pure；path pure BSS 512；
 *       Cap residual xlang_driver_sibling_argv0_get + access_spawn）；
 *   + wave44 Cap residual pure：driver_print_usage_write 在 thin.x
 *     （color policy pure：NO_COLOR / FORCE / isatty；Cap residual
 *       xlang_driver_usage_write_stdout 持巨型 plain/color lit，
 *       经 xlang_io_write(1,…) Cap io 写，无 libc FILE star）；
 *     wave29：pure io_net N=224 + WEAK_IO skip 178..181；表数据仍 seed；
 * FROM_X 剔 pure-dup _impl（H↓）。
 */
/* Generated from src/runtime_driver_abi.x (G-02f-29/41/45..57/83 true .x + C tail).
 * G-02f-116 true .x pure helpers.
 * G-02f-104 helper gates.
 * G-02f-243: P1-6 open — entry_source_len_i32 saturate + scan_top_level_import pure.
 * G-02f-244: phase index + stack want + path import orchestrate pure.
 * G-02f-245: argv_collect_defines main loop pure; uname host defines locked.
 * G-02f-246: large_stack early-exit/current-stack orch pure; P1-6 soft near-close.
 * Regen: ./xlang-c -E -L .. src/runtime_driver_abi.x > /tmp/dabi.c
 *         merge flags/env/phase/peek/smoke/stack/defines; C uname + pthread create bulk.
 * .x covers: + argv_collect pure + large_stack orch + entry_len/scan/stack want/path.
 */
#include <xlang_weak.h>
#include "win32_compat.h"
#include "runtime_driver_abi.h"
#include "runtime_io_abi.h"
#include "runtime_pipeline_abi.h"
#include "runtime_abi.h"
#include "diag.h"
#include "runtime_diag_codes.h"

#ifdef XLANG_L2_RDABI_THIN_FROM_X
int32_t driver_check_quiet_ok_get(void);
int32_t driver_check_diag_emitted_get(void);
int32_t driver_is_large_stack_thread(void);
void driver_large_stack_thread_mark(int on);
void driver_run_fn_on_current_large_stack(void *(*fn)(void *), void *arg);
int32_t driver_compile_phase_index_ok(int32_t phase);
char driver_ascii_toupper(char c);
int32_t driver_typeck_skip_large_entry(void);
int32_t driver_sanitize_address_get(void);
int32_t driver_typeck_force_c_enabled(void);
int32_t driver_asm_build_skip_typeck(void);
int32_t driver_asm_entry_emit_heavy(void);
int32_t driver_pipeline_no_large_stack_env(void);
int32_t driver_asm_entry_module_only_from_env(void);
int32_t driver_asm_parse_metric_only_from_env(void);
int32_t driver_pipeline_entry_source_len_i32(void);
void driver_defines_set_at(const char **defines, int i, const char *s);
int64_t driver_stack_limit_want_bytes(void);
int64_t driver_path_last_preprocess_len(void);
void driver_path_last_preprocess_len_store(int64_t len);
void driver_current_dep_path_store(const char *path);
const char *driver_current_dep_path_load(void);
void driver_pipeline_entry_source_len_store(size_t len);
size_t driver_pipeline_entry_source_len_load_and_maybe_debug(void);
int32_t driver_target_arg_os_kind(const char *target);
void driver_bump_stack_limit(void);
void driver_set_pipeline_entry_source_len(size_t len);
int compile_phase_timing_enabled(void);
int32_t driver_compile_phase_timing_enabled(void);
const char *driver_os_define_lit(int kind);
void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg);
int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines);
int driver_source_has_top_level_import(const char *src, size_t src_len);
/* wave5: phase timing BSS pure in thin — flush Cap reads via getters. */
double driver_compile_phase_acc_ms_get(int32_t phase);
void driver_compile_phase_timing_clear(void);
/* wave7: compile_phase_now_sec pure in thin → xlang_driver_wall_clock_sec (no pure-dup _impl). */
/* wave1: flag-slot BSS pure in thin — no public→_impl rename (rest drops pure-dup slots). */
/* wave2: path/len BSS pure in thin — path_read rest writes len via thin store. */
/* wave11: path_read body is permanent OS surface xlang_driver_path_read_preprocess_malloc
 * (no pure-dup path_read _impl rename under FROM_X). */
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: driver_abi path/uname format → Cap snprintf */
/* G.7: single Cap authority for this cold/rest TU (after stdio). */
#undef snprintf
#define snprintf xlang_snprintf
/* Cap residual 9.7.1: opaque stream face → fd-handle (write/open/close authorities). */
#include "xlang_driver_stream_cap.h"

#ifndef _WIN32
#include <sys/time.h>
#include <sys/utsname.h>
#include <xlang_time_cap.h> /* Cap residual 9.1.5 clock_gettime (wall clock) */
#ifndef _WIN32
#include <sys/resource.h>
#endif
#endif
#include <pthread.h>
/* PLATFORM: SHARED — realpath (opaque surface) on POSIX/Apple; unistd may already
 * be pulled later for Cap residual; include here so WEAK helpers stay self-contained. */
#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#endif

/*
 * Stage 12.0.5 pure-asm freestanding surface residual (G.7 有则补全 — single exported
 * authority; peer of fmt_check_cmd.from_x.c xlang_fmt_* WEAK bodies):
 *
 * pure-asm of runtime_pipeline_abi.x / runtime_driver_abi_thin.x leaves U
 * xlang_driver_{fputs,stdout,fclose,fwrite,fopen_*,stderr,fflush,fdopen,realpath}_opaque
 * and xlang_driver_{pipeline_run_x,asm_elf_o}_thread_fn_ptr. Host-cc prologue
 * (rt_prefer_try_x_to_o / g05_ensure) only injects static inline bodies (local `t` —
 * not exported). Without global defs, pure_asm_x_to_o rejected the .o and product
 * pabi prefer forced RT=0 (skip pure-asm install).
 *
 * Always export XLANG_WEAK bodies here for both cold monofile and FROM_X rest so
 * pure-asm thin / mega .o U's resolve at pure-ld against this leaf (always on
 * freestanding bag). Keep prologue static inline for -E inlining only; local `t`
 * does not multidef against these weak globals.
 *
 * Cap residual 9.7.1: the face no longer wraps libc FILE*. Every body encodes
 * raw fds via xlang_driver_stream_cap.h and routes I/O through the Cap
 * authorities (xlang_io_write / xlang_io_open_write / xlang_proc_close_fd), so
 * this TU carries zero stdio UNDEFs. Signatures stay `uint8_t *` (opaque),
 * which keeps every .x consumer source-compatible.
 *
 * PLATFORM: SHARED — fd-handle face (encoding in xlang_driver_stream_cap.h);
 * Win32 realpath null; thread_fn_ptr casts require product pipeline_run_x_thread_fn
 * and xlang_asm_codegen_elf_o_thread_fn T defs at final pure-ld (present on bag).
 */
XLANG_WEAK int32_t xlang_driver_fputs_opaque(uint8_t *s, uint8_t *stream) {
    long n;
    int fd;
    if (!s || !stream) {
        return (int32_t)-1;
    }
    fd = xlang_driver_handle_to_fd(stream);
    if (fd < 0) {
        return (int32_t)-1;
    }
    /* Mirrors fputs contract used by callers (driver_preamble_fputs checks <0):
     * return byte count written, or -1 on error. */
    n = xlang_io_write(fd, s, strlen((const char *)(void *)s));
    return (int32_t)n;
}

XLANG_WEAK uint8_t *xlang_driver_stdout_ptr(void) {
    return xlang_driver_handle_from_fd(1);
}

XLANG_WEAK int32_t xlang_driver_fclose_opaque(uint8_t *stream) {
    return (int32_t)xlang_driver_handle_close(stream);
}

XLANG_WEAK int32_t xlang_driver_fwrite_opaque(uint8_t *data, int32_t len, uint8_t *stream) {
    long n;
    int fd;
    if (!data || len < 0 || !stream) {
        return 1;
    }
    if (len == 0) {
        return 0;
    }
    fd = xlang_driver_handle_to_fd(stream);
    if (fd < 0) {
        return 1;
    }
    n = xlang_io_write(fd, data, (size_t)len);
    return n == (size_t)len ? 0 : 1;
}

XLANG_WEAK uint8_t *xlang_driver_fopen_write_opaque(uint8_t *path) {
    int fd;
    if (!path) {
        return (uint8_t *)0;
    }
    /* fopen(path,"w") ≡ O_WRONLY|O_CREAT|O_TRUNC (0644) — the Cap authority. */
    fd = xlang_io_open_write((const char *)(void *)path);
    return fd < 0 ? (uint8_t *)0 : xlang_driver_handle_from_fd(fd);
}

XLANG_WEAK uint8_t *xlang_driver_stderr_ptr(void) {
    return xlang_driver_handle_from_fd(2);
}

XLANG_WEAK void xlang_driver_fflush_stdout(void) {
    /* Raw fd 1 writes are unbuffered — nothing to flush (9.7.1). */
}

XLANG_WEAK uint8_t *xlang_driver_fopen_wb_opaque(uint8_t *path) {
    int fd;
    if (!path) {
        return (uint8_t *)0;
    }
    /* Binary "wb" face: xlang_io_open_write is _O_BINARY on Windows (9.7.1),
     * so metric .o / asm .o emission cannot be CRLF-corrupted. */
    fd = xlang_io_open_write((const char *)(void *)path);
    return fd < 0 ? (uint8_t *)0 : xlang_driver_handle_from_fd(fd);
}

XLANG_WEAK uint8_t *xlang_driver_fdopen_wb_opaque(int32_t fd) {
    if (fd < 0) {
        return (uint8_t *)0;
    }
    /* fdopen(fd,"wb") consumed the caller's fd (mkstemp); the handle now owns
     * it — fclose_opaque/handle_close releases it, same contract as libc. */
    return xlang_driver_handle_from_fd((int)fd);
}

#if defined(_POSIX_VERSION) || defined(__APPLE__)
XLANG_WEAK uint8_t *xlang_driver_realpath_opaque(uint8_t *path, uint8_t *resolved) {
    char *r;
    if (!path || !resolved) {
        return (uint8_t *)0;
    }
    r = realpath((const char *)(void *)path, (char *)(void *)resolved);
    return (uint8_t *)(void *)r;
}
#else
/* PLATFORM: WINDOWS — no POSIX realpath; pure path_try leaves input path. */
XLANG_WEAK uint8_t *xlang_driver_realpath_opaque(uint8_t *path, uint8_t *resolved) {
    (void)path;
    (void)resolved;
    return (uint8_t *)0;
}
#endif

/* Match pure .x export: *u8 arg / *u8 return (not void* — gcc conflicts with pure body). */
extern uint8_t *pipeline_run_x_thread_fn(uint8_t *);
extern uint8_t *xlang_asm_codegen_elf_o_thread_fn(uint8_t *);

XLANG_WEAK uint8_t *xlang_driver_pipeline_run_x_thread_fn_ptr(void) {
    return (uint8_t *)(void *)pipeline_run_x_thread_fn;
}

XLANG_WEAK uint8_t *xlang_driver_asm_elf_o_thread_fn_ptr(void) {
    return (uint8_t *)(void *)xlang_asm_codegen_elf_o_thread_fn;
}

/* wave228 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv). */
extern char *link_abi_getenv(const char *name);

/** nostdlib 下勿用 glibc ctype 宏（会引用 __ctype_toupper_loc）；本地 ASCII 大写。 */
/* G-02f-119：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_L2_RDABI_THIN_FROM_X removed */
#endif





/* G-02f-41: flag slot protos (defs after static storage) */
int32_t *driver_check_only_flag_slot(void);
int32_t *driver_check_diag_emitted_flag_slot(void);
int32_t *driver_freestanding_flag_slot(void);
int32_t *driver_sanitize_address_flag_slot(void);
int32_t *driver_fmt_check_only_flag_slot(void);
int32_t *driver_x_pipeline_skip_typeck_flag_slot(void);
int32_t *driver_x_pipeline_skip_codegen_flag_slot(void);
int32_t *driver_skip_codegen_dep_0_flag_slot(void);
int32_t driver_pipeline_entry_source_len_i32(void);
int32_t *driver_large_stack_thread_flag_slot(void);
void driver_current_dep_path_store(const char *path);
const char *driver_current_dep_path_load(void);
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
void driver_bump_stack_limit(void);
void xlang_driver_bump_stack_limit(int64_t want_bytes);
int64_t driver_stack_limit_want_bytes(void);
void driver_defines_set_at(const char **defines, int i, const char *s);
const char *driver_os_define_lit(int kind);
int xlang_driver_argv_append_uname(const char **defines, int ndefines, int max_defines);
int32_t driver_target_arg_os_kind(const char *target);
void driver_run_thread_on_large_stack(void *(*fn)(void *), void *arg);
void xlang_driver_run_thread_on_large_stack_pthread(void *(*fn)(void *), void *arg);
void xlang_driver_call_fn_void_arg(void *(*fn)(void *), void *arg);
int32_t driver_pipeline_no_large_stack_env(void);
int driver_source_scan_top_level_import(const char *src, size_t src_len);
char *xlang_driver_path_read_preprocess_malloc(const char *path);
char *driver_path_read_preprocess_malloc(const char *path);
int64_t driver_path_last_preprocess_len(void);
void driver_pipeline_entry_source_len_store(size_t len);
size_t driver_pipeline_entry_source_len_load_and_maybe_debug(void);
int32_t driver_compile_phase_timing_enabled(void);
int32_t driver_compile_phase_index_ok(int32_t phase);

/** xlang check：非 0 时 typeck 通过后跳过 codegen 与链接（C 与 X pipeline 共用）。 */
/* wave1 pure：hybrid thin owns BSS; cold seed keeps statics + flag_slot. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 设置 check-only 模式。
 * 参数：v 非 0 启用。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 查询 check-only 模式。
 * 返回值：1 表示启用，0 表示否。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** `-freestanding` / XLANG_FREESTANDING：用户程序 nostdlib 静态链（S4）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 设置 freestanding 链接模式。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 查询 freestanding 链接模式。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** M-6：`-fsanitize=address` 时强制数组/切片 INDEX 边界检查。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 设置 sanitize=address 标志。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 查询 sanitize=address；显式标志或 XLANG_SANITIZE_ADDRESS 环境变量。
 * pure 权威：thin.x driver_sanitize_address_get（flag + env 门闩）；
 * 冷启动保留全 C 体；FROM_X 无 pure-dup env_enabled_impl（H↓）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** xlang fmt --check：仅校验格式，不写回。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 查询 fmt --check 模式。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* 【Why 根源】MinGW PE 格式不真正支持 XLANG_WEAK：weak 函数被当作普通强符号，
 * 与 fmt_check_cmd.c 的强符号并存；--allow-multiple-definition 选第一个遇到的定义，
 * 链接器不保证按 OBJS_CORE 顺序选 fmt_check_cmd.o 的版本。当 weak 版本被选中且返回 0，
 * check 成功后会逐文件打印 "check OK"，与 deno check 静默成功语义矛盾。
 * 【Invariant】deno check 语义：成功时静默。weak 默认值必须返回 1（静默），保证无论
 * Windows 链接器选中哪个版本，driver_print_check_ok 都不输出逐文件 check OK。
 * 【Asm/Perf】macOS/Linux 上 weak 正常工作，强符号覆盖 weak 默认值，此改动无影响。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 统一 xlang check 成功行；deno 风格批量 check 成功时由 fmt_check_cmd 保持静默。
 * 参数：input_path 被检查文件路径（可为 NULL）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 非 0 时 pipeline_impl_typecheck 跳过 .x typeck。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 供 pipeline.x 读取：是否跳过 X typeck。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 设置 X typeck 跳过标志（C 预检后由 runtime 置位/清位）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 非 0 时 pipeline_impl_run_all 跳过 .x C codegen。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 供 pipeline.x 读取：是否跳过 X C codegen。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 设置 X C codegen 跳过标志。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 非 0 时入口模块 typeck 走 C 的 typeck_module（大模块 asm 构建时避免 .x typeck 栈过深）。
 * pure 权威：thin.x driver_typeck_force_c_enabled；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 当前线程是否已在 driver_run_thread_on_large_stack 创建的大栈 pthread 内。
 * 【Why 逻辑根源】nostdlib 静态链下 pthread 是 stub（bootstrap_nostdlib_pthread_is_stub()=1），
 *                driver_run_thread_on_large_stack 在当前栈运行不创建新线程，全程单线程无需 TLS。
 *                之前用 _Thread_local 时 gcc 对 _impl 生成 `mov %fs:0x0,%rax; add $-16,%rax` 间接访问，
 *                bootstrap_init_static_tls 只把 %fs 设为 &bootstrap_tls（48 字节 block），
 *                %fs:0x0 读到 BSS 默认值 0，0-16=0xfffffffffffffff0 无效地址 → SIGSEGV。
 *                stage1 工作纯属巧合：编译器把 driver_is_large_stack_thread 内联为 `mov %fs:-16,%eax`。
 * 【Invariant 状态不变量】nostdlib 路径下进程内只有 1 个执行流，单变量即正确反映"在大栈线程上下文"标志。
 * 【Asm/Perf 性能预期】普通 static int 在 BSS 中，访问为 RIP-relative 一次 load，比 TLS 间接访问快且无 %fs 依赖。 */
/* wave1 pure：hybrid thin owns large_stack flag BSS; cold seed keeps static + slot. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif


/**
 * 供 ast_pool / pipeline glue 查询：LSP 主循环已在大栈线程上时，typeck 勿再 spawn 嵌套 pthread。
 * 返回值：非 0 表示当前在大栈线程上下文。
 */

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 标记当前线程大栈上下文（runtime pthread trampoline 进入/退出时调用）。
 * 参数：on 非 0 进入，0 退出。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave2 pure：hybrid thin owns entry_source_len BSS; cold seed keeps static + store/load. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 非 0 表示入口源码过大，应跳过 merge/library 全量 typeck（.x 路径上易 segfault）。
 * 返回值：len > 150000 时为 1，否则 0。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * build_xlang_asm 单模块 -o：XLANG_ASM_BUILD_SKIP_TYPECK=1 时跳过 .x typeck。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * typeck 第二遍 EMIT_HEAVY：XLANG_ASM_ENTRY_EMIT_HEAVY=1 时 pipeline 跳过文本 asm codegen。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * build_xlang_asm 单模块 -o：XLANG_ASM_ENTRY_MODULE_ONLY=1 时仅编入口模块。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * A-11 typeck-parse-count-gate：仅采集 parse 指标，不跑 pipeline/asm_codegen_elf_o。
 * pure 权威：thin.x；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** -o 可执行文件路径：非 0 时 pipeline 跳过 dep 0 的 codegen。 */
/* wave1 pure：hybrid thin owns flag BSS; cold seed keeps statics + flag_slot bodies. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif


/** 设置 skip_codegen_dep_0 标志（driver -o exe 路径）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 查询 skip_codegen_dep_0；pipeline.x dep_j==0 时读取。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave2 pure：hybrid thin owns dep-path BSS; cold seed keeps static + store/load. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave3 pure：hybrid thin owns format print (append + diag_report*); cold keeps reportf _impl. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif



/**
 * 设置当前 dep 路径；pipeline codegen 循环每 dep 调用。
 * 参数：path import 逻辑路径或 NULL 清槽。
 * wave2 pure：hybrid thin owns; cold keeps store wrapper.
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif



/** OBS-001：编译阶段耗时；phase 0=parse 1=typeck 2=codegen。 */
#define XLANG_COMPILE_PHASE_MAX 3

/* wave5 pure：hybrid thin owns phase timing BSS; cold seed keeps statics + begin/end _impl. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 是否启用 XLANG_COMPILE_PHASE_TIMING 阶段计时。 */
/* pure 权威：thin.x compile_phase_timing_enabled（getenv 非空）；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif



/**
 * Permanent OS wall-clock surface (seconds as double).
 * PLATFORM: POSIX — Cap clock_gettime(CLOCK_REALTIME); WINDOWS — time(NULL) (usec=0).
 * Always present under FROM_X (thin compile_phase_now_sec calls this; no pure-dup _impl).
 * G.7: single authority for wall clock used by phase timing.
 * Cap residual 9.1.5: no libc gettimeofday on Linux.
 */
double xlang_driver_wall_clock_sec(void)
{
#ifndef _WIN32
    struct timespec ts;
    if (xlang_time_clock_gettime(CLOCK_REALTIME, &ts) != 0)
        return 0.0;
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
#else
    {
        struct timeval tv;
        time_t t = time(NULL);
        tv.tv_sec = (long)t;
        tv.tv_usec = 0;
        return (double)tv.tv_sec + (double)tv.tv_usec * 1e-6;
    }
#endif
}

/** Wall-clock seconds for phase timing (cold twin of thin pure wave7). */
/* G-02f-165 / wave7：hybrid thin owns public; cold seed keeps thin twin via OS surface. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif




/* G-02f-244：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave5：cold seed getters twin thin pure surface (hybrid uses thin symbols). */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 标记编译阶段开始；由 pipeline.x run_x_pipeline_impl 调用。
 * 参数：phase 0..2。
 * wave5 pure：hybrid thin owns begin；cold keeps _impl；FROM_X 无 pure-dup。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 累加阶段耗时（毫秒）；同 phase 可多次 begin/end 叠加。
 * 参数：phase 0..2。
 * wave5 pure：hybrid thin owns end；cold keeps _impl；FROM_X 无 pure-dup。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 打印 parse/typeck/codegen/total 毫秒汇总行并清零；XLANG_COMPILE_PHASE_TIMING 启用时生效。
 * wave6 pure：hybrid thin owns flush（whole-ms append + diag_report）；cold keeps integer-ms twin；
 * FROM_X 无 pure-dup flush _impl。acc 经 driver_compile_phase_acc_ms_get（thin/cold twin）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* G-02f-244：逻辑源 .x（门闩 → index_ok pure）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* pure 权威：thin.x driver_compile_phase_timing_enabled；冷启动保留 public；FROM_X 无 pure-dup（H↓）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* G-02f-244：逻辑源 .x（门闩 → index_ok pure）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif


/**
 * 从 argv 收集 -D / -DFOO 与 -target 推导 OS_*、uname 的 XLANG_OS_/XLANG_ARCH_（run_compiler_c / asm 后端共用）。
 * 参数：defines 至少 max_defines 个槽；返回 ndefines。
 * G-02f-245：主循环逻辑源 .x pure；uname 🔒。
 */
/* wave4 pure：hybrid thin owns defines_set_at (xlang_ptr_slot_set) + os_define_lit table;
 * cold keeps _impl + public; FROM_X rest drops pure-dup set_at/os_lit _impl. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* G-02f-245：逻辑源 .x（真迁 target→OS kind）；seed 保留同语义 C 供产品 cc */
/* G-02f-401：strstr 字面量体始终 seed；public PREFER 时 thin forward */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Permanent OS uname host-define surface (XLANG_OS_* / XLANG_ARCH_*).
 * PLATFORM: POSIX — uname(struct utsname) + static define buffers; hides utsname from .x.
 *            WINDOWS — may no-op via uname stub if present; same signature.
 * Always present under FROM_X (thin argv_collect pure orch calls this;
 * no pure-dup driver_argv_collect_append_uname_impl).
 * G.7: single authority for host OS/arch define append used by argv_collect.
 */
int xlang_driver_argv_append_uname(const char **defines, int ndefines, int max_defines) {
    struct utsname u;
    static char xlang_os_def[80], xlang_arch_def[80];
    if (!defines)
        return ndefines;
    if (ndefines + 2 > max_defines)
        return ndefines;
    if (uname(&u) != 0)
        return ndefines;
    snprintf(xlang_os_def, sizeof xlang_os_def, "XLANG_OS_%s", u.sysname);
    snprintf(xlang_arch_def, sizeof xlang_arch_def, "XLANG_ARCH_%s", u.machine);
    for (char *p = xlang_os_def + 7; *p; p++)
        *p = driver_ascii_toupper(*p);
    for (char *p = xlang_arch_def + 9; *p; p++)
        *p = driver_ascii_toupper(*p);
    defines[ndefines++] = xlang_os_def;
    defines[ndefines++] = xlang_arch_def;
    return ndefines;
}

/* G-02f-245：逻辑源 .x；G-02f-413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** pipeline_gen.c / main.x：module num_funcs 与 main 下标。 */
extern int driver_get_module_num_funcs(void *m);
extern int driver_get_module_main_func_index(void *m);

/** pipeline 失败 rc 诊断；rc==-7 时打印 resolve 尝试路径。 */
/* G-02f-413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * .x pipeline 烟测 stderr 摘要；保留 parse OK / typeck OK 前缀供 run-import gate grep。
 * 参数：module ASTModule*；codegen_len 产出字节数（可为 0）。
 */
/* G-02f-244/413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * B-20：读源文件前缀到 content（最多 cap-1 字节）；成功返回读入字节数，失败 -1。
 * 参数：path 源路径；content/cap 输出缓冲；实现委托 runtime_io_abi。
 */
/* G-02f-413：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 大模块 pipeline 栈帧深；macOS 默认 RLIMIT_STACK 约 512KiB～8MiB，进入 pipeline 前抬高软上限。
 * NL-07 nostdlib：pthread 大栈桩无效，须把主线程软上限抬到 256MiB 以免 -o 编译栈溢出 SIGSEGV。
 * G-02f-244：want pure 在 .x；setrlimit / nostdlib 覆盖 🔒 在 to_impl。
 */
/* pure 权威：thin.x driver_parse_u32_cstr + driver_stack_limit_want_bytes；
 * 冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Permanent OS RLIMIT_STACK raise surface.
 * PLATFORM: POSIX — getrlimit/setrlimit (struct rlimit hidden from .x);
 *            WINDOWS — no-op (want_bytes unused).
 * Always present under FROM_X (thin driver_bump_stack_limit pure orch calls this;
 * no pure-dup driver_bump_stack_limit_to_impl).
 * G.7: single authority for stack soft-limit raise used by large-stack paths.
 */
void xlang_driver_bump_stack_limit(int64_t want_bytes) {
    #ifndef _WIN32
    struct rlimit rl;
    rlim_t want = (rlim_t)want_bytes;
    if (want_bytes <= 0)
        want = (rlim_t)(512 * 1024 * 1024);
    if (bootstrap_nostdlib_pthread_is_stub())
        want = (rlim_t)(512 * 1024 * 1024);
    if (getrlimit(RLIMIT_STACK, &rl) == 0 && rl.rlim_cur < want) {
        rl.rlim_cur = want;
        if (rl.rlim_max > (rlim_t)0 && rl.rlim_cur > rl.rlim_max)
            rl.rlim_cur = rl.rlim_max;
        (void)setrlimit(RLIMIT_STACK, &rl);
    }
    #else
    (void)want_bytes;
    #endif
}

/* G-02f-244 / wave9：逻辑源 .x（want pure → permanent OS surface）；seed 冷 twin */
/* G-02f-402：public PREFER 时 thin owns driver_bump_stack_limit orch */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif



/** pthread 大栈调用参数（trampoline 解包 fn/arg）。 */
typedef struct {
    void *(*fn)(void *);
    void *arg;
} DriverLargeStackCall;

/** pthread 入口：标记大栈线程并抬高 soft limit 后执行用户 fn。 */
/* G-02f-243：.x 门闩 null 边界；主体 🔒 pthread 解包 */
void * driver_large_stack_thread_trampoline(void *v) {
    DriverLargeStackCall *c;
    if (v == NULL)
        return NULL;
    c = (DriverLargeStackCall *)v;
    driver_large_stack_thread_mark(1);
    driver_bump_stack_limit();
    void *r = c->fn(c->arg);
    driver_large_stack_thread_mark(0);
    return r;
}

/**
 * Permanent OS indirect call surface.
 * PLATFORM: SHARED — invokes fn(arg) when fn != NULL.
 * Always present under FROM_X (thin pure orch calls this; no pure-dup call_fn _impl).
 * G.7: single authority for void*(void*) style driver callbacks (.x cannot cast safely).
 */
void xlang_driver_call_fn_void_arg(void *(*fn)(void *), void *arg) {
    if (fn)
        (void)fn(arg);
}

/* pure 权威：thin.x driver_pipeline_no_large_stack_env；冷启动保留 _impl + public；FROM_X 无 pure-dup（H↓）。 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/** 在当前线程直接执行 fn(arg)，并临时标记大栈上下文。 */
/* G-02f-246 pure 深迁：PREFER thin 真体；冷启动 full C；FROM_X 无 pure-dup */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Permanent OS large-stack pthread create/join surface.
 * PLATFORM: POSIX — pthread_attr / posix_memalign / pthread_create+join
 *            (hides OS layouts from .x pure orch); falls back to current-stack path.
 * Default stack 256MiB; XLANG_STACK_LIMIT_MB (64..8192) overrides.
 * Always present under FROM_X (thin driver_run_thread_on_large_stack pure orch calls this;
 * no pure-dup driver_run_thread_on_large_stack_pthread_impl).
 * G.7: single authority for driver large-stack pthread body used after pure early exits.
 */
void xlang_driver_run_thread_on_large_stack_pthread(void *(*fn)(void *), void *arg) {
    pthread_attr_t attr;
    pthread_t tid;
    void *stk = NULL;
    size_t stack_sz = (size_t)256 * 1024 * 1024;
    const char *mb_env = link_abi_getenv("XLANG_STACK_LIMIT_MB");
    DriverLargeStackCall call = { fn, arg };
    if (fn == NULL)
        return;
    if (mb_env && mb_env[0]) {
        unsigned long mb = strtoul(mb_env, NULL, 10);
        if (mb >= 64 && mb <= 8192)
            stack_sz = (size_t)mb * (size_t)(1024 * 1024);
    }
    if (pthread_attr_init(&attr) != 0) {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    (void)pthread_attr_setguardsize(&attr, 0);
    if (posix_memalign(&stk, (size_t)65536, stack_sz) != 0)
        stk = NULL;
    if (stk != NULL && pthread_attr_setstack(&attr, stk, stack_sz) == 0) {
        if (pthread_create(&tid, &attr, driver_large_stack_thread_trampoline, &call) == 0) {
            pthread_join(tid, NULL);
            pthread_attr_destroy(&attr);
            free(stk);
            return;
        }
    }
    pthread_attr_destroy(&attr);
    free(stk);
    if (pthread_attr_init(&attr) != 0) {
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    if (pthread_attr_setstacksize(&attr, stack_sz) != 0) {
        pthread_attr_destroy(&attr);
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    if (pthread_create(&tid, &attr, driver_large_stack_thread_trampoline, &call) != 0) {
        pthread_attr_destroy(&attr);
        driver_run_fn_on_current_large_stack(fn, arg);
        return;
    }
    pthread_join(tid, NULL);
    pthread_attr_destroy(&attr);
}

/**
 * Run fn(arg) on the 256MiB-stack pthread; pure early exits then the permanent
 * OS pthread surface (verbatim mirror of the thin wave12 orch body).
 * macOS main-thread RLIMIT_STACK caps around 8MiB; deep pipeline/typeck
 * recursion must share the large pipeline path.
 * G-02f-246/414 / wave12: public PREFER runs the thin pure orch; this cold twin
 * keeps the same early-exit order and the same OS surface.
 * 9.7.7 G.7: the former driver_run_thread_on_large_stack_impl middleman is
 * collapsed — this public twin now holds the orch body directly.
 * PLATFORM: SHARED orch; OS boundary only in xlang_driver_run_thread_on_large_stack_pthread.
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Public alias: run fn(arg) on the large-stack pthread (LSP main loop etc.).
 * G-02f-414: body always seed; public PREFER uses the thin pure forward.
 * 9.7.7: mirrors the thin alias shape — null guard then direct call; the
 * former driver_run_on_large_stack_pthread_impl middleman is removed.
 * PLATFORM: SHARED orch.
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Cap-fn-ptr residual：.x 无法形成函数指针常量。
 * wave37 pure：hybrid thin owns driver_run_stack_esc_gate_on_large_stack orch
 * （fn_ptr residual + G.7 driver_run_thread_on_large_stack）；cold twin under #ifndef FROM_X。
 * always-seed：driver_stack_esc_gate_thread_fn_ptr（取函数地址）。
 * PLATFORM: SHARED — Cap-fn-ptr residual stays seed.
 */
extern void *driver_stack_esc_gate_thread_fn(void *arg);

uint8_t *driver_stack_esc_gate_thread_fn_ptr(void) {
    return (uint8_t *)(void *)driver_stack_esc_gate_thread_fn;
}

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Cap residual：opaque FILE* 供 rt_entry R2 full .x 的 diag_print_*。
 * wave39 pure：hybrid thin owns driver_stdio_stdout via fd-handle stdout_ptr；
 * wave40 pure：hybrid thin owns driver_stdio_stderr via fd-handle stderr_ptr；
 * cold twins under #ifndef FROM_X；FROM_X 无 pure-dup。
 * PLATFORM: SHARED — fd-handle face (9.7.1): encoded std fds, .x consumers
 * pass the value to the same opaque face, so identity/typing still holds.
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Cap residual：rt_entry R2 缓冲槽 + fmt argv。
 * .x 禁局部 u8[N]（-E 抬 init_globals / 丢函数）；模块 BSS 可 pure（wave15 thin）。
 * wave15 pure：hybrid thin owns entry_*_slot (char buffers) + path slots。
 * wave21 pure：hybrid thin owns fmt_argv_slot (byte-lit BSS + G.7 ptr slots；no *u8[2] lit)。
 * cold keeps C static for buffers + fmt_argv; FROM_X no pure-dup buffer/fmt slots.
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/**
 * Cap residual：rt_run_exec R2 usage 写 stdout。
 * wave44 pure：hybrid thin owns driver_print_usage_write orch
 *   （NO_COLOR nonnull / CLICOLOR_FORCE|XLANG_FORCE_COLOR truthy / isatty）；
 * cold twin under #ifndef FROM_X；FROM_X 无 pure-dup。
 * always-seed：xlang_driver_usage_write_stdout（巨型 plain/color lit，
 *   经 xlang_io_write(1,…) Cap io 写；9.7.1 起无 libc FILE star）。
 * PLATFORM: SHARED orch；lit 表权威唯一在 residual（G.7，禁 .x 长 \\n 串）。
 */

/* Permanent Cap residual: giant usage tables, written to fd 1 via
 * xlang_io_write (Cap io face, 9.7.1 fd-handle convergence).
 * Pure wave44 owns color policy only; .x -E cannot host multi-line \\n lits.
 * Always linked under FROM_X. PLATFORM: SHARED — Cap io write, raw fd 1. */
void xlang_driver_usage_write_stdout(int32_t use_color) {
    /* Deno-style help layout: yellow section headers, blue subcommand names,
     * yellow flags, two-column alignment with description column. */
static const char usage_plain[] =
    "Xlang compiler\n"
    "\n"
    "Usage: xlang [COMMAND] [OPTIONS]\n"
    "\n"
    "Subcommands:\n"
    "\n"
    "  build\n"
    "    Compile .x to binary/object (default a.out)\n"
    "    Usage: xlang build [options] file.x [-o exe]\n"
    "    Options:\n"
    "      -backend asm|c                    Backend (default asm)\n"
    "      -O <0|1|2|3|s>                    Optimization level (default 2)\n"
    "      -o <path>                         Output binary or .o\n"
    "      -L <dir>                          Library search path\n"
    "      -target <triple>                  Target triple (e.g. aarch64-linux-gnu)\n"
    "      -target-cpu <cpu>                 native|generic|avx2|...\n"
    "      -freestanding                     Nostdlib static link (Linux x86_64 ELF)\n"
    "      -legacy-f32-abi                   Legacy SysV f32 CALL (f64 widen; default xmm ABI)\n"
    "      -E                                Emit C (debug)\n"
    "      -flto                             Link-time optimization (C backend)\n"
    "\n"
    "  run\n"
    "    Compile and run .x\n"
    "    Usage: xlang run [options] file.x\n"
    "    Options:\n"
    "      -backend asm|c                    Backend (default asm)\n"
    "      -O <0|1|2|3|s>                    Optimization level (default 2)\n"
    "      -o <path>                         Output binary or .o\n"
    "      -L <dir>                          Library search path\n"
    "      -target <triple>                  Target triple (e.g. aarch64-linux-gnu)\n"
    "      -target-cpu <cpu>                 native|generic|avx2|...\n"
    "      -legacy-f32-abi                   Legacy SysV f32 CALL (f64 widen; default xmm ABI)\n"
    "\n"
    "  check\n"
    "    Parse + typeck only (no codegen)\n"
    "    Usage: xlang check [paths...]\n"
    "\n"
    "  fmt\n"
    "    Format .x sources\n"
    "    Usage: xlang fmt [--check] [paths...]\n"
    "\n"
    "  explain\n"
    "    Explain a diagnostic code\n"
    "    Usage: xlang explain <CODE>\n"
    "\n"
    "  test\n"
    "    Run test script\n"
    "    Usage: xlang test [script.sh]\n"
    "\n"
    "Global options:\n"
    "  --print-target-cpu                    Print host CPU features and exit\n"
    "  --explain <CODE>                      Print diagnostic code explanation and exit\n"
    "  --help, -h                            Show this help\n"
    "\n"
    "Environment:\n"
    "  XLANG_ABI_F32_XMM=0                    Same as -legacy-f32-abi (x86_64 SysV)\n"
    "  XLANG_OPT                              Default -O level if omitted\n"
    "  NO_COLOR                              Disable color output\n"
    "  CLICOLOR_FORCE=1                      Force color output even when piped\n"
    "  XLANG_FORCE_COLOR=1                    Same as CLICOLOR_FORCE\n"
    "\n"
    "Release default: xlang_asm -backend asm -O2 (f32 xmm ABI on unless legacy).\n"
    "See compiler/docs/F32_XMM_ABI.md for f32 ABI and deprecation timeline.\n";
static const char usage_color[] =
    "\033[32mXlang compiler\033[0m\n"
    "\n"
    "\033[32mUsage:\033[0m xlang [COMMAND] [OPTIONS]\n"
    "\n"
    "\033[32mSubcommands:\033[0m\n"
    "\n"
    "  \033[34mbuild\033[0m\n"
    "    Compile .x to binary/object (default a.out)\n"
    "    Usage: xlang build [options] file.x [-o exe]\n"
    "    Options:\n"
    "      \033[32m-backend\033[0m asm|c                    Backend \033[90m(default asm)\033[0m\n"
    "      \033[32m-O\033[0m <0|1|2|3|s>                    Optimization level \033[90m(default 2)\033[0m\n"
    "      \033[32m-o\033[0m <path>                         Output binary or .o\n"
    "      \033[32m-L\033[0m <dir>                          Library search path\n"
    "      \033[32m-target\033[0m <triple>                  Target triple (e.g. aarch64-linux-gnu)\n"
    "      \033[32m-target-cpu\033[0m <cpu>                 native|generic|avx2|...\n"
    "      \033[32m-freestanding\033[0m                     Nostdlib static link (Linux x86_64 ELF)\n"
    "      \033[32m-legacy-f32-abi\033[0m                   Legacy SysV f32 CALL (f64 widen; default xmm ABI)\n"
    "      \033[32m-E\033[0m                                Emit C (debug)\n"
    "      \033[32m-flto\033[0m                             Link-time optimization (C backend)\n"
    "\n"
    "  \033[34mrun\033[0m\n"
    "    Compile and run .x\n"
    "    Usage: xlang run [options] file.x\n"
    "    Options:\n"
    "      \033[32m-backend\033[0m asm|c                    Backend \033[90m(default asm)\033[0m\n"
    "      \033[32m-O\033[0m <0|1|2|3|s>                    Optimization level \033[90m(default 2)\033[0m\n"
    "      \033[32m-o\033[0m <path>                         Output binary or .o\n"
    "      \033[32m-L\033[0m <dir>                          Library search path\n"
    "      \033[32m-target\033[0m <triple>                  Target triple (e.g. aarch64-linux-gnu)\n"
    "      \033[32m-target-cpu\033[0m <cpu>                 native|generic|avx2|...\n"
    "      \033[32m-legacy-f32-abi\033[0m                   Legacy SysV f32 CALL (f64 widen; default xmm ABI)\n"
    "\n"
    "  \033[34mcheck\033[0m\n"
    "    Parse + typeck only (no codegen)\n"
    "    Usage: xlang check [paths...]\n"
    "\n"
    "  \033[34mfmt\033[0m\n"
    "    Format .x sources\n"
    "    Usage: xlang fmt [--check] [paths...]\n"
    "\n"
    "  \033[34mexplain\033[0m\n"
    "    Explain a diagnostic code\n"
    "    Usage: xlang explain <CODE>\n"
    "\n"
    "  \033[34mtest\033[0m\n"
    "    Run test script\n"
    "    Usage: xlang test [script.sh]\n"
    "\n"
    "\033[32mGlobal options:\033[0m\n"
    "  \033[32m--print-target-cpu\033[0m                    Print host CPU features and exit\n"
    "  \033[32m--explain\033[0m <CODE>                      Print diagnostic code explanation and exit\n"
    "  \033[32m--help, -h\033[0m                            Show this help\n"
    "\n"
    "\033[32mEnvironment:\033[0m\n"
    "  XLANG_ABI_F32_XMM=0                    Same as -legacy-f32-abi (x86_64 SysV)\n"
    "  XLANG_OPT                              Default -O level if omitted\n"
    "  NO_COLOR                              Disable color output\n"
    "  CLICOLOR_FORCE=1                      Force color output even when piped\n"
    "  XLANG_FORCE_COLOR=1                    Same as CLICOLOR_FORCE\n"
    "\n"
    "Release default: xlang_asm -backend asm -O2 (f32 xmm ABI on unless legacy).\n"
    "See \033[4;34mcompiler/docs/F32_XMM_ABI.md\033[0m for f32 ABI and deprecation timeline.\n";
    if (use_color) {
        (void)xlang_io_write(1, usage_color, sizeof(usage_color) - 1u);
    } else {
        (void)xlang_io_write(1, usage_plain, sizeof(usage_plain) - 1u);
    }
}

/* wave44 pure: hybrid thin owns print_usage color orch; cold twin under #ifndef FROM_X. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Cap residual：rt_run_exec R2 driver_exec_compiled 体。
 * wave42 pure：hybrid thin owns driver_exec_compiled_body orch
 *   （null/argc + G.7 driver_exec_path_is_non_exe + residual scan/spawn）；
 * cold twin under #ifndef FROM_X；FROM_X 无 pure-dup。
 * always-seed：xlang_driver_exec_scan_out_path_opaque（*u8→char** cast + scan）
 *   + xlang_driver_exec_spawn_wait（fork/exec 或 spawnvp）。
 * PLATFORM: SHARED orch；WINDOWS spawn vs POSIX fork in residual.
 */
#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#endif
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern const char *driver_exec_scan_out_path(int argc, char **argv);
extern int driver_exec_path_is_non_exe(const char *exe);
#if !defined(_WIN32) && !defined(_WIN64)
extern int xlang_waitpid_retry(pid_t pid, int *status_out);
#endif

/* Permanent Cap residual: *u8 argv_opaque → char** + G.7 scan_out_path.
 * Pure wave42 cannot cast *u8→**u8 (-E drops body). Always linked under FROM_X.
 * PLATFORM: SHARED — cast glue only; scan authority remains rt_run_exec. */
uint8_t *xlang_driver_exec_scan_out_path_opaque(int32_t argc, uint8_t *argv_opaque) {
    if (argv_opaque == NULL)
        return NULL;
    return (uint8_t *)(void *)driver_exec_scan_out_path(argc, (char **)(void *)argv_opaque);
}

/* 9.4.3 v1: driver flags that consume a separate value argument.
 * Mirrors the parse authorities' i+2 advance — main.x driver_argv_parse_x_path
 * / driver_argv_parse_x (-target, -L, -backend, -o, -O) and the rt_compile
 * surface parse (-target-cpu) — plus the usage tables above. Exact matches
 * only: attached forms ("-O1", "-E-extern") are standalone flags and are
 * skipped by the generic '-' rule. Keep in lockstep with those parsers
 * (same commit, same semantics). PLATFORM: SHARED. */
static int xlang_driver_run_flag_consumes_value(const char *s) {
    if (s == NULL || s[0] != '-')
        return 0;
    if (strcmp(s, "-o") == 0 || strcmp(s, "-O") == 0 || strcmp(s, "-L") == 0 ||
        strcmp(s, "-backend") == 0 || strcmp(s, "-target") == 0 ||
        strcmp(s, "-target-cpu") == 0)
        return 1;
    return 0;
}

/* Permanent OS residual: wait for product exe (spawn/fork/exec).
 * Pure wave42 owns null/non_exe orch; this is process boundary only.
 * 9.4.3 C ABI argv: child argv = [exe] + user positionals after the .x source
 * path. Driver flags stay driver-owned (not forwarded); value-taking flags
 * (-o, -O, -L, -backend, -target, -target-cpu — see
 * xlang_driver_run_flag_consumes_value) also consume their separate value so
 * it does not leak into the child argv (the run path appends the injected
 * "-o <temp>" pair at argv tail; an explicit -o product path is likewise a
 * driver artifact). argv[0] is the exe path per C convention. Falls back to
 * [exe] only when the source path / argv is absent.
 * PLATFORM: WINDOWS _spawnvp; POSIX fork+execv+xlang_waitpid_retry. */
int32_t xlang_driver_exec_spawn_wait(uint8_t *exe, int32_t argc, uint8_t *argv_opaque) {
    const char *path;
    /* Single-thread driver process, one exec per call — static matches the
     * adj[512] convention in runtime_link_abi (ensure_run_o / drop_subcommand). */
    static char *cav[520];
    int k = 0;
    if (exe == NULL)
        return 1;
    path = (const char *)(void *)exe;
    cav[k++] = (char *)path;
    if (argv_opaque != NULL && argc >= 1 && argc <= 512) {
        char **argv = (char **)(void *)argv_opaque;
        int src = -1;
        int i;
        /* Locate the .x source path: first argv entry with a ".x" suffix. */
        for (i = 1; i < argc; i++) {
            const char *s = argv[i];
            int n;
            if (s == NULL)
                continue;
            n = (int)strlen(s);
            if (n >= 2 && s[n - 2] == '.' && s[n - 1] == 'x') {
                src = i;
                break;
            }
        }
        if (src >= 0) {
            for (i = src + 1; i < argc; i++) {
                const char *s = argv[i];
                if (s == NULL)
                    continue;
                if (xlang_driver_run_flag_consumes_value(s)) {
                    /* Skip the value-taking flag and its separate value
                     * (e.g. the injected "-o <temp>" tail pair; -O/-L/-backend/
                     * -target/-target-cpu values are driver-owned, not user
                     * args — 9.4.3 v1 flag-value table). Guard: only consume
                     * a next entry that exists and does not start with '-'
                     * (documented values are paths/levels/triples, never
                     * flag-shaped); a dangling flag at the tail must not eat
                     * the injected "-o" pair and leak the temp path. */
                    if (i + 1 < argc && argv[i + 1] != NULL && argv[i + 1][0] != '-')
                        i++;
                    continue;
                }
                if (s[0] == '-')
                    continue; /* driver flag: consumed at compile, not forwarded */
                if (k < 512)
                    cav[k++] = (char *)s;
            }
        }
    }
    cav[k] = NULL;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    {
        intptr_t rc;
        rc = _spawnvp(_P_WAIT, path, (const char *const *)cav);
        if (rc == -1) {
            runtime_diag_errno_path(NULL, "process error", "spawnvp (driver_exec_compiled)", path);
            return 1;
        }
        return (int32_t)rc;
    }
#else
    {
        pid_t pid = fork();
        if (pid < 0) {
            runtime_diag_errno_path(NULL, "process error", "fork (driver_exec_compiled)", path);
            return 1;
        }
        if (pid == 0) {
            execv(path, cav);
            runtime_diag_errno_path(NULL, "process error", "execv (driver_exec_compiled)", path);
            _exit(127);
        }
        {
            int st = 0;
            if (xlang_waitpid_retry(pid, &st) != 0)
                return 1;
            if (WIFEXITED(st))
                return (int32_t)WEXITSTATUS(st);
            return 1;
        }
    }
#endif
}

/* wave42 pure: hybrid thin owns exec_compiled_body orch; cold twin under #ifndef FROM_X. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Cap-global-bss residual：rt_emit_state R2 full .x 写共享 emit 槽。
 * 数据定义在 seeds/rt_emit_state.from_x.c（跨 TU 非 static）；本层暴露槽/绑定。
 * Always-seed Cap-global-bss data residual（path/lib/scan slots + c_path_cell +
 * lib_roots_raw + n/want slots）：不随 RDABI thin 宏剥离。
 * wave33 pure：clear/bind/take/get/lib_root_at/effective/try_extern 在 thin.x
 *   （G.7 xlang_ptr_slot_* on c_path_cell/lib_roots_raw；无 **u8 写）；
 *   cold keeps C twins under #ifndef FROM_X；FROM_X 无 pure-dup。
 * PLATFORM: SHARED — BSS authority remains rt_emit_state.from_x.c.
 */
#define X_EMIT_MAX_LIB_ROOTS_ABI 16
extern const char *driver_x_emit_c_path;
extern const char *driver_x_emit_lib_roots[X_EMIT_MAX_LIB_ROOTS_ABI];
extern int driver_x_emit_n_lib_roots;
extern char driver_x_emit_path_buf[512];
extern char driver_x_emit_lib_bufs[X_EMIT_MAX_LIB_ROOTS_ABI][256];
extern int driver_x_emit_c_want_extern;
/* argv 扫描临时缓冲（.x 勿用局部 u8[512]，易被抬成坏 init_globals） */
extern char driver_x_emit_scan_ab[512];
extern char driver_x_emit_scan_nx[512];

/* Always-seed: Cap-global-bss buffer bases (data in rt_emit_state.from_x.c). */
uint8_t *driver_x_emit_path_buf_slot(void) {
    return (uint8_t *)driver_x_emit_path_buf;
}

uint8_t *driver_x_emit_lib_buf_slot(int i) {
    if (i < 0 || i >= X_EMIT_MAX_LIB_ROOTS_ABI)
        return NULL;
    return (uint8_t *)driver_x_emit_lib_bufs[i];
}

uint8_t *driver_x_emit_scan_ab_slot(void) {
    return (uint8_t *)driver_x_emit_scan_ab;
}

uint8_t *driver_x_emit_scan_nx_slot(void) {
    return (uint8_t *)driver_x_emit_scan_nx;
}

/* Always-seed: address of driver_x_emit_c_path pointer cell (1-slot G.7 table). */
uint8_t *driver_x_emit_c_path_cell(void) {
    return (uint8_t *)(void *)&driver_x_emit_c_path;
}

/* Always-seed: base of driver_x_emit_lib_roots[16] pointer table. */
uint8_t *driver_x_emit_lib_roots_raw(void) {
    return (uint8_t *)(void *)driver_x_emit_lib_roots;
}

int32_t *driver_x_emit_n_lib_roots_slot(void) {
    return (int32_t *)&driver_x_emit_n_lib_roots;
}

int32_t *driver_x_emit_want_extern_slot(void) {
    return (int32_t *)&driver_x_emit_c_want_extern;
}

/* wave33 pure: hybrid thin owns clear/bind; cold seed keeps C twins. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/**
 * Cap-global-bss residual：rt_arena_buf R2 full .x 访问 128MiB/2MiB 静态缓冲。
 * 数据定义在 seeds/rt_arena_buf.from_x.c（跨 TU 非 static）。
 * wave37 pure：hybrid thin owns slot/size；always-seed base residual 供 pure 取址；
 * cold keeps C slot/size twins under #ifndef FROM_X。
 * PLATFORM: SHARED — array body stays rt_arena_buf; pure owns public slot/size API under PREFER.
 */
#define DRIVER_ARENA_STATIC_SIZE_ABI (128 * 1024 * 1024)
#define DRIVER_MODULE_STATIC_SIZE_ABI (2 * 1024 * 1024)
extern uint8_t driver_arena_static[DRIVER_ARENA_STATIC_SIZE_ABI];
extern uint8_t driver_module_static[DRIVER_MODULE_STATIC_SIZE_ABI];

/* Always-seed Cap-global base residual (like preamble_*_lines_raw). */
uint8_t *driver_arena_static_base(void) {
    return driver_arena_static;
}

uint8_t *driver_module_static_base(void) {
    return driver_module_static;
}

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/**
 * Cap-giant-string residual：rt_preamble R2 full .x 访问巨型 C 字串表。
 * 数据定义在 seeds/rt_preamble.from_x.c（跨 TU 非 static）。
 * wave20 pure：hybrid thin owns line_at/count（xlang_ptr_slot_get + fixed N）；
 *   always-seed residual = *_lines_raw（表基址）；cold keeps C line_at/count twins；
 *   FROM_X 无 pure-dup line_at/count。
 * PLATFORM: SHARED — table text authority remains rt_preamble.from_x.c.
 */
extern const char *const driver_preamble_io_net_lines[];
/* w2060: counts are single authority in rt_preamble.x (renamed commons). */
extern const int32_t driver_preamble_io_net_lines_n;
extern const char *const driver_preamble_fs_path_lines[];
extern const int32_t driver_preamble_fs_path_lines_n;

/* Always seed: Cap-giant-string data residual (base of pointer table for pure line_at). */
uint8_t *driver_preamble_io_net_lines_raw(void) {
    return (uint8_t *)(void *)driver_preamble_io_net_lines;
}

uint8_t *driver_preamble_fs_path_lines_raw(void) {
    return (uint8_t *)(void *)driver_preamble_fs_path_lines;
}

/* Always seed: address of authority counts for pure thin bounds (no hardcoded N). */
int32_t *driver_preamble_io_net_lines_n_raw(void) {
    return (int32_t *)&driver_preamble_io_net_lines_n;
}

int32_t *driver_preamble_fs_path_lines_n_raw(void) {
    return (int32_t *)&driver_preamble_fs_path_lines_n;
}

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* ---------- Cap residual：rt_run_x_emit R2（平台/巨型布局） ---------- */
#ifndef X_CODEGEN_OUTBUF_CAP_ABI
#define X_CODEGEN_OUTBUF_CAP_ABI (9 * 1024 * 1024)
#endif
struct driver_codegen_outbuf_abi {
    unsigned char data[X_CODEGEN_OUTBUF_CAP_ABI];
    int32_t length;
};

extern const char *driver_x_emit_c_path;
extern const char *driver_x_emit_lib_roots[];
extern int driver_x_emit_n_lib_roots;
extern int driver_x_emit_c_want_extern;
/* wave77: G.7 accessors only — pure owns typeck_dep BSS under hybrid; no naked C globals. */
extern void typeck_ndep_store(int32_t n);
extern void typeck_dep_module_set(int32_t i, void *mod);
extern void typeck_dep_arena_set(int32_t i, void *arena);

struct parser_ParseIntoResult {
    int32_t ok;
    int32_t main_idx;
};
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data,
                                                          int32_t len);

/* wave33 pure: hybrid thin owns take/get/lib_root_at; cold seed keeps C twins. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* 9.7.1: stdout writes go through raw fd 1 (unbuffered by nature) — kept as a
 * no-op for .x callers that used to disable libc FILE buffering. */
void driver_x_emit_stdout_set_unbuffered(void) {
}

/**
 * Cap OS residual for wave39 pure driver_x_emit_fwrite_stdout.
 * Pure owns null/len guards; this returns write byte count (fd 1 is unbuffered).
 * Always linked under FROM_X (no pure-dup of public symbol).
 * PLATFORM: SHARED — fd-handle face; raw write(1) via Cap authority (9.7.1).
 */
int32_t xlang_driver_fwrite_stdout_n(uint8_t *data, int32_t len) {
    if (data == NULL || len <= 0)
        return 0;
    return (int32_t)xlang_io_write(1, data, (size_t)len);
}

/* wave39 pure: hybrid thin owns fwrite_stdout; cold twin; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave23 pure：hybrid thin owns calloc family; cold seed keeps sizeof twins. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave24 pure：hybrid thin owns free/len/data; cold seed keeps twins. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave24 pure：hybrid thin owns free/get/set; cold seed keeps twins. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Cap-struct-return residual：unpack parser_parse_into_buf into rc + out_main_idx.
 * Always-seed (not stripped by FROM_X). Wave38 pure driver_parse_into_buf_rc owns
 * null guards then calls this. PLATFORM: SHARED — struct return stays C.
 *
 * wave269: always-seed also owns L001 sticky hard-fail (reset before parse, pending
 * after). wave271: same for L002 unclosed string. wave272: same for L003 illegal char.
 * wave273: same for L004 incomplete hex.
 * wave274: same for L005 incomplete float exponent.
 * Thin driver_parse_into_buf_rc may also check; this residual is the G.7 single choke
 * that hybrid and cold both pass through.
 */
extern void lexer_unclosed_block_comment_reset(void);
extern int32_t lexer_unclosed_block_comment_pending(void);
extern void lexer_unclosed_string_reset(void);
extern int32_t lexer_unclosed_string_pending(void);
extern void lexer_illegal_char_reset(void);
extern int32_t lexer_illegal_char_pending(void);
extern void lexer_incomplete_hex_reset(void);
extern int32_t lexer_incomplete_hex_pending(void);
extern void lexer_incomplete_exp_reset(void);
extern int32_t lexer_incomplete_exp_pending(void);
extern void lexer_incomplete_bin_reset(void);
extern int32_t lexer_incomplete_bin_pending(void);
extern void lexer_incomplete_oct_reset(void);
extern void lexer_invalid_digit_sep_reset(void);
extern int32_t lexer_invalid_digit_sep_pending(void);
extern void lexer_invalid_type_suffix_reset(void);
extern int32_t lexer_invalid_type_suffix_pending(void);
extern int32_t lexer_incomplete_oct_pending(void);
int32_t xlang_parser_parse_into_buf_rc(void *arena, void *module, uint8_t *data, int32_t len,
                                      int32_t *out_main_idx) {
    struct parser_ParseIntoResult pr;
    lexer_unclosed_block_comment_reset();
    lexer_unclosed_string_reset();
    lexer_illegal_char_reset();
    lexer_incomplete_hex_reset();
    lexer_incomplete_exp_reset();
    lexer_incomplete_bin_reset();
    lexer_incomplete_oct_reset();
    lexer_invalid_digit_sep_reset();
    lexer_invalid_type_suffix_reset();
    pr = parser_parse_into_buf(arena, module, data, len);
    if (lexer_unclosed_block_comment_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_unclosed_string_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_illegal_char_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_incomplete_hex_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_incomplete_exp_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_incomplete_bin_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_incomplete_oct_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_invalid_digit_sep_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (lexer_invalid_type_suffix_pending() != 0) {
        if (out_main_idx)
            *out_main_idx = -1;
        return -1;
    }
    if (out_main_idx)
        *out_main_idx = pr.main_idx;
    return pr.ok;
}

/* wave38 pure: hybrid thin owns parse_into_buf_rc orch; cold keeps twin with guards.
 * wave269: reset + hard-fail on unclosed block comment (L001 sticky pending).
 * wave271: reset + hard-fail on unclosed string (L002 sticky pending).
 * wave272: reset + hard-fail on illegal character (L003 sticky pending).
 * wave273: reset + hard-fail on incomplete hex (L004 sticky pending).
 * wave274: reset + hard-fail on incomplete float exponent (L005 sticky pending). */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave23 pure：hybrid thin owns diag snapshot alloc (fixed LP64 size 32). */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave24 pure：hybrid thin owns free; cold seed keeps twin. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave35 pure：hybrid thin owns push/restore + typeck set; cold seed keeps C twins. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave15 pure：hybrid thin owns path_max/entry_dir slots; cold keeps C static; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave33 pure: hybrid thin owns effective_lib_roots; cold seed keeps C twin. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

extern int32_t parser_diag_fail_at_token_kind(struct xlang_slice_uint8_t *source);

/* wave37 pure：hybrid thin owns pack + call; cold twin under #ifndef FROM_X. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave19 pure under PREFER：dep_ctx i32 field set/get; cold keeps C struct twin; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/*
 * Cap residual → wave16 pure under PREFER：rt_run_x_emit 工作槽。
 * hybrid thin owns BSS + get/set/reset/cleanup；cold keeps C static + memset twin；
 * FROM_X no pure-dup (avoid dual BSS under hybrid).
 * 指针槽 i: 0 path 1 src 2 raw 3 arena 4 module 5 entry_dir 6 dep_sources
 *   7 dep_paths 8 dep_lens 9 dep_arenas 10 dep_modules 11 out_buf 12 pctx
 *   13 one_ctx 14 dep_out 15 dep_src 16 resolved 17 snap 18 dep_diag_file
 *   19 kind 20 code 21 msg 22 cpaths 23 out_data 24 lib_roots_as_u8 25 tmp_p
 * i32 槽 i: 0 want_extern 1 n_lib 2 n_deps 3 asm_direct 4 n_imports 5 main_idx
 *   6 pr_ok 7 ec 8 ec_dep 9 emit_ret 10 out_len 11 j 12 i 13 fail_tok
 *   14 n_closure 15 rc 16 free_src_flag
 * size_t 槽 i: 0 src_len 1 raw_len 2 arena_sz 3 module_sz 4 dep_len
 */
/* Always-seed decl before cold work cleanup (wave16/17/18); thin pure also links this. */
extern void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);

#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave33 pure: hybrid thin owns try_extern NO_C diag stub; cold seed keeps C twin. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/**
 * 扫描预处理后源码是否含顶层 import（`import("` 或 `= import(`）。
 * 参数：src 预处理后缓冲；src_len 有效字节数。
 * 返回值：1 含顶层 import；0 否。
 * G-02f-243/414：实现体始终 seed（memcmp 字面量）；public PREFER 时 thin pure forward。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* G-02f-243/414：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * 读入口 .x 并预处理；返回 malloc 缓冲，长度经 driver_path_last_preprocess_len。
 * G-02f-244：IO 🔒；编排在 .x（scan pure + free）。
 * wave2：len BSS 权威 hybrid=thin / cold=seed static；本函数经 store 写入（禁直写 static）。
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/**
 * Permanent OS path-read + preprocess surface.
 * PLATFORM: SHARED — runtime_read_file_view + xlang_preprocess + thin/cold len store API;
 *            hides XlangRuntimeFileView and preprocess ABI from .x pure orch.
 * Always present under FROM_X (thin driver_path_read_preprocess_malloc pure orch calls this;
 * no pure-dup driver_path_read_preprocess_malloc_impl).
 * G.7: single authority for entry-path read+preprocess used by has_top_level_import_path.
 */
char *xlang_driver_path_read_preprocess_malloc(const char *path) {
    XlangRuntimeFileView raw_view;
    size_t src_len = 0;
    char *src;

    /* PLATFORM: SHARED — always write len via store API (thin BSS under FROM_X). */
    driver_path_last_preprocess_len_store(0);
    if (!path)
        return NULL;
    if (runtime_read_file_view(path, &raw_view) != 0)
        return NULL;
    src = xlang_preprocess(raw_view.data, raw_view.length, NULL, 0, &src_len);
    runtime_release_file_view(&raw_view);
    if (!src)
        return NULL;
    driver_path_last_preprocess_len_store((int64_t)src_len);
    return src;
}

/* G-02f-244/414：冷启动 public twin；PREFER/FROM_X 时 thin owns public pure orch */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* G-02f-244/414：实现体始终 seed（IO/preprocess）；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* --------------------------------------------------------------------------
 * Cap residual：rt_run_asm_backend R2（FILE* / pctx 字段 / host #ifdef / **u8 / work 槽）
 * -------------------------------------------------------------------------- */

/* wave19 pure under PREFER：asm-path dep_ctx field set/get; cold C twin; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

extern uint32_t driver_get_pending_target_cpu_features(void);

/*
 * wave23 permanent OS residual for pure host_defaults orch (always linked under FROM_X).
 * PLATFORM: MACOS — default arch / macho prefer; WINDOWS — coff prefer; else 0.
 * G.7: thin.x owns product orchestration; these helpers only hide host #ifdef.
 */
int32_t xlang_driver_host_default_target_arch(void) {
#if defined(__APPLE__) && defined(__aarch64__)
    return 1;
#else
    return 0;
#endif
}

int32_t xlang_driver_host_prefer_macho(int32_t emit_elf_o) {
#if defined(__APPLE__)
    return emit_elf_o ? 1 : 0;
#else
    (void)emit_elf_o;
    return 0;
#endif
}

int32_t xlang_driver_host_prefer_coff(int32_t emit_elf_o) {
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    return emit_elf_o ? 1 : 0;
#else
    (void)emit_elf_o;
    return 0;
#endif
}

/* wave23 pure：hybrid thin owns host_defaults orch; cold seed keeps #ifdef twin. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#if defined(__APPLE__) && defined(__aarch64__)
#endif
#if defined(__APPLE__)
#endif
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
#endif
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave40 pure: hybrid thin owns fopen_wb via fd-handle fopen_wb_opaque; cold twin. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

#ifndef XLANG_TMP_PREFIX
#if !defined(_WIN32) && !defined(_WIN64)
#define XLANG_TMP_PREFIX "/tmp/xlang_"
#else
#define XLANG_TMP_PREFIX "xlang_"
#endif
#endif

/* OS residual gate for asm mkstemp+fdopen (always linked under FROM_X).
 * Pure wave41 calls this before template/mkstemp; cold twin uses the same body.
 * MinGW provides mkstemp+fdopen; enabling Windows closes want-exe pure-asm BLD001
 * that previously forced -backend c fallback in win32 gates.
 * PLATFORM: SHARED — WINDOWS|POSIX|LINUX|MACOS → 1. */
int32_t xlang_driver_asm_mkstemp_fdopen_enabled(void) {
    return 1;
}

/* wave41 pure: hybrid thin owns mkstemp_fdopen orch; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED — mkstemp+fdopen (MinGW/POSIX); XLANG_TMP_PREFIX is host residual. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

void driver_asm_fclose(uint8_t *fp) {
    driver_asm_fclose_asm_out(fp);
}

/* wave39 pure: hybrid thin owns asm_fwrite via fd-handle fwrite_opaque + stdout_ptr;
 * cold twin under #ifndef FROM_X；FROM_X 无 pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave40 pure: hybrid thin owns fflush_stdout + write_metric_o; cold twins. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

extern size_t pipeline_sizeof_elf_ctx(void);

/* wave23 pure：hybrid thin owns elf_ctx calloc; cold seed keeps sizeof/malloc twin. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave38 pure: hybrid thin owns elf_ctx_free; cold seed twin; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif

/* wave25 pure: hybrid thin owns asm tmp path BSS; cold seed twin; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#else
extern uint8_t *driver_asm_tmp_path_slot(void);
#endif

/* wave34 pure: hybrid thin owns collect/defines/ndefines/bind/argv0/try_c/use_impl_c;
 * cold seed keeps C BSS + bodies; FROM_X no pure-dup (avoid dual defines BSS). */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#ifndef MAX_DEFINES
#endif
#if defined(XLANG_ASM_USE_COMPILER_IMPL_C)
#else
#define XLANG_TMP_PREFIX "xlang_"
#endif
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/*
 * Wave17: asm work BSS pure package under PREFER thin.
 * hybrid thin owns BSS + get/set/reset/cleanup；cold keeps C static + memset twin；
 * FROM_X no pure-dup (avoid dual BSS under hybrid).
 * asm work 槽：
 * p: 0 path 1 src 2 out_path 3 arena 4 module 5 entry 6 dsrc 7 dpath 8 dlens
 *    9 dar 10 dmod 11 out_buf 12 pctx 13 kind 14 code 15 msg 16 lib 17 target
 *    18 argv 19 asm_out 20 elf 21 defines 22 tmp_path 23 one_ctx 24 dep_out
 * i: 0 nlib 1 ndeps 2 nimp 3 main 4 emit_elf 5 want_exe 6 smoke 7 ndef 8 argc
 *    9 ec 10 j 11 entry_only 12 skip_dep_load 13 rc 14 n_closure 15 num_funcs
 * z: 0 src_len 1 asz 2 msz 3 dep_len
 * reset also clears g_driver_asm_tmp_path_slot[0] (tmp_path BSS cold twin; hybrid = wave25 pure).
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* ========== Cap residual: rt_run_compiler_parsed R2 full ========== */

#ifndef X_FULL_MAX_LIB_ROOTS
#define X_FULL_MAX_LIB_ROOTS 16
#endif
#ifndef XLANG_TMP_PREFIX
#if !defined(_WIN32) && !defined(_WIN64)
#define XLANG_TMP_PREFIX "/tmp/xlang_"
#else
#define XLANG_TMP_PREFIX "xlang_"
#endif
#endif

typedef struct DriverCompileParsedAbi {
    const char *input_path;
    const char *out_path;
    const char *lib_roots_arr[X_FULL_MAX_LIB_ROOTS];
    int n_lib_roots;
    int want_asm_backend;
    const char *target;
    const char *opt_level;
    int use_lto;
} DriverCompileParsedAbi;

/* 9.7.1: inline ABI writers take the opaque fd-handle stream (rt_preamble seed). */
extern int write_io_net_abi_inline(uint8_t *cf);
extern int write_fs_path_map_error_abi_inline(uint8_t *cf);
extern int xlang_write_path_bytes(const char *path, const void *data, size_t len);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail,
                         const char *fmt, ...);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void runtime_diag_errno_path_pair(const char *file, const char *kind, const char *op,
                                         const char *from_path, const char *to_path);
extern void driver_unlink_failed_output(const char *out_path);
extern const char *xlang_std_io_o_path(const char *argv0);
extern const char *xlang_rel_o_path_from_argv0(const char *argv0, const char *rel);
extern const char *xlang_runtime_panic_o_path(const char *argv0);
extern const char *xlang_repo_root_from_argv0(const char *argv0);
extern int xlang_invoke_cc(const char **c_paths, int n, const char *out_path, const char *target,
                          const char *opt_level, int use_lto, const char *io_o, const char *fs_o,
                          const char *process_o, const char *string_o, const char *heap_o, const char *path_o,
                          const char *runtime_o, const char *runtime_panic_o, const char *net_o,
                          const char *thread_o, const char *time_o, const char *random_o, const char *env_o,
                          const char *sync_o, const char *encoding_o, const char *base64_o, const char *crypto_o,
                          const char *log_o, const char *atomic_o, const char *channel_o, const char *backtrace_o,
                          const char *hash_o, const char *math_o, const char *sort_o, const char *ffi_o,
                          const char *db_o, const char *elf_o, const char *json_o, const char *csv_o,
                          const char *regex_o, const char *compress_o, const char *unicode_o, const char *dynlib_o,
                          const char *http_o, const char *tar_o, const char *simd_o, const char *context_o,
                          const char *datetime_o, const char *uuid_o, const char *url_o, const char *cli_o,
                          const char *security_o, const char *config_o, const char *cache_o, const char *trace_o,
                          const char *task_o, const char *schema_o, const char *test_o, const char *include_root,
                          const char *async_scheduler_o);
/* User-specified .o files from command line — single authority (G.3/G.4).
 * Why: xlang_invoke_cc takes a fixed variadic std/core .o list, so user .o args
 *   from argv (e.g. runtime_atomic_glue.o) never reach the cc link line.
 *   These setters plumb user .o args through xlang_invoke_cc_impl.
 * Authority: see runtime_link_abi.from_x.c (g_xlang_user_extra_o_files + setters).
 * PLATFORM: SHARED — argv is plain char**. */
extern void xlang_invoke_cc_set_user_o_files_from_argv(int argc, char **argv);
extern void xlang_invoke_cc_clear_user_o_files(void);
extern void codegen_reset_preamble_skip_mask(void);
extern void codegen_or_preamble_skip_mask(unsigned mask);
#ifndef CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS
#define CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS 1u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE 4u
#endif

/* wave32 pure: hybrid thin owns parsed field accessors + try_c_after_pp;
 * cold twins below; FROM_X no pure-dup.
 * PLATFORM: SHARED LP64 — offsetof layout must match thin.x constants. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave19 pure under PREFER：skip_codegen_dep_0; cold C twin; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave25 pure: hybrid thin owns parsed tmp BSS; cold seed twin; FROM_X no pure-dup.
 * PLATFORM: SHARED — 256 bytes matches .x rt_cp_step_open_out malloc(256)
 * and accommodates Windows long TEMP paths (C:\xlang_tmp\xlang_xlang_x.YZXDC4.c).
 * open_out (always seed) writes only via driver_parsed_tmp_c_buf() accessor. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#else
extern uint8_t *driver_parsed_tmp_c_buf(void);
extern uint8_t *driver_parsed_tmp_c_slot(void);
#endif

/* Permanent OS residual: host temp path prefix for mkstemp templates.
 * PLATFORM: POSIX → "/tmp/xlang_"; WINDOWS → "xlang_" (cwd-relative; TEMP via env elsewhere).
 * Pure open_out concatenates this with "xlang_x.XXXXXX" without #ifdef in .x. */
const char *xlang_driver_tmp_prefix(void) {
    return XLANG_TMP_PREFIX;
}

/* wave27 pure: hybrid thin owns open_out; cold twin; FROM_X no pure-dup.
 * wave25: writes tmp path only via pure/cold driver_parsed_tmp_c_buf().
 * PLATFORM: WINDOWS | POSIX — close mkstemp fd BEFORE rename (BLD001). */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave26 pure: hybrid thin owns fclose / fclose_rc / write_out; cold twins; FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave28 pure: hybrid thin owns invoke_cc orch; cold twin; FROM_X no pure-dup.
 * PLATFORM: SHARED — path pack + set/clear user .o + xlang_invoke_cc + fail/KEEP_C. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* wave31 pure: hybrid thin owns dump_prep + deps_has_* + apply_preamble_skip;
 * cold twins below; FROM_X no pure-dup.
 * PLATFORM: SHARED — mask bits match codegen.h; dump path /tmp dev-only. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#ifndef CODEGEN_PREAMBLE_SKIP_WEAK_IO_BATCH
#endif
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/*
 * Wave18: parsed work BSS pure package under PREFER thin.
 * hybrid thin owns BSS + get/set/reset/cleanup；cold keeps C static + memset twin；
 * FROM_X no pure-dup (avoid dual BSS under hybrid).
 * wave25: tmp slots pure under hybrid; cold twin still clears statics here.
 * parsed work 槽：
 * p: 0 path 1 src 2 out_path 3 arena 4 module 5 entry 6 dsrc 7 dpath 8 dlens
 *    9 dar 10 dmod 11 out_buf 12 pctx 13 kind 14 code 15 msg 16 lib 17 opt
 *    18 argv 19 cf 20 tmp_c 21 target 22 defs
 * i: 0 nlib 1 ndeps 2 nimp 3 main 4 want_asm 5 emit_stdout 6 ndef 7 use_lto
 *    8 argc 9 ec 10 j 11 check 12 n_funcs
 * z: 0 src_len 1 asz 2 msz
 */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* ========== Cap residual: rt_dispatch_impl R2 full ========== */

extern int driver_lib_roots_from_key(uint8_t *lib_key, const char **out_arr,
                                     char bufs[X_FULL_MAX_LIB_ROOTS][512]);
extern int driver_run_compiler_parsed(void *p, int argc, char **argv);

/* wave36 pure：hybrid thin owns lib_roots_from_key + run_compiler_parsed +
 * lib_root_at + opt_default; cold seed keeps C twins (static bufs + struct pack).
 * PLATFORM: SHARED LP64 — FROM_X no pure-dup. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* ---------- Cap residual：rt_asm_stub R2（GAS 行表 + OutBuf append） ---------- */
/* wave14 pure：hybrid thin owns gas_line_at/count + out_append_cstr (LE OutBuf layout);
 * cold seed keeps C table/append; FROM_X no pure-dup (H↓). */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#endif /* !XLANG_L2_RDABI_THIN_FROM_X */

/* ---------- Cap residual：rt_dispatch_thin R2（sibling path/access/fork） ---------- */
/* wave43 pure：hybrid thin owns driver_dispatch_sibling_try_spawn orch
 *   （null/argc + G.7 driver_argv0_basename_is + path pure BSS 512 + residual）；
 * cold twin under #ifndef FROM_X；FROM_X 无 pure-dup。
 * always-seed：xlang_driver_sibling_argv0_get（*u8→char** cast + av[0]）
 *   + xlang_driver_sibling_access_spawn（access X_OK + fork/exec 或 spawnvp）。
 * PLATFORM: SHARED orch；WINDOWS spawn vs POSIX fork in residual.
 */
extern int driver_argv0_basename_is(const char *argv0, const char *base);

/* Permanent Cap residual: *u8 argv_opaque → cast + av[0].
 * Pure wave43 cannot cast *u8→**u8 (-E drops body). Always linked under FROM_X.
 * PLATFORM: SHARED — cast glue only. */
uint8_t *xlang_driver_sibling_argv0_get(uint8_t *argv_opaque) {
    char **av;
    if (argv_opaque == NULL)
        return NULL;
    av = (char **)(void *)argv_opaque;
    if (av[0] == NULL)
        return NULL;
    return (uint8_t *)(void *)av[0];
}

/* Permanent OS residual: access(path, X_OK) then spawn/fork with av[0]=path.
 * Pure wave43 owns path build + basename gate; this is process boundary only.
 * PLATFORM: WINDOWS _spawnvp; POSIX fork+execvp+waitpid. */
int32_t xlang_driver_sibling_access_spawn(uint8_t *path, int32_t argc, uint8_t *argv_opaque) {
    char **av;
    char *xlang_c;
    (void)argc;
    if (path == NULL || argv_opaque == NULL)
        return -1;
    xlang_c = (char *)(void *)path;
    av = (char **)(void *)argv_opaque;
    if (access(xlang_c, X_OK) != 0)
        return -1;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    {
        intptr_t rc;
        av[0] = xlang_c;
        rc = _spawnvp(_P_WAIT, xlang_c, (const char *const *)av);
        if (rc == -1)
            return -1;
        return (int32_t)rc;
    }
#else
    {
        pid_t pid = fork();
        if (pid < 0)
            return -1;
        if (pid == 0) {
            av[0] = xlang_c;
            execvp(xlang_c, av);
            _exit(127);
        }
        {
            int st = 0;
            if (waitpid(pid, &st, 0) < 0)
                return -1;
            if (WIFEXITED(st))
                return (int32_t)WEXITSTATUS(st);
            return 1;
        }
    }
#endif
}

/* wave43 pure: hybrid thin owns sibling_try_spawn orch; cold twin under #ifndef FROM_X. */
#ifndef XLANG_L2_RDABI_THIN_FROM_X
#if defined(_WIN32)
#endif
#endif

int runtime_driver_abi_slice_marker(void) {
    return 1;
}
