/* wave323 codegen M4 cold assemble from .x (7.4.2):
 *   base = tip xlang -E src/codegen/codegen.x
 *   product struct rename: CodegenOutBuf → codegen_CodegenOutBuf
 *   module-prefix rename: bare export faces → codegen_*
 *   X-mangle demangle (25): *_Type_ptr_*_reti32 → short product faces
 *   Cap residual append = seeds/codegen_cap_residual.from_x.c
 * G.7: product authority = codegen.x + companions; pin seed archaeology only.
 * PLATFORM: SHARED freestanding codegen cold assemble.
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
#ifndef XLANG_SLICE_LAYOUTS
#define XLANG_SLICE_LAYOUTS
struct xlang_slice_uint8_t { uint8_t *data; size_t length; };
struct xlang_slice_int8_t { int8_t *data; size_t length; };
struct xlang_slice_int16_t { int16_t *data; size_t length; };
struct xlang_slice_uint16_t { uint16_t *data; size_t length; };
struct xlang_slice_int { int *data; size_t length; };
struct xlang_slice_int32_t { int32_t *data; size_t length; };
struct xlang_slice_uint32_t { uint32_t *data; size_t length; };
struct xlang_slice_int64_t { int64_t *data; size_t length; };
struct xlang_slice_uint64_t { uint64_t *data; size_t length; };
struct xlang_slice_size_t { size_t *data; size_t length; };
struct xlang_slice_ssize_t { ssize_t *data; size_t length; };
struct xlang_slice_float { float *data; size_t length; };
struct xlang_slice_double { double *data; size_t length; };
struct xlang_slice_xlang_slice_uint8_t { struct xlang_slice_uint8_t *data; size_t length; };
struct xlang_slice_xlang_slice_int8_t { struct xlang_slice_int8_t *data; size_t length; };
struct xlang_slice_xlang_slice_int16_t { struct xlang_slice_int16_t *data; size_t length; };
struct xlang_slice_xlang_slice_uint16_t { struct xlang_slice_uint16_t *data; size_t length; };
struct xlang_slice_xlang_slice_int { struct xlang_slice_int *data; size_t length; };
struct xlang_slice_xlang_slice_int32_t { struct xlang_slice_int32_t *data; size_t length; };
struct xlang_slice_xlang_slice_uint32_t { struct xlang_slice_uint32_t *data; size_t length; };
struct xlang_slice_xlang_slice_int64_t { struct xlang_slice_int64_t *data; size_t length; };
struct xlang_slice_xlang_slice_uint64_t { struct xlang_slice_uint64_t *data; size_t length; };
struct xlang_slice_xlang_slice_size_t { struct xlang_slice_size_t *data; size_t length; };
struct xlang_slice_xlang_slice_ssize_t { struct xlang_slice_ssize_t *data; size_t length; };
struct xlang_slice_xlang_slice_float { struct xlang_slice_float *data; size_t length; };
struct xlang_slice_xlang_slice_double { struct xlang_slice_double *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_uint8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_int8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_int16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_uint16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_int *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_int32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_uint32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_slice_xlang_slice_int64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_uint64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_size_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_ssize_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_float *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_double *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang_slice_int *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_uint32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_size_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_xlang_slice_ssize_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_float *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_float *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float *data; size_t length; };
struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };
#endif
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_LINEAR, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS, ast_ExprKind_EXPR_AWAIT, ast_ExprKind_EXPR_RUN, ast_ExprKind_EXPR_SPAWN, ast_ExprKind_EXPR_TRY_PROPAGATE, ast_ExprKind_EXPR_STRING_LIT };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type {
  int32_t kind;
  uint8_t name[128];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[128];
  int32_t region_label_len;
};

struct xlang_slice_ast_Type { struct ast_Type *data; size_t length; };

struct xlang_slice_xlang_slice_ast_Type { struct xlang_slice_ast_Type *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_Type { struct xlang_slice_xlang_slice_ast_Type *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Type { struct xlang_slice_xlang_slice_xlang_slice_ast_Type *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Type { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Type *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Type { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Type *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Type { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Type *data; size_t length; };

struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[128];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[128];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[128];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[128];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};

struct xlang_slice_ast_Expr { struct ast_Expr *data; size_t length; };

struct xlang_slice_xlang_slice_ast_Expr { struct xlang_slice_ast_Expr *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_Expr { struct xlang_slice_xlang_slice_ast_Expr *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Expr { struct xlang_slice_xlang_slice_xlang_slice_ast_Expr *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Expr { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Expr *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Expr { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Expr *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Expr { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Expr *data; size_t length; };

struct ast_ConstDecl {
  uint8_t name[128];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
};

struct xlang_slice_ast_ConstDecl { struct ast_ConstDecl *data; size_t length; };

struct xlang_slice_xlang_slice_ast_ConstDecl { struct xlang_slice_ast_ConstDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl { struct xlang_slice_xlang_slice_ast_ConstDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl { struct xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ConstDecl *data; size_t length; };

struct ast_LetDecl {
  uint8_t name[128];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
};

struct xlang_slice_ast_LetDecl { struct ast_LetDecl *data; size_t length; };

struct xlang_slice_xlang_slice_ast_LetDecl { struct xlang_slice_ast_LetDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_LetDecl { struct xlang_slice_xlang_slice_ast_LetDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LetDecl { struct xlang_slice_xlang_slice_xlang_slice_ast_LetDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LetDecl { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LetDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LetDecl { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LetDecl *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LetDecl { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LetDecl *data; size_t length; };

struct ast_WhileLoop {
  int32_t cond_ref;
  int32_t body_ref;
};

struct xlang_slice_ast_WhileLoop { struct ast_WhileLoop *data; size_t length; };

struct xlang_slice_xlang_slice_ast_WhileLoop { struct xlang_slice_ast_WhileLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop { struct xlang_slice_xlang_slice_ast_WhileLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop { struct xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_WhileLoop *data; size_t length; };

struct ast_ForLoop {
  int32_t init_ref;
  int32_t cond_ref;
  int32_t step_ref;
  int32_t body_ref;
};

struct xlang_slice_ast_ForLoop { struct ast_ForLoop *data; size_t length; };

struct xlang_slice_xlang_slice_ast_ForLoop { struct xlang_slice_ast_ForLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_ForLoop { struct xlang_slice_xlang_slice_ast_ForLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ForLoop { struct xlang_slice_xlang_slice_xlang_slice_ast_ForLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ForLoop { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ForLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ForLoop { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ForLoop *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ForLoop { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ForLoop *data; size_t length; };

struct ast_IfStmt {
  int32_t cond_ref;
  int32_t then_body_ref;
  int32_t else_body_ref;
};

struct xlang_slice_ast_IfStmt { struct ast_IfStmt *data; size_t length; };

struct xlang_slice_xlang_slice_ast_IfStmt { struct xlang_slice_ast_IfStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_IfStmt { struct xlang_slice_xlang_slice_ast_IfStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_IfStmt { struct xlang_slice_xlang_slice_xlang_slice_ast_IfStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_IfStmt { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_IfStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_IfStmt { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_IfStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_IfStmt { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_IfStmt *data; size_t length; };

struct ast_StmtOrderItem {
  uint8_t kind;
  int32_t idx;
};

struct xlang_slice_ast_StmtOrderItem { struct ast_StmtOrderItem *data; size_t length; };

struct xlang_slice_xlang_slice_ast_StmtOrderItem { struct xlang_slice_ast_StmtOrderItem *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem { struct xlang_slice_xlang_slice_ast_StmtOrderItem *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem { struct xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StmtOrderItem *data; size_t length; };

struct ast_LabeledStmt {
  uint8_t label[128];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[128];
  int32_t goto_target_len;
  int32_t return_expr_ref;
};

struct xlang_slice_ast_LabeledStmt { struct ast_LabeledStmt *data; size_t length; };

struct xlang_slice_xlang_slice_ast_LabeledStmt { struct xlang_slice_ast_LabeledStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt { struct xlang_slice_xlang_slice_ast_LabeledStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt { struct xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_LabeledStmt *data; size_t length; };

struct ast_Block {
  int32_t const_base;
  int32_t num_consts;
  int32_t let_base;
  int32_t num_lets;
  int32_t num_early_lets;
  int32_t loop_base;
  int32_t num_loops;
  int32_t for_loop_base;
  int32_t num_for_loops;
  int32_t if_base;
  int32_t num_if_stmts;
  int32_t region_base;
  int32_t num_regions;
  int32_t defer_base;
  int32_t num_defers;
  int32_t labeled_base;
  int32_t num_labeled_stmts;
  int32_t expr_stmt_base;
  int32_t num_expr_stmts;
  int32_t final_expr_ref;
  int32_t stmt_order_base;
  int32_t num_stmt_order;
  int32_t parent_block_ref;
};

struct xlang_slice_ast_Block { struct ast_Block *data; size_t length; };

struct xlang_slice_xlang_slice_ast_Block { struct xlang_slice_ast_Block *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_Block { struct xlang_slice_xlang_slice_ast_Block *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Block { struct xlang_slice_xlang_slice_xlang_slice_ast_Block *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Block { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Block *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Block { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Block *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Block { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Block *data; size_t length; };

struct ast_Param {
  uint8_t name[32];
  int32_t name_len;
  int32_t type_ref;
};

struct xlang_slice_ast_Param { struct ast_Param *data; size_t length; };

struct xlang_slice_xlang_slice_ast_Param { struct xlang_slice_ast_Param *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_Param { struct xlang_slice_xlang_slice_ast_Param *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Param { struct xlang_slice_xlang_slice_xlang_slice_ast_Param *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Param { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Param *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Param { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Param *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Param { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Param *data; size_t length; };

struct ast_Func {
  uint8_t name[128];
  int32_t name_len;
  int32_t param_base;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t return_type_ref;
  int32_t body_ref;
  int32_t body_expr_ref;
  int32_t is_extern;
  int32_t is_async;
  int32_t is_used;
  int32_t is_naked;
  int32_t is_entry;
  int32_t is_no_mangle;
  int32_t is_interrupt;
  int32_t abi_kind;
  int32_t is_variadic;
  int32_t is_export;
};

struct xlang_slice_ast_Func { struct ast_Func *data; size_t length; };

struct xlang_slice_xlang_slice_ast_Func { struct xlang_slice_ast_Func *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_Func { struct xlang_slice_xlang_slice_ast_Func *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Func { struct xlang_slice_xlang_slice_xlang_slice_ast_Func *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Func { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Func *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Func { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Func *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Func { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Func *data; size_t length; };

struct ast_StructLayout {
  uint8_t name[128];
  int32_t name_len;
  int32_t field_base;
  int32_t num_fields;
  int32_t allow_padding;
  int32_t soa;
  int32_t packed;
  int32_t repr_compatible;
  int32_t is_export;
};

struct xlang_slice_ast_StructLayout { struct ast_StructLayout *data; size_t length; };

struct xlang_slice_xlang_slice_ast_StructLayout { struct xlang_slice_ast_StructLayout *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_StructLayout { struct xlang_slice_xlang_slice_ast_StructLayout *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StructLayout { struct xlang_slice_xlang_slice_xlang_slice_ast_StructLayout *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StructLayout { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StructLayout *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StructLayout { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StructLayout *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StructLayout { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_StructLayout *data; size_t length; };

struct ast_Module {
  int32_t num_funcs;
  int32_t main_func_index;
  int32_t num_imports;
  int32_t num_top_level_lets;
  int32_t num_struct_layouts;
  int32_t pending_allow_padding;
  int32_t pending_soa_struct;
  int32_t pending_cfg_skip;
  int32_t pending_repr_c_struct;
  int32_t pending_repr_compatible_struct;
  int32_t pending_used;
  int32_t pending_naked;
  int32_t pending_entry;
  int32_t pending_no_mangle;
  int32_t pending_interrupt;
  int32_t pending_export;
  int32_t num_module_enums;
};

struct xlang_slice_ast_Module { struct ast_Module *data; size_t length; };

struct xlang_slice_xlang_slice_ast_Module { struct xlang_slice_ast_Module *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_Module { struct xlang_slice_xlang_slice_ast_Module *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Module { struct xlang_slice_xlang_slice_xlang_slice_ast_Module *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Module { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Module *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Module { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Module *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Module { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_Module *data; size_t length; };

struct ast_ASTArena {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
};

/* pipeline call aliases (ast_pipeline_* extern, pipeline_* call) */
#define ast_arena_init ast_ast_arena_init
#define ast_arena_type_alloc ast_ast_arena_type_alloc
#define ast_arena_expr_alloc ast_ast_arena_expr_alloc
#define ast_arena_block_alloc ast_ast_arena_block_alloc
#define ast_arena_type_get ast_ast_arena_type_get
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_expr_get ast_ast_arena_expr_get
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_block_get ast_ast_arena_block_get
#define ast_arena_patch_block_parent_links ast_ast_arena_patch_block_parent_links
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_func_alloc ast_ast_arena_func_alloc
#define ast_arena_func_get ast_ast_arena_func_get
#define ast_arena_func_set ast_ast_arena_func_set
#define codegen_codegen_path_is_std_io_driver_bytes codegen_path_is_std_io_driver_bytes
#define codegen_codegen_path_is_std_io_core_bytes codegen_path_is_std_io_core_bytes
#define codegen_codegen_dep_import_path_len_at codegen_dep_import_path_len_at
#define codegen_codegen_ctx_dep_path_for_current_codegen_module_into codegen_ctx_dep_path_for_current_codegen_module_into
#define codegen_codegen_module_import_path_len_at codegen_module_import_path_len_at
#define codegen_codegen_find_dep_index_by_path codegen_find_dep_index_by_path
#define codegen_codegen_find_seeded_global_dep_slot_by_path codegen_find_seeded_global_dep_slot_by_path
#define codegen_codegen_module_num_imports codegen_module_num_imports
#define codegen_codegen_emit_prefix_len_from_ctx codegen_emit_prefix_len_from_ctx
#define codegen_codegen_emit_async_run_seed_push_name codegen_emit_async_run_seed_push_name
#define codegen_codegen_emit_async_sched_call codegen_emit_async_sched_call
#define codegen_codegen_emit_async_sched_call_by_name codegen_emit_async_sched_call_by_name
#define codegen_codegen_emit_async_task_submit_call codegen_emit_async_task_submit_call
#define codegen_codegen_emit_async_task_submit_call_by_symbol codegen_emit_async_task_submit_call_by_symbol
#define codegen_codegen_emit_async_binding_import_call codegen_emit_async_binding_import_call
#define codegen_codegen_emit_async_method_call_run codegen_emit_async_method_call_run
#define codegen_codegen_find_module_func_index_by_name codegen_find_module_func_index_by_name
#define codegen_codegen_resolve_binding_import_dep_index codegen_resolve_binding_import_dep_index
#define codegen_codegen_find_module_func_index_by_name_overload codegen_find_module_func_index_by_name_overload
#define codegen_codegen_resolve_call_target_func_index codegen_resolve_call_target_func_index
#define codegen_codegen_expr_var_matches_func_param_index codegen_expr_var_matches_func_param_index
#define codegen_codegen_symbuf_bytes_eq codegen_symbuf_bytes_eq
#define codegen_codegen_call_num_args_override codegen_call_num_args_override
#define codegen_codegen_name_bytes_prefix_eq codegen_name_bytes_prefix_eq
#define codegen_codegen_is_std_io_driver_bridge_name codegen_is_std_io_driver_bridge_name
#define codegen_codegen_should_skip_emit_std_io_core_io_dup codegen_should_skip_emit_std_io_core_io_dup
#define codegen_codegen_should_skip_emit_std_io_trivial_handle codegen_should_skip_emit_std_io_trivial_handle
#define codegen_codegen_should_skip_later_same_name_body codegen_should_skip_later_same_name_body
#define codegen_codegen_should_skip_emit_func codegen_should_skip_emit_func
#define codegen_codegen_force_param_std_io_driver_prefix_ok codegen_force_param_std_io_driver_prefix_ok
#define codegen_codegen_force_param_size_t codegen_force_param_size_t
#define codegen_codegen_force_param_size_t_std_io_print_str_second codegen_force_param_size_t_std_io_print_str_second
#define codegen_codegen_force_param_ptrdiff_t codegen_force_param_ptrdiff_t
#define codegen_codegen_force_param_uint32_t codegen_force_param_uint32_t
#define codegen_codegen_use_buf_wrapper codegen_use_buf_wrapper
#define codegen_codegen_emit_io_driver_buf_call_name codegen_emit_io_driver_buf_call_name
#define codegen_codegen_try_emit_std_io_driver_buf_body codegen_try_emit_std_io_driver_buf_body
#define codegen_codegen_field_access_base_is_pointer_ref codegen_field_access_base_is_pointer_ref
#define codegen_codegen_field_access_base_type_resolved codegen_field_access_base_type_resolved
#define codegen_codegen_try_emit_fmt_string_lit_call codegen_try_emit_fmt_string_lit_call
#define codegen_codegen_try_emit_size_align_of_call codegen_try_emit_size_align_of_call
#define codegen_codegen_emit_call_arg_slice_abi codegen_emit_call_arg_slice_abi
#define codegen_codegen_field_access_base_is_pointer_param codegen_field_access_base_is_pointer_param
#define codegen_codegen_field_access_base_is_pointer_local codegen_field_access_base_is_pointer_local
#define codegen_codegen_field_access_base_param_type_known codegen_field_access_base_param_type_known
#define codegen_codegen_field_access_base_is_slice_param_name codegen_field_access_base_is_slice_param_name
#define codegen_codegen_block_stmt_order_has_let codegen_block_stmt_order_has_let
#define codegen_codegen_append_byte codegen_append_byte
#define codegen_codegen_append_byte_u8 codegen_append_byte_u8
#define codegen_codegen_emit_bytes_4 codegen_emit_bytes_4
#define codegen_codegen_emit_bytes_5 codegen_emit_bytes_5
#define codegen_codegen_emit_bytes_6 codegen_emit_bytes_6
#define codegen_codegen_emit_bytes_7 codegen_emit_bytes_7
#define codegen_codegen_emit_bytes_8 codegen_emit_bytes_8
#define codegen_codegen_emit_bytes_9 codegen_emit_bytes_9
#define codegen_codegen_emit_bytes_22 codegen_emit_bytes_22
#define codegen_codegen_emit_bytes_32 codegen_emit_bytes_32
#define codegen_codegen_emit_bytes_64 codegen_emit_bytes_64
#define codegen_codegen_emit_bytes_from_ptr codegen_emit_bytes_from_ptr
#define codegen_codegen_emit_bytes_3 codegen_emit_bytes_3
#define codegen_codegen_c_prefix_redundant_with_name codegen_c_prefix_redundant_with_name
#define codegen_codegen_emit_bytes_2 codegen_emit_bytes_2
#define codegen_codegen_format_uint codegen_format_uint
#define codegen_codegen_format_uint64 codegen_format_uint64
#define codegen_codegen_format_int codegen_format_int
#define codegen_codegen_emit_indent codegen_emit_indent
#define codegen_codegen_emit_break_stmt codegen_emit_break_stmt
#define codegen_codegen_emit_continue_stmt codegen_emit_continue_stmt
#define codegen_codegen_emit_type_kind_ord codegen_emit_type_kind_ord
#define codegen_codegen_emit_type_kind codegen_emit_type_kind
#define codegen_codegen_type_kind_append_to_scratch codegen_type_kind_append_to_scratch
#define codegen_codegen_emit_vector_c_type_out codegen_emit_vector_c_type_out
#define codegen_codegen_type_kind_append_to_scratch_ord codegen_type_kind_append_to_scratch_ord
#define codegen_codegen_type_to_c_repr codegen_type_to_c_repr
#define codegen_codegen_emit_type codegen_emit_type
#define codegen_codegen_type_dep_struct_owner_index codegen_type_dep_struct_owner_index
#define codegen_codegen_type_dep_struct_prefix_into codegen_type_dep_struct_prefix_into
#define codegen_codegen_type_array_elem_is_u8 codegen_type_array_elem_is_u8
#define codegen_codegen_emit_c codegen_emit_c
#define codegen_codegen_type_is codegen_type_is
#define codegen_codegen_emit_local_fixed_array_elem_type codegen_emit_local_fixed_array_elem_type
#define codegen_codegen_emit_local_fixed_array_suffix codegen_emit_local_fixed_array_suffix
#define codegen_codegen_emit_local_fixed_array_let_finish codegen_emit_local_fixed_array_let_finish
#define codegen_codegen_try_emit_slice_init_from_array_var codegen_try_emit_slice_init_from_array_var
#define codegen_codegen_emit_braced_array_lit_init codegen_emit_braced_array_lit_init
#define codegen_codegen_emit_struct_field_type_via_pipeline codegen_emit_struct_field_type_via_pipeline
#define codegen_codegen_lookup_struct_field_type_ref codegen_lookup_struct_field_type_ref
#define codegen_codegen_should_skip_emit_struct_layout_for_abi_dup codegen_should_skip_emit_struct_layout_for_abi_dup
#define codegen_codegen_type_is_module_user_struct codegen_type_is_module_user_struct
#define codegen_codegen_type_is_module_user_enum codegen_type_is_module_user_enum
#define codegen_codegen_type_dep_enum_prefix_into codegen_type_dep_enum_prefix_into
#define codegen_codegen_type_ref_is_host_concrete codegen_type_ref_is_host_concrete
#define codegen_codegen_resolve_generic_struct_field_type codegen_resolve_generic_struct_field_type
#define codegen_codegen_module_struct_layout_index_by_name codegen_module_struct_layout_index_by_name
#define codegen_codegen_generic_struct_resolve_arg_via_ctx codegen_generic_struct_resolve_arg_via_ctx
#define codegen_codegen_generic_struct_resolve_arg_via_map codegen_generic_struct_resolve_arg_via_map
#define codegen_codegen_generic_struct_fill_concrete_args codegen_generic_struct_fill_concrete_args
#define codegen_codegen_generic_struct_mangled_name_into codegen_generic_struct_mangled_name_into
#define codegen_codegen_mono_suffix_bytes_from_init codegen_mono_suffix_bytes_from_init
#define codegen_codegen_try_emit_struct_lit_mono_from_fields codegen_try_emit_struct_lit_mono_from_fields
#define codegen_codegen_emit_generic_struct_mono_suffix codegen_emit_generic_struct_mono_suffix
#define codegen_codegen_generic_struct_field_type_from_mono codegen_generic_struct_field_type_from_mono
#define codegen_codegen_type_refs_same_for_mono codegen_type_refs_same_for_mono
#define codegen_codegen_type_ref_type_arg_nest_depth codegen_type_ref_type_arg_nest_depth
#define codegen_codegen_generic_struct_combo_nest_depth codegen_generic_struct_combo_nest_depth
#define codegen_codegen_collect_generic_struct_mono_combos codegen_collect_generic_struct_mono_combos
#define codegen_codegen_maybe_emit_generic_struct_mono_suffix_for_type codegen_maybe_emit_generic_struct_mono_suffix_for_type
#define codegen_codegen_build_func_param_mono_map codegen_build_func_param_mono_map
#define codegen_codegen_emit_struct_field_decl_x codegen_emit_struct_field_decl_x
#define codegen_codegen_emit_companion_named_slice_layout codegen_emit_companion_named_slice_layout
#define codegen_codegen_emit_module_struct_definitions codegen_emit_module_struct_definitions
#define codegen_codegen_emit_module_struct_forward_declarations codegen_emit_module_struct_forward_declarations
#define codegen_codegen_emit_module_struct_forward_declarations_ctx codegen_emit_module_struct_forward_declarations_ctx
#define codegen_codegen_emit_module_enum_definitions codegen_emit_module_enum_definitions
#define codegen_codegen_emit_skipped_dep_type_definitions codegen_emit_skipped_dep_type_definitions
#define codegen_codegen_emit_dep_struct_forward_declarations codegen_emit_dep_struct_forward_declarations
#define codegen_codegen_resolve_binding_import_path_for_field_access codegen_resolve_binding_import_path_for_field_access
#define codegen_codegen_resolve_binding_import_path_for_method_call codegen_resolve_binding_import_path_for_method_call
#define codegen_codegen_emit_import_module_field_symbol codegen_emit_import_module_field_symbol
#define codegen_codegen_emit_import_module_const_field codegen_emit_import_module_const_field
#define codegen_codegen_try_emit_match_field_bind codegen_try_emit_match_field_bind
#define codegen_codegen_emit_match_arm_value codegen_emit_match_arm_value
#define codegen_codegen_block_has_explicit_return codegen_block_has_explicit_return
#define codegen_codegen_match_arm_result_is_return_control codegen_match_arm_result_is_return_control
#define codegen_codegen_match_has_return_arm codegen_match_has_return_arm
#define codegen_codegen_emit_match_stmt_arm_body codegen_emit_match_stmt_arm_body
#define codegen_codegen_emit_match_as_stmt codegen_emit_match_as_stmt
#define codegen_codegen_emit_match_from_arm codegen_emit_match_from_arm
#define codegen_codegen_emit_expr codegen_emit_expr
#define codegen_codegen_callee_var_is_string_new codegen_callee_var_is_string_new
#define codegen_codegen_emit_run_defers codegen_emit_run_defers
#define codegen_codegen_current_func_returns_void codegen_current_func_returns_void
#define codegen_codegen_current_func_is_named_main codegen_current_func_is_named_main
#define codegen_codegen_emit_return_stmt_with_context codegen_emit_return_stmt_with_context
#define codegen_codegen_emit_block_final_expr codegen_emit_block_final_expr
#define codegen_codegen_emit_block codegen_emit_block
#define codegen_codegen_emit_suffix_bytes codegen_emit_suffix_bytes
#define codegen_codegen_type_ref_to_suffix codegen_type_ref_to_suffix
#define codegen_codegen_module_func_overload_count codegen_module_func_overload_count
#define codegen_codegen_func_param_sig_equal codegen_func_param_sig_equal
#define codegen_codegen_module_overload_param_sig_count codegen_module_overload_param_sig_count
#define codegen_codegen_func_c_symbol_prefix_len codegen_func_c_symbol_prefix_len
#define codegen_codegen_emit_func_link_name codegen_emit_func_link_name
#define codegen_codegen_name_is_local_binding codegen_name_is_local_binding
#define codegen_codegen_try_emit_fn_as_value codegen_try_emit_fn_as_value
#define codegen_codegen_emit_call_func_name codegen_emit_call_func_name
#define codegen_codegen_block_contains_return codegen_block_contains_return
#define codegen_codegen_emit_func codegen_emit_func
#define codegen_codegen_is_libc_conflicting_extern_name codegen_is_libc_conflicting_extern_name
#define codegen_codegen_find_mono_type_for_generic_func codegen_find_mono_type_for_generic_func
#define codegen_codegen_call_mono_type_at codegen_call_mono_type_at
#define codegen_codegen_mono_combo_slot_equal codegen_mono_combo_slot_equal
#define codegen_codegen_func_ret_type_param_extra codegen_func_ret_type_param_extra
#define codegen_codegen_call_ret_type_param_concrete_at codegen_call_ret_type_param_concrete_at
#define codegen_codegen_collect_mono_combos_for_generic_func codegen_collect_mono_combos_for_generic_func
#define codegen_codegen_try_emit_impl_method_mono_call_name codegen_try_emit_impl_method_mono_call_name
#define codegen_codegen_emit_mono_mangled_name codegen_emit_mono_mangled_name
#define codegen_codegen_mono_subst_type codegen_mono_subst_type
#define codegen_codegen_find_impl_method_for_type codegen_find_impl_method_for_type
#define codegen_codegen_try_emit_generic_identity_mono codegen_try_emit_generic_identity_mono
#define codegen_codegen_try_emit_generic_impl_method_mono codegen_try_emit_generic_impl_method_mono
#define codegen_codegen_try_emit_generic_impl_method_extern_mono codegen_try_emit_generic_impl_method_extern_mono
#define codegen_codegen_emit_func_extern_declaration codegen_emit_func_extern_declaration
#define codegen_codegen_emit_import_dep_function_declarations codegen_emit_import_dep_function_declarations
#define codegen_codegen_x_ast_emit_header codegen_x_ast_emit_header
#define codegen_codegen_x_ast codegen_x_ast
#define codegen_codegen_should_skip_emit_func_by_name codegen_should_skip_emit_func_by_name
#define codegen_codegen_is_submit_batch_buf_call codegen_is_submit_batch_buf_call
#define codegen_codegen_force_param_i32 codegen_force_param_i32
#define codegen_codegen_should_skip_emit_func_core_read_ptr codegen_should_skip_emit_func_core_read_ptr
#define codegen_codegen_std_io_fixed_fd_emit_impl codegen_std_io_fixed_fd_emit_impl
#define codegen_codegen_get_host_call_arg_param_ty codegen_get_host_call_arg_param_ty
#define codegen_codegen_next_host_call_array_tmp_id codegen_next_host_call_array_tmp_id
#define codegen_codegen_emit_slice_let_reent_finish codegen_emit_slice_let_reent_finish
#define ast_expr_apply_call_resolve ast_ast_expr_apply_call_resolve
#define ast_block_final_expr_ref ast_ast_block_final_expr_ref
#define ast_expr_disallows_implicit_tail ast_ast_expr_disallows_implicit_tail
#define ast_block_num_consts ast_ast_block_num_consts
#define ast_block_num_lets ast_ast_block_num_lets
#define ast_block_num_loops ast_ast_block_num_loops
#define ast_block_num_for_loops ast_ast_block_num_for_loops
#define ast_block_num_if_stmts ast_ast_block_num_if_stmts
#define ast_block_num_regions ast_ast_block_num_regions
#define ast_block_num_labeled_stmts ast_ast_block_num_labeled_stmts
#define ast_block_region_body_ref ast_ast_block_region_body_ref
#define ast_block_num_expr_stmts ast_ast_block_num_expr_stmts
#define ast_block_num_stmt_order ast_ast_block_num_stmt_order
#define ast_block_stmt_order_kind ast_ast_block_stmt_order_kind
#define ast_block_stmt_order_idx ast_ast_block_stmt_order_idx
#define ast_block_const_init_ref ast_ast_block_const_init_ref
#define ast_block_const_type_ref ast_ast_block_const_type_ref
#define ast_block_let_init_ref ast_ast_block_let_init_ref
#define ast_block_let_type_ref ast_ast_block_let_type_ref
#define ast_block_expr_stmt_ref ast_ast_block_expr_stmt_ref
#define ast_block_while_cond_ref ast_ast_block_while_cond_ref
#define ast_block_while_body_ref ast_ast_block_while_body_ref
#define ast_block_for_init_ref ast_ast_block_for_init_ref
#define ast_block_for_cond_ref ast_ast_block_for_cond_ref
#define ast_block_for_step_ref ast_ast_block_for_step_ref
#define ast_block_for_body_ref ast_ast_block_for_body_ref
#define ast_block_if_cond_ref ast_ast_block_if_cond_ref
#define ast_block_if_then_body_ref ast_ast_block_if_then_body_ref
#define ast_block_if_else_body_ref ast_ast_block_if_else_body_ref
#define ast_block_resolve_var_to_type_ref ast_ast_block_resolve_var_to_type_ref
#define ast_expr_layout_prime_call_resolved ast_ast_expr_layout_prime_call_resolved
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_func_set ast_ast_arena_func_set

/* pipeline reverse aliases (call ast_pipeline_* → pipeline_* extern) */
#define ast_pipeline_arena_expr_get_copy pipeline_arena_expr_get_copy
#define ast_pipeline_arena_block_get_copy pipeline_arena_block_get_copy
#define ast_pipeline_arena_type_get_copy pipeline_arena_type_get_copy
#define ast_pipeline_arena_func_get_copy pipeline_arena_func_get_copy
#define ast_pipeline_arena_type_alloc pipeline_arena_type_alloc
#define ast_pipeline_arena_expr_alloc pipeline_arena_expr_alloc
#define ast_pipeline_arena_block_alloc pipeline_arena_block_alloc
#define ast_pipeline_arena_func_alloc pipeline_arena_func_alloc
#define ast_pipeline_arena_type_set_copy pipeline_arena_type_set_copy
#define ast_pipeline_arena_expr_set_copy pipeline_arena_expr_set_copy
#define ast_pipeline_arena_block_set_copy pipeline_arena_block_set_copy
#define ast_pipeline_arena_func_set_copy pipeline_arena_func_set_copy
#define ast_pipeline_arena_type_cap pipeline_arena_type_cap
#define ast_pipeline_arena_expr_cap pipeline_arena_expr_cap
#define ast_pipeline_arena_block_cap pipeline_arena_block_cap
#define ast_pipeline_arena_func_cap pipeline_arena_func_cap
#define ast_pipeline_module_import_alloc pipeline_module_import_alloc
#define ast_pipeline_module_import_set_path pipeline_module_import_set_path
#define ast_pipeline_module_import_path_len pipeline_module_import_path_len
#define ast_pipeline_module_import_path_copy pipeline_module_import_path_copy
#define ast_pipeline_module_import_path_byte_at pipeline_module_import_path_byte_at
#define ast_pipeline_module_import_set_kind pipeline_module_import_set_kind
#define ast_pipeline_module_import_kind_at pipeline_module_import_kind_at
#define ast_pipeline_module_import_set_binding_name pipeline_module_import_set_binding_name
#define ast_pipeline_module_import_binding_name_len pipeline_module_import_binding_name_len
#define ast_pipeline_module_import_binding_name_byte_at pipeline_module_import_binding_name_byte_at
#define ast_pipeline_module_import_set_select_count pipeline_module_import_set_select_count
#define ast_pipeline_module_import_append_select_name pipeline_module_import_append_select_name
#define ast_pipeline_module_import_select_count_at pipeline_module_import_select_count_at
#define ast_pipeline_module_import_set_select_name pipeline_module_import_set_select_name
#define ast_pipeline_module_import_select_name_len pipeline_module_import_select_name_len
#define ast_pipeline_module_import_select_name_byte_at pipeline_module_import_select_name_byte_at
#define ast_pipeline_module_struct_layout_alloc pipeline_module_struct_layout_alloc
#define ast_pipeline_module_struct_layout_reset_slot pipeline_module_struct_layout_reset_slot
#define ast_pipeline_module_struct_layout_set_name pipeline_module_struct_layout_set_name
#define ast_pipeline_module_struct_layout_set_field pipeline_module_struct_layout_set_field
#define ast_pipeline_module_struct_layout_name_len pipeline_module_struct_layout_name_len
#define ast_pipeline_module_struct_layout_name_into pipeline_module_struct_layout_name_into
#define ast_pipeline_module_struct_layout_field_name_into pipeline_module_struct_layout_field_name_into
#define ast_pipeline_module_struct_layout_num_fields pipeline_module_struct_layout_num_fields
#define ast_pipeline_module_struct_layout_set_num_fields pipeline_module_struct_layout_set_num_fields
#define ast_pipeline_module_struct_layout_field_type_ref pipeline_module_struct_layout_field_type_ref
#define ast_pipeline_module_struct_layout_field_name_len pipeline_module_struct_layout_field_name_len
#define ast_pipeline_module_top_level_let_alloc pipeline_module_top_level_let_alloc
#define ast_pipeline_module_top_level_let_set pipeline_module_top_level_let_set
#define ast_pipeline_module_top_level_let_name_len pipeline_module_top_level_let_name_len
#define ast_pipeline_module_top_level_let_name_byte_at pipeline_module_top_level_let_name_byte_at
#define ast_pipeline_module_top_level_let_type_ref pipeline_module_top_level_let_type_ref
#define ast_pipeline_module_top_level_let_init_ref pipeline_module_top_level_let_init_ref
#define ast_pipeline_module_top_level_let_is_const pipeline_module_top_level_let_is_const
#define ast_pipeline_module_enum_alloc pipeline_module_enum_alloc
#define ast_pipeline_module_enum_set_name pipeline_module_enum_set_name
#define ast_pipeline_module_enum_name_len pipeline_module_enum_name_len
#define ast_pipeline_module_enum_name_byte_at pipeline_module_enum_name_byte_at
#define ast_pipeline_module_struct_layout_name_byte_at pipeline_module_struct_layout_name_byte_at
#define ast_pipeline_module_struct_layout_set_allow_padding pipeline_module_struct_layout_set_allow_padding
#define ast_pipeline_module_struct_layout_allow_padding_at pipeline_module_struct_layout_allow_padding_at
#define ast_pipeline_module_struct_layout_set_soa pipeline_module_struct_layout_set_soa
#define ast_pipeline_module_struct_layout_set_packed pipeline_module_struct_layout_set_packed
#define ast_pipeline_module_struct_layout_packed_at pipeline_module_struct_layout_packed_at
#define ast_pipeline_module_struct_layout_soa_at pipeline_module_struct_layout_soa_at
#define ast_pipeline_module_struct_layout_field_offset_at pipeline_module_struct_layout_field_offset_at
#define ast_pipeline_module_struct_layout_set_field_offset pipeline_module_struct_layout_set_field_offset
#define ast_pipeline_onefunc_append_const_name pipeline_onefunc_append_const_name
#define ast_pipeline_onefunc_const_name_len pipeline_onefunc_const_name_len
#define ast_pipeline_onefunc_const_name_byte_at pipeline_onefunc_const_name_byte_at
#define ast_pipeline_onefunc_const_init_val pipeline_onefunc_const_init_val
#define ast_pipeline_onefunc_num_consts pipeline_onefunc_num_consts
#define ast_pipeline_onefunc_append_let pipeline_onefunc_append_let
#define ast_pipeline_onefunc_let_name_len pipeline_onefunc_let_name_len
#define ast_pipeline_onefunc_let_name_byte_at pipeline_onefunc_let_name_byte_at
#define ast_pipeline_onefunc_let_init_val pipeline_onefunc_let_init_val
#define ast_pipeline_onefunc_let_init_ref pipeline_onefunc_let_init_ref
#define ast_pipeline_onefunc_let_type_ref pipeline_onefunc_let_type_ref
#define ast_pipeline_onefunc_num_lets pipeline_onefunc_num_lets
#define ast_pipeline_onefunc_const_name_copy64 pipeline_onefunc_const_name_copy64
#define ast_pipeline_onefunc_let_name_copy64 pipeline_onefunc_let_name_copy64
#define ast_pipeline_onefunc_copy_sidecar pipeline_onefunc_copy_sidecar
#define ast_pipeline_block_append_const pipeline_block_append_const
#define ast_pipeline_block_append_let pipeline_block_append_let
#define ast_pipeline_block_append_if pipeline_block_append_if
#define ast_pipeline_block_append_region pipeline_block_append_region
#define ast_pipeline_block_append_unsafe pipeline_block_append_unsafe
#define ast_pipeline_block_region_body_ref pipeline_block_region_body_ref
#define ast_pipeline_block_append_expr_stmt pipeline_block_append_expr_stmt
#define ast_pipeline_block_append_stmt_order pipeline_block_append_stmt_order
#define ast_pipeline_block_const_init_ref pipeline_block_const_init_ref
#define ast_pipeline_block_const_type_ref pipeline_block_const_type_ref
#define ast_pipeline_block_const_name_len pipeline_block_const_name_len
#define ast_pipeline_block_const_name_copy64 pipeline_block_const_name_copy64
#define ast_pipeline_block_let_init_ref pipeline_block_let_init_ref
#define ast_pipeline_block_let_type_ref pipeline_block_let_type_ref
#define ast_pipeline_block_let_name_len pipeline_block_let_name_len
#define ast_pipeline_block_let_name_copy64 pipeline_block_let_name_copy64
#define ast_pipeline_block_expr_stmt_ref pipeline_block_expr_stmt_ref
#define ast_pipeline_block_stmt_order_kind pipeline_block_stmt_order_kind
#define ast_pipeline_block_stmt_order_idx pipeline_block_stmt_order_idx
#define ast_pipeline_block_if_cond_ref pipeline_block_if_cond_ref
#define ast_pipeline_block_if_then_body_ref pipeline_block_if_then_body_ref
#define ast_pipeline_block_if_else_body_ref pipeline_block_if_else_body_ref
#define ast_pipeline_block_resolve_var_type_ref pipeline_block_resolve_var_type_ref
#define ast_pipeline_block_fill_ifs_from_onefunc pipeline_block_fill_ifs_from_onefunc
#define ast_pipeline_block_fill_stmt_order_from_onefunc pipeline_block_fill_stmt_order_from_onefunc
#define ast_pipeline_block_fill_expr_stmts_from_onefunc pipeline_block_fill_expr_stmts_from_onefunc
#define ast_pipeline_block_append_while pipeline_block_append_while
#define ast_pipeline_block_append_for pipeline_block_append_for
#define ast_pipeline_block_while_cond_ref pipeline_block_while_cond_ref
#define ast_pipeline_block_while_body_ref pipeline_block_while_body_ref
#define ast_pipeline_block_for_init_ref pipeline_block_for_init_ref
#define ast_pipeline_block_for_cond_ref pipeline_block_for_cond_ref
#define ast_pipeline_block_for_step_ref pipeline_block_for_step_ref
#define ast_pipeline_block_for_body_ref pipeline_block_for_body_ref
#define ast_pipeline_block_fill_whiles_from_onefunc pipeline_block_fill_whiles_from_onefunc
#define ast_pipeline_block_fill_fors_from_onefunc pipeline_block_fill_fors_from_onefunc
#define ast_pipeline_block_append_labeled pipeline_block_append_labeled
#define ast_pipeline_block_labeled_return_expr_ref pipeline_block_labeled_return_expr_ref
#define ast_pipeline_onefunc_append_while pipeline_onefunc_append_while
#define ast_pipeline_onefunc_while_cond_ref pipeline_onefunc_while_cond_ref
#define ast_pipeline_onefunc_while_body_ref pipeline_onefunc_while_body_ref
#define ast_pipeline_onefunc_num_whiles pipeline_onefunc_num_whiles
#define ast_pipeline_onefunc_append_for pipeline_onefunc_append_for
#define ast_pipeline_onefunc_for_init_ref pipeline_onefunc_for_init_ref
#define ast_pipeline_onefunc_for_cond_ref pipeline_onefunc_for_cond_ref
#define ast_pipeline_onefunc_for_step_ref pipeline_onefunc_for_step_ref
#define ast_pipeline_onefunc_for_body_ref pipeline_onefunc_for_body_ref
#define ast_pipeline_onefunc_num_fors pipeline_onefunc_num_fors
#define ast_pipeline_dep_ctx_set_module pipeline_dep_ctx_set_module
#define ast_pipeline_dep_ctx_set_arena pipeline_dep_ctx_set_arena
#define ast_pipeline_dep_ctx_module_at pipeline_dep_ctx_module_at
#define ast_pipeline_dep_ctx_arena_at pipeline_dep_ctx_arena_at
#define ast_pipeline_dep_ctx_set_import_path pipeline_dep_ctx_set_import_path
#define ast_pipeline_dep_ctx_import_path_len pipeline_dep_ctx_import_path_len
#define ast_pipeline_dep_ctx_import_path_byte_at pipeline_dep_ctx_import_path_byte_at
#define ast_pipeline_dep_ctx_import_path_copy64 pipeline_dep_ctx_import_path_copy64
#define ast_pipeline_dep_ctx_ndep pipeline_dep_ctx_ndep
#define ast_pipeline_dep_ctx_set_ndep pipeline_dep_ctx_set_ndep
#define ast_pipeline_ctx_append_lib_root pipeline_ctx_append_lib_root
#define ast_pipeline_ctx_lib_root_count pipeline_ctx_lib_root_count
#define ast_pipeline_ctx_lib_root_len pipeline_ctx_lib_root_len
#define ast_pipeline_ctx_lib_root_copy pipeline_ctx_lib_root_copy
#define ast_pipeline_module_func_alloc_slot pipeline_module_func_alloc_slot
#define ast_pipeline_module_func_ref_at pipeline_module_func_ref_at
#define ast_pipeline_module_func_ref_set pipeline_module_func_ref_set
#define ast_pipeline_module_func_set_return_type pipeline_module_func_set_return_type
#define ast_pipeline_module_func_set_body_ref pipeline_module_func_set_body_ref
#define ast_pipeline_module_func_set_body_expr_ref pipeline_module_func_set_body_expr_ref
#define ast_pipeline_module_func_set_is_extern pipeline_module_func_set_is_extern
#define ast_pipeline_module_func_set_is_variadic pipeline_module_func_set_is_variadic
#define ast_pipeline_module_func_is_variadic_at pipeline_module_func_is_variadic_at
#define ast_pipeline_module_func_set_num_params pipeline_module_func_set_num_params
#define ast_pipeline_module_func_set_num_generic_params pipeline_module_func_set_num_generic_params
#define ast_pipeline_module_func_return_type_at pipeline_module_func_return_type_at
#define ast_pipeline_module_func_num_generic_params_at pipeline_module_func_num_generic_params_at
#define ast_pipeline_module_func_name_equal_at pipeline_module_func_name_equal_at
#define ast_pipeline_module_func_name_byte_at pipeline_module_func_name_byte_at
#define ast_pipeline_module_func_body_expr_ref_at pipeline_module_func_body_expr_ref_at
#define ast_pipeline_expr_append_call_arg pipeline_expr_append_call_arg
#define ast_pipeline_expr_call_arg_ref pipeline_expr_call_arg_ref
#define ast_pipeline_expr_call_num_args_at pipeline_expr_call_num_args_at
#define ast_pipeline_expr_call_num_type_args_at pipeline_expr_call_num_type_args_at
#define ast_pipeline_expr_append_method_call_arg pipeline_expr_append_method_call_arg
#define ast_pipeline_expr_method_call_arg_ref pipeline_expr_method_call_arg_ref
#define ast_pipeline_expr_append_match_arm pipeline_expr_append_match_arm
#define ast_pipeline_expr_match_num_arms_at pipeline_expr_match_num_arms_at
#define ast_pipeline_expr_match_arm_result_ref pipeline_expr_match_arm_result_ref
#define ast_pipeline_expr_match_arm_is_wildcard pipeline_expr_match_arm_is_wildcard
#define ast_pipeline_expr_match_arm_lit_val pipeline_expr_match_arm_lit_val
#define ast_pipeline_expr_match_arm_is_enum_variant pipeline_expr_match_arm_is_enum_variant
#define ast_pipeline_expr_match_arm_variant_index pipeline_expr_match_arm_variant_index
#define ast_pipeline_expr_match_arm_set_wildcard pipeline_expr_match_arm_set_wildcard
#define ast_pipeline_expr_match_arm_set_lit_val pipeline_expr_match_arm_set_lit_val
#define ast_pipeline_expr_match_arm_set_enum_variant pipeline_expr_match_arm_set_enum_variant
#define ast_pipeline_expr_append_struct_lit_field pipeline_expr_append_struct_lit_field
#define ast_pipeline_expr_append_array_lit_elem pipeline_expr_append_array_lit_elem
#define ast_pipeline_expr_array_lit_elem_ref pipeline_expr_array_lit_elem_ref
#define ast_pipeline_expr_array_lit_num_elems_at pipeline_expr_array_lit_num_elems_at
#define ast_pipeline_expr_init_call_resolve_at_ref pipeline_expr_init_call_resolve_at_ref
#define ast_pipeline_expr_apply_call_resolve pipeline_expr_apply_call_resolve
#define ast_pipeline_type_named_name_into pipeline_type_named_name_into
#define ast_pipeline_type_kind_ord_at pipeline_type_kind_ord_at
#define ast_pipeline_type_elem_ref_at pipeline_type_elem_ref_at
#define ast_pipeline_type_array_size_at pipeline_type_array_size_at
#define ast_pipeline_type_type_arg_ref_at pipeline_type_type_arg_ref_at
#define ast_pipeline_module_struct_layout_num_type_params_at pipeline_module_struct_layout_num_type_params_at
#define ast_pipeline_module_struct_layout_type_param_name_len pipeline_module_struct_layout_type_param_name_len
#define ast_pipeline_module_struct_layout_type_param_name_into pipeline_module_struct_layout_type_param_name_into
#define ast_pipeline_typeck_resolve_type_alias_ref_c pipeline_typeck_resolve_type_alias_ref_c
#define ast_pipeline_codegen_type_to_c_repr pipeline_codegen_type_to_c_repr
#define ast_pipeline_codegen_c_file_prologue_done_get pipeline_codegen_c_file_prologue_done_get
#define ast_pipeline_codegen_c_file_prologue_done_set pipeline_codegen_c_file_prologue_done_set
#define ast_pipeline_codegen_c_file_prologue_done_reset pipeline_codegen_c_file_prologue_done_reset
#define ast_pipeline_codegen_struct_tag_try_claim pipeline_codegen_struct_tag_try_claim
#define ast_pipeline_codegen_emit_struct_field_type pipeline_codegen_emit_struct_field_type
#define ast_pipeline_codegen_emit_struct_field_decl pipeline_codegen_emit_struct_field_decl
#define ast_pipeline_codegen_emit_seed_mega_enabled pipeline_codegen_emit_seed_mega_enabled
#define ast_pipeline_codegen_emit_float_lit_c pipeline_codegen_emit_float_lit_c
#define ast_pipeline_module_struct_layout_is_export_at pipeline_module_struct_layout_is_export_at
#define ast_pipeline_expr_kind_ord_at pipeline_expr_kind_ord_at
#define ast_pipeline_expr_is_c_static_const_init pipeline_expr_is_c_static_const_init
#define ast_pipeline_expr_resolved_type_ref pipeline_expr_resolved_type_ref
#define ast_pipeline_expr_as_target_type_ref_at pipeline_expr_as_target_type_ref_at
#define ast_pipeline_typeck_type_refs_equal_c pipeline_typeck_type_refs_equal_c
#define ast_pipeline_expr_call_type_arg_ref_at pipeline_expr_call_type_arg_ref_at
#define ast_pipeline_expr_call_resolved_dep_index_at pipeline_expr_call_resolved_dep_index_at
#define ast_pipeline_expr_call_resolved_func_index_at pipeline_expr_call_resolved_func_index_at
#define ast_pipeline_expr_match_arm_guard_ref pipeline_expr_match_arm_guard_ref
#define ast_pipeline_codegen_match_set_subject_c pipeline_codegen_match_set_subject_c
#define ast_pipeline_codegen_match_clear_subject_c pipeline_codegen_match_clear_subject_c
#define ast_pipeline_codegen_match_matched_ref_c pipeline_codegen_match_matched_ref_c
#define ast_pipeline_codegen_match_subject_ty_c pipeline_codegen_match_subject_ty_c
#define ast_pipeline_codegen_match_mod_c pipeline_codegen_match_mod_c
#define ast_pipeline_codegen_match_name_is_subject_field_c pipeline_codegen_match_name_is_subject_field_c
#define ast_pipeline_expr_struct_lit_field_name_len pipeline_expr_struct_lit_field_name_len
#define ast_pipeline_expr_struct_lit_field_name_into pipeline_expr_struct_lit_field_name_into
#define ast_pipeline_expr_struct_lit_init_ref pipeline_expr_struct_lit_init_ref
#define ast_pipeline_expr_struct_lit_num_fields pipeline_expr_struct_lit_num_fields
#define ast_pipeline_module_enum_num_variants pipeline_module_enum_num_variants
#define ast_pipeline_module_enum_variant_name_len pipeline_module_enum_variant_name_len
#define ast_pipeline_module_enum_variant_name_byte_at pipeline_module_enum_variant_name_byte_at
#define ast_pipeline_codegen_try_mark_enum_field_access pipeline_codegen_try_mark_enum_field_access
#define ast_pipeline_expr_int_val_at pipeline_expr_int_val_at
#define ast_pipeline_codegen_dep_skip_x_bootstrap_partial pipeline_codegen_dep_skip_x_bootstrap_partial
#define ast_pipeline_module_func_name_copy64 pipeline_module_func_name_copy64
#define ast_pipeline_module_func_param_name_copy32 pipeline_module_func_param_name_copy32
#define ast_pipeline_module_func_num_params_at pipeline_module_func_num_params_at
#define ast_pipeline_module_func_param_name_len_at pipeline_module_func_param_name_len_at
#define ast_pipeline_module_func_param_type_ref_at pipeline_module_func_param_type_ref_at
#define ast_pipeline_module_func_name_len_at pipeline_module_func_name_len_at
#define ast_pipeline_module_func_body_ref_at pipeline_module_func_body_ref_at
#define ast_pipeline_find_fixed_array_slice_escape pipeline_find_fixed_array_slice_escape
#define ast_pipeline_dep_ctx_empty_param_reset pipeline_dep_ctx_empty_param_reset
#define ast_pipeline_dep_ctx_empty_param_append pipeline_dep_ctx_empty_param_append
#define ast_pipeline_dep_ctx_empty_param_at pipeline_dep_ctx_empty_param_at
#define ast_pipeline_dep_ctx_empty_param_backup pipeline_dep_ctx_empty_param_backup
#define ast_pipeline_dep_ctx_empty_param_restore pipeline_dep_ctx_empty_param_restore
#define ast_pipeline_module_func_is_extern_at pipeline_module_func_is_extern_at
#define ast_pipeline_module_func_is_used_at pipeline_module_func_is_used_at
#define ast_pipeline_module_func_is_naked_at pipeline_module_func_is_naked_at
#define ast_pipeline_module_func_is_entry_at pipeline_module_func_is_entry_at
#define ast_pipeline_module_func_is_no_mangle_at pipeline_module_func_is_no_mangle_at
#define ast_pipeline_module_func_is_interrupt_at pipeline_module_func_is_interrupt_at
#define ast_pipeline_block_defer_body_ref pipeline_block_defer_body_ref
#define ast_pipeline_asm_resolve_whole_import_qualified_symbol_c pipeline_asm_resolve_whole_import_qualified_symbol_c
#define ast_pipeline_block_num_labeled_stmts pipeline_block_num_labeled_stmts
#define ast_pipeline_block_labeled_is_goto pipeline_block_labeled_is_goto
#define ast_pipeline_block_labeled_label_len pipeline_block_labeled_label_len
#define ast_pipeline_block_labeled_label_copy32 pipeline_block_labeled_label_copy32
#define ast_pipeline_block_labeled_goto_target_len pipeline_block_labeled_goto_target_len
#define ast_pipeline_block_labeled_goto_target_copy32 pipeline_block_labeled_goto_target_copy32
#define ast_pipeline_expr_var_name_into pipeline_expr_var_name_into
#define ast_pipeline_expr_var_name_len pipeline_expr_var_name_len
#define ast_pipeline_module_func_param_type_ref_for_name pipeline_module_func_param_type_ref_for_name
#define ast_pipeline_codegen_std_dep_link_only pipeline_codegen_std_dep_link_only
#define ast_pipeline_prepare_dep_codegen_path_c pipeline_prepare_dep_codegen_path_c

/* slim arena grow pool glue (linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);


struct xlang_slice_ast_ASTArena { struct ast_ASTArena *data; size_t length; };

struct xlang_slice_xlang_slice_ast_ASTArena { struct xlang_slice_ast_ASTArena *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_ASTArena { struct xlang_slice_xlang_slice_ast_ASTArena *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ASTArena { struct xlang_slice_xlang_slice_xlang_slice_ast_ASTArena *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ASTArena { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ASTArena *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ASTArena { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ASTArena *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ASTArena { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_ASTArena *data; size_t length; };

struct ast_PipelineDepCtx {
  int32_t ndep;
  uint8_t entry_dir_buf[512];
  int32_t entry_dir_len;
  int32_t num_lib_roots;
  uint8_t path_buf[512];
  uint8_t loaded_buf[4194304];
  ssize_t loaded_len;
  uint8_t preprocess_buf[4194304];
  int32_t preprocess_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  int32_t target_cpu_features;
  int32_t use_macho_o;
  int32_t use_coff_o;
  int32_t current_block_ref;
  int32_t typeck_loop_depth;
  int32_t current_func_index;
  int32_t skip_codegen_dep_0;
  int32_t entry_already_parsed;
  int32_t current_func_single_empty_param_index;
  int32_t current_func_empty_param_count;
  int32_t current_emit_empty_var_next_index;
  int32_t emit_expr_as_callee;
  struct ast_Module * current_codegen_module;
  struct ast_ASTArena * current_codegen_arena;
  int32_t current_codegen_dep_index;
  uint8_t current_codegen_prefix_mirror[128];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[128];
  int32_t entry_module_import_path_len;
  int32_t typeck_scope_region_len;
  uint8_t typeck_scope_region_label[128];
  int32_t mono_active;
  int32_t mono_num_types;
  int32_t mono_generic_type_refs[8];
  int32_t mono_concrete_type_refs[8];
};

struct xlang_slice_ast_PipelineDepCtx { struct ast_PipelineDepCtx *data; size_t length; };

struct xlang_slice_xlang_slice_ast_PipelineDepCtx { struct xlang_slice_ast_PipelineDepCtx *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx { struct xlang_slice_xlang_slice_ast_PipelineDepCtx *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx { struct xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ast_PipelineDepCtx *data; size_t length; };

struct ast_Type;
struct ast_Expr;
struct ast_ConstDecl;
struct ast_LetDecl;
struct ast_WhileLoop;
struct ast_ForLoop;
struct ast_IfStmt;
struct ast_StmtOrderItem;
struct ast_LabeledStmt;
struct ast_Block;
struct ast_Param;
struct ast_Func;
struct ast_StructLayout;
struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct ast_Type;
struct ast_Expr;
struct ast_ConstDecl;
struct ast_LetDecl;
struct ast_WhileLoop;
struct ast_ForLoop;
struct ast_IfStmt;
struct ast_StmtOrderItem;
struct ast_LabeledStmt;
struct ast_Block;
struct ast_Param;
struct ast_Func;
struct ast_StructLayout;
struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
extern void ast_ast_pool_block_on_alloc(struct ast_ASTArena * arena, int32_t block_ref);
extern int32_t pipeline_arena_type_alloc(struct ast_ASTArena * arena);
extern int32_t pipeline_arena_expr_alloc(struct ast_ASTArena * arena);
extern int32_t pipeline_arena_block_alloc(struct ast_ASTArena * arena);
extern int32_t pipeline_arena_func_alloc(struct ast_ASTArena * arena);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_type_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_expr_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_block_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena * arena, int32_t ref);
extern void pipeline_arena_func_set_copy(struct ast_ASTArena * arena, int32_t ref, struct ast_Func f);
extern int32_t pipeline_arena_type_cap(void);
extern int32_t pipeline_arena_expr_cap(void);
extern int32_t pipeline_arena_block_cap(void);
extern int32_t pipeline_arena_func_cap(void);
extern int32_t pipeline_module_import_alloc(struct ast_Module * module);
extern void pipeline_module_import_set_path(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_path_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_path_copy(struct ast_Module * module, int32_t idx, uint8_t * dst, int32_t dst_cap);
extern uint8_t pipeline_module_import_path_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void pipeline_module_import_set_kind(struct ast_Module * module, int32_t idx, int32_t kind);
extern int32_t pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_set_binding_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void pipeline_module_import_set_select_count(struct ast_Module * module, int32_t idx, int32_t n);
extern int32_t pipeline_module_import_append_select_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_set_select_name(struct ast_Module * module, int32_t idx, int32_t sel, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern int32_t pipeline_module_struct_layout_alloc(struct ast_Module * module);
extern void pipeline_module_struct_layout_reset_slot(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern void pipeline_module_struct_layout_set_field(struct ast_Module * module, int32_t li, int32_t j, uint8_t * fname_bytes, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out64);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t li, int32_t j, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_num_fields(struct ast_Module * module, int32_t idx, int32_t nf);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t pipeline_module_top_level_let_alloc(struct ast_Module * module);
extern void pipeline_module_top_level_let_set(struct ast_Module * module, int32_t idx, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref, int32_t is_const);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_init_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_enum_alloc(struct ast_Module * module);
extern void pipeline_module_enum_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_enum_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void pipeline_module_struct_layout_set_allow_padding(struct ast_Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_soa(struct ast_Module * module, int32_t idx, int32_t v);
extern void pipeline_module_struct_layout_set_packed(struct ast_Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_packed_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_soa_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module * module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_field_offset(struct ast_Module * module, int32_t li, int32_t j, int32_t foff);
extern int32_t pipeline_onefunc_append_const_name(uint8_t * out, uint8_t * name, int32_t name_len, int32_t init_val);
extern int32_t pipeline_onefunc_const_name_len(uint8_t * out, int32_t i);
extern uint8_t pipeline_onefunc_const_name_byte_at(uint8_t * out, int32_t i, int32_t off);
extern int32_t pipeline_onefunc_const_init_val(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_consts(uint8_t * out);
extern int32_t pipeline_onefunc_append_let(uint8_t * out, uint8_t * name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_let_name_len(uint8_t * out, int32_t i);
extern uint8_t pipeline_onefunc_let_name_byte_at(uint8_t * out, int32_t i, int32_t off);
extern int32_t pipeline_onefunc_let_init_val(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_let_init_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_let_type_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_lets(uint8_t * out);
extern void pipeline_onefunc_const_name_copy64(uint8_t * out, int32_t i, uint8_t * dst);
extern void pipeline_onefunc_let_name_copy64(uint8_t * out, int32_t i, uint8_t * dst);
extern void pipeline_onefunc_copy_sidecar(uint8_t * dst, uint8_t * src);
extern void ast_ast_pool_onefunc_reset(uint8_t * out);
extern int32_t pipeline_block_append_const(struct ast_ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_let(struct ast_ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_if(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_block_append_region(struct ast_ASTArena * arena, int32_t br, uint8_t * label, int32_t label_len, int32_t body_ref);
extern int32_t pipeline_block_append_unsafe(struct ast_ASTArena * arena, int32_t br, int32_t body_ref);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ri);
extern int32_t pipeline_block_append_expr_stmt(struct ast_ASTArena * arena, int32_t br, int32_t expr_ref);
extern int32_t pipeline_block_append_stmt_order(struct ast_ASTArena * arena, int32_t br, uint8_t kind, int32_t idx);
extern int32_t pipeline_block_const_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_name_len(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern void pipeline_block_const_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t ci, uint8_t * dst);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena * arena, int32_t br, int32_t ei);
extern uint8_t pipeline_block_stmt_order_kind(struct ast_ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_if_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena * arena, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern void pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern int32_t pipeline_block_append_while(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t pipeline_block_append_for(struct ast_ASTArena * arena, int32_t br, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t pipeline_block_while_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t wi);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_step_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t fi);
extern void pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern int32_t pipeline_block_append_labeled(struct ast_ASTArena * arena, int32_t br, int32_t label_len, int32_t is_goto, int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_onefunc_append_while(uint8_t * out, int32_t cond_ref, int32_t body_ref);
extern int32_t pipeline_onefunc_while_cond_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_while_body_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_whiles(uint8_t * out);
extern int32_t pipeline_onefunc_append_for(uint8_t * out, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t pipeline_onefunc_for_init_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_for_cond_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_for_step_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_for_body_ref(uint8_t * out, int32_t i);
extern int32_t pipeline_onefunc_num_fors(uint8_t * out);
extern void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_Module * m);
extern void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_ASTArena * a);
extern struct ast_Module * pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_ASTArena * pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern uint8_t pipeline_dep_ctx_import_path_byte_at(struct ast_PipelineDepCtx * ctx, int32_t idx, int32_t off);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx * ctx, int32_t n);
extern int32_t pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx * ctx, uint8_t * path, int32_t len);
extern int32_t pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx * ctx, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t pipeline_module_func_alloc_slot(struct ast_Module * module);
extern int32_t pipeline_module_func_ref_at(struct ast_Module * module, int32_t func_index);
extern void pipeline_module_func_ref_set(struct ast_Module * module, int32_t func_index, int32_t func_ref);
extern void pipeline_module_func_set_return_type(struct ast_Module * module, int32_t fi, int32_t type_ref);
extern void pipeline_module_func_set_body_ref(struct ast_Module * module, int32_t fi, int32_t body_ref);
extern void pipeline_module_func_set_body_expr_ref(struct ast_Module * module, int32_t fi, int32_t body_expr_ref);
extern void pipeline_module_func_set_is_extern(struct ast_Module * module, int32_t fi, int32_t is_extern);
extern void pipeline_module_func_set_is_variadic(struct ast_Module * module, int32_t fi, int32_t is_variadic);
extern int32_t pipeline_module_func_is_variadic_at(struct ast_Module * module, int32_t fi);
extern void pipeline_module_func_set_num_params(struct ast_Module * module, int32_t fi, int32_t n);
extern void pipeline_module_func_set_num_generic_params(struct ast_Module * module, int32_t fi, int32_t n);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_name_equal_at(struct ast_Module * module, int32_t fi, uint8_t * name, int32_t name_len);
extern uint8_t pipeline_module_func_name_byte_at(struct ast_Module * module, int32_t fi, int32_t i);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int ast_ref_is_null(int32_t ref);
extern int32_t ast_ast_placeholder(void);
extern void ast_expr_layout_prime_call_resolved(void);
extern void ast_func_layout_prime_generic_params(void);
extern void ast_ast_arena_init(struct ast_ASTArena * arena);
extern int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena);
extern int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena * arena);
extern int32_t ast_ast_arena_block_alloc(struct ast_ASTArena * arena);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern void ast_expr_init_match_enum(struct ast_Expr * e);
extern int32_t pipeline_expr_append_call_arg(struct ast_ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_append_method_call_arg(struct ast_ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_append_match_arm(struct ast_ASTArena * arena, int32_t expr_ref, int32_t result_ref, int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant, int32_t variant_index);
extern int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern void pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i, int32_t v);
extern void pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i, int32_t v);
extern void pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i, int32_t is_var, int32_t variant_index);
extern int32_t pipeline_expr_append_struct_lit_field(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * name_bytes, int32_t name_len, int32_t init_ref);
extern int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena * arena, int32_t expr_ref, int32_t elem_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern void ast_expr_init_call_resolve(struct ast_ASTArena * arena, int32_t expr_ref);
extern void ast_ast_expr_apply_call_resolve(struct ast_ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref);
extern int ast_ast_name_bytes_equal(uint8_t * a_nm, int32_t a_len, uint8_t * b_nm, int32_t b_len);
extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena * a, int32_t body_ref);
extern int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena * a, int32_t expr_ref);
extern int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena * a, int32_t expr_ref);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_for_loops(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_regions(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_labeled_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_region_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ri);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena * a, int32_t br);
extern int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena * a, int32_t br);
extern uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_ast_block_const_init_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_const_type_ref(struct ast_ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_ast_block_let_init_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_let_type_ref(struct ast_ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena * a, int32_t br, int32_t ei);
extern int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_while_body_ref(struct ast_ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_for_init_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_step_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_for_body_ref(struct ast_ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern void ast_ast_arena_patch_block_parent_links(struct ast_ASTArena * arena, int32_t block_ref, int32_t parent_ref);
extern void ast_ast_arena_block_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b);
extern int32_t ast_ast_arena_func_alloc(struct ast_ASTArena * arena);
extern struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_func_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Func f);
struct codegen_CodegenOutBuf {
  uint8_t data[9437184];
  int32_t length;
};

struct xlang_slice_CodegenOutBuf { struct codegen_CodegenOutBuf *data; size_t length; };

struct xlang_slice_xlang_slice_CodegenOutBuf { struct xlang_slice_CodegenOutBuf *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf { struct xlang_slice_xlang_slice_CodegenOutBuf *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf { struct xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf *data; size_t length; };

struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_CodegenOutBuf *data; size_t length; };

extern int32_t codegen_path_is_std_io_driver_bytes(uint8_t * path);
extern int32_t codegen_path_is_std_io_core_bytes(uint8_t * path);
extern void codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap);
extern int32_t codegen_dep_import_path_len_at(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern int32_t codegen_ctx_dep_path_for_current_codegen_module_into(struct ast_PipelineDepCtx * ctx, uint8_t * dst);
extern int32_t codegen_module_import_path_len_at(struct ast_Module * module, int32_t import_idx, uint8_t * dst);
extern int32_t codegen_find_dep_index_by_path(struct ast_PipelineDepCtx * ctx, uint8_t * path, int32_t path_len);
extern int32_t codegen_find_seeded_global_dep_slot_by_path(uint8_t * path, int32_t path_len);
extern int32_t codegen_module_num_imports(struct ast_Module * module);
extern int32_t codegen_emit_prefix_len_from_ctx(struct ast_PipelineDepCtx * ctx, uint8_t * buf, int32_t buf_cap);
extern int32_t codegen_emit_async_run_seed_push_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_emit_async_sched_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index);
extern int32_t codegen_emit_async_sched_call_by_name(struct codegen_CodegenOutBuf * out, uint8_t * fn_name, int32_t fn_len);
extern int32_t codegen_emit_async_task_submit_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index);
extern int32_t codegen_emit_async_task_submit_call_by_symbol(struct codegen_CodegenOutBuf * out, uint8_t * prefix, int32_t prefix_len, uint8_t * fn_name, int32_t fn_len);
extern int32_t codegen_emit_async_binding_import_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t is_spawn);
extern int32_t codegen_emit_async_method_call_run(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t method_expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_find_module_func_index_by_name(struct ast_Module * module, uint8_t * nm, int32_t nm_len);
extern int32_t codegen_resolve_binding_import_dep_index(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t callee_expr_ref);
extern int32_t codegen_find_module_func_index_by_name_overload(struct ast_ASTArena * arena, struct ast_Module * module, int32_t call_expr_ref, uint8_t * nm, int32_t nm_len);
extern int32_t codegen_resolve_call_target_func_index(struct ast_ASTArena * arena, struct ast_Module * module, int32_t call_expr_ref);
extern int32_t codegen_expr_var_matches_func_param_index(struct ast_ASTArena * arena, int32_t var_ref, struct ast_Module * mod, int32_t func_index, int32_t param_idx, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_symbuf_bytes_eq(uint8_t * buf, int32_t buf_len, uint8_t * lit, int32_t lit_len);
extern int32_t codegen_call_num_args_override(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t num_args);
extern int32_t codegen_name_bytes_prefix_eq(uint8_t * name, int32_t name_len, uint8_t * expect, int32_t exp_len);
extern int32_t codegen_is_std_io_driver_bridge_name(uint8_t * name, int32_t name_len);
extern int32_t codegen_should_skip_emit_std_io_core_io_dup(uint8_t * dep_path, uint8_t * name, int32_t name_len);
extern int32_t codegen_should_skip_emit_std_io_trivial_handle(uint8_t * dep_path, uint8_t * name, int32_t name_len);
extern int32_t codegen_should_skip_later_same_name_body(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern int32_t codegen_should_skip_emit_func(uint8_t * dep_path, uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t codegen_force_param_std_io_driver_prefix_ok(uint8_t * prefix, int32_t prefix_len);
extern int32_t codegen_force_param_size_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_force_param_size_t_std_io_print_str_second(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_force_param_ptrdiff_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_force_param_uint32_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_use_buf_wrapper(uint8_t * name, int32_t name_len, int32_t num_args);
extern int32_t codegen_emit_io_driver_buf_call_name(struct codegen_CodegenOutBuf * out, uint8_t * name, int32_t name_len, int32_t num_args);
extern int32_t codegen_try_emit_std_io_driver_buf_body(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len);
extern int32_t codegen_field_access_base_is_pointer_ref(struct ast_ASTArena * arena, int32_t base_ref);
extern int32_t codegen_field_access_base_type_resolved(struct ast_ASTArena * arena, int32_t base_ref);
extern int32_t codegen_try_emit_fmt_string_lit_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_try_emit_size_align_of_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_call_arg_slice_abi(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t arg_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_field_access_base_is_pointer_param(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index);
extern int32_t codegen_field_access_base_is_pointer_local(struct ast_ASTArena * arena, int32_t base_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_field_access_base_param_type_known(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index);
extern int32_t codegen_field_access_base_is_slice_param_name(struct ast_ASTArena * arena, int32_t base_ref);
extern int32_t codegen_block_stmt_order_has_let(struct ast_ASTArena * arena, int32_t block_ref, int32_t let_idx);
extern int32_t codegen_append_byte(struct codegen_CodegenOutBuf * out, int32_t b);
extern int32_t codegen_append_byte_u8(struct codegen_CodegenOutBuf * out, uint8_t b);
extern int32_t codegen_emit_bytes_4(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_5(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_6(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_7(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_8(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_9(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_22(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_32(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_emit_bytes_64(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len);
extern int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len);
extern int32_t codegen_emit_bytes_3(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t codegen_emit_bytes_2(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len);
extern int32_t codegen_format_uint(struct codegen_CodegenOutBuf * out, int32_t val);
extern int32_t codegen_format_uint64(struct codegen_CodegenOutBuf * out, uint64_t val);
extern int32_t codegen_format_int(struct codegen_CodegenOutBuf * out, int64_t val);
extern int32_t codegen_emit_indent(struct codegen_CodegenOutBuf * out, int32_t indent);
extern int32_t codegen_emit_break_stmt(struct codegen_CodegenOutBuf * out, int32_t indent);
extern int32_t codegen_emit_continue_stmt(struct codegen_CodegenOutBuf * out, int32_t indent);
extern int32_t codegen_emit_type_kind_ord(struct codegen_CodegenOutBuf * out, int32_t tk);
extern int32_t codegen_emit_type_kind(struct codegen_CodegenOutBuf * out, int32_t kind_ord);
extern int32_t codegen_type_kind_append_to_scratch(uint8_t * scratch, int32_t cap, int32_t w, int32_t kind_ord);
extern int32_t codegen_emit_vector_c_type_out(struct codegen_CodegenOutBuf * out, int32_t elem_kind_ord, int32_t lanes);
extern int32_t codegen_type_kind_append_to_scratch_ord(uint8_t * scratch, int32_t cap, int32_t w, int32_t tk);
extern int32_t codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t codegen_emit_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_type_dep_struct_owner_index(struct ast_PipelineDepCtx * ctx, uint8_t * bare_nm, int32_t bare_len);
extern int32_t codegen_type_dep_struct_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap);
extern int32_t codegen_type_array_elem_is_u8(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_emit_c(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t ptr_type_ref, uint8_t * name, int32_t name_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_type_is(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_emit_local_fixed_array_elem_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_local_fixed_array_suffix(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref);
extern int32_t codegen_emit_local_fixed_array_let_finish(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t indent, uint8_t * name, int32_t name_len, int32_t linit_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_try_emit_slice_init_from_array_var(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t let_idx, int32_t let_type_ref, int32_t linit_ref);
extern int32_t codegen_emit_braced_array_lit_init(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t init_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_struct_field_type_via_pipeline(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t codegen_lookup_struct_field_type_ref(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * struct_name, int32_t struct_name_len, uint8_t * field_name, int32_t field_name_len);
extern int32_t codegen_should_skip_emit_struct_layout_for_abi_dup(uint8_t * name, int32_t name_len);
extern int32_t codegen_type_is_module_user_struct(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_type_is_module_user_enum(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_type_dep_enum_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap);
extern int32_t codegen_type_ref_is_host_concrete(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty);
extern int32_t codegen_resolve_generic_struct_field_type(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * layout_nm, int32_t layout_nl, uint8_t * field_nm, int32_t field_nl, int32_t ftr);
extern int32_t codegen_module_struct_layout_index_by_name(struct ast_Module * module, uint8_t * layout_nm, int32_t layout_nl);
extern int32_t codegen_generic_struct_resolve_arg_via_ctx(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t ty);
extern int32_t codegen_generic_struct_resolve_arg_via_map(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty, int32_t * mono_gen, int32_t * mono_conc, int32_t nmono);
extern int32_t codegen_generic_struct_fill_concrete_args(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref, int32_t ntp, int32_t * mono_out, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_generic_struct_mangled_name_into(struct ast_ASTArena * arena, uint8_t * layout_nm, int32_t layout_nl, int32_t * mono_tys, int32_t ntp, uint8_t * out_nm, int32_t out_cap);
extern int32_t codegen_mono_suffix_bytes_from_init(struct ast_ASTArena * arena, struct ast_Module * module, int32_t init_ref, uint8_t * buf, int32_t buf_cap, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_try_emit_struct_lit_mono_from_fields(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, uint8_t * layout_nm, int32_t layout_nl, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_generic_struct_mono_suffix(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t * mono_tys, int32_t ntp);
extern int32_t codegen_generic_struct_field_type_from_mono(struct ast_Module * module, struct ast_ASTArena * arena, int32_t layout_k, int32_t ftr, int32_t * mono_tys, int32_t ntp);
extern int32_t codegen_type_refs_same_for_mono(struct ast_ASTArena * arena, int32_t a, int32_t b);
extern int32_t codegen_type_ref_type_arg_nest_depth(struct ast_ASTArena * arena, int32_t ty);
extern int32_t codegen_generic_struct_combo_nest_depth(struct ast_ASTArena * arena, int32_t * mono_tys, int32_t ntp);
extern void codegen_generic_struct_sort_mono_combos_by_depth(struct ast_ASTArena * arena, int32_t * combos, int32_t ncombo, int32_t ntp);
extern int32_t codegen_collect_generic_struct_mono_combos(struct ast_Module * module, struct ast_ASTArena * arena, int32_t layout_k, uint8_t * layout_nm, int32_t layout_nl, int32_t ntp, int32_t * combos_out, int32_t max_combos);
extern int32_t codegen_maybe_emit_generic_struct_mono_suffix_for_type(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_build_func_param_mono_map(struct ast_Module * module, struct ast_ASTArena * arena, int32_t fi, int32_t * gen_refs, int32_t * conc_refs, int32_t max_entries);
extern int32_t codegen_emit_struct_field_decl_x(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * field_name, int32_t field_name_len, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_companion_named_slice_layout(struct codegen_CodegenOutBuf * out, uint8_t * pfx, int32_t pfx_len, uint8_t * name, int32_t name_len);
extern int32_t codegen_emit_module_struct_definitions(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_module_struct_forward_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t codegen_emit_module_struct_forward_declarations_ctx(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_module_enum_definitions(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * enum_prefix, int32_t enum_prefix_len);
extern int32_t codegen_emit_skipped_dep_type_definitions(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out);
extern int32_t codegen_emit_dep_struct_forward_declarations(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out);
extern int32_t codegen_resolve_binding_import_path_for_field_access(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst);
extern int32_t codegen_resolve_binding_import_path_for_method_call(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst);
extern int32_t codegen_emit_import_module_field_symbol(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_import_module_const_field(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_try_emit_match_field_bind(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, uint8_t * name, int32_t name_len);
extern void codegen_match_push_subject(struct ast_Module * module, int32_t matched_ref, struct ast_ASTArena * arena);
extern int32_t codegen_emit_match_arm_value(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t res_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_block_has_explicit_return(struct ast_ASTArena * arena, int32_t block_ref);
extern int32_t codegen_match_arm_result_is_return_control(struct ast_ASTArena * arena, int32_t res_ref);
extern int32_t codegen_match_has_return_arm(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t codegen_emit_match_stmt_arm_body(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t res_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void);
extern int32_t codegen_emit_match_as_stmt(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void);
extern int32_t codegen_emit_match_from_arm(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx, int32_t arm_i);
extern int32_t codegen_emit_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_callee_var_is_string_new(struct ast_Expr e);
extern int32_t codegen_emit_run_defers(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_current_func_returns_void(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_current_func_is_named_main(struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_return_stmt_with_context(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t indent, int32_t operand_ref, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void);
extern int32_t codegen_emit_block_final_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t final_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void);
extern int32_t codegen_emit_block(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_suffix_bytes(uint8_t * dst, uint8_t * src, int32_t len);
extern int32_t codegen_type_ref_to_suffix(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * buf, int32_t buf_cap);
extern int32_t codegen_module_func_overload_count(struct ast_Module * module, uint8_t * name_ptr, int32_t name_len);
extern int32_t codegen_func_param_sig_equal(struct ast_ASTArena * arena, struct ast_Module * mod_a, int32_t fi_a, struct ast_Module * mod_b, int32_t fi_b);
extern int32_t codegen_module_overload_param_sig_count(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern int32_t codegen_func_c_symbol_prefix_len(struct ast_Module * module, int32_t fi, int32_t prefix_len);
extern int32_t codegen_emit_func_link_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern int32_t codegen_name_is_local_binding(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * name, int32_t name_len);
extern int32_t codegen_try_emit_fn_as_value(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * name, int32_t name_len);
extern struct ast_ASTArena * codegen_arena_for_module(struct ast_PipelineDepCtx * ctx, struct ast_Module * module, struct ast_ASTArena * fallback);
extern int32_t codegen_emit_call_func_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t expr_ref, struct ast_Module * current_module, uint8_t * fallback_name, int32_t fallback_len);
extern void codegen_copy_func_name64_from_module(struct ast_Module * module, int32_t fi, uint8_t * dst);
extern void codegen_copy_param_name32_from_module(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst);
extern int32_t codegen_block_contains_return(struct ast_ASTArena * arena, int32_t block_ref);
extern int32_t codegen_emit_func(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, int is_entry, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx, int32_t call_init_globals);
extern int32_t codegen_is_libc_conflicting_extern_name(uint8_t * name, int32_t name_len);
extern int32_t codegen_find_mono_type_for_generic_func(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t arg_idx);
extern int32_t codegen_call_mono_type_at(struct ast_ASTArena * arena, int32_t ei, int32_t arg_idx, int32_t num_args);
extern int32_t codegen_mono_combo_slot_equal(struct ast_ASTArena * arena, int32_t a, int32_t b);
extern int32_t codegen_func_ret_type_param_extra(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern int32_t codegen_call_ret_type_param_concrete_at(struct ast_ASTArena * arena, int32_t ei);
extern int32_t codegen_collect_mono_combos_for_generic_func(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t * combos_out, int32_t max_combos, int32_t num_params, int32_t ret_extra);
extern int32_t codegen_try_emit_impl_method_mono_call_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, struct ast_Module * module, int32_t fi, int32_t receiver_ty);
extern int32_t codegen_emit_mono_mangled_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t * mono_tys, int32_t num_mono);
extern int32_t codegen_mono_subst_type(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_find_impl_method_for_type(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * method_name, int32_t method_name_len, int32_t receiver_type_ref);
extern int32_t codegen_try_emit_generic_identity_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_try_emit_generic_impl_method_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_try_emit_generic_impl_method_extern_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_func_extern_declaration(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_import_dep_function_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_x_ast_emit_header(struct codegen_CodegenOutBuf * out);
extern int32_t codegen_x_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index);
extern int32_t codegen_should_skip_emit_func_by_name(uint8_t * name, int32_t name_len);
extern int32_t codegen_is_submit_batch_buf_call(uint8_t * name, int32_t name_len);
extern int32_t codegen_force_param_i32(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index);
extern int32_t codegen_should_skip_emit_func_core_read_ptr(uint8_t * name, int32_t name_len);
extern int32_t codegen_std_io_fixed_fd_emit_impl(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern struct ast_Module * pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_ASTArena * pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena * arena, int32_t ref, uint8_t * out64);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena * arena, int32_t ref);
extern int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena * arena, int32_t type_ref, int32_t idx);
extern int32_t pipeline_module_struct_layout_num_type_params_at(struct ast_Module * module, int32_t li);
extern int32_t pipeline_module_struct_layout_type_param_name_len(struct ast_Module * module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_type_param_name_into(struct ast_Module * module, int32_t li, int32_t j, uint8_t * out64);
extern int32_t pipeline_typeck_resolve_type_alias_ref_c(struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t pipeline_codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_codegen_c_file_prologue_done_get(void);
extern void pipeline_codegen_c_file_prologue_done_set(int32_t v);
extern void pipeline_codegen_c_file_prologue_done_reset(void);
extern int32_t pipeline_codegen_struct_tag_try_claim(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
extern int32_t pipeline_codegen_emit_struct_field_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_codegen_emit_struct_field_decl(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * field_name, int32_t field_name_len, uint8_t * struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_codegen_emit_seed_mega_enabled(void);
extern int32_t pipeline_codegen_emit_float_lit_c(struct codegen_CodegenOutBuf * out, double float_val, int32_t bits_lo, int32_t bits_hi);
extern void driver_diagnostic_codegen_emit_func_fail(struct ast_Module * module, int32_t func_index);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module * module, int32_t idx, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t layout_idx, int32_t field_idx);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t layout_idx, int32_t field_idx);
extern void pipeline_module_struct_layout_field_name_into(struct ast_Module * module, int32_t layout_idx, int32_t field_idx, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_is_export_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_kind_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module * module, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module * module, int32_t idx, int32_t sel, int32_t off);
extern int32_t pipeline_module_import_path_len(struct ast_Module * module, int32_t idx);
extern void pipeline_module_import_path_copy(struct ast_Module * module, int32_t idx, uint8_t * dst, int32_t dst_cap);
extern int32_t parser_get_module_num_imports(struct ast_Module * module);
extern uint8_t * driver_dep_arena_buf(int32_t i);
extern uint8_t * driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t driver_dep_slot_for_path(uint8_t * path);
extern uint8_t * driver_get_current_dep_path_for_codegen(void);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_is_c_static_const_init(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena * arena, int32_t a, int32_t b);
extern int32_t pipeline_expr_call_type_arg_ref_at(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_guard_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t i);
extern void pipeline_codegen_match_set_subject_c(struct ast_Module * module, int32_t matched_ref, int32_t subject_ty);
extern void pipeline_codegen_match_clear_subject_c(void);
extern int32_t pipeline_codegen_match_matched_ref_c(void);
extern int32_t pipeline_codegen_match_subject_ty_c(void);
extern struct ast_Module * pipeline_codegen_match_mod_c(void);
extern int32_t pipeline_codegen_match_name_is_subject_field_c(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * name, int32_t name_len);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j, uint8_t * out);
extern int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena * arena, int32_t expr_ref, int32_t j);
extern int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_module_enum_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_enum_num_variants(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_enum_variant_name_len(struct ast_Module * module, int32_t idx, int32_t variant_idx);
extern uint8_t pipeline_module_enum_variant_name_byte_at(struct ast_Module * module, int32_t idx, int32_t variant_idx, int32_t off);
extern void pipeline_codegen_try_mark_enum_field_access(struct ast_Module * module, struct ast_ASTArena * arena, int32_t expr_ref, struct ast_PipelineDepCtx * dep_ctx);
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_init_ref(struct ast_Module * module, int32_t idx);
extern int32_t pipeline_expr_int_val_at(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t * path);
extern void pipeline_module_func_name_copy64(struct ast_Module * module, int32_t fi, uint8_t * dst);
extern void pipeline_module_func_param_name_copy32(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_param_name_len_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_find_fixed_array_slice_escape(struct ast_ASTArena * arena, int32_t body_ref, uint8_t * vname, int32_t vlen, int32_t * out_arr_sz, int32_t * out_elem_tr, int32_t * out_arr_init_ref);
extern void pipeline_dep_ctx_empty_param_reset(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx * ctx, int32_t pi);
extern int32_t pipeline_dep_ctx_empty_param_at(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx * ctx);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_used_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_naked_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_entry_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_no_mangle_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_interrupt_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_is_variadic_at(struct ast_Module * module, int32_t fi);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module * module, int32_t fi, int32_t pi);
extern void pipeline_block_const_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t ci, uint8_t * dst);
extern int32_t pipeline_block_const_name_len(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t ci);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_if_cond_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_defer_body_ref(struct ast_ASTArena * arena, int32_t br, int32_t di);
extern int32_t pipeline_module_func_ref_at(struct ast_Module * module, int32_t func_index);
extern int32_t pipeline_asm_resolve_whole_import_qualified_symbol_c(struct ast_ASTArena * arena, struct ast_Module * cur_mod, int32_t callee_expr_ref, uint8_t * sym_flat, int32_t * out_match_imp_j);
extern uint8_t pipeline_block_stmt_order_kind(struct ast_ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_num_labeled_stmts(struct ast_ASTArena * arena, int32_t br);
extern int32_t pipeline_block_labeled_is_goto(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_labeled_label_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern void pipeline_block_labeled_label_copy32(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_labeled_goto_target_len(struct ast_ASTArena * arena, int32_t br, int32_t li);
extern void pipeline_block_labeled_goto_target_copy32(struct ast_ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena * arena, int32_t br, int32_t li);
int32_t codegen_path_is_std_io_driver_bytes(uint8_t * path) {
  uint8_t expect[14] = {115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0};
  int32_t i = 0;
  if ((path ==0)) {
    return 0;
  }
  while ((i < 14)) {
    if (((path)[i] !=(expect)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_path_is_std_io_core_bytes(uint8_t * path) {
  uint8_t expect[12] = {115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101, 0};
  int32_t i = 0;
  int32_t pi = 0;
  int32_t ei = 0;
  if ((path ==0)) {
    return 0;
  }
  while ((i < 12)) {
    (void)((pi = ((int32_t)((path)[i]))));
    (void)((ei = ((int32_t)((expect)[i]))));
    if ((pi !=ei)) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
void codegen_import_path_to_c_prefix_into(uint8_t * path, uint8_t * buf, int32_t buf_cap) {
  if (((buf ==0) || (buf_cap <=0))) {
    return;
  }
  int32_t off = 0;
  int32_t pi = 0;
  while ((path !=0)) {
    uint8_t ch = (path)[pi];
    if ((ch ==0)) {
      break;
    }
    if (((off + 2) >=buf_cap)) {
      break;
    }
    if ((ch ==46)) {
      (void)(((buf)[off] = ((uint8_t)(95))));
    } else {
      (void)(((buf)[off] = ch));
    }
    (void)((off = (off + 1)));
    (void)((pi = (pi + 1)));
  }
  if (((off + 1) < buf_cap)) {
    (void)(((buf)[off] = ((uint8_t)(95))));
    (void)((off = (off + 1)));
  }
  (void)(((buf)[off] = ((uint8_t)(0))));
}
int32_t codegen_dep_import_path_len_at(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst) {
  {
    int32_t plen = pipeline_dep_ctx_import_path_len(ctx, idx);
    if ((plen <=0)) {
      return 0;
    }
    (void)(pipeline_dep_ctx_import_path_copy64(ctx, idx, dst));
    return plen;
  }
}
int32_t codegen_ctx_dep_path_for_current_codegen_module_into(struct ast_PipelineDepCtx * ctx, uint8_t * dst) {
  {
    if ((ctx ==0)) {
      return 0;
    }
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t j = 0;
    while ((j < nd)) {
      if ((pipeline_dep_ctx_module_at(ctx, j) ==((ctx)->current_codegen_module))) {
        return codegen_dep_import_path_len_at(ctx, j, dst);
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
}
int32_t codegen_module_import_path_len_at(struct ast_Module * module, int32_t import_idx, uint8_t * dst) {
  {
    if ((((module ==0) || (dst ==0)) || (import_idx < 0))) {
      return 0;
    }
    int32_t plen = pipeline_module_import_path_len(module, import_idx);
    if ((plen <=0)) {
      return 0;
    }
    (void)(pipeline_module_import_path_copy(module, import_idx, dst, 64));
    return plen;
  }
}
int32_t codegen_find_dep_index_by_path(struct ast_PipelineDepCtx * ctx, uint8_t * path, int32_t path_len) {
  {
    if ((((ctx ==0) || (path ==0)) || (path_len <=0))) {
      return -1;
    }
    int32_t di = 0;
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    while ((di < nd)) {
      uint8_t dep_path[128] = {};
      int32_t dep_len = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
      if ((dep_len ==path_len)) {
        int eq = 1;
        int32_t k = 0;
        while (((k < path_len) && (k < 64))) {
          if (((dep_path)[k] !=(path)[k])) {
            (void)((eq = 0));
            break;
          }
          (void)((k = (k + 1)));
        }
        if (eq) {
          return di;
        }
      }
      (void)((di = (di + 1)));
    }
    return -1;
  }
}
int32_t codegen_find_seeded_global_dep_slot_by_path(uint8_t * path, int32_t path_len) {
  {
    if ((((path ==0) || (path_len <=0)) || (path_len > 127))) {
      return -1;
    }
    uint8_t path_buf[128] = {};
    int32_t i = 0;
    while (((i < path_len) && (i < 63))) {
      (void)(((path_buf)[i] = (path)[i]));
      (void)((i = (i + 1)));
    }
    (void)(((path_buf)[i] = ((uint8_t)(0))));
    int32_t gs = driver_dep_slot_for_path(&((path_buf)[0]));
    if (((gs >=0) && (driver_dep_seeded_get(gs) !=0))) {
      return gs;
    }
    return -1;
  }
}
int32_t codegen_module_num_imports(struct ast_Module * module) {
  {
    if ((module ==0)) {
      return 0;
    }
    int32_t n_imp = parser_get_module_num_imports(module);
    if ((n_imp > 0)) {
      return n_imp;
    }
    return ((module)->num_imports);
  }
}
int32_t codegen_emit_prefix_len_from_ctx(struct ast_PipelineDepCtx * ctx, uint8_t * buf, int32_t buf_cap) {
  if ((((buf ==0) || (buf_cap <=0)) || (ctx ==0))) {
    return 0;
  }
  (void)(((buf)[0] = ((uint8_t)(0))));
  if (((((ctx)->current_codegen_dep_index) < 0) && (((ctx)->entry_module_import_path_len) > 0))) {
    int32_t pi = 0;
    while (((pi < ((ctx)->entry_module_import_path_len)) && (pi < (buf_cap - 1)))) {
      (void)(((buf)[pi] = (((ctx)->entry_module_import_path_mirror))[pi]));
      (void)((pi = (pi + 1)));
    }
    (void)(((buf)[pi] = ((uint8_t)(0))));
    return pi;
  }
  if ((((ctx)->current_codegen_prefix_len) > 0)) {
    int32_t pi = 0;
    while (((pi < ((ctx)->current_codegen_prefix_len)) && (pi < (buf_cap - 1)))) {
      (void)(((buf)[pi] = (((ctx)->current_codegen_prefix_mirror))[pi]));
      (void)((pi = (pi + 1)));
    }
    (void)(((buf)[pi] = ((uint8_t)(0))));
    return pi;
  }
  uint8_t path_buf[128] = {};
  int32_t path_len = 0;
  if ((((ctx)->current_codegen_dep_index) >=0)) {
    (void)((path_len = codegen_dep_import_path_len_at(ctx, ((ctx)->current_codegen_dep_index), &((path_buf)[0]))));
  }
  if ((path_len ==0)) {
    (void)((path_len = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &((path_buf)[0]))));
  }
  if ((path_len ==0)) {
    return 0;
  }
  if ((codegen_path_is_std_io_core_bytes(&((path_buf)[0])) !=0)) {
    return 0;
  }
  (void)(codegen_import_path_to_c_prefix_into(&((path_buf)[0]), buf, buf_cap));
  int32_t i = 0;
  while (((i < buf_cap) && ((buf)[i] !=0))) {
    (void)((i = (i + 1)));
  }
  return i;
}
int32_t codegen_emit_async_run_seed_push_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t type_ref) {
  {
    uint8_t push_i32[29] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 51, 50};
    uint8_t push_u32[29] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 51, 50};
    uint8_t push_i64[29] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 54, 52};
    uint8_t push_usize[31] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 115, 105, 122, 101};
    int32_t kind_ord = 0;
    if (((arena !=0) && !(ast_ref_is_null(type_ref)))) {
      (void)((kind_ord = pipeline_type_kind_ord_at(arena, type_ref)));
    }
    if ((kind_ord ==3)) {
      return codegen_emit_bytes_from_ptr(out, &((push_u32)[0]), 28);
    }
    if ((kind_ord ==5)) {
      return codegen_emit_bytes_from_ptr(out, &((push_i64)[0]), 28);
    }
    if ((kind_ord ==6)) {
      return codegen_emit_bytes_from_ptr(out, &((push_usize)[0]), 30);
    }
    return codegen_emit_bytes_from_ptr(out, &((push_i32)[0]), 28);
  }
}
int32_t codegen_emit_async_sched_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index) {
  {
    uint8_t sched_prefix[18] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95};
    uint8_t fn_name[128] = {};
    int32_t fn_len = 0;
    if ((((module ==0) || (func_index < 0)) || (func_index >=((module)->num_funcs)))) {
      return -1;
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, func_index)));
    if ((fn_len <=0)) {
      return -1;
    }
    (void)(pipeline_module_func_name_copy64(module, func_index, &((fn_name)[0])));
    if ((codegen_emit_bytes_from_ptr(out, &((sched_prefix)[0]), 17) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((fn_name)[0]), fn_len) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -1;
    }
    return codegen_append_byte(out, 41);
  }
}
int32_t codegen_emit_async_sched_call_by_name(struct codegen_CodegenOutBuf * out, uint8_t * fn_name, int32_t fn_len) {
  {
    uint8_t sched_prefix[18] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95};
    if ((((out ==0) || (fn_name ==0)) || (fn_len <=0))) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((sched_prefix)[0]), 17) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, fn_name, fn_len) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -1;
    }
    return codegen_append_byte(out, 41);
  }
}
int32_t codegen_emit_async_task_submit_call(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t func_index) {
  {
    uint8_t submit_name[23] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116};
    uint8_t cast_prefix[19] = {40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41};
    uint8_t fn_name[128] = {};
    int32_t fn_len = 0;
    if ((((module ==0) || (func_index < 0)) || (func_index >=((module)->num_funcs)))) {
      return -1;
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, func_index)));
    if ((fn_len <=0)) {
      return -1;
    }
    (void)(pipeline_module_func_name_copy64(module, func_index, &((fn_name)[0])));
    if ((codegen_emit_bytes_from_ptr(out, &((submit_name)[0]), 22) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((cast_prefix)[0]), 19) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((fn_name)[0]), fn_len) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 41) !=0)) {
      return -1;
    }
    return 0;
  }
}
int32_t codegen_emit_async_task_submit_call_by_symbol(struct codegen_CodegenOutBuf * out, uint8_t * prefix, int32_t prefix_len, uint8_t * fn_name, int32_t fn_len) {
  {
    uint8_t submit_name[23] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116};
    uint8_t cast_prefix[19] = {40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41};
    if ((((out ==0) || (fn_name ==0)) || (fn_len <=0))) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((submit_name)[0]), 22) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((cast_prefix)[0]), 19) !=0)) {
      return -1;
    }
    if (((((prefix !=0) && (prefix_len > 0)) && (codegen_c_prefix_redundant_with_name(prefix, prefix_len, fn_name, fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, prefix, prefix_len) !=0))) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, fn_name, fn_len) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 41) !=0)) {
      return -1;
    }
    return 0;
  }
}
int32_t codegen_emit_async_binding_import_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t call_expr_ref, struct ast_PipelineDepCtx * ctx, int32_t is_spawn) {
  {
    uint8_t reset_name[26] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116};
    uint8_t comma[3] = {44, 32, 0};
    uint8_t dep_path[128] = {};
    uint8_t prefix_buf[128] = {};
    int32_t dep_ix = -1;
    int32_t n_args = 0;
    int32_t ai = 0;
    int32_t prefix_len = 0;
    if ((((arena ==0) || (out ==0)) || (ctx ==0))) {
      return -1;
    }
    if (((ast_ref_is_null(call_expr_ref) || (call_expr_ref <=0)) || (call_expr_ref > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr call_e = ast_ast_arena_expr_get(arena, call_expr_ref);
    if (((((((int32_t)(((call_e).kind))) !=48) || ast_ref_is_null(((call_e).call_callee_ref))) || (((call_e).call_callee_ref) <=0)) || (((call_e).call_callee_ref) > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr callee_e = ast_ast_arena_expr_get(arena, ((call_e).call_callee_ref));
    if (((((int32_t)(((callee_e).kind))) !=44) || (((callee_e).field_access_field_len) <=0))) {
      return -1;
    }
    (void)((n_args = ((call_e).call_num_args)));
    if ((n_args < 0)) {
      return -1;
    }
    if ((is_spawn ==0)) {
      if ((n_args > 0)) {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((reset_name)[0]), 25) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
        (void)((ai = 0));
        while ((ai < n_args)) {
          int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
          int32_t arg_type_ref = 0;
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
          if (!(ast_ref_is_null(arg_ref))) {
            (void)((arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref)));
          }
          if ((codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          if ((!(ast_ref_is_null(arg_ref)) && (codegen_emit_expr(arena, out, arg_ref, ctx) !=0))) {
            return -1;
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -1;
          }
          (void)((ai = (ai + 1)));
        }
        if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
          return -1;
        }
        if ((codegen_emit_async_sched_call_by_name(out, &((((callee_e).field_access_field_name))[0]), ((callee_e).field_access_field_len)) !=0)) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      return codegen_emit_async_sched_call_by_name(out, &((((callee_e).field_access_field_name))[0]), ((callee_e).field_access_field_len));
    }
    (void)((dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, ((call_e).call_callee_ref))));
    if (((dep_ix < 0) || (dep_ix >=pipeline_dep_ctx_ndep(ctx)))) {
      return -1;
    }
    (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &((dep_path)[0])));
    (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
    while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
      (void)((prefix_len = (prefix_len + 1)));
    }
    if ((n_args > 0)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      (void)((ai = 0));
      while ((ai < n_args)) {
        int32_t arg_ref2 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
        int32_t arg_type_ref2 = 0;
        if (((ai > 0) && (codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0))) {
          return -1;
        }
        if (!(ast_ref_is_null(arg_ref2))) {
          (void)((arg_type_ref2 = pipeline_expr_resolved_type_ref(arena, arg_ref2)));
        }
        if ((codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref2) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((!(ast_ref_is_null(arg_ref2)) && (codegen_emit_expr(arena, out, arg_ref2, ctx) !=0))) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
        (void)((ai = (ai + 1)));
      }
      if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_async_task_submit_call_by_symbol(out, &((prefix_buf)[0]), prefix_len, &((((callee_e).field_access_field_name))[0]), ((callee_e).field_access_field_len)) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_async_task_submit_call_by_symbol(out, &((prefix_buf)[0]), prefix_len, &((((callee_e).field_access_field_name))[0]), ((callee_e).field_access_field_len));
  }
}
int32_t codegen_emit_async_method_call_run(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t method_expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    uint8_t reset_name[26] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116};
    uint8_t comma[3] = {44, 32, 0};
    int32_t ai = 0;
    if ((((arena ==0) || (out ==0)) || (ctx ==0))) {
      return -1;
    }
    if (((ast_ref_is_null(method_expr_ref) || (method_expr_ref <=0)) || (method_expr_ref > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr method_e = ast_ast_arena_expr_get(arena, method_expr_ref);
    if (((((int32_t)(((method_e).kind))) !=49) || (((method_e).method_call_name_len) <=0))) {
      return -1;
    }
    if ((((method_e).method_call_num_args) > 0)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((reset_name)[0]), 25) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      while ((ai < ((method_e).method_call_num_args))) {
        int32_t arg_ref = pipeline_expr_method_call_arg_ref(arena, method_expr_ref, ai);
        int32_t arg_type_ref = 0;
        if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
          return -1;
        }
        if (!(ast_ref_is_null(arg_ref))) {
          (void)((arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref)));
        }
        if ((codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((!(ast_ref_is_null(arg_ref)) && (codegen_emit_expr(arena, out, arg_ref, ctx) !=0))) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
        (void)((ai = (ai + 1)));
      }
      if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_async_sched_call_by_name(out, &((((method_e).method_call_name))[0]), ((method_e).method_call_name_len)) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_async_sched_call_by_name(out, &((((method_e).method_call_name))[0]), ((method_e).method_call_name_len));
  }
}
int32_t codegen_find_module_func_index_by_name(struct ast_Module * module, uint8_t * nm, int32_t nm_len) {
  {
    if ((((module ==0) || (nm ==0)) || (nm_len <=0))) {
      return -1;
    }
    int32_t fi = 0;
    while ((fi < ((module)->num_funcs))) {
      int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
      if (((fn_len ==nm_len) && (fn_len > 0))) {
        uint8_t fn_name[128] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        (void)(pipeline_module_func_name_copy64(module, fi, &((fn_name)[0])));
        while ((bi < fn_len)) {
          if (((fn_name)[bi] !=(nm)[bi])) {
            (void)((matched = 0));
            (void)((bi = fn_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          return fi;
        }
      }
      (void)((fi = (fi + 1)));
    }
    return -1;
  }
}
int32_t codegen_resolve_binding_import_dep_index(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t callee_expr_ref) {
  {
    if ((((ctx ==0) || (arena ==0)) || (((ctx)->current_codegen_module) ==0))) {
      return -1;
    }
    if (((ast_ref_is_null(callee_expr_ref) || (callee_expr_ref <=0)) || (callee_expr_ref > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr callee_e = ast_ast_arena_expr_get(arena, callee_expr_ref);
    if ((((((int32_t)(((callee_e).kind))) !=44) || (((callee_e).field_access_base_ref) <=0)) || (((callee_e).field_access_base_ref) > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr base_e = ast_ast_arena_expr_get(arena, ((callee_e).field_access_base_ref));
    if ((((((int32_t)(((base_e).kind))) !=3) || (((base_e).var_name_len) <=0)) || (((base_e).var_name_len) > 127))) {
      return -1;
    }
    struct ast_Module * cur_mod = ((ctx)->current_codegen_module);
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t j = 0;
    int32_t n_imp = codegen_module_num_imports(cur_mod);
    while (((j < n_imp) && (j < nd))) {
      if ((pipeline_module_import_kind_at(cur_mod, j) ==1)) {
        int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
        if ((bind_len ==((base_e).var_name_len))) {
          int32_t matched = 1;
          int32_t kk = 0;
          while ((kk < bind_len)) {
            if (((((base_e).var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
              (void)((matched = 0));
              (void)((kk = bind_len));
            } else {
              (void)((kk = (kk + 1)));
            }
          }
          if ((matched !=0)) {
            uint8_t import_path[128] = {};
            int32_t import_path_len = codegen_module_import_path_len_at(cur_mod, j, &((import_path)[0]));
            if ((import_path_len <=0)) {
              return -1;
            }
            return codegen_find_dep_index_by_path(ctx, &((import_path)[0]), import_path_len);
          }
        }
      }
      (void)((j = (j + 1)));
    }
    return -1;
  }
}
int32_t codegen_find_module_func_index_by_name_overload(struct ast_ASTArena * arena, struct ast_Module * module, int32_t call_expr_ref, uint8_t * nm, int32_t nm_len) {
  {
    int32_t fi = 0;
    int32_t first_idx = -1;
    int32_t best_idx = -1;
    int32_t best_score = -1;
    int32_t num_args = 0;
    if ((((module ==0) || (nm ==0)) || (nm_len <=0))) {
      return -1;
    }
    if (((call_expr_ref > 0) && (call_expr_ref <=((arena)->num_exprs)))) {
      (void)((num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref)));
    }
    while ((fi < ((module)->num_funcs))) {
      int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
      if (((fn_len ==nm_len) && (fn_len > 0))) {
        uint8_t fn_name[128] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        (void)(pipeline_module_func_name_copy64(module, fi, &((fn_name)[0])));
        while ((bi < fn_len)) {
          if (((fn_name)[bi] !=(nm)[bi])) {
            (void)((matched = 0));
            (void)((bi = fn_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          if ((first_idx < 0)) {
            (void)((first_idx = fi));
          }
          if ((num_args > 0)) {
            int32_t np = pipeline_module_func_num_params_at(module, fi);
            if ((np ==num_args)) {
              int32_t ai = 0;
              int32_t score = 0;
              int32_t ok = 1;
              while ((ai < num_args)) {
                int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
                int32_t param_ty = pipeline_module_func_param_type_ref_at(module, fi, ai);
                int32_t arg_ty = 0;
                int32_t sc = 0;
                if ((arg_ref <=0)) {
                  (void)((ok = 0));
                  break;
                }
                (void)((arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref)));
                if ((((arg_ty > 0) && (param_ty > 0)) && (pipeline_typeck_type_refs_equal_c(arena, arg_ty, param_ty) !=0))) {
                  (void)((sc = 1000));
                } else {
                  if (((arg_ty > 0) && (param_ty > 0))) {
                    int32_t ak = pipeline_type_kind_ord_at(arena, arg_ty);
                    int32_t pk = pipeline_type_kind_ord_at(arena, param_ty);
                    if (((ak ==pk) && (ak !=0))) {
                      (void)((sc = 1));
                    } else {
                      (void)((sc = -1));
                    }
                  } else {
                    (void)((sc = 0));
                  }
                }
                if ((sc < 0)) {
                  (void)((ok = 0));
                  break;
                }
                (void)((score = (score + sc)));
                (void)((ai = (ai + 1)));
              }
              if (((ok !=0) && (score > best_score))) {
                (void)((best_score = score));
                (void)((best_idx = fi));
              }
            }
          }
        }
      }
      (void)((fi = (fi + 1)));
    }
    if ((best_idx >=0)) {
      return best_idx;
    }
    return first_idx;
  }
}
int32_t codegen_resolve_call_target_func_index(struct ast_ASTArena * arena, struct ast_Module * module, int32_t call_expr_ref) {
  {
    int32_t func_ix = -1;
    if (((module ==0) || (arena ==0))) {
      return -1;
    }
    (void)((func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref)));
    if (((func_ix >=0) && (func_ix < ((module)->num_funcs)))) {
      return func_ix;
    }
    if (((ast_ref_is_null(call_expr_ref) || (call_expr_ref <=0)) || (call_expr_ref > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr call_e = ast_ast_arena_expr_get(arena, call_expr_ref);
    if ((((int32_t)(((call_e).kind))) ==48)) {
      if (((ast_ref_is_null(((call_e).call_callee_ref)) || (((call_e).call_callee_ref) <=0)) || (((call_e).call_callee_ref) > ((arena)->num_exprs)))) {
        return -1;
      }
      struct ast_Expr callee_e = ast_ast_arena_expr_get(arena, ((call_e).call_callee_ref));
      if (((((int32_t)(((callee_e).kind))) ==3) && (((callee_e).var_name_len) > 0))) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &((((callee_e).var_name))[0]), ((callee_e).var_name_len));
      }
      if (((((int32_t)(((callee_e).kind))) ==44) && (((callee_e).field_access_field_len) > 0))) {
        return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &((((callee_e).field_access_field_name))[0]), ((callee_e).field_access_field_len));
      }
      return -1;
    }
    if (((((int32_t)(((call_e).kind))) ==49) && (((call_e).method_call_name_len) > 0))) {
      return codegen_find_module_func_index_by_name_overload(arena, module, call_expr_ref, &((((call_e).method_call_name))[0]), ((call_e).method_call_name_len));
    }
    return -1;
  }
}
int32_t codegen_expr_var_matches_func_param_index(struct ast_ASTArena * arena, int32_t var_ref, struct ast_Module * mod, int32_t func_index, int32_t param_idx, struct ast_PipelineDepCtx * ctx) {
  {
    if (((ast_ref_is_null(var_ref) || (var_ref <=0)) || (var_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    if (((func_index < 0) || (func_index >=((mod)->num_funcs)))) {
      return 0;
    }
    int32_t np = pipeline_module_func_num_params_at(mod, func_index);
    if (((param_idx < 0) || (param_idx >=np))) {
      return 0;
    }
    struct ast_Expr base = ast_ast_arena_expr_get(arena, var_ref);
    if ((((int32_t)(((base).kind))) !=3)) {
      return 0;
    }
    int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, param_idx);
    if ((p_name_len > 0)) {
      uint8_t pname_buf[128] = {};
      (void)(pipeline_module_func_param_name_copy32(mod, func_index, param_idx, &((pname_buf)[0])));
      if (((pname_buf)[0] > 32)) {
        if ((((base).var_name_len) !=p_name_len)) {
          return 0;
        }
        if (((((base).var_name_len) <=0) || ((((base).var_name))[0] <=32))) {
          return 0;
        }
        int32_t j = 0;
        while ((j < p_name_len)) {
          if (((((base).var_name))[j] !=(pname_buf)[j])) {
            return 0;
          }
          (void)((j = (j + 1)));
        }
        return 1;
      }
    }
    if ((ctx ==0)) {
      return 0;
    }
    if ((((ctx)->current_func_single_empty_param_index) !=param_idx)) {
      return 0;
    }
    if (((((base).var_name_len) <=0) || ((((base).var_name))[0] <=32))) {
      return 1;
    }
    return 0;
  }
}
int32_t codegen_symbuf_bytes_eq(uint8_t * buf, int32_t buf_len, uint8_t * lit, int32_t lit_len) {
  if ((((buf ==0) || (lit ==0)) || (buf_len !=lit_len))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < lit_len)) {
    if (((buf)[i] !=(lit)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_call_num_args_override(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t num_args) {
  if ((num_args <=0)) {
    return num_args;
  }
  uint8_t buf[96] = {};
  int32_t full = 0;
  int32_t i = 0;
  if (((prefix !=0) && (prefix_len > 0))) {
    (void)((i = 0));
    while (((i < prefix_len) && (full < 96))) {
      (void)(((buf)[full] = (prefix)[i]));
      (void)((full = (full + 1)));
      (void)((i = (i + 1)));
    }
  }
  if (((name !=0) && (name_len > 0))) {
    (void)((i = 0));
    while (((i < name_len) && (full < 96))) {
      (void)(((buf)[full] = (name)[i]));
      (void)((full = (full + 1)));
      (void)((i = (i + 1)));
    }
  }
  uint8_t z0[13] = {118, 101, 99, 95, 108, 101, 110, 95, 101, 109, 112, 116, 121};
  uint8_t z1[21] = {115, 116, 100, 95, 118, 101, 99, 95, 118, 101, 99, 95, 108, 101, 110, 95, 101, 109, 112, 116, 121};
  uint8_t z2[15] = {97, 108, 108, 111, 99, 95, 115, 105, 122, 101, 95, 122, 101, 114, 111};
  uint8_t z3[24] = {115, 116, 100, 95, 104, 101, 97, 112, 95, 97, 108, 108, 111, 99, 95, 115, 105, 122, 101, 95, 122, 101, 114, 111};
  uint8_t z4[13] = {114, 117, 110, 116, 105, 109, 101, 95, 114, 101, 97, 100, 121};
  uint8_t z5[25] = {115, 116, 100, 95, 114, 117, 110, 116, 105, 109, 101, 95, 114, 117, 110, 116, 105, 109, 101, 95, 114, 101, 97, 100, 121};
  uint8_t z6[10] = {115, 116, 114, 105, 110, 103, 95, 110, 101, 119};
  uint8_t z7[21] = {115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 103, 95, 110, 101, 119};
  uint8_t z8[11] = {112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114};
  uint8_t z9[22] = {115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114};
  uint8_t z10[11] = {116, 104, 114, 101, 97, 100, 95, 115, 101, 108, 102};
  uint8_t z11[22] = {115, 116, 100, 95, 116, 104, 114, 101, 97, 100, 95, 116, 104, 114, 101, 97, 100, 95, 115, 101, 108, 102};
  uint8_t z12[22] = {116, 104, 114, 101, 97, 100, 95, 100, 117, 109, 109, 121, 95, 101, 110, 116, 114, 121, 95, 112, 116, 114};
  uint8_t z13[33] = {115, 116, 100, 95, 116, 104, 114, 101, 97, 100, 95, 116, 104, 114, 101, 97, 100, 95, 100, 117, 109, 109, 121, 95, 101, 110, 116, 114, 121, 95, 112, 116, 114};
  uint8_t z14[16] = {110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 110, 115};
  uint8_t z15[25] = {115, 116, 100, 95, 116, 105, 109, 101, 95, 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 110, 115};
  uint8_t z16[16] = {110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 109, 115};
  uint8_t z17[25] = {115, 116, 100, 95, 116, 105, 109, 101, 95, 110, 111, 119, 95, 109, 111, 110, 111, 116, 111, 110, 105, 99, 95, 109, 115};
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z0)[0]), 13) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z1)[0]), 21) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z2)[0]), 15) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z3)[0]), 24) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z4)[0]), 13) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z5)[0]), 25) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z6)[0]), 10) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z7)[0]), 21) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z8)[0]), 11) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z9)[0]), 22) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z10)[0]), 11) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z11)[0]), 22) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z12)[0]), 22) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z13)[0]), 33) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z14)[0]), 16) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z15)[0]), 25) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z16)[0]), 16) !=0)) {
    return 0;
  }
  if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((z17)[0]), 25) !=0)) {
    return 0;
  }
  if ((num_args >=1)) {
    uint8_t o0[7] = {102, 109, 116, 95, 105, 51, 50};
    uint8_t o1[16] = {99, 111, 114, 101, 95, 102, 109, 116, 95, 102, 109, 116, 95, 105, 51, 50};
    uint8_t o2[9] = {112, 114, 105, 110, 116, 95, 105, 51, 50};
    uint8_t o3[16] = {115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 105, 51, 50};
    uint8_t o4[9] = {112, 114, 105, 110, 116, 95, 117, 51, 50};
    uint8_t o5[16] = {115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 117, 51, 50};
    uint8_t o6[9] = {112, 114, 105, 110, 116, 95, 105, 54, 52};
    uint8_t o7[16] = {115, 116, 100, 95, 105, 111, 95, 112, 114, 105, 110, 116, 95, 105, 54, 52};
    uint8_t o8[6] = {111, 107, 95, 105, 51, 50};
    uint8_t o9[18] = {99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 111, 107, 95, 105, 51, 50};
    uint8_t o10[7] = {101, 114, 114, 95, 105, 51, 50};
    uint8_t o11[19] = {99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 101, 114, 114, 95, 105, 51, 50};
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o0)[0]), 7) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o1)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o2)[0]), 9) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o3)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o4)[0]), 9) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o5)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o6)[0]), 9) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o7)[0]), 16) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o8)[0]), 6) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o9)[0]), 18) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o10)[0]), 7) !=0)) {
      return 1;
    }
    if ((codegen_symbuf_bytes_eq(&((buf)[0]), full, &((o11)[0]), 19) !=0)) {
      return 1;
    }
  }
  return num_args;
}
int32_t codegen_name_bytes_prefix_eq(uint8_t * name, int32_t name_len, uint8_t * expect, int32_t exp_len) {
  if ((((name ==0) || (expect ==0)) || (name_len < exp_len))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < exp_len)) {
    if (((name)[i] !=(expect)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_is_std_io_driver_bridge_name(uint8_t * name, int32_t name_len) {
  if ((name ==0)) {
    return 0;
  }
  uint8_t nm8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
  if ((((name_len ==8) || (name_len ==9)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm8)[0]), 8) !=0))) {
    return 1;
  }
  uint8_t nm11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  if ((((name_len ==11) || (name_len ==12)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm11)[0]), 11) !=0))) {
    return 1;
  }
  uint8_t nm12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  if ((((name_len ==12) || (name_len ==13)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm12)[0]), 12) !=0))) {
    return 1;
  }
  uint8_t nm13[13] = {119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101};
  if ((((name_len ==13) || (name_len ==14)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm13)[0]), 13) !=0))) {
    return 1;
  }
  uint8_t nm22[22] = {114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115};
  if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm22)[0]), 22) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_should_skip_emit_std_io_core_io_dup(uint8_t * dep_path, uint8_t * name, int32_t name_len) {
  uint8_t path_core[11] = {115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101};
  uint8_t n_rf[19] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 102, 105, 120, 101, 100};
  uint8_t n_wf[20] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100};
  int32_t di = 0;
  if (((dep_path ==0) || (name ==0))) {
    return 0;
  }
  while ((di < 11)) {
    if (((dep_path)[di] !=(path_core)[di])) {
      return 0;
    }
    (void)((di = (di + 1)));
  }
  if ((((name_len ==18) || (name_len ==19)) && (codegen_name_bytes_prefix_eq(name, name_len, &((n_rf)[0]), 18) !=0))) {
    return 1;
  }
  if ((((name_len ==19) || (name_len ==20)) && (codegen_name_bytes_prefix_eq(name, name_len, &((n_wf)[0]), 19) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_should_skip_emit_std_io_trivial_handle(uint8_t * dep_path, uint8_t * name, int32_t name_len) {
  uint8_t path_io[7] = {115, 116, 100, 46, 105, 111, 0};
  uint8_t h_stdin[12] = {104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 105, 110};
  uint8_t h_stdout[13] = {104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 111, 117, 116};
  uint8_t h_stderr[13] = {104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 101, 114, 114};
  uint8_t h_from_fd[15] = {104, 97, 110, 100, 108, 101, 95, 102, 114, 111, 109, 95, 102, 100, 0};
  int32_t di = 0;
  if ((name ==0)) {
    return 0;
  }
  if ((dep_path !=0)) {
    while ((di < 7)) {
      if (((dep_path)[di] !=(path_io)[di])) {
        return 0;
      }
      (void)((di = (di + 1)));
    }
  }
  if ((((name_len ==12) || (name_len ==13)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_stdin)[0]), 12) !=0))) {
    return 1;
  }
  if ((((name_len ==13) || (name_len ==14)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_stdout)[0]), 13) !=0))) {
    return 1;
  }
  if ((((name_len ==13) || (name_len ==14)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_stderr)[0]), 13) !=0))) {
    return 1;
  }
  if ((((name_len ==15) || (name_len ==16)) && (codegen_name_bytes_prefix_eq(name, name_len, &((h_from_fd)[0]), 15) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_should_skip_later_same_name_body(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi) {
  {
    if (((module ==0) || (fi <=0))) {
      return 0;
    }
    if ((pipeline_module_func_is_extern_at(module, fi) !=0)) {
      return 0;
    }
    int32_t nlen = pipeline_module_func_name_len_at(module, fi);
    if (((nlen <=0) || (nlen > 127))) {
      return 0;
    }
    uint8_t name[128] = {};
    (void)(pipeline_module_func_name_copy64(module, fi, &((name)[0])));
    int32_t np = pipeline_module_func_num_params_at(module, fi);
    int32_t ret_fi = pipeline_module_func_return_type_at(module, fi);
    int32_t j = 0;
    while ((j < fi)) {
      if ((pipeline_module_func_is_extern_at(module, j) ==0)) {
        int32_t jlen = pipeline_module_func_name_len_at(module, j);
        if (((jlen ==nlen) && (pipeline_module_func_num_params_at(module, j) ==np))) {
          uint8_t jname[128] = {};
          (void)(pipeline_module_func_name_copy64(module, j, &((jname)[0])));
          int32_t eq = 1;
          int32_t k = 0;
          while ((k < nlen)) {
            if (((name)[k] !=(jname)[k])) {
              (void)((eq = 0));
            }
            (void)((k = (k + 1)));
          }
          if ((eq !=0)) {
            int32_t pi = 0;
            while ((pi < np)) {
              int32_t ta = pipeline_module_func_param_type_ref_at(module, fi, pi);
              int32_t tb = pipeline_module_func_param_type_ref_at(module, j, pi);
              if ((arena !=0)) {
                if ((pipeline_typeck_type_refs_equal_c(arena, ta, tb) ==0)) {
                  (void)((eq = 0));
                }
              } else {
                if ((ta !=tb)) {
                  (void)((eq = 0));
                }
              }
              (void)((pi = (pi + 1)));
            }
          }
          if ((eq !=0)) {
            int32_t ret_j = pipeline_module_func_return_type_at(module, j);
            if ((arena !=0)) {
              if ((pipeline_typeck_type_refs_equal_c(arena, ret_fi, ret_j) ==0)) {
                (void)((eq = 0));
              }
            } else {
              if ((ret_fi !=ret_j)) {
                (void)((eq = 0));
              }
            }
          }
          if ((eq !=0)) {
            return 1;
          }
        }
      }
      (void)((j = (j + 1)));
    }
    return 0;
  }
}
int32_t codegen_should_skip_emit_func(uint8_t * dep_path, uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  uint8_t full33[33] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110};
  uint8_t full29[29] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114};
  uint8_t path_driver[14] = {115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0};
  uint8_t path_io[7] = {115, 116, 100, 46, 105, 111, 0};
  uint8_t nm_len19[19] = {100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110};
  uint8_t nm_len15[15] = {100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114};
  uint8_t nm_gen19[19] = {100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110};
  int32_t pi = 0;
  int32_t ni = 0;
  int32_t ok_path = 0;
  int32_t di = 0;
  uint8_t full33_gen[33] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110};
  if (((((prefix !=0) && (prefix_len > 0)) && (name !=0)) && (name_len > 0))) {
    int32_t total_len = (prefix_len + name_len);
    if ((total_len ==33)) {
      int32_t match_len = 1;
      int32_t match_gen = 1;
      (void)((pi = 0));
      while ((pi < prefix_len)) {
        if (((prefix)[pi] !=(full33)[pi])) {
          (void)((match_len = 0));
        }
        if (((prefix)[pi] !=(full33_gen)[pi])) {
          (void)((match_gen = 0));
        }
        (void)((pi = (pi + 1)));
      }
      (void)((ni = 0));
      while ((ni < name_len)) {
        if (((name)[ni] !=(full33)[(prefix_len + ni)])) {
          (void)((match_len = 0));
        }
        if (((name)[ni] !=(full33_gen)[(prefix_len + ni)])) {
          (void)((match_gen = 0));
        }
        (void)((ni = (ni + 1)));
      }
      if (((match_len !=0) || (match_gen !=0))) {
        return 1;
      }
    }
    if ((total_len ==29)) {
      (void)((pi = 0));
      while ((pi < prefix_len)) {
        if (((prefix)[pi] !=(full29)[pi])) {
          (void)((pi = (prefix_len + 1)));
          break;
        }
        (void)((pi = (pi + 1)));
      }
      if ((pi ==prefix_len)) {
        (void)((ni = 0));
        while ((ni < name_len)) {
          if (((name)[ni] !=(full29)[(prefix_len + ni)])) {
            (void)((ni = (name_len + 1)));
            break;
          }
          (void)((ni = (ni + 1)));
        }
        if ((ni ==name_len)) {
          return 1;
        }
      }
    }
  }
  if ((dep_path !=0)) {
    (void)((ok_path = 0));
    (void)((di = 0));
    while ((di < 14)) {
      if (((dep_path)[di] !=(path_driver)[di])) {
        (void)((ok_path = 0));
        break;
      }
      (void)((di = (di + 1)));
    }
    if ((di ==14)) {
      (void)((ok_path = 1));
    }
    if ((ok_path ==0)) {
      (void)((di = 0));
      while ((di < 7)) {
        if (((dep_path)[di] !=(path_io)[di])) {
          (void)((ok_path = 0));
          break;
        }
        (void)((di = (di + 1)));
      }
      if ((di ==7)) {
        (void)((ok_path = 1));
      }
    }
    if (((ok_path !=0) && (name !=0))) {
      if ((((name_len ==19) || (name_len ==20)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm_len19)[0]), 19) !=0))) {
        return 1;
      }
      if ((((name_len ==19) || (name_len ==20)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm_gen19)[0]), 19) !=0))) {
        return 1;
      }
      if ((((name_len ==15) || (name_len ==16)) && (codegen_name_bytes_prefix_eq(name, name_len, &((nm_len15)[0]), 15) !=0))) {
        return 1;
      }
    }
  }
  uint8_t pref_abi14[14] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95};
  if (((((prefix !=0) && (prefix_len ==14)) && (name !=0)) && (codegen_name_bytes_prefix_eq(prefix, prefix_len, &((pref_abi14)[0]), 14) !=0))) {
    if ((codegen_is_std_io_driver_bridge_name(name, name_len) !=0)) {
      return 1;
    }
  }
  if (((dep_path !=0) && (name !=0))) {
    int32_t ok_drv_only = 0;
    (void)((di = 0));
    while ((di < 14)) {
      if (((dep_path)[di] !=(path_driver)[di])) {
        (void)((ok_drv_only = 0));
        break;
      }
      (void)((di = (di + 1)));
    }
    if ((di ==14)) {
      (void)((ok_drv_only = 1));
    }
    if (((ok_drv_only !=0) && (codegen_is_std_io_driver_bridge_name(name, name_len) !=0))) {
      return 1;
    }
  }
  if (((((prefix !=0) && (prefix_len ==14)) && (name !=0)) && (codegen_name_bytes_prefix_eq(prefix, prefix_len, &((pref_abi14)[0]), 14) !=0))) {
    if ((codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len) !=0)) {
      return 1;
    }
  }
  if (((dep_path !=0) && (name !=0))) {
    if ((codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len) !=0)) {
      return 1;
    }
    uint8_t path_driver[14] = {115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0};
    int32_t di2 = 0;
    while ((di2 < 14)) {
      if (((dep_path)[di2] !=(path_driver)[di2])) {
        break;
      }
      (void)((di2 = (di2 + 1)));
    }
    if (((di2 ==14) && (codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len) !=0))) {
      return 1;
    }
  }
  return 0;
}
int32_t codegen_force_param_std_io_driver_prefix_ok(uint8_t * prefix, int32_t prefix_len) {
  uint8_t exp13[13] = {115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114};
  if (((prefix ==0) || (prefix_len < 13))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 13)) {
    if (((prefix)[i] !=(exp13)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  if ((prefix_len > 13)) {
    uint8_t b14 = (prefix)[13];
    if (((b14 !=0) && (b14 !=95))) {
      return 0;
    }
  }
  return 1;
}
int32_t codegen_force_param_size_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t rd_batch[21] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  uint8_t wr_batch[22] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  if ((param_index !=0)) {
    return 0;
  }
  if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if (((name_len ==21) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd_batch)[0]), 21) !=0))) {
    return 1;
  }
  if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr_batch)[0]), 22) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_force_param_size_t_std_io_print_str_second(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  if ((param_index !=1)) {
    return 0;
  }
  if (((name ==0) || (name_len !=5))) {
    return 0;
  }
  if (((((((name)[0] !=112) || ((name)[1] !=114)) || ((name)[2] !=105)) || ((name)[3] !=110)) || ((name)[4] !=116))) {
    return 0;
  }
  uint8_t exp7[7] = {115, 116, 100, 95, 105, 111, 95};
  if (((prefix ==0) || (prefix_len < 7))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 7)) {
    if (((prefix)[i] !=(exp7)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t codegen_force_param_ptrdiff_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t reg8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
  uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  if ((param_index !=0)) {
    return 0;
  }
  if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if (((name_len ==8) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg8)[0]), 8) !=0))) {
    return 1;
  }
  if (((name_len ==11) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd11)[0]), 11) !=0))) {
    return 1;
  }
  if (((name_len ==12) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr12)[0]), 12) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_force_param_uint32_t(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  uint8_t reg_fixed_buf[33] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115, 95, 98, 117, 102};
  uint8_t rd_batch[21] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  uint8_t wr_batch[22] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
    return 0;
  }
  if ((name ==0)) {
    return 0;
  }
  if ((param_index ==1)) {
    if (((name_len ==11) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd11)[0]), 11) !=0))) {
      return 1;
    }
    if (((name_len ==12) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr12)[0]), 12) !=0))) {
      return 1;
    }
    if (((name_len ==33) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg_fixed_buf)[0]), 33) !=0))) {
      return 1;
    }
    return 0;
  }
  if ((param_index ==3)) {
    if (((name_len ==21) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd_batch)[0]), 21) !=0))) {
      return 1;
    }
    if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr_batch)[0]), 22) !=0))) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t codegen_use_buf_wrapper(uint8_t * name, int32_t name_len, int32_t num_args) {
  uint8_t reg15[15] = {115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114};
  uint8_t rd18[18] = {115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
  uint8_t wr19[19] = {115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
  if (((name ==0) || (name_len <=0))) {
    return 0;
  }
  if ((((num_args ==1) && (name_len ==15)) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg15)[0]), 15) !=0))) {
    return 1;
  }
  if ((((num_args ==2) && (name_len ==18)) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd18)[0]), 18) !=0))) {
    return 1;
  }
  if ((((num_args ==2) && (name_len ==19)) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr19)[0]), 19) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_emit_io_driver_buf_call_name(struct codegen_CodegenOutBuf * out, uint8_t * name, int32_t name_len, int32_t num_args) {
  {
    uint8_t reg8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
    uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
    uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
    uint8_t sym_reg[21] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102};
    uint8_t sym_rd[24] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102};
    uint8_t sym_wr[25] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102};
    if (((name ==0) || (name_len <=0))) {
      return 0;
    }
    if ((((num_args ==1) && (name_len ==8)) && (codegen_name_bytes_prefix_eq(name, name_len, &((reg8)[0]), 8) !=0))) {
      if ((codegen_emit_bytes_from_ptr(out, &((sym_reg)[0]), 21) !=0)) {
        return -1;
      }
      return 1;
    }
    if ((((num_args ==2) && (name_len ==11)) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd11)[0]), 11) !=0))) {
      if ((codegen_emit_bytes_from_ptr(out, &((sym_rd)[0]), 24) !=0)) {
        return -1;
      }
      return 1;
    }
    if ((((num_args ==2) && (name_len ==12)) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr12)[0]), 12) !=0))) {
      if ((codegen_emit_bytes_from_ptr(out, &((sym_wr)[0]), 25) !=0)) {
        return -1;
      }
      return 1;
    }
    return 0;
  }
}
int32_t codegen_try_emit_std_io_driver_buf_body(struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len) {
  {
    uint8_t fn_local[128] = {};
    int32_t fn_len = 0;
    int32_t nparams = 0;
    uint8_t p0[128] = {};
    uint8_t p1[128] = {};
    uint8_t reg8[8] = {114, 101, 103, 105, 115, 116, 101, 114};
    uint8_t rd11[11] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100};
    uint8_t wr12[12] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101};
    uint8_t sym_reg[21] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102};
    uint8_t sym_rd[24] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102};
    uint8_t sym_wr[25] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102};
    uint8_t ret_kw[8] = {32, 32, 114, 101, 116, 117, 114, 110};
    uint8_t close_b[3] = {10, 125, 0};
    if ((codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) ==0)) {
      return 0;
    }
    int32_t p0_len = 3;
    int32_t p1_len = 10;
    (void)(((p0)[0] = 98));
    (void)(((p0)[1] = 117));
    (void)(((p0)[2] = 102));
    (void)(((p1)[0] = 116));
    (void)(((p1)[1] = 105));
    (void)(((p1)[2] = 109));
    (void)(((p1)[3] = 101));
    (void)(((p1)[4] = 111));
    (void)(((p1)[5] = 117));
    (void)(((p1)[6] = 116));
    (void)(((p1)[7] = 95));
    (void)(((p1)[8] = 109));
    (void)(((p1)[9] = 115));
    (void)(pipeline_module_func_name_copy64(module, fi, &((fn_local)[0])));
    (void)((fn_len = pipeline_module_func_name_len_at(module, fi)));
    (void)((nparams = pipeline_module_func_num_params_at(module, fi)));
    if ((pipeline_module_func_param_name_len_at(module, fi, 0) > 0)) {
      (void)(pipeline_module_func_param_name_copy32(module, fi, 0, &((p0)[0])));
      (void)((p0_len = pipeline_module_func_param_name_len_at(module, fi, 0)));
    }
    if (((nparams > 1) && (pipeline_module_func_param_name_len_at(module, fi, 1) > 0))) {
      (void)(pipeline_module_func_param_name_copy32(module, fi, 1, &((p1)[0])));
      (void)((p1_len = pipeline_module_func_param_name_len_at(module, fi, 1)));
    }
    if ((((fn_len ==8) && (codegen_name_bytes_prefix_eq(&((fn_local)[0]), fn_len, &((reg8)[0]), 8) !=0)) && (nparams ==1))) {
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 8) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sym_reg)[0]), 21) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p0)[0]), p0_len) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 59) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close_b)[0]), 2) !=0)) {
        return -1;
      }
      return 1;
    }
    if ((((fn_len ==11) && (codegen_name_bytes_prefix_eq(&((fn_local)[0]), fn_len, &((rd11)[0]), 11) !=0)) && (nparams ==2))) {
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 8) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sym_rd)[0]), 24) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p0)[0]), p0_len) !=0)) {
        return -1;
      }
      uint8_t comma[3] = {44, 32, 0};
      if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p1)[0]), p1_len) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 59) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close_b)[0]), 2) !=0)) {
        return -1;
      }
      return 1;
    }
    if ((((fn_len ==12) && (codegen_name_bytes_prefix_eq(&((fn_local)[0]), fn_len, &((wr12)[0]), 12) !=0)) && (nparams ==2))) {
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 8) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sym_wr)[0]), 25) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p0)[0]), p0_len) !=0)) {
        return -1;
      }
      uint8_t comma2[3] = {44, 32, 0};
      if ((codegen_emit_bytes_3(out, &((comma2)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((p1)[0]), p1_len) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 59) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close_b)[0]), 2) !=0)) {
        return -1;
      }
      return 1;
    }
    return 0;
  }
}
int32_t codegen_field_access_base_is_pointer_ref(struct ast_ASTArena * arena, int32_t base_ref) {
  if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > ((arena)->num_exprs)))) {
    return 0;
  }
  struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
  if (((ast_ref_is_null(((base).resolved_type_ref)) || (((base).resolved_type_ref) <=0)) || (((base).resolved_type_ref) > ((arena)->num_types)))) {
    return 0;
  }
  struct ast_Type ty = ast_ast_arena_type_get(arena, ((base).resolved_type_ref));
  if ((((int32_t)(((ty).kind))) ==9)) {
    return 1;
  }
  return 0;
}
int32_t codegen_field_access_base_type_resolved(struct ast_ASTArena * arena, int32_t base_ref) {
  if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > ((arena)->num_exprs)))) {
    return 0;
  }
  struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
  if (((ast_ref_is_null(((base).resolved_type_ref)) || (((base).resolved_type_ref) <=0)) || (((base).resolved_type_ref) > ((arena)->num_types)))) {
    return 0;
  }
  return 1;
}
int32_t codegen_try_emit_fmt_string_lit_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t callee_ref = 0;
    struct ast_Expr callee = e;
    uint8_t path[128] = {};
    int32_t path_len = 0;
    uint8_t pre[128] = {};
    int32_t pre_len = 0;
    uint8_t * name_ptr = 0;
    int32_t name_len = 0;
    int32_t arg_ref = 0;
    struct ast_Expr arg = e;
    int32_t slen = 0;
    uint8_t mid[12] = {95, 117, 56, 95, 112, 116, 114, 95, 105, 51, 50, 0};
    uint8_t comma[3] = {44, 32, 0};
    int32_t is_method = 0;
    if ((((arena ==0) || (out ==0)) || (ctx ==0))) {
      return 0;
    }
    if (((expr_ref <=0) || (expr_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    (void)((e = ast_ast_arena_expr_get(arena, expr_ref)));
    if ((((((int32_t)(((e).kind))) ==49) && (((e).method_call_num_args) ==1)) && (((e).method_call_name_len) > 0))) {
      (void)((is_method = 1));
      (void)((name_len = ((e).method_call_name_len)));
      (void)((name_ptr = &((((e).method_call_name))[0])));
      (void)((path_len = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &((path)[0]))));
      (void)((arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0)));
    } else {
      if (((((int32_t)(((e).kind))) ==48) && (((e).call_num_args) ==1))) {
        (void)((callee_ref = ((e).call_callee_ref)));
        if (((callee_ref <=0) || (callee_ref > ((arena)->num_exprs)))) {
          return 0;
        }
        (void)((callee = ast_ast_arena_expr_get(arena, callee_ref)));
        if (((((int32_t)(((callee).kind))) !=44) || (((callee).field_access_field_len) <=0))) {
          return 0;
        }
        (void)((name_len = ((callee).field_access_field_len)));
        (void)((name_ptr = &((((callee).field_access_field_name))[0])));
        (void)((path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, callee_ref, &((path)[0]))));
        (void)((arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, 0)));
      } else {
        return 0;
      }
    }
    if (((((((((name_len ==7) && ((name_ptr)[0] ==112)) && ((name_ptr)[1] ==114)) && ((name_ptr)[2] ==105)) && ((name_ptr)[3] ==110)) && ((name_ptr)[4] ==116)) && ((name_ptr)[5] ==108)) && ((name_ptr)[6] ==110))) {
    } else {
      if (((((((name_len ==5) && ((name_ptr)[0] ==112)) && ((name_ptr)[1] ==114)) && ((name_ptr)[2] ==105)) && ((name_ptr)[3] ==110)) && ((name_ptr)[4] ==116))) {
      } else {
        return 0;
      }
    }
    if ((path_len <=0)) {
      return 0;
    }
    if (((((((((path_len ==7) && ((path)[0] ==115)) && ((path)[1] ==116)) && ((path)[2] ==100)) && ((path)[3] ==46)) && ((path)[4] ==102)) && ((path)[5] ==109)) && ((path)[6] ==116))) {
    } else {
      if (((((((((((path_len ==9) && ((path)[0] ==115)) && ((path)[1] ==116)) && ((path)[2] ==100)) && ((path)[3] ==46)) && ((path)[4] ==100)) && ((path)[5] ==101)) && ((path)[6] ==98)) && ((path)[7] ==117)) && ((path)[8] ==103))) {
      } else {
        return 0;
      }
    }
    if (((arg_ref <=0) || (arg_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, arg_ref) !=59)) {
      return 0;
    }
    (void)((arg = ast_ast_arena_expr_get(arena, arg_ref)));
    (void)((slen = ((arg).var_name_len)));
    if ((slen < 0)) {
      (void)((slen = 0));
    }
    if ((slen > 64)) {
      (void)((slen = 64));
    }
    (void)(codegen_import_path_to_c_prefix_into(&((path)[0]), &((pre)[0]), 128));
    (void)((pre_len = 0));
    while (((pre_len < 128) && ((pre)[pre_len] !=0))) {
      (void)((pre_len = (pre_len + 1)));
    }
    if ((pre_len <=0)) {
      return 0;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((pre)[0]), pre_len) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, name_ptr, name_len) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, &((mid)[0]), 11) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -1;
    }
    if ((codegen_emit_expr(arena, out, arg_ref, ctx) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
      return -1;
    }
    if ((codegen_format_int(out, ((int64_t)(slen))) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 41) !=0)) {
      return -1;
    }
    return 1;
  }
}
int32_t codegen_try_emit_size_align_of_call(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t callee_ref = 0;
    struct ast_Expr callee = e;
    uint8_t * name_ptr = 0;
    int32_t name_len = 0;
    int32_t is_size = 0;
    int32_t is_align = 0;
    int32_t n_ta = 0;
    int32_t ta = 0;
    uint8_t open_sz[18] = {40, 40, 105, 110, 116, 51, 50, 95, 116, 41, 40, 115, 105, 122, 101, 111, 102, 40};
    uint8_t open_al[20] = {40, 40, 105, 110, 116, 51, 50, 95, 116, 41, 40, 95, 65, 108, 105, 103, 110, 111, 102, 40};
    uint8_t close3[4] = {41, 41, 41, 0};
    if ((((arena ==0) || (out ==0)) || (ctx ==0))) {
      return 0;
    }
    if (((expr_ref <=0) || (expr_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    (void)((e = ast_ast_arena_expr_get(arena, expr_ref)));
    if (((((int32_t)(((e).kind))) !=48) || (((e).call_num_args) !=0))) {
      return 0;
    }
    (void)((n_ta = pipeline_expr_call_num_type_args_at(arena, expr_ref)));
    if ((n_ta < 1)) {
      return 0;
    }
    (void)((callee_ref = ((e).call_callee_ref)));
    if (((callee_ref <=0) || (callee_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    (void)((callee = ast_ast_arena_expr_get(arena, callee_ref)));
    if (((((int32_t)(((callee).kind))) ==44) && (((callee).field_access_field_len) > 0))) {
      (void)((name_ptr = &((((callee).field_access_field_name))[0])));
      (void)((name_len = ((callee).field_access_field_len)));
    } else {
      if (((((int32_t)(((callee).kind))) ==3) && (((callee).var_name_len) > 0))) {
        (void)((name_ptr = &((((callee).var_name))[0])));
        (void)((name_len = ((callee).var_name_len)));
      } else {
        return 0;
      }
    }
    if (((((((((name_len ==7) && ((name_ptr)[0] ==115)) && ((name_ptr)[1] ==105)) && ((name_ptr)[2] ==122)) && ((name_ptr)[3] ==101)) && ((name_ptr)[4] ==95)) && ((name_ptr)[5] ==111)) && ((name_ptr)[6] ==102))) {
      (void)((is_size = 1));
    } else {
      if ((((((((((name_len ==8) && ((name_ptr)[0] ==97)) && ((name_ptr)[1] ==108)) && ((name_ptr)[2] ==105)) && ((name_ptr)[3] ==103)) && ((name_ptr)[4] ==110)) && ((name_ptr)[5] ==95)) && ((name_ptr)[6] ==111)) && ((name_ptr)[7] ==102))) {
        (void)((is_align = 1));
      } else {
        return 0;
      }
    }
    (void)((ta = pipeline_expr_call_type_arg_ref_at(arena, expr_ref, 0)));
    if ((ta <=0)) {
      return 0;
    }
    if ((is_size !=0)) {
      if ((codegen_emit_bytes_from_ptr(out, &((open_sz)[0]), 18) !=0)) {
        return -1;
      }
    } else {
      if ((is_align !=0)) {
        if ((codegen_emit_bytes_from_ptr(out, &((open_al)[0]), 20) !=0)) {
          return -1;
        }
      } else {
        return 0;
      }
    }
    if ((pipeline_type_kind_ord_at(arena, ta) ==10)) {
      if ((codegen_emit_local_fixed_array_elem_type(arena, out, ta, ctx) !=0)) {
        return -1;
      }
      if ((codegen_emit_local_fixed_array_suffix(arena, out, ta) !=0)) {
        return -1;
      }
    } else {
      if ((codegen_emit_type(arena, out, ta, 0, 0, ctx) !=0)) {
        return -1;
      }
    }
    if ((codegen_emit_bytes_from_ptr(out, &((close3)[0]), 3) !=0)) {
      return -1;
    }
    return 1;
  }
}
extern void codegen_set_host_call_arg_param_ty(int32_t param_ty_ref);
extern int32_t codegen_get_host_call_arg_param_ty(void);
extern int32_t codegen_next_host_call_array_tmp_id(void);
extern int32_t codegen_emit_slice_let_reent_finish(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t indent, uint8_t * name, int32_t name_len, int32_t let_type_ref, int32_t linit_ref, struct ast_PipelineDepCtx * ctx);
int32_t codegen_emit_call_arg_slice_abi(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t arg_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if (ast_ref_is_null(arg_ref)) {
      return codegen_append_byte(out, 48);
    }
    struct ast_Expr arg = ast_ast_arena_expr_get(arena, arg_ref);
    if ((((int32_t)(((arg).kind))) ==51)) {
      return codegen_emit_expr(arena, out, arg_ref, ctx);
    }
    if ((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_func_index) >=0))) {
      if ((codegen_field_access_base_is_pointer_param(arena, arg_ref, ((ctx)->current_codegen_module), ((ctx)->current_func_index)) !=0)) {
        int32_t is_slice_param = 0;
        struct ast_Expr base = arg;
        if (((((int32_t)(((base).kind))) ==3) && (((base).var_name_len) > 0))) {
          struct ast_Module * mod = ((ctx)->current_codegen_module);
          int32_t fi = ((ctx)->current_func_index);
          int32_t np = pipeline_module_func_num_params_at(mod, fi);
          int32_t pi = 0;
          while ((pi < np)) {
            int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, fi, pi);
            if (((p_name_len > 0) && (p_name_len ==((base).var_name_len)))) {
              uint8_t pname_buf[128] = {};
              (void)(pipeline_module_func_param_name_copy32(mod, fi, pi, &((pname_buf)[0])));
              int matched = 1;
              int32_t j = 0;
              while (((j < p_name_len) && (j < 32))) {
                if (((pname_buf)[j] !=(((base).var_name))[j])) {
                  (void)((matched = 0));
                  break;
                }
                (void)((j = (j + 1)));
              }
              if (matched) {
                int32_t param_ty_ref = pipeline_module_func_param_type_ref_at(mod, fi, pi);
                if ((pipeline_type_kind_ord_at(arena, param_ty_ref) ==11)) {
                  (void)((is_slice_param = 1));
                }
              }
            }
            (void)((pi = (pi + 1)));
          }
        }
        if ((is_slice_param !=0)) {
          return codegen_emit_expr(arena, out, arg_ref, ctx);
        }
      }
    }
    (void)(({   int32_t arr_sz = 0;
  int32_t arr_tr = 0;
  int32_t elem_tr = 0;
  int32_t is_arr_rvalue = 0;
  if (((((int32_t)(((arg).kind))) ==3) && (((arg).var_name_len) > 0))) {
    (void)((is_arr_rvalue = 1));
  } else {
    if ((((((int32_t)(((arg).kind))) ==48) || (((int32_t)(((arg).kind))) ==49)) || (((int32_t)(((arg).kind))) ==44))) {
      (void)((is_arr_rvalue = 1));
    }
  }
  if ((is_arr_rvalue !=0)) {
    if (((!(ast_ref_is_null(((arg).resolved_type_ref))) && (((arg).resolved_type_ref) > 0)) && (((arg).resolved_type_ref) <=((arena)->num_types)))) {
      if ((pipeline_type_kind_ord_at(arena, ((arg).resolved_type_ref)) ==10)) {
        (void)((arr_tr = ((arg).resolved_type_ref)));
        (void)((arr_sz = pipeline_type_array_size_at(arena, arr_tr)));
      }
    }
    if (((((arr_sz <=0) && (((int32_t)(((arg).kind))) ==3)) && (((arg).var_name_len) > 0)) && (ctx !=0))) {
      int32_t br = 0;
      if (((((ctx)->current_codegen_module) !=0) && (((ctx)->current_func_index) >=0))) {
        (void)((br = pipeline_module_func_body_ref_at(((ctx)->current_codegen_module), ((ctx)->current_func_index))));
      }
      if (((ast_ref_is_null(br) || (br <=0)) || (br > ((arena)->num_blocks)))) {
        (void)((br = ((ctx)->current_block_ref)));
      }
      if (((!(ast_ref_is_null(br)) && (br > 0)) && (br <=((arena)->num_blocks)))) {
        int32_t nlets = ast_ast_block_num_lets(arena, br);
        int32_t li = 0;
        while ((li < nlets)) {
          int32_t nl = pipeline_block_let_name_len(arena, br, li);
          if (((nl ==((arg).var_name_len)) && (nl > 0))) {
            uint8_t nb[128] = {};
            (void)(pipeline_block_let_name_copy64(arena, br, li, &((nb)[0])));
            int eq = 1;
            int32_t j2 = 0;
            while (((j2 < nl) && (j2 < 64))) {
              if (((nb)[j2] !=(((arg).var_name))[j2])) {
                (void)((eq = 0));
                break;
              }
              (void)((j2 = (j2 + 1)));
            }
            if (eq) {
              int32_t tr = pipeline_block_let_type_ref(arena, br, li);
              if ((pipeline_type_kind_ord_at(arena, tr) ==10)) {
                (void)((arr_tr = tr));
                (void)((arr_sz = pipeline_type_array_size_at(arena, tr)));
              }
            }
          }
          (void)((li = (li + 1)));
        }
      }
    }
    if ((arr_sz > 0)) {
      int32_t formal_ty = codegen_get_host_call_arg_param_ty();
      if (((formal_ty <=0) || (pipeline_type_kind_ord_at(arena, formal_ty) !=11))) {
        return codegen_emit_expr(arena, out, arg_ref, ctx);
      }
      uint8_t open[4] = {38, 40, 40, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((open)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_type(arena, out, formal_ty, 0, 0, ctx) !=0)) {
        uint8_t fb[28] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((fb)[0]), 26) !=0)) {
          return -1;
        }
      }
      uint8_t mid1[14] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((mid1)[0]), 11) !=0)) {
        return -1;
      }
      if (((((int32_t)(((arg).kind))) ==3) && (((arg).var_name_len) > 0))) {
        if ((codegen_emit_bytes_64(out, &((((arg).var_name))[0]), ((arg).var_name_len)) !=0)) {
          return -1;
        }
      } else {
        if (((((int32_t)(((arg).kind))) ==48) || (((int32_t)(((arg).kind))) ==49))) {
          int32_t tid = codegen_next_host_call_array_tmp_id();
          uint8_t ca_open[12] = {40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ca_open)[0]), 10) !=0)) {
            return -1;
          }
          if (((ast_ref_is_null(elem_tr) || (elem_tr <=0)) || (codegen_emit_type(arena, out, elem_tr, 0, 0, ctx) !=0))) {
            uint8_t fb_e[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((fb_e)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t ca_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 99, 97, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ca_nm)[0]), 11) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 91) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ((int64_t)(arr_sz))) !=0)) {
            return -1;
          }
          uint8_t ca_sz_end[4] = {93, 59, 32, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ca_sz_end)[0]), 3) !=0)) {
            return -1;
          }
          if (((ast_ref_is_null(elem_tr) || (elem_tr <=0)) || (codegen_emit_type(arena, out, elem_tr, 0, 0, ctx) !=0))) {
            uint8_t fb_rp[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((fb_rp)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t rp_asg[16] = {32, 42, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 32, 61, 32, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((rp_asg)[0]), 15) !=0)) {
            return -1;
          }
          if ((codegen_emit_expr(arena, out, arg_ref, ctx) !=0)) {
            return -1;
          }
          uint8_t rp_sc[4] = {59, 32, 0, 0};
          if ((codegen_emit_bytes_4(out, &((rp_sc)[0]), 2) !=0)) {
            return -1;
          }
          int32_t ai_ca = 0;
          while ((ai_ca < arr_sz)) {
            uint8_t ca_asg[14] = {95, 95, 120, 108, 97, 110, 103, 95, 99, 97, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((ca_asg)[0]), 10) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 91) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, ((int64_t)(ai_ca))) !=0)) {
              return -1;
            }
            uint8_t ca_mid[16] = {93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 91, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((ca_mid)[0]), 15) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, ((int64_t)(ai_ca))) !=0)) {
              return -1;
            }
            uint8_t ca_el_end[4] = {93, 59, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((ca_el_end)[0]), 3) !=0)) {
              return -1;
            }
            (void)((ai_ca = (ai_ca + 1)));
          }
          uint8_t ca_ret[14] = {95, 95, 120, 108, 97, 110, 103, 95, 99, 97, 0, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ca_ret)[0]), 10) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
            return -1;
          }
          uint8_t ca_close[6] = {59, 32, 125, 41, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ca_close)[0]), 4) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_emit_expr(arena, out, arg_ref, ctx) !=0)) {
            return -1;
          }
        }
      }
      uint8_t mid2[14] = {44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((mid2)[0]), 12) !=0)) {
        return -1;
      }
      if ((codegen_format_int(out, ((int64_t)(arr_sz))) !=0)) {
        return -1;
      }
      uint8_t close[4] = {32, 125, 41, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((close)[0]), 3) !=0)) {
        return -1;
      }
      return 0;
    }
  }
 }));
    int32_t need_addr = 0;
    if (((!(ast_ref_is_null(((arg).resolved_type_ref))) && (((arg).resolved_type_ref) > 0)) && (((arg).resolved_type_ref) <=((arena)->num_types)))) {
      struct ast_Type aty = ast_ast_arena_type_get(arena, ((arg).resolved_type_ref));
      if ((((int32_t)(((aty).kind))) ==11)) {
        (void)((need_addr = 1));
      }
    }
    if ((((need_addr ==0) && (((int32_t)(((arg).kind))) ==3)) && (ctx !=0))) {
      if ((codegen_field_access_base_is_pointer_local(arena, arg_ref, ctx) ==0)) {
        int32_t br = 0;
        if (((((ctx)->current_codegen_module) !=0) && (((ctx)->current_func_index) >=0))) {
          (void)((br = pipeline_module_func_body_ref_at(((ctx)->current_codegen_module), ((ctx)->current_func_index))));
        }
        if (((ast_ref_is_null(br) || (br <=0)) || (br > ((arena)->num_blocks)))) {
          (void)((br = ((ctx)->current_block_ref)));
        }
        if (((!(ast_ref_is_null(br)) && (br > 0)) && (br <=((arena)->num_blocks)))) {
          int32_t nlets = ast_ast_block_num_lets(arena, br);
          int32_t li = 0;
          while ((li < nlets)) {
            int32_t nl = pipeline_block_let_name_len(arena, br, li);
            if (((nl ==((arg).var_name_len)) && (nl > 0))) {
              uint8_t nb[128] = {};
              (void)(pipeline_block_let_name_copy64(arena, br, li, &((nb)[0])));
              int eq = 1;
              int32_t j2 = 0;
              while (((j2 < nl) && (j2 < 64))) {
                if (((nb)[j2] !=(((arg).var_name))[j2])) {
                  (void)((eq = 0));
                  break;
                }
                (void)((j2 = (j2 + 1)));
              }
              if (eq) {
                int32_t tr = pipeline_block_let_type_ref(arena, br, li);
                if ((pipeline_type_kind_ord_at(arena, tr) ==11)) {
                  (void)((need_addr = 1));
                }
              }
            }
            (void)((li = (li + 1)));
          }
        }
      }
    }
    if ((need_addr !=0)) {
      if (((((int32_t)(((arg).kind))) ==48) || (((int32_t)(((arg).kind))) ==49))) {
        int32_t ty_ref = ((arg).resolved_type_ref);
        int32_t tid = codegen_next_host_call_array_tmp_id();
        int32_t elem_tr = 0;
        if (((!(ast_ref_is_null(ty_ref)) && (ty_ref > 0)) && (ty_ref <=((arena)->num_types)))) {
          (void)((elem_tr = pipeline_type_elem_ref_at(arena, ty_ref)));
        }
        uint8_t open_stmt[12] = {40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((open_stmt)[0]), 10) !=0)) {
          return -1;
        }
        if (((!(ast_ref_is_null(ty_ref)) && (ty_ref > 0)) && (ty_ref <=((arena)->num_types)))) {
          if ((codegen_emit_type(arena, out, ty_ref, 0, 0, ctx) !=0)) {
            return -1;
          }
        } else {
          uint8_t fb[32] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((fb)[0]), 26) !=0)) {
            return -1;
          }
        }
        uint8_t sp_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sp_nm)[0]), 11) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t st2[10] = {59, 32, 115, 116, 97, 116, 105, 99, 32, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((st2)[0]), 9) !=0)) {
          return -1;
        }
        if (((ast_ref_is_null(elem_tr) || (elem_tr <=0)) || (codegen_emit_type(arena, out, elem_tr, 0, 0, ctx) !=0))) {
          uint8_t fb_e[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((fb_e)[0]), 7) !=0)) {
            return -1;
          }
        }
        uint8_t sd_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 100, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sd_nm)[0]), 11) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t sd_mid[28] = {91, 49, 48, 50, 52, 93, 59, 32, 115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sd_mid)[0]), 25) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t si_decl[24] = {59, 32, 115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((si_decl)[0]), 19) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t sp_asg[14] = {59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sp_asg)[0]), 12) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t eq_sp[4] = {32, 61, 32, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((eq_sp)[0]), 3) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, arg_ref, ctx) !=0)) {
          return -1;
        }
        uint8_t sn_asg[14] = {59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sn_asg)[0]), 12) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t sn_eq[14] = {32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sn_eq)[0]), 13) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t sn_len[28] = {46, 108, 101, 110, 103, 116, 104, 59, 32, 105, 102, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sn_len)[0]), 23) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t sn_cap[20] = {32, 62, 32, 49, 48, 50, 52, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sn_cap)[0]), 19) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t for_open[28] = {32, 61, 32, 49, 48, 50, 52, 59, 32, 102, 111, 114, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((for_open)[0]), 24) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t for_mid1[16] = {32, 61, 32, 48, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105};
        if ((codegen_emit_bytes_from_ptr(out, &((for_mid1)[0]), 16) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t for_mid2[16] = {32, 60, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((for_mid2)[0]), 13) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t for_mid3[14] = {59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((for_mid3)[0]), 12) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t for_body[16] = {43, 43, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 100, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((for_body)[0]), 14) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t idx_open[14] = {91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((idx_open)[0]), 11) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t copy_mid[16] = {93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((copy_mid)[0]), 14) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t data_idx[20] = {46, 100, 97, 116, 97, 91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((data_idx)[0]), 16) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t after_copy[16] = {93, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((after_copy)[0]), 13) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t data_asg[20] = {46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 100, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((data_asg)[0]), 18) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t len_asg[14] = {59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((len_asg)[0]), 12) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t len_eq[24] = {46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((len_eq)[0]), 20) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t end_sp[16] = {59, 32, 38, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((end_sp)[0]), 13) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ((int64_t)(tid))) !=0)) {
          return -1;
        }
        uint8_t close_sp[6] = {59, 32, 125, 41, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((close_sp)[0]), 4) !=0)) {
          return -1;
        }
        return 0;
      }
      if ((((int32_t)(((arg).kind))) ==46)) {
        int32_t ty_ref = ((arg).resolved_type_ref);
        uint8_t open_stmt[12] = {40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((open_stmt)[0]), 10) !=0)) {
          return -1;
        }
        if (((!(ast_ref_is_null(ty_ref)) && (ty_ref > 0)) && (ty_ref <=((arena)->num_types)))) {
          if ((codegen_emit_type(arena, out, ty_ref, 0, 0, ctx) !=0)) {
            return -1;
          }
        } else {
          uint8_t fb[32] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((fb)[0]), 26) !=0)) {
            return -1;
          }
        }
        uint8_t sp_decl[28] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 32, 61, 32, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((sp_decl)[0]), 26) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, arg_ref, ctx) !=0)) {
          return -1;
        }
        uint8_t end_sp[20] = {59, 32, 38, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 59, 32, 125, 41, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((end_sp)[0]), 17) !=0)) {
          return -1;
        }
        return 0;
      }
      uint8_t pre[3] = {38, 40, 0};
      if ((codegen_emit_bytes_3(out, &((pre)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, arg_ref, ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    return codegen_emit_expr(arena, out, arg_ref, ctx);
  }
}
int32_t codegen_field_access_base_is_pointer_param(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index) {
  {
    if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    if ((((mod ==0) || (func_index < 0)) || (func_index >=((mod)->num_funcs)))) {
      return 0;
    }
    struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
    if (((((int32_t)(((base).kind))) !=3) || (((base).var_name_len) <=0))) {
      return 0;
    }
    int32_t np = pipeline_module_func_num_params_at(mod, func_index);
    int32_t pi = 0;
    while ((pi < np)) {
      int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (((p_name_len > 0) && (p_name_len ==((base).var_name_len)))) {
        uint8_t pname_buf[128] = {};
        (void)(pipeline_module_func_param_name_copy32(mod, func_index, pi, &((pname_buf)[0])));
        int matched = 1;
        int32_t j = 0;
        while (((j < p_name_len) && (j < 32))) {
          if (((pname_buf)[j] !=(((base).var_name))[j])) {
            (void)((matched = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (matched) {
          int32_t param_ty_ref = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (((!(ast_ref_is_null(param_ty_ref)) && (param_ty_ref > 0)) && (param_ty_ref <=((arena)->num_types)))) {
            struct ast_Type pty = ast_ast_arena_type_get(arena, param_ty_ref);
            if (((((int32_t)(((pty).kind))) ==9) || (((int32_t)(((pty).kind))) ==11))) {
              return 1;
            }
          }
        }
      }
      (void)((pi = (pi + 1)));
    }
    return 0;
  }
}
int32_t codegen_field_access_base_is_pointer_local(struct ast_ASTArena * arena, int32_t base_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if (((arena ==0) || (ctx ==0))) {
      return 0;
    }
    if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
    if (((((int32_t)(((base).kind))) !=3) || (((base).var_name_len) <=0))) {
      return 0;
    }
    int32_t br = 0;
    if (((((ctx)->current_codegen_module) !=0) && (((ctx)->current_func_index) >=0))) {
      (void)((br = pipeline_module_func_body_ref_at(((ctx)->current_codegen_module), ((ctx)->current_func_index))));
    }
    if (((ast_ref_is_null(br) || (br <=0)) || (br > ((arena)->num_blocks)))) {
      (void)((br = ((ctx)->current_block_ref)));
    }
    if (((ast_ref_is_null(br) || (br <=0)) || (br > ((arena)->num_blocks)))) {
      return 0;
    }
    int32_t nlets = ast_ast_block_num_lets(arena, br);
    int32_t li = 0;
    while ((li < nlets)) {
      int32_t nl = pipeline_block_let_name_len(arena, br, li);
      if (((nl ==((base).var_name_len)) && (nl > 0))) {
        uint8_t nb[128] = {};
        (void)(pipeline_block_let_name_copy64(arena, br, li, &((nb)[0])));
        int eq = 1;
        int32_t j = 0;
        while (((j < nl) && (j < 64))) {
          if (((nb)[j] !=(((base).var_name))[j])) {
            (void)((eq = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (eq) {
          int32_t tr = pipeline_block_let_type_ref(arena, br, li);
          if (((!(ast_ref_is_null(tr)) && (tr > 0)) && (tr <=((arena)->num_types)))) {
            struct ast_Type lty = ast_ast_arena_type_get(arena, tr);
            if ((((int32_t)(((lty).kind))) ==9)) {
              return 1;
            }
          }
        }
      }
      (void)((li = (li + 1)));
    }
    return 0;
  }
}
int32_t codegen_field_access_base_param_type_known(struct ast_ASTArena * arena, int32_t base_ref, struct ast_Module * mod, int32_t func_index) {
  {
    if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    if ((((mod ==0) || (func_index < 0)) || (func_index >=((mod)->num_funcs)))) {
      return 0;
    }
    struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
    if (((((int32_t)(((base).kind))) !=3) || (((base).var_name_len) <=0))) {
      return 0;
    }
    int32_t np = pipeline_module_func_num_params_at(mod, func_index);
    int32_t pi = 0;
    while ((pi < np)) {
      int32_t p_name_len = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (((p_name_len > 0) && (p_name_len ==((base).var_name_len)))) {
        uint8_t pname_buf[128] = {};
        (void)(pipeline_module_func_param_name_copy32(mod, func_index, pi, &((pname_buf)[0])));
        int matched = 1;
        int32_t j = 0;
        while (((j < p_name_len) && (j < 32))) {
          if (((pname_buf)[j] !=(((base).var_name))[j])) {
            (void)((matched = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (matched) {
          int32_t param_ty_ref = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (((!(ast_ref_is_null(param_ty_ref)) && (param_ty_ref > 0)) && (param_ty_ref <=((arena)->num_types)))) {
            return 1;
          }
        }
      }
      (void)((pi = (pi + 1)));
    }
    return 0;
  }
}
int32_t codegen_field_access_base_is_slice_param_name(struct ast_ASTArena * arena, int32_t base_ref) {
  if (((ast_ref_is_null(base_ref) || (base_ref <=0)) || (base_ref > ((arena)->num_exprs)))) {
    return 0;
  }
  struct ast_Expr base = ast_ast_arena_expr_get(arena, base_ref);
  if (((((int32_t)(((base).kind))) !=3) || (((base).var_name_len) <=0))) {
    return 0;
  }
  if ((((base).var_name_len) ==6)) {
    if ((((((((((base).var_name))[0] ==115) && ((((base).var_name))[1] ==111)) && ((((base).var_name))[2] ==117)) && ((((base).var_name))[3] ==114)) && ((((base).var_name))[4] ==99)) && ((((base).var_name))[5] ==101))) {
      return 1;
    }
  }
  if ((((base).var_name_len) ==7)) {
    if (((((((((((base).var_name))[0] ==111) && ((((base).var_name))[1] ==117)) && ((((base).var_name))[2] ==116)) && ((((base).var_name))[3] ==95)) && ((((base).var_name))[4] ==98)) && ((((base).var_name))[5] ==117)) && ((((base).var_name))[6] ==102))) {
      return 1;
    }
  }
  if ((((((((((base).var_name_len) ==6) && ((((base).var_name))[0] ==109)) && ((((base).var_name))[1] ==111)) && ((((base).var_name))[2] ==100)) && ((((base).var_name))[3] ==117)) && ((((base).var_name))[4] ==108)) && ((((base).var_name))[5] ==101))) {
    return 1;
  }
  if (((((((((base).var_name_len) ==5) && ((((base).var_name))[0] ==97)) && ((((base).var_name))[1] ==114)) && ((((base).var_name))[2] ==101)) && ((((base).var_name))[3] ==110)) && ((((base).var_name))[4] ==97))) {
    return 1;
  }
  if ((((((((((((base).var_name_len) ==8) && ((((base).var_name))[0] ==101)) && ((((base).var_name))[1] ==108)) && ((((base).var_name))[2] ==102)) && ((((base).var_name))[3] ==95)) && ((((base).var_name))[4] ==99)) && ((((base).var_name))[5] ==116)) && ((((base).var_name))[6] ==120)) && ((((base).var_name))[7] ==120))) {
    return 1;
  }
  if (((((((((((base).var_name_len) ==7) && ((((base).var_name))[0] ==99)) && ((((base).var_name))[1] ==117)) && ((((base).var_name))[2] ==114)) && ((((base).var_name))[3] ==95)) && ((((base).var_name))[4] ==109)) && ((((base).var_name))[5] ==111)) && ((((base).var_name))[6] ==100))) {
    return 1;
  }
  if (((((((base).var_name_len) ==3) && ((((base).var_name))[0] ==99)) && ((((base).var_name))[1] ==116)) && ((((base).var_name))[2] ==120))) {
    return 1;
  }
  if (((((((((((base).var_name_len) ==7) && ((((base).var_name))[0] ==99)) && ((((base).var_name))[1] ==117)) && ((((base).var_name))[2] ==114)) && ((((base).var_name))[3] ==95)) && ((((base).var_name))[4] ==109)) && ((((base).var_name))[5] ==111)) && ((((base).var_name))[6] ==100))) {
    return 1;
  }
  return 0;
}
int32_t codegen_block_stmt_order_has_let(struct ast_ASTArena * arena, int32_t block_ref, int32_t let_idx) {
  {
    int32_t nso = ast_ast_block_num_stmt_order(arena, block_ref);
    int32_t si = 0;
    while ((si < nso)) {
      if (((pipeline_block_stmt_order_kind(arena, block_ref, si) ==1) && (pipeline_block_stmt_order_idx(arena, block_ref, si) ==let_idx))) {
        return 1;
      }
      (void)((si = (si + 1)));
    }
    return 0;
  }
}
extern int32_t codegen_collect_generic_struct_mono_combos(struct ast_Module * module, struct ast_ASTArena * arena, int32_t layout_k, uint8_t * layout_nm, int32_t layout_nl, int32_t ntp, int32_t * combos_out, int32_t max_combos);
extern int32_t codegen_emit_generic_struct_mono_suffix(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t * mono_tys, int32_t ntp);
extern int32_t codegen_generic_struct_fill_concrete_args(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref, int32_t ntp, int32_t * mono_out, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_module_struct_layout_index_by_name(struct ast_Module * module, uint8_t * layout_nm, int32_t layout_nl);
extern int32_t codegen_type_ref_is_host_concrete(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty);
extern int32_t codegen_type_refs_same_for_mono(struct ast_ASTArena * arena, int32_t a, int32_t b);
extern int32_t codegen_try_emit_impl_method_mono_call_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, struct ast_Module * module, int32_t fi, int32_t receiver_ty);
extern int32_t codegen_emit_local_fixed_array_elem_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_emit_local_fixed_array_suffix(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref);
extern int32_t codegen_func_ret_type_param_extra(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi);
extern int32_t codegen_collect_mono_combos_for_generic_func(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t * combos_out, int32_t max_combos, int32_t num_params, int32_t ret_extra);
extern int32_t codegen_call_mono_type_at(struct ast_ASTArena * arena, int32_t ei, int32_t arg_idx, int32_t num_args);
extern int32_t codegen_call_ret_type_param_concrete_at(struct ast_ASTArena * arena, int32_t ei);
extern int32_t codegen_emit_mono_mangled_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t * mono_tys, int32_t num_mono);
extern void pipeline_expr_var_name_into(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * out);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module * module, int32_t func_index, uint8_t * name, int32_t name_len);
int32_t codegen_append_byte(struct codegen_CodegenOutBuf * out, int32_t b) {
  if ((((out)->length) >=9437184)) {
    return -1;
  }
  (void)(((((out)->data))[((out)->length)] = ((uint8_t)((b & 255)))));
  (void)((((out)->length) = (((out)->length) + 1)));
  return 0;
}
int32_t codegen_append_byte_u8(struct codegen_CodegenOutBuf * out, uint8_t b) {
  return codegen_append_byte(out, ((int32_t)(b)));
}
int32_t codegen_emit_bytes_4(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_5(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_6(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_7(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_8(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_9(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_22(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_32(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_64(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len) {
  return codegen_emit_bytes_from_ptr(out, ptr, len);
}
int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf * out, uint8_t * ptr, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (ptr)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_bytes_3(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  if (((prefix ==0) || (name ==0))) {
    return 0;
  }
  if (((prefix_len <=0) || (name_len < prefix_len))) {
    return 0;
  }
  if ((((((prefix_len ==4) && ((prefix)[0] ==97)) && ((prefix)[1] ==115)) && ((prefix)[2] ==116)) && ((prefix)[3] ==95))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < prefix_len)) {
    if (((name)[i] !=(prefix)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
extern int32_t codegen_append_byte(struct codegen_CodegenOutBuf * out, int32_t b);
extern int32_t codegen_emit_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx);
extern int32_t codegen_resolve_binding_import_dep_index(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t callee_expr_ref);
extern int32_t codegen_emit_async_run_seed_push_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t type_ref);
extern int32_t codegen_emit_async_sched_call_by_name(struct codegen_CodegenOutBuf * out, uint8_t * fn_name, int32_t fn_len);
extern int32_t codegen_emit_async_task_submit_call_by_symbol(struct codegen_CodegenOutBuf * out, uint8_t * prefix, int32_t prefix_len, uint8_t * fn_name, int32_t fn_len);
extern int32_t codegen_c_prefix_redundant_with_name(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len);
int32_t codegen_emit_bytes_2(struct codegen_CodegenOutBuf * out, uint8_t * buf, int32_t len) {
  {
    if ((buf ==0)) {
      return -1;
    }
    int32_t i = 0;
    while ((i < len)) {
      if ((codegen_append_byte_u8(out, (buf)[i]) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_format_uint(struct codegen_CodegenOutBuf * out, int32_t val) {
  if ((val >=10)) {
    int32_t q = (val / 10);
    int32_t r = (val % 10);
    if ((codegen_format_uint(out, q) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, (48 + r)) !=0)) {
      return -1;
    }
    return 0;
  }
  if ((codegen_append_byte(out, (48 + val)) !=0)) {
    return -1;
  }
  return 0;
}
int32_t codegen_format_uint64(struct codegen_CodegenOutBuf * out, uint64_t val) {
  if ((val >=10)) {
    uint64_t q = (val / 10);
    uint64_t r = (val % 10);
    if ((codegen_format_uint64(out, q) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, (48 + ((int32_t)(r)))) !=0)) {
      return -1;
    }
    return 0;
  }
  if ((codegen_append_byte(out, (48 + ((int32_t)(val)))) !=0)) {
    return -1;
  }
  return 0;
}
int32_t codegen_format_int(struct codegen_CodegenOutBuf * out, int64_t val) {
  {
    if ((val >=0)) {
      return codegen_format_uint64(out, ((uint64_t)(val)));
    }
    int64_t u = (0 - val);
    if ((u < 0)) {
      if ((codegen_append_byte(out, 45) !=0)) {
        return -1;
      }
      uint8_t d[20] = {57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56, 0};
      int32_t i = 0;
      while ((i < 19)) {
        if ((codegen_append_byte_u8(out, (d)[i]) !=0)) {
          return -1;
        }
        (void)((i = (i + 1)));
      }
      return 0;
    }
    if ((codegen_append_byte(out, 45) !=0)) {
      return -1;
    }
    return codegen_format_uint64(out, ((uint64_t)(u)));
  }
}
int32_t codegen_emit_indent(struct codegen_CodegenOutBuf * out, int32_t indent) {
  {
    int32_t i = 0;
    while ((i < indent)) {
      if ((codegen_append_byte(out, 32) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_break_stmt(struct codegen_CodegenOutBuf * out, int32_t indent) {
  {
    if ((codegen_emit_indent(out, indent) !=0)) {
      return -1;
    }
    uint8_t br[8] = {98, 114, 101, 97, 107, 59, 10, 0};
    return codegen_emit_bytes_8(out, &((br)[0]), 7);
  }
}
int32_t codegen_emit_continue_stmt(struct codegen_CodegenOutBuf * out, int32_t indent) {
  {
    if ((codegen_emit_indent(out, indent) !=0)) {
      return -1;
    }
    uint8_t co[11] = {99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0};
    return codegen_emit_bytes_from_ptr(out, &((co)[0]), 10);
  }
}
int32_t codegen_emit_type_kind_ord(struct codegen_CodegenOutBuf * out, int32_t tk) {
  return codegen_emit_type_kind(out, tk);
}
int32_t codegen_emit_type_kind(struct codegen_CodegenOutBuf * out, int32_t kind_ord) {
  if ((kind_ord ==0)) {
    uint8_t s[8] = {105, 110, 116, 51, 50, 95, 116, 0};
    return codegen_emit_bytes_8(out, &((s)[0]), 7);
  }
  if ((kind_ord ==5)) {
    uint8_t s[8] = {105, 110, 116, 54, 52, 95, 116, 0};
    return codegen_emit_bytes_8(out, &((s)[0]), 7);
  }
  if ((kind_ord ==1)) {
    uint8_t s[4] = {105, 110, 116, 0};
    return codegen_emit_bytes_4(out, &((s)[0]), 3);
  }
  if ((kind_ord ==2)) {
    uint8_t s[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
    return codegen_emit_bytes_9(out, &((s)[0]), 7);
  }
  if ((kind_ord ==3)) {
    uint8_t s[9] = {117, 105, 110, 116, 51, 50, 95, 116, 0};
    return codegen_emit_bytes_9(out, &((s)[0]), 8);
  }
  if ((kind_ord ==4)) {
    uint8_t s[9] = {117, 105, 110, 116, 54, 52, 95, 116, 0};
    return codegen_emit_bytes_9(out, &((s)[0]), 8);
  }
  if ((kind_ord ==14)) {
    uint8_t s[6] = {102, 108, 111, 97, 116, 0};
    return codegen_emit_bytes_6(out, &((s)[0]), 5);
  }
  if ((kind_ord ==15)) {
    uint8_t s[7] = {100, 111, 117, 98, 108, 101, 0};
    return codegen_emit_bytes_7(out, &((s)[0]), 6);
  }
  if ((kind_ord ==16)) {
    uint8_t s[5] = {118, 111, 105, 100, 0};
    return codegen_emit_bytes_5(out, &((s)[0]), 4);
  }
  if ((kind_ord ==6)) {
    uint8_t s[7] = {115, 105, 122, 101, 95, 116, 0};
    return codegen_emit_bytes_7(out, &((s)[0]), 6);
  }
  if ((kind_ord ==7)) {
    uint8_t s[8] = {115, 115, 105, 122, 101, 95, 116, 0};
    return codegen_emit_bytes_8(out, &((s)[0]), 7);
  }
  return -1;
}
int32_t codegen_type_kind_append_to_scratch(uint8_t * scratch, int32_t cap, int32_t w, int32_t kind_ord) {
  if ((kind_ord ==0)) {
    uint8_t s[8] = {105, 110, 116, 51, 50, 95, 116, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==5)) {
    uint8_t s[8] = {105, 110, 116, 54, 52, 95, 116, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==1)) {
    uint8_t s[4] = {105, 110, 116, 0};
    int32_t i = 0;
    while ((i < 3)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==2)) {
    uint8_t s[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==3)) {
    uint8_t s[9] = {117, 105, 110, 116, 51, 50, 95, 116, 0};
    int32_t i = 0;
    while ((i < 8)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==4)) {
    uint8_t s[9] = {117, 105, 110, 116, 54, 52, 95, 116, 0};
    int32_t i = 0;
    while ((i < 8)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==14)) {
    uint8_t s[6] = {102, 108, 111, 97, 116, 0};
    int32_t i = 0;
    while ((i < 5)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==15)) {
    uint8_t s[7] = {100, 111, 117, 98, 108, 101, 0};
    int32_t i = 0;
    while ((i < 6)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==16)) {
    uint8_t s[5] = {118, 111, 105, 100, 0};
    int32_t i = 0;
    while ((i < 4)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==6)) {
    uint8_t s[7] = {115, 105, 122, 101, 95, 116, 0};
    int32_t i = 0;
    while ((i < 6)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  if ((kind_ord ==7)) {
    uint8_t s[8] = {115, 115, 105, 122, 101, 95, 116, 0};
    int32_t i = 0;
    while ((i < 7)) {
      if ((w >=(cap - 1))) {
        return -1;
      }
      (void)(((scratch)[w] = (s)[i]));
      (void)((w = (w + 1)));
      (void)((i = (i + 1)));
    }
    return w;
  }
  return -1;
}
int32_t codegen_emit_vector_c_type_out(struct codegen_CodegenOutBuf * out, int32_t elem_kind_ord, int32_t lanes) {
  {
    if ((elem_kind_ord ==0)) {
      if ((lanes ==4)) {
        uint8_t s[8] = {105, 51, 50, 120, 52, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
      }
      if ((lanes ==8)) {
        uint8_t s[8] = {105, 51, 50, 120, 56, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
      }
      if ((lanes ==16)) {
        uint8_t sa[9] = {105, 51, 50, 120, 49, 54, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((sa)[0]), 8);
      }
    }
    if ((elem_kind_ord ==3)) {
      if ((lanes ==4)) {
        uint8_t s[8] = {117, 51, 50, 120, 52, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
      }
      if ((lanes ==8)) {
        uint8_t s[8] = {117, 51, 50, 120, 56, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
      }
      if ((lanes ==16)) {
        uint8_t sa[9] = {117, 51, 50, 120, 49, 54, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((sa)[0]), 8);
      }
    }
    if ((elem_kind_ord ==14)) {
      if ((lanes ==4)) {
        uint8_t s[8] = {102, 51, 50, 120, 52, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
      }
      if ((lanes ==8)) {
        uint8_t s[8] = {102, 51, 50, 120, 56, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((s)[0]), 7);
      }
      if ((lanes ==16)) {
        uint8_t sa[9] = {102, 51, 50, 120, 49, 54, 95, 116, 0};
        return codegen_emit_bytes_from_ptr(out, &((sa)[0]), 8);
      }
    }
    uint8_t df[8] = {105, 110, 116, 51, 50, 95, 116, 0};
    return codegen_emit_bytes_from_ptr(out, &((df)[0]), 7);
  }
}
int32_t codegen_type_kind_append_to_scratch_ord(uint8_t * scratch, int32_t cap, int32_t w, int32_t tk) {
  int32_t w2 = codegen_type_kind_append_to_scratch(scratch, cap, w, tk);
  if ((w2 < 0)) {
    return codegen_type_kind_append_to_scratch(scratch, cap, w, 0);
  }
  return w2;
}
int32_t codegen_type_to_c_repr(struct ast_ASTArena * arena, uint8_t * scratch, int32_t cap, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_type_to_c_repr(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
}
int32_t codegen_emit_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t tk = 0;
    int32_t elem_ref = 0;
    int32_t arr_sz = 0;
    int32_t elem_kind = 0;
    int32_t name_len = 0;
    uint8_t nm[128] = {};
    if (ast_ref_is_null(type_ref)) {
      uint8_t s[8] = {105, 110, 116, 51, 50, 95, 116, 0};
      return codegen_emit_bytes_8(out, &((s)[0]), 7);
    }
    (void)((type_ref = pipeline_typeck_resolve_type_alias_ref_c(arena, type_ref)));
    if (ast_ref_is_null(type_ref)) {
      uint8_t s2[8] = {105, 110, 116, 51, 50, 95, 116, 0};
      return codegen_emit_bytes_8(out, &((s2)[0]), 7);
    }
    if ((((ctx !=0) && (((ctx)->mono_active) !=0)) && (((ctx)->mono_num_types) > 0))) {
      int32_t mi = 0;
      while (((mi < ((ctx)->mono_num_types)) && (mi < 8))) {
        int32_t conc = (((ctx)->mono_concrete_type_refs))[mi];
        if ((((type_ref ==(((ctx)->mono_generic_type_refs))[mi]) && (conc > 0)) && (conc !=type_ref))) {
          return codegen_emit_type(arena, out, conc, struct_prefix, struct_prefix_len, ctx);
        }
        (void)((mi = (mi + 1)));
      }
      uint8_t fb_nm[128] = {};
      int32_t fb_len = pipeline_type_named_name_into(arena, type_ref, &((fb_nm)[0]));
      if ((fb_len > 0)) {
        int32_t mi2 = 0;
        while (((mi2 < ((ctx)->mono_num_types)) && (mi2 < 8))) {
          int32_t conc2 = (((ctx)->mono_concrete_type_refs))[mi2];
          if (((conc2 > 0) && (conc2 !=type_ref))) {
            uint8_t gnm[128] = {};
            int32_t gname_len = pipeline_type_named_name_into(arena, (((ctx)->mono_generic_type_refs))[mi2], &((gnm)[0]));
            if (((gname_len ==fb_len) && (gname_len > 0))) {
              int32_t names_eq = 1;
              int32_t ci = 0;
              while ((ci < gname_len)) {
                if (((gnm)[ci] !=(fb_nm)[ci])) {
                  (void)((names_eq = 0));
                  (void)((ci = gname_len));
                } else {
                  (void)((ci = (ci + 1)));
                }
              }
              if ((names_eq !=0)) {
                return codegen_emit_type(arena, out, conc2, struct_prefix, struct_prefix_len, ctx);
              }
            }
          }
          (void)((mi2 = (mi2 + 1)));
        }
      }
    }
    (void)((tk = pipeline_type_kind_ord_at(arena, type_ref)));
    (void)((elem_ref = pipeline_type_elem_ref_at(arena, type_ref)));
    (void)((arr_sz = pipeline_type_array_size_at(arena, type_ref)));
    if (((tk ==9) && !(ast_ref_is_null(elem_ref)))) {
      if ((pipeline_type_kind_ord_at(arena, elem_ref) ==10)) {
        return codegen_emit_c(arena, out, type_ref, 0, 0, ctx);
      }
      if ((codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 42);
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((nm)[0]))));
    if (((tk ==8) && (name_len > 0))) {
      uint8_t dep_prefix_buf[128] = {};
      int32_t dep_prefix_len = 0;
      if ((((((((name_len ==6) && ((nm)[0] ==66)) && ((nm)[1] ==117)) && ((nm)[2] ==102)) && ((nm)[3] ==102)) && ((nm)[4] ==101)) && ((nm)[5] ==114))) {
        uint8_t io_buf[22] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 105, 111, 95, 66, 117, 102, 102, 101, 114, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((io_buf)[0]), 20);
      }
      if (((((((((name_len >=8) && ((nm)[0] ==79)) && ((nm)[1] ==112)) && ((nm)[2] ==116)) && ((nm)[3] ==105)) && ((nm)[4] ==111)) && ((nm)[5] ==110)) && ((nm)[6] ==95))) {
        uint8_t opt_head[20] = {115, 116, 114, 117, 99, 116, 32, 99, 111, 114, 101, 95, 111, 112, 116, 105, 111, 110, 95, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((opt_head)[0]), 19) !=0)) {
          return -1;
        }
        int32_t oi = 0;
        while (((oi < name_len) && (oi < 64))) {
          if ((codegen_append_byte_u8(out, (nm)[oi]) !=0)) {
            return -1;
          }
          (void)((oi = (oi + 1)));
        }
        return 0;
      }
      /* ABI-dup canonical tag for Result_* mono shorts (same class as Option_*).
       * Root fix (G.7): emit_type rewrites short Result_* to struct core_result_ +
       * full name. Seed pin MUST match codegen.x (L4 cold uses this seed for
       * codegen_x.o; missing rewrite => incomplete struct Result_i32 on
       * core/result formal + stdlib-import FAIL).
       * PLATFORM: SHARED — same commit as compiler/src/codegen/codegen.x. */
      if (((((((((name_len >=8) && ((nm)[0] ==82)) && ((nm)[1] ==101)) && ((nm)[2] ==115)) && ((nm)[3] ==117)) && ((nm)[4] ==108)) && ((nm)[5] ==116)) && ((nm)[6] ==95))) {
        uint8_t res_head[20] = {115, 116, 114, 117, 99, 116, 32, 99, 111, 114, 101, 95, 114, 101, 115, 117, 108, 116, 95, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((res_head)[0]), 19) !=0)) {
          return -1;
        }
        int32_t ri = 0;
        while (((ri < name_len) && (ri < 64))) {
          if ((codegen_append_byte_u8(out, (nm)[ri]) !=0)) {
            return -1;
          }
          (void)((ri = (ri + 1)));
        }
        return 0;
      }
      /* ABI-dup canonical tag: rt_preamble owns `struct std_string_String` (+ typedef
       * String) and `struct std_string_StrView`; per-module layout is skipped. Bare
       * `struct String` is an incomplete host-C type that mismatches the STRUCT_LIT
       * compound literal `struct std_string_String` in function bodies -> host-cc
       * "returning 'struct std_string_String' from incompatible result type 'struct
       * String'". Root fix: emit_type uses the same canonical namespaced tag as the
       * STRUCT_LIT emitter and rt_preamble authority. Mirrors Buffer pattern.
       * PLATFORM: SHARED -- seed pin same commit as codegen.x; G.8 dual-end L2. */
      if ((((((((name_len ==6) && ((nm)[0] ==83)) && ((nm)[1] ==116)) && ((nm)[2] ==114)) && ((nm)[3] ==105)) && ((nm)[4] ==110)) && ((nm)[5] ==103))) {
        uint8_t s_string[26] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 83, 116, 114, 105, 110, 103, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((s_string)[0]), 24);
      }
      if (((((((((name_len ==7) && ((nm)[0] ==83)) && ((nm)[1] ==116)) && ((nm)[2] ==114)) && ((nm)[3] ==86)) && ((nm)[4] ==105)) && ((nm)[5] ==101)) && ((nm)[6] ==119))) {
        uint8_t s_view[27] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 83, 116, 114, 86, 105, 101, 119, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((s_view)[0]), 25);
      }
      /* ABI-dup canonical tags: Error/ErrorChain/Allocator — same class as String.
       * rt_preamble owns namespaced layouts; bare tags are incomplete when layout skip.
       * PLATFORM: SHARED — seed pin same commit as codegen.x. */
      if (((((((name_len ==5) && ((nm)[0] ==69)) && ((nm)[1] ==114)) && ((nm)[2] ==114)) && ((nm)[3] ==111)) && ((nm)[4] ==114))) {
        uint8_t s_err[24] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 101, 114, 114, 111, 114, 95, 69, 114, 114, 111, 114, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((s_err)[0]), 22);
      }
      if ((((((((((((name_len ==10) && ((nm)[0] ==69)) && ((nm)[1] ==114)) && ((nm)[2] ==114)) && ((nm)[3] ==111)) && ((nm)[4] ==114)) && ((nm)[5] ==67)) && ((nm)[6] ==104)) && ((nm)[7] ==97)) && ((nm)[8] ==105)) && ((nm)[9] ==110))) {
        uint8_t s_chain[28] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 101, 114, 114, 111, 114, 95, 69, 114, 114, 111, 114, 67, 104, 97, 105, 110, 0};
        return codegen_emit_bytes_from_ptr(out, &((s_chain)[0]), 27);
      }
      if (((((((((((name_len ==9) && ((nm)[0] ==65)) && ((nm)[1] ==108)) && ((nm)[2] ==108)) && ((nm)[3] ==111)) && ((nm)[4] ==99)) && ((nm)[5] ==97)) && ((nm)[6] ==116)) && ((nm)[7] ==111)) && ((nm)[8] ==114))) {
        uint8_t s_alloc[26] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 104, 101, 97, 112, 95, 65, 108, 108, 111, 99, 97, 116, 111, 114, 0};
        return codegen_emit_bytes_from_ptr(out, &((s_alloc)[0]), 25);
      }
      if (((((((((name_len ==7) && ((nm)[0] ==65)) && ((nm)[1] ==114)) && ((nm)[2] ==101)) && ((nm)[3] ==110)) && ((nm)[4] ==97)) && ((nm)[5] ==54)) && ((nm)[6] ==52))) {
        uint8_t s_arena[24] = {115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 104, 101, 97, 112, 95, 65, 114, 101, 110, 97, 54, 52, 0};
        return codegen_emit_bytes_from_ptr(out, &((s_arena)[0]), 23);
      }
      if (((((name_len ==3) && ((nm)[0] ==117)) && ((nm)[1] ==49)) && ((nm)[2] ==54))) {
        uint8_t u16_t[9] = {117, 105, 110, 116, 49, 54, 95, 116, 0};
        return codegen_emit_bytes_8(out, &((u16_t)[0]), 8);
      }
      if (((((name_len ==3) && ((nm)[0] ==105)) && ((nm)[1] ==49)) && ((nm)[2] ==54))) {
        uint8_t i16_t[8] = {105, 110, 116, 49, 54, 95, 116, 0};
        return codegen_emit_bytes_8(out, &((i16_t)[0]), 7);
      }
      if ((((name_len ==2) && ((nm)[0] ==105)) && ((nm)[1] ==56))) {
        uint8_t i8_t[7] = {105, 110, 116, 56, 95, 116, 0};
        return codegen_emit_bytes_8(out, &((i8_t)[0]), 6);
      }
      if (((((((name_len ==5) && ((nm)[0] ==105)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==52))) {
        return codegen_emit_vector_c_type_out(out, 0, 4);
      }
      if (((((((name_len ==5) && ((nm)[0] ==105)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==56))) {
        return codegen_emit_vector_c_type_out(out, 0, 8);
      }
      if (((((((name_len ==5) && ((nm)[0] ==117)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==52))) {
        return codegen_emit_vector_c_type_out(out, 3, 4);
      }
      if (((((((name_len ==5) && ((nm)[0] ==117)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==56))) {
        return codegen_emit_vector_c_type_out(out, 3, 8);
      }
      if ((((((((name_len ==6) && ((nm)[0] ==105)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==49)) && ((nm)[5] ==54))) {
        return codegen_emit_vector_c_type_out(out, 0, 16);
      }
      if ((((((((name_len ==6) && ((nm)[0] ==117)) && ((nm)[1] ==51)) && ((nm)[2] ==50)) && ((nm)[3] ==120)) && ((nm)[4] ==49)) && ((nm)[5] ==54))) {
        return codegen_emit_vector_c_type_out(out, 3, 16);
      }
      if ((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (codegen_type_is_module_user_enum(((ctx)->current_codegen_module), arena, type_ref) !=0))) {
        uint8_t i32_enum[8] = {105, 110, 116, 51, 50, 95, 116, 0};
        return codegen_emit_bytes_8(out, &((i32_enum)[0]), 7);
      }
      if ((ctx !=0)) {
        uint8_t dep_enum_prefix[128] = {};
        int32_t dep_enum_prefix_len = codegen_type_dep_enum_prefix_into(ctx, arena, type_ref, &((dep_enum_prefix)[0]), 128);
        if ((dep_enum_prefix_len > 0)) {
          uint8_t e[8] = {101, 110, 117, 109, 32, 0, 0, 0};
          if ((codegen_emit_bytes_8(out, &((e)[0]), 5) !=0)) {
            return -1;
          }
          if ((codegen_emit_bytes_from_ptr(out, &((dep_enum_prefix)[0]), dep_enum_prefix_len) !=0)) {
            return -1;
          }
          int32_t bare_off2 = 0;
          int32_t bi2 = 0;
          while (((bi2 < name_len) && (bi2 < 64))) {
            if (((nm)[bi2] ==46)) {
              (void)((bare_off2 = (bi2 + 1)));
            }
            (void)((bi2 = (bi2 + 1)));
          }
          int32_t ci2 = bare_off2;
          while (((ci2 < name_len) && (ci2 < 128))) {
            if ((codegen_append_byte_u8(out, (nm)[ci2]) !=0)) {
              return -1;
            }
            (void)((ci2 = (ci2 + 1)));
          }
          return 0;
        }
      }
      uint8_t s[8] = {115, 116, 114, 117, 99, 116, 32, 0};
      if ((codegen_emit_bytes_8(out, &((s)[0]), 7) !=0)) {
        return -1;
      }
      (void)((dep_prefix_len = codegen_type_dep_struct_prefix_into(ctx, arena, type_ref, &((dep_prefix_buf)[0]), 128)));
      if ((dep_prefix_len ==0)) {
        int32_t qmod_end = 0;
        int qhas_dot = 0;
        int32_t qi = 0;
        while (((qi < name_len) && (qi < 64))) {
          if (((nm)[qi] ==46)) {
            (void)((qhas_dot = 1));
            (void)((qmod_end = qi));
          }
          (void)((qi = (qi + 1)));
        }
        if (((qhas_dot && (qmod_end > 0)) && (qmod_end < 64))) {
          uint8_t mod_path[128] = {};
          int32_t mi = 0;
          while ((mi < qmod_end)) {
            (void)(((mod_path)[mi] = (nm)[mi]));
            (void)((mi = (mi + 1)));
          }
          (void)(((mod_path)[mi] = ((uint8_t)(0))));
          (void)(codegen_import_path_to_c_prefix_into(&((mod_path)[0]), &((dep_prefix_buf)[0]), 128));
          (void)((dep_prefix_len = 0));
          while (((dep_prefix_len < 128) && ((dep_prefix_buf)[dep_prefix_len] !=0))) {
            (void)((dep_prefix_len = (dep_prefix_len + 1)));
          }
        }
      }
      if ((dep_prefix_len > 0)) {
        if ((codegen_emit_bytes_from_ptr(out, &((dep_prefix_buf)[0]), dep_prefix_len) !=0)) {
          return -1;
        }
      } else {
        if (((struct_prefix !=0) && (struct_prefix_len > 0))) {
          if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
            return -1;
          }
        } else {
          if ((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (codegen_type_is_module_user_struct(((ctx)->current_codegen_module), arena, type_ref) !=0))) {
            uint8_t cur_pre[128] = {};
            int32_t cur_pre_len = codegen_emit_prefix_len_from_ctx(ctx, &((cur_pre)[0]), 128);
            if (((cur_pre_len > 0) && (codegen_emit_bytes_from_ptr(out, &((cur_pre)[0]), cur_pre_len) !=0))) {
              return -1;
            }
          } else {
            if (((ctx !=0) && (((ctx)->current_codegen_dep_index) < 0))) {
            } else {
              uint8_t ast_p[4] = {97, 115, 116, 95};
              if ((codegen_emit_bytes_4(out, &((ast_p)[0]), 4) !=0)) {
                return -1;
              }
            }
          }
        }
      }
      int32_t bare_off = 0;
      int32_t bi = 0;
      while (((bi < name_len) && (bi < 64))) {
        if (((nm)[bi] ==46)) {
          (void)((bare_off = (bi + 1)));
        }
        (void)((bi = (bi + 1)));
      }
      int32_t ci = bare_off;
      while (((ci < name_len) && (ci < 128))) {
        if ((codegen_append_byte_u8(out, (nm)[ci]) !=0)) {
          return -1;
        }
        (void)((ci = (ci + 1)));
      }
      if (((ctx !=0) && (((ctx)->current_codegen_module) !=0))) {
        if ((codegen_maybe_emit_generic_struct_mono_suffix_for_type(((ctx)->current_codegen_module), arena, out, type_ref, ctx) !=0)) {
          return -1;
        }
      }
      return 0;
    }
    if (((tk ==10) && !(ast_ref_is_null(elem_ref)))) {
      if ((codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 42);
    }
    if (((tk ==11) && !(ast_ref_is_null(elem_ref)))) {
      if ((((ctx !=0) && (((ctx)->mono_active) !=0)) && (((ctx)->mono_num_types) > 0))) {
        if ((pipeline_type_kind_ord_at(arena, elem_ref) ==8)) {
          uint8_t cur_sl_nm[128] = {};
          int32_t cur_sl_nl = pipeline_type_named_name_into(arena, elem_ref, &((cur_sl_nm)[0]));
          if ((cur_sl_nl > 0)) {
            int32_t mi_sl = 0;
            while (((mi_sl < ((ctx)->mono_num_types)) && (mi_sl < 8))) {
              int32_t g_sl = (((ctx)->mono_generic_type_refs))[mi_sl];
              int32_t c_sl = (((ctx)->mono_concrete_type_refs))[mi_sl];
              if ((((((c_sl > 0) && (c_sl !=type_ref)) && (g_sl > 0)) && (pipeline_type_kind_ord_at(arena, g_sl) ==11)) && (pipeline_type_kind_ord_at(arena, c_sl) ==11))) {
                int32_t e_gen_sl = pipeline_type_elem_ref_at(arena, g_sl);
                if (((e_gen_sl > 0) && (pipeline_type_kind_ord_at(arena, e_gen_sl) ==8))) {
                  uint8_t g_sl_nm[128] = {};
                  int32_t g_sl_nl = pipeline_type_named_name_into(arena, e_gen_sl, &((g_sl_nm)[0]));
                  if (((g_sl_nl ==cur_sl_nl) && (g_sl_nl > 0))) {
                    int32_t eq_sl = 1;
                    int32_t ci_sl = 0;
                    while ((ci_sl < g_sl_nl)) {
                      if (((g_sl_nm)[ci_sl] !=(cur_sl_nm)[ci_sl])) {
                        (void)((eq_sl = 0));
                        (void)((ci_sl = g_sl_nl));
                      } else {
                        (void)((ci_sl = (ci_sl + 1)));
                      }
                    }
                    if ((eq_sl !=0)) {
                      return codegen_emit_type(arena, out, c_sl, struct_prefix, struct_prefix_len, ctx);
                    }
                  }
                }
              }
              (void)((mi_sl = (mi_sl + 1)));
            }
            int32_t mi_bt = 0;
            while (((mi_bt < ((ctx)->mono_num_types)) && (mi_bt < 8))) {
              int32_t g_bt = (((ctx)->mono_generic_type_refs))[mi_bt];
              int32_t c_bt = (((ctx)->mono_concrete_type_refs))[mi_bt];
              if (((((c_bt > 0) && (c_bt !=type_ref)) && (g_bt > 0)) && (pipeline_type_kind_ord_at(arena, g_bt) ==8))) {
                uint8_t g_bt_nm[128] = {};
                int32_t g_bt_nl = pipeline_type_named_name_into(arena, g_bt, &((g_bt_nm)[0]));
                if (((g_bt_nl ==cur_sl_nl) && (g_bt_nl > 0))) {
                  int32_t eq_bt = 1;
                  int32_t ci_bt = 0;
                  while ((ci_bt < g_bt_nl)) {
                    if (((g_bt_nm)[ci_bt] !=(cur_sl_nm)[ci_bt])) {
                      (void)((eq_bt = 0));
                      (void)((ci_bt = g_bt_nl));
                    } else {
                      (void)((ci_bt = (ci_bt + 1)));
                    }
                  }
                  if ((eq_bt !=0)) {
                    uint8_t eb_bt[256] = {};
                    int32_t n_bt = codegen_type_to_c_repr(arena, &((eb_bt)[0]), 256, c_bt, struct_prefix, struct_prefix_len);
                    if ((n_bt > 0)) {
                      int32_t sp_bt = 0;
                      if (((((((((n_bt >=7) && ((eb_bt)[0] ==115)) && ((eb_bt)[1] ==116)) && ((eb_bt)[2] ==114)) && ((eb_bt)[3] ==117)) && ((eb_bt)[4] ==99)) && ((eb_bt)[5] ==116)) && ((eb_bt)[6] ==32))) {
                        (void)((sp_bt = 7));
                        while (((sp_bt < n_bt) && ((eb_bt)[sp_bt] ==32))) {
                          (void)((sp_bt = (sp_bt + 1)));
                        }
                      }
                      int32_t plen_bt = (n_bt - sp_bt);
                      if ((plen_bt > 0)) {
                        uint8_t hdr_bt[20] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
                        if ((codegen_emit_bytes_from_ptr(out, &((hdr_bt)[0]), 19) !=0)) {
                          return -1;
                        }
                        int32_t pi_bt = 0;
                        while ((pi_bt < plen_bt)) {
                          if ((codegen_append_byte_u8(out, (eb_bt)[(sp_bt + pi_bt)]) !=0)) {
                            return -1;
                          }
                          (void)((pi_bt = (pi_bt + 1)));
                        }
                        return 0;
                      }
                    }
                  }
                }
              }
              (void)((mi_bt = (mi_bt + 1)));
            }
          }
        }
      }
      int32_t ek = pipeline_type_kind_ord_at(arena, elem_ref);
      if ((ek ==8)) {
        uint8_t enm[128] = {};
        int32_t enl = pipeline_type_named_name_into(arena, elem_ref, &((enm)[0]));
        int32_t is_short_int = 0;
        if ((((enl ==2) && ((enm)[0] ==105)) && ((enm)[1] ==56))) {
          (void)((is_short_int = 1));
        }
        if (((((enl ==3) && ((enm)[0] ==105)) && ((enm)[1] ==49)) && ((enm)[2] ==54))) {
          (void)((is_short_int = 1));
        }
        if (((((enl ==3) && ((enm)[0] ==117)) && ((enm)[1] ==49)) && ((enm)[2] ==54))) {
          (void)((is_short_int = 1));
        }
        if (((is_short_int ==0) && (enl > 0))) {
          uint8_t hdr_sl[20] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((hdr_sl)[0]), 19) !=0)) {
            return -1;
          }
          uint8_t dep_prefix_buf2[128] = {};
          int32_t dep_prefix_len2 = codegen_type_dep_struct_prefix_into(ctx, arena, elem_ref, &((dep_prefix_buf2)[0]), 128);
          if ((dep_prefix_len2 ==0)) {
            int32_t qmod_end2 = 0;
            int qhas_dot2 = 0;
            int32_t qi2 = 0;
            while (((qi2 < enl) && (qi2 < 64))) {
              if (((enm)[qi2] ==46)) {
                (void)((qhas_dot2 = 1));
                (void)((qmod_end2 = qi2));
              }
              (void)((qi2 = (qi2 + 1)));
            }
            if (((qhas_dot2 && (qmod_end2 > 0)) && (qmod_end2 < 64))) {
              uint8_t mod_path2[128] = {};
              int32_t mi2 = 0;
              while ((mi2 < qmod_end2)) {
                (void)(((mod_path2)[mi2] = (enm)[mi2]));
                (void)((mi2 = (mi2 + 1)));
              }
              (void)(((mod_path2)[mi2] = ((uint8_t)(0))));
              (void)(codegen_import_path_to_c_prefix_into(&((mod_path2)[0]), &((dep_prefix_buf2)[0]), 128));
              (void)((dep_prefix_len2 = 0));
              while (((dep_prefix_len2 < 128) && ((dep_prefix_buf2)[dep_prefix_len2] !=0))) {
                (void)((dep_prefix_len2 = (dep_prefix_len2 + 1)));
              }
            }
          }
          if ((dep_prefix_len2 > 0)) {
            if ((codegen_emit_bytes_from_ptr(out, &((dep_prefix_buf2)[0]), dep_prefix_len2) !=0)) {
              return -1;
            }
          } else {
            if (((struct_prefix !=0) && (struct_prefix_len > 0))) {
              if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
                return -1;
              }
            } else {
              if ((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (codegen_type_is_module_user_struct(((ctx)->current_codegen_module), arena, elem_ref) !=0))) {
                uint8_t cur_pre2[128] = {};
                int32_t cur_pre_len2 = codegen_emit_prefix_len_from_ctx(ctx, &((cur_pre2)[0]), 128);
                if (((cur_pre_len2 > 0) && (codegen_emit_bytes_from_ptr(out, &((cur_pre2)[0]), cur_pre_len2) !=0))) {
                  return -1;
                }
              } else {
                if (((ctx !=0) && (((ctx)->current_codegen_dep_index) < 0))) {
                } else {
                  uint8_t ast_p2[4] = {97, 115, 116, 95};
                  if ((codegen_emit_bytes_4(out, &((ast_p2)[0]), 4) !=0)) {
                    return -1;
                  }
                }
              }
            }
          }
          int32_t bare_off2 = 0;
          int32_t bi3 = 0;
          while (((bi3 < enl) && (bi3 < 64))) {
            if (((enm)[bi3] ==46)) {
              (void)((bare_off2 = (bi3 + 1)));
            }
            (void)((bi3 = (bi3 + 1)));
          }
          int32_t ci3 = bare_off2;
          while (((ci3 < enl) && (ci3 < 128))) {
            if ((codegen_append_byte_u8(out, (enm)[ci3]) !=0)) {
              return -1;
            }
            (void)((ci3 = (ci3 + 1)));
          }
          return 0;
        }
      }
      uint8_t * pfx_use = struct_prefix;
      int32_t pfx_len_use = struct_prefix_len;
      uint8_t cur_pre_sl[128] = {};
      if ((((pfx_use ==0) || (pfx_len_use <=0)) && (ctx !=0))) {
        int32_t pl_sl = codegen_emit_prefix_len_from_ctx(ctx, &((cur_pre_sl)[0]), 128);
        if ((pl_sl > 0)) {
          (void)((pfx_use = &((cur_pre_sl)[0])));
          (void)((pfx_len_use = pl_sl));
        }
      }
      uint8_t slb[256] = {};
      int32_t nl = codegen_type_to_c_repr(arena, &((slb)[0]), 256, type_ref, pfx_use, pfx_len_use);
      if ((nl <=0)) {
        return -1;
      }
      int32_t si = 0;
      while ((si < nl)) {
        if ((codegen_append_byte_u8(out, (slb)[si]) !=0)) {
          return -1;
        }
        (void)((si = (si + 1)));
      }
      return 0;
    }
    if (((tk ==13) && !(ast_ref_is_null(elem_ref)))) {
      (void)((elem_kind = pipeline_type_kind_ord_at(arena, elem_ref)));
      return codegen_emit_vector_c_type_out(out, elem_kind, arr_sz);
    }
    if (((tk ==12) && !(ast_ref_is_null(elem_ref)))) {
      return codegen_emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx);
    }
    return codegen_emit_type_kind_ord(out, tk);
  }
}
int32_t codegen_type_dep_struct_owner_index(struct ast_PipelineDepCtx * ctx, uint8_t * bare_nm, int32_t bare_len) {
  {
    int32_t best_di = -1;
    int32_t best_export = 0;
    int32_t best_nf = 0;
    int32_t cur = -1;
    int32_t di = 0;
    int32_t nd = 0;
    if ((((ctx ==0) || (bare_nm ==0)) || (bare_len <=0))) {
      return -1;
    }
    (void)((cur = ((ctx)->current_codegen_dep_index)));
    (void)((nd = pipeline_dep_ctx_ndep(ctx)));
    while ((di < nd)) {
      struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
      if ((dep_mod !=0)) {
        int32_t li = 0;
        int32_t hit = 0;
        int32_t hit_export = 0;
        int32_t hit_nf = 0;
        while ((li < ((dep_mod)->num_struct_layouts))) {
          int32_t dep_name_len = pipeline_module_struct_layout_name_len(dep_mod, li);
          if ((dep_name_len ==bare_len)) {
            uint8_t dep_nm[128] = {};
            int eq = 1;
            int32_t j = 0;
            (void)(pipeline_module_struct_layout_name_into(dep_mod, li, &((dep_nm)[0])));
            while (((j < bare_len) && (j < 64))) {
              if (((dep_nm)[j] !=(bare_nm)[j])) {
                (void)((eq = 0));
                break;
              }
              (void)((j = (j + 1)));
            }
            if (eq) {
              (void)((hit = 1));
              (void)((hit_nf = pipeline_module_struct_layout_num_fields(dep_mod, li)));
              if ((pipeline_module_struct_layout_is_export_at(dep_mod, li) !=0)) {
                (void)((hit_export = 1));
              }
              break;
            }
          }
          (void)((li = (li + 1)));
        }
        if ((hit !=0)) {
          if ((best_di < 0)) {
            (void)((best_di = di));
            (void)((best_export = hit_export));
            (void)((best_nf = hit_nf));
          } else {
            if (((hit_nf > 0) && (best_nf <=0))) {
              (void)((best_di = di));
              (void)((best_export = hit_export));
              (void)((best_nf = hit_nf));
            } else {
              if (((((hit_nf > 0) && (best_nf > 0)) && (hit_export !=0)) && (best_export ==0))) {
                (void)((best_di = di));
                (void)((best_export = 1));
                (void)((best_nf = hit_nf));
              } else {
                if ((((hit_export !=0) && (best_export ==0)) && (hit_nf >=best_nf))) {
                  (void)((best_di = di));
                  (void)((best_export = 1));
                  (void)((best_nf = hit_nf));
                } else {
                  if ((((((hit_nf > 0) && (best_nf > 0)) && (hit_export !=0)) && (best_export !=0)) && (di ==cur))) {
                    (void)((best_di = di));
                    (void)((best_nf = hit_nf));
                  } else {
                    if ((((((hit_nf > 0) && (best_nf > 0)) && (hit_export ==0)) && (best_export ==0)) && (di > best_di))) {
                      (void)((best_di = di));
                      (void)((best_nf = hit_nf));
                    }
                  }
                }
              }
            }
          }
        }
      }
      (void)((di = (di + 1)));
    }
    return best_di;
  }
}
int32_t codegen_type_dep_struct_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[128] = {};
    int32_t owner = -1;
    if ((((((ctx ==0) || (arena ==0)) || (dst ==0)) || (dst_cap <=0)) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t bare_off = 0;
    int32_t bi = 0;
    while (((bi < name_len) && (bi < 64))) {
      if (((ty_nm)[bi] ==46)) {
        (void)((bare_off = (bi + 1)));
      }
      (void)((bi = (bi + 1)));
    }
    int32_t bare_len = (name_len - bare_off);
    (void)((owner = codegen_type_dep_struct_owner_index(ctx, &((ty_nm)[bare_off]), bare_len)));
    if ((owner >=0)) {
      uint8_t dep_path[128] = {};
      int32_t plen = codegen_dep_import_path_len_at(ctx, owner, &((dep_path)[0]));
      if ((plen > 0)) {
        (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), dst, dst_cap));
        int32_t out_len = 0;
        while (((out_len < dst_cap) && ((dst)[out_len] !=0))) {
          (void)((out_len = (out_len + 1)));
        }
        return out_len;
      }
    }
    return 0;
  }
}
int32_t codegen_type_array_elem_is_u8(struct ast_ASTArena * arena, int32_t type_ref) {
  {
    int32_t inner = 0;
    if (((ast_ref_is_null(type_ref) || (type_ref <=0)) || (type_ref > ((arena)->num_types)))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=10)) {
      return 0;
    }
    (void)((inner = pipeline_type_elem_ref_at(arena, type_ref)));
    if (((ast_ref_is_null(inner) || (inner <=0)) || (inner > ((arena)->num_types)))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, inner) ==2)) {
      return 1;
    }
    return 0;
  }
}
int32_t codegen_emit_c(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t ptr_type_ref, uint8_t * name, int32_t name_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t arr_tr = 0;
    if ((ast_ref_is_null(ptr_type_ref) || (pipeline_type_kind_ord_at(arena, ptr_type_ref) !=9))) {
      return -1;
    }
    (void)((arr_tr = pipeline_type_elem_ref_at(arena, ptr_type_ref)));
    if ((ast_ref_is_null(arr_tr) || (pipeline_type_kind_ord_at(arena, arr_tr) !=10))) {
      return -1;
    }
    if ((codegen_emit_local_fixed_array_elem_type(arena, out, arr_tr, ctx) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 42) !=0)) {
      return -1;
    }
    if (((name_len > 0) && (name !=0))) {
      if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
        return -1;
      }
    }
    if ((codegen_append_byte(out, 41) !=0)) {
      return -1;
    }
    return codegen_emit_local_fixed_array_suffix(arena, out, arr_tr);
  }
}
int32_t codegen_type_is(struct ast_ASTArena * arena, int32_t type_ref) {
  {
    int32_t elem = 0;
    if ((ast_ref_is_null(type_ref) || (pipeline_type_kind_ord_at(arena, type_ref) !=9))) {
      return 0;
    }
    (void)((elem = pipeline_type_elem_ref_at(arena, type_ref)));
    if ((ast_ref_is_null(elem) || (pipeline_type_kind_ord_at(arena, elem) !=10))) {
      return 0;
    }
    return 1;
  }
}
int32_t codegen_emit_local_fixed_array_elem_type(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t base_ref = type_ref;
    while ((!(ast_ref_is_null(base_ref)) && (pipeline_type_kind_ord_at(arena, base_ref) ==10))) {
      int32_t inner = pipeline_type_elem_ref_at(arena, base_ref);
      if (ast_ref_is_null(inner)) {
        break;
      }
      (void)((base_ref = inner));
    }
    if ((ast_ref_is_null(base_ref) || (codegen_emit_type(arena, out, base_ref, 0, 0, ctx) !=0))) {
      uint8_t fb[8] = {105, 110, 116, 51, 50, 95, 116, 0};
      return codegen_emit_bytes_8(out, &((fb)[0]), 7);
    }
    return 0;
  }
}
int32_t codegen_emit_local_fixed_array_suffix(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref) {
  {
    int32_t dims_ref = type_ref;
    int32_t depth = 0;
    while (((!(ast_ref_is_null(dims_ref)) && (pipeline_type_kind_ord_at(arena, dims_ref) ==10)) && (depth < 8))) {
      int32_t asz = pipeline_type_array_size_at(arena, dims_ref);
      if ((codegen_append_byte(out, 91) !=0)) {
        return -1;
      }
      if ((codegen_format_int(out, asz) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 93) !=0)) {
        return -1;
      }
      (void)((dims_ref = pipeline_type_elem_ref_at(arena, dims_ref)));
      (void)((depth = (depth + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_local_fixed_array_let_finish(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t indent, uint8_t * name, int32_t name_len, int32_t linit_ref, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t use_brace = 0;
    int32_t use_zero = 0;
    if (((ast_ref_is_null(linit_ref) || (linit_ref <=0)) || (linit_ref > ((arena)->num_exprs)))) {
      (void)((use_zero = 1));
    } else {
      struct ast_Expr ie = ast_ast_arena_expr_get(arena, linit_ref);
      if ((((int32_t)(((ie).kind))) ==46)) {
        (void)((use_brace = 1));
      } else {
        if (((((int32_t)(((ie).kind))) ==0) && (((ie).int_val) ==0))) {
          (void)((use_zero = 1));
        }
      }
    }
    if ((use_brace !=0)) {
      uint8_t eqb[4] = {32, 61, 32, 0};
      if ((codegen_emit_bytes_4(out, &((eqb)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_braced_array_lit_init(arena, out, linit_ref, ctx) !=0)) {
        return -1;
      }
      uint8_t scb[3] = {59, 10, 0};
      return codegen_emit_bytes_3(out, &((scb)[0]), 2);
    }
    if ((use_zero !=0)) {
      uint8_t z[10] = {32, 61, 32, 123, 32, 48, 32, 125, 59, 10};
      return codegen_emit_bytes_from_ptr(out, &((z)[0]), 10);
    }
    if ((codegen_append_byte(out, 59) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 10) !=0)) {
      return -1;
    }
    if ((codegen_emit_indent(out, indent) !=0)) {
      return -1;
    }
    uint8_t pref[16] = {109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42, 41, 40, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((pref)[0]), 15) !=0)) {
      return -1;
    }
    if (((name_len > 0) && (codegen_emit_bytes_64(out, &((name)[0]), name_len) !=0))) {
      return -1;
    }
    uint8_t mid[20] = {41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((mid)[0]), 17) !=0)) {
      return -1;
    }
    if ((codegen_emit_expr(arena, out, linit_ref, ctx) !=0)) {
      return -1;
    }
    uint8_t mid_sz[12] = {41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((mid_sz)[0]), 10) !=0)) {
      return -1;
    }
    if (((name_len > 0) && (codegen_emit_bytes_64(out, &((name)[0]), name_len) !=0))) {
      return -1;
    }
    uint8_t tail[4] = {41, 41, 59, 10};
    return codegen_emit_bytes_from_ptr(out, &((tail)[0]), 4);
  }
}
int32_t codegen_try_emit_slice_init_from_array_var(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t let_idx, int32_t let_type_ref, int32_t linit_ref) {
  {
    if ((ast_ref_is_null(let_type_ref) || (pipeline_type_kind_ord_at(arena, let_type_ref) !=11))) {
      return 0;
    }
    if (((ast_ref_is_null(linit_ref) || (linit_ref <=0)) || (linit_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_ref);
    int32_t arr_sz = 0;
    int32_t is_field = 0;
    struct ast_Expr base_e = init_e;
    int32_t init_ko = pipeline_expr_kind_ord_at(arena, linit_ref);
    if (((init_ko ==3) && (((init_e).var_name_len) > 0))) {
      int32_t li = 0;
      while ((li < let_idx)) {
        int32_t nlen = pipeline_block_let_name_len(arena, block_ref, li);
        if (((nlen ==((init_e).var_name_len)) && (nlen > 0))) {
          int32_t matched = 1;
          uint8_t nb[128] = {};
          (void)(pipeline_block_let_name_copy64(arena, block_ref, li, &((nb)[0])));
          int32_t ci = 0;
          while ((ci < nlen)) {
            if (((nb)[ci] !=(((init_e).var_name))[ci])) {
              (void)((matched = 0));
              (void)((ci = nlen));
            } else {
              (void)((ci = (ci + 1)));
            }
          }
          if ((matched !=0)) {
            int32_t tr = pipeline_block_let_type_ref(arena, block_ref, li);
            if ((pipeline_type_kind_ord_at(arena, tr) ==10)) {
              (void)((arr_sz = pipeline_type_array_size_at(arena, tr)));
              (void)((li = let_idx));
            }
          }
        }
        (void)((li = (li + 1)));
      }
      if ((((arr_sz <=0) && !(ast_ref_is_null(((init_e).resolved_type_ref)))) && (((init_e).resolved_type_ref) > 0))) {
        if ((pipeline_type_kind_ord_at(arena, ((init_e).resolved_type_ref)) ==10)) {
          (void)((arr_sz = pipeline_type_array_size_at(arena, ((init_e).resolved_type_ref))));
        }
      }
    } else {
      if (((((init_ko ==44) && (((init_e).field_access_field_len) > 0)) && (((init_e).field_access_base_ref) > 0)) && (((init_e).field_access_base_ref) <=((arena)->num_exprs)))) {
        (void)((is_field = 1));
        (void)((base_e = ast_ast_arena_expr_get(arena, ((init_e).field_access_base_ref))));
        if (((((int32_t)(((base_e).kind))) !=3) || (((base_e).var_name_len) <=0))) {
          return 0;
        }
        if ((!(ast_ref_is_null(((init_e).resolved_type_ref))) && (((init_e).resolved_type_ref) > 0))) {
          if ((pipeline_type_kind_ord_at(arena, ((init_e).resolved_type_ref)) ==10)) {
            (void)((arr_sz = pipeline_type_array_size_at(arena, ((init_e).resolved_type_ref))));
          }
        }
      } else {
        return 0;
      }
    }
    if (((arr_sz <=0) && (is_field ==0))) {
      return 0;
    }
    if ((codegen_append_byte(out, 123) !=0)) {
      return -1;
    }
    uint8_t d1[9] = {32, 46, 100, 97, 116, 97, 32, 61, 32};
    if ((codegen_emit_bytes_from_ptr(out, &((d1)[0]), 9) !=0)) {
      return -1;
    }
    if ((is_field !=0)) {
      if ((codegen_emit_bytes_64(out, &((((base_e).var_name))[0]), ((base_e).var_name_len)) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 46) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_64(out, &((((init_e).field_access_field_name))[0]), ((init_e).field_access_field_len)) !=0)) {
        return -1;
      }
    } else {
      if ((codegen_emit_bytes_64(out, &((((init_e).var_name))[0]), ((init_e).var_name_len)) !=0)) {
        return -1;
      }
    }
    uint8_t d2[12] = {44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32};
    if ((codegen_emit_bytes_from_ptr(out, &((d2)[0]), 12) !=0)) {
      return -1;
    }
    if ((arr_sz > 0)) {
      if ((codegen_format_int(out, arr_sz) !=0)) {
        return -1;
      }
    } else {
      uint8_t sz0[8] = {40, 115, 105, 122, 101, 111, 102, 40};
      uint8_t sz1[12] = {41, 47, 115, 105, 122, 101, 111, 102, 40, 40, 0, 0};
      uint8_t sz2[8] = {41, 91, 48, 93, 41, 41, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((sz0)[0]), 8) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_64(out, &((((base_e).var_name))[0]), ((base_e).var_name_len)) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 46) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_64(out, &((((init_e).field_access_field_name))[0]), ((init_e).field_access_field_len)) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sz1)[0]), 10) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_64(out, &((((base_e).var_name))[0]), ((base_e).var_name_len)) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 46) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_64(out, &((((init_e).field_access_field_name))[0]), ((init_e).field_access_field_len)) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((sz2)[0]), 6) !=0)) {
        return -1;
      }
    }
    uint8_t d3[4] = {32, 125, 0, 0};
    if ((codegen_emit_bytes_4(out, &((d3)[0]), 2) !=0)) {
      return -1;
    }
    return 1;
  }
}
int32_t codegen_emit_braced_array_lit_init(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t init_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if (((ast_ref_is_null(init_ref) || (init_ref <=0)) || (init_ref > ((arena)->num_exprs)))) {
      uint8_t z[4] = {123, 32, 48, 0};
      if ((codegen_emit_bytes_4(out, &((z)[0]), 3) !=0)) {
        return -1;
      }
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, init_ref) !=46)) {
      if ((codegen_emit_expr(arena, out, init_ref, ctx) !=0)) {
        return -1;
      }
      return 0;
    }
    if ((codegen_append_byte(out, 123) !=0)) {
      return -1;
    }
    int32_t n = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    int32_t ai = 0;
    while ((ai < n)) {
      if ((ai > 0)) {
        uint8_t comma[3] = {44, 32, 0};
        if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) ==0)) {
          (void)((ai = ai));
        } else {
          return -1;
        }
      }
      int32_t elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
      if ((!(ast_ref_is_null(elem_ref)) && (pipeline_expr_kind_ord_at(arena, elem_ref) ==46))) {
        if ((codegen_emit_braced_array_lit_init(arena, out, elem_ref, ctx) !=0)) {
          return -1;
        }
        (void)((ai = (ai + 1)));
      } else {
        if ((codegen_emit_expr(arena, out, elem_ref, ctx) ==0)) {
          (void)((ai = (ai + 1)));
        } else {
          return -1;
        }
      }
    }
    if ((codegen_append_byte(out, 125) ==0)) {
      return 0;
    }
    return -1;
  }
}
int32_t codegen_emit_struct_field_type_via_pipeline(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_emit_struct_field_type(arena, out, type_ref, struct_prefix, struct_prefix_len);
}
int32_t codegen_lookup_struct_field_type_ref(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * struct_name, int32_t struct_name_len, uint8_t * field_name, int32_t field_name_len) {
  {
    if (((((struct_name ==0) || (struct_name_len <=0)) || (field_name ==0)) || (field_name_len <=0))) {
      return 0;
    }
    int32_t bare_off = 0;
    int32_t bi = 0;
    while (((bi < struct_name_len) && (bi < 64))) {
      if (((struct_name)[bi] ==46)) {
        (void)((bare_off = (bi + 1)));
      }
      (void)((bi = (bi + 1)));
    }
    int32_t bare_len = (struct_name_len - bare_off);
    if ((bare_len <=0)) {
      return 0;
    }
    int32_t flen_use = field_name_len;
    if ((flen_use > 127)) {
      (void)((flen_use = 127));
    }
    struct ast_Module * try_mod = 0;
    int32_t pass = 0;
    while ((pass < 2)) {
      int32_t nmod = 1;
      if ((pass ==1)) {
        if ((ctx ==0)) {
          break;
        }
        (void)((nmod = pipeline_dep_ctx_ndep(ctx)));
      }
      int32_t mi = 0;
      while ((mi < nmod)) {
        if ((pass ==0)) {
          if (((ctx ==0) || (((ctx)->current_codegen_module) ==0))) {
            (void)((mi = (mi + 1)));
            continue;
          }
          (void)((try_mod = ((ctx)->current_codegen_module)));
        } else {
          (void)((try_mod = pipeline_dep_ctx_module_at(ctx, mi)));
        }
        if ((try_mod !=0)) {
          int32_t k = 0;
          while ((k < ((try_mod)->num_struct_layouts))) {
            int32_t snl = pipeline_module_struct_layout_name_len(try_mod, k);
            if (((snl ==bare_len) && (snl > 0))) {
              uint8_t snm[128] = {};
              (void)(pipeline_module_struct_layout_name_into(try_mod, k, &((snm)[0])));
              int eq = 1;
              int32_t sj = 0;
              while (((sj < snl) && (sj < 64))) {
                if (((snm)[sj] !=(struct_name)[(bare_off + sj)])) {
                  (void)((eq = 0));
                  break;
                }
                (void)((sj = (sj + 1)));
              }
              if (eq) {
                int32_t nf = pipeline_module_struct_layout_num_fields(try_mod, k);
                int32_t j = 0;
                while ((j < nf)) {
                  int32_t fnl = pipeline_module_struct_layout_field_name_len(try_mod, k, j);
                  if (((fnl ==flen_use) && (fnl > 0))) {
                    uint8_t fnm[128] = {};
                    (void)(pipeline_module_struct_layout_field_name_into(try_mod, k, j, &((fnm)[0])));
                    int feq = 1;
                    int32_t fj = 0;
                    while (((fj < fnl) && (fj < 64))) {
                      if (((fnm)[fj] !=(field_name)[fj])) {
                        (void)((feq = 0));
                        break;
                      }
                      (void)((fj = (fj + 1)));
                    }
                    if (feq) {
                      return pipeline_module_struct_layout_field_type_ref(try_mod, k, j);
                    }
                  }
                  (void)((j = (j + 1)));
                }
              }
            }
            (void)((k = (k + 1)));
          }
        }
        (void)((mi = (mi + 1)));
        if ((pass ==0)) {
          break;
        }
      }
      (void)((pass = (pass + 1)));
    }
    return 0;
  }
}
int32_t codegen_should_skip_emit_struct_layout_for_abi_dup(uint8_t * name, int32_t name_len) {
  if (((name ==0) || (name_len <=0))) {
    return 0;
  }
  uint8_t nm_buffer[7] = {66, 117, 102, 102, 101, 114, 0};
  uint8_t nm_completion[11] = {67, 111, 109, 112, 108, 101, 116, 105, 111, 110, 0};
  uint8_t nm_async_ctx[13] = {65, 115, 121, 110, 99, 67, 111, 110, 116, 101, 120, 116, 0};
  uint8_t nm_error[6] = {69, 114, 114, 111, 114, 0};
  uint8_t nm_error_chain[11] = {69, 114, 114, 111, 114, 67, 104, 97, 105, 110, 0};
  uint8_t nm_option_us[8] = {79, 112, 116, 105, 111, 110, 95, 0};
  uint8_t nm_option[7] = {79, 112, 116, 105, 111, 110, 0};
  uint8_t nm_result_i32[11] = {82, 101, 115, 117, 108, 116, 95, 105, 51, 50, 0};
  uint8_t nm_result_u8[10] = {82, 101, 115, 117, 108, 116, 95, 117, 56, 0};
  uint8_t nm_string[7] = {83, 116, 114, 105, 110, 103, 0};
  uint8_t nm_str_view[8] = {83, 116, 114, 86, 105, 101, 119, 0};
  uint8_t nm_tcp_stream[10] = {84, 99, 112, 83, 116, 114, 101, 97, 109, 0};
  uint8_t nm_tcp_listener[12] = {84, 99, 112, 76, 105, 115, 116, 101, 110, 101, 114, 0};
  uint8_t nm_udp_socket[10] = {85, 100, 112, 83, 111, 99, 107, 101, 116, 0};
  uint8_t nm_ipv4[9] = {73, 112, 118, 52, 65, 100, 100, 114, 0};
  uint8_t nm_ipv6[9] = {73, 112, 118, 54, 65, 100, 100, 114, 0};
  uint8_t nm_sock_v4[13] = {83, 111, 99, 107, 101, 116, 65, 100, 100, 114, 86, 52, 0};
  if (((name_len ==6) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_buffer)[0]), 6) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_completion)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len ==12) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_async_ctx)[0]), 12) !=0))) {
    return 1;
  }
  if (((name_len ==5) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_error)[0]), 5) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_error_chain)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len > 7) && (codegen_symbuf_bytes_eq(name, 7, &((nm_option_us)[0]), 7) !=0))) {
    return 1;
  }
  if (((name_len ==6) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_option)[0]), 6) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_result_i32)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_result_u8)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==6) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_string)[0]), 6) !=0))) {
    return 1;
  }
  if (((name_len ==7) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_str_view)[0]), 7) !=0))) {
    return 1;
  }
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_tcp_stream)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==11) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_tcp_listener)[0]), 11) !=0))) {
    return 1;
  }
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_udp_socket)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==8) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_ipv4)[0]), 8) !=0))) {
    return 1;
  }
  if (((name_len ==8) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_ipv6)[0]), 8) !=0))) {
    return 1;
  }
  if (((name_len ==12) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_sock_v4)[0]), 12) !=0))) {
    return 1;
  }
  uint8_t nm_allocator[10] = {65, 108, 108, 111, 99, 97, 116, 111, 114, 0};
  uint8_t nm_arena64[8] = {65, 114, 101, 110, 97, 54, 52, 0};
  uint8_t nm_fs_iovec[11] = {70, 115, 73, 111, 118, 101, 99, 66, 117, 102, 0};
  uint8_t nm_iovec[6] = {73, 111, 118, 101, 99, 0};
  if (((name_len ==9) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_allocator)[0]), 9) !=0))) {
    return 1;
  }
  if (((name_len ==7) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_arena64)[0]), 7) !=0))) {
    return 1;
  }
  if (((name_len ==10) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_fs_iovec)[0]), 10) !=0))) {
    return 1;
  }
  if (((name_len ==5) && (codegen_symbuf_bytes_eq(name, name_len, &((nm_iovec)[0]), 5) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_type_is_module_user_struct(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[128] = {};
    if ((((module ==0) || (arena ==0)) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t k = 0;
    while ((k < ((module)->num_struct_layouts))) {
      int32_t nl = pipeline_module_struct_layout_name_len(module, k);
      if ((nl ==name_len)) {
        uint8_t lay_nm[128] = {};
        (void)(pipeline_module_struct_layout_name_into(module, k, &((lay_nm)[0])));
        int eq = 1;
        int32_t j = 0;
        while (((j < nl) && (j < 64))) {
          if (((lay_nm)[j] !=(ty_nm)[j])) {
            (void)((eq = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (eq) {
          return 1;
        }
      }
      (void)((k = (k + 1)));
    }
    return 0;
  }
}
int32_t codegen_type_is_module_user_enum(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[128] = {};
    if ((((module ==0) || (arena ==0)) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t ei = 0;
    while ((ei < ((module)->num_module_enums))) {
      int32_t enl = pipeline_module_enum_name_len(module, ei);
      if ((enl ==name_len)) {
        int eq = 1;
        int32_t j = 0;
        while (((j < name_len) && (j < 64))) {
          if ((pipeline_module_enum_name_byte_at(module, ei, j) !=(ty_nm)[j])) {
            (void)((eq = 0));
            break;
          }
          (void)((j = (j + 1)));
        }
        if (eq) {
          return 1;
        }
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
}
int32_t codegen_type_dep_enum_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap) {
  {
    int32_t name_len = 0;
    uint8_t ty_nm[128] = {};
    int32_t di = 0;
    if ((((((ctx ==0) || (arena ==0)) || (dst ==0)) || (dst_cap <=0)) || ast_ref_is_null(type_ref))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    (void)((name_len = pipeline_type_named_name_into(arena, type_ref, &((ty_nm)[0]))));
    if ((name_len <=0)) {
      return 0;
    }
    int32_t bare_off = 0;
    int32_t bi = 0;
    while (((bi < name_len) && (bi < 64))) {
      if (((ty_nm)[bi] ==46)) {
        (void)((bare_off = (bi + 1)));
      }
      (void)((bi = (bi + 1)));
    }
    int32_t bare_len = (name_len - bare_off);
    (void)((di = 0));
    while ((di < pipeline_dep_ctx_ndep(ctx))) {
      struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
      if ((dep_mod !=0)) {
        int32_t ei = 0;
        while ((ei < ((dep_mod)->num_module_enums))) {
          int32_t dep_name_len = pipeline_module_enum_name_len(dep_mod, ei);
          if ((dep_name_len ==bare_len)) {
            int eq = 1;
            int32_t j = 0;
            while (((j < bare_len) && (j < 64))) {
              if ((pipeline_module_enum_name_byte_at(dep_mod, ei, j) !=(ty_nm)[(bare_off + j)])) {
                (void)((eq = 0));
                break;
              }
              (void)((j = (j + 1)));
            }
            if (eq) {
              uint8_t dep_path[128] = {};
              int32_t plen = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
              if ((plen > 0)) {
                (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), dst, dst_cap));
                int32_t out_len = 0;
                while (((out_len < dst_cap) && ((dst)[out_len] !=0))) {
                  (void)((out_len = (out_len + 1)));
                }
                return out_len;
              }
            }
          }
          (void)((ei = (ei + 1)));
        }
      }
      (void)((di = (di + 1)));
    }
    return 0;
  }
}
int32_t codegen_type_ref_is_host_concrete(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty) {
  {
    if ((((module ==0) || (arena ==0)) || (ty <=0))) {
      return 0;
    }
    int32_t k = pipeline_type_kind_ord_at(arena, ty);
    if ((k !=8)) {
      return 1;
    }
    uint8_t nm[128] = {};
    int32_t nl = pipeline_type_named_name_into(arena, ty, &((nm)[0]));
    if ((nl <=0)) {
      return 0;
    }
    int32_t sk = 0;
    while ((sk < ((module)->num_struct_layouts))) {
      int32_t sl = pipeline_module_struct_layout_name_len(module, sk);
      if ((sl ==nl)) {
        uint8_t snm[128] = {};
        (void)(pipeline_module_struct_layout_name_into(module, sk, &((snm)[0])));
        int32_t bi = 0;
        int32_t name_eq = 1;
        while ((bi < nl)) {
          if (((snm)[bi] !=(nm)[bi])) {
            (void)((name_eq = 0));
          }
          (void)((bi = (bi + 1)));
        }
        if ((name_eq !=0)) {
          int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, sk);
          if ((ntp <=0)) {
            return 1;
          }
          int32_t ai = 0;
          while (((ai < ntp) && (ai < 4))) {
            int32_t arg = pipeline_type_type_arg_ref_at(arena, ty, ai);
            if (((arg <=0) && (ai ==0))) {
              (void)((arg = pipeline_type_elem_ref_at(arena, ty)));
            }
            if ((arg <=0)) {
              return 0;
            }
            if ((codegen_type_ref_is_host_concrete(module, arena, arg) ==0)) {
              return 0;
            }
            (void)((ai = (ai + 1)));
          }
          return 1;
        }
      }
      (void)((sk = (sk + 1)));
    }
    return 0;
  }
}
int32_t codegen_resolve_generic_struct_field_type(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * layout_nm, int32_t layout_nl, uint8_t * field_nm, int32_t field_nl, int32_t ftr) {
  {
    if ((((module ==0) || (arena ==0)) || (ftr <=0))) {
      return ftr;
    }
    if (((((layout_nm ==0) || (layout_nl <=0)) || (field_nm ==0)) || (field_nl <=0))) {
      return ftr;
    }
    if ((pipeline_type_kind_ord_at(arena, ftr) !=8)) {
      return ftr;
    }
    uint8_t ftn[128] = {};
    int32_t ftnl = pipeline_type_named_name_into(arena, ftr, &((ftn)[0]));
    if ((ftnl <=0)) {
      return ftr;
    }
    int32_t sk = 0;
    while ((sk < ((module)->num_struct_layouts))) {
      int32_t sl = pipeline_module_struct_layout_name_len(module, sk);
      if ((sl ==ftnl)) {
        uint8_t snm[128] = {};
        (void)(pipeline_module_struct_layout_name_into(module, sk, &((snm)[0])));
        int32_t bi = 0;
        int32_t name_eq = 1;
        while ((bi < ftnl)) {
          if (((snm)[bi] !=(ftn)[bi])) {
            (void)((name_eq = 0));
          }
          (void)((bi = (bi + 1)));
        }
        if ((name_eq !=0)) {
          return ftr;
        }
      }
      (void)((sk = (sk + 1)));
    }
    int32_t tp_slot = 0;
    (void)((sk = 0));
    while ((sk < ((module)->num_struct_layouts))) {
      int32_t sl2 = pipeline_module_struct_layout_name_len(module, sk);
      if (((sl2 ==layout_nl) && (layout_nl > 0))) {
        uint8_t snm2[128] = {};
        (void)(pipeline_module_struct_layout_name_into(module, sk, &((snm2)[0])));
        int32_t eq2 = 1;
        int32_t bi2 = 0;
        while ((bi2 < layout_nl)) {
          if (((snm2)[bi2] !=(layout_nm)[bi2])) {
            (void)((eq2 = 0));
          }
          (void)((bi2 = (bi2 + 1)));
        }
        if ((eq2 !=0)) {
          int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, sk);
          if ((ntp > 0)) {
            (void)((tp_slot = -1));
            int32_t tj = 0;
            while ((tj < ntp)) {
              int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, sk, tj);
              if ((tpl ==ftnl)) {
                uint8_t tpn[128] = {};
                (void)(pipeline_module_struct_layout_type_param_name_into(module, sk, tj, &((tpn)[0])));
                int32_t peq = 1;
                int32_t pi = 0;
                while ((pi < ftnl)) {
                  if (((tpn)[pi] !=(ftn)[pi])) {
                    (void)((peq = 0));
                  }
                  (void)((pi = (pi + 1)));
                }
                if ((peq !=0)) {
                  (void)((tp_slot = tj));
                  (void)((tj = ntp));
                }
              }
              (void)((tj = (tj + 1)));
            }
            if ((tp_slot < 0)) {
              return ftr;
            }
          }
          (void)((sk = ((module)->num_struct_layouts)));
        }
      }
      (void)((sk = (sk + 1)));
    }
    int32_t ti = 1;
    while ((ti <=((arena)->num_types))) {
      if ((pipeline_type_kind_ord_at(arena, ti) ==8)) {
        uint8_t tnm[128] = {};
        int32_t tnl = pipeline_type_named_name_into(arena, ti, &((tnm)[0]));
        if (((tnl ==layout_nl) && (tnl > 0))) {
          int32_t eq = 1;
          int32_t ci = 0;
          while ((ci < tnl)) {
            if (((tnm)[ci] !=(layout_nm)[ci])) {
              (void)((eq = 0));
            }
            (void)((ci = (ci + 1)));
          }
          if ((eq !=0)) {
            int32_t mono = pipeline_type_type_arg_ref_at(arena, ti, tp_slot);
            if ((mono <=0)) {
              if ((tp_slot ==0)) {
                (void)((mono = pipeline_type_elem_ref_at(arena, ti)));
              }
            }
            if (((mono > 0) && (codegen_type_ref_is_host_concrete(module, arena, mono) !=0))) {
              return mono;
            }
          }
        }
      }
      (void)((ti = (ti + 1)));
    }
    int32_t ei = 1;
    while ((ei <=((arena)->num_exprs))) {
      if ((pipeline_expr_kind_ord_at(arena, ei) ==45)) {
        struct ast_Expr e = ast_ast_arena_expr_get(arena, ei);
        if (((((e).struct_lit_struct_name_len) ==layout_nl) && (layout_nl > 0))) {
          int32_t seq = 1;
          int32_t si = 0;
          while ((si < layout_nl)) {
            if (((((e).struct_lit_struct_name))[si] !=(layout_nm)[si])) {
              (void)((seq = 0));
            }
            (void)((si = (si + 1)));
          }
          if ((seq !=0)) {
            int32_t nf = pipeline_expr_struct_lit_num_fields(arena, ei);
            int32_t fj = 0;
            while ((fj < nf)) {
              int32_t fl = pipeline_expr_struct_lit_field_name_len(arena, ei, fj);
              if ((fl ==field_nl)) {
                uint8_t fnb[128] = {};
                (void)(pipeline_expr_struct_lit_field_name_into(arena, ei, fj, &((fnb)[0])));
                int32_t feq = 1;
                int32_t fi = 0;
                while ((fi < fl)) {
                  if (((fnb)[fi] !=(field_nm)[fi])) {
                    (void)((feq = 0));
                  }
                  (void)((fi = (fi + 1)));
                }
                if ((feq !=0)) {
                  int32_t iref = pipeline_expr_struct_lit_init_ref(arena, ei, fj);
                  if ((iref > 0)) {
                    int32_t ity = pipeline_expr_resolved_type_ref(arena, iref);
                    if (((ity > 0) && (codegen_type_ref_is_host_concrete(module, arena, ity) !=0))) {
                      return ity;
                    }
                  }
                }
              }
              (void)((fj = (fj + 1)));
            }
          }
        }
      }
      (void)((ei = (ei + 1)));
    }
    return ftr;
  }
}
int32_t codegen_module_struct_layout_index_by_name(struct ast_Module * module, uint8_t * layout_nm, int32_t layout_nl) {
  {
    if ((((module ==0) || (layout_nm ==0)) || (layout_nl <=0))) {
      return -1;
    }
    int32_t sk = 0;
    while ((sk < ((module)->num_struct_layouts))) {
      int32_t sl = pipeline_module_struct_layout_name_len(module, sk);
      if ((sl ==layout_nl)) {
        uint8_t snm[128] = {};
        (void)(pipeline_module_struct_layout_name_into(module, sk, &((snm)[0])));
        int32_t eq = 1;
        int32_t bi = 0;
        while ((bi < layout_nl)) {
          if (((snm)[bi] !=(layout_nm)[bi])) {
            (void)((eq = 0));
          }
          (void)((bi = (bi + 1)));
        }
        if ((eq !=0)) {
          return sk;
        }
      }
      (void)((sk = (sk + 1)));
    }
    return -1;
  }
}
int32_t codegen_generic_struct_resolve_arg_via_ctx(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t ty) {
  {
    if ((((module ==0) || (arena ==0)) || (ty <=0))) {
      return 0;
    }
    if ((codegen_type_ref_is_host_concrete(module, arena, ty) !=0)) {
      return ty;
    }
    if ((((ctx ==0) || (((ctx)->mono_active) ==0)) || (((ctx)->mono_num_types) <=0))) {
      return 0;
    }
    int32_t mi = 0;
    while (((mi < ((ctx)->mono_num_types)) && (mi < 8))) {
      int32_t gen = (((ctx)->mono_generic_type_refs))[mi];
      int32_t conc = (((ctx)->mono_concrete_type_refs))[mi];
      if (((((gen > 0) && (conc > 0)) && (conc !=ty)) && (ty ==gen))) {
        if ((codegen_type_ref_is_host_concrete(module, arena, conc) !=0)) {
          return conc;
        }
      }
      (void)((mi = (mi + 1)));
    }
    uint8_t fb_nm[128] = {};
    int32_t fb_len = pipeline_type_named_name_into(arena, ty, &((fb_nm)[0]));
    if ((fb_len <=0)) {
      return 0;
    }
    (void)((mi = 0));
    while (((mi < ((ctx)->mono_num_types)) && (mi < 8))) {
      int32_t gen2 = (((ctx)->mono_generic_type_refs))[mi];
      int32_t conc2 = (((ctx)->mono_concrete_type_refs))[mi];
      if ((((gen2 > 0) && (conc2 > 0)) && (conc2 !=ty))) {
        uint8_t gnm[128] = {};
        int32_t gnl = pipeline_type_named_name_into(arena, gen2, &((gnm)[0]));
        if (((gnl ==fb_len) && (gnl > 0))) {
          int32_t eq = 1;
          int32_t bi = 0;
          while ((bi < gnl)) {
            if (((gnm)[bi] !=(fb_nm)[bi])) {
              (void)((eq = 0));
            }
            (void)((bi = (bi + 1)));
          }
          if (((eq !=0) && (codegen_type_ref_is_host_concrete(module, arena, conc2) !=0))) {
            return conc2;
          }
        }
      }
      (void)((mi = (mi + 1)));
    }
    return 0;
  }
}
int32_t codegen_generic_struct_resolve_arg_via_map(struct ast_Module * module, struct ast_ASTArena * arena, int32_t ty, int32_t * mono_gen, int32_t * mono_conc, int32_t nmono) {
  {
    if (((((((module ==0) || (arena ==0)) || (ty <=0)) || (mono_gen ==0)) || (mono_conc ==0)) || (nmono <=0))) {
      return 0;
    }
    if ((codegen_type_ref_is_host_concrete(module, arena, ty) !=0)) {
      return ty;
    }
    int32_t mi = 0;
    while (((mi < nmono) && (mi < 8))) {
      if ((((((mono_gen)[mi] > 0) && ((mono_conc)[mi] > 0)) && ((mono_conc)[mi] !=ty)) && (ty ==(mono_gen)[mi]))) {
        if ((codegen_type_ref_is_host_concrete(module, arena, (mono_conc)[mi]) !=0)) {
          return (mono_conc)[mi];
        }
      }
      (void)((mi = (mi + 1)));
    }
    uint8_t fb_nm[128] = {};
    int32_t fb_len = pipeline_type_named_name_into(arena, ty, &((fb_nm)[0]));
    if ((fb_len <=0)) {
      return 0;
    }
    (void)((mi = 0));
    while (((mi < nmono) && (mi < 8))) {
      if (((((mono_gen)[mi] > 0) && ((mono_conc)[mi] > 0)) && ((mono_conc)[mi] !=ty))) {
        uint8_t gnm[128] = {};
        int32_t gnl = pipeline_type_named_name_into(arena, (mono_gen)[mi], &((gnm)[0]));
        if (((gnl ==fb_len) && (gnl > 0))) {
          int32_t eq = 1;
          int32_t bi = 0;
          while ((bi < gnl)) {
            if (((gnm)[bi] !=(fb_nm)[bi])) {
              (void)((eq = 0));
            }
            (void)((bi = (bi + 1)));
          }
          if (((eq !=0) && (codegen_type_ref_is_host_concrete(module, arena, (mono_conc)[mi]) !=0))) {
            return (mono_conc)[mi];
          }
        }
      }
      (void)((mi = (mi + 1)));
    }
    return 0;
  }
}
int32_t codegen_generic_struct_fill_concrete_args(struct ast_Module * module, struct ast_ASTArena * arena, int32_t type_ref, int32_t ntp, int32_t * mono_out, struct ast_PipelineDepCtx * ctx) {
  {
    if (((((module ==0) || (arena ==0)) || (type_ref <=0)) || (mono_out ==0))) {
      return 0;
    }
    if (((ntp <=0) || (ntp > 4))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    int32_t si = 0;
    while ((si < ntp)) {
      int32_t mono = pipeline_type_type_arg_ref_at(arena, type_ref, si);
      if (((mono <=0) && (si ==0))) {
        (void)((mono = pipeline_type_elem_ref_at(arena, type_ref)));
      }
      if (((mono > 0) && (codegen_type_ref_is_host_concrete(module, arena, mono) ==0))) {
        (void)((mono = codegen_generic_struct_resolve_arg_via_ctx(module, arena, ctx, mono)));
      }
      if (((mono <=0) || (codegen_type_ref_is_host_concrete(module, arena, mono) ==0))) {
        return 0;
      }
      (void)(((mono_out)[si] = mono));
      (void)((si = (si + 1)));
    }
    return ntp;
  }
}
int32_t codegen_generic_struct_mangled_name_into(struct ast_ASTArena * arena, uint8_t * layout_nm, int32_t layout_nl, int32_t * mono_tys, int32_t ntp, uint8_t * out_nm, int32_t out_cap) {
  {
    if ((((((arena ==0) || (layout_nm ==0)) || (layout_nl <=0)) || (mono_tys ==0)) || (out_nm ==0))) {
      return 0;
    }
    if (((ntp <=0) || (out_cap <=(layout_nl + 2)))) {
      return 0;
    }
    int32_t o = 0;
    int32_t bi = 0;
    while (((bi < layout_nl) && (o < out_cap))) {
      (void)(((out_nm)[o] = (layout_nm)[bi]));
      (void)((o = (o + 1)));
      (void)((bi = (bi + 1)));
    }
    if (((o + 2) >=out_cap)) {
      return 0;
    }
    (void)(((out_nm)[o] = 95));
    (void)((o = (o + 1)));
    (void)(((out_nm)[o] = 95));
    (void)((o = (o + 1)));
    int32_t mi = 0;
    while ((mi < ntp)) {
      if ((mi > 0)) {
        if ((o >=out_cap)) {
          return 0;
        }
        (void)(((out_nm)[o] = 95));
        (void)((o = (o + 1)));
      }
      uint8_t suf[128] = {};
      int32_t sl = codegen_type_ref_to_suffix(arena, (mono_tys)[mi], &((suf)[0]), 64);
      if ((sl <=0)) {
        return 0;
      }
      int32_t si = 0;
      while ((si < sl)) {
        if ((o >=out_cap)) {
          return 0;
        }
        (void)(((out_nm)[o] = (suf)[si]));
        (void)((o = (o + 1)));
        (void)((si = (si + 1)));
      }
      (void)((mi = (mi + 1)));
    }
    return o;
  }
}
int32_t codegen_mono_suffix_bytes_from_init(struct ast_ASTArena * arena, struct ast_Module * module, int32_t init_ref, uint8_t * buf, int32_t buf_cap, struct ast_PipelineDepCtx * ctx) {
  {
    if ((((((arena ==0) || (module ==0)) || (init_ref <=0)) || (buf ==0)) || (buf_cap <=0))) {
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, init_ref) ==45)) {
      struct ast_Expr e = ast_ast_arena_expr_get(arena, init_ref);
      int32_t nl = ((e).struct_lit_struct_name_len);
      if (((nl <=0) || (nl >=buf_cap))) {
        return 0;
      }
      int32_t pos = 0;
      int32_t i = 0;
      while ((i < nl)) {
        (void)(((buf)[pos] = (((e).struct_lit_struct_name))[i]));
        (void)((pos = (pos + 1)));
        (void)((i = (i + 1)));
      }
      int32_t lk = codegen_module_struct_layout_index_by_name(module, &((((e).struct_lit_struct_name))[0]), nl);
      if ((lk < 0)) {
        return pos;
      }
      int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if ((ntp <=0)) {
        return pos;
      }
      int32_t tj = 0;
      while (((tj < ntp) && (tj < 4))) {
        int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
        uint8_t tpn[128] = {};
        (void)(pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &((tpn)[0])));
        int32_t found = 0;
        int32_t nf = pipeline_module_struct_layout_num_fields(module, lk);
        int32_t fj = 0;
        while ((fj < nf)) {
          int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, lk, fj);
          if ((pipeline_type_kind_ord_at(arena, ftr) ==8)) {
            uint8_t ftn[128] = {};
            int32_t ftnl = pipeline_type_named_name_into(arena, ftr, &((ftn)[0]));
            if (((ftnl ==tpl) && (ftnl > 0))) {
              int32_t peq = 1;
              int32_t pi = 0;
              while ((pi < ftnl)) {
                if (((ftn)[pi] !=(tpn)[pi])) {
                  (void)((peq = 0));
                }
                (void)((pi = (pi + 1)));
              }
              if ((peq !=0)) {
                int32_t flen = pipeline_module_struct_layout_field_name_len(module, lk, fj);
                uint8_t fnm[128] = {};
                (void)(pipeline_module_struct_layout_field_name_into(module, lk, fj, &((fnm)[0])));
                int32_t lit_nf = pipeline_expr_struct_lit_num_fields(arena, init_ref);
                int32_t li = 0;
                while ((li < lit_nf)) {
                  int32_t lfl = pipeline_expr_struct_lit_field_name_len(arena, init_ref, li);
                  if (((lfl ==flen) && (flen > 0))) {
                    uint8_t lfn[128] = {};
                    (void)(pipeline_expr_struct_lit_field_name_into(arena, init_ref, li, &((lfn)[0])));
                    int32_t feq = 1;
                    int32_t fi = 0;
                    while ((fi < flen)) {
                      if (((lfn)[fi] !=(fnm)[fi])) {
                        (void)((feq = 0));
                      }
                      (void)((fi = (fi + 1)));
                    }
                    if ((feq !=0)) {
                      int32_t iref = pipeline_expr_struct_lit_init_ref(arena, init_ref, li);
                      uint8_t asuf[128] = {};
                      int32_t al = codegen_mono_suffix_bytes_from_init(arena, module, iref, &((asuf)[0]), 64, ctx);
                      if (((((al <=0) && (ctx !=0)) && (((ctx)->mono_active) !=0)) && (((ctx)->mono_num_types) > 0))) {
                        int32_t mi_f = 0;
                        while (((mi_f < ((ctx)->mono_num_types)) && (mi_f < 8))) {
                          int32_t gtr_f = (((ctx)->mono_generic_type_refs))[mi_f];
                          int32_t ctr_f = (((ctx)->mono_concrete_type_refs))[mi_f];
                          if (((gtr_f > 0) && (ctr_f > 0))) {
                            uint8_t gnm_f[128] = {};
                            int32_t gnl_f = pipeline_type_named_name_into(arena, gtr_f, &((gnm_f)[0]));
                            if (((gnl_f ==tpl) && (gnl_f > 0))) {
                              int32_t geq_f = 1;
                              int32_t gi_f = 0;
                              while ((gi_f < gnl_f)) {
                                if (((gnm_f)[gi_f] !=(tpn)[gi_f])) {
                                  (void)((geq_f = 0));
                                }
                                (void)((gi_f = (gi_f + 1)));
                              }
                              if (((geq_f !=0) && (codegen_type_ref_is_host_concrete(module, arena, ctr_f) !=0))) {
                                (void)((al = codegen_type_ref_to_suffix(arena, ctr_f, &((asuf)[0]), 64)));
                                (void)((mi_f = ((ctx)->mono_num_types)));
                              }
                            }
                          }
                          (void)((mi_f = (mi_f + 1)));
                        }
                      }
                      if (((al <=0) || (((pos + 1) + al) >=buf_cap))) {
                        return 0;
                      }
                      (void)(((buf)[pos] = 95));
                      (void)((pos = (pos + 1)));
                      int32_t aj = 0;
                      while ((aj < al)) {
                        (void)(((buf)[pos] = (asuf)[aj]));
                        (void)((pos = (pos + 1)));
                        (void)((aj = (aj + 1)));
                      }
                      (void)((found = 1));
                      (void)((li = lit_nf));
                      (void)((fj = nf));
                    }
                  }
                  (void)((li = (li + 1)));
                }
              }
            }
          }
          (void)((fj = (fj + 1)));
        }
        if ((found ==0)) {
          return 0;
        }
        (void)((tj = (tj + 1)));
      }
      return pos;
    }
    int32_t rty = pipeline_expr_resolved_type_ref(arena, init_ref);
    if ((rty <=0)) {
      if (((pipeline_expr_kind_ord_at(arena, init_ref) ==0) && (buf_cap > 3))) {
        (void)(((buf)[0] = 105));
        (void)(((buf)[1] = 51));
        (void)(((buf)[2] = 50));
        return 3;
      }
      return 0;
    }
    int32_t mapped = codegen_generic_struct_resolve_arg_via_ctx(module, arena, ctx, rty);
    if ((mapped > 0)) {
      (void)((rty = mapped));
    }
    return codegen_type_ref_to_suffix(arena, rty, buf, buf_cap);
  }
}
int32_t codegen_try_emit_struct_lit_mono_from_fields(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, uint8_t * layout_nm, int32_t layout_nl, struct ast_PipelineDepCtx * ctx) {
  {
    if (((((module ==0) || (arena ==0)) || (out ==0)) || (expr_ref <=0))) {
      return 0;
    }
    if (((layout_nm ==0) || (layout_nl <=0))) {
      return 0;
    }
    int32_t lk = codegen_module_struct_layout_index_by_name(module, layout_nm, layout_nl);
    if ((lk < 0)) {
      return 0;
    }
    int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, lk);
    if (((ntp <=0) || (ntp > 4))) {
      return 0;
    }
    int32_t tj = 0;
    while ((tj < ntp)) {
      uint8_t asuf[128] = {};
      int32_t al = 0;
      int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
      uint8_t tpn[128] = {};
      (void)(pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &((tpn)[0])));
      int32_t found = 0;
      int32_t nf = pipeline_module_struct_layout_num_fields(module, lk);
      int32_t fj = 0;
      while ((fj < nf)) {
        int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, lk, fj);
        if ((pipeline_type_kind_ord_at(arena, ftr) ==8)) {
          uint8_t ftn[128] = {};
          int32_t ftnl = pipeline_type_named_name_into(arena, ftr, &((ftn)[0]));
          if (((ftnl ==tpl) && (ftnl > 0))) {
            int32_t peq = 1;
            int32_t pi = 0;
            while ((pi < ftnl)) {
              if (((ftn)[pi] !=(tpn)[pi])) {
                (void)((peq = 0));
              }
              (void)((pi = (pi + 1)));
            }
            if ((peq !=0)) {
              int32_t flen = pipeline_module_struct_layout_field_name_len(module, lk, fj);
              uint8_t fnm[128] = {};
              (void)(pipeline_module_struct_layout_field_name_into(module, lk, fj, &((fnm)[0])));
              int32_t lit_nf = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
              int32_t li = 0;
              while ((li < lit_nf)) {
                int32_t lfl = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, li);
                if (((lfl ==flen) && (flen > 0))) {
                  uint8_t lfn[128] = {};
                  (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, li, &((lfn)[0])));
                  int32_t feq = 1;
                  int32_t fi = 0;
                  while ((fi < flen)) {
                    if (((lfn)[fi] !=(fnm)[fi])) {
                      (void)((feq = 0));
                    }
                    (void)((fi = (fi + 1)));
                  }
                  if ((feq !=0)) {
                    int32_t iref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, li);
                    (void)((al = codegen_mono_suffix_bytes_from_init(arena, module, iref, &((asuf)[0]), 64, ctx)));
                    if ((al <=0)) {
                      return 0;
                    }
                    (void)((found = 1));
                    (void)((li = lit_nf));
                    (void)((fj = nf));
                  }
                }
                (void)((li = (li + 1)));
              }
            }
          }
        }
        (void)((fj = (fj + 1)));
      }
      if ((found ==0)) {
        return 0;
      }
      (void)((tj = (tj + 1)));
    }
    uint8_t sep[2] = {95, 95};
    if ((codegen_emit_bytes_from_ptr(out, &((sep)[0]), 2) !=0)) {
      return -1;
    }
    int32_t first = 1;
    (void)((tj = 0));
    while ((tj < ntp)) {
      int32_t tpl2 = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
      uint8_t tpn2[128] = {};
      (void)(pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &((tpn2)[0])));
      int32_t done = 0;
      int32_t nf2 = pipeline_module_struct_layout_num_fields(module, lk);
      int32_t fj2 = 0;
      while ((fj2 < nf2)) {
        int32_t ftr2 = pipeline_module_struct_layout_field_type_ref(module, lk, fj2);
        if ((pipeline_type_kind_ord_at(arena, ftr2) ==8)) {
          uint8_t ftn2[128] = {};
          int32_t ftnl2 = pipeline_type_named_name_into(arena, ftr2, &((ftn2)[0]));
          if (((ftnl2 ==tpl2) && (ftnl2 > 0))) {
            int32_t peq2 = 1;
            int32_t pi2 = 0;
            while ((pi2 < ftnl2)) {
              if (((ftn2)[pi2] !=(tpn2)[pi2])) {
                (void)((peq2 = 0));
              }
              (void)((pi2 = (pi2 + 1)));
            }
            if ((peq2 !=0)) {
              int32_t flen2 = pipeline_module_struct_layout_field_name_len(module, lk, fj2);
              uint8_t fnm2[128] = {};
              (void)(pipeline_module_struct_layout_field_name_into(module, lk, fj2, &((fnm2)[0])));
              int32_t lit_nf2 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
              int32_t li2 = 0;
              while ((li2 < lit_nf2)) {
                int32_t lfl2 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, li2);
                if (((lfl2 ==flen2) && (flen2 > 0))) {
                  uint8_t lfn2[128] = {};
                  (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, li2, &((lfn2)[0])));
                  int32_t feq2 = 1;
                  int32_t fi2 = 0;
                  while ((fi2 < flen2)) {
                    if (((lfn2)[fi2] !=(fnm2)[fi2])) {
                      (void)((feq2 = 0));
                    }
                    (void)((fi2 = (fi2 + 1)));
                  }
                  if ((feq2 !=0)) {
                    int32_t iref2 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, li2);
                    uint8_t asuf2[128] = {};
                    int32_t al2 = codegen_mono_suffix_bytes_from_init(arena, module, iref2, &((asuf2)[0]), 64, ctx);
                    if ((al2 <=0)) {
                      return -1;
                    }
                    if ((first ==0)) {
                      if ((codegen_append_byte(out, 95) !=0)) {
                        return -1;
                      }
                    }
                    (void)((first = 0));
                    if ((codegen_emit_bytes_from_ptr(out, &((asuf2)[0]), al2) !=0)) {
                      return -1;
                    }
                    (void)((done = 1));
                    (void)((li2 = lit_nf2));
                    (void)((fj2 = nf2));
                  }
                }
                (void)((li2 = (li2 + 1)));
              }
            }
          }
        }
        (void)((fj2 = (fj2 + 1)));
      }
      if ((done ==0)) {
        return -1;
      }
      (void)((tj = (tj + 1)));
    }
    return 1;
  }
}
int32_t codegen_emit_generic_struct_mono_suffix(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, int32_t * mono_tys, int32_t ntp) {
  {
    if (((((out ==0) || (arena ==0)) || (mono_tys ==0)) || (ntp <=0))) {
      return -1;
    }
    uint8_t sep[2] = {95, 95};
    if ((codegen_emit_bytes_from_ptr(out, &((sep)[0]), 2) !=0)) {
      return -1;
    }
    int32_t mi = 0;
    while ((mi < ntp)) {
      if ((mi > 0)) {
        if ((codegen_append_byte(out, 95) !=0)) {
          return -1;
        }
      }
      uint8_t suf[128] = {};
      int32_t sl = codegen_type_ref_to_suffix(arena, (mono_tys)[mi], &((suf)[0]), 64);
      if ((sl <=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((suf)[0]), sl) !=0)) {
        return -1;
      }
      (void)((mi = (mi + 1)));
    }
    return 0;
  }
}
int32_t codegen_generic_struct_field_type_from_mono(struct ast_Module * module, struct ast_ASTArena * arena, int32_t layout_k, int32_t ftr, int32_t * mono_tys, int32_t ntp) {
  {
    if ((((((module ==0) || (arena ==0)) || (ftr <=0)) || (mono_tys ==0)) || (ntp <=0))) {
      return ftr;
    }
    if ((pipeline_type_kind_ord_at(arena, ftr) !=8)) {
      return ftr;
    }
    uint8_t ftn[128] = {};
    int32_t ftnl = pipeline_type_named_name_into(arena, ftr, &((ftn)[0]));
    if ((ftnl <=0)) {
      return ftr;
    }
    int32_t tj = 0;
    while ((tj < ntp)) {
      int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, layout_k, tj);
      if ((tpl ==ftnl)) {
        uint8_t tpn[128] = {};
        (void)(pipeline_module_struct_layout_type_param_name_into(module, layout_k, tj, &((tpn)[0])));
        int32_t peq = 1;
        int32_t pi = 0;
        while ((pi < ftnl)) {
          if (((tpn)[pi] !=(ftn)[pi])) {
            (void)((peq = 0));
          }
          (void)((pi = (pi + 1)));
        }
        if (((peq !=0) && ((mono_tys)[tj] > 0))) {
          return (mono_tys)[tj];
        }
      }
      (void)((tj = (tj + 1)));
    }
    return ftr;
  }
}
int32_t codegen_type_refs_same_for_mono(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  {
    if (((a ==b) && (a > 0))) {
      return 1;
    }
    if ((((arena ==0) || (a <=0)) || (b <=0))) {
      return 0;
    }
    int32_t ka = pipeline_type_kind_ord_at(arena, a);
    int32_t kb = pipeline_type_kind_ord_at(arena, b);
    if ((ka !=kb)) {
      return 0;
    }
    if ((ka ==8)) {
      uint8_t nma[128] = {};
      uint8_t nmb[128] = {};
      int32_t nla = pipeline_type_named_name_into(arena, a, &((nma)[0]));
      int32_t nlb = pipeline_type_named_name_into(arena, b, &((nmb)[0]));
      if (((nla <=0) || (nla !=nlb))) {
        return 0;
      }
      int32_t ni = 0;
      while ((ni < nla)) {
        if (((nma)[ni] !=(nmb)[ni])) {
          return 0;
        }
        (void)((ni = (ni + 1)));
      }
      int32_t ai = 0;
      while ((ai < 4)) {
        int32_t aa = pipeline_type_type_arg_ref_at(arena, a, ai);
        int32_t bb = pipeline_type_type_arg_ref_at(arena, b, ai);
        if (((aa <=0) && (bb <=0))) {
          return 1;
        }
        if (((aa <=0) || (bb <=0))) {
          return 0;
        }
        if ((codegen_type_refs_same_for_mono(arena, aa, bb) ==0)) {
          return 0;
        }
        (void)((ai = (ai + 1)));
      }
      return 1;
    }
    if ((ka ==9)) {
      return codegen_type_refs_same_for_mono(arena, pipeline_type_elem_ref_at(arena, a), pipeline_type_elem_ref_at(arena, b));
    }
    return 1;
  }
}
int32_t codegen_type_ref_type_arg_nest_depth(struct ast_ASTArena * arena, int32_t ty) {
  {
    if (((arena ==0) || (ty <=0))) {
      return 0;
    }
    int32_t maxd = 0;
    int32_t ai = 0;
    while ((ai < 4)) {
      int32_t arg = pipeline_type_type_arg_ref_at(arena, ty, ai);
      if ((arg <=0)) {
        (void)((ai = 4));
      } else {
        int32_t d = (1 + codegen_type_ref_type_arg_nest_depth(arena, arg));
        if ((d > maxd)) {
          (void)((maxd = d));
        }
        (void)((ai = (ai + 1)));
      }
    }
    return maxd;
  }
}
int32_t codegen_generic_struct_combo_nest_depth(struct ast_ASTArena * arena, int32_t * mono_tys, int32_t ntp) {
  {
    if ((((arena ==0) || (mono_tys ==0)) || (ntp <=0))) {
      return 0;
    }
    int32_t maxd = 0;
    int32_t i = 0;
    while ((i < ntp)) {
      int32_t d = codegen_type_ref_type_arg_nest_depth(arena, (mono_tys)[i]);
      if ((d > maxd)) {
        (void)((maxd = d));
      }
      (void)((i = (i + 1)));
    }
    return maxd;
  }
}
void codegen_generic_struct_sort_mono_combos_by_depth(struct ast_ASTArena * arena, int32_t * combos, int32_t ncombo, int32_t ntp) {
  {
    if (((((arena ==0) || (combos ==0)) || (ncombo <=1)) || (ntp <=0))) {
      return;
    }
    int32_t i = 0;
    while ((i < ncombo)) {
      int32_t j = (i + 1);
      while ((j < ncombo)) {
        int32_t di = codegen_generic_struct_combo_nest_depth(arena, &((combos)[(i * ntp)]), ntp);
        int32_t dj = codegen_generic_struct_combo_nest_depth(arena, &((combos)[(j * ntp)]), ntp);
        if ((dj < di)) {
          int32_t s = 0;
          while ((s < ntp)) {
            int32_t tmp = (combos)[((i * ntp) + s)];
            (void)(((combos)[((i * ntp) + s)] = (combos)[((j * ntp) + s)]));
            (void)(((combos)[((j * ntp) + s)] = tmp));
            (void)((s = (s + 1)));
          }
        }
        (void)((j = (j + 1)));
      }
      (void)((i = (i + 1)));
    }
  }
}
int32_t codegen_collect_generic_struct_mono_combos(struct ast_Module * module, struct ast_ASTArena * arena, int32_t layout_k, uint8_t * layout_nm, int32_t layout_nl, int32_t ntp, int32_t * combos_out, int32_t max_combos) {
  {
    if (((((module ==0) || (arena ==0)) || (layout_nm ==0)) || (combos_out ==0))) {
      return 0;
    }
    if (((((ntp <=0) || (ntp > 4)) || (max_combos <=0)) || (layout_nl <=0))) {
      return 0;
    }
    int32_t combo_count = 0;
    int32_t ti = 1;
    while ((ti <=((arena)->num_types))) {
      if ((pipeline_type_kind_ord_at(arena, ti) ==8)) {
        uint8_t tnm[128] = {};
        int32_t tnl = pipeline_type_named_name_into(arena, ti, &((tnm)[0]));
        if (((tnl ==layout_nl) && (tnl > 0))) {
          int32_t eq = 1;
          int32_t ci = 0;
          while ((ci < tnl)) {
            if (((tnm)[ci] !=(layout_nm)[ci])) {
              (void)((eq = 0));
            }
            (void)((ci = (ci + 1)));
          }
          if ((eq !=0)) {
            int32_t combo[4] = {};
            if ((codegen_generic_struct_fill_concrete_args(module, arena, ti, ntp, &((combo)[0]), 0) ==ntp)) {
              int32_t found = 0;
              int32_t c0 = 0;
              while ((c0 < combo_count)) {
                int32_t same = 1;
                int32_t s0 = 0;
                while ((s0 < ntp)) {
                  int32_t ca = (combos_out)[((c0 * ntp) + s0)];
                  int32_t cb = (combo)[s0];
                  if ((codegen_type_refs_same_for_mono(arena, ca, cb) ==0)) {
                    (void)((same = 0));
                    (void)((s0 = ntp));
                  }
                  (void)((s0 = (s0 + 1)));
                }
                if ((same !=0)) {
                  (void)((found = 1));
                  (void)((c0 = combo_count));
                }
                (void)((c0 = (c0 + 1)));
              }
              if (((found ==0) && (combo_count < max_combos))) {
                int32_t s1 = 0;
                while ((s1 < ntp)) {
                  (void)(((combos_out)[((combo_count * ntp) + s1)] = (combo)[s1]));
                  (void)((s1 = (s1 + 1)));
                }
                (void)((combo_count = (combo_count + 1)));
              }
            }
          }
        }
      }
      (void)((ti = (ti + 1)));
    }
    int32_t ei = 1;
    while ((ei <=((arena)->num_exprs))) {
      if ((pipeline_expr_kind_ord_at(arena, ei) ==45)) {
        struct ast_Expr e = ast_ast_arena_expr_get(arena, ei);
        if (((((e).struct_lit_struct_name_len) ==layout_nl) && (layout_nl > 0))) {
          int32_t seq = 1;
          int32_t si = 0;
          while ((si < layout_nl)) {
            if (((((e).struct_lit_struct_name))[si] !=(layout_nm)[si])) {
              (void)((seq = 0));
            }
            (void)((si = (si + 1)));
          }
          if ((seq !=0)) {
            int32_t combo2[4] = {};
            int32_t filled = 0;
            int32_t ok = 1;
            int32_t tj = 0;
            while ((tj < ntp)) {
              (void)(((combo2)[tj] = 0));
              (void)((tj = (tj + 1)));
            }
            int32_t nf = pipeline_module_struct_layout_num_fields(module, layout_k);
            int32_t fj = 0;
            while ((fj < nf)) {
              int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, layout_k, fj);
              if ((pipeline_type_kind_ord_at(arena, ftr) ==8)) {
                uint8_t ftn[128] = {};
                int32_t ftnl = pipeline_type_named_name_into(arena, ftr, &((ftn)[0]));
                int32_t slot = -1;
                int32_t pj = 0;
                while ((pj < ntp)) {
                  int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, layout_k, pj);
                  if (((tpl ==ftnl) && (ftnl > 0))) {
                    uint8_t tpn[128] = {};
                    (void)(pipeline_module_struct_layout_type_param_name_into(module, layout_k, pj, &((tpn)[0])));
                    int32_t peq = 1;
                    int32_t pi = 0;
                    while ((pi < ftnl)) {
                      if (((tpn)[pi] !=(ftn)[pi])) {
                        (void)((peq = 0));
                      }
                      (void)((pi = (pi + 1)));
                    }
                    if ((peq !=0)) {
                      (void)((slot = pj));
                      (void)((pj = ntp));
                    }
                  }
                  (void)((pj = (pj + 1)));
                }
                if ((slot >=0)) {
                  int32_t flen = pipeline_module_struct_layout_field_name_len(module, layout_k, fj);
                  uint8_t fnm[128] = {};
                  (void)(pipeline_module_struct_layout_field_name_into(module, layout_k, fj, &((fnm)[0])));
                  int32_t lit_nf = pipeline_expr_struct_lit_num_fields(arena, ei);
                  int32_t li = 0;
                  while ((li < lit_nf)) {
                    int32_t lfl = pipeline_expr_struct_lit_field_name_len(arena, ei, li);
                    if (((lfl ==flen) && (flen > 0))) {
                      uint8_t lfn[128] = {};
                      (void)(pipeline_expr_struct_lit_field_name_into(arena, ei, li, &((lfn)[0])));
                      int32_t feq = 1;
                      int32_t fi = 0;
                      while ((fi < flen)) {
                        if (((lfn)[fi] !=(fnm)[fi])) {
                          (void)((feq = 0));
                        }
                        (void)((fi = (fi + 1)));
                      }
                      if ((feq !=0)) {
                        int32_t iref = pipeline_expr_struct_lit_init_ref(arena, ei, li);
                        if ((iref > 0)) {
                          int32_t ity = pipeline_expr_resolved_type_ref(arena, iref);
                          if (((ity > 0) && (codegen_type_ref_is_host_concrete(module, arena, ity) !=0))) {
                            if (((combo2)[slot] ==0)) {
                              (void)(((combo2)[slot] = ity));
                              (void)((filled = (filled + 1)));
                            }
                          }
                        }
                        (void)((li = lit_nf));
                      }
                    }
                    (void)((li = (li + 1)));
                  }
                }
              }
              (void)((fj = (fj + 1)));
            }
            int32_t scheck = 0;
            while ((scheck < ntp)) {
              if (((combo2)[scheck] <=0)) {
                (void)((ok = 0));
              }
              (void)((scheck = (scheck + 1)));
            }
            if (((ok !=0) && (filled > 0))) {
              int32_t found2 = 0;
              int32_t c1 = 0;
              while ((c1 < combo_count)) {
                int32_t same2 = 1;
                int32_t s2 = 0;
                while ((s2 < ntp)) {
                  int32_t ca2 = (combos_out)[((c1 * ntp) + s2)];
                  int32_t cb2 = (combo2)[s2];
                  if ((codegen_type_refs_same_for_mono(arena, ca2, cb2) ==0)) {
                    (void)((same2 = 0));
                    (void)((s2 = ntp));
                  }
                  (void)((s2 = (s2 + 1)));
                }
                if ((same2 !=0)) {
                  (void)((found2 = 1));
                  (void)((c1 = combo_count));
                }
                (void)((c1 = (c1 + 1)));
              }
              if (((found2 ==0) && (combo_count < max_combos))) {
                int32_t s3 = 0;
                while ((s3 < ntp)) {
                  (void)(((combos_out)[((combo_count * ntp) + s3)] = (combo2)[s3]));
                  (void)((s3 = (s3 + 1)));
                }
                (void)((combo_count = (combo_count + 1)));
              }
            }
          }
        }
      }
      (void)((ei = (ei + 1)));
    }
    int32_t fi_h = 0;
    while (((fi_h < ((module)->num_funcs)) && (combo_count < max_combos))) {
      if (((pipeline_module_func_num_generic_params_at(module, fi_h) > 0) && (pipeline_module_func_is_extern_at(module, fi_h) ==0))) {
        int32_t np_h = pipeline_module_func_num_params_at(module, fi_h);
        if (((np_h >=0) && (np_h <=8))) {
          int32_t ret_extra_h = codegen_func_ret_type_param_extra(arena, module, fi_h);
          int32_t combo_width_h = (np_h + ret_extra_h);
          if (((combo_width_h > 0) && (combo_width_h <=8))) {
            int32_t combos_fn[128] = {};
            int32_t ncombo_fn = codegen_collect_mono_combos_for_generic_func(arena, module, fi_h, &((combos_fn)[0]), 16, np_h, ret_extra_h);
            int32_t ci_fn = 0;
            while (((ci_fn < ncombo_fn) && (combo_count < max_combos))) {
              int32_t mono_gen[8] = {};
              int32_t mono_conc[8] = {};
              int32_t nmono = 0;
              int32_t ret_ty_fn = pipeline_module_func_return_type_at(module, fi_h);
              int32_t pi_h = 0;
              while (((pi_h < np_h) && (nmono < 8))) {
                (void)(((mono_gen)[nmono] = pipeline_module_func_param_type_ref_at(module, fi_h, pi_h)));
                (void)(((mono_conc)[nmono] = (combos_fn)[((ci_fn * combo_width_h) + pi_h)]));
                (void)((nmono = (nmono + 1)));
                (void)((pi_h = (pi_h + 1)));
              }
              if (((ret_extra_h !=0) && (nmono < 8))) {
                int32_t ta_c = (combos_fn)[((ci_fn * combo_width_h) + np_h)];
                if (((ta_c > 0) && (ta_c !=ret_ty_fn))) {
                  (void)(((mono_gen)[nmono] = ret_ty_fn));
                  (void)(((mono_conc)[nmono] = ta_c));
                  (void)((nmono = (nmono + 1)));
                }
              }
              int32_t tr_i = 0;
              while ((tr_i < (np_h + 1))) {
                int32_t try_tr = ret_ty_fn;
                if ((tr_i < np_h)) {
                  (void)((try_tr = pipeline_module_func_param_type_ref_at(module, fi_h, tr_i)));
                }
                if (((try_tr > 0) && (pipeline_type_kind_ord_at(arena, try_tr) ==8))) {
                  uint8_t tnm_r[128] = {};
                  int32_t tnl_r = pipeline_type_named_name_into(arena, try_tr, &((tnm_r)[0]));
                  if (((tnl_r ==layout_nl) && (tnl_r > 0))) {
                    int32_t eq_r = 1;
                    int32_t bi_r = 0;
                    while ((bi_r < tnl_r)) {
                      if (((tnm_r)[bi_r] !=(layout_nm)[bi_r])) {
                        (void)((eq_r = 0));
                      }
                      (void)((bi_r = (bi_r + 1)));
                    }
                    if ((eq_r !=0)) {
                      int32_t combo_r[4] = {};
                      int32_t filled_r = 0;
                      int32_t ok_r = 1;
                      int32_t si_r = 0;
                      while ((si_r < ntp)) {
                        int32_t arg = pipeline_type_type_arg_ref_at(arena, try_tr, si_r);
                        if (((arg <=0) && (si_r ==0))) {
                          (void)((arg = pipeline_type_elem_ref_at(arena, try_tr)));
                        }
                        if (((arg > 0) && (codegen_type_ref_is_host_concrete(module, arena, arg) ==0))) {
                          (void)((arg = codegen_generic_struct_resolve_arg_via_map(module, arena, arg, &((mono_gen)[0]), &((mono_conc)[0]), nmono)));
                        }
                        if (((arg <=0) || (codegen_type_ref_is_host_concrete(module, arena, arg) ==0))) {
                          (void)((ok_r = 0));
                          (void)((si_r = ntp));
                        } else {
                          (void)(((combo_r)[si_r] = arg));
                          (void)((filled_r = (filled_r + 1)));
                        }
                        (void)((si_r = (si_r + 1)));
                      }
                      if (((ok_r ==0) || (filled_r !=ntp))) {
                        (void)((ok_r = 1));
                        (void)((filled_r = 0));
                        (void)((si_r = 0));
                        while ((si_r < ntp)) {
                          int32_t tpl_h = pipeline_module_struct_layout_type_param_name_len(module, layout_k, si_r);
                          uint8_t tpn_h[128] = {};
                          (void)(pipeline_module_struct_layout_type_param_name_into(module, layout_k, si_r, &((tpn_h)[0])));
                          int32_t found_slot = 0;
                          int32_t mi_m = 0;
                          while (((mi_m < nmono) && (mi_m < 8))) {
                            if ((((mono_gen)[mi_m] > 0) && ((mono_conc)[mi_m] > 0))) {
                              uint8_t gnm_h[128] = {};
                              int32_t gnl_h = pipeline_type_named_name_into(arena, (mono_gen)[mi_m], &((gnm_h)[0]));
                              if (((gnl_h ==tpl_h) && (gnl_h > 0))) {
                                int32_t geq_h = 1;
                                int32_t gi_h = 0;
                                while ((gi_h < gnl_h)) {
                                  if (((gnm_h)[gi_h] !=(tpn_h)[gi_h])) {
                                    (void)((geq_h = 0));
                                  }
                                  (void)((gi_h = (gi_h + 1)));
                                }
                                if (((geq_h !=0) && (codegen_type_ref_is_host_concrete(module, arena, (mono_conc)[mi_m]) !=0))) {
                                  (void)(((combo_r)[si_r] = (mono_conc)[mi_m]));
                                  (void)((found_slot = 1));
                                  (void)((filled_r = (filled_r + 1)));
                                  (void)((mi_m = nmono));
                                }
                              }
                            }
                            (void)((mi_m = (mi_m + 1)));
                          }
                          if ((found_slot ==0)) {
                            (void)((ok_r = 0));
                            (void)((si_r = ntp));
                          }
                          (void)((si_r = (si_r + 1)));
                        }
                      }
                      if (((ok_r !=0) && (filled_r ==ntp))) {
                        int32_t found_r = 0;
                        int32_t c_r = 0;
                        while ((c_r < combo_count)) {
                          int32_t same_r = 1;
                          int32_t s_r = 0;
                          while ((s_r < ntp)) {
                            if ((codegen_type_refs_same_for_mono(arena, (combos_out)[((c_r * ntp) + s_r)], (combo_r)[s_r]) ==0)) {
                              (void)((same_r = 0));
                            }
                            (void)((s_r = (s_r + 1)));
                          }
                          if ((same_r !=0)) {
                            (void)((found_r = 1));
                            (void)((c_r = combo_count));
                          }
                          (void)((c_r = (c_r + 1)));
                        }
                        if (((found_r ==0) && (combo_count < max_combos))) {
                          int32_t s_a = 0;
                          while ((s_a < ntp)) {
                            (void)(((combos_out)[((combo_count * ntp) + s_a)] = (combo_r)[s_a]));
                            (void)((s_a = (s_a + 1)));
                          }
                          (void)((combo_count = (combo_count + 1)));
                        }
                      }
                    }
                  }
                }
                (void)((tr_i = (tr_i + 1)));
              }
              (void)((ci_fn = (ci_fn + 1)));
            }
          }
        }
      }
      (void)((fi_h = (fi_h + 1)));
    }
    return combo_count;
  }
}
int32_t codegen_maybe_emit_generic_struct_mono_suffix_for_type(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if (((((module ==0) || (arena ==0)) || (out ==0)) || (type_ref <=0))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, type_ref) !=8)) {
      return 0;
    }
    uint8_t nm[128] = {};
    int32_t nl = pipeline_type_named_name_into(arena, type_ref, &((nm)[0]));
    if ((nl <=0)) {
      return 0;
    }
    int32_t bare_off = 0;
    int32_t bi = 0;
    while (((bi < nl) && (bi < 64))) {
      if (((nm)[bi] ==46)) {
        (void)((bare_off = (bi + 1)));
      }
      (void)((bi = (bi + 1)));
    }
    int32_t bare_len = (nl - bare_off);
    if ((bare_len <=0)) {
      return 0;
    }
    int32_t lk = codegen_module_struct_layout_index_by_name(module, &((nm)[bare_off]), bare_len);
    if ((lk < 0)) {
      return 0;
    }
    int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, lk);
    if ((ntp <=0)) {
      return 0;
    }
    int32_t mono[4] = {};
    if ((codegen_generic_struct_fill_concrete_args(module, arena, type_ref, ntp, &((mono)[0]), ctx) ==ntp)) {
      return codegen_emit_generic_struct_mono_suffix(out, arena, &((mono)[0]), ntp);
    }
    if (((((ctx !=0) && (((ctx)->mono_active) !=0)) && (((ctx)->mono_num_types) > 0)) && (ntp <=4))) {
      int32_t tj = 0;
      int32_t ok = 1;
      while ((tj < ntp)) {
        int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, lk, tj);
        uint8_t tpn[128] = {};
        (void)(pipeline_module_struct_layout_type_param_name_into(module, lk, tj, &((tpn)[0])));
        (void)(((mono)[tj] = 0));
        int32_t found = 0;
        int32_t mi_m = 0;
        while (((mi_m < ((ctx)->mono_num_types)) && (mi_m < 8))) {
          int32_t gtr = (((ctx)->mono_generic_type_refs))[mi_m];
          int32_t ctr = (((ctx)->mono_concrete_type_refs))[mi_m];
          if (((gtr > 0) && (ctr > 0))) {
            uint8_t gnm[128] = {};
            int32_t gnl = pipeline_type_named_name_into(arena, gtr, &((gnm)[0]));
            if (((gnl ==tpl) && (gnl > 0))) {
              int32_t geq = 1;
              int32_t gi = 0;
              while ((gi < gnl)) {
                if (((gnm)[gi] !=(tpn)[gi])) {
                  (void)((geq = 0));
                }
                (void)((gi = (gi + 1)));
              }
              if (((geq !=0) && (codegen_type_ref_is_host_concrete(module, arena, ctr) !=0))) {
                (void)(((mono)[tj] = ctr));
                (void)((found = 1));
                (void)((mi_m = ((ctx)->mono_num_types)));
              }
            }
          }
          (void)((mi_m = (mi_m + 1)));
        }
        if ((found ==0)) {
          (void)((ok = 0));
          (void)((tj = ntp));
        }
        (void)((tj = (tj + 1)));
      }
      if ((ok !=0)) {
        return codegen_emit_generic_struct_mono_suffix(out, arena, &((mono)[0]), ntp);
      }
    }
    if ((ntp <=4)) {
      int32_t combos[32] = {};
      int32_t nc = codegen_collect_generic_struct_mono_combos(module, arena, lk, &((nm)[bare_off]), bare_len, ntp, &((combos)[0]), 8);
      if ((nc ==1)) {
        return codegen_emit_generic_struct_mono_suffix(out, arena, &((combos)[0]), ntp);
      }
      if ((nc > 1)) {
        int32_t match_combo[4] = {};
        int32_t mi = 0;
        while ((mi < nc)) {
          int32_t matched = 1;
          int32_t si = 0;
          while ((si < ntp)) {
            int32_t arg_ref = pipeline_type_type_arg_ref_at(arena, type_ref, si);
            if ((arg_ref <=0)) {
              (void)((matched = 0));
              (void)((si = ntp));
            } else {
              if ((codegen_type_refs_same_for_mono(arena, arg_ref, (combos)[((mi * ntp) + si)]) ==0)) {
                (void)((matched = 0));
                (void)((si = ntp));
              }
            }
            (void)((si = (si + 1)));
          }
          if ((matched !=0)) {
            int32_t sj = 0;
            while ((sj < ntp)) {
              (void)(((match_combo)[sj] = (combos)[((mi * ntp) + sj)]));
              (void)((sj = (sj + 1)));
            }
            return codegen_emit_generic_struct_mono_suffix(out, arena, &((match_combo)[0]), ntp);
          }
          (void)((mi = (mi + 1)));
        }
      }
    }
    return 0;
  }
}
int32_t codegen_build_func_param_mono_map(struct ast_Module * module, struct ast_ASTArena * arena, int32_t fi, int32_t * gen_refs, int32_t * conc_refs, int32_t max_entries) {
  {
    if ((((((module ==0) || (arena ==0)) || (gen_refs ==0)) || (conc_refs ==0)) || (max_entries <=0))) {
      return 0;
    }
    if (((fi < 0) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    int32_t map_count = 0;
    int32_t num_params = pipeline_module_func_num_params_at(module, fi);
    int32_t p = 0;
    while ((p < num_params)) {
      int32_t pty_raw = pipeline_module_func_param_type_ref_at(module, fi, p);
      if ((pty_raw <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t pty = pipeline_typeck_resolve_type_alias_ref_c(arena, pty_raw);
      if ((pty <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      if ((pipeline_type_kind_ord_at(arena, pty) !=8)) {
        (void)((p = (p + 1)));
        continue;
      }
      uint8_t nm[128] = {};
      int32_t nl = pipeline_type_named_name_into(arena, pty, &((nm)[0]));
      if ((nl <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t bare_off = 0;
      int32_t bi = 0;
      while (((bi < nl) && (bi < 64))) {
        if (((nm)[bi] ==46)) {
          (void)((bare_off = (bi + 1)));
        }
        (void)((bi = (bi + 1)));
      }
      int32_t bare_len = (nl - bare_off);
      if ((bare_len <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t lk = codegen_module_struct_layout_index_by_name(module, &((nm)[bare_off]), bare_len);
      if ((lk < 0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if ((ntp <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t mono_chk[4] = {};
      if ((codegen_generic_struct_fill_concrete_args(module, arena, pty, ntp, &((mono_chk)[0]), 0) ==ntp)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t combos[32] = {};
      int32_t nc = codegen_collect_generic_struct_mono_combos(module, arena, lk, &((nm)[bare_off]), bare_len, ntp, &((combos)[0]), 8);
      if ((nc !=1)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t tj = 0;
      while ((tj < ntp)) {
        int32_t formal_arg = pipeline_type_type_arg_ref_at(arena, pty, tj);
        int32_t concrete_arg = (combos)[tj];
        if ((((formal_arg > 0) && (concrete_arg > 0)) && (map_count < max_entries))) {
          int32_t dup = 0;
          int32_t dk = 0;
          while ((dk < map_count)) {
            if (((gen_refs)[dk] ==formal_arg)) {
              (void)((dup = 1));
              (void)((dk = map_count));
            }
            (void)((dk = (dk + 1)));
          }
          if ((dup ==0)) {
            (void)(((gen_refs)[map_count] = formal_arg));
            (void)(((conc_refs)[map_count] = concrete_arg));
            (void)((map_count = (map_count + 1)));
          }
        }
        (void)((tj = (tj + 1)));
      }
      (void)((p = (p + 1)));
    }
    return map_count;
  }
}
int32_t codegen_emit_struct_field_decl_x(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t type_ref, uint8_t * field_name, int32_t field_name_len, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t base_ref = type_ref;
    if (((ast_ref_is_null(type_ref) || (field_name ==0)) || (field_name_len <=0))) {
      return -1;
    }
    while ((!(ast_ref_is_null(base_ref)) && (pipeline_type_kind_ord_at(arena, base_ref) ==10))) {
      int32_t inner = pipeline_type_elem_ref_at(arena, base_ref);
      if (ast_ref_is_null(inner)) {
        break;
      }
      (void)((base_ref = inner));
    }
    if ((codegen_emit_type(arena, out, base_ref, struct_prefix, struct_prefix_len, ctx) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_from_ptr(out, field_name, field_name_len) !=0)) {
      return -1;
    }
    int32_t dims_ref = type_ref;
    while ((!(ast_ref_is_null(dims_ref)) && (pipeline_type_kind_ord_at(arena, dims_ref) ==10))) {
      uint8_t lbr[2] = {91, 0};
      uint8_t rbr[2] = {93, 0};
      if ((codegen_emit_bytes_2(out, &((lbr)[0]), 1) !=0)) {
        return -1;
      }
      if ((codegen_format_int(out, pipeline_type_array_size_at(arena, dims_ref)) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_2(out, &((rbr)[0]), 1) !=0)) {
        return -1;
      }
      (void)((dims_ref = pipeline_type_elem_ref_at(arena, dims_ref)));
    }
    return 0;
  }
}
int32_t codegen_emit_companion_named_slice_layout(struct codegen_CodegenOutBuf * out, uint8_t * pfx, int32_t pfx_len, uint8_t * name, int32_t name_len) {
  if ((((out ==0) || (name ==0)) || (name_len <=0))) {
    return -1;
  }
  uint8_t h1[20] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((h1)[0]), 19) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t mid[12] = {32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((mid)[0]), 10) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t tail[28] = {32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 10, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((tail)[0]), 27) !=0)) {
    return -1;
  }
  uint8_t h2[32] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((h2)[0]), 31) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t mid2[24] = {32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((mid2)[0]), 22) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((tail)[0]), 27) !=0)) {
    return -1;
  }
  uint8_t h3[44] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((h3)[0]), 43) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t mid3[36] = {32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((mid3)[0]), 34) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((tail)[0]), 27) !=0)) {
    return -1;
  }
  uint8_t h4[56] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((h4)[0]), 55) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t mid4[48] = {32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((mid4)[0]), 46) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((tail)[0]), 27) !=0)) {
    return -1;
  }
  uint8_t h5[68] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((h5)[0]), 67) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t mid5[60] = {32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((mid5)[0]), 58) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((tail)[0]), 27) !=0)) {
    return -1;
  }
  uint8_t h6[80] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((h6)[0]), 79) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t mid6[72] = {32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((mid6)[0]), 70) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((tail)[0]), 27) !=0)) {
    return -1;
  }
  uint8_t h7[96] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0, 0, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((h7)[0]), 91) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  uint8_t mid7[88] = {32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 0, 0, 0, 0, 0, 0};
  if ((codegen_emit_bytes_from_ptr(out, &((mid7)[0]), 82) !=0)) {
    return -1;
  }
  if (((pfx !=0) && (pfx_len > 0))) {
    if ((codegen_emit_bytes_from_ptr(out, pfx, pfx_len) !=0)) {
      return -1;
    }
  }
  if ((codegen_emit_bytes_from_ptr(out, name, name_len) !=0)) {
    return -1;
  }
  if ((codegen_emit_bytes_from_ptr(out, &((tail)[0]), 27) !=0)) {
    return -1;
  }
  return 0;
}
int32_t codegen_emit_module_struct_definitions(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t cur_di = -1;
    if ((ctx !=0)) {
      (void)((cur_di = ((ctx)->current_codegen_dep_index)));
    }
    int32_t phase = 0;
    while ((phase < 2)) {
      int32_t k = 0;
      int32_t job_k[32] = {};
      int32_t job_ntp[32] = {};
      int32_t job_depth[32] = {};
      int32_t job_mono[128] = {};
      int32_t njob = 0;
      while ((k < ((module)->num_struct_layouts))) {
        int32_t nf = pipeline_module_struct_layout_num_fields(module, k);
        int32_t nl = pipeline_module_struct_layout_name_len(module, k);
        if ((nl <=0)) {
          (void)((k = (k + 1)));
          continue;
        }
        uint8_t ty_nm[128] = {};
        (void)(pipeline_module_struct_layout_name_into(module, k, &((ty_nm)[0])));
        if ((ctx !=0)) {
          int32_t owner = codegen_type_dep_struct_owner_index(ctx, &((ty_nm)[0]), nl);
          if (((owner >=0) && (owner !=cur_di))) {
            (void)((k = (k + 1)));
            continue;
          }
        }
        if ((codegen_should_skip_emit_struct_layout_for_abi_dup(&((ty_nm)[0]), nl) !=0)) {
          (void)((k = (k + 1)));
          continue;
        }
        uint8_t claim_pfx[128] = {};
        int32_t claim_plen = 0;
        if (((struct_prefix !=0) && (struct_prefix_len > 0))) {
          (void)((claim_plen = struct_prefix_len));
          if ((claim_plen > 127)) {
            (void)((claim_plen = 127));
          }
          int32_t ci = 0;
          while ((ci < claim_plen)) {
            (void)(((claim_pfx)[ci] = (struct_prefix)[ci]));
            (void)((ci = (ci + 1)));
          }
        } else {
          if (!(((ctx !=0) && (((ctx)->current_codegen_dep_index) < 0)))) {
            (void)(((claim_pfx)[0] = 97));
            (void)(((claim_pfx)[1] = 115));
            (void)(((claim_pfx)[2] = 116));
            (void)(((claim_pfx)[3] = 95));
            (void)((claim_plen = 4));
          }
        }
        int32_t ntp_gs = pipeline_module_struct_layout_num_type_params_at(module, k);
        int32_t combos_gs[32] = {};
        int32_t ncombo_gs = 0;
        if ((((ntp_gs > 0) && (ntp_gs <=4)) && (arena !=0))) {
          (void)((ncombo_gs = codegen_collect_generic_struct_mono_combos(module, arena, k, &((ty_nm)[0]), nl, ntp_gs, &((combos_gs)[0]), 8)));
        }
        if ((phase ==0)) {
          if ((ncombo_gs > 0)) {
            (void)((k = (k + 1)));
            continue;
          }
          if ((pipeline_codegen_struct_tag_try_claim(&((claim_pfx)[0]), claim_plen, &((ty_nm)[0]), nl) ==0)) {
            (void)((k = (k + 1)));
            continue;
          }
          uint8_t hdr_top[8] = {115, 116, 114, 117, 99, 116, 32, 0};
          if ((codegen_emit_bytes_8(out, &((hdr_top)[0]), 7) !=0)) {
            return -1;
          }
          if (((struct_prefix !=0) && (struct_prefix_len > 0))) {
            if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
              return -1;
            }
          } else {
            if (((ctx !=0) && (((ctx)->current_codegen_dep_index) < 0))) {
            } else {
              uint8_t ast_top[4] = {97, 115, 116, 95};
              if ((codegen_emit_bytes_4(out, &((ast_top)[0]), 4) !=0)) {
                return -1;
              }
            }
          }
          if ((codegen_emit_bytes_from_ptr(out, &((ty_nm)[0]), nl) !=0)) {
            return -1;
          }
          uint8_t br1[4] = {32, 123, 10, 0};
          if ((codegen_emit_bytes_4(out, &((br1)[0]), 3) !=0)) {
            return -1;
          }
          int32_t j = 0;
          while ((j < nf)) {
            int32_t flen = pipeline_module_struct_layout_field_name_len(module, k, j);
            int32_t ftr = pipeline_module_struct_layout_field_type_ref(module, k, j);
            if ((flen <=0)) {
              (void)((j = (j + 1)));
              continue;
            }
            if ((codegen_emit_indent(out, 2) !=0)) {
              return -1;
            }
            uint8_t fnm[128] = {};
            (void)(pipeline_module_struct_layout_field_name_into(module, k, j, &((fnm)[0])));
            (void)((ftr = codegen_resolve_generic_struct_field_type(module, arena, &((ty_nm)[0]), nl, &((fnm)[0]), flen, ftr)));
            if ((codegen_emit_struct_field_decl_x(arena, out, ftr, &((fnm)[0]), flen, 0, 0, ctx) !=0)) {
              return -1;
            }
            uint8_t semi_nl[3] = {59, 10, 0};
            if ((codegen_emit_bytes_3(out, &((semi_nl)[0]), 2) !=0)) {
              return -1;
            }
            (void)((j = (j + 1)));
          }
          uint8_t close_ty[4] = {125, 59, 10, 10};
          if ((codegen_emit_bytes_4(out, &((close_ty)[0]), 4) !=0)) {
            return -1;
          }
          if ((codegen_emit_companion_named_slice_layout(out, &((claim_pfx)[0]), claim_plen, &((ty_nm)[0]), nl) !=0)) {
            return -1;
          }
          (void)((k = (k + 1)));
          continue;
        }
        if ((ncombo_gs > 0)) {
          int32_t cc = 0;
          while (((cc < ncombo_gs) && (njob < 32))) {
            int32_t mono_c[4] = {};
            int32_t ms = 0;
            while ((ms < ntp_gs)) {
              (void)(((mono_c)[ms] = (combos_gs)[((cc * ntp_gs) + ms)]));
              (void)((ms = (ms + 1)));
            }
            (void)(((job_k)[njob] = k));
            (void)(((job_ntp)[njob] = ntp_gs));
            (void)(((job_depth)[njob] = codegen_generic_struct_combo_nest_depth(arena, &((mono_c)[0]), ntp_gs)));
            (void)((ms = 0));
            while ((ms < ntp_gs)) {
              (void)(((job_mono)[((njob * 4) + ms)] = (mono_c)[ms]));
              (void)((ms = (ms + 1)));
            }
            while ((ms < 4)) {
              (void)(((job_mono)[((njob * 4) + ms)] = 0));
              (void)((ms = (ms + 1)));
            }
            (void)((njob = (njob + 1)));
            (void)((cc = (cc + 1)));
          }
        }
        (void)((k = (k + 1)));
      }
      if ((phase ==1)) {
        int32_t i = 0;
        while ((i < njob)) {
          int32_t j = (i + 1);
          while ((j < njob)) {
            if (((job_depth)[j] < (job_depth)[i])) {
              int32_t tmp = (job_k)[i];
              (void)(((job_k)[i] = (job_k)[j]));
              (void)(((job_k)[j] = tmp));
              (void)((tmp = (job_ntp)[i]));
              (void)(((job_ntp)[i] = (job_ntp)[j]));
              (void)(((job_ntp)[j] = tmp));
              (void)((tmp = (job_depth)[i]));
              (void)(((job_depth)[i] = (job_depth)[j]));
              (void)(((job_depth)[j] = tmp));
              int32_t s = 0;
              while ((s < 4)) {
                (void)((tmp = (job_mono)[((i * 4) + s)]));
                (void)(((job_mono)[((i * 4) + s)] = (job_mono)[((j * 4) + s)]));
                (void)(((job_mono)[((j * 4) + s)] = tmp));
                (void)((s = (s + 1)));
              }
            }
            (void)((j = (j + 1)));
          }
          (void)((i = (i + 1)));
        }
        int32_t ji = 0;
        while ((ji < njob)) {
          int32_t jk = (job_k)[ji];
          int32_t jntp = (job_ntp)[ji];
          int32_t jnf = pipeline_module_struct_layout_num_fields(module, jk);
          int32_t jnl = pipeline_module_struct_layout_name_len(module, jk);
          if (((jnl <=0) || (jntp <=0))) {
            (void)((ji = (ji + 1)));
            continue;
          }
          uint8_t jty[128] = {};
          (void)(pipeline_module_struct_layout_name_into(module, jk, &((jty)[0])));
          int32_t mono_c[4] = {};
          int32_t ms = 0;
          while (((ms < jntp) && (ms < 4))) {
            (void)(((mono_c)[ms] = (job_mono)[((ji * 4) + ms)]));
            (void)((ms = (ms + 1)));
          }
          uint8_t claim_pfx2[128] = {};
          int32_t claim_plen2 = 0;
          if (((struct_prefix !=0) && (struct_prefix_len > 0))) {
            (void)((claim_plen2 = struct_prefix_len));
            if ((claim_plen2 > 127)) {
              (void)((claim_plen2 = 127));
            }
            int32_t ci2 = 0;
            while ((ci2 < claim_plen2)) {
              (void)(((claim_pfx2)[ci2] = (struct_prefix)[ci2]));
              (void)((ci2 = (ci2 + 1)));
            }
          } else {
            if (!(((ctx !=0) && (((ctx)->current_codegen_dep_index) < 0)))) {
              (void)(((claim_pfx2)[0] = 97));
              (void)(((claim_pfx2)[1] = 115));
              (void)(((claim_pfx2)[2] = 116));
              (void)(((claim_pfx2)[3] = 95));
              (void)((claim_plen2 = 4));
            }
          }
          uint8_t mangled[96] = {};
          int32_t mlen = codegen_generic_struct_mangled_name_into(arena, &((jty)[0]), jnl, &((mono_c)[0]), jntp, &((mangled)[0]), 96);
          if ((mlen <=0)) {
            (void)((ji = (ji + 1)));
            continue;
          }
          if ((pipeline_codegen_struct_tag_try_claim(&((claim_pfx2)[0]), claim_plen2, &((mangled)[0]), mlen) ==0)) {
            (void)((ji = (ji + 1)));
            continue;
          }
          uint8_t hdr_m[8] = {115, 116, 114, 117, 99, 116, 32, 0};
          if ((codegen_emit_bytes_8(out, &((hdr_m)[0]), 7) !=0)) {
            return -1;
          }
          if (((struct_prefix !=0) && (struct_prefix_len > 0))) {
            if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
              return -1;
            }
          } else {
            if (((ctx !=0) && (((ctx)->current_codegen_dep_index) < 0))) {
            } else {
              uint8_t ast_m[4] = {97, 115, 116, 95};
              if ((codegen_emit_bytes_4(out, &((ast_m)[0]), 4) !=0)) {
                return -1;
              }
            }
          }
          if ((codegen_emit_bytes_from_ptr(out, &((mangled)[0]), mlen) !=0)) {
            return -1;
          }
          uint8_t br_m[4] = {32, 123, 10, 0};
          if ((codegen_emit_bytes_4(out, &((br_m)[0]), 3) !=0)) {
            return -1;
          }
          int32_t j_m = 0;
          while ((j_m < jnf)) {
            int32_t flen_m = pipeline_module_struct_layout_field_name_len(module, jk, j_m);
            int32_t ftr_m = pipeline_module_struct_layout_field_type_ref(module, jk, j_m);
            if ((flen_m <=0)) {
              (void)((j_m = (j_m + 1)));
              continue;
            }
            if ((codegen_emit_indent(out, 2) !=0)) {
              return -1;
            }
            uint8_t fnm_m[128] = {};
            (void)(pipeline_module_struct_layout_field_name_into(module, jk, j_m, &((fnm_m)[0])));
            (void)((ftr_m = codegen_generic_struct_field_type_from_mono(module, arena, jk, ftr_m, &((mono_c)[0]), jntp)));
            if ((codegen_emit_struct_field_decl_x(arena, out, ftr_m, &((fnm_m)[0]), flen_m, 0, 0, ctx) !=0)) {
              return -1;
            }
            uint8_t semi_m[3] = {59, 10, 0};
            if ((codegen_emit_bytes_3(out, &((semi_m)[0]), 2) !=0)) {
              return -1;
            }
            (void)((j_m = (j_m + 1)));
          }
          uint8_t close_m[4] = {125, 59, 10, 10};
          if ((codegen_emit_bytes_4(out, &((close_m)[0]), 4) !=0)) {
            return -1;
          }
          if ((codegen_emit_companion_named_slice_layout(out, &((claim_pfx2)[0]), claim_plen2, &((mangled)[0]), mlen) !=0)) {
            return -1;
          }
          (void)((ji = (ji + 1)));
        }
      }
      (void)((phase = (phase + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_module_struct_forward_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len) {
  return codegen_emit_module_struct_forward_declarations_ctx(module, out, struct_prefix, struct_prefix_len, 0);
}
int32_t codegen_emit_module_struct_forward_declarations_ctx(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t k = 0;
    int32_t cur_di = -1;
    if ((ctx !=0)) {
      (void)((cur_di = ((ctx)->current_codegen_dep_index)));
    }
    while ((k < ((module)->num_struct_layouts))) {
      int32_t nl = pipeline_module_struct_layout_name_len(module, k);
      if ((nl <=0)) {
        (void)((k = (k + 1)));
        continue;
      }
      uint8_t ty_nm[128] = {};
      (void)(pipeline_module_struct_layout_name_into(module, k, &((ty_nm)[0])));
      if ((ctx !=0)) {
        int32_t owner = codegen_type_dep_struct_owner_index(ctx, &((ty_nm)[0]), nl);
        if (((owner >=0) && (owner !=cur_di))) {
          (void)((k = (k + 1)));
          continue;
        }
      }
      uint8_t hdr[8] = {115, 116, 114, 117, 99, 116, 32, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((hdr)[0]), 7) !=0)) {
        return -1;
      }
      if (((struct_prefix !=0) && (struct_prefix_len > 0))) {
        if ((codegen_emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) !=0)) {
          return -1;
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((ty_nm)[0]), nl) !=0)) {
        return -1;
      }
      uint8_t semi_nl[2] = {59, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((semi_nl)[0]), 2) !=0)) {
        return -1;
      }
      (void)((k = (k + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_module_enum_definitions(struct ast_Module * module, struct codegen_CodegenOutBuf * out, uint8_t * enum_prefix, int32_t enum_prefix_len) {
  {
    int32_t ei = 0;
    while ((ei < ((module)->num_module_enums))) {
      int32_t enl = pipeline_module_enum_name_len(module, ei);
      if ((enl <=0)) {
        (void)((ei = (ei + 1)));
        continue;
      }
      uint8_t enm[128] = {};
      uint8_t hdr[8] = {101, 110, 117, 109, 32, 0, 0, 0};
      uint8_t open[4] = {32, 123, 32, 0};
      uint8_t close[6] = {32, 125, 59, 10, 0, 0};
      uint8_t comma[3] = {44, 32, 0};
      (void)(pipeline_module_enum_name_byte_at(module, ei, 0));
      int32_t nk = 0;
      while (((nk < enl) && (nk < 64))) {
        (void)(((enm)[nk] = pipeline_module_enum_name_byte_at(module, ei, nk)));
        (void)((nk = (nk + 1)));
      }
      uint8_t claim_pfx[128] = {};
      int32_t claim_plen = 0;
      (void)(((claim_pfx)[0] = 101));
      (void)((claim_plen = 1));
      if (((enum_prefix !=0) && (enum_prefix_len > 0))) {
        int32_t ep = enum_prefix_len;
        if ((ep > 126)) {
          (void)((ep = 126));
        }
        int32_t ei2 = 0;
        while ((ei2 < ep)) {
          (void)(((claim_pfx)[(1 + ei2)] = (enum_prefix)[ei2]));
          (void)((ei2 = (ei2 + 1)));
        }
        (void)((claim_plen = (1 + ep)));
      }
      if ((pipeline_codegen_struct_tag_try_claim(&((claim_pfx)[0]), claim_plen, &((enm)[0]), enl) ==0)) {
        (void)((ei = (ei + 1)));
        continue;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((hdr)[0]), 5) !=0)) {
        return -1;
      }
      if (((enum_prefix !=0) && (enum_prefix_len > 0))) {
        if ((codegen_emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) !=0)) {
          return -1;
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((enm)[0]), enl) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_4(out, &((open)[0]), 3) !=0)) {
        return -1;
      }
      int32_t nv = pipeline_module_enum_num_variants(module, ei);
      int32_t vi = 0;
      while ((vi < nv)) {
        int32_t vlen = pipeline_module_enum_variant_name_len(module, ei, vi);
        uint8_t vnm[128] = {};
        int32_t vk = 0;
        if ((vi > 0)) {
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
        }
        while (((vk < vlen) && (vk < 64))) {
          (void)(((vnm)[vk] = pipeline_module_enum_variant_name_byte_at(module, ei, vi, vk)));
          (void)((vk = (vk + 1)));
        }
        if (((enum_prefix !=0) && (enum_prefix_len > 0))) {
          if ((codegen_emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) !=0)) {
            return -1;
          }
        }
        if ((codegen_emit_bytes_from_ptr(out, &((enm)[0]), enl) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 95) !=0)) {
          return -1;
        }
        if (((vlen > 0) && (codegen_emit_bytes_from_ptr(out, &((vnm)[0]), vlen) !=0))) {
          return -1;
        }
        (void)((vi = (vi + 1)));
      }
      if ((codegen_emit_bytes_from_ptr(out, &((close)[0]), 4) !=0)) {
        return -1;
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_skipped_dep_type_definitions(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out) {
  {
    if (((ctx ==0) || (out ==0))) {
      return 0;
    }
    struct ast_Module * saved_module = ((ctx)->current_codegen_module);
    struct ast_ASTArena * saved_arena = ((ctx)->current_codegen_arena);
    int32_t saved_dep_index = ((ctx)->current_codegen_dep_index);
    int32_t saved_prefix_len = ((ctx)->current_codegen_prefix_len);
    uint8_t saved_prefix[128] = {};
    int32_t sp = 0;
    while ((sp < 64)) {
      (void)(((saved_prefix)[sp] = (((ctx)->current_codegen_prefix_mirror))[sp]));
      (void)((sp = (sp + 1)));
    }
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t done[64] = {};
    int32_t di_init = 0;
    while ((di_init < 64)) {
      (void)(((done)[di_init] = 0));
      (void)((di_init = (di_init + 1)));
    }
    int32_t remaining = 0;
    int32_t di_count = 0;
    while ((di_count < nd)) {
      struct ast_Module * dep_mod0 = pipeline_dep_ctx_module_at(ctx, di_count);
      struct ast_ASTArena * dep_arena0 = pipeline_dep_ctx_arena_at(ctx, di_count);
      uint8_t dep_path0[128] = {};
      int32_t plen0 = codegen_dep_import_path_len_at(ctx, di_count, &((dep_path0)[0]));
      if ((((dep_mod0 !=0) && (dep_arena0 !=0)) && (plen0 > 0))) {
        (void)((remaining = (remaining + 1)));
      } else {
        (void)(((done)[di_count] = 1));
      }
      (void)((di_count = (di_count + 1)));
    }
    int32_t pass = 0;
    int32_t max_pass = (nd + 2);
    while (((remaining > 0) && (pass < max_pass))) {
      int32_t progressed = 0;
      int32_t di = 0;
      while ((di < nd)) {
        if (((done)[di] !=0)) {
          (void)((di = (di + 1)));
          continue;
        }
        struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
        struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, di);
        uint8_t dep_path[128] = {};
        int32_t dep_path_len = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
        if ((((dep_mod ==0) || (dep_arena ==0)) || (dep_path_len <=0))) {
          (void)(((done)[di] = 1));
          (void)((di = (di + 1)));
          continue;
        }
        int32_t ready = 1;
        int32_t n_imp = codegen_module_num_imports(dep_mod);
        int32_t ii = 0;
        while ((ii < n_imp)) {
          uint8_t ipath[128] = {};
          int32_t ilen = codegen_module_import_path_len_at(dep_mod, ii, &((ipath)[0]));
          if ((ilen > 0)) {
            int32_t idi = codegen_find_dep_index_by_path(ctx, &((ipath)[0]), ilen);
            if (((((idi >=0) && (idi < nd)) && (idi !=di)) && ((done)[idi] ==0))) {
              (void)((ready = 0));
              break;
            }
          }
          (void)((ii = (ii + 1)));
        }
        if ((ready ==0)) {
          (void)((di = (di + 1)));
          continue;
        }
        int32_t seen_before = 0;
        int32_t pj = 0;
        while ((pj < di)) {
          uint8_t prev_path[128] = {};
          int32_t prev_len = codegen_dep_import_path_len_at(ctx, pj, &((prev_path)[0]));
          if ((prev_len ==dep_path_len)) {
            int eq_prev = 1;
            int32_t pk = 0;
            while (((pk < dep_path_len) && (pk < 64))) {
              if (((prev_path)[pk] !=(dep_path)[pk])) {
                (void)((eq_prev = 0));
                break;
              }
              (void)((pk = (pk + 1)));
            }
            if (eq_prev) {
              struct ast_Module * prev_mod = pipeline_dep_ctx_module_at(ctx, pj);
              if (((prev_mod !=0) && (((prev_mod)->num_struct_layouts) > 0))) {
                (void)((seen_before = 1));
                break;
              }
            }
          }
          (void)((pj = (pj + 1)));
        }
        if ((seen_before ==0)) {
          uint8_t prefix_buf[128] = {};
          int32_t prefix_len = 0;
          if ((codegen_path_is_std_io_core_bytes(&((dep_path)[0])) ==0)) {
            (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
            while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
              (void)((prefix_len = (prefix_len + 1)));
            }
          }
          (void)((((ctx)->current_codegen_module) = dep_mod));
          (void)((((ctx)->current_codegen_arena) = dep_arena));
          (void)((((ctx)->current_codegen_dep_index) = di));
          (void)((((ctx)->current_codegen_prefix_len) = 0));
          int32_t px = 0;
          while (((px < prefix_len) && (px < 63))) {
            (void)(((((ctx)->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
            (void)((px = (px + 1)));
          }
          (void)(((((ctx)->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
          (void)((((ctx)->current_codegen_prefix_len) = px));
          if ((codegen_emit_module_enum_definitions(dep_mod, out, &((prefix_buf)[0]), prefix_len) !=0)) {
            return -1;
          }
          if ((codegen_emit_module_struct_definitions(dep_mod, dep_arena, out, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
            return -1;
          }
        }
        (void)(((done)[di] = 1));
        (void)((remaining = (remaining - 1)));
        (void)((progressed = 1));
        (void)((di = (di + 1)));
      }
      if ((progressed ==0)) {
        int32_t dj = 0;
        while ((dj < nd)) {
          if (((done)[dj] ==0)) {
            struct ast_Module * dep_mod2 = pipeline_dep_ctx_module_at(ctx, dj);
            struct ast_ASTArena * dep_arena2 = pipeline_dep_ctx_arena_at(ctx, dj);
            uint8_t dep_path2[128] = {};
            int32_t plen2 = codegen_dep_import_path_len_at(ctx, dj, &((dep_path2)[0]));
            if ((((dep_mod2 !=0) && (dep_arena2 !=0)) && (plen2 > 0))) {
              uint8_t prefix_buf2[128] = {};
              int32_t prefix_len2 = 0;
              if ((codegen_path_is_std_io_core_bytes(&((dep_path2)[0])) ==0)) {
                (void)(codegen_import_path_to_c_prefix_into(&((dep_path2)[0]), &((prefix_buf2)[0]), 128));
                while (((prefix_len2 < 128) && ((prefix_buf2)[prefix_len2] !=0))) {
                  (void)((prefix_len2 = (prefix_len2 + 1)));
                }
              }
              (void)((((ctx)->current_codegen_module) = dep_mod2));
              (void)((((ctx)->current_codegen_arena) = dep_arena2));
              (void)((((ctx)->current_codegen_dep_index) = dj));
              int32_t px2 = 0;
              while (((px2 < prefix_len2) && (px2 < 63))) {
                (void)(((((ctx)->current_codegen_prefix_mirror))[px2] = (prefix_buf2)[px2]));
                (void)((px2 = (px2 + 1)));
              }
              (void)(((((ctx)->current_codegen_prefix_mirror))[px2] = ((uint8_t)(0))));
              (void)((((ctx)->current_codegen_prefix_len) = px2));
              if ((codegen_emit_module_enum_definitions(dep_mod2, out, &((prefix_buf2)[0]), prefix_len2) !=0)) {
                return -1;
              }
              if ((codegen_emit_module_struct_definitions(dep_mod2, dep_arena2, out, &((prefix_buf2)[0]), prefix_len2, ctx) !=0)) {
                return -1;
              }
            }
            (void)(((done)[dj] = 1));
            (void)((remaining = (remaining - 1)));
          }
          (void)((dj = (dj + 1)));
        }
      }
      (void)((pass = (pass + 1)));
    }
    (void)((((ctx)->current_codegen_module) = saved_module));
    (void)((((ctx)->current_codegen_arena) = saved_arena));
    (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
    (void)((((ctx)->current_codegen_prefix_len) = saved_prefix_len));
    (void)((sp = 0));
    while ((sp < 64)) {
      (void)(((((ctx)->current_codegen_prefix_mirror))[sp] = (saved_prefix)[sp]));
      (void)((sp = (sp + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_dep_struct_forward_declarations(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out) {
  {
    if (((ctx ==0) || (out ==0))) {
      return 0;
    }
    int32_t saved_dep_index = ((ctx)->current_codegen_dep_index);
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t di = 0;
    while ((di < nd)) {
      struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
      if ((dep_mod !=0)) {
        uint8_t dep_path[128] = {};
        int32_t dep_path_len = codegen_dep_import_path_len_at(ctx, di, &((dep_path)[0]));
        uint8_t prefix_buf[128] = {};
        int32_t prefix_len = 0;
        if (((dep_path_len > 0) && (codegen_path_is_std_io_core_bytes(&((dep_path)[0])) ==0))) {
          (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
          while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
            (void)((prefix_len = (prefix_len + 1)));
          }
        }
        (void)((((ctx)->current_codegen_dep_index) = di));
        if ((codegen_emit_module_struct_forward_declarations_ctx(dep_mod, out, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
          (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
          return -1;
        }
      }
      (void)((di = (di + 1)));
    }
    (void)((di = 0));
    while ((di < nd)) {
      struct ast_Module * dep_mod2 = pipeline_dep_ctx_module_at(ctx, di);
      if ((dep_mod2 !=0)) {
        int32_t k = 0;
        while ((k < ((dep_mod2)->num_struct_layouts))) {
          int32_t nl = pipeline_module_struct_layout_name_len(dep_mod2, k);
          int32_t nf = pipeline_module_struct_layout_num_fields(dep_mod2, k);
          if (((nl > 0) && (nf > 0))) {
            uint8_t ty_nm[128] = {};
            (void)(pipeline_module_struct_layout_name_into(dep_mod2, k, &((ty_nm)[0])));
            int32_t owner = codegen_type_dep_struct_owner_index(ctx, &((ty_nm)[0]), nl);
            if ((owner >=0)) {
              uint8_t opath[128] = {};
              int32_t oplen = codegen_dep_import_path_len_at(ctx, owner, &((opath)[0]));
              uint8_t opfx[128] = {};
              int32_t opfx_len = 0;
              if (((oplen > 0) && (codegen_path_is_std_io_core_bytes(&((opath)[0])) ==0))) {
                (void)(codegen_import_path_to_c_prefix_into(&((opath)[0]), &((opfx)[0]), 128));
                while (((opfx_len < 128) && ((opfx)[opfx_len] !=0))) {
                  (void)((opfx_len = (opfx_len + 1)));
                }
              }
              uint8_t hdr[8] = {115, 116, 114, 117, 99, 116, 32, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((hdr)[0]), 7) !=0)) {
                (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
                return -1;
              }
              if (((opfx_len > 0) && (codegen_emit_bytes_from_ptr(out, &((opfx)[0]), opfx_len) !=0))) {
                (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
                return -1;
              }
              if ((codegen_emit_bytes_from_ptr(out, &((ty_nm)[0]), nl) !=0)) {
                (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
                return -1;
              }
              uint8_t semi_nl[2] = {59, 10};
              if ((codegen_emit_bytes_from_ptr(out, &((semi_nl)[0]), 2) !=0)) {
                (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
                return -1;
              }
            }
          }
          (void)((k = (k + 1)));
        }
      }
      (void)((di = (di + 1)));
    }
    (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
    return 0;
  }
}
int32_t codegen_resolve_binding_import_path_for_field_access(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst) {
  {
    if (((ctx ==0) || (((ctx)->current_codegen_module) ==0))) {
      return 0;
    }
    if (((((arena ==0) || (dst ==0)) || (expr_ref <=0)) || (expr_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    if ((((int32_t)(((e).kind))) !=44)) {
      return 0;
    }
    if (((((e).field_access_base_ref) <=0) || (((e).field_access_base_ref) > ((arena)->num_exprs)))) {
      return 0;
    }
    struct ast_Expr base = ast_ast_arena_expr_get(arena, ((e).field_access_base_ref));
    if (((((int32_t)(((base).kind))) !=3) || (((base).var_name_len) <=0))) {
      return 0;
    }
    struct ast_Module * cur_mod = ((ctx)->current_codegen_module);
    int32_t j = 0;
    int32_t n_imp = codegen_module_num_imports(cur_mod);
    while ((j < n_imp)) {
      if ((pipeline_module_import_kind_at(cur_mod, j) !=1)) {
        (void)((j = (j + 1)));
        continue;
      }
      int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
      if ((bind_len !=((base).var_name_len))) {
        (void)((j = (j + 1)));
        continue;
      }
      int eq = 1;
      int32_t kk = 0;
      while ((kk < ((base).var_name_len))) {
        if (((((base).var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
          (void)((eq = 0));
          break;
        }
        (void)((kk = (kk + 1)));
      }
      if (!(eq)) {
        (void)((j = (j + 1)));
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
}
int32_t codegen_resolve_binding_import_path_for_method_call(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * dst) {
  {
    if (((ctx ==0) || (((ctx)->current_codegen_module) ==0))) {
      return 0;
    }
    if (((((arena ==0) || (dst ==0)) || (expr_ref <=0)) || (expr_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    if ((((int32_t)(((e).kind))) !=49)) {
      return 0;
    }
    if (((((e).method_call_base_ref) <=0) || (((e).method_call_base_ref) > ((arena)->num_exprs)))) {
      return 0;
    }
    struct ast_Expr base = ast_ast_arena_expr_get(arena, ((e).method_call_base_ref));
    if (((((int32_t)(((base).kind))) !=3) || (((base).var_name_len) <=0))) {
      return 0;
    }
    struct ast_Module * cur_mod = ((ctx)->current_codegen_module);
    int32_t j = 0;
    int32_t n_imp = codegen_module_num_imports(cur_mod);
    while ((j < n_imp)) {
      if ((pipeline_module_import_kind_at(cur_mod, j) !=1)) {
        (void)((j = (j + 1)));
        continue;
      }
      int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
      if ((bind_len !=((base).var_name_len))) {
        (void)((j = (j + 1)));
        continue;
      }
      int eq = 1;
      int32_t kk = 0;
      while ((kk < ((base).var_name_len))) {
        if (((((base).var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
          (void)((eq = 0));
          break;
        }
        (void)((kk = (kk + 1)));
      }
      if (!(eq)) {
        (void)((j = (j + 1)));
        continue;
      }
      return codegen_module_import_path_len_at(cur_mod, j, dst);
    }
    return 0;
  }
}
int32_t codegen_emit_import_module_field_symbol(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if ((((ctx ==0) || (arena ==0)) || (out ==0))) {
      return -1;
    }
    if (((expr_ref <=0) || (expr_ref > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    uint8_t dep_path[128] = {};
    int32_t dep_path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &((dep_path)[0]));
    if (((((int32_t)(((e).kind))) !=44) || (dep_path_len <=0))) {
      return -1;
    }
    uint8_t pre[128] = {};
    (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((pre)[0]), 128));
    int32_t plen = 0;
    while (((plen < 128) && ((pre)[plen] !=0))) {
      (void)((plen = (plen + 1)));
    }
    if ((((plen > 0) && (codegen_c_prefix_redundant_with_name(&((pre)[0]), plen, &((((e).field_access_field_name))[0]), ((e).field_access_field_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre)[0]), plen) !=0))) {
      return -1;
    }
    if (((((e).field_access_field_len) > 0) && (codegen_emit_bytes_from_ptr(out, &((((e).field_access_field_name))[0]), ((e).field_access_field_len)) !=0))) {
      return -1;
    }
    return 0;
  }
}
int32_t codegen_emit_import_module_const_field(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if (((ctx ==0) || (((ctx)->current_codegen_module) ==0))) {
      return -1;
    }
    if (((expr_ref <=0) || (expr_ref > ((arena)->num_exprs)))) {
      return -1;
    }
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    uint8_t dep_path[128] = {};
    int32_t dep_path_len = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &((dep_path)[0]));
    if (((((int32_t)(((e).kind))) !=44) || (dep_path_len <=0))) {
      return -1;
    }
    int32_t dep_ix = codegen_find_dep_index_by_path(ctx, &((dep_path)[0]), dep_path_len);
    if (((dep_ix < 0) || (dep_ix >=pipeline_dep_ctx_ndep(ctx)))) {
      return -1;
    }
    struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if ((dep_mod ==0)) {
      return -1;
    }
    int32_t ti = 0;
    while ((ti < ((dep_mod)->num_top_level_lets))) {
      if ((pipeline_module_top_level_let_is_const(dep_mod, ti) ==0)) {
        (void)((ti = (ti + 1)));
        continue;
      }
      int32_t nlen = pipeline_module_top_level_let_name_len(dep_mod, ti);
      if ((nlen !=((e).field_access_field_len))) {
        (void)((ti = (ti + 1)));
        continue;
      }
      int nm_eq = 1;
      int32_t ni = 0;
      while ((ni < nlen)) {
        if ((pipeline_module_top_level_let_name_byte_at(dep_mod, ti, ni) !=(((e).field_access_field_name))[ni])) {
          (void)((nm_eq = 0));
          break;
        }
        (void)((ni = (ni + 1)));
      }
      if (!(nm_eq)) {
        (void)((ti = (ti + 1)));
        continue;
      }
      int32_t init_ref = pipeline_module_top_level_let_init_ref(dep_mod, ti);
      if ((((init_ref > 0) && (init_ref <=((arena)->num_exprs))) && (pipeline_expr_kind_ord_at(arena, init_ref) ==0))) {
        if ((codegen_format_int(out, ((int64_t)(pipeline_expr_int_val_at(arena, init_ref)))) !=0)) {
          return -1;
        }
        return 0;
      }
      if (((((e).field_access_field_len) > 0) && (codegen_emit_bytes_from_ptr(out, &((((e).field_access_field_name))[0]), ((e).field_access_field_len)) !=0))) {
        return -1;
      }
      return 0;
    }
    return -1;
  }
}
int32_t codegen_try_emit_match_field_bind(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, uint8_t * name, int32_t name_len) {
  {
    struct ast_Module * mod = 0;
    int32_t matched_ref = 0;
    if (((((arena ==0) || (out ==0)) || (name ==0)) || (name_len <=0))) {
      return 1;
    }
    if ((ctx !=0)) {
      (void)((mod = ((ctx)->current_codegen_module)));
    }
    if ((mod ==0)) {
      (void)((mod = pipeline_codegen_match_mod_c()));
    }
    if ((mod ==0)) {
      return 1;
    }
    if ((codegen_name_is_local_binding(arena, ctx, name, name_len) !=0)) {
      return 1;
    }
    if ((pipeline_codegen_match_name_is_subject_field_c(mod, arena, name, name_len) ==0)) {
      return 1;
    }
    (void)((matched_ref = pipeline_codegen_match_matched_ref_c()));
    if (((matched_ref <=0) || ast_ref_is_null(matched_ref))) {
      return 1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      return -1;
    }
    if ((codegen_emit_expr(arena, out, matched_ref, ctx) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 46) !=0)) {
      return -1;
    }
    if ((codegen_emit_bytes_64(out, &((name)[0]), name_len) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 41) !=0)) {
      return -1;
    }
    return 0;
  }
}
void codegen_match_push_subject(struct ast_Module * module, int32_t matched_ref, struct ast_ASTArena * arena) {
  {
    int32_t ty = 0;
    if (((((module ==0) || (arena ==0)) || (matched_ref <=0)) || ast_ref_is_null(matched_ref))) {
      (void)(pipeline_codegen_match_clear_subject_c());
      return;
    }
    (void)((ty = pipeline_expr_resolved_type_ref(arena, matched_ref)));
    (void)(pipeline_codegen_match_set_subject_c(module, matched_ref, ty));
  }
}
int32_t codegen_emit_match_arm_value(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t res_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if (ast_ref_is_null(res_ref)) {
      return codegen_append_byte(out, 48);
    }
    struct ast_Expr re = ast_ast_arena_expr_get(arena, res_ref);
    if ((((int32_t)(((re).kind))) ==41)) {
      if (ast_ref_is_null(((re).unary_operand_ref))) {
        return codegen_append_byte(out, 48);
      }
      return codegen_emit_expr(arena, out, ((re).unary_operand_ref), ctx);
    }
    return codegen_emit_expr(arena, out, res_ref, ctx);
  }
}
int32_t codegen_block_has_explicit_return(struct ast_ASTArena * arena, int32_t block_ref) {
  {
    if (((arena ==0) || ast_ref_is_null(block_ref))) {
      return 0;
    }
    if (((block_ref <=0) || (block_ref > ((arena)->num_blocks)))) {
      return 0;
    }
    int32_t ji = 0;
    int32_t nes = ast_ast_block_num_expr_stmts(arena, block_ref);
    while ((ji < nes)) {
      int32_t se_ref = ast_ast_block_expr_stmt_ref(arena, block_ref, ji);
      struct ast_Expr se = ast_ast_arena_expr_get(arena, se_ref);
      if ((((int32_t)(((se).kind))) ==41)) {
        return 1;
      }
      if (((((int32_t)(((se).kind))) ==26) && (codegen_block_has_explicit_return(arena, ((se).block_ref)) !=0))) {
        return 1;
      }
      (void)((ji = (ji + 1)));
    }
    int32_t fr = ast_ast_block_final_expr_ref(arena, block_ref);
    if (!(ast_ref_is_null(fr))) {
      struct ast_Expr fe = ast_ast_arena_expr_get(arena, fr);
      if ((((int32_t)(((fe).kind))) ==41)) {
        return 1;
      }
      if (((((int32_t)(((fe).kind))) ==26) && (codegen_block_has_explicit_return(arena, ((fe).block_ref)) !=0))) {
        return 1;
      }
    }
    int32_t ri = 0;
    int32_t nr = ast_ast_block_num_regions(arena, block_ref);
    while ((ri < nr)) {
      int32_t rb = ast_ast_block_region_body_ref(arena, block_ref, ri);
      if ((codegen_block_has_explicit_return(arena, rb) !=0)) {
        return 1;
      }
      (void)((ri = (ri + 1)));
    }
    return 0;
  }
}
int32_t codegen_match_arm_result_is_return_control(struct ast_ASTArena * arena, int32_t res_ref) {
  {
    if (ast_ref_is_null(res_ref)) {
      return 0;
    }
    struct ast_Expr re = ast_ast_arena_expr_get(arena, res_ref);
    if ((((int32_t)(((re).kind))) ==41)) {
      return 1;
    }
    if ((((int32_t)(((re).kind))) ==26)) {
      return codegen_block_has_explicit_return(arena, ((re).block_ref));
    }
    return 0;
  }
}
int32_t codegen_match_has_return_arm(struct ast_ASTArena * arena, int32_t expr_ref) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t n = ((e).match_num_arms);
    int32_t i = 0;
    while ((i < n)) {
      int32_t res = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
      if ((codegen_match_arm_result_is_return_control(arena, res) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_match_stmt_arm_body(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t res_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void) {
  {
    if (!(ast_ref_is_null(res_ref))) {
      struct ast_Expr re = ast_ast_arena_expr_get(arena, res_ref);
      if ((((int32_t)(((re).kind))) ==41)) {
        return codegen_emit_return_stmt_with_context(arena, out, (indent + 2), ((re).unary_operand_ref), ctx, fn_ret_void);
      }
      if (((((int32_t)(((re).kind))) ==26) && !(ast_ref_is_null(((re).block_ref))))) {
        return codegen_emit_block(arena, out, ((re).block_ref), (indent + 2), ctx);
      }
    }
    if ((codegen_emit_indent(out, (indent + 2)) !=0)) {
      return -1;
    }
    uint8_t v[9] = {40, 118, 111, 105, 100, 41, 40, 0, 0};
    if ((codegen_emit_bytes_9(out, &((v)[0]), 7) !=0)) {
      return -1;
    }
    if (ast_ref_is_null(res_ref)) {
      if ((codegen_append_byte(out, 48) !=0)) {
        return -1;
      }
    } else {
      if ((codegen_emit_expr(arena, out, res_ref, ctx) !=0)) {
        return -1;
      }
    }
    uint8_t sc[4] = {41, 59, 10, 0};
    return codegen_emit_bytes_4(out, &((sc)[0]), 3);
  }
}
int32_t codegen_emit_match_as_stmt(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t n = ((e).match_num_arms);
    int32_t matched = ((e).match_matched_ref);
    int32_t i = 0;
    int32_t opened = 0;
    int32_t wild_i = -1;
    uint8_t eq[3] = {61, 61, 0};
    uint8_t if_kw[4] = {105, 102, 32, 0};
    uint8_t else_if[11] = {125, 32, 101, 108, 115, 101, 32, 105, 102, 32, 0};
    uint8_t else_br[9] = {125, 32, 101, 108, 115, 101, 32, 123, 0};
    uint8_t open_br[4] = {41, 32, 123, 0};
    uint8_t close_br[3] = {125, 10, 0};
    uint8_t if1[8] = {105, 102, 32, 40, 49, 41, 32, 0};
    int32_t cmp_val = 0;
    int32_t res = 0;
    int32_t guard_ref = 0;
    uint8_t and_and[3] = {38, 38, 0};
    struct ast_Module * prev_mod = pipeline_codegen_match_mod_c();
    int32_t prev_mref = pipeline_codegen_match_matched_ref_c();
    int32_t prev_ty = pipeline_codegen_match_subject_ty_c();
    struct ast_Module * cur_mod = 0;
    if ((ctx !=0)) {
      (void)((cur_mod = ((ctx)->current_codegen_module)));
    }
    if ((cur_mod !=0)) {
      (void)(codegen_match_push_subject(cur_mod, matched, arena));
    }
    while ((i < n)) {
      (void)((guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, i)));
      if (((pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i) !=0) && (ast_ref_is_null(guard_ref) || (guard_ref <=0)))) {
        (void)((wild_i = i));
      } else {
        if ((codegen_emit_indent(out, indent) !=0)) {
          return -1;
        }
        if ((opened ==0)) {
          if ((codegen_emit_bytes_from_ptr(out, &((if_kw)[0]), 3) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_emit_bytes_from_ptr(out, &((else_if)[0]), 10) !=0)) {
            return -1;
          }
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i) !=0)) {
          if ((codegen_emit_expr(arena, out, guard_ref, ctx) !=0)) {
            return -1;
          }
        } else {
          if ((ast_ref_is_null(matched) || (codegen_emit_expr(arena, out, matched, ctx) !=0))) {
            return -1;
          }
          if ((codegen_emit_bytes_2(out, &((eq)[0]), 2) !=0)) {
            return -1;
          }
          if ((pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, i) !=0)) {
            (void)((cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, i)));
          } else {
            (void)((cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, i)));
          }
          if ((codegen_format_int(out, ((int64_t)(cmp_val))) !=0)) {
            return -1;
          }
          if ((!(ast_ref_is_null(guard_ref)) && (guard_ref > 0))) {
            if ((codegen_emit_bytes_2(out, &((and_and)[0]), 2) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 40) !=0)) {
              return -1;
            }
            if ((codegen_emit_expr(arena, out, guard_ref, ctx) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 41) !=0)) {
              return -1;
            }
          }
        }
        if ((codegen_emit_bytes_from_ptr(out, &((open_br)[0]), 3) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 10) !=0)) {
          return -1;
        }
        (void)((res = pipeline_expr_match_arm_result_ref(arena, expr_ref, i)));
        if ((codegen_emit_match_stmt_arm_body(arena, out, res, indent, ctx, fn_ret_void) !=0)) {
          return -1;
        }
        (void)((opened = 1));
      }
      (void)((i = (i + 1)));
    }
    if ((wild_i >=0)) {
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      if ((opened !=0)) {
        if ((codegen_emit_bytes_from_ptr(out, &((else_br)[0]), 8) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 10) !=0)) {
          return -1;
        }
      } else {
        if ((codegen_emit_bytes_from_ptr(out, &((if1)[0]), 7) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 123) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 10) !=0)) {
          return -1;
        }
      }
      (void)((res = pipeline_expr_match_arm_result_ref(arena, expr_ref, wild_i)));
      if ((codegen_emit_match_stmt_arm_body(arena, out, res, indent, ctx, fn_ret_void) !=0)) {
        return -1;
      }
      (void)((opened = 1));
    }
    if ((opened !=0)) {
      if ((codegen_emit_indent(out, indent) !=0)) {
        (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
        return -1;
      }
      (void)(({   int32_t brc = codegen_emit_bytes_3(out, &((close_br)[0]), 2);
  (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
  return brc;
 }));
    }
    (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
    return 0;
  }
}
int32_t codegen_emit_match_from_arm(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx, int32_t arm_i) {
  {
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t n = ((e).match_num_arms);
    int32_t matched = ((e).match_matched_ref);
    int32_t res = 0;
    int32_t cmp_val = 0;
    int32_t guard_ref = 0;
    uint8_t eq[3] = {61, 61, 0};
    uint8_t and_and[3] = {38, 38, 0};
    struct ast_Module * prev_mod = pipeline_codegen_match_mod_c();
    int32_t prev_mref = pipeline_codegen_match_matched_ref_c();
    int32_t prev_ty = pipeline_codegen_match_subject_ty_c();
    struct ast_Module * cur_mod = 0;
    int32_t rc = 0;
    if ((arm_i >=n)) {
      return codegen_append_byte(out, 48);
    }
    if ((ctx !=0)) {
      (void)((cur_mod = ((ctx)->current_codegen_module)));
    }
    if ((cur_mod !=0)) {
      (void)(codegen_match_push_subject(cur_mod, matched, arena));
    }
    (void)((guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, arm_i)));
    (void)((res = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i)));
    if (((pipeline_expr_match_arm_is_wildcard(arena, expr_ref, arm_i) !=0) && (ast_ref_is_null(guard_ref) || (guard_ref <=0)))) {
      (void)((rc = codegen_emit_match_arm_value(arena, out, res, ctx)));
      (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
      return rc;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
      return -1;
    }
    if ((pipeline_expr_match_arm_is_wildcard(arena, expr_ref, arm_i) !=0)) {
      if ((codegen_emit_expr(arena, out, guard_ref, ctx) !=0)) {
        (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
        return -1;
      }
    } else {
      if ((codegen_append_byte(out, 40) !=0)) {
        (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
        return -1;
      }
      if ((ast_ref_is_null(matched) || (codegen_emit_expr(arena, out, matched, ctx) !=0))) {
        (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
        return -1;
      }
      if ((codegen_emit_bytes_2(out, &((eq)[0]), 2) !=0)) {
        (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
        return -1;
      }
      if ((pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i) !=0)) {
        (void)((cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i)));
      } else {
        (void)((cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, arm_i)));
      }
      if ((codegen_format_int(out, ((int64_t)(cmp_val))) !=0)) {
        (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
        return -1;
      }
      if ((!(ast_ref_is_null(guard_ref)) && (guard_ref > 0))) {
        if ((codegen_emit_bytes_2(out, &((and_and)[0]), 2) !=0)) {
          (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
          return -1;
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
          return -1;
        }
        if ((codegen_emit_expr(arena, out, guard_ref, ctx) !=0)) {
          (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
          return -1;
        }
      }
    }
    if ((codegen_append_byte(out, 63) !=0)) {
      (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
      return -1;
    }
    if ((codegen_append_byte(out, 40) !=0)) {
      (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
      return -1;
    }
    if ((codegen_emit_match_arm_value(arena, out, res, ctx) !=0)) {
      (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
      return -1;
    }
    if ((codegen_append_byte(out, 41) !=0)) {
      (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
      return -1;
    }
    if ((codegen_append_byte(out, 58) !=0)) {
      (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
      return -1;
    }
    (void)(pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty));
    if ((codegen_emit_match_from_arm(arena, out, expr_ref, ctx, (arm_i + 1)) !=0)) {
      return -1;
    }
    return codegen_append_byte(out, 41);
  }
}
int32_t codegen_emit_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t expr_ref, struct ast_PipelineDepCtx * ctx) {
  {
    if (ast_ref_is_null(expr_ref)) {
      return 0;
    }
    if (((expr_ref <=0) || (expr_ref > ((arena)->num_exprs)))) {
      return 0;
    }
    struct ast_Expr e = ast_ast_arena_expr_get(arena, expr_ref);
    if ((((((e).const_folded_valid) !=0) && (pipeline_expr_kind_ord_at(arena, expr_ref) !=3)) && (pipeline_expr_kind_ord_at(arena, expr_ref) !=1))) {
      if ((codegen_format_int(out, ((int64_t)(((e).const_folded_val)))) !=0)) {
        return -1;
      }
      return 0;
    }
    if ((pipeline_expr_kind_ord_at(arena, expr_ref) ==59)) {
      int32_t slen = ((e).var_name_len);
      int emit_slice = 0;
      if ((slen < 0)) {
        (void)((slen = 0));
      }
      if ((slen > 64)) {
        (void)((slen = 64));
      }
      if (((!(ast_ref_is_null(((e).resolved_type_ref))) && (((e).resolved_type_ref) > 0)) && (((e).resolved_type_ref) <=((arena)->num_types)))) {
        struct ast_Type sty = ast_ast_arena_type_get(arena, ((e).resolved_type_ref));
        if ((((int32_t)(((sty).kind))) ==11)) {
          (void)((emit_slice = 1));
        }
      }
      uint8_t cast_open[14] = {40, 40, 117, 105, 110, 116, 56, 95, 116, 32, 42, 41, 34, 0};
      if (emit_slice) {
        uint8_t slice_mid[13] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0};
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((codegen_emit_type(arena, out, ((e).resolved_type_ref), 0, 0, ctx) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((slice_mid)[0]), 12) !=0)) {
          return -1;
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((cast_open)[0]), 13) !=0)) {
        return -1;
      }
      int32_t si = 0;
      while ((si < slen)) {
        int32_t b = ((int32_t)((((e).var_name))[si]));
        if ((b < 0)) {
          (void)((b = (b + 256)));
        }
        if ((b > 255)) {
          (void)((b = (b & 255)));
        }
        if ((codegen_append_byte(out, 92) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 120) !=0)) {
          return -1;
        }
        int32_t hi = (b / 16);
        int32_t lo = (b - (hi * 16));
        uint8_t hex[17] = {48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102, 0};
        if ((codegen_append_byte(out, (hex)[hi]) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, (hex)[lo]) !=0)) {
          return -1;
        }
        (void)((si = (si + 1)));
      }
      if ((codegen_append_byte(out, 34) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      if (emit_slice) {
        uint8_t slice_tail[18] = {32, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((slice_tail)[0]), 13) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, slen) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 125) !=0)) {
          return -1;
        }
        return 0;
      }
      return 0;
    }
    if ((((int32_t)(((e).kind))) ==0)) {
      return codegen_format_int(out, ((e).int_val));
    }
    if ((((int32_t)(((e).kind))) ==2)) {
      if ((((e).int_val) !=0)) {
        return codegen_append_byte(out, 49);
      }
      return codegen_append_byte(out, 48);
    }
    if ((((int32_t)(((e).kind))) ==3)) {
      if (((((e).var_name_len) > 0) && ((((e).var_name))[0] > 32))) {
        if ((((((((e).var_name_len) ==3) && ((((e).var_name))[0] ==109)) && ((((e).var_name))[1] ==115)) && ((((e).var_name))[2] ==103)) && (ctx !=0))) {
          int use_l0 = 0;
          if (((((ctx)->current_block_ref) !=0) && (((ctx)->current_block_ref) <=((arena)->num_blocks)))) {
            if (((ast_ast_block_num_lets(arena, ((ctx)->current_block_ref)) >=1) && (pipeline_block_let_name_len(arena, ((ctx)->current_block_ref), 0) ==0))) {
              (void)((use_l0 = 1));
            }
          }
          if (use_l0) {
            uint8_t l0[4] = {95, 108, 48, 0};
            return codegen_emit_bytes_4(out, &((l0)[0]), 3);
          }
        }
        (void)(({   int32_t mfb = codegen_try_emit_match_field_bind(arena, out, ctx, &((((e).var_name))[0]), ((e).var_name_len));
  if ((mfb ==0)) {
    return 0;
  }
  if ((mfb < 0)) {
    return -1;
  }
 }));
        int32_t fn_val = codegen_try_emit_fn_as_value(out, arena, ctx, &((((e).var_name))[0]), ((e).var_name_len));
        if ((fn_val ==0)) {
          return 0;
        }
        if ((fn_val < 0)) {
          return -1;
        }
        return codegen_emit_bytes_64(out, &((((e).var_name))[0]), ((e).var_name_len));
      }
      if (((ctx !=0) && (((ctx)->emit_expr_as_callee) !=0))) {
        uint8_t fallback[3] = {95, 48, 0};
        return codegen_emit_bytes_3(out, &((fallback)[0]), 2);
      }
      if ((ctx !=0)) {
        if ((((ctx)->current_func_single_empty_param_index) >=0)) {
          uint8_t place[4] = {95, 112, 48, 0};
          if ((codegen_emit_bytes_4(out, &((place)[0]), 2) !=0)) {
            return -1;
          }
          return codegen_format_int(out, ((ctx)->current_func_single_empty_param_index));
        }
        if (((((ctx)->current_func_empty_param_count) >=2) && (((ctx)->current_emit_empty_var_next_index) < ((ctx)->current_func_empty_param_count)))) {
          int32_t param_idx = pipeline_dep_ctx_empty_param_at(ctx, ((ctx)->current_emit_empty_var_next_index));
          uint8_t place[4] = {95, 112, 48, 0};
          if ((codegen_emit_bytes_4(out, &((place)[0]), 2) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, param_idx) !=0)) {
            return -1;
          }
          (void)((((ctx)->current_emit_empty_var_next_index) = (((ctx)->current_emit_empty_var_next_index) + 1)));
          return 0;
        }
      }
      uint8_t fallback[3] = {95, 48, 0};
      return codegen_emit_bytes_3(out, &((fallback)[0]), 2);
    }
    if ((((int32_t)(((e).kind))) ==54)) {
      int32_t as_tgt = ((e).as_target_type_ref);
      if (!(ast_ref_is_null(as_tgt))) {
        (void)((as_tgt = pipeline_typeck_resolve_type_alias_ref_c(arena, as_tgt)));
        (void)((as_tgt = codegen_mono_subst_type(ctx, arena, as_tgt)));
      }
      int32_t as_struct = 0;
      if ((((!(ast_ref_is_null(as_tgt)) && (ctx !=0)) && (((ctx)->current_codegen_module) !=0)) && (codegen_type_is_module_user_struct(((ctx)->current_codegen_module), arena, as_tgt) !=0))) {
        (void)((as_struct = 1));
      }
      int32_t op_ty = 0;
      int32_t as_op_struct = 0;
      if (((!(ast_ref_is_null(((e).as_operand_ref))) && (ctx !=0)) && (((ctx)->current_codegen_module) !=0))) {
        (void)((op_ty = pipeline_expr_resolved_type_ref(arena, ((e).as_operand_ref))));
        if (!(ast_ref_is_null(op_ty))) {
          (void)((op_ty = pipeline_typeck_resolve_type_alias_ref_c(arena, op_ty)));
          (void)((op_ty = codegen_mono_subst_type(ctx, arena, op_ty)));
          if ((!(ast_ref_is_null(op_ty)) && (codegen_type_is_module_user_struct(((ctx)->current_codegen_module), arena, op_ty) !=0))) {
            (void)((as_op_struct = 1));
          }
        }
      }
      if ((((((as_struct !=0) && (as_op_struct !=0)) && !(ast_ref_is_null(op_ty))) && !(ast_ref_is_null(as_tgt))) && (pipeline_typeck_type_refs_equal_c(arena, op_ty, as_tgt) !=0))) {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((!(ast_ref_is_null(((e).as_operand_ref))) && (codegen_emit_expr(arena, out, ((e).as_operand_ref), ctx) !=0))) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      if (((as_op_struct !=0) && !(ast_ref_is_null(op_ty)))) {
        uint8_t as_pun_open[4] = {40, 123, 32, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((as_pun_open)[0]), 3) !=0)) {
          return -1;
        }
        if ((codegen_emit_type(arena, out, op_ty, 0, 0, ctx) !=0)) {
          return -1;
        }
        uint8_t as_pun_nm[20] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 115, 95, 111, 32, 61, 32, 40, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((as_pun_nm)[0]), 17) !=0)) {
          return -1;
        }
        if ((!(ast_ref_is_null(((e).as_operand_ref))) && (codegen_emit_expr(arena, out, ((e).as_operand_ref), ctx) !=0))) {
          return -1;
        }
        uint8_t as_pun_mid[8] = {41, 59, 32, 42, 40, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((as_pun_mid)[0]), 5) !=0)) {
          return -1;
        }
        if ((codegen_emit_type(arena, out, ((e).as_target_type_ref), 0, 0, ctx) !=0)) {
          return -1;
        }
        uint8_t as_pun_end[32] = {32, 42, 41, 40, 118, 111, 105, 100, 32, 42, 41, 38, 95, 95, 120, 108, 97, 110, 103, 95, 97, 115, 95, 111, 59, 32, 125, 41, 0, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((as_pun_end)[0]), 28) !=0)) {
          return -1;
        }
        return 0;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_type(arena, out, ((e).as_target_type_ref), 0, 0, ctx) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      if ((as_struct !=0)) {
        if ((codegen_append_byte(out, 123) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((!(ast_ref_is_null(((e).as_operand_ref))) && (codegen_emit_expr(arena, out, ((e).as_operand_ref), ctx) !=0))) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 125) !=0)) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).as_operand_ref))) && (codegen_emit_expr(arena, out, ((e).as_operand_ref), ctx) !=0))) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      return 0;
    }
    if ((((int32_t)(((e).kind))) ==41)) {
      uint8_t op[9] = {114, 101, 116, 117, 114, 110, 32, 0, 0};
      if ((codegen_emit_bytes_9(out, &((op)[0]), 7) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).unary_operand_ref))) && (codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0))) {
        return -1;
      }
      return 0;
    }
    if ((((int32_t)(((e).kind))) ==26)) {
      uint8_t open[4] = {40, 123, 32, 0};
      if ((codegen_emit_bytes_4(out, &((open)[0]), 3) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).block_ref))) && (codegen_emit_block(arena, out, ((e).block_ref), 2, ctx) !=0))) {
        return -1;
      }
      uint8_t tail[8] = {32, 125, 41, 0, 0, 0, 0, 0};
      return codegen_emit_bytes_8(out, &((tail)[0]), 3);
    }
    if ((((int32_t)(((e).kind))) ==4)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 43, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==5)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 45, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==28)) {
      int32_t lt_ref = pipeline_expr_resolved_type_ref(arena, ((e).binop_left_ref));
      int32_t is_fa = 0;
      if (((lt_ref > 0) && (pipeline_type_kind_ord_at(arena, lt_ref) ==10))) {
        (void)((is_fa = 1));
      }
      if ((is_fa !=0)) {
        uint8_t pref[16] = {109, 101, 109, 99, 112, 121, 40, 40, 118, 111, 105, 100, 42, 41, 40, 0};
        uint8_t mid[20] = {41, 44, 32, 40, 99, 111, 110, 115, 116, 32, 118, 111, 105, 100, 42, 41, 40, 0, 0, 0};
        uint8_t mid_sz[12] = {41, 44, 32, 115, 105, 122, 101, 111, 102, 40, 0, 0};
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((pref)[0]), 15) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((mid)[0]), 17) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((mid_sz)[0]), 10) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 61, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if (((((((((((((int32_t)(((e).kind))) ==29) || (((int32_t)(((e).kind))) ==30)) || (((int32_t)(((e).kind))) ==31)) || (((int32_t)(((e).kind))) ==32)) || (((int32_t)(((e).kind))) ==33)) || (((int32_t)(((e).kind))) ==34)) || (((int32_t)(((e).kind))) ==35)) || (((int32_t)(((e).kind))) ==36)) || (((int32_t)(((e).kind))) ==37)) || (((int32_t)(((e).kind))) ==38))) {
      uint8_t op_buf[8] = {32, 43, 61, 32, 0, 0, 0, 0};
      int32_t op_len = 4;
      if ((((int32_t)(((e).kind))) ==29)) {
        (void)(((op_buf)[1] = 43));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==30)) {
        (void)(((op_buf)[1] = 45));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==31)) {
        (void)(((op_buf)[1] = 42));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==32)) {
        (void)(((op_buf)[1] = 47));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==33)) {
        (void)(((op_buf)[1] = 37));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==34)) {
        (void)(((op_buf)[1] = 38));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==35)) {
        (void)(((op_buf)[1] = 124));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==36)) {
        (void)(((op_buf)[1] = 94));
        (void)(((op_buf)[2] = 61));
        (void)((op_len = 4));
      }
      if ((((int32_t)(((e).kind))) ==37)) {
        (void)(((op_buf)[1] = 60));
        (void)(((op_buf)[2] = 60));
        (void)(((op_buf)[3] = 61));
        (void)(((op_buf)[4] = 32));
        (void)((op_len = 5));
      }
      if ((((int32_t)(((e).kind))) ==38)) {
        (void)(((op_buf)[1] = 62));
        (void)(((op_buf)[2] = 62));
        (void)(((op_buf)[3] = 61));
        (void)(((op_buf)[4] = 32));
        (void)((op_len = 5));
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_8(out, &((op_buf)[0]), op_len) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==22)) {
      uint8_t pre[3] = {45, 40, 0};
      if ((codegen_emit_bytes_3(out, &((pre)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==51)) {
      uint8_t pre_a[3] = {38, 40, 0};
      if ((codegen_emit_bytes_3(out, &((pre_a)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==52)) {
      uint8_t pre_d[3] = {42, 40, 0};
      if ((codegen_emit_bytes_3(out, &((pre_d)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==58)) {
      int32_t op_ref = ((e).unary_operand_ref);
      int32_t op_ty_ref = 0;
      uint8_t open[4] = {40, 123, 32, 0};
      uint8_t tmp_name[16] = {95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 0};
      uint8_t assign_mid[5] = {32, 61, 32, 0, 0};
      uint8_t if_open[38] = {59, 32, 105, 102, 32, 40, 40, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 41, 46, 101, 114, 114, 32, 33, 61, 32, 48, 41, 32, 123, 32, 114, 101};
      uint8_t turn_mid[41] = {116, 117, 114, 110, 32, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 59, 32, 125, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 116, 114, 121, 95, 116, 109, 112, 0};
      uint8_t value_tail[7] = {41, 46, 118, 97, 108, 117, 101};
      uint8_t close_tail[4] = {59, 32, 125, 41};
      if (((ast_ref_is_null(op_ref) || (op_ref <=0)) || (op_ref > ((arena)->num_exprs)))) {
        return -1;
      }
      (void)((op_ty_ref = pipeline_expr_resolved_type_ref(arena, op_ref)));
      if (ast_ref_is_null(op_ty_ref)) {
        return -1;
      }
      if ((codegen_emit_bytes_4(out, &((open)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_type(arena, out, op_ty_ref, 0, 0, ctx) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((tmp_name)[0]), 14) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_5(out, &((assign_mid)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, op_ref, ctx) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((if_open)[0]), 37) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((turn_mid)[0]), 38) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_from_ptr(out, &((value_tail)[0]), 7) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_4(out, &((close_tail)[0]), 4) !=0)) {
        return -1;
      }
      return 0;
    }
    if ((((int32_t)(((e).kind))) ==55)) {
      if ((!(ast_ref_is_null(((e).unary_operand_ref))) && (codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0))) {
        return -1;
      }
      return 0;
    }
    if (((((int32_t)(((e).kind))) ==56) || (((int32_t)(((e).kind))) ==57))) {
      int32_t op_ref = ((e).unary_operand_ref);
      int32_t dep_ix = -1;
      int32_t func_ix = -1;
      struct ast_Module * target_mod = 0;
      int32_t n_args = 0;
      int32_t num_params = 0;
      int32_t ai = 0;
      int32_t op_is_call = 0;
      uint8_t reset_name[26] = {120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116};
      uint8_t comma[3] = {44, 32, 0};
      if (((ctx ==0) || (((ctx)->current_codegen_module) ==0))) {
        return -1;
      }
      if (((ast_ref_is_null(op_ref) || (op_ref <=0)) || (op_ref > ((arena)->num_exprs)))) {
        return -1;
      }
      struct ast_Expr op = ast_ast_arena_expr_get(arena, op_ref);
      if ((((int32_t)(((op).kind))) ==48)) {
        (void)((op_is_call = 1));
      } else {
        if ((((int32_t)(((op).kind))) !=49)) {
          return -1;
        }
      }
      if ((((((int32_t)(((e).kind))) ==56) && (((int32_t)(((op).kind))) ==49)) && (codegen_emit_async_method_call_run(arena, out, op_ref, ctx) ==0))) {
        return 0;
      }
      if ((((op_is_call !=0) && (((op).call_callee_ref) > 0)) && (((op).call_callee_ref) <=((arena)->num_exprs)))) {
        struct ast_Expr fast_callee = ast_ast_arena_expr_get(arena, ((op).call_callee_ref));
        if (((((int32_t)(((fast_callee).kind))) ==44) && (codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, ((((int32_t)(((e).kind))) ==57) ? 1 : 0)) ==0))) {
          return 0;
        }
      }
      (void)((dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, op_ref)));
      if (((dep_ix < 0) && (op_is_call !=0))) {
        (void)((dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, ((op).call_callee_ref))));
      }
      if ((dep_ix >=0)) {
        if ((dep_ix >=pipeline_dep_ctx_ndep(ctx))) {
          return -1;
        }
        (void)((target_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
      } else {
        (void)((target_mod = ((ctx)->current_codegen_module)));
      }
      if ((target_mod !=0)) {
        (void)((func_ix = codegen_resolve_call_target_func_index(arena, target_mod, op_ref)));
      }
      if (((dep_ix >=0) && (((target_mod ==0) || (func_ix < 0)) || (func_ix >=((target_mod)->num_funcs))))) {
        return codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, ((((int32_t)(((e).kind))) ==57) ? 1 : 0));
      }
      if ((target_mod ==0)) {
        return -1;
      }
      if (((func_ix < 0) || (func_ix >=((target_mod)->num_funcs)))) {
        return -1;
      }
      if ((op_is_call !=0)) {
        (void)((n_args = ((op).call_num_args)));
      } else {
        (void)((n_args = ((op).method_call_num_args)));
      }
      if ((n_args < 0)) {
        return -1;
      }
      (void)((num_params = pipeline_module_func_num_params_at(target_mod, func_ix)));
      if ((((int32_t)(((e).kind))) ==56)) {
        if ((n_args > 0)) {
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          if ((codegen_emit_bytes_from_ptr(out, &((reset_name)[0]), 25) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -1;
          }
          (void)((ai = 0));
          while ((ai < n_args)) {
            int32_t arg_ref = 0;
            int32_t param_type_ref = 0;
            if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
              return -1;
            }
            if ((op_is_call !=0)) {
              (void)((arg_ref = pipeline_expr_call_arg_ref(arena, op_ref, ai)));
            } else {
              (void)((arg_ref = pipeline_expr_method_call_arg_ref(arena, op_ref, ai)));
            }
            if ((ai < num_params)) {
              (void)((param_type_ref = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai)));
            }
            if ((codegen_emit_async_run_seed_push_name(out, arena, param_type_ref) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 40) !=0)) {
              return -1;
            }
            if ((!(ast_ref_is_null(arg_ref)) && (codegen_emit_expr(arena, out, arg_ref, ctx) !=0))) {
              return -1;
            }
            if ((codegen_append_byte(out, 41) !=0)) {
              return -1;
            }
            (void)((ai = (ai + 1)));
          }
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
          if ((codegen_emit_async_sched_call(out, target_mod, func_ix) !=0)) {
            return -1;
          }
          return codegen_append_byte(out, 41);
        }
        return codegen_emit_async_sched_call(out, target_mod, func_ix);
      }
      if ((n_args > 0)) {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        (void)((ai = 0));
        while ((ai < n_args)) {
          int32_t arg_ref2 = 0;
          int32_t param_type_ref2 = 0;
          if (((ai > 0) && (codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0))) {
            return -1;
          }
          if ((op_is_call !=0)) {
            (void)((arg_ref2 = pipeline_expr_call_arg_ref(arena, op_ref, ai)));
          } else {
            (void)((arg_ref2 = pipeline_expr_method_call_arg_ref(arena, op_ref, ai)));
          }
          if ((ai < num_params)) {
            (void)((param_type_ref2 = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai)));
          }
          if ((codegen_emit_async_run_seed_push_name(out, arena, param_type_ref2) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          if ((!(ast_ref_is_null(arg_ref2)) && (codegen_emit_expr(arena, out, arg_ref2, ctx) !=0))) {
            return -1;
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -1;
          }
          (void)((ai = (ai + 1)));
        }
        if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
          return -1;
        }
        if ((codegen_emit_async_task_submit_call(out, target_mod, func_ix) !=0)) {
          return -1;
        }
        return codegen_append_byte(out, 41);
      }
      return codegen_emit_async_task_submit_call(out, target_mod, func_ix);
    }
    if ((((int32_t)(((e).kind))) ==25)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).if_cond_ref))) && (codegen_emit_expr(arena, out, ((e).if_cond_ref), ctx) !=0))) {
        return -1;
      }
      uint8_t q[4] = {32, 63, 32, 0};
      if ((codegen_emit_bytes_4(out, &((q)[0]), 3) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).if_then_ref))) && (codegen_emit_expr(arena, out, ((e).if_then_ref), ctx) !=0))) {
        return -1;
      }
      uint8_t colon[4] = {32, 58, 32, 0};
      if ((codegen_emit_bytes_4(out, &((colon)[0]), 3) !=0)) {
        return -1;
      }
      if (!(ast_ref_is_null(((e).if_else_ref)))) {
        if ((codegen_emit_expr(arena, out, ((e).if_else_ref), ctx) !=0)) {
          return -1;
        }
      } else {
        if ((codegen_append_byte(out, 48) !=0)) {
          return -1;
        }
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==48)) {
      int32_t callee_ref = ((e).call_callee_ref);
      if ((ctx !=0)) {
        int32_t fmt_lit_rc = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if ((fmt_lit_rc < 0)) {
          return -1;
        }
        if ((fmt_lit_rc > 0)) {
          return 0;
        }
      }
      if ((ctx !=0)) {
        int32_t sa_rc = codegen_try_emit_size_align_of_call(arena, out, expr_ref, ctx);
        if ((sa_rc < 0)) {
          return -1;
        }
        if ((sa_rc > 0)) {
          return 0;
        }
      }
      if (((((!(ast_ref_is_null(callee_ref)) && (callee_ref > 0)) && (callee_ref <=((arena)->num_exprs))) && (ctx !=0)) && (((ctx)->current_codegen_module) !=0))) {
        uint8_t sym_buf[128] = {};
        int32_t imp_j = -1;
        int32_t sym_len = pipeline_asm_resolve_whole_import_qualified_symbol_c(arena, ((ctx)->current_codegen_module), callee_ref, &((sym_buf)[0]), &(imp_j));
        if (((sym_len > 0) && (sym_len < 128))) {
          struct ast_Expr callee_q = ast_ast_arena_expr_get(arena, callee_ref);
          uint8_t * fn_ptr_q = 0;
          int32_t fn_len_q = 0;
          if (((((int32_t)(((callee_q).kind))) ==44) && (((callee_q).field_access_field_len) > 0))) {
            (void)((fn_ptr_q = &((((callee_q).field_access_field_name))[0])));
            (void)((fn_len_q = ((callee_q).field_access_field_len)));
          } else {
            if (((((int32_t)(((callee_q).kind))) ==3) && (((callee_q).var_name_len) > 0))) {
              (void)((fn_ptr_q = &((((callee_q).var_name))[0])));
              (void)((fn_len_q = ((callee_q).var_name_len)));
            }
          }
          struct ast_Module * dep_mod_q = 0;
          if (((imp_j >=0) && (imp_j < pipeline_dep_ctx_ndep(ctx)))) {
            (void)((dep_mod_q = pipeline_dep_ctx_module_at(ctx, imp_j)));
          }
          int32_t mangled_emitted = 0;
          if ((((fn_len_q > 0) && (fn_len_q <=sym_len)) && (dep_mod_q !=0))) {
            int32_t pre_len_q = (sym_len - fn_len_q);
            if ((pre_len_q > 0)) {
              if ((codegen_emit_bytes_from_ptr(out, &((sym_buf)[0]), pre_len_q) !=0)) {
                return -1;
              }
            }
            if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_q, fn_ptr_q, fn_len_q) !=0)) {
              return -1;
            }
            (void)((mangled_emitted = 1));
          }
          if ((mangled_emitted ==0)) {
            if ((codegen_emit_bytes_from_ptr(out, &((sym_buf)[0]), sym_len) !=0)) {
              return -1;
            }
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          int32_t n_q = ((e).call_num_args);
          int32_t ai_q = 0;
          while ((ai_q < n_q)) {
            if ((ai_q > 0)) {
              uint8_t comma_q[3] = {44, 32, 0};
              if ((codegen_emit_bytes_3(out, &((comma_q)[0]), 2) !=0)) {
                return -1;
              }
            }
            if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_q))) {
              if ((codegen_append_byte(out, 48) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_q), ctx) !=0)) {
                return -1;
              }
            }
            (void)((ai_q = (ai_q + 1)));
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -1;
          }
          return 0;
        }
      }
      if (((((!(ast_ref_is_null(callee_ref)) && (callee_ref > 0)) && (callee_ref <=((arena)->num_exprs))) && (ctx !=0)) && (pipeline_dep_ctx_ndep(ctx) > 0))) {
        int32_t dep_ix_fast = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        struct ast_Expr callee_fast = ast_ast_arena_expr_get(arena, callee_ref);
        if (((((dep_ix_fast >=0) && (dep_ix_fast < pipeline_dep_ctx_ndep(ctx))) && (((int32_t)(((callee_fast).kind))) ==44)) && (((callee_fast).field_access_field_len) > 0))) {
          struct ast_Module * dep_mod_chk = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
          int32_t field_in_dep = 0;
          if ((dep_mod_chk !=0)) {
            int32_t fi_c = 0;
            while ((fi_c < ((dep_mod_chk)->num_funcs))) {
              int32_t fl = pipeline_module_func_name_len_at(dep_mod_chk, fi_c);
              if (((fl ==((callee_fast).field_access_field_len)) && (fl > 0))) {
                uint8_t fnc[128] = {};
                (void)(pipeline_module_func_name_copy64(dep_mod_chk, fi_c, &((fnc)[0])));
                int32_t eqc = 1;
                int32_t ic = 0;
                while ((ic < fl)) {
                  if (((fnc)[ic] !=(((callee_fast).field_access_field_name))[ic])) {
                    (void)((eqc = 0));
                    (void)((ic = fl));
                  } else {
                    (void)((ic = (ic + 1)));
                  }
                }
                if ((eqc !=0)) {
                  (void)((field_in_dep = 1));
                  (void)((fi_c = ((dep_mod_chk)->num_funcs)));
                } else {
                  (void)((fi_c = (fi_c + 1)));
                }
              } else {
                (void)((fi_c = (fi_c + 1)));
              }
            }
          }
          if ((field_in_dep !=0)) {
            uint8_t dep_path_fast[128] = {};
            (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, &((dep_path_fast)[0])));
            uint8_t pre_fast[128] = {};
            (void)(codegen_import_path_to_c_prefix_into(&((dep_path_fast)[0]), &((pre_fast)[0]), 128));
            int32_t pre_fast_len = 0;
            while (((pre_fast_len < 128) && ((pre_fast)[pre_fast_len] !=0))) {
              (void)((pre_fast_len = (pre_fast_len + 1)));
            }
            int32_t drv_buf_fast = 0;
            if ((codegen_path_is_std_io_driver_bytes(&((dep_path_fast)[0])) !=0)) {
              (void)((drv_buf_fast = codegen_emit_io_driver_buf_call_name(out, &((((callee_fast).field_access_field_name))[0]), ((callee_fast).field_access_field_len), ((e).call_num_args))));
              if ((drv_buf_fast < 0)) {
                return -1;
              }
            }
            if ((drv_buf_fast ==0)) {
              if ((((pre_fast_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_fast)[0]), pre_fast_len, &((((callee_fast).field_access_field_name))[0]), ((callee_fast).field_access_field_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_fast)[0]), pre_fast_len) !=0))) {
                return -1;
              }
              struct ast_Module * dep_mod_fast = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
              if ((dep_mod_fast ==0)) {
                (void)((dep_mod_fast = ((ctx)->current_codegen_module)));
              }
              if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_fast, &((((callee_fast).field_access_field_name))[0]), ((callee_fast).field_access_field_len)) !=0)) {
                return -1;
              }
            }
            if ((codegen_append_byte(out, 40) !=0)) {
              return -1;
            }
            int32_t ai_fast = 0;
            while ((ai_fast < ((e).call_num_args))) {
              if ((ai_fast > 0)) {
                uint8_t comma_fast[3] = {44, 32, 0};
                if ((codegen_emit_bytes_3(out, &((comma_fast)[0]), 2) !=0)) {
                  return -1;
                }
              }
              if (((drv_buf_fast !=0) && (ai_fast ==0))) {
                uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                  return -1;
                }
              }
              if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast))) {
                if ((codegen_append_byte(out, 48) !=0)) {
                  return -1;
                }
              } else {
                if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast), ctx) !=0)) {
                  return -1;
                }
              }
              (void)((ai_fast = (ai_fast + 1)));
            }
            if ((codegen_append_byte(out, 41) !=0)) {
              return -1;
            }
            return 0;
          }
        }
      }
      if ((((((!(ast_ref_is_null(callee_ref)) && (callee_ref > 0)) && (callee_ref <=((arena)->num_exprs))) && (ctx !=0)) && (pipeline_dep_ctx_ndep(ctx) > 0)) && (((ctx)->current_codegen_module) !=0))) {
        struct ast_Expr callee = ast_ast_arena_expr_get(arena, callee_ref);
        struct ast_Module * cur_mod = ((ctx)->current_codegen_module);
        if ((((((int32_t)(((callee).kind))) ==44) && (((callee).field_access_base_ref) > 0)) && (((callee).field_access_base_ref) <=((arena)->num_exprs)))) {
          struct ast_Expr base = ast_ast_arena_expr_get(arena, ((callee).field_access_base_ref));
          if ((((((int32_t)(((base).kind))) ==3) && (((base).var_name_len) > 0)) && (((base).var_name_len) <=63))) {
            int32_t j = 0;
            int32_t nd_bind = pipeline_dep_ctx_ndep(ctx);
            int32_t n_imp = codegen_module_num_imports(cur_mod);
            while (((j < n_imp) && (j < nd_bind))) {
              if ((pipeline_module_import_kind_at(cur_mod, j) ==1)) {
                int32_t bind_len = pipeline_module_import_binding_name_len(cur_mod, j);
                if ((bind_len !=((base).var_name_len))) {
                  (void)((j = (j + 1)));
                  continue;
                }
                int eq = 1;
                int32_t kk = 0;
                while (((kk < ((base).var_name_len)) && (kk < 64))) {
                  if (((((base).var_name))[kk] !=pipeline_module_import_binding_name_byte_at(cur_mod, j, kk))) {
                    (void)((eq = 0));
                    break;
                  }
                  (void)((kk = (kk + 1)));
                }
                if (eq) {
                  uint8_t dep_path_bind[128] = {};
                  int32_t dep_path_bind_len = codegen_module_import_path_len_at(cur_mod, j, &((dep_path_bind)[0]));
                  if ((dep_path_bind_len <=0)) {
                    (void)((j = (j + 1)));
                    continue;
                  }
                  int32_t dep_ix_bind = codegen_find_dep_index_by_path(ctx, &((dep_path_bind)[0]), dep_path_bind_len);
                  struct ast_Module * dep_mod_bind = cur_mod;
                  if (((dep_ix_bind >=0) && (dep_ix_bind < pipeline_dep_ctx_ndep(ctx)))) {
                    (void)((dep_mod_bind = pipeline_dep_ctx_module_at(ctx, dep_ix_bind)));
                  }
                  uint8_t pre_buf[128] = {};
                  (void)(codegen_import_path_to_c_prefix_into(&((dep_path_bind)[0]), &((pre_buf)[0]), 128));
                  int32_t pre_len = 0;
                  while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                    (void)((pre_len = (pre_len + 1)));
                  }
                  int32_t drv_buf_bind = 0;
                  if ((codegen_path_is_std_io_driver_bytes(&((dep_path_bind)[0])) !=0)) {
                    (void)((drv_buf_bind = codegen_emit_io_driver_buf_call_name(out, &((((callee).field_access_field_name))[0]), ((callee).field_access_field_len), ((e).call_num_args))));
                    if ((drv_buf_bind < 0)) {
                      return -1;
                    }
                  }
                  if ((drv_buf_bind ==0)) {
                    int32_t bind_pre = pre_len;
                    if (((dep_mod_bind !=0) && (((callee).field_access_field_len) > 0))) {
                      int32_t fi_b = 0;
                      while ((fi_b < ((dep_mod_bind)->num_funcs))) {
                        int32_t fl = pipeline_module_func_name_len_at(dep_mod_bind, fi_b);
                        if (((fl ==((callee).field_access_field_len)) && (fl > 0))) {
                          uint8_t fnb[128] = {};
                          (void)(pipeline_module_func_name_copy64(dep_mod_bind, fi_b, &((fnb)[0])));
                          int32_t eqb = 1;
                          int32_t bi_b = 0;
                          while ((bi_b < fl)) {
                            if (((fnb)[bi_b] !=(((callee).field_access_field_name))[bi_b])) {
                              (void)((eqb = 0));
                              (void)((bi_b = fl));
                            } else {
                              (void)((bi_b = (bi_b + 1)));
                            }
                          }
                          if ((eqb !=0)) {
                            (void)((bind_pre = codegen_func_c_symbol_prefix_len(dep_mod_bind, fi_b, pre_len)));
                            (void)((fi_b = ((dep_mod_bind)->num_funcs)));
                          } else {
                            (void)((fi_b = (fi_b + 1)));
                          }
                        } else {
                          (void)((fi_b = (fi_b + 1)));
                        }
                      }
                    }
                    if ((((bind_pre > 0) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), bind_pre, &((((callee).field_access_field_name))[0]), ((callee).field_access_field_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), bind_pre) !=0))) {
                      return -1;
                    }
                    if (((((callee).field_access_field_len) > 0) && (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_bind, &((((callee).field_access_field_name))[0]), ((callee).field_access_field_len)) !=0))) {
                      return -1;
                    }
                  }
                  if ((codegen_append_byte(out, 40) !=0)) {
                    return -1;
                  }
                  int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &((((callee).field_access_field_name))[0]), ((callee).field_access_field_len), ((e).call_num_args));
                  int32_t ai = 0;
                  while ((ai < n_dep)) {
                    if ((ai > 0)) {
                      uint8_t comma[3] = {44, 32, 0};
                      if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
                        return -1;
                      }
                    }
                    if (((drv_buf_bind !=0) && (ai ==0))) {
                      uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                      if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                        return -1;
                      }
                    }
                    if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                      if ((codegen_append_byte(out, 48) !=0)) {
                        return -1;
                      }
                    } else {
                      if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) !=0)) {
                        return -1;
                      }
                    }
                    (void)((ai = (ai + 1)));
                  }
                  if ((codegen_append_byte(out, 41) !=0)) {
                    return -1;
                  }
                  return 0;
                }
              }
              (void)((j = (j + 1)));
            }
          }
        }
        if (((((int32_t)(((callee).kind))) ==3) && (((callee).var_name_len) > 0))) {
          int32_t j = 0;
          int32_t nd_sel = pipeline_dep_ctx_ndep(ctx);
          int32_t n_imp = codegen_module_num_imports(cur_mod);
          while (((j < n_imp) && (j < nd_sel))) {
            if ((pipeline_module_import_kind_at(cur_mod, j) ==2)) {
              int32_t k = 0;
              int32_t sel_cnt = pipeline_module_import_select_count_at(cur_mod, j);
              while ((k < sel_cnt)) {
                int32_t sel_len = pipeline_module_import_select_name_len(cur_mod, j, k);
                if ((sel_len ==((callee).var_name_len))) {
                  int eq = 1;
                  int32_t kk = 0;
                  while (((kk < ((callee).var_name_len)) && (kk < 64))) {
                    if (((((callee).var_name))[kk] !=pipeline_module_import_select_name_byte_at(cur_mod, j, k, kk))) {
                      (void)((eq = 0));
                      break;
                    }
                    (void)((kk = (kk + 1)));
                  }
                  if (eq) {
                    uint8_t dep_path_sel[128] = {};
                    int32_t dep_path_sel_len = codegen_module_import_path_len_at(cur_mod, j, &((dep_path_sel)[0]));
                    if ((dep_path_sel_len <=0)) {
                      (void)((k = (k + 1)));
                      continue;
                    }
                    uint8_t pre_buf[128] = {};
                    (void)(codegen_import_path_to_c_prefix_into(&((dep_path_sel)[0]), &((pre_buf)[0]), 128));
                    int32_t pre_len = 0;
                    while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                      (void)((pre_len = (pre_len + 1)));
                    }
                    if ((((pre_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), pre_len, ((callee).var_name), ((callee).var_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), pre_len) !=0))) {
                      return -1;
                    }
                    if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &((((callee).var_name))[0]), ((callee).var_name_len)) !=0)) {
                      return -1;
                    }
                    if ((codegen_append_byte(out, 40) !=0)) {
                      return -1;
                    }
                    int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &((((callee).var_name))[0]), ((callee).var_name_len), ((e).call_num_args));
                    int32_t ai = 0;
                    while ((ai < n_dep)) {
                      if ((ai > 0)) {
                        uint8_t comma[3] = {44, 32, 0};
                        if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
                          return -1;
                        }
                      }
                      if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                        if ((codegen_append_byte(out, 48) !=0)) {
                          return -1;
                        }
                      } else {
                        if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) !=0)) {
                          return -1;
                        }
                      }
                      (void)((ai = (ai + 1)));
                    }
                    if ((codegen_append_byte(out, 41) !=0)) {
                      return -1;
                    }
                    return 0;
                  }
                }
                (void)((k = (k + 1)));
              }
            }
            (void)((j = (j + 1)));
          }
          (void)((j = 0));
          int32_t nd_call = pipeline_dep_ctx_ndep(ctx);
          int32_t local_has_name = 0;
          if (((cur_mod !=0) && (((callee).var_name_len) > 0))) {
            int32_t lfi = 0;
            while ((lfi < ((cur_mod)->num_funcs))) {
              int32_t lnl = pipeline_module_func_name_len_at(cur_mod, lfi);
              if ((lnl ==((callee).var_name_len))) {
                uint8_t lnm[128] = {};
                (void)(pipeline_module_func_name_copy64(cur_mod, lfi, &((lnm)[0])));
                int32_t leq = 1;
                int32_t li = 0;
                while (((li < lnl) && (li < 64))) {
                  if (((lnm)[li] !=(((callee).var_name))[li])) {
                    (void)((leq = 0));
                    break;
                  }
                  (void)((li = (li + 1)));
                }
                if ((leq !=0)) {
                  (void)((local_has_name = 1));
                  break;
                }
              }
              (void)((lfi = (lfi + 1)));
            }
          }
          while (((j < nd_call) && (local_has_name ==0))) {
            struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, j);
            struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, j);
            if ((((dep_mod !=0) && (dep_arena !=0)) && (((dep_mod)->num_funcs) > 0))) {
              int32_t fi = 0;
              while ((fi < ((dep_mod)->num_funcs))) {
                int32_t func_ref = pipeline_module_func_ref_at(dep_mod, fi);
                if (((ast_ref_is_null(func_ref) || (func_ref <=0)) || (func_ref > ((dep_arena)->num_funcs)))) {
                  (void)((fi = (fi + 1)));
                  continue;
                }
                struct ast_Func df = ast_ast_arena_func_get(dep_arena, func_ref);
                if ((((df).name_len) ==((callee).var_name_len))) {
                  int eq = 1;
                  int32_t k = 0;
                  while (((k < ((callee).var_name_len)) && (k < 64))) {
                    if (((((callee).var_name))[k] !=(((df).name))[k])) {
                      (void)((eq = 0));
                      break;
                    }
                    (void)((k = (k + 1)));
                  }
                  if ((eq && (pipeline_dep_ctx_import_path_len(ctx, j) > 0))) {
                    int32_t callee_is_extern = pipeline_module_func_is_extern_at(dep_mod, fi);
                    uint8_t dep_path_call[128] = {};
                    (void)(pipeline_dep_ctx_import_path_copy64(ctx, j, &((dep_path_call)[0])));
                    uint8_t pre_buf[128] = {};
                    (void)(codegen_import_path_to_c_prefix_into(&((dep_path_call)[0]), &((pre_buf)[0]), 128));
                    int32_t pre_len = 0;
                    while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                      (void)((pre_len = (pre_len + 1)));
                    }
                    if (((callee_is_extern !=0) || (pipeline_module_func_is_no_mangle_at(dep_mod, fi) !=0))) {
                      (void)((pre_len = 0));
                    }
                    int32_t drv_buf_call = 0;
                    if ((codegen_path_is_std_io_driver_bytes(&((dep_path_call)[0])) !=0)) {
                      (void)((drv_buf_call = codegen_emit_io_driver_buf_call_name(out, &((((callee).var_name))[0]), ((callee).var_name_len), ((e).call_num_args))));
                      if ((drv_buf_call < 0)) {
                        return -1;
                      }
                    }
                    if ((drv_buf_call ==0)) {
                      if ((((pre_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), pre_len, ((callee).var_name), ((callee).var_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), pre_len) !=0))) {
                        return -1;
                      }
                      if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &((((callee).var_name))[0]), ((callee).var_name_len)) !=0)) {
                        return -1;
                      }
                      if (((codegen_path_is_std_io_core_bytes(&((dep_path_call)[0])) !=0) && (codegen_use_buf_wrapper(&((((callee).var_name))[0]), ((callee).var_name_len), ((e).call_num_args)) !=0))) {
                        uint8_t suf_buf[8] = {95, 98, 117, 102, 0, 0, 0, 0};
                        if ((codegen_emit_bytes_from_ptr(out, &((suf_buf)[0]), 4) !=0)) {
                          return -1;
                        }
                      }
                    }
                    if ((codegen_append_byte(out, 40) !=0)) {
                      return -1;
                    }
                    int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, ((callee).var_name), ((callee).var_name_len), ((e).call_num_args));
                    int32_t fmt_i32_second_dep = 0;
                    if (((((((((((((e).call_num_args) ==2) && (n_dep ==1)) && (((callee).var_name_len) ==7)) && ((((callee).var_name))[0] ==102)) && ((((callee).var_name))[1] ==109)) && ((((callee).var_name))[2] ==116)) && ((((callee).var_name))[3] ==95)) && ((((callee).var_name))[4] ==105)) && ((((callee).var_name))[5] ==51)) && ((((callee).var_name))[6] ==50))) {
                      if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                        (void)((fmt_i32_second_dep = 1));
                      }
                    }
                    int32_t cast_buf0 = drv_buf_call;
                    int32_t ai = 0;
                    while ((ai < n_dep)) {
                      if ((ai > 0)) {
                        uint8_t comma[3] = {44, 32, 0};
                        if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
                          return -1;
                        }
                      }
                      int32_t arg_idx_dep = ai;
                      if (((fmt_i32_second_dep !=0) && (ai ==0))) {
                        (void)((arg_idx_dep = 1));
                      }
                      if (((cast_buf0 !=0) && (ai ==0))) {
                        uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                        if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                          return -1;
                        }
                      }
                      if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep))) {
                        if ((codegen_append_byte(out, 48) !=0)) {
                          return -1;
                        }
                      } else {
                        if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep), ctx) !=0)) {
                          return -1;
                        }
                      }
                      (void)((ai = (ai + 1)));
                    }
                    if (((codegen_is_submit_batch_buf_call(((callee).var_name), ((callee).var_name_len)) !=0) && (((e).call_num_args) ==3))) {
                      uint8_t comma0[4] = {44, 32, 48, 0};
                      if ((codegen_emit_bytes_4(out, &((comma0)[0]), 3) !=0)) {
                        return -1;
                      }
                    }
                    if ((codegen_append_byte(out, 41) !=0)) {
                      return -1;
                    }
                    return 0;
                  }
                }
                (void)((fi = (fi + 1)));
              }
            }
            (void)((j = (j + 1)));
          }
        }
      }
      if ((((((ctx !=0) && (((ctx)->ndep) > 0)) && !(ast_ref_is_null(callee_ref))) && (callee_ref > 0)) && (callee_ref <=((arena)->num_exprs)))) {
        struct ast_Expr callee_fb = ast_ast_arena_expr_get(arena, callee_ref);
        if ((((((((((((((int32_t)(((callee_fb).kind))) ==3) && (((callee_fb).var_name_len) ==9)) && ((((callee_fb).var_name))[0] ==112)) && ((((callee_fb).var_name))[1] ==114)) && ((((callee_fb).var_name))[2] ==105)) && ((((callee_fb).var_name))[3] ==110)) && ((((callee_fb).var_name))[4] ==116)) && ((((callee_fb).var_name))[5] ==95)) && ((((callee_fb).var_name))[6] ==115)) && ((((callee_fb).var_name))[7] ==116)) && ((((callee_fb).var_name))[8] ==114))) {
          uint8_t std_io[8] = {115, 116, 100, 95, 105, 111, 95, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((std_io)[0]), 7) !=0)) {
            return -1;
          }
          if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, ((ctx)->current_codegen_module), &((((callee_fb).var_name))[0]), ((callee_fb).var_name_len)) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          int32_t ai = 0;
          while ((ai < ((e).call_num_args))) {
            if ((ai > 0)) {
              uint8_t comma[3] = {44, 32, 0};
              if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
                return -1;
              }
            }
            if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
              if ((codegen_append_byte(out, 48) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) !=0)) {
                return -1;
              }
            }
            (void)((ai = (ai + 1)));
          }
          if ((codegen_append_byte(out, 41) !=0)) {
            return -1;
          }
          return 0;
        }
      }
      if (((((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_codegen_arena) !=0)) && !(ast_ref_is_null(callee_ref))) && (callee_ref > 0)) && (callee_ref <=((arena)->num_exprs)))) {
        struct ast_Expr callee2 = ast_ast_arena_expr_get(arena, callee_ref);
        if (((((int32_t)(((callee2).kind))) ==3) && (((callee2).var_name_len) > 0))) {
          struct ast_Module * cur_mod = ((ctx)->current_codegen_module);
          struct ast_ASTArena * cur_arena = ((ctx)->current_codegen_arena);
          int32_t fi = 0;
          while ((fi < ((cur_mod)->num_funcs))) {
            int32_t func_ref = pipeline_module_func_ref_at(cur_mod, fi);
            if (((!(ast_ref_is_null(func_ref)) && (func_ref > 0)) && (func_ref <=((cur_arena)->num_funcs)))) {
              struct ast_Func df = ast_ast_arena_func_get(cur_arena, func_ref);
              if ((((df).name_len) ==((callee2).var_name_len))) {
                int eq = 1;
                int32_t k = 0;
                while (((k < ((callee2).var_name_len)) && (k < 64))) {
                  if (((((callee2).var_name))[k] !=(((df).name))[k])) {
                    (void)((eq = 0));
                    break;
                  }
                  (void)((k = (k + 1)));
                }
                if (eq) {
                  uint8_t cur_pre[128] = {};
                  uint8_t cur_dep_path_buf[128] = {};
                  int32_t cur_dep_plen = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &((cur_dep_path_buf)[0]));
                  int32_t pl = 0;
                  if ((cur_dep_plen > 0)) {
                    (void)(codegen_import_path_to_c_prefix_into(&((cur_dep_path_buf)[0]), &((cur_pre)[0]), 128));
                    while (((pl < 128) && ((cur_pre)[pl] !=0))) {
                      (void)((pl = (pl + 1)));
                    }
                  } else {
                    if ((((ctx)->current_codegen_prefix_len) > 0)) {
                      int32_t _cpl = ((ctx)->current_codegen_prefix_len);
                      int32_t pi = 0;
                      while (((pi < _cpl) && (pi < 127))) {
                        (void)(((cur_pre)[pi] = (((ctx)->current_codegen_prefix_mirror))[pi]));
                        (void)((pi = (pi + 1)));
                      }
                      (void)(((cur_pre)[pi] = ((uint8_t)(0))));
                      (void)((pl = pi));
                    } else {
                      (void)(((cur_pre)[0] = ((uint8_t)(0))));
                      (void)((pl = 0));
                    }
                  }
                  if (((pipeline_module_func_is_extern_at(cur_mod, fi) !=0) || (pipeline_module_func_is_no_mangle_at(cur_mod, fi) !=0))) {
                    (void)((pl = 0));
                  }
                  if ((((pl > 0) && (codegen_c_prefix_redundant_with_name(&((cur_pre)[0]), pl, ((callee2).var_name), ((callee2).var_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((cur_pre)[0]), pl) !=0))) {
                    return -1;
                  }
                  if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &((((callee2).var_name))[0]), ((callee2).var_name_len)) !=0)) {
                    return -1;
                  }
                  if ((codegen_append_byte(out, 40) !=0)) {
                    return -1;
                  }
                  int32_t n_cur = codegen_call_num_args_override(&((cur_pre)[0]), pl, ((callee2).var_name), ((callee2).var_name_len), ((e).call_num_args));
                  int32_t fmt_i32_second_cur = 0;
                  if (((((((((((((e).call_num_args) ==2) && (n_cur ==1)) && (((callee2).var_name_len) ==7)) && ((((callee2).var_name))[0] ==102)) && ((((callee2).var_name))[1] ==109)) && ((((callee2).var_name))[2] ==116)) && ((((callee2).var_name))[3] ==95)) && ((((callee2).var_name))[4] ==105)) && ((((callee2).var_name))[5] ==51)) && ((((callee2).var_name))[6] ==50))) {
                    if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                      (void)((fmt_i32_second_cur = 1));
                    }
                  }
                  int32_t ai = 0;
                  while ((ai < n_cur)) {
                    if ((ai > 0)) {
                      uint8_t comma[3] = {44, 32, 0};
                      if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
                        return -1;
                      }
                    }
                    int32_t arg_idx_cur = ai;
                    if (((fmt_i32_second_cur !=0) && (ai ==0))) {
                      (void)((arg_idx_cur = 1));
                    }
                    if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur))) {
                      if ((codegen_append_byte(out, 48) !=0)) {
                        return -1;
                      }
                    } else {
                      int32_t pty_cur = 0;
                      if ((arg_idx_cur < pipeline_module_func_num_params_at(cur_mod, fi))) {
                        (void)((pty_cur = pipeline_module_func_param_type_ref_at(cur_mod, fi, arg_idx_cur)));
                      }
                      (void)(codegen_set_host_call_arg_param_ty(pty_cur));
                      if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur), ctx) !=0)) {
                        (void)(codegen_set_host_call_arg_param_ty(0));
                        return -1;
                      }
                      (void)(codegen_set_host_call_arg_param_ty(0));
                    }
                    (void)((ai = (ai + 1)));
                  }
                  if (((codegen_is_submit_batch_buf_call(((callee2).var_name), ((callee2).var_name_len)) !=0) && (((e).call_num_args) ==3))) {
                    uint8_t comma0[4] = {44, 32, 48, 0};
                    if ((codegen_emit_bytes_4(out, &((comma0)[0]), 3) !=0)) {
                      return -1;
                    }
                  }
                  if ((codegen_append_byte(out, 41) !=0)) {
                    return -1;
                  }
                  return 0;
                }
              }
            }
            (void)((fi = (fi + 1)));
          }
        }
      }
      if ((((!(ast_ref_is_null(((e).call_callee_ref))) && (((e).call_num_args) ==2)) && (((e).call_callee_ref) > 0)) && (((e).call_callee_ref) <=((arena)->num_exprs)))) {
        struct ast_Expr callee_fb = ast_ast_arena_expr_get(arena, ((e).call_callee_ref));
        if (((((int32_t)(((callee_fb).kind))) ==3) && (((callee_fb).var_name_len) >=10))) {
          int prefix_ok = (((((((callee_fb).var_name))[0] ==109) && ((((callee_fb).var_name))[1] ==97)) && ((((callee_fb).var_name))[2] ==112)) && ((((callee_fb).var_name))[3] ==95));
          int32_t off = (((callee_fb).var_name_len) - 6);
          int suffix_ok = (((((((off >=0) && ((((callee_fb).var_name))[off] ==102)) && ((((callee_fb).var_name))[(off + 1)] ==105)) && ((((callee_fb).var_name))[(off + 2)] ==110)) && ((((callee_fb).var_name))[(off + 3)] ==100)) && ((((callee_fb).var_name))[(off + 4)] ==95)) && ((((callee_fb).var_name))[(off + 5)] ==99));
          if ((prefix_ok && suffix_ok)) {
            if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, ((ctx)->current_codegen_module), &((((callee_fb).var_name))[0]), ((callee_fb).var_name_len)) !=0)) {
              return -1;
            }
            uint8_t open[3] = {40, 40, 0};
            if ((codegen_emit_bytes_3(out, &((open)[0]), 2) !=0)) {
              return -1;
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) !=0)) {
              return -1;
            }
            uint8_t mid1[10] = {41, 46, 107, 101, 121, 115, 44, 32, 40, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((mid1)[0]), 9) !=0)) {
              return -1;
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) !=0)) {
              return -1;
            }
            uint8_t mid2[14] = {41, 46, 111, 99, 99, 117, 112, 105, 101, 100, 44, 32, 40, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((mid2)[0]), 13) !=0)) {
              return -1;
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) !=0)) {
              return -1;
            }
            uint8_t mid3[8] = {41, 46, 99, 97, 112, 44, 32, 0};
            if ((codegen_emit_bytes_8(out, &((mid3)[0]), 7) !=0)) {
              return -1;
            }
            if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 1), ctx) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 41) !=0)) {
              return -1;
            }
            return 0;
          }
        }
      }
      int32_t need_4th = 0;
      if ((((!(ast_ref_is_null(((e).call_callee_ref))) && (((e).call_callee_ref) > 0)) && (((e).call_callee_ref) <=((arena)->num_exprs))) && (((e).call_num_args) ==3))) {
        struct ast_Expr callee_f4 = ast_ast_arena_expr_get(arena, ((e).call_callee_ref));
        if (((((int32_t)(((callee_f4).kind))) ==3) && (codegen_is_submit_batch_buf_call(((callee_f4).var_name), ((callee_f4).var_name_len)) !=0))) {
          (void)((need_4th = 1));
        }
      }
      int32_t saved_callee_flag = 0;
      if ((ctx !=0)) {
        (void)((saved_callee_flag = ((ctx)->emit_expr_as_callee)));
        (void)((((ctx)->emit_expr_as_callee) = 1));
      }
      if ((!(ast_ref_is_null(((e).call_callee_ref))) && (codegen_emit_expr(arena, out, ((e).call_callee_ref), ctx) !=0))) {
        if ((ctx !=0)) {
          (void)((((ctx)->emit_expr_as_callee) = saved_callee_flag));
        }
        return -1;
      }
      if ((ctx !=0)) {
        (void)((((ctx)->emit_expr_as_callee) = saved_callee_flag));
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      uint8_t fallback_pre[128] = {};
      int32_t fallback_pl = 0;
      if ((ctx !=0)) {
        uint8_t fb_dep_path_buf[128] = {};
        int32_t fb_dep_plen = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &((fb_dep_path_buf)[0]));
        if ((fb_dep_plen > 0)) {
          (void)(codegen_import_path_to_c_prefix_into(&((fb_dep_path_buf)[0]), &((fallback_pre)[0]), 64));
        } else {
          (void)(((fallback_pre)[0] = ((uint8_t)(0))));
        }
        while (((fallback_pl < 64) && ((fallback_pre)[fallback_pl] !=0))) {
          (void)((fallback_pl = (fallback_pl + 1)));
        }
      }
      int32_t n_fb = ((e).call_num_args);
      int32_t use_second_arg = 0;
      if (((!(ast_ref_is_null(((e).call_callee_ref))) && (((e).call_callee_ref) > 0)) && (((e).call_callee_ref) <=((arena)->num_exprs)))) {
        struct ast_Expr callee_expr = ast_ast_arena_expr_get(arena, ((e).call_callee_ref));
        if ((((int32_t)(((callee_expr).kind))) ==3)) {
          (void)((n_fb = codegen_call_num_args_override(&((fallback_pre)[0]), fallback_pl, ((callee_expr).var_name), ((callee_expr).var_name_len), ((e).call_num_args))));
          if ((((((e).call_num_args) ==2) && (n_fb ==1)) && ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0)))) {
            (void)((use_second_arg = 1));
          }
        }
      }
      int32_t ai = 0;
      while ((ai < n_fb)) {
        if ((ai > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
        }
        int32_t arg_idx = ai;
        if (((use_second_arg !=0) && (ai ==0))) {
          (void)((arg_idx = 1));
        }
        if (ast_ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx))) {
          if ((codegen_append_byte(out, 48) !=0)) {
            return -1;
          }
        } else {
          int32_t pty_fb = 0;
          int32_t rfi_fb = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
          if ((((rfi_fb >=0) && (ctx !=0)) && (((ctx)->current_codegen_module) !=0))) {
            if ((arg_idx < pipeline_module_func_num_params_at(((ctx)->current_codegen_module), rfi_fb))) {
              (void)((pty_fb = pipeline_module_func_param_type_ref_at(((ctx)->current_codegen_module), rfi_fb, arg_idx)));
            }
          }
          (void)(codegen_set_host_call_arg_param_ty(pty_fb));
          if ((codegen_emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx), ctx) !=0)) {
            (void)(codegen_set_host_call_arg_param_ty(0));
            return -1;
          }
          (void)(codegen_set_host_call_arg_param_ty(0));
        }
        (void)((ai = (ai + 1)));
      }
      if ((need_4th !=0)) {
        uint8_t comma0[4] = {44, 32, 48, 0};
        if ((codegen_emit_bytes_4(out, &((comma0)[0]), 3) !=0)) {
          return -1;
        }
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      return 0;
    }
    if ((((int32_t)(((e).kind))) ==1)) {
      return pipeline_codegen_emit_float_lit_c(out, ((e).float_val), ((e).float_bits_lo), ((e).float_bits_hi));
    }
    if ((((int32_t)(((e).kind))) ==6)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 42, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==7)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 47, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==8)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 37, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==14)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 61, 61, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==15)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 33, 61, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==16)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 60, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==17)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 60, 61, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==18)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 62, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==19)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 62, 61, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==20)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[5] = {32, 38, 38, 32, 0};
      if ((codegen_emit_bytes_5(out, &((op)[0]), 4) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==21)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[5] = {32, 124, 124, 32, 0};
      if ((codegen_emit_bytes_5(out, &((op)[0]), 4) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==9)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 60, 60, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==10)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 62, 62, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==11)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 38, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==12)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 124, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==13)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_left_ref), ctx) !=0)) {
        return -1;
      }
      uint8_t op[4] = {32, 94, 32, 0};
      if ((codegen_emit_bytes_4(out, &((op)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).binop_right_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==23)) {
      uint8_t pre[3] = {126, 40, 0};
      if ((codegen_emit_bytes_3(out, &((pre)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==24)) {
      uint8_t pre[3] = {33, 40, 0};
      if ((codegen_emit_bytes_3(out, &((pre)[0]), 2) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==27)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).if_cond_ref))) && (codegen_emit_expr(arena, out, ((e).if_cond_ref), ctx) !=0))) {
        return -1;
      }
      uint8_t q[4] = {32, 63, 32, 0};
      if ((codegen_emit_bytes_4(out, &((q)[0]), 3) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).if_then_ref))) && (codegen_emit_expr(arena, out, ((e).if_then_ref), ctx) !=0))) {
        return -1;
      }
      uint8_t colon[4] = {32, 58, 32, 0};
      if ((codegen_emit_bytes_4(out, &((colon)[0]), 3) !=0)) {
        return -1;
      }
      if (!(ast_ref_is_null(((e).if_else_ref)))) {
        if ((codegen_emit_expr(arena, out, ((e).if_else_ref), ctx) !=0)) {
          return -1;
        }
      } else {
        if ((codegen_append_byte(out, 48) !=0)) {
          return -1;
        }
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==47)) {
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).index_base_ref))) && (codegen_emit_expr(arena, out, ((e).index_base_ref), ctx) !=0))) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      int32_t need_slice_data = ((e).index_base_is_slice);
      if (((need_slice_data ==0) && !(ast_ref_is_null(((e).index_base_ref))))) {
        int32_t base_ty = pipeline_expr_resolved_type_ref(arena, ((e).index_base_ref));
        if (((!(ast_ref_is_null(base_ty)) && (base_ty > 0)) && (base_ty <=((arena)->num_types)))) {
          if ((pipeline_type_kind_ord_at(arena, base_ty) ==11)) {
            (void)((need_slice_data = 1));
          }
        }
      }
      if ((need_slice_data !=0)) {
        int32_t use_arrow = 0;
        if (!(ast_ref_is_null(((e).index_base_ref)))) {
          if ((codegen_field_access_base_is_pointer_ref(arena, ((e).index_base_ref)) !=0)) {
            (void)((use_arrow = 1));
          }
          if (((((use_arrow ==0) && (ctx !=0)) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_func_index) >=0))) {
            if ((codegen_field_access_base_is_pointer_param(arena, ((e).index_base_ref), ((ctx)->current_codegen_module), ((ctx)->current_func_index)) !=0)) {
              (void)((use_arrow = 1));
            }
          }
        }
        if ((use_arrow !=0)) {
          uint8_t arrow_data[8] = {45, 62, 100, 97, 116, 97, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((arrow_data)[0]), 6) !=0)) {
            return -1;
          }
        } else {
          uint8_t dot[6] = {46, 100, 97, 116, 97, 0};
          if ((codegen_emit_bytes_6(out, &((dot)[0]), 5) !=0)) {
            return -1;
          }
        }
      }
      if ((codegen_append_byte(out, 91) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).index_index_ref))) && (codegen_emit_expr(arena, out, ((e).index_index_ref), ctx) !=0))) {
        return -1;
      }
      return codegen_append_byte(out, 93);
    }
    if ((((int32_t)(((e).kind))) ==44)) {
      if (((ctx !=0) && (((ctx)->current_codegen_module) !=0))) {
        (void)(pipeline_codegen_try_mark_enum_field_access(((ctx)->current_codegen_module), arena, expr_ref, ctx));
        (void)((e = ast_ast_arena_expr_get(arena, expr_ref)));
      }
      if ((((e).field_access_is_enum_variant) !=0)) {
        return codegen_format_int(out, ((e).enum_variant_tag));
      }
      if (((((((((((((e).field_access_field_len) ==6) && ((((e).field_access_field_name))[0] ==108)) && ((((e).field_access_field_name))[1] ==101)) && ((((e).field_access_field_name))[2] ==110)) && ((((e).field_access_field_name))[3] ==103)) && ((((e).field_access_field_name))[4] ==116)) && ((((e).field_access_field_name))[5] ==104)) && !(ast_ref_is_null(((e).field_access_base_ref)))) && (((e).field_access_base_ref) > 0)) && (((e).field_access_base_ref) <=((arena)->num_exprs)))) {
        struct ast_Expr base_e = ast_ast_arena_expr_get(arena, ((e).field_access_base_ref));
        int32_t base_ty = ((base_e).resolved_type_ref);
        if (((!(ast_ref_is_null(base_ty)) && (base_ty > 0)) && (base_ty <=((arena)->num_types)))) {
          int32_t bk = pipeline_type_kind_ord_at(arena, base_ty);
          if (((bk ==10) || (bk ==13))) {
            int32_t asz = pipeline_type_array_size_at(arena, base_ty);
            if ((asz > 0)) {
              uint8_t open_cast[16] = {40, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((open_cast)[0]), 9) !=0)) {
                return -1;
              }
              if ((codegen_format_int(out, asz) !=0)) {
                return -1;
              }
              return codegen_append_byte(out, 41);
            }
          }
        }
      }
      if ((((ctx !=0) && (((ctx)->emit_expr_as_callee) !=0)) && (codegen_emit_import_module_field_symbol(arena, out, expr_ref, ctx) ==0))) {
        return 0;
      }
      if ((codegen_emit_import_module_const_field(arena, out, expr_ref, ctx) ==0)) {
        return 0;
      }
      if (((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_codegen_arena) ==arena)) && (((ctx)->current_func_index) >=0))) {
        struct ast_Module * mod = ((ctx)->current_codegen_module);
        if ((((ctx)->current_func_index) < ((mod)->num_funcs))) {
          int32_t cfi = ((ctx)->current_func_index);
          uint8_t pref[128] = {};
          int32_t plen = codegen_emit_prefix_len_from_ctx(ctx, &((pref)[0]), 128);
          uint8_t cfn[128] = {};
          (void)(pipeline_module_func_name_copy64(mod, cfi, &((cfn)[0])));
          int32_t cfn_len = pipeline_module_func_name_len_at(mod, cfi);
          if ((codegen_force_param_ptrdiff_t(&((pref)[0]), plen, &((cfn)[0]), cfn_len, 0) !=0)) {
            if ((codegen_expr_var_matches_func_param_index(arena, ((e).field_access_base_ref), mod, cfi, 0, ctx) !=0)) {
              return codegen_emit_expr(arena, out, ((e).field_access_base_ref), ctx);
            }
          }
        }
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).field_access_base_ref))) && (codegen_emit_expr(arena, out, ((e).field_access_base_ref), ctx) !=0))) {
        return -1;
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      int32_t is_ptr_base = codegen_field_access_base_is_pointer_ref(arena, ((e).field_access_base_ref));
      int32_t param_type_known = 0;
      if ((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_func_index) >=0))) {
        if ((is_ptr_base ==0)) {
          (void)((is_ptr_base = codegen_field_access_base_is_pointer_param(arena, ((e).field_access_base_ref), ((ctx)->current_codegen_module), ((ctx)->current_func_index))));
        }
        if ((is_ptr_base ==0)) {
          (void)((is_ptr_base = codegen_field_access_base_is_pointer_local(arena, ((e).field_access_base_ref), ctx)));
        }
        (void)((param_type_known = codegen_field_access_base_param_type_known(arena, ((e).field_access_base_ref), ((ctx)->current_codegen_module), ((ctx)->current_func_index))));
      }
      if ((((is_ptr_base ==0) && (param_type_known ==0)) && (codegen_field_access_base_type_resolved(arena, ((e).field_access_base_ref)) ==0))) {
        if ((codegen_field_access_base_is_slice_param_name(arena, ((e).field_access_base_ref)) !=0)) {
          (void)((is_ptr_base = 1));
        }
      }
      if ((is_ptr_base !=0)) {
        uint8_t arrow[3] = {45, 62, 0};
        if ((codegen_emit_bytes_3(out, &((arrow)[0]), 2) !=0)) {
          return -1;
        }
      } else {
        uint8_t dot[2] = {46, 0};
        if ((codegen_emit_bytes_2(out, &((dot)[0]), 1) !=0)) {
          return -1;
        }
      }
      if ((codegen_emit_bytes_64(out, &((((e).field_access_field_name))[0]), ((e).field_access_field_len)) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==42)) {
      uint8_t p[23] = {120, 108, 97, 110, 103, 95, 112, 97, 110, 105, 99, 95, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
      uint8_t cast_open[12] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 0};
      if ((codegen_emit_bytes_22(out, &((p)[0]), 13) !=0)) {
        return -1;
      }
      if (ast_ref_is_null(((e).unary_operand_ref))) {
        if ((codegen_append_byte(out, 48) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 44) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 48) !=0)) {
          return -1;
        }
      } else {
        int32_t is_cstr = 0;
        int32_t op_ref = ((e).unary_operand_ref);
        if ((pipeline_expr_kind_ord_at(arena, op_ref) ==59)) {
          (void)((is_cstr = 1));
        } else {
          if (((op_ref > 0) && (op_ref <=((arena)->num_exprs)))) {
            struct ast_Expr op_e = ast_ast_arena_expr_get(arena, op_ref);
            if (((!(ast_ref_is_null(((op_e).resolved_type_ref))) && (((op_e).resolved_type_ref) > 0)) && (((op_e).resolved_type_ref) <=((arena)->num_types)))) {
              struct ast_Type oty = ast_ast_arena_type_get(arena, ((op_e).resolved_type_ref));
              if ((((int32_t)(((oty).kind))) ==9)) {
                (void)((is_cstr = 1));
              }
            }
          }
        }
        if ((is_cstr !=0)) {
          if ((codegen_append_byte(out, 50) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_append_byte(out, 49) !=0)) {
            return -1;
          }
        }
        if ((codegen_append_byte(out, 44) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((cast_open)[0]), 11) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, ((e).unary_operand_ref), ctx) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==39)) {
      return codegen_append_byte(out, 48);
    }
    if ((((int32_t)(((e).kind))) ==40)) {
      return codegen_append_byte(out, 48);
    }
    if ((((int32_t)(((e).kind))) ==49)) {
      if ((ctx !=0)) {
        int32_t fmt_mc_rc = codegen_try_emit_fmt_string_lit_call(arena, out, expr_ref, ctx);
        if ((fmt_mc_rc < 0)) {
          return -1;
        }
        if ((fmt_mc_rc > 0)) {
          return 0;
        }
      }
      if ((((((ctx !=0) && (((ctx)->mono_active) !=0)) && (((e).method_call_base_ref) > 0)) && (((e).method_call_base_ref) <=((arena)->num_exprs))) && (((e).method_call_name_len) > 0))) {
        struct ast_Expr base_mono = ast_ast_arena_expr_get(arena, ((e).method_call_base_ref));
        int32_t recv_ty = pipeline_expr_resolved_type_ref(arena, ((e).method_call_base_ref));
        struct ast_Module * mono_mod = ((ctx)->current_codegen_module);
        int32_t mono_fi = ((ctx)->current_func_index);
        if ((((recv_ty <=0) && (mono_mod !=0)) && (((int32_t)(((base_mono).kind))) ==3))) {
          int32_t parm_i = 0;
          int32_t nparm = pipeline_module_func_num_params_at(mono_mod, mono_fi);
          while ((parm_i < nparm)) {
            uint8_t pname[128] = {};
            int32_t pnl = pipeline_module_func_param_name_len_at(mono_mod, mono_fi, parm_i);
            (void)(pipeline_module_func_param_name_copy32(mono_mod, mono_fi, parm_i, &((pname)[0])));
            if (((pnl ==((base_mono).var_name_len)) && (pnl > 0))) {
              int32_t peq = 1;
              int32_t pi2 = 0;
              while ((pi2 < pnl)) {
                if (((pname)[pi2] !=(((base_mono).var_name))[pi2])) {
                  (void)((peq = 0));
                  (void)((pi2 = pnl));
                } else {
                  (void)((pi2 = (pi2 + 1)));
                }
              }
              if ((peq !=0)) {
                (void)((recv_ty = pipeline_module_func_param_type_ref_at(mono_mod, mono_fi, parm_i)));
                (void)((parm_i = 999));
              }
            }
            (void)((parm_i = (parm_i + 1)));
          }
        }
        if ((((recv_ty <=0) && (((int32_t)(((base_mono).kind))) ==3)) && (((ctx)->current_block_ref) > 0))) {
          int32_t blk = ((ctx)->current_block_ref);
          int32_t nlets = ast_ast_block_num_lets(arena, blk);
          int32_t li = 0;
          while ((li < nlets)) {
            uint8_t lname[128] = {};
            int32_t lnl = pipeline_block_let_name_len(arena, blk, li);
            (void)(pipeline_block_let_name_copy64(arena, blk, li, &((lname)[0])));
            if (((lnl ==((base_mono).var_name_len)) && (lnl > 0))) {
              int32_t leq = 1;
              int32_t li2 = 0;
              while ((li2 < lnl)) {
                if (((lname)[li2] !=(((base_mono).var_name))[li2])) {
                  (void)((leq = 0));
                  (void)((li2 = lnl));
                } else {
                  (void)((li2 = (li2 + 1)));
                }
              }
              if ((leq !=0)) {
                (void)((recv_ty = pipeline_block_let_type_ref(arena, blk, li)));
                (void)((li = 999));
              }
            }
            (void)((li = (li + 1)));
          }
        }
        int32_t concrete_ty = codegen_mono_subst_type(ctx, arena, recv_ty);
        if (((concrete_ty !=recv_ty) && (concrete_ty > 0))) {
          struct ast_Module * cur_mod_mono = ((ctx)->current_codegen_module);
          if ((cur_mod_mono !=0)) {
            int32_t impl_fi = codegen_find_impl_method_for_type(cur_mod_mono, arena, &((((e).method_call_name))[0]), ((e).method_call_name_len), concrete_ty);
            if ((impl_fi >=0)) {
              if ((((ctx)->current_codegen_prefix_len) > 0)) {
                if ((codegen_emit_bytes_from_ptr(out, &((((ctx)->current_codegen_prefix_mirror))[0]), ((ctx)->current_codegen_prefix_len)) !=0)) {
                  return -1;
                }
              }
              int32_t c6_mono_rc = codegen_try_emit_impl_method_mono_call_name(out, arena, ctx, cur_mod_mono, impl_fi, concrete_ty);
              if ((c6_mono_rc < 0)) {
                return -1;
              }
              if ((c6_mono_rc ==0)) {
                if ((codegen_emit_func_link_name(out, arena, cur_mod_mono, impl_fi) !=0)) {
                  return -1;
                }
              }
              if ((codegen_append_byte(out, 40) !=0)) {
                return -1;
              }
              if ((((e).method_call_base_ref) <=0)) {
                if ((codegen_append_byte(out, 48) !=0)) {
                  return -1;
                }
              } else {
                if ((codegen_emit_call_arg_slice_abi(arena, out, ((e).method_call_base_ref), ctx) !=0)) {
                  return -1;
                }
              }
              int32_t ai_mono = 0;
              while ((ai_mono < ((e).method_call_num_args))) {
                uint8_t cs_mono[2] = {44, 32};
                if ((codegen_emit_bytes_from_ptr(out, &((cs_mono)[0]), 2) !=0)) {
                  return -1;
                }
                int32_t dep_arg_mono = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_mono);
                if (ast_ref_is_null(dep_arg_mono)) {
                  if ((codegen_append_byte(out, 48) !=0)) {
                    return -1;
                  }
                } else {
                  if ((codegen_emit_call_arg_slice_abi(arena, out, dep_arg_mono, ctx) !=0)) {
                    return -1;
                  }
                }
                (void)((ai_mono = (ai_mono + 1)));
              }
              return codegen_append_byte(out, 41);
            }
          }
        }
      }
      if ((ctx !=0)) {
        int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        int32_t func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        int32_t mc_resolved_ok = 0;
        if ((((dep_ix >=0) && (func_ix >=0)) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
          struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
          if (((dep_mod !=0) && (func_ix < ((dep_mod)->num_funcs)))) {
            uint8_t fn_name[128] = {};
            int32_t fn_len = pipeline_module_func_name_len_at(dep_mod, func_ix);
            int32_t name_ok = 0;
            if ((fn_len > 0)) {
              (void)(pipeline_module_func_name_copy64(dep_mod, func_ix, &((fn_name)[0])));
            }
            if ((((fn_len > 0) && (fn_len ==((e).method_call_name_len))) && (((e).method_call_name_len) > 0))) {
              (void)((name_ok = 1));
              int32_t mi = 0;
              while ((mi < fn_len)) {
                if (((fn_name)[mi] !=(((e).method_call_name))[mi])) {
                  (void)((name_ok = 0));
                  (void)((mi = fn_len));
                } else {
                  (void)((mi = (mi + 1)));
                }
              }
            }
            if (((name_ok !=0) && (pipeline_module_func_num_params_at(dep_mod, func_ix) ==((e).method_call_num_args)))) {
              (void)((mc_resolved_ok = 1));
            }
            if ((mc_resolved_ok !=0)) {
              uint8_t bind_path[128] = {};
              int32_t bind_plen = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &((bind_path)[0]));
              uint8_t dep_path_chk[128] = {};
              (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &((dep_path_chk)[0])));
              int32_t dep_plen_chk = pipeline_dep_ctx_import_path_len(ctx, dep_ix);
              if ((bind_plen > 0)) {
                if ((bind_plen !=dep_plen_chk)) {
                  (void)((mc_resolved_ok = 0));
                } else {
                  int32_t bp = 0;
                  while ((bp < bind_plen)) {
                    if (((bind_path)[bp] !=(dep_path_chk)[bp])) {
                      (void)((mc_resolved_ok = 0));
                      (void)((bp = bind_plen));
                    } else {
                      (void)((bp = (bp + 1)));
                    }
                  }
                }
              }
            }
            if ((mc_resolved_ok !=0)) {
              uint8_t dep_path[128] = {};
              (void)(pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &((dep_path)[0])));
              uint8_t pre_buf[128] = {};
              (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((pre_buf)[0]), 128));
              int32_t pre_len = 0;
              while (((pre_len < 128) && ((pre_buf)[pre_len] !=0))) {
                (void)((pre_len = (pre_len + 1)));
              }
              int32_t drv_buf_mc = 0;
              if (((codegen_path_is_std_io_driver_bytes(&((dep_path)[0])) !=0) && (fn_len > 0))) {
                (void)((drv_buf_mc = codegen_emit_io_driver_buf_call_name(out, &((fn_name)[0]), fn_len, ((e).method_call_num_args))));
                if ((drv_buf_mc < 0)) {
                  return -1;
                }
              }
              if ((drv_buf_mc ==0)) {
                int32_t call_pre = codegen_func_c_symbol_prefix_len(dep_mod, func_ix, pre_len);
                if (((((call_pre > 0) && (fn_len > 0)) && (codegen_c_prefix_redundant_with_name(&((pre_buf)[0]), call_pre, &((fn_name)[0]), fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_buf)[0]), call_pre) !=0))) {
                  return -1;
                }
                struct ast_ASTArena * dep_arena = codegen_arena_for_module(ctx, dep_mod, arena);
                if ((dep_arena ==0)) {
                  (void)((dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix)));
                }
                if ((fn_len > 0)) {
                  int32_t dep_recv_ty = 0;
                  if (!(ast_ref_is_null(((e).method_call_base_ref)))) {
                    (void)((dep_recv_ty = pipeline_expr_resolved_type_ref(arena, ((e).method_call_base_ref))));
                  }
                  int32_t dep_mono_rc = 0;
                  if ((dep_recv_ty > 0)) {
                    (void)((dep_mono_rc = codegen_try_emit_impl_method_mono_call_name(out, dep_arena, ctx, dep_mod, func_ix, dep_recv_ty)));
                  }
                  if ((dep_mono_rc < 0)) {
                    return -1;
                  }
                  if ((dep_mono_rc ==0)) {
                    if ((codegen_emit_func_link_name(out, dep_arena, dep_mod, func_ix) !=0)) {
                      return -1;
                    }
                  }
                }
              }
              if ((codegen_append_byte(out, 40) !=0)) {
                return -1;
              }
              int32_t n_dep = codegen_call_num_args_override(&((pre_buf)[0]), pre_len, &((fn_name)[0]), fn_len, ((e).method_call_num_args));
              int32_t ai = 0;
              while ((ai < n_dep)) {
                if ((ai > 0)) {
                  uint8_t comma_dep[3] = {44, 32, 0};
                  if ((codegen_emit_bytes_3(out, &((comma_dep)[0]), 2) !=0)) {
                    return -1;
                  }
                }
                if (((drv_buf_mc !=0) && (ai ==0))) {
                  uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
                  if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                    return -1;
                  }
                }
                int32_t dep_arg = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
                if (ast_ref_is_null(dep_arg)) {
                  if ((codegen_append_byte(out, 48) !=0)) {
                    return -1;
                  }
                } else {
                  if ((codegen_emit_call_arg_slice_abi(arena, out, dep_arg, ctx) !=0)) {
                    return -1;
                  }
                }
                (void)((ai = (ai + 1)));
              }
              return codegen_append_byte(out, 41);
            }
          }
        }
        uint8_t dep_path_fb[128] = {};
        int32_t dep_path_fb_len = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &((dep_path_fb)[0]));
        if ((dep_path_fb_len > 0)) {
          uint8_t pre_fb[128] = {};
          (void)(codegen_import_path_to_c_prefix_into(&((dep_path_fb)[0]), &((pre_fb)[0]), 128));
          int32_t pre_fb_len = 0;
          while (((pre_fb_len < 128) && ((pre_fb)[pre_fb_len] !=0))) {
            (void)((pre_fb_len = (pre_fb_len + 1)));
          }
          int32_t drv_buf_fb = 0;
          if ((codegen_path_is_std_io_driver_bytes(&((dep_path_fb)[0])) !=0)) {
            (void)((drv_buf_fb = codegen_emit_io_driver_buf_call_name(out, &((((e).method_call_name))[0]), ((e).method_call_name_len), ((e).method_call_num_args))));
            if ((drv_buf_fb < 0)) {
              return -1;
            }
          }
          if ((drv_buf_fb ==0)) {
            if ((((pre_fb_len > 0) && (codegen_c_prefix_redundant_with_name(&((pre_fb)[0]), pre_fb_len, &((((e).method_call_name))[0]), ((e).method_call_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((pre_fb)[0]), pre_fb_len) !=0))) {
              return -1;
            }
            struct ast_Module * fb_dep_mod = 0;
            int32_t dj = 0;
            while ((dj < pipeline_dep_ctx_ndep(ctx))) {
              uint8_t dj_path[128] = {};
              (void)(pipeline_dep_ctx_import_path_copy64(ctx, dj, &((dj_path)[0])));
              int32_t dj_plen = pipeline_dep_ctx_import_path_len(ctx, dj);
              if (((dj_plen ==dep_path_fb_len) && (dj_plen > 0))) {
                int32_t dj_eq = 1;
                int32_t dk = 0;
                while ((dk < dj_plen)) {
                  if (((dj_path)[dk] !=(dep_path_fb)[dk])) {
                    (void)((dj_eq = 0));
                    (void)((dk = dj_plen));
                  } else {
                    (void)((dk = (dk + 1)));
                  }
                }
                if ((dj_eq !=0)) {
                  (void)((fb_dep_mod = pipeline_dep_ctx_module_at(ctx, dj)));
                  (void)((dj = pipeline_dep_ctx_ndep(ctx)));
                }
              }
              (void)((dj = (dj + 1)));
            }
            if ((codegen_emit_call_func_name(out, arena, ctx, expr_ref, fb_dep_mod, &((((e).method_call_name))[0]), ((e).method_call_name_len)) !=0)) {
              return -1;
            }
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          int32_t n_fb = codegen_call_num_args_override(&((pre_fb)[0]), pre_fb_len, &((((e).method_call_name))[0]), ((e).method_call_name_len), ((e).method_call_num_args));
          int32_t ai_fb = 0;
          while ((ai_fb < n_fb)) {
            if ((ai_fb > 0)) {
              uint8_t comma_fb[3] = {44, 32, 0};
              if ((codegen_emit_bytes_3(out, &((comma_fb)[0]), 2) !=0)) {
                return -1;
              }
            }
            if (((drv_buf_fb !=0) && (ai_fb ==0))) {
              uint8_t cast_buf[19] = {40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((cast_buf)[0]), 18) !=0)) {
                return -1;
              }
            }
            int32_t arg_fb = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_fb);
            if (ast_ref_is_null(arg_fb)) {
              if ((codegen_append_byte(out, 48) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_call_arg_slice_abi(arena, out, arg_fb, ctx) !=0)) {
                return -1;
              }
            }
            (void)((ai_fb = (ai_fb + 1)));
          }
          return codegen_append_byte(out, 41);
        }
      }
      if (((ctx !=0) && (((ctx)->current_codegen_module) !=0))) {
        int32_t uf_dep = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        int32_t uf_fn = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
        struct ast_Module * uf_mod = ((ctx)->current_codegen_module);
        if (((((uf_fn >=0) && (uf_dep < 0)) && (uf_fn < ((uf_mod)->num_funcs))) && (((e).method_call_name_len) > 0))) {
          uint8_t cur_pre[128] = {};
          uint8_t cur_dep_path_buf[128] = {};
          int32_t cur_dep_plen = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &((cur_dep_path_buf)[0]));
          int32_t pl = 0;
          if ((cur_dep_plen > 0)) {
            (void)(codegen_import_path_to_c_prefix_into(&((cur_dep_path_buf)[0]), &((cur_pre)[0]), 128));
            while (((pl < 128) && ((cur_pre)[pl] !=0))) {
              (void)((pl = (pl + 1)));
            }
          } else {
            if ((((ctx)->current_codegen_prefix_len) > 0)) {
              int32_t _cpl = ((ctx)->current_codegen_prefix_len);
              int32_t pi = 0;
              while (((pi < _cpl) && (pi < 127))) {
                (void)(((cur_pre)[pi] = (((ctx)->current_codegen_prefix_mirror))[pi]));
                (void)((pi = (pi + 1)));
              }
              (void)(((cur_pre)[pi] = ((uint8_t)(0))));
              (void)((pl = pi));
            }
          }
          if (((pipeline_module_func_is_extern_at(uf_mod, uf_fn) !=0) || (pipeline_module_func_is_no_mangle_at(uf_mod, uf_fn) !=0))) {
            (void)((pl = 0));
          }
          if ((((pl > 0) && (codegen_c_prefix_redundant_with_name(&((cur_pre)[0]), pl, &((((e).method_call_name))[0]), ((e).method_call_name_len)) ==0)) && (codegen_emit_bytes_from_ptr(out, &((cur_pre)[0]), pl) !=0))) {
            return -1;
          }
          struct ast_ASTArena * uf_arena = arena;
          if ((((ctx)->current_codegen_arena) !=0)) {
            (void)((uf_arena = ((ctx)->current_codegen_arena)));
          }
          int32_t uf_bty_mono = 0;
          if (!(ast_ref_is_null(((e).method_call_base_ref)))) {
            (void)((uf_bty_mono = pipeline_expr_resolved_type_ref(arena, ((e).method_call_base_ref))));
          }
          int32_t uf_mono_rc = 0;
          if ((uf_bty_mono > 0)) {
            (void)((uf_mono_rc = codegen_try_emit_impl_method_mono_call_name(out, uf_arena, ctx, uf_mod, uf_fn, uf_bty_mono)));
          }
          if ((uf_mono_rc < 0)) {
            return -1;
          }
          if ((uf_mono_rc ==0)) {
            if ((codegen_emit_func_link_name(out, uf_arena, uf_mod, uf_fn) !=0)) {
              return -1;
            }
          }
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          if (!(ast_ref_is_null(((e).method_call_base_ref)))) {
            int32_t uf_are = 0;
            int32_t uf_p0 = pipeline_module_func_param_type_ref_at(uf_mod, uf_fn, 0);
            int32_t uf_bty = pipeline_expr_resolved_type_ref(arena, ((e).method_call_base_ref));
            if ((((uf_p0 > 0) && (uf_bty > 0)) && (pipeline_type_kind_ord_at(uf_arena, uf_p0) ==9))) {
              int32_t uf_pe = pipeline_type_elem_ref_at(uf_arena, uf_p0);
              if ((((uf_pe > 0) && (pipeline_typeck_type_refs_equal_c(uf_arena, uf_bty, uf_p0) ==0)) && (pipeline_typeck_type_refs_equal_c(uf_arena, uf_bty, uf_pe) !=0))) {
                (void)((uf_are = 1));
              }
            }
            if ((uf_are !=0)) {
              if ((codegen_append_byte(out, 38) !=0)) {
                return -1;
              }
              if ((codegen_emit_expr(arena, out, ((e).method_call_base_ref), ctx) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_call_arg_slice_abi(arena, out, ((e).method_call_base_ref), ctx) !=0)) {
                return -1;
              }
            }
          } else {
            if ((codegen_append_byte(out, 48) !=0)) {
              return -1;
            }
          }
          int32_t mi_uf = 0;
          while ((mi_uf < ((e).method_call_num_args))) {
            uint8_t comma_uf[3] = {44, 32, 0};
            if ((codegen_emit_bytes_3(out, &((comma_uf)[0]), 2) !=0)) {
              return -1;
            }
            int32_t m_arg_uf = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi_uf);
            if (ast_ref_is_null(m_arg_uf)) {
              if ((codegen_append_byte(out, 48) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_call_arg_slice_abi(arena, out, m_arg_uf, ctx) !=0)) {
                return -1;
              }
            }
            (void)((mi_uf = (mi_uf + 1)));
          }
          return codegen_append_byte(out, 41);
        }
      }
      if ((((((((((((e).method_call_name_len) ==6) && ((((e).method_call_name))[0] ==100)) && ((((e).method_call_name))[1] ==111)) && ((((e).method_call_name))[2] ==117)) && ((((e).method_call_name))[3] ==98)) && ((((e).method_call_name))[4] ==108)) && ((((e).method_call_name))[5] ==101)) && (((e).method_call_num_args) ==0)) && !(ast_ref_is_null(((e).method_call_base_ref))))) {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, ((e).method_call_base_ref), ctx) !=0)) {
          return -1;
        }
        uint8_t mul2[6] = {32, 42, 32, 50, 41, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((mul2)[0]), 5) !=0)) {
          return -1;
        }
        return 0;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(((e).method_call_base_ref))) && (codegen_emit_expr(arena, out, ((e).method_call_base_ref), ctx) !=0))) {
        return -1;
      }
      uint8_t dot[2] = {46, 0};
      if ((codegen_emit_bytes_2(out, &((dot)[0]), 1) !=0)) {
        return -1;
      }
      if ((codegen_emit_bytes_64(out, &((((e).method_call_name))[0]), ((e).method_call_name_len)) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        return -1;
      }
      int32_t mi = 0;
      while ((mi < ((e).method_call_num_args))) {
        if ((mi > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
        }
        int32_t m_arg = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi);
        if (ast_ref_is_null(m_arg)) {
          if ((codegen_append_byte(out, 48) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_emit_call_arg_slice_abi(arena, out, m_arg, ctx) !=0)) {
            return -1;
          }
        }
        (void)((mi = (mi + 1)));
      }
      if ((codegen_append_byte(out, 41) !=0)) {
        return -1;
      }
      return codegen_append_byte(out, 41);
    }
    if ((((int32_t)(((e).kind))) ==43)) {
      if ((((e).match_num_arms) <=0)) {
        return codegen_append_byte(out, 48);
      }
      return codegen_emit_match_from_arm(arena, out, expr_ref, ctx, 0);
    }
    if ((((int32_t)(((e).kind))) ==45)) {
      uint8_t sl_pfx[128] = {};
      int32_t sl_plen = codegen_emit_prefix_len_from_ctx(ctx, &((sl_pfx)[0]), 128);
      int32_t bare_user_lit = 0;
      if (((ctx !=0) && (((e).struct_lit_struct_name_len) > 0))) {
        int32_t lit_bare_off = 0;
        int32_t lit_bi = 0;
        while (((lit_bi < ((e).struct_lit_struct_name_len)) && (lit_bi < 64))) {
          if (((((e).struct_lit_struct_name))[lit_bi] ==46)) {
            (void)((lit_bare_off = (lit_bi + 1)));
          }
          (void)((lit_bi = (lit_bi + 1)));
        }
        int32_t lit_bare_len = (((e).struct_lit_struct_name_len) - lit_bare_off);
        if ((lit_bare_len > 0)) {
          int32_t lit_owner = codegen_type_dep_struct_owner_index(ctx, &((((e).struct_lit_struct_name))[lit_bare_off]), lit_bare_len);
          if ((lit_owner >=0)) {
            uint8_t lit_path[128] = {};
            int32_t lit_plen = codegen_dep_import_path_len_at(ctx, lit_owner, &((lit_path)[0]));
            if ((lit_plen > 0)) {
              (void)(codegen_import_path_to_c_prefix_into(&((lit_path)[0]), &((sl_pfx)[0]), 128));
              (void)((sl_plen = 0));
              while (((sl_plen < 128) && ((sl_pfx)[sl_plen] !=0))) {
                (void)((sl_plen = (sl_plen + 1)));
              }
            }
          }
        }
      }
      if (((((sl_plen ==0) && (ctx !=0)) && (((ctx)->current_codegen_dep_index) < 0)) && (((ctx)->current_codegen_module) !=0))) {
        struct ast_Module * modu = ((ctx)->current_codegen_module);
        int32_t sk = 0;
        while ((sk < ((modu)->num_struct_layouts))) {
          int32_t snl = pipeline_module_struct_layout_name_len(modu, sk);
          if (((snl ==((e).struct_lit_struct_name_len)) && (snl > 0))) {
            uint8_t snm[128] = {};
            (void)(pipeline_module_struct_layout_name_into(modu, sk, &((snm)[0])));
            int eq2 = 1;
            int32_t sj = 0;
            while (((sj < snl) && (sj < 64))) {
              if (((snm)[sj] !=(((e).struct_lit_struct_name))[sj])) {
                (void)((eq2 = 0));
                break;
              }
              (void)((sj = (sj + 1)));
            }
            if (eq2) {
              (void)((bare_user_lit = 1));
              break;
            }
          }
          (void)((sk = (sk + 1)));
        }
      }
      if ((codegen_should_skip_emit_struct_layout_for_abi_dup(&((((e).struct_lit_struct_name))[0]), ((e).struct_lit_struct_name_len)) !=0)) {
        (void)((bare_user_lit = 0));
        if (((((e).struct_lit_struct_name_len) ==6) && ((((e).struct_lit_struct_name))[0] ==66))) {
          (void)(((sl_pfx)[0] = 115));
          (void)(((sl_pfx)[1] = 116));
          (void)(((sl_pfx)[2] = 100));
          (void)(((sl_pfx)[3] = 95));
          (void)(((sl_pfx)[4] = 105));
          (void)(((sl_pfx)[5] = 111));
          (void)(((sl_pfx)[6] = 95));
          (void)(((sl_pfx)[7] = 100));
          (void)(((sl_pfx)[8] = 114));
          (void)(((sl_pfx)[9] = 105));
          (void)(((sl_pfx)[10] = 118));
          (void)(((sl_pfx)[11] = 101));
          (void)(((sl_pfx)[12] = 114));
          (void)(((sl_pfx)[13] = 95));
          (void)(((sl_pfx)[14] = 0));
          (void)((sl_plen = 14));
        } else {
          if (((((e).struct_lit_struct_name_len) ==5) && ((((e).struct_lit_struct_name))[0] ==69))) {
            (void)(((sl_pfx)[0] = 115));
            (void)(((sl_pfx)[1] = 116));
            (void)(((sl_pfx)[2] = 100));
            (void)(((sl_pfx)[3] = 95));
            (void)(((sl_pfx)[4] = 101));
            (void)(((sl_pfx)[5] = 114));
            (void)(((sl_pfx)[6] = 114));
            (void)(((sl_pfx)[7] = 111));
            (void)(((sl_pfx)[8] = 114));
            (void)(((sl_pfx)[9] = 95));
            (void)(((sl_pfx)[10] = 0));
            (void)((sl_plen = 10));
          } else if ((((((e).struct_lit_struct_name_len) ==10) && ((((e).struct_lit_struct_name))[0] ==69)) && ((((e).struct_lit_struct_name))[5] ==67))) {
            /* ErrorChain → std_error_ (pair emit_type) */
            (void)(((sl_pfx)[0] = 115));
            (void)(((sl_pfx)[1] = 116));
            (void)(((sl_pfx)[2] = 100));
            (void)(((sl_pfx)[3] = 95));
            (void)(((sl_pfx)[4] = 101));
            (void)(((sl_pfx)[5] = 114));
            (void)(((sl_pfx)[6] = 114));
            (void)(((sl_pfx)[7] = 111));
            (void)(((sl_pfx)[8] = 114));
            (void)(((sl_pfx)[9] = 95));
            (void)(((sl_pfx)[10] = 0));
            (void)((sl_plen = 10));
          } else if ((((((((e).struct_lit_struct_name_len) ==9) && ((((e).struct_lit_struct_name))[0] ==65)) && ((((e).struct_lit_struct_name))[1] ==108)) && ((((e).struct_lit_struct_name))[2] ==108)) && ((((e).struct_lit_struct_name))[3] ==111))) {
            /* Allocator → std_heap_ (pair emit_type) */
            (void)(((sl_pfx)[0] = 115));
            (void)(((sl_pfx)[1] = 116));
            (void)(((sl_pfx)[2] = 100));
            (void)(((sl_pfx)[3] = 95));
            (void)(((sl_pfx)[4] = 104));
            (void)(((sl_pfx)[5] = 101));
            (void)(((sl_pfx)[6] = 97));
            (void)(((sl_pfx)[7] = 112));
            (void)(((sl_pfx)[8] = 95));
            (void)(((sl_pfx)[9] = 0));
            (void)((sl_plen = 9));
          } else if (((((e).struct_lit_struct_name_len) ==7)
              && ((((e).struct_lit_struct_name))[0] ==65)
              && ((((e).struct_lit_struct_name))[1] ==114)
              && ((((e).struct_lit_struct_name))[2] ==101)
              && ((((e).struct_lit_struct_name))[3] ==110)
              && ((((e).struct_lit_struct_name))[4] ==97)
              && ((((e).struct_lit_struct_name))[5] ==54)
              && ((((e).struct_lit_struct_name))[6] ==52))) {
            /* Arena64 → std_heap_ (pair emit_type) */
            (void)(((sl_pfx)[0] = 115));
            (void)(((sl_pfx)[1] = 116));
            (void)(((sl_pfx)[2] = 100));
            (void)(((sl_pfx)[3] = 95));
            (void)(((sl_pfx)[4] = 104));
            (void)(((sl_pfx)[5] = 101));
            (void)(((sl_pfx)[6] = 97));
            (void)(((sl_pfx)[7] = 112));
            (void)(((sl_pfx)[8] = 95));
            (void)(((sl_pfx)[9] = 0));
            (void)((sl_plen = 9));
          } else {
            if (((((((((((e).struct_lit_struct_name_len) >=8) && ((((e).struct_lit_struct_name))[0] ==79)) && ((((e).struct_lit_struct_name))[1] ==112)) && ((((e).struct_lit_struct_name))[2] ==116)) && ((((e).struct_lit_struct_name))[3] ==105)) && ((((e).struct_lit_struct_name))[4] ==111)) && ((((e).struct_lit_struct_name))[5] ==110)) && ((((e).struct_lit_struct_name))[6] ==95))) {
              (void)(((sl_pfx)[0] = 99));
              (void)(((sl_pfx)[1] = 111));
              (void)(((sl_pfx)[2] = 114));
              (void)(((sl_pfx)[3] = 101));
              (void)(((sl_pfx)[4] = 95));
              (void)(((sl_pfx)[5] = 111));
              (void)(((sl_pfx)[6] = 112));
              (void)(((sl_pfx)[7] = 116));
              (void)(((sl_pfx)[8] = 105));
              (void)(((sl_pfx)[9] = 111));
              (void)(((sl_pfx)[10] = 110));
              (void)(((sl_pfx)[11] = 95));
              (void)(((sl_pfx)[12] = 0));
              (void)((sl_plen = 12));
            } else {
              if (((((e).struct_lit_struct_name_len) ==9) && ((((e).struct_lit_struct_name))[0] ==82))) {
                (void)(((sl_pfx)[0] = 99));
                (void)(((sl_pfx)[1] = 111));
                (void)(((sl_pfx)[2] = 114));
                (void)(((sl_pfx)[3] = 101));
                (void)(((sl_pfx)[4] = 95));
                (void)(((sl_pfx)[5] = 114));
                (void)(((sl_pfx)[6] = 101));
                (void)(((sl_pfx)[7] = 115));
                (void)(((sl_pfx)[8] = 117));
                (void)(((sl_pfx)[9] = 108));
                (void)(((sl_pfx)[10] = 116));
                (void)(((sl_pfx)[11] = 95));
                (void)(((sl_pfx)[12] = 0));
                (void)((sl_plen = 12));
              } else {
                if ((((((e).struct_lit_struct_name_len) ==10) && ((((e).struct_lit_struct_name))[0] ==82)) && ((((e).struct_lit_struct_name))[7] ==105))) {
                  (void)(((sl_pfx)[0] = 99));
                  (void)(((sl_pfx)[1] = 111));
                  (void)(((sl_pfx)[2] = 114));
                  (void)(((sl_pfx)[3] = 101));
                  (void)(((sl_pfx)[4] = 95));
                  (void)(((sl_pfx)[5] = 114));
                  (void)(((sl_pfx)[6] = 101));
                  (void)(((sl_pfx)[7] = 115));
                  (void)(((sl_pfx)[8] = 117));
                  (void)(((sl_pfx)[9] = 108));
                  (void)(((sl_pfx)[10] = 116));
                  (void)(((sl_pfx)[11] = 95));
                  (void)(((sl_pfx)[12] = 0));
                  (void)((sl_plen = 12));
                } else {
                  if ((((((((e).struct_lit_struct_name_len) ==6) && ((((e).struct_lit_struct_name))[0] ==83)) && ((((e).struct_lit_struct_name))[1] ==116)) && ((((e).struct_lit_struct_name))[2] ==114)) && ((((e).struct_lit_struct_name))[3] ==105))) {
                    (void)(((sl_pfx)[0] = 115));
                    (void)(((sl_pfx)[1] = 116));
                    (void)(((sl_pfx)[2] = 100));
                    (void)(((sl_pfx)[3] = 95));
                    (void)(((sl_pfx)[4] = 115));
                    (void)(((sl_pfx)[5] = 116));
                    (void)(((sl_pfx)[6] = 114));
                    (void)(((sl_pfx)[7] = 105));
                    (void)(((sl_pfx)[8] = 110));
                    (void)(((sl_pfx)[9] = 103));
                    (void)(((sl_pfx)[10] = 95));
                    (void)(((sl_pfx)[11] = 0));
                    (void)((sl_plen = 11));
                  } else {
                    if ((((((e).struct_lit_struct_name_len) ==7) && ((((e).struct_lit_struct_name))[0] ==83)) && ((((e).struct_lit_struct_name))[3] ==86))) {
                      (void)(((sl_pfx)[0] = 115));
                      (void)(((sl_pfx)[1] = 116));
                      (void)(((sl_pfx)[2] = 100));
                      (void)(((sl_pfx)[3] = 95));
                      (void)(((sl_pfx)[4] = 115));
                      (void)(((sl_pfx)[5] = 116));
                      (void)(((sl_pfx)[6] = 114));
                      (void)(((sl_pfx)[7] = 105));
                      (void)(((sl_pfx)[8] = 110));
                      (void)(((sl_pfx)[9] = 103));
                      (void)(((sl_pfx)[10] = 95));
                      (void)(((sl_pfx)[11] = 0));
                      (void)((sl_plen = 11));
                    } else {
                      if (((((e).struct_lit_struct_name_len) ==9) && ((((e).struct_lit_struct_name))[0] ==84))) {
                        (void)(((sl_pfx)[0] = 115));
                        (void)(((sl_pfx)[1] = 116));
                        (void)(((sl_pfx)[2] = 100));
                        (void)(((sl_pfx)[3] = 95));
                        (void)(((sl_pfx)[4] = 110));
                        (void)(((sl_pfx)[5] = 101));
                        (void)(((sl_pfx)[6] = 116));
                        (void)(((sl_pfx)[7] = 95));
                        (void)(((sl_pfx)[8] = 0));
                        (void)((sl_plen = 8));
                      } else {
                        if (((((e).struct_lit_struct_name_len) ==11) && ((((e).struct_lit_struct_name))[0] ==84))) {
                          (void)(((sl_pfx)[0] = 115));
                          (void)(((sl_pfx)[1] = 116));
                          (void)(((sl_pfx)[2] = 100));
                          (void)(((sl_pfx)[3] = 95));
                          (void)(((sl_pfx)[4] = 110));
                          (void)(((sl_pfx)[5] = 101));
                          (void)(((sl_pfx)[6] = 116));
                          (void)(((sl_pfx)[7] = 95));
                          (void)(((sl_pfx)[8] = 0));
                          (void)((sl_plen = 8));
                        } else {
                          if ((((((e).struct_lit_struct_name_len) ==10) && ((((e).struct_lit_struct_name))[0] ==70)) && ((((e).struct_lit_struct_name))[1] ==115))) {
                            (void)(((sl_pfx)[0] = 115));
                            (void)(((sl_pfx)[1] = 116));
                            (void)(((sl_pfx)[2] = 100));
                            (void)(((sl_pfx)[3] = 95));
                            (void)(((sl_pfx)[4] = 102));
                            (void)(((sl_pfx)[5] = 115));
                            (void)(((sl_pfx)[6] = 95));
                            (void)(((sl_pfx)[7] = 0));
                            (void)((sl_plen = 7));
                          } else {
                            if ((((((e).struct_lit_struct_name_len) ==5) && ((((e).struct_lit_struct_name))[0] ==73)) && ((((e).struct_lit_struct_name))[1] ==111))) {
                              (void)(((sl_pfx)[0] = 115));
                              (void)(((sl_pfx)[1] = 116));
                              (void)(((sl_pfx)[2] = 100));
                              (void)(((sl_pfx)[3] = 95));
                              (void)(((sl_pfx)[4] = 105));
                              (void)(((sl_pfx)[5] = 111));
                              (void)(((sl_pfx)[6] = 95));
                              (void)(((sl_pfx)[7] = 115));
                              (void)(((sl_pfx)[8] = 121));
                              (void)(((sl_pfx)[9] = 110));
                              (void)(((sl_pfx)[10] = 99));
                              (void)(((sl_pfx)[11] = 95));
                              (void)(((sl_pfx)[12] = 0));
                              (void)((sl_plen = 12));
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      int32_t nf_codegen = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
      int32_t need_call_mat = 0;
      int32_t si_scan = 0;
      while ((si_scan < nf_codegen)) {
        int32_t iref_s = pipeline_expr_struct_lit_init_ref(arena, expr_ref, si_scan);
        if (!(ast_ref_is_null(iref_s))) {
          struct ast_Expr ie_s = ast_ast_arena_expr_get(arena, iref_s);
          if (((((int32_t)(((ie_s).kind))) ==48) || (((int32_t)(((ie_s).kind))) ==49))) {
            uint8_t fnbuf_s[128] = {};
            (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, si_scan, &((fnbuf_s)[0])));
            int32_t flen_s = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, si_scan);
            if ((flen_s > 127)) {
              (void)((flen_s = 127));
            }
            int32_t ftr_s = codegen_lookup_struct_field_type_ref(arena, ctx, &((((e).struct_lit_struct_name))[0]), ((e).struct_lit_struct_name_len), &((fnbuf_s)[0]), flen_s);
            int32_t arr_ty_s = 0;
            if ((!(ast_ref_is_null(ftr_s)) && (pipeline_type_kind_ord_at(arena, ftr_s) ==10))) {
              (void)((arr_ty_s = ftr_s));
            } else {
              if ((!(ast_ref_is_null(((ie_s).resolved_type_ref))) && (pipeline_type_kind_ord_at(arena, ((ie_s).resolved_type_ref)) ==10))) {
                (void)((arr_ty_s = ((ie_s).resolved_type_ref)));
              }
            }
            if (!(ast_ref_is_null(arr_ty_s))) {
              int32_t asz_s = pipeline_type_array_size_at(arena, arr_ty_s);
              if (((asz_s > 0) && (asz_s <=512))) {
                (void)((need_call_mat = 1));
              }
            }
          }
        }
        (void)((si_scan = (si_scan + 1)));
      }
      if ((need_call_mat !=0)) {
        uint8_t mat_open[4] = {40, 123, 32, 0};
        if ((codegen_emit_bytes_4(out, &((mat_open)[0]), 3) !=0)) {
          return -1;
        }
        int32_t mi = 0;
        while ((mi < nf_codegen)) {
          int32_t iref_m = pipeline_expr_struct_lit_init_ref(arena, expr_ref, mi);
          if (ast_ref_is_null(iref_m)) {
            (void)((mi = (mi + 1)));
            continue;
          }
          struct ast_Expr ie_m = ast_ast_arena_expr_get(arena, iref_m);
          if (((((int32_t)(((ie_m).kind))) !=48) && (((int32_t)(((ie_m).kind))) !=49))) {
            (void)((mi = (mi + 1)));
            continue;
          }
          uint8_t fnbuf_m[128] = {};
          (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, mi, &((fnbuf_m)[0])));
          int32_t flen_m = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, mi);
          if ((flen_m > 127)) {
            (void)((flen_m = 127));
          }
          int32_t ftr_m = codegen_lookup_struct_field_type_ref(arena, ctx, &((((e).struct_lit_struct_name))[0]), ((e).struct_lit_struct_name_len), &((fnbuf_m)[0]), flen_m);
          int32_t arr_ty_m = 0;
          if ((!(ast_ref_is_null(ftr_m)) && (pipeline_type_kind_ord_at(arena, ftr_m) ==10))) {
            (void)((arr_ty_m = ftr_m));
          } else {
            if ((!(ast_ref_is_null(((ie_m).resolved_type_ref))) && (pipeline_type_kind_ord_at(arena, ((ie_m).resolved_type_ref)) ==10))) {
              (void)((arr_ty_m = ((ie_m).resolved_type_ref)));
            }
          }
          if (ast_ref_is_null(arr_ty_m)) {
            (void)((mi = (mi + 1)));
            continue;
          }
          int32_t asz_m = pipeline_type_array_size_at(arena, arr_ty_m);
          if (((asz_m <=0) || (asz_m > 512))) {
            (void)((mi = (mi + 1)));
            continue;
          }
          int32_t elem_m = pipeline_type_elem_ref_at(arena, arr_ty_m);
          uint8_t st_kw[8] = {115, 116, 97, 116, 105, 99, 32, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((st_kw)[0]), 7) !=0)) {
            return -1;
          }
          if ((ast_ref_is_null(elem_m) || (codegen_emit_type(arena, out, elem_m, 0, 0, ctx) !=0))) {
            uint8_t fb_i32[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((fb_i32)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t aa_nm[12] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 97, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((aa_nm)[0]), 11) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ((int64_t)(mi))) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 91) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ((int64_t)(asz_m))) !=0)) {
            return -1;
          }
          uint8_t aa_end[4] = {93, 59, 32, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((aa_end)[0]), 3) !=0)) {
            return -1;
          }
          if ((ast_ref_is_null(elem_m) || (codegen_emit_type(arena, out, elem_m, 0, 0, ctx) !=0))) {
            uint8_t fb_i32b[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((fb_i32b)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t ap_nm[14] = {32, 42, 95, 95, 120, 108, 97, 110, 103, 95, 97, 112, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ap_nm)[0]), 12) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ((int64_t)(mi))) !=0)) {
            return -1;
          }
          uint8_t ap_eq[4] = {32, 61, 32, 0};
          if ((codegen_emit_bytes_4(out, &((ap_eq)[0]), 3) !=0)) {
            return -1;
          }
          if ((codegen_emit_expr(arena, out, iref_m, ctx) !=0)) {
            return -1;
          }
          uint8_t ap_sc[4] = {59, 32, 0, 0};
          if ((codegen_emit_bytes_4(out, &((ap_sc)[0]), 2) !=0)) {
            return -1;
          }
          int32_t ai_m = 0;
          while ((ai_m < asz_m)) {
            uint8_t cp_aa[12] = {95, 95, 120, 108, 97, 110, 103, 95, 97, 97, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((cp_aa)[0]), 10) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, ((int64_t)(mi))) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 91) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, ((int64_t)(ai_m))) !=0)) {
              return -1;
            }
            uint8_t cp_mid[16] = {93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 112, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((cp_mid)[0]), 14) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, ((int64_t)(mi))) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 91) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, ((int64_t)(ai_m))) !=0)) {
              return -1;
            }
            uint8_t cp_end[4] = {93, 59, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((cp_end)[0]), 3) !=0)) {
              return -1;
            }
            (void)((ai_m = (ai_m + 1)));
          }
          (void)((mi = (mi + 1)));
        }
      }
      uint8_t open[9] = {40, 115, 116, 114, 117, 99, 116, 32, 0};
      if ((codegen_emit_bytes_9(out, &((open)[0]), 8) !=0)) {
        return -1;
      }
      uint8_t sl_emit_name[128] = {};
      int32_t sl_emit_nlen = ((e).struct_lit_struct_name_len);
      int32_t sl_ni = 0;
      while (((sl_ni < sl_emit_nlen) && (sl_ni < 64))) {
        (void)(((sl_emit_name)[sl_ni] = (((e).struct_lit_struct_name))[sl_ni]));
        (void)((sl_ni = (sl_ni + 1)));
      }
      if (((((ctx !=0) && (((ctx)->mono_active) !=0)) && (((ctx)->mono_num_types) > 0)) && (sl_emit_nlen > 0))) {
        int32_t mi_sl = 0;
        while (((mi_sl < ((ctx)->mono_num_types)) && (mi_sl < 8))) {
          int32_t gtr_sl = (((ctx)->mono_generic_type_refs))[mi_sl];
          int32_t ctr_sl = (((ctx)->mono_concrete_type_refs))[mi_sl];
          if ((((gtr_sl > 0) && (ctr_sl > 0)) && (ctr_sl !=gtr_sl))) {
            uint8_t gnm_sl[128] = {};
            int32_t gnl_sl = pipeline_type_named_name_into(arena, gtr_sl, &((gnm_sl)[0]));
            if (((gnl_sl ==sl_emit_nlen) && (gnl_sl > 0))) {
              int32_t eq_sl = 1;
              int32_t bi_sl = 0;
              while ((bi_sl < gnl_sl)) {
                if (((gnm_sl)[bi_sl] !=(sl_emit_name)[bi_sl])) {
                  (void)((eq_sl = 0));
                  (void)((bi_sl = gnl_sl));
                } else {
                  (void)((bi_sl = (bi_sl + 1)));
                }
              }
              if ((eq_sl !=0)) {
                uint8_t cnm_sl[128] = {};
                int32_t cnl_sl = pipeline_type_named_name_into(arena, ctr_sl, &((cnm_sl)[0]));
                if (((cnl_sl > 0) && (cnl_sl <=64))) {
                  int32_t ci_sl = 0;
                  while ((ci_sl < cnl_sl)) {
                    (void)(((sl_emit_name)[ci_sl] = (cnm_sl)[ci_sl]));
                    (void)((ci_sl = (ci_sl + 1)));
                  }
                  (void)((sl_emit_nlen = cnl_sl));
                }
                (void)((mi_sl = ((ctx)->mono_num_types)));
              }
            }
          }
          (void)((mi_sl = (mi_sl + 1)));
        }
      }
      if ((((bare_user_lit ==0) && (sl_plen > 0)) && (codegen_emit_bytes_from_ptr(out, &((sl_pfx)[0]), sl_plen) !=0))) {
        return -1;
      }
      if ((codegen_emit_bytes_64(out, &((sl_emit_name)[0]), sl_emit_nlen) !=0)) {
        return -1;
      }
      if (((ctx !=0) && (((ctx)->current_codegen_module) !=0))) {
        struct ast_Module * mod_sl = ((ctx)->current_codegen_module);
        int32_t rty_sl = ((e).resolved_type_ref);
        int32_t did_mono = 0;
        (void)(({   int32_t st0 = codegen_try_emit_struct_lit_mono_from_fields(mod_sl, arena, out, expr_ref, &((sl_emit_name)[0]), sl_emit_nlen, ctx);
  if ((st0 < 0)) {
    return -1;
  }
  if ((st0 > 0)) {
    (void)((did_mono = 1));
  }
 }));
        if ((did_mono ==0)) {
          int32_t lk2 = codegen_module_struct_layout_index_by_name(mod_sl, &((sl_emit_name)[0]), sl_emit_nlen);
          if ((lk2 >=0)) {
            int32_t ntp2 = pipeline_module_struct_layout_num_type_params_at(mod_sl, lk2);
            if (((ntp2 > 0) && (ntp2 <=4))) {
              int32_t combo_sl[4] = {};
              int32_t filled_sl = 0;
              int32_t ok_sl = 1;
              int32_t tj_sl = 0;
              while ((tj_sl < ntp2)) {
                (void)(((combo_sl)[tj_sl] = 0));
                (void)((tj_sl = (tj_sl + 1)));
              }
              int32_t nf_lay = pipeline_module_struct_layout_num_fields(mod_sl, lk2);
              int32_t fj_sl = 0;
              while ((fj_sl < nf_lay)) {
                int32_t ftr_sl = pipeline_module_struct_layout_field_type_ref(mod_sl, lk2, fj_sl);
                if ((pipeline_type_kind_ord_at(arena, ftr_sl) ==8)) {
                  uint8_t ftn_sl[128] = {};
                  int32_t ftnl_sl = pipeline_type_named_name_into(arena, ftr_sl, &((ftn_sl)[0]));
                  int32_t slot_sl = -1;
                  int32_t pj_sl = 0;
                  while ((pj_sl < ntp2)) {
                    int32_t tpl_sl = pipeline_module_struct_layout_type_param_name_len(mod_sl, lk2, pj_sl);
                    if (((tpl_sl ==ftnl_sl) && (ftnl_sl > 0))) {
                      uint8_t tpn_sl[128] = {};
                      (void)(pipeline_module_struct_layout_type_param_name_into(mod_sl, lk2, pj_sl, &((tpn_sl)[0])));
                      int32_t peq_sl = 1;
                      int32_t pi_sl = 0;
                      while ((pi_sl < ftnl_sl)) {
                        if (((tpn_sl)[pi_sl] !=(ftn_sl)[pi_sl])) {
                          (void)((peq_sl = 0));
                        }
                        (void)((pi_sl = (pi_sl + 1)));
                      }
                      if ((peq_sl !=0)) {
                        (void)((slot_sl = pj_sl));
                        (void)((pj_sl = ntp2));
                      }
                    }
                    (void)((pj_sl = (pj_sl + 1)));
                  }
                  if ((slot_sl >=0)) {
                    int32_t flen_sl = pipeline_module_struct_layout_field_name_len(mod_sl, lk2, fj_sl);
                    uint8_t fnm_sl[128] = {};
                    (void)(pipeline_module_struct_layout_field_name_into(mod_sl, lk2, fj_sl, &((fnm_sl)[0])));
                    int32_t lit_nf_sl = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
                    int32_t li_sl = 0;
                    while ((li_sl < lit_nf_sl)) {
                      int32_t lfl_sl = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, li_sl);
                      if (((lfl_sl ==flen_sl) && (flen_sl > 0))) {
                        uint8_t lfn_sl[128] = {};
                        (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, li_sl, &((lfn_sl)[0])));
                        int32_t feq_sl = 1;
                        int32_t fi_sl = 0;
                        while ((fi_sl < flen_sl)) {
                          if (((lfn_sl)[fi_sl] !=(fnm_sl)[fi_sl])) {
                            (void)((feq_sl = 0));
                          }
                          (void)((fi_sl = (fi_sl + 1)));
                        }
                        if ((feq_sl !=0)) {
                          int32_t iref_sl = pipeline_expr_struct_lit_init_ref(arena, expr_ref, li_sl);
                          if ((iref_sl > 0)) {
                            int32_t ity_sl = pipeline_expr_resolved_type_ref(arena, iref_sl);
                            if (((ity_sl > 0) && (codegen_type_ref_is_host_concrete(mod_sl, arena, ity_sl) !=0))) {
                              if (((combo_sl)[slot_sl] ==0)) {
                                (void)(((combo_sl)[slot_sl] = ity_sl));
                                (void)((filled_sl = (filled_sl + 1)));
                              }
                            }
                          }
                          (void)((li_sl = lit_nf_sl));
                        }
                      }
                      (void)((li_sl = (li_sl + 1)));
                    }
                  }
                }
                (void)((fj_sl = (fj_sl + 1)));
              }
              int32_t sc_sl = 0;
              while ((sc_sl < ntp2)) {
                if (((combo_sl)[sc_sl] <=0)) {
                  (void)((ok_sl = 0));
                }
                (void)((sc_sl = (sc_sl + 1)));
              }
              if (((ok_sl !=0) && (filled_sl > 0))) {
                if ((codegen_emit_generic_struct_mono_suffix(out, arena, &((combo_sl)[0]), ntp2) !=0)) {
                  return -1;
                }
                (void)((did_mono = 1));
              }
            }
          }
        }
        if (((did_mono ==0) && (rty_sl > 0))) {
          if ((codegen_maybe_emit_generic_struct_mono_suffix_for_type(mod_sl, arena, out, rty_sl, ctx) !=0)) {
            return -1;
          }
          int32_t mono_chk[4] = {};
          int32_t lk_sl = codegen_module_struct_layout_index_by_name(mod_sl, &((sl_emit_name)[0]), sl_emit_nlen);
          if ((lk_sl >=0)) {
            int32_t ntp_sl = pipeline_module_struct_layout_num_type_params_at(mod_sl, lk_sl);
            if (((ntp_sl > 0) && (codegen_generic_struct_fill_concrete_args(mod_sl, arena, rty_sl, ntp_sl, &((mono_chk)[0]), ctx) ==ntp_sl))) {
              (void)((did_mono = 1));
            }
          }
        }
        if ((((did_mono ==0) && (((ctx)->mono_active) !=0)) && (((ctx)->mono_num_types) > 0))) {
          int32_t lk_m = codegen_module_struct_layout_index_by_name(mod_sl, &((sl_emit_name)[0]), sl_emit_nlen);
          if ((lk_m >=0)) {
            int32_t ntp_m = pipeline_module_struct_layout_num_type_params_at(mod_sl, lk_m);
            if (((ntp_m > 0) && (ntp_m <=4))) {
              int32_t combo_m[4] = {};
              int32_t ok_m = 1;
              int32_t tj_m = 0;
              while ((tj_m < ntp_m)) {
                (void)(((combo_m)[tj_m] = 0));
                int32_t tpl_m = pipeline_module_struct_layout_type_param_name_len(mod_sl, lk_m, tj_m);
                uint8_t tpn_m[128] = {};
                (void)(pipeline_module_struct_layout_type_param_name_into(mod_sl, lk_m, tj_m, &((tpn_m)[0])));
                int32_t mi_m = 0;
                while (((mi_m < ((ctx)->mono_num_types)) && (mi_m < 8))) {
                  int32_t gtr_m = (((ctx)->mono_generic_type_refs))[mi_m];
                  int32_t ctr_m = (((ctx)->mono_concrete_type_refs))[mi_m];
                  if (((gtr_m > 0) && (ctr_m > 0))) {
                    uint8_t gnm_m[128] = {};
                    int32_t gnl_m = pipeline_type_named_name_into(arena, gtr_m, &((gnm_m)[0]));
                    if (((gnl_m ==tpl_m) && (gnl_m > 0))) {
                      int32_t geq = 1;
                      int32_t gi = 0;
                      while ((gi < gnl_m)) {
                        if (((gnm_m)[gi] !=(tpn_m)[gi])) {
                          (void)((geq = 0));
                        }
                        (void)((gi = (gi + 1)));
                      }
                      if ((geq !=0)) {
                        (void)(((combo_m)[tj_m] = ctr_m));
                        (void)((mi_m = ((ctx)->mono_num_types)));
                      }
                    }
                  }
                  (void)((mi_m = (mi_m + 1)));
                }
                if (((combo_m)[tj_m] <=0)) {
                  (void)((ok_m = 0));
                }
                (void)((tj_m = (tj_m + 1)));
              }
              if ((ok_m !=0)) {
                if ((codegen_emit_generic_struct_mono_suffix(out, arena, &((combo_m)[0]), ntp_m) !=0)) {
                  return -1;
                }
                (void)((did_mono = 1));
              }
            }
          }
        }
      }
      uint8_t open2[5] = {41, 123, 32, 0, 0};
      if ((codegen_emit_bytes_5(out, &((open2)[0]), 3) !=0)) {
        return -1;
      }
      int32_t fi = 0;
      while ((fi < nf_codegen)) {
        if ((fi > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
        }
        if ((codegen_append_byte(out, 46) !=0)) {
          return -1;
        }
        uint8_t sl_fnbuf[128] = {};
        (void)(pipeline_expr_struct_lit_field_name_into(arena, expr_ref, fi, &((sl_fnbuf)[0])));
        int32_t flen = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, fi);
        if ((flen > 127)) {
          (void)((flen = 127));
        }
        if (((flen > 0) && (codegen_emit_bytes_from_ptr(out, &((sl_fnbuf)[0]), flen) !=0))) {
          return -1;
        }
        uint8_t eq[4] = {32, 61, 32, 0};
        if ((codegen_emit_bytes_4(out, &((eq)[0]), 3) !=0)) {
          return -1;
        }
        int32_t init_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
        if (!(ast_ref_is_null(init_ref))) {
          struct ast_Expr init_e = ast_ast_arena_expr_get(arena, init_ref);
          if ((((int32_t)(((init_e).kind))) ==46)) {
            if ((((init_e).array_lit_num_elems) ==0)) {
              uint8_t zero_init[6] = {123, 32, 48, 32, 125, 0};
              if ((codegen_emit_bytes_6(out, &((zero_init)[0]), 5) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_braced_array_lit_init(arena, out, init_ref, ctx) !=0)) {
                return -1;
              }
            }
          } else {
            int32_t use_elem_expand = 0;
            int32_t arr_sz = 0;
            int32_t flen_lk = flen;
            if ((flen_lk > 127)) {
              (void)((flen_lk = 127));
            }
            int32_t ftr = codegen_lookup_struct_field_type_ref(arena, ctx, &((((e).struct_lit_struct_name))[0]), ((e).struct_lit_struct_name_len), &((sl_fnbuf)[0]), flen_lk);
            if ((!(ast_ref_is_null(ftr)) && (pipeline_type_kind_ord_at(arena, ftr) ==10))) {
              (void)((arr_sz = pipeline_type_array_size_at(arena, ftr)));
              if (((arr_sz > 0) && (arr_sz <=512))) {
                (void)((use_elem_expand = 1));
              }
            } else {
              if ((!(ast_ref_is_null(((init_e).resolved_type_ref))) && (pipeline_type_kind_ord_at(arena, ((init_e).resolved_type_ref)) ==10))) {
                (void)((arr_sz = pipeline_type_array_size_at(arena, ((init_e).resolved_type_ref))));
                if (((arr_sz > 0) && (arr_sz <=512))) {
                  (void)((use_elem_expand = 1));
                }
              }
            }
            int32_t is_call_init = 0;
            if (((((int32_t)(((init_e).kind))) ==48) || (((int32_t)(((init_e).kind))) ==49))) {
              (void)((is_call_init = 1));
            }
            if ((((use_elem_expand !=0) && (is_call_init !=0)) && (need_call_mat !=0))) {
              if ((codegen_append_byte(out, 123) !=0)) {
                return -1;
              }
              int32_t ai_c = 0;
              while ((ai_c < arr_sz)) {
                if ((ai_c > 0)) {
                  uint8_t cm_c[3] = {44, 32, 0};
                  if ((codegen_emit_bytes_3(out, &((cm_c)[0]), 2) !=0)) {
                    return -1;
                  }
                }
                uint8_t aa_rd[12] = {95, 95, 120, 108, 97, 110, 103, 95, 97, 97, 0, 0};
                if ((codegen_emit_bytes_from_ptr(out, &((aa_rd)[0]), 10) !=0)) {
                  return -1;
                }
                if ((codegen_format_int(out, ((int64_t)(fi))) !=0)) {
                  return -1;
                }
                if ((codegen_append_byte(out, 91) !=0)) {
                  return -1;
                }
                if ((codegen_format_int(out, ((int64_t)(ai_c))) !=0)) {
                  return -1;
                }
                if ((codegen_append_byte(out, 93) !=0)) {
                  return -1;
                }
                (void)((ai_c = (ai_c + 1)));
              }
              if ((codegen_append_byte(out, 125) !=0)) {
                return -1;
              }
            } else {
              if ((use_elem_expand !=0)) {
                if ((codegen_append_byte(out, 123) !=0)) {
                  return -1;
                }
                int32_t ai = 0;
                while ((ai < arr_sz)) {
                  if ((ai > 0)) {
                    uint8_t cm[3] = {44, 32, 0};
                    if ((codegen_emit_bytes_3(out, &((cm)[0]), 2) !=0)) {
                      return -1;
                    }
                  }
                  if ((codegen_emit_expr(arena, out, init_ref, ctx) !=0)) {
                    return -1;
                  }
                  if ((codegen_append_byte(out, 91) !=0)) {
                    return -1;
                  }
                  if ((codegen_format_int(out, ((int64_t)(ai))) !=0)) {
                    return -1;
                  }
                  if ((codegen_append_byte(out, 93) !=0)) {
                    return -1;
                  }
                  (void)((ai = (ai + 1)));
                }
                if ((codegen_append_byte(out, 125) !=0)) {
                  return -1;
                }
              } else {
                if ((codegen_emit_expr(arena, out, init_ref, ctx) !=0)) {
                  return -1;
                }
              }
            }
          }
        }
        (void)((fi = (fi + 1)));
      }
      if ((need_call_mat !=0)) {
        uint8_t mat_close[8] = {32, 125, 59, 32, 125, 41, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((mat_close)[0]), 6);
      }
      uint8_t close[4] = {32, 125, 0, 0};
      return codegen_emit_bytes_4(out, &((close)[0]), 2);
    }
    if ((((int32_t)(((e).kind))) ==46)) {
      int32_t n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
      int32_t elem_type_ref = 0;
      int32_t is_slice = 0;
      int32_t is_vector = 0;
      if (((!(ast_ref_is_null(((e).resolved_type_ref))) && (((e).resolved_type_ref) > 0)) && (((e).resolved_type_ref) <=((arena)->num_types)))) {
        struct ast_Type ty = ast_ast_arena_type_get(arena, ((e).resolved_type_ref));
        if ((((int32_t)(((ty).kind))) ==11)) {
          (void)((is_slice = 1));
          (void)((elem_type_ref = ((ty).elem_type_ref)));
        } else {
          if ((((int32_t)(((ty).kind))) ==10)) {
            (void)((elem_type_ref = ((ty).elem_type_ref)));
          } else {
            if ((((int32_t)(((ty).kind))) ==13)) {
              (void)((is_vector = 1));
            } else {
              if (((((int32_t)(((ty).kind))) ==8) && (((ty).name_len) >=5))) {
                int32_t ni = 0;
                while ((ni < ((ty).name_len))) {
                  if (((((ty).name))[ni] ==120)) {
                    (void)((is_vector = 1));
                    (void)((ni = ((ty).name_len)));
                  } else {
                    (void)((ni = (ni + 1)));
                  }
                }
              }
            }
          }
        }
      }
      if ((is_vector !=0)) {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((codegen_emit_type(arena, out, ((e).resolved_type_ref), 0, 0, ctx) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 41) !=0)) {
          return -1;
        }
        if ((codegen_append_byte(out, 123) !=0)) {
          return -1;
        }
        int32_t vai = 0;
        while ((vai < n)) {
          if ((vai > 0)) {
            uint8_t comma[3] = {44, 32, 0};
            if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
              return -1;
            }
          }
          if ((!(ast_ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai))) && (codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai), ctx) !=0))) {
            return -1;
          }
          (void)((vai = (vai + 1)));
        }
        uint8_t vclose[4] = {32, 125, 0, 0};
        return codegen_emit_bytes_4(out, &((vclose)[0]), 2);
      }
      if (((elem_type_ref ==0) && (n > 0))) {
        int32_t first_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
        if (!(ast_ref_is_null(first_ref))) {
          struct ast_Expr first_e = ast_ast_arena_expr_get(arena, first_ref);
          (void)((elem_type_ref = ((first_e).resolved_type_ref)));
        }
      }
      if ((is_slice !=0)) {
        if ((n ==0)) {
          if ((codegen_append_byte(out, 40) !=0)) {
            return -1;
          }
          if ((codegen_emit_type(arena, out, ((e).resolved_type_ref), 0, 0, ctx) !=0)) {
            uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
            if ((codegen_emit_bytes_9(out, &((fallback)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t empty_tail[40] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 118, 111, 105, 100, 32, 42, 41, 48, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 48, 32, 125, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((empty_tail)[0]), 35) !=0)) {
            return -1;
          }
          return 0;
        }
        int32_t all_const = 1;
        int32_t ci = 0;
        while ((ci < n)) {
          int32_t er = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ci);
          if (ast_ref_is_null(er)) {
            (void)((all_const = 0));
          } else {
            int32_t ek = pipeline_expr_kind_ord_at(arena, er);
            if (((ek !=0) && (ek !=2))) {
              (void)((all_const = 0));
            }
          }
          (void)((ci = (ci + 1)));
        }
        if ((all_const !=0)) {
          uint8_t open_stmt[12] = {40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((open_stmt)[0]), 10) !=0)) {
            return -1;
          }
          if ((!(ast_ref_is_null(elem_type_ref)) && (codegen_emit_type(arena, out, elem_type_ref, 0, 0, ctx) !=0))) {
            uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
            if ((codegen_emit_bytes_9(out, &((fallback)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t al_head[18] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 93, 32, 61, 32, 123, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((al_head)[0]), 17) !=0)) {
            return -1;
          }
          int32_t ai = 0;
          while ((ai < n)) {
            if ((ai > 0)) {
              uint8_t comma[3] = {44, 32, 0};
              if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
                return -1;
              }
            }
            if ((!(ast_ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai))) && (codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) !=0))) {
              return -1;
            }
            (void)((ai = (ai + 1)));
          }
          uint8_t mid[6] = {125, 59, 32, 40, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((mid)[0]), 4) !=0)) {
            return -1;
          }
          if ((codegen_emit_type(arena, out, ((e).resolved_type_ref), 0, 0, ctx) !=0)) {
            uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
            if ((codegen_emit_bytes_9(out, &((fallback)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t slice_mid[36] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((slice_mid)[0]), 33) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ai) !=0)) {
            return -1;
          }
          uint8_t slice_end[8] = {32, 125, 59, 32, 125, 41, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((slice_end)[0]), 6) !=0)) {
            return -1;
          }
          return 0;
        }
        uint8_t nc_open[12] = {40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((nc_open)[0]), 10) !=0)) {
          return -1;
        }
        if ((!(ast_ref_is_null(elem_type_ref)) && (codegen_emit_type(arena, out, elem_type_ref, 0, 0, ctx) !=0))) {
          uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
          if ((codegen_emit_bytes_9(out, &((fallback)[0]), 7) !=0)) {
            return -1;
          }
        }
        uint8_t nc_al_br[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((nc_al_br)[0]), 12) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, n) !=0)) {
          return -1;
        }
        uint8_t nc_sz_end[4] = {93, 59, 32, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((nc_sz_end)[0]), 3) !=0)) {
          return -1;
        }
        int32_t ai_nc = 0;
        while ((ai_nc < n)) {
          uint8_t nc_asg_h[14] = {95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 91, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((nc_asg_h)[0]), 11) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ai_nc) !=0)) {
            return -1;
          }
          uint8_t nc_asg_m[6] = {93, 32, 61, 32, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((nc_asg_m)[0]), 4) !=0)) {
            return -1;
          }
          if ((!(ast_ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai_nc))) && (codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai_nc), ctx) !=0))) {
            return -1;
          }
          uint8_t nc_asg_t[4] = {59, 32, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((nc_asg_t)[0]), 2) !=0)) {
            return -1;
          }
          (void)((ai_nc = (ai_nc + 1)));
        }
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((codegen_emit_type(arena, out, ((e).resolved_type_ref), 0, 0, ctx) !=0)) {
          uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
          if ((codegen_emit_bytes_9(out, &((fallback)[0]), 7) !=0)) {
            return -1;
          }
        }
        uint8_t nc_slice_mid[36] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 108, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((nc_slice_mid)[0]), 33) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, ai_nc) !=0)) {
          return -1;
        }
        uint8_t nc_slice_end[8] = {32, 125, 59, 32, 125, 41, 0, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((nc_slice_end)[0]), 6) !=0)) {
          return -1;
        }
        return 0;
      } else {
        if ((codegen_append_byte(out, 40) !=0)) {
          return -1;
        }
        if ((ast_ref_is_null(elem_type_ref) || (codegen_emit_type(arena, out, elem_type_ref, 0, 0, ctx) !=0))) {
          uint8_t fallback[9] = {117, 105, 110, 116, 56, 95, 116, 0, 0};
          if ((codegen_emit_bytes_9(out, &((fallback)[0]), 7) !=0)) {
            return -1;
          }
        }
        uint8_t arr[5] = {91, 93, 41, 123, 0};
        if ((codegen_emit_bytes_5(out, &((arr)[0]), 4) !=0)) {
          return -1;
        }
      }
      int32_t ai = 0;
      while ((ai < n)) {
        if ((ai > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
        }
        if ((!(ast_ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai))) && (codegen_emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) !=0))) {
          return -1;
        }
        (void)((ai = (ai + 1)));
      }
      uint8_t close[4] = {32, 125, 0, 0};
      return codegen_emit_bytes_4(out, &((close)[0]), 2);
    }
    if ((((int32_t)(((e).kind))) ==50)) {
      return codegen_append_byte(out, 48);
    }
    return -1;
  }
}
int32_t codegen_callee_var_is_string_new(struct ast_Expr e) {
  if ((((int32_t)(((e).kind))) !=3)) {
    return 0;
  }
  if ((((e).var_name_len) ==10)) {
    uint8_t expect_sn[10] = {115, 116, 114, 105, 110, 95, 110, 101, 119, 0};
    int32_t i_sn = 0;
    while ((i_sn < 9)) {
      if (((((e).var_name))[i_sn] !=(expect_sn)[i_sn])) {
        return 0;
      }
      (void)((i_sn = (i_sn + 1)));
    }
    return 1;
  }
  if ((((e).var_name_len) ==22)) {
    uint8_t expect_ssn[22] = {115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 95, 110, 101, 119, 0, 0};
    int32_t i_ssn = 0;
    while ((i_ssn < 20)) {
      if (((((e).var_name))[i_ssn] !=(expect_ssn)[i_ssn])) {
        return 0;
      }
      (void)((i_ssn = (i_ssn + 1)));
    }
    return 1;
  }
  return 0;
}
int32_t codegen_emit_run_defers(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx) {
  {
    int32_t ndef = 0;
    while ((ndef < 256)) {
      if ((pipeline_block_defer_body_ref(arena, block_ref, ndef) <=0)) {
        break;
      }
      (void)((ndef = (ndef + 1)));
    }
    int32_t di = (ndef - 1);
    while ((di >=0)) {
      int32_t dbody = pipeline_block_defer_body_ref(arena, block_ref, di);
      if ((dbody > 0)) {
        if ((codegen_emit_block(arena, out, dbody, indent, ctx) !=0)) {
          return -1;
        }
      }
      (void)((di = (di - 1)));
    }
    return 0;
  }
}
int32_t codegen_current_func_returns_void(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  {
    if (((((ctx ==0) || (((ctx)->current_codegen_module) ==0)) || (((ctx)->current_codegen_arena) !=arena)) || (((ctx)->current_func_index) < 0))) {
      return 0;
    }
    struct ast_Module * mod = ((ctx)->current_codegen_module);
    if ((((ctx)->current_func_index) >=((mod)->num_funcs))) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(mod, ((ctx)->current_func_index))) ==16)) {
      return 1;
    }
    return 0;
  }
}
int32_t codegen_current_func_is_named_main(struct ast_PipelineDepCtx * ctx) {
  {
    if ((((ctx ==0) || (((ctx)->current_codegen_module) ==0)) || (((ctx)->current_func_index) < 0))) {
      return 0;
    }
    struct ast_Module * mod = ((ctx)->current_codegen_module);
    if ((((ctx)->current_func_index) >=((mod)->num_funcs))) {
      return 0;
    }
    int32_t nlen = pipeline_module_func_name_len_at(mod, ((ctx)->current_func_index));
    if ((nlen !=4)) {
      return 0;
    }
    uint8_t nm[128] = {};
    (void)(codegen_copy_func_name64_from_module(mod, ((ctx)->current_func_index), &((nm)[0])));
    if ((((((nm)[0] ==109) && ((nm)[1] ==97)) && ((nm)[2] ==105)) && ((nm)[3] ==110))) {
      return 1;
    }
    return 0;
  }
}
int32_t codegen_emit_return_stmt_with_context(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t indent, int32_t operand_ref, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void) {
  {
    if (((fn_ret_void ==0) && !(ast_ref_is_null(operand_ref)))) {
      struct ast_Expr mop = ast_ast_arena_expr_get(arena, operand_ref);
      if (((((int32_t)(((mop).kind))) ==43) && (codegen_match_has_return_arm(arena, operand_ref) !=0))) {
        return codegen_emit_match_as_stmt(arena, out, operand_ref, indent, ctx, fn_ret_void);
      }
    }
    if ((fn_ret_void !=0)) {
      if (!(ast_ref_is_null(operand_ref))) {
        if ((codegen_emit_indent(out, indent) !=0)) {
          return -1;
        }
        uint8_t v[9] = {40, 118, 111, 105, 100, 41, 40, 0, 0};
        if ((codegen_emit_bytes_9(out, &((v)[0]), 7) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, operand_ref, ctx) !=0)) {
          return -1;
        }
        uint8_t scv[4] = {41, 59, 10, 0};
        if ((codegen_emit_bytes_4(out, &((scv)[0]), 3) !=0)) {
          return -1;
        }
      }
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      if ((codegen_current_func_is_named_main(ctx) !=0)) {
        uint8_t ret0[12] = {114, 101, 116, 117, 114, 110, 32, 48, 59, 10, 0, 0};
        return codegen_emit_bytes_from_ptr(out, &((ret0)[0]), 10);
      }
      uint8_t retv[9] = {114, 101, 116, 117, 114, 110, 59, 10, 0};
      return codegen_emit_bytes_9(out, &((retv)[0]), 8);
    }
    if (!(ast_ref_is_null(operand_ref))) {
      if ((pipeline_expr_kind_ord_at(arena, operand_ref) ==42)) {
        if ((codegen_emit_indent(out, indent) !=0)) {
          return -1;
        }
        if ((codegen_emit_expr(arena, out, operand_ref, ctx) !=0)) {
          return -1;
        }
        uint8_t sc_panic[4] = {59, 10, 0, 0};
        return codegen_emit_bytes_4(out, &((sc_panic)[0]), 2);
      }
    }
    if (((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_func_index) >=0)) && (((ctx)->current_func_index) < ((((ctx)->current_codegen_module))->num_funcs)))) {
      int32_t rty = pipeline_module_func_return_type_at(((ctx)->current_codegen_module), ((ctx)->current_func_index));
      if (((!(ast_ref_is_null(rty)) && (pipeline_type_kind_ord_at(arena, rty) ==10)) && !(ast_ref_is_null(operand_ref)))) {
        int32_t arr_sz_r = pipeline_type_array_size_at(arena, rty);
        int32_t elem_r = pipeline_type_elem_ref_at(arena, rty);
        if (((arr_sz_r > 0) && (arr_sz_r <=512))) {
          if ((codegen_emit_indent(out, indent) !=0)) {
            return -1;
          }
          uint8_t ar_open[20] = {114, 101, 116, 117, 114, 110, 32, 40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ar_open)[0]), 17) !=0)) {
            return -1;
          }
          if ((ast_ref_is_null(elem_r) || (codegen_emit_type(arena, out, elem_r, 0, 0, ctx) !=0))) {
            uint8_t fb_ar[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((fb_ar)[0]), 7) !=0)) {
              return -1;
            }
          }
          uint8_t ar_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 91, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ar_nm)[0]), 12) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, ((int64_t)(arr_sz_r))) !=0)) {
            return -1;
          }
          uint8_t ar_sz_end[4] = {93, 59, 32, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ar_sz_end)[0]), 3) !=0)) {
            return -1;
          }
          int32_t op_k = pipeline_expr_kind_ord_at(arena, operand_ref);
          if ((op_k ==46)) {
            int32_t n_lit = pipeline_expr_array_lit_num_elems_at(arena, operand_ref);
            int32_t ai_r = 0;
            while ((ai_r < arr_sz_r)) {
              uint8_t ar_asg[14] = {95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 91, 0, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((ar_asg)[0]), 11) !=0)) {
                return -1;
              }
              if ((codegen_format_int(out, ((int64_t)(ai_r))) !=0)) {
                return -1;
              }
              uint8_t ar_eq[6] = {93, 32, 61, 32, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((ar_eq)[0]), 4) !=0)) {
                return -1;
              }
              if ((ai_r < n_lit)) {
                int32_t er_r = pipeline_expr_array_lit_elem_ref(arena, operand_ref, ai_r);
                if ((!(ast_ref_is_null(er_r)) && (codegen_emit_expr(arena, out, er_r, ctx) !=0))) {
                  return -1;
                } else {
                  if (ast_ref_is_null(er_r)) {
                    if ((codegen_append_byte(out, 48) !=0)) {
                      return -1;
                    }
                  }
                }
              } else {
                if ((codegen_append_byte(out, 48) !=0)) {
                  return -1;
                }
              }
              uint8_t ar_sc[4] = {59, 32, 0, 0};
              if ((codegen_emit_bytes_4(out, &((ar_sc)[0]), 2) !=0)) {
                return -1;
              }
              (void)((ai_r = (ai_r + 1)));
            }
          } else {
            if ((ast_ref_is_null(elem_r) || (codegen_emit_type(arena, out, elem_r, 0, 0, ctx) !=0))) {
              uint8_t fb_rp[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((fb_rp)[0]), 7) !=0)) {
                return -1;
              }
            }
            uint8_t rp_nm[16] = {32, 42, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 32, 61, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((rp_nm)[0]), 15) !=0)) {
              return -1;
            }
            if ((codegen_emit_expr(arena, out, operand_ref, ctx) !=0)) {
              return -1;
            }
            uint8_t rp_sc[4] = {59, 32, 0, 0};
            if ((codegen_emit_bytes_4(out, &((rp_sc)[0]), 2) !=0)) {
              return -1;
            }
            int32_t ai_c = 0;
            while ((ai_c < arr_sz_r)) {
              uint8_t cp_h[14] = {95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 91, 0, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((cp_h)[0]), 11) !=0)) {
                return -1;
              }
              if ((codegen_format_int(out, ((int64_t)(ai_c))) !=0)) {
                return -1;
              }
              uint8_t cp_m[16] = {93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 114, 112, 91, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((cp_m)[0]), 15) !=0)) {
                return -1;
              }
              if ((codegen_format_int(out, ((int64_t)(ai_c))) !=0)) {
                return -1;
              }
              uint8_t cp_e[4] = {93, 59, 32, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((cp_e)[0]), 3) !=0)) {
                return -1;
              }
              (void)((ai_c = (ai_c + 1)));
            }
          }
          uint8_t ar_end[20] = {95, 95, 120, 108, 97, 110, 103, 95, 97, 114, 59, 32, 125, 41, 59, 10, 0, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ar_end)[0]), 16) !=0)) {
            return -1;
          }
          return 0;
        }
      }
      if ((!(ast_ref_is_null(rty)) && (pipeline_type_kind_ord_at(arena, rty) ==8))) {
        int32_t use_struct_zero = 0;
        if (ast_ref_is_null(operand_ref)) {
          (void)((use_struct_zero = 1));
        } else {
          if ((pipeline_expr_kind_ord_at(arena, operand_ref) ==0)) {
            struct ast_Expr lit = ast_ast_arena_expr_get(arena, operand_ref);
            if ((((lit).int_val) ==0)) {
              (void)((use_struct_zero = 1));
            }
          }
        }
        if ((use_struct_zero !=0)) {
          if ((codegen_emit_indent(out, indent) !=0)) {
            return -1;
          }
          uint8_t ret_open[8] = {114, 101, 116, 117, 114, 110, 32, 40};
          if ((codegen_emit_bytes_from_ptr(out, &((ret_open)[0]), 8) !=0)) {
            return -1;
          }
          if ((codegen_emit_type(arena, out, rty, 0, 0, ctx) !=0)) {
            return -1;
          }
          uint8_t ret_close[8] = {41, 123, 48, 125, 59, 10, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ret_close)[0]), 6) !=0)) {
            return -1;
          }
          return 0;
        }
      }
      if ((((!(ast_ref_is_null(rty)) && (pipeline_type_kind_ord_at(arena, rty) ==11)) && !(ast_ref_is_null(operand_ref))) && (pipeline_expr_kind_ord_at(arena, operand_ref) ==3))) {
        int32_t body_br = pipeline_module_func_body_ref_at(((ctx)->current_codegen_module), ((ctx)->current_func_index));
        if ((!(ast_ref_is_null(body_br)) && (body_br > 0))) {
          struct ast_Expr op_e = ast_ast_arena_expr_get(arena, operand_ref);
          int32_t arr_sz = 0;
          int32_t elem_tr = 0;
          int32_t arr_init_dummy = 0;
          int32_t found_esc = 0;
          (void)((found_esc = pipeline_find_fixed_array_slice_escape(arena, body_br, &((((op_e).var_name))[0]), ((op_e).var_name_len), &(arr_sz), &(elem_tr), &(arr_init_dummy))));
          if (((((found_esc !=0) && (arr_sz > 0)) && (arr_sz <=1024)) && !(ast_ref_is_null(elem_tr)))) {
            if ((codegen_emit_indent(out, indent) !=0)) {
              return -1;
            }
            uint8_t open1[20] = {114, 101, 116, 117, 114, 110, 32, 40, 123, 32, 115, 116, 97, 116, 105, 99, 32, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((open1)[0]), 17) !=0)) {
              return -1;
            }
            if ((codegen_emit_type(arena, out, elem_tr, 0, 0, ctx) !=0)) {
              uint8_t fallback[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0};
              if ((codegen_emit_bytes_9(out, &((fallback)[0]), 7) !=0)) {
                return -1;
              }
            }
            uint8_t esc_br[16] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 91, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((esc_br)[0]), 13) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, arr_sz) !=0)) {
              return -1;
            }
            uint8_t mid1[48] = {93, 59, 32, 115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 61, 32, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((mid1)[0]), 34) !=0)) {
              return -1;
            }
            if ((codegen_emit_bytes_64(out, &((((op_e).var_name))[0]), ((op_e).var_name_len)) !=0)) {
              return -1;
            }
            uint8_t mid2a[48] = {46, 108, 101, 110, 103, 116, 104, 59, 32, 105, 102, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 62, 32, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((mid2a)[0]), 37) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, arr_sz) !=0)) {
              return -1;
            }
            uint8_t mid2b[32] = {41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 61, 32, 40, 115, 105, 122, 101, 95, 116, 41, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((mid2b)[0]), 26) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, arr_sz) !=0)) {
              return -1;
            }
            uint8_t mid2c[28] = {59, 32, 109, 101, 109, 99, 112, 121, 40, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 44, 32, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((mid2c)[0]), 22) !=0)) {
              return -1;
            }
            if ((codegen_emit_bytes_64(out, &((((op_e).var_name))[0]), ((op_e).var_name_len)) !=0)) {
              return -1;
            }
            uint8_t mid3[56] = {46, 100, 97, 116, 97, 44, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 42, 32, 115, 105, 122, 101, 111, 102, 40, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 91, 48, 93, 41, 41, 59, 32, 40, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((mid3)[0]), 49) !=0)) {
              return -1;
            }
            if ((codegen_emit_type(arena, out, rty, 0, 0, ctx) !=0)) {
              return -1;
            }
            uint8_t end1[128] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 101, 115, 99, 95, 110, 32, 125, 59, 32, 125, 41, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((end1)[0]), 55) !=0)) {
              return -1;
            }
            return 0;
          }
        }
        if ((codegen_field_access_base_is_pointer_param(arena, operand_ref, ((ctx)->current_codegen_module), ((ctx)->current_func_index)) !=0)) {
          struct ast_Expr op_e2 = ast_ast_arena_expr_get(arena, operand_ref);
          if ((((op_e2).var_name_len) > 0)) {
            if ((codegen_emit_indent(out, indent) !=0)) {
              return -1;
            }
            uint8_t ret_star[12] = {114, 101, 116, 117, 114, 110, 32, 42, 0, 0, 0, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((ret_star)[0]), 8) !=0)) {
              return -1;
            }
            if ((codegen_emit_bytes_64(out, &((((op_e2).var_name))[0]), ((op_e2).var_name_len)) !=0)) {
              return -1;
            }
            uint8_t sc_star[4] = {59, 10, 0, 0};
            return codegen_emit_bytes_4(out, &((sc_star)[0]), 2);
          }
        }
      }
    }
    if ((codegen_emit_indent(out, indent) !=0)) {
      return -1;
    }
    uint8_t ret[8] = {114, 101, 116, 117, 114, 110, 32, 0};
    if ((codegen_emit_bytes_8(out, &((ret)[0]), 7) !=0)) {
      return -1;
    }
    if ((!(ast_ref_is_null(operand_ref)) && (codegen_emit_expr(arena, out, operand_ref, ctx) !=0))) {
      return -1;
    }
    uint8_t sc[4] = {59, 10, 0, 0};
    return codegen_emit_bytes_4(out, &((sc)[0]), 2);
  }
}
int32_t codegen_emit_block_final_expr(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t final_ref, int32_t indent, struct ast_PipelineDepCtx * ctx, int32_t fn_ret_void) {
  {
    if (ast_ref_is_null(final_ref)) {
      return 0;
    }
    struct ast_Expr fe = ast_ast_arena_expr_get(arena, final_ref);
    if ((((int32_t)(((fe).kind))) ==39)) {
      return codegen_emit_break_stmt(out, indent);
    }
    if ((((int32_t)(((fe).kind))) ==40)) {
      return codegen_emit_continue_stmt(out, indent);
    }
    if ((((int32_t)(((fe).kind))) ==41)) {
      return codegen_emit_return_stmt_with_context(arena, out, indent, ((fe).unary_operand_ref), ctx, fn_ret_void);
    }
    if (((((int32_t)(((fe).kind))) ==43) && (codegen_match_has_return_arm(arena, final_ref) !=0))) {
      return codegen_emit_match_as_stmt(arena, out, final_ref, indent, ctx, fn_ret_void);
    }
    int32_t parent_br = 0;
    if (((block_ref > 0) && (block_ref <=((arena)->num_blocks)))) {
      struct ast_Block blk = ast_ast_arena_block_get(arena, block_ref);
      (void)((parent_br = ((blk).parent_block_ref)));
    }
    int32_t is_func_body = 0;
    if ((((ctx !=0) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_func_index) >=0))) {
      int32_t fbody = pipeline_module_func_body_ref_at(((ctx)->current_codegen_module), ((ctx)->current_func_index));
      if ((!(ast_ref_is_null(fbody)) && (fbody ==block_ref))) {
        (void)((is_func_body = 1));
      }
    }
    if (((parent_br > 0) || (is_func_body ==0))) {
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, final_ref, ctx) !=0)) {
        return -1;
      }
      uint8_t end[4] = {59, 10, 0, 0};
      return codegen_emit_bytes_from_ptr(out, &((end)[0]), 2);
    }
    return codegen_emit_return_stmt_with_context(arena, out, indent, final_ref, ctx, fn_ret_void);
  }
}
int32_t codegen_emit_block(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, int32_t block_ref, int32_t indent, struct ast_PipelineDepCtx * ctx) {
  {
    uint8_t blk_prefix[128] = {};
    int32_t blk_prefix_len = codegen_emit_prefix_len_from_ctx(ctx, &((blk_prefix)[0]), 128);
    int32_t fn_ret_void = codegen_current_func_returns_void(arena, ctx);
    if (ast_ref_is_null(block_ref)) {
      return 0;
    }
    if (((block_ref <=0) || (block_ref > ((arena)->num_blocks)))) {
      return 0;
    }
    if ((ast_ast_block_num_stmt_order(arena, block_ref) > 0)) {
      int32_t pre_li = 0;
      while ((pre_li < ast_ast_block_num_lets(arena, block_ref))) {
        if ((codegen_block_stmt_order_has_let(arena, block_ref, pre_li) ==0)) {
          uint8_t lname_pre[128] = {};
          (void)(pipeline_block_let_name_copy64(arena, block_ref, pre_li, &((lname_pre)[0])));
          int32_t lname_len_pre = pipeline_block_let_name_len(arena, block_ref, pre_li);
          int32_t let_type_pre = pipeline_block_let_type_ref(arena, block_ref, pre_li);
          int32_t linit_pre = pipeline_block_let_init_ref(arena, block_ref, pre_li);
          if ((codegen_emit_indent(out, indent) !=0)) {
            return -1;
          }
          int32_t type_emitted_pre = 0;
          int32_t use_local_array_pre = 0;
          if ((!(ast_ref_is_null(let_type_pre)) && (pipeline_type_kind_ord_at(arena, let_type_pre) ==10))) {
            (void)((use_local_array_pre = 1));
          }
          if ((use_local_array_pre !=0)) {
            if ((codegen_emit_local_fixed_array_elem_type(arena, out, let_type_pre, ctx) !=0)) {
              return -1;
            }
            (void)((type_emitted_pre = 1));
          }
          if ((type_emitted_pre ==0)) {
            if ((codegen_emit_type(arena, out, let_type_pre, 0, 0, ctx) !=0)) {
              return -1;
            }
          }
          if ((codegen_append_byte(out, 32) !=0)) {
            return -1;
          }
          uint8_t emit_nm_pre[128] = {};
          int32_t emit_nml_pre = 0;
          if (((lname_len_pre > 0) && ((lname_pre)[0] > 32))) {
            int32_t ci = 0;
            while (((ci < lname_len_pre) && (ci < 128))) {
              (void)(((emit_nm_pre)[ci] = (lname_pre)[ci]));
              (void)((ci = (ci + 1)));
            }
            (void)((emit_nml_pre = lname_len_pre));
          } else {
            (void)(((emit_nm_pre)[0] = 95));
            (void)(((emit_nm_pre)[1] = 108));
            (void)((emit_nml_pre = 2));
            int32_t v = pre_li;
            uint8_t digs[12] = {};
            int32_t nd = 0;
            if ((v ==0)) {
              (void)(((digs)[0] = 48));
              (void)((nd = 1));
            } else {
              int32_t tmp = v;
              while (((tmp > 0) && (nd < 12))) {
                (void)(((digs)[nd] = ((uint8_t)(((tmp % 10) + 48)))));
                (void)((tmp = (tmp / 10)));
                (void)((nd = (nd + 1)));
              }
              int32_t a = 0;
              int32_t b = (nd - 1);
              while ((a < b)) {
                uint8_t sw = (digs)[a];
                (void)(((digs)[a] = (digs)[b]));
                (void)(((digs)[b] = sw));
                (void)((a = (a + 1)));
                (void)((b = (b - 1)));
              }
            }
            int32_t pi = 0;
            while (((pi < nd) && (emit_nml_pre < 128))) {
              (void)(((emit_nm_pre)[emit_nml_pre] = (digs)[pi]));
              (void)((emit_nml_pre = (emit_nml_pre + 1)));
              (void)((pi = (pi + 1)));
            }
          }
          if ((codegen_emit_bytes_64(out, &((emit_nm_pre)[0]), emit_nml_pre) !=0)) {
            return -1;
          }
          if ((use_local_array_pre !=0)) {
            if ((codegen_emit_local_fixed_array_suffix(arena, out, let_type_pre) !=0)) {
              return -1;
            }
          }
          if ((use_local_array_pre !=0)) {
            if ((codegen_emit_local_fixed_array_let_finish(arena, out, indent, &((emit_nm_pre)[0]), emit_nml_pre, linit_pre, ctx) !=0)) {
              return -1;
            }
          } else {
            uint8_t eq_pre[4] = {32, 61, 32, 0};
            if ((codegen_emit_bytes_4(out, &((eq_pre)[0]), 3) !=0)) {
              return -1;
            }
            if ((codegen_emit_expr(arena, out, linit_pre, ctx) !=0)) {
              return -1;
            }
            uint8_t sc_pre[3] = {59, 10, 0};
            if ((codegen_emit_bytes_3(out, &((sc_pre)[0]), 2) !=0)) {
              return -1;
            }
          }
        }
        (void)((pre_li = (pre_li + 1)));
      }
      int32_t si = 0;
      while ((si < ast_ast_block_num_stmt_order(arena, block_ref))) {
        uint8_t k = ast_ast_block_stmt_order_kind(arena, block_ref, si);
        int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, si);
        if ((k ==0)) {
          if (((idx >=0) && (idx < ast_ast_block_num_consts(arena, block_ref)))) {
            uint8_t cname_buf[128] = {};
            (void)(pipeline_block_const_name_copy64(arena, block_ref, idx, &((cname_buf)[0])));
            int32_t cname_len = pipeline_block_const_name_len(arena, block_ref, idx);
            int32_t ctype_ref = pipeline_block_const_type_ref(arena, block_ref, idx);
            int32_t cinit_ref = pipeline_block_const_init_ref(arena, block_ref, idx);
            if ((codegen_emit_indent(out, indent) !=0)) {
              return -1;
            }
            if ((codegen_emit_type(arena, out, ctype_ref, 0, 0, ctx) !=0)) {
              return -1;
            }
            uint8_t sp[3] = {32, 0, 0};
            if ((codegen_emit_bytes_3(out, &((sp)[0]), 1) !=0)) {
              return -1;
            }
            if (((cname_len > 0) && ((cname_buf)[0] > 32))) {
              if ((codegen_emit_bytes_64(out, &((cname_buf)[0]), cname_len) !=0)) {
                return -1;
              }
            } else {
              uint8_t place[4] = {95, 99, 48, 0};
              if ((codegen_emit_bytes_4(out, &((place)[0]), 2) !=0)) {
                return -1;
              }
              if ((codegen_format_int(out, idx) !=0)) {
                return -1;
              }
            }
            uint8_t eq[4] = {32, 61, 32, 0};
            if ((codegen_emit_bytes_4(out, &((eq)[0]), 3) !=0)) {
              return -1;
            }
            if ((codegen_emit_expr(arena, out, cinit_ref, ctx) !=0)) {
              return -1;
            }
            uint8_t sc[3] = {59, 10, 0};
            if ((codegen_emit_bytes_3(out, &((sc)[0]), 2) !=0)) {
              return -1;
            }
          }
        } else {
          if ((k ==1)) {
            if (((idx >=0) && (idx < ast_ast_block_num_lets(arena, block_ref)))) {
              uint8_t lname_buf[128] = {};
              (void)(pipeline_block_let_name_copy64(arena, block_ref, idx, &((lname_buf)[0])));
              int32_t lname_len = pipeline_block_let_name_len(arena, block_ref, idx);
              int32_t let_type_ref = pipeline_block_let_type_ref(arena, block_ref, idx);
              int32_t linit_ref = pipeline_block_let_init_ref(arena, block_ref, idx);
              if ((codegen_emit_indent(out, indent) !=0)) {
                return -1;
              }
              int32_t type_emitted = 0;
              int32_t use_local_array = 0;
              int32_t use = 0;
              if ((!(ast_ref_is_null(let_type_ref)) && (pipeline_type_kind_ord_at(arena, let_type_ref) ==10))) {
                (void)((use_local_array = 1));
              }
              if ((((use_local_array ==0) && !(ast_ref_is_null(let_type_ref))) && (codegen_type_is(arena, let_type_ref) !=0))) {
                (void)((use = 1));
              }
              if ((use_local_array !=0)) {
                if ((codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) !=0)) {
                  return -1;
                }
                (void)((type_emitted = 1));
              }
              if (((!(ast_ref_is_null(linit_ref)) && (linit_ref > 0)) && (linit_ref <=((arena)->num_exprs)))) {
                struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_ref);
                if ((((type_emitted ==0) && (((int32_t)(((init_e).kind))) ==46)) && (codegen_type_array_elem_is_u8(arena, let_type_ref) !=0))) {
                  uint8_t u8ptr[9] = {117, 105, 110, 116, 56, 95, 116, 32, 0};
                  if ((codegen_emit_bytes_9(out, &((u8ptr)[0]), 7) !=0)) {
                    return -1;
                  }
                  if ((codegen_append_byte(out, 42) !=0)) {
                    return -1;
                  }
                  (void)((type_emitted = 1));
                }
                if (((((type_emitted ==0) && !(ast_ref_is_null(((init_e).resolved_type_ref)))) && (((init_e).resolved_type_ref) > 0)) && (((init_e).resolved_type_ref) <=((arena)->num_types)))) {
                  struct ast_Type rt = ast_ast_arena_type_get(arena, ((init_e).resolved_type_ref));
                  if (((((int32_t)(((rt).kind))) ==8) && (((rt).name_len) >=6))) {
                    int32_t n0 = (((rt).name_len) - 6);
                    if ((((((((((rt).name))[n0] ==83) && ((((rt).name))[(n0 + 1)] ==116)) && ((((rt).name))[(n0 + 2)] ==114)) && ((((rt).name))[(n0 + 3)] ==105)) && ((((rt).name))[(n0 + 4)] ==110)) && ((((rt).name))[(n0 + 5)] ==103))) {
                      uint8_t str_ty[7] = {83, 116, 114, 105, 110, 103, 0};
                      if ((codegen_emit_bytes_from_ptr(out, &((str_ty)[0]), 6) !=0)) {
                        return -1;
                      }
                      if ((codegen_append_byte(out, 32) !=0)) {
                        return -1;
                      }
                      (void)((type_emitted = 1));
                    }
                  }
                }
                if ((((((type_emitted ==0) && (((int32_t)(((init_e).kind))) ==48)) && !(ast_ref_is_null(((init_e).call_callee_ref)))) && (((init_e).call_callee_ref) > 0)) && (((init_e).call_callee_ref) <=((arena)->num_exprs)))) {
                  struct ast_Expr callee_let = ast_ast_arena_expr_get(arena, ((init_e).call_callee_ref));
                  if ((((int32_t)(((callee_let).kind))) ==3)) {
                    if ((codegen_callee_var_is_string_new(callee_let) !=0)) {
                      uint8_t str_ty[7] = {83, 116, 114, 105, 110, 103, 0};
                      if ((codegen_emit_bytes_from_ptr(out, &((str_ty)[0]), 6) !=0)) {
                        return -1;
                      }
                      if ((codegen_append_byte(out, 32) !=0)) {
                        return -1;
                      }
                      (void)((type_emitted = 1));
                    }
                  }
                }
              }
              uint8_t emit_nm[128] = {};
              int32_t emit_nml = 0;
              if (((lname_len > 0) && ((lname_buf)[0] > 32))) {
                int32_t ci2 = 0;
                while (((ci2 < lname_len) && (ci2 < 128))) {
                  (void)(((emit_nm)[ci2] = (lname_buf)[ci2]));
                  (void)((ci2 = (ci2 + 1)));
                }
                (void)((emit_nml = lname_len));
              } else {
                (void)(((emit_nm)[0] = 95));
                (void)(((emit_nm)[1] = 108));
                (void)((emit_nml = 2));
                int32_t v2 = idx;
                uint8_t digs2[12] = {};
                int32_t nd2 = 0;
                if ((v2 ==0)) {
                  (void)(((digs2)[0] = 48));
                  (void)((nd2 = 1));
                } else {
                  int32_t tmp2 = v2;
                  while (((tmp2 > 0) && (nd2 < 12))) {
                    (void)(((digs2)[nd2] = ((uint8_t)(((tmp2 % 10) + 48)))));
                    (void)((tmp2 = (tmp2 / 10)));
                    (void)((nd2 = (nd2 + 1)));
                  }
                  int32_t a2 = 0;
                  int32_t b2 = (nd2 - 1);
                  while ((a2 < b2)) {
                    uint8_t sw2 = (digs2)[a2];
                    (void)(((digs2)[a2] = (digs2)[b2]));
                    (void)(((digs2)[b2] = sw2));
                    (void)((a2 = (a2 + 1)));
                    (void)((b2 = (b2 - 1)));
                  }
                }
                int32_t pi2 = 0;
                while (((pi2 < nd2) && (emit_nml < 128))) {
                  (void)(((emit_nm)[emit_nml] = (digs2)[pi2]));
                  (void)((emit_nml = (emit_nml + 1)));
                  (void)((pi2 = (pi2 + 1)));
                }
              }
              if (((use !=0) && (type_emitted ==0))) {
                if ((codegen_emit_c(arena, out, let_type_ref, &((emit_nm)[0]), emit_nml, ctx) !=0)) {
                  return -1;
                }
                (void)((type_emitted = 1));
              } else {
                if ((type_emitted ==0)) {
                  if ((((ast_ref_is_null(let_type_ref) && !(ast_ref_is_null(linit_ref))) && (linit_ref > 0)) && (linit_ref <=((arena)->num_exprs)))) {
                    struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_ref);
                    if (!(ast_ref_is_null(((init_e).resolved_type_ref)))) {
                      (void)((let_type_ref = ((init_e).resolved_type_ref)));
                    }
                  }
                  if ((codegen_emit_type(arena, out, let_type_ref, 0, 0, ctx) !=0)) {
                    return -1;
                  }
                }
              }
              if ((use ==0)) {
                if ((codegen_append_byte(out, 32) !=0)) {
                  return -1;
                }
                if ((codegen_emit_bytes_64(out, &((emit_nm)[0]), emit_nml) !=0)) {
                  return -1;
                }
              }
              if ((use_local_array !=0)) {
                if ((codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) !=0)) {
                  return -1;
                }
              }
              if ((use_local_array !=0)) {
                if ((codegen_emit_local_fixed_array_let_finish(arena, out, indent, &((emit_nm)[0]), emit_nml, linit_ref, ctx) !=0)) {
                  return -1;
                }
              } else {
                if ((((!(ast_ref_is_null(let_type_ref)) && (pipeline_type_kind_ord_at(arena, let_type_ref) ==11)) && !(ast_ref_is_null(linit_ref))) && ((pipeline_expr_kind_ord_at(arena, linit_ref) ==48) || (pipeline_expr_kind_ord_at(arena, linit_ref) ==49)))) {
                  if ((codegen_emit_slice_let_reent_finish(arena, out, indent, &((emit_nm)[0]), emit_nml, let_type_ref, linit_ref, ctx) !=0)) {
                    return -1;
                  }
                } else {
                  uint8_t eq[4] = {32, 61, 32, 0};
                  if ((codegen_emit_bytes_4(out, &((eq)[0]), 3) !=0)) {
                    return -1;
                  }
                  int32_t slice_init = 0;
                  if (!(ast_ref_is_null(linit_ref))) {
                    (void)((slice_init = codegen_try_emit_slice_init_from_array_var(arena, out, block_ref, idx, let_type_ref, linit_ref)));
                  }
                  if (ast_ref_is_null(linit_ref)) {
                    uint8_t zinit_omit2[6] = {123, 32, 48, 32, 125, 0};
                    if ((codegen_emit_bytes_6(out, &((zinit_omit2)[0]), 5) !=0)) {
                      return -1;
                    }
                  } else {
                    if ((slice_init ==1)) {
                    } else {
                      if ((slice_init < 0)) {
                        return -1;
                      } else {
                        int32_t use_vec_z = 0;
                        int32_t use_vec_braced = 0;
                        if ((((!(ast_ref_is_null(linit_ref)) && (linit_ref > 0)) && (linit_ref <=((arena)->num_exprs))) && !(ast_ref_is_null(let_type_ref)))) {
                          struct ast_Expr init_ez = ast_ast_arena_expr_get(arena, linit_ref);
                          int32_t tk_z = pipeline_type_kind_ord_at(arena, let_type_ref);
                          int32_t is_vec_ty = 0;
                          if ((tk_z ==13)) {
                            (void)((is_vec_ty = 1));
                          } else {
                            if ((tk_z ==8)) {
                              uint8_t vzn[128] = {};
                              int32_t vzn_l = pipeline_type_named_name_into(arena, let_type_ref, &((vzn)[0]));
                              int32_t vi = 0;
                              while ((vi < vzn_l)) {
                                if (((vzn)[vi] ==120)) {
                                  (void)((is_vec_ty = 1));
                                  (void)((vi = vzn_l));
                                } else {
                                  (void)((vi = (vi + 1)));
                                }
                              }
                            }
                          }
                          if ((is_vec_ty !=0)) {
                            if (((((int32_t)(((init_ez).kind))) ==0) && (((init_ez).int_val) ==0))) {
                              (void)((use_vec_z = 1));
                            } else {
                              if ((((int32_t)(((init_ez).kind))) ==46)) {
                                (void)((use_vec_braced = 1));
                              }
                            }
                          }
                        }
                        if ((use_vec_z !=0)) {
                          uint8_t vz[6] = {123, 32, 48, 32, 125, 0};
                          if ((codegen_emit_bytes_6(out, &((vz)[0]), 5) !=0)) {
                            return -1;
                          }
                        } else {
                          if ((use_vec_braced !=0)) {
                            if ((codegen_emit_braced_array_lit_init(arena, out, linit_ref, ctx) !=0)) {
                              return -1;
                            }
                          } else {
                            if ((codegen_emit_expr(arena, out, linit_ref, ctx) !=0)) {
                              return -1;
                            }
                          }
                        }
                      }
                    }
                  }
                  uint8_t sc[3] = {59, 10, 0};
                  if ((codegen_emit_bytes_3(out, &((sc)[0]), 2) !=0)) {
                    return -1;
                  }
                }
              }
            }
          } else {
            if ((k ==2)) {
              if (((idx >=0) && (idx < ast_ast_block_num_expr_stmts(arena, block_ref)))) {
                int32_t ex_ref = ast_ast_block_expr_stmt_ref(arena, block_ref, idx);
                struct ast_Expr st = ast_ast_arena_expr_get(arena, ex_ref);
                if ((((int32_t)(((st).kind))) ==41)) {
                  if ((codegen_emit_return_stmt_with_context(arena, out, indent, ((st).unary_operand_ref), ctx, fn_ret_void) !=0)) {
                    return -1;
                  }
                } else {
                  if ((((int32_t)(((st).kind))) ==39)) {
                    if ((codegen_emit_break_stmt(out, indent) !=0)) {
                      return -1;
                    }
                  } else {
                    if ((((int32_t)(((st).kind))) ==40)) {
                      if ((codegen_emit_continue_stmt(out, indent) !=0)) {
                        return -1;
                      }
                    } else {
                      if (((((int32_t)(((st).kind))) ==43) && (codegen_match_has_return_arm(arena, ex_ref) !=0))) {
                        if ((codegen_emit_match_as_stmt(arena, out, ex_ref, indent, ctx, fn_ret_void) !=0)) {
                          return -1;
                        }
                      } else {
                        if ((codegen_emit_indent(out, indent) !=0)) {
                          return -1;
                        }
                        uint8_t v[9] = {40, 118, 111, 105, 100, 41, 40, 0, 0};
                        if ((codegen_emit_bytes_9(out, &((v)[0]), 7) !=0)) {
                          return -1;
                        }
                        if ((codegen_emit_expr(arena, out, ex_ref, ctx) !=0)) {
                          return -1;
                        }
                        uint8_t sc[4] = {41, 59, 10, 0};
                        if ((codegen_emit_bytes_4(out, &((sc)[0]), 3) !=0)) {
                          return -1;
                        }
                      }
                    }
                  }
                }
              }
            } else {
              if ((k ==3)) {
                if (((idx >=0) && (idx < ast_ast_block_num_loops(arena, block_ref)))) {
                  int32_t w_cr = ast_ast_block_while_cond_ref(arena, block_ref, idx);
                  int32_t w_br = ast_ast_block_while_body_ref(arena, block_ref, idx);
                  if ((codegen_emit_indent(out, indent) !=0)) {
                    return -1;
                  }
                  uint8_t wh[8] = {119, 104, 105, 108, 101, 32, 40, 0};
                  if ((codegen_emit_bytes_8(out, &((wh)[0]), 7) !=0)) {
                    return -1;
                  }
                  if ((codegen_emit_expr(arena, out, w_cr, ctx) !=0)) {
                    return -1;
                  }
                  uint8_t paren[5] = {41, 32, 123, 10, 0};
                  if ((codegen_emit_bytes_5(out, &((paren)[0]), 4) !=0)) {
                    return -1;
                  }
                  if ((codegen_emit_block(arena, out, w_br, (indent + 2), ctx) !=0)) {
                    return -1;
                  }
                  if ((codegen_emit_indent(out, indent) !=0)) {
                    return -1;
                  }
                  uint8_t close[3] = {125, 10, 0};
                  if ((codegen_emit_bytes_3(out, &((close)[0]), 2) !=0)) {
                    return -1;
                  }
                }
              } else {
                if ((k ==4)) {
                  if (((idx >=0) && (idx < ast_ast_block_num_for_loops(arena, block_ref)))) {
                    int32_t fl_ir = ast_ast_block_for_init_ref(arena, block_ref, idx);
                    int32_t fl_cr = ast_ast_block_for_cond_ref(arena, block_ref, idx);
                    int32_t fl_sr = ast_ast_block_for_step_ref(arena, block_ref, idx);
                    int32_t fl_br = ast_ast_block_for_body_ref(arena, block_ref, idx);
                    if ((codegen_emit_indent(out, indent) !=0)) {
                      return -1;
                    }
                    uint8_t fk[6] = {102, 111, 114, 32, 40, 0};
                    if ((codegen_emit_bytes_6(out, &((fk)[0]), 5) !=0)) {
                      return -1;
                    }
                    if (!(ast_ref_is_null(fl_ir))) {
                      if ((codegen_emit_expr(arena, out, fl_ir, ctx) !=0)) {
                        return -1;
                      }
                    }
                    uint8_t sc1[3] = {59, 32, 0};
                    if ((codegen_emit_bytes_3(out, &((sc1)[0]), 2) !=0)) {
                      return -1;
                    }
                    if (!(ast_ref_is_null(fl_cr))) {
                      if ((codegen_emit_expr(arena, out, fl_cr, ctx) !=0)) {
                        return -1;
                      }
                    }
                    uint8_t sc2[3] = {59, 32, 0};
                    if ((codegen_emit_bytes_3(out, &((sc2)[0]), 2) !=0)) {
                      return -1;
                    }
                    if (!(ast_ref_is_null(fl_sr))) {
                      if ((codegen_emit_expr(arena, out, fl_sr, ctx) !=0)) {
                        return -1;
                      }
                    }
                    uint8_t paren[5] = {41, 32, 123, 10, 0};
                    if ((codegen_emit_bytes_5(out, &((paren)[0]), 4) !=0)) {
                      return -1;
                    }
                    if ((!(ast_ref_is_null(fl_br)) && (codegen_emit_block(arena, out, fl_br, (indent + 2), ctx) !=0))) {
                      return -1;
                    }
                    if ((codegen_emit_indent(out, indent) !=0)) {
                      return -1;
                    }
                    uint8_t close[3] = {125, 10, 0};
                    if ((codegen_emit_bytes_3(out, &((close)[0]), 2) !=0)) {
                      return -1;
                    }
                  }
                } else {
                  if ((k ==5)) {
                    if (((idx >=0) && (idx < ast_ast_block_num_if_stmts(arena, block_ref)))) {
                      int32_t if_cond_r = ast_ast_block_if_cond_ref(arena, block_ref, idx);
                      int32_t if_then_r = ast_ast_block_if_then_body_ref(arena, block_ref, idx);
                      int32_t if_else_r = ast_ast_block_if_else_body_ref(arena, block_ref, idx);
                      if ((codegen_emit_indent(out, indent) !=0)) {
                        return -1;
                      }
                      uint8_t ikw[5] = {105, 102, 32, 40, 0};
                      if ((codegen_emit_bytes_5(out, &((ikw)[0]), 4) !=0)) {
                        return -1;
                      }
                      if ((codegen_emit_expr(arena, out, if_cond_r, ctx) !=0)) {
                        return -1;
                      }
                      uint8_t paren_if[5] = {41, 32, 123, 10, 0};
                      if ((codegen_emit_bytes_5(out, &((paren_if)[0]), 4) !=0)) {
                        return -1;
                      }
                      if ((codegen_emit_block(arena, out, if_then_r, (indent + 2), ctx) !=0)) {
                        return -1;
                      }
                      if ((codegen_emit_indent(out, indent) !=0)) {
                        return -1;
                      }
                      if ((if_else_r !=0)) {
                        uint8_t else_brace[9] = {125, 32, 101, 108, 115, 101, 32, 123, 10};
                        if ((codegen_emit_bytes_9(out, &((else_brace)[0]), 9) !=0)) {
                          return -1;
                        }
                        if ((codegen_emit_block(arena, out, if_else_r, (indent + 2), ctx) !=0)) {
                          return -1;
                        }
                        if ((codegen_emit_indent(out, indent) !=0)) {
                          return -1;
                        }
                      }
                      uint8_t cif[3] = {125, 10, 0};
                      if ((codegen_emit_bytes_3(out, &((cif)[0]), 2) !=0)) {
                        return -1;
                      }
                    }
                  } else {
                    if ((k ==6)) {
                      if (((idx >=0) && (idx < ast_ast_block_num_regions(arena, block_ref)))) {
                        int32_t reg_body = ast_ast_block_region_body_ref(arena, block_ref, idx);
                        int32_t need_scope = 0;
                        if (((!(ast_ref_is_null(reg_body)) && (reg_body > 0)) && (reg_body <=((arena)->num_blocks)))) {
                          if (((ast_ast_block_num_lets(arena, reg_body) > 0) || (ast_ast_block_num_consts(arena, reg_body) > 0))) {
                            (void)((need_scope = 1));
                          }
                        }
                        if ((need_scope !=0)) {
                          if ((codegen_emit_indent(out, indent) !=0)) {
                            return -1;
                          }
                          uint8_t ob[2] = {123, 10};
                          if ((codegen_emit_bytes_2(out, &((ob)[0]), 2) !=0)) {
                            return -1;
                          }
                          if ((codegen_emit_block(arena, out, reg_body, (indent + 2), ctx) !=0)) {
                            return -1;
                          }
                          if ((codegen_emit_indent(out, indent) !=0)) {
                            return -1;
                          }
                          uint8_t cb[3] = {125, 10, 0};
                          if ((codegen_emit_bytes_3(out, &((cb)[0]), 2) !=0)) {
                            return -1;
                          }
                        } else {
                          if ((codegen_emit_block(arena, out, reg_body, indent, ctx) !=0)) {
                            return -1;
                          }
                        }
                      }
                    } else {
                      if ((k ==7)) {
                        if (((idx >=0) && (idx < pipeline_block_num_labeled_stmts(arena, block_ref)))) {
                          int32_t is_g = pipeline_block_labeled_is_goto(arena, block_ref, idx);
                          if ((is_g !=0)) {
                            if ((codegen_emit_indent(out, indent) !=0)) {
                              return -1;
                            }
                            uint8_t gkw[6] = {103, 111, 116, 111, 32, 0};
                            if ((codegen_emit_bytes_from_ptr(out, &((gkw)[0]), 5) !=0)) {
                              return -1;
                            }
                            uint8_t gt_buf[128] = {};
                            (void)(pipeline_block_labeled_goto_target_copy32(arena, block_ref, idx, &((gt_buf)[0])));
                            int32_t gt_len = pipeline_block_labeled_goto_target_len(arena, block_ref, idx);
                            if (((gt_len > 0) && (gt_len <=127))) {
                              if ((codegen_emit_bytes_from_ptr(out, &((gt_buf)[0]), gt_len) !=0)) {
                                return -1;
                              }
                            }
                            uint8_t gend[3] = {59, 10, 0};
                            if ((codegen_emit_bytes_from_ptr(out, &((gend)[0]), 2) !=0)) {
                              return -1;
                            }
                          } else {
                            uint8_t lb_buf[128] = {};
                            (void)(pipeline_block_labeled_label_copy32(arena, block_ref, idx, &((lb_buf)[0])));
                            int32_t lb_len = pipeline_block_labeled_label_len(arena, block_ref, idx);
                            if (((lb_len > 0) && (lb_len <=127))) {
                              if ((codegen_emit_indent(out, indent) !=0)) {
                                return -1;
                              }
                              if ((codegen_emit_bytes_from_ptr(out, &((lb_buf)[0]), lb_len) !=0)) {
                                return -1;
                              }
                              uint8_t colon_nl[3] = {58, 10, 0};
                              if ((codegen_emit_bytes_from_ptr(out, &((colon_nl)[0]), 2) !=0)) {
                                return -1;
                              }
                            }
                            int32_t ret_ref_lab = pipeline_block_labeled_return_expr_ref(arena, block_ref, idx);
                            if ((!(ast_ref_is_null(ret_ref_lab)) && (ret_ref_lab > 0))) {
                              if ((codegen_emit_return_stmt_with_context(arena, out, indent, ret_ref_lab, ctx, fn_ret_void) !=0)) {
                                return -1;
                              }
                            } else {
                              if (((ret_ref_lab ==0) && (lb_len > 0))) {
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        (void)((si = (si + 1)));
      }
      if ((codegen_emit_run_defers(arena, out, block_ref, indent, ctx) !=0)) {
        return -1;
      }
      int32_t final_ref = ast_ast_block_final_expr_ref(arena, block_ref);
      if ((codegen_emit_block_final_expr(arena, out, block_ref, final_ref, indent, ctx, fn_ret_void) !=0)) {
        return -1;
      }
      return 0;
    }
    int32_t i = 0;
    while ((i < ast_ast_block_num_consts(arena, block_ref))) {
      uint8_t cname_fb[128] = {};
      (void)(pipeline_block_const_name_copy64(arena, block_ref, i, &((cname_fb)[0])));
      int32_t cname_len_fb = pipeline_block_const_name_len(arena, block_ref, i);
      int32_t ctype_fb = pipeline_block_const_type_ref(arena, block_ref, i);
      int32_t cinit_fb = pipeline_block_const_init_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      if ((codegen_emit_type(arena, out, ctype_fb, &((blk_prefix)[0]), blk_prefix_len, ctx) !=0)) {
        return -1;
      }
      uint8_t sp[3] = {32, 0, 0};
      if ((codegen_emit_bytes_3(out, &((sp)[0]), 1) !=0)) {
        return -1;
      }
      if (((cname_len_fb > 0) && ((cname_fb)[0] > 32))) {
        if ((codegen_emit_bytes_64(out, &((cname_fb)[0]), cname_len_fb) !=0)) {
          return -1;
        }
      } else {
        uint8_t place[4] = {95, 99, 48, 0};
        if ((codegen_emit_bytes_4(out, &((place)[0]), 2) !=0)) {
          return -1;
        }
        if ((codegen_format_int(out, i) !=0)) {
          return -1;
        }
      }
      uint8_t eq[4] = {32, 61, 32, 0};
      if ((codegen_emit_bytes_4(out, &((eq)[0]), 3) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, cinit_fb, ctx) !=0)) {
        return -1;
      }
      uint8_t sc[3] = {59, 10, 0};
      if ((codegen_emit_bytes_3(out, &((sc)[0]), 2) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_lets(arena, block_ref))) {
      uint8_t lname_fb[128] = {};
      (void)(pipeline_block_let_name_copy64(arena, block_ref, i, &((lname_fb)[0])));
      int32_t lname_len_fb = pipeline_block_let_name_len(arena, block_ref, i);
      int32_t let_type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
      int32_t linit_fb = pipeline_block_let_init_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      int32_t type_emitted = 0;
      int32_t use_local_array = 0;
      if ((!(ast_ref_is_null(let_type_ref)) && (pipeline_type_kind_ord_at(arena, let_type_ref) ==10))) {
        (void)((use_local_array = 1));
      }
      if ((use_local_array !=0)) {
        if ((codegen_emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) !=0)) {
          return -1;
        }
        (void)((type_emitted = 1));
      }
      if (((!(ast_ref_is_null(linit_fb)) && (linit_fb > 0)) && (linit_fb <=((arena)->num_exprs)))) {
        struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_fb);
        if ((((type_emitted ==0) && (((int32_t)(((init_e).kind))) ==46)) && (codegen_type_array_elem_is_u8(arena, let_type_ref) !=0))) {
          uint8_t u8ptr[9] = {117, 105, 110, 116, 56, 95, 116, 32, 0};
          if ((codegen_emit_bytes_9(out, &((u8ptr)[0]), 7) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 42) !=0)) {
            return -1;
          }
          (void)((type_emitted = 1));
        }
        if (((((type_emitted ==0) && !(ast_ref_is_null(((init_e).resolved_type_ref)))) && (((init_e).resolved_type_ref) > 0)) && (((init_e).resolved_type_ref) <=((arena)->num_types)))) {
          struct ast_Type rt2 = ast_ast_arena_type_get(arena, ((init_e).resolved_type_ref));
          if (((((int32_t)(((rt2).kind))) ==8) && (((rt2).name_len) >=6))) {
            int32_t n02 = (((rt2).name_len) - 6);
            if ((((((((((rt2).name))[n02] ==83) && ((((rt2).name))[(n02 + 1)] ==116)) && ((((rt2).name))[(n02 + 2)] ==114)) && ((((rt2).name))[(n02 + 3)] ==105)) && ((((rt2).name))[(n02 + 4)] ==110)) && ((((rt2).name))[(n02 + 5)] ==103))) {
              uint8_t str_ty2a[7] = {83, 116, 114, 105, 110, 103, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((str_ty2a)[0]), 6) !=0)) {
                return -1;
              }
              if ((codegen_append_byte(out, 32) !=0)) {
                return -1;
              }
              (void)((type_emitted = 1));
            }
          }
        }
        if ((((((type_emitted ==0) && (((int32_t)(((init_e).kind))) ==48)) && !(ast_ref_is_null(((init_e).call_callee_ref)))) && (((init_e).call_callee_ref) > 0)) && (((init_e).call_callee_ref) <=((arena)->num_exprs)))) {
          struct ast_Expr callee_let2 = ast_ast_arena_expr_get(arena, ((init_e).call_callee_ref));
          if ((((int32_t)(((callee_let2).kind))) ==3)) {
            if ((codegen_callee_var_is_string_new(callee_let2) !=0)) {
              uint8_t str_ty2[7] = {83, 116, 114, 105, 110, 103, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((str_ty2)[0]), 6) !=0)) {
                return -1;
              }
              if ((codegen_append_byte(out, 32) !=0)) {
                return -1;
              }
              (void)((type_emitted = 1));
            }
          }
        }
      }
      if ((type_emitted ==0)) {
        if ((((ast_ref_is_null(let_type_ref) && !(ast_ref_is_null(linit_fb))) && (linit_fb > 0)) && (linit_fb <=((arena)->num_exprs)))) {
          struct ast_Expr init_e = ast_ast_arena_expr_get(arena, linit_fb);
          if (!(ast_ref_is_null(((init_e).resolved_type_ref)))) {
            (void)((let_type_ref = ((init_e).resolved_type_ref)));
          }
        }
        if ((codegen_emit_type(arena, out, let_type_ref, &((blk_prefix)[0]), blk_prefix_len, ctx) !=0)) {
          return -1;
        }
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        return -1;
      }
      uint8_t emit_nm_fb[128] = {};
      int32_t emit_nml_fb = 0;
      if (((lname_len_fb > 0) && ((lname_fb)[0] > 32))) {
        int32_t ci3 = 0;
        while (((ci3 < lname_len_fb) && (ci3 < 128))) {
          (void)(((emit_nm_fb)[ci3] = (lname_fb)[ci3]));
          (void)((ci3 = (ci3 + 1)));
        }
        (void)((emit_nml_fb = lname_len_fb));
      } else {
        (void)(((emit_nm_fb)[0] = 95));
        (void)(((emit_nm_fb)[1] = 108));
        (void)((emit_nml_fb = 2));
        int32_t v3 = i;
        uint8_t digs3[12] = {};
        int32_t nd3 = 0;
        if ((v3 ==0)) {
          (void)(((digs3)[0] = 48));
          (void)((nd3 = 1));
        } else {
          int32_t tmp3 = v3;
          while (((tmp3 > 0) && (nd3 < 12))) {
            (void)(((digs3)[nd3] = ((uint8_t)(((tmp3 % 10) + 48)))));
            (void)((tmp3 = (tmp3 / 10)));
            (void)((nd3 = (nd3 + 1)));
          }
          int32_t a3 = 0;
          int32_t b3 = (nd3 - 1);
          while ((a3 < b3)) {
            uint8_t sw3 = (digs3)[a3];
            (void)(((digs3)[a3] = (digs3)[b3]));
            (void)(((digs3)[b3] = sw3));
            (void)((a3 = (a3 + 1)));
            (void)((b3 = (b3 - 1)));
          }
        }
        int32_t pi3 = 0;
        while (((pi3 < nd3) && (emit_nml_fb < 128))) {
          (void)(((emit_nm_fb)[emit_nml_fb] = (digs3)[pi3]));
          (void)((emit_nml_fb = (emit_nml_fb + 1)));
          (void)((pi3 = (pi3 + 1)));
        }
      }
      if ((codegen_emit_bytes_64(out, &((emit_nm_fb)[0]), emit_nml_fb) !=0)) {
        return -1;
      }
      if ((use_local_array !=0)) {
        if ((codegen_emit_local_fixed_array_suffix(arena, out, let_type_ref) !=0)) {
          return -1;
        }
      }
      if ((use_local_array !=0)) {
        if ((codegen_emit_local_fixed_array_let_finish(arena, out, indent, &((emit_nm_fb)[0]), emit_nml_fb, linit_fb, ctx) !=0)) {
          return -1;
        }
      } else {
        uint8_t eq[4] = {32, 61, 32, 0};
        if ((codegen_emit_bytes_4(out, &((eq)[0]), 3) !=0)) {
          return -1;
        }
        if (ast_ref_is_null(linit_fb)) {
          uint8_t zinit_omit[6] = {123, 32, 48, 32, 125, 0};
          if ((codegen_emit_bytes_6(out, &((zinit_omit)[0]), 5) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_emit_expr(arena, out, linit_fb, ctx) !=0)) {
            return -1;
          }
        }
        uint8_t sc[3] = {59, 10, 0};
        if ((codegen_emit_bytes_3(out, &((sc)[0]), 2) !=0)) {
          return -1;
        }
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_expr_stmts(arena, block_ref))) {
      int32_t ex_fb = ast_ast_block_expr_stmt_ref(arena, block_ref, i);
      struct ast_Expr st = ast_ast_arena_expr_get(arena, ex_fb);
      if ((((int32_t)(((st).kind))) ==41)) {
        if ((codegen_emit_return_stmt_with_context(arena, out, indent, ((st).unary_operand_ref), ctx, fn_ret_void) !=0)) {
          return -1;
        }
      } else {
        if ((((int32_t)(((st).kind))) ==39)) {
          if ((codegen_emit_indent(out, indent) !=0)) {
            return -1;
          }
          uint8_t br[8] = {98, 114, 101, 97, 107, 59, 10, 0};
          if ((codegen_emit_bytes_8(out, &((br)[0]), 7) !=0)) {
            return -1;
          }
        } else {
          if ((((int32_t)(((st).kind))) ==40)) {
            if ((codegen_emit_indent(out, indent) !=0)) {
              return -1;
            }
            uint8_t co[11] = {99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((co)[0]), 10) !=0)) {
              return -1;
            }
          } else {
            if (((((int32_t)(((st).kind))) ==43) && (codegen_match_has_return_arm(arena, ex_fb) !=0))) {
              if ((codegen_emit_match_as_stmt(arena, out, ex_fb, indent, ctx, fn_ret_void) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_indent(out, indent) !=0)) {
                return -1;
              }
              uint8_t v[9] = {40, 118, 111, 105, 100, 41, 40, 0, 0};
              if ((codegen_emit_bytes_9(out, &((v)[0]), 7) !=0)) {
                return -1;
              }
              if ((codegen_emit_expr(arena, out, ex_fb, ctx) !=0)) {
                return -1;
              }
              uint8_t sc[4] = {41, 59, 10, 0};
              if ((codegen_emit_bytes_4(out, &((sc)[0]), 3) !=0)) {
                return -1;
              }
            }
          }
        }
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_loops(arena, block_ref))) {
      int32_t w_cr = ast_ast_block_while_cond_ref(arena, block_ref, i);
      int32_t w_br = ast_ast_block_while_body_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      uint8_t wh[8] = {119, 104, 105, 108, 101, 32, 40, 0};
      if ((codegen_emit_bytes_8(out, &((wh)[0]), 7) !=0)) {
        return -1;
      }
      if ((codegen_emit_expr(arena, out, w_cr, ctx) !=0)) {
        return -1;
      }
      uint8_t paren[5] = {41, 32, 123, 10, 0};
      if ((codegen_emit_bytes_5(out, &((paren)[0]), 4) !=0)) {
        return -1;
      }
      if ((codegen_emit_block(arena, out, w_br, (indent + 2), ctx) !=0)) {
        return -1;
      }
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      uint8_t close[3] = {125, 10, 0};
      if ((codegen_emit_bytes_3(out, &((close)[0]), 2) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < ast_ast_block_num_for_loops(arena, block_ref))) {
      int32_t fl_ir = ast_ast_block_for_init_ref(arena, block_ref, i);
      int32_t fl_cr = ast_ast_block_for_cond_ref(arena, block_ref, i);
      int32_t fl_sr = ast_ast_block_for_step_ref(arena, block_ref, i);
      int32_t fl_br = ast_ast_block_for_body_ref(arena, block_ref, i);
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      uint8_t fk[6] = {102, 111, 114, 32, 40, 0};
      if ((codegen_emit_bytes_6(out, &((fk)[0]), 5) !=0)) {
        return -1;
      }
      if (!(ast_ref_is_null(fl_ir))) {
        if ((codegen_emit_expr(arena, out, fl_ir, ctx) !=0)) {
          return -1;
        }
      }
      uint8_t sc1[3] = {59, 32, 0};
      if ((codegen_emit_bytes_3(out, &((sc1)[0]), 2) !=0)) {
        return -1;
      }
      if (!(ast_ref_is_null(fl_cr))) {
        if ((codegen_emit_expr(arena, out, fl_cr, ctx) !=0)) {
          return -1;
        }
      }
      uint8_t sc2[3] = {59, 32, 0};
      if ((codegen_emit_bytes_3(out, &((sc2)[0]), 2) !=0)) {
        return -1;
      }
      if (!(ast_ref_is_null(fl_sr))) {
        if ((codegen_emit_expr(arena, out, fl_sr, ctx) !=0)) {
          return -1;
        }
      }
      uint8_t paren[5] = {41, 32, 123, 10, 0};
      if ((codegen_emit_bytes_5(out, &((paren)[0]), 4) !=0)) {
        return -1;
      }
      if ((!(ast_ref_is_null(fl_br)) && (codegen_emit_block(arena, out, fl_br, (indent + 2), ctx) !=0))) {
        return -1;
      }
      if ((codegen_emit_indent(out, indent) !=0)) {
        return -1;
      }
      uint8_t close[3] = {125, 10, 0};
      if ((codegen_emit_bytes_3(out, &((close)[0]), 2) !=0)) {
        return -1;
      }
      (void)((i = (i + 1)));
    }
    if ((codegen_emit_run_defers(arena, out, block_ref, indent, ctx) !=0)) {
      return -1;
    }
    int32_t final_ref_plain = ast_ast_block_final_expr_ref(arena, block_ref);
    if ((codegen_emit_block_final_expr(arena, out, block_ref, final_ref_plain, indent, ctx, fn_ret_void) !=0)) {
      return -1;
    }
    return 0;
  }
}
int32_t codegen_emit_suffix_bytes(uint8_t * dst, uint8_t * src, int32_t len) {
  int32_t i = 0;
  while ((i < len)) {
    (void)(((dst)[i] = (src)[i]));
    (void)((i = (i + 1)));
  }
  return len;
}
int32_t codegen_type_ref_to_suffix(struct ast_ASTArena * arena, int32_t type_ref, uint8_t * buf, int32_t buf_cap) {
  {
    if ((((type_ref <=0) || (buf ==0)) || (buf_cap <=0))) {
      return 0;
    }
    int32_t tk = pipeline_type_kind_ord_at(arena, type_ref);
    if ((tk ==9)) {
      int32_t elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      int32_t n = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (((n > 0) && ((n + 4) < buf_cap))) {
        (void)(((buf)[n] = 95));
        (void)(((buf)[(n + 1)] = 112));
        (void)(((buf)[(n + 2)] = 116));
        (void)(((buf)[(n + 3)] = 114));
        return (n + 4);
      }
      return n;
    }
    if ((tk ==8)) {
      int32_t nl = pipeline_type_named_name_into(arena, type_ref, buf);
      int32_t si = 0;
      while (((si < nl) && (si < buf_cap))) {
        if (((buf)[si] ==46)) {
          (void)(((buf)[si] = 95));
        }
        (void)((si = (si + 1)));
      }
      if (((nl <=0) || (nl >=buf_cap))) {
        return 0;
      }
      int32_t pos = nl;
      int32_t ai = 0;
      while ((ai < 4)) {
        int32_t arg = pipeline_type_type_arg_ref_at(arena, type_ref, ai);
        if ((arg <=0)) {
          (void)((ai = 4));
        } else {
          uint8_t asuf[128] = {};
          int32_t al = codegen_type_ref_to_suffix(arena, arg, &((asuf)[0]), 64);
          if ((al <=0)) {
            (void)((ai = 4));
          } else {
            if ((((pos + 1) + al) >=buf_cap)) {
              (void)((ai = 4));
            } else {
              (void)(((buf)[pos] = 95));
              (void)((pos = (pos + 1)));
              int32_t aj = 0;
              while ((aj < al)) {
                (void)(((buf)[pos] = (asuf)[aj]));
                (void)((pos = (pos + 1)));
                (void)((aj = (aj + 1)));
              }
              (void)((ai = (ai + 1)));
            }
          }
        }
      }
      return pos;
    }
    if ((tk ==0)) {
      uint8_t s[4] = {105, 51, 50, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==5)) {
      uint8_t s[4] = {105, 54, 52, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==2)) {
      uint8_t s[3] = {117, 56, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 2);
    }
    if ((tk ==3)) {
      uint8_t s[4] = {117, 51, 50, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==4)) {
      uint8_t s[4] = {117, 54, 52, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==14)) {
      uint8_t s[4] = {102, 51, 50, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==15)) {
      uint8_t s[4] = {102, 54, 52, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 3);
    }
    if ((tk ==13)) {
      int32_t elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      int32_t lanes = pipeline_type_array_size_at(arena, type_ref);
      int32_t ek = 0;
      int32_t pos = 0;
      if (((elem_ref <=0) || (lanes <=0))) {
        return 0;
      }
      (void)((ek = pipeline_type_kind_ord_at(arena, elem_ref)));
      if ((ek ==0)) {
        uint8_t pre[4] = {105, 51, 50, 0};
        (void)((pos = codegen_emit_suffix_bytes(buf, &((pre)[0]), 3)));
      } else {
        if ((ek ==3)) {
          uint8_t pre[4] = {117, 51, 50, 0};
          (void)((pos = codegen_emit_suffix_bytes(buf, &((pre)[0]), 3)));
        } else {
          if ((ek ==14)) {
            uint8_t pre[4] = {102, 51, 50, 0};
            (void)((pos = codegen_emit_suffix_bytes(buf, &((pre)[0]), 3)));
          } else {
            return 0;
          }
        }
      }
      if ((pos <=0)) {
        return 0;
      }
      if ((pos < buf_cap)) {
        (void)(((buf)[pos] = 120));
        (void)((pos = (pos + 1)));
      } else {
        return pos;
      }
      if (((lanes ==4) && (pos < buf_cap))) {
        (void)(((buf)[pos] = 52));
        return (pos + 1);
      } else {
        if (((lanes ==8) && (pos < buf_cap))) {
          (void)(((buf)[pos] = 56));
          return (pos + 1);
        } else {
          if (((lanes ==16) && ((pos + 1) < buf_cap))) {
            (void)(((buf)[pos] = 49));
            (void)(((buf)[(pos + 1)] = 54));
            return (pos + 2);
          }
        }
      }
      return pos;
    }
    if ((tk ==1)) {
      uint8_t s[5] = {98, 111, 111, 108, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 4);
    }
    if ((tk ==6)) {
      uint8_t s[6] = {117, 115, 105, 122, 101, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 5);
    }
    if ((tk ==7)) {
      uint8_t s[6] = {105, 115, 105, 122, 101, 0};
      return codegen_emit_suffix_bytes(buf, &((s)[0]), 5);
    }
    if ((tk ==10)) {
      int32_t elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      int32_t asz = pipeline_type_array_size_at(arena, type_ref);
      int32_t n = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (((n <=0) || (asz <=0))) {
        return 0;
      }
      if (((n + 2) >=buf_cap)) {
        return 0;
      }
      (void)(((buf)[n] = 95));
      (void)(((buf)[(n + 1)] = 97));
      (void)((n = (n + 2)));
      uint8_t digs[8] = {};
      int32_t nd = 0;
      int32_t v = asz;
      while (((v > 0) && (nd < 6))) {
        (void)(((digs)[nd] = ((uint8_t)(((v % 10) + 48)))));
        (void)((nd = (nd + 1)));
        (void)((v = (v / 10)));
      }
      if ((nd <=0)) {
        return 0;
      }
      if (((n + nd) >=buf_cap)) {
        return 0;
      }
      int32_t di = (nd - 1);
      while ((di >=0)) {
        (void)(((buf)[n] = (digs)[di]));
        (void)((n = (n + 1)));
        (void)((di = (di - 1)));
      }
      return n;
    }
    if ((tk ==11)) {
      int32_t elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
      int32_t n = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
      if (((n > 0) && ((n + 4) < buf_cap))) {
        (void)(((buf)[n] = 95));
        (void)(((buf)[(n + 1)] = 115));
        (void)(((buf)[(n + 2)] = 108));
        (void)(((buf)[(n + 3)] = 99));
        return (n + 4);
      }
      return 0;
    }
    return 0;
  }
}
int32_t codegen_module_func_overload_count(struct ast_Module * module, uint8_t * name_ptr, int32_t name_len) {
  {
    int32_t c = 0;
    if ((((module ==0) || (name_ptr ==0)) || (name_len <=0))) {
      return 0;
    }
    int32_t i = 0;
    while ((i < ((module)->num_funcs))) {
      int32_t fn_len = pipeline_module_func_name_len_at(module, i);
      if (((fn_len ==name_len) && (fn_len > 0))) {
        uint8_t fn_name[128] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        (void)(pipeline_module_func_name_copy64(module, i, &((fn_name)[0])));
        while ((bi < fn_len)) {
          if (((fn_name)[bi] !=(name_ptr)[bi])) {
            (void)((matched = 0));
            (void)((bi = fn_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          (void)((c = (c + 1)));
        }
      }
      (void)((i = (i + 1)));
    }
    return c;
  }
}
int32_t codegen_func_param_sig_equal(struct ast_ASTArena * arena, struct ast_Module * mod_a, int32_t fi_a, struct ast_Module * mod_b, int32_t fi_b) {
  {
    int32_t np_a = pipeline_module_func_num_params_at(mod_a, fi_a);
    int32_t np_b = pipeline_module_func_num_params_at(mod_b, fi_b);
    if ((np_a !=np_b)) {
      return 0;
    }
    int32_t pi = 0;
    while ((pi < np_a)) {
      uint8_t sa[128] = {};
      uint8_t sb[128] = {};
      int32_t na = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_a, fi_a, pi), &((sa)[0]), 64);
      int32_t nb = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_b, fi_b, pi), &((sb)[0]), 64);
      if ((na !=nb)) {
        return 0;
      }
      int32_t k = 0;
      while ((k < na)) {
        if (((sa)[k] !=(sb)[k])) {
          return 0;
        }
        (void)((k = (k + 1)));
      }
      (void)((pi = (pi + 1)));
    }
    return 1;
  }
}
int32_t codegen_module_overload_param_sig_count(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi) {
  {
    int32_t c = 0;
    if ((((module ==0) || (fi < 0)) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    uint8_t fn_local[128] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    if ((fn_len <=0)) {
      return 0;
    }
    int32_t i = 0;
    while ((i < ((module)->num_funcs))) {
      int32_t g_len = pipeline_module_func_name_len_at(module, i);
      if (((g_len ==fn_len) && (g_len > 0))) {
        uint8_t g_name[128] = {};
        int32_t matched = 1;
        int32_t bi = 0;
        (void)(pipeline_module_func_name_copy64(module, i, &((g_name)[0])));
        while ((bi < g_len)) {
          if (((g_name)[bi] !=(fn_local)[bi])) {
            (void)((matched = 0));
            (void)((bi = g_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          if ((codegen_func_param_sig_equal(arena, module, fi, module, i) !=0)) {
            (void)((c = (c + 1)));
          }
        }
      }
      (void)((i = (i + 1)));
    }
    return c;
  }
}
int32_t codegen_func_c_symbol_prefix_len(struct ast_Module * module, int32_t fi, int32_t prefix_len) {
  if ((prefix_len <=0)) {
    return 0;
  }
  if ((((module !=0) && (fi >=0)) && (pipeline_module_func_is_no_mangle_at(module, fi) !=0))) {
    return 0;
  }
  return prefix_len;
}
/*
 * PLATFORM: SHARED — host-C keyword escape for function link stems.
 * Trait/impl free-fn hoist can emit methods named like C type-specifiers
 * (e.g. double) → BLD001 "two or more data types" without escape.
 * Single authority: only codegen_emit_func_link_name uses these helpers for
 * the base stem (def / call / extern / mono all share link_name).
 */
static int32_t codegen_c_ident_is_keyword(uint8_t * name, int32_t name_len) {
  if (((name ==0) || (name_len <=0))) {
    return 0;
  }
  if ((name_len ==2)) {
    if ((((name)[0] ==100) && ((name)[1] ==111))) { return 1; }
    if ((((name)[0] ==105) && ((name)[1] ==102))) { return 1; }
    return 0;
  }
  if ((name_len ==3)) {
    if (((((name)[0] ==102) && ((name)[1] ==111)) && ((name)[2] ==114))) { return 1; }
    if (((((name)[0] ==105) && ((name)[1] ==110)) && ((name)[2] ==116))) { return 1; }
    return 0;
  }
  if ((name_len ==4)) {
    if ((((((name)[0] ==99) && ((name)[1] ==97)) && ((name)[2] ==115)) && ((name)[3] ==101))) { return 1; }
    if ((((((name)[0] ==99) && ((name)[1] ==104)) && ((name)[2] ==97)) && ((name)[3] ==114))) { return 1; }
    if ((((((name)[0] ==101) && ((name)[1] ==108)) && ((name)[2] ==115)) && ((name)[3] ==101))) { return 1; }
    if ((((((name)[0] ==101) && ((name)[1] ==110)) && ((name)[2] ==117)) && ((name)[3] ==109))) { return 1; }
    if ((((((name)[0] ==103) && ((name)[1] ==111)) && ((name)[2] ==116)) && ((name)[3] ==111))) { return 1; }
    if ((((((name)[0] ==108) && ((name)[1] ==111)) && ((name)[2] ==110)) && ((name)[3] ==103))) { return 1; }
    if ((((((name)[0] ==118) && ((name)[1] ==111)) && ((name)[2] ==105)) && ((name)[3] ==100))) { return 1; }
    return 0;
  }
  if ((name_len ==5)) {
    if (((((((name)[0] ==98) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==97)) && ((name)[4] ==107))) { return 1; }
    if (((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==110)) && ((name)[3] ==115)) && ((name)[4] ==116))) { return 1; }
    if (((((((name)[0] ==102) && ((name)[1] ==108)) && ((name)[2] ==111)) && ((name)[3] ==97)) && ((name)[4] ==116))) { return 1; }
    if (((((((name)[0] ==115) && ((name)[1] ==104)) && ((name)[2] ==111)) && ((name)[3] ==114)) && ((name)[4] ==116))) { return 1; }
    if (((((((name)[0] ==117) && ((name)[1] ==110)) && ((name)[2] ==105)) && ((name)[3] ==111)) && ((name)[4] ==110))) { return 1; }
    if (((((((name)[0] ==119) && ((name)[1] ==104)) && ((name)[2] ==105)) && ((name)[3] ==108)) && ((name)[4] ==101))) { return 1; }
    return 0;
  }
  if ((name_len ==6)) {
    if ((((((((name)[0] ==100) && ((name)[1] ==111)) && ((name)[2] ==117)) && ((name)[3] ==98)) && ((name)[4] ==108)) && ((name)[5] ==101))) { return 1; }
    if ((((((((name)[0] ==101) && ((name)[1] ==120)) && ((name)[2] ==116)) && ((name)[3] ==101)) && ((name)[4] ==114)) && ((name)[5] ==110))) { return 1; }
    if ((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==116)) && ((name)[3] ==117)) && ((name)[4] ==114)) && ((name)[5] ==110))) { return 1; }
    if ((((((((name)[0] ==115) && ((name)[1] ==105)) && ((name)[2] ==103)) && ((name)[3] ==110)) && ((name)[4] ==101)) && ((name)[5] ==100))) { return 1; }
    if ((((((((name)[0] ==115) && ((name)[1] ==105)) && ((name)[2] ==122)) && ((name)[3] ==101)) && ((name)[4] ==111)) && ((name)[5] ==102))) { return 1; }
    if ((((((((name)[0] ==115) && ((name)[1] ==116)) && ((name)[2] ==97)) && ((name)[3] ==116)) && ((name)[4] ==105)) && ((name)[5] ==99))) { return 1; }
    if ((((((((name)[0] ==115) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==117)) && ((name)[4] ==99)) && ((name)[5] ==116))) { return 1; }
    if ((((((((name)[0] ==115) && ((name)[1] ==119)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==99)) && ((name)[5] ==104))) { return 1; }
    return 0;
  }
  if ((name_len ==7)) {
    if (((((((((name)[0] ==100) && ((name)[1] ==101)) && ((name)[2] ==102)) && ((name)[3] ==97)) && ((name)[4] ==117)) && ((name)[5] ==108)) && ((name)[6] ==116))) { return 1; }
    if (((((((((name)[0] ==116) && ((name)[1] ==121)) && ((name)[2] ==112)) && ((name)[3] ==101)) && ((name)[4] ==100)) && ((name)[5] ==101)) && ((name)[6] ==102))) { return 1; }
    return 0;
  }
  if ((name_len ==8)) {
    if ((((((((((name)[0] ==99) && ((name)[1] ==111)) && ((name)[2] ==110)) && ((name)[3] ==116)) && ((name)[4] ==105)) && ((name)[5] ==110)) && ((name)[6] ==117)) && ((name)[7] ==101))) { return 1; }
    if ((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==103)) && ((name)[3] ==105)) && ((name)[4] ==115)) && ((name)[5] ==116)) && ((name)[6] ==101)) && ((name)[7] ==114))) { return 1; }
    if ((((((((((name)[0] ==114) && ((name)[1] ==101)) && ((name)[2] ==115)) && ((name)[3] ==116)) && ((name)[4] ==114)) && ((name)[5] ==105)) && ((name)[6] ==99)) && ((name)[7] ==116))) { return 1; }
    if ((((((((((name)[0] ==117) && ((name)[1] ==110)) && ((name)[2] ==115)) && ((name)[3] ==105)) && ((name)[4] ==103)) && ((name)[5] ==110)) && ((name)[6] ==101)) && ((name)[7] ==100))) { return 1; }
    if ((((((((((name)[0] ==118) && ((name)[1] ==111)) && ((name)[2] ==108)) && ((name)[3] ==97)) && ((name)[4] ==116)) && ((name)[5] ==105)) && ((name)[6] ==108)) && ((name)[7] ==101))) { return 1; }
    return 0;
  }
  return 0;
}
static int32_t codegen_emit_c_func_base_name(struct codegen_CodegenOutBuf * out, uint8_t * name, int32_t name_len) {
  if (((((out ==0) || (name ==0)) || (name_len <=0)))) {
    return -1;
  }
  if ((codegen_c_ident_is_keyword(name, name_len) !=0)) {
    /* "xlang_" */
    uint8_t pfx[7] = {120, 108, 97, 110, 103, 95, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((pfx)[0]), 6) !=0)) {
      return -1;
    }
  }
  return codegen_emit_bytes_64(out, name, name_len);
}
int32_t codegen_emit_func_link_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi) {
  {
    uint8_t fn_local[128] = {};
    int32_t fn_len = 0;
    int32_t overload_count = 0;
    int32_t np = 0;
    int32_t pi = 0;
    int32_t sig_count = 0;
    if ((((module ==0) || (fi < 0)) || (fi >=((module)->num_funcs)))) {
      return -1;
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, fi)));
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    if ((fn_len <=0)) {
      return -1;
    }
    if ((pipeline_module_func_is_no_mangle_at(module, fi) !=0)) {
      return codegen_emit_c_func_base_name(out, &((fn_local)[0]), fn_len);
    }
    (void)((overload_count = codegen_module_func_overload_count(module, &((fn_local)[0]), fn_len)));
    if ((overload_count <=1)) {
      return codegen_emit_c_func_base_name(out, &((fn_local)[0]), fn_len);
    }
    if ((codegen_emit_c_func_base_name(out, &((fn_local)[0]), fn_len) !=0)) {
      return -1;
    }
    (void)((np = pipeline_module_func_num_params_at(module, fi)));
    (void)((pi = 0));
    while ((pi < np)) {
      uint8_t suf[128] = {};
      int32_t param_ty = pipeline_module_func_param_type_ref_at(module, fi, pi);
      int32_t sl = 0;
      if ((arena !=0)) {
        (void)((sl = codegen_type_ref_to_suffix(arena, param_ty, &((suf)[0]), 64)));
      }
      if ((sl > 0)) {
        if ((codegen_append_byte(out, 95) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((suf)[0]), sl) !=0)) {
          return -1;
        }
      }
      (void)((pi = (pi + 1)));
    }
    (void)((sig_count = codegen_module_overload_param_sig_count(arena, module, fi)));
    if ((sig_count > 1)) {
      int32_t ret_ref = pipeline_module_func_return_type_at(module, fi);
      uint8_t rs[128] = {};
      int32_t rsl = codegen_type_ref_to_suffix(arena, ret_ref, &((rs)[0]), 64);
      if ((rsl > 0)) {
        uint8_t ret_kw[5] = {95, 114, 101, 116, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 4) !=0)) {
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((rs)[0]), rsl) !=0)) {
          return -1;
        }
      }
    }
    return 0;
  }
}
int32_t codegen_name_is_local_binding(struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * name, int32_t name_len) {
  {
    if (((((arena ==0) || (ctx ==0)) || (name ==0)) || (name_len <=0))) {
      return 0;
    }
    struct ast_Module * mod = ((ctx)->current_codegen_module);
    if ((((mod !=0) && (((ctx)->current_func_index) >=0)) && (((ctx)->current_func_index) < ((mod)->num_funcs)))) {
      int32_t fi = ((ctx)->current_func_index);
      int32_t np = pipeline_module_func_num_params_at(mod, fi);
      int32_t pi = 0;
      while ((pi < np)) {
        int32_t pl = pipeline_module_func_param_name_len_at(mod, fi, pi);
        if (((pl ==name_len) && (pl > 0))) {
          uint8_t pb[128] = {};
          int32_t ok = 1;
          int32_t j = 0;
          (void)(pipeline_module_func_param_name_copy32(mod, fi, pi, &((pb)[0])));
          while ((j < pl)) {
            if (((pb)[j] !=(name)[j])) {
              (void)((ok = 0));
              (void)((j = pl));
            } else {
              (void)((j = (j + 1)));
            }
          }
          if ((ok !=0)) {
            return 1;
          }
        }
        (void)((pi = (pi + 1)));
      }
    }
    if (((((ctx)->current_block_ref) > 0) && (((ctx)->current_block_ref) <=((arena)->num_blocks)))) {
      int32_t br = ((ctx)->current_block_ref);
      int32_t li = 0;
      int32_t nlets = ast_ast_block_num_lets(arena, br);
      while ((li < nlets)) {
        int32_t nl = pipeline_block_let_name_len(arena, br, li);
        if (((nl ==name_len) && (nl > 0))) {
          uint8_t nb[128] = {};
          int32_t ok2 = 1;
          int32_t j2 = 0;
          (void)(pipeline_block_let_name_copy64(arena, br, li, &((nb)[0])));
          while ((j2 < nl)) {
            if (((nb)[j2] !=(name)[j2])) {
              (void)((ok2 = 0));
              (void)((j2 = nl));
            } else {
              (void)((j2 = (j2 + 1)));
            }
          }
          if ((ok2 !=0)) {
            return 1;
          }
        }
        (void)((li = (li + 1)));
      }
      int32_t ci = 0;
      int32_t nconsts = ast_ast_block_num_consts(arena, br);
      while ((ci < nconsts)) {
        int32_t cl = pipeline_block_const_name_len(arena, br, ci);
        if (((cl ==name_len) && (cl > 0))) {
          uint8_t cb[128] = {};
          int32_t ok3 = 1;
          int32_t j3 = 0;
          (void)(pipeline_block_const_name_copy64(arena, br, ci, &((cb)[0])));
          while ((j3 < cl)) {
            if (((cb)[j3] !=(name)[j3])) {
              (void)((ok3 = 0));
              (void)((j3 = cl));
            } else {
              (void)((j3 = (j3 + 1)));
            }
          }
          if ((ok3 !=0)) {
            return 1;
          }
        }
        (void)((ci = (ci + 1)));
      }
    }
    return 0;
  }
}
int32_t codegen_try_emit_fn_as_value(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, uint8_t * name, int32_t name_len) {
  {
    if ((((out ==0) || (name ==0)) || (name_len <=0))) {
      return 1;
    }
    if (((ctx ==0) || (((ctx)->current_codegen_module) ==0))) {
      return 1;
    }
    if ((codegen_name_is_local_binding(arena, ctx, name, name_len) !=0)) {
      return 1;
    }
    struct ast_Module * mod = ((ctx)->current_codegen_module);
    int32_t fi = codegen_find_module_func_index_by_name(mod, name, name_len);
    if ((fi < 0)) {
      return 1;
    }
    int32_t pre_len = ((ctx)->current_codegen_prefix_len);
    int32_t sym_pre = codegen_func_c_symbol_prefix_len(mod, fi, pre_len);
    if ((sym_pre > 0)) {
      if ((codegen_c_prefix_redundant_with_name(&((((ctx)->current_codegen_prefix_mirror))[0]), sym_pre, name, name_len) ==0)) {
        if ((codegen_emit_bytes_from_ptr(out, &((((ctx)->current_codegen_prefix_mirror))[0]), sym_pre) !=0)) {
          return -1;
        }
      }
    }
    if ((codegen_emit_func_link_name(out, arena, mod, fi) !=0)) {
      return -1;
    }
    return 0;
  }
}
struct ast_ASTArena * codegen_arena_for_module(struct ast_PipelineDepCtx * ctx, struct ast_Module * module, struct ast_ASTArena * fallback) {
  {
    if (((ctx ==0) || (module ==0))) {
      return fallback;
    }
    int32_t di = 0;
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    while ((di < nd)) {
      if ((pipeline_dep_ctx_module_at(ctx, di) ==module)) {
        struct ast_ASTArena * da = pipeline_dep_ctx_arena_at(ctx, di);
        if ((da !=0)) {
          return da;
        }
        return fallback;
      }
      (void)((di = (di + 1)));
    }
    return fallback;
  }
}
int32_t codegen_emit_call_func_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, int32_t expr_ref, struct ast_Module * current_module, uint8_t * fallback_name, int32_t fallback_len) {
  if (((ctx !=0) && (arena !=0))) {
    int32_t func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    struct ast_Expr call_e0 = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t is_m0 = 0;
    if ((((int32_t)(((call_e0).kind))) ==49)) {
      (void)((is_m0 = 1));
    }
    int32_t nargs0 = 0;
    if ((is_m0 !=0)) {
      (void)((nargs0 = ((call_e0).method_call_num_args)));
    } else {
      (void)((nargs0 = ((call_e0).call_num_args)));
    }
    if ((func_ix >=0)) {
      struct ast_Module * res_mod = 0;
      if (((dep_ix >=0) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
        (void)((res_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
      } else {
        (void)((res_mod = current_module));
      }
      if (((res_mod !=0) && (func_ix < ((res_mod)->num_funcs)))) {
        int32_t ok_res = 1;
        if ((pipeline_module_func_num_params_at(res_mod, func_ix) !=nargs0)) {
          (void)((ok_res = 0));
        }
        if (((ok_res !=0) && (fallback_len > 0))) {
          int32_t rlen = pipeline_module_func_name_len_at(res_mod, func_ix);
          if ((rlen !=fallback_len)) {
            (void)((ok_res = 0));
          } else {
            uint8_t rnm[128] = {};
            (void)(pipeline_module_func_name_copy64(res_mod, func_ix, &((rnm)[0])));
            int32_t ri = 0;
            while ((ri < rlen)) {
              if (((rnm)[ri] !=(fallback_name)[ri])) {
                (void)((ok_res = 0));
                (void)((ri = rlen));
              } else {
                (void)((ri = (ri + 1)));
              }
            }
          }
        }
        if ((((ok_res !=0) && (current_module !=0)) && (res_mod !=current_module))) {
          (void)((ok_res = 0));
        }
        if ((ok_res !=0)) {
          struct ast_ASTArena * res_arena = codegen_arena_for_module(ctx, res_mod, arena);
          if ((pipeline_module_func_num_generic_params_at(res_mod, func_ix) > 0)) {
            int32_t np_mono = pipeline_module_func_num_params_at(res_mod, func_ix);
            int32_t re_mono = codegen_func_ret_type_param_extra(res_arena, res_mod, func_ix);
            int32_t cw_mono = (np_mono + re_mono);
            if (((cw_mono > 0) && (cw_mono <=8))) {
              struct ast_Expr call_e_mono = ast_ast_arena_expr_get(arena, expr_ref);
              int32_t nargs_mono = ((call_e_mono).call_num_args);
              int32_t mono_tys[8] = {};
              int32_t pi_mono = 0;
              int32_t valid_mono = 1;
              while ((pi_mono < np_mono)) {
                int32_t ty_mono = codegen_call_mono_type_at(arena, expr_ref, pi_mono, nargs_mono);
                if ((ty_mono <=0)) {
                  (void)((valid_mono = 0));
                  (void)((pi_mono = np_mono));
                } else {
                  (void)(((mono_tys)[pi_mono] = ty_mono));
                }
                (void)((pi_mono = (pi_mono + 1)));
              }
              if (((valid_mono !=0) && (re_mono !=0))) {
                int32_t rty_mono = codegen_call_ret_type_param_concrete_at(arena, expr_ref);
                if ((rty_mono <=0)) {
                  (void)((valid_mono = 0));
                } else {
                  (void)(((mono_tys)[np_mono] = rty_mono));
                }
              }
              if ((valid_mono !=0)) {
                return codegen_emit_mono_mangled_name(out, arena, res_mod, func_ix, &((mono_tys)[0]), cw_mono);
              }
            }
          }
          return codegen_emit_func_link_name(out, res_arena, res_mod, func_ix);
        }
      }
      (void)((func_ix = -1));
    }
    struct ast_Module * search_mod = 0;
    struct ast_ASTArena * search_arena = arena;
    if ((current_module !=0)) {
      (void)((search_mod = current_module));
      (void)((search_arena = codegen_arena_for_module(ctx, search_mod, arena)));
    } else {
      if (((dep_ix >=0) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
        (void)((search_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
        (void)((search_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix)));
        if ((search_arena ==0)) {
          (void)((search_arena = arena));
        }
      } else {
        (void)((search_mod = current_module));
        (void)((search_arena = codegen_arena_for_module(ctx, search_mod, arena)));
      }
    }
    if (((search_mod !=0) && (fallback_len > 0))) {
      struct ast_Expr call_e = call_e0;
      int32_t is_method = is_m0;
      int32_t call_nargs = nargs0;
      int32_t found_fi = -1;
      int32_t found_count = 0;
      int32_t fi_s = 0;
      while ((fi_s < ((search_mod)->num_funcs))) {
        int32_t fn_len = pipeline_module_func_name_len_at(search_mod, fi_s);
        if (((fn_len ==fallback_len) && (fn_len > 0))) {
          uint8_t fn_name[128] = {};
          (void)(pipeline_module_func_name_copy64(search_mod, fi_s, &((fn_name)[0])));
          int32_t matched = 1;
          int32_t bi = 0;
          while ((bi < fn_len)) {
            if (((fn_name)[bi] !=(fallback_name)[bi])) {
              (void)((matched = 0));
              (void)((bi = fn_len));
            } else {
              (void)((bi = (bi + 1)));
            }
          }
          if ((matched !=0)) {
            int32_t np = pipeline_module_func_num_params_at(search_mod, fi_s);
            if ((np ==call_nargs)) {
              int32_t types_match = 1;
              int32_t pi = 0;
              while (((pi < np) && (types_match !=0))) {
                int32_t arg_ref = 0;
                if ((is_method !=0)) {
                  (void)((arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, pi)));
                } else {
                  (void)((arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi)));
                }
                if (ast_ref_is_null(arg_ref)) {
                  (void)((types_match = 0));
                } else {
                  int32_t arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
                  if ((((((arg_ty <=0) && (ctx !=0)) && (((ctx)->current_codegen_module) !=0)) && (((ctx)->current_func_index) >=0)) && (pipeline_expr_kind_ord_at(arena, arg_ref) ==3))) {
                    int32_t av_len = pipeline_expr_var_name_len(arena, arg_ref);
                    if (((av_len > 0) && (av_len <=63))) {
                      uint8_t av_buf[128] = {};
                      (void)(pipeline_expr_var_name_into(arena, arg_ref, &((av_buf)[0])));
                      int32_t apt = pipeline_module_func_param_type_ref_for_name(((ctx)->current_codegen_module), ((ctx)->current_func_index), &((av_buf)[0]), av_len);
                      if ((apt > 0)) {
                        (void)((arg_ty = apt));
                      }
                    }
                  }
                  if (((arg_ty <=0) && (pipeline_expr_kind_ord_at(arena, arg_ref) ==54))) {
                    int32_t as_tgt = pipeline_expr_as_target_type_ref_at(arena, arg_ref);
                    if ((as_tgt > 0)) {
                      (void)((arg_ty = as_tgt));
                    }
                  }
                  int32_t is_str_lit = 0;
                  if (((arg_ty <=0) && (pipeline_expr_kind_ord_at(arena, arg_ref) ==59))) {
                    (void)((is_str_lit = 1));
                  }
                  int32_t param_ty = pipeline_module_func_param_type_ref_at(search_mod, fi_s, pi);
                  uint8_t sa[128] = {};
                  uint8_t sb[128] = {};
                  int32_t na = 0;
                  int32_t nb = 0;
                  if (((((is_str_lit ==0) && (arg_ty > 0)) && (pipeline_type_kind_ord_at(arena, arg_ty) ==10)) && (pipeline_type_kind_ord_at(search_arena, param_ty) ==9))) {
                    int32_t ae = pipeline_type_elem_ref_at(arena, arg_ty);
                    int32_t pe = pipeline_type_elem_ref_at(search_arena, param_ty);
                    (void)((na = codegen_type_ref_to_suffix(arena, ae, &((sa)[0]), 64)));
                    (void)((nb = codegen_type_ref_to_suffix(search_arena, pe, &((sb)[0]), 64)));
                  } else {
                    if ((is_str_lit !=0)) {
                      (void)(((sa)[0] = 117));
                      (void)(((sa)[1] = 56));
                      (void)(((sa)[2] = 95));
                      (void)(((sa)[3] = 112));
                      (void)(((sa)[4] = 116));
                      (void)(((sa)[5] = 114));
                      (void)((na = 6));
                      (void)((nb = codegen_type_ref_to_suffix(search_arena, param_ty, &((sb)[0]), 64)));
                    } else {
                      (void)((na = codegen_type_ref_to_suffix(arena, arg_ty, &((sa)[0]), 64)));
                      (void)((nb = codegen_type_ref_to_suffix(search_arena, param_ty, &((sb)[0]), 64)));
                    }
                  }
                  if ((na !=nb)) {
                    (void)((types_match = 0));
                  } else {
                    if ((na <=0)) {
                      (void)((types_match = 0));
                    } else {
                      int32_t k = 0;
                      while ((k < na)) {
                        if (((sa)[k] !=(sb)[k])) {
                          (void)((types_match = 0));
                          (void)((k = na));
                        } else {
                          (void)((k = (k + 1)));
                        }
                      }
                    }
                  }
                }
                (void)((pi = (pi + 1)));
              }
              if ((types_match !=0)) {
                (void)((found_fi = fi_s));
                (void)((found_count = (found_count + 1)));
              }
            }
          }
        }
        (void)((fi_s = (fi_s + 1)));
      }
      if (((found_count ==1) && (found_fi >=0))) {
        if ((is_method !=0)) {
          int32_t recv_ty_fb = 0;
          struct ast_Expr call_e_fb = call_e0;
          if (!(ast_ref_is_null(((call_e_fb).method_call_base_ref)))) {
            (void)((recv_ty_fb = pipeline_expr_resolved_type_ref(arena, ((call_e_fb).method_call_base_ref))));
          }
          if ((recv_ty_fb > 0)) {
            int32_t fb_mono_rc = codegen_try_emit_impl_method_mono_call_name(out, search_arena, ctx, search_mod, found_fi, recv_ty_fb);
            if ((fb_mono_rc < 0)) {
              return -1;
            }
            if ((fb_mono_rc ==1)) {
              return 0;
            }
          }
        }
        return codegen_emit_func_link_name(out, search_arena, search_mod, found_fi);
      }
      if (((((found_count !=1) && (call_nargs ==1)) && (is_method !=0)) && (search_mod !=0))) {
        int32_t arg0 = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
        int32_t arg0_ty = 0;
        if ((arg0 > 0)) {
          (void)((arg0_ty = pipeline_expr_resolved_type_ref(arena, arg0)));
        }
        if (((arg0_ty > 0) && (pipeline_type_kind_ord_at(arena, arg0_ty) ==9))) {
          int32_t ae_k = 0;
          int32_t ae = pipeline_type_elem_ref_at(arena, arg0_ty);
          if ((ae > 0)) {
            (void)((ae_k = pipeline_type_kind_ord_at(arena, ae)));
          }
          int32_t fi_p = 0;
          int32_t best_p = -1;
          int32_t n_p = 0;
          while ((fi_p < ((search_mod)->num_funcs))) {
            int32_t fl = pipeline_module_func_name_len_at(search_mod, fi_p);
            if ((((fl ==fallback_len) && (fl > 0)) && (pipeline_module_func_num_params_at(search_mod, fi_p) ==1))) {
              uint8_t fnm_p[128] = {};
              (void)(pipeline_module_func_name_copy64(search_mod, fi_p, &((fnm_p)[0])));
              int32_t me = 1;
              int32_t bi = 0;
              while ((bi < fl)) {
                if (((fnm_p)[bi] !=(fallback_name)[bi])) {
                  (void)((me = 0));
                  (void)((bi = fl));
                } else {
                  (void)((bi = (bi + 1)));
                }
              }
              if ((me !=0)) {
                int32_t pt = pipeline_module_func_param_type_ref_at(search_mod, fi_p, 0);
                if (((pt > 0) && (pipeline_type_kind_ord_at(search_arena, pt) ==9))) {
                  int32_t pe = pipeline_type_elem_ref_at(search_arena, pt);
                  if (((pe > 0) && (pipeline_type_kind_ord_at(search_arena, pe) ==ae_k))) {
                    (void)((best_p = fi_p));
                    (void)((n_p = (n_p + 1)));
                  }
                }
              }
            }
            (void)((fi_p = (fi_p + 1)));
          }
          if (((n_p ==1) && (best_p >=0))) {
            int32_t recv_ty_p = 0;
            struct ast_Expr call_e_p = call_e0;
            if (!(ast_ref_is_null(((call_e_p).method_call_base_ref)))) {
              (void)((recv_ty_p = pipeline_expr_resolved_type_ref(arena, ((call_e_p).method_call_base_ref))));
            }
            if ((recv_ty_p > 0)) {
              int32_t p_mono_rc = codegen_try_emit_impl_method_mono_call_name(out, search_arena, ctx, search_mod, best_p, recv_ty_p);
              if ((p_mono_rc < 0)) {
                return -1;
              }
              if ((p_mono_rc ==1)) {
                return 0;
              }
            }
            return codegen_emit_func_link_name(out, search_arena, search_mod, best_p);
          }
        }
      }
      if (((found_count !=1) && (call_nargs >=0))) {
        int32_t arity_fi = -1;
        int32_t arity_count = 0;
        int32_t ext_fi = -1;
        int32_t ext_count = 0;
        int32_t fi_a = 0;
        while ((fi_a < ((search_mod)->num_funcs))) {
          int32_t fn_len_a = pipeline_module_func_name_len_at(search_mod, fi_a);
          if (((fn_len_a ==fallback_len) && (fn_len_a > 0))) {
            uint8_t fn_name_a[128] = {};
            (void)(pipeline_module_func_name_copy64(search_mod, fi_a, &((fn_name_a)[0])));
            int32_t matched_a = 1;
            int32_t bi_a = 0;
            while ((bi_a < fn_len_a)) {
              if (((fn_name_a)[bi_a] !=(fallback_name)[bi_a])) {
                (void)((matched_a = 0));
                (void)((bi_a = fn_len_a));
              } else {
                (void)((bi_a = (bi_a + 1)));
              }
            }
            if ((matched_a !=0)) {
              int32_t np_a = pipeline_module_func_num_params_at(search_mod, fi_a);
              if ((np_a ==call_nargs)) {
                (void)((arity_fi = fi_a));
                (void)((arity_count = (arity_count + 1)));
                if (((pipeline_module_func_is_extern_at(search_mod, fi_a) !=0) || (pipeline_module_func_is_no_mangle_at(search_mod, fi_a) !=0))) {
                  (void)((ext_fi = fi_a));
                  (void)((ext_count = (ext_count + 1)));
                }
              }
            }
          }
          (void)((fi_a = (fi_a + 1)));
        }
        if (((ext_count ==1) && (ext_fi >=0))) {
          return codegen_emit_func_link_name(out, search_arena, search_mod, ext_fi);
        }
        if (((arity_count ==1) && (arity_fi >=0))) {
          return codegen_emit_func_link_name(out, search_arena, search_mod, arity_fi);
        }
      }
    }
  }
  if ((((ctx !=0) && (fallback_len > 0)) && (arena !=0))) {
    struct ast_Expr mc_e = ast_ast_arena_expr_get(arena, expr_ref);
    int32_t mc_nargs = 0;
    if ((((int32_t)(((mc_e).kind))) ==49)) {
      (void)((mc_nargs = ((mc_e).method_call_num_args)));
    } else {
      (void)((mc_nargs = ((mc_e).call_num_args)));
    }
    int32_t dep_di = 0;
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    while ((dep_di < nd)) {
      struct ast_Module * dm = pipeline_dep_ctx_module_at(ctx, dep_di);
      struct ast_ASTArena * da = pipeline_dep_ctx_arena_at(ctx, dep_di);
      if (((dm !=0) && (da !=0))) {
        int32_t fi_x = 0;
        int32_t found_x = -1;
        while ((fi_x < ((dm)->num_funcs))) {
          int32_t fn_x = pipeline_module_func_name_len_at(dm, fi_x);
          if (((fn_x ==fallback_len) && (fn_x > 0))) {
            uint8_t fnm[128] = {};
            (void)(pipeline_module_func_name_copy64(dm, fi_x, &((fnm)[0])));
            int32_t mx = 1;
            int32_t bx = 0;
            while ((bx < fn_x)) {
              if (((fnm)[bx] !=(fallback_name)[bx])) {
                (void)((mx = 0));
                (void)((bx = fn_x));
              } else {
                (void)((bx = (bx + 1)));
              }
            }
            if (((mx !=0) && (pipeline_module_func_num_params_at(dm, fi_x) ==mc_nargs))) {
              (void)((found_x = fi_x));
              (void)((fi_x = ((dm)->num_funcs)));
            } else {
              (void)((fi_x = (fi_x + 1)));
            }
          } else {
            (void)((fi_x = (fi_x + 1)));
          }
        }
        if ((found_x >=0)) {
          return codegen_emit_func_link_name(out, da, dm, found_x);
        }
      }
      (void)((dep_di = (dep_di + 1)));
    }
  }
  return codegen_emit_bytes_from_ptr(out, fallback_name, fallback_len);
}
void codegen_copy_func_name64_from_module(struct ast_Module * module, int32_t fi, uint8_t * dst) {
  (void)(pipeline_module_func_name_copy64(module, fi, dst));
}
void codegen_copy_param_name32_from_module(struct ast_Module * module, int32_t fi, int32_t pi, uint8_t * dst) {
  (void)(pipeline_module_func_param_name_copy32(module, fi, pi, dst));
}
int32_t codegen_block_contains_return(struct ast_ASTArena * arena, int32_t block_ref) {
  {
    if (((arena ==0) || ast_ref_is_null(block_ref))) {
      return 0;
    }
    if (!(ast_ref_is_null(ast_ast_block_final_expr_ref(arena, block_ref)))) {
      return 1;
    }
    int32_t ji = 0;
    int32_t nes = ast_ast_block_num_expr_stmts(arena, block_ref);
    while ((ji < nes)) {
      struct ast_Expr se = ast_ast_arena_expr_get(arena, ast_ast_block_expr_stmt_ref(arena, block_ref, ji));
      if ((((int32_t)(((se).kind))) ==41)) {
        return 1;
      }
      (void)((ji = (ji + 1)));
    }
    int32_t ri = 0;
    int32_t nr = ast_ast_block_num_regions(arena, block_ref);
    while ((ri < nr)) {
      int32_t rb = ast_ast_block_region_body_ref(arena, block_ref, ri);
      if ((codegen_block_contains_return(arena, rb) !=0)) {
        return 1;
      }
      (void)((ri = (ri + 1)));
    }
    return 0;
  }
}
int32_t codegen_emit_func(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, int is_entry, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx, int32_t call_init_globals) {
  {
    uint8_t fn_local[128] = {};
    int32_t fn_len = 0;
    int name_is_main = 0;
    int force_entry_main = 0;
    int emit_c_main_symbol = 0;
    uint8_t main_name[4] = {109, 97, 105, 110};
    if (((fi < 0) || (fi >=((module)->num_funcs)))) {
      return -1;
    }
    (void)((fn_len = pipeline_module_func_name_len_at(module, fi)));
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    if ((pipeline_module_func_is_used_at(module, fi) !=0)) {
      uint8_t used_attr[27] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((used_attr)[0]), 22) !=0)) {
        return -1;
      }
    }
    if ((pipeline_module_func_is_naked_at(module, fi) !=0)) {
      uint8_t naked_attr[29] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((naked_attr)[0]), 23) !=0)) {
        return -1;
      }
    }
    if ((pipeline_module_func_is_entry_at(module, fi) !=0)) {
      uint8_t entry_attr[30] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((entry_attr)[0]), 26) !=0)) {
        return -1;
      }
    }
    if ((pipeline_module_func_is_interrupt_at(module, fi) !=0)) {
      uint8_t int_attr[31] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((int_attr)[0]), 27) !=0)) {
        return -1;
      }
    }
    if ((((((fn_len ==4) && ((fn_local)[0] ==109)) && ((fn_local)[1] ==97)) && ((fn_local)[2] ==105)) && ((fn_local)[3] ==110))) {
      (void)((name_is_main = 1));
    }
    if ((is_entry && (((module)->num_funcs) ==1))) {
      if ((fn_len <=0)) {
        (void)((force_entry_main = 1));
      }
      if (((fn_local)[0] ==0)) {
        (void)((force_entry_main = 1));
      }
    }
    if (is_entry) {
      if (name_is_main) {
        (void)((emit_c_main_symbol = 1));
      }
    }
    if (force_entry_main) {
      (void)((emit_c_main_symbol = 1));
    }
    int32_t ret_ty_ref = pipeline_module_func_return_type_at(module, fi);
    int32_t w495_mono_set = 0;
    int32_t w495_saved_active = 0;
    int32_t w495_saved_num = 0;
    if ((ctx !=0)) {
      int32_t w495_gen[8] = {};
      int32_t w495_conc[8] = {};
      int32_t w495_n = codegen_build_func_param_mono_map(module, arena, fi, &((w495_gen)[0]), &((w495_conc)[0]), 8);
      if ((w495_n > 0)) {
        (void)((w495_saved_active = ((ctx)->mono_active)));
        (void)((w495_saved_num = ((ctx)->mono_num_types)));
        int32_t w495_k = 0;
        while (((w495_k < w495_n) && (w495_k < 8))) {
          (void)(((((ctx)->mono_generic_type_refs))[w495_k] = (w495_gen)[w495_k]));
          (void)(((((ctx)->mono_concrete_type_refs))[w495_k] = (w495_conc)[w495_k]));
          (void)((w495_k = (w495_k + 1)));
        }
        (void)((((ctx)->mono_active) = 1));
        (void)((((ctx)->mono_num_types) = w495_n));
        (void)((w495_mono_set = 1));
      }
    }
    int fn_ret_void_pre = (pipeline_type_kind_ord_at(arena, ret_ty_ref) ==16);
    if ((emit_c_main_symbol && fn_ret_void_pre)) {
      uint8_t i32_ty[8] = {105, 110, 116, 51, 50, 95, 116, 0};
      if ((codegen_emit_bytes_8(out, &((i32_ty)[0]), 7) !=0)) {
        return -1;
      }
    } else {
      if ((codegen_emit_type(arena, out, ret_ty_ref, prefix, prefix_len, ctx) !=0)) {
        return -1;
      }
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -1;
    }
    if (emit_c_main_symbol) {
      if ((codegen_emit_bytes_4(out, &((main_name)[0]), 4) !=0)) {
        return -1;
      }
    } else {
      int32_t sym_pre = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
      if ((((sym_pre > 0) && (codegen_c_prefix_redundant_with_name(prefix, sym_pre, &((fn_local)[0]), fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, prefix, sym_pre) !=0))) {
        return -1;
      }
      if ((codegen_emit_func_link_name(out, arena, module, fi) !=0)) {
        return -1;
      }
      if ((codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &((fn_local)[0]), fn_len) !=0)) {
        uint8_t impl_suffix[6] = {95, 105, 109, 112, 108, 0};
        if ((codegen_emit_bytes_from_ptr(out, &((impl_suffix)[0]), 5) !=0)) {
          return -1;
        }
      }
    }
    uint8_t lpar[2] = {40, 0};
    if ((codegen_emit_bytes_2(out, &((lpar)[0]), 1) !=0)) {
      return -1;
    }
    if ((pipeline_module_func_num_params_at(module, fi) ==0)) {
      uint8_t v[7] = {118, 111, 105, 100, 0, 0, 0};
      if ((codegen_emit_bytes_7(out, &((v)[0]), 4) !=0)) {
        return -1;
      }
    } else {
      int32_t p = 0;
      while ((p < pipeline_module_func_num_params_at(module, fi))) {
        if ((p > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
        }
        if ((codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
          uint8_t size_t_ps[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_32(out, &((size_t_ps)[0]), 7) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_force_param_size_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
            uint8_t size_t_buf[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_32(out, &((size_t_buf)[0]), 7) !=0)) {
              return -1;
            }
          } else {
            if ((codegen_force_param_ptrdiff_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
              uint8_t ptrdiff_t_buf[32] = {112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
              if ((codegen_emit_bytes_32(out, &((ptrdiff_t_buf)[0]), 10) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_force_param_uint32_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                uint8_t u32_buf[32] = {117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
                if ((codegen_emit_bytes_32(out, &((u32_buf)[0]), 9) !=0)) {
                  return -1;
                }
              } else {
                if ((codegen_force_param_i32(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                  uint8_t i32_str[8] = {105, 110, 116, 51, 50, 95, 116, 0};
                  if ((codegen_emit_bytes_8(out, &((i32_str)[0]), 7) !=0)) {
                    return -1;
                  }
                } else {
                  if ((codegen_type_is(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) !=0)) {
                    uint8_t pta_nm[128] = {};
                    int32_t pta_nl = 0;
                    if ((pipeline_module_func_param_name_len_at(module, fi, p) > 0)) {
                      (void)(codegen_copy_param_name32_from_module(module, fi, p, &((pta_nm)[0])));
                      (void)((pta_nl = pipeline_module_func_param_name_len_at(module, fi, p)));
                      if (((pta_nm)[0] <=32)) {
                        (void)((pta_nl = 0));
                      }
                    }
                    if ((pta_nl <=0)) {
                      (void)(((pta_nm)[0] = 95));
                      (void)(((pta_nm)[1] = 112));
                      (void)((pta_nl = 2));
                      int32_t v_p = p;
                      uint8_t digs_p[12] = {};
                      int32_t nd_p = 0;
                      if ((v_p ==0)) {
                        (void)(((digs_p)[0] = 48));
                        (void)((nd_p = 1));
                      } else {
                        int32_t tmp_p = v_p;
                        while (((tmp_p > 0) && (nd_p < 12))) {
                          (void)(((digs_p)[nd_p] = ((uint8_t)(((tmp_p % 10) + 48)))));
                          (void)((tmp_p = (tmp_p / 10)));
                          (void)((nd_p = (nd_p + 1)));
                        }
                        int32_t a_p = 0;
                        int32_t b_p = (nd_p - 1);
                        while ((a_p < b_p)) {
                          uint8_t sw_p = (digs_p)[a_p];
                          (void)(((digs_p)[a_p] = (digs_p)[b_p]));
                          (void)(((digs_p)[b_p] = sw_p));
                          (void)((a_p = (a_p + 1)));
                          (void)((b_p = (b_p - 1)));
                        }
                      }
                      int32_t pi_p = 0;
                      while (((pi_p < nd_p) && (pta_nl < 128))) {
                        (void)(((pta_nm)[pta_nl] = (digs_p)[pi_p]));
                        (void)((pta_nl = (pta_nl + 1)));
                        (void)((pi_p = (pi_p + 1)));
                      }
                    }
                    if ((codegen_emit_c(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), &((pta_nm)[0]), pta_nl, ctx) !=0)) {
                      return -1;
                    }
                  } else {
                    if ((codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) !=0)) {
                      return -1;
                    }
                  }
                }
              }
            }
          }
        }
        if (((codegen_type_is(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) ==0) && (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) ==11))) {
          if ((codegen_append_byte(out, 32) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 42) !=0)) {
            return -1;
          }
        }
        if ((codegen_type_is(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) ==0)) {
          if ((codegen_append_byte(out, 32) !=0)) {
            return -1;
          }
          if ((pipeline_module_func_param_name_len_at(module, fi, p) > 0)) {
            uint8_t plocal[128] = {};
            (void)(codegen_copy_param_name32_from_module(module, fi, p, &((plocal)[0])));
            if ((((plocal)[0] > 32) && (codegen_emit_bytes_from_ptr(out, &((plocal)[0]), pipeline_module_func_param_name_len_at(module, fi, p)) !=0))) {
              return -1;
            }
          } else {
            uint8_t place[4] = {95, 112, 48, 0};
            if ((codegen_emit_bytes_4(out, &((place)[0]), 2) !=0)) {
              return -1;
            }
            if ((codegen_format_int(out, p) !=0)) {
              return -1;
            }
          }
        }
        (void)((p = (p + 1)));
      }
    }
    uint8_t rpar[3] = {41, 32, 0};
    if ((codegen_emit_bytes_3(out, &((rpar)[0]), 2) !=0)) {
      return -1;
    }
    uint8_t brace[3] = {123, 10, 0};
    if ((codegen_emit_bytes_3(out, &((brace)[0]), 2) !=0)) {
      return -1;
    }
    if ((codegen_try_emit_std_io_driver_buf_body(out, module, fi, prefix, prefix_len) !=0)) {
      if ((w495_mono_set !=0)) {
        (void)((((ctx)->mono_active) = w495_saved_active));
        (void)((((ctx)->mono_num_types) = w495_saved_num));
      }
      return 0;
    }
    int fn_ret_void = (pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi)) ==16);
    if ((call_init_globals !=0)) {
      if (is_entry) {
        if (emit_c_main_symbol) {
          if ((codegen_emit_indent(out, 2) !=0)) {
            return -1;
          }
          uint8_t init_globals_call[22] = {105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 41, 59, 10, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((init_globals_call)[0]), 16) !=0)) {
            return -1;
          }
        }
      }
    }
    int32_t saved_empty = -1;
    int32_t saved_count = 0;
    int32_t saved_next = 0;
    if ((ctx !=0)) {
      (void)(pipeline_dep_ctx_empty_param_backup(ctx));
      (void)((saved_empty = ((ctx)->current_func_single_empty_param_index)));
      (void)((saved_count = ((ctx)->current_func_empty_param_count)));
      (void)((saved_next = ((ctx)->current_emit_empty_var_next_index)));
      int32_t empty_count = 0;
      int32_t empty_idx = -1;
      int32_t pi = 0;
      while ((pi < pipeline_module_func_num_params_at(module, fi))) {
        if ((pipeline_module_func_param_name_len_at(module, fi, pi) <=0)) {
          (void)((empty_count = (empty_count + 1)));
          (void)((empty_idx = pi));
        }
        (void)((pi = (pi + 1)));
      }
      if ((empty_count ==1)) {
        (void)((((ctx)->current_func_single_empty_param_index) = empty_idx));
        (void)((((ctx)->current_func_empty_param_count) = 0));
        (void)((((ctx)->current_emit_empty_var_next_index) = 0));
      } else {
        if ((empty_count >=2)) {
          (void)((((ctx)->current_func_single_empty_param_index) = -1));
          (void)(pipeline_dep_ctx_empty_param_reset(ctx));
          (void)((((ctx)->current_func_empty_param_count) = empty_count));
          int32_t ei = 0;
          (void)((pi = 0));
          while ((pi < pipeline_module_func_num_params_at(module, fi))) {
            if ((pipeline_module_func_param_name_len_at(module, fi, pi) <=0)) {
              (void)(pipeline_dep_ctx_empty_param_append(ctx, pi));
              (void)((ei = (ei + 1)));
            }
            (void)((pi = (pi + 1)));
          }
          (void)((((ctx)->current_emit_empty_var_next_index) = 0));
        } else {
          (void)((((ctx)->current_func_single_empty_param_index) = -1));
          (void)((((ctx)->current_func_empty_param_count) = 0));
          (void)((((ctx)->current_emit_empty_var_next_index) = 0));
        }
      }
    }
    if (!(ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {
      int32_t saved_block = 0;
      if ((ctx !=0)) {
        (void)((saved_block = ((ctx)->current_block_ref)));
        (void)((((ctx)->current_block_ref) = pipeline_module_func_body_ref_at(module, fi)));
      }
      if ((codegen_emit_block(arena, out, pipeline_module_func_body_ref_at(module, fi), 2, ctx) !=0)) {
        if ((ctx !=0)) {
          (void)((((ctx)->current_block_ref) = saved_block));
        }
        return -1;
      }
      if ((ctx !=0)) {
        (void)((((ctx)->current_block_ref) = saved_block));
      }
    } else {
      if (!(ast_ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi)))) {
        if (fn_ret_void) {
          if ((codegen_emit_indent(out, 2) !=0)) {
            return -1;
          }
          if ((codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 59) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 10) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_emit_indent(out, 2) !=0)) {
            return -1;
          }
          uint8_t ret_keyword[9] = {114, 101, 116, 117, 114, 110, 32, 0, 0};
          if ((codegen_emit_bytes_9(out, &((ret_keyword)[0]), 7) !=0)) {
            return -1;
          }
          struct ast_Expr body_e = ast_ast_arena_expr_get(arena, pipeline_module_func_body_expr_ref_at(module, fi));
          if ((((int32_t)(((body_e).kind))) ==41)) {
            if ((!(ast_ref_is_null(((body_e).unary_operand_ref))) && (codegen_emit_expr(arena, out, ((body_e).unary_operand_ref), ctx) !=0))) {
              return -1;
            }
          } else {
            if ((codegen_emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) !=0)) {
              return -1;
            }
          }
          if ((codegen_append_byte(out, 59) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 10) !=0)) {
            return -1;
          }
        }
      }
    }
    if ((ctx !=0)) {
      (void)((((ctx)->current_func_single_empty_param_index) = saved_empty));
      (void)((((ctx)->current_func_empty_param_count) = saved_count));
      (void)((((ctx)->current_emit_empty_var_next_index) = saved_next));
      (void)(pipeline_dep_ctx_empty_param_restore(ctx));
    }
    int need_fallback_return = 0;
    if (fn_ret_void) {
      if (emit_c_main_symbol) {
        if (!(ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {
          if ((codegen_block_contains_return(arena, pipeline_module_func_body_ref_at(module, fi)) ==0)) {
            (void)((need_fallback_return = 1));
          }
        } else {
          (void)((need_fallback_return = 1));
        }
      } else {
        (void)((need_fallback_return = 0));
      }
    } else {
      if (!(ast_ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi)))) {
        (void)((need_fallback_return = 0));
      } else {
        if (!(ast_ref_is_null(pipeline_module_func_body_ref_at(module, fi)))) {
          int32_t body_br = pipeline_module_func_body_ref_at(module, fi);
          if ((codegen_block_contains_return(arena, body_br) ==0)) {
            int32_t ret_ord = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
            if ((((ret_ord >=0) && (ret_ord <=7)) || (ret_ord ==9))) {
              (void)((need_fallback_return = 1));
            }
          }
        } else {
          int32_t ret_ord2 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
          if ((((ret_ord2 >=0) && (ret_ord2 <=7)) || (ret_ord2 ==9))) {
            (void)((need_fallback_return = 1));
          }
        }
      }
    }
    if (need_fallback_return) {
      if ((codegen_emit_indent(out, 2) !=0)) {
        return -1;
      }
      uint8_t ret0[9] = {114, 101, 116, 117, 114, 110, 32, 48, 59};
      if ((codegen_emit_bytes_9(out, &((ret0)[0]), 9) !=0)) {
        return -1;
      }
      if ((codegen_append_byte(out, 10) !=0)) {
        return -1;
      }
    }
    uint8_t close[3] = {125, 10, 0};
    if ((codegen_emit_bytes_3(out, &((close)[0]), 2) !=0)) {
      return -1;
    }
    if ((w495_mono_set !=0)) {
      (void)((((ctx)->mono_active) = w495_saved_active));
      (void)((((ctx)->mono_num_types) = w495_saved_num));
    }
    return 0;
  }
}
int32_t codegen_is_libc_conflicting_extern_name(uint8_t * name, int32_t name_len) {
  if (((name ==0) || (name_len <=0))) {
    return 0;
  }
  if ((((((name_len ==4) && ((name)[0] ==114)) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==100))) {
    return 1;
  }
  if (((((((name_len ==5) && ((name)[0] ==119)) && ((name)[1] ==114)) && ((name)[2] ==105)) && ((name)[3] ==116)) && ((name)[4] ==101))) {
    return 1;
  }
  if ((((((name_len ==4) && ((name)[0] ==111)) && ((name)[1] ==112)) && ((name)[2] ==101)) && ((name)[3] ==110))) {
    return 1;
  }
  if (((((((name_len ==5) && ((name)[0] ==99)) && ((name)[1] ==108)) && ((name)[2] ==111)) && ((name)[3] ==115)) && ((name)[4] ==101))) {
    return 1;
  }
  if (((((((name_len ==5) && ((name)[0] ==102)) && ((name)[1] ==99)) && ((name)[2] ==110)) && ((name)[3] ==116)) && ((name)[4] ==108))) {
    return 1;
  }
  if ((((((name_len ==4) && ((name)[0] ==102)) && ((name)[1] ==114)) && ((name)[2] ==101)) && ((name)[3] ==101))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==97)) && ((name)[2] ==108)) && ((name)[3] ==108)) && ((name)[4] ==111)) && ((name)[5] ==99))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==99)) && ((name)[1] ==97)) && ((name)[2] ==108)) && ((name)[3] ==108)) && ((name)[4] ==111)) && ((name)[5] ==99))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==114)) && ((name)[1] ==101)) && ((name)[2] ==97)) && ((name)[3] ==108)) && ((name)[4] ==108)) && ((name)[5] ==111)) && ((name)[6] ==99))) {
    return 1;
  }
  if ((((((((((((((((name_len ==14) && ((name)[0] ==112)) && ((name)[1] ==111)) && ((name)[2] ==115)) && ((name)[3] ==105)) && ((name)[4] ==120)) && ((name)[5] ==95)) && ((name)[6] ==109)) && ((name)[7] ==101)) && ((name)[8] ==109)) && ((name)[9] ==97)) && ((name)[10] ==108)) && ((name)[11] ==105)) && ((name)[12] ==103)) && ((name)[13] ==110))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==117)) && ((name)[6] ==108))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==108))) {
    return 1;
  }
  if ((((((((((name_len ==8) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==117)) && ((name)[6] ==108)) && ((name)[7] ==108))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==116)) && ((name)[4] ==111)) && ((name)[5] ==108)) && ((name)[6] ==108))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==99)) && ((name)[4] ==112)) && ((name)[5] ==121))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==99)) && ((name)[4] ==109)) && ((name)[5] ==112))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==115)) && ((name)[4] ==101)) && ((name)[5] ==116))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==99)) && ((name)[4] ==104)) && ((name)[5] ==114))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==114)) && ((name)[4] ==99)) && ((name)[5] ==104)) && ((name)[6] ==114))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==109)) && ((name)[1] ==101)) && ((name)[2] ==109)) && ((name)[3] ==109)) && ((name)[4] ==101)) && ((name)[5] ==109))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==99)) && ((name)[4] ==104)) && ((name)[5] ==114))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==114)) && ((name)[4] ==99)) && ((name)[5] ==104)) && ((name)[6] ==114))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==99)) && ((name)[4] ==112)) && ((name)[5] ==121))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==110)) && ((name)[4] ==99)) && ((name)[5] ==112)) && ((name)[6] ==121))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==103)) && ((name)[1] ==101)) && ((name)[2] ==116)) && ((name)[3] ==101)) && ((name)[4] ==110)) && ((name)[5] ==118))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==103)) && ((name)[1] ==101)) && ((name)[2] ==116)) && ((name)[3] ==99)) && ((name)[4] ==119)) && ((name)[5] ==100))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==117)) && ((name)[1] ==110)) && ((name)[2] ==108)) && ((name)[3] ==105)) && ((name)[4] ==110)) && ((name)[5] ==107))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==108)) && ((name)[4] ==101)) && ((name)[5] ==110))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==99)) && ((name)[4] ==109)) && ((name)[5] ==112))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==110)) && ((name)[4] ==99)) && ((name)[5] ==109)) && ((name)[6] ==112))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==115)) && ((name)[4] ==116)) && ((name)[5] ==114))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==101)) && ((name)[2] ==116)) && ((name)[3] ==101)) && ((name)[4] ==110)) && ((name)[5] ==118))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==115)) && ((name)[1] ==121)) && ((name)[2] ==115)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==109))) {
    return 1;
  }
  if (((((((name_len ==5) && ((name)[0] ==102)) && ((name)[1] ==112)) && ((name)[2] ==117)) && ((name)[3] ==116)) && ((name)[4] ==115))) {
    return 1;
  }
  if ((((((((((name_len ==8) && ((name)[0] ==115)) && ((name)[1] ==116)) && ((name)[2] ==114)) && ((name)[3] ==101)) && ((name)[4] ==114)) && ((name)[5] ==114)) && ((name)[6] ==111)) && ((name)[7] ==114))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==97)) && ((name)[1] ==99)) && ((name)[2] ==99)) && ((name)[3] ==101)) && ((name)[4] ==115)) && ((name)[5] ==115))) {
    return 1;
  }
  if (((((((((name_len ==7) && ((name)[0] ==109)) && ((name)[1] ==107)) && ((name)[2] ==115)) && ((name)[3] ==116)) && ((name)[4] ==101)) && ((name)[5] ==109)) && ((name)[6] ==112))) {
    return 1;
  }
  if ((((((((name_len ==6) && ((name)[0] ==114)) && ((name)[1] ==101)) && ((name)[2] ==110)) && ((name)[3] ==97)) && ((name)[4] ==109)) && ((name)[5] ==101))) {
    return 1;
  }
  return 0;
}
int32_t codegen_find_mono_type_for_generic_func(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t arg_idx) {
  {
    if (((((arena ==0) || (module ==0)) || (fi < 0)) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    uint8_t fn_local[128] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    if ((fn_len <=0)) {
      return 0;
    }
    int32_t ei = 1;
    while ((ei <=((arena)->num_exprs))) {
      struct ast_Expr e = ast_ast_arena_expr_get(arena, ei);
      if ((((int32_t)(((e).kind))) ==48)) {
        int32_t matched = 0;
        if ((((e).call_resolved_func_index) ==fi)) {
          (void)((matched = 1));
        } else {
          if (((!(ast_ref_is_null(((e).call_callee_ref))) && (((e).call_callee_ref) > 0)) && (((e).call_callee_ref) <=((arena)->num_exprs)))) {
            struct ast_Expr cal = ast_ast_arena_expr_get(arena, ((e).call_callee_ref));
            if (((((int32_t)(((cal).kind))) ==3) && (((cal).var_name_len) ==fn_len))) {
              int32_t eq = 1;
              int32_t k = 0;
              while ((k < fn_len)) {
                if (((((cal).var_name))[k] !=(fn_local)[k])) {
                  (void)((eq = 0));
                  (void)((k = fn_len));
                } else {
                  (void)((k = (k + 1)));
                }
              }
              (void)((matched = eq));
            }
          }
        }
        if ((matched !=0)) {
          int32_t ty = 0;
          if ((arg_idx ==0)) {
            (void)((ty = ((e).resolved_type_ref)));
          }
          if ((((ty <=0) && (arg_idx >=0)) && (arg_idx < ((e).call_num_args)))) {
            int32_t a0 = pipeline_expr_call_arg_ref(arena, ei, arg_idx);
            if ((a0 > 0)) {
              (void)((ty = pipeline_expr_resolved_type_ref(arena, a0)));
            }
          }
          if ((ty > 0)) {
            return ty;
          }
        }
      }
      (void)((ei = (ei + 1)));
    }
    return 0;
  }
}
int32_t codegen_call_mono_type_at(struct ast_ASTArena * arena, int32_t ei, int32_t arg_idx, int32_t num_args) {
  {
    if (((((arena ==0) || (ei <=0)) || (arg_idx < 0)) || (num_args <=0))) {
      return 0;
    }
    struct ast_Expr e = ast_ast_arena_expr_get(arena, ei);
    if ((((int32_t)(((e).kind))) !=48)) {
      return 0;
    }
    int32_t ty = 0;
    if ((arg_idx < num_args)) {
      int32_t a = pipeline_expr_call_arg_ref(arena, ei, arg_idx);
      if ((a > 0)) {
        (void)((ty = pipeline_expr_resolved_type_ref(arena, a)));
      }
    }
    if (((ty <=0) && (arg_idx ==0))) {
      (void)((ty = ((e).resolved_type_ref)));
    }
    return ty;
  }
}
int32_t codegen_mono_combo_slot_equal(struct ast_ASTArena * arena, int32_t a, int32_t b) {
  {
    if ((a ==b)) {
      return 1;
    }
    if ((((a <=0) || (b <=0)) || (arena ==0))) {
      return 0;
    }
    int32_t ka = pipeline_type_kind_ord_at(arena, a);
    int32_t kb = pipeline_type_kind_ord_at(arena, b);
    if ((ka !=kb)) {
      return 0;
    }
    if ((ka ==8)) {
      uint8_t na[128] = {};
      uint8_t nb[128] = {};
      int32_t la = pipeline_type_named_name_into(arena, a, &((na)[0]));
      int32_t lb = pipeline_type_named_name_into(arena, b, &((nb)[0]));
      if (((la <=0) || (la !=lb))) {
        return 0;
      }
      int32_t i = 0;
      while ((i < la)) {
        if (((na)[i] !=(nb)[i])) {
          return 0;
        }
        (void)((i = (i + 1)));
      }
      return 1;
    }
    return 0;
  }
}
int32_t codegen_func_ret_type_param_extra(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi) {
  {
    if (((((arena ==0) || (module ==0)) || (fi < 0)) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    int32_t ret_ty = pipeline_module_func_return_type_at(module, fi);
    if (((ret_ty <=0) || (pipeline_type_kind_ord_at(arena, ret_ty) !=8))) {
      return 0;
    }
    uint8_t ret_nm[128] = {};
    int32_t ret_nl = pipeline_type_named_name_into(arena, ret_ty, &((ret_nm)[0]));
    if ((ret_nl <=0)) {
      return 0;
    }
    int32_t np = pipeline_module_func_num_params_at(module, fi);
    int32_t pi = 0;
    while ((pi < np)) {
      int32_t pty = pipeline_module_func_param_type_ref_at(module, fi, pi);
      if (((pty > 0) && (pipeline_type_kind_ord_at(arena, pty) ==8))) {
        uint8_t pnm[128] = {};
        int32_t pnl = pipeline_type_named_name_into(arena, pty, &((pnm)[0]));
        if (((pnl ==ret_nl) && (pnl > 0))) {
          int32_t eq = 1;
          int32_t bi = 0;
          while ((bi < pnl)) {
            if (((pnm)[bi] !=(ret_nm)[bi])) {
              (void)((eq = 0));
              (void)((bi = pnl));
            } else {
              (void)((bi = (bi + 1)));
            }
          }
          if ((eq !=0)) {
            return 0;
          }
        }
      }
      (void)((pi = (pi + 1)));
    }
    return 1;
  }
}
int32_t codegen_call_ret_type_param_concrete_at(struct ast_ASTArena * arena, int32_t ei) {
  {
    if (((arena ==0) || (ei <=0))) {
      return 0;
    }
    struct ast_Expr e = ast_ast_arena_expr_get(arena, ei);
    if ((((int32_t)(((e).kind))) !=48)) {
      return 0;
    }
    if ((((e).resolved_type_ref) > 0)) {
      return ((e).resolved_type_ref);
    }
    if ((((e).call_num_type_args) ==1)) {
      int32_t ta = pipeline_expr_call_type_arg_ref_at(arena, ei, 0);
      if ((ta > 0)) {
        return ta;
      }
    }
    return 0;
  }
}
int32_t codegen_collect_mono_combos_for_generic_func(struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t * combos_out, int32_t max_combos, int32_t num_params, int32_t ret_extra) {
  {
    if (((((arena ==0) || (module ==0)) || (fi < 0)) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    int32_t combo_width = (num_params + ret_extra);
    if (((((combos_out ==0) || (max_combos <=0)) || (combo_width <=0)) || (combo_width > 8))) {
      return 0;
    }
    if ((((num_params < 0) || (ret_extra < 0)) || (ret_extra > 1))) {
      return 0;
    }
    uint8_t fn_local[128] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    if ((fn_len <=0)) {
      return 0;
    }
    int32_t combo_count = 0;
    int32_t ei = 1;
    while ((ei <=((arena)->num_exprs))) {
      struct ast_Expr e = ast_ast_arena_expr_get(arena, ei);
      if ((((int32_t)(((e).kind))) ==48)) {
        int32_t matched = 0;
        if ((((e).call_resolved_func_index) ==fi)) {
          (void)((matched = 1));
        } else {
          if (((!(ast_ref_is_null(((e).call_callee_ref))) && (((e).call_callee_ref) > 0)) && (((e).call_callee_ref) <=((arena)->num_exprs)))) {
            struct ast_Expr cal = ast_ast_arena_expr_get(arena, ((e).call_callee_ref));
            if (((((int32_t)(((cal).kind))) ==3) && (((cal).var_name_len) ==fn_len))) {
              int32_t eq = 1;
              int32_t k = 0;
              while ((k < fn_len)) {
                if (((((cal).var_name))[k] !=(fn_local)[k])) {
                  (void)((eq = 0));
                  (void)((k = fn_len));
                } else {
                  (void)((k = (k + 1)));
                }
              }
              (void)((matched = eq));
            }
          }
        }
        if (((matched !=0) && ((num_params ==0) || (((e).call_num_args) >=num_params)))) {
          int32_t combo[8] = {};
          int32_t pi = 0;
          int32_t valid = 1;
          while ((pi < num_params)) {
            int32_t ty = codegen_call_mono_type_at(arena, ei, pi, ((e).call_num_args));
            if ((ty <=0)) {
              (void)((valid = 0));
              (void)((pi = num_params));
            } else {
              (void)(((combo)[pi] = ty));
            }
            (void)((pi = (pi + 1)));
          }
          if (((valid !=0) && (ret_extra !=0))) {
            int32_t rty = codegen_call_ret_type_param_concrete_at(arena, ei);
            if ((rty <=0)) {
              (void)((valid = 0));
            } else {
              (void)(((combo)[num_params] = rty));
            }
          }
          if ((valid !=0)) {
            int32_t found = 0;
            int32_t ci = 0;
            while ((ci < combo_count)) {
              int32_t same = 1;
              int32_t pi2 = 0;
              while ((pi2 < combo_width)) {
                if ((codegen_mono_combo_slot_equal(arena, (combos_out)[((ci * combo_width) + pi2)], (combo)[pi2]) ==0)) {
                  (void)((same = 0));
                  (void)((pi2 = combo_width));
                }
                (void)((pi2 = (pi2 + 1)));
              }
              if ((same !=0)) {
                (void)((found = 1));
                (void)((ci = combo_count));
              }
              (void)((ci = (ci + 1)));
            }
            if (((found ==0) && (combo_count < max_combos))) {
              int32_t pi3 = 0;
              while ((pi3 < combo_width)) {
                (void)(((combos_out)[((combo_count * combo_width) + pi3)] = (combo)[pi3]));
                (void)((pi3 = (pi3 + 1)));
              }
              (void)((combo_count = (combo_count + 1)));
            }
          }
        }
      }
      (void)((ei = (ei + 1)));
    }
    return combo_count;
  }
}
int32_t codegen_try_emit_impl_method_mono_call_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx, struct ast_Module * module, int32_t fi, int32_t receiver_ty) {
  {
    if ((((out ==0) || (arena ==0)) || (module ==0))) {
      return 0;
    }
    if (((fi < 0) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    if ((pipeline_module_func_num_generic_params_at(module, fi) > 0)) {
      return 0;
    }
    if ((receiver_ty <=0)) {
      return 0;
    }
    int32_t np = pipeline_module_func_num_params_at(module, fi);
    if ((np < 1)) {
      return 0;
    }
    int32_t p0_ty_raw = pipeline_module_func_param_type_ref_at(module, fi, 0);
    if ((p0_ty_raw <=0)) {
      return 0;
    }
    int32_t p0_ty = pipeline_typeck_resolve_type_alias_ref_c(arena, p0_ty_raw);
    if ((p0_ty <=0)) {
      return 0;
    }
    if ((pipeline_type_kind_ord_at(arena, p0_ty) !=8)) {
      return 0;
    }
    uint8_t nm[128] = {};
    int32_t nl = pipeline_type_named_name_into(arena, p0_ty, &((nm)[0]));
    if ((nl <=0)) {
      return 0;
    }
    int32_t bare_off = 0;
    int32_t bi = 0;
    while (((bi < nl) && (bi < 64))) {
      if (((nm)[bi] ==46)) {
        (void)((bare_off = (bi + 1)));
      }
      (void)((bi = (bi + 1)));
    }
    int32_t bare_len = (nl - bare_off);
    if ((bare_len <=0)) {
      return 0;
    }
    int32_t lk = codegen_module_struct_layout_index_by_name(module, &((nm)[bare_off]), bare_len);
    if ((lk < 0)) {
      return 0;
    }
    int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, lk);
    if (((ntp <=0) || (ntp > 8))) {
      return 0;
    }
    int32_t mono_chk[8] = {};
    if ((codegen_generic_struct_fill_concrete_args(module, arena, p0_ty, ntp, &((mono_chk)[0]), 0) ==ntp)) {
      return 0;
    }
    int32_t combos[32] = {};
    int32_t nc = codegen_collect_generic_struct_mono_combos(module, arena, lk, &((nm)[bare_off]), bare_len, ntp, &((combos)[0]), 8);
    if ((nc <=1)) {
      return 0;
    }
    int32_t recv_concrete = receiver_ty;
    if (((ctx !=0) && (((ctx)->mono_active) !=0))) {
      (void)((recv_concrete = codegen_mono_subst_type(ctx, arena, recv_concrete)));
    }
    int32_t recv_mono[8] = {};
    if ((codegen_generic_struct_fill_concrete_args(module, arena, recv_concrete, ntp, &((recv_mono)[0]), ctx) !=ntp)) {
      return 0;
    }
    if ((codegen_emit_mono_mangled_name(out, arena, module, fi, &((recv_mono)[0]), ntp) !=0)) {
      return -1;
    }
    return 1;
  }
}
int32_t codegen_emit_mono_mangled_name(struct codegen_CodegenOutBuf * out, struct ast_ASTArena * arena, struct ast_Module * module, int32_t fi, int32_t * mono_tys, int32_t num_mono) {
  {
    if (((((out ==0) || (arena ==0)) || (module ==0)) || (mono_tys ==0))) {
      return -1;
    }
    if ((((fi < 0) || (fi >=((module)->num_funcs))) || (num_mono <=0))) {
      return -1;
    }
    if ((codegen_emit_func_link_name(out, arena, module, fi) !=0)) {
      return -1;
    }
    uint8_t sep[2] = {95, 95};
    if ((codegen_emit_bytes_from_ptr(out, &((sep)[0]), 2) !=0)) {
      return -1;
    }
    int32_t mi = 0;
    while ((mi < num_mono)) {
      uint8_t suf[128] = {};
      int32_t ty = (mono_tys)[mi];
      int32_t sl = codegen_type_ref_to_suffix(arena, ty, &((suf)[0]), 64);
      if ((sl <=0)) {
        return -1;
      }
      if ((mi > 0)) {
        if ((codegen_append_byte(out, 95) !=0)) {
          return -1;
        }
      }
      if ((codegen_emit_bytes_from_ptr(out, &((suf)[0]), sl) !=0)) {
        return -1;
      }
      (void)((mi = (mi + 1)));
    }
    return 0;
  }
}
int32_t codegen_mono_subst_type(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref) {
  {
    if ((((ctx ==0) || (((ctx)->mono_active) ==0)) || (((ctx)->mono_num_types) <=0))) {
      return type_ref;
    }
    int32_t mi = 0;
    while (((mi < ((ctx)->mono_num_types)) && (mi < 8))) {
      if (((type_ref ==(((ctx)->mono_generic_type_refs))[mi]) && ((((ctx)->mono_concrete_type_refs))[mi] > 0))) {
        return (((ctx)->mono_concrete_type_refs))[mi];
      }
      (void)((mi = (mi + 1)));
    }
    uint8_t fb_nm[128] = {};
    int32_t fb_len = pipeline_type_named_name_into(arena, type_ref, &((fb_nm)[0]));
    if ((fb_len > 0)) {
      int32_t mi2 = 0;
      while (((mi2 < ((ctx)->mono_num_types)) && (mi2 < 8))) {
        if (((((ctx)->mono_concrete_type_refs))[mi2] > 0)) {
          uint8_t gnm[128] = {};
          int32_t gname_len = pipeline_type_named_name_into(arena, (((ctx)->mono_generic_type_refs))[mi2], &((gnm)[0]));
          if (((gname_len ==fb_len) && (gname_len > 0))) {
            int32_t names_eq = 1;
            int32_t ci = 0;
            while ((ci < gname_len)) {
              if (((gnm)[ci] !=(fb_nm)[ci])) {
                (void)((names_eq = 0));
                (void)((ci = gname_len));
              } else {
                (void)((ci = (ci + 1)));
              }
            }
            if ((names_eq !=0)) {
              return (((ctx)->mono_concrete_type_refs))[mi2];
            }
          }
        }
        (void)((mi2 = (mi2 + 1)));
      }
    }
    return type_ref;
  }
}
int32_t codegen_find_impl_method_for_type(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * method_name, int32_t method_name_len, int32_t receiver_type_ref) {
  {
    if ((((module ==0) || (arena ==0)) || (method_name ==0))) {
      return -1;
    }
    if (((method_name_len <=0) || (receiver_type_ref <=0))) {
      return -1;
    }
    int32_t fi = 0;
    while ((fi < ((module)->num_funcs))) {
      int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
      if (((fn_len ==method_name_len) && (fn_len > 0))) {
        uint8_t fn_name[128] = {};
        (void)(pipeline_module_func_name_copy64(module, fi, &((fn_name)[0])));
        int32_t matched = 1;
        int32_t bi = 0;
        while ((bi < fn_len)) {
          if (((fn_name)[bi] !=(method_name)[bi])) {
            (void)((matched = 0));
            (void)((bi = fn_len));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((matched !=0)) {
          int32_t np = pipeline_module_func_num_params_at(module, fi);
          if ((np > 0)) {
            int32_t p0_ty = pipeline_module_func_param_type_ref_at(module, fi, 0);
            if ((p0_ty > 0)) {
              if ((pipeline_typeck_type_refs_equal_c(arena, p0_ty, receiver_type_ref) !=0)) {
                return fi;
              }
              uint8_t p0_nm[128] = {};
              int32_t p0_nlen = pipeline_type_named_name_into(arena, p0_ty, &((p0_nm)[0]));
              uint8_t recv_nm[128] = {};
              int32_t recv_nlen = pipeline_type_named_name_into(arena, receiver_type_ref, &((recv_nm)[0]));
              if (((p0_nlen > 0) && (p0_nlen ==recv_nlen))) {
                int32_t neq = 1;
                int32_t ni = 0;
                while ((ni < p0_nlen)) {
                  if (((p0_nm)[ni] !=(recv_nm)[ni])) {
                    (void)((neq = 0));
                    (void)((ni = p0_nlen));
                  } else {
                    (void)((ni = (ni + 1)));
                  }
                }
                if ((neq !=0)) {
                  if (((pipeline_type_kind_ord_at(arena, p0_ty) ==8) && (pipeline_type_kind_ord_at(arena, receiver_type_ref) ==8))) {
                    if ((codegen_type_refs_same_for_mono(arena, p0_ty, receiver_type_ref) !=0)) {
                      return fi;
                    }
                  } else {
                    return fi;
                  }
                }
              }
            }
          }
        }
      }
      (void)((fi = (fi + 1)));
    }
    return -1;
  }
}
int32_t codegen_try_emit_generic_identity_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    if ((((arena ==0) || (out ==0)) || (module ==0))) {
      return 0;
    }
    if (((fi < 0) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    if ((pipeline_module_func_num_generic_params_at(module, fi) <=0)) {
      return 0;
    }
    if ((pipeline_module_func_is_extern_at(module, fi) !=0)) {
      return 0;
    }
    int32_t num_params = pipeline_module_func_num_params_at(module, fi);
    if (((num_params < 0) || (num_params > 8))) {
      return 0;
    }
    int32_t ret_ty = pipeline_module_func_return_type_at(module, fi);
    int32_t p0_ty = pipeline_module_func_param_type_ref_at(module, fi, 0);
    int32_t ret_extra_zp = codegen_func_ret_type_param_extra(arena, module, fi);
    if (((num_params ==0) && (ret_extra_zp ==0))) {
      if ((ret_ty <=0)) {
        return 0;
      }
      uint8_t fn_local0[128] = {};
      (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local0)[0])));
      int32_t fn_len0 = pipeline_module_func_name_len_at(module, fi);
      if ((fn_len0 <=0)) {
        return 0;
      }
      int32_t has_call = 0;
      int32_t ei0 = 1;
      while ((ei0 <=((arena)->num_exprs))) {
        struct ast_Expr e0 = ast_ast_arena_expr_get(arena, ei0);
        if ((((int32_t)(((e0).kind))) ==48)) {
          int32_t matched0 = 0;
          if ((((e0).call_resolved_func_index) ==fi)) {
            (void)((matched0 = 1));
          } else {
            if (((!(ast_ref_is_null(((e0).call_callee_ref))) && (((e0).call_callee_ref) > 0)) && (((e0).call_callee_ref) <=((arena)->num_exprs)))) {
              struct ast_Expr cal0 = ast_ast_arena_expr_get(arena, ((e0).call_callee_ref));
              if (((((int32_t)(((cal0).kind))) ==3) && (((cal0).var_name_len) ==fn_len0))) {
                int32_t eq0 = 1;
                int32_t k0 = 0;
                while ((k0 < fn_len0)) {
                  if (((((cal0).var_name))[k0] !=(fn_local0)[k0])) {
                    (void)((eq0 = 0));
                    (void)((k0 = fn_len0));
                  } else {
                    (void)((k0 = (k0 + 1)));
                  }
                }
                (void)((matched0 = eq0));
              }
            }
          }
          if ((matched0 !=0)) {
            (void)((has_call = 1));
            (void)((ei0 = ((arena)->num_exprs)));
          }
        }
        (void)((ei0 = (ei0 + 1)));
      }
      if ((has_call ==0)) {
        return 0;
      }
      int32_t mono_sym_pre0 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
      int32_t saved_func_index0 = -1;
      int32_t saved_block_ref0 = 0;
      int32_t saved_mono_active0 = 0;
      int32_t saved_mono_num0 = 0;
      int32_t ctx_set0 = 0;
      if ((ctx !=0)) {
        (void)((saved_func_index0 = ((ctx)->current_func_index)));
        (void)((saved_block_ref0 = ((ctx)->current_block_ref)));
        (void)((saved_mono_active0 = ((ctx)->mono_active)));
        (void)((saved_mono_num0 = ((ctx)->mono_num_types)));
        (void)((((ctx)->current_func_index) = fi));
        int32_t ret_ord0 = pipeline_type_kind_ord_at(arena, ret_ty);
        if ((ret_ord0 ==8)) {
          int32_t ta0 = 0;
          int32_t ei_ta = 1;
          while (((ei_ta <=((arena)->num_exprs)) && (ta0 <=0))) {
            struct ast_Expr e_ta = ast_ast_arena_expr_get(arena, ei_ta);
            if (((((int32_t)(((e_ta).kind))) ==48) && (((e_ta).call_resolved_func_index) ==fi))) {
              (void)((ta0 = codegen_call_ret_type_param_concrete_at(arena, ei_ta)));
            }
            (void)((ei_ta = (ei_ta + 1)));
          }
          if ((ta0 <=0)) {
            (void)((ei_ta = 1));
            while (((ei_ta <=((arena)->num_exprs)) && (ta0 <=0))) {
              struct ast_Expr e_ta2 = ast_ast_arena_expr_get(arena, ei_ta);
              if (((((int32_t)(((e_ta2).kind))) ==48) && (((e_ta2).call_resolved_func_index) !=fi))) {
                if (((!(ast_ref_is_null(((e_ta2).call_callee_ref))) && (((e_ta2).call_callee_ref) > 0)) && (((e_ta2).call_callee_ref) <=((arena)->num_exprs)))) {
                  struct ast_Expr cal_ta = ast_ast_arena_expr_get(arena, ((e_ta2).call_callee_ref));
                  if (((((int32_t)(((cal_ta).kind))) ==3) && (((cal_ta).var_name_len) ==fn_len0))) {
                    int32_t eq_ta = 1;
                    int32_t k_ta = 0;
                    while ((k_ta < fn_len0)) {
                      if (((((cal_ta).var_name))[k_ta] !=(fn_local0)[k_ta])) {
                        (void)((eq_ta = 0));
                        (void)((k_ta = fn_len0));
                      } else {
                        (void)((k_ta = (k_ta + 1)));
                      }
                    }
                    if ((eq_ta !=0)) {
                      (void)((ta0 = codegen_call_ret_type_param_concrete_at(arena, ei_ta)));
                    }
                  }
                }
              }
              (void)((ei_ta = (ei_ta + 1)));
            }
          }
          if (((ta0 > 0) && (ta0 !=ret_ty))) {
            (void)((((ctx)->mono_active) = 1));
            (void)((((ctx)->mono_num_types) = 1));
            (void)(((((ctx)->mono_generic_type_refs))[0] = ret_ty));
            (void)(((((ctx)->mono_concrete_type_refs))[0] = ta0));
          }
        }
        (void)((ctx_set0 = 1));
      }
      if ((codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) !=0)) {
        if ((ctx_set0 !=0)) {
          (void)((((ctx)->current_func_index) = saved_func_index0));
          (void)((((ctx)->current_block_ref) = saved_block_ref0));
          (void)((((ctx)->mono_active) = saved_mono_active0));
          (void)((((ctx)->mono_num_types) = saved_mono_num0));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        if ((ctx_set0 !=0)) {
          (void)((((ctx)->current_func_index) = saved_func_index0));
          (void)((((ctx)->current_block_ref) = saved_block_ref0));
          (void)((((ctx)->mono_active) = saved_mono_active0));
          (void)((((ctx)->mono_num_types) = saved_mono_num0));
        }
        return -1;
      }
      if (((mono_sym_pre0 > 0) && (codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre0, &((fn_local0)[0]), fn_len0) ==0))) {
        if ((codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre0) !=0)) {
          if ((ctx_set0 !=0)) {
            (void)((((ctx)->current_func_index) = saved_func_index0));
            (void)((((ctx)->current_block_ref) = saved_block_ref0));
            (void)((((ctx)->mono_active) = saved_mono_active0));
            (void)((((ctx)->mono_num_types) = saved_mono_num0));
          }
          return -1;
        }
      }
      if ((codegen_emit_func_link_name(out, arena, module, fi) !=0)) {
        if ((ctx_set0 !=0)) {
          (void)((((ctx)->current_func_index) = saved_func_index0));
          (void)((((ctx)->current_block_ref) = saved_block_ref0));
          (void)((((ctx)->mono_active) = saved_mono_active0));
          (void)((((ctx)->mono_num_types) = saved_mono_num0));
        }
        return -1;
      }
      uint8_t open0[4] = {40, 41, 32, 123};
      if ((codegen_emit_bytes_from_ptr(out, &((open0)[0]), 4) !=0)) {
        if ((ctx_set0 !=0)) {
          (void)((((ctx)->current_func_index) = saved_func_index0));
          (void)((((ctx)->current_block_ref) = saved_block_ref0));
          (void)((((ctx)->mono_active) = saved_mono_active0));
          (void)((((ctx)->mono_num_types) = saved_mono_num0));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 10) !=0)) {
        if ((ctx_set0 !=0)) {
          (void)((((ctx)->current_func_index) = saved_func_index0));
          (void)((((ctx)->current_block_ref) = saved_block_ref0));
          (void)((((ctx)->mono_active) = saved_mono_active0));
          (void)((((ctx)->mono_num_types) = saved_mono_num0));
        }
        return -1;
      }
      int32_t body_walked0 = 0;
      int32_t body_br0 = pipeline_module_func_body_ref_at(module, fi);
      int32_t body_er0 = pipeline_module_func_body_expr_ref_at(module, fi);
      if ((!(ast_ref_is_null(body_br0)) || !(ast_ref_is_null(body_er0)))) {
        if (!(ast_ref_is_null(body_br0))) {
          if ((ctx_set0 !=0)) {
            (void)((((ctx)->current_block_ref) = body_br0));
          }
          if ((codegen_emit_block(arena, out, body_br0, 2, ctx) ==0)) {
            (void)((body_walked0 = 1));
          }
        } else {
          if ((ctx_set0 !=0)) {
            (void)((((ctx)->current_block_ref) = 0));
          }
          if ((codegen_emit_indent(out, 2) ==0)) {
            uint8_t ret_kw0[8] = {114, 101, 116, 117, 114, 110, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((ret_kw0)[0]), 7) ==0)) {
              if ((codegen_emit_expr(arena, out, body_er0, ctx) ==0)) {
                uint8_t sc_nl0[2] = {59, 10};
                if ((codegen_emit_bytes_from_ptr(out, &((sc_nl0)[0]), 2) ==0)) {
                  (void)((body_walked0 = 1));
                }
              }
            }
          }
        }
      }
      if ((body_walked0 ==0)) {
        if ((codegen_emit_indent(out, 2) !=0)) {
          if ((ctx_set0 !=0)) {
            (void)((((ctx)->current_func_index) = saved_func_index0));
            (void)((((ctx)->current_block_ref) = saved_block_ref0));
            (void)((((ctx)->mono_active) = saved_mono_active0));
            (void)((((ctx)->mono_num_types) = saved_mono_num0));
          }
          return -1;
        }
        uint8_t ret0z[10] = {114, 101, 116, 117, 114, 110, 32, 48, 59, 10};
        if ((codegen_emit_bytes_from_ptr(out, &((ret0z)[0]), 10) !=0)) {
          if ((ctx_set0 !=0)) {
            (void)((((ctx)->current_func_index) = saved_func_index0));
            (void)((((ctx)->current_block_ref) = saved_block_ref0));
            (void)((((ctx)->mono_active) = saved_mono_active0));
            (void)((((ctx)->mono_num_types) = saved_mono_num0));
          }
          return -1;
        }
      }
      if ((ctx_set0 !=0)) {
        (void)((((ctx)->current_func_index) = saved_func_index0));
        (void)((((ctx)->current_block_ref) = saved_block_ref0));
        (void)((((ctx)->mono_active) = saved_mono_active0));
        (void)((((ctx)->mono_num_types) = saved_mono_num0));
      }
      uint8_t end0[2] = {125, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((end0)[0]), 2) !=0)) {
        return -1;
      }
      return 1;
    }
    if ((ret_ty <=0)) {
      return 0;
    }
    if (((num_params > 0) && (p0_ty <=0))) {
      return 0;
    }
    int32_t is_identity_shape = 0;
    if ((((num_params > 0) && (pipeline_type_kind_ord_at(arena, ret_ty) ==8)) && (pipeline_type_kind_ord_at(arena, p0_ty) ==8))) {
      uint8_t ret_nm[128] = {};
      uint8_t p0_nm[128] = {};
      int32_t ret_nl = pipeline_type_named_name_into(arena, ret_ty, &((ret_nm)[0]));
      int32_t p0_nl = pipeline_type_named_name_into(arena, p0_ty, &((p0_nm)[0]));
      if (((ret_nl > 0) && (ret_nl ==p0_nl))) {
        int32_t bi = 0;
        int32_t names_eq = 1;
        while ((bi < ret_nl)) {
          if (((ret_nm)[bi] !=(p0_nm)[bi])) {
            (void)((names_eq = 0));
            (void)((bi = ret_nl));
          } else {
            (void)((bi = (bi + 1)));
          }
        }
        if ((names_eq !=0)) {
          (void)((is_identity_shape = 1));
        }
      }
    }
    int32_t ret_extra = ret_extra_zp;
    int32_t combo_width = (num_params + ret_extra);
    if (((combo_width <=0) || (combo_width > 8))) {
      return 0;
    }
    int32_t combos[128] = {};
    int32_t combo_count = codegen_collect_mono_combos_for_generic_func(arena, module, fi, &((combos)[0]), 16, num_params, ret_extra);
    if ((combo_count <=0)) {
      return 0;
    }
    int32_t pn_len = 1;
    uint8_t pn[128] = {};
    (void)(((pn)[0] = 120));
    if ((num_params > 0)) {
      (void)((pn_len = pipeline_module_func_param_name_len_at(module, fi, 0)));
      (void)(pipeline_module_func_param_name_copy32(module, fi, 0, &((pn)[0])));
      if ((pn_len <=0)) {
        (void)(((pn)[0] = 120));
        (void)((pn_len = 1));
      }
    }
    uint8_t fn_local[128] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    int32_t mono_sym_pre = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    int32_t ci = 0;
    while ((ci < combo_count)) {
      int32_t saved_mono_active = 0;
      int32_t saved_mono_num = 0;
      int32_t saved_func_index = -1;
      int32_t saved_block_ref = 0;
      int32_t mono_ctx_set = 0;
      if ((ctx !=0)) {
        (void)((saved_mono_active = ((ctx)->mono_active)));
        (void)((saved_mono_num = ((ctx)->mono_num_types)));
        (void)((saved_func_index = ((ctx)->current_func_index)));
        (void)((saved_block_ref = ((ctx)->current_block_ref)));
        (void)((((ctx)->mono_active) = 1));
        (void)((((ctx)->mono_num_types) = 0));
        int32_t sti0 = 0;
        while (((sti0 < num_params) && (sti0 < 8))) {
          (void)(((((ctx)->mono_generic_type_refs))[sti0] = pipeline_module_func_param_type_ref_at(module, fi, sti0)));
          (void)(((((ctx)->mono_concrete_type_refs))[sti0] = (combos)[((ci * combo_width) + sti0)]));
          (void)((sti0 = (sti0 + 1)));
        }
        (void)((((ctx)->mono_num_types) = num_params));
        (void)(({   int32_t peel_src = 0;
  int32_t peel_n0 = ((ctx)->mono_num_types);
  while (((peel_src < peel_n0) && (((ctx)->mono_num_types) < 8))) {
    int32_t gwalk = (((ctx)->mono_generic_type_refs))[peel_src];
    int32_t cwalk = (((ctx)->mono_concrete_type_refs))[peel_src];
    int32_t pdepth = 0;
    while (((((gwalk > 0) && (cwalk > 0)) && (pdepth < 4)) && (((ctx)->mono_num_types) < 8))) {
      int32_t gk = pipeline_type_kind_ord_at(arena, gwalk);
      int32_t ck = pipeline_type_kind_ord_at(arena, cwalk);
      if ((gk !=ck)) {
        (void)((pdepth = 4));
      } else {
        if (((((gk ==9) || (gk ==11)) || (gk ==10)) || (gk ==13))) {
          int32_t ge = pipeline_type_elem_ref_at(arena, gwalk);
          int32_t ce = pipeline_type_elem_ref_at(arena, cwalk);
          if (((ge <=0) || (ce <=0))) {
            (void)((pdepth = 4));
          } else {
            if ((pipeline_type_kind_ord_at(arena, ge) ==8)) {
              int32_t dup_p = 0;
              int32_t di_p = 0;
              while ((di_p < ((ctx)->mono_num_types))) {
                if (((((ctx)->mono_generic_type_refs))[di_p] ==ge)) {
                  (void)((dup_p = 1));
                  (void)((di_p = ((ctx)->mono_num_types)));
                } else {
                  (void)((di_p = (di_p + 1)));
                }
              }
              if (((dup_p ==0) && (((ctx)->mono_num_types) < 8))) {
                (void)(((((ctx)->mono_generic_type_refs))[((ctx)->mono_num_types)] = ge));
                (void)(((((ctx)->mono_concrete_type_refs))[((ctx)->mono_num_types)] = ce));
                (void)((((ctx)->mono_num_types) = (((ctx)->mono_num_types) + 1)));
              }
              (void)((gwalk = ge));
              (void)((cwalk = ce));
              (void)((pdepth = (pdepth + 1)));
            } else {
              int32_t dup_mid = 0;
              int32_t di_mid = 0;
              while ((di_mid < ((ctx)->mono_num_types))) {
                if (((((ctx)->mono_generic_type_refs))[di_mid] ==ge)) {
                  (void)((dup_mid = 1));
                  (void)((di_mid = ((ctx)->mono_num_types)));
                } else {
                  (void)((di_mid = (di_mid + 1)));
                }
              }
              if (((dup_mid ==0) && (((ctx)->mono_num_types) < 8))) {
                (void)(((((ctx)->mono_generic_type_refs))[((ctx)->mono_num_types)] = ge));
                (void)(((((ctx)->mono_concrete_type_refs))[((ctx)->mono_num_types)] = ce));
                (void)((((ctx)->mono_num_types) = (((ctx)->mono_num_types) + 1)));
              }
              (void)((gwalk = ge));
              (void)((cwalk = ce));
              (void)((pdepth = (pdepth + 1)));
            }
          }
        } else {
          (void)((pdepth = 4));
        }
      }
    }
    (void)((peel_src = (peel_src + 1)));
  }
 }));
        if (((ret_extra !=0) && (((ctx)->mono_num_types) < 8))) {
          int32_t ta_conc = (combos)[((ci * combo_width) + num_params)];
          if (((ta_conc > 0) && (ta_conc !=ret_ty))) {
            (void)(((((ctx)->mono_generic_type_refs))[((ctx)->mono_num_types)] = ret_ty));
            (void)(((((ctx)->mono_concrete_type_refs))[((ctx)->mono_num_types)] = ta_conc));
            (void)((((ctx)->mono_num_types) = (((ctx)->mono_num_types) + 1)));
          }
        }
        (void)((((ctx)->current_func_index) = fi));
        (void)((mono_ctx_set = 1));
      }
      if ((codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if (((mono_sym_pre > 0) && (codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &((fn_local)[0]), fn_len) ==0))) {
        if ((codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
      }
      if ((codegen_emit_mono_mangled_name(out, arena, module, fi, &((combos)[(ci * combo_width)]), combo_width) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((num_params > 0)) {
        if ((codegen_emit_type(arena, out, p0_ty, prefix, prefix_len, ctx) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        if ((pipeline_type_kind_ord_at(arena, p0_ty) ==11)) {
          if ((codegen_append_byte(out, 32) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          if ((codegen_append_byte(out, 42) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        if ((codegen_emit_bytes_from_ptr(out, &((pn)[0]), pn_len) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        int32_t pi = 1;
        while ((pi < num_params)) {
          int32_t p_ty = pipeline_module_func_param_type_ref_at(module, fi, pi);
          uint8_t comma_space[2] = {44, 32};
          if ((codegen_emit_bytes_from_ptr(out, &((comma_space)[0]), 2) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          if (((p_ty <=0) || (codegen_emit_type(arena, out, p_ty, prefix, prefix_len, ctx) !=0))) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          if (((p_ty > 0) && (pipeline_type_kind_ord_at(arena, p_ty) ==11))) {
            if ((codegen_append_byte(out, 32) !=0)) {
              if ((mono_ctx_set !=0)) {
                (void)((((ctx)->mono_active) = saved_mono_active));
                (void)((((ctx)->mono_num_types) = saved_mono_num));
                (void)((((ctx)->current_func_index) = saved_func_index));
                (void)((((ctx)->current_block_ref) = saved_block_ref));
              }
              return -1;
            }
            if ((codegen_append_byte(out, 42) !=0)) {
              if ((mono_ctx_set !=0)) {
                (void)((((ctx)->mono_active) = saved_mono_active));
                (void)((((ctx)->mono_num_types) = saved_mono_num));
                (void)((((ctx)->current_func_index) = saved_func_index));
                (void)((((ctx)->current_block_ref) = saved_block_ref));
              }
              return -1;
            }
          }
          if ((codegen_append_byte(out, 32) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          int32_t pni_len = pipeline_module_func_param_name_len_at(module, fi, pi);
          uint8_t pni[128] = {};
          (void)(pipeline_module_func_param_name_copy32(module, fi, pi, &((pni)[0])));
          if ((pni_len <=0)) {
            (void)(((pni)[0] = 120));
            (void)((pni_len = 1));
          }
          if ((codegen_emit_bytes_from_ptr(out, &((pni)[0]), pni_len) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          (void)((pi = (pi + 1)));
        }
      }
      uint8_t open_body[4] = {41, 32, 123, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((open_body)[0]), 4) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      int32_t body_walked = 0;
      int32_t body_br = pipeline_module_func_body_ref_at(module, fi);
      int32_t body_er = pipeline_module_func_body_expr_ref_at(module, fi);
      if (((mono_ctx_set !=0) && (!(ast_ref_is_null(body_br)) || !(ast_ref_is_null(body_er))))) {
        if (!(ast_ref_is_null(body_br))) {
          (void)((((ctx)->current_block_ref) = body_br));
          if ((codegen_emit_block(arena, out, body_br, 2, ctx) ==0)) {
            (void)((body_walked = 1));
          }
        } else {
          (void)((((ctx)->current_block_ref) = 0));
          if ((codegen_emit_indent(out, 2) ==0)) {
            uint8_t ret_kw2[8] = {114, 101, 116, 117, 114, 110, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((ret_kw2)[0]), 7) ==0)) {
              if ((codegen_emit_expr(arena, out, body_er, ctx) ==0)) {
                uint8_t sc_nl[2] = {59, 10};
                if ((codegen_emit_bytes_from_ptr(out, &((sc_nl)[0]), 2) ==0)) {
                  (void)((body_walked = 1));
                }
              }
            }
          }
        }
      }
      if ((body_walked ==0)) {
        if ((is_identity_shape !=0)) {
          if ((codegen_emit_indent(out, 2) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          uint8_t ret_kw[8] = {114, 101, 116, 117, 114, 110, 32, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 7) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          if ((codegen_emit_bytes_from_ptr(out, &((pn)[0]), pn_len) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          uint8_t semi_nl[2] = {59, 10};
          if ((codegen_emit_bytes_from_ptr(out, &((semi_nl)[0]), 2) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
        } else {
          if ((codegen_emit_indent(out, 2) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          uint8_t ret0[12] = {114, 101, 116, 117, 114, 110, 32, 48, 59, 10, 0, 0};
          if ((codegen_emit_bytes_from_ptr(out, &((ret0)[0]), 10) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
        }
      }
      if ((mono_ctx_set !=0)) {
        (void)((((ctx)->mono_active) = saved_mono_active));
        (void)((((ctx)->mono_num_types) = saved_mono_num));
        (void)((((ctx)->current_func_index) = saved_func_index));
        (void)((((ctx)->current_block_ref) = saved_block_ref));
      }
      uint8_t end[2] = {125, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((end)[0]), 2) !=0)) {
        return -1;
      }
      (void)((ci = (ci + 1)));
    }
    return 1;
  }
}
int32_t codegen_try_emit_generic_impl_method_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    if ((((arena ==0) || (out ==0)) || (module ==0))) {
      return 0;
    }
    if (((fi < 0) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    if ((pipeline_module_func_num_generic_params_at(module, fi) > 0)) {
      return 0;
    }
    if ((pipeline_module_func_is_extern_at(module, fi) !=0)) {
      return 0;
    }
    int32_t num_params = pipeline_module_func_num_params_at(module, fi);
    if (((num_params < 0) || (num_params > 8))) {
      return 0;
    }
    int32_t ret_ty = pipeline_module_func_return_type_at(module, fi);
    if ((ret_ty <=0)) {
      return 0;
    }
    int32_t p = 0;
    int32_t found_lk = -1;
    int32_t found_pty = 0;
    int32_t found_ntp = 0;
    uint8_t found_nm[128] = {};
    int32_t found_bare_off = 0;
    int32_t found_bare_len = 0;
    while ((p < num_params)) {
      int32_t pty_raw = pipeline_module_func_param_type_ref_at(module, fi, p);
      if ((pty_raw <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t pty = pipeline_typeck_resolve_type_alias_ref_c(arena, pty_raw);
      if ((pty <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      if ((pipeline_type_kind_ord_at(arena, pty) !=8)) {
        (void)((p = (p + 1)));
        continue;
      }
      uint8_t nm[128] = {};
      int32_t nl = pipeline_type_named_name_into(arena, pty, &((nm)[0]));
      if ((nl <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t bare_off = 0;
      int32_t bi = 0;
      while (((bi < nl) && (bi < 64))) {
        if (((nm)[bi] ==46)) {
          (void)((bare_off = (bi + 1)));
        }
        (void)((bi = (bi + 1)));
      }
      int32_t bare_len = (nl - bare_off);
      if ((bare_len <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t lk = codegen_module_struct_layout_index_by_name(module, &((nm)[bare_off]), bare_len);
      if ((lk < 0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if ((ntp <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t mono_chk[4] = {};
      if ((codegen_generic_struct_fill_concrete_args(module, arena, pty, ntp, &((mono_chk)[0]), 0) ==ntp)) {
        (void)((p = (p + 1)));
        continue;
      }
      (void)((found_lk = lk));
      (void)((found_pty = pty));
      (void)((found_ntp = ntp));
      int32_t cp_i = 0;
      while (((cp_i < nl) && (cp_i < 64))) {
        (void)(((found_nm)[cp_i] = (nm)[cp_i]));
        (void)((cp_i = (cp_i + 1)));
      }
      (void)((found_bare_off = bare_off));
      (void)((found_bare_len = bare_len));
      (void)((p = num_params));
    }
    if ((found_lk < 0)) {
      return 0;
    }
    int32_t combos[32] = {};
    int32_t nc = codegen_collect_generic_struct_mono_combos(module, arena, found_lk, &((found_nm)[found_bare_off]), found_bare_len, found_ntp, &((combos)[0]), 8);
    if ((nc <=1)) {
      return 0;
    }
    uint8_t fn_local[128] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    int32_t mono_sym_pre = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    int32_t ci = 0;
    while ((ci < nc)) {
      int32_t saved_mono_active = 0;
      int32_t saved_mono_num = 0;
      int32_t saved_func_index = -1;
      int32_t saved_block_ref = 0;
      int32_t mono_ctx_set = 0;
      if ((ctx !=0)) {
        (void)((saved_mono_active = ((ctx)->mono_active)));
        (void)((saved_mono_num = ((ctx)->mono_num_types)));
        (void)((saved_func_index = ((ctx)->current_func_index)));
        (void)((saved_block_ref = ((ctx)->current_block_ref)));
        (void)((((ctx)->mono_active) = 1));
        (void)((((ctx)->mono_num_types) = 0));
        int32_t tj = 0;
        while (((tj < found_ntp) && (tj < 8))) {
          int32_t formal_arg = pipeline_type_type_arg_ref_at(arena, found_pty, tj);
          int32_t concrete_arg = (combos)[((ci * found_ntp) + tj)];
          if (((formal_arg > 0) && (concrete_arg > 0))) {
            (void)(((((ctx)->mono_generic_type_refs))[((ctx)->mono_num_types)] = formal_arg));
            (void)(((((ctx)->mono_concrete_type_refs))[((ctx)->mono_num_types)] = concrete_arg));
            (void)((((ctx)->mono_num_types) = (((ctx)->mono_num_types) + 1)));
          }
          (void)((tj = (tj + 1)));
        }
        (void)((((ctx)->current_func_index) = fi));
        (void)((mono_ctx_set = 1));
      }
      if ((codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if (((mono_sym_pre > 0) && (codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &((fn_local)[0]), fn_len) ==0))) {
        if ((codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
      }
      if ((codegen_emit_mono_mangled_name(out, arena, module, fi, &((combos)[(ci * found_ntp)]), found_ntp) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      int32_t pi = 0;
      while ((pi < num_params)) {
        if ((pi > 0)) {
          uint8_t cs[2] = {44, 32};
          if ((codegen_emit_bytes_from_ptr(out, &((cs)[0]), 2) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
        }
        int32_t p_ty = pipeline_module_func_param_type_ref_at(module, fi, pi);
        if ((codegen_emit_type(arena, out, p_ty, prefix, prefix_len, ctx) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        uint8_t pname[128] = {};
        int32_t plen = pipeline_module_func_param_name_len_at(module, fi, pi);
        (void)(pipeline_module_func_param_name_copy32(module, fi, pi, &((pname)[0])));
        if ((plen <=0)) {
          (void)(((pname)[0] = 95));
          (void)((plen = 1));
        }
        if ((codegen_emit_bytes_from_ptr(out, &((pname)[0]), plen) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        (void)((pi = (pi + 1)));
      }
      uint8_t open_body[4] = {41, 32, 123, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((open_body)[0]), 4) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      int32_t body_walked = 0;
      int32_t body_br = pipeline_module_func_body_ref_at(module, fi);
      int32_t body_er = pipeline_module_func_body_expr_ref_at(module, fi);
      if ((!(ast_ref_is_null(body_br)) || !(ast_ref_is_null(body_er)))) {
        if (!(ast_ref_is_null(body_br))) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->current_block_ref) = body_br));
          }
          if ((codegen_emit_block(arena, out, body_br, 2, ctx) ==0)) {
            (void)((body_walked = 1));
          }
        } else {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->current_block_ref) = 0));
          }
          if ((codegen_emit_indent(out, 2) ==0)) {
            uint8_t ret_kw[8] = {114, 101, 116, 117, 114, 110, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((ret_kw)[0]), 7) ==0)) {
              if ((codegen_emit_expr(arena, out, body_er, ctx) ==0)) {
                uint8_t sc_nl[2] = {59, 10};
                if ((codegen_emit_bytes_from_ptr(out, &((sc_nl)[0]), 2) ==0)) {
                  (void)((body_walked = 1));
                }
              }
            }
          }
        }
      }
      if ((body_walked ==0)) {
        if ((codegen_emit_indent(out, 2) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        uint8_t ret0[10] = {114, 101, 116, 117, 114, 110, 32, 48, 59, 10};
        if ((codegen_emit_bytes_from_ptr(out, &((ret0)[0]), 10) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
      }
      if ((mono_ctx_set !=0)) {
        (void)((((ctx)->mono_active) = saved_mono_active));
        (void)((((ctx)->mono_num_types) = saved_mono_num));
        (void)((((ctx)->current_func_index) = saved_func_index));
        (void)((((ctx)->current_block_ref) = saved_block_ref));
      }
      uint8_t end[2] = {125, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((end)[0]), 2) !=0)) {
        return -1;
      }
      (void)((ci = (ci + 1)));
    }
    return 1;
  }
}
int32_t codegen_try_emit_generic_impl_method_extern_mono(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    if ((((arena ==0) || (out ==0)) || (module ==0))) {
      return 0;
    }
    if (((fi < 0) || (fi >=((module)->num_funcs)))) {
      return 0;
    }
    if ((pipeline_module_func_num_generic_params_at(module, fi) > 0)) {
      return 0;
    }
    int32_t num_params = pipeline_module_func_num_params_at(module, fi);
    if (((num_params < 0) || (num_params > 8))) {
      return 0;
    }
    int32_t ret_ty = pipeline_module_func_return_type_at(module, fi);
    if ((ret_ty <=0)) {
      return 0;
    }
    int32_t p = 0;
    int32_t found_lk = -1;
    int32_t found_pty = 0;
    int32_t found_ntp = 0;
    uint8_t found_nm[128] = {};
    int32_t found_bare_off = 0;
    int32_t found_bare_len = 0;
    while ((p < num_params)) {
      int32_t pty_raw = pipeline_module_func_param_type_ref_at(module, fi, p);
      if ((pty_raw <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t pty = pipeline_typeck_resolve_type_alias_ref_c(arena, pty_raw);
      if ((pty <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      if ((pipeline_type_kind_ord_at(arena, pty) !=8)) {
        (void)((p = (p + 1)));
        continue;
      }
      uint8_t nm[128] = {};
      int32_t nl = pipeline_type_named_name_into(arena, pty, &((nm)[0]));
      if ((nl <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t bare_off = 0;
      int32_t bi = 0;
      while (((bi < nl) && (bi < 64))) {
        if (((nm)[bi] ==46)) {
          (void)((bare_off = (bi + 1)));
        }
        (void)((bi = (bi + 1)));
      }
      int32_t bare_len = (nl - bare_off);
      if ((bare_len <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t lk = codegen_module_struct_layout_index_by_name(module, &((nm)[bare_off]), bare_len);
      if ((lk < 0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t ntp = pipeline_module_struct_layout_num_type_params_at(module, lk);
      if ((ntp <=0)) {
        (void)((p = (p + 1)));
        continue;
      }
      int32_t mono_chk[4] = {};
      if ((codegen_generic_struct_fill_concrete_args(module, arena, pty, ntp, &((mono_chk)[0]), 0) ==ntp)) {
        (void)((p = (p + 1)));
        continue;
      }
      (void)((found_lk = lk));
      (void)((found_pty = pty));
      (void)((found_ntp = ntp));
      int32_t cp_i = 0;
      while (((cp_i < nl) && (cp_i < 64))) {
        (void)(((found_nm)[cp_i] = (nm)[cp_i]));
        (void)((cp_i = (cp_i + 1)));
      }
      (void)((found_bare_off = bare_off));
      (void)((found_bare_len = bare_len));
      (void)((p = num_params));
    }
    if ((found_lk < 0)) {
      return 0;
    }
    int32_t combos[32] = {};
    int32_t nc = codegen_collect_generic_struct_mono_combos(module, arena, found_lk, &((found_nm)[found_bare_off]), found_bare_len, found_ntp, &((combos)[0]), 8);
    if ((nc <=1)) {
      return 0;
    }
    uint8_t fn_local[128] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    int32_t mono_sym_pre = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    int32_t ci = 0;
    while ((ci < nc)) {
      int32_t saved_mono_active = 0;
      int32_t saved_mono_num = 0;
      int32_t saved_func_index = -1;
      int32_t saved_block_ref = 0;
      int32_t mono_ctx_set = 0;
      if ((ctx !=0)) {
        (void)((saved_mono_active = ((ctx)->mono_active)));
        (void)((saved_mono_num = ((ctx)->mono_num_types)));
        (void)((saved_func_index = ((ctx)->current_func_index)));
        (void)((saved_block_ref = ((ctx)->current_block_ref)));
        (void)((((ctx)->mono_active) = 1));
        (void)((((ctx)->mono_num_types) = 0));
        int32_t tj = 0;
        while (((tj < found_ntp) && (tj < 8))) {
          int32_t formal_arg = pipeline_type_type_arg_ref_at(arena, found_pty, tj);
          int32_t concrete_arg = (combos)[((ci * found_ntp) + tj)];
          if (((formal_arg > 0) && (concrete_arg > 0))) {
            (void)(((((ctx)->mono_generic_type_refs))[((ctx)->mono_num_types)] = formal_arg));
            (void)(((((ctx)->mono_concrete_type_refs))[((ctx)->mono_num_types)] = concrete_arg));
            (void)((((ctx)->mono_num_types) = (((ctx)->mono_num_types) + 1)));
          }
          (void)((tj = (tj + 1)));
        }
        (void)((((ctx)->current_func_index) = fi));
        (void)((mono_ctx_set = 1));
      }
      uint8_t kw[8] = {101, 120, 116, 101, 114, 110, 32, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((kw)[0]), 7) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((codegen_emit_type(arena, out, ret_ty, prefix, prefix_len, ctx) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 32) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if (((mono_sym_pre > 0) && (codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &((fn_local)[0]), fn_len) ==0))) {
        if ((codegen_emit_bytes_from_ptr(out, prefix, mono_sym_pre) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
      }
      if ((codegen_emit_mono_mangled_name(out, arena, module, fi, &((combos)[(ci * found_ntp)]), found_ntp) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((codegen_append_byte(out, 40) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      int32_t pi = 0;
      while ((pi < num_params)) {
        if ((pi > 0)) {
          uint8_t cs[2] = {44, 32};
          if ((codegen_emit_bytes_from_ptr(out, &((cs)[0]), 2) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
        }
        int32_t p_ty = pipeline_module_func_param_type_ref_at(module, fi, pi);
        if ((codegen_emit_type(arena, out, p_ty, prefix, prefix_len, ctx) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        if ((pipeline_type_kind_ord_at(arena, p_ty) ==11)) {
          if ((codegen_append_byte(out, 32) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
          if ((codegen_append_byte(out, 42) !=0)) {
            if ((mono_ctx_set !=0)) {
              (void)((((ctx)->mono_active) = saved_mono_active));
              (void)((((ctx)->mono_num_types) = saved_mono_num));
              (void)((((ctx)->current_func_index) = saved_func_index));
              (void)((((ctx)->current_block_ref) = saved_block_ref));
            }
            return -1;
          }
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        uint8_t pname[128] = {};
        int32_t plen = pipeline_module_func_param_name_len_at(module, fi, pi);
        (void)(pipeline_module_func_param_name_copy32(module, fi, pi, &((pname)[0])));
        if ((plen <=0)) {
          (void)(((pname)[0] = 95));
          (void)((plen = 1));
        }
        if ((codegen_emit_bytes_from_ptr(out, &((pname)[0]), plen) !=0)) {
          if ((mono_ctx_set !=0)) {
            (void)((((ctx)->mono_active) = saved_mono_active));
            (void)((((ctx)->mono_num_types) = saved_mono_num));
            (void)((((ctx)->current_func_index) = saved_func_index));
            (void)((((ctx)->current_block_ref) = saved_block_ref));
          }
          return -1;
        }
        (void)((pi = (pi + 1)));
      }
      uint8_t end_proto[3] = {41, 59, 10};
      if ((codegen_emit_bytes_from_ptr(out, &((end_proto)[0]), 3) !=0)) {
        if ((mono_ctx_set !=0)) {
          (void)((((ctx)->mono_active) = saved_mono_active));
          (void)((((ctx)->mono_num_types) = saved_mono_num));
          (void)((((ctx)->current_func_index) = saved_func_index));
          (void)((((ctx)->current_block_ref) = saved_block_ref));
        }
        return -1;
      }
      if ((mono_ctx_set !=0)) {
        (void)((((ctx)->mono_active) = saved_mono_active));
        (void)((((ctx)->mono_num_types) = saved_mono_num));
        (void)((((ctx)->current_func_index) = saved_func_index));
        (void)((((ctx)->current_block_ref) = saved_block_ref));
      }
      (void)((ci = (ci + 1)));
    }
    return 1;
  }
}
int32_t codegen_emit_func_extern_declaration(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_Module * module, int32_t fi, uint8_t * prefix, int32_t prefix_len, struct ast_PipelineDepCtx * ctx) {
  {
    if (((fi < 0) || (fi >=((module)->num_funcs)))) {
      return -1;
    }
    if ((pipeline_module_func_num_generic_params_at(module, fi) > 0)) {
      return 0;
    }
    int32_t w498_ext_rc = codegen_try_emit_generic_impl_method_extern_mono(arena, out, module, fi, prefix, prefix_len, ctx);
    if ((w498_ext_rc < 0)) {
      return -1;
    }
    if ((w498_ext_rc > 0)) {
      return 0;
    }
    uint8_t fn_local[128] = {};
    (void)(codegen_copy_func_name64_from_module(module, fi, &((fn_local)[0])));
    int32_t fn_len = pipeline_module_func_name_len_at(module, fi);
    if (((pipeline_module_func_is_extern_at(module, fi) !=0) && (codegen_is_libc_conflicting_extern_name(&((fn_local)[0]), fn_len) !=0))) {
      return 0;
    }
    uint8_t kw[8] = {101, 120, 116, 101, 114, 110, 32, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((kw)[0]), 7) !=0)) {
      return -1;
    }
    if ((pipeline_module_func_is_used_at(module, fi) !=0)) {
      uint8_t used_attr[27] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((used_attr)[0]), 22) !=0)) {
        return -1;
      }
    }
    if ((pipeline_module_func_is_naked_at(module, fi) !=0)) {
      uint8_t naked_attr[29] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((naked_attr)[0]), 23) !=0)) {
        return -1;
      }
    }
    if ((pipeline_module_func_is_entry_at(module, fi) !=0)) {
      uint8_t entry_attr[30] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((entry_attr)[0]), 26) !=0)) {
        return -1;
      }
    }
    if ((pipeline_module_func_is_interrupt_at(module, fi) !=0)) {
      uint8_t int_attr[31] = {95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((int_attr)[0]), 27) !=0)) {
        return -1;
      }
    }
    int32_t w495_mono_set = 0;
    int32_t w495_saved_active = 0;
    int32_t w495_saved_num = 0;
    if ((ctx !=0)) {
      int32_t w495_gen[8] = {};
      int32_t w495_conc[8] = {};
      int32_t w495_n = codegen_build_func_param_mono_map(module, arena, fi, &((w495_gen)[0]), &((w495_conc)[0]), 8);
      if ((w495_n > 0)) {
        (void)((w495_saved_active = ((ctx)->mono_active)));
        (void)((w495_saved_num = ((ctx)->mono_num_types)));
        int32_t w495_k = 0;
        while (((w495_k < w495_n) && (w495_k < 8))) {
          (void)(((((ctx)->mono_generic_type_refs))[w495_k] = (w495_gen)[w495_k]));
          (void)(((((ctx)->mono_concrete_type_refs))[w495_k] = (w495_conc)[w495_k]));
          (void)((w495_k = (w495_k + 1)));
        }
        (void)((((ctx)->mono_active) = 1));
        (void)((((ctx)->mono_num_types) = w495_n));
        (void)((w495_mono_set = 1));
      }
    }
    /* PLATFORM: SHARED — process entry ABI: void main → int32_t main (Zig-like).
     * Mirror emit_func's emit_c_main_symbol logic so the extern forward
     * declaration matches the definition's return type. Without this,
     * `extern void main(void);` conflicts with `int32_t main(void) {`
     * (BLD001 conflicting types for main). is_entry mirrors emit_func's
     * (fi == module.main_func_index) || (module.num_funcs == 1). */
    int32_t ext_ret_ty_ref = pipeline_module_func_return_type_at(module, fi);
    int ext_name_is_main = (((((fn_len ==4) && ((fn_local)[0] ==109)) && ((fn_local)[1] ==97)) && ((fn_local)[2] ==105)) && ((fn_local)[3] ==110));
    int ext_is_entry = ((fi == ((module)->main_func_index)) || (((module)->num_funcs) ==1));
    int ext_emit_c_main = 0;
    if ((ext_is_entry && ext_name_is_main)) {
      (void)((ext_emit_c_main = 1));
    }
    if ((ext_emit_c_main && (pipeline_type_kind_ord_at(arena, ext_ret_ty_ref) ==16))) {
      uint8_t i32_ty[8] = {105, 110, 116, 51, 50, 95, 116, 0};
      if ((codegen_emit_bytes_8(out, &((i32_ty)[0]), 7) !=0)) {
        return -1;
      }
    } else if ((codegen_emit_type(arena, out, ext_ret_ty_ref, prefix, prefix_len, ctx) !=0)) {
      return -1;
    }
    if ((codegen_append_byte(out, 32) !=0)) {
      return -1;
    }
    int32_t name_prefix_len = prefix_len;
    if ((pipeline_module_func_is_extern_at(module, fi) !=0)) {
      int _starts_with_prefix = 0;
      if (((prefix_len > 0) && (fn_len >=prefix_len))) {
        int32_t _k = 0;
        (void)((_starts_with_prefix = 1));
        while ((_k < prefix_len)) {
          if (((fn_local)[_k] !=(prefix)[_k])) {
            (void)((_starts_with_prefix = 0));
            break;
          }
          (void)((_k = (_k + 1)));
        }
      }
      if (!(_starts_with_prefix)) {
        (void)((name_prefix_len = 0));
      }
    }
    (void)((name_prefix_len = codegen_func_c_symbol_prefix_len(module, fi, name_prefix_len)));
    if ((((name_prefix_len > 0) && (codegen_c_prefix_redundant_with_name(prefix, name_prefix_len, &((fn_local)[0]), fn_len) ==0)) && (codegen_emit_bytes_from_ptr(out, prefix, name_prefix_len) !=0))) {
      return -1;
    }
    if ((codegen_emit_func_link_name(out, arena, module, fi) !=0)) {
      return -1;
    }
    if ((codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &((fn_local)[0]), fn_len) !=0)) {
      uint8_t impl_suffix[6] = {95, 105, 109, 112, 108, 0};
      if ((codegen_emit_bytes_from_ptr(out, &((impl_suffix)[0]), 5) !=0)) {
        return -1;
      }
    }
    uint8_t lpar[2] = {40, 0};
    if ((codegen_emit_bytes_2(out, &((lpar)[0]), 1) !=0)) {
      return -1;
    }
    if ((pipeline_module_func_num_params_at(module, fi) ==0)) {
      uint8_t v[7] = {118, 111, 105, 100, 0, 0, 0};
      if ((codegen_emit_bytes_7(out, &((v)[0]), 4) !=0)) {
        return -1;
      }
    } else {
      int32_t p = 0;
      while ((p < pipeline_module_func_num_params_at(module, fi))) {
        if ((p > 0)) {
          uint8_t comma[3] = {44, 32, 0};
          if ((codegen_emit_bytes_3(out, &((comma)[0]), 2) !=0)) {
            return -1;
          }
        }
        if ((codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
          uint8_t size_t_buf2[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
          if ((codegen_emit_bytes_32(out, &((size_t_buf2)[0]), 7) !=0)) {
            return -1;
          }
        } else {
          if ((codegen_force_param_size_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
            uint8_t size_t_buf[32] = {115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            if ((codegen_emit_bytes_32(out, &((size_t_buf)[0]), 7) !=0)) {
              return -1;
            }
          } else {
            if ((codegen_force_param_ptrdiff_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
              uint8_t ptrdiff_t_buf[32] = {112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
              if ((codegen_emit_bytes_32(out, &((ptrdiff_t_buf)[0]), 10) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_force_param_uint32_t(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                uint8_t u32_buf[32] = {117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
                if ((codegen_emit_bytes_32(out, &((u32_buf)[0]), 9) !=0)) {
                  return -1;
                }
              } else {
                if ((codegen_force_param_i32(prefix, prefix_len, &((fn_local)[0]), fn_len, p) !=0)) {
                  uint8_t i32_str[8] = {105, 110, 116, 51, 50, 95, 116, 0};
                  if ((codegen_emit_bytes_8(out, &((i32_str)[0]), 7) !=0)) {
                    return -1;
                  }
                } else {
                  if ((codegen_emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) !=0)) {
                    return -1;
                  }
                }
              }
            }
          }
        }
        if ((pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) ==11)) {
          if ((codegen_append_byte(out, 32) !=0)) {
            return -1;
          }
          if ((codegen_append_byte(out, 42) !=0)) {
            return -1;
          }
        }
        if ((codegen_append_byte(out, 32) !=0)) {
          return -1;
        }
        if ((pipeline_module_func_param_name_len_at(module, fi, p) > 0)) {
          uint8_t plocal[128] = {};
          (void)(codegen_copy_param_name32_from_module(module, fi, p, &((plocal)[0])));
          if ((((plocal)[0] > 32) && (codegen_emit_bytes_from_ptr(out, &((plocal)[0]), pipeline_module_func_param_name_len_at(module, fi, p)) !=0))) {
            return -1;
          }
        } else {
          uint8_t place[4] = {95, 112, 48, 0};
          if ((codegen_emit_bytes_4(out, &((place)[0]), 2) !=0)) {
            return -1;
          }
          if ((codegen_format_int(out, p) !=0)) {
            return -1;
          }
        }
        (void)((p = (p + 1)));
      }
    }
    if (((pipeline_module_func_is_variadic_at(module, fi) !=0) && (pipeline_module_func_num_params_at(module, fi) > 0))) {
      uint8_t ellipsis[5] = {44, 32, 46, 46, 46};
      if ((codegen_emit_bytes_from_ptr(out, &((ellipsis)[0]), 5) !=0)) {
        return -1;
      }
    }
    uint8_t end_proto[3] = {41, 59, 10};
    if ((codegen_emit_bytes_from_ptr(out, &((end_proto)[0]), 3) !=0)) {
      return -1;
    }
    if ((w495_mono_set !=0)) {
      (void)((((ctx)->mono_active) = w495_saved_active));
      (void)((((ctx)->mono_num_types) = w495_saved_num));
    }
    return 0;
  }
}
int32_t codegen_emit_import_dep_function_declarations(struct ast_Module * module, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx) {
  {
    if ((((module ==0) || (out ==0)) || (ctx ==0))) {
      return 0;
    }
    struct ast_Module * saved_module = ((ctx)->current_codegen_module);
    struct ast_ASTArena * saved_arena = ((ctx)->current_codegen_arena);
    int32_t saved_dep_index = ((ctx)->current_codegen_dep_index);
    int32_t saved_prefix_len = ((ctx)->current_codegen_prefix_len);
    uint8_t saved_prefix[128] = {};
    int32_t sp = 0;
    while ((sp < 64)) {
      (void)(((saved_prefix)[sp] = (((ctx)->current_codegen_prefix_mirror))[sp]));
      (void)((sp = (sp + 1)));
    }
    int32_t n_imp = codegen_module_num_imports(module);
    int32_t imp_i = 0;
    while ((imp_i < n_imp)) {
      uint8_t dep_path[128] = {};
      int32_t dep_path_len = codegen_module_import_path_len_at(module, imp_i, &((dep_path)[0]));
      if ((dep_path_len > 0)) {
        int32_t seen_before = 0;
        int32_t prev_i = 0;
        while ((prev_i < imp_i)) {
          uint8_t prev_path[128] = {};
          int32_t prev_len = codegen_module_import_path_len_at(module, prev_i, &((prev_path)[0]));
          if ((prev_len ==dep_path_len)) {
            int eq_prev = 1;
            int32_t pk = 0;
            while (((pk < dep_path_len) && (pk < 64))) {
              if (((prev_path)[pk] !=(dep_path)[pk])) {
                (void)((eq_prev = 0));
                break;
              }
              (void)((pk = (pk + 1)));
            }
            if (eq_prev) {
              (void)((seen_before = 1));
              break;
            }
          }
          (void)((prev_i = (prev_i + 1)));
        }
        if ((seen_before ==0)) {
          int32_t dep_ix = codegen_find_dep_index_by_path(ctx, &((dep_path)[0]), dep_path_len);
          struct ast_Module * dep_mod = 0;
          struct ast_ASTArena * dep_arena = 0;
          int32_t dep_ctx_ix = dep_ix;
          if (((dep_ix >=0) && (dep_ix < pipeline_dep_ctx_ndep(ctx)))) {
            (void)((dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix)));
            (void)((dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix)));
          }
          if ((((dep_mod ==0) || (dep_arena ==0)) && (dep_path_len > 0))) {
            int32_t global_slot = codegen_find_seeded_global_dep_slot_by_path(&((dep_path)[0]), dep_path_len);
            if ((global_slot >=0)) {
              (void)((dep_mod = ((struct ast_Module *)(driver_dep_module_buf(global_slot)))));
              (void)((dep_arena = ((struct ast_ASTArena *)(driver_dep_arena_buf(global_slot)))));
              (void)((dep_ctx_ix = -1));
            }
          }
          if ((((dep_mod !=0) && (dep_arena !=0)) && (((dep_mod)->num_funcs) > 0))) {
            uint8_t prefix_buf[128] = {};
            int32_t prefix_len = 0;
            if ((codegen_path_is_std_io_core_bytes(&((dep_path)[0])) ==0)) {
              (void)(codegen_import_path_to_c_prefix_into(&((dep_path)[0]), &((prefix_buf)[0]), 128));
              while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
                (void)((prefix_len = (prefix_len + 1)));
              }
            }
            (void)((((ctx)->current_codegen_module) = dep_mod));
            (void)((((ctx)->current_codegen_arena) = dep_arena));
            (void)((((ctx)->current_codegen_dep_index) = dep_ctx_ix));
            (void)((((ctx)->current_codegen_prefix_len) = 0));
            int32_t px = 0;
            while (((px < prefix_len) && (px < 63))) {
              (void)(((((ctx)->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
              (void)((px = (px + 1)));
            }
            (void)(((((ctx)->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
            (void)((((ctx)->current_codegen_prefix_len) = px));
            int32_t fi = 0;
            while ((fi < ((dep_mod)->num_funcs))) {
              if ((codegen_emit_func_extern_declaration(dep_arena, out, dep_mod, fi, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
                return -1;
              }
              (void)((fi = (fi + 1)));
            }
          }
        }
      }
      (void)((imp_i = (imp_i + 1)));
    }
    (void)((((ctx)->current_codegen_module) = saved_module));
    (void)((((ctx)->current_codegen_arena) = saved_arena));
    (void)((((ctx)->current_codegen_dep_index) = saved_dep_index));
    (void)((((ctx)->current_codegen_prefix_len) = saved_prefix_len));
    (void)((sp = 0));
    while ((sp < 64)) {
      (void)(((((ctx)->current_codegen_prefix_mirror))[sp] = (saved_prefix)[sp]));
      (void)((sp = (sp + 1)));
    }
    return 0;
  }
}
int32_t codegen_x_ast_emit_header(struct codegen_CodegenOutBuf * out) {
  {
    uint8_t h[64] = {35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 105, 110, 116, 46, 104, 62, 10, 35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 100, 101, 102, 46, 104, 62, 10, 35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 121, 115, 47, 116, 121, 112, 101, 115, 46, 104, 62, 10, 0};
    if ((codegen_emit_bytes_64(out, &((h)[0]), 63) !=0)) {
      return -1;
    }
    uint8_t g0[64] = {35, 105, 102, 110, 100, 101, 102, 32, 88, 76, 65, 78, 71, 95, 83, 76, 73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 10, 35, 100, 101, 102, 105, 110, 101, 32, 88, 76, 65, 78, 71, 95, 83, 76, 73, 67, 69, 95, 76, 65, 89, 79, 85, 84, 83, 10, 0};
    if ((codegen_emit_bytes_64(out, &((g0)[0]), 56) !=0)) {
      return -1;
    }
    uint8_t s0[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s0)[0]), 62) !=0)) {
      return -1;
    }
    uint8_t s1[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s1)[0]), 60) !=0)) {
      return -1;
    }
    uint8_t s2[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s2)[0]), 62) !=0)) {
      return -1;
    }
    uint8_t s3[65] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s3)[0]), 64) !=0)) {
      return -1;
    }
    uint8_t s4[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s4)[0]), 54) !=0)) {
      return -1;
    }
    uint8_t s5[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s5)[0]), 62) !=0)) {
      return -1;
    }
    uint8_t s6[65] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s6)[0]), 64) !=0)) {
      return -1;
    }
    uint8_t s7[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s7)[0]), 62) !=0)) {
      return -1;
    }
    uint8_t s8[65] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s8)[0]), 64) !=0)) {
      return -1;
    }
    uint8_t s9[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s9)[0]), 60) !=0)) {
      return -1;
    }
    uint8_t s10[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s10)[0]), 62) !=0)) {
      return -1;
    }
    uint8_t s11[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s11)[0]), 58) !=0)) {
      return -1;
    }
    uint8_t s12[64] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_64(out, &((s12)[0]), 60) !=0)) {
      return -1;
    }
    uint8_t n0[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n0)[0]), 93) !=0)) {
      return -1;
    }
    uint8_t n1[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n1)[0]), 91) !=0)) {
      return -1;
    }
    uint8_t n2[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n2)[0]), 93) !=0)) {
      return -1;
    }
    uint8_t n3[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n3)[0]), 95) !=0)) {
      return -1;
    }
    uint8_t n4[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n4)[0]), 85) !=0)) {
      return -1;
    }
    uint8_t n5[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n5)[0]), 93) !=0)) {
      return -1;
    }
    uint8_t n6[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n6)[0]), 95) !=0)) {
      return -1;
    }
    uint8_t n7[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n7)[0]), 93) !=0)) {
      return -1;
    }
    uint8_t n8[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n8)[0]), 95) !=0)) {
      return -1;
    }
    uint8_t n9[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n9)[0]), 91) !=0)) {
      return -1;
    }
    uint8_t n10[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n10)[0]), 93) !=0)) {
      return -1;
    }
    uint8_t n11[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n11)[0]), 89) !=0)) {
      return -1;
    }
    uint8_t n12[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((n12)[0]), 91) !=0)) {
      return -1;
    }
    uint8_t t0[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t0)[0]), 117) !=0)) {
      return -1;
    }
    uint8_t t1[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t1)[0]), 115) !=0)) {
      return -1;
    }
    uint8_t t2[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t2)[0]), 117) !=0)) {
      return -1;
    }
    uint8_t t3[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t3)[0]), 119) !=0)) {
      return -1;
    }
    uint8_t t4[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t4)[0]), 109) !=0)) {
      return -1;
    }
    uint8_t t5[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t5)[0]), 117) !=0)) {
      return -1;
    }
    uint8_t t6[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t6)[0]), 119) !=0)) {
      return -1;
    }
    uint8_t t7[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t7)[0]), 117) !=0)) {
      return -1;
    }
    uint8_t t8[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t8)[0]), 119) !=0)) {
      return -1;
    }
    uint8_t t9[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t9)[0]), 115) !=0)) {
      return -1;
    }
    uint8_t t10[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t10)[0]), 117) !=0)) {
      return -1;
    }
    uint8_t t11[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t11)[0]), 113) !=0)) {
      return -1;
    }
    uint8_t t12[128] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t12)[0]), 115) !=0)) {
      return -1;
    }
    uint8_t q0[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q0)[0]), 141) !=0)) {
      return -1;
    }
    uint8_t q1[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q1)[0]), 139) !=0)) {
      return -1;
    }
    uint8_t q2[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q2)[0]), 141) !=0)) {
      return -1;
    }
    uint8_t q3[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q3)[0]), 143) !=0)) {
      return -1;
    }
    uint8_t q4[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q4)[0]), 133) !=0)) {
      return -1;
    }
    uint8_t q5[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q5)[0]), 141) !=0)) {
      return -1;
    }
    uint8_t q6[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q6)[0]), 143) !=0)) {
      return -1;
    }
    uint8_t q7[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q7)[0]), 141) !=0)) {
      return -(1);
    }
    uint8_t q8[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q8)[0]), 143) !=0)) {
      return -(1);
    }
    uint8_t q9[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q9)[0]), 139) !=0)) {
      return -(1);
    }
    uint8_t q10[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q10)[0]), 141) !=0)) {
      return -(1);
    }
    uint8_t q11[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q11)[0]), 137) !=0)) {
      return -(1);
    }
    uint8_t q12[160] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((q12)[0]), 139) !=0)) {
      return -(1);
    }
    uint8_t p0[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p0)[0]), 165) !=0)) {
      return -(1);
    }
    uint8_t p1[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p1)[0]), 163) !=0)) {
      return -(1);
    }
    uint8_t p2[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p2)[0]), 165) !=0)) {
      return -(1);
    }
    uint8_t p3[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p3)[0]), 167) !=0)) {
      return -(1);
    }
    uint8_t p4[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p4)[0]), 157) !=0)) {
      return -(1);
    }
    uint8_t p5[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p5)[0]), 165) !=0)) {
      return -(1);
    }
    uint8_t p6[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p6)[0]), 167) !=0)) {
      return -(1);
    }
    uint8_t p7[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p7)[0]), 165) !=0)) {
      return -(1);
    }
    uint8_t p8[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p8)[0]), 167) !=0)) {
      return -(1);
    }
    uint8_t p9[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p9)[0]), 163) !=0)) {
      return -(1);
    }
    uint8_t p10[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p10)[0]), 165) !=0)) {
      return -(1);
    }
    uint8_t p11[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p11)[0]), 161) !=0)) {
      return -(1);
    }
    uint8_t p12[192] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((p12)[0]), 163) !=0)) {
      return -(1);
    }
    uint8_t r0[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r0)[0]), 189) !=0)) {
      return -(1);
    }
    uint8_t r1[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r1)[0]), 187) !=0)) {
      return -(1);
    }
    uint8_t r2[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r2)[0]), 189) !=0)) {
      return -(1);
    }
    uint8_t r3[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r3)[0]), 191) !=0)) {
      return -(1);
    }
    uint8_t r4[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r4)[0]), 181) !=0)) {
      return -(1);
    }
    uint8_t r5[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r5)[0]), 189) !=0)) {
      return -(1);
    }
    uint8_t r6[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r6)[0]), 191) !=0)) {
      return -(1);
    }
    uint8_t r7[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r7)[0]), 189) !=0)) {
      return -(1);
    }
    uint8_t r8[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r8)[0]), 191) !=0)) {
      return -(1);
    }
    uint8_t r9[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r9)[0]), 187) !=0)) {
      return -(1);
    }
    uint8_t r10[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r10)[0]), 189) !=0)) {
      return -(1);
    }
    uint8_t r11[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r11)[0]), 185) !=0)) {
      return -(1);
    }
    uint8_t r12[224] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((r12)[0]), 187) !=0)) {
      return -(1);
    }
    uint8_t s0_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s0_n7)[0]), 213) !=0)) {
      return -(1);
    }
    uint8_t s1_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s1_n7)[0]), 211) !=0)) {
      return -(1);
    }
    uint8_t s2_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s2_n7)[0]), 213) !=0)) {
      return -(1);
    }
    uint8_t s3_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s3_n7)[0]), 215) !=0)) {
      return -(1);
    }
    uint8_t s4_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s4_n7)[0]), 205) !=0)) {
      return -(1);
    }
    uint8_t s5_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s5_n7)[0]), 213) !=0)) {
      return -(1);
    }
    uint8_t s6_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s6_n7)[0]), 215) !=0)) {
      return -(1);
    }
    uint8_t s7_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s7_n7)[0]), 213) !=0)) {
      return -(1);
    }
    uint8_t s8_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s8_n7)[0]), 215) !=0)) {
      return -(1);
    }
    uint8_t s9_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s9_n7)[0]), 211) !=0)) {
      return -(1);
    }
    uint8_t s10_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s10_n7)[0]), 213) !=0)) {
      return -(1);
    }
    uint8_t s11_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s11_n7)[0]), 209) !=0)) {
      return -(1);
    }
    uint8_t s12_n7[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((s12_n7)[0]), 211) !=0)) {
      return -(1);
    }
    uint8_t t0_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t0_n8)[0]), 237) !=0)) {
      return -(1);
    }
    uint8_t t1_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 56, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t1_n8)[0]), 235) !=0)) {
      return -(1);
    }
    uint8_t t2_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t2_n8)[0]), 237) !=0)) {
      return -(1);
    }
    uint8_t t3_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 49, 54, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t3_n8)[0]), 239) !=0)) {
      return -(1);
    }
    uint8_t t4_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t4_n8)[0]), 229) !=0)) {
      return -(1);
    }
    uint8_t t5_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t5_n8)[0]), 237) !=0)) {
      return -(1);
    }
    uint8_t t6_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 51, 50, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t6_n8)[0]), 239) !=0)) {
      return -(1);
    }
    uint8_t t7_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t7_n8)[0]), 237) !=0)) {
      return -(1);
    }
    uint8_t t8_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 117, 105, 110, 116, 54, 52, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t8_n8)[0]), 239) !=0)) {
      return -(1);
    }
    uint8_t t9_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t9_n8)[0]), 235) !=0)) {
      return -(1);
    }
    uint8_t t10_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 115, 115, 105, 122, 101, 95, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t10_n8)[0]), 237) !=0)) {
      return -(1);
    }
    uint8_t t11_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 102, 108, 111, 97, 116, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t11_n8)[0]), 233) !=0)) {
      return -(1);
    }
    uint8_t t12_n8[256] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 123, 32, 115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 120, 108, 97, 110, 103, 95, 115, 108, 105, 99, 101, 95, 100, 111, 117, 98, 108, 101, 32, 42, 100, 97, 116, 97, 59, 32, 115, 105, 122, 101, 95, 116, 32, 108, 101, 110, 103, 116, 104, 59, 32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    if ((codegen_emit_bytes_from_ptr(out, &((t12_n8)[0]), 235) !=0)) {
      return -(1);
    }
    uint8_t ge[8] = {35, 101, 110, 100, 105, 102, 10, 0};
    if ((codegen_emit_bytes_64(out, &((ge)[0]), 7) !=0)) {
      return -(1);
    }
    return 0;
  }
}
extern int32_t pipeline_codegen_std_dep_link_only(uint8_t * path);
int32_t codegen_x_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index) {
  {
    if ((ctx !=0)) {
      (void)((((ctx)->current_codegen_module) = module));
      (void)((((ctx)->current_codegen_arena) = arena));
      (void)((((ctx)->current_codegen_dep_index) = dep_index));
    }
    uint8_t prefix_buf[128] = {};
    int32_t prefix_len = 0;
    uint8_t dep_path_prefix[128] = {};
    int32_t dep_path_prefix_len = 0;
    if (((dep_index >=0) && (ctx !=0))) {
      (void)((dep_path_prefix_len = codegen_dep_import_path_len_at(ctx, dep_index, &((dep_path_prefix)[0]))));
      if (((dep_path_prefix_len > 0) && (pipeline_codegen_std_dep_link_only(&((dep_path_prefix)[0])) !=0))) {
        return 0;
      }
    }
    if ((((dep_index >=0) && (ctx !=0)) && (dep_path_prefix_len > 0))) {
      if ((codegen_path_is_std_io_core_bytes(&((dep_path_prefix)[0])) ==0)) {
        (void)(codegen_import_path_to_c_prefix_into(&((dep_path_prefix)[0]), &((prefix_buf)[0]), 128));
        while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
          (void)((prefix_len = (prefix_len + 1)));
        }
      }
    }
    if (((prefix_len ==0) && (((dep_index < 0) || (dep_path_prefix_len ==0)) || (codegen_path_is_std_io_core_bytes(&((dep_path_prefix)[0])) ==0)))) {
      (void)((prefix_len = 0));
      (void)(((prefix_buf)[0] = ((uint8_t)(0))));
      if ((dep_path_prefix_len > 0)) {
        (void)(codegen_import_path_to_c_prefix_into(&((dep_path_prefix)[0]), &((prefix_buf)[0]), 128));
        while (((prefix_len < 128) && ((prefix_buf)[prefix_len] !=0))) {
          (void)((prefix_len = (prefix_len + 1)));
        }
      }
    }
    if ((((prefix_len ==0) && (dep_index < 0)) && (ctx !=0))) {
      if ((((ctx)->entry_module_import_path_len) > 0)) {
        int32_t pi = 0;
        while (((pi < ((ctx)->entry_module_import_path_len)) && (pi < 127))) {
          (void)(((prefix_buf)[pi] = (((ctx)->entry_module_import_path_mirror))[pi]));
          (void)((pi = (pi + 1)));
        }
        (void)(((prefix_buf)[pi] = ((uint8_t)(0))));
        (void)((prefix_len = pi));
      }
    }
    if ((ctx !=0)) {
      (void)((((ctx)->current_codegen_prefix_len) = 0));
      int32_t px = 0;
      while (((px < prefix_len) && (px < 63))) {
        (void)(((((ctx)->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
        (void)((px = (px + 1)));
      }
      (void)(((((ctx)->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
      (void)((((ctx)->current_codegen_prefix_len) = px));
    }
    int32_t call_init_globals = 0;
    if ((((module)->num_top_level_lets) > 0)) {
      int32_t ti = 0;
      while ((ti < ((module)->num_top_level_lets))) {
        if ((pipeline_module_top_level_let_is_const(module, ti) ==0)) {
          (void)((call_init_globals = 1));
          break;
        }
        (void)((ti = (ti + 1)));
      }
    }
    int32_t i = 0;
    while ((i < ((module)->num_funcs))) {
      if ((i ==0)) {
        if ((pipeline_codegen_c_file_prologue_done_get() ==0)) {
          if ((codegen_x_ast_emit_header(out) !=0)) {
            return -1;
          }
          if ((codegen_emit_skipped_dep_type_definitions(ctx, out) !=0)) {
            return -1;
          }
          if ((ctx !=0)) {
            (void)((((ctx)->current_codegen_module) = module));
            (void)((((ctx)->current_codegen_arena) = arena));
          }
          if ((codegen_emit_dep_struct_forward_declarations(ctx, out) !=0)) {
            return -1;
          }
          (void)(pipeline_codegen_c_file_prologue_done_set(1));
        }
        if ((codegen_emit_import_dep_function_declarations(module, out, ctx) !=0)) {
          return -1;
        }
        if ((dep_index < 0)) {
          if ((codegen_emit_module_enum_definitions(module, out, &((prefix_buf)[0]), prefix_len) !=0)) {
            return -1;
          }
          if ((codegen_emit_module_struct_definitions(module, arena, out, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
            return -1;
          }
        }
        int32_t fwd_fi = 0;
        while ((fwd_fi < ((module)->num_funcs))) {
          if ((pipeline_module_func_is_extern_at(module, fwd_fi) ==0)) {
            if ((codegen_emit_func_extern_declaration(arena, out, module, fwd_fi, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
              return -1;
            }
          }
          (void)((fwd_fi = (fwd_fi + 1)));
        }
        if ((((module)->num_top_level_lets) > 0)) {
          int32_t ti = 0;
          while ((ti < ((module)->num_top_level_lets))) {
            int32_t is_const = pipeline_module_top_level_let_is_const(module, ti);
            int32_t name_len = pipeline_module_top_level_let_name_len(module, ti);
            if (((name_len <=0) || (name_len > 127))) {
              (void)((ti = (ti + 1)));
              continue;
            }
            uint8_t tl_name_buf[128] = {};
            int32_t tni = 0;
            while (((tni < name_len) && (tni < 64))) {
              (void)(((tl_name_buf)[tni] = pipeline_module_top_level_let_name_byte_at(module, ti, tni)));
              (void)((tni = (tni + 1)));
            }
            int32_t tl_ty = pipeline_module_top_level_let_type_ref(module, ti);
            int32_t tl_init = pipeline_module_top_level_let_init_ref(module, ti);
            int32_t is_fixed_arr = 0;
            if ((!(ast_ref_is_null(tl_ty)) && (pipeline_type_kind_ord_at(arena, tl_ty) ==10))) {
              (void)((is_fixed_arr = 1));
            }
            uint8_t undef_kw[8] = {35, 117, 110, 100, 101, 102, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((undef_kw)[0]), 7) !=0)) {
              return -1;
            }
            if ((codegen_emit_bytes_from_ptr(out, &((tl_name_buf)[0]), name_len) !=0)) {
              return -1;
            }
            if ((codegen_append_byte(out, 10) !=0)) {
              return -1;
            }
            if ((is_const !=0)) {
              uint8_t static_const[15] = {115, 116, 97, 116, 105, 99, 32, 99, 111, 110, 115, 116, 32, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((static_const)[0]), 13) !=0)) {
                return -1;
              }
            } else {
              uint8_t static_[9] = {115, 116, 97, 116, 105, 99, 32, 0, 0};
              if ((codegen_emit_bytes_from_ptr(out, &((static_)[0]), 7) !=0)) {
                return -1;
              }
            }
            if ((is_fixed_arr !=0)) {
              if ((codegen_emit_local_fixed_array_elem_type(arena, out, tl_ty, ctx) !=0)) {
                return -1;
              }
            } else {
              if ((codegen_emit_type(arena, out, tl_ty, &((prefix_buf)[0]), 0, ctx) !=0)) {
                return -1;
              }
            }
            if ((codegen_append_byte(out, 32) !=0)) {
              return -1;
            }
            if ((codegen_emit_bytes_from_ptr(out, &((tl_name_buf)[0]), name_len) !=0)) {
              return -1;
            }
            if ((is_fixed_arr !=0)) {
              if ((codegen_emit_local_fixed_array_suffix(arena, out, tl_ty) !=0)) {
                return -1;
              }
            }
            int32_t want_decl_init = 0;
            if (((is_fixed_arr !=0) && !(ast_ref_is_null(tl_init)))) {
              if ((pipeline_expr_kind_ord_at(arena, tl_init) ==46)) {
                if ((pipeline_expr_array_lit_num_elems_at(arena, tl_init) > 0)) {
                  (void)((want_decl_init = 1));
                }
              } else {
                (void)((want_decl_init = 1));
              }
            }
            if ((((is_const !=0) && (is_fixed_arr ==0)) && !(ast_ref_is_null(tl_init)))) {
              (void)((want_decl_init = 1));
            }
            if ((((is_const ==0) && (is_fixed_arr ==0)) && !(ast_ref_is_null(tl_init)))) {
              if ((pipeline_expr_is_c_static_const_init(arena, tl_init) !=0)) {
                (void)((want_decl_init = 1));
              }
            }
            if ((want_decl_init !=0)) {
              uint8_t eq[4] = {32, 61, 32, 0};
              if ((codegen_emit_bytes_4(out, &((eq)[0]), 3) !=0)) {
                return -1;
              }
              if ((is_fixed_arr !=0)) {
                if ((codegen_emit_braced_array_lit_init(arena, out, tl_init, ctx) !=0)) {
                  return -1;
                }
              } else {
                if ((codegen_emit_expr(arena, out, tl_init, ctx) !=0)) {
                  return -1;
                }
              }
            }
            uint8_t sc[3] = {59, 10, 0};
            if ((codegen_emit_bytes_3(out, &((sc)[0]), 2) !=0)) {
              return -1;
            }
            (void)((ti = (ti + 1)));
          }
          int32_t any_let = 0;
          (void)((ti = 0));
          while ((ti < ((module)->num_top_level_lets))) {
            if ((pipeline_module_top_level_let_is_const(module, ti) ==0)) {
              (void)((any_let = 1));
              break;
            }
            (void)((ti = (ti + 1)));
          }
          if ((((dep_index < 0) && (any_let ==0)) && (((module)->main_func_index) >=0))) {
            int32_t dep_scan_i = 0;
            int32_t dep_ndep = pipeline_dep_ctx_ndep(ctx);
            while ((dep_scan_i < dep_ndep)) {
              uint8_t scan_path[128] = {};
              int32_t scan_plen = codegen_dep_import_path_len_at(ctx, dep_scan_i, &((scan_path)[0]));
              if (((scan_plen > 0) && (pipeline_codegen_std_dep_link_only(&((scan_path)[0])) !=0))) {
                (void)((dep_scan_i = (dep_scan_i + 1)));
                continue;
              }
              struct ast_Module * dep_scan_mod = pipeline_dep_ctx_module_at(ctx, dep_scan_i);
              if ((dep_scan_mod !=0)) {
                int32_t dep_ti = 0;
                while ((dep_ti < ((dep_scan_mod)->num_top_level_lets))) {
                  if ((pipeline_module_top_level_let_is_const(dep_scan_mod, dep_ti) ==0)) {
                    (void)((any_let = 1));
                    break;
                  }
                  (void)((dep_ti = (dep_ti + 1)));
                }
              }
              if ((any_let !=0)) {
                break;
              }
              (void)((dep_scan_i = (dep_scan_i + 1)));
            }
          }
          if (((any_let !=0) && (dep_index < 0))) {
            uint8_t init_globals_def[32] = {115, 116, 97, 116, 105, 99, 32, 118, 111, 105, 100, 32, 105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 118, 111, 105, 100, 41, 32, 0};
            if ((codegen_emit_bytes_from_ptr(out, &((init_globals_def)[0]), 31) !=0)) {
              return -1;
            }
            uint8_t brace3[3] = {123, 10, 0};
            if ((codegen_emit_bytes_3(out, &((brace3)[0]), 2) !=0)) {
              return -1;
            }
            (void)((ti = 0));
            while ((ti < ((module)->num_top_level_lets))) {
              if ((pipeline_module_top_level_let_is_const(module, ti) !=0)) {
                (void)((ti = (ti + 1)));
                continue;
              }
              int32_t ig_ty = pipeline_module_top_level_let_type_ref(module, ti);
              if ((!(ast_ref_is_null(ig_ty)) && (pipeline_type_kind_ord_at(arena, ig_ty) ==10))) {
                (void)((ti = (ti + 1)));
                continue;
              }
              if ((codegen_emit_indent(out, 2) !=0)) {
                return -1;
              }
              int32_t nlen = pipeline_module_top_level_let_name_len(module, ti);
              if (((nlen > 0) && (nlen <=63))) {
                uint8_t tl_init_name[128] = {};
                int32_t tni2 = 0;
                while (((tni2 < nlen) && (tni2 < 64))) {
                  (void)(((tl_init_name)[tni2] = pipeline_module_top_level_let_name_byte_at(module, ti, tni2)));
                  (void)((tni2 = (tni2 + 1)));
                }
                if ((codegen_emit_bytes_from_ptr(out, &((tl_init_name)[0]), nlen) !=0)) {
                  return -1;
                }
              }
              uint8_t eq2[4] = {32, 61, 32, 0};
              if ((codegen_emit_bytes_4(out, &((eq2)[0]), 3) !=0)) {
                return -1;
              }
              if ((!(ast_ref_is_null(pipeline_module_top_level_let_init_ref(module, ti))) && (codegen_emit_expr(arena, out, pipeline_module_top_level_let_init_ref(module, ti), ctx) !=0))) {
                return -1;
              }
              uint8_t sc2[3] = {59, 10, 0};
              if ((codegen_emit_bytes_3(out, &((sc2)[0]), 2) !=0)) {
                return -1;
              }
              (void)((ti = (ti + 1)));
            }
            int32_t dep_i = 0;
            int32_t ndep = 0;
            if ((((module)->main_func_index) >=0)) {
              (void)((ndep = pipeline_dep_ctx_ndep(ctx)));
            }
            while ((dep_i < ndep)) {
              uint8_t lo_path[128] = {};
              int32_t lo_plen = codegen_dep_import_path_len_at(ctx, dep_i, &((lo_path)[0]));
              if (((lo_plen > 0) && (pipeline_codegen_std_dep_link_only(&((lo_path)[0])) !=0))) {
                (void)((dep_i = (dep_i + 1)));
                continue;
              }
              struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, dep_i);
              if ((dep_mod !=0)) {
                struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_i);
                int32_t dti = 0;
                while ((dti < ((dep_mod)->num_top_level_lets))) {
                  if ((pipeline_module_top_level_let_is_const(dep_mod, dti) ==0)) {
                    int32_t dig_ty = pipeline_module_top_level_let_type_ref(dep_mod, dti);
                    if ((((dep_arena !=0) && !(ast_ref_is_null(dig_ty))) && (pipeline_type_kind_ord_at(dep_arena, dig_ty) ==10))) {
                      (void)((dti = (dti + 1)));
                      continue;
                    }
                    if ((codegen_emit_indent(out, 2) !=0)) {
                      return -1;
                    }
                    int32_t dnlen = pipeline_module_top_level_let_name_len(dep_mod, dti);
                    if (((dnlen > 0) && (dnlen <=63))) {
                      uint8_t dtl_name[128] = {};
                      int32_t dtni = 0;
                      while (((dtni < dnlen) && (dtni < 64))) {
                        (void)(((dtl_name)[dtni] = pipeline_module_top_level_let_name_byte_at(dep_mod, dti, dtni)));
                        (void)((dtni = (dtni + 1)));
                      }
                      if ((codegen_emit_bytes_from_ptr(out, &((dtl_name)[0]), dnlen) !=0)) {
                        return -1;
                      }
                    }
                    uint8_t deq[4] = {32, 61, 32, 0};
                    if ((codegen_emit_bytes_4(out, &((deq)[0]), 3) !=0)) {
                      return -1;
                    }
                    if ((!(ast_ref_is_null(pipeline_module_top_level_let_init_ref(dep_mod, dti))) && (codegen_emit_expr(dep_arena, out, pipeline_module_top_level_let_init_ref(dep_mod, dti), ctx) !=0))) {
                      return -1;
                    }
                    uint8_t dsc[3] = {59, 10, 0};
                    if ((codegen_emit_bytes_3(out, &((dsc)[0]), 2) !=0)) {
                      return -1;
                    }
                  }
                  (void)((dti = (dti + 1)));
                }
              }
              (void)((dep_i = (dep_i + 1)));
            }
            uint8_t close_brace[3] = {125, 10, 0};
            if ((codegen_emit_bytes_3(out, &((close_brace)[0]), 2) !=0)) {
              return -1;
            }
          }
        }
      }
      uint8_t skip_name[128] = {};
      (void)(codegen_copy_func_name64_from_module(module, i, &((skip_name)[0])));
      int32_t skip_nl = pipeline_module_func_name_len_at(module, i);
      if ((pipeline_module_func_num_generic_params_at(module, i) > 0)) {
        int32_t mono_rc = codegen_try_emit_generic_identity_mono(arena, out, module, i, &((prefix_buf)[0]), prefix_len, ctx);
        if ((mono_rc < 0)) {
          return -1;
        }
        (void)((i = (i + 1)));
        continue;
      }
      int32_t w498_mono_rc = codegen_try_emit_generic_impl_method_mono(arena, out, module, i, &((prefix_buf)[0]), prefix_len, ctx);
      if ((w498_mono_rc < 0)) {
        return -1;
      }
      if ((w498_mono_rc > 0)) {
        (void)((i = (i + 1)));
        continue;
      }
      if ((pipeline_module_func_is_extern_at(module, i) !=0)) {
        if ((codegen_emit_func_extern_declaration(arena, out, module, i, &((prefix_buf)[0]), prefix_len, ctx) !=0)) {
          return -1;
        }
        (void)((i = (i + 1)));
        continue;
      }
      int32_t skip = 0;
      int32_t asm_backend = 0;
      if (((ctx !=0) && (((ctx)->use_asm_backend) !=0))) {
        (void)((asm_backend = 1));
      }
      (void)((skip = codegen_should_skip_emit_func_by_name(&((skip_name)[0]), skip_nl)));
      if (((skip ==0) && (asm_backend ==0))) {
        int32_t is_prelinked_dep = 0;
        if (((dep_index >=0) && (dep_path_prefix_len >=10))) {
          if ((((((((((((dep_path_prefix)[0] ==115) && ((dep_path_prefix)[1] ==116)) && ((dep_path_prefix)[2] ==100)) && (((dep_path_prefix)[3] ==46) || ((dep_path_prefix)[3] ==47))) && ((dep_path_prefix)[4] ==115)) && ((dep_path_prefix)[5] ==116)) && ((dep_path_prefix)[6] ==114)) && ((dep_path_prefix)[7] ==105)) && ((dep_path_prefix)[8] ==110)) && ((dep_path_prefix)[9] ==103))) {
            (void)((is_prelinked_dep = 1));
          }
        }
        if ((((is_prelinked_dep ==0) && (dep_index >=0)) && (dep_path_prefix_len >=9))) {
          if (((((((((((dep_path_prefix)[0] ==115) && ((dep_path_prefix)[1] ==116)) && ((dep_path_prefix)[2] ==100)) && (((dep_path_prefix)[3] ==46) || ((dep_path_prefix)[3] ==47))) && ((dep_path_prefix)[4] ==101)) && ((dep_path_prefix)[5] ==114)) && ((dep_path_prefix)[6] ==114)) && ((dep_path_prefix)[7] ==111)) && ((dep_path_prefix)[8] ==114))) {
            (void)((is_prelinked_dep = 1));
          }
        }
        if ((((is_prelinked_dep ==0) && (dep_index >=0)) && (dep_path_prefix_len >=11))) {
          if (((((((((((((dep_path_prefix)[0] ==115) && ((dep_path_prefix)[1] ==116)) && ((dep_path_prefix)[2] ==100)) && (((dep_path_prefix)[3] ==46) || ((dep_path_prefix)[3] ==47))) && ((dep_path_prefix)[4] ==99)) && ((dep_path_prefix)[5] ==111)) && ((dep_path_prefix)[6] ==110)) && ((dep_path_prefix)[7] ==116)) && ((dep_path_prefix)[8] ==101)) && ((dep_path_prefix)[9] ==120)) && ((dep_path_prefix)[10] ==116))) {
            (void)((is_prelinked_dep = 1));
          }
        }
        if (((((((((((((((is_prelinked_dep ==0) && (prefix_len >=11)) && ((prefix_buf)[0] ==115)) && ((prefix_buf)[1] ==116)) && ((prefix_buf)[2] ==100)) && ((prefix_buf)[3] ==95)) && ((prefix_buf)[4] ==115)) && ((prefix_buf)[5] ==116)) && ((prefix_buf)[6] ==114)) && ((prefix_buf)[7] ==105)) && ((prefix_buf)[8] ==110)) && ((prefix_buf)[9] ==103)) && ((prefix_buf)[10] ==95)) && (dep_index >=0))) {
          (void)((is_prelinked_dep = 1));
        }
        if ((((((((((((((is_prelinked_dep ==0) && (prefix_len >=10)) && ((prefix_buf)[0] ==115)) && ((prefix_buf)[1] ==116)) && ((prefix_buf)[2] ==100)) && ((prefix_buf)[3] ==95)) && ((prefix_buf)[4] ==101)) && ((prefix_buf)[5] ==114)) && ((prefix_buf)[6] ==114)) && ((prefix_buf)[7] ==111)) && ((prefix_buf)[8] ==114)) && ((prefix_buf)[9] ==95)) && (dep_index >=0))) {
          (void)((is_prelinked_dep = 1));
        }
        if ((((((((((((((((is_prelinked_dep ==0) && (prefix_len >=12)) && ((prefix_buf)[0] ==115)) && ((prefix_buf)[1] ==116)) && ((prefix_buf)[2] ==100)) && ((prefix_buf)[3] ==95)) && ((prefix_buf)[4] ==99)) && ((prefix_buf)[5] ==111)) && ((prefix_buf)[6] ==110)) && ((prefix_buf)[7] ==116)) && ((prefix_buf)[8] ==101)) && ((prefix_buf)[9] ==120)) && ((prefix_buf)[10] ==116)) && ((prefix_buf)[11] ==95)) && (dep_index >=0))) {
          (void)((is_prelinked_dep = 1));
        }
        if ((is_prelinked_dep !=0)) {
          (void)((skip = 1));
        }
      }
      if ((((skip !=0) && (prefix_len > 0)) && ((skip_nl ==11) || (skip_nl ==10)))) {
        (void)((skip = 0));
      }
      if ((((skip ==0) && (prefix_len ==0)) && (asm_backend ==0))) {
        (void)((skip = codegen_should_skip_emit_func_core_read_ptr(&((skip_name)[0]), skip_nl)));
      }
      if ((((skip ==0) && (prefix_len > 0)) && (asm_backend ==0))) {
        (void)((skip = codegen_should_skip_emit_func(0, &((prefix_buf)[0]), prefix_len, &((skip_name)[0]), skip_nl)));
      }
      if ((((((skip ==0) && (dep_index >=0)) && (ctx !=0)) && (dep_path_prefix_len > 0)) && (asm_backend ==0))) {
        (void)((skip = codegen_should_skip_emit_func(&((dep_path_prefix)[0]), 0, 0, &((skip_name)[0]), skip_nl)));
      }
      if (((skip ==0) && (asm_backend ==0))) {
        uint8_t * skip_dep = 0;
        if ((((dep_index >=0) && (ctx !=0)) && (dep_path_prefix_len > 0))) {
          (void)((skip_dep = &((dep_path_prefix)[0])));
        }
        if ((skip_dep ==0)) {
          (void)((skip_dep = driver_get_current_dep_path_for_codegen()));
        }
        (void)((skip = codegen_should_skip_emit_func(skip_dep, 0, 0, &((skip_name)[0]), skip_nl)));
      }
      if (((skip ==0) && (asm_backend ==0))) {
        (void)((skip = codegen_should_skip_later_same_name_body(arena, module, i)));
      }
      if ((skip !=0)) {
        (void)((i = (i + 1)));
        continue;
      }
      int is_entry = ((i ==((module)->main_func_index)) || (((module)->num_funcs) ==1));
      int32_t saved_func_idx = -1;
      if ((ctx !=0)) {
        (void)((saved_func_idx = ((ctx)->current_func_index)));
        (void)((((ctx)->current_func_index) = i));
      }
      if ((ctx !=0)) {
        (void)((((ctx)->current_codegen_module) = module));
        (void)((((ctx)->current_codegen_arena) = arena));
        (void)((((ctx)->current_codegen_dep_index) = dep_index));
        int32_t px = 0;
        while (((px < prefix_len) && (px < 63))) {
          (void)(((((ctx)->current_codegen_prefix_mirror))[px] = (prefix_buf)[px]));
          (void)((px = (px + 1)));
        }
        (void)(((((ctx)->current_codegen_prefix_mirror))[px] = ((uint8_t)(0))));
        (void)((((ctx)->current_codegen_prefix_len) = px));
      }
      if ((codegen_emit_func(arena, out, module, i, is_entry, &((prefix_buf)[0]), prefix_len, ctx, call_init_globals) !=0)) {
        (void)(driver_diagnostic_codegen_emit_func_fail(module, i));
        if ((ctx !=0)) {
          (void)((((ctx)->current_func_index) = saved_func_idx));
        }
        return -1;
      }
      if ((ctx !=0)) {
        (void)((((ctx)->current_func_index) = saved_func_idx));
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
}
int32_t codegen_should_skip_emit_func_by_name(uint8_t * name, int32_t name_len) {
  {
    uint8_t asm_seed_mega[25] = {97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97};
    uint8_t asm_to_elf_seed_mega[32] = {97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 116, 111, 95, 101, 108, 102, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97};
    if ((name ==0)) {
      return 0;
    }
    if ((pipeline_codegen_emit_seed_mega_enabled() ==0)) {
      if (((name_len ==25) && (codegen_name_bytes_prefix_eq(name, name_len, &((asm_seed_mega)[0]), 25) !=0))) {
        return 1;
      }
      if (((name_len ==32) && (codegen_name_bytes_prefix_eq(name, name_len, &((asm_to_elf_seed_mega)[0]), 32) !=0))) {
        return 1;
      }
    }
    return 0;
  }
}
int32_t codegen_is_submit_batch_buf_call(uint8_t * name, int32_t name_len) {
  uint8_t rd_batch[21] = {115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  uint8_t wr_batch[22] = {115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102};
  if ((name ==0)) {
    return 0;
  }
  if (((name_len ==21) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd_batch)[0]), 21) !=0))) {
    return 1;
  }
  if (((name_len ==22) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr_batch)[0]), 22) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_force_param_i32(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len, int32_t param_index) {
  return 0;
}
int32_t codegen_should_skip_emit_func_core_read_ptr(uint8_t * name, int32_t name_len) {
  uint8_t xlang_rpl20[21] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110};
  uint8_t xlang_rp16[17] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114};
  if ((name ==0)) {
    return 0;
  }
  if (((name_len >=20) && (codegen_name_bytes_prefix_eq(name, name_len, &((xlang_rpl20)[0]), 20) !=0))) {
    return 1;
  }
  if (((name_len ==16) && (codegen_name_bytes_prefix_eq(name, name_len, &((xlang_rp16)[0]), 16) !=0))) {
    return 1;
  }
  uint8_t xlang_rpb24[25] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 98, 97, 99, 107, 101, 110, 100};
  if ((((name_len ==24) || (name_len ==25)) && (codegen_name_bytes_prefix_eq(name, name_len, &((xlang_rpb24)[0]), 24) !=0))) {
    return 1;
  }
  uint8_t xlang_sra25[26] = {120, 108, 97, 110, 103, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 97, 115, 121, 110, 99};
  if ((((name_len ==25) || (name_len ==26)) && (codegen_name_bytes_prefix_eq(name, name_len, &((xlang_sra25)[0]), 25) !=0))) {
    return 1;
  }
  return 0;
}
int32_t codegen_std_io_fixed_fd_emit_impl(uint8_t * prefix, int32_t prefix_len, uint8_t * name, int32_t name_len) {
  uint8_t pre7[7] = {115, 116, 100, 95, 105, 111, 95};
  uint8_t rd13[13] = {114, 101, 97, 100, 95, 102, 105, 120, 101, 100, 95, 102, 100};
  uint8_t wr14[14] = {119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100, 95, 102, 100};
  if (((((prefix ==0) || (name ==0)) || (prefix_len < 7)) || (name_len <=0))) {
    return 0;
  }
  if ((codegen_name_bytes_prefix_eq(prefix, prefix_len, &((pre7)[0]), 7) ==0)) {
    return 0;
  }
  if (((name_len >=13) && (codegen_name_bytes_prefix_eq(name, name_len, &((rd13)[0]), 13) !=0))) {
    return 1;
  }
  if (((name_len >=14) && (codegen_name_bytes_prefix_eq(name, name_len, &((wr14)[0]), 14) !=0))) {
    return 1;
  }
  return 0;
}

/* wave323 Cap residual (seeds/codegen_cap_residual.from_x.c) */
/* seeds/codegen_cap_residual.from_x.c — wave323 M4 7.4.2 companions
 * Cap residual not emitted by tip codegen.x -E (host-call BSS, slice-let
 * reent finish, pipeline scratch/loop glue). Appended by assemble_codegen_gen_from_x.py.
 * G.7: residual TU only; business emit lives in codegen.x.
 * PLATFORM: SHARED freestanding codegen cold assemble companion.
 */

/* PLATFORM: SHARED host-C — formal type for next emit_call_arg_slice_abi (wave395). */
static int32_t g_codegen_host_call_arg_param_ty_ref = 0;
void codegen_set_host_call_arg_param_ty(int32_t param_ty_ref) {
  g_codegen_host_call_arg_param_ty_ref = param_ty_ref;
}
int32_t codegen_get_host_call_arg_param_ty(void) {
  return g_codegen_host_call_arg_param_ty_ref;
}
/* PLATFORM: SHARED host-C — unique id for call-site TYPE_ARRAY deep-copy temps
 * (__xlang_caN). wave397: dual CALL/METHOD T[N] as TYPE_SLICE formals must not
 * both alias callee __xlang_ar (last-wins). Mirror codegen.x. */
static int32_t g_codegen_host_call_array_tmp_id = 0;
int32_t codegen_next_host_call_array_tmp_id(void) {
  int32_t id = g_codegen_host_call_array_tmp_id;
  g_codegen_host_call_array_tmp_id = id + 1;
  if (g_codegen_host_call_array_tmp_id < 0) {
    g_codegen_host_call_array_tmp_id = 0;
  }
  return id;
}

/**
 * wave409 Cap residual pure: host-C TYPE_SLICE let from CALL/METHOD — frame deep-copy.
 * Root: callee `return [n,…]` uses function-static `__xlang_al` (wave341 durable).
 * `let s = mk(n); recurse(); use(s)` → all frames share one static → last-wins (walk 18≠36).
 * G.7: after `Type name` is already written, finish as:
 *   ; E __xlang_ldN[1024]; { S __xlang_spN = call; copy min(len,1024) into ld; name = fat(ld); }
 * Stack payload (auto, not static) is reentrancy-safe across recursive frames of the same let site.
 * Host twin of freestanding glue_slice_let_reent_deep_copy_after_dual_gp_elf_c.
 * Soft: length > 1024 truncates copy (same cap as wave406 call-arg). PLATFORM: SHARED host-C.
 * @return 0 success; -1 emit fail. Caller must only invoke when init is CALL/METHOD + TYPE_SLICE.
 */
int32_t codegen_emit_slice_let_reent_finish(struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out,
                                             int32_t indent, uint8_t * name, int32_t name_len,
                                             int32_t let_type_ref, int32_t linit_ref,
                                             struct ast_PipelineDepCtx * ctx) {
  int32_t tid;
  int32_t elem_tr = 0;
  /* ";\n" — close uninit fat decl (Type name already emitted). */
  {
    uint8_t scnl[4] = {59, 10, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, scnl, 2) != 0)
      return -1;
  }
  tid = codegen_next_host_call_array_tmp_id();
  if (!(ast_ref_is_null(let_type_ref)) && let_type_ref > 0 && let_type_ref <= arena->num_types)
    elem_tr = pipeline_type_elem_ref_at(arena, let_type_ref);
  /* E __xlang_ldN[1024]; */
  if (codegen_emit_indent(out, indent) != 0)
    return -1;
  if (elem_tr <= 0 || codegen_emit_type(arena, out, elem_tr, ((uint8_t *)(0)), 0, ctx) != 0) {
    uint8_t fb_e[9] = {105, 110, 116, 51, 50, 95, 116, 0, 0}; /* int32_t */
    if (codegen_emit_bytes_from_ptr(out, fb_e, 7) != 0)
      return -1;
  }
  {
    uint8_t ld_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 108, 100, 0, 0, 0}; /*  __xlang_ld */
    if (codegen_emit_bytes_from_ptr(out, ld_nm, 11) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t ld_sz[12] = {91, 49, 48, 50, 52, 93, 59, 10, 0, 0, 0, 0}; /* [1024];\n */
    if (codegen_emit_bytes_from_ptr(out, ld_sz, 8) != 0)
      return -1;
  }
  /* { */
  if (codegen_emit_indent(out, indent) != 0)
    return -1;
  if (codegen_append_byte(out, 123) != 0) /* { */
    return -1;
  if (codegen_append_byte(out, 10) != 0)
    return -1;
  /* S __xlang_spN = <call>; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  if (!(ast_ref_is_null(let_type_ref)) && let_type_ref > 0) {
    if (codegen_emit_type(arena, out, let_type_ref, ((uint8_t *)(0)), 0, ctx) != 0)
      return -1;
  } else {
    uint8_t fb[32] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105,
                      99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, fb, 26) != 0)
      return -1;
  }
  {
    uint8_t sp_nm[14] = {32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0}; /*  __xlang_sp */
    if (codegen_emit_bytes_from_ptr(out, sp_nm, 11) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t eq[4] = {32, 61, 32, 0};
    if (codegen_emit_bytes_4(out, eq, 3) != 0)
      return -1;
  }
  if (codegen_emit_expr(arena, out, linit_ref, ctx) != 0)
    return -1;
  {
    uint8_t sc[4] = {59, 10, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, sc, 2) != 0)
      return -1;
  }
  /* size_t __xlang_snN = __xlang_spN.length; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  {
    uint8_t sn_decl[28] = {115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115,
                           110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; /* size_t __xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, sn_decl, 17) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t sn_eq[16] = {32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0}; /*  = __xlang_sp */
    if (codegen_emit_bytes_from_ptr(out, sn_eq, 13) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t sn_len[16] = {46, 108, 101, 110, 103, 116, 104, 59, 10, 0, 0, 0, 0, 0, 0, 0}; /* .length;\n */
    if (codegen_emit_bytes_from_ptr(out, sn_len, 9) != 0)
      return -1;
  }
  /* if (__xlang_snN > 1024) __xlang_snN = 1024; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  {
    uint8_t if_h[20] = {105, 102, 32, 40, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0, 0}; /* if (__xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, if_h, 14) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t if_m[28] = {32, 62, 32, 49, 48, 50, 52, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, if_m, 19) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t if_t[12] = {32, 61, 32, 49, 48, 50, 52, 59, 10, 0, 0, 0}; /*  = 1024;\n */
    if (codegen_emit_bytes_from_ptr(out, if_t, 9) != 0)
      return -1;
  }
  /* size_t __xlang_siN; for (__xlang_siN = 0; __xlang_siN < __xlang_snN; __xlang_siN++) */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  {
    uint8_t si_decl[28] = {115, 105, 122, 101, 95, 116, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115,
                           105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; /* size_t __xlang_si */
    if (codegen_emit_bytes_from_ptr(out, si_decl, 17) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_h[12] = {59, 32, 102, 111, 114, 32, 40, 95, 95, 120, 108, 97}; /* ; for (__xla */
    uint8_t for_h2[8] = {110, 103, 95, 115, 105, 0, 0, 0}; /* ng_si */
    if (codegen_emit_bytes_from_ptr(out, for_h, 12) != 0)
      return -1;
    if (codegen_emit_bytes_from_ptr(out, for_h2, 5) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_m1[16] = {32, 61, 32, 48, 59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105}; /*  = 0; __xlang_si */
    if (codegen_emit_bytes_from_ptr(out, for_m1, 16) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_m2[16] = {32, 60, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 110, 0, 0, 0}; /*  < __xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, for_m2, 13) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_m3[16] = {59, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0}; /* ; __xlang_si */
    if (codegen_emit_bytes_from_ptr(out, for_m3, 12) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t for_body[20] = {43, 43, 41, 32, 95, 95, 120, 108, 97, 110, 103, 95, 108, 100, 0, 0, 0, 0, 0, 0}; /* ++) __xlang_ld */
    if (codegen_emit_bytes_from_ptr(out, for_body, 14) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t idx_o[16] = {91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0, 0}; /* [__xlang_si */
    if (codegen_emit_bytes_from_ptr(out, idx_o, 11) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t copy_m[20] = {93, 32, 61, 32, 95, 95, 120, 108, 97, 110, 103, 95, 115, 112, 0, 0, 0, 0, 0, 0}; /* ] = __xlang_sp */
    if (codegen_emit_bytes_from_ptr(out, copy_m, 14) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t data_i[24] = {46, 100, 97, 116, 97, 91, 95, 95, 120, 108, 97, 110, 103, 95, 115, 105, 0, 0, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, data_i, 16) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t after[8] = {93, 59, 10, 0, 0, 0, 0, 0}; /* ];\n */
    if (codegen_emit_bytes_from_ptr(out, after, 3) != 0)
      return -1;
  }
  /* name = (S){ .data = __xlang_ldN, .length = __xlang_spN.length }; */
  if (codegen_emit_indent(out, indent + 1) != 0)
    return -1;
  if (name_len > 0 && name != ((uint8_t *)(0))) {
    if (codegen_emit_bytes_64(out, name, name_len) != 0)
      return -1;
  } else {
    uint8_t fb_nm[4] = {95, 108, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, fb_nm, 2) != 0)
      return -1;
  }
  {
    uint8_t eq[4] = {32, 61, 32, 0};
    if (codegen_emit_bytes_4(out, eq, 3) != 0)
      return -1;
  }
  if (codegen_append_byte(out, 40) != 0) /* ( */
    return -1;
  if (!(ast_ref_is_null(let_type_ref)) && let_type_ref > 0) {
    if (codegen_emit_type(arena, out, let_type_ref, ((uint8_t *)(0)), 0, ctx) != 0)
      return -1;
  } else {
    uint8_t fb[32] = {115, 116, 114, 117, 99, 116, 32, 120, 108, 97, 110, 103, 95, 115, 108, 105,
                      99, 101, 95, 105, 110, 116, 51, 50, 95, 116, 0, 0, 0, 0, 0, 0};
    if (codegen_emit_bytes_from_ptr(out, fb, 26) != 0)
      return -1;
  }
  {
    uint8_t fat_mid[28] = {41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 95, 95, 120, 108, 97,
                           110, 103, 95, 108, 100, 0, 0, 0, 0, 0, 0, 0}; /* ){ .data = __xlang_ld */
    if (codegen_emit_bytes_from_ptr(out, fat_mid, 21) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t len_asg[28] = {44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 95, 95, 120, 108,
                           97, 110, 103, 95, 115, 110, 0, 0, 0, 0, 0, 0}; /* , .length = __xlang_sn */
    if (codegen_emit_bytes_from_ptr(out, len_asg, 22) != 0)
      return -1;
  }
  if (codegen_format_int(out, (int64_t)tid) != 0)
    return -1;
  {
    uint8_t end_fat[16] = {32, 125, 59, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; /*  };\n */
    if (codegen_emit_bytes_from_ptr(out, end_fat, 4) != 0)
      return -1;
  }
  /* } */
  if (codegen_emit_indent(out, indent) != 0)
    return -1;
  if (codegen_append_byte(out, 125) != 0)
    return -1;
  if (codegen_append_byte(out, 10) != 0)
    return -1;
  return 0;
}

/* ============================================================================
 * 8.3.2 host-cc leave: pipeline_scratch_bufs.c retired from pipeline_x mega-TU.
 * Live path/prefix scratch buffer accessors live here in codegen_x.o.
 * Mangled thin faces (codegen_pipeline_scratch_buf64* / ast_pipeline_scratch_buf*)
 * remain in pipeline_x host-cc forwarders and call these symbols.
 * PLATFORM: SHARED — BSS only; no business logic; G.7 single authority pools.
 * ============================================================================ */

/** codegen path/prefix scratch (avoid `u8[N] = []` ExprKind=-1 under asm emit). */
static uint8_t g_pipeline_scratch64[4][128];
static uint8_t g_pipeline_scratch128[2][128];
static uint8_t g_pipeline_scratch256[2][256];

uint8_t *pipeline_scratch_buf64(void) {
  return g_pipeline_scratch64[0];
}

uint8_t *pipeline_scratch_buf64_slot(int32_t slot) {
  if (slot < 0 || slot >= 4)
    return g_pipeline_scratch64[0];
  return g_pipeline_scratch64[slot];
}

uint8_t *pipeline_scratch_buf128(void) {
  return g_pipeline_scratch128[0];
}

uint8_t *pipeline_scratch_buf128_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_pipeline_scratch128[0];
  return g_pipeline_scratch128[slot];
}

uint8_t *pipeline_scratch_buf96(void) {
  static uint8_t s[96];
  return s;
}

uint8_t *pipeline_scratch_buf256(void) {
  return g_pipeline_scratch256[0];
}

uint8_t *pipeline_scratch_buf256_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_pipeline_scratch256[0];
  return g_pipeline_scratch256[slot];
}

/* ============================================================================
 * 8.3.2 host-cc leave: pipeline_loop_glue.c retired from pipeline_x mega-TU.
 * Live bounded-loop predicates + one_dep prepare glue live here in codegen_x.o.
 * Callers (pipeline.x / pipeline_gen / runtime_pipeline_abi) already extern these
 * `*_c` faces; they U-resolve from pipeline_x / other TUs into codegen_x.
 * Callees (dep_ctx_ndep / lib_root_count / prepare_dep_codegen_path_c /
 * parser_get_module_num_imports) stay in pipeline_x / parser_x and link back.
 * PLATFORM: SHARED — thin glue only; G.7 single authority for these faces.
 * ============================================================================ */

extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern int32_t pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
extern int32_t pipeline_prepare_dep_codegen_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                                   uint8_t *dst);

/**
 * Bounded loop continue: return 1 while idx < ndep.
 * X while bare CALL predicate (do not emit CALL==0 compare).
 */
int32_t pipeline_loop_should_continue_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * Bounded import loop continue: return 1 while idx < num_imports.
 */
int32_t pipeline_loop_should_continue_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 0;
  return idx < parser_get_module_num_imports(module) ? 1 : 0;
}

/**
 * Bounded lib_root loop continue: return 1 while idx < lib_root_count.
 */
int32_t pipeline_loop_should_continue_lib_root_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_ctx_lib_root_count(ctx) ? 1 : 0;
}

/**
 * Bounded loop exit: return 1 when idx >= ndep (X if(CALL!=0)).
 */
int32_t pipeline_loop_index_at_or_beyond_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 1;
  return idx >= pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * Bounded import loop exit: return 1 when idx >= num_imports.
 */
int32_t pipeline_loop_index_at_or_beyond_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 1;
  return idx >= parser_get_module_num_imports(module) ? 1 : 0;
}

/** After import loop: write ndep from module import count (C glue; no dual CALL in X stmt). */
void pipeline_load_and_sync_set_ndep_from_module_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  if (module && ctx)
    pipeline_dep_ctx_set_ndep(ctx, parser_get_module_num_imports(module));
}

/**
 * one_dep codegen prepare path prefix (C glue; X side u8[64] stack array issue).
 * Zeros a 128-byte scratch then calls pipeline_prepare_dep_codegen_path_c.
 */
int32_t run_x_pipeline_codegen_one_dep_prepare_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  uint8_t dep_path_buf[128];
  int32_t i;

  if (!ctx || dep_j < 0)
    return -1;
  /* Avoid string.h memset macros in this seed (see codegen string.h clash notes). */
  for (i = 0; i < 128; i++)
    dep_path_buf[i] = 0;
  return pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
}
