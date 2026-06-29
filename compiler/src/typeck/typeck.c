/**
 * typeck.c — 类型检查实现
 *
 * 文件职责：实现 typeck.h 声明的 typeck_module，对 AST 做类型校验（main 返回 i32；if/while/for 条件须为 bool，禁止整型隐式转 bool；库模块放行）。
 * 所属模块：编译器前端 typeck，compiler/src/typeck/；实现 typeck.h。
 * 与其它文件的关系：依赖 include/ast.h；被 main 在 parse 之后调用；不修改 AST。
 * 重要约定：类型与变量规则以 analysis/变量类型与类型系统设计.md 为准（§4 基础标量、§九 衔接建议）；后续阶段可在此扩展 struct 布局与泛型、trait 等检查。
 */

#include "typeck/typeck.h"
#include "ast.h"
#include "lsp/lsp_diag.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/** DOD-CL -pad-fields warning（runtime.c）。 */
extern void driver_diagnostic_warn_pad_fields_same_cache_line(const uint8_t *sname, int32_t sname_len,
                                                              const uint8_t *f0, int32_t f0_len,
                                                              const uint8_t *f1, int32_t f1_len);
extern void driver_diagnostic_warn_hot_reorder_field(const uint8_t *sname, int32_t sname_len, const uint8_t *hot,
                                                     int32_t hot_len, const uint8_t *cold, int32_t cold_len);

/** 符号表：names[0..n) 为当前作用域内 const/let 名称（const 在前）；type_kinds[i] 为对应类型；type_names[i] 为 NAMED 类型名（结构体名等）。 */
#define MAX_SYMTAB 128

/** BCE 扩展：循环内值域上下文，用于 for (let i=0; i<n; i++) 或 i < s.length 时证明 arr[i]/s[i] 在界内。 */
#define MAX_BCE_RANGES 4
static const char *bce_var_names[MAX_BCE_RANGES];
static int bce_bound_const[MAX_BCE_RANGES];   /* 1 表示上界为常数 bce_bound_val，0 表示上界为 bce_bound_base 的 .length */

/** LANG-007 v2：S0 内 *T 解引用与 extern 调用须在 unsafe { } 内；嵌套 unsafe 块递增。 */
static int typeck_unsafe_depth;
/**
 * 自举兼容：旧 C typeck 仍承担 shux-c 的 `-E` 生成职责，而编译器内部 `.sx` 大量通过 C glue 调 extern。
 * 最终语言语义以 `.sx` typeck 为准，因此这里放宽“extern 调用必须 unsafe”只用于 bootstrap 生成链，
 * 避免 pipeline、lsp、ast 等内部模块在自举前被旧规则卡死。
 */
static int typeck_allow_legacy_extern_calls = 1;
static int bce_bound_val[MAX_BCE_RANGES];
static const struct ASTExpr *bce_bound_base[MAX_BCE_RANGES];
static int bce_n;

/** 当前 typeck 的函数是否为 async function（await 仅允许在其体内）。 */
static int typeck_current_func_is_async;

/** M-4：线性类型 use-once move 跟踪；与 symtab names[i] 平行，仅 AST_TYPE_LINEAR 有意义。 */
static int g_linear_moved[MAX_SYMTAB];

/** M-4：进入新函数体前清零线性 move 状态。 */
static void typeck_linear_reset(void) {
    memset(g_linear_moved, 0, sizeof(g_linear_moved));
}

/** 结构体字面量具名类型缓存：为 (Type){0} 等设置 resolved_type，使 if-expr/嵌套 if 能正确推断 __tmp 类型，从源头消除对 sed 补丁的依赖。 */
#define MAX_STRUCT_LIT_TYPES 32
static struct ASTType struct_lit_type_cache[MAX_STRUCT_LIT_TYPES];
static const char *struct_lit_type_names[MAX_STRUCT_LIT_TYPES];
static int struct_lit_type_n;

/** 字面量默认类型，用于设置 resolved_type 以便函数调用实参匹配 */
static struct ASTType static_type_i32 = { AST_TYPE_I32, NULL, NULL, 0 };
static struct ASTType static_type_i64 = { AST_TYPE_I64, NULL, NULL, 0 };
static struct ASTType static_type_f64 = { AST_TYPE_F64, NULL, NULL, 0 };
static struct ASTType static_type_f32 = { AST_TYPE_F32, NULL, NULL, 0 };
static struct ASTType static_type_bool = { AST_TYPE_BOOL, NULL, NULL, 0 };
/** 切片 .length 字段类型（与 C 侧 size_t 对应） */
static struct ASTType static_type_usize = { AST_TYPE_USIZE, NULL, NULL, 0 };
/** u8/i32/u64 与 *u8/*i32/*u64，用于切片 .data 字段类型（与 C 侧 elem* data 一致） */
static struct ASTType static_type_u8 = { AST_TYPE_U8, NULL, NULL, 0 };
static struct ASTType static_type_u64 = { AST_TYPE_U64, NULL, NULL, 0 };
static struct ASTType static_type_ptr_u8 = { AST_TYPE_PTR, NULL, &static_type_u8, 0 };
static struct ASTType static_type_ptr_i32 = { AST_TYPE_PTR, NULL, &static_type_i32, 0 };
static struct ASTType static_type_ptr_u64 = { AST_TYPE_PTR, NULL, &static_type_u64, 0 };
/** M-5：read_ptr_slice 等零拷贝读 API 的 TLS buf 域标签（与 typeck 自动绑定一致）。 */
static struct ASTType static_type_slice_u8_io_read_ptr = {
    AST_TYPE_SLICE, NULL, &static_type_u8, 0, "io_read_ptr"
};

/** M-5：callee 是否为 read_ptr 系 slice 生产者（typeck 自动绑 io_read_ptr 域）。 */
static int typeck_is_read_ptr_slice_producer(const char *name) {
    if (!name) return 0;
    return strcmp(name, "read_ptr_slice") == 0
        || strcmp(name, "shux_io_read_ptr_slice") == 0
        || strcmp(name, "driver_read_ptr_slice") == 0
        || strcmp(name, "io_read_ptr_slice") == 0;
}

/** 当前 typeck 的依赖模块列表（与 m->import_paths 顺序一致），供 CALL 跨模块解析；由 typeck_module 设置。 */
static struct ASTModule **typeck_dep_mods;
static int typeck_num_deps;
/** 当前 typeck 的主模块（供 find_*_with_deps 解析 import 解构 as 别名）。 */
static const struct ASTModule *typeck_current_mod;

/* LANG-009/010：泛型 struct 单态化物化（typeck_generic_struct.c 以 include 方式链入） */
#include "typeck_generic_struct.c"

/**
 * import 解构第 j 条第 k 个条目的本地绑定名：有 as 别名则用别名，否则与 import_select_names[j][k] 相同。
 */
static const char *import_select_local_name(const struct ASTModule *m, int j, int k) {
    if (!m || j < 0 || j >= m->num_imports || !m->import_select_names || !m->import_select_counts)
        return NULL;
    if (k < 0 || k >= m->import_select_counts[j])
        return NULL;
    if (m->import_select_aliases && m->import_select_aliases[j] && m->import_select_aliases[j][k])
        return m->import_select_aliases[j][k];
    return m->import_select_names[j][k];
}

/**
 * 将解构 import 的本地裸名 local_name 映射到第 j 条 import 在依赖模块中的源符号名；无匹配返回 NULL。
 */
static const char *import_select_source_for_local(const struct ASTModule *m, int j, const char *local_name) {
    if (!m || !local_name || j < 0 || j >= m->num_imports)
        return NULL;
    if (!m->import_kinds || m->import_kinds[j] != AST_IMPORT_KIND_SELECT)
        return NULL;
    if (!m->import_select_names || !m->import_select_counts)
        return NULL;
    for (int k = 0; k < m->import_select_counts[j]; k++) {
        const char *loc = import_select_local_name(m, j, k);
        if (loc && strcmp(loc, local_name) == 0)
            return m->import_select_names[j][k];
    }
    return NULL;
}

/** 判断第 j 个 import 是否导出符号 name：WHOLE 导出全部，BINDING 不导出（仅绑定名为模块引用），SELECT 仅导出列表中的本地名（含 as 别名）。 */
static int import_exports_name(const struct ASTModule *m, int j, const char *name) {
    if (!m || !name || j < 0 || j >= m->num_imports) return 0;
    if (!m->import_kinds) return 1; /* 旧 AST 无 import_kinds，视为整模块 */
    if (m->import_kinds[j] == AST_IMPORT_KIND_WHOLE) return 1;
    if (m->import_kinds[j] == AST_IMPORT_KIND_BINDING) return 0;
    if (m->import_kinds[j] == AST_IMPORT_KIND_SELECT && m->import_select_names && m->import_select_counts) {
        for (int k = 0; k < m->import_select_counts[j]; k++) {
            const char *loc = import_select_local_name(m, j, k);
            if (loc && strcmp(loc, name) == 0) return 1;
        }
    }
    return 0;
}

/** 全面自举：仅填 resolved_type，不做语义检查；.sx 用访问器遍历 AST 并做检查（重写实现）。 */
static int typeck_fill_only;

/** 前向声明：判断表达式是否为赋值或复合赋值（供 typeck 与 typeck_sx 访问器使用）。 */
static int expr_is_assign_or_compound(const struct ASTExpr *e);

/** 前向声明：typeck_block 在文件后部定义，供 AST_EXPR_BLOCK 的 typeck 调用。 */
static int typeck_block(const struct ASTBlock *b, const char **parent_names,
    const int *parent_type_kinds, const char **parent_type_names, const struct ASTType **parent_type_ptrs, int parent_n,
    const int *parent_const_values, int parent_n_consts, int inside_loop,
    struct ASTStructDef **struct_defs, int num_structs, struct ASTEnumDef **enum_defs, int num_enums, const struct ASTModule *m,
    const struct ASTType *func_return_type, const char *scope_region);

/** 前向声明：块是否含隐式 return（联合单态化体检查用）。 */
static int block_has_implicit_return(const struct ASTBlock *b);

/** run v4：seed 支持的标量形参/实参类型（usize 用于 IO handle / fd）。 */
static int typeck_run_seed_scalar_kind(int kind) {
    return kind == AST_TYPE_I32 || kind == AST_TYPE_U32 || kind == AST_TYPE_I64
        || kind == AST_TYPE_USIZE;
}

/** run v3：实参类型须与形参类型一致。 */
static int typeck_run_seed_arg_matches_param(const struct ASTType *arg, const struct ASTType *param) {
    if (!arg || !param)
        return 0;
    return arg->kind == param->kind;
}

/**
 * 按名称查找结构体定义；用于字段访问与结构体字面量校验。
 * 参数：defs 结构体定义数组；num 长度；name 类型名。返回值：找到返回该 ASTStructDef*，否则 NULL。
 */
static const struct ASTStructDef *find_struct_def(struct ASTStructDef **defs, int num, const char *name) {
    if (!defs || !name) return NULL;
    for (int i = 0; i < num; i++)
        if (defs[i] && defs[i]->name && strcmp(defs[i]->name, name) == 0) return defs[i];
    return NULL;
}

/**
 * 先在本模块 defs 中查找结构体，未找到时在 typeck_dep_mods 中查找（跨模块类型解析，如 import std.mem 后使用 Buffer）。
 * 参数：defs/num 当前模块结构体；name 类型名。返回值：找到返回该 ASTStructDef*，否则 NULL。
 */
static const struct ASTStructDef *find_struct_def_with_deps(struct ASTStructDef **defs, int num, const char *name) {
    const struct ASTStructDef *sd = find_struct_def(defs, num, name);
    if (sd) return sd;
    if (!typeck_dep_mods || !name) return NULL;
    for (int j = 0; j < typeck_num_deps; j++) {
        struct ASTModule *dm = typeck_dep_mods[j];
        if (!dm || !dm->struct_defs) continue;
        sd = find_struct_def(dm->struct_defs, dm->num_structs, name);
        if (sd) return sd;
    }
    /* import 解构 as 别名：本地 IoBuf → 依赖模块 Buffer */
    if (typeck_current_mod) {
        for (int j = 0; j < typeck_current_mod->num_imports && j < typeck_num_deps; j++) {
            const char *src = import_select_source_for_local(typeck_current_mod, j, name);
            if (!src) continue;
            struct ASTModule *dm = typeck_dep_mods[j];
            if (!dm || !dm->struct_defs) continue;
            sd = find_struct_def(dm->struct_defs, dm->num_structs, src);
            if (sd) return sd;
        }
    }
    /* 限定名 platform.elf.ElfCodegenCtx：依赖里只存短名 ElfCodegenCtx，用最后一段再查 */
    const char *tail = strrchr(name, '.');
    if (tail && tail[1]) {
        const char *base = tail + 1;
        sd = find_struct_def(defs, num, base);
        if (sd) return sd;
        for (int j = 0; j < typeck_num_deps; j++) {
            struct ASTModule *dm = typeck_dep_mods[j];
            if (!dm || !dm->struct_defs) continue;
            sd = find_struct_def(dm->struct_defs, dm->num_structs, base);
            if (sd) return sd;
        }
    }
    return NULL;
}

/**
 * 在依赖模块顶层 const 中按名查找（仅用于报错提示与 binding.CONST 解析，不做裸名 re-export）。
 */
static const struct ASTLetDecl *find_const_in_dep_module(const struct ASTModule *dm, const char *name) {
    if (!dm || !name || !dm->top_level_lets) return NULL;
    for (int i = 0; i < dm->num_top_level_lets; i++) {
        if (!dm->top_level_lets[i].is_const || !dm->top_level_lets[i].name) continue;
        if (strcmp(dm->top_level_lets[i].name, name) == 0)
            return &dm->top_level_lets[i];
    }
    return NULL;
}

/**
 * 在依赖模块顶层 const 中按名查找（与 find_struct_def_with_deps 对齐，供 import 后裸名 DB_ROW_OK 等）。
 * 参数：name 常量名。返回值：找到返回 ASTLetDecl*，否则 NULL。
 * @deprecated 裸名访问已禁止；仅保留供 import select 别名与 binding 提示。
 */
static const struct ASTLetDecl *find_module_const_in_deps(const char *name) {
    if (!name || !typeck_dep_mods) return NULL;
    for (int j = 0; j < typeck_num_deps; j++) {
        struct ASTModule *dm = typeck_dep_mods[j];
        if (!dm || !dm->top_level_lets) continue;
        for (int i = 0; i < dm->num_top_level_lets; i++) {
            if (!dm->top_level_lets[i].is_const || !dm->top_level_lets[i].name) continue;
            if (strcmp(dm->top_level_lets[i].name, name) == 0)
                return &dm->top_level_lets[i];
        }
    }
    /* import select as 别名：本地 DB_ROW_OK → 依赖模块源名 */
    if (typeck_current_mod) {
        for (int j = 0; j < typeck_current_mod->num_imports && j < typeck_num_deps; j++) {
            const char *src = import_select_source_for_local(typeck_current_mod, j, name);
            if (!src) continue;
            struct ASTModule *dm = typeck_dep_mods[j];
            if (!dm || !dm->top_level_lets) continue;
            for (int i = 0; i < dm->num_top_level_lets; i++) {
                if (!dm->top_level_lets[i].is_const || !dm->top_level_lets[i].name) continue;
                if (strcmp(dm->top_level_lets[i].name, src) == 0)
                    return &dm->top_level_lets[i];
            }
        }
    }
    return NULL;
}

/** 写出含 const 的 import binding 名，供裸名 const 报错提示。 */
static int typeck_const_binding_hint(const char *const_name, char *bind_out, size_t bind_size) {
    if (!const_name || !bind_out || bind_size == 0 || !typeck_dep_mods || !typeck_current_mod) return 0;
    bind_out[0] = '\0';
    for (int j = 0; j < typeck_num_deps && j < typeck_current_mod->num_imports; j++) {
        struct ASTModule *dm = typeck_dep_mods[j];
        if (!find_const_in_dep_module(dm, const_name)) continue;
        if (typeck_current_mod->import_kinds && typeck_current_mod->import_kinds[j] == AST_IMPORT_KIND_BINDING
            && typeck_current_mod->import_binding_names && typeck_current_mod->import_binding_names[j]) {
            snprintf(bind_out, bind_size, "%s", typeck_current_mod->import_binding_names[j]);
            return 1;
        }
        if (typeck_current_mod->import_paths && typeck_current_mod->import_paths[j]) {
            const char *path = typeck_current_mod->import_paths[j];
            const char *dot = strrchr(path, '.');
            snprintf(bind_out, bind_size, "%s", dot ? dot + 1 : path);
            return 1;
        }
    }
    return 0;
}

/** 前向声明：binding.CONST 解析与 module.func 共用 import 槽对齐。 */
static int import_module_ref_matches(const struct ASTModule *m, int j, const char *name);

/** binding.CONST：在依赖模块顶层 const 中解析 field 名；成功设置 resolved_type。 */
static int typeck_field_access_import_const(struct ASTExpr *e, const struct ASTModule *m, const char *path_buf) {
    const char *cname;
    if (!e || !m || !path_buf || !typeck_dep_mods) return 0;
    cname = e->value.field_access.field_name;
    if (!cname) return 0;
    for (int j = 0; j < m->num_imports && j < typeck_num_deps; j++) {
        struct ASTModule *dm;
        const struct ASTLetDecl *lc;
        if (!import_module_ref_matches(m, j, path_buf)) continue;
        dm = typeck_dep_mods[j];
        lc = find_const_in_dep_module(dm, cname);
        if (!lc || !lc->type) continue;
        e->resolved_type = lc->type;
        return 1;
    }
    return 0;
}

static const struct ASTStructDef *find_struct_def_binding_qualified(const struct ASTModule *m, const char *qual_name) {
    const char *dot;
    char binding[128];
    size_t blen;
    const char *struct_short;
    const char *tail;
    const char *sname;
    int j;
    if (!m || !qual_name || !(dot = strchr(qual_name, '.')))
        return NULL;
    blen = (size_t)(dot - qual_name);
    if (blen == 0 || blen >= sizeof(binding))
        return NULL;
    memcpy(binding, qual_name, blen);
    binding[blen] = '\0';
    struct_short = dot + 1;
    if (!struct_short[0])
        return NULL;
    tail = strrchr(struct_short, '.');
    sname = tail ? tail + 1 : struct_short;
    if (!sname[0])
        return NULL;
    for (j = 0; j < typeck_num_deps && j < m->num_imports; j++) {
        struct ASTModule *dm;
        if (!m->import_kinds || m->import_kinds[j] != AST_IMPORT_KIND_BINDING)
            continue;
        if (!m->import_binding_names || !m->import_binding_names[j]
            || strcmp(m->import_binding_names[j], binding) != 0)
            continue;
        dm = typeck_dep_mods[j];
        if (!dm || !dm->struct_defs)
            return NULL;
        return find_struct_def(dm->struct_defs, dm->num_structs, sname);
    }
    return NULL;
}

/**
 * 按名称查找枚举定义；用于枚举值 Name::Variant 校验（§7.4）。
 * 参数：defs 枚举定义数组；num 长度；name 类型名。返回值：找到返回该 ASTEnumDef*，否则 NULL。
 */
static const struct ASTEnumDef *find_enum_def(struct ASTEnumDef **defs, int num, const char *name) {
    if (!defs || !name) return NULL;
    for (int i = 0; i < num; i++)
        if (defs[i] && defs[i]->name && strcmp(defs[i]->name, name) == 0) return defs[i];
    return NULL;
}

/** 先在本模块 defs 中查找枚举，未找到时在 typeck_dep_mods 中查找（跨模块 Type.Variant，如 import token 后 TokenKind.TOKEN_EOF）。 */
static const struct ASTEnumDef *find_enum_def_with_deps(struct ASTEnumDef **defs, int num, const char *name) {
    const struct ASTEnumDef *ed = find_enum_def(defs, num, name);
    if (ed) return ed;
    if (!typeck_dep_mods || !name) return NULL;
    for (int j = 0; j < typeck_num_deps; j++) {
        struct ASTModule *dm = typeck_dep_mods[j];
        if (!dm || !dm->enum_defs) continue;
        ed = find_enum_def(dm->enum_defs, dm->num_enums, name);
        if (ed) return ed;
    }
    /* import 解构 as 别名：本地别名 → 依赖模块源枚举名 */
    if (typeck_current_mod) {
        for (int j = 0; j < typeck_current_mod->num_imports && j < typeck_num_deps; j++) {
            const char *src = import_select_source_for_local(typeck_current_mod, j, name);
            if (!src) continue;
            struct ASTModule *dm = typeck_dep_mods[j];
            if (!dm || !dm->enum_defs) continue;
            ed = find_enum_def(dm->enum_defs, dm->num_enums, src);
            if (ed) return ed;
        }
    }
    return NULL;
}

/**
 * 判断 import 路径是否与标识符 name 匹配（用于 module.func 中的模块名）。
 * path 如 "backend" 或 "codegen.types"；name 如 "backend" 或 "types"。
 * 返回值：1 表示匹配（path 等于 name 或 path 最后一段等于 name），0 表示不匹配。
 */
static int import_path_matches(const char *path, const char *name) {
    if (!path || !name) return 0;
    if (strcmp(path, name) == 0) return 1;
    const char *last = strrchr(path, '.');
    if (last && last[1] && strcmp(last + 1, name) == 0) return 1;
    return 0;
}

/**
 * 判断 name 是否为某 import 路径的前缀（用于 arch.x86_64 中单独出现 arch 时视为合法）。
 * 例如 path="arch.x86_64"、name="arch" 则返回 1，使 arch.x86_64.emit_* 的中间前缀合法。
 */
static int import_path_has_prefix(const char *path, const char *name) {
    if (!path || !name) return 0;
    size_t nlen = strlen(name);
    if (strlen(path) < nlen) return 0;
    if (strncmp(path, name, nlen) != 0) return 0;
    return (path[nlen] == '\0' || path[nlen] == '.');
}

/**
 * 判断模块引用名 name 是否对应第 j 个 import（绑定名、完整路径或路径尾段）。
 * 用于 const mod = import("std.io"); mod.fn() 中 mod 与 dep 槽对齐。
 */
static int import_module_ref_matches(const struct ASTModule *m, int j, const char *name) {
    if (!m || !name || j < 0 || j >= m->num_imports || !m->import_paths || !m->import_paths[j])
        return 0;
    const char *path = m->import_paths[j];
    if (strcmp(path, name) == 0)
        return 1;
    if (m->import_kinds && m->import_kinds[j] == AST_IMPORT_KIND_BINDING
        && m->import_binding_names && m->import_binding_names[j]
        && strcmp(m->import_binding_names[j], name) == 0)
        return 1;
    return import_path_matches(path, name);
}

/** L6-unused-hint：SHUX_UNUSED_HINT=1 时报告未使用绑定/变量（info，不阻断 check）。 */
extern void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, const uint8_t *name, int32_t name_len);

#define TYPECK_MAX_USED_NAMES 256
static const char *typeck_used_names[TYPECK_MAX_USED_NAMES];
static int typeck_used_n;

/** 重置当前函数/模块 usage 集合。 */
static void typeck_used_names_reset(void) {
    typeck_used_n = 0;
}

/** 记录标识符 name 已被使用（去重）。 */
static void typeck_used_names_add(const char *name) {
    int i;
    if (!name || !name[0])
        return;
    for (i = 0; i < typeck_used_n; i++)
        if (typeck_used_names[i] && strcmp(typeck_used_names[i], name) == 0)
            return;
    if (typeck_used_n < TYPECK_MAX_USED_NAMES)
        typeck_used_names[typeck_used_n++] = name;
}

/** 名称是否以 '_' 开头（约定为刻意 unused，跳过 L6）。 */
static int typeck_name_is_underscore(const char *name) {
    return name && name[0] == '_';
}

/** 遍历块内所有表达式语句与 final_expr，供 L6 usage 收集。 */
static void typeck_used_names_walk_block_exprs(const struct ASTBlock *b);

/** 递归遍历表达式，收集 VAR 引用名。 */
static void typeck_used_names_walk_expr(const struct ASTExpr *e) {
    int i;
    if (!e)
        return;
    switch (e->kind) {
    case AST_EXPR_VAR:
        typeck_used_names_add(e->value.var.name);
        return;
    case AST_EXPR_FIELD_ACCESS:
        typeck_used_names_walk_expr(e->value.field_access.base);
        return;
    case AST_EXPR_CALL:
        typeck_used_names_walk_expr(e->value.call.callee);
        for (i = 0; i < e->value.call.num_args; i++)
            typeck_used_names_walk_expr(e->value.call.args[i]);
        return;
    case AST_EXPR_METHOD_CALL:
        typeck_used_names_walk_expr(e->value.method_call.base);
        for (i = 0; i < e->value.method_call.num_args; i++)
            typeck_used_names_walk_expr(e->value.method_call.args[i]);
        return;
    case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV:
    case AST_EXPR_MOD: case AST_EXPR_SHL: case AST_EXPR_SHR:
    case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
    case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE:
    case AST_EXPR_GT: case AST_EXPR_GE: case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
        typeck_used_names_walk_expr(e->value.binop.left);
        typeck_used_names_walk_expr(e->value.binop.right);
        return;
    case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT:
        typeck_used_names_walk_expr(e->value.unary.operand);
        return;
    case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        typeck_used_names_walk_expr(e->value.unary.operand);
        return;
    case AST_EXPR_AS:
        typeck_used_names_walk_expr(e->value.as_type.operand);
        return;
    case AST_EXPR_INDEX:
        typeck_used_names_walk_expr(e->value.index.base);
        typeck_used_names_walk_expr(e->value.index.index_expr);
        return;
    case AST_EXPR_ARRAY_LIT:
        for (i = 0; i < e->value.array_lit.num_elems; i++)
            typeck_used_names_walk_expr(e->value.array_lit.elems[i]);
        return;
    case AST_EXPR_STRUCT_LIT:
        for (i = 0; i < e->value.struct_lit.num_fields; i++)
            typeck_used_names_walk_expr(e->value.struct_lit.inits[i]);
        return;
    case AST_EXPR_IF:
        typeck_used_names_walk_expr(e->value.if_expr.cond);
        typeck_used_names_walk_expr(e->value.if_expr.then_expr);
        typeck_used_names_walk_expr(e->value.if_expr.else_expr);
        return;
    case AST_EXPR_TERNARY:
        typeck_used_names_walk_expr(e->value.if_expr.cond);
        typeck_used_names_walk_expr(e->value.if_expr.then_expr);
        typeck_used_names_walk_expr(e->value.if_expr.else_expr);
        return;
    case AST_EXPR_MATCH:
        typeck_used_names_walk_expr(e->value.match_expr.matched_expr);
        for (i = 0; i < e->value.match_expr.num_arms; i++)
            typeck_used_names_walk_expr(e->value.match_expr.arms[i].result);
        return;
    case AST_EXPR_ASSIGN:
    case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN:
    case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
    case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN:
    case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
        typeck_used_names_walk_expr(e->value.binop.left);
        typeck_used_names_walk_expr(e->value.binop.right);
        return;
    case AST_EXPR_BLOCK:
        if (e->value.block)
            typeck_used_names_walk_block_exprs(e->value.block);
        return;
    default:
        return;
    }
}

/** 遍历块内所有表达式语句与 final_expr，供 L6 usage 收集。 */
static void typeck_used_names_walk_block_exprs(const struct ASTBlock *b) {
    int i;
    if (!b)
        return;
    for (i = 0; i < b->num_expr_stmts; i++)
        typeck_used_names_walk_expr(b->expr_stmts[i]);
    for (i = 0; i < b->num_labeled_stmts; i++) {
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            typeck_used_names_walk_expr(b->labeled_stmts[i].u.return_expr);
    }
    for (i = 0; i < b->num_loops; i++) {
        typeck_used_names_walk_expr(b->loops[i].cond);
        typeck_used_names_walk_block_exprs(b->loops[i].body);
    }
    for (i = 0; i < b->num_for_loops; i++) {
        typeck_used_names_walk_expr(b->for_loops[i].init);
        typeck_used_names_walk_expr(b->for_loops[i].cond);
        typeck_used_names_walk_expr(b->for_loops[i].step);
        typeck_used_names_walk_block_exprs(b->for_loops[i].body);
    }
    for (i = 0; i < b->num_defers; i++)
        typeck_used_names_walk_block_exprs(b->defer_blocks[i]);
    for (i = 0; i < b->num_regions; i++)
        typeck_used_names_walk_block_exprs(b->regions[i].body);
    if (b->final_expr)
        typeck_used_names_walk_expr(b->final_expr);
}

/** 判断 name 是否在 usage 集合中。 */
static int typeck_used_names_has(const char *name) {
    int i;
    for (i = 0; i < typeck_used_n; i++)
        if (typeck_used_names[i] && name && strcmp(typeck_used_names[i], name) == 0)
            return 1;
    return 0;
}

/** 递归检查块内 let/const 是否未使用；line/col 取自 init 表达式位置。 */
static void typeck_unused_hints_block_lets(const struct ASTBlock *b) {
    int i;
    if (!b)
        return;
    for (i = 0; i < b->num_lets; i++) {
        const char *nm = b->let_decls[i].name;
        int ln = (b->let_decls[i].init && b->let_decls[i].init->line > 0) ? b->let_decls[i].init->line : 1;
        int cl = (b->let_decls[i].init && b->let_decls[i].init->col > 0) ? b->let_decls[i].init->col : 1;
        if (nm && !typeck_name_is_underscore(nm) && !typeck_used_names_has(nm))
            driver_diagnostic_hint_unused_binding(ln, cl, (const uint8_t *)nm, (int32_t)strlen(nm));
    }
    for (i = 0; i < b->num_consts; i++) {
        const char *nm = b->const_decls[i].name;
        int ln = (b->const_decls[i].init && b->const_decls[i].init->line > 0) ? b->const_decls[i].init->line : 1;
        int cl = (b->const_decls[i].init && b->const_decls[i].init->col > 0) ? b->const_decls[i].init->col : 1;
        if (nm && !typeck_name_is_underscore(nm) && !typeck_used_names_has(nm))
            driver_diagnostic_hint_unused_binding(ln, cl, (const uint8_t *)nm, (int32_t)strlen(nm));
    }
    for (i = 0; i < b->num_loops; i++)
        typeck_unused_hints_block_lets(b->loops[i].body);
    for (i = 0; i < b->num_for_loops; i++)
        typeck_unused_hints_block_lets(b->for_loops[i].body);
    for (i = 0; i < b->num_defers; i++)
        typeck_unused_hints_block_lets(b->defer_blocks[i]);
    for (i = 0; i < b->num_regions; i++)
        typeck_unused_hints_block_lets(b->regions[i].body);
}

