// See implementation.
const codec = import("std.codec");
const bytes = import("std.bytes");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let src_big: u8[5] = [10, 20, 30, 40, 50];
  let src_small: u8[3] = [1, 2, 3];
  let b: Bytes = bytes.new();
  let e: Encoder = codec.encoder_new(codec.kind_hex());

  // See implementation.
  if (codec.encode_into_bytes(e, &src_big[0], 5, &b) != 10) {
    bytes.deinit(&b);
    return 1;
  }
  let cap_after_first: i32 = bytes.capacity(b);
  if (cap_after_first < 10) {
    bytes.deinit(&b);
    return 2;
  }

  // See implementation.
  if (codec.encode_into_bytes(e, &src_small[0], 3, &b) != 6) {
    bytes.deinit(&b);
    return 3;
  }
  if (bytes.capacity(b) != cap_after_first) {
    bytes.deinit(&b);
    return 4;
  }
  if (bytes.len(b) != 6) {
    bytes.deinit(&b);
    return 5;
  }

  // See implementation.
  let d: Decoder = codec.decoder_new(codec.kind_hex());
  let decoded: Bytes = bytes.new();
  if (codec.decode_from_bytes(d, b, &decoded) != 3) {
    bytes.deinit(&b);
    bytes.deinit(&decoded);
    return 6;
  }
  let i: i32 = 0;
  while (i < 3) {
    if (decoded.ptr[i] != src_small[i]) {
      bytes.deinit(&b);
      bytes.deinit(&decoded);
      return 7;
    }
    i = i + 1;
  }

  bytes.deinit(&b);
  bytes.deinit(&decoded);
  return 0;
}
