/* seeds/labi_diag_pure.from_x.c — G-02f-268/L P2 link_abi L1 diag pure thin shells
 * Logic source: src/runtime/labi_diag_pure.x
 * Hybrid: SHUX_LABI_DIAG_PURE_FROM_X + ld -r into runtime_link_abi.o
 * 产品 PREFER_X_O：g05_try_x_to_o(labi_diag_pure.x)；本 seed 冷启动 / fallback
 * prove：nm IDENTICAL（code_for_kind + 8 report thin + labi_diag_pure_count + U _impl）
 *
 * - link_diag_code_for_kind：pure strcmp 映射（与 .x 同构）
 * - reportf/长文案：thin → *_impl（mega rest 常驻）
 */
#include <stddef.h>
#include <string.h>

/* Report bodies provided by runtime_link_abi.from_x.c rest (always). */
void link_diag_runtime_obj_resolve_fail_impl(const char *obj_name, const char *hint);
void link_diag_runtime_source_missing_impl(const char *obj_name, const char *source_path);
void link_diag_runtime_source_missing_under_impl(const char *obj_name, const char *base_dir,
                                                 const char *suffix);
void link_diag_runtime_obj_missing_impl(const char *obj_name, const char *out_o);
void link_diag_freestanding_missing_impl(const char *obj_name, const char *symbol_name);
void link_diag_freestanding_unsupported_impl(void);
void link_diag_ld_debug_push_impl(const char *rel, const char *stage, const char *path);
void link_diag_ld_debug_argv_impl(const char *label, const char *const *argv);

const char *link_diag_code_for_kind(const char *kind) {
  if (!kind)
    return "PRC001";
  if (strcmp(kind, "build error") == 0)
    return "BLD001";
  if (strcmp(kind, "process error") == 0)
    return "PRC001";
  return NULL;
}

void link_diag_runtime_obj_resolve_fail(const char *obj_name, const char *hint) {
  link_diag_runtime_obj_resolve_fail_impl(obj_name, hint);
}

void link_diag_runtime_source_missing(const char *obj_name, const char *source_path) {
  link_diag_runtime_source_missing_impl(obj_name, source_path);
}

void link_diag_runtime_source_missing_under(const char *obj_name, const char *base_dir,
                                            const char *suffix) {
  link_diag_runtime_source_missing_under_impl(obj_name, base_dir, suffix);
}

void link_diag_runtime_obj_missing(const char *obj_name, const char *out_o) {
  link_diag_runtime_obj_missing_impl(obj_name, out_o);
}

void link_diag_freestanding_missing(const char *obj_name, const char *symbol_name) {
  link_diag_freestanding_missing_impl(obj_name, symbol_name);
}

void link_diag_freestanding_unsupported(void) {
  link_diag_freestanding_unsupported_impl();
}

void link_diag_ld_debug_push(const char *rel, const char *stage, const char *path) {
  link_diag_ld_debug_push_impl(rel, stage, path);
}

void link_diag_ld_debug_argv(const char *label, const char *const *argv) {
  link_diag_ld_debug_argv_impl(label, argv);
}

/* Pure audit: public L1 gates in this slice (code_for_kind + 8 report thin). */
int labi_diag_pure_count(void) {
  return 9;
}
