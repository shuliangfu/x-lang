# FFI 隔离：要不要做、怎么做

> 更新时间：2026-06-28（§7.5 **G-FFI-3/4 gate ✅**；§7.2 阶段表同步）  
> 状态：**分析定稿**（指导 LANG-007 v2 / SAFE-004 演进与阶段 G 排期）  
> 关联：[安全路线.md](./安全路线.md) §6、[lang-unsafe-v1-rfc.md](./lang-unsafe-v1-rfc.md)、[safe-ffi-contract-v1.md](./safe-ffi-contract-v1.md)、[type-ffi-bridge-v1.md](./type-ffi-bridge-v1.md)、[安全与性能.md](./安全与性能.md)、[与C互操作.md](./与C互操作.md)

---

## 1. 结论（先给答案）

| 问题 | 回答 |
|------|------|
| **要不要做 FFI 隔离？** | **要。** FFI 是类型系统故意停止证明的边界；不做隔离，安全子集的「无泄漏、不因内存错误崩溃」在进程内无法成立。 |
| **隔离指什么？** | **编译期类型分界 + 显式 `unsafe` 信封 + 库层 Safe Wrapper + 可审计集中化**——不是把每次 FFI 调用包进厚重 runtime，也不是默认启用硬件沙箱。 |
| **要不要做文档旧稿里的 MPK / 双映射 / 寄存器钉死？** | **v1 不做默认方案。** 成本高、平台碎、与「零 C / LTO 内联 / 全平台一套 API」方向冲突；收益无法覆盖 Shux 当前主要 FFI 面（syscall、`std/sys`、少量 `extern`）。 |
| **性能会不会被牺牲？** | **不会。** Shux 的安全路线是「编译期证明、运行期零税」；隔离放在 typeck 与模块边界，热路径仍是裸 `call` + 标准 ABI，与 C 互调同级。 |
| **在哪个阶段做？** | **分三层排期，不是「等完全自举后再做」**：L1/L3 **已在做且 v1 已定版**；L2 **`unsafe { }` 在现阶段（阶段 G）并行推进，G 结束前 typeck 硬拒**；v3 / 进程外隔离 **v1.0.0 发布后**。详见 §7。 |

**一句话**：Shux 需要 **FFI 边界隔离**，不需要 **FFI 硬件沙箱**；隔离工作 **与自举主线并行**，核心层 **现在就要做**，不必等完全自举后再启动。

---

## 2. 问题定义：隔离到底防什么

### 2.1 FFI 在 Shux 中的真实形态

自举与 F-ZC 推进后，FFI 并非「业务代码随意调第三方 C 库」：

| 类别 | 典型路径 | 风险来源 |
|------|----------|----------|
| **OS 边界** | `std/sys/*.x` 内 `asm { syscall }` 或 `extern` 绑平台库 | 错误参数、错误缓冲区长度 |
| **标准库胶层** | `std/ffi`（CString、POD pack/unpack、回调句柄） | 裸指针生命周期、double-free |
| **动态库** | `std/dynlib` → `dlopen` / `LoadLibrary` | 错误函数签名、无界 C API |
| **用户第三方 C** | 用户自行 `extern` + 链接 | 任意 UB |
| **编译器 runtime** | `compiler/src/runtime*.c`（构建链，非用户程序） | 供应链 |

**隔离目标**：让 **S0 安全子集内的业务代码** 无法无意中依赖「C 侧已破坏的内存假设」；FFI 污染面 **可 grep、可门禁、可审计**。

### 2.2 威胁模型（进程内）

| 攻击面 | 后果 | 隔离能否 100% 挡住 |
|--------|------|-------------------|
| C 函数越界写堆 | UAF、任意写、RCE | **不能**（同进程、同页表） |
| C 破坏栈 / 寄存器 | 崩溃或控制流劫持 | **不能**（共享线程栈） |
| 错误 `extern` 签名 | 静默错误返回值 / 栈破坏 | **编译期 + 审计可大幅降低** |
| 裸指针渗入业务层 | 安全子集被架空 | **类型分界 + 模块收拢可挡住** |
| 恶意动态库 | 等同加载恶意代码 | **须进程外隔离**（见 §5.4） |

