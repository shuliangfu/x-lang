/* Cap tip Linux fallback for std/math/math.x bare constants.
 * tip Linux typeck XT001 on math_tau_c → math_pi_c(&p) call; Darwin tip-asm OK.
 * Prefer pure-asm from math.x; this seed restores math_pi_c / math_e_c /
 * math_tau_c without a new host-cc product .c (seed only). */
#include <stdint.h>

int32_t math_pi_c(double *out) {
  if (!out) return -1;
  *out = 3.14159265358979323846;
  return 0;
}

int32_t math_e_c(double *out) {
  if (!out) return -1;
  *out = 2.7182818284590452354;
  return 0;
}

int32_t math_tau_c(double *out) {
  if (!out) return -1;
  *out = 6.28318530717958647692;
  return 0;
}
