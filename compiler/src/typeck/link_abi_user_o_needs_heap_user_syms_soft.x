/* knife256/10.2 Cap tip: string.o leaf carries U std_heap_arena64_alloc but
 * may not be on ld argv as a probed .o (archive / implicit). Also probe
 * std/string/string.o so encoding/string consumers get heap.o.
 * PLATFORM: SHARED Cap tip Darwin. */
export extern function link_abi_user_o_needs_heap_user_syms__demoted(user_o: *u8): i32;
export extern function xlang_link_obj_needs_undef_sym_impl(path: *u8, sym: *u8): i32;

#[no_mangle]
export function link_abi_user_o_needs_heap_user_syms(user_o: *u8): i32 {
  unsafe {
    let lit: u8[64] = [];
    let sym: u8[32] = [];
    if (link_abi_user_o_needs_heap_user_syms__demoted(user_o) != 0) {
      return 1;
    }
    /* std/string/string.o */
    lit[0] = 115; lit[1] = 116; lit[2] = 100; lit[3] = 47;
    lit[4] = 115; lit[5] = 116; lit[6] = 114; lit[7] = 105;
    lit[8] = 110; lit[9] = 103; lit[10] = 47; lit[11] = 115;
    lit[12] = 116; lit[13] = 114; lit[14] = 105; lit[15] = 110;
    lit[16] = 103; lit[17] = 46; lit[18] = 111; lit[19] = 0;
    sym[0] = 115; sym[1] = 116; sym[2] = 100; sym[3] = 95;
    sym[4] = 104; sym[5] = 101; sym[6] = 97; sym[7] = 112;
    sym[8] = 95; sym[9] = 97; sym[10] = 114; sym[11] = 101;
    sym[12] = 110; sym[13] = 97; sym[14] = 54; sym[15] = 52;
    sym[16] = 95; sym[17] = 97; sym[18] = 108; sym[19] = 108;
    sym[20] = 111; sym[21] = 99; sym[22] = 0;
    if (xlang_link_obj_needs_undef_sym_impl(&lit[0], &sym[0]) != 0) {
      return 1;
    }
    return 0;
  }
}
