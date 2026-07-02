/**
 * lsp_diag.h — LSP 诊断收集器接口
 *
 * 供 parser/typeck 在 LSP 模式下将错误写入收集器而非 stderr；
 * LSP 层调用 lsp_diagnostics_collect 对当前文档跑解析并取 Diagnostic[] JSON。
 */

#ifndef SHUX_LSP_DIAG_H
#define SHUX_LSP_DIAG_H

#include <stdint.h>

#define LSP_DIAG_CODE_MAX 15

/** 非零时 parser/typeck 应调用 lsp_diag_add 而非写 stderr（由 lsp_diagnostics_collect 置 1，结束后置 0）。 */
extern int lsp_diag_enabled;

/** 清空当前收集的诊断条数。 */
void lsp_diag_clear(void);

/** 开始一次「仅收集、不写 stderr」的诊断会话（parse/typeck 路径会写入 lsp_diag_add）。 */
void lsp_diag_collect_begin(void);

/** 结束诊断收集会话。 */
void lsp_diag_collect_end(void);

/** .sx 诊断路径：arena/module/PipelineDepCtx 一次性分配（体积大），指针在进程内常驻。 */
void *lsp_diag_sx_arena_ptr(void);
void *lsp_diag_sx_module_ptr(void);
void *lsp_diag_sx_ctx_ptr(void);

/** 复位上述三块缓冲为全零，便于重复 parse_into/typeck（勿对池化 AST 调 ast_module_free）。 */
void lsp_diag_sx_reset_parse_buffers(void);

/** 为 .sx pipeline LSP 路径配置 PipelineDepCtx（libRoots + entry_dir）。 */
void lsp_diag_prepare_pipeline_ctx(void *ctx_void);

/** 文档变更时由 lsp_io 调用，使模块与诊断缓存失效，避免旧模块指向已释放的文档缓冲。 */
void lsp_diag_invalidate_cache(void);

/** 追加一条诊断：line/col 为 1-based；severity 1=Error 2=Warning 3=Information。 */
void lsp_diag_add(int line, int col, int severity, const char *msg);
void lsp_diag_add_code(int line, int col, int severity, const char *code, const char *msg);

/**
 * 统计当前收集器中 severity 等于给定值的诊断条数（用于 shux check CI profile）。
 */
int lsp_diag_count_severity(int severity);

/**
 * 将当前收集的诊断打印到 stderr（deno / rustc 风格：path:line:col - error: msg）。
 * path 为源文件路径前缀；返回打印的条数。
 */
int lsp_diag_print_stderr_human(const char *path);

/** typeck 统一报错入口：line/col 为 1-based；LSP 模式下写入收集器，否则 fprintf stderr + " at line:col\n"。 */
void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);
void lsp_diag_report_typeck_code(const char *code, int line, int col, const char *fmt, ...);

/**
 * 对 source[0..source_len-1] 跑 .sx parse_into_buf + typeck_sx_ast，收集诊断，构建完整 JSON-RPC 响应正文：
 * {"jsonrpc":"2.0","id":<id_val>,"result":<Diagnostic[] 的 JSON>}。
 * 实现位于 lsp_diag.sx（-E 生成 lsp_diag_gen.c）；与 C 缓存的 definition/hover 路径独立，调用前会使缓存失效。
 * 写入 out_buf，返回长度，失败或越界返回 -1。
 */
int lsp_build_diagnostics_response(int id_val, const uint8_t *source, int source_len,
                                   uint8_t *out_buf, int out_cap);

/**
 * 在 source 上按 (line_0, col_0)（LSP 0-based）查“定义”；找到则 out_line/out_col 为 1-based 定义位置，返回 1，否则返回 0。
 */
int lsp_definition_at(const uint8_t *source, int source_len, int line_0, int col_0, int *out_line, int *out_col);

/**
 * 在 source 上按 (line_0, col_0) 确定目标函数，收集其所有引用位置（1-based），写入 out_lines/out_cols，返回个数，最多 max_refs。
 */
int lsp_references_at(const uint8_t *source, int source_len, int line_0, int col_0,
                      int *out_lines, int *out_cols, int max_refs);

/**
 * 在 source 上按 (line_0, col_0) 找表达式类型，格式化为字符串写入 out_buf，返回长度；无类型返回 0。
 */
int lsp_hover_at(const uint8_t *source, int source_len, int line_0, int col_0, char *out_buf, int out_cap);

/* ---------- 原 lsp_io.c：文档缓冲与 JSON 响应构建（已合并到 lsp_diag.c，去掉 lsp_io.c） ---------- */
void lsp_set_document_from_body(const uint8_t *body, int body_len);
uint8_t *lsp_get_document_ptr(void);
int lsp_get_document_len(void);
int lsp_build_initialize_result(int id_val, uint8_t *out_buf, int out_cap);
int lsp_build_response_with_result(int id_val, const uint8_t *result_ptr, int result_len, uint8_t *out_buf, int out_cap);
int lsp_build_definition_response(int id_val, const uint8_t *body, int body_len, const uint8_t *doc_buf, int doc_len, uint8_t *out_buf, int out_cap);
int lsp_build_references_response(int id_val, const uint8_t *body, int body_len, const uint8_t *doc_buf, int doc_len, uint8_t *out_buf, int out_cap);
int lsp_build_hover_response(int id_val, const uint8_t *body, int body_len, const uint8_t *doc_buf, int doc_len, uint8_t *out_buf, int out_cap);
int lsp_build_formatting_response(int id_val, const uint8_t *body, int body_len, const uint8_t *doc_buf, int doc_len, uint8_t *out_buf, int out_cap);

/**
 * shux fmt CLI：对 .sx 源码做与 LSP formatting 相同的缩进/换行规范（tabSize=2、空格缩进、maxLineLength=100）。
 * 写入 out_buf，返回格式化后字节数；失败或越界返回 -1。
 */
int shu_format_sx_document(const uint8_t *doc, int doc_len, uint8_t *out_buf, int out_cap);

/** textDocument/completion：返回 CompletionItem[] JSON；无模块或失败时 result 为 []。 */
int lsp_build_completion_response(int id_val, const uint8_t *body, int body_len,
                                  const uint8_t *doc_buf, int doc_len, uint8_t *out_buf, int out_cap);

/** textDocument/documentSymbol：返回 DocumentSymbol[] JSON；无模块时 result 为 []。 */
int lsp_build_document_symbol_response(int id_val, const uint8_t *body, int body_len,
                                       const uint8_t *doc_buf, int doc_len, uint8_t *out_buf, int out_cap);

/** textDocument/semanticTokens/full：返回 SemanticTokens JSON；无模块时 result 为 {"data":[]}。 */
int lsp_build_semantic_tokens_response(int id_val, const uint8_t *doc_buf, int doc_len,
                                       uint8_t *out_buf, int out_cap);

/** textDocument/rename：返回 WorkspaceEdit JSON；无匹配时 result 为 null。 */
int lsp_build_rename_response(int id_val, const uint8_t *body, int body_len,
                              const uint8_t *doc_buf, int doc_len,
                              uint8_t *out_buf, int out_cap);

#endif /* SHUX_LSP_DIAG_H */
