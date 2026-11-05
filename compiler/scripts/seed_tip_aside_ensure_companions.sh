#!/usr/bin/env bash
# seed_tip_aside_ensure_companions.sh — tip_l4_mac_aside_user_env_seed
#
# tip-aside hosts resolve compiler_dir via dirname(exe) (_NSGetExecutablePath /
# realpath). link_abi_ensure then looks for <aside>/seeds/<stem>.from_x.c (or
# skips if <aside>/<stem>.o already exists). Without this, Mac tip_aside L2 is
# 0/5 BLD001 on runtime_link_abi_user_env (then io_stubs / panic).
#
# Usage (cwd irrelevant):
#   bash compiler/scripts/seed_tip_aside_ensure_companions.sh <aside_dir>
#   # or source + call:
#   . compiler/scripts/seed_tip_aside_ensure_companions.sh
#   seed_tip_aside_ensure_companions <aside_dir>
#
# Ban: Soft Cap Prefer / Cap tip Prefer raise; fake green. PLATFORM: SHARED.
set -eu

seed_tip_aside_ensure_companions() {
  local aside_dir="${1:-}"
  local stem="" seed_src="" o_src="" n=0
  local _here _compiler
  _here="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  _compiler="$(CDPATH= cd -- "$_here/.." && pwd)"

  if [ -z "$aside_dir" ] || [ ! -d "$aside_dir" ]; then
    return 0
  fi
  if [ ! -x "$aside_dir/xlang" ] && [ ! -x "$aside_dir/xlang_asm" ] \
    && [ ! -x "$aside_dir/xlang.exe" ] && [ ! -x "$aside_dir/xlang_asm.exe" ]; then
    return 0
  fi
  mkdir -p "$aside_dir/seeds"

  # Primary residual = user_env; peel chain for hosted exe link also needs
  # io_stubs + panic (+ process_argv for common L2 probes). Seeds enable
  # rebuild; .o lets ensure skip_missing short-circuit.
  for stem in runtime_link_abi_user_env runtime_asm_io_stubs runtime_panic runtime_process_argv; do
    seed_src="$_compiler/seeds/${stem}.from_x.c"
    o_src="$_compiler/${stem}.o"
    if [ -f "$seed_src" ]; then
      cp -f "$seed_src" "$aside_dir/seeds/${stem}.from_x.c" || true
    fi
    if [ -s "$o_src" ]; then
      cp -f "$o_src" "$aside_dir/${stem}.o" || true
    elif [ -f "$seed_src" ]; then
      if ( cd "$_compiler" && bash scripts/ensure_host_cc_seed_o.sh one "${stem}.o" "seeds/${stem}.from_x.c" ) \
        && [ -s "$_compiler/${stem}.o" ]; then
        cp -f "$_compiler/${stem}.o" "$aside_dir/${stem}.o" || true
      fi
    fi
    if [ -f "$aside_dir/seeds/${stem}.from_x.c" ] || [ -s "$aside_dir/${stem}.o" ]; then
      n=$((n + 1))
    fi
  done
  # Darwin panic may prefer arm64 seed leaf.
  if [ -f "$_compiler/seeds/runtime_panic_arm64.from_x.c" ]; then
    cp -f "$_compiler/seeds/runtime_panic_arm64.from_x.c" \
      "$aside_dir/seeds/runtime_panic_arm64.from_x.c" || true
  fi
  if [ "$n" -gt 0 ]; then
    echo "seed_tip_aside_ensure_companions: seeded $n stems → $aside_dir" >&2
  fi
  return 0
}

# Direct invoke: seed the given aside dir.
if [ "${BASH_SOURCE[0]:-$0}" = "$0" ] || [ "${1:-}" = "--run" ]; then
  if [ "${1:-}" = "--run" ]; then shift; fi
  seed_tip_aside_ensure_companions "${1:-}"
fi
