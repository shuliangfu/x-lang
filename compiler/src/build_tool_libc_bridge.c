/**
 * build_tool_libc_bridge.c — build_tool 宿主 libc 桥（G-05）
 *
 * .x 侧以 *u8 传命令行；若直接在 .x 中 extern system/fopen 等，Darwin 上
 * 与 stdlib 头文件类型冲突。本 TU 提供 build_exec_system 等 C 签名包装。
 *
 * 另：build_run_asm_build / build_copy_shux_asm 放在此 C 侧实现——当前 -x -E
 * 对 build_runtime_x.x 中该函数会截断（丢 copy_path/suffix），导致 build_tool 卡死或恒失败。
 */
#include <stdint.h>
#include <stdio.h>
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

/**
 * SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 SHUX=<shu_path> ./scripts/build_shux_asm.sh
 * 与 build_runtime_x.x build_run_asm_build 语义一致。
 */
int32_t build_run_asm_build(uint8_t *shu_path) {
  char cmd[4096];
  const char *shux = (shu_path && shu_path[0]) ? (const char *)shu_path : "./shux";
  int n = snprintf(cmd, sizeof(cmd),
                   "SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 SHUX=%s ./scripts/build_shux_asm.sh", shux);
  if (n < 0 || (size_t)n >= sizeof(cmd)) {
    return -1;
  }
  if (build_exec_system(cmd) != 0) {
    return -1;
  }
  return 0;
}

/** cp -f shux_asm shux */
int32_t build_copy_shux_asm(void) {
  if (build_exec_system("cp -f shux_asm shux") != 0) {
    return -1;
  }
  return 0;
}
