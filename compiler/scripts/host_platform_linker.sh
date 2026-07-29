#!/usr/bin/env bash
# host_platform_linker.sh — 11.1.3 host platform facts + 11.1.4 linker policy inventory
#
# Authority (G.7):
#   Single shell authority for *host OS/arch facts* and *named linker residual*
#   inventory under Track MG. Does NOT own .o lists (compiler/mk/*.mk) and does
#   NOT re-implement cold/product link (bootstrap_driver_seed_link / g05 /
#   xlang_asm_invoke_ld_* remain the body authorities).
#
# Human map: compiler/docs/PLATFORM_LINKER.md
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/host_platform_linker.sh              # dump all
#   bash compiler/scripts/host_platform_linker.sh platform     # host facts only
#   bash compiler/scripts/host_platform_linker.sh linker       # linker residual inventory
#   bash compiler/scripts/host_platform_linker.sh --export     # shell-sourceable KEY=value
#   bash compiler/scripts/host_platform_linker.sh --check
#   ./xbuild host-platform | linker-policy [--check|--export]
#
# PLATFORM: SHARED — detection portable; leaf ABI stays in mk / product link path.
# Wave: 745 Track MG · 11.1.3 + 11.1.4 policy slice.
# Wave: 772 Track MG · 11.1.4 pure-ld prefer in bootstrap_driver_seed_link (CC residual fallback).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"

MODE="${1:-dump}"
case "$MODE" in
  --check|check|-c) MODE=check ;;
  --export|export|-e) MODE=export ;;
  platform|host|os|arch) MODE=platform ;;
  linker|link|ld|policy) MODE=linker ;;
  dump|all|"") MODE=dump ;;
  help|-h|--help)
    sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "host_platform_linker: unknown mode '$MODE' (platform|linker|dump|export|check)" >&2
    exit 2
    ;;
esac

fail=0
note() { echo "host_platform_linker: $*" >&2; }
bad() { echo "host_platform_linker: FAIL: $*" >&2; fail=1; }

# ---------------------------------------------------------------------------
# 11.1.3 detect host (single authority for shell consumers)
# ---------------------------------------------------------------------------
detect_host() {
  # Raw uname (empty → Unknown)
  XLANG_HOST_UNAME_S="$(uname -s 2>/dev/null || echo Unknown)"
  XLANG_HOST_UNAME_M="$(uname -m 2>/dev/null || echo unknown)"

  # Windows host: Makefile uses OS=Windows_NT; MSYS/MINGW also via uname.
  XLANG_HOST_IS_WINDOWS=0
  XLANG_HOST_IS_DARWIN=0
  XLANG_HOST_IS_LINUX=0
  XLANG_HOST_OS=unknown
  XLANG_PLATFORM_TAG=UNKNOWN

  if [ "${OS:-}" = "Windows_NT" ]; then
    XLANG_HOST_IS_WINDOWS=1
    XLANG_HOST_OS=windows
    XLANG_PLATFORM_TAG=WINDOWS
  else
    case "$XLANG_HOST_UNAME_S" in
      Darwin)
        XLANG_HOST_IS_DARWIN=1
        XLANG_HOST_OS=darwin
        XLANG_PLATFORM_TAG=MACOS
        ;;
      Linux)
        XLANG_HOST_IS_LINUX=1
        XLANG_HOST_OS=linux
        XLANG_PLATFORM_TAG=LINUX
        ;;
      MINGW*|MSYS*|CYGWIN*)
        XLANG_HOST_IS_WINDOWS=1
        XLANG_HOST_OS=windows
        XLANG_PLATFORM_TAG=WINDOWS
        ;;
      *)
        XLANG_HOST_OS=unknown
        XLANG_PLATFORM_TAG=UNKNOWN
        ;;
    esac
  fi

  # Normalize arch for stamps / diagnostics (do not invent second crt0 table).
  case "$XLANG_HOST_UNAME_M" in
    x86_64|amd64) XLANG_HOST_ARCH=x86_64 ;;
    arm64) XLANG_HOST_ARCH=arm64 ;;
    aarch64) XLANG_HOST_ARCH=aarch64 ;;
    i386|i686) XLANG_HOST_ARCH=x86 ;;
    *) XLANG_HOST_ARCH="$XLANG_HOST_UNAME_M" ;;
  esac

  XLANG_HOST_ALPINE=0
  if [ -f /etc/alpine-release ]; then
    XLANG_HOST_ALPINE=1
  fi

  # Product pin presence (SHARED: linux.x86_64 pin is host-portable C).
  XLANG_SEED_PIN_LINUX_X86_64_OK=0
  if [ -f "$COMPILER_DIR/seeds/parser_gen.linux.x86_64.c" ]; then
    XLANG_SEED_PIN_LINUX_X86_64_OK=1
  fi

  # Diagnostic-only ld partial-link arch flag (Makefile LD_RELFLAGS remains
  # authoritative for cold recipes until 11.3.1).
  XLANG_LD_RELFLAGS_HINT=
  if [ "$XLANG_HOST_IS_DARWIN" = 1 ]; then
    case "$XLANG_HOST_ARCH" in
      arm64|aarch64) XLANG_LD_RELFLAGS_HINT="-arch arm64" ;;
      x86_64) XLANG_LD_RELFLAGS_HINT="-arch x86_64" ;;
    esac
    XLANG_LD_FILTER_EXPORT_HINT="-exported_symbols_list"
    XLANG_LD_FILTER_USE_VER_HINT=0
  else
    XLANG_LD_FILTER_EXPORT_HINT="--version-script"
    XLANG_LD_FILTER_USE_VER_HINT=1
  fi

  # Preferred host linkers (presence probe only — not a second link path).
  XLANG_HOST_LD_BIN="$(command -v ld 2>/dev/null || true)"
  XLANG_HOST_LLD_BIN="$(command -v lld 2>/dev/null || true)"
  XLANG_HOST_CC_BIN="$(command -v "${CC:-cc}" 2>/dev/null || true)"
}

