/* seeds/runtime_math_libm.from_x.c — G-02f-19 product TU
 * G-02f-119 true .x pure helpers.
 * G-02f-100 math helper gates.
 * Product: runtime_math_libm.o; R2 full mode — thin (.x) provides public API, rest (.c) provides OS bridges.
 *
 * libm：floor/ceil/trunc/round/sin/cos/tan/asin/acos/atan/atan2/
 *        sqrt/cbrt/pow/exp/log/fabs/signum/fmin/fmax/erf/erfc/log1p/expm1
 * fenv：mask_to_fe/fe_to_mask/emit_cap_report/available/test/clear/raise/smoke/capability_smoke
 */
#include <xlang_weak.h>
#include <stdint.h>
#include <math.h>
#include <stdio.h>
#include "diag.h"

#ifndef diag_reportf
XLANG_WEAK void diag_reportf(const char *file, int line, int col, const char *tag, const char *code, const char *fmt, ...) {
  (void)file; (void)line; (void)col; (void)tag; (void)code; (void)fmt;
}
#endif

#if defined(__APPLE__) || (defined(__linux__) && !defined(__ANDROID__))
#include <fenv.h>
#define XLANG_MATH_HAVE_FENV 1
#if defined(__APPLE__)
#pragma STDC FENV_ACCESS ON
#endif
#else
#define XLANG_MATH_HAVE_FENV 0
#endif

#define FENV_NOT_IMPL (-9)

/* thin forward declarations: thin functions (.x) called by rest smoke/test */
int math_special_near(double a, double b, double eps);
int math_fenv_mask_to_fe(int32_t mask);
int32_t math_fenv_fe_to_mask(int fe);
void math_fenv_emit_cap_report(int32_t avail);

#ifdef XLANG_RUNTIME_MATH_LIBM_FROM_X
/* In R2 mode, _c functions are provided by thin (.x); rest needs forward decls */
double math_erf_c(double x);
double math_erfc_c(double x);
double math_log1p_c(double x);
double math_expm1_c(double x);
int32_t math_fenv_available_c(void);
#endif

/* === libm _impl functions (called by thin .x wrappers) === */

double math_floor_impl(double x) { return floor(x); }
double math_ceil_impl(double x) { return ceil(x); }
double math_trunc_impl(double x) { return trunc(x); }
double math_round_impl(double x) { return round(x); }
double math_sin_impl(double x) { return sin(x); }
double math_cos_impl(double x) { return cos(x); }
double math_tan_impl(double x) { return tan(x); }
double math_asin_impl(double x) { return asin(x); }
double math_acos_impl(double x) { return acos(x); }
double math_atan_impl(double x) { return atan(x); }
double math_atan2_impl(double y, double x) { return atan2(y, x); }
double math_sqrt_impl(double x) { return sqrt(x); }
double math_cbrt_impl(double x) { return cbrt(x); }
double math_pow_impl(double base, double exp) { return pow(base, exp); }
double math_exp_impl(double x) { return exp(x); }
double math_log_impl(double x) { return log(x); }
double math_fabs_impl(double x) { return fabs(x); }
double math_fmin_impl(double a, double b) { return fmin(a, b); }
double math_fmax_impl(double a, double b) { return fmax(a, b); }
double math_erf_impl(double x) { return erf(x); }
double math_erfc_impl(double x) { return erfc(x); }
double math_log1p_impl(double x) { return log1p(x); }
double math_expm1_impl(double x) { return expm1(x); }

/* === libm thin wrappers (only when NOT in R2 from_x mode) === */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
double math_floor_c(double x) { return math_floor_impl(x); }
double math_ceil_c(double x) { return math_ceil_impl(x); }
double math_trunc_c(double x) { return math_trunc_impl(x); }
double math_round_c(double x) { return math_round_impl(x); }
double math_sin_c(double x) { return math_sin_impl(x); }
double math_cos_c(double x) { return math_cos_impl(x); }
double math_tan_c(double x) { return math_tan_impl(x); }
double math_asin_c(double x) { return math_asin_impl(x); }
double math_acos_c(double x) { return math_acos_impl(x); }
double math_atan_c(double x) { return math_atan_impl(x); }
double math_atan2_c(double y, double x) { return math_atan2_impl(y, x); }
double math_sqrt_c(double x) { return math_sqrt_impl(x); }
double math_cbrt_c(double x) { return math_cbrt_impl(x); }
double math_pow_c(double base, double exp) { return math_pow_impl(base, exp); }
double math_exp_c(double x) { return math_exp_impl(x); }
double math_log_c(double x) { return math_log_impl(x); }
double math_fabs_c(double x) { return math_fabs_impl(x); }
double math_fmin_c(double a, double b) { return math_fmin_impl(a, b); }
double math_fmax_c(double a, double b) { return math_fmax_impl(a, b); }
double math_erf_c(double x) { return math_erf_impl(x); }
double math_erfc_c(double x) { return math_erfc_impl(x); }
double math_log1p_c(double x) { return math_log1p_impl(x); }
double math_expm1_c(double x) { return math_expm1_impl(x); }
#endif

/* === signum: thin provides full .x impl; rest keeps C copy for cold path === */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
double math_signum_c(double x) {
  if (x > 0.0) {
    return 1.0;
  }
  if (x < 0.0) {
    return -1.0;
  }
  return 0.0;
}
#endif

