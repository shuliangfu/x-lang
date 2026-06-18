/**
 * std/simd/simd.c — STD-153 自动向量化策略探测（SHU_SIMD_AUTovec / SHU_SIMD_HW）
 *
 * 【文件职责】宿主 SIMD 可用性、`recommend_simd_path` 策略分派、C 烟测报告。
 * 【所属模块/组件】标准库 std.simd；与 std/simd/mod.su 同属一模块。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/** lane-scalar 回退路径。 */
#define SIMD_PATH_SCALAR 0
/** 硬件向量 emit（编译器内联 shuffle/select/add 等）。 */
#define SIMD_PATH_HW     1

/** 读取 SHU_SIMD_HW=0 或 SHU_SIMD_AUTovec=scalar 强制标量。 */
static int32_t simd_env_force_scalar(void) {
  const char *hw = getenv("SHU_SIMD_HW");
  if (hw && hw[0] == '0' && hw[1] == '\0') return 1;
  const char *aut = getenv("SHU_SIMD_AUTovec");
  if (!aut) return 0;
  if (strcmp(aut, "scalar") == 0 || strcmp(aut, "0") == 0) return 1;
  return 0;
}

/** 读取 SHU_SIMD_AUTovec=hw 强制硬件路径（不可用则仍标量）。 */
static int32_t simd_env_force_hw(void) {
  const char *aut = getenv("SHU_SIMD_AUTovec");
  if (!aut) return 0;
  if (strcmp(aut, "hw") == 0 || strcmp(aut, "1") == 0) return 1;
  return 0;
}

/**
 * 宿主是否具备已知 SIMD 能力（编译期架构 + v1 启发式）。
 * 返回 1 可用，0 不可用。
 */
int32_t simd_hw_available_c(void) {
#if defined(__aarch64__) || defined(__arm64__) || defined(_M_ARM64)
  return 1;
#elif defined(__x86_64__) || defined(_M_X64) || defined(__amd64__)
  return 1;
#elif defined(__riscv) && __riscv_xlen == 64
  return 1;
#else
  return 0;
#endif
}

/**
 * STD-153：推荐向量化路径。
 * auto（默认）：有 HW 则 SIMD_PATH_HW，否则 SIMD_PATH_SCALAR。
 */
int32_t simd_recommend_path_c(void) {
  if (simd_env_force_scalar()) return SIMD_PATH_SCALAR;
  if (simd_env_force_hw()) {
    return simd_hw_available_c() ? SIMD_PATH_HW : SIMD_PATH_SCALAR;
  }
  return simd_hw_available_c() ? SIMD_PATH_HW : SIMD_PATH_SCALAR;
}

/**
 * STD-153 C 烟测：校验 auto 策略并输出 `shu: [SHU_SIMD_AUTovec]` 报告行。
 * 成功 0，失败非 0。
 */
int32_t simd_autovec_smoke_c(void) {
  const char *plat = "unknown";
#if defined(__APPLE__) && (defined(__aarch64__) || defined(__arm64__))
  plat = "Darwin-arm64";
#elif defined(__APPLE__)
  plat = "Darwin-x86_64";
#elif defined(__linux__) && (defined(__aarch64__) || defined(__arm64__))
  plat = "Linux-aarch64";
#elif defined(__linux__) && (defined(__x86_64__) || defined(__amd64__))
  plat = "Linux-x86_64";
#endif
  int32_t hw = simd_hw_available_c();
  int32_t path = simd_recommend_path_c();
  fprintf(stderr, "shu: [SHU_SIMD_AUTovec] platform=%s hw=%d path=%d\n", plat, (int)hw, (int)path);
  if (hw && path == SIMD_PATH_SCALAR && !simd_env_force_scalar()) {
    if (getenv("SHU_SIMD_AUTovec") == NULL && getenv("SHU_SIMD_HW") == NULL) {
      return 1;
    }
  }
  if (!hw && path != SIMD_PATH_SCALAR) return 2;
  return 0;
}
