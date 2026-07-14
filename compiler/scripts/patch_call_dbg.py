#!/usr/bin/env python3
from pathlib import Path
import sys

def main() -> int:
    p = Path(sys.argv[1] if len(sys.argv) > 1 else "codegen_gen.c")
    t = p.read_text()
    needle = (
        'fprintf(stderr, "DBG-CALL sym=%.*s sym_len=%d imp_j=%d nargs=%d\\n", '
        "sym_len, (char*)sym_buf, sym_len, imp_j, (e).call_num_args);"
    )
    if needle not in t:
        print("needle missing", file=sys.stderr)
        return 1
    if "DBG-CALL2" in t:
        print("already")
        return 0
    add = (
        needle
        + "\n  {\n"
        + "    struct ast_Expr cdbg = ast_arena_expr_get(arena, callee_ref);\n"
        + '    fprintf(stderr, "DBG-CALL2 callee_kind=%d nargs=%d ndep=%d\\n", '
        "(int)(cdbg).kind, (e).call_num_args, (int)pipeline_dep_ctx_ndep(ctx));\n"
        + "    if ((cdbg).kind == ast_ExprKind_EXPR_FIELD_ACCESS) {\n"
        + "      struct ast_Expr bdbg = ast_arena_expr_get(arena, (cdbg).field_access_base_ref);\n"
        + '      fprintf(stderr, "DBG-CALL2 field=%.*s base_kind=%d base=%.*s\\n", '
        "(cdbg).field_access_field_len, (char*)(cdbg).field_access_field_name, "
        "(int)(bdbg).kind, (bdbg).var_name_len, (char*)(bdbg).var_name);\n"
        + "    }\n"
        + "  }\n"
    )
    t = t.replace(needle, add, 1)
    p.write_text(t)
    print("ok")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
