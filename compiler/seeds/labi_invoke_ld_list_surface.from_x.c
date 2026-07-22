/* seeds/labi_invoke_ld_list_surface.from_x.c
 * G-02f labi_invoke_ld_list R2 full surface — isomorphic with src/runtime/labi_invoke_ld_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_invoke_ld_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (brew/compress/tail/driver pure table
 *   + wave152 ld_append_brew_lib_paths pure orch
 *   + wave153 asm_ld_append_compress_libs pure orch
 *   + wave154 invoke_cc_append_compress_ld pure orch
 *   + wave156 shux_asm_ld_append_mach_tail_libs_impl pure orch)
 * Cap residual: host_is_apple; needs + ensure + path; push_existing; spawn/ld/cc IO mega
 * Regen: ./shux_asm -E ... src/runtime/labi_invoke_ld_list.x | filter DBG + polish prologue
 * PLATFORM: SHARED - symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern int32_t link_abi_host_is_apple(void);
extern int32_t link_abi_obj_needs_zlib(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_zstd(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_brotli(uint8_t * obj_o);
extern int32_t link_abi_user_o_needs_compress_libs(uint8_t * user_o);
extern int32_t shux_ensure_runtime_compress_zlib_glue_o(uint8_t * argv0);
extern uint8_t * shux_runtime_compress_zlib_glue_o_path(uint8_t * argv0);
extern int32_t invoke_cc_argv_push_existing(uint8_t * * argv, int32_t * ia, int32_t max_ia, uint8_t * path);
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