print_platform() {
  detect_host
  cat <<EOF
# host platform (11.1.3 · wave745)
XLANG_HOST_OS=$XLANG_HOST_OS
XLANG_HOST_ARCH=$XLANG_HOST_ARCH
XLANG_HOST_UNAME_S=$XLANG_HOST_UNAME_S
XLANG_HOST_UNAME_M=$XLANG_HOST_UNAME_M
XLANG_HOST_IS_LINUX=$XLANG_HOST_IS_LINUX
XLANG_HOST_IS_DARWIN=$XLANG_HOST_IS_DARWIN
XLANG_HOST_IS_WINDOWS=$XLANG_HOST_IS_WINDOWS
XLANG_HOST_ALPINE=$XLANG_HOST_ALPINE
XLANG_PLATFORM_TAG=$XLANG_PLATFORM_TAG
XLANG_SEED_PIN_LINUX_X86_64_OK=$XLANG_SEED_PIN_LINUX_X86_64_OK
XLANG_LD_RELFLAGS_HINT=$XLANG_LD_RELFLAGS_HINT
XLANG_LD_FILTER_EXPORT_HINT=$XLANG_LD_FILTER_EXPORT_HINT
XLANG_LD_FILTER_USE_VER_HINT=$XLANG_LD_FILTER_USE_VER_HINT
XLANG_HOST_LD_BIN=$XLANG_HOST_LD_BIN
XLANG_HOST_LLD_BIN=$XLANG_HOST_LLD_BIN
XLANG_HOST_CC_BIN=$XLANG_HOST_CC_BIN
EOF
}

print_export() {
  detect_host
  # shell-sourceable: no comments
  cat <<EOF
export XLANG_HOST_OS='$XLANG_HOST_OS'
export XLANG_HOST_ARCH='$XLANG_HOST_ARCH'
export XLANG_HOST_UNAME_S='$XLANG_HOST_UNAME_S'
export XLANG_HOST_UNAME_M='$XLANG_HOST_UNAME_M'
export XLANG_HOST_IS_LINUX='$XLANG_HOST_IS_LINUX'
export XLANG_HOST_IS_DARWIN='$XLANG_HOST_IS_DARWIN'
export XLANG_HOST_IS_WINDOWS='$XLANG_HOST_IS_WINDOWS'
export XLANG_HOST_ALPINE='$XLANG_HOST_ALPINE'
export XLANG_PLATFORM_TAG='$XLANG_PLATFORM_TAG'
export XLANG_SEED_PIN_LINUX_X86_64_OK='$XLANG_SEED_PIN_LINUX_X86_64_OK'
export XLANG_LD_RELFLAGS_HINT='$XLANG_LD_RELFLAGS_HINT'
export XLANG_LD_FILTER_EXPORT_HINT='$XLANG_LD_FILTER_EXPORT_HINT'
export XLANG_LD_FILTER_USE_VER_HINT='$XLANG_LD_FILTER_USE_VER_HINT'
EOF
}

