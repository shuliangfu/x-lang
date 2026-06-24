# 阶段 F-uuid v1（std.uuid 去 C）

> **F-uuid v1**：删除 **`uuid.c`**；v4/v7/parse/format 全在 **`uuid.sx`**；仍链 **random.o + time.o**（extern）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `uuid.c` + extern | `uuid.sx` |
| `uuid.o` | `cc -c uuid.c` | `shux -backend asm uuid.sx` |
| 存量 | std 90 `.c` | std **89** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/uuid/uuid.c`~~ | v1 删除 |

## 保留依赖

| 模块 | 原因 |
|------|------|
| `std/random/random.sx` + `runtime_random_fill.c` | CSPRNG `random_fill_bytes_c` |
| `std/time/time.sx` + `runtime_time_os.c` | 墙钟 `time_now_wall_ms_c` |

## 构建

```bash
make -C compiler ../std/uuid/uuid.o   # 自动先链 random.o + time.o
```

## 门禁

```bash
SHUX_F_UUID_V1_FAIL=1 ./tests/run-f-uuid-v1-gate.sh
./tests/run-std-uuid-gate.sh
```

## 下一项

- **F-process v1**：`process.c` → `.sx` + OS FFI 胶层
- **random/time 去 C**：解除 uuid 对 C 的间接依赖
