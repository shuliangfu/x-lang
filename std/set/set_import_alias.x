// set_import_alias.x — import binding -o 链接桩（从 .c 转换）

extern function std_heap_free_i32(ptr: *i32): void;
extern function std_heap_free_u8(ptr: *u8): void;

function std_set_set_i32_contains(s: *ShuxSetI32, key: i32): i32 { return 0 as i32; }
function std_set_set_i32_insert(s: *ShuxSetI32, key: i32): i32 { return 0 as i32; }
function std_set_set_i32_remove(s: *ShuxSetI32, key: i32): i32 { return 0 as i32; }
function std_set_set_i32_len(s: *ShuxSetI32): i32 { return 0 as i32; }
function std_set_set_i32_deinit(s: *ShuxSetI32): void { }
