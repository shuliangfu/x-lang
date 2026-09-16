#!/usr/bin/env bash
# F-crypto v1: std.crypto into F aggregate batch (F-04 v16～v21 already closed).
#
# Usage: ./tests/run-f-crypto-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-crypto-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# F-04 closure + STD-049 aes-gcm + STD-050 sha512-hmac hard delegate.
# Soft XLANG_F_CRYPTO_V1_FAIL retired. Root: soft die→exit0 = portable
# false-green (static+f04+aes+sha512 already green; STD-113 chacha /
# STD-126 ed25519 still prefer-c / ## 门禁 / product residual).
# chacha／ed25519 observational (not product root-fix this wave).
# Report static=/ensure=/f04=/aes=/sha512=/chacha=/ed25519=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested f04-std-crypto-closure / leftover nested
# std-crypto-aes-gcm / leftover nested std-crypto-sha512-hmac /
# leftover nested observational chacha / leftover nested
# observational ed25519; refuse leftover ignore of explicit-bad).
# leftover auto-make of crypto.o (`xlang_compiler_make` even when the
# leaf is present — try-heat/g05 raced L2) retired. leftover unused
# compiler-make.sh sourced unused after leftover auto-make retired.
# Missing leaf .o = hard die. leftover nested f04-std-crypto-closure /
# leftover nested std-crypto-aes-gcm / leftover nested
# std-crypto-sha512-hmac stay. leftover nested observational chacha /
# leftover nested observational ed25519 stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-crypto-v1.md"
MANIFEST="tests/baseline/f-crypto-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_CRYPTO_V1]"

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-crypto-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} f04=${F04_OK:-0} aes=${AES_OK:-0} sha512=${SHA512_OK:-0} chacha=${CHACHA_OK:-0} ed25519=${ED25519_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
F04_OK=0
AES_OK=0
SHA512_OK=0
CHACHA_OK=0
ED25519_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested f04-std-crypto-closure / leftover nested
# std-crypto-aes-gcm / leftover nested std-crypto-sha512-hmac /
# leftover nested observational chacha / leftover nested
# observational ed25519 (refuse leftover SKIP→OK / leftover ignore of
# explicit-bad / leftover XLANG fallthrough). leftover auto-make of
# crypto.o retired; leftover nested f04-std-crypto-closure /
# leftover nested std-crypto-aes-gcm / leftover nested
# std-crypto-sha512-hmac stay. leftover nested observational chacha /
# leftover nested observational ed25519 stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-crypto v1: F-04 closure → F batch (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-crypto v1' "$DOC" || die "doc missing F-crypto v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/crypto/core.x ] || die "missing std/crypto/core.x"
[ ! -f std/crypto/crypto.c ] || die "std/crypto/crypto.c should stay deleted"
[ -f compiler/seeds/runtime_crypto_inc_glue.from_x.c ] || die "missing runtime_crypto_inc_glue.from_x.c"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

# leftover auto-make retired: require the leaf already present (refuse try-heat/g05).
# PLATFORM: SHARED — missing leaf = hard die; Ubuntu gold still required.
if [ ! -f std/crypto/crypto.o ]; then
  die "missing std/crypto/crypto.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

# Hard-delegate already soft→硬绿 F-04 closure + STD-049 / STD-050.
# Do NOT export retired XLANG_F_CRYPTO_V1_FAIL / XLANG_F04_CRYPTO_*_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-f04-std-crypto-closure-gate.sh ]; then
  echo "=== F-crypto v1: delegate run-f04-std-crypto-closure-gate (hard) ==="
  chmod +x tests/run-f04-std-crypto-closure-gate.sh
  if ! tests/run-f04-std-crypto-closure-gate.sh; then
    die "f04-crypto-closure sub-gate failed"
  fi
  F04_OK=1
else
  die "missing tests/run-f04-std-crypto-closure-gate.sh"
fi

if [ -f tests/run-std-crypto-aes-gcm-gate.sh ]; then
  echo "=== F-crypto v1: delegate run-std-crypto-aes-gcm-gate (hard) ==="
  chmod +x tests/run-std-crypto-aes-gcm-gate.sh
  if ! tests/run-std-crypto-aes-gcm-gate.sh; then
    die "std-crypto-aes-gcm sub-gate failed"
  fi
  AES_OK=1
else
  die "missing tests/run-std-crypto-aes-gcm-gate.sh"
fi

if [ -f tests/run-std-crypto-sha512-hmac-gate.sh ]; then
  echo "=== F-crypto v1: delegate run-std-crypto-sha512-hmac-gate (hard) ==="
  chmod +x tests/run-std-crypto-sha512-hmac-gate.sh
  if ! tests/run-std-crypto-sha512-hmac-gate.sh; then
    die "std-crypto-sha512-hmac sub-gate failed"
  fi
  SHA512_OK=1
else
  die "missing tests/run-std-crypto-sha512-hmac-gate.sh"
fi

# STD-113 / STD-126 observational: still prefer-c / ## 门禁 / product residual
# (ed25519／chacha listed as UNDEF／product-red skip — not soft FAIL wrap).
if [ -f tests/run-std-crypto-chacha20-poly1305-gate.sh ]; then
  echo "=== F-crypto v1: std-crypto-chacha20-poly1305 (observational) ==="
  chmod +x tests/run-std-crypto-chacha20-poly1305-gate.sh
  if tests/run-std-crypto-chacha20-poly1305-gate.sh; then
    CHACHA_OK=1
  else
    echo "f-crypto-v1 WARN: chacha20-poly1305 failed (observational)" >&2
    CHACHA_OK=0
  fi
fi

if [ -f tests/run-std-crypto-ed25519-gate.sh ]; then
  echo "=== F-crypto v1: std-crypto-ed25519 (observational) ==="
  chmod +x tests/run-std-crypto-ed25519-gate.sh
  if tests/run-std-crypto-ed25519-gate.sh; then
    ED25519_OK=1
  else
    echo "f-crypto-v1 WARN: ed25519 failed (observational)" >&2
    ED25519_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} f04=${F04_OK} aes=${AES_OK} sha512=${SHA512_OK} chacha=${CHACHA_OK} ed25519=${ED25519_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-crypto-v1 gate OK (F-crypto v1; honesty)"
