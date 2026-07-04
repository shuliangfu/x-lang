# STD-075 std.uuid v1

> 更新时间：2026-06-18  
> 状态：**可用** — v4/v7 + parse/format + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-uuid-manifest.tsv` |
| 3 | `./tests/run-std-uuid-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `Uuid` | 128-bit 字节布局 `u8[16]` |
| `new_v4` | CSPRNG 随机 UUID |
| `new_v7` | Unix 毫秒时间有序 UUID（RFC 9562；同毫秒内 12-bit 序号递增保证单调） |
| `parse` / `format` | 连字符/纯 hex、大小写不敏感 |
| `eq` / `version` | 比较与版本 nibble |
| `as_bytes` | 16 字节指针视图 |

实现：`std/uuid/mod.x` + `std/uuid/uuid.c`；v4 依赖 `std.random`，v7 依赖 `std.time` 墙钟毫秒。

---

## 3. Gate

```
shux: [SHUX_STD_UUID] status=ok c_smoke=1 x=1 skip=0
std-uuid gate OK
```

向量：`tests/baseline/std-uuid-vectors.tsv`。
