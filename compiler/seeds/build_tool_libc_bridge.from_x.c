/* seeds/build_tool_libc_bridge.from_x.c — G-02f-79 product cold-start TU
 * Promoted from compiler/src/build_tool_libc_bridge.inc (alias/stub; retired .inc).
 * Compile: cc -c seeds/build_tool_libc_bridge.from_x.c  (or cc_inc_tu wrap).
 */
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
 * 对齐 Makefile 日常发布路径（G-05 产物一致性）：
 *
 * 唯一出口：`scripts/g05_build_shux_asm.sh`
 * - 默认：脚本内 `make shux_asm`（= relink-shux + cp shux→shux_asm）
 * - SHUX_BUILD_TOOL_FULL=1：脚本内 `make bootstrap-driver-bstrict`
 *
 * 勿只跑 build_shux_asm.sh（会留下未 refresh 的 strict 大二进制）。
 * shu_path 保留参数以兼容 build_runner；宿主路径由脚本/Makefile 使用 ./shux。
 */
int32_t build_run_asm_build(uint8_t *shu_path) {
  char cmd[512];
  int n;
  (void)shu_path;
  /* FULL 由脚本读环境；此处只调单点出口，便于日后无 make 实现。 */
  n = snprintf(cmd, sizeof(cmd), "sh scripts/g05_build_shux_asm.sh");
  if (n < 0 || (size_t)n >= sizeof(cmd)) {
    return -1;
  }
  if (build_exec_system(cmd) != 0) {
    return -1;
  }
  return 0;
}

/**
 * make shux_asm 已同步 shux 与 shux_asm；保留 cp 作幂等兜底
 * （显式 ./build_tool ./shux asm 后 runner 仍会调用）。
 */
int32_t build_copy_shux_asm(void) {
  if (build_exec_system("cp -f shux shux_asm 2>/dev/null; true") != 0) {
    return 0;
  }
  /* Prefer gold: shux is primary after make shux_asm */
  (void)build_exec_system("test -f shux && test -f shux_asm && cp -f shux shux_asm");
  return 0;
}
