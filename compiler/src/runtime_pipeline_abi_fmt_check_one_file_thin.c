/* Host-gcc twin of check_one_file (fmt_check_cmd_thin.x).
 * typool first-wins W check_one_file 0x14024b220 (fromsrc_s77) compiles
 * `view[z] = 0` and `snap[si] = 0` (`let view: u8[32]`, `let snap: u8[32]`)
 * as scale-8 qword stores through &view / &snap:
 *   lea rax,[rbp-0x30]; lea rax,[rax+rbx*8]; mov QWORD PTR [rbx],rax
 * Writer RIP typool 0x14024b377 (view[z]=0). GDB: entered from typool
 * driver_run_compiler_check + 1897 (caller return RIP 0x140251b01) with
 * the real abs path in g_fmt_file_list_paths; at z=5 stored 0 over
 * saved rbx, at z=6 stored 0 over saved rbp, at z=7 stored 0 over the
 * return address. typool check_one_file then continued; later typool
 * snap[si]=0 at writer 0x14024bb5f is the same typool-wrong (si=17
 * would smash the already-zero retaddr from [rbp-0x80]). Epilogue ret
 * 0x14024c1a6 jumped to 0 (first-chance RIP=0, rsp past the smashed
 * frame). Same-class typool u8[N] scale-8 stores live in this face
 * (view and snap); host-gcc twin indexes u8 directly. docs-only .x,
 * do not idx8. Do not JMP typool rec T 0x140087de4. Do not fold typool
 * diag_io_fputc / runtime_read_file_malloc / pp_path in this thin. */
#include <stdint.h>
#include <string.h>

extern int32_t runtime_read_file_view(uint8_t *path, uint8_t *out);
extern void runtime_release_file_view(uint8_t *view);
extern uint8_t *xlang_ptr_slot_get(uint8_t *arr, int32_t i);
extern void xlang_ptr_slot_set(uint8_t *arr, int32_t i, uint8_t *p);
extern void diag_set_file(uint8_t *path, uint8_t *source, int64_t source_len);
extern void diag_push_file(uint8_t *snapshot, uint8_t *path, uint8_t *source, int64_t source_len);
extern void diag_restore(uint8_t *snapshot);
extern void lsp_diag_collect_begin(void);
extern void lsp_diag_collect_end(void);
extern int32_t lsp_diag_count_severity(int32_t severity);
extern int32_t lsp_diag_print_stderr_human(uint8_t *path);
extern void driver_check_diag_emitted_reset(void);
extern int32_t driver_check_diag_emitted_get(void);
extern void driver_check_only_set(int32_t v);
extern void driver_check_set_current_file(uint8_t *path);
extern void fmt_check_lib_bufs_reset(void);
extern int32_t fmt_check_invoke_compile(int32_t argc, uint8_t *check_argv);
extern void fmt_check_dep_clear(void);
extern void check_argv_append_default_libs_for_path(uint8_t *path, uint8_t *check_argv, int32_t *n);
extern void check_progress_break(void);
extern void check_progress_resume(void);
extern int32_t check_one_need_fallback_diag(int32_t rc, int32_t nd, int32_t nd_errors, int32_t nd_warnings, int32_t nd_infos, int32_t direct_diag);
extern int32_t check_one_finalize_rc(int32_t rc, int32_t warn_count);
extern void check_stats_add_file(int32_t rc, int32_t n_errors, int32_t n_warnings);
extern void diag_report_with_code(uint8_t *file, int32_t line, int32_t col, uint8_t *kind, uint8_t *code, uint8_t *msg, uint8_t *detail);

static uint8_t g_fmt_lit_check_error[12] = {99, 104, 101, 99, 107, 32, 101, 114, 114, 111, 114, 0};
static uint8_t g_fmt_lit_chk001[7] = {67, 72, 75, 48, 48, 49, 0};
static uint8_t g_fmt_lit_check_failed_prefix[15] = {99, 104, 101, 99, 107, 32, 102, 97, 105, 108, 101, 100, 58, 32, 0};
static uint8_t g_fmt_lit_dash_L[3] = {45, 76, 0};
static uint8_t g_fmt_lit_cmd_check[6] = {99, 104, 101, 99, 107, 0};
static uint8_t g_fmt_lit_fail_fast[12] = {45, 45, 102, 97, 105, 108, 45, 102, 97, 115, 116, 0};
static uint8_t g_fmt_lit_dash_I[3] = {45, 73, 0};
static uint8_t g_fmt_lit_dash_o[3] = {45, 111, 0};
static uint8_t g_fmt_lit_dash_O[3] = {45, 79, 0};
static uint8_t g_fmt_lit_backend[9] = {45, 98, 97, 99, 107, 101, 110, 100, 0};

