#!/usr/bin/env bash
# ZC-006：零拷贝语义白皮书 manifest 门禁
#
# Honesty: top-level analysis/zc-semantics-v1.md deleted — DOC
# authority = archive/zc (refuse fossil hard-red / soft silence).
# ZC-2 runnable honesty lives in run-zc2-gate.sh (this gate is
# manifest-only unless XLANG_ZC_SEMANTICS_RUN_HOOKS=1).
#
# 1) zc-semantics-v1.md 必需章节与拷贝 catalog
# 2) ZC-1..5 tier 与交叉引用
# 3) 示例存在；可选跑 run-zc-gates.sh
#
# Honesty: leftover native_xlang third resolver retired (G.7 converge
# dod_native_exe). leftover ignore of explicit-bad XLANG (manifest ran
# first; XLANG unused unless RUN_HOOKS=1) retired. Explicit-bad XLANG /
# missing native = hard die FIRST (before DOC / leftover nested zc
# hooks). leftover nested zc3／zc4／zc5 hooks stay opt-in.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# Report: doc=/manifest=/hook=/skip=
# PLATFORM: SHARED archaeology.
#
# 用法：./tests/run-zc-semantics-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_ZC_SEMANTICS_DOC:-analysis/archive/zc/zc-semantics-v1.md}"
MANIFEST="${XLANG_ZC_SEMANTICS_TSV:-tests/baseline/zc-semantics.tsv}"
PREFIX="xlang: [XLANG_ZC_SEMANTICS]"
MIN_SEC=7
MIN_ZC=5
RUN_HOOKS=0
[ "${XLANG_ZC_SEMANTICS_RUN_HOOKS:-0}" = "1" ] && RUN_HOOKS=1

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"

DOC_OK=0
MANIFEST_OK=0
HOOK_OK=0
SKIP=1

die() {
  echo "zc-semantics gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} manifest=${MANIFEST_OK:-0} hook=${HOOK_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# leftover native_xlang third resolver retired — converge
# dod_native_exe. Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

# Explicit XLANG that is missing/non-native hard-dies BEFORE DOC /
# leftover nested zc hooks (refuse leftover SKIP→OK / leftover ignore of
# explicit-bad / leftover native_xlang). leftover nested product path
# stays when XLANG is unset (hooks remain opt-in).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover ignore of explicit-bad / leftover SKIP→OK / leftover native_xlang)"
fi

echo "=== ZC-006: zero-copy semantics manifest ==="
# Honesty: NEXT.md top-level fossil retired — live roadmap = 自举进度.md.
# Require DOC + manifest only (refuse NEXT.md hard-red / soft silence).
for f in "$DOC" "$MANIFEST"; do
  [ -f "$f" ] || die "missing $f"
done
# DOC must live under archive (top-level analysis/zc-semantics-v1.md deleted).
case "$DOC" in
  analysis/archive/zc/*) ;;
  *)
    die "DOC must be archive/zc (got $DOC)"
    ;;
esac
DOC_OK=1

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_zc_tiers) MIN_ZC="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
ZC=0
HOOK=""
echo "=== ZC-006: sections, catalog, tiers ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section|catalog_anchor)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      elif [ "$kind" = "section" ]; then
        SEC=$((SEC + 1))
        echo "zc-semantics OK section $item_id"
      fi
      ;;
    zc_tier)
      ZC=$((ZC + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: doc missing tier $anchor" >&2
        MISS=$((MISS + 1))
      fi
      gate_script="$notes"
      case "$gate_script" in
        tests/*) gate_path="$gate_script" ;;
        *) gate_path="tests/$gate_script" ;;
      esac
      if [ ! -f "$gate_path" ]; then
        echo "zc-semantics FAIL: missing gate $gate_path" >&2
        MISS=$((MISS + 1))
      else
        echo "zc-semantics OK tier $anchor ($gate_path)"
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "zc-semantics FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "zc-semantics OK cross-ref $anchor"
      fi
      ;;
    example)
      if [ ! -f "$anchor" ]; then
        echo "zc-semantics FAIL: missing example $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-semantics FAIL: doc missing example $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "zc-semantics OK example $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "zc-semantics FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      else
        HOOK="$path"
        echo "zc-semantics OK hook $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  die "sections=${SEC} < min ${MIN_SEC}"
fi
if [ "$ZC" -lt "$MIN_ZC" ]; then
  die "zc_tiers=${ZC} < min ${MIN_ZC}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi

for kw in read_ptr StrView fs_mmap_ro fs_pipe_splice; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
echo "zc-semantics manifest OK (sections=${SEC}, zc_tiers=${ZC})"
MANIFEST_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover ignore of explicit-bad / leftover SKIP→OK / leftover native_xlang)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover SKIP→OK / leftover native_xlang / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Honesty: do NOT auto-enable RUN_HOOKS when native xlang is present.
# Auto-hook previously pulled zc3／zc4／zc5 (host-c postponed) into this
# manifest gate and mixed soft SKIP→OK / check-bound false-red with ZC-2.
# leftover nested zc3／zc4／zc5 hooks stay opt-in:
# XLANG_ZC_SEMANTICS_RUN_HOOKS=1.
# PLATFORM: SHARED archaeology.
if [ "$RUN_HOOKS" -eq 1 ] && [ -n "$HOOK" ]; then
  echo "=== ZC-006: linked hook $HOOK (opt-in) ==="
  chmod +x "$HOOK" 2>/dev/null || true
  if XLANG="$XLANG_BIN" "$HOOK"; then
    echo "zc-semantics hook OK"
    HOOK_OK=1
  else
    die "hook $(basename "$HOOK")"
  fi
else
  echo "zc-semantics gate skip hook (manifest-only; set XLANG_ZC_SEMANTICS_RUN_HOOKS=1 to force)"
fi

SKIP=0
echo "zc-semantics gate OK"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} hook=${HOOK_OK} skip=${SKIP} host=$(ci_host_summary)"
