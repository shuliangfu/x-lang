#!/usr/bin/env bash
# driver_seed_obj_catalog.sh — wave726–728 · wave788 B7B shell-primary catalog
#
# G.7: Object-list *definitions* live in compiler/mk/*.mk (included by Makefile).
# wave788: default expansion is **shell parse of mk + product-default host picks**
# (0 make). `make bootstrap-driver-seed-export-obj-catalog` remains an escape /
# parity authority via XLANG_CATALOG_VIA_MAKE=1 or LEGACY host flags.
#
# Usage (compiler/ directory or with -C):
#   bash scripts/driver_seed_obj_catalog.sh
#   bash scripts/driver_seed_obj_catalog.sh --check   # keys present + shell==make
#   bash scripts/driver_seed_obj_catalog.sh --shell   # force shell path
#   bash scripts/driver_seed_obj_catalog.sh --make    # force make export
#   bash scripts/driver_seed_obj_catalog.sh --link-export phase1  # SEED_LINK_* (phase1)
#   bash scripts/driver_seed_obj_catalog.sh --link-export final   # SEED_LINK_* (final)
#   bash scripts/driver_seed_obj_catalog.sh --cflags-export       # CFLAGS + PIPELINE_GEN_CFLAGS
#   bash scripts/driver_seed_obj_catalog.sh --link-objs-export xnc # LINK_OBJS (bag: xnc/legacy-xlang-c/...)
#   bash scripts/driver_seed_obj_catalog.sh --link-cflags-export xnc # LINK_CFLAGS (bag: xnc/relink-product/...)
#   MAKE=gmake bash scripts/driver_seed_obj_catalog.sh
#
# PLATFORM: SHARED — thin catalog; no compile/link.
# Wave: 726–728 export · 788 B7B shell-primary · 924 --link-export · 925 --cflags-export · 926 --link-objs/cflags-export (not physical delete).

set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MAKE="${MAKE:-make}"
# Clear MAKEFLAGS so nested/agent make does not inject -n / jobserver noise into export.
export MAKEFLAGS=""

CHECK=0
FORCE_SHELL=0
FORCE_MAKE=0
LINK_EXPORT_MODE=""
CFLAGS_EXPORT=0
LINK_OBJS_BAG=""
LINK_CFLAGS_BAG=""
case "${1:-}" in
  --check) CHECK=1 ;;
  --shell) FORCE_SHELL=1 ;;
  --make) FORCE_MAKE=1 ;;
  --link-export)
    if [ -z "${2:-}" ]; then
      echo "driver_seed_obj_catalog: --link-export needs phase1|final" >&2
      exit 2
    fi
    LINK_EXPORT_MODE="$2"
    ;;
  --cflags-export) CFLAGS_EXPORT=1 ;;
  --link-objs-export)
    if [ -z "${2:-}" ]; then
      echo "driver_seed_obj_catalog: --link-objs-export needs bag name" >&2
      exit 2
    fi
    LINK_OBJS_BAG="$2"
    ;;
  --link-cflags-export)
    if [ -z "${2:-}" ]; then
      echo "driver_seed_obj_catalog: --link-cflags-export needs bag name" >&2
      exit 2
    fi
    LINK_CFLAGS_BAG="$2"
    ;;
  "" ) ;;
  -h|--help)
    sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "driver_seed_obj_catalog: unknown arg '$1' (use --check|--shell|--make|--link-export|--cflags-export|--link-objs-export|--link-cflags-export)" >&2
    exit 2
    ;;
esac

# wave924: --link-export phase1|final short-circuits to SEED_LINK_* dump.
# Dispatch is after function definitions (catalog_link_export_dump at bottom).
# See USE_MAKE decision block below for the actual call.

# Required keys from export-obj-catalog (must match Makefile recipe + mk lists).
# wave728: composite keys (LINK_BASE / PREREQS / X_FRONTEND) added.
REQUIRED_KEYS=(
  DRIVER_SEED_PIPELINE_X_OBJS
  DRIVER_SEED_SAT_REBUILD_OBJS
  DRIVER_SEED_LSP_X_OBJS
  DRIVER_SEED_BRIDGE_OBJS
  DRIVER_SEED_PANIC_OBJS
  DRIVER_SEED_TYPECK_F64_OBJS
  DRIVER_SEED_CRT0_OBJS
  DRIVER_SEED_USER_ASM_SEED_OBJS
  DRIVER_SEED_ASM_GLUE_OBJS
  DRIVER_SEED_HOST_STUBS_SCAN_BASE
  DRIVER_SEED_ASM_HOST_DISPATCH_OBJS
  DRIVER_SEED_OBJS
  DRIVER_SEED_LINK_BASE
  BOOTSTRAP_DRIVER_SEED_LINK_BASE
  DRIVER_SEED_PREREQS
  DRIVER_SEED_X_FRONTEND_OBJS
  BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS
  BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS
  USER_ASM_SEED_OBJS
  ASM_GLUE_STANDALONE_O
  RT_SEED_SLICE_OBJS
  R1_CORE_SEED_OBJS
  R1_FRONTEND_GLUE_OBJS
  R1_MAIN_RUNTIME_OBJS
  R1_ALIAS_STUBS_OBJS
  R1_EXTRA_CFLAGS_OBJS
  R1_MISC_BASENAME_OBJS
  R1_SEED_MAP_OBJS
  R3_COLD_SEED_OBJS
  ASYNC_THREE_SEED_OBJS
  B1_RUNTIME_OS_SEED_OBJS
  GEN_X_SEED_OBJS
  GEN_C_TO_O_SEED_OBJS
  B3_LSP_SAT_SEED_OBJS
  FMT_CHECK_SEED_OBJS
  MIGRATE_X_OBJS
  DRIVER_LEAF_PRODUCT_OBJS
  FILTER_AGAINST_PARTIAL_OBJS
  FILTER_PIPELINE_OBJS
)

