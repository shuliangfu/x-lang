# STD-110：std.codec compress/base64 流式适配 v1

> 更新时间：2026-06-27  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-codec-stream.tsv`、`tests/std-codec/stream_roundtrip.x`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 |
| 2 | `tests/baseline/std-codec-stream.tsv` |
| 3 | `./tests/run-std-codec-stream-gate.sh` |

---

## 2. 流式适配

| API | 说明 |
|-----|------|
| `kind_base64_stream()` | Base64 流 kind |
| `codec_init_base64(sc, state, cap, url, mode)` | 绑定 base64 流；mode=compress 编码 / decompress 解码 |
| `codec_state_bytes()` | gzip 与 base64 流状态取较大值 |
| `codec_process` / `codec_end` | 按 kind 分发 gzip 或 base64 流 |
| `adapter_compress_stream_init` | gzip 流 init（委托 `codec_init_gzip`） |
| `adapter_compress_stream_process` | gzip/base64 流 process（委托 `codec_process`） |
| `adapter_compress_stream_end` | 流 end（委托 `codec_end`） |
| `adapter_base64_stream_init` | base64 流 init |
| `adapter_base64_stream_process` | base64 流 process |
| `adapter_base64_stream_end` | base64 流 end |

金样向量：`tests/baseline/std-codec-stream-vectors.tsv`（`aGVsbG8=` = hello）。

---

## 4. Gate

```bash
./tests/run-std-codec-stream-gate.sh
```

```
xlang: [XLANG_STD110_CODEC_STREAM] status=ok run=0 obs=1 skip=0
std-codec-stream gate OK
```

### Gate honesty (2026-08-28)

- Prefer product `xlang_asm`; pin `XLANG_LINK_XLANG`. Explicit bad / missing native = hard die.
- Refuse soft prefer-c / soft auto-make / soft SKIP→OK / check-as-sole-green.
- check residual = obs (paused 2026-08-05). tip product `-o` `std_codec_*` UNDEF = obs (product debt leave).
- Report contract: `run=` / `obs=` / `skip=`. Archive DOC is live authority.
