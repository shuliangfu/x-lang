/**
 * runtime_math_libm.c — libm / fenv 胶层（F-ZC：自 std/math/math_libm_glue.c 迁入）
 *
 * floor/sin/sqrt/erf 等 libm 转发与 fenv；常量/signum/special_smoke 在 math.sx；与 math.o 一并链入（须 -lm）。
 */
#include <stdint.h>
#include <math.h>
#include <stdio.h>

#if defined(__APPLE__) || (defined(__linux__) && !defined(__ANDROID__))
#include <fenv.h>
#define SHUX_MATH_HAVE_FENV 1
#if defined(__APPLE__)
#pragma STDC FENV_ACCESS ON
#endif
#else
#define SHUX_MATH_HAVE_FENV 0
#endif

#define FENV_NOT_IMPL (-9)

/** libm：向下取整。 */
double math_floor_c(double x) { return floor(x); }

/** libm：向上取整。 */
double math_ceil_c(double x) { return ceil(x); }

/** libm：截断取整。 */
double math_trunc_c(double x) { return trunc(x); }

/** libm：四舍五入。 */
double math_round_c(double x) { return round(x); }

/** libm：正弦。 */
double math_sin_c(double x) { return sin(x); }

/** libm：余弦。 */
double math_cos_c(double x) { return cos(x); }

/** libm：正切。 */
double math_tan_c(double x) { return tan(x); }

/** libm：反正弦。 */
double math_asin_c(double x) { return asin(x); }

/** libm：反余弦。 */
double math_acos_c(double x) { return acos(x); }

/** libm：反正切。 */
double math_atan_c(double x) { return atan(x); }

/** libm：双参数反正切。 */
double math_atan2_c(double y, double x) { return atan2(y, x); }

/** libm：平方根。 */
double math_sqrt_c(double x) { return sqrt(x); }

/** libm：立方根。 */
double math_cbrt_c(double x) { return cbrt(x); }

/** libm：幂。 */
double math_pow_c(double base, double exp) { return pow(base, exp); }

/** libm：自然指数。 */
double math_exp_c(double x) { return exp(x); }

/** libm：自然对数。 */
double math_log_c(double x) { return log(x); }

/** libm：绝对值。 */
double math_fabs_c(double x) { return fabs(x); }

/** libm：较小值。 */
double math_fmin_c(double a, double b) { return fmin(a, b); }

/** libm：较大值。 */
double math_fmax_c(double a, double b) { return fmax(a, b); }

/** libm：误差函数 erf。 */
double math_erf_c(double x) { return erf(x); }

/** libm：互补误差函数 erfc。 */
double math_erfc_c(double x) { return erfc(x); }

/** libm：log(1+x)。 */
double math_log1p_c(double x) { return log1p(x); }

/** libm：exp(x)-1。 */
double math_expm1_c(double x) { return expm1(x); }

#if SHUX_MATH_HAVE_FENV
/** 将 Shux fenv 掩码转为 FE_* 位。 */
static int math_fenv_mask_to_fe(int32_t mask) {
  int fe = 0;
  if (mask & 1) fe |= FE_INVALID;
  if (mask & 2) fe |= FE_DIVBYZERO;
  if (mask & 4) fe |= FE_OVERFLOW;
  if (mask & 8) fe |= FE_UNDERFLOW;
  if (mask & 16) fe |= FE_INEXACT;
  return fe;
}

/** 将 FE_* 位转为 Shux fenv 掩码。 */
static int32_t math_fenv_fe_to_mask(int fe) {
  int32_t m = 0;
  if (fe & FE_INVALID) m |= 1;
  if (fe & FE_DIVBYZERO) m |= 2;
  if (fe & FE_OVERFLOW) m |= 4;
  if (fe & FE_UNDERFLOW) m |= 8;
  if (fe & FE_INEXACT) m |= 16;
  return m;
}
#endif

/** 输出 STD-149 fenv 能力报告行到 stderr。 */
static void math_fenv_emit_cap_report(int32_t avail) {
  const char *plat = "Unknown";
#if defined(__APPLE__)
  plat = "Darwin";
#elif defined(__linux__)
  plat = "Linux";
#elif defined(_WIN32)
  plat = "Windows";
#endif
  fprintf(stderr, "shux: [SHUX_MATH_FENV_CAP] platform=%s available=%d\n", plat, (int)avail);
}

/**
 * 当前平台是否支持 fenv API。
 * 返回值：1 支持，0 不支持。
 */
int32_t math_fenv_available_c(void) {
#if SHUX_MATH_HAVE_FENV
  math_fenv_emit_cap_report(1);
  return 1;
#else
  math_fenv_emit_cap_report(0);
  return 0;
#endif
}

/**
 * 测试浮点异常标志；返回当前掩码，不支持时 FENV_NOT_IMPL。
 */
int32_t math_fenv_test_c(int32_t mask) {
#if SHUX_MATH_HAVE_FENV
  return math_fenv_fe_to_mask(fetestexcept(math_fenv_mask_to_fe(mask)));
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

/**
 * 清除浮点异常标志；成功 0，失败 1，不支持 FENV_NOT_IMPL。
 */
int32_t math_fenv_clear_c(int32_t mask) {
#if SHUX_MATH_HAVE_FENV
  return feclearexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

/**
 * 触发浮点异常标志；成功 0，失败 1，不支持 FENV_NOT_IMPL。
 */
int32_t math_fenv_raise_c(int32_t mask) {
#if SHUX_MATH_HAVE_FENV
  return feraiseexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

/**
 * STD-059 fenv 烟测：invalid/overflow 往返；不支持返回 FENV_NOT_IMPL。
 */
int32_t math_fenv_smoke_c(void) {
#if SHUX_MATH_HAVE_FENV
  feclearexcept(FE_ALL_EXCEPT);
  volatile double nan_val = 0.0 / 0.0;
  (void)nan_val;
  if ((fetestexcept(FE_INVALID) & FE_INVALID) == 0) return 1;
  if (feclearexcept(FE_INVALID) != 0) return 2;
  if ((fetestexcept(FE_INVALID) & FE_INVALID) != 0) return 3;
  if (feraiseexcept(FE_OVERFLOW) != 0) return 4;
  if ((fetestexcept(FE_OVERFLOW) & FE_OVERFLOW) == 0) return 5;
  feclearexcept(FE_ALL_EXCEPT);
  return 0;
#else
  return FENV_NOT_IMPL;
#endif
}

/** STD-149 能力烟测：输出 cap 报告行。 */
int32_t math_fenv_capability_smoke_c(void) {
  (void)math_fenv_available_c();
  return 0;
}
