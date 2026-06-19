# STD-129：std.set Set_i32 高阶集合操作 v1

> 状态：**定版（v1，union / intersect / difference）**

## API

| 名称 | 说明 |
|------|------|
| `set_i32_union_into` | dst = a ∪ b |
| `set_i32_intersect_into` | dst = a ∩ b |
| `set_i32_difference_into` | dst = a \\ b |
| `set_i32_insert_all_from` | 将 src 全部元素插入 dst（内部辅助） |

## 门禁

`./tests/run-std-set-ops-gate.sh`
