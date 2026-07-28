/* seeds/target_cpu_flags_surface.from_x.c
 * G-02f-86 target_cpu_flags R2 DIRECT surface - isomorphic with src/driver/target_cpu_flags.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/target_cpu_flags.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (5 #[no_mangle])
 * Mode: DIRECT - 5 #[no_mangle] (driver_set/get_pending_target_cpu_features + tcp_tolower + tcp_eq5 + tcp_eq6)
 * Cap residual: none (pure compute + static BSS, no extern bridges)
 * No doc_anchor (target_cpu_flags.x has none).
 * Note: driver_/tcp_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 5 DIRECT functions + 1 static BSS (g_driver_pending_target_cpu_features).
 * Regen: ./xlang-c -E ... target_cpu_flags.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

static uint32_t g_driver_pending_target_cpu_features = 0;

/* === 5 DIRECT functions === */

void driver_set_pending_target_cpu_features(uint32_t features) {
  g_driver_pending_target_cpu_features = features;
}

uint32_t driver_get_pending_target_cpu_features(void) {
  return g_driver_pending_target_cpu_features;
}

uint8_t tcp_tolower(uint8_t c) {
  if (c >= 65 && c <= 90) {
    return (uint8_t)(c + 32);
  }
  return c;
}

int32_t tcp_eq5(uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4) {
  if (tcp_tolower(name[0]) != a0) { return 0; }
  if (tcp_tolower(name[1]) != a1) { return 0; }
  if (tcp_tolower(name[2]) != a2) { return 0; }
  if (tcp_tolower(name[3]) != a3) { return 0; }
  if (tcp_tolower(name[4]) != a4) { return 0; }
  return 1;
}

int32_t tcp_eq6(uint8_t *name, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4, uint8_t a5) {
  if (tcp_eq5(name, a0, a1, a2, a3, a4) == 0) { return 0; }
  if (tcp_tolower(name[5]) != a5) { return 0; }
  return 1;
}
