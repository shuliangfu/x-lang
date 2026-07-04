// atomic_import_alias.x — import binding -o 链接桩（从 .c 转换）

extern function atomic_load_i32_c(ptr: *i32): i32;
extern function atomic_store_i32_c(ptr: *i32, val: i32): void;
extern function atomic_compare_exchange_i32_c(ptr: *i32, expected: *i32, desired: i32): i32;
extern function atomic_fetch_add_i32_c(ptr: *i32, delta: i32): i32;
extern function atomic_fetch_sub_i32_c(ptr: *i32, delta: i32): i32;
extern function atomic_load_u32_c(ptr: *u32): u32;
extern function atomic_store_u32_c(ptr: *u32, val: u32): void;
extern function atomic_compare_exchange_u32_c(ptr: *u32, expected: *u32, desired: u32): i32;
extern function atomic_fetch_add_u32_c(ptr: *u32, delta: u32): u32;
extern function atomic_load_i64_c(ptr: *i64): i64;
extern function atomic_store_i64_c(ptr: *i64, val: i64): void;
extern function atomic_load_u64_c(ptr: *u64): u64;
extern function atomic_store_u64_c(ptr: *u64, val: u64): void;
extern function atomic_fetch_add_i64_c(ptr: *i64, delta: i64): i64;
extern function atomic_fetch_sub_i64_c(ptr: *i64, delta: i64): i64;
extern function atomic_fetch_add_u64_c(ptr: *u64, delta: u64): u64;
extern function atomic_fetch_sub_u64_c(ptr: *u64, delta: u64): u64;
extern function atomic_compare_exchange_i64_c(ptr: *i64, expected: *i64, desired: i64): i32;
extern function atomic_compare_exchange_u64_c(ptr: *u64, expected: *u64, desired: u64): i32;
extern function atomic_load_i16_c(ptr: *i16): i16;
extern function atomic_store_i16_c(ptr: *i16, val: i16): void;
extern function atomic_fetch_add_i16_c(ptr: *i16, delta: i16): i16;
extern function atomic_compare_exchange_i16_c(ptr: *i16, expected: *i16, desired: i16): i32;
extern function atomic_load_u16_c(ptr: *u16): u16;
extern function atomic_store_u16_c(ptr: *u16, val: u16): void;
extern function atomic_fetch_add_u16_c(ptr: *u16, delta: u16): u16;
extern function atomic_compare_exchange_u16_c(ptr: *u16, expected: *u16, desired: u16): i32;
extern function atomic_fence_seq_cst_c(): void;
extern function atomic_fence_acquire_c(): void;
extern function atomic_fence_release_c(): void;

function std_atomic_load_i32(ptr: *i32): i32 { return atomic_load_i32_c(ptr); }
function std_atomic_store_i32(ptr: *i32, val: i32): void { atomic_store_i32_c(ptr, val); }
function std_atomic_compare_exchange_i32(ptr: *i32, expected: *i32, desired: i32): i32 { return atomic_compare_exchange_i32_c(ptr, expected, desired); }
function std_atomic_fetch_add_i32(ptr: *i32, delta: i32): i32 { return atomic_fetch_add_i32_c(ptr, delta); }
function std_atomic_fetch_sub_i32(ptr: *i32, delta: i32): i32 { return atomic_fetch_sub_i32_c(ptr, delta); }
function std_atomic_load_u32(ptr: *u32): u32 { return atomic_load_u32_c(ptr); }
function std_atomic_store_u32(ptr: *u32, val: u32): void { atomic_store_u32_c(ptr, val); }
function std_atomic_compare_exchange_u32(ptr: *u32, expected: *u32, desired: u32): i32 { return atomic_compare_exchange_u32_c(ptr, expected, desired); }
function std_atomic_fetch_add_u32(ptr: *u32, delta: u32): u32 { return atomic_fetch_add_u32_c(ptr, delta); }
function std_atomic_load_i64(ptr: *i64): i64 { return atomic_load_i64_c(ptr); }
function std_atomic_store_i64(ptr: *i64, val: i64): void { atomic_store_i64_c(ptr, val); }
function std_atomic_load_u64(ptr: *u64): u64 { return atomic_load_u64_c(ptr); }
function std_atomic_store_u64(ptr: *u64, val: u64): void { atomic_store_u64_c(ptr, val); }
function std_atomic_fetch_add_i64(ptr: *i64, delta: i64): i64 { return atomic_fetch_add_i64_c(ptr, delta); }
function std_atomic_fetch_sub_i64(ptr: *i64, delta: i64): i64 { return atomic_fetch_sub_i64_c(ptr, delta); }
function std_atomic_fetch_add_u64(ptr: *u64, delta: u64): u64 { return atomic_fetch_add_u64_c(ptr, delta); }
function std_atomic_fetch_sub_u64(ptr: *u64, delta: u64): u64 { return atomic_fetch_sub_u64_c(ptr, delta); }
function std_atomic_compare_exchange_i64(ptr: *i64, expected: *i64, desired: i64): i32 { return atomic_compare_exchange_i64_c(ptr, expected, desired); }
function std_atomic_compare_exchange_u64(ptr: *u64, expected: *u64, desired: u64): i32 { return atomic_compare_exchange_u64_c(ptr, expected, desired); }
function std_atomic_load_i16(ptr: *i16): i16 { return atomic_load_i16_c(ptr); }
function std_atomic_store_i16(ptr: *i16, val: i16): void { atomic_store_i16_c(ptr, val); }
function std_atomic_fetch_add_i16(ptr: *i16, delta: i16): i16 { return atomic_fetch_add_i16_c(ptr, delta); }
function std_atomic_compare_exchange_i16(ptr: *i16, expected: *i16, desired: i16): i32 { return atomic_compare_exchange_i16_c(ptr, expected, desired); }
function std_atomic_load_u16(ptr: *u16): u16 { return atomic_load_u16_c(ptr); }
function std_atomic_store_u16(ptr: *u16, val: u16): void { atomic_store_u16_c(ptr, val); }
function std_atomic_fetch_add_u16(ptr: *u16, delta: u16): u16 { return atomic_fetch_add_u16_c(ptr, delta); }
function std_atomic_compare_exchange_u16(ptr: *u16, expected: *u16, desired: u16): i32 { return atomic_compare_exchange_u16_c(ptr, expected, desired); }
function std_atomic_fence_seq_cst(): void { atomic_fence_seq_cst_c(); }
function std_atomic_fence_acquire(): void { atomic_fence_acquire_c(); }
function std_atomic_fence_release(): void { atomic_fence_release_c(); }
