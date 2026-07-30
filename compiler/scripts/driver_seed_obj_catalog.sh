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
#   MAKE=gmake bash scripts/driver_seed_obj_catalog.sh
#
# PLATFORM: SHARED — thin catalog; no compile/link.
# Wave: 726–728 export · 788 B7B shell-primary (not physical delete).

set -euo pipefail
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MAKE="${MAKE:-make}"
# Clear MAKEFLAGS so nested/agent make does not inject -n / jobserver noise into export.
export MAKEFLAGS=""

CHECK=0
FORCE_SHELL=0
FORCE_MAKE=0
case "${1:-}" in
  --check) CHECK=1 ;;
  --shell) FORCE_SHELL=1 ;;
  --make) FORCE_MAKE=1 ;;
  "" ) ;;
  -h|--help)
    sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "driver_seed_obj_catalog: unknown arg '$1' (use --check|--shell|--make)" >&2
    exit 2
    ;;
esac

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
  sed -n "s/^${1}=//p" "$_CAT_FILE" | tail -n 1
}

# Collapse runs of spaces (make often leaves double spaces from empty $(VAR)).
catalog_norm_ws() {
  printf '%s' "$1" | tr -s ' ' | sed 's/^ //;s/ $//'
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
    rep=$(catalog_get "$name")
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

  while IFS= read -r raw || [ -n "$raw" ]; do
    # strip CR
    raw=${raw%$'\r'}
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

    # KEY = value  or  KEY := value (bash 3.2; no sed \? optional)
    case "$line" in
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
  catalog_store_init
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
  catalog_parse_mk "mk/x_source_deps.mk"
  catalog_parse_mk "mk/x_e_dirs.mk"
  catalog_parse_mk "mk/objs_core.mk"
  catalog_parse_mk "mk/user_asm_seed_objs.mk"
  catalog_parse_mk "mk/pipeline_x_objs.mk"
  catalog_parse_mk "mk/driver_seed_r_lists.mk"
  catalog_parse_mk "mk/driver_subcmd_objs.mk"
  catalog_parse_mk "mk/driver_seed_mode_objs.mk"
  catalog_parse_mk "mk/driver_seed_link_picks.mk"
  catalog_parse_mk "mk/archaeology_experiment_objs.mk"
  catalog_parse_mk "mk/driver_seed_export_lists.mk"
  catalog_parse_mk "mk/driver_seed_composites.mk"
  catalog_expand_all_stored

  local k v
  for k in "${REQUIRED_KEYS[@]}"; do
    v=$(catalog_get "$k")
    v=$(catalog_norm_ws "$v")
    printf '%s=%s\n' "$k" "$v"
  done
}

catalog_make_dump() {
  "$MAKE" -s bootstrap-driver-seed-export-obj-catalog
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
  for k in "${REQUIRED_KEYS[@]}"; do
    if ! printf '%s\n' "$out" | grep -q "^${k}="; then
      echo "driver_seed_obj_catalog: missing key $k" >&2
      missing=1
    fi
  done
  # Empty lists ok (e.g. FILTERED on Linux); values must expand USER_ASM non-empty.
  user_asm=$(printf '%s\n' "$out" | sed -n 's/^USER_ASM_SEED_OBJS=//p' | head -1)
  if [ -z "${user_asm// /}" ]; then
    echo "driver_seed_obj_catalog: USER_ASM_SEED_OBJS empty (mk include broken?)" >&2
    missing=1
  fi

  # wave788: shell vs make parity under product-default flags (when make available).
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
          sv=$(printf '%s\n' "$shell_out" | sed -n "s/^${k}=//p" | head -1)
          mv=$(printf '%s\n' "$make_out" | sed -n "s/^${k}=//p" | head -1)
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
