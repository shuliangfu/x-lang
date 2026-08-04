#!/usr/bin/env bash
# driver_seed_ensure_prereqs.sh — wave935 · 11.3 residual: shell-primary DRIVER_SEED_PREREQS edges
#
# Authority (G.7):
#   Object-list *definition* of DRIVER_SEED_PREREQS stays in
#   compiler/mk/driver_seed_composites.mk (read via driver_seed_obj_catalog.sh /
#   make bootstrap-driver-seed-export-obj-catalog). This script owns only
#   *edge satisfaction*: expand the catalog key and dispatch each target via
#   shell — no Make invocation in --run path.
#   wave935: dispatch by catalog membership (MIGRATE_X_OBJS → migrate_x_objs.sh;
#   DRIVER_LEAF_PRODUCT_OBJS → driver_leaf_x_to_o.sh; others → try-heat).
#   MAKE retained for --check fallback only.
#
# Usage (from compiler/):
#   bash scripts/driver_seed_ensure_prereqs.sh              # run (make prereqs)
#   bash scripts/driver_seed_ensure_prereqs.sh --dry-run
#   bash scripts/driver_seed_ensure_prereqs.sh --check
#   bash scripts/driver_seed_ensure_prereqs.sh --run
#
# Env:
#   MAKE — make binary (default: make)
#   XLANG_SKIP_DRIVER_SEED_PREREQS=1 — no-op (nested / agent escape hatch)
#   XLANG_CATALOG_CACHE_FILE — when set and non-empty, reuse parent-warmed catalog
#     blob (bootstrap_driver_seed warms once for the whole seed wave). This script
#     only creates/deletes a cache file when it owns the warm.
#
# PLATFORM: SHARED — catalog expansion is host-specific (Darwin filtered lists);
# leaf recipes carry platform ABI. Wave744 Track MG (not physical Makefile delete).

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
MODE=run
case "${1:-}" in
  --dry-run|dry-run|dryrun) MODE=dry-run ;;
  --check|check|-c) MODE=check ;;
  --run|run|ensure|"") MODE=run ;;
  help|-h|--help)
    sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "driver_seed_ensure_prereqs: unknown mode '${1:-}' (use --dry-run|--check|--run)" >&2
    exit 2
    ;;
esac

if [ "${XLANG_SKIP_DRIVER_SEED_PREREQS:-}" = "1" ]; then
  echo "driver_seed_ensure_prereqs: skip (XLANG_SKIP_DRIVER_SEED_PREREQS=1)" >&2
  exit 0
fi

# Clear MAKEFLAGS so parent `make -n` / jobserver noise does not poison export.
export MAKEFLAGS=""

if [ ! -f scripts/driver_seed_obj_catalog.sh ]; then
  echo "driver_seed_ensure_prereqs: missing scripts/driver_seed_obj_catalog.sh" >&2
  exit 1
fi

catalog_out="$(bash scripts/driver_seed_obj_catalog.sh)"
prereqs="$(printf '%s\n' "$catalog_out" | sed -n 's/^DRIVER_SEED_PREREQS=//p' | head -1)"

# Historical Makefile attached glue companion outside the composite list:
#   bootstrap-driver-seed: $(DRIVER_SEED_PREREQS) build_asm/pipeline_glue_strict_minimal.o
# Keep that edge; do not bake a full second list.
extra_glue="build_asm/pipeline_glue_strict_minimal.o"

if [ -z "${prereqs// /}" ]; then
  echo "driver_seed_ensure_prereqs: empty DRIVER_SEED_PREREQS from catalog" >&2
  exit 1
fi

# Build ordered unique word list (prereqs first, then glue if not already present).
# shellcheck disable=SC2086
set -- $prereqs
have_glue=0
for t in "$@"; do
  if [ "$t" = "$extra_glue" ]; then
    have_glue=1
    break
  fi
done
if [ "$have_glue" -eq 0 ]; then
  set -- "$@" "$extra_glue"
fi

n=$#
if [ "$n" -lt 8 ]; then
  echo "driver_seed_ensure_prereqs: DRIVER_SEED_PREREQS too short (n=$n; catalog broken?)" >&2
  exit 1
fi

# Spot-check core cold nodes are present (names only — not a second inventory).
joined=" $* "
for must in pipeline_x.o parser_x.o typeck_x.o codegen_x.o driver_x.o; do
  case "$joined" in
    *" $must "*) ;;
    *)
      echo "driver_seed_ensure_prereqs: catalog PREREQS missing expected $must" >&2
      exit 1
      ;;
  esac
done

echo "driver_seed_ensure_prereqs: mode=$MODE count=$n (catalog DRIVER_SEED_PREREQS + glue companion)" >&2

