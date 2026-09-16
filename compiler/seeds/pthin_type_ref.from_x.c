/* seeds/pthin_type_ref.from_x.c — G-02f-280 P2 parser thin P3 type_ref
 * Logic source: src/asm/pthin_type_ref.x
 * Hybrid: XLANG_PTHIN_TYPE_REF_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_type_ref_slice.inc
 * Types must match parser_asm_thin_c.from_x.c (layout-locked).
 *
 * Hybrid P3b/P3c/P3d/P3e/P3g/P3h/P3i/P3j/P3k/P3l (XLANG_PTHIN_TYPE_REF_BODIES_FROM_X): portable kind / dyn /
 * vector-ident bodies, type-inst mangle, consume_qualified,
 * type_angle_close, and TYPE_DYN wrap dest-buffer come from
 * pthin_type_ref.x; this TU keeps slice trampolines plus arena parse.
 * XLANG_PTHIN_TYPE_REF_POSTFIX_FROM_X (P3g) skips postfix array/slice C
 * twins when both parse_x symbols are present (missing postfix keeps the
 * C twins without dropping P3b–P3e). XLANG_PTHIN_TYPE_REF_PREFIX_FROM_X
 * (P3h) skips prefix `[N]T` / `[]T` C twin when prefix_x is present
 * (missing prefix keeps the C twin without dropping P3g).
 * XLANG_PTHIN_TYPE_REF_FN_FROM_X (P3i) skips type-position
 * `function(...): Ret` C twin when fn_x is present (missing fn keeps
 * the C twin without dropping P3h). XLANG_PTHIN_TYPE_REF_STAR_FROM_X
 * (P3j) skips prefix `*T` C twin when star_x is present (missing star
 * keeps the C twin without dropping P3i). XLANG_PTHIN_TYPE_REF_LINEAR_FROM_X
 * (P3k) skips IDENT `Linear(T)` C twin when linear_x is present (missing
 * linear keeps the C twin without dropping P3j). XLANG_PTHIN_TYPE_REF_VEC_FROM_X
 * (P3l) skips builtin vec-token C twin when vec_x is present (missing vec
 * keeps the C twin without dropping P3k). TYPE_DYN / TYPE_FN writers
 * pipeline_type_init_dyn_c / pipeline_type_init_fn_c live here
 * (consumer-wave; do not FORCE pabi mega). Mangle C twins live in
 * primary.inc (7-arg trampoline holds suf[64]). Cold: no
 * BODIES/POSTFIX/PREFIX/FN/STAR/LINEAR/VEC define, full .inc.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

/* Helpers from thin mega rest. */
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out,
                                                 struct parser_asm_lexer_result *r);
extern void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start,
                                                   int32_t nlen, uint8_t *out);
extern void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source,
                                                          size_t end_pos, int32_t nlen, uint8_t *out);
extern int32_t parser_asm_is_pointee_type_token_c(int32_t kind);

