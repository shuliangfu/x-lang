/**
 * pipeline_glue.c — 与 -E 产出的 pipeline_gen.c 同属一个翻译单元的 C 胶水代码。
 *
 * 用法：pipeline_gen.c 末尾有 #include "pipeline_glue.c"（由 runtime.c -E 或 build_patch 追加），
 * 编译 pipeline_gen.c 时由 cc 在同一 TU 内包含本文件，故可直接使用上方已定义的 ast_* / codegen_* 等类型。
 * 不单独编译；无补丁、无 sed，所有逻辑在此源文件内从根源提供。
 *
 * parser.x 聚合 -o 可执行时，runtime 在含入前 #define XLANG_PARSER_EXE_PIPELINE_GLUE：省略依赖
 * platform_elf_ElfCodegenCtx 完整定义与 codegen.o 转发符号的片段，避免单文件 TU 编译失败。
 *
 * ── extern 消费者索引（10.4.2 自举；删函数前 grep 本表）────────────────────────────
 * | 符号 | 消费者 |
 * |------|--------|
 * | parser_slice_from_buf / lexer_parser_slice_from_buf / pipeline_source_slice | parser.x, lexer.x, pipeline.x |
 * | parser_lex_from_lexer_result_ptr_into | parser.x（*LexerResult → *Lexer，避 typeck 链式 FIELD_ACCESS） |
 * | pipeline_run_x_pipeline | runtime.c（C 包装 buf+len） |
 * | pipeline_sizeof_* / pipeline_arena_offset_num_types | parser.x, lsp_diag.x；**PipelineDepCtx 增字段时须同步** runtime.c / lsp_diag_pipeline_sizes.c / ast.x |
 * | pipeline_expr_ref_is_assign_lvalue | parser.x |
 * | compound_assign_token_to_expr_kind_from_glue | parser.x |
 * | pipeline_expr_* / ast_pipeline_expr_* / implicit_tail_expr_disallowed_by_glue | ast.x, typeck.x |
 * | pipeline_type_* / pipeline_module_struct_layout_* | typeck.x, codegen.x |
 * | pipeline_module_func_* / pipeline_arena_func_* | parser.x |
 * | pipeline_asm_array_lit_elem_type_ref | asm/backend.x |
 * | pipeline_asm_cmp_cc_for_expr_kind_ord / pipeline_asm_arm64_cset_cond_enc_from_cc | asm/backend.x, arch/arm64_enc.x |
 * | pipeline_module_func_is_extern_at / pipeline_module_func_body_ref_at / pipeline_module_func_name_len_at | asm/backend.x, arch/arm64.x |
 * | pipeline_backend_get_return_expr_ref_at / pipeline_arm64_get_return_lit_ref_at | asm/backend.x, arch/arm64.x |
 * | std_io_driver_submit_*_batch_buf | pipeline_gen.c 同 TU（io.o 批量读写） |
 * | driver_get_module_num_funcs / driver_get_module_main_func_index | runtime.c 烟测 |
 * | driver_diagnostic_entry_* | pipeline.x（日常 no-op） |
 * 原因：X/asm 对大 struct 按值读写字段或 enum 比较易撕裂/ typeck 失败，暂保留 C 指针读池。
 */

#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "xlang_weak.h"
#include "token.h"
#include "target_cpu.h"
#include "simd_enc.h"
#include "simd_loop.h"
#include "async_asm_pool.h"


/* wave240 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product pipeline_glue residual raw getenv call sites migrate to this face
 * (debug/trace/WPO/SIMD/pad/hot/stack-escape gates; same G.7 pattern as wave238/239 rt_run_*).
 * Header may already declare; explicit for this TU (included into pipeline_gen).
 */
extern char *link_abi_getenv(const char *name);
/* wave248 G.7: shell via public pure thin link_abi_system (wave224 → _impl host system);
 * not raw libc system. Cap residual host system stays only link_abi_system_impl.
 * PLATFORM: SHARED — debug curl residual (try_propagate report) migrates to this face
 * (same G.7 pattern as wave226 pure/modular twins + wave247 mega dual).
 */
extern int link_abi_system(const char *cmd);

struct xlang_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

struct backend_AsmFuncCtx;

typedef struct {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
  int32_t label_counter;
  struct ast_Module *module_ref;
  uint8_t loop_break_label_stack[512];
  int32_t loop_break_len_stack[8];
  uint8_t loop_continue_label_stack[512];
  int32_t loop_continue_len_stack[8];
  uint8_t break_label[128];
  int32_t break_len;
  uint8_t continue_label[128];
  int32_t continue_len;
  int32_t loop_label_depth;
  void *dep_pipe;
  uint8_t tail_join_label[128];
  int32_t tail_join_label_len;
} pipeline_glue_AsmFuncCtxLayout;

static pipeline_glue_AsmFuncCtxLayout *pipeline_asm_ctx_layout(struct backend_AsmFuncCtx *ctx) {
  return (pipeline_glue_AsmFuncCtxLayout *)ctx;
}

/** ast_pool.c 提供；须在下方 glue 之前声明（ast_pool.c 在文件末尾 #include）。 */
struct ast_Func *pipeline_module_func_ptr(struct ast_Module *m, int32_t func_index);
int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                        int32_t goto_target_len, int32_t return_expr_ref);
int32_t pipeline_module_func_alloc_slot(struct ast_Module *m);
void pipeline_module_func_name_write(struct ast_Module *m, int32_t func_index, uint8_t *name_bytes, int32_t name_len);
void pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n);
void pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref);
void pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref);
void pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref);
void pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern);
void pipeline_module_func_set_is_async(struct ast_Module *m, int32_t fi, int32_t is_async);
void pipeline_module_func_set_is_used(struct ast_Module *m, int32_t fi, int32_t is_used);
int32_t pipeline_module_func_is_used_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_naked(struct ast_Module *m, int32_t fi, int32_t is_naked);
int32_t pipeline_module_func_is_naked_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_entry(struct ast_Module *m, int32_t fi, int32_t is_entry);
int32_t pipeline_module_func_is_entry_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_no_mangle(struct ast_Module *m, int32_t fi, int32_t is_no_mangle);
int32_t pipeline_module_func_is_no_mangle_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_interrupt(struct ast_Module *m, int32_t fi, int32_t is_interrupt);
int32_t pipeline_module_func_is_interrupt_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_variadic(struct ast_Module *m, int32_t fi, int32_t is_variadic);
int32_t pipeline_module_func_is_variadic_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_set_is_export(struct ast_Module *m, int32_t fi, int32_t is_export);
int32_t pipeline_module_func_is_export_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_struct_layout_set_is_export(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_struct_layout_is_export_at(struct ast_Module *m, int32_t idx);
void pipeline_module_enum_set_is_export(struct ast_Module *m, int32_t idx, int32_t v);
int32_t pipeline_module_enum_is_export_at(struct ast_Module *m, int32_t idx);
void pipeline_module_top_level_let_set_is_export(struct ast_Module *m, int32_t idx, int32_t is_export);
int32_t pipeline_module_top_level_let_is_export_at(struct ast_Module *m, int32_t idx);
/** XLANG_VISIBILITY: 0=compat 1=warn 2=strict；默认 compat（迁移期）。 */
int32_t pipeline_visibility_mode(void);
/** 跨模块访问函数：compat 放行；warn 告警并放行；strict 要求 is_export。返回 1 允许 0 拒绝。 */
int32_t pipeline_visibility_allow_func(struct ast_Module *m, int32_t fi, int32_t cross_module);
void pipeline_module_func_ref_set(struct ast_Module *m, int32_t func_index, int32_t func_ref);
/** ast_pool.c 提供；pipeline_backend_get_return_expr_ref 在 #include ast_pool 之前调用。 */
int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name, int32_t enum_len,
                                                   uint8_t *variant_name, int32_t variant_len);

/** 当前 asm_codegen_ast_to_elf 正在发射的 module（定义见本文件后部 pipeline_asm_emit_set_module）。 */
static struct ast_Module *g_pipeline_asm_emit_module;
/** WPO-S3 / LANG-006 call-site CTFE: set by pipeline_typeck_set_active_ctx_c before check. */
static struct ast_Module *g_typeck_active_module;
/** 当前 asm emit 函数下标；供形参 *T 槽 load/leа 判定（driver compile.x state 等）。 */
static int32_t g_pipeline_asm_emit_func_index = -1;
/** 当前 emit 用的 AST arena（param homing 形参 kind 查询）。 */
static struct ast_ASTArena *g_pipeline_asm_emit_arena;
/** CALL 实参 emit 时对照的 callee 形参 type_ref（f32 须 32-bit 位型）。 */
static int32_t g_pipeline_asm_emit_call_param_ty_ref;
/** CALL 实参 emit 嵌套深度（>0 时 FIELD_ACCESS 可区分传址 struct 字段）。 */
static int32_t g_glue_emit_call_arg_depth;
/**
 * Large-struct (>16B) return home: stack slot holding the caller's dest pointer.
 * PLATFORM: LINUX+MACOS x86_64 SysV — hidden dest arrives in rdi, saved here.
 * PLATFORM: MACOS|ARM64 AAPCS64 — Indirect Result Location arrives in x8, saved here.
 * (-1 = current function is not an sret return target.)
 */
static int32_t g_pipeline_asm_sret_home_off = -1;
/**
 * 1 = current emit function writes large struct return via hidden dest (sret).
 * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 (x8).
 */
static int32_t g_pipeline_asm_func_sret_active = 0;
/** Current emit function sret return byte width (valid when >16). */
static int32_t g_pipeline_asm_func_sret_ret_sz = 0;
/**
 * CALL-side sret: how many GP arg slots shift (0 or 1).
 * PLATFORM: LINUX+MACOS x86_64 SysV only — rdi already holds dest, args start at rsi.
 * PLATFORM: MACOS|ARM64 AAPCS64 — x8 is separate from x0–x7; always 0 (no GP shift).
 */
static int32_t g_pipeline_asm_call_sret_reg_shift = 0;
/**
 * PLATFORM: SHARED — expected return type for import CALL/METHOD_CALL overload mangle.
 * Asm user -o with imports skips entry .x typeck (C precheck is a separate arena); zero-arg
 * overloads (vec.new) would otherwise pick first (Vec_i32). Let-init install sets this from
 * the declaration type (let v: Vec_u8 = vec.new()).
 */
static int32_t g_pipeline_asm_call_expected_ret_ty = 0;

void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref) {
  g_pipeline_asm_call_expected_ret_ty = type_ref > 0 ? type_ref : 0;
}

int32_t pipeline_asm_call_expected_ret_ty_c(void) {
  return g_pipeline_asm_call_expected_ret_ty;
}

int32_t pipeline_asm_emit_call_arg_active_c(void);
/** 当前 emit 块 scope（与 asm_ctx scope_block_ref 同步）；FIELD_ACCESS 查 let 类型用。 */
static int32_t g_pipeline_asm_emit_scope_block = 0;
/** 当前 asm emit 的 dep 池；import struct layout 查字段偏移用（WPO-S3 cross_ret 等）。 */
static struct ast_PipelineDepCtx *g_pipeline_asm_emit_dep_pipe;
/** backend_try_inline / SIMD emit：读取当前 dep 池（定义见本文件后部）。 */
struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);
/** 当前 asm_codegen_ast_to_elf 正在写入的 elf_ctx（PGO-Lite emit 段切换）。 */
static struct platform_elf_ElfCodegenCtx *g_pipeline_asm_emit_elf_ctx;

/** asm_ctx scope 设置（定义见本文件后部；前置声明供 glue_asm_ctx_set_scope_block 调用）。 */
void asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref);

/* wave1152 G.7: glue_asm_ctx_set_scope_block migrated to
 * pipeline_asm_emit_block_body.c EOF (block scope setter; colocated
 * with block_body_sync domain — all 13 callsites are in block_body.c /
 * block_if_stmt.c / fold_count_up_while.c / glue.c:5121, all after
 * block_body.c #include at L3623).
 *
 * Static fwd decl at block_body.c:53 (callsites at lines 295/700/865
 * precede EOF definition). Deps g_pipeline_asm_emit_scope_block (L182)
 * + asm_ctx_set_scope_block (L191) both before #include L3623 — visible.
 * PLATFORM: SHARED. */
int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
/* wave379/wave387: labeled pool accessors (stmt_order kind=7 goto/label/labeled-return). */
int32_t pipeline_block_num_labeled_stmts(struct ast_ASTArena *a, int32_t br);
int32_t pipeline_block_labeled_is_goto(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_labeled_label_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_labeled_label_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_labeled_goto_target_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_labeled_goto_target_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
/** MEM-C1：块内 region/with_arena 第 ri 条 cap expr ref；0 表示普通 region。 */
int32_t pipeline_block_region_with_arena_cap_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Func *pipeline_arena_func_ptr(struct ast_ASTArena *a, int32_t ref);
int32_t pipeline_arena_type_alloc(struct ast_ASTArena *a);
/** DOD-S1 SoA：定义见 pipeline_typeck_soa.c（文件后部 #include）；emit 段前置调用。 */
int32_t pipeline_typeck_field_soa_index_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t base_ref);
int32_t pipeline_arena_expr_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_block_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_func_alloc(struct ast_ASTArena *a);
int32_t pipeline_module_struct_layout_alloc(struct ast_Module *m);
void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                              int32_t fname_len, int32_t ftype_ref, int32_t foff);
void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap);
int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
extern int typeck_float64_bits_lo(double d);
extern int typeck_float64_bits_hi(double d);
/** 模块顶层 const 字面量回落（非 hoist 目标函数内 VAR AF_INET 等）；定义见 ast_pool.c。 */
extern int32_t asm_module_top_level_const_lit_i32(struct ast_Module *m, struct ast_ASTArena *a, uint8_t *name,
                                                   int32_t name_len, int32_t *out_imm);
extern int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t li, int32_t depth);
extern int32_t typeck_x_type_align_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t li, int32_t depth);
int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);
int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_struct_layout_repr_compatible_at(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_set_field_offset(struct ast_Module *m, int32_t li, int32_t j, int32_t foff);
int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_set_field_align(struct ast_Module *m, int32_t li, int32_t j, int32_t al);
/** func 形参池读 API；glue 内 asm 转发在 ast_pool.c 定义之前调用。 */
int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t func_index, uint8_t *name, int32_t name_len);
int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                            uint8_t *dst);
int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *m, int32_t func_index, uint8_t *var_name,
                                                     int32_t var_name_len);
int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
/** asm .o 失败时打印 ElfCodegenCtx 计数（ast_pool.c）。 */
void pipeline_elf_ctx_diag_stderr(uint8_t *ctx_bytes);
/** macho/elf：reloc_sym_names 行读写（ast_pool.c）。 */
uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst);
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset);
int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_pgo_hot_enabled(void);
void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot);
int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                      int32_t imm_bits);
int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
/** PLATFORM: MACOS pure-asm MH_OBJECT; strong platform_macho_write overrides Darwin weak stubs. */
int32_t pipeline_macho_write_o_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf);
/* wave1100 G.7: pipeline_asm_modlet_name_is_shared + load_to_rax + store_from_rax +
 * prepare_and_emit migrated to pipeline_asm_emit_modlet.c (same-TU #include at L2291,
 * before all callsites: assign.c store + expr_rec.c load + glue.c L8257+ prepare/seed). */
/* ast_pool.c — SHN_COMMON object symbols (modlet + wave341 non-const array-lit durable). */
int32_t pipeline_elf_ctx_add_common_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t size,
                                        int32_t align);
int32_t pipeline_elf_ctx_total_code_len(uint8_t *ctx_bytes);
int32_t pipeline_asm_wpo_pgo_is_hot_func(struct ast_Module *m, int32_t fi);
/** ast_pool.c WPO emit 序（#include 之后定义）；ELF mega 主循环前向声明。 */
void pipeline_asm_wpo_pgo_emit_order_prepare(struct ast_Module *m);
int32_t pipeline_asm_wpo_pgo_emit_order_count(struct ast_Module *m);
int32_t pipeline_asm_wpo_pgo_emit_order_at(struct ast_Module *m, int32_t order_index);
int32_t asm_diag_start_func_skip(void);
int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index);
extern void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len);
/** pipeline.x：PipelineDepCtx / CodegenOutBuf 字段 glue（ast_pool.c）。 */
int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_module_num_funcs(struct ast_Module *m);
int32_t pipeline_module_main_func_index(struct ast_Module *m);
int32_t pipeline_arena_num_types(struct ast_ASTArena *a);
int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx);
int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
uint8_t pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out);
void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n);

/* wave1193 G.7: parser_diagnostic cluster (4 fns) migrated to
 * pipeline_parse_orch.c EOF. Colocated with parse orchestration
 * domain — all are thin extern forwarders to driver_diagnostic_*
 * in runtime.c. PLATFORM: SHARED. */

/* wave1153 dead code delete: parser_diagnostic_parse_commit_shape removed
 * (static wrapper delegating to driver_diagnostic_parse_commit_shape extern;
 * zero callsites in glue.c TU — superseded by runtime_driver_diagnostic.x
 * export function which is linked independently). */
/* wave1185 G.7: parser result copy/lex/slice helper cluster (20 fns + 4 typedefs)
 * migrated to pipeline_parser_result.c (same-TU #include). Members: parser_slice_from_buf /
 * lexer_parser_slice_from_buf / pipeline_source_slice / parser_lexer_pos_before /
 * parser_lex_from_lexer_result_{ptr,val}_into / parser_lex_copy_from_collect_imports /
 * parser_lex_from_onefunc_result_ptr_into / parser_lex_from_extern_parse_result_ptr_into /
 * pipeline_parser_extern_parse_set_fail_c / pipeline_parser_library_result_copy_into_c /
 * pipeline_parser_try_skip_result_copy_into_c / parser_lex_from_try_skip_result_val_into /
 * parser_lex_from_library_result_val_into / pipeline_parser_set_onefunc_fail_c /
 * pipeline_parser_onefunc_buf_into_set_success_c + 4 glue-local typedefs
 * (ExternParseResult / LibraryParseResult / TrySkipAllowResult / OneFuncResult).
 * Depends on pipeline_module_fill_u8_64_from_src_c (fwd decl at L229). All extern. */
#include "pipeline_parser_result.c"

#ifndef XLANG_PARSER_EXE_PIPELINE_GLUE
/* C 包装：以 (data, len) 形式调用 pipeline，impl 内用 parse_into_with_init_buf 解析，无需组 slice。 */
extern int32_t pipeline_run_x_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);

int32_t pipeline_run_x_pipeline(struct ast_Module *module, struct ast_ASTArena *arena, const uint8_t *source_data, size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  return pipeline_run_x_pipeline_impl(module, arena, (uint8_t *)source_data, source_len, out_buf, ctx);
}
#endif /* !XLANG_PARSER_EXE_PIPELINE_GLUE */

/* wave1193 G.7: sizeof cluster (5 fns) migrated to pipeline_parse_orch.c
 * EOF. Excluded: pipeline_sizeof_elf_ctx remains here (has
 * #ifdef XLANG_PARSER_EXE_PIPELINE_GLUE guard not applicable to
 * parse_orch.c context). PLATFORM: SHARED LP64. */
#ifndef XLANG_PARSER_EXE_PIPELINE_GLUE
size_t pipeline_sizeof_elf_ctx(void) { return sizeof(struct platform_elf_ElfCodegenCtx); }
#else
/** parser 聚合 exe TU 不含 ElfCodegenCtx 定义：占位返回 0（该路径不调 asm 全流程 sizeof）。 */
size_t pipeline_sizeof_elf_ctx(void) { return (size_t)0; }
#endif /* XLANG_PARSER_EXE_PIPELINE_GLUE */

#include <stdio.h>
/* wave1193 G.7: pipeline_debug_module_funcs + driver_get_module_num_funcs
 * + driver_get_module_main_func_index (3 fns) migrated to
 * pipeline_parse_orch.c EOF. Colocated with parse orchestration
 * diagnostic domain. PLATFORM: SHARED. */

/** 这些 arena/block 查询与 body trace helper 在本 TU 后段实现；前置声明用于前面的调试入口。 */
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);

/* wave1193 G.7: driver_diagnostic_entry_module + driver forwarding
 * cluster + driver_diagnostic_entry_block_after_parse (15 fns +
 * 5 driver_* extern decls) migrated to pipeline_parse_orch.c EOF.
 * Colocated with parse/load/typeck orchestration domain — all are
 * thin extern forwarders to driver_* in runtime.c. driver_*
 * extern decls (driver_diagnostic_after_entry_parse /
 * driver_pipeline_entry_source_len / driver_typeck_skip_large_entry /
 * driver_asm_build_skip_typeck / driver_diagnostic_pipe_marker /
 * driver_check_only_get / driver_x_pipeline_skip_typeck_get) are
 * redeclared locally inside the migrated function bodies in
 * parse_orch.c. PLATFORM: SHARED. */
/* Retained extern: driver_asm_build_skip_typeck still called by
 * pipeline_asm_emit_struct_lit.c (L1027/L1071, #include at L1663
 * before parse_orch.c #include at L4263). */
extern int32_t driver_asm_build_skip_typeck(void);

/* std.io.driver 单次 _buf 声明与 inline 已由 -E 产出在 pipeline_gen.c 顶部（runtime.c -E 路径 preamble），此处仅保留批量读写桩。 */

struct std_io_driver_Buffer;

/* std.io.driver 批量读写桩：pipeline_gen.c 同 TU 已定义 struct std_io_driver_Buffer；io.o 提供 io_read_batch_buf/io_write_batch_buf，供 xlang_x 链接时解析。 */
extern ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);

int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ref);
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref);
/* wave1166: type pool accessors migrated to ast_pool_type.c (via ast_pool.c
 * #include at L5058). Fwd decls for callsites before that #include. */
int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ref);
int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
int32_t pipeline_module_struct_layout_packed_at(struct ast_Module *m, int32_t layout_idx);
int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord);
int32_t pipeline_typeck_get_dep_return_type_in_caller_arena_c(int32_t from_dep_index, int32_t dep_return_type_ref,
                                                              struct ast_ASTArena *caller_arena,
                                                              struct ast_PipelineDepCtx *ctx);
int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(struct ast_ASTArena *arena, int32_t call_expr_ref);
int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index);
void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst);
/* wave1175: asm-prefixed module func forwarders migrated to
 * ast_pool_module_func.c EOF. Fwd decls for callsites before ast_pool.c
 * #include at L5055. */
int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_asm_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_asm_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
void pipeline_asm_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index, uint8_t *dst);

/* wave1194 G.7: std_io_driver batch read/write stubs (2 fns) +
 * pipeline_expr_ref_is_assign_lvalue + compound_assign_token_to_expr_kind_from_glue
 * (2 fns) migrated to pipeline_parse_orch.c EOF (same-TU #include at L4104).
 * Colocated with parse/load/typeck orchestration domain — all are
 * parser-facing helpers (TokenKind→ExprKind mapping, lvalue check) or
 * io driver stubs (batch read/write forwarders to io.o).
 * glue_arena_expr_kind_at_ref (static) retained here — also called by
 * implicit_tail_expr_disallowed_by_glue (L672) + pipeline_expr_kind_ord_at
 * (L2396); visible to parse_orch.c via same-TU definition at L433 above.
 * PLATFORM: SHARED. */
static enum ast_ExprKind glue_arena_expr_kind_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return ast_ExprKind_EXPR_LIT;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->kind : ast_ExprKind_EXPR_LIT;
}

/* wave1101 G.7: codegen outbuf append domain (4 functions + macro) migrated to
 * pipeline_codegen_outbuf.c (same-TU #include). Members:
 * glue_codegen_out_append_bytes / _cstr / _int / _byte.
 * PLATFORM: SHARED. */
#include "pipeline_codegen_outbuf.c"

/**
 * C-backend float literal emit for codegen.x emit_expr (EXPR_FLOAT_LIT).
 * Purpose: host snprintf of a real decimal/hex-free C double token into CodegenOutBuf.
 * Prefer float_val; if float_val is 0.0 but bits_lo/hi are non-zero, reconstruct via IEEE bits
 * (little-endian lo/hi layout matches typeck_float64_bits_lo/hi).
 * Returns 0 on success, -1 on failure. Integer-looking tokens get a trailing ".0".
 * PLATFORM: SHARED — product M2 force-regen of codegen.x links this; also mirrored in
 * seeds/pipeline_glue_strict_minimal.from_x.c for Darwin g05 (no full standalone glue).
 */
int32_t pipeline_codegen_emit_float_lit_c(struct codegen_CodegenOutBuf *out, double float_val,
                                         int32_t bits_lo, int32_t bits_hi) {
  char buf[64];
  int n;
  int i;
  int has_dot = 0;
  int has_e = 0;
  double v = float_val;
  union {
    double d;
    struct {
      uint32_t lo;
      uint32_t hi;
    } w;
  } u;

  if (!out)
    return -1;
  if (v == 0.0 && (bits_lo != 0 || bits_hi != 0)) {
    u.w.lo = (uint32_t)bits_lo;
    u.w.hi = (uint32_t)bits_hi;
    v = u.d;
  }
  n = snprintf(buf, sizeof(buf), "%.17g", v);
  if (n <= 0 || n >= (int)sizeof(buf))
    return -1;
  for (i = 0; i < n; i++) {
    if (buf[i] == '.' || buf[i] == ',')
      has_dot = 1;
    if (buf[i] == 'e' || buf[i] == 'E')
      has_e = 1;
  }
  if (!has_dot && !has_e && n < (int)sizeof(buf) - 3) {
    buf[n++] = '.';
    buf[n++] = '0';
    buf[n] = '\0';
  }
  return glue_codegen_out_append_cstr(out, buf);
}

/**
 * let s: T[] = arr：写出 { .data = arr, .length = N }（对齐 codegen.c codegen_init / codegen.x）。
 * wave348: also `let s: T[] = b.a` (FIELD_ACCESS fixed TYPE_ARRAY).
 * @return 1 已写出；0 不适用；-1 失败。
 * PLATFORM: SHARED host-C (dup of seed when OMIT_X_DUP not set).
 */
#if !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU) && !defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS)
int32_t codegen_try_emit_slice_init_from_array_var(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                   int32_t block_ref, int32_t let_idx, int32_t let_type_ref,
                                                   int32_t linit_ref) {
  struct ast_Expr *init_pe;
  struct ast_Expr *base_pe;
  int32_t arr_sz = 0;
  int32_t li;
  int32_t vlen;
  int32_t is_field = 0;
  uint8_t vname[128];
  if (!arena || !out || block_ref <= 0 || let_type_ref <= 0 || linit_ref <= 0 || linit_ref > arena->num_exprs)
    return 0;
  if (pipeline_type_kind_ord_at(arena, let_type_ref) != (int32_t)ast_TypeKind_TYPE_SLICE)
    return 0;
  init_pe = pipeline_arena_expr_ptr(arena, linit_ref);
  if (!init_pe)
    return 0;
  if (init_pe->kind == (int32_t)ast_ExprKind_EXPR_VAR) {
    vlen = pipeline_expr_var_name_len(arena, linit_ref);
    if (vlen <= 0)
      return 0;
    pipeline_expr_var_name_into(arena, linit_ref, vname);
    for (li = 0; li < let_idx; li++) {
      int32_t nlen = pipeline_block_let_name_len(arena, block_ref, li);
      if (nlen == vlen && nlen > 0) {
        int32_t match = 1;
        int32_t ci;
        uint8_t nb[128];
        pipeline_block_let_name_copy64(arena, block_ref, li, nb);
        for (ci = 0; ci < nlen; ci++) {
          if (nb[ci] != vname[ci]) {
            match = 0;
            break;
          }
        }
        if (match) {
          int32_t tr = pipeline_block_let_type_ref(arena, block_ref, li);
          if (pipeline_type_kind_ord_at(arena, tr) == 10) {
            arr_sz = pipeline_type_array_size_at(arena, tr);
            break;
          }
        }
      }
    }
    if (arr_sz <= 0 && init_pe->resolved_type_ref > 0 &&
        pipeline_type_kind_ord_at(arena, init_pe->resolved_type_ref) == (int32_t)ast_TypeKind_TYPE_ARRAY)
      arr_sz = pipeline_type_array_size_at(arena, init_pe->resolved_type_ref);
  } else if (init_pe->kind == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS &&
             init_pe->field_access_field_len > 0 && init_pe->field_access_base_ref > 0 &&
             init_pe->field_access_base_ref <= arena->num_exprs) {
    /* wave348: let s: T[] = b.a */
    is_field = 1;
    base_pe = pipeline_arena_expr_ptr(arena, init_pe->field_access_base_ref);
    if (!base_pe || base_pe->kind != (int32_t)ast_ExprKind_EXPR_VAR || base_pe->var_name_len <= 0)
      return 0;
    vlen = base_pe->var_name_len;
    if (vlen > 127)
      return 0;
    memcpy(vname, base_pe->var_name, (size_t)vlen);
    if (init_pe->resolved_type_ref > 0 &&
        pipeline_type_kind_ord_at(arena, init_pe->resolved_type_ref) == (int32_t)ast_TypeKind_TYPE_ARRAY)
      arr_sz = pipeline_type_array_size_at(arena, init_pe->resolved_type_ref);
  } else {
    return 0;
  }
  if (arr_sz <= 0 && is_field == 0)
    return 0;
  if (glue_codegen_out_append_byte(out, '{') != 0)
    return -1;
  if (glue_codegen_out_append_cstr(out, " .data = ") != 0)
    return -1;
  if (glue_codegen_out_append_bytes(out, vname, vlen) != 0)
    return -1;
  if (is_field) {
    if (glue_codegen_out_append_byte(out, '.') != 0)
      return -1;
    if (glue_codegen_out_append_bytes(out, init_pe->field_access_field_name, init_pe->field_access_field_len) != 0)
      return -1;
  }
  if (glue_codegen_out_append_cstr(out, ", .length = ") != 0)
    return -1;
  if (arr_sz > 0) {
    if (glue_codegen_out_append_int(out, arr_sz) != 0)
      return -1;
  } else if (is_field) {
    /* sizeof(base.field)/sizeof((base.field)[0]) */
    if (glue_codegen_out_append_cstr(out, "(sizeof(") != 0)
      return -1;
    if (glue_codegen_out_append_bytes(out, vname, vlen) != 0)
      return -1;
    if (glue_codegen_out_append_byte(out, '.') != 0)
      return -1;
    if (glue_codegen_out_append_bytes(out, init_pe->field_access_field_name, init_pe->field_access_field_len) != 0)
      return -1;
    if (glue_codegen_out_append_cstr(out, ")/sizeof((") != 0)
      return -1;
    if (glue_codegen_out_append_bytes(out, vname, vlen) != 0)
      return -1;
    if (glue_codegen_out_append_byte(out, '.') != 0)
      return -1;
    if (glue_codegen_out_append_bytes(out, init_pe->field_access_field_name, init_pe->field_access_field_len) != 0)
      return -1;
    if (glue_codegen_out_append_cstr(out, ")[0])") != 0)
      return -1;
  } else {
    return 0;
  }
  if (glue_codegen_out_append_cstr(out, " }") != 0)
    return -1;
  return 1;
}
#endif

/**
 * ast.x extern：块末若为 RETURN/PANIC/BREAK/CONTINUE，返回 1（禁止隐式尾）；非法 ref 视为 1。
 * 符号名 deliberately 无前缀，供 X「extern function」原样映射，避免与其它 ast_ast_* extern 串联重复前缀。
 */
/* wave1159 G.7: call_resolve cluster (8 extern fns) migrated to
 * pipeline_typeck_method_call.c EOF (colocated with method_call typeck
 * domain). Extern fwd decls below for callsites before #include L9703. */
void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                    int32_t func_ix);
int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);

int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return 1;
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  if (kd == ast_ExprKind_EXPR_RETURN || kd == ast_ExprKind_EXPR_PANIC ||
      kd == ast_ExprKind_EXPR_BREAK || kd == ast_ExprKind_EXPR_CONTINUE)
    return 1;
  return 0;
}

/* wave1166 G.7: type pool cold accessors cluster (8 fns) migrated to
 * ast_pool_type.c (included from ast_pool.c L895). Colocated with type
 * pool domain — all read/write ast_Type struct fields via pipeline_arena_type_ptr
 * (defined in ast_pool_arena.c, included before ast_pool_type.c at L886).
 *
 * Migrated: pipeline_type_named_name_into / region_label_into /
 * region_label_len_at / set_region_label_at / find_or_alloc_slice /
 * kind_ord_at / elem_ref_at / array_size_at (L2216 below, also removed).
 *
 * Forward decls retained:
 * - pipeline_type_kind_ord_at: L761 (before callsites throughout glue.c)
 * - pipeline_type_array_size_at: L762 + L1989 (before callsites + L2210
 *   pipeline_asm_emit_expr_rec.c #include)
 * Other 5 fns have no glue.c callsites before ast_pool.c #include at L5160
 * (sole callers are typeck_gen.c / codegen_gen.c seeds via extern).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * asm/backend.x asm_expr_array_elem_store_sz_bytes：从数组字面量 expr 池 ref 取 TYPE_ARRAY 的 elem_type_ref。
 * 无效、非数组或 elem 缺失时返回 0。在 C 内读池，避免 .x 中 `let e: Expr = ast_arena_expr_get` 后字段访问触发 typeck 失败，
 * 亦避免 backend import codegen 时 pipeline_type_* 调用被编成 codegen_ 前缀导致链接未定义。
 */
int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref) {
  int32_t arr_tr;
  int32_t tk;
  struct ast_Expr *ex;
  if (!arena || array_lit_expr_ref <= 0 || array_lit_expr_ref > arena->num_exprs)
    return 0;
  ex = pipeline_arena_expr_ptr(arena, array_lit_expr_ref);
  if (!ex)
    return 0;
  arr_tr = ex->resolved_type_ref;
  if (arr_tr <= 0)
    return 0;
  tk = pipeline_type_kind_ord_at(arena, arr_tr);
  /*
   * wave631 Cap residual pure: peel TYPE_SLICE (11) as well as TYPE_ARRAY (10).
   * Root: `let s: S24[] = [S24{…}, …]` stamps the lit as TYPE_SLICE; old gate only
   * accepted TYPE_ARRAY → elem_ty=0 → array_lit_elem_byte_sz defaulted 4 while INDEX
   * used NAMED layout stride 24 → durable COMMON packed 4B pointer halves (Ubuntu
   * pure-asm RO s[0].a+s[1].a=120≠11; host-C compound green). Fixed S24[N] lit was
   * already TYPE_ARRAY so green via vector_let_init. G.7: single elem-type face for
   * both aggregate stamps. PLATFORM: SHARED freestanding.
   */
  if (tk != 10 && tk != 11)
    return 0;
  return pipeline_type_elem_ref_at(arena, arr_tr);
}

