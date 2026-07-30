#!/usr/bin/env bash
# migrate_x_objs.sh — body of make migrate-x-objs + parser/typeck/codegen _x.o (11.1.6 · wave735)
#
# Authority (G.7):
#   Single implementation of the migrate companion compile path:
#     parser_gen.c  → parser_x.o
#     typeck_gen.c  → typeck_x.o
#     codegen_gen.c → codegen_x.o
#   Makefile thin leaves call this script; refresh-gate and xbuild call it
#   directly (no `make migrate-x-objs` recipe body).
#
#   *_gen.c production: G.7 body = scripts/ensure_migrate_gen.sh (wave736).
#   This script calls ensure_migrate_gen for missing/stale gen (0× make).
#   Residual make only if ensure_migrate_gen needs a missing xlang-c binary.
#
# Usage (cwd = compiler/):
#   sh scripts/migrate_x_objs.sh              # all three (default)
#   sh scripts/migrate_x_objs.sh all
#   sh scripts/migrate_x_objs.sh parser|typeck|codegen
#   ./xbuild migrate                          # repo root
#   make migrate-x-objs | make parser_x.o …   # thin Makefile leaves
#
# Env:
#   CC / CFLAGS / PIPELINE_GEN_CFLAGS / PYTHON / MAKE — host compile
#   CFLAGS / PIPELINE_GEN_CFLAGS default: load via make export-try-heat-cflags
#     when unset (wave865; G.7 有则补全 on wave862 export leaf — OPT/-I/clang ifeq)
#   XLANG_MIGRATE_FORCE=1 — always recompile even if .o is newer than gen
#   XLANG_FORCE_REGEN_GEN=1 — force ensure_migrate_gen -E path
#
# PLATFORM: SHARED shell orchestration; seed pins are host-portable C.
# Wave: 735/736 Track MG · pairs with ensure_migrate_gen.sh + Makefile thin leaves.
# wave832: Makefile *_x.o leaves are FORCE dep-thin; this script owns gen.c mtime
#   (need_rebuild + XLANG_MIGRATE_FORCE). NOT physical delete.
# wave865: Makefile drops multi-token CFLAGS="$(CFLAGS)" inject; shell loads
#   export-try-heat-cflags when unset (same authority as try-heat / wave862).
# wave878: Makefile drops multi-token CC/PYTHON/MAKE inject; shell defaults own
#   CC="${CC:-cc}" / PYTHON auto / MAKE="${MAKE:-make}" (G.7 有则补全 wave877-style).

# Makefile thin leaves invoke this script with `sh` (Ubuntu dash; macOS often bash).
# Avoid bash-only set options so both hosts parse (G.8 PLATFORM: SHARED).
# dash: `set -o pipefail` is illegal — use a subshell guard (special-builtin + set -e
# does not honor `cmd || true` for failed `set` on some dash builds).
set -eu
(set -o pipefail) 2>/dev/null || true
cd "$(dirname "$0")/.."

CC="${CC:-cc}"
MAKE="${MAKE:-make}"
PYTHON="${PYTHON:-}"
if [ -z "$PYTHON" ]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
  else
    PYTHON=python
  fi
fi
XLANG_MIGRATE_FORCE="${XLANG_MIGRATE_FORCE:-0}"
MODE="${1:-all}"

# wave865 · B7B migrate CFLAGS shell-load (G.7 有则补全 on wave862 export leaf).
# Product CFLAGS / PIPELINE_GEN_CFLAGS need make expansion (OPT += -O2; clang
# silence ifeq). Makefile migrate recipes drop multi-token CFLAGS= env; shell
# loads export-try-heat-cflags when either var is unset.
# PLATFORM: SHARED — KEY=value from export target; no compile side effects.
_load_try_heat_cflags_via_make() {
  # PLATFORM: SHARED — invoked via `sh` on Makefile thin leaves (dash on Ubuntu);
  # use heredoc not bash <<< so macOS bash + Ubuntu dash both parse.
  # shellcheck disable=SC2039
  local raw line
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s export-try-heat-cflags) || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      CFLAGS=*)
        if [ -z "${CFLAGS+x}" ]; then
          CFLAGS=${line#CFLAGS=}
        fi
        ;;
      PIPELINE_GEN_CFLAGS=*)
        if [ -z "${PIPELINE_GEN_CFLAGS+x}" ]; then
          PIPELINE_GEN_CFLAGS=${line#PIPELINE_GEN_CFLAGS=}
        fi
        ;;
    esac
  done <<EOF
$raw
EOF
  return 0
}

