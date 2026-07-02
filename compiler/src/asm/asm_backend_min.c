/**
 * asm_backend_min.c — ARM64 汇编文本后端
 * 输出 .s 文件 → as 汇编 → ld 链接
 */
#include "diag.h"
#include "runtime_diag_codes.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>

static FILE *f;

static void emit(const char *s) { fprintf(f, "%s\n", s); }

static int asm_backend_min_usage(const char *argv0) {
    diag_reportf_with_code(NULL, 0, 0, "usage error", SHUX_DIAG_CODE_ARGUMENT_ARG001, NULL,
                 "usage: %s <in.sx> [-o <out>]",
                 argv0 ? argv0 : "asm_backend_min");
    return 1;
}

static int asm_backend_min_errno(const char *path, const char *op) {
    diag_reportf_with_code(path, 0, 0, "io error", SHUX_DIAG_CODE_IO_IO001, NULL,
                 "%s failed for '%s': %s",
                 op ? op : "file operation",
                 path ? path : "?",
                 strerror(errno));
    return 1;
}

int main(int argc, char **argv) {
    if (argc < 2)
        return asm_backend_min_usage(argv[0]);

    const char *in = argv[1];
    const char *out = "a.out";
    for (int i = 2; i < argc; i++)
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) out = argv[i + 1];

    /* parse */
    FILE *fi = fopen(in, "r");
    if (!fi)
        return asm_backend_min_errno(in, "open");
    fseek(fi, 0, SEEK_END);
    long sz = ftell(fi); if (sz > 4095) sz = 4095;
    fseek(fi, 0, SEEK_SET);
    char *buf = malloc(sz + 1);
    fread(buf, 1, sz, fi); fclose(fi); buf[sz] = 0;

    char *p = strstr(buf, "return");
    int32_t val = 0;
    if (p) {
        p += 6;
        while (*p == ' ' || *p == '\t') p++;
        if (*p == '-') val = -(int32_t)strtol(p + 1, NULL, 10);
        else val = (int32_t)strtol(p, NULL, 10);
    }
    free(buf);

    /* write .s */
    char tmp_s[256];
    snprintf(tmp_s, sizeof(tmp_s), "/tmp/shux_min_%d.s", getpid());
    f = fopen(tmp_s, "w");
    if (!f)
        return asm_backend_min_errno(tmp_s, "open");

    emit(".text");
    emit(".globl _main");
    emit(".p2align 2");
    emit("_main:");
    emit("    stp x29, x30, [sp, #-16]!");
    emit("    mov x29, sp");
    fprintf(f, "    mov x0, #%d\n", val);
    emit("    ldp x29, x30, [sp], #16");
    emit("    ret");
    fclose(f);

    /* assemble + link */
    char cmd[1024];
    snprintf(cmd, sizeof(cmd),
        "as -arch arm64 -o /tmp/shux_min_%d.o %s && "
        "ld -arch arm64 -o %s -platform_version macos 14.0 14.0 "
        "-syslibroot $(xcrun --show-sdk-path) -lSystem "
        "/tmp/shux_min_%d.o 2>&1",
        getpid(), tmp_s, out, getpid());
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm backend min command: %s",
                 cmd);
    int rc = system(cmd);
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm backend min exit=%d",
                 rc);
    if (rc == 0)
        diag_reportf(NULL, 0, 0, "info", NULL,
                     "asm backend min: built %s",
                     out);
    else
        diag_reportf_with_code(out, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                     "asm backend min failed to build '%s'",
                     out);
    return rc;
}
