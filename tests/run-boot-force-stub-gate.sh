#!/usr/bin/env bash
# BOOT-010：force_stub 6 风险处置 manifest 门禁
# wave309 honesty: ast_pool.c left — live PARSER_STUB_EQ =
# seeds/runtime_pipeline_abi.from_x.c. DOC archived under analysis/archive/boot/.
# Selfhost pause (2026-08-05): do NOT run xlang check as gate smoke.
# PLATFORM: SHARED archaeology.
#
# 1) archived boot-force-stub-v1.md + matrix + runtime_pipeline_abi seed
# 2) 6 符号在 parser.x 且 PARSER_STUB_EQ 在 abi seed
# 3) padding glue 锚点存在
# 4) 回归源存在；hooks 仍跑（check_only 自举期 SKIP）
#
# 用法：./tests/run-boot-force-stub-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_BOOT_FORCE_STUB_DOC:-analysis/archive/boot/boot-force-stub-v1.md}"
MEGA7_DOC="${XLANG_BOOT_MEGA7_GAP_DOC:-analysis/archive/boot/boot-mega7-gap.md}"
MATRIX="${XLANG_BOOT_FORCE_STUB_TSV:-tests/baseline/boot-force-stub-matrix.tsv}"
PARSER_X="compiler/src/parser/parser.x"
# Historical name AST_POOL; live body = runtime_pipeline_abi seed (wave309).
ABI_SEED="compiler/seeds/runtime_pipeline_abi.from_x.c"
THIN_C="compiler/seeds/parser_asm_thin_c.from_x.c"
MIN_STUB=6

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

echo "=== BOOT-010: force_stub manifest ==="
for f in \
  "$DOC" \
  "$MEGA7_DOC" \
  "$MATRIX" \
  "$PARSER_X" \
  "$ABI_SEED"; do
  if [ ! -f "$f" ]; then
    echo "boot-force-stub gate FAIL: missing $f" >&2
    exit 1
  fi
done
if [ -f compiler/ast_pool.c ]; then
  echo "boot-force-stub gate FAIL: compiler/ast_pool.c resurrected (wave309 left; dual authority)" >&2
  exit 1
fi
echo "boot-force-stub manifest OK (host=$(ci_host_summary))"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_stub_rows) MIN_STUB="$c2" ;; esac
done < "$MATRIX"

# ── 6 项符号 + PARSER_STUB_EQ ──
MISS=0
N=0
HOOKS=""
echo "=== BOOT-010: force_stub symbol check ==="
while IFS=$'\t' read -r stub_id sym _cause strategy reg_src reg_hook notes; do
  [ -z "${stub_id:-}" ] && continue
  case "$stub_id" in \#*|min_*) continue ;; esac
  N=$((N + 1))
  if ! grep -qE "function ${sym}\\(" "$PARSER_X" 2>/dev/null; then
    echo "boot-force-stub FAIL: function ${sym} not in $PARSER_X ($stub_id)" >&2
    MISS=$((MISS + 1))
  fi
  if ! grep -qF "PARSER_STUB_EQ(\"${sym}\"" "$ABI_SEED" 2>/dev/null; then
    echo "boot-force-stub FAIL: PARSER_STUB_EQ missing for ${sym} in $ABI_SEED" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "$reg_src" ]; then
    echo "boot-force-stub FAIL: missing regression $reg_src ($stub_id)" >&2
    MISS=$((MISS + 1))
  fi
  if [ -n "${reg_hook:-}" ] && [ "$reg_hook" != "check_only" ]; then
    case " $HOOKS " in
      *" $reg_hook "*) ;;
      *) HOOKS="$HOOKS $reg_hook" ;;
    esac
  fi
done < "$MATRIX"

if [ "$N" -lt "$MIN_STUB" ]; then
  echo "boot-force-stub gate FAIL: stub_rows=${N} < min ${MIN_STUB}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "boot-force-stub gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "boot-force-stub symbols OK (${N} stubs)"

# ── padding glue 锚点 ──
echo "=== BOOT-010: padding glue anchors ==="
for g in \
  parser_try_skip_allow_padding_struct_glue \
  parser_try_skip_allow_padding_struct_buf_glue; do
  if ! grep -qF "$g" "$THIN_C" 2>/dev/null && ! grep -qF "$g" "$ABI_SEED" 2>/dev/null; then
    echo "boot-force-stub FAIL: missing glue $g" >&2
    exit 1
  fi
done
echo "boot-force-stub glue OK"

# ── check_only：自举期暂停 xlang check 闸门（2026-08-05）──
# Manifest / PARSER_STUB_EQ / padding / non-check hooks remain hard.
echo "=== BOOT-010: check-only regression ==="
echo "boot-force-stub SKIP check-only (selfhost check gate paused 2026-08-05)"

XLANG_BIN="${XLANG:-}"
if [ -z "$XLANG_BIN" ]; then
  for cand in ./compiler/xlang-c ./compiler/xlang ./compiler/xlang_asm; do
    if native_xlang "$cand"; then
      XLANG_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$XLANG_BIN" ]; then
  echo "boot-force-stub SKIP hooks (no native xlang)"
  echo "boot-force-stub gate OK"
  exit 0
fi

FAILS=0
for hook in $HOOKS; do
  script="tests/${hook}"
  if [ ! -f "$script" ]; then
    echo "boot-force-stub FAIL: missing hook $script" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "── hook: $hook ──"
  chmod +x "$script" 2>/dev/null || true
  if XLANG="$XLANG_BIN" "$script"; then
    echo "boot-force-stub hook OK $hook"
  else
    echo "boot-force-stub hook FAIL $hook" >&2
    FAILS=$((FAILS + 1))
  fi
done

if [ "$FAILS" -gt 0 ]; then
  echo "boot-force-stub gate FAIL: ${FAILS} hook(s)" >&2
  exit 1
fi

echo "boot-force-stub gate OK"
