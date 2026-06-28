/**
 * runtime_driver_diagnostic.c — pipeline/typeck/asm 诊断输出（Phase E-04 v34）
 *
 * 文件职责：driver_diagnostic_*、parser_diag_*、typeck 诊断 scratch；供 pipeline.sx / typeck.sx / backend.sx 链接。
 * 所属模块：compiler 运行时 driver 诊断；bootstrap driver seed 与 shux-c 均链入。
 * 与其它文件的关系：依赖 lsp_diag、runtime_driver_abi（check_only）；不依赖 C 前端头。
 */

#include "runtime_driver_diagnostic.h"
#include "runtime_driver_abi.h"
#include "lsp/lsp_diag.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_is_extern_at(void *module, int32_t fi);


void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types) {
    if (lsp_diag_enabled) {
        char msg[160];
        (void)snprintf(msg, sizeof(msg), "parse fail main_idx=%d num_funcs=%d arena_num_types=%d", (int)main_idx,
                       (int)num_funcs, (int)arena_num_types);
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "shux: parse fail main_idx=%d num_funcs=%d arena_num_types=%d\n", (int)main_idx, (int)num_funcs,
            (int)arena_num_types);
}

/**
 * 非 0 时 parse_into_buf 在单函数 impl/buf 均失败时返回 -2，不再静默 skip（与 parse_into slice 路径对齐）。
 * 环境变量 SHUX_PARSE_STRICT=1。
 */
int32_t driver_parse_strict_enabled(void) {
    const char *e = getenv("SHUX_PARSE_STRICT");
    return (e && e[0] && e[0] != '0') ? 1 : 0;
}

/**
 * parse_into_buf 跳过无法解析的 function 时打印诊断（SHUX_DEBUG_PARSE=1 或 SHUX_PARSE_STRICT=1）。
 * byte_pos 为源缓冲字节偏移；name 可为 NULL。
 */
void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                           const uint8_t *name) {
    const char *tag;
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    tag = getenv("SHUX_DEBUG_PARSE") ? "debug" : "strict";
    if (lsp_diag_enabled) {
        char msg[240];
        char nb[72];
        int nl = (name && name_len > 0 && name_len < (int)sizeof(nb)) ? name_len : 0;
        if (nl > 0)
            memcpy(nb, name, (size_t)nl);
        nb[nl > 0 ? nl : 0] = '\0';
        (void)snprintf(msg, sizeof(msg), "parse skip at byte %d (num_funcs=%d) name=%s [%s]", (int)byte_pos,
                       (int)num_funcs_so_far, nl > 0 ? nb : "?", tag);
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "shux: parse skip at byte %d (num_funcs=%d)", (int)byte_pos, (int)num_funcs_so_far);
    if (name && name_len > 0 && name_len < 64) {
        fprintf(stderr, " name=");
        fwrite(name, 1, (size_t)name_len, stderr);
    }
    fprintf(stderr, " [%s]\n", tag);
    fflush(stderr);
}

/**
 * .sx 流水线中 typeck_sx_ast / typeck_sx_ast_library 失败时打印一行 stderr。
 * 与 C 路径 lsp_diag_report_typeck 在 !lsp_diag_enabled 时的前缀一致，供 run-typeck.sh、check-7.2 等识别（.sx typeck 当前不向 stderr 逐条报原因）。
 */
void driver_diagnostic_typeck_fail(void) {
    const char *msg = driver_check_only_get() ? "check failed: .sx pipeline type check failed"
                                              : "typeck error: .sx pipeline type check failed";
    if (lsp_diag_enabled) {
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "%s\n", msg);
    fflush(stderr);
}

/**
 * .sx typeck：标注失败函数（下标 + 名称）与失败类别；在 driver_diagnostic_typeck_fail 一行之前打印，便于定位大模块。
 * kind：5 = check_block 失败；-6 = 非 void 函数块末隐式尾表达式。
 */
