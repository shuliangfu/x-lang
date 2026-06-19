# STD-053：std.log 多 sink 与级别过滤 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：OBS-003（结构化行格式）、`std/log/log.c`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4（Cookbook） |
| 2 | `tests/baseline/std-log-multi-sink.tsv` |
| 3 | `./tests/run-std-log-multi-sink-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `set_min_level(level)` | 全局过滤：仅 `level >= min` 写出 |
| `set_sink_mask(mask)` | `SINK_STDERR`(1) \| `SINK_FILE`(2) |
| `set_file_sink(path, len)` | 打开追加写文件 sink |
| `close_file_sink()` | 关闭文件 sink |
| `log` / `log_structured_kv` | 写入所有活跃 sink |

环境变量 **`SHUX_LOG_MIN_LEVEL`**（0–3）在首次写日志时惰性应用，与 `set_min_level` 一致。

---

## 3. Cookbook（结构化日志）

### 3.1 仅 stderr（默认）

```su
import("std.log");
set_min_level(level_info());
let msg: [5]u8 = [104, 101, 108, 108, 111];
log(level_info(), &msg[0], 5);
```

### 3.2 stderr + 文件双写

```su
import("std.log");
let path: [20]u8 = [47, 116, 109, 112, 47, 97, 112, 112, 46, 108, 111, 103, 0, 0, 0, 0, 0, 0, 0, 0];
set_file_sink(&path[0], 12);
set_sink_mask(1 | 2);
log(level_warn(), &msg[0], 3);
close_file_sink();
```

### 3.3 结构化行（机器聚合）

```su
let kv: [24]u8 = [101, 118, 101, 110, 116, 61, 115, 116, 97, 114, 116, 32, 117, 115, 61, 49, 50, 51, 0, 0, 0, 0, 0, 0];
log_structured_kv(&comp[0], level_info(), &kv[0]);
```

输出：`shux: level=info component=… event=start us=123`（见 OBS-003）。

### 3.4 级别过滤

```su
set_min_level(level_warn());
log(level_info(), &msg[0], 4);
```

INFO 被丢弃（返回 0、无输出）。烟测金样：`filtered` 在 `min=WARN` 时不落盘。

---

## 4. 金样向量

| ID | 期望 |
|----|------|
| `human_file` | 文件含 `[INFO] sink_ok` |
| `structured_file` | 文件含 `shux: level=info component=std_log_smoke` |
| `level_filter` | `min=WARN` 时 INFO `filtered` 不出现 |

---

## 5. 门禁

```bash
./tests/run-std-log-multi-sink-gate.sh
```

```
shux: [SHUX_STD_LOG_MULTI_SINK] status=ok c_smoke=1 su=1 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | 多 sink + SHUX_LOG_MIN_LEVEL + Cookbook |
