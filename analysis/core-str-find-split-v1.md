# STD-131：core.str BytesView 查找/分割 v1

> 状态：**定版（v1，零拷贝子视图）**

## API

| 名称 | 说明 |
|------|------|
| `bytes_view_index_of_byte` | 单字节查找 |
| `bytes_view_index_of` | 子串查找 |
| `bytes_view_contains_byte` | 是否含某字节 |

分割模式：`index = bytes_view_index_of_byte(v, sep)` 后配合 `bytes_view_subview`。
| `bytes_view_starts_with` | 前缀匹配 |

## 门禁

`./tests/run-core-str-find-split-gate.sh`
