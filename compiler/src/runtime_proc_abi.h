/**
 * runtime_proc_abi.h — 编译器 C 侧进程/链接辅助 ABI（Phase E-04 v4+）
 *
 * 文件职责：声明 waitpid 重试与链接前 .o 路径探测；供 runtime.c invoke_cc/invoke_ld 使用。
 * 所属模块：compiler 运行时进程 ABI；实现于 runtime_proc_abi.c。
 * 与其它文件的关系：不依赖 C 前端；逐步从 runtime.c 拆出，为 invoke_ld 独立 TU 铺路。
 */

#ifndef SHUX_RUNTIME_PROC_ABI_H
#define SHUX_RUNTIME_PROC_ABI_H

#include <sys/types.h>

/**
 * 等待子进程结束；waitpid 遇 EINTR 时重试。
 * 参数：pid 子进程 id；status_out 非 NULL 时写入 wait 状态。
 * 返回值：0 成功；-1 失败（已 perror）。
 */
int shu_waitpid_retry(pid_t pid, int *status_out);

/**
 * 链接可选 std/*.o：路径可读且为常规文件时返回 path，否则 NULL。
 * 参数：path 候选 .o 路径。
 * 返回值：可链入时返回 path，否则 NULL。
 */
const char *asm_link_obj_skip_missing(const char *path);

#endif /* SHUX_RUNTIME_PROC_ABI_H */
