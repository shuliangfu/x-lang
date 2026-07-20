/* seeds/rt_run_compiler_parsed_surface.from_x.c
 * R2 full surface — isomorphic with src/runtime/rt_run_compiler_parsed.x
 * Product PREFER_X_O: full .x + rest marker (H=0)
 * Regen: shux -E ... rt_run_compiler_parsed.x | strip DBG + polish libc redecl
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t pp_path(void);
extern int32_t pp_src(void);
extern int32_t pp_out_path(void);
extern int32_t pp_arena(void);
extern int32_t pp_module(void);
extern int32_t pp_entry(void);
extern int32_t pp_dsrc(void);
extern int32_t pp_dpath(void);
extern int32_t pp_dlens(void);
extern int32_t pp_dar(void);
extern int32_t pp_dmod(void);
extern int32_t pp_out(void);
extern int32_t pp_pctx(void);
extern int32_t pp_kind(void);
extern int32_t pp_code(void);
extern int32_t pp_msg(void);
extern int32_t pp_lib(void);
extern int32_t pp_opt(void);
extern int32_t pp_argv(void);
extern int32_t pp_cf(void);
extern int32_t pp_tmpc(void);
extern int32_t pp_target(void);
extern int32_t pp_defs(void);
extern int32_t pi_nlib(void);
extern int32_t pi_ndeps(void);
extern int32_t pi_nimp(void);
extern int32_t pi_main(void);
extern int32_t pi_want_asm(void);
extern int32_t pi_emit_stdout(void);
extern int32_t pi_ndef(void);
extern int32_t pi_use_lto(void);
extern int32_t pi_argc(void);
extern int32_t pi_ec(void);
extern int32_t pi_check(void);
extern int32_t pz_slen(void);
extern int32_t pz_asz(void);
extern int32_t pz_msz(void);
extern void rt_cp_fill_kind_io(uint8_t * k);
extern void rt_cp_fill_code_io001(uint8_t * c);
extern void rt_cp_fill_kind_pp(uint8_t * k);
extern void rt_cp_fill_code_pp002(uint8_t * c);
extern void rt_cp_fill_kind_pipe(uint8_t * k);
extern void rt_cp_fill_code_xp003(uint8_t * c);
extern void rt_cp_fill_code_xp005(uint8_t * c);
extern void rt_cp_fill_code_xp006(uint8_t * c);
extern void rt_cp_fill_code_xp007(uint8_t * c);
extern void rt_cp_fill_code_xp008(uint8_t * c);
extern void rt_cp_fill_kind_parse(uint8_t * k);
extern void rt_cp_fill_code_p001(uint8_t * c);
extern void rt_cp_msg_cannot_read(uint8_t * m);
extern void rt_cp_msg_pp_failed(uint8_t * m);
extern void rt_cp_msg_alloc(uint8_t * m);
extern void rt_cp_msg_src_large(uint8_t * m);
extern void rt_cp_msg_parse(uint8_t * m);
extern void rt_cp_msg_dep_alloc(uint8_t * m);
extern void rt_cp_msg_out_ctx(uint8_t * m);
extern void rt_cp_msg_dep_prerun(uint8_t * m);
extern void rt_cp_msg_pipe(uint8_t * m);
extern void rt_cp_diag(uint8_t * path, int32_t kind_fn, int32_t code_fn, int32_t msg_fn);
extern int32_t rt_cp_step_read_pp(void);
extern int32_t rt_cp_step_try_c(void);
extern int32_t rt_cp_step_parse(void);
extern int32_t rt_cp_step_load_deps(void);
extern int32_t rt_cp_step_open_out(void);
extern int32_t rt_cp_step_prerun(void);
extern int32_t rt_cp_step_pipeline(void);
extern int32_t rt_cp_step_finish(void);
extern int32_t driver_run_compiler_parsed(uint8_t * p, int32_t argc, uint8_t * argv);
extern uint8_t * runtime_read_file_malloc(uint8_t * path, size_t * out_len);
extern uint8_t * shux_preprocess_with_path(uint8_t * data, size_t len, uint8_t * path, uint8_t * defines, int32_t n_defines, size_t * out_len);
extern void pipeline_diag_emitted_reset(void);
extern int32_t pipeline_diag_emitted_get(void);
extern void diag_set_file(uint8_t * path, uint8_t * src, size_t len);
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern void parser_parse_into_init(uint8_t * module, uint8_t * arena);
extern void parser_parse_into_set_main_index(uint8_t * module, int32_t main_idx);
extern int32_t driver_get_module_num_funcs(uint8_t * m);
extern int32_t parser_get_module_num_imports(uint8_t * module);
extern void shux_get_entry_dir(uint8_t * path, uint8_t * out, size_t out_sz);
extern void pipeline_set_entry_dir(uint8_t * dir);
extern void driver_dep_seeded_clear_all(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t * path);
extern void driver_dep_publish_slot(int32_t j, uint8_t * arena, uint8_t * module, uint8_t * path);
extern void pipeline_set_dep_slots(uint8_t * arenas, uint8_t * modules);
extern void driver_dep_seed_slots(uint8_t * arenas, uint8_t * modules, int32_t n);
extern void codegen_set_dep_slots_for_x_pipeline(uint8_t * mods, uint8_t * paths, int32_t n);
extern void codegen_set_preamble_has_core_option_result(int32_t on);
extern int32_t runtime_report_precise_parse_failure_if_known(uint8_t * input_path, uint8_t * src, size_t src_len);
extern void pipeline_dep_ctx_heap_destroy(uint8_t * ctx);
extern int32_t shux_pipeline_run_x_pipeline_large_stack(uint8_t * module, uint8_t * arena, uint8_t * src, size_t src_len, uint8_t * out_buf, uint8_t * pctx);
extern void shux_pipeline_fill_ctx_path_buffers(uint8_t * ctx, uint8_t * entry_dir, uint8_t * lib_roots, int32_t n_lib);
extern void shux_pipeline_pctx_seed_dep_slots(uint8_t * ctx, uint8_t * dep_mods, uint8_t * dep_ar, uint8_t * dep_paths, int32_t n);
extern void shux_pipeline_one_ctx_for_dep_prerun(uint8_t * ctx, int32_t j, uint8_t * dep_mods, uint8_t * dep_ar, uint8_t * dep_paths, int32_t n, uint8_t * dep_src, size_t dep_len);
extern int32_t shux_collect_deps_transitive(uint8_t * module, size_t arena_sz, size_t module_sz, uint8_t * lib_roots, int32_t n_lib, uint8_t * entry_dir, uint8_t * defines, int32_t n_defines, uint8_t * cls, uint8_t * clens, uint8_t * cpaths, int32_t * n_closure);
extern uint8_t * shux_dep_prerun_entry_dir(uint8_t * entry_dir, uint8_t * lib_roots, int32_t n_lib);
extern int32_t shux_pipeline_dep_prerun_parse_only(uint8_t * mod, uint8_t * arena, uint8_t * src, size_t len);
extern int32_t shux_pipeline_dep_prerun_typeck_only(uint8_t * mod, uint8_t * arena, uint8_t * src, size_t len, uint8_t * out, uint8_t * ctx);
extern int32_t shux_asm_user_std_dep_skip_x_typeck(uint8_t * dep_path);
extern int32_t shux_output_want_exe(uint8_t * path);
extern int32_t driver_source_has_generic_syntax(uint8_t * path, int32_t path_len);
extern void driver_bump_stack_limit(void);
extern int32_t driver_check_only_get(void);
extern void driver_print_x_smoke_summary(uint8_t * module, size_t codegen_len);
extern void driver_print_check_ok(uint8_t * input_path);
extern void driver_x_pipeline_skip_typeck_set(int32_t v);
extern int32_t driver_deps_are_std_core_closure_only(uint8_t * dep_paths, int32_t n);
extern int32_t driver_run_asm_backend(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_roots, int32_t n_lib, uint8_t * target, int32_t argc, uint8_t * argv);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern uint8_t * driver_codegen_outbuf_calloc(void);
extern void driver_codegen_outbuf_free(uint8_t * p);
extern int32_t driver_codegen_outbuf_len(uint8_t * p);
extern uint8_t * driver_codegen_outbuf_data(uint8_t * p);
extern uint8_t * driver_pipeline_dep_ctx_calloc(void);
extern uint8_t * driver_ptr_table_calloc(int32_t n);
extern void driver_ptr_table_free(uint8_t * t);
extern uint8_t * driver_ptr_table_get(uint8_t * t, int32_t i);
extern void driver_ptr_table_set(uint8_t * t, int32_t i, uint8_t * p);
extern uint8_t * driver_size_table_calloc(int32_t n);
extern void driver_size_table_free(uint8_t * t);
extern size_t driver_size_table_get(uint8_t * t, int32_t i);
extern void driver_size_table_set(uint8_t * t, int32_t i, size_t v);
extern int32_t driver_parse_into_buf_rc(uint8_t * arena, uint8_t * module, uint8_t * data, int32_t len, int32_t * out_main_idx);
extern void driver_typeck_ndep_set(int32_t n);
extern void driver_typeck_dep_ptrs_set(int32_t j, uint8_t * mod, uint8_t * arena);
extern uint8_t * driver_entry_dir_slot(void);
extern void driver_pipeline_dep_ctx_set_entry_already_parsed(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_asm_entry_module_only(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_skip_codegen_dep_0(uint8_t * ctx, int32_t v);
extern uint8_t * driver_parsed_input_path(uint8_t * p);
extern uint8_t * driver_parsed_out_path(uint8_t * p);
extern uint8_t * driver_parsed_lib_roots(uint8_t * p);
extern int32_t driver_parsed_n_lib_roots(uint8_t * p);
extern int32_t driver_parsed_want_asm(uint8_t * p);
extern uint8_t * driver_parsed_target(uint8_t * p);
extern uint8_t * driver_parsed_opt_level(uint8_t * p);
extern int32_t driver_parsed_use_lto(uint8_t * p);
extern int32_t driver_parsed_try_c_after_pp(uint8_t * input_path, uint8_t * src, size_t src_len, uint8_t * lib_roots, int32_t n_lib, uint8_t * out_path, int32_t argc, uint8_t * argv, uint8_t * opt_level, int32_t use_lto, int32_t ndefines, uint8_t * defines);
extern uint8_t * driver_parsed_open_out_file(uint8_t * out_path, uint8_t * tmp_c_out64, int32_t * emit_stdout);
extern void driver_parsed_fclose(uint8_t * fp);
extern int32_t driver_parsed_fclose_rc(uint8_t * fp);
extern int32_t driver_parsed_write_out(uint8_t * fp, uint8_t * data, int32_t len);
extern int32_t driver_parsed_invoke_cc(uint8_t * tmp_c, uint8_t * out_path, uint8_t * opt_level, int32_t use_lto, uint8_t * argv0);
extern void driver_parsed_maybe_dump_prep(uint8_t * input_path, uint8_t * src, size_t src_len);
extern void driver_parsed_apply_preamble_skip(uint8_t * dep_paths, int32_t n_deps);
extern int32_t driver_asm_collect_defines(int32_t argc, uint8_t * argv);
extern uint8_t * driver_asm_defines_as_u8(void);
extern uint8_t * driver_asm_bind_lib_roots(uint8_t * lib_roots, int32_t n, int32_t * n_out);
extern uint8_t * driver_asm_argv0(uint8_t * argv);
extern void driver_parsed_work_reset(void);
extern uint8_t * driver_parsed_work_p_get(int32_t i);
extern void driver_parsed_work_p_set(int32_t i, uint8_t * v);
extern int32_t driver_parsed_work_i_get(int32_t i);
extern void driver_parsed_work_i_set(int32_t i, int32_t v);
extern size_t driver_parsed_work_z_get(int32_t i);
extern void driver_parsed_work_z_set(int32_t i, size_t v);
extern void driver_parsed_work_cleanup(void);
int32_t pp_path(void) {
  return 0;
}
int32_t pp_src(void) {
  return 1;
}
int32_t pp_out_path(void) {
  return 2;
}
int32_t pp_arena(void) {
  return 3;
}
int32_t pp_module(void) {
  return 4;
}
int32_t pp_entry(void) {
  return 5;
}
int32_t pp_dsrc(void) {
  return 6;
}
int32_t pp_dpath(void) {
  return 7;
}
int32_t pp_dlens(void) {
  return 8;
}
int32_t pp_dar(void) {
  return 9;
}
int32_t pp_dmod(void) {
  return 10;
}
int32_t pp_out(void) {
  return 11;
}
int32_t pp_pctx(void) {
  return 12;
}
int32_t pp_kind(void) {
  return 13;
}
int32_t pp_code(void) {
  return 14;
}
int32_t pp_msg(void) {
  return 15;
}
int32_t pp_lib(void) {
  return 16;
}
int32_t pp_opt(void) {
  return 17;
}
int32_t pp_argv(void) {
  return 18;
}
int32_t pp_cf(void) {
  return 19;
}
int32_t pp_tmpc(void) {
  return 20;
}
int32_t pp_target(void) {
  return 21;
}
int32_t pp_defs(void) {
  return 22;
}
int32_t pi_nlib(void) {
  return 0;
}
int32_t pi_ndeps(void) {
  return 1;
}
int32_t pi_nimp(void) {
  return 2;
}
int32_t pi_main(void) {
  return 3;
}
int32_t pi_want_asm(void) {
  return 4;
}
int32_t pi_emit_stdout(void) {
  return 5;
}
int32_t pi_ndef(void) {
  return 6;
}
int32_t pi_use_lto(void) {
  return 7;
}
int32_t pi_argc(void) {
  return 8;
}
int32_t pi_ec(void) {
  return 9;
}
int32_t pi_check(void) {
  return 11;
}
int32_t pz_slen(void) {
  return 0;
}
int32_t pz_asz(void) {
  return 1;
}
int32_t pz_msz(void) {
  return 2;
}
void rt_cp_fill_kind_io(uint8_t * k) {
  (void)(((k)[0] = 105));
  (void)(((k)[1] = 111));
  (void)(((k)[2] = 32));
  (void)(((k)[3] = 101));
  (void)(((k)[4] = 114));
  (void)(((k)[5] = 114));
  (void)(((k)[6] = 111));
  (void)(((k)[7] = 114));
  (void)(((k)[8] = 0));
}
void rt_cp_fill_code_io001(uint8_t * c) {
  (void)(((c)[0] = 73));
  (void)(((c)[1] = 79));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 49));
  (void)(((c)[5] = 0));
}
void rt_cp_fill_kind_pp(uint8_t * k) {
  (void)(((k)[0] = 112));
  (void)(((k)[1] = 114));
  (void)(((k)[2] = 101));
  (void)(((k)[3] = 112));
  (void)(((k)[4] = 114));
  (void)(((k)[5] = 111));
  (void)(((k)[6] = 99));
  (void)(((k)[7] = 101));
  (void)(((k)[8] = 115));
  (void)(((k)[9] = 115));
  (void)(((k)[10] = 32));
  (void)(((k)[11] = 101));
  (void)(((k)[12] = 114));
  (void)(((k)[13] = 114));
  (void)(((k)[14] = 111));
  (void)(((k)[15] = 114));
  (void)(((k)[16] = 0));
}
void rt_cp_fill_code_pp002(uint8_t * c) {
  (void)(((c)[0] = 80));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 50));
  (void)(((c)[5] = 0));
}
void rt_cp_fill_kind_pipe(uint8_t * k) {
  (void)(((k)[0] = 112));
  (void)(((k)[1] = 105));
  (void)(((k)[2] = 112));
  (void)(((k)[3] = 101));
  (void)(((k)[4] = 108));
  (void)(((k)[5] = 105));
  (void)(((k)[6] = 110));
  (void)(((k)[7] = 101));
  (void)(((k)[8] = 32));
  (void)(((k)[9] = 101));
  (void)(((k)[10] = 114));
  (void)(((k)[11] = 114));
  (void)(((k)[12] = 111));
  (void)(((k)[13] = 114));
  (void)(((k)[14] = 0));
}
void rt_cp_fill_code_xp003(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 51));
  (void)(((c)[5] = 0));
}
void rt_cp_fill_code_xp005(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 53));
  (void)(((c)[5] = 0));
}
void rt_cp_fill_code_xp006(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 54));
  (void)(((c)[5] = 0));
}
void rt_cp_fill_code_xp007(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 55));
  (void)(((c)[5] = 0));
}
void rt_cp_fill_code_xp008(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 56));
  (void)(((c)[5] = 0));
}
void rt_cp_fill_kind_parse(uint8_t * k) {
  (void)(((k)[0] = 112));
  (void)(((k)[1] = 97));
  (void)(((k)[2] = 114));
  (void)(((k)[3] = 115));
  (void)(((k)[4] = 101));
  (void)(((k)[5] = 32));
  (void)(((k)[6] = 101));
  (void)(((k)[7] = 114));
  (void)(((k)[8] = 114));
  (void)(((k)[9] = 111));
  (void)(((k)[10] = 114));
  (void)(((k)[11] = 0));
}
void rt_cp_fill_code_p001(uint8_t * c) {
  (void)(((c)[0] = 80));
  (void)(((c)[1] = 48));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 49));
  (void)(((c)[4] = 0));
}
void rt_cp_msg_cannot_read(uint8_t * m) {
  (void)(((m)[0] = 99));
  (void)(((m)[1] = 97));
  (void)(((m)[2] = 110));
  (void)(((m)[3] = 110));
  (void)(((m)[4] = 111));
  (void)(((m)[5] = 116));
  (void)(((m)[6] = 32));
  (void)(((m)[7] = 114));
  (void)(((m)[8] = 101));
  (void)(((m)[9] = 97));
  (void)(((m)[10] = 100));
  (void)(((m)[11] = 32));
  (void)(((m)[12] = 102));
  (void)(((m)[13] = 105));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 101));
  (void)(((m)[16] = 0));
}
void rt_cp_msg_pp_failed(uint8_t * m) {
  (void)(((m)[0] = 112));
  (void)(((m)[1] = 114));
  (void)(((m)[2] = 101));
  (void)(((m)[3] = 112));
  (void)(((m)[4] = 114));
  (void)(((m)[5] = 111));
  (void)(((m)[6] = 99));
  (void)(((m)[7] = 101));
  (void)(((m)[8] = 115));
  (void)(((m)[9] = 115));
  (void)(((m)[10] = 32));
  (void)(((m)[11] = 102));
  (void)(((m)[12] = 97));
  (void)(((m)[13] = 105));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 101));
  (void)(((m)[16] = 100));
  (void)(((m)[17] = 0));
}
void rt_cp_msg_alloc(uint8_t * m) {
  (void)(((m)[0] = 46));
  (void)(((m)[1] = 120));
  (void)(((m)[2] = 32));
  (void)(((m)[3] = 112));
  (void)(((m)[4] = 105));
  (void)(((m)[5] = 112));
  (void)(((m)[6] = 101));
  (void)(((m)[7] = 108));
  (void)(((m)[8] = 105));
  (void)(((m)[9] = 110));
  (void)(((m)[10] = 101));
  (void)(((m)[11] = 32));
  (void)(((m)[12] = 97));
  (void)(((m)[13] = 108));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 111));
  (void)(((m)[16] = 99));
  (void)(((m)[17] = 32));
  (void)(((m)[18] = 102));
  (void)(((m)[19] = 97));
  (void)(((m)[20] = 105));
  (void)(((m)[21] = 108));
  (void)(((m)[22] = 101));
  (void)(((m)[23] = 100));
  (void)(((m)[24] = 0));
}
void rt_cp_msg_src_large(uint8_t * m) {
  (void)(((m)[0] = 101));
  (void)(((m)[1] = 110));
  (void)(((m)[2] = 116));
  (void)(((m)[3] = 114));
  (void)(((m)[4] = 121));
  (void)(((m)[5] = 32));
  (void)(((m)[6] = 115));
  (void)(((m)[7] = 111));
  (void)(((m)[8] = 117));
  (void)(((m)[9] = 114));
  (void)(((m)[10] = 99));
  (void)(((m)[11] = 101));
  (void)(((m)[12] = 32));
  (void)(((m)[13] = 116));
  (void)(((m)[14] = 111));
  (void)(((m)[15] = 111));
  (void)(((m)[16] = 32));
  (void)(((m)[17] = 108));
  (void)(((m)[18] = 97));
  (void)(((m)[19] = 114));
  (void)(((m)[20] = 103));
  (void)(((m)[21] = 101));
  (void)(((m)[22] = 0));
}
void rt_cp_msg_parse(uint8_t * m) {
  (void)(((m)[0] = 112));
  (void)(((m)[1] = 97));
  (void)(((m)[2] = 114));
  (void)(((m)[3] = 115));
  (void)(((m)[4] = 101));
  (void)(((m)[5] = 32));
  (void)(((m)[6] = 102));
  (void)(((m)[7] = 97));
  (void)(((m)[8] = 105));
  (void)(((m)[9] = 108));
  (void)(((m)[10] = 101));
  (void)(((m)[11] = 100));
  (void)(((m)[12] = 0));
}
void rt_cp_msg_dep_alloc(uint8_t * m) {
  (void)(((m)[0] = 100));
  (void)(((m)[1] = 101));
  (void)(((m)[2] = 112));
  (void)(((m)[3] = 32));
  (void)(((m)[4] = 97));
  (void)(((m)[5] = 108));
  (void)(((m)[6] = 108));
  (void)(((m)[7] = 111));
  (void)(((m)[8] = 99));
  (void)(((m)[9] = 32));
  (void)(((m)[10] = 102));
  (void)(((m)[11] = 97));
  (void)(((m)[12] = 105));
  (void)(((m)[13] = 108));
  (void)(((m)[14] = 101));
  (void)(((m)[15] = 100));
  (void)(((m)[16] = 0));
}
void rt_cp_msg_out_ctx(uint8_t * m) {
  (void)(((m)[0] = 111));
  (void)(((m)[1] = 117));
  (void)(((m)[2] = 116));
  (void)(((m)[3] = 47));
  (void)(((m)[4] = 99));
  (void)(((m)[5] = 116));
  (void)(((m)[6] = 120));
  (void)(((m)[7] = 32));
  (void)(((m)[8] = 97));
  (void)(((m)[9] = 108));
  (void)(((m)[10] = 108));
  (void)(((m)[11] = 111));
  (void)(((m)[12] = 99));
  (void)(((m)[13] = 32));
  (void)(((m)[14] = 102));
  (void)(((m)[15] = 97));
  (void)(((m)[16] = 105));
  (void)(((m)[17] = 108));
  (void)(((m)[18] = 101));
  (void)(((m)[19] = 100));
  (void)(((m)[20] = 0));
}
void rt_cp_msg_dep_prerun(uint8_t * m) {
  (void)(((m)[0] = 100));
  (void)(((m)[1] = 101));
  (void)(((m)[2] = 112));
  (void)(((m)[3] = 32));
  (void)(((m)[4] = 112));
  (void)(((m)[5] = 114));
  (void)(((m)[6] = 101));
  (void)(((m)[7] = 114));
  (void)(((m)[8] = 117));
  (void)(((m)[9] = 110));
  (void)(((m)[10] = 32));
  (void)(((m)[11] = 102));
  (void)(((m)[12] = 97));
  (void)(((m)[13] = 105));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 101));
  (void)(((m)[16] = 100));
  (void)(((m)[17] = 0));
}
void rt_cp_msg_pipe(uint8_t * m) {
  (void)(((m)[0] = 112));
  (void)(((m)[1] = 105));
  (void)(((m)[2] = 112));
  (void)(((m)[3] = 101));
  (void)(((m)[4] = 108));
  (void)(((m)[5] = 105));
  (void)(((m)[6] = 110));
  (void)(((m)[7] = 101));
  (void)(((m)[8] = 32));
  (void)(((m)[9] = 102));
  (void)(((m)[10] = 97));
  (void)(((m)[11] = 105));
  (void)(((m)[12] = 108));
  (void)(((m)[13] = 101));
  (void)(((m)[14] = 100));
  (void)(((m)[15] = 0));
}
void rt_cp_diag(uint8_t * path, int32_t kind_fn, int32_t code_fn, int32_t msg_fn) {
  uint8_t * k = ((uint8_t *)(0));
  uint8_t * c = ((uint8_t *)(0));
  uint8_t * m = ((uint8_t *)(0));
  {
    (void)((k = driver_parsed_work_p_get(pp_kind())));
    (void)((c = driver_parsed_work_p_get(pp_code())));
    (void)((m = driver_parsed_work_p_get(pp_msg())));
  }
  if ((k ==((uint8_t *)(0)))) {
    return;
  }
  if ((kind_fn ==1)) {
    (void)(rt_cp_fill_kind_io(k));
  }
  if ((kind_fn ==2)) {
    (void)(rt_cp_fill_kind_pp(k));
  }
  if ((kind_fn ==3)) {
    (void)(rt_cp_fill_kind_pipe(k));
  }
  if ((kind_fn ==4)) {
    (void)(rt_cp_fill_kind_parse(k));
  }
  if ((code_fn ==1)) {
    (void)(rt_cp_fill_code_io001(c));
  }
  if ((code_fn ==2)) {
    (void)(rt_cp_fill_code_pp002(c));
  }
  if ((code_fn ==3)) {
    (void)(rt_cp_fill_code_xp003(c));
  }
  if ((code_fn ==5)) {
    (void)(rt_cp_fill_code_xp005(c));
  }
  if ((code_fn ==6)) {
    (void)(rt_cp_fill_code_xp006(c));
  }
  if ((code_fn ==7)) {
    (void)(rt_cp_fill_code_xp007(c));
  }
  if ((code_fn ==8)) {
    (void)(rt_cp_fill_code_xp008(c));
  }
  if ((code_fn ==9)) {
    (void)(rt_cp_fill_code_p001(c));
  }
  if ((msg_fn ==1)) {
    (void)(rt_cp_msg_cannot_read(m));
  }
  if ((msg_fn ==2)) {
    (void)(rt_cp_msg_pp_failed(m));
  }
  if ((msg_fn ==3)) {
    (void)(rt_cp_msg_alloc(m));
  }
  if ((msg_fn ==4)) {
    (void)(rt_cp_msg_src_large(m));
  }
  if ((msg_fn ==5)) {
    (void)(rt_cp_msg_parse(m));
  }
  if ((msg_fn ==6)) {
    (void)(rt_cp_msg_dep_alloc(m));
  }
  if ((msg_fn ==7)) {
    (void)(rt_cp_msg_out_ctx(m));
  }
  if ((msg_fn ==8)) {
    (void)(rt_cp_msg_dep_prerun(m));
  }
  if ((msg_fn ==9)) {
    (void)(rt_cp_msg_pipe(m));
  }
  {
    (void)(diag_report_with_code(path, 0, 0, k, c, m, ((uint8_t *)(0))));
  }
  (void)(0);
  return;
}
int32_t rt_cp_step_read_pp(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * raw = ((uint8_t *)(0));
  size_t raw_len = 0;
  uint8_t * src = ((uint8_t *)(0));
  size_t src_len = 0;
  int32_t em = 0;
  {
    (void)((path = driver_parsed_work_p_get(pp_path())));
    (void)((raw = runtime_read_file_malloc(path, &(raw_len))));
  }
  if ((raw ==((uint8_t *)(0)))) {
    (void)(rt_cp_diag(path, 1, 1, 1));
    return 1;
  }
  {
    (void)(pipeline_diag_emitted_reset());
    (void)((src = shux_preprocess_with_path(raw, raw_len, path, ((uint8_t *)(0)), 0, &(src_len))));
    (void)(free(raw));
  }
  if ((src ==((uint8_t *)(0)))) {
    {
      (void)((em = pipeline_diag_emitted_get()));
    }
    if ((em ==0)) {
      (void)(rt_cp_diag(path, 2, 2, 2));
    }
    return 1;
  }
  {
    (void)(diag_set_file(path, src, src_len));
    (void)(driver_parsed_work_p_set(pp_src(), src));
    (void)(driver_parsed_work_z_set(pz_slen(), src_len));
    (void)(driver_parsed_maybe_dump_prep(path, src, src_len));
  }
  return 0;
}
int32_t rt_cp_step_try_c(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * src = ((uint8_t *)(0));
  size_t src_len = 0;
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * outp = ((uint8_t *)(0));
  int32_t argc = 0;
  uint8_t * argv = ((uint8_t *)(0));
  uint8_t * opt = ((uint8_t *)(0));
  int32_t use_lto = 0;
  int32_t ndef = 0;
  uint8_t * defs = ((uint8_t *)(0));
  int32_t rc = 0;
  {
    (void)((path = driver_parsed_work_p_get(pp_path())));
    (void)((src = driver_parsed_work_p_get(pp_src())));
    (void)((src_len = driver_parsed_work_z_get(pz_slen())));
    (void)((lib = driver_parsed_work_p_get(pp_lib())));
    (void)((nlib = driver_parsed_work_i_get(pi_nlib())));
    (void)((outp = driver_parsed_work_p_get(pp_out_path())));
    (void)((argc = driver_parsed_work_i_get(pi_argc())));
    (void)((argv = driver_parsed_work_p_get(pp_argv())));
    (void)((opt = driver_parsed_work_p_get(pp_opt())));
    (void)((use_lto = driver_parsed_work_i_get(pi_use_lto())));
    (void)((ndef = driver_parsed_work_i_get(pi_ndef())));
    (void)((defs = driver_parsed_work_p_get(pp_defs())));
    (void)((rc = driver_parsed_try_c_after_pp(path, src, src_len, lib, nlib, outp, argc, argv, opt, use_lto, ndef, defs)));
  }
  if ((rc ==(0 - 2))) {
    return 0;
  }
  {
    (void)(driver_parsed_work_i_set(pi_ec(), rc));
  }
  return 2;
}
int32_t rt_cp_step_parse(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * src = ((uint8_t *)(0));
  size_t src_len = 0;
  size_t asz = 0;
  size_t msz = 0;
  uint8_t * arena = ((uint8_t *)(0));
  uint8_t * module = ((uint8_t *)(0));
  int32_t main_idx = 0;
  int32_t pr = 0;
  int32_t nimp = 0;
  uint8_t * entry = ((uint8_t *)(0));
  int32_t max_i32 = 2147483647;
  {
    (void)((path = driver_parsed_work_p_get(pp_path())));
    (void)((src = driver_parsed_work_p_get(pp_src())));
    (void)((src_len = driver_parsed_work_z_get(pz_slen())));
    (void)((asz = pipeline_sizeof_arena()));
    (void)((msz = pipeline_sizeof_module()));
    (void)((arena = malloc(asz)));
    (void)((module = malloc(msz)));
  }
  if ((arena ==((uint8_t *)(0)))) {
    if ((module !=((uint8_t *)(0)))) {
      {
        (void)(free(module));
      }
    }
    return 1;
  }
  if ((module ==((uint8_t *)(0)))) {
    {
      (void)(free(arena));
    }
    return 1;
  }
  if ((src_len > ((size_t)(max_i32)))) {
    (void)(rt_cp_diag(path, 3, 7, 4));
    {
      (void)(free(arena));
      (void)(free(module));
    }
    return 1;
  }
  {
    (void)(memset(arena, 0, asz));
    (void)(memset(module, 0, msz));
    (void)(parser_parse_into_init(module, arena));
    (void)((pr = driver_parse_into_buf_rc(arena, module, src, ((int32_t)(src_len)), &(main_idx))));
  }
  if ((pr !=0)) {
    {
      (void)((pr = runtime_report_precise_parse_failure_if_known(path, src, src_len)));
    }
    if ((pr ==0)) {
      (void)(rt_cp_diag(path, 4, 9, 5));
    }
    {
      (void)(free(arena));
      (void)(free(module));
    }
    return 1;
  }
  {
    (void)(parser_parse_into_set_main_index(module, main_idx));
    (void)((nimp = parser_get_module_num_imports(module)));
    (void)((entry = driver_entry_dir_slot()));
    (void)(shux_get_entry_dir(path, entry, ((size_t)(512))));
    if ((nimp > 0)) {
      (void)(pipeline_set_entry_dir(entry));
    }
    (void)(driver_parsed_work_p_set(pp_arena(), arena));
    (void)(driver_parsed_work_p_set(pp_module(), module));
    (void)(driver_parsed_work_p_set(pp_entry(), entry));
    (void)(driver_parsed_work_z_set(pz_asz(), asz));
    (void)(driver_parsed_work_z_set(pz_msz(), msz));
    (void)(driver_parsed_work_i_set(pi_main(), main_idx));
    (void)(driver_parsed_work_i_set(pi_nimp(), nimp));
  }
  return 0;
}
int32_t rt_cp_step_load_deps(void) {
  uint8_t * module = ((uint8_t *)(0));
  size_t asz = 0;
  size_t msz = 0;
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * entry = ((uint8_t *)(0));
  uint8_t * defs = ((uint8_t *)(0));
  int32_t ndef = 0;
  int32_t nimp = 0;
  uint8_t * dsrc = ((uint8_t *)(0));
  uint8_t * dpath = ((uint8_t *)(0));
  uint8_t * dlens = ((uint8_t *)(0));
  uint8_t * dar = ((uint8_t *)(0));
  uint8_t * dmod = ((uint8_t *)(0));
  int32_t n_deps = 0;
  uint8_t * out_buf = ((uint8_t *)(0));
  uint8_t * pctx = ((uint8_t *)(0));
  int32_t j = 0;
  int32_t rc = 0;
  {
    (void)((module = driver_parsed_work_p_get(pp_module())));
    (void)((asz = driver_parsed_work_z_get(pz_asz())));
    (void)((msz = driver_parsed_work_z_get(pz_msz())));
    (void)((lib = driver_parsed_work_p_get(pp_lib())));
    (void)((nlib = driver_parsed_work_i_get(pi_nlib())));
    (void)((entry = driver_parsed_work_p_get(pp_entry())));
    (void)((defs = driver_parsed_work_p_get(pp_defs())));
    (void)((ndef = driver_parsed_work_i_get(pi_ndef())));
    (void)((nimp = driver_parsed_work_i_get(pi_nimp())));
  }
  if ((nimp > 0)) {
    if ((nimp <=32)) {
      {
        (void)((dsrc = driver_ptr_table_calloc(128)));
        (void)((dpath = driver_ptr_table_calloc(128)));
        (void)((dlens = driver_size_table_calloc(128)));
      }
      if ((dsrc ==((uint8_t *)(0)))) {
        return 1;
      }
      if ((dpath ==((uint8_t *)(0)))) {
        {
          (void)(driver_ptr_table_free(dsrc));
        }
        return 1;
      }
      if ((dlens ==((uint8_t *)(0)))) {
        {
          (void)(driver_ptr_table_free(dsrc));
          (void)(driver_ptr_table_free(dpath));
        }
        return 1;
      }
      {
        (void)((rc = shux_collect_deps_transitive(module, asz, msz, lib, nlib, entry, defs, ndef, dsrc, dlens, dpath, &(n_deps))));
      }
      if ((rc !=0)) {
        {
          (void)(driver_ptr_table_free(dsrc));
          (void)(driver_ptr_table_free(dpath));
          (void)(driver_size_table_free(dlens));
        }
        return 1;
      }
      {
        (void)(driver_parsed_work_p_set(pp_dsrc(), dsrc));
        (void)(driver_parsed_work_p_set(pp_dpath(), dpath));
        (void)(driver_parsed_work_p_set(pp_dlens(), dlens));
        (void)(driver_parsed_work_i_set(pi_ndeps(), n_deps));
      }
    }
  }
  {
    (void)((n_deps = driver_parsed_work_i_get(pi_ndeps())));
  }
  if ((n_deps > 0)) {
    {
      (void)((dar = driver_ptr_table_calloc(n_deps)));
      (void)((dmod = driver_ptr_table_calloc(n_deps)));
    }
    if ((dar ==((uint8_t *)(0)))) {
      return 1;
    }
    if ((dmod ==((uint8_t *)(0)))) {
      {
        (void)(driver_ptr_table_free(dar));
      }
      return 1;
    }
    (void)((j = (n_deps - 1)));
    while ((j >=0)) {
      uint8_t * a = ((uint8_t *)(0));
      uint8_t * m = ((uint8_t *)(0));
      {
        (void)((a = malloc(asz)));
        (void)((m = malloc(msz)));
      }
      if ((a ==((uint8_t *)(0)))) {
        if ((m !=((uint8_t *)(0)))) {
          {
            (void)(free(m));
          }
        }
        (void)(rt_cp_diag(((uint8_t *)(0)), 3, 5, 6));
        {
          (void)(driver_ptr_table_free(dar));
          (void)(driver_ptr_table_free(dmod));
        }
        return 1;
      }
      if ((m ==((uint8_t *)(0)))) {
        {
          (void)(free(a));
        }
        (void)(rt_cp_diag(((uint8_t *)(0)), 3, 5, 6));
        {
          (void)(driver_ptr_table_free(dar));
          (void)(driver_ptr_table_free(dmod));
        }
        return 1;
      }
      {
        (void)(memset(a, 0, asz));
        (void)(memset(m, 0, msz));
        (void)(driver_ptr_table_set(dar, j, a));
        (void)(driver_ptr_table_set(dmod, j, m));
      }
      (void)((j = (j - 1)));
    }
    {
      (void)(driver_parsed_work_p_set(pp_dar(), dar));
      (void)(driver_parsed_work_p_set(pp_dmod(), dmod));
    }
  }
  {
    (void)((out_buf = driver_codegen_outbuf_calloc()));
    (void)((pctx = driver_pipeline_dep_ctx_calloc()));
  }
  if ((out_buf ==((uint8_t *)(0)))) {
    if ((pctx !=((uint8_t *)(0)))) {
      {
        (void)(pipeline_dep_ctx_heap_destroy(pctx));
      }
    }
    (void)(rt_cp_diag(((uint8_t *)(0)), 3, 6, 7));
    return 1;
  }
  if ((pctx ==((uint8_t *)(0)))) {
    {
      (void)(driver_codegen_outbuf_free(out_buf));
    }
    (void)(rt_cp_diag(((uint8_t *)(0)), 3, 6, 7));
    return 1;
  }
  {
    (void)(shux_pipeline_fill_ctx_path_buffers(pctx, entry, lib, nlib));
    (void)((dmod = driver_parsed_work_p_get(pp_dmod())));
    (void)((dar = driver_parsed_work_p_get(pp_dar())));
    (void)((dpath = driver_parsed_work_p_get(pp_dpath())));
    (void)((n_deps = driver_parsed_work_i_get(pi_ndeps())));
    (void)(shux_pipeline_pctx_seed_dep_slots(pctx, dmod, dar, dpath, n_deps));
    (void)(driver_pipeline_dep_ctx_set_skip_codegen_dep_0(pctx, 0));
    (void)(driver_parsed_work_p_set(pp_out(), out_buf));
    (void)(driver_parsed_work_p_set(pp_pctx(), pctx));
  }
  return 0;
}
int32_t rt_cp_step_open_out(void) {
  uint8_t * outp = ((uint8_t *)(0));
  uint8_t * tmp = ((uint8_t *)(0));
  uint8_t * cf = ((uint8_t *)(0));
  int32_t emit_stdout = 0;
  {
    (void)((outp = driver_parsed_work_p_get(pp_out_path())));
    (void)((tmp = malloc(((size_t)(64)))));
  }
  if ((tmp ==((uint8_t *)(0)))) {
    return 1;
  }
  {
    (void)(memset(tmp, 0, ((size_t)(64))));
    (void)((cf = driver_parsed_open_out_file(outp, tmp, &(emit_stdout))));
  }
  if ((cf ==((uint8_t *)(0)))) {
    {
      (void)(free(tmp));
    }
    return 1;
  }
  {
    (void)(driver_parsed_work_p_set(pp_cf(), cf));
    (void)(driver_parsed_work_p_set(pp_tmpc(), tmp));
    (void)(driver_parsed_work_i_set(pi_emit_stdout(), emit_stdout));
  }
  return 0;
}
int32_t rt_cp_step_prerun(void) {
  int32_t n_deps = 0;
  int32_t j = 0;
  uint8_t * entry = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * dsrc = ((uint8_t *)(0));
  uint8_t * dpath = ((uint8_t *)(0));
  uint8_t * dlens = ((uint8_t *)(0));
  uint8_t * dar = ((uint8_t *)(0));
  uint8_t * dmod = ((uint8_t *)(0));
  uint8_t * one = ((uint8_t *)(0));
  uint8_t * dep_out = ((uint8_t *)(0));
  uint8_t * dep_src = ((uint8_t *)(0));
  size_t dep_len = 0;
  uint8_t * p = ((uint8_t *)(0));
  int32_t ec = 0;
  int32_t check = 0;
  int32_t skip = 0;
  {
    (void)((n_deps = driver_parsed_work_i_get(pi_ndeps())));
    (void)((entry = driver_parsed_work_p_get(pp_entry())));
    (void)((lib = driver_parsed_work_p_get(pp_lib())));
    (void)((nlib = driver_parsed_work_i_get(pi_nlib())));
    (void)((dsrc = driver_parsed_work_p_get(pp_dsrc())));
    (void)((dpath = driver_parsed_work_p_get(pp_dpath())));
    (void)((dlens = driver_parsed_work_p_get(pp_dlens())));
    (void)((dar = driver_parsed_work_p_get(pp_dar())));
    (void)((dmod = driver_parsed_work_p_get(pp_dmod())));
    (void)((check = driver_check_only_get()));
    (void)(driver_dep_seeded_clear_all());
  }
  if ((n_deps <=0)) {
    return 0;
  }
  (void)((j = (n_deps - 1)));
  while ((j >=0)) {
    {
      (void)((one = driver_pipeline_dep_ctx_calloc()));
      (void)((dep_out = driver_codegen_outbuf_calloc()));
    }
    if ((one ==((uint8_t *)(0)))) {
      if ((dep_out !=((uint8_t *)(0)))) {
        {
          (void)(driver_codegen_outbuf_free(dep_out));
        }
      }
      (void)(rt_cp_diag(((uint8_t *)(0)), 3, 6, 7));
      return 1;
    }
    if ((dep_out ==((uint8_t *)(0)))) {
      {
        (void)(pipeline_dep_ctx_heap_destroy(one));
      }
      (void)(rt_cp_diag(((uint8_t *)(0)), 3, 6, 7));
      return 1;
    }
    {
      (void)((p = shux_dep_prerun_entry_dir(entry, lib, nlib)));
      (void)(shux_pipeline_fill_ctx_path_buffers(one, p, lib, nlib));
      (void)((dep_src = driver_ptr_table_get(dsrc, j)));
      (void)((dep_len = driver_size_table_get(dlens, j)));
      (void)(shux_pipeline_one_ctx_for_dep_prerun(one, j, dmod, dar, dpath, n_deps, dep_src, dep_len));
      (void)((p = driver_ptr_table_get(dpath, j)));
      (void)(driver_set_current_dep_path_for_codegen(p));
      (void)((skip = 0));
      if ((check !=0)) {
        (void)((skip = 1));
      }
      if ((shux_asm_user_std_dep_skip_x_typeck(p) !=0)) {
        (void)((skip = 1));
      }
      if ((driver_deps_are_std_core_closure_only(dpath, n_deps) !=0)) {
        (void)((skip = 1));
      }
    }
    if ((skip !=0)) {
      {
        (void)((ec = shux_pipeline_dep_prerun_parse_only(driver_ptr_table_get(dmod, j), driver_ptr_table_get(dar, j), dep_src, dep_len)));
      }
    } else {
      {
        (void)((ec = shux_pipeline_dep_prerun_typeck_only(driver_ptr_table_get(dmod, j), driver_ptr_table_get(dar, j), dep_src, dep_len, dep_out, one)));
      }
    }
    {
      (void)(driver_set_current_dep_path_for_codegen(((uint8_t *)(0))));
      (void)(pipeline_dep_ctx_heap_destroy(one));
      (void)(driver_codegen_outbuf_free(dep_out));
    }
    if ((ec !=0)) {
      (void)(rt_cp_diag(p, 3, 8, 8));
      return 1;
    }
    {
      (void)(driver_dep_publish_slot(j, driver_ptr_table_get(dar, j), driver_ptr_table_get(dmod, j), driver_ptr_table_get(dpath, j)));
    }
    (void)((j = (j - 1)));
  }
  return 0;
}
int32_t rt_cp_step_pipeline(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * src = ((uint8_t *)(0));
  size_t src_len = 0;
  uint8_t * arena = ((uint8_t *)(0));
  uint8_t * module = ((uint8_t *)(0));
  size_t asz = 0;
  size_t msz = 0;
  int32_t n_deps = 0;
  uint8_t * dar = ((uint8_t *)(0));
  uint8_t * dmod = ((uint8_t *)(0));
  uint8_t * dpath = ((uint8_t *)(0));
  uint8_t * out_buf = ((uint8_t *)(0));
  uint8_t * pctx = ((uint8_t *)(0));
  int32_t j = 0;
  int32_t ec = 0;
  int32_t out_len = 0;
  int32_t check = 0;
  int32_t want_asm = 0;
  int32_t core_only = 0;
  {
    (void)((path = driver_parsed_work_p_get(pp_path())));
    (void)((src = driver_parsed_work_p_get(pp_src())));
    (void)((src_len = driver_parsed_work_z_get(pz_slen())));
    (void)((arena = driver_parsed_work_p_get(pp_arena())));
    (void)((module = driver_parsed_work_p_get(pp_module())));
    (void)((asz = driver_parsed_work_z_get(pz_asz())));
    (void)((msz = driver_parsed_work_z_get(pz_msz())));
    (void)((n_deps = driver_parsed_work_i_get(pi_ndeps())));
    (void)((dar = driver_parsed_work_p_get(pp_dar())));
    (void)((dmod = driver_parsed_work_p_get(pp_dmod())));
    (void)((dpath = driver_parsed_work_p_get(pp_dpath())));
    (void)((out_buf = driver_parsed_work_p_get(pp_out())));
    (void)((pctx = driver_parsed_work_p_get(pp_pctx())));
    (void)((check = driver_check_only_get()));
    (void)((want_asm = driver_parsed_work_i_get(pi_want_asm())));
    (void)(driver_typeck_ndep_set(n_deps));
  }
  (void)((j = 0));
  while ((j < n_deps)) {
    {
      (void)(driver_typeck_dep_ptrs_set(j, driver_ptr_table_get(dmod, j), driver_ptr_table_get(dar, j)));
    }
    (void)((j = (j + 1)));
  }
  {
    (void)(pipeline_set_dep_slots(dar, dmod));
    (void)(driver_dep_seed_slots(dar, dmod, n_deps));
    (void)(codegen_set_dep_slots_for_x_pipeline(dmod, dpath, n_deps));
    (void)(codegen_set_preamble_has_core_option_result(1));
    (void)(driver_parsed_apply_preamble_skip(dpath, n_deps));
    (void)(memset(arena, 0, asz));
    (void)(memset(module, 0, msz));
    (void)(parser_parse_into_init(module, arena));
    (void)(driver_pipeline_dep_ctx_set_entry_already_parsed(pctx, 0));
    (void)((core_only = 0));
    if ((n_deps > 0)) {
      (void)((core_only = driver_deps_are_std_core_closure_only(dpath, n_deps)));
    }
  }
  if ((n_deps > 0)) {
    if ((check ==0)) {
      if ((want_asm !=0)) {
        if ((core_only !=0)) {
          {
            (void)(driver_pipeline_dep_ctx_set_asm_entry_module_only(pctx, 1));
          }
        }
      }
    }
  }
  if ((check !=0)) {
    if ((n_deps > 0)) {
      if ((core_only !=0)) {
        {
          (void)(driver_print_check_ok(path));
        }
        return 2;
      }
    }
  }
  {
    (void)((ec = shux_pipeline_run_x_pipeline_large_stack(module, arena, src, src_len, out_buf, pctx)));
    (void)(driver_x_pipeline_skip_typeck_set(0));
    (void)(driver_dep_seeded_clear_all());
    (void)(codegen_set_dep_slots_for_x_pipeline(((uint8_t *)(0)), ((uint8_t *)(0)), 0));
    (void)((out_len = driver_codegen_outbuf_len(out_buf)));
  }
  if ((ec !=0)) {
    (void)(rt_cp_diag(path, 3, 3, 9));
    return 1;
  }
  if ((check ==0)) {
    if ((out_len ==0)) {
      (void)(rt_cp_diag(path, 3, 3, 9));
      return 1;
    }
  }
  if ((check !=0)) {
    {
      (void)(driver_print_check_ok(path));
    }
    return 2;
  }
  return 0;
}
int32_t rt_cp_step_finish(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * module = ((uint8_t *)(0));
  uint8_t * out_buf = ((uint8_t *)(0));
  uint8_t * out_data = ((uint8_t *)(0));
  int32_t out_len = 0;
  uint8_t * cf = ((uint8_t *)(0));
  uint8_t * tmpc = ((uint8_t *)(0));
  uint8_t * outp = ((uint8_t *)(0));
  uint8_t * opt = ((uint8_t *)(0));
  uint8_t * argv = ((uint8_t *)(0));
  uint8_t * argv0 = ((uint8_t *)(0));
  int32_t use_lto = 0;
  int32_t emit_stdout = 0;
  int32_t rc = 0;
  {
    (void)((path = driver_parsed_work_p_get(pp_path())));
    (void)((module = driver_parsed_work_p_get(pp_module())));
    (void)((out_buf = driver_parsed_work_p_get(pp_out())));
    (void)((out_len = driver_codegen_outbuf_len(out_buf)));
    (void)((out_data = driver_codegen_outbuf_data(out_buf)));
    (void)((cf = driver_parsed_work_p_get(pp_cf())));
    (void)((tmpc = driver_parsed_work_p_get(pp_tmpc())));
    (void)((outp = driver_parsed_work_p_get(pp_out_path())));
    (void)((opt = driver_parsed_work_p_get(pp_opt())));
    (void)((argv = driver_parsed_work_p_get(pp_argv())));
    (void)((use_lto = driver_parsed_work_i_get(pi_use_lto())));
    (void)((emit_stdout = driver_parsed_work_i_get(pi_emit_stdout())));
  }
  if ((emit_stdout !=0)) {
    {
      (void)(driver_print_x_smoke_summary(module, ((size_t)(out_len))));
    }
  }
  {
    (void)(free(driver_parsed_work_p_get(pp_arena())));
    (void)(free(driver_parsed_work_p_get(pp_module())));
    (void)(free(driver_parsed_work_p_get(pp_src())));
    (void)(driver_parsed_work_p_set(pp_arena(), ((uint8_t *)(0))));
    (void)(driver_parsed_work_p_set(pp_module(), ((uint8_t *)(0))));
    (void)(driver_parsed_work_p_set(pp_src(), ((uint8_t *)(0))));
    (void)((rc = driver_parsed_write_out(cf, out_data, out_len)));
  }
  if ((rc !=0)) {
    return 1;
  }
  if ((emit_stdout !=0)) {
    return 0;
  }
  {
    (void)((rc = driver_parsed_fclose_rc(cf)));
    (void)(driver_parsed_work_p_set(pp_cf(), ((uint8_t *)(0))));
  }
  if ((rc !=0)) {
    if ((tmpc !=((uint8_t *)(0)))) {
      {
        (void)(unlink(tmpc));
      }
    }
    return 1;
  }
  {
    (void)((argv0 = driver_asm_argv0(argv)));
    (void)((rc = driver_parsed_invoke_cc(tmpc, outp, opt, use_lto, argv0)));
    if ((rc ==0)) {
      (void)(driver_parsed_work_p_set(pp_tmpc(), ((uint8_t *)(0))));
      (void)(free(tmpc));
    }
  }
  return rc;
}
int32_t driver_run_compiler_parsed(uint8_t * p, int32_t argc, uint8_t * argv) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * outp = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  int32_t want_asm = 0;
  uint8_t * target = ((uint8_t *)(0));
  uint8_t * opt = ((uint8_t *)(0));
  int32_t use_lto = 0;
  int32_t ndef = 0;
  uint8_t * defs = ((uint8_t *)(0));
  uint8_t * k = ((uint8_t *)(0));
  uint8_t * c = ((uint8_t *)(0));
  uint8_t * m = ((uint8_t *)(0));
  int32_t rc = 0;
  int32_t plen = 0;
  int32_t want_exe = 0;
  if ((p ==((uint8_t *)(0)))) {
    return 1;
  }
  {
    (void)(driver_bump_stack_limit());
    (void)((path = driver_parsed_input_path(p)));
    (void)((outp = driver_parsed_out_path(p)));
    (void)((lib = driver_parsed_lib_roots(p)));
    (void)((nlib = driver_parsed_n_lib_roots(p)));
    (void)((want_asm = driver_parsed_want_asm(p)));
    (void)((target = driver_parsed_target(p)));
    (void)((opt = driver_parsed_opt_level(p)));
    (void)((use_lto = driver_parsed_use_lto(p)));
  }
  if ((path ==((uint8_t *)(0)))) {
    return 1;
  }
  {
    if ((driver_check_only_get() !=0)) {
      (void)((want_asm = 0));
    }
  }
  if ((want_asm !=0)) {
    (void)((want_exe = 1));
    if ((outp !=((uint8_t *)(0)))) {
      {
        (void)((want_exe = shux_output_want_exe(outp)));
      }
    }
    if ((want_exe !=0)) {
      {
        (void)((plen = ((int32_t)(strlen(path)))));
      }
      if ((plen > 0)) {
        if ((plen < 512)) {
          {
            if ((driver_source_has_generic_syntax(path, plen) !=0)) {
              (void)((want_asm = 0));
            }
          }
        }
      }
    }
  }
  if ((want_asm !=0)) {
    {
      (void)((lib = driver_asm_bind_lib_roots(lib, nlib, &(nlib))));
      return driver_run_asm_backend(path, outp, lib, nlib, target, argc, argv);
    }
  }
  {
    (void)(driver_parsed_work_reset());
    (void)(driver_parsed_work_p_set(pp_path(), path));
    (void)(driver_parsed_work_p_set(pp_out_path(), outp));
    (void)(driver_parsed_work_p_set(pp_target(), target));
    (void)(driver_parsed_work_p_set(pp_argv(), argv));
    (void)(driver_parsed_work_p_set(pp_opt(), opt));
    (void)(driver_parsed_work_i_set(pi_use_lto(), use_lto));
    (void)(driver_parsed_work_i_set(pi_argc(), argc));
    (void)(driver_parsed_work_i_set(pi_want_asm(), want_asm));
    (void)((lib = driver_asm_bind_lib_roots(lib, nlib, &(nlib))));
    (void)(driver_parsed_work_p_set(pp_lib(), lib));
    (void)(driver_parsed_work_i_set(pi_nlib(), nlib));
    (void)((ndef = driver_asm_collect_defines(argc, argv)));
    (void)((defs = driver_asm_defines_as_u8()));
    (void)(driver_parsed_work_i_set(pi_ndef(), ndef));
    (void)(driver_parsed_work_p_set(pp_defs(), defs));
    (void)((k = malloc(((size_t)(32)))));
    (void)((c = malloc(((size_t)(16)))));
    (void)((m = malloc(((size_t)(64)))));
  }
  if ((k ==((uint8_t *)(0)))) {
    return 1;
  }
  if ((c ==((uint8_t *)(0)))) {
    {
      (void)(free(k));
    }
    return 1;
  }
  if ((m ==((uint8_t *)(0)))) {
    {
      (void)(free(k));
      (void)(free(c));
    }
    return 1;
  }
  {
    (void)(driver_parsed_work_p_set(pp_kind(), k));
    (void)(driver_parsed_work_p_set(pp_code(), c));
    (void)(driver_parsed_work_p_set(pp_msg(), m));
    (void)((rc = rt_cp_step_read_pp()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_cp_step_try_c()));
  }
  if ((rc ==2)) {
    {
      (void)((rc = driver_parsed_work_i_get(pi_ec())));
      (void)(driver_parsed_work_cleanup());
    }
    return rc;
  }
  if ((rc !=0)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_cp_step_parse()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_cp_step_load_deps()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_cp_step_open_out()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_cp_step_prerun()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_cp_step_pipeline()));
  }
  if ((rc ==2)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 0;
  }
  if ((rc !=0)) {
    {
      (void)(driver_parsed_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_cp_step_finish()));
    (void)(driver_parsed_work_cleanup());
  }
  return rc;
}