# ---------------------------------------------------------------------------
# Host / product-default seeds (mirror Makefile default no_c + crt0 pick).
# Lists themselves stay in mk; these are host *picks* composites need.
# PLATFORM: SHARED product default; LEGACY flags force make path.
# ---------------------------------------------------------------------------
catalog_need_make_escape() {
  # Non-empty LEGACY / experimental flags diverge from product-default shell picks.
  if [ -n "${XLANG_LEGACY_C_FRONTEND:-}" ] && [ "${XLANG_LEGACY_C_FRONTEND}" != "0" ]; then
    return 0
  fi
  if [ -n "${XLANG_NO_C_SEED_LINK:-}" ] && [ "${XLANG_NO_C_SEED_LINK}" != "0" ]; then
    return 0
  fi
  if [ -n "${XLANG_LEGACY_MAIN_C:-}" ] && [ "${XLANG_LEGACY_MAIN_C}" != "0" ]; then
    return 0
  fi
  if [ -n "${XLANG_LEGACY_SEED_LEXER_AST:-}" ] && [ "${XLANG_LEGACY_SEED_LEXER_AST}" != "0" ]; then
    return 0
  fi
  if [ "${XLANG_CATALOG_VIA_MAKE:-0}" = "1" ]; then
    return 0
  fi
  return 1
}

# File-backed KEY=value store (bash 3.2 — no associative arrays).
# PLATFORM: SHARED — must not rebuild a growing in-memory string on every
# set/get (O(n² · store_bytes)). That path hangs MinGW/Git-Bash long enough
# that Windows hybrid min-gate looks "stuck forever" (ensure → catalog).
# Append + last-wins get is O(file size) with cheap I/O; expand still multi-pass.
_CAT_FILE=""

catalog_store_init() {
  if [ -n "${_CAT_FILE:-}" ] && [ -f "$_CAT_FILE" ]; then
    : > "$_CAT_FILE"
    return 0
  fi
  _CAT_FILE=$(mktemp "${TMPDIR:-/tmp}/xlang_driver_seed_cat.XXXXXX" 2>/dev/null || mktemp)
  # Best-effort cleanup when the catalog process exits.
  trap 'rm -f "${_CAT_FILE:-}"' EXIT HUP INT TERM
}

catalog_set() {
  local k="$1" v="$2"
  if [ -z "${_CAT_FILE:-}" ]; then
    catalog_store_init
  fi
  # Append; catalog_get takes the last matching line (last-wins).
  printf '%s=%s\n' "$k" "$v" >> "$_CAT_FILE"
}

catalog_get() {
  if [ -z "${_CAT_FILE:-}" ] || [ ! -f "$_CAT_FILE" ]; then
    return 0
  fi
  # Last assignment wins (matches prior overwrite semantics of _CAT_STORE).
  # Use '|' as sed delimiter — key names may contain '/' (e.g. wildcard paths).
  sed -n "s|^${1}=||p" "$_CAT_FILE" | tail -n 1
}

# Collapse runs of spaces (make often leaves double spaces from empty $(VAR)).
catalog_norm_ws() {
  # wave935: also collapse tabs (mk continuation lines carry tab indentation).
  printf '%s' "$1" | tr '\t' ' ' | tr -s ' ' | sed 's/^ //;s/ $//'
}

catalog_expand_value() {
  # Expand $(NAME) refs using store. Unknown NAME → empty (match make empty).
  local val="$1"
  local i=0
  local pre rest name post rep
  while [ "$i" -lt 64 ]; do
    case "$val" in
      *'$('* ) ;;
      *) printf '%s' "$val"; return 0 ;;
    esac
    pre="${val%%\$\(*}"
    rest="${val#*\$\(}"
    name="${rest%%\)*}"
    post="${rest#*\)}"
    # If no closing paren, stop
    if [ "$name" = "$rest" ]; then
      printf '%s' "$val"
      return 0
    fi
    # Handle make built-in $(wildcard PATTERN) — expand shell glob
    # (make semantics: return matching files, space-separated).
    if [ "${name#wildcard }" != "$name" ]; then
      local wpat="${name#wildcard }"
      local wres=""
      local wf
      for wf in $wpat; do
        [ -f "$wf" ] && wres="$wres $wf"
      done
      rep="${wres# }"
    else
      rep=$(catalog_get "$name")
    fi
    val="${pre}${rep}${post}"
    i=$((i + 1))
  done
  printf '%s' "$val"
}

