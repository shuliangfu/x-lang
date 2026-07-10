/* seeds/rt_entry.from_x.c — G-02f-301/310 P2 runtime R10 entry gates
 * Logic source: src/runtime/rt_entry.x
 * Hybrid: SHUX_RT_ENTRY_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * f-301: explain CLI / smoke summary / fmt no-files thin gate
 * f-310: run_compiler_c 薄转调 + driver_build_build_x（system 🔒）
 * main_entry (!X_DRIVER) and full run_compiler orchestration remain mega.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "runtime_diag_codes.h"

extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);
extern void diag_report_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                  const char *msg, const char *detail);
extern void diag_print_code_table(FILE *out);
extern int diag_code_is_known(const char *code);
extern const char *diag_code_suggest(const char *code, char *buf, size_t cap);
extern void diag_print_code_explain(FILE *out, const char *code);
extern void diag_print_known_codes(FILE *out);
extern int diag_json_enabled(void);
extern int driver_run_fmt(int argc, char **argv);
extern int main_run_compiler_c(int argc, uint8_t *argv);
extern int system(const char *command);

/** explain 子命令 / --explain：-1=非 explain，0=成功，1=失败。 */
int runtime_try_handle_explain_cli(int argc, char **argv) {
  const char *code = NULL;
  if (argc < 2 || !argv || !argv[1])
    return -1;
  if (strcmp(argv[1], "explain") == 0) {
    if (argc >= 3 && argv[2] && argv[2][0])
      code = argv[2];
    else
      code = NULL;
  } else if (strcmp(argv[1], "--explain") == 0) {
    if (argc >= 3 && argv[2] && argv[2][0])
      code = argv[2];
    else
      code = NULL;
  } else if (strncmp(argv[1], "--explain=", 10) == 0 && argv[1][10] != '\0') {
    code = argv[1] + 10;
  } else {
    return -1;
  }
  if (!code || !code[0]) {
    diag_reportf_with_code(NULL, 0, 0, "usage error", SHUX_DIAG_CODE_ARGUMENT_ARG001, NULL,
                           "--explain requires a diagnostic code (example: shux --explain P001; use --list to see all)");
    return 1;
  }
  if (strcmp(code, "list") == 0 || strcmp(code, "--list") == 0) {
    diag_print_code_table(stdout);
    return 0;
  }
  if (!diag_code_is_known(code)) {
    char suggest[16];
    const char *sug;
    diag_reportf_with_code(NULL, 0, 0, "argument error", SHUX_DIAG_CODE_ARGUMENT_ARG002, NULL,
                           "unknown diagnostic code '%s'", code);
    sug = diag_code_suggest(code, suggest, sizeof suggest);
    if (sug)
      diag_reportf(NULL, 0, 0, "help", NULL, "did you mean '%s'?", sug);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "use `shux --explain P001` or `shux explain P001`; use `--list` to see all codes");
    fputs("note: ", stderr);
    diag_print_known_codes(stderr);
    return 1;
  }
  diag_print_code_explain(stdout, code);
  return 0;
}

int shux_smoke_diag_enabled(void) {
  const char *e;
  if (diag_json_enabled())
    return 1;
  e = getenv("SHUX_SMOKE_DIAG");
  return (e && e[0] && e[0] != '0') ? 1 : 0;
}

void driver_emit_legacy_smoke_summary_stdout(const char *main_name, int main_final_lit, int has_main_body) {
  const char *name = main_name ? main_name : "?";
  if (has_main_body) {
    if (main_final_lit >= 0)
      printf("parse OK: %s(): i32 { %d }\n", name, main_final_lit);
    else
      printf("parse OK: %s(): i32 { expr }\n", name);
  } else {
    printf("parse OK (library module)\n");
  }
  printf("typeck OK\n");
  if (shux_smoke_diag_enabled()) {
    if (has_main_body) {
      if (main_final_lit >= 0)
        diag_reportf_with_code(NULL, 0, 0, "info", SHUX_DIAG_CODE_SMOKE_SMOKE001, NULL, "parse OK: %s(): i32 { %d }",
                               name, main_final_lit);
      else
        diag_reportf_with_code(NULL, 0, 0, "info", SHUX_DIAG_CODE_SMOKE_SMOKE001, NULL, "parse OK: %s(): i32 { expr }",
                               name);
    } else {
      diag_reportf_with_code(NULL, 0, 0, "info", SHUX_DIAG_CODE_SMOKE_SMOKE001, NULL, "parse OK (library module)");
    }
    diag_report_with_code(NULL, 0, 0, "info", SHUX_DIAG_CODE_SMOKE_SMOKE002, "typeck OK", NULL);
  }
}

/** 兼容旧 driver_fmt_gen.c：无路径时委托 driver_run_fmt。 */
int driver_fmt_report_no_files(void) {
  char *argv_fmt[2];
  argv_fmt[0] = "shux";
  argv_fmt[1] = "fmt";
  return driver_run_fmt(2, argv_fmt);
}

/** X driver：转调 main.x main_run_compiler_c。 */
int run_compiler_c(int argc, char **argv) {
  return main_run_compiler_c(argc, (uint8_t *)argv);
}

/**
 * cmd_build：make build-tool 再 build_tool ./shux。
 * 🔒 system() 经 libc。
 */
int driver_build_build_x(void) {
  int rc = system("cd compiler && make -s build-tool 2>&1");
  if (rc != 0) {
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "make build-tool failed (exit %d)", rc);
    return 1;
  }
  rc = system("cd compiler && ./build_tool ./shux 2>&1");
  if (rc != 0) {
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "build_tool failed (exit %d)", rc);
    return 1;
  }
  return 0;
}

int labi_rt_entry_slice_marker(void) {
  return 1;
}
