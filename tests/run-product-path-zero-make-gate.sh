#!/usr/bin/env bash
# Product-path 0-make static gate (C迁移 11.0.2 · wave714)
#
# Purpose:
#   G-05 product path claims "no make" for daily relink. This gate freezes that
#   contract with a static allowlist so new `make` calls cannot regress silently.
#
# Scope (static only — does not rebuild the compiler):
#   - compiler/scripts/g05_*.sh daily chain
#   - repo-root xlang-build.sh product targets (document remaining make)
#
# Not in scope (tracked elsewhere):
#   - FULL=1 / bootstrap-driver-seed cold start (Makefile authority until 11.0.3)
#   - tests/lib/** make -C (stage 11.2.3)
#   - CI workflows (stage 11.2.5)
#
# Runtime companion (wave726):
#   ./tests/run-product-path-zero-make-path-probe.sh  — PATH shadow make; daily g05 0-exec
#
# Usage (repo root):
#   ./tests/run-product-path-zero-make-gate.sh
# Exit: 0 = OK, 1 = new make invocation outside allowlist or missing product entry
#
# PLATFORM: SHARED — pure shell; no host binary dependency.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== 11.0.2/11.0.3/11.0.4 product-path 0-make static gate (wave714–729) ==="

fail=0
note() { echo "  OK  $*"; }
bad()  { echo "  FAIL $*" >&2; fail=1; }
warn() { echo "  WARN $*" >&2; }

# --- required product-path files ---
for f in \
  xlang-build.sh \
  build.x \
  analysis/Makefile迁移表.md \
  compiler/scripts/g05_build_xlang_asm.sh \
  compiler/scripts/g05_prepare_and_relink.sh \
  compiler/scripts/g05_ensure_relink_prereqs.sh \
  compiler/scripts/g05_relink_env.sh \
  compiler/scripts/g05_relink_xlang.sh
do
  [ -f "$f" ] || bad "missing $f"
done
[ "$fail" -eq 0 ] && note "product-path files present"

# --- default g05 must not exec make xlang_asm (must go prepare_and_relink) ---
if grep -q 'g05_prepare_and_relink' compiler/scripts/g05_build_xlang_asm.sh; then
  note "g05_build_xlang_asm default → g05_prepare_and_relink"
else
  bad "g05_build_xlang_asm.sh must invoke g05_prepare_and_relink on default path"
fi

# FULL=1 may still call make (non-daily); must be gated on FULL env
if grep -n 'bootstrap-driver-bstrict' compiler/scripts/g05_build_xlang_asm.sh | grep -q 'FULL'; then
  note "FULL=1 bstrict still make (allowed non-daily)"
elif grep -q 'bootstrap-driver-bstrict' compiler/scripts/g05_build_xlang_asm.sh; then
  note "FULL path references bootstrap-driver-bstrict (document as cold/full)"
else
  warn "no FULL=1 bstrict path found (ok if migrated)"
fi

# --- scan g05 daily scripts for make invocations ---
# Allowlist: exact substring matches on the code line (after strip comments).
# Update this list only when intentionally keeping a make call + document in
# analysis/Makefile迁移表.md §5.
ALLOW_PATTERNS=(
  # non-daily full rebuild
  'exec make bootstrap-driver-bstrict'
  # error hints to user for cold start (not product build)
  'make -C compiler bootstrap-driver-seed'
  'make -C compiler build-seed-asm-host'
  # Makefile header comments in echo (cold-start guidance)
  'Makefile 冷启动'
  'make bootstrap-driver-seed'
  'make bootstrap-driver-bstrict'
)

# Extract non-comment lines that mention make as a command-ish token.
# shellcheck: intentional scan
scan_make_lines() {
  local file="$1"
  # drop full-line comments and trailing comments roughly
  grep -nE '(^|[^A-Za-z0-9_])make([ \t]|$|")' "$file" 2>/dev/null \
    | grep -vE '^[0-9]+:[ \t]*#' \
    | grep -vE '^[0-9]+:.*#.*\bmake\b' \
    || true
}

is_allowed() {
  local line="$1"
  local p
  for p in "${ALLOW_PATTERNS[@]}"; do
    case "$line" in
      *"$p"*) return 0 ;;
    esac
  done
  # pure documentation / echo strings that only mention make in prose
  if echo "$line" | grep -qE 'echo .*make'; then
    return 0
  fi
  if echo "$line" | grep -qE '^\s*[0-9]+:\s*#'; then
    return 0
  fi
  return 1
}

G05_DAILY=(
  compiler/scripts/g05_build_xlang_asm.sh
  compiler/scripts/g05_prepare_and_relink.sh
  compiler/scripts/g05_ensure_relink_prereqs.sh
  compiler/scripts/g05_relink_env.sh
  compiler/scripts/g05_relink_xlang.sh
)

