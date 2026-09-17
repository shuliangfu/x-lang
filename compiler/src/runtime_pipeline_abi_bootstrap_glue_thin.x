// Thin pure: wave321/376/391 M2 — bootstrap_glue Cap residual C→.x
//   (was wave282 C thin).
// typeck_i32_ptr_* / layout_metrics / asm scope BSS / asm_local_slot_reg_offset
// + align/bump/simd/scoped / patch_parent_links / dep_skip / redirect_std_c_wrapper.
// G.7: bodies match runtime_pipeline_abi_bootstrap_glue_thin.c / seed WAVE282.
// wave376: BAN PREFER (Darwin g05 BRANCH26); MACOS -E of T001-wrapped thin;
//   LINUX hard-skip (Ubuntu typeck rejects wrapped thin).
// wave391: HARD BAN reinject both ends (stamp .pabi_w391_bootstrap_glue.stamp);
//   stay prior Darwin -E / Ubuntu prior -E until BRANCH26 root.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
// Slot polarity: pipeline_asm_host_is_arm64_c (was #if __aarch64__/__arm64__).

export extern function typeck_layout_metrics_sz_slot(): *i32;
export extern function typeck_layout_metrics_al_slot(): *i32;
export extern function typeck_layout_metrics_sz_slot_depth(depth: i32): *i32;
export extern function typeck_layout_metrics_al_slot_depth(depth: i32): *i32;
export extern function pipeline_type_kind_ord_at(a: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(a: *u8, type_ref: i32): i32;
export extern function pipeline_arena_type_ptr(a: *u8, type_ref: i32): *u8;
export extern function pipeline_arena_num_types(a: *u8): i32;
export extern function asm_local_slot_bytes(arena: *u8, type_ref: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_block_slot_get(ctx: *u8, block_ref: i32): i32;
export extern function asm_ctx_local_count(ctx: *u8): i32;
export extern function asm_ctx_local_name_len(ctx: *u8, idx: i32): i32;
export extern function asm_ctx_local_name_copy64(ctx: *u8, idx: i32, out: *u8): void;
export extern function asm_ctx_local_offset_at(ctx: *u8, idx: i32): i32;
export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_module_func_body_ref_at(m: *u8, func_index: i32): i32;
export extern function pipeline_patch_block_parent_links(a: *u8, block_ref: i32, parent_ref: i32): void;
export extern function pipeline_codegen_dep_skip_asm_user_std_io(path: *u8): i32;
export extern function ast_ast_block_num_consts(a: *u8, br: i32): i32;
export extern function ast_ast_block_num_lets(a: *u8, br: i32): i32;
export extern function pipeline_asm_host_is_arm64_c(): i32;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memcmp(a: *u8, b: *u8, n: usize): i32;
export extern "C" function strlen(s: *u8): usize;
export extern "C" function strstr(hay: *u8, needle: *u8): *u8;

const W321_MAX_ASM_SCOPE: i32 = 64;
const W321_SC_STRIDE: i32 = 16;
// Flat BSS: [ctx*@0 | used@8 | scope_block_ref@12] × 64.
let g_w321_asm_scope_sc: u8[1024] = [];

/**
 * Byte-equal of n bytes (null-safe).
 * @param a *u8
 * @param b *u8
 * @param n i32
 * @return i32 — 1 equal, 0 otherwise
 */
function w321_bytes_eq(a: *u8, b: *u8, n: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (n <= 0) {
      return 1;
    }
    if (a == (0 as *u8) || b == (0 as *u8)) {
      return 0;
    }
    let i: i32 = 0;
    while (i < n) {
      unsafe {
        if (a[i] != b[i]) {
          return 0;
        }
      }
      i = i + 1;
    }
    return 1;
  }
}

/**
 * Path prefix match: memcmp(path, lit, n) and path[n] is NUL or '.'.
 * @param path *u8
 * @param lit *u8
 * @param n i32
 * @return i32 — 1 match
 */
function w321_path_prefix_dot(path: *u8, lit: *u8, n: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (path == (0 as *u8) || lit == (0 as *u8) || n <= 0) {
      return 0;
    }
    if (w321_bytes_eq(path, lit, n) == 0) {
      return 0;
    }
    let b: u8 = 0;
    unsafe {
      b = path[n];
    }
    if (b == (0 as u8) || b == (46 as u8)) {
      return 1;
    }
    return 0;
  }
}

/**
 * Sidecar base at index i.
 * @param i i32
 * @return *u8
 */
