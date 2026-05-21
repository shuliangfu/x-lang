/**
 * _su_stubs2.c — verify-selfhost-stage2.sh 链接 shu-su2 时的桩与转发
 *
 * Stage2 用 shu-su 生成的 *_gen2.c / *_su2.o 与 C 侧模块混合链接，不链完整
 * bootstrap-driver-seed 的 DRIVER_SUBCMD_OBJS / heap.o 等；本文件补齐：
 * - asm 后端占位（asm_asm_codegen_ast 等）
 * - asm_driver_* → runtime driver_* 转发
 * - std_heap_*（parser_gen2 经 -E-extern 引用）
 * - driver_cmd_* 子命令桩（hello 烟测不走 fmt/check/test）
 * - preprocess 名桥接
 *
 * 构建：verify-selfhost-stage2.sh 编译为 _su_stubs2.o；亦可在本地 cc -c 验证。
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>

/** asm 后端占位：Stage2 仅验 C 生成路径，不链真实 asm 模块。 */
int asm_asm_codegen_ast(void *a, void *b, void *c, void *d) {
    (void)a;
    (void)b;
    (void)c;
    (void)d;
    return -1;
}

/** asm ELF 占位。 */
int asm_asm_codegen_elf_o(void *a, void *b, void *c, void *d, void *e) {
    (void)a;
    (void)b;
    (void)c;
    (void)d;
    (void)e;
    return -1;
}

int io_read_batch_buf(void) { return -1; }
int io_write_batch_buf(void) { return -1; }
int typeck_lsp_main(void) { return -1; }

extern int32_t typeck_preprocess_su_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap);

/** preprocess_gen2 符号名与 typeck 路径对齐。 */
int32_t preprocess_preprocess_su_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap) {
    return typeck_preprocess_su_buf(src, src_len, out_buf, out_cap);
}

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(const char *path);

/** pipeline_gen2 经 asm 模块 extern 的 driver 转发（与 _stubs_driver.c 一致）。 */
int32_t asm_driver_skip_codegen_dep_0_get(void) {
    return driver_skip_codegen_dep_0_get();
}

void asm_driver_set_current_dep_path_for_codegen(uint8_t *path) {
    driver_set_current_dep_path_for_codegen((const char *)path);
}

/** parser_gen2 分配 scratch / arena 堆缓冲。 */
uint8_t *std_heap_alloc_zeroed(size_t size) {
    return size ? (uint8_t *)calloc(1, size) : NULL;
}

void std_heap_free(uint8_t *ptr) {
    free(ptr);
}

/** driver 子命令桩：Stage2 hello 烟测不调用。 */
int32_t driver_cmd_check(int32_t argc, uint8_t *argv) {
    (void)argc;
    (void)argv;
    return -1;
}

int32_t driver_cmd_fmt(int32_t argc, uint8_t *argv) {
    (void)argc;
    (void)argv;
    return -1;
}

int32_t driver_cmd_test(int32_t argc, uint8_t *argv) {
    (void)argc;
    (void)argv;
    return -1;
}
