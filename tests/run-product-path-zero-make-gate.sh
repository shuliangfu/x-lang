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

echo "=== 11.0.2/11.0.3/11.0.4 + 11.1.6/11.2.3/11.2.5/11.4/11.5 product-path 0-make static gate (wave714–741) ==="

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

# wave722/724/725 + wave747: rebuild leaves → shell; default catalog mode (R4)
if [ ! -f compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh ]; then
  bad "missing compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh (11.0.3 wave722+)"
elif ! grep -q 'bootstrap_driver_seed_rebuild_leaves\.sh' compiler/Makefile; then
  bad "Makefile rebuild leaves must call bootstrap_driver_seed_rebuild_leaves.sh"
elif ! grep -q 'driver_seed_obj_catalog\.sh' compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh \
  || ! grep -q 'catalog_key=' compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh; then
  bad "rebuild_leaves must default to catalog KEY mode table (wave747 R4)"
elif ! grep -q 'bootstrap-driver-seed-export-sat-rebuild' compiler/Makefile \
  || ! grep -q 'bootstrap-driver-seed-export-lsp-x-objs' compiler/Makefile; then
  bad "Makefile missing sat/lsp export leaves (G.7 inventory mirrors / legacy escape)"
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
    note "rebuild leaves → catalog+mode table (wave747) + make pattern bodies; export leaves inventory"
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

# remaining make -C in xlang-build:
#   wave720: product targets 0× make -C
#   wave730: run_compiler_make hub for CI/cold/leaves
#   wave733: hub body moved to tests/lib/compiler-make.sh (G.7) → xlang-build 0× make -C
xb_make_exec=$(grep -nE 'make -C compiler' xlang-build.sh \
  | grep -vE '^[0-9]+:[[:space:]]*#' \
  || true)
xb_make_n=$(printf '%s\n' "$xb_make_exec" | grep -c . || true)
echo "  INFO xlang-build.sh executable make -C compiler sites: ${xb_make_n:-0} (wave733 expects 0; body in compiler-make.sh)"
if [ "${xb_make_n:-0}" -eq 0 ] \
  && grep -q 'run_compiler_make()' xlang-build.sh \
  && grep -q 'tests/lib/compiler-make\.sh' xlang-build.sh; then
  note "xlang-build.sh: 0× make -C; run_compiler_make → tests/lib/compiler-make.sh (G.7 wave733)"
else
  bad "xlang-build.sh must have 0 make -C and delegate via run_compiler_make → compiler-make.sh; got: $xb_make_exec"
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

# --- wave730: 11.2.5 CI workflows + 11.4.3 docker-ci outer 0× make -C ---
# Outer CI/docker must call ./xbuild; residual make graph only via run_compiler_make hub.
if grep -q 'run_compiler_make' xlang-build.sh \
  && grep -q 'compiler-all|ci-all' xlang-build.sh \
  && grep -q 'bootstrap-driver-seed)' xlang-build.sh \
  && grep -q 'compiler-make)' xlang-build.sh; then
  note "xlang-build CI/cold hub: compiler-all + bootstrap-driver-seed + compiler-make (wave730)"
else
  bad "xlang-build missing wave730 CI hub targets (compiler-all / bootstrap-driver-seed / compiler-make)"
fi

# --- wave731: 11.4.1 build.sh thin → xbuild; 11.4.5/6 docker + delete-one outer entry ---
# build.sh must not host-cc assemble build_tool (G.7: only build_tool.sh residual).
if [ -x build.sh ] || [ -f build.sh ]; then
  if grep -qE 'exec sh "\$ROOT/xbuild"|exec .*xbuild' build.sh \
    && ! grep -nE '[[:space:]]cc[[:space:]]|\$CC' build.sh | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
    note "build.sh thin-forwards ./xbuild (no host-cc; wave731 11.4.1)"
  else
    bad "build.sh must thin-forward ./xbuild and must not invoke host-cc (wave731 11.4.1)"
  fi
else
  bad "missing build.sh (legacy alias required until docs/LICENSE migrate)"
fi

# delete-one-c-file: outer bootstrap via ./xbuild (not raw make -C / xlang_compiler_make dual)
if [ -f tests/lib/delete-one-c-file.sh ]; then
  if grep -q '\./xbuild bootstrap-driver-bstrict' tests/lib/delete-one-c-file.sh \
    && ! grep -nE 'make[[:space:]]+-C[[:space:]]+compiler' tests/lib/delete-one-c-file.sh \
      | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
    note "delete-one-c-file uses ./xbuild bootstrap-driver-bstrict (11.4.6)"
  else
    bad "delete-one-c-file must call ./xbuild bootstrap-driver-bstrict (wave731 11.4.6)"
  fi
else
  bad "missing tests/lib/delete-one-c-file.sh"
fi

# Dockerfile documents preferred ./xbuild entry (packages residual until stage 12)
if [ -f tests/docker/linux-dev.Dockerfile ]; then
  if grep -q 'XLANG_PREFERRED_ENTRY=\./xbuild' tests/docker/linux-dev.Dockerfile \
    && grep -q 'org.xlang.entry="./xbuild"' tests/docker/linux-dev.Dockerfile; then
    note "linux-dev.Dockerfile documents ./xbuild preferred entry (11.4.5)"
  else
    bad "linux-dev.Dockerfile missing ./xbuild entry labels/env (wave731 11.4.5)"
  fi
else
  bad "missing tests/docker/linux-dev.Dockerfile"
fi

# --- wave732: 11.2.3 tests/run-*.sh → xlang_compiler_make (0 raw make -C) ---
# Exclude this gate + PATH probe (they document/scan make -C by design).
# Use a file list so the gate itself is not grepped.
run_raw=$(
  find tests -maxdepth 1 -name 'run-*.sh' ! -name 'run-product-path-zero-make-gate.sh' \
    ! -name 'run-product-path-zero-make-path-probe.sh' -print0 2>/dev/null \
    | xargs -0 grep -nE 'make[[:space:]]+-C[[:space:]]+' 2>/dev/null \
    | grep -vE ':[0-9]+:[[:space:]]*#' \
    || true
)
if [ -n "$run_raw" ]; then
  bad "tests/run-*.sh still has raw make -C (must use xlang_compiler_make); wave732:"
  echo "$run_raw" | head -30 >&2
else
  note "tests/run-*.sh: 0 raw make -C (hub xlang_compiler_make; 11.2.3 wave732)"
fi
# Spot-check high-traffic entry scripts source the hub
spot_ok=1
for f in tests/run-all.sh tests/run-all-c.sh tests/run-goto.sh tests/run-without-c.sh; do
  if [ -f "$f" ] && grep -q 'compiler-make\.sh' "$f" && grep -q 'xlang_compiler_make' "$f"; then
    :
  else
    bad "$f must source tests/lib/compiler-make.sh and call xlang_compiler_make (wave732)"
    spot_ok=0
  fi
