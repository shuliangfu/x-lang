/* scripts/pthin_stretch_audit_eq_harness.c — 7.2.1 B-minus equivalence harness
 *
 * Proves every .x port in src/asm/pthin_stretch_audit.x is behaviorally
 * identical to its gated C twin in the suite slice: same return value on the
 * same lexer state AND (by-value contracts) the caller's lexer untouched /
 * (inout contracts) both twins leave the caller at the same end state.
 *
 * The twin set (twins.h) and the dispatch table (table.h) are AUTO-GENERATED
 * by scripts/sync_stretch_audit_harness.py from the migrated surface — run it
 * after every generator wave; this file is the stable shell.
 *
 * Lexer authority under test: seeds/lexer_gen.linux.x86_64.c pin (same
 * T-symbol face as product lexer_x.o). Struct mirrors follow the
 * layout-mirror discipline (field-for-field identical to the lexer authority).
 *
 * PLATFORM: SHARED (built+run on Darwin and Ubuntu by the driver script).
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "token.h" /* single authority for TOKEN_* kind values */

/* --- parser_asm layout mirrors (identical to the suite family) --- */
struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

/* Lexer authority (pin .c object provides the definition). */
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);

/* Pin .c extern stubs (only reached on cfg-attr / malformed-literal paths the
 * harness corpus never exercises; stubs keep the link self-contained). */
char *link_abi_getenv(const char *name) { return getenv(name); }
int32_t cfg_eval_expr_c(char *buf, int32_t expr_len) {
  (void)buf;
  (void)expr_len;
  return 1;
}
void diag_report_with_code(void *ctx, const char *code, int32_t line, int32_t col, const char *fmt,
                           ...) {
  (void)ctx;
  (void)code;
  (void)line;
  (void)col;
  (void)fmt;
}
int32_t lexer_parser_slice_from_buf(void) { return 0; }

/* Reference twins + helper authority copies (generated). */
#include "pthin_stretch_audit_eq_twins.h"

/* --- dispatch (generated: externs + shims + k_cases) --- */
typedef int32_t (*audit_fn)(void *lex_inout, void *source, int32_t flag);

typedef struct {
  const char *name;
  audit_fn c_ref;
  audit_fn x_ver;
  int32_t flag;
  int inout; /* 1: inout contract — compare post-call lexer states */
} audit_case;

#include "pthin_stretch_audit_eq_table.h"

/* v5.50: leftover_helpers kind-scalar eq lives in a sibling TU so twins.h
 * static C copies do not shadow the .x T from audit_x.o. */
extern int leftover_kind_eq_run(long *checks, int *fail);
/* v5.51: leftover_helpers name/len eq — same sibling-TU reason. */
extern int leftover_namelen_eq_run(long *checks, int *fail);
/* v5.52: leftover_helpers source+off eq — same sibling-TU reason. */
extern int leftover_sourceoff_eq_run(long *checks, int *fail);
/* v5.53: leftover_helpers kind+source+off eq — same sibling-TU reason. */
extern int leftover_kindsrc_eq_run(long *checks, int *fail);
/* v5.54: leftover_helpers two-kind+source+off eq — same sibling-TU reason. */
extern int leftover_twokind_eq_run(long *checks, int *fail);
/* v5.55: leftover_helpers 7-param as-bind eq — same sibling-TU reason. */
extern int leftover_asbind_eq_run(long *checks, int *fail);
/* v5.56: leftover_helpers kinds-array eq — same sibling-TU reason
 * (twins.h static peek_kind_chain / expr_binop_kinds_probe). */
extern int leftover_kindarr_eq_run(long *checks, int *fail);

static int g_fail = 0;
static long g_checks = 0;
static long g_checks_at_progress = 0;
static size_t g_cases_sel = 0;
static int g_shard_i = 0; /* EQ_SHARD=i/n → this worker owns indices ≡ i (mod n) */
static int g_shard_n = 1;
static int g_file_stride = 1; /* EQ_FILE_STRIDE=k → advance k tokens between checks */
/* Deep-climb names (peak/summit/zenith/versal) cost ~1s/check on large files.
 * EQ_DEEP_MAX_FILE_OFF caps their token-offset budget independently of shallow
 * cases. -1 = same as the battery max_steps (no extra cap). Soft-knife close
 * sets this to 1 and relies on the short smoke battery (see main) — large
 * product files skip deep entirely when source length > EQ_DEEP_MAX_SRC_LEN
 * (default 512) so close stays in the minutes budget. */
