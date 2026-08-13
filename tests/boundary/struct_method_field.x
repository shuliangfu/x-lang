// METHOD(49)-rooted field access: materialise receiver.method() then load .field.
// CALL(48) neighborhood: mk().a must stay green on the same emit path.
// PLATFORM: SHARED — Ubuntu gold for frame home / sret; Darwin same names.

struct Pair {
  a: i32
  b: i32
}

trait Incrementable {
  function increment(self): Pair;
}

/**
 * Trait impl: Pair.increment returns a new Pair (METHOD_CALL root for .a/.b).
 * @param self Pair — receiver
 * @return Pair — { a+1, b+1 }
 */
impl Incrementable for Pair {
  function increment(self: Pair): Pair {
    return Pair { a: self.a + 1, b: self.b + 1 };
  }
}

/**
 * Same-module CALL returning Pair (neighborhood of METHOD.field).
 * @param x i32 — field a
 * @param y i32 — field b
 * @return Pair — { x, y }
 */
function mk(x: i32, y: i32): Pair {
  return Pair { a: x, b: y };
}

trait Pairable {
  function as_pair(self): Pair;
}

/**
 * METHOD param-struct-lit: fields are the receiver param (try_inline body, not sret).
 * @param self i32 — copied into both Pair fields
 * @return Pair — { self, self }
 */
impl Pairable for i32 {
  function as_pair(self: i32): Pair {
    return Pair { a: self, b: self };
  }
}

trait Originable {
  function origin(self): Pair;
}

/**
 * METHOD const-struct-lit: unused receiver, fields are integer literals.
 * @param self Pair — ignored
 * @return Pair — { 0, 0 }
 */
impl Originable for Pair {
  function origin(self: Pair): Pair {
    return Pair { a: 0, b: 0 };
  }
}

// >16B SysV MEMORY class (5×i32). Binop fields refuse try_inline.
struct Wide {
  a: i32
  b: i32
  c: i32
  d: i32
  e: i32
}

trait Wideable {
  function as_wide(self): Wide;
}

/**
 * METHOD returning >16B: binop field inits refuse try_inline (sret / memcpy).
 * @param self i32 — copied into a; b..e are self+1 .. self+4
 * @return Wide
 */
impl Wideable for i32 {
  function as_wide(self: i32): Wide {
    return Wide { a: self + 0, b: self + 1, c: self + 2, d: self + 3, e: self + 4 };
  }
}

/**
 * CALL neighborhood of as_wide (same layout, same binop inits).
 * @param x i32 — base for a..e
 * @return Wide
 */
function mk_wide(x: i32): Wide {
  return Wide { a: x + 0, b: x + 1, c: x + 2, d: x + 3, e: x + 4 };
}

trait Firstable {
  function first(self): i32;
}

/**
 * METHOD param0-single-field: callee is `return self.a` (try_inline field load).
 * @param self Pair — receiver whose `.a` is loaded
 * @return i32 — self.a
 */
impl Firstable for Pair {
  function first(self: Pair): i32 {
    return self.a;
  }
}

/**
 * CALL neighborhood of first (same fold: return param0.a).
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
 * METHOD param0-field-sum: callee is `return self.a + self.b`.
 * @param self Pair — receiver whose `.a` and `.b` are loaded then added
 * @return i32 — self.a + self.b
 */
impl Summable for Pair {
  function pair_sum(self: Pair): i32 {
    return self.a + self.b;
  }
}

/**
 * CALL neighborhood of pair_sum (same fold: return param0.a + param0.b).
 * @param p Pair — source
 * @return i32 — p.a + p.b
 */
function field_sum(p: Pair): i32 {
  return p.a + p.b;
}

trait Addable {
  function plus_one(self): i32;
}

/**
 * METHOD x+K: callee is `return self + 1` (try_inline emit-arg then add).
 * @param self i32 — receiver added to the constant
 * @return i32 — self + 1
 */
impl Addable for i32 {
  function plus_one(self: i32): i32 {
    return self + 1;
  }
}

/**
 * CALL neighborhood of plus_one (same fold: return param0 + 1).
 * @param x i32 — source
 * @return i32 — x + 1
 */
function add_one(x: i32): i32 {
  return x + 1;
}

trait FoldAddable {
  function fold_add(self, other: i32): i32;
}

/**
 * METHOD wpo_const scalar: callee is `return self + other` (two const i32).
 * @param self i32 — receiver (const at the call site)
 * @param other i32 — extra UFCS arg (const at the call site)
 * @return i32 — self + other
 */
