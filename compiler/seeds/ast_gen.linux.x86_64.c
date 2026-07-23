#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
enum TypeKind { TypeKind_TYPE_I32, TypeKind_TYPE_BOOL, TypeKind_TYPE_U8, TypeKind_TYPE_U32, TypeKind_TYPE_U64, TypeKind_TYPE_I64, TypeKind_TYPE_USIZE, TypeKind_TYPE_ISIZE, TypeKind_TYPE_NAMED, TypeKind_TYPE_PTR, TypeKind_TYPE_ARRAY, TypeKind_TYPE_SLICE, TypeKind_TYPE_LINEAR, TypeKind_TYPE_VECTOR, TypeKind_TYPE_F32, TypeKind_TYPE_F64, TypeKind_TYPE_VOID };
enum ExprKind { ExprKind_EXPR_LIT, ExprKind_EXPR_FLOAT_LIT, ExprKind_EXPR_BOOL_LIT, ExprKind_EXPR_VAR, ExprKind_EXPR_ADD, ExprKind_EXPR_SUB, ExprKind_EXPR_MUL, ExprKind_EXPR_DIV, ExprKind_EXPR_MOD, ExprKind_EXPR_SHL, ExprKind_EXPR_SHR, ExprKind_EXPR_BITAND, ExprKind_EXPR_BITOR, ExprKind_EXPR_BITXOR, ExprKind_EXPR_EQ, ExprKind_EXPR_NE, ExprKind_EXPR_LT, ExprKind_EXPR_LE, ExprKind_EXPR_GT, ExprKind_EXPR_GE, ExprKind_EXPR_LOGAND, ExprKind_EXPR_LOGOR, ExprKind_EXPR_NEG, ExprKind_EXPR_BITNOT, ExprKind_EXPR_LOGNOT, ExprKind_EXPR_IF, ExprKind_EXPR_BLOCK, ExprKind_EXPR_TERNARY, ExprKind_EXPR_ASSIGN, ExprKind_EXPR_ADD_ASSIGN, ExprKind_EXPR_SUB_ASSIGN, ExprKind_EXPR_MUL_ASSIGN, ExprKind_EXPR_DIV_ASSIGN, ExprKind_EXPR_MOD_ASSIGN, ExprKind_EXPR_BITAND_ASSIGN, ExprKind_EXPR_BITOR_ASSIGN, ExprKind_EXPR_BITXOR_ASSIGN, ExprKind_EXPR_SHL_ASSIGN, ExprKind_EXPR_SHR_ASSIGN, ExprKind_EXPR_BREAK, ExprKind_EXPR_CONTINUE, ExprKind_EXPR_RETURN, ExprKind_EXPR_PANIC, ExprKind_EXPR_MATCH, ExprKind_EXPR_FIELD_ACCESS, ExprKind_EXPR_STRUCT_LIT, ExprKind_EXPR_ARRAY_LIT, ExprKind_EXPR_INDEX, ExprKind_EXPR_CALL, ExprKind_EXPR_METHOD_CALL, ExprKind_EXPR_ENUM_VARIANT, ExprKind_EXPR_ADDR_OF, ExprKind_EXPR_DEREF, ExprKind_EXPR_BINOP, ExprKind_EXPR_AS, ExprKind_EXPR_AWAIT, ExprKind_EXPR_RUN, ExprKind_EXPR_SPAWN, ExprKind_EXPR_TRY_PROPAGATE, ExprKind_EXPR_STRING_LIT };
enum ImportKind { ImportKind_IMPORT_WHOLE, ImportKind_IMPORT_BINDING, ImportKind_IMPORT_SELECT };
struct Type {
  int32_t kind;
  uint8_t name[64];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[64];
  int32_t region_label_len;
};

struct Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[64];
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
  uint8_t field_access_field_name[64];
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
  uint8_t method_call_name[64];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[64];
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

struct ConstDecl {
  uint8_t name[64];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
};

struct LetDecl {
  uint8_t name[64];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
};

struct WhileLoop {
  int32_t cond_ref;
  int32_t body_ref;
};

struct ForLoop {
  int32_t init_ref;
  int32_t cond_ref;
  int32_t step_ref;
  int32_t body_ref;
};

