#!/usr/bin/env bash
# product_build_dag.sh — 11.1.1 inventory + 11.1.2 schedule execute (wave742/743)
#
# Authority (G.7):
#   Single machine-checkable view of *orchestration* nodes for product daily
#   path and cold-start bootstrap-driver-seed. Does NOT own or hardcode .o
#   inventories (those live in compiler/mk/*.mk + driver_seed_obj_catalog.sh).
#
#   Human map: compiler/docs/BUILD_DAG.md
#   Policy facade: root build.x
#   Execution (11.1.2): this script dry-run/run invokes *existing* body scripts
#   only — no second compile/link implementation, no dual .o lists.
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/product_build_dag.sh              # dump inventory
#   bash compiler/scripts/product_build_dag.sh dump
#   bash compiler/scripts/product_build_dag.sh --check
#   bash compiler/scripts/product_build_dag.sh --dry-run [product|refresh|cold]
#   bash compiler/scripts/product_build_dag.sh --run product   # execute product schedule
#   bash compiler/scripts/product_build_dag.sh --run refresh
#   bash compiler/scripts/product_build_dag.sh --run cold      # residual: outer bootstrap
#   ./xbuild product-dag | build-dag | cold-dag
#   ./xbuild product-dag --check | --dry-run | --run product
#
# PLATFORM: SHARED — paths relative to repo root; bodies carry platform ABI.
# Wave: 742 inventory · 743 schedule execute slice (not full .x import graph).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
# scripts/ → compiler/ → repo root
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"

MODE="${1:-dump}"
PROFILE="${2:-product}"
case "$MODE" in
  --check|check|-c) MODE=check ;;
  dump|list|"") MODE=dump ;;
  --dry-run|dry-run|dryrun) MODE=dry-run ;;
  --run|run|execute) MODE=run ;;
  help|-h|--help)
    sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "product_build_dag: unknown mode '$MODE' (use dump|check|dry-run|run)" >&2
    exit 2
    ;;
esac

# ---------------------------------------------------------------------------
# Product daily orchestration nodes (inventory · wave742).
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

# ---------------------------------------------------------------------------
# 11.1.2 schedules (ordered node ids · wave743)
#
# product: gen ensure → migrate → g05 prepare (prepare embeds ensure+link_env).
#   Skip archaeology (Track L, off product link).
#   Skip standalone g05_ensure / g05_link_env (embedded in prepare — G.7 no double).
# refresh: single P0 gate body (migrate + g05 + overlay).
# cold: inventory order for dry-run; live run uses residual outer bootstrap
#   (DRIVER_SEED_PREREQS still Makefile → 11.3).
# ---------------------------------------------------------------------------
PRODUCT_SCHEDULE=(
  ensure_migrate_gen
  ensure_driver_gen
  ensure_lsp_pipeline_gen
  migrate_x_objs
  g05_prepare_and_relink
)

REFRESH_SCHEDULE=(
  refresh_gate
)

COLD_SCHEDULE=(
  cold_check_i64_abi
  cold_pipeline_x
  cold_sat
  cold_lsp
  cold_bridge
  cold_user_asm
  cold_asm_glue
  cold_asm_host
  cold_host_stubs
  cold_phase1_link
  cold_final_link
  cold_panic
  cold_orchestrator
)

DOC_REL="compiler/docs/BUILD_DAG.md"
CATALOG_REL="compiler/scripts/driver_seed_obj_catalog.sh"
XBUILD_REL="xlang-build.sh"

fail=0
note() { echo "product_build_dag: $*" >&2; }
bad() { echo "product_build_dag: FAIL: $*" >&2; fail=1; }

lookup_product_body() {
  local want="$1" ent id xt body
  for ent in "${PRODUCT_NODES[@]}"; do
    IFS='|' read -r id xt body <<<"$ent"
    if [ "$id" = "$want" ]; then
      echo "$body"
      return 0
    fi
  done
  return 1
}

lookup_cold_body() {
  local want="$1" ent id leaf body
  for ent in "${COLD_NODES[@]}"; do
    IFS='|' read -r id leaf body <<<"$ent"
    if [ "$id" = "$want" ]; then
      echo "$body"
      return 0
    fi
  done
  return 1
}

dump_product() {
  echo "# product_daily (11.1.1 inventory · 11.1.2 schedules wave743)"
  local i=0 ent id xt body
  for ent in "${PRODUCT_NODES[@]}"; do
    IFS='|' read -r id xt body <<<"$ent"
    printf 'PRODUCT_ORDER=%d NODE=%s XBUILD=%s BODY=%s\n' "$i" "$id" "$xt" "$body"
    i=$((i + 1))
  done
  echo "PRODUCT_ENTRY=all|build|xlang BODY=build_tool→g05_build_xlang_asm.sh"
  echo "CI_ENTRY=compiler-all BODY=tests/lib/compiler-make.sh→Makefile all"
  echo "# schedule product (11.1.2)"
  i=0
  for id in "${PRODUCT_SCHEDULE[@]}"; do
    body="$(lookup_product_body "$id" || true)"
    printf 'PRODUCT_SCHEDULE=%d NODE=%s BODY=%s\n' "$i" "$id" "${body:-?}"
    i=$((i + 1))
  done
  echo "# schedule refresh (11.1.2)"
  i=0
  for id in "${REFRESH_SCHEDULE[@]}"; do
    body="$(lookup_product_body "$id" || true)"
    printf 'REFRESH_SCHEDULE=%d NODE=%s BODY=%s\n' "$i" "$id" "${body:-?}"
    i=$((i + 1))
  done
}

