/**
 * simd_loop.c — SIMD-S3：固定长度数组 index-add 循环剥离（无 cross-iteration carry）。
 *
 * 匹配：
 *   while i < N { dst[i] = a[i] (+|-|*) b[i]; i = i + 1 / i += 1; }
 * N 为编译期常量或同块 `let n: i32 = K` 绑定；可变 n 走条带主循环 + 标量 epilogue。
 */
#include "simd_loop.h"
#include "simd_enc.h"
#include "target_cpu.h"

#include <stdlib.h>
#include <stdint.h>
#include <string.h>

extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *arena, int32_t expr_ref, uint8_t *dst);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, struct ast_ASTArena *arena, uint8_t *name,
                                                 int32_t name_len);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t pipeline_asm_emit_next_label_c(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name, int32_t name_len,
                                      int32_t is_global, int32_t ta);
extern int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_jge_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *label, int32_t label_len,
                                    int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t offset,
                                                int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off,
                                                 int32_t ta);
extern int32_t pipeline_asm_emit_assign_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);

#define GLUE_EXPR_VAR 3
#define GLUE_EXPR_ADD 4
#define GLUE_EXPR_SUB 5
#define GLUE_EXPR_MUL 6
#define GLUE_EXPR_LT 16
#define GLUE_EXPR_ASSIGN 28
#define GLUE_EXPR_ADD_ASSIGN 29
#define GLUE_EXPR_INDEX 47
#define GLUE_TYPE_ARRAY 10
#define GLUE_TYPE_I32 0

/** 两 EXPR_VAR 是否同名。 */
static int32_t glue_expr_same_var_c(struct ast_ASTArena *arena, int32_t a_ref, int32_t b_ref) {
    uint8_t an[64];
    uint8_t bn[64];
    int32_t alen;
    int32_t blen;
    int32_t k;
    if (pipeline_expr_kind_ord_at(arena, a_ref) != GLUE_EXPR_VAR ||
        pipeline_expr_kind_ord_at(arena, b_ref) != GLUE_EXPR_VAR)
        return 0;
    alen = pipeline_expr_var_name_len(arena, a_ref);
    blen = pipeline_expr_var_name_len(arena, b_ref);
    if (alen <= 0 || alen != blen || alen > 63)
        return 0;
    pipeline_expr_var_name_into(arena, a_ref, an);
    pipeline_expr_var_name_into(arena, b_ref, bn);
    for (k = 0; k < alen; k++) {
        if (an[k] != bn[k])
            return 0;
    }
    return 1;
}

/** INDEX 的下标是否为归纳变量 i。 */
static int32_t glue_index_uses_var_c(struct ast_ASTArena *arena, int32_t index_expr_ref, int32_t i_var_ref) {
    int32_t idx_ref;
    if (pipeline_expr_kind_ord_at(arena, index_expr_ref) != GLUE_EXPR_INDEX)
        return 0;
    idx_ref = pipeline_expr_index_index_ref(arena, index_expr_ref);
    return glue_expr_same_var_c(arena, idx_ref, i_var_ref);
}

/** VAR 的 [N]i32 定长数组元素个数；失败 0。 */
static int32_t glue_var_array_i32_size_c(struct ast_ASTArena *arena, int32_t var_ref) {
    int32_t tr;
    int32_t elem;
    int32_t asz;
    if (pipeline_expr_kind_ord_at(arena, var_ref) != GLUE_EXPR_VAR)
        return 0;
    tr = pipeline_expr_resolved_type_ref(arena, var_ref);
    if (tr <= 0)
        return 0;
    if (pipeline_type_kind_ord_at(arena, tr) != GLUE_TYPE_ARRAY)
        return 0;
    asz = pipeline_type_array_size_at(arena, tr);
    if (asz <= 0 || asz > 256)
        return 0;
    elem = pipeline_type_elem_ref_at(arena, tr);
    if (elem <= 0)
        return 0;
    if (pipeline_type_kind_ord_at(arena, elem) != GLUE_TYPE_I32)
        return 0;
    return asz;
}

