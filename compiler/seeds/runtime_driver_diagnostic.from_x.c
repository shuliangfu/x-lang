/* seeds/runtime_driver_diagnostic.from_x.c — G-02f-12 product TU
 * Product object from this seed; logic still C until full .x port.
 */
/**
 * runtime_driver_diagnostic.c — pipeline/typeck/asm 诊断输出（Phase E-04 v34）
 *
 * 文件职责：driver_diagnostic_*、parser_diag_*、typeck 诊断 scratch；供 pipeline.x / typeck.x / backend.x 链接。
 * 所属模块：compiler 运行时 driver 诊断；bootstrap driver seed 与 shux-c 均链入。
 * 与其它文件的关系：依赖 lsp_diag、runtime_driver_abi（check_only）；不依赖 C 前端头。
 */

#include "runtime_driver_diagnostic.h"
#include "runtime_driver_abi.h"
#include "runtime_diag_codes.h"
#include "lsp/lsp_diag.h"
#include "diag.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <string.h>

extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_is_extern_at(void *module, int32_t fi);

static void driver_diag_report_prefixed(int32_t line, int32_t col, const char *msg) {
    if (lsp_diag_enabled) {
        lsp_diag_add(line > 0 ? (int)line : 1, col > 0 ? (int)col : 1, 1, msg ? msg : "");
        return;
    }
    if (driver_check_only_get())
        driver_check_diag_emitted_note();
    diag_report(NULL, (int)line, (int)col, NULL, msg ? msg : "", msg ? msg : "");
}

static void driver_diag_report_x_pipeline_code(const char *code, const char *fmt, ...) {
    va_list ap;
    char buf[256];

    if (!fmt)
        fmt = "";
    va_start(ap, fmt);
    (void)vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    if (lsp_diag_enabled) {
        lsp_diag_add_code(1, 1, 1, code, buf);
        return;
    }
    if (driver_check_only_get())
        driver_check_diag_emitted_note();
    diag_report_with_code(NULL, 0, 0, "pipeline error", code, buf, NULL);
}

static int driver_diag_copy_bytes(char *dst, size_t dst_size, const uint8_t *src, int32_t src_len) {
    int n = 0;
    if (!dst || dst_size == 0)
        return 0;
    if (src && src_len > 0) {
        while (n < src_len && (size_t)n + 1 < dst_size) {
            dst[n] = (char)src[n];
            n++;
        }
    }
    dst[n] = '\0';
    return n;
}


void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types) {
    driver_diag_report_x_pipeline_code("XP001",
                                        ".x parse failed (main_idx=%d, num_funcs=%d, arena_num_types=%d)",
                                        (int)main_idx, (int)num_funcs, (int)arena_num_types);
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
    char namebuf[72];
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
    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, name_len);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "parse skip at byte %d (num_funcs=%d, name=%s, mode=%s)",
                 (int)byte_pos, (int)num_funcs_so_far,
                 namebuf[0] ? namebuf : "?", tag);
}

/**
 * .x 流水线中 typeck_x_ast / typeck_x_ast_library 失败时打印一行 stderr。
 * 与 C 路径 lsp_diag_report_typeck 在 !lsp_diag_enabled 时的前缀一致，供 run-typeck.sh、check-7.2 等识别（.x typeck 当前不向 stderr 逐条报原因）。
 */
void driver_diagnostic_typeck_fail(void) {
    /*
     * .x check/compile 失败前通常已由更具体的 typeck 诊断（例如 XT001 或 lsp/typeck 细节）
     * 说明根因；这里不再追加泛化摘要，避免用户面出现重复的 ".x pipeline type check failed"。
     */
    (void)driver_check_only_get();
    (void)driver_check_diag_emitted_get();
}

/**
 * .x typeck：标注失败函数（下标 + 名称）与失败类别；在 driver_diagnostic_typeck_fail 一行之前打印，便于定位大模块。
 * kind：5 = check_block 失败；-6 = 非 void 函数块末隐式尾表达式。
 */
