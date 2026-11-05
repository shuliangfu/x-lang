/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only — tip_l4_tip_pe_cg002_asm_codegen.
 *
 * Tip PE selfhost-emitted glue_asm_build_dep_export_sym_c (backend_call_dispatch.o)
 * drops loop increments (i++/pos++) after the prefix/name copy stores — Cap keeps
 * both. After cg002 export_sym twin restores the non-bare else → dep_export, tip
 * busy-loops at the eprefix copy (sample: dep_export +2380) → hang → tip_after.o
 * 0B / no `_main`. Soft Cap Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twin Cap-aligned with src/asm/backend_call_dispatch.x.
 * g05_relink_env prepends this .o and weakens the broken tip T so the twin wins.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

extern uint8_t *driver_get_current_dep_path_for_codegen(void);
extern void glue_codegen_import_path_to_c_prefix_into(uint8_t *dep_path, uint8_t *prefix,
                                                     int32_t cap);
extern int32_t codegen_c_prefix_redundant_with_name(uint8_t *prefix, int32_t plen, uint8_t *name,
                                                   int32_t name_len);
extern uint8_t *pipeline_asm_emit_dep_pipe_c(void);
extern int32_t xlang_pipeline_pctx_entry_lib_prefix_into(uint8_t *pctx, uint8_t *eprefix,
                                                        int32_t cap);

int32_t glue_asm_build_dep_export_sym_c(uint8_t *name, int32_t name_len, uint8_t *out,
                                       int32_t out_cap) {
  uint8_t *dep_path;
  int32_t pos;
  int32_t dep_live;
  uint8_t prefix[128];
  int32_t plen;
  int32_t i;
  int32_t is_main;
  uint8_t *pctx;
  uint8_t eprefix[128];
  int32_t eplen;
  int32_t ei;
  int32_t j;

  if (!name || name_len <= 0 || !out || out_cap <= 0)
    return -1;

  dep_path = driver_get_current_dep_path_for_codegen();
  pos = 0;
  dep_live = 0;
  if (dep_path != NULL) {
    if (dep_path[0] != 0) {
      dep_live = 1;
      memset(prefix, 0, sizeof prefix);
      glue_codegen_import_path_to_c_prefix_into(dep_path, prefix, 128);
      plen = 0;
      while (plen < 255) {
        if (prefix[plen] == 0)
          break;
        plen = plen + 1;
      }
      if (plen > 0) {
        if (codegen_c_prefix_redundant_with_name(prefix, plen, name, name_len) == 0) {
          i = 0;
          while (i < plen) {
            if (pos >= out_cap - 1)
              break;
            out[pos] = prefix[i];
            pos = pos + 1;
            i = i + 1;
          }
        }
      }
    }
  }

  if (dep_live == 0) {
    is_main = 0;
    if (name_len == 4) {
      if (name[0] == 109 && name[1] == 97 && name[2] == 105 && name[3] == 110)
        is_main = 1;
    }
    if (is_main == 0) {
      pctx = pipeline_asm_emit_dep_pipe_c();
      if (pctx != NULL) {
        memset(eprefix, 0, sizeof eprefix);
        eplen = xlang_pipeline_pctx_entry_lib_prefix_into(pctx, eprefix, 128);
        if (eplen > 0) {
          if (codegen_c_prefix_redundant_with_name(eprefix, eplen, name, name_len) == 0) {
            ei = 0;
            while (ei < eplen) {
              if (pos >= out_cap - 1)
                break;
              out[pos] = eprefix[ei];
              pos = pos + 1;
              ei = ei + 1;
            }
          }
        }
      }
    }
  }

  j = 0;
  while (j < name_len) {
    if (pos >= out_cap - 1)
      break;
    out[pos] = name[j];
    pos = pos + 1;
    j = j + 1;
  }
  if (pos > 0)
    return pos;
  return -1;
}
