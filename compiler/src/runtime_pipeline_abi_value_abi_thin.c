/*
 * Thin pure: wave276 value-ABI Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c WAVE276_ARENA_VALUE_ABI_ALWAYS
 * (by-value Type/Expr/Block/Func get/set_copy + name aliases + float IEEE helpers).
 *
 * NOT portable as freestanding .x: large-struct sret/pass differs SysV x86_64 vs
 * AAPCS64. Independent C thin (Darwin additive-leaf rule). No file-local BSS.
 * Calls pipeline_arena_*_ptr (pure product / cold twin) + typeck_float64_bits_*.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc value-ABI Cap residual leave.
 */

#include <stdint.h>
#include <stddef.h>
#include <string.h>

enum { W276_TY = 532, W276_EX = 1224, W276_BL = 92, W276_FN = 324 };

struct w276_Type { uint8_t _b[W276_TY]; };
struct w276_Expr { uint8_t _b[W276_EX]; };
struct w276_Block { uint8_t _b[W276_BL]; };
struct w276_Func { uint8_t _b[W276_FN]; };

/* Pure (FROM_X) or cold twins provide these. */
extern void *pipeline_arena_type_ptr(void *a, int32_t ref);
extern void *pipeline_arena_expr_ptr(void *a, int32_t ref);
extern void *pipeline_arena_block_ptr(void *a, int32_t ref);
extern void *pipeline_arena_func_ptr(void *a, int32_t ref);
extern int typeck_float64_bits_lo(double d);
extern int typeck_float64_bits_hi(double d);

/**
 * Snapshot Type row by value (host ABI sret). Empty zero row if ptr null.
 * @param a ASTArena*
 * @param ref 1-based type ref
 */
struct w276_Type pipeline_arena_type_get_copy(void *a, int32_t ref) {
  struct w276_Type empty;
  void *tp;
  memset(&empty, 0, sizeof(empty));
  tp = pipeline_arena_type_ptr(a, ref);
  if (tp)
    memcpy(&empty, tp, (size_t)W276_TY);
  return empty;
}

/**
 * Write Type row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based type ref
 * @param t host-ABI Type value
 */
void pipeline_arena_type_set_copy(void *a, int32_t ref, struct w276_Type t) {
  void *tp = pipeline_arena_type_ptr(a, ref);
  if (tp)
    memcpy(tp, &t, (size_t)W276_TY);
}

/**
 * Snapshot Expr row by value (host ABI sret; sizeof 1224).
 * @param a ASTArena*
 * @param ref 1-based expr ref
 */
struct w276_Expr pipeline_arena_expr_get_copy(void *a, int32_t ref) {
  struct w276_Expr empty;
  void *ep;
  memset(&empty, 0, sizeof(empty));
  ep = pipeline_arena_expr_ptr(a, ref);
  if (ep)
    memcpy(&empty, ep, (size_t)W276_EX);
  return empty;
}

/**
 * Write Expr row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based expr ref
 * @param e host-ABI Expr value
 */
void pipeline_arena_expr_set_copy(void *a, int32_t ref, struct w276_Expr e) {
  void *ep = pipeline_arena_expr_ptr(a, ref);
  if (ep)
    memcpy(ep, &e, (size_t)W276_EX);
}

/**
 * Snapshot Block row by value (host ABI sret).
 * @param a ASTArena*
 * @param ref 1-based block ref
 */
struct w276_Block pipeline_arena_block_get_copy(void *a, int32_t ref) {
  struct w276_Block empty;
  void *bp;
  memset(&empty, 0, sizeof(empty));
  bp = pipeline_arena_block_ptr(a, ref);
  if (bp)
    memcpy(&empty, bp, (size_t)W276_BL);
  return empty;
}

/**
 * Write Block row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based block ref
 * @param b host-ABI Block value
 */
void pipeline_arena_block_set_copy(void *a, int32_t ref, struct w276_Block b) {
  void *bp = pipeline_arena_block_ptr(a, ref);
  if (bp)
    memcpy(bp, &b, (size_t)W276_BL);
}

/**
 * Snapshot Func row by value (host ABI sret).
 * @param a ASTArena*
 * @param ref 1-based func ref
 */
struct w276_Func pipeline_arena_func_get_copy(void *a, int32_t ref) {
  struct w276_Func empty;
  void *fp;
  memset(&empty, 0, sizeof(empty));
  fp = pipeline_arena_func_ptr(a, ref);
  if (fp)
    memcpy(&empty, fp, (size_t)W276_FN);
  return empty;
}

/**
 * Write Func row from by-value copy into arena slot.
 * @param a ASTArena*
 * @param ref 1-based func ref
 * @param f host-ABI Func value
 */
void pipeline_arena_func_set_copy(void *a, int32_t ref, struct w276_Func f) {
  void *fp = pipeline_arena_func_ptr(a, ref);
  if (fp)
    memcpy(fp, &f, (size_t)W276_FN);
}