catalog_seed_host_defaults() {
  local uname_s uname_m is_win=0
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  if [ "${OS:-}" = "Windows_NT" ]; then
    is_win=1
  else
    case "$uname_s" in
      MINGW*|MSYS*|CYGWIN*) is_win=1 ;;
    esac
  fi

  catalog_set UNAME_S "$uname_s"
  catalog_set UNAME_M "$uname_m"
  catalog_set XLANG_IS_WIN_HOST "$is_win"

  # wave924: CC / LD / CFLAGS / TARGET mirror Makefile `?=` defaults so the
  # --link-export shell path can compose SEED_LINK_CFLAGS / SEED_LINK_OUT /
  # SEED_LINK_OBJS without invoking make. Same semantics as Makefile:
  # env override wins; platform default only when unset.
  # PLATFORM: SHARED — cc/ld on POSIX; gcc on MinGW (Makefile L17-27 parity).
  if [ -z "${CC:-}" ]; then
    if [ "$is_win" -eq 1 ]; then
      catalog_set CC gcc
    else
      catalog_set CC cc
    fi
  else
    catalog_set CC "$CC"
  fi
  if [ -z "${LD:-}" ]; then
    catalog_set LD ld
  else
    catalog_set LD "$LD"
  fi
  # CFLAGS default mirrors Makefile L37 (+ OPT=1 append L86).
  if [ -z "${CFLAGS:-}" ]; then
    cflags_default="-Wall -Wextra -I. -Iinclude -Isrc"
    if [ "${OPT:-0}" = "1" ]; then
      cflags_default="$cflags_default -O2"
    fi
    catalog_set CFLAGS "$cflags_default"
  else
    catalog_set CFLAGS "$CFLAGS"
  fi
  catalog_set TARGET "${TARGET:-xlang}"

  # wave925: CC_IS_CLANG mirrors Makefile `:= $(findstring clang,$(shell $(CC) -v 2>&1))`.
  # Both produce "clang" when CC output contains "clang", empty otherwise.
  # Set before parsing mk/driver_seed_mode_objs.mk so ifeq resolves correctly.
  local _cc_bin
  _cc_bin=$(catalog_get CC)
  if "$_cc_bin" -v 2>&1 | grep -q 'clang'; then
    catalog_set CC_IS_CLANG clang
  else
    catalog_set CC_IS_CLANG ""
  fi

  # wave818: DRIVER_SEED_RUNTIME_O / SUPPORT_EXTRA / FRONTEND_EXTRA /
  # RUNTIME_REBUILD / LINK_FLAGS / C_FRONTEND_LEGACY → mk/driver_seed_mode_objs.mk.
  # wave819: MAIN_LINK / LEXER_AST / LSP_DIAG / PREPROCESS / GLUE → mk/driver_seed_link_picks.mk.
  # wave820: OBJS_CORE / OBJS archaeology → mk/objs_core.mk.
  # wave821: X_FRONTEND_EXPERIMENT + NO_C_FRONTEND archaeology → mk/archaeology_experiment_objs.mk.
  # wave822: LEGACY_XLANG_C_* + RELINK_XLANG_PREREQS → mk/driver_seed_composites.mk.
  # wave823: SRCS / MAIN_X_DEPS / PREPROCESS_X_DEPS / PIPELINE_*_DEPS →
  #          mk/x_source_deps.mk (source-path inventories; G.7).
  # wave824: MAIN_X_E_DIRS / LSP_X_E_DIRS / PIPELINE_X_E_DIRS →
  #          mk/x_e_dirs.mk (-E module search roots; G.7).
  # Do not hardcode those lists here — catalog_parse_mk owns them (after env flags).
  catalog_set XLANG_LEGACY_C_FRONTEND "${XLANG_LEGACY_C_FRONTEND:-}"
  catalog_set XLANG_NO_C_SEED_LINK "${XLANG_NO_C_SEED_LINK:-}"
  catalog_set XLANG_LEGACY_MAIN_C "${XLANG_LEGACY_MAIN_C:-}"
  catalog_set XLANG_LEGACY_SEED_LEXER_AST "${XLANG_LEGACY_SEED_LEXER_AST:-}"
  catalog_set XLANG_C "xlang-c"
  # wave816: DRIVER_SUBCMD_* list authority → mk/driver_subcmd_objs.mk (G.7).
  # Do not hardcode DRIVER_SUBCMD_OBJS / GEN here — catalog_parse_mk owns them.
  # wave817: PIPELINE_X_* + PIPELINE_LIBS → mk/pipeline_x_objs.mk (G.7).
  # Do not hardcode PIPELINE_LIBS / PIPELINE_X_* here — catalog_parse_mk owns them.
  # wave818: DRIVER_SEED mode picks → mk/driver_seed_mode_objs.mk (G.7).
  # wave819: seed link picks → mk/driver_seed_link_picks.mk (G.7).
  # wave820: OBJS_CORE archaeology list → mk/objs_core.mk (G.7).
  # wave821: archaeology experiment lists → mk/archaeology_experiment_objs.mk (G.7).
  # wave822: RELINK/LEGACY composites → mk/driver_seed_composites.mk (G.7).
  # wave823: source-path deps → mk/x_source_deps.mk (G.7).
  # wave824: -E module roots → mk/x_e_dirs.mk (G.7).
}

