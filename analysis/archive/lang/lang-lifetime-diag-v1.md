# LANG-008 生命周期错误信息友好化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `lsp_diag_report_typeck`、`tests/run-typeck-region.sh` 对齐  
> 关联：`TYPE-002`（region 检查）、`EXC-005`（CLI/LSP 错误显示）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 诊断层 E1–E6 |
| 2 | 打开 `tests/baseline/lang-lifetime-diag-cases.tsv` |
| 3 | `./tests/run-lang-lifetime-diag-gate.sh` |
| 4 | `shux check tests/typeck/slice_lifetime/region_assign_escape.x` |

---

## 2. 诊断层 E1–E6（lifetime friendly diagnostic）

权威：`tests/baseline/lang-lifetime-diag.tsv`（**6** 条 `layer_*`）。

| 层级 | 能力 | 实现 | v1 |
|------|------|------|-----|
| **E1-format** | CLI 行：`typeck error: <msg> at <line>:<col>` | `lsp_diag_report_typeck` | ✅ |
| **E2-escape-assign** | 赋值逃逸带站点行号 | `typeck_check_slice_region_assign` | ✅ |
| **E3-mismatch** | 域冲突含 expected/found `<label>` | `slice region mismatch` | ✅ |
| **E4-return-escape** | `return` 路径独立措辞 + 行号 | `typeck_check_return_slice_region` | ✅ |
| **E5-call-site** | 调用实参域错误定位到 call 表达式 | call 路径 `TYPECK_ERR` | ✅ |
| **E6-lsp-bridge** | LSP 模式写入 `lsp_diag_add(line,col)` | `lsp_diag_enabled` | ✅ |

**friendly 原则**：

1. **source 行号**：凡有 `ASTExpr` 站点的 region 错误须 `at line:col`，禁止仅 `TYPECK_ERR_AT(0,0)`。
2. **可读文案**：消息含 `slice region escape` / `slice region mismatch` 与域标签 `<ra>` 等。
3. **LSP 一致**：CLI 与 LSP 收集共用 `lsp_diag_report_typeck` 格式化。

示例（`region_assign_escape.x` 第 8 行）：

```text
typeck error: slice region escape: cannot assign <ra> slice to unbound T[] at 8:5
```

---

## 3. 诊断用例矩阵

`tests/baseline/lang-lifetime-diag-cases.tsv`：**4** 条负例须命中子串 **且** `at <line>:<col>`。

| case_id | 文件 | 子串 | 期望行 |
|---------|------|------|--------|
| `diag_escape_assign` | `region_assign_escape.x` | `slice region escape` | **8** |
| `diag_mismatch` | `region_mismatch.x` | `slice region mismatch` | **6** |
| `diag_return_escape` | `region_return_escape.x` | `slice region escape` | **7** |
| `diag_call_escape` | `region_call_escape.x` | `slice region escape` | **8** |

正例回归仍由 `tests/run-typeck-region.sh`（12 case）覆盖。

---

## 4. 非目标（v1）

- 二级「建议修复」hint（如「将 leaked 移入 region 块内」）
- 借用冲突（`TYPE-003`）诊断改写
- 多诊断排序 / 相关错误聚合

---

## 5. 验证与门禁

```bash
./tests/run-lang-lifetime-diag-gate.sh   # runnable：manifest + lifetime diag hooks
./tests/run-lang-lifetime-diag.sh        # 行号定位烟测
./tests/run-typeck-region.sh             # region 全矩阵
```

**gate report**：stdout 须含 `lang-lifetime-diag gate OK`；失败打印 `lang-lifetime-diag FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/lang-lifetime-diag-v1.md` |
| manifest | `tests/baseline/lang-lifetime-diag.tsv` |
| 矩阵 | `tests/baseline/lang-lifetime-diag-cases.tsv` |
| region RFC | `analysis/type-region-v1-rfc.md` |

**LANG-008 状态：定版 ✅**