/** 同块 let 初值为整型字面量（`let n: i32 = K` 常量传播）。 */
static int32_t glue_block_let_init_lit_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t var_ref,
                                         int32_t *out_lit) {
    uint8_t vbuf[64];
    int32_t vlen;
    int32_t nlet;
    int32_t li;
    if (!out_lit || var_ref <= 0)
        return 0;
    if (pipeline_expr_kind_ord_at(arena, var_ref) != GLUE_EXPR_VAR)
        return 0;
    vlen = pipeline_expr_var_name_len(arena, var_ref);
    if (vlen <= 0 || vlen > 63)
        return 0;
    pipeline_expr_var_name_into(arena, var_ref, vbuf);
    nlet = ast_ast_block_num_lets(arena, block_ref);
    for (li = 0; li < nlet; li++) {
        uint8_t lb[64];
        int32_t llen;
        int32_t init_ref;
        int32_t k;
        int32_t match;
        llen = pipeline_block_let_name_len(arena, block_ref, li);
        if (llen != vlen)
            continue;
        pipeline_block_let_name_copy64(arena, block_ref, li, lb);
        match = 1;
        for (k = 0; k < vlen; k++) {
            if (lb[k] != vbuf[k])
                match = 0;
        }
        if (!match)
            continue;
        init_ref = pipeline_block_let_init_ref(arena, block_ref, li);
        if (init_ref <= 0 || pipeline_expr_kind_ord_at(arena, init_ref) != 0)
            return 0;
        *out_lit = pipeline_expr_int_val_at(arena, init_ref);
        return 1;
    }
    return 0;
}

/** VAR 是否为 [N]i32 栈数组（resolved 类型）。 */
static int32_t glue_var_is_array_i32_n_c(struct ast_ASTArena *arena, int32_t var_ref, int32_t n) {
    return glue_var_array_i32_size_c(arena, var_ref) == n ? 1 : 0;
}

/** 解析 `i = i + 1` 或 `i += 1` 步进语句。 */
static int32_t glue_parse_i_plus_one_step_c(struct ast_ASTArena *arena, int32_t step_ref, int32_t i_var_ref) {
    int32_t left_ref;
    int32_t right_ref;
    int32_t add_l;
    int32_t add_r;
    int32_t ko;
    ko = pipeline_expr_kind_ord_at(arena, step_ref);
    if (ko == GLUE_EXPR_ADD_ASSIGN) {
        left_ref = pipeline_expr_binop_left_ref_at(arena, step_ref);
        right_ref = pipeline_expr_binop_right_ref_at(arena, step_ref);
        if (!glue_expr_same_var_c(arena, left_ref, i_var_ref))
            return 0;
        if (pipeline_expr_kind_ord_at(arena, right_ref) != 0)
            return 0;
        return pipeline_expr_int_val_at(arena, right_ref) == 1 ? 1 : 0;
    }
    if (ko != GLUE_EXPR_ASSIGN)
        return 0;
    left_ref = pipeline_expr_binop_left_ref_at(arena, step_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, step_ref);
    if (!glue_expr_same_var_c(arena, left_ref, i_var_ref))
        return 0;
    if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_ADD)
        return 0;
    add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
    add_r = pipeline_expr_binop_right_ref_at(arena, right_ref);
    if (!glue_expr_same_var_c(arena, add_l, i_var_ref))
        return 0;
    if (pipeline_expr_kind_ord_at(arena, add_r) != 0)
        return 0;
    if (pipeline_expr_int_val_at(arena, add_r) != 1)
        return 0;
    return 1;
}