/* wave1031 G.7: pipeline_asm_cmp_cc_for_expr_kind_ord +
 * pipeline_asm_arm64_cset_cond_enc_from_cc folded into
 * pipeline_asm_emit_cmp.c (same TU #include at L4407; no new DEPS).
 * Chinese docblocks converted to English per G.9. cmp.c is the sole
 * in-TU consumer of cmp_cc_for_expr_kind_ord; arm64_cset_cond_enc_from_cc
 * is also extern'd by arm64_enc.x / backend_enc_dispatch.x seeds — same
 * pipeline_x.o symbol, no link change. */
/**
 * seed asm 后端（asm_backend_partial.o）提供的 enc/emit 符号；在 C 内实现二元运算，
 * 避免 xlang-c -E 将 if/return 包进 statement expression 导致 emit_expr_elf fallthrough。
 */
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;

extern int32_t backend_emit_expr_elf_slow(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_epilogue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_prologue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t frame_size, int32_t ta);
extern int32_t asm_backend_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                         int32_t out_cap, int32_t *out_len);
extern int32_t asm_pipeline_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                          int32_t out_cap, int32_t *out_len);
extern int32_t asm_parser_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                          int32_t out_cap, int32_t *out_len);
extern int32_t asm_driver_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);
/** typeck EMIT_HEAVY 第二遍：桩路径 bl→typeck_x.o 同名符号（扩 __text，避免 mega X emit Abort）。 */
extern int32_t asm_typeck_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                        int32_t out_cap, int32_t *out_len);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
/** EXPR_FLOAT_LIT 64 位立即数入 rax/x0（backend.x backend_enc_mov_imm64_to_rax_arch）。 */
extern int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi,
                                                   int32_t ta);
extern int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_x0_sp_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_bytes,
                                                   int32_t ta);
extern int32_t backend_enc_push_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** arm64 INDEX binop：mov x2/x1 暂存 rbx（asm_backend_partial.o / build_asm/arm64_enc.o）。 */
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x2_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x2(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x2_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x9(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x9_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x10(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x10_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x10(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x10_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x11(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x11_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x11(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x11_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x12(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x12_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x12(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x12_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x13(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x13_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x13(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x13_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x14(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x14_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x14(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x14_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x15(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x15_to_rax(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_x15(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_x15_to_rbx(struct platform_elf_ElfCodegenCtx *elf_ctx);
/** arm64：从 outgoing 栈槽 slot 装入 xreg（与 enc_push_rax/rbx 的 16B 槽对齐）。 */
extern int32_t arch_arm64_enc_enc_ldr_sp_slot_to_xreg(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot,
                                                       int32_t reg);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t elem_sz,
                                                          int32_t ta);
extern int32_t asm_local_var_slot_holds_indirect_ptr(struct ast_ASTArena *arena, int32_t expr_ref,
                                                     struct ast_Module *mod, uint8_t *asm_ctx);
extern int32_t asm_ctx_scope_block_ref_at(uint8_t *ctx);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                   int32_t vlen);
extern int32_t pipeline_block_find_var_decl_block_ref(struct ast_ASTArena *arena, int32_t block_ref, uint8_t *vname,
                                                      int32_t vlen);
extern int32_t backend_enc_add_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_addss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits in eax/rbx → product bits in eax (mulss); freestanding f32 `*` (wave294). */
extern int32_t backend_enc_mulss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits: left ebx − right eax → eax (subss); freestanding f32 `-` (wave298). */
extern int32_t backend_enc_subss_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits: left eax − right ebx → eax (subss); freestanding f32 `-` (wave298). */
extern int32_t backend_enc_subss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits: left eax / right ebx → eax (divss); freestanding f32 `/` (wave298). */
extern int32_t backend_enc_divss_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_addsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_subsd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_subsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mulsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_divsd_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_ucomisd_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave621: f32 ordered compare (ucomiss / fcmp s); sibling of ucomisd. */
extern int32_t backend_enc_ucomiss_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_fp_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta);
extern int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f64 bits in rax → truncated i32 in eax (cvttsd2si); freestanding `as i32` (wave291). */
extern int32_t backend_enc_cvttsd2si_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits in eax → truncated i64 in rax (REX.W cvttss2si); freestanding `as i64/u64` (wave303). */
extern int32_t backend_enc_cvttss2si_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f64 bits in rax → truncated i64 in rax (REX.W cvttsd2si); freestanding `as i64/u64` (wave303). */
extern int32_t backend_enc_cvttsd2si_rax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsd2ss_eax_from_f64_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** i64/u64 in rax → f32 bits in eax (REX.W cvtsi2ss); freestanding `as f32` (wave299). */
extern int32_t backend_enc_cvtsi2ss_eax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** u64 in rax → f32 bits in eax (unsigned convert seq); freestanding `as f32` when >2^63-1 (wave304). */
extern int32_t backend_enc_cvtsi2ss_eax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** i32 in eax → f64 bits in rax (cvtsi2sd); freestanding `as f64` (wave292). */
extern int32_t backend_enc_cvtsi2sd_rax_from_i32_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** i64/u64 in rax → f64 bits in rax (REX.W cvtsi2sd); freestanding `as f64` (wave295). */
extern int32_t backend_enc_cvtsi2sd_rax_from_i64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** u64 in rax → f64 bits in rax (unsigned convert seq); freestanding `as f64` when >2^63-1 (wave304). */
extern int32_t backend_enc_cvtsi2sd_rax_from_u64_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** f32 bits in eax → f64 bits in rax (cvtss2sd); freestanding `as f64` (wave293). */
extern int32_t backend_enc_cvtss2sd_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                  int32_t ta);
extern int32_t backend_enc_sub_rbx_rax_then_mov_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_imul_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_and_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** 按位或/异或、移位计数与 shl/shr（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_or_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_xor_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_ecx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_idiv_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_div_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cltd_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_edx_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_unsigned_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_setcc_movzbl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t cc, int32_t ta);
extern int32_t backend_enc_jz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                   int32_t ta);
/** match 臂相等分支：cmp 后 beq/je（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_jeq_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
/** cmp left(rbx) vs right(rax)；match 字面量臂比较用。 */
extern int32_t backend_enc_cmp_rbx_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** cmp left(rax) vs right(rbx)；INDEX 下标 < 0 检查用。 */
extern int32_t backend_enc_cmp_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_jnz_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jne_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                      int32_t ta);
extern int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jge_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jle_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jl_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                   int32_t ta);
extern int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                      int32_t is_func, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t pipeline_elf_label_mod_scope_active(void);
extern void backend_ensure_block_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                             int32_t block_ref);
extern int32_t backend_emit_block_body_sync_elf(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_block_slot_base_for(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                           int32_t block_ref);
extern int32_t backend_asm_ctx_slot_offset(struct backend_AsmFuncCtx *ctx, int32_t slot_idx);
extern int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off,
                                                 int32_t ta);
/** SysV 16B struct：rdx 半落栈 / 从栈槽 load 到 rax+rdx。 */
extern int32_t backend_enc_store_rdx_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off,
                                                 int32_t ta);
extern int32_t backend_enc_load_qword_from_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_qword_rbx8_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rdx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                 int32_t ta);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rdx_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                   int32_t ta);
/** 将栈槽地址装入 rax/x0（定长数组 let 无 init 时写指针用）。 */
extern int32_t backend_enc_lea_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                               int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off,
                                                        int32_t sz, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
/** i32xN lane：x86 movl 取 4B 分量（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_load_rbp_lane_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                     int32_t esz, int32_t ta);
extern int32_t backend_enc_load_rbp_lane_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                     int32_t esz, int32_t ta);
extern int32_t backend_enc_store_x_reg_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t reg,
                                                   int32_t offset, int32_t ta);
extern int32_t backend_enc_load_x29_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos,
                                                    int32_t ta);
extern int32_t backend_enc_mov_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                   int32_t ta);
/** SysV f32 xmm 形参：movd xmmK, eax（backend_enc_dispatch.c）。 */
extern int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_xmm_arg_reg_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
extern int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                       int32_t ta);
/** XLANG_ABI_F32_XMM=1 时启用（pipeline_abi_f32_xmm.c）。 */
extern int32_t pipeline_asm_abi_f32_xmm_enabled_c(void);
extern int32_t backend_enc_load_rbp_pos_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off_pos,
                                                    int32_t ta);
extern int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale1_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale4_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale8_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                    int32_t ta);
extern int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                      int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_add_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_rbp_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                          int32_t ta);
extern int32_t backend_enc_rbx_plus_index_scratch_scaled_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t esz,
                                                               int32_t ta);
extern int32_t backend_enc_add_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                            int32_t ta);
extern int32_t backend_enc_load_rbp_index_secondary_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                  int32_t offset, int32_t ta);
extern int32_t backend_enc_index_scratch_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_imm_from_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                              int32_t ta);
extern int32_t backend_enc_index_scratch_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_index_scratch_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_rsub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_mul_imm_to_index_scratch_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit,
                                                          int32_t ta);
extern int32_t backend_enc_mul_imm_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lit, int32_t ta);
extern int32_t backend_enc_add_imm_to_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                      int32_t ta);
extern int32_t backend_enc_sub_imm_from_rbx_index_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm,
                                                          int32_t ta);
extern int32_t backend_enc_rbx_index_add_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_sub_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_index_scratch_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t arch_arm64_enc_enc_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t val);
extern int32_t backend_enc_rbx_index_mul_secondary_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_neg_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave290 Cap residual: EXPR_BITNOT ELF emit needs notl/mvn (mirror NEG/LOGNOT). */
extern int32_t backend_enc_not_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_test_eax_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_test_rbx_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_setz_movzbl_eax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_32_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_arch_emit_load_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta);
extern int32_t backend_arch_emit_lea_rbp_to_rax(struct codegen_CodegenOutBuf *out, int32_t off, int32_t ta);
extern int32_t backend_arch_emit_add_imm_to_rax(struct codegen_CodegenOutBuf *out, int32_t imm, int32_t ta);
extern int32_t backend_arch_emit_load_64_from_rax(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_push_rax(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_pop_rax(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_mov_rax_to_rbx(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale1(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale4(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale8(struct codegen_CodegenOutBuf *out, int32_t ta);
extern int32_t pipeline_asm_emit_expr_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                        struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_local_count(uint8_t *ctx);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern void asm_ctx_block_slot_set(uint8_t *ctx, int32_t block_ref, int32_t slot_base);
int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset);
int32_t asm_ctx_local_count(uint8_t *ctx);
void asm_ctx_set_scope_block(uint8_t *ctx, int32_t block_ref);
int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, struct ast_ASTArena *arena, uint8_t *name,
                                          int32_t name_len);
void pipeline_asm_patch_module_parent_links(struct ast_Module *m, struct ast_ASTArena *a);
/** 遍历块树登记全部 const/let 栈槽（ast_pool.c；前置声明，定义在 #include ast_pool.c 之后）。 */
void asm_ctx_fill_locals_block_tree(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                    int32_t *inout_next_offset, int32_t *inout_num_locals);
void asm_ctx_local_reset(uint8_t *ctx);
int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, struct ast_ASTArena *arena, int32_t block_ref,
                                          struct ast_Module *mod, int32_t func_index);
int32_t pipeline_asm_hoist_target_func_index(struct ast_Module *m);
int32_t pipeline_asm_sum_module_top_level_lets_stack(struct ast_ASTArena *a, struct ast_Module *m, int32_t off);
int32_t pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx);
uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx);
int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref);
int32_t asm_bump_off_before_struct_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
int32_t asm_bump_off_align_for_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
int32_t asm_local_slot_reg_offset(struct ast_ASTArena *arena, int32_t type_ref, int32_t off, int32_t *inout_off);
int32_t asm_sum_block_local_slot_bytes(struct ast_ASTArena *arena, int32_t block_ref);
int32_t asm_sum_block_array_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref);
/** MEM-C1：with_arena 栈上 Arena64 临时区总字节（compute_frame_size 用）。 */
int32_t asm_sum_block_wa_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref);
int32_t asm_type_is_simd_vector(struct ast_ASTArena *arena, int32_t type_ref);
int32_t asm_type_is_simd_vector_spelling(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);

/* wave1149 G.7: pipeline_asm_fill_block_locals_tree migrated to
 * pipeline_asm_emit_block_inits.c EOF (block-local slot allocation
 * domain; colocated with const/let init emit). Visible here via
 * #include at L3617 (before callers at L5230 / block_body.c /
 * block_if_stmt.c). Direct g_pipeline_asm_emit_module write replaced
 * with pipeline_asm_emit_set_module() public setter (G.7 single
 * authority). PLATFORM: SHARED. */
extern int32_t backend_try_fold_count_up_while_elf(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                   int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta);
/** M8-tail 薄包装打破：循环 emit 真实现在 C glue（勿再调 partial 的 backend_emit_*_elf 薄桩）。 */
int32_t backend_emit_while_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                         int32_t ta);
int32_t backend_emit_for_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t backend_emit_loop_body_content_elf_sync(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t body_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta);

int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int64_t pipeline_expr_int64_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
/* wave1034 G.7: pipeline_expr_float_bits_lo/hi_at folded into
 * pipeline_asm_emit_as.c (same TU #include; no new DEPS). as.c is the
 * sole in-TU leaf consumer (4 callsites); ast_pool.c wrapper is after
 * as.c #include — definition visible, no forward decl needed. */
int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j);
int32_t pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
/* Forward declaration: definition lives in ast_pool.c (#include'd below at L21844).
 * Required so the C5-enum-variant whitelist pre-mark and fold handler can call
 * the marker before ast_pool.c is textually included. */
void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
int32_t pipeline_expr_enum_namespace_field_tag(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
int32_t pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
int32_t pipeline_expr_field_access_soa_stride(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                int32_t field_ix);
int32_t pipeline_expr_struct_lit_value_bytes(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref);
int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_asm_emit_block_body_sync_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

extern int32_t asm_array_lit_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref);
extern int32_t asm_struct_lit_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref);

/* wave1149 G.7: glue_asm_init_expr_reserve_stack_bytes migrated to
 * pipeline_asm_emit_block_inits.c EOF (block-local slot allocation
 * domain; colocated with pipeline_asm_fill_block_locals_tree).
 * Static fwd decl below — sole caller pipeline_asm_let_init_stack_
 * reserve_bytes at L2106 is BEFORE block_inits.c #include at L3617;
 * definition at block_inits.c EOF (after #include). Deps:
 * asm_array_lit_reserve_stack_bytes / asm_struct_lit_reserve_stack_bytes
 * (extern, fwd decls above). PLATFORM: SHARED. */
static int32_t glue_asm_init_expr_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref);

#define PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED (-99)

int32_t pipeline_asm_emit_expr_elf_fast(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_cmp_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                  int32_t cmp_expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
static int32_t pipeline_asm_emit_expr_elf_rec(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
/**
 * wave589/593/608 FIELD on CALL/METHOD/STRUCT_LIT rvalue; leave_addr=1 → field slot
 * address in rax (INDEX base), leave_addr=0 → load field (rvalue).
 * Def later; INDEX base helpers (wave609) call before the body is defined.
 */
static int32_t glue_field_access_call_base_rvalue_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t leave_addr);
static int32_t glue_emit_index_eff_addr_scaled_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ix_ref,
                                                      int32_t base_ref, int32_t idx_ref, struct backend_AsmFuncCtx *ctx,
                                                      int32_t ta, int32_t esz);
static int32_t pipeline_asm_emit_panic_int_div_zero_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
static int32_t glue_binop_preserve_rax_for_rbx_load_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t ta, struct backend_AsmFuncCtx *ctx);
static int32_t glue_binop_restore_rax_after_rbx_load_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               int32_t ta);
static int32_t pipeline_asm_expr_lit_i32_at_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out_imm);
static int32_t glue_index_elem_byte_sz_from_type_ref_c(struct ast_ASTArena *arena, int32_t tr);
static int32_t glue_expr_emit_may_clobber_rbx_elf_c(struct ast_ASTArena *arena, int32_t expr_ref);
static int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                              int32_t var_expr_ref);
static int32_t glue_emit_index_add_index_to_base_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t idx_ref, struct backend_AsmFuncCtx *ctx,
                                                            int32_t ta, int32_t esz);
static int32_t glue_emit_index_rax_plus_rbx_scaled_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t esz,
                                                          int32_t ta);
/* wave1037: 16 glue_try_index_var_* fwd declarations removed (G.7 same-leaf fold).
 * Definitions live in pipeline_asm_emit_index_helpers.c (included at line ~2352,
 * before all consuming leaves: assign/array_lit/index/index_eff_addr/call_args/
 * field_access/block_inits). glue.c has no direct call sites — fwd was redundant. */

/**
 * 压入嵌套循环 break/continue 标签栈；与 backend.x ctx_push_loop_labels 一致。
 * C glue 真实现：避免 partial 与 mega_body 栈上 AsmFuncCtx 布局漂移时误读 loop_label_depth。
 */
int32_t backend_ctx_push_loop_labels(struct backend_AsmFuncCtx *ctx, uint8_t *exit_buf, int32_t exit_len,
                                     uint8_t *loop_buf, int32_t loop_len) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t d;
  int32_t base_off;
  int32_t k;
  if (!ctx || !exit_buf || !loop_buf || exit_len <= 0 || loop_len <= 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  d = ly->loop_label_depth;
  if (d >= 8)
    return -1;
  base_off = d * 64;
  k = 0;
  while (k < exit_len && k < 64) {
    ly->loop_break_label_stack[base_off + k] = exit_buf[k];
    k++;
  }
  ly->loop_break_len_stack[d] = exit_len;
  k = 0;
  while (k < loop_len && k < 64) {
    ly->loop_continue_label_stack[base_off + k] = loop_buf[k];
    k++;
  }
  ly->loop_continue_len_stack[d] = loop_len;
  ly->loop_label_depth = d + 1;
  k = 0;
  while (k < exit_len && k < 64) {
    ly->break_label[k] = exit_buf[k];
    k++;
  }
  ly->break_len = exit_len;
  k = 0;
  while (k < loop_len && k < 64) {
    ly->continue_label[k] = loop_buf[k];
    k++;
  }
  ly->continue_len = loop_len;
  return 0;
}

/** 弹出循环标签栈顶；与 backend.x ctx_pop_loop_labels 一致。 */
void backend_ctx_pop_loop_labels(struct backend_AsmFuncCtx *ctx) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t d;
  int32_t prev;
  int32_t base_off;
  int32_t bl;
  int32_t cl;
  int32_t k;
  if (!ctx)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly || ly->loop_label_depth <= 0) {
    if (ly) {
      ly->break_len = 0;
      ly->continue_len = 0;
    }
    return;
  }
  ly->loop_label_depth = ly->loop_label_depth - 1;
  d = ly->loop_label_depth;
  if (d <= 0) {
    ly->break_len = 0;
    ly->continue_len = 0;
    return;
  }
  prev = d - 1;
  base_off = prev * 64;
  bl = ly->loop_break_len_stack[prev];
  cl = ly->loop_continue_len_stack[prev];
  k = 0;
  while (k < bl && k < 64) {
    ly->break_label[k] = ly->loop_break_label_stack[base_off + k];
    k++;
  }
  ly->break_len = bl;
  k = 0;
  while (k < cl && k < 64) {
    ly->continue_label[k] = ly->loop_continue_label_stack[base_off + k];
    k++;
  }
  ly->continue_len = cl;
}

/** EXPR_RETURN：可选 emit 操作数后 jmp 函数尾汇合标签 tail_join_label。 */
static int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/** SysV sret 写回（定义见 glue_type_size_simple 之后）。 */
static int32_t glue_emit_sret_memcpy_rbx_to_home_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t sz,
                                                       int32_t ta);
static int32_t glue_emit_sret_return_from_var_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t var_expr_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta);
/* wave333: return ARRAY_LIT→TYPE_SLICE dual-GP (defs later).
 * wave631: force_esz>0 overrides lit-inferred elem width (TYPE_SLICE formal / large NAMED). */
int32_t pipeline_asm_emit_array_lit_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
static int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                          int32_t ta, int32_t force_esz);
void pipeline_asm_bump_next_offset_for_array_lit(struct ast_ASTArena *arena, int32_t expr_ref,
                                                 struct backend_AsmFuncCtx *ctx);
static int32_t pipeline_asm_array_lit_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref);
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
/**
 * wave625 Cap residual pure: ARRAY_LIT→TYPE_SLICE force_esz from formal/let elem type.
 * Scalars 1/4/8; TYPE_NAMED → glue_type_size_simple (Pt=8, S24=24).
 * wave632: durable COMMON packs scalar {1,2,4,8} and bulk-fills force_esz>8 NAMED
 * (return [S24{…}] must not fall to stack → dangle). Stack force_esz still used when
 * durable cannot pack (weird widths / capacity).
 * G.7: single authority for let-init / call-arg / return force_esz (was 4× scalar-only).
 * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64.
 */
static int32_t glue_array_lit_force_esz_from_elem_type_c(struct ast_ASTArena *arena, int32_t et);
/* wave692: used by durable TYPE_SLICE fat pack before full defs later in TU. */
static int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
static void glue_align_next_offset(struct backend_AsmFuncCtx *ctx);
/* wave632: durable large NAMED bulk fill needs struct let-init + spill bulk copy. */
static int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                    int32_t let_ty_ref, int32_t stack_slot_off);
static int32_t glue_emit_bulk_mem_copy_spills_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     int32_t src_spill, int32_t dst_spill, int32_t esz,
                                                     int32_t ta);
/* wave1021: durable doc/body folded into pipeline_asm_emit_array_lit.c.
 * Seq counter for non-const COMMON labels (shared: durable + return escape + reent). */
static int32_t g_pipeline_asm_al_nc_seq;

/* wave1027 G.7: glue_asm_lea_rax_common_rip_x86 + glue_asm_lea_rbx_common_rip_x86 +
 * glue_arm64_mov_x0_to_x8_elf_c + glue_arm64_mov_x8_to_x0_elf_c +
 * glue_asm_lea_rbx_common_adrp_arm64 + glue_asm_lea_rax_common_adrp_arm64
 * folded into pipeline_asm_emit_lea_common.c (same TU #include; no new DEPS).
 * pipeline_elf_ctx_append_reloc_typed extern also moved into the leaf.
 * Forward decls preserved in array_lit/return/call_args/field_access/struct_let leaves. */
#include "pipeline_asm_emit_lea_common.c"

/**
 * wave413 Cap residual pure: freestanding ARRAY_LIT element cap 256→512.
 * wave415 Cap residual pure: raise durable byte payload + elem face again.
 * Root (wave415): n_arr≤512 and nbytes≤2048 still CG002 for i32[n] n>512
 * (host-C green; durable text-embed / COMMON / escape shared the 2048B hard cap).
 * G.7: single pair of #defines for freestanding ARRAY_LIT / fixed-array face.
 *   MAX_ELEMS=1024 · MAX_PAYLOAD=4096 → u8[1024] / i32[1024] / i64[512].
 * Host deep-copy __xlang_sdN[512] (wave412) stays reentrancy soft, not this face.
 * PLATFORM: SHARED freestanding.
 */
#define GLUE_ARRAY_LIT_MAX_ELEMS 1024
#define GLUE_ARRAY_LIT_MAX_PAYLOAD 4096

/* wave647: ARRAY_LIT scalar elem → rax (FLOAT_LIT force_ty for f32 pack). Def later. */
static int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t array_lit_ref, int32_t elem_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t force_esz);

/* wave335 durable ARRAY_LIT → rax; wave1021 body → pipeline_asm_emit_array_lit.c (G.7). */
static int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t expr_ref, int32_t force_esz, int32_t ta,
                                                            struct backend_AsmFuncCtx *ctx);

/** WPO-S3 async CPS：return 前 reset phase；定义见 glue_async_cps_emit_phase_reset. */
static int32_t glue_async_cps_emit_phase_reset(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
/* wave1130-1131 G.7: glue_maybe_promote_f32_to_f64_rax_elf_c /
 * glue_float_promote_src_ty_ref_c fwd decls removed — definitions now at
 * pipeline_asm_emit_return.c EOF (#include @ L1913 below provides same-TU
 * visibility to all subsequent callsites incl. assign/block_inits/block_body
 * and glue.c L5553-5554). */
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);

/* BC 8.3.1: asm ELF return emit domain (slice escape + return_impl; same TU). */
#include "pipeline_asm_emit_return.c"

/* Forward decls: used by EXPR_NEG / assign before f32/f64 classifiers and mul helper. */
static int32_t glue_binop_operand_is_scalar_f32_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                       int32_t expr_ref);
static int32_t glue_binop_operand_is_scalar_f64_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                       int32_t expr_ref);
static int32_t glue_type_ref_is_scalar_f32_c(struct ast_ASTArena *arena, int32_t type_ref);
static int32_t glue_type_ref_is_scalar_f64_c(struct ast_ASTArena *arena, int32_t type_ref);
static int32_t glue_var_decl_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                           int32_t var_expr_ref);
static int32_t glue_emit_binop_mul_rax_rbx_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct backend_AsmFuncCtx *ctx, int32_t left_ref,
                                                   int32_t right_ref, int32_t ta);
/* wave1130-1131 G.7: float promote pair fwd decls removed — definitions now
 * at pipeline_asm_emit_return.c EOF (visible via #include @ L1913 above). */

/* BC 8.3.1: asm ELF unary emit domain (NEG/LOGNOT/BITNOT + sxt/jz; same TU). */
#include "pipeline_asm_emit_unary.c"

/* BC 8.3.1: asm ELF as/await/try/float-lit emit domain (same TU). */
#include "pipeline_asm_emit_as.c"

/* wave1028 G.7: GlueAsyncCpsEmitState + g_glue_async_cps_emit +
 * pipeline_module_func_is_async_at extern + glue_async_cps_mov_imm32_to_rax +
 * glue_async_cps_emit_frame_phase_ptr + glue_async_cps_call_frame_memop +
 * glue_async_cps_save_live + glue_async_cps_restore_live +
 * glue_async_cps_emit_after_await + glue_async_cps_emit_phase_reset +
 * pipeline_asm_emit_async_cps_entry_elf_c + pipeline_asm_emit_async_cps_end_func_elf_c
 * folded into pipeline_asm_emit_async_cps.c (same TU #include; no new DEPS).
 * L2066 forward decl for glue_async_cps_emit_phase_reset preserved for
 * as.c / return.c (both #included before this site). */
#include "pipeline_asm_emit_async_cps.c"

/* BC 8.3.1: asm ELF LOGAND/LOGOR short-circuit emit domain (same TU). */
#include "pipeline_asm_emit_logand.c"

/* wave1033 G.7: pipeline_token_kind_variant_tag folded into
 * pipeline_asm_emit_field_access.c (same TU #include at L2489; no new DEPS).
 * Chinese docblock converted to English per G.9. field_access.c is the sole
 * in-TU leaf consumer (2 callsites); residual glue.c caller
 * pipeline_expr_enum_namespace_field_tag is after the #include site — no
 * forward decl needed. */
/* wave1146 G.7: TypeKind 枚举变体 tag (definition migrated to
 * pipeline_asm_emit_cmp.c EOF). Static fwd decl here provides
 * visibility to field_access.c (#include at L2281) and cmp.c
 * (#include at L3547) — both before the definition at cmp.c EOF. */
static int32_t pipeline_asm_typekind_variant_tag(const uint8_t *field_buf, int32_t flen);
/** if/三元分支块 emit 深度（定义见 glue_block_emit_stmt_i 旁；此处前置供 if_arm 使用）。 */
static int32_t glue_if_expr_arm_emit_depth;

/** if/三元表达式的单条分支：EXPR_BLOCK 走 C 块体同步发射（含 let t）；非块走 rec。 */
int32_t pipeline_asm_emit_expr_if_arm_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t arm_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t ko;
  int32_t br;
  int32_t sv_locs;
  int32_t sv_next;
  int32_t r;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (arm_ref <= 0)
    return 0;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, arm_ref);
  if (ko == 26) {
    br = pipeline_expr_block_ref_at(arena, arm_ref);
    if (br <= 0)
      return -1;
    if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
      fprintf(stderr, "xlang: if_arm block br=%d\n", (int)br);
    sv_locs = ly->num_locals;
    sv_next = ly->next_offset;
    backend_ensure_block_local_slots(ctx, arena, br);
    /** 分支块 final_expr 勿 jmp 函数 tail_join，否则 let x = if … { … } else … 提前 return。 */
    glue_if_expr_arm_emit_depth = glue_if_expr_arm_emit_depth + 1;
    r = pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, br, ctx, ta);
    glue_if_expr_arm_emit_depth = glue_if_expr_arm_emit_depth - 1;
    ly->num_locals = sv_locs;
    ly->next_offset = sv_next;
    return r;
  }
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, arm_ref, ctx, ta);
}

/**
 * 表达式级 if/三元 ELF 发射（C 实现）：避免 seed partial 中 backend.x EXPR_IF 经 -E 后漏打 else 标签（.L_else_N offset=-1）。
 * backend.x::emit_expr_elf 在 ek 25/27 时 extern 调用本函数。
 */
/* Forward: dual-GP / named layout used by STRUCT_LIT field store (defs later). */
static int32_t glue_sysv_dual_gp_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref);
static int32_t glue_type_named_layout_size_any_module_elf_c(struct ast_ASTArena *arena, int32_t ty_ref);
/* wave1032 G.7: glue_type_is_empty_struct_c folded into
 * pipeline_asm_emit_struct_lit.c (same TU #include at L2160; no new DEPS).
 * Chinese docblock converted to English per G.9. struct_lit.c is the sole
 * in-TU leaf consumer; residual glue.c callers (layout metrics / call
 * return size) are after the #include site — no forward decl needed. */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
/* wave349/350: STRUCT_LIT fixed TYPE_ARRAY field inline store (def after vector_let_init). */
static int32_t pipeline_asm_emit_vector_let_init_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t stack_slot_off);
static int32_t glue_struct_lit_store_fixed_array_field_elf_c(
    struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
    struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t sret_direct, int32_t base_off, int32_t foff, int32_t fty);
/* wave652: arch-aware struct field frame mag (nest_slot + fixed array field). */
static int32_t glue_struct_field_frame_mag_c(int32_t base_off, int32_t foff, int32_t ta);
/* Used by wave350 FIELD init; full def near pipeline_expr_field_access_layout_offset. */
static int32_t glue_field_access_effective_offset_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                   int32_t fa_ref);
/* wave351 CALL field init: reuse let-init CALL store authority (defs later). */
/* wave1048 G.7: glue_call_return_byte_size_c fwd decl removed — definition
 * migrated to pipeline_asm_emit_call_args.c (fwd decl at call_args.c:356,
 * visible after #include at L2392; struct_let.c:93 retains its own fwd decl
 * for struct_let.c:141 callsite before #include at L2266). */
static int32_t glue_store_retval_pair_to_rbp_elf_c(struct ast_Module *m, struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ty_ref,
                                                   int32_t slot_off, int32_t ta, int32_t init_ref,
                                                   struct backend_AsmFuncCtx *ctx);
static struct ast_Module *glue_emit_module_from_ctx(struct backend_AsmFuncCtx *ctx);
/* wave598: ARRAY_LIT of >8B named struct elems reuses struct let-init (dual-GP / sret / lit). */
static int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                    int32_t let_ty_ref, int32_t stack_slot_off);
void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t shift);

/* GLUE_TYPE_NAMED (TYPE_NAMED kind ord) — used by struct_lit leaf + call_args leaf + later glue residual. */
#define GLUE_TYPE_NAMED 8

/* BC 8.3.1: asm ELF STRUCT_LIT emit domain
 * (field_store_sz + public wrapper + DEST_IN_RBX/rehome + fields + struct_lit_elf;
 *  Cap residual pure; same TU).
 * store_fixed_array_field / vector_let_init: pipeline_asm_emit_vector_let.c below. */
#include "pipeline_asm_emit_struct_lit.c"


/**
 * let v: i32xN = [..]：逐分量写入已分配向量栈槽（按值存放），勿 store 8 字节 temp 指针。
 */
static int32_t pipeline_asm_array_lit_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref);

static int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                                 struct backend_AsmFuncCtx *ctx, int32_t ta);

/* BC 8.3.1: asm ELF vector_let / leaf-flat / fixed-array field store domain
 * (leaf_elem_byte_sz + flat + vector_let_init + field_frame_mag +
 *  store_fixed_array_field; Cap residual pure; same TU).
 * SIMD vector helpers + glue_emit_fixed_array_type_let_init stay below. */
#include "pipeline_asm_emit_vector_let.c"


/* wave354: glue_emit_fixed_array_type_let_init_elf_c defined after glue_type_is_fixed_array. */

/* wave1115-1117 G.7: vector type/let helpers domain (3 fns) migrated to
 * pipeline_asm_emit_vector_simd.c EOF (SIMD vector type introspection and
 * let-init classification, co-located with SIMD emit domain). Static fwd
 * decl below for glue.c L2205 callsite (pipeline_asm_let_init_stack_reserve_bytes)
 * which precedes vector_simd.c #include at L2218. PLATFORM: SHARED. */
static int32_t glue_vector_let_init_uses_direct_slot(struct ast_ASTArena *arena, int32_t type_ref, int32_t init_ref);

/** TYPE_ARRAY / TYPE_SLICE 在 TypeKind 序数表中的值（与 ast.x / pipeline_type_kind_ord_at 一致）。 */
#define GLUE_TYPE_KIND_ARRAY 10
#define GLUE_TYPE_KIND_SLICE 11
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref);
/** TYPE_F32 在 TypeKind 序数表中的值（与 pipeline_asm_index_elem_byte_sz_c 一致）。 */
#define GLUE_TYPE_KIND_F32_ORD 14
/** TYPE_F64（ast TypeKind with LINEAR；与 TYPE_F32 同属 SysV SSE 浮点类）。 */
#define GLUE_TYPE_KIND_F64_ORD 15

