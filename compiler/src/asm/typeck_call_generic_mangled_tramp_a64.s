// Cap tip: call_generic faces → short soft face (10.22 plus_bound).
// PLATFORM: MACOS arm64.
	.globl	_pipeline_typeck_check_call_generic_type_args_c_Module_ptr_ASTArena_ptr_i32_PipelineDepCtx_ptr_i32_reti32
	.p2align	2
_pipeline_typeck_check_call_generic_type_args_c_Module_ptr_ASTArena_ptr_i32_PipelineDepCtx_ptr_i32_reti32:
	b	_pipeline_typeck_check_call_generic_type_args_c

	.globl	_typeck_check_call_generic_type_args
	.p2align	2
_typeck_check_call_generic_type_args:
	b	_pipeline_typeck_check_call_generic_type_args_c
