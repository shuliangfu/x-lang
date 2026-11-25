/*
 * Host-gcc twin of parser_asm_module_try_register_enum_name_c
 * (pthin_skip_if.x).
 * Root (s48 unofficial hello --check hang after the skip_generic_angle
 *   lea-of-local out-pointer fold): typool first-wins W at 0x1404d2f90
 *   is live. Language walks existing enum sidecar slots:
 *     while (true) {
 *       cur_len = pipeline_module_enum_name_len(module, ei);
 *       if (cur_len <= 0) break;
 *       ... match ...
 *       ei = ei + 1;
 *     }
 * typool compiled `if (cur_len <= 0) break` as:
 *   setle / je match-check / jmp loop-head at +299 / 0x1404d30bb
 * so an empty first slot (cur_len <= 0, ei still 0) jumps back to the
 * loop head instead of falling through to enum_alloc. gdb: 100% CPU in
 * pipeline_module_enum_name_len -> pipe_en_find_slot (i=0..0x7f) ->
 * xlang_ptr_slot_get -> pipe_load_ptr_slot on g_pipe_en_mod.
 * Class: typool miscompiled break-as-continue (same class as s47
 *   parser_onefunc_param_name_dup_c).
 * Fold allowlist: parser_asm_module_try_register_enum_name_c only.
 * Keep the uncommitted s48 JMP typool skip_generic_angle_list_count_into_c
 *   W 0x140451590 -> 0x14a3e2400.
 * Do not fold typool pend BSS, typool w1545_pend_rcx_emit, typool
 *   onefunc_sidecar_get, or formal-ensure.
 * Do not idx8 the .x twin.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

int32_t pipeline_module_enum_name_len(uint8_t *module, int32_t idx);
uint8_t pipeline_module_enum_name_byte_at(uint8_t *module, int32_t idx, int32_t off);
int32_t pipeline_module_enum_alloc(uint8_t *module);
void pipeline_module_enum_set_name(uint8_t *module, int32_t idx, uint8_t *bytes, int32_t len);

int32_t parser_asm_module_try_register_enum_name_c(uint8_t *module, uint8_t *name,
                                                  int32_t name_len) {
  int32_t ei;
  int32_t j;
  int32_t slot;
  int32_t cur_len;
  int32_t eq;
  uint8_t b;

  if (module == 0 || name == 0 || name_len <= 0 || name_len > 255) {
    return -1;
  }
  ei = 0;
  while (1) {
    cur_len = pipeline_module_enum_name_len(module, ei);
    if (cur_len <= 0) {
      break;
    }
    if (cur_len == name_len) {
      eq = 1;
      j = 0;
      while (j < name_len) {
        b = pipeline_module_enum_name_byte_at(module, ei, j);
        if (b != name[j]) {
          eq = 0;
          break;
        }
        j = j + 1;
      }
      if (eq != 0) {
        return ei;
      }
    }
    ei = ei + 1;
  }
  slot = pipeline_module_enum_alloc(module);
  if (slot < 0) {
    return -1;
  }
  pipeline_module_enum_set_name(module, slot, name, name_len);
  return slot;
}
