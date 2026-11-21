/* Source-faithful glue_asm_build_dep_export_sym_c twin
 * (compiler/src/asm/backend_call_dispatch.x / fromsrc_s72 same body).
 * s143 hello build remaining hang: prefix thin entered at 0.926s from
 * build_dep_export_sym+0x4bb and returned. Six poll samples from
 * 1.305-3.106s sat in typool glue_asm_build_dep_export_sym_c
 * (0x14040c108) at +0x4d6 / +0x4f1 / +0x4f5 / +0x508 / +0x510.
 * Source loop is: let plen: i32 = 0; while (plen < 255) {
 * if (prefix[plen] == 0) { break; } plen = plen + 1; }. typool
 * compiled prefix[plen] as lea of the local u8[128] at [rbp-0xd8]
 * (=0x103f70c8, the prefix thin dst) plus scale-8, and the break as
 * jmp to the loop test at +0x4bf (0x14040c5c7) without incrementing
 * plen. Live: at +0x4f1 plen/rbx=2 and lea address 0x103f70d8
 * (prefix+16); at +0x508/+0x510 rax=1 rbx=0 (loaded low 32 bits 0,
 * treated as NUL). Same typool break-as-jmp-to-head family as
 * s137/s140/s142/s143 and same scale-8 / shallow-lea family as
 * s136/s141/s142/s143. typool uasb_put_i32 was not on this path and
 * was not folded. The later copy loops in this same function were
 * not the live hang and were included only because they live in the
 * proven typool symbol, not as a batch fold of cousins. docs-only .x,
 * do not idx8.
 */
#include <stdint.h>

extern uint8_t *driver_get_current_dep_path_for_codegen(void);
extern void glue_codegen_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap);
extern int32_t codegen_c_prefix_redundant_with_name(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len);
extern uint8_t *pipeline_asm_emit_dep_pipe_c(void);
extern int32_t xlang_pipeline_pctx_entry_lib_prefix_into(uint8_t *ctx, uint8_t *out, int32_t cap);

int32_t glue_asm_build_dep_export_sym_c(uint8_t *name, int32_t name_len, uint8_t *out, int32_t out_cap) {
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
  if (name == 0) {
    return 0 - 1;
  }
  if (name_len <= 0) {
    return 0 - 1;
  }
  if (out == 0) {
    return 0 - 1;
  }
  if (out_cap <= 0) {
    return 0 - 1;
  }
  dep_path = driver_get_current_dep_path_for_codegen();
  pos = 0;
  dep_live = 0;
  if (dep_path != 0) {
    if (dep_path[0] != 0) {
      dep_live = 1;
      for (i = 0; i < 128; i = i + 1) {
        prefix[i] = 0;
      }
      glue_codegen_import_path_to_c_prefix_into(dep_path, &prefix[0], 128);
      plen = 0;
      while (plen < 255) {
        if (prefix[plen] == 0) {
          break;
        }
        plen = plen + 1;
      }
      if (plen > 0) {
        if (codegen_c_prefix_redundant_with_name(&prefix[0], plen, name, name_len) == 0) {
          i = 0;
          while (i < plen) {
            if (pos >= out_cap - 1) {
              break;
            }
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
      if (name[0] == 109 && name[1] == 97 && name[2] == 105 && name[3] == 110) {
        is_main = 1;
      }
    }
    if (is_main == 0) {
      pctx = pipeline_asm_emit_dep_pipe_c();
      if (pctx != 0) {
        for (ei = 0; ei < 128; ei = ei + 1) {
          eprefix[ei] = 0;
        }
        eplen = xlang_pipeline_pctx_entry_lib_prefix_into(pctx, &eprefix[0], 128);
        if (eplen > 0) {
          if (codegen_c_prefix_redundant_with_name(&eprefix[0], eplen, name, name_len) == 0) {
            ei = 0;
            while (ei < eplen) {
              if (pos >= out_cap - 1) {
                break;
              }
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
    if (pos >= out_cap - 1) {
      break;
    }
    out[pos] = name[j];
    pos = pos + 1;
    j = j + 1;
  }
  if (pos > 0) {
    return pos;
  }
  return 0 - 1;
}
