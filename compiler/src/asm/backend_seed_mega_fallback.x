// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f：backend_seed_mega_fallback 产品源迁 seeds/backend_seed_mega_fallback.from_x.c。
// G-02f-104：+ ctx_reset / target_arch_local 薄门闩。
// G-02f-150：pipeline_seed_mega_ctx_reset 真迁 .x（label_counter@12 / module_ref@16 LE）

extern "C" function pipeline_dep_ctx_target_arch(ctx: *u8): i32;
extern "C" function memset(p: *u8, c: i32, n: i32): *u8;

function backend_seed_mega_fallback_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-104 / G-02f-150：seed mega helpers ---- */

// AsmFuncCtxLayout size=1336；label_counter@12 i32；module_ref@16 ptr
function mega_load_i32_le(p: *u8, off: i32): i32 {
  if (p == 0) { return 0; }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

function mega_store_i32_le(p: *u8, off: i32, v: i32): void {
  if (p == 0) { return; }
  let u: u32 = v as u32;
  p[off] = (u & 255) as u8;
  p[off + 1] = ((u / 256) & 255) as u8;
  p[off + 2] = ((u / 65536) & 255) as u8;
  p[off + 3] = ((u / 16777216) & 255) as u8;
}

function mega_store_ptr_le(p: *u8, off: i32, val: *u8): void {
  if (p == 0) { return; }
  let a: usize = val as usize;
  let m: usize = 256;
  p[off + 0] = (a % m) as u8;
  a = a / m;
  p[off + 1] = (a % m) as u8;
  a = a / m;
  p[off + 2] = (a % m) as u8;
  a = a / m;
  p[off + 3] = (a % m) as u8;
  a = a / m;
  p[off + 4] = (a % m) as u8;
  a = a / m;
  p[off + 5] = (a % m) as u8;
  a = a / m;
  p[off + 6] = (a % m) as u8;
  a = a / m;
  p[off + 7] = (a % m) as u8;
}

// G-02f-150：清零 ctx 保留 label_counter，写 module_ref
#[no_mangle]
function pipeline_seed_mega_ctx_reset(ctx: *u8, mod: *u8): void {
  if (ctx == 0) { return; }
  unsafe {
    let label_counter: i32 = mega_load_i32_le(ctx, 12);
    // sizeof(pipeline_glue_AsmFuncCtxLayout)=1336
    memset(ctx, 0, 1336);
    mega_store_i32_le(ctx, 12, label_counter);
    mega_store_ptr_le(ctx, 16, mod);
  }
}

#[no_mangle]
// G-02f-133：委托 pipeline_dep_ctx_target_arch
#[no_mangle]
function pipeline_dep_ctx_target_arch_local(ctx: *u8): i32 {
  if (ctx == 0) { return 0; }
  unsafe {
    return pipeline_dep_ctx_target_arch(ctx);
  }
  return 0;
}
