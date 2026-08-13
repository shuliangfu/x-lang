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

/**
 * Probe: METHOD.field plus CALL.field plus METHOD/CALL let-init.
 * Exit 0 on success; 1..16 name the miss.
 * 1-4 materialise/sret neighborhood; 5-8 field-access inline;
 * 9-12 let-init try_inline (param + const); 13-16 let-init sret/CALL neighborhood.
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
  return 0;
}
