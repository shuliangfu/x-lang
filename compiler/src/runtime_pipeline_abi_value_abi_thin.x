// Thin pure: wave330/378/384/517 M2 — value_abi Cap residual C→.x (was wave276 C thin).
// By-value Type/Expr/Block/Func get/set_copy + Cap aliases + IEEE f32/f64 helpers.
// G.7: bodies match deleted C thin / seed WAVE276_ARENA_VALUE_ABI_ALWAYS.
// PRODUCT inject: HARD BAN reinject (wave384/517) — stay prior -E overlay.
// Opaque byte blobs — host cc owns sret ABI (SysV x86_64 vs AAPCS64);
// do NOT pure-asm this leaf; do NOT tip reinject -E after green.
// wave378 BAN PREFER: sret ABI — stay -E+$CC both ends.
// wave384 HARD BAN reinject both ends.
// wave517: float bits peer-flat → value_abi_float_bits_thin (tipU Soft Cap;
//   Ubuntu tip CG002 on sret monolith); stamp → w517; tip PRODUCT reinject
//   still HARD BAN (keep prior -E overlay).
// PLATFORM: SHARED host-cc Cap leave / LINUX gold / MACOS co-path.

export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

export extern function pipeline_arena_type_ptr(a: *u8, ref: i32): *u8;
export extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;
export extern function pipeline_arena_block_ptr(a: *u8, ref: i32): *u8;
export extern function pipeline_arena_func_ptr(a: *u8, ref: i32): *u8;
/* wave517: float bits moved to value_abi_float_bits_thin (tipU peer; Ubuntu
 * monolith tip CG002 on sret). PRODUCT -E overlay still has float symbols. */

/** Opaque product Type row — sizeof 532. PLATFORM: SHARED */
allow(padding) struct W276_Type {
  _b: u8[532];
}

/** Opaque product Expr row — sizeof 1224. PLATFORM: SHARED */
allow(padding) struct W276_Expr {
  _b: u8[1224];
}

/** Opaque product Block row — sizeof 92. PLATFORM: SHARED */
allow(padding) struct W276_Block {
  _b: u8[92];
}

/** Opaque product Func row — sizeof 324. PLATFORM: SHARED */
allow(padding) struct W276_Func {
  _b: u8[324];
}

/**
 * Snapshot Type row by value (host ABI sret). Empty zero row if ptr null.
 * @param a ASTArena*
 * @param ref 1-based type ref
 * @return W276_Type by value
 * PLATFORM: SHARED — host cc emits correct sret for this TU
 */
export function pipeline_arena_type_get_copy(a: *u8, ref: i32): W276_Type {
  let empty: W276_Type;
  let tp: *u8 = 0 as *u8;
  unsafe { memset(&(empty._b[0]), 0, 532 as usize); }
  unsafe { tp = pipeline_arena_type_ptr(a, ref); }
  if (tp != (0 as *u8)) {
    unsafe { memcpy(&(empty._b[0]), tp, 532 as usize); }
  }
  return empty;
}

/**
 * Write Type row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based type ref
 * @param t host-ABI Type value
 * PLATFORM: SHARED
 */
export function pipeline_arena_type_set_copy(a: *u8, ref: i32, t: W276_Type): void {
  let tp: *u8 = 0 as *u8;
  unsafe { tp = pipeline_arena_type_ptr(a, ref); }
  if (tp != (0 as *u8)) {
    unsafe { memcpy(tp, &(t._b[0]), 532 as usize); }
  }
}

/**
 * Snapshot Expr row by value (host ABI sret; sizeof 1224).
 * @param a ASTArena*
 * @param ref 1-based expr ref
 * @return W276_Expr by value
 * PLATFORM: SHARED
 */
export function pipeline_arena_expr_get_copy(a: *u8, ref: i32): W276_Expr {
  let empty: W276_Expr;
  let ep: *u8 = 0 as *u8;
  unsafe { memset(&(empty._b[0]), 0, 1224 as usize); }
  unsafe { ep = pipeline_arena_expr_ptr(a, ref); }
  if (ep != (0 as *u8)) {
    unsafe { memcpy(&(empty._b[0]), ep, 1224 as usize); }
  }
  return empty;
}

/**
 * Write Expr row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based expr ref
 * @param e host-ABI Expr value
 * PLATFORM: SHARED
 */
export function pipeline_arena_expr_set_copy(a: *u8, ref: i32, e: W276_Expr): void {
  let ep: *u8 = 0 as *u8;
  unsafe { ep = pipeline_arena_expr_ptr(a, ref); }
  if (ep != (0 as *u8)) {
    unsafe { memcpy(ep, &(e._b[0]), 1224 as usize); }
  }
}

