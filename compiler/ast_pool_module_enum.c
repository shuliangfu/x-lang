/**
 * ast_pool_module_enum.c — module ModuleEnumEntry + enum field-access mark (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain:
 * - pipeline_module_enum_* (alloc / set_name / export / append_variant /
 *   variant_tag_for_names / name_len / name_byte / num_variants / variant_name_*)
 * - pipeline_enum_name_from_field_access_base (domain-private static)
 * - pipeline_expr_try_mark_enum_field_access
 * - pipeline_codegen_try_mark_enum_field_access
 *
 * Depends on same-TU statics: module_sidecar_get, grow_vec_*, ModuleEnumEntry /
 * ModuleSidecar / MODULE_ENUM_MAX_VARIANTS (defined earlier in ast_pool.c).
 * Uses pipeline_arena_expr_ptr and later same-TU pipeline_dep_ctx_ndep /
 * pipeline_dep_ctx_module_at (call sites predate their defs; same order as
 * when inlined in ast_pool.c).
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these.
 * Wave: 983 · no semantic change · pin stays 77b334842.
 */

int32_t pipeline_module_enum_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->module_enums);
  if (idx < 0)
    return -1;
  m->num_module_enums = sc->module_enums.len;
  return idx;
}

/**
 * Set module enum type name at idx.
 * wave582 Cap residual: ModuleEnumEntry.name is u8[128]; gate was still len>64
 * → long enum names never registered → typeck check_block fail.
 * Content cap 127. PLATFORM: SHARED
 */
/**
 * Set module enum type name at idx.
 * wave582 Cap residual: ModuleEnumEntry.name is u8[128]; gate was still len>64
 * → long enum names never registered → typeck check_block fail.
 * Content cap 127. PLATFORM: SHARED
 */
void pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ModuleEnumEntry *me;
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  if (!sc || !bytes || len <= 0 || len > 127 || idx < 0 || idx >= sc->module_enums.len)
    return;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me)
    return;
  me->name_len = len;
  me->num_variants = 0;
  me->is_export = 0;
  memset(me->name, 0, sizeof(me->name));
  memcpy(me->name, bytes, (size_t)len);
}

void pipeline_module_enum_set_is_export(struct ast_Module *m, int32_t idx, int32_t v) {
  ModuleEnumEntry *me;
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (me)
    me->is_export = v;
}
int32_t pipeline_module_enum_is_export_at(struct ast_Module *m, int32_t idx) {
  ModuleEnumEntry *me;
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  return me ? me->is_export : 0;
}

/**
 * Append variant name to module enum idx; returns tag 0..n-1 or -1.
 * wave582 Cap residual: variant_name rows are u8[128]; gate was still len>64 and
 * memset only 64 → long variants dropped / truncated → Color.LongName fail.
 * Content cap 127. PLATFORM: SHARED
 */
int32_t pipeline_module_enum_append_variant(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ModuleEnumEntry *me;
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  int32_t slot;
  if (!sc || !bytes || len <= 0 || len > 127 || idx < 0 || idx >= sc->module_enums.len)
    return -1;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me)
    return -1;
  if (me->num_variants >= MODULE_ENUM_MAX_VARIANTS) {
    /** 禁止静默截断：TokenKind 曾 >64 时只表现为 typeck found ?。 */
    fprintf(stderr,
            "xlang: enum '%.*s' exceeds MODULE_ENUM_MAX_VARIANTS=%d (registered=%d, drop variant '%.*s')\n",
            me->name_len > 0 ? me->name_len : 0, me->name_len > 0 ? (const char *)me->name : "?",
            MODULE_ENUM_MAX_VARIANTS, me->num_variants, len, (const char *)bytes);
    return -1;
  }
  slot = me->num_variants;
  me->variant_name_len[slot] = len;
  memset(me->variant_name[slot], 0, 128);
  memcpy(me->variant_name[slot], bytes, (size_t)len);
  me->num_variants = slot + 1;
  return slot;
}

/** 按枚举类型名 + 变体名查 tag；未命中返回 -1。 */
/*
 * wave91: product pure owns pipeline_typeck_set_dep_ctx / get_dep_ctx
 * (runtime_pipeline_abi.x BSS). Historical static g_typeck_dep_ctx dual-auth removed;
 * readers call get_dep_ctx only. Cold twin XLANG_WEAK lives in pipeline_glue.c.
 * PLATFORM: SHARED — hybrid pure strong; cold weak when pure not linked.
 */
