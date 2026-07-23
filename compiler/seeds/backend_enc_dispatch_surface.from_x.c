/* seeds/backend_enc_dispatch_surface.from_x.c
 * R2 full surface — isomorphic with src/asm/backend_enc_dispatch.x
 * Product PREFER_X_O: g05_try_x_to_o(backend_enc_dispatch.x) + hybrid rest
 *   seeds/backend_enc_dispatch.from_x.c (-DXLANG_BACKEND_ENC_DISPATCH_FROM_X) ld -r
 * R2: full.x 吃满 enc/ta 公共业务；FROM_X rest 仅 slice_marker（业务 H=0）
 * Prove: full.x vs this seed → nm IDENTICAL
 * Regen: ./xlang -E ... src/asm/backend_enc_dispatch.x | filter DBG + polish prologue
 * Track-L (2026-07-16): riscv call/mov_rax_to_arg_reg 对齐 .x #[no_mangle] 短名（去 type-suffix mangle 快照）
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t backend_enc_dispatch_x_doc_anchor(void);
extern int32_t backend_enc_x86_jcc_rel32_c(uint8_t * elf_ctx, uint8_t opcode2, uint8_t * label, int32_t label_len);
extern int32_t backend_enc_append_u32_le_c(uint8_t * elf_ctx, uint32_t word);
extern int32_t backend_enc_arm64_call_c(uint8_t * elf_ctx, uint8_t * name, int32_t name_len);
extern int32_t backend_enc_arm64_add_sp_imm12_c(uint8_t * elf_ctx, int32_t imm);
extern int32_t backend_enc_arm64_sub_sp_imm12_c(uint8_t * elf_ctx, int32_t imm);
extern int32_t backend_enc_arm64_str_x0_sp_offset_c(uint8_t * elf_ctx, int32_t off_bytes);
extern int32_t arm64_enc_load_w0_from_rbp_c(uint8_t * elf_ctx, int32_t offset);
extern int32_t arm64_enc_store_w0_to_rbp_c(uint8_t * elf_ctx, int32_t offset);
extern int32_t backend_enc_label_arch(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t is_func, int32_t ta);
extern int32_t backend_enc_prologue_arch(uint8_t * elf_ctx, int32_t frame_sz, int32_t ta);
extern int32_t backend_enc_epilogue_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_ret_imm32_arch(uint8_t * elf_ctx, int32_t imm32, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(uint8_t * elf_ctx, int32_t imm32, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(uint8_t * elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_push_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_push_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_add_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_sub_rbx_rax_then_mov_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_imul_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_not_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_and_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_or_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_xor_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_ecx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_shl_cl_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_shr_cl_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_sar_cl_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_cltd_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_edx_to_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_neg_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_test_eax_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_test_rbx_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_setz_movzbl_eax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_setcc_movzbl_arch(uint8_t * elf_ctx, int32_t cc, int32_t ta);
extern int32_t backend_enc_cmp_w0_imm12_arch(uint8_t * elf_ctx, int32_t imm12, int32_t ta);
extern int32_t backend_enc_cset_w0_from_cc_arch(uint8_t * elf_ctx, int32_t cc, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale4_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale1_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale8_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_indirect_arch(uint8_t * elf_ctx, int32_t elem_sz, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_add_imm_to_rbx_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_rbp_index_scratch_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(uint8_t * elf_ctx, int32_t offset, int32_t store_size, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_jz_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jeq_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jge_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jnz_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jmp_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(uint8_t * elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta);
extern int32_t backend_enc_store_x_reg_to_rbp_arch(uint8_t * elf_ctx, int32_t reg, int32_t offset, int32_t ta);
extern int32_t backend_enc_jne_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_call_stack_cleanup_arch(uint8_t * elf_ctx, int32_t nbytes, int32_t ta);
extern int32_t backend_enc_call_stack_reserve_arch(uint8_t * elf_ctx, int32_t nbytes, int32_t ta);
extern int32_t backend_enc_store_x0_sp_offset_arch(uint8_t * elf_ctx, int32_t off_bytes, int32_t ta);
extern int32_t backend_enc_index_scratch_add_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_index_scratch_sub_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_index_scratch_rsub_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_rsub_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_add_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_sub_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_index_scratch_mul_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rbx_index_mul_secondary_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_idiv_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_div_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_rem_mod_unsigned_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_load_qword_from_rbx_to_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_load_qword_rbx8_to_rdx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rdx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_rdx_to_arg_reg_arch(uint8_t * elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_mov_arg_reg_to_rax_arch(uint8_t * elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_load_rbp_pos_to_rax_arch(uint8_t * elf_ctx, int32_t off_pos, int32_t ta);
extern int32_t backend_enc_jle_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jl_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_load_32_from_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_load_rbp_lane_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t esz, int32_t ta);
extern int32_t backend_enc_load_rbp_lane_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t esz, int32_t ta);
extern int32_t backend_enc_load_x29_pos_to_rax_arch(uint8_t * elf_ctx, int32_t off_pos, int32_t ta);
extern int32_t backend_enc_rbx_plus_index_scratch_scaled_arch(uint8_t * elf_ctx, int32_t esz, int32_t ta);
extern int32_t backend_enc_add_imm_to_index_scratch_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_sub_imm_from_index_scratch_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_add_imm_to_rbx_index_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_sub_imm_from_rbx_index_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_rbp_index_secondary_scratch_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mul_imm_to_index_scratch_arch(uint8_t * elf_ctx, int32_t lit, int32_t ta);
extern int32_t backend_enc_mul_imm_to_rbx_arch(uint8_t * elf_ctx, int32_t lit, int32_t ta);
extern int32_t backend_enc_addss_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsd2ss_eax_from_f64_bits_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(uint8_t * elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(uint8_t * elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(uint8_t * elf_ctx, int32_t k, int32_t ta);
extern int32_t arch_arm64_enc_enc_cmp_w0_imm12(uint8_t * elf_ctx, int32_t imm12);
extern int32_t arch_arm64_enc_enc_cset_w0_from_cc(uint8_t * elf_ctx, int32_t cc);
extern int32_t arch_arm64_enc_enc_add_sp_imm12(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_sub_sp_imm12(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_str_x0_sp_offset(uint8_t * elf_ctx, int32_t off_bytes);
extern int32_t arch_arm64_enc_enc_call(uint8_t * elf_ctx, uint8_t * name, int32_t name_len);
extern int32_t arch_riscv64_enc_enc_call(uint8_t * elf_ctx, uint8_t * name, int32_t name_len);
extern int32_t arch_riscv64_enc_enc_mov_rax_to_arg_reg(uint8_t * elf_ctx, int32_t k);
extern int32_t backend_enc_append_u8_c(uint8_t * elf_ctx, int32_t byte);
extern int32_t arch_x86_64_enc_enc_cdqe_rax(uint8_t * elf_ctx);
int32_t backend_enc_dispatch_x_doc_anchor(void) {
  return 0;
}
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t * ctx, uint8_t * ptr, int32_t n);
extern int32_t pipeline_elf_ctx_emit_code_len(uint8_t * ctx);
extern int32_t pipeline_elf_ctx_ensure_label(uint8_t * ctx, uint8_t * name, int32_t name_len);
extern int32_t pipeline_elf_ctx_append_patch(uint8_t * ctx, int32_t rel32_offset, uint8_t * name, int32_t name_len, int32_t imm_bits);
extern int32_t pipeline_elf_ctx_append_reloc(uint8_t * ctx, int32_t at, uint8_t * name, int32_t name_len);
extern int32_t arch_arm64_enc_enc_u32_le(uint8_t * elf_ctx, int32_t word);
int32_t backend_enc_x86_jcc_rel32_c(uint8_t * elf_ctx, uint8_t opcode2, uint8_t * label, int32_t label_len) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((label ==0)) {
    return (0 - 1);
  }
  if ((label_len <=0)) {
    return (0 - 1);
  }
  uint8_t b0 = 15;
  uint8_t b1 = opcode2;
  uint8_t z = 0;
  {
    int32_t rel32_at = (pipeline_elf_ctx_emit_code_len(elf_ctx) - 4);
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(b0), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(b1), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(z), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(z), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(z), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(z), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_ensure_label(elf_ctx, label, label_len) !=0)) {
      return (0 - 1);
    }
    return pipeline_elf_ctx_append_patch(elf_ctx, rel32_at, label, label_len, 32);
  }
  return (0 - 1);
}
int32_t backend_enc_append_u32_le_c(uint8_t * elf_ctx, uint32_t word) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  uint8_t b0 = ((uint8_t)((word & 255)));
  uint8_t b1 = ((uint8_t)(((word / 256) & 255)));
  uint8_t b2 = ((uint8_t)(((word / 65536) & 255)));
  uint8_t b3 = ((uint8_t)(((word / 16777216) & 255)));
  {
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(b0), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(b1), 1) !=0)) {
      return (0 - 1);
    }
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &(b2), 1) !=0)) {
      return (0 - 1);
    }
    return pipeline_elf_ctx_append_bytes(elf_ctx, &(b3), 1);
  }
  return (0 - 1);
}
int32_t backend_enc_arm64_call_c(uint8_t * elf_ctx, uint8_t * name, int32_t name_len) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((name ==0)) {
    return (0 - 1);
  }
  if ((name_len <=0)) {
    return (0 - 1);
  }
  {
    int32_t at = (pipeline_elf_ctx_emit_code_len(elf_ctx) - 4);
    int32_t m = 256;
    int32_t macho = ((int32_t)((elf_ctx)[598052]));
    if ((backend_enc_append_u32_le_c(elf_ctx, -1811939328) !=0)) {
      return (0 - 1);
    }
    if ((at < 0)) {
      return (0 - 1);
    }
    (void)((macho = (macho + (((int32_t)((elf_ctx)[598053])) * m))));
    (void)((macho = (macho + (((int32_t)((elf_ctx)[598054])) * (m * m)))));
    (void)((macho = (macho + (((int32_t)((elf_ctx)[598055])) * ((m * m) * m)))));
    if ((macho !=0)) {
      if ((name_len <=63)) {
        if (((name)[0] !=95)) {
          uint8_t reloc_name[64] = {};
          (void)(((reloc_name)[0] = 95));
          int32_t i = 0;
          while ((i < name_len)) {
            if ((i >=63)) {
              break;
            }
            (void)(((reloc_name)[(i + 1)] = (name)[i]));
            (void)((i = (i + 1)));
          }
          int32_t reloc_len = (name_len + 1);
          return pipeline_elf_ctx_append_reloc(elf_ctx, at, &((reloc_name)[0]), reloc_len);
        }
      }
    }
    return pipeline_elf_ctx_append_reloc(elf_ctx, at, name, name_len);
  }
  return (0 - 1);
}
int32_t backend_enc_arm64_add_sp_imm12_c(uint8_t * elf_ctx, int32_t imm) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((imm <=0)) {
    return 0;
  }
  if ((imm > 4095)) {
    return backend_enc_append_u32_le_c(elf_ctx, (-1862269953 | (4095 * 1024)));
  }
  return backend_enc_append_u32_le_c(elf_ctx, (-1862269953 | (((uint32_t)(imm)) * 1024)));
}
int32_t backend_enc_arm64_sub_sp_imm12_c(uint8_t * elf_ctx, int32_t imm) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((imm <=0)) {
    return 0;
  }
  if ((imm > 4095)) {
    return backend_enc_append_u32_le_c(elf_ctx, (-788528129 | (4095 * 1024)));
  }
  return backend_enc_append_u32_le_c(elf_ctx, (-788528129 | (((uint32_t)(imm)) * 1024)));
}
int32_t backend_enc_arm64_str_x0_sp_offset_c(uint8_t * elf_ctx, int32_t off_bytes) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((off_bytes < 0)) {
    return backend_enc_append_u32_le_c(elf_ctx, -117439520);
  }
  if (((off_bytes / 8) > 4095)) {
    return backend_enc_append_u32_le_c(elf_ctx, (-117439520 | (4095 * 1024)));
  }
  return backend_enc_append_u32_le_c(elf_ctx, (-117439520 | (((uint32_t)((off_bytes / 8))) * 1024)));
}
int32_t arm64_enc_load_w0_from_rbp_c(uint8_t * elf_ctx, int32_t offset) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((offset < 0)) {
    return (0 - 1);
  }
  if ((offset > 256)) {
    {
      return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)(((-1203765248 | (256 * 4096)) | 928))));
    }
    return (0 - 1);
  }
  {
    int32_t u9 = ((0 - offset) & 511);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)(((-1203765248 | (((uint32_t)(u9)) * 4096)) | 928))));
  }
  return (0 - 1);
}
int32_t arm64_enc_store_w0_to_rbp_c(uint8_t * elf_ctx, int32_t offset) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((offset < 0)) {
    return (0 - 1);
  }
  if ((offset > 256)) {
    {
      return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)(((-1207959552 | (256 * 4096)) | 928))));
    }
    return (0 - 1);
  }
  {
    int32_t u9 = ((0 - offset) & 511);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)(((-1207959552 | (((uint32_t)(u9)) * 4096)) | 928))));
  }
  return (0 - 1);
}
extern int32_t arch_arm64_enc_enc_add_imm_to_rax(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_add_imm_to_rbx(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_arm64_enc_enc_add_rax_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_and_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_cltd(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_cmp_rax_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_cmp_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_cmp_setcc_movzbl(uint8_t * elf_ctx, int32_t cc);
extern int32_t pipeline_asm_arm64_cset_cond_enc_from_cc(int32_t cc);
extern int32_t arch_arm64_enc_enc_epilogue(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_imul_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_jeq(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jge(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jmp(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jnz(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_jz(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_label(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t is_func);
extern int32_t arch_arm64_enc_enc_lea_rbp_to_rax(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_lea_rbp_to_rbx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_load_64_from_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_load_rbp_to_rax(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_load_rbp_to_x2(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_load_zext8_from_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_edx_to_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_imm32_to_rbx(uint8_t * elf_ctx, int32_t imm32);
extern int32_t arch_arm64_enc_enc_mov_imm64_to_rax(uint8_t * elf_ctx, int32_t lo, int32_t hi);
extern int32_t arch_arm64_enc_enc_mov_rax_to_arg_reg(uint8_t * elf_ctx, int32_t k);
extern int32_t arch_arm64_enc_enc_mov_rax_to_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_ecx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rbx_to_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_neg_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_not_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_or_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_pop_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_pop_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_prologue(uint8_t * elf_ctx, int32_t frame_sz);
extern int32_t arch_arm64_enc_enc_push_rax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_push_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_rax_plus_rbx_scale1(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_rax_plus_rbx_scale4(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_rax_plus_rbx_scale8(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_ret_imm32(uint8_t * elf_ctx, int32_t imm32);
extern int32_t arch_arm64_enc_enc_sar_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_setz_movzbl_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_shl_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_shr_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_store_rax_to_rbp(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_store_rax_to_rbx_indirect(uint8_t * elf_ctx, int32_t elem_sz);
extern int32_t arch_arm64_enc_enc_store_rax_to_rbx_offset(uint8_t * elf_ctx, int32_t offset, int32_t store_size);
extern int32_t arch_arm64_enc_enc_sub_rax_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_sub_rbx_rax_then_mov(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_test_eax_eax(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_test_rbx_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_xor_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_add_imm_to_rax(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_add_imm_to_rbx(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_add_rax_rbx(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_and_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_call(uint8_t * elf_ctx, uint8_t * name, int32_t name_len);
extern int32_t arch_riscv64_enc_enc_cltd(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_cmp_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_cmp_setcc_movzbl(uint8_t * elf_ctx, int32_t cc);
extern int32_t arch_riscv64_enc_enc_epilogue(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_imul_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_jeq(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jge(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jmp(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jnz(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_jz(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_riscv64_enc_enc_label(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t is_func);
extern int32_t arch_riscv64_enc_enc_lea_rbp_to_rax(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_lea_rbp_to_rbx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_load_64_from_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_a2(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_rax(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_load_zext8_from_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_edx_to_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_imm32_to_rbx(uint8_t * elf_ctx, int32_t imm32);
extern int32_t arch_riscv64_enc_enc_mov_imm64_to_rax(uint8_t * elf_ctx, int32_t lo, int32_t hi);
extern int32_t arch_riscv64_enc_enc_mov_rax_to_arg_reg(uint8_t * elf_ctx, int32_t k);
extern int32_t arch_riscv64_enc_enc_mov_rax_to_rbx(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_rbx_to_ecx(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_mov_rbx_to_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_neg_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_not_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_or_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_pop_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_pop_rbx(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_prologue(uint8_t * elf_ctx, int32_t frame_sz);
extern int32_t arch_riscv64_enc_enc_push_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_push_rbx(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rax_plus_rbx_scale1(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rax_plus_rbx_scale4(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rax_plus_rbx_scale8(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_ret_imm32(uint8_t * elf_ctx, int32_t imm32);
extern int32_t arch_riscv64_enc_enc_sar_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_setz_movzbl_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_shl_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_shr_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_store_rax_to_rbp(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_store_rax_to_rbx_indirect(uint8_t * elf_ctx, int32_t elem_sz);
extern int32_t arch_riscv64_enc_enc_store_rax_to_rbx_offset(uint8_t * elf_ctx, int32_t offset, int32_t store_size);
extern int32_t arch_riscv64_enc_enc_sub_rbx_rax_then_mov(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_test_eax_eax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_test_rbx_rbx(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_xor_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_imm_to_rax(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_add_imm_to_rbx(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_add_rax_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_and_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_call(uint8_t * elf_ctx, uint8_t * name, int32_t name_len);
extern int32_t arch_x86_64_enc_enc_cltd(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_cmp_rax_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_cmp_eax_imm32(uint8_t * elf_ctx, int32_t imm32);
extern int32_t arch_x86_64_enc_enc_cmp_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_cmp_setcc_movzbl(uint8_t * elf_ctx, int32_t cc);
extern int32_t arch_x86_64_enc_enc_epilogue(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_imul_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_jeq(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jge(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jmp(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jnz(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_jz(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_x86_64_enc_enc_label(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t is_func);
extern int32_t arch_x86_64_enc_enc_lea_rbp_to_rax(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_lea_rbp_to_rbx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_64_from_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_ecx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_rax(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_zext8_from_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_edx_to_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_imm32_to_rbx(uint8_t * elf_ctx, int32_t imm32);
extern int32_t arch_x86_64_enc_enc_mov_imm64_to_rax(uint8_t * elf_ctx, int32_t lo, int32_t hi);
extern int32_t arch_x86_64_enc_enc_mov_rax_to_arg_reg(uint8_t * elf_ctx, int32_t k);
extern int32_t arch_x86_64_enc_enc_mov_rax_to_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_rbx_to_ecx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_mov_rbx_to_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_neg_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_not_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_or_rbx_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_pop_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_pop_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_prologue(uint8_t * elf_ctx, int32_t frame_sz);
extern int32_t arch_x86_64_enc_enc_push_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_push_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale1(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale4(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_rax_plus_rbx_scale8(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_ret_imm32(uint8_t * elf_ctx, int32_t imm32);
extern int32_t arch_x86_64_enc_enc_sar_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_sar_cl_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_setz_movzbl_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_shl_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_shl_cl_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_shr_cl_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_shr_cl_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_store_rax_to_rbp(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_store_rax_to_rbx_indirect(uint8_t * elf_ctx, int32_t elem_sz);
extern int32_t arch_x86_64_enc_enc_store_rax_to_rbx_offset(uint8_t * elf_ctx, int32_t offset, int32_t store_size);
extern int32_t arch_x86_64_enc_enc_sub_rax_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_sub_rbx_rax_then_mov(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_test_eax_eax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_test_rbx_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_xor_rbx_rax(uint8_t * elf_ctx);
int32_t backend_enc_label_arch(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t is_func, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_label(elf_ctx, name, name_len, is_func);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_label(elf_ctx, name, name_len, is_func);
  }
  return arch_x86_64_enc_enc_label(elf_ctx, name, name_len, is_func);
}
int32_t backend_enc_prologue_arch(uint8_t * elf_ctx, int32_t frame_sz, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_prologue(elf_ctx, frame_sz);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_prologue(elf_ctx, frame_sz);
  }
  return arch_x86_64_enc_enc_prologue(elf_ctx, frame_sz);
}
int32_t backend_enc_epilogue_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_epilogue(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_epilogue(elf_ctx);
  }
  return arch_x86_64_enc_enc_epilogue(elf_ctx);
}
int32_t backend_enc_ret_imm32_arch(uint8_t * elf_ctx, int32_t imm32, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_ret_imm32(elf_ctx, imm32);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32);
  }
  return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32);
}
int32_t backend_enc_mov_imm32_to_rbx_arch(uint8_t * elf_ctx, int32_t imm32, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
  }
  return arch_x86_64_enc_enc_mov_imm32_to_rbx(elf_ctx, imm32);
}
int32_t backend_enc_mov_imm64_to_rax_arch(uint8_t * elf_ctx, int32_t lo, int32_t hi, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
  }
  return arch_x86_64_enc_enc_mov_imm64_to_rax(elf_ctx, lo, hi);
}
int32_t backend_enc_push_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_push_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_push_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_push_rax(elf_ctx);
}
int32_t backend_enc_push_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_push_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_push_rbx(elf_ctx);
  }
  return arch_x86_64_enc_enc_push_rbx(elf_ctx);
}
int32_t backend_enc_pop_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_pop_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_pop_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_pop_rax(elf_ctx);
}
int32_t backend_enc_pop_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_pop_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_pop_rbx(elf_ctx);
  }
  return arch_x86_64_enc_enc_pop_rbx(elf_ctx);
}
int32_t backend_enc_add_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_add_rax_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_rax_rbx(elf_ctx);
  }
  return arch_x86_64_enc_enc_add_rax_rbx(elf_ctx);
}
int32_t backend_enc_sub_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_sub_rax_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return -(1);
  }
  return arch_x86_64_enc_enc_sub_rax_rbx(elf_ctx);
}
int32_t backend_enc_sub_rbx_rax_then_mov_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
  }
  return arch_x86_64_enc_enc_sub_rbx_rax_then_mov(elf_ctx);
}
int32_t backend_enc_imul_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_imul_rbx_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_imul_rbx_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_imul_rbx_rax(elf_ctx);
}
int32_t backend_enc_mov_rax_to_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_mov_rax_to_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mov_rax_to_rbx(elf_ctx);
  }
  return arch_x86_64_enc_enc_mov_rax_to_rbx(elf_ctx);
}
int32_t backend_enc_not_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_not_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_not_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_not_eax(elf_ctx);
}
int32_t backend_enc_and_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_and_rbx_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_and_rbx_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_and_rbx_rax(elf_ctx);
}
int32_t backend_enc_or_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_or_rbx_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_or_rbx_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_or_rbx_rax(elf_ctx);
}
int32_t backend_enc_xor_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_xor_rbx_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_xor_rbx_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_xor_rbx_rax(elf_ctx);
}
int32_t backend_enc_mov_rbx_to_ecx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_mov_rbx_to_ecx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mov_rbx_to_ecx(elf_ctx);
  }
  return arch_x86_64_enc_enc_mov_rbx_to_ecx(elf_ctx);
}
int32_t backend_enc_shl_cl_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_shl_cl_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_shl_cl_eax(elf_ctx);
}
int32_t backend_enc_shr_cl_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_shr_cl_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_shr_cl_eax(elf_ctx);
}
int32_t backend_enc_sar_cl_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_sar_cl_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_sar_cl_eax(elf_ctx);
}
int32_t backend_enc_shl_cl_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_shl_cl_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_shl_cl_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_shl_cl_rax(elf_ctx);
}
int32_t backend_enc_shr_cl_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_shr_cl_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_shr_cl_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_shr_cl_rax(elf_ctx);
}
int32_t backend_enc_sar_cl_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_sar_cl_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_sar_cl_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_sar_cl_rax(elf_ctx);
}
int32_t backend_enc_cltd_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_cltd(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_cltd(elf_ctx);
  }
  return arch_x86_64_enc_enc_cltd(elf_ctx);
}
int32_t backend_enc_mov_edx_to_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_mov_edx_to_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mov_edx_to_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_mov_edx_to_eax(elf_ctx);
}
int32_t backend_enc_neg_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_neg_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_neg_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_neg_eax(elf_ctx);
}
int32_t backend_enc_test_eax_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_test_eax_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_test_eax_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_test_eax_eax(elf_ctx);
}
int32_t backend_enc_test_rbx_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_test_rbx_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_test_rbx_rbx(elf_ctx);
  }
  return arch_x86_64_enc_enc_test_rbx_rbx(elf_ctx);
}
int32_t backend_enc_setz_movzbl_eax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_setz_movzbl_eax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_setz_movzbl_eax(elf_ctx);
  }
  return arch_x86_64_enc_enc_setz_movzbl_eax(elf_ctx);
}
int32_t backend_enc_cmp_rbx_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_cmp_rbx_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_cmp_rbx_rax(elf_ctx);
}
int32_t backend_enc_cmp_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_cmp_rax_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return -(1);
  }
  return arch_x86_64_enc_enc_cmp_rax_rbx(elf_ctx);
}
int32_t backend_enc_cmp_setcc_movzbl_arch(uint8_t * elf_ctx, int32_t cc, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
  }
  return arch_x86_64_enc_enc_cmp_setcc_movzbl(elf_ctx, cc);
}
int32_t backend_enc_cmp_w0_imm12_arch(uint8_t * elf_ctx, int32_t imm12, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_cmp_w0_imm12(elf_ctx, imm12);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_cmp_rbx_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_cmp_eax_imm32(elf_ctx, imm12);
}
int32_t backend_enc_cset_w0_from_cc_arch(uint8_t * elf_ctx, int32_t cc, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_cset_w0_from_cc(elf_ctx, cc);
  }
  return backend_enc_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
}
int32_t backend_enc_store_rax_to_rbp_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
  }
  return arch_x86_64_enc_enc_store_rax_to_rbp(elf_ctx, offset);
}
int32_t backend_enc_load_rbp_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
  }
  return arch_x86_64_enc_enc_load_rbp_to_rax(elf_ctx, offset);
}
int32_t backend_enc_lea_rbp_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
  }
  return arch_x86_64_enc_enc_lea_rbp_to_rax(elf_ctx, offset);
}
int32_t backend_enc_lea_rbp_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
  }
  return arch_x86_64_enc_enc_lea_rbp_to_rbx(elf_ctx, offset);
}
int32_t backend_enc_rax_plus_rbx_scale4_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
  }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale4(elf_ctx);
}
int32_t backend_enc_rax_plus_rbx_scale1_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
  }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale1(elf_ctx);
}
int32_t backend_enc_rax_plus_rbx_scale8_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
  }
  return arch_x86_64_enc_enc_rax_plus_rbx_scale8(elf_ctx);
}
int32_t backend_enc_store_rax_to_rbx_indirect_arch(uint8_t * elf_ctx, int32_t elem_sz, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
  }
  return arch_x86_64_enc_enc_store_rax_to_rbx_indirect(elf_ctx, elem_sz);
}
int32_t backend_enc_load_zext8_from_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_load_zext8_from_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_load_zext8_from_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_load_zext8_from_rax(elf_ctx);
}
int32_t backend_enc_add_imm_to_rax_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_add_imm_to_rax(elf_ctx, imm);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_imm_to_rax(elf_ctx, imm);
  }
  return arch_x86_64_enc_enc_add_imm_to_rax(elf_ctx, imm);
}
int32_t backend_enc_add_imm_to_rbx_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  }
  return arch_x86_64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
}
int32_t backend_enc_load_rbp_index_scratch_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_load_rbp_to_x2(elf_ctx, offset);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_load_rbp_to_a2(elf_ctx, offset);
  }
  return arch_x86_64_enc_enc_load_rbp_to_ecx(elf_ctx, offset);
}
int32_t backend_enc_load_64_from_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_load_64_from_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_load_64_from_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_load_64_from_rax(elf_ctx);
}
int32_t backend_enc_store_rax_to_rbx_offset_arch(uint8_t * elf_ctx, int32_t offset, int32_t store_size, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
  }
  return arch_x86_64_enc_enc_store_rax_to_rbx_offset(elf_ctx, offset, store_size);
}
int32_t backend_enc_mov_rbx_to_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_mov_rbx_to_rax(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mov_rbx_to_rax(elf_ctx);
  }
  return arch_x86_64_enc_enc_mov_rbx_to_rax(elf_ctx);
}
int32_t backend_enc_jz_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_jz(elf_ctx, label, label_len);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_jz(elf_ctx, label, label_len);
  }
  return arch_x86_64_enc_enc_jz(elf_ctx, label, label_len);
}
int32_t backend_enc_jeq_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_jeq(elf_ctx, label, label_len);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_jeq(elf_ctx, label, label_len);
  }
  return arch_x86_64_enc_enc_jeq(elf_ctx, label, label_len);
}
int32_t backend_enc_jge_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_jge(elf_ctx, label, label_len);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_jge(elf_ctx, label, label_len);
  }
  return arch_x86_64_enc_enc_jge(elf_ctx, label, label_len);
}
int32_t backend_enc_jnz_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_jnz(elf_ctx, label, label_len);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_jnz(elf_ctx, label, label_len);
  }
  return arch_x86_64_enc_enc_jnz(elf_ctx, label, label_len);
}
int32_t backend_enc_jmp_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_jmp(elf_ctx, label, label_len);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_jmp(elf_ctx, label, label_len);
  }
  return arch_x86_64_enc_enc_jmp(elf_ctx, label, label_len);
}
int32_t backend_enc_mov_rax_to_arg_reg_arch(uint8_t * elf_ctx, int32_t k, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
  }
  return arch_x86_64_enc_enc_mov_rax_to_arg_reg(elf_ctx, k);
}
int32_t backend_enc_call_arch(uint8_t * elf_ctx, uint8_t * name, int32_t name_len, int32_t ta) {
  if ((ta ==1)) {
    return backend_enc_arm64_call_c(elf_ctx, name, name_len);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_call(elf_ctx, name, name_len);
  }
  return arch_x86_64_enc_enc_call(elf_ctx, name, name_len);
}
extern int32_t arch_arm64_enc_enc_idiv_rbx(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_jne(uint8_t * elf_ctx, uint8_t * label, int32_t label_len);
extern int32_t arch_arm64_enc_enc_store_x_reg_to_rbp(uint8_t * elf_ctx, int32_t reg, int32_t offset);
extern int32_t arch_riscv64_enc_enc_add_a2_a3(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_add_rbx_a3(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_add_sp_imm12(uint8_t * elf_ctx, int32_t nbytes);
extern int32_t arch_riscv64_enc_enc_idiv_rbx(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_mul_a2_a3(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_mul_rbx_a3(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rsub_a2_a3(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rsub_rbx_a3(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_sub_a2_a3(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_sub_rbx_a3(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_ebx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_ecx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_add_rsp_imm(uint8_t * elf_ctx, int32_t nbytes);
extern int32_t arch_x86_64_enc_enc_div_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_idiv_rbx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_imul_ebx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_imul_ecx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_rsub_ebx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_rsub_ecx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_sub_ebx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_sub_ecx_edx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_xor_edx_edx(uint8_t * elf_ctx);
int32_t backend_enc_store_x_reg_to_rbp_arch(uint8_t * elf_ctx, int32_t reg, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_store_x_reg_to_rbp(elf_ctx, reg, offset);
  }
  return (0 - 1);
}
int32_t backend_enc_jne_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_jne(elf_ctx, label, label_len);
  }
  return backend_enc_jnz_arch(elf_ctx, label, label_len, ta);
}
int32_t backend_enc_call_stack_cleanup_arch(uint8_t * elf_ctx, int32_t nbytes, int32_t ta) {
  if ((nbytes <=0)) {
    return 0;
  }
  if ((ta ==1)) {
    return backend_enc_arm64_add_sp_imm12_c(elf_ctx, nbytes);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_sp_imm12(elf_ctx, nbytes);
  }
  return arch_x86_64_enc_enc_add_rsp_imm(elf_ctx, nbytes);
}
int32_t backend_enc_call_stack_reserve_arch(uint8_t * elf_ctx, int32_t nbytes, int32_t ta) {
  if ((nbytes <=0)) {
    return 0;
  }
  if ((ta ==1)) {
    return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, nbytes);
  }
  return 0;
}
int32_t backend_enc_store_x0_sp_offset_arch(uint8_t * elf_ctx, int32_t off_bytes, int32_t ta) {
  if ((ta ==1)) {
    return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes);
  }
  return (0 - 1);
}
int32_t backend_enc_index_scratch_add_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 184746050);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_a2_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_add_ecx_edx(elf_ctx);
}
int32_t backend_enc_index_scratch_sub_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 1258487874);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_sub_a2_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_sub_ecx_edx(elf_ctx);
}
int32_t backend_enc_index_scratch_rsub_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 1258422370);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_rsub_a2_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_rsub_ecx_edx(elf_ctx);
}
int32_t backend_enc_rbx_index_rsub_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 1258356833);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_rsub_rbx_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_rsub_ebx_edx(elf_ctx);
}
int32_t backend_enc_rbx_index_add_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 184746017);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_rbx_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_add_ebx_edx(elf_ctx);
}
int32_t backend_enc_rbx_index_sub_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 1258487841);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_sub_rbx_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_sub_ebx_edx(elf_ctx);
}
int32_t backend_enc_index_scratch_mul_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mul_a2_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_imul_ecx_edx(elf_ctx);
}
int32_t backend_enc_rbx_index_mul_secondary_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mul_rbx_a3(elf_ctx);
  }
  return arch_x86_64_enc_enc_imul_ebx_edx(elf_ctx);
}
int32_t backend_enc_idiv_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_idiv_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_idiv_rbx(elf_ctx);
  }
  if ((arch_x86_64_enc_enc_cltd(elf_ctx) !=0)) {
    return (0 - 1);
  }
  return arch_x86_64_enc_enc_idiv_rbx(elf_ctx);
}
int32_t backend_enc_div_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_idiv_rbx(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_idiv_rbx(elf_ctx);
  }
  if ((arch_x86_64_enc_enc_xor_edx_edx(elf_ctx) !=0)) {
    return (0 - 1);
  }
  return arch_x86_64_enc_enc_div_rbx(elf_ctx);
}
int32_t backend_enc_rem_mod_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
  }
  if ((backend_enc_cltd_arch(elf_ctx, ta) !=0)) {
    return (0 - 1);
  }
  if ((backend_enc_idiv_rbx_arch(elf_ctx, ta) !=0)) {
    return (0 - 1);
  }
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}
int32_t backend_enc_rem_mod_unsigned_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
  }
  if ((backend_enc_div_rbx_arch(elf_ctx, ta) !=0)) {
    return (0 - 1);
  }
  return backend_enc_mov_edx_to_eax_arch(elf_ctx, ta);
}
extern int32_t arch_x86_64_enc_enc_store_rdx_to_rbp(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_rdx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_mov_rdx_to_arg_reg(uint8_t * elf_ctx, int32_t k);
extern int32_t arch_x86_64_enc_enc_mov_arg_reg_to_rax(uint8_t * elf_ctx, int32_t k);
extern int32_t arch_x86_64_enc_enc_load_rbp_pos_to_rax(uint8_t * elf_ctx, int32_t off_pos);
extern int32_t arch_arm64_enc_enc_load_32_from_rax(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_load_32_from_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_32_from_rax(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_eax32(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_ebx32(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_load_rbp_to_rbx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_rbx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_arm64_enc_enc_rbx_plus_x2_scale1(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_rbx_plus_x2_scale4(uint8_t * elf_ctx);
extern int32_t arch_arm64_enc_enc_rbx_plus_x2_scale8(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rbx_plus_a2_scale1(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rbx_plus_a2_scale4(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_rbx_plus_a2_scale8(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(uint8_t * elf_ctx);
extern int32_t arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(uint8_t * elf_ctx);
extern int32_t arch_riscv64_enc_enc_add_imm_to_a2(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_add_imm_to_ecx(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_sub_imm_from_a2(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_sub_imm_from_ecx(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_add_imm_to_ebx_index(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_sub_imm_from_rbx_index(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_x86_64_enc_enc_sub_imm_from_ebx_index(uint8_t * elf_ctx, int32_t imm);
extern int32_t arch_riscv64_enc_enc_load_rbp_to_a3(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_x86_64_enc_enc_load_rbp_to_edx(uint8_t * elf_ctx, int32_t offset);
extern int32_t arch_riscv64_enc_enc_mul_imm_to_a2(uint8_t * elf_ctx, int32_t lit);
extern int32_t arch_x86_64_enc_enc_imul_imm_to_ecx(uint8_t * elf_ctx, int32_t lit);
extern int32_t arch_riscv64_enc_enc_mul_imm_to_rbx(uint8_t * elf_ctx, int32_t lit);
extern int32_t arch_x86_64_enc_enc_imul_imm_to_ebx(uint8_t * elf_ctx, int32_t lit);
int32_t backend_enc_store_rdx_to_rbp_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  return arch_x86_64_enc_enc_store_rdx_to_rbp(elf_ctx, offset);
}
int32_t backend_enc_load_qword_from_rbx_to_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  return arch_x86_64_enc_enc_load_qword_from_rbx_to_rax(elf_ctx);
}
int32_t backend_enc_load_qword_rbx8_to_rdx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  return arch_x86_64_enc_enc_load_qword_rbx8_to_rdx(elf_ctx);
}
int32_t backend_enc_load_rbp_to_rdx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  return arch_x86_64_enc_enc_load_rbp_to_rdx(elf_ctx, offset);
}
int32_t backend_enc_mov_rdx_to_arg_reg_arch(uint8_t * elf_ctx, int32_t k, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  return arch_x86_64_enc_enc_mov_rdx_to_arg_reg(elf_ctx, k);
}
int32_t backend_enc_mov_arg_reg_to_rax_arch(uint8_t * elf_ctx, int32_t k, int32_t ta) {
  if ((ta ==0)) {
    return arch_x86_64_enc_enc_mov_arg_reg_to_rax(elf_ctx, k);
  }
  return (0 - 1);
}
int32_t backend_enc_load_rbp_pos_to_rax_arch(uint8_t * elf_ctx, int32_t off_pos, int32_t ta) {
  if ((ta ==0)) {
    return arch_x86_64_enc_enc_load_rbp_pos_to_rax(elf_ctx, off_pos);
  }
  return (0 - 1);
}
int32_t backend_enc_jle_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 142, label, label_len);
}
int32_t backend_enc_jl_arch(uint8_t * elf_ctx, uint8_t * label, int32_t label_len, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  return backend_enc_x86_jcc_rel32_c(elf_ctx, 140, label, label_len);
}
int32_t backend_enc_load_32_from_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta ==1)) {
    if ((arch_arm64_enc_enc_load_32_from_rax(elf_ctx) !=0)) {
      return (0 - 1);
    }
    return 0;
  }
  if ((ta ==2)) {
    if ((arch_riscv64_enc_enc_load_32_from_rax(elf_ctx) !=0)) {
      return (0 - 1);
    }
    return 0;
  }
  if ((arch_x86_64_enc_enc_load_32_from_rax(elf_ctx) !=0)) {
    return (0 - 1);
  }
  return 0;
}
int32_t backend_enc_load_i32_indirect_to_rax_arch(uint8_t * elf_ctx, int32_t ta) {
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}
int32_t backend_enc_load_rbp_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arch_arm64_enc_enc_load_rbp_to_rbx(elf_ctx, offset);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_load_rbp_to_rbx(elf_ctx, offset);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    int32_t disp = (0 - offset);
    uint32_t u = ((uint32_t)(disp));
    uint8_t b[7] = {};
    if ((disp >=(0 - 128))) {
      if ((disp <=(0 - 1))) {
        (void)(((b)[0] = 72));
        (void)(((b)[1] = 139));
        (void)(((b)[2] = 93));
        (void)(((b)[3] = ((uint8_t)((u & 255)))));
        return pipeline_elf_ctx_append_bytes(elf_ctx, &((b)[0]), 4);
      }
    }
    (void)(((b)[0] = 72));
    (void)(((b)[1] = 139));
    (void)(((b)[2] = 157));
    (void)(((b)[3] = ((uint8_t)((u & 255)))));
    (void)(((b)[4] = ((uint8_t)(((u / 256) & 255)))));
    (void)(((b)[5] = ((uint8_t)(((u / 65536) & 255)))));
    (void)(((b)[6] = ((uint8_t)(((u / 16777216) & 255)))));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &((b)[0]), 7);
  }
  return (0 - 1);
}
int32_t backend_enc_store_eax_to_rbp_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    return arm64_enc_store_w0_to_rbp_c(elf_ctx, offset);
  }
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    int32_t disp = (0 - offset);
    uint32_t u = ((uint32_t)(disp));
    uint8_t b[7] = {};
    if ((disp >=(0 - 128))) {
      if ((disp <=(0 - 1))) {
        (void)(((b)[0] = 137));
        (void)(((b)[1] = 69));
        (void)(((b)[2] = ((uint8_t)((u & 255)))));
        return pipeline_elf_ctx_append_bytes(elf_ctx, &((b)[0]), 3);
      }
    }
    (void)(((b)[0] = 137));
    (void)(((b)[1] = 133));
    (void)(((b)[2] = ((uint8_t)((u & 255)))));
    (void)(((b)[3] = ((uint8_t)(((u / 256) & 255)))));
    (void)(((b)[4] = ((uint8_t)(((u / 65536) & 255)))));
    (void)(((b)[5] = ((uint8_t)(((u / 16777216) & 255)))));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &((b)[0]), 6);
  }
  return (0 - 1);
}
int32_t backend_enc_load_rbp_lane_to_rax_arch(uint8_t * elf_ctx, int32_t offset, int32_t esz, int32_t ta) {
  if ((ta ==0)) {
    if ((esz ==4)) {
      return arch_x86_64_enc_enc_load_rbp_to_eax32(elf_ctx, offset);
    }
  }
  if ((ta ==1)) {
    if ((esz ==4)) {
      return arm64_enc_load_w0_from_rbp_c(elf_ctx, offset);
    }
  }
  return backend_enc_load_rbp_to_rax_arch(elf_ctx, offset, ta);
}
int32_t backend_enc_load_rbp_lane_to_rbx_arch(uint8_t * elf_ctx, int32_t offset, int32_t esz, int32_t ta) {
  if ((ta ==0)) {
    if ((esz ==4)) {
      return arch_x86_64_enc_enc_load_rbp_to_ebx32(elf_ctx, offset);
    }
  }
  return backend_enc_load_rbp_to_rbx_arch(elf_ctx, offset, ta);
}
int32_t backend_enc_load_x29_pos_to_rax_arch(uint8_t * elf_ctx, int32_t off_pos, int32_t ta) {
  if ((ta ==1)) {
    int32_t off = off_pos;
    if ((off < 0)) {
      (void)((off = 0));
    }
    int32_t imm12 = (off / 8);
    if ((imm12 > 4095)) {
      (void)((imm12 = 4095));
    }
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((-113245280 | (((uint32_t)(imm12)) * 1024)))));
  }
  return (0 - 1);
}
int32_t backend_enc_rbx_plus_index_scratch_scaled_arch(uint8_t * elf_ctx, int32_t esz, int32_t ta) {
  if ((esz ==1)) {
    if ((ta ==1)) {
      return arch_arm64_enc_enc_rbx_plus_x2_scale1(elf_ctx);
    }
    if ((ta ==2)) {
      return arch_riscv64_enc_enc_rbx_plus_a2_scale1(elf_ctx);
    }
    return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale1(elf_ctx);
  }
  if ((esz ==4)) {
    if ((ta ==1)) {
      return arch_arm64_enc_enc_rbx_plus_x2_scale4(elf_ctx);
    }
    if ((ta ==2)) {
      return arch_riscv64_enc_enc_rbx_plus_a2_scale4(elf_ctx);
    }
    return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale4(elf_ctx);
  }
  if ((ta ==1)) {
    return arch_arm64_enc_enc_rbx_plus_x2_scale8(elf_ctx);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_rbx_plus_a2_scale8(elf_ctx);
  }
  return arch_x86_64_enc_enc_lea_rbx_plus_rcx_scale8(elf_ctx);
}
int32_t backend_enc_add_imm_to_index_scratch_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta) {
  if ((ta ==1)) {
    int32_t imm12 = imm;
    if ((imm ==0)) {
      return 0;
    }
    if ((imm12 > 4095)) {
      (void)((imm12 = 4095));
    }
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((285213762 + ((imm12 - 1) * 1024)))));
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_imm_to_a2(elf_ctx, imm);
  }
  return arch_x86_64_enc_enc_add_imm_to_ecx(elf_ctx, imm);
}
int32_t backend_enc_sub_imm_from_index_scratch_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta) {
  if ((ta ==1)) {
    int32_t imm12 = imm;
    if ((imm ==0)) {
      return 0;
    }
    if ((imm12 > 4095)) {
      (void)((imm12 = 4095));
    }
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((1358955586 + ((imm12 - 1) * 1024)))));
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_sub_imm_from_a2(elf_ctx, imm);
  }
  return arch_x86_64_enc_enc_sub_imm_from_ecx(elf_ctx, imm);
}
int32_t backend_enc_add_imm_to_rbx_index_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta) {
  if ((imm ==0)) {
    return 0;
  }
  if ((ta ==1)) {
    int32_t imm12 = imm;
    if ((imm12 > 4095)) {
      (void)((imm12 = 4095));
    }
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((285213729 + ((imm12 - 1) * 1024)))));
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_add_imm_to_rbx(elf_ctx, imm);
  }
  return arch_x86_64_enc_enc_add_imm_to_ebx_index(elf_ctx, imm);
}
int32_t backend_enc_sub_imm_from_rbx_index_arch(uint8_t * elf_ctx, int32_t imm, int32_t ta) {
  if ((imm ==0)) {
    return 0;
  }
  if ((ta ==1)) {
    int32_t imm12 = imm;
    if ((imm12 > 4095)) {
      (void)((imm12 = 4095));
    }
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((1358955553 + ((imm12 - 1) * 1024)))));
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_sub_imm_from_rbx_index(elf_ctx, imm);
  }
  return arch_x86_64_enc_enc_sub_imm_from_ebx_index(elf_ctx, imm);
}
int32_t backend_enc_load_rbp_index_secondary_scratch_arch(uint8_t * elf_ctx, int32_t offset, int32_t ta) {
  if ((ta ==1)) {
    int32_t simm9 = (0 - offset);
    if ((simm9 < (0 - 256))) {
      (void)((simm9 = (0 - 256)));
    }
    int32_t u9 = (simm9 & 511);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((((-1204453376 | (((uint32_t)(u9)) * 4096)) | (29 * 32)) | 3))));
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_load_rbp_to_a3(elf_ctx, offset);
  }
  return arch_x86_64_enc_enc_load_rbp_to_edx(elf_ctx, offset);
}
int32_t backend_enc_mul_imm_to_index_scratch_arch(uint8_t * elf_ctx, int32_t lit, int32_t ta) {
  if ((lit <=1)) {
    return 0;
  }
  if ((lit > 65535)) {
    return (0 - 1);
  }
  if ((ta ==1)) {
    if ((arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)(((1384120320 | (((uint32_t)(lit)) * 32)) | 3)))) !=0)) {
      return (0 - 1);
    }
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213250);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mul_imm_to_a2(elf_ctx, lit);
  }
  return arch_x86_64_enc_enc_imul_imm_to_ecx(elf_ctx, lit);
}
int32_t backend_enc_mul_imm_to_rbx_arch(uint8_t * elf_ctx, int32_t lit, int32_t ta) {
  if ((lit <=1)) {
    return 0;
  }
  if ((lit > 65535)) {
    return (0 - 1);
  }
  if ((ta ==1)) {
    if ((arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)(((1384120320 | (((uint32_t)(lit)) * 32)) | 3)))) !=0)) {
      return (0 - 1);
    }
    return arch_arm64_enc_enc_u32_le(elf_ctx, 453213217);
  }
  if ((ta ==2)) {
    return arch_riscv64_enc_enc_mul_imm_to_rbx(elf_ctx, lit);
  }
  return arch_x86_64_enc_enc_imul_imm_to_ebx(elf_ctx, lit);
}
int32_t backend_enc_addss_rax_rbx_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t a[4] = {};
    (void)(((a)[0] = 102));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 110));
    (void)(((a)[3] = 192));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4) !=0)) {
      return (0 - 1);
    }
    (void)(((a)[0] = 102));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 110));
    (void)(((a)[3] = 203));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4) !=0)) {
      return (0 - 1);
    }
    (void)(((a)[0] = 243));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 88));
    (void)(((a)[3] = 193));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4) !=0)) {
      return (0 - 1);
    }
    (void)(((a)[0] = 102));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 126));
    (void)(((a)[3] = 192));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4);
  }
  return (0 - 1);
}
int32_t backend_enc_cvttss2si_eax_from_f32_bits_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t a[4] = {};
    (void)(((a)[0] = 102));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 110));
    (void)(((a)[3] = 192));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4) !=0)) {
      return (0 - 1);
    }
    (void)(((a)[0] = 243));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 44));
    (void)(((a)[3] = 192));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4);
  }
  return (0 - 1);
}
int32_t backend_enc_cvtsd2ss_eax_from_f64_bits_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t q[5] = {};
    (void)(((q)[0] = 102));
    (void)(((q)[1] = 72));
    (void)(((q)[2] = 15));
    (void)(((q)[3] = 110));
    (void)(((q)[4] = 192));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((q)[0]), 5) !=0)) {
      return (0 - 1);
    }
    uint8_t a[4] = {};
    (void)(((a)[0] = 242));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 90));
    (void)(((a)[3] = 192));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4) !=0)) {
      return (0 - 1);
    }
    (void)(((a)[0] = 102));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 126));
    (void)(((a)[3] = 192));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4);
  }
  return (0 - 1);
}
int32_t backend_enc_cvtsi2ss_eax_from_i32_arch(uint8_t * elf_ctx, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t a[4] = {};
    (void)(((a)[0] = 243));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 42));
    (void)(((a)[3] = 192));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4) !=0)) {
      return (0 - 1);
    }
    (void)(((a)[0] = 102));
    (void)(((a)[1] = 15));
    (void)(((a)[2] = 126));
    (void)(((a)[3] = 192));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &((a)[0]), 4);
  }
  return (0 - 1);
}
int32_t backend_enc_mov_eax_to_xmm_arg_reg_arch(uint8_t * elf_ctx, int32_t k, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((k < 0)) {
    return (0 - 1);
  }
  if ((k > 7)) {
    return (0 - 1);
  }
  {
    uint8_t p[3] = {};
    (void)(((p)[0] = 102));
    (void)(((p)[1] = 15));
    (void)(((p)[2] = 110));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((p)[0]), 3) !=0)) {
      return (0 - 1);
    }
    uint8_t modrm = ((uint8_t)((192 | ((k * 8) & 255))));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &(modrm), 1);
  }
  return (0 - 1);
}
int32_t backend_enc_mov_xmm_arg_reg_to_eax_arch(uint8_t * elf_ctx, int32_t k, int32_t ta) {
  if ((ta !=0)) {
    return (0 - 1);
  }
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((k < 0)) {
    return (0 - 1);
  }
  if ((k > 7)) {
    return (0 - 1);
  }
  {
    uint8_t p[3] = {};
    (void)(((p)[0] = 102));
    (void)(((p)[1] = 15));
    (void)(((p)[2] = 126));
    if ((pipeline_elf_ctx_append_bytes(elf_ctx, &((p)[0]), 3) !=0)) {
      return (0 - 1);
    }
    uint8_t modrm = ((uint8_t)((192 | ((k * 8) & 255))));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &(modrm), 1);
  }
  return (0 - 1);
}
int32_t arch_arm64_enc_enc_cmp_w0_imm12(uint8_t * elf_ctx, int32_t imm12) {
  int32_t imm = (imm12 & 4095);
  return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((1895825439 | (imm * 1024)))));
}
int32_t arch_arm64_enc_enc_cset_w0_from_cc(uint8_t * elf_ctx, int32_t cc) {
  {
    int32_t c = pipeline_asm_arm64_cset_cond_enc_from_cc(cc);
    return arch_arm64_enc_enc_u32_le(elf_ctx, ((int32_t)((446629856 | (c * 4096)))));
  }
  return (0 - 1);
}
int32_t arch_arm64_enc_enc_add_sp_imm12(uint8_t * elf_ctx, int32_t imm) {
  return backend_enc_arm64_add_sp_imm12_c(elf_ctx, imm);
}
int32_t arch_arm64_enc_enc_sub_sp_imm12(uint8_t * elf_ctx, int32_t imm) {
  return backend_enc_arm64_sub_sp_imm12_c(elf_ctx, imm);
}
int32_t arch_arm64_enc_enc_str_x0_sp_offset(uint8_t * elf_ctx, int32_t off_bytes) {
  return backend_enc_arm64_str_x0_sp_offset_c(elf_ctx, off_bytes);
}
int32_t arch_arm64_enc_enc_call(uint8_t * elf_ctx, uint8_t * name, int32_t name_len) {
  return backend_enc_arm64_call_c(elf_ctx, name, name_len);
}
int32_t arch_riscv64_enc_enc_call(uint8_t * elf_ctx, uint8_t * name, int32_t name_len) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((name ==0)) {
    return (0 - 1);
  }
  if ((name_len <=0)) {
    return (0 - 1);
  }
  return (0 - 1);
}
int32_t arch_riscv64_enc_enc_mov_rax_to_arg_reg(uint8_t * elf_ctx, int32_t k) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  if ((k < 0)) {
    return (0 - 1);
  }
  return (0 - 1);
}
int32_t backend_enc_append_u8_c(uint8_t * elf_ctx, int32_t byte) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  uint8_t b = ((uint8_t)((byte & 255)));
  {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &(b), 1);
  }
  return (0 - 1);
}
int32_t arch_x86_64_enc_enc_cdqe_rax(uint8_t * elf_ctx) {
  if ((elf_ctx ==0)) {
    return (0 - 1);
  }
  {
    uint8_t cdqe[2] = {};
    (void)(((cdqe)[0] = 72));
    (void)(((cdqe)[1] = 152));
    return pipeline_elf_ctx_append_bytes(elf_ctx, &((cdqe)[0]), 2);
  }
  return (0 - 1);
}
