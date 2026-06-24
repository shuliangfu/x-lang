/**
 * runtime_thread_glue.c — 线程胶层（F-ZC：自 std/thread/thread_glue.c 迁入）
 *
 * 【文件职责】thread_self/create/join/affinity/QoS 等；与 thread.o 一并链入 exe。
 * 【所属模块】std.thread；Unix 需 -lpthread，Windows 需 kernel32。
 */

#if defined(__linux__)
#define _GNU_SOURCE
#endif
#include <stddef.h>
#include <stdint.h>

#if defined(__linux__)
#include <sched.h>
#include <string.h>
/* 手写 cpu_set 清零与置位，避免依赖 CPU_ZERO/CPU_SET/CPU_ZERO_S/CPU_SET_S 的链接符号（部分 glibc 会未定义） */
static void shu_cpu_zero(cpu_set_t *set) {
    memset(set, 0, sizeof(cpu_set_t));
}
static void shu_cpu_set(unsigned int cpu, cpu_set_t *set) {
    if (cpu < sizeof(cpu_set_t) * 8) {
        size_t idx = cpu / (8 * sizeof(unsigned long));
        size_t bit = cpu % (8 * sizeof(unsigned long));
        ((unsigned long *)set)[idx] |= (unsigned long)1 << bit;
    }
}
#endif

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#include <stdlib.h>
/* Windows：用 CreateThread + WaitForSingleObject；thread_id 存 HANDLE。 */
typedef HANDLE shu_thread_t;
#define SHUX_THREAD_ID_INVALID ((int64_t)(uintptr_t)NULL)
#else
#include <pthread.h>
typedef pthread_t shu_thread_t;
#define SHUX_THREAD_ID_INVALID ((int64_t)0)
#if defined(__APPLE__)
#include <sys/qos.h>
#endif
#endif

/** 当前线程 ID；用于区分线程、多核压榨时每线程一 io_uring。POSIX 为 pthread_self() 的数值表示，Windows 为 GetCurrentThreadId()。 */
int64_t thread_self_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return (int64_t)(intptr_t)GetCurrentThreadId();
#else
    return (int64_t)(uintptr_t)pthread_self();
#endif
}

#if defined(_WIN32) || defined(_WIN64)
struct shu_thread_params { void *(*entry)(void *); void *arg; };
static DWORD WINAPI thread_wrap(LPVOID arg) {
    struct shu_thread_params *p = (struct shu_thread_params *)arg;
    void *(*entry)(void *) = p->entry;
    void *a = p->arg;
    free(p);
    return (DWORD)(uintptr_t)entry(a);
}
#endif

/**
 * 创建新线程；entry 为 C 函数 void* (*)(void*)，arg 传入；成功返回 thread_id（用于 join），失败返回 SHUX_THREAD_ID_INVALID（约定为 0 或 -1）。
 * 调用方保证 entry 非 NULL。
 */
int64_t thread_create_c(void *entry, void *arg) {
    if (entry == NULL) return SHUX_THREAD_ID_INVALID;
#if defined(_WIN32) || defined(_WIN64)
    {
        struct shu_thread_params *params = (struct shu_thread_params *)malloc(sizeof(struct shu_thread_params));
        if (!params) return SHUX_THREAD_ID_INVALID;
        params->entry = (void *(*)(void *))entry;
        params->arg = arg;
        HANDLE h = CreateThread(NULL, 0, thread_wrap, params, 0, NULL);
        if (h == NULL) { free(params); return SHUX_THREAD_ID_INVALID; }
        return (int64_t)(uintptr_t)h;
    }
#else
    {
        pthread_t tid;
        if (pthread_create(&tid, NULL, (void *(*)(void *))entry, arg) != 0)
            return SHUX_THREAD_ID_INVALID;
        return (int64_t)(uintptr_t)tid;
    }
#endif
}

/**
 * 创建新线程并指定栈大小；stack_size 为 0 表示使用默认栈大小。
 * 多 worker 时可用较小栈（如 262144）省内存。成功返回 thread_id，失败返回 SHUX_THREAD_ID_INVALID。
 */