# Parse a single .mk file: simple KEY = value and ifeq ($(VAR),VAL)/else/endif.
# PLATFORM: SHARED — only simple ifeq forms used in mk/*.mk today.
catalog_parse_mk() {
  local path="$1"
  local line raw key val
  # skip stack: space-separated 0/1 flags; empty = active root
  local stack=""
  local top active cond_var cond_want actual

  if [ ! -f "$path" ]; then
    echo "driver_seed_obj_catalog: missing $path" >&2
    return 1
  fi

  # wave935: join backslash line continuations (mk files like
  # driver_leaf_product_objs.mk use `KEY = \` + tab-indented values).
  # Read raw, accumulate until a line not ending with backslash.
  while IFS= read -r raw || [ -n "$raw" ]; do
    # strip CR
    raw=${raw%$'\r'}
    # accumulate backslash continuations: while raw ends with backslash,
    # strip it and append the next line.
    while printf '%s' "$raw" | grep -qE '\\$'; do
      raw=$(printf '%s' "$raw" | sed 's/\\$//')
      local _cont
      if IFS= read -r _cont || [ -n "$_cont" ]; then
        _cont=${_cont%$'\r'}
        raw="$raw $_cont"
      else
        break
      fi
    done
    # strip comment (not inside values we care about — mk comments are full-line or trailing after lists rarely)
    line=$(printf '%s\n' "$raw" | sed 's/#.*//')
    # trim
    line=$(printf '%s\n' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$line" ] && continue

    # Conditionals (avoid case patterns with '(' — bash 3.2 macOS).
    if printf '%s' "$line" | grep -qE '^(ifeq|ifneq)[[:space:]]'; then
      # Active only if parent stack all 0
      active=1
      for top in $stack; do
        if [ "$top" != "0" ]; then active=0; break; fi
      done
      # Portable parse: ifeq ($(VAR),VAL) / ifneq ($(VAR),VAL)
      # bash 3.2 — no case patterns with '('; no ${var#$(...)} (cmd-sub).
      cond_kind=
      cond_var=
      cond_want=
      if [ "${line#ifeq }" != "$line" ]; then
        cond_kind=ifeq
        _rest=${line#ifeq }
      elif [ "${line#ifneq }" != "$line" ]; then
        cond_kind=ifneq
        _rest=${line#ifneq }
      fi
      # Expect _rest = ($(NAME),VAL)  — strip leading "($(" via byte offset
      if [ -n "$cond_kind" ] && [ "${#_rest}" -ge 4 ] && [ "${_rest:0:3}" = '($(' ]; then
        _inner=${_rest:3}
        cond_var=${_inner%%\)*}
        _tmp=${_inner#*\)}
        cond_want=${_tmp#,}
        cond_want=${cond_want%\)}
      fi
      if [ -n "$cond_kind" ] && [ -n "$cond_var" ]; then
        actual=$(catalog_get "$cond_var")
        if [ "$cond_kind" = "ifeq" ]; then
          if [ "$active" -eq 1 ] && [ "$actual" = "$cond_want" ]; then
            stack="$stack 0"
          else
            stack="$stack 1"
          fi
        else
          # ifneq
          if [ "$active" -eq 1 ] && [ "$actual" != "$cond_want" ]; then
            stack="$stack 0"
          else
            stack="$stack 1"
          fi
        fi
      else
        # Unsupported conditional form → treat as skip branch (safe for product mk)
        echo "driver_seed_obj_catalog: unsupported conditional in $path: $line" >&2
        stack="$stack 1"
      fi
      continue
    fi
    if [ "$line" = "else" ]; then
      # invert top of stack
      if [ -z "$stack" ]; then
        echo "driver_seed_obj_catalog: else without ifeq in $path" >&2
        return 1
      fi
      top=$(printf '%s\n' "$stack" | awk '{print $NF}')
      stack=$(printf '%s\n' "$stack" | awk '{$NF=""; print}' | sed 's/[[:space:]]*$//')
      if [ "$top" = "0" ]; then
        stack="$stack 1"
      else
        stack="$stack 0"
      fi
      # trim leading space
      stack=$(printf '%s' "$stack" | sed 's/^[[:space:]]*//')
      continue
    fi
    if [ "$line" = "endif" ]; then
      if [ -z "$stack" ]; then
        echo "driver_seed_obj_catalog: endif without ifeq in $path" >&2
        return 1
      fi
      stack=$(printf '%s\n' "$stack" | awk '{$NF=""; print}' | sed 's/[[:space:]]*$//')
      stack=$(printf '%s' "$stack" | sed 's/^[[:space:]]*//')
      continue
    fi

    # skip inactive branches
    active=1
    for top in $stack; do
      if [ "$top" != "0" ]; then active=0; break; fi
    done
    [ "$active" -eq 1 ] || continue

    # KEY = value / KEY := value / KEY += value (bash 3.2; wave925: += append support)
    case "$line" in
      *'+='*)
        key=${line%%+=*}
        val=${line#*+=}
        key=$(printf '%s' "$key" | sed 's/[[:space:]]*$//;s/^[[:space:]]*//')
        val=$(printf '%s' "$val" | sed 's/^[[:space:]]*//')
        case "$key" in
          [A-Za-z_]*)
            # append: get existing value, add space + new value (match make += semantics)
            local _old
            _old=$(catalog_get "$key")
            catalog_set "$key" "$(catalog_norm_ws "$_old $val")"
            ;;
        esac
        ;;
      *'='*)
        key=
        val=
        case "$line" in
          *':='*)
            key=${line%%:=*}
            val=${line#*:=}
            ;;
          *)
            key=${line%%=*}
            val=${line#*=}
            ;;
        esac
        # trim spaces around key/val
        key=$(printf '%s' "$key" | sed 's/[[:space:]]*$//;s/^[[:space:]]*//')
        val=$(printf '%s' "$val" | sed 's/^[[:space:]]*//')
        case "$key" in
          [A-Za-z_]*)
            catalog_set "$key" "$val"
            ;;
        esac
        ;;
    esac
  done < "$path"
}