function w321_sc_base(i: i32): *u8 {
  unsafe {
    return &g_w321_asm_scope_sc[0] + ((i * W321_SC_STRIDE) as usize);
  }
}

/**
 * Load LP64 ptr at sidecar base.
 * @param base *u8
 * @return *u8
 */
function w321_sc_ctx(base: *u8): *u8 {
  unsafe {
    return *(base as **u8);
  }
}

/**
 * Store LP64 ptr at sidecar base.
 * @param base *u8
 * @param ctx *u8
 */
function w321_sc_set_ctx(base: *u8, ctx: *u8): void {
  unsafe {
    *(base as **u8) = ctx;
  }
}

/**
 * Load used flag @8.
 * @param base *u8
 * @return i32
 */
function w321_sc_used(base: *u8): i32 {
  unsafe {
    return *((base + 8) as *i32);
  }
}

/**
 * Store used flag @8.
 * @param base *u8
 * @param v i32
 */
function w321_sc_set_used(base: *u8, v: i32): void {
  unsafe {
    *((base + 8) as *i32) = v;
  }
}

/**
 * Load scope_block_ref @12.
 * @param base *u8
 * @return i32
 */
function w321_sc_blk(base: *u8): i32 {
  unsafe {
    return *((base + 12) as *i32);
  }
}

/**
 * Store scope_block_ref @12.
 * @param base *u8
 * @param v i32
 */
function w321_sc_set_blk(base: *u8, v: i32): void {
  unsafe {
    *((base + 12) as *i32) = v;
  }
}

/**
 * Find or create asm scope sidecar for ctx.
 * @param ctx *u8
 * @param create i32
 * @return *u8 — sidecar base or null
 */
function w321_asm_scope_sidecar_get(ctx: *u8, create: i32): *u8 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (ctx == (0 as *u8)) {
      return 0 as *u8;
    }
    let i: i32 = 0;
    while (i < W321_MAX_ASM_SCOPE) {
      let base: *u8 = w321_sc_base(i);
      if (w321_sc_used(base) != 0 && w321_sc_ctx(base) == ctx) {
        return base;
      }
      i = i + 1;
    }
    if (create == 0) {
      return 0 as *u8;
    }
    i = 0;
    while (i < W321_MAX_ASM_SCOPE) {
      let base2: *u8 = w321_sc_base(i);
      if (w321_sc_used(base2) == 0) {
        w321_sc_set_ctx(base2, ctx);
        w321_sc_set_used(base2, 1);
        w321_sc_set_blk(base2, 0);
        return base2;
      }
      i = i + 1;
    }
    return 0 as *u8;
  }
}

/**
 * Store i32 through optional pointer (null-safe).
 * @param p *i32
 * @param v i32
 */
#[no_mangle]
export function typeck_i32_ptr_store(p: *i32, v: i32): void {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (p != (0 as *i32)) {
      unsafe {
        *p = v;
      }
    }
  }
}

/**
 * Read i32 through optional pointer (null → 0).
 * @param p *i32
 * @return i32
 */
#[no_mangle]
export function typeck_i32_ptr_read(p: *i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (p == (0 as *i32)) {
      return 0;
    }
    unsafe {
      return *p;
    }
  }
}

/**
 * Init layout metrics slots at depth (sz=0, al=1).
 * @param depth i32
 */
#[no_mangle]
export function typeck_layout_metrics_init_depth(depth: i32): void {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let al: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    if (sz != (0 as *i32)) {
      unsafe {
        *sz = 0;
      }
    }
    if (al != (0 as *i32)) {
      unsafe {
        *al = 1;
      }
    }
  }
}

/**
 * Read align slot at depth.
 * @param depth i32
 * @return i32
 */
#[no_mangle]
export function typeck_layout_metrics_al_read_depth(depth: i32): i32 {
  unsafe {
    return *typeck_layout_metrics_al_slot_depth(depth);
  }
}

/**
 * Read size slot at depth.
 * @param depth i32
 * @return i32
 */
#[no_mangle]
export function typeck_layout_metrics_sz_read_depth(depth: i32): i32 {
  unsafe {
    return *typeck_layout_metrics_sz_slot_depth(depth);
  }
}

/**
 * Init default layout metrics slots (sz=0, al=1).
 */
#[no_mangle]
export function typeck_layout_metrics_init_slot(): void {
  unsafe {
    *typeck_layout_metrics_sz_slot() = 0;
    *typeck_layout_metrics_al_slot() = 1;
  }
}

