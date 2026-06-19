# STBL-003 模块变更 RFC 模板 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STBL-001（Tier-S manifest）、STBL-002（README 同步）、STD-011（错误码）

---

## 1. 目标

| ID | 交付 |
|----|------|
| STBL-003 | 统一 std/core 模块变更 RFC 模板（**API / ABI / ZC / 错误码**） |
| 验收 | `analysis/std-change-rfc-template.md` 存在且 gate 校验必填 § |

**模板路径**：`analysis/std-change-rfc-template.md`（复制后重命名为 `analysis/<topic>-v1.md`）

---

## 2. 必填章节

| § | 标签 | 用途 |
|---|------|------|
| 0 | 元数据 | 模块 ID、任务 ID、manifest、gate |
| 2 | API | Tier-S 符号与签名 |
| 3 | ABI | `.o` 链接、extern、runtime |
| 4 | ZC | 零拷贝 / 生命周期；无则 N/A |
| 5 | 错误码 | Layer A/B/C、STD-011 对齐 |
| 6 | 测试 | 烟测、manifest、gate |
| 7 | 文档 | README / NEXT / portable-suite |

---

## 3. 使用流程

1. `cp analysis/std-change-rfc-template.md analysis/std-foo-v1.md`
2. 填写 §0–§8；删除附录 A
3. 实现代码 + manifest + gate + 烟测
4. 更新 `NEXT.md` 与 `tests/run-portable-suite.sh`
5. `./tests/run-stbl-003-change-rfc-template-gate.sh`（模板完整性）+ 模块专属 gate

---

## 4. Gate

```bash
./tests/run-stbl-003-change-rfc-template-gate.sh
```

manifest：`tests/baseline/stbl-change-rfc-template.tsv`

```
shux: [SHUX_STBL_CHANGE_RFC] status=ok sections=7
```

---

## 5. 参考 RFC（已按模板精神编写）

| 维度 | 示例 |
|------|------|
| API + 测试 | `analysis/std-csv-row-v1.md` |
| ZC | `analysis/std-json-zc-v1.md` |
| 错误码 | `analysis/std-error-unify-v1.md` |
| ABI | `analysis/boot-std-link-contract-v1.md` |
