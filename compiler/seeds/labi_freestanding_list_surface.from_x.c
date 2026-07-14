/* seeds/labi_freestanding_list_surface.from_x.c
 * G-02f labi_freestanding_list R2 full surface — isomorphic with src/runtime/labi_freestanding_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_freestanding_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (freestanding env/io/ensure pure table)
 * Cap residual: ensure/cc/spawn IO in mega freestanding ensure path
 * Regen: ./shux -E ... src/runtime/labi_freestanding_list.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
uint8_t * labi_fs_env_freestanding(void) {
  uint8_t * p = (uint8_t[]){83, 72, 85, 88, 95, 70, 82, 69, 69, 83, 84, 65, 78, 68, 73, 78, 71, 0 };
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
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 119, 114, 105, 116, 101, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 114, 101, 97, 100, 0 };
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 99, 108, 111, 115, 101, 0 };
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 101, 120, 105, 116, 0 };
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 111, 112, 101, 110, 0 };
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 111, 112, 101, 110, 97, 116, 0 };
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 109, 109, 97, 112, 0 };
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 109, 117, 110, 109, 97, 112, 0 };
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 115, 111, 99, 107, 101, 116, 0 };
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 99, 111, 110, 110, 101, 99, 116, 0 };
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 98, 105, 110, 100, 0 };
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 108, 105, 115, 116, 101, 110, 0 };
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 115, 121, 115, 95, 97, 99, 99, 101, 112, 116, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_panic_sym(void) {
  uint8_t * p = (uint8_t[]){115, 104, 117, 120, 95, 112, 97, 110, 105, 99, 95, 0 };
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
    if ((stem_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 114, 116, 48, 95, 117, 115, 101, 114, 0 };
      (void)(((stem_out)[0] = ((size_t)(p))));
    }
    if ((out_base_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 114, 116, 48, 95, 117, 115, 101, 114, 46, 111, 0 };
      (void)(((out_base_out)[0] = ((size_t)(p))));
    }
    if ((src_rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 114, 99, 47, 97, 115, 109, 47, 99, 114, 116, 48, 95, 117, 115, 101, 114, 95, 120, 56, 54, 95, 54, 52, 46, 115, 0 };
      (void)(((src_rel_out)[0] = ((size_t)(p))));
    }
    return 1;
  }
  if ((i ==1)) {
    if ((stem_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 0 };
      (void)(((stem_out)[0] = ((size_t)(p))));
    }
    if ((out_base_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 46, 111, 0 };
      (void)(((out_base_out)[0] = ((size_t)(p))));
    }
    if ((src_rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 114, 99, 47, 97, 115, 109, 47, 102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 95, 120, 56, 54, 95, 54, 52, 46, 115, 0 };
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
    uint8_t * p = (uint8_t[]){99, 114, 116, 48, 95, 117, 115, 101, 114, 46, 111, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 46, 111, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_ensure_src_rel(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){115, 114, 99, 47, 97, 115, 109, 47, 99, 114, 116, 48, 95, 117, 115, 101, 114, 95, 120, 56, 54, 95, 54, 52, 46, 115, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){115, 114, 99, 47, 97, 115, 109, 47, 102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 95, 120, 56, 54, 95, 54, 52, 46, 115, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_ensure_stem(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = (uint8_t[]){99, 114, 116, 48, 95, 117, 115, 101, 114, 0 };
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = (uint8_t[]){102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_fs_crt0_out_base(void) {
  uint8_t * p = (uint8_t[]){99, 114, 116, 48, 95, 117, 115, 101, 114, 46, 111, 0 };
  return p;
}
uint8_t * labi_fs_crt0_src_rel(void) {
  uint8_t * p = (uint8_t[]){115, 114, 99, 47, 97, 115, 109, 47, 99, 114, 116, 48, 95, 117, 115, 101, 114, 95, 120, 56, 54, 95, 54, 52, 46, 115, 0 };
  return p;
}
uint8_t * labi_fs_io_out_base(void) {
  uint8_t * p = (uint8_t[]){102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 46, 111, 0 };
  return p;
}
uint8_t * labi_fs_io_src_rel(void) {
  uint8_t * p = (uint8_t[]){115, 114, 99, 47, 97, 115, 109, 47, 102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 95, 105, 111, 95, 120, 56, 54, 95, 54, 52, 46, 115, 0 };
  return p;
}
