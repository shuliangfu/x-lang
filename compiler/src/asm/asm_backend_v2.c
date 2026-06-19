/**
 * asm_backend_v2.c — ARM64 汇编后端 v2
 * 直接用 C parser 拿 AST，递归遍历生成 ARM64 .s
 * 支持：return N, 算术, 比较, if, let/const 声明, while
 */
#include "ast.h"
#include "lexer/lexer.h"
#include "parser/parser.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static FILE *s;
static int indent;
static int label_id;
static int stack_off;   /* 当前栈偏移（字节），从 16 开始 */
static int var_off[256]; /* 变量名 hash → 栈偏移，简化 */
static char *var_names[256];
static int nvars;

#define emitf(...) do { for(int _i=0;_i<indent;_i++) fputc(' ',s); fprintf(s,__VA_ARGS__); fputc('\n',s); } while(0)

static void asm_expr(const struct ASTExpr *e);
static void asm_block(const struct ASTBlock *b);

static int find_var(const char *name) {
    for (int i = 0; i < nvars; i++)
        if (var_names[i] && strcmp(var_names[i], name) == 0) return i;
    return -1;
}

static int add_var(const char *name) {
    if (nvars >= 256 || !name) return -1;
    var_names[nvars] = (char*)name;
    var_off[nvars] = stack_off;
    stack_off += 8;
    return nvars++;
}