这与 [安全与性能.md](./安全与性能.md) 一致：**通用 OS + FFI 不存在数学意义上的绝对安全**；目标是 **可证明的安全子集 + 可审计边界 + 纵深防御**。

---

## 3. 旧稿四方案评审

此前讨论的「极致硬件隔离」四条，逐条对照 Shux 目标（性能比肩 C、轻量、全平台、零 C 终局）评估。

### 3.1 编译期双轨：`&T` vs `*raw T`

| 维度 | 评估 |
|------|------|
| **方向** | ✅ 正确——安全与不安全指针应在类型上可分 |
| **现状** | Shux v1 已有 **S0：`T[]`（带长度）** 与 **U2：`*T`（裸地址）** 分层（[lang-unsafe-v1-rfc.md](./lang-unsafe-v1-rfc.md)）；尚无 `&T` 借用、尚无独立 `*raw T` 类型 |
| **是否另造 `*raw T`** | ❌ 不建议 v1 引入第三指针种类。`*T` 已承担「无 region / 无长度」语义；再拆 `*raw T` 与 `*T` 边界模糊，且与 TYPE-004 `*T`→C 映射重复 |
| **应做** | v2：`extern` 调用、`*T` 解引用、`*T`→`T[]` 升格 **收入 `unsafe { }`**；考虑 `ForeignBuf` / `CString` 等 **具名边界类型**（见 §5.2） |

**性能**：纯编译期，零运行开销。✅

### 3.2 运行时：MPK / 虚拟内存双映射

| 维度 | 评估 |
|------|------|
| **设想** | 同物理页双 VA；FFI 临界区切换 MPK domain，C 只能写「影子」视图 |
| **问题** | ① Intel MPX 已废弃；MPK 仅 16 key、**不能防 syscall、不能防同域内越界** ② 双映射管理复杂，**破坏地址稳定性**（指针 identity），与 slice、arena、LTO 内联冲突 ③ Linux/macOS/ARM/Windows 能力不一致，违背「一套 API」 ④ 实现与测试成本远超自举主线 |
| **与零拷贝** | 不拷贝数据，但 **页表切换 + TLB 压力 + 影子地址换算** 仍是实开销；对高频 syscall 小缓冲区不划算 |
| **结论** | ❌ **非默认路径**；仅可作为未来 **可选部署硬化**（高安全场景、插件宿主），不进语言 core |

### 3.3 汇编层：寄存器钉死 + 零胶水 `call`

| 维度 | 评估 |
|------|------|
| **设想** | r14/r15 钉死 Shux 上下文；FFI 一条 `call` 无包装 |
| **现状** | System V AMD64 / AAPCS64 已规定 callee-saved 寄存器；Shux asm 后端已按平台 ABI 发 `call`。**无 Shux 专属「线程 Context 寄存器」需求时，钉死 r14/r15 无额外收益** |
| **栈** | 共享系统栈是 C ABI 要求；隔离靠 **编译期 red zone / 栈探针**（纵深防御 §6.6），不是第二套栈 |
| **结论** | ✅ **保持现有裸 ABI 调用**即可；❌ 不必为「隔离」单独设计寄存器协议 |

### 3.4 跨语言 LTO 内联

| 维度 | 评估 |
|------|------|
| **性能** | ✅ 极好——FFI 边界消失，与 Shux 代码同优化单元 |
| **隔离** | ❌ **与隔离目标相反**——内联后 C UB 直接进入 Shux 优化图，无「临界区」可切换 MPK |
| **结论** | LTO 作为 **性能选项**（`runtime.c` 已支持 `use_lto`）；与 FFI **隔离策略独立**。内联的 C 代码应视为 **同信任级源码**，须同样审计 |

