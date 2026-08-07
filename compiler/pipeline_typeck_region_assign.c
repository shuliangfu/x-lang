/**
 * pipeline_typeck_region_assign.c — typeck region/escape assign-site domain (BC 8.3.1).
 *
 * wave235 G.7 pure leave: M-3 slice region assign + return operand path dual
 * bodies retired → typeck.x (typeck_check_slice_region_assign /
 * typeck_check_return_slice_region + private escape/conflict helpers).
 *
 * wave236 G.7 pure leave: WPO-S3 stack-escape assign + MEM-A3 scope-borrow
 * assign/return → typeck.x (typeck_check_struct_stack_escape_assign /
 * typeck_check_scope_borrow_assign / typeck_check_scope_borrow_return +
 * private helpers). Cap residual keeps thin *_c faces for scan/mega.
 *
 * wave237 G.7 pure leave: MEM-C1 allocator region assign/return → typeck.x
 * (typeck_check_allocator_region_assign / typeck_check_allocator_region_return).
 *
 * wave239 G.7 pure leave: M-3 call_slice_region + MOD-02 *Struct compat →
 * typeck.x (typeck_check_call_slice_region + private typeck_check_call_ptr_struct_compat).
 * Cap residual keeps thin pipeline_typeck_check_call_slice_region_c only.
 *
 * wave240 G.7 pure leave: MEM-C1 with_arena nest BSS + push/pop/reset →
 * typeck.x (pipeline_typeck_with_arena_scope_*). Cap residual only
 * calls pure faces from scan tree + check_block_one_region.
 *
 * wave241 G.7 pure leave: M-3 region-label scope BSS + push/pop/len/reset →
 * typeck.x (pipeline_dep_ctx_scope_region_* + pipeline_typeck_region_scope_reset_c).
 * Cap residual only calls pure faces; no second BSS cell.
 *
 * wave242 G.7 pure leave: WPO-S3 post-scan tree (scan_expr / scan_block /
 * pipeline_typeck_scan_module_struct_stack_escape_c) → typeck.x.
 * Cap residual deletes static scan bodies (dual-export ban); pure calls pure
 * pipeline_typeck_check_call_struct_stack_escape_c (wave244; dual-export ban).
 *
 * wave243 G.7 pure leave: M-5 read_ptr slice + M-3 stamp_let → typeck.x
 * (pipeline_typeck_is_read_ptr_slice_callee_c /
 *  pipeline_typeck_read_ptr_slice_return_ref_c /
 *  pipeline_type_stamp_block_let_region_c). Cap residual deletes second bodies.
 *
 * wave244 G.7 pure leave: M-3 check_block_one_region + WPO-S3
 * call_struct_stack_escape → typeck.x (pipeline_typeck_check_block_one_region_c /
 * pipeline_typeck_check_call_struct_stack_escape_c). Cap residual deletes second
 * bodies; pure var_is_block_local gains residual-fidelity block-tree walk.
 *
 * wave245 G.7 pure leave: WPO-S3 ptr_for_addr_of (+ stack_local *T stamp) →
 * typeck.x (pipeline_typeck_ptr_for_addr_of_operand_c). Type-pool face
 * pipeline_type_find_or_alloc_ptr is the single authority for labelled *T.
 * Cap residual deletes stack_local helpers + dead store-scan cluster + body.
 *
 * wave246 G.7 pure leave: M-3 return_slice_region_in_scope → typeck.x
 * (pipeline_typeck_check_return_slice_region_in_scope_c). Cap residual deletes
 * second body + static expr_diag_line_col (only residual caller of that helper).
 *
 * Still residual (not pure-leaved this wave):
 * - thin *_c faces for scan/mega / pure leave callees
 *
 * G.7 dual-export ban: do NOT re-open second bodies for pure-leaved faces;
 * typeck.x is single authority for those checks.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c.
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Live M-3 / WPO-S3 / MEM-A3 authority in typeck_x.o (typeck.x exports). */
extern int32_t typeck_check_slice_region_assign(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                int32_t expect_ref, int32_t src_ref);
extern int32_t typeck_check_return_slice_region(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                int32_t op_ref, int32_t func_return_ref);
extern int32_t typeck_check_struct_stack_escape_assign(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_scope_borrow_assign(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_scope_borrow_return(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t site_expr_ref, int32_t op_ref, int32_t return_type_ref,
                                                struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_allocator_region_assign(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t site_expr_ref, int32_t left_ref,
                                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_check_allocator_region_return(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                    int32_t return_type_ref);
extern int32_t typeck_check_call_slice_region(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx);

/* wave156 pure-owned: assign-like kind face lives in runtime_pipeline_abi pure. */
int32_t glue_expr_kind_is_assign_like_ord(int32_t ko);

/**
 * M-3：.x typeck 统一 slice 域 assign/let/实参检查.
 * wave235 pure leave: thin → typeck_check_slice_region_assign.
 * site_expr_ref 用于 line/col；返回 0 可接受，-1 已打印 typeck error。
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_slice_region_assign_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                    int32_t expect_ref, int32_t src_ref) {
  return typeck_check_slice_region_assign(arena, site_expr_ref, expect_ref, src_ref);
}

/**
 * WPO-S3：assign 路径 — 禁止将局部 struct 指针写入形参 *T 的字段（外层槽逃逸）。
 * wave236 pure leave: thin → typeck_check_struct_stack_escape_assign.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_struct_stack_escape_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                           struct ast_PipelineDepCtx *ctx) {
  return typeck_check_struct_stack_escape_assign(module, arena, site_expr_ref, left_ref, right_ref, ctx);
}

/**
 * MEM-A3：assign — 禁止内层块局部地址写入外层块变量（scope borrow 逃逸）。
 * wave236 pure leave: thin → typeck_check_scope_borrow_assign.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_scope_borrow_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t site_expr_ref, int32_t left_ref, int32_t right_ref,
                                                  struct ast_PipelineDepCtx *ctx) {
  return typeck_check_scope_borrow_assign(module, arena, site_expr_ref, left_ref, right_ref, ctx);
}

/**
 * MEM-A3：return — 禁止返回块内局部变量地址（指针逃出函数/块生命周期）。
 * wave236 pure leave: thin → typeck_check_scope_borrow_return.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_scope_borrow_return_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t site_expr_ref, int32_t op_ref, int32_t return_type_ref,
                                                    struct ast_PipelineDepCtx *ctx) {
  return typeck_check_scope_borrow_return(module, arena, site_expr_ref, op_ref, return_type_ref, ctx);
}

/*
 * wave240 G.7 pure leave: with_arena nest BSS + push/pop/reset live in
 * typeck.x / typeck_gen (pipeline_typeck_with_arena_scope_* → typeck_x.o).
 * Cap residual only calls pure faces — dual-export ban (no second BSS cell).
 * PLATFORM: SHARED — freestanding typeck_x provides the symbols.
 */
extern int32_t pipeline_typeck_with_arena_scope_n_at(void);
extern int32_t pipeline_typeck_with_arena_current_body_ref_c(void);
extern void pipeline_typeck_with_arena_scope_push_c(int32_t body_ref);
extern void pipeline_typeck_with_arena_scope_pop_c(void);
extern void pipeline_typeck_with_arena_scope_reset_c(void);

/*
 * wave241 G.7 pure leave: region-label scope BSS + push/pop/len/reset live in
 * typeck.x / typeck_gen (pipeline_dep_ctx_scope_region_* → typeck_x.o).
 * Cap residual only calls pure faces — dual-export ban (no second BSS cell).
 */
extern int32_t pipeline_dep_ctx_scope_region_push_c(struct ast_PipelineDepCtx *ctx, uint8_t *label,
                                                    int32_t label_len);
extern void pipeline_dep_ctx_scope_region_pop_c(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_scope_region_len_at(struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_region_scope_reset_c(void);

/** M-3 AL-06：return slice 域检查（定义见下）。 */
int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                    int32_t op_ref, int32_t func_return_ref);

/**
 * MEM-C1 AL-04：with_arena 内 assign — 禁止 arena 域值写入块外变量（allocator region 逃逸）。
 * wave237 pure leave: thin → typeck_check_allocator_region_assign.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_allocator_region_assign_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      int32_t site_expr_ref, int32_t left_ref,
                                                      struct ast_PipelineDepCtx *ctx) {
  return typeck_check_allocator_region_assign(module, arena, site_expr_ref, left_ref, ctx);
}

/**
 * MEM-C1 AL-04：with_arena 内 return Allocator — 禁止 allocator 域逃出 with_arena 块。
 * wave237 pure leave: thin → typeck_check_allocator_region_return.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_allocator_region_return_c(struct ast_ASTArena *arena, int32_t site_expr_ref,
                                                        int32_t return_type_ref) {
  return typeck_check_allocator_region_return(arena, site_expr_ref, return_type_ref);
}

/**
 * M-3：.x typeck return 路径 slice 域逃逸 / 不一致；ret_site_ref 用于 line/col。
 * wave235 pure leave: thin → typeck_check_return_slice_region.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_return_slice_region_c(struct ast_ASTArena *arena, int32_t ret_site_ref,
                                                    int32_t op_ref, int32_t func_return_ref) {
  return typeck_check_return_slice_region(arena, ret_site_ref, op_ref, func_return_ref);
}

/*
 * wave242–246 G.7 pure leave trail (dual-export ban — no second bodies):
 *   wave242 scan_expr/scan_block/scan_module → typeck_x.o
 *   wave243 read_ptr + stamp_let → typeck_x.o
 *   wave244 one_region + call_struct → typeck_x.o
 *   wave245 ptr_for_addr_of (+ stack_local *T) → typeck_x.o
 *   wave246 return_slice_region_in_scope → typeck_x.o
 * Residual keeps thin *_c faces only (no second pure-leaved bodies).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU (U faces from typeck_x).
 */

/* wave246 pure leave: return_slice_region_in_scope lives in typeck_x.o (dual-export ban).
 * check_expr residual + scan tree may still call by name — U from typeck_x. */
extern int32_t pipeline_typeck_check_return_slice_region_in_scope_c(struct ast_ASTArena *arena,
                                                                    int32_t site_expr_ref,
                                                                    int32_t return_type_ref,
                                                                    struct ast_PipelineDepCtx *ctx);

/* wave243 pure leave: read_ptr + stamp_let live in typeck_x.o (dual-export ban). */
extern int32_t pipeline_typeck_is_read_ptr_slice_callee_c(uint8_t *name, int32_t name_len);
extern int32_t pipeline_typeck_read_ptr_slice_return_ref_c(struct ast_ASTArena *arena);
extern int32_t pipeline_type_stamp_block_let_region_c(struct ast_ASTArena *arena, int32_t block_ref,
                                                     int32_t let_idx, struct ast_PipelineDepCtx *ctx);

/* wave244 pure leave: one_region + call_struct live in typeck_x.o (dual-export ban).
 * check_expr residual may still call call_struct by name — U from typeck_x. */
extern int32_t pipeline_typeck_check_call_struct_stack_escape_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena,
                                                                int32_t call_expr_ref,
                                                                struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_block_one_region_c(struct ast_Module *module,
                                                        struct ast_ASTArena *arena, int32_t block_ref,
                                                        int32_t region_idx, int32_t return_type_ref,
                                                        struct ast_PipelineDepCtx *ctx);

/* wave245 pure leave: ptr_for_addr lives in typeck_x.o (dual-export ban).
 * check_expr addr_of + typeck_gen call this name — U from typeck_x.
 * Type-pool: pipeline_type_find_or_alloc_ptr (ast_pool_type.c) for stack_local *T. */
extern int32_t pipeline_typeck_ptr_for_addr_of_operand_c(struct ast_ASTArena *arena, int32_t op_ref,
                                                        int32_t elem_ty, struct ast_Module *module,
                                                        struct ast_PipelineDepCtx *ctx);

/**
 * M-3 CALL slice region Cap residual thin face.
 * wave239 pure leave: body → typeck_check_call_slice_region (typeck_x.o).
 * Dual-export ban: no second call_slice / ptr_struct_compat body here.
 * PLATFORM: SHARED — Cap residual face only.
 */
int32_t pipeline_typeck_check_call_slice_region_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t call_expr_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_call_slice_region(module, arena, call_expr_ref, ctx);
}
