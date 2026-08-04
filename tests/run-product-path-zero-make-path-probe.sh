#!/usr/bin/env bash
# Product-path 0-make *runtime* PATH probe (C迁移 11.0.2 residual · wave726)
#
# Purpose:
#   Static gate freezes source-level `make` allowlists. This probe proves the
#   daily product path does not *exec* make when a shadow `make` is first on PATH.
#
# Scope (runtime, no cold bootstrap):
#   - ./xlang-build.sh help
#   - compiler/scripts/g05_relink_env.sh
#   - g05_ensure (G05_SKIP_HOT_REBUILD=1) when bootstrap/product binary exists
#   - g05_prepare_and_relink when ensure OK (optional full product relink)
#
# Not in scope:
#   - cold bootstrap-driver-seed (Makefile authority until xbuild absorbs OBJS)
#   - FULL=1 / bootstrap-driver-bstrict
#   - tests/lib/** make -C (stage 11.2.3)
#
# Usage (repo root):
#   ./tests/run-product-path-zero-make-path-probe.sh
# Exit: 0 = no make exec on product path; 1 = make was invoked or probe failed
#
# PLATFORM: SHARED — pure shell stub; no host binary dependency beyond bash/cc.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== 11.0.2 product-path 0-make PATH probe (wave726) ==="

fail=0
note() { echo "  OK  $*"; }
bad()  { echo "  FAIL $*" >&2; fail=1; }
skip() { echo "  SKIP $*"; }

STUB_DIR=$(mktemp -d "${TMPDIR:-/tmp}/xlang_path_probe.XXXXXX")
PROBE_LOG="$STUB_DIR/make_invocations.log"
: >"$PROBE_LOG"
cleanup() { rm -rf "$STUB_DIR"; }
trap cleanup EXIT

# Shadow make: log argv and hard-fail. Product path must never reach here.
cat >"$STUB_DIR/make" <<EOF
#!/bin/sh
# PLATFORM: SHARED — PATH probe stub; not a real make.
echo "PATH-PROBE: product path invoked make: \$*" >&2
printf '%s\n' "\$*" >>"$PROBE_LOG"
exit 99
EOF
chmod +x "$STUB_DIR/make"
# Also cover gmake / common alternate name if tools use it.
cp "$STUB_DIR/make" "$STUB_DIR/gmake"

# Prepend stub so any bare `make` hits the probe first.
export PATH="$STUB_DIR:$PATH"
export PATH_PROBE_LOG="$PROBE_LOG"

run_step() {
  local name="$1"
  shift
  echo "  -- $name"
  if "$@"; then
    note "$name"
  else
    bad "$name (exit $?)"
  fi
}

# 1) help is pure documentation — must not touch make
echo "  -- xlang-build help"
if ./xlang-build.sh help >/dev/null; then
  note "xlang-build help"
else
  bad "xlang-build help (exit $?)"
fi

# 2) g05 env export is shell-only authority for product relink lists
echo "  -- g05_relink_env"
if (cd compiler && bash scripts/g05_relink_env.sh >/dev/null); then
  note "g05_relink_env"
else
  bad "g05_relink_env (exit $?)"
fi

# 3–4) ensure / prepare only when a product bootstrap binary exists
has_bin=0
if [ -x compiler/xlang ] || [ -x compiler/xlang-c ] || [ -x compiler/bootstrap_xlangc ]; then
  has_bin=1
fi

if [ "$has_bin" -eq 0 ]; then
  skip "g05_ensure/prepare (no xlang/xlang-c/bootstrap_xlangc — cold tree; static gate still covers source)"
else
  # Skip hot cc rebuild: probe asserts make is not used for dependency *orchestration*
  # (cc -c on hot path is host-cc residual, not Makefile).
  if (cd compiler && G05_SKIP_HOT_REBUILD=1 bash scripts/g05_ensure_relink_prereqs.sh) >/tmp/xlang_path_probe_ensure.log 2>&1; then
    note "g05_ensure (SKIP_HOT_REBUILD=1)"
    # Full prepare: ensure + env + link. Real product daily path claim.
    if (cd compiler && G05_SKIP_HOT_REBUILD=1 G05_SYNC_ASM=1 bash scripts/g05_prepare_and_relink.sh) \
         >/tmp/xlang_path_probe_prepare.log 2>&1; then
      note "g05_prepare_and_relink (product daily path, PATH make=stub)"
    else
      # Missing .o → ensure fails with cold-start hint (echo make, not exec). Treat as soft.
      if grep -q 'bootstrap-driver-seed\|missing' /tmp/xlang_path_probe_prepare.log 2>/dev/null; then
        skip "g05_prepare incomplete tree (not a make-exec regression)"
      else
        bad "g05_prepare_and_relink failed (see /tmp/xlang_path_probe_prepare.log)"
        tail -20 /tmp/xlang_path_probe_prepare.log >&2 || true
      fi
    fi
  else
    if grep -qE 'missing|cold-start|bootstrap-driver-seed' /tmp/xlang_path_probe_ensure.log 2>/dev/null; then
      skip "g05_ensure incomplete tree (not a make-exec regression)"
    else
      bad "g05_ensure failed (see /tmp/xlang_path_probe_ensure.log)"
      tail -20 /tmp/xlang_path_probe_ensure.log >&2 || true
    fi
  fi
fi

# Any real make exec leaves a non-empty probe log
if [ -s "$PROBE_LOG" ]; then
  bad "make was executed under product PATH probe:"
  sed 's/^/    /' "$PROBE_LOG" >&2 || true
else
  note "no make/gmake exec recorded"
fi

echo "=== PATH probe summary ==="
if [ "$fail" -ne 0 ]; then
  echo "FAIL product-path 0-make PATH probe" >&2
  exit 1
fi
echo "OK product-path 0-make PATH probe (wave726)"
exit 0
