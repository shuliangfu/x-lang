# std.net 性能压榨与超越 Zig

> 在功能完整的前提下，如何把 std.net 性能压榨到极致并超越 Zig。与《高吞吐网络与多平台》《高并发IO与多平台》衔接。

---

## 一、Zig 网络栈的典型形态与瓶颈

| 维度 | Zig 常见用法 | 瓶颈/可超越点 |
|------|--------------|----------------|
| **数据路径** | std.net.Stream 配合 std.io 的 read/write；默认往往走阻塞或单次 syscall | 单次 read/write、无批量化时 syscall 次数与上下文切换多 |
| **连接建立** | connect/accept 通常单次调用、单连接 | 高并发时 accept/connect 未批量化，系统边界次数高 |
| **多路复用** | 依赖 event loop 或 async；Linux 上未必用 io_uring | 若用 epoll/select，批处理与零拷贝不如 io_uring |
| **内存与拷贝** | 一般需用户提供 buffer，部分路径可能有临时分配 | 热路径若有分配或二次拷贝，延迟与吞吐受损 |
| **平台差异** | 各平台不同后端，API 统一但实现分散 | 我们可做到「一套抽象 + 每平台压榨到该平台最优」 |

**结论**：Zig 强在控制力与无隐藏成本，但 **std.net 的「典型用法」未必用满 io_uring 批量化、多段 I/O、预注册 buffer**。我们若在这些点上做足，即可在**实际表现**上超越其常见用法，并在**抽象统一**上不输。

---

## 二、当前 std.net 与 IO 的差距（相对「极致」）

| 层级 | 现状 | 与「极致」的差距 |
|------|------|------------------|
| **连接建立（net.c）** | connect/accept 用 poll（Unix）或 select（Windows）做超时；单次 accept/单次 connect | Linux 未用 io_uring 的 **multishot accept**、**batch connect**；每次建立仍多次 syscall |
| **数据读写** | 走 std.io：read_fd/write_fd → submit_read/submit_write → io_uring（Linux）/kqueue/IOCP | 已走 uring，但 **单 Buffer**；多段 []Buffer 已预留未在 net 侧用满 |
| **accept_many/connect_many** | 循环单次 accept/connect | 非「一次提交多个 accept/connect、一次收割」，系统边界未压到最低 |
| **UDP** | send_to/recv_from 单次；未与 driver 批量化 | 未做 recvmmsg/sendmmsg（Linux）或等价批量化 |
| **fd 与 buffer 注册** | 每线程 uring 有 register_files/fixed buffer，但 **net 的 fd 未显式参与固定文件槽** | socket fd 未预注册时，每次 submit 可能多一次间接；固定 buffer 未与 net 读路径统一 |
| **热路径** | 无额外分配；Buffer 为值类型 | 已满足零分配；可再收紧「栈上/池化 TcpStream 数组」避免 accept_many 时临时构造 |

---

## 三、压榨到极致的路线图（按优先级）

### 阶段 1：Linux 上 connect/accept 走 io_uring（单次 → 批量化基础）✅

- **目标**：connect、accept 在 Linux 上不再用 poll+connect/accept，改为 **io_uring 的 IORING_OP_CONNECT、IORING_OP_ACCEPT**，与现有 std.io 的 uring 共用同一 ring（或同线程 uring）。
- **收益**：一次 submit 可挂多个 accept/connect，一次 reap 多个完成；减少「poll + 单次 accept」的 syscall 数。
- **实现要点**：
  - 在 **std/io/io.c**（或 net 专用 uring 扩展）中增加：`io_uring_prep_accept`、`io_uring_prep_connect`，超时用 `io_uring_prep_link_timeout` 或统一 timeout_ms 在 reap 时判断。
  - **std/net/net.c**：Linux 分支改为调用上述 uring 接口；非 Linux 保持现有 poll/select 实现。
- **与 Zig 对比**：Zig 常见用法很少把 accept/connect 放进 io_uring；我们做即在这一块领先。

### 阶段 2：accept_many / connect_many 真批量（与 Completion 对接）✅

