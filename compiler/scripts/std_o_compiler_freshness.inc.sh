# 10.75: stdlib/core cached .o freshness vs compiler product (ABI).
# Sourced by xlang_compile_std_module.sh / xlang_compile_std_x.sh.
# A leaf is stale when the active XLANG binary is newer than the .o, or when
# the sidecar stamp does not match this compiler's id (sha16@mtime).
# PLATFORM: SHARED. No host-cc.
#
# Usage:
#   . "$(dirname "$0")/std_o_compiler_freshness.inc.sh"
#   if std_o_stale_vs_compiler "$out_o"; then ... rebuild ...; fi
#   std_o_write_compiler_stamp "$out_o"   # after successful compile

std_o_resolve_compiler() {
  _soc_xl="${XLANG:-}"
  if [ -n "$_soc_xl" ] && [ -x "$_soc_xl" ]; then
    printf '%s\n' "$_soc_xl"
    return 0
  fi
  for _soc_c in ./xlang ./xlang.cap_g05_l2 ./xlang_asm ./xlang-c; do
    if [ -x "$_soc_c" ]; then
      printf '%s\n' "$_soc_c"
      return 0
    fi
  done
  return 1
}

std_o_compiler_id() {
  # $1 = compiler path
  _soc_bin=$1
  [ -x "$_soc_bin" ] || { echo none; return 1; }
  if command -v sha256sum >/dev/null 2>&1; then
    _soc_sha=$(sha256sum "$_soc_bin" | cut -c1-16)
  else
    _soc_sha=$(shasum -a 256 "$_soc_bin" 2>/dev/null | cut -c1-16)
  fi
  _soc_mt=$(stat -c %Y "$_soc_bin" 2>/dev/null || stat -f %m "$_soc_bin" 2>/dev/null || echo 0)
  printf '%s@%s\n' "$_soc_sha" "$_soc_mt"
}

std_o_stamp_path() {
  # $1 = out.o (may be ../std/... or std/...)
  _soc_leaf=$1
  _soc_key=$(printf '%s' "$_soc_leaf" | sed 's#^\.\./##; s#[/]#_#g; s#^\./##')
  printf 'build_asm/std_o_stamp/%s.id\n' "$_soc_key"
}

# Return 0 if leaf must rebuild for compiler/ABI; 1 if compiler says fresh.
std_o_stale_vs_compiler() {
  _soc_out=$1
  [ -f "$_soc_out" ] || return 0
  _soc_xl=$(std_o_resolve_compiler) || return 1
  if [ "$_soc_xl" -nt "$_soc_out" ]; then
    return 0
  fi
  _soc_id=$(std_o_compiler_id "$_soc_xl") || return 0
  _soc_stamp=$(std_o_stamp_path "$_soc_out")
  if [ ! -f "$_soc_stamp" ]; then
    # First ensure after 10.75: adopt current leaf under this compiler id
    # (no perpetual rebuild when product is older than cached .o).
    std_o_write_compiler_stamp "$_soc_out" || true
    return 1
  fi
  _soc_prev=$(cat "$_soc_stamp" 2>/dev/null || echo none)
  if [ "$_soc_prev" != "$_soc_id" ]; then
    return 0
  fi
  return 1
}

std_o_write_compiler_stamp() {
  _soc_out=$1
  _soc_xl=$(std_o_resolve_compiler) || return 0
  _soc_id=$(std_o_compiler_id "$_soc_xl") || return 0
  _soc_stamp=$(std_o_stamp_path "$_soc_out")
  mkdir -p "$(dirname "$_soc_stamp")"
  printf '%s\n' "$_soc_id" > "$_soc_stamp"
}
