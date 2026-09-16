#!/usr/bin/env bash
# TOOL-007: package manager design manifest gate.
#
# Honesty: soft SKIP→OK when no native xlang (bare "gate OK") + prefer
# xlang-c before xlang_asm retired. Prefer product xlang_asm. Explicit
# bad XLANG = hard die. Missing native = hard die. DOC authority =
# archive/tool. Report run=/hooks=/skip=.
#
# Usage: ./tests/run-tool-pkgmgr-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tool-pkgmgr.sh
. tests/lib/tool-pkgmgr.sh

DOC="${XLANG_TOOL_PKGMGR_DOC:-analysis/archive/tool/tool-pkgmgr-v1.md}"
MANIFEST="${XLANG_TOOL_PKGMGR_MANIFEST:-tests/baseline/tool-pkgmgr.tsv}"
CATALOG="${XLANG_TOOL_PKGMGR_CATALOG:-tests/baseline/tool-pkgmgr-catalog.tsv}"
RESOLVE_SRC="${XLANG_TOOL_PKGMGR_RESOLVE_SRC:-compiler/src/runtime_pipeline_abi.h}"
MIN_RULES=6
MIN_PACKAGES=8
PREFIX="xlang: [XLANG_TOOL_PKGMGR]"
RUN_OK=0
HOOKS_OK=0
SKIP=0

die() {
  echo "tool-pkgmgr gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} hooks=${HOOKS_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} hooks=${HOOKS_OK} skip=${SKIP} host=$(ci_host_summary)"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

echo "=== TOOL-007: pkgmgr manifest (monofile retired) ==="
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (resolve live = runtime_pipeline_abi.h)"
fi
if [ -f analysis/tool-pkgmgr-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tool/)"
fi
for f in "$DOC" "$MANIFEST" "$CATALOG" "$RESOLVE_SRC" scripts/xlang-deps-resolve.sh \
  tests/fixtures/pkgmgr/xlang.pkg.tsv tests/fixtures/pkgmgr/main.x; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rules) MIN_RULES="$c2" ;;
    min_packages) MIN_PACKAGES="$c2" ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_packages) [ -n "$c2" ] && MIN_PACKAGES="$c2" ;;
  esac
done < "$CATALOG"

MISS=0
RULE_N=0
PKG_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-pkgmgr FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    rules)
      RULE_N=$((RULE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-pkgmgr FAIL: doc missing rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if [ ! -f "$src" ]; then
        echo "tool-pkgmgr FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$src" 2>/dev/null; then
        echo "tool-pkgmgr FAIL: symbol $anchor not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-pkgmgr FAIL: missing file $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-pkgmgr FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-pkgmgr FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-pkgmgr FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-pkgmgr FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r pkg_id tier path_glob _notes; do
  [ -z "${pkg_id:-}" ] && continue
  case "$pkg_id" in \#*|min_*) continue ;; esac
  PKG_N=$((PKG_N + 1))
  if [ ! -f "$path_glob" ]; then
    echo "tool-pkgmgr FAIL: catalog missing $path_glob ($pkg_id)" >&2
    MISS=$((MISS + 1))
  elif ! tool_pkg_resolve_import "." "$pkg_id" >/dev/null 2>&1; then
    if ! tool_pkg_resolve_import "$(pwd)" "$pkg_id" >/dev/null 2>&1; then
      echo "tool-pkgmgr FAIL: cannot resolve $pkg_id" >&2
      MISS=$((MISS + 1))
    fi
  fi
done < "$CATALOG"

[ "$RULE_N" -ge "$MIN_RULES" ] || die "rules=${RULE_N} < min ${MIN_RULES}"
[ "$PKG_N" -ge "$MIN_PACKAGES" ] || die "packages=${PKG_N} < min ${MIN_PACKAGES}"
for kw in package manager resolve prototype runnable report; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "tool-pkgmgr manifest OK (rules=${RULE_N} packages=${PKG_N})"
RUN_OK=1

chmod +x scripts/xlang-deps-resolve.sh tests/run-pkgmgr-resolve.sh
./scripts/xlang-deps-resolve.sh tests/fixtures/pkgmgr/xlang.pkg.tsv

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== TOOL-007: pkgmgr hooks (XLANG=$XLANG_BIN) ==="
XLANG="$XLANG_BIN" ./tests/run-pkgmgr-resolve.sh
HOOKS_OK=1
echo "tool-pkgmgr hooks OK"

ok_report
echo "tool-pkgmgr gate OK"
