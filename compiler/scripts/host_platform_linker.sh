#!/usr/bin/env bash
# host_platform_linker.sh — 11.1.3 host platform facts + 11.1.4 linker policy inventory
#
# Authority (G.7 · 10.4 knife 11.04 demote):
#   Live *host OS/arch facts* (uname) stay in this shell. *Named linker-policy*
#   KEY=VALUE inventory authority = root build.x export ABI
#   (build_linker_policy_count / build_linker_policy_entry_at); this script
#   holds a derived bash cache only. Does NOT own .o lists (compiler/mk/*.mk)
#   and does NOT re-implement cold/product link bodies.
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
# Wave: 772 pure-ld cold · 773 g05 pure-ld · 774 drop silent CC residual fallback.

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
# 10.4 / knife 11.04: LINKER_POLICY inventory authority = build.x export ABI.
# Bash LINKER_POLICY_ENTRIES is a derived runtime cache. G.7: no hardcoded
# KEY=VALUE inventory literal that could drift from build.x.
# Live uname host detect stays below (facts, not policy dual).
# ---------------------------------------------------------------------------
LINKER_POLICY_ENTRIES=()

# Load linker-policy KEY=VALUE entries from root build.x (source-parse; no tip).
# PLATFORM: SHARED — paths via $ROOT; dual-end L2.
load_linker_policy_from_build_x() {
  local bx="$ROOT/build.x"
  local _bx_entries _ent
  LINKER_POLICY_ENTRIES=()
  if [ ! -f "$bx" ]; then
    echo "host_platform_linker: FAIL: missing $bx (LINKER_POLICY authority)" >&2
    return 1
  fi
  if ! grep -q 'export function build_linker_policy_count' "$bx" \
    || ! grep -q 'export function build_linker_policy_entry_at' "$bx"; then
    echo "host_platform_linker: FAIL: build.x missing LINKER_POLICY export ABI" >&2
    return 1
  fi
  _bx_entries=$(
    awk '
      /export function build_linker_policy_entry_at[[:space:]]*\(/ { in_fn=1; next }
      in_fn && /return[[:space:]]+"/ {
        if (match($0, /"[^"]+"/)) {
          print substr($0, RSTART + 1, RLENGTH - 2)
        }
        next
      }
      in_fn && /^}/ { exit }
    ' "$bx"
  )
  while IFS= read -r _ent; do
    [ -z "${_ent:-}" ] && continue
    LINKER_POLICY_ENTRIES+=("${_ent}")
  done <<< "${_bx_entries}"
  if [ "${#LINKER_POLICY_ENTRIES[@]}" -eq 0 ]; then
    echo "host_platform_linker: FAIL: build.x linker_policy entry_at parsed 0" >&2
    return 1
  fi
  return 0
}

if ! load_linker_policy_from_build_x; then
  exit 1
fi

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
      Windows_NT*|MINGW*|MSYS*|CYGWIN*)
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
  local _ent
  detect_host
  cat <<EOF
# linker policy inventory (11.1.4 · wave745 · 10.4 knife 11.04 demote)
# Authority: build.x build_linker_policy_* (derived cache below). Host probes only.
# Prefer: product xlang_asm_invoke_ld_platform / direct ld|lld|link.exe
EOF
  for _ent in "${LINKER_POLICY_ENTRIES[@]}"; do
    printf '%s
' "$_ent"
  done
  cat <<EOF

# Host tool presence (probe only · not build.x policy inventory)
HOST_LD_PRESENT=$([ -n "$XLANG_HOST_LD_BIN" ] && echo 1 || echo 0)
HOST_LLD_PRESENT=$([ -n "$XLANG_HOST_LLD_BIN" ] && echo 1 || echo 0)
HOST_CC_PRESENT=$([ -n "$XLANG_HOST_CC_BIN" ] && echo 1 || echo 0)
HOST_LD_BIN=$XLANG_HOST_LD_BIN
HOST_CC_BIN=$XLANG_HOST_CC_BIN
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
XCODE_REL="xlang-build.sh"
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

