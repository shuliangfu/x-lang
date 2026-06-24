/**
 * runtime_net_workers.c — accept worker 线程入口胶层（F-ZC：自 std/net/net_workers_glue.c 迁入）
 *
 * .sx 暂无法导出 void* (*)(void*) 线程入口；循环 accept_many+close 保留于此。
 * 编排（thread_create/join）见 net_workers.sx；与 net.o 一并链入 exe。
 */

#include <stddef.h>
#include <stdint.h>

/** 每 worker 一次 accept_many 批量上限（与 IO_NET_BATCH_MAX 对齐）。 */
#define SHUX_NET_ACCEPT_BATCH 64

/** worker 线程参数（与 net_workers.sx NetWorkerArg ABI 一致）。 */
struct shu_net_worker_arg {
    int32_t listener_fd;
    uint32_t timeout_ms;
    int32_t worker_index;
};

extern int net_accept_many_c(int32_t listener_fd, int32_t *out_fds, int n, uint32_t timeout_ms);
extern int32_t net_close_socket_c(int32_t fd);

/* 可选绑核：弱 stub；链接 std/thread/thread.o 时由强符号覆盖。 */
#if defined(__GNUC__) || defined(__clang__)
__attribute__((weak)) int32_t thread_set_affinity_self_c(int32_t cpu_index) {
    (void)cpu_index;
    return 0;
}
#endif

/**
 * worker 线程体：绑核（若可用）后循环 accept_many 并 close。
 */
static void *shu_net_worker_accept_loop(void *arg) {
    struct shu_net_worker_arg *a = (struct shu_net_worker_arg *)arg;
#if defined(__GNUC__) || defined(__clang__)
    (void)thread_set_affinity_self_c(a->worker_index);
#endif
    int32_t fds[SHUX_NET_ACCEPT_BATCH];
    for (;;) {
        int n = net_accept_many_c(a->listener_fd, fds, SHUX_NET_ACCEPT_BATCH, a->timeout_ms);
        int i;
        for (i = 0; i < n; i++)
            (void)net_close_socket_c(fds[i]);
    }
    return NULL;
}

/**
 * 返回 accept worker 线程入口地址，供 thread_create_c 使用。
 */
uintptr_t shu_net_worker_accept_entry_ptr_c(void) {
    return (uintptr_t)shu_net_worker_accept_loop;
}
