#!/usr/bin/env bash
# ensure_cp_alias_o.sh — product object-path cp-alias leaves (11.3.1 · wave836)
#
# Authority (G.7 无才新增):
#   Single shell body for Makefile leaves that only `cp` one product `.o` onto
#   another path (alias / freestanding link-name wrappers). Makefile prereqs are
#   FORCE + this script only (no make-graph edge on SRC). Shell owns:
#     - catalog OUT|SRC (one table; Makefile must not re-list)
#     - try-heat SRC when missing (heat authority stays ensure_host_cc_seed_o)
#     - mtime skip (SRC -nt OUT; XLANG_CP_ALIAS_FORCE=1 always recopy)
#   NOT physical delete of compiler/Makefile.
#
# Catalog (COUNT=3):
#   ast_x.o              ← src/ast/ast_seed.o          (SHARED G-02a C ABI alias)
#   crt0_user.o          ← src/asm/crt0_user_x86_64.o  (PLATFORM: x86_64 freestanding)
#   freestanding_io.o    ← src/asm/freestanding_io_x86_64.o
#
# Usage (cwd = compiler/):
#   bash scripts/ensure_cp_alias_o.sh ensure OUT.o
#   bash scripts/ensure_cp_alias_o.sh list
#   bash scripts/ensure_cp_alias_o.sh --check
#
# Env:
#   XLANG_CP_ALIAS_FORCE=1 — always cp (ignore mtime)
#   CC / CFLAGS — forwarded to try-heat when SRC is missing
#
# PLATFORM: SHARED script; freestanding wrappers are product-useful on x86_64
# (Makefile rules for those two stay under UNAME_M=x86_64). Mac arm64 still
# has the shared ast_x.o alias leaf.
#
# Wave: 836 Track MG · pairs with Makefile FORCE leaves.
# wave920: 3 per-leaf recipes → 2 multi-target rules (1 SHARED + 1 Linux x86_64 guard).
#   Lists: CP_ALIAS_SHARED_OBJS (ast_x.o) + CP_ALIAS_LINUX_X86_64_OBJS (crt0_user.o
#   freestanding_io.o) in mk/driver_seed_r_lists.mk. Body = @bash ensure $@.

set -euo pipefail

_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_self="$_script_dir/$(basename "$0")"
_compiler_dir="$(CDPATH= cd -- "$_script_dir/.." && pwd)"
cd "$_compiler_dir"

TAG="ensure_cp_alias_o"
FORCE="${XLANG_CP_ALIAS_FORCE:-0}"

# OUT|SRC — single catalog authority (G.7; Makefile must not re-list).
CATALOG='
ast_x.o|src/ast/ast_seed.o
crt0_user.o|src/asm/crt0_user_x86_64.o
freestanding_io.o|src/asm/freestanding_io_x86_64.o
'

usage() {
  echo "usage: $TAG ensure OUT.o | list | --check" >&2
  exit 2
}

log() { echo "${TAG}: $*" >&2; }

catalog_lookup() {
  # $1 = OUT → sets SRC_O
  local out="$1" line
  SRC_O=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    if [ "${line%%|*}" = "$out" ]; then
      SRC_O="${line#*|}"
      return 0
    fi
  done <<EOF
$CATALOG
EOF
  return 1
}

catalog_count() {
  local n=0 line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    n=$((n + 1))
  done <<EOF
$CATALOG
EOF
  echo "$n"
}

need_rebuild() {
  # $1=SRC $2=OUT
  local src="$1" out="$2"
  if [ "$FORCE" = "1" ]; then
    return 0
  fi
  if [ ! -f "$out" ]; then
    return 0
  fi
  if [ ! -f "$src" ]; then
    return 0
  fi
  if [ "$src" -nt "$out" ]; then
    return 0
  fi
  return 1
}

ensure_src_via_try_heat() {
  local src="$1"
  if [ -f scripts/ensure_host_cc_seed_o.sh ]; then
    # PLATFORM: SHARED — try-heat builds catalog heat leaves; exit 3 = not owned.
    if ! CC="${CC:-}" CFLAGS="${CFLAGS:-}" \
      bash scripts/ensure_host_cc_seed_o.sh try-heat "$src" 2>/dev/null; then
      _rc=$?
      if [ "$_rc" -eq 3 ]; then
        : # not ensure-owned; require prebuilt SRC
      elif [ "$_rc" -ne 0 ]; then
        log "try-heat $src failed (rc=$_rc)"
        return 1
      fi
    fi
  fi
  if [ ! -f "$src" ]; then
    log "missing SRC $src after try-heat"
    return 1
  fi
  return 0
}

run_cp() {
  local src="$1" out="$2"
  if [ ! -f "$src" ]; then
    log "FAIL missing SRC $src"
    return 1
  fi
  # PLATFORM: SHARED — atomic-ish: cp to tmp then mv when paths differ.
  local tmp="${out}.tmp.$$"
  if ! cp -f "$src" "$tmp"; then
    rm -f "$tmp"
    log "FAIL cp $src → $tmp"
    return 1
  fi
  if ! mv -f "$tmp" "$out"; then
    rm -f "$tmp"
    log "FAIL mv $tmp → $out"
    return 1
  fi
  log "cp $src → $out"
  return 0
}

ensure_one() {
  local out="$1"
  if ! catalog_lookup "$out"; then
    log "unknown OUT $out (not in cp-alias catalog)"
    return 1
  fi
  # Heat SRC only when missing — avoid re-try-heat on every FORCE when OUT fresh.
  if [ ! -f "$SRC_O" ]; then
    ensure_src_via_try_heat "$SRC_O" || return 1
  fi
  if ! need_rebuild "$SRC_O" "$out"; then
    log "skip up-to-date $out"
    return 0
  fi
  run_cp "$SRC_O" "$out"
}

do_list() {
  local line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    printf '%s\n' "$line"
  done <<EOF
$CATALOG
EOF
}

do_check() {
  local n exp=3 line out src fail=0
  n="$(catalog_count)"
  if [ "$n" -ne "$exp" ]; then
    log "FAIL catalog count $n expected $exp"
    fail=1
  fi
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    out="${line%%|*}"
    src="${line#*|}"
    if [ -z "$out" ] || [ -z "$src" ] || [ "$out" = "$src" ]; then
      log "FAIL bad catalog row: $line"
      fail=1
      continue
    fi
    if [ "${out##*.}" != "o" ] || [ "${src##*.}" != "o" ]; then
      log "FAIL catalog row must be .o paths: $line"
      fail=1
    fi
  done <<EOF
$CATALOG
EOF
  # Self path absolute so re-exec after cd works.
  if [ ! -x "$_self" ] && [ ! -f "$_self" ]; then
    log "FAIL missing self $_self"
    fail=1
  fi
  if [ "$fail" -ne 0 ]; then
    return 1
  fi
  log "CHECK OK (catalog n=$n; wave836/920 FORCE thin multi-target; not physical delete)"
  return 0
}

MODE="${1:-}"
case "$MODE" in
  ensure|auto)
    [ -n "${2:-}" ] || usage
    ensure_one "$2"
    ;;
  list)
    do_list
    ;;
  --check)
    do_check
    ;;
  *)
    usage
    ;;
esac
