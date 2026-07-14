#!/usr/bin/env python3
from pathlib import Path
import sys

def main() -> int:
    p = Path(sys.argv[1] if len(sys.argv) > 1 else "codegen_gen.c")
    t = p.read_text()
    # After reading func_ix/dep_ix
    needle = (
        "    int32_t func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);\n"
        "    int32_t dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);\n"
    )
    if needle not in t:
        print("needle missing", file=sys.stderr)
        return 1
    if "ALLOC-EARLY" in t:
        print("already has early dbg")
    else:
        t = t.replace(
            needle,
            needle
            + "    if (fallback_len == 5 && fallback_name && fallback_name[0]==97 && "
            "fallback_name[1]==108 && fallback_name[2]==108 && fallback_name[3]==111 && "
            "fallback_name[4]==99) {\n"
            "      struct ast_Expr ce = ast_arena_expr_get(arena, expr_ref);\n"
            "      fprintf(stderr, \"ALLOC-EARLY func_ix=%d dep_ix=%d nargs=%d cur_mod=%p\\n\", "
            "func_ix, dep_ix, (int)(ce).call_num_args, (void*)current_module);\n"
            "    }\n",
            1,
        )
        print("added early dbg")
    p.write_text(t)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