/**
 * Snapshot Block row by value (host ABI sret).
 * @param a ASTArena*
 * @param ref 1-based block ref
 * @return W276_Block by value
 * PLATFORM: SHARED
 */
export function pipeline_arena_block_get_copy(a: *u8, ref: i32): W276_Block {
  let empty: W276_Block;
  let bp: *u8 = 0 as *u8;
  unsafe { memset(&(empty._b[0]), 0, 92 as usize); }
  unsafe { bp = pipeline_arena_block_ptr(a, ref); }
  if (bp != (0 as *u8)) {
    unsafe { memcpy(&(empty._b[0]), bp, 92 as usize); }
  }
  return empty;
}

/**
 * Write Block row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based block ref
 * @param b host-ABI Block value
 * PLATFORM: SHARED
 */
export function pipeline_arena_block_set_copy(a: *u8, ref: i32, b: W276_Block): void {
  let bp: *u8 = 0 as *u8;
  unsafe { bp = pipeline_arena_block_ptr(a, ref); }
  if (bp != (0 as *u8)) {
    unsafe { memcpy(bp, &(b._b[0]), 92 as usize); }
  }
}

/**
 * Snapshot Func row by value (host ABI sret).
 * @param a ASTArena*
 * @param ref 1-based func ref
 * @return W276_Func by value
 * PLATFORM: SHARED
 */
export function pipeline_arena_func_get_copy(a: *u8, ref: i32): W276_Func {
  let empty: W276_Func;
  let fp: *u8 = 0 as *u8;
  unsafe { memset(&(empty._b[0]), 0, 324 as usize); }
  unsafe { fp = pipeline_arena_func_ptr(a, ref); }
  if (fp != (0 as *u8)) {
    unsafe { memcpy(&(empty._b[0]), fp, 324 as usize); }
  }
  return empty;
}

/**
 * Write Func row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based func ref
 * @param f host-ABI Func value
 * PLATFORM: SHARED
 */
export function pipeline_arena_func_set_copy(a: *u8, ref: i32, f: W276_Func): void {
  let fp: *u8 = 0 as *u8;
  unsafe { fp = pipeline_arena_func_ptr(a, ref); }
  if (fp != (0 as *u8)) {
    unsafe { memcpy(fp, &(f._b[0]), 324 as usize); }
  }
}

/** Cap rename: ast_pipeline_arena_type_get_copy → pipeline_arena_type_get_copy. */
export function ast_pipeline_arena_type_get_copy(a: *u8, ref: i32): W276_Type {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Type;
  t683 = pipeline_arena_type_get_copy(a, ref);
  return t683;
}
/** Cap rename: ast_pipeline_arena_type_set_copy → pipeline_arena_type_set_copy. */
export function ast_pipeline_arena_type_set_copy(a: *u8, ref: i32, t: W276_Type): void {
  pipeline_arena_type_set_copy(a, ref, t);
}
/** Cap rename: ast_pipeline_arena_expr_get_copy → pipeline_arena_expr_get_copy. */
export function ast_pipeline_arena_expr_get_copy(a: *u8, ref: i32): W276_Expr {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Expr;
  t683 = pipeline_arena_expr_get_copy(a, ref);
  return t683;
}
/** Cap rename: ast_pipeline_arena_expr_set_copy → pipeline_arena_expr_set_copy. */
export function ast_pipeline_arena_expr_set_copy(a: *u8, ref: i32, e: W276_Expr): void {
  pipeline_arena_expr_set_copy(a, ref, e);
}
/** Cap rename: ast_pipeline_arena_block_get_copy → pipeline_arena_block_get_copy. */
export function ast_pipeline_arena_block_get_copy(a: *u8, ref: i32): W276_Block {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Block;
  t683 = pipeline_arena_block_get_copy(a, ref);
  return t683;
}
/** Cap rename: ast_pipeline_arena_block_set_copy → pipeline_arena_block_set_copy. */
export function ast_pipeline_arena_block_set_copy(a: *u8, ref: i32, b: W276_Block): void {
  pipeline_arena_block_set_copy(a, ref, b);
}
/** Cap rename: ast_pipeline_arena_func_get_copy → pipeline_arena_func_get_copy. */
export function ast_pipeline_arena_func_get_copy(a: *u8, ref: i32): W276_Func {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Func;
  t683 = pipeline_arena_func_get_copy(a, ref);
  return t683;
}
/** Cap rename: ast_pipeline_arena_func_set_copy → pipeline_arena_func_set_copy. */
export function ast_pipeline_arena_func_set_copy(a: *u8, ref: i32, f: W276_Func): void {
  pipeline_arena_func_set_copy(a, ref, f);
}