/**
 * Set current asm emit scope block for ctx sidecar.
 * @param ctx *u8
 * @param block_ref i32
 */
#[no_mangle]
export function asm_ctx_set_scope_block(ctx: *u8, block_ref: i32): void {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let sc: *u8 = w321_asm_scope_sidecar_get(ctx, 1);
    if (sc != (0 as *u8)) {
      w321_sc_set_blk(sc, block_ref);
    }
  }
}

/**
 * Get current asm emit scope block for ctx (0 if unset).
 * @param ctx *u8
 * @return i32
 */
#[no_mangle]
export function asm_ctx_scope_block_ref_at(ctx: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let sc: *u8 = w321_asm_scope_sidecar_get(ctx, 0);
    if (sc == (0 as *u8)) {
      return 0;
    }
    return w321_sc_blk(sc);
  }
}

/**
 * Align for local slot by type kind (recursive on ptr/array/slice elem).
 * @param arena *u8
 * @param type_ref i32
 * @param depth i32
 * @return i32
 */
function asm_type_align_for_local(arena: *u8, type_ref: i32, depth: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (arena == (0 as *u8) || type_ref <= 0 || type_ref > pipeline_arena_num_types(arena) || depth > 64) {
      return 8;
    }
    let kind: i32 = pipeline_type_kind_ord_at(arena, type_ref);
    if (kind == 2) {
      return 1;
    }
    if (kind == 0 || kind == 3 || kind == 1 || kind == 14) {
      return 4;
    }
    if (kind == 13) {
      return 16;
    }
    if (kind == 5 || kind == 4 || kind == 6 || kind == 7 || kind == 15 || kind == 9 || kind == 11) {
      return 8;
    }
    if (kind == 10 || kind == 12) {
      let elem: i32 = pipeline_type_elem_ref_at(arena, type_ref);
      if (elem > 0) {
        return asm_type_align_for_local(arena, elem, depth + 1);
      }
      return 1;
    }
    if (kind == 8) {
      return 4;
    }
    return 8;
  }
}

/**
 * Bump frame off up to type align.
 * @param arena *u8
 * @param type_ref i32
 * @param off i32
 * @return i32
 */
#[no_mangle]
export function asm_bump_off_align_for_local(arena: *u8, type_ref: i32, off: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let al: i32 = asm_type_align_for_local(arena, type_ref, 0);
    if (al <= 0) {
      al = 8;
    }
    return (off + al - 1) / al * al;
  }
}

/**
 * True if type kind is SIMD vector (ord 13).
 * @param arena *u8
 * @param type_ref i32
 * @return i32
 */
#[no_mangle]
export function asm_type_is_simd_vector(arena: *u8, type_ref: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (arena == (0 as *u8) || type_ref <= 0 || type_ref > pipeline_arena_num_types(arena)) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, type_ref) == 13) {
      return 1;
    }
    return 0;
  }
}

/**
 * True if NAMED type spelling is a known SIMD vector name.
 * Cap 4.2.8 Type LE: kind@0 name[256]@4 name_len@260.
 * @param arena *u8
 * @param type_ref i32
 * @return i32
 */
#[no_mangle]
export function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (arena == (0 as *u8) || type_ref <= 0 || type_ref > pipeline_arena_num_types(arena)) {
      return 0;
    }
    if (asm_type_is_simd_vector(arena, type_ref) != 0) {
      return 1;
    }
    let t: *u8 = pipeline_arena_type_ptr(arena, type_ref);
    if (t == (0 as *u8)) {
      return 0;
    }
    let kind: i32 = 0;
    let nlen: i32 = 0;
    unsafe {
      kind = *((t + 0) as *i32);
      nlen = *((t + 260) as *i32);
    }
    if (kind != 8 || nlen <= 0) {
      return 0;
    }
    let name: *u8 = t + 4;
    if (nlen == 5 && w321_bytes_eq(name, "i32x4", 5) != 0) { return 1; }
    if (nlen == 5 && w321_bytes_eq(name, "i32x8", 5) != 0) { return 1; }
    if (nlen == 6 && w321_bytes_eq(name, "i32x16", 6) != 0) { return 1; }
    if (nlen == 5 && w321_bytes_eq(name, "u32x4", 5) != 0) { return 1; }
    if (nlen == 5 && w321_bytes_eq(name, "u32x8", 5) != 0) { return 1; }
    if (nlen == 6 && w321_bytes_eq(name, "u32x16", 6) != 0) { return 1; }
    if (nlen == 5 && w321_bytes_eq(name, "f32x4", 5) != 0) { return 1; }
    if (nlen == 5 && w321_bytes_eq(name, "f32x8", 5) != 0) { return 1; }
    if (nlen == 5 && w321_bytes_eq(name, "Vec4f", 5) != 0) { return 1; }
    if (nlen == 5 && w321_bytes_eq(name, "Vec8i", 5) != 0) { return 1; }
    return 0;
  }
}

