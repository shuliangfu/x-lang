#!/usr/bin/env bash
# product_build_dag.sh — 11.1.1 inventory + 11.1.2 schedule + 11.3 prereq edges
#                       + 11.1.3/4 platform/linker cross-check (wave742–745)
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
#   wave744: cold prereq *edges* → driver_seed_ensure_prereqs.sh (catalog).
#   wave745: host platform + linker policy → host_platform_linker.sh
#            (PLATFORM_LINKER.md); this script only cross-checks presence.
#   wave746: leaf pattern residual inventory → leaf_pattern_residual.sh
#            (LEAF_PATTERN_RESIDUAL.md); cross-check presence only.
#   wave747: R4 mode-policy swallow in rebuild_leaves (catalog default);
#            residual dump flags SWALLOWED_R4_MODE_POLICY=1.
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/product_build_dag.sh              # dump inventory
#   bash compiler/scripts/product_build_dag.sh dump
#   bash compiler/scripts/product_build_dag.sh --check
#   bash compiler/scripts/product_build_dag.sh --dry-run [product|refresh|cold]
#   bash compiler/scripts/product_build_dag.sh --run product   # execute product schedule
#   bash compiler/scripts/product_build_dag.sh --run refresh
#   bash compiler/scripts/product_build_dag.sh --run cold      # outer bootstrap (shell prereqs)
#   ./xbuild product-dag | build-dag | cold-dag
#   ./xbuild product-dag --check | --dry-run | --run product
#
# PLATFORM: SHARED — paths relative to repo root; bodies carry platform ABI.
# Wave: 742 inventory · 743 schedule · 744 DRIVER_SEED_PREREQS · 745 platform/linker.

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

