# STD-129：std.set Set_i32 高阶集合操作 v1

> 状态：**定版（v1，union / intersect / difference）**
> 2026-08-25：API 名对齐产品 overload（`union_into` / `intersect_into` /
> `difference_into`）；闸门诚实化（prefer asm、check 观测、runnable 硬失败）。

## API

| 名称 | 说明 |
|------|------|
| `union_into` | dst = a ∪ b（`Set_i32` overload） |
| `intersect_into` | dst = a ∩ b（`Set_i32` overload） |
| `difference_into` | dst = a \\ b（`Set_i32` overload） |

产品面在 `std/set/mod.x`；烟测 `tests/set/ops.x` 用 `contains_key`／`length`
断言（避免 by-value `Set_i32` + 栈数组 `&i32[N]` 辅助的已知 SIGSEGV 残债）。

## 门禁

`./tests/run-std-set-ops-gate.sh`