/** EXPR_VAR kind 序数（与 ast_ExprKind 一致）。 */
#define GLUE_EXPR_KIND_VAR 3

/* wave1141-1144 G.7: fixed TYPE_ARRAY local let helpers cluster migrated to
 * pipeline_asm_emit_vector_let.c EOF (glue_type_is_fixed_array +
 * glue_emit_fixed_array_type_let_init_elf_c + glue_block_let_is_fixed_array_type
 * + glue_fixed_array_let_init_uses_direct_slot). Visible here via #include at
 * L2063. Colocated with glue_struct_lit_store_fixed_array_field_elf_c (the
 * element-wise store authority called by glue_emit_fixed_array_type_let_init).
 * GLUE_TYPE_KIND_ARRAY macro stays here (L2076 above) for callers in
 * struct_let/index_helpers/spill/modlet/assign/array_lit/index/vector_simd/
 * block_inits/field_access (all #included AFTER L2076). */



/**
 * let 初值在指针槽后额外占用的 temp 字节；向量/定长数组 ARRAY_LIT 直写槽时返回 0。
 * 供 fill_local_slots 与 ast_ctx_ensure_block_locals 共用。
 */
int32_t pipeline_asm_let_init_stack_reserve_bytes(struct ast_ASTArena *arena, int32_t type_ref, int32_t init_ref) {
  if (!arena)
    return 0;
  if (glue_vector_let_init_uses_direct_slot(arena, type_ref, init_ref))
    return 0;
  if (glue_fixed_array_let_init_uses_direct_slot(arena, type_ref, init_ref))
    return 0;
  return glue_asm_init_expr_reserve_stack_bytes(arena, init_ref);
}


/* BC 8.3.1: asm ELF SIMD vector lane / shuffle / select / fma domain
 * (block_let_is_simd + lane operand/binop + var_copy + vector_binop_let +
 *  shuffle/select/fma/binop2 inline + emit_vector_type_let_init +
 *  colocated pure-call fold helpers; Cap residual pure; same TU).
 * glue_vector_type_lanes_esz / is_lane_binop / fixed-array wrappers stay above. */
#include "pipeline_asm_emit_vector_simd.c"


/* BC 8.3.1: asm ELF struct let-init domain
 * (struct_let_init + glue_emit_struct_type_let_init + sret reg shift;
 *  Cap residual pure; same TU).
 * store_retval_pair / type_size helpers stay later in glue. */
#include "pipeline_asm_emit_struct_let.c"



/* BC 8.3.1: asm ELF INDEX residual helpers domain
 * (module_from_ctx + param/local slot ptr + field_type_ref + fixed_array
 *  total_bytes + index_elem_byte_sz_from_type_ref + try_index forest +
 *  soa_index_field_addr + lvalue_eff_addr; Cap residual pure; same TU).
 * index face (esz+emit+addr_of+deref): pipeline_asm_emit_index.c later.
 * 7.3 live/spill + bulk_mem_copy_spills: pipeline_asm_emit_spill.c next. */
#include "pipeline_asm_emit_index_helpers.c"


/* BC 8.3.1: asm ELF 7.3 live / Chaitin spill / bulk_mem / index-assign
 * residual domain (live_fwd + color + bulk_mem_copy_spills +
 * index_assign_finish_store + index scratch spill methods; Cap residual
 * pure; same TU). eff_addr_scaled → pipeline_asm_emit_index_eff_addr.c. */
#include "pipeline_asm_emit_spill.c"

/* BC 8.3.1: asm ELF module-level mutable let (modlet) COMMON cell emit domain
 * (table + lea/load/store/prepare/seed/register; same TU). Must precede assign.c
 * (store_from_rax + modlet_name_is_shared callsites) and expr_rec.c (load_to_rax). */
#include "pipeline_asm_emit_modlet.c"


/** 前向声明：assign / binop f32 路径用（定义见本文件后部 glue_var_expr_stack_off 附近）。 */
static int32_t glue_var_decl_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t var_expr_ref);

/* BC 8.3.1: asm ELF EXPR_ASSIGN emit domain (lhs f32 + rhs + assign_elf; same TU). */
#include "pipeline_asm_emit_assign.c"


/* BC 8.3.1: asm ELF EXPR_ARRAY_LIT emit domain (elem_byte_sz + empty +
 * emit/force_esz; Cap residual pure; same TU). */
#include "pipeline_asm_emit_array_lit.c"


/* BC 8.3.1: asm ELF EXPR_INDEX / ADDR_OF / DEREF emit domain
 * (index_elem_byte_sz + emit_index + addr_of + deref; Cap residual pure; same TU). */
#include "pipeline_asm_emit_index.c"


int32_t pipeline_asm_emit_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_method_call_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
int32_t pipeline_asm_emit_panic_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/* BC 8.3.1: asm ELF EXPR_MATCH / EXPR_IF emit domain
 * (match + expr_if; Cap residual pure; same TU). */
#include "pipeline_asm_emit_match.c"


/**
 * 查局部 VAR 的 fp 负偏移；失败 -1。
 */
static int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t var_expr_ref) {
  int32_t off;
  if (!arena || !ctx || var_expr_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != GLUE_EXPR_KIND_VAR)
    return -1;
  off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref);
  if (off < 0) {
    uint8_t vname[128];
    int32_t vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
    if (vlen <= 0 || vlen > 127)
      return -1;
    pipeline_expr_var_name_into(arena, var_expr_ref, vname);
    off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
  }
  return off;
}

static int32_t glue_lazy_append_block_let_local(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t block_ref, int32_t let_idx, uint8_t *name, int32_t name_len);
int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);

/* wave1023 G.7: var_decl_type_ref + lazy_append folded into
 * pipeline_asm_emit_var_decl.c (shared VAR/block-let infrastructure for
 * assign/unary/binop/call_args/expr_rec/block_inits/block_body; same TU
 * static via this include; no new DEPS count). wave1019 note superseded:
 * these two statics no longer "stay in glue" — extracted to leaf. */

/* BC 8.3.1: asm ELF VAR-decl type-ref + lazy block-let append (shared
 * infrastructure; same TU). */
#include "pipeline_asm_emit_var_decl.c"

/** Forward: binop operand loader paths (field_access body in field_access leaf). */
static int32_t pipeline_asm_expr_lit_i32_at_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out_imm);
static int32_t pipeline_asm_emit_var_field_access_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta);
/** Forward: FIELD_ACCESS for binop operand (body in field_access leaf). */
static int32_t pipeline_asm_emit_field_access_elf_fast_c(struct ast_ASTArena *arena,
                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                           int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                           int32_t ta);

int32_t pipeline_asm_emit_expr_elf_fast(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                        int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave1018 G.7: glue_binop_as_needs_full_emit + try_binop residual
 * (load_operand / clobber / preserve-restore / commutative / left_rax /
 *  cmp_rbx_rax) folded into pipeline_asm_emit_binop.c.
 * wave1019: f32 VAR slot load + call_arg resolve folded into call_args leaf. */

/* BC 8.3.1: asm ELF INDEX effective-address domain
 * (rax_plus_rbx_scaled + bounds_guard + rvalue_slice_once +
 *  eff_addr_scaled entry + base twins + public index_eff_addr faces;
 *  Cap residual pure; same TU). G.7 fold base/public into this leaf (wave1012).
 * try_index forest + lvalue_eff_addr_{elf,text} stay in index_helpers
 * (text folded wave1013); face in index/assign. */
#include "pipeline_asm_emit_index_eff_addr.c"

/* wave1020: expr_rec leaf (lit_i32 + rec + fast + emit_expr_elf_c) include
 * moved to after field_access — see wave1020 include below. Early forward
 * decls for rec/fast/lit_i32 remain above for index_helpers / array_lit. */

/** 与 typeck.x typeck_x_type_size 一致（前向声明，定义见本文件后部）。 */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);

/** typeck ImportKind.IMPORT_BINDING / IMPORT_SELECT（与 ast.x 序数一致）。
 * wave1150 G.7: moved here from L8947 (was after call_args.c #include) so
 * glue_asm_resolve_call_target_module_c (migrated to call_args.c EOF) can
 * see GLUE_TYPECK_IMPORT_BINDING/SELECT. Anonymous enum — single authority. */
enum {
  GLUE_TYPECK_IMPORT_BINDING = 1,
  GLUE_TYPECK_IMPORT_SELECT = 2,
};

/* BC 8.3.1: asm ELF CALL-arg emit domain
 * (named_struct_layout predicate + lea_not_load + dual-GP load_var +
 *  named layout size + pass_addr + emit_expr_elf_for_call_args +
 *  call_arg resolve + f32 VAR slot load; Cap residual pure; same TU).
 * G.7 fold type_named_struct (wave1017) + resolve/f32 residual (wave1019). */
#include "pipeline_asm_emit_call_args.c"


/* wave1016 G.7: glue_emit_assign_rhs_to_rax folded into pipeline_asm_emit_assign.c
 * (included earlier after spill). Compound-assign uses binop helpers via
 * forwards in that leaf; early unary/as scalar/mul forwards remain ~2584.
 * binop residual scalar/ptr/add already in pipeline_asm_emit_binop.c (wave1015).
 * wave1017: type_named_struct predicate in call_args leaf (above).
 * wave1018: try_binop load/placement residual folded into binop leaf. */

/* BC 8.3.1: asm ELF EXPR_PANIC + integer div-zero panic face
 * (xlang_panic_call + panic_elf + panic_int_div_zero + divisor_zero_check_rbx;
 * Cap residual pure; same TU). */
#include "pipeline_asm_emit_panic.c"

/* BC 8.3.1: asm ELF EXPR_BINOP emit domain
 * (add/sub/mul/div/mod/and/bitwise/shift + unsigned/64bit classifiers +
 * nested rax/rbx helpers + wave1015 residual scalar/ptr/add; Cap residual pure; same TU). */
#include "pipeline_asm_emit_binop.c"


/* BC 8.3.1: asm ELF EXPR_FIELD_ACCESS emit domain
 * (layout_by_name + call_arg struct/agg + call_base rvalue +
 * var_field_access + field_access_elf_fast; Cap residual pure; same TU). */
#include "pipeline_asm_emit_field_access.c"


/* BC 8.3.1 wave1020: asm ELF expr recursion + fast path domain
 * (lit_i32 + emit_expr_elf_rec + emit_expr_elf_c + emit_expr_elf_fast;
 *  Cap residual pure; same TU). G.7 fold fast residual into expr_rec leaf.
 * Include AFTER field_access / call_args / binop so fast callees exist.
 * Early forward decls (PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED / rec / fast)
 * remain near durable helpers for index_helpers / array_lit. */
#include "pipeline_asm_emit_expr_rec.c"

/* wave1166 G.7: pipeline_type_array_size_at migrated to ast_pool_type.c
 * (included from ast_pool.c L895). Fwd decls retained at L762 + L1887
 * for callsites before ast_pool.c #include at L5058.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** func 形参 / arena copy_slot 实现见 ast_pool.c（#include 进本 TU）。 */

/**
 * 将 src 前 n 字节（最多 src_cap）复制到 dst[0..63]，余下清零。
 * parse_one_function_library X 真 emit 时勿对局部 Type/Expr 数组逐元素 ASSIGN（asm INDEX 发射失败）。
 */
void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap) {
  int32_t i;
  if (!dst)
    return;
  if (n < 0)
    n = 0;
  if (src_cap < 0)
    src_cap = 0;
  for (i = 0; i < 64; i++) {
    if (src && i < n && i < src_cap)
      dst[i] = src[i];
    else
      dst[i] = 0;
  }
}

/* wave1184 G.7: pipeline_parser_library_init_* + pipeline_parser_extern_init_arena_func
 * cluster (8 fns) migrated to ast_pool_arena.c EOF (same-TU #include via ast_pool.c
 * L886 -> ast_pool_arena.c). Members: library_init_bool_type / named_type / var_expr /
 * field_access_expr / enum_variant_expr / eq_expr / labeled_block + extern_init_arena_func.
 * All delegate to pipeline_arena_{type,expr,block,func}_ptr (defined in ast_pool_arena.c)
 * + pipeline_module_fill_u8_64 + ast_pipeline_block_append_labeled + pipeline_module_func_*.
 * Forward decls at ast_pool_arena.c L405-419 for same-TU visibility. All extern. */

/* wave1163 G.7: module_func name/body reader cluster (5 fns:
 * pipeline_module_func_name_write / name_copy64 / name_len_at /
 * is_extern_at / body_ref_at) migrated to ast_pool_module_func.c EOF
 * (colocated with module_func accessor domain). Forward decls at L96 /
 * L256-260 retained for early callsites (L637-649 etc.).
 * ast_pool.c #include at L5388 → ast_pool_module_func.c at L1222 within. */

/** struct_layout / import / top_level / enum / func 形参池实现见 ast_pool.c（文件末尾 #include）。 */

/** 读 arena expr 槽；无效 ref 返回 NULL。 */
static struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return NULL;
  return pipeline_arena_expr_ptr(a, expr_ref);
}

/* wave965 BC 8.3.1: typeck CTFE producer (const whitelist + fold) — same TU slice.
 * Body: pipeline_typeck_ctfe.c. Requires glue_arena_expr_at_ref above.
 * PLATFORM: SHARED — host-cc via pipeline_x.o; STALE via PIPELINE_X_DEPS. */
#include "pipeline_typeck_ctfe.c"


/* wave1164 G.7: struct_lit accessor cluster (4 fns:
 * pipeline_expr_struct_lit_num_fields / type_name_len / type_name_into /
 * type_name_set) migrated to pipeline_asm_emit_struct_lit.c EOF (colocated
 * with STRUCT_LIT emit domain). glue_arena_expr_at_ref fwd decl in as.c L41
 * covers the migrated functions (same TU). Forward decl for num_fields at
 * L1540 retained (harmless). */

extern void driver_diagnostic_typeck_struct_padding_before(uint8_t *sname, int32_t sname_len, int32_t gap,
                                                           uint8_t *fname, int32_t fname_len);
extern void driver_diagnostic_typeck_struct_padding_trailing(uint8_t *sname, int32_t sname_len, int32_t gap);
extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t *sname, int32_t sname_len, uint8_t *fname,
                                                           int32_t fname_len);

static int32_t glue_type_align_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref, int32_t depth);

/* wave1053 G.7: glue_struct_layout_metrics_c + typeck_typeck_struct_layout_metrics
 * migrated to pipeline_asm_emit_struct_lit.c (definitions at EOF). Static fwd
 * decl for metrics retained at glue.c:2794 (above) — callsites at glue.c:3050
 * (glue_type_align_simple recursive) + public wrapper removed below.
 * Public wrapper typeck_typeck_struct_layout_metrics was at glue.c:16631 —
 * extern-called by ast_pool.c:8151 (same pipeline_x.o symbol, no link change).
 * extern decls for driver_diagnostic_typeck_struct_padding_* / field_bad_size
 * retained below (still consumed by glue.c:2912/2962 warn_layout paths). */
static int32_t glue_struct_layout_metrics_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t li,
                                            int32_t depth, int32_t check_pad, int32_t *out_sz, int32_t *out_al);

/* wave1171 G.7: layout warn cluster (2 extern fns + 2 extern decls) migrated to
 * pipeline_asm_emit_struct_lit.c EOF. Colocated with glue_pad_fields_warn_enabled
 * (wave1070) + glue_field_type_atomic_sized (wave1071) + glue_hot_reorder_warn_enabled
 * (wave1072) + glue_type_size_simple (wave1056) — all static helpers consumed by
 * these warn functions were already migrated to struct_lit.c in earlier waves;
 * the extern consumer functions now join them in the same domain file.
 *
 * Migrated: pipeline_typeck_pad_fields_warn_layout + pipeline_typeck_hot_reorder_warn_layout
 * + extern decls for driver_diagnostic_warn_pad_fields_same_cache_line /
 *   driver_diagnostic_warn_hot_reorder_field.
 *
 * No glue.c callsites (sole callers are typeck_gen.c seed). No fwd decls needed.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1054 G.7: glue_type_align_simple migrated to pipeline_asm_emit_struct_lit.c
 * (definition at EOF, after metrics). Static fwd decl retained above (L2787)
 * for glue.c callsites in pipeline_struct_layout_next_field_offset_ex body
 * + soa.c:94/140 via #include at L11697 (fwd decl at L2787 < L11697 visible).
 * struct_lit.c:65 fwd decl retained for struct_lit.c callsites at L726/L1040
 * (before EOF definition). Mutually recursive with glue_struct_layout_metrics_c
 * (wave1053 migrated to struct_lit.c EOF). */

/** DOD-S1：SoAStruct[N] 列主序总字节数；非 SoA 时返回 0 由调用方回落 AoS。 */
extern int32_t typeck_soa_array_storage_size_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t elem_type_ref, int32_t array_len, int32_t depth);

/* wave1056 G.7: glue_type_size_simple migrated to pipeline_asm_emit_struct_lit.c
 * EOF (type sizing domain — completes struct layout registry triad:
 * size + align(wave1054) + metrics(wave1053)). Definition visible via same-TU
 * #include at L2095 < all callsites below. Static fwd decl at L1887 retained
 * for return.c (#include at L1957 < L2095) + glue.c callsites before L2095.
 * struct_lit.c local fwd decl at L81 retained for callsites before EOF def.
 * Redundant fwd decls in array_lit.c:35 / struct_let.c:95 / index_helpers.c:122
 * / index.c:35 harmless (C allows redeclaration); cleanup deferred.
 * Dependencies: typeck_x_type_size_from_layout_glue (extern L233 < 2095 visible)
 * + typeck_soa_array_storage_size_glue (extern above; also declared in
 * struct_lit.c for its body) + g_pipeline_asm_emit_dep_pipe (static global
 * L184 < 2095 visible). */



/**
 * wave625 Cap residual pure: force_esz for ARRAY_LIT packed into TYPE_SLICE / TYPE_ARRAY.
 *
 * Root: let/call/return only mapped scalar TypeKind → 1/4/8; TYPE_NAMED (Pt=8) stayed 0
 * → durable inferred default 4 → COMMON stored only w0 of by-value STRUCT_LIT (y lost)
 * while INDEX used glue_type_size_simple stride 8 → a[1].y unread (mac pure-asm sum=12).
 * Host-C static compound already correct (wave624).
 *
 * @param arena AST arena (non-null)
 * @param et TYPE_SLICE/ARRAY element type_ref (0 → 0)
 * @return 1/2/4/8 for scalars; layout size for TYPE_NAMED when known; else 0
 * PLATFORM: SHARED freestanding. G.7 authority for all force_esz call sites.
 */
/* wave1021: glue_array_lit_force_esz_from_elem_type_c body → pipeline_asm_emit_array_lit.c
 * (G.7; early forward above remains). */

/* wave1046 G.7: glue_func_return_byte_size_c migrated to
 * pipeline_asm_emit_call_args.c (definition at EOF; twin of
 * glue_func_param_agg_byte_size_c — same SysV ABI func sizing domain).
 * Same-TU #include at L2392 makes it visible to all glue.c callsites
 * below (frame-size reserve L5949 + sret activation L8968).
 * Dependencies: glue_type_size_simple (fwd decl L1887 < include 2392). */

/* wave1048 G.7: glue_call_return_byte_size_c migrated to
 * pipeline_asm_emit_call_args.c (definition at EOF; fwd decl at
 * call_args.c:356 — visible after #include at L2392 for glue.c:3269/3383
 * callsites. struct_let.c:93 retains its own fwd decl for struct_let.c:141).
 * Same CALL-expr return sizing domain as wave1046 glue_func_return_byte_size_c. */

/* wave1025 G.7: glue_emit_sret_memcpy_rbx_to_home_elf_c +
 * glue_emit_sret_return_from_var_elf_c + glue_copy_large_struct_from_rax_ptr_elf_c
 * folded into pipeline_asm_emit_return.c (same TU #include; no new DEPS).
 * glue 1989-1991 forward decls kept (struct_lit/struct_let call them). */
/**
 * PLATFORM: LINUX+MACOS x86_64 SysV — push a MEMORY-class (>16B) by-value aggregate onto the
 * outgoing call stack (matches formal C: full struct on stack, not a pointer in rdi).
 * Authority for asm freestanding/product vec residual (len(Vec) etc.).
 *
 * Materialize sources (G.7 single push authority):
 *   - VAR (kind 3): push qwords from local home (high-end polarity: off, off-8, …)
 *   - CALL/METHOD_CALL (48/49) with >16B return: sret into a fresh frame temp, then push
 *     (wave601)
 *   - STRUCT_LIT (45): emit fields into frame temp (high-end home), then push (wave605)
 *   - FIELD_ACCESS (44): lvalue addr → copy words into frame temp, then push (wave605)
 *
 * Returns bytes pushed (8-aligned), or -1 on error.
 * G.7: single push authority (method import path already calls this; CALL path wave601;
 *   STRUCT_LIT/FIELD wave605 — twin of store_memory arm64).
 */
int32_t pipeline_asm_push_sysv_memory_by_value_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     struct backend_AsmFuncCtx *ctx, int32_t arg_ref, int32_t sz,
                                                     int32_t ta) {
  int32_t off;
  int32_t nbytes;
  int32_t k;
  int32_t ko;
  typedef struct {
    int32_t frame_size;
    int32_t next_offset;
  } glue_AsmFuncCtxHead;
  glue_AsmFuncCtxHead *ly;
  if (!arena || !elf_ctx || !ctx || arg_ref <= 0 || sz <= 16 || ta != 0)
    return -1;
  nbytes = (sz + 7) & ~7;
  ko = pipeline_expr_kind_ord_at(arena, arg_ref);
  off = -1;
  /* 1) Local VAR: known stack home. */
  if (ko == 3) {
    off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, arg_ref);
    if (off < 0)
      return -1;
  } else if (ko == 48 || ko == 49) {
    /*
     * 2) Nested CALL/METHOD large return: materialize via SysV sret into frame temp.
     * Root wave601: sum(mk()) previously placed only rax→rdi (pointer) while callee
     * param_home reads MEMORY at [rbp+0x10..].
     */
    int32_t ret_sz = glue_call_return_byte_size_c(arena, arg_ref);
    if (ret_sz <= 16)
      ret_sz = sz;
    if (ret_sz <= 16)
      return -1;
    ly = (glue_AsmFuncCtxHead *)ctx;
    /* High-end home: allocate nbytes; home = next after bump (≡ dual-GP spill / let slot). */
    if (ly->next_offset + nbytes < ly->next_offset)
      return -1;
    ly->next_offset += nbytes;
    off = ly->next_offset;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
      return -1;
    pipeline_asm_emit_set_call_sret_reg_shift_c(1);
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, arg_ref, ctx, ta) != 0) {
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      return -1;
    }
    pipeline_asm_emit_set_call_sret_reg_shift_c(0);
  } else if (ko == 45) {
    /*
     * 3) STRUCT_LIT as MEMORY call-arg: materialize fields into high-end frame temp.
     * Root wave605: sum(Big{…}) freestanding CG002 (push returned -1); host-C green.
     * G.7: reuse pipeline_asm_emit_struct_let_init (same as let s = Big{…}).
     * PLATFORM: LINUX|x86 high-end — byte0 @ off via lea -off(%rbp).
     */
    ly = (glue_AsmFuncCtxHead *)ctx;
    if (ly->next_offset + nbytes < ly->next_offset)
      return -1;
    ly->next_offset += nbytes;
    off = ly->next_offset;
    if (pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, arg_ref, ctx, ta, off) != 0)
      return -1;
  } else if (ko == 44) {
    /*
     * 4) FIELD_ACCESS as MEMORY call-arg: copy aggregate from lvalue address into temp.
     * Root wave605: sum(o.t) freestanding CG002; host-C temporary `.` hid the gap.
     * G.7: per-word lvalue_eff_addr + load_64_from_rax (SHARED) — do NOT use
     * load_qword_from_rbx (x86-only; returns -1 for ta!=0 and broke arm64 twin).
     * PLATFORM: LINUX|x86 high-end — store word i at off-k (k=0,8,…).
     */
    ly = (glue_AsmFuncCtxHead *)ctx;
    if (ly->next_offset + nbytes < ly->next_offset)
      return -1;
    ly->next_offset += nbytes;
    off = ly->next_offset;
    for (k = 0; k < nbytes; k += 8) {
      if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, arg_ref, ctx, ta) != 0)
        return -1;
      if (k != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, k, ta) != 0)
        return -1;
      if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off - k, ta) != 0)
        return -1;
    }
  } else {
    return -1;
  }
  /* Push high qwords first so [rsp+0] holds struct byte 0. */
  for (k = nbytes - 8; k >= 0; k -= 8) {
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off - k, ta) != 0)
      return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  return nbytes;
}

/**
 * wave603/604/605 Cap residual: AAPCS64 MEMORY by-value call-arg → store words at [sp+#sp_off].
 * PLATFORM: MACOS|ARM64 — low-end home (byte0@off); store low word first at sp_off.
 *
 * Materialize sources (G.7 twin of pipeline_asm_push_sysv_memory_by_value_elf_c):
 *   - VAR (kind 3): copy qwords from local home (wave603)
 *   - CALL/METHOD_CALL (48/49) with >16B return: sret into frame temp (x8), then copy
 *     (wave604; arm64 Indirect Result Location — no GP shift, unlike x86 rdi+shift)
 *   - STRUCT_LIT (45): emit fields into low-end frame temp, then copy (wave605)
 *   - FIELD_ACCESS (44): lvalue addr → copy words into frame temp, then to SP (wave605)
 *
 * @return nbytes stored, or -1
 */
int32_t pipeline_asm_store_memory_by_value_to_sp_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       struct backend_AsmFuncCtx *ctx, int32_t arg_ref, int32_t sz,
                                                       int32_t ta, int32_t sp_off) {
  int32_t off;
  int32_t nbytes;
  int32_t k;
  int32_t ko;
  typedef struct {
    int32_t frame_size;
    int32_t next_offset;
  } glue_AsmFuncCtxHead;
  glue_AsmFuncCtxHead *ly;
  if (!arena || !elf_ctx || !ctx || arg_ref <= 0 || sz <= 16 || ta != 1 || sp_off < 0)
    return -1;
  nbytes = (sz + 7) & ~7;
  ko = pipeline_expr_kind_ord_at(arena, arg_ref);
  off = -1;
  /* 1) Local VAR: known stack home (wave603). */
  if (ko == 3) {
    off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, arg_ref);
    if (off < 0)
      return -1;
  } else if (ko == 48 || ko == 49) {
    /*
     * 2) Nested CALL/METHOD large return: materialize via AAPCS64 sret into frame temp.
     * Root wave604: sum(mk()) previously returned -1 (VAR-only) → CG002; x86 push_sysv
     * already sret+push since wave601.
     * PLATFORM: MACOS|ARM64 — dest in x8 (wave591); low-end home byte0@off.
     */
    int32_t ret_sz = glue_call_return_byte_size_c(arena, arg_ref);
    if (ret_sz <= 16)
      ret_sz = sz;
    if (ret_sz <= 16)
      return -1;
    ly = (glue_AsmFuncCtxHead *)ctx;
    /* Low-end: allocate [off, off+nbytes); byte0 @ off. */
    off = ly->next_offset;
    if (off < 16)
      off = 16;
    if (off + nbytes < off)
      return -1;
    ly->next_offset = off + nbytes;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
      return -1;
    /* AAPCS64 Indirect Result Location = x8 (not an arg GP; no sret_reg_shift). */
    if (glue_arm64_mov_x0_to_x8_elf_c(elf_ctx) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, arg_ref, ctx, ta) != 0)
      return -1;
  } else if (ko == 45) {
    /*
     * 3) STRUCT_LIT as MEMORY call-arg: materialize fields into low-end frame temp.
     * Root wave605: sum(Big{…}) freestanding CG002 (store returned -1); host-C green.
     * G.7: reuse pipeline_asm_emit_struct_let_init (same as let s = Big{…}).
     * PLATFORM: MACOS|ARM64 low-end — byte0 @ off, fields at off+foff.
     */
    ly = (glue_AsmFuncCtxHead *)ctx;
    off = ly->next_offset;
    if (off < 16)
      off = 16;
    if (off + nbytes < off)
      return -1;
    ly->next_offset = off + nbytes;
    if (pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, arg_ref, ctx, ta, off) != 0)
      return -1;
  } else if (ko == 44) {
    /*
     * 4) FIELD_ACCESS as MEMORY call-arg: copy aggregate from lvalue address into temp.
     * Root wave605: sum(o.t) freestanding CG002; host-C temporary `.` hid the gap.
     * G.7: per-word lvalue_eff_addr + load_64_from_rax (SHARED) — do NOT use
     * load_qword_from_rbx (x86-only; returns -1 for ta!=0).
     * PLATFORM: MACOS|ARM64 low-end — store word i at off+k.
     */
    ly = (glue_AsmFuncCtxHead *)ctx;
    off = ly->next_offset;
    if (off < 16)
      off = 16;
    if (off + nbytes < off)
      return -1;
    ly->next_offset = off + nbytes;
    for (k = 0; k < nbytes; k += 8) {
      if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, arg_ref, ctx, ta) != 0)
        return -1;
      if (k != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, k, ta) != 0)
        return -1;
      if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off + k, ta) != 0)
        return -1;
    }
  } else {
    return -1;
  }
  for (k = 0; k < nbytes; k += 8) {
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off + k, ta) != 0)
      return -1;
    if (backend_enc_store_x0_sp_offset_arch(elf_ctx, sp_off + k, ta) != 0)
      return -1;
  }
  return nbytes;
}

/* wave1057 G.7: glue_sysv_dual_gp_byte_size_c migrated to
 * pipeline_asm_emit_call_args.c EOF (SysV ABI type classification domain).
 * Definition visible via same-TU #include at L2395 < all callsites below
 * (L3270/3398/3415/3421/3428). Static fwd decl at L2050 retained for
 * struct_lit.c:279 callsite (struct_lit.c #include at L2095 < call_args.c
 * #include at L2395). call_args.c:358 has its own fwd decl for callsites
 * at L396/L410/L1571 before the EOF definition. Dependency
 * glue_type_named_layout_size_any_module_elf_c already in call_args.c:454. */

/* wave1022: glue_slice_let_reent_deep_copy_after_dual_gp_elf_c body folded into
 * pipeline_asm_emit_call_args.c (G.7 有则补全; same TU). Callers: this residual
 * store_retval_pair (use_frame=1) + call_args for_call_args (use_frame=0).
 * g_pipeline_asm_al_nc_seq remains early in glue (shared with durable/return).
 */

/* wave1058 G.7: glue_store_retval_pair_to_rbp_elf_c migrated to
 * pipeline_asm_emit_call_args.c EOF (retval store domain). Definition
 * visible via same-TU #include at L2395 < callsite at L6291. Static fwd
 * decl at L2076 retained for struct_let.c:208 (struct_let.c #include at
 * L2269 < call_args.c L2395). struct_let.c:70 retains its own fwd decl.
 * block_body.c:595 + field_access.c:427 via #include > L2395 visible.
 * Dependencies: glue_type_size_simple (fwd L1887), glue_sysv_dual_gp_byte_size_c
 * (call_args.c:358), glue_copy_large_struct_from_rax_ptr (return.c:751),
 * glue_slice_dual_gp_length_off_c (fwd L1899), glue_slice_let_reent_deep_copy
 * (call_args.c:562), glue_deref_struct16/call_struct16_ret_needs_rax_deref
 * (#define-aliased to pipeline_asm_* externs, struct_let.c:76-77). */

/** 导出给 backend_call_dispatch：形参/局部 type_ref 字节大小（与 typeck 一致）。 */
int32_t pipeline_asm_type_ref_byte_size_c(struct ast_ASTArena *arena, int32_t ty_ref) {
  return glue_type_size_simple(g_pipeline_asm_emit_module, arena, ty_ref, 0);
}

/**
 * Call/method-arg value byte size for SysV GP packing (G.7 authority with dual load).
 * Order: formal pty → expr resolved → VAR decl → FIELD_ACCESS field type → dual-GP name.
 * PLATFORM: SHARED size query; consumers apply LINUX+MACOS SysV 2-GP for 9–16B.
 *
 * FIELD_ACCESS (v.al → alloc): formal pty often 0 during co-emit; must resolve field type
 * so units=2 (rax+rdx place). units=1 left size in rsi and arena half unused → malloc(0).
 */
