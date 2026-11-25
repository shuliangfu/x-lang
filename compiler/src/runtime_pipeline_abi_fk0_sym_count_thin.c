/*
 * Host-gcc first-wins twin of labi_fk0_sym_count (labi_ondemand_heavy.x).
 *
 * DIG s198 soft: hello.o U ctx_*_c but fk0 context gate (k==9) count was 4
 * (std_context_* only). Raise to 11 with ctx_*_c needles in
 * labi_od_needle_tables.c; this thin keeps the count in sync for dig PE
 * when the .x object is not rebuilt.
 *
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED fk0 contract.
 */
#include <stdint.h>

/**
 * Count of exact UNDEF needles for fk0 kind k.
 * @param k rel kind (9 = std/context/context.o)
 * @return needle count; 0 if kind out of range
 */
int labi_fk0_sym_count(int k) {
  if (k == 0) {
    return 11;
  }
  if (k == 1) {
    return 2;
  }
  if (k == 2) {
    return 2;
  }
  if (k == 3) {
    return 4;
  }
  if (k == 4) {
    return 12;
  }
  if (k == 5) {
    return 4;
  }
  if (k == 6) {
    return 12;
  }
  if (k == 7) {
    return 11;
  }
  if (k == 8) {
    return 57;
  }
  /* PLATFORM: SHARED — context.o: std_context_* + ctx_*_c. */
  if (k == 9) {
    return 11;
  }
  if (k == 10) {
    return 42;
  }
  if (k == 11) {
    return 9;
  }
  if (k == 12) {
    return 13;
  }
  if (k == 13) {
    return 12;
  }
  if (k == 14) {
    return 15;
  }
  if (k == 15) {
    return 15;
  }
  if (k == 16) {
    return 7;
  }
  if (k == 17) {
    return 6;
  }
  if (k == 18) {
    return 5;
  }
  if (k == 19) {
    return 10;
  }
  if (k == 20) {
    return 27;
  }
  if (k == 21) {
    return 31;
  }
  if (k == 22) {
    return 20;
  }
  if (k == 23) {
    return 10;
  }
  if (k == 24) {
    return 16;
  }
  if (k == 25) {
    return 11;
  }
  if (k == 26) {
    return 11;
  }
  return 0;
}
