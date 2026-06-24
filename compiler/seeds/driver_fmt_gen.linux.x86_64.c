/* G-06 cold-start seed stub for driver/fmt.sx */
#include <stdint.h>

extern int32_t driver_run_fmt(int32_t argc, uint8_t *argv);
int32_t driver_cmd_fmt(int32_t argc, uint8_t *argv) {
  return driver_run_fmt(argc, argv);
}