/** 解析 `dst[i]=a[i](+|-|*)b[i]`；binop_ko 输出 4=ADD / 5=SUB / 6=MUL。 */
static int32_t glue_parse_index_binop_assign_c(struct ast_ASTArena *arena, int32_t assign_ref, int32_t i_var_ref,
                                               int32_t *binop_ko, int32_t *dst_base_ref, int32_t *a_base_ref,
                                               int32_t *b_base_ref) {
    int32_t left_ref;
    int32_t right_ref;
    int32_t al;
    int32_t ar;
    int32_t dst_base;
    int32_t a_base;
    int32_t b_base;
    int32_t rko;
    if (pipeline_expr_kind_ord_at(arena, assign_ref) != GLUE_EXPR_ASSIGN)
        return 0;
    left_ref = pipeline_expr_binop_left_ref_at(arena, assign_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, assign_ref);
    if (!glue_index_uses_var_c(arena, left_ref, i_var_ref))
        return 0;
    rko = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rko != GLUE_EXPR_ADD && rko != GLUE_EXPR_SUB && rko != GLUE_EXPR_MUL)
        return 0;
    al = pipeline_expr_binop_left_ref_at(arena, right_ref);
    ar = pipeline_expr_binop_right_ref_at(arena, right_ref);
    if (!glue_index_uses_var_c(arena, al, i_var_ref) || !glue_index_uses_var_c(arena, ar, i_var_ref))
        return 0;
    dst_base = pipeline_expr_index_base_ref(arena, left_ref);
    a_base = pipeline_expr_index_base_ref(arena, al);
    b_base = pipeline_expr_index_base_ref(arena, ar);
    if (dst_base <= 0 || a_base <= 0 || b_base <= 0)
        return 0;
    if (pipeline_expr_kind_ord_at(arena, dst_base) != GLUE_EXPR_VAR ||
        pipeline_expr_kind_ord_at(arena, a_base) != GLUE_EXPR_VAR ||
        pipeline_expr_kind_ord_at(arena, b_base) != GLUE_EXPR_VAR)
        return 0;
    *binop_ko = rko;
    *dst_base_ref = dst_base;
    *a_base_ref = a_base;
    *b_base_ref = b_base;
    return 1;
}

/** 解析 `i < N`：N 为字面量或同块 let 整型初值；n_is_const=1 时写 n_lit。 */
static int32_t glue_parse_i_lt_bound_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t cond_ref,
                                       int32_t *i_var_ref, int32_t *n_lit, int32_t *n_is_const, int32_t *n_var_ref) {
    int32_t left_ref;
    int32_t right_ref;
    int32_t rko;
    int32_t prop;
    if (pipeline_expr_kind_ord_at(arena, cond_ref) != GLUE_EXPR_LT)
        return 0;
    left_ref = pipeline_expr_binop_left_ref_at(arena, cond_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, cond_ref);
    if (pipeline_expr_kind_ord_at(arena, left_ref) != GLUE_EXPR_VAR)
        return 0;
    *i_var_ref = left_ref;
    rko = pipeline_expr_kind_ord_at(arena, right_ref);
    if (rko == 0) {
        *n_lit = pipeline_expr_int_val_at(arena, right_ref);
        if (*n_lit <= 0)
            return 0;
        *n_is_const = 1;
        *n_var_ref = 0;
        return 1;
    }
    if (rko != GLUE_EXPR_VAR)
        return 0;
    *n_var_ref = right_ref;
    prop = glue_block_let_init_lit_c(arena, block_ref, right_ref, n_lit);
    if (prop) {
        if (*n_lit <= 0)
            return 0;
        *n_is_const = 1;
        return 1;
    }
    *n_is_const = 0;
    return 1;
}

/** EXPR_VAR 局部在 rbp 上的偏移；失败 -1。 */
static int32_t glue_simd_local_var_stack_off_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                int32_t var_expr_ref) {
    uint8_t vname[64];
    int32_t vlen;
    int32_t off;
    if (!arena || !ctx || var_expr_ref <= 0)
        return -1;
    vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
    if (vlen <= 0 || vlen > 63)
        return -1;
    pipeline_expr_var_name_into(arena, var_expr_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
        off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    return off;
}

/** 读取 SIMD-S1 已解析的 target CPU feature 掩码。 */
static uint32_t glue_simd_loop_cpu_features_c(void) {
    uint32_t feats;
    feats = driver_get_pending_target_cpu_features();
    if (feats != 0)
        return feats;
    return shu_target_cpu_detect_host();
}

/** 按 binop 与 CPU feature 选取 SIMD lane 宽（add/sub→SSE2/AVX2，mul→SSE4.1/AVX2）。 */
static int32_t glue_simd_loop_pick_lanes_c(uint32_t feats, int32_t binop_ko, int32_t *lanes_out) {
    if (binop_ko == GLUE_EXPR_MUL) {
        if ((feats & SHUX_CPU_FEAT_AVX2) != 0) {
            *lanes_out = 8;
            return 0;
        }
        if ((feats & SHUX_CPU_FEAT_SSE41) != 0) {
            *lanes_out = 4;
            return 0;
        }
        return -1;
    }
    if ((feats & SHUX_CPU_FEAT_AVX2) != 0) {
        *lanes_out = 8;
        return 0;
    }
    if ((feats & SHUX_CPU_FEAT_SSE2) != 0) {
        *lanes_out = 4;
        return 0;
    }
    return -1;
}

/** 发射单 chunk 硬件向量 binop；0=成功，-1=失败。 */
static int32_t glue_simd_loop_emit_chunk_binop_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t binop_ko,
                                                  int32_t chunk_off_a, int32_t chunk_off_b, int32_t chunk_off_d,
                                                  int32_t lanes, int32_t esz, int32_t ta, uint32_t feats) {
    if (binop_ko == GLUE_EXPR_SUB)
        return simd_enc_try_hw_vector_isub_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
    if (binop_ko == GLUE_EXPR_MUL)
        return simd_enc_try_hw_vector_imul_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
    return simd_enc_try_hw_vector_iadd_rbp(elf_ctx, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta, feats);
}

