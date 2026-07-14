/* seeds/labi_invoke_ld_list_surface.from_x.c
 * G-02f labi_invoke_ld_list R2 full surface — isomorphic with src/runtime/labi_invoke_ld_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_invoke_ld_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (brew/compress/tail/driver pure table)
 * Cap residual: spawn/ld/cc IO in mega shux_asm_invoke_ld_platform / tail_libs
 * Regen: ./shux -E ... src/runtime/labi_invoke_ld_list.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
int32_t labi_ld_brew_lib_path_count(void) {
  return 2;
}
uint8_t * labi_ld_brew_lib_path_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){45, 76, 47, 111, 112, 116, 47, 104, 111, 109, 101, 98, 114, 101, 119, 47, 108, 105, 98, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){45, 76, 47, 117, 115, 114, 47, 108, 111, 99, 97, 108, 47, 108, 105, 98, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_ld_flag_lz(void) {
  uint8_t * p = (uint8_t[]){45, 108, 122, 0 };
  return p;
}
uint8_t * labi_ld_flag_lzstd(void) {
  uint8_t * p = (uint8_t[]){45, 108, 122, 115, 116, 100, 0 };
  return p;
}
uint8_t * labi_ld_flag_lbrotlienc(void) {
  uint8_t * p = (uint8_t[]){45, 108, 98, 114, 111, 116, 108, 105, 101, 110, 99, 0 };
  return p;
}
uint8_t * labi_ld_flag_lbrotlidec(void) {
  uint8_t * p = (uint8_t[]){45, 108, 98, 114, 111, 116, 108, 105, 100, 101, 99, 0 };
  return p;
}
int32_t labi_ld_compress_flag_count(void) {
  return 4;
}
uint8_t * labi_ld_compress_flag_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){45, 108, 122, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){45, 108, 122, 115, 116, 100, 0 };
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = (uint8_t[]){45, 108, 98, 114, 111, 116, 108, 105, 101, 110, 99, 0 };
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = (uint8_t[]){45, 108, 98, 114, 111, 116, 108, 105, 100, 101, 99, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_ld_flag_lm(void) {
  uint8_t * p = (uint8_t[]){45, 108, 109, 0 };
  return p;
}
uint8_t * labi_ld_flag_lsqlite3(void) {
  uint8_t * p = (uint8_t[]){45, 108, 115, 113, 108, 105, 116, 101, 51, 0 };
  return p;
}
uint8_t * labi_ld_flag_pthread(void) {
  uint8_t * p = (uint8_t[]){45, 112, 116, 104, 114, 101, 97, 100, 0 };
  return p;
}
uint8_t * labi_ld_flag_lpthread(void) {
  uint8_t * p = (uint8_t[]){45, 108, 112, 116, 104, 114, 101, 97, 100, 0 };
  return p;
}
uint8_t * labi_ld_flag_ldl(void) {
  uint8_t * p = (uint8_t[]){45, 108, 100, 108, 0 };
  return p;
}
uint8_t * labi_ld_flag_lc(void) {
  uint8_t * p = (uint8_t[]){45, 108, 99, 0 };
  return p;
}
uint8_t * labi_ld_flag_lSystem(void) {
  uint8_t * p = (uint8_t[]){45, 108, 83, 121, 115, 116, 101, 109, 0 };
  return p;
}
uint8_t * labi_ld_flag_lws2_32(void) {
  uint8_t * p = (uint8_t[]){45, 108, 119, 115, 50, 95, 51, 50, 0 };
  return p;
}
uint8_t * labi_ld_flag_lbcrypt(void) {
  uint8_t * p = (uint8_t[]){45, 108, 98, 99, 114, 121, 112, 116, 0 };
  return p;
}
uint8_t * labi_ld_driver_clang(void) {
  uint8_t * p = (uint8_t[]){99, 108, 97, 110, 103, 0 };
  return p;
}
uint8_t * labi_ld_driver_ld(void) {
  uint8_t * p = (uint8_t[]){108, 100, 0 };
  return p;
}
uint8_t * labi_ld_driver_gcc(void) {
  uint8_t * p = (uint8_t[]){103, 99, 99, 0 };
  return p;
}
uint8_t * labi_ld_driver_cc(void) {
  uint8_t * p = (uint8_t[]){99, 99, 0 };
  return p;
}
uint8_t * labi_ld_mach_entry_main(void) {
  uint8_t * p = (uint8_t[]){95, 109, 97, 105, 110, 0 };
  return p;
}
uint8_t * labi_ld_flag_e(void) {
  uint8_t * p = (uint8_t[]){45, 101, 0 };
  return p;
}
uint8_t * labi_ld_flag_o(void) {
  uint8_t * p = (uint8_t[]){45, 111, 0 };
  return p;
}
int32_t labi_ld_common_tail_flag_count(void) {
  return 7;
}
uint8_t * labi_ld_common_tail_flag_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){45, 108, 109, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){45, 108, 115, 113, 108, 105, 116, 101, 51, 0 };
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = (uint8_t[]){45, 112, 116, 104, 114, 101, 97, 100, 0 };
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = (uint8_t[]){45, 108, 112, 116, 104, 114, 101, 97, 100, 0 };
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = (uint8_t[]){45, 108, 100, 108, 0 };
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = (uint8_t[]){45, 108, 99, 0 };
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = (uint8_t[]){45, 108, 83, 121, 115, 116, 101, 109, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}