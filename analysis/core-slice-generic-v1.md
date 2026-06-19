# CORE-157 切片泛型工具扩展 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-157、`CORE-004`

---

## 1. 目标

在 CORE-004 `[]i32` / `[]u8` 基础上扩展：

| 族 | 新增 API |
|----|----------|
| `[]i32` / `[]u8` | `is_empty_*` / `first_*` / `last_*` |
| `[]u64` | `len/get/is_empty/first/last`（subslice 待 typeck `.data` 扩展） |
| `core.option` | `Option_u64`（供 `get_u64`） |

---

## 2. manifest

- 扩展：`tests/baseline/core-slice-api.tsv`
- 烟测：`tests/slice/subslice_split_chunks.sx`（含 u64 + 工具段）
- 门禁：`tests/run-core-slice-api-gate.sh`（CORE-004/157 共用）

---

## 3. 验收

- typeck + runnable：`subslice_split_chunks.sx` exit 0
- 报告：`shux: [SHUX_CORE_SLICE_API] status=ok`
