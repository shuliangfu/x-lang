# 接下来做什么：性能压榨 vs 新 std

> 在测试全部通过、固定参数已支持切片（`*Buffer + n` 等）的前提下，对「继续优化压榨性能」与「开发新 std」两条线做全面分析，并给出执行建议。

---

## 一、当前基线

| 维度 | 状态 |
|------|------|
| **测试** | `run-all.sh` 全过，无 SKIP（含 stdlib-import、vec、defer、goto、runtime、map 等）。 |
| **切片化** | 写死参数已支持切片：`read_batch_fd_buf`/`write_batch_fd_buf`、`register_fixed_buffers_buf`、`stream_read_batch_buf`/`stream_write_batch_buf`、`fs_readv_buf`/`fs_writev_buf`、`udp_recv_many_buf`/`udp_send_many_buf`、`net_batch_max()` 等均已落地（见《写死参数与切片化优化清单》）。 |
| **std.net 压榨** | 阶段 1～5 已完成：io_uring accept/connect、accept_many/connect_many 真批量、[]Buffer 与 net 打通、fixed 注册、UDP recvmmsg/sendmmsg；六「继续压榨」中 CQE 批收、64 批量、run_accept_workers、绑核等已做；multishot accept 为可选预留。 |
| **std.thread** | 零成本抽象、绑核、栈大小、macOS QoS 已实现（见《std.thread性能压榨》）。 |
| **core** | 在当前语言下已齐；mem_copy→builtin、slice unchecked、Option/Result inline 等已做（见《core完善与性能分析》）。 |

**结论**：性能与切片化方面的「必做项」已基本做完；剩余多为**可选深化**或**新能力**。

**与 `NEXT.md` 的同步（2026）：** 当 NEXT §二（time/random/env）已勾选完成后，仓库主推荐的开发顺序以 **NEXT §三（自举 / parser·typeck·codegen `.sx` 化）** 为准；本文 §二「主线 B」中的新 std 仍可穿插交付，但不压住自举主线。**性能专线**仍以 benchmark 或业务瓶颈出现后再定点投入（multishot、编译器 IR 等），见 §三「按需深化」。

---

## 二、两条主线对比

### 2.1 主线 A：继续性能压榨

| 方向 | 内容 | 收益 | 工作量 |
|------|------|------|--------|
| **std.net** | multishot accept（Linux 5.19+ IORING_ACCEPT_MULTISHOT）；阶段 6「换赛道」仅抽象预留/文档，不落 DPDK 实现 | 建连路径再省 syscall；阶段 6 为长期占位 | 小～中（multishot）；大（阶段 6 若真做） |
| **std.thread** | 文档化「零成本」与推荐用法；无必须代码改动 | 心智统一、最佳实践清晰 | 小 |
| **编译器/IR** | 阶段 8 优化与体积（更多内建、DCE 强化、strip）；或 IR 阶段 3 深化 | 生成代码更小更快 | 中～大 |
| **benchmark 与调优** | 对 net/io/vec/string 做定量 benchmark，对标 Zig/C，发现新瓶颈再压榨 | 数据驱动，避免空转 | 中 |

**特点**：边际收益递减；当前栈已在「内核 socket + io_uring + 批量化」下做到文档中的量级（建连数万～十几万/秒、TCP 数 Gbps、UDP 数十万 PPS、百万并发连接可行）。再往上要么是**可选优化**（multishot），要么是**换赛道**（DPDK/内核 bypass），要么是**编译器/后端**的长期投入。

### 2.2 主线 B：开发新 std

| 方向 | 内容 | 收益 | 工作量 |
|------|------|------|--------|
| **标准库丰富** | 与目标「标准库要丰富」直接对齐；用户写业务更顺手，不重复造轮子。 | 提升「开发上比 C 简单太多」、生态与自举可选依赖。 | 按模块，单模块小～中 |
| **自举与工具链** | 自举前清单中 std 已满足最小（io/net/fs/process/string/vec/heap/map 等）；新 std 不阻塞自举，但可让「用 .sx 写编译器」时更舒服。 | 自举时少写 C 或少造临时工具。 | 视模块而定 |
| **候选模块（示例）** | **std.time**：单调时间/墙上时钟、sleep（可薄封装 C）；**std.env**：getenv 已在 process，可独立成 std.env 或扩 process；**std.random**：最小 API（如 fill_bytes、u32）；**std.encoding**：utf8 编解码最小集；**std.crypto**：仅哈希/常量时间比较等轻量接口（可选）。 | 覆盖常见需求；保持「轻量、按需链接」。 | 每个模块小～中 |

