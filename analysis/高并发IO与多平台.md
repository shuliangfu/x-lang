# 高并发 I/O 与多平台设计

> 本文档约定：零拷贝与 fixed buffer、超时、Completion 与无锁、多段 I/O、**热路径零分配**、**Buffer 与 Slice 零拷贝约定**，以及**平台分支**的定位，供自举后实现**舒 IO（Shu IO）**时遵循。  
> **目标**：实现**自己的舒 IO**，在性能与并发能力上**超越**现有内核/系统 API（io_uring、kqueue、IOCP），而非以它们为后端；条件编译用于各平台下舒 IO 的差异化实现或与内核的对接方式。  
> 关联：《[自举前-极致IO与网络性能准备](自举前-极致IO与网络性能准备.md)》《[自举前必须清单](自举前必须清单.md)》。

---

## 一、零拷贝与 Fixed Buffer（P3：Buffer 与 Slice 约定）

### 1.1 Buffer 与 Slice 关系

- **Buffer**：`(ptr, len, handle)`，64 位下 ABI 24 字节。`ptr` 指向内存，`len` 为字节数，**handle 仅用于 driver 层**（舒 IO 预注册句柄或 fixed buffer 索引）。
- **Slice**：`(ptr, len)`，与 Buffer 前两字段一致；表示「可读或可写的一段内存」。
- **零拷贝约定**：
  - **Buffer 与 Slice 的互转/视图仅为指针与长度传递，无额外拷贝**。从 Buffer 得到可读/可写区间时，只传递 ptr 与 len（或包装为 ReadOnlySlice/WriteOnlySlice），**不拷贝内存**。
  - **handle 仅 driver 层使用**：提交回驱动（submit_read/submit_write）时仍用完整 Buffer（含 handle）；上层业务可只持有 Slice 视图，不碰 handle。

### 1.2 ReadOnlySlice / WriteOnlySlice

- 零拷贝只读/只写视图，字段为 `data: u8[]`；与 driver 对接时**仅传递指针+长度**，避免隐式拷贝。
- 舒 IO 中 Buffer 经预注册后，读完成的数据可直接通过 Slice 暴露给调用方，无需再拷贝。

---

## 二、超时

- 所有读写接口**统一预留 timeout 参数**（如 `timeout_ms: u32`）；**0 表示无超时**（阻塞直到有数据或完成）。
- 高并发下**禁止无超时的阻塞 I/O** 作为默认，避免挂死与资源泄漏；driver 层 submit_read/submit_write 均带 timeout_ms。

---

## 三、Completion 与无锁（P4：热路径零分配）

### 3.1 完成状态与原子位

- **IO_Result**：Ok / Err / Timeout / Cancelled；Err 负载为 i32 错误码（自举后可扩展）。
- **Completion**：完成句柄占位；自举后与 completion 队列、无锁状态机对接。
- **AsyncContext**：原子位占位（如 flags）；自举后用于原子状态位，不依赖锁。

### 3.2 热路径零分配约定

- **异步/完成回调模型不依赖「必须堆分配闭包或 Future」**。允许**栈上状态机 + 固定大小 Completion 队列**实现。
- 若语言层面暂无 async/await，明确：自举后可用 **C 风格回调 + 外部 Completion 队列** 接入舒 IO 完成路径，**不引入隐式堆分配**。
- **接口与类型不堵死该路径**：Completion、AsyncContext 为固定大小；状态机可由栈或预分配池表示，热路径上不强制 malloc。

---

## 四、多段 I/O（Buffer[] 批量提交）

- 高并发与高吞吐依赖**多段 Buffer 一次提交**（类似 readv/writev、iovec，但由舒 IO 自己实现与优化）。
- **预留**：driver 层预留 **Buffer[] 多段扩展**（如 `submit_read(bufs: Buffer[], timeout_ms)`）；当前签名为单 Buffer，扩展时不破坏现有 read(buf)/write(buf) 单缓冲 API。
- **批量 I/O** 以 **Buffer[] 或等价形式在 driver 层扩展**；标准库上层可在此基础上封装。

