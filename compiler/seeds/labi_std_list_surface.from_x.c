/* seeds/labi_std_list_surface.from_x.c
 * G-02f labi_std_list R2 full surface — isomorphic with src/runtime/labi_std_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_std_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (59-step std ld plan pure table)
 * Cap residual: IO/ensure/push in mega shux_asm_ld_append_std_objs
 * Regen: ./shux -E ... src/runtime/labi_std_list.x | tail -n +8 (skip extern decls)
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
int32_t labi_std_plan_count(void) {
  return 59;
}
int32_t labi_std_plan_step_at(int32_t i, int32_t * op_out, size_t * rel_out, int32_t * flag_kind_out) {
  if ((i < 0)) {
    return 0;
  }
  if ((i >=59)) {
    return 0;
  }
  if ((i ==0)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 2));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 97, 115, 109, 95, 105, 111, 95, 115, 116, 117, 98, 115, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==1)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 112, 114, 111, 99, 101, 115, 115, 47, 112, 114, 111, 99, 101, 115, 115, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 1));
    }
    return 1;
  }
  if ((i ==2)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 116, 114, 105, 110, 103, 47, 115, 116, 114, 105, 110, 103, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==3)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 112, 97, 116, 104, 47, 112, 97, 116, 104, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==4)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 114, 117, 110, 116, 105, 109, 101, 47, 114, 117, 110, 116, 105, 109, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==5)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 3));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 112, 97, 110, 105, 99, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==6)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 104, 114, 101, 97, 100, 47, 116, 104, 114, 101, 97, 100, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 2));
    }
    return 1;
  }
  if ((i ==7)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 10));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 116, 104, 114, 101, 97, 100, 95, 103, 108, 117, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==8)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 4));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 116, 105, 109, 101, 95, 111, 115, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==9)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 105, 109, 101, 47, 116, 105, 109, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==10)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 5));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 114, 97, 110, 100, 111, 109, 95, 102, 105, 108, 108, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==11)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 114, 97, 110, 100, 111, 109, 47, 114, 97, 110, 100, 111, 109, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==12)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 6));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 101, 110, 118, 95, 111, 115, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==13)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 110, 118, 47, 101, 110, 118, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==14)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 121, 110, 99, 47, 115, 121, 110, 99, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 3));
    }
    return 1;
  }
  if ((i ==15)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 11));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 115, 121, 110, 99, 95, 108, 111, 99, 107, 95, 100, 105, 97, 103, 95, 116, 108, 115, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==16)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 110, 99, 111, 100, 105, 110, 103, 47, 101, 110, 99, 111, 100, 105, 110, 103, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==17)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 98, 97, 115, 101, 54, 52, 47, 98, 97, 115, 101, 54, 52, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==18)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 114, 121, 112, 116, 111, 47, 99, 114, 121, 112, 116, 111, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 4));
    }
    return 1;
  }
  if ((i ==19)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 12));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 101, 100, 50, 53, 53, 49, 57, 95, 114, 101, 102, 49, 48, 95, 103, 108, 117, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==20)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 108, 111, 103, 47, 108, 111, 103, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 5));
    }
    return 1;
  }
  if ((i ==21)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 13));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 108, 111, 103, 95, 111, 115, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==22)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 97, 116, 111, 109, 105, 99, 47, 97, 116, 111, 109, 105, 99, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 6));
    }
    return 1;
  }
  if ((i ==23)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 14));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 97, 116, 111, 109, 105, 99, 95, 103, 108, 117, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==24)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 104, 97, 110, 110, 101, 108, 47, 99, 104, 97, 110, 110, 101, 108, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 7));
    }
    return 1;
  }
  if ((i ==25)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 15));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 99, 104, 97, 110, 110, 101, 108, 95, 103, 108, 117, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==26)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 98, 97, 99, 107, 116, 114, 97, 99, 101, 47, 98, 97, 99, 107, 116, 114, 97, 99, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 8));
    }
    return 1;
  }
  if ((i ==27)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 16));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 98, 97, 99, 107, 116, 114, 97, 99, 101, 95, 112, 108, 97, 116, 102, 111, 114, 109, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==28)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 104, 97, 115, 104, 47, 104, 97, 115, 104, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==29)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 109, 97, 116, 104, 47, 109, 97, 116, 104, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 9));
    }
    return 1;
  }
  if ((i ==30)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 17));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 109, 97, 116, 104, 95, 108, 105, 98, 109, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==31)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 111, 114, 116, 47, 115, 111, 114, 116, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==32)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 102, 102, 105, 47, 102, 102, 105, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==33)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 98, 47, 115, 113, 108, 105, 116, 101, 47, 115, 113, 108, 105, 116, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 10));
    }
    return 1;
  }
  if ((i ==34)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 18));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 115, 113, 108, 105, 116, 101, 95, 103, 108, 117, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==35)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 108, 102, 47, 101, 108, 102, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 11));
    }
    return 1;
  }
  if ((i ==36)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 106, 115, 111, 110, 47, 106, 115, 111, 110, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==37)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 115, 118, 47, 99, 115, 118, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==38)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 114, 101, 103, 101, 120, 47, 114, 101, 103, 101, 120, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==39)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 117, 110, 105, 99, 111, 100, 101, 47, 117, 110, 105, 99, 111, 100, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==40)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 121, 110, 108, 105, 98, 47, 100, 121, 110, 108, 105, 98, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 12));
    }
    return 1;
  }
  if ((i ==41)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 19));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 100, 121, 110, 108, 105, 98, 95, 111, 115, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==42)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 104, 116, 116, 112, 47, 104, 116, 116, 112, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 13));
    }
    return 1;
  }
  if ((i ==43)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 20));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){99, 111, 109, 112, 105, 108, 101, 114, 47, 114, 117, 110, 116, 105, 109, 101, 95, 104, 116, 116, 112, 95, 103, 108, 117, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==44)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 111, 99, 107, 101, 116, 105, 111, 47, 115, 111, 99, 107, 101, 116, 105, 111, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==45)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 97, 114, 47, 116, 97, 114, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==46)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 105, 109, 100, 47, 115, 105, 109, 100, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==47)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 111, 110, 116, 101, 120, 116, 47, 99, 111, 110, 116, 101, 120, 116, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==48)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 114, 114, 111, 114, 47, 101, 114, 114, 111, 114, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==49)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 97, 116, 101, 116, 105, 109, 101, 47, 100, 97, 116, 101, 116, 105, 109, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==50)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 117, 117, 105, 100, 47, 117, 117, 105, 100, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==51)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 117, 114, 108, 47, 117, 114, 108, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==52)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 108, 105, 47, 99, 108, 105, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==53)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 101, 99, 117, 114, 105, 116, 121, 47, 115, 101, 99, 117, 114, 105, 116, 121, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==54)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 111, 110, 102, 105, 103, 47, 99, 111, 110, 102, 105, 103, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==55)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 97, 99, 104, 101, 47, 99, 97, 99, 104, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==56)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 114, 97, 99, 101, 47, 116, 114, 97, 99, 101, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  /* PLATFORM: SHARED — std/vec/vec.o (link_only product path). */
  if ((i ==57)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 1));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 118, 101, 99, 47, 118, 101, 99, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  if ((i ==58)) {
    if ((op_out !=((int32_t *)(0)))) {
      (void)(((op_out)[0] = 30));
    }
    if ((rel_out !=((size_t *)(0)))) {
      uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 97, 115, 107, 47, 116, 97, 115, 107, 46, 111, 0 };
      (void)(((rel_out)[0] = ((size_t)(p))));
    }
    if ((flag_kind_out !=((int32_t *)(0)))) {
      (void)(((flag_kind_out)[0] = 0));
    }
    return 1;
  }
  return 0;
}
int32_t labi_std_default_std_rel_count(void) {
  return 42;
}
uint8_t * labi_std_default_std_rel_at(int32_t j) {
  if ((j < 0)) {
    return ((uint8_t *)(0));
  }
  if ((j ==0)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 112, 114, 111, 99, 101, 115, 115, 47, 112, 114, 111, 99, 101, 115, 115, 46, 111, 0 };
    return p;
  }
  if ((j ==1)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 116, 114, 105, 110, 103, 47, 115, 116, 114, 105, 110, 103, 46, 111, 0 };
    return p;
  }
  if ((j ==2)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 112, 97, 116, 104, 47, 112, 97, 116, 104, 46, 111, 0 };
    return p;
  }
  if ((j ==3)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 114, 117, 110, 116, 105, 109, 101, 47, 114, 117, 110, 116, 105, 109, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==4)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 104, 114, 101, 97, 100, 47, 116, 104, 114, 101, 97, 100, 46, 111, 0 };
    return p;
  }
  if ((j ==5)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 105, 109, 101, 47, 116, 105, 109, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==6)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 114, 97, 110, 100, 111, 109, 47, 114, 97, 110, 100, 111, 109, 46, 111, 0 };
    return p;
  }
  if ((j ==7)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 110, 118, 47, 101, 110, 118, 46, 111, 0 };
    return p;
  }
  if ((j ==8)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 121, 110, 99, 47, 115, 121, 110, 99, 46, 111, 0 };
    return p;
  }
  if ((j ==9)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 110, 99, 111, 100, 105, 110, 103, 47, 101, 110, 99, 111, 100, 105, 110, 103, 46, 111, 0 };
    return p;
  }
  if ((j ==10)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 98, 97, 115, 101, 54, 52, 47, 98, 97, 115, 101, 54, 52, 46, 111, 0 };
    return p;
  }
  if ((j ==11)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 114, 121, 112, 116, 111, 47, 99, 114, 121, 112, 116, 111, 46, 111, 0 };
    return p;
  }
  if ((j ==12)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 108, 111, 103, 47, 108, 111, 103, 46, 111, 0 };
    return p;
  }
  if ((j ==13)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 97, 116, 111, 109, 105, 99, 47, 97, 116, 111, 109, 105, 99, 46, 111, 0 };
    return p;
  }
  if ((j ==14)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 104, 97, 110, 110, 101, 108, 47, 99, 104, 97, 110, 110, 101, 108, 46, 111, 0 };
    return p;
  }
  if ((j ==15)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 98, 97, 99, 107, 116, 114, 97, 99, 101, 47, 98, 97, 99, 107, 116, 114, 97, 99, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==16)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 104, 97, 115, 104, 47, 104, 97, 115, 104, 46, 111, 0 };
    return p;
  }
  if ((j ==17)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 109, 97, 116, 104, 47, 109, 97, 116, 104, 46, 111, 0 };
    return p;
  }
  if ((j ==18)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 111, 114, 116, 47, 115, 111, 114, 116, 46, 111, 0 };
    return p;
  }
  if ((j ==19)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 102, 102, 105, 47, 102, 102, 105, 46, 111, 0 };
    return p;
  }
  if ((j ==20)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 98, 47, 115, 113, 108, 105, 116, 101, 47, 115, 113, 108, 105, 116, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==21)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 108, 102, 47, 101, 108, 102, 46, 111, 0 };
    return p;
  }
  if ((j ==22)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 106, 115, 111, 110, 47, 106, 115, 111, 110, 46, 111, 0 };
    return p;
  }
  if ((j ==23)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 115, 118, 47, 99, 115, 118, 46, 111, 0 };
    return p;
  }
  if ((j ==24)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 114, 101, 103, 101, 120, 47, 114, 101, 103, 101, 120, 46, 111, 0 };
    return p;
  }
  if ((j ==25)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 117, 110, 105, 99, 111, 100, 101, 47, 117, 110, 105, 99, 111, 100, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==26)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 121, 110, 108, 105, 98, 47, 100, 121, 110, 108, 105, 98, 46, 111, 0 };
    return p;
  }
  if ((j ==27)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 104, 116, 116, 112, 47, 104, 116, 116, 112, 46, 111, 0 };
    return p;
  }
  if ((j ==28)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 111, 99, 107, 101, 116, 105, 111, 47, 115, 111, 99, 107, 101, 116, 105, 111, 46, 111, 0 };
    return p;
  }
  if ((j ==29)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 97, 114, 47, 116, 97, 114, 46, 111, 0 };
    return p;
  }
  if ((j ==30)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 105, 109, 100, 47, 115, 105, 109, 100, 46, 111, 0 };
    return p;
  }
  if ((j ==31)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 111, 110, 116, 101, 120, 116, 47, 99, 111, 110, 116, 101, 120, 116, 46, 111, 0 };
    return p;
  }
  if ((j ==32)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 101, 114, 114, 111, 114, 47, 101, 114, 114, 111, 114, 46, 111, 0 };
    return p;
  }
  if ((j ==33)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 100, 97, 116, 101, 116, 105, 109, 101, 47, 100, 97, 116, 101, 116, 105, 109, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==34)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 117, 117, 105, 100, 47, 117, 117, 105, 100, 46, 111, 0 };
    return p;
  }
  if ((j ==35)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 117, 114, 108, 47, 117, 114, 108, 46, 111, 0 };
    return p;
  }
  if ((j ==36)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 108, 105, 47, 99, 108, 105, 46, 111, 0 };
    return p;
  }
  if ((j ==37)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 115, 101, 99, 117, 114, 105, 116, 121, 47, 115, 101, 99, 117, 114, 105, 116, 121, 46, 111, 0 };
    return p;
  }
  if ((j ==38)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 111, 110, 102, 105, 103, 47, 99, 111, 110, 102, 105, 103, 46, 111, 0 };
    return p;
  }
  if ((j ==39)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 99, 97, 99, 104, 101, 47, 99, 97, 99, 104, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==40)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 116, 114, 97, 99, 101, 47, 116, 114, 97, 99, 101, 46, 111, 0 };
    return p;
  }
  if ((j ==41)) {
    uint8_t * p = (uint8_t[]){115, 116, 100, 47, 118, 101, 99, 47, 118, 101, 99, 46, 111, 0 };
    return p;
  }
  return ((uint8_t *)(0));
}