int64_t thread_create_with_stack_c(void *entry, void *arg, size_t stack_size) {
    if (entry == NULL) return SHUX_THREAD_ID_INVALID;
#if defined(_WIN32) || defined(_WIN64)
    {
        struct shu_thread_params *params = (struct shu_thread_params *)malloc(sizeof(struct shu_thread_params));
        if (!params) return SHUX_THREAD_ID_INVALID;
        params->entry = (void *(*)(void *))entry;
        params->arg = arg;
        HANDLE h = CreateThread(NULL, (SIZE_T)stack_size, thread_wrap, params, 0, NULL);
        if (h == NULL) { free(params); return SHUX_THREAD_ID_INVALID; }
        return (int64_t)(uintptr_t)h;
    }
#else
    {
        pthread_t tid;
        if (stack_size == 0) {
            if (pthread_create(&tid, NULL, (void *(*)(void *))entry, arg) != 0)
                return SHUX_THREAD_ID_INVALID;
            return (int64_t)(uintptr_t)tid;
        }
        pthread_attr_t attr;
        if (pthread_attr_init(&attr) != 0) return SHUX_THREAD_ID_INVALID;
        if (pthread_attr_setstacksize(&attr, stack_size) != 0) {
            pthread_attr_destroy(&attr);
            return SHUX_THREAD_ID_INVALID;
        }
        int ret = pthread_create(&tid, &attr, (void *(*)(void *))entry, arg);
        pthread_attr_destroy(&attr);
        if (ret != 0) return SHUX_THREAD_ID_INVALID;
        return (int64_t)(uintptr_t)tid;
    }
#endif
}

/** 等待线程结束；thread_id 为 thread_create_c 返回值。返回 0 成功，-1 失败（如已 join 或无效 id）。 */
int32_t thread_join_c(int64_t thread_id) {
    if (thread_id == SHUX_THREAD_ID_INVALID) return -1;
#if defined(_WIN32) || defined(_WIN64)
    {
        HANDLE h = (HANDLE)(uintptr_t)thread_id;
        if (WaitForSingleObject(h, INFINITE) != WAIT_OBJECT_0) return -1;
        CloseHandle(h);
        return 0;
    }
#else
    {
        pthread_t tid = (pthread_t)(uintptr_t)thread_id;
        if (pthread_join(tid, NULL) != 0) return -1;
        return 0;
    }
#endif
}

/**
 * 将当前线程绑定到指定 CPU（绑核）；多 worker 时减少迁移与缓存抖动。
 * cpu_index：逻辑 CPU 编号（从 0 开始）。成功返回 0，失败返回 -1。
 * Linux：pthread_setaffinity_np(self, ...)；Windows：SetThreadAffinityMask(GetCurrentThread(), 1<<cpu_index)；macOS/BSD 暂返回 -1。
 */
int32_t thread_set_affinity_self_c(int32_t cpu_index) {
    if (cpu_index < 0) return -1;
#if defined(_WIN32) || defined(_WIN64)
    {
        DWORD_PTR mask = (DWORD_PTR)(1ULL << (unsigned)cpu_index);
        if (SetThreadAffinityMask(GetCurrentThread(), mask) == 0) return -1;
        return 0;
    }
#elif defined(__linux__)
    {
        cpu_set_t set;
        shu_cpu_zero(&set);
        shu_cpu_set((unsigned)cpu_index, &set);
        if (pthread_setaffinity_np(pthread_self(), sizeof(set), &set) != 0) return -1;
        return 0;
    }
#else
    (void)cpu_index;
    return -1; /* macOS/BSD 暂不实现 */
#endif
}

/**
 * 将指定线程绑定到指定 CPU；thread_id 为 thread_create_c 返回值。
 * 成功返回 0，失败返回 -1（如无效 thread_id 或平台不支持）。
 */
int32_t thread_set_affinity_c(int64_t thread_id, int32_t cpu_index) {
    if (thread_id == SHUX_THREAD_ID_INVALID || cpu_index < 0) return -1;
#if defined(_WIN32) || defined(_WIN64)
    {
        DWORD_PTR mask = (DWORD_PTR)(1ULL << (unsigned)cpu_index);
        if (SetThreadAffinityMask((HANDLE)(uintptr_t)thread_id, mask) == 0) return -1;
        return 0;
    }
#elif defined(__linux__)
    {
        cpu_set_t set;
        shu_cpu_zero(&set);
        shu_cpu_set((unsigned)cpu_index, &set);
        if (pthread_setaffinity_np((pthread_t)(uintptr_t)thread_id, sizeof(set), &set) != 0) return -1;
        return 0;
    }
#else
    (void)thread_id;
    (void)cpu_index;
    return -1;
#endif
}

/**
 * 仅 macOS：设置当前线程的 QoS 等级，提升调度优先级（无法绑核时的替代）。
 * qos_class：0=default，1=user_interactive，2=user_initiated，3=utility，4=background。
 * worker 线程建议传 2（user_initiated）。成功返回 0，失败或非 macOS 返回 -1。
 */