int32_t pipeline_asm_call_arg_value_byte_size_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                 int32_t arg_ref, int32_t pty) {
  int32_t sz = 0;
  int32_t tr;
  /*
   * PLATFORM: SHARED — TYPE_SLICE call/formal param is pointer (codegen.x), 1 GP (8B).
   * Fat value size 16 must not dual-GP-pack (steals next arg's rsi). G.7 with call lea.
   */
  if (arena && pty > 0 &&
      pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_SLICE)
    return 8;
  if (arena && arg_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == (int32_t)ast_TypeKind_TYPE_SLICE)
      return 8;
  }
  /*
   * wave635 Cap residual pure: fixed TYPE_ARRAY formal is E* (one GP), not MEMORY
   * by-value of the payload. Twin of glue_func_param_agg_byte_size_c (wave417) and
   * TYPE_SLICE call-arg size above.
   * Root: prior glue_type_size_simple(T[N]) returned full payload (S24[2]=48, S12[2]=24)
   * → glue_sysv_arg_gp_units_from_size → MEMORY (units=0) → arm64 store_memory_by_value
   * / x86 push_sysv_memory multi-word stack copy, while callee param_home + INDEX treat
   * the formal as a pointer in x0/rdi (wave417). Freestanding take(mk())/take(s) SEGV;
   * pure-asm without -freestanding often CTFE-folds away the call (false green);
   * host-C decays T[N]→E*. S8[2]=16 dual-GP + single S24 MEMORY named both green.
   * G.7: complete call-arg size authority only — emit already lea local T[N] /
   * load param E* / pass CALL return E* (wave417/610). Do not invent a second path.
   * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64.
   */
  if (arena && pty > 0 &&
      (pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_ARRAY ||
       glue_type_is_fixed_array(arena, pty)))
    return 8;
  if (arena && arg_ref > 0) {
    tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (tr > 0 &&
        (pipeline_type_kind_ord_at(arena, tr) == (int32_t)ast_TypeKind_TYPE_ARRAY ||
         glue_type_is_fixed_array(arena, tr))) {
      /* When formal missing, still pass E* for fixed-array values (C decay twin). */
      if (pty <= 0 ||
          pipeline_type_kind_ord_at(arena, pty) == (int32_t)ast_TypeKind_TYPE_ARRAY ||
          glue_type_is_fixed_array(arena, pty))
        return 8;
    }
  }
  if (pty > 0)
    sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, pty, 0);
  if (sz <= 0 && arg_ref > 0 && arena) {
    tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (tr > 0)
      sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, tr, 0);
  }
  if (arg_ref > 0 && arena && ctx && pipeline_expr_kind_ord_at(arena, arg_ref) == 3) {
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, arg_ref);
    if (tr > 0) {
      int32_t sz2 = glue_type_size_simple(g_pipeline_asm_emit_module, arena, tr, 0);
      if (sz2 > sz)
        sz = sz2;
      sz2 = glue_sysv_dual_gp_byte_size_c(arena, tr);
      if (sz2 > sz)
        sz = sz2;
    }
  }
  /* FIELD_ACCESS: field type / layout (v.al) when formal pty or resolved miss. */
  if (arg_ref > 0 && arena && pipeline_expr_kind_ord_at(arena, arg_ref) == 44) {
    tr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, arg_ref);
    if (tr <= 0 && g_pipeline_asm_emit_module)
      tr = glue_field_access_layout_field_type_ref_by_name_c(arena, g_pipeline_asm_emit_module, arg_ref);
    if (tr > 0) {
      int32_t sz2 = glue_type_size_simple(g_pipeline_asm_emit_module, arena, tr, 0);
      if (sz2 > sz)
        sz = sz2;
      sz2 = glue_type_named_layout_size_any_module_elf_c(arena, tr);
      if (sz2 > sz)
        sz = sz2;
      sz2 = glue_sysv_dual_gp_byte_size_c(arena, tr);
      if (sz2 > sz)
        sz = sz2;
    }
  }
  if (sz <= 8 && pty > 0) {
    int32_t sz2 = glue_sysv_dual_gp_byte_size_c(arena, pty);
    if (sz2 > sz)
      sz = sz2;
  }
  if (sz <= 8 && arg_ref > 0 && arena) {
    tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (tr > 0) {
      int32_t sz2 = glue_sysv_dual_gp_byte_size_c(arena, tr);
      if (sz2 > sz)
        sz = sz2;
    }
  }
  if (sz <= 0)
    return 8;
  return sz;
}

/* wave1044 G.7: glue_struct_layout_compute_field_offset_c migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF; forward decl at top
 * serves struct_lit.c callsites L152/L158 + glue.c internal callsites
 * L3759/3772/3774/3804 after #include 2092 — visible via that decl). */

/* wave1052 G.7: glue_sync_struct_layout_field_offsets_c migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF). Forward decl below
 * retained for glue.c:11850 callsite (fill_struct_layouts — module layout
 * finalization pass). struct_lit.c:77 also has a forward decl; same-TU
 * #include at glue.c:2095 makes the definition visible to glue.c. */
static void glue_sync_struct_layout_field_offsets_c(struct ast_Module *m, struct ast_ASTArena *a);

/* wave1050 G.7: glue_struct_layout_field_offset_by_name_c migrated to
 * pipeline_asm_emit_field_access.c (definition at EOF; field_access.c:708 fwd
 * decl retained for callsites at L811/L832/L866/L884 — all in field_access.c,
 * before the definition). glue.c has zero self-callsites — pure leaf consumed
 * only by field_access.c. */

/* wave1049 G.7: glue_struct_layout_index_by_type_name_c migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF; struct_lit.c:59 fwd
 * decl retained for struct_lit.c:162 callsite. field_access.c:706 fwd decl
 * retained for field_access.c:830/882 callsite — field_access.c #include
 * at L2419 > struct_lit.c L2095 so definition is visible there). glue.c
 * has zero self-callsites — pure leaf consumed by struct_lit + field_access. */

/**
 * Compute the §11.1-aligned byte offset for the next field (of type
 * new_field_type_ref) on layout_idx; field_align_req is the minimum
 * alignment specified by align(N) (0 means type alignment only).
 */
int32_t pipeline_struct_layout_next_field_offset_ex(struct ast_Module *m, struct ast_ASTArena *a, int32_t layout_idx,
                                                    int32_t new_field_type_ref, int32_t field_align_req) {
  int32_t current;
  int32_t nf;
  int32_t j;
  int32_t A;
  int32_t rem;
  int32_t gap;
  if (!m || layout_idx < 0)
    return 0;
  current = 0;
  nf = pipeline_module_struct_layout_num_fields(m, layout_idx);
  /** packed：字段紧密排列，无对齐填充（内存契约 §11.1 packed）。 */
  if (pipeline_module_struct_layout_packed_at(m, layout_idx)) {
    for (j = 0; j < nf; j++) {
      int32_t ftr = pipeline_module_struct_layout_field_type_ref(m, layout_idx, j);
      int32_t fsize = glue_type_size_simple(m, a, ftr, 0);
      if (fsize < 0 || (fsize == 0 && glue_type_is_empty_struct_c(m, a, ftr, 0) == 0))
        fsize = 4;
      current = current + fsize;
    }
    return current;
  }
  for (j = 0; j < nf; j++) {
    int32_t ftr = pipeline_module_struct_layout_field_type_ref(m, layout_idx, j);
    int32_t fsize;
    int32_t fa = pipeline_module_struct_layout_field_align_at(m, layout_idx, j);
    A = glue_type_align_simple(m, a, ftr, 0);
    if (A <= 0)
      A = 1;
    if (fa > A)
      A = fa;
    fsize = glue_type_size_simple(m, a, ftr, 0);
    if (fsize < 0 || (fsize == 0 && glue_type_is_empty_struct_c(m, a, ftr, 0) == 0))
      fsize = 4;
    rem = current % A;
    gap = A - rem;
    gap = gap % A;
    current = current + gap + fsize;
  }
  A = glue_type_align_simple(m, a, new_field_type_ref, 0);
  if (A <= 0)
    A = 1;
  if (field_align_req > A)
    A = field_align_req;
  rem = current % A;
  gap = A - rem;
  gap = gap % A;
  return current + gap;
}

/**
 * 在 layout_idx 上为下一字段（类型 new_field_type_ref）计算 §11.1 对齐后的字节偏移；
 * parser struct 定义与 struct_lit 登记须用此值，勿 off+=8。
 */
int32_t pipeline_struct_layout_next_field_offset(struct ast_Module *m, struct ast_ASTArena *a, int32_t layout_idx,
                                               int32_t new_field_type_ref) {
  return pipeline_struct_layout_next_field_offset_ex(m, a, layout_idx, new_field_type_ref, 0);
}

/* wave1051 G.7: pipeline_expr_struct_lit_value_bytes migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF; struct_lit.c:69 fwd decl
 * for glue_struct_layout_metrics_c added — static, defined later in TU at
 * glue.c:2794). glue.c:1693 public forward decl retained (public symbol).
 * Consumed by struct_lit.c:612 + field_access.c:330 — field_access.c #include
 * at L2419 > struct_lit.c L2095 so definition is visible there. glue.c has
 * zero self-callsites — pure leaf consumed by struct_lit + field_access. */

/* wave1035 G.7: pipeline_expr_struct_lit_field_offset_at +
 * pipeline_expr_struct_lit_field_type_ref_at folded into
 * pipeline_asm_emit_struct_lit.c (included at glue.c:2172). struct_lit.c
 * is the sole in-TU leaf consumer (offset: 1 callsite L276; type_ref: 2
 * callsites L119/L278); residual glue.c wrappers codegen_/backend_ at
 * L17076/L17084 are after struct_lit.c #include — definition visible,
 * no forward decl needed. Seed backend_try_inline_dispatch consumes via
 * extern — symbol still in pipeline_x.o.
 */

/** struct_lit 字段名/init 读 API 见 ast_pool.c（侧车池）。 */

/** 读 expr.kind 序数；无效 ref 返回 -1。 */
int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return -1;
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  return (int32_t)kd;
}

/* wave1162 G.7: int_val_at + int64_val_at migrated to
 * pipeline_asm_emit_expr_rec.c EOF. Fwd decls at L1530-1531. */

/* wave1172 G.7: pipeline_typeck_check_expr_int_lit_c migrated to
 * pipeline_typeck_coerce_init.c EOF. Colocated with coerce_init domain —
 * int literal type resolution (i32 vs i64) is the entry point for literal
 * coerce. No glue.c callsites (sole caller is typeck_gen.c seed).
 * Dependencies: glue_arena_expr_at_ref (static, glue.c L2437 < coerce_init.c
 * #include L8661) + pipeline_type_ensure_by_kind_ord (fwd decl glue.c L769).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1162 G.7: unary/field_access/var/null/binop accessor cluster
 * (11 fns: unary_operand_ref_at, field_access_name_into/len/base_ref,
 * var_name_into/len_for_string_lit/len, is_null_keyword_c,
 * tag_null_keyword_c, binop_left/right_ref_at) migrated to
 * pipeline_asm_emit_expr_rec.c EOF. Fwd decls at L1530-1571. */

/* wave1146 G.7: pipeline_asm_typekind_variant_tag migrated to
 * pipeline_asm_emit_cmp.c EOF (TypeKind variant-name → tag table;
 * colocated with CMP enum RHS consumer pipeline_asm_cmp_enum_rhs_tag_c).
 * Visible here via static fwd decl at L1958 (before field_access.c
 * #include at L2281 and cmp.c #include at L3547). */

/* BC 8.3.1: asm ELF relational CMP emit domain
 * (emit_cmp_elf + enum RHS tag + 64-bit/rex + f32/f64/int finish;
 * Cap residual pure; same TU). typekind_variant_tag now at cmp.c EOF. */
#include "pipeline_asm_emit_cmp.c"


int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
/** WPO-S3 typeck_block_tree_has_var_c 等于 10313 块；定义见 ast_ast_block_if_else_body_ref。 */
int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci);
void ast_pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst);
int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void ast_pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);

int32_t pipeline_asm_emit_block_if_stmt_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t cur_block, int32_t if_idx, struct backend_AsmFuncCtx *ctx,
                                            int32_t ta, int32_t stmt_i);

/* wave1055 G.7: glue_fixed_array_temp_bytes + glue_array_temp_bytes_for_let_init
 * migrated to pipeline_asm_emit_array_lit.c EOF (array temp sizing domain).
 * Definitions visible via same-TU #include at L2299 < all callsites below
 * (L4018/4042/6402/6483 + block_body.c:473/606 via #include at L4117).
 * Dependencies (glue_type_size_simple fwd decl L1887 < 2299; public pipeline_*
 * / ast_pipeline_* / pipeline_asm_array_lit_elem_type_ref @ L1278) all visible
 * at array_lit.c. No fwd decl retained in glue.c — zero callsites before L2299. */

/* wave1105 G.7: asm_func_ctx next_offset management domain (3 fns)
 * migrated to pipeline_asm_emit_next_offset.c (same-TU #include).
 * Members: glue_align_next_offset (static) +
 * pipeline_asm_bump_next_offset_for_array_lit (public) +
 * pipeline_asm_bump_next_offset_after_let_init (public).
 * #include point chosen AFTER pipeline_asm_emit_array_lit.c (L2260, provides
 * glue_array_temp_bytes_for_let_init) and BEFORE pipeline_asm_emit_block_inits.c
 * (L3791) / pipeline_asm_emit_block_body.c (L3806) consumers. Earlier consumers
 * (return.c L1913 / assign.c L2255 / call_args.c L2356) reach the public bump_*
 * via the forward decl retained at L1840.
 * Deps: pipeline_asm_ctx_layout + pipeline_glue_AsmFuncCtxLayout (extern decls
 * earlier in glue.c) + glue_array_temp_bytes_for_let_init (static from
 * array_lit.c, same-TU visible) + pipeline_expr_* / pipeline_block_let_type_ref
 * (public). No static deps on other glue domains.
 * PLATFORM: SHARED. */
#include "pipeline_asm_emit_next_offset.c"

/* wave1043 G.7: glue_emit_array_let_empty_init migrated to
 * pipeline_asm_emit_block_body.c (sole consumer block_body_sync_elf +
 * glue.c internal callsites 6791/6872 after #include 4459 — visible via
 * forward decl in block_body.c). Definition removed from here. */

/* wave1073 G.7: glue_block_stmt_order_has_return migrated to
 * pipeline_asm_emit_block_body.c EOF (block stmt_order return scanner,
 * consumed by block_body_sync_elf + block_if_stmt). Static same-TU:
 * block_body.c #include L3872 < fwd decl L48 < def EOF. Callsites:
 * block_body.c:819/851 + block_if_stmt.c:82 (via #include L3875 > L3872).
 * Deps: ast_ast_block_* / ast_pipeline_block_* / pipeline_expr_kind_ord_at
 * / pipeline_block_labeled_* (all extern). */

/* wave1021: durable body already in pipeline_asm_emit_array_lit.c; late redecl OK. */
static int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t expr_ref, int32_t force_esz, int32_t ta,
                                                            struct backend_AsmFuncCtx *ctx);
/* wave647: ARRAY_LIT scalar elem → rax (FLOAT_LIT force_ty for f32 pack). */
static int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t array_lit_ref, int32_t elem_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t force_esz);

/* wave1024 G.7: glue_slice_dual_gp_length_off_c + bump_past_home +
 * glue_emit_slice_from_array_let_init_elf_c folded into
 * pipeline_asm_emit_block_inits.c (same TU #include; no new DEPS).
 * glue ~2017 forward decl for length_off kept (call_args leaf uses it).
 * bump_past_home: call_args leaf calls it (no explicit fwd; same TU later def). */
/* BC 8.3.1: asm ELF block const/let init emit domain (same TU). */
#include "pipeline_asm_emit_block_inits.c"


/* wave1030 G.7: GLUE_WA_SCOPE_STACK_MAX + g_glue_wa_* globals +
 * glue_with_arena_scope_active_c + glue_with_arena_scope_top_off_c +
 * glue_wa_emit_begin_func_c + glue_wa_scope_alloc_off_c +
 * glue_wa_scope_push_c + glue_wa_scope_pop_c +
 * glue_emit_with_arena_init_elf + glue_emit_with_arena_deinit_elf
 * folded into pipeline_asm_emit_with_arena.c (same TU #include; no new DEPS).
 * Chinese docblocks converted to English per G.9. block_body.c #included
 * after this site consumes all wa helpers; no forward decls needed. */
#include "pipeline_asm_emit_with_arena.c"


/* BC 8.3.1: asm ELF block body sync emit domain (defer + body_sync + accessors; same TU). */
#include "pipeline_asm_emit_block_body.c"

/* BC 8.3.1: asm ELF block-level if-stmt emit domain (same TU). */
#include "pipeline_asm_emit_block_if_stmt.c"


/* wave1034 G.7: pipeline_expr_float_bits_lo/hi_at folded into
 * pipeline_asm_emit_as.c (included at glue.c:2062). as.c is the sole
 * in-TU leaf consumer (4 callsites: array_lit pack + float_lit emit);
 * ast_pool.c wrapper (pipeline_expr_float_bits_lo/hi) is after as.c
 * #include — definition visible, no forward decl needed. */

/* wave1159 G.7: pipeline_expr_call_callee_ref_at migrated to
 * pipeline_typeck_method_call.c EOF. Fwd decl already exists above. */

/* wave1160 G.7: expr accessor cluster (10 extern fns) migrated to
 * pipeline_asm_emit_expr_rec.c EOF (colocated with expr ELF recursion
 * dispatcher domain). Fwd decls already exist at L1532-1578 (before
 * #include L2210). ast_pipeline_* wrappers also migrated. */

/* wave1159 G.7: method_call accessor cluster (4 extern fns) migrated to
 * pipeline_typeck_method_call.c EOF (colocated with method_call typeck
 * domain). Fwd decls in method_call.c top; visible via #include L9703. */

/* wave1173 G.7: type init/find-or-alloc cluster (6 fns + 1 static helper
 * glue_type_kind_from_ord) migrated to ast_pool_type.c EOF. Colocated with
 * type pool domain — all allocate/find type slots via pipeline_arena_type_alloc
 * + pipeline_arena_type_ptr (ast_pool_arena.c, included before ast_pool_type.c).
 * No glue.c callsites for the 5 init/find_or_alloc fns (sole callers are
 * typeck_gen.c / codegen_gen.c seeds via extern). pipeline_type_ensure_by_kind_ord
 * fwd decl retained at L773 for callsites (all after ast_pool.c #include at
 * L5058; fwd decl retained defensively).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1176 G.7: backend return-expr ref cluster (8 fns) migrated to
 * pipeline_asm_emit_return.c EOF (colocated with EXPR_RETURN emit domain).
 * Members: pipeline_backend_get_return_expr_ref / _at +
 * pipeline_arm64_get_return_lit_ref / _at + pipeline_backend_type_kind_ord_at
 * (L3514 below, also removed) + pipeline_asm_get_return_expr_ref_at (L4546,
 * also removed) + pipeline_asm_get_return_lit_ref_at (L4615, also removed) +
 * arch_arm64_pipeline_asm_get_return_lit_ref_at (L4638, also removed).
 *
 * All deps fwd-declared before pipeline_asm_emit_return.c #include at L1731:
 * pipeline_arena_block_ptr (L215) / pipeline_block_labeled_return_expr_ref
 * (L203) / pipeline_arena_expr_ptr (L214) / pipeline_block_expr_stmt_ref (L92)
 * / pipeline_module_func_ptr (L91) / pipeline_type_kind_ord_at (L761).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** INDEX 元素字节宽；委托 pipeline_asm_index_elem_byte_sz_c（勿在此重复旧 TYPE_PTR→8 逻辑）。 */
int32_t pipeline_asm_index_elem_byte_sz(struct ast_ASTArena *a, int32_t index_expr_ref) {
  return pipeline_asm_index_elem_byte_sz_c(a, index_expr_ref);
}

/* wave1161 G.7: index/field_access/line/col accessor cluster (10 extern
 * fns) migrated to pipeline_asm_emit_expr_rec.c EOF (colocated with
 * expr ELF recursion dispatcher). Fwd decls already exist at L1554-1565.
 * Note: pipeline_expr_set_field_access_enum_variant,
 * pipeline_expr_set_field_access_soa_stride remain in glue.c (different
 * domain / dependency). */

/* wave1178 G.7: pipeline_expr_typeck_set_float_bits_from_val migrated to
 * pipeline_typeck_coerce_init.c EOF (colocated with int_lit coerce domain).
 * pipeline_dep_ctx_typeck_loop_depth_at migrated to ast_pool_dep_ctx.c EOF
 * (colocated with PipelineDepCtx cold accessor domain).
 * Both have no glue.c callsites (sole callers are typeck_gen.c seed via
 * extern). PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1179 G.7: field_access enum/soa setter cluster (5 fns) migrated to
 * pipeline_asm_emit_field_access.c EOF (colocated with FIELD_ACCESS emit
 * domain). Members: pipeline_expr_set_field_access_enum_variant +
 * pipeline_expr_set_field_access_soa_stride +
 * pipeline_expr_field_access_is_enum_variant +
 * pipeline_expr_enum_namespace_field_tag +
 * pipeline_expr_enum_field_tag_via_module (def + fwd decl L3196, both
 * removed).
 *
 * All deps fwd-declared before pipeline_asm_emit_field_access.c #include
 * at L2111: glue_arena_expr_at_ref (static fwd decl in field_access.c L712)
 * + pipeline_expr_kind_ord_at / var_name_* / field_access_name_* (L1554-1565)
 * + pipeline_token_kind_variant_tag (L1773) + glue_enum_field_name_equal
 * (static in field_access.c L1169) + g_pipeline_asm_emit_module (L132).
 * No glue.c callsites (sole callers are typeck_gen.c / codegen_gen.c seeds
 * via extern). PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** typeck.x get_field_offset_from_layout_deps；asm emit 跨模块 struct 字段偏移回落。 */
extern int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                        uint8_t *type_name, int32_t type_name_len, uint8_t *field_name,
                                                        int32_t field_name_len);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);

/* wave1026 G.7: glue_dep_layout_field_offset_by_name_c +
 * glue_field_layout_offset_for_{var_base,base}_field +
 * glue_field_access_effective_offset_c +
 * pipeline_expr_field_access_layout_offset +
 * glue_field_access_load_bytes_for_type_ref +
 * pipeline_expr_field_access_load_byte_sz
 * folded into pipeline_asm_emit_field_access.c (same TU #include; no new DEPS).
 * glue 1726-1727 public fwd decls kept (backend_try_inline extern).
 * glue 2500 static fwd decl kept (index_helpers/assign/index_eff_addr/vector_let). */

/* wave1074 G.7: glue_enum_field_name_equal migrated to
 * pipeline_asm_emit_field_access.c EOF (enum variant name prefix match,
 * consumed by pipeline_expr_enum_namespace_field_tag — also migrated in
 * wave1179). Static same-TU: field_access.c #include L2111 < def EOF.
 * Deps: strlen / memcmp (libc, global). */

/* wave1180 G.7: asm emit context setters/getters cluster (14 fns) migrated to
 * pipeline_asm_emit_context.c (new domain file, same-TU #include below).
 * Members:
 *  - pipeline_asm_emit_set_module / module_ref_c (current emit module)
 *  - pipeline_asm_emit_set_dep_pipe / dep_pipe_c (current dep pipe)
 *  - pipeline_asm_emit_set_arena (current emit AST arena)
 *  - pipeline_asm_emit_set_call_param_type_ref (callee formal type_ref)
 *  - pipeline_asm_emit_call_arg_begin_c / end_c / active_c (CALL arg depth)
 *  - pipeline_asm_emit_set_func_index / func_index_c (current emit func idx)
 *  - pipeline_asm_emit_set_elf_ctx (current emit ElfCodegenCtx)
 *  - pipeline_asm_emit_func_param_is_ptr_by_name_c (lookup *T param by name)
 *  - pipeline_asm_var_is_emit_func_param_ptr_c (VAR expr -> name lookup wrapper)
 *
 * Static globals STAY in glue.c (L132-188): g_pipeline_asm_emit_module /
 * _func_index / _arena / _call_param_ty_ref / g_glue_emit_call_arg_depth /
 * g_pipeline_asm_emit_dep_pipe / g_pipeline_asm_emit_elf_ctx — also read
 * directly by pipeline_asm_emit_field_access.c (#include L2111) for CALL-arg
 * struct pass-by-address classification, so cannot move with the functions.
 *
 * Fwd decls retained at L180 (pipeline_asm_emit_call_arg_active_c — called
 * by field_access.c #included at L2111, before this file's #include below)
 * and L186 (pipeline_asm_emit_dep_pipe_c — called by vector_simd.c #included
 * at L1940, before this file's #include below).
 *
 * No glue.c callsites before this #include (sole early callers are via the
 * two retained fwd decls above). Glue.c callsites after this #include:
 * L3571 / L4538 (pipeline_asm_emit_set_func_index).
 *
 * External deps (declared elsewhere in pipeline_x.o TU):
 *  - pipeline_elf_pgo_hot_enabled / pipeline_elf_ctx_set_emit_hot
 *    / pipeline_asm_wpo_pgo_is_hot_func (PGO-Lite hot section switch)
 *  - pipeline_module_func_param_type_ref_for_name (module formal table)
 *  - pipeline_type_kind_ord_at / pipeline_expr_kind_ord_at
 *    / pipeline_expr_var_name_len / _into (expr accessor domain)
 *
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */
#include "pipeline_asm_emit_context.c"

/* wave1179: pipeline_expr_enum_field_tag_via_module migrated to
 * pipeline_asm_emit_field_access.c EOF (colocated with enum_namespace_field_tag). */
/* wave1176: pipeline_backend_type_kind_ord_at migrated to
 * pipeline_asm_emit_return.c EOF (colocated with backend return-expr cluster). */

/* wave1175 G.7: asm-prefixed module func forwarders (7 fns) migrated to
 * ast_pool_module_func.c EOF. Colocated with pipeline_module_func_* domain.
 * Fwd decls retained at L778/L7685 + added L767-770 for 5 fns previously
 * without declarations. All callsites before ast_pool.c #include at L5055
 * resolved via fwd decls.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1100 G.7: modlet ELF emit domain (12 functions + typedef + macro + global)
 * migrated to pipeline_asm_emit_modlet.c (same-TU #include at L2291). Members:
 * pipeline_asm_modlet_reset / _name_is_shared / _find / _lea_rbx_rip_x86 /
 * _lea_rbx_adrp_arm64 / _lea_rbx_arch / _load_to_rax_elf_c / _store_from_rax_elf_c /
 * _prepare_and_emit_elf_c / _seed_nonzero_inits_elf_c / _register_module_top_level_lets_c /
 * _emit_module_top_level_mutable_lit_inits_elf_c. PLATFORM: SHARED. */

/**
 * 栈帧大小：模拟 fill_param + 块树 fill_local 后的 next_offset（真实 struct/vector 槽宽）
 * + 数组 temp + with_arena temp + SysV call-arg spill + 最小 scratch + 64B。
 *
 * PLATFORM: SHARED frame formula; call-spill advance is LINUX+MACOS x86_64 SysV
 * (glue_sysv_spill_rax_rdx_to_frame_c permanently bumps next_offset by 32B/reg-arg).
 * arm64 does not use that spill path — over-reserve is safe.
 */
/* wave1046 G.7: glue_func_return_byte_size_c forward decl removed —
 * definition migrated to pipeline_asm_emit_call_args.c (same-TU #include
 * at L2392, before all callsites below). */
/* wave1047 G.7: glue_func_param_home_width_c forward decl removed —
 * definition migrated to pipeline_asm_emit_call_args.c (same-TU #include
 * at L2392, before all callsites below). */
/* wave1045 G.7: glue_func_param_agg_byte_size_c forward decl removed —
 * definition migrated to pipeline_asm_emit_call_args.c (same-TU #include
 * at L2392, before all callsites below). */

/**
 * Permanent next_offset advance per spilled SysV register-class call arg.
 * Matches glue_sysv_spill_rax_rdx_to_frame_c: off = next+16; next = off+16.
 * PLATFORM: LINUX+MACOS x86_64 SysV (producer); SHARED frame-size consumer.
 */
/* wave1138-1140 G.7: frame-size spill byte summation cluster migrated to
 * pipeline_asm_emit_spill.c EOF (glue_asm_sum_expr_call_spill_bytes +
 * glue_sum_block_slice_reent_dc_bytes_c + glue_asm_sum_block_call_spill_bytes
 * + 3 macros GLUE_ASM_CALL_SPILL_SLOT_BYTES / _FRAME_WALK_VISIT_MAX /
 * _FRAME_WALK_DEPTH_MAX). Visible here via #include at L2181. Extern fwd
 * decls below kept for other callers (pipeline_block_*_ref at L7592/L10719). */


extern int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t pipeline_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);

int32_t pipeline_asm_compute_frame_size_c(int32_t num_params, struct ast_ASTArena *arena, int32_t block_ref,
                                          struct ast_Module *mod, int32_t func_index) {
  uint8_t ctx_buf[128];
  int32_t next_off;
  int32_t num_loc;
  int32_t size;
  int32_t arr_temp;
  int32_t call_spill;
  int32_t scratch;
  struct ast_Module *prev_mod;
  if (!arena || block_ref <= 0)
    return 64;
  memset(ctx_buf, 0, sizeof(ctx_buf));
  /** module_ref @ AsmFuncCtx+16，与 asm_ctx_ensure_block_locals 一致。 */
  *(struct ast_Module **)(ctx_buf + 16) = mod;
  prev_mod = g_pipeline_asm_emit_module;
  g_pipeline_asm_emit_module = mod;
  asm_ctx_local_reset(ctx_buf);
  /*
   * 【Why】x86_64 prologue 在 [rbp-8] 保存 rbx（callee-saved）；形参 homing 须从 16 起，
   *   否则 store [rbp-8] 覆写 saved rbx → epilogue pop 错误（run-env env_iter SEGV）。
   * PLATFORM: SHARED x86_64 SysV — 与 fill_param_slots / emit_param_home 对齐。
   */
  next_off = 16;
  if (num_params > 0 && mod && func_index >= 0) {
    int32_t pi;
    /**
     * Match pipeline_asm_fill_param_slots advancement (wave599):
     * - PLATFORM: LINUX|x86_64 — 8B +8; multi-word high-end next = home+8 (= off+w+8).
     * - PLATFORM: MACOS|ARM64 — 8B +8; multi-word low-end next = off+w (no high-end gap).
     */
    for (pi = 0; pi < num_params; pi++) {
      int32_t w = glue_func_param_home_width_c(arena, mod, func_index, pi);
#if defined(__aarch64__) || defined(__arm64__)
      next_off += (w > 8) ? w : 8;
#else
      next_off += (w > 8) ? (w + 8) : 8;
#endif
    }
  } else if (num_params > 0) {
    next_off = 16 + num_params * 8;
  }
  /** 与 mega_body emit 一致：>16B 返回函数在形参后预留 8B 存 hidden rdi。 */
  if (mod && func_index >= 0 && glue_func_return_byte_size_c(mod, arena, func_index) > 16)
    next_off += 8;
  if (mod && func_index >= 0 && func_index != pipeline_asm_hoist_target_func_index(mod))
    next_off = pipeline_asm_sum_module_top_level_lets_stack(arena, mod, next_off);
  num_loc = 0;
  asm_ctx_fill_locals_block_tree(ctx_buf, arena, block_ref, &next_off, &num_loc);
  arr_temp = asm_sum_block_array_temp_bytes(arena, block_ref);
  call_spill = glue_asm_sum_block_call_spill_bytes(arena, block_ref);
  g_pipeline_asm_emit_module = prev_mod;
  {
    int32_t wa_temp = asm_sum_block_wa_temp_bytes(arena, block_ref);
    /*
     * wave418: TYPE_SLICE let from CALL/METHOD deep-copies into a per-frame buffer
     * (use_frame=1). Pre-sum max_n*esz per such let so prologue covers body next_offset
     * bumps (wave411 SP overrun root). max_n=1024, worst esz=8 → 8192 per let.
     */
    int32_t reent_dc = glue_sum_block_slice_reent_dc_bytes_c(arena, block_ref);
    size = next_off + arr_temp + wa_temp + reent_dc;
  }
  if (size > 0 && size % 16 != 0)
    size += 16 - (size % 16);
  /*
   * Scratch = max(historical 512, AST call-spill estimate).
   * Root (option pure-asm residual): body with many nested Option CALL args permanently
   * advanced next_offset past frame (max rbp off 0xa80 vs sub $0x360). G.7: complete
   * compute_frame_size authority rather than a larger constant-only pad.
   * Also covers transient struct_lit dual-GP spill at next_offset+16 without advance.
   */
  scratch = call_spill;
  if (scratch < 512)
    scratch = 512;
  size += scratch;
  return size + 64;
}

/* wave1045 G.7: glue_func_param_agg_byte_size_c migrated to
 * pipeline_asm_emit_call_args.c (definition at EOF; same-TU #include at
 * L2392 makes it visible to all glue.c callsites below —
 * glue_func_param_home_width_c + fill_param_slots / emit_func_param_home).
 * Dependencies already visible from that include point:
 * glue_type_named_layout_size_any_module_elf_c (call_args.c:429) +
 * glue_type_size_simple (fwd decl L1887) + glue_sysv_dual_gp_byte_size_c
 * (call_args.c EOF; wave1057; static fwd decl L2050 retained). */

/**
 * Home slot width for formal param.
 * PLATFORM: LINUX+MACOS x86_64 SysV —
 * - >16B MEMORY by-value: full 8-aligned aggregate
 * - 9–16B INTEGER by-value: full dual-half home (Allocator / StrView / Result; matches formal C)
 * - else: 8B (scalar / pointer)
 */
/* wave1047 G.7: glue_func_param_home_width_c migrated to
 * pipeline_asm_emit_call_args.c (definition at EOF; direct consumer of
 * glue_func_param_agg_byte_size_c — same SysV ABI param sizing domain).
 * Same-TU #include at L2392 makes it visible to all glue.c callsites
 * below (L5922/6030/6186/6330/6410). */

/**
 * 将函数形参填入 asm 局部 sidecar；[rbp-8] 保留给 prologue 的 saved rbx。
 * >16B MEMORY by-value params get a full-size home (not 8B pointer slot).
 *
 * wave599 Cap residual pure: arm64 9–16B named dual-GP formals.
 * Root: fill_param always used x86 high-end (home=off+width) while
 * asm_local_slot_reg_offset (wave402) is low-end on MACOS|ARM64, and
 * emit_param_home arm64 only stored one GP at 16+i*8 — field loads from
 * empty high-end home (take_m(o).m / o.m.f → 0; take_field fs=65≠41).
 * G.7: same polarity authority as asm_local_slot_reg_offset + dual-GP
 * store_retval half2 (low@home high@home±8 by ta).
 *
 * PLATFORM: LINUX|x86_64 SysV — high-end multi-word (home=off+w, next=home+8).
 * PLATFORM: MACOS|ARM64 — low-end multi-word (home=off, next=off+w); matches
 *   [x29+off] emit + field_off add (host ISA == freestanding product target).
 */
