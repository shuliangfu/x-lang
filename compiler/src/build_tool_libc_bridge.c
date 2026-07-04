/**
 * build_tool_libc_bridge.c — build_tool 宿主 libc 桥（G-05）
 *
 * .x 侧以 *u8 传命令行；若直接在 .x 中 extern system/fopen 等，Darwin 上
 * 与 stdlib 头文件类型冲突。本 TU 提供 build_exec_system 等 C 签名包装。
 */
#include <stdlib.h>
#include <string.h>

/**
 * 执行 shell 命令；cmd 为 NUL 结尾字节串（与 build_runtime_x.x 一致）。
 * 返回 system(3) 状态，失败时由调用方判非零。
 */
int build_exec_system(const char *cmd) {
  if (!cmd) {
    return -1;
  }
  return system(cmd);
}

/**
 * 从 argv[i] 拷贝到 buf；build_tool 专用，避免链入 runtime_abi.c 的 main_entry 转发。
 */
int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max) {
  if (!argv || !buf || max <= 0 || i < 0 || i >= argc || !argv[i]) {
    return -1;
  }
  size_t n = (size_t)max - 1;
  size_t j = 0;
  while (argv[i][j] && j < n) {
    buf[j] = argv[i][j];
    j++;
  }
  buf[j] = '\0';
  return (int)j;
}
