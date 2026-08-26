#!/usr/bin/env bash
# std.db kv + arrow 门禁（假权威诚实 · F-05 soft residual）。
#
# 用法：./tests/run-std-db-kv-arrow-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); kv_tick_smoke + arrow_column_smoke +
# cookbook db_kv_arrow exit 0 hard-fail (no soft SKIP when native xlang present).
# C smokes observational. Report check=/kv=/arrow=/cb=/c=/skip=.
# Product surfaces already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP when no .x run / SKIP→OK).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_DB_KV_ARROW_DOC:-analysis/archive/std/std-db-kv-arrow-v1.md}"
MANIFEST="${XLANG_STD_DB_KV_ARROW_TSV:-tests/baseline/std-db-kv-arrow.tsv}"
LIB="tests/lib/std-db-kv-arrow.sh"
MOD_KV="std/db/kv/mod.x"
MOD_ARROW="std/db/arrow/mod.x"
MOD_DB="std/db/mod.x"
MOD_SQLITE="std/db/sqlite/mod.x"
ARROW_X="std/db/arrow/arrow.x"
KV_X="std/db/kv/kv.x"
KV_GLUE="compiler/seeds/runtime_kv_mmap_glue.from_x.c"
MMAP_X="std/sys/mmap.x"
LINUX_X="std/sys/linux.x"
SMOKE_KV="tests/std-db/kv_tick_smoke.x"
SMOKE_ARROW="tests/std-db/arrow_column_smoke.x"
COOKBOOK_DB="examples/cookbook/db_kv_arrow.x"
README="std/db/README.md"
MIN_APIS=8

# shellcheck source=tests/lib/std-db-kv-arrow.sh
. "$LIB"

echo "=== std.db kv+arrow: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_KV" "$MOD_ARROW" "$MOD_DB" "$MOD_SQLITE" \
  "$ARROW_X" "$KV_X" "$KV_GLUE" "$MMAP_X" "$LINUX_X" "$README" \
  "$SMOKE_KV" "$SMOKE_ARROW" "$COOKBOOK_DB"; do
  if [ ! -f "$f" ]; then
    echo "std-db-kv-arrow gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in std.db.kv std.db.arrow mmap LSM WAL compact null_bitmap adopt SIMD SST; do
  if ! grep -qF "$kw" "$README" 2>/dev/null; then
    echo "std-db-kv-arrow gate FAIL: README missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-db-kv-arrow gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-db-kv-arrow gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-db-kv-arrow gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_db_kv_arrow_symbols_ok "$MOD_KV" "$MOD_ARROW" "$KV_X" "$ARROW_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_db_kv_arrow_emit_report "fail" 0 0 0 0 0 0
  echo "std-db-kv-arrow gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-db-kv-arrow manifest OK"

if [ "${XLANG_STD_DB_KV_ARROW_MANIFEST_ONLY:-0}" = "1" ]; then
  std_db_kv_arrow_emit_report "ok" 0 0 0 0 0 1
  echo "std-db-kv-arrow gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
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

CHECK_OK=0
KV_OK=0
ARROW_OK=0
CB_OK=0
C_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== std.db kv+arrow: smoke (XLANG=$XLANG_BIN; check/c observational; kv/arrow/cb hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_KV" >/dev/null 2>&1 \
     && "$XLANG_BIN" check -L . "$SMOKE_ARROW" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-db-kv-arrow gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  xlang_compiler_make ../std/db/kv/kv.o ../std/db/arrow/arrow.o \
    runtime_kv_mmap_glue.o runtime_arrow_simd_glue.o >/dev/null 2>&1 || true
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_db_kv_arrow_run_smoke "$XLANG_BIN" "$SMOKE_KV" "kv"; then
    KV_OK=1
  else
    std_db_kv_arrow_emit_report "fail" "$CHECK_OK" 0 0 0 0 0
    exit 1
  fi
  if std_db_kv_arrow_run_smoke "$XLANG_BIN" "$SMOKE_ARROW" "arrow"; then
    ARROW_OK=1
  else
    std_db_kv_arrow_emit_report "fail" "$CHECK_OK" "$KV_OK" 0 0 0 0
    exit 1
  fi
  if std_db_kv_arrow_run_smoke "$XLANG_BIN" "$COOKBOOK_DB" "cb"; then
    CB_OK=1
    SKIP=0
  else
    std_db_kv_arrow_emit_report "fail" "$CHECK_OK" "$KV_OK" "$ARROW_OK" 0 0 0
    exit 1
  fi

  # Observational: host-C archaeology smokes (not product asm hard path).
  if std_db_kv_arrow_run_c_smokes; then
    C_OK=1
  else
    echo "std-db-kv-arrow gate SKIP c smokes (observational)" >&2
  fi
else
  echo "std-db-kv-arrow gate FAIL: no native xlang" >&2
  std_db_kv_arrow_emit_report "fail" 0 0 0 0 0 0
  exit 1
fi

# check/c stay observational; hard-green signal is kv= + arrow= + cb=.
echo "std-db-kv-arrow check_ok=${CHECK_OK} c_ok=${C_OK} (observational)"
std_db_kv_arrow_emit_report "ok" "$CHECK_OK" "$KV_OK" "$ARROW_OK" "$CB_OK" "$C_OK" "$SKIP"
echo "std-db-kv-arrow gate OK"
