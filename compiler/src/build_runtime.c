/**
 * build_runtime.c — build.sx（Zig build.zig 类比）的 C 执行后端
 *
 * 职责：提供 main() 按 ../build.sx 的 build_get_step_count() 与 build_get_step_at()（见 build_runtime.c 与 build.sx）顺序执行；
 * build_run_step(step_id, shu_path) 跑「默认路径」（.sx → *_gen.c → cc）；build_run_asm_build() 调 scripts/build_shux_asm.sh（机器码路径）。
 * argv[1]=shux 可执行路径，argv[2]=asm 时只做 asm 路径、不跑默认步骤。
 * 约定：在 compiler 目录运行 build_tool；具体命令字符串集中在本文件，策略与路线图写在 build.sx 顶注释。
 * 长期目标：Makefile 仅兜底；日常以 ./build_tool ./shux 与 ./build_tool ./shux asm 为准（见 build.sx「去掉 Makefile 的爬梯」）。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

#define PIPELINE_GEN_PATCH_BUF_SIZE (512 * 1024)

/**
 * 从源头去补丁：pipeline.sx 已用 run_sx_pipeline_impl、get_ndep()；codegen 已对 slice/数组形参生成 -> 与 *。
 * 此处仅：必要时插入 parser_parse_into extern，并追加 pipeline_glue.c 内容（包装/sizeof/debug 等）。返回 0 成功，-1 失败。
 */
static int build_patch_pipeline_gen_c(void) {
  FILE *f = fopen("pipeline_gen.c", "rb");
  if (!f) return -1;
  if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return -1; }
  long sz = ftell(f);
  if (sz <= 0 || sz >= (long)PIPELINE_GEN_PATCH_BUF_SIZE) { fclose(f); return -1; }
  rewind(f);
  size_t cap = (size_t)sz + 4096;
  if (cap > PIPELINE_GEN_PATCH_BUF_SIZE) cap = PIPELINE_GEN_PATCH_BUF_SIZE;
  char *buf = (char *)malloc(cap);
  if (!buf) { fclose(f); return -1; }
  if (fread(buf, 1, (size_t)sz, f) != (size_t)sz) { free(buf); fclose(f); return -1; }
  buf[sz] = '\0';
  fclose(f);

  /* 去重 struct shux_slice_uint8_t：只保留第一个出现，删除后续重复 */
  {
    const char *pat = "struct shux_slice_uint8_t { uint8_t *data; size_t length; };";
    size_t pat_len = strlen(pat);
    char *first = strstr(buf, pat);
    if (first) {
      char *next = first + pat_len;
      while ((next = strstr(next, pat)) != NULL) {
        /* 向前找到该行的开头（行首或前一个换行后） */
        char *line_start = next;
        while (line_start > buf && *(line_start - 1) != '\n') line_start--;
        /* 找到该行末尾的换行 */
        char *line_end = next + pat_len;
        while (*line_end && *line_end != '\n') line_end++;
        if (*line_end == '\n') line_end++;
        /* 删除从 line_start 到 line_end 的内容 */
        size_t remove_len = (size_t)(line_end - line_start);
        size_t remaining = (size_t)((buf + sz) - line_end) + 1;
        memmove(line_start, line_end, remaining);
        next = line_start; /* 从删除位置继续搜索 */
      }
    }
  }

  /* 在 #include 块之后立即插入 parser_parse_into_buf 的 extern 声明 */
  {
    const char *extras =
      "extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *, struct ast_Module *, uint8_t *, int32_t);\n";
    /* 找到 shux_panic_ 函数之前的位置（紧接 #include 块之后） */
    char *ins_point = strstr(buf, "static inline void shux_panic_");
    if (!ins_point) {
      /* 回退：找最后一个 #include */
      char *p = buf;
      while (*p) {
        if (strncmp(p, "#include", 8) == 0) ins_point = p;
        p++;
      }
      if (ins_point) {
        while (*ins_point && *ins_point != '\n') ins_point++;
        if (*ins_point == '\n') ins_point++;
      }
    }
    if (ins_point) {
      size_t ins_len = strlen(extras);
      size_t remaining = (size_t)((buf + sz) - ins_point) + 1;
      if ((size_t)(ins_point - buf) + ins_len + remaining <= cap) {
        memmove(ins_point + ins_len, ins_point, remaining);
        memcpy(ins_point, extras, ins_len);
      }
    }
  }

  /* 瘦 pipeline_gen.c：外部符号由 parser_sx.o / typeck_su.o / codegen_su.o 链接提供 */
  f = fopen("pipeline_gen.c", "wb");
  if (!f) { free(buf); return -1; }
  if (fwrite(buf, 1, strlen(buf), f) != strlen(buf)) { fclose(f); free(buf); return -1; }
  fclose(f);
  free(buf);
  return 0;
}

