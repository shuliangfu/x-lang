# STD-156 std.context Cookbook 扩展示例 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-156、`STD-071`、`STD-091`～`STD-095`

---

## 1. 目标

为 `std.context` 提供 **Cookbook 可运行示例**，与 io/net/http/async 的 Context 集成 gate 互补，面向「如何写取消/超时/元数据传播」场景。

| ID | 交付 |
|----|------|
| CTX-01 | `examples/cookbook/context_cancel_deadline.x` |
| STD-156 | manifest + `run-std-context-cookbook-gate.sh` |

---

## 2. 食谱 CTX-01

路径：`examples/cookbook/context_cancel_deadline.x`

覆盖 API：

- `background` / `with_cancel` / `with_timeout`
- `cancel` / `is_cancelled` / `remaining_ns`
- `set_value` / `get_value` / `free`

与模块 gate 关系：

- `run-std-context-gate.sh`（STD-071）保留 C 烟测 + `tests/std-context/cancel_smoke.x`
- 本 gate 校验 Cookbook 食谱存在、归档文档引用与 **asm 产品路径 runnable**（check 仅观测）

---

## 3. manifest

- `tests/baseline/std-context-cookbook.tsv`
- Cookbook 索引：`analysis/archive/doc/doc-cookbook-expand-v1.md` §15（CTX-01）

---

## 4. 验收

- 门禁：`tests/run-std-context-cookbook-gate.sh`
- 报告：`status=ok check=… run=1 skip=0`（prefer `xlang_asm`；无 soft SKIP；拒顶层 DOC 复活）
- 2026-08-25 honesty：假权威（偏 xlang-c／硬 check／无二进制 soft SKIP／顶层 expand DOC）→硬绿