/** 对单函数体做 L6 未使用 let/const 检查。 */
static void typeck_unused_hints_func(const struct ASTFunc *f) {
    if (!f || !f->body)
        return;
    typeck_used_names_reset();
    typeck_used_names_walk_block_exprs(f->body);
    typeck_unused_hints_block_lets(f->body);
}

/** 模块级：未使用的 import 绑定/解构符号与顶层 let/const（SHUX_UNUSED_HINT=1）。 */
static void typeck_unused_hints_module(const struct ASTModule *m) {
    const char *uh;
    int i, j, k, fi;
    if (!m)
        return;
    uh = getenv("SHUX_UNUSED_HINT");
    if (!uh || uh[0] != '1' || uh[1] != '\0')
        return;

    typeck_used_names_reset();
    for (fi = 0; fi < m->num_funcs; fi++)
        if (m->funcs[fi] && m->funcs[fi]->body)
            typeck_used_names_walk_block_exprs(m->funcs[fi]->body);
    for (i = 0; i < m->num_impl_blocks && m->impl_blocks; i++)
        for (j = 0; j < m->impl_blocks[i]->num_funcs; j++)
            if (m->impl_blocks[i]->funcs[j] && m->impl_blocks[i]->funcs[j]->body)
                typeck_used_names_walk_block_exprs(m->impl_blocks[i]->funcs[j]->body);

    for (i = 0; i < m->num_imports; i++) {
        if (m->import_kinds && m->import_kinds[i] == AST_IMPORT_KIND_BINDING
            && m->import_binding_names && m->import_binding_names[i]) {
            const char *bn = m->import_binding_names[i];
            if (!typeck_name_is_underscore(bn) && !typeck_used_names_has(bn))
                driver_diagnostic_hint_unused_binding(1, 1, (const uint8_t *)bn, (int32_t)strlen(bn));
        }
        if (m->import_kinds && m->import_kinds[i] == AST_IMPORT_KIND_SELECT
            && m->import_select_names && m->import_select_counts) {
            for (k = 0; k < m->import_select_counts[i]; k++) {
                const char *sn = import_select_local_name(m, i, k);
                if (sn && !typeck_name_is_underscore(sn) && !typeck_used_names_has(sn))
                    driver_diagnostic_hint_unused_binding(1, 1, (const uint8_t *)sn, (int32_t)strlen(sn));
            }
        }
    }
    for (i = 0; m->top_level_lets && i < m->num_top_level_lets; i++) {
        const char *nm = m->top_level_lets[i].name;
        int ln = (m->top_level_lets[i].init && m->top_level_lets[i].init->line > 0) ? m->top_level_lets[i].init->line : 1;
        int cl = (m->top_level_lets[i].init && m->top_level_lets[i].init->col > 0) ? m->top_level_lets[i].init->col : 1;
        if (nm && !typeck_name_is_underscore(nm) && !typeck_used_names_has(nm))
            driver_diagnostic_hint_unused_binding(ln, cl, (const uint8_t *)nm, (int32_t)strlen(nm));
    }

    for (fi = 0; fi < m->num_funcs; fi++)
        typeck_unused_hints_func(m->funcs[fi]);
    for (i = 0; i < m->num_impl_blocks && m->impl_blocks; i++)
        for (j = 0; j < m->impl_blocks[i]->num_funcs; j++)
            typeck_unused_hints_func(m->impl_blocks[i]->funcs[j]);
}

/**
 * 从“模块引用”表达式（VAR 或嵌套 FIELD_ACCESS 如 arch.x86_64）拼出完整 import 路径到 buf，返回长度，失败返回 -1。
 * 用于 CALL(arch.x86_64.emit_*, ...) 时从 callee->base 得到 "arch.x86_64" 以在 typeck_dep_mods 中查找。
 */
static int expr_to_import_path(const struct ASTExpr *e, char *buf, size_t buf_size) {
    if (!e || !buf || buf_size == 0) return -1;
    if (e->kind == AST_EXPR_VAR && e->value.var.name) {
        size_t len = strlen(e->value.var.name);
        if (len >= buf_size) return -1;
        memcpy(buf, e->value.var.name, len + 1);
        return (int)len;
    }
    if (e->kind == AST_EXPR_FIELD_ACCESS && e->value.field_access.base && e->value.field_access.field_name) {
        int base_len = expr_to_import_path(e->value.field_access.base, buf, buf_size);
        if (base_len < 0) return -1;
        size_t need = (size_t)base_len + 1 + strlen(e->value.field_access.field_name);
        if (need >= buf_size) return -1;
        buf[base_len] = '.';
        strcpy(buf + base_len + 1, e->value.field_access.field_name);
        return (int)need;
    }
    return -1;
}

/** 按名称查找 trait 定义；用于 impl 校验（阶段 7.2）。 */
static const struct ASTTraitDef *find_trait_def(struct ASTTraitDef **defs, int num, const char *name) {
    if (!defs || !name) return NULL;
    for (int i = 0; i < num; i++)
        if (defs[i] && defs[i]->name && strcmp(defs[i]->name, name) == 0) return defs[i];
    return NULL;
}

/**
 * 判断两个类型是否相等（用于函数调用实参与形参匹配）；NAMED 比较 name，PTR/ARRAY/SLICE/VECTOR 递归 elem_type。
 */
static int type_equal(const struct ASTType *a, const struct ASTType *b) {
    if (!a || !b) return (a == b);
    if (a->kind != b->kind) return 0;
    if (a->kind == AST_TYPE_NAMED) {
        if (!a->name && !b->name) return 1;
        if (a->name && b->name && strcmp(a->name, b->name) == 0) return 1;
        /* 跨模块限定名与短名视为同类型：ElfCodegenCtx 与 platform.elf.ElfCodegenCtx */
        if (a->name && b->name) {
            const char *tail_a = strrchr(a->name, '.');
            const char *tail_b = strrchr(b->name, '.');
            const char *base_a = tail_a ? tail_a + 1 : a->name;
            const char *base_b = tail_b ? tail_b + 1 : b->name;
            if (strcmp(base_a, base_b) == 0) return 1;
        }
        return 0;
    }
    if (a->kind == AST_TYPE_SLICE) {
        if (!type_equal(a->elem_type, b->elem_type))
            return 0;
        /* M-3：同元素类型但域标签不同（[]i32<ra> vs []i32<rb>）视为不等。 */
        if (a->region_label && b->region_label)
            return strcmp(a->region_label, b->region_label) == 0;
        return 1;
    }
    if (a->kind == AST_TYPE_PTR || a->kind == AST_TYPE_LINEAR || a->kind == AST_TYPE_VECTOR)
        return type_equal(a->elem_type, b->elem_type);
    if (a->kind == AST_TYPE_ARRAY)
        return a->array_size == b->array_size && type_equal(a->elem_type, b->elem_type);
    if (a->kind == AST_TYPE_UNION && b->kind == AST_TYPE_UNION) {
        if (a->union_count != b->union_count) return 0;
        for (int i = 0; i < a->union_count; i++)
            if (!type_equal(a->union_members[i], b->union_members[i])) return 0;
        return 1;
    }
    if (a->kind == AST_TYPE_UNION || b->kind == AST_TYPE_UNION)
        return 0;
    return 1;
}

/**
 * let 初值：较小整数类型向较宽整数类型隐式拓宽（如 u8→u32、i32→i64）。
 */
static int typeck_integer_widen_ok(enum ASTTypeKind dest, enum ASTTypeKind src) {
    /* 同 kind 仅整数类型可隐式拓宽；slice 等同 kind 但域标签不同须保留 init 类型供 M-3 检查。 */
    if (dest == src) {
        return dest == AST_TYPE_I32 || dest == AST_TYPE_I64 || dest == AST_TYPE_U8
            || dest == AST_TYPE_U32 || dest == AST_TYPE_U64 || dest == AST_TYPE_USIZE;
    }
    if (src == AST_TYPE_U8)
        return dest == AST_TYPE_U32 || dest == AST_TYPE_U64 || dest == AST_TYPE_USIZE || dest == AST_TYPE_I32;
    if (src == AST_TYPE_I32)
        return dest == AST_TYPE_I64 || dest == AST_TYPE_U32 || dest == AST_TYPE_USIZE || dest == AST_TYPE_U64;
    if (src == AST_TYPE_U32 && dest == AST_TYPE_U64)
        return 1;
    return 0;
}

/**
 * 实参是否可赋给形参（含联合成员匹配与既有隐式转换规则）。
 * arg_expr 可为 NULL（跳过仅依赖字面量的规则）。
 */
static int type_assignable_to(const struct ASTType *actual, const struct ASTType *formal,
    const struct ASTExpr *arg_expr) {
    if (!formal) return actual == NULL;
    /* 取址实参：ADDR_OF 无 resolved_type，须按 operand 与 formal 元素类型匹配（含 &buf[i]）。 */
    if (formal->kind == AST_TYPE_PTR && formal->elem_type && arg_expr && arg_expr->kind == AST_EXPR_ADDR_OF) {
        const struct ASTExpr *operand = arg_expr->value.unary.operand;
        if (operand && operand->resolved_type) {
            if (type_equal(formal->elem_type, operand->resolved_type)) return 1;
            if (operand->resolved_type->kind == AST_TYPE_ARRAY && operand->resolved_type->elem_type
                && type_equal(formal->elem_type, operand->resolved_type->elem_type))
                return 1;
        }
        return 0;
    }
    /** resolved_type 未填时仍可按表达式形态匹配（overload 实参 typecheck 在 CALL 分派前常无类型）。 */
    if (!actual && arg_expr) {
        if (formal->kind == AST_TYPE_SLICE && formal->elem_type && formal->elem_type->kind == AST_TYPE_U8
            && arg_expr->kind == AST_EXPR_ARRAY_LIT)
            return 1;
        if (formal->kind == AST_TYPE_VECTOR && arg_expr->kind == AST_EXPR_ARRAY_LIT
            && arg_expr->value.array_lit.num_elems == formal->array_size)
            return 1;
        if (formal->kind == AST_TYPE_ARRAY && arg_expr->kind == AST_EXPR_ARRAY_LIT
            && arg_expr->value.array_lit.num_elems == formal->array_size)
            return 1;
        if (formal->kind == AST_TYPE_U32 && arg_expr->kind == AST_EXPR_LIT && arg_expr->value.int_val >= 0)
            return 1;
        if (formal->kind == AST_TYPE_I32 && arg_expr->kind == AST_EXPR_LIT)
            return 1;
        if (formal->kind == AST_TYPE_USIZE && arg_expr->kind == AST_EXPR_LIT && arg_expr->value.int_val >= 0)
            return 1;
        if (formal->kind == AST_TYPE_I64 && arg_expr->kind == AST_EXPR_LIT)
            return 1;
        if (formal->kind == AST_TYPE_U8 && arg_expr->kind == AST_EXPR_LIT) {
            int v = arg_expr->value.int_val;
            if (v >= 0 && v <= 255) return 1;
        }
        /* 字面量 0 作 null 指针实参（*u8 与 usize 交替时避免裸 0 被解析为 i32）。 */
        if (formal->kind == AST_TYPE_PTR && arg_expr->kind == AST_EXPR_LIT && arg_expr->value.int_val == 0)
            return 1;
        return 0;
    }
    if (!actual) return 0;
    if (formal->kind == AST_TYPE_UNION) {
        for (int i = 0; i < formal->union_count; i++)
            if (type_assignable_to(actual, formal->union_members[i], arg_expr)) return 1;
        return 0;
    }
    if (type_equal(actual, formal)) return 1;
    if (formal->kind == AST_TYPE_U32 && arg_expr && arg_expr->kind == AST_EXPR_LIT
        && arg_expr->value.int_val >= 0)
        return 1;
    if (formal->kind == AST_TYPE_USIZE && arg_expr && arg_expr->kind == AST_EXPR_LIT
        && arg_expr->value.int_val >= 0)
        return 1;
    if (formal->kind == AST_TYPE_I64 && arg_expr && arg_expr->kind == AST_EXPR_LIT)
        return 1;
    /* i32 可赋给 isize/usize/u32（常见长度/计数/权限位实参）。 */
    if (actual->kind == AST_TYPE_I32) {
        if (formal->kind == AST_TYPE_ISIZE || formal->kind == AST_TYPE_USIZE || formal->kind == AST_TYPE_U32)
            return 1;
    }
    if (formal->kind == AST_TYPE_U8 && arg_expr && arg_expr->kind == AST_EXPR_LIT) {
        int v = arg_expr->value.int_val;
        if (v >= 0 && v <= 255) return 1;
    }
    /* 字面量 0 → null 指针实参（与 ASSIGN 中 ptr=0 一致）。 */
    if (formal->kind == AST_TYPE_PTR && arg_expr && arg_expr->kind == AST_EXPR_LIT && arg_expr->value.int_val == 0)
        return 1;
    if (formal->kind == AST_TYPE_F32 && actual->kind == AST_TYPE_F64
        && arg_expr && arg_expr->kind == AST_EXPR_FLOAT_LIT)
        return 1;
    if (formal->kind == AST_TYPE_SLICE && formal->elem_type && formal->elem_type->kind == AST_TYPE_U8
        && arg_expr && arg_expr->kind == AST_EXPR_ARRAY_LIT)
        return 1;
    if (formal->kind == AST_TYPE_VECTOR && arg_expr && arg_expr->kind == AST_EXPR_ARRAY_LIT
        && arg_expr->value.array_lit.num_elems == formal->array_size)
        return 1;
    if (formal->kind == AST_TYPE_ARRAY && arg_expr && arg_expr->kind == AST_EXPR_ARRAY_LIT
        && arg_expr->value.array_lit.num_elems == formal->array_size)
        return 1;
    /* M-3：slice 元素类型一致但域标签不同时仍匹配 overload；域错误在 CALL 分派后单独报错。 */
    if (formal->kind == AST_TYPE_SLICE && actual->kind == AST_TYPE_SLICE
        && formal->elem_type && actual->elem_type
        && type_equal(formal->elem_type, actual->elem_type))
        return 1;
    if (formal->kind == AST_TYPE_PTR && actual->kind == AST_TYPE_ARRAY
        && formal->elem_type && actual->elem_type && type_equal(formal->elem_type, actual->elem_type))
        return 1;
    if (formal->kind == AST_TYPE_PTR && formal->elem_type && formal->elem_type->kind == AST_TYPE_U8
        && actual->kind == AST_TYPE_PTR)
        return 1;
    if (typeck_integer_widen_ok(formal->kind, actual->kind))
        return 1;
    return 0;
}

/** let 注解为联合时 symtab 存初值具体类型，否则存声明类型。 */
static const struct ASTType *typeck_let_symtab_type(const struct ASTType *decl, const struct ASTExpr *init) {
    if (decl && decl->kind == AST_TYPE_UNION && init && init->resolved_type)
        return init->resolved_type;
    if (decl) return decl;
    if (init && init->resolved_type) return init->resolved_type;
    return NULL;
}

/** let 初值是否与声明类型兼容（含联合成员匹配）。 */
/**
 * 结构体字面量的 resolved_type 名：import as 别名时保留用户写的本地名（IoBuf），否则用定义名（Buffer）。
 */
static const char *struct_lit_resolved_type_name(const struct ASTStructDef *sd, const char *lit_struct_name) {
    if (lit_struct_name && sd && sd->name && strcmp(lit_struct_name, sd->name) != 0)
        return lit_struct_name;
    if (sd && sd->name)
        return sd->name;
    return lit_struct_name;
}

static int typeck_let_init_matches(const struct ASTType *decl, const struct ASTExpr *init) {
    if (!decl || !init || !init->resolved_type) return 1;
    if (decl->kind == AST_TYPE_UNION)
        return type_assignable_to(init->resolved_type, decl, init);
    if (type_equal(decl, init->resolved_type)) return 1;
    /* import 解构 as：声明 IoBuf、初值 Buffer（或反之）时视为同一结构体 */
    if (typeck_current_mod && decl->kind == AST_TYPE_NAMED && init->resolved_type->kind == AST_TYPE_NAMED
        && decl->name && init->resolved_type->name && strcmp(decl->name, init->resolved_type->name) != 0) {
        for (int j = 0; j < typeck_current_mod->num_imports; j++) {
            const char *src = import_select_source_for_local(typeck_current_mod, j, decl->name);
            if (src && strcmp(src, init->resolved_type->name) == 0) return 1;
            src = import_select_source_for_local(typeck_current_mod, j, init->resolved_type->name);
            if (src && strcmp(src, decl->name) == 0) return 1;
        }
    }
    if (decl->kind == AST_TYPE_F32 && init->resolved_type->kind == AST_TYPE_F64) return 1;
    return 0;
}

/**
 * let 初值：整数字面量按声明类型收窄/零初始化（与 typeck.sx 一致）。
 */
static int typeck_coerce_let_int_lit(const struct ASTType *decl, struct ASTExpr *init) {
    int iv;
    enum ASTTypeKind dk;
    if (!decl || !init || init->kind != AST_EXPR_LIT)
        return 0;
    iv = init->value.int_val;
    dk = decl->kind;
    if (iv == 0 && (dk == AST_TYPE_PTR || dk == AST_TYPE_ARRAY || dk == AST_TYPE_VECTOR || dk == AST_TYPE_NAMED)) {
        init->resolved_type = (struct ASTType *)decl;
        return 1;
    }
    if (dk == AST_TYPE_U8 && iv >= 0 && iv <= 255) {
        init->resolved_type = (struct ASTType *)decl;
        return 1;
    }
    if (dk == AST_TYPE_I32) {
        init->resolved_type = (struct ASTType *)decl;
        return 1;
    }
    if (dk == AST_TYPE_NAMED && decl->name) {
        if (strcmp(decl->name, "i16") == 0 && iv >= -32768 && iv <= 32767) {
            init->resolved_type = (struct ASTType *)decl;
            return 1;
        }
        if (strcmp(decl->name, "u16") == 0 && iv >= 0 && iv <= 65535) {
            init->resolved_type = (struct ASTType *)decl;
            return 1;
        }
    }
    if (dk == AST_TYPE_I64 || dk == AST_TYPE_ISIZE) {
        init->resolved_type = (struct ASTType *)decl;
        return 1;
    }
    if (iv >= 0 && (dk == AST_TYPE_U32 || dk == AST_TYPE_U64 || dk == AST_TYPE_USIZE)) {
        init->resolved_type = (struct ASTType *)decl;
        return 1;
    }
    if (iv == 0 && (dk == AST_TYPE_U8 || dk == AST_TYPE_U32 || dk == AST_TYPE_U64 || dk == AST_TYPE_USIZE ||
                    dk == AST_TYPE_I64 || dk == AST_TYPE_ISIZE)) {
        init->resolved_type = (struct ASTType *)decl;
        return 1;
    }
    return 0;
}

/**
 * 顶层 let 初值：与块内 let 相同的整型 0 收窄与数组字面量按声明类型归一（u64、*T[N]、[]= 零初始化）。
 * 参数：decl 声明类型；init 初值表达式（可写 resolved_type）。
 */
static void typeck_coerce_top_level_let_init(const struct ASTType *decl, struct ASTExpr *init) {
    if (!decl || !init)
        return;
    (void)typeck_coerce_let_int_lit(decl, init);
    if (init->resolved_type && decl->kind != AST_TYPE_UNION
        && typeck_integer_widen_ok(decl->kind, init->resolved_type->kind))
        init->resolved_type = (struct ASTType *)decl;
    if (init->kind == AST_EXPR_ARRAY_LIT && decl->kind == AST_TYPE_ARRAY) {
        int nel = init->value.array_lit.num_elems;
        if (nel == 0 || nel == decl->array_size)
            init->resolved_type = (struct ASTType *)decl;
    }
}

/**
 * 判断实参类型 arg_type 是否与形参类型 param_type 在代入泛型实参后一致。
 * 用于泛型调用 f<Type>(args) 的实参与形参匹配；gp_names/type_args 为泛型参数名与类型实参。
 * 若 param_type 为泛型参数名（NAMED 且 name 在 gp_names 中），则与对应 type_args[i] 比较；
 * PTR/ARRAY/SLICE/VECTOR 递归 elem_type；否则退化为 type_equal。
 */
static int type_equal_subst(const struct ASTType *param_type, const struct ASTType *arg_type,
    char **gp_names, struct ASTType **type_args, int num_gp) {
    if (!param_type || !arg_type) return (param_type == arg_type);
    if (param_type->kind == AST_TYPE_NAMED && gp_names && type_args && num_gp > 0) {
        for (int i = 0; i < num_gp; i++)
            if (param_type->name && gp_names[i] && strcmp(param_type->name, gp_names[i]) == 0)
                return type_equal(arg_type, type_args[i]);
    }
    if (param_type->kind != arg_type->kind) return 0;
    if (param_type->kind == AST_TYPE_PTR || param_type->kind == AST_TYPE_SLICE || param_type->kind == AST_TYPE_LINEAR || param_type->kind == AST_TYPE_VECTOR)
        return type_equal_subst(param_type->elem_type, arg_type->elem_type, gp_names, type_args, num_gp);
    if (param_type->kind == AST_TYPE_ARRAY)
        return param_type->array_size == arg_type->array_size
            && type_equal_subst(param_type->elem_type, arg_type->elem_type, gp_names, type_args, num_gp);
    return type_equal(param_type, arg_type);
}

/**
 * M-3 原型：切片域标签冲突检测。expect/src 均为 SLICE 且均带 region_label 时须一致。
 * 返回 1 表示冲突（应报错），0 表示可接受。
 */
static int typeck_slice_region_conflict(const struct ASTType *expect, const struct ASTType *src) {
    if (!expect || !src || expect->kind != AST_TYPE_SLICE || src->kind != AST_TYPE_SLICE)
        return 0;
    if (!expect->region_label || !src->region_label)
        return 0;
    return strcmp(expect->region_label, src->region_label) != 0;
}

/**
 * M-3：域绑定 slice 逃逸到未标注域（外层 let / 返回值等）。
 * 返回 1 表示逃逸（应报错），0 表示可接受。
 */
static int typeck_slice_region_escape(const struct ASTType *expect, const struct ASTType *src) {
    if (!expect || !src || expect->kind != AST_TYPE_SLICE || src->kind != AST_TYPE_SLICE)
        return 0;
    return (src->region_label && !expect->region_label) ? 1 : 0;
}

/**
 * M-3：为未标注域的 []T 类型打上当前 region 块标签（scope_region）。
 */
static void typeck_stamp_slice_region(struct ASTType *ty, const char *scope_region) {
    if (!ty || ty->kind != AST_TYPE_SLICE || !scope_region || !scope_region[0] || ty->region_label)
        return;
    ty->region_label = strdup(scope_region);
}

/**
 * 返回泛型函数 return_type 在代入 type_args 后的类型指针（仅支持顶层 NAMED 泛型参数，如 -> T）。
 * 用于设置泛型调用表达式的 resolved_type；不分配新节点，返回的为 type_args[i] 或 return_type 自身。
 */
static const struct ASTType *get_substituted_return_type(const struct ASTType *return_type,
    char **gp_names, struct ASTType **type_args, int num_gp) {
    if (!return_type || !gp_names || !type_args || num_gp <= 0) return return_type;
    if (return_type->kind == AST_TYPE_NAMED && return_type->name) {
        for (int i = 0; i < num_gp; i++)
            if (gp_names[i] && strcmp(return_type->name, gp_names[i]) == 0)
                return type_args[i];
    }
    return return_type;
}

/** 将类型转为用于 impl 查找的名字串（i32/bool/NAMED 等）；用于方法调用解析（阶段 7.2）。 */
static const char *type_to_name_string(const struct ASTType *ty) {
    if (!ty) return "";
    if (ty->kind == AST_TYPE_NAMED && ty->name) return ty->name;
    switch (ty->kind) {
        case AST_TYPE_I32:   return "i32";
        case AST_TYPE_BOOL:  return "bool";
        case AST_TYPE_U8:    return "u8";
        case AST_TYPE_U32:   return "u32";
        case AST_TYPE_U64:   return "u64";
        case AST_TYPE_I64:   return "i64";
        case AST_TYPE_USIZE: return "usize";
        case AST_TYPE_ISIZE: return "isize";
        case AST_TYPE_F32:   return "f32";
        case AST_TYPE_F64:   return "f64";
        default: break;
    }
    return "";
}

/**
 * 将类型格式化为可读字符串，用于面包屑错误（Expected/Found）；写入 buf，最多 size 字节。
 * 支持标量、NAMED、*T、[]T、[N]T。
 */
static void type_to_string_buf(const struct ASTType *ty, char *buf, size_t size) {
    if (!ty || !buf || size == 0) { if (buf && size) buf[0] = '\0'; return; }
    const char *base = type_to_name_string(ty);
    if (ty->kind == AST_TYPE_PTR && ty->elem_type) {
        char inner[64];
        type_to_string_buf(ty->elem_type, inner, sizeof(inner));
        (void)snprintf(buf, size, "*%s", inner[0] ? inner : "?");
        return;
    }
    if (ty->kind == AST_TYPE_SLICE && ty->elem_type) {
        char inner[64];
        type_to_string_buf(ty->elem_type, inner, sizeof(inner));
        if (ty->region_label && ty->region_label[0])
            (void)snprintf(buf, size, "[]%s<%s>", inner[0] ? inner : "?", ty->region_label);
        else
            (void)snprintf(buf, size, "[]%s", inner[0] ? inner : "?");
        return;
    }
    if (ty->kind == AST_TYPE_ARRAY && ty->elem_type && ty->array_size > 0) {
        char inner[64];
        type_to_string_buf(ty->elem_type, inner, sizeof(inner));
        (void)snprintf(buf, size, "[%d]%s", ty->array_size, inner[0] ? inner : "?");
        return;
    }
    if (ty->kind == AST_TYPE_LINEAR && ty->elem_type) {
        char inner[64];
        type_to_string_buf(ty->elem_type, inner, sizeof(inner));
        (void)snprintf(buf, size, "Linear(%s)", inner[0] ? inner : "?");
        return;
    }
    if (ty->kind == AST_TYPE_UNION && ty->union_members && ty->union_count > 0) {
        size_t off = 0;
        for (int i = 0; i < ty->union_count && off + 1 < size; i++) {
            char part[48];
            type_to_string_buf(ty->union_members[i], part, sizeof(part));
            if (i > 0)
                off += (size_t)snprintf(buf + off, size - off, " | ");
            off += (size_t)snprintf(buf + off, size - off, "%s", part[0] ? part : "?");
        }
        return;
    }
    if (base && base[0])
        (void)snprintf(buf, size, "%s", base);
    else
        (void)snprintf(buf, size, "?");
}

/** 若表达式节点有源码位置则输出 " at line:col"，然后换行；非 LSP 模式下由 lsp_diag_report_typeck 替代。 */
static void typeck_err_loc(const struct ASTExpr *e) {
    if (lsp_diag_enabled) return;
    if (e && (e->line > 0 || e->col > 0))
        fprintf(stderr, " at %d:%d", e->line, e->col);
    fprintf(stderr, "\n");
}
#define TYPECK_ERR(e, fmt, ...) do { lsp_diag_report_typeck((e)->line, (e)->col, fmt, ##__VA_ARGS__); } while(0)
#define TYPECK_ERR_AT(line, col, fmt, ...) do { lsp_diag_report_typeck(line, col, fmt, ##__VA_ARGS__); } while(0)

/** M-4：VAR 读取线性值时检查并标记 moved；返回 -1 并已报错。 */
static int typeck_linear_use_var(const struct ASTExpr *e, int sym_index,
    const struct ASTType **type_ptrs) {
    if (!e || sym_index < 0 || sym_index >= MAX_SYMTAB || !type_ptrs || !type_ptrs[sym_index])
        return 0;
    if (type_ptrs[sym_index]->kind != AST_TYPE_LINEAR)
        return 0;
    if (g_linear_moved[sym_index]) {
        TYPECK_ERR(e, "linear value used after move");
        return -1;
    }
    g_linear_moved[sym_index] = 1;
    return 0;
}

/** M-4：Linear(T) 是否接受内层标量/指针字面量初始化。 */
static int typeck_linear_accepts_inner(const struct ASTType *linear, const struct ASTType *inner) {
    if (!linear || linear->kind != AST_TYPE_LINEAR || !linear->elem_type || !inner)
        return 0;
    return type_equal(linear->elem_type, inner);
}

/**
 * M-3：统一检查 slice 域 assign/let；返回 -1 并已打印 typeck error。
 */
static int typeck_check_slice_region_assign(const struct ASTExpr *site,
    const struct ASTType *expect, const struct ASTType *src) {
    if (!site || !expect || !src || expect->kind != AST_TYPE_SLICE || src->kind != AST_TYPE_SLICE)
        return 0;
    if (typeck_slice_region_escape(expect, src)) {
        TYPECK_ERR(site, "slice region escape: cannot assign <%s> slice to unbound []T",
            src->region_label);
        return -1;
    }
    if (typeck_slice_region_conflict(expect, src)) {
        TYPECK_ERR(site, "slice region mismatch: expected <%s>, found <%s>",
            expect->region_label, src->region_label);
        return -1;
    }
    return 0;
}

/**
 * M-3：return 路径 slice 域逃逸 / 不一致检查。
 */
static int typeck_check_return_slice_region(const struct ASTExpr *ret_site,
    const struct ASTExpr *op, const struct ASTType *func_return_type) {
    const struct ASTType *got;
    if (!ret_site || !op || !func_return_type || func_return_type->kind != AST_TYPE_SLICE)
        return 0;
    got = op->resolved_type;
    if (!got || got->kind != AST_TYPE_SLICE)
        return 0;
    if (typeck_slice_region_escape(func_return_type, got)) {
        TYPECK_ERR(ret_site, "slice region escape: cannot return <%s> slice as unbound []T",
            got->region_label);
        return -1;
    }
    if (typeck_slice_region_conflict(func_return_type, got)) {
        TYPECK_ERR(ret_site, "slice region mismatch in return: expected <%s>, found <%s>",
            func_return_type->region_label, got->region_label);
        return -1;
    }
    return 0;
}

/**
 * 在枚举定义中按变体名查找 0-based 序号；用于 match 枚举分支（§7.4）。
 * 参数：ed 枚举定义；variant_name 变体名。返回值：序号（>=0）或 -1 表示未找到。
 */
static int enum_variant_index(const struct ASTEnumDef *ed, const char *variant_name) {
    if (!ed || !variant_name) return -1;
    for (int i = 0; i < ed->num_variants; i++)
        if (ed->variant_names[i] && strcmp(ed->variant_names[i], variant_name) == 0) return i;
    return -1;
}