/**
 * Bump off to 16 before SIMD/struct local when needed.
 * @param arena *u8
 * @param type_ref i32
 * @param off i32
 * @return i32
 */
#[no_mangle]
export function asm_bump_off_before_struct_local(arena: *u8, type_ref: i32, off: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (arena == (0 as *u8) || type_ref <= 0) {
      return off;
    }
    let kind: i32 = pipeline_type_kind_ord_at(arena, type_ref);
    if ((kind == 13 || asm_type_is_simd_vector_spelling(arena, type_ref) != 0) && (off % 16) != 0) {
      return (off + 15) / 16 * 16;
    }
    if (kind == 8 && (off % 16) != 0) {
      return (off + 15) / 16 * 16;
    }
    return off;
  }
}

/**
 * Allocate local slot home; arm64 low-end, x86_64 high-end polarity.
 * PLATFORM: SHARED — uses pipeline_asm_host_is_arm64_c (LINUX|x86_64 vs MACOS|ARM64).
 * @param arena *u8
 * @param type_ref i32
 * @param off i32
 * @param inout_off *i32
 * @return i32 — slot_off
 */
#[no_mangle]
export function asm_local_slot_reg_offset(arena: *u8, type_ref: i32, off: i32, inout_off: *i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let cur: i32 = asm_bump_off_before_struct_local(arena, type_ref, off);
    cur = asm_bump_off_align_for_local(arena, type_ref, cur);
    let sz: i32 = asm_local_slot_bytes(arena, type_ref);
    if (sz <= 0) {
      sz = 8;
    }
    let slot_off: i32 = 0;
    if (pipeline_asm_host_is_arm64_c() != 0) {
      slot_off = cur;
      if (inout_off != (0 as *i32)) {
        unsafe {
          *inout_off = cur + sz;
        }
      }
    } else {
      slot_off = cur + sz;
      if (inout_off != (0 as *i32)) {
        unsafe {
          *inout_off = cur + sz;
        }
      }
    }
    return slot_off;
  }
}

/**
 * Resolve local name within current emit scope block only.
 * PLATFORM: SHARED — pure-asm VAR load / return of block-local lets.
 * @param ctx *u8
 * @param arena *u8
 * @param name *u8
 * @param name_len i32
 * @return i32 — offset or fallback find_offset
 */
#[no_mangle]
export function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let scope_blk: i32 = asm_ctx_scope_block_ref_at(ctx);
    if (scope_blk <= 0) {
      return asm_ctx_local_find_offset(ctx, name, name_len);
    }
    let min_slot: i32 = asm_ctx_block_slot_get(ctx, scope_blk);
    if (min_slot < 0) {
      return asm_ctx_local_find_offset(ctx, name, name_len);
    }
    let nconst: i32 = 0;
    let nlet: i32 = 0;
    if (arena != (0 as *u8)) {
      nconst = ast_ast_block_num_consts(arena, scope_blk);
      nlet = ast_ast_block_num_lets(arena, scope_blk);
    }
    if (nconst < 0) { nconst = 0; }
    if (nlet < 0) { nlet = 0; }
    let end_slot: i32 = min_slot + nconst + nlet;
    let count: i32 = asm_ctx_local_count(ctx);
    if (end_slot > count) {
      end_slot = count;
    }
    let i: i32 = end_slot - 1;
    while (i >= min_slot) {
      let nb: u8[256] = [];
      let nlen: i32 = asm_ctx_local_name_len(ctx, i);
      if (nlen == name_len) {
        asm_ctx_local_name_copy64(ctx, i, &nb[0]);
        let k: i32 = 0;
        let ok: i32 = 1;
        while (k < name_len) {
          unsafe {
            if (nb[k] != name[k]) {
              ok = 0;
            }
          }
          if (ok == 0) {
            break;
          }
          k = k + 1;
        }
        if (ok != 0) {
          return asm_ctx_local_offset_at(ctx, i);
        }
      }
      i = i - 1;
    }
    return asm_ctx_local_find_offset(ctx, name, name_len);
  }
}

