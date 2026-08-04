#!/usr/bin/env bash
# pure_ld_shared.sh — 11.1.4 pure-ld platform helpers (G.7 single authority)
#
# Sourced by:
#   · bootstrap_driver_seed_link.sh  (cold phase1/final · wave772)
#   · g05_relink_xlang.sh            (product g05 final link · wave773)
#
# PLATFORM: SHARED — freestanding eligibility + multidef / entry composition
# PLATFORM: MACOS  — syslibroot / -dynamic / -arch / -platform_version / -lSystem
# PLATFORM: LINUX  — multidef + -lc (libc freestanding) or nostdlib static (g05)
# PLATFORM: WINDOWS — pure-ld not eligible (caller uses named CC residual only)
#
# G.7: Do not open a second pure-ld platform table in cold or g05.
# Object lists stay at the caller (Makefile export / g05_relink_env).
# wave774: callers must not silently fall back to CC after pure_ld_try_link fails;
#          FORCE_CC / ineligible host are the only named CC residual entries.
#
# Wave: 772 platform prefix in seed_link · 773 extract + g05 prefer · 774 drop silent fallback.

# ---------------------------------------------------------------------------
# pure_ld_platform_prefix — stdout: space-separated ld flags (may be empty)
# Returns 1 when host cannot pure-ld (Windows / missing Darwin SDK).
# ---------------------------------------------------------------------------
pure_ld_platform_prefix() {
  local os arch sdk ver
  os="$(uname -s 2>/dev/null || echo Unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  case "$os" in
    Darwin)
      sdk=""
      if command -v xcrun >/dev/null 2>&1; then
        sdk="$(xcrun --show-sdk-path 2>/dev/null || true)"
      fi
      if [ -z "$sdk" ] || [ ! -d "$sdk" ]; then
        for c in \
          /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
          /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
        do
          if [ -d "$c" ]; then sdk="$c"; break; fi
        done
      fi
      if [ -z "$sdk" ] || [ ! -d "$sdk" ]; then
        echo "pure_ld_shared: Darwin SDK not found (need xcrun --show-sdk-path)" >&2
        return 1
      fi
      ver="$(sw_vers -productVersion 2>/dev/null || echo 14.0)"
      case "$arch" in
        arm64|aarch64) arch=arm64 ;;
        x86_64|amd64) arch=x86_64 ;;
      esac
      # Match clang freestanding link shape (dynamic + syslibroot + platform).
      printf '%s\n' "-syslibroot ${sdk} -dynamic -arch ${arch} -platform_version macos ${ver} ${ver}"
      return 0
      ;;
    Linux)
      printf '%s\n' ""
      return 0
      ;;
    *)
      echo "pure_ld_shared: unsupported host OS=$os for pure-ld" >&2
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# pure_ld_multidef_flags — host multidef for final executable link
# ---------------------------------------------------------------------------
pure_ld_multidef_flags() {
  case "$(uname -s 2>/dev/null || echo Unknown)" in
    Darwin) printf '%s\n' "-multiply_defined suppress" ;;
    Linux) printf '%s\n' "--allow-multiple-definition" ;;
    *) printf '%s\n' "" ;;
  esac
}

# ---------------------------------------------------------------------------
# pure_ld_freestanding_ok — 0 if freestanding crt0 pure-ld is eligible
# Mirrors Makefile SEED_LINK_PURE_OK (Darwin any arch · Linux x86_64).
# ---------------------------------------------------------------------------
pure_ld_freestanding_ok() {
  local os arch
  os="$(uname -s 2>/dev/null || echo Unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  case "$os" in
    Darwin) return 0 ;;
    Linux)
      case "$arch" in
        x86_64|amd64) return 0 ;;
        *) return 1 ;;
      esac
      ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# pure_ld_default_entry — freestanding entry flag (stdout)
# ---------------------------------------------------------------------------
pure_ld_default_entry() {
  printf '%s\n' "-e _start"
}

# ---------------------------------------------------------------------------
# pure_ld_default_libc_tail — -lSystem / -lc for freestanding-with-libc
# (cold seed · g05 when not nostdlib). Empty string for nostdlib product.
# ---------------------------------------------------------------------------
pure_ld_default_libc_tail() {
  case "$(uname -s 2>/dev/null || echo Unknown)" in
    Darwin) printf '%s\n' "-lSystem" ;;
    Linux) printf '%s\n' "-lc" ;;
    *) printf '%s\n' "" ;;
  esac
}

# ---------------------------------------------------------------------------
# pure_ld_resolve_ld — pick ld binary (arg preferred, else PATH)
# ---------------------------------------------------------------------------
pure_ld_resolve_ld() {
  local preferred="${1:-}"
  if [ -n "$preferred" ]; then
    if [ -x "$preferred" ]; then
      printf '%s\n' "$preferred"
      return 0
    fi
    if command -v "$preferred" >/dev/null 2>&1; then
      command -v "$preferred"
      return 0
    fi
  fi
  if command -v ld >/dev/null 2>&1; then
    command -v ld
    return 0
  fi
  return 1
}

# ---------------------------------------------------------------------------
# pure_ld_try_link — run pure ld once
# Usage: pure_ld_try_link OUT "OBJS..." ENTRY TAIL [EXTRA_LD_FLAGS] [LD_BIN]
#   ENTRY/TAIL/EXTRA are space-separated flag strings (may be empty).
# Returns 0 on success. Does not fall back to CC (caller owns residual).
# ---------------------------------------------------------------------------
pure_ld_try_link() {
  local out="$1"
  local objs="$2"
  local entry="${3:-}"
  local tail="${4:-}"
  local extra="${5:-}"
  local ld_pref="${6:-}"
  local plat ld_bin multidef n_objs

  if [ -z "$out" ] || [ -z "$objs" ]; then
    echo "pure_ld_shared: pure_ld_try_link needs OUT and OBJS" >&2
    return 1
  fi
  if ! pure_ld_freestanding_ok; then
    echo "pure_ld_shared: host not freestanding pure-ld eligible" >&2
    return 1
  fi
  plat="$(pure_ld_platform_prefix)" || return 1
  ld_bin="$(pure_ld_resolve_ld "$ld_pref")" || {
    echo "pure_ld_shared: ld not found" >&2
    return 1
  }
  multidef="$(pure_ld_multidef_flags)"
  n_objs=$(printf '%s\n' "$objs" | wc -w | tr -d ' ')
  echo "pure_ld_shared: ld=$(basename "$ld_bin") → $out ($n_objs objs)" >&2
  # shellcheck disable=SC2086
  if "$ld_bin" $plat $multidef $extra $entry -o "$out" $objs $tail; then
    echo "pure_ld_shared: OK pure-ld $out" >&2
    return 0
  fi
  echo "pure_ld_shared: pure-ld failed for $out" >&2
  return 1
}