---

## 4. 为什么「不做任何隔离」也不行

若仅保留 `extern function`、无模块收拢与类型分界：

1. **安全子集可被架空**：业务层持有 `*u8` 即可绕过 `T[]` 长度约束，typeck 对 S0 的保证失效。  
2. **与项目宗旨冲突**：[00-项目目标与宗旨](../../.cursor/rules/00-项目目标与宗旨.mdc) 要求 unsafe / C 互操作有 **显式边界**。  
3. **与已投入资产重复**：SAFE-004、TYPE-004、`std/ffi`、`run-safe-ffi-contract-gate.sh` 已定义契约；放弃隔离等于废弃这套门禁。  
4. **零 C 不等于零 FFI**：`std/sys` 的 syscall、`dynlib`、macOS 的 `libSystem` 绑定仍是外部代码入口。  
5. **旧稿否定的「Safe Wrapper」正是 Shux 已选路线**：[安全路线.md](./安全路线.md) §6.2 明确要求裸指针在胶水层转为 `T[]`，禁止渗透业务逻辑——这与「厚重 runtime」不是一回事。

**不做硬件隔离 ≠ 不做 FFI 隔离。**

---

## 5. 推荐架构：四层边界（零运行期税）

```
┌─────────────────────────────────────────────────────────┐
│  L4 纵深防御（进程/OS，不替代 typeck）                    │
│  ASLR / NX / 最小权限 / 不可信库 → 子进程 + IPC          │
├─────────────────────────────────────────────────────────┤
│  L3 库层契约（SAFE-004）                                  │
│  std/ffi · std/dynlib · std/sys — Safe Wrapper + 错误码   │
├─────────────────────────────────────────────────────────┤
│  L2 语法信封（LANG-007 v2）                               │
│  unsafe { } 包裹：extern、*T 解引用、裸算术、syscall 胶层   │
├─────────────────────────────────────────────────────────┤
│  L1 类型分界（S0 / U2 / U3）                              │
│  T[] + region  vs  *T  vs  extern — 禁止隐式升格           │
├─────────────────────────────────────────────────────────┤
│  业务代码（目标：零 unsafe）                               │
└─────────────────────────────────────────────────────────┘
```

### 5.1 L1：类型分界（编译期，零成本）

| 规则 | 说明 | 状态 |
|------|------|------|
| S0 默认 `T[]` | 长度显式，bounds check / BCE | ✅ |
| `*T` 无 region | U2；不得与 S0 slice 隐式互换 | ✅ 部分 |
| `extern` 参数 | TYPE-004：`i32`/`*T`/POD struct；`T[]` 不直接跨边界 | ✅ |
| `allow(padding)` | U1；C 布局镜像须显式 opt-in | ✅ |
| **禁止** `*T` 在 S0 解引用 | v2 进 `unsafe` | ⬜ 计划 |

**不引入 `*raw T`**：用 **层级（S0/U2/U3）+ unsafe 信封** 表达「外来污点」，避免类型爆炸。

### 5.2 L2：`unsafe { }` 语法信封（v2）

与 [lang-unsafe-v1-rfc.md](./lang-unsafe-v1-rfc.md) §3.5 对齐，v2 落地：

```sx
// 目标形态（示意）
unsafe {
  let n: i32 = extern_read(fd, buf_ptr, cap);
}
// buf_ptr 为 *u8；升格为 u8[] 须在 unsafe 内或经 std 包装证明长度
```

| 须在 `unsafe` 内 | 原因 |
|------------------|------|
| 调用 `extern function` | C 侧 UB 不收窄 |
| `*T` 解引用、指针算术 | 无边界证明 |
| `*T` → `T[]` 手动升格 | 长度由程序员断言 |
| `std/dynlib.sym` 返回值当函数指针调用 | 签名由程序员保证 |

**业务层零 `unsafe`**；仅 `std/sys`、`std/ffi`、`std/dynlib` 等模块出现。

