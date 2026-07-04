// CORE-004 烟测：subslice / split_at / chunks（i32[] + u8[] 边界钳制）
const slice = import("core.slice");
const option = import("core.option");

function main(): i32 {
  // ——— i32[] subslice ———
  let a: i32[4] = [10, 20, 30, 40];
  let s: i32[] = a;
  let sub: i32[] = slice.subslice_i32(s, 1, 2);
  if (sub.length != 2) { return 1; }
  if (sub[0] != 20 || sub[1] != 30) { return 2; }
  let empty: i32[] = slice.subslice_i32(s, 10, 5);
  if (empty.length != 0) { return 3; }

  // ——— i32[] split_at ———
  let sp: Split_i32 = slice.split_at_i32(s, 2);
  if (sp.left.length != 2 || sp.right.length != 2) { return 4; }
  if (sp.left[0] != 10 || sp.left[1] != 20) { return 5; }
  if (sp.right[0] != 30 || sp.right[1] != 40) { return 6; }
  let sp2: Split_i32 = slice.split_at_i32(s, 99);
  if (sp2.left.length != 4 || sp2.right.length != 0) { return 7; }

  // ——— i32[] chunks ———
  let b: i32[5] = [1, 2, 3, 4, 5];
  let sb: i32[] = b;
  if (slice.chunks_len_i32(sb, 2) != 3) { return 8; }
  let c0: i32[] = slice.chunk_i32(sb, 2, 0);
  let c2: i32[] = slice.chunk_i32(sb, 2, 2);
  if (c0.length != 2 || c0[0] != 1 || c0[1] != 2) { return 9; }
  if (c2.length != 1 || c2[0] != 5) { return 10; }
  let c_oob: i32[] = slice.chunk_i32(sb, 2, 99);
  if (c_oob.length != 0) { return 11; }
  if (slice.chunks_len_i32(sb, 0) != 0) { return 12; }

  // ——— u8[] subslice / split / chunk ———
  let u: u8[4] = [1, 2, 3, 4];
  let x: u8[] = u;
  let usub: u8[] = slice.subslice_u8(x, 1, 2);
  if (usub.length != 2 || usub[0] != 2 || usub[1] != 3) { return 13; }
  let usp: Split_u8 = slice.split_at_u8(x, 2);
  if (usp.left.length != 2 || usp.right.length != 2) { return 14; }
  if (slice.chunks_len_u8(x, 3) != 2) { return 15; }
  let uc: u8[] = slice.chunk_u8(x, 3, 1);
  if (uc.length != 1 || uc[0] != 4) { return 16; }

  // ——— is_empty / first / last ———
  if (slice.is_empty_i32(s) != 0) { return 17; }
  if (slice.is_empty_u8(x) != 0) { return 18; }
  let fi: Option_i32 = slice.first_i32(s);
  if (fi.is_some == false || fi.value != 10) { return 19; }
  let li: Option_i32 = slice.last_i32(s);
  if (li.is_some == false || li.value != 40) { return 20; }
  let fu: Option_u8 = slice.first_u8(x);
  if (fu.is_some == false || fu.value != 1) { return 21; }

  // ——— u64[] len / get / first / last ———
  let w: u64[4] = [100, 200, 300, 400];
  let sw: u64[] = w;
  if (slice.is_empty_u64(sw) != 0) { return 22; }
  if (slice.len_u64(sw) != 4) { return 23; }
  let fw: Option_u64 = slice.first_u64(sw);
  if (fw.is_some == false || fw.value != 100) { return 24; }
  let lw: Option_u64 = slice.last_u64(sw);
  if (lw.is_some == false || lw.value != 400) { return 25; }
  let gw: Option_u64 = slice.get_u64(sw, 2);
  if (gw.is_some == false || gw.value != 300) { return 26; }

  // ——— u64[] subslice / split / chunk ———
  let wsub: u64[] = slice.subslice_u64(sw, 1, 2);
  if (wsub.length != 2 || wsub[0] != 200 || wsub[1] != 300) { return 27; }
  let wsp: Split_u64 = slice.split_at_u64(sw, 2);
  if (wsp.left.length != 2 || wsp.right.length != 2) { return 28; }
  if (wsp.left[0] != 100 || wsp.right[0] != 300) { return 29; }
  if (slice.chunks_len_u64(sw, 3) != 2) { return 30; }
  let wc: u64[] = slice.chunk_u64(sw, 3, 1);
  if (wc.length != 1 || wc[0] != 400) { return 31; }

  return 0;
}
