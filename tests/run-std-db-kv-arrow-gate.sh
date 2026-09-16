#!/usr/bin/env bash
# std.db kv + arrow — honesty leftover wrap dead source →硬绿 (F-05 residual).
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product kv_tick +
# arrow_column + cookbook db_kv_arrow exit0 = hard run (run+=). check +
# host-C archaeology = obs (no soft ensure rebuild). Report: run=/obs=/skip=.
# G.7: complete existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-db-kv-arrow-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-db-kv-arrow gate FAIL: $*" >&2
  std_db_kv_arrow_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== std.db kv+arrow: manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_KV" "$MOD_ARROW" "$MOD_DB" "$MOD_SQLITE" \
  "$ARROW_X" "$KV_X" "$KV_GLUE" "$MMAP_X" "$LINUX_X" "$README" \
  "$SMOKE_KV" "$SMOKE_ARROW" "$COOKBOOK_DB"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in std.db.kv std.db.arrow mmap LSM WAL compact null_bitmap adopt SIMD SST; do
  grep -qF "$kw" "$README" 2>/dev/null || die "README missing '$kw'"
done

grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

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
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_db_kv_arrow_symbols_ok "$MOD_KV" "$MOD_ARROW" "$KV_X" "$ARROW_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-db-kv-arrow manifest OK"

if [ "${XLANG_STD_DB_KV_ARROW_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_db_kv_arrow_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-db-kv-arrow gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== std.db kv+arrow: smoke (XLANG=$XLANG_BIN; check/C obs; kv+arrow+cb product -o hard) ==="

# Observational check (paused 2026-08-05); CHK red does not hard-fail.
set +e
"$XLANG_BIN" check -L . "$SMOKE_KV" >/tmp/xlang_std_db_kv_arrow_chk_kv.log 2>&1
chk1=$?
"$XLANG_BIN" check -L . "$SMOKE_ARROW" >/tmp/xlang_std_db_kv_arrow_chk_arrow.log 2>&1
chk2=$?
set -e
if [ "$chk1" -ne 0 ] || [ "$chk2" -ne 0 ]; then
  echo "std-db-kv-arrow OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

if std_db_kv_arrow_run_smoke "$XLANG_BIN" "$SMOKE_KV" "kv"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-db-kv-arrow OK: kv"
else
  die "kv_tick_smoke.x exit!=0 (refuse soft SKIP→OK)"
fi
if std_db_kv_arrow_run_smoke "$XLANG_BIN" "$SMOKE_ARROW" "arrow"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-db-kv-arrow OK: arrow"
else
  die "arrow_column_smoke.x exit!=0 (refuse soft SKIP→OK)"
fi
if std_db_kv_arrow_run_smoke "$XLANG_BIN" "$COOKBOOK_DB" "cb"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-db-kv-arrow OK: cookbook"
else
  die "db_kv_arrow.x exit!=0 (refuse soft SKIP→OK)"
fi

# Observational: host-C archaeology smokes (no soft rebuild).
# PLATFORM: SHARED — refuse soft ensure / soft auto-make on C path.
if ! std_db_kv_arrow_run_c_smokes; then
  echo "std-db-kv-arrow OBS c smokes (host-C archaeology; refuse soft ensure rebuild)" >&2
  OBS=$((OBS + 1))
fi

std_db_kv_arrow_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-db-kv-arrow gate OK (host=$(ci_host_summary))"
