# 阶段 F-random v1（std.random 去 C）

> **F-random v1 / F-ZC**：删除 **`random.c`**；锚点 **`random.x`**（纯 .x → **`random.o`**）；CSPRNG OS fill 在 **`runtime_random_fill.c`**（compiler runtime）。

## 变更

| 项 | 旧 | 现 |
|----|----|-----|
| PRNG / u32/u64 | `random.c` | **`random.x`** |
| OS CSPRNG | `random_os_glue.c` | **`runtime_random_fill.c`**（已迁出 std/） |
| `random.o` | ld -r glue + .x | **纯 `.x`** |

## 符号

- `random_fill_bytes_c` — compiler runtime（getrandom / getentropy / BCryptGenRandom）
- `random_u32_c` / `random_u64_c` / `random_rng_smoke_c` — `random.x`

## 门禁

```bash
SHUX_F_RANDOM_V1_FAIL=1 ./tests/run-f-random-v1-gate.sh
./tests/run-std-random-rng-gate.sh
```

## 下一项

- **F-time v2** / **Z8** 其它 OS 胶层（`log_os_glue.c` 等）
