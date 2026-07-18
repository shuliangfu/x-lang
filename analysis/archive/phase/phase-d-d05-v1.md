# 阶段 D-05 完成标准 v1（NEXT §7）

> **D-05 v1**：日常发布/开发以 **`compiler/shux`**（B-strict `shux_asm` 覆盖）为**单一编译器入口**；**不**要求用户日常调用 `shux-c` 冷启动。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| 发布入口 | `make bootstrap-driver-bstrict` → `cp shux_asm $(TARGET)` | `run-d05-single-shux-release-gate.sh` |
| 能力 | `shux` 支持 `-backend asm` / `--lsp`（seed 链后） | 同上烟测 |
| 日常 compile | `SHUX=./compiler/shux check …` **不**设 `SHUX_LINK_SHUX=shux-c` | 同上（x86_64 native） |
| 文档 | README / SELFHOST / bootstrap.sh 区分「日常 shux」与「考古 shux-c」 | 同上 manifest |

## 复现

```bash
make -C compiler bootstrap-driver-bstrict   # shux ← shux_asm
SHUX_D05_FAIL=1 ./tests/run-d05-single-shux-release-gate.sh
SHUX=./compiler/shux ./tests/run-hello.sh
```

## track-only（不阻塞 v1 ✅）

| 项 | 说明 |
|----|------|
| **首次克隆** | 仍须 `bootstrap.sh` / `make all` 产出 seed（含 `shux-c`） |
| **MSYS2 / 非 x86_64** | `-o` 链接仍可能 `SHUX_LINK_SHUX=shux-c`（与 run-hello 一致） |
| **删除 shux-c 文件** | v2；v1 仅「日常不依赖」 |

## 延后（D-05 v2）

- 仓库发布包仅含 `shux`（无 `shux-c` 二进制）
- CI 默认不构建 / 不安装 `shux-c`
