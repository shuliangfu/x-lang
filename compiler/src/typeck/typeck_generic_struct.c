/**
 * typeck_generic_struct.c — LANG-009/010：泛型 struct 模板单态化（由 typeck.c #include）
 *
 * v1：Option<i32> / Result<i32,i32> 等解析期 mangling；若模块无具名 struct 则从模板物化布局。
 * 支持单参 Option<T> 与双参 Result<T,E>（后缀 _T_E 按最长匹配拆分）。
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/** 将单态类型追加到 buf 后缀（如 _i32、_ptr_u8）。 */
static void typeck_mangle_append_type(const struct ASTType *ty, char *buf, size_t cap) {
    size_t len;
    if (!ty || !buf || cap < 2)
        return;
    len = strlen(buf);
    if (len + 8 >= cap)
        return;
    switch (ty->kind) {
        case AST_TYPE_I32:
            (void)strncat(buf, "_i32", cap - len - 1);
            break;
        case AST_TYPE_U8:
            (void)strncat(buf, "_u8", cap - len - 1);
            break;
        case AST_TYPE_BOOL:
            (void)strncat(buf, "_bool", cap - len - 1);
            break;
        case AST_TYPE_PTR:
            (void)strncat(buf, "_ptr", cap - len - 1);
            len = strlen(buf);
            if (ty->elem_type && ty->elem_type->kind == AST_TYPE_U8 && len + 4 < cap)
                (void)strncat(buf, "_u8", cap - len - 1);
            break;
        default:
            break;
    }
}

#define TYPECK_MAX_GENERIC_ARGS 4

/** 从 mangled 后缀单段解析一个具体类型（_i32 / _u8 / _bool / _ptr_u8）；成功返回新 ASTType。 */
static struct ASTType *typeck_demangle_one_type_token(const char *token) {
    struct ASTType *ty;
    if (!token || !token[0])
        return NULL;
    if (strcmp(token, "_i32") == 0) {
        ty = (struct ASTType *)calloc(1, sizeof(struct ASTType));
        if (ty)
            ty->kind = AST_TYPE_I32;
        return ty;
    }
    if (strcmp(token, "_u8") == 0) {
        ty = (struct ASTType *)calloc(1, sizeof(struct ASTType));
        if (ty)
            ty->kind = AST_TYPE_U8;
        return ty;
    }
    if (strcmp(token, "_bool") == 0) {
        ty = (struct ASTType *)calloc(1, sizeof(struct ASTType));
        if (ty)
            ty->kind = AST_TYPE_BOOL;
        return ty;
    }
    if (strcmp(token, "_ptr_u8") == 0) {
        struct ASTType *inner = (struct ASTType *)calloc(1, sizeof(struct ASTType));
        ty = (struct ASTType *)calloc(1, sizeof(struct ASTType));
        if (!inner || !ty) {
            free(inner);
            free(ty);
            return NULL;
        }
        inner->kind = AST_TYPE_U8;
        ty->kind = AST_TYPE_PTR;
        ty->elem_type = inner;
        return ty;
    }
    return NULL;
}

/**
 * LANG-010：从 mangled 后缀（不含模板名）还原 1..N 个类型实参。
 * 例：_i32 → 1 个；_i32_i32 → 2 个；_u8_i32 → u8 + i32。
 * 成功返回实参个数；失败返回 -1。
 */
static int typeck_demangle_suffix_to_types(const char *suffix, struct ASTType **out, int max_out) {
    int n = 0;
    const char *p;
    size_t adv;
    if (!suffix || suffix[0] != '_' || !out || max_out < 1)
        return -1;
    p = suffix;
    while (*p && n < max_out) {
        struct ASTType *ty = NULL;
        adv = 0;
        if (strncmp(p, "_ptr_u8", 7) == 0) {
            ty = typeck_demangle_one_type_token("_ptr_u8");
            adv = 7;
        } else if (strncmp(p, "_bool", 5) == 0) {
            ty = typeck_demangle_one_type_token("_bool");
            adv = 5;
        } else if (strncmp(p, "_i32", 4) == 0) {
            ty = typeck_demangle_one_type_token("_i32");
            adv = 4;
        } else if (strncmp(p, "_u8", 3) == 0) {
            ty = typeck_demangle_one_type_token("_u8");
            adv = 3;
        } else {
            return -1;
        }
        if (!ty)
            return -1;
        out[n++] = ty;
        p += adv;
    }
    return (*p == '\0') ? n : -1;
}