catalog_expand_all_stored() {
  # Multi-pass expand every stored value until stable or cap.
  local pass=0
  local keys k old new
  while [ "$pass" -lt 32 ]; do
    keys=$(sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' "$_CAT_FILE" | sort -u)
    local changed=0
    for k in $keys; do
      old=$(catalog_get "$k")
      new=$(catalog_expand_value "$old")
      if [ "$new" != "$old" ]; then
        catalog_set "$k" "$new"
        changed=1
      fi
    done
    [ "$changed" -eq 0 ] && break
    pass=$((pass + 1))
  done
}

catalog_shell_dump() {
  catalog_shell_parse_all
  # wave940: dump ALL stored keys, not just REQUIRED_KEYS. The cache file
  # (XLANG_CATALOG_CACHE_FILE) is produced by `--shell` and must contain
  # every key that --link-export / --cflags-export / --link-objs-export
  # might query via catalog_get (e.g. BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS,
  # DRIVER_SEED_LINK_FLAGS, SEED_LINK_PURE_OK, etc.). These are set by
  # catalog_parse_mk + catalog_expand_all_stored but are NOT in
  # REQUIRED_KEYS. Dumping only REQUIRED_KEYS would starve the cache and
  # break --link-export when it reuses a parent-warmed cache.
  # --check still validates only REQUIRED_KEYS (parity + presence).
  # PLATFORM: SHARED — same KEY=VALUE store on Darwin/Linux/Windows MSYS2.
  local k v
  # First emit REQUIRED_KEYS (stable order for --check parity consumers).
  for k in "${REQUIRED_KEYS[@]}"; do
    v=$(catalog_get "$k")
    v=$(catalog_norm_ws "$v")
    printf '%s=%s\n' "$k" "$v"
  done
  # Then emit all other keys from the store (dedup against REQUIRED_KEYS).
  if [ -n "${_CAT_FILE:-}" ] && [ -f "$_CAT_FILE" ]; then
    # Extract unique key names from the store, skip REQUIRED_KEYS.
    local _seen _key _line
    _seen=" $(printf '%s\n' "${REQUIRED_KEYS[@]}") "
    while IFS='=' read -r _key _; do
      [ -z "$_key" ] && continue
      case "$_seen" in
        *" $_key "*) continue ;;
      esac
      _seen="$_seen$_key "
      v=$(catalog_get "$_key")
      v=$(catalog_norm_ws "$v")
      printf '%s=%s\n' "$_key" "$v"
    done < "$_CAT_FILE"
  fi
}