---

## 五、网络接口预留（高吞吐、高并发）

- **定位**：网络与 IO 共用同一套「Buffer + submit + completion」抽象；**数据读写**统一走 std.io.driver，**连接生命周期**由 std.net 提供 API。
- **std.net 为对外 API 层**：提供 Ipv4Addr、TcpStream、TcpListener、connect、listen、accept；自举前仅占位，**不做单独 net/core.sx**，调度与实现细节自举后在 mod 内或下层（driver/核心）完成。
- **超时**：connect(addr, port, timeout_ms)、accept(listener, timeout_ms) 已预留 timeout_ms（0=无超时），与 driver 的 submit 超时一致。
- **Completion 与批量**：自举后 accept/connect 可与 driver 的 Completion 对接、支持无锁完成路径；**预留**批量 accept、批量 connect（或 TcpStream[] 等），与 Buffer[] 多段扩展同思路。
- **TcpStream 与 handle**：自举后 TcpStream/TcpListener 的句柄可与 driver 的 handle 统一（如 usize），便于在 submit_read/submit_write 时用同一套 Buffer(ptr, len, handle)。

---

## 六、平台分支（条件编译）— 舒 IO 自研，超越现有 API

- **目标**：实现**舒 IO（Shu IO）**，在 IO 与网络的高并发、高吞吐上**超越**现有系统 API（io_uring、kqueue、IOCP），**不是**以它们为后端封装，而是自研驱动与调度模型。
- **平台分支的用途**：各 OS/arch 下**舒 IO 的差异化实现**（如与内核的对接方式、syscall 或自有协议不同）；条件编译 **SHUX_OS_* / SHUX_ARCH_*** 用于在 std.io.driver 与运行时内选径，用户 API 统一（std.io / std.net）；std.net 为 API 层，调度与数据路径见 §五。详见《[条件编译](条件编译.md)》。
- **不承诺**：实现过程中若需与现有 API 对比、联调或临时回退，可留分支；长期方向是舒 IO 独立于 io_uring/kqueue/IOCP 并超越之。

---

## 七、如何实现才能超越现有 API，以及自举前应做的准备

### 6.1 现有 API 为何快（简要）

- **io_uring**：用户态与内核共享环形缓冲，批量提交、批量收割；预注册 buffer 减少映射与拷贝；轮询或中断可选，减少上下文切换。
- **kqueue / IOCP**：事件就绪通知、多路复用，减少阻塞与线程数；但通常仍是「一次操作一次系统边界」，批处理与零拷贝不如 io_uring 彻底。
- **共性**：减少 syscall 次数、减少拷贝、批处理、完成通知不阻塞热路径。要**超越**，需要在这些维度上更激进，或换一种与内核/硬件的协作方式。

### 6.2 舒 IO 实现方向（自举后落地）

以下方向在自举后实现时可供选择，**自举前不实现具体逻辑**，只把接口与约定定死，避免将来返工：

| 方向 | 要点 | 自举前准备 |
|------|------|------------|
| **接口不绑定现有 API** | 抽象为「Buffer + 预注册 + 批量 submit + completion」，**不**暴露 io_uring/kqueue/IOCP 的 op 或句柄；舒 IO 内部可用自研 ring、自研协议或新 syscall。 | Buffer/Completion/AsyncContext 类型与 ABI 已定；register、submit_read、submit_write 签名已定，不依赖任一内核 API 形状。 |
| **热路径零成本** | submit/completion 路径上：零分配、零拷贝、无锁；完成结果通过固定大小结构或 ring 传递，不 malloc。 | 热路径零分配约定（§3.2）；Completion/AsyncContext 固定大小；Buffer 与 Slice 零拷贝约定（§1）。 |
| **批量与多段** | 一次提交多 Buffer（Buffer[]），一次收割多 Completion；减少系统边界与调度次数。 | Buffer[] 多段扩展已预留；接口不堵死批量 submit/complete。 |
| **可选：内核 bypass 或自研内核路径** | 若走 DPDK/旁路网卡或自研内核模块，舒 IO 的接口仍是 Buffer + submit + completion，只是底层由自研驱动或内核模块实现。 | 当前抽象不依赖「必须走 io_uring 或 socket」；handle 可表示自研资源的句柄。 |
| **可选：per-core 状态与无锁队列** | 每核独立 submit/completion 队列，避免锁；轮询与中断混合，按负载切换。 | AsyncContext 原子位、Completion 固定大小已预留；无锁与栈/池化状态机已在文档约定。 |

