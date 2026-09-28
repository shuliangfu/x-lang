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
extern void asm_ctx_ensure_block_locals(uint8_t *ctx, uint8_t *arena, int32_t block_ref,
                                        int32_t *next_off, int32_t *num_loc);
extern int32_t ast_ast_block_num_loops(uint8_t *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_for_loops(uint8_t *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(uint8_t *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_regions(uint8_t *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(uint8_t *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_expr_stmts(uint8_t *arena, int32_t block_ref);
extern int32_t ast_ast_block_final_expr_ref(uint8_t *arena, int32_t block_ref);
extern int32_t pipeline_block_while_body_ref(uint8_t *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_for_body_ref(uint8_t *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_if_then_body_ref(uint8_t *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_if_else_body_ref(uint8_t *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_region_body_ref(uint8_t *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_let_init_ref(uint8_t *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_expr_stmt_ref(uint8_t *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_block_ref_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_num_arms_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_result_ref(uint8_t *arena, int32_t expr_ref, int32_t i);

/*
 * w1490: expression-nested blocks for frame sizing.
 *
 * Root: asm_ctx_fill_locals_block_tree only follows block-level children
 * (while/for bodies, if-STMT then/else, regions). A block-final `if` is
 * converted by the parser into an EXPR_IF held in final_expr_ref
 * (if_stmt_parts_to_if_expr), with then/else as EXPR_BLOCK. Locals in
 * those blocks (e.g. `if (a) { if (b) { let buf: u8[256]; } }`) were never
 * registered, so the prologue `sub` missed them; the emitter allocates them
 * lazily below the frame and they overwrite saved rbp/ret (Win cold
 * asm_local_var_slot_holds_indirect_ptr u8[256] ret-to-0). Hidden since
 * w1032 dropped the unconditional 2048 scratch floor.
 * Fix: walk the same tree plus EXPR_IF / EXPR_BLOCK / EXPR_MATCH arms found
 * in final_expr, expr stmts and let initializers; every block reached only
 * through such an edge (and its subtree) gets asm_ctx_ensure_block_locals.
 * PLATFORM: SHARED.
 */
#define W1490_EXPR_IF 25
#define W1490_EXPR_BLOCK 26
#define W1490_EXPR_MATCH 43
#define W1490_STACK 512
#define W1490_ESTACK 256

static int32_t w1490_blk[W1490_STACK];
static uint8_t w1490_hidden[W1490_STACK];

static int32_t w1490_push(int32_t sp, int32_t b, uint8_t hidden) {
  if (b <= 0 || sp < 0 || sp >= W1490_STACK) {
    return sp;
  }
  w1490_blk[sp] = b;
  w1490_hidden[sp] = hidden;
  return sp + 1;
}

/* Push blocks reachable from expression e through IF/BLOCK/MATCH nodes. */
static int32_t w1490_push_expr_blocks(uint8_t *arena, int32_t sp, int32_t e) {
  int32_t es[W1490_ESTACK];
  int32_t esp = 0;
  int32_t steps = 0;
  if (e <= 0) {
    return sp;
  }
  es[esp++] = e;
  while (esp > 0 && steps < 4096) {
    int32_t cur = es[--esp];
    int32_t ko;
    steps++;
    if (cur <= 0) {
      continue;
    }
    ko = pipeline_expr_kind_ord_at(arena, cur);
    if (ko == W1490_EXPR_BLOCK) {
      sp = w1490_push(sp, pipeline_expr_block_ref_at(arena, cur), 1);
    } else if (ko == W1490_EXPR_IF) {
      int32_t t = pipeline_expr_if_then_ref_at(arena, cur);
      int32_t el = pipeline_expr_if_else_ref_at(arena, cur);
      if (t > 0 && esp < W1490_ESTACK) {
        es[esp++] = t;
      }
      if (el > 0 && esp < W1490_ESTACK) {
        es[esp++] = el;
      }
    } else if (ko == W1490_EXPR_MATCH) {
      int32_t na = pipeline_expr_match_num_arms_at(arena, cur);
      int32_t ai;
      for (ai = 0; ai < na && ai < 1024; ai++) {
        int32_t r = pipeline_expr_match_arm_result_ref(arena, cur, ai);
        if (r > 0 && esp < W1490_ESTACK) {
          es[esp++] = r;
        }
      }
    }
  }
  return sp;
}

static void w1490_fill_expr_nested_locals(uint8_t *ctx, uint8_t *arena, int32_t root,
                                          int32_t *next_off, int32_t *num_loc) {
  int32_t sp = 0;
  int32_t visits = 0;
  sp = w1490_push(0, root, 0);
  while (sp > 0 && visits < 8192) {
    int32_t cur;
    uint8_t hid;
    int32_t n, i;
    sp--;
    cur = w1490_blk[sp];
    hid = w1490_hidden[sp];
    visits++;
    if (cur <= 0) {
      continue;
    }
    if (hid != 0) {
      asm_ctx_ensure_block_locals(ctx, arena, cur, next_off, num_loc);
    }
    n = ast_ast_block_num_loops(arena, cur);
    for (i = 0; i < n; i++) {
      sp = w1490_push(sp, pipeline_block_while_body_ref(arena, cur, i), hid);
    }
    n = ast_ast_block_num_for_loops(arena, cur);
    for (i = 0; i < n; i++) {
      sp = w1490_push(sp, pipeline_block_for_body_ref(arena, cur, i), hid);
    }
    n = ast_ast_block_num_if_stmts(arena, cur);
    for (i = 0; i < n; i++) {
      sp = w1490_push(sp, ast_pipeline_block_if_then_body_ref(arena, cur, i), hid);
      sp = w1490_push(sp, ast_pipeline_block_if_else_body_ref(arena, cur, i), hid);
    }
    n = ast_ast_block_num_regions(arena, cur);
    for (i = 0; i < n; i++) {
      sp = w1490_push(sp, pipeline_block_region_body_ref(arena, cur, i), hid);
    }
    n = ast_ast_block_num_lets(arena, cur);
    for (i = 0; i < n; i++) {
      sp = w1490_push_expr_blocks(arena, sp, pipeline_block_let_init_ref(arena, cur, i));
    }
    n = ast_ast_block_num_expr_stmts(arena, cur);
    for (i = 0; i < n; i++) {
      sp = w1490_push_expr_blocks(arena, sp, ast_pipeline_block_expr_stmt_ref(arena, cur, i));
    }
    sp = w1490_push_expr_blocks(arena, sp, ast_ast_block_final_expr_ref(arena, cur));
  }
}

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
  w1490_fill_expr_nested_locals(&ctx_buf[0], arena, block_ref, &next_off, &num_loc);
  arr_temp = asm_sum_block_array_temp_bytes(arena, block_ref);
  call_spill = glue_asm_sum_block_call_spill_bytes(arena, block_ref);
  /* w1484: arm64 emit gives every call temp its own 16-byte slot
   * (str x0,[x29,#off]; next_off += 16). The w1040/w1041 budget counts
   * 8 bytes per temp (x86 stride), so arm64 frames came out too small and
   * temps landed on the caller's saved x29/x30 (e.g. w189_param_at_is_type_ptr
   * sub #0xf0 storing at #0xf0/#0x100 → Darwin `-backend asm -c` SIGSEGV in
   * glue_load_var_as_value_to_rax_rdx_elf_c). Double the budget on arm64.
   * PLATFORM: MACOS|arm64 — x86_64 (Linux/Windows) unchanged. */
  if (is_arm != 0) {
    call_spill = call_spill * 2;
  }
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
  /*
   * w1047 PLATFORM: SHARED x86_64 — outgoing stack args at [rsp+0x20..]
   * alias param homes at [rbp-0x10..] when the frame is only next_off-sized.
   * Pure `return f(params)` forwarders have call_spill==0 (every arg is
   * EXPR_VAR → w157 adds 0). With 7+ formals tip stores outgoing arg5..
   * over homes → glue_emit_one_call_arg_elf_c / emit_call_with_cleanup fat
   * forwarders smash (option CG002 / si SEGV). Reserve shadow(32) +
   * 8*(num_params-4) below homes. Arm64 keeps AAPCS stack shape elsewhere.
   */
  if (is_arm == 0 && call_spill == 0 && num_params > 4) {
    int32_t n_stack = num_params - 4;
    int32_t out_need = 32 + n_stack * 8;
    int32_t min_sz = next_off + out_need;
    int32_t rem2 = min_sz % 16;
    if (rem2 != 0) {
      min_sz = min_sz + (16 - rem2);
    }
    if (size < min_sz) {
      size = min_sz;
    }
  }
  /*
   * w1043: param-home-only forwarders land at next_off==56 (16+5*8) then
   * 16-align to 64; with push rbx that becomes sub $0x48. Cap at 48 so
   * the lean prologue (no rbx, pad ≡0) emits sub $0x30 like host thin.
   * Homes at rbp-16..rbp-48 still fit. w1047: only when num_params<=4 so
   * no outgoing stack-arg stores can alias homes. PLATFORM: SHARED.
   */
  if (call_spill == 0 && arr_temp == 0 && wa_temp == 0 && reent_dc == 0 &&
      num_params <= 4 && size > 48 && size <= 64) {
    return 48;
  }
  return size;
}