可选演进（非 v2 阻塞）：

- `CString` / `ForeignBuf`：owned 句柄，析构/释放唯一入口  
- `Provenance` 标注（与 TYPE-002 region 衔接）：`*T` 携带「来自 extern」标记，typeck 拒绝直接进入 S0

### 5.3 L3：库层集中与契约（SAFE-004）

| 模块 | 职责 | 门禁 |
|------|------|------|
| `std/ffi` | CString 生命周期、POD pack/unpack、回调句柄 | `run-safe-ffi-contract-gate.sh` |
| `std/dynlib` | 动态库 open/sym/close；禁止无界 C API | `run-dynlib.sh`、`safe-unsafe-extern.tsv` |
| `std/sys` | syscall / 平台 `extern` 收拢 | `safe-unsafe-audit-gate.sh` |

**隔离原则**：

1. **裸指针不出库**：对外 API 返回 `T[]`、`Result`、owned 句柄或标量。  
2. **禁止 std 封装 `strcpy`/`sprintf` 等无界 API**；须长度参数或 Shux 侧缓冲区。  
3. **新增 `extern` 符号** → 更新 `safe-unsafe-extern.tsv` + SAFE-003 审计。  
4. **F-ZC**：`std/ffi` 已纯 `.x`（[phase-f-ffi-v1.md](./phase-f-ffi-v1.md)）；隔离逻辑留在 Shux 源码，便于 grep。

### 5.4 L4：纵深防御与进程外隔离

**同进程内无法阻止恶意 C 读写任意可访问页**——这是 OS 与 ABI 事实，MPK 也只能缩小域，不能消灭。

| 场景 | 推荐 |
|------|------|
| 可信系统库（libc 片段、libSystem、kernel32） | L1–L3 足够 + 最小权限进程 |
| 不可信原生插件（游戏 mod、用户 DLL） | **子进程 / 独立服务 + IPC**（socket、shared memory 仅传拷贝或 capability fd） |
| 未来 AI 插件生态 | [安全路线.md](./安全路线.md) §7.1 Capability / Wasm 沙箱 |

进程层机制（ASLR、NX、栈保护）见安全路线 §6.6；**不替代** typeck。

---

## 6. 与性能目标的对齐

| 顾虑 | 事实 |
|------|------|
| Safe Wrapper 很慢？ | `std/ffi` 的 `cstr_len` 等即一次 `extern call`；检查在 **进入 FFI 前**（长度、null），非每次热循环 |
| 不用 MPK 就不安全？ | MPK 防不了同域越界与恶意代码；**真正高风险靠进程边界** |
| 要比 C 快？ | FFI 路径 = 标准 ABI `call`；LTO 可选内联；**隔离在编译期，不在 call 路径上加锁或拷贝** |
| 零拷贝 IO？ | `read`/`write` 指针 + 长度 syscall 不受影响；隔离要求 **长度来源可信**（S0 slice 或契约），不要求 memcpy |

[性能压榨.md](./性能压榨.md) 铁律不变：**证不出 → 不删边界**；`unsafe` 内行为等同 C，隔离与性能在此汇合而非对立。

---

## 7. 阶段安排：现阶段 vs 完全自举后

### 7.1 直接回答

| 问题 | 回答 |
|------|------|
| **要不要等完全自举（D+E+F）后再做 FFI 隔离？** | **不要等。** D+E+F v1 已闭合；FFI 隔离的 **v1 底座（L1 部分 + L3）已经落地并在 CI 跑 gate**。若等到阶段 G 全部清场、物理零 C 后再启动，等于 **retrofit 整个 std**，成本更高。 |
| **会不会拖慢自举 / 阶段 G？** | **不应阻塞 bootstrap-min / bootstrap-gold。** L2（`unsafe { }` + typeck 硬拒）走 **并行轨道**：与 G-02/G-03 同排期，但不进 bootstrap-min 阻塞项（与 [lang-unsafe-v1-rfc.md](./lang-unsafe-v1-rfc.md)「U4 v2 不阻塞 v1」一致）。 |
| **现阶段具体做什么？** | ① 维持并扩展 L3（`std/ffi`、`std/sys`、`std/dynlib` 收拢 + gate）② 启动 LANG-007 v2 语法与 typeck ③ 新增 `extern` 必须更新审计 TSV。 |
| **完全自举以后做什么？** | v3 边界类型、provenance、不可信插件 IPC、B 级 Wasm/Capability——均属 **增强与生态**，不是隔离的「从零启动」。 |

