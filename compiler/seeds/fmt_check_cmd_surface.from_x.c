/* seeds/fmt_check_cmd_surface.from_x.c
 * G-02f fmt_check_cmd R2 mixed surface - isomorphic with src/driver/fmt_check_cmd.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/fmt_check_cmd.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (25 #[no_mangle])
 * Mode: mixed - DIRECT compute + thin+rest forwards
 * Cap residual: 30 extern bridges (driver_/path_/fmt_/file_/check_/walk_/collect_/parse_)
 * No doc_anchor (fmt_check_cmd.x has none).
 * Note: driver_/path_/fmt_/file_/check_/walk_/collect_/parse_ prefix not trigger ast_.
 * Logic: 25 functions = DIRECT compute + thin+rest forwards.
 * Regen: ./xlang-c -E ... fmt_check_cmd.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
extern int32_t driver_check_quiet_ok_get(void);
extern uint8_t * driver_collect_error_kind(void);
extern uint8_t * driver_collect_missing_path_code(void);
extern int32_t path_should_ignore(uint8_t * path);
extern int32_t fmt_path_ends_with_dot_x(uint8_t * path);
extern int32_t file_list_push(uint8_t * path);
extern void file_list_clear(void);
extern void fmt_check_dep_clear(void);
extern void check_init_user_lib_flags(int32_t argc, uint8_t * argv, int32_t path_start);
extern void check_try_append_lib_root(uint8_t * check_argv, int32_t * n, uint8_t * dir);
extern void check_append_repo_lib_roots(uint8_t * check_argv, int32_t * n);
extern void check_argv_append_default_libs_for_path(uint8_t * path, uint8_t * check_argv, int32_t * n);
extern int32_t fmt_check_invoke_compile(uint8_t * path);
extern int32_t fmt_walk_skip_dot_name(uint8_t * name);
extern void walk_dir_collect_process_child(uint8_t * child, int32_t is_dir, int32_t is_reg);
extern void walk_dir_collect(uint8_t * dir);
extern void check_collect_default_product_dirs(void);
extern void collect_paths_from_arg(uint8_t * arg);
extern int32_t parse_ignore_opt(uint8_t * arg);
extern int32_t check_one_need_fallback_diag(int32_t rc, int32_t nd, int32_t nd_errors, int32_t nd_warnings, int32_t nd_infos, int32_t direct_diag);
extern int32_t check_one_finalize_rc(int32_t rc, int32_t warn_count);
extern int32_t check_one_file(uint8_t * path, int32_t argc, uint8_t * argv);
extern void closedir_win(uint8_t * d);
extern int32_t check_lint_fail_on_warnings(void);
extern int32_t xlang_path_is_absolute(uint8_t * path);
extern uint8_t * link_abi_getenv(uint8_t * name);
extern int32_t driver_collect_mode_is_check(void);
extern uint8_t * driver_fmt_check_lit_check_error(void);
extern uint8_t * driver_fmt_check_lit_fmt_error(void);
extern uint8_t * driver_fmt_check_lit_chk002(void);
extern uint8_t * driver_fmt_check_lit_fmt001(void);
extern uint8_t * fmt_builtin_ignore_at(int32_t i);
extern int32_t fmt_user_ignore_count(void);
extern uint8_t * fmt_user_ignore_at(int32_t i);
extern int32_t fmt_file_list_n(void);
extern uint8_t * fmt_path_resolve_abs(uint8_t * path);
extern int32_t fmt_file_list_store_impl(uint8_t * abs_path);
extern void file_list_clear_impl(void);
extern void fmt_check_dep_clear_impl(void);
extern void check_init_user_lib_flags_impl(int32_t argc, uint8_t * argv, int32_t path_start);
extern int32_t check_user_passed_L_get(void);
extern void check_try_append_lib_root_impl(uint8_t * check_argv, int32_t * n, uint8_t * dir);
extern void check_append_repo_lib_roots_impl(uint8_t * check_argv, int32_t * n);
extern void check_argv_append_default_libs_for_path_impl(uint8_t * path, uint8_t * check_argv, int32_t * n);
extern int32_t fmt_check_invoke_compile_impl(uint8_t * path);
extern void walk_dir_collect_impl(uint8_t * dir);
extern uint8_t * fmt_default_product_sub_at(int32_t i);
extern int32_t fmt_try_walk_if_product_subdir(uint8_t * sub);
extern void fmt_walk_cwd_fallback_impl(void);
extern int32_t fmt_path_stat_kind(uint8_t * path);
extern void collect_paths_missing_diag_impl(uint8_t * path);
extern void parse_ignore_opt_impl(uint8_t * arg);
extern int32_t check_one_file_body_impl(uint8_t * path, int32_t argc, uint8_t * argv);
extern void closedir_win_impl(uint8_t * d);
int32_t driver_check_quiet_ok_get(void) {
  return 1;
}
uint8_t * driver_collect_error_kind(void) {
  if ((driver_collect_mode_is_check() !=0)) {
    return driver_fmt_check_lit_check_error();
  }
  return driver_fmt_check_lit_fmt_error();
  return ((uint8_t *)(0));
}
uint8_t * driver_collect_missing_path_code(void) {
  if ((driver_collect_mode_is_check() !=0)) {
    return driver_fmt_check_lit_chk002();
  }
  return driver_fmt_check_lit_fmt001();
  return ((uint8_t *)(0));
}
int32_t path_should_ignore(uint8_t * path) {
  if ((path ==0)) {
    return 1;
  }
  {
    int32_t i = 0;
    while ((i < 32)) {
      uint8_t * b = fmt_builtin_ignore_at(i);
      if ((b ==0)) {
        break;
      }
      if ((strstr(path, b) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    int32_t n = fmt_user_ignore_count();
    int32_t j = 0;
    while ((j < n)) {
      uint8_t * u = fmt_user_ignore_at(j);
      if ((u !=0)) {
        if (((u)[0] !=0)) {
          if ((strstr(path, u) !=0)) {
            return 1;
          }
        }
      }
      (void)((j = (j + 1)));
    }
  }
  return 0;
}
int32_t fmt_path_ends_with_dot_x(uint8_t * path) {
  if ((path ==0)) {
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
int32_t file_list_push(uint8_t * path) {
  if ((path ==0)) {
    return -1;
  }
  {
    if ((fmt_file_list_n() >=8192)) {
      return -1;
    }
    uint8_t * abs_path = fmt_path_resolve_abs(path);
    if ((abs_path ==0)) {
      return -1;
    }
    if ((path_should_ignore(abs_path) !=0)) {
      return 0;
    }
    if ((fmt_path_ends_with_dot_x(abs_path) ==0)) {
      return 0;
    }
    return fmt_file_list_store_impl(abs_path);
  }
  return -1;
}
void file_list_clear(void) {
  (void)(file_list_clear_impl());
}
void fmt_check_dep_clear(void) {
  (void)(fmt_check_dep_clear_impl());
}
void check_init_user_lib_flags(int32_t argc, uint8_t * argv, int32_t path_start) {
  if ((argv ==0)) {
    return;
  }
  (void)(check_init_user_lib_flags_impl(argc, argv, path_start));
}
void check_try_append_lib_root(uint8_t * check_argv, int32_t * n, uint8_t * dir) {
  if ((check_argv ==0)) {
    return;
  }
  if ((n ==0)) {
    return;
  }
  if ((dir ==0)) {
    return;
  }
  if (((dir)[0] ==0)) {
    return;
  }
  if ((check_user_passed_L_get() !=0)) {
    return;
  }
  if ((*(n) >=58)) {
    return;
  }
  (void)(check_try_append_lib_root_impl(check_argv, n, dir));
}
void check_append_repo_lib_roots(uint8_t * check_argv, int32_t * n) {
  if ((check_argv ==0)) {
    return;
  }
  if ((n ==0)) {
    return;
  }
  (void)(check_append_repo_lib_roots_impl(check_argv, n));
}
void check_argv_append_default_libs_for_path(uint8_t * path, uint8_t * check_argv, int32_t * n) {
  if ((check_argv ==0)) {
    return;
  }
  if ((n ==0)) {
    return;
  }
  (void)(check_argv_append_default_libs_for_path_impl(path, check_argv, n));
}
int32_t fmt_check_invoke_compile(uint8_t * path) {
  if ((path ==0)) {
    return -1;
  }
  return fmt_check_invoke_compile_impl(path);
  return -1;
}
int32_t fmt_walk_skip_dot_name(uint8_t * name) {
  if ((name ==0)) {
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
void walk_dir_collect_process_child(uint8_t * child, int32_t is_dir, int32_t is_reg) {
  if ((child ==0)) {
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
}
void walk_dir_collect(uint8_t * dir) {
  if ((dir ==0)) {
    return;
  }
  (void)(walk_dir_collect_impl(dir));
}
void check_collect_default_product_dirs(void) {
  int32_t any = 0;
  int32_t i = 0;
  while ((i < 8)) {
    {
      uint8_t * sub = fmt_default_product_sub_at(i);
      if ((sub ==0)) {
        break;
      }
      if ((fmt_try_walk_if_product_subdir(sub) !=0)) {
        (void)((any = 1));
      }
    }
    (void)((i = (i + 1)));
  }
  if ((any ==0)) {
    (void)(fmt_walk_cwd_fallback_impl());
  }
}
void collect_paths_from_arg(uint8_t * arg) {
  if ((arg ==0)) {
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
      if ((base !=0)) {
        (void)(walk_dir_collect(base));
      }
      return;
    }
    (void)(file_list_push(arg));
  }
}
int32_t parse_ignore_opt(uint8_t * arg) {
  if ((arg ==0)) {
    return 0;
  }
  if (((arg)[0] !=45)) {
    return 0;
  }
  if (((arg)[1] !=45)) {
    return 0;
  }
  if (((arg)[2] !=105)) {
    return 0;
  }
  if (((arg)[3] !=103)) {
    return 0;
  }
  if (((arg)[4] !=110)) {
    return 0;
  }
  if (((arg)[5] !=111)) {
    return 0;
  }
  if (((arg)[6] !=114)) {
    return 0;
  }
  if (((arg)[7] !=101)) {
    return 0;
  }
  if (((arg)[8] !=61)) {
    return 0;
  }
  (void)(parse_ignore_opt_impl(arg));
  return 1;
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
  if ((nd_errors ==0)) {
    if ((nd_warnings ==0)) {
      if ((nd_infos ==0)) {
        return 1;
      }
    }
  }
  return 0;
}
int32_t check_one_finalize_rc(int32_t rc, int32_t warn_count) {
  if ((rc !=0)) {
    return rc;
  }
  if ((check_lint_fail_on_warnings() !=0)) {
    if ((warn_count > 0)) {
      return 1;
    }
  }
  return rc;
}
int32_t check_one_file(uint8_t * path, int32_t argc, uint8_t * argv) {
  if ((path ==0)) {
    return -1;
  }
  if ((argv ==0)) {
    return -1;
  }
  if ((argc <=0)) {
    return -1;
  }
  return check_one_file_body_impl(path, argc, argv);
  return -1;
}
void closedir_win(uint8_t * d) {
  if ((d ==0)) {
    return;
  }
  (void)(closedir_win_impl(d));
}
int32_t check_lint_fail_on_warnings(void) {
  {
    uint8_t * v = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x4c\x49\x4e\x54\x5f\x43\x49\x5f\x46\x41\x49\x4c\x5f\x4f\x4e"));
    if ((v ==0)) {
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
int32_t xlang_path_is_absolute(uint8_t * path) {
  if ((path ==0)) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  if (((path)[0] ==47)) {
    return 1;
  }
  uint8_t c0 = (path)[0];
  int32_t ok = 0;
  if ((c0 >=65)) {
    if ((c0 <=90)) {
      (void)((ok = 1));
    }
  }
  if ((c0 >=97)) {
    if ((c0 <=122)) {
      (void)((ok = 1));
    }
  }
  if ((ok !=0)) {
    if (((path)[1] ==58)) {
      return 1;
    }
  }
  return 0;
}