void driver_diagnostic_typeck_func_fail(int32_t func_idx, const uint8_t *name, int32_t name_len, int32_t kind) {
    char namebuf[72];
    int nl = (name && name_len > 0 && name_len <= 64) ? (int)name_len : 0;
    const char *why = kind == -6 ? "implicit tail return" : "check_block failed";

    if (nl > 0) {
        memcpy(namebuf, name, (size_t)nl);
        namebuf[nl] = '\0';
    } else {
        (void)strcpy(namebuf, "(unknown)");
    }
    if (lsp_diag_enabled) {
        char msg[240];
        (void)snprintf(msg, sizeof(msg), ".x type check failed in function #%d %s (%s)", (int)func_idx, namebuf, why);
        lsp_diag_add_code(1, 1, 1, "XT001", msg);
        return;
    }
    driver_check_diag_emitted_note();
    diag_reportf_with_code(NULL, 0, 0, "typeck error", "XT001", NULL,
                           ".x type check failed in function #%d %s (%s)", (int)func_idx, namebuf, why);
    if (kind == -6) {
        driver_diag_report_prefixed(0, 0, "typeck error: return value must use explicit return statement (e.g. return 0;)");
    }
}

/** 诊断：FIELD_ACCESS 时 base 的类型与 *T 指向名；SHUX_TYPECK_PTR=1 时打印（含模块已登记的 struct_layouts 条数）。 */
void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen, int32_t base_resolved_ref,
                                      int32_t num_struct_layouts) {
    if (!getenv("SHUX_TYPECK_PTR"))
        return;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "typeck ptr debug: FIELD_ACCESS bt_kind=%d inner_kind=%d inner_nlen=%d base_resolved_ref=%d num_struct_layouts=%d",
                 (int)bt_kind, (int)inner_kind, (int)inner_nlen, (int)base_resolved_ref, (int)num_struct_layouts);
}

/** 诊断：EXPR_RETURN 失败；SHUX_TYPECK_RET=1 时额外打印 ref 调试。stage 1=operand check_expr -1；2=got 与期望 return_type_ref 不一致。 */
void driver_diagnostic_typeck_ret_fail(int32_t stage, int32_t op_expr_ref, int32_t expect_ty_ref, int32_t got_ty_ref) {
    if (getenv("SHUX_TYPECK_RET")) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "typeck return debug: stage=%d op_expr_ref=%d expect_ty_ref=%d got_ty_ref=%d",
                     (int)stage, (int)op_expr_ref, (int)expect_ty_ref, (int)got_ty_ref);
    }
}

void driver_diagnostic_typeck_binop_operands(int32_t expr_ref, int32_t left_ref, int32_t right_ref,
                                             int32_t left_kind, int32_t right_kind,
                                             int32_t left_block_ref, int32_t right_block_ref,
                                             int32_t left_ty_ref, int32_t right_ty_ref,
                                             const uint8_t *left_ty, int32_t left_ty_len,
                                             const uint8_t *right_ty, int32_t right_ty_len) {
    char left_buf[112];
    char right_buf[112];
    if (!getenv("SHUX_TYPECK_BINOP"))
        return;
    driver_diag_copy_bytes(left_buf, sizeof(left_buf), left_ty, left_ty_len);
    driver_diag_copy_bytes(right_buf, sizeof(right_buf), right_ty, right_ty_len);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "typeck binop debug: expr=%d left_ref=%d left_kind=%d left_block=%d left_ty_ref=%d left_ty=%s right_ref=%d right_kind=%d right_block=%d right_ty_ref=%d right_ty=%s",
                 (int)expr_ref, (int)left_ref, (int)left_kind, (int)left_block_ref, (int)left_ty_ref, left_buf[0] ? left_buf : "?",
                 (int)right_ref, (int)right_kind, (int)right_block_ref, (int)right_ty_ref, right_buf[0] ? right_buf : "?");
}