if [ -z "${CFLAGS+x}" ] || [ -z "${PIPELINE_GEN_CFLAGS+x}" ]; then
  _load_try_heat_cflags_via_make || true
fi
# Fallback when make export unavailable (direct shell invoke without Makefile).
CFLAGS="${CFLAGS:--Wall -Wextra -I. -Iinclude -Isrc}"
if [ -z "${PIPELINE_GEN_CFLAGS+x}" ] || [ -z "${PIPELINE_GEN_CFLAGS:-}" ]; then
  # Match Makefile PIPELINE_GEN_CFLAGS (Clang extras only when CC is clang).
  PIPELINE_GEN_CFLAGS_BASE="-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits"
  PIPELINE_GEN_CFLAGS_CLANG="-Wno-logical-op-parentheses -Wno-bitwise-op-parentheses -Wno-incompatible-pointer-types-discards-qualifiers -Wno-parentheses-equality"
  PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS_BASE"
  if "$CC" -v 2>&1 | grep -qi clang; then
    PIPELINE_GEN_CFLAGS="$PIPELINE_GEN_CFLAGS_BASE $PIPELINE_GEN_CFLAGS_CLANG"
  fi
fi

log() { echo "migrate-x-objs: $*" >&2; }

obj_size() {
  # PLATFORM: SHARED — Darwin stat -f%z; Linux stat -c%s
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

need_rebuild() {
  # $1=out.o $2=gen.c — rebuild if force, missing o, or gen newer than o
  local o="$1" g="$2"
  if [ "$XLANG_MIGRATE_FORCE" = "1" ]; then
    return 0
  fi
  if [ ! -f "$o" ]; then
    return 0
  fi
  if [ -n "$g" ] && [ -f "$g" ] && [ "$g" -nt "$o" ]; then
    return 0
  fi
  return 1
}

ensure_gen_via_shell() {
  # $1 = all|parser|typeck|codegen — G.7: ensure_migrate_gen.sh (wave736)
  local mode="$1"
  if [ ! -f scripts/ensure_migrate_gen.sh ]; then
    log "missing scripts/ensure_migrate_gen.sh (wave736)"
    exit 1
  fi
  MAKE="$MAKE" XLANG_FORCE_REGEN_GEN="${XLANG_FORCE_REGEN_GEN:-0}" \
    sh scripts/ensure_migrate_gen.sh "$mode"
}

# Skip ensure when gen already present (make only re-runs recipe when .x is newer).
# FORCE always re-ensures. codegen tip seed: re-sync only when local pin is missing
# or still byte-identical to seed (post fix_slim diverges — do not thrash rebuild).
# typeck: re-enter ensure when pin fails product symbol contract (Windows dual-boot
# gitignored pin drift → phase1 UNDEF). ensure_migrate_gen owns refresh body.
want_ensure_gen() {
  # $1=mode $2=gen.c $3=optional seed
  local mode="$1" gen="$2" seed="${3:-}"
  if [ "${XLANG_FORCE_REGEN_GEN:-0}" = "1" ]; then
    return 0
  fi
  if [ ! -s "$gen" ]; then
    return 0
  fi
  if [ "$mode" = "codegen" ] && [ -n "$seed" ] && [ -f "$seed" ]; then
    # Tip pin guard: only when local file still equals raw seed (pre-fix_slim pin).
    # After ensure_migrate_gen, fix_slim rewrites gen → differs from seed; skip re-copy
    # so we do not force rebuild every migrate (G.7 single path, no thrash).
    if cmp -s "$seed" "$gen" 2>/dev/null; then
      return 0
    fi
  fi
  # PLATFORM: SHARED — typeck pin contract (phase1 link surface).
  if [ "$mode" = "typeck" ]; then
    if ! grep -Fq 'typeck_check_call_arity' "$gen" \
      || ! grep -Fq 'typeck_expr_is_null_keyword' "$gen" \
      || ! grep -Fq 'typeck_type_is_valid_subscript_index' "$gen"; then
      return 0
    fi
  fi
  return 1
}

build_parser() {
  if want_ensure_gen parser parser_gen.c seeds/parser_gen.linux.x86_64.c; then
    ensure_gen_via_shell parser
  fi
  if ! need_rebuild parser_x.o parser_gen.c; then
    log "parser_x.o up-to-date"
    return 0
  fi
  # Makefile parity: token enum sync before cc (no-op-ish if already aligned)
  if [ -f scripts/sync_lexer_gen_token_enum.pl ]; then
    perl scripts/sync_lexer_gen_token_enum.pl parser_gen.c
  fi
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc \
    -Dstd_io_driver_driver_read_ptr_len=xlang_io_read_ptr_len \
    -Dstd_io_driver_driver_read_ptr=xlang_io_read_ptr \
    -c parser_gen.c -o parser_x.o
  log "parser_x.o OK"
}

build_typeck() {
  if want_ensure_gen typeck typeck_gen.c seeds/typeck_gen.linux.x86_64.c; then
    ensure_gen_via_shell typeck
  fi
  # Skip patch+cc when .o is current (patch may rewrite gen even when no-op-ish).
  if ! need_rebuild typeck_x.o typeck_gen.c; then
    log "typeck_x.o up-to-date"
    return 0
  fi
  # LANG-007: patch before compile (Makefile parity)
  if [ -f scripts/patch_typeck_gen_lang007.py ]; then
    "$PYTHON" scripts/patch_typeck_gen_lang007.py || true
  fi
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c typeck_gen.c -o typeck_x.o
  sz=$(obj_size typeck_x.o)
  if [ "$sz" -le 10000 ]; then
    log "typeck_x.o too small ($sz; corrupt gen? rm typeck_gen.c && sh scripts/ensure_migrate_gen.sh typeck)"
    exit 1
  fi
  log "typeck_x.o OK ($sz bytes)"
}

build_codegen() {
  if want_ensure_gen codegen codegen_gen.c seeds/codegen_gen.linux.x86_64.c; then
    ensure_gen_via_shell codegen
  fi
  if ! need_rebuild codegen_x.o codegen_gen.c; then
    log "codegen_x.o up-to-date"
    return 0
  fi
  # shellcheck disable=SC2086
  $CC $CFLAGS $PIPELINE_GEN_CFLAGS -I. -Iinclude -Isrc -c codegen_gen.c -o codegen_x.o
  sz=$(obj_size codegen_x.o)
  if [ "$sz" -le 50000 ]; then
    log "codegen_x.o too small ($sz; corrupt gen? rm codegen_gen.c && sh scripts/ensure_migrate_gen.sh codegen)"
    exit 1
  fi
  log "codegen_x.o OK ($sz bytes)"
}

case "$MODE" in
  all|"")
    build_parser
    build_typeck
    build_codegen
    echo "migrate-x-objs OK (parser_x.o typeck_x.o codegen_x.o ready)"
    ;;
  parser|parser_x.o)
    build_parser
    ;;
  typeck|typeck_x.o)
    build_typeck
    ;;
  codegen|codegen_x.o)
    build_codegen
    ;;
  -h|--help|help)
    cat <<'EOF'
Usage: migrate_x_objs.sh [all|parser|typeck|codegen]
  all (default)  — build parser_x.o typeck_x.o codegen_x.o
  parser|typeck|codegen — single leaf
Env: CC CFLAGS PYTHON MAKE XLANG_MIGRATE_FORCE=1
EOF
    ;;
  *)
    log "unknown mode: $MODE (use all|parser|typeck|codegen)"
    exit 2
    ;;
esac