/* build_patch_parser_export 已删除：当前 step 6 用 -E-extern 生成 parser_gen.c，已含 parser_* 符号，不再追写 ABI 包装。 */

/* build.sx 经 shux -E 生成：符号为 build_<name>；若源名已含模块前缀则 codegen 去重（见 codegen_c_prefix_redundant_with_name）。 */
extern int32_t build_get_step_count(void);
extern int32_t build_use_asm_only(void);
extern int32_t build_get_step_at(int32_t);

/**
 * 6.3 极薄原语：将 argv[i] 复制到 buf（NUL 结尾），返回长度；越界或失败返回 -1。
 */
int build_get_argv_i(int argc, char **argv, int i, char *buf, int max) {
  if (!buf || max <= 0 || i < 0 || i >= argc || !argv || !argv[i]) return -1;
  size_t n = (size_t)max - 1;
  size_t len = strlen(argv[i]);
  if (len > n) len = n;
  memcpy(buf, argv[i], len);
  buf[len] = '\0';
  return (int)len;
}

/**
 * 6.3 极薄原语：将 literal_id 对应字符串追加到 buf[offset]，返回新 offset；溢出返回 -1。
 */
static const char *const build_literals[] = {
  /* 0: step 0 全命令（含 std_fs_shim.o 供 pipeline/driver 的 std.fs 符号） */
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c -o src/main.o src/main.c && cc -Wall -Wextra -I. -Iinclude -Isrc -c -o src/runtime.o src/runtime.c && cc -Wall -Wextra -I. -Iinclude -Isrc -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_FRONTEND -DSHUX_USE_SX_PREPROCESS -c -o src/runtime_driver.o src/runtime.c && cc -Wall -Wextra -I. -Iinclude -Isrc -DSHUX_USE_SX_PREPROCESS -c -o src/preprocess_fallback.o src/preprocess.c && cc -Wall -Wextra -I. -Iinclude -Isrc -c -o std_fs.o src/std_fs_shim.c && cc -Wall -Wextra -I. -Iinclude -Isrc -c -o preprocess_shim.o src/preprocess_shim.c",
  /* 1: step 1 后缀（前接 shu_path） */
  " -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.sx > pipeline_gen.c",
  /* 2: step 2 */
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c pipeline_gen.c -o pipeline_sx.o",
  /* 3: step 3 后缀 */
  " -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess src/main.sx -E -E-extern > driver_gen.c",
  /* 4: step 4 */
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c driver_gen.c -o driver_su.o",
  /* 5: step 5（含 std_fs.o 供 pipeline/driver 的 std.fs 符号） */
  "cc -Wall -Wextra -I. -Iinclude -Isrc -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_FRONTEND -o shux src/main.o src/runtime_driver.o src/preprocess_fallback.o preprocess_shim.o preprocess_su.o std_fs.o ast_su.o token_su.o lexer_su.o parser_sx.o typeck_su.o codegen_su.o driver_su.o pipeline_sx.o",
  /* 6–7: step 6 parser */
  " -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > parser_gen.c",
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c parser_gen.c -o parser_sx.o",
  /* 8–9: typeck */
  " -L .. -L src/lexer -L src/ast -E -E-extern src/typeck/typeck.sx > typeck_gen.c",
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c typeck_gen.c -o typeck_su.o",
  /* 10–11: codegen */
  " -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -E -E-extern src/codegen/codegen.sx > codegen_gen.c",
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c codegen_gen.c -o codegen_su.o",
  /* 12–13: ast */
  " -E -E-extern src/ast/ast.sx > ast_gen.c",
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c ast_gen.c -o ast_su.o",
  /* 14–15: token */
  " -L src/lexer -E -E-extern src/lexer/token.sx > token_gen.c",
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c token_gen.c -o token_su.o",
  /* 16–17: lexer */
  " -L src/lexer -E -E-extern src/lexer/lexer.sx > lexer_gen.c",
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c lexer_gen.c -o lexer_su.o",
  /* 18–19: preprocess */
  " -L src/lexer -E -E-extern src/preprocess/preprocess.sx > preprocess_gen.c",
  "cc -Wall -Wextra -I. -Iinclude -Isrc -c preprocess_gen.c -o preprocess_su.o",
  /* 20–21: 完全自举 asm 路径（build.sx 用 argv[2]==asm 时执行） */
  "SHUX=",
  " ./scripts/build_shux_asm.sh",
};
static const int build_literals_n = (int)(sizeof(build_literals) / sizeof(build_literals[0]));

