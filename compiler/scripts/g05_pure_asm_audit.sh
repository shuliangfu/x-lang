#!/bin/sh
# Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# w1485: g05 pure-asm audit. ensure is incremental, so an object that once
# fell back to host cc (g05_try_x_to_o: pure-asm failed, then -E + $CC) stays
# a cc object forever and nothing says so. This compiles every .x source that
# g05_ensure_relink_prereqs.sh routes through the pure-asm path with the
# current product (`-backend asm -c`, timeout per file) and classifies it:
#   ok     pure asm emits a non-empty object
#   fail   compiler reports an error (host cc would be used instead)
#   crash  compiler died on a signal or timed out
# Known debt is listed per platform in scripts/g05_cc_fallback_baseline.txt
# ("<uname-s> <src>", Windows for MINGW/MSYS). Exit 1 when a source not in the
# baseline fails or crashes (a new silent cc fallback). A baseline entry that
# now passes is printed so it can be removed. PLATFORM: SHARED.
#
# Usage: sh scripts/g05_pure_asm_audit.sh [product]   (default ./xlang_asm)
set -u
cd "$(dirname "$0")/.."
xl="${1:-${XLANG:-./xlang_asm}}"
[ -x "$xl" ] || { [ -x "$xl.exe" ] && xl="$xl.exe"; }
if [ ! -x "$xl" ]; then
  echo "g05_pure_asm_audit: no product at $xl" >&2
  exit 2
fi
os="$(uname -s 2>/dev/null || echo Unknown)"
case "$os" in MINGW*|MSYS*|CYGWIN*) os=Windows ;; esac
base=scripts/g05_cc_fallback_baseline.txt
tmo="${G05_AUDIT_TIMEOUT:-180}"
out="${G05_AUDIT_DIR:-${TMPDIR:-/tmp}/g05_pure_asm_audit.$$}"
mkdir -p "$out"
run_to() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$tmo" "$@"
  else
    perl -e 'alarm shift; exec @ARGV' "$tmo" "$@"
  fi
}
srcs=$(sed -n 's/^[[:space:]]*_\(pthin_p[0-9a-z]*\|pel\|diag_thin\|xsb\)_x=\(src\/[A-Za-z0-9_/]*\.x\).*/\2/p' \
  scripts/g05_ensure_relink_prereqs.sh | sort -u)
if [ -z "$srcs" ]; then
  srcs=$(grep -E '^[[:space:]]*_(pthin_p[0-9a-z]+|pel|diag_thin|xsb)_x=src/' scripts/g05_ensure_relink_prereqs.sh \
    | sed 's/.*=\(src\/[A-Za-z0-9_/]*\.x\).*/\1/' | sort -u)
fi
n_ok=0 n_known=0 n_new=0 n_fixed=0
for s in $srcs; do
  [ -f "$s" ] || continue
  o="$out/$(echo "$s" | tr '/' '_').o"
  rm -f "$o"
  run_to "$xl" -backend asm -c "$s" -o "$o" >"$o.log" 2>&1
  rc=$?
  if [ "$rc" -eq 0 ] && [ -s "$o" ]; then
    st=ok
    if nm -u "$o" 2>/dev/null | grep -E 'xlang_panic|^__error$' >/dev/null 2>&1; then
      st=fail
    fi
  elif [ "$rc" -eq 124 ] || [ "$rc" -ge 128 ]; then
    st=crash
  else
    st=fail
  fi
  known=0
  if [ -f "$base" ] && grep -qx "$os $s" "$base" 2>/dev/null; then
    known=1
  fi
  if [ "$st" = ok ]; then
    n_ok=$((n_ok + 1))
    if [ "$known" = 1 ]; then
      n_fixed=$((n_fixed + 1))
      echo "FIXED  $s (pure asm now emits; remove \"$os $s\" from $base)"
    else
      echo "ok     $s"
    fi
  elif [ "$known" = 1 ]; then
    n_known=$((n_known + 1))
    echo "known  $s ($st rc=$rc, baseline cc debt)"
  else
    n_new=$((n_new + 1))
    echo "NEW    $s ($st rc=$rc) log=$o.log"
  fi
done
echo "g05_pure_asm_audit: host=$os ok=$n_ok known=$n_known new=$n_new fixed=$n_fixed product=$xl"
[ "$n_new" -eq 0 ]