done
if [ "$spot_ok" -eq 1 ]; then
  note "run-all / run-all-c / run-goto / run-without-c use xlang_compiler_make hub"
fi

# --- wave733: 11.2.3 close — all tests/**/*.sh 0 raw make -C (bench vacuous) ---
# Only hub body may contain make -C; gate/probe scan make by design.
tests_all_raw=$(
  find tests -name '*.sh' \
    ! -path 'tests/lib/compiler-make.sh' \
    ! -name 'run-product-path-zero-make-gate.sh' \
    ! -name 'run-product-path-zero-make-path-probe.sh' \
    -print0 2>/dev/null \
    | xargs -0 grep -nE 'make[[:space:]]+-C[[:space:]]+' 2>/dev/null \
    | grep -vE ':[0-9]+:[[:space:]]*#' \
    || true
)
if [ -n "$tests_all_raw" ]; then
  bad "tests/**/*.sh still has raw make -C outside hub; wave733 11.2.3:"
  echo "$tests_all_raw" | head -30 >&2
else
  note "tests/**/*.sh: 0 raw make -C outside compiler-make.sh (11.2.3 closed; bench vacuous)"
fi
# Hub CLI mode (xbuild run_compiler_make)
if grep -q 'BASH_SOURCE\[0\]' tests/lib/compiler-make.sh \
  && grep -q 'xlang_compiler_make "\$@"' tests/lib/compiler-make.sh; then
  note "compiler-make.sh CLI mode present (source + exec; G.7 wave733)"
else
  bad "tests/lib/compiler-make.sh missing CLI entry for xbuild run_compiler_make"
fi
# g05 first-class targets on xbuild (11.1.6 slice)
if grep -q 'ensure|g05-ensure' xlang-build.sh \
  && grep -q 'link-product|relink' xlang-build.sh \
  && grep -q 'link-env|g05-export' xlang-build.sh \
  && grep -q 'run_g05_prepare_and_relink' xlang-build.sh \
  && grep -q 'g05_ensure_relink_prereqs\.sh' xlang-build.sh \
  && grep -q 'g05_prepare_and_relink\.sh' xlang-build.sh; then
  note "xbuild g05 targets: ensure / link-env / link-product (11.1.6 wave733; 0 make)"
else
  bad "xlang-build missing wave733 g05 first-class targets (ensure/link-env/link-product)"
fi

# wave734: refresh-xlang-asm-gate → shell body + xbuild first-class
if [ ! -f compiler/scripts/refresh_xlang_asm_gate.sh ]; then
  bad "missing compiler/scripts/refresh_xlang_asm_gate.sh (11.1.6 wave734)"
elif ! grep -q 'g05_prepare_and_relink\.sh' compiler/scripts/refresh_xlang_asm_gate.sh \
  || ! grep -q 'migrate' compiler/scripts/refresh_xlang_asm_gate.sh \
  || ! grep -q 'xlang_asm' compiler/scripts/refresh_xlang_asm_gate.sh; then
  bad "refresh_xlang_asm_gate.sh must own migrate + g05 relink + xlang_asm overlay"
elif ! grep -q 'refresh_xlang_asm_gate\.sh' compiler/Makefile; then
  bad "Makefile refresh-xlang-asm-gate must call refresh_xlang_asm_gate.sh"
elif ! grep -q 'refresh-gate|refresh-xlang-asm-gate' xlang-build.sh \
  || ! grep -q 'run_refresh_xlang_asm_gate' xlang-build.sh; then
  bad "xlang-build missing refresh-gate first-class target (wave734)"
elif ! grep -q 'refresh_xlang_asm_gate\.sh' compiler/scripts/bootstrap_driver_bstrict.sh; then
  bad "bootstrap_driver_bstrict must call refresh_xlang_asm_gate.sh (not make refresh)"
elif grep -nE '["\$]MAKE["\s]* refresh-xlang-asm-gate|make refresh-xlang-asm-gate' \
  compiler/scripts/bootstrap_driver_bstrict.sh 2>/dev/null \
  | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "bootstrap_driver_bstrict still invokes make refresh-xlang-asm-gate"
