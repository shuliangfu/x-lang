# 零 libc 产品策略（Linux 金标）

> **日期**：2026-07-17（产品决议重写）  
> **旧名**：`无libc基础与-libc开关分析.md`（已废止；**不再**讨论 `--libc` 兼容开关）  
> **范围**：产品路径 `shux` / `shux_asm`、标准库 `std/`、链接 ABI、自举终局（F-no-libc / 阶段 G）  
> **产品决议（强制）**：  
> 1. **目标就是零 libc 依赖**——不是「默认有 libc、加参数才 freestanding」的终局叙事。  
> 2. **不提供、不实现、不规划 `--libc` / `--hosted` 兼容开关**——不需要。  
> 3. 用户路径权威入口仍是 **`-freestanding`**（Linux x86_64 nostdlib）；**禁止**再开第二套「开 libc」CLI。  
> 4. 编译器本体 / bootstrap **以 NL-07 → G-03 硬绿为门禁**（`ldd` 无 `libc.so`）；残债按层消，**禁止**用 `ALLOW_LIBC` 当验收假绿。

---

## 0. 三层目标（验收用语）

| 层级 | 含义 | 状态（2026-07-17） |
|------|------|--------------------|
| **L0 语义自举** | 产品 `shux_asm` 冷编译自己 + 全量 bstrict | 双端 tip 已绿（钉盘见 `自举进度.md`） |
| **L1 用户零 libc** | 用户 `.x` 经产品路径出 **nostdlib、无 `-lc`** 的静态可执行文件（Linux x86_64） | **NL-05 等 gate ✅**；std 首批发 NL-06 🟡 |
| **L2 编译器 / bootstrap 零 libc** | `shux_asm` 自身无动态 `libc.so`、crt0 bag nostdlib **无 UNDEF** | **进行中**：NL-07 **L1–L3b** 已关（multi / fflush / `backend_enc` / `backend_emit`）；crt0 bag unique UNDEF≈147（head driver/typeck）→ **L4+**；G-03 未硬绿 |

「实现无 libc」= **L1 + L2 都硬绿**。L0 绿 **不能** 单独写成「无 libc 已完成」。

参考：`NEXT.md` §9.5 F-no-libc、§10 阶段 G；`analysis/phase-f-n07-v4.md` 分层 residual；`README_zh-CN.md` freestanding 说明。

---

## 1. 已经写好的零 libc 底座

### 1.1 OS 门面与 syscall（权威：`std.sys`）

- `std/sys/mod.x`：上层只 `import("std.sys")`，按 `target_os` 分流。
- Linux：`os_write` → `shux_sys_write` 等 freestanding 桩；**拒绝 libc 脐带**。
- Gate：`run-linux-syscall-invoke-gate.sh`、`run-b04-freestanding-syscall-gate.sh` 等。

### 1.2 无 malloc 的堆（权威：`std.heap.page_mmap`）

- `std/heap/page_mmap.x`：Linux **匿名 mmap bump**，extern `shux_sys_mmap` / `munmap`，**不链 `heap.c`、不调 `malloc`**。
- v1 限制：单块映射、free 为 no-op——最小可用，不是通用分配器终局。

### 1.3 用户链接：`-freestanding`（唯一用户侧无 libc 入口）

- driver：`rt_compile.x` → `driver_freestanding_set` / `cfg_set_freestanding`。
- 链接：`runtime_link_abi.x` 中 freestanding / nostdlib 路径。
- **NL-05** `run-no-libc-link-gate.sh`：用户 `-freestanding` 无 `-lc` ✅。
- **禁止**再加 `--libc` 与之对称；有 libc 的过渡态只允许 **实现层尚未清完的 residual**，不是产品开关。

### 1.4 其它已闭合底座

| 项 | 说明 |
|----|------|
| F-ZC | `std/` 下 **0** 个 `.c`/`.h`（无 C **源码** ≠ 运行时已无 libc） |
| freestanding_io | `freestanding_io_x86_64.s`：`shux_sys_*` syscall 薄层 |
| bootstrap stubs | `bootstrap_nostdlib_stubs`：nostdlib 链 stdio/string 等最小桩（**仅** bootstrap 入链；含 NL-07 L2 `fflush`） |
| crt0 | `crt0_x86_64.s`：`_start` → main_entry；exit 路径经 `bootstrap_flush_stdio_and_exit` |

### 1.5 仍捆在 libc 上的 residual（诚实）

