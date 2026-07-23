#!/usr/bin/env python3
"""Patch codegen_gen.c: defining-module owner for multi-dep struct prefix (export+current)."""
from pathlib import Path
import sys

def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "codegen_gen.c")
    text = path.read_text()

    extern_line = (
        "extern int32_t pipeline_module_struct_layout_is_export_at("
        "struct ast_Module * module, int32_t idx);\n"
    )
    if "pipeline_module_struct_layout_is_export_at" not in text:
        anchor = (
            "extern void pipeline_module_struct_layout_field_name_into("
            "struct ast_Module * module, int32_t layout_idx, int32_t field_idx, uint8_t * out64);\n"
        )
        if anchor not in text:
            print("anchor for extern missing", file=sys.stderr)
            return 1
        text = text.replace(anchor, anchor + extern_line, 1)
        print("added extern is_export_at")
    else:
        print("extern already present")

    if "codegen_type_dep_struct_owner_index" not in text:
        old_start = (
            "XLANG_LIB_WEAK int32_t codegen_type_dep_struct_prefix_into("
            "struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, "
            "int32_t type_ref, uint8_t * dst, int32_t dst_cap) {"
        )
        old_end = (
            "XLANG_LIB_WEAK int32_t codegen_type_array_elem_is_u8("
            "struct ast_ASTArena * arena, int32_t type_ref) {"
        )
        i0 = text.find(old_start)
        i1 = text.find(old_end)
        if i0 < 0 or i1 < 0 or i1 <= i0:
            print(f"prefix_into bounds not found {i0} {i1}", file=sys.stderr)
            return 1
        new_block = r'''XLANG_LIB_WEAK int32_t codegen_type_dep_struct_owner_index(struct ast_PipelineDepCtx * ctx, uint8_t * bare_nm, int32_t bare_len) {
  int32_t best_di = -1;
  int32_t best_export = 0;
  int32_t cur = -1;
  int32_t di = 0;
  int32_t nd = 0;
  if (ctx == ((struct ast_PipelineDepCtx *)(0)) || bare_nm == ((uint8_t *)(0)) || bare_len <= 0) {
    return (-1);
  }
  cur = (ctx)->current_codegen_dep_index;
  nd = pipeline_dep_ctx_ndep(ctx);
  while (di < nd) {
    struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, di);
    if (dep_mod != ((struct ast_Module *)(0))) {
      int32_t li = 0;
      int32_t hit = 0;
      int32_t hit_export = 0;
      while (li < (dep_mod)->num_struct_layouts) {
        int32_t dep_name_len = pipeline_module_struct_layout_name_len(dep_mod, li);
        if (dep_name_len == bare_len) {
          uint8_t dep_nm[64] = { 0 };
          int eq = 1;
          int32_t j = 0;
          (void)(pipeline_module_struct_layout_name_into(dep_mod, li, (&((dep_nm)[0]))));
          while (j < bare_len && j < 64) {
            if ((dep_nm)[j] != (bare_nm)[j]) {
              (eq = (0));
              break;
            }
            ++j;
          }
          if (eq) {
            hit = 1;
            if (pipeline_module_struct_layout_is_export_at(dep_mod, li) != 0) {
              hit_export = 1;
            }
            break;
          }
        }
        ++li;
      }
      if (hit != 0) {
        if (best_di < 0) {
          best_di = di;
          best_export = hit_export;
        } else if (hit_export != 0 && best_export == 0) {
          best_di = di;
          best_export = 1;
        } else if (hit_export == best_export && di == cur) {
          best_di = di;
        }
      }
    }
    ++di;
  }
  return best_di;
}
XLANG_LIB_WEAK int32_t codegen_type_dep_struct_prefix_into(struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, int32_t type_ref, uint8_t * dst, int32_t dst_cap) {
  int32_t name_len = 0;
  uint8_t ty_nm[64] = { 0 };
  int32_t owner = -1;
  int32_t bare_off = 0;
  int32_t bare_len = 0;
  int32_t bi_ = 0;
  if (ctx == ((struct ast_PipelineDepCtx *)(0)) || arena == ((struct ast_ASTArena *)(0)) || dst == ((uint8_t *)(0)) || dst_cap <= 0 || ast_ref_is_null(type_ref)) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, type_ref) != ast_TypeKind_TYPE_NAMED) {
    return 0;
  }
  (name_len = (pipeline_type_named_name_into(arena, type_ref, (&((ty_nm)[0])))));
  if (name_len <= 0) {
    return 0;
  }
  bare_off = 0;
  bi_ = 0;
  while (bi_ < name_len && bi_ < 64) {
    if (ty_nm[bi_] == 46) bare_off = bi_ + 1;
    ++bi_;
  }
  bare_len = name_len - bare_off;
  owner = codegen_type_dep_struct_owner_index(ctx, (&((ty_nm)[0])) + bare_off, bare_len);
  if (owner >= 0) {
    uint8_t dep_path[64] = { 0 };
    int32_t plen = codegen_dep_import_path_len_at(ctx, owner, (&((dep_path)[0])));
    if (plen > 0) {
      (void)(codegen_import_path_to_c_prefix_into((&((dep_path)[0])), dst, dst_cap));
      int32_t out_len = 0;
      while (out_len < dst_cap && (dst)[out_len] != ((uint8_t)(0))) {
        ++out_len;
      }
      return out_len;
    }
  }
  return 0;
}
'''
        text = text[:i0] + new_block + text[i1:]
        print("replaced prefix_into + added owner_index")
    else:
        print("owner_index already present")

    # Forward decl for owner_index near other decls
    decl = (
        "int32_t codegen_type_dep_struct_owner_index("
        "struct ast_PipelineDepCtx * ctx, uint8_t * bare_nm, int32_t bare_len);\n"
    )
    if "codegen_type_dep_struct_owner_index(" in text.split("XLANG_LIB_WEAK")[0]:
        pass
    else:
        pdecl = (
            "int32_t codegen_type_dep_struct_prefix_into("
            "struct ast_PipelineDepCtx * ctx, struct ast_ASTArena * arena, "
            "int32_t type_ref, uint8_t * dst, int32_t dst_cap);\n"
        )
        if pdecl in text:
            text = text.replace(pdecl, decl + pdecl, 1)
            print("added owner_index prototype")

    old_defs = (
        "XLANG_LIB_WEAK int32_t codegen_emit_module_struct_definitions("
        "struct ast_Module * module, struct ast_ASTArena * arena, "
        "struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, "
        "int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {\n"
        "  int32_t k = 0;\n"
        "  while (k < (module)->num_struct_layouts) {\n"
        "    int32_t nf = pipeline_module_struct_layout_num_fields(module, k);\n"
        "    int32_t nl = pipeline_module_struct_layout_name_len(module, k);\n"
        "    if (nf <= 0 || nl <= 0) {   ++k;\n"
        "  continue;\n"
        " }\n"
        "    uint8_t ty_nm[64] = { 0 };\n"
        "    (void)(pipeline_module_struct_layout_name_into(module, k, (&((ty_nm)[0]))));\n"
        "    if (codegen_should_skip_emit_struct_layout_for_abi_dup((&((ty_nm)[0])), nl) != 0) {   ++k;\n"
        "  continue;\n"
        " }"
    )
    new_defs = (
        "XLANG_LIB_WEAK int32_t codegen_emit_module_struct_definitions("
        "struct ast_Module * module, struct ast_ASTArena * arena, "
        "struct codegen_CodegenOutBuf * out, uint8_t * struct_prefix, "
        "int32_t struct_prefix_len, struct ast_PipelineDepCtx * ctx) {\n"
        "  int32_t k = 0;\n"
        "  int32_t cur_di = -1;\n"
        "  if (ctx != ((struct ast_PipelineDepCtx *)(0))) {\n"
        "    cur_di = (ctx)->current_codegen_dep_index;\n"
        "  }\n"
        "  while (k < (module)->num_struct_layouts) {\n"
        "    int32_t nf = pipeline_module_struct_layout_num_fields(module, k);\n"
        "    int32_t nl = pipeline_module_struct_layout_name_len(module, k);\n"
        "    if (nf <= 0 || nl <= 0) {   ++k;\n"
        "  continue;\n"
        " }\n"
        "    uint8_t ty_nm[64] = { 0 };\n"
        "    (void)(pipeline_module_struct_layout_name_into(module, k, (&((ty_nm)[0]))));\n"
        "    if (cur_di >= 0 && ctx != ((struct ast_PipelineDepCtx *)(0))) {\n"
        "      int32_t owner = codegen_type_dep_struct_owner_index(ctx, (&((ty_nm)[0])), nl);\n"
        "      if (owner >= 0 && owner != cur_di) {   ++k;\n"
        "  continue;\n"
        " }\n"
        "    }\n"
        "    if (codegen_should_skip_emit_struct_layout_for_abi_dup((&((ty_nm)[0])), nl) != 0) {   ++k;\n"
        "  continue;\n"
        " }"
    )
    if old_defs in text:
        text = text.replace(old_defs, new_defs, 1)
        print("patched emit_module_struct_definitions")
    elif "cur_di = (ctx)->current_codegen_dep_index" in text:
        print("emit_module_struct_definitions already patched")
    else:
        print("WARN: emit_module_struct_definitions pattern not found", file=sys.stderr)

    # forward decls: insert owner skip after name_into
    fwd = "XLANG_LIB_WEAK int32_t codegen_emit_module_struct_forward_declarations("
    fi = text.find(fwd)
    if fi >= 0 and "codegen_type_dep_struct_owner_index(ctx, (&((ty_nm)[0])), nl)" not in text[fi : fi + 2500]:
        # inject after first name_into in forward decls function
        marker = "(void)(pipeline_module_struct_layout_name_into(module, k, (&((ty_nm)[0]))));\n"
        # find within this function only
        fend = text.find("XLANG_LIB_WEAK int32_t codegen_emit_dep_struct_forward_declarations", fi)
        chunk = text[fi:fend]
        if marker in chunk:
            inject = (
                marker
                + "    if (ctx != ((struct ast_PipelineDepCtx *)(0)) && (ctx)->current_codegen_dep_index >= 0) {\n"
                + "      int32_t owner = codegen_type_dep_struct_owner_index(ctx, (&((ty_nm)[0])), nl);\n"
                + "      if (owner >= 0 && owner != (ctx)->current_codegen_dep_index) {   ++k;\n"
                + "  continue;\n"
                + " }\n"
                + "    }\n"
            )
            # But forward decls signature has no ctx! Need to change dep_forward caller instead.
            print("forward decls function has no ctx; patching dep_forward only")
        else:
            print("WARN: name_into marker not in forward decls", file=sys.stderr)

    # Patch dep_struct_forward to set current_codegen_dep_index and skip non-owned
    dep_fwd_start = "XLANG_LIB_WEAK int32_t codegen_emit_dep_struct_forward_declarations(struct ast_PipelineDepCtx * ctx, struct codegen_CodegenOutBuf * out) {"
    di = text.find(dep_fwd_start)
    if di >= 0 and "codegen_type_dep_struct_owner_index" not in text[di : di + 1200]:
        old_call = (
            "  if (codegen_emit_module_struct_forward_declarations("
            "dep_mod, out, (&((prefix_buf)[0])), prefix_len) != 0) {   return (-1);\n"
            " }"
        )
        # Instead of changing forward decls API, inline owner-aware skip by setting dep index
        # and reimplementing a simple filter: call forward then... can't filter easily.
        # Replace the whole loop body call with set index + custom inline skip via temporarily
        # zeroing num_struct_layouts of non-owned — too invasive.
        #
        # Simpler: patch forward declarations function to take optional filter via
        # ctx global: when ctx non-null... but signature has no ctx.
        #
        # Change forward decls to accept ctx as last arg? Would break prototype.
        #
        # Minimal: in dep_forward loop, set current_codegen_dep_index, then call a new
        # weak helper that wraps the old forward with ownership. Easiest path:
        # replace codegen_emit_module_struct_forward_declarations body to read
        # ctx from nowhere — can't.
        #
        # So expand: change prototype of forward_declarations to include ctx.
        print("note: forward decl ownership handled only in definitions for now")
    else:
        print("dep_forward already has owner or not found")

    path.write_text(text)
    print("wrote", path, "bytes", path.stat().st_size)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
