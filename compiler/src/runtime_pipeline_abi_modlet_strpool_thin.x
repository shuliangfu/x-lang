// Thin pure override: intern one module-let STRING_LIT into the .data pool.
// w1501 (终局待办 10.24): pabi's pipe_modlet_bake_string_lit_elem_to_data
// copied the head chunk with a 255-byte cap, but the parser splits string
// literals into 127-byte chunks (PARSER_ASM_STRING_LIT_CHUNK). A literal
// longer than 127 bytes in a module `let g: *u8[N] = [...]` or a module
// struct field then got 128 zero bytes after byte 127 and lost its tail on
// Darwin and Ubuntu. src/runtime_pipeline_abi.x and its seed may not be
// rebuilt (mega ban), so this file redefines the same exported symbol with
// the 127 cap; merge it back into pabi.x under 10.26.
// Labels: Lxmlt_<hex8(seq)><hex8(module_fp)>, 22 bytes. The prefix differs
// from pabi's Lxmls_ so a cold-path label in the same TU never collides.
// g05_relink_env.sh compiles this with the current product (pure asm, no
// host cc) and links it ahead of pabi: Darwin pabi copies are weak, Linux is
// first-wins, Windows weakens pabi_weak and jmp-patches leftovers.
// PLATFORM: SHARED freestanding · ELF .data RELA · Mach-O __DATA · PE .data.

export extern "C" function glue_asm_string_lit_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_elf_ctx_emit_data_len(ctx_bytes: *u8): i32;
export extern function pipeline_elf_ctx_append_data_zeros(ctx_bytes: *u8, n: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern "C" function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_elf_ctx_add_label(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern function pipeline_elf_ctx_add_sym(ctx_bytes: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern function pipeline_elf_ctx_append_reloc_absolute64(ctx_bytes: *u8, offset: i32, name: *u8, name_len: i32): i32;
export extern function pipe_modlet_module_fp(): i64;

// [0] = label sequence (monotonic for the whole process, so labels stay
// unique inside one TU even across pabi's per-emit reset).
let w1501_sp_st: i32[2] = [];

/**
 * Write eight lowercase hex digits of v into lab[at..at+8).
 * @param lab *u8 — label buffer (24 bytes)
 * @param at i32 — first digit index
 * @param v i64 — value; only the low 32 bits are used
 * @return void
 * PLATFORM: SHARED.
 */
function w1501_sp_hex8(lab: *u8, at: i32, v: i64): void {
  let i: i32 = 0;
  let nib: i32 = 0;
  let shift: i32 = 0;
  while (i < 8) {
    shift = (7 - i) * 4;
    nib = ((v >> shift) & 15) as i32;
    unsafe {
      if (nib >= 10) {
        *(lab + at + i) = (87 + nib) as u8;
      } else {
        *(lab + at + i) = (48 + nib) as u8;
      }
    }
    i = i + 1;
  }
}

/**
 * Intern one STRING_LIT into the .data string pool and record an
 * absolute64 reloc on the already-reserved pointer slot.
 * Head chunk is at most 127 bytes; continuation chunks carry their own
 * length and are chained through int_val.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer context
 * @param eref i32 — STRING_LIT expr ref
 * @param slot_off i32 — .data offset of the pointer slot
 * @return i32 — 0 ok, -1 on failure
 * The filename contains "pipeline", so the entry-module prefix would emit
 * pipeline_pipe_modlet_bake_string_lit_elem_to_data. The egg and g05 both
 * require the bare name.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_modlet_bake_string_lit_elem_to_data(
  arena: *u8, elf_ctx: *u8, eref: i32, slot_off: i32
): i32 {
  let slen: i32 = 0;
  let pool_off: i32 = 0;
  let rc: i32 = 0;
  let bi: i32 = 0;
  let seq: i32 = 0;
  let fp: i64 = 0;
  let lab: u8[24] = [];
  let sbuf: u8[256] = [];
  let cur: i32 = 0;
  let n: i32 = 0;
  let copied: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || eref <= 0 || slot_off < 0) {
    return 0 - 1;
  }
  unsafe {
    slen = glue_asm_string_lit_len(arena, eref);
  }
  if (slen < 0 || slen > 4095) {
    return 0 - 1;
  }
  unsafe {
    pool_off = pipeline_elf_ctx_emit_data_len(elf_ctx);
  }
  if (pool_off < 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_append_data_zeros(elf_ctx, slen + 1);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  copied = 0;
  cur = eref;
  while (copied < slen && cur > 0) {
    bi = 0;
    while (bi < 256) {
      sbuf[bi] = 0 as u8;
      bi = bi + 1;
    }
    unsafe {
      pipeline_expr_var_name_into(arena, cur, &sbuf[0]);
    }
    if (cur == eref) {
      n = slen;
      if (n > 127) {
        n = 127;
      }
    } else {
      unsafe {
        n = glue_asm_string_lit_len(arena, cur);
      }
    }
    if (n < 0) {
      n = 0;
    }
    if (n > slen - copied) {
      n = slen - copied;
    }
    bi = 0;
    while (bi < n) {
      unsafe {
        rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, pool_off + copied + bi, sbuf[bi] as i32);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      bi = bi + 1;
    }
    copied = copied + n;
    unsafe {
      cur = pipeline_expr_int_val_at(arena, cur);
    }
  }
  w1501_sp_st[0] = w1501_sp_st[0] + 1;
  seq = w1501_sp_st[0];
  unsafe {
    fp = pipe_modlet_module_fp();
  }
  lab[0] = 76 as u8;
  lab[1] = 120 as u8;
  lab[2] = 109 as u8;
  lab[3] = 108 as u8;
  lab[4] = 116 as u8;
  lab[5] = 95 as u8;
  w1501_sp_hex8(&lab[0], 6, seq as i64);
  w1501_sp_hex8(&lab[0], 14, fp);
  unsafe {
    rc = pipeline_elf_ctx_add_label(elf_ctx, &lab[0], 22, pool_off);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_add_sym(elf_ctx, &lab[0], 22, pool_off);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_append_reloc_absolute64(elf_ctx, slot_off, &lab[0], 22);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}
