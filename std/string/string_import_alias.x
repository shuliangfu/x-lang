// string_import_alias.x — import binding -o 链接桩（从 .c 转换）

extern function shux_string_memcmp_c(a: *u8, b: *u8, n: i32): i32;
extern function shux_string_memmem_c(hay: *u8, hay_len: i32, needle: *u8, needle_len: i32): i32;
extern function shux_string_copy_c(dst: *u8, src: *u8, n: i32): void;
extern function shux_string_memchr_c(ptr: *u8, c: u8, n: i32): i32;
extern function shux_string_memrchr_c(ptr: *u8, c: u8, n: i32): i32;
extern function shux_string_memcmp_at_c(a: *u8, off: i32, b: *u8, n: i32): i32;

function std_string_string_empty(): i32 { return 0 as i32; }
function std_string_string_capacity(): i32 { return 0 as i32; }
function std_string_string_len(s: *ShuxString): i32 { return 0 as i32; }
function std_string_string_len_ptr(slot: *u8): i32 { return 0 as i32; }
function std_string_string_is_empty(s: *ShuxString): i32 { return 0 as i32; }
function std_string_string_get(s: *ShuxString, i: i32): u8 { return 0 as u8; }
function std_string_string_eq(a: *ShuxString, b: *ShuxString): i32 { return 0 as i32; }
function std_string_string_compare(a: *ShuxString, b: *ShuxString): i32 { return 0 as i32; }
function std_string_string_append_char(slot: *u8, c: u8): i32 { return 0 as i32; }
function std_string_string_append_slice(slot: *u8, ptr: *u8, len: i32): i32 { return 0 as i32; }
function std_string_string_copy_to(s: *ShuxString, out: *u8, out_max: i32): void { }
function std_string_string_find_char(s: *ShuxString, c: u8): void { }
function std_string_string_starts_with(s: *ShuxString, prefix: *u8, prefix_len: i32): i32 { return 0 as i32; }
function std_string_string_ends_with(s: *ShuxString, suffix: *u8, suffix_len: i32): i32 { return 0 as i32; }
function std_string_string_find_slice(s: *ShuxString, sub: *u8, sub_len: i32): i32 { return 0 as i32; }
function std_string_string_contains(s: *ShuxString, sub: *u8, sub_len: i32): i32 { return 0 as i32; }
function std_string_string_rfind_char(s: *ShuxString, c: u8): i32 { return 0 as i32; }
function std_string_string_trim_space(s: *ShuxString, out: *u8, out_max: i32): i32 { return 0 as i32; }
function std_string_string_replace_char(slot: *u8, from: u8, to: u8): i32 { return 0 as i32; }
function std_string_string_view_len(v: *ShuxStrView): i32 { return 0 as i32; }
function std_string_string_view_is_empty(v: *ShuxStrView): i32 { return 0 as i32; }
function std_string_string_view_get(v: *ShuxStrView, i: i32): u8 { return 0 as u8; }
function std_string_string_view_eq(a: *ShuxStrView, b: *ShuxStrView): i32 { return 0 as i32; }
function std_string_string_view_compare(a: *ShuxStrView, b: *ShuxStrView): i32 { return 0 as i32; }
function std_string_string_view_find_char(v: *ShuxStrView, c: u8): void { }
function std_string_string_view_starts_with(v: *ShuxStrView, prefix: *u8, prefix_len: i32): i32 { return 0 as i32; }
function std_string_string_view_ends_with(v: *ShuxStrView, suffix: *u8, suffix_len: i32): i32 { return 0 as i32; }
function std_string_string_view_find_slice(v: *ShuxStrView, sub: *u8, sub_len: i32): i32 { return 0 as i32; }
function std_string_string_view_contains(v: *ShuxStrView, sub: *u8, sub_len: i32): i32 { return 0 as i32; }
function std_string_string_eq_view(s: *ShuxString, v: *ShuxStrView): i32 { return 0 as i32; }
function std_string_string_compare_view(s: *ShuxString, v: *ShuxStrView): i32 { return 0 as i32; }
