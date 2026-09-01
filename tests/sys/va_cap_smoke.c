/*
 * va_cap_smoke.c — Stage 10 (10.7.1) Cap residual probe.
 *
 * Host-cc smoke for xlang_va_cap.h: start/arg/end/copy without <stdarg.h>.
 * PLATFORM: SHARED (GCC/Clang builtins).
 *
 * Build (gate): cc -O0 -Icompiler/include -o /tmp/... tests/sys/va_cap_smoke.c
 * Exit: 0 ok; 1..5 step failure.
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <xlang_va_cap.h>

/**
 * Cap variadic: sum n trailing int args.
 * @param n count of trailing ints
 * @return sum
 * PLATFORM: SHARED
 */
static int va_cap_sum_n(int n, ...) {
  xlang_va_list ap;
  int i = 0;
  int s = 0;
  xlang_va_start(ap, n);
  for (i = 0; i < n; i++) {
    s = s + xlang_va_arg(ap, int);
  }
  xlang_va_end(ap);
  return s;
}

/**
 * Cap variadic: first trailing pointer as C string; return first byte or -1.
 * @param fmt unused marker (named last before ...)
 * @return (unsigned char)s[0] or -1
 * PLATFORM: SHARED
 */
static int va_cap_first_byte(const char *fmt, ...) {
  xlang_va_list ap;
  const char *s = 0;
  (void)fmt;
  xlang_va_start(ap, fmt);
  s = xlang_va_arg(ap, const char *);
  xlang_va_end(ap);
  if (s == 0) {
    return -1;
  }
  return (int)(unsigned char)s[0];
}

/**
 * Cap variadic: sum via va_copy (consume copy, leave original unused).
 * @param n count
 * @return sum from copied list
 * PLATFORM: SHARED
 */
static int va_cap_sum_copy(int n, ...) {
  xlang_va_list ap;
  xlang_va_list ap2;
  int i = 0;
  int s = 0;
  xlang_va_start(ap, n);
  xlang_va_copy(ap2, ap);
  for (i = 0; i < n; i++) {
    s = s + xlang_va_arg(ap2, int);
  }
  xlang_va_end(ap2);
  xlang_va_end(ap);
  return s;
}

/**
 * Cap residual 10.7.1 probe entry.
 * @return 0 ok; nonzero step id on failure
 * PLATFORM: SHARED
 */
int main(void) {
  if (va_cap_sum_n(3, 10, 20, 12) != 42) {
    fprintf(stderr, "sum_n want 42\n");
    return 1;
  }
  if (va_cap_sum_n(0) != 0) {
    fprintf(stderr, "sum_n empty want 0\n");
    return 2;
  }
  if (va_cap_first_byte("x", "Z") != (int)'Z') {
    fprintf(stderr, "first_byte want Z\n");
    return 3;
  }
  if (va_cap_sum_copy(4, 1, 2, 3, 36) != 42) {
    fprintf(stderr, "sum_copy want 42\n");
    return 4;
  }
  /* Header must not require stdarg.h — preprocessor already succeeded above. */
  if (sizeof(xlang_va_list) == 0) {
    fprintf(stderr, "va_list size 0\n");
    return 5;
  }
  return 0;
}