struct IfStmt {
  int32_t cond_ref;
  int32_t then_body_ref;
  int32_t else_body_ref;
};

struct StmtOrderItem {
  uint8_t kind;
  int32_t idx;
};

struct LabeledStmt {
  uint8_t label[32];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[32];
  int32_t goto_target_len;
  int32_t return_expr_ref;
};

struct Block {
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

struct Param {
  uint8_t name[32];
  int32_t name_len;
  int32_t type_ref;
};

struct Func {
  uint8_t name[64];
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

struct StructLayout {
  uint8_t name[64];
  int32_t name_len;
  int32_t field_base;
  int32_t num_fields;
  int32_t allow_padding;
  int32_t soa;
  int32_t packed;
  int32_t repr_compatible;
  int32_t is_export;
};

struct Module {
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

struct ASTArena {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
};

struct PipelineDepCtx {
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
  struct Module * current_codegen_module;
  struct ASTArena * current_codegen_arena;
  int32_t current_codegen_dep_index;
  uint8_t current_codegen_prefix_mirror[64];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[64];
  int32_t entry_module_import_path_len;
  int32_t typeck_scope_region_len;
  uint8_t typeck_scope_region_label[64];
};

extern int ref_is_null(int32_t ref);
extern int32_t ast_placeholder(void);
extern void expr_layout_prime_call_resolved(void);
extern void func_layout_prime_generic_params(void);
extern void ast_arena_init(struct ASTArena * arena);
extern int32_t ast_arena_type_alloc(struct ASTArena * arena);
extern int32_t ast_arena_expr_alloc(struct ASTArena * arena);
extern int32_t ast_arena_block_alloc(struct ASTArena * arena);
extern void expr_init_match_enum(struct Expr * e);
extern void expr_init_call_resolve(struct ASTArena * arena, int32_t expr_ref);
extern void ast_expr_apply_call_resolve(struct ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
extern int ast_name_bytes_equal(uint8_t * a_nm, int32_t a_len, uint8_t * b_nm, int32_t b_len);
extern int32_t ast_block_final_expr_ref(struct ASTArena * a, int32_t body_ref);
extern int ast_expr_disallows_implicit_tail(struct ASTArena * a, int32_t expr_ref);
extern int32_t ast_block_num_consts(struct ASTArena * a, int32_t br);
extern int32_t ast_block_num_lets(struct ASTArena * a, int32_t br);
extern int32_t ast_block_num_loops(struct ASTArena * a, int32_t br);
extern int32_t ast_block_num_for_loops(struct ASTArena * a, int32_t br);
extern int32_t ast_block_num_if_stmts(struct ASTArena * a, int32_t br);
extern int32_t ast_block_num_regions(struct ASTArena * a, int32_t br);
extern int32_t ast_block_region_body_ref(struct ASTArena * a, int32_t br, int32_t ri);
extern int32_t ast_block_num_expr_stmts(struct ASTArena * a, int32_t br);
extern int32_t ast_block_num_stmt_order(struct ASTArena * a, int32_t br);
extern uint8_t ast_block_stmt_order_kind(struct ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_block_stmt_order_idx(struct ASTArena * a, int32_t br, int32_t si);
extern int32_t ast_block_const_init_ref(struct ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_block_const_type_ref(struct ASTArena * a, int32_t br, int32_t ci);
extern int32_t ast_block_let_init_ref(struct ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_block_let_type_ref(struct ASTArena * a, int32_t br, int32_t li);
extern int32_t ast_block_expr_stmt_ref(struct ASTArena * a, int32_t br, int32_t ei);
extern int32_t ast_block_while_cond_ref(struct ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_block_while_body_ref(struct ASTArena * a, int32_t br, int32_t wi);
extern int32_t ast_block_for_init_ref(struct ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_cond_ref(struct ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_step_ref(struct ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_for_body_ref(struct ASTArena * a, int32_t br, int32_t fi);
extern int32_t ast_block_if_cond_ref(struct ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_if_then_body_ref(struct ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_if_else_body_ref(struct ASTArena * a, int32_t br, int32_t ii);
extern int32_t ast_block_resolve_var_to_type_ref(struct ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern void ast_arena_patch_block_parent_links(struct ASTArena * arena, int32_t block_ref, int32_t parent_ref);
extern int32_t ast_arena_func_alloc(struct ASTArena * arena);
extern void ast_pool_block_on_alloc(struct ASTArena * arena, int32_t block_ref);
extern int32_t pipeline_arena_type_alloc(struct ASTArena * arena);
extern int32_t pipeline_arena_expr_alloc(struct ASTArena * arena);
extern int32_t pipeline_arena_block_alloc(struct ASTArena * arena);
extern int32_t pipeline_arena_func_alloc(struct ASTArena * arena);
extern struct Type pipeline_arena_type_get_copy(struct ASTArena * arena, int32_t ref);
extern void pipeline_arena_type_set_copy(struct ASTArena * arena, int32_t ref, struct Type t);
extern struct Expr pipeline_arena_expr_get_copy(struct ASTArena * arena, int32_t ref);
extern void pipeline_arena_expr_set_copy(struct ASTArena * arena, int32_t ref, struct Expr e);
extern struct Block pipeline_arena_block_get_copy(struct ASTArena * arena, int32_t ref);
extern void pipeline_arena_block_set_copy(struct ASTArena * arena, int32_t ref, struct Block b);
extern struct Func pipeline_arena_func_get_copy(struct ASTArena * arena, int32_t ref);
extern void pipeline_arena_func_set_copy(struct ASTArena * arena, int32_t ref, struct Func f);
extern int32_t pipeline_arena_type_cap(void);
extern int32_t pipeline_arena_expr_cap(void);
extern int32_t pipeline_arena_block_cap(void);
extern int32_t pipeline_arena_func_cap(void);
extern int32_t pipeline_module_import_alloc(struct Module * module);
extern void pipeline_module_import_set_path(struct Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_path_len(struct Module * module, int32_t idx);
extern void pipeline_module_import_path_copy(struct Module * module, int32_t idx, uint8_t * dst, int32_t dst_cap);
extern uint8_t pipeline_module_import_path_byte_at(struct Module * module, int32_t idx, int32_t off);
extern void pipeline_module_import_set_kind(struct Module * module, int32_t idx, int32_t kind);
extern int32_t pipeline_module_import_kind_at(struct Module * module, int32_t idx);
extern void pipeline_module_import_set_binding_name(struct Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_binding_name_len(struct Module * module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct Module * module, int32_t idx, int32_t off);
extern void pipeline_module_import_set_select_count(struct Module * module, int32_t idx, int32_t n);
extern int32_t pipeline_module_import_append_select_name(struct Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_select_count_at(struct Module * module, int32_t idx);
extern void pipeline_module_import_set_select_name(struct Module * module, int32_t idx, int32_t sel, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_import_select_name_len(struct Module * module, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct Module * module, int32_t idx, int32_t sel, int32_t off);
extern int32_t pipeline_module_struct_layout_alloc(struct Module * module);
extern void pipeline_module_struct_layout_reset_slot(struct Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_name(struct Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern void pipeline_module_struct_layout_set_field(struct Module * module, int32_t li, int32_t j, uint8_t * fname_bytes, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern int32_t pipeline_module_struct_layout_name_len(struct Module * module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct Module * module, int32_t idx, uint8_t * out64);
extern void pipeline_module_struct_layout_field_name_into(struct Module * module, int32_t li, int32_t j, uint8_t * out64);
extern int32_t pipeline_module_struct_layout_num_fields(struct Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_num_fields(struct Module * module, int32_t idx, int32_t nf);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct Module * module, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_name_len(struct Module * module, int32_t li, int32_t j);
extern int32_t pipeline_module_top_level_let_alloc(struct Module * module);
extern void pipeline_module_top_level_let_set(struct Module * module, int32_t idx, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref, int32_t is_const);
extern int32_t pipeline_module_top_level_let_name_len(struct Module * module, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct Module * module, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(struct Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_init_ref(struct Module * module, int32_t idx);
extern int32_t pipeline_module_top_level_let_is_const(struct Module * module, int32_t idx);
extern int32_t pipeline_module_enum_alloc(struct Module * module);
extern void pipeline_module_enum_set_name(struct Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_module_enum_name_len(struct Module * module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct Module * module, int32_t idx, int32_t off);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct Module * module, int32_t idx, int32_t off);
extern void pipeline_module_struct_layout_set_allow_padding(struct Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_allow_padding_at(struct Module * module, int32_t idx);
extern void pipeline_module_struct_layout_set_soa(struct Module * module, int32_t idx, int32_t v);
extern void pipeline_module_struct_layout_set_packed(struct Module * module, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_packed_at(struct Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_soa_at(struct Module * module, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_offset_at(struct Module * module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_field_offset(struct Module * module, int32_t li, int32_t j, int32_t foff);
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
extern void ast_pool_onefunc_reset(uint8_t * out);
extern int32_t pipeline_block_append_const(struct ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_let(struct ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_if(struct ASTArena * arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_block_append_region(struct ASTArena * arena, int32_t br, uint8_t * label, int32_t label_len, int32_t body_ref);
extern int32_t pipeline_block_append_unsafe(struct ASTArena * arena, int32_t br, int32_t body_ref);
extern int32_t pipeline_block_region_body_ref(struct ASTArena * arena, int32_t br, int32_t ri);
extern int32_t pipeline_block_append_expr_stmt(struct ASTArena * arena, int32_t br, int32_t expr_ref);
extern int32_t pipeline_block_append_stmt_order(struct ASTArena * arena, int32_t br, uint8_t kind, int32_t idx);
extern int32_t pipeline_block_const_init_ref(struct ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_type_ref(struct ASTArena * arena, int32_t br, int32_t ci);
extern int32_t pipeline_block_const_name_len(struct ASTArena * arena, int32_t br, int32_t ci);
extern void pipeline_block_const_name_copy64(struct ASTArena * arena, int32_t br, int32_t ci, uint8_t * dst);
extern int32_t pipeline_block_let_init_ref(struct ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_type_ref(struct ASTArena * arena, int32_t br, int32_t li);
extern int32_t pipeline_block_let_name_len(struct ASTArena * arena, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(struct ASTArena * arena, int32_t br, int32_t li, uint8_t * dst);
extern int32_t pipeline_block_expr_stmt_ref(struct ASTArena * arena, int32_t br, int32_t ei);
extern uint8_t pipeline_block_stmt_order_kind(struct ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_stmt_order_idx(struct ASTArena * arena, int32_t br, int32_t si);
extern int32_t pipeline_block_if_cond_ref(struct ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_then_body_ref(struct ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_if_else_body_ref(struct ASTArena * arena, int32_t br, int32_t ii);
extern int32_t pipeline_block_resolve_var_type_ref(struct ASTArena * arena, int32_t block_ref, uint8_t * vname, int32_t vlen);
extern void pipeline_block_fill_ifs_from_onefunc(struct ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_stmt_order_from_onefunc(struct ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_expr_stmts_from_onefunc(struct ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern int32_t pipeline_block_append_while(struct ASTArena * arena, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t pipeline_block_append_for(struct ASTArena * arena, int32_t br, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t pipeline_block_while_cond_ref(struct ASTArena * arena, int32_t br, int32_t wi);
extern int32_t pipeline_block_while_body_ref(struct ASTArena * arena, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_init_ref(struct ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_cond_ref(struct ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_step_ref(struct ASTArena * arena, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_body_ref(struct ASTArena * arena, int32_t br, int32_t fi);
extern void pipeline_block_fill_whiles_from_onefunc(struct ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void pipeline_block_fill_fors_from_onefunc(struct ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern int32_t pipeline_block_append_labeled(struct ASTArena * arena, int32_t br, int32_t label_len, int32_t is_goto, int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t pipeline_block_labeled_return_expr_ref(struct ASTArena * arena, int32_t br, int32_t li);
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
extern void pipeline_dep_ctx_set_module(struct PipelineDepCtx * ctx, int32_t idx, struct Module * m);
extern void pipeline_dep_ctx_set_arena(struct PipelineDepCtx * ctx, int32_t idx, struct ASTArena * a);
extern struct Module * pipeline_dep_ctx_module_at(struct PipelineDepCtx * ctx, int32_t idx);
extern struct ASTArena * pipeline_dep_ctx_arena_at(struct PipelineDepCtx * ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct PipelineDepCtx * ctx, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t pipeline_dep_ctx_import_path_len(struct PipelineDepCtx * ctx, int32_t idx);
extern uint8_t pipeline_dep_ctx_import_path_byte_at(struct PipelineDepCtx * ctx, int32_t idx, int32_t off);
extern void pipeline_dep_ctx_import_path_copy64(struct PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern int32_t pipeline_dep_ctx_ndep(struct PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_set_ndep(struct PipelineDepCtx * ctx, int32_t n);
extern int32_t pipeline_ctx_append_lib_root(struct PipelineDepCtx * ctx, uint8_t * path, int32_t len);
extern int32_t pipeline_ctx_lib_root_count(struct PipelineDepCtx * ctx);
extern int32_t pipeline_ctx_lib_root_len(struct PipelineDepCtx * ctx, int32_t i);
extern void pipeline_ctx_lib_root_copy(struct PipelineDepCtx * ctx, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t pipeline_module_func_alloc_slot(struct Module * module);
extern int32_t pipeline_module_func_ref_at(struct Module * module, int32_t func_index);
extern void pipeline_module_func_ref_set(struct Module * module, int32_t func_index, int32_t func_ref);
extern void pipeline_module_func_set_return_type(struct Module * module, int32_t fi, int32_t type_ref);
extern void pipeline_module_func_set_body_ref(struct Module * module, int32_t fi, int32_t body_ref);
extern void pipeline_module_func_set_body_expr_ref(struct Module * module, int32_t fi, int32_t body_expr_ref);
extern void pipeline_module_func_set_is_extern(struct Module * module, int32_t fi, int32_t is_extern);
extern void pipeline_module_func_set_is_variadic(struct Module * module, int32_t fi, int32_t is_variadic);
extern int32_t pipeline_module_func_is_variadic_at(struct Module * module, int32_t fi);
extern void pipeline_module_func_set_num_params(struct Module * module, int32_t fi, int32_t n);
extern void pipeline_module_func_set_num_generic_params(struct Module * module, int32_t fi, int32_t n);
extern int32_t pipeline_module_func_return_type_at(struct Module * module, int32_t fi);
extern int32_t pipeline_module_func_num_generic_params_at(struct Module * module, int32_t fi);
extern int32_t pipeline_module_func_name_equal_at(struct Module * module, int32_t fi, uint8_t * name, int32_t name_len);
extern uint8_t pipeline_module_func_name_byte_at(struct Module * module, int32_t fi, int32_t i);
extern int32_t pipeline_module_func_body_expr_ref_at(struct Module * module, int32_t fi);
int ref_is_null(int32_t ref) {
  return (ref ==0);
}
int32_t ast_placeholder(void) {
  return 0;
}
void expr_layout_prime_call_resolved(void) {
  struct Expr _tail = (struct Expr){ .kind = 0, .resolved_type_ref = 0, .line = 0, .col = 0, .as_operand_ref = 0, .as_target_type_ref = 0, .call_resolved_func_index = -(1), .call_resolved_dep_index = -(1) };
  (void)(((_tail.call_num_type_args) = 0));
  (void)(((_tail.call_resolved_func_index) = -(1)));
}
void func_layout_prime_generic_params(void) {
  uint8_t name0[64] = {};
  struct Func f0 = (struct Func){ .name = name0, .name_len = 0, .param_base = 0, .num_params = 0, .num_generic_params = 0, .return_type_ref = 0, .body_ref = 0, .body_expr_ref = 0, .is_extern = 0, .is_async = 0 };
  (void)(((f0.num_generic_params) = 0));
}
void ast_arena_init(struct ASTArena * arena) {
  (void)(expr_layout_prime_call_resolved());
  (void)(func_layout_prime_generic_params());
  (void)(((arena->num_types) = 0));
  (void)(((arena->num_exprs) = 0));
  (void)(((arena->num_blocks) = 0));
  (void)(((arena->num_funcs) = 0));
}
int32_t ast_arena_type_alloc(struct ASTArena * arena) {
  int32_t ref = 0;
  (void)((ref = pipeline_arena_type_alloc(arena)));
  if ((ref <=0)) {
    return 0;
  }
  return ref;
}
int32_t ast_arena_expr_alloc(struct ASTArena * arena) {
  int32_t ref = 0;
  (void)((ref = pipeline_arena_expr_alloc(arena)));
  if ((ref <=0)) {
    return 0;
  }
  return ref;
}
int32_t ast_arena_block_alloc(struct ASTArena * arena) {
  int32_t ref = 0;
  (void)((ref = pipeline_arena_block_alloc(arena)));
  if ((ref <=0)) {
    return 0;
  }
  return ref;
}
extern struct Type ast_arena_type_get(struct ASTArena * arena, int32_t ref);
extern void ast_arena_type_set(struct ASTArena * arena, int32_t ref, struct Type t);
void expr_init_match_enum(struct Expr * e) {
  (void)(((e->match_arm_base) = 0));
  (void)(((e->enum_variant_tag) = 0));
}
extern int32_t pipeline_expr_append_call_arg(struct ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t pipeline_expr_call_arg_ref(struct ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_call_num_args_at(struct ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_type_args_at(struct ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_append_method_call_arg(struct ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t pipeline_expr_method_call_arg_ref(struct ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_append_match_arm(struct ASTArena * arena, int32_t expr_ref, int32_t result_ref, int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant, int32_t variant_index);
extern int32_t pipeline_expr_match_num_arms_at(struct ASTArena * arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_result_ref(struct ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_wildcard(struct ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_lit_val(struct ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(struct ASTArena * arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(struct ASTArena * arena, int32_t expr_ref, int32_t i);
extern void pipeline_expr_match_arm_set_wildcard(struct ASTArena * arena, int32_t expr_ref, int32_t i, int32_t v);
extern void pipeline_expr_match_arm_set_lit_val(struct ASTArena * arena, int32_t expr_ref, int32_t i, int32_t v);
extern void pipeline_expr_match_arm_set_enum_variant(struct ASTArena * arena, int32_t expr_ref, int32_t i, int32_t is_var, int32_t variant_index);
extern int32_t pipeline_expr_append_struct_lit_field(struct ASTArena * arena, int32_t expr_ref, uint8_t * name_bytes, int32_t name_len, int32_t init_ref);
extern int32_t pipeline_expr_append_array_lit_elem(struct ASTArena * arena, int32_t expr_ref, int32_t elem_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ASTArena * arena, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_init_call_resolve_at_ref(struct ASTArena * arena, int32_t expr_ref);
extern void pipeline_expr_apply_call_resolve(struct ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
void expr_init_call_resolve(struct ASTArena * arena, int32_t expr_ref) {
  (void)(pipeline_expr_init_call_resolve_at_ref(arena, expr_ref));
  (void)(0);
  return;
}
void ast_expr_apply_call_resolve(struct ASTArena * arena, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix) {
  (void)(pipeline_expr_apply_call_resolve(arena, call_expr_ref, dep_ix, func_ix));
  (void)(0);
  return;
}
extern struct Expr ast_arena_expr_get(struct ASTArena * arena, int32_t ref);
extern void ast_arena_expr_set(struct ASTArena * arena, int32_t ref, struct Expr e);
extern struct Block ast_arena_block_get(struct ASTArena * arena, int32_t ref);
int ast_name_bytes_equal(uint8_t * a_nm, int32_t a_len, uint8_t * b_nm, int32_t b_len) {
  if (((a_len !=b_len) || (a_len <=0))) {
    return 0;
  }
  int32_t j = 0;
  while ((j < a_len)) {
    if (((a_nm)[j] !=(b_nm)[j])) {
      return 0;
    }
    (void)((j = (j + 1)));
  }
  return 1;
}
int32_t ast_block_final_expr_ref(struct ASTArena * a, int32_t body_ref) {
  if (((body_ref <=0) || (body_ref > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk = { 0 };
  (void)((blk = ast_arena_block_get(a, body_ref)));
  return (blk.final_expr_ref);
}
extern int implicit_tail_expr_disallowed_by_glue(struct ASTArena * a, int32_t expr_ref);
int ast_expr_disallows_implicit_tail(struct ASTArena * a, int32_t expr_ref) {
  return implicit_tail_expr_disallowed_by_glue(a, expr_ref);
  return 0;
}
int32_t ast_block_num_consts(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nc = { 0 };
  (void)((blk_nc = ast_arena_block_get(a, br)));
  return (blk_nc.num_consts);
}
int32_t ast_block_num_lets(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nl = { 0 };
  (void)((blk_nl = ast_arena_block_get(a, br)));
  return (blk_nl.num_lets);
}
int32_t ast_block_num_loops(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nlp = { 0 };
  (void)((blk_nlp = ast_arena_block_get(a, br)));
  return (blk_nlp.num_loops);
}
int32_t ast_block_num_for_loops(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nfp = { 0 };
  (void)((blk_nfp = ast_arena_block_get(a, br)));
  return (blk_nfp.num_for_loops);
}
int32_t ast_block_num_if_stmts(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nif = { 0 };
  (void)((blk_nif = ast_arena_block_get(a, br)));
  return (blk_nif.num_if_stmts);
}
int32_t ast_block_num_regions(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nr = { 0 };
  (void)((blk_nr = ast_arena_block_get(a, br)));
  return (blk_nr.num_regions);
}
int32_t ast_block_region_body_ref(struct ASTArena * a, int32_t br, int32_t ri) {
  return pipeline_block_region_body_ref(a, br, ri);
  return 0;
}
int32_t ast_block_num_expr_stmts(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nes = { 0 };
  (void)((blk_nes = ast_arena_block_get(a, br)));
  return (blk_nes.num_expr_stmts);
}
int32_t ast_block_num_stmt_order(struct ASTArena * a, int32_t br) {
  if (((br <=0) || (br > (a->num_blocks)))) {
    return 0;
  }
  struct Block blk_nso = { 0 };
  (void)((blk_nso = ast_arena_block_get(a, br)));
  return (blk_nso.num_stmt_order);
}
uint8_t ast_block_stmt_order_kind(struct ASTArena * a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_kind(a, br, si);
  return 0;
}
int32_t ast_block_stmt_order_idx(struct ASTArena * a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_idx(a, br, si);
  return 0;
}
int32_t ast_block_const_init_ref(struct ASTArena * a, int32_t br, int32_t ci) {
  return pipeline_block_const_init_ref(a, br, ci);
  return 0;
}
int32_t ast_block_const_type_ref(struct ASTArena * a, int32_t br, int32_t ci) {
  return pipeline_block_const_type_ref(a, br, ci);
  return 0;
}
int32_t ast_block_let_init_ref(struct ASTArena * a, int32_t br, int32_t li) {
  return pipeline_block_let_init_ref(a, br, li);
  return 0;
}
int32_t ast_block_let_type_ref(struct ASTArena * a, int32_t br, int32_t li) {
  return pipeline_block_let_type_ref(a, br, li);
  return 0;
}
int32_t ast_block_expr_stmt_ref(struct ASTArena * a, int32_t br, int32_t ei) {
  return pipeline_block_expr_stmt_ref(a, br, ei);
  return 0;
}
int32_t ast_block_while_cond_ref(struct ASTArena * a, int32_t br, int32_t wi) {
  return pipeline_block_while_cond_ref(a, br, wi);
  return 0;
}
int32_t ast_block_while_body_ref(struct ASTArena * a, int32_t br, int32_t wi) {
  return pipeline_block_while_body_ref(a, br, wi);
  return 0;
}
int32_t ast_block_for_init_ref(struct ASTArena * a, int32_t br, int32_t fi) {
  return pipeline_block_for_init_ref(a, br, fi);
  return 0;
}
int32_t ast_block_for_cond_ref(struct ASTArena * a, int32_t br, int32_t fi) {
  return pipeline_block_for_cond_ref(a, br, fi);
  return 0;
}
int32_t ast_block_for_step_ref(struct ASTArena * a, int32_t br, int32_t fi) {
  return pipeline_block_for_step_ref(a, br, fi);
  return 0;
}
int32_t ast_block_for_body_ref(struct ASTArena * a, int32_t br, int32_t fi) {
  return pipeline_block_for_body_ref(a, br, fi);
  return 0;
}
int32_t ast_block_if_cond_ref(struct ASTArena * a, int32_t br, int32_t ii) {
  return pipeline_block_if_cond_ref(a, br, ii);
  return 0;
}
int32_t ast_block_if_then_body_ref(struct ASTArena * a, int32_t br, int32_t ii) {
  return pipeline_block_if_then_body_ref(a, br, ii);
  return 0;
}
int32_t ast_block_if_else_body_ref(struct ASTArena * a, int32_t br, int32_t ii) {
  return pipeline_block_if_else_body_ref(a, br, ii);
  return 0;
}
int32_t ast_block_resolve_var_to_type_ref(struct ASTArena * a, int32_t block_ref, uint8_t * vname, int32_t vlen) {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
  return 0;
}
void ast_arena_patch_block_parent_links(struct ASTArena * arena, int32_t block_ref, int32_t parent_ref) {
  int32_t stack_blk[256] = {};
  int32_t stack_par[256] = {};
  int32_t sp = 0;
  int32_t cur = 0;
  int32_t par = 0;
  int32_t wb = 0;
  int32_t fb = 0;
  int32_t tb = 0;
  int32_t eb = 0;
  int32_t rgb = 0;
  int32_t i = 0;
  if (((block_ref <=0) || (block_ref > (arena->num_blocks)))) {
    return;
  }
  (void)(((stack_blk)[sp] = block_ref));
  (void)(((stack_par)[sp] = parent_ref));
  (void)((sp = (sp + 1)));
  while ((sp > 0)) {
    struct Block b = { 0 };
    (void)((sp = (sp - 1)));
    (void)((cur = (stack_blk)[sp]));
    (void)((par = (stack_par)[sp]));
    if (((cur <=0) || (cur > (arena->num_blocks)))) {
      continue;
    }
    if ((par !=0)) {
      struct Block b_head = { 0 };
      (void)((b_head = ast_arena_block_get(arena, cur)));
      if (((b_head.parent_block_ref) ==0)) {
        (void)(((b_head.parent_block_ref) = par));
        (void)(ast_arena_block_set(arena, cur, b_head));
      }
    }
    (void)((b = ast_arena_block_get(arena, cur)));
    (void)((i = 0));
    while ((i < (b.num_loops))) {
      (void)((wb = ast_block_while_body_ref(arena, cur, i)));
      if (((wb > 0) && (sp < 256))) {
        (void)(((stack_blk)[sp] = wb));
        (void)(((stack_par)[sp] = cur));
        (void)((sp = (sp + 1)));
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < (b.num_for_loops))) {
      (void)((fb = ast_block_for_body_ref(arena, cur, i)));
      if (((fb > 0) && (sp < 256))) {
        (void)(((stack_blk)[sp] = fb));
        (void)(((stack_par)[sp] = cur));
        (void)((sp = (sp + 1)));
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < (b.num_if_stmts))) {
      (void)((tb = ast_block_if_then_body_ref(arena, cur, i)));
      if (((tb > 0) && (sp < 256))) {
        (void)(((stack_blk)[sp] = tb));
        (void)(((stack_par)[sp] = cur));
        (void)((sp = (sp + 1)));
      }
      (void)((eb = ast_block_if_else_body_ref(arena, cur, i)));
      if (((eb > 0) && (sp < 256))) {
        (void)(((stack_blk)[sp] = eb));
        (void)(((stack_par)[sp] = cur));
        (void)((sp = (sp + 1)));
      }
      (void)((i = (i + 1)));
    }
    (void)((i = 0));
    while ((i < (b.num_regions))) {
      (void)((rgb = ast_block_region_body_ref(arena, cur, i)));
      if (((rgb > 0) && (sp < 256))) {
        (void)(((stack_blk)[sp] = rgb));
        (void)(((stack_par)[sp] = cur));
        (void)((sp = (sp + 1)));
      }
      (void)((i = (i + 1)));
    }
  }
}
extern void ast_arena_block_set(struct ASTArena * arena, int32_t ref, struct Block b);
int32_t ast_arena_func_alloc(struct ASTArena * arena) {
  int32_t ref = 0;
  (void)((ref = pipeline_arena_func_alloc(arena)));
  if ((ref <=0)) {
    return 0;
  }
  return ref;
}
extern struct Func ast_arena_func_get(struct ASTArena * arena, int32_t ref);
extern void ast_arena_func_set(struct ASTArena * arena, int32_t ref, struct Func f);