/**
 * Patch parent links for every function body in module.
 * @param m *u8
 * @param a *u8
 */
#[no_mangle]
export function pipeline_asm_patch_module_parent_links(m: *u8, a: *u8): void {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (m == (0 as *u8) || a == (0 as *u8)) {
      return;
    }
    let n: i32 = pipeline_module_num_funcs(m);
    let i: i32 = 0;
    while (i < n) {
      let body: i32 = pipeline_module_func_body_ref_at(m, i);
      if (body > 0) {
        pipeline_patch_block_parent_links(a, body, 0);
      }
      i = i + 1;
    }
  }
}

/**
 * Skip co-emit for std.fs family path.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_codegen_dep_skip_asm_user_std_fs(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return w321_path_prefix_dot(path, "std.fs", 6);
  }
}

/**
 * Skip co-emit for std.process family path.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_codegen_dep_skip_asm_user_std_process(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return w321_path_prefix_dot(path, "std.process", 11);
  }
}

/**
 * Skip co-emit for std.fmt family path.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_codegen_dep_skip_asm_user_std_fmt(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return w321_path_prefix_dot(path, "std.fmt", 7);
  }
}

/**
 * Skip co-emit for std.error / std.context / std.simd.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_codegen_dep_skip_asm_user_std_misc(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (w321_path_prefix_dot(path, "std.error", 9) != 0) { return 1; }
    if (w321_path_prefix_dot(path, "std.context", 11) != 0) { return 1; }
    if (w321_path_prefix_dot(path, "std.simd", 8) != 0) { return 1; }
    return 0;
  }
}

/**
 * Skip co-emit for core.fmt/types/option/result (typeck skip set).
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_codegen_dep_skip_asm_user_core_lib(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (w321_path_prefix_dot(path, "core.fmt", 8) != 0) { return 1; }
    if (w321_path_prefix_dot(path, "core.types", 10) != 0) { return 1; }
    if (w321_path_prefix_dot(path, "core.option", 11) != 0) { return 1; }
    if (w321_path_prefix_dot(path, "core.result", 11) != 0) { return 1; }
    return 0;
  }
}

/**
 * True if path is an in-tree core/* formal module (not scratch core.m6).
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_user_dep_is_in_tree_core(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (path == (0 as *u8)) {
      return 0;
    }
    let plen: i32 = 0;
    while (plen < 64) {
      let c: u8 = 0;
      unsafe {
        c = path[plen];
      }
      if (c == (0 as u8)) {
        break;
      }
      plen = plen + 1;
    }
    // Table of in-tree core.* names (exact or dotted continuation).
  
    if (plen >= 11 && w321_bytes_eq(path, "core.assert", 11) != 0) {
      if (plen == 11) { return 1; }
      unsafe {
        if (path[11] == (46 as u8) || path[11] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 12 && w321_bytes_eq(path, "core.builtin", 12) != 0) {
      if (plen == 12) { return 1; }
      unsafe {
        if (path[12] == (46 as u8) || path[12] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 8 && w321_bytes_eq(path, "core.cmp", 8) != 0) {
      if (plen == 8) { return 1; }
      unsafe {
        if (path[8] == (46 as u8) || path[8] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 10 && w321_bytes_eq(path, "core.debug", 10) != 0) {
      if (plen == 10) { return 1; }
      unsafe {
        if (path[10] == (46 as u8) || path[10] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 8 && w321_bytes_eq(path, "core.fmt", 8) != 0) {
      if (plen == 8) { return 1; }
      unsafe {
        if (path[8] == (46 as u8) || path[8] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 13 && w321_bytes_eq(path, "core.iterator", 13) != 0) {
      if (plen == 13) { return 1; }
      unsafe {
        if (path[13] == (46 as u8) || path[13] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 8 && w321_bytes_eq(path, "core.mem", 8) != 0) {
      if (plen == 8) { return 1; }
      unsafe {
        if (path[8] == (46 as u8) || path[8] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 11 && w321_bytes_eq(path, "core.option", 11) != 0) {
      if (plen == 11) { return 1; }
      unsafe {
        if (path[11] == (46 as u8) || path[11] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 11 && w321_bytes_eq(path, "core.result", 11) != 0) {
      if (plen == 11) { return 1; }
      unsafe {
        if (path[11] == (46 as u8) || path[11] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 10 && w321_bytes_eq(path, "core.slice", 10) != 0) {
      if (plen == 10) { return 1; }
      unsafe {
        if (path[10] == (46 as u8) || path[10] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 8 && w321_bytes_eq(path, "core.str", 8) != 0) {
      if (plen == 8) { return 1; }
      unsafe {
        if (path[8] == (46 as u8) || path[8] == (0 as u8)) { return 1; }
      }
    }
    if (plen >= 10 && w321_bytes_eq(path, "core.types", 10) != 0) {
      if (plen == 10) { return 1; }
      unsafe {
        if (path[10] == (46 as u8) || path[10] == (0 as u8)) { return 1; }
      }
    }
    return 0;
  }
}

/**
 * True if path is std.net family.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_user_std_net_dep_path(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    return w321_path_prefix_dot(path, "std.net", 7);
  }
}

/**
 * Load char* from char** table at index (LP64).
 * @param dep_paths *u8 — char**
 * @param i i32
 * @return *u8
 */
