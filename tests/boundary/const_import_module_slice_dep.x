// Dep-module consts for import-module FIELD (`dep.K` / `dep.A`).
// Product spelling is `dep.Name` (bare import const is rejected).
// `K` is the scalar INT_LIT emit payload (dep-arena init_ref).
// `A` is the dest-SLICE wrap payload (host-C `{.data=durable,.length=2}`;
// asm durable ARRAY_LIT from this dep arena).
// PLATFORM: SHARED — Ubuntu gold import-const FIELD emit.

const K: i32 = 10;
const A: [2]i32 = [10, 32];