void driver_diagnostic_typeck_func_fail(int32_t func_idx, const uint8_t *name, int32_t name_len, int32_t kind) {
    if (lsp_diag_enabled) {
        char msg[240];
        char namebuf[72];
        int nl = (name && name_len > 0 && name_len <= 64) ? (int)name_len : 0;
        if (nl > 0) {
            memcpy(namebuf, name, (size_t)nl);
            namebuf[nl] = '\0';
        } else {
            namebuf[0] = '\0';
            (void)strcpy(namebuf, "(unknown)");
        }
        (void)snprintf(msg, sizeof(msg), "shux: typeck func_idx=%d %s (%s)", (int)func_idx, namebuf,
                       kind == -6 ? "implicit tail return" : "check_block failed");
        lsp_diag_add(1, 1, 1, msg);
        return;
    }
    fprintf(stderr, "shux: typeck func_idx=%d ", (int)func_idx);
    if (name && name_len > 0 && name_len <= 64)
        (void)fwrite(name, 1, (size_t)name_len, stderr);
    else
        (void)fputs("(unknown)", stderr);
    fprintf(stderr, " (%s)\n", kind == -6 ? "implicit tail return" : "check_block failed");
    if (kind == -6) {
        fprintf(stderr, "typeck error: return value must use explicit return statement (e.g. return 0;)\n");
    }
    fflush(stderr);
}

/** 诊断：FIELD_ACCESS 时 base 的类型与 *T 指向名；SHUX_TYPECK_PTR=1 时打印（含模块已登记的 struct_layouts 条数）。 */
void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref,
                                      int32_t num_struct_layouts) {
    if (!getenv("SHUX_TYPECK_PTR"))
        return;
    fprintf(stderr,
            "shux: [SHUX_TYPECK_PTR] FIELD_ACCESS bt_kind=%d inner_kind=%d inner_nlen=%d base_resolved_ref=%d "
            "num_struct_layouts=%d\n",
            (int)bt_kind, (int)inner_kind, (int)inner_nlen, (int)base_resolved_ref, (int)num_struct_layouts);
    fflush(stderr);
}

/** 诊断：EXPR_RETURN 失败；SHUX_TYPECK_RET=1 时额外打印 ref 调试。stage 1=operand check_expr -1；2=got 与期望 return_type_ref 不一致。 */
void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref) {
    if (getenv("SHUX_TYPECK_RET")) {
        fprintf(stderr, "shux: [RET_FAIL] stage=%d op_expr_ref=%d expect_ty_ref=%d got_ty_ref=%d\n", (int)stage,
                (int)op_expr_ref, (int)expect_ty_ref, (int)got_ty_ref);
        fflush(stderr);
    }
}

/** .sx typeck：`return expr` 表达式类型与函数返回类型不符；行文与 assignment type mismatch 对齐。 */
void driver_diagnostic_typeck_return_mismatch(int32_t line, int32_t col,
                                               const uint8_t *expect_buf, int32_t expect_len,
                                               const uint8_t *found_buf, int32_t found_len) {
    char msg[240];
    char epart[112];
    char fpart[112];
    int el = (expect_buf && expect_len > 0) ? (int)expect_len : 0;
    int fl = (found_buf && found_len > 0) ? (int)found_len : 0;
    if (el > 0 && el < (int)sizeof(epart)) {
        memcpy(epart, expect_buf, (size_t)el);
        epart[el] = '\0';
    } else {
        epart[0] = '?';
        epart[1] = '\0';
    }
    if (fl > 0 && fl < (int)sizeof(fpart)) {
        memcpy(fpart, found_buf, (size_t)fl);
        fpart[fl] = '\0';
    } else {
        fpart[0] = '?';
        fpart[1] = '\0';
    }
    (void)snprintf(msg, sizeof(msg),
                   "typeck error: return expression type mismatch: expected %s, found %s",
                   epart, fpart);
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs("typeck error: return expression type mismatch: expected ", stderr);
    if (expect_buf && expect_len > 0)
        (void)fwrite(expect_buf, 1, (size_t)expect_len, stderr);
    else
        (void)fputc('?', stderr);
    (void)fputs(", found ", stderr);
    if (found_buf && found_len > 0)
        (void)fwrite(found_buf, 1, (size_t)found_len, stderr);
    else
        (void)fputc('?', stderr);
    if (line > 0 || col > 0)
        fprintf(stderr, " at %d:%d", (int)line, (int)col);
    fputc('\n', stderr);
    fflush(stderr);
}