/**
 * Cap get with ref<=0 → zero Type (else get_copy).
 * @param a ASTArena*
 * @param ref type ref; <=0 yields empty
 * @return W276_Type by value
 * PLATFORM: SHARED
 */
export function ast_ast_arena_type_get(a: *u8, ref: i32): W276_Type {
  /* wave689: no tail-forward — the pure backend's `return f(args)` for a
   * struct-returning callee forwards (sret-buf, args...) correctly, but the
   * w683 audit found the family inconsistent; keep every struct-returning
   * wrapper in the explicit-temp form so each hop passes the sret buffer
   * deliberately (buf in rdi, then a, then ref). PLATFORM: SHARED. */
  let t: W276_Type;
  if (ref <= 0) {
    t = empty_type_row();
    return t;
  }
  t = pipeline_arena_type_get_copy(a, ref);
  return t;
}

/**
 * Zero W276_Type row (shared by get wrappers' ref<=0 path).
 * wave689 helper. PLATFORM: SHARED.
 */
function empty_type_row(): W276_Type {
  let e: W276_Type;
  unsafe { memset(&(e._b[0]), 0, 532 as usize); }
  return e;
}
/** Cap set → pipeline_arena_type_set_copy. */
export function ast_ast_arena_type_set(a: *u8, ref: i32, t: W276_Type): void {
  pipeline_arena_type_set_copy(a, ref, t);
}
/** Cap expr get → get_copy. */
export function ast_ast_arena_expr_get(a: *u8, ref: i32): W276_Expr {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Expr;
  t683 = pipeline_arena_expr_get_copy(a, ref);
  return t683;
}
/** Cap expr set → set_copy. */
export function ast_ast_arena_expr_set(a: *u8, ref: i32, e: W276_Expr): void {
  pipeline_arena_expr_set_copy(a, ref, e);
}
/** Cap block get → get_copy. */
export function ast_ast_arena_block_get(a: *u8, ref: i32): W276_Block {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Block;
  t683 = pipeline_arena_block_get_copy(a, ref);
  return t683;
}
/** Cap block set → set_copy. */
export function ast_ast_arena_block_set(a: *u8, ref: i32, b: W276_Block): void {
  pipeline_arena_block_set_copy(a, ref, b);
}
/** Cap func get → get_copy. */
export function ast_ast_arena_func_get(a: *u8, ref: i32): W276_Func {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Func;
  t683 = pipeline_arena_func_get_copy(a, ref);
  return t683;
}
/** Cap func set → set_copy. */
export function ast_ast_arena_func_set(a: *u8, ref: i32, f: W276_Func): void {
  pipeline_arena_func_set_copy(a, ref, f);
}

/** Short alias: ast_arena_type_get → ast_ast_arena_type_get.
 * wave683: explicit temp (NOT a tail `return f(...)` forward) — the pure
 * backend's tail-forward path drops the hidden sret pointer when
 * forwarding a by-value struct return (outer passed (a,ref) as ordinary
 * args while the inner reads sret layout: real arena discarded, ref=1
 * read as arena — force-chain arena=1 crash). A named temp forces the
 * struct through memory so both sides use the ordinary call ABI for
 * the inner call and the outer's own sret buffer is filled by the
 * return-copy path. PLATFORM: SHARED. */
export function ast_arena_type_get(a: *u8, ref: i32): W276_Type {
  let t: W276_Type;
  t = ast_ast_arena_type_get(a, ref);
  return t;
}
/** Short alias: ast_arena_type_set → ast_ast_arena_type_set. */
export function ast_arena_type_set(a: *u8, ref: i32, t: W276_Type): void {
  ast_ast_arena_type_set(a, ref, t);
}
/** Short alias: ast_arena_expr_get → ast_ast_arena_expr_get. */
export function ast_arena_expr_get(a: *u8, ref: i32): W276_Expr {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Expr;
  t683 = ast_ast_arena_expr_get(a, ref);
  return t683;
}
/** Short alias: ast_arena_expr_set → ast_ast_arena_expr_set. */
export function ast_arena_expr_set(a: *u8, ref: i32, e: W276_Expr): void {
  ast_ast_arena_expr_set(a, ref, e);
}
/** Short alias: ast_arena_block_get → ast_ast_arena_block_get. */
export function ast_arena_block_get(a: *u8, ref: i32): W276_Block {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Block;
  t683 = ast_ast_arena_block_get(a, ref);
  return t683;
}
/** Short alias: ast_arena_block_set → ast_ast_arena_block_set. */
export function ast_arena_block_set(a: *u8, ref: i32, b: W276_Block): void {
  ast_ast_arena_block_set(a, ref, b);
}
/** Short alias: ast_arena_func_get → ast_ast_arena_func_get. */
export function ast_arena_func_get(a: *u8, ref: i32): W276_Func {
  /* wave683: explicit temp, not tail-forward — the pure backend drops
   * the hidden sret pointer on struct-return tail forwards (arena=1
   * class). PLATFORM: SHARED. */
  let t683: W276_Func;
  t683 = ast_ast_arena_func_get(a, ref);
  return t683;
}
/** Short alias: ast_arena_func_set → ast_ast_arena_func_set. */
export function ast_arena_func_set(a: *u8, ref: i32, f: W276_Func): void {
  ast_ast_arena_func_set(a, ref, f);
}