new_hits=0
for f in "${G05_DAILY[@]}"; do
  while IFS= read -r hit; do
    [ -z "$hit" ] && continue
    if is_allowed "$hit"; then
      continue
    fi
    # allow "no make" / "零 make" / "不调用 make" contract strings
    if echo "$hit" | grep -qiE 'no make|零 make|不.*make|without make|不调用 make|不依赖 make'; then
      continue
    fi
    bad "new/undocumented make in $hit"
    new_hits=$((new_hits + 1))
  done < <(scan_make_lines "$f")
done

# wave715/716: class-G filtered.o must be pure shell (no make -s)
if grep -nE 'make[[:space:]]+-s|make[[:space:]]+"?\$_filt' compiler/scripts/g05_ensure_relink_prereqs.sh 2>/dev/null \
  | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
  bad "g05_ensure still has make -s filtered.o leak (must use filter_* shell scripts)"
elif grep -q 'filter_bootstrap_seed_pipeline_o' compiler/scripts/g05_ensure_relink_prereqs.sh \
  && grep -q 'filter_bootstrap_seed_against_partial_o' compiler/scripts/g05_ensure_relink_prereqs.sh; then
  note "g05_ensure class-G filtered.o → filter_* shell (pipeline + partial trio; no make)"
else
  bad "g05_ensure missing class-G filter shell authority (pipeline + against_partial)"
fi

for f in \
  compiler/scripts/filter_o_export_against_deps.sh \
  compiler/scripts/filter_bootstrap_seed_pipeline_o.sh \
  compiler/scripts/filter_bootstrap_seed_against_partial_o.sh
do
  if [ ! -f "$f" ]; then
    bad "missing $f"
  else
    note "$(basename "$f") present"
  fi
done

# wave716: Makefile class-G recipes must call shell, not inline nm/ld
if grep -nE 'build_asm/bootstrap_seed_.*_filtered\.o:' -A6 compiler/Makefile 2>/dev/null \
  | grep -E '^\s+nm |ld -r \$\(LD_FILTER' | grep -q .; then
  bad "Makefile class-G filtered recipes still inline nm/ld (must call filter_*.sh)"
else
  note "Makefile class-G filtered recipes → shell scripts"
fi

# wave717: bootstrap-driver-seed orchestration must live in shell (11.0.3)
if [ ! -x compiler/scripts/bootstrap_driver_seed.sh ] && [ ! -f compiler/scripts/bootstrap_driver_seed.sh ]; then
  bad "missing compiler/scripts/bootstrap_driver_seed.sh (11.0.3 authority)"
elif ! grep -q 'bootstrap_driver_seed\.sh' compiler/Makefile; then
  bad "Makefile bootstrap-driver-seed must call scripts/bootstrap_driver_seed.sh"
elif ! grep -q 'bootstrap-driver-seed-phase1-link' compiler/Makefile \
  || ! grep -q 'bootstrap-driver-seed-final-link' compiler/Makefile; then
  bad "Makefile missing thin phase1/final link leaves for bootstrap_driver_seed.sh"
elif grep -A20 '^bootstrap-driver-seed: \$(DRIVER_SEED_PREREQS)' compiler/Makefile 2>/dev/null \
  | grep -E 'xlang-seed-phase1|bootstrap_driver_seed_smoke' | grep -q .; then
  bad "Makefile bootstrap-driver-seed recipe still inlines phase1/smoke (must be shell)"
else
  note "bootstrap-driver-seed orchestration → bootstrap_driver_seed.sh (+ thin link leaves)"
fi

# wave721: phase1/final link body → shell via Makefile OBJS/CFLAGS export (no dual list)
if [ ! -f compiler/scripts/bootstrap_driver_seed_link.sh ]; then
  bad "missing compiler/scripts/bootstrap_driver_seed_link.sh (11.0.3 wave721)"
elif ! grep -q 'bootstrap_driver_seed_link\.sh' compiler/Makefile; then
  bad "Makefile phase1/final must call bootstrap_driver_seed_link.sh"
elif ! grep -q 'bootstrap-driver-seed-export-phase1-link' compiler/Makefile \
  || ! grep -q 'bootstrap-driver-seed-export-final-link' compiler/Makefile; then
  bad "Makefile missing phase1/final OBJS+CFLAGS export leaves (G.7 single authority)"