void driver_diagnostic_parser_onefunc_param_ref(const uint8_t *func_name, int32_t func_name_len,
                                                const uint8_t *param_name, int32_t param_name_len,
                                                int32_t stage, int32_t param_idx, int32_t type_ref) {
    char func_buf[72];
    char param_buf[72];
    if (!getenv("SHUX_PARSE_PARAM"))
        return;
    driver_diag_copy_bytes(func_buf, sizeof(func_buf), func_name, func_name_len);
    driver_diag_copy_bytes(param_buf, sizeof(param_buf), param_name, param_name_len);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "parser param debug: func=%s stage=%d param_idx=%d param=%s type_ref=%d",
                 func_buf[0] ? func_buf : "?", (int)stage, (int)param_idx,
                 param_buf[0] ? param_buf : "?", (int)type_ref);
}

/** .x typeck：`return expr` 表达式类型与函数返回类型不符；行文与 assignment type mismatch 对齐。 */
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
    driver_diag_report_prefixed(line, col, msg);
}

void driver_diagnostic_typeck_return_unresolved(int32_t line, int32_t col,
                                                const uint8_t *expr_buf, int32_t expr_len) {
    char msg[240];
    char expr_part[128];
    int el = (expr_buf && expr_len > 0) ? (int)expr_len : 0;
    if (el > 0 && el < (int)sizeof(expr_part)) {
        memcpy(expr_part, expr_buf, (size_t)el);
        expr_part[el] = '\0';
    } else {
        (void)strcpy(expr_part, "?");
    }
    (void)snprintf(msg, sizeof(msg), "typeck error: cannot resolve return subexpression: %s", expr_part);
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    driver_diag_report_prefixed(line, col, msg);
}

void driver_diagnostic_typeck_return_subexpr(int32_t line, int32_t col,
                                             const uint8_t *expr_buf, int32_t expr_len) {
    char msg[240];
    char expr_part[128];
    int el = (expr_buf && expr_len > 0) ? (int)expr_len : 0;
    if (el > 0 && el < (int)sizeof(expr_part)) {
        memcpy(expr_part, expr_buf, (size_t)el);
        expr_part[el] = '\0';
    } else {
        (void)strcpy(expr_part, "?");
    }
    (void)snprintf(msg, sizeof(msg), "typeck note: return subexpression: %s", expr_part);
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    driver_diag_report_prefixed(line, col, msg);
}

void driver_diagnostic_typeck_call_not_generic(int32_t line, int32_t col,
                                               const uint8_t *name, int32_t name_len) {
    lsp_diag_report_typeck((int)line, (int)col,
                           "function '%.*s' is not generic but type arguments were provided",
                           (int)(name_len > 0 ? name_len : 0),
                           (const char *)(name ? name : (const uint8_t *)""));
}

void driver_diagnostic_typeck_call_wrong_num_type_args(int32_t line, int32_t col,
                                                       const uint8_t *name, int32_t name_len,
                                                       int32_t expect_n, int32_t got_n) {
    lsp_diag_report_typeck((int)line, (int)col,
                           "generic function '%.*s' expects %d type arguments, got %d",
                           (int)(name_len > 0 ? name_len : 0),
                           (const char *)(name ? name : (const uint8_t *)""),
                           (int)expect_n, (int)got_n);
}

void driver_diagnostic_typeck_call_requires_type_args(int32_t line, int32_t col,
                                                      const uint8_t *name, int32_t name_len) {
    lsp_diag_report_typeck((int)line, (int)col,
                           "generic function '%.*s' requires type arguments (e.g. %.*s<Type>(...))",
                           (int)(name_len > 0 ? name_len : 0),
                           (const char *)(name ? name : (const uint8_t *)""),
                           (int)(name_len > 0 ? name_len : 0),
                           (const char *)(name ? name : (const uint8_t *)""));
}

/**
 * .x 流水线 typeck：赋值 / 复合赋值左右类型不符时打印一行 stderr，与 typeck.c 经 lsp_diag_report_typeck 的措辞一致，
 * 以便 run-typeck、负例与 shux-c 对齐（含 "assignment type mismatch: expected …, found …"）。
 */