### 7.2 与项目阶段的映射

对齐 [自举进度.md](./自举进度.md) §1 层次、[安全路线.md](./安全路线.md) §8 里程碑、[phase-g-full-selfhost-tasks-v1.md](./phase-g-full-selfhost-tasks-v1.md)：

```text
时间线 ──────────────────────────────────────────────────────────────►

  A～F (D+E+F v1 ✅)     阶段 G（进行中 🟡）        v1.0.0-selfhost 后
        │                      │                          │
  L1 类型分界 v1 ✅          L2 unsafe { } v2            L2 全量硬拒 + 业务零 unsafe
  L3 SAFE-004 ✅             L3 std/sys 收拢             v3 ForeignBuf / provenance
  TYPE-004 ✅                audit gate 常态化           B 级 Wasm / Capability
  std/ffi F-ZC ✅            不阻塞 bootstrap-min        插件 IPC 标准协议
        │                      │                          │
  ──────┴──────────────────────┴──────────────────────────┴──────────
        已在做                    现阶段主战场               增强层（非阻塞自举）
```

| 项目阶段 | FFI 隔离交付 | 阻塞自举？ | 状态 |
|----------|--------------|------------|------|
| **A～F（D+E+F v1）** | L1 部分 + L3 + TYPE-004 + U1–U3 + `std/ffi` F-ZC | — | ✅ 已定版 |
| **阶段 G 进行中（现在）** | L3 持续：`std/sys` syscall/`extern` 收拢；SAFE-003/004 gate 进 bstrict | **否** | 🟡 进行中 |
| **阶段 G 进行中（并行轨）** | L2 v2：`unsafe { }` + typeck 硬拒；`run-lang-unsafe-gate.sh` 全绿（Docker #88） | **否** | ✅ L2 v2 gate 绿；**G-FFI-5** 待闭合 |
| **阶段 G 结束前** | L2 std 底层 `unsafe` 集中、业务测试层零裸 `extern`；release CI | **否**（G 自身里程碑） | ⬜ |
| **G-07 发布 `vX.Y.Z-selfhost`** | 隔离 v1+v2 写入 release CI；L4 纵深防御文档化 | — | ⬜ |
| **v1.0.0-selfhost 之后** | v3 边界类型、provenance、dynlib 类型化 sym、插件 IPC | — | B 级 backlog |
| **不排期** | MPK / 双 VA / 第二套 FFI runtime | — | 不做默认 |

### 7.3 为什么不是「完全自举后再做」

1. **FFI 入口已存在**：`std/sys`、`std/ffi`、`compiler/runtime*.c` 构建链——不是自举完成后才突然出现的外部边界。  
2. **v1 已投入且 CI 在跑**：SAFE-004、TYPE-004、`run-safe-ffi-contract-gate.sh` 等；「等自举后再做」= 闲置已有门禁。  
3. **安全路线已写死 G 结束前目标**：`std/sys` syscall 收拢、业务层零 `unsafe`（[安全路线.md](./安全路线.md) §8）——没有 L2 `unsafe { }`，「零 unsafe 业务层」无法操作化。  
4. **std 收拢与 G 同向**：F-ZC 后隔离逻辑在 `.x` 里，阶段 G 改 `std/sys`、删 `import_alias.c` 时 **顺带** 包 `unsafe`、更新 TSV，比事后再 grep 全库便宜。  
5. **自举不依赖 LANG-007 v2**：[lang-unsafe-v1-rfc.md](./lang-unsafe-v1-rfc.md) 明确 U4 `unsafe { }` 属 v2、**不阻塞 v1**；compiler 自举路径几乎不扩 `extern` 面。

