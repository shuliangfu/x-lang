/* note743y.6.23: Cap tip reapply — bak_cap once renamed external U WPO
 * refs to __demoted_wpo. Provide aliases to tip thin lives so pure-ld
 * resolves even if a polluted bak_cap is restored. Dead thin_dead callers
 * never run these at product time. PLATFORM: MACOS|ARM64 Cap tip.
 */
	.globl _asm_wpo_collect_walk__demoted_wpo
	.globl _pipeline_asm_wpo_pgo_emit_order_at__demoted_wpo
	.globl _pipeline_asm_wpo_pgo_emit_order_count__demoted_wpo
	.globl _pipeline_asm_wpo_pgo_emit_order_prepare__demoted_wpo
	.globl _pipeline_asm_wpo_collect_walk
	.globl _pipeline_asm_wpo_pgo_emit_order_at
	.globl _pipeline_asm_wpo_pgo_emit_order_count
	.globl _pipeline_asm_wpo_pgo_emit_order_prepare
_asm_wpo_collect_walk__demoted_wpo = _pipeline_asm_wpo_collect_walk
_pipeline_asm_wpo_pgo_emit_order_at__demoted_wpo = _pipeline_asm_wpo_pgo_emit_order_at
_pipeline_asm_wpo_pgo_emit_order_count__demoted_wpo = _pipeline_asm_wpo_pgo_emit_order_count
_pipeline_asm_wpo_pgo_emit_order_prepare__demoted_wpo = _pipeline_asm_wpo_pgo_emit_order_prepare
