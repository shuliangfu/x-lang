/* s286: tip thin exports short asm_wpo_* helpers; official s249 host-cc
 * reach_compute twin calls pipeline_asm_wpo_*. GNU as on ELF does not
 * emit Darwin-style `=` aliases, so each pipeline_ name is a tail jmp
 * to the short T (same binding as Darwin collect_walk alias).
 * PLATFORM: LINUX.
 */
	.section .note.GNU-stack,"",@progbits
	.text
	.globl pipeline_asm_wpo_set_entry
	.type pipeline_asm_wpo_set_entry, @function
pipeline_asm_wpo_set_entry:
	jmp asm_wpo_set_entry
	.size pipeline_asm_wpo_set_entry, .-pipeline_asm_wpo_set_entry

	.globl pipeline_asm_wpo_set_dep_ctx
	.type pipeline_asm_wpo_set_dep_ctx, @function
pipeline_asm_wpo_set_dep_ctx:
	jmp asm_wpo_set_dep_ctx
	.size pipeline_asm_wpo_set_dep_ctx, .-pipeline_asm_wpo_set_dep_ctx

	.globl pipeline_asm_wpo_register_mod
	.type pipeline_asm_wpo_register_mod, @function
pipeline_asm_wpo_register_mod:
	jmp asm_wpo_register_mod
	.size pipeline_asm_wpo_register_mod, .-pipeline_asm_wpo_register_mod

	.globl pipeline_asm_wpo_register_func
	.type pipeline_asm_wpo_register_func, @function
pipeline_asm_wpo_register_func:
	jmp asm_wpo_register_func
	.size pipeline_asm_wpo_register_func, .-pipeline_asm_wpo_register_func

	.globl pipeline_asm_wpo_mod_slot
	.type pipeline_asm_wpo_mod_slot, @function
pipeline_asm_wpo_mod_slot:
	jmp asm_wpo_mod_slot
	.size pipeline_asm_wpo_mod_slot, .-pipeline_asm_wpo_mod_slot

	.globl pipeline_asm_wpo_func_id_of
	.type pipeline_asm_wpo_func_id_of, @function
pipeline_asm_wpo_func_id_of:
	jmp asm_wpo_func_id_of
	.size pipeline_asm_wpo_func_id_of, .-pipeline_asm_wpo_func_id_of

	.globl pipeline_asm_wpo_is_user_program_entry
	.type pipeline_asm_wpo_is_user_program_entry, @function
pipeline_asm_wpo_is_user_program_entry:
	jmp asm_wpo_is_user_program_entry
	.size pipeline_asm_wpo_is_user_program_entry, .-pipeline_asm_wpo_is_user_program_entry

	.globl pipeline_asm_wpo_is_user_single_file_pgo_entry
	.type pipeline_asm_wpo_is_user_single_file_pgo_entry, @function
pipeline_asm_wpo_is_user_single_file_pgo_entry:
	jmp asm_wpo_is_user_single_file_pgo_entry
	.size pipeline_asm_wpo_is_user_single_file_pgo_entry, .-pipeline_asm_wpo_is_user_single_file_pgo_entry

	.globl pipeline_asm_wpo_user_main_func_id
	.type pipeline_asm_wpo_user_main_func_id, @function
pipeline_asm_wpo_user_main_func_id:
	jmp asm_wpo_user_main_func_id
	.size pipeline_asm_wpo_user_main_func_id, .-pipeline_asm_wpo_user_main_func_id

	.globl pipeline_asm_wpo_build_reach
	.type pipeline_asm_wpo_build_reach, @function
pipeline_asm_wpo_build_reach:
	jmp asm_wpo_build_reach
	.size pipeline_asm_wpo_build_reach, .-pipeline_asm_wpo_build_reach

	.globl pipeline_asm_wpo_close_std_heap_helpers
	.type pipeline_asm_wpo_close_std_heap_helpers, @function
pipeline_asm_wpo_close_std_heap_helpers:
	jmp asm_wpo_close_std_heap_helpers
	.size pipeline_asm_wpo_close_std_heap_helpers, .-pipeline_asm_wpo_close_std_heap_helpers

	.globl pipeline_asm_wpo_reach_fixpoint_expand
	.type pipeline_asm_wpo_reach_fixpoint_expand, @function
pipeline_asm_wpo_reach_fixpoint_expand:
	jmp asm_wpo_reach_fixpoint_expand
	.size pipeline_asm_wpo_reach_fixpoint_expand, .-pipeline_asm_wpo_reach_fixpoint_expand

	.globl pipeline_asm_wpo_mark_pgo_hot
	.type pipeline_asm_wpo_mark_pgo_hot, @function
pipeline_asm_wpo_mark_pgo_hot:
	jmp asm_wpo_mark_pgo_hot
	.size pipeline_asm_wpo_mark_pgo_hot, .-pipeline_asm_wpo_mark_pgo_hot

	.globl pipeline_asm_wpo_mark_pgo_depth
	.type pipeline_asm_wpo_mark_pgo_depth, @function
pipeline_asm_wpo_mark_pgo_depth:
	jmp asm_wpo_mark_pgo_depth
	.size pipeline_asm_wpo_mark_pgo_depth, .-pipeline_asm_wpo_mark_pgo_depth

	.globl pipeline_asm_wpo_dce_env_enabled
	.type pipeline_asm_wpo_dce_env_enabled, @function
pipeline_asm_wpo_dce_env_enabled:
	jmp asm_wpo_dce_env_enabled
	.size pipeline_asm_wpo_dce_env_enabled, .-pipeline_asm_wpo_dce_env_enabled