int build_append_literal(char *buf, int size, int offset, int literal_id) {
  if (!buf || size <= 0 || offset < 0 || literal_id < 0 || literal_id >= build_literals_n) return -1;
  const char *s = build_literals[literal_id];
  size_t len = strlen(s);
  if (offset + len >= (size_t)size) return -1;
  memcpy(buf + offset, s, len + 1);
  return (int)(offset + len);
}

/**
 * 6.3 极薄原语：执行 cmd_buf（NUL 结尾）；返回 system() 的返回值或 -1。
 */
int build_exec_cmd(char *cmd_buf) {
  if (!cmd_buf) return -1;
  return system(cmd_buf);
}

/**
 * 6.3：对 driver_gen.c 做与 Makefile 等价的 sed 修正（slice . -> ->；preprocess_sx_buf 签名）。
 */
static int build_patch_driver_gen_c(void) {
  FILE *f = fopen("driver_gen.c", "rb");
  if (!f) return -1;
  if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return -1; }
  long sz = ftell(f);
  if (sz <= 0 || sz >= (long)PIPELINE_GEN_PATCH_BUF_SIZE) { fclose(f); return -1; }
  rewind(f);
  char *buf = (char *)malloc((size_t)sz + 1);
  if (!buf) { fclose(f); return -1; }
  if (fread(buf, 1, (size_t)sz, f) != (size_t)sz) { free(buf); fclose(f); return -1; }
  buf[sz] = '\0';
  fclose(f);
  /* slice . -> ->、preprocess_sx_buf 签名、run_compiler_c 包装均已从源头产出（codegen 数组形参为 *，runtime.c 在 SHUX_USE_SX_DRIVER 下已定义 run_compiler_c），不再补丁 */
  f = fopen("driver_gen.c", "wb");
  if (!f) { free(buf); return -1; }
  if (fwrite(buf, 1, strlen(buf), f) != strlen(buf)) { fclose(f); free(buf); return -1; }
  fclose(f);
  free(buf);
  return 0;
}

/**
 * 6.3 极薄原语：执行 step_id 对应的修正（1 pipeline_gen.c，3 driver_gen.c，6 preprocess_gen.c）。返回 0 成功 -1 失败。
 */
int build_patch_after_step(int step_id) {
  if (step_id == 1) return build_patch_pipeline_gen_c() == 0 ? 0 : -1;
  if (step_id == 3) return build_patch_driver_gen_c() == 0 ? 0 : -1;
  /* step 6：preprocess_gen.c 不再补丁，codegen 对 source/out_buf 形参已生成 -> */
  return 0;
}

/**
 * 将 argv[1] 或默认 "./shux" 写入 buf（NUL 结尾），不超过 max-1 字节。
 * 返回 0 成功，-1 失败（如 max<=0）。保留供兼容。
 */
int build_get_shu_path(char *buf, int max, int argc, char **argv) {
  if (!buf || max <= 0) return -1;
  buf[0] = '\0';
  if (argc >= 2 && argv[1] && argv[1][0]) {
    size_t n = (size_t)max - 1;
    strncat(buf, argv[1], n);
    buf[max - 1] = '\0';
  } else {
    size_t n = (size_t)max - 1;
    if (n > 5) n = 5;
    memcpy(buf, "./shux", 5);
    buf[5] = '\0';
  }
  return 0;
}

/**
 * 执行单步构建命令；由 main 按 build.sx 的步骤顺序调用。step_id 含义见 build.sx 注释。
 */
