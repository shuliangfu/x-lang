// Link unit for arch_x86_64_enc_enc_cltd.
// The body is the same two appends as
// backend_enc_dispatch_thin.x arch_x86_64_enc_enc_cltd.
// backend_enc_dispatch.o on Windows still emits only 99 (cltd).
// idiv %rbx in that object is 48 f7 fb, so edx must be the
// sign of rax, which is cqo (48 99). This file exports that
// one symbol. Do not add another encoder function here.
// PLATFORM: WINDOWS. Linux already links its own
// build_asm/selfhost_pabi/cltd_cqo.o. Darwin is arm64 and
// does not link this object. Do not rebuild
// backend_x86_64_enc_c.o or backend_enc_dispatch.o to pick
// this up: other symbols in those TUs must stay as they are.

export extern "C" function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32;

/**
 * Emit cqo before the 64-bit idiv %rbx.
 * The link name stays arch_x86_64_enc_enc_cltd. The bytes are
 * 48 99, not 99. idiv %rbx is REX.W. cltd only fills edx, so a
 * negative rax dividend traps. cqo sign-extends rax into rdx.
 * Each byte is appended through backend_enc_append_u8_c.
 * A null context returns -1 from that append.
 * @param elf_ctx *u8 — emit context; null is rejected by append
 * @return i32 — 0 when both bytes are appended, -1 on failure
 * PLATFORM: WINDOWS — COFF link unit. First strong definition
 * wins over the cltd still inside backend_enc_dispatch.o.
 * This body does not compare elf_ctx with 0 and does not divide.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_cltd(elf_ctx: *u8): i32 {
  // cqo: 48 99. Not cltd (99). The following idiv %rbx is 64-bit.
  // The append is an extern C call, so it stays inside unsafe.
  unsafe {
    if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c(elf_ctx, 153);
  }
}
