# 阶段 F-base64 v1（std.base64 去 C）

> **F-base64 v1**：删除 **`base64.c`**；块/流式 API 全在 **`base64.sx`**；**零胶层 C**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `base64.c`（567 行） | `base64.sx`（块 + STD-109 流） |
| `base64.o` | `cc -c base64.c` | `shux -backend asm base64.sx` |
| 解码表 | 静态 256 字节表 | 字符分类函数（无 lazy init） |
| 存量 | std 89 `.c` | std **88** `.c` |

## 已删除（须保持 absent）

| 文件 | 说明 |
|------|------|
| ~~`std/base64/base64.c`~~ | v1 删除 |

## 构建

```bash
make -C compiler ../std/base64/base64.o
```

## 门禁

```bash
SHUX_F_BASE64_V1_FAIL=1 ./tests/run-f-base64-v1-gate.sh
./tests/run-base64.sh
./tests/run-std-base64-stream-gate.sh
```

## 下一项

- **F-encoding v1** / **F-string v1**
- **F-process v2**：getcwd/self_exe 缓存迁 `.sx`