int build_run_step(int step_id, const char *shu_path) {
  char cmd[4096];
  const char *cc = "cc";
  const char *cflags = "-Wall -Wextra -I. -Iinclude -Isrc";
  const char *cflags_driver = "-Wall -Wextra -I. -Iinclude -Isrc -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_FRONTEND -DSHUX_USE_SX_PREPROCESS";
  int n;

  switch (step_id) {
  case 0:
    /* 阶段 3.2 / 6.4：编 main、runtime_driver（带 SU_PREPROCESS 使 preprocess() 在 .sx 路径）、preprocess_fallback（不覆盖 preprocess.o）。
     * 同时编译所有 C 侧模块，供 step 5 链接（runtime_driver 仍引用了部分 C 侧函数）。 */
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s %s -c -o src/main.o src/main.c && "
      "%s %s -c -o src/runtime.o src/runtime.c && "
      "%s %s -DSHUX_USE_SX_PREPROCESS -c -o src/runtime_driver.o src/runtime.c && "
      "%s %s -DSHUX_USE_SX_PREPROCESS -c -o src/preprocess_fallback.o src/preprocess.c && "
      "%s %s -c -o src/lexer/lexer.o src/lexer/lexer.c && "
      "%s %s -DSHUX_USE_SX_AST -c -o src/ast/ast.o src/ast/ast.c && "
      "%s %s -c -o src/parser/parser.o src/parser/parser.c && "
      "%s %s -c -o src/typeck/typeck.o src/typeck/typeck.c && "
      "%s %s -c -o src/codegen/codegen.o src/codegen/codegen.c && "
      "%s %s -c -o src/lsp/lsp_diag.o src/lsp/lsp_diag.c && "
      "%s %s -c -o std_fs_shim.o src/std_fs_shim.c && "
      "%s %s -c -o sx_stubs.o src/sx_stubs.c",
      cc, cflags, cc, cflags, cc, cflags_driver, cc, cflags,
      cc, cflags, cc, cflags, cc, cflags, cc, cflags,
      cc, cflags, cc, cflags, cc, cflags, cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    return system(cmd);
  case 6: {
    /* 阶段 3.2：用 -E -E-extern 生成瘦 parser_gen.c/typeck_gen.c/codegen_gen.c（仅类型+入口模块，依赖用 extern），再编成 _su.o。 */
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L .. -L src/lexer -L src/ast -E -E-extern src/parser/parser.sx > parser_gen.c",
      shu_path);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    /* -E-extern 已生成 parser_* 符号，不再追加 ABI 包装，避免重复定义。 */
    n = (int)snprintf(cmd, sizeof(cmd),
      "perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' parser_gen.c && %s %s -include ast.h -c parser_gen.c -o parser_sx.o", cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L .. -L src/lexer -L src/ast -E -E-extern src/typeck/typeck.sx > typeck_gen.c && "
      "%s %s -c typeck_gen.c -o typeck_su.o",
      shu_path, cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -E -E-extern src/codegen/codegen.sx > codegen_gen.c && "
      "%s %s -c codegen_gen.c -o codegen_su.o",
      shu_path, cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    /* 阶段 3：生成并编 ast_su.o、token_su.o、lexer_su.o，供 parser/typeck/codegen 与 pipeline 链接。 */
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -E -E-extern src/ast/ast.sx > ast_gen.c && %s %s -c ast_gen.c -o ast_su.o",
      shu_path, cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L src/lexer -E -E-extern src/lexer/token.sx > token_gen.c && %s %s -c token_gen.c -o token_su.o",
      shu_path, cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L src/lexer -E -E-extern src/lexer/lexer.sx > lexer_gen.c && %s %s -c lexer_gen.c -o lexer_su.o",
      shu_path, cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    /* 6.4：preprocess.sx 生成 preprocess_gen.c（codegen 对 slice 形参已生成 ->，无补丁），编成 preprocess_su.o。 */
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L src/lexer -E -E-extern src/preprocess/preprocess.sx > preprocess_gen.c",
      shu_path);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    n = (int)snprintf(cmd, sizeof(cmd), "%s %s -c preprocess_gen.c -o preprocess_su.o", cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    return system(cmd);
  }
  case 1: {
    /* 阶段 1.1/1.2：用 shux 生成 pipeline_gen.c，再由 build_patch_pipeline_gen_c 修正。
     * 阶段 3：C 版 shux 无 -su，一律用 -E -E-extern 生成瘦 pipeline_gen.c，避免与 parser_su/typeck_su/codegen_su 重复符号。 */
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -E -E-extern src/pipeline/pipeline.sx > pipeline_gen.c",
      shu_path);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    if (system(cmd) != 0) return -1;
    return build_patch_pipeline_gen_c() == 0 ? 0 : -1;
  }
  case 2:
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s %s -c pipeline_gen.c -o pipeline_sx.o", cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    return system(cmd);
  case 3:
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -E -E-extern src/main.sx > driver_gen.c",
      shu_path);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    return system(cmd);
  case 4:
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s %s -c driver_gen.c -o driver_su.o", cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    return system(cmd);
  case 5:
    /* 阶段 3.2/3.3、6.4：链 runtime_driver.o（含 preprocess()，step 0 已带 -DSHUX_USE_SX_PREPROCESS）+ preprocess_fallback.o + preprocess_su.o
     * + 所有 C 侧 .o（仍被 runtime_driver 的部分路径引用）。 */
    n = (int)snprintf(cmd, sizeof(cmd),
      "%s %s -DSHUX_USE_SX_DRIVER -DSHUX_USE_SX_PIPELINE -DSHUX_USE_SX_FRONTEND -o shux "
      "src/main.o src/runtime_driver.o src/preprocess_fallback.o "
      "src/lexer/lexer.o src/ast/ast.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/lsp/lsp_diag.o std_fs_shim.o sx_stubs.o "
      "preprocess_su.o ast_su.o token_su.o lexer_su.o parser_sx.o typeck_su.o codegen_su.o driver_su.o pipeline_sx.o",
      cc, cflags);
    if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
    return system(cmd);
  default:
    return -1;
  }
}

