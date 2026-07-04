// STD-HTTP-REQRESP-v2：HttpUrlOwned 堆 URL（>256B）烟测
const http = import("std.http");

function main(): i32 {
  if (http.url_owned_smoke() != 0) { return 1; }
  if (http.url_string_cap() != 256) { return 2; }
  if (http.url_exceeds_string_cap(300) == false) { return 3; }
  if (http.url_exceeds_string_cap(256)) { return 4; }

  let buf: u8[320] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let i: i32 = 0;
  while (i < 300) {
    buf[i] = 97;
    i = i + 1;
  }
  buf[0] = 104;
  buf[1] = 116;
  buf[2] = 116;
  buf[3] = 112;
  buf[4] = 58;
  buf[5] = 47;
  buf[6] = 47;
  buf[7] = 120;
  buf[8] = 47;

  let owned: HttpUrlOwned = HttpUrlOwned { ptr: 0, len: 0 };
  if (http.url_owned_from_slice(&buf[0], 300, &owned) != 300) { return 5; }
  if (owned.len != 300) { return 6; }

  let req: HttpRequest = HttpRequest { method: Method.GET, url: owned.ptr, url_len: owned.len, body: 0, body_len: 0, timeout_ms: 0 };
  if (req.url_len != 300) { return 7; }

  http.url_owned_free(owned);
  return 0;
}