### 7.4 为什么也不是「现在就全量硬拒」

| 顾虑 | 处理 |
|------|------|
| 全库 retrofit 量大 | v2 先 **语法 + 烟测**；`tests/ffi/`、`std/ffi` 先行；全库硬拒放在 **G 尾声**，与「业务零 unsafe」同一批 |
| 阻塞 bootstrap | **不进** bootstrap-min / bootstrap-gold 阻塞项；bstrict / staging 可先 warning |
| 与 G-02 删 C 冲突 | `unsafe` 块是 **语言特性**，不依赖仓库零 C；runtime 薄 ABI 删 C 与 typeck 规则独立 |
| 编译器前端仍在演进 | v2 规则先覆盖 **extern 调用 + `*T` 解引用** 两条高价值路径，provenance 留 v3 |

### 7.5 现阶段执行清单（阶段 G 并行轨）

**立即（维护型，不阻塞 G）**

- [ ] 新增 `extern` → `safe-unsafe-extern.tsv` + SAFE-003 审计  
- [ ] `std/sys`、`std/dynlib` 新 API 对外不暴露裸 `*T`（L3）  
- [ ] CI 保持：`run-safe-ffi-contract-gate.sh`、`run-type-ffi-bridge-gate.sh`、`run-safe-unsafe-audit-gate.sh`

**阶段 G 内（LANG-007 v2，P0 并行）**

- [x] parser：`unsafe { }` 块语法（C 前端 + sx 路径；Docker gate #88）  
- [x] typeck：S0 内 `extern` 调用 → error  
- [x] typeck：S0 内 `*T` 解引用 → error  
- [x] `tests/unsafe/` + `run-lang-unsafe-gate.sh` 扩展 v2 case  
- [x] bootstrap 重链 + gate 全绿（Docker linux/amd64；run 路径 `-backend c -o`）  
- [x] `std/ffi`、`std/sys` 模块内用 `unsafe { }` 包裹现有 `extern`（#89 `run-g-ffi-5-std-wrap-gate.sh`）  

**阶段 G 尾声 / G-07 前（闭合）**

- [ ] bstrict 全库：业务 `tests/`（非 ffi/sys 专项）无裸 `extern`  
- [ ] `安全路线.md` §8「业务层零 unsafe」在 std 测试矩阵可验证  
- [ ] release CI 纳入 v2 gate

**v1.0.0-selfhost 后（不阻塞自举）**

- [ ] `CString` / `ForeignBuf` 具名边界类型（v3）  
- [ ] `*T` provenance 与 TYPE-002 region 联动  
- [ ] `std/dynlib` 类型化 `sym`  
- [ ] 不可信原生插件：子进程 + IPC 标准协议  
- [ ] B 级 Capability / Wasm 沙箱 RFC（[安全路线.md](./安全路线.md) §7.1）

### 7.6 技术版本路线图（与 §7.2 对照）

| 版本 | 内容 | 对应项目阶段 | 优先级 |
|------|------|--------------|--------|
| **v1** | TYPE-004、SAFE-004、U1–U3、`std/ffi` F-ZC、audit gate | A～F ✅ | — |
| **v2** | `unsafe { }`；`extern` / `*T` 解引用进 unsafe；typeck 拒 S0 违规 | **阶段 G 并行** | **P0 — gate ✅（#88）；std 包裹 ✅（#89）；G-FFI-5 尾声待闭合** |
| **v2.1** | `std/dynlib` 类型化 sym | G 尾声或 post-release | P1 |
| **v3** | `ForeignBuf` / provenance | v1.0.0-selfhost 后 | P2 |
| **可选** | LTO 信任模型文档；插件 IPC | post-release | P2 |
| **不计划** | MPK、双 VA、Go 式栈切换 | — | — |