/** .x typeck：break/continue 不在循环内时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
void driver_diagnostic_typeck_break_continue_outside(int32_t line, int32_t col, int32_t is_break) {
    const char *kw = is_break ? "break" : "continue";
    lsp_diag_report_typeck((int)line, (int)col, "'%s' only allowed inside a loop", kw);
}

void driver_diagnostic_typeck_if_condition_not_bool(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "if condition must be bool (no implicit int-to-bool)");
}

void driver_diagnostic_typeck_while_condition_not_bool(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "while condition must be bool (no implicit int-to-bool)");
}

void driver_diagnostic_typeck_for_condition_not_bool(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "for condition must be bool (no implicit int-to-bool)");
}

/** LANG-007 v2：S0 内 *T 解引用须在 unsafe { } 内。 */
void driver_diagnostic_typeck_deref_outside_unsafe(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "pointer dereference requires unsafe block");
}

/** LANG-007 v2：S0 内 extern 调用须在 unsafe { } 内。 */
void driver_diagnostic_typeck_extern_call_outside_unsafe(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "extern call requires unsafe block");
}

/** .x typeck：对 linear 值取址时打印，与 typeck.c「cannot take address of linear value」一致。 */
void driver_diagnostic_typeck_linear_addr_of(int32_t line, int32_t col) {
    lsp_diag_report_typeck((int)line, (int)col, "cannot take address of linear value");
}

/** .x typeck：import 顶层 const 裸名访问时打印，与 typeck.c TYPECK_ERR 措辞对齐。 */
void driver_diagnostic_typeck_import_const_must_be_qualified(int32_t line, int32_t col, const uint8_t *name,
                                                             int32_t name_len, const uint8_t *binding,
                                                             int32_t binding_len) {
    if (binding && binding_len > 0) {
        lsp_diag_report_typeck((int)line, (int)col,
                               "import constant '%.*s' must be qualified; use %.*s.%.*s",
                               (int)(name_len > 0 ? name_len : 0),
                               (const char *)(name ? name : (const uint8_t *)""),
                               (int)binding_len, (const char *)binding,
                               (int)(name_len > 0 ? name_len : 0),
                               (const char *)(name ? name : (const uint8_t *)""));
        return;
    }
    lsp_diag_report_typeck((int)line, (int)col,
                           "import constant '%.*s' must be qualified as binding.%.*s",
                           (int)(name_len > 0 ? name_len : 0),
                           (const char *)(name ? name : (const uint8_t *)""),
                           (int)(name_len > 0 ? name_len : 0),
                           (const char *)(name ? name : (const uint8_t *)""));
}

/** .x typeck：match 臂 Enum.Variant 在模块枚举表中未命中（与 typeck.c TYPECK_ERR 措辞一致）。 */
void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col) {
    const char *msg = "typeck error: enum has no variant";
    if (lsp_diag_enabled) {
        lsp_diag_add((int)line, (int)col, 1, msg);
        return;
    }
    driver_diag_report_prefixed(line, col, msg);
}

/** .x typeck：下标基类型非数组/切片/指针时打印，与 typeck.c TYPECK_ERR 措辞一致。 */
void driver_diagnostic_typeck_subscript_base(int32_t line, int32_t col) {
    const char *msg = "subscript base must be array, slice or pointer";
    if (lsp_diag_enabled) {
        lsp_diag_add_code((int)line, (int)col, 1, "T001", msg);
        return;
    }
    diag_report_with_code(NULL, (int)line, (int)col, "typeck error", "T001", msg, msg);
}

/** ERR-01：`?` 要求 enclosing function 返回与 operand 同型的 Result（run-typeck result_try_bad.x）。 */
void driver_diagnostic_typeck_try_propagate_bad_enclosing(int32_t line, int32_t col) {
    const char *msg = "`?` requires the enclosing function to return the same Result type";
    if (lsp_diag_enabled) {
        lsp_diag_report_typeck_code("T001", (int)line, (int)col, "%s", msg);
        return;
    }
    diag_report_with_code(NULL, (int)line, (int)col, "typeck error", "T001", msg, msg);
}

