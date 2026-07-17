# 无 libc 基础现状与 `--libc` 开关分析

> **日期**：2026-07-17  
> **范围**：产品路径 `shux` / `shux_asm`、标准库 `std/`、链接 ABI、自举终局（F-no-libc / 阶段 G）  
> **结论先行**：  
> 1. **用户程序 Linux freestanding 底座已有雏形且门禁化**（`-freestanding` + `std.sys` + `page_mmap` + 若干 NL gate）；  
> 2. **编译器本体与默认产品链仍深度依赖 libc**（Ubuntu 产品 `shux` 仍 `ldd` → `libc.so.6`）；  
> 3. **自举完成后再「一刀切」无 libc 风险大**——不是做不到，而是债面已分层，越晚切爆炸半径越大；  
> 4. **不建议**把「默认有 libc、加参数才 freestanding」作为终局默认；更合理的是 **默认 hosted（现状）/ 显式 freestanding（已有 `-freestanding`）**，若要对称可再加 **`--hosted` 或 `--libc` 作显式兼容模式**，但需先定义权威门面，禁止双权威。

---

## 0. 先分清三层目标（否则永远吵不清楚）

| 层级 | 含义 | 当前状态（2026-07-17） |
|------|------|------------------------|
| **L0 语义自举** | 用产品 `shux_asm` 冷编译自己 + 全量 bstrict | 双端 tip 已绿（mac + Ubuntu 123 scripts） |
| **L1 用户 freestanding** | 用户 `.x` 可 `-freestanding -backend asm` 出 **nostdlib、无链 `-lc`** 的静态可执行文件（Linux x86_64 金标） | **NL-05 等 gate ✅**；std 首批发 NL-06 🟡 |
| **L2 编译器 / bootstrap 零 libc** | `shux_asm` 自身 `ldd` 无 `libc.so`、bootstrap `-nostdlib` 硬绿 | **未达**（Ubuntu 产品 `shux` 仍动态依赖 `libc.so.6`）；NL-07 / G-03 🟡 track |

「我们要实现无 libc」在路线图里同时指 **L1 + L2**。本文按这两层分别评估。

参考：`NEXT.md` §9.5 F-no-libc、§10 阶段 G；`README_zh-CN.md` freestanding 说明。

---

## 1. 现在有没有「按无 libc 写好基础」？

### 1.1 已经写好的（可当作底座）

**（1）OS 门面与 syscall 路径（权威：`std.sys`）**

- `std/sys/mod.x`：上层只 `import("std.sys")`，按 `target_os` 分流。
- Linux：`os_write` → `shux_sys_write` 等 freestanding 桩；文档写明 **Linux freestanding 拒绝 libc 脐带**。
- macOS / FreeBSD / Windows：常规路径仍可走 libc / 平台 API（hosted）。
- 已有 gate：`run-linux-syscall-invoke-gate.sh`、`run-b04-freestanding-syscall-gate.sh` 等。

**（2）无 malloc 的堆路径（权威：`std.heap.page_mmap`）**

- `std/heap/page_mmap.x`：Linux freestanding **匿名 mmap bump**，直接 extern `shux_sys_mmap` / `munmap`，**不链 `heap.c`、不调 `malloc`**。
- 限制 v1 明确：单块映射、free 为 no-op、不自动扩容——这是 freestanding 最小可用，不是通用分配器终局。

**（3）用户链接开关：`-freestanding`（已存在）**

- driver：`rt_compile.x` 解析 `-freestanding` → `driver_freestanding_set` / `cfg_set_freestanding`。
- 链接：`runtime_link_abi.x` 中 `shux_link_freestanding_enabled`、`shux_ensure_freestanding_io_o`、`shux_asm_nostdlib_minimal_selfcontained_exe_link` 等。
- 非 Linux 显式 unsupported 诊断：`link_diag_freestanding_unsupported`。
- 用户路径链接审计：**NL-05** `run-no-libc-link-gate.sh`（用户 `-freestanding` 无 `-lc`）✅。

**（4）std 源码侧「零手写 C」**

- 阶段 **F-ZC**：`std/` 下 **0 个 `.c`/`.h`**（v1 闭合）。  
  这是「无 C 源码」，**不等于**「运行时无 libc」。

**（5）按需双路径雏形**

| 能力 | hosted（默认产品） | freestanding（Linux 用户路径） |
|------|-------------------|-------------------------------|
| 堆 | `std.heap.libc` → `malloc/free/...` | `std.heap.page_mmap` → mmap bump |
| 文件 | `std.fs.posix` → libc FFI | `std.fs.freestanding_linux` → `std.sys` |
| 写 fd | macOS libc `write` 等 | Linux `shux_sys_write` |
| 启动 | 平台 crt / 动态链接器 | `crt0_*` + `-nostdlib` 路径 |

