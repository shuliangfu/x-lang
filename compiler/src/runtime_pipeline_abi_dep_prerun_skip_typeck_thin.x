// Thin pure override: dep prerun parse-skip-typeck for std.io.driver / std.net.
// rt_ab_step_prerun sends those dep paths here (xlang_asm_user_dep_parse_skip_typeck_path)
// to parse the dep module through the x pipeline with typeck and codegen off.
// The Darwin leftover pabi carries 8-byte `mov w0,#0; ret` copies of both names
// (Class BR compaction treated them as always-miss predicates). They return
// success without parsing, so the dep slot keeps an empty module and every
// `driver.f()` in the importer fails typeck with T001 (std/fs/mod.x
// driver.submit_read_batch). g05_relink_env.sh compiles this with the current
// product (pure asm, no host cc) and links it ahead of the weak pabi copies.
// G.7: bodies match runtime_pipeline_abi.x
//   xlang_pipeline_dep_prerun_parse_skip_typeck_impl / _parse_skip_typeck.
// PLATFORM: SHARED freestanding body · MACOS|DARWIN sidecar (Linux pabi keeps
// the real body).

export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_check_only_set(v: i32): void;
export extern "C" function driver_pipeline_dep_ctx_get_asm_entry_module_only(ctx: *u8): i32;
export extern "C" function driver_pipeline_dep_ctx_set_asm_entry_module_only(ctx: *u8, v: i32): void;
export extern "C" function driver_x_pipeline_skip_typeck_set(v: i32): void;
export extern "C" function driver_x_pipeline_skip_codegen_set(v: i32): void;
export extern function xlang_pipeline_run_x_pipeline_large_stack(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32;
export extern function pipeline_typeck_patch_all_body_parent_links_c(module: *u8, arena: *u8): void;

/**
 * Dep prerun body: run the x pipeline on one dep with typeck and codegen off.
 * @param dep_mod *u8 - dep AST module; caller thin already null-checked
 * @param dep_arena *u8 - dep AST arena
 * @param src *u8 - source bytes
 * @param len i64 - byte length
 * @param dep_out *u8 - optional out buffer (pipeline accepts null)
 * @param one_ctx *u8 - PipelineDepCtx; may be null (asm_entry field skipped)
 * @return i32 - pipeline ec (0 ok)
 * PLATFORM: SHARED - same flag order as runtime_pipeline_abi.x.
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  unsafe {
    let saved: i32 = driver_check_only_get();
    let saved_entry_only: i32 = 0;
    driver_check_only_set(1);
    if (one_ctx != 0 as *u8) {
      saved_entry_only = driver_pipeline_dep_ctx_get_asm_entry_module_only(one_ctx);
      driver_pipeline_dep_ctx_set_asm_entry_module_only(one_ctx, 1);
    }
    driver_x_pipeline_skip_typeck_set(1);
    driver_x_pipeline_skip_codegen_set(1);
    let ec: i32 = xlang_pipeline_run_x_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    if (ec == 0) {
      // Dep prerun skips typeck, so block parent links stay unbound in the
      // dep arena; emit-time scope walks need them. PLATFORM: SHARED.
      pipeline_typeck_patch_all_body_parent_links_c(dep_mod, dep_arena);
    }
    driver_x_pipeline_skip_codegen_set(0);
    driver_x_pipeline_skip_typeck_set(0);
    if (one_ctx != 0 as *u8) {
      driver_pipeline_dep_ctx_set_asm_entry_module_only(one_ctx, saved_entry_only);
    }
    if (saved != 0) {
      driver_check_only_set(1);
    } else {
      driver_check_only_set(0);
    }
    return ec;
  }
  return 0 - 1;
}

/**
 * Thin gate for dep prerun parse-skip-typeck (null / empty source rejected).
 * @param dep_mod *u8 - dep AST module; null -> -1
 * @param dep_arena *u8 - dep AST arena; null -> -1
 * @param src *u8 - source bytes; null -> -1
 * @param len i64 - byte length; <=0 -> -1
 * @param dep_out *u8 - optional out buffer
 * @param one_ctx *u8 - PipelineDepCtx; may be null
 * @return i32 - pipeline ec; -1 on reject
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function xlang_pipeline_dep_prerun_parse_skip_typeck(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  return xlang_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}