print_linker() {
  detect_host
  cat <<EOF
# linker policy inventory (11.1.4 · wave745 · wave772 pure-ld prefer)
# Prefer: product xlang_asm_invoke_ld_platform / direct ld|lld|link.exe
# Cold phase1/final: pure-ld default when SEED_LINK_PURE_OK=1; CC residual fallback

LINKER_POLICY=prefer_direct_ld_then_named_cc_residual
LINKER_FORBIDDEN_DEFAULT=silent_cc_as_linker_without_inventory

# Cold seed link body (G.7 single authority)
COLD_SEED_LINK_BODY=scripts/bootstrap_driver_seed_link.sh
COLD_SEED_LINK_PURE_LD=1
COLD_SEED_LINK_PURE_LD_VIA=SEED_LINK_LD+MULTIDEF+ENTRY+LD_TAIL_export
COLD_SEED_LINK_CC_FALLBACK=SEED_LINK_CC_-o_when_PURE_OK_0_or_FORCE_CC_or_pure_fail
RESIDUAL_CC_LINK_SITE=scripts/bootstrap_driver_seed_link.sh
RESIDUAL_CC_LINK_ROLE=cold_phase1_final_SEED_LINK_CC_fallback
RESIDUAL_CC_LINK_LIST_AUTHORITY=Makefile_export_bootstrap-driver-seed-export-phase1/final-link

# Preferred direct-ld / product paths (do not reimplement)
PREFERRED_LD_PARTIAL=scripts/filter_bootstrap_seed_pipeline_o.sh
PREFERRED_PRODUCT_LD=xlang_asm_invoke_ld_platform
PREFERRED_G05_RELINK=scripts/g05_relink_xlang.sh
PREFERRED_COLD_PURE_LD=scripts/bootstrap_driver_seed_link.sh

# Host tool presence (probe only)
HOST_LD_PRESENT=$([ -n "$XLANG_HOST_LD_BIN" ] && echo 1 || echo 0)
HOST_LLD_PRESENT=$([ -n "$XLANG_HOST_LLD_BIN" ] && echo 1 || echo 0)
HOST_CC_PRESENT=$([ -n "$XLANG_HOST_CC_BIN" ] && echo 1 || echo 0)
HOST_LD_BIN=$XLANG_HOST_LD_BIN
HOST_CC_BIN=$XLANG_HOST_CC_BIN

# Endgame markers (wave772: cold pure-ld path live; UNAME leaf still Makefile)
ENDGAME_COLD_LINK_WITHOUT_CC=1
ENDGAME_MAKEFILE_UNAME_SWALLOWED=0
EOF
}

if [ "$MODE" = platform ]; then
  print_platform
  exit 0
fi

if [ "$MODE" = linker ]; then
  print_linker
  exit 0
fi

if [ "$MODE" = export ]; then
  print_export
  exit 0
fi

if [ "$MODE" = dump ]; then
  print_platform
  echo
  print_linker
  exit 0
fi

# ---- check mode ----
cd "$ROOT"
DOC_REL="compiler/docs/PLATFORM_LINKER.md"
SCRIPT_REL="compiler/scripts/host_platform_linker.sh"
XBUILD_REL="xlang-build.sh"
LINK_BODY="compiler/scripts/bootstrap_driver_seed_link.sh"

if [ ! -f "$DOC_REL" ]; then
  bad "missing $DOC_REL (11.1.3/4 authority map)"
else
  if ! grep -q '11\.1\.3' "$DOC_REL" || ! grep -q '11\.1\.4' "$DOC_REL"; then
    bad "$DOC_REL must document 11.1.3 and 11.1.4"
  fi
  if ! grep -qiE 'prefer.*ld|direct.*ld|forbid.*CC|\$\(CC\).* -o|CC -o' "$DOC_REL"; then
    bad "$DOC_REL must state prefer direct ld / named residual CC -o"
  fi
  if ! grep -qiE 'seed pin|linux\.x86_64|host-portable' "$DOC_REL"; then
    bad "$DOC_REL must document product seed pin policy"
  fi
  if ! grep -qi 'Do not.*\.o\|not.*own.*\.o\|lists stay mk\|no dual' "$DOC_REL"; then
    bad "$DOC_REL must ban dual .o inventories (G.7)"
  fi
  note "doc $DOC_REL present"
fi

if [ ! -f "$SCRIPT_REL" ]; then
  bad "missing $SCRIPT_REL"
fi

# Live dump must produce host OS + residual site
_plat_out="$(bash "$SCRIPT_REL" platform 2>/dev/null || true)"
if ! printf '%s\n' "$_plat_out" | grep -qE '^XLANG_HOST_OS=(linux|darwin|windows|unknown)$'; then
  bad "platform dump missing XLANG_HOST_OS"
else
  note "platform dump OK: $(printf '%s\n' "$_plat_out" | grep '^XLANG_HOST_OS=')"
fi
if ! printf '%s\n' "$_plat_out" | grep -q '^XLANG_PLATFORM_TAG='; then
  bad "platform dump missing XLANG_PLATFORM_TAG"
fi
if ! printf '%s\n' "$_plat_out" | grep -q '^XLANG_SEED_PIN_LINUX_X86_64_OK='; then
  bad "platform dump missing seed pin key"
fi

_link_out="$(bash "$SCRIPT_REL" linker 2>/dev/null || true)"
if ! printf '%s\n' "$_link_out" | grep -q 'RESIDUAL_CC_LINK_SITE=scripts/bootstrap_driver_seed_link.sh'; then
  bad "linker dump must name residual bootstrap_driver_seed_link.sh"