int32_t check_one_file(uint8_t *path, int32_t argc, uint8_t *argv) {
  uint8_t view[32];
  int32_t z;
  int32_t have_diag_view;
  uint8_t *view_data;
  int64_t view_len;
  uint8_t *len_bits;
  uint8_t check_argv[512];
  int32_t n;
  uint8_t *a0;
  int32_t i;
  uint8_t *ai;
  int32_t take_val;
  uint8_t *av;
  int32_t rc;
  uint8_t snap[32];
  int32_t si;
  int32_t nd_errors;
  int32_t nd_warnings;
  int32_t nd_infos;
  int32_t progress_broke;
  int32_t nd;
  int32_t direct_diag;
  int32_t used_fallback;
  uint8_t msg[600];
  int32_t at;
  uint8_t *pfx;
  int32_t pi;
  int32_t qi;
  uint8_t c;
  int32_t err_total;

  if (path == 0)
    return 0 - 1;
  if (argv == 0)
    return 0 - 1;
  if (argc <= 0)
    return 0 - 1;

  z = 0;
  while (z < 32) {
    view[z] = 0;
    z = z + 1;
  }
  have_diag_view = 0;
  view_data = 0;
  view_len = 0;
  if (runtime_read_file_view(path, &view[0]) == 0) {
    view_data = xlang_ptr_slot_get(&view[0], 0);
    len_bits = xlang_ptr_slot_get(&view[0], 1);
    view_len = (int64_t)(intptr_t)len_bits;
    diag_set_file(path, view_data, view_len);
    have_diag_view = 1;
  } else {
    diag_set_file(path, 0, 0);
  }
  lsp_diag_collect_begin();
  driver_check_diag_emitted_reset();
  driver_check_set_current_file(path);
  fmt_check_lib_bufs_reset();

  n = 0;
  while (n < 512) {
    check_argv[n] = 0;
    n = n + 1;
  }
  n = 0;
  a0 = xlang_ptr_slot_get(argv, 0);
  xlang_ptr_slot_set(&check_argv[0], 0, a0);
  n = 1;
  xlang_ptr_slot_set(&check_argv[0], n, &g_fmt_lit_cmd_check[0]);
  n = n + 1;
  i = 2;
  while (i < argc) {
    if (n >= 60)
      break;
    ai = xlang_ptr_slot_get(argv, i);
    if (ai != 0) {
      if (ai[0] == 45) {
        xlang_ptr_slot_set(&check_argv[0], n, ai);
        n = n + 1;
        take_val = 0;
        if (strcmp((char *)ai, (char *)&g_fmt_lit_dash_L[0]) == 0) {
          take_val = 1;
        } else if (strcmp((char *)ai, (char *)&g_fmt_lit_dash_I[0]) == 0) {
          take_val = 1;
        } else if (strcmp((char *)ai, (char *)&g_fmt_lit_dash_o[0]) == 0) {
          take_val = 1;
        } else if (strcmp((char *)ai, (char *)&g_fmt_lit_backend[0]) == 0) {
          take_val = 1;
        } else if (strcmp((char *)ai, (char *)&g_fmt_lit_dash_O[0]) == 0) {
          take_val = 1;
        }
        if (take_val != 0) {
          if ((i + 1) < argc) {
            if (n < 60) {
              i = i + 1;
              av = xlang_ptr_slot_get(argv, i);
              xlang_ptr_slot_set(&check_argv[0], n, av);
              n = n + 1;
            }
          }
        }
      } else {
        if (strcmp((char *)ai, (char *)&g_fmt_lit_fail_fast[0]) == 0) {
          xlang_ptr_slot_set(&check_argv[0], n, ai);
          n = n + 1;
        }
      }
    }
    i = i + 1;
  }
  check_argv_append_default_libs_for_path(path, &check_argv[0], &n);
  if (n < 64) {
    xlang_ptr_slot_set(&check_argv[0], n, path);
    n = n + 1;
  }

  driver_check_only_set(1);
  rc = fmt_check_invoke_compile(n, &check_argv[0]);
  driver_check_only_set(0);

  si = 0;
  while (si < 32) {
    snap[si] = 0;
    si = si + 1;
  }
  if (have_diag_view != 0) {
    diag_push_file(&snap[0], path, view_data, view_len);
  } else {
    diag_push_file(&snap[0], path, 0, 0);
  }
  nd_errors = lsp_diag_count_severity(1);
  nd_warnings = lsp_diag_count_severity(2);
  nd_infos = lsp_diag_count_severity(3);
  progress_broke = 0;
  if ((nd_errors + nd_warnings + nd_infos) > 0) {
    check_progress_break();
    progress_broke = 1;
  }
  nd = lsp_diag_print_stderr_human(path);
  direct_diag = driver_check_diag_emitted_get();
  diag_restore(&snap[0]);
  used_fallback = 0;
  if (check_one_need_fallback_diag(rc, nd, nd_errors, nd_warnings, nd_infos, direct_diag) != 0) {
    check_progress_break();
    progress_broke = 1;
    at = 0;
    pfx = &g_fmt_lit_check_failed_prefix[0];
    pi = 0;
    while (pi < 14) {
      msg[at] = pfx[pi];
      at = at + 1;
      pi = pi + 1;
    }
    qi = 0;
    while (qi < 512) {
      c = path[qi];
      if (c == 0)
        break;
      if (at >= 598)
        break;
      msg[at] = c;
      at = at + 1;
      qi = qi + 1;
    }
    msg[at] = 0;
    diag_report_with_code(path, 0, 0, &g_fmt_lit_check_error[0], &g_fmt_lit_chk001[0], &msg[0], 0);
    used_fallback = 1;
  }
  if (nd_errors > 0) {
    rc = 1;
  }
  rc = check_one_finalize_rc(rc, nd_warnings);

  err_total = nd_errors;
  if (used_fallback != 0) {
    err_total = err_total + 1;
  }
  check_stats_add_file(rc, err_total, nd_warnings);
  if (progress_broke != 0) {
    check_progress_resume();
  }

  lsp_diag_collect_end();
  if (have_diag_view != 0) {
    runtime_release_file_view(&view[0]);
  }
  fmt_check_dep_clear();
  return rc;
}