/**
 * .sx 流水线 typeck：赋值 / 复合赋值左右类型不符时打印一行 stderr，与 typeck.c 经 lsp_diag_report_typeck 的措辞一致，
 * 以便 run-typeck、负例与 shux-c 对齐（含 "assignment type mismatch: expected …, found …"）。
 */
/** .sx typeck：break/continue 不在循环内时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break) {
    const char *kw = is_break ? "break" : "continue";
    lsp_diag_report_typeck((int)line, (int)col, "'%s' only allowed inside a loop", kw);
}

/** LANG-007 v2：S0 内 *T 解引用须在 unsafe { } 内。 */
void driver_diagnostic_typeck_deref_outside_unsafe(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "pointer dereference requires unsafe block");
}

/** LANG-007 v2：S0 内 extern 调用须在 unsafe { } 内。 */
void driver_diagnostic_typeck_extern_call_outside_unsafe(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "extern call requires unsafe block");
}

/** .sx typeck：对 linear 值取址时打印，与 typeck.c「cannot take address of linear value」一致。 */
void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "cannot take address of linear value");
}

/** .sx typeck：match 臂 Enum.Variant 在模块枚举表中未命中（与 typeck.c TYPECK_ERR 措辞一致）。 */
void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col) {
    const char *msg = "typeck error: enum has no variant";
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs(msg, stderr);
    (void)fputc('\n', stderr);
}

/** .sx typeck：下标基类型非数组/切片/指针时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col) {
    const char *msg = "subscript base must be array, slice or pointer";
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs("typeck error: ", stderr);
    (void)fputs(msg, stderr);
    (void)fputc('\n', stderr);
}

/** ERR-01：`?` 要求 enclosing function 返回与 operand 同型的 Result（run-typeck result_try_bad.sx）。 */
void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col) {
    const char *msg = "`?` requires the enclosing function to return the same Result type";
    if (lsp_diag_enabled) {
        lsp_diag_report_typeck((int)line, (int)col, "%s", msg);
        return;
    }
    (void)fputs("typeck error: ", stderr);
    (void)fputs(msg, stderr);
    fprintf(stderr, " at %d:%d\n", (int)line, (int)col);
    fflush(stderr);
}

/** .sx typeck：结构体 §11.1 隐式 padding 前间隙；行文与 typeck.c TYPECK_ERR_AT 一致。 */
void driver_diagnostic_typeck_struct_padding_before(const uint8_t *sname, int32_t sname_len, int32_t gap,
                                                    const uint8_t *fname, int32_t fname_len) {
    lsp_diag_report_typeck(
        0, 0,
        "struct '%.*s' has %d byte(s) implicit padding before field '%.*s'; add explicit padding field or allow(padding)",
        (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""), (int)gap,
        (int)(fname_len > 0 ? fname_len : 0), (const char *)(fname ? fname : (const uint8_t *)""));
}

