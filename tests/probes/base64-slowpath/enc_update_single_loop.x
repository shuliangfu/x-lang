allow(padding) struct B64Stream {
  magic: u32
  is_url: i32
  is_enc: i32
  pending_len: i32
  pending: u8[3]
  dec_len: i32
  dec_pending: u8[4]
}

const SHU_B64_STREAM_MAGIC: u32 = 0x42345354;
const B64_STREAM_STATE_BYTES: i32 = 28;

extern function memset(s: *u8, c: i32, n: usize): *u8;

function b64_stream_cast(state: *u8, state_cap: i32): *B64Stream {
  let need: i32 = B64_STREAM_STATE_BYTES;
  if (state == 0 || state_cap < need) { return 0 as *B64Stream; }
  let s: *B64Stream = state as *B64Stream;
  if (s.magic != SHU_B64_STREAM_MAGIC) { return 0 as *B64Stream; }
  return s;
}

function base64_stream_enc_init_c(state: *u8, state_cap: i32, url: i32): i32 {
  let need: i32 = B64_STREAM_STATE_BYTES;
  let s: *B64Stream = 0 as *B64Stream;
  if (state == 0 || state_cap < need) { return -1; }
  unsafe { memset(state, 0, need); }
  s = state as *B64Stream;
  s.magic = SHU_B64_STREAM_MAGIC;
  s.is_url = (url != 0) ? 1 : 0;
  s.is_enc = 1;
  return 0;
}

function emit_stub(s: *B64Stream, tri: *u8, n: i32, is_last: i32, out: *u8, out_cap: i32): i32 {
  if (s == 0 || tri == 0 || out == 0 || out_cap <= 0 || n <= 0) { return -1; }
  out[0] = tri[0];
  if (n > 1 && out_cap > 1) { out[1] = tri[1]; }
  if (is_last != 0) { return 1; }
  return 1;
}

function base64_stream_enc_update_single_loop_c(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let s: *B64Stream = b64_stream_cast(state, state_cap);
  let used_in: i32 = 0;
  let written: i32 = 0;
  let chunk: i32 = 0;
  let n: i32 = 0;
  if (s == 0) { return -1; }
  if (s.is_enc == 0) { return -1; }
  if (out == 0) { return -1; }
  if (out_cap <= 0) { return -1; }
  if (in_len > 0 && inp == 0) { return -1; }
  if (in_consumed != 0) { in_consumed[0] = 0; }
  while (used_in < in_len) {
    chunk = 3;
    if (in_len - used_in < 3) { chunk = in_len - used_in; }
    if (chunk <= 0) { break; }
    n = emit_stub(s, inp + used_in, chunk, ((used_in + chunk) >= in_len && is_last != 0) as i32, out, out_cap);
    if (n < 0) {
      if (in_consumed != 0) { in_consumed[0] = used_in; }
      return -1;
    }
    used_in = used_in + chunk;
    written = written + n;
  }
  if (in_consumed != 0) { in_consumed[0] = used_in; }
  return written;
}

function main(): i32 {
  let st: u8[32] = [];
  let out: u8[16] = [];
  let inp: u8[5] = [104, 101, 108, 108, 111];
  let consumed: i32 = 0;
  if (base64_stream_enc_init_c(&st[0], 32, 0) != 0) { return -1; }
  return base64_stream_enc_update_single_loop_c(&st[0], 32, &inp[0], 5, &out[0], 16, 1, &consumed);
}