# wave924: Parse all mk files + host defaults into the store (shared by
# catalog_shell_dump for REQUIRED_KEYS and catalog_link_export_dump for
# SEED_LINK_*). Split out so --link-export reuses the same parse pipeline
# without duplicating the include-order comments / catalog_parse_mk calls.
catalog_shell_parse_all() {
  catalog_store_init
  # wave940: Reuse parent's pre-warmed catalog cache when available.
  # Without this, every invocation (bootstrap link, g05 ensure, rebuild
  # leaves, filter scripts, ...) re-parses all 17 mk files. On Windows
  # MinGW/Git Bash that is ~3min per call; a single bootstrap makes ~6
  # catalog calls → 18+ min of redundant shell parsing that looks "hung".
  # The cache file is a KEY=VALUE blob produced by `driver_seed_obj_catalog.sh
  # --shell` (or a caller-supplied path). It contains every mk-derived key
  # (DRIVER_SEED_OBJS, SEED_LINK_*, FILTER_*, etc.) but NOT the host-default
  # keys (CC, CFLAGS, TARGET, CC_IS_CLANG, UNAME_*) which depend on the
  # current process environment. So we still call catalog_seed_host_defaults
  # (cheap: 1 `cc -v` probe + ~20 catalog_set) but skip all catalog_parse_mk
  # calls (expensive: 17 mk files × shell parse). catalog_get is last-wins,
  # so host-default keys appended after the cache take precedence.
  # PLATFORM: SHARED — same KEY=VALUE semantics on Darwin/Linux/Windows MSYS2.
  if [ -n "${XLANG_CATALOG_CACHE_FILE:-}" ] && [ -s "${XLANG_CATALOG_CACHE_FILE:-}" ]; then
    cat "${XLANG_CATALOG_CACHE_FILE}" >> "$_CAT_FILE"
    catalog_seed_host_defaults
    return 0
  fi
  catalog_seed_host_defaults
  # Include order matches make dependency of lists
  # (user_asm → pipeline_x → r_lists → subcmd → mode → link_picks → export → composites).
  # wave816: driver_subcmd_objs.mk before composites (DRIVER_SUBCMD_OBJS/GEN).
  # wave817: pipeline_x_objs.mk after user_asm (USER_ASM_LINK for LINK_OBJS;
  #          PIPELINE_LIBS before composites that expand it).
  # wave818: driver_seed_mode_objs.mk before composites (SUPPORT_EXTRA / RUNTIME_O).
  # wave819: driver_seed_link_picks.mk after r_lists (ASM_GLUE for GLUE_SUFFIX)
  #          and before composites (MAIN_LINK / LEXER / AST expand).
  # wave820: objs_core.mk is independent archaeology inventory (OBJS_CORE / OBJS);
  #          parse early; no composite deps.
  # wave821: archaeology_experiment_objs.mk after link_picks (NO_C expands
  #          MAIN_LINK / PREPROCESS / AST); before composites.
  # wave822: composites.mk also owns LEGACY_XLANG_C_* + RELINK_XLANG_PREREQS
  #          (parse last; expands filtered/host + DRIVER_SEED_OBJS).
  # wave823: x_source_deps.mk (SRCS / MAIN_X_DEPS / PIPELINE_X_DEPS; independent
  #          of composites; parse early like objs_core).
  # wave824: x_e_dirs.mk (MAIN/LSP/PIPELINE_X_E_DIRS; independent; parse early).
  # wave924: link_picks.mk now also owns LD_R_MULTIDEF_FLAGS / ASM_GLUE_DUP_LDFLAGS
  #          / SEED_LINK_PURE_OK / ENTRY / LD_TAIL (moved from Makefile inline).
  catalog_parse_mk "mk/x_source_deps.mk"
  catalog_parse_mk "mk/x_e_dirs.mk"
  catalog_parse_mk "mk/objs_core.mk"
  catalog_parse_mk "mk/user_asm_seed_objs.mk"
  catalog_parse_mk "mk/pipeline_x_objs.mk"
  catalog_parse_mk "mk/driver_seed_r_lists.mk"
  # wave935: driver_leaf_product_objs.mk owns DRIVER_LEAF_PRODUCT_OBJS (8 leaves);
  # parsed after r_lists (no composite deps; independent leaf list).
  catalog_parse_mk "mk/driver_leaf_product_objs.mk"
  catalog_parse_mk "mk/driver_subcmd_objs.mk"
  catalog_parse_mk "mk/driver_seed_mode_objs.mk"
  catalog_parse_mk "mk/driver_seed_link_picks.mk"
  catalog_parse_mk "mk/archaeology_experiment_objs.mk"
  catalog_parse_mk "mk/driver_seed_export_lists.mk"
  catalog_parse_mk "mk/driver_seed_composites.mk"
  # wave939: complete mk coverage — 4 remaining mk files (were Makefile-only includes;
  # catalog now parses all 17 mk files for Makefile-independent operation).
  catalog_parse_mk "mk/formal_mod_product_objs.mk"
  catalog_parse_mk "mk/std_x_product_objs.mk"
  catalog_parse_mk "mk/std_core_hybrid_product_objs.mk"
  catalog_parse_mk "mk/std_and_panic_objs.mk"
  catalog_expand_all_stored
}

# wave924: --link-export phase1|final — shell-primary SEED_LINK_* dump.
# Replaces `make bootstrap-driver-seed-export-{phase1,final}-link` for the
# product link path (bootstrap_driver_seed_link.sh / gen_g06_phase1_backend_stub.sh).
# Output mirrors the Makefile export targets exactly (9 KEY=value lines).
# All RHS vars resolve via catalog_shell_parse_all (mk parse + host defaults).
# PLATFORM: SHARED — CC/LD/CFLAGS/TARGET defaults mirror Makefile `?=`.
catalog_link_export_dump() {
  local mode="$1"
  if [ "$mode" != "phase1" ] && [ "$mode" != "final" ]; then
    echo "driver_seed_obj_catalog: --link-export needs phase1|final (got '$mode')" >&2
    return 2
  fi
  catalog_shell_parse_all

  # Compose SEED_LINK_CFLAGS = $(CFLAGS) $(DRIVER_SEED_LINK_FLAGS) $(ASM_GLUE_DUP_LDFLAGS) $(MAIN_LINK_FLAGS)
  local cflags driver_link_flags dup_ldflags main_link_flags
  cflags=$(catalog_get CFLAGS)
  driver_link_flags=$(catalog_get DRIVER_SEED_LINK_FLAGS)
  dup_ldflags=$(catalog_get ASM_GLUE_DUP_LDFLAGS)
  main_link_flags=$(catalog_get MAIN_LINK_FLAGS)
  local seed_link_cflags
  seed_link_cflags=$(catalog_norm_ws "$cflags $driver_link_flags $dup_ldflags $main_link_flags")

  local cc ld multidef entry ld_tail pure_ok target objs out
  cc=$(catalog_get CC)
  ld=$(catalog_get LD)
  multidef=$(catalog_get LD_R_MULTIDEF_FLAGS)
  entry=$(catalog_get SEED_LINK_ENTRY)
  ld_tail=$(catalog_get SEED_LINK_LD_TAIL)
  pure_ok=$(catalog_get SEED_LINK_PURE_OK)
  target=$(catalog_get TARGET)

  if [ "$mode" = "phase1" ]; then
    out="xlang-seed-phase1"
    objs=$(catalog_get BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS)
  else
    out="$target"
    objs=$(catalog_get BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS)
  fi
  objs=$(catalog_norm_ws "$objs")

  printf 'SEED_LINK_CC=%s\n' "$cc"
  printf 'SEED_LINK_CFLAGS=%s\n' "$seed_link_cflags"
  printf 'SEED_LINK_LD=%s\n' "$ld"
  printf 'SEED_LINK_MULTIDEF=%s\n' "$multidef"
  printf 'SEED_LINK_ENTRY=%s\n' "$entry"
  printf 'SEED_LINK_LD_TAIL=%s\n' "$ld_tail"
  printf 'SEED_LINK_PURE_OK=%s\n' "$pure_ok"
  printf 'SEED_LINK_OUT=%s\n' "$out"
  printf 'SEED_LINK_OBJS=%s\n' "$objs"
}

