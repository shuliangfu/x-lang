/* seeds/labi_invoke_ld_list_surface.from_x.c
 * G-02f labi_invoke_ld_list R2 full surface — isomorphic with src/runtime/labi_invoke_ld_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_invoke_ld_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (brew/compress/tail/driver pure table
 *   + wave152 ld_append_brew_lib_paths pure orch
 *   + wave153 asm_ld_append_compress_libs pure orch
 *   + wave154 invoke_cc_append_compress_ld pure orch
 *   + wave156 shux_asm_ld_append_mach_tail_libs_impl pure orch
 *   + wave157 shux_asm_ld_append_unix_gcc_tail_libs_impl pure orch
 *   + wave158 invoke_cc_append_net_tls_ld pure orch)
 * Cap residual: host_is_apple; needs + ensure + path; push_existing;
 *   exports_marker / realpath_cap / shux_rel_o_path_from_argv0; spawn/ld/cc IO mega
 * Regen: ./shux_asm -E ... src/runtime/labi_invoke_ld_list.x | filter DBG + polish prologue
 * PLATFORM: SHARED - pure contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern int32_t link_abi_host_is_apple(void);
extern int32_t shux_host_is_linux(void);
extern int32_t link_abi_obj_needs_zlib(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_zstd(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_brotli(uint8_t * obj_o);
extern int32_t link_abi_user_o_needs_compress_libs(uint8_t * user_o);
extern int32_t shux_ensure_runtime_compress_zlib_glue_o(uint8_t * argv0);
extern uint8_t * shux_runtime_compress_zlib_glue_o_path(uint8_t * argv0);
extern int32_t invoke_cc_argv_push_existing(uint8_t * * argv, int32_t * ia, int32_t max_ia, uint8_t * path);
extern int32_t link_abi_obj_exports_marker(uint8_t * obj_o, uint8_t * marker);
extern uint8_t * link_abi_realpath_cap(uint8_t * path, uint8_t * out);
extern uint8_t * shux_rel_o_path_from_argv0(uint8_t * argv0, uint8_t * rel);
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
/* wave158: net_tls pure flag/marker/rel catalog (surface pin). */
uint8_t * labi_ld_flag_L_hb_openssl(void) {
  uint8_t * p = (uint8_t[]){45, 76, 47, 111, 112, 116, 47, 104, 111, 109, 101, 98, 114, 101, 119, 47, 111, 112, 116, 47, 111, 112, 101, 110, 115, 115, 108, 47, 108, 105, 98, 0 };
  return p;
}
uint8_t * labi_ld_flag_L_hb_mbedtls(void) {
  uint8_t * p = (uint8_t[]){45, 76, 47, 111, 112, 116, 47, 104, 111, 109, 101, 98, 114, 101, 119, 47, 111, 112, 116, 47, 109, 98, 101, 100, 116, 108, 115, 47, 108, 105, 98, 0 };
  return p;
}
uint8_t * labi_ld_flag_lssl(void) {
  uint8_t * p = (uint8_t[]){45, 108, 115, 115, 108, 0 };
  return p;
}
uint8_t * labi_ld_flag_lcrypto(void) {
  uint8_t * p = (uint8_t[]){45, 108, 99, 114, 121, 112, 116, 111, 0 };
  return p;
}
uint8_t * labi_ld_flag_lmbedtls(void) {
  uint8_t * p = (uint8_t[]){45, 108, 109, 98, 101, 100, 116, 108, 115, 0 };
  return p;
}
uint8_t * labi_ld_flag_lmbedx509(void) {
  uint8_t * p = (uint8_t[]){45, 108, 109, 98, 101, 100, 120, 53, 48, 57, 0 };
  return p;
}
uint8_t * labi_ld_flag_lmbedcrypto(void) {
  uint8_t * p = (uint8_t[]){45, 108, 109, 98, 101, 100, 99, 114, 121, 112, 116, 111, 0 };
  return p;
}
uint8_t * labi_net_tls_openssl_marker(void) {
  uint8_t * p = (uint8_t[]){115, 104, 117, 95, 110, 101, 116, 95, 116, 108, 115, 95, 111, 112, 101, 110, 115, 115, 108, 95, 109, 97, 114, 107, 101, 114, 0 };
  return p;
}
uint8_t * labi_net_tls_mbedtls_marker(void) {
  uint8_t * p = (uint8_t[]){115, 104, 117, 95, 110, 101, 116, 95, 116, 108, 115, 95, 109, 98, 101, 100, 116, 108, 115, 95, 109, 97, 114, 107, 101, 114, 0 };
  return p;
}
uint8_t * labi_rel_tls_openssl_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 110, 101, 116, 47, 116, 108, 115, 95, 111, 112, 101, 110, 115, 115, 108, 46, 111, 0 };
  return p;
}
uint8_t * labi_rel_tls_mbedtls_o(void) {
  uint8_t * p = (uint8_t[]){115, 116, 100, 47, 110, 101, 116, 47, 116, 108, 115, 95, 109, 98, 101, 100, 116, 108, 115, 46, 111, 0 };
  return p;
}
void labi_append_openssl_ld_flags(uint8_t * * argv, int32_t * i, int32_t argv_cap) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((i ==0)) {
    return;
  }
  int32_t is_apple = 0;
  (void)((is_apple = link_abi_host_is_apple()));
  if ((is_apple !=0)) {
    int32_t cur = (i)[0];
    if ((cur <(argv_cap - 1))) {
      uint8_t * fl = labi_ld_flag_L_hb_openssl();
      (void)(((argv)[cur] = fl));
      (void)(((i)[0] = (cur + 1)));
    }
  }
  int32_t cur2 = (i)[0];
  if ((cur2 <(argv_cap - 1))) {
    uint8_t * fssl = labi_ld_flag_lssl();
    (void)(((argv)[cur2] = fssl));
    (void)(((i)[0] = (cur2 + 1)));
  }
  int32_t cur3 = (i)[0];
  if ((cur3 <(argv_cap - 1))) {
    uint8_t * fcr = labi_ld_flag_lcrypto();
    (void)(((argv)[cur3] = fcr));
    (void)(((i)[0] = (cur3 + 1)));
  }
}
void labi_append_mbedtls_ld_flags(uint8_t * * argv, int32_t * i, int32_t argv_cap) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((i ==0)) {
    return;
  }
  int32_t is_apple = 0;
  (void)((is_apple = link_abi_host_is_apple()));
  if ((is_apple !=0)) {
    int32_t cur = (i)[0];
    if ((cur <(argv_cap - 1))) {
      uint8_t * fl = labi_ld_flag_L_hb_mbedtls();
      (void)(((argv)[cur] = fl));
      (void)(((i)[0] = (cur + 1)));
    }
  }
  int32_t cur2 = (i)[0];
  if ((cur2 <(argv_cap - 1))) {
    uint8_t * fmb = labi_ld_flag_lmbedtls();
    (void)(((argv)[cur2] = fmb));
    (void)(((i)[0] = (cur2 + 1)));
  }
  int32_t cur3 = (i)[0];
  if ((cur3 <(argv_cap - 1))) {
    uint8_t * fx = labi_ld_flag_lmbedx509();
    (void)(((argv)[cur3] = fx));
    (void)(((i)[0] = (cur3 + 1)));
  }
  int32_t cur4 = (i)[0];
  if ((cur4 <(argv_cap - 1))) {
    uint8_t * fc = labi_ld_flag_lmbedcrypto();
    (void)(((argv)[cur4] = fc));
    (void)(((i)[0] = (cur4 + 1)));
  }
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
/* wave152: ld_append_brew_lib_paths pure orch (surface pin; Cap residual host_is_apple). */
void ld_append_brew_lib_paths(uint8_t * * argv, int32_t * la, int32_t max_la) {
  int32_t apple = 0;
  (void)((apple = link_abi_host_is_apple()));
  if ((apple ==0)) {
    return;
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  int32_t n = labi_ld_brew_lib_path_count();
  int32_t k = 0;
  while ((k <n)) {
    int32_t cur = (la)[0];
    if ((cur >=(max_la - 1))) {
      break;
    }
    uint8_t * p = labi_ld_brew_lib_path_at(k);
    (void)((k = (k + 1)));
    if ((p ==0)) {
      continue;
    }
    if (((p)[0] ==0)) {
      continue;
    }
    (void)(((argv)[cur] = p));
    (void)(((la)[0] = (cur + 1)));
  }
}
/* wave153: asm_ld_append_compress_libs pure orch (surface pin; Cap residual needs+ensure+path). */
void asm_ld_append_compress_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * * argv, int32_t * la, int32_t max_la) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  int32_t need_z = 0;
  int32_t need_zs = 0;
  int32_t need_br = 0;
  (void)((need_z = link_abi_obj_needs_zlib(compress_o)));
  if ((need_z ==0)) {
    (void)((need_z = link_abi_obj_needs_zlib(user_o)));
  }
  (void)((need_zs = link_abi_obj_needs_zstd(compress_o)));
  if ((need_zs ==0)) {
    (void)((need_zs = link_abi_obj_needs_zstd(user_o)));
  }
  (void)((need_br = link_abi_obj_needs_brotli(compress_o)));
  if ((need_br ==0)) {
    (void)((need_br = link_abi_obj_needs_brotli(user_o)));
  }
  if ((need_z !=0)) {
    ld_append_brew_lib_paths(argv, la, max_la);
    int32_t cur = (la)[0];
    if ((cur <(max_la - 1))) {
      uint8_t * fl = labi_ld_flag_lz();
      (void)(((argv)[cur] = fl));
      (void)(((la)[0] = (cur + 1)));
    }
    int32_t _e = 0;
    (void)((_e = shux_ensure_runtime_compress_zlib_glue_o(((uint8_t *)(0)))));
    uint8_t * glue = ((uint8_t *)(0));
    (void)((glue = shux_runtime_compress_zlib_glue_o_path(((uint8_t *)(0)))));
    if ((glue !=0)) {
      if (((glue)[0] !=0)) {
        int32_t cur2 = (la)[0];
        if ((cur2 <(max_la - 1))) {
          (void)(((argv)[cur2] = glue));
          (void)(((la)[0] = (cur2 + 1)));
        }
      }
    }
  }
  if ((need_zs !=0)) {
    ld_append_brew_lib_paths(argv, la, max_la);
    int32_t curz = (la)[0];
    if ((curz <(max_la - 1))) {
      uint8_t * flz = labi_ld_flag_lzstd();
      (void)(((argv)[curz] = flz));
      (void)(((la)[0] = (curz + 1)));
    }
  }
  if ((need_br !=0)) {
    ld_append_brew_lib_paths(argv, la, max_la);
    int32_t curb = (la)[0];
    if ((curb <(max_la - 1))) {
      uint8_t * fle = labi_ld_flag_lbrotlienc();
      (void)(((argv)[curb] = fle));
      (void)(((la)[0] = (curb + 1)));
    }
    int32_t curb2 = (la)[0];
    if ((curb2 <(max_la - 1))) {
      uint8_t * fld = labi_ld_flag_lbrotlidec();
      (void)(((argv)[curb2] = fld));
      (void)(((la)[0] = (curb2 + 1)));
    }
  }
}
/* wave154: invoke_cc_append_compress_ld pure orch (surface pin; Cap residual push_existing). */
void invoke_cc_append_compress_ld(uint8_t * * argv, int32_t * i, int32_t argv_cap, uint8_t * compress_o, uint8_t * user_o) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((i ==0)) {
    return;
  }
  if ((((i)[0] >=(argv_cap - 1)))) {
    return;
  }
  int32_t need_z = 0;
  int32_t need_zs = 0;
  int32_t need_br = 0;
  (void)((need_z = link_abi_obj_needs_zlib(compress_o)));
  if ((need_z ==0)) {
    (void)((need_z = link_abi_obj_needs_zlib(user_o)));
  }
  (void)((need_zs = link_abi_obj_needs_zstd(compress_o)));
  if ((need_zs ==0)) {
    (void)((need_zs = link_abi_obj_needs_zstd(user_o)));
  }
  (void)((need_br = link_abi_obj_needs_brotli(compress_o)));
  if ((need_br ==0)) {
    (void)((need_br = link_abi_obj_needs_brotli(user_o)));
  }
  if ((need_z !=0)) {
    ld_append_brew_lib_paths(argv, i, argv_cap);
    int32_t cur = (i)[0];
    if ((cur <(argv_cap - 1))) {
      uint8_t * fl = labi_ld_flag_lz();
      (void)(((argv)[cur] = fl));
      (void)(((i)[0] = (cur + 1)));
    }
    int32_t _e = 0;
    (void)((_e = shux_ensure_runtime_compress_zlib_glue_o(((uint8_t *)(0)))));
    uint8_t * glue = ((uint8_t *)(0));
    (void)((glue = shux_runtime_compress_zlib_glue_o_path(((uint8_t *)(0)))));
    int32_t _p = 0;
    (void)((_p = invoke_cc_argv_push_existing(argv, i, argv_cap, glue)));
  }
  if ((need_zs !=0)) {
    ld_append_brew_lib_paths(argv, i, argv_cap);
    int32_t curz = (i)[0];
    if ((curz <(argv_cap - 1))) {
      uint8_t * flz = labi_ld_flag_lzstd();
      (void)(((argv)[curz] = flz));
      (void)(((i)[0] = (curz + 1)));
    }
  }
  if ((need_br !=0)) {
    ld_append_brew_lib_paths(argv, i, argv_cap);
    int32_t curb = (i)[0];
    if ((curb <(argv_cap - 1))) {
      uint8_t * fle = labi_ld_flag_lbrotlienc();
      (void)(((argv)[curb] = fle));
      (void)(((i)[0] = (curb + 1)));
    }
    int32_t curb2 = (i)[0];
    if ((curb2 <(argv_cap - 1))) {
      uint8_t * fld = labi_ld_flag_lbrotlidec();
      (void)(((argv)[curb2] = fld));
      (void)(((i)[0] = (curb2 + 1)));
    }
  }
}
/* wave156: shux_asm_ld_append_mach_tail_libs_impl pure orch (surface pin; flags i32 layout). */
void shux_asm_ld_append_mach_tail_libs_impl(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, uint8_t * * argv, int32_t * la, int32_t max_la, int32_t append_lsystem) {
  if ((flags == 0)) {
    return;
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab == 0)) {
    return;
  }
  if ((la == 0)) {
    return;
  }
  if ((((la)[0] < 0))) {
    return;
  }
  int32_t * f = ((int32_t *)(flags));
  int32_t have_thread = (f)[2];
  int32_t have_sync = (f)[3];
  int32_t have_channel = (f)[4];
  int32_t have_math = (f)[5];
  int32_t have_compress = (f)[6];
  int32_t have_sqlite = (f)[8];
  int32_t need_pt = 0;
  if ((have_thread != 0)) {
    need_pt = 1;
  }
  if ((have_sync != 0)) {
    need_pt = 1;
  }
  if ((have_channel != 0)) {
    need_pt = 1;
  }
  if ((have_math != 0)) {
    int32_t cur = (la)[0];
    if ((cur <(max_la - 1))) {
      uint8_t * fl = labi_ld_flag_lm();
      (void)(((argv)[cur] = fl));
      (void)(((la)[0] = (cur + 1)));
    }
  }
  int32_t need_comp = have_compress;
  if ((need_comp == 0)) {
    (void)((need_comp = link_abi_user_o_needs_compress_libs(user_o)));
  }
  if ((need_comp != 0)) {
    asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
  }
  if ((have_sqlite != 0)) {
    int32_t curs = (la)[0];
    if ((curs <(max_la - 1))) {
      uint8_t * fs = labi_ld_flag_lsqlite3();
      (void)(((argv)[curs] = fs));
      (void)(((la)[0] = (curs + 1)));
    }
  }
  if ((need_pt != 0)) {
    int32_t curp = (la)[0];
    if ((curp <(max_la - 1))) {
      uint8_t * fp = labi_ld_flag_pthread();
      (void)(((argv)[curp] = fp));
      (void)(((la)[0] = (curp + 1)));
    }
  }
  if ((append_lsystem != 0)) {
    int32_t curl = (la)[0];
    if ((curl <(max_la - 1))) {
      uint8_t * fsys = labi_ld_flag_lSystem();
      (void)(((argv)[curl] = fsys));
      (void)(((la)[0] = (curl + 1)));
    }
  }
}
/* wave157: shux_asm_ld_append_unix_gcc_tail_libs_impl pure orch (surface pin; flags i32 layout). */
void shux_asm_ld_append_unix_gcc_tail_libs_impl(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, int32_t need_pt, uint8_t * * argv, int32_t * la, int32_t max_la) {
  if ((flags == 0)) {
    return;
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab == 0)) {
    return;
  }
  if ((la == 0)) {
    return;
  }
  if ((((la)[0] < 0))) {
    return;
  }
  int32_t * f = ((int32_t *)(flags));
  int32_t have_io = (f)[0];
  int32_t have_net = (f)[1];
  int32_t have_math = (f)[5];
  int32_t have_compress = (f)[6];
  int32_t have_dynlib = (f)[7];
  int32_t have_sqlite = (f)[8];
  int32_t have_libc_heap = (f)[10];
  int32_t have_fs = (f)[11];
  if ((have_io != 0)) {
    if ((need_pt != 0)) {
      int32_t cur0 = (la)[0];
      if ((cur0 <(max_la - 1))) {
        uint8_t * fp0 = labi_ld_flag_pthread();
        (void)(((argv)[cur0] = fp0));
        (void)(((la)[0] = (cur0 + 1)));
      }
    }
  } else {
    if ((need_pt != 0)) {
      int32_t cur1 = (la)[0];
      if ((cur1 <(max_la - 1))) {
        uint8_t * fp1 = labi_ld_flag_lpthread();
        (void)(((argv)[cur1] = fp1));
        (void)(((la)[0] = (cur1 + 1)));
      }
    }
  }
  if ((have_math != 0)) {
    int32_t curm = (la)[0];
    if ((curm <(max_la - 1))) {
      uint8_t * fm = labi_ld_flag_lm();
      (void)(((argv)[curm] = fm));
      (void)(((la)[0] = (curm + 1)));
    }
  }
  int32_t need_comp = have_compress;
  if ((need_comp == 0)) {
    (void)((need_comp = link_abi_user_o_needs_compress_libs(user_o)));
  }
  if ((need_comp != 0)) {
    asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
  }
  if ((have_sqlite != 0)) {
    int32_t curs = (la)[0];
    if ((curs <(max_la - 1))) {
      uint8_t * fs = labi_ld_flag_lsqlite3();
      (void)(((argv)[curs] = fs));
      (void)(((la)[0] = (curs + 1)));
    }
  }
  if ((have_dynlib != 0)) {
    int32_t is_linux = 0;
    (void)((is_linux = shux_host_is_linux()));
    if ((is_linux != 0)) {
      int32_t curd = (la)[0];
      if ((curd <(max_la - 1))) {
        uint8_t * fd = labi_ld_flag_ldl();
        (void)(((argv)[curd] = fd));
        (void)(((la)[0] = (curd + 1)));
      }
    }
  }
  int32_t always_lc = 0;
  if ((have_io != 0)) {
    always_lc = 1;
  }
  if ((have_net != 0)) {
    always_lc = 1;
  }
  if ((need_pt != 0)) {
    always_lc = 1;
  }
  if ((always_lc != 0)) {
    int32_t curc = (la)[0];
    if ((curc <(max_la - 1))) {
      uint8_t * fc = labi_ld_flag_lc();
      (void)(((argv)[curc] = fc));
      (void)(((la)[0] = (curc + 1)));
    }
  } else {
    int32_t want_lc = 0;
    if ((have_libc_heap != 0)) {
      want_lc = 1;
    }
    if ((have_fs != 0)) {
      want_lc = 1;
    }
    if ((have_math != 0)) {
      want_lc = 1;
    }
    if ((have_compress != 0)) {
      want_lc = 1;
    }
    if ((have_sqlite != 0)) {
      want_lc = 1;
    }
    if ((have_dynlib != 0)) {
      want_lc = 1;
    }
    if ((want_lc != 0)) {
      int32_t is_linux2 = 0;
      int32_t is_apple = 0;
      (void)((is_linux2 = shux_host_is_linux()));
      (void)((is_apple = link_abi_host_is_apple()));
      if (((is_linux2 != 0) || (is_apple != 0))) {
        int32_t curc2 = (la)[0];
        if ((curc2 <(max_la - 1))) {
          uint8_t * fc2 = labi_ld_flag_lc();
          (void)(((argv)[curc2] = fc2));
          (void)(((la)[0] = (curc2 + 1)));
        }
      }
    }
  }
}/* wave158: invoke_cc_append_net_tls_ld pure orch (surface pin; Cap residual marker/realpath/rel/push). */
int32_t invoke_cc_append_net_tls_ld(uint8_t * * argv, int32_t * i, int32_t argv_cap, uint8_t * net_o, uint8_t * repo_root) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return 0;
  }
  if ((i ==0)) {
    return 0;
  }
  if ((((i)[0] >=(argv_cap - 1)))) {
    return 0;
  }
  uint8_t * mk_ssl = labi_net_tls_openssl_marker();
  uint8_t * mk_mb = labi_net_tls_mbedtls_marker();
  if ((net_o !=0)) {
    if ((((net_o)[0] !=0))) {
      uint8_t * use = net_o;
      uint8_t abs_n[4096];
      uint8_t * rn = ((uint8_t *)(0));
      (void)((rn = link_abi_realpath_cap(net_o, &((abs_n)[0]))));
      if ((rn !=0)) {
        use = rn;
      }
      int32_t hit_ssl = 0;
      (void)((hit_ssl = link_abi_obj_exports_marker(use, mk_ssl)));
      if ((hit_ssl !=0)) {
        labi_append_openssl_ld_flags(argv, i, argv_cap);
        return 1;
      }
      int32_t hit_mb = 0;
      (void)((hit_mb = link_abi_obj_exports_marker(use, mk_mb)));
      if ((hit_mb !=0)) {
        labi_append_mbedtls_ld_flags(argv, i, argv_cap);
        return 1;
      }
    }
  }
  if ((repo_root ==0)) {
    return 0;
  }
  if ((((repo_root)[0] ==0))) {
    return 0;
  }
  uint8_t * rel_ssl = labi_rel_tls_openssl_o();
  uint8_t * tls_ssl = ((uint8_t *)(0));
  (void)((tls_ssl = shux_rel_o_path_from_argv0(repo_root, rel_ssl)));
  if ((tls_ssl !=0)) {
    if ((((tls_ssl)[0] !=0))) {
      uint8_t * use2 = tls_ssl;
      uint8_t abs_s[4096];
      uint8_t * rs = ((uint8_t *)(0));
      (void)((rs = link_abi_realpath_cap(tls_ssl, &((abs_s)[0]))));
      if ((rs !=0)) {
        use2 = rs;
      }
      int32_t hit2 = 0;
      (void)((hit2 = link_abi_obj_exports_marker(use2, mk_ssl)));
      if ((hit2 !=0)) {
        int32_t _p = 0;
        (void)((_p = invoke_cc_argv_push_existing(argv, i, argv_cap, tls_ssl)));
        labi_append_openssl_ld_flags(argv, i, argv_cap);
        return 1;
      }
    }
  }
  uint8_t * rel_mb = labi_rel_tls_mbedtls_o();
  uint8_t * tls_mb = ((uint8_t *)(0));
  (void)((tls_mb = shux_rel_o_path_from_argv0(repo_root, rel_mb)));
  if ((tls_mb !=0)) {
    if ((((tls_mb)[0] !=0))) {
      uint8_t * use3 = tls_mb;
      uint8_t abs_m[4096];
      uint8_t * rm = ((uint8_t *)(0));
      (void)((rm = link_abi_realpath_cap(tls_mb, &((abs_m)[0]))));
      if ((rm !=0)) {
        use3 = rm;
      }
      int32_t hit3 = 0;
      (void)((hit3 = link_abi_obj_exports_marker(use3, mk_mb)));
      if ((hit3 !=0)) {
        int32_t _p2 = 0;
        (void)((_p2 = invoke_cc_argv_push_existing(argv, i, argv_cap, tls_mb)));
        labi_append_mbedtls_ld_flags(argv, i, argv_cap);
        return 1;
      }
    }
  }
  return 0;
}