function w321_dep_path_at(dep_paths: *u8, i: i32): *u8 {
  unsafe {
    return *(((dep_paths as usize) + ((i * 8) as usize)) as **u8);
  }
}

/**
 * Whether user deps need co-emit (non-hosted std / non in-tree core).
 * @param dep_paths *u8 — char**
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_user_deps_need_coemit(dep_paths: *u8, n: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (dep_paths == (0 as *u8) || n <= 0) {
      return 0;
    }
    let i: i32 = 0;
    while (i < n) {
      let p: *u8 = w321_dep_path_at(dep_paths, i);
      if (p == (0 as *u8)) {
        p = "" as *u8;
      }
      if (w321_bytes_eq(p, "std.", 4) != 0) {
        i = i + 1;
        continue;
      }
      if (w321_bytes_eq(p, "std/", 4) != 0) {
        i = i + 1;
        continue;
      }
      if (strstr(p, "/std/") != (0 as *u8)) {
        i = i + 1;
        continue;
      }
      if (pipeline_asm_user_dep_is_in_tree_core(p) != 0) {
        i = i + 1;
        continue;
      }
      return 1;
    }
    return 0;
  }
}

/**
 * Skip X typeck for hosted std/core/net deps (prebuilt .o).
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_user_dep_skip_x_typeck(path: *u8): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (path == (0 as *u8)) { return 0; }
    if (pipeline_codegen_dep_skip_asm_user_std_io(path) != 0) { return 1; }
    if (pipeline_codegen_dep_skip_asm_user_std_fs(path) != 0) { return 1; }
    if (pipeline_codegen_dep_skip_asm_user_std_process(path) != 0) { return 1; }
    if (pipeline_codegen_dep_skip_asm_user_std_fmt(path) != 0) { return 1; }
    if (pipeline_codegen_dep_skip_asm_user_std_misc(path) != 0) { return 1; }
    if (pipeline_codegen_dep_skip_asm_user_core_lib(path) != 0) { return 1; }
    if (pipeline_asm_user_std_net_dep_path(path) != 0) { return 1; }
    return 0;
  }
}

/**
 * No-op seed of std.net struct layouts (historical leave).
 * @param m *u8
 */
#[no_mangle]
export function pipeline_asm_seed_std_net_struct_layouts(m: *u8): void {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    let _unused: *u8 = m;
  }
}

/**
 * Try heap redirect table: from-name → to-sym.
 * @param name *u8
 * @param name_len i32
 * @param sym_out *u8
 * @param out_cap i32
 * @return i32 — written length or 0
 */
