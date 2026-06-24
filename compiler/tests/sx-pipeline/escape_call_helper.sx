/** 探针：while 内 call 辅助函数，避免循环体内 if/else */
function esc_one(ch: u8, buf: *u8, i: i32, buf_cap: i32): i32 {
  if (ch == 34) {
    if (i + 2 > buf_cap) {
      return -1;
    }
    buf[i] = 34;
    i = i + 1;
    buf[i] = 34;
    i = i + 1;
    return i;
  }
  if (i >= buf_cap - 1) {
    return -1;
  }
  buf[i] = ch;
  i = i + 1;
  return i;
}

function escape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  if (buf_cap < 2) {
    return -1;
  }
  let i: i32 = 0;
  buf[i] = 34;
  i = i + 1;
  let j: i32 = 0;
  while (j < len) {
    i = esc_one(ptr[j], buf, i, buf_cap);
    if (i < 0) {
      return -1;
    }
    j = j + 1;
  }
  if (i >= buf_cap - 1) {
    return -1;
  }
  buf[i] = 34;
  i = i + 1;
  return i;
}

function main(): i32 {
  let line: u8[8] = [97, 98, 0, 0, 0, 0, 0, 0];
  let buf: u8[64] = [];
  let n: i32 = escape(&line[0], 2, &buf[0], 64);
  return n;
}