验收命令（延续 gate 风格）：

```bash
./tests/run-safe-ffi-contract-gate.sh    # SAFE-004（现阶段 ✅）
./tests/run-type-ffi-bridge-gate.sh      # TYPE-004（现阶段 ✅）
./tests/run-safe-unsafe-audit-gate.sh    # SAFE-003（现阶段 ✅）
# v2 新增（阶段 G）：
./tests/run-lang-unsafe-gate.sh          # unsafe { } + S0 违规拒错
```

---

## 8. 决策记录

| 决策 | 理由 |
|------|------|
| **做 FFI 隔离** | 安全子集与项目宗旨要求可审计边界；FFI 是已知污点源 |
| **默认方案 = 编译期 + unsafe 信封 + std 收拢** | 零运行期税；与 Rust/Zig 工业实践一致；已有 SAFE-004 基础 |
| **不做默认硬件沙箱** | 平台碎、成本高、与 LTO/零 C/全平台冲突；收益不覆盖主路径 |
| **不引入 `*raw T`** | `*T` + 层级 + unsafe 足够；避免类型系统重复 |
| **不可信原生代码走进程外** | 同进程内无完美隔离；与 MPK 与否无关 |
| **LTO 与隔离解耦** | 内联 C 视为信任源码，须审计；不作为隔离手段 |
| **阶段 G 并行做 v2，不等完全自举后** | v1 已闭合；G 与 std 收拢同向；v2 不阻塞 bootstrap-min |
| **v3 / 插件 IPC 放 post-release** | 增强层；不阻塞 D+E+F 与 G 清场 |

---

## 9. 参考与阅读顺序

| 顺序 | 文档 | 关注点 |
|------|------|--------|
| 1 | [安全与性能.md](./安全与性能.md) §一、§三 | 为何无「绝对安全」 |
| 2 | [lang-unsafe-v1-rfc.md](./lang-unsafe-v1-rfc.md) | S0 / U1–U4 分层 |
| 3 | [safe-ffi-contract-v1.md](./safe-ffi-contract-v1.md) | C1–C7 契约 |
| 4 | [type-ffi-bridge-v1.md](./type-ffi-bridge-v1.md) | F1–F6 类型桥 |
| 5 | [安全路线.md](./安全路线.md) §6 | A 级隔离总览 |
| 6 | [与C互操作.md](./与C互操作.md) | ABI 与语法 |
| 7 | [phase-f-ffi-v1.md](./phase-f-ffi-v1.md) | std.ffi 零 C 现状 |
| 8 | [自举进度.md](./自举进度.md) §1、§2 | D+E+F / G 层次与进度 |
| 9 | [phase-g-full-selfhost-tasks-v1.md](./phase-g-full-selfhost-tasks-v1.md) | 阶段 G 任务与 gate |
| 10 | [安全路线.md](./安全路线.md) §8 | 里程碑对齐 |
| 11 | [自举进度.md](./自举进度.md) §3.1、§10.10 | G-FFI 并行轨勾选 |
| 12 | [NEXT.md](../NEXT.md) §0.1、§10.5、§11 | 路线图与下一步动作 |

## 10. 附录：旧稿与定稿对照

| 旧稿主张 | 定稿 |
|----------|------|
| 拒绝 Safe Wrapper | **采纳 Safe Wrapper**（薄包装 + 契约），拒绝的是「每次 FFI 重型 runtime」 |
| `*raw T` 双轨 | **保留 `*T` + S0/`T[]` 双轨**，v2 用 `unsafe` 信封 |
| MPK 零拷贝沙箱 | **不默认**；不可信库用进程隔离 |
| 寄存器钉死 r14/r15 | **遵循平台 ABI 即可** |
| LTO 消灭 FFI 边界 | **性能选项**；内联代码须纳入审计信任集 |
