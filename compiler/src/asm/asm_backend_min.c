/**
 * asm_backend_min.c — ARM64 汇编文本后端
 * 输出 .s 文件 → as 汇编 → ld 链接
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>

static FILE *f;

static void emit(const char *s) { fprintf(f, "%s\n", s); }

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "Usage: %s <in.sx> [-o <out>]\n", argv[0]); return 1; }

    const char *in = argv[1];
    const char *out = "a.out";
    for (int i = 2; i < argc; i++)
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) out = argv[i + 1];

    /* parse */
    FILE *fi = fopen(in, "r");
    if (!fi) { perror(in); return 1; }
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
    if (!f) { perror(tmp_s); return 1; }

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
    printf("[min] %s\n", cmd);
    int rc = system(cmd);
    printf("[min] exit=%d\n", rc);
    if (rc == 0) printf("[min] built %s\n", out);
    else fprintf(stderr, "[min] FAILED\n");
    return rc;
}
