// Thin pure: FIELD frame-mag fold over chain (wave441/445).
// wave445: `*out_off =` heal Ubuntu pure-asm CG002 (`out[0]=`).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path.
// wave545 Soft Cap: Ubuntu tip SEGV on raw `*i32` load/store, and while-body
//   extern calls are dropped. Step walks chain_n-1 .. 0 (cap 16). Layout
//   name_into stays behind a vlen parameter; effective_offset and frame_mag
//   are call-args so tip keeps them. Out is pipe_store_i32_le, not `*out=`.
//   stamp w545 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function glue_field_layout_offset_for_base_field(a: *u8, m: *u8, base_ref: i32, field_name: *u8, flen: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, field_off: i32, ta: i32): i32;

/**
 * Layout offset for one FIELD name, or -1 when vlen is out of 1..255.
 * vlen is a parameter so name_into / layout_offset stay in the tip object.
 * @param arena *u8 — AST arena
 * @param mod *u8 — emit module
 * @param fa_ref i32 — FIELD expr ref
 * @param base_ref i32 — FIELD base expr
 * @param vlen i32 — name length
 * @param name *u8 — scratch of at least 256 bytes
 * @return i32 — layout offset, or -1
 * PLATFORM: SHARED freestanding.
 */
function w545_layout(arena: *u8, mod: *u8, fa_ref: i32, base_ref: i32, vlen: i32, name: *u8): i32 {
  unsafe {
    if (vlen <= 0) {
      return 0 - 1;
    }
    if (vlen > 255) {
      return 0 - 1;
    }
    pipeline_expr_field_access_name_into(arena, fa_ref, name);
    let rcell: u8[8] = [];
    pipe_store_i32_le(&rcell[0], 0, glue_field_layout_offset_for_base_field(arena, mod, base_ref, name, vlen));
    return pipe_load_i32_le(&rcell[0], 0);
  }
}

/**
 * Resolve field offset then frame-mag. effective_offset and frame_mag are
 * always invoked (rty selects which value is kept) so Ubuntu tip does not
 * drop the failure-only call.
 * @param arena *u8 — AST arena
 * @param mod *u8 — emit module
 * @param fa_ref i32 — FIELD expr ref
 * @param rty i32 — layout offset, or -1 to use effective_offset
 * @param off i32 — offset before this field
 * @param hit i32 — 0 means already failed
 * @param ta i32 — target arch flag passed to frame_mag
 * @param ocell *u8 — receives the next offset
 * @return i32 — updated hit (0 or hit)
 * PLATFORM: SHARED freestanding.
 */
function w545_apply(arena: *u8, mod: *u8, fa_ref: i32, rty: i32, off: i32, hit: i32, ta: i32, ocell: *u8): i32 {
  unsafe {
    let ecell: u8[8] = [];
    let ucell: u8[8] = [];
    let mcell: u8[8] = [];
    pipe_store_i32_le(&ecell[0], 0, glue_field_access_effective_offset_c(arena, mod, fa_ref));
    if (rty >= 0) {
      pipe_store_i32_le(&ucell[0], 0, rty);
    } else {
      pipe_store_i32_le(&ucell[0], 0, pipe_load_i32_le(&ecell[0], 0));
    }
    pipe_store_i32_le(&mcell[0], 0, glue_struct_field_frame_mag_c(off, pipe_load_i32_le(&ucell[0], 0), ta));
    if (hit == 0) {
      pipe_store_i32_le(ocell, 0, off);
      return 0;
    }
    if (pipe_load_i32_le(&ucell[0], 0) < 0) {
      pipe_store_i32_le(ocell, 0, off);
      return 0;
    }
    pipe_store_i32_le(ocell, 0, pipe_load_i32_le(&mcell[0], 0));
    if (pipe_load_i32_le(ocell, 0) < 0) {
      return 0;
    }
    return hit;
  }
}

/**
 * One downward FIELD step. go/hit/walk_i are parameters.
 * Stores next off/hit/walk_i into the three cells.
 * @param fa *u8 — chain_fa as bytes; slot i is at offset i*4
 * @param name *u8 — 256-byte name scratch
 * @return i32 — 1 to continue, 0 to stop
 * PLATFORM: SHARED freestanding.
 */