static int g_deep_max_file_off = -1;
static size_t g_deep_max_src_len = 512;

/**
 * Daily-delta filter (wall-clock): EQ_ONLY=comma-separated substrings.
 * A case runs iff its name contains any substring. Empty/unset = all cases.
 * PLATFORM: SHARED — used to prove only this wave's new exports in minutes
 * instead of re-scoring the full 400+ table (~50 min at OFF=128).
 */
static int case_selected(const audit_case *ac) {
  const char *only = getenv("EQ_ONLY");
  char buf[2048];
  size_t n;
  char *tok;
  char *save;
  if (!only || !only[0])
    return 1;
  n = strlen(only);
  if (n >= sizeof(buf))
    n = sizeof(buf) - 1;
  memcpy(buf, only, n);
  buf[n] = 0;
  for (tok = strtok_r(buf, ",", &save); tok; tok = strtok_r(0, ",", &save)) {
    while (*tok == ' ' || *tok == '\t')
      tok++;
    if (!*tok)
      continue;
    if (strstr(ac->name, tok))
      return 1;
  }
  return 0;
}

/** Parse EQ_SHARD=i/n (parallel workers). Default 0/1 = whole table. */
static void load_shard_env(void) {
  const char *s = getenv("EQ_SHARD");
  int i = 0, n = 1;
  if (s && s[0] && sscanf(s, "%d/%d", &i, &n) == 2 && n > 0 && i >= 0 && i < n) {
    g_shard_i = i;
    g_shard_n = n;
  } else {
    g_shard_i = 0;
    g_shard_n = 1;
  }
}

static int case_in_shard(size_t ci) {
  return (int)(ci % (size_t)g_shard_n) == g_shard_i;
}

static void load_stride_env(void) {
  const char *s = getenv("EQ_FILE_STRIDE");
  long v;
  g_file_stride = 1;
  if (s && s[0]) {
    v = strtol(s, 0, 10);
    if (v > 1 && v < 1024)
      g_file_stride = (int)v;
  }
}

static void load_deep_off_env(void) {
  const char *s = getenv("EQ_DEEP_MAX_FILE_OFF");
  const char *slen = getenv("EQ_DEEP_MAX_SRC_LEN");
  long v;
  g_deep_max_file_off = -1;
  g_deep_max_src_len = 512;
  if (s && s[0]) {
    v = strtol(s, 0, 10);
    /* 0 = offset 0 only; positive = inclusive max step for deep names. */
    if (v >= 0 && v < 100000)
      g_deep_max_file_off = (int)v;
  }
  if (slen && slen[0]) {
    v = strtol(slen, 0, 10);
    if (v >= 0 && v < 10000000)
      g_deep_max_src_len = (size_t)v;
  }
}

/**
 * Score-chain climbs whose nested audit body is ~0.1–1s per call on large
 * files. Measured 2026-09-11: peak×OFF=24×3files ≈25+ min; after peak/summit
 * skip, max_ultra_hyper still dominated step-0 samples. Soft-knife close
 * treats hyper+ score rungs as deep (smoke on short buffers only).
 * PLATFORM: SHARED — name predicate only; no semantic change to twins.
 */
static int is_deep_climb_name(const char *name) {
  if (!name)
    return 0;
  return strstr(name, "peak") != 0 || strstr(name, "summit") != 0 ||
         strstr(name, "zenith") != 0 || strstr(name, "versal") != 0 ||
         strstr(name, "_vx_") != 0 ||
         strstr(name, "pinnacle") != 0 || strstr(name, "crown") != 0 ||
         strstr(name, "apex_max") != 0 || strstr(name, "max_ultra") != 0 ||
         strstr(name, "ultra_hyper") != 0 || strstr(name, "hyper_mega") != 0;
}

