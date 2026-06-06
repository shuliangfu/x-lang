/**
 * driver_compile_asm_link_alias.c — strict 链 driver SU 符号别名
 *
 * build_asm/driver_compile.o（EMIT_HEAVY 单编 compile.su）导出 run_compiler_full_su /
 * compile_dispatch_* 裸名；runtime.c 与 C-gen driver_compile_su.o 期望 driver_* 链接名。
 * ld -r 与本 TU 合并为 build_asm/driver_compile_link.o，供 relink_shu_asm_strict_glue 替换
 * driver_compile_su.o。
 */
#include <stdint.h>

/** 与 compile.su DriverCompileState 布局兼容；别名层仅透传指针。 */
struct driver_DriverCompileState;

extern int32_t run_compiler_full_su(int32_t argc, uint8_t *argv);
extern int32_t run_compiler_full_su_post_parse(struct driver_DriverCompileState *state, int32_t argc,
                                               uint8_t *argv);
extern int32_t compile_dispatch_asm_backend(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                            uint8_t *target, int32_t argc, uint8_t *argv);
extern int32_t compile_dispatch_emit_c_path(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                              uint8_t *target, uint8_t *opt_level, int32_t use_lto, int32_t argc,
                                              uint8_t *argv);

/** runtime driver_run_compiler_full 链接入口 → asm EMIT_HEAVY 薄包装。 */
int32_t driver_run_compiler_full_su(int32_t argc, uint8_t *argv) {
  return run_compiler_full_su(argc, argv);
}

/** post_parse 链接名 → asm 裸名（impl_c 经 thin delegate 回调）。 */
int32_t driver_run_compiler_full_su_post_parse(struct driver_DriverCompileState *state, int32_t argc,
                                               uint8_t *argv) {
  return run_compiler_full_su_post_parse(state, argc, argv);
}

/** C-gen / gate 期望的 dispatch 符号 → asm SU 真 emit 裸名。 */
int32_t driver_compile_dispatch_asm_backend(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                            uint8_t *target, int32_t argc, uint8_t *argv) {
  return compile_dispatch_asm_backend(input_path, out_path, lib_key, target, argc, argv);
}

/** C-gen / gate 期望的 dispatch 符号 → asm SU 真 emit 裸名。 */
int32_t driver_compile_dispatch_emit_c_path(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                              uint8_t *target, uint8_t *opt_level, int32_t use_lto, int32_t argc,
                                              uint8_t *argv) {
  return compile_dispatch_emit_c_path(input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv);
}