static void asm_expr(const struct ASTExpr *e) {
    if (!e) return;
    switch (e->kind) {
    case AST_EXPR_LIT:
        emitf("mov x0, #%d", e->value.int_val);
        break;
    case AST_EXPR_BOOL_LIT:
        emitf("mov x0, #%d", e->value.int_val ? 1 : 0);
        break;
    case AST_EXPR_VAR: {
        int vi = find_var(e->value.var.name);
        if (vi >= 0)
            emitf("ldr x0, [x29, #-%d]", var_off[vi]);
        else
            emitf("mov x0, #0 // var '%s' not found", e->value.var.name);
        break;
    }
    case AST_EXPR_BLOCK:
        if (e->value.block) asm_block(e->value.block);
        else emitf("mov x0, #0");
        break;

    /* 二元运算：先算左存 x1，再算右存 x0，然后运算 */
    case AST_EXPR_ADD:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("add x0, x1, x0"); break;
    case AST_EXPR_SUB:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("sub x0, x1, x0"); break;
    case AST_EXPR_MUL:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("mul x0, x1, x0"); break;
    case AST_EXPR_DIV:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("sdiv x0, x1, x0"); break;
    case AST_EXPR_MOD:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("sdiv x8, x1, x0"); emitf("msub x0, x8, x0, x1"); break;
    case AST_EXPR_BITAND:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("and x0, x1, x0"); break;
    case AST_EXPR_BITOR:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("orr x0, x1, x0"); break;
    case AST_EXPR_BITXOR:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("eor x0, x1, x0"); break;
    case AST_EXPR_SHL:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("lsl x0, x1, x0"); break;
    case AST_EXPR_SHR:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("asr x0, x1, x0"); break;

    case AST_EXPR_EQ:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("cmp x1, x0"); emitf("cset x0, eq"); break;
    case AST_EXPR_NE:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("cmp x1, x0"); emitf("cset x0, ne"); break;
    case AST_EXPR_LT:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("cmp x1, x0"); emitf("cset x0, lt"); break;
    case AST_EXPR_LE:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("cmp x1, x0"); emitf("cset x0, le"); break;
    case AST_EXPR_GT:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("cmp x1, x0"); emitf("cset x0, gt"); break;
    case AST_EXPR_GE:
        asm_expr(e->value.binop.left);  emitf("mov x1, x0"); asm_expr(e->value.binop.right); emitf("cmp x1, x0"); emitf("cset x0, ge"); break;

    case AST_EXPR_NEG:
        asm_expr(e->value.unary.operand); emitf("neg x0, x0"); break;
    case AST_EXPR_BITNOT:
        asm_expr(e->value.unary.operand); emitf("mvn x0, x0"); break;
    case AST_EXPR_LOGNOT:
        asm_expr(e->value.unary.operand); emitf("cmp x0, #0"); emitf("cset x0, eq"); break;
    case AST_EXPR_RETURN:
        if (e->value.unary.operand) asm_expr(e->value.unary.operand);
        else emitf("mov x0, #0");
        break;

    /* 短路逻辑 */
    case AST_EXPR_LOGAND: {
        int lid = label_id++;
        asm_expr(e->value.binop.left);  emitf("cmp x0, #0"); emitf("cset x0, ne"); emitf("cmp x0, #0"); emitf("b.eq L_and_f_%d", lid);
        asm_expr(e->value.binop.right); emitf("cmp x0, #0"); emitf("cset x0, ne");
        emitf("L_and_f_%d:", lid); break;
    }
    case AST_EXPR_LOGOR: {
        int lid = label_id++;
        asm_expr(e->value.binop.left);  emitf("cmp x0, #0"); emitf("cset x0, ne"); emitf("cmp x0, #0"); emitf("b.ne L_or_t_%d", lid);
        asm_expr(e->value.binop.right); emitf("cmp x0, #0"); emitf("cset x0, ne");
        emitf("L_or_t_%d:", lid); break;
    }

    /* if 表达式 */
    case AST_EXPR_IF: {
        int lid = label_id++;
        asm_expr(e->value.if_expr.cond);
        emitf("cmp x0, #0");
        emitf("b.eq L_else_%d", lid);
        asm_expr(e->value.if_expr.then_expr);
        emitf("b L_end_%d", lid);
        emitf("L_else_%d:", lid);
        if (e->value.if_expr.else_expr) asm_expr(e->value.if_expr.else_expr); else emitf("mov x0, #0");
        emitf("L_end_%d:", lid); break;
    }

    /*** 语句类（不产生值，但有副作用）***/
    /* 赋值语句 left = right */
    case AST_EXPR_ASSIGN: {
        if (e->value.binop.left && e->value.binop.left->kind == AST_EXPR_VAR) {
            const char *nm = e->value.binop.left->value.var.name;
            int vi = find_var(nm);
            asm_expr(e->value.binop.right);
            if (vi >= 0) emitf("str x0, [x29, #-%d]", var_off[vi]);
            else emitf("// assign to unknown var '%s'", nm);
        } else { emitf("// NYI: assign to non-var"); }
        break;
    }

    default:
        emitf("mov x0, #0 // NYI kind=%d", e->kind); break;
    }
}

/* ──── 块：const_decls, let_decls, expr_stmts, loops, final_expr ──── */
static void asm_block(const struct ASTBlock *b) {
    if (!b) { emitf("mov x0, #0"); return; }

    /* const/let 声明 */
    for (int i = 0; i < b->num_consts && i < 128; i++) {
        const struct ASTConstDecl *cd = &b->const_decls[i];
        add_var(cd->name);
        emitf("// const %s", cd->name);
        if (cd->init) asm_expr(cd->init);
        int vi = find_var(cd->name);
        if (vi >= 0) emitf("str x0, [x29, #-%d]", var_off[vi]);
    }
    for (int i = 0; i < b->num_lets && i < 128; i++) {
        const struct ASTLetDecl *ld = &b->let_decls[i];
        add_var(ld->name);
        emitf("// let %s", ld->name);
        if (ld->init) asm_expr(ld->init);
        int vi = find_var(ld->name);
        if (vi >= 0) emitf("str x0, [x29, #-%d]", var_off[vi]);
    }

    /* while 循环 */
    for (int i = 0; i < b->num_loops && i < 8; i++) {
        int lid = label_id++;
        const struct ASTWhileLoop *wl = &b->loops[i];
        emitf("L_while_%d:", lid);
        if (wl->cond) { asm_expr(wl->cond); emitf("cmp x0, #0"); emitf("b.eq L_while_end_%d", lid); }
        if (wl->body) asm_block(wl->body);
        emitf("b L_while_%d", lid);
        emitf("L_while_end_%d:", lid);
    }

    /* 表达式语句 (expr;) */
    for (int i = 0; i < b->num_expr_stmts && i < 128; i++) {
        if (b->expr_stmts[i]) asm_expr(b->expr_stmts[i]);
    }

    /* final_expr */
    if (b->final_expr) asm_expr(b->final_expr);
    else emitf("mov x0, #0");
}