# ---------------------------------------------------------------------------
# Filter product PE / tip binaries out of make goals.
#
# DRIVER_SEED_PREREQS in mk/driver_seed_composites.mk still begins with
# $(XLANG_C) (historical "compiler first" orchestration edge when the phony
# carried the list as make-graph deps). Shell ensure (wave744) must *not*
# pass PE names as goals:
#   - Pulls the full product DAG (xlang-c → everything) instead of leaf .o/.c
#   - On Windows hybrid min-gate, MAKE is wrapped with -o xlang-c … to avoid
#     nested PE rebuild; goal+assume-old on the same PE yields
#     "xlang-c is up to date" then multi-minute graph stalls with no gcc
# G.7: list *definition* stays in the mk catalog; this script only owns
# edge satisfaction for rebuildable leaves (objs + gen sources).
# PLATFORM: SHARED — filter is host-independent; Windows hang was the symptom.
# ---------------------------------------------------------------------------
_is_product_pe_goal() {
  case "$1" in
    xlang|xlang-c|xlang-x|xlang_asm|bootstrap_xlangc|xlang-seed-phase1|\
    xlang.exe|xlang-c.exe|xlang-x.exe|xlang_asm.exe|bootstrap_xlangc.exe|\
    xlang-seed-phase1.exe|bootstrap_shuxc|bootstrap_shuxc.exe)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

_filt=
_skipped=
for _t in "$@"; do
  if _is_product_pe_goal "$_t"; then
    _skipped="${_skipped} ${_t}"
    continue
  fi
  _filt="${_filt} ${_t}"
done
# shellcheck disable=SC2086
set -- $_filt
n=$#
if [ -n "${_skipped// /}" ]; then
  echo "driver_seed_ensure_prereqs: skip product PE goals:${_skipped}" >&2
fi
if [ "$n" -lt 8 ]; then
  echo "driver_seed_ensure_prereqs: leaf goals too short after PE filter (n=$n)" >&2
  exit 1
fi
echo "driver_seed_ensure_prereqs: leaf goals count=$n" >&2

if [ "$MODE" = dry-run ] || [ "$MODE" = check ]; then
  i=0
  for t in "$@"; do
    printf 'PREREQ=%d PATH=%s\n' "$i" "$t"
    i=$((i + 1))
  done
  if [ "$MODE" = dry-run ]; then
    echo "driver_seed_ensure_prereqs: DRY-RUN OK count=$n"
  else
    echo "driver_seed_ensure_prereqs: CHECK OK count=$n"
  fi
  exit 0
fi

# run: single make invocation for leaf edge targets only.
# Shared catalog blob for try-heat children. Prefer parent session cache
# (bootstrap_driver_seed); only warm+own a temp file when unset so EXIT does
# not delete the bootstrap-wide cache (that regressed Windows after prereqs:
# pipeline-x try-r1 ladder re-expanded catalog for minutes). PLATFORM: SHARED.
_cat_owned=0
_cat_cache=""
if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE}" ]; then
  echo "driver_seed_ensure_prereqs: catalog cache reuse OK (${XLANG_CATALOG_CACHE_FILE})" >&2
else
  _cat_cache="${TMPDIR:-/tmp}/xlang_ensure_prereqs_cat_$$.txt"
  if bash scripts/driver_seed_obj_catalog.sh --shell >"$_cat_cache" 2>/tmp/xlang_ensure_cat_err_$$.txt; then
    export XLANG_CATALOG_CACHE_FILE="$_cat_cache"
    _cat_owned=1
    echo "driver_seed_ensure_prereqs: catalog cache warm OK ($_cat_cache)" >&2
  else
    echo "driver_seed_ensure_prereqs: catalog warm failed (try-heat will re-expand)" >&2
    cat /tmp/xlang_ensure_cat_err_$$.txt 2>/dev/null || true
    rm -f "$_cat_cache" /tmp/xlang_ensure_cat_err_$$.txt
    unset XLANG_CATALOG_CACHE_FILE || true
    _cat_cache=""
    _cat_owned=0
  fi
fi
# shellcheck disable=SC2064
trap 'if [ "${_cat_owned:-0}" = "1" ]; then rm -f "${_cat_cache:-}" /tmp/xlang_ensure_cat_err_$$.txt; fi' EXIT HUP INT TERM

echo "driver_seed_ensure_prereqs: shell try-heat ($n leaf targets) ..." >&2

