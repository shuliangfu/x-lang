/* seeds/runtime_math_libm.from_x.c — G-02f-19 product TU
 * G-02f-119 true .x pure helpers.
 * G-02f-100 math helper gates.
 * Product: runtime_math_libm.o; R2 full mode — thin (.x) provides public API, rest (.c) provides OS bridges.
 *
 * libm：floor/ceil/trunc/round/sin/cos/tan/asin/acos/atan/atan2/
 *        sqrt/cbrt/pow/exp/log/fabs/signum/fmin/fmax/erf/erfc/log1p/expm1
 *        — all math_*_c (exact-7 bit-level + fdlibm); no host <math.h>
 * fenv：mask_to_fe/fe_to_mask/emit_cap_report/available/test/clear/raise/smoke/capability_smoke
 *        (standing C bridge, fenv.h)
 */
#include <xlang_weak.h>
#include <stdint.h>
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

/* === libm _impl functions ===
 * 9.2.4 exact-7 (floor/ceil/trunc/round/fabs/fmin/fmax): host-libm splices
 * removed. Thin (.x) provides bit-level math_*_c on the product path;
 * same-semantics C cold twins live in the guarded block below. rem_pio2
 * twins call math_floor_c / math_fabs_c (G.7, same as .x). No <math.h>.
 */
/* math_floor_impl / math_ceil_impl / math_trunc_impl / math_round_impl /
 * math_fabs_impl / math_fmin_impl / math_fmax_impl host-libm splices
 * removed (9.2.4 exact-7). */
/* math_sin_impl / math_cos_impl / math_tan_impl / math_asin_impl /
 * math_acos_impl / math_atan_impl / math_atan2_impl libm splices
 * removed (9.2.4). */
/* 9.2.4 sqrt/cbrt/exp/log/expm1/log1p/sin/cos/tan/pow/asin/acos/atan/atan2/erf/erfc:
 * fdlibm .x ports on the product path; matching math_*_impl libm splices
 * removed (same-semantics C cold twins live in the guarded block). */

/* === libm thin wrappers (only when NOT in R2 from_x mode) ===
 * 9.2.4 exact-7 (floor/ceil/trunc/round/fabs/fmin/fmax) removed from this
 * forward block: thin (.x) provides full bit-level implementations on the
 * product path, and same-semantics C cold twins live in the guarded block
 * below (G.4: same commit, same semantics on both paths).
 */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X removed */
#endif

/* === exact-7 cold twins (9.2.4): same bit-level algorithm as thin .x ===
 * Thin (.x) provides these on the product path; this C twin keeps the cold
 * (non from_x) path semantics-identical (G.4: same commit, same semantics).
 * Punning via union (strict-aliasing safe); masks computed with shifts —
 * no large hex literals, mirroring the .x source.
 */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
#endif

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
#endif

/* === exp/log cold twins (9.2.4, 2026-09-08): fdlibm e_exp.c / e_log.c ===
 * Thin (.x) provides these on the product path; this C twin keeps the cold
 * (non from_x) path semantics-identical (G.4: same commit, same semantics).
 * Constants are the same plain-decimal literals as the .x source, each
 * Python-verified against the fdlibm hex comment shown. Punning via union.
 */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
#endif

/* === signum: thin provides full .x impl; rest keeps C copy for cold path === */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
#endif

/* === special_near: thin provides full .x impl; rest keeps C copy for cold path === */

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
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
#if XLANG_MATH_HAVE_FENV
#else
  return FENV_NOT_IMPL;
#endif
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
#if XLANG_MATH_HAVE_FENV
#else
  return FENV_NOT_IMPL;
#endif
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
#if XLANG_MATH_HAVE_FENV
#else
  return FENV_NOT_IMPL;
#endif
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
#if XLANG_MATH_HAVE_FENV
#else
  return FENV_NOT_IMPL;
#endif
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
#if XLANG_MATH_HAVE_FENV
#else
  return FENV_NOT_IMPL;
#endif
#endif

int32_t math_fenv_capability_smoke_impl_c(void) {
  (void)math_fenv_available_c();
  return 0;
}

#ifndef XLANG_RUNTIME_MATH_LIBM_FROM_X
#endif
