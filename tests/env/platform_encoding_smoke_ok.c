#include <stdint.h>

/** STD-132 C 金样驱动：声明 env.c 内导出的解析向量测试。 */
extern int32_t env_platform_encoding_smoke_c(void);

/** env.o 内 args_iter 依赖的 process 桩（仅 C 金样链接 env.o 时使用）。 */
int32_t process_args_count_c(void) { return 0; }
uint8_t *process_arg_c(int32_t i) { (void)i; return 0; }

int main(void) {
  return env_platform_encoding_smoke_c() != 0;
}