/** 深拷贝 ASTType（浅层标量；指针/数组递归 elem）。 */
static struct ASTType *typeck_dup_type(const struct ASTType *src) {
    struct ASTType *out;
    if (!src)
        return NULL;
    out = (struct ASTType *)calloc(1, sizeof(struct ASTType));
    if (!out)
        return NULL;
    *out = *src;
    out->name = NULL;
    out->elem_type = NULL;
    out->region_label = NULL;
    if (src->kind == AST_TYPE_NAMED && src->name)
        out->name = strdup(src->name);
    if (src->elem_type)
        out->elem_type = typeck_dup_type(src->elem_type);
    if (src->region_label)
        out->region_label = strdup(src->region_label);
    return out;
}

/** 在泛型 struct 字段类型中，将模板参数名替换为具体类型。 */
static struct ASTType *typeck_subst_field_type(const struct ASTType *fty, char **gp_names, int n_gp,
    struct ASTType **type_args, int n_args) {
    struct ASTType *out;
    int i;
    if (!fty)
        return NULL;
    if (fty->kind == AST_TYPE_NAMED && fty->name && gp_names && type_args) {
        for (i = 0; i < n_gp && i < n_args; i++) {
            if (gp_names[i] && strcmp(fty->name, gp_names[i]) == 0)
                return typeck_dup_type(type_args[i]);
        }
    }
    return typeck_dup_type(fty);
}

/** 从泛型模板物化一个具体 struct 定义（1..N 类型参数）。 */
static struct ASTStructDef *typeck_clone_mono_struct(const struct ASTStructDef *tmpl, const char *mangled,
    struct ASTType **type_args, int n_args) {
    struct ASTStructDef *sd;
    int i;
    if (!tmpl || !mangled || !type_args || n_args < 1 || tmpl->num_generic_params < 1 ||
        n_args != tmpl->num_generic_params)
        return NULL;
    sd = (struct ASTStructDef *)calloc(1, sizeof(struct ASTStructDef));
    if (!sd)
        return NULL;
    sd->name = strdup(mangled);
    sd->num_generic_params = 0;
    sd->generic_param_names = NULL;
    sd->allow_padding = tmpl->allow_padding;
    sd->repr_c = tmpl->repr_c;
    sd->repr_compatible = tmpl->repr_compatible;
    sd->packed = tmpl->packed;
    sd->soa = tmpl->soa;
    sd->num_fields = tmpl->num_fields;
    sd->fields = (ASTStructField *)calloc((size_t)tmpl->num_fields, sizeof(ASTStructField));
    if (!sd->fields || !sd->name) {
        free(sd->name);
        free(sd->fields);
        free(sd);
        return NULL;
    }
    for (i = 0; i < tmpl->num_fields; i++) {
        sd->fields[i].name = tmpl->fields[i].name ? strdup(tmpl->fields[i].name) : NULL;
        sd->fields[i].type = typeck_subst_field_type(tmpl->fields[i].type,
            tmpl->generic_param_names, tmpl->num_generic_params, type_args, n_args);
        sd->field_min_align[i] = tmpl->field_min_align[i];
    }
    return sd;
}

/** 查找已存在的 struct 定义。 */
static struct ASTStructDef *typeck_find_struct_local(struct ASTStructDef **defs, int n, const char *name) {
    int i;
    if (!defs || !name)
        return NULL;
    for (i = 0; i < n; i++) {
        if (defs[i] && defs[i]->name && strcmp(defs[i]->name, name) == 0)
            return defs[i];
    }
    return NULL;
}

/** 创建 i32 类型节点（CORE-016 Result<T,i32> 压缩 demangle 用）。 */
static struct ASTType *typeck_make_i32_type(void) {
    struct ASTType *ty = (struct ASTType *)calloc(1, sizeof(struct ASTType));
    if (ty)
        ty->kind = AST_TYPE_I32;
    return ty;
}

