#!/usr/bin/env bash
# bootstrap_driver_seed_link.sh — phase1/final link body for cold bootstrap (11.0.3 / 11.1.4)
#
# Authority (G.7):
#   - Object lists + CFLAGS + platform link flags live ONLY in compiler/Makefile
#     (DRIVER_SEED_* / BOOTSTRAP_DRIVER_SEED_* / MAIN_LINK_* expansions).
#   - This script never hardcodes an .o list. It evals export leaves:
#       make bootstrap-driver-seed-export-phase1-link
#       make bootstrap-driver-seed-export-final-link
#   - wave772 · 11.1.4 pure-ld (default when SEED_LINK_PURE_OK=1):
#       "$SEED_LINK_LD" [platform] $MULTIDEF $ENTRY -o OUT $OBJS $TAIL
#     Residual fallback: "$SEED_LINK_CC" $CFLAGS -o OUT $OBJS
#     Force residual: XLANG_SEED_LINK_FORCE_CC=1
#   - wave773 · G.7 有则补全: pure-ld platform helpers live in pure_ld_shared.sh
#     (shared with g05_relink_xlang pure-ld prefer). No second platform table.
#
# Usage (compiler directory):
#   ./scripts/bootstrap_driver_seed_link.sh phase1
#   ./scripts/bootstrap_driver_seed_link.sh final
#   ./scripts/bootstrap_driver_seed_link.sh --self-test   # pure-ld smoke (tiny objs)
#
# Env:
#   MAKE   — make binary (default: make)
#   TARGET — final product name when mode=final (default: xlang); must match Makefile
#   XLANG_SEED_LINK_FORCE_CC=1 — skip pure-ld; use SEED_LINK_CC residual only
#
# PLATFORM: SHARED — link composition identical; Makefile expands platform
#            crt0 / -e / filtered.o into SEED_LINK_*.
# PLATFORM: MACOS — pure-ld needs -syslibroot / -arch / -platform_version / -lSystem
#            (composed in pure_ld_shared.sh; not a second .o inventory).
# PLATFORM: LINUX — pure-ld freestanding entry + multidef + -lc (nostartfiles-style).
# Wave: 721 export body · 772 pure-ld prefer (11.1.4) · 773 pure_ld_shared extract.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
MODE="${1:-}"

note() { echo "bootstrap_driver_seed_link: $*" >&2; }
fail() { echo "bootstrap_driver_seed_link: FAIL: $*" >&2; exit 1; }

# G.7: pure-ld platform prefix / resolve / freestanding facts — pure_ld_shared.sh only.
# shellcheck disable=SC1091
. scripts/pure_ld_shared.sh

# ---------------------------------------------------------------------------
# --self-test: pure-ld smoke with tiny host objs (no product .o list)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--self-test" ] || [ "$MODE" = "self-test" ]; then
  note "self-test pure-ld (tiny objs)"
  tmpd="${TMPDIR:-/tmp}/xlang_seed_link_selftest_$$"
  mkdir -p "$tmpd"
  cleanup() { rm -rf "$tmpd"; }
  trap cleanup EXIT
  # PLATFORM: SHARED — tiny C TUs; entry symbol with leading _ on Darwin.
  entry_sym="seed_link_selftest_entry"
  case "$(uname -s 2>/dev/null || echo Unknown)" in
    Darwin) entry_flag="-e _${entry_sym}" ;;
    *) entry_flag="-e ${entry_sym}" ;;
  esac
  cat >"$tmpd/a.c" <<EOF
int ${entry_sym}(void) { return 0; }
EOF
  cat >"$tmpd/b.c" <<EOF
int seed_link_selftest_other(void) { return 1; }
EOF
  "${CC:-cc}" -c -o "$tmpd/a.o" "$tmpd/a.c"
  "${CC:-cc}" -c -o "$tmpd/b.o" "$tmpd/b.c"
  out="$tmpd/out.exe"
  # G.7: pure_ld_try_link is the only pure-ld argv composition path.
  if ! pure_ld_try_link "$out" "$tmpd/a.o $tmpd/b.o" "$entry_flag" \
      "$(pure_ld_default_libc_tail)" "" ""; then
    fail "self-test pure-ld failed"
  fi
  [ -f "$out" ] || fail "self-test: missing $out"
  note "self-test OK pure-ld → $out"
  exit 0
fi

if [ "$MODE" != "phase1" ] && [ "$MODE" != "final" ]; then
  echo "bootstrap_driver_seed_link: usage: $0 phase1|final|--self-test" >&2
  exit 2
fi

export_target="bootstrap-driver-seed-export-${MODE}-link"

