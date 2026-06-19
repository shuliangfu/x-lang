#!/usr/bin/env python3
"""
Shux 硬切迁移：在全仓库文本中按序替换旧品牌/后缀/宏名。
禁止兼容：不保留 shu/shulang/.sx/SHU_ 任何路径。
"""
from __future__ import annotations

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SKIP_DIRS = {
    ".git",
    "node_modules",
    ".cursor",
    "__pycache__",
}

# 仅跳过已打包 vsix（二进制）；其余文本全改
SKIP_SUFFIX = {
    ".vsix",
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".o",
    ".a",
    ".so",
    ".dylib",
    ".exe",
    ".wasm",
    ".zip",
    ".tar",
    ".gz",
    ".br",
    ".lock",  # package-lock 内 npm 包名可能误伤，单独处理 json
}

# 有序替换：长模式优先，避免 shu_asm 被 \bshu\b 截断
REPLACEMENTS: list[tuple[str, str]] = [
    ("SHU_USE_SU_", "SHUX_USE_SX_"),
    ("SHULANG_RUN_ALL_BOOTSTRAP_SHU", "SHUX_RUN_ALL_BOOTSTRAP_SHUX"),
    ("SHULANG_LSP_LIB_ROOTS", "SHUX_LSP_LIB_ROOTS"),
    ("SHULANG_", "SHUX_"),
    ("shulang_", "shux_"),
    ("shu_asm2", "shux_asm2"),
    ("shu_asm", "shux_asm"),
    ("shu-su2", "shux-sx2"),
    ("shu-su", "shux-sx"),
    ("shu-c", "shux-c"),
    ("bootstrap_shu", "bootstrap_shux"),
    ("build_shu_asm", "build_shux_asm"),
    ("relink_shu_asm", "relink_shux_asm"),
    ("run_shu_asm", "run_shux_asm"),
    ("bootstrap_shu_create", "bootstrap_shux_create"),
    ("parser_sx.o", "parser_sx.o"),
    ("main_sx.o", "main_sx.o"),
    ("runtime_sx.o", "runtime_sx.o"),
    ("preprocess_for_driver", "preprocess_for_driver"),  # noop anchor
    ("su-pipeline", "sx-pipeline"),
    ("su_bridge", "sx_bridge"),
    ("su_seed_bridge", "sx_seed_bridge"),
    ("su_stubs", "sx_stubs"),
    ("lexer_su_link", "lexer_sx_link"),
    ("vscode-shulang", "vscode-shux"),
    ("shulang-icon-theme", "shux-icon-theme"),
    ("Shulang Language", "Shux Language"),
    ("Shulang", "Shux"),
    ("shulang", "shux"),
    ("source.sx", "source.sx"),
    ("su.tmLanguage.json", "sx.tmLanguage.json"),
    ("shuPath.ts", "shuxPath.ts"),
    ("shu.pkg", "shux.pkg"),
    ("shu-link-env", "shux-link-env"),
    ("bootstrap-shu", "bootstrap-shux"),
    ("boot-027-shu-asm2", "boot-027-shux-asm2"),
    ("boot-028-shu-asm2", "boot-028-shux-asm2"),
    ("shu-asm2", "shux-asm2"),
    ("run-shu-asm", "run-shux-asm"),
    ("run-size-shu-asm", "run-size-shux-asm"),
    ("run-refresh-shu-asm", "run-refresh-shux-asm"),
    ("SU与C流水线", "SX与C流水线"),
    ("SHU_SU", "SHUX_SX"),
    ("SHU_C", "SHUX_C"),
    ('"-su"', '"-sx"'),
    ("'-su'", "'-sx'"),
    ("-su ", "-sx "),
    ("-su\n", "-sx\n"),
    ("-su\t", "-sx\t"),
    (".sx.bak", ".sx.bak"),
    ("tmp_*.sx", "tmp_*.sx"),
    ("*.sx", "*.sx"),
    ("/mod.sx", "/mod.sx"),
    ("mod.sx", "mod.sx"),
    ("build.sx", "build.sx"),
    (".sx\"", ".sx\""),
    (".sx'", ".sx'"),
    (".sx)", ".sx)"),
    (".sx,", ".sx,"),
    (".sx ", ".sx "),
    (".sx\n", ".sx\n"),
    (".sx\t", ".sx\t"),
    (".sx/", ".sx/"),
    (".sx`", ".sx`"),
    ("compiler/shu", "compiler/shux"),
    ("./shu", "./shux"),
    # 禁止 ("/shu","/shux")：会级联命中 /shux → /shux
    (" SHUX=", " SHUX="),
    ("${SHUX}", "${SHUX}"),
    ("${SHUX:", "${SHUX:"),
    ("$SHU", "$SHUX"),
    ("SHU_", "SHUX_"),
    (" TARGET=shu", " TARGET=shux"),
    ("= shu\n", "= shux\n"),
    ("=shu\n", "=shux\n"),
    ("`shu ", "`shux "),
    (" shu ", " shux "),
    (" shu\n", " shux\n"),
    ("# shu", "# shux"),
    ("> shu", "> shux"),
    ("| shu", "| shux"),
    ("$(shu)", "$(shux)"),
    ("./$(TARGET)" , "./$(TARGET)"),  # noop
]

# 整词 shu → shux（放最后）
RE_SHU_WORD = re.compile(r"\bshu\b")


def should_skip(path: str) -> bool:
    parts = path.split(os.sep)
    for p in parts:
        if p in SKIP_DIRS:
            return True
    ext = os.path.splitext(path)[1].lower()
    if ext in SKIP_SUFFIX:
        return True
    if path.endswith("tools/shux_migrate_replace.py"):
        return True
    if path.endswith("package-lock.json"):
        return True
    return False


def transform(text: str) -> str:
    for old, new in REPLACEMENTS:
        if old == new:
            continue
        text = text.replace(old, new)
    text = RE_SHU_WORD.sub("shux", text)
    return text


def main() -> int:
    dry = "--dry-run" in sys.argv
    changed = 0
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            path = os.path.join(dirpath, fn)
            rel = os.path.relpath(path, ROOT)
            if should_skip(rel):
                continue
            try:
                with open(path, "r", encoding="utf-8", errors="strict") as f:
                    orig = f.read()
            except (UnicodeDecodeError, OSError):
                continue
            new = transform(orig)
            if new != orig:
                changed += 1
                if not dry:
                    with open(path, "w", encoding="utf-8", newline="") as f:
                        f.write(new)
                print(rel)
    print(f"{'would change' if dry else 'changed'} {changed} files", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
