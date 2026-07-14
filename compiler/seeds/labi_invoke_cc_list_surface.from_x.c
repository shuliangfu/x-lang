/* seeds/labi_invoke_cc_list_surface.from_x.c
 * G-02f labi_invoke_cc_list R2 full surface — isomorphic with src/runtime/labi_invoke_cc_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_invoke_cc_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (harden/skip-native/icc rel pure table)
 * Cap residual: getenv 🔒 + mega shux_invoke_cc_impl fork/exec
 * Regen: ./shux -E ... src/runtime/labi_invoke_cc_list.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern int32_t labi_linux_harden_flag_count(void);
extern uint8_t * labi_linux_harden_flag_at(int32_t i);
extern int32_t labi_invoke_cc_skip_native_env_count(void);
extern uint8_t * labi_invoke_cc_skip_native_env_at(int32_t i);
extern int32_t invoke_cc_skip_native_tuning(void);
extern uint8_t * labi_icc_rel_core_builtin_o(void);
extern uint8_t * labi_icc_rel_core_builtin_abi_h(void);
extern uint8_t * labi_icc_rel_core_mem_o(void);
extern uint8_t * labi_icc_rel_core_slice_o(void);
extern uint8_t * labi_icc_rel_db_kv_o(void);
extern uint8_t * labi_icc_rel_db_arrow_o(void);
extern uint8_t * labi_icc_rel_csv_o(void);
extern uint8_t * labi_icc_rel_error_o(void);
extern uint8_t * labi_icc_rel_heap_o(void);
extern uint8_t * labi_icc_rel_json_o(void);
extern uint8_t * labi_icc_rel_log_o(void);
extern uint8_t * labi_icc_rel_socketio_o(void);
extern int32_t labi_icc_needs_rel_count(void);
extern uint8_t * labi_icc_needs_rel_at(int32_t i);
extern uint8_t * getenv(uint8_t * name);
int32_t labi_linux_harden_flag_count(void) {
  return 5;
}
uint8_t * labi_linux_harden_flag_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){45, 112, 105, 101, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){45, 102, 112, 105, 101, 0 };
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = (uint8_t[]){45, 87, 108, 44, 45, 122, 44, 110, 111, 101, 120, 101, 99, 115, 116, 97, 99, 107, 0 };
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = (uint8_t[]){45, 87, 108, 44, 45, 122, 44, 114, 101, 108, 114, 111, 0 };
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = (uint8_t[]){45, 87, 108, 44, 45, 45, 97, 108, 108, 111, 119, 45, 109, 117, 108, 116, 105, 112, 108, 101, 45, 100, 101, 102, 105, 110, 105, 116, 105, 111, 110, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_invoke_cc_skip_native_env_count(void) {
  return 3;
}
uint8_t * labi_invoke_cc_skip_native_env_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){67, 73, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){83, 72, 85, 88, 95, 67, 73, 95, 68, 79, 67, 75, 69, 82, 0 };
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = (uint8_t[]){83, 72, 85, 88, 95, 78, 79, 95, 77, 65, 82, 67, 72, 95, 78, 65, 84, 73, 86, 69, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t invoke_cc_skip_native_tuning(void) {
  int32_t n = labi_invoke_cc_skip_native_env_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * name = labi_invoke_cc_skip_native_env_at(i);
    if ((name !=((uint8_t *)(0)))) {
      if (((name)[0] !=0)) {
        uint8_t * v = ((uint8_t *)(0));
        {
          (void)((v = getenv(name)));
        }
        if ((v !=((uint8_t *)(0)))) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
uint8_t * labi_icc_rel_core_builtin_o(void) {
  uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 98, 117, 105, 108, 116, 105, 110, 47, 98, 117, 105, 108, 116, 105, 110, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_core_builtin_abi_h(void) {
  uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 98, 117, 105, 108, 116, 105, 110, 47, 98, 117, 105, 108, 116, 105, 110, 95, 97, 98, 105, 46, 104, 0 };
  return p;
}
uint8_t * labi_icc_rel_core_mem_o(void) {
  uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 109, 101, 109, 47, 109, 101, 109, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_core_slice_o(void) {
  uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 115, 108, 105, 99, 101, 47, 115, 108, 105, 99, 101, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_db_kv_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 98, 47, 107, 118, 47, 107, 118, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_db_arrow_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 98, 47, 97, 114, 114, 111, 119, 47, 97, 114, 114, 111, 119, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_csv_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 115, 118, 47, 99, 115, 118, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_error_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 114, 114, 111, 114, 47, 101, 114, 114, 111, 114, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_heap_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 104, 101, 97, 112, 47, 104, 101, 97, 112, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_json_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 106, 115, 111, 110, 47, 106, 115, 111, 110, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_log_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 108, 111, 103, 47, 108, 111, 103, 46, 111, 0 };
  return p;
}
uint8_t * labi_icc_rel_socketio_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 111, 99, 107, 101, 116, 105, 111, 47, 115, 111, 99, 107, 101, 116, 105, 111, 46, 111, 0 };
  return p;
}
int32_t labi_icc_needs_rel_count(void) {
  return 12;
}
uint8_t * labi_icc_needs_rel_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 98, 117, 105, 108, 116, 105, 110, 47, 98, 117, 105, 108, 116, 105, 110, 46, 111, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 98, 117, 105, 108, 116, 105, 110, 47, 98, 117, 105, 108, 116, 105, 110, 95, 97, 98, 105, 46, 104, 0 };
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 109, 101, 109, 47, 109, 101, 109, 46, 111, 0 };
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = (uint8_t[]){99, 111, 114, 101, 47, 115, 108, 105, 99, 101, 47, 115, 108, 105, 99, 101, 46, 111, 0 };
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 98, 47, 107, 118, 47, 107, 118, 46, 111, 0 };
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 98, 47, 97, 114, 114, 111, 119, 47, 97, 114, 114, 111, 119, 46, 111, 0 };
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 115, 118, 47, 99, 115, 118, 46, 111, 0 };
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 114, 114, 111, 114, 47, 101, 114, 114, 111, 114, 46, 111, 0 };
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 104, 101, 97, 112, 47, 104, 101, 97, 112, 46, 111, 0 };
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 106, 115, 111, 110, 47, 106, 115, 111, 110, 46, 111, 0 };
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 108, 111, 103, 47, 108, 111, 103, 46, 111, 0 };
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 111, 99, 107, 101, 116, 105, 111, 47, 115, 111, 99, 107, 101, 116, 105, 111, 46, 111, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
