#!/usr/bin/env bash
# product_build_dag.sh — 11.1.1 orchestration DAG dump + check (wave742)
#
# Authority (G.7):
#   Single machine-checkable view of *orchestration* nodes for product daily
#   path and cold-start bootstrap-driver-seed. Does NOT own or hardcode .o
#   inventories (those live in compiler/mk/*.mk + driver_seed_obj_catalog.sh).
#
#   Human map: compiler/docs/BUILD_DAG.md
#   Policy facade: root build.x
#   Execution: ./xbuild → shells / residual Makefile graph until 11.3
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/product_build_dag.sh              # dump
#   bash compiler/scripts/product_build_dag.sh dump
#   bash compiler/scripts/product_build_dag.sh --check
#   bash compiler/scripts/product_build_dag.sh check
#   ./xbuild product-dag | build-dag | cold-dag
#   ./xbuild product-dag --check
#
# PLATFORM: SHARED — paths relative to repo root; no host-cc.
# Wave: 742 Track MG · 11.1.1 inventory slice (not full scheduler).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
# scripts/ → compiler/ → repo root
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"

MODE="${1:-dump}"
case "$MODE" in
  --check|check|-c) MODE=check ;;
  dump|list|"") MODE=dump ;;
  help|-h|--help)
    sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "product_build_dag: unknown mode '$MODE' (use dump|check)" >&2
    exit 2
    ;;
esac

# ---------------------------------------------------------------------------
# Product daily orchestration nodes (order = recommended / documented edge order).
# Fields: id|xbuild_target|body_relpath_from_compiler
# body path empty means multi-body or hub-only (validated separately).
# ---------------------------------------------------------------------------
PRODUCT_NODES=(
  "ensure_migrate_gen|migrate-gen|scripts/ensure_migrate_gen.sh"
  "ensure_driver_gen|driver-gen|scripts/ensure_driver_gen.sh"
  "ensure_lsp_pipeline_gen|lsp-pipeline-gen|scripts/ensure_lsp_pipeline_gen.sh"
  "ensure_archaeology_gen|archaeology-gen|scripts/ensure_archaeology_gen.sh"
  "migrate_x_objs|migrate|scripts/migrate_x_objs.sh"
  "g05_ensure|ensure|scripts/g05_ensure_relink_prereqs.sh"
  "g05_link_env|link-env|scripts/g05_relink_env.sh"
  "g05_prepare_and_relink|link-product|scripts/g05_prepare_and_relink.sh"
  "refresh_gate|refresh-gate|scripts/refresh_xlang_asm_gate.sh"
)

# Cold-start shell orchestration after Makefile DRIVER_SEED_PREREQS.
# id|make_or_shell_leaf|body (compiler-relative; "-" = pure make leaf export)
COLD_NODES=(
  "cold_check_i64_abi|check-pipeline-gen-expr-i64-abi|scripts/check_pipeline_gen_expr_i64_abi.sh"
  "cold_pipeline_x|bootstrap-driver-seed-pipeline-x|scripts/bootstrap_driver_seed_rebuild_leaves.sh"
  "cold_sat|bootstrap-driver-seed-sat-rebuild|scripts/bootstrap_driver_seed_rebuild_leaves.sh"
  "cold_lsp|bootstrap-driver-seed-lsp-x-objs|scripts/bootstrap_driver_seed_rebuild_leaves.sh"
  "cold_bridge|bootstrap-driver-seed-bridge|scripts/bootstrap_driver_seed_rebuild_leaves.sh"
  "cold_user_asm|bootstrap-driver-seed-user-asm-seed-objs|scripts/bootstrap_driver_seed_rebuild_leaves.sh"
  "cold_asm_glue|bootstrap-driver-seed-asm-glue-standalone|scripts/bootstrap_driver_seed_rebuild_leaves.sh"
  "cold_asm_host|bootstrap-driver-seed-asm-host|scripts/build_seed_asm_host.sh"
  "cold_host_stubs|bootstrap-driver-seed-host-stubs|scripts/bootstrap_driver_seed_host_stubs.sh"
  "cold_phase1_link|bootstrap-driver-seed-phase1-link|scripts/bootstrap_driver_seed_link.sh"
  "cold_final_link|bootstrap-driver-seed-final-link|scripts/bootstrap_driver_seed_link.sh"
  "cold_panic|bootstrap-driver-seed-panic|scripts/bootstrap_driver_seed_rebuild_leaves.sh"
  "cold_orchestrator|bootstrap-driver-seed|scripts/bootstrap_driver_seed.sh"
)

DOC_REL="compiler/docs/BUILD_DAG.md"
CATALOG_REL="compiler/scripts/driver_seed_obj_catalog.sh"
XBUILD_REL="xlang-build.sh"

fail=0
note() { echo "product_build_dag: $*" >&2; }
bad() { echo "product_build_dag: FAIL: $*" >&2; fail=1; }

dump_product() {
  echo "# product_daily (11.1.1 wave742)"
  local i=0 ent id xt body
  for ent in "${PRODUCT_NODES[@]}"; do
    IFS='|' read -r id xt body <<<"$ent"
    printf 'PRODUCT_ORDER=%d NODE=%s XBUILD=%s BODY=%s\n' "$i" "$id" "$xt" "$body"
    i=$((i + 1))
  done
  echo "PRODUCT_ENTRY=all|build|xlang BODY=build_tool→g05_build_xlang_asm.sh"
  echo "CI_ENTRY=compiler-all BODY=tests/lib/compiler-make.sh→Makefile all"
}

