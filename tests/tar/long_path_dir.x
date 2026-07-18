// See implementation.
//
// See implementation.
const tar = import("std.tar");

/** Internal function `prefix_eq`.
 * Implements `prefix_eq`.
 * @param name_out *u8
 * @param expect *u8
 * @param len i32
 * @return bool
 */
function prefix_eq(name_out: *u8, expect: *u8, len: i32): bool {
  let i: i32 = 0;
  while (i < len) {
    if (name_out[i] != expect[i]) {
      return false;
    }
    i = i + 1;
  }
  if (name_out[len] != 0) {
    return false;
  }
  return true;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arc: u8[8192] = [];
  let off: i32 = 0;

  /* See implementation. */
  let path: u8[128] = [];
  let i: i32 = 0;
  while (i < 60) {
    path[i] = 97;
    i = i + 1;
  }
  let tail: u8[16] = [47, 110, 101, 115, 116, 101, 100, 47, 102, 105, 108, 101, 46, 115, 117, 0];
  let j: i32 = 0;
  while (j < 15) {
    path[i] = tail[j];
    i = i + 1;
    j = j + 1;
  }
  let path_len: i32 = i;

  let data: u8[1] = [88];
  if (tar.append_entry(&arc[0], 8192, &off, &path[0], path_len, &data[0], 1, 0) != 0) {
    return 1;
  }

  /* See implementation. */
  let dir: u8[64] = [];
  i = 0;
  while (i < 40) {
    dir[i] = 100;
    i = i + 1;
  }
  let dtail: u8[6] = [47, 100, 101, 101, 112, 47];
  j = 0;
  while (j < 6) {
    dir[i] = dtail[j];
    i = i + 1;
    j = j + 1;
  }
  let dir_len: i32 = i;
  if (tar.append_entry(&arc[0], 8192, &off, &dir[0], dir_len, 0 as *u8, 0, 1) != 0) {
    return 2;
  }

  /* See implementation. */
  let pax_path: u8[280] = [];
  i = 0;
  while (i < 270) {
    pax_path[i] = 112;
    i = i + 1;
  }
  let pdata: u8[1] = [81];
  if (tar.append_entry(&arc[0], 8192, &off, &pax_path[0], 270, &pdata[0], 1, 0) != 0) {
    return 3;
  }

  let z: i32 = 0;
  while (z < 512 && off < 8192) {
    arc[off] = 0;
    off = off + 1;
    z = z + 1;
  }
  let arc_len: i32 = off;

  if (path_max() != 512) {
    return 4;
  }

  let pos: i32 = 0;
  let name_out: u8[520] = [];
  let sz: i32 = 0;
  let typ: i32 = 0;
  let got_file: i32 = 0;
  let got_dir: i32 = 0;
  let got_pax: i32 = 0;

  while (pos < arc_len) {
    let entry_off: i32 = pos;
    let nr: i32 = tar.next_entry(&arc[0], arc_len, &pos, &name_out[0], 520, &sz, &typ);
    if (nr == 1) {
      break;
    }
    if (nr != 0) {
      return 5;
    }
    if (typ == 53) {
      got_dir = got_dir + 1;
      if (!prefix_eq(&name_out[0], &dir[0], dir_len)) {
        return 6;
      }
    } else if (typ == 48) {
      let out: u8[4] = [];
      let n: i32 = tar.read_entry_data(&arc[0], arc_len, entry_off, &out[0], 4);
      if (name_out[0] == 97 && name_out[60] == 47) {
        got_file = got_file + 1;
        if (n != 1 || out[0] != 88) {
          return 7;
        }
      } else if (name_out[0] == 112 && name_out[269] == 112) {
        got_pax = got_pax + 1;
        if (n != 1 || out[0] != 81) {
          return 8;
        }
      } else {
        return 9;
      }
    } else {
      return 10;
    }
  }

  if (got_file != 1 || got_dir != 1 || got_pax != 1) {
    return 11;
  }
  return 0;
}
