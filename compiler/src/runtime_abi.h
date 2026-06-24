/**
 * runtime_abi.h — 编译器 C 侧 ABI 薄壳声明（Phase E-04 v2+）
 *
 * 文件职责：声明须保留在 C 的极薄原语（argv 拷贝、子命令 argv 调整、默认 target_arch），供 main.sx / compile.sx 经 extern 调用。
 * 所属模块：compiler 运行时 ABI；实现于 runtime_abi.c。
 * 与其它文件的关系：runtime.c 业务逻辑仍在本 TU；本头仅暴露稳定 FFI 符号，不依赖 lexer/parser/ast。
 * 重要约定：argv 在 ABI 上与 char** 同址；.sx 侧为 *u8，须经 driver_get_argv_i 逐项拷贝字符串。
 */

#ifndef SHUX_RUNTIME_ABI_H
#define SHUX_RUNTIME_ABI_H

#include <stdint.h>

/**
 * 将 argv[i] 复制到 buf（最多 max-1 字节并加 NUL）。
 * 参数：argc/argv 为 C main 风格；i 为下标；buf 输出缓冲；max 为 buf 容量（含 NUL）。
 * 返回值：拷贝字节数（不含 NUL）；i 越界或参数无效时返回 -1。
 */
int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);

/**
 * main.sx 子命令路由：去掉 argv[1]（子命令名），保留 argv[0] 与原 argv[2..]。
 * 参数：argc/argv_opaque 与 main 一致（argv_opaque 与 char** 同址）。
 * 返回值：调整后的 argv 指针（静态槽，单次 main 内单线程安全）；argc<2 时原样返回 argv_opaque。
 */
uint8_t *driver_argv_drop_subcommand(int argc, uint8_t *argv_opaque);

/**
 * 未显式 -target 时为 Mach-O arm64 宿主选择默认 target_arch。
 * 参数：parsed_target 为 argv 解析得到的 0/x86、1/arm64、2/riscv64；saw_target_flag 非 0 表示用户已传 -target。
 * 返回值：最终 target_arch 枚举值。
 */
int32_t driver_resolve_target_arch(int32_t parsed_target, int32_t saw_target_flag);

/**
 * C 程序入口薄转发：main.c / runtime_asm_build.c 的 main() 统一经本符号进入 main.sx 的 main_entry。
 * 参数：argc/argv 与 C main 一致。
 * 返回值：main_entry 的退出码。
 * 说明：Linux x86_64 bootstrap 默认 crt0 直调 main_entry（E-04 v19）；non-Linux 经 shux_forward_main_to_main_entry。
 */
int shux_forward_main_to_main_entry(int argc, char **argv);

/**
 * NL-07 nostdlib：bootstrap_nostdlib_stubs 链入时返回 1（pthread 为同步桩）；
 * libc 链 weak 默认 0。
 */
int bootstrap_nostdlib_pthread_is_stub(void);

#endif /* SHUX_RUNTIME_ABI_H */
