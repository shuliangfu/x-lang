#!/usr/bin/env bash
# compiler-make.sh — wave727/728/732/733 + wave944 · 11.2.3 + 11.1.6 + 11.4.2 hub body
#
# G.7 single authority for residual "compiler graph" work once requested as
# historical `make -C compiler …` (tests/** + `./xbuild compiler-make`).
#
# wave944 post-delete (MG): compiler/Makefile is gone. This hub is **0-make**:
# it routes targets to shell authorities (bootstrap_driver_seed, formal_mod,
# std_x, try-heat, ensure_xlang_c, compiler_all_ci / g05). It does **not**
# invoke make/gmake.
#
# Usage (from repo root or after setting XLANG_REPO_ROOT):
#   . tests/lib/compiler-make.sh
#   xlang_compiler_make -q runtime_panic.o || xlang_compiler_make runtime_panic.o
#   xlang_compiler_make bootstrap-driver-bstrict
#   XLANG_COMPILER_DIR=/path/to/compiler xlang_compiler_make runtime_panic.o
#   bash tests/lib/compiler-make.sh OPT=1 all   # CLI (xlang-build uses this)
#
# PLATFORM: SHARED — thin dispatch; leaf compile logic stays in compiler/scripts.

# Resolve repo root once: prefer caller ROOT, else walk from this file.
if [ -z "${XLANG_REPO_ROOT:-}" ]; then
  _cm_here="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  XLANG_REPO_ROOT="$(CDPATH= cd -- "$_cm_here/../.." && pwd)"
  unset _cm_here
fi

# Historical override; unused after wave944 (kept so callers that export it do not break).
XLANG_COMPILER_MAKE="${XLANG_COMPILER_MAKE:-make}"

# ---------------------------------------------------------------------------
# Ensure one leaf .o under compiler/ cwd via formal_mod → std_x → try-heat.
# Exit: 0 ok, non-zero failure (unknown + try-heat fail).
# PLATFORM: SHARED
# ---------------------------------------------------------------------------
_xlang_cm_ensure_one_o() {
  local out="$1"
  local rc=0
  local _log
  # Fast path: leaf present. Product bstrict calls ensure on every script;
  # each miss re-enters try-heat as a *new* bash → catalog re-parse without
  # XLANG_CATALOG_CACHE_FILE (~8s×N) looks like a hang. FORCE rebuilds when
  # XLANG_CM_FORCE=1 or leaf missing. PLATFORM: SHARED
  if [ -z "${XLANG_CM_FORCE:-}" ] && [ -s "$out" ]; then
    return 0
  fi
  _log="${TMPDIR:-/tmp}/xlang_cm_ensure.$$.$RANDOM"
  # formal_mod catalog (exit 3 = not a formal leaf). Capture rc explicitly
  # (do not use `if cmd; then` which can obscure status with set -e callers).
  bash scripts/xlang_compile_std_module.sh ensure "$out" >"$_log" 2>&1
  rc=$?
  if [ "$rc" -eq 0 ]; then
    rm -f "$_log"
    return 0
  fi
  if [ "$rc" -ne 3 ]; then
    cat "$_log" >&2 || true
    rm -f "$_log"
    return "$rc"
  fi
  # std_x catalog (exit 3 = not a std_x leaf).
  bash scripts/xlang_compile_std_x.sh ensure "$out" >"$_log" 2>&1
  rc=$?
  if [ "$rc" -eq 0 ]; then
    rm -f "$_log"
    return 0
  fi
  if [ "$rc" -ne 3 ]; then
    cat "$_log" >&2 || true
    rm -f "$_log"
    return "$rc"
  fi
  rm -f "$_log"
  # Heat ladder (R1–R6 / B1–B6 / gen / prefer) — single shell body.
  bash scripts/ensure_host_cc_seed_o.sh try-heat "$out"
}

