#!/usr/bin/env bash
# F-09 v1: whole-repo handwritten-C clearance audit (std/core + compiler/src track).
#
# Usage: ./tests/run-no-handwritten-c-gate.sh
# Env:
#   XLANG_NO_HANDWRITTEN_C_UPDATE=1     — refresh tests/baseline/no-handwritten-c-whitelist.tsv
#   XLANG_NO_HANDWRITTEN_C_STRICT=1     — zero-C终局 mode (currently red; CI reserved)
#   XLANG_NO_HANDWRITTEN_C_MANIFEST_ONLY=1 — whitelist + inventory only; skip product children
#
# 2026-08-25 / 2026-08-26: DOC → analysis/archive/phase/; refuse compiler/Makefile
# resurrect (use ./xbuild). Soft XLANG_NO_HANDWRITTEN_C_FAIL retired.
# 2026-08-27: Product dogfood children hard-delegate (retire soft WARN wrapper
# XLANG_F09_PRODUCT_FAIL). Root: children already honesty-hard (f04 crypto/net,
# f05, path/uuid/sort, e-soft); soft WARN→exit0 was portable false-green when a
# child red while archaeology knife claimed OK. Do NOT re-export retired child
# *_FAIL envs (XLANG_F_PATH_V1_FAIL / UUID / SORT). Prefer children' own prefer-asm.
# Report audit=/inventory=/crypto=/net=/db=/path=/g02f=/uuid=/sort=/e_soft=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

UPDATE=${XLANG_NO_HANDWRITTEN_C_UPDATE:-0}
STRICT=${XLANG_NO_HANDWRITTEN_C_STRICT:-0}
MANIFEST_ONLY=${XLANG_NO_HANDWRITTEN_C_MANIFEST_ONLY:-0}
DOC="${XLANG_F09_DOC:-analysis/archive/phase/phase-f-f09-v1.md}"
BASELINE="${XLANG_NO_HANDWRITTEN_C_TSV:-tests/baseline/no-handwritten-c-whitelist.tsv}"
PREFIX="xlang: [XLANG_F09_NHC]"

# shellcheck source=tests/lib/no-handwritten-c-audit.sh
. tests/lib/no-handwritten-c-audit.sh

AUDIT_OK=0
INVENTORY_OK=0
CRYPTO_OK=0
NET_OK=0
DB_OK=0
PATH_OK=0
G02F_OK=0
UUID_OK=0
SORT_OK=0
E_SOFT_OK=0
SKIP=1

die() {
  echo "no-handwritten-c gate FAIL: $*" >&2
  echo "${PREFIX} status=fail audit=${AUDIT_OK} inventory=${INVENTORY_OK} crypto=${CRYPTO_OK} net=${NET_OK} db=${DB_OK} path=${PATH_OK} g02f=${G02F_OK} uuid=${UUID_OK} sort=${SORT_OK} e_soft=${E_SOFT_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

run_sub() {
  local script="$1"
  chmod +x "$script"
  if ! "$script"; then
    die "sub-gate failed: $script"
  fi
}

echo "=== F-09 v1: no-handwritten-C audit (track mode; honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-09 v1' "$DOC" || die "doc missing F-09 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

if [ "$UPDATE" = "1" ]; then
  nhc_write_snapshot_tsv "$BASELINE"
  total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$BASELINE")
  echo "no-handwritten-c gate: updated $BASELINE (total=${total})"
  exit 0
fi

if [ ! -f "$BASELINE" ]; then
  nhc_write_snapshot_tsv "$BASELINE"
  total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$BASELINE")
  echo "no-handwritten-c gate: created baseline $BASELINE (total=${total})"
  exit 0
fi

export NHC_AUDIT_STRICT="$STRICT"
if ! nhc_audit_whitelist "$BASELINE"; then
  die "whitelist audit failed"
fi
AUDIT_OK=1

if [ "$MANIFEST_ONLY" = "1" ]; then
  SKIP=0
  echo "no-handwritten-c gate OK (manifest only)"
  echo "${PREFIX} status=ok audit=${AUDIT_OK} inventory=0 crypto=0 net=0 db=0 path=0 g02f=0 uuid=0 sort=0 e_soft=0 skip=${SKIP} host=$(ci_host_summary) mode=manifest"
  exit 0
fi

echo "=== F-09 v1: delegate run-std-c-inventory-gate (hard) ==="
run_sub tests/run-std-c-inventory-gate.sh
INVENTORY_OK=1

# Product dogfood: hard-delegate. Soft XLANG_F09_PRODUCT_FAIL retired.
# Children already honesty-hard; do NOT re-export retired child *_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-f04-std-crypto-closure-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f04-std-crypto-closure-gate (hard) ==="
  run_sub tests/run-f04-std-crypto-closure-gate.sh
  CRYPTO_OK=1
fi

if [ -f tests/run-f04-std-net-closure-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f04-std-net-closure-gate (hard) ==="
  run_sub tests/run-f04-std-net-closure-gate.sh
  NET_OK=1
fi

if [ -f tests/run-f05-std-db-closure-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f05-std-db-closure-gate (hard) ==="
  run_sub tests/run-f05-std-db-closure-gate.sh
  DB_OK=1
fi

if [ -f tests/run-f-path-v1-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f-path-v1-gate (hard) ==="
  run_sub tests/run-f-path-v1-gate.sh
  PATH_OK=1
fi

echo "=== F-09 / G-02f: delegate run-g02f-src-no-inc-gate (src .inc=0; hard) ==="
run_sub tests/run-g02f-src-no-inc-gate.sh
G02F_OK=1

if [ -f tests/run-f-uuid-v1-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f-uuid-v1-gate (hard) ==="
  run_sub tests/run-f-uuid-v1-gate.sh
  UUID_OK=1
fi

if [ -f tests/run-f-sort-v1-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f-sort-v1-gate (hard) ==="
  run_sub tests/run-f-sort-v1-gate.sh
  SORT_OK=1
fi

if [ -f tests/run-e-soft-retire-gate.sh ]; then
  echo "=== F-09 v1: delegate run-e-soft-retire-gate (compiler C track; hard) ==="
  chmod +x tests/run-e-soft-retire-gate.sh
  # Hard-delegate; soft XLANG_E_SOFT_FAIL retired. Manifest-only keeps F-09
  # archaeology from re-dogfooding full E-soft product children.
  if ! XLANG_E_SOFT_MANIFEST_ONLY=1 tests/run-e-soft-retire-gate.sh; then
    die "e-soft manifest sub-gate failed"
  fi
  E_SOFT_OK=1
fi

SKIP=0
echo "no-handwritten-c gate OK (F-09 v1 track; honesty; run XLANG_NO_HANDWRITTEN_C_STRICT=1 for zero-C终局)"
echo "${PREFIX} status=ok audit=${AUDIT_OK} inventory=${INVENTORY_OK} crypto=${CRYPTO_OK} net=${NET_OK} db=${DB_OK} path=${PATH_OK} g02f=${G02F_OK} uuid=${UUID_OK} sort=${SORT_OK} e_soft=${E_SOFT_OK} skip=${SKIP} host=$(ci_host_summary)"