/** .x typeck：结构体 §11.1 隐式 padding 前间隙；行文与 typeck.c TYPECK_ERR_AT 一致。 */
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
    driver_diag_report_prefixed(line, col, msg);
}

/** 非重入也没关系：赋值诊断双缓冲（.x check_expr_impl 格式化 expected/found 类型名）；单线程流水线专用。 */
static uint8_t g_type_diag_scratch_expect[96];
static uint8_t g_type_diag_scratch_found[96];

uint8_t *driver_typeck_diag_scratch_expect(void) { return g_type_diag_scratch_expect; }
uint8_t *driver_typeck_diag_scratch_found(void) { return g_type_diag_scratch_found; }

/** 诊断：check_block_impl 入口打印块计数；SHUX_TYPECK_BLOCK=1（常与 SHUX_TYPECK_FN 同用）。 */
void driver_diagnostic_typeck_block_enter(int32_t func_idx, int32_t block_ref, int32_t n_const, int32_t n_let, int32_t n_loop,
                                          int32_t n_for, int32_t n_expr, int32_t final_ref) {
    if (!getenv("SHUX_TYPECK_BLOCK"))
        return;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "typeck block debug: func_idx=%d block_ref=%d const=%d let=%d while=%d for=%d expr_stmt=%d final_expr=%d",
                 (int)func_idx, (int)block_ref, (int)n_const, (int)n_let, (int)n_loop, (int)n_for, (int)n_expr, (int)final_ref);
}

/** 诊断：typeck_x_ast_impl 逐函数入口；SHUX_TYPECK_FN=1 时打印 func_idx 与名称。 */
void driver_diagnostic_typeck_fn_enter(int32_t func_idx, const uint8_t *name, int32_t name_len) {
    char namebuf[72];
    if (!getenv("SHUX_TYPECK_FN"))
        return;
    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, name_len);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "typeck function debug: func_idx=%d name=%s",
                 (int)func_idx, namebuf[0] ? namebuf : "(unknown)");
}

/** 诊断：EXPR_VAR 解析来源；SHUX_TYPECK_VAR=1 时打印。source 1=block, 2=param, 3=top-level。 */
void driver_diagnostic_typeck_var_resolution(int32_t expr_ref, const uint8_t *name, int32_t name_len,
                                             int32_t func_idx, int32_t block_ref, int32_t source, int32_t type_ref) {
    char namebuf[72];
    if (!getenv("SHUX_TYPECK_VAR"))
        return;
    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, name_len);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "typeck var debug: expr=%d name=%s func=%d block=%d source=%d type_ref=%d",
                 (int)expr_ref, namebuf[0] ? namebuf : "?", (int)func_idx, (int)block_ref,
                 (int)source, (int)type_ref);
}

/** -x -E 多文件诊断：codegen 前打印 module.num_funcs 与 out_buf.len，便于排查 dep 产出为空。 */
void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len) {
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: before_codegen num_funcs=%d out_len=%d",
                     (int)num_funcs, (int)out_len);
}

/** 诊断：pipeline 入口 ctx.entry_already_parsed。由 pipeline.x 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_entry_already(int32_t v) {
    (void)v;
}

/** 诊断：解析前 source_len。由 pipeline.x 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_source_len(int32_t len) {
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: entry_source_len=%d", (int)len);
}

/** 诊断：entry 解析后 module.num_funcs，便于确认是否未解析（0）。由 pipeline.x 调用。需要时取消注释 fprintf。 */
void driver_diagnostic_after_entry_parse(int32_t num_funcs) {
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: after_entry_parse num_funcs=%d", (int)num_funcs);
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
    char namebuf[72];
    int nl = (name && name_len > 0 && name_len < 64) ? (int)name_len : 0;
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    tag = getenv("SHUX_DEBUG_PARSE") ? "debug" : "strict";
    if (nl > 0) {
        memcpy(namebuf, name, (size_t)nl);
        namebuf[nl] = '\0';
    } else {
        (void)strcpy(namebuf, "?");
    }
    driver_diag_report_x_pipeline_code("XP002",
                                        ".x parse commit failed at byte %d (num_funcs=%d, name=%s, mode=%s)",
                                        (int)byte_pos, (int)num_funcs_so_far, namebuf, tag);
}