else
  # Recipe body only: must not inline $(CC) link; must call shell
  phase1_body=$(awk '
    /^bootstrap-driver-seed-phase1-link:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if echo "$phase1_body" | grep -qE '\$\(CC\)|\$\(CFLAGS\)' \
    && ! echo "$phase1_body" | grep -q 'bootstrap_driver_seed_link\.sh'; then
    bad "Makefile phase1-link still inlines \$(CC) (must be shell + export)"
  elif ! echo "$phase1_body" | grep -q 'bootstrap_driver_seed_link\.sh'; then
    bad "Makefile phase1-link recipe missing bootstrap_driver_seed_link.sh"
  elif grep -qE '^\s+(src/|\.o|lexer_x\.o|parser_x\.o)' compiler/scripts/bootstrap_driver_seed_link.sh; then
    bad "bootstrap_driver_seed_link.sh must not hardcode .o list (dual authority)"
  else
    note "phase1/final link → export leaves + bootstrap_driver_seed_link.sh (OBJS single authority)"
  fi
fi

# wave722/724/725: rebuild leaves (sat/lsp/bridge/panic/user-asm/glue/pipeline-x) → shell via export
if [ ! -f compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh ]; then
  bad "missing compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh (11.0.3 wave722+)"
elif ! grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh' compiler/Makefile; then
  bad "Makefile rebuild leaves must call bootstrap_driver_seed_rebuild_leaves.sh"
elif ! grep -q 'bootstrap-driver-seed-export-sat-rebuild' compiler/Makefile \
  || ! grep -q 'bootstrap-driver-seed-export-lsp-x-objs' compiler/Makefile; then
  bad "Makefile missing sat/lsp export leaves (G.7 single authority)"
elif ! grep -q 'bootstrap-driver-seed-export-bridge' compiler/Makefile \
  || ! grep -q 'bootstrap-driver-seed-export-panic' compiler/Makefile \
  || ! grep -q 'bootstrap-driver-seed-export-user-asm' compiler/Makefile \
  || ! grep -q 'bootstrap-driver-seed-export-glue' compiler/Makefile; then
  bad "Makefile missing bridge/panic/user-asm/glue export leaves (wave724)"
elif ! grep -q 'bootstrap-driver-seed-export-pipeline-x' compiler/Makefile \
  || ! grep -q 'DRIVER_SEED_PIPELINE_X_OBJS' compiler/Makefile; then
  bad "Makefile missing pipeline-x export leaf / DRIVER_SEED_PIPELINE_X_OBJS (wave725 §5b #2)"
elif ! grep -q 'DRIVER_SEED_SAT_REBUILD_OBJS' compiler/Makefile \
  || ! grep -q 'DRIVER_SEED_LSP_X_OBJS' compiler/Makefile \
  || ! grep -q 'DRIVER_SEED_BRIDGE_OBJS' compiler/Makefile \
  || ! grep -q 'DRIVER_SEED_PANIC_OBJS' compiler/Makefile; then
  bad "Makefile missing DRIVER_SEED_*_OBJS single-authority lists (sat/lsp/bridge/panic)"
else
  sat_body=$(awk '
    /^bootstrap-driver-seed-sat-rebuild:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  lsp_body=$(awk '
    /^bootstrap-driver-seed-lsp-x-objs:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  bridge_body=$(awk '
    /^bootstrap-driver-seed-bridge:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  panic_body=$(awk '
    /^bootstrap-driver-seed-panic:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  user_asm_body=$(awk '
    /^bootstrap-driver-seed-user-asm-seed-objs:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  glue_body=$(awk '
    /^bootstrap-driver-seed-asm-glue-standalone:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  pipe_x_body=$(awk '
    /^bootstrap-driver-seed-pipeline-x:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  orch_raw_bridge=$(grep -E 'mk (src/x_seed_bridge\.o|runtime_panic\.o)' compiler/scripts/bootstrap_driver_seed.sh || true)
  orch_raw_pipe=$(grep -E 'mk pipeline_x\.o' compiler/scripts/bootstrap_driver_seed.sh || true)
  if echo "$sat_body" | grep -qE 'src/diag\.o|runtime_io_abi' \
    && ! echo "$sat_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile sat-rebuild still inlines .o list (must be shell + export)"
  elif ! echo "$sat_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile sat-rebuild recipe missing bootstrap_driver_seed_rebuild_leaves.sh"
  elif echo "$lsp_body" | grep -qE 'lsp_io_x\.o|lsp_x\.o' \
    && ! echo "$lsp_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile lsp-x-objs still inlines .o list (must be shell + export)"
  elif ! echo "$lsp_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile lsp-x-objs recipe missing bootstrap_driver_seed_rebuild_leaves.sh"
  elif ! echo "$bridge_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile bridge leaf missing bootstrap_driver_seed_rebuild_leaves.sh"
  elif ! echo "$panic_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile panic leaf missing bootstrap_driver_seed_rebuild_leaves.sh"
  elif ! echo "$user_asm_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile user-asm leaf missing bootstrap_driver_seed_rebuild_leaves.sh"
  elif ! echo "$glue_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile glue leaf missing bootstrap_driver_seed_rebuild_leaves.sh"
  elif ! echo "$pipe_x_body" | grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh'; then
    bad "Makefile pipeline-x leaf missing bootstrap_driver_seed_rebuild_leaves.sh (wave725)"
  elif [ -n "$orch_raw_bridge" ]; then
    bad "bootstrap_driver_seed.sh still mk raw bridge/panic .o (must use thin leaves)"
  elif [ -n "$orch_raw_pipe" ]; then
    bad "bootstrap_driver_seed.sh still mk pipeline_x.o raw (must use bootstrap-driver-seed-pipeline-x)"
  elif grep -qE 'src/diag\.o|lsp_io_x\.o|simd_enc\.o|x_seed_bridge\.o|runtime_panic\.o|user_asm_seed_bridge\.o|pipeline_glue_standalone\.o' \
    compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh; then
    bad "bootstrap_driver_seed_rebuild_leaves.sh must not hardcode .o list (dual authority)"
  else
    note "rebuild leaves (sat/lsp/bridge/panic/user-asm/glue/pipeline-x) → export + rebuild_leaves.sh"
  fi
fi

# wave725: §5b #1 check-abi pure shell · #8 asm-host thin leaf
if [ ! -f compiler/scripts/check_pipeline_gen_expr_i64_abi.sh ]; then
  bad "missing compiler/scripts/check_pipeline_gen_expr_i64_abi.sh (11.0.3 wave725 §5b #1)"
elif ! grep -q 'check_pipeline_gen_expr_i64_abi\.sh' compiler/Makefile; then
  bad "Makefile check-pipeline-gen-expr-i64-abi must call check_pipeline_gen_expr_i64_abi.sh"
elif ! grep -q 'check_pipeline_gen_expr_i64_abi\.sh' compiler/scripts/bootstrap_driver_seed.sh; then
  bad "bootstrap_driver_seed.sh must call check_pipeline_gen_expr_i64_abi.sh directly (§5b #1)"
else
  abi_body=$(awk '
    /^check-pipeline-gen-expr-i64-abi:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if echo "$abi_body" | grep -qE 'int64_t int_val|restored empty pipeline_gen'; then
    bad "Makefile check-abi still inlines restore/fail body (must be shell)"
  elif ! echo "$abi_body" | grep -q 'check_pipeline_gen_expr_i64_abi\.sh'; then
    bad "Makefile check-abi recipe missing check_pipeline_gen_expr_i64_abi.sh"
  else
    note "§5b #1 check-abi → check_pipeline_gen_expr_i64_abi.sh (pure shell)"
  fi
fi

if ! grep -q 'bootstrap-driver-seed-asm-host' compiler/Makefile \
  || ! grep -q 'DRIVER_SEED_ASM_HOST_DISPATCH_OBJS' compiler/Makefile; then
  bad "Makefile missing bootstrap-driver-seed-asm-host / DRIVER_SEED_ASM_HOST_DISPATCH_OBJS (wave725 §5b #8)"
elif ! grep -q 'bootstrap-driver-seed-asm-host' compiler/scripts/bootstrap_driver_seed.sh; then
  bad "bootstrap_driver_seed.sh must mk bootstrap-driver-seed-asm-host (not raw build-seed-asm-host)"
elif grep -qE 'mk build-seed-asm-host\b' compiler/scripts/bootstrap_driver_seed.sh; then
  bad "bootstrap_driver_seed.sh still mk raw build-seed-asm-host (must use thin leaf)"
else
  asm_host_body=$(awk '
    /^bootstrap-driver-seed-asm-host:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if ! echo "$asm_host_body" | grep -q 'build_seed_asm_host\.sh'; then
    bad "Makefile bootstrap-driver-seed-asm-host missing build_seed_asm_host.sh"
  else
    note "§5b #8 asm-host → thin leaf bootstrap-driver-seed-asm-host + build_seed_asm_host.sh"
  fi
fi

# wave723: host-stubs body → shell via Makefile SCAN_BASE/CFLAGS export (no dual list)
if [ ! -f compiler/scripts/bootstrap_driver_seed_host_stubs.sh ]; then
  bad "missing compiler/scripts/bootstrap_driver_seed_host_stubs.sh (11.0.3 wave723)"
elif ! grep -q 'bootstrap_driver_seed_host_stubs\.sh' compiler/Makefile; then
  bad "Makefile host-stubs must call bootstrap_driver_seed_host_stubs.sh"
elif ! grep -q 'bootstrap-driver-seed-export-host-stubs' compiler/Makefile; then
  bad "Makefile missing host-stubs export leaf (G.7 single authority)"
elif ! grep -q 'DRIVER_SEED_HOST_STUBS_SCAN_BASE' compiler/Makefile; then
  bad "Makefile missing DRIVER_SEED_HOST_STUBS_SCAN_BASE single-authority scan list"
else
  stubs_body=$(awk '
    /^bootstrap-driver-seed-host-stubs:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  file_rule_body=$(awk '
    /^\$\(USER_ASM_SEED_HOST_STUBS\):/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if echo "$stubs_body" | grep -qE 'gen_asm_full_link_stubs\.pl|\$\(CC\)' \
    && ! echo "$stubs_body" | grep -q 'bootstrap_driver_seed_host_stubs\.sh'; then
    bad "Makefile thin host-stubs still inlines perl/cc (must be shell + export)"
  elif ! echo "$stubs_body" | grep -q 'bootstrap_driver_seed_host_stubs\.sh'; then
    bad "Makefile thin host-stubs recipe missing bootstrap_driver_seed_host_stubs.sh"
  elif echo "$file_rule_body" | grep -qE 'gen_asm_full_link_stubs\.pl|\$\(CC\)' \
    && ! echo "$file_rule_body" | grep -q 'bootstrap_driver_seed_host_stubs\.sh'; then
    bad "Makefile \$(USER_ASM_SEED_HOST_STUBS) still inlines perl/cc (must be shell + export)"
  elif ! echo "$file_rule_body" | grep -q 'bootstrap_driver_seed_host_stubs\.sh'; then
    bad "Makefile \$(USER_ASM_SEED_HOST_STUBS) missing bootstrap_driver_seed_host_stubs.sh"
  elif grep -qE 'user_asm_seed_bridge\.o|pipeline_glue_standalone\.o|backend_x86_64_enc_c\.o' \
    compiler/scripts/bootstrap_driver_seed_host_stubs.sh; then
    bad "bootstrap_driver_seed_host_stubs.sh must not hardcode SCAN .o list (dual authority)"
  else
    note "host-stubs → export leaf + bootstrap_driver_seed_host_stubs.sh (SCAN_BASE single authority)"
  fi
fi

if [ "$new_hits" -eq 0 ]; then
  note "g05 daily scripts: no make outside allowlist"
fi

# --- xlang-build.sh: product default must not hard-require make for build when build_tool exists ---
# Contract: daily build via build_tool; wave718 build-tool/clean pure shell
if grep -q 'run_build_tool' xlang-build.sh || grep -q 'build_tool' xlang-build.sh; then
  note "xlang-build.sh routes daily build via build_tool"
else
  bad "xlang-build.sh missing build_tool daily path"
fi

# wave718: build-tool / clean authority → shell (no make -C for those targets)
if [ ! -f compiler/scripts/build_tool.sh ]; then
  bad "missing compiler/scripts/build_tool.sh (11.0.3 wave718)"
elif ! grep -q 'scripts/build_tool\.sh' compiler/Makefile; then
  bad "Makefile build-tool must call scripts/build_tool.sh"
elif ! grep -q 'scripts/build_tool\.sh' xlang-build.sh; then
  bad "xlang-build.sh must call scripts/build_tool.sh (not make -C build-tool)"
elif grep -nE 'make -C compiler build-tool' xlang-build.sh | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "xlang-build.sh still has make -C compiler build-tool (must be shell)"
else
  note "build-tool → scripts/build_tool.sh (Makefile + xlang-build)"
fi

if [ ! -f compiler/scripts/clean_compiler.sh ]; then
  bad "missing compiler/scripts/clean_compiler.sh (11.0.3 wave718)"
elif ! grep -q 'scripts/clean_compiler\.sh' compiler/Makefile; then
  bad "Makefile clean must call scripts/clean_compiler.sh"
elif ! grep -q 'scripts/clean_compiler\.sh' xlang-build.sh; then
  bad "xlang-build.sh clean must call scripts/clean_compiler.sh"
elif grep -nE 'make -C compiler clean' xlang-build.sh | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "xlang-build.sh still has make -C compiler clean (must be shell)"
else
  note "clean → scripts/clean_compiler.sh (Makefile + xlang-build)"
fi

# wave719: bootstrap-token/lexer + bootstrap-driver-bstrict → shell
if [ ! -f compiler/scripts/bootstrap_token_lexer_smoke.sh ]; then
  bad "missing compiler/scripts/bootstrap_token_lexer_smoke.sh (11.0.3 wave719)"
elif ! grep -q 'bootstrap_token_lexer_smoke\.sh' compiler/Makefile; then
  bad "Makefile bootstrap-token/lexer must call bootstrap_token_lexer_smoke.sh"
elif ! grep -q 'bootstrap_token_lexer_smoke\.sh' xlang-build.sh; then
  bad "xlang-build.sh must call bootstrap_token_lexer_smoke.sh (not make -C token/lexer)"
elif grep -nE 'make -C compiler bootstrap-(token|lexer)' xlang-build.sh | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "xlang-build.sh still has make -C compiler bootstrap-token/lexer (must be shell)"
else
  note "bootstrap-token/lexer → bootstrap_token_lexer_smoke.sh (Makefile + xlang-build)"
fi

if [ ! -f compiler/scripts/bootstrap_driver_bstrict.sh ]; then
  bad "missing compiler/scripts/bootstrap_driver_bstrict.sh (11.0.3 wave719)"
elif ! grep -q 'bootstrap_driver_bstrict\.sh' compiler/Makefile; then
  bad "Makefile bootstrap-driver-bstrict must call bootstrap_driver_bstrict.sh"
elif ! grep -q 'bootstrap_driver_bstrict\.sh' xlang-build.sh; then
  bad "xlang-build.sh must call bootstrap_driver_bstrict.sh (not make -C bstrict)"
elif grep -nE 'make -C compiler bootstrap-driver-bstrict' xlang-build.sh | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "xlang-build.sh still has make -C compiler bootstrap-driver-bstrict (must be shell)"
else
  # Recipe body only (stop at next non-comment target line); must not inline build/refresh
  bstrict_body=$(awk '
    /^bootstrap-driver-bstrict: bootstrap-driver-seed$/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if echo "$bstrict_body" | grep -qE 'build_xlang_asm\.sh|refresh-xlang-asm-gate'; then
    bad "Makefile bootstrap-driver-bstrict recipe still inlines build/refresh (must be shell)"
  elif ! echo "$bstrict_body" | grep -q 'bootstrap_driver_bstrict\.sh'; then
    bad "Makefile bootstrap-driver-bstrict recipe missing shell call"
  else
    note "bootstrap-driver-bstrict → bootstrap_driver_bstrict.sh (Makefile + xlang-build)"
  fi
fi

# wave720: test* / bootstrap-verify → shell (xlang-build product entry 0× make -C)
if [ ! -f compiler/scripts/run_compiler_tests.sh ]; then
  bad "missing compiler/scripts/run_compiler_tests.sh (11.0.3 wave720)"
elif ! grep -q 'run_compiler_tests\.sh' compiler/Makefile; then
  bad "Makefile test_c/test_x must call run_compiler_tests.sh"
elif ! grep -q 'run_compiler_tests\.sh' xlang-build.sh; then
  bad "xlang-build.sh must call run_compiler_tests.sh (not make -C test*)"
elif grep -nE 'make -C compiler test(_c|_x)?' xlang-build.sh | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "xlang-build.sh still has make -C compiler test* (must be shell)"
else
  # Recipe body only for test_c
  test_c_body=$(awk '
    /^test_c:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if echo "$test_c_body" | grep -qE 'run-all-c\.sh' && ! echo "$test_c_body" | grep -q 'run_compiler_tests\.sh'; then
    bad "Makefile test_c still inlines run-all-c (must be shell)"
  elif ! echo "$test_c_body" | grep -q 'run_compiler_tests\.sh'; then
    bad "Makefile test_c recipe missing run_compiler_tests.sh"
  else
    note "test_c/test_x/test → run_compiler_tests.sh (Makefile + xlang-build)"
  fi
fi

if [ ! -f compiler/scripts/bootstrap_verify_bstrict.sh ]; then
  bad "missing compiler/scripts/bootstrap_verify_bstrict.sh (11.0.3 wave720)"
elif ! grep -q 'bootstrap_verify_bstrict\.sh' compiler/Makefile; then
  bad "Makefile check-7.2-bstrict must call bootstrap_verify_bstrict.sh"
elif ! grep -q 'bootstrap_verify_bstrict\.sh' xlang-build.sh; then
  bad "xlang-build.sh bootstrap-verify must call bootstrap_verify_bstrict.sh"
elif grep -nE 'make -C compiler bootstrap-verify' xlang-build.sh | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "xlang-build.sh still has make -C compiler bootstrap-verify (must be shell)"
else
  verify_body=$(awk '
    /^check-7\.2-bstrict:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if echo "$verify_body" | grep -qE 'run-lexer\.sh|verify-selfhost-stage2' && ! echo "$verify_body" | grep -q 'bootstrap_verify_bstrict\.sh'; then
    bad "Makefile check-7.2-bstrict still inlines stage suite (must be shell)"
  elif ! echo "$verify_body" | grep -q 'bootstrap_verify_bstrict\.sh'; then
    bad "Makefile check-7.2-bstrict recipe missing bootstrap_verify_bstrict.sh"
  else
    note "bootstrap-verify → bootstrap_verify_bstrict.sh (Makefile + xlang-build)"
  fi
fi

# remaining make -C in xlang-build: must be 0 after wave720
xb_make=$(grep -cE 'make -C compiler' xlang-build.sh || true)
echo "  INFO xlang-build.sh make -C compiler sites: ${xb_make:-0} (wave720 target = 0)"
if [ "${xb_make:-0}" -gt 0 ]; then
  bad "xlang-build.sh make -C sites ${xb_make} > 0 (wave720: product entry must be 0-make)"
else
  note "xlang-build.sh product entry: 0× make -C compiler"
fi

# --- migration table exists and mentions classes ---
if grep -q '11.0.1' analysis/Makefile迁移表.md && grep -q 'xbuild link-product' analysis/Makefile迁移表.md; then
  note "Makefile迁移表.md present (11.0.1 inventory)"
else
  bad "analysis/Makefile迁移表.md incomplete"
fi

# --- C迁移 11.0.1 checked ---
if grep -q '11.0.1' analysis/C迁移追踪.md && grep -q 'Makefile迁移表' analysis/C迁移追踪.md; then
  note "C迁移追踪 links migration table"
else
  bad "C迁移追踪.md missing 11.0.1 / migration table link"
fi

# --- wave726: PATH runtime probe present + obj-catalog export (11.0.4 start) ---
if [ -f tests/run-product-path-zero-make-path-probe.sh ] \
  && grep -q 'PATH-PROBE' tests/run-product-path-zero-make-path-probe.sh \
  && grep -q 'g05_prepare_and_relink' tests/run-product-path-zero-make-path-probe.sh; then
  note "PATH 0-make runtime probe script present (wave726)"
else
  bad "missing tests/run-product-path-zero-make-path-probe.sh (wave726 PATH probe)"
fi

if grep -q 'bootstrap-driver-seed-export-obj-catalog' compiler/Makefile \
  && [ -f compiler/scripts/driver_seed_obj_catalog.sh ]; then
  note "export-obj-catalog + driver_seed_obj_catalog.sh (OBJS read API, G.7)"
else
  bad "missing bootstrap-driver-seed-export-obj-catalog / driver_seed_obj_catalog.sh (wave726)"
fi

# --- wave727/728: OBJS defs in mk/ fragments (11.0.4) + tests/lib make hub (11.2.3) ---
if [ -f compiler/mk/user_asm_seed_objs.mk ] \
  && [ -f compiler/mk/driver_seed_export_lists.mk ] \
  && [ -f compiler/mk/driver_seed_composites.mk ] \
  && grep -q 'include mk/user_asm_seed_objs.mk' compiler/Makefile \
  && grep -q 'include mk/driver_seed_export_lists.mk' compiler/Makefile \
  && grep -q 'include mk/driver_seed_composites.mk' compiler/Makefile; then
  note "mk user_asm + export_lists + composites included (OBJS leave Makefile body)"
else
  bad "missing compiler/mk/*.mk includes (wave727/728 11.0.4 OBJS extract)"
fi

# G.7: leaf + composite list assignments must not reappear as bare defs in Makefile body
if grep -nE '^DRIVER_SEED_(PIPELINE_X|SAT_REBUILD|LSP_X|BRIDGE|PANIC)_OBJS[[:space:]]*=' compiler/Makefile \
  | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
  bad "Makefile still assigns DRIVER_SEED_*_OBJS (must live only in mk/driver_seed_export_lists.mk)"
elif grep -nE '^USER_ASM_SEED_OBJS[[:space:]]*=' compiler/Makefile \
  | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
  bad "Makefile still assigns USER_ASM_SEED_OBJS (must live only in mk/user_asm_seed_objs.mk)"
elif grep -nE '^DRIVER_SEED_(OBJS|LINK_BASE|PREREQS|X_OBJS|X_FRONTEND_OBJS)[[:space:]]*=' compiler/Makefile \
  | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
  bad "Makefile still assigns DRIVER_SEED composites (must live only in mk/driver_seed_composites.mk)"
elif grep -nE '^BOOTSTRAP_DRIVER_SEED_LINK_BASE[[:space:]]*=' compiler/Makefile \
  | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
  bad "Makefile still assigns BOOTSTRAP_DRIVER_SEED_LINK_BASE (must live only in mk/driver_seed_composites.mk)"
elif ! grep -q '^USER_ASM_SEED_OBJS' compiler/mk/user_asm_seed_objs.mk \
  || ! grep -q '^DRIVER_SEED_SAT_REBUILD_OBJS' compiler/mk/driver_seed_export_lists.mk \
  || ! grep -q '^DRIVER_SEED_OBJS' compiler/mk/driver_seed_composites.mk \
  || ! grep -q '^DRIVER_SEED_LINK_BASE' compiler/mk/driver_seed_composites.mk \
  || ! grep -q '^DRIVER_SEED_PREREQS' compiler/mk/driver_seed_composites.mk; then
  bad "mk fragments missing authoritative USER_ASM / SAT_REBUILD / composite list assignments"
else
  note "OBJS list authority → compiler/mk/*.mk only (no dual assign in Makefile)"
fi

# Authority lists also referenced by earlier gate checks: accept mk/ + Makefile
if ! grep -q 'DRIVER_SEED_PIPELINE_X_OBJS' compiler/mk/driver_seed_export_lists.mk \
  || ! grep -q 'DRIVER_SEED_ASM_HOST_DISPATCH_OBJS' compiler/mk/user_asm_seed_objs.mk \
  || ! grep -q 'DRIVER_SEED_X_FRONTEND_OBJS' compiler/mk/driver_seed_composites.mk; then
  bad "mk fragments missing PIPELINE_X / ASM_HOST_DISPATCH / X_FRONTEND lists"
else
  note "§5b + composite catalog keys present in mk fragments"
fi

if [ -f tests/lib/compiler-make.sh ] \
  && grep -q 'xlang_compiler_make' tests/lib/compiler-make.sh \
  && grep -q 'compiler-make\.sh' tests/lib/build-std-c-o.sh \
  && grep -q 'xlang_compiler_make' tests/lib/build-std-c-o.sh \
  && grep -q 'compiler-make\.sh' tests/lib/ensure-compiler-seed.sh \
  && grep -q 'xlang_compiler_make' tests/lib/ensure-compiler-seed.sh; then
  # Hub must not reintroduce raw make -C outside compiler-make.sh
  raw_lib=$(grep -RInE 'make[[:space:]]+-C[[:space:]]+(compiler|"\$compiler_dir")' tests/lib \
    --include='*.sh' 2>/dev/null \
    | grep -v 'compiler-make\.sh' \
    | grep -vE ':[0-9]+:[[:space:]]*#' \
    || true)
  if [ -n "$raw_lib" ]; then
    bad "tests/lib still has raw make -C (must use xlang_compiler_make); wave728:"
    echo "$raw_lib" | head -20 >&2
  else
    note "tests/lib make hub: 0 raw make -C outside compiler-make.sh (11.2.3 wave728)"
  fi
else
  bad "missing tests/lib/compiler-make.sh or ensure/build-std not migrated (wave727/728)"
fi

# Hard-run PATH probe (daily product path must not exec make)
if [ -x tests/run-product-path-zero-make-path-probe.sh ] || [ -f tests/run-product-path-zero-make-path-probe.sh ]; then
  chmod +x tests/run-product-path-zero-make-path-probe.sh 2>/dev/null || true
  if bash tests/run-product-path-zero-make-path-probe.sh; then
    note "PATH 0-make runtime probe executed OK"
  else
    bad "PATH 0-make runtime probe failed"
  fi
fi

# Hard-run catalog --check (mk include expands correctly; wave728 composites included)
if bash compiler/scripts/driver_seed_obj_catalog.sh --check >/tmp/wave728_obj_catalog.out 2>/tmp/wave728_obj_catalog.err; then
  note "driver_seed_obj_catalog --check OK (18 keys incl. composites)"
  # Non-empty DRIVER_SEED_OBJS / LINK_BASE sanity
  if ! grep -q '^DRIVER_SEED_OBJS=.*\.o' /tmp/wave728_obj_catalog.out \
    || ! grep -q '^DRIVER_SEED_LINK_BASE=.*driver_x\.o' /tmp/wave728_obj_catalog.out; then
    bad "catalog composites empty or missing driver_x.o (mk include broken?)"
  else
    note "catalog DRIVER_SEED_OBJS / LINK_BASE non-empty"
  fi
else
  bad "driver_seed_obj_catalog --check failed (see /tmp/wave728_obj_catalog.err)"
  cat /tmp/wave728_obj_catalog.err >&2 || true
fi

# --- wave729: root Makefile help-only → ./xbuild (11.0.4); G.7 xbuild body = xlang-build.sh ---
if [ -x ./xbuild ] || [ -f ./xbuild ]; then
  if head -20 ./xbuild | grep -q 'xlang-build\.sh' \
    && ! grep -qE 'run_build_tool|make -C' ./xbuild; then
    note "./xbuild thin-forward to xlang-build.sh only (G.7)"
  else
    bad "./xbuild must only forward to xlang-build.sh (no second body)"
  fi
else
  bad "missing ./xbuild product entry (wave729 11.0.4)"
fi

if grep -q 'help-only' Makefile \
  && grep -q '\./xbuild' Makefile \
  && grep -q '\.DEFAULT_GOAL := help' Makefile; then
  # Must not re-list full target recipes that call xlang-build by name for each target
  # (compat % forward is OK; explicit multi-recipe wrappers are the old thick style).
  if grep -nE '^\t\./xlang-build\.sh ' Makefile | grep -v help | grep -q .; then
    bad "root Makefile still has explicit xlang-build recipes (must be help-only + % → xbuild)"
  else
    note "root Makefile help-only → ./xbuild (11.0.4 wave729)"
  fi
else
  bad "root Makefile not help-only / missing ./xbuild (wave729)"
fi

# 8.3 glue map present in C迁移追踪 (inventory, not changelog)
if grep -q '### 8.3' analysis/C迁移追踪.md \
  && grep -q 'pipeline_glue.c' analysis/C迁移追踪.md \
  && grep -q '消费方' analysis/C迁移追踪.md; then
  note "8.3 glue map + consumers present in C迁移追踪"
else
  bad "C迁移追踪 8.3 glue map missing consumer section (wave729)"
fi

# Changelog lives only in 自举进度 (not C迁移追踪)
if grep -qE '^## 变更记录' analysis/C迁移追踪.md; then
  bad "C迁移追踪.md must not carry ## 变更记录 (write waves in 自举进度 only)"
else
  note "C迁移追踪 has no wave changelog section (authority: 自举进度)"
fi

echo "=== gate summary ==="
if [ "$fail" -ne 0 ]; then
  echo "FAIL product-path 0-make static gate" >&2
  exit 1
fi
echo "OK product-path 0-make static gate (allowlist frozen; class-G + bootstrap + test* shell; xlang-build 0-make; PATH probe; mk OBJS+composites; catalog --check; tests/lib hub; root help→xbuild)"
exit 0
