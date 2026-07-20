#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
# PLATFORM: SHARED — C backend prelinks crypto.o (std_crypto_sha256/hmac/mem_eq).
# SHUX_SKIP_SUBSCRIPT_MAKE must not skip this ensure. Stale/partial crypto.o
# (mtime ok but missing std_crypto_*) → mac L4 UNDEF; force rebuild if gate fails.
make -C compiler -q ../std/crypto/crypto.o 2>/dev/null \
  || make -C compiler ../std/crypto/crypto.o
if ! nm std/crypto/crypto.o 2>/dev/null | grep -q 'std_crypto_sha256'; then
  echo "run-crypto: crypto.o missing std_crypto_sha256 — force rebuild" >&2
  rm -f std/crypto/crypto.o
  make -C compiler ../std/crypto/crypto.o
fi
# libm/inc glue for crypto_*_c UNDEF from bare-impl bodies
make -C compiler -q runtime_crypto_inc_glue.o 2>/dev/null \
  || make -C compiler runtime_crypto_inc_glue.o
SHUX="${SHUX:-./compiler/shux}"
exe="/tmp/shux_crypto_$$"
if ! $SHUX build -L . tests/crypto/main.x -o "$exe" 2>&1; then echo "crypto test: compile failed"; rm -f "$exe"; exit 1; fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then echo "crypto test: expected exit 0, got $exitcode"; exit 1; fi
echo "crypto test OK"
