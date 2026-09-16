#!/bin/sh
# verify-selfhost-stage2.sh — Stage2 X dogfood: xlang-x → xlang-x2 (-x -E full modules).
# Authority (G.7): single body for verify-selfhost-stage2 / CI stage2.
# wave893: live under compiler/scripts/ (Makefile pure @bash scripts/… form).
# Post-Makefile phys-del: default path is 0-make shell (bootstrap_driver_seed /
# build_seed_asm_host / ensure_host_cc_seed_o). Escape:
#   XLANG_STAGE2_VIA_MAKE=1 + Makefile → historic make leaves (parity only).
# Stage2 X E2E link hygiene: platform crt0 / DUP / USER_ASM from g05_relink_env
# (G.7 有则补全); pipeline_x2 filter via filter_o_export_against_deps --omit-sym
# (ban hardcoded Darwin crt0_arm64 / -multiply_defined / bare exported_symbols_list).
#
# Product NO_C / G-02a (2026-08): classic Step 1 `-x -E -E-extern` requires the
# deleted C frontend (driver_run_x_emit_c_extern_via_cparser_impl body gone;
# product driver_x_emit_try_extern_via_cparser is a fixed BLD001 stub). Live
# Stage2 dogfood under product NO_C is verify-selfhost-stage2-bstrict.sh.
# Default: probe then soft-skip (exit 0) with a loud banner. Escape:
#   XLANG_STAGE2_X_REQUIRE_X_EMIT=1 → hard-fail when emit is blocked (restore work).
# Step 5 Darwin/ARM64 -backend c: G.7 twin of bstrict — export XLANG_ALLOW_HOST_CC=1
# (Stage 12.2.3; -backend c alone is not enough).
#
# Usage: cd compiler && bash scripts/verify-selfhost-stage2.sh
# PLATFORM: SHARED — orchestration; link faces branched via g05_relink_env.
set -e
# cwd = compiler/ (this file lives in scripts/)
cd "$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"

