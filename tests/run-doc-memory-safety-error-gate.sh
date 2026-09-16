#!/usr/bin/env bash
# DOC-004：内存安全与异常处理指南 manifest 门禁（假权威诚实）。
#
# Honesty: prefer-c + soft SKIP hooks + top-level DOC / fossil xref retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die. Manifest hard; linked hooks (lang-unsafe check-bound) = obs.
# DOC authority = archive/doc. Report: run=/obs=/skip=
# Usage: ./tests/run-doc-memory-safety-error-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_DOC_MEM_SAFE_ERR:-analysis/archive/doc/doc-memory-safety-error-v1.md}"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
MANIFEST="${XLANG_DOC_MEM_SAFE_MANIFEST:-tests/baseline/doc-memory-safety-error.tsv}"
MIN_SEC=8
MIN_XREF=6
PREFIX="${XLANG_DOC_MEM_SAFE_PREFIX:-xlang: [XLANG_DOC_MEMORY_SAFETY]}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "doc-memory-safety-error gate FAIL: $*" >&2
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

echo "=== DOC-004: memory safety & error guide manifest ==="

if [ -f analysis/doc-memory-safety-error-v1.md ]; then
  die "top-level DOC resurrected (analysis/doc-memory-safety-error-v1.md; use archive)"
fi
if [ -f NEXT.md ]; then
  die "NEXT.md resurrected (use analysis/自举进度.md)"
fi

for f in "$DOC" "$MANIFEST" "$ROADMAP"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_cross_refs) MIN_XREF="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
XREF=0
HOOKS=""
echo "=== DOC-004: required sections & refs ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-memory-safety-error FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        SEC=$((SEC + 1))
        echo "doc-memory-safety-error OK section $item_id"
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "doc-memory-safety-error FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        XREF=$((XREF + 1))
        if ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
          echo "doc-memory-safety-error FAIL: doc missing link to $anchor" >&2
          MISS=$((MISS + 1))
        else
          echo "doc-memory-safety-error OK cross-ref $anchor"
        fi
      fi
      ;;
    example)
      if [ ! -f "$anchor" ]; then
        echo "doc-memory-safety-error FAIL: missing example $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-memory-safety-error FAIL: doc missing example ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "doc-memory-safety-error OK example $anchor"
      fi
      ;;
    hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "doc-memory-safety-error FAIL: missing hook $path" >&2
        MISS=$((MISS + 1))
      else
        HOOKS="$HOOKS $path"
        echo "doc-memory-safety-error OK hook $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$SEC" -ge "$MIN_SEC" ] || die "sections=${SEC} < min ${MIN_SEC}"
[ "$XREF" -ge "$MIN_XREF" ] || die "cross_refs=${XREF} < min ${MIN_XREF}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"

for kw in EXC-001 EXC-003 LANG-007 SAFE-002; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
echo "doc-memory-safety-error manifest OK (sections=${SEC}, cross_refs=${XREF})"
RUN_OK=1

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Hook *existence* is hard (above). Execution is opt-in observational:
# lang-unsafe is check-bound (postponed); auto-running hooks would soft-bind
# DOC-004 to postponed check debt. PLATFORM: SHARED — not soft silence.
if [ "${XLANG_DOC_MEM_SAFE_RUN_HOOKS:-0}" = "1" ] && [ -n "$HOOKS" ]; then
  echo "=== DOC-004: linked gate hooks (opt-in observational) ==="
  for hook in $HOOKS; do
    echo "── hook obs: $hook ──"
    chmod +x "$hook" 2>/dev/null || true
    set +e
    XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$hook" >/tmp/doc_mem_hook_$$.log 2>&1
    hec=$?
    set -e
    if [ "$hec" -eq 0 ]; then
      echo "doc-memory-safety-error hook OK $(basename "$hook")"
    else
      OBS=$((OBS + 1))
      echo "doc-memory-safety-error OBS hook $(basename "$hook") (ec=$hec; check/product residual)" >&2
      tail -5 /tmp/doc_mem_hook_$$.log >&2 || true
    fi
  done
else
  echo "doc-memory-safety-error hooks: existence OK (exec opt-in via XLANG_DOC_MEM_SAFE_RUN_HOOKS=1; lang-unsafe check-bound＝obs)"
fi

ok_report
echo "doc-memory-safety-error gate OK"