这是 **分层门面** 的正确方向，但 **默认产品路径仍是 hosted+libc**。

### 1.2 还没写好 / 仍捆在 libc 上的（不能自欺）

**（1）产品编译器二进制本身**

- Ubuntu tip 产品 `compiler/shux`：`ldd` 仍见 **`libc.so.6`**（动态链接、非 nostdlib）。
- mac 产品链 `libSystem`（含 libc 语义）。
- g05 链接：Linux `-no-pie -e _start -nostartfiles` **但仍会经 runtime 链入依赖 libc 的对象**；默认 **未** 做到 NL-07「`ldd` 无 libc」。

**（2）编译器 runtime / seed 大量 libc 契约**

非穷举，代表类：

| 区域 | 依赖形态 |
|------|----------|
| `runtime_heap_user.x` / `lsp_io_std_heap.x` | `extern malloc/free` |
| `runtime_io_abi` | `runtime_read_file_malloc` 等 |
| `runtime_driver_diagnostic*` | `snprintf` / stdio 风格诊断 |
| `runtime_pipeline_abi` | `stdio.h` / `string.h`；预处理 `malloc` 缓冲 |
| `labi_invoke_ld_list.x` | 用户/工具链链接参数列表含 **`-lc`** |
| 诊断 / 文件 IO 热路径 | `fopen`、`fwrite`、`getenv` 等 C 运行时 |

**（3）标准库默认入口仍偏 libc**

- `std.heap` 默认叙事与 typed alloc 主路径仍 **`heap_libc`**；page_mmap 是 Linux freestanding 旁路。
- `std.fs` 默认 POSIX libc FFI；`freestanding_linux` 是 cfg / 专用模块。
- `std.net` / TLS（openssl/mbedtls）等 **天然 hosted**，freestanding 只覆盖子集。

**（4）F-no-libc 路线图自身状态**

| 编号 | 项 | 状态（NEXT.md） |
|------|----|-----------------|
| NL-02～05 | socket 桩 / fs / 用户链接无 `-lc` | ✅ |
| NL-06 | freestanding std 首批发 | 🟡 |
| NL-07 / G-03 | **bootstrap nostdlib 硬绿** | 🟡 track，**产品默认未达** |

### 1.3 一句话判断

> **基础「有」但只覆盖「用户 Linux freestanding 最小世界」；产品编译器与默认 std 入口仍是 libc hosted 世界。**  
> 不能说「已经按无 libc 写完了」——只能说「**L1 的骨架和门禁在，L2 还没硬绿**」。

---

## 2. 自举完成后再改成无 libc，会不会有很大问题？

### 2.1 什么叫「自举完成」

当前 tip 语义自举（L0）已在双端 bstrict 硬绿。路线图里的「完全自举终局」还包含 **阶段 G（物理删手写 C/H + bootstrap 零 libc + build.x）**。  
若「自举完成」= **仅 L0**，再做 L2：问题 **大**。  
若「自举完成」= **G 闭合**，那无 libc 本就是 G 的验收项，不是「之后再改」。

### 2.2 晚切的主要风险（按爆炸半径）

| 风险 | 为什么大 | 典型触点 |
|------|----------|----------|
| **双权威硬化** | hosted 与 freestanding 两套堆/IO 长期并存，语义漂移 | `heap.libc` vs `page_mmap`；`fs.posix` vs `freestanding_linux` |
| **编译器热路径绑死 malloc** | seed/runtime 以「总能 malloc」写逻辑，改 freestanding 需整段重写 | 预处理缓冲、读文件、diag、LSP heap |
| **链接图假设 -lc** | UNDEF 列表、弱符号、g05 过滤导出表都按「有 libc」收敛 | Darwin filtered pipeline 已多次暴露「符号可见性」类问题 |
| **测试矩阵分裂** | 全量 bstrict 默认 hosted；freestanding 另有 gate，假绿空间大 | mac 过、Linux nostdlib 红 |
| **第三方/FFI** | openssl/mbedtls/sqlite 等 **不能** freestanding 默认 | 必须永远是 opt-in hosted |
| **平台不对称** | freestanding 金标是 **Linux x86_64**；mac 产品路径本就 libSystem | 「全平台无 libc」不现实，需明确定义 Linux 金标 |

### 2.3 晚切「不是灾难」的条件（若不得不晚）

若坚持 L0 优先、L2 后置，必须 **现在** 守住：

