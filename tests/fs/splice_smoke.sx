/**
 * ZC-5 smoke：fs_pipe_splice 文件→文件（经内核 pipe 中转）。
 * 写入 /tmp/fs_splice_in → splice → /tmp/fs_splice_out → 读回校验；exit 0。
 */
const fs = import("std.fs");

function main(): i32 {
  /** "/tmp/fs_splice_in\0" */
  let path_in: u8[18] =
  [47, 116, 109, 112, 47, 102, 115, 95, 115, 112, 108, 105, 99, 101, 95, 105, 110, 0];
  /** "/tmp/fs_splice_out\0" */
  let path_out: u8[19] =
  [47, 116, 109, 112, 47, 102, 115, 95, 115, 112, 108, 105, 99, 101, 95, 111, 117, 116, 0];
  let payload: u8[16] =
  [90, 67, 53, 32, 115, 112, 108, 105, 99, 101, 32, 79, 75, 10, 0, 0];
  let pay_len: usize = 14 as usize;
  let fd_w: i32 = fs.create(&path_in[0]);
  if (fd_w < 0) { return 1; }
  let nw: isize = fs.write(fd_w, &payload[0], pay_len);
  if (fs.sync(fd_w) != 0) {
    fs.close(fd_w);
    return 2;
  }
  fs.close(fd_w);
  if (nw != (pay_len as isize)) { return 3; }
  let fd_in: i32 = fs.open(&path_in[0]);
  if (fd_in < 0) { return 4; }
  let fd_out: i32 = fs.create(&path_out[0]);
  if (fd_out < 0) {
    fs.close(fd_in);
    return 5;
  }
  let copied: i64 = fs.pipe_splice(fd_in, fd_out, pay_len);
  if (fs.sync(fd_out) != 0) {
    fs.close(fd_in);
    fs.close(fd_out);
    return 6;
  }
  fs.close(fd_in);
  fs.close(fd_out);
  if (copied != (pay_len as i64)) { return 7; }
  let fd_r: i32 = fs.open(&path_out[0]);
  if (fd_r < 0) { return 8; }
  let buf: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let nr: isize = fs.read(fd_r, &buf[0], pay_len);
  fs.close(fd_r);
  if (nr != (pay_len as isize)) { return 9; }
  let i: i32 = 0;
  while (i < 14) {
    if (buf[i] != payload[i]) { return 10; }
    i = i + 1;
  }
  return 0;
}
