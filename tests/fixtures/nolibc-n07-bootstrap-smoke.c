/**
 * nolibc-n07-bootstrap-smoke.c — NL-07 v3：crt0 + nostdlib 桩最小链入烟测入口
 *
 * 【职责】
 * 提供 main_entry 弱符号实现，供 crt0_x86_64.s 调用；验证
 * -nostdlib -static 链可生成可执行文件且 exit 0。
 *
 * 【用法】
 * 由 tests/lib/nolibc-n07-link-smoke.sh / run-nolibc-n07-v3-link-gate.sh 编译链入。
 */

/**
 * bootstrap crt0 入口；argc/argv 由 _start 传入。
 * 返回值：进程退出码（0 表示烟测通过）。
 */
int main_entry(int argc, char **argv) {
    (void)argc;
    (void)argv;
    return 0;
}
