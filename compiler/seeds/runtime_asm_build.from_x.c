/* Generated from src/asm/runtime_asm_build.x (G-02f-24 true .x).
 * Regen: ./xlang-c -E -L .. src/asm/runtime_asm_build.x > seeds/runtime_asm_build.from_x.c
 * main argv polished to char** for C ABI.
 */
#include <stdint.h>
#include <stddef.h>
extern int xlang_forward_main_to_main_entry(int argc, char **argv);
extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(const char *path);

/* main 保留 seed：.x 无法表达 char** argv（Clang 强制 main 第二参数为 char**） */
int main(int argc, char **argv) {
  (void)(({   {
    int32_t r = xlang_forward_main_to_main_entry(argc, argv);
    return r;
  }
 }));
  return 0;
}

/* G-02f-20 thin+rest：DIRECT 模式，thin（src/asm/runtime_asm_build.x）提供完整实现 */
#ifndef XLANG_RUNTIME_ASM_BUILD_FROM_X
int32_t asm_driver_skip_codegen_dep_0_get(void) {
  (void)(({   {
    int32_t r = driver_skip_codegen_dep_0_get();
    return r;
  }
 }));
  return 0;
}
void asm_driver_set_current_dep_path_for_codegen(uint8_t *path) {
  (void)(({   {
    (void)(driver_set_current_dep_path_for_codegen((const char *)path));
  }
 }));
}
#endif