# Makefile single authority. Clear MAKEFLAGS so parent `make -n` / jobserver
# dry-run does not turn the export target into printed recipe text.
# KEY=value lines (first '=' splits) — safe for CFLAGS with commas/spaces.
export_raw=$(MAKEFLAGS= "$MAKE" -s "$export_target" TARGET="${TARGET:-xlang}")
if [ -z "$export_raw" ]; then
  fail "empty export from $export_target"
fi

SEED_LINK_CC=
SEED_LINK_CFLAGS=
SEED_LINK_LD=
SEED_LINK_MULTIDEF=
SEED_LINK_ENTRY=
SEED_LINK_LD_TAIL=
SEED_LINK_PURE_OK=0
SEED_LINK_OUT=
SEED_LINK_OBJS=
while IFS= read -r line; do
  [ -z "${line:-}" ] && continue
  case "$line" in
    SEED_LINK_CC=*) SEED_LINK_CC=${line#SEED_LINK_CC=} ;;
    SEED_LINK_CFLAGS=*) SEED_LINK_CFLAGS=${line#SEED_LINK_CFLAGS=} ;;
    SEED_LINK_LD=*) SEED_LINK_LD=${line#SEED_LINK_LD=} ;;
    SEED_LINK_MULTIDEF=*) SEED_LINK_MULTIDEF=${line#SEED_LINK_MULTIDEF=} ;;
    SEED_LINK_ENTRY=*) SEED_LINK_ENTRY=${line#SEED_LINK_ENTRY=} ;;
    SEED_LINK_LD_TAIL=*) SEED_LINK_LD_TAIL=${line#SEED_LINK_LD_TAIL=} ;;
    SEED_LINK_PURE_OK=*) SEED_LINK_PURE_OK=${line#SEED_LINK_PURE_OK=} ;;
    SEED_LINK_OUT=*) SEED_LINK_OUT=${line#SEED_LINK_OUT=} ;;
    SEED_LINK_OBJS=*) SEED_LINK_OBJS=${line#SEED_LINK_OBJS=} ;;
    *)
      fail "unknown export line: $line"
      ;;
  esac
done <<EOF
$export_raw
EOF

if [ -z "$SEED_LINK_OUT" ] || [ -z "$SEED_LINK_OBJS" ]; then
  fail "incomplete export (OUT/OBJS) from $export_target"
  echo "$export_raw" >&2
fi
if [ -z "$SEED_LINK_CC" ] && [ -z "$SEED_LINK_LD" ]; then
  fail "incomplete export (CC/LD) from $export_target"
fi

n_objs=$(printf '%s\n' "$SEED_LINK_OBJS" | wc -w | tr -d ' ')

# ---------------------------------------------------------------------------
# Prefer pure-ld (wave772) when export says PURE_OK and not forced to CC.
# ---------------------------------------------------------------------------
try_pure_ld() {
  if [ "${XLANG_SEED_LINK_FORCE_CC:-0}" = "1" ]; then
    note "pure-ld skipped (XLANG_SEED_LINK_FORCE_CC=1)"
    return 1
  fi
  if [ "${SEED_LINK_PURE_OK:-0}" != "1" ]; then
    note "pure-ld skipped (SEED_LINK_PURE_OK=${SEED_LINK_PURE_OK:-0})"
    return 1
  fi
  # MULTIDEF from Makefile export is folded into pure_ld_try_link's host multidef
  # (same Darwin/Linux shape). ENTRY/TAIL still come from Makefile export authority.
  note "${MODE} pure-ld → $SEED_LINK_OUT  ($n_objs objs via pure_ld_shared)"
  if pure_ld_try_link "$SEED_LINK_OUT" "$SEED_LINK_OBJS" \
      "${SEED_LINK_ENTRY:-}" "${SEED_LINK_LD_TAIL:-}" "" "${SEED_LINK_LD:-}"; then
    note "OK pure-ld $SEED_LINK_OUT"
    return 0
  fi
  note "pure-ld failed; falling back to SEED_LINK_CC residual"
  return 1
}

if try_pure_ld; then
  exit 0
fi

# Residual: host CC driver (wave721 named residual; still valid when pure-ld ineligible)
if [ -z "$SEED_LINK_CC" ]; then
  fail "CC residual needed but SEED_LINK_CC empty"
fi
note "${MODE} link (CC residual) → $SEED_LINK_OUT  ($n_objs objs via Makefile export)"
# Word-split CFLAGS and OBJS intentionally (space-separated make expansions).
# shellcheck disable=SC2086
"$SEED_LINK_CC" $SEED_LINK_CFLAGS -o "$SEED_LINK_OUT" $SEED_LINK_OBJS

note "OK CC residual $SEED_LINK_OUT"
