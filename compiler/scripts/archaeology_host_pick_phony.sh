#!/usr/bin/env bash
# archaeology_host_pick_phony.sh — F-04 / F-ZC archaeology host-pick phonies
#
# Usage (cwd = compiler/):
#   bash scripts/archaeology_host_pick_phony.sh ensure <phony>
#   bash scripts/archaeology_host_pick_phony.sh auto <phony>     # alias of ensure
#   bash scripts/archaeology_host_pick_phony.sh list
#   bash scripts/archaeology_host_pick_phony.sh --check
#
# wave815 (G.7 有则补全): archaeology phonies that historically owned a multi-line
# host-pick ladder (xlang_asm → xlang → xlang-c) live here. Makefile thin-calls
# `ensure <phony>` only. Product std/*.o leaves already use xlang_compile_std_x
# (wave811) / formal_mod ensure (wave812); this catalog is **off product default
# link** (opt-in TLS/sqlite stub merge paths).
#
# Catalog keys:
#   net-o-stub       — ensure ../std/net/net.o (net.o product leaf is try-heat)
#   net-o-openssl    — compile tls_openssl.x → tls_openssl.o + net-o-stub
#   net-o-mbedtls    — compile tls_mbedtls.x → main, bio, ld -r → tls_mbedtls.o + net-o-stub
#   sqlite-o-stub    — glue_stub + optional sqlite.x merge into sqlite.o
#
# Host compile body reuses xlang_compile_std_x.sh auto (single host-pick authority).
# Nested .o deps still go through make (try-heat / product leaves) — thin edges remain.
# NOT physical delete; B7B lists + product thin edges + B2 remain residual.
#
# Env: MAKE (default make), LD_R_MULTIDEF_FLAGS (optional override)
# PLATFORM: SHARED — catalog + host pick; ld -r multidef is host-OS branched.
set -eu
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
STD_X_SH="scripts/xlang_compile_std_x.sh"

# ---------------------------------------------------------------------------
# Host ld -r multidef flags (historic Makefile LD_R_MULTIDEF_FLAGS).
# PLATFORM: MACOS → -multiply_defined suppress; LINUX|WINDOWS → --allow-multiple-definition
# Prefer env override when Makefile passes LD_R_MULTIDEF_FLAGS=...
# ---------------------------------------------------------------------------
arch_ld_r_multidef_flags() {
  if [ -n "${LD_R_MULTIDEF_FLAGS:-}" ]; then
    # shellcheck disable=SC2086
    printf '%s' "$LD_R_MULTIDEF_FLAGS"
    return 0
  fi
  case "$(uname -s 2>/dev/null || echo Unknown)" in
    Darwin) printf '%s' '-multiply_defined suppress' ;;
    *) printf '%s' '--allow-multiple-definition' ;;
  esac
}

# Catalog authority: one key per archaeology phony (G.7; residual must list via list).
arch_phony_keys() {
  printf '%s\n' \
    'net-o-stub' \
    'net-o-openssl' \
    'net-o-mbedtls' \
    'sqlite-o-stub'
}

arch_phony_known() {
  case "$1" in
    net-o-stub|net-o-openssl|net-o-mbedtls|sqlite-o-stub) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# Bodies (historic Makefile semantics; single shell authority)
# ---------------------------------------------------------------------------

# net-o-stub: product net.o via make (try-heat body already shell-primary).
arch_run_net_o_stub() {
  "$MAKE" ../std/net/net.o
}

# net-o-openssl: hard-fail without host; compile tls_openssl.x then net-o-stub.
# PLATFORM: SHARED — TLS opt-in archaeology (not default product link bag).
arch_run_net_o_openssl() {
  if [ ! -x ./xlang_asm ] && [ ! -x ./xlang ] && [ ! -x ./xlang-c ]; then
    echo "archaeology_host_pick_phony: net-o-openssl: need xlang_asm, xlang, or xlang-c" >&2
    return 1
  fi
  sh "$STD_X_SH" auto ../std/net/tls_openssl.x ../std/net/tls_openssl.o || return 1
  arch_run_net_o_stub
}

