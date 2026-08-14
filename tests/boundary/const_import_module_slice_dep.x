// Dep-module consts for import-module FIELD (`dep.K` / `dep.A`).
// Product spelling is `dep.Name` (bare import const is rejected).
// `K` is this typeck-knife payload (INT_LIT emit already exists).
// `A` stays for the dest-SLICE emit leftover (host-C `dep.A` / asm CG002).
// PLATFORM: SHARED — Ubuntu gold typeck whitelist + import-const type remap.

const K: i32 = 10;
const A: [2]i32 = [10, 32];
