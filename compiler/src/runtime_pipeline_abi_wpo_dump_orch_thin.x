// Thin pure: WPO dump ORCH peer-flat (export + collect/bfs/emit).
// G.7: body MUST match pipeline_typeck_wpo_dump_callgraph semantics in
// runtime_pipeline_abi.x / wpo_dump_thin (same exported symbol).
// Why separate leaf: Ubuntu tip -c of monolith wpo_dump_thin silently drops
// the file tail from wpo_dump_append_i32 onward (17 helpers through write
// stay; export never lands). Small orch file tip-emits the export both ends.
// wave503/514: local write/append/flush; tipU 21/21 + EXPORT_OK; PRODUCT
//   PREFER L2 SEGV 0/5 (x86_64 *i32 store: flush len[0], collect nedges_out,
//   export i32[1] cell). HARD BAN then; product stayed w498 -E helpers.
// wave594: no *i32 store (flush takes i32 by value; collect_all returns
//   i32; export drops i32[1]). LINUX PRODUCT PREFER still L2 SEGV 0/5
//   — keep HARD BAN orch; product stays w498 -E helpers.
// PLATFORM: SHARED freestanding WPO dump · LINUX gold + MACOS.

export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_body_expr_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern function pipeline_module_func_name_equal_at(m: *u8, fi: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_asm_module_func_is_extern_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_is_export_at(m: *u8, fi: i32): i32;
export extern function xlang_driver_fopen_write_opaque(path: *u8): *u8;
export extern function xlang_driver_fclose_opaque(fp: *u8): void;
export extern function xlang_driver_fwrite_opaque(data: *u8, len: i32, stream: *u8): i32;
export extern function xlang_driver_fwrite_stdout_n(data: *u8, len: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function wpo_dump_collect_block(
  a: *u8, m: *u8, br: i32, caller: i32, nfuncs: i32,
  edge_from: *i32, edge_to: *i32, nedges: *i32
): void;
export extern function wpo_dump_collect_expr(
  a: *u8, m: *u8, er: i32, caller: i32, nfuncs: i32,
  edge_from: *i32, edge_to: *i32, nedges: *i32, depth: i32
): void;
export extern function wpo_dump_env_path(out_path: *u8): i32;
export extern function wpo_dump_load_path(slot: *u8): *u8;
export extern function wpo_dump_max_funcs(): i32;

/**
 * Pipe-cell load i32 (wave498 tipU class).
 * @param base *u8
 * @return i32
 * PLATFORM: SHARED.
 */
function w503_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Pipe-cell load ptr (wave498 tipU class).
 * @param base *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
function w503_cell_ptr(base: *u8): *u8 {
  unsafe {
    return pipe_load_ptr_slot(base, 0);
  }
}

/*
 * Zeroed BSS tables — tip silent-drops large stack frames on the export.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
let g_w503_edge_from: i32[1024] = [];
let g_w503_edge_to: i32[1024] = [];
let g_w503_reach: u8[256] = [];
let g_w503_queue: i32[256] = [];
let g_w503_name: u8[256] = [];
let g_w503_buf: u8[512] = [];

/**
 * Local write (G.7 ≡ wpo_dump_write in thin).
 * @param fp *u8
 * @param use_stdout i32
 * @param data *u8
 * @param len i32
 * @return void
 * PLATFORM: SHARED.
 */
function w503_write(fp: *u8, use_stdout: i32, data: *u8, len: i32): void {
  if (data == 0 as *u8 || len <= 0) {
    return;
  }
  if (use_stdout != 0) {
    unsafe {
      xlang_driver_fwrite_stdout_n(data, len);
    }
    return;
  }
  if (fp == 0 as *u8) {
    return;
  }
  unsafe {
    xlang_driver_fwrite_opaque(data, len, fp);
  }
}

/**
 * Local append decimal i32 (G.7 ≡ wpo_dump_append_i32).
 * Local (not extern) so tip keeps `blen=call()` mid-assign.
 * @param buf *u8
 * @param cap i32
 * @param len i32
 * @param v i32
 * @return i32 — updated length
 * PLATFORM: SHARED.
 */
function w503_append_i32(buf: *u8, cap: i32, len: i32, v: i32): i32 {
  let tmp: u8[16];
  let n: i32 = 0;
  let x: i32 = v;
  let neg: i32 = 0;
  let i: i32 = 0;
  if (buf == 0 as *u8 || cap <= 0 || len < 0 || len >= cap) {
    return len;
  }
  if (x == 0) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = 48;
    }
    return len + 1;
  }
  if (x < 0) {
    neg = 1;
    x = 0 - x;
  }
  while (x > 0 && n < 16) {
    unsafe {
      tmp[n] = ((x % 10) + 48) as u8;
    }
    n = n + 1;
    x = x / 10;
  }
  if (neg != 0) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = 45;
    }
    len = len + 1;
  }
  i = n - 1;
  while (i >= 0) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = tmp[i];
    }
    len = len + 1;
    i = i - 1;
  }
  return len;
}

