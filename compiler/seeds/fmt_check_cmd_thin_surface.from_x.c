/* regen from fmt_check_cmd_thin.x -E (path_resolve_abs pure + path BSS slot) */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif

extern int32_t driver_check_quiet_ok_get(void);
extern int32_t fmt_walk_skip_dot_name(uint8_t * name);
extern int32_t check_one_need_fallback_diag(int32_t rc, int32_t nd, int32_t nd_errors, int32_t nd_warnings, int32_t nd_infos, int32_t direct_diag);
extern int32_t shux_path_is_absolute(uint8_t * path);
extern int32_t check_one_finalize_rc(int32_t rc, int32_t warn_count);
extern uint8_t * driver_fmt_check_lit_check_error(void);
extern uint8_t * driver_fmt_check_lit_fmt_error(void);
extern uint8_t * driver_fmt_check_lit_chk002(void);
extern uint8_t * driver_fmt_check_lit_fmt001(void);
extern uint8_t * driver_collect_error_kind(void);
extern uint8_t * driver_collect_missing_path_code(void);
extern uint8_t * fmt_builtin_ignore_at(int32_t i);
extern uint8_t * fmt_default_product_sub_at(int32_t i);
extern uint8_t * fmt_user_ignore_at(int32_t i);
extern uint8_t * fmt_path_resolve_abs(uint8_t * path);
extern int32_t driver_collect_mode_is_check(void);
extern int32_t check_user_passed_L_get(void);
extern int32_t fmt_user_ignore_count(void);
extern int32_t fmt_path_ends_with_dot_x(uint8_t * path);
extern int32_t fmt_file_list_n(void);
extern int32_t check_lint_fail_on_warnings(void);
extern int32_t fmt_check_invoke_compile(int32_t argc, uint8_t * check_argv);
extern void fmt_check_dep_clear(void);
extern int32_t fmt_path_stat_kind(uint8_t * path);
extern void check_try_append_lib_root(uint8_t * check_argv, int32_t * n, uint8_t * dir);
extern void check_init_user_lib_flags(int32_t argc, uint8_t * argv, int32_t path_start);
extern void driver_check_set_current_file(uint8_t * path);
extern int32_t driver_check_print_collected_diagnostics(uint8_t * path);
extern int32_t check_one_file(uint8_t * path, int32_t argc, uint8_t * argv);
extern int32_t path_should_ignore(uint8_t * path);
extern int32_t file_list_push(uint8_t * path);
extern void walk_dir_collect_process_child(uint8_t * child, int32_t is_dir, int32_t is_reg);
extern void walk_dir_collect(uint8_t * dir);
extern void parse_ignore_opt(uint8_t * arg);
extern void file_list_clear(void);
extern int32_t fmt_try_walk_if_product_subdir(uint8_t * sub);
extern void fmt_walk_cwd_fallback(void);
extern void check_collect_default_product_dirs(void);
extern void collect_paths_from_arg(uint8_t * arg);
extern void check_append_repo_lib_roots(uint8_t * path, uint8_t * check_argv, int32_t * n);
extern void check_argv_append_default_libs_for_path(uint8_t * path, uint8_t * check_argv, int32_t * n);
extern int32_t driver_run_fmt(int32_t argc, uint8_t * argv);
extern int32_t driver_run_compiler_check(int32_t argc, uint8_t * argv);
static uint8_t * g_fmt_lit_check_error;
static uint8_t * g_fmt_lit_fmt_error;
static uint8_t * g_fmt_lit_chk002;
static uint8_t * g_fmt_lit_fmt001;
static uint8_t * g_fmt_builtin_ignore_0;
static uint8_t * g_fmt_builtin_ignore_1;
static uint8_t * g_fmt_builtin_ignore_2;
static uint8_t * g_fmt_builtin_ignore_3;
static uint8_t * g_fmt_builtin_ignore_4;
static uint8_t * g_fmt_builtin_ignore_5;
static uint8_t * g_fmt_builtin_ignore_6;
static uint8_t * g_fmt_builtin_ignore_7;
static uint8_t * g_fmt_default_product_sub_0;
static uint8_t * g_fmt_default_product_sub_1;
static uint8_t * g_fmt_default_product_sub_2;
static uint8_t * g_fmt_default_product_sub_3;
static void init_globals(void) {
  g_fmt_lit_check_error = (uint8_t[]){99, 104, 101, 99, 107, 32, 101, 114, 114, 111, 114, 0 };
  g_fmt_lit_fmt_error = (uint8_t[]){102, 109, 116, 32, 101, 114, 114, 111, 114, 0 };
  g_fmt_lit_chk002 = (uint8_t[]){67, 72, 75, 48, 48, 50, 0 };
  g_fmt_lit_fmt001 = (uint8_t[]){70, 77, 84, 48, 48, 49, 0 };
  g_fmt_builtin_ignore_0 = (uint8_t[]){47, 46, 103, 105, 116, 47, 0, 0 };
  g_fmt_builtin_ignore_1 = (uint8_t[]){47, 98, 117, 105, 108, 100, 95, 97, 115, 109, 47, 0 };
  g_fmt_builtin_ignore_2 = (uint8_t[]){47, 98, 117, 105, 108, 100, 47, 0 };
  g_fmt_builtin_ignore_3 = (uint8_t[]){47, 110, 111, 100, 101, 95, 109, 111, 100, 117, 108, 101, 115, 47, 0 };
  g_fmt_builtin_ignore_4 = (uint8_t[]){47, 46, 99, 117, 114, 115, 111, 114, 47, 0, 0 };
  g_fmt_builtin_ignore_5 = (uint8_t[]){47, 99, 111, 109, 112, 105, 108, 101, 114, 47, 98, 117, 105, 108, 100, 95, 97, 115, 109, 47, 0 };
  g_fmt_builtin_ignore_6 = (uint8_t[]){47, 99, 111, 109, 112, 105, 108, 101, 114, 47, 98, 117, 105, 108, 100, 47, 0 };
  g_fmt_builtin_ignore_7 = (uint8_t[]){47, 99, 111, 109, 112, 105, 108, 101, 114, 47, 116, 101, 115, 116, 115, 47, 0 };
  g_fmt_default_product_sub_0 = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 115, 114, 99, 0 };
  g_fmt_default_product_sub_1 = (uint8_t[]){99, 111, 114, 101, 0 };
  g_fmt_default_product_sub_2 = (uint8_t[]){115, 116, 100, 0 };
  g_fmt_default_product_sub_3 = (uint8_t[]){101, 120, 97, 109, 112, 108, 101, 115, 0 };
}
extern int32_t lsp_diag_print_stderr_human(uint8_t * path);
extern int32_t driver_run_compiler_full(int32_t argc, uint8_t * argv);
extern void driver_dep_seeded_clear_all(void);
extern int32_t driver_collect_mode_is_check_impl(void);
extern int32_t check_user_passed_L_get_impl(void);
extern int32_t fmt_user_ignore_count_impl(void);
extern int32_t fmt_file_list_n_impl(void);
extern uint8_t * fmt_user_ignore_at_impl(int32_t i);
extern int32_t fmt_file_list_store_impl(uint8_t * abs_path);
extern uint8_t * fmt_check_path_bss_slot(int32_t which);
int32_t driver_check_quiet_ok_get(void) {
  return 1;
}
int32_t fmt_walk_skip_dot_name(uint8_t * name) {
  if ((name ==((uint8_t *)(0)))) {
    return 1;
  }
  if (((name)[0] ==0)) {
    return 1;
  }
  if (((name)[0] ==46)) {
    return 1;
  }
  return 0;
}
int32_t check_one_need_fallback_diag(int32_t rc, int32_t nd, int32_t nd_errors, int32_t nd_warnings, int32_t nd_infos, int32_t direct_diag) {
  if ((rc ==0)) {
    return 0;
  }
  if ((direct_diag !=0)) {
    return 0;
  }
  if ((nd ==0)) {
    return 1;
  }
  if ((nd_errors !=0)) {
    return 0;
  }
  if ((nd_warnings !=0)) {
    return 0;
  }
  if ((nd_infos !=0)) {
    return 0;
  }
  return 1;
}
int32_t shux_path_is_absolute(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  if (((path)[0] ==47)) {
    return 1;
  }
  if (((path)[1] ==0)) {
    return 0;
  }
  if (((path)[1] !=58)) {
    return 0;
  }
  if (((path)[0] < 65)) {
    return 0;
  }
  if (((path)[0] <=90)) {
    return 1;
  }
  if (((path)[0] < 97)) {
    return 0;
  }
  if (((path)[0] <=122)) {
    return 1;
  }
  return 0;
}
int32_t check_one_finalize_rc(int32_t rc, int32_t warn_count) {
  if ((rc !=0)) {
    return rc;
  }
  if ((warn_count <=0)) {
    return 0;
  }
  if ((check_lint_fail_on_warnings() !=0)) {
    return 1;
  }
  return 0;
}
uint8_t * driver_fmt_check_lit_check_error(void) {
  return &((g_fmt_lit_check_error)[0]);
}
uint8_t * driver_fmt_check_lit_fmt_error(void) {
  return &((g_fmt_lit_fmt_error)[0]);
}
uint8_t * driver_fmt_check_lit_chk002(void) {
  return &((g_fmt_lit_chk002)[0]);
}
uint8_t * driver_fmt_check_lit_fmt001(void) {
  return &((g_fmt_lit_fmt001)[0]);
}
uint8_t * driver_collect_error_kind(void) {
  {
    if ((driver_collect_mode_is_check_impl() !=0)) {
      return &((g_fmt_lit_check_error)[0]);
    }
  }
  return &((g_fmt_lit_fmt_error)[0]);
}
uint8_t * driver_collect_missing_path_code(void) {
  {
    if ((driver_collect_mode_is_check_impl() !=0)) {
      return &((g_fmt_lit_chk002)[0]);
    }
  }
  return &((g_fmt_lit_fmt001)[0]);
}
uint8_t * fmt_builtin_ignore_at(int32_t i) {
  if ((i ==0)) {
    return &((g_fmt_builtin_ignore_0)[0]);
  }
  if ((i ==1)) {
    return &((g_fmt_builtin_ignore_1)[0]);
  }
  if ((i ==2)) {
    return &((g_fmt_builtin_ignore_2)[0]);
  }
  if ((i ==3)) {
    return &((g_fmt_builtin_ignore_3)[0]);
  }
  if ((i ==4)) {
    return &((g_fmt_builtin_ignore_4)[0]);
  }
  if ((i ==5)) {
    return &((g_fmt_builtin_ignore_5)[0]);
  }
  if ((i ==6)) {
    return &((g_fmt_builtin_ignore_6)[0]);
  }
  if ((i ==7)) {
    return &((g_fmt_builtin_ignore_7)[0]);
  }
  return ((uint8_t *)(0));
}
uint8_t * fmt_default_product_sub_at(int32_t i) {
  if ((i ==0)) {
    return &((g_fmt_default_product_sub_0)[0]);
  }
  if ((i ==1)) {
    return &((g_fmt_default_product_sub_1)[0]);
  }
  if ((i ==2)) {
    return &((g_fmt_default_product_sub_2)[0]);
  }
  if ((i ==3)) {
    return &((g_fmt_default_product_sub_3)[0]);
  }
  return ((uint8_t *)(0));
}
uint8_t * fmt_user_ignore_at(int32_t i) {
  {
    return fmt_user_ignore_at_impl(i);
  }
  return ((uint8_t *)(0));
}
uint8_t * fmt_path_resolve_abs(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  {
    uint8_t * buf = fmt_check_path_bss_slot(1);
    if ((buf ==((uint8_t *)(0)))) {
      return ((uint8_t *)(0));
    }
    if ((shux_path_is_absolute(path) !=0)) {
      int32_t i = 0;
      while ((i < 511)) {
        uint8_t c = (path)[i];
        (void)(((buf)[i] = c));
        if ((c ==0)) {
          return buf;
        }
        (void)((i = (i + 1)));
      }
      (void)(((buf)[511] = 0));
      return buf;
    }
    uint8_t * p = getcwd(buf, 512);
    if ((p ==((uint8_t *)(0)))) {
      return ((uint8_t *)(0));
    }
    int32_t n = 0;
    while ((n < 511)) {
      if (((buf)[n] ==0)) {
        break;
      }
      (void)((n = (n + 1)));
    }
    int32_t plen = 0;
    while ((plen < 512)) {
      if (((path)[plen] ==0)) {
        break;
      }
      (void)((plen = (plen + 1)));
    }
    if ((((n + 1) + plen) >=512)) {
      return ((uint8_t *)(0));
    }
    (void)(((buf)[n] = 47));
    (void)((n = (n + 1)));
    int32_t j = 0;
    while ((j <=plen)) {
      uint8_t c2 = (path)[j];
      (void)(((buf)[(n + j)] = c2));
      if ((c2 ==0)) {
        break;
      }
      (void)((j = (j + 1)));
    }
    return buf;
  }
  return ((uint8_t *)(0));
}
int32_t driver_collect_mode_is_check(void) {
  {
    return driver_collect_mode_is_check_impl();
  }
  return 0;
}
int32_t check_user_passed_L_get(void) {
  {
    return check_user_passed_L_get_impl();
  }
  return 0;
}
int32_t fmt_user_ignore_count(void) {
  {
    return fmt_user_ignore_count_impl();
  }
  return 0;
}
int32_t fmt_path_ends_with_dot_x(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  {
    int32_t i = 0;
    while ((i < 4096)) {
      if (((path)[i] ==0)) {
        if ((i < 2)) {
          return 0;
        }
        if (((path)[(i - 2)] ==46)) {
          if (((path)[(i - 1)] ==120)) {
            return 1;
          }
        }
        return 0;
      }
      (void)((i = (i + 1)));
    }
  }
  return 0;
}
int32_t fmt_file_list_n(void) {
  {
    return fmt_file_list_n_impl();
  }
  return 0;
}
extern int32_t fmt_path_stat_kind_impl(uint8_t * path);
int32_t check_lint_fail_on_warnings(void) {
  {
    uint8_t * v = getenv((uint8_t[]){83, 72, 85, 88, 95, 76, 73, 78, 84, 95, 67, 73, 95, 70, 65, 73, 76, 95, 79, 78, 0 });
    if ((v ==((uint8_t *)(0)))) {
      return 0;
    }
    if (((v)[0] ==119)) {
      if (((v)[1] ==97)) {
        if (((v)[2] ==114)) {
          if (((v)[3] ==110)) {
            if (((v)[4] ==0)) {
              return 1;
            }
            if (((v)[4] ==105)) {
              if (((v)[5] ==110)) {
                if (((v)[6] ==103)) {
                  if (((v)[7] ==0)) {
                    return 1;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return 0;
}
int32_t fmt_check_invoke_compile(int32_t argc, uint8_t * check_argv) {
  {
    return driver_run_compiler_full(argc, check_argv);
  }
  return 0;
}
void fmt_check_dep_clear(void) {
  {
    (void)(driver_dep_seeded_clear_all());
  }
  (void)(0);
  return;
}
int32_t fmt_path_stat_kind(uint8_t * path) {
  {
    return fmt_path_stat_kind_impl(path);
  }
  return (0 - 1);
}
extern void check_try_append_lib_root_impl(uint8_t * check_argv, int32_t * n, uint8_t * dir);
extern void check_init_user_lib_flags_impl(int32_t argc, uint8_t * argv, int32_t path_start);
extern int32_t check_one_file_body_impl(uint8_t * path, int32_t argc, uint8_t * argv);
void check_try_append_lib_root(uint8_t * check_argv, int32_t * n, uint8_t * dir) {
  if ((check_argv ==((uint8_t *)(0)))) {
    return;
  }
  if ((n ==((int32_t *)(0)))) {
    return;
  }
  if ((dir ==((uint8_t *)(0)))) {
    return;
  }
  if (((dir)[0] ==0)) {
    return;
  }
  if ((check_user_passed_L_get() !=0)) {
    return;
  }
  {
    if (((n)[0] >=58)) {
      return;
    }
    (void)(check_try_append_lib_root_impl(check_argv, n, dir));
  }
  (void)(0);
  return;
}
void check_init_user_lib_flags(int32_t argc, uint8_t * argv, int32_t path_start) {
  {
    (void)(check_init_user_lib_flags_impl(argc, argv, path_start));
  }
  (void)(0);
  return;
}
void driver_check_set_current_file(uint8_t * path) {
  {
    uint8_t * buf = fmt_check_path_bss_slot(0);
    if ((buf ==((uint8_t *)(0)))) {
      return;
    }
    if ((path ==((uint8_t *)(0)))) {
      (void)(((buf)[0] = 0));
      return;
    }
    int32_t i = 0;
    while ((i < 511)) {
      uint8_t c = (path)[i];
      (void)(((buf)[i] = c));
      if ((c ==0)) {
        return;
      }
      (void)((i = (i + 1)));
    }
    (void)(((buf)[511] = 0));
  }
  (void)(0);
  return;
}
int32_t driver_check_print_collected_diagnostics(uint8_t * path) {
  {
    uint8_t * buf = fmt_check_path_bss_slot(0);
    if ((path !=((uint8_t *)(0)))) {
      return lsp_diag_print_stderr_human(path);
    }
    if ((buf ==((uint8_t *)(0)))) {
      return 0;
    }
    return lsp_diag_print_stderr_human(buf);
  }
  return 0;
}
int32_t check_one_file(uint8_t * path, int32_t argc, uint8_t * argv) {
  if ((path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  if ((argv ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  if ((argc <=0)) {
    return (0 - 1);
  }
  {
    return check_one_file_body_impl(path, argc, argv);
  }
  return (0 - 1);
}
extern void walk_dir_collect_impl(uint8_t * dir);
extern void parse_ignore_opt_impl(uint8_t * arg);
extern void file_list_clear_impl(void);
int32_t path_should_ignore(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 1;
  }
  {
    int32_t i = 0;
    while ((i < 32)) {
      uint8_t * b = fmt_builtin_ignore_at(i);
      if ((b ==((uint8_t *)(0)))) {
        break;
      }
      if ((strstr(path, b) !=((uint8_t *)(0)))) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    int32_t n = fmt_user_ignore_count();
    int32_t j = 0;
    while ((j < n)) {
      uint8_t * u = fmt_user_ignore_at(j);
      if ((u !=((uint8_t *)(0)))) {
        if (((u)[0] !=0)) {
          if ((strstr(path, u) !=((uint8_t *)(0)))) {
            return 1;
          }
        }
      }
      (void)((j = (j + 1)));
    }
  }
  return 0;
}
int32_t file_list_push(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  {
    uint8_t * abs_path = fmt_path_resolve_abs(path);
    if ((fmt_file_list_n() >=8192)) {
      return (0 - 1);
    }
    if ((abs_path ==((uint8_t *)(0)))) {
      return (0 - 1);
    }
    if ((path_should_ignore(abs_path) !=0)) {
      return 0;
    }
    if ((fmt_path_ends_with_dot_x(abs_path) ==0)) {
      return 0;
    }
    return fmt_file_list_store_impl(abs_path);
  }
  return (0 - 1);
}
void walk_dir_collect_process_child(uint8_t * child, int32_t is_dir, int32_t is_reg) {
  if ((child ==((uint8_t *)(0)))) {
    return;
  }
  if ((path_should_ignore(child) !=0)) {
    return;
  }
  if ((is_dir !=0)) {
    (void)(walk_dir_collect(child));
    return;
  }
  if ((is_reg !=0)) {
    if ((fmt_path_ends_with_dot_x(child) !=0)) {
      (void)(file_list_push(child));
    }
  }
  (void)(0);
  return;
}
void walk_dir_collect(uint8_t * dir) {
  {
    (void)(walk_dir_collect_impl(dir));
  }
  (void)(0);
  return;
}
void parse_ignore_opt(uint8_t * arg) {
  if ((arg ==((uint8_t *)(0)))) {
    return;
  }
  if (((arg)[0] !=45)) {
    return;
  }
  if (((arg)[1] !=45)) {
    return;
  }
  if (((arg)[2] !=105)) {
    return;
  }
  if (((arg)[3] !=103)) {
    return;
  }
  if (((arg)[4] !=110)) {
    return;
  }
  if (((arg)[5] !=111)) {
    return;
  }
  if (((arg)[6] !=114)) {
    return;
  }
  if (((arg)[7] !=101)) {
    return;
  }
  if (((arg)[8] !=61)) {
    return;
  }
  {
    (void)(parse_ignore_opt_impl(arg));
  }
  (void)(0);
  return;
}
void file_list_clear(void) {
  {
    (void)(file_list_clear_impl());
  }
  (void)(0);
  return;
}
extern void collect_paths_missing_diag_impl(uint8_t * path);
extern void check_append_repo_lib_roots_impl(uint8_t * path, uint8_t * check_argv, int32_t * n);
extern void check_argv_append_default_libs_for_path_impl(uint8_t * path, uint8_t * check_argv, int32_t * n);
int32_t fmt_try_walk_if_product_subdir(uint8_t * sub) {
  if ((sub ==((uint8_t *)(0)))) {
    return 0;
  }
  {
    uint8_t cwd[512] = {};
    uint8_t * p = getcwd(&((cwd)[0]), 512);
    if ((p ==((uint8_t *)(0)))) {
      return 0;
    }
    uint8_t subp[560] = {};
    int32_t i = 0;
    while ((i < 511)) {
      uint8_t c = (cwd)[i];
      if ((c ==0)) {
        break;
      }
      (void)(((subp)[i] = c));
      (void)((i = (i + 1)));
    }
    if ((i >=559)) {
      return 0;
    }
    (void)(((subp)[i] = 47));
    (void)((i = (i + 1)));
    int32_t j = 0;
    while ((i < 559)) {
      uint8_t c2 = (sub)[j];
      (void)(((subp)[i] = c2));
      if ((c2 ==0)) {
        break;
      }
      (void)((i = (i + 1)));
      (void)((j = (j + 1)));
    }
    (void)(((subp)[559] = 0));
    if ((fmt_path_stat_kind(&((subp)[0])) ==1)) {
      (void)(walk_dir_collect(&((subp)[0])));
      return 1;
    }
  }
  return 0;
}
void fmt_walk_cwd_fallback(void) {
  {
    uint8_t cwd[512] = {};
    uint8_t * p = getcwd(&((cwd)[0]), 512);
    if ((p ==((uint8_t *)(0)))) {
      return;
    }
    (void)(walk_dir_collect(&((cwd)[0])));
  }
  (void)(0);
  return;
}
void check_collect_default_product_dirs(void) {
  {
    int32_t any_product = 0;
    int32_t i = 0;
    while ((i < 64)) {
      uint8_t * sub = fmt_default_product_sub_at(i);
      if ((sub ==((uint8_t *)(0)))) {
        break;
      }
      if ((fmt_try_walk_if_product_subdir(sub) !=0)) {
        (void)((any_product = 1));
      }
      (void)((i = (i + 1)));
    }
    if ((any_product ==0)) {
      (void)(fmt_walk_cwd_fallback());
    }
  }
  (void)(0);
  return;
}
void collect_paths_from_arg(uint8_t * arg) {
  if ((arg ==((uint8_t *)(0)))) {
    return;
  }
  {
    int32_t k = fmt_path_stat_kind(arg);
    if ((k < 0)) {
      (void)(collect_paths_missing_diag_impl(arg));
      return;
    }
    if ((k ==1)) {
      uint8_t * base = fmt_path_resolve_abs(arg);
      if ((base !=((uint8_t *)(0)))) {
        (void)(walk_dir_collect(base));
      }
      return;
    }
    (void)(file_list_push(arg));
  }
  (void)(0);
  return;
}
void check_append_repo_lib_roots(uint8_t * path, uint8_t * check_argv, int32_t * n) {
  {
    (void)(check_append_repo_lib_roots_impl(path, check_argv, n));
  }
  (void)(0);
  return;
}
void check_argv_append_default_libs_for_path(uint8_t * path, uint8_t * check_argv, int32_t * n) {
  {
    (void)(check_argv_append_default_libs_for_path_impl(path, check_argv, n));
  }
  (void)(0);
  return;
}
extern int32_t driver_run_fmt_impl(int32_t argc, uint8_t * argv);
extern int32_t driver_run_compiler_check_impl(int32_t argc, uint8_t * argv);
int32_t driver_run_fmt(int32_t argc, uint8_t * argv) {
  {
    return driver_run_fmt_impl(argc, argv);
  }
  return 0;
}
int32_t driver_run_compiler_check(int32_t argc, uint8_t * argv) {
  {
    return driver_run_compiler_check_impl(argc, argv);
  }
  return 0;
}
