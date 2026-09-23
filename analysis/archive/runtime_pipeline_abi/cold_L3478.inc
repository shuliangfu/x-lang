/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
int xlang_import_dep_dir_from_path(const char *path, char *dep_dir, size_t dep_dir_size) {
  if (path == NULL) {
    return -1;
  }
  if (dep_dir == NULL) {
    return -1;
  }
  if (dep_dir_size == 0) {
    return -1;
  }
  {
    return xlang_import_dep_dir_from_path_impl(path, dep_dir, dep_dir_size);
  }
  return -1;
}
