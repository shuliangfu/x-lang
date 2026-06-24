/**
 * runtime_abi.c — 编译器 C 侧 ABI 薄壳实现（Phase E-04 v2）
 *
 * 文件职责：提供 argv / target 相关极薄 C 原语；自 runtime.c 拆出，逐步收成 E-04 ABI 薄壳。
 * 所属模块：compiler 运行时；被 main.sx、compile.sx、runtime.c、asm 桥接 TU 链接。
 * 与其它文件的关系：不 include C 前端头；runtime.c 仍承载 pipeline/driver 主体逻辑。
 * 重要约定：与 main.sx 注释一致——.sx 无法安全从 *u8 读取 argv[i] 字符串，须调 driver_get_argv_i。
 */

#include "runtime_abi.h"

#include <string.h>

/**
 * 6.2 极薄原语：将 argv[i] 复制到 buf，最多 max-1 字节并加 NUL。
 * 参数：见 runtime_abi.h。
 * 返回值：拷贝长度（不含 NUL）；失败返回 -1。
 */
int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max) {
    if (!argv || !buf || max <= 0 || i < 0 || i >= argc || !argv[i])
        return -1;
    size_t n = (size_t)max - 1;
    size_t j = 0;
    while (argv[i][j] && j < n) {
        buf[j] = argv[i][j];
        j++;
    }
    buf[j] = '\0';
    return (int)j;
}

/**
 * 去掉 argv[1] 子命令名，供 cmd_build/cmd_run 等子命令路径复用。
 * 参数：见 runtime_abi.h。
 * 返回值：静态 adj[] 槽指针；argc 超 512 时原样返回 argv_opaque。
 */
uint8_t *driver_argv_drop_subcommand(int argc, uint8_t *argv_opaque) {
    static char *adj[512];
    char **argv;
    int i;

    if (argc < 2 || !argv_opaque)
        return argv_opaque;
    argv = (char **)argv_opaque;
    if (argc > 512)
        return argv_opaque;
    adj[0] = argv[0];
    for (i = 2; i < argc; i++)
        adj[i - 1] = argv[i];
    return (uint8_t *)adj;
}

/**
 * Mach-O arm64 宿主默认 target_arch；其它平台保留 parsed_target。
 * 参数：见 runtime_abi.h。
 * 返回值：最终 target_arch。
 */
int32_t driver_resolve_target_arch(int32_t parsed_target, int32_t saw_target_flag) {
    if (saw_target_flag)
        return parsed_target;
#if defined(__APPLE__) && defined(__aarch64__)
    return 1;
#else
    return parsed_target;
#endif
}

/** main.sx 经 -E 或 asm 后端导出的驱动入口；由链接时强符号覆盖 runtime.c 弱桩。 */
extern int main_entry(int argc, char **argv);

/**
 * C main() 统一转发至 main_entry；main.c 与 runtime_asm_build.c 共用，避免重复 extern。
 * 参数：见 runtime_abi.h。
 * 返回值：main_entry 退出码。
 */
int shux_forward_main_to_main_entry(int argc, char **argv) {
    return main_entry(argc, argv);
}

/**
 * NL-07 v5：crt0 _start 在 main_entry 前调用；libc 链 weak 空实现。
 * nostdlib 链 bootstrap_nostdlib_stubs.o 提供强符号（arch_prctl 初始化 %fs:0x28）。
 */
__attribute__((weak)) void bootstrap_init_static_tls(void) {
}

/**
 * NL-07 v5：crt0 在 main_entry 前从 argv 填充 environ；libc 链 weak 空实现。
 */
__attribute__((weak)) void bootstrap_init_environ(int argc, char **argv) {
    (void)argc;
    (void)argv;
}

/** libc 链默认 0；nostdlib bootstrap_nostdlib_stubs.o 提供强符号返回 1。 */
__attribute__((weak)) int bootstrap_nostdlib_pthread_is_stub(void) {
    return 0;
}
