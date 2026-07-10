/**
 * runtime_test_fn_invoke.c — std.test 函数指针 invoke（F-ZC：自 std/test/test_glue.c 迁入）
 *
 * .x 尚不能稳定经 usize 间接调用；本 TU 提供 test_call_i32_void_c 供 test.x / test.o 链入。
 */
#include <stdint.h>

/**
 * 经函数指针调用无参返回 i32 的测试函数。
 * 参数：fn 函数地址（0 非法）。
 * 返回值：fn() 或 fn 为 0 时 -1。
 */
int32_t test_call_i32_void_c(void *fn) {
    if (fn == 0)
        return -1;
    return ((int32_t (*)(void))fn)();
}