int32_t thread_set_qos_class_self_c(int32_t qos_class) {
#if defined(__APPLE__)
    qos_class_t q = QOS_CLASS_DEFAULT;
    switch (qos_class) {
        case 0: q = QOS_CLASS_DEFAULT; break;
        case 1: q = QOS_CLASS_USER_INTERACTIVE; break;
        case 2: q = QOS_CLASS_USER_INITIATED; break;
        case 3: q = QOS_CLASS_UTILITY; break;
        case 4: q = QOS_CLASS_BACKGROUND; break;
        default: return -1;
    }
    if (pthread_set_qos_class_self_np(q, 0) != 0) return -1;
    return 0;
#else
    (void)qos_class;
    return -1;
#endif
}

/** 测试/示例用：供 thread_create_c 的 entry，直接返回 NULL。可用于验证 spawn+join 流程。 */
void *thread_dummy_entry(void *arg) {
    (void)arg;
    return NULL;
}

/** 返回 thread_dummy_entry 的地址（usize），便于 .sx 侧无函数指针时仍可测试 thread_create_c(thread_dummy_entry_ptr_c(), 0)。 */
uintptr_t thread_dummy_entry_ptr_c(void) {
    return (uintptr_t)&thread_dummy_entry;
}

/* ——— .sx pipeline 用：codegen 对 std.thread 生成 std_thread_*_c 符号，与 thread.o 链接 ——— */
int64_t std_thread_thread_self_c(void) { return thread_self_c(); }
int64_t std_thread_thread_create_c(void *entry, void *arg) { return thread_create_c(entry, arg); }
int64_t std_thread_thread_create_with_stack_c(void *entry, void *arg, size_t stack_size) { return thread_create_with_stack_c(entry, arg, stack_size); }
int32_t std_thread_thread_join_c(int64_t thread_id) { return thread_join_c(thread_id); }
int32_t std_thread_thread_set_affinity_self_c(int32_t cpu_index) { return thread_set_affinity_self_c(cpu_index); }
int32_t std_thread_thread_set_affinity_c(int64_t thread_id, int32_t cpu_index) { return thread_set_affinity_c(thread_id, cpu_index); }
int32_t std_thread_thread_set_qos_class_self_c(int32_t qos_class) { return thread_set_qos_class_self_c(qos_class); }
uintptr_t std_thread_thread_dummy_entry_ptr_c(void) { return thread_dummy_entry_ptr_c(); }

/* --- STD-043：命名线程与固定 worker 线程池 --- */

#if !defined(_WIN32) && !defined(_WIN64)
#include <stdlib.h>

#define SHU_THREAD_POOL_CAP 128
#define SHU_THREAD_POOL_MAX_WORKERS 8

typedef struct {
    void *(*entry)(void *);
    void *arg;
} shu_pool_job_t;

static pthread_mutex_t g_pool_mu = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t g_pool_not_empty = PTHREAD_COND_INITIALIZER;
static pthread_cond_t g_pool_idle = PTHREAD_COND_INITIALIZER;
static shu_pool_job_t g_pool_q[SHU_THREAD_POOL_CAP];
static int g_pool_head;
static int g_pool_tail;
static int g_pool_count;
static int g_pool_workers;
static int g_pool_started;
static int g_pool_stop_req;
static int g_pool_in_flight;
static pthread_t g_pool_tids[SHU_THREAD_POOL_MAX_WORKERS];

/** worker 主循环：取队列任务执行，stop 时退出。 */
static void *shu_thread_pool_worker(void *arg) {
    (void)arg;
    for (;;) {
        shu_pool_job_t job;
        pthread_mutex_lock(&g_pool_mu);
        while (g_pool_count == 0 && !g_pool_stop_req) {
            pthread_cond_wait(&g_pool_not_empty, &g_pool_mu);
        }
        if (g_pool_stop_req && g_pool_count == 0) {
            pthread_mutex_unlock(&g_pool_mu);
            break;
        }
        job = g_pool_q[g_pool_head];
        g_pool_head = (g_pool_head + 1) % SHU_THREAD_POOL_CAP;
        g_pool_count--;
        g_pool_in_flight++;
        pthread_mutex_unlock(&g_pool_mu);
        if (job.entry) {
            (void)job.entry(job.arg);
        }
        pthread_mutex_lock(&g_pool_mu);
        g_pool_in_flight--;
        if (g_pool_count == 0 && g_pool_in_flight == 0) {
            pthread_cond_broadcast(&g_pool_idle);
        }
        pthread_mutex_unlock(&g_pool_mu);
    }
    return NULL;
}
#endif

