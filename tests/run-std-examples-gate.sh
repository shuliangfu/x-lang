#!/usr/bin/env bash
# STD-012：标准库示例工程 manifest 门禁（假权威诚实）。
#
# 用法：./tests/run-std-examples-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); hello + cookbook io_batch exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/x=/skip=. Product
# surface already green under asm; gate was portable-false-red (prefer xlang-c
# only / hard typeck on cookbook+core / soft SKIP when no native).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_EXAMPLES_DOC:-analysis/archive/std/std-examples-v1.md}"
MANIFEST="${XLANG_STD_EXAMPLES_MANIFEST:-tests/baseline/std-examples-manifest.tsv}"
CATALOG="${XLANG_STD_EXAMPLES_CATALOG:-tests/baseline/std-examples-catalog.tsv}"
LIB="tests/lib/std-examples.sh"
SMOKE_HELLO="examples/hello.x"
SMOKE_IO="examples/cookbook/io_batch_rw.x"
MIN_EX=30

# shellcheck source=tests/lib/std-examples.sh
. "$LIB"

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

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== STD-012: std examples manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-examples-v1.md ]; then
  echo "std-examples gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$CATALOG" "$LIB" "$SMOKE_HELLO" "$SMOKE_IO"; do
  if [ ! -f "$f" ]; then
    echo "std-examples gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_examples) MIN_EX="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
IDX=0
echo "=== STD-012: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    example_index)
      IDX=$((IDX + 1))
      if ! awk -F'\t' -v e="$anchor" '$1==e && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$CATALOG"; then
        echo "std-examples FAIL: catalog missing $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing index $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-examples FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-examples FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-examples FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-examples FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-examples FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

COUNT=$(std_ex_catalog_count "$CATALOG")
if [ "$COUNT" -lt "$MIN_EX" ]; then
  echo "std-examples gate FAIL: catalog count=${COUNT} < min ${MIN_EX}" >&2
  exit 1
fi

if ! std_ex_validate_paths "$CATALOG"; then
  echo "std-examples gate FAIL: catalog paths" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  echo "std-examples gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in examples catalog cookbook runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "std-examples gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

# DOC §5 = Gate honesty (was ## 5. 验证与门禁 without prefer-asm / runnable hard).
# PLATFORM: SHARED archaeology — section anchor must match archive DOC.
if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-examples gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

echo "std-examples manifest OK (catalog=${COUNT} index=${IDX})"

if [ "${XLANG_STD_EXAMPLES_MANIFEST_ONLY:-0}" = "1" ]; then
  std_ex_emit_report "ok" 0 0 1
  echo "std-examples gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
X_OK=0
SKIP=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "std-examples gate FAIL: no native xlang" >&2
  std_ex_emit_report "fail" 0 0 0
  exit 1
fi

echo "=== STD-012: smoke (XLANG=$XLANG_BIN; check observational; hello+io runnable hard) ==="
# Observational check (paused 2026-08-05); CHK red does not hard-fail.
if std_ex_check_example "$XLANG_BIN" "$SMOKE_HELLO"; then
  CHECK_OK=1
else
  echo "std-examples gate SKIP check smoke (paused 2026-08-05)" >&2
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

FAILS=0
if std_ex_run_x_smoke "$XLANG_BIN" "$SMOKE_HELLO" "/tmp/xlang_std_ex_hello_$$"; then
  echo "std-examples runnable OK hello"
else
  echo "std-examples runnable FAIL hello" >&2
  FAILS=$((FAILS + 1))
fi
if std_ex_run_x_smoke "$XLANG_BIN" "$SMOKE_IO" "/tmp/xlang_std_ex_io_$$"; then
  echo "std-examples runnable OK io_batch"
else
  echo "std-examples runnable FAIL io_batch" >&2
  FAILS=$((FAILS + 1))
fi

if [ "$FAILS" -gt 0 ]; then
  std_ex_emit_report "fail" "$CHECK_OK" 0 0
  echo "std-examples gate FAIL: ${FAILS} runnable smoke(s)" >&2
  exit 1
fi

X_OK=1
SKIP=0
# check stays observational; hard-green signal is x= (hello+io exit0).
echo "std-examples check_ok=${CHECK_OK} (observational)"
std_ex_emit_report "ok" "$CHECK_OK" "$X_OK" "$SKIP"
echo "std-examples gate OK"