/**
 * 诊断：parse_into/parse_into_buf 在提交函数槽前打印 generic 计数，定位 OneFuncResult 到 module.funcs 的污染链。
 * 环境变量 SHUX_DEBUG_PARSE_GENERIC=1。
 */
void driver_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name, int32_t name_len,
                                          int32_t num_generic_params, int32_t is_main) {
    char namebuf[72];
    if (!getenv("SHUX_DEBUG_PARSE_GENERIC"))
        return;
    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, name_len);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "parse generic debug: byte=%d num_funcs=%d generic=%d is_main=%d name=%s",
                 (int)byte_pos, (int)num_funcs_so_far, (int)num_generic_params, (int)is_main,
                 namebuf[0] ? namebuf : "?");
}

/**
 * 诊断：函数体提交前后打印 OneFunc sidecar 与 Block 形状，定位污染发生在 fill 之前还是 body_ref 绑定之后。
 * 环境变量 SHUX_DEBUG_PARSE_COMMIT=1。
 */
void driver_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name, int32_t name_len,
                                          int32_t phase, int32_t block_ref, int32_t pool_num_consts,
                                          int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions,
                                          int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets,
                                          int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order,
                                          int32_t final_expr_ref) {
    char namebuf[72];
    const char *phase_name;
    if (!getenv("SHUX_DEBUG_PARSE_COMMIT"))
        return;
    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, name_len);
    phase_name = (phase == 0) ? "pre_fill" : ((phase == 1) ? "post_block" : "unknown");
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "parse commit debug: byte=%d num_funcs=%d phase=%s block=%d pool(c=%d l=%d if=%d reg=%d so=%d) block(c=%d l=%d if=%d reg=%d so=%d fin=%d) name=%s",
                 (int)byte_pos, (int)num_funcs_so_far, phase_name, (int)block_ref, (int)pool_num_consts,
                 (int)pool_num_lets, (int)pool_num_ifs, (int)pool_num_regions, (int)pool_num_stmt_order,
                 (int)block_num_consts, (int)block_num_lets, (int)block_num_ifs, (int)block_num_regions,
                 (int)block_num_stmt_order, (int)final_expr_ref, namebuf[0] ? namebuf : "?");
}

void parser_diagnostic_parse_commit_shape(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name, int32_t name_len,
                                          int32_t phase, int32_t block_ref, int32_t pool_num_consts,
                                          int32_t pool_num_lets, int32_t pool_num_ifs, int32_t pool_num_regions,
                                          int32_t pool_num_stmt_order, int32_t block_num_consts, int32_t block_num_lets,
                                          int32_t block_num_ifs, int32_t block_num_regions, int32_t block_num_stmt_order,
                                          int32_t final_expr_ref) {
    driver_diagnostic_parse_commit_shape(byte_pos, num_funcs_so_far, name, name_len, phase, block_ref, pool_num_consts,
                                         pool_num_lets, pool_num_ifs, pool_num_regions, pool_num_stmt_order,
                                         block_num_consts, block_num_lets, block_num_ifs, block_num_regions,
                                         block_num_stmt_order, final_expr_ref);
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
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "pipeline debug: after_entry_parse num_funcs=%d num_defined=%d num_extern=%d",
                 (int)nf, (int)ndef, (int)next);
    {
        struct ast_ModuleThin {
            int32_t num_funcs;
            int32_t main_func_index;
            int32_t num_imports;
            int32_t num_top_level_lets;
        };
        struct ast_ModuleThin *m_local = (struct ast_ModuleThin *)module;
        int32_t ntl = m_local ? m_local->num_top_level_lets : 0;
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: after_entry_parse num_top_level_lets=%d",
                     (int)ntl);
    }
}

/** 诊断：pipeline/typeck 阶段 marker；SHUX_DEBUG_PIPE=1 时打印（1=merge 后，2=typeck library 入口，3=validate 后）。 */
void driver_diagnostic_pipe_marker(int32_t id) {
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: pipe_marker=%d", (int)id);
}

