// json_import_alias.x — import binding -o 链接桩（从 .c 转换）

extern function json_parse_number_c(ptr: *u8, len: i32, out_val: *double, consumed: *i32): i32;
extern function json_parse_null_c(ptr: *u8, len: i32, consumed: *i32): i32;
extern function json_parse_bool_c(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32;
extern function json_escape_c(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32;
extern function json_append_null_c(buf: *u8, buf_cap: i32): i32;
extern function json_append_bool_c(buf: *u8, buf_cap: i32, val: i32): i32;
extern function json_append_number_c(buf: *u8, buf_cap: i32, val: double): i32;
extern function json_skip_value_c(ptr: *u8, len: i32, consumed: *i32): i32;
extern function json_cursor_init_c(cur: *ShuxJsonCursor, ptr: *u8, len: i32): void;
extern function json_cursor_enter_object_c(cur: *ShuxJsonCursor): i32;
extern function json_cursor_skip_value_c(cur: *ShuxJsonCursor): i32;
extern function json_cursor_enter_array_c(cur: *ShuxJsonCursor): i32;
extern function json_cursor_array_has_elem_c(cur: *ShuxJsonCursor): i32;
extern function json_cursor_value_type_c(cur: *ShuxJsonCursor): i32;
extern function json_decode_i32_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32;
extern function json_decode_f64_at_c(ptr: *u8, len: i32, consumed: *i32, out: *double): i32;
extern function json_decode_bool_at_c(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32;
extern function json_typed_decode_smoke_c(): i32;

function std_json_parse_number(ptr: *u8, len: i32, out_val: *double, consumed: *i32): i32 { return json_parse_number_c(ptr, len, out_val, consumed); }
function std_json_parse_null(ptr: *u8, len: i32, consumed: *i32): i32 { return json_parse_null_c(ptr, len, consumed); }
function std_json_parse_bool(ptr: *u8, len: i32, out: *i32, consumed: *i32): i32 { return json_parse_bool_c(ptr, len, out, consumed); }
function std_json_parse_string(ptr: *u8, len: i32, out: *u8, out_cap: i32, consumed: *i32): i32 { return 0 as i32; }
function std_json_escape_string(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 { return json_escape_c(ptr, len, buf, buf_cap); }
function std_json_append_null(buf: *u8, buf_cap: i32): i32 { return json_append_null_c(buf, buf_cap); }
function std_json_append_bool(buf: *u8, buf_cap: i32, val: i32): i32 { return json_append_bool_c(buf, buf_cap, val); }
function std_json_append_number(buf: *u8, buf_cap: i32, val: double): i32 { return json_append_number_c(buf, buf_cap, val); }
function std_json_skip_value(ptr: *u8, len: i32, consumed: *i32): i32 { return json_skip_value_c(ptr, len, consumed); }
function std_json_cursor_init(cur: *ShuxJsonCursor, ptr: *u8, len: i32): void { json_cursor_init_c(cur, ptr, len); }
function std_json_cursor_enter_object(cur: *ShuxJsonCursor): i32 { return json_cursor_enter_object_c(cur); }
function std_json_cursor_object_next(cur: *ShuxJsonCursor, key_buf: *u8, key_cap: i32, key_len: *i32): i32 { return 0 as i32; }
function std_json_cursor_skip_value(cur: *ShuxJsonCursor): i32 { return json_cursor_skip_value_c(cur); }
function std_json_cursor_enter_array(cur: *ShuxJsonCursor): i32 { return json_cursor_enter_array_c(cur); }
function std_json_cursor_array_has_elem(cur: *ShuxJsonCursor): i32 { return json_cursor_array_has_elem_c(cur); }
function std_json_cursor_value_type(cur: *ShuxJsonCursor): i32 { return json_cursor_value_type_c(cur); }
function std_json_decode_i32_at(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 { return json_decode_i32_at_c(ptr, len, consumed, out); }
function std_json_decode_f64_at(ptr: *u8, len: i32, consumed: *i32, out: *double): i32 { return json_decode_f64_at_c(ptr, len, consumed, out); }
function std_json_decode_bool_at(ptr: *u8, len: i32, consumed: *i32, out: *i32): i32 { return json_decode_bool_at_c(ptr, len, consumed, out); }
function std_json_decode_string_at(ptr: *u8, len: i32, out: *u8, out_cap: i32, out_len: *i32, consumed: *i32): i32 { return 0 as i32; }
function std_json_typed_decode_smoke(): i32 { return json_typed_decode_smoke_c(); }
function std_json_json_view_needs_copy(): i32 { return 0 as i32; }
function std_json_json_decode_missing(): i32 { return 0 as i32; }
