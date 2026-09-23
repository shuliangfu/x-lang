/* G-02f-9 / R2 full（2026-07-14）：backend_call_dispatch 真迁
 * Logic source: src/asm/backend_call_dispatch.x
 * Product PREFER_X_O: g05_try_x_to_o(full.x) + rest (-DXLANG_BACKEND_CALL_DISPATCH_FROM_X) ld -r
 *   → src/asm/backend_call_dispatch.o
 * R2: full.x 吃满 CALL/emit/import 公共业务；FROM_X 下 rest 业务 T=0（仅 slice_marker）
 * 冷启动/无 PREFER：本文件完整 C 体（含 L2 thin hybrid 的 _impl 尾）
 * L2 thin hybrid（XLANG_L2_CALL_DISPATCH_THIN_FROM_X）仍作 full.x 失败时的回退路径。
 *
 * seeds/backend_call_dispatch.from_x.c — product backend dispatch TU (cold full C)
 */
#ifndef XLANG_BACKEND_CALL_DISPATCH_FROM_X
/* Class BW: tip from_x 债清零 — cold twin → analysis/archive；产品 FROM_X 仅 slice_marker。 */
#include "../../analysis/archive/backend_call_dispatch/backend_call_dispatch_cold_twin.inc"
#else /* XLANG_BACKEND_CALL_DISPATCH_FROM_X：产品 rest 业务 H=0 */
#include "seeds/call_dispatch_std_redirect_tables.c" /* Class BM */

int backend_call_dispatch_slice_marker(void) {
  return 0;
}
#endif /* XLANG_BACKEND_CALL_DISPATCH_FROM_X */
