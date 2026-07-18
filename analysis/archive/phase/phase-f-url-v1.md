# 阶段 F-url v1（std.url 去 C）

> **F-url v1**：删除 **`url.c`**；锚点 **`url.x`**；URL 解析在 **`url_glue.c`**。

## 变更

| 项 | 前 | 后 |
|----|----|-----|
| 实现 | `url.c`（456 行） | `url.x` + `url_glue.c` |
| `url.o` | `cc -c` | `ld -r` 合并 |

## 门禁

```bash
SHUX_F_URL_V1_FAIL=1 ./tests/run-f-url-v1-gate.sh
./tests/run-std-url-gate.sh
./tests/run-std-url-ipv6-host-gate.sh
```

## 下一项

- **F-url v2** ✅ / **F-schema v1** ✅ / **F-socketio v1**
