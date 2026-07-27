/* seeds/runtime_net_workers.from_x.c — G-02f-20 product TU
 * Product: runtime_net_workers.o
 *
 * R2 migration architecture:
 *   - thin (.x): public xlang_net_worker_accept_entry_ptr_c wrapper +
 *     weak thread_set_affinity_self_c stub (XLANG_RUNTIME_NET_WORKERS_FROM_X)
 *   - rest (this file, always compiled): xlang_net_worker_accept_loop (the
 *     void *(*)(void *) thread body) + xlang_net_worker_accept_entry_ptr_impl_c
 *     (returns the function pointer as uintptr_t).
 *
 * Cold path (no guard): this file provides both the public _c wrapper + _impl.
 * R2 path: this file provides only the _impl bridge; the _c wrapper comes
 * from .x. The thread body and _impl bridge are always compiled.
 */
/**
 * runtime_net_workers.c — accept worker 线程入口胶层（F-ZC：自 std/net/workers_glue.c 迁入）
 *
 * .x 暂无法导出 void* (*)(void*) 线程入口；循环 accept_many+close 保留于此。
 * 编排（thread_create/join）见 workers.x；与 net.o 一并链入 exe。
 */
#include <xlang_weak.h>

#include <stddef.h>
#include <stdint.h>

/** 每 worker 一次 accept_many 批量上限（与 IO_NET_BATCH_MAX 对齐）。 */
#define XLANG_NET_ACCEPT_BATCH 64

/** worker 线程参数（与 workers.x NetWorkerArg ABI 一致）。 */
struct xlang_net_worker_arg {
    int32_t listener_fd;
    uint32_t timeout_ms;
    int32_t worker_index;
};

extern int net_accept_many_c(int32_t listener_fd, int32_t *out_fds, int n, uint32_t timeout_ms);
extern int32_t net_close_socket_c(int32_t fd);

/* Forward declaration of the (possibly weak) affinity setter. In cold path
 * this is the XLANG_WEAK stub defined below; in R2 path it is defined in the
 * thin (.x) side. Either way the thread body can call it. */
int32_t thread_set_affinity_self_c(int32_t cpu_index);

#ifndef XLANG_RUNTIME_NET_WORKERS_FROM_X
/* 可选绑核：弱 stub；链接 std/thread/thread.o 时由强符号覆盖。
 * R2 mode: weak stub provided by thin (.x). This block is skipped. */
#if defined(__GNUC__) || defined(__clang__)
XLANG_WEAK int32_t thread_set_affinity_self_c(int32_t cpu_index) {
    (void)cpu_index;
    return 0;
}
#endif
#endif /* !XLANG_RUNTIME_NET_WORKERS_FROM_X */

/* === Thread body (always compiled, both cold and R2 paths use it) ===
 * 【Why 根源】.x 无法表达 void *(*)(void *) 线程入口签名；线程体循环
 * accept_many+close 必须保留在 C。此函数被 _impl_c 桥返回其地址。
 *
 * 【Invariant】线程体无限循环 accept_many+close；正常不返回（除非 accept
 * 接口报错退出）。调用方通过 thread_create_c 启动。
 *
 * 【Asm/Perf】循环无 sleep；accept_many 自带 timeout 节流。 */
static void *xlang_net_worker_accept_loop(void *arg) {
    struct xlang_net_worker_arg *a = (struct xlang_net_worker_arg *)arg;
#if defined(__GNUC__) || defined(__clang__)
    (void)thread_set_affinity_self_c(a->worker_index);
#endif
    int32_t fds[XLANG_NET_ACCEPT_BATCH];
    for (;;) {
        int n = net_accept_many_c(a->listener_fd, fds, XLANG_NET_ACCEPT_BATCH, a->timeout_ms);
        int i;
        for (i = 0; i < n; i++)
            (void)net_close_socket_c(fds[i]);
    }
    return NULL;
}

/* === R2 _impl bridge (always compiled, both cold and R2 paths use it) ===
 * Returns the address of xlang_net_worker_accept_loop as uintptr_t.
 *
 * 【Why 根因】.x 无法表达 void *(*)(void *) 线程入口签名；线程体循环
 * accept_many+close 必须保留在 C。此 _impl_c 桥被 thin (.x) 的
 * xlang_net_worker_accept_entry_ptr_c wrapper 调用，将函数指针以 uintptr_t
 * 形式返回给 .x 侧（供 thread_create_c 使用）。
 *
 * 【Invariant】返回值是 C 函数指针，调用方须以 thread_create_c 的 entry
 * 参数约定使用（usize/i64 容纳）。
 *
 * 【Asm/Perf】无性能影响：仅返回常量函数地址。 */
uintptr_t xlang_net_worker_accept_entry_ptr_impl_c(void) {
    return (uintptr_t)xlang_net_worker_accept_loop;
}

#ifndef XLANG_RUNTIME_NET_WORKERS_FROM_X
/* Cold path public wrapper: when XLANG_RUNTIME_NET_WORKERS_FROM_X is NOT
 * defined, this _c wrapper provides the full implementation. When the guard
 * IS defined, the thin (.x) provides the _c wrapper and calls _impl_c above. */
uintptr_t xlang_net_worker_accept_entry_ptr_c(void) {
    return xlang_net_worker_accept_entry_ptr_impl_c();
}
#endif /* !XLANG_RUNTIME_NET_WORKERS_FROM_X */
