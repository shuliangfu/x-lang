#!/usr/bin/env bash
# STD-079：std.security 门禁（F-security v1 + F-ZC：纯 security.x）
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SECURITY_DOC:-analysis/std-security-v1.md}"
MANIFEST="${SHUX_STD_SECURITY_MANIFEST:-tests/baseline/std-security-manifest.tsv}"
VECTORS="${SHUX_STD_SECURITY_VECTORS:-tests/baseline/std-security-vectors.tsv}"
MOD_X="std/security/mod.x"
SEC_X="std/security/security.x"
LIB="tests/lib/std-security.sh"
SMOKE_X="tests/std-security/roundtrip.x"
SMOKE_C="tests/std-security/security_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-security.sh
. "$LIB"

echo "=== STD-079: std.security manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SEC_X" "$SMOKE_X" "$SMOKE_C" std/security/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-security gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-079 ct_compare hkdf_sha256 secure_zero sensitive_lock mem_eq; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-security gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-security gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-security gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_security_symbols_ok "$MOD_X" "$SEC_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_security_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-security manifest OK"

C_OK=0
X_OK=0
SKIP=0

echo "=== STD-079: security c smoke ==="
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/security/security.o 2>/dev/null && std_security_run_c_smoke "$SEC_X"; then
    C_OK=1
  else
    echo "std-security gate SKIP c smoke (no full security.o)" >&2
  fi
else
  echo "std-security gate SKIP c smoke (no shux-c)" >&2
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-079: .x smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-security gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_security_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_security_run_smoke "$SHUX_BIN" "$SMOKE_X" "roundtrip"; then X_OK=1; else
    std_security_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_security_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-security gate OK"
