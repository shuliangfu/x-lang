/* note743y.6.23: Cap tip reapply — demoted WPO → tip thin lives.
 * collect_walk short lives in thin; pipeline→short is alias.o.
 * pgo_* pipeline names live in thin. PLATFORM: MACOS|ARM64 Cap tip.
 */
	.globl _asm_wpo_collect_walk__demoted_wpo
	.globl _pipeline_asm_wpo_pgo_emit_order_at__demoted_wpo
	.globl _pipeline_asm_wpo_pgo_emit_order_count__demoted_wpo
	.globl _pipeline_asm_wpo_pgo_emit_order_prepare__demoted_wpo
_asm_wpo_collect_walk__demoted_wpo = _asm_wpo_collect_walk
_pipeline_asm_wpo_pgo_emit_order_at__demoted_wpo = _pipeline_asm_wpo_pgo_emit_order_at
_pipeline_asm_wpo_pgo_emit_order_count__demoted_wpo = _pipeline_asm_wpo_pgo_emit_order_count
_pipeline_asm_wpo_pgo_emit_order_prepare__demoted_wpo = _pipeline_asm_wpo_pgo_emit_order_prepare
