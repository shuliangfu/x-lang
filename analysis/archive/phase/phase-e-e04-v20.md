# 阶段 E-04 v20（Darwin crt0 替代 main_driver.o）

> **E-04 v20**：Darwin **arm64 / x86_64** bootstrap 默认 **`crt0_arm64.o` / `crt0_darwin_x86_64.o`** + **`MAIN_LINK_FLAGS=-e _start -nostartfiles`**；与 v19 Linux crt0 对称；Windows 仍 main_driver.o。

## v20 完成（✅）

| 项 | 说明 |
|------|------|
| `crt0_arm64.s` | Darwin arm64 Mach-O `_start` → `main_entry` + `driver_get_argv_i` |
| `crt0_darwin_x86_64.s` | Darwin x86_64 同上 |
| `MAIN_LINK_FLAGS` | Darwin crt0 链接 `-e _start -nostartfiles` |
| `main.c` | 文件保留；仅 Windows / LEGACY / 无 crt0 平台链入 |

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
# Darwin arm64 / x86_64：
make -C compiler relink-shux
./compiler/shux --version 2>/dev/null || ./compiler/shux -h 2>&1 | head -1
# 考古 C main()：
SHUX_LEGACY_MAIN_C=1 make -C compiler relink-shux
```

## 延后（E-04 v21+）

- 见 `analysis/phase-e-e04-v21.md`（v21 MinGW/Windows crt0_mingw 替代 main_driver.o）