/**
 * 返回类型的对齐要求（字节）；用于结构体布局算法（变量类型与类型系统设计 §11.1）。
 * 参数：ty 字段类型；struct_defs/num_structs 已计算过布局的结构体；enum_defs/num_enums 枚举（NAMED 时可能为枚举）。返回值：对齐字节数，无法确定时返回 1。
 */
static int type_align_of(const struct ASTType *ty, struct ASTStructDef **struct_defs, int num_structs,
    struct ASTEnumDef **enum_defs, int num_enums) {
    if (!ty) return 1;
    switch (ty->kind) {
        case AST_TYPE_I32: case AST_TYPE_U32: case AST_TYPE_BOOL: return 4;
        case AST_TYPE_F32: return 4;
        case AST_TYPE_F64: return 8;
        case AST_TYPE_U8: return 1;
        case AST_TYPE_I64: case AST_TYPE_U64: case AST_TYPE_USIZE: case AST_TYPE_ISIZE: return 8;
        case AST_TYPE_PTR: return 8;
        case AST_TYPE_SLICE: return 8;  /* 对齐与指针一致 */
        case AST_TYPE_ARRAY:
            return ty->elem_type ? type_align_of(ty->elem_type, struct_defs, num_structs, enum_defs, num_enums) : 1;
        case AST_TYPE_VECTOR:
            return ty->elem_type ? type_align_of(ty->elem_type, struct_defs, num_structs, enum_defs, num_enums) : 1;
        case AST_TYPE_NAMED: {
            const struct ASTStructDef *sd = find_struct_def_with_deps(struct_defs, num_structs, ty->name);
            if (sd && sd->struct_align > 0) return sd->struct_align;
            if (find_enum_def(enum_defs, num_enums, ty->name)) return 4;  /* 枚举按 int 对齐 */
            /* 自举：NAMED "i32" 等按内建类型给对齐 */
            if (ty->name && (strcmp(ty->name, "i32") == 0 || strcmp(ty->name, "u32") == 0 || strcmp(ty->name, "bool") == 0)) return 4;
            if (ty->name && strcmp(ty->name, "u8") == 0) return 1;
            if (ty->name && (strcmp(ty->name, "i16") == 0 || strcmp(ty->name, "u16") == 0)) return 2; /* CORE-013 */
            if (ty->name && (strcmp(ty->name, "i64") == 0 || strcmp(ty->name, "u64") == 0 || strcmp(ty->name, "f64") == 0)) return 8;
            if (ty->name && strcmp(ty->name, "f32") == 0) return 4;
            return 1;
        }
        default: return 1;
    }
}

/**
 * 返回类型的大小（字节）；用于结构体布局算法 §11.1。
 * 参数：同上。返回值：大小字节数，无法确定时返回 0。
 */
static int type_size_of(const struct ASTType *ty, struct ASTStructDef **struct_defs, int num_structs,
    struct ASTEnumDef **enum_defs, int num_enums) {
    if (!ty) return 0;
    switch (ty->kind) {
        case AST_TYPE_I32: case AST_TYPE_U32: case AST_TYPE_BOOL: return 4;
        case AST_TYPE_F32: return 4;
        case AST_TYPE_F64: return 8;
        case AST_TYPE_U8: return 1;
        case AST_TYPE_I64: case AST_TYPE_U64: case AST_TYPE_USIZE: case AST_TYPE_ISIZE: return 8;
        case AST_TYPE_PTR: return 8;
        case AST_TYPE_SLICE: return 16;  /* C 侧为 { ptr, len }，两字 */
        case AST_TYPE_ARRAY: {
            int esz = ty->elem_type ? type_size_of(ty->elem_type, struct_defs, num_structs, enum_defs, num_enums) : 0;
            return (ty->array_size > 0 && esz > 0) ? (ty->array_size * esz) : 0;
        }
        case AST_TYPE_VECTOR: {
            int esz = ty->elem_type ? type_size_of(ty->elem_type, struct_defs, num_structs, enum_defs, num_enums) : 0;
            return (ty->array_size > 0 && esz > 0) ? (ty->array_size * esz) : 0;
        }
        case AST_TYPE_NAMED: {
            const struct ASTStructDef *sd = find_struct_def_with_deps(struct_defs, num_structs, ty->name);
            if (sd && sd->struct_size > 0) return sd->struct_size;
            if (find_enum_def(enum_defs, num_enums, ty->name)) return 4;  /* 枚举按 int */
            /* 自举：.sx 中 [N]i32 等会解析为 NAMED "i32"，按内建类型给大小 */
            if (ty->name && strcmp(ty->name, "i32") == 0) return 4;
            if (ty->name && strcmp(ty->name, "u32") == 0) return 4;
            if (ty->name && strcmp(ty->name, "bool") == 0) return 4;
            if (ty->name && strcmp(ty->name, "u8") == 0) return 1;
            if (ty->name && (strcmp(ty->name, "i16") == 0 || strcmp(ty->name, "u16") == 0)) return 2; /* CORE-013 */
            if (ty->name && strcmp(ty->name, "i64") == 0) return 8;
            if (ty->name && strcmp(ty->name, "u64") == 0) return 8;
            if (ty->name && strcmp(ty->name, "f64") == 0) return 8;
            if (ty->name && strcmp(ty->name, "f32") == 0) return 4;
            return 0;
        }
        default: return 0;
    }
}

/**
 * 对模块内所有结构体计算布局（字段偏移、总大小、对齐）；按定义顺序计算，NAMED 字段须引用已计算过的结构体（变量类型与类型系统设计 §11.1）。
 * 参数：struct_defs/num_structs 顶层结构体；enum_defs/num_enums 枚举（用于 NAMED 字段为枚举时）。返回值：0 成功，-1 失败并已写 stderr。
 */
static int compute_struct_layouts(struct ASTStructDef **struct_defs, int num_structs,
    struct ASTEnumDef **enum_defs, int num_enums) {
    if (!struct_defs || num_structs <= 0) return 0;
    for (int idx = 0; idx < num_structs; idx++) {
        struct ASTStructDef *sd = struct_defs[idx];
        if (!sd || !sd->fields || sd->num_fields <= 0) continue;
        /* LANG-009：泛型 struct 模板不参与布局，由单态化实例承担。 */
        if (sd->num_generic_params > 0) continue;
        int current_offset = 0;
        int max_align = 1;
        if (sd->packed) {
            /* packed：无填充，字段紧密排列，结构体对齐为 1（内存契约） */
            for (int i = 0; i < sd->num_fields && i < AST_STRUCT_MAX_FIELDS; i++) {
                const struct ASTType *fty = sd->fields[i].type;
                if (!fty) { sd->field_offsets[i] = current_offset; continue; }
                sd->field_offsets[i] = current_offset;
                int fsize = type_size_of(fty, struct_defs, num_structs, enum_defs, num_enums);
                if (fsize <= 0) {
                    TYPECK_ERR_AT(0, 0, "struct '%s' field '%s' has unknown or invalid type size",
                        sd->name ? sd->name : "?", sd->fields[i].name ? sd->fields[i].name : "?");
                    return -1;
                }
                current_offset += fsize;
            }
            sd->struct_size = current_offset;
            sd->struct_align = 1;
            continue;
        }
        for (int i = 0; i < sd->num_fields && i < AST_STRUCT_MAX_FIELDS; i++) {
            const struct ASTType *fty = sd->fields[i].type;
            if (!fty) { sd->field_offsets[i] = current_offset; continue; }
            int A = type_align_of(fty, struct_defs, num_structs, enum_defs, num_enums);
            if (A <= 0) A = 1;
            if (sd->field_min_align[i] > A) A = sd->field_min_align[i];
            int gap = (A - (current_offset % A)) % A;
            /* Zero-Padding 强制校验（§11.1）：存在隐式 padding 且未标记 allow(padding) 则报错 */
            if (gap > 0 && !sd->allow_padding && !sd->repr_c) {
                TYPECK_ERR_AT(0, 0, "struct '%s' has %d byte(s) implicit padding before field '%s'; add explicit padding field or allow(padding)",
                    sd->name ? sd->name : "?", gap, sd->fields[i].name ? sd->fields[i].name : "?");
                return -1;
            }
            current_offset += gap;
            sd->field_offsets[i] = current_offset;
            int fsize = type_size_of(fty, struct_defs, num_structs, enum_defs, num_enums);
            if (fsize <= 0) {
                TYPECK_ERR_AT(0, 0, "struct '%s' field '%s' has unknown or invalid type size",
                        sd->name ? sd->name : "?", sd->fields[i].name ? sd->fields[i].name : "?");
                return -1;
            }
            current_offset += fsize;
            if (A > max_align) max_align = A;
        }
        /* 末尾对齐；若存在末尾空隙且未标记 allow(padding) 则报错（§11.1 Zero-Padding） */
        if (max_align > 0 && (current_offset % max_align) != 0) {
            int end_pad = max_align - (current_offset % max_align);
            if (end_pad > 0 && !sd->allow_padding && !sd->repr_c) {
                TYPECK_ERR_AT(0, 0, "struct '%s' has %d byte(s) implicit trailing padding; add explicit padding field or allow(padding)",
                    sd->name ? sd->name : "?", end_pad);
                return -1;
            }
            current_offset += end_pad;
        }
        sd->struct_size = current_offset;
        sd->struct_align = max_align;
    }
    /** DOD-CL：SHUX_PAD_FIELDS=1 时 -pad-fields 伪共享 warning（C/shux-c 路径）。 */
    {
        const char *pf = getenv("SHUX_PAD_FIELDS");
        if (pf && pf[0] == '1' && pf[1] == '\0') {
            for (int idx = 0; idx < num_structs; idx++) {
                struct ASTStructDef *sd = struct_defs[idx];
                int j;
                if (!sd || sd->num_fields < 2)
                    continue;
                for (j = 0; j + 1 < sd->num_fields; j++) {
                    const struct ASTType *t0 = sd->fields[j].type;
                    const struct ASTType *t1 = sd->fields[j + 1].type;
                    int off0 = sd->field_offsets[j];
                    int off1 = sd->field_offsets[j + 1];
                    int sz0 = t0 ? type_size_of(t0, struct_defs, num_structs, enum_defs, num_enums) : 0;
                    int sz1 = t1 ? type_size_of(t1, struct_defs, num_structs, enum_defs, num_enums) : 0;
                    if (sd->field_min_align[j] >= 64 || sd->field_min_align[j + 1] >= 64)
                        continue;
                    if (off0 / 64 != off1 / 64)
                        continue;
                    if ((sz0 != 4 && sz0 != 8) && (sz1 != 4 && sz1 != 8))
                        continue;
                    driver_diagnostic_warn_pad_fields_same_cache_line(
                        (const uint8_t *)(sd->name ? sd->name : "?"),
                        sd->name ? (int32_t)strlen(sd->name) : 1,
                        (const uint8_t *)(sd->fields[j].name ? sd->fields[j].name : "?"),
                        sd->fields[j].name ? (int32_t)strlen(sd->fields[j].name) : 1,
                        (const uint8_t *)(sd->fields[j + 1].name ? sd->fields[j + 1].name : "?"),
                        sd->fields[j + 1].name ? (int32_t)strlen(sd->fields[j + 1].name) : 1);
                }
            }
        }
    }
    /** DOD-CL-S2：SHUX_HOT_REORDER=1 时热字段重排 hint（C/shux-c 路径）。 */
    {
        const char *hr = getenv("SHUX_HOT_REORDER");
        if (hr && hr[0] == '1' && hr[1] == '\0') {
            for (int idx = 0; idx < num_structs; idx++) {
                struct ASTStructDef *sd = struct_defs[idx];
                int j, i;
                if (!sd || sd->num_fields < 2)
                    continue;
                for (j = 1; j < sd->num_fields; j++) {
                    const struct ASTType *ty = sd->fields[j].type;
                    int sz = ty ? type_size_of(ty, struct_defs, num_structs, enum_defs, num_enums) : 0;
                    if (sz <= 0 || sz > 4)
                        continue;
                    for (i = 0; i < j; i++) {
                        const struct ASTType *ty_c = sd->fields[i].type;
                        int sz_c = ty_c ? type_size_of(ty_c, struct_defs, num_structs, enum_defs, num_enums) : 0;
                        if (sz_c >= 8) {
                            driver_diagnostic_warn_hot_reorder_field(
                                (const uint8_t *)(sd->name ? sd->name : "?"),
                                sd->name ? (int32_t)strlen(sd->name) : 1,
                                (const uint8_t *)(sd->fields[j].name ? sd->fields[j].name : "?"),
                                sd->fields[j].name ? (int32_t)strlen(sd->fields[j].name) : 1,
                                (const uint8_t *)(sd->fields[i].name ? sd->fields[i].name : "?"),
                                sd->fields[i].name ? (int32_t)strlen(sd->fields[i].name) : 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

/**
 * 判断表达式是否产生 bool 类型（用于 if/while 条件；禁止整型隐式转 bool）。
 * 参数：e 表达式；names 符号表；type_kinds 各符号类型（与 names 平行）；n 数量。
 * 返回值：1 表示产生 bool，0 表示否（如整型字面量或整型变量）。
 */
static int expr_produces_bool(const struct ASTExpr *e, const char **names,
    const int *type_kinds, int n) {
    if (!e) return 0;
    switch (e->kind) {
        case AST_EXPR_BOOL_LIT:
            return 1;
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE:
        case AST_EXPR_GT: case AST_EXPR_GE:
            return 1;  /* 比较运算产生 bool */
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            return expr_produces_bool(e->value.binop.left, names, type_kinds, n)
                && expr_produces_bool(e->value.binop.right, names, type_kinds, n);
        case AST_EXPR_LOGNOT:
            return expr_produces_bool(e->value.unary.operand, names, type_kinds, n);
        case AST_EXPR_VAR: {
            const char *name = e->value.var.name;
            for (int i = 0; i < n; i++) {
                if (names[i] && name && strcmp(names[i], name) == 0 && type_kinds && i < n)
                    return (type_kinds[i] == AST_TYPE_BOOL);
            }
            return 0;  /* 未定义或非 bool 变量 */
        }
        default:
            /* 已 typeck 的表达式：若 resolved_type 为 bool 则视为产生 bool（如返回 bool 的函数调用、字段访问等） */
            return (e->resolved_type && e->resolved_type->kind == AST_TYPE_BOOL);
    }
}

/**
 * 判断表达式是否为常量表达式（仅字面量、或引用已定义 const 的 VAR、或二者的运算）。
 * 参数：e 表达式；names 已定义 const 名列表；n 数量。返回值：1 是常量表达式，0 否。
 */
static int is_const_expr(const struct ASTExpr *e, const char **names, int n) {
    if (!e) return 0;
    switch (e->kind) {
        case AST_EXPR_LIT:
        case AST_EXPR_FLOAT_LIT:
        case AST_EXPR_BOOL_LIT:
            return 1;
        case AST_EXPR_VAR: {
            const char *name = e->value.var.name;
            for (int i = 0; i < n; i++)
                if (names[i] && name && strcmp(names[i], name) == 0) return 1;
            return 0;
        }
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV:
        case AST_EXPR_MOD: case AST_EXPR_SHL: case AST_EXPR_SHR:
        case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE:
        case AST_EXPR_GT: case AST_EXPR_GE: case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            return is_const_expr(e->value.binop.left, names, n) && is_const_expr(e->value.binop.right, names, n);
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT:
            return is_const_expr(e->value.unary.operand, names, n);
        case AST_EXPR_ADDR_OF:
            return 0;  /* 取址非常量表达式 */
        case AST_EXPR_DEREF:
            return 0;  /* 解引用非常量表达式 */
        case AST_EXPR_AS:
            return 0;  /* 类型转换非常量（或可扩展为递归 is_const_expr(operand)） */
        case AST_EXPR_ARRAY_LIT: {
            /* CTFE 扩展：数组字面量为常量表达式（各元素须为常量），求值时返回元素个数（数组长度） */
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                if (!is_const_expr(e->value.array_lit.elems[i], names, n)) return 0;
            return 1;
        }
        case AST_EXPR_IF:
        case AST_EXPR_TERNARY:
        case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            return 0;  /* if/三元/赋值 表达式非常量 */
        default:
            return 0;
    }
}

/**
 * CTFE 最小集：对常量表达式求值，返回整型结果（用于 const 初值及折叠）。
 * 要求 e 已通过 is_const_expr；names/const_values 为当前作用域 const 名与已求值；n 为 const 个数。
 */
static int eval_const_int(const struct ASTExpr *e, const char **names, const int *const_values, int n) {
    if (!e) return 0;
    switch (e->kind) {
        case AST_EXPR_LIT:
            return e->value.int_val;
        case AST_EXPR_BOOL_LIT:
            return e->value.int_val ? 1 : 0;
        case AST_EXPR_FLOAT_LIT:
            return (int)e->value.float_val;
        case AST_EXPR_VAR: {
            const char *name = e->value.var.name;
            for (int i = 0; i < n && names && const_values; i++)
                if (names[i] && name && strcmp(names[i], name) == 0) return const_values[i];
            return 0;
        }
        case AST_EXPR_ADD: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return l + r;
        }
        case AST_EXPR_SUB: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return l - r;
        }
        case AST_EXPR_MUL: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return l * r;
        }
        case AST_EXPR_DIV: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return (r != 0) ? (l / r) : 0;
        }
        case AST_EXPR_MOD: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return (r != 0) ? (l % r) : 0;
        }
        case AST_EXPR_SHL: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return (int)((unsigned int)l << (r & 31));
        }
        case AST_EXPR_SHR: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return (int)((unsigned int)l >> (r & 31));
        }
        case AST_EXPR_BITAND: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return l & r;
        }
        case AST_EXPR_BITOR: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return l | r;
        }
        case AST_EXPR_BITXOR: {
            int l = eval_const_int(e->value.binop.left, names, const_values, n);
            int r = eval_const_int(e->value.binop.right, names, const_values, n);
            return l ^ r;
        }
        case AST_EXPR_EQ:  return eval_const_int(e->value.binop.left, names, const_values, n) == eval_const_int(e->value.binop.right, names, const_values, n) ? 1 : 0;
        case AST_EXPR_NE:  return eval_const_int(e->value.binop.left, names, const_values, n) != eval_const_int(e->value.binop.right, names, const_values, n) ? 1 : 0;
        case AST_EXPR_LT:  return eval_const_int(e->value.binop.left, names, const_values, n) <  eval_const_int(e->value.binop.right, names, const_values, n) ? 1 : 0;
        case AST_EXPR_LE:  return eval_const_int(e->value.binop.left, names, const_values, n) <= eval_const_int(e->value.binop.right, names, const_values, n) ? 1 : 0;
        case AST_EXPR_GT:  return eval_const_int(e->value.binop.left, names, const_values, n) >  eval_const_int(e->value.binop.right, names, const_values, n) ? 1 : 0;
        case AST_EXPR_GE:  return eval_const_int(e->value.binop.left, names, const_values, n) >= eval_const_int(e->value.binop.right, names, const_values, n) ? 1 : 0;
        case AST_EXPR_LOGAND: return (eval_const_int(e->value.binop.left, names, const_values, n) && eval_const_int(e->value.binop.right, names, const_values, n)) ? 1 : 0;
        case AST_EXPR_LOGOR:  return (eval_const_int(e->value.binop.left, names, const_values, n) || eval_const_int(e->value.binop.right, names, const_values, n)) ? 1 : 0;
        case AST_EXPR_NEG: {
            int o = eval_const_int(e->value.unary.operand, names, const_values, n);
            return -o;
        }
        case AST_EXPR_BITNOT: {
            int o = eval_const_int(e->value.unary.operand, names, const_values, n);
            return ~o;
        }
        case AST_EXPR_LOGNOT: {
            int o = eval_const_int(e->value.unary.operand, names, const_values, n);
            return !o ? 1 : 0;
        }
        case AST_EXPR_ARRAY_LIT:
            /* CTFE 扩展：数组字面量在整型上下文中求值为元素个数（数组长度） */
            return e->value.array_lit.num_elems;
        default:
            return 0;
    }
}

/**
 * 若 e 为整型/布尔常量表达式，则求值并设置 const_folded_val/const_folded_valid（CTFE 最小集）。
 * const_start：当前块 const 在 names 中的起始下标；parent_n_consts：父块 const 个数（names[0..parent_n_consts) 有父 const 值）。
 */
static void fold_expr(struct ASTExpr *e, const char **names, const int *const_values, int n_consts, int const_start, int parent_n_consts) {
    if (!e || !names) return;
    e->const_folded_valid = 0; /* 默认未折叠，避免 malloc 分配的节点残留垃圾 */
    switch (e->kind) {
        case AST_EXPR_LIT:
        case AST_EXPR_BOOL_LIT:
            e->const_folded_val = e->value.int_val;
            e->const_folded_valid = 1;
            return;
        case AST_EXPR_FLOAT_LIT:
            e->const_folded_val = (int)e->value.float_val;
            e->const_folded_valid = 1;
            return;
        case AST_EXPR_VAR:
            if (const_values) {
                const char *name = e->value.var.name;
                int i;
                for (i = 0; i < parent_n_consts; i++)
                    if (names[i] && name && strcmp(names[i], name) == 0) {
                        e->const_folded_val = const_values[i];
                        e->const_folded_valid = 1;
                        return;
                    }
                for (i = const_start; i < const_start + n_consts; i++)
                    if (names[i] && name && strcmp(names[i], name) == 0) {
                        e->const_folded_val = const_values[i];
                        e->const_folded_valid = 1;
                        return;
                    }
            }
            return;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR: {
            fold_expr(e->value.binop.left, names, const_values, n_consts, const_start, parent_n_consts);
            fold_expr(e->value.binop.right, names, const_values, n_consts, const_start, parent_n_consts);
            if (e->value.binop.left->const_folded_valid && e->value.binop.right->const_folded_valid && e->resolved_type &&
                (e->resolved_type->kind == AST_TYPE_I32 || e->resolved_type->kind == AST_TYPE_BOOL ||
                 e->resolved_type->kind == AST_TYPE_U8 || e->resolved_type->kind == AST_TYPE_U32 ||
                 e->resolved_type->kind == AST_TYPE_I64 || e->resolved_type->kind == AST_TYPE_USIZE || e->resolved_type->kind == AST_TYPE_ISIZE)) {
                int l = e->value.binop.left->const_folded_val, r = e->value.binop.right->const_folded_val;
                switch (e->kind) {
                    case AST_EXPR_ADD: e->const_folded_val = l + r; break;
                    case AST_EXPR_SUB: e->const_folded_val = l - r; break;
                    case AST_EXPR_MUL: e->const_folded_val = l * r; break;
                    case AST_EXPR_DIV: e->const_folded_val = (r != 0) ? (l / r) : 0; break;
                    case AST_EXPR_MOD: e->const_folded_val = (r != 0) ? (l % r) : 0; break;
                    case AST_EXPR_SHL: e->const_folded_val = (int)((unsigned int)l << (r & 31)); break;
                    case AST_EXPR_SHR: e->const_folded_val = (int)((unsigned int)l >> (r & 31)); break;
                    case AST_EXPR_BITAND: e->const_folded_val = l & r; break;
                    case AST_EXPR_BITOR: e->const_folded_val = l | r; break;
                    case AST_EXPR_BITXOR: e->const_folded_val = l ^ r; break;
                    case AST_EXPR_EQ: e->const_folded_val = (l == r) ? 1 : 0; break;
                    case AST_EXPR_NE: e->const_folded_val = (l != r) ? 1 : 0; break;
                    case AST_EXPR_LT: e->const_folded_val = (l < r) ? 1 : 0; break;
                    case AST_EXPR_LE: e->const_folded_val = (l <= r) ? 1 : 0; break;
                    case AST_EXPR_GT: e->const_folded_val = (l > r) ? 1 : 0; break;
                    case AST_EXPR_GE: e->const_folded_val = (l >= r) ? 1 : 0; break;
                    case AST_EXPR_LOGAND: e->const_folded_val = (l && r) ? 1 : 0; break;
                    case AST_EXPR_LOGOR: e->const_folded_val = (l || r) ? 1 : 0; break;
                    default: break;
                }
                e->const_folded_valid = 1;
            }
            return;
        }
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT:
        case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
            fold_expr(e->value.unary.operand, names, const_values, n_consts, const_start, parent_n_consts);
            if (e->kind != AST_EXPR_ADDR_OF && e->kind != AST_EXPR_DEREF && e->value.unary.operand->const_folded_valid && e->resolved_type &&
                (e->resolved_type->kind == AST_TYPE_I32 || e->resolved_type->kind == AST_TYPE_BOOL ||
                 e->resolved_type->kind == AST_TYPE_U8 || e->resolved_type->kind == AST_TYPE_U32 ||
                 e->resolved_type->kind == AST_TYPE_I64 || e->resolved_type->kind == AST_TYPE_USIZE || e->resolved_type->kind == AST_TYPE_ISIZE)) {
                int o = e->value.unary.operand->const_folded_val;
                if (e->kind == AST_EXPR_NEG) e->const_folded_val = -o;
                else if (e->kind == AST_EXPR_BITNOT) e->const_folded_val = ~o;
                else e->const_folded_val = !o ? 1 : 0;
                e->const_folded_valid = 1;
            }
            return;
        case AST_EXPR_AS:
            fold_expr(e->value.as_type.operand, names, const_values, n_consts, const_start, parent_n_consts);
            return;
        case AST_EXPR_ARRAY_LIT: {
            int ai;
            for (ai = 0; ai < e->value.array_lit.num_elems; ai++)
                fold_expr(e->value.array_lit.elems[ai], names, const_values, n_consts, const_start, parent_n_consts);
            /* 整型上下文：数组字面量 CTFE 为元素个数（C5-array-len） */
            if (e->resolved_type && (e->resolved_type->kind == AST_TYPE_I32 || e->resolved_type->kind == AST_TYPE_I64 ||
                    e->resolved_type->kind == AST_TYPE_U32 || e->resolved_type->kind == AST_TYPE_USIZE ||
                    e->resolved_type->kind == AST_TYPE_ISIZE)) {
                e->const_folded_val = e->value.array_lit.num_elems;
                e->const_folded_valid = 1;
            }
            return;
        }
        default:
            return;
    }
}

/**
 * 获取表达式类型（用于字段访问、下标校验）：VAR 查符号表；FIELD_ACCESS 取字段类型；INDEX 取数组元素类型；ENUM_VARIANT 为枚举类型。
 * 参数：type_ptrs 与 names 平行，存各符号的 ASTType*；out_elem_type 仅当表达式为数组时写入。
 * 返回值：0 成功并写入 out_*；-1 无法确定类型。
 */
static int get_expr_type(const struct ASTExpr *e, const char **names, const int *type_kinds,
    const char **type_names, int n, const struct ASTType **type_ptrs,
    struct ASTStructDef **struct_defs, int num_structs,
    struct ASTEnumDef **enum_defs, int num_enums,
    int *out_kind, const char **out_name, const struct ASTType **out_elem_type) {
    if (!e || !out_kind || !out_name) return -1;
    *out_name = NULL;
    if (out_elem_type) *out_elem_type = NULL;
    /* SX parser 的 match 1 { … } 等：matched 常为 EXPR_LIT，须能推断类型（与 typeck_expr_sym 中 i32 默认一致）。 */
    if (e->kind == AST_EXPR_LIT) {
        if (e->resolved_type) {
            *out_kind = e->resolved_type->kind;
            *out_name = e->resolved_type->name;
        } else {
            *out_kind = AST_TYPE_I32;
            *out_name = NULL;
        }
        return 0;
    }
    if (e->kind == AST_EXPR_BOOL_LIT) {
        *out_kind = AST_TYPE_BOOL;
        *out_name = NULL;
        return 0;
    }
    if (e->kind == AST_EXPR_FLOAT_LIT) {
        if (e->resolved_type) {
            *out_kind = e->resolved_type->kind;
            *out_name = e->resolved_type->name;
        } else {
            *out_kind = AST_TYPE_F64;
            *out_name = NULL;
        }
        return 0;
    }
    if (e->kind == AST_EXPR_ENUM_VARIANT) {
        *out_kind = AST_TYPE_NAMED;
        *out_name = e->value.enum_variant.enum_name;
        return 0;
    }
    if (e->kind == AST_EXPR_VAR) {
        const char *name = e->value.var.name;
        for (int i = 0; i < n; i++)
            if (names[i] && name && strcmp(names[i], name) == 0) {
                *out_kind = type_kinds[i];
                *out_name = (type_names && i < n) ? type_names[i] : NULL;
                if (out_elem_type && type_ptrs && i < n && type_ptrs[i] && type_ptrs[i]->elem_type &&
                    (type_ptrs[i]->kind == AST_TYPE_ARRAY || type_ptrs[i]->kind == AST_TYPE_SLICE || type_ptrs[i]->kind == AST_TYPE_PTR))
                    *out_elem_type = type_ptrs[i]->elem_type;
                return 0;
            }
        TYPECK_ERR((struct ASTExpr *)e, "get_expr_type variable '%.*s' not in scope", name ? (int)strlen(name) : 0, name ? name : "?");
        return -1;
    }
    if (e->kind == AST_EXPR_FIELD_ACCESS) {
        /* Type.Variant 形式（typeck 已设 is_enum_variant）：类型为枚举名 */
        if (e->value.field_access.is_enum_variant && e->value.field_access.base->kind == AST_EXPR_VAR && e->value.field_access.base->value.var.name) {
            *out_kind = AST_TYPE_NAMED;
            *out_name = e->value.field_access.base->value.var.name;
            return 0;
        }
        int base_kind;
        const char *base_name = NULL;
        if (get_expr_type(e->value.field_access.base, names, type_kinds, type_names, n, type_ptrs, struct_defs, num_structs, enum_defs, num_enums, &base_kind, &base_name, NULL) != 0) return -1;
        /* 切片 []T 的 .length（usize）与 .data（*elem_type） */
        if (base_kind == AST_TYPE_SLICE) {
            const char *field = e->value.field_access.field_name;
            if (field && strcmp(field, "length") == 0) {
                *out_kind = AST_TYPE_USIZE;
                *out_name = NULL;
                return 0;
            }
            if (field && strcmp(field, "data") == 0) {
                *out_kind = AST_TYPE_PTR;
                *out_name = NULL;
                if (out_elem_type && e->value.field_access.base->resolved_type
                    && e->value.field_access.base->resolved_type->kind == AST_TYPE_SLICE
                    && e->value.field_access.base->resolved_type->elem_type)
                    *out_elem_type = e->value.field_access.base->resolved_type->elem_type;
                return 0;
            }
            return -1;
        }
        /* 自举：指针到结构体 *T 的 p.field 按 T 的字段类型返回 */
        if (base_kind == AST_TYPE_PTR && e->value.field_access.base->kind == AST_EXPR_VAR && type_ptrs) {
            const char *var_name = e->value.field_access.base->value.var.name;
            for (int vi = 0; vi < n && var_name && names[vi]; vi++)
                if (strcmp(names[vi], var_name) == 0 && type_ptrs[vi] && type_ptrs[vi]->kind == AST_TYPE_PTR
                    && type_ptrs[vi]->elem_type && type_ptrs[vi]->elem_type->kind == AST_TYPE_NAMED
                    && type_ptrs[vi]->elem_type->name) {
                    base_name = type_ptrs[vi]->elem_type->name;
                    base_kind = AST_TYPE_NAMED;
                    break;
                }
        }
        if (base_kind != AST_TYPE_NAMED || !base_name) return -1;
        const struct ASTStructDef *sd = find_struct_def_with_deps(struct_defs, num_structs, base_name);
        if (!sd) return -1;
        const char *field = e->value.field_access.field_name;
        for (int i = 0; i < sd->num_fields; i++)
            if (sd->fields[i].name && field && strcmp(sd->fields[i].name, field) == 0) {
                *out_kind = sd->fields[i].type->kind;
                *out_name = sd->fields[i].type->name;
                if (out_elem_type && sd->fields[i].type->elem_type && (sd->fields[i].type->kind == AST_TYPE_ARRAY || sd->fields[i].type->kind == AST_TYPE_SLICE || sd->fields[i].type->kind == AST_TYPE_PTR))
                    *out_elem_type = sd->fields[i].type->elem_type;
                return 0;
            }
        return -1;
    }
    if (e->kind == AST_EXPR_INDEX) {
        int base_kind;
        const char *base_name = NULL;
        const struct ASTType *base_elem = NULL;
        if (get_expr_type(e->value.index.base, names, type_kinds, type_names, n, type_ptrs, struct_defs, num_structs, enum_defs, num_enums, &base_kind, &base_name, &base_elem) != 0) return -1;
        if (base_kind == AST_TYPE_PTR && !base_elem && e->value.index.base->resolved_type && e->value.index.base->resolved_type->kind == AST_TYPE_PTR)
            base_elem = e->value.index.base->resolved_type->elem_type;
        if (base_kind != AST_TYPE_ARRAY && base_kind != AST_TYPE_SLICE && base_kind != AST_TYPE_PTR && base_kind != AST_TYPE_VECTOR) {
                TYPECK_ERR(e, "subscript base must be array, slice or pointer type");
                return -1;
        }
        if (!base_elem) {
                TYPECK_ERR(e, "subscript base must be array, slice or pointer type");
                return -1;
        }
        *out_kind = base_elem->kind;
        *out_name = base_elem->name;
        if (out_elem_type && base_elem->elem_type && (base_elem->kind == AST_TYPE_ARRAY || base_elem->kind == AST_TYPE_SLICE || base_elem->kind == AST_TYPE_PTR))
            *out_elem_type = base_elem->elem_type;
        return 0;
    }
    if (e->kind == AST_EXPR_AS) {
        const struct ASTType *ty = e->value.as_type.type;
        if (!ty) return -1;
        *out_kind = ty->kind;
        *out_name = ty->name;
        if (out_elem_type && ty->elem_type && (ty->kind == AST_TYPE_ARRAY || ty->kind == AST_TYPE_SLICE || ty->kind == AST_TYPE_PTR))
            *out_elem_type = ty->elem_type;
        return 0;
    }
    if (e->kind == AST_EXPR_AWAIT) {
        return get_expr_type(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs,
            struct_defs, num_structs, enum_defs, num_enums, out_kind, out_name, out_elem_type);
    }
    if (e->kind == AST_EXPR_RUN || e->kind == AST_EXPR_SPAWN) {
        return get_expr_type(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs,
            struct_defs, num_structs, enum_defs, num_enums, out_kind, out_name, out_elem_type);
    }
    TYPECK_ERR((struct ASTExpr *)e, "get_expr_type unhandled expression kind %d", (int)e->kind);
    return -1;
}

