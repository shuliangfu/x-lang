/*
 * w1032: strong first-wins overlay for pipeline_asm_compute_frame_size_c.
 *
 * Root: the mega/egg body always raised scratch to 2048, so tip-compiled
 * leaf functions got `sub $0x888` even with call_spill==0 (w1028 map).
 * Authority .x + windows_e now skip the floor when call_spill==0, and
 * w1033/w1040 use measured+64 for small call graphs (spill < 1024) while
 * keeping the 2048 floor for heavy graphs. Leaf drops the +64 trailer.
 * This sidecar ships the same body without waiting for a full egg rebuild
 * (no g05_prepare / L4).
 *
 * Link ahead of runtime_pipeline_abi.o / pabi_weak. On Windows weaken the
 * egg T in pabi_weak so PE first-wins this strong T. Darwin/Ubuntu egg
 * already expose weak W — strong overlay wins without weaken.
 *
 * PLATFORM: SHARED host-cc sidecar · LINUX gold · MACOS co-path · WINDOWS.
 */
#include <stdint.h>
#include <string.h>

extern void pipe_store_ptr_slot(uint8_t *base, int32_t slot_idx, void *ptr);
extern uint8_t *pipeline_asm_emit_ctx_module_get(void);
extern void pipeline_asm_emit_ctx_module_set(uint8_t *mod);
extern void asm_ctx_local_reset(uint8_t *ctx);
extern int32_t pipeline_asm_host_is_arm64_c(void);
extern int32_t glue_func_param_home_width_c(uint8_t *arena, uint8_t *mod, int32_t func_index,
                                            int32_t pi);
extern int32_t glue_func_return_byte_size_c(uint8_t *mod, uint8_t *arena, int32_t func_index);
extern int32_t pipeline_asm_hoist_target_func_index(uint8_t *mod);
extern int32_t pipeline_asm_sum_module_top_level_lets_stack(uint8_t *arena, uint8_t *mod,
                                                           int32_t next_off);
extern void asm_ctx_fill_locals_block_tree(uint8_t *ctx, uint8_t *arena, int32_t block_ref,
                                           int32_t *next_off, int32_t *num_loc);
extern int32_t asm_sum_block_array_temp_bytes(uint8_t *arena, int32_t block_ref);
extern int32_t glue_asm_sum_block_call_spill_bytes(uint8_t *arena, int32_t block_ref);
extern int32_t asm_sum_block_wa_temp_bytes(uint8_t *arena, int32_t block_ref);
extern int32_t glue_sum_block_slice_reent_dc_bytes_c(uint8_t *arena, int32_t block_ref);

/**
 * Compute total frame size for a function prologue (w1032 leaf floor skip).
 * PLATFORM: SHARED — mirrors runtime_pipeline_abi.x authority.
 */
int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, uint8_t *arena, int32_t block_ref,
                                          uint8_t *mod, int32_t func_index) {
  uint8_t ctx_buf[256];
  int32_t next_off = 16;
  int32_t num_loc = 0;
  int32_t size = 0;
  int32_t arr_temp = 0;
  int32_t call_spill = 0;
  int32_t scratch = 0;
  uint8_t *prev_mod = 0;
  int32_t wa_temp = 0;
  int32_t reent_dc = 0;
  int32_t is_arm = 0;
  int32_t pi = 0;
  int32_t w = 0;
  int32_t ret_sz = 0;
  int32_t hoist = 0;
  if (arena == 0 || block_ref <= 0) {
    return 64;
  }
  memset(&ctx_buf[0], 0, 128);
  pipe_store_ptr_slot(&ctx_buf[0], 2, mod);
  prev_mod = pipeline_asm_emit_ctx_module_get();
  pipeline_asm_emit_ctx_module_set(mod);
  asm_ctx_local_reset(&ctx_buf[0]);
  is_arm = pipeline_asm_host_is_arm64_c();
  if (num_params > 0 && mod != 0 && func_index >= 0) {
    pi = 0;
    while (pi < num_params) {
      w = glue_func_param_home_width_c(arena, mod, func_index, pi);
      if (is_arm != 0) {
        if (w > 8) {
          next_off = next_off + w;
        } else {
          next_off = next_off + 8;
        }
      } else {
        if (w > 8) {
          next_off = next_off + w + 8;
        } else {
          next_off = next_off + 8;
        }
      }
      pi = pi + 1;
    }
  } else if (num_params > 0) {
    next_off = 16 + num_params * 8;
  }
  if (mod != 0 && func_index >= 0) {
    ret_sz = glue_func_return_byte_size_c(mod, arena, func_index);
    if (ret_sz > 16) {
      next_off = next_off + 8;
    }
    hoist = pipeline_asm_hoist_target_func_index(mod);
    if (func_index != hoist) {
      next_off = pipeline_asm_sum_module_top_level_lets_stack(arena, mod, next_off);
    }
  }
  num_loc = 0;
  asm_ctx_fill_locals_block_tree(&ctx_buf[0], arena, block_ref, &next_off, &num_loc);
  arr_temp = asm_sum_block_array_temp_bytes(arena, block_ref);
  call_spill = glue_asm_sum_block_call_spill_bytes(arena, block_ref);
  pipeline_asm_emit_ctx_module_set(prev_mod);
  wa_temp = asm_sum_block_wa_temp_bytes(arena, block_ref);
  reent_dc = glue_sum_block_slice_reent_dc_bytes_c(arena, block_ref);
  size = next_off + arr_temp + wa_temp + reent_dc;
  if (size > 0) {
    int32_t rem = size % 16;
    if (rem != 0) {
      size = size + (16 - rem);
    }
  }
  scratch = call_spill;
  /* w1032/w1033/w1040/w1041/w1042: leaf=0; heavy (>=1024)→2048 floor.
   * w1040: small pad 256→64; leaf drops unconditional +64 trailer.
   * w1041: call_spill overlay budgets (n+1)*8.
   * w1042: small spill (<256) uses measured only — no +64 pad / +64
   * trailer. Tip emit_call trampoline was forced to sub $0xf8 largely by
   * those two 64B safety cushions on a (5+1)*8=48 spill; host thin is
   * sub $0x30. Medium spill (256..1023) keeps pad+trailer. */
  if (call_spill > 0) {
    if (call_spill >= 1024) {
      if (scratch < 2048) {
        scratch = 2048;
      }
    } else if (call_spill >= 256) {
      scratch = call_spill + 64;
    }
    /* else: scratch = call_spill (no pad) */
  }
  size = size + scratch;
  if (call_spill >= 256) {
    return size + 64;
  }
  return size;
}