- **目标**：`accept_many(listener, out: []TcpStream, timeout_ms)`、`connect_many(addr, port, out, timeout_ms)` 不再循环单次，而是 **一次提交 N 个 accept/connect SQE，一次收割 N 个 CQE**，写满 `out`。
- **收益**：高并发建连时，系统边界从 O(N) 降为 O(1)（或少量）次 uring 提交/收割。
- **实现要点**：
  - driver 层扩展：`submit_accept_many(listener_fd, out_fds_ptr, n)`、`submit_connect_many(addr, port, out_fds_ptr, n)`（或返回 Completion 句柄，由 net 层轮询/回调取 fd）。
  - std.net 的 accept_many/connect_many 调用上述接口，将返回的 fd 封装为 TcpStream 填入 `out`。
- **与 Zig 对比**：Zig 标准库通常不提供「一次提交多个 accept/connect」的 API；我们提供即超越。

### 阶段 3：数据路径 []Buffer 与 net 打通 ✅

- **目标**：TcpStream 的读写不仅支持单 Buffer，还支持 **多段 []Buffer**（scatter-gather），走 driver 的 `submit_read_batch`/`submit_write_batch`（或未来的 `submit_read(bufs: []Buffer)`）。
- **收益**：单次 read/write 可覆盖多块 buffer，减少 syscall 次数、更好利用 uring 的 readv/writev 或多 SQE。
- **实现要点**：
  - std.io.driver 已有 `submit_read_batch(buffers: [4]Buffer, n, timeout_ms)`；std.net 可暴露 `stream_read_batch(stream, bufs, n, timeout_ms)`、`stream_write_batch(stream, bufs, n, timeout_ms)`，内部将 `stream.fd` 填成每个 Buffer 的 handle。
  - 若后续 driver 支持 `[]Buffer`（长度动态），net 同步扩展即可。
- **与 Zig 对比**：与 Zig 的 Reader/Writer 多段读写的「可做」相比，我们做成**默认可批、零拷贝**即更贴近极致。

### 阶段 4：socket fd 与 fixed buffer 的注册策略 ✅

- **目标**：高并发服务中，**listener fd 与常用 socket fd 预注册到 io_uring 的 fixed files**；**读路径尽量走 fixed buffer**（预注册的 buffer 池），避免每次映射变动。
- **收益**：SQPOLL 或高负载下，减少 uring 操作的开销；fixed buffer 减少内核与用户态之间的 buffer 注册/撤销。
- **实现要点**：
  - 在 io.c 的 uring 层，listener 创建后可选 `io_uring_register_files` 登记；accept 得到的 client fd 可「按需注册」或「连接池预注册」。
  - std.io 的 `register`/`register_fixed_buffers` 与 net 的读路径结合：例如提供「从 fixed buffer 池中取一块做 read，完成后返回 Slice」的 API，供 echo/代理等热路径使用。
- **与 Zig 对比**：Zig 很少在标准库暴露「固定文件槽 / 固定 buffer 池」的细粒度控制；我们做成可选即更压榨。

### 阶段 5：UDP 批量化（recvmmsg / sendmmsg）✅

- **目标**：UDP 的 recv_from/send_to 在 Linux 上支持 **recvmmsg/sendmmsg**，一次系统调用多报文；接口上可提供 `udp_recv_many`/`udp_send_many`（或 batch 版）。
- **收益**：高 PPS UDP 场景下，系统边界与上下文切换大幅下降。
- **实现要点**：
  - net.c 增加 `net_udp_recv_many_c`/`net_udp_send_many_c`（Linux 走 recvmmsg/sendmmsg，其他平台循环或条件编译回退）。
  - mod.sx 增加 `udp_recv_many`/`udp_send_many`，参数为多 (buf, len) 或多 (addr, port, buf, len)。
- **与 Zig 对比**：Zig std.net UDP 通常为单报文 API；我们提供 many 即在高 PPS 场景超越。

### 阶段 6（可选）：换赛道 — 内核 bypass / 自研路径

- **目标**：在需要「超越内核 socket 理论上限」的场景，接入 **DPDK、旁路网卡或自研内核模块**；std.net 的 API 不变，底层由舒 IO 的 Buffer + submit + completion 对接 bypass 或自研驱动。
- **收益**：延迟与吞吐可超过任何「走内核 socket + io_uring」的栈，包括 Zig 的常见用法。
- **实现要点**：见《高并发IO与多平台》§六、§七；平台分支 SHUX_OS_* 下选径，用户仍用同一套 connect/listen/accept 与 read/write。

**「换赛道」具体指什么？**

