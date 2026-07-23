/* xlang_weak.h — Canonical XLANG_WEAK macro (single authority).
 *
 * Why: Previously XLANG_WEAK was defined inline in 8 seed .from_x.c files with
 *      TWO divergent patterns — some checked only `__GNUC__ || __clang__`
 *      (which is TRUE on MinGW, incorrectly emitting `__attribute__((weak))`
 *      on PE where weak defs do NOT satisfy undefined references), others
 *      correctly checked `_WIN32 || _WIN64`. This caused Windows MSYS/MinGW
 *      xlang-c link failures: weak-defined stub symbols (typeck_module,
 *      append_asm_line, parse, preprocess_*, lsp_*, codegen_*, etc.) were
 *      present in link inputs as weak defs but MinGW GNU ld left the
 *      undefined refs unsatisfied.
 *
 *      Additionally, ~578 direct `__attribute__((weak))` usages across 39
 *      seed files bypassed XLANG_WEAK entirely, suffering the same problem.
 *      This header is the single authority; all seed files include it and
 *      use XLANG_WEAK instead of bare `__attribute__((weak))`.
 *
 * Invariant: On ELF (Linux/macOS) XLANG_WEAK expands to `__attribute__((weak))`
 *            so real implementations override stubs at link time. On PE/MinGW
 *            (Windows) XLANG_WEAK expands to EMPTY — stubs become strong defs,
 *            and `-Wl,--allow-multiple-definition` (WIN_LDFLAGS in Makefile)
 *            resolves conflicts with real impls in favor of the first seen.
 *
 * PLATFORM: SHARED — POSIX branch (ELF weak) vs WINDOWS branch (empty).
 *            See AGENTS.md "平台边界必须标注" + project memory
 *            "Windows/MinGW: __attribute__((weak)) 函数符号不被 PE 格式支持".
 *
 * Usage:
 *   #include <xlang_weak.h>
 *   XLANG_WEAK int32_t my_stub(void) { return -1; }
 */
#ifndef XLANG_WEAK_H
#define XLANG_WEAK_H

#ifndef XLANG_WEAK
#if defined(_WIN32) || defined(_WIN64)
/* PLATFORM: WINDOWS | MSYS | MINGW — PE weak externs do not satisfy U refs.
 * Emit normal (strong) definitions; --allow-multiple-definition resolves
 * conflicts with real implementations. */
#define XLANG_WEAK
#else
/* PLATFORM: POSIX (Linux/macOS/FreeBSD) — ELF weak symbols are overridden
 * by strong definitions at link time. */
#define XLANG_WEAK __attribute__((weak))
#endif
#endif

#endif /* XLANG_WEAK_H */
