#!/usr/bin/env bash
# bootstrap_x_compiler.sh — archaeology bootstrap-x-compiler body
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phony bootstrap-x-compiler:
#     1) xlang_x -x -E typeck.x / codegen.x → typeck_x_x.c / codegen_x_x.c
#     2) host-cc -c those gens → typeck_x_x.o / codegen_x_x.o
#     3) host-cc link TARGET_x_stage2 with BXC_LINK_OBJS + those .o
#
#   Why not migrate_x_objs?
#     typeck_x_x / codegen_x_x are *stage2 archaeology* TU names (wave785 honesty).
#     Product typeck_x.o / codegen_x.o stay under migrate_x_objs — different path.
#
#   Link bag authority: mk/objs_core.mk OBJS=$(OBJS_CORE) (wave820).
#   wave859: BXC_LINK_OBJS via make export-bxc-link-objs when unset
#   (OBJS may expand platform OBJS_CORE ifeq — not pure mk text alone).
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_x_compiler.sh
#   bash scripts/bootstrap_x_compiler.sh --check
#
# Env (product path):
#   TARGET         — product binary basename (default: xlang)
#   TARGET_X       — .x-pipeline binary (default: ${TARGET}_x)
#   STAGE2         — output binary (default: ${TARGET}_x_stage2)
#   CC             — host C compiler (default: cc)
#   CFLAGS         — host CFLAGS for -c and link base
#   MAKE           — residual make for export leaf (wave859)
#   BXC_LINK_OBJS  — optional; default loads via export-bxc-link-objs
#
# wave842 (G.7 有则补全): Makefile fat -x -E + $(CC) -c + link → this script.
# wave859: BXC_LINK_OBJS shell-load via make export leaf (G.7; not physical delete).
# NOT physical delete — thin-call edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — shell orchestration; product seed pins host-portable.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
TARGET_X="${TARGET_X:-${TARGET}_x}"
STAGE2="${STAGE2:-${TARGET}_x_stage2}"
CC="${CC:-cc}"
CFLAGS="${CFLAGS:-}"
MAKE="${MAKE:-make}"

log() { echo "bootstrap-x-compiler: $*" >&2; }
fail() { echo "bootstrap-x-compiler: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  # Makefile thin-call only (wave842): scan *recipe* lines (tab-indented) only —
  # comments between phonies must not false-positive on "$(CC) -c" prose.
  _rec=$(awk '
    /^bootstrap-x-compiler:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'bootstrap_x_compiler\.sh' <<<"$_rec"; then
    fail "bootstrap-x-compiler must thin-call bootstrap_x_compiler.sh (wave842)"
  fi
  # Dual body: host-cc -c on archaeology typeck_x_x / codegen_x_x, or inline -x -E
  if grep -qE '\$\(CC\).*-c .*typeck_x_x|\$\(CC\).*-c .*codegen_x_x' <<<"$_rec"; then
    fail "bootstrap-x-compiler must not keep dual \$(CC) -c typeck_x_x body (wave842)"
  fi
  if grep -qE 'TARGET\)_x.*-x.*-E|xlang_x.*-x.*-E|typeck_x_x\.c|codegen_x_x\.c' <<<"$_rec"; then
    fail "bootstrap-x-compiler must not keep dual -x -E emit body (wave842; shell owns emit)"
  fi
  # wave859: Makefile must not re-export multi-token BXC bag (shell loads export leaf).
  if grep -qE 'BXC_LINK_OBJS=' <<<"$_rec"; then
    fail "bootstrap-x-compiler must not export BXC_LINK_OBJS (wave859; shell loads export-bxc-link-objs)"
  fi
  if ! grep -qE '^export-bxc-link-objs:' "$MF"; then
    fail "Makefile must define export-bxc-link-objs (wave859)"
  fi
  log "CHECK OK (wave842+859 bootstrap-x-compiler shell-primary; BXC bag export leaf; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ "$MODE" != "" ]; then
  case "$MODE" in
    -h|--help)
      echo "usage: $0 [--check]" >&2
      exit 0
      ;;
    *)
      echo "usage: $0 [--check]" >&2
      exit 2
      ;;
  esac
fi

# ---------------------------------------------------------------------------
# Preflight: link bag from make export leaf when unset (wave859; G.7)
# PLATFORM: SHARED — KEY=value from export target; no second .o inventory.
# ---------------------------------------------------------------------------
_load_link_objs_via_make() {
  # $1 = make export target (export-*-link-objs)
  local target="$1"
  local raw line val
  raw=$(MAKEFLAGS= "${MAKE:-make}" -s "$target") || return 1
  val=
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      LINK_OBJS=*) val=${line#LINK_OBJS=} ;;
    esac
  done <<<"$raw"
  printf '%s' "$val"
}

if [ -z "${BXC_LINK_OBJS:-}" ]; then
  BXC_LINK_OBJS=$(_load_link_objs_via_make export-bxc-link-objs) \
    || fail "failed to expand export-bxc-link-objs (wave859 BXC shell-load)"
fi
if [ -z "${BXC_LINK_OBJS:-}" ]; then
  fail "empty LINK_OBJS from export-bxc-link-objs (wave859)"
fi
if [ ! -x "./$TARGET_X" ] && [ ! -f "./$TARGET_X" ]; then
  fail "missing $TARGET_X (build prereq first: make xlang-x-pipeline)"
fi

# ---------------------------------------------------------------------------
# Emit stage2 archaeology C via full .x pipeline (-x -E on xlang_x)
# PLATFORM: SHARED — intermediate TU names typeck_x_x / codegen_x_x are archaeology only
# ---------------------------------------------------------------------------
log "emit typeck_x_x.c via ./$TARGET_X -x -E"
./"$TARGET_X" -x -E src/typeck/typeck.x > typeck_x_x.c

log "emit codegen_x_x.c via ./$TARGET_X -x -E"
./"$TARGET_X" -x -E src/codegen/codegen.x > codegen_x_x.c

# ---------------------------------------------------------------------------
# host-cc -c (not product migrate_x_objs; different TU names)
# ---------------------------------------------------------------------------
log "host-cc -c typeck_x_x.c / codegen_x_x.c"
# shellcheck disable=SC2086
$CC $CFLAGS -c typeck_x_x.c -o typeck_x_x.o
# shellcheck disable=SC2086
$CC $CFLAGS -c codegen_x_x.c -o codegen_x_x.o

# ---------------------------------------------------------------------------
# Link stage2 with USE_X_TYPECK / USE_X_CODEGEN (base bag from export leaf)
# PLATFORM: SHARED — host CC links expanded .o; pure-ld not this archaeology path
# ---------------------------------------------------------------------------
log "link ./$STAGE2"
# shellcheck disable=SC2086
$CC $CFLAGS -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN -o "./$STAGE2" \
  $BXC_LINK_OBJS typeck_x_x.o codegen_x_x.o
echo "bootstrap-x-compiler OK (.x pipeline typeck/codegen C → $STAGE2)"
