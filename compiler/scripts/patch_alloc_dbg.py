#!/usr/bin/env python3
from pathlib import Path
import sys

def main() -> int:
    p = Path(sys.argv[1] if len(sys.argv) > 1 else "codegen_gen.c")
    t = p.read_text()
    needle = "int32_t call_nargs = is_method ? (call_e).method_call_num_args : (call_e).call_num_args;\n"
    if needle not in t:
        print("needle missing", file=sys.stderr)
        return 1
    insert = needle + (
        "      if (fallback_len == 5 && fallback_name[0]==97 && fallback_name[1]==108 && "
        "fallback_name[2]==108 && fallback_name[3]==111 && fallback_name[4]==99) {\n"
        "        fprintf(stderr, \"ALLOC-DBG nargs=%d search=%p mod_arena=%p entry_arena=%p nfuncs=%d\\n\", "
        "call_nargs, (void*)search_mod, (void*)mod_arena, (void*)arena, "
        "search_mod ? (search_mod)->num_funcs : -1);\n"
        "        if (call_nargs >= 1) {\n"
        "          int32_t ar0 = is_method ? pipeline_expr_method_call_arg_ref(arena, expr_ref, 0) : "
        "pipeline_expr_call_arg_ref(arena, expr_ref, 0);\n"
        "          struct ast_Expr ae0 = ast_arena_expr_get(arena, ar0);\n"
        "          fprintf(stderr, \"ALLOC-DBG arg0 ref=%d kind=%d rty=%d as_tgt=%d\\n\", "
        "ar0, (int)(ae0).kind, (int)pipeline_expr_resolved_type_ref(arena, ar0), "
        "(int)(ae0).as_target_type_ref);\n"
        "        }\n"
        "      }\n"
    )
    t = t.replace(needle, insert, 1)
    needle2 = (
        "      if (found_count == 1 && found_fi >= 0) {\n"
        "        return codegen_emit_func_link_name(out, mod_arena, search_mod, found_fi);\n"
        "      }"
    )
    if needle2 not in t:
        print("needle2 missing", file=sys.stderr)
        return 1
    t = t.replace(
        needle2,
        "      if (fallback_len == 5 && fallback_name[0]==97) "
        "fprintf(stderr, \"ALLOC-DBG found_count=%d found_fi=%d\\n\", found_count, found_fi);\n"
        + needle2,
        1,
    )
    p.write_text(t)
    print("ok")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
