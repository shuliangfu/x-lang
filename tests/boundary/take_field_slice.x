// Isolated green: already-typed [N]T (FIELD / VAR / local) as []T call-arg
// (4.2.10). Score accepts array→slice with equal elems; emit keeps
// TYPE_ARRAY so host-C/fs can materialize the fat (do not stamp SLICE).
// Let `s: []T = w.xs` is neighborhood. return/assign of [N]T→[]T
// are ret_array_as_slice / asg_array_as_slice. ARRAY_LIT take is wave647/622.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck+emit.

struct Wf {
  xs: [2]f32
}

struct Wi {
  xs: [2]i32
}

/**
 * Accept a []f32 fat and check length plus truncated lanes.
 * @param s []f32 — coerced from [2]f32 field/var/local
 * @return i32 — 42 ok, else the failing check
 */
function take_f(s: []f32): i32 {
  if (s.length != 2) { return 1; }
  if ((s[0] as i32) != 1) { return 2; }
  if ((s[1] as i32) != 2) { return 3; }
  return 42;
}

/**
 * Accept a []i32 fat and check both elements.
 * @param s []i32 — coerced from [2]i32 field
 * @return i32 — 42 ok, else the failing check
 */
function take_i(s: []i32): i32 {
  if (s.length != 2) { return 1; }
  if (s[0] != 1) { return 2; }
  if (s[1] != 2) { return 3; }
  return 42;
}

/**
 * Build a Wf so take(mk().xs) exercises CALL.field.
 * @return Wf — xs = [1.0, 2.0]
 */
function mk(): Wf {
  return { xs: [1.0, 2.0] };
}

/**
 * Exit 42 when [N]T → []T call-arg scores and emits a fat.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  /* STRUCT_LIT.field call-arg — original 4.2.10 hole. */
  if (take_f({ xs: [1.0, 2.0] }.xs) != 42) { return 10; }
  /* CALL.field */
  if (take_f(mk().xs) != 42) { return 11; }
  /* VAR.field */
  let w: Wf = { xs: [1.0, 2.0] };
  if (take_f(w.xs) != 42) { return 12; }
  /* local [2]f32 */
  let a: [2]f32 = [1.0, 2.0];
  if (take_f(a) != 42) { return 13; }
  /* i32 neighborhood */
  let wi: Wi = { xs: [1, 2] };
  if (take_i(wi.xs) != 42) { return 14; }
  /* let already green (typeck_coerce_init_slice_from_array) */
  let lf: []f32 = w.xs;
  if ((lf[0] as i32) != 1) { return 19; }
  /* ARRAY_LIT neighborhood */
  if (take_f([1.0, 2.0]) != 42) { return 20; }
  return 42;
}
