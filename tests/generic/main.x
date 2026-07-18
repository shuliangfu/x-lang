/** Function `id`.
 * Purpose: implements `id`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
function id<T>(x: T): T { return x; }
/** Internal function `main`.
 * Program/test entry point.
 * @param ) i32 { return id<i32>(42
 * @return void
 */
function main(): i32 { return id<i32>(42); }