# net-o-mbedtls: hard-fail without host; main .x + bio glue ld -r + net-o-stub.
# PLATFORM: SHARED — F-ZC mbedTLS BIO merge (runtime_tls_mbedtls_bio.o).
arch_run_net_o_mbedtls() {
  if [ ! -x ./xlang_asm ] && [ ! -x ./xlang ] && [ ! -x ./xlang-c ]; then
    echo "archaeology_host_pick_phony: net-o-mbedtls: need xlang_asm, xlang, or xlang-c" >&2
    return 1
  fi
  sh "$STD_X_SH" auto ../std/net/tls_mbedtls.x ../std/net/tls_mbedtls_main.o || return 1
  "$MAKE" runtime_tls_mbedtls_bio.o || return 1
  # shellcheck disable=SC2086
  ld -r $(arch_ld_r_multidef_flags) -o ../std/net/tls_mbedtls.o \
    ../std/net/tls_mbedtls_main.o runtime_tls_mbedtls_bio.o || return 1
  arch_run_net_o_stub
}

# sqlite-o-stub: always build glue stub; merge sqlite.x when host present.
# PLATFORM: SHARED — archaeology stub path (product sqlite.o is wave811 auto-soft).
arch_run_sqlite_o_stub() {
  "$MAKE" runtime_sqlite_glue_stub.o || return 1
  _mdf="$(arch_ld_r_multidef_flags)"
  if [ -x ./xlang_asm ] || [ -x ./xlang ] || [ -x ./xlang-c ]; then
    sh "$STD_X_SH" auto ../std/db/sqlite/sqlite.x ../std/db/sqlite/sqlite_main.o || return 1
    # shellcheck disable=SC2086
    ld -r $_mdf -o ../std/db/sqlite/sqlite.o \
      ../std/db/sqlite/sqlite_main.o runtime_sqlite_glue_stub.o || return 1
  else
    # shellcheck disable=SC2086
    ld -r $_mdf -o ../std/db/sqlite/sqlite.o runtime_sqlite_glue_stub.o || return 1
    echo "archaeology_host_pick_phony: sqlite-o-stub: need xlang host to merge sqlite.x" >&2
  fi
}

arch_run_key() {
  _k="$1"
  case "$_k" in
    net-o-stub) arch_run_net_o_stub ;;
    net-o-openssl) arch_run_net_o_openssl ;;
    net-o-mbedtls) arch_run_net_o_mbedtls ;;
    sqlite-o-stub) arch_run_sqlite_o_stub ;;
    *)
      echo "archaeology_host_pick_phony: unknown key: $_k" >&2
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# --check: catalog integrity + no dual host-pick ladder expected in Makefile
# (Makefile check is owned by leaf_pattern_residual; this is script self-check)
# ---------------------------------------------------------------------------
arch_check() {
  _n=0
  while IFS= read -r _k; do
    [ -n "$_k" ] || continue
    arch_phony_known "$_k" || {
      echo "archaeology_host_pick_phony: --check: list key not known: $_k" >&2
      return 1
    }
    _n=$((_n + 1))
  done < <(arch_phony_keys)
  if [ "$_n" -ne 4 ]; then
    echo "archaeology_host_pick_phony: --check: expected 4 keys, got $_n" >&2
    return 1
  fi
  if [ ! -f "$STD_X_SH" ]; then
    echo "archaeology_host_pick_phony: --check: missing $STD_X_SH (host compile authority)" >&2
    return 1
  fi
  # Smoke: each key dispatches (dry — do not run bodies that need make/.x host)
  for _k in net-o-stub net-o-openssl net-o-mbedtls sqlite-o-stub; do
    arch_phony_known "$_k" || return 1
  done
  echo "archaeology_host_pick_phony: --check OK (wave815; 4 phonies; host via xlang_compile_std_x)"
  return 0
}

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF' >&2
usage: archaeology_host_pick_phony.sh ensure|auto <phony>
       archaeology_host_pick_phony.sh list
       archaeology_host_pick_phony.sh --check

phonies: net-o-stub | net-o-openssl | net-o-mbedtls | sqlite-o-stub
EOF
}

cmd="${1:-}"
case "$cmd" in
  list)
    arch_phony_keys
    exit 0
    ;;
  --check)
    arch_check
    exit $?
    ;;
  ensure|auto)
    key="${2:-}"
    if [ -z "$key" ]; then
      usage
      exit 1
    fi
    if ! arch_phony_known "$key"; then
      echo "archaeology_host_pick_phony: unknown phony: $key" >&2
      usage
      exit 1
    fi
    arch_run_key "$key"
    exit $?
    ;;
  -h|--help|help|"")
    usage
    exit 1
    ;;
  *)
    # Allow bare `ensure`-style: if first arg is a known key, run it.
    if arch_phony_known "$cmd"; then
      arch_run_key "$cmd"
      exit $?
    fi
    echo "archaeology_host_pick_phony: unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac
