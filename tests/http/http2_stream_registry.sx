// STD-HTTP-H2-v9：多 stream 注册表烟测（离线）
const http = import("std.http");

function main(): i32 {
  if (http.registry_smoke() != 0) { return 1; }
  if (http.registry_max() != 8) { return 2; }

  let reg: Http2StreamRegistry = Http2StreamRegistry {
    slots_blob: [],
    count: 0,
    next_id: 0
  };
  http.init(&reg);
  let s1: i32 = http.open(&reg);
  let s2: i32 = http.open(&reg);
  if (s1 != 1 || s2 != 3) { return 3; }
  if (http.is_open(&reg, 3) == false) { return 4; }
  http.close(&reg, 3);
  if (http.is_open(&reg, 3) == true) { return 5; }

  return 0;
}