**特点**：每条都是**可独立交付**的增量；不破坏「轻量级」前提下，直接推进「标准库要丰富」和「开发简单」。

---

## 三、建议：优先新 std，性能做「按需深化」

> **档期说明：** 本节写于 NEXT §二 std 条目尚未全部完成之时。若仅以 **NEXT.md 当前勾选** 为准，则 **编译自举（§三）应与「新 std 小步」并联**：新 std（encoding、crypto 等）仍可依下表做小模块，但不宜长期占用本应投入 parser/typeck/codegen `.sx` 化的带宽；性能仍遵循 §3.2 的「按需」。

### 3.1 理由简述

1. **宗旨与目标**  
   - 宗旨是「极致压榨性能」**与**「代码可维护、开发简单易上手」并重；「标准库要丰富」是明确目标。  
   - 当前性能与切片化已到「文档规划」水平，继续压榨多为可选或长期项；而「丰富 std」每做一个模块就多一块能力，收益可见。

2. **边际收益**  
   - 性能：再压榨需要要么上 multishot/DPDK/后端优化，要么先有 benchmark 再定向优化，更适合**有明确瓶颈或目标指标时**再做。  
   - 新 std：每增加一个最小可用模块（如 time/random/env），都能立刻被业务或自举路径用到，边际收益清晰。

3. **风险与依赖**  
   - 新 std 模块通常依赖现有 core + std.io/fs/process 等，不改变现有架构；性能深化则可能动 io/net 或编译器，影响面更大。  
   - 先丰富 std，再在「用户真实用法」上做 benchmark 和针对性优化，顺序更稳。

### 3.2 推荐执行顺序（高 level）

| 优先级 | 建议 | 说明 |
|--------|------|------|
| **P0** | **新 std 模块（小步快跑）** | 先选 1～2 个最小可用模块（如 **std.time**、**std.random**），实现最小 API、文档与测试，再按需加 std.env / encoding 等。 |
| **P1** | **性能与压榨「按需做」** | 若你做 benchmark 或业务遇到 net/io 瓶颈，再开 multishot、或局部调优；阶段 6 保持「文档+抽象预留」即可。 |
| **P2** | **编译器/自举** | 与《下一步开发分析》一致：自举与 .sx 迁移、build_tool 为默认等按既有阶段推进；新 std 不阻塞，且可为自举提供更好工具。 |

---

## 四、若选「新 std」：建议的首批模块

- **std.time**  
  - 最小 API：单调时间（如 `now_monotonic_ns()`）、墙上时钟（如 `now_wall_sec()`）、`sleep_ms(n)`；底层可 extern C（clock_gettime、gettimeofday、nanosleep 等）。  
  - 与 core 无新依赖；与 std.process 并列，不增加体积负担。

- **std.random**  
  - 最小 API：如 `fill_bytes(buf: *u8, n: i32)`、`u32()`；底层可 extern C（getentropy、getrandom 或平台等价）。  
  - 不依赖 io/net；按需链接即可。

两者都符合「轻量、全平台一套 API、内部条件编译」的约定；做完即可在文档与示例中标注「推荐下一步：std.env、std.encoding 等」。

---

## 五、若选「继续压榨」：建议的聚焦点

- **短期可做**  
  - 为 std.net 增加 **multishot accept** 可选路径（Linux 5.19+），文档注明平台与内核要求。  
  - 为 std.thread / std.net 写一段「性能与多核用法」最佳实践（含绑核、run_accept_workers、batch 读写）。

- **中期按需**  
  - 对 std.net / std.io / std.vec 做**定量 benchmark**（建连 QPS、吞吐、PPS），与 Zig/C 对照，再决定是否上 multishot 或调 buffer/批大小。  
  - 阶段 8 优化与体积：更多内建识别、DCE 强化、strip 与体积报告。

- **长期预留**  
  - 阶段 6（DPDK/内核 bypass）保持「抽象预留 + 文档」，不落具体实现与构建依赖。

---

## 六、总结

- **当前**：测试全过、切片化与 net/thread/io 的主线压榨已到位，性能与「写死参数」的优化告一段落。  
- **建议**：**优先做新 std（如 std.time、std.random）**，性能压榨改为「按需深化」+ 可选 multishot + benchmark 驱动。  
- **这样**：既继续推进「标准库要丰富」和「开发简单」，又为后续在真实用法上再做性能优化留出清晰入口；自举与编译器演进可继续按《下一步开发分析》和《完全自举-无C无Makefile》推进。