# Cold seed link body: pure-ld required when eligible; named CC residual only (wave774)
if [ ! -f "$LINK_BODY" ]; then
  bad "missing cold link body $LINK_BODY"
elif ! grep -q 'SEED_LINK_PURE_OK\|run_pure_ld_required\|pure-ld' "$LINK_BODY"; then
  bad "$LINK_BODY must require pure-ld when eligible (SEED_LINK_PURE_OK / run_pure_ld_required) wave774"
elif ! grep -q 'SEED_LINK_CC' "$LINK_BODY"; then
  bad "$LINK_BODY must keep SEED_LINK_CC named residual (FORCE_CC / ineligible)"
elif ! grep -q 'pure_ld_shared' "$LINK_BODY"; then
  bad "$LINK_BODY must source pure_ld_shared.sh (wave773 G.7 extract)"
elif grep -qE 'falling back to.*(CC|SEED_LINK_CC)' "$LINK_BODY"; then
  bad "$LINK_BODY must not silently fall back to CC after pure-ld fail (wave774)"
else
  note "cold link body pure-ld required + named CC residual + pure_ld_shared (wave772/774)"
fi
# wave946 post_ship: Makefile deleted (wave941). Authority is shell pure-ld + catalog.
if [ -f compiler/Makefile ]; then
  if ! grep -q 'SEED_LINK_PURE_OK\|SEED_LINK_LD\|SEED_LINK_MULTIDEF' compiler/Makefile; then
    bad "Makefile export must emit SEED_LINK_LD/MULTIDEF/PURE_OK (wave772 pure-ld)"
  else
    note "Makefile pure-ld export keys present"
  fi
elif [ -f compiler/scripts/pure_ld_shared.sh ] \
  && grep -q 'SEED_LINK_PURE_OK\|pure_ld_try_link\|SEED_LINK_LD\|SEED_LINK_MULTIDEF' \
       compiler/scripts/pure_ld_shared.sh compiler/scripts/bootstrap_driver_seed_link.sh 2>/dev/null; then
  note "Makefile absent (wave946 post_ship): pure-ld authority in shell (pure_ld_shared + seed link)"
else
  bad "Makefile absent and pure-ld shell authority missing SEED_LINK_* / pure_ld_try_link (wave946)"
fi

# wave773/774: g05 product pure-ld required; no silent CC fallback
G05_LINK_BODY=compiler/scripts/g05_relink_xlang.sh
PURE_LD_SHARED_REL=compiler/scripts/pure_ld_shared.sh
if [ ! -f "$PURE_LD_SHARED_REL" ]; then
  bad "missing $PURE_LD_SHARED_REL (wave773 pure-ld authority)"
elif ! grep -q 'pure_ld_platform_prefix\|pure_ld_try_link' "$PURE_LD_SHARED_REL"; then
  bad "pure_ld_shared.sh must define pure_ld_platform_prefix / pure_ld_try_link"
else
  note "pure_ld_shared authority present (wave773)"
fi
if [ ! -f "$G05_LINK_BODY" ]; then
  bad "missing $G05_LINK_BODY"
elif ! grep -q 'run_g05_pure_ld_required\|pure_ld_try_link\|pure_ld_shared' "$G05_LINK_BODY"; then
  bad "g05_relink_xlang must require pure-ld via pure_ld_shared (wave774)"
elif ! grep -q 'CC residual\|FORCE_CC' "$G05_LINK_BODY"; then
  bad "g05_relink_xlang must keep named CC residual for FORCE_CC/ineligible (wave774)"
elif grep -qE 'falling back to CC residual' "$G05_LINK_BODY"; then
  bad "g05_relink_xlang must not silently fall back to CC (wave774)"
else
  note "g05 pure-ld required + named CC residual only (wave774)"
fi
if ! printf '%s\n' "$_link_out" | grep -q 'G05_RELINK_PURE_LD=1'; then
  bad "linker dump must set G05_RELINK_PURE_LD=1 (wave773)"
