/**
 * See implementation.
 */
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /** "HTTP/1.1 204 No Content\r\n" */
  let line204: u8[28] = [
    72, 84, 84, 80, 47, 49, 46, 49, 32, 50, 48, 52, 32, 78, 111, 32,
    67, 111, 110, 116, 101, 110, 116, 13, 10, 0, 0, 0
  ];
  let code: i32 = 0;
  if (http.parse_status_line(&line204[0], 24, &code) != 0) { return 1; }
  if (code != 204) { return 2; }
  return 0;
}
