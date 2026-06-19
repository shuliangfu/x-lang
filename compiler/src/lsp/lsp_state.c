/**
 * lsp_state.c — LSP read_message 的 state 缓冲区，单独编译单元避免被同单元内大数组/栈覆盖。
 * 供 lsp_gen.c 通过 extern 使用（生成代码里 state_buf 被 sed 替换为 g_lsp_state_buf）。
 * 另提供 typeck_lsp_main 入口：在 256MiB 栈 pthread 上跑 lsp.sx 主循环，避免 Alpine/macOS 默认栈在 diag/fmt 时 SIGSEGV/SIGBUS。
 */
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>

/** 由 lsp.sx 导出（function lsp_main_impl）；本文件 wrapper 再导出 typeck_lsp_main 供 main.sx 调用。 */
extern int32_t typeck_lsp_main_impl(void);
extern void driver_bump_stack_limit(void);
extern void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg);

uint8_t g_lsp_state_buf[16388];

/** LSP 主循环线程参数：pthread 入口写回退出码。 */
typedef struct LspMainThreadArgs {
    int32_t result;
} LspMainThreadArgs;

/** pthread 入口：抬高栈上限后执行 typeck_lsp_main_impl。 */
static void *lsp_main_large_stack_thread_fn(void *arg) {
    LspMainThreadArgs *a = (LspMainThreadArgs *)arg;
    driver_bump_stack_limit();
    a->result = typeck_lsp_main_impl();
    return NULL;
}

/**
 * LSP 主入口：在 256MiB 栈线程上运行 lsp_main_impl，与 pipeline/typeck 大栈路径一致。
 * main.sx --lsp 调用此符号；lsp_gen.c 仅提供 typeck_lsp_main_impl。
 */
int32_t typeck_lsp_main(void) {
    LspMainThreadArgs args;
    args.result = -1;
    driver_run_on_large_stack_pthread(lsp_main_large_stack_thread_fn, &args);
    return args.result;
}

/** 供 lsp.sx read_message 使用，避免 lsp_main 栈上再放 16KiB state（与 g_lsp_state_buf 同缓冲）。 */
uint8_t *lsp_state_buf_ptr(void) {
    return g_lsp_state_buf;
}

/**
 * 向 fd 完整写入 buf[0..len)；短写时循环直至写完或出错。
 * LSP stdout 走 libc write，绕过 std.io/io_uring（Linux ARM64 pipe 上曾丢 Content-Length 头）。
 * 成功返回 0，失败返回 -1。
 */
int32_t lsp_write_all(int32_t fd, const uint8_t *buf, int32_t len) {
    int32_t off = 0;
    if (fd < 0 || !buf) {
        return -1;
    }
    if (len <= 0) {
        return 0;
    }
    while (off < len) {
        ssize_t n = write(fd, buf + (size_t)off, (size_t)(len - off));
        if (n < 0) {
            if (errno == EINTR) {
                continue;
            }
            return -1;
        }
        if (n == 0) {
            return -1;
        }
        off += (int32_t)n;
    }
    return 0;
}
