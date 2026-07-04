// base64_import_alias.x — import binding -o 链接桩（从 .c 转换）

extern function base64_stream_state_bytes_c(): i32;
extern function base64_stream_enc_init_c(state: *u8, state_cap: i32, url: i32): i32;
extern function base64_stream_dec_init_c(state: *u8, state_cap: i32, url: i32): i32;

function std_base64_encode_standard(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 { return 0 as i32; }
function std_base64_encode_url(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 { return 0 as i32; }
function std_base64_decode_standard(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 { return 0 as i32; }
function std_base64_decode_url(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 { return 0 as i32; }
function std_base64_stream_state_bytes(): i32 { return base64_stream_state_bytes_c(); }
function std_base64_stream_enc_init(state: *u8, state_cap: i32, url: i32): i32 { return base64_stream_enc_init_c(state, state_cap, url); }
function std_base64_stream_dec_init(state: *u8, state_cap: i32, url: i32): i32 { return base64_stream_dec_init_c(state, state_cap, url); }
function std_base64_stream_enc_update(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 { return 0 as i32; }
function std_base64_stream_dec_update(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 { return 0 as i32; }
