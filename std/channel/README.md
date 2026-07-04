# std.channel — 有界/无界 channel

**模块路径**：`std/channel/mod.x` + `std/channel/channel.x` + `compiler/src/asm/runtime_channel_glue.c`（F-channel v2 / F-ZC）  
**对标**：Go channel、Rust mpsc（有界、阻塞 send/recv）。

## 平台

- **Linux/macOS**：pthread mutex + condvar（链接 `-lpthread`）。
- **Windows**：`CRITICAL_SECTION` + `CONDITION_VARIABLE`（Vista+，与 select 共用实现）。

## API 概览

- `bounded(cap)` / `unbounded()` — 创建有界/无界 channel。
- `send` / `recv` — 阻塞发送/接收。
- `try_send` / `try_recv` — 非阻塞尝试。
- `close` / `free` — 关闭与释放。
- `select_*` — 双路/N 路 recv/send/混合 select（STD-098/102/104/108）。

## 测试

- `bash tests/run-channel.sh`
- `bash tests/run-std-channel-select-gate.sh`
- `bash tests/run-f-channel-v1-gate.sh`
- cookbook：`examples/cookbook/async_channel_ping.x`
