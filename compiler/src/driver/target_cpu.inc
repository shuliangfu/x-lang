/**
 * target_cpu.inc — G-02f-6 退役包装
 *
 * 产品 / g05 / strict 链统一编译 `seeds/target_cpu_pure.from_x.c` 为
 * `src/driver/target_cpu.o`（含 pure 逻辑 + OS detect）。
 * 本文件仅保留给仍引用 `.inc` 路径的冷启动脚本：直接纳入 seed。
 */
#include "seeds/target_cpu_pure.from_x.c"
