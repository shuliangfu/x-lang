#!/usr/bin/env bash
# EXC-005: CLI/LSP error display — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft SKIP→OK
# (no native still gate OK) + prefer-c / bootstrap-link wrap retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make).
# Golden compile stderr phrase+kind+line:col = hard run; check format = obs
# (check gate paused 2026-08-05). Report: run=/obs=/skip=.
# DOC → analysis/archive/exc/; lsp_diag.c retired.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-exc-cli-lsp-error-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_EXC_CLI_LSP_DOC:-analysis/archive/exc/exc-cli-lsp-error-v1.md}"
MATRIX="${XLANG_EXC_CLI_LSP_TSV:-tests/baseline/exc-cli-lsp-error.tsv}"
MIN_ITEMS=10
PREFIX="${XLANG_EXC_CLI_LSP_PREFIX:-exc-cli-lsp-error}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "exc-cli-lsp-error gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== EXC-005: CLI/LSP error display (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="

# Refuse resurrected top-level DOC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/exc-cli-lsp-error-v1.md ]; then
  die "top-level DOC resurrected (live = archive/exc/)"
fi
if [ -f compiler/src/lsp/lsp_diag.c ]; then
  die "lsp_diag.c resurrected (live = lsp_diag.h)"
fi

for f in "$DOC" "$MATRIX" compiler/src/lsp/lsp_diag.h compiler/seeds/runtime_lsp_glue.from_x.c; do
  [ -f "$f" ] || die "missing $f"
done

for kw in EXC-005 CLI LSP typeck; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 7. Gate' "$DOC" 2>/dev/null || die "doc missing '## 7. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_items) MIN_ITEMS="$c2" ;; esac
done < "$MATRIX"

MISS=0
FOUND=0
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
      fi
      ;;
  esac
done < "$MATRIX"

[ "$FOUND" -ge "$MIN_ITEMS" ] || die "items=${FOUND} < min_items=${MIN_ITEMS}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "exc-cli-lsp-error manifest OK (items=${FOUND})"

if [ "${XLANG_EXC_CLI_LSP_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  ok_report
  echo "exc-cli-lsp-error gate OK (manifest only)"
  exit 0
fi

# Refuse soft auto-make — require existing native product binary.
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

echo "=== EXC-005: smoke (check observational; golden compile hard) ==="
# Observational check format (paused 2026-08-05); CHK red does not hard-fail.
assign="tests/typeck/type_mismatch_assign.x"
want_chk="assignment type mismatch: expected i32, found bool"
set +e
chk=$("$XLANG_BIN" check "$assign" 2>&1)
set -e
if echo "$chk" | grep -qF "$want_chk" && echo "$chk" | grep -qE 'error|typeck error'; then
  echo "exc-cli-lsp-error OK check format (observational pass)"
else
  echo "exc-cli-lsp-error OBS check format (paused 2026-08-05 / format evolved; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

FAILS=0
echo "=== EXC-005: golden compile stderr (XLANG=$XLANG_BIN) ==="
while IFS=$'\t' read -r item_id kind anchor src notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  [ "$kind" = "golden" ] || continue
  want="$notes"
  echo "── compile golden: $src ──"
  set +e
  err=$("$XLANG_BIN" "$src" -o /tmp/xlang_exc_cli_lsp_fail_$$ 2>&1)
  set -e
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
  RUN_OK=$((RUN_OK + 1))
  echo "exc-cli-lsp-error OK compile $src"
done < "$MATRIX"

[ "$FAILS" -eq 0 ] || die "golden=${FAILS}"
[ "$RUN_OK" -ge 2 ] || die "golden run=${RUN_OK} < 2"

echo "exc-cli-lsp-error check=obs=${OBS} run=${RUN_OK}"
ok_report
echo "exc-cli-lsp-error gate OK"