/** 每个 dep codegen 后打印 j 与 out_buf.len，确认 buffer 是否递增。需要时取消注释 fprintf。 */
void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len) {
    (void)j;
    (void)out_len;
}

/** codegen 失败时打印是第几个 dep（is_dep!=0）还是当前模块（is_dep==0），便于定位 -6。需要时取消注释 fprintf。 */
void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "codegen failed at %s (dep_index=%d)",
                 is_dep ? "dependency emission" : "entry module emission", (int)dep_index);
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
    {
        char namebuf[80];
        int out_i = 0;
        for (k = 0; k < nl && k < 72; k++)
            namebuf[out_i++] = (char)pipeline_module_func_name_byte_at(module, func_index, k);
        namebuf[out_i] = '\0';
        diag_reportf_with_code(NULL, 0, 0, "codegen error", SHUX_DIAG_CODE_CODEGEN_CG003, NULL,
                               "failed to emit function '%s' (idx=%d)",
                               out_i > 0 ? namebuf : "?", (int)func_index);
    }
}

/** asm 后端：不支持的 ExprKind 时由 backend.x 调用，便于定位 rc=-6；kind 为 ast_ExprKind 枚举值。 */
void driver_diagnostic_asm_unsupported_expr(int32_t kind) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm codegen unsupported ExprKind=%d", (int)kind);
}

/** asm 后端：elf_resolve_patches 找不到补丁目标标签。 */
void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t len) {
    char namebuf[65];
    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, len);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "elf unresolved patch label name_len=%d name='%s'",
                 (int)len, namebuf);
}

/** asm 后端：Mach-O 写出时 reloc 符号名为空。 */
void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "macho empty reloc symbol at idx=%d", (int)reloc_idx);
}

/** asm 后端：Mach-O 写出时外部 reloc 未命中 und 池（常与 macho_leading_underscore 未置 1 有关）。 */
void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "macho undef reloc not in und pool at idx=%d", (int)reloc_idx);
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
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm trace: %.*s", driver_diagnostic_asm_current_func_len,
                     (const char *)driver_diagnostic_asm_current_func);
    }
}

/** backend_asm_codegen_ast_to_elf 返回 -1 时打印当前函数名（SHUX_ASM_DEBUG）。 */
void driver_diagnostic_asm_print_current_func(void) {
    if (driver_diagnostic_asm_current_func_len > 0)
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen failed in func=%.*s",
                     driver_diagnostic_asm_current_func_len,
                     (const char *)driver_diagnostic_asm_current_func);
    else
        diag_report(NULL, 0, 0, "note", "asm codegen failed (func unknown)", NULL);
}

/** asm 后端：EXPR_VAR 在 local_offset 未找到时由 backend.x 调用；若 num_locals>0 可传首槽名 first_slot/first_len 便于对比。 */
void driver_diagnostic_asm_var_not_found(const uint8_t *name, int32_t len, int32_t num_locals,
    const uint8_t *first_slot, int32_t first_len) {
    char namebuf[65];
    char firstbuf[65];
    const char *func_name = "?";
    int func_name_len = 1;

    driver_diag_copy_bytes(namebuf, sizeof(namebuf), name, len);
    driver_diag_copy_bytes(firstbuf, sizeof(firstbuf), first_slot, first_len);
    if (driver_diagnostic_asm_current_func_len > 0) {
        func_name = (const char *)driver_diagnostic_asm_current_func;
        func_name_len = driver_diagnostic_asm_current_func_len;
    }
    if (num_locals > 0 && first_slot && first_len > 0 && first_len <= 64) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen EXPR_VAR not in ctx: \"%s\" (func: %.*s, num_locals=%d, first_slot=\"%s\" len=%d)",
                     namebuf, func_name_len, func_name, (int)num_locals, firstbuf, (int)first_len);
    } else {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen EXPR_VAR not in ctx: \"%s\" (func: %.*s, num_locals=%d)",
                     namebuf, func_name_len, func_name, (int)num_locals);
    }
}

