#!/usr/bin/env bash
# TOOL-007：包管理器方案 manifest 门禁
#
# 用法：./tests/run-tool-pkgmgr-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TOOL_PKGMGR_DOC:-analysis/tool-pkgmgr-v1.md}"
MANIFEST="${SHUX_TOOL_PKGMGR_MANIFEST:-tests/baseline/tool-pkgmgr.tsv}"
CATALOG="${SHUX_TOOL_PKGMGR_CATALOG:-tests/baseline/tool-pkgmgr-catalog.tsv}"
MIN_RULES=6
MIN_PACKAGES=8

# shellcheck source=tests/lib/tool-pkgmgr.sh
. tests/lib/tool-pkgmgr.sh

native_shu() {
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

echo "=== TOOL-007: pkgmgr manifest ==="
for f in "$DOC" "$MANIFEST" "$CATALOG" scripts/shux-deps-resolve.sh \
  tests/fixtures/pkgmgr/shux.pkg.tsv tests/fixtures/pkgmgr/main.x; do
  if [ ! -f "$f" ]; then
    echo "tool-pkgmgr gate FAIL: missing $f" >&2
    exit 1
  fi
done

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
  # resolve from repo root
    if ! tool_pkg_resolve_import "$(pwd)" "$pkg_id" >/dev/null 2>&1; then
      echo "tool-pkgmgr FAIL: cannot resolve $pkg_id" >&2
      MISS=$((MISS + 1))
    fi
  fi
done < "$CATALOG"

if [ "$RULE_N" -lt "$MIN_RULES" ]; then
  echo "tool-pkgmgr gate FAIL: rules=${RULE_N} < min ${MIN_RULES}" >&2
  exit 1
fi
if [ "$PKG_N" -lt "$MIN_PACKAGES" ]; then
  echo "tool-pkgmgr gate FAIL: packages=${PKG_N} < min ${MIN_PACKAGES}" >&2
  exit 1
fi

for kw in package manager resolve prototype runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-pkgmgr gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-pkgmgr gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-pkgmgr manifest OK (rules=${RULE_N} packages=${PKG_N})"

chmod +x scripts/shux-deps-resolve.sh tests/run-pkgmgr-resolve.sh
./scripts/shux-deps-resolve.sh tests/fixtures/pkgmgr/shux.pkg.tsv

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
  echo "=== TOOL-007: pkgmgr hooks (SHUX=$SHUX_BIN) ==="
  SHUX="$SHUX_BIN" ./tests/run-pkgmgr-resolve.sh
  echo "tool-pkgmgr hooks OK"
else
  echo "tool-pkgmgr gate SKIP compile hook (no native shux)" >&2
fi

echo "tool-pkgmgr gate OK"