# PLATFORM: SHARED — shell-primary bootstrap (twin of verify-selfhost-stage2-bstrict
# wave941 / experimental archaeology 0-make). Ban bare make-only after phys-del.
stage2_via_make() {
  [ "${XLANG_STAGE2_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ] && command -v make >/dev/null 2>&1
}

# Probe GEN for classic Stage2 X emit (-x -E -E-extern).
# Returns 0 if emit produces non-empty C; 1 if product NO_C / missing cparser.
# PLATFORM: SHARED — product default is NO_C; do not treat soft-skip as product green.
stage2_probe_x_emit() {
  _probe_bin="$1"
  _probe_src="${TMPDIR:-/tmp}/xlang_stage2_x_emit_probe.x"
  _probe_out="${TMPDIR:-/tmp}/xlang_stage2_x_emit_probe.c"
  _probe_err="${TMPDIR:-/tmp}/xlang_stage2_x_emit_probe.err"
  printf '%s\n' 'function main(): i32 { return 42; }' > "$_probe_src"
  rm -f "$_probe_out" "$_probe_err"
  set +e
  "$_probe_bin" -x -E -E-extern "$_probe_src" > "$_probe_out" 2>"$_probe_err"
  _probe_rc=$?
  set -e
  if [ "$_probe_rc" -eq 0 ] && [ -s "$_probe_out" ]; then
    return 0
  fi
  return 1
}

# Load platform link faces from g05_relink_env (same table as product g05).
# Sets: STAGE2_MAIN_LINK_O / STAGE2_MAIN_LINK_FLAGS / STAGE2_ASM_GLUE_DUP /
#        STAGE2_USER_ASM_LINK / STAGE2_UNAME_S / STAGE2_UNAME_M
stage2_load_g05_platform() {
  # shellcheck disable=SC1090
  eval "$(bash scripts/g05_relink_env.sh)"
  STAGE2_MAIN_LINK_O="${G05_MAIN_LINK_O:-}"
  STAGE2_MAIN_LINK_FLAGS="${G05_MAIN_LINK_FLAGS:-}"
  STAGE2_ASM_GLUE_DUP="${G05_ASM_GLUE_DUP_LDFLAGS:-}"
  STAGE2_USER_ASM_LINK="${G05_USER_ASM_LINK:-}"
  STAGE2_UNAME_S="${G05_UNAME_S:-$(uname -s)}"
  STAGE2_UNAME_M="${G05_UNAME_M:-$(uname -m)}"
  if [ -z "$STAGE2_MAIN_LINK_O" ]; then
    echo "verify-stage2: g05_relink_env missing G05_MAIN_LINK_O" >&2
    exit 1
  fi
  echo " verify-stage2: platform $STAGE2_UNAME_S/$STAGE2_UNAME_M MAIN_LINK=$STAGE2_MAIN_LINK_O"
}

stage2_bootstrap_driver_seed() {
  if stage2_via_make; then
    echo " verify-stage2: VIA_MAKE bootstrap-driver-seed"
    make bootstrap-driver-seed
  else
    echo " verify-stage2: 0-make bootstrap_driver_seed.sh"
    bash scripts/bootstrap_driver_seed.sh
  fi
}

stage2_build_seed_asm_host() {
  if stage2_via_make; then
    echo " verify-stage2: VIA_MAKE build-seed-asm-host"
    make -q build-seed-asm-host 2>/dev/null || make build-seed-asm-host
  else
    echo " verify-stage2: 0-make build_seed_asm_host.sh"
    bash scripts/build_seed_asm_host.sh
  fi
}

stage2_ensure_driver_c_objs() {
  # G.7: main_driver = try-heat (R1 seed); fmt_check_cmd_driver = try-other-l2-prefer.
  if stage2_via_make; then
    echo " verify-stage2: VIA_MAKE main_driver + fmt_check_cmd_driver"
    make src/main_driver.o src/driver/fmt_check_cmd_driver.o >/dev/null
  else
    echo " verify-stage2: 0-make ensure main_driver + fmt_check_cmd_driver"
    bash scripts/ensure_host_cc_seed_o.sh try-heat src/main_driver.o
    bash scripts/ensure_host_cc_seed_o.sh try-other-l2-prefer src/driver/fmt_check_cmd_driver.o
  fi
}

# Step 0：重链 xlang-x；若无则先 bootstrap_driver_seed（产出 xlang-x）
echo ""
echo "── Step 0: 确保 xlang-x ──"
if [ ! -x ./xlang-x ]; then
  stage2_bootstrap_driver_seed
  if [ ! -x ./xlang-x ]; then
    echo "verify-stage2: xlang-x still missing after bootstrap_driver_seed" >&2
    exit 1
  fi
fi

echo "============================================"
echo " Xlang Stage2 X 验证 (Stage 2)"
echo " 种子: GEN=xlang-x 生成 _gen2.c（-x -E -E-extern），链接 xlang-x2；对比两代编译 hello 的退出码"
echo "============================================"

# GEN 使用 xlang-x：-x -E 经 driver_run_x_emit_c_extern_via_cparser 与 C 路径 -E-extern 对齐（parse/typeck/codegen）。
# Product NO_C (G-02a): that cparser path is deleted; probe before burning Step 1.
X=./xlang-x
GEN=$X

echo ""
echo "── Step 0b: probe GEN -x -E -E-extern (product NO_C honesty) ──"
if ! stage2_probe_x_emit "$GEN"; then
  echo "verify-stage2: GEN=$GEN cannot -x -E -E-extern (product NO_C / G-02a C frontend deleted)."
  if [ -f "${TMPDIR:-/tmp}/xlang_stage2_x_emit_probe.err" ]; then
    echo "verify-stage2: probe stderr (head):"
    head -5 "${TMPDIR:-/tmp}/xlang_stage2_x_emit_probe.err" || true
  fi
  if [ "${XLANG_STAGE2_X_REQUIRE_X_EMIT:-0}" = "1" ]; then
    echo "verify-stage2: XLANG_STAGE2_X_REQUIRE_X_EMIT=1 → hard-fail (restore WITH_C GEN or reimplement X emit)." >&2
    exit 1
  fi
  echo "============================================"
  echo " Stage2 X SKIP (honest): product NO_C blocks classic -x -E -E-extern"
  echo " Live Stage2 dogfood under product = verify-selfhost-stage2-bstrict.sh"
  echo " Force hard-fail: XLANG_STAGE2_X_REQUIRE_X_EMIT=1"
  echo " Link hygiene / ALLOW_HOST_CC Step5 still maintained in this script."
  echo "============================================"
  exit 0
fi
echo " verify-stage2: probe OK — classic -x -E -E-extern available"

# ── Step 1: 生成所有 _gen2.c ──
echo ""
echo "── Step 1: 生成 _gen2.c (GEN=$GEN) ──"
echo " token..."
$GEN -x -E -L src/lexer -E-extern src/lexer/token.x > token_gen2.c
echo " ast..."
$GEN -x -E -E-extern src/ast/ast.x > ast_gen2.c
echo " lexer..."
$GEN -x -E -L src/lexer -E-extern src/lexer/lexer.x > lexer_gen2.c
echo " parser..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -E-extern src/parser/parser.x > parser_gen2.c
echo " typeck..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -E-extern src/typeck/typeck.x > typeck_gen2.c
echo " codegen..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -E-extern src/codegen/codegen.x > codegen_gen2.c
echo " preprocess..."
$GEN -x -E -L src/lexer -E-extern src/preprocess/preprocess.x > preprocess_gen2.c
echo " pipeline..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/asm -E-extern src/pipeline/pipeline.x > pipeline_gen2.c
echo " driver (main.x)..."
$GEN -x -E -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -E-extern src/main.x > driver_gen2.c

# ── Step 2: 去重结构体 ──
echo ""
echo "── Step 2: 修复 pipeline_gen2.c / 去重 slice 结构体 ──"
for f in parser_gen2.c typeck_gen2.c codegen_gen2.c pipeline_gen2.c driver_gen2.c preprocess_gen2.c; do
  perl -i -ne 'print unless /^struct xlang_slice_uint8_t/ && $seen++' "$f" 2>/dev/null || true
done
for f in ast_gen2.c lexer_gen2.c parser_gen2.c typeck_gen2.c codegen_gen2.c pipeline_gen2.c driver_gen2.c; do
  perl scripts/fix_slim_arena_gen_c.pl "$f" 2>/dev/null || true
done
perl scripts/fix_parser_pool_access_gen_c.pl parser_gen2.c 2>/dev/null || true
perl scripts/fix_driver_gen_duplicate_main.pl driver_gen2.c 2>/dev/null || true
perl scripts/fix_pipeline_extern_gen_c.pl pipeline_gen2.c 2>/dev/null || true
# wave967: pipeline_glue.c / ast_pool.c left wave309 — fix_pipeline_extern strips
# residual #include only (never reinjects). Live orch = runtime_pipeline_abi /
# pipeline.x pure-extern. Duplicate ast symbols: prefer seed ast_x.o on link.
perl scripts/hoist_pipeline_prototypes.pl pipeline_gen2.c 2>/dev/null || true
perl scripts/fix_slim_arena_gen_c.pl pipeline_gen2.c 2>/dev/null || true
perl -i -ne 'print unless /^extern.*parser_parse_into_buf/' pipeline_gen2.c 2>/dev/null || true
perl -i -0777 -pe 's/(struct parser_ParseIntoResult \{ int32_t ok; int32_t main_idx; \};\n)/$1extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *, struct ast_Module *, uint8_t *, int32_t);\n/s unless /parser_parse_into_buf\(struct ast_ASTArena \*, struct ast_Module \*, uint8_t \*, int32_t\)/' pipeline_gen2.c 2>/dev/null || true

# ── Step 3: 编译 _x2.o ──
CFLAGS="-fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w"
echo ""
echo "── Step 3: 编译 _x2.o ──"
cc $CFLAGS -c token_gen2.c -o token_x2.o
cc $CFLAGS -c ast_gen2.c -o ast_x2.o
cc $CFLAGS -c lexer_gen2.c -o lexer_x2.o
cc $CFLAGS -include ast.h -c parser_gen2.c -o parser_x2.o
cc $CFLAGS -c typeck_gen2.c -o typeck_x2.o
cc $CFLAGS -c codegen_gen2.c -o codegen_x2.o
cc $CFLAGS -c preprocess_gen2.c -o preprocess_x2.o
cc $CFLAGS -c pipeline_gen2.c -o pipeline_x2.o
STAGE2_X_TMP_DIR="${TMPDIR:-/tmp}/xlang-stage2-x"
mkdir -p "$STAGE2_X_TMP_DIR"
PIPELINE_X2_FILTERED="$STAGE2_X_TMP_DIR/pipeline_x2_filtered.o"
# PLATFORM: SHARED — named-symbol omit via filter_o_export (Darwin -arch +
# exported_symbols_list / Linux --version-script). Ban bare Darwin-only ld -r.
echo " verify-stage2: filter pipeline_x2.o (omit-sym; 0-make filter_o_export)"
bash scripts/filter_o_export_against_deps.sh \
  --src pipeline_x2.o \
  --out "$PIPELINE_X2_FILTERED" \
  --stem stage2_pipeline_x2 \
  --omit-sym typeck_check_expr_call \
  --omit-sym typeck_check_expr_deref \
  --omit-sym typeck_check_expr_method_call \
  --omit-sym codegen_try_emit_slice_init_from_array_var \
  --omit-sym backend_ctx_push_loop_labels \
  --omit-sym backend_ctx_pop_loop_labels \
  --omit-sym backend_try_fold_count_up_while_elf

echo ""
echo "── 编译 C 侧与 seed 桥（与 bootstrap-driver-seed 同拓扑）──"
stage2_load_g05_platform
stage2_build_seed_asm_host
# runtime_driver_strict_glue_stubs is already on the seed/g05 bag when needed;
# do not re-cc with a truncated -o (historic phys-del bitrot).
cc $CFLAGS -DX_VERIFY_STAGE2 -c src/x_seed_bridge.c -o src/x_seed_bridge_stage2.o
cc $CFLAGS -c typeck_x_link_alias.c -o x_frontend_link_alias.o
cc $CFLAGS -c codegen_x_link_alias.c -o x_frontend_link_alias.o
cc $CFLAGS -c lexer_x_link_alias.c -o x_frontend_link_alias.o 2>/dev/null || true
# runtime_driver（与 xlang-x 相同宏，供 driver_run_compiler_full_x）
cc $CFLAGS -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN -DXLANG_USE_X_PREPROCESS \
  -c src/runtime.c -o runtime_driver2.o
# Stage2 链接仍需沿用 driver 专用 C 对象；不要依赖工作区里偶然残留的 .o。
stage2_ensure_driver_c_objs

# ── Step 4: 链接 xlang-x2（*_x2.o 替代 parser_x/typeck_x/codegen_x/pipeline_x；
# PLATFORM faces = g05_relink_env MAIN_LINK / DUP / USER_ASM）──
echo ""
echo "── Step 4: 链接 xlang-x2 ──"
stage2_bootstrap_driver_seed >/dev/null
for _o in driver_x.o driver_compile_x.o driver_fmt_x.o driver_check_x.o driver_test_x.o \
  driver_build_x.o driver_run_x.o driver_emit_x.o preprocess_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o lsp_io_std_heap_x.o \
  pipeline_bootstrap_orchestration.o src/async/async_liveness.o src/async/async_cps_codegen.o; do
  if [ ! -f "$_o" ]; then
    echo " verify-stage2: missing $_o → re-run bootstrap_driver_seed"
    stage2_bootstrap_driver_seed
    break
  fi
done
# shellcheck disable=SC2086
cc -fno-stack-protector -Wall -Wextra -I. -Iinclude -Isrc -w \
  -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN \
  $STAGE2_ASM_GLUE_DUP $STAGE2_MAIN_LINK_FLAGS \
  -o xlang-x2 \
  $STAGE2_MAIN_LINK_O src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o \
  src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o runtime_driver2.o \
  src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o \
  src/lexer/lexer.o src/ast/ast_seed.o \
  src/async/async_liveness.o src/async/async_cps_codegen.o \
  src/runtime_c_import.o src/codegen/codegen_pipeline_stubs.o src/lexer/cfg_eval.o \
  src/typeck/typeck_f64_bits.o typeck_c_module_stubs.o \
  src/x_seed_bridge_stage2.o src/seed_link_compat.o src/std_fs_shim.o src/std_sys_shim.o \
  \
  token_x2.o ast_x2.o lexer_x2.o parser_x2.o typeck_x2.o codegen_x2.o preprocess_x2.o "$PIPELINE_X2_FILTERED" \
  x_frontend_link_alias.o \
  driver_x.o pipeline_bootstrap_orchestration.o \
  driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o \
  src/lsp/lsp_diag_stubs_no_c.o src/lsp/lsp_diag_pipeline_sizes_nostub.o \
  src/lsp/lsp_diag_pipeline_ctx.o lsp_x.o lsp_diag_x.o \
  lsp_io_x.o lsp_io_std_heap_x.o \
  $STAGE2_USER_ASM_LINK \
  build_asm/pipeline_glue_strict_minimal.o

echo "xlang-x2 linked: $(ls -lh xlang-x2 | awk '{print $5}')"

# ── Step 5: 功能对比 ──
echo ""
echo "── Step 5: 功能对比 ──"
echo 'function main(): i32 { return 42; }' > /tmp/selfhost_test.x
# 与 verify-selfhost-stage2-bstrict 对齐：Darwin/ARM64 等平台 asm -o 尚不稳定时，用 -backend c 验证行为 parity。
# G.7 有则补全：bstrict already exports XLANG_ALLOW_HOST_CC=1 for this fallback
# (Stage 12.2.3 — explicit -backend c alone hits host-cc-requires-allow).
GEN_FLAGS="-L .."
STAGE2_X_COMPILE_BACKEND=""
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*|Linux-aarch64|Linux-arm64)
  STAGE2_X_COMPILE_BACKEND="-backend c"
  # PLATFORM: SHARED — only this Darwin/ARM64 fallback path uses -backend c.
  export XLANG_ALLOW_HOST_CC=1
  echo "verify-stage2: use -backend c for Step 5 on $(uname -s)/$(uname -m 2>/dev/null) (ALLOW_HOST_CC=1)"
  ;;