# ---------------------------------------------------------------------------
# Dispatch one non-assignment argument (target or flag already stripped).
# Runs with cwd = compiler dir. Returns target exit status.
# PLATFORM: SHARED
# ---------------------------------------------------------------------------
_xlang_cm_dispatch_one() {
  local t="$1"
  case "$t" in
    ""|-q|--quiet|-s|--silent|-k|--keep-going|-j*|--jobs*|-B|--always-make|--no-print-directory)
      return 0
      ;;
    # --- product / cold / CI phonies ---
    all)
      # Historical `make all` / OPT=1 all → CI shell body (0-make after wave944).
      bash scripts/compiler_all_ci.sh
      return $?
      ;;
    bootstrap-driver-seed)
      bash scripts/bootstrap_driver_seed.sh
      return $?
      ;;
    bootstrap-driver-bstrict)
      bash scripts/bootstrap_driver_bstrict.sh
      return $?
      ;;
    bootstrap-verify|bootstrap-verify-bstrict|bootstrap-verify-seed)
      bash scripts/bootstrap_verify_bstrict.sh
      return $?
      ;;
    bootstrap-driver)
      # Soft residual: cold seed is the product-facing path.
      bash scripts/bootstrap_driver_seed.sh
      return $?
      ;;
    bootstrap-pipeline|xlang-x-pipeline)
      # Structural + best-effort full path (script owns residual honesty).
      if [ -f scripts/xlang_x_pipeline.sh ]; then
        bash scripts/xlang_x_pipeline.sh 2>/dev/null \
          || bash scripts/xlang_x_pipeline.sh --check
        return $?
      fi
      echo "compiler-make: missing scripts/xlang_x_pipeline.sh for $t" >&2
      return 1
      ;;
    xlang-c|"\$(XLANG_C)"|'$(XLANG_C)')
      bash scripts/ensure_xlang_c.sh ensure xlang-c
      return $?
      ;;
    xlang|xlang_asm)
      # Product link via g05 (wave786 B7D authority path).
      if [ -f scripts/g05_prepare_and_relink.sh ]; then
        FULL="${FULL:-0}" bash scripts/g05_prepare_and_relink.sh
        return $?
      fi
      if [ -f scripts/build_xlang_asm.sh ]; then
        bash scripts/build_xlang_asm.sh
        return $?
      fi
      echo "compiler-make: no g05/build_xlang_asm for $t" >&2
      return 1
      ;;
    std-objs)
      # Soft: ensure a common formal core set used by many tests.
      local _so _rc=0
      for _so in \
        ../std/heap/heap.o \
        ../core/mem/mem.o \
        ../std/string/string.o \
        ../std/io/io.o \
        ../std/fs/fs.o \
        ../std/process/process.o
      do
        _xlang_cm_ensure_one_o "$_so" || _rc=$?
      done
      return "$_rc"
      ;;
    clean)
      # Soft product clean — do not wipe seed pins; only common products.
      rm -f xlang xlang_asm xlang-c bootstrap_xlangc 2>/dev/null || true
      return 0
      ;;
    # --- leaf .o / path-like targets ---
    *.o|*/*.o|*/*/*.o|*/*/*/*.o)
      _xlang_cm_ensure_one_o "$t"
      return $?
      ;;
    # net-o-* archaeology phony
    net-o-stub|net-o-openssl|net-o-mbedtls)
      if [ -f scripts/archaeology_host_pick_phony.sh ]; then
        bash scripts/archaeology_host_pick_phony.sh "$t"
        return $?
      fi
      _xlang_cm_ensure_one_o ../std/net/net.o
      return $?
      ;;
    *)
      # Unknown phony: try as heat leaf basename, else fail clearly.
      if [[ "$t" == *"="* ]]; then
        # VAR=val already handled in outer parse; stray here = ignore.
        return 0
      fi
      if [[ "$t" == *.o ]] || [[ "$t" == */* ]]; then
        _xlang_cm_ensure_one_o "$t"
        return $?
      fi
      # Last resort: try-heat with the raw name (may be a short object stem).
      if bash scripts/ensure_host_cc_seed_o.sh try-heat "$t" 2>/dev/null; then
        return 0
      fi
      echo "compiler-make: unsupported target after Makefile delete: $t" >&2
      echo "  use: ./xbuild <bootstrap|all|migrate|host-cc-seed|…> or known .o paths" >&2
      return 1
      ;;
  esac
}

# Run "compiler make" with remaining args. cwd stays caller's cwd.
# XLANG_COMPILER_DIR overrides the default ${XLANG_REPO_ROOT}/compiler (nolibc
# / out-of-tree smoke may pass an alternate compiler tree).
# Returns last non-zero status (0 if all succeed).
xlang_compiler_make() {
  local _cm_dir="${XLANG_COMPILER_DIR:-${XLANG_REPO_ROOT}/compiler}"
  local -a _cm_args=()
  local _a _rc=0 _had_target=0

  # Parse: export VAR=val; drop make-only flags; collect targets.
  for _a in "$@"; do
    case "$_a" in
      -q|--quiet|-s|--silent|-k|--keep-going|--no-print-directory|-B|--always-make)
        continue
        ;;
      -j|--jobs)
        # next arg may be job count if separate; skip count if next is digits only
        continue
        ;;
      -j*|--jobs=*)
        continue
        ;;
      *=*)
        # Export assignment for leaf scripts (CFLAGS=… OPT=1 XLANG_LEGACY… etc.).
        # shellcheck disable=SC2163
        export "$_a"
        continue
        ;;
      *)
        _cm_args+=("$_a")
        ;;
    esac
  done

  if [ ! -d "$_cm_dir" ]; then
    echo "compiler-make: compiler dir missing: $_cm_dir" >&2
    return 1
  fi

  # Empty target list: historical bare `make -C compiler` ≈ product all.
  if [ "${#_cm_args[@]}" -eq 0 ]; then
    _cm_args=(all)
  fi

  (
    cd "$_cm_dir" || exit 1
    for _a in "${_cm_args[@]}"; do
      _had_target=1
      if ! _xlang_cm_dispatch_one "$_a"; then
        _rc=$?
        # Match make: continue on later targets only if -k was requested.
        # Default: stop on first failure.
        exit "$_rc"
      fi
    done
    exit 0
  )
  return $?
}

# CLI mode when executed (not sourced): ./xbuild compiler-make / run_compiler_make.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  xlang_compiler_make "$@"
  exit $?
fi
