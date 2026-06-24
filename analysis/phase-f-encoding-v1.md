# 阶段 F-encoding v1（std.encoding 去 C）

> **F-encoding v1**：删除 **`encoding.c`**；UTF-8/hex/base32/percent 全在 **`encoding.sx`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `encoding.c`（397 行） | `encoding.sx` |
| `encoding.o` | `cc -c encoding.c` | `shux -backend asm encoding.sx` |
| UTF-8 首字节表 | 256 字节静态表 | 范围判定函数 |
| 存量 | std 87 `.c` | std **86** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/encoding/encoding.c`~~ | v1 删除 |

## 构建

```bash
make -C compiler ../std/encoding/encoding.o
```

## 门禁

```bash
SHUX_F_ENCODING_V1_FAIL=1 ./tests/run-f-encoding-v1-gate.sh
./tests/run-std-encoding-hex-base64-gate.sh
./tests/run-std-encoding-extra-gate.sh
```

## 下一项

- **F-env v1** / **F-log v1** 等小模块
- **F-process v2**：getcwd/self_exe 缓存迁 `.sx`