function w545_mag_step(arena: *u8, mod: *u8, fa: *u8, walk_i: i32, off: i32, hit: i32, ta: i32, go: i32, name: *u8, ocell: *u8, hcell: *u8, icell: *u8): i32 {
  unsafe {
    if (go == 0) {
      pipe_store_i32_le(ocell, 0, off);
      pipe_store_i32_le(hcell, 0, hit);
      pipe_store_i32_le(icell, 0, walk_i);
      return 0;
    }
    if (hit == 0) {
      pipe_store_i32_le(ocell, 0, off);
      pipe_store_i32_le(hcell, 0, hit);
      pipe_store_i32_le(icell, 0, walk_i);
      return 0;
    }
    if (walk_i < 0) {
      pipe_store_i32_le(ocell, 0, off);
      pipe_store_i32_le(hcell, 0, hit);
      pipe_store_i32_le(icell, 0, walk_i);
      return 0;
    }
    let fcell: u8[8] = [];
    let bcell: u8[8] = [];
    let lcell: u8[8] = [];
    pipe_store_i32_le(&fcell[0], 0, pipe_load_i32_le(fa, walk_i * 4));
    pipe_store_i32_le(&bcell[0], 0, pipeline_expr_field_access_base_ref(arena, pipe_load_i32_le(&fcell[0], 0)));
    pipe_store_i32_le(&lcell[0], 0, pipeline_expr_field_access_name_len(arena, pipe_load_i32_le(&fcell[0], 0)));
    let rty: i32 = w545_layout(arena, mod, pipe_load_i32_le(&fcell[0], 0), pipe_load_i32_le(&bcell[0], 0), pipe_load_i32_le(&lcell[0], 0), name);
    let nh: i32 = w545_apply(arena, mod, pipe_load_i32_le(&fcell[0], 0), rty, off, hit, ta, ocell);
    pipe_store_i32_le(hcell, 0, nh);
    pipe_store_i32_le(icell, 0, walk_i - 1);
    if (nh == 0) {
      return 0;
    }
    return 1;
  }
}

/**
 * Fold glue_struct_field_frame_mag_c from VAR slot through FIELD chain.
 * Writes final off into out_off; returns updated hit (0 cleared on fail).
 * @param arena *u8 — AST arena
 * @param mod *u8 — emit module
 * @param chain_fa *i32 — FIELD expr refs, index 0 is the outermost
 * @param chain_n i32 — length; INDEX/FIELD walk produces at most 16
 * @param off_in i32 — starting frame offset
 * @param hit_in i32 — 0 skips the fold
 * @param ta i32 — target-arch flag for frame_mag
 * @param out_off *i32 — final offset (pipe_store, not *i32)
 * @return i32 — hit (0 or hit_in)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_mag_fold_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, off_in: i32, hit_in: i32, ta: i32, out_off: *i32): i32 {
  unsafe {
    let name: u8[256] = [];
    let ocell: u8[8] = [];
    let hcell: u8[8] = [];
    let icell: u8[8] = [];
    let go: i32 = 1;
    pipe_store_i32_le(&ocell[0], 0, off_in);
    pipe_store_i32_le(&hcell[0], 0, hit_in);
    pipe_store_i32_le(&icell[0], 0, chain_n - 1);
    if (hit_in == 0) {
      go = 0;
    }
    if (chain_n <= 0) {
      go = 0;
    }
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    go = w545_mag_step(arena, mod, chain_fa as *u8, pipe_load_i32_le(&icell[0], 0), pipe_load_i32_le(&ocell[0], 0), pipe_load_i32_le(&hcell[0], 0), ta, go, &name[0], &ocell[0], &hcell[0], &icell[0]);
    pipe_store_i32_le(out_off as *u8, 0, pipe_load_i32_le(&ocell[0], 0));
    return pipe_load_i32_le(&hcell[0], 0);
  }
}