/** x86：cmp eax, ebx（i - n 置标志，紧接 jge 表示 i>=n 退出）。 */
static int32_t glue_simd_x86_cmp_rax_rbx_c(struct platform_elf_ElfCodegenCtx *elf_ctx) {
    static const uint8_t insn[2] = {0x39, 0xd8};
    if (!elf_ctx)
        return -1;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, (uint8_t *)insn, 2);
}

/** 编译期 trip count 整段 peel（N 为 lanes 的整数倍）。 */
static int32_t glue_emit_full_const_peel_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t binop_ko, int32_t off_a,
                                           int32_t off_b, int32_t off_d, int32_t n_lit, int32_t lanes, int32_t esz,
                                           int32_t ta, uint32_t feats) {
    int32_t chunks;
    int32_t chunk;
    const char *strict_env;
    chunks = n_lit / lanes;
    if (chunks <= 0 || (chunks * lanes) != n_lit)
        return 0;
    for (chunk = 0; chunk < chunks; chunk++) {
        int32_t start = chunk * lanes;
        int32_t chunk_off_a = off_a - start * esz;
        int32_t chunk_off_b = off_b - start * esz;
        int32_t chunk_off_d = off_d - start * esz;
        if (glue_simd_loop_emit_chunk_binop_c(elf_ctx, binop_ko, chunk_off_a, chunk_off_b, chunk_off_d, lanes, esz, ta,
                                              feats) != 0) {
            strict_env = getenv("SHUX_SIMD_HW_STRICT");
            if (strict_env && strict_env[0] != '0')
                return -1;
            return 0;
        }
    }
    return 1;
}

/**
 * 可变 n 条带主循环 + 标量 epilogue：
 *   while i < n { dst[i]=a[i] op b[i]; i++ }
 * → SIMD 块（i += lanes）+ 余数标量 while。
 */