# Cold-start shell orchestration (wave744: prereq edges first via catalog ensure).
# id|make_or_shell_leaf|body (compiler-relative; "-" = pure make leaf export)
COLD_NODES=(
  "cold_ensure_prereqs|driver-seed-prereqs|scripts/driver_seed_ensure_prereqs.sh"
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
# cold: dry-run prints inventory order (ensure_prereqs first · wave744);
#   live run = outer bootstrap-driver-seed (shell ensure + §5b sequence).
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
  cold_ensure_prereqs
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
XCODE_REL="xlang-build.sh"

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
    printf 'PRODUCT_ORDER=%d NODE=%s XCODE=%s BODY=%s\n' "$i" "$id" "$xt" "$body"
    i=$((i + 1))
  done
  echo "PRODUCT_ENTRY=all|build|xlang BODY=build_tool→g05_build_xlang_asm.sh"
  echo "CI_ENTRY=compiler-all BODY=scripts/compiler_all_ci.sh→make_xlang_xlang_c_B7_wave785_inventory"
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
  echo "# cold_bootstrap_driver_seed (11.1.1 inventory · 11.1.2 schedule · 11.3 prereq wave744)"
  echo "COLD_PREREQ_EDGES=scripts/driver_seed_ensure_prereqs.sh (lists: compiler/mk/*.mk via catalog)"
  echo "COLD_PREREQ_GRAPH=shell ensure (Makefile thin phony; leaf pattern rules residual → 11.3 endgame)"
  local i=0 ent id leaf body
  for ent in "${COLD_NODES[@]}"; do
    IFS='|' read -r id leaf body <<<"$ent"
    printf 'COLD_ORDER=%d NODE=%s LEAF=%s BODY=%s\n' "$i" "$id" "$leaf" "$body"
    i=$((i + 1))
  done
  echo "COLD_OUTER=./xbuild bootstrap-driver-seed"
  echo "COLD_OBJ_CATALOG=$CATALOG_REL"
  echo "# schedule cold (11.1.2 dry-run; live = outer bootstrap embeds ensure_prereqs)"
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

  echo "# schedule=$profile action=$action (11.1.2 wave743 · prereq edges wave744)"
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
    # cold dry-run: expand prereq edges at STEP 0 (catalog; no rebuild)
    if [ "$profile" = cold ] && [ "$action" = dry-run ] && [ "$id" = cold_ensure_prereqs ]; then
      if [ -f "$COMPILER_DIR/scripts/driver_seed_ensure_prereqs.sh" ]; then
        (cd "$COMPILER_DIR" && bash scripts/driver_seed_ensure_prereqs.sh --dry-run) \
          || note "ensure_prereqs dry-run non-fatal noise (catalog still required at --check)"
      fi
    fi
    if [ "$action" = run ]; then
      if [ "$profile" = cold ]; then
        # Single outer authority: bootstrap-driver-seed (embeds ensure_prereqs · wave744).
        if [ "$step" -eq 0 ]; then
          note "cold run: prereq edges via shell ensure inside bootstrap_driver_seed (wave744)"
          note "invoking outer ./xbuild bootstrap-driver-seed (G.7 single orchestrator)"
          if [ ! -x "$ROOT/xcode" ] && [ ! -f "$ROOT/xcode" ]; then
            echo "product_build_dag: missing $ROOT/xcode" >&2
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
    bad "$DOC_REL must document cold-start DRIVER_SEED_PREREQS"
  fi
  # G.7: doc must ban a second .o inventory (orchestration only)
  if ! grep -qi 'duplicate.*\.o\|\.o invent\|hardcode.*\.o\|Do not.*\.o' "$DOC_REL"; then
    bad "$DOC_REL must ban dual .o inventories (G.7)"
  fi
  # 11.1.2 schedule execute must be documented
  if ! grep -q '11\.1\.2' "$DOC_REL" || ! grep -qiE 'dry-run|schedule|--run' "$DOC_REL"; then
    bad "$DOC_REL must document 11.1.2 schedule dry-run/run (wave743)"
  fi
  # wave744: prereq edge swallow must be documented
  if ! grep -qE 'driver_seed_ensure_prereqs|ensure_prereqs|wave744|11\.3.*prereq|prereq.*shell' "$DOC_REL"; then
    bad "$DOC_REL must document wave744 DRIVER_SEED_PREREQS shell ensure"
  fi
  note "doc $DOC_REL present"
fi

if [ ! -f "$XCODE_REL" ]; then
  bad "missing $XCODE_REL"
fi

for ent in "${PRODUCT_NODES[@]}"; do
  IFS='|' read -r id xt body <<<"$ent"
  if [ ! -f "compiler/$body" ]; then
    bad "missing product body compiler/$body (node $id)"
  fi
  if ! grep -qE "(^|[[:space:]|])${xt}(\||[[:space:]]|\\)|$)" "$XCODE_REL" \
    && ! grep -q "${xt}" "$XCODE_REL"; then
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
if ! grep -q 'bootstrap-driver-seed)' "$XCODE_REL" \
  && ! grep -q 'bootstrap-driver-seed' "$XCODE_REL"; then
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

# wave744: shell owns prereq *edge satisfaction* (list still catalog)
if [ ! -f compiler/scripts/driver_seed_ensure_prereqs.sh ]; then
  bad "missing compiler/scripts/driver_seed_ensure_prereqs.sh (wave744 11.3 prereq edges)"
elif ! grep -q 'driver_seed_ensure_prereqs' compiler/scripts/bootstrap_driver_seed.sh; then
  bad "bootstrap_driver_seed.sh must call driver_seed_ensure_prereqs (wave744)"
elif [ -f compiler/Makefile ] \
  && grep -nE '^bootstrap-driver-seed:.*DRIVER_SEED_PREREQS' compiler/Makefile \
  | grep -vE '^[0-9]+:[[:space:]]*#' | grep -q .; then
  bad "Makefile must not use DRIVER_SEED_PREREQS as make-graph deps (wave744 shell ensure)"
else
  # wave946 post_ship: Makefile already absent — skip make-graph anti-pattern grep.
  if [ ! -f compiler/Makefile ]; then
    note "Makefile absent (wave946 post_ship): skip DRIVER_SEED_PREREQS make-graph check"
  fi
  if ! bash compiler/scripts/driver_seed_ensure_prereqs.sh --check >/tmp/driver_seed_ensure_prereqs_check.out 2>/tmp/driver_seed_ensure_prereqs_check.err; then
    bad "driver_seed_ensure_prereqs.sh --check failed"
    head -20 /tmp/driver_seed_ensure_prereqs_check.err >&2 || true
  else
    if ! grep -q 'CHECK OK' /tmp/driver_seed_ensure_prereqs_check.out \
      && ! grep -q 'CHECK OK' /tmp/driver_seed_ensure_prereqs_check.err; then
      bad "driver_seed_ensure_prereqs --check missing CHECK OK banner"
    else
      note "driver_seed_ensure_prereqs --check OK (wave744 prereq edges)"
    fi
  fi
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
  if ! grep -qE 'ensure_prereqs|driver_seed_ensure_prereqs|DRIVER_SEED_PREREQS.*shell|wave744|11\.3' build.x; then
    bad "build.x must mention wave744 prereq shell ensure / 11.3 residual"
  fi
  if ! grep -qE '11\.1\.3|host.platform|PLATFORM_LINKER' build.x; then
    bad "build.x must mention 11.1.3 / host platform / PLATFORM_LINKER (wave745)"
  fi
  if ! grep -qE '11\.1\.4|linker.policy|SEED_LINK_CC|direct.*ld' build.x; then
    bad "build.x must mention 11.1.4 / linker policy (wave745)"
  fi
else
  bad "missing root build.x"
fi

# xbuild first-class product-dag target + 11.1.2 modes
if grep -qE 'product-dag|build-dag|cold-dag' "$XCODE_REL" \
  && grep -q 'product_build_dag\.sh' "$XCODE_REL"; then
  note "xbuild product-dag wired"
else
  bad "xlang-build.sh must wire product-dag → product_build_dag.sh (wave742)"
fi
if ! grep -qE 'dry-run|--run|dryrun' "$XCODE_REL"; then
  bad "xlang-build.sh must wire product-dag --dry-run / --run (wave743 11.1.2)"
fi

# wave745: platform + linker policy companion (G.7 single host-facts shell)
if [ ! -f compiler/docs/PLATFORM_LINKER.md ]; then
  bad "missing compiler/docs/PLATFORM_LINKER.md (wave745 11.1.3/4)"
elif [ ! -f compiler/scripts/host_platform_linker.sh ]; then
  bad "missing compiler/scripts/host_platform_linker.sh (wave745)"
elif ! grep -qE 'host-platform|linker-policy' "$XCODE_REL" \
  || ! grep -q 'host_platform_linker\.sh' "$XCODE_REL"; then
  bad "xlang-build.sh must wire host-platform / linker-policy (wave745)"
elif ! grep -qE '11\.1\.3|PLATFORM_LINKER|host_platform_linker|wave745' "$DOC_REL"; then
  bad "$DOC_REL must cross-ref wave745 PLATFORM_LINKER / 11.1.3"
else
  if ! bash compiler/scripts/host_platform_linker.sh --check \
    >/tmp/host_platform_linker_check.out 2>/tmp/host_platform_linker_check.err; then
    bad "host_platform_linker.sh --check failed (wave745)"
    head -30 /tmp/host_platform_linker_check.err >&2 || true
  else
    if ! grep -q 'CHECK OK' /tmp/host_platform_linker_check.out \
      && ! grep -q 'CHECK OK' /tmp/host_platform_linker_check.err; then
      bad "host_platform_linker --check missing CHECK OK banner"
    else
      note "host_platform_linker --check OK (wave745 11.1.3/4)"
    fi
  fi
fi

# wave746–747: leaf pattern residual inventory + R4 mode-policy (11.3.1 path)
if [ ! -f compiler/docs/LEAF_PATTERN_RESIDUAL.md ]; then
  bad "missing compiler/docs/LEAF_PATTERN_RESIDUAL.md (wave746 11.3.1 path)"
elif [ ! -f compiler/scripts/leaf_pattern_residual.sh ]; then
  bad "missing compiler/scripts/leaf_pattern_residual.sh (wave746)"
elif ! grep -qE 'leaf-patterns|leaf-residual' "$XCODE_REL" \
  || ! grep -q 'leaf_pattern_residual\.sh' "$XCODE_REL"; then
  bad "xlang-build.sh must wire leaf-patterns / leaf-residual (wave746)"
elif ! grep -qE '11\.3\.1|LEAF_PATTERN|leaf_pattern_residual|wave746|wave747' "$DOC_REL"; then
  bad "$DOC_REL must cross-ref wave746/747 LEAF_PATTERN / 11.3.1"
elif ! grep -qE '11\.3\.1|leaf.pattern|LEAF_PATTERN' build.x; then
  bad "build.x must mention 11.3.1 / leaf pattern residual (wave746)"
elif ! grep -q 'driver_seed_obj_catalog\.sh' compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh \
  || ! grep -q 'catalog_key=' compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh; then
  bad "rebuild_leaves must use catalog mode table (wave747 R4)"
else
  if ! bash compiler/scripts/leaf_pattern_residual.sh --check \
    >/tmp/leaf_pattern_residual_check.out 2>/tmp/leaf_pattern_residual_check.err; then
    bad "leaf_pattern_residual.sh --check failed (wave747)"
    head -30 /tmp/leaf_pattern_residual_check.err >&2 || true
  else
    if ! grep -q 'CHECK OK' /tmp/leaf_pattern_residual_check.out \
      && ! grep -q 'CHECK OK' /tmp/leaf_pattern_residual_check.err; then
      bad "leaf_pattern_residual --check missing CHECK OK banner"
    else
      note "leaf_pattern_residual --check OK (wave747 R4 mode + 11.3.1 path)"
    fi
  fi
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
    # cold dry-run must surface ensure_prereqs first (wave744)
    if [ "$_p" = cold ]; then
      if ! grep -q 'NODE=cold_ensure_prereqs' /tmp/product_build_dag_dry_${_p}.out; then
        bad "cold dry-run must include cold_ensure_prereqs (wave744)"
      fi
      if ! grep -qE 'PREREQ=|driver_seed_ensure_prereqs: DRY-RUN OK' /tmp/product_build_dag_dry_${_p}.out \
        && ! grep -qE 'PREREQ=|DRY-RUN OK' /tmp/product_build_dag_dry_${_p}.err; then
        # PREREQ lines go to stdout from ensure; banner may be mixed
        if ! grep -q 'PREREQ=' /tmp/product_build_dag_dry_${_p}.out; then
          bad "cold dry-run must expand PREREQ= lines via ensure_prereqs (wave744)"
        fi
      fi
    fi
    note "dry-run $_p OK"
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "product_build_dag: CHECK FAIL" >&2
  exit 1
fi
echo "product_build_dag: CHECK OK (11.1.1+11.1.2 wave743 · 11.3 prereq edges wave744 · 11.1.3/4 wave745 · 11.3.1 leaf residual wave746 · R4 mode wave747)"
exit 0