| 选项 | 含义 | 典型用途 |
|------|------|----------|
| **DPDK** | Data Plane Development Kit：用户态轮询网卡、绕过内核协议栈 | 超低延迟 / 高 PPS 的网关、负载均衡、自定义协议 |
| **旁路网卡** | 网卡或驱动提供 kernel bypass（如部分 SmartNIC、AF_XDP） | 同左，或与 DPDK 配合 |
| **自研内核模块** | 自写内核模块或 eBPF/XDP 做包处理，再交回用户态 | 可编程数据面、过滤/转发 |

**现在可以写吗？**

- **完整接 DPDK/旁路**：属于**长期可选**。需要引入大依赖（DPDK 构建、PMD、大页等）或内核/驱动开发，且 DPDK 本身不提供「标准 TCP socket」——要么在 DPDK 上跑 lwIP 等栈，要么做裸包/自定义协议，工作量与当前 std.net 不在同一量级。
- **当前可做**：
  1. **抽象预留**：保持 std.net 与 std.io 的「Buffer + submit + completion」抽象，不把「内核 socket」写死；日后在平台或编译选项下可切换后端（如 `SHUX_NET_BACKEND=uring|dpdk|xdp`），而不改用户 API。
  2. **文档与接口约定**：在分析/设计中写明「阶段 6 后端」的接口契约（例如：connect/accept/read/write 由哪一层 C 或 .sx 实现、如何与 Buffer 对接），便于以后接 DPDK/AF_XDP 时只换实现、不拆 API。
  3. **不落实现**：暂不引入 DPDK 或内核模块代码，也不在构建里加 DPDK 依赖；阶段 6 作为路线图占位与设计预留即可。

---

## 四、与 Zig 的「超越」对照表

| 维度 | Zig 典型 | 我们阶段 1～2 后 | 我们阶段 3～5 后 |
|------|----------|-------------------|-------------------|
| accept/connect 批量化 | 无标准 API，手写循环 | ✅ io_uring 批量 accept/connect | ✅ 同左 + 与 Completion 统一 |
| 数据多段 I/O | 可手写 readv/writev | 单 Buffer 为主 | ✅ []Buffer/read_batch/write_batch 与 net 打通 |
| 默认非阻塞 + 统一 driver | 可配置，非默认 | ✅ 已默认非阻塞 + std.io | ✅ 同左 |
| UDP 批量 | 单报文 | 单报文 | ✅ recvmmsg/sendmmsg 或 many API |
| fixed fd/buffer 注册 | 不暴露 | 可选（阶段 4） | ✅ 可选，热路径零额外成本 |
| 超时统一 timeout_ms | 各 API 不一 | ✅ 已统一 | ✅ 已统一 |

**结论**：按阶段 1～3 落地后，在「连接建立批量化 + 数据多段 I/O + 非阻塞与统一 driver」上即可**实际表现超越 Zig 的 std.net 典型用法**；阶段 4～5 进一步压榨；阶段 6 为可选换赛道。

---

## 四.1、吞吐与并发量级（当前栈：内核 socket + io_uring）

| 指标 | 含义 | 当前栈（io_uring + 批量化）量级 | 突破 100 万/秒所需 |
|------|------|----------------------------------|---------------------|
| **连接建立** | 每秒新建立 TCP 连接数（accept/connect） | 单核约 **数万～十几万/秒**（accept_many/connect_many 批量化后）；多核线性扩展 | 多核 + 调优可到 **几十万/秒**；**稳定 100 万/秒** 建连通常需多机或内核/驱动优化 |
| **TCP 吞吐** | 每秒读写字节数（Gbps/MBps） | 单核 **数 Gbps** 可达（stream_read_batch/write_batch、大包）；小包受 PPS 限制 | 100 万 QPS（小请求/响应）≈ 100 万 PPS，接近内核单机上限，需多核 + 绑核、减少拷贝 |
| **UDP PPS** | 每秒收/发 UDP 报文数 | 单核 **数十万 PPS**（udp_recv_many/send_many）；多核可更高 | **100 万 PPS** 在 kernel 栈下多核可冲击；再高常需 AF_XDP/DPDK 等 bypass |
| **并发连接数** | 同时保持的 TCP 连接数（C10M） | **百万级并发连接** 可行（io_uring + 非阻塞 + 足够内存与 fd 限制调优） | 与「每秒新建 100 万」不同；百万连接常指「同时在线」，当前架构可支持 |