/** asm 后端：返回 -1 前调用，loc 表示失败位置（1=section_text 2=globl 3=label 4=prologue 5=block_body 6=block_inits 7=emit_expr 8=epilogue），便于定位 rc=-6。 */
void driver_diagnostic_asm_fail_at(int32_t loc) {
    const char *func_name = "?";
    int func_name_len = 1;
    if (driver_diagnostic_asm_current_func_len > 0) {
        func_name = (const char *)driver_diagnostic_asm_current_func;
        func_name_len = driver_diagnostic_asm_current_func_len;
    }
    if (driver_diagnostic_asm_current_func_len > 0) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm codegen func=%.*s fail_at=%d (last_expr_kind=%d)",
                     func_name_len, func_name, (int)loc, driver_diagnostic_asm_last_expr_kind);
        return;
    }
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm codegen fail_at=%d (last_expr_kind=%d)",
                 (int)loc, driver_diagnostic_asm_last_expr_kind);
}

void driver_debug_log(int32_t step) {
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "parse debug: step=%d", (int)step);
}

void parser_diag_tok_kind(int32_t k) {
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "parse debug: r.tok.kind=%d", (int)k);
}

void parser_diag_ident_len(int32_t len) {
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "parse debug: first ident_len=%d", (int)len);
}

void parser_diag_scan_fail(int32_t step) {
    if (!getenv("SHUX_DEBUG_PARSE") && !driver_parse_strict_enabled())
        return;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "library scan failed at step=%d", (int)step);
}

int parser_is_ident_allow(const uint8_t *ident, int len) {
    if (!ident || len != 5) return 0;
    return (ident[0] == 'a' && ident[1] == 'l' && ident[2] == 'l' && ident[3] == 'o' && ident[4] == 'w') ? 1 : 0;
}
/** DOD-CL -pad-fields：相邻 atomic-sized 与普通字段同 cache line 且无 align(64) 分隔。
 * 须在 #if SHUX_USE_X_PIPELINE 外：C 前端 typeck.o（shux-c）也调用。 */
void driver_diagnostic_warn_pad_fields_same_cache_line(const uint8_t *sname, int32_t sname_len, const uint8_t *f0,
                                                       int32_t f0_len, const uint8_t *f1, int32_t f1_len) {
    char msg[384];
    snprintf(msg, sizeof msg,
             "-pad-fields: struct '%.*s' fields '%.*s' and '%.*s' share a 64-byte cache line; "
             "consider align(64) to avoid false sharing",
             (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
             (int)(f0_len > 0 ? f0_len : 0), (const char *)(f0 ? f0 : (const uint8_t *)""),
             (int)(f1_len > 0 ? f1_len : 0), (const char *)(f1 ? f1 : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(1, 1, 2, msg);
    else
        diag_report(NULL, 0, 0, "warning", msg, NULL);
}

/** DOD-CL-S2 -hot-reorder：热标量字段宜置大字段之前；C 前端 typeck.o 亦调用。 */
void driver_diagnostic_warn_hot_reorder_field(const uint8_t *sname, int32_t sname_len, const uint8_t *hot,
                                              int32_t hot_len, const uint8_t *cold, int32_t cold_len) {
    char msg[256];
    snprintf(msg, sizeof msg,
             "-hot-reorder: struct '%.*s': consider moving hot field '%.*s' before '%.*s'",
             (int)(sname_len > 0 ? sname_len : 0), (const char *)(sname ? sname : (const uint8_t *)""),
             (int)(hot_len > 0 ? hot_len : 0), (const char *)(hot ? hot : (const uint8_t *)""),
             (int)(cold_len > 0 ? cold_len : 0), (const char *)(cold ? cold : (const uint8_t *)""));
    if (lsp_diag_enabled)
        lsp_diag_add(1, 1, 2, msg);
    else
        diag_report(NULL, 0, 0, "warning", msg, NULL);
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
        diag_report(NULL, ln, cl, "info", msg, NULL);
}
