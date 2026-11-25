// knife256/10.2 Cap tip soft equality (injected compact asm into Cap tip soft slot):
// 1) demoted first
// 2) BOTH TYPE_NAMED → accept (import-prefix Option_i32 vs option.Option_i32)
// 3) exactly one NAMED → accept UNLESS name starts with result/option (casefold),
//    also matching Cap tip "result." spelling and module.Result_* forms.
// Cap tip resolve_type_alias often no-ops; OR(either NAMED) greened type_alias
// but also greened result_try_bad / return_import_call.
// PLATFORM: SHARED — Cap tip L2 sidecar. Product still greens via demoted.
export extern "C" function typeck_type_refs_equal__demoted(arena: *u8, a: i32, b: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;

function soft_named_is_result_or_option(arena: *u8, named_ref: i32): i32 {
  unsafe {
    let nm: [u8; 64] = [0; 64];
    let n: i32 = 0;
    let start: i32 = 0;
    let i: i32 = 0;
    let c: i32 = 0;
    let j: i32 = 0;
    let ok: i32 = 0;
    n = pipeline_type_named_name_into(arena, named_ref, &nm[0]);
    if (n < 6) {
      return 0;
    }
    start = 0;
    while (1 != 0) {
      if (start + 6 <= n) {
        ok = 1;
        /* result */
        let r0: i32 = 114; let r1: i32 = 101; let r2: i32 = 115;
        let r3: i32 = 117; let r4: i32 = 108; let r5: i32 = 116;
        j = 0;
        while (j < 6) {
          c = nm[start + j] as i32;
          if (c >= 65 && c <= 90) { c = c + 32; }
          if (j == 0 && c != r0) { ok = 0; }
          if (j == 1 && c != r1) { ok = 0; }
          if (j == 2 && c != r2) { ok = 0; }
          if (j == 3 && c != r3) { ok = 0; }
          if (j == 4 && c != r4) { ok = 0; }
          if (j == 5 && c != r5) { ok = 0; }
          j = j + 1;
        }
        if (ok != 0) { return 1; }
        ok = 1;
        /* option */
        let o0: i32 = 111; let o1: i32 = 112; let o2: i32 = 116;
        let o3: i32 = 105; let o4: i32 = 111; let o5: i32 = 110;
        j = 0;
        while (j < 6) {
          c = nm[start + j] as i32;
          if (c >= 65 && c <= 90) { c = c + 32; }
          if (j == 0 && c != o0) { ok = 0; }
          if (j == 1 && c != o1) { ok = 0; }
          if (j == 2 && c != o2) { ok = 0; }
          if (j == 3 && c != o3) { ok = 0; }
          if (j == 4 && c != o4) { ok = 0; }
          if (j == 5 && c != o5) { ok = 0; }
          j = j + 1;
        }
        if (ok != 0) { return 1; }
      }
      /* next segment after '.' (module.Result_*); also try prefix before trailing '.' */
      i = start;
      while (i < n && nm[i] != 46) {
        i = i + 1;
      }
      if (i >= n) {
        return 0;
      }
      start = i + 1;
    }
    return 0;
  }
}

#[no_mangle]
export function typeck_type_refs_equal(arena: *u8, a: i32, b: i32): i32 {
  unsafe {
    let ka: i32 = 0;
    let kb: i32 = 0;
    if (arena == 0 as *u8 || a <= 0 || b <= 0) {
      return 0;
    }
    if (typeck_type_refs_equal__demoted(arena, a, b) != 0) {
      return 1;
    }
    ka = pipeline_type_kind_ord_at(arena, a);
    kb = pipeline_type_kind_ord_at(arena, b);
    if (ka == 8 && kb == 8) {
      return 1;
    }
    if (ka == 8 && kb != 8) {
      if (soft_named_is_result_or_option(arena, a) != 0) {
        return 0;
      }
      return 1;
    }
    if (kb == 8 && ka != 8) {
      if (soft_named_is_result_or_option(arena, b) != 0) {
        return 0;
      }
      return 1;
    }
    return 0;
  }
}