dump_cold() {
  echo "# cold_bootstrap_driver_seed (11.1.1 inventory · 11.1.2 schedule wave743)"
  echo "COLD_PREREQ_GRAPH=Makefile DRIVER_SEED_PREREQS (lists: compiler/mk/*.mk)"
  local i=0 ent id leaf body
  for ent in "${COLD_NODES[@]}"; do
    IFS='|' read -r id leaf body <<<"$ent"
    printf 'COLD_ORDER=%d NODE=%s LEAF=%s BODY=%s\n' "$i" "$id" "$leaf" "$body"
    i=$((i + 1))
  done
  echo "COLD_OUTER=./xbuild bootstrap-driver-seed"
  echo "COLD_OBJ_CATALOG=$CATALOG_REL"
  echo "# schedule cold (11.1.2 dry-run; live run residual make graph → 11.3)"
  i=0
  for id in "${COLD_SCHEDULE[@]}"; do
    body="$(lookup_cold_body "$id" || true)"
    printf 'COLD_SCHEDULE=%d NODE=%s BODY=%s\n' "$i" "$id" "${body:-?}"
    i=$((i + 1))
  done
}

# Resolve schedule profile → bash array name of node ids.
resolve_schedule() {
  case "$1" in
    product|daily|product-daily|"") echo product ;;
    refresh|gate|refresh-gate) echo refresh ;;
    cold|bootstrap|cold-start) echo cold ;;
    *)
      echo "product_build_dag: unknown schedule profile '$1' (product|refresh|cold)" >&2
      return 2
      ;;
  esac
}

# Print or execute one schedule. $1 = product|refresh|cold ; $2 = dry-run|run
schedule_walk() {
  local profile="$1" action="$2"
  local -a ids=()
  local id body step=0

  case "$profile" in
    product) ids=("${PRODUCT_SCHEDULE[@]}") ;;
    refresh) ids=("${REFRESH_SCHEDULE[@]}") ;;
    cold) ids=("${COLD_SCHEDULE[@]}") ;;
    *)
      note "unknown profile $profile"
      return 2
      ;;
  esac

  echo "# schedule=$profile action=$action (11.1.2 wave743)"
  for id in "${ids[@]}"; do
    if [ "$profile" = cold ]; then
      body="$(lookup_cold_body "$id" || true)"
    else
      body="$(lookup_product_body "$id" || true)"
    fi
    if [ -z "${body:-}" ]; then
      echo "product_build_dag: FAIL: schedule node $id missing from inventory" >&2
      return 1
    fi
    printf 'STEP=%d NODE=%s BODY=compiler/%s\n' "$step" "$id" "$body"
    if [ "$action" = run ]; then
      if [ "$profile" = cold ]; then
        # Cold live path still needs Makefile DRIVER_SEED_PREREQS until 11.3.
        # Single outer authority: bootstrap-driver-seed (do not re-implement leaves).
        if [ "$step" -eq 0 ]; then
          note "cold run residual: DRIVER_SEED_PREREQS still Makefile (→ 11.3)"
          note "invoking outer ./xbuild bootstrap-driver-seed (G.7 single orchestrator)"
          if [ ! -x "$ROOT/xbuild" ] && [ ! -f "$ROOT/xbuild" ]; then
            echo "product_build_dag: missing $ROOT/xbuild" >&2
            return 1
          fi
          (cd "$ROOT" && bash ./xbuild bootstrap-driver-seed)
          note "cold outer bootstrap-driver-seed finished (remaining cold STEPs are inventory order only)"
          # Outer already ran full cold chain; do not re-run each leaf body.
          return 0
        fi
      else
        if [ ! -f "$COMPILER_DIR/$body" ]; then
          echo "product_build_dag: missing body $COMPILER_DIR/$body" >&2
          return 1
        fi
        note "run STEP=$step NODE=$id → (cd compiler && bash $body)"
        (cd "$COMPILER_DIR" && bash "$body")
      fi
    fi
    step=$((step + 1))
  done
  if [ "$action" = dry-run ]; then
    echo "product_build_dag: DRY-RUN OK schedule=$profile steps=$step"
  else
    echo "product_build_dag: RUN OK schedule=$profile steps=$step"
  fi
}