void driver_diagnostic_typeck_struct_padding_trailing(const uint8_t *sname, int32_t sname_len, int32_t gap) {
    lsp_diag_report_typeck(0, 0,
                           "struct '%.*s' has %d byte(s) implicit trailing padding; add explicit padding field or allow(padding)",
                           (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
                           (int)gap);
}

void driver_diagnostic_typeck_struct_field_bad_size(const uint8_t *sname, int32_t sname_len, const uint8_t *fname,
                                                    int32_t fname_len) {
    lsp_diag_report_typeck(0, 0, "struct '%.*s' field '%.*s' has unknown or invalid type size",
                           (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
                           (int)(fname_len > 0 ? fname_len : 0), (const char *)(fname ? fname : (const uint8_t *)""));
}

void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line, int32_t col,
                                               const uint8_t *expect_buf, int32_t expect_len,
                                               const uint8_t *found_buf, int32_t found_len) {
    char msg[240];
    char epart[112];
    char fpart[112];
    int el = (expect_buf && expect_len > 0) ? (int)expect_len : 0;
    int fl = (found_buf && found_len > 0) ? (int)found_len : 0;
    if (el > 0 && el < (int)sizeof(epart)) {
        memcpy(epart, expect_buf, (size_t)el);
        epart[el] = '\0';
    } else {
        epart[0] = '?';
        epart[1] = '\0';
    }
    if (fl > 0 && fl < (int)sizeof(fpart)) {
        memcpy(fpart, found_buf, (size_t)fl);
        fpart[fl] = '\0';
    } else {
        fpart[0] = '?';
        fpart[1] = '\0';
    }
    (void)snprintf(msg, sizeof(msg),
                   "typeck error: %s%s, found %s",
                   is_compound ? "compound assignment type mismatch: expected " : "assignment type mismatch: expected ",
                   epart, fpart);
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    (void)fputs("typeck error: ", stderr);
    (void)fputs(is_compound ? "compound assignment type mismatch: expected " : "assignment type mismatch: expected ", stderr);
    if (expect_buf && expect_len > 0)
        (void)fwrite(expect_buf, 1, (size_t)expect_len, stderr);
    else
        (void)fputc('?', stderr);
    (void)fputs(", found ", stderr);
    if (found_buf && found_len > 0)
        (void)fwrite(found_buf, 1, (size_t)found_len, stderr);
    else
        (void)fputc('?', stderr);
    fprintf(stderr, " at %d:%d\n", (int)line, (int)col);
    fflush(stderr);
}

/** 非重入也没关系：赋值诊断双缓冲（.sx check_expr_impl 格式化 expected/found 类型名）；单线程流水线专用。 */
static uint8_t g_type_diag_scratch_expect[96];
static uint8_t g_type_diag_scratch_found[96];

uint8_t *driver_typeck_diag_scratch_expect(void) { return g_type_diag_scratch_expect; }
uint8_t *driver_typeck_diag_scratch_found(void) { return g_type_diag_scratch_found; }

/** 诊断：check_block_impl 入口打印块计数；SHUX_TYPECK_BLOCK=1（常与 SHUX_TYPECK_FN 同用）。 */
void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop,
                                          int32_t n_for, int32_t n_expr, int32_t final_ref) {
    if (!getenv("SHUX_TYPECK_BLOCK"))
        return;
    fprintf(stderr,
            "shux: [SHUX_TYPECK_BLOCK] func_idx=%d block_ref=%d const=%d let=%d while=%d for=%d expr_stmt=%d final_expr=%d\n",
            (int)func_idx, (int)block_ref, (int)n_const, (int)n_let, (int)n_loop, (int)n_for, (int)n_expr, (int)final_ref);
    fflush(stderr);
}

/** 诊断：typeck_sx_ast_impl 逐函数入口；SHUX_TYPECK_FN=1 时打印 func_idx 与名称。 */
void driver_diagnostic_typeck_fn_enter(int32_t func_idx, const uint8_t *name, int32_t name_len) {
    if (!getenv("SHUX_TYPECK_FN"))
        return;
    fprintf(stderr, "shux: [SHUX_TYPECK_FN] func_idx=%d ", (int)func_idx);
    if (name && name_len > 0 && name_len <= 64)
        (void)fwrite(name, 1, (size_t)name_len, stderr);
    else
        (void)fputs("(unknown)", stderr);
    fputc('\n', stderr);
    fflush(stderr);
}

/** -sx -E 多文件诊断：codegen 前打印 module.num_funcs 与 out_buf.len，便于排查 dep 产出为空。 */
void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] before_codegen num_funcs=%d out_len=%d\n", (int)num_funcs, (int)out_len);
}

/** 诊断：pipeline 入口 ctx.entry_already_parsed。由 pipeline.sx 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_entry_already(int32_t v) {
    (void)v;
}

/** 诊断：解析前 source_len。由 pipeline.sx 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_source_len(int32_t len) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] entry_source_len=%d\n", (int)len);
}

/** 诊断：entry 解析后 module.num_funcs，便于确认是否未解析（0）。由 pipeline.sx 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_after_entry_parse(int32_t num_funcs) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] after_entry_parse num_funcs=%d\n", (int)num_funcs);
}

extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_is_extern_at(void *module, int32_t fi);

/**
 * 诊断：parse_into_buf commit 失败（arena/侧车池满等）；SHUX_DEBUG_PARSE=1 或 SHUX_PARSE_STRICT=1。
 * 大模块 typeck 单函数 commit 失败时不应整文件 abort，由 seed parse 改 skip+continue。
 */
