// Isolated green: already-typed [N]T (FIELD / VAR / CALL / local)
// coerces to []T at call-arg, assign, and return (4.2.10).
// Let `s: []T = w.xs` was already green via typeck_coerce_init_expr_to_decl;
// take(W.xs) / return / assign skipped the same helper → T001.
// ARRAY_LIT take([1.0, 2.0]) is neighborhood (wave647/622).
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck.

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
  return Wf { xs: [1.0, 2.0] };
}

/**
 * Return a []f32 by coercing STRUCT_LIT.field (return consumer).
 * @return []f32 — two f32 lanes
 */
function ret_f(): []f32 {
  return Wf { xs: [1.0, 2.0] }.xs;
}

/**
 * Exit 42 when [N]T → []T stamps at every 4.2.10 consumer.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  /* STRUCT_LIT.field call-arg — original 4.2.10 hole. */
  if (take_f(Wf { xs: [1.0, 2.0] }.xs) != 42) { return 10; }
  /* CALL.field */
  if (take_f(mk().xs) != 42) { return 11; }
  /* VAR.field */
  let w: Wf = Wf { xs: [1.0, 2.0] };
  if (take_f(w.xs) != 42) { return 12; }
  /* local [2]f32 */
  let a: [2]f32 = [1.0, 2.0];
  if (take_f(a) != 42) { return 13; }
  /* i32 neighborhood */
  let wi: Wi = Wi { xs: [1, 2] };
  if (take_i(wi.xs) != 42) { return 14; }
  /* assign consumer */
  let s: []f32 = [0.0, 0.0];
  s = w.xs;
  if (s.length != 2) { return 15; }
  if ((s[0] as i32) != 1) { return 16; }
  /* return consumer */
  let rf: []f32 = ret_f();
  if (rf.length != 2) { return 17; }
  if ((rf[1] as i32) != 2) { return 18; }
  /* let already green (same helper) */
  let lf: []f32 = w.xs;
  if ((lf[0] as i32) != 1) { return 19; }
  /* ARRAY_LIT neighborhood */
  if (take_f([1.0, 2.0]) != 42) { return 20; }
  return 42;
}
