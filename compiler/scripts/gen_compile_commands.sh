#!/usr/bin/env bash
# 生成 compiler/compile_commands.json + ide/pipeline_glue_types.inc，供 clangd 精确解析。
# 用法（仓库根目录）：./compiler/scripts/gen_compile_commands.sh
# 或：./xbuild compiler-make compile_commands.json

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CDIR="$ROOT/compiler"
IDE="$CDIR/ide"
OUT="$CDIR/compile_commands.json"
SNAP="$CDIR/typeck_gen_full.c"
INC="$IDE/pipeline_glue_types.inc"

mkdir -p "$IDE"

# IDE glue 类型快照（与 build_asm/pipeline_glue_types.inc 同源 extract；无 pipeline_gen.c 时用快照）
if [[ -f "$CDIR/pipeline_gen.c" ]]; then
  perl "$CDIR/scripts/extract_pipeline_glue_types.pl" "$CDIR/pipeline_gen.c" >"$INC"
  perl "$CDIR/scripts/patch_ide_glue_types.pl" "$INC"
  echo "gen_compile_commands: ide/pipeline_glue_types.inc <- pipeline_gen.c"
elif [[ -f "$SNAP" ]]; then
  perl "$CDIR/scripts/extract_pipeline_glue_types.pl" "$SNAP" >"$INC"
  perl "$CDIR/scripts/patch_ide_glue_types.pl" "$INC"
  echo "gen_compile_commands: ide/pipeline_glue_types.inc <- typeck_gen_full.c (snapshot + patch)"
else
  echo "gen_compile_commands: warn — no pipeline_gen.c or typeck_gen_full.c for ide types" >&2
fi

cd "$CDIR"

# wave941/965: Makefile physically deleted — bear+make capture is archaeology only.
# Prefer static seed DB below (no fake make graph). Escape: restore MF + bear.
if [[ -f Makefile ]] && command -v bear >/dev/null 2>&1; then
  echo "gen_compile_commands: bear capturing make compile commands (MF archaeology)…"
  rm -f "$OUT"
  bear -- make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)" \
    src/runtime_driver.o \
    src/runtime.o \
    src/parser/parser.o \
    src/lexer/lexer.o \
    src/ast/ast.o \
    src/lsp/lsp_diag.o \
    pipeline_bootstrap_orchestration.o \
    2>/dev/null || bear -- make src/runtime_driver.o src/parser/parser.o
  if [[ -f "$OUT" ]]; then
    echo "gen_compile_commands OK: $OUT (+ $INC)"
    exit 0
  fi
fi

echo "gen_compile_commands: writing static compile_commands.json (post_ship; no MF)…"
CC="${CC:-cc}"
python3 - "$CDIR" "$CC" "$OUT" <<'PY'
import json, os, sys

cdir, cc, out = sys.argv[1], sys.argv[2], sys.argv[3]
base = ["-x", "c", "-std=c11", "-Wall", "-Wextra", "-I.", "-Iinclude", "-Isrc", "-Iide"]
driver_flags = base + [
    "-DXLANG_USE_X_DRIVER", "-DXLANG_USE_X_PIPELINE", "-DXLANG_USE_X_PREPROCESS",
    "-DXLANG_USE_X_TYPECK", "-DXLANG_USE_X_CODEGEN",
]
# wave965: pipeline_glue.c / ast_pool.c left wave309 — do not list deleted
# paths in compile_commands (IDE fake authority; same debt as audit_static_limits).
# Live clangd surface = seeds below + ide/clangd_glued_preamble.h for types.
# PLATFORM: SHARED — static DB only when bear/make unavailable (MF deleted wave941).
entries = [
    # wave321 7.1.1: monofile seeds/runtime.from_x.c retired; content layer is gate.
    ("seeds/rt_content.from_x.c", driver_flags),
    ("seeds/rt_content.from_x.c", base),
    ("seeds/main.from_x.c", base),
    ("seeds/runtime_lexer_glue.from_x.c", base),
    ("seeds/runtime_ast_glue.from_x.c", base),
    ("seeds/runtime_lsp_glue.from_x.c", base),
    ("src/main_driver.c", driver_flags),
    ("src/runtime_driver.c", driver_flags),
    ("seeds/fmt_check_cmd.from_x.c", base),
    ("seeds/async_liveness.from_x.c", base),
    ("seeds/async_cps_codegen.from_x.c", base),
    # wave292: host wrapper deleted; product/clangd compile seed directly (ensure_one twin).
    ("seeds/pipeline_bootstrap_orchestration.from_x.c", base + [
        "-Ibuild_asm", "-DPIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER",
        "-include", "ide/clangd_glued_preamble.h",
    ]),
    ("seeds/pipeline_glue_standalone.from_x.c", base + [
        "-Ibuild_asm", "-Wno-unused-function",
        "-include", "ide/clangd_glued_preamble.h",
    ]),
]

seen = set()
db = []
for rel, flags in entries:
    if rel in seen:
        continue
    seen.add(rel)
    abspath = os.path.join(cdir, rel)
    obj = rel.replace("/", "_").replace(".c", ".o")
    cmd = " ".join([cc] + flags + ["-c", "-o", obj, rel])
    db.append({"directory": cdir, "command": cmd, "file": abspath})

with open(out, "w", encoding="utf-8") as f:
    json.dump(db, f, indent=2)
    f.write("\n")
print(f"Wrote {len(db)} entries -> {out}")
PY

echo "gen_compile_commands OK: $OUT (+ $INC)"