void pipeline_asm_fill_param_slots(struct backend_AsmFuncCtx *ctx, struct ast_Module *mod, int32_t func_index) {
  int32_t off;
  int32_t np;
  int32_t i;
  uint8_t pname_buf[128];
  int32_t plen;
  struct ast_ASTArena *arena;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || !mod)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  g_pipeline_asm_emit_module = mod;
  arena = g_pipeline_asm_emit_arena;
  off = 16; /* reserve [rbp-8] for callee-saved rbx */
  np = pipeline_asm_module_func_num_params_at(mod, func_index);
  for (i = 0; i < np; i++) {
    int32_t width;
    int32_t slot_off;
    pipeline_asm_module_func_param_name_copy32(mod, func_index, i, pname_buf);
    plen = pipeline_asm_module_func_param_name_len_at(mod, func_index, i);
    width = arena ? glue_func_param_home_width_c(arena, mod, func_index, i) : 8;
#if defined(__aarch64__) || defined(__arm64__)
    /*
     * PLATFORM: MACOS|ARM64 — low-end home (≡ asm_local_slot_reg_offset).
     * 8B scalar/pointer: home@off, next off+8.
     * width>8 dual/MEMORY: byte0@off, payload [off,off+width), next off+width.
     */
    slot_off = off;
    if (asm_ctx_local_append((uint8_t *)ctx, pname_buf, plen, slot_off) < 0)
      return;
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    off = (width > 8) ? (off + width) : (off + 8);
#else
    /**
     * PLATFORM: LINUX|x86_64 — high-end multi-word home.
     * 8B (scalar/pointer): home at `off`, next off+8 (historical param layout).
     * width>8 (9–16B dual-half or MEMORY): byte0 at off+width (like asm_local_slot_reg_offset);
     * words live at home, home-8, … — next free is home+8 so a following 8B param does not
     * clobber byte0 (Allocator dual-home + size; get(Vec,i) MEMORY + i).
     */
    if (width > 8)
      slot_off = off + width;
    else
      slot_off = off;
    if (asm_ctx_local_append((uint8_t *)ctx, pname_buf, plen, slot_off) < 0)
      return;
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    off = (width > 8) ? (slot_off + 8) : (off + 8);
#endif
  }
  ly->next_offset = off;
}

/* wave1059 G.7: glue_func_param_is_f32_c + glue_func_param_is_f64_c migrated
 * to pipeline_asm_emit_call_args.c EOF (SysV param classification domain).
 * Definitions visible via same-TU #include at L2395 < sole live caller
 * pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c at L5648. Dependencies:
 * GLUE_TYPE_KIND_F32_ORD/F64_ORD macros at L2185/2187 < L2395;
 * pipeline_module_func_param_type_ref_at + pipeline_type_kind_ord_at extern. */

/* Dead code glue_sysv_x86_func_param_slot_c deleted wave1059: full-tree grep
 * showed zero callsites (static, same-TU only). It consumed
 * glue_func_param_agg_byte_size_c + glue_func_param_is_f32_c but was never
 * called — leftover from an earlier SysV slot iteration design superseded by
 * pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c below. */

/* wave1151 G.7: pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c migrated to
 * pipeline_asm_emit_call_args.c EOF (SysV x86 f32 xmm param homing; callee-side
 * twin of call-arg packing domain — directly consumes glue_func_param_agg_byte_
 * size_c / glue_func_param_home_width_c / glue_func_param_is_f32_c /
 * glue_func_param_is_f64_c all in call_args.c wave1045-1059).
 *
 * No static fwd decl needed: sole caller pipeline_asm_emit_param_home_elf_c
 * (below at L4742) is AFTER call_args.c #include at L2251, so the definition
 * at call_args.c EOF (which expands at L2251) precedes the caller.
 *
 * Deps: g_pipeline_asm_emit_arena / g_pipeline_asm_func_sret_active (same-TU
 * globals); glue_func_param_* (same leaf); backend_enc_*_arch (extern).
 * PLATFORM: LINUX+MACOS x86_64 SysV. */

/**
 * prologue 后形参 homing：寄存器实参写入 fill_param_slots 栈槽，栈上传参从 [fp+#] 拷入。
 * AAPCS64：x0-x7 @ [fp-8..-64]；第 9+ 个 @ [x29,#16] 起。SysV x86：rdi..r9；第 7+ @ [rbp+16] 起。
 * XLANG_ABI_F32_XMM=1：SysV gp/xmm 分轨（f32 走 xmm0–7）。
 */
int32_t pipeline_asm_emit_param_home_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           struct backend_AsmFuncCtx *ctx, struct ast_Module *mod,
                                           int32_t func_index, int32_t ta) {
  int32_t np;
  int32_t reg_max;
  int32_t i;
  int32_t off;
  if (!elf_ctx || !ctx || !mod || func_index < 0)
    return -1;
  /** seed partial mega 可能未调 backend.x 的 emit_set_func_index；形参 *T field 识别依赖此下标。 */
  pipeline_asm_emit_set_func_index(func_index);
  np = pipeline_asm_module_func_num_params_at(mod, func_index);
  /**
   * >16B sret: save incoming hidden dest before param homing (independent of nargs).
   * PLATFORM: LINUX+MACOS x86_64 SysV — rdi → [sret_home].
   * PLATFORM: MACOS|ARM64 AAPCS64 (wave591) — x8 → [sret_home].
   */
  if (g_pipeline_asm_func_sret_active && g_pipeline_asm_sret_home_off >= 0) {
    if (ta == 0) {
      /* SysV: hidden dest in rdi (= arg reg 0); GP formals shift to rsi… */
      if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, 0, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
        return -1;
    } else if (ta == 1) {
      /*
       * wave596 Cap residual pure: AAPCS64 sret save must not clobber x0.
       * Root: wave591 used mov x8→x0 then store_rax — x0 is first GP formal
       * (no GP shift; x8 is separate Indirect Result Location). mk(ip) with
       * >16B return stored sret dest into ip home → pointer fields / first
       * arg garbage (mac freestanding mk(&i).m.p.f wrong; host-C hid).
       * G.7: store x8 directly via store_x_reg_to_rbp(reg=8).
       * PLATFORM: MACOS|ARM64 AAPCS64 · LINUX arm64 same if ever product.
       */
      if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, 8, g_pipeline_asm_sret_home_off, ta) != 0)
        return -1;
    }
  }
  if (np <= 0)
    return 0;
  if (ta == 0 && pipeline_asm_abi_f32_xmm_enabled_c() != 0)
    return pipeline_asm_emit_param_home_elf_sysv_f32_xmm_c(elf_ctx, ctx, mod, func_index, np);
  /** Legacy SysV (f32 xmm off): MEMORY + 9–16B dual-GP by-value (same as f32_xmm path). */
  if (ta == 0) {
    struct ast_ASTArena *arena = g_pipeline_asm_emit_arena;
    int32_t gp = g_pipeline_asm_func_sret_active ? 1 : 0;
    int32_t stack_pos = 16;
    int32_t cur = 16;
    int32_t k;
    if (!arena)
      return -1;
    for (i = 0; i < np; i++) {
      int32_t psz = glue_func_param_agg_byte_size_c(arena, mod, func_index, i);
      int32_t home_w = glue_func_param_home_width_c(arena, mod, func_index, i);
      int32_t home = (home_w > 8) ? (cur + home_w) : cur;
      if (psz > 16) {
        int32_t nbytes = (psz + 7) & ~7;
        for (k = 0; k < nbytes; k += 8) {
          if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos + k, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home - k, 0) != 0)
            return -1;
        }
        stack_pos += nbytes;
      } else if (psz > 8) {
        if (gp + 2 <= 6) {
          if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
            return -1;
          if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp + 1, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home - 8, 0) != 0)
            return -1;
          gp += 2;
        } else {
          if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
            return -1;
          if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos + 8, 0) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home - 8, 0) != 0)
            return -1;
          stack_pos += 16;
        }
      } else if (gp < 6) {
        if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, 0) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
          return -1;
        gp++;
      } else {
        if (backend_enc_load_rbp_pos_to_rax_arch(elf_ctx, stack_pos, 0) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, 0) != 0)
          return -1;
        stack_pos += 8;
      }
      cur = (home_w > 8) ? (home + 8) : (cur + 8);
    }
    return 0;
  }
  /*
   * PLATFORM: MACOS|ARM64 AAPCS64 (wave599) — dual-GP / MEMORY param home.
   * Prior: one GP per formal at 16+i*8, ignored 9–16B INTEGER dual-GP and
   * fill_param multi-word homes → field extract on Outer formal returned 0.
   * G.7: mirror SysV x86 dual-GP/MEMORY path with arm64 low-end polarity
   * (low@home, high@home+8 ≡ glue_store_retval_pair / wave402 locals).
   * Hidden sret uses x8 (already saved above); GP formals start at x0 (no shift).
   */
  reg_max = 8;
  {
    struct ast_ASTArena *arena = g_pipeline_asm_emit_arena;
    int32_t gp = 0;
    /*
     * wave414 low-end prologue: sub sp,#fs; stp; mov x29,sp → locals [x29+16..)
     * and incoming stack args live at [x29+frame_size + …], not [x29+16]
     * (that was classic stp #-16! / high locals layout). wave603: use frame_size.
     * Fallback 16 only when frame_size unset (skip-heavy / zero-body stubs).
     */
    int32_t stack_pos = 16;
    int32_t cur = 16;
    int32_t k;
    if (!arena)
      return -1;
    if (ctx) {
      pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
      if (ly && ly->frame_size > 16)
        stack_pos = ly->frame_size;
    }
    for (i = 0; i < np; i++) {
      int32_t psz = glue_func_param_agg_byte_size_c(arena, mod, func_index, i);
      int32_t home_w = glue_func_param_home_width_c(arena, mod, func_index, i);
      int32_t home = cur; /* low-end (match fill_param arm64) */
      if (psz > 16) {
        /* MEMORY by-value: copy nbytes from caller stack into low-end home. */
        int32_t nbytes = (psz + 7) & ~7;
        for (k = 0; k < nbytes; k += 8) {
          if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos + k, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home + k, ta) != 0)
            return -1;
        }
        stack_pos += nbytes;
      } else if (psz > 8) {
        /* 9–16B INTEGER dual-GP: low half @ home, high @ home+8. */
        if (gp + 2 <= reg_max) {
          if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp, home, ta) != 0)
            return -1;
          if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp + 1, home + 8, ta) != 0)
            return -1;
          gp += 2;
        } else {
          if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
            return -1;
          if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos + 8, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home + 8, ta) != 0)
            return -1;
          stack_pos += 16;
        }
      } else if (gp < reg_max) {
        if (backend_enc_store_x_reg_to_rbp_arch(elf_ctx, gp, home, ta) != 0)
          return -1;
        gp++;
      } else {
        if (backend_enc_load_x29_pos_to_rax_arch(elf_ctx, stack_pos, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
          return -1;
        stack_pos += 8;
      }
      cur = (home_w > 8) ? (cur + home_w) : (cur + 8);
    }
  }
  return 0;
}

/**
 * 将块内 const/let 填入 asm 局部 sidecar；与 backend.x fill_local_slots 一致（+8 槽 + lit temp 预留）。
 */
void pipeline_asm_fill_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t off;
  int32_t i;
  int32_t nconst;
  int32_t nlet;
  uint8_t name_buf[128];
  int32_t nlen;
  int32_t init_ref;
  int32_t slot_base;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || !arena || block_ref <= 0)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  /** 与 asm_ctx_ensure_block_locals 互斥，避免 stmt_order 路径重复登记偏移。 */
  if (asm_ctx_block_slot_get((uint8_t *)ctx, block_ref) >= 0)
    return;
  slot_base = asm_ctx_local_count((uint8_t *)ctx);
  off = ly->next_offset;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  for (i = 0; i < nconst; i++) {
    int32_t type_ref;
    ast_pipeline_block_const_name_copy64(arena, block_ref, i, name_buf);
    nlen = ast_pipeline_block_const_name_len(arena, block_ref, i);
    type_ref = pipeline_block_const_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append((uint8_t *)ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (i = 0; i < nlet; i++) {
    int32_t type_ref;
    ast_pipeline_block_let_name_copy64(arena, block_ref, i, name_buf);
    nlen = ast_pipeline_block_let_name_len(arena, block_ref, i);
    type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append((uint8_t *)ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    ly->num_locals = asm_ctx_local_count((uint8_t *)ctx);
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  ly->next_offset = off;
  asm_ctx_block_slot_set((uint8_t *)ctx, block_ref, slot_base);
}

/* wave1102 G.7: asm label integer format domain (2 functions) migrated to
 * pipeline_asm_label_format.c (same-TU #include). Members:
 * glue_format_u32_to_buf / glue_format_i32_to_buf.
 * PLATFORM: SHARED. */
#include "pipeline_asm_label_format.c"

/**
 * 生成唯一局部标签 ".Lf<scope>_<n>" 到 buf；多 Module 共用 elf_ctx 时 scope 由 pipeline_elf_label_mod_scope_begin_module 分配。
 */
int32_t pipeline_asm_emit_next_label_c(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t n;
  int32_t id;
  int32_t scope;
  int32_t off;
  if (!ctx || !buf || buf_size < 8)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  scope = pipeline_elf_label_mod_scope_active();
  buf[0] = (uint8_t)'.';
  buf[1] = (uint8_t)'L';
  buf[2] = (uint8_t)'f';
  off = 3;
  n = glue_format_u32_to_buf(buf, off, buf_size - off, (uint32_t)scope);
  if (n <= 0)
    n = 1;
  off = off + n;
  if (off + 2 >= buf_size)
    return -1;
  buf[off] = (uint8_t)'_';
  off = off + 1;
  id = ly->label_counter;
  ly->label_counter = id + 1;
  n = glue_format_u32_to_buf(buf, off, buf_size - off, (uint32_t)id);
  if (n <= 0)
    n = 1;
  return off + n;
}

/**
 * 将 label 序号格式化为 ".L_<id>" 写入 buf；与 backend.x format_label_id 一致（不推进 label_counter）。
 */
int32_t pipeline_asm_format_label_id_c(uint8_t *buf, int32_t buf_size, int32_t id) {
  int32_t n;
  if (!buf || buf_size < 4)
    return -1;
  buf[0] = (uint8_t)'.';
  buf[1] = (uint8_t)'L';
  buf[2] = (uint8_t)'_';
  n = glue_format_i32_to_buf(buf, 3, buf_size - 3, id);
  if (n <= 0)
    n = 1;
  return 3 + n;
}

/**
 * if 语句 then 块 ELF 发射：暂存/恢复 locals，fill + sync block body；与 backend.x emit_if_then_block_body_elf 一致。
 */
int32_t pipeline_asm_emit_if_then_block_body_elf_c(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   int32_t then_block_ref, struct backend_AsmFuncCtx *ctx,
                                                   int32_t ta) {
  int32_t sv_locs;
  int32_t sv_next;
  int32_t r;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!ctx || !arena || then_block_ref <= 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  sv_locs = ly->num_locals;
  sv_next = ly->next_offset;
  pipeline_asm_fill_local_slots(ctx, arena, then_block_ref);
  r = backend_emit_block_body_sync_elf(arena, elf_ctx, then_block_ref, ctx, ta);
  ly->num_locals = sv_locs;
  ly->next_offset = sv_next;
  return r;
}

/* wave1154 dead code delete: glue_emit_block_stmt_order_let_const_elf removed
 * (~134 LOC; zero callsites in glue.c TU — superseded by block_body_sync_elf
 * in pipeline_asm_emit_block_body.c which handles stmt_order let/const init
 * via the same code path). */
#if 0
static int32_t glue_emit_block_stmt_order_let_const_elf(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                        uint8_t item_kind, int32_t idx, int32_t slot_base,
                                                        int32_t nconst, int32_t nlet) {
  if (item_kind == 0) {
    if (idx >= 0 && idx < nconst) {
      int32_t init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, idx);
      if (init_ref != 0) {
        if (glue_init_is_empty_array_lit(arena, init_ref)) {
          /* 空 [] 初值：无 store。 */
        } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
          return -1;
        else if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot_base + idx), ta) != 0)
          return -1;
      }
    }
    return 0;
  }
  if (item_kind != 1 || idx < 0 || idx >= nlet)
    return 0;
  {
    int32_t slot = slot_base + nconst + idx;
    int32_t init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
    uint8_t lnb[128];
    int32_t llen = pipeline_block_let_name_len(arena, block_ref, idx);
    /** emit 前懒登记 let 栈槽（循环/if 体内 let 可能未进 fill_tree 子树）。 */
    if (llen > 0) {
      pipeline_block_let_name_copy64(arena, block_ref, idx, lnb);
      if (glue_lazy_append_block_let_local(arena, ctx, block_ref, idx, lnb, llen) != 0)
        return -1;
    }
    if (init_ref != 0) {
      if (glue_init_is_empty_array_lit(arena, init_ref)) {
        int32_t tref_empty = pipeline_block_let_type_ref(arena, block_ref, idx);
        int32_t slice_st_empty;
        /* wave330: empty TYPE_SLICE → dual-GP {data,length=0}; see body_sync twin. */
        slice_st_empty =
            glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, idx, init_ref, tref_empty, ctx, ta,
                                                      backend_asm_ctx_slot_offset(ctx, slot));
        if (slice_st_empty == 1) {
          /* empty fat slice written */
        } else if (slice_st_empty < 0) {
          return -1;
        } else if (glue_block_let_is_fixed_array_type(arena, block_ref, idx)) {
          /* T[N] = [] 内联 blob，无 pointer init */
        } else if (glue_array_temp_bytes_for_let_init(arena, tref_empty, 0) > 0) {
          if (glue_emit_array_let_empty_init(arena, elf_ctx, ctx, ta, backend_asm_ctx_slot_offset(ctx, slot)) != 0)
            return -1;
          pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, 0, ctx);
        }
      } else if (glue_block_let_is_fixed_array_type(arena, block_ref, idx)) {
        /* wave354: T[N] = ARRAY_LIT/VAR/FIELD/CALL element-wise (G.7 fixed_array_type_let). */
        int32_t arr_st = glue_emit_fixed_array_type_let_init_elf_c(
            arena, elf_ctx, init_ref, ctx, ta, pipeline_block_let_type_ref(arena, block_ref, idx),
            backend_asm_ctx_slot_offset(ctx, slot));
        if (arr_st == 0) {
          /* fixed array payload written */
        } else if (arr_st == -1) {
          return -1;
        } else {
          if (link_abi_getenv("XLANG_ASM_DEBUG"))
            fprintf(stderr, "xlang: fixed array let (stmt_order twin) unhandled block=%d idx=%d init_ko=%d\n",
                    (int)block_ref, (int)idx, (int)pipeline_expr_kind_ord_at(arena, init_ref));
          return -1;
        }
      } else if (glue_block_let_is_simd_vector_type(arena, block_ref, idx)) {
        int32_t vtype_ref = pipeline_block_let_type_ref(arena, block_ref, idx);
        int32_t vst =
            glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                 backend_asm_ctx_slot_offset(ctx, slot), vtype_ref);
        if (vst == 0) {
          /* 向量 let 直写栈槽 */
        } else if (vst == -1) {
          return -1;
        } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0) {
          return -1;
        } else if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0) {
          return -1;
        }
      } else {
        int32_t st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                          pipeline_block_let_type_ref(arena, block_ref, idx),
                                                          backend_asm_ctx_slot_offset(ctx, slot));
        if (st == 0) {
          /* struct 字面量或 mk(...) 内联已写入 let 槽 */
        } else if (st == -1) {
          return -1;
        } else if (pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
          if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
            return -1;
          pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, init_ref, ctx);
        } else {
          int32_t let_ty;
          int32_t init_ko;
          let_ty = pipeline_block_let_type_ref(arena, block_ref, idx);
          init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
          if (let_ty > 0 && pipeline_type_kind_ord_at(arena, let_ty) == GLUE_TYPE_KIND_F32_ORD && init_ko == 1) {
            if (glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, init_ref, ta, let_ty, 0) != 0)
              return -1;
            if (backend_enc_store_eax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
              return -1;
          } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
            return -1;
          else if (let_ty > 0 && pipeline_type_kind_ord_at(arena, let_ty) == GLUE_TYPE_KIND_F32_ORD) {
            if (backend_enc_store_eax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
              return -1;
          } else {
            /* wave314: f32→f64 let-init promote before 64-bit store. */
            if (glue_type_ref_is_scalar_f64_c(arena, let_ty) &&
                glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, init_ref)) {
              if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
                return -1;
            } else {
              int32_t src_ty = glue_float_promote_src_ty_ref_c(arena, init_ref);
              if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, let_ty, src_ty, ta) != 0)
                return -1;
            }
            if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, let_ty,
                                                     backend_asm_ctx_slot_offset(ctx, slot), ta, init_ref,
                                                     ctx) != 0)
              return -1;
          }
        }
      }
    } else if (glue_array_temp_bytes_for_let_init(arena, pipeline_block_let_type_ref(arena, block_ref, idx), 0) > 0) {
      if (glue_emit_array_let_empty_init(arena, elf_ctx, ctx, ta, backend_asm_ctx_slot_offset(ctx, slot)) != 0)
        return -1;
      pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, 0, ctx);
    }
  }
  return 0;
}
#endif

/**
 * ELF 循环体 stmt_order（expr/while/for/if + final_expr）；C for 循环，避免 partial 薄包装递归。
 */
int32_t backend_emit_loop_body_content_elf_sync(struct ast_ASTArena *arena,
                                                struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t body_ref,
                                                struct backend_AsmFuncCtx *ctx, int32_t ta) {
  if (!arena || !elf_ctx || !ctx)
    return -1;
  /** 空 while 体合法（`while (c) {}`）；勿因 body_ref==0  abort 整函数 codegen。 */
  if (body_ref <= 0)
    return 0;
  {
    pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
    if (ly && ly->module_ref)
      g_pipeline_asm_emit_module = ly->module_ref;
  }
  /**
   * 与 pipeline_asm_emit_block_if_stmt_elf 的 then 分支一致：先铺局部槽再按 stmt_order 发射，
   * 否则 while 体内赋值/调用在 asm 路径静默失败（body_ref 有效但 code_len 停在 cond+jz）。
   */
  backend_ensure_block_local_slots(ctx, arena, body_ref);
  pipeline_asm_fill_block_locals_tree(ctx, arena, body_ref);
  /** 循环体 scoped 查局部（while 内 let p 的 p.a 等 FIELD_ACCESS）。 */
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, body_ref);
  if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, body_ref, ctx, ta) != 0)
    return -1;
  return 0;
}

/* wave1106 G.7: fold pattern detection primitives domain (13 fns)
 * migrated to pipeline_asm_emit_fold_primitives.c (same-TU #include).
 * Members: glue_fold_expr_var_refs_same_c / glue_fold_parse_while_lt_i_n_c /
 * glue_fold_block_let_init_lit_c / glue_parse_i_mul_add_lit_c /
 * glue_is_assign_var_add_one_c / glue_expr_is_param0_field_access_c /
 * glue_fold_func_returns_param0_field_sum_c / glue_is_field_assign_from_var_c /
 * glue_is_field_assign_i_plus_one_c / glue_is_assign_s_plus_pair_field_sum_call_c /
 * glue_is_assign_u8_index_store_cast_i_c / glue_is_assign_sum_plus_u8_index_cast_c
 * + glue_expr_var_name_eq_let_idx_c (moved from after x86_enc_helpers #include).
 * #include point AFTER pipeline_asm_emit_vector_simd.c (L2218, provides
 * glue_expr_is_func_param_at_c + glue_fold_func_return_operand_ref_c) and
 * pipeline_asm_emit_as.c (L1938, provides glue_expr_is_x_as_cast_at_c);
 * BEFORE pipeline_asm_emit_x86_enc_helpers.c (L6032) — x86 encoders are
 * consumed by fold EMITTERS that follow, primitives must precede them.
 * Consumers (glue_match_* / glue_try_fold_* / backend_try_fold_count_up_while_elf)
 * all follow this #include point.
 * Deps: pipeline_expr_* / pipeline_block_* / ast_ast_block_* / pipeline_call_*
 * (all public pool accessors) + GLUE_EXPR_KIND_VAR (macro, earlier in glue.c).
 * No static deps on other glue domains.
 * PLATFORM: SHARED. */
#include "pipeline_asm_emit_fold_primitives.c"

/* wave1106: remaining 11 fold primitives (glue_fold_parse_while_lt_i_n_c through
 * glue_is_assign_s_plus_pair_field_sum_call_c) removed — now provided by
 * pipeline_asm_emit_fold_primitives.c #include above. */

/* wave1068 G.7: glue_field_assign_pair_base_ref_c migrated to
 * pipeline_asm_emit_assign.c EOF (fold/affine pattern detection). Static
 * same-TU: asm_emit_assign.c #include L2294 < def L6499 < callsite L6664.
 * Deps: pipeline_expr_kind_ord_at / pipeline_expr_binop_left_ref_at /
 * pipeline_expr_field_access_base_ref (all extern). */

/* wave1106: glue_is_assign_u8_index_store_cast_i_c +
 * glue_is_assign_sum_plus_u8_index_cast_c removed — now provided by
 * pipeline_asm_emit_fold_primitives.c #include above. */

/* wave1029 G.7: 27 glue_enc_x86_* micro-encoders + glue_emit_lcg_xor_body_x86_c
 * folded into pipeline_asm_emit_x86_enc_helpers.c (same TU #include; no new DEPS).
 * Chinese docblocks converted to English per G.9. Callers in fold paths
 * (struct_pair_n2 / u8_fill / lcg_xor) follow after this #include site. */
#include "pipeline_asm_emit_x86_enc_helpers.c"


/* wave1106: glue_expr_var_name_eq_let_idx_c removed — now provided by
 * pipeline_asm_emit_fold_primitives.c #include above (moved from here). */

/* wave1069 G.7: glue_body_expr_stmt_at_c migrated to
 * pipeline_asm_emit_assign.c EOF (fold/affine pattern detection). Static
 * same-TU: asm_emit_assign.c #include L2294 < def L6604 < callsite L6657.
 * Deps: ast_ast_block_stmt_order_kind / ast_ast_block_stmt_order_idx /
 * ast_pipeline_block_expr_stmt_ref (all extern). */

/* wave1107-1110 G.7: count_up_while loop folding domain (17 fns)
 * migrated to pipeline_asm_emit_fold_count_up_while.c (same-TU #include).
 * Members: glue_match_struct_pair_n2_body_pattern_c /
 *   glue_try_fold_struct_pair_n2_while_elf_c / glue_try_fold_u8_fill_index_while_elf_c /
 *   glue_try_fold_u8_sum_index_while_elf_c / glue_mem_copy_fold_final_sum_i32 /
 *   glue_match_u8_fill_index_while_pattern_c / glue_match_u8_sum_index_while_pattern_c /
 *   glue_match_u8_fill_index_while_c / glue_match_u8_sum_index_while_c /
 *   glue_try_fold_mem_copy_outer_while_elf_c / glue_try_fold_lcg_xor_while_elf_c /
 *   glue_fold_expr_is_func_param0_c / glue_fold_func_x_plus_k_chain_c /
 *   glue_fold_affine_i_plus_k_expr_c / glue_fold_is_assign_s_plus_affine_i_c /
 *   glue_fold_parse_affine_sum_body_c / backend_try_fold_count_up_while_elf.
 * Deps: fold primitives (pipeline_asm_emit_fold_primitives.c) +
 *   x86 encoders (pipeline_asm_emit_x86_enc_helpers.c) +
 *   glue_asm_local_var_stack_off_scoped (pipeline_asm_emit_vector_simd.c) +
 *   glue_enc_local_slot_ptr_or_addr_rbx_elf_c (pipeline_asm_emit_index_helpers.c) +
 *   pipeline_asm_emit_next_label_c / glue_asm_ctx_set_scope_block (pipeline_glue.c) +
 *   glue_body_expr_stmt_at_c / glue_field_assign_pair_base_ref_c (pipeline_asm_emit_assign.c).
 * Same-TU: fold_primitives #include + x86_enc_helpers #include < this #include
 *   < backend_emit_while_loop_elf_sync def. Forward decl at ~L1605 remains.
 * PLATFORM: SHARED. */
#include "pipeline_asm_emit_fold_count_up_while.c"

/**
 * ELF while 循环；C glue 真实现（与 backend.x emit_while_loop_elf 语义一致）。
 */
int32_t backend_emit_while_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                         int32_t ta) {
  int32_t fold_rc;
  int32_t cond_ref;
  int32_t body_ref;
  uint8_t loop_buf[128];
  uint8_t exit_buf[128];
  int32_t loop_len;
  int32_t exit_len;
  pipeline_glue_AsmFuncCtxLayout *ly;

  ly = pipeline_asm_ctx_layout(ctx);
  if (ly && ly->module_ref)
    g_pipeline_asm_emit_module = ly->module_ref;
  /*
   * 各 while fold hook：仅 rc>0 表示已完整发射并 return；rc<0 为误匹配/局部 emit 失败，
   * 须回退通用 while（std.path path_join 等），勿像旧逻辑直接 return -1 整函数 abort。
   */
  {
    int32_t mc_rc = glue_try_fold_mem_copy_outer_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (mc_rc > 0)
      return 0;
  }
  /* struct_pair n²：闭式 s=n*n；hook 启用，函数体逐步恢复。 */
  {
    int32_t struct_rc = glue_try_fold_struct_pair_n2_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (struct_rc > 0)
      return 0;
  }
  {
    int32_t u8_rc = glue_try_fold_u8_fill_index_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (u8_rc > 0)
      return 0;
    u8_rc = glue_try_fold_u8_sum_index_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (u8_rc > 0)
      return 0;
  }
  {
    int32_t lcg_rc = glue_try_fold_lcg_xor_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (lcg_rc > 0)
      return 0;
  }
  {
    int32_t simd_peel_rc;
    simd_peel_rc = glue_try_simd_peel_f32_soa_sum_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (simd_peel_rc > 0)
      return 0;
    simd_peel_rc = glue_try_simd_peel_index_add_while_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
    if (simd_peel_rc > 0)
      return 0;
  }
  fold_rc = backend_try_fold_count_up_while_elf(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
  if (fold_rc > 0)
    return 0;
  /** fold 匹配但 emit 失败（fold_rc<0）时回退通用 while，勿 abort 整模块 codegen。 */
  cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
  body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: while emit br=%d wi=%d cond=%d body=%d\n", (int)block_ref, (int)loop_idx, (int)cond_ref,
            (int)body_ref);
  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_buf, 64);
  exit_len = pipeline_asm_emit_next_label_c(ctx, exit_buf, 64);
  if (loop_len <= 0 || exit_len <= 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, loop_buf, loop_len, 0, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cond_ref, ctx, ta) != 0)
    return -1;
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, exit_buf, exit_len, ta) != 0)
    return -1;
  if (backend_ctx_push_loop_labels(ctx, exit_buf, exit_len, loop_buf, loop_len) != 0)
    return -1;
  glue_loop_break_exit_push();
  if (backend_emit_loop_body_content_elf_sync(arena, elf_ctx, body_ref, ctx, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_jmp_arch(elf_ctx, loop_buf, loop_len, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_label_arch(elf_ctx, exit_buf, exit_len, 0, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  glue_asm_cache_invalidate_at_cfg_merge_selective(arena, ctx, body_ref, 0);
  glue_asm_loop_phi_invalidate_carried_defs(arena, ctx, body_ref);
  glue_asm_loop_merge_live_union(arena, ctx, body_ref);
  glue_loop_break_exit_pop();
  backend_ctx_pop_loop_labels(ctx);
  return 0;
}

/**
 * ELF for 循环；C glue 真实现（与 backend.x emit_for_loop_elf 语义一致）。
 *
 * wave653: continue must target the *step* label, not the cond head.
 * C for-semantics: continue → step → cond. Old path pushed loop_buf (cond) as
 * continue_label → `for (…; i = i + 1)` body `continue` skipped step → infinite
 * when i stuck (masked until loop-body final_expr no longer early-returned).
 * Empty step (`for ( ; c ; )`) still uses step label (= fall into jmp head).
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.
 */
int32_t backend_emit_for_loop_elf_sync(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t init_ref;
  int32_t cond_ref;
  int32_t step_ref;
  int32_t body_ref;
  uint8_t loop_buf[128];
  uint8_t exit_buf[128];
  uint8_t step_buf[128];
  int32_t loop_len;
  int32_t exit_len;
  int32_t step_len;

  init_ref = ast_ast_block_for_init_ref(arena, block_ref, for_idx);
  cond_ref = ast_ast_block_for_cond_ref(arena, block_ref, for_idx);
  step_ref = ast_ast_block_for_step_ref(arena, block_ref, for_idx);
  body_ref = ast_ast_block_for_body_ref(arena, block_ref, for_idx);
  if (init_ref != 0 && pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
    return -1;
  loop_len = pipeline_asm_emit_next_label_c(ctx, loop_buf, 64);
  exit_len = pipeline_asm_emit_next_label_c(ctx, exit_buf, 64);
  step_len = pipeline_asm_emit_next_label_c(ctx, step_buf, 64);
  if (loop_len <= 0 || exit_len <= 0 || step_len <= 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, loop_buf, loop_len, 0, ta) != 0)
    return -1;
  if (cond_ref != 0) {
    if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cond_ref, ctx, ta) != 0)
      return -1;
    if (glue_enc_jz_after_bool_in_eax(elf_ctx, exit_buf, exit_len, ta) != 0)
      return -1;
  }
  /* continue → step_buf (not loop_buf); break → exit_buf. */
  if (backend_ctx_push_loop_labels(ctx, exit_buf, exit_len, step_buf, step_len) != 0)
    return -1;
  glue_loop_break_exit_push();
  if (backend_emit_loop_body_content_elf_sync(arena, elf_ctx, body_ref, ctx, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_label_arch(elf_ctx, step_buf, step_len, 0, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (step_ref != 0 && pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, step_ref, ctx, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_jmp_arch(elf_ctx, loop_buf, loop_len, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  if (backend_enc_label_arch(elf_ctx, exit_buf, exit_len, 0, ta) != 0) {
    glue_loop_break_exit_pop();
    backend_ctx_pop_loop_labels(ctx);
    return -1;
  }
  glue_asm_cache_invalidate_at_cfg_merge_selective(arena, ctx, body_ref, 0);
  glue_asm_loop_phi_invalidate_carried_defs(arena, ctx, body_ref);
  glue_asm_loop_merge_live_union(arena, ctx, body_ref);
  if (step_ref != 0)
    glue_live_fwd_apply_expr_effect(arena, ctx, step_ref);
  glue_loop_break_exit_pop();
  backend_ctx_pop_loop_labels(ctx);
  return 0;
}

/**
 * ELF while 循环发射；M8-tail 薄包装入口 → C glue 真实现（勿调 partial backend_emit_while_loop_elf）。
 */
int32_t pipeline_asm_emit_while_loop_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                           int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                           int32_t ta) {
  return backend_emit_while_loop_elf_sync(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
}

/**
 * ELF for 循环发射；M8-tail 薄包装入口 → C glue 真实现。
 */
int32_t pipeline_asm_emit_for_loop_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx,
                                         int32_t ta) {
  return backend_emit_for_loop_elf_sync(arena, elf_ctx, block_ref, for_idx, ctx, ta);
}

/**
 * ELF 循环体 stmt_order；M8-tail 薄包装入口 → C glue 真实现。
 */
int32_t pipeline_asm_emit_loop_body_content_elf_c(struct ast_ASTArena *arena,
                                                  struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t body_ref,
                                                  struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return backend_emit_loop_body_content_elf_sync(arena, elf_ctx, body_ref, ctx, ta);
}

/* wave1176: pipeline_asm_get_return_expr_ref_at migrated to
 * pipeline_asm_emit_return.c EOF (colocated with backend return-expr cluster). */

/**
 * build_xlang_asm SKIP 桩：M8-tail 薄包装 emit bl C 委托 + epilogue；mega 仍 mov w0,#0 + epilogue。
 * 须在 enc_prologue(0) 之后调用；实参已由 ABI 传入 x0..xN。
 */
int32_t pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta,
                                                          struct ast_Module *mod, int32_t func_index) {
  uint8_t cname[72];
  int32_t clen;
  const char *dbg_env;

  clen = 0;
  if (mod != NULL) {
    /** 按序尝试各模块 thin delegate 表；任一命中即写 cname/clen 并停止（返回 1）。 */
    if (asm_backend_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
      if (asm_pipeline_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
        if (asm_parser_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
          if (asm_driver_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen) == 0)
            (void)asm_typeck_m8_tail_thin_delegate_c_name(mod, func_index, cname, (int32_t)sizeof(cname), &clen);
  }
  dbg_env = link_abi_getenv("XLANG_DEBUG_PARSER_DELEGATE");
  if (dbg_env && dbg_env[0] != '\0' && dbg_env[0] != '0' && mod != NULL) {
    static int32_t dbg_stub_n;
    static int32_t dbg_delegate_hit;
    uint8_t fn[128];
    int32_t fl;
    dbg_stub_n++;
    if (clen > 0)
      dbg_delegate_hit++;
    if (dbg_stub_n <= 8 || (clen > 0 && dbg_delegate_hit <= 5)) {
      fl = pipeline_module_func_name_len_at(mod, func_index);
      pipeline_module_func_name_copy64(mod, func_index, fn);
      fprintf(stderr, "parser_delegate_stub #%d fi=%d fn=%.*s clen=%d hit_total=%d\n", (int)dbg_stub_n,
              (int)func_index, (int)(fl > 127 ? 127 : fl), fn, (int)clen, (int)dbg_delegate_hit);
      if (clen > 0)
        fprintf(stderr, "  -> cname=%.*s\n", (int)(clen > 127 ? 127 : clen), cname);
      fflush(stderr);
    }
    if (dbg_stub_n == 1) {
      int32_t fi;
      int32_t probe_clen;
      uint8_t probe_c[72];
      for (fi = 0; fi < (int32_t)mod->num_funcs; fi++) {
        if (pipeline_module_func_name_equal_at(mod, fi, (uint8_t *)"first_token_kind", 16)) {
          probe_clen = 0;
          fprintf(stderr, "parser_delegate_probe first_token_kind fi=%d lookup_ret=%d clen=%d\n", (int)fi,
                  (int)asm_parser_m8_tail_thin_delegate_c_name(mod, fi, probe_c, (int32_t)sizeof(probe_c),
                                                                 &probe_clen),
                  (int)probe_clen);
          fflush(stderr);
          break;
        }
      }
    }
  }
  if (clen > 0) {
    if (backend_enc_call_arch(elf_ctx, cname, clen, ta) != 0)
      return -1;
    return backend_enc_epilogue_arch(elf_ctx, ta);
  }
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_epilogue_arch(elf_ctx, ta);
}

/* wave1176: pipeline_asm_get_return_lit_ref_at migrated to
 * pipeline_asm_emit_return.c EOF (colocated with backend return-expr cluster). */

/* wave1177 G.7: arch_arm64 module_func + return_lit forwarders (5 fns)
 * migrated to ast_pool_module_func.c EOF (4 module_func forwarders) +
 * pipeline_asm_emit_return.c EOF (arch_arm64_pipeline_asm_get_return_lit_ref_at
 * already migrated in wave1176 block). The 4 module_func forwarders are
 * colocated with the asm_module_func forwarder family (wave1175).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** ast.x 池 init/alloc：须在 #include ast_pool.c 之前（ast_pool 内 strict parse 调 ast_ast_arena_init）。 */
void ast_expr_layout_prime_call_resolved(void) {
  /* ast.x expr_layout_prime_call_resolved；C glue 侧无额外状态。 */
}
void ast_ast_arena_init(struct ast_ASTArena *arena) {
  if (!arena)
    return;
  ast_expr_layout_prime_call_resolved();
  arena->num_types = 0;
  arena->num_exprs = 0;
  arena->num_blocks = 0;
  arena->num_funcs = 0;
}
int32_t ast_ast_arena_type_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_type_alloc(a);
}
int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_expr_alloc(a);
}
int32_t ast_ast_arena_block_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_block_alloc(a);
}
int32_t ast_ast_arena_func_alloc(struct ast_ASTArena *a) {
  return pipeline_arena_func_alloc(a);
}

/** ast_pool.c 内 pipeline_elf_ctx_resolve_patches 需前置声明（standalone TU 由 pipeline_glue_types.inc 提供）。 */
#ifndef XLANG_PIPELINE_GLUE_STANDALONE_TU
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t name_len);
#endif
struct platform_elf_ElfCodegenCtx;
void pipeline_elf_log_unresolved_patch(struct platform_elf_ElfCodegenCtx *ctx, int32_t patch_idx);

/** ast_pool asm_local_slot_bytes 读取 codegen 期 module（struct layout 真实尺寸）。 */
struct ast_Module *pipeline_asm_glue_emit_module_ref(void) {
  return g_pipeline_asm_emit_module;
}

extern int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t li, int32_t depth);
extern int32_t typeck_x_type_align_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t li, int32_t depth);

