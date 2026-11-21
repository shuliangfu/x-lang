/* Source-faithful glue_codegen_import_path_to_c_prefix_into twin
 * (compiler/src/asm/backend_call_dispatch.x).
 * s142 hello build remaining hang: emit_deps and typool put_i32 both
 * returned; codegen_ast_to_elf entered from emit_deps+0x19c5 at 0.955s.
 * Six poll samples from 1.329-3.130s sat in typool
 * glue_codegen_import_path_to_c_prefix_into (0x1403fed4c) at
 * +0xaf / +0xcb / +0xd6, called from glue_asm_build_dep_export_sym_c+0x4bb,
 * rcx=g_driver_current_dep_path_buf, r8=cap 0x80. typool compiled
 * `let ch: u8 = path[pi]` as shallow-lea of &path plus scale-8, and
 * `if (ch == 0) break;` as jmp to the loop head (0x1403fede1) without
 * incrementing pi or off; live samples also showed the scale-8 lea at
 * +0xaf with pi=7 and the break jmp at +0xd6 with ebx=0 (low 32 bits of
 * a qword load 0xd500000000). Stores `buf[off]=...` were also typool
 * scale-8 through &buf. Same typool break-as-jmp-to-head family as
 * s137/s140/s142 and same scale-8 / shallow-lea family as s136/s141/s142.
 * typool uasb_put_i32 entered twice and returned; it was not folded.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

void glue_codegen_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap) {
  int32_t off;
  int32_t pi;
  uint8_t ch;
  if (buf == 0) {
    return;
  }
  if (buf_cap <= 0) {
    return;
  }
  off = 0;
  pi = 0;
  if (path != 0) {
    while (1 == 1) {
      ch = path[pi];
      if (ch == 0) {
        break;
      }
      if (off + 2 >= buf_cap) {
        break;
      }
      if (ch == 46) {
        buf[off] = 95;
      } else {
        buf[off] = ch;
      }
      off = off + 1;
      pi = pi + 1;
    }
  }
  if (off + 1 < buf_cap) {
    buf[off] = 95;
    off = off + 1;
  }
  if (off < buf_cap) {
    buf[off] = 0;
  }
}