catalog_make_dump() {
  "$MAKE" -s bootstrap-driver-seed-export-obj-catalog
}

# wave925: --cflags-export — shell-primary CFLAGS + PIPELINE_GEN_CFLAGS dump.
# Replaces `make export-try-heat-cflags` for build_tool.sh.
# Output mirrors the Makefile export target exactly (2 KEY=value lines).
# CFLAGS resolves from host defaults (Makefile `?=` parity + OPT=1 -O2).
# PIPELINE_GEN_CFLAGS resolves from mk/driver_seed_mode_objs.mk (BASE + ifeq
# CC_IS_CLANG → CLANG append).
catalog_cflags_export_dump() {
  catalog_shell_parse_all
  local cflags pipeline_gen_cflags
  cflags=$(catalog_get CFLAGS)
  pipeline_gen_cflags=$(catalog_get PIPELINE_GEN_CFLAGS)
  cflags=$(catalog_norm_ws "$cflags")
  pipeline_gen_cflags=$(catalog_norm_ws "$pipeline_gen_cflags")
  printf 'CFLAGS=%s\n' "$cflags"
  printf 'PIPELINE_GEN_CFLAGS=%s\n' "$pipeline_gen_cflags"
}

# wave926: --link-objs-export <bag> — shell-primary LINK_OBJS dump.
# Replaces `make export-<bag>-link-objs` for archaeology link scripts.
# Bag name maps to the Makefile variable that holds the .o list:
#   xnc           → XLANG_NO_C_FRONTEND_LINK_OBJS (mk/archaeology_experiment_objs.mk)
#   legacy-xlang-c → LEGACY_XLANG_C_PREREQS       (mk/driver_seed_composites.mk)
#   relink-product → RELINK_PRODUCT_LINK_OBJS     (mk/driver_seed_composites.mk)
#   xlang-x       → XLANG_X_LINK_OBJS             (mk/driver_seed_composites.mk)
#   bxf           → DRIVER_SEED_X_FRONTEND_LINK_OBJS
#   bs            → BOOTSTRAP_SELF_LINK_OBJS
#   objs-core     → OBJS                          (mk/objs_core.mk)
#   bxc           → OBJS                          (mk/objs_core.mk)
# Output: single LINK_OBJS=<space-separated .o list> line.
catalog_link_objs_export_dump() {
  local bag="$1"
  local var
  case "$bag" in
    xnc)             var=XLANG_NO_C_FRONTEND_LINK_OBJS ;;
    legacy-xlang-c)  var=LEGACY_XLANG_C_PREREQS ;;
    relink-product)  var=RELINK_PRODUCT_LINK_OBJS ;;
    xlang-x)         var=XLANG_X_LINK_OBJS ;;
    bxf)             var=DRIVER_SEED_X_FRONTEND_LINK_OBJS ;;
    bs)              var=BOOTSTRAP_SELF_LINK_OBJS ;;
    objs-core|bxc)   var=OBJS ;;
    *)
      echo "driver_seed_obj_catalog: unknown link-objs bag '$bag'" >&2
      return 2
      ;;
  esac
  catalog_shell_parse_all
  local objs
  objs=$(catalog_get "$var")
  objs=$(catalog_norm_ws "$objs")
  printf 'LINK_OBJS=%s\n' "$objs"
}

# wave926: --link-cflags-export <bag> — shell-primary LINK_CFLAGS dump.
# Replaces `make export-<bag>-link-cflags` for archaeology link scripts.
# Each bag has a distinct CFLAGS formula (mirrors Makefile export targets):
#   relink-product → CFLAGS + DRIVER_SEED_LINK_FLAGS + ASM_GLUE_DUP_LDFLAGS + MAIN_LINK_FLAGS
#   xnc            → CFLAGS + DRIVER_SEED_LINK_FLAGS + MAIN_LINK_FLAGS
#   btc-typeck     → CFLAGS + -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK + ASM_GLUE_DUP_LDFLAGS + MAIN_LINK_FLAGS
#   bxf            → CFLAGS + -DXLANG_USE_X_DRIVER -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN
# Output: single LINK_CFLAGS=<flags> line.
catalog_link_cflags_export_dump() {
  local bag="$1"
  catalog_shell_parse_all
  local cflags driver_link_flags dup_ldflags main_link_flags
  cflags=$(catalog_get CFLAGS)
  driver_link_flags=$(catalog_get DRIVER_SEED_LINK_FLAGS)
  dup_ldflags=$(catalog_get ASM_GLUE_DUP_LDFLAGS)
  main_link_flags=$(catalog_get MAIN_LINK_FLAGS)
  local link_cflags
  case "$bag" in
    relink-product)
      link_cflags="$cflags $driver_link_flags $dup_ldflags $main_link_flags"
      ;;
    xnc)
      link_cflags="$cflags $driver_link_flags $main_link_flags"
      ;;
    btc-typeck)
      link_cflags="$cflags -DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_TYPECK $dup_ldflags $main_link_flags"
      ;;
    bxf)
      link_cflags="$cflags -DXLANG_USE_X_DRIVER -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN"
      ;;
    *)
      echo "driver_seed_obj_catalog: unknown link-cflags bag '$bag'" >&2
      return 2
      ;;
  esac
  link_cflags=$(catalog_norm_ws "$link_cflags")
  printf 'LINK_CFLAGS=%s\n' "$link_cflags"
}

