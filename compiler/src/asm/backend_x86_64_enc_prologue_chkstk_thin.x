// Override arch_x86_64_enc_enc_prologue with a Windows-safe stack probe.
// A bare `sub rsp, imm32` larger than one page skips the guard page and
// SEGVs on Windows (global array bake with large folder frames).
// Linked first on LINUX|WINDOWS like cltd_cqo.o (PE first-wins).
// PLATFORM: LINUX|UBUNTU / WINDOWS — x86_64 only. Darwin arm64 skips.

export extern "C" function x86_enc_u8(elf_ctx: *u8, b: i32): i32;
export extern "C" function x86_enc_bytes(elf_ctx: *u8, p: *u8, n: i32): i32;

/**
 * Emit push rbp; mov rbp,rsp; push rbx; then allocate frame_sz bytes.
 * When the aligned frame is larger than 4096, probe in 4096-byte steps
 * so Windows commits guard pages before RSP crosses them. A single
 * unprobed `sub rsp, large` is the Windows tip SEGV on deep AS/compare
 * folds. Frames of 4096 or less keep the historic one-shot sub.
 * @param elf_ctx *u8 - emit context; null returns -1
 * @param frame_sz i32 - requested local bytes before 16-byte align pad
 * @return i32 - 0 on success, -1 on failure
 * PLATFORM: LINUX|UBUNTU / WINDOWS — x86_64 PE/ELF product link name.
 */
#[no_mangle]
export function arch_x86_64_enc_enc_prologue(elf_ctx: *u8, frame_sz: i32): i32 {
  let fs: i32 = 0;
  let rem: i32 = 0;
  let add: i32 = 0;
  let aligned: i32 = 0;
  let u: u32 = 0;
  let page: i32 = 4096;
  let sub7: u8[7] = [];
  let or5: u8[5] = [];
  let sub5: u8[5] = [];
  let cmp5: u8[5] = [];
  let jae2: u8[2] = [];
  let subrax: u8[3] = [];
  if (elf_ctx == (0 as *u8)) {
    return 0 - 1;
  }
  // push rbp
  if (x86_enc_u8(elf_ctx, 85) != 0) {
    return 0 - 1;
  }
  // mov rbp, rsp
  if (x86_enc_u8(elf_ctx, 72) != 0) {
    return 0 - 1;
  }
  if (x86_enc_u8(elf_ctx, 137) != 0) {
    return 0 - 1;
  }
  if (x86_enc_u8(elf_ctx, 229) != 0) {
    return 0 - 1;
  }
  // push rbx
  if (x86_enc_u8(elf_ctx, 83) != 0) {
    return 0 - 1;
  }
  fs = frame_sz;
  if (fs < 0) {
    fs = 0;
  }
  rem = fs & 15;
  add = (8 - rem) & 15;
  aligned = fs + add;
  // Small frame: one-shot sub rsp, imm32 (historic path).
  // Do not use `aligned <= page` — the Windows host that compiles this
  // thin has miscompiled bare `<=` in neighboring arms.
  // PLATFORM: WINDOWS.
  if (page < aligned) {
    // Large frame path below.
  } else {
    u = aligned as u32;
    sub7[0] = 72;
    sub7[1] = 129;
    sub7[2] = 236;
    sub7[3] = (u & 255) as u8;
    sub7[4] = ((u >> 8) & 255) as u8;
    sub7[5] = ((u >> 16) & 255) as u8;
    sub7[6] = ((u >> 24) & 255) as u8;
    return x86_enc_bytes(elf_ctx, &(sub7[0]), 7);
  }
  // Large frame: mov eax, aligned; then probe loop; then sub rsp, rax.
  // mov eax, imm32
  if (x86_enc_u8(elf_ctx, 184) != 0) {
    return 0 - 1;
  }
  u = aligned as u32;
  if (x86_enc_u8(elf_ctx, (u & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (x86_enc_u8(elf_ctx, ((u >> 8) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (x86_enc_u8(elf_ctx, ((u >> 16) & 255) as i32) != 0) {
    return 0 - 1;
  }
  if (x86_enc_u8(elf_ctx, ((u >> 24) & 255) as i32) != 0) {
    return 0 - 1;
  }
  // jmp check (rel8). Body of page: 7+5+5 = 17 bytes; jae is 2; so
  // jmp skips 17 bytes → eb 11.
  if (x86_enc_u8(elf_ctx, 235) != 0) {
    return 0 - 1;
  }
  if (x86_enc_u8(elf_ctx, 17) != 0) {
    return 0 - 1;
  }
  // page: sub rsp, 0x1000
  sub7[0] = 72;
  sub7[1] = 129;
  sub7[2] = 236;
  sub7[3] = 0;
  sub7[4] = 16;
  sub7[5] = 0;
  sub7[6] = 0;
  if (x86_enc_bytes(elf_ctx, &(sub7[0]), 7) != 0) {
    return 0 - 1;
  }
  // or qword [rsp], 0 — touch the guard page. 48 83 0c 24 00
  or5[0] = 72;
  or5[1] = 131;
  or5[2] = 12;
  or5[3] = 36;
  or5[4] = 0;
  if (x86_enc_bytes(elf_ctx, &(or5[0]), 5) != 0) {
    return 0 - 1;
  }
  // sub eax, 0x1000
  sub5[0] = 45;
  sub5[1] = 0;
  sub5[2] = 16;
  sub5[3] = 0;
  sub5[4] = 0;
  if (x86_enc_bytes(elf_ctx, &(sub5[0]), 5) != 0) {
    return 0 - 1;
  }
  // check: cmp eax, 0x1000
  cmp5[0] = 61;
  cmp5[1] = 0;
  cmp5[2] = 16;
  cmp5[3] = 0;
  cmp5[4] = 0;
  if (x86_enc_bytes(elf_ctx, &(cmp5[0]), 5) != 0) {
    return 0 - 1;
  }
  // jae page — back 17+5+2 = 24 bytes from next insn → 73 e8
  // From after jae2 back to page start: page(7)+or(5)+sub(5)+cmp(5)+jae(2)=24.
  // rel8 = -24 = 0xe8.
  jae2[0] = 115;
  jae2[1] = 232;
  if (x86_enc_bytes(elf_ctx, &(jae2[0]), 2) != 0) {
    return 0 - 1;
  }
  // sub rsp, rax (remainder in eax, zero-extended)
  subrax[0] = 72;
  subrax[1] = 41;
  subrax[2] = 196;
  if (x86_enc_bytes(elf_ctx, &(subrax[0]), 3) != 0) {
    return 0 - 1;
  }
  return 0;
}