/**
 * Local append ASCII literal (G.7 ≡ wpo_dump_append_lit).
 * @param buf *u8
 * @param cap i32
 * @param len i32
 * @param lit *u8
 * @param lit_len i32
 * @return i32
 * PLATFORM: SHARED.
 */
function w503_append_lit(buf: *u8, cap: i32, len: i32, lit: *u8, lit_len: i32): i32 {
  let i: i32 = 0;
  if (buf == 0 as *u8 || lit == 0 as *u8 || lit_len <= 0) {
    return len;
  }
  while (i < lit_len) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = lit[i];
    }
    len = len + 1;
    i = i + 1;
  }
  return len;
}

/**
 * Local flush (G.7 ≡ wpo_dump_flush write side).
 * Length is by-value so this leaf never stores through *i32 (Ubuntu
 * x86_64 -backend asm SEGV 139 class). Caller zeros its length after.
 * @param fp *u8 — FILE* or unused when stdout
 * @param use_stdout i32 — nonzero → stdout
 * @param buf *u8 — bytes to write
 * @param n i32 — byte count; n<=0 is a no-op
 * @return void
 * PLATFORM: SHARED.
 */
function w503_flush(fp: *u8, use_stdout: i32, buf: *u8, n: i32): void {
  if (n > 0) {
    w503_write(fp, use_stdout, buf, n);
  }
}