### 6.3 自举前为「超越」做好的准备（清单）

自举前**不实现**舒 IO 的具体算法或内核对接，只做以下准备，使自举后能在其上实现并超越现有 API：

1. **ABI 与类型锁定**：Buffer(ptr, len, handle) 24 字节、Slice(ptr, len)、Completion/AsyncContext 固定大小；与 C 互操作零成本。→ 已就绪。
2. **零拷贝与零分配约定**：Buffer↔Slice 仅传指针与长度；热路径不强制堆分配；文档写入《高并发IO与多平台》§1、§3。→ 已就绪。
3. **接口形状不绑定现有 API**：register、submit_read、submit_write 以 Buffer 与 timeout 为参数，不暴露 io_uring op 或 kqueue filter；预留 Buffer[]。→ 已就绪。
4. **超时与完成状态**：所有读写带 timeout_ms；IO_Result/Completion 表示完成状态，便于自举后实现超时与取消。→ 已就绪。
5. **平台分支**：SHUX_OS_* / SHUX_ARCH_* 条件编译，便于各平台下舒 IO 差异化实现（不同 syscall、不同驱动）。→ 已就绪。
6. **高并发设计文档**：本文档含「如何超越」的方向与自举前准备清单，自举后实现时可直接按此扩展。→ 本文档。

自举后在此之上实现：**具体 ring 布局、提交/完成队列、与内核或 bypass 的对接、批处理与调度策略**；语言与 ABI 不再返工，即可向「超越 io_uring/kqueue/IOCP」推进。

### 6.4 「超越」能否实现？——可行含义与实现路径

**结论：能实现，但需明确「超越」的三种可行含义。** 在「仍只使用内核提供的 syscall、不增加内核或硬件 bypass」的前提下，**无法在性能上真正超过内核 API 的理论上限**（上限由内核与硬件决定）；舒 IO 的「超越」通过以下路径实现：

| 含义 | 是否可行 | 实现方式 |
|------|----------|----------|
| **（1）抽象与体验超越** | ✅ 可行 | 统一 Buffer + submit + completion 抽象，一套 API 覆盖 Linux/macOS/Windows；不暴露 uring/kevent/IOCP 细节；自举后可在不改用户代码的前提下替换后端（自研 ring 或 bypass），实现「体验与可演进性」上的超越。 |
| **（2）实际表现超越「典型用法」** | ✅ 可行 | 通过批量化（Buffer[]）、预注册、热路径零分配、轮询/中断可调等，使舒 IO 的**实际吞吐与延迟**优于「未调优、单次 syscall、带分配」的 uring/kqueue/IOCP 用法；与手写 C 调优到极致的 uring 同水平，即视为在该维度「达到并可比肩」现有 API。 |
| **（3）同一内核下性能理论超越** | ❌ 不可行 | 若仍只使用内核提供的 io_uring/kqueue/IOCP，则性能上限由内核与硬件决定，用户态无法「比内核 API 更快」。 |
| **（4）换赛道后的超越** | ✅ 可选 | **内核 bypass**（如 DPDK、旁路网卡）：网络路径完全用户态，延迟与吞吐可超越走内核 socket 的 uring/kqueue/IOCP；**自研内核模块或协议**：在特定场景下提供比通用 uring 更贴合的接口与调度。此时「舒 IO」的接口不变（仍为 Buffer + submit + completion），仅底层由自研驱动或 bypass 实现，从而实现**在该赛道内**的超越。 |