void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                         const uint8_t *name) {
    const char *tag;
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    tag = getenv("SHUX_DEBUG_PARSE") ? "debug" : "strict";
    fprintf(stderr, "shux: parse commit fail at byte %d (num_funcs=%d)", (int)byte_pos, (int)num_funcs_so_far);
    if (name && name_len > 0 && name_len < 64) {
        fprintf(stderr, " name=");
        fwrite(name, 1, (size_t)name_len, stderr);
    }
    fprintf(stderr, " [%s]\n", tag);
    fflush(stderr);
}

/**
 * 诊断：entry 解析后 num_funcs / num_defined / num_extern 分项（A-11 typeck 截断：target num_defined=146）。
 */
void driver_diagnostic_after_entry_parse_module(void *module) {
    int32_t nf, i, ndef, next;
    if (!getenv("SHUX_DEBUG_PIPE") || !module)
        return;
    nf = pipeline_module_num_funcs(module);
    ndef = 0;
    next = 0;
    for (i = 0; i < nf; i++) {
        if (pipeline_module_func_is_extern_at(module, i) != 0)
            next++;
        else
            ndef++;
    }
    fprintf(stderr,
            "shux: [SHUX_DEBUG_PIPE] after_entry_parse num_funcs=%d num_defined=%d num_extern=%d\n", (int)nf,
            (int)ndef, (int)next);
}

/** 诊断：pipeline/typeck 阶段 marker；SHUX_DEBUG_PIPE=1 时打印（1=merge 后，2=typeck library 入口，3=validate 后）。 */
void driver_diagnostic_pipe_marker(int32_t id) {
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] pipe_marker=%d\n", (int)id);
}

/** 每个 dep codegen 后打印 j 与 out_buf.len，确认 buffer 是否递增。需要时取消注释 fprintf。 */
void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len) {
    (void)j;
    (void)out_len;
}

/** codegen 失败时打印是第几个 dep（is_dep!=0）还是当前模块（is_dep==0），便于定位 -6。需要时取消注释 fprintf。 */
void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep) {
    /* 始终打印简要失败位置；SHUX_DEBUG_PIPE=1 时前缀一致便于 grep。 */
    fprintf(stderr, "shux: codegen fail dep_index=%d is_dep=%d\n", (int)dep_index, (int)is_dep);
}

/** codegen emit_func 失败时打印函数下标与名称（pipeline_glue / ast_pool 提供读 API）。 */
void driver_diagnostic_codegen_emit_func_fail(void *module, int32_t func_index) {
    extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
    extern uint8_t pipeline_module_func_name_byte_at(void *m, int32_t fi, int32_t bi);
    int32_t nl;
    int32_t k;
    if (!module || func_index < 0)
        return;
    nl = pipeline_module_func_name_len_at(module, func_index);
    fprintf(stderr, "shux: codegen emit_func fail idx=%d name='", (int)func_index);
    for (k = 0; k < nl && k < 72; k++)
        fputc((char)pipeline_module_func_name_byte_at(module, func_index, k), stderr);
    fputc('\'', stderr);
    fputc('\n', stderr);
    fflush(stderr);
}

/** asm 后端：不支持的 ExprKind 时由 backend.sx 调用，便于定位 rc=-6；kind 为 ast_ExprKind 枚举值。 */
void driver_diagnostic_asm_unsupported_expr(int32_t kind) {
    fprintf(stderr, "shux: asm codegen unsupported ExprKind=%d\n", (int)kind);
    fflush(stderr);
}

/** asm 后端：elf_resolve_patches 找不到补丁目标标签。 */
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t len) {
    fprintf(stderr, "shux: elf unresolved patch label name_len=%d name='", (int)len);
    if (name && len > 0) {
        for (int32_t i = 0; i < len && i < 64; i++)
            fputc((char)name[i], stderr);
    }
    fputc('\'', stderr);
    fputc('\n', stderr);
    fflush(stderr);
}