fi
if ! printf '%s\n' "$_link_out" | grep -q 'PREFERRED_PRODUCT_LD=xlang_asm_invoke_ld_platform'; then
  bad "linker dump must name preferred product ld path"
fi
if ! printf '%s\n' "$_link_out" | grep -q 'LINKER_POLICY=prefer_direct_ld'; then
  bad "linker dump missing LINKER_POLICY"
else
  note "linker inventory dump OK"
fi

# Cold seed link body: pure-ld prefer + CC residual (wave772 · G.7 single body)
if [ ! -f "$LINK_BODY" ]; then
  bad "missing cold link body $LINK_BODY"
elif ! grep -q 'SEED_LINK_PURE_OK\|try_pure_ld\|pure-ld' "$LINK_BODY"; then
  bad "$LINK_BODY must prefer pure-ld (SEED_LINK_PURE_OK / try_pure_ld) wave772"
elif ! grep -q 'SEED_LINK_CC' "$LINK_BODY"; then
  bad "$LINK_BODY must keep SEED_LINK_CC residual fallback"
else
  note "cold link body pure-ld prefer + CC residual present (wave772)"
fi
if ! grep -q 'SEED_LINK_PURE_OK\|SEED_LINK_LD\|SEED_LINK_MULTIDEF' compiler/Makefile; then
  bad "Makefile export must emit SEED_LINK_LD/MULTIDEF/PURE_OK (wave772 pure-ld)"
else
  note "Makefile pure-ld export keys present"
fi

# Prefer-path scripts present
if [ ! -f compiler/scripts/filter_bootstrap_seed_pipeline_o.sh ]; then
  bad "missing preferred ld-partial script filter_bootstrap_seed_pipeline_o.sh"
else
  note "preferred ld-partial filter script present"
fi

# xbuild wiring
if [ ! -f "$XBUILD_REL" ]; then
  bad "missing $XBUILD_REL"
elif ! grep -qE 'host-platform|platform-host|linker-policy' "$XBUILD_REL" \
  || ! grep -q 'host_platform_linker\.sh' "$XBUILD_REL"; then
  bad "xlang-build.sh must wire host-platform / linker-policy → host_platform_linker.sh"
else
  note "xbuild host-platform / linker-policy wired"
fi

# build.x strategy map
if [ -f build.x ]; then
  if ! grep -qE '11\.1\.3|host.platform|PLATFORM_LINKER' build.x; then
    bad "build.x must mention 11.1.3 / host platform / PLATFORM_LINKER"
  fi
  if ! grep -qE '11\.1\.4|linker.policy|direct.*ld|SEED_LINK_CC' build.x; then
    bad "build.x must mention 11.1.4 / linker policy"
  fi
  note "build.x references 11.1.3/4"
else
  bad "missing root build.x"
fi

# BUILD_DAG cross-ref
if [ -f compiler/docs/BUILD_DAG.md ]; then
  if ! grep -qE '11\.1\.3|PLATFORM_LINKER|host_platform_linker|wave745' compiler/docs/BUILD_DAG.md; then
    bad "BUILD_DAG.md must cross-ref 11.1.3/4 / PLATFORM_LINKER / wave745"
  else
    note "BUILD_DAG.md cross-ref OK"
  fi
else
  bad "missing compiler/docs/BUILD_DAG.md"
fi

# G.7: this script must not hardcode product .o inventories
if grep -nE '[a-zA-Z0-9_./-]+\.o' "$SCRIPT_DIR/host_platform_linker.sh" \
  | grep -vE '^\s*#|\.o invent|dual|\.mk|list|not.*\.o|hardcode|pattern' \
  | grep -qE '[a-zA-Z0-9_/]+\.o'; then
  hits=$(grep -nE '[a-zA-Z0-9_./-]+\.o' "$SCRIPT_DIR/host_platform_linker.sh" \
    | grep -vE '^\s*#|inventor|hardcode|catalog|\.mk|lists|dual|not ' || true)
  if [ -n "$hits" ]; then
    # Allow only comments; any real code .o path is dual-list risk
    code_hits=$(printf '%s\n' "$hits" | grep -vE ':[0-9]+:[[:space:]]*#' || true)
    if [ -n "$code_hits" ]; then
      bad "host_platform_linker.sh must not hardcode .o paths (G.7):"
      echo "$code_hits" | head -10 >&2
    fi
  fi
fi

unset _plat_out _link_out

if [ "$fail" -ne 0 ]; then
  echo "host_platform_linker: CHECK FAIL" >&2
  exit 1
fi
echo "host_platform_linker: CHECK OK (11.1.3 platform + 11.1.4 linker policy · wave745)"
exit 0
