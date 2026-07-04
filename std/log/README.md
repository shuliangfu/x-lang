# std.log — 日志级别与 stderr/文件

**路径**：`std/log/`（mod.x + log.x + runtime_log_os.o）  
**依赖**：core。**性能**：零分配，单次 write。

| API | 说明 |
|-----|------|
| `set_min_level(level): void` | 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR |
| `log(level, ptr, len): i32` | 写 "[LEVEL] " + 消息 + 换行到活跃 sink |
| `structured_kv(comp, level, kv): i32` | OBS-003 结构化行 `shux: level=… component=…` |
| `set_sink_mask(mask): void` | SINK_STDERR \| SINK_FILE |
| `set_file_sink(path, len): i32` | 打开追加写文件 sink |
| `level_debug/info/warn/error(): i32` | 返回级别常量 |
