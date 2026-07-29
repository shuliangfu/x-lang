#!/usr/bin/env bash
# Product-path 0-make static gate (C迁移 11.0.2 · wave714)
#
# Purpose:
#   G-05 product path claims "no make" for daily relink. This gate freezes that
#   contract with a static allowlist so new `make` calls cannot regress silently.
#
# Scope (static only — does not rebuild the compiler):
#   - compiler/scripts/g05_*.sh daily chain
#   - repo-root xlang-build.sh product targets (document remaining make)
#
# Not in scope (tracked elsewhere):
#   - FULL=1 / bootstrap-driver-seed cold start (Makefile authority until 11.0.3)
#   - tests/lib/** make -C (stage 11.2.3)
#   - CI workflows (stage 11.2.5)
#
# Usage (repo root):
#   ./tests/run-product-path-zero-make-gate.sh
# Exit: 0 = OK, 1 = new make invocation outside allowlist or missing product entry
#
# PLATFORM: SHARED — pure shell; no host binary dependency.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== 11.0.2 product-path 0-make static gate (wave714) ==="

fail=0
note() { echo "  OK  $*"; }
bad()  { echo "  FAIL $*" >&2; fail=1; }
warn() { echo "  WARN $*" >&2; }

# --- required product-path files ---
for f in \
  xlang-build.sh \
  build.x \
  analysis/Makefile迁移表.md \
  compiler/scripts/g05_build_xlang_asm.sh \
  compiler/scripts/g05_prepare_and_relink.sh \
  compiler/scripts/g05_ensure_relink_prereqs.sh \
  compiler/scripts/g05_relink_env.sh \
  compiler/scripts/g05_relink_xlang.sh
do
  [ -f "$f" ] || bad "missing $f"
done
[ "$fail" -eq 0 ] && note "product-path files present"

# --- default g05 must not exec make xlang_asm (must go prepare_and_relink) ---
if grep -q 'g05_prepare_and_relink' compiler/scripts/g05_build_xlang_asm.sh; then
  note "g05_build_xlang_asm default → g05_prepare_and_relink"
else
  bad "g05_build_xlang_asm.sh must invoke g05_prepare_and_relink on default path"
fi

# FULL=1 may still call make (non-daily); must be gated on FULL env
if grep -n 'bootstrap-driver-bstrict' compiler/scripts/g05_build_xlang_asm.sh | grep -q 'FULL'; then
  note "FULL=1 bstrict still make (allowed non-daily)"
elif grep -q 'bootstrap-driver-bstrict' compiler/scripts/g05_build_xlang_asm.sh; then
  note "FULL path references bootstrap-driver-bstrict (document as cold/full)"
else
  warn "no FULL=1 bstrict path found (ok if migrated)"
fi

# --- scan g05 daily scripts for make invocations ---
# Allowlist: exact substring matches on the code line (after strip comments).
# Update this list only when intentionally keeping a make call + document in
# analysis/Makefile迁移表.md §5.
ALLOW_PATTERNS=(
  # non-daily full rebuild
  'exec make bootstrap-driver-bstrict'
  # known product leak: Darwin filtered pipeline.o (debt → pure shell ld -r)
  'make -s "$_filt"'
  'make -s $_filt'
  # error hints to user for cold start (not product build)
  'make -C compiler bootstrap-driver-seed'
  'make -C compiler build-seed-asm-host'
  # Makefile header comments in echo (cold-start guidance)
  'Makefile 冷启动'
  'make bootstrap-driver-seed'
  'make bootstrap-driver-bstrict'
)

# Extract non-comment lines that mention make as a command-ish token.
# shellcheck: intentional scan
scan_make_lines() {
  local file="$1"
  # drop full-line comments and trailing comments roughly
  grep -nE '(^|[^A-Za-z0-9_])make([ \t]|$|")' "$file" 2>/dev/null \
    | grep -vE '^[0-9]+:[ \t]*#' \
    | grep -vE '^[0-9]+:.*#.*\bmake\b' \
    || true
}

is_allowed() {
  local line="$1"
  local p
  for p in "${ALLOW_PATTERNS[@]}"; do
    case "$line" in
      *"$p"*) return 0 ;;
    esac
  done
  # pure documentation / echo strings that only mention make in prose
  if echo "$line" | grep -qE 'echo .*make'; then
    return 0
  fi
  if echo "$line" | grep -qE '^\s*[0-9]+:\s*#'; then
    return 0
  fi
  return 1
}

G05_DAILY=(
  compiler/scripts/g05_build_xlang_asm.sh
  compiler/scripts/g05_prepare_and_relink.sh
  compiler/scripts/g05_ensure_relink_prereqs.sh
  compiler/scripts/g05_relink_env.sh
  compiler/scripts/g05_relink_xlang.sh
)

new_hits=0
known_leak_hits=0
for f in "${G05_DAILY[@]}"; do
  while IFS= read -r hit; do
    [ -z "$hit" ] && continue
    if is_allowed "$hit"; then
      if echo "$hit" | grep -q 'make -s'; then
        known_leak_hits=$((known_leak_hits + 1))
      fi
      continue
    fi
    # allow "no make" / "零 make" / "不调用 make" contract strings
    if echo "$hit" | grep -qiE 'no make|零 make|不.*make|without make|不调用 make|不依赖 make'; then
      continue
    fi
    bad "new/undocumented make in $hit"
    new_hits=$((new_hits + 1))
  done < <(scan_make_lines "$f")
done

if [ "$known_leak_hits" -gt 0 ]; then
  warn "known product make leak still present (filtered.o make -s) count=$known_leak_hits — see Makefile迁移表 §5; fix in 11.0.2 residual"
else
  note "no make -s filtered.o leak (good if already pure shell)"
fi

if [ "$new_hits" -eq 0 ]; then
  note "g05 daily scripts: no make outside allowlist"
fi

# --- xlang-build.sh: product default must not hard-require make for build when build_tool exists ---
# Contract text: build path uses build_tool; make only for build-tool/first-time/clean/test*
if grep -q 'run_build_tool' xlang-build.sh || grep -q 'build_tool' xlang-build.sh; then
  note "xlang-build.sh routes daily build via build_tool"
else
  bad "xlang-build.sh missing build_tool daily path"
fi

# inventory remaining make -C in xlang-build (informational; not hard-fail yet)
xb_make=$(grep -cE 'make -C compiler' xlang-build.sh || true)
echo "  INFO xlang-build.sh make -C compiler sites: ${xb_make:-0} (expected: build-tool/first-time/clean/test*; shrink in 11.0.3)"

# --- migration table exists and mentions classes ---
if grep -q '11.0.1' analysis/Makefile迁移表.md && grep -q 'xbuild link-product' analysis/Makefile迁移表.md; then
  note "Makefile迁移表.md present (11.0.1 inventory)"
else
  bad "analysis/Makefile迁移表.md incomplete"
fi

# --- C迁移 11.0.1 checked ---
if grep -q '11.0.1' analysis/C迁移追踪.md && grep -q 'Makefile迁移表' analysis/C迁移追踪.md; then
  note "C迁移追踪 links migration table"
else
  bad "C迁移追踪.md missing 11.0.1 / migration table link"
fi

echo "=== gate summary ==="
if [ "$fail" -ne 0 ]; then
  echo "FAIL product-path 0-make static gate" >&2
  exit 1
fi
echo "OK product-path 0-make static gate (allowlist frozen; known filtered.o leak documented)"
exit 0
