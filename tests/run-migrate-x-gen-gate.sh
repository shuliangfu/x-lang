#!/usr/bin/env bash
# parser/lexer/typeck/codegen/ast .x → gen.c marker gate (M-3 region / linear / slice).
#
# Honesty: soft auto-make of xlang-c + soft wipe+rebuild of *_gen.c when
# mtime-stale (false authority; can leave the tree without gen.c on rebuild
# fail) retired. Default = inspect-only existing gen.c (no delete, no soft
# rebuild). FORCE=1 / XLANG_FORCE_REFRESH_ASM_GATE=1 → require existing
# native xlang-c (hard die; refuse soft auto-make), then rebuild via
# ensure_migrate_gen + migrate_x_objs (no premature rm of gen). Stale
# mtime without FORCE = obs= (refuse soft auto-rebuild). Missing gen =
# hard die. Marker miss = hard FAIL. Report: run=/obs=/skip=
# Usage: ./tests/run-migrate-x-gen-gate.sh
# Env: XLANG_FORCE_MIGRATE_X_GEN=1 force rebuild; XLANG_FORCE_REFRESH_ASM_GATE=1 same.
# PLATFORM: SHARED — Ubuntu gold still required. Do not relink xlang_asm here.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_MIGRATE_X_GEN_PREFIX:-xlang: [MIGRATE_X_GEN]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "migrate-x-gen FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

X_SRC=(
  compiler/src/parser/parser.x
  compiler/src/lexer/lexer.x
  compiler/src/typeck/typeck.x
  compiler/src/codegen/codegen.x
  compiler/src/ast/ast.x
)
X_OBJ=(
  compiler/parser_x.o
  compiler/lexer_x.o
  compiler/typeck_x.o
  compiler/codegen_x.o
  compiler/ast_gen2.c
)
GEN_REQUIRED=(
  compiler/parser_gen.c
  compiler/typeck_gen.c
  compiler/codegen_gen.c
)

FORCE="${XLANG_FORCE_MIGRATE_X_GEN:-0}"
if [ "${XLANG_FORCE_REFRESH_ASM_GATE:-0}" = "1" ]; then
  FORCE=1
fi

need_rebuild=0
if [ "$FORCE" = "1" ]; then
  need_rebuild=1
else
  for f in "${X_SRC[@]}"; do
    for o in "${X_OBJ[@]}"; do
      if [ ! -f "$o" ] || [ "$f" -nt "$o" ]; then
        need_rebuild=1
        break 2
      fi
    done
  done
fi

echo "=== migrate-x-gen gate (inspect-only default; refuse soft auto-make / soft wipe) ==="

if [ "$FORCE" = "1" ]; then
  # Explicit force rebuild: require existing native xlang-c; never soft-make.
  # PLATFORM: SHARED — rebuild authority = ensure_migrate_gen + migrate_x_objs.
  if ! dod_native_exe ./compiler/xlang-c; then
    die "FORCE rebuild needs native ./compiler/xlang-c (refuse soft auto-make)"
  fi
  echo "migrate-x-gen: FORCE rebuild via ensure_migrate_gen + migrate_x_objs (no wipe-first)"
  (
    cd compiler
    # Do NOT rm *_gen.c first — ensure/migrate own pin/assemble without
    # leaving a hole if -E fails mid-flight.
    bash scripts/ensure_migrate_gen.sh all-frontend
    bash scripts/migrate_x_objs.sh all
  ) || die "FORCE rebuild failed (ensure_migrate_gen / migrate_x_objs)"
elif [ "$need_rebuild" = "1" ]; then
  # Stale or missing objs without FORCE: observational — refuse soft wipe+rebuild.
  echo "migrate-x-gen OBS: src/obj stale or missing .o (refuse soft auto-rebuild; set XLANG_FORCE_MIGRATE_X_GEN=1)" >&2
  OBS=$((OBS + 1))
fi

# Inspect-only (or post-FORCE) marker contract on existing gen.c.
for g in "${GEN_REQUIRED[@]}"; do
  [ -f "$g" ] || die "missing $g (refuse soft auto-make / soft pin restore in gate)"
done

require_needle() {
  local file="$1" needle="$2" msg="$3"
  grep -q "$needle" "$file" || die "$msg"
}

require_needle compiler/parser_gen.c 'pipeline_block_append_region' \
  "parser_gen.c missing pipeline_block_append_region"
require_needle compiler/parser_gen.c 'region_label' \
  "parser_gen.c missing region_label (slice domain)"
require_needle compiler/typeck_gen.c 'pipeline_typeck_check_block_one_region_c' \
  "typeck_gen.c missing block region typeck glue"
require_needle compiler/typeck_gen.c 'pipeline_typeck_check_call_slice_region_c' \
  "typeck_gen.c missing call slice region glue"
require_needle compiler/parser_gen.c 'parser_copy_module_import_path64' \
  "parser_gen thin gen incomplete"
require_needle compiler/typeck_gen.c 'pipeline_typeck_linear_use_var_c' \
  "typeck_gen.c missing linear move glue"
require_needle compiler/parser_gen.c 'TYPE_LINEAR' \
  "parser_gen.c missing TYPE_LINEAR"
require_needle compiler/codegen_gen.c 'TYPE_LINEAR' \
  "codegen_gen.c missing TYPE_LINEAR unwrap"
require_needle compiler/typeck_gen.c 'pipeline_typeck_reject_addr_of_linear_c' \
  "typeck_gen.c missing reject addr_of linear glue"
require_needle compiler/typeck_gen.c 'pipeline_typeck_is_read_ptr_slice_callee_c' \
  "typeck_gen.c missing read_ptr slice region glue"
require_needle compiler/codegen_gen.c 'field_access_base_is_slice_param_name' \
  "codegen_gen.c missing slice param field access (local . vs param ->)"

RUN_OK=$((RUN_OK + 1))
echo "migrate-x-gen OK (gen markers present)"
ok_report
