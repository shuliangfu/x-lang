#include <stdint.h>

/** STD-132 C 金样驱动：声明 env.c 内导出的解析向量测试。 */
extern int32_t env_platform_encoding_smoke_c(void);

int main(void) {
  return env_platform_encoding_smoke_c() != 0;
}
