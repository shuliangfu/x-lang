// STD-135：std.datetime 固定偏移时区烟测
const datetime = import("std.datetime");

function test_jst_roundtrip(): i32 {
  let tz: TimeZone = TimeZone { offset_min: 0, iana_id: -1 };
  let jst: u8[3] = [74, 83, 84];
  if (datetime.timezone_from_name(&jst[0], 3, &tz) != 0) { return 1; }
  if (tz.offset_min != 540) { return 2; }
  let f: DateFields = DateFields {
    year: 2020, month: 1, day: 1, hour: 15, minute: 0, second: 0, nsec: 0
  };
  let t: DateTime = datetime.from_zoned_fields(f, tz);
  if (t.sec != 1577858400) { return 3; }
  let z: DateFields = datetime.to_zoned_fields(t, tz);
  if (z.hour != 15 || z.minute != 0) { return 4; }
  return 0;
}

function test_parse_offset(): i32 {
  let off: i32 = 0;
  let p8: u8[6] = [43, 48, 56, 58, 48, 48];
  if (datetime.parse_offset_min(&p8[0], 6, &off) != 0) { return 1; }
  if (off != 480) { return 2; }
  let tz: TimeZone = datetime.timezone_fixed(off);
  let f: DateFields = DateFields {
    year: 2020, month: 1, day: 1, hour: 12, minute: 0, second: 0, nsec: 0
  };
  let t: DateTime = datetime.from_zoned_fields(f, tz);
  if (t.sec != 1577851200) { return 3; }
  return 0;
}

function main(): i32 {
  let r: i32 = test_jst_roundtrip();
  if (r != 0) { return r; }
  r = test_parse_offset();
  if (r != 0) { return 10 + r; }
  if (datetime.timezone_smoke() != 0) { return 20; }
  let utc: TimeZone = datetime.timezone_utc();
  if (utc.offset_min != 0) { return 21; }
  return 0;
}
