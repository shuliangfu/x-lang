/**
 * runtime.inc — G-02f-14 退役包装
 *
 * 产品源：seeds/runtime.from_x.c
 * 变体目标（不同 cflags）：
 *   src/runtime_driver_no_c.o  — G05 产品（NO_C + X pipeline/driver）
 *   src/runtime_driver.o / src/runtime_x.o / src/runtime.o
 *   src/runtime_driver_asm_bstrict.o 等
 * 本文件仅给仍引用 .inc 的冷启动脚本：直接纳入 seed。
 */
#include "seeds/runtime.from_x.c"
