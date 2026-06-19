/**
 * std/cli/cli.c — 命令行解析辅助（STD-077）
 *
 * 【文件职责】
 * 长短选项检测、子命令匹配、usage 生成；供 mod.sx 与 std.env args_iter 组合使用。
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

/** 与 mod.sx CliResult 布局一致。 */
typedef struct {
    int32_t subcommand_len;
    int32_t help;
    int32_t version;
    int32_t verbose;
    int32_t unknown;
    int32_t positional_count;
    uint8_t subcommand[64];
    int32_t positional0_len;
    uint8_t positional0[128];
} cli_result_t;

/** 比较等长字节串；1 相等。 */
static int cli_bytes_eq(const uint8_t *a, int32_t alen, const uint8_t *b, int32_t blen) {
    int32_t i;
    if (alen != blen) return 0;
    for (i = 0; i < alen; i++) {
        if (a[i] != b[i]) return 0;
    }
    return 1;
}

/** 是否为 -h / --help。 */
int32_t cli_is_help_c(const uint8_t *arg, int32_t len) {
    if (!arg || len <= 0) return 0;
    if (len == 2 && arg[0] == (uint8_t)'-' && arg[1] == (uint8_t)'h') return 1;
    if (len == 6 && memcmp(arg, "--help", 6) == 0) return 1;
    return 0;
}

/** 是否为 --version。 */
int32_t cli_is_version_c(const uint8_t *arg, int32_t len) {
    if (!arg || len <= 0) return 0;
    if (len == 9 && memcmp(arg, "--version", 9) == 0) return 1;
    return 0;
}

/** 长选项 --name 匹配（不含前缀）。 */
int32_t cli_match_long_c(const uint8_t *arg, int32_t len, const uint8_t *name, int32_t name_len) {
    if (!arg || !name || len < 2 + name_len) return 0;
    if (arg[0] != (uint8_t)'-' || arg[1] != (uint8_t)'-') return 0;
    return cli_bytes_eq(arg + 2, len - 2, name, name_len);
}

/** 短选项串 -x 或 -abc 是否含 c。 */
int32_t cli_match_short_c(const uint8_t *arg, int32_t len, uint8_t c) {
    int32_t i;
    if (!arg || len < 2 || arg[0] != (uint8_t)'-') return 0;
    if (len == 2 && arg[1] == c) return 1;
    for (i = 1; i < len; i++) {
        if (arg[i] == c) return 1;
    }
    return 0;
}

/** 写入 usage 行；返回长度，失败 -1。 */
int32_t cli_write_usage_c(const uint8_t *prog, int32_t prog_len, const uint8_t *desc, int32_t desc_len,
                          uint8_t *out, int32_t out_cap) {
    int n;
    if (!prog || !desc || !out || out_cap <= 0) return -1;
    n = snprintf((char *)out, (size_t)out_cap, "Usage: %.*s [subcommand] [options]\n%.*s\n",
                 (int)prog_len, (const char *)prog, (int)desc_len, (const char *)desc);
    if (n < 0 || n >= out_cap) return -1;
    return n;
}

/** 解析 argv[1..] 扁平参数（跳过程序名）；成功 0，未知参数 -1，help 1。 */
int32_t cli_parse_args_c(const uint8_t * const *argv, const int32_t *lens, int32_t argc,
                         const uint8_t *expect_sub, int32_t expect_sub_len, cli_result_t *out) {
    int32_t i;
    if (!out) return -1;
    memset(out, 0, sizeof(*out));
    if (argc <= 1) return 0;
    for (i = 1; i < argc; i++) {
        const uint8_t *a = argv[i];
        int32_t al = lens[i];
        if (!a || al <= 0) continue;
        if (cli_is_help_c(a, al)) {
            out->help = 1;
            return 1;
        }
        if (cli_is_version_c(a, al)) {
            out->version = 1;
            return 0;
        }
        if (cli_match_long_c(a, al, (const uint8_t *)"verbose", 7)) {
            out->verbose = 1;
            continue;
        }
        if (cli_match_short_c(a, al, (uint8_t)'v')) {
            out->verbose = 1;
            continue;
        }
        if (a[0] == (uint8_t)'-') {
            out->unknown = 1;
            return -1;
        }
        if (out->subcommand_len == 0 && expect_sub_len > 0 &&
            cli_bytes_eq(a, al, expect_sub, expect_sub_len)) {
            if (al >= (int32_t)sizeof(out->subcommand)) return -1;
            memcpy(out->subcommand, a, (size_t)al);
            out->subcommand[al] = 0;
            out->subcommand_len = al;
            continue;
        }
        if (out->positional_count == 0) {
            if (al >= (int32_t)sizeof(out->positional0)) return -1;
            memcpy(out->positional0, a, (size_t)al);
            out->positional0[al] = 0;
            out->positional0_len = al;
            out->positional_count = 1;
            continue;
        }
        out->unknown = 1;
        return -1;
    }
    return 0;
}

/** C 烟测：help/long/short/sub/positional。 */
int32_t cli_smoke_c(void) {
    cli_result_t r;
    const uint8_t *argv[5];
    int32_t lens[5];
    static const uint8_t a0[] = "tool";
    static const uint8_t a1[] = "run";
    static const uint8_t a2[] = "--verbose";
    static const uint8_t a3[] = "file.txt";
    uint8_t usage[128];
    argv[0] = a0; lens[0] = 4;
    argv[1] = a1; lens[1] = 3;
    argv[2] = a2; lens[2] = 9;
    argv[3] = a3; lens[3] = 8;
    if (cli_parse_args_c(argv, lens, 4, (const uint8_t *)"run", 3, &r) != 0) return 1;
    if (r.subcommand_len != 3 || r.verbose != 1 || r.positional_count != 1) return 2;
    if (cli_is_help_c((const uint8_t *)"--help", 6) != 1) return 3;
    if (cli_write_usage_c(a0, 4, (const uint8_t *)"demo", 4, usage, 128) <= 0) return 4;
    return 0;
}