/** 设置当前线程名（≤15 字节）；成功 0，不支持 -1。 */
int32_t thread_set_name_self_c(const uint8_t *name, int32_t len) {
    char buf[16];
    int32_t i;
    if (!name || len < 0) {
        return -1;
    }
    if (len > 15) {
        len = 15;
    }
    for (i = 0; i < len; i++) {
        buf[i] = (char)name[i];
    }
    buf[len] = '\0';
#if defined(__linux__)
    if (pthread_setname_np(pthread_self(), buf) != 0) {
        return -1;
    }
    return 0;
#elif defined(__APPLE__)
    if (pthread_setname_np(buf) != 0) {
        return -1;
    }
    return 0;
#else
    (void)buf;
    return -1;
#endif
}

/** 启动固定 worker 线程池；workers 1..8；成功 0。 */
int32_t thread_pool_start_c(int32_t workers) {
#if defined(_WIN32) || defined(_WIN64)
    (void)workers;
    return -1;
#else
    int i;
    if (workers < 1 || workers > SHU_THREAD_POOL_MAX_WORKERS) {
        return -1;
    }
    pthread_mutex_lock(&g_pool_mu);
    if (g_pool_started) {
        pthread_mutex_unlock(&g_pool_mu);
        return 0;
    }
    g_pool_head = 0;
    g_pool_tail = 0;
    g_pool_count = 0;
    g_pool_in_flight = 0;
    g_pool_stop_req = 0;
    g_pool_workers = workers;
    for (i = 0; i < workers; i++) {
        if (pthread_create(&g_pool_tids[i], NULL, shu_thread_pool_worker, NULL) != 0) {
            g_pool_stop_req = 1;
            pthread_cond_broadcast(&g_pool_not_empty);
            while (--i >= 0) {
                pthread_join(g_pool_tids[i], NULL);
            }
            g_pool_workers = 0;
            pthread_mutex_unlock(&g_pool_mu);
            return -1;
        }
    }
    g_pool_started = 1;
    pthread_mutex_unlock(&g_pool_mu);
    return 0;
#endif
}

/** 向池提交任务；队列满时阻塞；成功 0。 */
int32_t thread_pool_submit_c(uintptr_t entry, uintptr_t arg) {
#if defined(_WIN32) || defined(_WIN64)
    (void)entry;
    (void)arg;
    return -1;
#else
    shu_pool_job_t job;
    if (!g_pool_started || entry == 0) {
        return -1;
    }
    job.entry = (void *(*)(void *))entry;
    job.arg = (void *)arg;
    pthread_mutex_lock(&g_pool_mu);
    while (g_pool_count >= SHU_THREAD_POOL_CAP && !g_pool_stop_req) {
        pthread_cond_wait(&g_pool_idle, &g_pool_mu);
    }
    if (g_pool_stop_req) {
        pthread_mutex_unlock(&g_pool_mu);
        return -1;
    }
    g_pool_q[g_pool_tail] = job;
    g_pool_tail = (g_pool_tail + 1) % SHU_THREAD_POOL_CAP;
    g_pool_count++;
    pthread_cond_signal(&g_pool_not_empty);
    pthread_mutex_unlock(&g_pool_mu);
    return 0;
#endif
}

/** 阻塞直至队列与 in-flight 皆空；成功 0。 */
int32_t thread_pool_drain_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return -1;
#else
    if (!g_pool_started) {
        return -1;
    }
    pthread_mutex_lock(&g_pool_mu);
    while (g_pool_count > 0 || g_pool_in_flight > 0) {
        pthread_cond_wait(&g_pool_idle, &g_pool_mu);
    }
    pthread_mutex_unlock(&g_pool_mu);
    return 0;
#endif
}

/** 停止池并 join worker；成功 0。 */
int32_t thread_pool_stop_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return -1;
#else
    int i;
    if (!g_pool_started) {
        return 0;
    }
    pthread_mutex_lock(&g_pool_mu);
    g_pool_stop_req = 1;
    pthread_cond_broadcast(&g_pool_not_empty);
    pthread_mutex_unlock(&g_pool_mu);
    for (i = 0; i < g_pool_workers; i++) {
        pthread_join(g_pool_tids[i], NULL);
    }
    pthread_mutex_lock(&g_pool_mu);
    g_pool_started = 0;
    g_pool_workers = 0;
    g_pool_stop_req = 0;
    g_pool_head = 0;
    g_pool_tail = 0;
    g_pool_count = 0;
    g_pool_in_flight = 0;
    pthread_mutex_unlock(&g_pool_mu);
    return 0;
#endif
}

/** 观测 pending（队列 + in-flight）；未启动 -1。 */
int32_t thread_pool_pending_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return -1;
#else
    int32_t n;
    if (!g_pool_started) {
        return -1;
    }
    pthread_mutex_lock(&g_pool_mu);
    n = g_pool_count + g_pool_in_flight;
    pthread_mutex_unlock(&g_pool_mu);
    return n;
#endif
}