extern struct ast_PipelineDepCtx *pipeline_typeck_get_dep_ctx(void);
extern void pipeline_typeck_set_dep_ctx(struct ast_PipelineDepCtx *ctx);

int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name, int32_t enum_len,
                                                   uint8_t *variant_name, int32_t variant_len) {
  ModuleSidecar *sc;
  int32_t ei;
  if (!m || !enum_name || enum_len <= 0 || !variant_name || variant_len <= 0)
    return -1;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return -1;
  for (ei = 0; ei < sc->module_enums.len; ei++) {
    ModuleEnumEntry *me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, ei);
    int32_t vi;
    if (!me || me->name_len != enum_len)
      continue;
    {
      int32_t j = 0;
      int match = 1;
      for (j = 0; j < enum_len; j++) {
        if (me->name[j] != enum_name[j]) {
          match = 0;
          break;
        }
      }
      if (!match)
        continue;
    }
    for (vi = 0; vi < me->num_variants; vi++) {
      if (me->variant_name_len[vi] != variant_len)
        continue;
      {
        int32_t j = 0;
        int match = 1;
        for (j = 0; j < variant_len; j++) {
          if (me->variant_name[vi][j] != variant_name[j]) {
            match = 0;
            break;
          }
        }
        if (match)
          return vi;
      }
    }
    return -1;
  }
  /* Fallback: search dep modules' enums if not found in current module */
  {
    /* wave91 G.7: single authority via get_dep_ctx (pure BSS / glue cold twin). */
    struct ast_PipelineDepCtx *dep_ctx = pipeline_typeck_get_dep_ctx();
    if (dep_ctx) {
    int32_t ndep = pipeline_dep_ctx_ndep(dep_ctx);
    int32_t di;
    for (di = 0; di < ndep; di++) {
      struct ast_Module *dep_mod = pipeline_dep_ctx_module_at(dep_ctx, di);
      if (!dep_mod || dep_mod == m) continue;
      sc = module_sidecar_get(dep_mod, 0);
      if (!sc) continue;
      for (ei = 0; ei < sc->module_enums.len; ei++) {
        ModuleEnumEntry *me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, ei);
        int32_t vi;
        if (!me || me->name_len != enum_len) continue;
        { int32_t j; int match = 1;
          for (j = 0; j < enum_len; j++) {
            if (me->name[j] != enum_name[j]) { match = 0; break; }
          }
          if (!match) continue;
        }
        for (vi = 0; vi < me->num_variants; vi++) {
          if (me->variant_name_len[vi] != variant_len) continue;
          { int32_t j; int match = 1;
            for (j = 0; j < variant_len; j++) {
              if (me->variant_name[vi][j] != variant_name[j]) { match = 0; break; }
            }
            if (match) return vi;
          }
        }
      }
    }
    } /* if (dep_ctx) */
  }
  return -1;
}

/**
 * Extract enum type name for Enum.Variant or import.Enum.Variant field access.
 * PLATFORM: SHARED — typeck + codegen both need qualified import.Enum.Variant
 * (e.g. token.TokenKind.TOKEN_EOF). Bare Enum.Variant is base=VAR; import path is
 * base=FIELD_ACCESS(binding, EnumName). Returns enum name length or 0.
 */
static int32_t pipeline_enum_name_from_field_access_base(struct ast_Expr *base, uint8_t *ename_out) {
  int32_t elen;
  if (!base || !ename_out)
    return 0;
  /* Case 1: EnumName.Variant */
  if (base->kind == ast_ExprKind_EXPR_VAR && base->var_name_len > 0) {
    elen = base->var_name_len;
    if (elen > 127)
      elen = 127;
    memcpy(ename_out, base->var_name, (size_t)elen);
    return elen;
  }
  /* Case 2: import_binding.EnumName.Variant — enum name is the field on the binding. */
  if (base->kind == ast_ExprKind_EXPR_FIELD_ACCESS && base->field_access_field_len > 0) {
    elen = base->field_access_field_len;
    if (elen > 127)
      elen = 127;
    memcpy(ename_out, base->field_access_field_name, (size_t)elen);
    return elen;
  }
  return 0;
}

