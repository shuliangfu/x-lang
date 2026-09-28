// w1505 / 终局待办 10.36: a pass1-deferred `let` after a nested block that
// holds its own `let` (if / else / while / for / nested if) must still be
// initialized. The shared defer mask used to be overwritten by the inner
// block, so the outer init was dropped and the slot kept stack garbage.
// Exit 0 = all forms correct; otherwise the failing case number.
function zero(): i32 { return 0; }
function one(): i32 { return 1; }
function note(): void { }

function after_if(msg: *u8): i32 {
  if (one() != 0) { let q: i32 = 3; note(); }
  let m2: *u8 = msg;
  return m2[0] as i32;
}

function after_if_return(msg: *u8): i32 {
  if (zero() != 0) { let q: *u8 = msg; if (q == 0 as *u8) { return 7; } return 5; }
  let m2: *u8 = msg;
  if (m2 == 0 as *u8) { m2 = ""; }
  return m2[0] as i32;
}

function after_else(x: i32): i32 {
  if (zero() != 0) { let a: i32 = x + 1; note(); } else { let b: i32 = x + 2; note(); }
  let m: i32 = x;
  return m;
}

function after_while(x: i32): i32 {
  let i: i32 = 0;
  while (i < 3) { let t: i32 = i * 2; i = i + 1; }
  let m: i32 = x + i;
  return m;
}

function after_for(x: i32): i32 {
  let s: i32 = 0;
  for (let k: i32 = 0; k < 4; k = k + 1) { let t: i32 = k; s = s + t; }
  let m: i32 = x + s;
  return m;
}

function after_nested(x: i32, y: i32): i32 {
  if (one() != 0) {
    let a: i32 = y;
    if (a > 0) { let b: i32 = a; note(); }
    let c: i32 = x;
    if (c != x) { return 90; }
  }
  let m: i32 = x;
  let n: i32 = m + y;
  return n;
}

function after_two_ifs(line: i32, col: i32, msg: *u8): i32 {
  if (zero() != 0) {
    let m: *u8 = msg;
    if (m == 0 as *u8) { m = ""; }
    return 5;
  }
  if (one() != 0) { note(); }
  let m2: *u8 = msg;
  if (m2 == 0 as *u8) { m2 = ""; }
  return (m2[0] as i32) + line + col;
}

function main(): i32 {
  let s: *u8 = "A";
  if (after_if(s) != 65) { return 1; }
  if (after_if_return(s) != 65) { return 2; }
  if (after_else(41) != 41) { return 3; }
  if (after_while(40) != 43) { return 4; }
  if (after_for(40) != 46) { return 5; }
  if (after_nested(30, 12) != 42) { return 6; }
  if (after_two_ifs(1, 2, s) != 68) { return 7; }
  return 0;
}
