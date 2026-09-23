/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
void *get_dep_arena(int32_t i) {
  if ((i < 0)) {
    return ((void *)(0));
  }
  (void)(({   {
    int32_t n = get_ndep();
    if ((i >=n)) {
      return ((void *)(0));
    }
    void * r = typeck_dep_arena_get(i);
    return r;
  }
 }));
  return ((void *)(0));
}
