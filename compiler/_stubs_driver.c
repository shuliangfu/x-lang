/**
 * _stubs_driver.c — bootstrap-driver-seed / shu-su 链接桩（仅 asm_driver_*）
 *
 * pipeline_gen.c 中 extern 的 asm_driver_* 转发至 runtime_driver.o 的 driver_*。
 * fmt/check/test 子命令改由 driver_fmt_su.o / driver_check_su.o / driver_test_su.o（.su -E-extern）提供。
 *
 * 链接顺序：_stubs_driver.o 须紧跟 preprocess_su.o 之后（先于 lsp_diag/std *.o），避免与 runtime_driver.o
 * 中 _preprocess / preprocess_preprocess_su_buf 解析顺序导致 Undefined _preprocess。
 * 本文件为构建必需资产，勿在 make clean 的 compiler/_* 通配删除中移除（见 Makefile clean 白名单）。
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(const char *path);

int32_t asm_driver_skip_codegen_dep_0_get(void) {
    return driver_skip_codegen_dep_0_get();
}

void asm_driver_set_current_dep_path_for_codegen(uint8_t *path) {
    driver_set_current_dep_path_for_codegen((const char *)path);
}