static int32_t glue_emit_runtime_strip_loop_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                             struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t assign_body_ref,
                                             int32_t binop_ko, int32_t off_i, int32_t off_n, int32_t off_a,
                                             int32_t off_b, int32_t off_d, int32_t array_n, int32_t lanes,
                                             uint32_t feats) {
    uint8_t vec_loop[64];
    uint8_t epi_loop[64];
    uint8_t epi_done[64];
    int32_t vec_len;
    int32_t epi_len;
    int32_t done_len;
    if (ta != 0)
        return 0;
    vec_len = pipeline_asm_emit_next_label_c(ctx, vec_loop, 64);
    epi_len = pipeline_asm_emit_next_label_c(ctx, epi_loop, 64);
    done_len = pipeline_asm_emit_next_label_c(ctx, epi_done, 64);
    if (vec_len <= 0 || epi_len <= 0 || done_len <= 0)
        return -1;
    if (backend_enc_label_arch(elf_ctx, vec_loop, vec_len, 0, ta) != 0)
        return -1;
    /** i+lanes >= n+1 → 向量块越界，跳 epilogue。 */
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta) != 0)
        return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_n, ta) != 0)
        return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta) != 0)
        return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    if (glue_simd_x86_cmp_rax_rbx_c(elf_ctx) != 0)
        return -1;
    if (backend_enc_jge_arch(elf_ctx, epi_loop, epi_len, ta) != 0)
        return -1;
    if (simd_enc_try_hw_vector_binop_rbp_at_idx(elf_ctx, off_a, off_b, off_d, off_i, array_n, binop_ko, lanes, 4, ta,
                                                feats) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta) != 0)
        return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_jmp_arch(elf_ctx, vec_loop, vec_len, ta) != 0)
        return -1;
    /** 标量 epilogue：while i < n { assign; i++ } */
    if (backend_enc_label_arch(elf_ctx, epi_loop, epi_len, 0, ta) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, off_n, ta) != 0)
        return -1;
    if (glue_simd_x86_cmp_rax_rbx_c(elf_ctx) != 0)
        return -1;
    if (backend_enc_jge_arch(elf_ctx, epi_done, done_len, ta) != 0)
        return -1;
    if (pipeline_asm_emit_assign_elf_c(arena, elf_ctx, assign_body_ref, ctx, ta) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta) != 0)
        return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_jmp_arch(elf_ctx, epi_loop, epi_len, ta) != 0)
        return -1;
    if (backend_enc_label_arch(elf_ctx, epi_done, done_len, 0, ta) != 0)
        return -1;
    return 1;
}

extern int32_t pipeline_expr_field_access_soa_stride(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t lo, int32_t hi,
                                                  int32_t ta);

#define GLUE_EXPR_FIELD_ACCESS 44
#define GLUE_TYPE_F32 14

/** SoA x 列 x[start] 的 [rbp+disp32]（col0 为 x[0] 栈正偏移）。 */
static int32_t glue_soa_f32_col_rbp_disp32(int32_t off_col0, int32_t start_idx) {
    return -(off_col0 - start_idx * 4);
}

/** f32 局部槽 [rbp+disp32]。 */
static int32_t glue_f32_slot_rbp_disp32(int32_t off) {
    return -off;
}

/** VAR 定长数组元素个数；失败 0。 */
static int32_t glue_var_array_size_c(struct ast_ASTArena *arena, int32_t var_ref) {
    int32_t tr;
    int32_t asz;
    if (pipeline_expr_kind_ord_at(arena, var_ref) != GLUE_EXPR_VAR)
        return 0;
    tr = pipeline_expr_resolved_type_ref(arena, var_ref);
    if (tr <= 0 || pipeline_type_kind_ord_at(arena, tr) != GLUE_TYPE_ARRAY)
        return 0;
    asz = pipeline_type_array_size_at(arena, tr);
    if (asz <= 0 || asz > 65536)
        return 0;
    return asz;
}

/**
 * 解析 `s = s + arr[i].field`（SoA f32 列累加）。
 * field 须 soa_stride>0 且 resolved f32。
 */
static int32_t glue_parse_f32_soa_sum_assign_c(struct ast_ASTArena *arena, int32_t assign_ref, int32_t i_var_ref,
                                               int32_t *sum_ref, int32_t *arr_ref, int32_t *fa_ref) {
    int32_t left_ref;
    int32_t right_ref;
    int32_t add_l;
    int32_t add_r;
    int32_t idx_base;
    int32_t sum_tr;
    int32_t fa_tr;
    if (!sum_ref || !arr_ref || !fa_ref)
        return 0;
    if (pipeline_expr_kind_ord_at(arena, assign_ref) != GLUE_EXPR_ASSIGN)
        return 0;
    left_ref = pipeline_expr_binop_left_ref_at(arena, assign_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, assign_ref);
    if (pipeline_expr_kind_ord_at(arena, right_ref) != GLUE_EXPR_ADD)
        return 0;
    add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
    add_r = pipeline_expr_binop_right_ref_at(arena, right_ref);
    if (!glue_expr_same_var_c(arena, left_ref, add_l))
        return 0;
    if (pipeline_expr_kind_ord_at(arena, add_r) != GLUE_EXPR_FIELD_ACCESS)
        return 0;
    if (pipeline_expr_field_access_is_enum_variant(arena, add_r) != 0)
        return 0;
    if (pipeline_expr_field_access_soa_stride(arena, add_r) <= 0)
        return 0;
    fa_tr = pipeline_expr_resolved_type_ref(arena, add_r);
    if (fa_tr <= 0 || pipeline_type_kind_ord_at(arena, fa_tr) != GLUE_TYPE_F32)
        return 0;
    sum_tr = pipeline_expr_resolved_type_ref(arena, left_ref);
    if (sum_tr <= 0 || pipeline_type_kind_ord_at(arena, sum_tr) != GLUE_TYPE_F32)
        return 0;
    idx_base = pipeline_expr_field_access_base_ref(arena, add_r);
    if (pipeline_expr_kind_ord_at(arena, idx_base) != GLUE_EXPR_INDEX)
        return 0;
    if (!glue_index_uses_var_c(arena, idx_base, i_var_ref))
        return 0;
    idx_base = pipeline_expr_index_base_ref(arena, idx_base);
    if (pipeline_expr_kind_ord_at(arena, idx_base) != GLUE_EXPR_VAR)
        return 0;
    *sum_ref = left_ref;
    *arr_ref = idx_base;
    *fa_ref = add_r;
    return 1;
}

