# STD-141：docs/07 + Cookbook Phase 2 同步 v1

> 状态：**定版（v1）**  
> 关联：`DOC-006`、`DOC-007`、`STD-131`～`STD-140`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-141 | `docs/07` 补 Phase 2 增量表；Cookbook +4 食谱（40 条）；gate |

---

## 2. docs/07 增量（STD-131～140）

| STD | 模块 | 要点 |
|-----|------|------|
| 131 | `core.str` | `bytes_view_index_of*` / `starts_with` |
| 132 | `std.env` | 平台编码 smoke |
| 133 | `std.time` | `Timer` + `timer_elapsed_*` / `timer_lap_ns` |
| 134 | `std.url` | IPv6 `host_to_ipv6` / `format_ipv6_host` |
| 135 | `std.datetime` | `TimeZone` + zoned 字段 |
| 136 | — | `std-api.tsv` 60 模块 gate |
| 137 | `std.time` | `format_wall_rfc3339` / `wall_local_offset_min` |
| 138 | — | 三平台深度边界 gate |
| 139 | `std.codec` | `encode_into_bytes` 缓冲复用 / 零拷贝策略 |
| 140 | `std.path` | 极端 `path_clean` 向量 |

---

## 3. Cookbook 新增（§14）

| ID | 路径 |
|----|------|
| CSTR-01 | `examples/cookbook/core_str_index.sx` |
| TIME-02 | `examples/cookbook/time_timer_elapsed.sx` |
| TIME-03 | `examples/cookbook/time_rfc3339_format.sx` |
| PATH-02 | `examples/cookbook/path_clean_extreme.sx` |

---

## 4. Gate

```bash
./tests/run-doc-07-phase2-sync-gate.sh
```

报告：`shux: [SHUX_STD141_DOC07_PHASE2_SYNC]`
