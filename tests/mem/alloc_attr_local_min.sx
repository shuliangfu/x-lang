allow(padding) struct Allocator {
  kind: i32;
}

function kind_heap(): i32 { return 0; }

function heap_alloc(): Allocator {
  return Allocator { kind: kind_heap() };
}

function alloc(al: Allocator, size: usize): *u8 {
  if (al.kind == kind_heap()) {
    return 0 as *u8;
  }
  return size as *u8;
}

#[alloc]
function bump(al: Allocator, size: usize): *u8 {
  return alloc(al, size);
}

function sentinel(): i32 {
  return 7;
}

function main(): i32 {
  let p: *u8 = bump(4 as usize);
  if (p != 0 as *u8) { return 1; }
  return sentinel();
}
