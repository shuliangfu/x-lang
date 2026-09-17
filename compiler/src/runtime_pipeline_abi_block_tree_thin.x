// Thin pure: wave302 M2 — block_tree Cap residual C→.x (was wave269 C thin).
// Faces: asm_sum_block_local_slot_bytes / asm_count_block_stack_slots /
//   asm_sum_block_array_temp_bytes / asm_sum_block_wa_temp_bytes /
//   asm_ctx_fill_locals_block_tree.
// Fixed i32[256] walk stack + visits cap 8192 (match mega/C).
// G.7: bodies match runtime_pipeline_abi.x wave269 leave.
// PRODUCT inject: -E+$CC via pipeline_abi_inject_block_tree_thin
// (ALLOW_E_REPLACE + stamp). File-local walk stack OK under -E+$CC.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function asm_local_slot_bytes(arena: *u8, type_ref: i32): i32;
export extern function asm_fixed_array_total_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32;
export extern function asm_ctx_ensure_block_locals(ctx: *u8, arena: *u8, block_ref: i32, inout_next_offset: *i32, inout_num_locals: *i32): void;
export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_while_body_ref(arena: *u8, block_ref: i32, wi: i32): i32;
export extern function pipeline_block_for_body_ref(arena: *u8, block_ref: i32, fi: i32): i32;
export extern function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32;
export extern function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;
export extern function pipeline_block_region_with_arena_cap_ref(arena: *u8, block_ref: i32, ri: i32): i32;
export extern function pipeline_block_const_type_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, i: i32): i32;

let g_w269_block_tree_stack: i32[256] = [];

/**
 * Push one block_ref onto the wave269 walk stack if capacity remains.
 * @param sp i32 - current stack length
 * @param block_ref i32 - block to visit; <=0 ignored
 * @return i32 - new stack length
 * wave269 pure helper (was static asm_block_tree_push_ref + GrowVec).
 * PLATFORM: SHARED freestanding walk stack.
 */
function pipe_block_tree_push(sp: i32, block_ref: i32): i32 {
  if (block_ref <= 0 || sp < 0 || sp >= 256) {
    return sp;
  }
  g_w269_block_tree_stack[sp] = block_ref;
  return sp + 1;
}

/**
 * Push while/for/if-then/if-else child bodies of cur onto the walk stack.
 * @param arena *u8 - ASTArena*
 * @param sp i32 - current stack length
 * @param cur i32 - parent block_ref
 * @return i32 - new stack length
 * wave269 pure helper (was static asm_block_tree_push_children).
 * PLATFORM: SHARED freestanding walk stack.
 */
function pipe_block_tree_push_children(arena: *u8, sp: i32, cur: i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let ch: i32 = 0;
  if (arena == 0 as *u8 || cur <= 0) {
    return sp;
  }
  unsafe {
    n = ast_ast_block_num_loops(arena, cur);
  }
  i = 0;
  while (i < n) {
    unsafe {
      ch = pipeline_block_while_body_ref(arena, cur, i);
    }
    sp = pipe_block_tree_push(sp, ch);
    i = i + 1;
  }
  unsafe {
    n = ast_ast_block_num_for_loops(arena, cur);
  }
  i = 0;
  while (i < n) {
    unsafe {
      ch = pipeline_block_for_body_ref(arena, cur, i);
    }
    sp = pipe_block_tree_push(sp, ch);
    i = i + 1;
  }
  unsafe {
    n = ast_ast_block_num_if_stmts(arena, cur);
  }
  i = 0;
  while (i < n) {
    unsafe {
      ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
    }
    sp = pipe_block_tree_push(sp, ch);
    unsafe {
      ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
    }
    sp = pipe_block_tree_push(sp, ch);
    i = i + 1;
  }
  return sp;
}

/**
 * Push region/with_arena child bodies of cur onto the walk stack.
 * @param arena *u8 - ASTArena*
 * @param sp i32 - current stack length
 * @param cur i32 - parent block_ref
 * @return i32 - new stack length
 * wave269 pure helper (was static asm_block_tree_push_region_children).
 * PLATFORM: SHARED freestanding walk stack.
 */
function pipe_block_tree_push_region_children(arena: *u8, sp: i32, cur: i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let ch: i32 = 0;
  if (arena == 0 as *u8 || cur <= 0) {
    return sp;
  }
  unsafe {
    n = ast_ast_block_num_regions(arena, cur);
  }
  i = 0;
  while (i < n) {
    unsafe {
      ch = pipeline_block_region_body_ref(arena, cur, i);
    }
    sp = pipe_block_tree_push(sp, ch);
    i = i + 1;
  }
  return sp;
}

