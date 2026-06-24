/**
 * main.c — 6.4 极简入口：仅调 runtime_abi 转发至 main.sx 的 main_entry
 *
 * Phase E active (E-04 v21+)：E-04 v21 minimal main；Linux/Darwin/Windows 默认 crt0；本 TU 仅 LEGACY / shux-c 链入。
 * Linux crt0 路径可替代本 TU（见 SELFHOST §6）。文件保留，不删除。
 *
 * 程序入口为 main()；实际驱动由 main_entry 实现（main.sx 提供，或 runtime.c 的弱符号桩转调 run_compiler_c）。
 * 构建/文档标明：入口逻辑在 main.sx，C 侧运行时在 runtime.c。
 */
#include "runtime_abi.h"

int main(int argc, char **argv) {
    return shux_forward_main_to_main_entry(argc, argv);
}
