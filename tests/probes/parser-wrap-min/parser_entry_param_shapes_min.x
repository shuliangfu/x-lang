const lexer = import("lexer");

function plain_i32(x: i32): i32 {
  return x;
}

function plain_ptr(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  return 1;
}

function imported_lexer(lex: Lexer): i32 {
  let pos: usize = lex.pos;
  if (pos > 0) {
    return 1;
  }
  return 0;
}

function main(): i32 {
  return 0;
}