/**
 * f32 SoA 列 reduce 条带：movups/addps 主循环 + 水平归约写 s + 标量 epilogue（余数/i++1）。
 * 匹配 while i < n { s += arr[i].field; i++ }，n 可为字面量/let 常量或局部变量 n。
 */
static int32_t glue_emit_f32_soa_sum_strip_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t assign_body_ref,
                                              int32_t off_col0, int32_t off_s, int32_t off_i, int32_t off_n,
                                              int32_t n_lit, int32_t lanes, uint32_t feats) {
    uint8_t vec_loop[64];
    uint8_t epi_merge[64];
    uint8_t epi_loop[64];
    uint8_t epi_done[64];
    int32_t vec_len;
    int32_t merge_len;
    int32_t epi_len;
    int32_t done_len;
    const char *strict_env;
    if (ta != 0 || lanes != 4 || (feats & SHUX_CPU_FEAT_SSE2) == 0)
        return 0;
    vec_len = pipeline_asm_emit_next_label_c(ctx, vec_loop, 64);
    merge_len = pipeline_asm_emit_next_label_c(ctx, epi_merge, 64);
    epi_len = pipeline_asm_emit_next_label_c(ctx, epi_loop, 64);
    done_len = pipeline_asm_emit_next_label_c(ctx, epi_done, 64);
    if (vec_len <= 0 || merge_len <= 0 || epi_len <= 0 || done_len <= 0)
        return -1;
    if (simd_enc_x86_xorps_xmm0_zero(elf_ctx) != 0)
        return -1;
    /** 向量主循环：i+lanes > n 时跳 epilogue（避免越界 movups）。 */
    if (backend_enc_label_arch(elf_ctx, vec_loop, vec_len, 0, ta) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta) != 0)
        return -1;
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
    if (off_n >= 0) {
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_n, ta) != 0)
            return -1;
    } else {
        if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta) != 0)
            return -1;
    }
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta) != 0)
        return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
    if (glue_simd_x86_cmp_rax_rbx_c(elf_ctx) != 0)
        return -1;
    if (backend_enc_jge_arch(elf_ctx, epi_merge, merge_len, ta) != 0)
        return -1;
    if (simd_enc_f32_soa_col_movups_xmm1_at_idx(elf_ctx, off_col0, off_i, ta) != 0) {
        strict_env = getenv("SHUX_SIMD_HW_STRICT");
        if (strict_env && strict_env[0] != '0')
            return -1;
        return 0;
    }
    if (simd_enc_x86_addps_xmm0_xmm1(elf_ctx) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, lanes, ta) != 0)
        return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_jmp_arch(elf_ctx, vec_loop, vec_len, ta) != 0)
        return -1;
    /** 向量块累加结果 → 标量 s（须 s 初值为 0；epilogue 再 addss 余数）。 */
    if (backend_enc_label_arch(elf_ctx, epi_merge, merge_len, 0, ta) != 0)
        return -1;
    if (simd_enc_x86_horizontal_addps_xmm0(elf_ctx) != 0)
        return -1;
    if (simd_enc_x86_movss_xmm0_rbp_disp(elf_ctx, glue_f32_slot_rbp_disp32(off_s)) != 0)
        return -1;
    /** 标量 epilogue：while i < n { s += arr[i].x; i++ } */
    if (backend_enc_label_arch(elf_ctx, epi_loop, epi_len, 0, ta) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (off_n >= 0) {
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, off_n, ta) != 0)
            return -1;
    } else {
        /** 编译期 n：须保留 rax 中的 i，不可 glue_emit_n_to_rbx（会 clobber rax）。 */
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
            return -1;
        if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta) != 0)
            return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
            return -1;
        if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
            return -1;
    }
    if (glue_simd_x86_cmp_rax_rbx_c(elf_ctx) != 0)
        return -1;
    if (backend_enc_jge_arch(elf_ctx, epi_done, done_len, ta) != 0)
        return -1;
    if (pipeline_asm_emit_assign_elf_c(arena, elf_ctx, assign_body_ref, ctx, ta) != 0)
        return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta) != 0)
        return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off_i, ta) != 0)
        return -1;
    if (backend_enc_jmp_arch(elf_ctx, epi_loop, epi_len, ta) != 0)
        return -1;
    if (backend_enc_label_arch(elf_ctx, epi_done, done_len, 0, ta) != 0)
        return -1;
    return 1;
}

