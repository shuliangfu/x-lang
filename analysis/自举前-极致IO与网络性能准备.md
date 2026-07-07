# 自举前 — 为极致 IO 与网络性能做的准备

> 本文档说明：在**自举之前**，需要为「**舒 IO（Shu IO）**」——在 IO 与网络高并发高吞吐上**超越**现有系统 API（io_uring、kqueue、IOCP）——做好哪些**接口、ABI、语义与文档约定**，以便自举后实现时**不推翻重来**、能直接压榨到极致性能。  
> 关联文档：《[高并发IO与多平台](高并发IO与多平台.md)》《[自举前必须清单](自举前必须清单.md)》《[自举实现分析](自举实现分析.md)》《[自举前性能与语义基建](自举前性能与语义基建.md)》。

---

## 一、目标与范围

### 1.1 性能目标（自举后实现）

- **IO**：自研**舒 IO**，达到**超越 io_uring/kqueue/IOCP** 的高并发、高吞吐（固定 buffer、预注册、批量提交、completion 无锁）；**不以**现有内核 API 为后端封装。
- **网络**：同等级别的连接多路复用、零拷贝、批量收发、超时可控、无阻塞热路径。

这些**实现**在自举后用 .x 完成；本文档只谈**自举前要准备好的前提**。具体「如何实现才能超越」与自举前准备清单见《[高并发IO与多平台](高并发IO与多平台.md)》§6。

### 1.2 自举前「准备」的含义

- **不要求**在自举前实现舒 IO 的具体算法或内核对接，也不要求实现 io_uring/kqueue/IOCP。
- **要求**：在语言、ABI、标准库接口与文档上**预留好扩展点**，使得自举后实现**舒 IO**（超越现有 API）时：
  - 不需要改 Buffer/Reader/Writer 的 ABI 或签名；
  - 不需要引入「为兼容旧接口而做的拷贝或装箱」；
  - 热路径上可以**零分配、零拷贝、无锁 completion**；
  - **接口不绑定**任一现有内核 API 形状，便于自研 ring、自研协议或内核 bypass。

---

## 二、已就绪的预留（对照自举前必须清单）

以下在仓库中的**类型与接口**情况：**✅ 已实现**表示类型/签名/ABI/编译器能力已落地且稳定；**⬜ 待实现**表示当前仅为占位（如 `return 0`），**接下来要全部实现**。

| 状态 | 项 | 位置 | 作用 |
|------|----|------|------|
| ✅ 已实现 | **Buffer ABI 24 字节** | std.mem.Buffer、Buffer | ptr + len + handle，与舒 IO 预注册句柄 / fixed buffer 对接；64 位下 8+8+8，与 Slice(ptr, len) 兼容扩展；ABI 测试已覆盖。 |
| ✅ 已实现 | **内核预注册** | std.mem.register_buffer、std.io.driver.register | 通过 std.io.core（.x，Shu IO 核心）的 shu_io_register；当前为桩（返回 0），自举后可在此模块内改为舒 IO 预注册逻辑；接口不绑定现有 API。 |
| ✅ 已实现 | **提交读/写 + 超时** | std.io.driver.submit_read / submit_write(buf, timeout_ms) | 通过 std.io.core（.x，Shu IO 核心）的 shu_io_submit_read/submit_write；当前为桩（返回 0），自举后可改为真实 I/O 与超时；Buffer[] 多段扩展预留。 |
| ✅ 已实现 | **ReadOnlySlice / WriteOnlySlice** | std.io | 零拷贝只读/只写视图类型已定义，便于与 driver 对接、避免隐式拷贝。 |
| ✅ 已实现 | **Reader / Writer trait** | std.io | 自举前最小签名已定义；扩展时需保证不堵死「批量 Buffer、超时、completion」语义。 |
| ✅ 已实现 | **超时参数** | std.io read_with_timeout / write_with_timeout、driver timeout_ms | 所有读写接口已统一预留 timeout 参数（0=无超时），避免高并发下挂死与资源泄漏。 |
| ✅ 已实现 | **IO_Result / Completion / AsyncContext** | std.io.driver | 完成状态枚举与原子位结构体已定义；与 completion 队列、无锁状态机的对接逻辑待实现。 |
| ✅ 已实现 | **条件编译** | 编译器 + analysis/条件编译.md | SHUX_OS_* / SHUX_ARCH_* 全大写已注入；各平台下**舒 IO 差异化实现**可据此选径，目标超越 io_uring/kqueue/IOCP。 |

**上述 2 项已实现**：内核预注册、提交读/写 + 超时 已由 **std.io.core**（`std/io/core.x`，Shu IO 核心）实现，std.io.driver 与 std.mem 通过 `import("std.io.core")` 调用 `shu_io_register` / `shu_io_submit_read` / `shu_io_submit_write`；当前为桩（返回 0），自举后可在该 .x 模块内改为舒 IO 真实逻辑或通过 extern 调用内核/驱动。设计目标与「如何超越」见《[高并发IO与多平台](高并发IO与多平台.md)》§6。