/**
 * 计算非泛型候选 overload 与已 typecheck 实参的匹配得分；不匹配返回 -1，精确匹配得分更高。
 */
static int typeck_overload_match_score_args(const struct ASTFunc *f, int num_args, struct ASTExpr **args) {
    if (!f || f->num_generic_params > 0 || !args) return -1;
    if (f->num_params != num_args) return -1;
    int score = 0;
    for (int i = 0; i < f->num_params; i++) {
        const struct ASTExpr *arg_e = args[i];
        const struct ASTType *arg = arg_e ? arg_e->resolved_type : NULL;
        const struct ASTType *param = f->params[i].type;
        if (!type_assignable_to(arg, param, arg_e)) return -1;
        if (arg && param && type_equal(arg, param)) score += 1000;
        else score += 1;
    }
    return score;
}

static int typeck_overload_match_score(const struct ASTFunc *f, const struct ASTExpr *call) {
    if (!call || call->kind != AST_EXPR_CALL) return -1;
    return typeck_overload_match_score_args(f, call->value.call.num_args, call->value.call.args);
}

/** let/赋值上下文：按返回类型消解仅实参相同的 overload（如 heap.alloc(count)->*T）。 */
static const struct ASTType *typeck_ctx_expected_return;

/** 返回类型是否满足 let/赋值上下文（*T 按元素类型比较）。 */
static int typeck_return_matches_expected(const struct ASTType *ret, const struct ASTType *expect) {
    if (!ret || !expect) return 0;
    if (type_equal(ret, expect)) return 1;
    if (ret->kind == AST_TYPE_PTR && expect->kind == AST_TYPE_PTR
        && ret->elem_type && expect->elem_type)
        return type_equal(ret->elem_type, expect->elem_type);
    return 0;
}

/**
 * 在模块 mod 中按名称与实参类型选取唯一 overload；ambiguous / 未找到时返回 -1。
 */
static int typeck_pick_overload_in_module_ex(const struct ASTModule *mod, const char *name,
    int num_args, struct ASTExpr **args, struct ASTExpr *err_node, struct ASTFunc **out) {
    struct ASTFunc *best = NULL;
    struct ASTFunc *ret_match = NULL;
    int best_score = -1;
    int n_at_best = 0;
    int n_ret_match = 0;
    if (!mod || !name || !args || !out) return -1;
    for (int i = 0; i < mod->num_funcs; i++) {
        struct ASTFunc *cand = mod->funcs[i];
        int sc;
        if (!cand || !cand->name || strcmp(cand->name, name) != 0) continue;
        sc = typeck_overload_match_score_args(cand, num_args, args);
        if (sc < 0) continue;
        if (sc > best_score) {
            best = cand;
            best_score = sc;
            n_at_best = 1;
        } else if (sc == best_score) {
            n_at_best++;
        }
    }
    if (!best) return -1;
    if (typeck_ctx_expected_return) {
        for (int i = 0; i < mod->num_funcs; i++) {
            struct ASTFunc *cand = mod->funcs[i];
            int sc;
            if (!cand || !cand->name || strcmp(cand->name, name) != 0) continue;
            sc = typeck_overload_match_score_args(cand, num_args, args);
            if (sc != best_score) continue;
            if (!typeck_return_matches_expected(cand->return_type, typeck_ctx_expected_return)) continue;
            if (n_ret_match == 0) ret_match = cand;
            n_ret_match++;
        }
        if (n_ret_match == 1) {
            *out = ret_match;
            return 0;
        }
        if (n_ret_match > 1) {
            TYPECK_ERR(err_node, "ambiguous call to overloaded function '%s'", name);
            return -1;
        }
    }
    if (n_at_best > 1) {
        TYPECK_ERR(err_node, "ambiguous call to overloaded function '%s'", name);
        return -1;
    }
    *out = best;
    return 0;
}

static int typeck_pick_overload_in_module(const struct ASTModule *mod, const char *name,
    struct ASTExpr *call, struct ASTFunc **out) {
    if (!call || call->kind != AST_EXPR_CALL) return -1;
    return typeck_pick_overload_in_module_ex(mod, name, call->value.call.num_args,
        call->value.call.args, call, out);
}

/**
 * 在模块 mod 中按名称查找泛型函数模板（num_generic_params > 0）。
 */
static int typeck_find_generic_func_in_module(const struct ASTModule *mod, const char *name,
    struct ASTFunc **out) {
    if (!mod || !name || !out) return -1;
    for (int i = 0; i < mod->num_funcs; i++) {
        struct ASTFunc *cand = mod->funcs[i];
        if (!cand || !cand->name || strcmp(cand->name, name) != 0) continue;
        if (cand->num_generic_params > 0) {
            *out = cand;
            return 0;
        }
    }
    return -1;
}

/**
 * 按名称 + 实参匹配唯一非泛型函数（binding import 回退、单候选解析）。
 */
static int typeck_find_func_in_module_by_name(const struct ASTModule *mod, const char *name,
    int num_args, struct ASTExpr **args, struct ASTFunc **out) {
    struct ASTFunc *best = NULL;
    int n_match = 0;
    if (!mod || !name || !args || !out) return -1;
    for (int i = 0; i < mod->num_funcs; i++) {
        struct ASTFunc *cand = mod->funcs[i];
        if (!cand || !cand->name || strcmp(cand->name, name) != 0) continue;
        if (cand->num_generic_params > 0) continue;
        if (typeck_overload_match_score_args(cand, num_args, args) < 0) continue;
        best = cand;
        n_match++;
        if (n_match > 1) return -1;
    }
    if (!best) return -1;
    *out = best;
    return 0;
}

/**
 * 泛型解析失败后：binding import 依赖模块内按名称查找泛型模板。
 */
static int typeck_find_generic_func_in_binding_deps(const struct ASTModule *m, const char *name,
    struct ASTFunc **out, int *from_dep) {
    if (!m || !name || !out || !typeck_dep_mods) return -1;
    for (int j = 0; j < typeck_num_deps && j < m->num_imports; j++) {
        struct ASTModule *dm = typeck_dep_mods[j];
        const char *dep_fn = name;
        int ok_binding = (m->import_kinds && m->import_kinds[j] == AST_IMPORT_KIND_BINDING);
        if (!ok_binding && !import_exports_name(m, j, name)) continue;
        if (!ok_binding) {
            const char *src = import_select_source_for_local(m, j, name);
            if (src) dep_fn = src;
        }
        if (!dm) continue;
        if (typeck_find_generic_func_in_module(dm, dep_fn, out) == 0) {
            if (from_dep) *from_dep = j;
            return 0;
        }
    }
    return -1;
}

/**
 * overload 解析失败后：binding import 依赖模块内按名称查找（如 const foo = import("foo"); bar()）。
 */
static int typeck_find_func_in_binding_deps(const struct ASTModule *m, const char *name,
    int num_args, struct ASTExpr **args, struct ASTFunc **out, int *from_dep) {
    if (!m || !name || !args || !out || !typeck_dep_mods) return -1;
    for (int j = 0; j < typeck_num_deps && j < m->num_imports; j++) {
        struct ASTModule *dm = typeck_dep_mods[j];
        const char *dep_fn = name;
        int ok_binding = (m->import_kinds && m->import_kinds[j] == AST_IMPORT_KIND_BINDING);
        if (!ok_binding && !import_exports_name(m, j, name)) continue;
        if (!ok_binding) {
            const char *src = import_select_source_for_local(m, j, name);
            if (src) dep_fn = src;
        }
        if (!dm) continue;
        if (typeck_find_func_in_module_by_name(dm, dep_fn, num_args, args, out) == 0) {
            if (from_dep) *from_dep = j;
            return 0;
        }
    }
    return -1;
}

/**
 * 对单棵表达式做类型检查；VAR 须在符号表 names[0..n) 中已定义；break/continue 仅允许在循环体内；FIELD_ACCESS/STRUCT_LIT/ARRAY_LIT/INDEX 须与类型一致；CALL 须在模块函数表中找到并参数匹配（支持 overload）。
 * 参数：type_ptrs 与 names 平行，存各符号的 ASTType*；m 为当前模块，用于 CALL 查找函数签名，可为 NULL。
 * 返回值：0 通过，-1 非法并已写 stderr。
 */
