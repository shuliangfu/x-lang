#!/usr/bin/env bash
# BOOT-010：force_stub 6 风险处置 manifest 门禁
#
# 1) boot-force-stub-v1.md + matrix + ast_pool.c
# 2) 6 符号在 parser.su 且 PARSER_STUB_EQ 在 ast_pool.c
# 3) padding glue 锚点存在
# 4) 回归源存在；有 shu 时 check 烟测
#
# 用法：./tests/run-boot-force-stub-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHU_BOOT_FORCE_STUB_TSV:-tests/baseline/boot-force-stub-matrix.tsv}"
PARSER_SU="compiler/src/parser/parser.su"
AST_POOL="compiler/ast_pool.c"
THIN_C="compiler/src/asm/parser_asm_thin_c.c"
MIN_STUB=6

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

native_shu() {
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
  analysis/boot-force-stub-v1.md \
  analysis/boot-mega7-gap.md \
  "$MATRIX" \
  "$PARSER_SU" \
  "$AST_POOL"; do
  if [ ! -f "$f" ]; then
    echo "boot-force-stub gate FAIL: missing $f" >&2
    exit 1
  fi
done
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
  if ! grep -qE "function ${sym}\\(" "$PARSER_SU" 2>/dev/null; then
    echo "boot-force-stub FAIL: function ${sym} not in $PARSER_SU ($stub_id)" >&2
    MISS=$((MISS + 1))
  fi
  if ! grep -qF "PARSER_STUB_EQ(\"${sym}\"" "$AST_POOL" 2>/dev/null; then
    echo "boot-force-stub FAIL: PARSER_STUB_EQ missing for ${sym} in $AST_POOL" >&2
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
  if ! grep -qF "$g" "$THIN_C" 2>/dev/null && ! grep -qF "$g" "$AST_POOL" 2>/dev/null; then
    echo "boot-force-stub FAIL: missing glue $g" >&2
    exit 1
  fi
done
echo "boot-force-stub glue OK"

# ── check_only 烟测（有 shu）──
SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== BOOT-010: check-only regression (SHU=$SHU_BIN) ==="
  while IFS=$'\t' read -r stub_id _s _c _st reg_src reg_hook _n; do
    [ -z "${stub_id:-}" ] && continue
    case "$stub_id" in \#*|min_*) continue ;; esac
    [ "$reg_hook" = "check_only" ] || continue
    echo "── check: $reg_src ($stub_id) ──"
    if ! "$SHU_BIN" check "$reg_src" >/tmp/boot_force_stub_check.log 2>&1; then
      cat /tmp/boot_force_stub_check.log >&2
      echo "boot-force-stub FAIL: check $reg_src ($stub_id)" >&2
      exit 1
    fi
  done < "$MATRIX"
  echo "boot-force-stub check-only OK"
else
  echo "boot-force-stub SKIP check/hooks (no native shu)"
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
  if SHU="$SHU_BIN" "$script"; then
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
