// heap_import_alias.x — import binding -o 链接桩（从 .c 转换）
extern function calloc(count: u32, size: u32): *u8;
extern function free(ptr: *u8): void;

function std_heap_alloc_i32(count: i32): *i32 {
  if (count <= 0) { return 0 as *i32; }
  return calloc(count as u32, 4) as *i32;
}
function std_heap_alloc_u8(count: i32): *u8 {
  if (count <= 0) { return 0 as *u8; }
  return calloc(count as u32, 1) as *u8;
}
function std_heap_free_i32(ptr: *i32): void {
  free(ptr as *u8);
}
function std_heap_free_u8(ptr: *u8): void {
  free(ptr);
}
function std_heap_alloc_size_zero(): i32 {
  return 0;
}
