/* 记253／9.1 + note743y.6.23: tip thin exports short _asm_wpo_collect_walk;
 * Cap tip tramp/demoted and some leftovers want _pipeline_asm_wpo_collect_walk.
 * Alias pipeline → short (not the reverse). PLATFORM: MACOS tip cold Cap tip.
 */
	.globl _pipeline_asm_wpo_collect_walk
_pipeline_asm_wpo_collect_walk = _asm_wpo_collect_walk
