/* G-06 cold-start seed stub for driver/run.sx */
#include <stdint.h>

extern int32_t driver_exec_compiled(int32_t argc, uint8_t *argv);
int32_t driver_cmd_run(int32_t argc, uint8_t *argv) {
  return driver_exec_compiled(argc, argv);
}

