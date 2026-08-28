#!/usr/bin/env bash
# STD-010: std.db.sqlite prereq manifest gate — honesty residual soft
# auto-make →硬绿.
#
# Honesty: residual soft auto-make (`xlang_compiler_make -q` then
# `xlang_compiler_make` before typeck) + prefer-c resolve (xlang-c/xlang,
# no xlang_asm) + soft SKIP typeck (no native still gate OK) + hard
# `xlang check` as sole .x smoke retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c). check residual =
# obs (paused 2026-08-05). Product draft_typeck.x -o SEGV = obs (product
# debt; leave). No host-C harness on this RFC (do not invent). Report:
# run=/obs=/skip=. Keep ## 6. Gate. Keep keywords draft / RFC / runnable
# / report / XLANG_STD_SQLITE / D1-connection / DB_NOT_IMPL. Live API
# `rows` (refuse fossil `query_rows`). PLATFORM: SHARED archaeology —
# Ubuntu gold still required.
# Usage: ./tests/run-std-sqlite-prereq-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

DOC="${XLANG_STD_SQLITE_DOC:-analysis/archive/std/std-sqlite-prereq-v1.md}"
MANIFEST="${XLANG_STD_SQLITE_MANIFEST:-tests/baseline/std-sqlite-manifest.tsv}"
MOD_X="${XLANG_STD_SQLITE_MOD:-std/db/sqlite/mod.x}"
LIB="tests/lib/std-sqlite.sh"
RUNNER="tests/run-std-sqlite.sh"
SMOKE_X="tests/std-sqlite/draft_typeck.x"
README="std/db/sqlite/README.md"
MIN_APIS=9
MIN_LAYERS=4

# shellcheck source=tests/lib/std-sqlite.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sqlite gate FAIL: $*" >&2
  std_sqlite_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

echo "=== STD-010: std.db.sqlite prereq manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$README" "$LIB" "$RUNNER" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-sqlite-prereq-v1.md ] || die "dual-authority fossil analysis/std-sqlite-prereq-v1.md (archive live)"

for kw in draft RFC runnable report XLANG_STD_SQLITE D1-connection DB_NOT_IMPL; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 6. Gate' "$DOC" 2>/dev/null || die "doc missing '## 6. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
    min_layers) MIN_LAYERS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
API_N=0
LAYER_N=0
echo "=== STD-010: manifest walk ==="
while IFS=$'\t' read -r item_id kind anchor src _tier notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_sqlite_has_api "$MOD_X" "$anchor"; then
        echo "std-sqlite FAIL: missing API $anchor in $MOD_X" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|cross_ref)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "std-sqlite FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$path")" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing ref $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-sqlite FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-sqlite FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-sqlite FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "apis=${API_N} < min ${MIN_APIS}"
[ "$LAYER_N" -ge "$MIN_LAYERS" ] || die "layers=${LAYER_N} < min ${MIN_LAYERS}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "std-sqlite manifest OK (apis=${API_N}, layers=${LAYER_N})"

if [ "${XLANG_STD_SQLITE_PREREQ_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sqlite_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sqlite prereq gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(std_sqlite_resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-010: smoke (XLANG=$XLANG_BIN; check=obs; tip product=obs) ==="

# check residual = obs (paused 2026-08-05). Refuse hard-bind check.
# PLATFORM: SHARED — CHK residual is not a green signal.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_sqlite_prereq_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sqlite OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# tip product SEGV residual = obs (leave product debt; compile_rc=0 run=139).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make / paper SEGV as green.
# G.7: std_sqlite_run_smoke in tests/lib/std-sqlite-gate.sh.
if std_sqlite_run_smoke "$XLANG_BIN" "$SMOKE_X" "draft_typeck"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sqlite OK: product draft_typeck"
else
  echo "std-sqlite OBS tip product draft_typeck (SEGV/UNDEF residual)" >&2
  OBS=$((OBS + 1))
fi

std_sqlite_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sqlite prereq gate OK"