# wave935: shell-primary edge satisfaction (G.7 single body; was make "$@").
# Each target dispatches by suffix:
#   *.c   → ensure_lsp_pipeline_gen.sh (LSP pipeline gen sources; 3 leaves)
#   *.o   → ensure_host_cc_seed_o.sh try-heat (50 leaves; includes special
#           path build_asm/pipeline_glue_strict_minimal.o which try-heat
#           resolves via R1_MISC_BASENAME seed map)
# Pre-load CFLAGS / PIPELINE_GEN_CFLAGS via catalog --cflags-export so try-heat
# children do not each invoke `make export-try-heat-cflags`.
if [ -z "${CFLAGS+x}" ] || [ -z "${PIPELINE_GEN_CFLAGS+x}" ]; then
  _cflags_blob=""
  if _cflags_blob=$(bash scripts/driver_seed_obj_catalog.sh --cflags-export 2>/dev/null); then
    while IFS= read -r _line || [ -n "$_line" ]; do
      case "$_line" in
        CFLAGS=*) [ -z "${CFLAGS+x}" ] && CFLAGS=${_line#CFLAGS=} ;;
        PIPELINE_GEN_CFLAGS=*) [ -z "${PIPELINE_GEN_CFLAGS+x}" ] && PIPELINE_GEN_CFLAGS=${_line#PIPELINE_GEN_CFLAGS=} ;;
      esac
    done <<<"$_cflags_blob"
  fi
  export CFLAGS PIPELINE_GEN_CFLAGS
fi

# wave935: query catalog for MIGRATE_X_OBJS and DRIVER_LEAF_PRODUCT_OBJS
# (G.7 single authority — no hardcoded name lists in this script).
# Catalog cache is already warmed (parent or owned above); reuse it.
_migrate_x_objs=""
_driver_leaf_product_objs=""
if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE}" ]; then
  _migrate_x_objs=$(sed -n 's/^MIGRATE_X_OBJS=//p' "${XLANG_CATALOG_CACHE_FILE}" | head -1)
  _driver_leaf_product_objs=$(sed -n 's/^DRIVER_LEAF_PRODUCT_OBJS=//p' "${XLANG_CATALOG_CACHE_FILE}" | head -1)
fi
# Fallback: re-expand catalog if cache missing or keys empty.
if [ -z "${_migrate_x_objs// /}" ] || [ -z "${_driver_leaf_product_objs// /}" ]; then
  _cat_blob=$(bash scripts/driver_seed_obj_catalog.sh 2>/dev/null)
  _migrate_x_objs=$(printf '%s\n' "$_cat_blob" | sed -n 's/^MIGRATE_X_OBJS=//p' | head -1)
  _driver_leaf_product_objs=$(printf '%s\n' "$_cat_blob" | sed -n 's/^DRIVER_LEAF_PRODUCT_OBJS=//p' | head -1)
fi

# Membership check: $1=target, $2=space-separated list.
_in_list() {
  case " $2 " in *" $1 "*) return 0 ;; esac
  return 1
}

_ok=0
_fail=0
for _t in "$@"; do
  case "$_t" in
    *.c)
      # LSP pipeline gen sources: lsp_io_gen.c / lsp_gen.c / lsp_diag_gen.c
      # Map gen source name to ensure_lsp_pipeline_gen.sh family arg.
      case "$_t" in
        lsp_io_gen.c)    _fam=lsp_io ;;
        lsp_gen.c)       _fam=lsp_gen ;;
        lsp_diag_gen.c)  _fam=lsp_diag ;;
        *) echo "driver_seed_ensure_prereqs: unknown .c gen source $_t" >&2; _fail=$((_fail+1)); continue ;;
      esac
      if bash scripts/ensure_lsp_pipeline_gen.sh "$_fam" >&2; then
        _ok=$((_ok+1))
      else
        echo "driver_seed_ensure_prereqs: FAIL ensure_lsp_pipeline_gen.sh $_fam ($_t)" >&2
        _fail=$((_fail+1))
      fi
      ;;
    *.o)
      # wave935: dispatch by catalog membership (G.7 single authority).
      # - MIGRATE_X_OBJS (parser_x.o, typeck_x.o, codegen_x.o):
      #   migrate_x_objs.sh (Makefile rule body; .x→.o via xlang-x -E).
      # - DRIVER_LEAF_PRODUCT_OBJS (driver_*_x.o, lsp_io_std_heap_x.o):
      #   driver_leaf_x_to_o.sh ensure (Makefile rule body; .x→.o catalog).
      # - All other .o: try-heat auto-dispatch (prefer/R1/R2/R3 tables).
      if _in_list "$_t" "$_migrate_x_objs"; then
        if bash scripts/migrate_x_objs.sh "$_t" >&2; then
          _ok=$((_ok+1))
        else
          echo "driver_seed_ensure_prereqs: FAIL migrate_x_objs.sh $_t" >&2
          _fail=$((_fail+1))
        fi
      elif _in_list "$_t" "$_driver_leaf_product_objs"; then
        if bash scripts/driver_leaf_x_to_o.sh ensure "$_t" >&2; then
          _ok=$((_ok+1))
        else
          echo "driver_seed_ensure_prereqs: FAIL driver_leaf_x_to_o.sh ensure $_t" >&2
          _fail=$((_fail+1))
        fi
      else
        if bash scripts/ensure_host_cc_seed_o.sh try-heat "$_t" >&2; then
          _ok=$((_ok+1))
        else
          echo "driver_seed_ensure_prereqs: FAIL try-heat $_t" >&2
          _fail=$((_fail+1))
        fi
      fi
      ;;
    *)
      echo "driver_seed_ensure_prereqs: unknown target type $_t" >&2
      _fail=$((_fail+1))
      ;;
  esac
done

if [ "$_fail" -ne 0 ]; then
  echo "driver_seed_ensure_prereqs: FAIL ok=$_ok fail=$_fail (of $n)" >&2
  exit 1
fi
echo "driver_seed_ensure_prereqs: RUN OK ok=$_ok count=$n" >&2
exit 0
