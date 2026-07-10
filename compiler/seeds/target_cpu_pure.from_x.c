/* Generated from src/driver/target_cpu_pure.x (G-02f-2).
 * Regen: ./shux-c src/driver/target_cpu_pure.x -E > seeds/target_cpu_pure.from_x.c
 * Product: ld -r pure.o + detect.o → target_cpu.o
 */
#include <stdint.h>
#include <stddef.h>
static uint32_t g_driver_pending_target_cpu_features;
static void init_globals(void) {
  g_driver_pending_target_cpu_features = 0;
}
void driver_set_pending_target_cpu_features(uint32_t features) {
  (void)((g_driver_pending_target_cpu_features = features));
}
uint32_t driver_get_pending_target_cpu_features(void) {
  return g_driver_pending_target_cpu_features;
}