/** asm 后端：Mach-O 写出时 reloc 符号名为空。 */
void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx) {
    fprintf(stderr, "shux: macho empty reloc symbol at idx=%d\n", (int)reloc_idx);
    fflush(stderr);
}

/** asm 后端：Mach-O 写出时外部 reloc 未命中 und 池（常与 macho_leading_underscore 未置 1 有关）。 */
void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx) {
    fprintf(stderr, "shux: macho undef reloc not in und pool at idx=%d\n", (int)reloc_idx);
    fflush(stderr);
}

/** asm 后端：记录当前正在 emit 的 ExprKind 序数，供 fail_at 时打印。 */
static int driver_diagnostic_asm_last_expr_kind = -1;
void driver_diagnostic_asm_set_last_expr_kind(int32_t k) {
    driver_diagnostic_asm_last_expr_kind = (int)k;
}

/** asm 后端：记录当前正在 codegen 的函数名，供 var_not_found 时打印。 */
static uint8_t driver_diagnostic_asm_current_func[72];
static int driver_diagnostic_asm_current_func_len = 0;
void driver_diagnostic_asm_set_current_func(const uint8_t *name, int32_t len) {
    const char *trace;
    driver_diagnostic_asm_current_func_len = (len > 0 && len <= 64) ? (int)len : 0;
    if (name && driver_diagnostic_asm_current_func_len > 0) {
        for (int i = 0; i < driver_diagnostic_asm_current_func_len; i++)
            driver_diagnostic_asm_current_func[i] = name[i];
    }
    /** SHUX_ASM_FUNC_TRACE=1：打印当前 asm emit 函数名，便于二分大模块失败点。 */
    trace = getenv("SHUX_ASM_FUNC_TRACE");
    if (trace && trace[0] != '\0' && trace[0] != '0' && driver_diagnostic_asm_current_func_len > 0) {
        fprintf(stderr, "asm_trace: %.*s\n", driver_diagnostic_asm_current_func_len,
                (const char *)driver_diagnostic_asm_current_func);
        fflush(stderr);
    }
}

/** backend_asm_codegen_ast_to_elf 返回 -1 时打印当前函数名（SHUX_ASM_DEBUG）。 */
void driver_diagnostic_asm_print_current_func(void) {
    if (driver_diagnostic_asm_current_func_len > 0)
        fprintf(stderr, "shux: asm codegen failed in func=%.*s\n", driver_diagnostic_asm_current_func_len,
                (const char *)driver_diagnostic_asm_current_func);
    else
        fprintf(stderr, "shux: asm codegen failed (func unknown)\n");
    fflush(stderr);
}

/** asm 后端：EXPR_VAR 在 local_offset 未找到时由 backend.sx 调用；若 num_locals>0 可传首槽名 first_slot/first_len 便于对比。 */
void driver_diagnostic_asm_var_not_found(const uint8_t *name, int32_t len, int32_t num_locals,
    const uint8_t *first_slot, int32_t first_len) {
    fprintf(stderr, "shux: asm codegen EXPR_VAR not in ctx: \"");
    if (name && len > 0 && len <= 64) {
        for (int i = 0; i < len; i++) fputc((char)name[i], stderr);
    }
    fprintf(stderr, "\" (func: ");
    if (driver_diagnostic_asm_current_func_len > 0) {
        for (int i = 0; i < driver_diagnostic_asm_current_func_len; i++)
            fputc((char)driver_diagnostic_asm_current_func[i], stderr);
    } else {
        fprintf(stderr, "?");
    }
    fprintf(stderr, ", num_locals=%d", (int)num_locals);
    if (num_locals > 0 && first_slot && first_len > 0 && first_len <= 64) {
        fprintf(stderr, ", first_slot=\"");
        for (int i = 0; i < first_len; i++) fputc((char)first_slot[i], stderr);
        fprintf(stderr, "\" len=%d", (int)first_len);
    }
    fprintf(stderr, ")\n");
    fflush(stderr);
}