static int typeck_expr_sym(const struct ASTExpr *e, const char **names,
    const int *type_kinds, const char **type_names, int n, const struct ASTType **type_ptrs,
    int inside_loop, struct ASTStructDef **struct_defs, int num_structs,
    struct ASTEnumDef **enum_defs, int num_enums, const struct ASTModule *m) {
    if (!e) return 0;
    switch (e->kind) {
        case AST_EXPR_ENUM_VARIANT: {
            const struct ASTEnumDef *ed = find_enum_def(enum_defs, num_enums, e->value.enum_variant.enum_name);
            if (!ed) {
                TYPECK_ERR(e, "unknown enum type '%s'", e->value.enum_variant.enum_name ? e->value.enum_variant.enum_name : "?");
                return -1;
            }
            const char *v = e->value.enum_variant.variant_name;
            for (int i = 0; i < ed->num_variants; i++)
                if (ed->variant_names[i] && v && strcmp(ed->variant_names[i], v) == 0) return 0;
            TYPECK_ERR(e, "enum '%s' has no variant '%s'", ed->name ? ed->name : "?", v ? v : "?");
            return -1;
        }
        case AST_EXPR_BREAK:
        case AST_EXPR_CONTINUE:
            if (!inside_loop) {
                TYPECK_ERR(e, "'%s' only allowed inside a loop",
                    e->kind == AST_EXPR_BREAK ? "break" : "continue");
                return -1;
            }
            return 0;
        case AST_EXPR_RETURN:
            if (e->value.unary.operand)
                return typeck_expr_sym(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m);
            return 0;  /* return; 的 void 检查在 typeck_block 中根据 func_return_type 完成 */
        case AST_EXPR_LIT:
            ((struct ASTExpr *)e)->resolved_type = &static_type_i32;
            return 0;
        case AST_EXPR_BOOL_LIT:
            ((struct ASTExpr *)e)->resolved_type = &static_type_bool;
            return 0;
        case AST_EXPR_FLOAT_LIT: {
            if (!e->resolved_type)
                ((struct ASTExpr *)e)->resolved_type = &static_type_f64;
            /* 填写 64 位位模式供 asm 后端 EXPR_FLOAT_LIT 发射 movq 立即数 */
            union { double d; unsigned long long u; } u;
            u.d = e->value.float_val;
            ((struct ASTExpr *)e)->float_bits_lo = (int)(u.u & 0xFFFFFFFFU);
            ((struct ASTExpr *)e)->float_bits_hi = (int)(u.u >> 32);
            return 0;
        }
        case AST_EXPR_VAR: {
            const char *name = e->value.var.name;
            for (int i = 0; i < n; i++)
                if (names[i] && name && strcmp(names[i], name) == 0) {
                    if (typeck_linear_use_var(e, i, type_ptrs) != 0)
                        return -1;
                    if (type_ptrs && i < n && type_ptrs[i])
                        ((struct ASTExpr *)e)->resolved_type = type_ptrs[i];
                    return 0;
                }
            /* 标识符未在局部/参数中：若为 import 的模块名（如 backend）或某 import 路径的前缀（如 arch 对 arch.x86_64），视为合法，供 module.func / arch.x86_64.func 使用 */
            if (m && m->import_paths && name) {
                for (int j = 0; j < m->num_imports; j++) {
                    if (!m->import_paths[j]) continue;
                    if (import_module_ref_matches(m, j, name)) return 0;
                    if (import_path_has_prefix(m->import_paths[j], name)) return 0;
                }
            }
            /* 依赖模块顶层 const 禁止裸名（须 binding.CONST 或解构 import 显式绑定） */
            {
                const struct ASTLetDecl *mc = find_module_const_in_deps(name);
                if (mc && mc->type) {
                    char hint[128];
                    if (typeck_const_binding_hint(name, hint, sizeof(hint)))
                        TYPECK_ERR(e, "import constant '%s' must be qualified; use %s.%s", name, hint, name);
                    TYPECK_ERR(e, "import constant '%s' must be qualified as binding.%s", name, name);
                    return -1;
                }
            }
            TYPECK_ERR(e, "undefined name '%s'", name ? name : "");
            return -1;
        }
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV:
        case AST_EXPR_MOD: case AST_EXPR_SHL: case AST_EXPR_SHR:
        case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE:
        case AST_EXPR_GT: case AST_EXPR_GE: case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            if (typeck_expr_sym(e->value.binop.left, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (typeck_expr_sym(e->value.binop.right, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            /* 向量逐分量运算（§10）：两操作数均为同类型向量时，结果类型为该向量 */
            {
                const struct ASTType *lt = e->value.binop.left->resolved_type;
                const struct ASTType *rt = e->value.binop.right->resolved_type;
                /* [a,b,c,d] + [e,f,g,h]：数组字面量按 lanes 推断向量类型（vec_add_lit.sx） */
                if (e->value.binop.left->kind == AST_EXPR_ARRAY_LIT &&
                    e->value.binop.right->kind == AST_EXPR_ARRAY_LIT) {
                    const struct ASTExpr *ll = e->value.binop.left;
                    const struct ASTExpr *lr = e->value.binop.right;
                    int nl = ll->value.array_lit.num_elems;
                    int nr = lr->value.array_lit.num_elems;
                    const struct ASTType *et = (nl > 0 && ll->value.array_lit.elems[0])
                        ? ll->value.array_lit.elems[0]->resolved_type : NULL;
                    if (nl > 0 && nl == nr && et && lr->value.array_lit.elems[0]
                        && lr->value.array_lit.elems[0]->resolved_type
                        && type_equal(et, lr->value.array_lit.elems[0]->resolved_type)) {
                        static struct ASTType vec_from_lit;
                        vec_from_lit.kind = AST_TYPE_VECTOR;
                        vec_from_lit.name = NULL;
                        vec_from_lit.elem_type = (struct ASTType *)et;
                        vec_from_lit.array_size = nl;
                        vec_from_lit.region_label = NULL;
                        ((struct ASTExpr *)e->value.binop.left)->resolved_type = &vec_from_lit;
                        ((struct ASTExpr *)e->value.binop.right)->resolved_type = &vec_from_lit;
                        ((struct ASTExpr *)e)->resolved_type = &vec_from_lit;
                        lt = rt = &vec_from_lit;
                    }
                }
                if (lt && rt && lt->kind == AST_TYPE_VECTOR && rt->kind == AST_TYPE_VECTOR
                    && lt->elem_type && rt->elem_type && lt->elem_type->kind == rt->elem_type->kind
                    && lt->array_size == rt->array_size)
                    ((struct ASTExpr *)e)->resolved_type = lt;
                else if (e->kind >= AST_EXPR_EQ && e->kind <= AST_EXPR_GE)
                    ((struct ASTExpr *)e)->resolved_type = &static_type_bool;
                else if (e->kind == AST_EXPR_LOGAND || e->kind == AST_EXPR_LOGOR)
                    ((struct ASTExpr *)e)->resolved_type = &static_type_bool;
                else if (lt && rt) {
                    /* 标量算术：i64 与 i32 混合时提升为 i64；含 f64/f32 时提升为浮点；否则两类型须一致 */
                    if (lt->kind == AST_TYPE_I64 || rt->kind == AST_TYPE_I64)
                        ((struct ASTExpr *)e)->resolved_type = &static_type_i64;
                    else if ((lt->kind == AST_TYPE_F32 && rt->kind == AST_TYPE_F64 &&
                              e->value.binop.right->kind == AST_EXPR_FLOAT_LIT) ||
                             (rt->kind == AST_TYPE_F32 && lt->kind == AST_TYPE_F64 &&
                              e->value.binop.left->kind == AST_EXPR_FLOAT_LIT))
                        ((struct ASTExpr *)e)->resolved_type = &static_type_f32;
                    else if (lt->kind == AST_TYPE_F64 || rt->kind == AST_TYPE_F64)
                        ((struct ASTExpr *)e)->resolved_type = &static_type_f64;
                    else if (lt->kind == AST_TYPE_F32 || rt->kind == AST_TYPE_F32)
                        ((struct ASTExpr *)e)->resolved_type = &static_type_f32;
                    else if (type_equal(lt, rt))
                        ((struct ASTExpr *)e)->resolved_type = lt;
                    /* bool 参与 + - * / % 时结果为 i32（如 (3==3)+(2<5)；勿把 usize-i32 等混算一律提升为 i32） */
                    if ((e->kind == AST_EXPR_ADD || e->kind == AST_EXPR_SUB || e->kind == AST_EXPR_MUL
                            || e->kind == AST_EXPR_DIV || e->kind == AST_EXPR_MOD)
                        && (lt->kind == AST_TYPE_BOOL || rt->kind == AST_TYPE_BOOL
                            || (((struct ASTExpr *)e)->resolved_type
                                && ((struct ASTExpr *)e)->resolved_type->kind == AST_TYPE_BOOL)))
                        ((struct ASTExpr *)e)->resolved_type = &static_type_i32;
                }
            }
            return 0;
        case AST_EXPR_NEG:
        case AST_EXPR_BITNOT: {
            if (typeck_expr_sym(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0)
                return -1;
            {
                const struct ASTType *op_ty = e->value.unary.operand->resolved_type;
                if (op_ty)
                    ((struct ASTExpr *)e)->resolved_type = op_ty;
            }
            return 0;
        }
        case AST_EXPR_LOGNOT: {
            if (typeck_expr_sym(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0)
                return -1;
            ((struct ASTExpr *)e)->resolved_type = &static_type_bool;
            return 0;
        }
        case AST_EXPR_ADDR_OF: {
            /* M-4：禁止对 Linear(T) 取址（须在 use-once 消费 VAR 之前检查）。 */
            if (e->value.unary.operand && e->value.unary.operand->kind == AST_EXPR_VAR) {
                const char *vname = e->value.unary.operand->value.var.name;
                for (int i = 0; i < n; i++)
                    if (names[i] && vname && strcmp(names[i], vname) == 0 && type_ptrs && type_ptrs[i] &&
                        type_ptrs[i]->kind == AST_TYPE_LINEAR) {
                        TYPECK_ERR(e, "cannot take address of linear value");
                        return -1;
                    }
            }
            return typeck_expr_sym(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m);
        }
        case AST_EXPR_DEREF: {
            if (!typeck_fill_only && typeck_unsafe_depth <= 0) {
                TYPECK_ERR(e, "pointer dereference requires unsafe block");
                return -1;
            }
            if (typeck_expr_sym(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            const struct ASTType *op_ty = e->value.unary.operand->resolved_type;
            if (!op_ty || op_ty->kind != AST_TYPE_PTR || !op_ty->elem_type) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "dereference operand must be pointer type");
                    return -1;
                }
                return 0;
            }
            ((struct ASTExpr *)e)->resolved_type = op_ty->elem_type;
            return 0;
        }
        case AST_EXPR_AS:
            if (typeck_expr_sym(e->value.as_type.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            ((struct ASTExpr *)e)->resolved_type = e->value.as_type.type;
            return 0;
        case AST_EXPR_AWAIT:
            if (!typeck_current_func_is_async) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "'await' is only allowed inside async function");
                    return -1;
                }
                return 0;
            }
            if (typeck_expr_sym(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            ((struct ASTExpr *)e)->resolved_type = e->value.unary.operand->resolved_type;
            return 0;
        case AST_EXPR_RUN:
        case AST_EXPR_SPAWN: {
            const char *spawn_kw = (e->kind == AST_EXPR_SPAWN) ? "spawn" : "run";
            const struct ASTExpr *op = e->value.unary.operand;
            const struct ASTFunc *callee;
            int num_args;
            int pi;
            if (typeck_current_func_is_async) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "'%s' is not allowed inside async function (use await)", spawn_kw);
                    return -1;
                }
                return 0;
            }
            if (!op || op->kind != AST_EXPR_CALL) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "'%s' operand must be a call like %s async_fn()", spawn_kw, spawn_kw);
                    return -1;
                }
                return 0;
            }
            num_args = op->value.call.num_args;
            if (num_args < 0 || num_args > 8) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "'%s' async call supports zero to eight scalar arguments (v4)", spawn_kw);
                    return -1;
                }
                return 0;
            }
            if (typeck_expr_sym(op, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0)
                return -1;
            callee = op->value.call.resolved_callee_func;
            if (!callee || !callee->is_async) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "'%s' target must be async function", spawn_kw);
                    return -1;
                }
                return 0;
            }
            if (callee->num_params != num_args) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "'%s' argument count must match async function parameter count (v4)", spawn_kw);
                    return -1;
                }
                return 0;
            }
            for (pi = 0; pi < num_args; pi++) {
                const struct ASTExpr *a = op->value.call.args[pi];
                const struct ASTType *pty = callee->params[pi].type;
                if (!pty || !typeck_run_seed_scalar_kind(pty->kind)) {
                    if (!typeck_fill_only) {
                        TYPECK_ERR(e, "'%s' async params must be i32, u32, i64, or usize (v4)", spawn_kw);
                        return -1;
                    }
                    return 0;
                }
                if (!a || !a->resolved_type || !typeck_run_seed_arg_matches_param(a->resolved_type, pty)) {
                    if (!typeck_fill_only) {
                        TYPECK_ERR(e, "'%s' async argument type must match parameter type (v4)", spawn_kw);
                        return -1;
                    }
                    return 0;
                }
            }
            if (e->kind == AST_EXPR_SPAWN)
                ((struct ASTExpr *)e)->resolved_type = &static_type_i32;
            else
                ((struct ASTExpr *)e)->resolved_type = op->resolved_type;
            return 0;
        }
        case AST_EXPR_IF: {
            const struct ASTExpr *cond_if = e->value.if_expr.cond;
            if (typeck_expr_sym(cond_if, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (!expr_produces_bool(cond_if, names, type_kinds, n)) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "if condition must be bool (no implicit int-to-bool)");
                    return -1;
                }
            }
            if (typeck_expr_sym(e->value.if_expr.then_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (e->value.if_expr.else_expr && typeck_expr_sym(e->value.if_expr.else_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            /* if 表达式类型：两分支均为 struct 时须类型一致，否则 codegen 会生成 struct X = struct Y；一侧 struct 一侧标量时取 struct 以便 __tmp 声明正确 */
            {
                const struct ASTExpr *te = e->value.if_expr.then_expr;
                const struct ASTExpr *ee = e->value.if_expr.else_expr;
                const struct ASTType *ty_t = te ? te->resolved_type : NULL;
                const struct ASTType *ty_e = ee ? ee->resolved_type : NULL;
                int t_named = (ty_t && ty_t->kind == AST_TYPE_NAMED);
                int e_named = (ty_e && ty_e->kind == AST_TYPE_NAMED);
                if (ty_t && ty_e && t_named && e_named && !type_equal(ty_t, ty_e)) {
                    if (!typeck_fill_only) {
                        char ebuf[80], fbuf[80];
                        type_to_string_buf(ty_t, ebuf, sizeof(ebuf));
                        type_to_string_buf(ty_e, fbuf, sizeof(fbuf));
                        TYPECK_ERR(e, "if-expr branches must have the same type when both are struct: then %s, else %s", ebuf, fbuf);
                    }
                    return -1;
                }
                if (ty_t && ty_e)
                    ((struct ASTExpr *)e)->resolved_type = (e_named && !t_named) ? ty_e : ty_t;
                else if (ty_t) ((struct ASTExpr *)e)->resolved_type = ty_t;
                else if (ty_e) ((struct ASTExpr *)e)->resolved_type = ty_e;
            }
            return 0;
        }
        case AST_EXPR_BLOCK: {
            /* 块表达式（if 的 then/else 体）：用块表达式上下文 typeck_block（func_return_type=NULL 允许 return） */
            const struct ASTBlock *b = e->value.block;
            if (typeck_block(b, names, type_kinds, type_names, type_ptrs, n, NULL, 0, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m, NULL, NULL) != 0) return -1;
            if (b->final_expr && b->final_expr->kind != AST_EXPR_RETURN) {
                /* 若 final_expr 为赋值，用 RHS 类型作为块类型（如 else { __tmp = (struct ast_Type){0} } 取 ast.Type），便于 if 表达式 __tmp 推断 */
                if (expr_is_assign_or_compound(b->final_expr) && b->final_expr->value.binop.right && b->final_expr->value.binop.right->resolved_type)
                    ((struct ASTExpr *)e)->resolved_type = b->final_expr->value.binop.right->resolved_type;
                else
                    ((struct ASTExpr *)e)->resolved_type = b->final_expr->resolved_type;
            } else if (b->final_expr && b->final_expr->kind == AST_EXPR_RETURN && b->final_expr->value.unary.operand)
                ((struct ASTExpr *)e)->resolved_type = b->final_expr->value.unary.operand->resolved_type;
            else if (b->num_labeled_stmts == 1 && b->labeled_stmts[0].kind == AST_STMT_RETURN && b->labeled_stmts[0].u.return_expr)
                ((struct ASTExpr *)e)->resolved_type = b->labeled_stmts[0].u.return_expr->resolved_type;
            /* 块仅含一条赋值语句且无 final_expr 时（如 else { __tmp = (struct ast_Type){0} }），用赋值 RHS 类型作为块类型，供 if 表达式取 else 分支 struct 类型 */
            else if (!b->final_expr && b->expr_stmts && b->num_expr_stmts == 1
                && expr_is_assign_or_compound(b->expr_stmts[0]) && b->expr_stmts[0]->value.binop.right
                && b->expr_stmts[0]->value.binop.right->resolved_type)
                ((struct ASTExpr *)e)->resolved_type = b->expr_stmts[0]->value.binop.right->resolved_type;
            return 0;
        }
        case AST_EXPR_TERNARY: {
            /* cond ? then : else：条件须为 bool，两分支类型须一致 */
            const struct ASTExpr *cond_ter = e->value.if_expr.cond;
            if (typeck_expr_sym(cond_ter, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (!expr_produces_bool(cond_ter, names, type_kinds, n)) {
                if (!typeck_fill_only) {
                    TYPECK_ERR(e, "ternary condition must be bool (no implicit int-to-bool)");
                    return -1;
                }
            }
            if (typeck_expr_sym(e->value.if_expr.then_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (typeck_expr_sym(e->value.if_expr.else_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            const struct ASTType *ty_then = e->value.if_expr.then_expr->resolved_type;
            const struct ASTType *ty_else = e->value.if_expr.else_expr->resolved_type;
            if (!ty_then || !ty_else || !type_equal(ty_then, ty_else)) {
                {
                    char ebuf[80], fbuf[80];
                    type_to_string_buf(e->value.if_expr.then_expr->resolved_type, ebuf, sizeof(ebuf));
                    type_to_string_buf(e->value.if_expr.else_expr->resolved_type, fbuf, sizeof(fbuf));
                    TYPECK_ERR(e, "ternary branches must have the same type: expected %s, found %s", ebuf, fbuf);
                }
                return -1;
            }
            ((struct ASTExpr *)e)->resolved_type = ty_then;
            return 0;
        }
        case AST_EXPR_ASSIGN: {
            /* left = right：左值类型须与右值一致，表达式类型为左值类型 */
            if (typeck_expr_sym(e->value.binop.left, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (typeck_expr_sym(e->value.binop.right, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            const struct ASTType *lt = e->value.binop.left->resolved_type;
            const struct ASTType *rt = e->value.binop.right->resolved_type;
            if (!rt && lt)
                ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt;  /* 子块中右端可能未解析到类型，用左端补 */
            rt = e->value.binop.right->resolved_type;
            if (!typeck_fill_only && typeck_check_slice_region_assign(e, lt, rt) != 0)
                return -1;
            if (!lt || !rt || !type_equal(lt, rt)) {
                /* 允许 0..255 整数字面量赋给 u8（与函数实参一致，便于 out_buf[i] = 10 等） */
                int allow_u8_lit = 0;
                if (lt && lt->kind == AST_TYPE_U8 && e->value.binop.right->kind == AST_EXPR_LIT) {
                    int v = e->value.binop.right->value.int_val;
                    if (v >= 0 && v <= 255) { allow_u8_lit = 1; ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt; }
                }
                /* 允许字面量 0 赋给指针（如 v.ptr = 0），与 C 的 NULL 一致 */
                int allow_ptr_zero = 0;
                if (lt && lt->kind == AST_TYPE_PTR && e->value.binop.right->kind == AST_EXPR_LIT && e->value.binop.right->value.int_val == 0) {
                    allow_ptr_zero = 1;
                    ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt;
                }
                /* 允许整数字面量赋给 u8/u32/u64/usize 等（与 let 初值 typeck_coerce_let_int_lit 一致） */
                int allow_int_lit = 0;
                if (lt && e->value.binop.right->kind == AST_EXPR_LIT
                    && typeck_coerce_let_int_lit(lt, (struct ASTExpr *)e->value.binop.right)) {
                    allow_int_lit = 1;
                } else if (lt && rt && typeck_integer_widen_ok(lt->kind, rt->kind)) {
                    ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt;
                    allow_int_lit = 1;
                } else if (lt && lt->kind == AST_TYPE_NAMED && lt->name
                    && e->value.binop.right->kind == AST_EXPR_LIT) {
                    /* CORE-013：i16/u16 字段赋 small int literal（PollFd.events 等）。 */
                    int v = e->value.binop.right->value.int_val;
                    if ((strcmp(lt->name, "i16") == 0 && v >= -32768 && v <= 32767)
                        || (strcmp(lt->name, "u16") == 0 && v >= 0 && v <= 65535)) {
                        allow_int_lit = 1;
                        ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt;
                    }
                }
                if (!allow_u8_lit && !allow_ptr_zero && !allow_int_lit && !typeck_fill_only) {
                    /* f32 赋值：右端 f64 浮点字面量允许窄化（sum = sum + 1.0；simd_dot.sx） */
                    int allow_f32_narrow = 0;
                    if (lt && lt->kind == AST_TYPE_F32 && rt && rt->kind == AST_TYPE_F64 &&
                        e->value.binop.right->kind == AST_EXPR_FLOAT_LIT) {
                        allow_f32_narrow = 1;
                        ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt;
                    }
                    if (!allow_f32_narrow) {
                    char ebuf[80], fbuf[80];
                    type_to_string_buf(lt, ebuf, sizeof(ebuf));
                    type_to_string_buf(rt, fbuf, sizeof(fbuf));
                    TYPECK_ERR(e, "assignment type mismatch: expected %s, found %s", ebuf, fbuf);
                    return -1;
                    }
                }
            }
            ((struct ASTExpr *)e)->resolved_type = lt;
            return 0;
        }
        /* 复合赋值 left op= right：与 ASSIGN 类似，左值类型与右值（或 left op right 结果）一致，表达式类型为左值类型 */
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN: {
            if (typeck_expr_sym(e->value.binop.left, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (typeck_expr_sym(e->value.binop.right, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            const struct ASTType *lt = e->value.binop.left->resolved_type;
            const struct ASTType *rt = e->value.binop.right->resolved_type;
            if (!rt && lt)
                ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt;
            rt = e->value.binop.right->resolved_type;
            if (!typeck_fill_only && typeck_check_slice_region_assign(e, lt, rt) != 0)
                return -1;
            if (!lt || !rt || !type_equal(lt, rt)) {
                int allow_u8_lit = 0;
                if (lt && lt->kind == AST_TYPE_U8 && e->value.binop.right->kind == AST_EXPR_LIT) {
                    int v = e->value.binop.right->value.int_val;
                    if (v >= 0 && v <= 255) { allow_u8_lit = 1; ((struct ASTExpr *)e->value.binop.right)->resolved_type = lt; }
                }
                if (!allow_u8_lit && !typeck_fill_only) {
                    char ebuf[80], fbuf[80];
                    type_to_string_buf(lt, ebuf, sizeof(ebuf));
                    type_to_string_buf(rt, fbuf, sizeof(fbuf));
                    TYPECK_ERR(e, "compound assignment type mismatch: expected %s, found %s", ebuf, fbuf);
                    return -1;
                }
            }
            ((struct ASTExpr *)e)->resolved_type = lt;
            return 0;
        }
        case AST_EXPR_PANIC:
            if (e->value.unary.operand)
                return typeck_expr_sym(e->value.unary.operand, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m);
            return 0;
        case AST_EXPR_MATCH: {
            if (typeck_expr_sym(e->value.match_expr.matched_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            int match_kind;
            const char *match_name = NULL;
            if (get_expr_type(e->value.match_expr.matched_expr, names, type_kinds, type_names, n, type_ptrs, struct_defs, num_structs, enum_defs, num_enums, &match_kind, &match_name, NULL) != 0) {
                TYPECK_ERR(e, "match expression has no determinable type");
                return -1;
            }
            const struct ASTEnumDef *match_enum = (match_kind == AST_TYPE_NAMED && match_name) ? find_enum_def(enum_defs, num_enums, match_name) : NULL;
            for (int i = 0; i < e->value.match_expr.num_arms; i++) {
                ASTMatchArm *arm = &e->value.match_expr.arms[i];
                if (arm->is_enum_variant) {
                    if (!match_enum) {
                        TYPECK_ERR(e, "enum variant pattern requires matched expression to be an enum type");
                        return -1;
                    }
                    if (!arm->enum_name || strcmp(arm->enum_name, match_name) != 0) {
                        TYPECK_ERR(e, "match arm enum type must match matched expression type");
                        return -1;
                    }
                    int idx = enum_variant_index(match_enum, arm->variant_name);
                    if (idx < 0) {
                        TYPECK_ERR_AT(arm->result ? arm->result->line : 0, arm->result ? arm->result->col : 0, "enum '%s' has no variant '%s'", arm->enum_name, arm->variant_name ? arm->variant_name : "");
                        return -1;
                    }
                    arm->variant_index = idx;
                }
                if (typeck_expr_sym(arm->result, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            }
            return 0;
        }
        case AST_EXPR_FIELD_ACCESS: {
            /* module.func 或 arch.x86_64.func 形式：base 为 import 的模块名或嵌套路径时，在依赖模块中按函数名解析 */
            if (e->value.field_access.base && e->value.field_access.field_name
                && m && m->import_paths && typeck_dep_mods && typeck_num_deps > 0) {
                char path_buf[128];
                int path_len = expr_to_import_path(e->value.field_access.base, path_buf, sizeof(path_buf));
                if (path_len >= 0) {
                    path_buf[path_len] = '\0';
                    const char *fn_name = e->value.field_access.field_name;
                    for (int j = 0; j < m->num_imports && j < typeck_num_deps; j++) {
                        if (!import_module_ref_matches(m, j, path_buf)) continue;
                        struct ASTModule *dm = typeck_dep_mods[j];
                        if (!dm || !dm->funcs) continue;
                        for (int i = 0; i < dm->num_funcs; i++) {
                            if (!dm->funcs[i]) continue;
                            if (dm->funcs[i]->name && strcmp(dm->funcs[i]->name, fn_name) == 0) {
                                if (dm->funcs[i]->return_type)
                                    ((struct ASTExpr *)e)->resolved_type = dm->funcs[i]->return_type;
                                return 0;
                            }
                        }
                    }
                    if (typeck_field_access_import_const((struct ASTExpr *)e, m, path_buf))
                        return 0;
                    /* base 为单 VAR 时可能是子模块引用（如 arch.x86_64）；若完整路径 mod.field 为某 import，则接受 */
                    if (e->value.field_access.base->kind == AST_EXPR_VAR && e->value.field_access.base->value.var.name) {
                        size_t plen = (size_t)path_len;
                        if (plen + 1 + strlen(fn_name) < sizeof(path_buf)) {
                            path_buf[plen] = '.';
                            strcpy(path_buf + plen + 1, fn_name);
                            for (int j = 0; j < m->num_imports; j++) {
                                if (m->import_paths[j] && strcmp(m->import_paths[j], path_buf) == 0)
                                    return 0;
                            }
                        }
                    }
                }
            }
            /* Type.Variant 形式：base 为标识符且为枚举类型名时，按枚举变体处理（§7.4）；含跨模块 import 的枚举 */
            if (e->value.field_access.base->kind == AST_EXPR_VAR && e->value.field_access.base->value.var.name) {
                const char *type_name = e->value.field_access.base->value.var.name;
                const struct ASTEnumDef *ed = find_enum_def_with_deps(enum_defs, num_enums, type_name);
                if (ed) {
                    const char *vname = e->value.field_access.field_name;
                    if (enum_variant_index(ed, vname) >= 0) {
                        ((struct ASTExpr *)e)->value.field_access.is_enum_variant = 1;
                        return 0;
                    }
                    TYPECK_ERR_AT(e->line, e->col, "enum '%s' has no variant '%s'", type_name, vname ? vname : "");
                    return -1;
                }
            }
            if (typeck_expr_sym(e->value.field_access.base, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            /* base 为模块引用（VAR 或嵌套 FIELD 且无 resolved_type）时，按 module.func 或 arch.x86_64.func 在依赖中解析 */
            if (!e->value.field_access.base->resolved_type && e->value.field_access.base && e->value.field_access.field_name
                && m && m->import_paths && typeck_dep_mods && typeck_num_deps > 0) {
                char path_buf2[128];
                int path_len2 = expr_to_import_path(e->value.field_access.base, path_buf2, sizeof(path_buf2));
                if (path_len2 >= 0) {
                    path_buf2[path_len2] = '\0';
                    const char *fn_name = e->value.field_access.field_name;
                    for (int j = 0; j < m->num_imports && j < typeck_num_deps; j++) {
                        if (!import_module_ref_matches(m, j, path_buf2)) continue;
                        struct ASTModule *dm = typeck_dep_mods[j];
                        if (!dm || !dm->funcs) continue;
                        for (int i = 0; i < dm->num_funcs; i++) {
                            if (!dm->funcs[i]) continue;
                            if (dm->funcs[i]->name && strcmp(dm->funcs[i]->name, fn_name) == 0) {
                                if (dm->funcs[i]->return_type)
                                    ((struct ASTExpr *)e)->resolved_type = dm->funcs[i]->return_type;
                                return 0;
                            }
                        }
                    }
                    if (typeck_field_access_import_const((struct ASTExpr *)e, m, path_buf2))
                        return 0;
                    /* 未找到函数时，若 base 为 VAR，可能是子模块引用（arch.x86_64）；若 path.field 为某 import 则接受 */
                    if (e->value.field_access.base->kind == AST_EXPR_VAR && path_len2 + 1 + (int)strlen(fn_name) < (int)sizeof(path_buf2)) {
                        path_buf2[path_len2] = '.';
                        strcpy(path_buf2 + path_len2 + 1, fn_name);
                        for (int j = 0; j < m->num_imports; j++) {
                            if (m->import_paths[j] && strcmp(m->import_paths[j], path_buf2) == 0)
                                return 0;
                        }
                    }
                }
            }
            int base_kind;
            const char *base_name = NULL;
            if (get_expr_type(e->value.field_access.base, names, type_kinds, type_names, n, type_ptrs, struct_defs, num_structs, enum_defs, num_enums, &base_kind, &base_name, NULL) != 0) {
                TYPECK_ERR(e, "field access base has no struct or slice type");
                return -1;
            }
            /* 切片 []T 支持 .length（usize）与 .data（*elem_type；C 侧 struct 为 data/length） */
            if (base_kind == AST_TYPE_SLICE) {
                const char *field = e->value.field_access.field_name;
                const struct ASTType *base_type = e->value.field_access.base->resolved_type;
                if (field && strcmp(field, "length") == 0) {
                    ((struct ASTExpr *)e)->resolved_type = &static_type_usize;
                    return 0;
                }
                if (field && strcmp(field, "data") == 0) {
                    if (!base_type || base_type->kind != AST_TYPE_SLICE || !base_type->elem_type) {
                        TYPECK_ERR(e, "slice .data requires resolved slice type");
                        return -1;
                    }
                    /* []u8.data → *u8；[]i32.data → *i32；[]u64.data → *u64（CORE-004/157 subslice） */
                    if (base_type->elem_type->kind == AST_TYPE_U8) {
                        ((struct ASTExpr *)e)->resolved_type = &static_type_ptr_u8;
                        return 0;
                    }
                    if (base_type->elem_type->kind == AST_TYPE_I32) {
                        ((struct ASTExpr *)e)->resolved_type = &static_type_ptr_i32;
                        return 0;
                    }
                    if (base_type->elem_type->kind == AST_TYPE_U64) {
                        ((struct ASTExpr *)e)->resolved_type = &static_type_ptr_u64;
                        return 0;
                    }
                    TYPECK_ERR(e, "slice .data currently only supported for []u8, []i32 and []u64");
                    return -1;
                }
                TYPECK_ERR(e, "slice only has fields 'length' and 'data'");
                return -1;
            }
            /* 自举：允许指针到结构体 p.field，按 pointee 结构体查字段（如 arena: *ASTArena 时 arena.num_types） */
            if ((base_kind != AST_TYPE_NAMED || !base_name) && base_kind == AST_TYPE_PTR
                && e->value.field_access.base->kind == AST_EXPR_VAR && type_ptrs) {
                const char *var_name = e->value.field_access.base->value.var.name;
                for (int vi = 0; vi < n && var_name && names[vi]; vi++)
                    if (strcmp(names[vi], var_name) == 0 && type_ptrs[vi] && type_ptrs[vi]->kind == AST_TYPE_PTR
                        && type_ptrs[vi]->elem_type && type_ptrs[vi]->elem_type->kind == AST_TYPE_NAMED
                        && type_ptrs[vi]->elem_type->name) {
                        base_name = type_ptrs[vi]->elem_type->name;
                        base_kind = AST_TYPE_NAMED;
                        break;
                    }
            }
            if (base_kind != AST_TYPE_NAMED || !base_name) {
                TYPECK_ERR(e, "field access requires struct type");
                return -1;
            }
            /* DOD-S1：arr[i].field — base 为 INDEX 且数组元素为 soa struct */
            if (e->value.field_access.base->kind == AST_EXPR_INDEX) {
                const struct ASTExpr *ix = e->value.field_access.base;
                const struct ASTType *arr_ty = ix->value.index.base && ix->value.index.base->resolved_type
                    ? ix->value.index.base->resolved_type : NULL;
                if (arr_ty && arr_ty->kind == AST_TYPE_ARRAY && arr_ty->elem_type
                    && arr_ty->elem_type->kind == AST_TYPE_NAMED && arr_ty->elem_type->name) {
                    const struct ASTStructDef *sd_arr = find_struct_def_with_deps(struct_defs, num_structs, arr_ty->elem_type->name);
                    const char *field = e->value.field_access.field_name;
                    if (sd_arr && sd_arr->soa && field) {
                        int N = arr_ty->array_size;
                        int fi;
                        for (fi = 0; fi < sd_arr->num_fields; fi++) {
                            if (!sd_arr->fields[fi].name || strcmp(sd_arr->fields[fi].name, field) != 0)
                                continue;
                            int col = 0;
                            int j;
                            for (j = 0; j < fi; j++) {
                                const struct ASTType *fty = sd_arr->fields[j].type;
                                int fsize = fty ? type_size_of(fty, struct_defs, num_structs, enum_defs, num_enums) : 0;
                                int A = fty ? type_align_of(fty, struct_defs, num_structs, enum_defs, num_enums) : 1;
                                if (A <= 0) A = 1;
                                if (fsize <= 0) fsize = 4;
                                col += (A - (col % A)) % A;
                                col += N * fsize;
                            }
                            int stride = sd_arr->fields[fi].type
                                ? type_size_of(sd_arr->fields[fi].type, struct_defs, num_structs, enum_defs, num_enums) : 0;
                            if (stride <= 0) stride = 4;
                            if (sd_arr->fields[fi].type)
                                ((struct ASTExpr *)e)->resolved_type = sd_arr->fields[fi].type;
                            ((struct ASTExpr *)e)->value.field_access.field_offset = col;
                            ((struct ASTExpr *)e)->value.field_access.field_soa_stride = stride;
                            return 0;
                        }
                    }
                }
            }
            const struct ASTStructDef *sd = find_struct_def_with_deps(struct_defs, num_structs, base_name);
            if (!sd) {
                TYPECK_ERR(e, "unknown struct type '%s'", base_name);
                return -1;
            }
            const char *field = e->value.field_access.field_name;
            for (int i = 0; i < sd->num_fields; i++)
                if (sd->fields[i].name && field && strcmp(sd->fields[i].name, field) == 0) {
                    if (sd->fields[i].type)
                        ((struct ASTExpr *)e)->resolved_type = sd->fields[i].type;
                    ((struct ASTExpr *)e)->value.field_access.field_offset = sd->field_offsets[i];
                    return 0;
                }
            TYPECK_ERR(e, "struct '%s' has no field '%s'", base_name, field ? field : "");
            return -1;
        }
        case AST_EXPR_STRUCT_LIT: {
            const char *lit_name = e->value.struct_lit.struct_name;
            const struct ASTStructDef *sd = NULL;
            if (lit_name && strchr(lit_name, '.') && typeck_current_mod)
                sd = find_struct_def_binding_qualified(typeck_current_mod, lit_name);
            if (!sd)
                sd = find_struct_def_with_deps(struct_defs, num_structs, lit_name);
            if (!sd) {
                TYPECK_ERR(e, "unknown struct type '%s'", e->value.struct_lit.struct_name ? e->value.struct_lit.struct_name : "");
                return -1;
            }
            {
                int nf = (int)e->value.struct_lit.num_fields;
                /* 零字段结构体：`struct S {}` 的空字面量 `S {}` 合法；有字段但未写初值仍为错误（保持原报错）。 */
                if (nf <= 0) {
                    if (sd->num_fields > 0) {
                        TYPECK_ERR(e, "struct literal has no fields for '%s'", sd->name);
                        return -1;
                    }
                    if (sd->name) {
                        const char *ty_name = struct_lit_resolved_type_name(sd, e->value.struct_lit.struct_name);
                        int ci;
                        for (ci = 0; ci < struct_lit_type_n; ci++)
                            if (struct_lit_type_names[ci] && ty_name && strcmp(struct_lit_type_names[ci], ty_name) == 0) break;
                        if (ci >= struct_lit_type_n && struct_lit_type_n < MAX_STRUCT_LIT_TYPES) {
                            ci = struct_lit_type_n++;
                            struct_lit_type_cache[ci].kind = AST_TYPE_NAMED;
                            struct_lit_type_cache[ci].name = ty_name;
                            struct_lit_type_cache[ci].elem_type = NULL;
                            struct_lit_type_cache[ci].array_size = 0;
                            struct_lit_type_names[ci] = ty_name;
                        }
                        if (ci < struct_lit_type_n)
                            ((struct ASTExpr *)e)->resolved_type = &struct_lit_type_cache[ci];
                    }
                    return 0;
                }
                if (nf > sd->num_fields) {
                    TYPECK_ERR(e, "struct literal field count mismatch for '%s'", sd->name);
                    return -1;
                }
                /* 允许指定初值子集（与 codegen 的 designated initializer 一致）；按字段名在 sd 中查找，不要求写满、不要求声明顺序 */
                for (int ii = 0; ii < nf; ii++) {
                    for (int kk = ii + 1; kk < nf; kk++) {
                        if (e->value.struct_lit.field_names[ii] && e->value.struct_lit.field_names[kk] &&
                            strcmp(e->value.struct_lit.field_names[ii], e->value.struct_lit.field_names[kk]) == 0) {
                            TYPECK_ERR(e, "duplicate field in struct literal: '%s'", e->value.struct_lit.field_names[ii]);
                            return -1;
                        }
                    }
                }
                for (int i = 0; i < nf; i++) {
                    const char *lit_fn = e->value.struct_lit.field_names[i];
                    if (!lit_fn) {
                        TYPECK_ERR(e, "struct literal missing field name at %d", i);
                        return -1;
                    }
                    int fj = -1;
                    for (int j = 0; j < sd->num_fields; j++) {
                        if (sd->fields[j].name && strcmp(lit_fn, sd->fields[j].name) == 0) {
                            fj = j;
                            break;
                        }
                    }
                    if (fj < 0) {
                        TYPECK_ERR(e, "struct '%s' has no field '%s'", sd->name, lit_fn);
                        return -1;
                    }
                    if (typeck_expr_sym(e->value.struct_lit.inits[i], names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0)
                        return -1;
                    if (sd->fields[fj].type)
                        ((struct ASTExpr *)e->value.struct_lit.inits[i])->resolved_type = sd->fields[fj].type;
                }
            }
            /* 为结构体字面量本身设 resolved_type（AST_TYPE_NAMED），供 if-expr/嵌套 else 推断 __tmp 类型，从源头消除 int __tmp 却赋 (struct X){0} 的补丁 */
            if (sd->name) {
                const char *ty_name = struct_lit_resolved_type_name(sd, e->value.struct_lit.struct_name);
                int ci;
                for (ci = 0; ci < struct_lit_type_n; ci++)
                    if (struct_lit_type_names[ci] && ty_name && strcmp(struct_lit_type_names[ci], ty_name) == 0) break;
                if (ci >= struct_lit_type_n && struct_lit_type_n < MAX_STRUCT_LIT_TYPES) {
                    ci = struct_lit_type_n++;
                    struct_lit_type_cache[ci].kind = AST_TYPE_NAMED;
                    struct_lit_type_cache[ci].name = ty_name;
                    struct_lit_type_cache[ci].elem_type = NULL;
                    struct_lit_type_cache[ci].array_size = 0;
                    struct_lit_type_names[ci] = ty_name;
                }
                if (ci < struct_lit_type_n)
                    ((struct ASTExpr *)e)->resolved_type = &struct_lit_type_cache[ci];
            }
            return 0;
        }
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++) {
                if (typeck_expr_sym(e->value.array_lit.elems[i], names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            }
            return 0;
        case AST_EXPR_INDEX: {
            if (typeck_expr_sym(e->value.index.base, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            if (typeck_expr_sym(e->value.index.index_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            int base_kind;
            const char *base_name = NULL;
            if (get_expr_type(e->value.index.base, names, type_kinds, type_names, n, type_ptrs, struct_defs, num_structs, enum_defs, num_enums, &base_kind, &base_name, NULL) != 0) {
                TYPECK_ERR(e, "subscript base must be array, slice or pointer");
                return -1;
            }
            if (base_kind != AST_TYPE_ARRAY && base_kind != AST_TYPE_SLICE && base_kind != AST_TYPE_PTR && base_kind != AST_TYPE_VECTOR) {
                /* SIMD-S4：Vec4f/Vec8i 形参/变量 lane 下标（hsum4 等）；parser 将 Vec4f 存为 TYPE_NAMED。 */
                if (base_kind == AST_TYPE_NAMED && base_name &&
                    (strcmp(base_name, "Vec4f") == 0 || strcmp(base_name, "f32x4") == 0)) {
                    ((struct ASTExpr *)e)->resolved_type = &static_type_f32;
                    return 0;
                }
                if (base_kind == AST_TYPE_NAMED && base_name &&
                    (strcmp(base_name, "Vec8i") == 0 || strcmp(base_name, "i32x8") == 0)) {
                    ((struct ASTExpr *)e)->resolved_type = &static_type_i32;
                    return 0;
                }
                TYPECK_ERR(e, "subscript base must be array, slice or pointer type");
                return -1;
            }
            ((struct ASTExpr *)e)->value.index.base_is_slice = (base_kind == AST_TYPE_SLICE);
            /* BCE：下标为字面量 0 且 base 为长度≥1 的数组时，可证明在界内，codegen 可省略边界检查 */
            {
                const struct ASTExpr *idx = e->value.index.index_expr;
                const struct ASTType *base_ty = e->value.index.base->resolved_type;
                if (idx->kind == AST_EXPR_LIT && idx->value.int_val == 0 && base_ty &&
                    (base_ty->kind == AST_TYPE_ARRAY || base_ty->kind == AST_TYPE_VECTOR) && base_ty->array_size >= 1)
                    ((struct ASTExpr *)e)->index_proven_in_bounds = 1;
            }
            /* BCE 扩展：循环内值域——若下标为变量且在当前 for 的 [0, bound) 上下文中，且 base 长度与 bound 一致则标为在界内 */
            if (!((struct ASTExpr *)e)->index_proven_in_bounds && e->value.index.index_expr->kind == AST_EXPR_VAR) {
                const char *idx_name = e->value.index.index_expr->value.var.name;
                const struct ASTType *base_ty = e->value.index.base->resolved_type;
                for (int k = 0; k < bce_n && idx_name; k++) {
                    if (!bce_var_names[k] || strcmp(bce_var_names[k], idx_name) != 0) continue;
                    if (bce_bound_const[k]) {
                        if (base_ty && base_ty->kind == AST_TYPE_ARRAY && base_ty->array_size == bce_bound_val[k])
                            ((struct ASTExpr *)e)->index_proven_in_bounds = 1;
                        break;
                    }
                    if (base_kind == AST_TYPE_SLICE && bce_bound_base[k] &&
                        e->value.index.base == bce_bound_base[k])
                        ((struct ASTExpr *)e)->index_proven_in_bounds = 1;
                    break;
                }
            }
            /* 下标表达式类型为数组/切片/指针的元素类型（供实参匹配等使用） */
            {
                const struct ASTType *base_ty = e->value.index.base->resolved_type;
                if (base_ty && (base_ty->kind == AST_TYPE_ARRAY || base_ty->kind == AST_TYPE_SLICE || base_ty->kind == AST_TYPE_PTR) && base_ty->elem_type)
                    ((struct ASTExpr *)e)->resolved_type = base_ty->elem_type;
            }
            return 0;
        }
        case AST_EXPR_CALL: {
            const char *callee_name = NULL;
            struct ASTFunc *func = NULL;
            int from_dep = -1;
            struct ASTModule *func_mod = (struct ASTModule *)m;
            /* 先 typecheck 实参，供 overload 按类型选取 */
            for (int ai = 0; ai < e->value.call.num_args; ai++) {
                if (typeck_expr_sym(e->value.call.args[ai], names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0)
                    return -1;
            }
            /* module.func：在依赖模块内 overload / 泛型解析 */
            if (e->value.call.callee->kind == AST_EXPR_FIELD_ACCESS
                && e->value.call.callee->value.field_access.base
                && e->value.call.callee->value.field_access.field_name
                && m && m->import_paths && typeck_dep_mods && typeck_num_deps > 0) {
                char call_path_buf[128];
                int call_path_len = expr_to_import_path(e->value.call.callee->value.field_access.base, call_path_buf, sizeof(call_path_buf));
                if (call_path_len >= 0) {
                    call_path_buf[call_path_len] = '\0';
                    callee_name = e->value.call.callee->value.field_access.field_name;
                    for (int j = 0; j < m->num_imports && j < typeck_num_deps; j++) {
                        if (!import_module_ref_matches(m, j, call_path_buf)) continue;
                        struct ASTModule *dm = typeck_dep_mods[j];
                        if (!dm) continue;
                        if (e->value.call.num_type_args > 0) {
                            if (typeck_find_generic_func_in_module(dm, callee_name, &func) == 0) {
                                from_dep = j;
                                func_mod = dm;
                                break;
                            }
                        } else if (typeck_pick_overload_in_module(dm, callee_name, (struct ASTExpr *)e, &func) == 0) {
                            from_dep = j;
                            func_mod = dm;
                            break;
                        }
                    }
                }
            }
            /* 普通函数名：本模块 → 依赖模块 overload / 泛型解析 */
            if (!func && e->value.call.callee->kind == AST_EXPR_VAR) {
                callee_name = e->value.call.callee->value.var.name;
                if (e->value.call.num_type_args > 0) {
                    if (m && typeck_find_generic_func_in_module(m, callee_name, &func) != 0)
                        func = NULL;
                    if (!func && typeck_dep_mods && typeck_num_deps > 0) {
                        for (int j = 0; j < typeck_num_deps; j++) {
                            if (!import_exports_name(m, j, callee_name)) continue;
                            struct ASTModule *dm = typeck_dep_mods[j];
                            if (!dm) continue;
                            const char *dep_fn = callee_name;
                            const char *src = import_select_source_for_local(m, j, callee_name);
                            if (src) dep_fn = src;
                            if (typeck_find_generic_func_in_module(dm, dep_fn, &func) == 0) {
                                from_dep = j;
                                func_mod = dm;
                                break;
                            }
                        }
                    }
                    if (!func && m)
                        typeck_find_generic_func_in_binding_deps(m, callee_name, &func, &from_dep);
                } else {
                    if (m && typeck_pick_overload_in_module(m, callee_name, (struct ASTExpr *)e, &func) != 0)
                        func = NULL;
                    if (!func && m && typeck_find_func_in_module_by_name(m, callee_name,
                            e->value.call.num_args, e->value.call.args, &func) != 0)
                        func = NULL;
                    if (!func && typeck_dep_mods && typeck_num_deps > 0) {
                        for (int j = 0; j < typeck_num_deps; j++) {
                            if (!import_exports_name(m, j, callee_name)) continue;
                            struct ASTModule *dm = typeck_dep_mods[j];
                            if (!dm) continue;
                            const char *dep_fn = callee_name;
                            const char *src = import_select_source_for_local(m, j, callee_name);
                            if (src) dep_fn = src;
                            if (typeck_pick_overload_in_module(dm, dep_fn, (struct ASTExpr *)e, &func) == 0) {
                                from_dep = j;
                                func_mod = dm;
                                break;
                            }
                        }
                    }
                    if (!func && m)
                        typeck_find_func_in_binding_deps(m, callee_name, e->value.call.num_args,
                            e->value.call.args, &func, &from_dep);
                }
            }
            if (!func) {
                if (e->value.call.callee->kind != AST_EXPR_VAR && e->value.call.callee->kind != AST_EXPR_FIELD_ACCESS) {
                    TYPECK_ERR(e, "call callee must be a function name");
                    return -1;
                }
                if (e->value.call.num_type_args > 0) {
                    TYPECK_ERR(e, "generic function '%s' not found", callee_name ? callee_name : "");
                } else {
                    TYPECK_ERR(e, "no matching overload for '%s'", callee_name ? callee_name : "");
                }
                return -1;
            }
            ((struct ASTExpr *)e)->value.call.resolved_callee_func = func;
            if (from_dep >= 0)
                ((struct ASTExpr *)e)->value.call.resolved_import_path = m->import_paths[from_dep];
            (void)func_mod;
            if (!typeck_fill_only && func->is_extern && typeck_unsafe_depth <= 0
                && !typeck_allow_legacy_extern_calls) {
                TYPECK_ERR(e, "extern call requires unsafe block");
                return -1;
            }
            /* 泛型调用 f<Type>(args)：要求函数为泛型、类型实参个数一致，登记单态化实例并做代入后类型检查 */
            if (e->value.call.num_type_args > 0) {
                if (func->num_generic_params == 0) {
                    TYPECK_ERR(e, "function '%s' is not generic but type arguments were provided", callee_name ? callee_name : "");
                    return -1;
                }
                if (e->value.call.num_type_args != func->num_generic_params) {
                    TYPECK_ERR(e, "generic function '%s' expects %d type arguments, got %d",
                        callee_name, func->num_generic_params, e->value.call.num_type_args);
                    return -1;
                }
                /* CORE-001：size_of<T>() / align_of<T>() 编译期布局查询（无值实参）。 */
                if (callee_name && e->value.call.num_type_args == 1 && e->value.call.num_args == 0
                    && e->value.call.type_args && e->value.call.type_args[0]
                    && (strcmp(callee_name, "size_of") == 0 || strcmp(callee_name, "align_of") == 0)) {
                    const struct ASTType *ty = e->value.call.type_args[0];
                    int layout_val = (strcmp(callee_name, "size_of") == 0)
                        ? type_size_of(ty, struct_defs, num_structs, enum_defs, num_enums)
                        : type_align_of(ty, struct_defs, num_structs, enum_defs, num_enums);
                    if (layout_val <= 0) {
                        TYPECK_ERR(e, "'%s' does not support the given type argument", callee_name);
                        return -1;
                    }
                    ((struct ASTExpr *)e)->resolved_type = &static_type_i32;
                    return 0;
                }
                /* 在对应模块中登记 (template, type_args)：本模块调用则登记到 m，从 import 调用则登记到 dep（供 codegen 生成单态化体） */
                {
                    struct ASTModule *mod = (from_dep >= 0 && typeck_dep_mods && from_dep < typeck_num_deps)
                        ? typeck_dep_mods[from_dep] : (struct ASTModule *)m;
                    int found = 0;
                    if (mod->mono_instances) {
                        for (int k = 0; k < mod->num_mono_instances; k++) {
                            if (mod->mono_instances[k].template != (struct ASTFunc *)func) continue;
                            if (mod->mono_instances[k].num_type_args != e->value.call.num_type_args) continue;
                            int eq = 1;
                            for (int j = 0; j < e->value.call.num_type_args; j++) {
                                if (!type_equal(mod->mono_instances[k].type_args[j], e->value.call.type_args[j])) { eq = 0; break; }
                            }
                            if (eq) { found = 1; break; }
                        }
                    }
                    if (!found) {
                        if (mod->num_mono_instances >= AST_MODULE_MAX_MONO_INSTANCES) {
                            TYPECK_ERR(e, "too many generic instances");
                            return -1;
                        }
                        ASTMonoInstance *new_list = (ASTMonoInstance *)realloc(mod->mono_instances,
                            (size_t)(mod->num_mono_instances + 1) * sizeof(ASTMonoInstance));
                        if (!new_list) {
                            TYPECK_ERR(e, "out of memory for mono instances");
                            return -1;
                        }
                        mod->mono_instances = new_list;
                        mod->mono_instances[mod->num_mono_instances].template = (struct ASTFunc *)func;
                        mod->mono_instances[mod->num_mono_instances].type_args = e->value.call.type_args;
                        mod->mono_instances[mod->num_mono_instances].num_type_args = e->value.call.num_type_args;
                        mod->num_mono_instances++;
                    }
                }
                if (e->value.call.num_args != func->num_params) {
                    TYPECK_ERR(e, "function '%s' expects %d arguments, got %d",
                        callee_name, func->num_params, e->value.call.num_args);
                    return -1;
                }
                for (int i = 0; i < e->value.call.num_args; i++) {
                    if (typeck_expr_sym(e->value.call.args[i], names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
                    const struct ASTType *arg_type = e->value.call.args[i]->resolved_type;
                    const struct ASTType *param_type = func->params[i].type;
                    if (!typeck_fill_only && typeck_check_slice_region_assign(e->value.call.args[i], param_type, arg_type) != 0)
                        return -1;
                    if (!arg_type || !param_type || !type_equal_subst(param_type, arg_type,
                            func->generic_param_names, e->value.call.type_args, e->value.call.num_type_args)) {
                        const struct ASTType *exp_ty = get_substituted_return_type(param_type,
                            func->generic_param_names, e->value.call.type_args, e->value.call.num_type_args);
                        char ebuf[80], fbuf[80];
                        type_to_string_buf(exp_ty ? exp_ty : param_type, ebuf, sizeof(ebuf));
                        type_to_string_buf(arg_type, fbuf, sizeof(fbuf));
                        TYPECK_ERR(e->value.call.args[i], "argument %d of '%s' type mismatch: expected %s, found %s",
                            i + 1, callee_name ? callee_name : "", ebuf, fbuf);
                        return -1;
                    }
                }
                if (func->return_type) {
                    const struct ASTType *rt = func->return_type;
                    if (typeck_is_read_ptr_slice_producer(callee_name))
                        rt = &static_type_slice_u8_io_read_ptr;
                    ((struct ASTExpr *)e)->resolved_type = get_substituted_return_type(rt,
                        func->generic_param_names, e->value.call.type_args, e->value.call.num_type_args);
                }
                return 0;
            }
            /* 非泛型调用：不允许调用泛型函数而不提供类型实参 */
            if (func->num_generic_params > 0) {
                TYPECK_ERR(e, "generic function '%s' requires type arguments (e.g. %s<Type>(...))", callee_name ? callee_name : "", callee_name ? callee_name : "");
                return -1;
            }
            if (e->value.call.num_args != func->num_params) {
                TYPECK_ERR(e, "function '%s' expects %d arguments, got %d",
                    callee_name, func->num_params, e->value.call.num_args);
                return -1;
            }
            for (int i = 0; i < e->value.call.num_args; i++) {
                const struct ASTType *arg_type = e->value.call.args[i]->resolved_type;
                const struct ASTType *param_type = func->params[i].type;
                if (!typeck_fill_only && typeck_check_slice_region_assign(e->value.call.args[i], param_type, arg_type) != 0)
                    return -1;
                int ok = (arg_type && param_type && type_equal(arg_type, param_type));
                /* 允许非负整数字面量传给 u32 参数（C 会隐式转换） */
                if (!ok && param_type && param_type->kind == AST_TYPE_U32
                    && e->value.call.args[i]->kind == AST_EXPR_LIT
                    && e->value.call.args[i]->value.int_val >= 0)
                    ok = 1;
                /* 允许非负整数字面量传给 usize 参数（如 fs_read 的 count；C 会隐式转换） */
                if (!ok && param_type && param_type->kind == AST_TYPE_USIZE
                    && e->value.call.args[i]->kind == AST_EXPR_LIT
                    && e->value.call.args[i]->value.int_val >= 0)
                    ok = 1;
                /* 允许整数字面量传给 i64 参数（C 会隐式转换） */
                if (!ok && param_type && param_type->kind == AST_TYPE_I64
                    && e->value.call.args[i]->kind == AST_EXPR_LIT)
                    ok = 1;
                /* 允许 0..255 整数字面量传给 u8 参数（自举 lexer 中 advance_one(l, 47) 等） */
                if (!ok && param_type && param_type->kind == AST_TYPE_U8
                    && e->value.call.args[i]->kind == AST_EXPR_LIT) {
                    int v = e->value.call.args[i]->value.int_val;
                    if (v >= 0 && v <= 255) ok = 1;
                }
                /* 允许 i32 传给 isize/usize 形参（长度/计数；C 会隐式转换）。 */
                if (!ok && param_type && arg_type && arg_type->kind == AST_TYPE_I32
                    && (param_type->kind == AST_TYPE_ISIZE || param_type->kind == AST_TYPE_USIZE))
                    ok = 1;
                /* 允许 f64 浮点字面量传给 f32 参数（默认浮点字面量为 f64，如 vec4f_splat(1.0)） */
                if (!ok && param_type && param_type->kind == AST_TYPE_F32
                    && arg_type && arg_type->kind == AST_TYPE_F64
                    && e->value.call.args[i]->kind == AST_EXPR_FLOAT_LIT) {
                    ok = 1;
                    ((struct ASTExpr *)e->value.call.args[i])->resolved_type = param_type;
                }
                /* 允许数组字面量 [x, y, ...] 传给 []u8 参数（如 match_keyword 的 keyword）；设 resolved_type 为参数类型供 codegen 生成 slice 复合字面量 */
                if (!ok && param_type && param_type->kind == AST_TYPE_SLICE && param_type->elem_type
                    && param_type->elem_type->kind == AST_TYPE_U8
                    && e->value.call.args[i]->kind == AST_EXPR_ARRAY_LIT) {
                    ok = 1;
                    ((struct ASTExpr *)e->value.call.args[i])->resolved_type = param_type;
                }
                /* i32x4 等：固定长度数组字面量传给 vector 形参（WPO vec_const_spec、bench lane0） */
                if (!ok && param_type && param_type->kind == AST_TYPE_VECTOR
                    && e->value.call.args[i]->kind == AST_EXPR_ARRAY_LIT
                    && e->value.call.args[i]->value.array_lit.num_elems == param_type->array_size) {
                    ok = 1;
                    ((struct ASTExpr *)e->value.call.args[i])->resolved_type = param_type;
                }
                /* [N]T 固定数组字面量传给同尺寸数组形参（SIMD-S4 vec4f_shuffle mask: [4]i32） */
                if (!ok && param_type && param_type->kind == AST_TYPE_ARRAY
                    && e->value.call.args[i]->kind == AST_EXPR_ARRAY_LIT
                    && e->value.call.args[i]->value.array_lit.num_elems == param_type->array_size) {
                    ok = 1;
                    ((struct ASTExpr *)e->value.call.args[i])->resolved_type = param_type;
                }
                /* 允许数组 [N]T 传给 *T 参数（数组到指针衰减，如 fs_open_read(path)、fs_read(fd, buf, n)；9.1 联调） */
                if (!ok && param_type && param_type->kind == AST_TYPE_PTR && arg_type && arg_type->kind == AST_TYPE_ARRAY
                    && param_type->elem_type && arg_type->elem_type && type_equal(param_type->elem_type, arg_type->elem_type))
                    ok = 1;
                /* 允许任意指针 *T 传给 *u8 参数（extern 中 *u8 表示 C 的 void*，如 pipeline_run_sx_pipeline 的 out_buf/ctx） */
                if (!ok && param_type && param_type->kind == AST_TYPE_PTR && param_type->elem_type && param_type->elem_type->kind == AST_TYPE_U8
                    && arg_type && arg_type->kind == AST_TYPE_PTR)
                    ok = 1;
                /* 取址 &expr 可传给 *u8 参数（&out、&ctx 等；此时 arg_type 可能尚未设为指针类型） */
                if (!ok && param_type && param_type->kind == AST_TYPE_PTR && param_type->elem_type && param_type->elem_type->kind == AST_TYPE_U8
                    && e->value.call.args[i]->kind == AST_EXPR_ADDR_OF)
                    ok = 1;
                /* 取址 &expr 可传给 *T 参数：要求 expr 的类型与 T 一致（如 driver_argv_parse_sx(..., &state)） */
                if (!ok && param_type && e->value.call.args[i]->kind == AST_EXPR_ADDR_OF) {
                    const struct ASTExpr *operand = e->value.call.args[i]->value.unary.operand;
                    if (operand->resolved_type && type_equal(param_type->elem_type, operand->resolved_type))
                        ok = 1;
                }
                /* 统一隐式转换（含字面量 0→*T、整型拓宽）；与 type_assignable_to 一致。 */
                if (!ok && param_type && type_assignable_to(arg_type, param_type, e->value.call.args[i])) {
                    ok = 1;
                    if (!arg_type || !type_equal(arg_type, param_type))
                        ((struct ASTExpr *)e->value.call.args[i])->resolved_type = param_type;
                }
                if (!ok) {
                    char ebuf[80], fbuf[80];
                    type_to_string_buf(param_type, ebuf, sizeof(ebuf));
                    type_to_string_buf(arg_type, fbuf, sizeof(fbuf));
                    TYPECK_ERR(e->value.call.args[i], "argument %d of '%s' type mismatch: expected %s, found %s",
                        i + 1, callee_name ? callee_name : "", ebuf, fbuf);
                    return -1;
                }
            }
            if (func->return_type) {
                const struct ASTType *rt = func->return_type;
                if (typeck_is_read_ptr_slice_producer(callee_name))
                    rt = &static_type_slice_u8_io_read_ptr;
                ((struct ASTExpr *)e)->resolved_type = rt;
            }
            return 0;
        }
        case AST_EXPR_METHOD_CALL: {
            if (typeck_expr_sym(e->value.method_call.base, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            const struct ASTType *base_ty = e->value.method_call.base->resolved_type;
            const char *method_name = e->value.method_call.method_name;
            /* module.func 或 arch.x86_64.func 形式：base 为模块引用（VAR 或嵌套 FIELD 且无 resolved_type）时，在依赖中按函数名解析 */
            if (!base_ty && e->value.method_call.base && method_name
                && m && m->import_paths && typeck_dep_mods && typeck_num_deps > 0) {
                char meth_path_buf[128];
                int meth_path_len = expr_to_import_path(e->value.method_call.base, meth_path_buf, sizeof(meth_path_buf));
                if (meth_path_len >= 0) {
                    meth_path_buf[meth_path_len] = '\0';
                    for (int ai = 0; ai < e->value.method_call.num_args; ai++) {
                        if (typeck_expr_sym(e->value.method_call.args[ai], names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0)
                            return -1;
                    }
                    for (int j = 0; j < m->num_imports && j < typeck_num_deps; j++) {
                        if (!import_module_ref_matches(m, j, meth_path_buf)) continue;
                        struct ASTModule *dm = typeck_dep_mods[j];
                        struct ASTFunc *func = NULL;
                        if (!dm || typeck_pick_overload_in_module_ex(dm, method_name,
                                e->value.method_call.num_args, e->value.method_call.args,
                                (struct ASTExpr *)e, &func) != 0)
                            continue;
                        for (int ai = 0; ai < e->value.method_call.num_args; ai++) {
                            const struct ASTType *arg_type = e->value.method_call.args[ai]->resolved_type;
                            const struct ASTType *param_type = func->params[ai].type;
                            if ((!arg_type || !type_assignable_to(arg_type, param_type, e->value.method_call.args[ai]))
                                && param_type && param_type->kind == AST_TYPE_PTR && param_type->elem_type
                                && e->value.method_call.args[ai]->kind == AST_EXPR_ADDR_OF
                                && e->value.method_call.args[ai]->value.unary.operand) {
                                const struct ASTExpr *operand = e->value.method_call.args[ai]->value.unary.operand;
                                if (operand->resolved_type && type_equal(param_type->elem_type, operand->resolved_type)) {
                                    ((struct ASTExpr *)e->value.method_call.args[ai])->resolved_type = param_type;
                                    arg_type = param_type;
                                }
                            }
                            if ((!arg_type || !type_assignable_to(arg_type, param_type, e->value.method_call.args[ai]))
                                && param_type && param_type->kind == AST_TYPE_PTR && arg_type && arg_type->kind == AST_TYPE_ARRAY
                                && param_type->elem_type && arg_type->elem_type
                                && type_equal(param_type->elem_type, arg_type->elem_type)) {
                                ((struct ASTExpr *)e->value.method_call.args[ai])->resolved_type = param_type;
                                arg_type = param_type;
                            }
                            if (!arg_type || !param_type || !type_assignable_to(arg_type, param_type, e->value.method_call.args[ai])) {
                                TYPECK_ERR(e->value.method_call.args[ai], "argument %d of '%s' type mismatch", ai + 1, method_name ? method_name : "");
                                return -1;
                            }
                        }
                        if (func->return_type)
                            ((struct ASTExpr *)e)->resolved_type = func->return_type;
                        ((struct ASTExpr *)e)->value.method_call.resolved_impl_func = func;
                        ((struct ASTExpr *)e)->value.method_call.resolved_import_path = m->import_paths[j];
                        return 0;
                    }
                }
            }
            if (!base_ty) {
                TYPECK_ERR(e, "method call base has no type");
                return -1;
            }
            const char *type_str = type_to_name_string(base_ty);
            struct ASTFunc *impl_func = NULL;
            if (m && m->impl_blocks) {
                for (int k = 0; k < m->num_impl_blocks; k++) {
                    if (!m->impl_blocks[k]->type_name || strcmp(m->impl_blocks[k]->type_name, type_str) != 0) continue;
                    for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
                        if (m->impl_blocks[k]->funcs[j]->name && method_name && strcmp(m->impl_blocks[k]->funcs[j]->name, method_name) == 0) {
                            impl_func = m->impl_blocks[k]->funcs[j];
                            break;
                        }
                    }
                    if (impl_func) break;
                }
            }
            if (!impl_func) {
                TYPECK_ERR(e, "no impl for type '%s' with method '%s'", type_str ? type_str : "?", method_name ? method_name : "?");
                return -1;
            }
            /* impl 方法首参为 self，实参仅对应 params[1..] */
            int num_params_no_self = impl_func->num_params - 1;
            if (e->value.method_call.num_args != num_params_no_self) {
                TYPECK_ERR(e, "method '%s' expects %d arguments, got %d",
                    method_name, num_params_no_self, e->value.method_call.num_args);
                return -1;
            }
            for (int i = 0; i < e->value.method_call.num_args; i++) {
                if (typeck_expr_sym(e->value.method_call.args[i], names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
                const struct ASTType *arg_type = e->value.method_call.args[i]->resolved_type;
                const struct ASTType *param_type = impl_func->params[i + 1].type;
                if (!arg_type || !param_type || !type_equal(arg_type, param_type)) {
                    TYPECK_ERR(e->value.method_call.args[i], "argument %d of method '%s' type mismatch", i + 1, method_name ? method_name : "");
                    return -1;
                }
            }
            ((struct ASTExpr *)e)->resolved_type = impl_func->return_type;
            ((struct ASTExpr *)e)->value.method_call.resolved_impl_func = impl_func;
            return 0;
        }
        default:
            TYPECK_ERR(e, "unsupported expression kind");
            return -1;
    }
}

/**
 * 检查 return 操作数类型是否与函数返回类型一致。
 * bool→i32 仅允许 `return !expr` 与 bool 字面量；`return x`（x: bool）拒绝（return_operand_type_mismatch）。
 * 返回值：1 匹配；0 不匹配（含 got 未解析）。
 */
static int typeck_return_value_matches(const struct ASTExpr *op, const struct ASTType *expect) {
    const struct ASTType *got;
    if (!op || !expect)
        return 1;
    got = op->resolved_type;
    if (!got)
        return 0;
    if (type_equal(got, expect))
        return 1;
    if (expect->kind == AST_TYPE_I32 && got->kind == AST_TYPE_BOOL) {
        if (op->kind == AST_EXPR_LOGNOT || op->kind == AST_EXPR_BOOL_LIT)
            return 1;
        return 0;
    }
    return 0;
}

/**
 * return 操作数与函数签名不一致时打印 typeck error 并返回 -1。
 */
static int typeck_check_return_operand(const struct ASTExpr *ret_site, const struct ASTExpr *op,
                                     const struct ASTType *func_return_type) {
    char ebuf[80], fbuf[80];
    const struct ASTType *got;
    if (!ret_site || !op || !func_return_type || func_return_type->kind != AST_TYPE_I32)
        return 0;
    got = op->resolved_type;
    /* 仅拒绝明确的 bool 变量/字段 return i32；未解析类型与其它不匹配留给 .sx typeck 或后续扩展。 */
    if (!got || got->kind != AST_TYPE_BOOL)
        return 0;
    if (typeck_return_value_matches(op, func_return_type))
        return 0;
    type_to_string_buf(func_return_type, ebuf, sizeof(ebuf));
    type_to_string_buf(got, fbuf, sizeof(fbuf));
    TYPECK_ERR(ret_site, "return expression type mismatch: expected %s, found %s", ebuf, fbuf);
    return -1;
}

/**
 * 判断块是否以「裸的最终表达式」作为返回值（即未写 return，仅写 0 等表达式）。
 * 约定：返回值统一使用 return expr;，不允许以块尾表达式隐式作为返回值。
 * 返回值：1 表示块有 final_expr 且非 return/panic/break/continue（即隐式返回值）；0 表示无或为控制流。
 */
static int block_has_implicit_return(const struct ASTBlock *b) {
    if (!b || !b->final_expr) return 0;
    switch (b->final_expr->kind) {
        case AST_EXPR_RETURN:
        case AST_EXPR_PANIC:
        case AST_EXPR_BREAK:
        case AST_EXPR_CONTINUE:
            return 0;
        default:
            return 1;
    }
}

/**
 * let/const 初值：声明为 slice、初值为同 elem 的 array 变量时，将 init->resolved_type 设为 slice 类型。
 * 返回值：0 成功或非此场景；非 0 则已写 typeck 错误。
 */
static int typeck_coerce_array_var_to_slice_type(struct ASTExpr *init, const struct ASTType *slice_ty,
    const char **names, int n, const struct ASTType **type_ptrs) {
    const char *vname;
    int j;
    if (!slice_ty || slice_ty->kind != AST_TYPE_SLICE || !init || init->kind != AST_EXPR_VAR)
        return 0;
    vname = init->value.var.name;
    for (j = 0; j < n; j++) {
        const struct ASTType *arr;
        if (!names[j] || !vname || strcmp(names[j], vname) != 0)
            continue;
        arr = (type_ptrs && j < n) ? type_ptrs[j] : NULL;
        if (!arr || arr->kind != AST_TYPE_ARRAY)
            return 0;
        if (!arr->elem_type || !slice_ty->elem_type)
            break;
        if (arr->elem_type->kind != slice_ty->elem_type->kind)
            break;
        if (arr->elem_type->kind == AST_TYPE_NAMED &&
            (!arr->elem_type->name || !slice_ty->elem_type->name ||
             strcmp(arr->elem_type->name, slice_ty->elem_type->name) != 0))
            break;
        init->resolved_type = slice_ty;
        return 0;
    }
    TYPECK_ERR_AT(0, 0, "slice init must be array variable with matching element type");
    return -1;
}

/**
 * BCE：从循环条件 var < bound 推断 [0,bound) 值域，供体内 arr[var]/s[var] 省略 INDEX 边界检查。
 * 支持 bound 为字面量、外层 const 变量或 slice.length。
 */
static void typeck_bce_push_lt_cond(const struct ASTExpr *cond,
                                    const char *const *names, int n,
                                    int const_start, int n_consts, const int *const_values)
{
    const struct ASTExpr *left;
    const struct ASTExpr *right;
    int j;

    if (!cond || cond->kind != AST_EXPR_LT || bce_n >= MAX_BCE_RANGES)
        return;
    left = cond->value.binop.left;
    right = cond->value.binop.right;
    if (!left || left->kind != AST_EXPR_VAR || !left->value.var.name)
        return;
    bce_var_names[bce_n] = left->value.var.name;
    if (right && right->kind == AST_EXPR_LIT) {
        bce_bound_const[bce_n] = 1;
        bce_bound_val[bce_n] = right->value.int_val;
        bce_bound_base[bce_n] = NULL;
        bce_n++;
        return;
    }
    if (right && right->kind == AST_EXPR_VAR && right->value.var.name) {
        for (j = 0; j < n && (!names[j] || strcmp(names[j], right->value.var.name) != 0); j++)
            ;
        if (j < n && j >= const_start && j < const_start + n_consts) {
            bce_bound_const[bce_n] = 1;
            bce_bound_val[bce_n] = const_values[j];
            bce_bound_base[bce_n] = NULL;
            bce_n++;
        }
        return;
    }
    if (right && right->kind == AST_EXPR_FIELD_ACCESS && right->value.field_access.field_name &&
        strcmp(right->value.field_access.field_name, "length") == 0 && right->value.field_access.base) {
        bce_bound_const[bce_n] = 0;
        bce_bound_val[bce_n] = 0;
        bce_bound_base[bce_n] = right->value.field_access.base;
        bce_n++;
    }
}

/**
 * 对块做类型检查；parent_names/... 为外层符号表；parent_const_values/parent_n_consts 为外层 const 求值结果（CTFE）；inside_loop 表示当前块是否为某 while 体。
 */
static int typeck_block(const struct ASTBlock *b, const char **parent_names,
    const int *parent_type_kinds, const char **parent_type_names, const struct ASTType **parent_type_ptrs, int parent_n,
    const int *parent_const_values, int parent_n_consts,
    int inside_loop,
    struct ASTStructDef **struct_defs, int num_structs, struct ASTEnumDef **enum_defs, int num_enums, const struct ASTModule *m,
    const struct ASTType *func_return_type, const char *scope_region) {
    if (!b) return -1;
    /* 允许空块 {}（如 if (x) { } 的 then 体）；仅当块完全为空且无 final_expr 时放行，不视为错误 */
    if (!b->final_expr && b->num_labeled_stmts == 0 && b->num_expr_stmts == 0
        && b->num_consts == 0 && b->num_lets == 0 && b->num_loops == 0 && b->num_for_loops == 0 && b->num_defers == 0
        && b->num_regions == 0)
        return 0;
    const char *names[MAX_SYMTAB];
    int type_kinds[MAX_SYMTAB];
    const char *type_names[MAX_SYMTAB];
    const struct ASTType *type_ptrs[MAX_SYMTAB];
    int const_values[MAX_SYMTAB]; /* CTFE：当前作用域 const 的求值结果，仅 names[0..n_consts) 为 const */
    int n = parent_n < MAX_SYMTAB ? parent_n : 0;
    for (int i = 0; i < n && parent_names; i++) {
        names[i] = parent_names[i];
        type_kinds[i] = (parent_type_kinds && i < parent_n) ? parent_type_kinds[i] : AST_TYPE_I32;
        type_names[i] = (parent_type_names && i < parent_n) ? parent_type_names[i] : NULL;
        type_ptrs[i] = (parent_type_ptrs && i < parent_n) ? parent_type_ptrs[i] : NULL;
        const_values[i] = (parent_const_values && i < parent_n_consts) ? parent_const_values[i] : 0;
    }
    int const_start = n; /* 当前块 const 在 names 中的起始下标（进入 const 循环前 n = parent_n） */
    int n_consts = 0;
    for (int i = 0; i < b->num_consts; i++) {
        if (n >= MAX_SYMTAB) {
            TYPECK_ERR_AT(0, 0, "too many declarations");
            return -1;
        }
        if (!is_const_expr(b->const_decls[i].init, names, n_consts)) {
            TYPECK_ERR_AT(0, 0, "const init must be constant expression");
            return -1;
        }
        if (typeck_expr_sym(b->const_decls[i].init, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
        if (!typeck_fill_only && b->const_decls[i].type && b->const_decls[i].type->kind == AST_TYPE_SLICE && b->const_decls[i].init &&
            typeck_coerce_array_var_to_slice_type((struct ASTExpr *)b->const_decls[i].init, b->const_decls[i].type, names, n, type_ptrs) != 0)
            return -1;
        const_values[n] = eval_const_int(b->const_decls[i].init, names, const_values, n);
        fold_expr((struct ASTExpr *)b->const_decls[i].init, names, const_values, i, const_start, parent_n_consts);
        /* i32 等标量 const 初值为数组字面量：resolved_type 设为声明类型以便 CTFE 折叠为 len */
        if (b->const_decls[i].type && b->const_decls[i].init && b->const_decls[i].init->kind == AST_EXPR_ARRAY_LIT &&
            (b->const_decls[i].type->kind == AST_TYPE_I32 || b->const_decls[i].type->kind == AST_TYPE_I64 ||
             b->const_decls[i].type->kind == AST_TYPE_U32 || b->const_decls[i].type->kind == AST_TYPE_USIZE ||
             b->const_decls[i].type->kind == AST_TYPE_ISIZE)) {
            ((struct ASTExpr *)b->const_decls[i].init)->resolved_type = b->const_decls[i].type;
            ((struct ASTExpr *)b->const_decls[i].init)->const_folded_val = const_values[n];
            ((struct ASTExpr *)b->const_decls[i].init)->const_folded_valid = 1;
        }
        /* 数组初值：= [] 表示全零初始化；= [e1,e2,...] 可写不超过声明长度的元素，不足部分按 0 填充 */
        if (b->const_decls[i].type && b->const_decls[i].type->kind == AST_TYPE_ARRAY &&
            b->const_decls[i].init && b->const_decls[i].init->kind == AST_EXPR_ARRAY_LIT) {
            int narr = b->const_decls[i].init->value.array_lit.num_elems;
            int decl_size = b->const_decls[i].type->array_size;
            /* 自举：允许 64 元素字面量（parser.sx）；narr>64 时仍报错 */
            if (narr > decl_size && narr > 64) {
                TYPECK_ERR_AT(0, 0, "array literal length exceeds declaration size");
                return -1;
            }
            /* 将数组字面量 resolved_type 设为声明类型，供 codegen 生成 { e1,... } 或 { 0 }，C 对未写元素零初始化 */
            ((struct ASTExpr *)b->const_decls[i].init)->resolved_type = b->const_decls[i].type;
        }
        if (b->const_decls[i].type && b->const_decls[i].type->kind == AST_TYPE_VECTOR &&
            b->const_decls[i].init && b->const_decls[i].init->kind == AST_EXPR_ARRAY_LIT) {
            if (b->const_decls[i].init->value.array_lit.num_elems != b->const_decls[i].type->array_size) {
                TYPECK_ERR_AT(0, 0, "vector literal length must match vector lanes");
                return -1;
            }
        }
        if (b->const_decls[i].type && b->const_decls[i].type->kind == AST_TYPE_SLICE &&
            b->const_decls[i].init && b->const_decls[i].init->kind == AST_EXPR_VAR &&
            b->const_decls[i].init->resolved_type &&
            b->const_decls[i].init->resolved_type->kind != AST_TYPE_SLICE) {
            TYPECK_ERR_AT(0, 0, "slice init must be array variable with matching element type");
            return -1;
        }
        /* f32/f64 初值：浮点字面量或整数字面量 0；非零整数字面量禁止（避免隐式截断）；浮点字面量设 resolved_type 供 codegen 生成 0.0f/0.0 */
        if (b->const_decls[i].type && (b->const_decls[i].type->kind == AST_TYPE_F32 || b->const_decls[i].type->kind == AST_TYPE_F64) && b->const_decls[i].init) {
            const struct ASTExpr *init = b->const_decls[i].init;
            if (init->kind == AST_EXPR_FLOAT_LIT)
                ((struct ASTExpr *)init)->resolved_type = b->const_decls[i].type;
            else if (init->kind == AST_EXPR_LIT && init->value.int_val == 0)
                ;
            else if (init->kind == AST_EXPR_LIT && init->value.int_val != 0) {
                TYPECK_ERR_AT(0, 0, "f32/f64 init must be float literal or integer 0");
                return -1;
            }
            else if (init->resolved_type && (init->resolved_type->kind == AST_TYPE_I32 || init->resolved_type->kind == AST_TYPE_F32 || init->resolved_type->kind == AST_TYPE_F64))
                ;
            else if (init->kind == AST_EXPR_VAR) {
                const char *v = init->value.var.name;
                int allow = 0;
                for (int k = 0; k < n && v; k++)
                    if (names[k] && strcmp(names[k], v) == 0 && (type_kinds[k] == AST_TYPE_I32 || type_kinds[k] == AST_TYPE_F32 || type_kinds[k] == AST_TYPE_F64)) { allow = 1; break; }
                if (!allow) {
                    TYPECK_ERR_AT(0, 0, "f32/f64 init must be float literal, integer 0, or numeric expression");
                    return -1;
                }
            }
            else {
                TYPECK_ERR_AT(0, 0, "f32/f64 init must be float literal, integer 0, or numeric expression");
                return -1;
            }
        }
        type_kinds[n] = b->const_decls[i].type ? b->const_decls[i].type->kind : AST_TYPE_I32;
        type_names[n] = (b->const_decls[i].type && b->const_decls[i].type->kind == AST_TYPE_NAMED) ? b->const_decls[i].type->name : NULL;
        type_ptrs[n] = b->const_decls[i].type;
        names[n++] = b->const_decls[i].name;
        n_consts++;
    }
    for (int i = 0; i < b->num_lets; i++) {
        if (n >= MAX_SYMTAB) {
            TYPECK_ERR_AT(0, 0, "too many declarations");
            return -1;
        }
        typeck_stamp_slice_region((struct ASTType *)b->let_decls[i].type, scope_region);
        {
            const struct ASTType *prev_ret = typeck_ctx_expected_return;
            if (b->let_decls[i].type)
                typeck_ctx_expected_return = b->let_decls[i].type;
            if (typeck_expr_sym(b->let_decls[i].init, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) {
                typeck_ctx_expected_return = prev_ret;
                return -1;
            }
            typeck_ctx_expected_return = prev_ret;
        }
        if (!typeck_fill_only && b->let_decls[i].type && b->let_decls[i].type->kind == AST_TYPE_SLICE && b->let_decls[i].init &&
            typeck_coerce_array_var_to_slice_type((struct ASTExpr *)b->let_decls[i].init, b->let_decls[i].type, names, n, type_ptrs) != 0)
            return -1;
        /* f32/f64 初值须在 let type mismatch 之前：浮点字面量默认为 f64，如 let sum: f32 = 0.0（simd_dot.sx） */
        if (b->let_decls[i].type && (b->let_decls[i].type->kind == AST_TYPE_F32 || b->let_decls[i].type->kind == AST_TYPE_F64) && b->let_decls[i].init) {
            const struct ASTExpr *init = b->let_decls[i].init;
            if (init->kind == AST_EXPR_FLOAT_LIT)
                ((struct ASTExpr *)init)->resolved_type = b->let_decls[i].type;
            else if (init->kind == AST_EXPR_LIT && init->value.int_val == 0)
                ((struct ASTExpr *)init)->resolved_type = b->let_decls[i].type;
            else if (init->kind == AST_EXPR_LIT && init->value.int_val != 0) {
                TYPECK_ERR_AT(0, 0, "f32/f64 init must be float literal or integer 0");
                return -1;
            }
            else if (init->resolved_type && (init->resolved_type->kind == AST_TYPE_I32 || init->resolved_type->kind == AST_TYPE_F32 || init->resolved_type->kind == AST_TYPE_F64))
                ;
            else if (init->kind == AST_EXPR_VAR) {
                const char *v = init->value.var.name;
                int allow = 0;
                for (int k = 0; k < n && v; k++)
                    if (names[k] && strcmp(names[k], v) == 0 && (type_kinds[k] == AST_TYPE_I32 || type_kinds[k] == AST_TYPE_F32 || type_kinds[k] == AST_TYPE_F64)) { allow = 1; break; }
                if (!allow) {
                    TYPECK_ERR_AT(0, 0, "f32/f64 init must be float literal, integer 0, or numeric expression");
                    return -1;
                }
            }
            else {
                TYPECK_ERR_AT(0, 0, "f32/f64 init must be float literal, integer 0, or numeric expression");
                return -1;
            }
        }
        (void)typeck_coerce_let_int_lit(b->let_decls[i].type, (struct ASTExpr *)b->let_decls[i].init);
        /* slice 域检查须在 integer widen 之前：同 kind slice 拓宽会覆盖 init->resolved_type 导致域标签丢失。 */
        if (!typeck_fill_only && b->let_decls[i].type && b->let_decls[i].init && b->let_decls[i].init->resolved_type
            && typeck_check_slice_region_assign(b->let_decls[i].init, b->let_decls[i].type,
                b->let_decls[i].init->resolved_type) != 0) {
            return -1;
        }
        if (b->let_decls[i].type && b->let_decls[i].init && b->let_decls[i].init->resolved_type
            && b->let_decls[i].type->kind != AST_TYPE_UNION
            && typeck_integer_widen_ok(b->let_decls[i].type->kind, b->let_decls[i].init->resolved_type->kind)) {
            ((struct ASTExpr *)b->let_decls[i].init)->resolved_type = b->let_decls[i].type;
        }
        if (!typeck_fill_only && b->let_decls[i].type && b->let_decls[i].init && b->let_decls[i].init->resolved_type
            && !typeck_let_init_matches(b->let_decls[i].type, b->let_decls[i].init)
            && !(b->let_decls[i].type->kind == AST_TYPE_LINEAR
                && typeck_linear_accepts_inner(b->let_decls[i].type, b->let_decls[i].init->resolved_type))) {
            char ebuf[64], fbuf[64];
            type_to_string_buf(b->let_decls[i].type, ebuf, sizeof(ebuf));
            type_to_string_buf(b->let_decls[i].init->resolved_type, fbuf, sizeof(fbuf));
            TYPECK_ERR_AT(0, 0, "let type mismatch: expected %s, found %s", ebuf, fbuf);
            return -1;
        }
        fold_expr((struct ASTExpr *)b->let_decls[i].init, names, const_values, n_consts, const_start, parent_n_consts);
        /* 数组初值：= [] 表示全零初始化；= [e1,e2,...] 可写不超过声明长度的元素，不足部分按 0 填充 */
        if (b->let_decls[i].type && b->let_decls[i].type->kind == AST_TYPE_ARRAY &&
            b->let_decls[i].init && b->let_decls[i].init->kind == AST_EXPR_ARRAY_LIT) {
            int narr = b->let_decls[i].init->value.array_lit.num_elems;
            int decl_size = b->let_decls[i].type->array_size;
            /* 自举：允许 64 元素字面量（parser.sx）；narr>64 时仍报错 */
            if (narr > decl_size && narr > 64) {
                TYPECK_ERR_AT(0, 0, "array literal length exceeds declaration size");
                return -1;
            }
            /* 将数组字面量 resolved_type 设为声明类型，供 codegen 生成 { e1,... } 或 { 0 }，C 对未写元素零初始化 */
            ((struct ASTExpr *)b->let_decls[i].init)->resolved_type = b->let_decls[i].type;
        }
        /* 向量可从数组字面量初始化：let v: i32x4 = [a,b,c,d]（文档 §10） */
        if (b->let_decls[i].type && b->let_decls[i].type->kind == AST_TYPE_VECTOR &&
            b->let_decls[i].init && b->let_decls[i].init->kind == AST_EXPR_ARRAY_LIT) {
            if (b->let_decls[i].init->value.array_lit.num_elems != b->let_decls[i].type->array_size) {
                TYPECK_ERR_AT(0, 0, "vector literal length must match vector lanes");
                return -1;
            }
        }
        type_ptrs[n] = typeck_let_symtab_type(b->let_decls[i].type, b->let_decls[i].init);
        if (!type_ptrs[n] && b->let_decls[i].init && b->let_decls[i].init->resolved_type)
            type_ptrs[n] = b->let_decls[i].init->resolved_type;
        type_kinds[n] = type_ptrs[n] ? type_ptrs[n]->kind : AST_TYPE_I32;
        type_names[n] = (type_ptrs[n] && type_ptrs[n]->kind == AST_TYPE_NAMED) ? type_ptrs[n]->name : NULL;
        names[n++] = b->let_decls[i].name;
    }
    for (int i = 0; i < b->num_loops; i++) {
        const struct ASTExpr *cond_while = b->loops[i].cond;
        if (typeck_expr_sym(cond_while, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
        fold_expr((struct ASTExpr *)cond_while, names, const_values, n_consts, const_start, parent_n_consts);
        if (!expr_produces_bool(cond_while, names, type_kinds, n)) {
            if (!typeck_fill_only) {
                TYPECK_ERR_AT(0, 0, "while condition must be bool (no implicit int-to-bool)");
                return -1;
            }
        }
        /* BCE 扩展：while (i < bound) 与 for 同，供体内 INDEX 消除边界检查 */
        {
            int saved_bce = bce_n;
            typeck_bce_push_lt_cond(cond_while, names, n, const_start, n_consts, const_values);
            if (typeck_block(b->loops[i].body, names, type_kinds, type_names, type_ptrs, n, const_values, n_consts, 1, struct_defs, num_structs, enum_defs, num_enums, m, func_return_type, scope_region) != 0) return -1;
            bce_n = saved_bce;
        }
    }
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init && typeck_expr_sym(b->for_loops[i].init, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
        if (b->for_loops[i].init) fold_expr((struct ASTExpr *)b->for_loops[i].init, names, const_values, n_consts, const_start, parent_n_consts);
        if (b->for_loops[i].cond) {
            const struct ASTExpr *cond_for = b->for_loops[i].cond;
            if (typeck_expr_sym(cond_for, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
            fold_expr((struct ASTExpr *)cond_for, names, const_values, n_consts, const_start, parent_n_consts);
            if (!expr_produces_bool(cond_for, names, type_kinds, n)) {
                if (!typeck_fill_only) {
                    TYPECK_ERR_AT(0, 0, "for condition must be bool (no implicit int-to-bool)");
                    return -1;
                }
            }
        }
        if (b->for_loops[i].step && typeck_expr_sym(b->for_loops[i].step, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
        if (b->for_loops[i].step) fold_expr((struct ASTExpr *)b->for_loops[i].step, names, const_values, n_consts, const_start, parent_n_consts);
        /* BCE 扩展：从 for 条件 i < bound 推断循环变量值域 [0, bound)，供体内 INDEX 消除边界检查 */
        {
            int saved_bce = bce_n;
            typeck_bce_push_lt_cond(b->for_loops[i].cond, names, n, const_start, n_consts, const_values);
            if (typeck_block(b->for_loops[i].body, names, type_kinds, type_names, type_ptrs, n, const_values, n_consts, 1, struct_defs, num_structs, enum_defs, num_enums, m, func_return_type, scope_region) != 0) return -1;
            bce_n = saved_bce;
        }
    }
    for (int i = 0; i < b->num_defers; i++) {
        if (typeck_block(b->defer_blocks[i], names, type_kinds, type_names, type_ptrs, n, const_values, n_consts, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m, func_return_type, scope_region) != 0) return -1;
    }
    for (int i = 0; i < b->num_regions; i++) {
        if (b->regions[i].is_unsafe) {
            typeck_unsafe_depth++;
            if (typeck_block(b->regions[i].body, names, type_kinds, type_names, type_ptrs, n, const_values, n_consts, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m, func_return_type, scope_region) != 0)
                return -1;
            typeck_unsafe_depth--;
        } else {
            if (typeck_block(b->regions[i].body, names, type_kinds, type_names, type_ptrs, n, const_values, n_consts, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m, func_return_type, b->regions[i].label) != 0)
                return -1;
        }
    }
    for (int i = 0; i < b->num_labeled_stmts; i++) {
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN) {
            if (!b->labeled_stmts[i].u.return_expr) {
                /* func_return_type 为 NULL 表示块表达式上下文（如 if 体），允许 return; */
                if (func_return_type && func_return_type->kind != AST_TYPE_VOID) {
                    TYPECK_ERR_AT(0, 0, "return; only allowed in void function");
                    return -1;
                }
            } else {
                if (func_return_type && func_return_type->kind == AST_TYPE_VOID) {
                    TYPECK_ERR_AT(0, 0, "void function cannot return a value");
                    return -1;
                }
                if (typeck_expr_sym(b->labeled_stmts[i].u.return_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
                if (typeck_check_return_operand(b->labeled_stmts[i].u.return_expr, b->labeled_stmts[i].u.return_expr,
                        func_return_type) != 0)
                    return -1;
                if (typeck_check_return_slice_region(b->labeled_stmts[i].u.return_expr,
                        b->labeled_stmts[i].u.return_expr, func_return_type) != 0)
                    return -1;
                fold_expr((struct ASTExpr *)b->labeled_stmts[i].u.return_expr, names, const_values, n_consts, const_start, parent_n_consts);
            }
        }
    }
    for (int i = 0; i < b->num_expr_stmts; i++) {
        if (typeck_expr_sym(b->expr_stmts[i], names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
    }
    if (!b->final_expr) return 0;
    if (b->final_expr->kind == AST_EXPR_RETURN && !b->final_expr->value.unary.operand) {
        if (func_return_type && func_return_type->kind != AST_TYPE_VOID) {
            TYPECK_ERR_AT(0, 0, "return; only allowed in void function");
            return -1;
        }
    } else if (b->final_expr->kind == AST_EXPR_RETURN && b->final_expr->value.unary.operand && func_return_type && func_return_type->kind == AST_TYPE_VOID) {
        TYPECK_ERR_AT(0, 0, "void function cannot return a value");
        return -1;
    }
    if (typeck_expr_sym(b->final_expr, names, type_kinds, type_names, n, type_ptrs, inside_loop, struct_defs, num_structs, enum_defs, num_enums, m) != 0) return -1;
    if (b->final_expr->kind == AST_EXPR_RETURN && b->final_expr->value.unary.operand && func_return_type &&
        func_return_type->kind != AST_TYPE_VOID) {
        if (typeck_check_return_operand(b->final_expr, b->final_expr->value.unary.operand, func_return_type) != 0)
            return -1;
        if (typeck_check_return_slice_region(b->final_expr, b->final_expr->value.unary.operand, func_return_type) != 0)
            return -1;
    }
    fold_expr((struct ASTExpr *)b->final_expr, names, const_values, n_consts, const_start, parent_n_consts);
    return 0;
}

/* ---------- .sx typeck 查询 API：供 typeck.sx 读取 AST，实现 main 等检查迁入 .sx ---------- */
void *typeck_sx_get_main_func(void *mod) {
    struct ASTModule *m = (struct ASTModule *)mod;
    return m ? (void *)m->main_func : NULL;
}
int typeck_sx_func_return_kind(void *func) {
    const struct ASTFunc *f = (const struct ASTFunc *)func;
    if (!f || !f->return_type) return -1;
    return f->return_type->kind;
}
int typeck_sx_func_is_extern(void *func) {
    const struct ASTFunc *f = (const struct ASTFunc *)func;
    return f ? f->is_extern : 0;
}
int typeck_sx_func_has_body(void *func) {
    const struct ASTFunc *f = (const struct ASTFunc *)func;
    return (f && f->body) ? 1 : 0;
}
int typeck_sx_func_is_generic(void *func) {
    const struct ASTFunc *f = (const struct ASTFunc *)func;
    return (f && f->num_generic_params > 0) ? 1 : 0;
}
void *typeck_sx_func_body(void *func) {
    const struct ASTFunc *f = (const struct ASTFunc *)func;
    return f ? (void *)f->body : NULL;
}
int typeck_sx_block_has_implicit_return(const void *block) {
    return block_has_implicit_return((const struct ASTBlock *)block);
}
int typeck_sx_ast_type_i32(void) { return AST_TYPE_I32; }
int typeck_sx_ast_type_i64(void) { return AST_TYPE_I64; }

/**
 * 全面自举（重写实现）：仅填 resolved_type，不做任何语义检查；.sx 用访问器遍历并做检查。
 * 返回与 typeck_module 相同（0 成功填类型，-1 推导失败等）。
 */
int typeck_sx_fill_resolved_types(void *mod, void *dep_mods, int num_deps) {
    typeck_fill_only = 1;
    int r = typeck_module((struct ASTModule *)mod, (struct ASTModule **)dep_mods, num_deps, NULL, 0);
    typeck_fill_only = 0;
    return r;
}

/** 全面自举：块访问器，供 .sx 遍历并检查条件须为 bool。 */
int typeck_sx_block_num_loops(const void *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? b->num_loops : 0;
}
void *typeck_sx_block_loop_cond(const void *block, int i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->loops || i < 0 || i >= b->num_loops) return NULL;
    return (void *)b->loops[i].cond;
}
void *typeck_sx_block_loop_body(const void *block, int i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->loops || i < 0 || i >= b->num_loops) return NULL;
    return (void *)b->loops[i].body;
}
int typeck_sx_block_num_for_loops(const void *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? b->num_for_loops : 0;
}
void *typeck_sx_block_for_cond(const void *block, int i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->for_loops || i < 0 || i >= b->num_for_loops) return NULL;
    return (void *)b->for_loops[i].cond;
}
void *typeck_sx_block_for_body(const void *block, int i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->for_loops || i < 0 || i >= b->num_for_loops) return NULL;
    return (void *)b->for_loops[i].body;
}
/** 表达式 resolved_type 的 kind；无类型或 expr 为空返回 -1。 */
int typeck_sx_expr_type_kind(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->resolved_type) ? (int)e->resolved_type->kind : -1;
}
int typeck_sx_ast_type_bool(void) { return AST_TYPE_BOOL; }

/** 块内表达式语句个数与第 i 个、最终表达式；供 .sx 遍历 if/三元。 */
int typeck_sx_block_num_expr_stmts(const void *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? b->num_expr_stmts : 0;
}
void *typeck_sx_block_expr_stmt(const void *block, int i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->expr_stmts || i < 0 || i >= b->num_expr_stmts) return NULL;
    return (void *)b->expr_stmts[i];
}
void *typeck_sx_block_final_expr(const void *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? (void *)b->final_expr : NULL;
}

/** .sx 自实现 typeck 用：块内 const/let 个数及「声明类型与初值类型一致」检查。 */
int typeck_sx_block_num_consts(const void *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? b->num_consts : 0;
}
int typeck_sx_block_num_lets(const void *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? b->num_lets : 0;
}
/** 返回 1 表示第 i 个 const 的声明类型与初值表达式 resolved_type 一致，0 表示不一致或无效。 */
int typeck_sx_block_const_type_matches_init(const void *block, int i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->const_decls || i < 0 || i >= b->num_consts) return 0;
    const struct ASTType *ty = b->const_decls[i].type;
    const struct ASTExpr *init = b->const_decls[i].init;
    if (!ty) return 1;
    if (!init || !init->resolved_type) return 0;
    return type_equal(ty, init->resolved_type) ? 1 : 0;
}
/** 返回 1 表示第 i 个 let 的声明类型与初值表达式 resolved_type 一致，0 表示不一致或无效。 */
int typeck_sx_block_let_type_matches_init(const void *block, int i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->let_decls || i < 0 || i >= b->num_lets) return 0;
    const struct ASTType *ty = b->let_decls[i].type;
    const struct ASTExpr *init = b->let_decls[i].init;
    if (!ty) return 1;
    if (!init || !init->resolved_type) return 0;
    return type_equal(ty, init->resolved_type) ? 1 : 0;
}

/** 表达式节点 kind（ASTExprKind）；IF/TERNARY 共用 if_expr 字段。 */
int typeck_sx_expr_kind(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return e ? (int)e->kind : -1;
}
void *typeck_sx_expr_if_cond(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || (e->kind != AST_EXPR_IF && e->kind != AST_EXPR_TERNARY)) return NULL;
    return (void *)e->value.if_expr.cond;
}
void *typeck_sx_expr_if_then(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || (e->kind != AST_EXPR_IF && e->kind != AST_EXPR_TERNARY)) return NULL;
    return (void *)e->value.if_expr.then_expr;
}
void *typeck_sx_expr_if_else(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || (e->kind != AST_EXPR_IF && e->kind != AST_EXPR_TERNARY)) return NULL;
    return (void *)e->value.if_expr.else_expr;
}
void *typeck_sx_expr_block(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_BLOCK) return NULL;
    return (void *)e->value.block;
}
int typeck_sx_expr_kind_if(void) { return AST_EXPR_IF; }
int typeck_sx_expr_kind_ternary(void) { return AST_EXPR_TERNARY; }
int typeck_sx_expr_kind_block(void) { return AST_EXPR_BLOCK; }
int typeck_sx_expr_kind_assign(void) { return AST_EXPR_ASSIGN; }
static int expr_is_assign_or_compound(const struct ASTExpr *e) {
    return e && (e->kind == AST_EXPR_ASSIGN || e->kind == AST_EXPR_ADD_ASSIGN || e->kind == AST_EXPR_SUB_ASSIGN
        || e->kind == AST_EXPR_MUL_ASSIGN || e->kind == AST_EXPR_DIV_ASSIGN || e->kind == AST_EXPR_MOD_ASSIGN
        || e->kind == AST_EXPR_BITAND_ASSIGN || e->kind == AST_EXPR_BITOR_ASSIGN || e->kind == AST_EXPR_BITXOR_ASSIGN
        || e->kind == AST_EXPR_SHL_ASSIGN || e->kind == AST_EXPR_SHR_ASSIGN);
}
void *typeck_sx_expr_assign_left(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!expr_is_assign_or_compound(e)) return NULL;
    return (void *)e->value.binop.left;
}
void *typeck_sx_expr_assign_right(const void *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!expr_is_assign_or_compound(e)) return NULL;
    return (void *)e->value.binop.right;
}
int typeck_sx_types_equal(const void *expr_a, const void *expr_b) {
    const struct ASTExpr *a = (const struct ASTExpr *)expr_a;
    const struct ASTExpr *b = (const struct ASTExpr *)expr_b;
    if (!a || !b || !a->resolved_type || !b->resolved_type) return 0;
    return type_equal(a->resolved_type, b->resolved_type) ? 1 : 0;
}

/**
 * .sx 自实现 typeck 用：块体的「结果类型」是否与函数声明的返回类型一致。
 * 非 void 函数：块 final_expr 须为表达式或 return expr，其 resolved_type 与 func->return_type 一致。
 * void 函数：块 final_expr 不得为「带操作数的 return」。
 * 返回 1 一致，0 不一致或无效。
 */
int typeck_sx_block_result_matches_func_return(const void *func, const void *block) {
    const struct ASTFunc *f = (const struct ASTFunc *)func;
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!f || !f->return_type || !b) return 0;
    const struct ASTExpr *fe = b->final_expr;
    if (f->return_type->kind == AST_TYPE_VOID) {
        if (fe && fe->kind == AST_EXPR_RETURN && fe->value.unary.operand) return 0;
        return 1;
    }
    if (!fe) return 0;
    const struct ASTType *block_ty = NULL;
    if (fe->kind == AST_EXPR_RETURN && fe->value.unary.operand)
        block_ty = fe->value.unary.operand->resolved_type;
    else if (fe->kind != AST_EXPR_RETURN && fe->kind != AST_EXPR_PANIC && fe->kind != AST_EXPR_BREAK && fe->kind != AST_EXPR_CONTINUE)
        block_ty = fe->resolved_type;
    if (!block_ty) return 0;
    return type_equal(block_ty, f->return_type) ? 1 : 0;
}

/** 模块内函数个数；mod 为空返回 0。 */
int typeck_sx_module_num_funcs(const void *mod) {
    const struct ASTModule *m = (const struct ASTModule *)mod;
    return m ? m->num_funcs : 0;
}
/** 模块内第 i 个函数；越界或 mod 为空返回 NULL。 */
void *typeck_sx_module_func(const void *mod, int i) {
    const struct ASTModule *m = (const struct ASTModule *)mod;
    if (!m || !m->funcs || i < 0 || i >= m->num_funcs) return NULL;
    return (void *)m->funcs[i];
}
/** impl 块内函数：impl_blocks[k].funcs[j]；越界返回 NULL。 */
int typeck_sx_module_num_impl_blocks(const void *mod) {
    const struct ASTModule *m = (const struct ASTModule *)mod;
    return m ? m->num_impl_blocks : 0;
}
int typeck_sx_impl_block_num_funcs(const void *mod, int k) {
    const struct ASTModule *m = (const struct ASTModule *)mod;
    if (!m || !m->impl_blocks || k < 0 || k >= m->num_impl_blocks) return 0;
    return m->impl_blocks[k]->num_funcs;
}
void *typeck_sx_impl_block_func(const void *mod, int k, int j) {
    const struct ASTModule *m = (const struct ASTModule *)mod;
    if (!m || !m->impl_blocks || k < 0 || k >= m->num_impl_blocks) return NULL;
    const struct ASTImplBlock *impl = m->impl_blocks[k];
    if (!impl->funcs || j < 0 || j >= impl->num_funcs) return NULL;
    return (void *)impl->funcs[j];
}

/**
 * 仅对 mod->funcs[only_func_index] 做体块 typeck（布局与顶层 let 先做）；用于 LSP 懒 typeck。
 */
int typeck_one_function(struct ASTModule *m, struct ASTModule **dep_mods, int num_deps, struct ASTModule **all_dep_mods, int n_all_deps, int only_func_index) {
    if (!m || only_func_index < 0 || only_func_index >= m->num_funcs) return 0;
    const struct ASTFunc *f = m->funcs[only_func_index];
    if (!f->body || f->num_generic_params > 0) return 0;
    struct ASTModule **layout_deps = (all_dep_mods && n_all_deps > 0) ? all_dep_mods : dep_mods;
    int layout_ndeps = (all_dep_mods && n_all_deps > 0) ? n_all_deps : num_deps;
    typeck_dep_mods = layout_deps;
    typeck_num_deps = layout_ndeps;
    if (layout_deps && layout_ndeps > 0) {
        for (int j = 0; j < layout_ndeps; j++) {
            if (!layout_deps[j]) continue;
            if (typeck_materialize_generic_structs(layout_deps[j]) != 0)
                return -1;
        }
    }
    if (typeck_materialize_generic_structs(m) != 0)
        return -1;
    if (layout_deps && layout_ndeps > 0) {
        for (int j = 0; j < layout_ndeps; j++) {
            if (!layout_deps[j]) continue;
            if (layout_deps[j]->struct_defs && layout_deps[j]->num_structs > 0 &&
                compute_struct_layouts(layout_deps[j]->struct_defs, layout_deps[j]->num_structs, layout_deps[j]->enum_defs, layout_deps[j]->num_enums) != 0)
                return -1;
        }
    }
    if (m->struct_defs && m->num_structs > 0 && compute_struct_layouts(m->struct_defs, m->num_structs, m->enum_defs, m->num_enums) != 0)
        return -1;
    typeck_dep_mods = dep_mods;
    typeck_num_deps = num_deps;
    if (m->top_level_lets && m->num_top_level_lets > 0) {
        const char *tl_names[MAX_SYMTAB];
        int tl_type_kinds[MAX_SYMTAB];
        const char *tl_type_names[MAX_SYMTAB];
        const struct ASTType *tl_type_ptrs[MAX_SYMTAB];
        int tl_n = 0;
        for (int i = 0; i < m->num_top_level_lets; i++) {
            if (tl_n >= MAX_SYMTAB) return -1;
            if (typeck_expr_sym(m->top_level_lets[i].init, tl_names, tl_type_kinds, tl_type_names, tl_n, tl_type_ptrs, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m) != 0)
                return -1;
            typeck_coerce_top_level_let_init(m->top_level_lets[i].type, (struct ASTExpr *)m->top_level_lets[i].init);
            if (m->top_level_lets[i].type && m->top_level_lets[i].init->resolved_type
                && !type_equal(m->top_level_lets[i].type, m->top_level_lets[i].init->resolved_type))
                return -1;
            tl_names[tl_n] = m->top_level_lets[i].name;
            tl_type_kinds[tl_n] = m->top_level_lets[i].type ? m->top_level_lets[i].type->kind : AST_TYPE_I32;
            tl_type_names[tl_n] = (m->top_level_lets[i].type && m->top_level_lets[i].type->kind == AST_TYPE_NAMED) ? m->top_level_lets[i].type->name : NULL;
            tl_type_ptrs[tl_n] = m->top_level_lets[i].type;
            tl_n++;
        }
        const char *names[MAX_SYMTAB];
        int type_kinds[MAX_SYMTAB];
        const char *type_names[MAX_SYMTAB];
        const struct ASTType *type_ptrs[MAX_SYMTAB];
        int n = 0;
        for (int j = 0; j < f->num_params && n < MAX_SYMTAB; j++) {
            names[n] = f->params[j].name;
            type_kinds[n] = f->params[j].type ? f->params[j].type->kind : AST_TYPE_I32;
            type_names[n] = (f->params[j].type && f->params[j].type->kind == AST_TYPE_NAMED) ? f->params[j].type->name : NULL;
            type_ptrs[n] = f->params[j].type;
            n++;
        }
        for (int t = 0; t < m->num_top_level_lets && n < MAX_SYMTAB; t++) {
            names[n] = m->top_level_lets[t].name;
            type_kinds[n] = m->top_level_lets[t].type ? m->top_level_lets[t].type->kind : AST_TYPE_I32;
            type_names[n] = (m->top_level_lets[t].type && m->top_level_lets[t].type->kind == AST_TYPE_NAMED) ? m->top_level_lets[t].type->name : NULL;
            type_ptrs[n] = m->top_level_lets[t].type;
            n++;
        }
        typeck_current_func_is_async = f->is_async ? 1 : 0;
        typeck_linear_reset();
        if (typeck_block(f->body, names, type_kinds, type_names, type_ptrs, n, NULL, 0, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m, f->return_type, NULL) != 0)
            return -1;
    } else {
        const char *names[MAX_SYMTAB];
        int type_kinds[MAX_SYMTAB];
        const char *type_names[MAX_SYMTAB];
        const struct ASTType *type_ptrs[MAX_SYMTAB];
        int n = 0;
        for (int j = 0; j < f->num_params && n < MAX_SYMTAB; j++) {
            names[n] = f->params[j].name;
            type_kinds[n] = f->params[j].type ? f->params[j].type->kind : AST_TYPE_I32;
            type_names[n] = (f->params[j].type && f->params[j].type->kind == AST_TYPE_NAMED) ? f->params[j].type->name : NULL;
            type_ptrs[n] = f->params[j].type;
            n++;
        }
        typeck_current_func_is_async = f->is_async ? 1 : 0;
        typeck_linear_reset();
        if (typeck_block(f->body, names, type_kinds, type_names, type_ptrs, n, NULL, 0, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m, f->return_type, NULL) != 0)
            return -1;
    }
    return 0;
}

/** WPO-S3：NAMED 类型是否为模块内 struct 定义。 */
static int typeck_wpo3_type_is_struct(const struct ASTType *ty, struct ASTStructDef **defs, int n) {
    if (!ty || ty->kind != AST_TYPE_NAMED || !ty->name || !defs)
        return 0;
    for (int i = 0; i < n; i++)
        if (defs[i] && defs[i]->name && strcmp(defs[i]->name, ty->name) == 0)
            return 1;
    return 0;
}

/** WPO-S3：块树内是否定义 let/const 名（非形参）。 */
static int typeck_wpo3_block_tree_has_let(const struct ASTBlock *b, const char *name) {
    int i;
    if (!b || !name || !name[0])
        return 0;
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].name && strcmp(b->let_decls[i].name, name) == 0)
            return 1;
    for (i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].name && strcmp(b->const_decls[i].name, name) == 0)
            return 1;
    for (i = 0; i < b->num_loops; i++)
        if (b->loops[i].body && typeck_wpo3_block_tree_has_let(b->loops[i].body, name))
            return 1;
    for (i = 0; i < b->num_for_loops; i++)
        if (b->for_loops[i].body && typeck_wpo3_block_tree_has_let(b->for_loops[i].body, name))
            return 1;
    for (i = 0; i < b->num_regions; i++)
        if (b->regions[i].body && typeck_wpo3_block_tree_has_let(b->regions[i].body, name))
            return 1;
    return 0;
}

/** WPO-S3：expr 是否为第 param_idx 个形参 VAR。 */
static int typeck_wpo3_expr_is_param(const struct ASTExpr *e, const struct ASTFunc *f, int param_idx) {
    if (!e || !f || e->kind != AST_EXPR_VAR || param_idx < 0 || param_idx >= f->num_params)
        return 0;
    if (!e->value.var.name || !f->params[param_idx].name)
        return 0;
    return strcmp(e->value.var.name, f->params[param_idx].name) == 0;
}

/** WPO-S3：left 是否为形参 *T 上的字段写入左值（field 基为形参）。 */
static int typeck_wpo3_lval_is_param_ptr_field(const struct ASTExpr *left, const struct ASTFunc *f, int dst_pi) {
    const struct ASTExpr *base;
    if (!left || !f || left->kind != AST_EXPR_FIELD_ACCESS || dst_pi < 0 || dst_pi >= f->num_params)
        return 0;
    base = left->value.field_access.base;
    if (!base || !typeck_wpo3_expr_is_param(base, f, dst_pi))
        return 0;
    return f->params[dst_pi].type && f->params[dst_pi].type->kind == AST_TYPE_PTR;
}

/** WPO-S3：在块树中查找 let 类型。 */
static const struct ASTType *typeck_wpo3_lookup_let_type_in_block(const struct ASTBlock *b, const char *name) {
    int i;
    const struct ASTType *ty;
    if (!b || !name || !name[0])
        return NULL;
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].name && strcmp(b->let_decls[i].name, name) == 0)
            return b->let_decls[i].type;
    for (i = 0; i < b->num_loops; i++) {
        ty = b->loops[i].body ? typeck_wpo3_lookup_let_type_in_block(b->loops[i].body, name) : NULL;
        if (ty) return ty;
    }
    for (i = 0; i < b->num_for_loops; i++) {
        ty = b->for_loops[i].body ? typeck_wpo3_lookup_let_type_in_block(b->for_loops[i].body, name) : NULL;
        if (ty) return ty;
    }
    for (i = 0; i < b->num_regions; i++) {
        ty = b->regions[i].body ? typeck_wpo3_lookup_let_type_in_block(b->regions[i].body, name) : NULL;
        if (ty) return ty;
    }
    for (i = 0; i < b->num_regions; i++) {
        ty = b->regions[i].body ? typeck_wpo3_lookup_let_type_in_block(b->regions[i].body, name) : NULL;
        if (ty) return ty;
    }
    return NULL;
}

/** WPO-S3：&块内局部 struct 的元素类型（非 addr 或非 struct 则 NULL）。 */
static const struct ASTType *typeck_wpo3_addr_of_local_struct_type(const struct ASTExpr *e, const struct ASTFunc *f,
    struct ASTStructDef **defs, int num_structs) {
    const struct ASTExpr *op;
    const struct ASTType *vty;
    if (!e || !f || e->kind != AST_EXPR_ADDR_OF)
        return NULL;
    op = e->value.unary.operand;
    if (!op || op->kind != AST_EXPR_VAR || !op->value.var.name)
        return NULL;
    if (!typeck_wpo3_block_tree_has_let(f->body, op->value.var.name))
        return NULL;
    vty = op->resolved_type;
    if (!vty && f->body)
        vty = typeck_wpo3_lookup_let_type_in_block(f->body, op->value.var.name);
    if (!typeck_wpo3_type_is_struct(vty, defs, num_structs))
        return NULL;
    return vty;
}

/** WPO-S3：expr 是否为 &块内局部 struct（seed AST 路径 post-scan）。 */
static int typeck_wpo3_expr_is_addr_of_local_struct(const struct ASTExpr *e, const struct ASTFunc *f,
    struct ASTStructDef **defs, int num_structs) {
    return typeck_wpo3_addr_of_local_struct_type(e, f, defs, num_structs) != NULL;
}

/** WPO-S3：两 NAMED 类型是否同名（*T 与 &local T 同型快照合法，如 copy_onefunc_into）。 */
static int typeck_wpo3_named_types_same(const struct ASTType *a, const struct ASTType *b) {
    if (!a || !b || a->kind != AST_TYPE_NAMED || b->kind != AST_TYPE_NAMED)
        return 0;
    if (!a->name || !b->name)
        return 0;
    return strcmp(a->name, b->name) == 0;
}

/** WPO-S3：assign 路径 — 禁止局部 struct 指针写入形参 *T 字段。 */
static int typeck_wpo3_check_assign_escape(const struct ASTExpr *site, const struct ASTExpr *left,
    const struct ASTExpr *right, const struct ASTFunc *f, struct ASTStructDef **defs, int num_structs) {
    int pi;
    int line;
    int col;
    if (!left || !right || !f)
        return 0;
    if (!typeck_wpo3_expr_is_addr_of_local_struct(right, f, defs, num_structs))
        return 0;
    for (pi = 0; pi < f->num_params; pi++) {
        if (typeck_wpo3_lval_is_param_ptr_field(left, f, pi)) {
            line = site ? site->line : 0;
            col = site ? site->col : 0;
            TYPECK_ERR_AT(line, col,
                "struct stack escape: cannot store address of local struct in outer lifetime");
            return -1;
        }
    }
    return 0;
}

/** WPO-S3：CALL 路径 — 局部 struct 与**异型** *Struct 形参同传时拒绝（同型 *T + &local T 为合法快照）。 */
static int typeck_wpo3_check_call_escape(const struct ASTExpr *call, const struct ASTFunc *f,
    struct ASTStructDef **defs, int num_structs) {
    const struct ASTFunc *callee;
    int src_i;
    int dst_j;
    if (!call || call->kind != AST_EXPR_CALL || !f)
        return 0;
    callee = call->value.call.resolved_callee_func;
    if (!callee || callee->num_params != call->value.call.num_args || callee->num_params < 2)
        return 0;
    for (src_i = 0; src_i < call->value.call.num_args; src_i++) {
        const struct ASTExpr *arg = call->value.call.args[src_i];
        const struct ASTType *local_st;
        local_st = typeck_wpo3_addr_of_local_struct_type(arg, f, defs, num_structs);
        if (!local_st)
            continue;
        for (dst_j = 0; dst_j < callee->num_params; dst_j++) {
            const struct ASTType *pt;
            if (dst_j == src_i)
                continue;
            pt = callee->params[dst_j].type;
            if (!pt || pt->kind != AST_TYPE_PTR || !pt->elem_type)
                continue;
            if (!typeck_wpo3_type_is_struct(pt->elem_type, defs, num_structs))
                continue;
            /** parser copy_onefunc_into(out, &snap) 等同型 *OneFuncResult，非 WPO 逃逸。 */
            if (typeck_wpo3_named_types_same(local_st, pt->elem_type))
                continue;
            TYPECK_ERR_AT(call->line, call->col,
                "struct stack escape: cannot pass address of local struct with outer struct pointer");
            return -1;
        }
    }
    return 0;
}

/** WPO-S3：扫描单 expr（assign/call）。 */
static int typeck_wpo3_scan_expr_escape(const struct ASTExpr *e, const struct ASTFunc *f,
    struct ASTStructDef **defs, int num_structs) {
    if (!e || !f)
        return 0;
    if (expr_is_assign_or_compound(e)) {
        if (typeck_wpo3_check_assign_escape(e, e->value.binop.left, e->value.binop.right, f, defs, num_structs) != 0)
            return -1;
    } else if (e->kind == AST_EXPR_CALL) {
        if (typeck_wpo3_check_call_escape(e, f, defs, num_structs) != 0)
            return -1;
    }
    return 0;
}

/** WPO-S3：递归扫描块内 expr_stmt / final_expr / 子块。 */
static int typeck_wpo3_scan_block_escape(const struct ASTBlock *b, const struct ASTFunc *f,
    struct ASTStructDef **defs, int num_structs) {
    int i;
    if (!b || !f)
        return 0;
    for (i = 0; i < b->num_expr_stmts; i++)
        if (typeck_wpo3_scan_expr_escape(b->expr_stmts[i], f, defs, num_structs) != 0)
            return -1;
    if (b->final_expr && typeck_wpo3_scan_expr_escape(b->final_expr, f, defs, num_structs) != 0)
        return -1;
    if (b->num_stmt_order > 0) {
        for (i = 0; i < b->num_stmt_order; i++) {
            unsigned char kind = b->stmt_order[i].kind;
            int idx = b->stmt_order[i].idx;
            if (kind == 2 && b->expr_stmts && idx >= 0 && idx < b->num_expr_stmts) {
                if (typeck_wpo3_scan_expr_escape(b->expr_stmts[idx], f, defs, num_structs) != 0)
                    return -1;
            } else if (kind == 3 && b->loops && idx >= 0 && idx < b->num_loops && b->loops[idx].body) {
                if (typeck_wpo3_scan_block_escape(b->loops[idx].body, f, defs, num_structs) != 0)
                    return -1;
            } else if (kind == 4 && b->for_loops && idx >= 0 && idx < b->num_for_loops && b->for_loops[idx].body) {
                if (typeck_wpo3_scan_block_escape(b->for_loops[idx].body, f, defs, num_structs) != 0)
                    return -1;
            } else if (kind == 5 && b->regions && idx >= 0 && idx < b->num_regions && b->regions[idx].body) {
                if (typeck_wpo3_scan_block_escape(b->regions[idx].body, f, defs, num_structs) != 0)
                    return -1;
            }
        }
    }
    return 0;
}

/** WPO-S3：模块级 post-typeck struct 栈指针逃逸扫描（seed shux-c 路径）。 */
static int typeck_wpo3_scan_module_struct_stack_escape(struct ASTModule *m) {
    int i;
    if (!m || !m->funcs)
        return 0;
    for (i = 0; i < m->num_funcs; i++) {
        struct ASTFunc *f = m->funcs[i];
        if (!f || f->is_extern || !f->body)
            continue;
        if (typeck_wpo3_scan_block_escape(f->body, f, m->struct_defs, m->num_structs) != 0)
            return -1;
    }
    for (i = 0; m->impl_blocks && i < m->num_impl_blocks; i++) {
        struct ASTImplBlock *impl = m->impl_blocks[i];
        int j;
        if (!impl || !impl->funcs)
            continue;
        for (j = 0; j < impl->num_funcs; j++) {
            struct ASTFunc *f = impl->funcs[j];
            if (!f || !f->body)
                continue;
            if (typeck_wpo3_scan_block_escape(f->body, f, m->struct_defs, m->num_structs) != 0)
                return -1;
        }
    }
    return 0;
}

/**
 * 对模块做类型检查；功能、参数、返回值见 typeck.h 声明处注释。
 */
int typeck_module(struct ASTModule *m, struct ASTModule **dep_mods, int num_deps, struct ASTModule **all_dep_mods, int n_all_deps) {
    if (!m) {
        TYPECK_ERR_AT(0, 0, "null module");
        return -1;
    }
    typeck_current_mod = m;
    typeck_unsafe_depth = 0;
    /* 布局阶段使用全部传递依赖（若有），以便依赖内结构体引用其他依赖类型时能解析（如 parser 的 OneFuncResult.next_lex: Lexer） */
    struct ASTModule **layout_deps = (all_dep_mods && n_all_deps > 0) ? all_dep_mods : dep_mods;
    int layout_ndeps = (all_dep_mods && n_all_deps > 0) ? n_all_deps : num_deps;
    typeck_dep_mods = layout_deps;
    typeck_num_deps = layout_ndeps;
    /* 先物化各依赖与主模块（主模块使用处可触发在依赖内单态化，LANG-010） */
    if (layout_deps && layout_ndeps > 0) {
        for (int j = 0; j < layout_ndeps; j++) {
            if (!layout_deps[j]) continue;
            if (typeck_materialize_generic_structs(layout_deps[j]) != 0)
                return -1;
        }
    }
    if (typeck_materialize_generic_structs(m) != 0)
        return -1;
    /* 物化完成后再统一计算布局（含依赖内跨模块生成的单态 struct） */
    if (layout_deps && layout_ndeps > 0) {
        for (int j = 0; j < layout_ndeps; j++) {
            if (!layout_deps[j]) continue;
            if (layout_deps[j]->struct_defs && layout_deps[j]->num_structs > 0 &&
                compute_struct_layouts(layout_deps[j]->struct_defs, layout_deps[j]->num_structs, layout_deps[j]->enum_defs, layout_deps[j]->num_enums) != 0)
                return -1;
        }
    }
    if (m->struct_defs && m->num_structs > 0 && compute_struct_layouts(m->struct_defs, m->num_structs, m->enum_defs, m->num_enums) != 0)
        return -1;
    /* 后续 CALL 解析等仍用直接依赖 dep_mods */
    typeck_dep_mods = dep_mods;
    typeck_num_deps = num_deps;

    /* 顶层 let：按顺序 typeck 每个 init（作用域为前面的顶层 let + import 符号），并校验 init 类型与声明类型一致 */
    if (m->top_level_lets && m->num_top_level_lets > 0) {
        const char *tl_names[MAX_SYMTAB];
        int tl_type_kinds[MAX_SYMTAB];
        const char *tl_type_names[MAX_SYMTAB];
        const struct ASTType *tl_type_ptrs[MAX_SYMTAB];
        int tl_n = 0;
        for (int i = 0; i < m->num_top_level_lets; i++) {
            if (tl_n >= MAX_SYMTAB) {
                TYPECK_ERR_AT(0, 0, "too many top-level lets");
                return -1;
            }
            if (typeck_expr_sym(m->top_level_lets[i].init, tl_names, tl_type_kinds, tl_type_names, tl_n, tl_type_ptrs, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m) != 0)
                return -1;
            typeck_coerce_top_level_let_init(m->top_level_lets[i].type, (struct ASTExpr *)m->top_level_lets[i].init);
            if (m->top_level_lets[i].type && m->top_level_lets[i].init->resolved_type
                && !typeck_let_init_matches(m->top_level_lets[i].type, m->top_level_lets[i].init)
                && !(m->top_level_lets[i].type->kind == AST_TYPE_LINEAR
                    && typeck_linear_accepts_inner(m->top_level_lets[i].type, m->top_level_lets[i].init->resolved_type))) {
                TYPECK_ERR_AT(0, 0, "top-level let init type mismatch");
                return -1;
            }
            tl_names[tl_n] = m->top_level_lets[i].name;
            tl_type_ptrs[tl_n] = typeck_let_symtab_type(m->top_level_lets[i].type, m->top_level_lets[i].init);
            if (!tl_type_ptrs[tl_n]) tl_type_ptrs[tl_n] = m->top_level_lets[i].type;
            tl_type_kinds[tl_n] = tl_type_ptrs[tl_n] ? tl_type_ptrs[tl_n]->kind : AST_TYPE_I32;
            tl_type_names[tl_n] = (tl_type_ptrs[tl_n] && tl_type_ptrs[tl_n]->kind == AST_TYPE_NAMED) ? tl_type_ptrs[tl_n]->name : NULL;
            tl_n++;
        }
    }

    /* 库模块也需对每个函数体做 typeck，以便设置 resolved_type 等供 codegen 使用（如结构体字面量内数组字面量类型） */
    if (!m->main_func) {
        for (int i = 0; i < m->num_funcs; i++) {
            const struct ASTFunc *f = m->funcs[i];
            if (!f->body) continue;
            if (f->num_generic_params > 0) continue;
            const char *names[MAX_SYMTAB];
            int type_kinds[MAX_SYMTAB];
            const char *type_names[MAX_SYMTAB];
            const struct ASTType *type_ptrs[MAX_SYMTAB];
            int n = 0;
            for (int j = 0; j < f->num_params && n < MAX_SYMTAB; j++) {
                names[n] = f->params[j].name;
                type_kinds[n] = f->params[j].type ? f->params[j].type->kind : AST_TYPE_I32;
                type_names[n] = (f->params[j].type && f->params[j].type->kind == AST_TYPE_NAMED) ? f->params[j].type->name : NULL;
                type_ptrs[n] = f->params[j].type;
                n++;
            }
            for (int t = 0; m->top_level_lets && t < m->num_top_level_lets && n < MAX_SYMTAB; t++) {
                names[n] = m->top_level_lets[t].name;
                type_kinds[n] = m->top_level_lets[t].type ? m->top_level_lets[t].type->kind : AST_TYPE_I32;
                type_names[n] = (m->top_level_lets[t].type && m->top_level_lets[t].type->kind == AST_TYPE_NAMED) ? m->top_level_lets[t].type->name : NULL;
                type_ptrs[n] = m->top_level_lets[t].type;
                n++;
            }
            typeck_current_func_is_async = f->is_async ? 1 : 0;
            typeck_linear_reset();
            if (typeck_block(f->body, names, type_kinds, type_names, type_ptrs, n, NULL, 0, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m, f->return_type, NULL) != 0)
                return -1;
        }
        return 0;
    }

#ifndef SHUX_USE_SX_TYPECK
    /* 未使用 .sx typeck 入口时，在此做 main 校验；使用 .sx 时由 typeck.sx 在调用 typeck_module 前完成。 */
    if (!m->main_func->return_type ||
        (m->main_func->return_type->kind != AST_TYPE_I32 && m->main_func->return_type->kind != AST_TYPE_I64)) {
        TYPECK_ERR_AT(0, 0, "main must return i32 or i64");
        return -1;
    }
    if (m->main_func->is_extern) {
        TYPECK_ERR_AT(0, 0, "main cannot be extern");
        return -1;
    }
    if (!m->main_func->body) {
        TYPECK_ERR_AT(0, 0, "main must have a body (block)");
        return -1;
    }
    if (block_has_implicit_return(m->main_func->body)) {
        TYPECK_ERR_AT(0, 0, "return value must use explicit return statement (e.g. return 0;)");
        return -1;
    }
    if (m->main_func->num_generic_params > 0) {
        TYPECK_ERR_AT(0, 0, "main cannot be generic");
        return -1;
    }
#endif

    /* impl 块校验：trait 存在、类型存在、每个 trait 方法在 impl 中有且签名一致（阶段 7.2） */
    if (m->impl_blocks) {
        for (int k = 0; k < m->num_impl_blocks; k++) {
            const struct ASTImplBlock *impl = m->impl_blocks[k];
            const struct ASTTraitDef *trait = find_trait_def(m->trait_defs, m->num_traits, impl->trait_name);
            if (!trait) {
                TYPECK_ERR_AT(0, 0, "impl for unknown trait '%s'", impl->trait_name ? impl->trait_name : "");
                return -1;
            }
            for (int i = 0; i < trait->num_methods; i++) {
                const char *meth = trait->methods[i].name;
                struct ASTFunc *impl_func = NULL;
                for (int j = 0; j < impl->num_funcs; j++)
                    if (impl->funcs[j]->name && meth && strcmp(impl->funcs[j]->name, meth) == 0) { impl_func = impl->funcs[j]; break; }
                if (!impl_func) {
                    TYPECK_ERR_AT(0, 0, "impl '%s' for '%s' missing method '%s'",
                        impl->trait_name ? impl->trait_name : "", impl->type_name ? impl->type_name : "", meth ? meth : "");
                    return -1;
                }
                if (!impl_func->return_type || !trait->methods[i].return_type || !type_equal(impl_func->return_type, trait->methods[i].return_type)) {
                    TYPECK_ERR_AT(0, 0, "impl method '%s' return type mismatch", meth ? meth : "");
                    return -1;
                }
            }
        }
        /* 对 impl 块内方法做体块类型检查 */
        for (int k = 0; k < m->num_impl_blocks; k++) {
            const struct ASTImplBlock *impl = m->impl_blocks[k];
            for (int j = 0; j < impl->num_funcs; j++) {
                const struct ASTFunc *f = impl->funcs[j];
                if (!f->body) continue;
                const char *names[MAX_SYMTAB];
                int type_kinds[MAX_SYMTAB];
                const char *type_names[MAX_SYMTAB];
                const struct ASTType *type_ptrs[MAX_SYMTAB];
                int n = 0;
                for (int i = 0; i < f->num_params && n < MAX_SYMTAB; i++) {
                    names[n] = f->params[i].name;
                    type_kinds[n] = f->params[i].type ? f->params[i].type->kind : AST_TYPE_I32;
                    type_names[n] = (f->params[i].type && f->params[i].type->kind == AST_TYPE_NAMED) ? f->params[i].type->name : NULL;
                    type_ptrs[n] = f->params[i].type;
                    n++;
                }
                for (int t = 0; m->top_level_lets && t < m->num_top_level_lets && n < MAX_SYMTAB; t++) {
                    names[n] = m->top_level_lets[t].name;
                    type_kinds[n] = m->top_level_lets[t].type ? m->top_level_lets[t].type->kind : AST_TYPE_I32;
                    type_names[n] = (m->top_level_lets[t].type && m->top_level_lets[t].type->kind == AST_TYPE_NAMED) ? m->top_level_lets[t].type->name : NULL;
                    type_ptrs[n] = m->top_level_lets[t].type;
                    n++;
                }
                typeck_current_func_is_async = f->is_async ? 1 : 0;
                typeck_linear_reset();
                if (typeck_block(f->body, names, type_kinds, type_names, type_ptrs, n, NULL, 0, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m, f->return_type, NULL) != 0)
                    return -1;
                if (f->return_type && f->return_type->kind != AST_TYPE_VOID && block_has_implicit_return(f->body)) {
                    TYPECK_ERR_AT(0, 0, "return value must use explicit return statement (e.g. return 0;)");
                    return -1;
                }
            }
        }
    }

    /* 对每个非泛型函数做体块类型检查；泛型函数体在对单态化实例检查时再做。初始作用域 = 形参 + 顶层 let。 */
    for (int i = 0; i < m->num_funcs; i++) {
        const struct ASTFunc *f = m->funcs[i];
        if (!f->body) continue;
        if (f->num_generic_params > 0) continue;
        const char *names[MAX_SYMTAB];
        int type_kinds[MAX_SYMTAB];
        const char *type_names[MAX_SYMTAB];
        const struct ASTType *type_ptrs[MAX_SYMTAB];
        int n = 0;
        for (int j = 0; j < f->num_params && n < MAX_SYMTAB; j++) {
            names[n] = f->params[j].name;
            type_kinds[n] = f->params[j].type ? f->params[j].type->kind : AST_TYPE_I32;
            type_names[n] = (f->params[j].type && f->params[j].type->kind == AST_TYPE_NAMED) ? f->params[j].type->name : NULL;
            type_ptrs[n] = f->params[j].type;
            n++;
        }
        for (int t = 0; m->top_level_lets && t < m->num_top_level_lets && n < MAX_SYMTAB; t++) {
            names[n] = m->top_level_lets[t].name;
            type_kinds[n] = m->top_level_lets[t].type ? m->top_level_lets[t].type->kind : AST_TYPE_I32;
            type_names[n] = (m->top_level_lets[t].type && m->top_level_lets[t].type->kind == AST_TYPE_NAMED) ? m->top_level_lets[t].type->name : NULL;
            type_ptrs[n] = m->top_level_lets[t].type;
            n++;
        }
        typeck_current_func_is_async = f->is_async ? 1 : 0;
        typeck_linear_reset();
        if (typeck_block(f->body, names, type_kinds, type_names, type_ptrs, n, NULL, 0, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m, f->return_type, NULL) != 0)
            return -1;
        if (f->return_type && f->return_type->kind != AST_TYPE_VOID && block_has_implicit_return(f->body)) {
            TYPECK_ERR_AT(0, 0, "return value must use explicit return statement (e.g. return 0;)");
            return -1;
        }
    }
    /* 对每个泛型单态化实例，用代入后的形参类型再检查一次模板函数体，保证体在具体类型下合法 */
    for (int k = 0; k < m->num_mono_instances; k++) {
        const struct ASTFunc *f = m->mono_instances[k].template;
        struct ASTType **type_args = m->mono_instances[k].type_args;
        int num_type_args = m->mono_instances[k].num_type_args;
        if (!f->body || !f->generic_param_names || !type_args) continue;
        const char *names[MAX_SYMTAB];
        int type_kinds[MAX_SYMTAB];
        const char *type_names[MAX_SYMTAB];
        const struct ASTType *type_ptrs[MAX_SYMTAB];
        int n = 0;
        for (int j = 0; j < f->num_params && n < MAX_SYMTAB; j++) {
            names[n] = f->params[j].name;
            type_ptrs[n] = get_substituted_return_type(f->params[j].type, f->generic_param_names, type_args, num_type_args);
            type_kinds[n] = type_ptrs[n] ? type_ptrs[n]->kind : AST_TYPE_I32;
            type_names[n] = (type_ptrs[n] && type_ptrs[n]->kind == AST_TYPE_NAMED) ? type_ptrs[n]->name : NULL;
            n++;
        }
        for (int t = 0; m->top_level_lets && t < m->num_top_level_lets && n < MAX_SYMTAB; t++) {
            names[n] = m->top_level_lets[t].name;
            type_kinds[n] = m->top_level_lets[t].type ? m->top_level_lets[t].type->kind : AST_TYPE_I32;
            type_names[n] = (m->top_level_lets[t].type && m->top_level_lets[t].type->kind == AST_TYPE_NAMED) ? m->top_level_lets[t].type->name : NULL;
            type_ptrs[n] = m->top_level_lets[t].type;
            n++;
        }
        const struct ASTType *mono_ret = get_substituted_return_type(f->return_type, f->generic_param_names, type_args, num_type_args);
        typeck_current_func_is_async = f->is_async ? 1 : 0;
        typeck_linear_reset();
        if (typeck_block(f->body, names, type_kinds, type_names, type_ptrs, n, NULL, 0, 0, m->struct_defs, m->num_structs, m->enum_defs, m->num_enums, m, mono_ret, NULL) != 0)
            return -1;
        if (mono_ret && mono_ret->kind != AST_TYPE_VOID && block_has_implicit_return(f->body)) {
            TYPECK_ERR_AT(0, 0, "return value must use explicit return statement (e.g. return 0;)");
            return -1;
        }
    }
    /* noalias 传递：对指针形参标记 is_restrict，codegen 生成 C restrict，便于优化 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        struct ASTFunc *f = (struct ASTFunc *)m->funcs[i];
        if (!f || !f->params) continue;
        for (int j = 0; j < f->num_params; j++)
            if (f->params[j].type && f->params[j].type->kind == AST_TYPE_PTR)
                f->params[j].is_restrict = 1;
    }
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
            struct ASTFunc *f = (struct ASTFunc *)m->impl_blocks[k]->funcs[j];
            if (!f || !f->params) continue;
            for (int p = 0; p < f->num_params; p++)
                if (f->params[p].type && f->params[p].type->kind == AST_TYPE_PTR)
                    f->params[p].is_restrict = 1;
        }
    /* WPO-S3：post-typeck struct 栈指针逃逸（与 pipeline_typeck_scan_module_struct_stack_escape_c 对齐）。 */
    if (typeck_wpo3_scan_module_struct_stack_escape(m) != 0)
        return -1;
    typeck_unused_hints_module(m);
    return 0;
}

/** double 的 64 位位模式低 32 位，供 .sx typeck 填写 EXPR_FLOAT_LIT（asm 后端用）。 */
int typeck_float64_bits_lo(double d) {
    union { double d; unsigned long long u; } u;
    u.d = d;
    return (int)(u.u & 0xFFFFFFFFULL);
}

/** double 的 64 位位模式高 32 位，供 .sx typeck 填写 EXPR_FLOAT_LIT（asm 后端用）。 */
int typeck_float64_bits_hi(double d) {
    union { double d; unsigned long long u; } u;
    u.d = d;
    return (int)(u.u >> 32);
}
