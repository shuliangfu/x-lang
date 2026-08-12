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

# ---------------------------------------------------------------------------
# pure_ld_partial_merge — merge .o files into a single relocatable .o.
# Replaces `$CC -r -nostdlib -o OUT OBJS...` in the prefer hybrid path
# (thin.o + rest.o → final.o) used by ensure_host_cc_seed_o.sh and
# g05_ensure_relink_prereqs.sh (Stage 12.2.3 zero-CC partial-merge).
#
# When XLANG_ZERO_CC_LD=1: uses `ld -r` with multidef flags (zero-CC).
# When unset (default): uses `$CC -r -nostdlib` (original behavior; zero
# regression — callers that don't set the flag are unaffected).
#
# Usage: pure_ld_partial_merge OUT OBJS...
#   OBJS is one or more .o paths (space-separated).
# Returns 0 on success, non-zero on failure. Caller owns stderr redirect.
#
# PLATFORM: SHARED — ld -r + multidef; no syslibroot/dynamic (relocatable
#           merge, not final executable link). multidef via
#           pure_ld_multidef_flags (Darwin: -multiply_defined suppress;
#           Linux: --allow-multiple-definition).
# ---------------------------------------------------------------------------
pure_ld_partial_merge() {
  local out="$1"; shift
  local objs="$*"
  local ld_bin multidef
  if [ -z "$out" ] || [ -z "$objs" ]; then
    echo "pure_ld_shared: pure_ld_partial_merge needs OUT and OBJS" >&2
    return 1
  fi
  if [ "${XLANG_ZERO_CC_LD:-0}" = "1" ]; then
    ld_bin="$(pure_ld_resolve_ld)" || {
      echo "pure_ld_shared: ld not found for partial_merge" >&2
      return 1
    }
    multidef="$(pure_ld_multidef_flags)"
    # shellcheck disable=SC2086
    "$ld_bin" -r $multidef -o "$out" $objs
  else
    # Original path: $CC -r -nostdlib (zero regression when flag unset).
    # shellcheck disable=SC2086
    ${CC:-cc} -r -nostdlib -o "$out" $objs
  fi
}

# ---------------------------------------------------------------------------
# pure_as_compile — assemble a .s file into a .o (zero-CC COMPILE elimination).
# Replaces `$CC -c -o OUT SRC.s` in R2 panic/crt0/typeck_f64 paths
# (Stage 12.2.3 zero-CC COMPILE migration for pure assembly files).
#
# When XLANG_ZERO_CC_AS=1: uses system `as` (zero-CC; .s files are pure
#   assembly, no C preprocessor needed — verified: 0 cpp directives in all
#   crt0_*.s / runtime_panic_*.s / typeck_f64_bits_*.s).
# When unset (default): uses `$CC -c` (original behavior; zero regression).
#
# Usage: pure_as_compile OUT SRC.s
# Returns 0 on success, non-zero on failure.
#
# PLATFORM: SHARED — `as` is available on macOS (Xcode tools) and Linux
#           (binutils). .s (lowercase) = no cpp; .S (uppercase) would need cpp
#           and must NOT use this helper.
# ---------------------------------------------------------------------------
pure_as_compile() {
  local out="$1"
  local src="$2"
  if [ -z "$out" ] || [ -z "$src" ]; then
    echo "pure_ld_shared: pure_as_compile needs OUT and SRC" >&2
    return 1
  fi
  if [ "${XLANG_ZERO_CC_AS:-0}" = "1" ]; then
    # Zero-CC: system assembler (no C compiler invoked).
    as -o "$out" "$src"
  else
    # Original path: $CC -c (zero regression when flag unset).
    # shellcheck disable=SC2086
    ${CC:-cc} -c -o "$out" "$src"
  fi
}

