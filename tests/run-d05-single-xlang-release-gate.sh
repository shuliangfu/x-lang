#!/usr/bin/env bash
# D-05 v1：日常发布以 compiler/xlang 为单一入口（不依赖 xlang-c 冷启动）。
#
# 用法：./tests/run-d05-single-xlang-release-gate.sh
# 环境：
#   XLANG_D05_FAIL=1           — 失败时硬退出（soft FAIL retired; die always hard)
#   XLANG_D05_MANIFEST_ONLY=1  — 仅 manifest（leftover nested opt-in stay)
#   XLANG=./compiler/xlang      — 默认发布二进制
#
# wave honesty (2026-08-24 #12 / 2026-08-25 / 2026-08-26): DOC →
# analysis/archive/phase/; compiler/Makefile deleted — refuse resurrect;
# live entry = ./xbuild bootstrap-driver-bstrict (G.7). check gate paused —
# smoke uses -backend asm unless XLANG_D05_REQUIRE_CHECK=1.
# 2026-08-26: Soft XLANG_D05_FAIL retired (hard die; f11 hard-delegate).
# Honesty leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired.
# Honesty: leftover d05_native_exe third resolver retired (G.7 converge
# dod_native_exe). leftover ignore of explicit-bad (silent fallback to
# xlang_asm / DOC before resolve) retired. leftover SKIP→OK (missing
# native still gate OK) retired. Explicit-bad XLANG / missing native =
# hard die FIRST (before DOC / leftover nested smoke / leftover nested
# hash note). leftover nested product path (MANIFEST_ONLY / REQUIRE_CHECK
# / hash note / -backend asm -o smoke) stay.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Report: doc=/run=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

if [ -f analysis/phase-d-d05-v1.md ]; then
  echo "d05-single-xlang-release-gate gate FAIL: top-level DOC resurrected (live = archive/phase/)" >&2
  exit 1
fi

DOC="analysis/archive/phase/phase-d-d05-v1.md"
MANIFEST="tests/baseline/d05-single-xlang-release.tsv"
BOOT="compiler/bootstrap.sh"
PREFIX="xlang: [XLANG_D05]"
XLANG_ASM="./compiler/xlang_asm"

DOC_OK=0
RUN_OK=0
SKIP=1

