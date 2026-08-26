#!/usr/bin/env bash
# BOOT-010: force_stub 6 风险处置 manifest + honesty gate
# (false-authority honesty).
#
# wave309 honesty: ast_pool.c left — live PARSER_STUB_EQ =
# seeds/runtime_pipeline_abi.from_x.c. DOC archived under analysis/archive/boot/.
# Selfhost pause (2026-08-05): do NOT run xlang check as gate smoke.
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; matrix reg_src link+run
# hard-fail (no soft SKIP→OK when no native; do not call full check-mixed
# hooks — those were portable-false-red under paused check). check_only
# observational. Report link=/skip=. Gate was portable-false-red
# (prefer xlang-c / soft SKIP→OK when no native / full run-float +
# run-lang-unsafe hooks hard on check negatives / DOC ## 4 without Gate).
# PLATFORM: SHARED archaeology.
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
LIB="tests/lib/boot-force-stub.sh"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
MIN_STUB=6

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/boot-force-stub.sh
. "$LIB"

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

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
boot010_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== BOOT-010: force_stub manifest ==="

# Refuse resurrected top-level DOC (live = archive/boot/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/boot-force-stub-v1.md ]; then
  echo "boot-force-stub gate FAIL: top-level DOC resurrected (live = archive/boot/)" >&2
  exit 1
fi

for f in \
  "$DOC" \
  "$MEGA7_DOC" \
  "$MATRIX" \
  "$PARSER_X" \
  "$ABI_SEED" \
  "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "boot-force-stub gate FAIL: missing $f" >&2
    exit 1
  fi
done
if [ -f compiler/ast_pool.c ]; then
  echo "boot-force-stub gate FAIL: compiler/ast_pool.c resurrected (wave309 left; dual authority)" >&2
  exit 1
fi

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "boot-force-stub gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

echo "boot-force-stub manifest OK (host=$(ci_host_summary))"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_stub_rows) MIN_STUB="$c2" ;; esac
done < "$MATRIX"

# ── 6 项符号 + PARSER_STUB_EQ ──
MISS=0
N=0
LINK_SRCS=""
SKIP_CHECK=0
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
  if [ "${reg_hook:-}" = "check_only" ]; then
    # Observational: selfhost check gate paused 2026-08-05.
    SKIP_CHECK=$((SKIP_CHECK + 1))
    echo "boot-force-stub SKIP check_only $stub_id ($reg_src)"
  else
    # Unique reg_src for link+run hard path.
    case " $LINK_SRCS " in
      *" $reg_src "*) ;;
      *) LINK_SRCS="$LINK_SRCS $reg_src" ;;
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
echo "boot-force-stub symbols OK (${N} stubs; link_srcs=$(echo $LINK_SRCS | wc -w | tr -d ' ') check_only=${SKIP_CHECK})"

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

if [ "${XLANG_BOOT010_MANIFEST_ONLY:-0}" = "1" ]; then
  boot010_emit_report "ok" 0 "$SKIP_CHECK"
  echo "boot-force-stub gate OK (manifest only)"
  exit 0
fi

LINK_OK=0
SKIP=1

if XLANG_BIN="$(boot010_resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-010: matrix reg_src link+run (XLANG=$XLANG_BIN; check_only observational) ==="
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh" 2>/dev/null || true
  mkdir -p "$OUT_DIR"
  FAILS=0
  for reg_src in $LINK_SRCS; do
    if ! want="$(boot010_want_exit "$reg_src")"; then
      echo "boot-force-stub FAIL: no want_exit map for $reg_src" >&2
      FAILS=$((FAILS + 1))
      continue
    fi
    out="$OUT_DIR/boot010_$(basename "$reg_src" .x)"
    rm -f "$out"
    if boot010_link_run_one "$XLANG_BIN" "$reg_src" "$out" "$want"; then
      echo "boot-force-stub link+run OK $reg_src (exit=$want)"
      LINK_OK=$((LINK_OK + 1))
    else
      FAILS=$((FAILS + 1))
    fi
  done
  if [ "$FAILS" -gt 0 ]; then
    echo "boot-force-stub gate FAIL: ${FAILS} link+run" >&2
    boot010_emit_report "fail" "$LINK_OK" "$SKIP_CHECK"
    exit 1
  fi
  # Expect 4 unique link sources (simple / no_else / f32_f64 / allow_padding_ok).
  if [ "$LINK_OK" -lt 4 ]; then
    echo "boot-force-stub gate FAIL: link_ok=${LINK_OK} < 4" >&2
    boot010_emit_report "fail" "$LINK_OK" "$SKIP_CHECK"
    exit 1
  fi
  SKIP=0
else
  echo "boot-force-stub gate FAIL: no native xlang" >&2
  boot010_emit_report "fail" 0 "$SKIP_CHECK"
  exit 2
fi

echo "boot-force-stub link_ok=${LINK_OK} check_only_skip=${SKIP_CHECK}"
boot010_emit_report "ok" "$LINK_OK" "$SKIP_CHECK"
echo "boot-force-stub gate OK"