# ---------------------------------------------------------------------------
# pure_asm_find_objcopy — stdout: path to objcopy that supports --weaken.
# Used by pure_asm weak polish (Stage 12.0.5 ldpc pure-asm hybrid residual).
# Prefer XLANG_OBJCOPY, then llvm-objcopy / objcopy / common install paths.
# PLATFORM: SHARED — Darwin (homebrew llvm) · Linux (binutils/llvm).
# ---------------------------------------------------------------------------
pure_asm_find_objcopy() {
  local c path
  for c in \
    "${XLANG_OBJCOPY:-}" \
    llvm-objcopy \
    objcopy \
    gobjcopy \
    /opt/homebrew/opt/llvm/bin/llvm-objcopy \
    /usr/local/opt/llvm/bin/llvm-objcopy \
    /usr/bin/llvm-objcopy \
    /usr/bin/objcopy; do
    [ -n "$c" ] || continue
    path=""
    if [ -x "$c" ]; then
      path="$c"
    elif command -v "$c" >/dev/null 2>&1; then
      path="$(command -v "$c")"
    fi
    [ -n "$path" ] || continue
    # Require --weaken (llvm-objcopy / GNU binutils); nmedit cannot weak pure-asm.
    # PLATFORM: SHARED — use /usr/bin/grep when present so agent/shells that
    # shadow `grep` (ugrep wrappers without -q) do not false-negative objcopy.
    if "$path" --help 2>&1 | command grep -q -- '--weaken' 2>/dev/null \
      || "$path" --help 2>&1 | /usr/bin/grep -q -- '--weaken' 2>/dev/null; then
      printf '%s\n' "$path"
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# pure_asm_apply_weak_polish OUT
# Mirror rt_prefer_try_x_to_o C rewrite of G05_X_O_WEAK / G05_X_O_WEAK_FUNCS
# after freestanding pure-asm emit (no temp C). G.7 有则补全 on pure_asm path:
#   · G05_X_O_WEAK=1        → objcopy --weaken (all defined globals weak)
#   · G05_X_O_WEAK_FUNCS    → --weaken-symbol per bare C name
#                             (Darwin Mach-O: try _name first, then name)
# Returns 0 on success; 1 if no capable objcopy or polish failed (caller must
# fall through to -E+$CC so product hybrid stays green without the tool).
# PLATFORM: SHARED — ELF/Mach-O weak binding; PE residual still -E path.
# ---------------------------------------------------------------------------
pure_asm_apply_weak_polish() {
  local out="$1"
  local oc="" uname_s="" _old_ifs="" _wfn="" _ok=0
  if [ -z "$out" ] || [ ! -s "$out" ]; then
    return 1
  fi
  # No polish requested: success no-op (pure_asm caller only invokes when set).
  if [ "${G05_X_O_WEAK:-0}" != "1" ] && [ -z "${G05_X_O_WEAK_FUNCS:-}" ]; then
    return 0
  fi
  oc="$(pure_asm_find_objcopy)" || return 1
  uname_s="$(uname -s 2>/dev/null || echo Unknown)"
  if [ -n "${G05_X_O_WEAK_FUNCS:-}" ]; then
    # Named weak only (seed_link_compat 6 stubs etc.). Do NOT --weaken all.
    _old_ifs="$IFS"
    IFS=','
    for _wfn in $G05_X_O_WEAK_FUNCS; do
      _wfn="$(printf '%s' "$_wfn" | tr -d '[:space:]')"
      [ -z "$_wfn" ] && continue
      _ok=0
      # PLATFORM: MACOS|DARWIN — C symbols in Mach-O objects are underscore-prefixed.
      if [ "$uname_s" = "Darwin" ]; then
        if "$oc" --weaken-symbol="_${_wfn}" "$out" 2>/dev/null; then
          _ok=1
        fi
      fi
      if [ "$_ok" != "1" ]; then
        if ! "$oc" --weaken-symbol="${_wfn}" "$out" 2>/dev/null; then
          IFS="$_old_ifs"
          return 1
        fi
      fi
    done
    IFS="$_old_ifs"
    return 0
  fi
  # G05_X_O_WEAK=1: weaken every defined global (matches -E perl XLANG_WEAK polish).
  if ! "$oc" --weaken "$out" 2>/dev/null; then
    return 1
  fi
  return 0
}

# ---------------------------------------------------------------------------
# xlang_strip_tree_prefer_asm_unless_allowed — Stage 12.0.5 tree PREFER ban.
# G.7 single authority: product must not inherit ambient tree-level
# XLANG_PREFER_ASM_O=1 (historic full-hybrid SEGV map; pipeline_abi hang when
# pure-asm leaked into mega ensure). Prefer families scope PREFER_ASM_O=1 only
# inside their pure_asm subshells (LABI/RT/G05 defaults).
#
# Policy:
#   · XLANG_ALLOW_TREE_PREFER_ASM=1 → keep ambient PREFER_ASM_O (opt-in maps /
#     ABI bisect; explicit operator consent).
#   · else if PREFER_ASM_O=1 → unset + one-line stderr note.
#   · else → no-op.
#
# Callers (product entry, after sourcing this file):
#   · ensure_host_cc_seed_o.sh
#   · g05_ensure_relink_prereqs.sh
# Prefer-family try_* also unset PREFER when family=0 unless ALLOW_TREE (belt).
# PLATFORM: SHARED — shell env hygiene; mac + Ubuntu product soft-g05.
# ---------------------------------------------------------------------------
xlang_strip_tree_prefer_asm_unless_allowed() {
  if [ "${XLANG_PREFER_ASM_O:-0}" != "1" ]; then
    return 0
  fi
  if [ "${XLANG_ALLOW_TREE_PREFER_ASM:-0}" = "1" ]; then
    return 0
  fi
  echo "xlang: tree XLANG_PREFER_ASM_O=1 stripped (ban default; prefer families scope pure-asm; set XLANG_ALLOW_TREE_PREFER_ASM=1 to keep)" >&2
  unset XLANG_PREFER_ASM_O
  return 0
}

# ---------------------------------------------------------------------------
# pure_asm_x_to_o — freestanding .x → .o via asm backend (zero host-cc COMPILE).
# Stage 12.0.5: G.7 single authority for pure asm module emit.
#
# Callers (Stage 12.0.5 product pure-asm defaults; authorized 2026-08-12):
#   · labi_prefer_try_x_to_o — XLANG_PREFER_ASM_O_LABI default 1 (labi slices).
#   · rt_prefer_try_x_to_o — XLANG_PREFER_ASM_O_RT default 1 (rt / async / R3 /
#     l2-asm / tcpu / ldpc / other-l2 / B1–B3 prefer families reusing harness).
#   · g05_try_x_to_o — XLANG_PREFER_ASM_O_G05 default 1 (residual g05 direct).
# Each scopes XLANG_PREFER_ASM_O=1 in a subshell only for this helper; tree
# PREFER_ASM_O stays unset by default (product entry strips ambient unless
# XLANG_ALLOW_TREE_PREFER_ASM=1). Fall through to -E+$CC on reject/fail.
# Ban: tree-level PREFER_ASM_O=1 as product default (see
# xlang_strip_tree_prefer_asm_unless_allowed).
# Hard ban: pure-asm on runtime_pipeline_abi.x mega (instant return 1; hang map
# 2026-08-12). Product call-site also forces XLANG_PREFER_ASM_O_RT=0 in
# ensure_pipeline_abi_prefer_one (belt-and-suspenders; G.7 complete policy).
# Hang guard: pure_asm_emit_with_timeout (default 90s; XLANG_PURE_ASM_TIMEOUT_SEC)
# so any non-banned unbounded emit cannot stall ensure forever.
# Escape: PREFER_ASM_O_{LABI,RT,G05}=0 per family.
#
# When XLANG_PREFER_ASM_O=1: run `$XLANG -backend asm -c` via a staged `*.o`
#   path (driver only emits relocatable objects when OUT ends with `.o`;
#   ensure mktemp thins are extension-less).
# When unset: return 1 immediately (callers that did not scope a family default).
#
# Skip (return 1) when:
#   · SRC is runtime_pipeline_abi.x mega (hard ban; Stage12.0.5 map 2026-08-12:
#     full mega pure-asm hangs 180s+ with empty OUT/stderr — tree PREFER_ASM=1
#     would stall try-pipeline-abi-prefer before -E fallthrough)
#   · emit exceeds XLANG_PURE_ASM_TIMEOUT_SEC (default 90; hang residual safety)
#   · G05_X_O_SYM_RENAME set (still needs C identifier rewrite; no pure-asm polish)
#   · object has U xlang_panic or bare U __error (g05 pure-ld surface mismatch)
#   · CG002 / typeck / empty output
#   · XLANG_PREFER_ASM_O_ONLY set and SRC basename not in the allow-list
#   · G05_X_O_WEAK / G05_X_O_WEAK_FUNCS set but objcopy --weaken unavailable/fails
#     (fall through to historic -E+$CC weak polish)
#
# Weak polish (Stage 12.0.5 residual close for ldpc pure-asm hybrid):
#   After successful pure-asm emit, apply pure_asm_apply_weak_polish so product
#   hybrid under G05_X_O_WEAK=1 no longer multidefs vs strong peers (e.g.
#   lsp_diag_{hover,definition,references}_at vs lsp_diag_x.o). nmedit cannot
#   mark pure-asm objects weak; llvm-objcopy/binutils --weaken is the authority.
#
# XLANG_PREFER_ASM_O_ONLY (optional, Stage 12.0.5 ABI bisect):
#   Comma-separated basenames or stems, e.g. "rt_util.x,rt_content" or "rt_util".
#   When set with PREFER_ASM_O=1, only matching sources take pure-asm; others
#   return 1 immediately so callers fall through to -E+$CC. Unset = all
#   PREFER_ASM_O sources try pure-asm (historic full-hybrid behavior).
#   Used to single-slice / binary-search L2 SIGSEGV under product hybrid.
#
# Usage: pure_asm_x_to_o OUT SRC.x
# Returns 0 on success (OUT non-empty), non-zero to fall through.
#
# PLATFORM: SHARED — asm backend object emit; no temp C; no host-cc on this path.
# ---------------------------------------------------------------------------

# pure_asm_emit_with_timeout XL STAGE SRC
# Run `$XL -backend asm -c -o STAGE SRC` with hang guard.
# XLANG_PURE_ASM_TIMEOUT_SEC default 90; 0 disables (unbounded; bisect only).
# Returns 0 if the emit process exited 0; else 1 (and best-effort rm STAGE).
# PLATFORM: SHARED — Stage12.0.5 hang residual (mega pure-asm 180s+ stall map);
# bash job control only (no GNU timeout required on Darwin).
# G.7: sole pure-asm emit launcher used by pure_asm_x_to_o.
pure_asm_emit_with_timeout() {
  local xl="$1" stage="$2" src="$3"
  local to="${XLANG_PURE_ASM_TIMEOUT_SEC:-90}"
  local pid="" killer="" rc=0

  if [ -z "$xl" ] || [ -z "$stage" ] || [ -z "$src" ]; then
    return 1
  fi
  # Non-numeric / empty → default 90 (avoid silent disable from bad env).
  case "$to" in
    ''|*[!0-9]*) to=90 ;;
  esac

  # Timeout 0: historic unbounded emit (diagnostic maps only).
  if [ "$to" = "0" ]; then
    "$xl" -backend asm -c -o "$stage" "$src" 2>/dev/null
    return $?
  fi

  # Hang guard: kill emit if it exceeds `to` seconds.
  # Map 2026-08-12: mega pure-asm hung 180s+ with empty OUT/stderr; basename ban
  # covers runtime_pipeline_abi.x, timeout is residual safety for any other
  # unbounded pure-asm emit that could stall try-*-prefer before -E fallthrough.
  "$xl" -backend asm -c -o "$stage" "$src" 2>/dev/null &
  pid=$!
  (
    sleep "$to"
    kill -TERM "$pid" 2>/dev/null || true
    sleep 1
    kill -KILL "$pid" 2>/dev/null || true
  ) &
  killer=$!
  rc=0
  wait "$pid" 2>/dev/null || rc=$?
  kill -TERM "$killer" 2>/dev/null || true
  wait "$killer" 2>/dev/null || true
  # Non-zero (incl. 128+SIGTERM/SIGKILL from hang guard) → reject stage.
  if [ "$rc" -ne 0 ]; then
    rm -f "$stage" 2>/dev/null || true
    return 1
  fi
  return 0
}

