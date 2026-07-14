export function add(a: i32, b: i32): i32 {
  return a + b;
}

extern "C" function printf(fmt: *u8): i32;

allow(padding) struct Point {
  x: i32,
  y: i32,
}

enum Color {
  RED,
  GREEN,
  BLUE,
}

const std = import("std");

export function demo(x: i32, n: i32, arr: *i32): void {
  match x {
    0 => return,
    n => panic,
  }

  for (i : 0 .. n) {
    arr[i] = arr[i] + 1;
  }

  let p: *u8 = "hello";
  let v: i32 = (1 as i32);
  defer printf(p);
}