function w321_try_std_heap_redirect_sym(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
  
    if (name_len == 5 && w321_bytes_eq(name, "alloc", 5) != 0) {
      if (12 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_c" as *u8, 12 as usize); }
      return 12;
    }
    if (name_len == 9 && w321_bytes_eq(name, "alloc_i32", 9) != 0) {
      if (16 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_i32_c" as *u8, 16 as usize); }
      return 16;
    }
    if (name_len == 21 && w321_bytes_eq(name, "alloc_i32_ret_i32_ptr", 21) != 0) {
      if (16 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_i32_c" as *u8, 16 as usize); }
      return 16;
    }
    if (name_len == 20 && w321_bytes_eq(name, "alloc_i32_ret_u8_ptr", 20) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_u8_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 21 && w321_bytes_eq(name, "alloc_i32_ret_u64_ptr", 21) != 0) {
      if (16 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_u64_c" as *u8, 16 as usize); }
      return 16;
    }
    if (name_len == 21 && w321_bytes_eq(name, "alloc_i32_ret_f64_ptr", 21) != 0) {
      if (16 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_f64_c" as *u8, 16 as usize); }
      return 16;
    }
    if (name_len == 21 && w321_bytes_eq(name, "alloc_i32_ret_f32_ptr", 21) != 0) {
      if (16 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_f32_c" as *u8, 16 as usize); }
      return 16;
    }
    if (name_len == 11 && w321_bytes_eq(name, "realloc_i32", 11) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_i32_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 23 && w321_bytes_eq(name, "realloc_i32_ret_i32_ptr", 23) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_i32_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 23 && w321_bytes_eq(name, "realloc_u64_ret_u64_ptr", 23) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_u64_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 23 && w321_bytes_eq(name, "realloc_f64_ret_f64_ptr", 23) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_f64_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 23 && w321_bytes_eq(name, "realloc_f32_ret_f32_ptr", 23) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_f32_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 21 && w321_bytes_eq(name, "realloc_u8_ret_u8_ptr", 21) != 0) {
      if (17 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_u8_c" as *u8, 17 as usize); }
      return 17;
    }
    if (name_len == 8 && w321_bytes_eq(name, "free_i32", 8) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_free_i32_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 12 && w321_bytes_eq(name, "free_i32_ptr", 12) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_free_i32_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 12 && w321_bytes_eq(name, "free_u64_ptr", 12) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_free_u64_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 12 && w321_bytes_eq(name, "free_f64_ptr", 12) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_free_f64_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 12 && w321_bytes_eq(name, "free_f32_ptr", 12) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_free_f32_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 8 && w321_bytes_eq(name, "alloc_u8", 8) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_u8_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 10 && w321_bytes_eq(name, "realloc_u8", 10) != 0) {
      if (17 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_u8_c" as *u8, 17 as usize); }
      return 17;
    }
    if (name_len == 7 && w321_bytes_eq(name, "free_u8", 7) != 0) {
      if (14 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_free_u8_c" as *u8, 14 as usize); }
      return 14;
    }
    if (name_len == 9 && w321_bytes_eq(name, "alloc_f32", 9) != 0) {
      if (16 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_alloc_f32_c" as *u8, 16 as usize); }
      return 16;
    }
    if (name_len == 11 && w321_bytes_eq(name, "realloc_f32", 11) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_realloc_f32_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 8 && w321_bytes_eq(name, "free_f32", 8) != 0) {
      if (15 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_free_f32_c" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 11 && w321_bytes_eq(name, "copy_i32_at", 11) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_i32_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 10 && w321_bytes_eq(name, "copy_u8_at", 10) != 0) {
      if (17 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_u8_at_c" as *u8, 17 as usize); }
      return 17;
    }
    if (name_len == 11 && w321_bytes_eq(name, "copy_f32_at", 11) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_f32_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 11 && w321_bytes_eq(name, "copy_u64_at", 11) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_u64_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 11 && w321_bytes_eq(name, "copy_f64_at", 11) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_f64_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 28 && w321_bytes_eq(name, "copy_i32_ptr_i32_i32_ptr_i32", 28) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_i32_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 26 && w321_bytes_eq(name, "copy_u8_ptr_i32_u8_ptr_i32", 26) != 0) {
      if (17 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_u8_at_c" as *u8, 17 as usize); }
      return 17;
    }
    if (name_len == 28 && w321_bytes_eq(name, "copy_f32_ptr_i32_f32_ptr_i32", 28) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_f32_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 28 && w321_bytes_eq(name, "copy_u64_ptr_i32_u64_ptr_i32", 28) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_u64_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 28 && w321_bytes_eq(name, "copy_f64_ptr_i32_f64_ptr_i32", 28) != 0) {
      if (18 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_copy_f64_at_c" as *u8, 18 as usize); }
      return 18;
    }
    if (name_len == 12 && w321_bytes_eq(name, "arena64_init", 12) != 0) {
      if (19 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_arena64_init_c" as *u8, 19 as usize); }
      return 19;
    }
    if (name_len == 13 && w321_bytes_eq(name, "arena64_alloc", 13) != 0) {
      if (20 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_arena64_alloc_c" as *u8, 20 as usize); }
      return 20;
    }
    if (name_len == 14 && w321_bytes_eq(name, "arena64_deinit", 14) != 0) {
      if (21 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_arena64_deinit_c" as *u8, 21 as usize); }
      return 21;
    }
    if (name_len == 7 && w321_bytes_eq(name, "ptr_mod", 7) != 0) {
      if (14 + 1 > out_cap) { return 0; }
      unsafe { memcpy(sym_out, "heap_ptr_mod_c" as *u8, 14 as usize); }
      return 14;
    }
    return 0;
  }
}

/**
 * Redirect std C-wrapper symbols (heap table + fs_/net_/_c + fmt/encoding/string).
 * @param name *u8
 * @param name_len i32
 * @param sym_out *u8
 * @param out_cap i32
 * @return i32 — written length or 0
 */
#[no_mangle]
export function pipeline_asm_redirect_std_c_wrapper_sym(name: *u8, name_len: i32, sym_out: *u8, out_cap: i32): i32 {
  // wave376: Cap-T001 whole-body unsafe (export-extern / PREFER_ASM).
  // PLATFORM: SHARED — asm typeck contract.
  unsafe {
    if (name == (0 as *u8) || name_len <= 0 || sym_out == (0 as *u8) || out_cap <= 0) {
      return 0;
    }
    if (name_len >= 2) {
      unsafe {
        if (name[name_len - 2] == (95 as u8) && name[name_len - 1] == (99 as u8)) {
          return 0;
        }
      }
    }
    let hlen: i32 = w321_try_std_heap_redirect_sym(name, name_len, sym_out, out_cap);
    if (hlen > 0) {
      return hlen;
    }
    if (name_len + 2 >= out_cap) {
      return 0;
    }
    if (name_len >= 3 && w321_bytes_eq(name, "fs_", 3) != 0) {
      unsafe {
        memcpy(sym_out, name, name_len as usize);
        sym_out[name_len] = 95 as u8;
        sym_out[name_len + 1] = 99 as u8;
      }
      return name_len + 2;
    }
    if (name_len >= 4 && w321_bytes_eq(name, "net_", 4) != 0) {
      unsafe {
        memcpy(sym_out, name, name_len as usize);
        sym_out[name_len] = 95 as u8;
        sym_out[name_len + 1] = 99 as u8;
      }
      return name_len + 2;
    }
    if (name_len == 9 && w321_bytes_eq(name, "print_str", 9) != 0) {
      unsafe { memcpy(sym_out, "std_io_print_str" as *u8, 16 as usize); }
      return 16;
    }
    if (name_len == 13 && w321_bytes_eq(name, "std_fmt_print", 13) != 0) {
      unsafe { memcpy(sym_out, "std_fmt_print" as *u8, 13 as usize); }
      return 13;
    }
    if (name_len == 24 && w321_bytes_eq(name, "std_fmt_print_u8_ptr_i32", 24) != 0) {
      unsafe { memcpy(sym_out, "std_fmt_print" as *u8, 13 as usize); }
      return 13;
    }
    if (name_len == 15 && w321_bytes_eq(name, "std_fmt_println", 15) != 0) {
      unsafe { memcpy(sym_out, "std_fmt_println" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len == 26 && w321_bytes_eq(name, "std_fmt_println_u8_ptr_i32", 26) != 0) {
      unsafe { memcpy(sym_out, "std_fmt_println" as *u8, 15 as usize); }
      return 15;
    }
    if (name_len > 13 && w321_bytes_eq(name, "std_encoding_", 13) != 0) {
      let suffix_len: i32 = name_len - 13;
      let out_len: i32 = 9 + suffix_len + 2;
      if (out_len >= out_cap) {
        return 0;
      }
      unsafe {
        memcpy(sym_out, "encoding_" as *u8, 9 as usize);
        memcpy(sym_out + 9, name + 13, suffix_len as usize);
        sym_out[9 + suffix_len] = 95 as u8;
        sym_out[9 + suffix_len + 1] = 99 as u8;
      }
      return out_len;
    }
    if (name_len > 11 && w321_bytes_eq(name, "std_string_", 11) != 0) {
      let suffix_len: i32 = name_len - 11;
      if (suffix_len + 1 > out_cap) {
        return 0;
      }
      if (suffix_len >= 12 && w321_bytes_eq(name + 11, "xlang_string_", 12) != 0) {
        unsafe {
          memcpy(sym_out, name + 11, suffix_len as usize);
        }
        return suffix_len;
      }
    }
    return 0;
  }
}