else
  refresh_body=$(awk '
    /^refresh-xlang-asm-gate:/ { in_r=1; next }
    in_r && /^[^#[:space:]	]/ { exit }
    in_r { print }
  ' compiler/Makefile)
  if echo "$refresh_body" | grep -qE 'cp -f|g05_prepare|migrate-x-objs'; then
    bad "Makefile refresh-xlang-asm-gate recipe still inlines body (must be shell)"
  elif ! echo "$refresh_body" | grep -q 'refresh_xlang_asm_gate\.sh'; then
    bad "Makefile refresh-xlang-asm-gate recipe missing shell call"
  elif ! grep -q '\./xbuild refresh-gate' tests/run-refresh-xlang-asm-gate.sh; then
    bad "tests/run-refresh-xlang-asm-gate.sh must call ./xbuild refresh-gate"
  else
    note "refresh-xlang-asm-gate → refresh_xlang_asm_gate.sh + xbuild refresh-gate (11.1.6 wave734)"
  fi
fi

# wave735: migrate-x-objs → shell body + xbuild first-class; refresh 0× make migrate
if [ ! -f compiler/scripts/migrate_x_objs.sh ]; then
  bad "missing compiler/scripts/migrate_x_objs.sh (11.1.6 wave735)"
elif ! grep -q 'parser_x\.o' compiler/scripts/migrate_x_objs.sh \
  || ! grep -q 'typeck_x\.o' compiler/scripts/migrate_x_objs.sh \
  || ! grep -q 'codegen_x\.o' compiler/scripts/migrate_x_objs.sh; then
  bad "migrate_x_objs.sh must own parser/typeck/codegen _x.o compile"
elif ! grep -q 'migrate_x_objs\.sh' compiler/Makefile; then
  bad "Makefile migrate/parser_x/typeck_x/codegen_x leaves must call migrate_x_objs.sh"
elif ! grep -q 'migrate|migrate-x-objs' xlang-build.sh \
  || ! grep -q 'run_migrate_x_objs' xlang-build.sh; then
  bad "xlang-build missing migrate first-class target (wave735)"
elif ! grep -q 'migrate_x_objs\.sh' compiler/scripts/refresh_xlang_asm_gate.sh; then
  bad "refresh_xlang_asm_gate must call migrate_x_objs.sh (wave735)"
elif grep -nE '["\$]MAKE["\s]* migrate-x-objs|make migrate-x-objs' \
  compiler/scripts/refresh_xlang_asm_gate.sh 2>/dev/null \
  | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "refresh_xlang_asm_gate still invokes make migrate-x-objs"
else
  migrate_body=$(awk '
    /^migrate-x-objs:/ { in_m=1; next }
    in_m && /^[^#[:space:]	]/ { exit }
    in_m { print }
  ' compiler/Makefile)
  # Thin leaf may pass CC="$(CC)" env; ban real compile recipes only.
  if echo "$migrate_body" | grep -qE '\$\(CC\)[[:space:]]+\$\(CFLAGS\)|-c[[:space:]]+parser_gen\.c|-c[[:space:]]+typeck_gen\.c|-c[[:space:]]+codegen_gen\.c'; then
    bad "Makefile migrate-x-objs recipe still inlines cc (must be shell)"
  elif ! echo "$migrate_body" | grep -q 'migrate_x_objs\.sh'; then
    bad "Makefile migrate-x-objs recipe missing shell call"
  else
    # leaf recipes must not inline cc for the three companions
    for leaf in parser_x.o typeck_x.o codegen_x.o; do
      leaf_body=$(awk -v leaf="$leaf" '
        $0 ~ "^" leaf ":" { in_l=1; next }
        in_l && /^[^#[:space:]	]/ { exit }
        in_l { print }
      ' compiler/Makefile)
      if echo "$leaf_body" | grep -qE '\$\(CC\)[[:space:]]+\$\(CFLAGS\)| -c[[:space:]]+.*_gen\.c'; then
        bad "Makefile $leaf recipe still inlines cc (must call migrate_x_objs.sh)"
      fi
      if ! echo "$leaf_body" | grep -q 'migrate_x_objs\.sh'; then
        bad "Makefile $leaf recipe missing migrate_x_objs.sh"
      fi
    done
    note "migrate-x-objs → migrate_x_objs.sh + xbuild migrate (11.1.6 wave735)"
  fi
fi

# wave736: parser/typeck/codegen *_gen.c → ensure_migrate_gen.sh; migrate 0× make gen
# wave737: lexer_gen.c → same script (mode lexer); Makefile thin leaf
if [ ! -f compiler/scripts/ensure_migrate_gen.sh ]; then
  bad "missing compiler/scripts/ensure_migrate_gen.sh (11.1.6 wave736/737)"
elif ! grep -q 'parser_gen\.c' compiler/scripts/ensure_migrate_gen.sh \
  || ! grep -q 'typeck_gen\.c' compiler/scripts/ensure_migrate_gen.sh \
  || ! grep -q 'codegen_gen\.c' compiler/scripts/ensure_migrate_gen.sh; then
  bad "ensure_migrate_gen.sh must own parser/typeck/codegen _gen.c production"
elif ! grep -q 'ensure_lexer_gen\|lexer_gen\.c' compiler/scripts/ensure_migrate_gen.sh \
  || ! grep -q 'sync_lexer_gen_token_enum' compiler/scripts/ensure_migrate_gen.sh; then
  bad "ensure_migrate_gen.sh must own lexer_gen.c (wave737; pin/seed/-E + token enum)"
elif ! grep -q 'ensure_migrate_gen\.sh' compiler/Makefile; then
  bad "Makefile parser_gen/typeck_gen/codegen_gen/lexer_gen leaves must call ensure_migrate_gen.sh"
elif ! grep -q 'migrate-gen\|ensure-migrate-gen' xlang-build.sh \
  || ! grep -q 'ensure_migrate_gen\.sh' xlang-build.sh; then
  bad "xlang-build missing migrate-gen first-class target (wave736)"
elif ! grep -q 'lexer-gen\|ensure-lexer-gen' xlang-build.sh; then
  bad "xlang-build missing lexer-gen first-class target (wave737)"
elif ! grep -q 'ensure_migrate_gen\.sh' compiler/scripts/migrate_x_objs.sh; then
  bad "migrate_x_objs must call ensure_migrate_gen.sh (wave736; 0× make gen body)"
elif grep -nE '["\$]MAKE["\s]* (parser|typeck|codegen)_gen\.c|make (parser|typeck|codegen)_gen\.c' \
  compiler/scripts/migrate_x_objs.sh 2>/dev/null \
  | grep -vE '^[0-9]+:[ \t]*#' | grep -q .; then
  bad "migrate_x_objs still invokes make for *_gen.c"
else
  for leaf in parser_gen.c typeck_gen.c codegen_gen.c lexer_gen.c; do
    leaf_body=$(awk -v leaf="$leaf" '
      $0 ~ "^" leaf ":" { in_l=1; next }
      in_l && /^[^#[:space:]	]/ { exit }
      in_l { print }
    ' compiler/Makefile)
    # Ban residual force-regen / seed-cp / -E body in Makefile leaf
    if echo "$leaf_body" | grep -qE 'XLANG_FORCE_REGEN_GEN.*=.*1|cp -f seeds/|-E-extern|fix_slim_arena|sync_lexer_gen_token_enum'; then
      bad "Makefile $leaf recipe still inlines gen body (must call ensure_migrate_gen.sh)"
    fi
    if ! echo "$leaf_body" | grep -q 'ensure_migrate_gen\.sh'; then
      bad "Makefile $leaf recipe missing ensure_migrate_gen.sh"
    fi
  done
  note "parser/typeck/codegen/lexer *_gen.c → ensure_migrate_gen.sh + xbuild migrate-gen|lexer-gen (11.1.6 wave736/737)"
fi

# wave738: driver_gen.c + preprocess_gen.c → ensure_driver_gen.sh; Makefile thin leaves
if [ ! -f compiler/scripts/ensure_driver_gen.sh ]; then
  bad "missing compiler/scripts/ensure_driver_gen.sh (11.1.6 wave738)"
elif ! grep -q 'driver_gen\.c' compiler/scripts/ensure_driver_gen.sh \
  || ! grep -q 'preprocess_gen\.c' compiler/scripts/ensure_driver_gen.sh; then
  bad "ensure_driver_gen.sh must own driver_gen.c + preprocess_gen.c production"
elif ! grep -q 'fix_driver_gen_duplicate_main' compiler/scripts/ensure_driver_gen.sh \
  || ! grep -q 'MAIN_X_DEPS\|any_dep_newer' compiler/scripts/ensure_driver_gen.sh; then
  bad "ensure_driver_gen.sh must own MAIN_X_DEPS freshness + fix_driver_gen_duplicate_main"
elif ! grep -q 'ensure_driver_gen\.sh' compiler/Makefile; then
  bad "Makefile driver_gen/preprocess_gen leaves must call ensure_driver_gen.sh"
elif ! grep -q 'driver-gen\|ensure-driver-gen' xlang-build.sh \
  || ! grep -q 'ensure_driver_gen\.sh' xlang-build.sh; then
  bad "xlang-build missing driver-gen first-class target (wave738)"
elif ! grep -q 'preprocess-gen\|ensure-preprocess-gen' xlang-build.sh; then
  bad "xlang-build missing preprocess-gen first-class target (wave738)"
else
  for leaf in driver_gen.c preprocess_gen.c; do
    leaf_body=$(awk -v leaf="$leaf" '
      $0 ~ "^" leaf ":" { in_l=1; next }
      in_l && /^[^#[:space:]	]/ { exit }
      in_l { print }
    ' compiler/Makefile)
    # Ban residual force-regen / seed-cp / -E body in Makefile leaf
    if echo "$leaf_body" | grep -qE 'cp -f seeds/|-E-extern|fix_driver_gen_duplicate_main|MAIN_X_E_DIRS'; then
      bad "Makefile $leaf recipe still inlines gen body (must call ensure_driver_gen.sh)"
    fi
    if ! echo "$leaf_body" | grep -q 'ensure_driver_gen\.sh'; then
      bad "Makefile $leaf recipe missing ensure_driver_gen.sh"
    fi
  done
  note "driver/preprocess *_gen.c → ensure_driver_gen.sh + xbuild driver-gen|preprocess-gen (11.1.6 wave738)"
fi

# wave739: product lsp_*_gen.c + pipeline_gen.c → ensure_lsp_pipeline_gen.sh
if [ ! -f compiler/scripts/ensure_lsp_pipeline_gen.sh ]; then
  bad "missing compiler/scripts/ensure_lsp_pipeline_gen.sh (11.1.6 wave739)"
elif ! grep -q 'lsp_diag_gen\.c' compiler/scripts/ensure_lsp_pipeline_gen.sh \
  || ! grep -q 'lsp_io_gen\.c' compiler/scripts/ensure_lsp_pipeline_gen.sh \
  || ! grep -q 'lsp_gen\.c' compiler/scripts/ensure_lsp_pipeline_gen.sh \
  || ! grep -q 'pipeline_gen\.c' compiler/scripts/ensure_lsp_pipeline_gen.sh; then
  bad "ensure_lsp_pipeline_gen.sh must own lsp_diag/io/lsp + pipeline_gen production"
elif ! grep -q 'check_pipeline_gen_expr_i64_abi' compiler/scripts/ensure_lsp_pipeline_gen.sh \
  || ! grep -q 'g_lsp_state_buf\|C-04 -E-extern TU aliases' compiler/scripts/ensure_lsp_pipeline_gen.sh; then
  bad "ensure_lsp_pipeline_gen.sh must own i64 ABI check + lsp C-04/state_buf posts"
elif ! grep -q 'ensure_lsp_pipeline_gen\.sh' compiler/Makefile; then
  bad "Makefile lsp/pipeline gen leaves must call ensure_lsp_pipeline_gen.sh"
elif ! grep -q 'lsp-gen\|ensure-lsp-gen' xlang-build.sh \
  || ! grep -q 'ensure_lsp_pipeline_gen\.sh' xlang-build.sh; then
  bad "xlang-build missing lsp-gen first-class target (wave739)"
elif ! grep -q 'pipeline-gen\|ensure-pipeline-gen' xlang-build.sh; then
  bad "xlang-build missing pipeline-gen first-class target (wave739)"
else
  for leaf in lsp_diag_gen.c lsp_io_gen.c lsp_gen.c pipeline_gen.c; do
    leaf_body=$(awk -v leaf="$leaf" '
      $0 ~ "^" leaf ":" { in_l=1; next }
      in_l && /^[^#[:space:]	]/ { exit }
      in_l { print }
    ' compiler/Makefile)
    # Ban residual body on non-comment recipe lines only (nearby # comments may mention -E-extern)
    leaf_code=$(echo "$leaf_body" | grep -vE '^[[:space:]]*#' || true)
    if echo "$leaf_code" | grep -qE 'cp -f seeds/|-E-extern|g_lsp_state_buf|check-pipeline-gen-expr-i64'; then
      bad "Makefile $leaf recipe still inlines gen body (must call ensure_lsp_pipeline_gen.sh)"
    fi
    if ! echo "$leaf_body" | grep -q 'ensure_lsp_pipeline_gen\.sh'; then
      bad "Makefile $leaf recipe missing ensure_lsp_pipeline_gen.sh"
    fi
  done
  note "lsp/pipeline *_gen.c → ensure_lsp_pipeline_gen.sh + xbuild lsp-gen|pipeline-gen (11.1.6 wave739)"
fi

# wave740: archaeology driver_*_gen + lsp_io_std_heap_gen → ensure_archaeology_gen.sh
if [ ! -f compiler/scripts/ensure_archaeology_gen.sh ]; then
  bad "missing compiler/scripts/ensure_archaeology_gen.sh (11.1.6 wave740)"
elif ! grep -q 'driver_fmt_gen\.c' compiler/scripts/ensure_archaeology_gen.sh \
  || ! grep -q 'driver_emit_gen\.c' compiler/scripts/ensure_archaeology_gen.sh \
  || ! grep -q 'lsp_io_std_heap_gen\.c' compiler/scripts/ensure_archaeology_gen.sh; then
  bad "ensure_archaeology_gen.sh must own driver_*_gen + lsp_io_std_heap_gen production"
elif ! grep -q 'Track L\|archaeology' compiler/scripts/ensure_archaeology_gen.sh; then
  bad "ensure_archaeology_gen.sh must document Track L archaeology (not product link path)"
elif ! grep -q 'ensure_archaeology_gen\.sh' compiler/Makefile; then
  bad "Makefile archaeology gen leaves must call ensure_archaeology_gen.sh"
elif ! grep -q 'archaeology-gen\|ensure-archaeology-gen' xlang-build.sh \
  || ! grep -q 'ensure_archaeology_gen\.sh' xlang-build.sh; then
  bad "xlang-build missing archaeology-gen first-class target (wave740)"
else
  for leaf in driver_fmt_gen.c driver_check_gen.c driver_test_gen.c \
    driver_compile_gen.c driver_build_gen.c driver_run_gen.c driver_emit_gen.c \
    lsp_io_std_heap_gen.c; do
    leaf_body=$(awk -v leaf="$leaf" '
      $0 ~ "^" leaf ":" { in_l=1; next }
      in_l && /^[^#[:space:]	]/ { exit }
      in_l { print }
    ' compiler/Makefile)
    leaf_code=$(echo "$leaf_body" | grep -vE '^[[:space:]]*#' || true)
    if echo "$leaf_code" | grep -qE 'cp -f seeds/|-E-extern|DRIVER_SUBCMD_DIRS|LSP_X_E_DIRS'; then
      bad "Makefile $leaf recipe still inlines gen body (must call ensure_archaeology_gen.sh)"
    fi
    if ! echo "$leaf_body" | grep -q 'ensure_archaeology_gen\.sh'; then
      bad "Makefile $leaf recipe missing ensure_archaeology_gen.sh"
    fi
  done
  note "archaeology *_gen.c → ensure_archaeology_gen.sh + xbuild archaeology-gen (11.1.6 wave740)"
fi

# wave741: 11.5.2–4 tests/ host-cc policy (authority tests/HOST_CC_POLICY.md)
if [ ! -f tests/HOST_CC_POLICY.md ]; then
  bad "missing tests/HOST_CC_POLICY.md (11.5.2–4 wave741)"
elif ! grep -q '11\.5\.2' tests/HOST_CC_POLICY.md \
  || ! grep -q '11\.5\.3' tests/HOST_CC_POLICY.md \
  || ! grep -q '11\.5\.4' tests/HOST_CC_POLICY.md; then
  bad "HOST_CC_POLICY.md must document 11.5.2 / 11.5.3 / 11.5.4"
elif ! grep -qi 'permanent host-cc whitelist' tests/HOST_CC_POLICY.md; then
  bad "HOST_CC_POLICY.md must state permanent host-cc whitelist ruling"
elif ! grep -qi 'not product' tests/HOST_CC_POLICY.md; then
  bad "HOST_CC_POLICY.md must state these .c files are not product"
else
  note "tests/HOST_CC_POLICY.md present (11.5.2–4 wave741)"
fi

# Product g05 chain must not compile tests/std-* or abi/leak/safe C harnesses
g05_tests_c_hits=$(
  grep -nE 'tests/std-[^[:space:]"]+\.c|tests/abi/layout_abi\.c|tests/leak/leak_probe\.c|tests/safe/race_probe\.c' \
    compiler/scripts/g05_*.sh 2>/dev/null \
    | grep -vE ':[0-9]+:[[:space:]]*#' \
    || true
)
if [ -n "$g05_tests_c_hits" ]; then
  bad "g05_*.sh must not compile tests/ host-cc harness C (11.5; wave741):"
  echo "$g05_tests_c_hits" | head -20 >&2
else
  note "g05_*.sh: 0× tests/std-*|abi|leak|safe harness .c (11.5 not product)"
fi

std_c_n=$(find tests/std-* -name '*.c' -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "${std_c_n:-0}" -ge 40 ]; then
  note "tests/std-*/*.c inventory floor ok (n=${std_c_n} ≥ 40; 11.5.2)"
else
  bad "tests/std-*/*.c inventory collapsed (n=${std_c_n}; expect ≥40 for 11.5.2)"
fi

for f in \
  tests/abi/layout_abi.c \
  tests/leak/leak_probe.c \
  tests/safe/race_probe.c \
  tests/kernel/freestanding_stubs.c
do
  [ -f "$f" ] || bad "missing 11.5.3 probe $f"
done
[ "$fail" -eq 0 ] && note "11.5.3 abi|leak|safe|kernel probe .c present"

if grep -q 'HOST_CC_POLICY\|11\.5\.2\|tests host-cc' build.x; then
  note "build.x strategy map references tests host-cc policy (wave741)"
else
  bad "build.x must mention tests host-cc / HOST_CC_POLICY / 11.5.2 (wave741)"
fi

# wave742/743/744: 11.1.1 inventory + 11.1.2 schedule + 11.3 prereq edges
if [ ! -f compiler/docs/BUILD_DAG.md ]; then
  bad "missing compiler/docs/BUILD_DAG.md (11.1.1 wave742)"
elif ! grep -q '11\.1\.1' compiler/docs/BUILD_DAG.md \
  || ! grep -q 'DRIVER_SEED_PREREQS' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must document 11.1.1 + DRIVER_SEED_PREREQS"
elif ! grep -q '11\.1\.2' compiler/docs/BUILD_DAG.md \
  || ! grep -qiE 'dry-run|schedule|--run' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must document 11.1.2 schedule dry-run/run (wave743)"
elif ! grep -qE 'driver_seed_ensure_prereqs|wave744|ensure_prereqs' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must document wave744 driver_seed_ensure_prereqs"
elif [ ! -f compiler/scripts/product_build_dag.sh ]; then
  bad "missing compiler/scripts/product_build_dag.sh (11.1.1 wave742)"
elif [ ! -f compiler/scripts/driver_seed_ensure_prereqs.sh ]; then
  bad "missing compiler/scripts/driver_seed_ensure_prereqs.sh (wave744)"
elif ! grep -q 'driver_seed_ensure_prereqs' compiler/scripts/bootstrap_driver_seed.sh; then
  bad "bootstrap_driver_seed.sh must call driver_seed_ensure_prereqs (wave744)"
elif grep -nE '^bootstrap-driver-seed:.*DRIVER_SEED_PREREQS' compiler/Makefile \
  | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
  bad "Makefile must not use DRIVER_SEED_PREREQS as make-graph deps (wave744 shell ensure)"
elif ! grep -q 'product-dag\|build-dag\|cold-dag' xlang-build.sh \
  || ! grep -q 'product_build_dag\.sh' xlang-build.sh; then
  bad "xlang-build missing product-dag first-class target (wave742)"
elif ! grep -qE 'dry-run|--run|dag-run|dag-dry-run' xlang-build.sh; then
  bad "xlang-build missing product-dag --dry-run / --run (wave743 11.1.2)"
elif ! grep -qE 'driver-seed-prereqs|ensure-driver-seed-prereqs' xlang-build.sh; then
  bad "xlang-build missing driver-seed-prereqs target (wave744)"
elif ! grep -qE '11\.1\.1|BUILD_DAG|product.dag|DAG-as-data' build.x; then
  bad "build.x must mention 11.1.1 / BUILD_DAG / product-dag (wave742)"
elif ! grep -qE '11\.1\.2|dry-run|--run|schedule' build.x; then
  bad "build.x must mention 11.1.2 schedule / dry-run / --run (wave743)"
elif ! grep -qE 'ensure_prereqs|driver_seed_ensure_prereqs|wave744' build.x; then
  bad "build.x must mention wave744 prereq shell ensure"
elif [ ! -f compiler/docs/PLATFORM_LINKER.md ]; then
  bad "missing compiler/docs/PLATFORM_LINKER.md (wave745 11.1.3/4)"
elif ! grep -q '11\.1\.3' compiler/docs/PLATFORM_LINKER.md \
  || ! grep -q '11\.1\.4' compiler/docs/PLATFORM_LINKER.md; then
  bad "PLATFORM_LINKER.md must document 11.1.3 and 11.1.4"
elif [ ! -f compiler/scripts/host_platform_linker.sh ]; then
  bad "missing compiler/scripts/host_platform_linker.sh (wave745)"
elif ! grep -qE 'host-platform|linker-policy' xlang-build.sh \
  || ! grep -q 'host_platform_linker\.sh' xlang-build.sh; then
  bad "xlang-build missing host-platform / linker-policy (wave745)"
elif ! grep -qE '11\.1\.3|host.platform|PLATFORM_LINKER' build.x; then
  bad "build.x must mention 11.1.3 / host platform / PLATFORM_LINKER (wave745)"
elif ! grep -qE '11\.1\.4|linker.policy|SEED_LINK_CC' build.x; then
  bad "build.x must mention 11.1.4 / linker policy (wave745)"
elif ! grep -qE '11\.1\.3|PLATFORM_LINKER|host_platform_linker|wave745' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave745 PLATFORM_LINKER"
elif [ ! -f compiler/docs/LEAF_PATTERN_RESIDUAL.md ]; then
  bad "missing compiler/docs/LEAF_PATTERN_RESIDUAL.md (wave746 11.3.1 path)"
elif ! grep -q '11\.3\.1' compiler/docs/LEAF_PATTERN_RESIDUAL.md \
  || ! grep -qE 'R1|host.cc|from_x' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document 11.3.1 and residual classes"
elif [ ! -f compiler/scripts/leaf_pattern_residual.sh ]; then
  bad "missing compiler/scripts/leaf_pattern_residual.sh (wave746)"
elif ! grep -qE 'leaf-patterns|leaf-residual' xlang-build.sh \
  || ! grep -q 'leaf_pattern_residual\.sh' xlang-build.sh; then
  bad "xlang-build missing leaf-patterns / leaf-residual (wave746)"
elif ! grep -qE '11\.3\.1|leaf.pattern|LEAF_PATTERN' build.x; then
  bad "build.x must mention 11.3.1 / leaf pattern residual (wave746)"
elif ! grep -qE '11\.3\.1|LEAF_PATTERN|leaf_pattern_residual|wave746' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave746 LEAF_PATTERN"
elif [ ! -f compiler/scripts/ensure_host_cc_seed_o.sh ]; then
  bad "missing compiler/scripts/ensure_host_cc_seed_o.sh (wave748–753 R1 families)"
elif ! grep -q 'ensure_host_cc_seed_o\.sh' compiler/Makefile; then
  bad "Makefile must thin-call ensure_host_cc_seed_o.sh (wave748–753)"
elif ! grep -q 'RT_SEED_SLICE_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require RT_SEED_SLICE_OBJS (wave748)"
elif ! grep -q 'R1_CORE_SEED_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_CORE_SEED_OBJS (wave749)"
elif ! grep -q 'R1_FRONTEND_GLUE_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_FRONTEND_GLUE_OBJS (wave750)"
elif ! grep -q 'R1_MAIN_RUNTIME_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_MAIN_RUNTIME_OBJS (wave751)"
elif ! grep -q 'R1_ALIAS_STUBS_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_ALIAS_STUBS_OBJS (wave752)"
elif ! grep -q 'R1_EXTRA_CFLAGS_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_EXTRA_CFLAGS_OBJS (wave753)"
elif ! grep -q 'R1_MISC_BASENAME_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_MISC_BASENAME_OBJS (wave754)"
elif ! grep -q 'R1_SEED_MAP_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_SEED_MAP_OBJS (wave755)"
elif ! grep -q 'R1_CORE_SEED_OBJS' compiler/Makefile; then
  bad "Makefile must define R1_CORE_SEED_OBJS (wave749)"
elif ! grep -q 'R1_FRONTEND_GLUE_OBJS' compiler/Makefile; then
  bad "Makefile must define R1_FRONTEND_GLUE_OBJS (wave750)"
elif ! grep -q 'R1_MAIN_RUNTIME_OBJS' compiler/Makefile; then
  bad "Makefile must define R1_MAIN_RUNTIME_OBJS (wave751)"
elif ! grep -q 'R1_ALIAS_STUBS_OBJS' compiler/Makefile; then
  bad "Makefile must define R1_ALIAS_STUBS_OBJS (wave752)"
elif ! grep -q 'R1_EXTRA_CFLAGS_OBJS' compiler/Makefile; then
  bad "Makefile must define R1_EXTRA_CFLAGS_OBJS (wave753)"
elif ! grep -q 'R1_MISC_BASENAME_OBJS' compiler/Makefile; then
  bad "Makefile must define R1_MISC_BASENAME_OBJS (wave754)"
elif ! grep -q 'R1_SEED_MAP_OBJS' compiler/Makefile; then
  bad "Makefile must define R1_SEED_MAP_OBJS (wave755)"
elif ! grep -qE 'host-cc-seed|rt-seed-slice|core-seed|frontend-glue|main-runtime|alias-stubs|extra-cflags|misc-basename|seed-map' xlang-build.sh \
  || ! grep -q 'ensure_host_cc_seed_o\.sh' xlang-build.sh; then
  bad "xlang-build missing host-cc-seed / families (wave748–755)"
elif ! grep -qE 'wave748|R1.*rt.seed|ensure_host_cc_seed_o|RT_SEED_SLICE' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave748 R1 rt-seed-slice"
elif ! grep -qE 'wave749|R1_CORE_SEED|core-seed' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave749 R1 core-seed"
elif ! grep -qE 'wave750|R1_FRONTEND_GLUE|frontend-glue' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave750 R1 frontend-glue"
elif ! grep -qE 'wave751|R1_MAIN_RUNTIME|main-runtime' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave751 R1 main-runtime"
elif ! grep -qE 'wave752|R1_ALIAS_STUBS|alias-stubs' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave752 R1 alias-stubs"
elif ! grep -qE 'wave753|R1_EXTRA_CFLAGS|extra-cflags' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave753 R1 extra-cflags"
elif ! grep -qE 'wave754|R1_MISC_BASENAME|misc-basename' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave754 R1 misc-basename"
elif ! grep -qE 'wave755|R1_SEED_MAP|seed-map' compiler/docs/LEAF_PATTERN_RESIDUAL.md; then
  bad "LEAF_PATTERN_RESIDUAL.md must document wave755 R1 seed-map"
elif ! grep -qE 'wave748|R1 rt|ensure_host_cc_seed_o|RT_SEED_SLICE' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave748 R1 rt-slice"
elif ! grep -qE 'wave749|core-seed|R1_CORE_SEED' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave749 R1 core-seed"
elif ! grep -qE 'wave750|frontend-glue|R1_FRONTEND_GLUE' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave750 R1 frontend-glue"
elif ! grep -qE 'wave751|main-runtime|R1_MAIN_RUNTIME' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave751 R1 main-runtime"
elif ! grep -qE 'wave752|alias-stubs|R1_ALIAS_STUBS' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave752 R1 alias-stubs"
elif ! grep -qE 'wave753|extra-cflags|R1_EXTRA_CFLAGS' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave753 R1 extra-cflags"
elif ! grep -qE 'wave754|misc-basename|R1_MISC_BASENAME' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave754 R1 misc-basename"
elif ! grep -qE 'wave755|seed-map|R1_SEED_MAP' compiler/docs/BUILD_DAG.md; then
  bad "BUILD_DAG.md must cross-ref wave755 R1 seed-map"
elif ! grep -qE 'wave748|host-cc-seed|rt-seed-slice|RT_SEED_SLICE' build.x; then
  bad "build.x must mention wave748 / host-cc-seed / RT_SEED_SLICE"
elif ! grep -qE 'wave749|core-seed|R1_CORE_SEED' build.x; then
  bad "build.x must mention wave749 / core-seed / R1_CORE_SEED"
elif ! grep -qE 'wave750|frontend-glue|R1_FRONTEND_GLUE' build.x; then
  bad "build.x must mention wave750 / frontend-glue / R1_FRONTEND_GLUE"
elif ! grep -qE 'wave751|main-runtime|R1_MAIN_RUNTIME' build.x; then
  bad "build.x must mention wave751 / main-runtime / R1_MAIN_RUNTIME"
elif ! grep -qE 'wave752|alias-stubs|R1_ALIAS_STUBS' build.x; then
  bad "build.x must mention wave752 / alias-stubs / R1_ALIAS_STUBS"
elif ! grep -qE 'wave753|extra-cflags|R1_EXTRA_CFLAGS' build.x; then
  bad "build.x must mention wave753 / extra-cflags / R1_EXTRA_CFLAGS"
elif ! grep -qE 'wave754|misc-basename|R1_MISC_BASENAME' build.x; then
  bad "build.x must mention wave754 / misc-basename / R1_MISC_BASENAME"
elif ! grep -qE 'wave755|seed-map|R1_SEED_MAP' build.x; then
  bad "build.x must mention wave755 / seed-map / R1_SEED_MAP"
else
  note "BUILD_DAG + ensure_prereqs + product-dag + PLATFORM_LINKER + LEAF_PATTERN + R1 families (wave744–755)"
  if ! bash compiler/scripts/product_build_dag.sh --check; then
    bad "product_build_dag.sh --check failed (wave742–746)"
  else
    note "product_build_dag.sh --check OK (11.1.1+11.1.2+wave744+wave745)"
  fi
  # Positive dry-run path via xbuild (not only internal --check recursion).
  # Capture full stdout first: under set -o pipefail, `cmd | grep -q` can fail with
  # SIGPIPE when grep -q exits early (false FAIL).
  _dag_dry_out="$(./xbuild product-dag --dry-run product 2>/dev/null || true)"
  if ! printf '%s\n' "$_dag_dry_out" | grep -q 'NODE=g05_prepare_and_relink'; then
    bad "xbuild product-dag --dry-run product missing g05_prepare_and_relink (wave743)"
  else
    note "xbuild product-dag --dry-run product OK (wave743)"
  fi
  _cold_dry_out="$(./xbuild product-dag --dry-run cold 2>/dev/null || true)"
  if ! printf '%s\n' "$_cold_dry_out" | grep -q 'NODE=cold_ensure_prereqs'; then
    bad "xbuild product-dag --dry-run cold missing cold_ensure_prereqs (wave744)"
  elif ! printf '%s\n' "$_cold_dry_out" | grep -q 'PREREQ='; then
    bad "xbuild product-dag --dry-run cold missing PREREQ= expansion (wave744)"
  else
    note "xbuild product-dag --dry-run cold + PREREQ edges OK (wave744)"
  fi
  if ! ./xbuild driver-seed-prereqs --check >/tmp/xbuild_prereq_check.out 2>/tmp/xbuild_prereq_check.err; then
    bad "xbuild driver-seed-prereqs --check failed (wave744)"
  elif ! grep -q 'CHECK OK' /tmp/xbuild_prereq_check.out /tmp/xbuild_prereq_check.err; then
    bad "xbuild driver-seed-prereqs --check missing CHECK OK (wave744)"
  else
    note "xbuild driver-seed-prereqs --check OK (wave744)"
  fi
  if ! ./xbuild host-platform --check >/tmp/xbuild_host_platform_check.out 2>/tmp/xbuild_host_platform_check.err; then
    bad "xbuild host-platform --check failed (wave745)"
  elif ! grep -q 'CHECK OK' /tmp/xbuild_host_platform_check.out /tmp/xbuild_host_platform_check.err; then
    bad "xbuild host-platform --check missing CHECK OK (wave745)"
  else
    note "xbuild host-platform --check OK (wave745)"
  fi
  _plat_out="$(./xbuild host-platform 2>/dev/null || true)"
  if ! printf '%s\n' "$_plat_out" | grep -qE '^XLANG_HOST_OS=(linux|darwin|windows|unknown)$'; then
    bad "xbuild host-platform dump missing XLANG_HOST_OS (wave745)"
  else
    note "xbuild host-platform dump OK (wave745)"
  fi
  _link_out="$(./xbuild linker-policy 2>/dev/null || true)"
  if ! printf '%s\n' "$_link_out" | grep -q 'RESIDUAL_CC_LINK_SITE=scripts/bootstrap_driver_seed_link.sh'; then
    bad "xbuild linker-policy missing residual site (wave745)"
  else
    note "xbuild linker-policy inventory OK (wave745)"
  fi
  if ! ./xbuild leaf-patterns --check >/tmp/xbuild_leaf_patterns_check.out 2>/tmp/xbuild_leaf_patterns_check.err; then
    bad "xbuild leaf-patterns --check failed (wave754)"
  elif ! grep -q 'CHECK OK' /tmp/xbuild_leaf_patterns_check.out /tmp/xbuild_leaf_patterns_check.err; then
    bad "xbuild leaf-patterns --check missing CHECK OK (wave754)"
  else
    note "xbuild leaf-patterns --check OK (wave747 R4 + wave748–753 R1)"
  fi
  _leaf_out="$(./xbuild leaf-patterns 2>/dev/null || true)"
  if ! printf '%s\n' "$_leaf_out" | grep -q 'RESIDUAL_CLASS_R1=host_cc_seed_from_x_to_o'; then
    bad "xbuild leaf-patterns dump missing RESIDUAL_CLASS_R1"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R4_MODE_POLICY=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R4_MODE_POLICY=1 (wave747)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R4_PATTERN_BODY_STILL_MAKE=1'; then
    bad "xbuild leaf-patterns dump missing R4_PATTERN_BODY_STILL_MAKE=1"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_RT_SEED_SLICE=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_RT_SEED_SLICE=1 (wave748)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_RT_SEED_SLICE_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_RT_SEED_SLICE_SWALLOWED=1 (wave748)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_CORE_SEED=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_CORE_SEED=1 (wave749)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_CORE_SEED_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_CORE_SEED_SWALLOWED=1 (wave749)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_FRONTEND_GLUE=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_FRONTEND_GLUE=1 (wave750)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_FRONTEND_GLUE_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_FRONTEND_GLUE_SWALLOWED=1 (wave750)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_MAIN_RUNTIME=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_MAIN_RUNTIME=1 (wave751)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_MAIN_RUNTIME_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_MAIN_RUNTIME_SWALLOWED=1 (wave751)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_ALIAS_STUBS=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_ALIAS_STUBS=1 (wave752)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_ALIAS_STUBS_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_ALIAS_STUBS_SWALLOWED=1 (wave752)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_EXTRA_CFLAGS=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_EXTRA_CFLAGS=1 (wave753)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_EXTRA_CFLAGS_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_EXTRA_CFLAGS_SWALLOWED=1 (wave753)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_MISC_BASENAME=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_MISC_BASENAME=1 (wave754)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_MISC_BASENAME_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_MISC_BASENAME_SWALLOWED=1 (wave754)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'SWALLOWED_R1_SEED_MAP=1'; then
    bad "xbuild leaf-patterns dump missing SWALLOWED_R1_SEED_MAP=1 (wave755)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_SEED_MAP_SWALLOWED=1'; then
    bad "xbuild leaf-patterns dump missing R1_SEED_MAP_SWALLOWED=1 (wave755)"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'R1_OTHER_HOST_CC_STILL_MAKE=1'; then
    bad "xbuild leaf-patterns dump missing R1_OTHER_HOST_CC_STILL_MAKE=1"
  elif ! printf '%s\n' "$_leaf_out" | grep -q 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=0'; then
    bad "xbuild leaf-patterns dump missing ENDGAME_PHYSICAL_DELETE_MAKEFILE=0"
  else
    note "xbuild leaf-patterns inventory OK (wave747 R4 + wave748–755 R1 families)"
  fi
  if ! ./xbuild host-cc-seed --check >/tmp/xbuild_host_cc_seed_check.out 2>/tmp/xbuild_host_cc_seed_check.err; then
    bad "xbuild host-cc-seed --check failed (wave755)"
  elif ! grep -q 'CHECK OK' /tmp/xbuild_host_cc_seed_check.out /tmp/xbuild_host_cc_seed_check.err; then
    bad "xbuild host-cc-seed --check missing CHECK OK (wave755)"
  else
    note "xbuild host-cc-seed --check OK (wave748–755 R1 families)"
  fi
  if ! bash compiler/scripts/driver_seed_obj_catalog.sh --check >/tmp/xbuild_catalog_rt.out 2>/tmp/xbuild_catalog_rt.err; then
    bad "driver_seed_obj_catalog --check failed (wave748–755 R1 family keys)"
  else
    note "driver_seed_obj_catalog --check OK (includes RT_SEED_SLICE + R1_CORE_SEED + R1_FRONTEND_GLUE + R1_MAIN_RUNTIME + R1_ALIAS_STUBS + R1_EXTRA_CFLAGS + R1_MISC_BASENAME + R1_SEED_MAP)"
  fi
  unset _dag_dry_out _cold_dry_out _plat_out _link_out _leaf_out
fi

# Product daily `all` must remain g05 (not Makefile all); CI uses compiler-all.
if grep -n 'all|build|xlang)' xlang-build.sh | head -1 | grep -q . \
  && sed -n '/all|build|xlang)/,/^  [a-zA-Z*]/p' xlang-build.sh | head -8 | grep -q 'run_build_tool'; then
  note "product ./xbuild all still g05 (distinct from compiler-all)"
else
  bad "product all|build must stay run_build_tool (do not alias to Makefile all)"
fi

scan_outer_make_c() {
  # Executable-ish lines only: drop full-line comments and prose that only document the ban.
  grep -nE 'make[[:space:]]+-C[[:space:]]+compiler' "$@" 2>/dev/null \
    | grep -vE ':[0-9]+:[[:space:]]*#' \
    | grep -vE '0×|外层|wave730|must not|禁止|改为|G\.7' \
    || true
}

outer_hits=$(scan_outer_make_c .github/workflows/*.yml scripts/docker-ci-local.sh)
if [ -n "$outer_hits" ]; then
  bad "CI/docker still has outer make -C compiler (must use ./xbuild); wave730:"
  echo "$outer_hits" | head -30 >&2
else
  note "CI workflows + docker-ci-local: 0× outer make -C compiler (11.2.5 / 11.4.3)"
fi

# Positive: docker + main workflows must invoke ./xbuild compiler-all / bootstrap paths
if grep -q '\./xbuild compiler-all' .github/workflows/ci.yml \
  && grep -q '\./xbuild bootstrap-driver-seed' .github/workflows/ci.yml \
  && grep -q '\./xbuild compiler-all' scripts/docker-ci-local.sh \
  && grep -q '\./xbuild bootstrap-driver-seed' scripts/docker-ci-local.sh; then
  note "ci.yml + docker-ci call ./xbuild compiler-all / bootstrap-driver-seed"
else
  bad "ci.yml or docker-ci missing ./xbuild compiler-all / bootstrap-driver-seed (wave730)"
fi

if grep -q '\./xbuild compiler-all' .github/workflows/ci-nightly.yml \
  && grep -q '\./xbuild compiler-all' .github/workflows/selfhost-stage2.yml \
  && grep -q '\./xbuild bootstrap-driver-seed' .github/workflows/release.yml; then
  note "nightly / selfhost-stage2 / release use ./xbuild entry"
else
  bad "nightly/selfhost/release missing ./xbuild migration (wave730)"
fi

echo "=== gate summary ==="
if [ "$fail" -ne 0 ]; then
  echo "FAIL product-path 0-make static gate" >&2
  exit 1
fi
echo "OK product-path 0-make static gate (allowlist frozen; class-G + bootstrap + test* shell; xlang-build 0-make; PATH probe; mk OBJS+composites; catalog --check; tests/lib+run-*.sh hub; root help→xbuild; CI/docker → xbuild; build.sh thin; docker/delete-one entry; 11.5 HOST_CC_POLICY; 11.1.1–4 BUILD_DAG + PLATFORM_LINKER; 11.3.1 LEAF_PATTERN + R4 mode wave747 + R1 rt-slice wave748 + R1 core-seed wave749 + R1 frontend-glue wave750 + R1 main-runtime wave751 + R1 alias-stubs wave752 + R1 extra-cflags wave753 + R1 misc-basename wave754 + R1 seed-map wave755)"
exit 0