pure_asm_x_to_o() {
  local out="$1"
  local src="$2"
  local xl=""
  local _pure_asm_stage=""
  local _bn="" _stem="" _only="" _tok="" _match=0 _old_ifs=""
  if [ -z "$out" ] || [ -z "$src" ]; then
    return 1
  fi
  # Gate: ambient XLANG_PREFER_ASM_O=1 only. Prefer families scope this via
  # subshell when PREFER_ASM_O_{LABI,RT,G05} defaults on (product pure-asm
  # default; authorized 2026-08-12). Tree PREFER_ASM_O is stripped at product
  # entry unless XLANG_ALLOW_TREE_PREFER_ASM=1 (diagnostic maps / ABI bisect).
  if [ "${XLANG_PREFER_ASM_O:-0}" != "1" ]; then
    return 1
  fi
  # SYM_RENAME still needs C identifier rewrite; pure-asm cannot rename.
  if [ -n "${G05_X_O_SYM_RENAME:-}" ]; then
    return 1
  fi
  if [ ! -f "$src" ]; then
    return 1
  fi
  # Hard ban: runtime_pipeline_abi mega pure-asm.
  # PLATFORM: SHARED — map @ tip edf848abc: `xlang -backend asm -c` on this
  # 85k-line mega hangs 180s+ with zero stderr and no .o; pure_asm_x_to_o had
  # no timeout so PREFER_ASM_O=1 leaked into try-pipeline-abi-prefer and stalled
  # product ensure (G05_X_O_WEAK thin path). Immediate reject → -E+$CC hybrid.
  # Product call-site also forces XLANG_PREFER_ASM_O_RT=0 (ensure_pipeline_abi
  # prefer_one) so rt_prefer never enters pure_asm for this mega.
  # Not a product default flip; codifies the long-standing policy ban in G.7.
  _bn="$(basename "$src")"
  if [ "$_bn" = "runtime_pipeline_abi.x" ]; then
    return 1
  fi
  # Optional single-slice / allow-list gate for hybrid ABI bisect.
  # PLATFORM: SHARED diagnostic harness — does not change default-all behavior.
  if [ -n "${XLANG_PREFER_ASM_O_ONLY:-}" ]; then
    _bn="$(basename "$src")"
    _stem="${_bn%.x}"
    _match=0
    _old_ifs="$IFS"
    IFS=','
    for _tok in $XLANG_PREFER_ASM_O_ONLY; do
      _tok="$(printf '%s' "$_tok" | tr -d '[:space:]')"
      [ -z "$_tok" ] && continue
      if [ "$_tok" = "$_bn" ] || [ "$_tok" = "$_stem" ] \
        || [ "$_tok" = "${_stem}.x" ]; then
        _match=1
        break
      fi
    done
    IFS="$_old_ifs"
    if [ "$_match" != "1" ]; then
      return 1
    fi
  fi
  # Prefer product xlang (g05 / soft-relink tip), then explicit XLANG, then
  # experimental xlang_asm / seed eggs. Preferring xlang_asm over product
  # silently re-emitted stale pure-asm (no Stage12.0.5 sxtw) under hybrid
  # bisect — PLATFORM: SHARED harness.
  if [ -n "${XLANG:-}" ] && [ -x "$XLANG" ]; then
    xl="$XLANG"
  elif [ -x ./xlang ]; then
    xl=./xlang
  elif [ -x ./xlang_asm ]; then
    xl=./xlang_asm
  elif [ -x ./xlang-c ]; then
    xl=./xlang-c
  elif [ -x ./bootstrap_xlangc ]; then
    xl=./bootstrap_xlangc
  else
    return 1
  fi
  mkdir -p "$(dirname "$out")" 2>/dev/null || true
  # PLATFORM: SHARED — freestanding asm .o; stderr discarded (caller has seed fallback).
  # Critical: product `xlang -backend asm -c -o PATH` only emits a relocatable
  # object when PATH ends with `.o`. Otherwise the driver treats PATH as a final
  # link target (needs main) → BLD001 ld fail. ensure thin temps from mktemp are
  # extension-less (`rtpref_*_thin.XXXXXX`), so always stage via a `*.o` temp
  # then mv into the caller path (G.7 single authority; callers stay unchanged).
  # BSD/macOS mktemp needs X-run at end of template — create bare temp, append .o.
  # Hang guard: pure_asm_emit_with_timeout (default 90s) — residual safety net
  # for unbounded pure-asm after basename ban (COMPILE residual Stage12.0.5).
  _pure_asm_stage=$(mktemp "${TMPDIR:-/tmp}/pure_asm.XXXXXX") || return 1
  rm -f "$_pure_asm_stage"
  _pure_asm_stage="${_pure_asm_stage}.o"
  if pure_asm_emit_with_timeout "$xl" "$_pure_asm_stage" "$src" \
    && [ -s "$_pure_asm_stage" ]; then
    # Product g05 pure-ld surface guard (Stage 12.0.5 residual):
    # · asm bounds checks emit U xlang_panic_ — not in g05 freestanding bag
    #   (runtime_panic.o is user-domain cold twin; g05 has no T xlang_panic_).
    # · bare U __error was Darwin mangling miss (fixed Stage 12.0.5: always
    #   prepend '_' so C __error → ___error). Keep reject as safety net if any
    #   residual path still emits unmangled __error.
    # · U xlang_driver_*_opaque / stdout_ptr / fflush_stdout / realpath_opaque /
    #   pipeline_run_x_thread_fn_ptr / asm_elf_o_thread_fn_ptr — these exist
    #   only as static inline in rt_prefer_try_x_to_o C prologue (G-02f-332/334;
    #   ensure_host_cc_seed_o.sh). pure-asm never injects that prologue, so
    #   accepting such .o → g05 pure-ld UNDEF (R3 hybrid residual:
    #   runtime_driver_abi_thin pure-asm → driver_env_flag_truthy refs).
    # Reject → caller falls back to -E+$CC (zero product regression; prologue
    #   path resolves helpers as local `t`).
    # PLATFORM: SHARED reject list · G.7 有则补全 freestanding surface.
    if nm -u "$_pure_asm_stage" 2>/dev/null | grep -E \
      'xlang_panic|^__error$|xlang_driver_(fputs_opaque|stdout_ptr|fclose_opaque|fwrite_opaque|fopen_write_opaque|stderr_ptr|fflush_stdout|fopen_wb_opaque|fdopen_wb_opaque|realpath_opaque|pipeline_run_x_thread_fn_ptr|asm_elf_o_thread_fn_ptr)' \
      >/dev/null 2>&1; then
      rm -f "$_pure_asm_stage"
      return 1
    fi
    # Weak polish before install: G05_X_O_WEAK / G05_X_O_WEAK_FUNCS (G.7).
    # Fail polish → drop stage and fall through to -E+$CC (same as missing objcopy).
    if [ "${G05_X_O_WEAK:-0}" = "1" ] || [ -n "${G05_X_O_WEAK_FUNCS:-}" ]; then
      if ! pure_asm_apply_weak_polish "$_pure_asm_stage"; then
        rm -f "$_pure_asm_stage"
        return 1
      fi
    fi
    if mv -f "$_pure_asm_stage" "$out" 2>/dev/null; then
      return 0
    fi
    # mv failed (cross-device rare): try cp then rm
    if cp -f "$_pure_asm_stage" "$out" 2>/dev/null && [ -s "$out" ]; then
      rm -f "$_pure_asm_stage"
      return 0
    fi
  fi
  rm -f "$_pure_asm_stage" 2>/dev/null || true
  return 1
}