### 2.1 为什么 Buffer 是 24 字节？24 与 32 字节对比

- **24 字节的由来**：64 位下三个 8 字节字段的自然结果：`ptr`(8) + `len`(8) + `handle`(8) = **24**，无 padding。在「三个 64 位」语义下已是**最小尺寸**。

- **24 与 32 字节对比**（32 即 24 + 8 字节预留/对齐 padding，或增加一个 8 字节预留字段）：

| 维度 | 24 字节 | 32 字节 |
|------|---------|---------|
| **体积** | 最小，无冗余 | 多 8 字节；百万级 Buffer 时多约 8 MB 内存 |
| **缓存** | 64B 缓存行可放 2.67 个，步长不规则 | 64B 行正好 2 个，步长规则，预取友好 |
| **对齐** | 8 字节对齐；非 2 的幂，数组 stride 24 | 可 32 字节对齐；2 的幂，利于 SIMD/AVX 与分配器 |
| **分配器** | 24 非 2 的幂，某些分配器易产生碎片 | 2 的幂大小常减少碎片、固定大小池更简单 |
| **扩展** | 无预留，加字段必改 ABI | 8 字节可作 reserved/flags，后续扩展不破 ABI |
| **单次访问** | 单 Buffer 热路径差异很小 | 单 Buffer 热路径差异很小 |
| **大批量** | Buffer 池/队列极大时，更少内存、更多条目进缓存 | 数组遍历 stride 规则、32B 对齐对向量化更友好 |

- **性能结论**：
  - **更看重内存占用、海量 Buffer 池（百万级）**：**24 更优**——少 8 字节/个，缓存能放下更多 Buffer，整体命中率可能更好。
  - **更看重规则 stride、32B 对齐、SIMD/向量化、分配器简单与预留扩展**：**32 更优**——2 的幂、可 32B 对齐，数组上循环更规整，预留 8 字节可做 flags/reserved 而不改 ABI。
- **当前选择**：我们采用 **24 字节**，理由：语义上只需 ptr+len+handle，不浪费；ABI 已锁定且测试覆盖；若未来确需预留或 32B 对齐，可再引入「Buffer32」或新版本 ABI，而非现在为假设预留 8 字节。

---

## 三、自举前需巩固或补齐的项（为压榨性能做准备）

### 3.1 ABI 与零拷贝约定

- **Buffer 与 Slice 关系**：当前 Buffer 为 (ptr, len, handle)，Slice 为 (ptr, len)。自举后「从 Buffer 取可读/可写区间」应为**零拷贝**：即得到 Slice 或 ReadOnlySlice/WriteOnlySlice 时**不拷贝内存**，仅传递指针+长度；若需提交回驱动，仍用 Buffer（含 handle）。
- **自举前动作**：在《高并发 IO 与多平台》中已明确：「Buffer 与 Slice 的互转/视图仅为指针与长度传递，无额外拷贝；handle 仅用于 driver 层」（见该文档 §1）。
- **验收**：✅ 已满足——《[高并发IO与多平台](高并发IO与多平台.md)》§1 与 std.mem/std.io 注释一致。

### 3.2 热路径零分配

- **目标**：自举后**舒 IO**的 submit / completion 路径上，**不强制堆分配**；状态机、Completion、AsyncContext 等可由栈或预分配池表示。
- **自举前动作**：在《高并发 IO 与多平台》中已约定：异步/完成回调不依赖堆分配闭包或 Future；允许栈上状态机 + 固定大小 Completion 队列；可用 C 风格回调 + 外部 Completion 队列接入**舒 IO 完成路径**（见该文档 §3.2）。
- **验收**：✅ 已满足——《[高并发IO与多平台](高并发IO与多平台.md)》§3 含「无分配热路径」与「栈/池化状态机」约定。

### 3.3 批量 / 向量化 I/O 接口不堵死

- **目标**：舒 IO 与高吞吐网络依赖**多段 Buffer 一次提交**；自举后应能暴露 `submit_read(bufs: Buffer[], ...)` 或等价 API。
- **自举前动作**：std.io.driver 注释已写明「预留 Buffer[] 多段扩展」；《高并发IO与多平台》§4 约定批量 I/O 以 Buffer[] 在 driver 层扩展。
- **验收**：✅ 已满足——trait 与 driver 签名不排除多 Buffer 提交；文档已写明。

### 3.4 FFI 与 syscall 零成本（已满足，仅确认）

- 自举后实现舒 IO 时可能调用自研 C 封装、内核模块或 syscall；**ABI 零成本、extern 无额外封送**在自举前性能生死线中已要求并满足。
- **自举前动作**：无新增实现；极致 IO/网络依赖 ABI 与 C 互操作零成本，见《自举前性能与语义基建》§7.1。

### 3.5 高并发 IO 与多平台设计文档（已存在）

