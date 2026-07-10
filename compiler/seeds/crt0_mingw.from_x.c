/* seeds/crt0_mingw.from_x.c — G-02f-80 product cold-start TU
 * Promoted from compiler/src/asm/crt0_mingw.inc (stub/bridge; retired .inc).
 * Compile: cc -c / cc_inc_tu seeds/crt0_mingw.from_x.c
 */
/**
 * crt0_mingw.c — MinGW/MSYS2/Windows PE 入口（Phase E-04 v21）
 *
 * 文件职责：Win64 PE 由默认 CRT 解析命令行后调 main；本 TU 替代 main.c / main_driver.o。
 * 所属模块：compiler asm 运行时；bootstrap-driver-seed 在 Windows/MinGW/MSYS 默认链入。
 * 重要约定：经 runtime_abi 转发至 main.x 的 main_entry；driver_get_argv_i 仍由 runtime_abi.c 提供。
 */
#include "runtime_abi.h"

/**
 * PE 链接入口：与 main.c 等价，但专用于 Windows 宿主 bootstrap，不链 main_driver.o。
 * 参数：argc/argv 由 MinGW CRT 传入。
 * 返回值：main_entry 退出码。
 */
int main(int argc, char **argv) {
    return shux_forward_main_to_main_entry(argc, argv);
}