/**
 * 尝试将 `while i < n { s = s + arr[i].field; i++ }`（SoA f32 列）矢量化 reduce peel。
 */
int32_t glue_try_simd_peel_f32_soa_sum_while_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                    int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta) {
    int32_t cond_ref;
    int32_t body_ref;
    int32_t i_var_ref;
    int32_t n_lit;
    int32_t n_is_const;
    int32_t n_var_ref;
    int32_t assign_body_ref;
    int32_t assign_step_ref;
    int32_t sum_ref;
    int32_t arr_ref;
    int32_t fa_ref;
    int32_t array_n;
    int32_t off_col0;
    int32_t col_base;
    int32_t off_s;
    int32_t off_i;
    int32_t off_n;
    uint32_t feats;
    const char *hw_env;
    int32_t lanes;

    if (!arena || !elf_ctx || !ctx || block_ref <= 0)
        return 0;
    hw_env = getenv("SHUX_SIMD_HW");
    if (hw_env && hw_env[0] == '0')
        return 0;
    cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
    body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
    if (cond_ref <= 0 || body_ref <= 0)
        return 0;
    if (!glue_parse_i_lt_bound_c(arena, block_ref, cond_ref, &i_var_ref, &n_lit, &n_is_const, &n_var_ref))
        return 0;
    if (ast_ast_block_num_expr_stmts(arena, body_ref) != 2)
        return 0;
    assign_body_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 0);
    assign_step_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 1);
    if (assign_body_ref <= 0 || assign_step_ref <= 0)
        return 0;
    if (!glue_parse_f32_soa_sum_assign_c(arena, assign_body_ref, i_var_ref, &sum_ref, &arr_ref, &fa_ref))
        return 0;
    if (!glue_parse_i_plus_one_step_c(arena, assign_step_ref, i_var_ref))
        return 0;
    array_n = glue_var_array_size_c(arena, arr_ref);
    if (n_is_const) {
        if (n_lit <= 0)
            return 0;
        if (array_n > 0 && n_lit > array_n)
            return 0;
    } else if (n_var_ref <= 0) {
        return 0;
    }
    off_col0 = glue_simd_local_var_stack_off_c(arena, ctx, arr_ref);
    col_base = pipeline_expr_field_access_offset(arena, fa_ref);
    if (col_base > 0)
        off_col0 -= col_base;
    off_s = glue_simd_local_var_stack_off_c(arena, ctx, sum_ref);
    off_i = glue_simd_local_var_stack_off_c(arena, ctx, i_var_ref);
    if (off_col0 < 0 || off_s < 0 || off_i < 0)
        return 0;
    feats = glue_simd_loop_cpu_features_c();
    lanes = 4;
    if ((feats & SHUX_CPU_FEAT_SSE2) == 0)
        return 0;
    off_n = -1;
    if (n_var_ref > 0)
        off_n = glue_simd_local_var_stack_off_c(arena, ctx, n_var_ref);
    if (!n_is_const && off_n < 0)
        return 0;
    return glue_emit_f32_soa_sum_strip_c(arena, elf_ctx, ctx, ta, assign_body_ref, off_col0, off_s, off_i, off_n,
                                         n_lit, lanes, feats);
}

