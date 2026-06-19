# DOC-001 标准库 Cookbook v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 读者：需在 30 分钟内跑通 IO / NET / 零拷贝 / async 主路径的开发者  
> 关联：`STD-001/002/004`、`ZC-006`

---

## 1. 阅读路径（约 30 分钟）

| 时段 | 章节 | 产出 |
|------|------|------|
| **0–8 min** | §2 IO 食谱 | 能 batch 读写 + mmap 读文件 |
| **8–15 min** | §3 NET 食谱 | 能 bind/listen + UDP + stream 写 |
| **15–22 min** | §4 ZC 食谱 | 知道 arena / read_ptr / provided 入口 |
| **22–28 min** | §5 ASYNC 食谱 | 能 import async + drain + channel |
| **28–30 min** | §6 验证 + §8 自检 | 本地 gate 绿 |

---

## 2. IO 食谱（STD-001）

### IO-01：`examples/cookbook/io_batch_rw.sx`

`write_batch_fd` + `read_batch_fd` 两段环回；全平台走 `std.io` 后端分派。

```bash
SHUX=./compiler/shux-c ./compiler/shux-c -L . examples/cookbook/io_batch_rw.sx -o /tmp/cb_io_batch
/tmp/cb_io_batch; echo exit=$?
```

### IO-02：`examples/cookbook/io_read_chunk.sx`

大块 `fs_read` 顺序读；适合无 mmap 的便携路径。

### IO-03：`examples/cookbook/io_mmap_read.sx`

`read_ptr` 绝对视图读文件（ZC-2 与 IO 交叉）。

深潜：`std/io/README.md`、`tests/run-io-unified-gate.sh`。

---

## 3. NET 食谱（STD-002）

### NET-01：`examples/cookbook/net_listen_bind.sx`

`listen` + `close_listener` 烟测（避免单线程自 accept 卡死）。

### NET-02：`examples/cookbook/net_udp_bind.sx`

`udp_bind` + `close_udp`。

### NET-03：`examples/cookbook/net_stream_write.sx`

`connect_blocking` + `stream_write_batch`；无 server 时 exit=2 属预期。  
吞吐对标见 `tests/bench/net_echo_throughput.sx` + `tests/run-perf-net.sh`。

深潜：`std/net/README.md`、`tests/run-std-net-api-gate.sh`。

---

## 4. 零拷贝（ZC）食谱（ZC-006）

### ZC-01：`examples/cookbook/zc_arena_concat.sx`

Arena64 + `string_view_concat_arena`（ZC-4）。

### ZC-02：`examples/cookbook/zc_read_ptr_slice.sx`

`read_ptr_view` + `read_ptr_view_valid`（ZC-2/ZC-3）。

### ZC-03：`examples/cookbook/zc_provided_buffers.sx`

`register_provided_buffers`（ZC-1，Linux io_uring）。

语义地图：`tests/baseline/zc-semantics.tsv`、`tests/run-zc-semantics-gate.sh`。

---

## 5. ASYNC 食谱（STD-004）

### ASYNC-01：`examples/cookbook/async_mod_import.sx`

`import("std.async")` 符号链烟测。

### ASYNC-02：`examples/cookbook/async_drain_idle.sx`

`shu_async_run_drain_until_idle` 空转 drain。

### ASYNC-03：`examples/cookbook/async_channel_ping.sx`

`std.channel` 有界 send/recv（与调度器配套）。

深潜：`std/async/README.md`、`tests/run-std-async-api-gate.sh`。

---

## 6. 运行与验证

```bash
# manifest + 食谱 typeck
./tests/run-doc-stdlib-cookbook-gate.sh

# 单食谱 typeck
./compiler/shux-c check -L . examples/cookbook/io_batch_rw.sx

# 领域烟测（native shux 时）
./tests/run-std-io-api-gate.sh
./tests/run-std-net-api-gate.sh
./tests/run-zc4-gate.sh
./tests/run-std-async-api-gate.sh
```

食谱清单：`tests/baseline/doc-stdlib-cookbook.tsv`（12 个 `examples/cookbook/*.sx` recipe）。

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| manifest | `tests/baseline/doc-stdlib-cookbook.tsv` |
| 食谱目录 | `examples/cookbook/` |
| 库 | `tests/lib/doc-cookbook.sh` |
| 门禁 | `tests/run-doc-stdlib-cookbook-gate.sh` |

---

## 8. 自检（5 题）

1. batch 读写应优先用哪个 API？（`read_batch_fd` / `write_batch_fd`）  
2. `read_ptr_view_valid` 解决什么问题？（gen 失效 / 视图生命周期）  
3. ZC-4 string 路径为何用 Arena64？（避免 per-concat heap）  
4. `connect_blocking(..., timeout_ms)` 为 0 表示什么？（阻塞 connect）  
5. 如何验证全部食谱？（`run-doc-stdlib-cookbook-gate.sh`）

**DOC-001 状态：定版 ✅**
