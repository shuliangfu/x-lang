/* Cap tip: call_spill.o U glue_addr_simd_lane_type_c but Cap tip G05_OBJS
 * omits addr_of_call.o. Prefer existing leaf when present; this weak stub
 * returns 0 (non-SIMD). PLATFORM: MACOS|ARM64. Prefer asm; no host-cc. */
	.globl	_glue_addr_simd_lane_type_c
	.weak_definition _glue_addr_simd_lane_type_c
	.p2align	2
_glue_addr_simd_lane_type_c:
	mov	w0, #0
	ret