/** 若 expr 为 TypeName.Variant 或 import.TypeName.Variant，写入 is_enum_variant 与 tag。 */
void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *e;
  struct ast_Expr *base;
  int32_t tag;
  uint8_t ename[128];
  uint8_t vname[128];
  int32_t elen;
  int32_t vlen;
  if (!m || !a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  e = pipeline_arena_expr_ptr(a, expr_ref);
  if (!e || e->kind != ast_ExprKind_EXPR_FIELD_ACCESS || e->field_access_is_enum_variant != 0)
    return;
  base = pipeline_arena_expr_ptr(a, e->field_access_base_ref);
  elen = pipeline_enum_name_from_field_access_base(base, ename);
  if (elen <= 0)
    return;
  vlen = e->field_access_field_len;
  if (vlen <= 0 || vlen > 127)
    return;
  memcpy(vname, e->field_access_field_name, (size_t)vlen);
  tag = pipeline_module_enum_variant_tag_for_names(m, ename, elen, vname, vlen);
  if (tag < 0)
    return;
  e->field_access_is_enum_variant = 1;
  e->enum_variant_tag = tag;
}

/* Codegen-time enum variant marking: search current + dep modules.
 * PLATFORM: SHARED — must mark import.Enum.Variant (token.TokenKind.TOKEN_*) so
 * emit_expr outputs a tag integer instead of illegal C `(token.TokenKind).TOKEN_*`.
 * Lexer -E residual was entry emission fail without this path. */
void pipeline_codegen_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a,
                                                  int32_t expr_ref, struct ast_PipelineDepCtx *dep_ctx) {
  struct ast_Expr *e;
  struct ast_Expr *base;
  int32_t tag;
  uint8_t ename[128];
  uint8_t vname[128];
  int32_t elen;
  int32_t vlen;
  if (!m || !a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  e = pipeline_arena_expr_ptr(a, expr_ref);
  if (!e || e->kind != ast_ExprKind_EXPR_FIELD_ACCESS || e->field_access_is_enum_variant != 0)
    return;
  base = pipeline_arena_expr_ptr(a, e->field_access_base_ref);
  elen = pipeline_enum_name_from_field_access_base(base, ename);
  if (elen <= 0)
    return;
  vlen = e->field_access_field_len;
  if (vlen <= 0 || vlen > 127) return;
  memcpy(vname, e->field_access_field_name, (size_t)vlen);
  tag = pipeline_module_enum_variant_tag_for_names(m, ename, elen, vname, vlen);
  if (tag >= 0) {
    e->field_access_is_enum_variant = 1;
    e->enum_variant_tag = tag;
    return;
  }
  /* Search dep modules (import.Enum lives on the dep sidecar). */
  if (dep_ctx) {
    int32_t ndep = pipeline_dep_ctx_ndep(dep_ctx);
    int32_t di;
    for (di = 0; di < ndep; di++) {
      struct ast_Module *dep_mod = pipeline_dep_ctx_module_at(dep_ctx, di);
      if (!dep_mod || dep_mod == m) continue;
      tag = pipeline_module_enum_variant_tag_for_names(dep_mod, ename, elen, vname, vlen);
      if (tag >= 0) {
        e->field_access_is_enum_variant = 1;
        e->enum_variant_tag = tag;
        return;
      }
    }
  }
}

int32_t pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  return me ? me->name_len : 0;
}

/** wave582: off bound 64→128 (name[128]). PLATFORM: SHARED */
uint8_t pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len || off < 0 || off >= 128)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  return me && off < me->name_len ? me->name[off] : 0;
}

int32_t pipeline_module_enum_num_variants(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  return me ? me->num_variants : 0;
}

int32_t pipeline_module_enum_variant_name_len(struct ast_Module *m, int32_t idx, int32_t variant_idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me || variant_idx < 0 || variant_idx >= me->num_variants)
    return 0;
  return me->variant_name_len[variant_idx];
}

/** wave582: off bound 64→128 (variant_name[][128]). PLATFORM: SHARED */
uint8_t pipeline_module_enum_variant_name_byte_at(struct ast_Module *m, int32_t idx, int32_t variant_idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len || off < 0 || off >= 128)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me || variant_idx < 0 || variant_idx >= me->num_variants || off >= me->variant_name_len[variant_idx])
    return 0;
  return me->variant_name[variant_idx][off];
}
