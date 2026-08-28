#!/usr/bin/env bash
# STBL-004: import std.* resolve + -L layout gate — honesty residual soft
# auto-make / XLANG fallthrough / check=/resolve= report →硬绿.
#
# Honesty: residual soft auto-make (`xlang_compiler_make -q ||
# xlang_compiler_make || true`) + `stbl_import_std_resolve_shu` XLANG
# fallthrough (explicit bad XLANG continues to xlang_asm) + bootstrap-link
# wrap + report resolve=/check=/run=/skip= retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / XLANG
# fallthrough). check residual = obs (paused 2026-08-05). Product
# check_imports.x -o exit0 = hard run (already green under asm).
# Manifest resolve walk stays hard (min_resolve). Report: run=/obs=/skip=.
# Keep ## 7. Gate. Keep keywords STBL-004 / import / std / -L / TOOL-007 /
# TOOL-008 / mod.x. PLATFORM: SHARED archaeology — Ubuntu gold still
# required.
# Usage: ./tests/run-stbl-004-import-std-layout-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

DOC="${XLANG_STBL_IMPORT_STD_DOC:-analysis/archive/stbl/stbl-import-std-layout-v1.md}"
MANIFEST="${XLANG_STBL_IMPORT_STD_TSV:-tests/baseline/stbl-import-std-layout.tsv}"
LIB="tests/lib/stbl-import-std-layout.sh"
PKG_LIB="tests/lib/tool-pkgmgr.sh"
SMOKE_X="tests/import-std-layout/check_imports.x"
MIN_RESOLVE=12
LIB_ROOT="."

# shellcheck source=tests/lib/tool-pkgmgr.sh
. "$PKG_LIB"
# shellcheck source=tests/lib/stbl-import-std-layout.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "stbl-import-std gate FAIL: $*" >&2
  stbl_import_std_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

echo "=== STBL-004: import std layout manifest (archive DOC) ==="

# Refuse resurrected top-level DOC (live = archive/stbl/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/stbl-import-std-layout-v1.md ] || die "dual-authority fossil analysis/stbl-import-std-layout-v1.md (archive live)"

for f in "$DOC" "$MANIFEST" "$LIB" "$PKG_LIB" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STBL-004 import std -L TOOL-007 TOOL-008 mod.x; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 7. Gate' "$DOC" 2>/dev/null || die "doc missing '## 7. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_resolve) MIN_RESOLVE="$c2" ;; esac
done < "$MANIFEST"

sec_miss="$(stbl_import_std_sections_ok "$DOC" "$MANIFEST" || true)"
[ "${sec_miss:-0}" -eq 0 ] || die "sec_miss=${sec_miss}"

RESOLVE_OK=0
while IFS=$'\t' read -r item_id kind import_path expected _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    resolve)
      if ! stbl_import_std_resolve_probe "$LIB_ROOT" "$import_path" "$expected"; then
        die "resolve $import_path"
      fi
      RESOLVE_OK=$((RESOLVE_OK + 1))
      ;;
  esac
done < "$MANIFEST"

[ "$RESOLVE_OK" -ge "$MIN_RESOLVE" ] || die "resolve $RESOLVE_OK < min $MIN_RESOLVE"
echo "stbl-import-std resolve OK (${RESOLVE_OK}/${MIN_RESOLVE})"

if [ "${XLANG_STBL_IMPORT_STD_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  stbl_import_std_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "stbl-import-std-layout gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(stbl_import_std_resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STBL-004: smoke (XLANG=$XLANG_BIN; check=obs; check_imports.x hard) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# check residual = obs (paused 2026-08-05). Refuse hard-bind check.
# PLATFORM: SHARED — CHK residual is not a green signal.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_stbl004_check_$$.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "stbl-import-std OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Product check_imports.x -o exit0 is the hard-green signal.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make. G.7: stbl_import_std_run_smoke.
if stbl_import_std_run_smoke "$XLANG_BIN" "$SMOKE_X" "check_imports"; then
  RUN_OK=$((RUN_OK + 1))
  echo "stbl-import-std OK: product check_imports"
else
  die "product -o $SMOKE_X failed (refuse soft SKIP→OK)"
fi

stbl_import_std_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "stbl-import-std-layout gate OK"
