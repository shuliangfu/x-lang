/*
 * DIG s224: host-cc twins for park_commit_args + commit_parked.
 *
 * Tip-asm of pthin_imports.x loads/stores module-level g_collect_imports_*
 * incorrectly (commit_parked reads uninit stack as pointers → SEGV on
 * `const name = import("path")`; park_commit_args burns a huge frame and
 * never stores the four args into the BSS globals). Authority matches
 * src/asm/pthin_imports.x (park then commit; IMPORT_BIND_CAP=128).
 * PLATFORM: SHARED host-cc first-wins (LINUX gold for tip -E parser.x).
 */
#include <stdint.h>

static uint8_t *g_collect_imports_module;
static uint8_t *g_collect_imports_path_buf;
static int32_t *g_collect_imports_path_len;
static uint8_t *g_collect_imports_bind_buf;

extern int32_t pipeline_module_import_alloc(uint8_t *module);
extern void pipeline_module_import_set_path(uint8_t *module, int32_t idx,
                                           uint8_t *bytes, int32_t len);
extern void pipeline_module_import_set_kind(uint8_t *module, int32_t idx,
                                           int32_t kind);
extern void pipeline_module_import_set_binding_name(uint8_t *module, int32_t idx,
                                                   uint8_t *bytes, int32_t len);
extern void pipeline_module_import_set_select_count(uint8_t *module, int32_t idx,
                                                   int32_t n);

/**
 * Park collect-imports commit pointers for the small commit frame.
 * Must share statics with commit_parked in this TU.
 */
void parser_asm_collect_imports_park_commit_args(uint8_t *module,
                                                 uint8_t *path_buf,
                                                 int32_t *path_len,
                                                 uint8_t *bind_buf) {
  g_collect_imports_module = module;
  g_collect_imports_path_buf = path_buf;
  g_collect_imports_path_len = path_len;
  g_collect_imports_bind_buf = bind_buf;
}

/**
 * Commit one parked const-import onto the opaque module.
 * @return import index, or -1 on null park / empty path / alloc fail
 */
int32_t parser_asm_collect_imports_commit_parked(void) {
  int32_t n;
  int32_t blen;
  int32_t ix;
  uint8_t b;
  if (g_collect_imports_module == 0 || g_collect_imports_path_buf == 0
      || g_collect_imports_path_len == 0 || g_collect_imports_bind_buf == 0) {
    return -1;
  }
  n = g_collect_imports_path_len[0];
  if (n <= 0) {
    return -1;
  }
  blen = 0;
  while (blen < 128) {
    b = g_collect_imports_bind_buf[blen];
    if (b == 0) {
      break;
    }
    blen = blen + 1;
  }
  ix = pipeline_module_import_alloc(g_collect_imports_module);
  if (ix < 0) {
    return -1;
  }
  pipeline_module_import_set_path(g_collect_imports_module, ix,
                                  g_collect_imports_path_buf, n);
  pipeline_module_import_set_kind(g_collect_imports_module, ix, 1);
  pipeline_module_import_set_binding_name(g_collect_imports_module, ix,
                                          g_collect_imports_bind_buf, blen);
  pipeline_module_import_set_select_count(g_collect_imports_module, ix, 0);
  return ix;
}