static void progress_maybe(const char *tag, int step) {
  /* Live progress on stderr every 200 checks (or first check of a step). */
  if (g_checks == 0 || (g_checks - g_checks_at_progress) < 200)
    return;
  g_checks_at_progress = g_checks;
  fprintf(stderr, "eq_harness: progress checks=%ld fail=%d tag=%s step=%d shard=%d/%d\n",
          g_checks, g_fail, tag ? tag : "?", step, g_shard_i, g_shard_n);
  fflush(stderr);
}

/** Compare one (C ref, .x) pair on one lexer state; verify contract. */
static void check_one(const audit_case *ac, size_t ci, struct parser_asm_lexer lex,
                      struct parser_asm_slice_u8 *src) {
  struct parser_asm_lexer for_c = lex;
  struct parser_asm_lexer for_x = lex;
  int32_t rc_c;
  int32_t rc_x;
  if (!case_selected(ac) || !case_in_shard(ci))
    return;
  if (getenv("EQ_TRACE")) fprintf(stderr, "[trace] %s pos=%zu\n", ac->name, lex.pos);
  rc_c = ac->c_ref(&for_c, src, ac->flag);
  rc_x = ac->x_ver(&for_x, src, ac->flag);
  g_checks++;
  if (rc_c != rc_x) {
    printf("FAIL %s: rc mismatch c=%d x=%d (pos=%zu line=%d col=%d)\n", ac->name, rc_c, rc_x,
           lex.pos, lex.line, lex.col);
    g_fail++;
    return;
  }
  if (ac->inout) {
    /* inout contract: both twins must leave the caller's lexer at the SAME
     * end state — compare the two directly (advancement allowed). */
    if (memcmp(&for_c, &for_x, sizeof(lex)) != 0) {
      printf("FAIL %s: inout end-state mismatch c=(%zu/%d/%d) x=(%zu/%d/%d)\n", ac->name,
             for_c.pos, for_c.line, for_c.col, for_x.pos, for_x.line, for_x.col);
      g_fail++;
    }
    return;
  }
  if (memcmp(&for_x, &lex, sizeof(lex)) != 0) {
    printf("FAIL %s: .x moved caller lexer (%zu/%d/%d -> %zu/%d/%d)\n", ac->name, lex.pos, lex.line,
           lex.col, for_x.pos, for_x.line, for_x.col);
    g_fail++;
  }
  if (memcmp(&for_c, &lex, sizeof(lex)) != 0) {
    printf("FAIL %s: c ref moved caller lexer (%zu/%d/%d -> %zu/%d/%d)\n", ac->name, lex.pos,
           lex.line, lex.col, for_c.pos, for_c.line, for_c.col);
    g_fail++;
  }
}

/**
 * Run shard-local audit cases at token offsets of one source buffer.
 * EQ_FILE_STRIDE>1 skips offsets (still starts at 0) to cut wall-clock while
 * keeping breadth across the file — used by close-mode mid coverage.
 * Deep-climb names additionally respect EQ_DEEP_MAX_FILE_OFF (see g_deep_*).
 */
static void battery(const char *tag, const char *text, size_t len, int max_steps) {
  struct parser_asm_slice_u8 src;
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  size_t ci;
  int step;
  int stride = g_file_stride > 0 ? g_file_stride : 1;
  src.data = (uint8_t *)(uintptr_t)text;
  src.length = len;
  lex.pos = 0;
  lex.line = 1;
  lex.col = 1;
  fprintf(stderr,
          "eq_harness: battery start tag=%s len=%zu max_steps=%d stride=%d deep_cap=%d "
          "deep_src_cap=%zu\n",
          tag, len, max_steps, stride, g_deep_max_file_off, g_deep_max_src_len);
  fflush(stderr);
  for (step = 0; step <= max_steps; step++) {
    if ((step % stride) == 0) {
      for (ci = 0; ci < sizeof(k_cases) / sizeof(k_cases[0]); ci++) {
        if (g_deep_max_file_off >= 0 && is_deep_climb_name(k_cases[ci].name)) {
          /* Large product files: skip deep (proven on short smoke instead). */
          if (len > g_deep_max_src_len)
            continue;
          /* Short buffers: only the first deep_cap+1 offsets (inclusive). */
          if (step > g_deep_max_file_off)
            continue;
        }
        check_one(&k_cases[ci], ci, lex, &src);
      }
      progress_maybe(tag, step);
    }
    lexer_next_into(&r, lex, &src);
    if ((int32_t)r.tok.kind == (int32_t)TOKEN_EOF)
      break;
    lex = r.next_lex;
  }
  fprintf(stderr, "eq_harness: battery done tag=%s checks=%ld fail=%d\n", tag, g_checks, g_fail);
  fflush(stderr);
}