/* === special_near: thin provides full .x impl; rest keeps C copy for cold path === */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int math_special_near(double a, double b, double eps) {
  double d = a - b;
  if (d < 0.0) {
    d = -d;
  }
  return d <= eps ? 1 : 0;
}
#endif

/* === special_smoke_c: test function, always provided by seed === */

int32_t math_special_smoke_c(void) {
  if (!math_special_near(math_erf_c(0.0), 0.0, 1.0e-12)) {
    return 1;
  }
  if (!math_special_near(math_erf_c(1.0), 0.8427007929497149, 1.0e-6)) {
    return 2;
  }
  if (!math_special_near(math_log1p_c(0.0), 0.0, 1.0e-12)) {
    return 3;
  }
  if (!math_special_near(math_expm1_c(0.0), 0.0, 1.0e-12)) {
    return 4;
  }
  if (!math_special_near(math_erfc_c(0.0), 1.0, 1.0e-12)) {
    return 5;
  }
  return 0;
}

/* === fenv functions === */

#if XLANG_MATH_HAVE_FENV

/* fenv_mask_to_fe_impl: thin calls this via bridge declaration */
int math_fenv_mask_to_fe_impl(int32_t mask) {
  int fe = 0;
  if (mask & 1) fe |= FE_INVALID;
  if (mask & 2) fe |= FE_DIVBYZERO;
  if (mask & 4) fe |= FE_OVERFLOW;
  if (mask & 8) fe |= FE_UNDERFLOW;
  if (mask & 16) fe |= FE_INEXACT;
  return fe;
}

/* fenv_mask_to_fe: thin wrapper in .x; rest keeps C copy for cold path */
#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int math_fenv_mask_to_fe(int32_t mask) {
    return math_fenv_mask_to_fe_impl(mask);
}
#endif

/* fenv_fe_to_mask_impl: thin calls this via bridge declaration */
int32_t math_fenv_fe_to_mask_impl(int fe) {
  int32_t m = 0;
  if (fe & FE_INVALID) m |= 1;
  if (fe & FE_DIVBYZERO) m |= 2;
  if (fe & FE_OVERFLOW) m |= 4;
  if (fe & FE_UNDERFLOW) m |= 8;
  if (fe & FE_INEXACT) m |= 16;
  return m;
}

/* fenv_fe_to_mask: thin wrapper in .x; rest keeps C copy for cold path */
#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int32_t math_fenv_fe_to_mask(int fe) {
    return math_fenv_fe_to_mask_impl(fe);
}
#endif

/* fenv_emit_cap_report_impl: thin calls this via bridge declaration */
void math_fenv_emit_cap_report_impl(int32_t avail) {
  const char *plat = "Unknown";
#if defined(__APPLE__)
  plat = "Darwin";
#elif defined(__linux__)
  plat = "Linux";
#elif defined(_WIN32)
  plat = "Windows";
#endif
  diag_reportf(NULL, 0, 0, "note", NULL,
               "math fenv cap: platform=%s available=%d",
               plat, (int)avail);
}

/* fenv_emit_cap_report: thin wrapper in .x; rest keeps C copy for cold path */
#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
void math_fenv_emit_cap_report(int32_t avail) {
    math_fenv_emit_cap_report_impl(avail);
}
#endif

#endif /* XLANG_MATH_HAVE_FENV */

/* === fenv public API _impl functions (called by thin .x wrappers) === */

int32_t math_fenv_available_impl_c(void) {
#if XLANG_MATH_HAVE_FENV
  math_fenv_emit_cap_report(1);
  return 1;
#else
  math_fenv_emit_cap_report(0);
  return 0;
#endif
}

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int32_t math_fenv_available_c(void) {
#if XLANG_MATH_HAVE_FENV
  math_fenv_emit_cap_report(1);
  return 1;
#else
  math_fenv_emit_cap_report(0);
  return 0;
#endif
}
#endif

int32_t math_fenv_test_impl_c(int32_t mask) {
#if XLANG_MATH_HAVE_FENV
  return math_fenv_fe_to_mask(fetestexcept(math_fenv_mask_to_fe(mask)));
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int32_t math_fenv_test_c(int32_t mask) {
#if XLANG_MATH_HAVE_FENV
  return math_fenv_fe_to_mask(fetestexcept(math_fenv_mask_to_fe(mask)));
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}
#endif

int32_t math_fenv_clear_impl_c(int32_t mask) {
#if XLANG_MATH_HAVE_FENV
  return feclearexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int32_t math_fenv_clear_c(int32_t mask) {
#if XLANG_MATH_HAVE_FENV
  return feclearexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}
#endif

int32_t math_fenv_raise_impl_c(int32_t mask) {
#if XLANG_MATH_HAVE_FENV
  return feraiseexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int32_t math_fenv_raise_c(int32_t mask) {
#if XLANG_MATH_HAVE_FENV
  return feraiseexcept(math_fenv_mask_to_fe(mask)) == 0 ? 0 : 1;
#else
  (void)mask;
  return FENV_NOT_IMPL;
#endif
}
#endif

int32_t math_fenv_smoke_impl_c(void) {
#if XLANG_MATH_HAVE_FENV
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

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int32_t math_fenv_smoke_c(void) {
#if XLANG_MATH_HAVE_FENV
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
#endif

int32_t math_fenv_capability_smoke_impl_c(void) {
  (void)math_fenv_available_c();
  return 0;
}

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
int32_t math_fenv_capability_smoke_c(void) {
  (void)math_fenv_available_c();
  return 0;
}
#endif