fi
if ! printf '%s\n' "$_link_out" | grep -q 'PURE_LD_SHARED=scripts/pure_ld_shared.sh'; then
  bad "linker dump must name PURE_LD_SHARED"
fi
if ! printf '%s\n' "$_link_out" | grep -q 'ENDGAME_DROP_CC_FALLBACK=1'; then
  bad "linker dump must set ENDGAME_DROP_CC_FALLBACK=1 (wave774)"
fi
if ! printf '%s\n' "$_link_out" | grep -q 'COLD_SEED_LINK_DROP_SILENT_FALLBACK=1'; then
  bad "linker dump must set COLD_SEED_LINK_DROP_SILENT_FALLBACK=1 (wave774)"
fi

# Prefer-path scripts present
if [ ! -f compiler/scripts/filter_bootstrap_seed_pipeline_o.sh ]; then
  bad "missing preferred ld-partial script filter_bootstrap_seed_pipeline_o.sh"
else
  note "preferred ld-partial filter script present"
fi

# xbuild wiring
if [ ! -f "$XCODE_REL" ]; then
  bad "missing $XCODE_REL"
elif ! grep -qE 'host-platform|platform-host|linker-policy' "$XCODE_REL" \
  || ! grep -q 'host_platform_linker\.sh' "$XCODE_REL"; then
  bad "xlang-build.sh must wire host-platform / linker-policy → host_platform_linker.sh"
else
  note "xbuild host-platform / linker-policy wired"
fi

# build.x strategy map + 11.04 LINKER_POLICY authority
if [ -f build.x ]; then
  if ! grep -qE '11\.1\.3|host.platform|PLATFORM_LINKER' build.x; then
    bad "build.x must mention 11.1.3 / host platform / PLATFORM_LINKER"
  fi
  if ! grep -qE '11\.1\.4|linker.policy|direct.*ld|SEED_LINK_CC' build.x; then
    bad "build.x must mention 11.1.4 / linker policy"
  fi
  if ! grep -q 'export function build_linker_policy_count' build.x     || ! grep -q 'export function build_linker_policy_entry_at' build.x; then
    bad "build.x must export build_linker_policy_count / entry_at (10.4 / 11.04)"
  else
    _bx_lp_count=$(awk '
      /export function build_linker_policy_count[[:space:]]*\(/ { in_fn=1; next }
      in_fn && /return[[:space:]]+[0-9]+/ {
        if (match($0, /[0-9]+/)) { print substr($0, RSTART, RLENGTH); exit }
      }
      in_fn && /^}/ { exit }
    ' build.x)
    _bash_lp_n=${#LINKER_POLICY_ENTRIES[@]}
    if [ -z "${_bx_lp_count:-}" ]; then
      bad "build.x build_linker_policy_count return not parsed"
    elif [ "$_bx_lp_count" -ne "$_bash_lp_n" ]; then
      bad "LINKER_POLICY count mismatch: build.x=${_bx_lp_count} derived=${_bash_lp_n}"
    elif [ "$_bash_lp_n" -eq 0 ]; then
      bad "LINKER_POLICY derived empty (build.x authority load failed)"
    else
      # G.7: no second hardcoded LINKER_POLICY=prefer_direct… literal inventory in this script.
      if grep -nE '^LINKER_POLICY=prefer_direct' "$0" 2>/dev/null         | grep -vqE 'load_linker_policy|derived|authority|build\.x|11\.04'; then
        bad "hardcoded LINKER_POLICY literal still present (G.7 dual authority; demote 11.04)"
      else
        note "LINKER_POLICY authority=build.x (${_bash_lp_n} entries · derived cache · 10.4/11.04)"
      fi
    fi
    unset _bx_lp_count _bash_lp_n
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
echo "host_platform_linker: CHECK OK (11.1.3 platform + 11.1.4 linker policy · wave745 · 10.4 LINKER_POLICY authority=build.x 11.04)"
exit 0
