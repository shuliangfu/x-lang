/**
 * runtime_proc_abi.c — 编译器 C 侧进程/链接辅助 ABI（Phase E-04 v4）
 *
 * 文件职责：waitpid 重试与链接前 .o 存在性探测；自 runtime.c 拆出。
 * 所属模块：compiler 运行时；被 runtime.c invoke_cc / asm_invoke_ld 路径链接。
 * 与其它文件的关系：invoke_ld 主体仍留 runtime.c；本 TU 为 E-04 v4 首拆。
 */

#include "runtime_proc_abi.h"

#include <errno.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

/**
 * 等待子进程；EINTR 时重试，避免 invoke_cc/asm_invoke_ld 误判失败。
 * 参数：见 runtime_proc_abi.h。
 */
int shu_waitpid_retry(pid_t pid, int *status_out) {
    int st = 0;
    for (;;) {
        pid_t w = waitpid(pid, &st, 0);
        if (w == pid) {
            if (status_out)
                *status_out = st;
            return 0;
        }
        if (w == -1 && errno == EINTR)
            continue;
        perror("shux: waitpid");
        return -1;
    }
}

/**
 * 仅当 path 指向已存在常规文件时返回 path，供 clang/ld argv 追加。
 * 参数：见 runtime_proc_abi.h。
 */
const char *asm_link_obj_skip_missing(const char *path) {
    struct stat st;
    if (!path || !path[0])
        return NULL;
    if (stat(path, &st) != 0 || !S_ISREG(st.st_mode))
        return NULL;
    return path;
}
