/**
 * std/math/math.c — 数学常量与函数（对标 Zig std.math、Rust std::f64）
 *
 * 【文件职责】
 * 常量 PI、E、Tau；舍入 floor/ceil/trunc/round；三角函数 sin/cos/tan、asin/acos/atan、atan2；
 * sqrt、cbrt、pow、exp、log、fabs、signum；erf/erfc/log1p/expm1（STD-115）；
 * fenv 异常标志（STD-059/149）。f64 双精度，对接 libm。
 *
 * 【所属模块/组件】
 * 标准库 std.math；与 std/math/mod.sx 同属一模块。链接需 -lm。
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

/** stub 平台 fenv API 统一返回值（STD-059）。 */
#define FENV_NOT_IMPL (-9)

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#ifndef M_E
#define M_E 2.7182818284590452354
#endif

double math_pi_c(void) { return M_PI; }
double math_e_c(void) { return M_E; }
double math_tau_c(void) { return M_PI * 2.0; }

double math_floor_c(double x) { return floor(x); }
double math_ceil_c(double x) { return ceil(x); }
double math_trunc_c(double x) { return trunc(x); }
double math_round_c(double x) { return round(x); }

double math_sin_c(double x) { return sin(x); }
double math_cos_c(double x) { return cos(x); }
double math_tan_c(double x) { return tan(x); }
double math_asin_c(double x) { return asin(x); }
double math_acos_c(double x) { return acos(x); }
double math_atan_c(double x) { return atan(x); }
double math_atan2_c(double y, double x) { return atan2(y, x); }

double math_sqrt_c(double x) { return sqrt(x); }
double math_cbrt_c(double x) { return cbrt(x); }
double math_pow_c(double base, double exp) { return pow(base, exp); }
double math_exp_c(double x) { return exp(x); }
double math_log_c(double x) { return log(x); }
double math_fabs_c(double x) { return fabs(x); }

/** signum：x>0 返回 1，x<0 返回 -1，x==0 返回 0。 */
double math_signum_c(double x) {
  if (x > 0.0) return 1.0;
  if (x < 0.0) return -1.0;
  return 0.0;
}

double math_fmin_c(double a, double b) { return fmin(a, b); }
double math_fmax_c(double a, double b) { return fmax(a, b); }

double math_erf_c(double x) { return erf(x); }
double math_erfc_c(double x) { return erfc(x); }
double math_log1p_c(double x) { return log1p(x); }
double math_expm1_c(double x) { return expm1(x); }

/** 近似相等；1 是，0 否。 */
static int math_special_near(double a, double b, double eps) {
  double d = a - b;
  if (d < 0.0) d = -d;
  return d <= eps ? 1 : 0;
}

/** STD-115 C 烟测：erf/log1p/expm1 金样。 */
int32_t math_special_smoke_c(void) {
  if (!math_special_near(erf(0.0), 0.0, 1e-12)) return 1;
  if (!math_special_near(erf(1.0), 0.8427007929497149, 1e-6)) return 2;
  if (!math_special_near(log1p(0.0), 0.0, 1e-12)) return 3;
  if (!math_special_near(expm1(0.0), 0.0, 1e-12)) return 4;
  if (!math_special_near(erfc(0.0), 1.0, 1e-12)) return 5;
  return 0;
}

#if SHUX_MATH_HAVE_FENV
/** 将 API 掩码 (FENV_*) 映射为 ISO C FE_* 组合。 */
static int math_fenv_mask_to_fe(int32_t mask) {
  int fe = 0;
  if (mask & 1) fe |= FE_INVALID;
  if (mask & 2) fe |= FE_DIVBYZERO;
  if (mask & 4) fe |= FE_OVERFLOW;
  if (mask & 8) fe |= FE_UNDERFLOW;
  if (mask & 16) fe |= FE_INEXACT;
  return fe;
}

/** 将 FE_* 状态映射回 API 掩码位。 */
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

/** 打印 fenv 能力报告到 stderr（STD-149）。 */
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

/** 平台是否支持 fenv：1=是，0=stub。 */
int32_t math_fenv_available_c(void) {
#if SHUX_MATH_HAVE_FENV
  math_fenv_emit_cap_report(1);
  return 1;
#else
  math_fenv_emit_cap_report(0);
  return 0;
#endif
}

/** 读取 sticky 异常标志；stub 返回 FENV_NOT_IMPL。 */
int32_t math_fenv_test_c(int32_t mask) {
#if SHUX_MATH_HAVE_FENV
  return math_fenv_fe_to_mask(fetestexcept(math_fenv_mask_to_fe(mask)));
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

/** 清除异常标志；成功 0，失败 1；stub 返回 FENV_NOT_IMPL。 */
int32_t math_fenv_clear_c(int32_t mask) {
#if SHUX_MATH_HAVE_FENV
  return feclearexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

/** 置位异常标志（诊断）；成功 0，失败 1；stub 返回 FENV_NOT_IMPL。 */
int32_t math_fenv_raise_c(int32_t mask) {
#if SHUX_MATH_HAVE_FENV
  return feraiseexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

/** STD-059 C 烟测：0/0 触发 invalid → clear → raise overflow。 */
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

/** STD-149 C 能力烟测：打印能力报告并返回 0。 */
int32_t math_fenv_capability_smoke_c(void) {
  (void)math_fenv_available_c();
  return 0;
}
