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

// 16B SysV INTEGER dual-GP (4×i32). Binop fields refuse try_inline.
struct Quad {
  a: i32
  b: i32
  c: i32
  d: i32
}

trait Quadable {
  function as_quad(self): Quad;
}

/**
 * METHOD returning 16B: classifier + rdx half + call-arg spill harvest.
 * @param self i32 — copied into a; b..d are self+1 .. self+3
 * @return Quad
 */
impl Quadable for i32 {
  function as_quad(self: i32): Quad {
    return Quad { a: self + 0, b: self + 1, c: self + 2, d: self + 3 };
  }
}

/**
 * CALL neighborhood of as_quad (same layout, same binop inits).
 * @param x i32 — base for a..d
 * @return Quad
 */
function mk_quad(x: i32): Quad {
  return Quad { a: x + 0, b: x + 1, c: x + 2, d: x + 3 };
}

/**
 * Consume a 16B Quad by value (METHOD/CALL as call-arg spill).
 * @param q Quad — dual-GP / spilled struct
 * @return i32 — q.d
 */
function take_quad(q: Quad): i32 {
  return q.d;
}

/**
 * Probe: METHOD.field plus CALL.field plus METHOD/CALL let-init plus >16B plus 16B.
 * Exit 0 on success; 1..30 name the miss.
 * 1-4 materialise/sret neighborhood; 5-8 field-access inline;
 * 9-12 let-init try_inline (param + const); 13-16 let-init sret/CALL neighborhood;
 * 17-22 >16B METHOD/CALL field-access + let-init (sret / memcpy residual);
 * 23-30 16B METHOD/CALL field-access + let-init + call-arg spill (rax-deref classifier).
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
  /* >16B METHOD field-access: sret home then load (memcpy if residual store). */
  if (7.as_wide().a != 7) { return 17; }
  if (7.as_wide().e != 11) { return 18; }
  /* >16B METHOD let-init. */
  let w: Wide = 7.as_wide();
  if (w.a != 7) { return 19; }
  if (w.e != 11) { return 20; }
  /* >16B CALL neighborhood. */
  if (mk_wide(7).e != 11) { return 21; }
  let cw: Wide = mk_wide(7);
  if (cw.e != 11) { return 22; }
  /* 16B METHOD field-access: dual-GP rdx half (classifier 0 for pure-asm). */
  if (8.as_quad().a != 8) { return 23; }
  if (8.as_quad().d != 11) { return 24; }
  /* 16B METHOD let-init store. */
  let qq: Quad = 8.as_quad();
  if (qq.a != 8) { return 25; }
  if (qq.d != 11) { return 26; }
  /* 16B CALL neighborhood. */
  if (mk_quad(8).d != 11) { return 27; }
  let cq: Quad = mk_quad(8);
  if (cq.d != 11) { return 28; }
  /* 16B METHOD/CALL as call-arg (spill after classifier). */
  if (take_quad(8.as_quad()) != 11) { return 29; }
  if (take_quad(mk_quad(8)) != 11) { return 30; }
  return 0;
}
