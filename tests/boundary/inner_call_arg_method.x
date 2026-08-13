// Isolated peel: first/take_a and pair_sum/field_sum over a METHOD factory.
// `take_a(5.as_pair())` / `5.as_pair().first()` must peel as_pair's self (5)
// through glue_inner_call_arg_for_field_access (48||49 + UFCS pix map).
// CALL-inner neighborhood: take_a(mk(...)) / mk(...).first() stay green.
// PLATFORM: SHARED — Ubuntu gold; no Wide / no array-lit CALL (typeck T001).

struct Pair {
  a: i32
  b: i32
}

trait Pairable {
  function as_pair(self): Pair;
}

/**
 * METHOD param-struct-lit factory: both fields are the receiver param.
 * @param self i32 — copied into Pair.a and Pair.b
 * @return Pair — { self, self }
 */
impl Pairable for i32 {
  function as_pair(self: i32): Pair {
    return Pair { a: self, b: self };
  }
}

/**
 * CALL neighborhood factory: fields are positional params.
 * @param x i32 — field a
 * @param y i32 — field b
 * @return Pair — { x, y }
 */
function mk(x: i32, y: i32): Pair {
  return Pair { a: x, b: y };
}

trait Firstable {
  function first(self): i32;
}

/**
 * METHOD param0-single-field: `return self.a`.
 * @param self Pair — receiver
 * @return i32 — self.a
 */
impl Firstable for Pair {
  function first(self: Pair): i32 {
    return self.a;
  }
}

/**
 * CALL neighborhood of first.
 * @param p Pair — source
 * @return i32 — p.a
 */
function take_a(p: Pair): i32 {
  return p.a;
}

trait Summable {
  function pair_sum(self): i32;
}

/**
 * METHOD param0-field-sum: `return self.a + self.b`.
 * @param self Pair — receiver
 * @return i32 — self.a + self.b
 */
impl Summable for Pair {
  function pair_sum(self: Pair): i32 {
    return self.a + self.b;
  }
}

/**
 * CALL neighborhood of pair_sum.
 * @param p Pair — source
 * @return i32 — p.a + p.b
 */
function field_sum(p: Pair): i32 {
  return p.a + p.b;
}

/**
 * Probe: METHOD factory as the nested arg of first / take_a / pair_sum / field_sum.
 * Exit 0 on success; 1..6 name the miss.
 * @return i32 — 0 ok
 */
function main(): i32 {
  /* CALL outer + METHOD inner factory. */
  if (take_a(5.as_pair()) != 5) { return 1; }
  /* METHOD outer + METHOD inner factory. */
  if (5.as_pair().first() != 5) { return 2; }
  /* CALL outer + METHOD inner factory (field-sum peel). */
  if (field_sum(5.as_pair()) != 10) { return 3; }
  /* METHOD outer + METHOD inner factory (field-sum peel). */
  if (5.as_pair().pair_sum() != 10) { return 4; }
  /* CALL-inner neighborhood (already green before this knife). */
  if (take_a(mk(3, 4)) != 3) { return 5; }
  if (mk(3, 4).first() != 3) { return 6; }
  return 0;
}