| 区域 | 现状 |
|------|------|
| 产品编译器二进制 | Ubuntu 默认 g05 产品链 historically 仍可能动态依赖 libc；**目标** = 静态/无 `libc.so`（NL-07 / G-03） |
| compiler runtime / seed | 大量 `malloc` / `stdio` / `snprintf` / 读文件缓冲等 **契约债** → 须迁门面或 nostdlib 桩，**禁止**新增裸 libc 脐带 |
| `labi_invoke_ld` 等 | 链接参数表仍可能出现 `-lc` 的 hosted 遗留 → 按需审计，默认产品向零 libc 收敛 |
| std 默认入口叙事 | 部分模块仍有 `heap.libc` / `fs.posix` **实现**；产品策略上 Linux 金标 **优先** page_mmap / freestanding_linux / `std.sys`，**不**再规划「开 `--libc` 选 libc 后端」 |
| 第三方 FFI | openssl / mbedtls / sqlite 等 **永不**进默认 freestanding 内核；需要时是 **可选依赖模块**，不是编译器 `--libc` 开关 |

### 1.6 一句话

> **底座骨架在（L1 + NL-07 分层推进）；L2 编译器零 libc 未硬绿。**  
> **产品策略已定为零 libc，不是「先自举完再决定要不要无 libc」。**

---

## 2. 为什么现在就定死「零 libc」（不晚切、不加 `--libc`）

### 2.1 晚切的代价

| 风险 | 说明 |
|------|------|
| 双权威硬化 | `heap.libc` vs `page_mmap` 长期并列 → 语义漂移 |
| runtime 绑死 malloc | seed/热路径「总能 malloc」写死 → 二次重写 |
| 链接图假设 `-lc` | UNDEF / 导出表 / g05 过滤按有 libc 收敛 → mac 假绿 Ubuntu 红 |
| 开关债 | `--libc` 会制造第二套产品语义，与「直接无依赖」决议冲突 |

### 2.2 纪律（现在就必须守）

1. **单一权威门面**：堆/文件/写 fd 只经 `std.heap` / `std.fs` / `std.sys`（及已登记的 freestanding 后端），禁止业务/compiler 新代码裸 `extern malloc`/`write`。  
2. **链接审计常青**：用户 NL-05；bootstrap NL-07 track；**禁止** `SHUX_BOOTSTRAP_ALLOW_LIBC` 当验收绿。  
3. **新代码禁增 libc 脐带**：compiler `.x` 新逻辑不得新增 stdio/malloc 依赖而不走门面或 nostdlib 桩。  
4. **一条债一层**：NL-07 硬绿按拓扑 → stdio → backend_enc → backend_emit → typeck/driver companion（见 `phase-f-n07-v4.md`）。  
5. **G.7**：同一能力一个权威实现；**不**为 libc 兼容再开平行函数树。

### 2.3 推荐节奏

```
L0 语义自举（已绿） ──并行──► L1 用户零 libc 扩 std（NL-06）
         │
         └──────────► L2 编译器 bootstrap nostdlib（NL-07 分层 → G-03）
                              │
                              ▼
                    阶段 G 物理零 C + build.x
```

**不要等「完全自举再做 F-no-libc」**——与 `NEXT.md` §10「G 与 F-no-libc 并行」一致。  
**不要**用「加 `--libc` 兼容」缓冲——产品不需要该开关。

---

## 3. 开关策略（已决议）

| 项 | 决议 |
|----|------|
| **用户无 libc** | 唯一 CLI：**`-freestanding`**（Linux x86_64 金标） |
| **`--libc` / `--hosted`** | **不做**；文档与实现均 **禁止** 新增 |
| **默认 hosted + 可选 freestanding** | **不是终局叙事**；过渡期允许实现 residual，验收与路线图以 **零 libc 硬绿** 为准 |
| **bootstrap 调试回退** | 构建脚本里的 `ALLOW_LIBC` 等 **仅工程逃生舱**，**永不**写进产品 CLI / 用户手册验收 |

链接侧只认 **一个** runtime profile 选择点（概念上 `FREESTANDING` 为主目标）；下游不二次解析「要不要 libc」argv。

---

## 4. 问题地图（产生 / 存储 / 消费）

| 层 | 产生 | 存储 | 消费 |
|----|------|------|------|
| 用户程序 | `.x` + import std | `.o` / 可执行文件 | OS；是否依赖 libc.so |
| std 门面 | `std.sys` / heap / fs | 符号与 cfg | 用户与 dogfood |
| 编译器 runtime | seed + `.x` glue | `shux` / `shux_asm` | 解析 / typeck / codegen / 链接 |
| 链接 ABI | `runtime_link_abi` / g05 / `build_shux_asm` | 链接命令行 | ld；是否出现 `-lc` |
| bootstrap 桩 | freestanding_io + nostdlib stubs | `src/asm/*.o` | nostdlib crt0 bag |
| 验收 | NL-* / bstrict | CI 日志 | 是否假绿 |