# Decide path
USE_MAKE=0
if [ "$FORCE_MAKE" -eq 1 ]; then
  USE_MAKE=1
elif [ "$FORCE_SHELL" -eq 1 ]; then
  USE_MAKE=0
elif catalog_need_make_escape; then
  USE_MAKE=1
else
  USE_MAKE=0
fi

# wave924: --link-export short-circuit (shell-only; no make parity path).
# LEGACY flags still need make escape for obj catalog, but link-export vars
# (SEED_LINK_*) resolve from mk directly — no make escape needed.
if [ -n "$LINK_EXPORT_MODE" ]; then
  catalog_link_export_dump "$LINK_EXPORT_MODE"
  exit $?
fi

# wave925: --cflags-export short-circuit (shell-only; replaces make export-try-heat-cflags).
if [ "$CFLAGS_EXPORT" -eq 1 ]; then
  catalog_cflags_export_dump
  exit $?
fi

# wave926: --link-objs-export <bag> short-circuit (shell-only; replaces make export-*-link-objs).
if [ -n "$LINK_OBJS_BAG" ]; then
  catalog_link_objs_export_dump "$LINK_OBJS_BAG"
  exit $?
fi

# wave926: --link-cflags-export <bag> short-circuit (shell-only; replaces make export-*-link-cflags).
if [ -n "$LINK_CFLAGS_BAG" ]; then
  catalog_link_cflags_export_dump "$LINK_CFLAGS_BAG"
  exit $?
fi

if [ "$USE_MAKE" -eq 1 ]; then
  out="$(catalog_make_dump)"
  CATALOG_PATH=make
else
  out="$(catalog_shell_dump)"
  CATALOG_PATH=shell
fi

printf '%s\n' "$out"

if [ "$CHECK" -eq 1 ]; then
  missing=0
  # wave948: use here-string (not `printf | grep -q`) under `set -o pipefail`.
  # When grep -q finds a match it exits early; printf can get SIGPIPE → pipeline
  # non-zero → false "missing key" flake (keys present in $out). Here-string is
  # deterministic. PLATFORM: SHARED.
  for k in "${REQUIRED_KEYS[@]}"; do
    if ! grep -q "^${k}=" <<<"$out"; then
      echo "driver_seed_obj_catalog: missing key $k" >&2
      missing=1
    fi
  done
  # Empty lists ok (e.g. FILTERED on Linux); values must expand USER_ASM non-empty.
  user_asm=$(sed -n 's/^USER_ASM_SEED_OBJS=//p' <<<"$out" | head -1)
  if [ -z "${user_asm// /}" ]; then
    echo "driver_seed_obj_catalog: USER_ASM_SEED_OBJS empty (mk include broken?)" >&2
    missing=1
  fi

  # wave788: shell vs make parity under product-default flags (when make available).
  # post_ship (Makefile absent): make export empty → skip parity (honest).
  if ! catalog_need_make_escape || [ "$FORCE_SHELL" -eq 1 ]; then
    if command -v "$MAKE" >/dev/null 2>&1 || command -v make >/dev/null 2>&1; then
      make_out="$(catalog_make_dump 2>/dev/null || true)"
      if [ -n "$make_out" ]; then
        shell_out="$out"
        if [ "$CATALOG_PATH" = "make" ]; then
          shell_out="$(FORCE_SHELL=1; catalog_shell_dump)"
        fi
        parity_fail=0
        for k in "${REQUIRED_KEYS[@]}"; do
          sv=$(sed -n "s/^${k}=//p" <<<"$shell_out" | head -1)
          mv=$(sed -n "s/^${k}=//p" <<<"$make_out" | head -1)
          sv=$(catalog_norm_ws "$sv")
          mv=$(catalog_norm_ws "$mv")
          if [ "$sv" != "$mv" ]; then
            echo "driver_seed_obj_catalog: parity FAIL $k" >&2
            echo "  shell: $sv" >&2
            echo "  make:  $mv" >&2
            parity_fail=1
          fi
        done
        if [ "$parity_fail" -ne 0 ]; then
          missing=1
        else
          echo "driver_seed_obj_catalog: shell==make parity OK (${#REQUIRED_KEYS[@]} keys)" >&2
        fi
      else
        echo "driver_seed_obj_catalog: skip parity (make export empty/fail)" >&2
      fi
    fi
  fi

  if [ "$missing" -ne 0 ]; then
    exit 1
  fi
  echo "driver_seed_obj_catalog: --check OK (${#REQUIRED_KEYS[@]} keys; path=$CATALOG_PATH)" >&2
fi
