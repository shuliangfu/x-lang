/**
 * pipeline_asm_ctx_layout.c — AsmFuncCtx layout view + cast helper (BC 8.3.1).
 *
 * wave1283 BC 8.3 G.7 same-TU early domain fold from pipeline_glue.c:
 *   typedef pipeline_glue_AsmFuncCtxLayout
 *   static pipeline_asm_ctx_layout (opaque backend_AsmFuncCtx * → layout *)
 *
 * Why early: every asm emit domain that touches frame_size / next_offset /
 * module_ref / loop labels casts through this layout. The typedef + cast must
 * appear BEFORE the first #include of those domains (emit_return / unary /
 * block_body / fold_count_up_while / codegen_mega_body / …).
 *
 * Include site: pipeline_glue.c top, immediately after std headers and before
 * the large extern/fwd shell and domain #includes. Not a separate .o — textually
 * #include'd into pipeline_x.o host-cc TU.
 *
 * G.7: single authority for AsmFuncCtx field layout view. Do not redeclare the
 * layout struct or open a second cast path in emit domains.
 *
 * PLATFORM: SHARED — host-cc residual; layout mirrors backend AsmFuncCtx ABI.
 */

struct backend_AsmFuncCtx;

/**
 * Layout overlay of backend AsmFuncCtx for C residual emit paths.
 * Field order must stay ABI-compatible with the X/asm AsmFuncCtx definition.
 */
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

/** Cast opaque AsmFuncCtx* to the C residual layout view (same address). */
static pipeline_glue_AsmFuncCtxLayout *pipeline_asm_ctx_layout(struct backend_AsmFuncCtx *ctx) {
  return (pipeline_glue_AsmFuncCtxLayout *)ctx;
}
