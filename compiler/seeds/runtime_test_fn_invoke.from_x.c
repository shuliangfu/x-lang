/* seeds/runtime_test_fn_invoke.from_x.c — G-02f-21 product TU
 *
 * R2 migration architecture:
 *   - thin (.x): public test_call_i32_void_c wrapper (validates non-null,
 *     forwards to _impl_c) (XLANG_RUNTIME_TEST_FN_INVOKE_FROM_X)
 *   - rest (this file, always compiled): test_call_i32_void_impl_c bridge
 *     that casts uintptr_t back to `int32_t (*)(void)` and invokes it.
 *
 * Cold path (no guard): this file provides both the public _c wrapper + _impl.
 * R2 path: this file provides only the _impl bridge; the _c wrapper comes
 * from .x.
 */
/**
 * runtime_test_fn_invoke.c — std.test 函数指针 invoke（F-ZC：自 std/test/test_glue.c 迁入）
 *
 * .x 尚不能稳定经 usize 间接调用；本 TU 提供 test_call_i32_void_c 供 test.x / test.o 链入。
 */
#include <stdint.h>

/* === R2 _impl bridge (always compiled, both cold and R2 paths use it) ===
 * Casts uintptr_t back to `int32_t (*)(void)` and invokes it.
 *
 * 【Why 根因】.x 无法表达 `((int32_t (*)(void))fn)()` 这种 void*→函数指针的
 * 强转调用；间接调用必须留 C。此 _impl_c 桥被 thin (.x) 的
 * test_call_i32_void_c wrapper 调用。
 *
 * 【Invariant】fn 非零（由 thin wrapper 已校验）；调用方约定 fn 指向
 * `int32_t (*)(void)` C ABI 函数。
 *
 * 【Asm/Perf】无性能影响：单次间接调用。 */
int32_t test_call_i32_void_impl_c(uintptr_t fn) {
    return ((int32_t (*)(void))fn)();
}

#ifndef XLANG_RUNTIME_TEST_FN_INVOKE_FROM_X
/* Cold path public wrapper: when XLANG_RUNTIME_TEST_FN_INVOKE_FROM_X is NOT
 * defined, this _c wrapper provides the full implementation (null check +
 * indirect call). When the guard IS defined, the thin (.x) provides the _c
 * wrapper and calls _impl_c above.
 *
 * 经函数指针调用无参返回 i32 的测试函数。
 * 参数：fn 函数地址（0 非法）。
 * 返回值：fn() 或 fn 为 0 时 -1。 */
int32_t test_call_i32_void_c(void *fn) {
    if (fn == 0)
        return -1;
    return test_call_i32_void_impl_c((uintptr_t)fn);
}
#endif /* !XLANG_RUNTIME_TEST_FN_INVOKE_FROM_X */