**能否突破 100 万/秒？**

- **「100 万/秒」若指「每秒新建 100 万 TCP 连接」**：单机内核栈下**很难稳定达到**；当前 std.net 批量化可把单核建连压到很高，多核可冲**几十万/秒**，要逼近或突破 100 万/秒通常需多机分散、或换赛道（阶段 6 的 bypass）。
- **「100 万/秒」若指「每秒 100 万次请求/响应（QPS）」或「100 万 UDP PPS」**：多核 + 批量化 + 调优（绑核、大页、适当 buffer）下，**有机会冲击或接近**；稳定 100 万 QPS 小包仍是内核单机的高端目标。
- **「100 万」若指「同时 100 万连接在线」**：与 io_uring、epoll 类模型兼容，**可以支持**（受内存、ulimit、应用逻辑影响）。

实际数值需在目标硬件与业务场景下做 benchmark 确定；上表为量级参考。

---

## 四.2、为何暂无内置线程池？要不要加？

**你的判断是对的**：要尽一切可能压榨性能，**让多核用起来零门槛**，内置多 worker/线程池确实能明显提升吞吐（多核并行 accept + 读写），且和「极致压榨」一致。

**当前没有做的原因主要是阶段与分工，不是「不该做」：**

| 原因 | 说明 |
|------|------|
| **尚无 std.thread** | 仓库与 README 里 std.thread/std.mutex 排在「7.4 后期或阶段 8 前」；没有统一的「起线程」API 时，在 std.net 里单独起 pthread 会变成 net 依赖并发原语，边界不清晰。 |
| **先做「每线程一 ring」** | 先把 io_uring 做成每线程一个 ring（TLS），保证**多线程可用、多核能跑**，再补「怎么方便起多线程」——所以目前是「能多核，但要自己起线程」。 |
| **线程池放哪一层** | 通用「线程池」更适合放在 **std.thread / std.concurrent**（任何模块都能用）；std.net 只做 **net 专用多 worker**（例如 listen 时直接起 N 个 worker 线程），避免 net 里塞进一套通用任务队列。 |

**结论与建议：**

- **值得做**：内置多 worker 或与 std.thread 配合的用法，能显著提升多核利用率和整体吞吐，符合「尽一切可能提升性能」。
- **两种路径**（可二选一或都做）：
  1. **先有 std.thread**：提供 `spawn(fn)` 或类似，用户自己写「起 N 个线程，每线程里 accept_many + 读写」，net 不动；多核易用性由语言层解决。
  2. **net 侧提供多 worker 封装**：例如 `listen_workers(addr, port, n_workers)` 或 `run_accept_loop(listener, n_workers)`，内部用 C/pthread 起 n 个线程，每线程一个 io_uring 循环 accept_many/read/write；**不引入通用线程池**，只做「监听 + 多 worker」这一小闭环，体积和依赖可控。
- **与「轻量级」不冲突**：不做通用任务队列和复杂调度，只做「固定 N 个 worker 线程 + 每线程自己的 ring」，属于轻量多核扩展；若实现时发现需要队列，再考虑最小接口（例如仅「交 fd 给 worker」）。

建议在实现顺序中增加一条：**多核易用（std.thread 或 net 内置多 worker）**，作为压榨性能的下一步。

---

## 五、实现顺序建议（与现有代码的衔接）

1. **先做阶段 1**：在 io.c 中为 Linux 增加 uring 的 accept/connect 封装，net.c 的 connect/accept（Linux）改为调 uring，保持现有 API 不变。
2. **再做阶段 2**：在 driver 层增加 submit_accept_many/submit_connect_many（或等价），mod.sx 的 accept_many/connect_many 改为调上述接口并填 []TcpStream。
3. **阶段 3**：为 TcpStream 增加 read_batch/write_batch（或 stream_read_batch/stream_write_batch），内部用 driver 的 submit_read_batch/submit_write_batch + stream.fd。
4. **阶段 4、5**：按需做 fixed 注册与 UDP many；阶段 6 作为长期可选。
5. **多核易用** ✅：std.thread 已提供 spawn/join/affinity；std.net 增加 **run_accept_workers(listener, n_workers, timeout_ms)**，内部起 n 个线程，每线程循环 accept_many 后立即 close（压测建连吞吐）；主线程阻塞 join。用户无需手写 pthread，见 §四.2。自定义业务逻辑仍可用 std.thread 自起线程 + accept_many 循环。