esac
REF=$X

echo "参照编译 ($REF):"
# shellcheck disable=SC2086
$REF $STAGE2_X_COMPILE_BACKEND $GEN_FLAGS /tmp/selfhost_test.x -o /tmp/selfhost_a 2>&1 || true
if [ ! -x /tmp/selfhost_a ] && [ -x ./xlang-c ]; then
  echo " (xlang-x -o 未产出，非 x86_64 等环境改 xlang-c 作参照)"
  REF=./xlang-c
  # shellcheck disable=SC2086
  $REF $STAGE2_X_COMPILE_BACKEND $GEN_FLAGS /tmp/selfhost_test.x -o /tmp/selfhost_a 2>&1 || true
fi
chmod +x /tmp/selfhost_a 2>/dev/null || true
set +e
/tmp/selfhost_a >/dev/null 2>&1
r1=$?
set -e

echo "xlang-x2 编译:"
# shellcheck disable=SC2086
./xlang-x2 $STAGE2_X_COMPILE_BACKEND $GEN_FLAGS /tmp/selfhost_test.x -o /tmp/selfhost_b 2>&1 || true
chmod +x /tmp/selfhost_b 2>/dev/null || true
set +e
/tmp/selfhost_b >/dev/null 2>&1
r2=$?
set -e

echo ""
echo "参照 ($REF) 返回值: $r1"
echo "xlang-x2 返回值: $r2"

if [ "$r1" = "42" ] && [ "$r2" = "42" ]; then
  echo ""
  echo "============================================"
  echo " ✓ Stage2 X 验证通过!"
  echo " xlang-x ($(ls -lh xlang-x | awk '{print $5}'))"
  echo " xlang-x2 ($(ls -lh xlang-x2 | awk '{print $5}'))"
  echo " 两代编译器行为一致 (exit 42)"
  echo "============================================"
else
  echo "✗ 自举验证失败! r1=$r1 r2=$r2"
  exit 1
fi
