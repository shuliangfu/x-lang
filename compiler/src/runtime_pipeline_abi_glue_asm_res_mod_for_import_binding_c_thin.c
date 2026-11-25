/* Source-faithful glue_asm_res_mod_for_import_binding_c twin
 * (compiler/src/asm/backend_call_dispatch.x export at ~L9035-9075).
 * s179 hello-build residual after s178 load_32 thin: soft check green;
 * build hangs in 2nd io_register_provided_buffers → method_tail →
 * glue_asm_mangle_import_binding_call_sym_c (s172 thin) → 2nd call of
 * glue_asm_res_mod_for_import_binding_c @ 0x140458714 with try_dep=-1
 * (1st call try_dep=0 returns). After pipeline_dep_ctx_ndep(=12) the
 * typool body never returns. Path uses `let dpath: u8[256] = []` then
 * pipeline_dep_ctx_import_path_copy64 — same typool =[] / break-as-jmp
 * family as s167–s173. Host-cc uses memset for the path slot and keeps
 * the tip while/break control. docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <string.h>

int32_t pipeline_dep_ctx_ndep(uint8_t *dp);
uint8_t *pipeline_dep_ctx_module_at(uint8_t *dp, int32_t ix);
int32_t pipeline_module_import_path_len(uint8_t *mod, int32_t idx);
int32_t pipeline_dep_ctx_import_path_len(uint8_t *dp, int32_t j);
void pipeline_dep_ctx_import_path_copy64(uint8_t *dp, int32_t j, uint8_t *path);
uint8_t pipeline_module_import_path_byte_at(uint8_t *mod, int32_t idx, int32_t k);

uint8_t *glue_asm_res_mod_for_import_binding_c(
    uint8_t *dp, uint8_t *user_mod, int32_t imp_j, int32_t r_dep
) {
  int32_t nd;
  int32_t iplen;
  int32_t di;
  int32_t dplen;
  uint8_t dpath[256];
  int32_t eq;
  int32_t k;

  if (dp == 0) {
    return 0;
  }
  nd = pipeline_dep_ctx_ndep(dp);
  if (r_dep >= 0) {
    if (r_dep < nd) {
      return pipeline_dep_ctx_module_at(dp, r_dep);
    }
  }
  if (user_mod == 0) {
    return 0;
  }
  if (imp_j < 0) {
    return 0;
  }
  iplen = pipeline_module_import_path_len(user_mod, imp_j);
  if (iplen <= 0) {
    return 0;
  }
  if (iplen > 63) {
    return 0;
  }
  di = 0;
  while (di < nd) {
    dplen = pipeline_dep_ctx_import_path_len(dp, di);
    if (dplen == iplen) {
      /* Cap 4.2.8: import_path_copy64 writes 256 bytes — dst >= 256. */
      memset(dpath, 0, sizeof(dpath));
      pipeline_dep_ctx_import_path_copy64(dp, di, &dpath[0]);
      eq = 1;
      k = 0;
      while (k < iplen) {
        if (dpath[k] != pipeline_module_import_path_byte_at(user_mod, imp_j, k)) {
          eq = 0;
          break;
        }
        k = k + 1;
      }
      if (eq != 0) {
        return pipeline_dep_ctx_module_at(dp, di);
      }
    }
    di = di + 1;
  }
  return 0;
}