1. **单一权威门面**：所有堆/文件/写 fd 只经 `std.heap` / `std.fs` / `std.sys`，禁止业务直接 `extern malloc`/`write`。  
2. **链接审计常青**：用户路径保持 NL-05；bootstrap 路径保留 NL-07 track，**禁止**用 `SHUX_BOOTSTRAP_ALLOW_LIBC` 当假绿。  
3. **新代码禁增 libc 脐带**：compiler `.x` 新逻辑不得新增 `stdio`/`malloc` 依赖而不走门面。  
4. **双路径同测**：任何 SHARED 堆/IO 改动，至少 Linux freestanding 烟测 + hosted bstrict。

**没有以上纪律，自举后再无 libc ≈ 二次重写编译器 runtime。**

### 2.4 推荐节奏（与 NEXT.md 一致）

```
L0 语义自举（已绿） ──并行──► L1 用户 freestanding 扩 std（NL-06）
         │
         └──────────► L2 编译器 bootstrap nostdlib（NL-07 / G-03）
                              │
                              ▼
                    阶段 G 物理零 C + build.x
```

**不要等「完全自举再做 F-no-libc」**——NEXT.md §10 已写明：**不要等**，G 与 F-no-libc **并行**。

---

## 3. 有没有必要加 `--libc` 开启兼容 libc？

### 3.1 现状已有的开关

| 开关 | 作用 | 默认 |
|------|------|------|
| **无开关（默认 hosted）** | 常规 `-o` / 产品链，链 libc / libSystem | **是** |
| **`-freestanding`** | Linux x86_64 nostdlib 用户路径 | 否（opt-in） |
| 环境变量（如 bootstrap allow libc） | 调试/过渡假绿出口 | 应收敛、禁止当验收 |

也就是说：**兼容 libc 的模式已经是默认**；缺的不是「开启 libc」，而是 **默认何时切到无 libc**。

### 3.2 三种产品语义对比

| 方案 | 默认 | 显式开关 | 评价 |
|------|------|----------|------|
| **A. 现状** | hosted + libc | `-freestanding` → 无 libc | 清晰；与 Zig 的「hosted 默认、freestanding 显式」同类 |
| **B. 默认 freestanding + `--libc`/`--hosted` 兼容** | 无 libc | 开 libc | 符合「终局是无 libc」叙事；**破坏面大**（现有 bstrict/用户脚本/mac 产品） |
| **C. 默认 hosted + 同时提供 `-freestanding` 与 `--libc`（冗余）** | hosted | 两者都写 | **易双权威**；不推荐 |

### 3.3 建议（可执行）

**短期（现在～NL-07 硬绿前）**

- **不要**为了「听起来对称」立刻加 `--libc` 当主开关。  
- **保留并强化** `-freestanding` 为用户无 libc 的唯一权威入口。  
- 默认继续 hosted（保证 mac + Ubuntu 产品/bstrict 稳定）。

**中期（NL-07 / G-03 接近硬绿）**

- 可引入 **显式** `--hosted` 或 `--libc`，语义 =「强制走 libc 兼容层」，用于：  
  - 依赖 openssl/sqlite 的用户程序；  
  - 调试；  
  - 过渡文档与 CI 矩阵中的「兼容轴」。  
- 规则：  
  - `--libc` 与 `-freestanding` **互斥**；  
  - 默认仍 hosted **或**（若已默认 freestanding）无开关 = freestanding；  
  - **禁止**第三套堆实现——只切换 `std.heap` / `std.fs` 后端选择。

**不推荐**

- 默认 freestanding 却未过 NL-07，导致「自举绿、产品却链不上」的假进度。  
- 在 codegen/runtime 里 `if (libc) … else …` 散落多处——违反「禁止双权威 / 禁止功能重复实现」。

### 3.4 `--libc` 若要做，最小权威设计

```
用户 flags
  ├─ (default) hosted  → link -lc / libSystem；std.heap.libc；std.fs.posix
  ├─ -freestanding     → Linux only；nostdlib；page_mmap；freestanding_linux
  └─ --libc / --hosted → 显式 hosted（与 default 同后端；仅当 default 将来改 freestanding 时有独立价值）
```

链接侧单一函数（概念上）：

- `link_select_runtime_profile(freestanding, force_libc) → HOSTED | FREESTANDING`  
- 下游只认 profile，不二次解析 argv。

---

## 4. 问题地图（上帝视角：产生 / 存储 / 消费）

