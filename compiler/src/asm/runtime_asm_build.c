/**
 * runtime_asm_build.c — Goal 2 用 asm 后端构建 shux 时的最小 C 桩
 *
 * 仅提供 main()，转调 main.sx 经 -E 生成 C 后的入口符号 main_entry（模块 main 前缀 + function entry）。
 * 与 main.c 一致：main.c 调 main_entry（driver_gen.c）；asm 全链若 main.o 仍为空桩，Goal2 回退链入 driver_su.o
 * 时同样使用 main_entry，而非裸符号 entry。
 *
 * 链接时需：本 .o + main.sx 对应实现（asm main.o 或 driver_su.o 等）+ runtime_driver.o + -lc。
 *
 * pipeline.sx -E 内联 asm.sx 时，Codegen 会对「当前模块」的 extern 加 asm_ 前缀（asm_driver_*），而
 * runtime.c 中仍导出 driver_skip_codegen_dep_0_get / driver_set_current_dep_path_for_codegen；
 * hybrid 链接 shux_asm 时在本 TU 提供转发符号，避免 undefined asm_driver_*。
 */
#include <stdint.h>

extern int main_entry(int argc, char **argv);

int main(int argc, char **argv) {
    return main_entry(argc, argv);
}

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(const char *path);

/** 转发至 runtime_driver 中的 driver_skip_codegen_dep_0_get。 */
int32_t asm_driver_skip_codegen_dep_0_get(void) {
    return driver_skip_codegen_dep_0_get();
}

/** 转发至 driver_set_current_dep_path_for_codegen（路径指针与 C 侧一致）。 */
void asm_driver_set_current_dep_path_for_codegen(uint8_t *path) {
    driver_set_current_dep_path_for_codegen((const char *)path);
}
