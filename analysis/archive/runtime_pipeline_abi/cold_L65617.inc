/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* Cold dual: typeck_check_expr_method_call → residual method_call_c when pure/typeck absent. */
int32_t typeck_check_expr_method_call(void *module, void *arena, int32_t expr_ref, int32_t return_type_ref, void *ctx) {
  return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx);
}