/** Cap rename: ast_pipeline_arena_type_get_copy → pipeline_arena_type_get_copy. */
struct w276_Type ast_pipeline_arena_type_get_copy(void *a, int32_t ref) {
  return pipeline_arena_type_get_copy(a, ref);
}
/** Cap rename: ast_pipeline_arena_type_set_copy → pipeline_arena_type_set_copy. */
void ast_pipeline_arena_type_set_copy(void *a, int32_t ref, struct w276_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}
/** Cap rename: ast_pipeline_arena_expr_get_copy → pipeline_arena_expr_get_copy. */
struct w276_Expr ast_pipeline_arena_expr_get_copy(void *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}
/** Cap rename: ast_pipeline_arena_expr_set_copy → pipeline_arena_expr_set_copy. */
void ast_pipeline_arena_expr_set_copy(void *a, int32_t ref, struct w276_Expr e) {
  pipeline_arena_expr_set_copy(a, ref, e);
}
/** Cap rename: ast_pipeline_arena_block_get_copy → pipeline_arena_block_get_copy. */
struct w276_Block ast_pipeline_arena_block_get_copy(void *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
/** Cap rename: ast_pipeline_arena_block_set_copy → pipeline_arena_block_set_copy. */
void ast_pipeline_arena_block_set_copy(void *a, int32_t ref, struct w276_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
/** Cap rename: ast_pipeline_arena_func_get_copy → pipeline_arena_func_get_copy. */
struct w276_Func ast_pipeline_arena_func_get_copy(void *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
/** Cap rename: ast_pipeline_arena_func_set_copy → pipeline_arena_func_set_copy. */
void ast_pipeline_arena_func_set_copy(void *a, int32_t ref, struct w276_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}

/**
 * Cap get with ref<=0 → zero Type (else get_copy).
 * @param a ASTArena*
 * @param ref type ref; <=0 yields empty
 */
struct w276_Type ast_ast_arena_type_get(void *a, int32_t ref) {
  struct w276_Type empty;
  if (ref <= 0) {
    memset(&empty, 0, sizeof(empty));
    return empty;
  }
  return pipeline_arena_type_get_copy(a, ref);
}
/** Cap set → pipeline_arena_type_set_copy. */
void ast_ast_arena_type_set(void *a, int32_t ref, struct w276_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}
/** Cap expr get → get_copy. */
struct w276_Expr ast_ast_arena_expr_get(void *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}
/** Cap expr set → set_copy. */
void ast_ast_arena_expr_set(void *a, int32_t ref, struct w276_Expr e) {
  pipeline_arena_expr_set_copy(a, ref, e);
}
/** Cap block get → get_copy. */
struct w276_Block ast_ast_arena_block_get(void *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
/** Cap block set → set_copy. */
void ast_ast_arena_block_set(void *a, int32_t ref, struct w276_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
/** Cap func get → get_copy. */
struct w276_Func ast_ast_arena_func_get(void *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
/** Cap func set → set_copy. */
void ast_ast_arena_func_set(void *a, int32_t ref, struct w276_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}

/** Short alias: ast_arena_type_get → ast_ast_arena_type_get. */
struct w276_Type ast_arena_type_get(void *a, int32_t ref) {
  return ast_ast_arena_type_get(a, ref);
}
/** Short alias: ast_arena_type_set → ast_ast_arena_type_set. */
void ast_arena_type_set(void *a, int32_t ref, struct w276_Type t) {
  ast_ast_arena_type_set(a, ref, t);
}
/** Short alias: ast_arena_expr_get → ast_ast_arena_expr_get. */
struct w276_Expr ast_arena_expr_get(void *a, int32_t ref) {
  return ast_ast_arena_expr_get(a, ref);
}
/** Short alias: ast_arena_expr_set → ast_ast_arena_expr_set. */
void ast_arena_expr_set(void *a, int32_t ref, struct w276_Expr e) {
  ast_ast_arena_expr_set(a, ref, e);
}
/** Short alias: ast_arena_block_get → ast_ast_arena_block_get. */
struct w276_Block ast_arena_block_get(void *a, int32_t ref) {
  return ast_ast_arena_block_get(a, ref);
}
/** Short alias: ast_arena_block_set → ast_ast_arena_block_set. */
void ast_arena_block_set(void *a, int32_t ref, struct w276_Block b) {
  ast_ast_arena_block_set(a, ref, b);
}
/** Short alias: ast_arena_func_get → ast_ast_arena_func_get. */
struct w276_Func ast_arena_func_get(void *a, int32_t ref) {
  return ast_ast_arena_func_get(a, ref);
}
/** Short alias: ast_arena_func_set → ast_ast_arena_func_set. */
void ast_arena_func_set(void *a, int32_t ref, struct w276_Func f) {
  ast_ast_arena_func_set(a, ref, f);
}

/**
 * Expr float bits lo: kind==1 uses live f64@+24 via typeck; else stored lo@+684.
 * Layout LE: kind@0, float_val@24, float_bits_lo@684.
 * @param a ASTArena*
 * @param expr_ref 1-based expr ref
 */
int32_t pipeline_expr_float_bits_lo_at(void *a, int32_t expr_ref) {
  uint8_t *ex = (uint8_t *)pipeline_arena_expr_ptr(a, expr_ref);
  int32_t kind, lo;
  double fv;
  if (!ex)
    return 0;
  memcpy(&kind, ex + 0, 4);
  if (kind == 1) {
    memcpy(&fv, ex + 24, 8);
    return (int32_t)typeck_float64_bits_lo(fv);
  }
  memcpy(&lo, ex + 684, 4);
  return lo;
}

/**
 * Expr float bits hi: kind==1 uses live f64@+24 via typeck; else stored hi@+688.
 * @param a ASTArena*
 * @param expr_ref 1-based expr ref
 */
int32_t pipeline_expr_float_bits_hi_at(void *a, int32_t expr_ref) {
  uint8_t *ex = (uint8_t *)pipeline_arena_expr_ptr(a, expr_ref);
  int32_t kind, hi;
  double fv;
  if (!ex)
    return 0;
  memcpy(&kind, ex + 0, 4);
  if (kind == 1) {
    memcpy(&fv, ex + 24, 8);
    return (int32_t)typeck_float64_bits_hi(fv);
  }
  memcpy(&hi, ex + 688, 4);
  return hi;
}

/**
 * Materialize typeck float bits from Expr float_val@+24 into lo@684/hi@688.
 * Bounds-check via arena num_exprs@+4.
 * @param a ASTArena*
 * @param expr_ref 1-based expr ref
 */
void pipeline_expr_typeck_set_float_bits_from_val(void *a, int32_t expr_ref) {
  uint8_t *ex;
  int32_t ne;
  double fv;
  int32_t lo, hi;
  if (!a || expr_ref <= 0)
    return;
  memcpy(&ne, (uint8_t *)a + 4, 4);
  if (expr_ref > ne)
    return;
  ex = (uint8_t *)pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  memcpy(&fv, ex + 24, 8);
  lo = (int32_t)typeck_float64_bits_lo(fv);
  hi = (int32_t)typeck_float64_bits_hi(fv);
  memcpy(ex + 684, &lo, 4);
  memcpy(ex + 688, &hi, 4);
}

/**
 * Pack IEEE f64 (lo/hi i32 parts) → f32 bits as i32.
 * PLATFORM: SHARED host float conversion (not freestanding-portable).
 */
int32_t glue_ieee_f64_bits_to_f32_bits(int32_t lo, int32_t hi) {
  double dv;
  float fv;
  uint32_t fb;
  int32_t parts[2];
  parts[0] = lo;
  parts[1] = hi;
  memcpy(&dv, parts, sizeof(dv));
  fv = (float)dv;
  memcpy(&fb, &fv, sizeof(fb));
  return (int32_t)fb;
}

/** Pack f32 bits → f64 lo half (low 32 of IEEE u64). */
int32_t glue_ieee_f32_bits_to_f64_lo(int32_t fb) {
  float fv;
  double dv;
  uint64_t u64;
  memcpy(&fv, &fb, sizeof(fv));
  dv = (double)fv;
  memcpy(&u64, &dv, sizeof(u64));
  return (int32_t)(u64 & 0xffffffffu);
}

/** Pack f32 bits → f64 hi half (high 32 of IEEE u64). */
int32_t glue_ieee_f32_bits_to_f64_hi(int32_t fb) {
  float fv;
  double dv;
  uint64_t u64;
  memcpy(&fv, &fb, sizeof(fv));
  dv = (double)fv;
  memcpy(&u64, &dv, sizeof(u64));
  return (int32_t)(u64 >> 32);
}

/** Convert i32 → f32 bits (host cast). */
int32_t glue_i32_to_f32_bits(int32_t v) {
  float fv = (float)v;
  uint32_t fb = 0;
  memcpy(&fb, &fv, sizeof(fb));
  return (int32_t)fb;
}

/** Convert i64 → f32 bits (host cast). */
int32_t glue_i64_to_f32_bits(int64_t v) {
  float fv = (float)v;
  uint32_t fb = 0;
  memcpy(&fb, &fv, sizeof(fb));
  return (int32_t)fb;
}

/**
 * Convert i64 → f64 bits into optional lo/hi out params.
 * @param v integer value
 * @param lo optional low 32 of IEEE u64
 * @param hi optional high 32 of IEEE u64
 */
void glue_i64_to_f64_bits(int64_t v, int32_t *lo, int32_t *hi) {
  double dv = (double)v;
  uint64_t u = 0;
  memcpy(&u, &dv, sizeof(u));
  if (lo)
    *lo = (int32_t)(u & 0xffffffffu);
  if (hi)
    *hi = (int32_t)(u >> 32);
}