**根因层**：只改用户链接、不改编译器 runtime 分配/IO → **L2 永远假绿**。

---

## 5. 平台边界

| 平台 | 零 libc 现实 | 说明 |
|------|--------------|------|
| **Linux x86_64** | **金标** | syscall + crt0 + nostdlib；验收以无动态 `libc.so` + 用户路径无 `-lc` 为准 |
| **Linux aarch64** | 跟进 | syscall 表对齐后同策略 |
| **macOS** | **不追求「无 libSystem」** | 产品可仍链 libSystem；Linux 零 libc 叙事 **不** 用 mac 绿冒充 |
| **Windows** | hosted / 平台 CRT | 不套用 POSIX freestanding 金标 |

**SHARED**：改堆/IO/链接 ABI 时双端想清楚——**禁止**把 mac `libSystem` 绿当成 Linux 零 libc 已过。

---

## 6. 验收清单

### 6.1 用户 L1（常青）

```bash
./tests/run-no-libc-link-gate.sh
./tests/run-no-libc-fs-gate.sh
./tests/run-freestanding-hello.sh
# 可选
./tests/run-no-libc-socket-gate.sh
./tests/run-no-libc-heap-gate.sh
```

### 6.2 编译器 L2 / G-03（终局）

```bash
# 产品二进制无动态 libc.so（Linux）
ldd compiler/shux_asm | tee /tmp/ldd_shux.txt
! grep -q libc.so /tmp/ldd_shux.txt

# NL-07 分层（见 phase-f-n07-v4.md）
SHUX_NOLIBC_N07_V4_TRY_BUILD=1 SHUX_NOLIBC_N07_V4_FAIL=1 \
  ./tests/run-nolibc-n07-v4-build-gate.sh
# 硬绿信号：bootstrap nostdlib crt0 link OK + unique UNDEF=0
```

### 6.3 产品正确性（不替代 L2）

```bash
./tests/run-all-bstrict.sh   # L0；绿 ≠ 零 libc 完成
```

---

## 7. 决策摘要（给主线）

1. **终局 = 零 libc 依赖**（Linux 金标编译器 + 用户 freestanding 路径）。  
2. **不做 `--libc`**——不实现、不文档化、不作为兼容轴。  
3. **用户入口 = `-freestanding` only**；compiler residual 用分层债清，不用新 CLI 糊。  
4. **NL-07 按层推进**（已 L1 multi-def、L2 fflush、L3 enc、L3b emit；下为 typeck/driver/lsp companion）→ G-03。  
5. **范围诚实**：mac/Windows 是平台兼容，不假装物理零系统库；Linux 是验收真值。  
6. **实现以 gate / `ldd` / crt0 UNDEF 为准**，不以叙事为准。

---

## 8. 与本周工程的关系

| 项 | 关系 |
|----|------|
| 双端 bstrict / 产品矩阵 | **L0**；不替代 F-no-libc |
| NL-07 L1 `e3d63a68` | crt0 multi-def 关 |
| NL-07 L2 `6a945f5b` | nostdlib stubs `fflush` 关 |
| NL-07 L3 `b613f58e` | crt0 入链 `BSTRICT_DISPATCH_OBJS`+simd（`backend_enc_*=0`） |
| NL-07 L3b `57fa657d` | seed `backend_emit_*` partial（`backend_emit_*=0`；双端 g05 矩阵） |
| NL-07 L4+ | typeck / driver / lsp companion |
| 本文 | **策略权威**；进度 KPI 见 `自举进度.md` / `当前进度.md` |

---

## 9. 参考路径

| 路径 | 内容 |
|------|------|
| `NEXT.md` §9.5 / §10 | F-no-libc、阶段 G |
| `analysis/phase-f-n07-v4.md` | bootstrap nostdlib 分层 residual |
| `std/sys/mod.x` | OS 门面 |
| `std/heap/page_mmap.x` | 零 malloc 堆 |
| `std/fs/freestanding_linux.x` | 零 libc 文件 IO |
| `compiler/src/runtime/rt_compile.x` | `-freestanding` 解析 |
| `compiler/src/runtime_link_abi.x` | freestanding / nostdlib 链接 |
| `compiler/seeds/bootstrap_nostdlib_stubs.from_x.c` | bootstrap 最小桩（含 fflush） |
| `tests/run-no-libc-*.sh` / `run-nolibc-n07-*.sh` | 验收 |
| `Agents.md` / skill `shux-selfhost-product-gate` | 根源治理、G.7、平台标注 |

---

*文档状态：产品策略权威。旧文「是否加 `--libc`」结论作废。实现以 gate 变绿与 `ldd`/UNDEF 为准。*
