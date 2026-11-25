/*
 * Host-cc first-wins twin of main.x driver_argv_parse_x (-E scan).
 *
 * DIG s204/s210: tipU asm dropped `break` in the -E inner while →
 * driver_get_argv_i infinite loop on Win. This twin uses an explicit
 * e_done flag (same as tip main.x / driver_gen after s210).
 * PLATFORM: WINDOWS DIG host-cc · SHARED semantics.
 */
#include <stdint.h>
#include <string.h>

struct main_DriverXEmitState {
  uint8_t path_buf[512];
  int32_t path_len;
  int32_t emit_extern_imports;
  int32_t use_asm_backend;
  int32_t target_arch;
  uint8_t out_path_buf[512];
  int32_t out_path_len;
};

extern int32_t driver_get_argv_i(int32_t argc, uint8_t *argv, int32_t i, uint8_t *buf, int32_t max);
extern int32_t driver_compile_argv_next_is_value_c(int32_t argc, uint8_t *argv, int32_t i, uint8_t *buf, int32_t max);
extern uint8_t *driver_emit_state_key(struct main_DriverXEmitState *state);
extern void driver_emit_lib_root_reset(uint8_t *key);
extern int32_t main_eq_minus_L(uint8_t *buf, int32_t len);
extern int32_t main_eq_minus_backend(uint8_t *buf, int32_t len);
extern int32_t main_eq_minus_target(uint8_t *buf, int32_t len);
extern int32_t main_eq_minus_x(uint8_t *buf, int32_t len);
extern int32_t main_eq_minus_lib_name(uint8_t *buf, int32_t len);
extern int32_t main_eq_minus_E(uint8_t *buf, int32_t len);
extern int32_t main_eq_minus_E_extern(uint8_t *buf, int32_t len);
extern int32_t main_eq_asm(uint8_t *buf, int32_t len);
extern int32_t main_target_contains_arm(uint8_t *buf, int32_t len);
extern int32_t main_target_contains_riscv(uint8_t *buf, int32_t len);
extern void main_driver_emit_try_append_lib_from_argv(int32_t argc, uint8_t *argv, int32_t arg_i,
                                                      struct main_DriverXEmitState *state);
extern void xlang_driver_x_emit_set_lib_name(uint8_t *buf, int32_t len);

/**
 * Parse -x -E argv lane; return 1 when path captured.
 * PLATFORM: SHARED · WINDOWS DIG first-wins thin.
 */
int32_t main_driver_argv_parse_x(int32_t argc, uint8_t *argv, struct main_DriverXEmitState *state) {
  uint8_t arg_buf[512];
  int32_t i;
  int32_t len;
  int32_t pi;
  int32_t e_done;
  int32_t plen_temp;
  int32_t nl2;
  int32_t nl3;
  int32_t vlen;
  int32_t tlen;
  int32_t opt_len;
  int32_t plen;

  if (!state) {
    return 0;
  }
  state->path_len = 0;
  driver_emit_lib_root_reset(driver_emit_state_key(state));
  state->emit_extern_imports = 0;
  state->use_asm_backend = 0;
  state->target_arch = 0;
  state->out_path_len = 0;
  if (argc < 3) {
    return 0;
  }
  i = 1;
  while (i < argc) {
    len = driver_get_argv_i(argc, argv, i, arg_buf, 512);
    if (len < 0) {
      i = i + 1;
      continue;
    }
    if (main_eq_minus_L(arg_buf, len) != 0 && i + 1 < argc) {
      if (driver_compile_argv_next_is_value_c(argc, argv, i, arg_buf, 512) != 0) {
        main_driver_emit_try_append_lib_from_argv(argc, argv, i + 1, state);
        i = i + 2;
      } else {
        i = i + 1;
      }
      continue;
    }
    if (main_eq_minus_backend(arg_buf, len) != 0 && i + 1 < argc) {
      if (driver_compile_argv_next_is_value_c(argc, argv, i, arg_buf, 512) != 0) {
        vlen = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
        if (vlen >= 0 && main_eq_asm(arg_buf, vlen) != 0) {
          state->use_asm_backend = 1;
        }
        i = i + 2;
      } else {
        i = i + 1;
      }
      continue;
    }
    if (main_eq_minus_target(arg_buf, len) != 0 && i + 1 < argc) {
      if (driver_compile_argv_next_is_value_c(argc, argv, i, arg_buf, 512) != 0) {
        tlen = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
        if (tlen >= 0 && main_target_contains_arm(arg_buf, tlen) != 0) {
          state->target_arch = 1;
        }
        if (tlen >= 0 && main_target_contains_riscv(arg_buf, tlen) != 0) {
          state->target_arch = 2;
        }
        i = i + 2;
      } else {
        i = i + 1;
      }
      continue;
    }
    if (main_eq_minus_x(arg_buf, len) != 0) {
      i = i + 1;
      continue;
    }
    if (main_eq_minus_lib_name(arg_buf, len) != 0) {
      if (i + 1 < argc && driver_compile_argv_next_is_value_c(argc, argv, i, arg_buf, 512) != 0) {
        nl2 = driver_get_argv_i(argc, argv, i + 1, arg_buf, 512);
        if (nl2 > 0) {
          xlang_driver_x_emit_set_lib_name(&arg_buf[0], nl2);
        }
        i = i + 2;
      } else {
        i = i + 1;
      }
      continue;
    }
    if (main_eq_minus_E(arg_buf, len) != 0) {
      pi = i + 1;
      e_done = 0;
      while (pi < argc && e_done == 0) {
        plen_temp = driver_get_argv_i(argc, argv, pi, arg_buf, 512);
        if (plen_temp > 0 && main_eq_minus_lib_name(arg_buf, plen_temp) != 0 && pi + 1 < argc) {
          if (driver_compile_argv_next_is_value_c(argc, argv, pi, arg_buf, 512) != 0) {
            nl3 = driver_get_argv_i(argc, argv, pi + 1, arg_buf, 512);
            if (nl3 > 0) {
              xlang_driver_x_emit_set_lib_name(&arg_buf[0], nl3);
            }
            pi = pi + 2;
          } else {
            pi = pi + 1;
          }
          continue;
        }
        if (plen_temp > 0 && main_eq_minus_L(arg_buf, plen_temp) != 0 && pi + 1 < argc) {
          if (driver_compile_argv_next_is_value_c(argc, argv, pi, arg_buf, 512) != 0) {
            main_driver_emit_try_append_lib_from_argv(argc, argv, pi + 1, state);
            pi = pi + 2;
          } else {
            pi = pi + 1;
          }
          continue;
        }
        if (plen_temp > 0 && main_eq_minus_x(arg_buf, plen_temp) != 0) {
          pi = pi + 1;
          continue;
        }
        e_done = 1;
      }
      if (pi < argc) {
        opt_len = driver_get_argv_i(argc, argv, pi, arg_buf, 512);
        if (opt_len >= 0 && main_eq_minus_E_extern(arg_buf, opt_len) != 0) {
          state->emit_extern_imports = 1;
          pi = pi + 1;
        }
      }
      if (pi < argc) {
        plen = driver_get_argv_i(argc, argv, pi, state->path_buf, 512);
        if (plen >= 0) {
          state->path_len = plen;
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}
