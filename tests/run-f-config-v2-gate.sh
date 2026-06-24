#!/usr/bin/env bash
# F-config v2：std.config 逻辑下沉（TOML/YAML/ENV → config.sx；F-ZC 纯 .sx 无 io glue）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_CONFIG_V2_FAIL:-0}
DOC="analysis/phase-f-config-v2.md"
MANIFEST="tests/baseline/f-config-v2-closure.tsv"
die() { echo "f-config-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-config v2: config logic → config.sx (F-ZC zero C) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-config v2' "$DOC" || die "doc marker"
[ -f std/config/config.sx ] || die "missing config.sx"
[ ! -f std/config/config_io_glue.c ] || die "config_io_glue.c should be deleted (F-ZC)"
[ ! -f std/config/config_glue.c ] || die "config_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'config_load_toml_buf_c' std/config/config.sx || die "config.sx missing toml load"
grep -q 'config_load_yaml_buf_c' std/config/config.sx || die "config.sx missing yaml load"
grep -q 'config_smoke_c' std/config/config.sx || die "config.sx missing smoke"
grep -q 'config_f_config_v2_marker_c' std/config/config.sx || die "config.sx missing v2 marker"
grep -q 'config_f_zero_c_marker_c' std/config/config.sx || die "config.sx missing zero-c marker"
grep -q 'config_read_file_c' std/config/config.sx || die "config.sx missing read_file"
grep -q 'fs_open_read_c' std/config/config.sx || die "config.sx missing fs IO"
grep -q 'config.sx' compiler/Makefile || die "Makefile missing config.sx"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/config/config.o >/dev/null 2>&1 || die "make config.o failed"
else
  echo "f-config-v2 SKIP config.o build (no shux-c)" >&2
fi
for sub in run-std-config-gate.sh run-std-config-yaml-gate.sh; do
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-config-v2 gate OK"
