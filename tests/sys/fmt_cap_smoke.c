/*
 * fmt_cap_smoke.c — Stage 10 (10.7.2) Cap residual probe.
 *
 * Host-cc smoke for xlang_fmt_cap.h: Cap vsnprintf/snprintf without libc fmt.
 * PLATFORM: SHARED (GCC/Clang + Cap va).
 *
 * Build (gate): cc -O0 -Icompiler/include -o /tmp/... tests/sys/fmt_cap_smoke.c
 * Exit: 0 ok; 1..6 step failure.
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <xlang_fmt_cap.h>

/**
 * Cap residual 10.7.2 probe entry.
 * @return 0 ok; nonzero step id on failure
 * PLATFORM: SHARED
 */
int main(void) {
  char buf[64];
  int n = 0;

  memset(buf, 0xab, sizeof(buf));
  n = xlang_snprintf(buf, sizeof(buf), "%d+%d=%d", 10, 32, 42);
  if (n != 8 || strcmp(buf, "10+32=42") != 0) {
    fprintf(stderr, "int fmt n=%d buf=%s\n", n, buf);
    return 1;
  }

  n = xlang_snprintf(buf, sizeof(buf), "%% %c %s", 'Z', "ok");
  if (strcmp(buf, "% Z ok") != 0) {
    fprintf(stderr, "mix buf=%s\n", buf);
    return 2;
  }

  n = xlang_snprintf(buf, sizeof(buf), "%.*s", 3, "hello");
  if (n != 3 || strcmp(buf, "hel") != 0) {
    fprintf(stderr, "prec s n=%d buf=%s\n", n, buf);
    return 3;
  }

  n = xlang_snprintf(buf, sizeof(buf), "%x", 255u);
  if (strcmp(buf, "ff") != 0) {
    fprintf(stderr, "hex buf=%s\n", buf);
    return 4;
  }

  n = xlang_snprintf(buf, sizeof(buf), "%s", (const char *)0);
  if (strcmp(buf, "(null)") != 0) {
    fprintf(stderr, "null s buf=%s\n", buf);
    return 5;
  }

  /* Truncation: size=4 → "42\0" and return would-be len. */
  n = xlang_snprintf(buf, 4, "%d", 12345);
  if (n < 4 || buf[3] != '\0' || buf[0] != '1' || buf[1] != '2' || buf[2] != '3') {
    fprintf(stderr, "trunc n=%d buf=%.8s\n", n, buf);
    return 6;
  }

  return 0;
}