/* wave517: float bits authority → runtime_pipeline_abi_value_abi_float_bits_thin.x
 * (tipU Soft Cap peer; Ubuntu tip CG002 on sret monolith). Do not re-add bodies. */

/**
 * Pack IEEE f64 (lo/hi i32 parts) → f32 bits as i32.
 * PLATFORM: SHARED host float conversion (not freestanding-portable).
 */
export function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32 {
  let dv: f64 = 0.0;
  let fv: f32 = 0.0;
  let fb: i32 = 0;
  let parts: i32[2] = [];
  parts[0] = lo;
  parts[1] = hi;
  unsafe { memcpy((&dv) as *u8, (&(parts[0])) as *u8, 8 as usize); }
  fv = dv as f32;
  unsafe { memcpy((&fb) as *u8, (&fv) as *u8, 4 as usize); }
  return fb;
}

/**
 * Pack f32 bits → f64 lo half (low 32 of IEEE u64).
 * PLATFORM: SHARED
 */
export function glue_ieee_f32_bits_to_f64_lo(fb: i32): i32 {
  let fv: f32 = 0.0;
  let dv: f64 = 0.0;
  let u64v: i64 = 0;
  unsafe { memcpy((&fv) as *u8, (&fb) as *u8, 4 as usize); }
  dv = fv as f64;
  unsafe { memcpy((&u64v) as *u8, (&dv) as *u8, 8 as usize); }
  return (u64v & 4294967295) as i32;
}

/**
 * Pack f32 bits → f64 hi half (high 32 of IEEE u64).
 * PLATFORM: SHARED
 */
export function glue_ieee_f32_bits_to_f64_hi(fb: i32): i32 {
  let fv: f32 = 0.0;
  let dv: f64 = 0.0;
  let u64v: i64 = 0;
  unsafe { memcpy((&fv) as *u8, (&fb) as *u8, 4 as usize); }
  dv = fv as f64;
  unsafe { memcpy((&u64v) as *u8, (&dv) as *u8, 8 as usize); }
  return ((u64v >> 32) & 4294967295) as i32;
}

/**
 * Convert i32 → f32 bits (host cast).
 * PLATFORM: SHARED
 */
export function glue_i32_to_f32_bits(v: i32): i32 {
  let fv: f32 = v as f32;
  let fb: i32 = 0;
  unsafe { memcpy((&fb) as *u8, (&fv) as *u8, 4 as usize); }
  return fb;
}

/**
 * Convert i64 → f32 bits (host cast).
 * PLATFORM: SHARED
 */
export function glue_i64_to_f32_bits(v: i64): i32 {
  let fv: f32 = v as f32;
  let fb: i32 = 0;
  unsafe { memcpy((&fb) as *u8, (&fv) as *u8, 4 as usize); }
  return fb;
}

/**
 * Convert i64 → f64 bits into optional lo/hi out params.
 * @param v integer value
 * @param lo optional low 32 of IEEE u64
 * @param hi optional high 32 of IEEE u64
 * PLATFORM: SHARED
 */
export function glue_i64_to_f64_bits(v: i64, lo: *i32, hi: *i32): void {
  let dv: f64 = v as f64;
  let u: i64 = 0;
  unsafe { memcpy((&u) as *u8, (&dv) as *u8, 8 as usize); }
  if (lo != (0 as *i32)) {
    unsafe { (*lo) = (u & 4294967295) as i32; }
  }
  if (hi != (0 as *i32)) {
    unsafe { (*hi) = ((u >> 32) & 4294967295) as i32; }
  }
}