int32_t glue_try_simd_peel_index_add_while_elf_c(struct ast_ASTArena *arena,
                                                 struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t block_ref,
                                                 int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t ta) {
    int32_t cond_ref;
    int32_t body_ref;
    int32_t i_var_ref;
    int32_t n_lit;
    int32_t n_is_const;
    int32_t n_var_ref;
    int32_t array_n;
    int32_t off_i;
    int32_t off_n;
    int32_t nes;
    int32_t assign_body_ref;
    int32_t assign_step_ref;
    int32_t binop_ko;
    int32_t dst_base;
    int32_t a_base;
    int32_t b_base;
    int32_t off_a;
    int32_t off_b;
    int32_t off_d;
    uint32_t feats;
    const char *hw_env;
    int32_t lanes;
    int32_t esz;

    if (!arena || !elf_ctx || !ctx || block_ref <= 0)
        return 0;
    hw_env = getenv("SHUX_SIMD_HW");
    if (hw_env && hw_env[0] == '0')
        return 0;
    cond_ref = ast_ast_block_while_cond_ref(arena, block_ref, loop_idx);
    body_ref = ast_ast_block_while_body_ref(arena, block_ref, loop_idx);
    if (cond_ref <= 0 || body_ref <= 0)
        return 0;
    if (!glue_parse_i_lt_bound_c(arena, block_ref, cond_ref, &i_var_ref, &n_lit, &n_is_const, &n_var_ref))
        return 0;
    nes = ast_ast_block_num_expr_stmts(arena, body_ref);
    if (nes != 2)
        return 0;
    assign_body_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 0);
    assign_step_ref = ast_ast_block_expr_stmt_ref(arena, body_ref, 1);
    if (assign_body_ref <= 0 || assign_step_ref <= 0)
        return 0;
    if (!glue_parse_index_binop_assign_c(arena, assign_body_ref, i_var_ref, &binop_ko, &dst_base, &a_base, &b_base))
        return 0;
    if (!glue_parse_i_plus_one_step_c(arena, assign_step_ref, i_var_ref))
        return 0;
    array_n = glue_var_array_i32_size_c(arena, dst_base);
    if (array_n <= 0 || glue_var_array_i32_size_c(arena, a_base) != array_n ||
        glue_var_array_i32_size_c(arena, b_base) != array_n)
        return 0;
    off_a = glue_simd_local_var_stack_off_c(arena, ctx, a_base);
    off_b = glue_simd_local_var_stack_off_c(arena, ctx, b_base);
    off_d = glue_simd_local_var_stack_off_c(arena, ctx, dst_base);
    off_i = glue_simd_local_var_stack_off_c(arena, ctx, i_var_ref);
    if (off_a < 0 || off_b < 0 || off_d < 0 || off_i < 0)
        return 0;
    feats = glue_simd_loop_cpu_features_c();
    esz = 4;
    if (glue_simd_loop_pick_lanes_c(feats, binop_ko, &lanes) != 0)
        return 0;
    /** 编译期 n 且整除 lanes：整段 peel。 */
    if (n_is_const && n_lit > 0 && (n_lit % lanes) == 0 && n_lit <= array_n &&
        glue_var_is_array_i32_n_c(arena, dst_base, n_lit)) {
        return glue_emit_full_const_peel_c(elf_ctx, binop_ko, off_a, off_b, off_d, n_lit, lanes, esz, ta, feats);
    }
    /** 可变 n 或 n 非 lanes 整数倍：条带主循环 + 标量 epilogue。 */
    if (n_var_ref > 0) {
        off_n = glue_simd_local_var_stack_off_c(arena, ctx, n_var_ref);
        if (off_n < 0)
            return 0;
        return glue_emit_runtime_strip_loop_c(arena, elf_ctx, ctx, ta, assign_body_ref, binop_ko, off_i, off_n, off_a,
                                              off_b, off_d, array_n, lanes, feats);
    }
    return 0;
}
