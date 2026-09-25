/**
 * PLATFORM: SHARED tip — module VAR → local fixed-array let-init.
 *
 * w1024: Cap residual store returns -2 when init is a module VAR (no
 * stack slot). glue_block_body_emit_let_init then maps any non-0 to -1
 * → CG002 (Darwin/Win) or SEGV fallthrough (Ubuntu). Twin of lvalue
 * eff-addr module COMMON lea + CALL-arm E* spill copy.
 * Authority: glue_emit_fixed_array_type_let_init_elf_c first-wins.
 */
#include <stdint.h>

extern int32_t glue_type_is_fixed_array(void *arena, int32_t type_ref);
extern int32_t glue_struct_lit_store_fixed_array_field_elf_c(void *arena, void *elf_ctx,
                                                            int32_t init_ref, void *ctx, int32_t ta,
                                                            int32_t sret_direct, int32_t base_off,
                                                            int32_t foff, int32_t fty);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_asm_emit_lvalue_eff_addr_elf_c(void *arena, void *elf_ctx, int32_t lval,
                                                      void *ctx, int32_t ta);
extern int32_t glue_fixed_array_total_bytes_c(void *arena, int32_t ty_ref, int32_t depth);
extern int32_t pipeline_type_array_size_at(void *a, int32_t ty_ref);
extern int32_t glue_array_lit_force_esz_from_elem_type_c(void *a, int32_t et);
extern int32_t pipeline_type_elem_ref_at(void *a, int32_t ty_ref);
extern int32_t glue_index_elem_byte_sz_from_type_ref_c(void *a, int32_t tr);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t glue_emit_bulk_mem_copy_spills_elf_c(void *elf, int32_t src_spill, int32_t dst_spill,
                                                   int32_t nbytes, int32_t ta);

/**
 * Copy module (or other non-local) fixed-array VAR into a frame slot.
 * @return 0 ok; -1 hard fail.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 · WINDOWS.
 */
static int32_t tip_copy_nonlocal_var_array_to_slot(void *arena, void *elf_ctx, int32_t init_ref,
                                                  void *ctx, int32_t ta, int32_t type_ref,
                                                  int32_t stack_slot_off) {
  int32_t nbytes;
  int32_t n_arr;
  int32_t elem_tr;
  int32_t esz;
  int32_t next_off;
  int32_t src_spill;
  int32_t dst_spill;

  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || type_ref <= 0 || stack_slot_off < 0)
    return -1;
  nbytes = glue_fixed_array_total_bytes_c(arena, type_ref, 0);
  if (nbytes <= 0) {
    n_arr = pipeline_type_array_size_at(arena, type_ref);
    elem_tr = pipeline_type_elem_ref_at(arena, type_ref);
    esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_tr);
    if (esz <= 0)
      esz = glue_index_elem_byte_sz_from_type_ref_c(arena, type_ref);
    if (esz <= 0)
      esz = 4;
    nbytes = n_arr * esz;
  }
  if (nbytes <= 0 || nbytes > 4096)
    return -1;

  /* AsmFuncCtx.next_offset @+4 — same as Cap residual CALL arm. */
  next_off = *(int32_t *)((uint8_t *)ctx + 4);
  if (next_off + 32 < next_off)
    return -1;
  next_off = next_off + 16;
  src_spill = next_off;
  next_off = next_off + 16;
  dst_spill = next_off;
  *(int32_t *)((uint8_t *)ctx + 4) = next_off;

  /* Module/COMMON E* — twin of pipeline_asm_emit_lvalue_eff_addr VAR arm. */
  if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0)
    return -1;
  return glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, nbytes, ta);
}

/**
 * Fixed-array let-init: Cap residual store, then module-VAR fallback.
 * @return 0 ok; -1 hard fail; -2 not a fixed array.
 * PLATFORM: SHARED.
 */
int32_t glue_emit_fixed_array_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                 void *ctx, int32_t ta, int32_t type_ref,
                                                 int32_t stack_slot_off) {
  int32_t st;

  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || type_ref <= 0)
    return -2;
  if (!glue_type_is_fixed_array(arena, type_ref))
    return -2;

  st = glue_struct_lit_store_fixed_array_field_elf_c(arena, elf_ctx, init_ref, ctx, ta, 0,
                                                    stack_slot_off, 0, type_ref);
  if (st == 0 || st == -1)
    return st;

  /* st == -2: module (non-local) VAR — no stack home. PLATFORM: SHARED. */
  if (pipeline_expr_kind_ord_at(arena, init_ref) == 3 &&
      glue_var_expr_stack_off_elf_c(arena, ctx, init_ref) < 0 && stack_slot_off >= 0) {
    if (tip_copy_nonlocal_var_array_to_slot(arena, elf_ctx, init_ref, ctx, ta, type_ref,
                                           stack_slot_off) == 0)
      return 0;
    return -1;
  }
  return st;
}