| 层 | 产生 | 存储 | 消费 |
|----|------|------|------|
| 用户程序 | `.x` 源 + import std | `.o` + 可执行文件 | OS；是否依赖 libc.so |
| std 门面 | `std.sys` / `std.heap` / `std.fs` | 符号与 cfg 分支 | 用户与编译器 dogfood |
| 编译器 runtime | seed + `.x` glue | `shux`/`shux_asm` 二进制 | 解析/typeck/codegen/链接 |
| 链接 ABI | `runtime_link_abi` / g05 | 链接命令行与过滤符号表 | ld；`-lc` 是否出现 |
| 验收 | gate scripts | CI / bstrict | 是否假绿 |

**根因层**：若 freestanding 只改「用户链接」、不改「编译器 runtime 分配/IO」，则 **L2 永远假绿**。

---

## 5. 平台边界（强制标注）

| 平台 | 无 libc 现实 | 说明 |
|------|--------------|------|
| **Linux x86_64** | **金标** | syscall + crt0 + nostdlib 完整路径；验收以 `ldd` 无 libc 为准 |
| **Linux aarch64** | 部分 | syscall 表/桩需对齐，勿默认与 x86_64 同绿 |
| **macOS** | **不追求「无 libSystem」** | 产品可仍链 libSystem；freestanding 开关可 unsupported 或极窄子集 |
| **Windows** | hosted | CRT / Win32；无 libc 叙事不套用 POSIX freestanding |

**SHARED 纪律**：改 `std.heap` / 链接 ABI 的 SHARED 逻辑，必须双端想清楚——**不能把 mac 的「链 libSystem 绿」当成 Linux 零 libc 已过**。

---

## 6. 验收清单（可写进门禁）

### 6.1 用户 L1（应保持常青）

```bash
# Linux x86_64
./tests/run-no-libc-link-gate.sh
./tests/run-no-libc-fs-gate.sh
./tests/run-freestanding-hello.sh
# 可选
./tests/run-no-libc-socket-gate.sh
```

### 6.2 编译器 L2（终局）

```bash
# 产品二进制无 libc.so（Linux）
ldd compiler/shux_asm | tee /tmp/ldd_shux.txt
! grep -q libc.so /tmp/ldd_shux.txt

# NL-07 / bootstrap nostdlib
./tests/run-nolibc-n07-v5-gate.sh   # 以仓库 tip 定义为准
```

### 6.3 回归不破坏 hosted

```bash
# 双端
./tests/run-all-bstrict.sh   # 默认 hosted 全量
```

---

## 7. 决策建议（给产品/自举主线）

1. **承认现状**：L1 骨架 ✅，L2 未硬绿；产品 `shux` 仍依赖 libc。  
2. **不要赌「自举后再无 libc」**：会放大双权威与 runtime 重写成本；与 NEXT.md「G 与 F-no-libc 并行」一致。  
3. **开关策略**：  
   - **现在**：强化 `-freestanding`；默认 hosted。  
   - **以后**（默认若改 freestanding）：再引入 `--libc`/`--hosted` 作兼容轴。  
   - **现在单独加 `--libc` 且默认仍 hosted**：价值低，易造成「两个开关都表示有 libc」的文档债。  
4. **工程铁律**：同一功能只保留 **一个权威后端选择点**；seed 与 `.x` 同步；禁止热路径 `if (特例 libc)` 糊绿。  
5. **范围诚实**：终局「无 libc」= **Linux 金标编译器与用户程序**；mac/Windows 是 hosted 兼容平台，不假装物理零系统库。

---

## 8. 与本周 tip 工作的关系

- 本周双端 bstrict / AL-06 修复属于 **L0 产品正确性**，**不替代** F-no-libc 硬绿。  
- 继续主线时建议并行保留：  
  - 任意 SHARED 堆/IO/链接改动 → 至少跑一条 Linux freestanding gate；  
  - 谈「自举完成」时在文档中写清是 **L0** 还是 **L0+L1+L2**。

---

## 9. 参考路径

| 路径 | 内容 |
|------|------|
| `NEXT.md` §9.5 / §10 | F-no-libc、阶段 G |
| `std/sys/mod.x` | OS 门面 |
| `std/heap/page_mmap.x` / `std/heap/libc.x` | 双堆后端 |
| `std/fs/freestanding_linux.x` / `posix.x` | 双 FS 后端 |
| `compiler/src/runtime/rt_compile.x` | `-freestanding` 解析 |
| `compiler/src/runtime_link_abi.x` | freestanding / nostdlib 链接 |
| `tests/run-no-libc-*.sh` / `run-nolibc-n07-*.sh` | 验收 |
| `Agents.md` | 根源治理、禁止双权威、平台标注 |

---

*文档状态：分析 / 决策参考；非实现清单。实现以 gate 变绿与 `ldd` 为准，不以叙事为准。*