/**
 * CORE-016：Result<T,E=i32> 压缩后缀（_i32/_u8/...）展开为双实参。
 * 成功返回 2；非压缩 Result 后缀返回 0。
 */
static int typeck_expand_result_e_i32_args(struct ASTType **args, int n_args) {
    struct ASTType *e;
    if (!args || n_args != 1 || !args[0])
        return 0;
    e = typeck_make_i32_type();
    if (!e)
        return -1;
    args[1] = e;
    return 2;
}

/** 若 mangled 名可由指定模块内模板物化且尚未定义，则追加到该模块 struct_defs。 */
static int typeck_ensure_mono_struct_in_module(struct ASTModule *m, const char *mangled) {
    struct ASTStructDef *tmpl, *mono, **new_defs;
    size_t tlen;
    struct ASTType *args[TYPECK_MAX_GENERIC_ARGS];
    int n_args, expanded, i, j;
    if (!m || !mangled || !m->struct_defs)
        return 0;
    if (typeck_find_struct_local(m->struct_defs, m->num_structs, mangled))
        return 0;
    for (i = 0; i < m->num_structs; i++) {
        tmpl = m->struct_defs[i];
        if (!tmpl || tmpl->num_generic_params < 1 || !tmpl->name || !tmpl->generic_param_names)
            continue;
        tlen = strlen(tmpl->name);
        if (strncmp(mangled, tmpl->name, tlen) != 0 || mangled[tlen] != '_')
            continue;
        n_args = typeck_demangle_suffix_to_types(mangled + tlen, args, TYPECK_MAX_GENERIC_ARGS);
        if (n_args < 0)
            continue;
        expanded = 0;
        if (n_args != tmpl->num_generic_params && tmpl->num_generic_params == 2 &&
            strcmp(tmpl->name, "Result") == 0) {
            expanded = typeck_expand_result_e_i32_args(args, n_args);
            if (expanded < 0)
                return -1;
            if (expanded > 0)
                n_args = expanded;
        }
        if (n_args != tmpl->num_generic_params)
            continue;
        mono = typeck_clone_mono_struct(tmpl, mangled, args, n_args);
        for (j = 0; j < n_args; j++)
            ast_type_free(args[j]);
        if (!mono)
            return -1;
        new_defs = (struct ASTStructDef **)realloc(m->struct_defs,
            (size_t)(m->num_structs + 1) * sizeof(struct ASTStructDef *));
        if (!new_defs) {
            ast_struct_def_free(mono);
            return -1;
        }
        m->struct_defs = new_defs;
        m->struct_defs[m->num_structs] = mono;
        m->num_structs++;
        return 0;
    }
    return 0;
}

/**
 * 物化 mangled struct：先本模块，再 typeck_dep_mods（LANG-010 import core.result 场景）。
 * 模板定义在依赖模块、使用处在本模块时，在依赖模块内生成单态定义供 find_struct_def_with_deps 查找。
 */
static int typeck_ensure_mono_struct(struct ASTModule *m, const char *mangled) {
    int j;
    if (!mangled)
        return 0;
    if (m && typeck_ensure_mono_struct_in_module(m, mangled) != 0)
        return -1;
    if (m && m->struct_defs && typeck_find_struct_local(m->struct_defs, m->num_structs, mangled))
        return 0;
    if (typeck_dep_mods && typeck_num_deps > 0) {
        for (j = 0; j < typeck_num_deps; j++) {
            struct ASTModule *dm = typeck_dep_mods[j];
            if (!dm)
                continue;
            if (typeck_ensure_mono_struct_in_module(dm, mangled) != 0)
                return -1;
            if (dm->struct_defs && typeck_find_struct_local(dm->struct_defs, dm->num_structs, mangled))
                return 0;
        }
    }
    return 0;
}

/** 收集 let 类型中的 NAMED 并尝试物化。 */
static int typeck_collect_lets(struct ASTModule *m) {
    int i;
    const struct ASTType *ty;
    if (!m || !m->top_level_lets)
        return 0;
    for (i = 0; i < m->num_top_level_lets; i++) {
        ty = m->top_level_lets[i].type;
        if (ty && ty->kind == AST_TYPE_NAMED && ty->name &&
            typeck_ensure_mono_struct(m, ty->name) != 0)
            return -1;
    }
    return 0;
}