/* wave1104 G.7: WPO-S2 mono thunk domain (5 fns + 3 macros + 2 typedefs + 1 global)
 * migrated to pipeline_asm_emit_wpo_mono.c (same-TU #include).
 * Members: glue_wpo_mono_has_sym / _reset_pending / _register_thunk_n / _register_thunk
 * + pipeline_asm_emit_wpo_mono_thunks_elf_c + GLUE_WPO_MONO_* macros + GlueWpoMonoThunk[s]
 * typedef + g_glue_wpo_mono_pending global.
 * Extern deps: codegen_wpo_mono_sym_format (moved to domain file); backend_enc_*_arch
 * (decl L1278+); link_abi_getenv (decl L51). No static deps on other glue domains.
 * PLATFORM: SHARED. */
#include "pipeline_asm_emit_wpo_mono.c"

/* wave1067 G.7: pipeline_asm_ctx_reset_for_func_c migrated to
 * pipeline_asm_emit_block_body.c EOF (per-func ctx reset). Static
 * same-TU: block_body.c #include L3872 < def L8255 < callsite L8342.
 * Deps: pipeline_glue_AsmFuncCtxLayout (struct < L3872);
 * asm_ctx_local_reset (extern). */

/**
 * M8-tail ELF mega 主循环 C 体：打破 seed_mega→backend_asm_codegen_ast_to_elf→pipeline 递归 SIGSEGV。
 * 端口 backend.x asm_codegen_ast_to_elf_seed_mega（2517+）。
 */
/** co-emit dep 导出符号前缀；定义见 backend_call_dispatch.c。 */
extern int32_t glue_asm_build_dep_export_sym_c(const uint8_t *name, int32_t name_len, uint8_t *out, int32_t out_cap);
extern int32_t glue_asm_build_func_export_sym_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                uint8_t *out, int32_t out_cap);
extern int32_t pipeline_typeck_pick_overload_func_index_for_call_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                  int32_t call_expr_ref);
extern int32_t pipeline_typeck_resolve_call_func_index_for_emit_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                  int32_t call_expr_ref);

int32_t pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                             struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                             struct ast_PipelineDepCtx *pipeline_ctx) {
  int32_t ta;
  pipeline_glue_AsmFuncCtxLayout ctx;
  uint8_t fname_buf[128];
  int32_t start_skip;
  int32_t emit_n;
  int32_t k;

  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  ta = pipeline_ctx->target_arch;
  if (ta == 1) {
    elf_ctx->e_machine = 183;
    elf_ctx->reloc_type_r_pc32 = 283;
  } else if (ta == 2) {
    elf_ctx->e_machine = 243;
    elf_ctx->reloc_type_r_pc32 = 32;
  } else {
    elf_ctx->e_machine = 62;
    elf_ctx->reloc_type_r_pc32 = 2;
  }
  memset(&ctx, 0, sizeof(ctx));
  pipeline_asm_wpo_pgo_emit_order_prepare(m);
  start_skip = asm_diag_start_func_skip();
  emit_n = pipeline_asm_wpo_pgo_emit_order_count(m);
  /**
   * PLATFORM: SHARED x86_64 — emit text-embedded module mutable lit cells once before funcs
   * so set_g/get_g share storage (not per-fn stack). Non-x86: no-op, stack residual.
   */
  if (pipeline_asm_modlet_prepare_and_emit_elf_c(m, a, elf_ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: mega_body_c modlet prepare fail\n");
    return -1;
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: mega_body_c start emit_n=%d start_skip=%d nf=%d\n", (int)emit_n, (int)start_skip,
            (int)pipeline_module_num_funcs(m));
  for (k = 0; k < emit_n; k++) {
    int32_t i = pipeline_asm_wpo_pgo_emit_order_at(m, k);
    int32_t body_ref;
    int32_t frame_sz;
    int32_t fname_len;
    int32_t export_sym_len;
    int32_t result_ref;
    uint8_t export_sym[128];
    struct backend_AsmFuncCtx *bctx = (struct backend_AsmFuncCtx *)&ctx;

    if (i < 0)
      continue;
    if (i < start_skip)
      continue;
    pipeline_elf_ctx_set_emit_hot((uint8_t *)elf_ctx, pipeline_asm_wpo_pgo_is_hot_func(m, i));
    pipeline_asm_module_func_name_copy64(m, i, fname_buf);
    fname_len = pipeline_asm_module_func_name_len_at(m, i);
    driver_diagnostic_asm_set_current_func(fname_buf, fname_len);
    pipeline_asm_emit_set_func_index(i);
    pipeline_debug_trace_named_func_bodies("mega_pre_reset", m, a);
    pipeline_asm_ctx_reset_for_func_c(&ctx, m);
    ctx.dep_pipe = pipeline_ctx;
    g_pipeline_asm_func_sret_active = 0;
    g_pipeline_asm_sret_home_off = -1;
    g_pipeline_asm_func_sret_ret_sz = 0;
    pipeline_asm_fill_param_slots(bctx, m, i);
    pipeline_debug_trace_named_func_bodies("mega_post_param_slots", m, a);
    /**
     * >16B return: reserve 8B to save incoming hidden dest (before top-level lets).
     * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 x8 (wave591).
     * fill_param_slots already set next_offset ≥ 16 (saved fp/lr / rbx reserve).
     */
    if (ta == 0 || ta == 1) {
      int32_t fn_ret_sz = glue_func_return_byte_size_c(m, a, i);
      if (fn_ret_sz > 16) {
        g_pipeline_asm_func_sret_ret_sz = fn_ret_sz;
        g_pipeline_asm_func_sret_active = 1;
        g_pipeline_asm_sret_home_off = ctx.next_offset;
        ctx.next_offset += 8;
      }
    }
    pipeline_asm_register_module_top_level_lets_c(bctx, m, a, i);
    pipeline_debug_trace_named_func_bodies("mega_post_register_top_level", m, a);
    /* wave580 Cap: export_sym is u8[128]; out_cap must be 128 (was 64 → silent truncate / clen<cap reject at 64). */
    export_sym_len = glue_asm_build_func_export_sym_c(m, a, i, export_sym, 128);
    if (export_sym_len <= 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, export_sym, export_sym_len, 1, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c enc_label fail func=%.*s\n", (int)export_sym_len, (char *)export_sym);
      return -1;
    }
    if (asm_skip_heavy_module_func_body(m, a, i) != 0) {
      if (backend_enc_prologue_arch(elf_ctx, 0, ta) != 0)
        return -1;
      if (pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(elf_ctx, ta, m, i) != 0)
        return -1;
      continue;
    }
    body_ref = pipeline_asm_module_func_body_ref_at(m, i);
    frame_sz = 0;
    if (body_ref != 0) {
      frame_sz = pipeline_asm_compute_frame_size_c(pipeline_asm_module_func_num_params_at(m, i), a, body_ref, m,
                                                    i);
      pipeline_debug_trace_named_func_bodies("mega_post_frame_size", m, a);
      if (pipeline_asm_block_num_stmt_order_at(a, body_ref) == 0)
        pipeline_asm_fill_local_slots(bctx, a, body_ref);
      pipeline_debug_trace_named_func_bodies("mega_post_fill_local_slots", m, a);
    }
    if (backend_enc_prologue_arch(elf_ctx, frame_sz, ta) != 0)
      return -1;
    /*
     * wave603: arm64 MEMORY param_home needs frame_size so incoming stack args
     * resolve at [x29+frame] (wave414 low-end prologue), not [x29+16] identity.
     */
    if (bctx) {
      pipeline_glue_AsmFuncCtxLayout *ly_fs = pipeline_asm_ctx_layout(bctx);
      if (ly_fs)
        ly_fs->frame_size = frame_sz;
    }
    if (pipeline_asm_emit_param_home_elf_c(elf_ctx, bctx, m, i, ta) != 0)
      return -1;
    /** Mutable module-level lit lets on non-hoist: seed stack slots after param home. */
    if (pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a, elf_ctx, bctx, m, i, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c top_level lit inits fail func=%.*s fi=%d\n", (int)fname_len,
                (char *)fname_buf, (int)i);
      return -1;
    }
    /** COMMON BSS starts zero; non-zero modlet inits (e.g. -1) once on hoist target. */
    if (i == pipeline_asm_hoist_target_func_index(m) &&
        pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c modlet nonzero seed fail func=%.*s\n", (int)fname_len,
                (char *)fname_buf);
      return -1;
    }
    if (pipeline_asm_emit_async_cps_entry_elf_c(a, elf_ctx, bctx, m, i, ta) != 0)
      return -1;
    if (body_ref != 0) {
      ctx.tail_join_label_len = pipeline_asm_emit_next_label_c(bctx, ctx.tail_join_label, 64);
      if (pipeline_asm_block_num_stmt_order_at(a, body_ref) > 0) {
        pipeline_debug_trace_named_func_bodies("mega_pre_emit_block_body", m, a);
        if (backend_emit_block_body_sync_elf(a, elf_ctx, body_ref, bctx, ta) != 0) {
          if (link_abi_getenv("XLANG_ASM_DEBUG"))
            fprintf(stderr, "xlang: mega_body_c emit_block_body fail func=%.*s fi=%d body_ref=%d\n",
                    (int)fname_len, (char *)fname_buf, (int)i, (int)body_ref);
          return -1;
        }
      } else {
        int32_t slot_base =
            ctx.num_locals - ast_ast_block_num_consts(a, body_ref) - ast_ast_block_num_lets(a, body_ref);
        if (slot_base < 0)
          return -1;
        if (pipeline_asm_emit_block_inits_elf_c(a, elf_ctx, body_ref, bctx, ta, slot_base) != 0)
          return -1;
      }
      if (backend_enc_label_arch(elf_ctx, ctx.tail_join_label, ctx.tail_join_label_len, 0, ta) != 0)
        return -1;
    }
    result_ref = 0;
    if (body_ref == 0 || pipeline_asm_block_num_stmt_order_at(a, body_ref) == 0)
      result_ref = pipeline_asm_get_return_expr_ref_at(a, m, i);
    if (result_ref != 0) {
      if (pipeline_asm_emit_expr_elf_c(a, elf_ctx, result_ref, bctx, ta) != 0)
        return -1;
    }
    /**
     * PLATFORM: LINUX+MACOS x86_64 SysV — place scalar float return in xmm0 before epilogue.
     * Internal path holds IEEE bits in eax/rax; callee ABI requires xmm0 for f32/f64.
     * Covers both explicit result_ref and values that jumped to tail_join via return stmts.
     */
    if (ta == 0) {
      int32_t rty = pipeline_module_func_return_type_at(m, i);
      int32_t rkind = (rty > 0) ? pipeline_type_kind_ord_at(a, rty) : -1;
      if (rkind == GLUE_TYPE_KIND_F32_ORD) {
        if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
          return -1;
      } else if (rkind == GLUE_TYPE_KIND_F64_ORD) {
        if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
          return -1;
      }
    }
    if (backend_enc_epilogue_arch(elf_ctx, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: mega_body_c epilogue fail func=%.*s fi=%d\n", (int)fname_len, (char *)fname_buf,
                (int)i);
      return -1;
    }
    pipeline_asm_emit_async_cps_end_func_elf_c();
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: mega_body_c done emit_n=%d rc=0\n", (int)emit_n);
  return 0;
}

#include "ast_pool.c"
/* R2 unbundle (2026-07-21): async_asm_pool is a separate product TU
 * (src/async/async_asm_pool.o), not embedded here.
 * Cold: seeds/async_asm_pool.from_x.c full C.
 * PREFER: src/asm/async_asm_pool.x + rest (-DXLANG_ASYNC_ASM_POOL_FROM_X, marker).
 * Call sites use include/async_asm_pool.h (top of this file).
 * PLATFORM: SHARED — link DRIVER_SEED_SUPPORT / g05_relink_env. */
/* #include "seeds/async_asm_pool.from_x.c" — retired; see src/async/async_asm_pool.o */

extern void parser_parse_into_init(struct ast_Module *module, struct ast_ASTArena *arena);
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                            uint8_t *data, int32_t len);
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t idx, uint8_t out[128]);
extern int32_t preprocess_x_buf(uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                             int32_t out_cap);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);

/* wave1186 G.7: pipeline parse/load/typeck orchestration cluster (24 fns)
 * migrated to pipeline_parse_orch.c (same-TU #include). Members:
 * pipeline_parse_into_buf_impl_c / _c
 * pipeline_load_import_from_disk_impl_c / _c
 * pipeline_sync_dep_slots_from_driver_impl_c / _c
 * pipeline_parse_into_with_init_buf_impl_c / _c
 * pipeline_parse_into_buf / pipeline_load_import_from_disk /
 * pipeline_sync_dep_slots_from_driver / pipeline_resolve_path_x /
 * pipeline_read_file_x / pipeline_parse_into_with_init_buf (XLANG_WEAK standalone)
 * pipeline_lsp_diag_parse_typeck_buf_impl_c / _c
 * pipeline_lsp_diag_parse_entry_buf_impl_c
 * pipeline_parse_into_with_init_c
 * pipeline_typeck_after_parse_ok_impl_c / _c
 * pipeline_typeck_after_parse_ok_buf_impl_c
 * pipeline_typeck_x_stack_escape_gate_from_src_c
 * pipeline_lsp_diag_parse_typeck_buf / pipeline_typeck_after_parse_ok (XLANG_WEAK standalone)
 * No static state; all extern deps. PLATFORM: SHARED. */
#include "pipeline_parse_orch.c"


extern int32_t backend_emit_expr_call(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                      struct ast_Expr e, struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t backend_emit_expr_method_call(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                             int32_t expr_ref, struct ast_Expr e, struct backend_AsmFuncCtx *ctx,
                                             int32_t target_arch);

/**
 * text asm EXPR_CALL；委托 seed partial backend_emit_expr_call（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_expr_call_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                      struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  struct ast_Expr e;
  if (expr_ref <= 0)
    return -1;
  e = pipeline_arena_expr_get_copy(arena, expr_ref);
  return backend_emit_expr_call(arena, out, expr_ref, e, ctx, target_arch);
}

/**
 * text asm EXPR_METHOD_CALL；委托 seed partial backend_emit_expr_method_call（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_expr_method_call_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  struct ast_Expr e;
  if (expr_ref <= 0)
    return -1;
  e = pipeline_arena_expr_get_copy(arena, expr_ref);
  return backend_emit_expr_method_call(arena, out, expr_ref, e, ctx, target_arch);
}

/* wave1118-1123 G.7: skipped-typeck array-lit/var type backfill domain (5 fns)
 * migrated to pipeline_asm_emit_block_inits.c EOF (block-init domain; forms
 * a tight interdependent cluster with glue_let_name_matches_var wave1084).
 * Members: glue_fill_array_lit_from_decl / glue_expr_in_scope_block_c /
 * glue_fill_var_types_from_params_for_func /
 * glue_fill_var_types_from_lets_in_block / glue_fill_array_lit_types_in_block.
 * #include at L3689 < all callsites (L8981+ public skipped-typeck path).
 * Zero fwd decls required. PLATFORM: SHARED. */

/**
 * C 预检后跳过 .x typeck 时：为各函数体块内 `let buf: u8[N] = [..]` 回填 ARRAY_LIT 的 resolved_type_ref，
 * 使 pipeline_asm_array_lit_elem_type_ref 能取 u8 步长（避免 Hello 打成 H\\0e\\0…）。
 */
void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena) {
  int32_t fi;
  int32_t nf;
  if (!m || !arena)
    return;
  pipeline_debug_trace_named_func_bodies("fill_array_pre", m, arena);
  nf = m->num_funcs;
  for (fi = 0; fi < nf; fi++) {
    int32_t br;
    /** parser EMIT_HEAVY：extern bl→glue 声明占 func 槽但无 body；遍历会 SIGSEGV。 */
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      continue;
    br = pipeline_module_func_body_ref_at(m, fi);
    if (br <= 0)
      continue;
    glue_fill_array_lit_types_in_block(arena, br);
  }
  pipeline_debug_trace_named_func_bodies("fill_array_post", m, arena);
}

/* wave1181 G.7: elf/codegen prefix forwarder cluster (18 fns) migrated to
 * pipeline_elf_codegen_forwarders.c (new domain file, same-TU #include below).
 * Members:
 *  - platform_elf_pipeline_elf_ctx_reloc_* (7 fns: sym_name_ptr/copy64/name_len,
 *    sidecar_reset, offset_at/set, shndx_at) — ElfCodegenCtx reloc accessors
 *  - platform_elf_pipeline_elf_ctx_sym_shndx_at (1 fn) — symtab shndx accessor
 *  - platform_elf_pipeline_elf_pgo_hot_enabled / elf_ctx_set_emit_hot (2 fns) — PGO hot/cold tag
 *  - platform_elf_pipeline_elf_ctx_append_bytes (1 fn) — raw byte stream into ctx
 *  - platform_elf_pipeline_elf_write_o_pgo_to_buf (1 fn) — flush ctx to CodegenOutBuf
 *  - codegen_codegen_out_buf_len / set_len (2 fns) — codegen_ prefix out_buf accessors
 *  - pipeline_codegen_out_buf_len / set_len (2 fns) — pipeline_ prefix aliases
 *  - codegen_pipeline_scratch_buf64 / _slot (2 fns) — codegen_ prefix scratch accessors
 *
 * All 18 are pure pass-through forwarders to unprefixed pipeline_elf_* /
 * codegen_out_buf_* / pipeline_scratch_buf64* implementations in ast_pool.c /
 * pipeline_elf.c / codegen.c. No static state; safe to colocate.
 */
#include "pipeline_elf_codegen_forwarders.c"
/* wave1182 G.7: ast_pipeline forwarder cluster (246 fns) migrated to
 * pipeline_ast_forwarders.c (new domain file, same-TU #include below).
 *
 * Members (246 ast_pipeline forwarders + 1 utility + 1 ast_ast_pool forwarder):
 *  - ast_pipeline_module_func_ (alloc_slot/ref_set/return_type/body_ref/is_extern/
 *    is_async/num_params/num_generic_params/name_equal/name_byte/body_expr_ref)
 *  - ast_pipeline_dep_ctx_ (reset/ndep/module_at/arena_at/set_X/codegen_prefix_X/
 *    current_X/entry_already_parsed/asm_entry_module_only/check_only_mode/
 *    use_asm_backend/entry_dir_byte_at/import_path/set_path_buf_byte/loaded_buf/
 *    ensure_source_buffers/free_source_buffers/heap_destroy/path_buf/preprocess_buf)
 *  - ast_pipeline_ctx_lib_root_ (count/len/copy/byte_at)
 *  - ast_pipeline_scratch_buf (64/96/128/256 + slot variants)
 *  - ast_pipeline_codegen_ (type_kind_copy/append/vector_type_copy/call_num_args/
 *    skip_emit/force_param/use_buf_wrapper/io_driver/fixed_fd/lsp_io)
 *  - ast_pipeline_elf_ctx_ (append_patch/append_reloc)
 *  - ast_pipeline_block_ (append_const/let/if/region/unsafe/with_arena/while/for/
 *    expr_stmt/stmt_order/labeled/fill_X/const_X/let_X/if_X/resolve_var_type_ref)
 *  - ast_pipeline_module_ (import_alloc/set_path/set_kind/set_binding_name/
 *    enum_alloc/enum_set_name/struct_layout_X/top_level_let_X)
 *  - ast_pipeline_onefunc_ (num_consts/lets/whiles/fors/const_X/let_X/append_X/
 *    copy_sidecar)
 *  - ast_pipeline_arena_ (type/expr/block/func cap/alloc)
 *  - pipeline_copy_lib_root_to_buf256 (utility: zero-fill + copy lib_root to 256B buf)
 *  - ast_ast_pool_onefunc_reset (forwarder to ast_pool_onefunc_reset)
 *
 * All 246 ast_pipeline functions are pure pass-through forwarders to unprefixed
 * pipeline_ implementations in ast_pool.c. No static state; safe to colocate.
 */
#include "pipeline_ast_forwarders.c"

/* wave1194 G.7: ast_ast_arena_type_get/set + ast_ast_arena_expr_get/set
 * (4 fns) migrated to ast_pool_arena.c EOF (same-TU #include via
 * ast_pool.c L886). Colocated with block/func get/set (wave1183) +
 * ast_arena_* twin forwarders. Forward decls in ast_pool_arena.c
 * replaced by actual definitions; ast_arena_* twins now delegate to
 * same-file definitions. PLATFORM: SHARED. */
/* wave1183 G.7: ast_ast_arena_*_get/set + ast_arena_*_get/set forwarder
 * cluster (14 fns) migrated to ast_pool_arena.c EOF (same-TU #include).
 * Members: block/func get/set (ast_ast_ prefix) + type/expr/block/func
 * get/set (ast_ prefix, delegates to ast_ast_ twins).
 * All pure forwarders to pipeline_arena_*_get_copy/_set_copy impls. */

int ast_ref_is_null(int32_t ref) {
  return ref == 0;
}

/* wave1183 G.7: ast_ast_arena_patch + ast_ast_block_* getters cluster
 * (20 fns) migrated to ast_pool_block.c EOF (same-TU #include already exists).
 * Members: patch_block_parent_links + num_consts/lets/loops/for_loops/if_stmts/
 * regions/expr_stmts/stmt_order + region_body_ref + stmt_order_kind/idx +
 * const_init/type_ref + let_init/type_ref + expr_stmt_ref + final_expr_ref.
 * All pure forwarders to pipeline_block_ / pipeline_patch_block_parent_links. */

/* wave1191 G.7: typeck func_body implicit return tail cluster (3 fns)
 * migrated to pipeline_typeck_check_block.c EOF. Colocated with check_block
 * walker domain — func_body tail analysis is a sub-domain of block typeck.
 *
 * Members: pipeline_typeck_func_body_tail_expr_ref_for_implicit_rule_c +
 *          pipeline_typeck_func_body_has_implicit_return_tail_c +
 *          pipeline_typeck_patch_all_body_parent_links_c (XLANG_WEAK).
 *
 * Forward decls visible at #include point (check_block.c) via earlier decls:
 * - ast_ast_block_* / pipeline_block_* / pipeline_expr_* (extern)
 * - implicit_tail_expr_disallowed_by_glue (defined earlier in glue.c before
 *   check_block.c #include — visible in same TU)
 * - ast_ast_arena_patch_block_parent_links / pipeline_module_func_body_ref_at
 *   (extern)
 * - link_abi_getenv (extern)
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1158 G.7: typeck type_refs_equal / type_ref_is_bool / expr_type_ref
 * public wrappers (9 extern fns) migrated to pipeline_typeck_coerce_init.c
 * EOF (colocated with wave1080-1083 static implementations). Extern fwd
 * decls below for callsites before #include L9626. */
int32_t pipeline_typeck_type_refs_equal_named_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_refs_equal_same_kind_c(struct ast_ASTArena *arena, int32_t a, int32_t b,
                                                     int32_t kind_ord);
int32_t pipeline_typeck_resolve_type_alias_ref_c(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_refs_equal_impl_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
int32_t pipeline_typeck_type_ref_is_bool_impl_c(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_typeck_type_ref_is_bool_c(struct ast_ASTArena *arena, int32_t type_ref);
int32_t pipeline_typeck_expr_type_ref_impl_c(struct ast_ASTArena *arena, int32_t expr_ref);
int32_t pipeline_typeck_expr_type_ref_c(struct ast_ASTArena *arena, int32_t expr_ref);

/* wave1080 G.7: typeck_named_unqual_offset_c migrated to
 * pipeline_typeck_coerce_init.c EOF (NAMED type unqualified-name offset:
 * find last '.' +1). Static same-TU: fwd decl below (before callsites in
 * typeck_glue_type_refs_equal_named L10117/10118) < coerce_init.c #include
 * L14126 < def EOF. Deps: none (pure buf scan). */
static int32_t typeck_named_unqual_offset_c(const uint8_t *buf, int32_t len);

/* wave1081 G.7: typeck_glue_type_refs_equal_named migrated to
 * pipeline_typeck_coerce_init.c EOF (NAMED type_refs_equal: full-name then
 * unqualified suffix match). Static same-TU: fwd decl below (before callsites
 * L10134/10145) < coerce_init.c #include L14126 < def EOF. Deps:
 * typeck_named_unqual_offset_c (same file, def above) /
 * typeck_scratch64_slot (extern L10447) / pipeline_type_named_name_into (extern). */
static int32_t typeck_glue_type_refs_equal_named(struct ast_ASTArena *arena, int32_t a, int32_t b);

/* wave1082 G.7: typeck_glue_type_refs_equal_impl migrated to
 * pipeline_typeck_coerce_init.c EOF (type_refs_equal internal impl: read kind
 * then delegate to same_kind). Static same-TU: fwd decl below (before callsites
 * L10199/10204) < coerce_init.c #include L14126 < def EOF. Deps:
 * pipeline_typeck_type_refs_equal_same_kind_c (extern, glue.c L10108) /
 * pipeline_type_kind_ord_at (extern). */
static int32_t typeck_glue_type_refs_equal_impl(struct ast_ASTArena *arena, int32_t a, int32_t b);

/** WPO-S3：typeck 活跃 module（type 别名展开等 glue 回落；定义见文件前部 g_typeck_active_module）。 */
extern int32_t pipeline_module_num_type_aliases_at(struct ast_Module *m);
extern int32_t pipeline_module_type_alias_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_type_alias_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_type_alias_target_ref(struct ast_Module *m, int32_t idx);

/* wave1083 G.7: pipeline_typeck_resolve_type_alias_ref_impl_c body migrated to
 * pipeline_typeck_coerce_init.c EOF (type alias chain resolver: NAMED → target
 * ref, depth-limited recursion). Static fwd decl below (before callsite in
 * resolve_type_alias_ref_c, now in coerce_init.c). Body 36 LOC. Deps:
 * ast_ref_is_null (global) / pipeline_module_num_type_aliases_at (extern) /
 * pipeline_type_kind_ord_at (extern) / pipeline_type_named_name_into (extern) /
 * pipeline_module_type_alias_name_len (extern) /
 * pipeline_module_type_alias_name_byte_at (extern) /
 * pipeline_module_type_alias_target_ref (extern). */
static int32_t pipeline_typeck_resolve_type_alias_ref_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                             int32_t type_ref, int32_t depth);

/* wave1158 G.7: 9 extern public wrappers (type_refs_equal_named_c /
 * type_refs_equal_same_kind_c / resolve_type_alias_ref_c /
 * type_refs_equal_c / type_refs_equal_impl_c / type_ref_is_bool_impl_c /
 * type_ref_is_bool_c / expr_type_ref_impl_c / expr_type_ref_c) migrated to
 * pipeline_typeck_coerce_init.c EOF — colocated with wave1080-1083 static
 * implementations. Bodies removed; extern fwd decls above. */

/* wave1156 G.7: typeck diag fmt cluster (5 fns) migrated to
 * pipeline_typeck_assign.c EOF (colocated with assign mismatch diag domain —
 * 8 callsites in assign.c lines 265-336; sole glue.c callsite at L8147 in
 * check_expr_return return-type mismatch diag). Extern (non-static):
 * assign.c #include at L8265; extern fwd decl at L8013 (before L8147 callsite).
 * Cluster: diag_append_lit_c / diag_append_u32_dec_c / diag_fmt_type_at_c /
 * diag_fmt_type_into_c / diag_fmt_type_or_question_c. PLATFORM: SHARED. */

/* wave1076 G.7: pipeline_typeck_float_widen_ok_c migrated to
 * pipeline_typeck_coerce_init.c EOF (f32→f64 IEEE float widen gate).
 * Static same-TU: fwd decl below (before all callsites L10570/10650/11132/
 * 13272) < coerce_init.c #include L14126 < def EOF. Deps: ast_TypeKind_* (global). */
static int32_t pipeline_typeck_float_widen_ok_c(int32_t dest_kind, int32_t src_kind);

/* wave1077 G.7: pipeline_typeck_integer_widen_ok_c migrated to
 * pipeline_typeck_coerce_init.c EOF (first-class integer widen gate).
 * Static same-TU: fwd decl below (before sole callsite in refs_c L10523) <
 * coerce_init.c #include L14126 < def EOF. Deps: ast_TypeKind_* (global). */
static int32_t pipeline_typeck_integer_widen_ok_c(int32_t dest_kind, int32_t src_kind);

/* wave1077 G.7: pipeline_typeck_integer_widen_ok_c body migrated to
 * pipeline_typeck_coerce_init.c EOF (first-class integer widen gate).
 * Static fwd decl at L10441 (before sole callsite in refs_c). Body 36 LOC. */

extern uint8_t *typeck_scratch64_slot(int32_t slot);

/* wave1078 G.7: pipeline_typeck_int_family_id_c migrated to
 * pipeline_typeck_coerce_init.c EOF (family id for first-class ints + NAMED
 * i8/i16/u16). Static same-TU: fwd decl below (before callsites in refs_c
 * L10485/10486) < coerce_init.c #include L14126 < def EOF. Deps:
 * typeck_scratch64_slot (extern L10447) / pipeline_type_named_name_into (extern). */
static int32_t pipeline_typeck_int_family_id_c(struct ast_ASTArena *arena, int32_t type_ref);

/* wave1079 G.7: pipeline_typeck_integer_widen_ok_refs_c migrated to
 * pipeline_typeck_coerce_init.c EOF (refs-based integer widen: first-class +
 * NAMED i8/i16/u16). Static same-TU: fwd decl below (before all callsites
 * L10590/10646/11074/13212) < coerce_init.c #include L14126 < def EOF.
 * Deps: pipeline_typeck_int_family_id_c + pipeline_typeck_integer_widen_ok_c
 * (both in coerce_init.c EOF, same file — direct call, no fwd needed). */
static int32_t pipeline_typeck_integer_widen_ok_refs_c(struct ast_ASTArena *arena, int32_t dest_ref,
                                                       int32_t src_ref);

/* wave1076 G.7: pipeline_typeck_float_widen_ok_c body migrated to
 * pipeline_typeck_coerce_init.c EOF (f32→f64 IEEE float widen gate).
 * Static fwd decl at L10435 (before all callsites). Body 10 LOC. */

/* wave1130-1131 G.7: glue_maybe_promote_f32_to_f64_rax_elf_c /
 * glue_float_promote_src_ty_ref_c migrated to pipeline_asm_emit_return.c EOF
 * (colocated with wave314 return float-widen callsites at L542/543/630/631/
 * 640/641). Same-TU visibility via #include @ L1913. */

/**
 * typeck.x::typeck_return_operand_matches C twin (G.7 single semantic).
 * Accept equal types, integer widen (wave313), f32→f64 (wave314), linear unwrap.
 * wave671 Cap residual: do NOT accept BOOL_LIT / LOGNOT as TYPE_I32
 * (`return true` / `return !x` false-green). Align with wave666 no int↔bool.
 * Explicit `as i32` stamps target before match. LANG-006 bool→int is let/const
 * coerce only. PLATFORM: SHARED — product return path often hits this glue twin
 * (Ubuntu) while typeck.x body is the seed twin; both must match.
 */
/* wave1165 G.7: ret coerce cluster (3 fns:
 * pipeline_typeck_return_operand_matches_c /
 * pipeline_typeck_ret_coerce_integral_to_expect_i32_c /
 * pipeline_typeck_ret_coerce_integral_widen_c) migrated to
 * pipeline_typeck_coerce_init.c EOF (colocated with coerce-init domain —
 * return coercion is the return-path twin of let/const/arg init coercion).
 * Forward decls below for callsites at L7367-7370 (before coerce_init.c
 * #include at L9010). Deps all visible at coerce_init.c #include L9010. */
int32_t pipeline_typeck_return_operand_matches_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t expect_ref);
void pipeline_typeck_ret_coerce_integral_to_expect_i32_c(struct ast_ASTArena *arena, int32_t op_ref,
                                                         int32_t expect_ref);