/**
 * Fixed T[N] let temp-zone bytes for frame sizing (SoA/layout then esz heuristic).
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - TYPE_ARRAY type ref
 * @return i32 - temp bytes; 0 non-array/invalid
 * wave269 pure helper (was static asm_fixed_array_temp_bytes).
 * Prefers pure asm_fixed_array_total_bytes_mod (wave268); else elem esz heuristic
 * matching C twin (u8=1, f32=4, named/ptr/i64/u64=8).
 * PLATFORM: SHARED freestanding array temp layout.
 */
function pipe_fixed_array_temp_bytes(arena: *u8, type_ref: i32): i32 {
  let nt: i32 = 0;
  let ko: i32 = 0;
  let asz: i32 = 0;
  let elem_ref: i32 = 0;
  let esz: i32 = 4;
  let bytes: i32 = 0;
  let ek: i32 = 0;
  if (arena == 0 as *u8 || type_ref <= 0) {
    return 0;
  }
  unsafe {
    nt = pipeline_arena_num_types(arena);
  }
  if (type_ref > nt) {
    return 0;
  }
  unsafe {
    ko = pipeline_type_kind_ord_at(arena, type_ref);
    asz = pipeline_type_array_size_at(arena, type_ref);
    elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  }
  // TYPE_ARRAY = 10 (misuse 9 would treat as TYPE_PTR and skip temp).
  if (ko != 10 || asz <= 0) {
    return 0;
  }
  bytes = asm_fixed_array_total_bytes_mod(arena, type_ref, 0 as *u8);
  if (bytes > 0) {
    return bytes;
  }
  esz = 4;
  if (elem_ref > 0 && elem_ref <= nt) {
    unsafe {
      ek = pipeline_type_kind_ord_at(arena, elem_ref);
    }
    if (ek == 2) {
      esz = 1;
    } else {
      if (ek == 14) {
        esz = 4;
      } else {
        if (ek == 8 || ek == 4 || ek == 5 || ek == 6) {
          esz = 8;
        }
      }
    }
  }
  bytes = asz * esz;
  if (bytes > 0) {
    return bytes;
  }
  return 0;
}

