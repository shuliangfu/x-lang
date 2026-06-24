/* G-06 cold-start seed stub for driver/test.sx */
#include <stdint.h>

extern int32_t driver_run_test(int32_t argc, uint8_t *argv);
int32_t driver_cmd_test(int32_t argc, uint8_t *argv) {
  return driver_run_test(argc, argv);
}

