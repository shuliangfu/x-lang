// Isolated 9–16B Quad `.d` home-vs-rdx layout probe.
// Pair (8B) and Wide (>16B sret) stay in struct_method_field.x; this file
// is Quad-only so a wrong rdx half cannot SEGV the neighborhood matrix.
// Binop inits refuse try_inline (emit+store_retval). Param-copy inits
// exercise try_inline linear rbx+foff. Exit N names the first miss.
// PLATFORM: SHARED — Ubuntu x86_64 SysV gold (high-end home / rdx at home-8).

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
 * METHOD 16B factory with binop field inits (try_inline refuses).
 * 8.as_quad() → {8, 9, 10, 11}; `.d` is the rdx high i32.
 * @param self i32 — base for a..d
 * @return Quad — {self, self+1, self+2, self+3}
 */
impl Quadable for i32 {
  function as_quad(self: i32): Quad {
    return { a: self + 0, b: self + 1, c: self + 2, d: self + 3 };
  }
}

/**
 * CALL neighborhood of as_quad (same binop inits, same 16B layout).
 * @param x i32 — base for a..d
 * @return Quad — {x, x+1, x+2, x+3}
 */
function mk_quad(x: i32): Quad {
  return { a: x + 0, b: x + 1, c: x + 2, d: x + 3 };
}

trait Copyable {
  function as_copy(self): Quad;
}

/**
 * METHOD 16B factory with param field inits (try_inline may fire).
 * 8.as_copy() → {8, 8, 8, 8}. Contrasts the binop emit+store path.
 * @param self i32 — copied into every field
 * @return Quad — {self, self, self, self}
 */
impl Copyable for i32 {
  function as_copy(self: i32): Quad {
    return { a: self, b: self, c: self, d: self };
  }
}

/**
 * CALL neighborhood of as_copy (param-copy fields).
 * @param x i32 — copied into every field
 * @return Quad — {x, x, x, x}
 */
function mk_copy(x: i32): Quad {
  return { a: x, b: x, c: x, d: x };
}

/**
 * Consume a 16B Quad by value and return `.d` (param0-single-field).
 * @param q Quad — dual-GP INTEGER class argument
 * @return i32 — q.d
 */
function take_quad(q: Quad): i32 {
  return q.d;
}

/**
 * Isolated Quad layout probe.
 * 1–4 METHOD binop field-access a/b/c/d
 * 5–8 CALL binop field-access a/b/c/d
 * 9–12 METHOD let-init then VAR a/b/c/d
 * 13–16 CALL let-init then VAR a/b/c/d
 * 17–18 take_quad METHOD / CALL
 * 19–22 param-copy try_inline METHOD/CALL a/d
 * @return i32 — 0 ok; 1..22 first miss
 */
function main(): i32 {
  /* METHOD binop field-access: emit+store_retval then lea home + off. */
  if (8.as_quad().a != 8) { return 1; }
  if (8.as_quad().b != 9) { return 2; }
  if (8.as_quad().c != 10) { return 3; }
  if (8.as_quad().d != 11) { return 4; }
  /* CALL binop neighborhood. */
  if (mk_quad(8).a != 8) { return 5; }
  if (mk_quad(8).b != 9) { return 6; }
  if (mk_quad(8).c != 10) { return 7; }
  if (mk_quad(8).d != 11) { return 8; }
  /* METHOD let-init then VAR field (same home as store_retval). */
  let qq: Quad = 8.as_quad();
  if (qq.a != 8) { return 9; }
  if (qq.b != 9) { return 10; }
  if (qq.c != 10) { return 11; }
  if (qq.d != 11) { return 12; }
  /* CALL let-init then VAR field. */
  let cq: Quad = mk_quad(8);
  if (cq.a != 8) { return 13; }
  if (cq.b != 9) { return 14; }
  if (cq.c != 10) { return 15; }
  if (cq.d != 11) { return 16; }
  /* By-value consume (param home / try_inline param0.d). */
  if (take_quad(8.as_quad()) != 11) { return 17; }
  if (take_quad(mk_quad(8)) != 11) { return 18; }
  /* Param-copy try_inline path (linear rbx+foff). */
  if (8.as_copy().a != 8) { return 19; }
  if (8.as_copy().d != 8) { return 20; }
  if (mk_copy(8).a != 8) { return 21; }
  if (mk_copy(8).d != 8) { return 22; }
  return 0;
}
