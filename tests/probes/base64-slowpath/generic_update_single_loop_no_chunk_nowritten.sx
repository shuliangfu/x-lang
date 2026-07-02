allow(padding) struct UpdateState {
  magic: u32
  mode: i32
  spare: i32
}

const UPDATE_STATE_MAGIC: u32 = 0x55504454;
const UPDATE_STATE_BYTES: i32 = 12;

extern function memset(s: *u8, c: i32, n: usize): *u8;

function update_state_cast(state: *u8, state_cap: i32): *UpdateState {
  let need: i32 = UPDATE_STATE_BYTES;
  if (state == 0 || state_cap < need) { return 0 as *UpdateState; }
  let s: *UpdateState = state as *UpdateState;
  if (s.magic != UPDATE_STATE_MAGIC) { return 0 as *UpdateState; }
  return s;
}

function update_state_init(state: *u8, state_cap: i32, mode: i32): i32 {
  let need: i32 = UPDATE_STATE_BYTES;
  let s: *UpdateState = 0 as *UpdateState;
  if (state == 0 || state_cap < need) { return -1; }
  unsafe { memset(state, 0, need); }
  s = state as *UpdateState;
  s.magic = UPDATE_STATE_MAGIC;
  s.mode = mode;
  return 0;
}

function update_emit_stub(s: *UpdateState, inp: *u8, n: i32, is_last: i32, out: *u8, out_cap: i32): i32 {
  if (s == 0 || inp == 0 || out == 0 || out_cap <= 0 || n <= 0) { return -1; }
  out[0] = inp[0];
  if (is_last != 0 && out_cap > 1) { out[1] = 33; }
  return 1;
}

function generic_update_single_loop_no_chunk_nowritten_c(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let s: *UpdateState = update_state_cast(state, state_cap);
  let cursor: *u8 = inp;
  let used_in: i32 = 0;
  let n: i32 = 0;
  if (s == 0) { return -1; }
  if (out == 0) { return -1; }
  if (out_cap <= 0) { return -1; }
  if (in_len > 0 && inp == 0) { return -1; }
  if (in_consumed != 0) { in_consumed[0] = 0; }
  while (used_in < in_len) {
    n = update_emit_stub(s, cursor, 1, ((used_in + 1) >= in_len && is_last != 0) as i32, out, out_cap);
    if (n < 0) {
      if (in_consumed != 0) { in_consumed[0] = used_in; }
      return -1;
    }
    cursor = cursor + 1;
    used_in = used_in + 1;
  }
  if (in_consumed != 0) { in_consumed[0] = used_in; }
  return 0;
}

function main(): i32 {
  let st: u8[16] = [];
  let out: u8[16] = [];
  let inp: u8[8] = [81, 85, 74, 68, 82, 69, 86, 71];
  let consumed: i32 = 0;
  if (update_state_init(&st[0], 16, 7) != 0) { return -1; }
  return generic_update_single_loop_no_chunk_nowritten_c(&st[0], 16, &inp[0], 8, &out[0], 16, 1, &consumed);
}
