# 阶段 D-03 完成标准 v1（NEXT §7）

> **D-03 v1**：Stage1（`xlang_asm_stage1`）与 Stage2（`xlang_asm2`）**可执行文件 SHA256 一致**——完全自举的**二进制金标准**（与行为 parity 正交）。

## v1 完成（✅）

> **Honesty 2026-08-24 #12 / 2026-08-27:** top-level DOC + soft `XLANG_D03_FAIL` retired (early Darwin "OOM" soft exit0 skipped DOC/manifest = portable false-green). Live = this archive path + `## Gate` + `run-stage2-hash-gate` when stage bins exist.

| 项 | 标准 | Gate |
|----|------|------|
| 哈希比对 | `sha256(stage1) == sha256(stage2)` | `run-stage2-hash-gate.sh` + `XLANG_STAGE2_HASH_STRICT=1` |
| verify 接入 | `verify-selfhost-stage2-bstrict.sh` Step 4c 调用 hash gate | 同上（默认 STRICT） |
| D-03 聚合 | 文档 + manifest + 委托 A-09 | `run-d03-stage2-hash-gate.sh` |
| Docker 复现 | Linux x86_64 全链 build → hash 一致 | `run-linux-a09-a11-gate.sh` Step A-09 |
| 登记 | `bootstrap-repro.tsv` `stage2_hash` 行 | portable / bstrict CI |

## Gate

```bash
./tests/run-d03-stage2-hash-gate.sh
# Optional (bins must exist for live hash):
#   XLANG_STAGE2_HASH_STRICT=1 ./tests/run-stage2-hash-gate.sh compiler/xlang_asm_stage1 compiler/xlang_asm2
# Report: doc=/static=/hash=/skip=
# Soft XLANG_D03_FAIL + early Darwin OOM soft-exit retired (die always hard).
# Missing stage bins after static → honest skip=1 (not soft die on missing DOC).
```

PLATFORM: SHARED archaeology (SHA256 works on Mach-O + ELF).

## 与 A-09 / A-14 关系

- **A-09**：门禁语义与 Docker 验收（2026-06-20 已绿）
- **A-14**：脚本化落地（`run-stage2-hash-gate.sh`）
- **D-03**：阶段 D 正式闭合项；v1 不重复实现，**委托 A-09 gate**

## track-only / 平台

| 项 | 说明 |
|----|------|
| 无 stage 产物 | static 硬审计后 skip=1（须先跑 verify-selfhost-stage2-bstrict） |
| 行为 ≠ 哈希 | `verify-selfhost` 42/hello/struct_mk 通过 **不** 蕴含 SHA256 一致 |

## 延后（D-03 v2+ / D-04+）

- **D-04 v2**：全量 `run-portable-suite.sh` / `make test_x` 两代 diff
- **D-05**：发布单 `xlang` 不依赖 `xlang-c` 冷启动
- **D-06**：`SELFHOST.md` 黄金自举声明与复现命令同步
