# 阶段 D-05 完成标准 v1（NEXT §7）

> **D-05 v1**：日常发布/开发以 **`compiler/xlang`**（B-strict `xlang_asm` 覆盖）为**单一编译器入口**；**不**要求用户日常调用 `xlang-c` 冷启动。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| 发布入口 | `make bootstrap-driver-bstrict` → `cp xlang_asm $(TARGET)` | `run-d05-single-xlang-release-gate.sh` |
| 能力 | `xlang` 支持 `-backend asm` / `--lsp`（seed 链后） | 同上烟测 |
| 日常 compile | `XLANG=./compiler/xlang check …` **不**设 `XLANG_LINK_XLANG=xlang-c` | 同上（x86_64 native） |
| 文档 | README / SELFHOST / bootstrap.sh 区分「日常 xlang」与「考古 xlang-c」 | 同上 manifest |

## 复现

```bash
make -C compiler bootstrap-driver-bstrict   # xlang ← xlang_asm
XLANG_D05_FAIL=1 ./tests/run-d05-single-xlang-release-gate.sh
XLANG=./compiler/xlang ./tests/run-hello.sh
```

## track-only（不阻塞 v1 ✅）

| 项 | 说明 |
|----|------|
| **首次克隆** | 仍须 `bootstrap.sh` / `make all` 产出 seed（含 `xlang-c`） |
| **MSYS2 / 非 x86_64** | `-o` 链接仍可能 `XLANG_LINK_XLANG=xlang-c`（与 run-hello 一致） |
| **删除 xlang-c 文件** | v2；v1 仅「日常不依赖」 |

## 延后（D-05 v2）

- 仓库发布包仅含 `xlang`（无 `xlang-c` 二进制）
- CI 默认不构建 / 不安装 `xlang-c`