void pipeline_typeck_ret_coerce_integral_widen_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t expect_ref);

/** EXPR_RETURN 诊断与 scratch 缓冲（runtime.c）。 */
extern void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref,
                                              int32_t got_ty_ref);
extern void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col, uint8_t *expect_buf,
                                                     int32_t expect_len, uint8_t *found_buf, int32_t found_len);
extern void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col,
                                                     uint8_t *expect_buf, int32_t expect_len, uint8_t *found_buf,
                                                     int32_t found_len);
extern void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_subscript_index(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col);
extern uint8_t *driver_typeck_diag_scratch_expect(void);
extern uint8_t *driver_typeck_diag_scratch_found(void);

/** 前向声明：panic/return C 委托内递归 check 子表达式。 */
int32_t pipeline_typeck_check_expr_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

extern void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col);

/* wave1189 G.7: typeck check_expr sub-class cluster (8 fns + 3 match helpers
 * + 2 match statics) migrated to pipeline_typeck_check_expr.c EOF (colocated
 * with wave1188 entry/dispatch domain). Members removed from here:
 * pipeline_typeck_check_expr_panic_c
 * + match subject helpers: g_typeck_match_subject_{ty,mod} statics +
 *   pipeline_typeck_match_set_subject_c / clear_subject_c /
 *   subject_field_type_c (sole users of those statics)
 * + pipeline_typeck_check_expr_match_c
 * + pipeline_typeck_check_expr_return_c
 * + pipeline_typeck_check_expr_unary_c
 * + pipeline_typeck_check_expr_addr_of_c
 * + pipeline_typeck_check_expr_deref_c
 * + pipeline_typeck_check_expr_index_c
 * + pipeline_typeck_check_expr_var_c
 * All extern (non-static): cross-TU calls (typeck_x.o / typeck.o / seeds).
 * g_typeck_unsafe_depth remains here (shared with check_block.c via #include).
 * Forward decls below remain for other glue.c callsites. PLATFORM: SHARED. */

/* wave1189+1190: fwd decls for migrated check_expr helpers (defined in
 * pipeline_typeck_check_expr.c EOF, #included at L6246). Needed because:
 * - check_expr.c impl_mega_c / impl_c call match/deref/var/call before their def
 * - check_expr.c check_expr_c calls try_propagate before its def
 * - glue.c typeck_check_expr_deref wrapper at L6207 calls deref_c
 * - glue.c typeck_check_expr_call wrapper at L6216 calls call_c */
int32_t pipeline_typeck_check_expr_match_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_return_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_deref_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_var_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                         struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_try_propagate_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t return_type_ref,
                                                    struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_expr_call_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_coerce_init_struct_lit_to_decl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t init_ref, int32_t decl_ty_ref);
/* wave318: return path reuses lit coerce before body (defined with coerce family). */
int32_t pipeline_typeck_coerce_init_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref, int32_t decl_ty_ref,
                                                  int32_t decl_kind, int32_t init_kind);
/* wave316: return path reuses float_lit coerce before body (defined with coerce family). */
int32_t pipeline_typeck_coerce_init_float_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
/* wave319: return path reuses int_binop coerce for EXPR_NEG/int binop → f32/f64. */
int32_t pipeline_typeck_coerce_init_int_binop_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                        int32_t decl_ty_ref, int32_t decl_kind, int32_t init_kind);
/* wave333: return ARRAY_LIT → TYPE_SLICE/ARRAY/VECTOR (def with coerce family). */
int32_t pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(struct ast_ASTArena *arena, int32_t init_ref,
                                                               int32_t decl_ty_ref, int32_t decl_kind,
                                                               int32_t init_kind);

/** bootstrap typeck 后处理（METHOD_CALL / 泛型 CALL）；定义见 pipeline_typeck_bootstrap_expr_fixup_c。 */
static void pipeline_typeck_bootstrap_expr_fixup_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref);

/* wave1156 G.7: extern fwd decl for diag fmt cluster migrated to
 * pipeline_typeck_assign.c EOF. Callsite at L8142 precedes assign.c
 * #include at L8265. */
int32_t pipeline_typeck_diag_fmt_type_or_question_c(struct ast_ASTArena *arena, int32_t ref, uint8_t *out);

/* wave1189 G.7: pipeline_typeck_check_expr_return_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

/** typeck.o / typeck_x：按元素类型分配或复用 *T Type ref。 */
extern int32_t find_or_alloc_ptr_type_ref(struct ast_ASTArena *arena, int32_t elem_ref);

/* wave1189 G.7: pipeline_typeck_check_expr_unary_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

/** WPO-S3：&local struct → stack_local *T；定义在 typeck_var_is_block_local_c 之后。 */
int32_t pipeline_typeck_ptr_for_addr_of_operand_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t elem_ty,
                                                  struct ast_Module *module, struct ast_PipelineDepCtx *ctx);

/* wave1189 G.7: pipeline_typeck_check_expr_addr_of_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t pipeline_dep_ctx_typeck_unsafe_depth_at(struct ast_PipelineDepCtx *ctx);
/* Cap-T001 / WPO-S3 post-scan: push/pop must be visible before typeck_scan_block_stack_escape_c. */
int32_t pipeline_typeck_unsafe_depth_push_c(struct ast_PipelineDepCtx *ctx);
void pipeline_typeck_unsafe_depth_pop_c(struct ast_PipelineDepCtx *ctx, int32_t saved_unsafe_depth);

/** LANG-007 v2：unsafe { } 嵌套深度侧车（不扩 PipelineDepCtx，避免 seed 结构体漂移）。 */
static int32_t g_typeck_unsafe_depth;

extern void driver_diagnostic_typeck_deref_outside_unsafe(int32_t line, int32_t col);

/* wave1189 G.7: pipeline_typeck_check_expr_deref_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). g_typeck_unsafe_depth + driver_diagnostic_typeck_deref_outside_unsafe
 * extern remain here (shared with check_block.c via same-TU #include).
 * PLATFORM: SHARED. */

/* typeck assign domain (lit narrow + EXPR_ASSIGN): pipeline_typeck_assign.c */
#include "pipeline_typeck_assign.c"

#include "pipeline_typeck_soa.c"

/** skip typeck 时从 STRUCT_LIT 补登记 module.struct_layouts（typeck.x ensure_struct_layout_from_struct_lit）。 */
extern int32_t typeck_ensure_struct_layout_from_struct_lit(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t expr_ref);

/**
 * asm emit 前：为 `arr[i].field` SoA 读/写补 col_base + stride（C/X typeck 遗漏或 skip 时）。
 * 须在 glue_fill_var_types_from_lets 之后（INDEX 基址须 resolved T[N]）。
 */
void pipeline_fill_soa_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena) {
  int32_t fi;
  int32_t ei;
  int32_t saved_fi;
  if (!m || !arena)
    return;
  pipeline_debug_trace_named_func_bodies("fill_cl_pre", m, arena);
  /** skip typeck：STRUCT_LIT 字段合并进 module.struct_layouts（parser 仅登记 head 时补 tail 等）。 */
  for (ei = 1; ei <= arena->num_exprs; ei++) {
    if (pipeline_expr_kind_ord_at(arena, ei) == (int32_t)ast_ExprKind_EXPR_STRUCT_LIT)
      (void)typeck_ensure_struct_layout_from_struct_lit(m, arena, ei);
  }
  /** DOD-CL：parser 偶发只写首字段 align(N) 时，后继 u32 字段继承同 line 对齐再重算 offset。 */
  {
    int32_t li;
    int32_t nf2;
    int32_t j;
    for (li = 0; li < pipeline_module_num_struct_layouts_at(m); li++) {
      nf2 = pipeline_module_struct_layout_num_fields(m, li);
      for (j = 0; j + 1 < nf2; j++) {
        int32_t fa0 = pipeline_module_struct_layout_field_align_at(m, li, j);
        if (fa0 >= 64 && pipeline_module_struct_layout_field_align_at(m, li, j + 1) == 0)
          pipeline_module_struct_layout_set_field_align(m, li, j + 1, fa0);
      }
    }
  }
  /** DOD-CL-S1：align(N) 字段 offset 按 field_align 重算并落盘，再填 FIELD_ACCESS。 */
  glue_sync_struct_layout_field_offsets_c(m, arena);
  if (link_abi_getenv("XLANG_ASM_DEBUG")) {
    fprintf(stderr, "xlang: fill_cl n_layouts=%d n_exprs=%d\n", (int)pipeline_module_num_struct_layouts_at(m),
            (int)arena->num_exprs);
  }
  saved_fi = g_pipeline_asm_emit_func_index;
  for (fi = 0; fi < (int32_t)m->num_funcs; fi++) {
    int32_t br;
    /** parser EMIT_HEAVY：extern bl→glue 声明占 func 槽但无 body/params；fill 会 SIGSEGV。 */
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      continue;
    br = pipeline_module_func_body_ref_at(m, fi);
    if (br <= 0)
      continue;
    g_pipeline_asm_emit_func_index = fi;
    glue_fill_var_types_from_lets_in_block(arena, br);
    glue_fill_var_types_from_params_for_func(m, arena, fi);
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: fill_cl func_loop done nf=%d\n", (int)m->num_funcs);
  for (ei = 1; ei <= arena->num_exprs; ei++) {
    int32_t base_ref;
    int32_t flen;
    uint8_t fname[128];
    int32_t layout_off;
    if (pipeline_expr_kind_ord_at(arena, ei) != 44)
      continue;
    base_ref = pipeline_expr_field_access_base_ref(arena, ei);
    if (base_ref <= 0)
      continue;
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 47)
      (void)pipeline_typeck_field_soa_index_c(m, arena, ei, base_ref);
    flen = pipeline_expr_field_access_name_len(arena, ei);
    if (flen <= 0 || flen > 127)
      continue;
    pipeline_expr_field_access_name_into(arena, ei, fname);
    /** SoA arr[i].field：col_base+stride 已由 typeck_field_soa_index 写入 offset；勿用 AoS layout 覆盖 y 列等。 */
    if (pipeline_expr_field_access_soa_stride(arena, ei) > 0)
      continue;
    layout_off = glue_field_layout_offset_for_base_field(arena, m, base_ref, fname, flen);
    if (layout_off >= 0)
      pipeline_expr_set_field_access_offset(arena, ei, layout_off);
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: fill_cl expr_loop done\n");
  g_pipeline_asm_emit_func_index = saved_fi;
  pipeline_debug_trace_named_func_bodies("fill_cl_post", m, arena);
}

/* EXPR_FIELD_ACCESS 子逻辑（prebind/known_ptr/layout/slice/fallback）见 pipeline_typeck_field_access.c */
#include "pipeline_typeck_field_access.c"

/* wave1189 G.7: pipeline_typeck_check_expr_index_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). PLATFORM: SHARED. */

/** typeck_x_no_layout_partial：顶层 let 名比较。 */
extern int32_t typeck_top_level_let_name_equal(struct ast_Module *module, int32_t tl_idx, uint8_t *name,
                                               int32_t name_len);
extern int32_t typeck_name_equal(uint8_t *a, int32_t a_len, uint8_t *b, int32_t b_len);
extern int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *module, int32_t idx);

/* wave1189 G.7: pipeline_typeck_check_expr_var_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with check_expr sub-class
 * cluster). extern above (typeck_top_level_let_name_equal / typeck_name_equal
 * / typeck_find_or_alloc_named_type_ref / pipeline_module_top_level_let_type_ref)
 * remain for other glue.c callsites. PLATFORM: SHARED. */

/* wave1066 G.7: pipeline_typeck_module_num_imports_c migrated to
 * pipeline_typeck_assign.c EOF (unified import count reader). Static
 * same-TU: assign.c #include L11324 < def L11682 < all callsites
 * (L11627/11706/12111). Old fwd decl at L11618 deleted — def visible
 * from #include point. Deps: parser_get_module_num_imports (extern). */
/* wave1192 G.7: pipeline_typeck_import_segment_at_c migrated to
 * pipeline_typeck_method_call.c EOF (import resolution cluster).
 * extern above (pipeline_module_import_path_len/byte_at) remain for
 * other glue.c callsites. PLATFORM: SHARED. */

extern int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len);
extern uint8_t pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_ASTArena *pipeline_get_dep_arena_slot(int32_t i);
extern int32_t pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel);
extern uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel,
                                                          int32_t off);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern void asm_qual_sym_layer_reset(void);
extern int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len);
extern int32_t asm_qual_sym_layer_count(void);
extern int32_t asm_qual_sym_layer_len(int32_t i);
extern void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap);

/* wave1066: def migrated to pipeline_typeck_assign.c EOF. */

/* wave1192 G.7: pipeline_typeck_resolve_dep_index_for_import_c migrated to
 * pipeline_typeck_method_call.c EOF (import resolution cluster).
 * PLATFORM: SHARED. */

/* wave1168 G.7: dep return type + entry module cluster (3 extern fns + 1 static)
 * migrated to pipeline_typeck_method_call.c EOF. Colocated with statics
 * pipeline_typeck_map_import_binding_named_to_caller_c (L2522) and
 * pipeline_typeck_dep_return_type_to_caller_arena_impl (L2563) already in
 * method_call.c.
 *
 * Static g_typeck_entry_module_for_dep_map moves to method_call.c (sole access
 * was from the 3 migrated functions).
 *
 * Forward decls:
 * - pipeline_typeck_get_dep_return_type_in_caller_arena_c: fwd decl at L770
 *   (before callsites L8033/8075 < method_call.c #include L9153)
 * - pipeline_typeck_set_entry_module_for_dep_map_c: callsites at L9469/9536
 *   > method_call.c #include L9153; no fwd decl needed.
 * - pipeline_typeck_dep_return_type_to_caller_arena_c: no glue.c callsites;
 *   extern, called from seed only.
 *
 * Static fwd decls below retained for callsites before method_call.c #include:
 * - pipeline_typeck_map_import_binding_named_to_caller_c (fwd decl below;
 *   callsite was in get_dep_return_type_in_caller_arena_c, now migrated)
 * - pipeline_typeck_dep_return_type_to_caller_arena_impl (fwd decl below;
 *   callsite was in dep_return_type_to_caller_arena_c + get_dep_return_type,
 *   both migrated)
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */
static int32_t pipeline_typeck_map_import_binding_named_to_caller_c(struct ast_Module *entry_mod,
                                                                    int32_t dep_ix,
                                                                    struct ast_ASTArena *caller_arena,
                                                                    uint8_t *nm, int32_t nlen);
static int32_t pipeline_typeck_dep_return_type_to_caller_arena_impl(struct ast_ASTArena *dep_arena,
                                                                    int32_t dep_return_type_ref,
                                                                    struct ast_ASTArena *caller_arena);

/* wave1169 G.7: func resolution cluster (4 extern fns) migrated to
 * pipeline_typeck_method_call.c EOF. Colocated with method_call domain —
 * callee-name matching, func return-type lookup, and call-resolve write-back
 * are all sub-domains of method-call resolution.
 *
 * Forward decl for pipeline_typeck_find_func_return_type_in_module_by_name_c
 * below (before callsite at L8196 < method_call.c #include L9153).
 * Other 3 fns have no glue.c callsites; extern fwd decls in call_args.c
 * (L2479/L2483) cover asm-emit callsites before method_call.c #include.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */
int32_t pipeline_typeck_find_func_return_type_in_module_by_name_c(
    struct ast_Module *mod, struct ast_ASTArena *caller_arena, uint8_t *name, int32_t name_len,
    int32_t from_dep_index, struct ast_PipelineDepCtx *ctx, int32_t *func_index_out);

/* wave1150 G.7: GLUE_TYPECK_IMPORT_BINDING/SELECT enum moved before
 * call_args.c #include (see ~L2237). Needed by glue_asm_resolve_call_target_
 * module_c migrated to call_args.c EOF. Single authority: mirrors ast.x
 * ImportKind. */

/* wave1085-1088 G.7: import path/binding/select name comparison helpers migrated
 * to pipeline_typeck_method_call.c EOF (import binding resolution sub-domain of
 * method_call + generic UFCS). Static (non-extern): same-TU — fwd decls below
 * (before all callsites L11893+) < method_call.c #include at L14053 < def EOF.
 * Deps: pipeline_module_import_path_byte_at /
 * pipeline_module_import_binding_name_len / pipeline_module_import_binding_name_byte_at /
 * pipeline_module_import_select_name_len / pipeline_module_import_select_name_byte_at
 * (all extern). PLATFORM: SHARED. */
static int32_t pipeline_typeck_import_path_segment_count_impl(const uint8_t *path, int32_t path_len);
static int32_t pipeline_typeck_import_path_slice_equal_impl(struct ast_Module *module, int32_t imp_ix, int32_t off,
                                                            int32_t seg_len, uint8_t *nm, int32_t nm_len);
static int32_t pipeline_typeck_import_binding_name_equal_impl(struct ast_Module *module, int32_t imp_ix, uint8_t *nm,
                                                              int32_t nm_len);
static int32_t pipeline_typeck_import_select_name_equal_impl(struct ast_Module *module, int32_t imp_ix, int32_t sel,
                                                             uint8_t *nm, int32_t nm_len);

/* wave1192 G.7: pipeline_typeck_resolve_whole_import_call_ret_c migrated to
 * pipeline_typeck_method_call.c EOF (import resolution cluster). Colocated
 * with method_call domain — qualified import call resolution is a sub-domain
 * of method-call target resolution.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1155 G.7: pipeline_typeck_resolve_call_callee_return_type_c migrated to
 * pipeline_typeck_method_call.c EOF (colocated with resolve_call_func_index_c
 * wave1085-1094 — both resolve CALL callee targets; return-type twin of
 * func_index resolver). Extern (non-static): sole callsite at L10353 is AFTER
 * method_call.c #include at L10186 — visible via extern decl. Deps:
 * GLUE_TYPECK_IMPORT_BINDING/SELECT enum (L2241 < #include L10186), all other
 * deps extern/header-declared. PLATFORM: SHARED. */

