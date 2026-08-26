#!/usr/bin/env bash
# F-07: forbid cc -c on migrated pure-.x std modules (io/fs/heap/compress/net).
#
# Usage: ./tests/run-f07-no-cc-std-migrated-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f07-no-cc-std-migrated-gate.sh
# 2026-08-26: Honesty — hard-fail static + forbidden ensure + f06 + f03-core
# (no soft die→exit0). Soft XLANG_F07_NO_CC_MIGRATED_FAIL retired. Prefer asm;
# pin XLANG_LINK_XLANG for child dogfood. Force f06 FAIL=1 so soft-child
# die→exit0 cannot portable-false-green this aggregator. f03-core already
# honesty-hard. Report static=/forbidden=/f06=/f03_core=/skip=. Gate was
# portable-false-green (soft FAIL exit0 + soft FAIL pass-through to f06
# while static + children already green under honesty).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F07_DOC:-analysis/archive/phase/phase-f-f07-v1.md}"
DOC_V2="${XLANG_F07_DOC_V2:-analysis/archive/phase/phase-f-f07-v2.md}"
MANIFEST="tests/baseline/f07-no-cc-std-migrated.tsv"
BUILD_STD="tests/lib/build-std-c-o.sh"
PREFIX="xlang: [XLANG_F07_NO_CC]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for child dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f07-no-cc-migrated gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} forbidden=${FORBIDDEN_OK:-0} f06=${F06_OK:-0} f03_core=${F03_CORE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
FORBIDDEN_OK=0
F06_OK=0
F03_CORE_OK=0
SKIP=1

echo "=== F-07: forbid cc -c migrated std modules (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$DOC_V2" ] || die "missing $DOC_V2"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-07 v1' "$DOC" || die "doc missing F-07 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -q 'F-07 v2' "$DOC_V2" || die "phase-f-f07-v2.md missing marker"
grep -qE '^## Gate' "$DOC_V2" || die "doc_v2 missing ## Gate section"
grep -q '_std_c_o_forbidden_migrated' "$BUILD_STD" || die "build-std-c-o.sh missing F-07 guard"

if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

# Manifest: absent / script / symbol rows (honesty TSV).
# PLATFORM: SHARED archaeology.
if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*) continue ;;
    esac
    case "$kind" in
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
      script)
        [ -f "$anchor" ] || die "manifest missing script: $anchor"
        ;;
      symbol)
        target="$mod_path"
        [ -n "$target" ] || die "manifest symbol missing mod_path for $item_id"
        [ -f "$target" ] || die "manifest target missing: $target"
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
      *)
        die "manifest unknown kind '$kind' for $item_id"
        ;;
    esac
  done < "$MANIFEST"
fi
echo "f07-no-cc manifest OK"

# Legacy C sources must stay deleted (hard list mirrors TSV absents).
for c in std/io/io.c std/fs/fs.c std/heap/heap.c std/compress/compress.c \
  std/compress/zlib/zlib.c std/compress/gzip/gzip.c \
  std/compress/brotli/brotli.c std/compress/zstd/zstd.c std/net/net.c \
  std/path/path.c std/uuid/uuid.c std/sort/sort.c; do
  [ ! -f "$c" ] || die "legacy C still exists: $c"
done
STATIC_OK=1

# ensure_std_c_o must reject migrated .o
# shellcheck source=tests/lib/build-std-c-o.sh
. "$BUILD_STD"
for o in ../std/io/io.o ../std/heap/heap.o ../std/compress/compress.o; do
  if ensure_std_c_o "$o" 2>/tmp/f07_forbidden.log; then
    die "ensure_std_c_o should reject $o"
  fi
  grep -q 'F-07 v1' /tmp/f07_forbidden.log || die "ensure_std_c_o reject message missing F-07 for $o"
done

# compiler/ tree bootstrap scripts must not cc -c migrated modules
MIGRATED_RE='std/(io/io|fs/fs|heap/heap|compress/(compress|zlib/zlib|gzip/gzip|brotli/brotli|zstd/zstd))\.c'
for f in compiler/scripts/build_xlang_asm.sh \
  compiler/scripts/relink_xlang_asm_experimental_bootstrap.sh \
  compiler/scripts/relink_xlang_asm_strict_glue.sh; do
  [ -f "$f" ] || die "missing $f"
  if grep -qE "cc .*-c.*${MIGRATED_RE}" "$f" 2>/dev/null; then
    die "$f still cc -c migrated std/*.c"
  fi
done

# tests/ must not ensure_std_c_o migrated (except build-std-c-o.sh + this gate)
while IFS= read -r f; do
  case "$f" in
    tests/lib/build-std-c-o.sh|tests/run-f07-no-cc-std-migrated-gate.sh) continue ;;
  esac
  if grep -qE 'ensure_std_c_o.*\.\./std/(io/io|fs/fs|heap/heap|compress/compress)\.o' "$f" 2>/dev/null; then
    die "$f still ensure_std_c_o migrated module"
  fi
done < <(find tests -name '*.sh' 2>/dev/null)
FORBIDDEN_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
# Pin product link for child dogfood (f03-core re-resolves; keep env honest).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

# Hard-delegate f06 with FAIL=1. f06 itself remains soft for its own knife,
# but this aggregator must not hide soft die→exit0.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-f06-runtime-std-o-cleanup-gate.sh ]; then
  echo "=== F-07: delegate run-f06-runtime-std-o-cleanup-gate (hard FAIL=1) ==="
  chmod +x tests/run-f06-runtime-std-o-cleanup-gate.sh
  if ! XLANG_F06_RUNTIME_CLEANUP_FAIL=1 tests/run-f06-runtime-std-o-cleanup-gate.sh; then
    die "f06 sub-gate failed"
  fi
  F06_OK=1
else
  die "missing tests/run-f06-runtime-std-o-cleanup-gate.sh"
fi

# f03-core is honesty-hard (soft XLANG_F03_CORE_FAIL retired).
if [ -f tests/run-f03-std-core-gate.sh ]; then
  echo "=== F-07: delegate run-f03-std-core-gate (hard) ==="
  chmod +x tests/run-f03-std-core-gate.sh
  if ! tests/run-f03-std-core-gate.sh; then
    die "f03-core sub-gate failed"
  fi
  F03_CORE_OK=1
else
  die "missing tests/run-f03-std-core-gate.sh"
fi
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} forbidden=${FORBIDDEN_OK} f06=${F06_OK} f03_core=${F03_CORE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f07 no-cc migrated std gate OK (F-07; honesty)"
