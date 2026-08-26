# 阶段 F-uuid v1（std.uuid 去 C）

> **F-uuid v1**：删除 **`uuid.c`**；v4/v7/parse/format 全在 **`uuid.x`**；仍链 **random.o + time.o**（extern）。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `uuid.c` + extern | `uuid.x` |
| `uuid.o` | `cc -c uuid.c` | `xlang -backend asm uuid.x` |
| 存量 | std 90 `.c` | std **89** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/uuid/uuid.c`~~ | v1 删除 |

## 保留依赖

| 模块 | 原因 |
|------|------|
| `std/random/random.x` + `runtime_random_fill.c` | CSPRNG `random_fill_bytes_c` |
| `std/time/time.x` + `runtime_time_os.c` | 墙钟 `time_now_wall_ms_c` |

## 构建

```bash
./xbuild  # was: make -C compiler ../std/uuid/uuid.o
```

## Gate

Honesty (2026-08-27): hard-fail static＋ensure＋STD-075 manifest; prefer asm; pin `XLANG_LINK_XLANG`. Soft `XLANG_F_UUID_V1_FAIL` retired. Full uuid product smoke observational (asm UNDEF residual).

```bash
XLANG=./compiler/xlang_asm ./tests/run-f-uuid-v1-gate.sh
XLANG_STD_UUID_MANIFEST_ONLY=1 ./tests/run-std-uuid-gate.sh
```

## 下一项

- **uuid 产品 UNDEF**：full STD-075 smoke 仍观测
- **random/time 去 C**：解除 uuid 对 C 的间接依赖（已部分完成）
