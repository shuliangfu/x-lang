/* G-06 cold-start seed stub for driver/check.sx */
#include <stdint.h>

extern int32_t driver_run_compiler_check(int32_t argc, uint8_t *argv);
int32_t driver_cmd_check(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_check(argc, argv);
}