- 《自举前必须清单》§2.2（S6）、§2.4（D2）要求：**高并发 I/O 与多平台设计文档**存在，且含零拷贝、超时、Completion、多段 I/O、平台分支、热路径零分配，以及**「如何实现才能超越现有 API」与自举前准备清单**。
- **验收**：✅ 已满足——《[高并发IO与多平台](高并发IO与多平台.md)》已存在，含上述全部内容及 §6（如何超越、自举前准备清单）；自举后实现**舒 IO** 时可直接按该文档扩展。

---

## 四、与自举前性能基建的对应

| 自举前性能与语义基建 | 对极致 IO/网络的作用 |
|----------------------|----------------------|
| **noalias / 零成本抽象** | driver 与内核之间指针传递无别名假设，利于优化与正确性。 |
| **let/mut、只读传递** | 只读缓冲区用 const/ReadOnlySlice 表达，避免误写、利于优化。 |
| **defer 静态内联** | 资源释放零开销，与 C 风格 cleanup 一致，不拖累热路径。 |
| **BCE（边界检查消除）** | 循环内 Buffer/slice 访问在可证明范围内无检查分支，利于吞吐。 |
| **Result 寄存器化** | IO_Result / 错误码返回无内存写，与 completion 路径一致。 |
| **条件编译** | 按 OS/arch 选**舒 IO 各平台实现路径**，用户 API 统一（std.io / std.net）；目标超越 io_uring/kqueue/IOCP。 |
| **内建 / intrinsic 映射** | 将来 memcpy、原子操作等可由内建直通，无额外调用开销。 |

以上在自举前已落地或已约定；自举后实现 IO/网络时**直接复用**，不再为性能补课。

---

## 五、自举前检查表（极致 IO/网络准备）

在启动自举前，可逐项确认「为以后压榨 IO/网络性能」的准备工作。**✅ = 已实现，⬜ = 待实现（接下来要完成）**。

| 序号 | 项 | 状态 |
|------|----|------|
| P1 | Buffer ABI 24 字节（ptr+len+handle）已锁定，与 std.mem / std.io.driver 一致 | ✅ 已实现 |
| P2 | ReadOnlySlice / WriteOnlySlice、超时参数、IO_Result/Completion/AsyncContext 类型与占位存在且稳定 | ✅ 已实现 |
| P3 | 文档中明确「Buffer 与 Slice 零拷贝约定、handle 仅 driver 层」 | ✅ 已实现（《高并发IO与多平台》§1） |
| P4 | 文档中约定「热路径零分配 / 栈或池化状态机」，接口不强制堆分配 | ✅ 已实现（《高并发IO与多平台》§3） |
| P5 | driver 与 trait 不堵死 Buffer[] 批量提交；注释或文档中写明多段 I/O 扩展 | ✅ 已实现（driver 注释已预留 Buffer[]） |
| P6 | 《高并发IO与多平台》或等价文档存在，含零拷贝、超时、Completion、多段 I/O、平台分支及§6「如何超越」 | ✅ 已实现（该文档已存在且含 §6） |
| P7 | ABI 与 C 互操作零成本、Result 寄存器化已满足（自举前性能生死线） | ✅ 已实现 |
| — | **二、表中 2 项**：内核预注册、提交读/写 + 超时（std.io.core .x 桩） | ✅ 已实现 |

全部勾选后，自举后即可在**不推翻现有接口与 ABI** 的前提下，实现**舒 IO**（超越 io_uring/kqueue/IOCP）与高并发网络，把 IO/网络性能压榨到极致。**如何实现才能超越**见《[高并发IO与多平台](高并发IO与多平台.md)》§6。

---

## 六、小结与待实现清单

### 6.1 小结

- **自举前**：锁定 Buffer/Reader/Writer 的 ABI 与扩展方式，约定零拷贝、超时、无分配热路径、多段 I/O 预留；《高并发IO与多平台》已存在，含「如何实现才能超越现有 API」与自举前准备清单（§6），供自举后实现**舒 IO** 时遵循。
- **自举后**：在 .x 内实现**舒 IO**（自研驱动与调度，超越 io_uring/kqueue/IOCP）、completion 队列、批量 submit、网络 accept/connect/read/write，全部基于现有 Buffer、driver 与条件编译，无需改语言或推倒重来。

### 6.2 已完成的实现项

| 类别 | 项 | 说明 |
|------|----|------|
| **二、表中** | 内核预注册 | std.mem.register_buffer、std.io.driver.register 通过 **std.io.core**（.x，Shu IO 核心）的 `shu_io_register` 调用；当前桩返回 0，自举后可在此模块内改为舒 IO 预注册逻辑。 |
| **二、表中** | 提交读/写 + 超时 | std.io.driver.submit_read、submit_write 通过 **std.io.core**（.x，Shu IO 核心）的 `shu_io_submit_read` / `shu_io_submit_write` 调用；当前桩返回 0，自举后可改为真实 I/O 与超时。 |

**P3、P4、P6** 已由《[高并发IO与多平台](高并发IO与多平台.md)》满足。**二、表中 2 项** 已实现（std.io.core .x 桩）。自举前为「舒 IO 超越现有 API」做的准备已全部完成；自举后只需在 **std.io.core** 内替换桩为舒 IO 真实实现即可。