extern int32_t pipeline_module_main_func_index(struct ast_Module *m);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t fi);
extern void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t fi, uint8_t *dst);
extern void pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
extern void driver_diagnostic_typeck_func_fail(int32_t func_idx, uint8_t *name, int32_t name_len, int32_t kind);
extern int32_t typeck_validate_struct_layouts_zero_padding_glue(struct ast_Module *module, struct ast_ASTArena *arena);
/** typeck.o EMIT_HEAVY 子 helper；check_block_impl C 编排调用。 */
extern int32_t typeck_check_block_one_const(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_let(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_while(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_for(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_one_if(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                         int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t typeck_check_block_final(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t fin0);
extern void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let,
                                                 int32_t n_loop, int32_t n_for, int32_t n_expr, int32_t final_ref);
/** typeck.o 简单 kind helper；pipeline_typeck_check_expr_impl_c 与 check_expr_impl X 共用。 */
extern int32_t typeck_check_expr_float_lit(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_int_lit(struct ast_ASTArena *arena, int32_t expr_ref, int32_t return_type_ref);
extern int32_t typeck_check_expr_bool_lit(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_break_continue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t expr_ref, int32_t return_type_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_enum_variant(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t typeck_check_expr_if_ternary(struct ast_Module *module, struct ast_ASTArena *arena,
                                            int32_t expr_ref, int32_t return_type_ref,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
/** typeck.o / typeck_x_no_layout 子 helper；kind 分派经 pipeline_typeck_check_expr_impl_mega_c 调用。 */
extern int32_t typeck_check_expr_return(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                        int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_panic(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_assign(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_field_access(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                              int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_index(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_var(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_match(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_call_arg(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx, int32_t arg_i,
                                          int32_t num_args);
extern int32_t typeck_check_expr_call_resolve(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                              struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_method_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                             int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_binop(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_unary(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_addr_of(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                         int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_deref(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                       int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_as(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_expr_struct_lit(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
/** typeck.o EMIT_HEAVY 桩仍导出 impl 符号；C orchestration 经 boundary wrapper 调用。 */
extern int32_t check_expr(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                          int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern int32_t check_block_impl(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
extern void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break);

/*
 * wave92: product pure owns pipeline_typeck_validate_struct_layouts_zero_padding_c
 * (runtime_pipeline_abi.x thin → typeck_validate_struct_layouts_zero_padding). Keep XLANG_WEAK
 * cold fallback for links without pure pipeline_abi / PREFER hybrid (still glue metrics fork).
 * PLATFORM: SHARED — ELF weak overridden by pure; cold uses typeck_validate_*_glue.
 */
XLANG_WEAK int32_t pipeline_typeck_validate_struct_layouts_zero_padding_c(
    struct ast_Module *module, struct ast_ASTArena *arena) {
  return typeck_validate_struct_layouts_zero_padding_glue(module, arena);
}

extern void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);

/** M-3 slice region assign / helpers: body in pipeline_typeck_region_assign.c (included below). */


/** M-4：线性类型 use-once move 跟踪（按变量名；每函数 reset）。 */
#define TYPECK_LINEAR_MOVED_MAX 128
static int g_typeck_linear_moved_n;
static char g_typeck_linear_moved_names[TYPECK_LINEAR_MOVED_MAX][128];
static int32_t g_typeck_linear_moved_lens[TYPECK_LINEAR_MOVED_MAX];

/** WPO-S3：typeck 活跃 module/ctx（call slice 检查等 C glue 无 ctx 参数时回落）。 */
static struct ast_PipelineDepCtx *g_typeck_active_ctx;

/* wave1157 G.7: linear type use-once move tracking cluster (6 fns) migrated
 * to pipeline_typeck_check_block.c EOF (colocated with typeck_linear_name_
 * already_moved wave1132 + check_block walker domain). Extern (non-static):
 * set_active_ctx_c extern fwd decl at L6099 (before callsite at L6109 <
 * check_block.c #include at L10250); linear_reset_c callsites at L10267/
 * 10331/10398 are AFTER #include L10250 — visible. Other 4 fns have no
 * glue.c callsites (called from typeck.x / ast_pool.c / seeds — cross-TU).
 * Globals above (g_typeck_linear_moved_*, g_typeck_active_ctx, TYPECK_LINEAR_
 * MOVED_MAX) stay here — visible in check_block.c via #include after L10250.
 * wave1132 static fwd decl for typeck_linear_name_already_moved removed
 * (sole caller linear_use_var_c now in same file — direct call, no fwd
 * needed). PLATFORM: SHARED. */

/* wave1125-1129 G.7: TYPECK_STACK_LOCAL_PTR_LBL const migrated to
 * pipeline_typeck_region_assign.c (with the 5 stack-escape helpers that
 * are its sole consumers). Visible via #include at L10231. */

static int32_t pipeline_typeck_resolve_call_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                         int32_t call_expr_ref);
static int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena,
                                                                int32_t call_expr_ref,
                                                                struct ast_PipelineDepCtx *ctx);

/* wave1113 G.7: typeck_type_is_named_struct_c migrated to
 * pipeline_asm_emit_struct_lit.c EOF (struct layout registry name-match
 * helper, co-located with layout registry authority). Static (non-extern):
 * same-TU — struct_lit.c #include at L2051 < all callsites (L10422+ /
 * L11189+ / L11240+ / L11363+). PLATFORM: SHARED. */

/* wave1125-1129 G.7: WPO-S3 stack-escape analysis helpers (5 fns + const)
 * migrated to pipeline_typeck_region_assign.c EOF (stack-escape local-var
 * detection cluster, co-located with WPO-S3 struct stack-escape assign).
 * Members: typeck_find_or_alloc_ptr_stack_local_c /
 * typeck_ptr_has_stack_local_label_c / typeck_block_tree_has_var_c /
 * typeck_var_is_block_local_c / typeck_expr_is_addr_of_block_local_c
 * (definitions at region_assign.c EOF). Glue.c L10223/10227 callsites
 * (inside pipeline_typeck_ptr_for_addr_of_operand_c) precede #include
 * L10231, so 2 static fwd decls below keep them visible.
 * PLATFORM: SHARED. */
static int32_t typeck_var_is_block_local_c(struct ast_Module *m, struct ast_ASTArena *a,
                                           struct ast_PipelineDepCtx *ctx, int32_t expr_ref);
static int32_t typeck_find_or_alloc_ptr_stack_local_c(struct ast_ASTArena *a, int32_t elem_ref);

/* wave1133-1135 G.7: lval param ptr field cluster migrated to
 * pipeline_typeck_region_assign.c EOF (colocated with WPO-S3 stack-escape
 * helpers wave1125-1129; same-TU visibility via #include @ L10059 below).
 * Cluster: typeck_lval_is_param_ptr_field_c / typeck_block_expr_stmts_store_scan_c /
 * typeck_block_final_expr_store_scan_c / typeck_block_stores_param_into_param_field_c /
 * typeck_func_stores_param_into_param_field_c. region_assign.c L141 callsite
 * sees definition via static fwd decl at file top L37. */

/**
 * WPO-S3：&local struct 时返回 stack_local *T，否则 0（调用方回落普通 *T）。
 */
int32_t pipeline_typeck_ptr_for_addr_of_operand_c(struct ast_ASTArena *arena, int32_t op_ref, int32_t elem_ty,
                                                  struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  if (!arena || !module || !ctx || op_ref <= 0 || elem_ty <= 0)
    return 0;
  if (!typeck_var_is_block_local_c(module, arena, ctx, op_ref))
    return 0;
  if (!typeck_type_is_named_struct_c(module, arena, elem_ty))
    return 0;
  return typeck_find_or_alloc_ptr_stack_local_c(arena, elem_ty);
}

/* BC 8.3.1: region/escape assign-site domain (same TU). */
#include "pipeline_typeck_region_assign.c"


/**
 * WPO-S3：CALL 路径 — 局部 struct 指针与另一 *Struct 形参同传时拒绝（callee 可能写入外层槽）。
 * PLATFORM: SHARED — Cap-T001: inside unsafe { } skip (depth>0); safe code still hard-fails T001.
 */
int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t func_ix;
  int32_t num_args;
  int32_t np;
  int32_t src_i;
  int32_t dst_j;
  int32_t line;
  int32_t col;
  if (!module || !arena || !ctx || call_expr_ref <= 0)
    return 0;
  /* Cap-T001: mega parser/typeck/codegen whole-body unsafe may pass &local with *Struct outer. */
  if (pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) > 0)
    return 0;
  func_ix = pipeline_typeck_resolve_call_func_index_c(module, arena, call_expr_ref);
  if (func_ix < 0)
    return 0;
  num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref);
  np = pipeline_module_func_num_params_at(module, func_ix);
  if (num_args != np || num_args < 2)
    return 0;
  if (link_abi_getenv("XLANG_SKIP_STACK_ESCAPE") != NULL)
    return 0;
  for (src_i = 0; src_i < num_args; src_i++) {
    int32_t arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, src_i);
    int32_t arg_ty;
    int32_t arg_elem;
    if (!typeck_expr_is_addr_of_block_local_c(module, arena, ctx, arg_ref))
      continue;
    /** 仅当 &local 的类型是 *Struct 时才触发（&local_i32 不逃逸）。 */
    arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (arg_ty <= 0)
      continue;
    if (pipeline_type_kind_ord_at(arena, arg_ty) != (int32_t)ast_TypeKind_TYPE_PTR)
      continue;
    arg_elem = pipeline_type_elem_ref_at(arena, arg_ty);
    if (arg_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, arg_elem))
      continue;
    for (dst_j = 0; dst_j < num_args; dst_j++) {
      int32_t param_ref;
      int32_t elem_ref;
      int32_t other_arg;
      if (dst_j == src_i)
        continue;
      param_ref = pipeline_module_func_param_type_ref_at(module, func_ix, dst_j);
      if (param_ref <= 0 ||
          pipeline_type_kind_ord_at(arena, param_ref) != (int32_t)ast_TypeKind_TYPE_PTR)
        continue;
      elem_ref = pipeline_type_elem_ref_at(arena, param_ref);
      if (elem_ref <= 0 || !typeck_type_is_named_struct_c(module, arena, elem_ref))
        continue;
      /**
       * 另一实参若也是「本函数块局部」的取址，则两指针同帧栈寿命，不是 outer。
       * 误报例：emit/main 中 pipeline(..., &out, &ctx) 两个本地 struct。
       * 仅当另一 *Struct 来自更长寿命（参数/堆/外层）时才拒。
       */
      other_arg = pipeline_expr_call_arg_ref(arena, call_expr_ref, dst_j);
      if (typeck_expr_is_addr_of_block_local_c(module, arena, ctx, other_arg))
        continue;
      line = pipeline_expr_line_at(arena, call_expr_ref);
      col = pipeline_expr_col_at(arena, call_expr_ref);
      lsp_diag_report_typeck((int)line, (int)col,
                             "struct stack escape: cannot pass address of local struct with outer struct pointer");
      return -1;
    }
  }
  return 0;
}

/* wave1136 G.7: typeck_scan_expr_stack_escape_c migrated to
 * pipeline_typeck_region_assign.c EOF (colocated with WPO-S3 assign/return
 * escape checks). Visible here via #include at L9934. */

/* wave1167 G.7: region scope + scan_module + read_ptr + stamp_let cluster
 * (7 extern fns + 3 statics + TYPECK_REGION_SCOPE_MAX macro) migrated to
 * pipeline_typeck_region_assign.c EOF. Colocated with region_assign domain
 * — all region scope push/pop/len/stamp and module-level stack-escape scan
 * belong with typeck_scan_block_stack_escape_c (wave1137).
 *
 * Statics (g_typeck_region_saved_len / saved_label / scope_n) now in
 * region_assign.c alongside g_typeck_with_arena_scope_n (L307).
 *
 * Forward decls:
 * - pipeline_typeck_scan_module_struct_stack_escape_c: fwd decl at L5610
 *   (before callsites L5645/5656/5703 < region_assign.c #include L8417)
 * - pipeline_dep_ctx_scope_region_push_c / _pop_c / _len_at: fwd decls in
 *   region_assign.c L327-329 (before callsites L409/416/1112/1121/1128)
 * - pipeline_typeck_is_read_ptr_slice_callee_c /
 *   pipeline_typeck_read_ptr_slice_return_ref_c / pipeline_type_stamp_block_let_region_c:
 *   extern, called from seed (typeck_gen.linux.x86_64.c) not from glue.c TU;
 *   no fwd decl needed in glue.c.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1089 G.7: pipeline_module_func_overload_count_c migrated to
 * pipeline_typeck_method_call.c EOF (overload gating sub-domain of method call
 * resolution). Static (non-extern): same-TU — static fwd decl at glue.c:12315
 * (before all callsites L13176+) < method_call.c #include at L14053 < def EOF.
 * Deps: pipeline_asm_module_func_is_extern_at / pipeline_module_func_name_equal_at
 * (both extern). PLATFORM: SHARED. */
static int32_t pipeline_module_func_overload_count_c(struct ast_Module *m, uint8_t *name, int32_t name_len);

/* wave1090-1094 G.7: overload resolution domain (call_arg_assignable + match_score
 * + expect_match + pick_overload + resolve_call_func_index) migrated to
 * pipeline_typeck_method_call.c EOF (overload dispatch sub-domain of method call).
 * Static (non-extern): same-TU — fwd decls below (before all callsites L12695+,
 * L13233+ wrappers, L13360+, L13743+) < method_call.c #include at L14053 < def EOF.
 * resolve_call_func_index_c also has static fwd decl at glue.c:12315 (before
 * callsite L12695). Deps: pipeline_expr_kind_ord_at / pipeline_typeck_expr_type_ref_c
 * / pipeline_expr_as_target_type_ref_at / pipeline_type_kind_ord_at /
 * pipeline_typeck_type_refs_equal_c / pipeline_typeck_integer_widen_ok_refs_c
 * (static, fwd decl at glue.c:10381) / pipeline_typeck_float_widen_ok_c (static,
 * fwd decl at glue.c:10354) / pipeline_type_elem_ref_at / pipeline_expr_int_val_at
 * / pipeline_expr_call_num_args_at / pipeline_module_func_num_params_at /
 * pipeline_expr_call_arg_ref / pipeline_module_func_param_type_ref_at /
 * pipeline_module_func_return_type_at / typeck_overload_expected_ret_peek
 * (extern, declared in-function-body) / pipeline_expr_call_callee_ref_at /
 * pipeline_arena_expr_ptr / pipeline_asm_module_func_is_extern_at /
 * pipeline_module_func_name_equal_at / pipeline_expr_apply_call_resolve /
 * pipeline_expr_call_resolved_func_index_at (all extern unless noted).
 * PLATFORM: SHARED. */
static int32_t pipeline_typeck_call_arg_assignable_c(struct ast_ASTArena *arena, int32_t arg_ref, int32_t param_ref);
static int32_t pipeline_typeck_overload_match_score_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t func_ix,
                                                      int32_t call_expr_ref);
static int32_t pipeline_typeck_overload_expect_match_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                       int32_t func_ix);
static int32_t pipeline_typeck_pick_overload_func_index_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                          int32_t call_expr_ref);

/* wave1170 G.7: overload wrapper cluster (2 extern fns:
 * pipeline_typeck_resolve_call_func_index_for_emit_c /
 * pipeline_typeck_pick_overload_func_index_for_call_c) migrated to
 * pipeline_typeck_method_call.c EOF. Colocated with static overload resolvers
 * (pipeline_typeck_resolve_call_func_index_c / _pick_overload_func_index_c,
 * wave1090-1094, same file).
 * Extern fwd decls at L5081/5083 cover ast_pool.c:11607 callsite.
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/* wave1150 G.7: glue_asm_resolve_call_target_module_c migrated to
 * pipeline_asm_emit_call_args.c EOF (CALL-target module/func_index resolver;
 * colocated with call-arg packing domain — every call-arg emitter calls this
 * resolver to get mod/func_ix/dep_ix before packing args).
 *
 * Visibility: static fwd decl at pipeline_asm_emit_struct_let.c:78 (struct_let.c
 * #include at L2120 < call_args.c #include at L2251) provides TU-wide visibility
 * for callers in call_args.c body that precede the EOF definition.
 *
 * GLUE_TYPECK_IMPORT_BINDING/SELECT enum moved before call_args.c #include at
 * L2241 so the migrated function can see the enum constants.
 *
 * Deps (fwd decls added at call_args.c EOF before the definition):
 *   - g_pipeline_asm_emit_module / g_pipeline_asm_emit_dep_pipe (same-TU globals)
 *   - pipeline_typeck_resolve_call_func_index_c (static; method_call.c #include
 *     at L10491 > call_args.c #include at L2251; static fwd decl in call_args.c)
 *   - pipeline_typeck_find_func_return_type_in_module_c (extern; def at L8926 >
 *     L2251; extern fwd decl in call_args.c)
 *   - parser_get_module_num_imports (extern; extern fwd decl in call_args.c)
 *   - pipeline_expr_* / pipeline_dep_ctx_* / pipeline_module_import_* (extern)
 * PLATFORM: SHARED. */

/* wave1060 G.7: pipeline_asm_deref_struct16_rax_ptr_elf_c migrated to
 * pipeline_asm_emit_call_args.c EOF (struct16 retval deref domain).
 * Extern prototype at L1493 < call_args.c #include L2395 visible.
 * struct_let.c:75 #define alias retained (glue_ name -> pipeline_asm_).
 * Dependencies: backend_enc_*_arch (global extern). */

/* wave1061 G.7: pipeline_asm_call_struct16_ret_needs_rax_deref_c migrated to
 * pipeline_asm_emit_call_args.c EOF (struct16 retval deref classifier domain,
 * twin of wave1060 deref action). Extern prototype at L791 < call_args.c
 * #include L2395 visible to all callsites. struct_let.c:77 #define alias
 * retained (glue_ name -> pipeline_asm_). Dependencies: glue_asm_resolve_
 * call_target_module_c (static fwd decl struct_let.c:78, def still in this
 * file at L13555); pipeline_module_func_* / pipeline_typeck_* / glue_type_*
 * (same-TU / extern). */

/* wave1063 G.7: pipeline_asm_call_param_type_ref_at_c migrated to
 * pipeline_asm_emit_call_args.c EOF (call param type_ref resolve domain,
 * twin of wave1062 call_return_type_kind_ord). Extern (non-static): seed
 * extern C link (backend_call_dispatch.x:19 / backend_call_dispatch_thin.x:104);
 * struct_let.c:98 comment references it (via #include L2269 < call_args.c
 * L2395). Dependencies: glue_asm_resolve_call_target_module_c (static fwd
 * decl struct_let.c:78, def still at L13555); pipeline_module_func_param_
 * type_ref_at (extern L261); pipeline_typeck_get_dep_return_type_in_caller_
 * arena_c (extern L788); pipeline_dep_ctx_arena_at (extern decl wave1062 in
 * call_args.c); pipeline_dep_ctx_ndep / pipeline_dep_ctx_module_at /
 * pipeline_get_dep_arena_slot / pipeline_typeck_dep_return_type_to_caller_
 * arena_c (extern decls wave1063 in call_args.c; defs at L11661/11663/
 * 11664/11846 > #include L2395); g_pipeline_asm_emit_module /
 * g_pipeline_asm_emit_dep_pipe (globals). */

/* wave1062 G.7: pipeline_asm_call_return_type_kind_ord_c migrated to
 * pipeline_asm_emit_call_args.c EOF (call return TypeKind resolve domain,
 * twin of wave1061 struct16 deref classifier). Extern prototype at
 * struct_let.c:99 (via #include L2269 < call_args.c L2395) visible to all
 * callsites. Dependencies: glue_asm_resolve_call_target_module_c (static
 * fwd decl struct_let.c:78, def still at L13555);
 * pipeline_dep_ctx_arena_at extern decl added in call_args.c (def at
 * L11662 > #include L2395); rest < L2395 / extern / global. */

/* wave1114 G.7: typeck_layout_index_for_named_type_c migrated to
 * pipeline_asm_emit_struct_lit.c EOF (struct layout registry index lookup,
 * co-located with typeck_type_is_named_struct_c wave1113). Static
 * (non-extern): same-TU — struct_lit.c #include at L2051 < callsites
 * (L11213+). PLATFORM: SHARED. */

/* wave1124 G.7: typeck_struct_layouts_same_shape_c migrated to
 * pipeline_asm_emit_struct_lit.c EOF (MOD-02 same-shape comparator for
 * repr(compatible) ptr coerce; co-located with struct layout registry).
 * Static (non-extern): same-TU — struct_lit.c #include at L2051 < callsite
 * (inside pipeline_typeck_call_arg_repr_compatible_ok_c). PLATFORM: SHARED. */

/**
 * wave703 / MOD-02: 1 if *StructA vs *StructB (or &StructB) may coerce under
 * #[repr(compatible)] + same field shape. 0 if not applicable or not ok.
 * G.7 single authority for positive coerce; typeck_check_call_arg_types and
 * overload score gate through this (not a second layout walker).
 * PLATFORM: SHARED.
 */
int32_t pipeline_typeck_call_arg_repr_compatible_ok_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t param_ref, int32_t arg_ref) {
  int32_t param_elem;
  int32_t arg_elem;
  int32_t arg_ty;
  int32_t arg_kind;
  int32_t la;
  int32_t lb;
  if (!module || !arena || param_ref <= 0 || arg_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, param_ref) != (int32_t)ast_TypeKind_TYPE_PTR)
    return 0;
  param_elem = pipeline_type_elem_ref_at(arena, param_ref);
  if (param_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, param_elem))
    return 0;
  arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
  arg_kind = pipeline_expr_kind_ord_at(arena, arg_ref);
  if (arg_ty <= 0 && arg_kind == (int32_t)ast_ExprKind_EXPR_ADDR_OF) {
    int32_t op = pipeline_expr_unary_operand_ref_at(arena, arg_ref);
    if (op > 0)
      arg_ty = pipeline_expr_resolved_type_ref(arena, op);
  }
  if (arg_ty <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_NAMED) {
    arg_elem = arg_ty;
  } else if (pipeline_type_kind_ord_at(arena, arg_ty) == (int32_t)ast_TypeKind_TYPE_PTR) {
    arg_elem = pipeline_type_elem_ref_at(arena, arg_ty);
  } else {
    return 0;
  }
  if (arg_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, arg_elem))
    return 0;
  param_elem = pipeline_typeck_resolve_type_alias_ref_c(arena, param_elem);
  arg_elem = pipeline_typeck_resolve_type_alias_ref_c(arena, arg_elem);
  if (param_elem == arg_elem)
    return 1;
  la = typeck_layout_index_for_named_type_c(module, arena, param_elem);
  lb = typeck_layout_index_for_named_type_c(module, arena, arg_elem);
  if (la < 0 || lb < 0)
    return 0;
  if (la == lb)
    return 1;
  if (typeck_struct_layouts_same_shape_c(module, arena, la, lb) &&
      pipeline_module_struct_layout_repr_compatible_at(module, la) &&
      pipeline_module_struct_layout_repr_compatible_at(module, lb))
    return 1;
  return 0;
}

/* wave1145 G.7: typeck_check_call_ptr_struct_compat_c migrated to
 * pipeline_typeck_method_call.c EOF (colocated with overload resolution /
 * call dispatch domain wave1089-1094 + import binding resolution wave1085-1088).
 * Static same-TU: fwd decl below (BEFORE sole callsite L10313 in
 * pipeline_typeck_check_call_slice_region_c) < method_call.c #include at
 * L10585 < def EOF. Deps: pipeline_type_kind_ord_at / pipeline_type_elem_ref_at /
 * typeck_type_is_named_struct_c (struct_lit.c L2051) /
 * pipeline_expr_resolved_type_ref / pipeline_expr_kind_ord_at /
 * pipeline_expr_unary_operand_ref_at / pipeline_typeck_call_arg_repr_compatible_ok_c
 * (glue.c L10151) / pipeline_expr_line_at / pipeline_expr_col_at /
 * lsp_diag_report_typeck. PLATFORM: SHARED. */
static int32_t typeck_check_call_ptr_struct_compat_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                     int32_t call_expr_ref, int32_t param_ref, int32_t arg_ref);

/**
 * M-3：.x typeck CALL 实参 slice 域检查；解析 callee 后逐实参对照形参域标签。
 */
/** LANG-007：S0 extern 边界（定义见后文；call_slice_region 旧路径也挂此检查）。 */
int32_t pipeline_typeck_check_extern_call_unsafe_boundary_c(struct ast_Module *module,
                                                            struct ast_ASTArena *arena, int32_t expr_ref,
                                                            struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_check_call_slice_region_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t func_ix;
  int32_t dep_ix;
  int32_t num_args;
  int32_t np;
  int32_t i;
  int32_t arg_ref;
  int32_t param_ref;
  int32_t arg_ty;
  struct ast_Module *callee_mod;
  if (!module || !arena || call_expr_ref <= 0)
    return 0;
  /**
   * LANG-007 belt：旧 typeck_gen 的 typeck_check_expr_call 内联路径不经
   * pipeline_typeck_check_expr_call_c，但仍调用本函数做 slice region；在此再挂 S0 extern 边界。
   * （新路径已在 pipeline_typeck_check_expr_call_c 内检查；重复检查幂等。）
   */
  if (pipeline_typeck_check_extern_call_unsafe_boundary_c(module, arena, call_expr_ref, ctx) != 0)
    return -1;
  func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
  dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
  if (func_ix < 0)
    func_ix = pipeline_typeck_resolve_call_func_index_c(module, arena, call_expr_ref);
  if (func_ix < 0)
    return 0;
  callee_mod = module;
  if (dep_ix >= 0 && ctx) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, dep_ix);
    if (dm)
      callee_mod = dm;
  }
  num_args = pipeline_expr_call_num_args_at(arena, call_expr_ref);
  np = pipeline_module_func_num_params_at(callee_mod, func_ix);
  if (num_args != np)
    return 0;
  for (i = 0; i < num_args; i++) {
    int32_t arg_kind;
    int32_t param_kind;
    arg_ref = pipeline_expr_call_arg_ref(arena, call_expr_ref, i);
    param_ref = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, i);
    /*
     * wave332 Cap residual pure: call-arg ARRAY_LIT → TYPE_SLICE / TYPE_ARRAY param.
     * Root: args are check_expr'd *before* resolve, so no param type is available then;
     * bare `[1,2,3]` never stamps → host emit falls to `(uint8_t[]){…}` while the formal
     * is `struct xlang_slice_* *` (run garbage / Ubuntu freestanding wrong).
     * Authority (G.7): reuse pipeline_typeck_coerce_init_array_vector_lit_to_decl_c
     * (let-init wave328 / assign wave331). After stamp, host emit_call_arg_slice_abi
     * emits `&(struct xlang_slice_T){ .data=(E[]){…}, .length=N }`.
     * PLATFORM: SHARED typeck — runs on product path (check_call_slice_region is the
     * post-resolve single authority for both typeck.x and glue call).
     */
    if (arg_ref > 0 && param_ref > 0) {
      arg_kind = pipeline_expr_kind_ord_at(arena, arg_ref);
      param_kind = pipeline_type_kind_ord_at(arena, param_ref);
      (void)pipeline_typeck_coerce_init_array_vector_lit_to_decl_c(arena, arg_ref, param_ref,
                                                                   param_kind, arg_kind);
    }
    arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
    if (pipeline_typeck_check_slice_region_assign_c(arena, arg_ref, param_ref, arg_ty) != 0)
      return -1;
    if (typeck_check_call_ptr_struct_compat_c(module, arena, call_expr_ref, param_ref, arg_ref) != 0)
      return -1;
  }
  /**
   * WPO-S3：&local struct 与 *Struct 形参同传 → 拒（外层槽逃逸）。
   * PLATFORM: SHARED — Cap-T001: skip when already inside unsafe { } (same gate as call_struct_stack_escape).
   * G.7 note: body mirrors pipeline_typeck_check_call_struct_stack_escape_c for dep-resolved callee_mod.
   */
  if (ctx && num_args >= 2 && link_abi_getenv("XLANG_SKIP_STACK_ESCAPE") == NULL &&
      pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) <= 0) {
    int32_t src_i;
    int32_t dst_j;
    for (src_i = 0; src_i < num_args; src_i++) {
      int32_t stack_arg = pipeline_expr_call_arg_ref(arena, call_expr_ref, src_i);
      int32_t stack_arg_ty;
      int32_t stack_arg_elem;
      if (!typeck_expr_is_addr_of_block_local_c(module, arena, ctx, stack_arg))
        continue;
      /** 仅当 &local 的类型是 *Struct 时才触发（&local_i32 不逃逸）。 */
      stack_arg_ty = pipeline_expr_resolved_type_ref(arena, stack_arg);
      if (stack_arg_ty <= 0)
        continue;
      if (pipeline_type_kind_ord_at(arena, stack_arg_ty) != (int32_t)ast_TypeKind_TYPE_PTR)
        continue;
      stack_arg_elem = pipeline_type_elem_ref_at(arena, stack_arg_ty);
      if (stack_arg_elem <= 0 || !typeck_type_is_named_struct_c(module, arena, stack_arg_elem))
        continue;
      for (dst_j = 0; dst_j < num_args; dst_j++) {
        int32_t param_ref2;
        int32_t elem_ref;
        int32_t line;
        int32_t col;
        int32_t other_arg;
        if (dst_j == src_i)
          continue;
        param_ref2 = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, dst_j);
        if (param_ref2 <= 0 ||
            pipeline_type_kind_ord_at(arena, param_ref2) != (int32_t)ast_TypeKind_TYPE_PTR)
          continue;
        elem_ref = pipeline_type_elem_ref_at(arena, param_ref2);
        if (elem_ref <= 0 || !typeck_type_is_named_struct_c(module, arena, elem_ref))
          continue;
        /* 同帧 &local 兄弟实参：非 outer（与 pipeline_typeck_check_call_struct_stack_escape_c 一致） */
        other_arg = pipeline_expr_call_arg_ref(arena, call_expr_ref, dst_j);
        if (typeck_expr_is_addr_of_block_local_c(module, arena, ctx, other_arg))
          continue;
        line = pipeline_expr_line_at(arena, call_expr_ref);
        col = pipeline_expr_col_at(arena, call_expr_ref);
        lsp_diag_report_typeck((int)line, (int)col,
                               "struct stack escape: cannot pass address of local struct with outer struct pointer");
        return -1;
      }
    }
  }
  return 0;
}

/**
 * M-3 / MEM-C1：typeck 单条 region 或 with_arena 块。
 * with_arena 无域标签，旧实现 label_len<=0 直接 return 0 会跳过体块 typeck，导致 AL-04 assign 逃逸漏报。
 */
int32_t pipeline_typeck_unsafe_depth_push_c(struct ast_PipelineDepCtx *ctx);
void pipeline_typeck_unsafe_depth_pop_c(struct ast_PipelineDepCtx *ctx, int32_t saved_unsafe_depth);

int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t block_ref, int32_t region_idx, int32_t return_type_ref,
                                                 struct ast_PipelineDepCtx *ctx) {
  uint8_t label[128];
  int32_t label_len;
  int32_t body_ref;
  int32_t wa_cap;
  int32_t rc;
  extern int32_t typeck_check_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                    int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
  if (!module || !arena || !ctx || block_ref <= 0 || region_idx < 0)
    return 0;
  body_ref = pipeline_block_region_body_ref(arena, block_ref, region_idx);
  if (body_ref <= 0)
    return 0;
  if (pipeline_block_region_is_unsafe(arena, block_ref, region_idx)) {
    int32_t saved_ud;
    saved_ud = pipeline_typeck_unsafe_depth_push_c(ctx);
    rc = typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
    pipeline_typeck_unsafe_depth_pop_c(ctx, saved_ud);
    return rc;
  }
  wa_cap = pipeline_block_region_with_arena_cap_ref(arena, block_ref, region_idx);
  if (wa_cap > 0) {
    /** MEM-C1：push with_arena 栈，使 check_expr_impl_mega / post-scan 能报 allocator region escape。 */
    typeck_with_arena_scope_push_c(body_ref);
    rc = typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
    typeck_with_arena_scope_pop_c();
    return rc;
  }
  label_len = pipeline_block_region_label_len(arena, block_ref, region_idx);
  if (label_len <= 0)
    return 0;
  pipeline_block_region_label_copy64(arena, block_ref, region_idx, label);
  if (pipeline_dep_ctx_scope_region_push_c(ctx, label, label_len) != 0)
    return -1;
  rc = typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
  pipeline_dep_ctx_scope_region_pop_c(ctx);
  return rc;
}

/* typeck coerce-init domain (lit/float/enum/call/array/vector/struct/slice):
 * pipeline_typeck_coerce_init.c */
#include "pipeline_typeck_coerce_init.c"

/** 前向声明：check_expr_impl C 委托内递归 check 子表达式。 */
int32_t pipeline_typeck_check_expr_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                     int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_check_block_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/* wave1065 G.7: pipeline_typeck_expr_is_any_assign_kind_c migrated to
 * pipeline_typeck_coerce_init.c EOF (assign-kind classifier, consumed by
 * check_block_one_region). Static same-TU: coerce_init.c #include L14126 <
 * def L14135 < sole callsite L15308. Deps: ast_ExprKind_* enum (global). */

/** typeck.o / typeck_x_no_layout 子 helper；kind 分派经 pipeline_typeck_check_expr_impl_mega_c 调用。 */
extern int32_t typeck_check_expr_try_propagate(struct ast_Module *module, struct ast_ASTArena *arena,
                                               int32_t expr_ref, int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/* wave1147 G.7: debug_try_propagate_report_glue_c migrated to
 * pipeline_typeck_method_call.c EOF (debug-point D try-propagate
 * reporter; colocated with call dispatch / overload resolution domain).
 * Static fwd decl below — sole caller pipeline_typeck_check_expr_
 * try_propagate_c at L10419 is BEFORE method_call.c #include at L10525;
 * definition at method_call.c EOF (after #include). Deps: link_abi_getenv
 * / link_abi_system (extern) + libc fopen/fgets/fclose/snprintf/strncmp/
 * strcspn. PLATFORM: SHARED. */
// #region debug-point D:try-propagate-strong-state
/* wave1190 G.7: debug_try_propagate_report_glue_c static fwd decl removed —
 * sole caller pipeline_typeck_check_expr_try_propagate_c migrated to
 * pipeline_typeck_check_expr.c EOF (after method_call.c #include, so the
 * definition in method_call.c EOF wave1147 is directly visible).
 * PLATFORM: SHARED. */
// #endregion

/* wave1190 G.7: pipeline_typeck_check_expr_try_propagate_c +
 * typeck_check_expr_try_propagate wrapper migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with wave1188 entry/dispatch
 * domain + wave1189 sub-class cluster). debug_try_propagate_report_glue_c
 * (static, wave1147 in method_call.c EOF) visible at check_expr.c #include
 * point (after method_call.c #include). PLATFORM: SHARED. */

/**
 * ERR-01 C codegen：GNU 语句表达式 desugar `expr?` → err 早退 + unwrap value（烟测 C 路径 codegen_x_ast）。
 */
int32_t pipeline_codegen_emit_expr_try_propagate_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                   int32_t expr_ref, struct ast_PipelineDepCtx *ctx) {
  extern int32_t codegen_emit_expr(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                   struct ast_PipelineDepCtx *ctx);
  extern int32_t codegen_emit_bytes_from_ptr(struct codegen_CodegenOutBuf *out, uint8_t *p, int32_t n);
  int32_t op;
  static const uint8_t pre[] = "({ struct core_result_Result_i32 __xlang_q = ";
  static const uint8_t suf[] = "; if (__xlang_q.err != 0) return __xlang_q; __xlang_q.value; })";

  (void)ctx;
  if (!arena || !out || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op <= 0)
    return -1;
  if (codegen_emit_bytes_from_ptr(out, (uint8_t *)pre, (int32_t)(sizeof(pre) - 1)) != 0)
    return -1;
  if (codegen_emit_expr(arena, out, op, ctx) != 0)
    return -1;
  return codegen_emit_bytes_from_ptr(out, (uint8_t *)suf, (int32_t)(sizeof(suf) - 1));
}

/* typeck method_call + generic UFCS mono domain (BC 8.3.1):
 * pipeline_typeck_method_call.c */
#include "pipeline_typeck_method_call.c"

/* wave1096 G.7: glue_generic_call_fixup_resolved_type_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsites L14181 + L14757.
 * PLATFORM: SHARED. */

/* wave1148 G.7: pipeline_typeck_bootstrap_expr_fixup_c migrated to
 * pipeline_typeck_method_call.c EOF (bootstrap typeck post-processing
 * expr fixup; colocated with glue_generic_call_fixup_resolved_type_c
 * wave1096 + call dispatch / overload resolution domain). Static fwd
 * decl at L8131 (before sole caller pipeline_typeck_check_expr_return_c
 * at L8191, before method_call.c #include at L10499). Deps:
 * pipeline_expr_kind_ord_at / pipeline_expr_resolved_type_ref /
 * pipeline_expr_method_call_* / pipeline_expr_set_resolved_type_ref /
 * pipeline_type_kind_ord_at / pipeline_type_ensure_by_kind_ord (all extern)
 * + glue_generic_call_fixup_resolved_type_c (static, same file). PLATFORM: SHARED. */

/**
 * EXPR_CALL：委托 typeck_x.o 后做泛型返回类型单态化 fixup（bootstrap parser 未存 call type_args）。
 * LANG-007 v2：S0 内 extern 调用须位于 unsafe { } 块内。
 */
extern void driver_diagnostic_typeck_extern_call_outside_unsafe(int32_t line, int32_t col);
extern void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col, const uint8_t *name, int32_t name_len);
extern void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col, const uint8_t *name,
                                                              int32_t name_len, int32_t expect_n, int32_t got_n);
extern void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col, const uint8_t *name,
                                                             int32_t name_len);
extern int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t func_index);
extern int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena *a, int32_t expr_ref);

static int32_t glue_module_func_index_by_name_c(struct ast_Module *mod, uint8_t *name, int32_t name_len);

/**
 * LANG-007 v2：S0 内 extern 调用须在 unsafe { } 内。
 * 非 static：typeck.x 的 typeck_check_expr_call 须直接调用（勿仅靠 glue 包装路径）。
 */
int32_t pipeline_typeck_check_extern_call_unsafe_boundary_c(struct ast_Module *module,
                                                            struct ast_ASTArena *arena, int32_t expr_ref,
                                                            struct ast_PipelineDepCtx *ctx) {
  int32_t callee_ref;
  int32_t callee_kind;
  int32_t name_len;
  uint8_t name[128];
  int32_t fi;
  int32_t line;
  int32_t col;
  /* -E seed regen / allow_legacy: typeck_x.o 提供 getter；缺省弱 0 保持 S0 强制。 */
  extern int typeck_get_allow_legacy_extern_calls(void);

  if (typeck_get_allow_legacy_extern_calls() != 0)
    return 0;
  if (pipeline_dep_ctx_typeck_unsafe_depth_at(ctx) > 0)
    return 0;
  if (!module || !arena || expr_ref <= 0 || expr_ref > arena->num_exprs)
    return 0;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
  if (callee_ref <= 0 || callee_ref > arena->num_exprs)
    return 0;
  callee_kind = pipeline_expr_kind_ord_at(arena, callee_ref);
  if (callee_kind != (int32_t)ast_ExprKind_EXPR_VAR)
    return 0;
  name_len = pipeline_expr_var_name_len(arena, callee_ref);
  if (name_len <= 0 || name_len > 127)
    return 0;
  pipeline_expr_var_name_into(arena, callee_ref, name);
  fi = glue_module_func_index_by_name_c(module, name, name_len);
  if (fi < 0 || pipeline_module_func_is_extern_at(module, fi) == 0)
    return 0;
  line = pipeline_expr_line_at(arena, expr_ref);
  col = pipeline_expr_col_at(arena, expr_ref);
  driver_diagnostic_typeck_extern_call_outside_unsafe(line, col);
  return -1;
}

/* wave1095 G.7: pipeline_typeck_named_is_module_type_c migrated to
 * pipeline_typeck_method_call.c EOF. Static fwd decl at method_call.c:348
 * (before callsites L476-L872) < method_call.c #include at L13803 < def EOF.
 * PLATFORM: SHARED. */

/* wave1097 G.7: pipeline_typeck_try_infer_generic_call_from_args_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsite inside
 * check_call_generic_type_args_c (same migration batch). PLATFORM: SHARED. */

/* wave1098 G.7: pipeline_typeck_check_inferred_generic_bounds_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsite inside
 * check_call_generic_type_args_c (same migration batch). PLATFORM: SHARED. */

/* wave1099 G.7: pipeline_typeck_check_call_generic_type_args_c migrated to
 * pipeline_typeck_method_call.c EOF. Static (non-extern): same-TU —
 * method_call.c #include at L13803 < def EOF < callsite L14743
 * (inside pipeline_typeck_check_expr_call_c). PLATFORM: SHARED. */

/* wave1190 G.7: pipeline_typeck_check_expr_call_c migrated to
 * pipeline_typeck_check_expr.c EOF (colocated with wave1188 entry/dispatch
 * domain + wave1189 sub-class cluster + try_propagate_c). Static helpers
 * glue_generic_call_fixup_resolved_type_c (wave1096) +
 * pipeline_typeck_check_call_generic_type_args_c (wave1099) visible at
 * check_expr.c #include point (method_call.c #include before check_expr.c).
 * pipeline_typeck_check_extern_call_unsafe_boundary_c (extern, defined above
 * at L6010) visible via fwd decl. typeck_check_expr_call wrapper below stays
 * (calls call_c via fwd decl at L4777). PLATFORM: SHARED. */

/** 非 standalone TU 保留旧 glue wrapper；strict_glue 改由 typeck_x.o 作为唯一导出方。 */
#if !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU) && !defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS)
int32_t typeck_check_expr_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                               int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_call_c(module, arena, expr_ref, return_type_ref, ctx);
}

int32_t typeck_check_expr_deref(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_deref_c(module, arena, expr_ref, return_type_ref, ctx);
}

int32_t typeck_check_expr_method_call(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                      int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
}
#endif

/* wave1188 G.7: typeck check_expr entry/dispatch cluster (5 fns + 2 XLANG_WEAK)
 * migrated to pipeline_typeck_check_expr.c (same-TU #include). Members:
 * pipeline_typeck_check_expr_impl_mega_c (full ExprKind dispatch)
 * + XLANG_WEAK check_expr_impl_mega (glue-only fallback; typeck_x.o overrides)
 * + pipeline_typeck_check_expr_impl_c (simple kind C path + mega fallback)
 * + XLANG_WEAK check_expr_impl (glue-only fallback; typeck.o EMIT_HEAVY overrides)
 * + pipeline_typeck_check_expr_c (boundary check → try_propagate / impl_c)
 * All extern (non-static): cross-TU calls (typeck_x.o / typeck.o / seeds).
 * XLANG_WEAK definitions retained for product pure strong-symbol override.
 * Sub-class helpers (panic/match/return/unary/addr_of/deref/index/var) remain
 * in pipeline_glue.c (interleaved with assign/soa/field_access domain slices).
 * call_c + try_propagate_c remain in pipeline_glue.c (before method_call.c
 * #include for debug_try_propagate_report_glue_c + glue_module_func_index_by_name_c).
 * PLATFORM: SHARED. */
#include "pipeline_typeck_check_expr.c"

/* typeck check_block orchestration domain (BC 8.3.1):
 * pipeline_typeck_check_block.c */
#include "pipeline_typeck_check_block.c"

extern int32_t check_block(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                           int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/* wave1187 G.7: typeck orchestration cluster (10 fns + 2 statics + 3 XLANG_WEAK)
 * migrated to pipeline_typeck_orch.c (same-TU #include). Members:
 * pipeline_typeck_x_ast_check_one_func_c / pipeline_typeck_x_ast_impl_c /
 * pipeline_typeck_x_ast_library_c / pipeline_typeck_x_ast_c
 * + g_pipeline_typeck_diag_soft_suppress static + diag_soft_suppress_set/get (XLANG_WEAK)
 * + g_pipeline_typeck_dep_ctx_cold static + set_dep_ctx/get_dep_ctx (XLANG_WEAK)
 * + pipeline_typeck_dep_prerun_module_c (XLANG_WEAK)
 * + typeck_validate_struct_layouts_zero_padding_glue
 * + typeck_x_type_size_from_layout_glue / typeck_x_type_align_from_layout_glue
 * Also: codegen_/backend_pipeline_expr_struct_lit_field_offset_at/_store_sz (4 fns)
 *   migrated to pipeline_asm_emit_expr_rec.c EOF (same-TU #include at L1914).
 * All extern (non-static): cross-TU calls (driver.x / lsp.x / runtime_pipeline_abi.x / seeds).
 * XLANG_WEAK definitions retained for product pure strong-symbol override.
 * PLATFORM: SHARED. */
#include "pipeline_typeck_orch.c"

/* wave1183 G.7: ast_ast_block_* control flow + ast_ast_expr_* apply cluster
 * (11 fns) migrated to ast_pool_block.c EOF (same-TU #include already exists).
 * Members: while/for/if cond/body/init/step/then/else ref + resolve_var_to_type_ref
 * + disallows_implicit_tail + apply_call_resolve.
 * All pure forwarders to pipeline_block_ / pipeline_expr_ / implicit_tail_ impls. */

/* wave1183 G.7: ast_pipeline_arena_* forwarder cluster (12 fns) migrated
 * to ast_pool_arena.c EOF (same-TU #include already exists).
 * Members: type/expr/block/func get_copy/set_copy + expr_write_var/binop.
 * All pure forwarders to pipeline_arena_* impls in ast_pool_arena.c. */

/* wave1183 G.7: ast_pipeline_expr_* + codegen_pipeline_expr_* +
 * backend_pipeline_expr_* forwarder cluster (40 fns) migrated to
 * pipeline_asm_emit_expr_rec.c EOF (same-TU #include already exists).
 * Members: call/method_call/match/struct_lit/array_lit/float/if/block/
 * match/const_folded/index/field_access accessors + codegen_/backend_ twins.
 * All pure forwarders to pipeline_expr_ / pipeline_module_ impls. */
/* wave1187 G.7: codegen_/backend_pipeline_expr_struct_lit_field_offset_at /
 * _field_store_sz (4 fns) migrated to pipeline_asm_emit_expr_rec.c EOF. */

/* wave1053 G.7: typeck_typeck_struct_layout_metrics migrated to
 * pipeline_asm_emit_struct_lit.c (definition at EOF). Public symbol —
 * extern-called by ast_pool.c:8151 (same pipeline_x.o symbol, no link
 * change). glue.c:16551/16564/16576 callsites (typeck_validate_* wrappers)
 * see the definition via same-TU #include at glue.c:2095. */
/* wave1187 G.7: typeck_validate_struct_layouts_zero_padding_glue +
 * typeck_x_type_size_from_layout_glue + typeck_x_type_align_from_layout_glue
 * (3 fns) migrated to pipeline_typeck_orch.c (same-TU #include above). */