以上顺序保证：**API 稳定、每步可测、与《高并发IO与多平台》的 Buffer/Completion/零分配约定一致**，从而在功能完整之后，把 std.net 性能压榨到极致并超越 Zig。

---

## 六、继续压榨（阶段 1～5 之后）

| 项 | 做法 | 状态 |
|----|------|------|
| **accept/connect 批量扩大** | IO_NET_BATCH_MAX 32→64；accept_many/connect_many 单次可提交 64 个 SQE，单轮建连更多 | ✅ 已做 |
| **CQE 收割一次取齐** | io_uring_accept_many/connect_many 用 **peek_batch_cqe** 一次取齐本批 CQE，不再循环 wait_cqe，减少内核边界与分支 | ✅ 已做 |
| **run_accept_workers 批量** | 每 worker 内 accept_many 批量 32→64，与 IO_NET_BATCH_MAX 一致 | ✅ 已做 |
| **多核 + 绑核** | run_accept_workers 在**链接 std.thread** 时自动为每 worker 调 thread_set_affinity_self_c(worker_index)，Linux/Windows 绑核；用户自起线程时同样在 worker 入口先 thread_set_affinity_self(worker_id) | ✅ 已做（net 弱符号可选调 thread） |
| **multishot accept（可选）** | Linux 5.19+ IORING_ACCEPT_MULTISHOT 一次提交持续 accept；需改 io 层语义，可作后续优化 | 预留 |

---

### 六.1 多核 + 绑核 推荐用法

**方式一：run_accept_workers（压测/占位）**

- 同时 `import("std.net")` 与 `import("std.thread")` 并链接 thread.o 时，`run_accept_workers(listener, n_workers, timeout_ms)` 内部会为每个 worker 调用 `thread_set_affinity_self_c(worker_index)`，即 **worker 0→CPU 0、worker 1→CPU 1**，无需用户手写。
- 仅 import("std.net") 不链 thread 时，run_accept_workers 仍可用，只是不绑核。

**方式二：自起线程 + accept_many + 业务（需 C 入口或日后 &fn）**

- 推荐模式（伪代码）：主线程 `listen` → 起 n 个线程，传入 `(listener, worker_id)`；每个 worker 入口内：
  1. `thread_set_affinity_self(worker_id)`（Linux/Windows 绑核；macOS 可 `thread_set_qos_class_self(2)`）；
  2. 循环：`accept_many(listener, out[0..64], timeout_ms)` → 对每个 `TcpStream` 做读写信令或 echo，然后 `close_stream`。
- 这样「每核一线程一 io_uring」+ 绑核，减少迁移与缓存抖动，吞吐更稳。

---

### 六.2 read/write 路径压榨与最佳实践

**已采用切片式 API，与 Zig/Rust 对齐**  
- TCP 流读写：`stream_read_batch_buf(stream, buffers: *Buffer, n, timeout_ms)` / `stream_write_batch_buf(stream, buffers: *Buffer, n, timeout_ms)`，`n` 为 1..16（`IO_READV_BUF_MAX`），由调用方决定段数，与 Zig 的 `readv(iovecs: []...)`、Rust 的 `read_vectored(&[IoSliceMut])` 语义一致。  
- 原有 4 段具名 API `stream_read_batch`/`stream_write_batch` 保留，便于简单场景；热路径推荐用 `*Buffer + n` 打满所需段数以减少 syscall。

| 项 | 建议 | 说明 |
|----|------|------|
| **batch 读写** | **用切片式 API** | `stream_read_batch_buf` / `stream_write_batch_buf`，buffers 指向至少 n 个 Buffer，n 为 1..16；栈上 `let bufs: [16]Buffer = [...]` 后传 `&bufs[0]`。 |
| **fixed buffer 热路径** | echo/代理用 **register_fixed_buffers_buf + stream_read_fixed/stream_write_fixed** | 先 `io.register_fixed_buffers_buf(bufs, nr)` 注册池，读用 `stream_read_fixed`，写用 `stream_write_fixed`，减少 uring 侧 buffer 注册/撤销。 |
| **零分配** | 热路径不分配；TcpStream 用栈上或池化数组 | accept_many 的 `out` 与读写的 buffer 由调用方提供，std.net 不分配。 |