/* PLATFORM: SHARED — 7.2.1 P3b Route C (2026-09-13).
 * pthin_type_ref.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_FUNCTION == 1, "type_ref.x TOKEN_FUNCTION pin");
_Static_assert((int)TOKEN_IMPL == 50, "type_ref.x TOKEN_IMPL pin");
_Static_assert((int)TOKEN_IDENT == 59, "type_ref.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_I32 == 60, "type_ref.x TOKEN_I32 pin");
_Static_assert((int)TOKEN_BOOL == 61, "type_ref.x TOKEN_BOOL pin");
_Static_assert((int)TOKEN_U8 == 62, "type_ref.x TOKEN_U8 pin");
_Static_assert((int)TOKEN_U32 == 63, "type_ref.x TOKEN_U32 pin");
_Static_assert((int)TOKEN_U64 == 64, "type_ref.x TOKEN_U64 pin");
_Static_assert((int)TOKEN_I64 == 65, "type_ref.x TOKEN_I64 pin");
_Static_assert((int)TOKEN_USIZE == 66, "type_ref.x TOKEN_USIZE pin");
_Static_assert((int)TOKEN_ISIZE == 67, "type_ref.x TOKEN_ISIZE pin");
_Static_assert((int)TOKEN_I32X4 == 68, "type_ref.x TOKEN_I32X4 pin");
_Static_assert((int)TOKEN_I32X8 == 69, "type_ref.x TOKEN_I32X8 pin");
_Static_assert((int)TOKEN_I32X16 == 70, "type_ref.x TOKEN_I32X16 pin");
_Static_assert((int)TOKEN_U32X4 == 71, "type_ref.x TOKEN_U32X4 pin");
_Static_assert((int)TOKEN_U32X8 == 72, "type_ref.x TOKEN_U32X8 pin");
_Static_assert((int)TOKEN_U32X16 == 73, "type_ref.x TOKEN_U32X16 pin");
_Static_assert((int)TOKEN_F32X4 == 74, "type_ref.x TOKEN_F32X4 pin");
_Static_assert((int)TOKEN_F32 == 77, "type_ref.x TOKEN_F32 pin");
_Static_assert((int)TOKEN_F64 == 78, "type_ref.x TOKEN_F64 pin");
_Static_assert((int)TOKEN_VOID == 79, "type_ref.x TOKEN_VOID pin");
_Static_assert((int)TOKEN_INT == 80, "type_ref.x TOKEN_INT pin");
_Static_assert((int)TOKEN_LPAREN == 82, "type_ref.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_RPAREN == 83, "type_ref.x TOKEN_RPAREN pin");
_Static_assert((int)TOKEN_LBRACKET == 86, "type_ref.x TOKEN_LBRACKET pin");
_Static_assert((int)TOKEN_RBRACKET == 87, "type_ref.x TOKEN_RBRACKET pin");
_Static_assert((int)TOKEN_COMMA == 90, "type_ref.x TOKEN_COMMA pin");
_Static_assert((int)TOKEN_COLON == 91, "type_ref.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_DOT == 92, "type_ref.x TOKEN_DOT pin");
_Static_assert((int)TOKEN_STAR == 98, "type_ref.x TOKEN_STAR pin");
_Static_assert((int)TOKEN_RSHIFT == 105, "type_ref.x TOKEN_RSHIFT pin");
_Static_assert((int)TOKEN_LT == 120, "type_ref.x TOKEN_LT pin");
_Static_assert((int)TOKEN_GT == 121, "type_ref.x TOKEN_GT pin");

#ifdef XLANG_PTHIN_TYPE_REF_BODIES_FROM_X
/* .x product bodies (same C names for Route C; buf split for dyn). */
extern int32_t parser_asm_type_ref_token_starts_type_c(int32_t kind);
extern int32_t parser_asm_type_ref_builtin_kind_ord_c(int32_t tok_kind);
extern int32_t parser_asm_type_ref_ident_is_dyn_buf_c(uint8_t *data, size_t length, size_t token_start,
                                                     int32_t ident_len);
extern int32_t parser_asm_vector_type_ident_pack_c(uint8_t *data, size_t length, size_t token_start,
                                                  int32_t ident_len);
extern int32_t parser_asm_wrap_registered_trait_as_dyn_into_c(void *arena, int32_t named_tr, uint8_t *name_scratch);
extern int32_t parser_asm_alloc_dyn_type_ref_into_c(void *arena, int32_t inner_tr, uint8_t *name_scratch);

static int32_t parser_asm_type_ref_ident_is_dyn_c(struct parser_asm_slice_u8 *source,
                                                  struct parser_asm_lexer_result *r) {
  if (!source || !r)
    return 0;
  if (r->tok.kind != (int32_t)TOKEN_IDENT || r->tok.ident_len != 3)
    return 0;
  return parser_asm_type_ref_ident_is_dyn_buf_c(source->data, source->length, r->token_start, r->tok.ident_len);
}
#endif

/* P3e consumer-wave writer. pipeline_abi inject-only skips new rest
 * symbols, so this T lives in the P3 seed (recompiled every g05).
 * Pointer = pipeline_arena_type_ptr. Layout ≡ Type LE:
 * kind@0 name[256]@4 name_len@260 elem@264 array_size@268
 * region_label[256]@272 region_label_len@528 size=532.
 * Do not reuse pipeline_type_init_compound_kind_at (kind_ord cap 15;
 * pipe_ty_kind_from_ord clamps >16 to TYPE_I32). PLATFORM: SHARED. */
extern void *pipeline_arena_type_ptr(void *a, int32_t ref);
typedef struct P3e_Type {
  int32_t kind;
  uint8_t name[256];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[256];
  int32_t region_label_len;
} P3e_Type;
_Static_assert(offsetof(P3e_Type, kind) == 0, "P3e Type.kind offset");
_Static_assert(offsetof(P3e_Type, name) == 4, "P3e Type.name offset");
_Static_assert(offsetof(P3e_Type, name_len) == 260, "P3e Type.name_len offset");
_Static_assert(offsetof(P3e_Type, elem_type_ref) == 264, "P3e Type.elem_type_ref offset");
_Static_assert(offsetof(P3e_Type, array_size) == 268, "P3e Type.array_size offset");
_Static_assert(offsetof(P3e_Type, region_label) == 272, "P3e Type.region_label offset");
_Static_assert(offsetof(P3e_Type, region_label_len) == 528, "P3e Type.region_label_len offset");
_Static_assert(sizeof(P3e_Type) == 532, "P3e Type size ≡ pipe_ty_slot_size");
void pipeline_type_init_dyn_c(void *a, int32_t ref, int32_t inner_tr, uint8_t *name, int32_t nlen) {
  P3e_Type *t;
  int32_t i;
  if (!a || ref <= 0)
    return;
  t = (P3e_Type *)pipeline_arena_type_ptr(a, ref);
  if (!t)
    return;
  t->kind = 17; /* PARSER_ASM_TYPE_DYN — write raw; do not go through pipe_ty_kind_from_ord. */
  t->elem_type_ref = inner_tr;
  t->array_size = 0;
  t->region_label_len = 0;
  t->name_len = 0;
  if (name && nlen > 0 && nlen < 128) {
    for (i = 0; i < nlen; i++)
      t->name[i] = name[i];
    t->name_len = nlen;
  }
}

