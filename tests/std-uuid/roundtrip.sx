// STD-075：std.uuid parse/format/eq/v4/v7 round-trip 烟测
const uuid = import("std.uuid");

function main(): i32 {
  let known: u8[36] = [
    53, 53, 48, 101, 56, 52, 48, 48, 45, 101, 50, 57, 98, 45, 52, 49,
    100, 52, 45, 97, 55, 49, 54, 45, 52, 52, 54, 54, 53, 53, 52, 52,
    48, 48, 48, 48
  ];
  let u: Uuid = Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  if (uuid.parse(&known[0], 36, &u) != 0) {
    return 1;
  }
  if (uuid.version(u) != 4) {
    return 2;
  }

  let out: u8[40] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0];
  if (uuid.format(u, &out[0], 40) != 36) {
    return 3;
  }

  let upper: u8[36] = [
    53, 53, 48, 69, 56, 52, 48, 48, 45, 69, 50, 57, 66, 45, 52, 49,
    68, 52, 45, 65, 55, 49, 54, 45, 52, 52, 54, 54, 53, 53, 52, 52,
    48, 48, 48, 48
  ];
  let u2: Uuid = Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  if (uuid.parse(&upper[0], 36, &u2) != 0) {
    return 4;
  }
  if (uuid.eq(u, u2) == 0) {
    return 5;
  }

  let plain: u8[32] = [
    53, 53, 48, 101, 56, 52, 48, 48, 101, 50, 57, 98, 52, 49, 100, 52,
    97, 55, 49, 54, 52, 52, 54, 54, 53, 53, 52, 52, 48, 48, 48, 48
  ];
  let u3: Uuid = Uuid { bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] };
  if (uuid.parse(&plain[0], 32, &u3) != 0) {
    return 6;
  }
  if (uuid.eq(u, u3) == 0) {
    return 7;
  }

  let v4: Uuid = uuid.new_v4();
  if (uuid.version(v4) != 4) {
    return 8;
  }

  let v7: Uuid = uuid.new_v7();
  if (uuid.version(v7) != 7) {
    return 9;
  }

  let v7b: Uuid = uuid.new_v7();
  if (uuid.version(v7b) != 7) {
    return 12;
  }
  let i: i32 = 0;
  let seen_diff: i32 = 0;
  while (i < 16) {
    if (v7.bytes[i] != v7b.bytes[i]) {
      seen_diff = 1;
      if (v7.bytes[i] > v7b.bytes[i]) {
        return 13;
      }
      i = 16;
    }
    i = i + 1;
  }
  if (seen_diff == 0) {
    return 14;
  }

  let bp: *u8 = uuid.as_bytes(&u);
  if (bp == 0) {
    return 10;
  }
  if (bp[0] != 85) {
    return 11;
  }

  return 0;
}
