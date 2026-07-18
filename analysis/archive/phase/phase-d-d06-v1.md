# 阶段 D-06 完成标准 v1（NEXT §7）

> **D-06 v1**：`SELFHOST.md` / `README.md` 声明 **Stage2 黄金自举**（D-03 SHA256 + D-04 扩面）及 **可复现命令**；**不含**最终「完全自举」（须 D+E+F）。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| 术语分层 | §1 区分语义自举 / 阶段 D 黄金 / 完全自举（D+E+F） | `run-d06-selfhost-doc-gate.sh` |
| 复现命令 | Stage2 bstrict + SHA256 STRICT + Docker 全链 | `SELFHOST.md` §2 |
| README 对齐 | 自举状态表 Stage2 哈希 ✅ | 同上 |
| 登记 | `bootstrap-repro.tsv` | portable / CI |

## 黄金自举复现（Linux x86_64 金标准）

```bash
# 一键 Docker（A-09 + A-10 + A-11 + A-12 + Stage2）
./tests/run-linux-a09-a11-gate.sh

# 或分步
make -C compiler bootstrap-driver-seed
make -C compiler bootstrap-driver-bstrict
make -C compiler bootstrap-verify-stage2-bstrict   # 行为 + Step 4c 默认 STRICT 哈希
SHUX_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh
SHUX_D04_FAIL=1 ./tests/run-d04-stage2-portable-diff-gate.sh
```

## 与 D-03 / D-04 / D-05 关系

| 项 | 说明 |
|----|------|
| **D-03** | 二进制 SHA256 金标准（文档引用 gate 命令） |
| **D-04** | portable 子集两代 diff（文档引用 gate 命令） |
| **D-05** | 发布单 `shux` 日常入口（`run-d05-single-shux-release-gate.sh`） | **v1 ✅** |

## 延后（D-06 v2）

- README 根目录「完全自举」口径与 E/F 阶段同步更新
- 多平台（Windows/Alpine）黄金自举复现矩阵