impl FoldAddable for i32 {
  function fold_add(self: i32, other: i32): i32 {
    return self + other;
  }
}

/**
 * CALL neighborhood of fold_add (same fold: return param0 + param1).
 * @param x i32 — left const
 * @param y i32 — right const
 * @return i32 — x + y
 */
function fold_add_call(x: i32, y: i32): i32 {
  return x + y;
}

/**
 * Probe: METHOD.field plus CALL.field plus METHOD/CALL let-init plus >16B.
 * Exit 0 on success; 1..30 name the miss.
 * 1-4 materialise/sret neighborhood; 5-8 field-access inline;
 * 9-12 let-init try_inline (param + const); 13-16 let-init sret/CALL neighborhood;
 * 17-18 param0-single-field METHOD first() + CALL take_a neighborhood;
 * 19-20 param0-field-sum METHOD pair_sum() + CALL field_sum neighborhood;
 * 21-22 x+K METHOD plus_one() + CALL add_one neighborhood;
 * 23-24 wpo_const scalar METHOD fold_add() + CALL fold_add_call neighborhood;
 * 25-30 >16B METHOD/CALL field-access + let-init (sret / memcpy residual).
 * 9–16B Quad field.d / take_quad left for the home-vs-rdx layout knife (not this classifier).
 * @return i32 — 0 ok
 */
function main(): i32 {
  let p: Pair = Pair { a: 10, b: 20 };
  /* METHOD-rooted field: glue_field_access_call_base_rvalue must size + materialise 49. */
  if (p.increment().a != 11) { return 1; }
  if (p.increment().b != 21) { return 2; }
  /* CALL-rooted neighborhood (already green before this knife). */
  if (mk(3, 4).a != 3) { return 3; }
  if (mk(3, 4).b != 4) { return 4; }
  /* METHOD param-struct-lit: try_inline maps self → field inits. */
  if (5.as_pair().a != 5) { return 5; }
  if (5.as_pair().b != 5) { return 6; }
  /* METHOD const-struct-lit: try_inline writes literals; receiver unused. */
  if (p.origin().a != 0) { return 7; }
  if (p.origin().b != 0) { return 8; }
  /* let-init METHOD param-struct-lit: glue_emit_struct_type_let_init try_inline gate. */
  let q: Pair = 5.as_pair();
  if (q.a != 5) { return 9; }
  if (q.b != 5) { return 10; }
  /* let-init METHOD const-struct-lit. */
  let o: Pair = p.origin();
  if (o.a != 0) { return 11; }
  if (o.b != 0) { return 12; }
  /* let-init METHOD sret neighborhood (increment is not param/const lit). */
  let inc: Pair = p.increment();
  if (inc.a != 11) { return 13; }
  if (inc.b != 21) { return 14; }
  /* let-init CALL neighborhood (gate already accepted 48). */
  let m: Pair = mk(3, 4);
  if (m.a != 3) { return 15; }
  if (m.b != 4) { return 16; }
  /* METHOD param0-single-field: try_inline loads recv.a (not a CALL). */
  if (p.first() != 10) { return 17; }
  /* CALL neighborhood of the same fold. */
  if (take_a(p) != 10) { return 18; }
  /* METHOD param0-field-sum: try_inline loads recv.a+recv.b (not a CALL). */
  if (p.pair_sum() != 30) { return 19; }
  /* CALL neighborhood of the same fold. */
  if (field_sum(p) != 30) { return 20; }
  /* METHOD x+K: try_inline emits recv then add 1 (not a CALL). */
  if (10.plus_one() != 11) { return 21; }
  /* CALL neighborhood of the same fold. */
  if (add_one(10) != 11) { return 22; }
  /* METHOD wpo_const scalar: fold two i32 consts (not a CALL). */
  if (10.fold_add(3) != 13) { return 23; }
  /* CALL neighborhood of the same fold. */
  if (fold_add_call(10, 3) != 13) { return 24; }
  /* >16B METHOD field-access: sret home then load (memcpy if residual store). */
  if (7.as_wide().a != 7) { return 25; }
  if (7.as_wide().e != 11) { return 26; }
  /* >16B METHOD let-init. */
  let w: Wide = 7.as_wide();
  if (w.a != 7) { return 27; }
  if (w.e != 11) { return 28; }
  /* >16B CALL neighborhood. */
  if (mk_wide(7).e != 11) { return 29; }
  let cw: Wide = mk_wide(7);
  if (cw.e != 11) { return 30; }
  return 0;
}