dump_cold() {
  echo "# cold_bootstrap_driver_seed (11.1.1 wave742)"
  echo "COLD_PREREQ_GRAPH=Makefile DRIVER_SEED_PREREQS (lists: compiler/mk/*.mk)"
  local i=0 ent id leaf body
  for ent in "${COLD_NODES[@]}"; do
    IFS='|' read -r id leaf body <<<"$ent"
    printf 'COLD_ORDER=%d NODE=%s LEAF=%s BODY=%s\n' "$i" "$id" "$leaf" "$body"
    i=$((i + 1))
  done
  echo "COLD_OUTER=./xbuild bootstrap-driver-seed"
  echo "COLD_OBJ_CATALOG=$CATALOG_REL"
}

if [ "$MODE" = "dump" ]; then
  dump_product
  echo
  dump_cold
  exit 0
fi

# ---- check mode ----
cd "$ROOT"

if [ ! -f "$DOC_REL" ]; then
  bad "missing $DOC_REL (11.1.1 authority map)"
else
  if ! grep -q '11\.1\.1' "$DOC_REL" || ! grep -qi 'product daily' "$DOC_REL"; then
    bad "$DOC_REL must document 11.1.1 product daily path"
  fi
  if ! grep -q 'bootstrap-driver-seed' "$DOC_REL" || ! grep -q 'DRIVER_SEED_PREREQS' "$DOC_REL"; then
    bad "$DOC_REL must document cold-start DRIVER_SEED_PREREQS residual"
  fi
  # G.7: doc must ban a second .o inventory (orchestration only)
  if ! grep -qi 'duplicate.*\.o\|\.o invent\|hardcode.*\.o\|Do not.*\.o' "$DOC_REL"; then
    bad "$DOC_REL must ban dual .o inventories (G.7)"
  fi
  note "doc $DOC_REL present"
fi

if [ ! -f "$XBUILD_REL" ]; then
  bad "missing $XBUILD_REL"
fi

for ent in "${PRODUCT_NODES[@]}"; do
  IFS='|' read -r id xt body <<<"$ent"
  if [ ! -f "compiler/$body" ]; then
    bad "missing product body compiler/$body (node $id)"
  fi
  if ! grep -qE "(^|[[:space:]|])${xt}(\||[[:space:]]|\\)|$)" "$XBUILD_REL" \
    && ! grep -q "${xt}" "$XBUILD_REL"; then
    bad "xlang-build.sh missing xbuild target for product node $id ($xt)"
  fi
done
note "product node bodies + xbuild targets present"

for ent in "${COLD_NODES[@]}"; do
  IFS='|' read -r id leaf body <<<"$ent"
  if [ ! -f "compiler/$body" ]; then
    bad "missing cold body compiler/$body (node $id)"
  fi
done
if ! grep -q 'bootstrap-driver-seed)' "$XBUILD_REL" \
  && ! grep -q 'bootstrap-driver-seed' "$XBUILD_REL"; then
  bad "xlang-build.sh missing bootstrap-driver-seed target"
fi
if ! grep -q 'bootstrap_driver_seed\.sh' "compiler/scripts/bootstrap_driver_seed.sh" \
  && [ ! -f compiler/scripts/bootstrap_driver_seed.sh ]; then
  bad "missing cold orchestrator bootstrap_driver_seed.sh"
fi
note "cold node bodies present"

if [ ! -f "$CATALOG_REL" ]; then
  bad "missing $CATALOG_REL (obj lists authority companion)"
else
  note "obj catalog companion present (lists ≠ edges)"
fi

# G.7: this script must not hardcode .o inventories
if grep -nE '\.o[[:space:]]|\.o"' "$SCRIPT_DIR/product_build_dag.sh" \
  | grep -vE '^\s*#|inventor|\.o invent|dual \.o|not.*\.o|lists|\.mk|catalog|hardcode' \
  | grep -qE '[a-zA-Z0-9_/]+\.o'; then
  # Soft: only fail if we see path-like .o tokens outside comments
  hits=$(grep -nE '[a-zA-Z0-9_./-]+\.o' "$SCRIPT_DIR/product_build_dag.sh" \
    | grep -vE '^\s*#|[Dd]o not|inventor|hardcode|catalog|\.mk|lists|dual' || true)
  if [ -n "$hits" ]; then
    bad "product_build_dag.sh must not hardcode .o paths (G.7 dual list ban):"
    echo "$hits" | head -10 >&2
  fi
fi

# build.x must point at 11.1.1 / BUILD_DAG
if [ -f build.x ]; then
  if grep -qE '11\.1\.1|BUILD_DAG|product.dag|DAG-as-data' build.x; then
    note "build.x references 11.1.1 / BUILD_DAG"
  else
    bad "build.x must mention 11.1.1 / BUILD_DAG / product-dag (wave742)"
  fi
else
  bad "missing root build.x"
fi

# xbuild first-class product-dag target
if grep -qE 'product-dag|build-dag|cold-dag' "$XBUILD_REL" \
  && grep -q 'product_build_dag\.sh' "$XBUILD_REL"; then
  note "xbuild product-dag wired"
else
  bad "xlang-build.sh must wire product-dag → product_build_dag.sh (wave742)"
fi

if [ "$fail" -ne 0 ]; then
  echo "product_build_dag: CHECK FAIL" >&2
  exit 1
fi
echo "product_build_dag: CHECK OK (11.1.1 wave742 orchestration inventory)"
exit 0
