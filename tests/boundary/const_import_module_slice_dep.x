// Dep-module TYPE_ARRAY const for import-module const FIELD dest-SLICE.
// Product spelling is `dep.A` (bare import const is rejected).
// PLATFORM: SHARED — Ubuntu gold typeck whitelist + host-C / asm emit.

const A: [2]i32 = [10, 32];
