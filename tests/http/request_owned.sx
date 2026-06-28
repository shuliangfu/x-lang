// STD-HTTP-REQRESP-v3：HttpRequestOwned 一体堆 URL/body 烟测
const http = import("std.http");

function main(): i32 {
  if (http.request_owned_smoke() != 0) { return 1; }

  let url_buf: u8[64] = [104, 116, 116, 112, 58, 47, 47, 101, 120, 97, 109, 112, 108, 101, 46, 99,
    111, 109, 47, 112, 111, 115, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  let owned: HttpRequestOwned = HttpRequestOwned {
    method: Method.POST,
    url: HttpUrlOwned { ptr: 0, len: 0 },
    body: HttpBodyOwned { ptr: 0, len: 0 },
    timeout_ms: 0
  };
  if (http.url_owned_from_slice(&url_buf[0], 24, &owned.url) != 24) { return 2; }
  if (owned.url.len != 24) { return 3; }

  let view: HttpRequest = HttpRequest {
    method: owned.method,
    url: owned.url.ptr,
    url_len: owned.url.len,
    body: owned.body.ptr,
    body_len: owned.body.len,
    timeout_ms: 0
  };
  if (view.url_len != 24) { return 4; }

  http.request_owned_free(&owned);

  if (http.push_network_smoke() != 0) { return 5; }
  if (http.h2c_network_smoke() != 0) { return 6; }
  if (http.h2c_is_available() == false) { return 7; }

  return 0;
}
