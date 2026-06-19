/**
 * sx_bridge.c — 将 runtime.c 调用的 C 原版符号桥接到 .sx 源码生成的实现
 *
 * 策略：
 *   parser.sx → -E-extern → parser_gen.c → cc → parser_sx.o
 *   typeck.sx → -E-extern → typeck_gen.c → cc → typeck_su.o
 *   codegen.sx → -E-extern → codegen_gen.c → cc → codegen_su.o
 *
 * 桥接本文件与上述 .o 一起链接，替代 parser.o / typeck.o / codegen.o。
 * 运行时仍通过 C 的 ast.o / lexer.o 分配 Module/Arena，.sx 实现只做解析/类型检查/代码生成。
 */

#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* ---- 类型前向声明（与 ast.h 一致）---- */
struct ASTModule;
struct ASTType;
struct ASTExpr;
struct ASTBlock;
struct ASTFuncDef;
struct ASTStructDecl;

/* ---- shux_slice_uint8_t（与 runtime.c / 生成代码一致）---- */
struct shux_slice_uint8_t {
    uint8_t *data;
    size_t   length;
};

/* ================================================================
 * PARSER 桥接
 * ================================================================ */

/* .sx parser 导出的主要解析入口 */
extern int32_t parser_parse(struct shux_slice_uint8_t *source);

/* parser 内部需要的 extern 函数（由 ast.o/lexer.o/runtime.o 提供）*/
extern struct ASTModule *ast_module_alloc(void);
extern void *ast_arena_alloc(void);
extern void parser_parse_into_init(void *module, void *arena);

/* parser_parse_into — 接收切片，填充 arena/module */
struct parser_ParseIntoResult {
    int32_t ok;
    int32_t main_idx;
    int32_t n_errors;
};

extern struct parser_ParseIntoResult parser_parse_into(
    void *arena, void *module, struct shux_slice_uint8_t *src);

extern void parser_parse_into_set_main_index(void *module, int32_t idx);
extern int32_t parser_get_module_num_imports(void *module);
extern void parser_get_module_import_path(void *module, int32_t i, uint8_t *buf);

/* ================================================================
 * TYPECK 桥接
 * ================================================================ */

/* .sx typeck 导出 */
extern int32_t typeck_typeck_module(
    struct ASTModule *m, struct ASTModule **deps, int32_t ndep);

/* ================================================================
 * CODEGEN 桥接（最复杂）
 * ================================================================ */

/* codegen 回调类型 */
typedef int (*codegen_is_func_used_fn)(void *ctx, int idx);
typedef int (*codegen_is_mono_used_fn)(void *ctx, int idx);
typedef int (*codegen_is_type_used_fn)(void *ctx, int idx);

/* .sx codegen 导出 */
extern int32_t codegen_codegen_sx_ast(
    struct ASTModule *m, FILE *out, void **deps, const char **dep_paths,
    int32_t ndep, int32_t is_library, const char *import_path);
