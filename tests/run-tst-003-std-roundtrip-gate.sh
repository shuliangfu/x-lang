#!/usr/bin/env bash
# TST-003：std round-trip 向量库门禁
#
# 验收：std-roundtrip.tsv 注册 base64/json/csv/compress 金样且烟测可运行。
#
# 用法：./tests/run-tst-003-std-roundtrip-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TST003_DOC:-analysis/tst-003-std-roundtrip-v1.md}"
MANIFEST="${SHUX_TST003_TSV:-tests/baseline/std-roundtrip.tsv}"
LIB="tests/lib/tst-003-std-roundtrip.sh"
MIN_VEC=4

# shellcheck source=tests/lib/tst-003-std-roundtrip.sh
. "$LIB"

echo "=== TST-003: std round-trip manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "tst-003-roundtrip gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in round-trip std-roundtrip base64 json csv compress; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "tst-003-roundtrip gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_vectors) MIN_VEC="$c2" ;; esac
done < "$MANIFEST"

miss="$(tst003_verify_manifest "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  tst003_emit_report "fail" 0 0 0
  echo "tst-003-roundtrip gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi
echo "tst-003-roundtrip manifest OK"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

VECTORS=0
PASS=0
SKIP=0
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== TST-003: round-trip smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  # Homebrew libzstd（macOS 常见）；无则链接受限时 SKIP。
  if [ -d /opt/homebrew/lib ]; then
    export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  elif [ -d /usr/local/lib ]; then
    export LIBRARY_PATH="/usr/local/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  fi
  while IFS=$'\t' read -r item_id kind _mod test_path needs_o _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|doc|lib|gate) continue ;; esac
    case "$kind" in
      roundtrip)
        VECTORS=$((VECTORS + 1))
        tst003_ensure_o "${needs_o:--}"
        rv=0
        tst003_run_vector "$SHUX_BIN" "$test_path" "$item_id" || rv=$?
        if [ "$rv" -eq 0 ]; then
          PASS=$((PASS + 1))
          echo "  OK ${item_id} (${test_path})"
        elif [ "$rv" -eq 2 ]; then
          SKIP=$((SKIP + 1))
          echo "  SKIP ${item_id} (link env: libzstd)" >&2
        else
          tst003_emit_report "fail" "$VECTORS" "$PASS" "$SKIP"
          exit 1
        fi
        ;;
    esac
  done < "$MANIFEST"
else
  echo "tst-003-roundtrip gate SKIP smoke (no native shux-c)" >&2
  SKIP=1
  while IFS=$'\t' read -r item_id kind _mod _test_path _needs_o _notes; do
    case "$kind" in roundtrip) VECTORS=$((VECTORS + 1)) ;; esac
  done < "$MANIFEST"
fi

if [ "$VECTORS" -lt "$MIN_VEC" ]; then
  echo "tst-003-roundtrip gate FAIL: vectors=${VECTORS} < min=${MIN_VEC}" >&2
  tst003_emit_report "fail" "$VECTORS" "$PASS" "$SKIP"
  exit 1
fi

if [ -n "$SHUX_BIN" ] && [ "$PASS" -eq 0 ] && [ "$SKIP" -gt 0 ]; then
  echo "tst-003-roundtrip gate OK (typeck+manifest; link SKIP libzstd)" >&2
fi

tst003_emit_report "ok" "$VECTORS" "$PASS" "$SKIP"
echo "tst-003-roundtrip gate OK"
