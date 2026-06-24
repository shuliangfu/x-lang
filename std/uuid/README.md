# std.uuid

UUID v4/v7 生成、标准字符串 parse/format、128-bit 比较（RFC 9562）。

## F-uuid v1（去 C）

- **`uuid.c` 已删除**；实现见 `uuid.sx`
- 构建：`make -C compiler ../std/uuid/uuid.o`（依赖 random.o + time.o）
- 门禁：`./tests/run-f-uuid-v1-gate.sh`

## Gate

```bash
./tests/run-std-uuid-gate.sh
SHUX_F_UUID_V1_FAIL=1 ./tests/run-f-uuid-v1-gate.sh
```
