/* seeds/labi_freestanding_list_surface.from_x.c
 * G-02f labi_freestanding_list R2 full surface — isomorphic with src/runtime/labi_freestanding_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_freestanding_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (env/io/ensure + wave117 heap/nostdlib + wave136/137 gen needs pure)
 * Cap residual: ensure/cc/spawn IO + contains_substr/undef_sym probes in mega
 * Regen: ./shux_asm -E ... src/runtime/labi_freestanding_list.x | filter DBG + polish prologue
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern int32_t link_abi_generated_c_contains_substr(uint8_t * c_path, uint8_t * needle);
extern int32_t shux_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym);
extern uint8_t * labi_fs_env_freestanding(void);
extern int32_t labi_fs_io_sym_count(void);
extern uint8_t * labi_fs_io_sym_at(int32_t i);
extern uint8_t * labi_fs_panic_sym(void);
extern int32_t labi_fs_ensure_catalog_count(void);
extern int32_t labi_fs_ensure_catalog_step_at(int32_t i, size_t * stem_out, size_t * out_base_out, size_t * src_rel_out);
extern uint8_t * labi_fs_ensure_out_base(int32_t i);
extern uint8_t * labi_fs_ensure_src_rel(int32_t i);
extern uint8_t * labi_fs_ensure_stem(int32_t i);
extern uint8_t * labi_fs_crt0_out_base(void);
extern uint8_t * labi_fs_crt0_src_rel(void);
extern uint8_t * labi_fs_io_out_base(void);
extern uint8_t * labi_fs_io_src_rel(void);
extern int32_t labi_fs_heap_c_needle_count(void);
extern uint8_t * labi_fs_heap_c_needle_at(int32_t i);
extern int32_t labi_fs_heap_o_sym_count(void);
extern uint8_t * labi_fs_heap_o_sym_at(int32_t i);
extern int32_t labi_fs_memcpy_face_sym_count(void);
extern uint8_t * labi_fs_memcpy_face_sym_at(int32_t i);
extern int32_t link_abi_generated_c_needs_libc_heap(uint8_t * c_path);
extern int32_t link_abi_user_o_needs_libc_heap(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_freestanding_nostdlib_face(uint8_t * user_o);
extern int32_t labi_fs_gen_fs_needle_count(void);
extern uint8_t * labi_fs_gen_fs_needle_at(int32_t i);
extern int32_t labi_fs_gen_random_needle_count(void);
extern uint8_t * labi_fs_gen_random_needle_at(int32_t i);
extern int32_t labi_fs_gen_time_needle_count(void);
extern uint8_t * labi_fs_gen_time_needle_at(int32_t i);
extern int32_t labi_fs_gen_runtime_needle_count(void);
extern uint8_t * labi_fs_gen_runtime_needle_at(int32_t i);
extern int32_t link_abi_generated_c_needs_fs(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_random(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_time(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_runtime(uint8_t * c_path);
extern int32_t labi_fs_gen_zlib_needle_count(void);
extern uint8_t * labi_fs_gen_zlib_needle_at(int32_t i);
extern int32_t labi_fs_gen_zstd_needle_count(void);
extern uint8_t * labi_fs_gen_zstd_needle_at(int32_t i);
extern int32_t labi_fs_gen_brotli_needle_count(void);
extern uint8_t * labi_fs_gen_brotli_needle_at(int32_t i);
extern int32_t link_abi_generated_c_needs_zlib(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_zstd(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_brotli(uint8_t * c_path);
uint8_t * labi_fs_env_freestanding(void) {
  uint8_t * p = ((uint8_t *)"\x53\x48\x55\x58\x5f\x46\x52\x45\x45\x53\x54\x41\x4e\x44\x49\x4e\x47");
  return p;
}
int32_t labi_fs_io_sym_count(void) {
  return 13;
}
uint8_t * labi_fs_io_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x72\x65\x61\x64");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x63\x6c\x6f\x73\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x65\x78\x69\x74");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6f\x70\x65\x6e");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6f\x70\x65\x6e\x61\x74");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6d\x6d\x61\x70");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6d\x75\x6e\x6d\x61\x70");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x73\x6f\x63\x6b\x65\x74");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x63\x6f\x6e\x6e\x65\x63\x74");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x62\x69\x6e\x64");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x6c\x69\x73\x74\x65\x6e");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x79\x73\x5f\x61\x63\x63\x65\x70\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_panic_sym(void) {
  uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x70\x61\x6e\x69\x63\x5f");
  return p;
}
int32_t labi_fs_ensure_catalog_count(void) {
  return 2;
}
int32_t labi_fs_ensure_catalog_step_at(int32_t i, size_t * stem_out, size_t * out_base_out, size_t * src_rel_out) {
  if ((i < 0)) {
    return 0;
  }
  if ((i >=2)) {
    return 0;
  }
  if ((i ==0)) {
    if ((stem_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72");
      (void)(((stem_out)[0] = ((size_t)(p))));
    }
    if ((out_base_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
      (void)(((out_base_out)[0] = ((size_t)(p))));
    }
    if ((src_rel_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
      (void)(((src_rel_out)[0] = ((size_t)(p))));
    }
    return 1;
  }
  if ((i ==1)) {
    if ((stem_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f");
      (void)(((stem_out)[0] = ((size_t)(p))));
    }
    if ((out_base_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
      (void)(((out_base_out)[0] = ((size_t)(p))));
    }
    if ((src_rel_out !=0)) {
      uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
      (void)(((src_rel_out)[0] = ((size_t)(p))));
    }
    return 1;
  }
  return 0;
}
uint8_t * labi_fs_ensure_out_base(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_ensure_src_rel(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_ensure_stem(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_crt0_out_base(void) {
  uint8_t * p = ((uint8_t *)"\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
  return p;
}
uint8_t * labi_fs_crt0_src_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
  return p;
}
uint8_t * labi_fs_io_out_base(void) {
  uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
  return p;
}
uint8_t * labi_fs_io_src_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
  return p;
}
extern int32_t link_abi_generated_c_contains_substr(uint8_t * c_path, uint8_t * needle);
extern int32_t shux_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym);
int32_t labi_fs_heap_c_needle_count(void) {
  return 9;
}
uint8_t * labi_fs_heap_c_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x6d\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x65\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x70\x6f\x73\x69\x78\x5f\x6d\x65\x6d\x61\x6c\x69\x67\x6e");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x72\x65\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x7a\x65\x72\x6f\x65\x64\x5f\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x67\x65\x74\x65\x6e\x76");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_heap_o_sym_count(void) {
  return 6;
}
uint8_t * labi_fs_heap_o_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x6d\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x65\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x66\x72\x65\x65");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x70\x6f\x73\x69\x78\x5f\x6d\x65\x6d\x61\x6c\x69\x67\x6e");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x67\x65\x74\x65\x6e\x76");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_memcpy_face_sym_count(void) {
  return 3;
}
uint8_t * labi_fs_memcpy_face_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x6d\x65\x6d\x63\x70\x79");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x6d\x65\x6d\x63\x6d\x70");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x6d\x65\x6d\x73\x65\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_libc_heap(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_heap_c_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_heap_c_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_user_o_needs_libc_heap(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_heap_o_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_fs_heap_o_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_user_o_needs_freestanding_nostdlib_face(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((link_abi_user_o_needs_libc_heap(user_o) !=0)) {
    return 1;
  }
  int32_t n = labi_fs_memcpy_face_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_fs_memcpy_face_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fs_gen_fs_needle_count(void) {
  return 5;
}
uint8_t * labi_fs_gen_fs_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x6f\x70\x65\x6e\x5f\x72\x65\x61\x64\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x6c\x61\x73\x74\x5f\x65\x72\x72\x6f\x72\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x63\x6c\x6f\x73\x65\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x72\x65\x61\x64\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x66\x73\x5f\x77\x72\x69\x74\x65\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_random_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_random_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x6e\x67\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x5f\x62\x79\x74\x65\x73\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x75\x36\x34\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_time_needle_count(void) {
  return 10;
}
uint8_t * labi_fs_gen_time_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x74\x69\x6d\x65\x7a\x6f\x6e\x65\x5f\x73\x6d\x6f\x6b\x65");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73\x5f\x63");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x74\x69\x6d\x65\x7a\x6f\x6e\x65\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_runtime_needle_count(void) {
  return 3;
}
uint8_t * labi_fs_gen_runtime_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x72\x61\x73\x68\x5f\x65\x76\x69\x64\x65\x6e\x63\x65\x5f\x63\x6f\x6c\x6c\x65\x63\x74\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x62\x6f\x72\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_fs(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_fs_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_fs_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_random(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_random_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_random_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_time(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_time_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_time_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_runtime(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_runtime_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_runtime_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fs_gen_zlib_needle_count(void) {
  return 7;
}
uint8_t * labi_fs_gen_zlib_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x32");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x5f\x64\x65\x66\x6c\x61\x74\x65");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x5f\x69\x6e\x66\x6c\x61\x74\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x5f\x75\x6e\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x72\x65\x73\x73\x32");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x64\x65\x66\x6c\x61\x74\x65\x49\x6e\x69\x74");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x69\x6e\x66\x6c\x61\x74\x65\x49\x6e\x69\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_zstd_needle_count(void) {
  return 5;
}
uint8_t * labi_fs_gen_zstd_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x64\x65\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x63\x72\x65\x61\x74\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x66\x72\x65\x65");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f\x69\x73\x45\x72\x72\x6f\x72");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fs_gen_brotli_needle_count(void) {
  return 2;
}
uint8_t * labi_fs_gen_brotli_needle_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x45\x6e\x63\x6f\x64\x65\x72");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x44\x65\x63\x6f\x64\x65\x72");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_generated_c_needs_zlib(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_zlib_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_zlib_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_zstd(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_zstd_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_zstd_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_generated_c_needs_brotli(uint8_t * c_path) {
  if ((c_path ==0)) {
    return 0;
  }
  if (((c_path)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_fs_gen_brotli_needle_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * needle = labi_fs_gen_brotli_needle_at(i);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_generated_c_contains_substr(c_path, needle)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