/* ──── 生成单个函数 ──── */
static void asm_func(const struct ASTFunc *fn) {
    if (!fn || !fn->name) return;
    emitf(".globl _%s", fn->name);
    emitf(".p2align 2");
    emitf("_%s:", fn->name);
    indent = 4;

    /* 重置栈状态 */
    nvars = 0;
    stack_off = 16;
    /* 参数 */
    for (int i = 0; i < fn->num_params && i < 16; i++) {
        add_var(fn->params[i].name);
    }

    int fs = ((stack_off + 15) / 16) * 16; /* frame size, 16 对齐 */
    emitf("stp x29, x30, [sp, #-%d]!", fs);
    emitf("mov x29, sp");
    /* 保存参数 */
    for (int i = 0; i < fn->num_params && i < 16 && i < 8; i++) {
        emitf("str x%d, [x29, #-%d]", i, var_off[i]);
    }

    if (fn->body) {
        asm_block(fn->body);
    } else {
        emitf("mov x0, #0");
    }

    emitf("ldp x29, x30, [sp], #%d", fs);
    emitf("ret");
    indent = 0;
}

/* ──── 模块 ──── */
static void asm_module(struct ASTModule *m) {
    emitf(".text");
    emitf("");
    for (int i = 0; i < m->num_funcs && i < 64; i++) {
        asm_func(m->funcs[i]);
        emitf("");
    }
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "Usage: %s <in.sx> [-o <out>]\n", argv[0]); return 1; }

    const char *in = argv[1];
    const char *out = "a.out";
    for (int i = 2; i < argc; i++)
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) out = argv[i + 1];

    FILE *fi = fopen(in, "r");
    if (!fi) { perror(in); return 1; }
    fseek(fi, 0, SEEK_END);
    size_t len = ftell(fi);
    fseek(fi, 0, SEEK_SET);
    char *src = malloc(len + 1);
    fread(src, 1, len, fi); fclose(fi); src[len] = 0;

    Lexer *lex = lexer_new(src);
    if (!lex) { free(src); return 1; }
    ASTModule *mod = NULL;
    if (parse(lex, &mod) != 0 || !mod) {
        fprintf(stderr, "parse failed\n"); lexer_free(lex); free(src); return 1;
    }
    lexer_free(lex); free(src);
    printf("[asm_v2] parsed %d funcs\n", mod->num_funcs);

    char tmp_s[256];
    snprintf(tmp_s, sizeof(tmp_s), "/tmp/shux_asmv2_%d.s", getpid());
    s = fopen(tmp_s, "w");
    if (!s) { perror(tmp_s); return 1; }
    label_id = 0;
    asm_module(mod);
    fclose(s);

    char tmp_o[256];
    snprintf(tmp_o, sizeof(tmp_o), "/tmp/shux_asmv2_%d.o", getpid());
    char cmd[1024];
    snprintf(cmd, sizeof(cmd),
        "as -arch arm64 -o %s %s 2>&1 && "
        "ld -arch arm64 -o %s -platform_version macos 14.0 14.0 "
        "-syslibroot $(xcrun --show-sdk-path) -lSystem %s 2>&1",
        tmp_o, tmp_s, out, tmp_o);
    int rc = system(cmd);
    if (rc == 0) printf("[asm_v2] built %s\n", out);
    else fprintf(stderr, "[asm_v2] FAILED\n");

    ast_module_free(mod);
    return rc;
}