**当前实现与目标的关系**：为自举与三平台可用，**现阶段** std.io 以 io_uring（Linux）、kqueue（macOS）、IOCP（Windows）为后端；**接口已按 §七 表格（接口不绑定现有 API、热路径零成本等）设计**，不绑定任一内核 API 形状。自举后可以：
- **路径 A**：在现有后端上做足批量化、零分配、轮询与 fixed buffer，达到「（2）实际表现超越典型用法」；
- **路径 B**：替换后端为自研 ring 或与内核的新对接方式（如新 syscall、自研模块），在接口不变下追求更优调度；
- **路径 C**：在需要极致网络性能的场景，接入 DPDK 或旁路驱动，实现「（4）换赛道后的超越」。
- **路径 D（可选，后期）**：**自研内核或内核层**，在「自己掌握 IO 栈与调度」的前提下超越现有通用内核的 API 上限。见下条。

**后期能否通过「自己写内核」超越？** 可以，作为路径 D 纳入「换赛道」选项，但需区分范围与成本：

| 层次 | 含义 | 可行性与说明 |
|------|------|----------------|
| **自研内核模块 / 驱动** | 在 Linux 等现有内核上提供自定义 IO 接口（如新的 ring、专用协议），舒 IO 对接该模块。 | ✅ 可行；不改通用内核行为，只在特定场景暴露「比 io_uring 更贴合的」接口与调度，实现该场景下的超越。 |
| **专用小内核 / Unikernel** | 为舒语言运行时定制的极小内核或 unikernel：仅含调度、内存与自研 IO 栈，无通用 POSIX 包袱；舒 IO 即内核 IO 路径。 | ✅ 可行；面向嵌入式、存储或网络服务器等场景，IO 路径可完全按 Buffer + submit + completion 设计，理论上限由自研实现决定。 |
| **完整自研通用内核** | 从零实现一个通用 OS 内核，其 IO 子系统优于 Linux/BSD/Windows。 | ⚠ 工程量极大；仅在有明确场景（如专用设备、研究或长期产品）时考虑；舒 IO 的抽象可复用到该内核的用户态或作为内核内部接口。 |

结论：**后期通过自研内核（模块 / 小内核 / 完整内核）在各自范围内超越现有 API 是可行的**；文档将「自研内核」列为可选长期路径，与 bypass、自研 ring 并列；当前仍以接口与自举为先，不依赖自研内核即可达成（1）（2）及部分（4）。

因此，**「超越 io_uring、kqueue、IOCP」在「抽象 + 实际表现 + 可选 bypass + 可选自研内核」意义下可以实现**；在「同一通用内核、同一 syscall 前提下理论性能更强」意义下不可实现，文档中的长期目标取前者。

---

## 八、与自举前必须清单的对应

- **S2**：ReadOnlySlice / WriteOnlySlice 已定义，本文档约定其为零拷贝视图。
- **S3**：超时参数已预留，本文档约定 0=无超时、高并发下避免无超时阻塞。
- **S4**：Buffer(ptr, len, handle) 与预注册、fixed buffer 的对应关系见 §1；handle 仅 driver 层。
- **S6 / D2**：本文档即「高并发 I/O 与多平台设计文档」，含零拷贝、超时、Completion、多段 I/O、**网络接口预留（§五）**、平台分支、热路径零分配约定，以及**§七 如何实现才能超越现有 API 与自举前准备清单**；目标为自研舒 IO 并超越 io_uring / kqueue / IOCP。

---

*本文档满足自举前必须清单 P3、P4、P6 的文档化要求；§七 明确「如何实现才能超越」与自举前准备清单，自举后实现**舒 IO** 时可直接按此扩展。*