# ---------------------------------------------------------------------------
# pure_ld_hosted_crt1 — stdout: path to system crt1.o for hosted (with libc)
# pure-ld links. Complements the freestanding crt0 path (pure_ld_default_entry
# + nostdlib). Used by relink_xlang_asm_experimental_bootstrap.sh to replace
# `$CC -o ...` (which auto-includes crt1.o) with pure `ld` (Stage 12.2.3).
#
# Returns 0 and prints crt1.o path on success; returns 1 if not found.
#
# PLATFORM: MACOS — $SDK/usr/lib/crt1.o (via xcrun or fallback SDK paths).
# PLATFORM: LINUX — /usr/lib/<triple>/crt1.o or /usr/lib/crt1.o (glibc).
# PLATFORM: WINDOWS — not eligible (caller uses CC residual).
# ---------------------------------------------------------------------------
pure_ld_hosted_crt1() {
  local os arch sdk
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
          /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk; do
          if [ -d "$c" ]; then sdk="$c"; break; fi
        done
      fi
      if [ -n "$sdk" ] && [ -f "$sdk/usr/lib/crt1.o" ]; then
        printf '%s\n' "$sdk/usr/lib/crt1.o"
        return 0
      fi
      echo "pure_ld_shared: crt1.o not found under SDK=$sdk" >&2
      return 1
      ;;
    Linux)
      local triple=""
      case "$arch" in
        x86_64|amd64) triple="x86_64-linux-gnu" ;;
        aarch64) triple="aarch64-linux-gnu" ;;
      esac
      for c in \
        "/usr/lib/${triple}/crt1.o" \
        "/usr/lib/crt1.o" \
        "/usr/lib64/crt1.o"; do
        if [ -f "$c" ]; then
          printf '%s\n' "$c"
          return 0
        fi
      done
      echo "pure_ld_shared: crt1.o not found (triple=$triple)" >&2
      return 1
      ;;
    *)
      echo "pure_ld_shared: crt1.o not available on $os" >&2
      return 1
      ;;
  esac
}
