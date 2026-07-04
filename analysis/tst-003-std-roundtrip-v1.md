# TST-003 std round-trip 向量库 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：STD-035（json）、STD-036（csv）、STD-007（compress）、STBL-003

---

## 1. 目标

| ID | 交付 |
|----|------|
| TST-003 | 共享 round-trip 向量注册表 + 统一 gate |
| 验收 | `tests/baseline/std-roundtrip.tsv` 覆盖 **base64 / json / csv / compress** |

---

## 2. 注册表

`tests/baseline/std-roundtrip.tsv` 列：

| 列 | 含义 |
|----|------|
| `module` | `std.*` 模块 |
| `test_path` | 金样 `.x` |
| `needs_o` | 链接用 C `.o`（`-` 表示纯 .x） |

---

## 3. v1 向量

| 模块 | 烟测 | 说明 |
|------|------|------|
| `std.base64` | `tests/boundary/base64_roundtrip.x` | `../std/base64/base64.o` |
| `std.json` | `tests/json/object_array_roundtrip.x` | object/array 序列化往返 |
| `std.csv` | `tests/csv/row_roundtrip.x` | `parse_row`/`write_row` |
| `std.compress` | `tests/std-compress/gzip_roundtrip.x` | gzip；无 zlib 时 **SKIP 语义**（exit 0） |

后续波次可追加 `zstd_roundtrip`、url base64 等行，不破坏 v1 gate。

---

## 4. Gate

```bash
./tests/run-tst-003-std-roundtrip-gate.sh
```

```
shux: [SHUX_TST003_ROUNDTRIP] status=ok vectors=4 pass=4 skip=0
```

便携回归：`tests/run-portable-suite.sh`

---

## 5. 维护

新增 round-trip 金样时：

1. 在 `std-roundtrip.tsv` 增加 `roundtrip` 行  
2. 确保模块专属 gate 仍绿  
3. 更新本文 §3 表
