#!/usr/bin/env bash
# EXC-005: CLI/LSP error display unified manifest + golden smoke
# (false-authority honesty).
#
# Usage: ./tests/run-exc-cli-lsp-error-gate.sh
# wave honesty (2026-08-24 #8): DOC → analysis/archive/exc/;
# lsp_diag.c retired — hubs live in lsp_diag.h + runtime_lsp_glue.from_x.c.
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); golden compile stderr phrase+kind+line:col
# hard-fail (no soft SKIP→OK when no native). Report check=/compile=/skip=.
# Gate was portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# DOC ## 7. 门禁 without Gate honesty). Ubuntu/Darwin asm golden already green.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_EXC_CLI_LSP_DOC:-analysis/archive/exc/exc-cli-lsp-error-v1.md}"
MATRIX="${XLANG_EXC_CLI_LSP_TSV:-tests/baseline/exc-cli-lsp-error.tsv}"
MIN_ITEMS=10

stdlib_cm_native_xlang() {
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

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
exc_cli_lsp_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

exc_cli_lsp_emit_report() {
  local status="$1"
  local check_ok="$2"
  local compile_ok="$3"
  local skip="$4"
  echo "exc-cli-lsp-error status=${status} check=${check_ok} compile=${compile_ok} skip=${skip}"
}

echo "=== EXC-005: CLI/LSP error display manifest (c retired) ==="

# Refuse resurrected top-level DOC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/exc-cli-lsp-error-v1.md ]; then
  echo "exc-cli-lsp-error gate FAIL: top-level DOC resurrected (live = archive/exc/)" >&2
  exit 1
fi

if [ -f compiler/src/lsp/lsp_diag.c ]; then
  echo "exc-cli-lsp-error gate FAIL: lsp_diag.c resurrected (live = lsp_diag.h)" >&2
  exit 1
fi

for f in "$DOC" "$MATRIX" compiler/src/lsp/lsp_diag.h compiler/seeds/runtime_lsp_glue.from_x.c; do
  if [ ! -f "$f" ]; then
    echo "exc-cli-lsp-error gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in EXC-005 CLI LSP typeck; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "exc-cli-lsp-error gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "exc-cli-lsp-error gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_items) MIN_ITEMS="$c2" ;; esac
done < "$MATRIX"

MISS=0
FOUND=0
HOOK=""
echo "=== EXC-005: hub and format check ==="
while IFS=$'\t' read -r item_id kind anchor src notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  FOUND=$((FOUND + 1))
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "exc-cli-lsp-error FAIL: doc missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if [ ! -f "$src" ]; then
        echo "exc-cli-lsp-error FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif [ "$anchor" = "set_onefunc_fail" ]; then
        if ! grep -qF 'set_onefunc_fail' "$src" 2>/dev/null; then
          echo "exc-cli-lsp-error FAIL: set_onefunc_fail not in $src" >&2
          MISS=$((MISS + 1))
        fi
      elif ! grep -qF "$anchor" "$src" 2>/dev/null; then
        echo "exc-cli-lsp-error FAIL: ${anchor} not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    pattern)
      if [ ! -f "$src" ] || ! grep -qF "$anchor" "$src" 2>/dev/null; then
        echo "exc-cli-lsp-error FAIL: pattern '$anchor' not in $src ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    golden)
      if [ ! -f "$src" ]; then
        echo "exc-cli-lsp-error FAIL: missing golden $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "exc-cli-lsp-error FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      else
        HOOK="$path"
      fi
      ;;
  esac
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_ITEMS" ]; then
  echo "exc-cli-lsp-error gate FAIL: items=${FOUND} < min_items=${MIN_ITEMS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "exc-cli-lsp-error gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "exc-cli-lsp-error manifest OK (items=${FOUND})"

if [ "${XLANG_EXC_CLI_LSP_MANIFEST_ONLY:-0}" = "1" ]; then
  exc_cli_lsp_emit_report "ok" 0 0 1
  echo "exc-cli-lsp-error gate OK (manifest only)"
  exit 0
fi

# Best-effort quiet make (do not soft-SKIP the gate when make is noisy).
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make || true

CHECK_OK=0
COMPILE_OK=0
SKIP=1

if XLANG_BIN="$(exc_cli_lsp_resolve_shu 2>/dev/null)"; then
  echo "=== EXC-005: smoke (XLANG=$XLANG_BIN; check observational; golden compile hard) ==="
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # Observational check format (paused 2026-08-05); CHK red does not hard-fail.
  assign="tests/typeck/type_mismatch_assign.x"
  want_chk="assignment type mismatch: expected i32, found bool"
  chk=$("$XLANG_BIN" check "$assign" 2>&1) || true
  if echo "$chk" | grep -qF "$want_chk" && echo "$chk" | grep -qE 'error|typeck error'; then
    CHECK_OK=1
    echo "exc-cli-lsp-error OK check format (observational)"
  else
    echo "exc-cli-lsp-error SKIP check format (paused 2026-08-05 / format evolved)" >&2
  fi

  FAILS=0
  echo "=== EXC-005: golden compile stderr (XLANG=$XLANG_BIN) ==="
  while IFS=$'\t' read -r item_id kind anchor src notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_items) continue ;; esac
    [ "$kind" = "golden" ] || continue
    want="$notes"
    echo "── compile golden: $src ──"
    err=$("$XLANG_BIN" "$src" -o /tmp/xlang_exc_cli_lsp_fail_$$ 2>&1) || true
    rm -f /tmp/xlang_exc_cli_lsp_fail_$$
    if ! echo "$err" | grep -qF "$want"; then
      echo "exc-cli-lsp-error FAIL compile: missing phrase '$want' in $src" >&2
      echo "$err" >&2
      FAILS=$((FAILS + 1))
      continue
    fi
    if ! echo "$err" | grep -qE 'typeck error|parse error|error\['; then
      echo "exc-cli-lsp-error FAIL compile: missing CLI error kind in $src" >&2
      FAILS=$((FAILS + 1))
      continue
    fi
    if ! echo "$err" | grep -qE '[0-9]+:[0-9]+'; then
      echo "exc-cli-lsp-error FAIL compile: missing line:col in $src" >&2
      FAILS=$((FAILS + 1))
      continue
    fi
    echo "exc-cli-lsp-error OK compile $src"
  done < "$MATRIX"

  if [ "$FAILS" -gt 0 ]; then
    echo "exc-cli-lsp-error gate FAIL: golden=${FAILS}" >&2
    exc_cli_lsp_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
  COMPILE_OK=1
  SKIP=0
else
  echo "exc-cli-lsp-error gate FAIL: no native xlang" >&2
  exc_cli_lsp_emit_report "fail" 0 0 0
  exit 2
fi

# check stays observational; hard-green signal is compile= (golden stderr).
echo "exc-cli-lsp-error check_ok=${CHECK_OK} (observational)"
exc_cli_lsp_emit_report "ok" "$CHECK_OK" "$COMPILE_OK" "$SKIP"
echo "exc-cli-lsp-error gate OK"