/**
 * PLATFORM: SHARED — P3g consumer-wave writer. Stamp TYPE_SLICE (kind=11)
 * + elem + optional region_label. Do not reuse pipeline_type_set_region_label_at
 * (that helper zeros t[144..271], wiping elem_type_ref / array_size on the
 * current Type layout). Do not FORCE pabi mega. Label cap matches the C
 * twin (ident_len 1..63). Unlabeled T[] passes nlen=0.
 */
void pipeline_type_init_slice_c(void *a, int32_t ref, int32_t elem_tr, uint8_t *label, int32_t nlen) {
  P3e_Type *t;
  int32_t i;
  if (!a || ref <= 0)
    return;
  t = (P3e_Type *)pipeline_arena_type_ptr(a, ref);
  if (!t)
    return;
  t->kind = 11; /* PARSER_ASM_TYPE_SLICE */
  t->elem_type_ref = elem_tr;
  t->array_size = 0;
  t->name_len = 0;
  t->region_label_len = 0;
  for (i = 0; i < 256; i++)
    t->region_label[i] = 0;
  if (label && nlen > 0 && nlen <= 63) {
    for (i = 0; i < nlen; i++)
      t->region_label[i] = label[i];
    t->region_label_len = nlen;
  }
}

/**
 * PLATFORM: SHARED — P3i consumer-wave writer. Stamp TYPE_FN (kind=18)
 * + return elem + n_params in array_size. Do not reuse
 * pipeline_type_init_compound_kind_at (kind_ord cap 15;
 * pipe_ty_kind_from_ord clamps >16 to TYPE_I32). Do not FORCE pabi mega.
 * Params go through existing pipeline_type_append_type_arg (G.7).
 */
void pipeline_type_init_fn_c(void *a, int32_t ref, int32_t ret_tr, int32_t n_params) {
  P3e_Type *t;
  if (!a || ref <= 0)
    return;
  t = (P3e_Type *)pipeline_arena_type_ptr(a, ref);
  if (!t)
    return;
  t->kind = 18; /* PARSER_ASM_TYPE_FN — write raw. */
  t->elem_type_ref = ret_tr;
  t->array_size = n_params;
  t->name_len = 0;
  t->region_label_len = 0;
}

/* mega rest 中为 static；本 TU 自备等价实现（layout 一致）。 */
static void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out,
                                               struct parser_asm_lexer_result r) {
  if (!out)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

#include "parser_asm_type_ref_slice.inc"

_Static_assert(PARSER_ASM_TYPE_I32 == 0, "type_ref.x TYPE_I32 pin");
_Static_assert(PARSER_ASM_TYPE_BOOL == 1, "type_ref.x TYPE_BOOL pin");
_Static_assert(PARSER_ASM_TYPE_U8 == 2, "type_ref.x TYPE_U8 pin");
_Static_assert(PARSER_ASM_TYPE_U32 == 3, "type_ref.x TYPE_U32 pin");
_Static_assert(PARSER_ASM_TYPE_U64 == 4, "type_ref.x TYPE_U64 pin");
_Static_assert(PARSER_ASM_TYPE_I64 == 5, "type_ref.x TYPE_I64 pin");
_Static_assert(PARSER_ASM_TYPE_USIZE == 6, "type_ref.x TYPE_USIZE pin");
_Static_assert(PARSER_ASM_TYPE_ISIZE == 7, "type_ref.x TYPE_ISIZE pin");
_Static_assert(PARSER_ASM_TYPE_NAMED == 8, "type_ref.x TYPE_NAMED pin");
_Static_assert(PARSER_ASM_TYPE_PTR == 9, "type_ref.x TYPE_PTR pin");
_Static_assert(PARSER_ASM_TYPE_ARRAY == 10, "type_ref.x TYPE_ARRAY pin");
_Static_assert(PARSER_ASM_TYPE_SLICE == 11, "type_ref.x TYPE_SLICE pin");
_Static_assert(PARSER_ASM_TYPE_DYN == 17, "type_ref.x TYPE_DYN pin");
_Static_assert(PARSER_ASM_TYPE_FN == 18, "type_ref.x TYPE_FN pin");

int labi_pthin_type_ref_slice_marker(void) {
  return 1;
}