/**
 * 完全自举 asm 路径：执行 SHUX=<shu_path> ./scripts/build_shux_asm.sh。
 * 返回 0 成功，非 0 为 system() 的退出状态（非零即失败）。供 main / build_runner 调用。
 *
 * 语义与「是否仍 cc -c pipeline_gen」以 compiler/docs/SELFHOST.md 为准（Target B-partial /
 * B-hybrid、`SHUX_ASM_LINK_TOPOLOGY`）。
 * 拓扑：未导出 `SHUX_ASM_LINK_TOPOLOGY` 时，脚本在 **Linux/macOS** 且 `check_asm_o_quality.sh` 认定全部
 * __text 非空后自动选 `full_asm`；M7 默认 `SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1` → asm_only_strict。
 * 不在此重复脚本细节，避免与 build_shux_asm.sh 漂移。
 */
int build_run_asm_build(const char *shu_path) {
  char cmd[4096];
  /* M7：与 make bootstrap-driver-bstrict 一致，默认 B-strict（SKIP_GEN）。 */
  int n = snprintf(cmd, sizeof(cmd),
                   "SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 SHUX=%s ./scripts/build_shux_asm.sh",
                   shu_path ? shu_path : "./shux");
  if (n <= 0 || n >= (int)sizeof(cmd)) return -1;
  return system(cmd);
}

/** 执行 build.sx 配置的 legacy 逐步（生成 *_gen.c 并链接 shux）。返回 0 成功。 */
static int build_run_legacy_steps(const char *shu_path) {
  int n = (int)build_get_step_count();
  for (int i = 0; i < n; i++) {
    int step_id = (int)build_get_step_at((int32_t)i);
    if (step_id < 0) return 1;
    if (build_run_step(step_id, shu_path) != 0) return 1;
  }
  return 0;
}

#ifdef BUILD_TOOL_SU_ENTRY
/* 入口由 build_runner.sx 提供；crt0 调 entry，此处提供 entry 包装调用 build_runner_entry（.sx -E 生成符号为 build_runner_entry）。 */
extern int32_t build_runner_entry(int argc, void *argv);
int entry(int argc, char **argv) {
  return (int)build_runner_entry(argc, (void *)argv);
}
#else
int main(int argc, char **argv) {
  char shu_path[256];
  if (argc >= 2 && argv[1] && argv[1][0]) {
    size_t n = sizeof(shu_path) - 1;
    size_t len = strlen(argv[1]);
    if (len > n) len = n;
    memcpy(shu_path, argv[1], len);
    shu_path[len] = '\0';
  } else {
    memcpy(shu_path, "./shux", 5);
    shu_path[5] = '\0';
  }
  /* 显式 asm：只跑脚本，失败即退出（不回退）。 */
  if (argc >= 3 && argv[2] && strcmp(argv[2], "asm") == 0)
    return build_run_asm_build(shu_path) != 0 ? 1 : 0;
  /* 显式 legacy：只跑 -E 逐步，忽略 build_use_asm_only。 */
  if (argc >= 3 && argv[2] && strcmp(argv[2], "legacy") == 0)
    return build_run_legacy_steps(shu_path) != 0 ? 1 : 0;
  /* build.sx build_use_asm_only()==1：先试 asm（不生成 pipeline_gen/driver_gen）；失败则回退 legacy。 */
  if (build_use_asm_only() != 0) {
    int ar = build_run_asm_build(shu_path);
    if (ar == 0) {
      (void)system("cp -f shux_asm shux");
      fprintf(stderr, "build_tool: asm path OK; ./shux updated from shux_asm.\n");
      return 0;
    }
    fprintf(stderr, "build_tool: asm build failed; falling back to legacy C codegen steps.\n");
  }
  return build_run_legacy_steps(shu_path) != 0 ? 1 : 0;
}
#endif /* !BUILD_TOOL_SU_ENTRY */