int main(int argc, char **argv) {
  static const char *const k_synth[] = {
      "if (x) { }",       "if(x",                 "iff (x)",      "while (x)",
      "while(x",          "for (i) { }",          "for(;)",       "break;",
      "break ;",          "continue;",            "continue",     "else { }",
      "else if (y)",      "else x",               "let x: i32 = 1;", "let x = 1;",
      "const y: u8 = 2;", "let : i32",            "enum E { }",   "enum { }",
      "enum E",           "match v { 1 => 2 }",   "match v;",     "match",
      "return;",          "return 1 + 2;",        "return",       "import a.b;",
      "import a.b as c;", "import ;",             "import",       "function f() { }",
      "\n\nif (a)\n{",   "let x\n:\ni32",        "return\n1;",
      "async function q() { }", "trait T { }",    "impl T for S { }",
      "x as i32",         "1 as u8 as i32",       "loop: label",  "x = 1;",
      "x += 2;",          "{ }",                  "[1, 2]",       "align(16) struct A { }",
      "(a + b)",          "struct S { }",         "struct S",     "panic(msg)",
      "panic;",           "panic",                "*u8",          "[u8; 4]",
      "fn(a: i32) -> i32 { }", "1 + 2 * 3 - 4 / 5 % 6", "a && b || !c",
      "<< >> & | ^",      "x.y.z[0]",             "f(1, g(2))",   "@attr fn",
      "unsafe { }",       "match x { _ => 0, }",  "spawn f()",    "await f()",
  };
  size_t i;
  int f;
  load_shard_env();
  load_stride_env();
  load_deep_off_env();
  {
    size_t ci;
    g_cases_sel = 0;
    for (ci = 0; ci < sizeof(k_cases) / sizeof(k_cases[0]); ci++)
      if (case_selected(&k_cases[ci]) && case_in_shard(ci))
        g_cases_sel++;
    fprintf(stderr,
            "eq_harness: cases_selected=%zu/%zu EQ_ONLY=%s EQ_SKIP_SYNTH=%s "
            "EQ_MAX_FILE_OFF=%s EQ_DEEP_MAX_FILE_OFF=%s EQ_SHARD=%d/%d "
            "EQ_FILE_STRIDE=%d\n",
            g_cases_sel, (size_t)(sizeof(k_cases) / sizeof(k_cases[0])),
            getenv("EQ_ONLY") && getenv("EQ_ONLY")[0] ? getenv("EQ_ONLY") : "(all)",
            getenv("EQ_SKIP_SYNTH") && getenv("EQ_SKIP_SYNTH")[0] ? getenv("EQ_SKIP_SYNTH") : "0",
            getenv("EQ_MAX_FILE_OFF") && getenv("EQ_MAX_FILE_OFF")[0] ? getenv("EQ_MAX_FILE_OFF")
                                                                     : "1200",
            getenv("EQ_DEEP_MAX_FILE_OFF") && getenv("EQ_DEEP_MAX_FILE_OFF")[0]
                ? getenv("EQ_DEEP_MAX_FILE_OFF")
                : "(none)",
            g_shard_i, g_shard_n, g_file_stride);
  }
  /* v5.50 leftover_kind / v5.51 leftover_namelen / v5.52 leftover_sourceoff
   * / v5.53 leftover_kindsrc / v5.54 leftover_twokind / v5.55 leftover_asbind
   * / v5.56 leftover_kindarr: sibling TUs so twins.h static C copies do not
   * shadow the .x T from audit_x.o. Shard 0 only so parallel workers do
   * not double-count. */
  if (g_shard_i == 0) {
    leftover_kind_eq_run(&g_checks, &g_fail);
    leftover_namelen_eq_run(&g_checks, &g_fail);
    leftover_sourceoff_eq_run(&g_checks, &g_fail);
    leftover_kindsrc_eq_run(&g_checks, &g_fail);
    leftover_twokind_eq_run(&g_checks, &g_fail);
    leftover_asbind_eq_run(&g_checks, &g_fail);
    leftover_kindarr_eq_run(&g_checks, &g_fail);
  }
  /* EQ_SKIP_SYNTH=1: skip synthetic corpus (daily delta); files + null remain.
   * Soft-knife close always keeps a short smoke battery so deep-climb twins
   * still run (large product files skip deep when len > EQ_DEEP_MAX_SRC_LEN). */
  {
    static const char k_deep_smoke[] =
        "if (x) { match v { 1 => 2, _ => 0 } } else { return 1 + 2; }\n"
        "struct S { a: i32, b: u8 }\n"
        "function f(a: i32) -> i32 { let x = a; return x; }\n";
    int smoke_steps = g_deep_max_file_off >= 0 ? g_deep_max_file_off : 8;
    battery("deep_smoke", k_deep_smoke, strlen(k_deep_smoke) + 1, smoke_steps);
  }
  if (!(getenv("EQ_SKIP_SYNTH") && getenv("EQ_SKIP_SYNTH")[0] && getenv("EQ_SKIP_SYNTH")[0] != '0')) {
    for (i = 0; i < sizeof(k_synth) / sizeof(k_synth[0]); i++) {
      char tag[32];
      snprintf(tag, sizeof(tag), "synth%zu", i);
      battery(tag, k_synth[i], strlen(k_synth[i]) + 1, 64); /* +1: NUL sentinel in slice */
    }
  }
  for (f = 1; f < argc; f++) {
    FILE *fp = fopen(argv[f], "rb");
    char *buf;
    long sz;
    if (!fp) {
      printf("FAIL open %s\n", argv[f]);
      g_fail++;
      continue;
    }
    fseek(fp, 0, SEEK_END);
    sz = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    buf = (char *)malloc((size_t)sz + 1);
    if (!buf || fread(buf, 1, (size_t)sz, fp) != (size_t)sz) {
      printf("FAIL read %s\n", argv[f]);
      g_fail++;
      fclose(fp);
      free(buf);
      continue;
    }
    fclose(fp);
    buf[sz] = 0;
    /* Default 1200 offsets/file. EQ_MAX_FILE_OFF caps wall-clock for deep
     * mega layers (hyper+): same twins, fewer file offsets; synthetic +
     * null-guard battery stay full. PLATFORM: SHARED. */
    {
      int32_t file_off = 1200;
      const char *cap = getenv("EQ_MAX_FILE_OFF");
      if (cap && cap[0]) {
        long v = strtol(cap, 0, 10);
        if (v > 0 && v < file_off)
          file_off = (int32_t)v;
      }
      battery(argv[f], buf, (size_t)sz + 1, file_off); /* +1: NUL sentinel */
    }
    free(buf);
  }
  /* Null-guard parity: every pair must answer 0 without dereferencing. */
  {
    struct parser_asm_lexer lex;
    size_t ci;
    lex.pos = 0;
    lex.line = 1;
    lex.col = 1;
    for (ci = 0; ci < sizeof(k_cases) / sizeof(k_cases[0]); ci++) {
      if (!case_selected(&k_cases[ci]) || !case_in_shard(ci))
        continue;
      g_checks++;
      if (k_cases[ci].x_ver(&lex, 0, k_cases[ci].flag) != 0) {
        printf("FAIL null-source guard (.x %s)\n", k_cases[ci].name);
        g_fail++;
      }
      g_checks++;
      if (k_cases[ci].x_ver(0, 0, k_cases[ci].flag) != 0) {
        printf("FAIL null-lex guard (.x %s)\n", k_cases[ci].name);
        g_fail++;
      }
    }
  }
  if (g_fail) {
    printf("pthin_stretch_audit_eq: %ld checks, %d FAIL (shard %d/%d)\n", g_checks, g_fail,
           g_shard_i, g_shard_n);
    return 1;
  }
  printf("pthin_stretch_audit_eq: %ld checks OK (shard %d/%d)\n", g_checks, g_shard_i, g_shard_n);
  return 0;
}
