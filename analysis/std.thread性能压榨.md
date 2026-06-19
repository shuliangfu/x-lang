# std.thread 性能压榨

> 在满足多核易用（与 std.net 多 worker、每线程一 io_uring 配合）的前提下，把 std.thread 做成零成本抽象，不引入额外运行时与热路径开销。

---

## 一、定位与原则

| 原则 | 含义 |
|------|------|
| **零成本抽象** | API 与 OS 原语 1:1：thread_create → pthread_create / CreateThread，thread_join → pthread_join / WaitForSingleObject，无中间层、无隐式分配（见下例外）。 |
| **多核压榨** | 与 std.net 配合时：每线程一个 io_uring，spawn N 个线程即可跑满 N 核；不内置线程池，池化由上层（如 listen_workers）或用户实现。 |
| **不引入运行时** | 无 GC、无任务队列、无调度器；仅提供 spawn/join/self，与 C 的 pthread 使用方式一致。 |

---

## 二、当前实现与成本

| 路径 | 成本 | 说明 |
|------|------|------|
| **thread_self** | 零 | 直接映射 pthread_self() / GetCurrentThreadId()，无分配、无锁。 |
| **thread_create（POSIX）** | 零 | pthread_create(entry, arg)，arg 直接传指针，无额外分配。 |
| **thread_create（Windows）** | 一次 malloc/free | CreateThread 只接受单参数，需把 (entry, arg) 打包；当前在堆上分配小结构体，子线程入口中 free。这是 **API 语义** 下的必要成本，无法在保持「双参数入口」的同时去掉。 |
| **thread_join** | 零 | 直接映射 pthread_join / WaitForSingleObject + CloseHandle，无分配。 |

**结论**：POSIX 路径已零成本；Windows 路径仅在 spawn 时有一次小块分配，属设计使然，可接受。

---

## 三、可选压榨点（按需做）

### 3.1 线程亲和（绑核）✅

- **目标**：多核场景下，将 worker 线程绑定到指定 CPU，减少迁移与缓存抖动。
- **实现**：可选 API `thread_set_affinity(thread_id, cpu_index)` 或 `thread_set_affinity_self(cpu_index)`；底层 pthread_setaffinity_np / SetThreadAffinityMask。
- **收益**：与 std.net 多 worker 配合时，每核固定一 uring、一线程，可预测延迟与更高吞吐。
- **已实现**：`thread_set_affinity_self(cpu_index: i32): i32`、`thread_set_affinity(thread_id: i64, cpu_index: i32): i32`；**Linux** 用 pthread_setaffinity_np，**Windows** 用 SetThreadAffinityMask；**macOS** 内核不支持绑核（KERN_NOT_SUPPORTED），返回 -1，可用 `thread_set_qos_class_self` 提升调度优先级作为替代。

### 3.2 栈大小（可选）✅

- **目标**：thread_create 若支持「指定栈大小」，可避免默认大栈带来的内存占用；多 worker 时每线程默认常为 8MB，若指定 256KB～512KB 可大幅省内存。
- **实现**：`thread_create_with_stack(entry, arg, stack_size: usize)`，0 表示默认；底层 pthread_attr_setstacksize / CreateThread 的 dwStackSize。
- **已实现**：`thread_create_with_stack(entry, arg, stack_size)`；stack_size==0 用默认栈，否则用指定字节数（POSIX pthread_attr_setstacksize，Windows CreateThread 第四参）。

### 3.2.1 macOS 无法绑核时的性能替代 ✅

- **目标**：Apple Silicon 上内核不支持线程亲和，无法绑核；通过 **QoS（Quality of Service）** 提升 worker 线程调度优先级，减少与后台任务竞争。
- **实现**：`thread_set_qos_class_self(qos_class: i32): i32`；仅 macOS 有效，0=default，1=user_interactive，2=user_initiated，3=utility，4=background；worker 建议传 2（user_initiated）。底层 pthread_set_qos_class_self_np。
- **已实现**：C 层 thread_set_qos_class_self_c；非 macOS 调用返回 -1。

### 3.3 不做的「压榨」

- **线程池**：池化属于上层抽象（如 std.net 的 listen_workers 或用户自己的 pool），std.thread 只提供原语，避免隐藏队列与调度成本。
- **Futures/async**：当前不做；若日后做，应在单独模块且不增加 spawn/join 的热路径成本。

---

## 四、与 Zig / Rust 对比

| 维度 | Zig std.Thread | Rust std::thread | 我们 |
|------|----------------|------------------|------|
| **spawn 成本** | 薄封装 OS，有栈分配等 | 有栈与 guard 等封装 | 直接 pthread/CreateThread，POSIX 零分配 |
| **线程池** | 无内置 | 有 std::thread::spawn 等，池在库或生态 | 不内置，池化由上层做 |
| **亲和** | 需平台 API | 需第三方或 platform 库 | 可选 thread_set_affinity 即可 |

**结论**：std.thread 已满足「零成本 + 多核易用」；进一步压榨以**可选**绑核、文档化为主，不增加默认路径成本。

---

## 五、还可继续压榨的方向

| 方向 | 收益 | 状态 |
|------|------|------|
| **3.2 栈大小** | 多 worker 时省内存（每线程可 256KB 而非默认 8MB） | ✅ 已实现 `thread_create_with_stack` |
| **macOS 绑核** | Apple Silicon 上也能绑核 | ❌ 内核不支持；✅ 已用 QoS `thread_set_qos_class_self` 作替代提升调度 |
| **创建时绑核（可选）** | 新线程一起跑就在指定核，少一次 set_affinity 调用 | 可选；Linux 可用 pthread_attr_setaffinity_np + pthread_create 扩展 |

---

## 六、实现顺序建议

1. **保持现状**：当前 spawn/join/self 已达标。✅
2. **可选**：增加 `thread_set_affinity_self(cpu_index)`（或带 thread_id 版本），供多 worker 绑核时使用。✅ 已实现。
3. **文档**：在 README 中注明「零成本、Windows 仅 spawn 时一次 malloc」，与本文档衔接。✅
4. **继续压榨**：栈大小 `thread_create_with_stack`（多 worker 省内存）。✅ 已实现。macOS 绑核：Apple Silicon 内核不支持，不实现。
