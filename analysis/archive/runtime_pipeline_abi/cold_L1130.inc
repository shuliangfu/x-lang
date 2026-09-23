/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
void pipeline_set_dep(int32_t i, void *mod, void *arena) {
  if ((i < 0)) {
    return;
  }
  if ((i >=32)) {
    return;
  }
  (void)(({   {
    (void)(typeck_dep_module_set(i, mod));
    (void)(typeck_dep_arena_set(i, arena));
  }
 }));
}
