extern function parser_diag_fail_at_token_kind_buf_glue(data: *u8, len: i32): i32;
extern "C" function std_fs_open(path: *u8): i32;
extern "C" function std_fs_read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function std_fs_close(fd: i32): i32;

function main(): i32 {
  let path: u8[31] = [112, 97, 114, 115, 101, 114, 95, 101, 110, 116, 114, 121, 95, 112, 97, 114, 97, 109, 95, 111, 110, 108, 121, 95, 109, 105, 110, 46, 115, 120, 0];
  let buf: u8[256] = [];
  unsafe {
    let fd: i32 = std_fs_open(&path[0]);
    if (fd < 0) {
      return 250;
    }
    let n: isize = std_fs_read(fd, &buf[0], 255 as usize);
    std_fs_close(fd);
    if (n <= 0) {
      return 251;
    }
    return parser_diag_fail_at_token_kind_buf_glue(&buf[0], n as i32);
  }
}
