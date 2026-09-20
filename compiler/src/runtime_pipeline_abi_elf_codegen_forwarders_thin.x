// Thin pure: wave292/w505 M2 — pipeline_elf_codegen_forwarders Cap residual
// C→.x (was wave291 C thin). Rename shims only: platform.elf / codegen_ /
// pipeline_ prefixes → authoritative unprefixed callees + sizeof_elf_ctx.
// G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
// WAVE291_ELF_CODEGEN_FORWARDERS_ALWAYS. No BSS. No FROM_X gate.
// wave505: PRODUCT inject BOTH PREFER (tip U-complete; was ambient/-E gap).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
//
// Note: inventory wave292 bootstrap_orchestration is already seed-only
// placeholder (not in g05 product link). This leaf reuses the wave slot
// for the next host-cc→0 knife after Class E ALWAYS C-thin closed @ w291.

export extern function pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes: *u8, idx: i32): *u8;
export extern function pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes: *u8, idx: i32, dst: *u8): void;
export extern function pipeline_elf_ctx_reloc_name_len(ctx_bytes: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes: *u8): void;
export extern function pipeline_elf_ctx_reloc_offset_at(ctx_bytes: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_offset_set(ctx_bytes: *u8, idx: i32, offset: i32): void;
export extern function pipeline_elf_ctx_reloc_shndx_at(ctx_bytes: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_sym_shndx_at(ctx_bytes: *u8, idx: i32): i32;
export extern function pipeline_elf_pgo_hot_enabled(): i32;
export extern function pipeline_elf_ctx_set_emit_hot(ctx_bytes: *u8, hot: i32): void;
export extern function pipeline_elf_ctx_append_bytes(ctx_bytes: *u8, ptr: *u8, n: i32): i32;
export extern function pipeline_elf_write_o_pgo_to_buf(ctx_bytes: *u8, out: *u8): i32;
export extern function codegen_out_buf_len(out: *u8): i32;
export extern function codegen_out_buf_set_len(out: *u8, n: i32): void;
export extern function pipeline_scratch_buf64(): *u8;
export extern function pipeline_scratch_buf64_slot(slot: i32): *u8;

/* LP64 sizeof(ElfCodegenCtx); keep lockstep with seed WAVE291 constant. */
/* wave651: patches 16384->65536 (+13172736). Keep in lockstep with
 * ElfCodegenCtx field set + seed twin. */
const WAVE291_PIPELINE_ELF_CODEGEN_CTX_SIZE: i64 = 40501296;

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_sym_name_ptr.
 * @param ctx_bytes *u8 — ElfCodegenCtx bytes
 * @param idx i32 — reloc index
 * @return *u8 — symbol name pointer
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes: *u8, idx: i32): *u8 {
  unsafe {
    return pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, idx);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_sym_name_copy64.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes: *u8, idx: i32, dst: *u8): void {
  unsafe {
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, idx, dst);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_name_len.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_reloc_name_len(ctx_bytes: *u8, idx: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_reloc_name_len(ctx_bytes, idx);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_sidecar_reset.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes: *u8): void {
  unsafe {
    pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_offset_at.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_reloc_offset_at(ctx_bytes: *u8, idx: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_reloc_offset_at(ctx_bytes, idx);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_offset_set.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_reloc_offset_set(ctx_bytes: *u8, idx: i32, offset: i32): void {
  unsafe {
    pipeline_elf_ctx_reloc_offset_set(ctx_bytes, idx, offset);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_shndx_at.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_reloc_shndx_at(ctx_bytes: *u8, idx: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, idx);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_sym_shndx_at.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_sym_shndx_at(ctx_bytes: *u8, idx: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_sym_shndx_at(ctx_bytes, idx);
  }
}

/**
 * platform.elf prefix → pipeline_elf_pgo_hot_enabled.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_pgo_hot_enabled(): i32 {
  unsafe {
    return pipeline_elf_pgo_hot_enabled();
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_set_emit_hot.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_set_emit_hot(ctx_bytes: *u8, hot: i32): void {
  unsafe {
    pipeline_elf_ctx_set_emit_hot(ctx_bytes, hot);
  }
}

/**
 * platform.elf prefix → pipeline_elf_ctx_append_bytes.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_ctx_append_bytes(ctx_bytes: *u8, ptr: *u8, n: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_append_bytes(ctx_bytes, ptr, n);
  }
}

/**
 * platform.elf prefix → pipeline_elf_write_o_pgo_to_buf.
 * @param out *u8 — CodegenOutBuf* (opaque)
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function platform_elf_pipeline_elf_write_o_pgo_to_buf(ctx_bytes: *u8, out: *u8): i32 {
  unsafe {
    return pipeline_elf_write_o_pgo_to_buf(ctx_bytes, out);
  }
}

/**
 * codegen_ prefix → codegen_out_buf_len.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function codegen_codegen_out_buf_len(out: *u8): i32 {
  unsafe {
    return codegen_out_buf_len(out);
  }
}

/**
 * codegen_ prefix → codegen_out_buf_set_len.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function codegen_codegen_out_buf_set_len(out: *u8, n: i32): void {
  unsafe {
    codegen_out_buf_set_len(out, n);
  }
}

/**
 * pipeline_ prefix → codegen_out_buf_len.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function pipeline_codegen_out_buf_len(out: *u8): i32 {
  unsafe {
    return codegen_out_buf_len(out);
  }
}

/**
 * pipeline_ prefix → codegen_out_buf_set_len.
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function pipeline_codegen_out_buf_set_len(out: *u8, n: i32): void {
  unsafe {
    codegen_out_buf_set_len(out, n);
  }
}

/**
 * codegen_ prefix → pipeline_scratch_buf64 (BSS authority = codegen_x.o).
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function codegen_pipeline_scratch_buf64(): *u8 {
  unsafe {
    return pipeline_scratch_buf64();
  }
}

/**
 * codegen_ prefix → pipeline_scratch_buf64_slot (BSS authority = codegen_x.o).
 * PLATFORM: SHARED — Cap residual rename shim (wave292 .x thin).
 */
#[no_mangle]
export function codegen_pipeline_scratch_buf64_slot(slot: i32): *u8 {
  unsafe {
    return pipeline_scratch_buf64_slot(slot);
  }
}

/**
 * pipeline_sizeof_elf_ctx — LP64 layout size for malloc of ElfCodegenCtx.
 * Freestanding Cap uses fixed size constant (no host sizeof(struct)).
 * @return i64 — byte size (cast from size_t face at C ABI)
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function pipeline_sizeof_elf_ctx(): i64 {
  return WAVE291_PIPELINE_ELF_CODEGEN_CTX_SIZE;
}