die() {
  echo "d05 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# G.7: complete existing d05_native_exe. Explicit XLANG that is missing
# or non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# leftover d05_native_exe third resolver retired — converge
# dod_native_exe. Do not restore set -e before return 1.
# Prefer xlang_asm then xlang (NOT xlang-c) — D-05 daily entry is not
# xlang-c cold start. PLATFORM: SHARED — product path honesty; Ubuntu
# gold still required.
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

# Explicit XLANG that is missing/non-native hard-dies BEFORE DOC /
# leftover nested smoke / leftover nested hash note (refuse leftover
# d05_native_exe / leftover ignore of explicit-bad / leftover SKIP→OK).
# leftover nested product path stays when XLANG is unset.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover d05_native_exe / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== D-05: single xlang release (v1) ==="
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
for f in "$DOC" "$MANIFEST" xbuild xlang-build.sh "$BOOT" README.md compiler/docs/SELFHOST.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-05 v1' "$DOC" || die "doc missing D-05 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

grep -qE '^[[:space:]]*bootstrap-driver-bstrict\)' xlang-build.sh \
  || die "xlang-build.sh missing bootstrap-driver-bstrict route"
grep -qE 'bootstrap-driver-bstrict|\./xbuild full' README.md \
  || die "README missing bootstrap-driver-bstrict / ./xbuild full"
grep -q 'D-05' compiler/docs/SELFHOST.md || die "SELFHOST missing D-05"

# manifest gate_ref
MISS=0
while IFS=$'\t' read -r item_id _layer anchor check_type _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    [ -f "$anchor" ] || { echo "d05 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"
DOC_OK=1

# leftover nested MANIFEST_ONLY opt-in stay (explicit skip smoke after DOC).
# Explicit-bad already died FIRST. PLATFORM: SHARED archaeology.
if [ "${XLANG_D05_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "${PREFIX} status=ok doc=${DOC_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
  echo "d05 single-xlang-release gate OK (manifest only)"
  exit 0
fi

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover d05_native_exe / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm (refuse leftover d05_native_exe / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0

# leftover nested product: --lsp note / --help empty fallback stay.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
HELP_OUT=$("$XLANG_BIN" --help 2>&1 || true)
if ! printf '%s' "$HELP_OUT" | grep -q '\-\-lsp'; then
  echo "d05 note: $XLANG_BIN missing --lsp in --help (may need bootstrap-driver-seed)" >&2
fi
# 部分 B-strict 链路上 --help 为空（driver_print_usage 弱桩/未链入）；用 -backend 行为探测兜底
if ! printf '%s' "$HELP_OUT" | grep -qE '\-backend|backend'; then
  if "$XLANG_BIN" -backend asm check -L . tests/c07/minimal_return42.x >/dev/null 2>&1 \
    || "$XLANG_BIN" -backend asm check -L . examples/hello.x >/dev/null 2>&1; then
    echo "d05 note: --help empty/missing -backend text; -backend asm check OK" >&2
  else
    die "$XLANG_BIN missing -backend (help empty and -backend asm check failed)"
  fi
fi

# leftover nested product: check paused unless REQUIRE_CHECK=1; default
# -backend asm -o smoke stays hard. PLATFORM: SHARED archaeology.
SMOKE="tests/c07/minimal_return42.x"
[ -f "$SMOKE" ] || SMOKE="examples/hello.x"
if [ "${XLANG_D05_REQUIRE_CHECK:-0}" = "1" ]; then
  if ! "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    "$XLANG_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    die "xlang check failed ($SMOKE)"
  fi
  echo "d05 OK: $XLANG_BIN check $SMOKE (XLANG_D05_REQUIRE_CHECK=1)"
  RUN_OK=1
else
  if ! "$XLANG_BIN" -backend asm -L . "$SMOKE" -o /tmp/d05_smoke_$$ >/dev/null 2>&1; then
    "$XLANG_BIN" -backend asm -L . "$SMOKE" -o /tmp/d05_smoke_$$ 2>&1 | tail -8 >&2 || true
    rm -f /tmp/d05_smoke_$$
    die "xlang -backend asm -o failed ($SMOKE)"
  fi
  rm -f /tmp/d05_smoke_$$
  echo "d05 OK: $XLANG_BIN -backend asm -o $SMOKE (check gate paused; REQUIRE_CHECK=1 to hard-check)"
  RUN_OK=1
fi

# leftover nested product: xlang vs xlang_asm hash note stay (hard only
# when XLANG_D05_REQUIRE_ASM_HASH=1). PLATFORM: SHARED archaeology.
if [ -x "$XLANG_ASM" ] && dod_native_exe "$XLANG_ASM" && [ -x "./compiler/xlang" ] && dod_native_exe "./compiler/xlang"; then
  if command -v shasum >/dev/null 2>&1; then
    H1=$(shasum -a 256 "./compiler/xlang" | awk '{print $1}')
    H2=$(shasum -a 256 "$XLANG_ASM" | awk '{print $1}')
    if [ "$H1" != "$H2" ]; then
      echo "d05 note: xlang != xlang_asm hash (sync: ./xbuild link-product-asm / refresh-gate)" >&2
      if [ "${XLANG_D05_REQUIRE_ASM_HASH:-0}" = "1" ]; then
        die "xlang and xlang_asm differ (XLANG_D05_REQUIRE_ASM_HASH=1)"
      fi
    else
      echo "d05 OK: compiler/xlang matches xlang_asm (release binary)"
    fi
  fi
fi

echo "${PREFIX} status=ok doc=${DOC_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "d05 single-xlang-release gate OK (daily XLANG=$XLANG_BIN, no xlang-c cold start required)"
