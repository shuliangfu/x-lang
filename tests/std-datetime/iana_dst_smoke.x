// STD-136：std.datetime IANA 时区 + DST 烟测
const datetime = import("std.datetime");

function test_ny_dst(): i32 {
  let tz: TimeZone = TimeZone { offset_min: 0, iana_id: -1 };
  let name: u8[16] = [
    65, 109, 101, 114, 105, 99, 97, 47, 78, 101, 119, 95, 89, 111, 114, 107
  ];
  if (datetime.timezone_iana(&name[0], 16, &tz) != 0) { return 1; }
  if (tz.iana_id < 0) { return 2; }

  let winter: DateTime = datetime.from_unix(1705320000, 0);
  let summer: DateTime = datetime.from_unix(1721044800, 0);
  if (datetime.timezone_offset_at(winter, tz) != -300) { return 3; }
  if (datetime.timezone_offset_at(summer, tz) != -240) { return 4; }

  let wf: DateFields = datetime.to_zoned_fields(winter, tz);
  if (wf.hour != 7) { return 5; }
  let sf: DateFields = datetime.to_zoned_fields(summer, tz);
  if (sf.hour != 8) { return 6; }
  return 0;
}

function main(): i32 {
  if (datetime.iana_dst_smoke() != 0) { return 1; }
  if (test_ny_dst() != 0) { return 2; }
  return 0;
}