/**
 * Sum const/let stack slot bytes over function body block tree (nested if/while/for/region).
 * @param arena *u8 - ASTArena*
 * @param block_ref i32 - function body (or nested) block
 * @return i32 - total slot bytes (>=0)
 * wave269 pure: G.7 single product authority (was pipeline_asm_block_tree.c).
 * PLATFORM: SHARED freestanding frame layout · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_sum_block_local_slot_bytes(arena: *u8, block_ref: i32): i32 {
  let total: i32 = 0;
  let sp: i32 = 0;
  let visits: i32 = 0;
  let cur: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let tref: i32 = 0;
  if (arena == 0 as *u8 || block_ref <= 0) {
    return 0;
  }
  sp = pipe_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp = sp - 1;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0) {
      continue;
    }
    visits = visits + 1;
    if (visits > 8192) {
      // match C twin visit cap
      sp = 0;
    } else {
      unsafe {
        n = ast_ast_block_num_consts(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          tref = pipeline_block_const_type_ref(arena, cur, i);
        }
        total = total + asm_local_slot_bytes(arena, tref);
        i = i + 1;
      }
      unsafe {
        n = ast_ast_block_num_lets(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          tref = pipeline_block_let_type_ref(arena, cur, i);
        }
        total = total + asm_local_slot_bytes(arena, tref);
        i = i + 1;
      }
      sp = pipe_block_tree_push_children(arena, sp, cur);
      sp = pipe_block_tree_push_region_children(arena, sp, cur);
    }
  }
  return total;
}

/**
 * Count const/let stack slots over function body block tree (nested if/while/for/region).
 * @param arena *u8 - ASTArena*
 * @param block_ref i32 - function body (or nested) block
 * @return i32 - total slot count (>=0)
 * wave269 pure: G.7 single product authority (was pipeline_asm_block_tree.c).
 * PLATFORM: SHARED freestanding frame layout · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_count_block_stack_slots(arena: *u8, block_ref: i32): i32 {
  let total: i32 = 0;
  let sp: i32 = 0;
  let visits: i32 = 0;
  let cur: i32 = 0;
  let nc: i32 = 0;
  let nl: i32 = 0;
  if (arena == 0 as *u8 || block_ref <= 0) {
    return 0;
  }
  sp = pipe_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp = sp - 1;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0) {
      continue;
    }
    visits = visits + 1;
    if (visits > 8192) {
      sp = 0;
    } else {
      unsafe {
        nc = ast_ast_block_num_consts(arena, cur);
        nl = ast_ast_block_num_lets(arena, cur);
      }
      total = total + nc + nl;
      sp = pipe_block_tree_push_children(arena, sp, cur);
      sp = pipe_block_tree_push_region_children(arena, sp, cur);
    }
  }
  return total;
}

/**
 * Sum fixed-array let temp-zone bytes over function body block tree (if/while/for only).
 * @param arena *u8 - ASTArena*
 * @param block_ref i32 - function body (or nested) block
 * @return i32 - total array temp bytes (>=0)
 * wave269 pure: G.7 single product authority (was pipeline_asm_block_tree.c).
 * Note: does not walk region children (match C twin; wa temp is separate face).
 * PLATFORM: SHARED freestanding frame layout · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_sum_block_array_temp_bytes(arena: *u8, block_ref: i32): i32 {
  let total: i32 = 0;
  let sp: i32 = 0;
  let visits: i32 = 0;
  let cur: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let tref: i32 = 0;
  if (arena == 0 as *u8 || block_ref <= 0) {
    return 0;
  }
  sp = pipe_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp = sp - 1;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0) {
      continue;
    }
    visits = visits + 1;
    if (visits > 8192) {
      sp = 0;
    } else {
      unsafe {
        n = ast_ast_block_num_lets(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          tref = pipeline_block_let_type_ref(arena, cur, i);
        }
        total = total + pipe_fixed_array_temp_bytes(arena, tref);
        i = i + 1;
      }
      // C twin: children only (no region) for array temp sum.
      sp = pipe_block_tree_push_children(arena, sp, cur);
    }
  }
  return total;
}

/**
 * MEM-C1: sum with_arena temp Arena64 stack bytes (24B per scope; pad total to 8).
 * @param arena *u8 - ASTArena*
 * @param block_ref i32 - function body (or nested) block
 * @return i32 - padded wa temp bytes (>=0)
 * wave269 pure: G.7 single product authority (was pipeline_asm_block_tree.c).
 * PLATFORM: SHARED freestanding frame layout · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_sum_block_wa_temp_bytes(arena: *u8, block_ref: i32): i32 {
  let total: i32 = 0;
  let sp: i32 = 0;
  let visits: i32 = 0;
  let cur: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let cap_ref: i32 = 0;
  if (arena == 0 as *u8 || block_ref <= 0) {
    return 0;
  }
  sp = pipe_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp = sp - 1;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0) {
      continue;
    }
    visits = visits + 1;
    if (visits > 8192) {
      sp = 0;
    } else {
      unsafe {
        n = ast_ast_block_num_regions(arena, cur);
      }
      i = 0;
      while (i < n) {
        unsafe {
          cap_ref = pipeline_block_region_with_arena_cap_ref(arena, cur, i);
        }
        if (cap_ref > 0) {
          total = total + 24;
        }
        i = i + 1;
      }
      sp = pipe_block_tree_push_children(arena, sp, cur);
      sp = pipe_block_tree_push_region_children(arena, sp, cur);
    }
  }
  if (total > 0 && total % 8 != 0) {
    total = total + (8 - (total % 8));
  }
  return total;
}

/**
 * DFS fill: register every block's const/let into asm local sidecar (lazy ensure).
 * @param ctx *u8 - AsmFuncCtx*
 * @param arena *u8 - ASTArena*
 * @param block_ref i32 - function body (or nested) block
 * @param inout_next_offset *i32 - next stack offset; updated across blocks
 * @param inout_num_locals *i32 - total locals after fill
 * wave269 pure: G.7 single product authority (was pipeline_asm_block_tree.c).
 * Calls pure asm_ctx_ensure_block_locals (wave268) per visited block.
 * MEM-C1: region children registered after cfg children so wa temp aligns with lets.
 * PLATFORM: SHARED freestanding block locals · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_ctx_fill_locals_block_tree(ctx: *u8, arena: *u8, block_ref: i32, inout_next_offset: *i32, inout_num_locals: *i32): void {
  let sp: i32 = 0;
  let visits: i32 = 0;
  let cur: i32 = 0;
  if (ctx == 0 as *u8 || arena == 0 as *u8 || inout_next_offset == 0 as *i32 || inout_num_locals == 0 as *i32 || block_ref <= 0) {
    return;
  }
  sp = pipe_block_tree_push(0, block_ref);
  while (sp > 0) {
    sp = sp - 1;
    cur = g_w269_block_tree_stack[sp];
    if (cur <= 0) {
      continue;
    }
    visits = visits + 1;
    if (visits > 8192) {
      sp = 0;
    } else {
      asm_ctx_ensure_block_locals(ctx, arena, cur, inout_next_offset, inout_num_locals);
      sp = pipe_block_tree_push_children(arena, sp, cur);
      // MEM-C1: with_arena / region child lets must register in same order as wa temp zone.
      sp = pipe_block_tree_push_region_children(arena, sp, cur);
    }
  }
}