/** asm 后端：返回 -1 前调用，loc 表示失败位置（1=section_text 2=globl 3=label 4=prologue 5=block_body 6=block_inits 7=emit_expr 8=epilogue），便于定位 rc=-6。 */
void driver_diagnostic_asm_fail_at(int32_t loc) {
    if (driver_diagnostic_asm_current_func_len > 0) {
        fprintf(stderr, "shux: asm codegen func=%.*s ",
                driver_diagnostic_asm_current_func_len, (const char *)driver_diagnostic_asm_current_func);
    }
    fprintf(stderr, "fail_at=%d (last_expr_kind=%d)\n", (int)loc, driver_diagnostic_asm_last_expr_kind);
    fflush(stderr);
}

void driver_debug_log(int32_t step) {
    fprintf(stderr, "[parse] step %d\n", (int)step);
    fflush(stderr);
}

void parser_diag_tok_kind(int32_t k) {
    fprintf(stderr, "[parse] r.tok.kind=%d\n", (int)k);
    fflush(stderr);
}

void parser_diag_ident_len(int32_t len) {
    fprintf(stderr, "[onefunc] first ident_len=%d\n", (int)len);
    fflush(stderr);
}

void parser_diag_scan_fail(int32_t step) {
    fprintf(stderr, "shux: library_scan fail step=%d\n", (int)step);
}

int parser_is_ident_allow(const uint8_t *ident, int len) {
    if (!ident || len != 5) return 0;
    return (ident[0] == 'a' && ident[1] == 'l' && ident[2] == 'l' && ident[3] == 'o' && ident[4] == 'w') ? 1 : 0;
}
/** DOD-CL -pad-fields：相邻 atomic-sized 与普通字段同 cache line 且无 align(64) 分隔。
 * 须在 #if SHUX_USE_SX_PIPELINE 外：C 前端 typeck.o（shux-c）也调用。 */
void driver_diagnostic_warn_pad_fields_same_cache_line(const uint8_t *sname, int32_t sname_len, const uint8_t *f0,
                                                       int32_t f0_len, const uint8_t *f1, int32_t f1_len) {
    char msg[384];
    snprintf(msg, sizeof msg,
             "warning: -pad-fields: struct '%.*s' fields '%.*s' and '%.*s' share a 64-byte cache line; "
             "consider align(64) to avoid false sharing",
             (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
             (int)(f0_len > 0 ? f0_len : 0), (const char *)(f0 ? f0 : (const uint8_t *)""),
             (int)(f1_len > 0 ? f1_len : 0), (const char *)(f1 ? f1 : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(1, 1, 2, msg);
    else
        fprintf(stderr, "%s\n", msg);
}

/** DOD-CL-S2 -hot-reorder：热标量字段宜置大字段之前；C 前端 typeck.o 亦调用。 */
void driver_diagnostic_warn_hot_reorder_field(const uint8_t *sname, int32_t sname_len, const uint8_t *hot,
                                              int32_t hot_len, const uint8_t *cold, int32_t cold_len) {
    char msg[256];
    snprintf(msg, sizeof msg,
             "warning: -hot-reorder: struct '%.*s': consider moving hot field '%.*s' before '%.*s'",
             (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
             (int)(hot_len > 0 ? hot_len : 0), (const char *)(hot ? hot : (const uint8_t *)""),
             (int)(cold_len > 0 ? cold_len : 0), (const char *)(cold ? cold : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(1, 1, 2, msg);
    else
        fprintf(stderr, "%s\n", msg);
}

/** L6-unused-hint：未使用的 let/const/import 绑定（SHUX_UNUSED_HINT=1；info 层，默认不阻断 check）。 */
void driver_diagnostic_hint_unused_binding(int32_t line, int32_t col, const uint8_t *name, int32_t name_len) {
    char msg[160];
    int ln = (line > 0) ? (int)line : 1;
    int cl = (col > 0) ? (int)col : 1;
    snprintf(msg, sizeof msg, "unused binding '%.*s'",
             (int)(name_len > 0 ? name_len : 0), (const char *)(name ? name : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(ln, cl, 3, msg);
    else
        fprintf(stderr, "info: %s\n", msg);
}
