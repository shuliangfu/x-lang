/**
 * parser_asm_stretch_audit_gate.h — 解析热路径 stretch audit 开关。
 *
 * stretch audit 仅用于自举 code-size 门禁（须定义 SHUX_PARSER_STRETCH_AUDIT）；
 * 默认关闭，避免每次 parse assign/expr 扫描整文件导致编译极慢。
 */
#ifndef PARSER_ASM_STRETCH_AUDIT_GATE_H
#define PARSER_ASM_STRETCH_AUDIT_GATE_H

#ifdef SHUX_PARSER_STRETCH_AUDIT
/** 自举门禁：执行 stretch audit 表达式。 */
#define PARSER_ASM_STRETCH_AUDIT_CALL(expr) ((void)(expr))
#else
/** 日常编译：跳过 stretch audit。 */
#define PARSER_ASM_STRETCH_AUDIT_CALL(expr) ((void)0)
#endif

#endif /* PARSER_ASM_STRETCH_AUDIT_GATE_H */