/** 递归表达式收集 struct 字面量名。 */
static int typeck_collect_expr_structs(struct ASTModule *m, struct ASTExpr *e) {
    int i;
    if (!e)
        return 0;
    if (e->kind == AST_EXPR_STRUCT_LIT && e->value.struct_lit.struct_name &&
        typeck_ensure_mono_struct(m, e->value.struct_lit.struct_name) != 0)
        return -1;
    if (e->kind >= AST_EXPR_ADD && e->kind <= AST_EXPR_LOGOR) {
        if (typeck_collect_expr_structs(m, e->value.binop.left) != 0)
            return -1;
        if (typeck_collect_expr_structs(m, e->value.binop.right) != 0)
            return -1;
    }
    if (e->kind == AST_EXPR_NEG || e->kind == AST_EXPR_BITNOT || e->kind == AST_EXPR_LOGNOT) {
        if (typeck_collect_expr_structs(m, e->value.unary.operand) != 0)
            return -1;
    }
    if (e->kind == AST_EXPR_IF) {
        if (typeck_collect_expr_structs(m, e->value.if_expr.cond) != 0)
            return -1;
        if (e->value.if_expr.then_expr && typeck_collect_expr_structs(m, e->value.if_expr.then_expr) != 0)
            return -1;
        if (e->value.if_expr.else_expr && typeck_collect_expr_structs(m, e->value.if_expr.else_expr) != 0)
            return -1;
    }
    if (e->kind == AST_EXPR_CALL) {
        for (i = 0; i < e->value.call.num_args; i++)
            if (typeck_collect_expr_structs(m, e->value.call.args[i]) != 0)
                return -1;
    }
    if (e->kind == AST_EXPR_BLOCK && e->value.block) {
        struct ASTBlock *b = e->value.block;
        if (b->final_expr && typeck_collect_expr_structs(m, b->final_expr) != 0)
            return -1;
        for (i = 0; i < b->num_lets; i++)
            if (b->let_decls[i].init && typeck_collect_expr_structs(m, b->let_decls[i].init) != 0)
                return -1;
    }
    return 0;
}

/** 遍历块内 let 与表达式，物化泛型 struct。 */
static int typeck_collect_block(struct ASTModule *m, struct ASTBlock *b) {
    int i;
    if (!b)
        return 0;
    for (i = 0; i < b->num_lets; i++) {
        if (b->let_decls[i].type && b->let_decls[i].type->kind == AST_TYPE_NAMED &&
            b->let_decls[i].type->name &&
            typeck_ensure_mono_struct(m, b->let_decls[i].type->name) != 0)
            return -1;
        if (b->let_decls[i].init && typeck_collect_expr_structs(m, b->let_decls[i].init) != 0)
            return -1;
    }
    if (b->final_expr && typeck_collect_expr_structs(m, b->final_expr) != 0)
        return -1;
    return 0;
}

/** 遍历模块函数体，物化所需的泛型 struct 实例。 */
static int typeck_collect_funcs(struct ASTModule *m) {
    int i, j;
    struct ASTFunc *f;
    if (!m || !m->funcs)
        return 0;
    for (i = 0; i < m->num_funcs; i++) {
        f = m->funcs[i];
        if (!f)
            continue;
        for (j = 0; j < f->num_params; j++) {
            if (f->params[j].type && f->params[j].type->kind == AST_TYPE_NAMED &&
                f->params[j].type->name &&
                typeck_ensure_mono_struct(m, f->params[j].type->name) != 0)
                return -1;
        }
        if (f->return_type && f->return_type->kind == AST_TYPE_NAMED && f->return_type->name &&
            typeck_ensure_mono_struct(m, f->return_type->name) != 0)
            return -1;
        if (f->body && typeck_collect_block(m, f->body) != 0)
            return -1;
    }
    return 0;
}

/** LANG-009：在布局计算前物化所有需要的泛型 struct 实例。 */
static int typeck_materialize_generic_structs(struct ASTModule *m) {
    if (!m)
        return 0;
    if (typeck_collect_lets(m) != 0)
        return -1;
    if (typeck_collect_funcs(m) != 0)
        return -1;
    return 0;
}