if [ "$MODE" = dump ]; then
  dump_product
  echo
  dump_cold
  exit 0
fi

if [ "$MODE" = dry-run ] || [ "$MODE" = run ]; then
  _prof="$(resolve_schedule "$PROFILE")" || exit 2
  schedule_walk "$_prof" "$MODE"
  exit $?
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
  # 11.1.2 schedule execute must be documented
  if ! grep -q '11\.1\.2' "$DOC_REL" || ! grep -qiE 'dry-run|schedule|--run' "$DOC_REL"; then
    bad "$DOC_REL must document 11.1.2 schedule dry-run/run (wave743)"
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
  hits=$(grep -nE '[a-zA-Z0-9_./-]+\.o' "$SCRIPT_DIR/product_build_dag.sh" \
    | grep -vE '^\s*#|[Dd]o not|inventor|hardcode|catalog|\.mk|lists|dual' || true)
  if [ -n "$hits" ]; then
    bad "product_build_dag.sh must not hardcode .o paths (G.7 dual list ban):"
    echo "$hits" | head -10 >&2
  fi
fi

# build.x must point at 11.1.1 / 11.1.2 / BUILD_DAG
if [ -f build.x ]; then
  if grep -qE '11\.1\.1|BUILD_DAG|product.dag|DAG-as-data' build.x; then
    note "build.x references 11.1.1 / BUILD_DAG"
  else
    bad "build.x must mention 11.1.1 / BUILD_DAG / product-dag (wave742)"
  fi
  if ! grep -qE '11\.1\.2|dry-run|--run|schedule' build.x; then
    bad "build.x must mention 11.1.2 schedule / dry-run / --run (wave743)"
  fi
else
  bad "missing root build.x"
fi

# xbuild first-class product-dag target + 11.1.2 modes
if grep -qE 'product-dag|build-dag|cold-dag' "$XBUILD_REL" \
  && grep -q 'product_build_dag\.sh' "$XBUILD_REL"; then
  note "xbuild product-dag wired"
else
  bad "xlang-build.sh must wire product-dag → product_build_dag.sh (wave742)"
fi
if ! grep -qE 'dry-run|--run|dryrun' "$XBUILD_REL"; then
  bad "xlang-build.sh must wire product-dag --dry-run / --run (wave743 11.1.2)"
fi

# Schedule integrity: every schedule id must exist in inventory + body file
for id in "${PRODUCT_SCHEDULE[@]}" "${REFRESH_SCHEDULE[@]}"; do
  body="$(lookup_product_body "$id" || true)"
  if [ -z "${body:-}" ]; then
    bad "schedule node $id not in PRODUCT_NODES inventory"
  elif [ ! -f "compiler/$body" ]; then
    bad "schedule node $id body missing compiler/$body"
  fi
done
for id in "${COLD_SCHEDULE[@]}"; do
  body="$(lookup_cold_body "$id" || true)"
  if [ -z "${body:-}" ]; then
    bad "cold schedule node $id not in COLD_NODES inventory"
  elif [ ! -f "compiler/$body" ]; then
    bad "cold schedule node $id body missing compiler/$body"
  fi
done
note "schedule ids resolve to inventory bodies"

# Live dry-run must succeed for all three profiles (no host-cc, no rebuild)
for _p in product refresh cold; do
  if ! bash "$SCRIPT_DIR/product_build_dag.sh" dry-run "$_p" >/tmp/product_build_dag_dry_${_p}.out 2>/tmp/product_build_dag_dry_${_p}.err; then
    bad "dry-run $_p failed"
    head -20 /tmp/product_build_dag_dry_${_p}.err >&2 || true
  else
    if ! grep -q "DRY-RUN OK schedule=$_p" /tmp/product_build_dag_dry_${_p}.out; then
      bad "dry-run $_p missing DRY-RUN OK banner"
    fi
    # product schedule must list g05_prepare and must NOT list archaeology
    if [ "$_p" = product ]; then
      if ! grep -q 'NODE=g05_prepare_and_relink' /tmp/product_build_dag_dry_${_p}.out; then
        bad "product dry-run must include g05_prepare_and_relink"
      fi
      if grep -q 'NODE=ensure_archaeology_gen' /tmp/product_build_dag_dry_${_p}.out; then
        bad "product schedule must not include archaeology (Track L off product)"
      fi
      # Standalone ensure/link_env are inventory nodes only; prepare embeds them (G.7).
      if grep -qE 'NODE=g05_ensure([[:space:]]|$)|NODE=g05_link_env([[:space:]]|$)' \
        /tmp/product_build_dag_dry_${_p}.out; then
        bad "product schedule must not double-run g05_ensure/link_env (embedded in prepare)"
      fi
    fi
    note "dry-run $_p OK"
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "product_build_dag: CHECK FAIL" >&2
  exit 1
fi
echo "product_build_dag: CHECK OK (11.1.1 inventory + 11.1.2 schedule execute wave743)"
exit 0