/**
 * Collect CALL/METHOD edges for all funcs into g_w503_edge_*.
 * Returns the edge count instead of storing through *i32 (Ubuntu x86_64
 * SEGV 139 class). Extern collect_block/expr still take *i32 nedges;
 * those stores live in the LINUX -E helper overlay (host-cc), not here.
 * @param m *u8 — Module*
 * @param a *u8 — ASTArena*
 * @param nfuncs i32 — capped func count
 * @return i32 — edge count written into g_w503_edge_*
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
function w503_wpo_collect_all(m: *u8, a: *u8, nfuncs: i32): i32 {
  let cell: u8[8] = [];
  let fi: i32 = 0;
  let br: i32 = 0;
  let ber: i32 = 0;
  let nedges: i32 = 0;
  while (fi < nfuncs) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_module_func_body_ref_at(m, fi));
      br = w503_cell_i32(&cell[0]);
      if (br > 0) {
        wpo_dump_collect_block(a, m, br, fi, nfuncs, &g_w503_edge_from[0], &g_w503_edge_to[0], &nedges);
      } else {
        pipe_store_i32_le(&cell[0], 0, pipeline_module_func_body_expr_ref_at(m, fi));
        ber = w503_cell_i32(&cell[0]);
        wpo_dump_collect_expr(a, m, ber, fi, nfuncs, &g_w503_edge_from[0], &g_w503_edge_to[0], &nedges, 0);
      }
    }
    fi = fi + 1;
  }
  return nedges;
}

/**
 * BFS reachability from root into g_w503_reach / g_w503_queue.
 * @param root i32
 * @param nfuncs i32
 * @param nedges i32
 * @return void
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
function w503_wpo_bfs(root: i32, nfuncs: i32, nedges: i32): void {
  let qh: i32 = 0;
  let qt: i32 = 1;
  let ei: i32 = 0;
  let to: i32 = 0;
  let cur: i32 = 0;
  let fi: i32 = 0;
  while (fi < nfuncs) {
    unsafe {
      g_w503_reach[fi] = 0;
    }
    fi = fi + 1;
  }
  if (root < 0 || root >= nfuncs) {
    return;
  }
  unsafe {
    g_w503_reach[root] = 1;
    g_w503_queue[0] = root;
  }
  while (qh < qt) {
    unsafe {
      cur = g_w503_queue[qh];
    }
    qh = qh + 1;
    ei = 0;
    while (ei < nedges) {
      unsafe {
        if (g_w503_edge_from[ei] == cur) {
          to = g_w503_edge_to[ei];
          if (to >= 0 && to < nfuncs && g_w503_reach[to] == 0) {
            g_w503_reach[to] = 1;
            if (qt < 256) {
              g_w503_queue[qt] = to;
              qt = qt + 1;
            }
          }
        }
      }
      ei = ei + 1;
    }
  }
}

/**
 * Emit JSON v2 to fp/stdout (local append — tip keeps mid assign).
 * @param m *u8
 * @param fp *u8
 * @param use_stdout i32
 * @param root i32
 * @param nfuncs i32
 * @param nedges i32
 * @return void
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
function w503_wpo_emit(m: *u8, fp: *u8, use_stdout: i32, root: i32, nfuncs: i32, nedges: i32): void {
  let cell: u8[8] = [];
  let fi: i32 = 0;
  let ei: i32 = 0;
  let nlen: i32 = 0;
  let is_ext: i32 = 0;
  let blen: i32 = 0;
  let first: i32 = 0;
  let s_ver: u8[18] = [123, 10, 32, 32, 34, 118, 101, 114, 115, 105, 111, 110, 34, 58, 32, 50, 44, 10];
  let s_entry: u8[15] = [32, 32, 34, 101, 110, 116, 114, 121, 34, 58, 32, 34, 34, 44, 10];
  let s_mods: u8[46] = [
    32, 32, 34, 109, 111, 100, 117, 108, 101, 115, 34, 58, 32, 91, 10,
    32, 32, 32, 32, 123, 34, 105, 100, 34, 58, 32, 48, 44, 32, 34, 112, 97, 116, 104, 34, 58, 32, 34, 34, 125, 10,
    32, 32, 93, 44, 10
  ];
  let s_funcs_open: u8[17] = [32, 32, 34, 102, 117, 110, 99, 116, 105, 111, 110, 115, 34, 58, 32, 91, 10];
  let s_comma_nl: u8[2] = [44, 10];
  let s_fn_head: u8[11] = [32, 32, 32, 32, 123, 34, 105, 100, 34, 58, 32];
  let s_fn_mid: u8[24] = [44, 32, 34, 109, 111, 100, 117, 108, 101, 34, 58, 32, 48, 44, 32, 34, 110, 97, 109, 101, 34, 58, 32, 34];
  let s_ext_key: u8[13] = [34, 44, 32, 34, 101, 120, 116, 101, 114, 110, 34, 58, 32];
  let s_true: u8[4] = [116, 114, 117, 101];
  let s_false: u8[5] = [102, 97, 108, 115, 101];
  let s_reach_key: u8[15] = [44, 32, 34, 114, 101, 97, 99, 104, 97, 98, 108, 101, 34, 58, 32];
  let s_close_obj: u8[1] = [125];
  let s_arr_close: u8[6] = [10, 32, 32, 93, 44, 10];
  let s_edges_open: u8[13] = [32, 32, 34, 101, 100, 103, 101, 115, 34, 58, 32, 91, 10];
  let s_edge_from: u8[13] = [32, 32, 32, 32, 123, 34, 102, 114, 111, 109, 34, 58, 32];
  let s_edge_to: u8[8] = [44, 32, 34, 116, 111, 34, 58, 32];
  let s_tail: u8[30] = [
    32, 32, 34, 99, 97, 108, 108, 95, 115, 105, 116, 101, 115, 34, 58, 32, 91, 93, 44, 10,
    32, 32, 34, 114, 111, 111, 116, 34, 58, 32
  ];
  let s_end: u8[3] = [10, 125, 10];
  blen = 0;
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_ver[0], 18);
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_entry[0], 15);
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_mods[0], 46);
  w503_flush(fp, use_stdout, &g_w503_buf[0], blen);
  blen = 0;
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_funcs_open[0], 17);
  w503_flush(fp, use_stdout, &g_w503_buf[0], blen);
  blen = 0;
  first = 1;
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_module_func_name_len_at(m, fi));
      nlen = w503_cell_i32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_is_extern_at(m, fi));
      is_ext = w503_cell_i32(&cell[0]);
    }
    if (nlen < 0) {
      nlen = 0;
    }
    if (nlen >= 128) {
      nlen = 127;
    }
    if (nlen > 0) {
      unsafe {
        pipeline_module_func_name_copy64(m, fi, &g_w503_name[0]);
      }
    }
    blen = 0;
    if (first == 0) {
      blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_comma_nl[0], 2);
    }
    first = 0;
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_fn_head[0], 11);
    blen = w503_append_i32(&g_w503_buf[0], 512, blen, fi);
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_fn_mid[0], 24);
    if (nlen > 0) {
      blen = w503_append_lit(&g_w503_buf[0], 512, blen, &g_w503_name[0], nlen);
    }
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_ext_key[0], 13);
    if (is_ext != 0) {
      blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_true[0], 4);
    } else {
      blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_false[0], 5);
    }
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_reach_key[0], 15);
    unsafe {
      if (g_w503_reach[fi] != 0) {
        blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_true[0], 4);
      } else {
        blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_false[0], 5);
      }
    }
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_close_obj[0], 1);
    w503_flush(fp, use_stdout, &g_w503_buf[0], blen);
    blen = 0;
    fi = fi + 1;
  }
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_arr_close[0], 6);
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_edges_open[0], 13);
  w503_flush(fp, use_stdout, &g_w503_buf[0], blen);
  blen = 0;
  first = 1;
  ei = 0;
  while (ei < nedges) {
    blen = 0;
    if (first == 0) {
      blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_comma_nl[0], 2);
    }
    first = 0;
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_edge_from[0], 13);
    unsafe {
      blen = w503_append_i32(&g_w503_buf[0], 512, blen, g_w503_edge_from[ei]);
    }
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_edge_to[0], 8);
    unsafe {
      blen = w503_append_i32(&g_w503_buf[0], 512, blen, g_w503_edge_to[ei]);
    }
    blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_close_obj[0], 1);
    w503_flush(fp, use_stdout, &g_w503_buf[0], blen);
    blen = 0;
    ei = ei + 1;
  }
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_arr_close[0], 6);
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_tail[0], 30);
  blen = w503_append_i32(&g_w503_buf[0], 512, blen, root);
  blen = w503_append_lit(&g_w503_buf[0], 512, blen, &s_end[0], 3);
  w503_flush(fp, use_stdout, &g_w503_buf[0], blen);
  blen = 0;
}

/**
 * WPO-S1 callgraph dump after successful typeck (orch tip export).
 * Gated by XLANG_WPO_DUMP_CALLGRAPH=<path> or "-" (stdout).
 * @param m *u8 - Module*
 * @param a *u8 - ASTArena*
 * @param ctx *u8 - PipelineDepCtx* (unused; reserved)
 * @return i32 - 1 if dumped, 0 if skipped/failed open
 * wave594: no local i32[1] / *i32 store (Ubuntu x86_64 SEGV 139 class).
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function pipeline_typeck_wpo_dump_callgraph(m: *u8, a: *u8, ctx: *u8): i32 {
  let cell: u8[8] = [];
  let pcell: u8[8] = [];
  let path_slot: u8[8] = [];
  let path: *u8 = 0 as *u8;
  let use_stdout: i32 = 0;
  let fp: *u8 = 0 as *u8;
  let nfuncs: i32 = 0;
  let fi: i32 = 0;
  let root: i32 = -1;
  let nedges: i32 = 0;
  let maxf: i32 = 0;
  let _ctx_unused: *u8 = ctx;
  if (m == 0 as *u8 || a == 0 as *u8) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, wpo_dump_env_path(&path_slot[0]));
    if (w503_cell_i32(&cell[0]) == 0) {
      return 0;
    }
    pipe_store_ptr_slot(&pcell[0], 0, wpo_dump_load_path(&path_slot[0]));
    path = w503_cell_ptr(&pcell[0]);
  }
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (path[0] == 45 && path[1] == 0) {
      use_stdout = 1;
    } else {
      pipe_store_ptr_slot(&pcell[0], 0, xlang_driver_fopen_write_opaque(path));
      fp = w503_cell_ptr(&pcell[0]);
    }
  }
  if (use_stdout == 0 && fp == 0 as *u8) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_module_num_funcs(m));
    nfuncs = w503_cell_i32(&cell[0]);
  }
  if (nfuncs <= 0) {
    if (use_stdout == 0) {
      unsafe {
        xlang_driver_fclose_opaque(fp);
      }
    }
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, wpo_dump_max_funcs());
    maxf = w503_cell_i32(&cell[0]);
  }
  if (nfuncs > maxf) {
    nfuncs = maxf;
  }
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_module_func_name_equal_at(m, fi, "main", 4));
      if (w503_cell_i32(&cell[0]) != 0) {
        root = fi;
        break;
      }
    }
    fi = fi + 1;
  }
  if (root < 0) {
    fi = 0;
    while (fi < nfuncs) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipeline_module_func_name_equal_at(m, fi, "entry", 5));
        if (w503_cell_i32(&cell[0]) != 0) {
          root = fi;
          break;
        }
      }
      fi = fi + 1;
    }
  }
  if (root < 0) {
    fi = 0;
    while (fi < nfuncs) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipeline_module_func_is_export_at(m, fi));
        if (w503_cell_i32(&cell[0]) != 0) {
          root = fi;
          break;
        }
      }
      fi = fi + 1;
    }
  }
  if (root < 0) {
    root = 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, w503_wpo_collect_all(m, a, nfuncs));
    nedges = w503_cell_i32(&cell[0]);
  }
  w503_wpo_bfs(root, nfuncs, nedges);
  w503_wpo_emit(m, fp, use_stdout, root, nfuncs, nedges);
  if (use_stdout == 0) {
    unsafe {
      xlang_driver_fclose_opaque(fp);
    }
  }
  return 1;
}
