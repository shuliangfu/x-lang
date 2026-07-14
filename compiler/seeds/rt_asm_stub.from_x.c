/* seeds/rt_asm_stub.from_x.c — G-02f-300 P2 runtime R9 → R2 full (asm GAS stub)
 * Logic source: src/runtime/rt_asm_stub.x
 * Hybrid: SHUX_RT_ASM_STUB_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：want_exe + asm_codegen_ast 由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * Cap residual（driver_abi）：GAS 行表 + CodegenOutBuf append。
 * 冷启动/无 PREFER 时仍编译完整 C 体（含 SHUX_WEAK asm_codegen_ast）。
 *
 * Scope: weak minimal GAS codegen stub + want_exe gate.
 * Full elf/macho asm backend remains mega/backend.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#ifndef SHUX_WEAK
#if defined(_WIN32) || defined(_WIN64)
#define SHUX_WEAK
#else
#define SHUX_WEAK __attribute__((weak))
#endif
#endif

/* 与 runtime.from_x.c / pipeline 生成物布局一致（仅作指针形参类型）。 */
#define X_CODEGEN_OUTBUF_CAP (9 * 1024 * 1024)
struct codegen_CodegenOutBuf {
  unsigned char data[X_CODEGEN_OUTBUF_CAP];
  int32_t len;
};

extern int shux_output_want_exe(const char *path);

#ifndef SHUX_RT_ASM_STUB_FROM_X

/** compile.x extern：-o 后缀是否表示可执行（非 .o/.obj/.s）。 */
int32_t driver_asm_output_want_exe(uint8_t *path) {
  return shux_output_want_exe(path ? (const char *)path : NULL);
}

/**
 * asm 后端 C 桩：-backend asm 时由 pipeline 调用，写出最小 GAS（main return 42）。
 * 实验 asm-only 链并入 build_asm/backend.o 时须为 weak，避免与 backend.x 重复定义。
 */
SHUX_WEAK int32_t asm_codegen_ast(void *module, void *arena, struct codegen_CodegenOutBuf *out) {
  static const char *lines[] = {".text",         ".globl main", "main:",       "pushq %rbp", "movq %rsp, %rbp",
                                  "subq $0, %rsp", "movl $42, %eax", "movq %rsp, %rbp", "popq %rbp", "ret"};
  size_t n = 0;
  int i;
  (void)module;
  (void)arena;
  if (!out)
    return -1;
  for (i = 0; i < (int)(sizeof lines / sizeof lines[0]); i++) {
    size_t len = strlen(lines[i]);
    if (n + len + 1 > (size_t)X_CODEGEN_OUTBUF_CAP)
      return -1;
    memcpy(out->data + n, lines[i], len);
    out->data[n + len] = '\n';
    n += len + 1;
  }
  out->len = (int32_t)n;
  return 0;
}

#else
int32_t driver_asm_output_want_exe(uint8_t *path);
int32_t asm_codegen_ast(void *module, void *arena, struct codegen_CodegenOutBuf *out);
#endif

int labi_rt_asm_stub_slice_marker(void) {
  return 1;
}
