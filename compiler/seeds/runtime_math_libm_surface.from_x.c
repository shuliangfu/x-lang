/* seeds/runtime_math_libm_surface.from_x.c
 * G-02f runtime_math_libm R2 mixed surface - isomorphic with src/asm/runtime_math_libm.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_math_libm.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (34 #[no_mangle])
 * Mode: mixed - 2 DIRECT compute + 32 thin+rest forwards to _impl
 * Cap residual: 32 extern bridges (math_*_impl)
 * No doc_anchor (runtime_math_libm.x has none).
 * Note: math_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 34 functions = 2 DIRECT (math_signum_c + math_special_near)
 *   + 32 thin+rest forwards to math_*_impl.
 * Regen: ./xlang-c -E ... runtime_math_libm.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
extern double math_signum_c(double x);
extern int32_t math_special_near(double a, double b, double eps);
extern double math_floor_c(double x);
extern double math_ceil_c(double x);
extern double math_trunc_c(double x);
extern double math_round_c(double x);
extern double math_sin_c(double x);
extern double math_cos_c(double x);
extern double math_tan_c(double x);
extern double math_asin_c(double x);
extern double math_acos_c(double x);
extern double math_atan_c(double x);
extern double math_atan2_c(double y, double x);
extern double math_sqrt_c(double x);
extern double math_cbrt_c(double x);
extern double math_pow_c(double base, double exp);
extern double math_exp_c(double x);
extern double math_log_c(double x);
extern double math_fabs_c(double x);
extern double math_fmin_c(double a, double b);
extern double math_fmax_c(double a, double b);
extern double math_erf_c(double x);
extern double math_erfc_c(double x);
extern double math_log1p_c(double x);
extern double math_expm1_c(double x);
extern int32_t math_fenv_mask_to_fe(int32_t mask);
extern int32_t math_fenv_fe_to_mask(int32_t fe);
extern void math_fenv_emit_cap_report(int32_t avail);
extern int32_t math_fenv_available_c(void);
extern int32_t math_fenv_test_c(int32_t mask);
extern int32_t math_fenv_clear_c(int32_t mask);
extern int32_t math_fenv_raise_c(int32_t mask);
extern int32_t math_fenv_smoke_c(void);
extern int32_t math_fenv_capability_smoke_c(void);
extern double math_floor_impl(double x);
extern double math_ceil_impl(double x);
extern double math_trunc_impl(double x);
extern double math_round_impl(double x);
extern double math_sin_impl(double x);
extern double math_cos_impl(double x);
extern double math_tan_impl(double x);
extern double math_asin_impl(double x);
extern double math_acos_impl(double x);
extern double math_atan_impl(double x);
extern double math_atan2_impl(double y, double x);
extern double math_sqrt_impl(double x);
extern double math_cbrt_impl(double x);
extern double math_pow_impl(double base, double exp);
extern double math_exp_impl(double x);
extern double math_log_impl(double x);
extern double math_fabs_impl(double x);
extern double math_fmin_impl(double a, double b);
extern double math_fmax_impl(double a, double b);
extern double math_erf_impl(double x);
extern double math_erfc_impl(double x);
extern double math_log1p_impl(double x);
extern double math_expm1_impl(double x);
extern int32_t math_fenv_mask_to_fe_impl(int32_t mask);
extern int32_t math_fenv_fe_to_mask_impl(int32_t fe);
extern void math_fenv_emit_cap_report_impl(int32_t avail);
double math_signum_c(double x) {
  if ((x > 0.0)) {
    return 1.0;
  }
  if ((x < 0.0)) {
    return -(1.0);
  }
  return 0.0;
}
int32_t math_special_near(double a, double b, double eps) {
  double d = (a - b);
  if ((d < 0.0)) {
    (void)((d = (0.0 - d)));
  }
  if ((d <=eps)) {
    return 1;
  }
  return 0;
}
double math_floor_c(double x) {
  return math_floor_impl(x);
}
double math_ceil_c(double x) {
  return math_ceil_impl(x);
}
double math_trunc_c(double x) {
  return math_trunc_impl(x);
}
double math_round_c(double x) {
  return math_round_impl(x);
}
double math_sin_c(double x) {
  return math_sin_impl(x);
}
double math_cos_c(double x) {
  return math_cos_impl(x);
}
double math_tan_c(double x) {
  return math_tan_impl(x);
}
double math_asin_c(double x) {
  return math_asin_impl(x);
}
double math_acos_c(double x) {
  return math_acos_impl(x);
}
double math_atan_c(double x) {
  return math_atan_impl(x);
}
double math_atan2_c(double y, double x) {
  return math_atan2_impl(y, x);
}
double math_sqrt_c(double x) {
  return math_sqrt_impl(x);
}
double math_cbrt_c(double x) {
  return math_cbrt_impl(x);
}
double math_pow_c(double base, double exp) {
  return math_pow_impl(base, exp);
}
double math_exp_c(double x) {
  return math_exp_impl(x);
}
double math_log_c(double x) {
  return math_log_impl(x);
}
double math_fabs_c(double x) {
  return math_fabs_impl(x);
}
double math_fmin_c(double a, double b) {
  return math_fmin_impl(a, b);
}
double math_fmax_c(double a, double b) {
  return math_fmax_impl(a, b);
}
double math_erf_c(double x) {
  return math_erf_impl(x);
}
double math_erfc_c(double x) {
  return math_erfc_impl(x);
}
double math_log1p_c(double x) {
  return math_log1p_impl(x);
}
double math_expm1_c(double x) {
  return math_expm1_impl(x);
}
int32_t math_fenv_mask_to_fe(int32_t mask) {
  return math_fenv_mask_to_fe_impl(mask);
}
int32_t math_fenv_fe_to_mask(int32_t fe) {
  return math_fenv_fe_to_mask_impl(fe);
}
void math_fenv_emit_cap_report(int32_t avail) {
  (void)(math_fenv_emit_cap_report_impl(avail));
}
extern int32_t math_fenv_available_impl_c(void);
extern int32_t math_fenv_test_impl_c(int32_t mask);
extern int32_t math_fenv_clear_impl_c(int32_t mask);
extern int32_t math_fenv_raise_impl_c(int32_t mask);
extern int32_t math_fenv_smoke_impl_c(void);
extern int32_t math_fenv_capability_smoke_impl_c(void);
int32_t math_fenv_available_c(void) {
  return math_fenv_available_impl_c();
}
int32_t math_fenv_test_c(int32_t mask) {
  return math_fenv_test_impl_c(mask);
}
int32_t math_fenv_clear_c(int32_t mask) {
  return math_fenv_clear_impl_c(mask);
}
int32_t math_fenv_raise_c(int32_t mask) {
  return math_fenv_raise_impl_c(mask);
}
int32_t math_fenv_smoke_c(void) {
  return math_fenv_smoke_impl_c();
}
int32_t math_fenv_capability_smoke_c(void) {
  return math_fenv_capability_smoke_impl_c();
}
