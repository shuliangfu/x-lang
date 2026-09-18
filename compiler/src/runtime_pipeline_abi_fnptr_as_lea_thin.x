// Thin pure: Cap-fn-ptr EXPR_AS peer (wave507).
// G.7: part of pipeline_asm_emit_as_elf_impl cast/fnptr path (peer-flat).
// tip BB budget: monolith tip T001/CG002 after i→f32 i64mov; single-arm
//   peers tipU-complete; gate→cast_orch→sub-orch→arms→lea.
// PRODUCT: BOTH tip PREFER (stamp w507).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_module_func_index_by_name_c(mod: *u8, name: *u8, name_len: i32): i32;
export extern function pipe_modlet_lea_fn_sym_to_rax(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32;

/**
 * Cap-fn-ptr LEA or fallback emit_expr.
 * Locals (stack slot) win over same-named funcs.
 * PLATFORM: SHARED · MACOS Mach-O '_' · LINUX ELF bare (spell in pipe_modlet).
 */
#[no_mangle]
export function glue_emit_as_fnptr_or_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32 {
  let fnptr_vname: u8[256] = [];
  unsafe {
    if ((pipeline_type_kind_ord_at(arena, tgt) == 9 || pipeline_type_kind_ord_at(arena, tgt) == 18)
        && pipeline_expr_kind_ord_at(arena, op) == 3) {
      if (glue_var_expr_stack_off_elf_c(arena, ctx, op) < 0) {
        if (pipeline_expr_var_name_len(arena, op) > 0 && pipeline_expr_var_name_len(arena, op) < 256) {
          pipeline_expr_var_name_into(arena, op, &fnptr_vname[0]);
          if (glue_emit_module_from_ctx(ctx) != (0 as *u8)) {
            if (glue_module_func_index_by_name_c(glue_emit_module_from_ctx(ctx), &fnptr_vname[0], pipeline_expr_var_name_len(arena, op)) >= 0) {
              return pipe_modlet_lea_fn_sym_to_rax(elf_ctx, &fnptr_vname[0], pipeline_expr_var_name_len(arena, op), ta);
            }
          }
        }
      }
    }
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
  }
}
