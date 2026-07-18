// See implementation.
const string = import("std.string");
const heap = import("std.heap");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let s: String = string.new();
  let _: i32 = string.string_append_char(&s, 97);
  let _: i32 = string.string_append_char(&s, 98);
  let _: i32 = string.string_append_char(&s, 99);
  let sv: StrView = string_view_from_string(&s);
  let expect_abc: u8[3] = [97, 98, 99];
  let exp: StrView = string.view(&expect_abc[0], 3);
  if (string.string_view_eq(sv, exp) != 1) { return 1; }
  let sub: StrView = string.string_view_subview(sv, 1, 2);
  let expect_bc: u8[2] = [98, 99];
  if (string.string_view_eq(sub, string.view(&expect_bc[0], 2)) != 1) { return 2; }

  // See implementation.
  let ss: StackStr = string.stack_str_new();
  if (string.stack_str_from_slice(&ss, &expect_abc[0], 3) != 0) { return 3; }
  let ss_v: StrView = string.stack_str_view(&ss);
  if (string.string_view_eq(ss_v, exp) != 1) { return 4; }

  // See implementation.
  let arena: Arena64 = heap.arena64_empty();
  if (heap.arena64_init(&arena, 256) != 0) { return 5; }
  let tail: u8[2] = [100, 101];
  let joined: StrView = string.string_view_concat_arena(&arena, sv, string.view(&tail[0], 2));
  if (string.len(joined) != 5) {
    heap.arena64_deinit(&arena);
    return 6;
  }
  if (string.string_view_get(joined, 4) != 101) {
    heap.arena64_deinit(&arena);
    return 7;
  }
  heap.arena64_deinit(&arena);
  return 0;
}
