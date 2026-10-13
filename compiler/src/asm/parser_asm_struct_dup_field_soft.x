// knife256/10.2 Cap tip soft: pack_dup_field false-positives on core.result
// (multiple allow(padding) structs with shared _padN / field names under dep
// prerun). Product greens the same sources. Cap tip L2: no-op until the
// in-layout compare is healed; reveals follow-on T001 on res.value.
// PLATFORM: SHARED — Cap tip sidecar only (winner over pthin p6).
#[no_mangle]
export function parser_asm_struct_layout_pack_dup_field_c(
    pack: *u8, module: *u8, layout_idx: i32, nf: i32, line: i32, col: i32): i32 {
  return 0;
}
