# SHUX IR 核心设计

> **文档状态**：架构设计文档 v4.0 — **Architecture Freeze（架构冻结）** | **日期**：2026-07-13
> **定位**：**Semantic IR（语义驱动 IR）**——把 SHUX 语言语义（Linear / Region / X ABI）直接编码进 IR，并通过 Contract 在 lowering 和优化过程中持续验证。不模仿 LLVM IR / GCC RTL / Cranelift，目标是把性能压榨到极致。
> **核心约束**：无历史包袱、Domain-Specific + Performance-First、与 SHUX 语言特性（`Linear(T)` move 语义、Arena、X ABI）深度耦合。
> **版本演进**：v1 基础框架 → v2 吸收 Grok 建议（契约模型 + 四层 + e-graph）→ v3 落地具体化（指令契约定义 + e-graph 规则系统 + 寄存器分配 + Superoptimizer 集成方案）→ v3.1 吸收 Grok 最终建议（指令集扩充 + e-graph 规则冲突与内存管理 + 开发 Checklist + 风险与权衡）→ v4.0 吸收 ChatGPT 建议（Semantic IR 定位 + Contract 池化 + Effect 独立子系统 + 五层架构 VMIR + SLIR immutable + Cost Model 多维度插件化 + SHIR 高层性原则）→ **Architecture Freeze**。
>
> **冻结条件**：自本日起，IR 总架构不再修改。仅以下两种情况允许调整：
> 1. **实现时发现不可行**——某个设计写不出来，回溯调整；
> 2. **Benchmark 证明性能退化**——某个设计导致性能下降，回溯修改。
>
> 其余情况（Contract → Contract2 → Contract3 式无限重构）禁止。剩余工作从"设计"切换为"实现"。

---

## 1. IR 设计哲学：Semantic IR（语义驱动 IR）

### 1.1 从"中间表示"到"语义驱动 IR"

传统 IR（LLVM IR / GCC RTL）是"中间表示"——优化器基于启发式猜测做变换，靠大量保守分析去"猜"别名/生存期/副作用。SHUX IR 升级为 **Semantic IR（语义驱动 IR）**：

- 每一条 IR 指令都携带**形式化语义契约**：pre-condition / post-condition / region 转移 / Linear 消耗证明；
- 优化器的本质不再是"启发式猜测"，而是**消费来自语言层的已证明语义**，在保证契约不变的前提下做最激进的等价变换；
- 这是 SHUX 能超越 C 的根本武器：C 编译器只能保守猜测别名/生存期，SHUX IR 基于语言级证明（`Linear(T)` + Region + X ABI）做极端优化；
- **Semantic IR 的五层职责**：SHIR 保留语言语义 → SMIR 把语义转化为可验证约束 → SLIR 在语义约束下做等价变换 → VMIR 做指令选择 → Target MIR 只关心寄存器分配与微架构对齐。

```
传统 IR：     代码 → 启发式分析 → 猜测性优化 → 保守（可能出错）
Semantic IR： 代码 → 语言语义编码 → 契约持续验证 → 激进（可证明正确）
```

### 1.2 契约表示方式：Contract Pool + Metadata ID

> **池化设计**：契约不直接内联到每条指令，而是通过 Metadata ID 间接引用 Contract Pool。一万个 `load` 指令共用同一个 Contract，IR 体积大幅缩小，cache 命中率提升。这是 LLVM 后期也在走的 Metadata 化路线。

```shux
// IR 指令通过 contract_id 间接引用 Contract Pool
struct IRInst {
    opcode: Opcode,
    operands: [Operand],
    contract_id: ContractId,        // 间接引用，不内联 Contract
    effect_id: EffectId,            // Effect 独立子系统（§1.7）
    debug_loc: DebugLoc,
}

// Contract Pool（全局唯一，去重存储）
struct ContractPool {
    contracts: Arena<Contract>,     // 紧致数组存储
    dedup: HashMap<ContractKey, ContractId>,  // 去重索引
}

// 契约结构体（存储在 Pool 中，被多条指令共享）
struct Contract {
    id: ContractId,                 // 池中唯一 ID
    // 前置条件：执行前必须满足
    pre: [
        region_alive(region_id),      // region 未被 reset
        ptr_aligned(ptr, align),       // 指针对齐
        linear_valid(handle),          // Linear 句柄未 consumed
    ],
    // 后置条件：执行后保证
    post: [
        region_alive(region_id),       // region 仍存活（alloc 不 reset）
        linear_consumed(src),          // move 后 src 失效
        no_alias(dst, other_ptrs),     // dst 与其他活跃指针无别名
    ],
    // 副作用引用（Effect 独立子系统，§1.7）
    effect_id: EffectId,
    // 所有权转移
    ownership: Move{from: src, to: dst} | Borrow{ptr, lifetime} | None,
}
```

**池化收益**：
- **内存**：1 万个 `load` 共用一个 Contract → 节省 ~99% 契约存储；
- **Cache**：指令流遍历时 contract_id 是 4 字节整数，远小于内联 Contract 结构体，icache 友好；
- **去重**：`ContractPool.dedup` 用 HashMap 自动去重，语义相同的 Contract 只存一份；
- **Pass 效率**：Pass 比较契约时只比 `contract_id`（整数相等），不需要深比较结构体。

### 1.3 契约验证机制

契约在 **lowering 时自动检查**，分三步：

```
SHIR lowering → SMIR
  │
  ├─ Step 1: 契约提取
  │   从 .x 类型系统提取 Linear/Region/ABI 信息 → 生成 Contract
  │
  ├─ Step 2: 前置条件检查
  │   每条指令执行前，验证 pre-condition 在当前 IR 状态下可满足
  │   · region_alive → 检查 region 未被 arena_reset
  │   · linear_valid → 检查句柄未被 linear_move/consume
  │
  └─ Step 3: 后置条件传播
      执行后更新 IR 状态（标记 consumed、更新 alias set）
      供后续指令的前置条件检查消费
```

**验证失败处理**：lowering 时契约不一致 = 编译器 bug（前端 typeck 与 IR 契约矛盾），直接 panic 并报告不一致点。不生成错误代码。

### 1.4 优化器工作模型

```
传统优化器：  代码 → 启发式分析 → 猜测性优化 → 可能出错（保守）
SHUX 优化器： 代码 → 契约提取 → 契约保持的等价变换 → 可证明正确（激进）
```

优化器的每一步变换都必须满足：**变换前后契约等价**。验证方式：
- 变换后的 pre-condition ⊆ 变换前的 pre-condition（不增加约束）；
- 变换后的 post-condition ⊇ 变换前的 post-condition（不减弱保证）；
- effects 集合不变（不新增副作用）。

> **拒绝 Lean4 / Coq**：SHUX 的"证明"靠编译期类型系统保证（`Linear(T)` + Region + X ABI 契约本身就是编译期可验证的形式化系统），不引入外部定理证明器。

### 1.5 Assume 语义（Escape Hatch）

> 系统编程中存在编译器类型系统无法穷举验证的场景（如 lock-free 数据结构、原子操作序列、手写无锁队列）。对此提供 `assume` 语义作为逃逸口。

```shux
// 开发者显式假设契约成立
#[unsafe_assume(region_alive(%r))]
fn lock_free_push(queue: *LockFreeQueue, item: Item) {
    // 编译器据此假设做优化
    // 若假设错误 → 不保证正确性（与 unsafe 同级）
}
```

**安全约束**：
- `assume` 必须带 `#[unsafe_assume]` 标注——明示这是 unsafe 操作，与 C ABI 的 `unsafe` 同级；
- **Debug 模式**：`assume` 自动插入 runtime guard（断言检查），违反时 panic；
- **Release 模式**：信任 `assume`，不做检查，按假设优化；
- **滥用防护**：`assume` 使用次数纳入代码审查指标，过多 `assume` 触发编译器警告。

**与 `unsafe` 的关系**：

| 机制 | 用途 | 验证方式 |
|------|------|----------|
| 契约（默认） | 编译器可验的语义保证 | 编译期自动验证 |
| `assume` | 编译器无法验证的开发者断言 | Debug runtime guard + Release 信任 |
| `unsafe` | FFI / 裸指针 / 内联汇编 | 无验证，程序员全责 |

### 1.6 契约快照（Contract Snapshot）

> 内联 `x_abi_call` 后会带来大量契约合并，若递归展开会导致 post-condition 无限复杂化。采用**契约快照**策略控制复杂度。

```
内联前：
  %result = x_abi_call %fn, args=[%a, %b]
  // %fn 的 Contract 未知（需要内联后才可见）

内联后（契约快照策略）：
  Step 1: 检查 %fn 的 pre-condition 是否满足
    · 若不满足 → 编译错误（契约违反）
    · 若满足 → 继续

  Step 2: 直接注入 %fn 的 post-condition 到当前上下文
    · 不递归展开 %fn 内部的契约链
    · post-condition 作为"快照"注入，当前上下文消费

  Step 3: 后续优化基于注入的 post-condition，不需要追踪 %fn 内部
```

**收益**：内联后的契约传播复杂度从 O(深度) 降为 O(1)——只查一次 pre + 注入一次 post，不递归。

### 1.7 Effect 独立子系统

> **解耦设计**：Effect（副作用）从 Contract 中拆出为独立子系统。原因：不同 Pass 关心的维度不同——Scheduler 只关心 Effect（能否重排），不关心 Ownership（所有权转移）；Alias Analysis 只关心 region 读写，不关心 Linear move。拆分后 Pass 耦合度大幅降低。

```shux
// Effect Pool（独立于 Contract Pool，全局唯一）
struct EffectPool {
    effects: Arena<Effect>,
    dedup: HashMap<EffectKey, EffectId>,
}

// Effect 种类（Scheduler / Alias Analysis 消费）
enum Effect {
    Pure,                               // 无副作用（可任意重排、CSE、DCE）
    ReadOnly{regions: [RegionId]},      // 只读某些 region（可重排，不可消除）
    Write{regions: [RegionId]},         // 写某些 region（不可随意重排）
    Call{kind: ABIKind},                // 函数调用副作用
    Atomic{order: MemoryOrder},         // 原子操作（内存序约束）
    Fence{order: MemoryOrder},          // 内存屏障
}
```

**Pass 与子系统的消费关系**：

| Pass | 关心 Contract | 关心 Effect | 关心 Ownership |
|------|:---:|:---:|:---:|
| Scheduler（指令调度） | ❌ | ✅ | ❌ |
| Alias Analysis | ❌ | ✅（region 读写） | ❌ |
| LICM（循环不变量外提） | ❌ | ✅（是否 Pure） | ❌ |
| DCE（死代码消除） | ✅（post 是否被消费） | ✅（是否 Pure） | ❌ |
| Inline（内联） | ✅（契约快照） | ✅（继承 Effect） | ✅（所有权传递） |
| Linear Move Optim | ✅（consumed 状态） | ❌ | ✅（move 边） |

**设计约束**：
- Contract 通过 `effect_id` 引用 Effect Pool——Contract 仍自包含（验证时一次查到），但 Effect 可被 Pass 独立查询；
- Effect 同样池化去重——1 万个 Pure 指令共用 `EffectId(0)`；
- Effect 不变量：**变换前后 Effect 集合不变**（与 §1.4 契约等价规则一致）。

### 1.8 SHIR 高层性原则

> **延迟 lowering**：SHIR 应保留语言级高层结构（Pattern Match / Coroutine / Generator / Trait dispatch 等），不要一开始就 lower 为低级指令。高层结构对 IDE / Incremental Compile / Refactor 友好，且为未来语言特性演进预留空间。

**原则**：
- SHIR 是"语言语义的 1:1 映射"，不是"低级 IR 的预处理层"；
- 能在 SHIR 层做的优化（如 Pattern Match 编译期穷尽性检查、Coroutine 状态机分析）不 lower 到 SMIR；
- lowering 决策由"优化收益"驱动，不由"实现简便"驱动——只有当高层结构阻碍进一步优化时才 lower；
- SHUX 语言新增高层特性时，SHIR 同步保留对应高层节点，不立即消除。

**当前 SHUX 语言特性映射**：

| SHUX 语言特性 | SHIR 高层节点 | lowering 时机 |
|---------------|---------------|---------------|
| `Linear(T)` move | `linear_move` / `linear_consume` | SMIR 阶段（所有权验证后） |
| Arena region | `region_alloc` / `arena_alloc` / `arena_reset` | Target MIR 阶段（内存映射） |
| X ABI call | `x_abi_call`（保留 ABI 标记） | SMIR 内联决策后 |
| C ABI FFI | `c_abi_call`（FFI 边界，永不 lower 为内联） | Target MIR 直接 codegen |
| Pattern Match（未来） | `match_arm` / `match_guard` | SMIR 阶段（穷尽性验证后 lower 为 branch） |
| Coroutine（未来） | `coroutine_resume` / `coroutine_yield` | SMIR 阶段（状态机转换） |
| Generator（未来） | `generator_next` | SMIR 阶段（状态机转换） |

> **注意**：Pattern Match / Coroutine / Generator 等 SHIR 高层节点将在 SHUX 语言本身支持这些特性后落地，当前 SHIR 聚焦 Linear / Region / X ABI 三大核心语义。

---

## 2. 五层 IR 架构

### 2.1 架构总览

```
.x 源码
  │
  ▼
┌─────────────────────────────────────────────────┐
│  SHIR (Shux High IR)                             │
│  最接近语言语义 · 保留高层结构                    │
│  · Linear(T) / Region / Trait 标注              │
│  · 泛型 monomorphization                        │
│  · X ABI / C ABI 标记                           │
│  · 语义契约（pre/post condition）                │
│  · 高层节点（Pattern Match / Coroutine / ...）   │
└──────────────────┬──────────────────────────────┘
                   │ lowering（语义保持，契约验证）
                   ▼
┌─────────────────────────────────────────────────┐
│  SMIR (Shux Mid IR)                              │
│  SSA + 显式所有权图 + region-aware 内存模型      │
│  · Linear move / borrow 边显式编码               │
│  · region-aware alias analysis                  │
│  · 跨 X ABI 边界内联                             │
│  · 契约验证（每条指令满足 pre-condition）         │
└──────────────────┬──────────────────────────────┘
                   │ lowering
                   ▼
┌─────────────────────────────────────────────────┐
│  SLIR (Shux Low IR)                              │
│  机器无关 · 极致优化表示（immutable graph）       │
│  · e-graph 重写引擎                             │
│  · Superoptimizer 搜索                          │
│  · Global Code Motion + Trace Scheduling        │
│  · SoA/AoS 布局转换                             │
└──────────────────┬──────────────────────────────┘
                   │ lowering（target-specific）
                   ▼
┌─────────────────────────────────────────────────┐
│  VMIR (Value MIR / Instruction Selection IR)     │
│  指令选择层 · 机器无关运算 → 目标机器指令         │
│  · 模式匹配 isel（a+b → LEA/ADD/FMA 决策）       │
│  · 依赖关系图构建（DAG）                         │
│  · 早期指令调度（依赖约束下的重排）               │
│  · 契约物化（Contract → 机器指令属性）            │
└──────────────────┬──────────────────────────────┘
                   │ lowering
                   ▼
┌─────────────────────────────────────────────────┐
│  Target MIR (Machine IR)                         │
│  特定硬件 · 寄存器分配与微架构对齐                │
│  · 寄存器分配（region-based Coloring）           │
│  · 最终指令调度 + 微架构流水线建模                │
│  · 执行端口调度                                  │
│  · 热度感知 spilling                             │
└──────────────────┬──────────────────────────────┘
                   │ codegen
                   ▼
              .s 汇编 / .o 目标文件
```

> **五层 vs 四层**：v4.0 新增 VMIR 层，将原 Target MIR 的"指令选择 + 寄存器分配"双重职责拆分。VMIR 专做指令选择（isel），Target MIR 专做寄存器分配 + 微架构对齐。职责单一后，每层 pass 实现更清晰，且 isel 可独立复用（如未来支持新架构只需新增 VMIR → Target MIR 的 lowering）。

### 2.2 各层职责

| 层级 | 核心职责 | 优化类型 | 契约状态 |
|------|----------|----------|----------|
| SHIR | 语义保留 + 契约提取 + 高层结构 | 泛型特化 / 死代码消除 / Pattern 穷尽性检查 | 完整契约 |
| SMIR | SSA + 所有权验证 | 内联 / 别名分析 / CSE | 契约验证 |
| SLIR | 机器无关极致优化（immutable graph） | e-graph 重写 / Superoptimizer / 布局转换 | 契约保持 |
| VMIR | 指令选择（isel） | 模式匹配 / DAG 构建 / 早期调度 | 契约物化 |
| Target MIR | 硬件适配 | 寄存器分配 / 微架构对齐 / 热度 spilling | 契约物化 |

### 2.3 IR 表示形式

| 形式 | 用途 |
|------|------|
| 文本形式 | 人类可读，用于调试与 pass 审查 |
| 紧凑二进制 | 内存中高效遍历，pipeline 内传递 |
| Graph + 属性系统 | 现代 pass 框架基础，支持增量更新 |
| e-graph | SLIR 层等价变换的中间表示 |

### 2.4 核心数据结构

```shux
// ═══════════════════════════════════════════════
// Module 级：Pool 与 IR 共存
// ═══════════════════════════════════════════════
struct Module {
    functions: Arena<Function>,
    contract_pool: ContractPool,   // §1.2 契约池（全局去重）
    effect_pool: EffectPool,       // §1.7 Effect 池（全局去重）
    cost_model: CostModel,         // §10.3 多维度 Cost Model
}

// ═══════════════════════════════════════════════
// IR 指令（统一表示，池化引用）
// ═══════════════════════════════════════════════
struct IRInst {
    opcode: Opcode,
    operands: [Operand],           // 寄存器/立即数/指针/函数引用
    contract_id: ContractId,       // 间接引用 Contract Pool（§1.2）
    effect_id: EffectId,           // 间接引用 Effect Pool（§1.7）
    debug_loc: DebugLoc,           // 源码位置（.x 行号）
}

// 操作数
enum Operand {
    Reg(SSAReg),                   // SSA 虚拟寄存器
    Imm(i64),                      // 立即数
    Ptr(*T, RegionId, Lifetime),   // 裸指针 + region + 生存期
    Func(FuncRef, ABIKind),        // 函数引用 + ABI 标记
}

// ABI 种类
enum ABIKind { XABI(InlinePolicy), CABI }

// SSA 寄存器
struct SSAReg {
    id: u32,
    ty: Type,                      // 类型信息（含 Linear/Region 标记）
    def_inst: IRInst,              // 定义点
}

// ═══════════════════════════════════════════════
// VMIR 指令（指令选择后的目标机器指令，未做寄存器分配）
// ═══════════════════════════════════════════════
struct MachineInst {
    mc_opcode: McOpcode,           // 目标机器操作码（如 x86 LEA/ADD/FMA）
    operands: [McOperand],         // 虚拟寄存器 / 立即数 / 内存操作数
    defs: [VReg],                  // 定义的虚拟寄存器
    uses: [VReg],                  // 使用的虚拟寄存器
    deps: [MachineInst],           // 依赖关系（DAG 调度用）
    contract_id: ContractId,       // 物化后的契约（来自 IRInst）
    cost: Cost,                    // 指令成本（来自 Cost Model）
}

enum McOperand {
    VReg(VReg),                    // 虚拟寄存器（寄存器分配前）
    Imm(i64),
    Mem(BaseReg, IndexReg, Scale, Displacement),  // 内存操作数
    Label(BlockId),
}
```

> **Pool 化设计要点**：`IRInst` 只存 4 字节的 `contract_id` / `effect_id`，不内联 Contract / Effect 结构体。1 万个 `load` 指令共用 `ContractId(7)` 和 `EffectId(0)`（Pure），IR 体积从 ~200 字节/指令降至 ~32 字节/指令。

---

## 3. 核心指令集与契约定义

### 3.1 指令集总览

| 操作码 | 操作数 | 契约属性 | 语义 | 优化收益 |
|--------|--------|----------|------|----------|
| `region_alloc` | `(id, size)` | `#[region_create]` | 创建 Arena region | region-aware 优化基础 |
| `arena_alloc` | `(region, size)` | `#[region(id)]` | Arena 内分配 | O(1) 批量回收 + stack promotion |
| `arena_reset` | `(region)` | `#[region_destroy]` | 批量释放 region 内全部对象 | 消除逐对象 free |
| `linear_move` | `(src)` | `#[move_consumes]` | 消耗 src，返回新句柄 | 消除 drop check + 悬空指针检查 |
| `linear_consume` | `(val)` | `#[move_consumes]` | 显式消耗，无需 drop | 消除 drop check |
| `noalias_load` | `(ptr, region, lifetime)` | `#[noalias]` `#[region(id)]` | 从 region 加载，携带 provenance | 消除 alias check + 允许重排 |
| `noalias_store` | `(ptr, val, region, lifetime)` | `#[noalias]` `#[region(id)]` | 存储到 region，携带 provenance | 消除 alias check + 允许重排 |
| `x_abi_call` | `(fn, args)` | `#[inline_eligible]` | X ABI 调用，可内联 | 跨模块内联 + 契约传递 |
| `c_abi_call` | `(fn, args)` | `#[ffi_boundary]` | C ABI FFI 调用 | 无（FFI 边界，禁止优化） |
| `pure_call` | `(fn, args)` | `#[pure]` | 纯函数调用，无副作用 | CSE / 重排 / 消除 |
| `branch` | `(cond, then, else)` | `#[pure]` | 条件分支 | 分支预测 + path-sensitive 优化 |
| `loop_header` | `(counter, bound)` | `#[loop]` | 循环头，携带迭代计数 | 循环展开 + 向量化 |
| `loop_unroll_hint` | `(loop_id, factor, pragma)` | `#[loop]` `#[hint]` | 循环展开提示（factor=0 表示禁止，N 表示按 N 倍展开） | 指导 unroll pass 决策，可被 PGO 覆盖 |
| `branch_predict` | `(cond, likely)` | `#[hint]` | 分支方向预测提示（likely=true/false） | 引导 layout pass 将热点路径 fall-through |
| `vector_load` | `(ptr, region, mask, vl)` | `#[noalias]` `#[vector(vl)]` | SIMD 向量加载（带掩码与向量长度） | 自动向量化前置 + unaligned 路径分离 |
| `vector_op` | `(op, v1, v2, vl)` | `#[pure]` `#[vector(vl)]` | SIMD 向量运算（add/sub/mul/and/or 等统一编码） | 寄存器合并 + FMA 融合 |
| `vector_store` | `(ptr, val, region, mask, vl)` | `#[noalias]` `#[vector(vl)]` | SIMD 向量存储（带掩码） | store-to-load forwarding 优化 |
| `atomic_load` | `(ptr, order)` | `#[atomic]` `#[order(acquire/relaxed)]` | 原子加载，携带内存序 | 编译期消除冗余 fence + Power/ARM 重排约束 |
| `atomic_store` | `(ptr, val, order)` | `#[atomic]` `#[order(release/relaxed)]` | 原子存储，携带内存序 | 与 atomic_load 配对消除多余 barrier |
| `atomic_cas` | `(ptr, expected, desired, order)` | `#[atomic]` `#[compare_swap]` | 原子比较交换，返回是否成功 | lock-free 数据结构核心原语 + 失败路径冷代码分离 |
| `memory_fence` | `(order)` | `#[atomic]` `#[order(seq_cst/acq_rel)]` | 全局内存屏障 | 编译期合并相邻 fence + target 降级到单条指令 |
| `prefetch` | `(ptr, level, hint)` | `#[hint]` `#[pure]` | 数据预取提示（L1/L2/L3，read/write） | cache miss 隐藏 + 与软件流水线协同 |

> **指令集分层**：
> - **核心契约指令**（前 12 条）：与 SHUX 语言语义深度耦合，每条都携带可验证 Contract；
> - **优化提示指令**（`loop_unroll_hint` / `branch_predict` / `prefetch`）：`#[hint]` 标注，不改变语义，只影响 pass 决策，可被 PGO 或 cost model 覆盖；
> - **SIMD 指令**（`vector_*`）：通过 `vl`（vector length）参数实现 VLA 向量化，target lowering 时映射到 SSE/AVX/NEON/SVE；
> - **原子指令**（`atomic_*` / `memory_fence`）：携带内存序参数，编译器据此推算最小必要 barrier，避免保守 seq_cst。

### 3.2 关键指令完整契约定义

> 以下契约定义采用**逻辑表示**（`effects: Pure` / `effects: Mutable{...}`）以直观展示语义；实际存储时通过 `contract_id` 引用 ContractPool（§1.2），Effect 字段通过 `effect_id` 引用 EffectPool（§1.7）。

#### 3.2.1 `linear_move`

```shux
// 指令
%dst = linear_move %src

// 契约
Contract {
    pre: [
        linear_valid(%src),              // src 必须未被 consume
        type_is_linear(%src.ty),          // src 必须是 Linear(T) 类型
    ],
    post: [
        linear_consumed(%src),            // 执行后 src 确定性失效
        linear_valid(%dst),               // dst 成为新的有效句柄
        same_ownership(%dst, %src),       // 所有权从 src 转移到 dst
    ],
    effects: Pure,                         // move 本身无内存副作用
    ownership: Move{from: %src, to: %dst},
}

// 优化收益
// 1. %src 之后的所有引用 → 编译期消除（契约保证 consumed）
// 2. %src 的 drop check → 消除（所有权已转移）
// 3. %src 与 %dst 的别名 → 可证明无别名（move 语义保证）
```

#### 3.2.2 `noalias_load`

```shux
// 指令
%val = noalias_load %ptr, region=%r, lifetime=%lt

// 契约
Contract {
    pre: [
        region_alive(%r),                 // region 未被 reset
        ptr_aligned(%ptr, align_of(T)),    // 指针对齐
        ptr_in_region(%ptr, %r),           // 指针属于该 region
        no_concurrent_write(%ptr, %lt),    // 生存期内无并发写
    ],
    post: [
        %val = *%ptr,                      // 值语义：加载指针指向的值
        // 不修改任何 region 状态
    ],
    effects: Pure,                         // load 是纯读操作
    ownership: None,
}

// 优化收益
// 1. 两个不同 region 的 noalias_load → 可证明无别名 → 允许重排
// 2. pure → 可 CSE（相同 ptr + region 的重复 load 合并）
// 3. region 隔离 → 消除 alias check
```

#### 3.2.3 `arena_reset`

```shux
// 指令
arena_reset %r

// 契约
Contract {
    pre: [
        region_alive(%r),                 // region 存活
        no_live_borrow(%r),               // 该 region 无活跃借用
    ],
    post: [
        region_dead(%r),                  // region 已回收
        all_ptrs_in_region_invalid(%r),   // region 内所有指针失效
    ],
    effects: Mutable{regions: [%r]},      // 修改该 region
    ownership: None,
}

// 优化收益
// 1. O(1) 批量回收 → 替代逐对象 free
// 2. region 内所有对象的 drop check → 批量消除
// 3. arena_reset 后对该 region 的访问 → 编译期报错（契约违反）
```

#### 3.2.4 `x_abi_call`

```shux
// 指令
%result = x_abi_call %fn, args=[%a, %b]

// 契约
Contract {
    pre: [
        fn_is_xabi(%fn),                  // 函数标记为 X ABI
        args_match_signature(%fn, args),  // 参数类型匹配
        // 若 args 包含 Linear(T) → 所有权转移契约传递
    ],
    post: [
        // 契约从被调用函数传播（inline 后可见）
        returns_valid(%result),
    ],
    effects: InheritCallee,               // 继承被调用函数的 effects
    ownership: InheritCallee,             // 继承被调用函数的所有权转移
}

// 优化收益
// 1. 可跨模块内联（C ABI 禁止）
// 2. 内联后契约可见 → 进一步优化
// 3. 契约传递 → 调用链全程可验
```

#### 3.2.5 `pure_call`

```shux
// 指令
%result = pure_call %fn, args=[%a, %b]

// 契约
Contract {
    pre: [
        fn_is_pure(%fn),                  // 函数标记为 #[pure]
        args_match_signature(%fn, args),
    ],
    post: [
        deterministic_return(%result),    // 相同输入 → 相同输出
    ],
    effects: Pure,                        // 无副作用
    ownership: None,                      // 不转移所有权
}

// 优化收益
// 1. 相同参数的重复调用 → CSE 合并为一次
// 2. 可跨基本块重排
// 3. 死代码消除：结果未使用 → 整个调用消除
```

---

## 4. e-graph 重写引擎设计

### 4.1 e-graph 核心概念

e-graph（equality graph）是当前最强大的等价优化技术。它把代码表示为**等价类的有向图**，自动探索所有等价表示，基于 cost function 提取最优。

```
传统 pass：  代码 → pass A → pass B → pass A → ... → fixpoint（依赖顺序）
e-graph：    代码 → 构建 e-graph → 注册重写规则 → 自动饱和 → 提取最优
```

### 4.2 重写规则定义

规则用声明式语法定义，支持动态注入（External Pass Provider 可注入）：

```shux
// 重写规则定义
rewrite rule algebra_simplify {
    // 模式匹配 → 等价替换
    add_zero:        x + 0        => x
    mul_zero:        x * 0        => 0
    mul_one:         x * 1        => x
    mul_two_shift:   x * 2        => x << 1
    add_sub_cancel:  (x + y) - y  => x
    // ... 更多代数恒等式
}

rewrite rule strength_reduction {
    pow2_to_shift:   x * 2^n      => x << n
    div_pow2:        x / 2^n      => x >> n
    mod_pow2:        x % 2^n      => x & (2^n - 1)
}

rewrite rule linear_optim {
    // Linear move 后的原引用访问 → 消除（契约保证 consumed）
    use_after_move:  use(linear_move(x).src) => unreachable_eliminate
    // region_reset 后的 region 访问 → 消除
    use_after_reset: use(arena_reset(r).region) => unreachable_eliminate
}

rewrite rule alias_optim {
    // 不同 region 的指针 → 标记 noalias
    cross_region_noalias: load(p1, r1), load(p2, r2) where r1 != r2 => noalias(p1, p2)
}
```

### 4.3 Cost Function 设计

```shux
// 指令 cost 表（越小越优）
fn inst_cost(inst: IRInst) -> Cost {
    match inst.opcode {
        // 常量/立即数 → 最低 cost
        Imm(_)           => 0,
        // 位运算 → 低 cost（1 cycle）
        Shl | Shr | And | Or | Xor  => 1,
        // 加减法 → 低 cost
        Add | Sub                    => 1,
        // 乘法 → 中 cost（3-5 cycle）
        Mul                          => 5,
        // 除法/取模 → 高 cost（20+ cycle）→ 触发 strength_reduction
        Div | Mod                    => 20,
        // 内存访问 → 中高 cost
        Load                         => 3,
        Store                        => 4,
        // 函数调用 → 最高 cost（触发内联决策）
        XabiCall                     => 10,
        CabiCall                     => 50,    // FFI 更贵
    }
}

// 提取策略：从 e-graph 中选择 cost 最小的等价表示
fn egraph_extract(egraph: EGraph) -> IRInst {
    // 对每个等价类，选择 cost 最小的代表
    // 递归计算子表达式的 cost
    // 动态规划：memoized extraction
}
```

### 4.4 提取策略

| 策略 | 适用场景 | 说明 |
|------|----------|------|
| **最小 cost 提取** | 默认 | 选择 cost function 最小的等价表示 |
| **profile-guided 提取** | PGO 开启时 | 结合运行时 profile，热点路径优先选择更激进的等价表示 |
| **target-aware 提取** | Target MIR | 结合微架构 cost（如 Apple M 的除法 vs 乘法+移位） |

### 4.5 e-graph 与传统 pass 的协同

```
SMIR pass（传统）         SLIR e-graph（现代）
  ├─ inline_xabi             ├─ egraph_build
  ├─ alias_analysis    →     ├─ egraph_rewrite{rules: stdlib + custom}
  ├─ cse                    ├─ egraph_extract{cost: inst_cost}
  └─ loop_invariant         └─ (e-graph 自动覆盖 CSE/loop invariant/_strength reduction)

传统 pass 做"结构变换"（内联/循环展开），e-graph 做"等价优化"（代数化简/强度削减）。
两者互补，不冲突。
```

### 4.6 分层饱和策略（防止 e-graph 爆炸）

> e-graph 在大规模模块（全程序内联后）中极其消耗内存，重写规则过多会导致饱和时间指数级增长。采用**分层饱和**控制爆炸。

**分块策略**：**以函数为主分块单位**，函数内 region 隔离（不建独立 e-graph，但作为 alias 分析边界），不一次性在全程序 e-graph 上饱和。

```
全程序 e-graph（不饱和）
  │
  ├─ Function 边界分块（主分块单位）
  │   · 每个函数构建一个独立 e-graph 实例
  │   · 函数内饱和 → 提取最优 → arena_reset 释放
  │   · 跨函数优化由 SMIR 内联 pass 处理，不在 e-graph 层
  │
  ├─ 函数内 Region 隔离（alias 边界，非独立 e-graph）
  │   · 不同 Arena region 的指针自动标记 noalias（§4.2 alias_optim）
  │   · region 隔离作为 e-graph 重写规则的约束输入，不分裂 e-graph
  │   · 避免过度细分导致 e-graph 实例过多（100 个 region → 100 个 e-graph = 爆炸）
  │
  └─ 全程序级（可选，仅 PGO 热点）
      · 仅对 PGO 标记的跨函数热点路径构建全局 e-graph
      · 限制等价类数量上限（如 10k 节点）
      · 使用增量 GC 而非 arena_reset（生命周期跨函数）
```

> **为什么不是"每个 Region 一个 e-graph"？** Region 是 Arena 内存粒度，一个函数可能使用多个 region，但指令优化以函数为单位（控制流、数据流都在函数内）。若每个 region 建独立 e-graph，会导致：① e-graph 实例过多（100 region = 100 e-graph）；② 跨 region 的指令无法在同一个等价类中比较；③ 函数级优化（如 LICM）无法跨 region 工作。正确做法是**函数一个 e-graph + region 作为 alias 边界**。

**规则优先级**：

```shux
// 规则按优先级分批应用，不一次性全部注入
rewrite priority {
    // P0: 代数化简（最快、最高频）
    algebra_simplify,        // x+0→x, x*1→x, ...
    strength_reduction,      // x*2→x<<1, x/2^n→x>>n

    // P1: 契约驱动（中速、中频）
    linear_optim,            // move 后访问消除
    alias_optim,             // cross-region noalias

    // P2: 激进搜索（慢、低频，仅热点函数）
    superoptimizer_search,   // beam search 最优指令序列
}
```

**饱和控制**：
- 每个分块 e-graph 设等价类节点上限（默认 10k）；
- 超过上限 → 停止重写，提取当前最优 → 报告 "e-graph capped" 警告；
- P0 规则先饱和到 fixpoint → 应用 P1 → 应用 P2，逐级深化。

### 4.7 规则冲突解决机制

> e-graph 与传统 term rewriting 的根本差异：**重写不是"替换"而是"添加等价类成员"**——原始节点保留，新表示作为同一等价类的另一个成员加入。因此"规则冲突"不丢失信息，由提取阶段的 cost function 仲裁。

**冲突类型与处理**：

| 冲突类型 | 示例 | 处理方式 |
|----------|------|----------|
| 多规则匹配同节点 | `x*2` 同时匹配 `mul_two_shift`（→`x<<1`）与 `algebra_simplify`（无匹配） | 全部添加到等价类，cost function 选最小者 |
| 规则互逆 | A: `x→x+0`，B: `x+0→x` | 都加入等价类；饱和检测（等价类不再增长）自动终止 |
| 规则振荡 | A: `a→b`，B: `b→c`，C: `c→a` | 饱和检测 + 节点上限双重保险，到达 fixpoint 即停 |
| 契约矛盾 | 规则 A 要求 `region_alive(r)`，规则 B 已 emit `arena_reset(r)` | 静态拒绝：契约不一致的规则不可同时注入等价类 |
| 优先级冲突 | P0 与 P1 规则产生不同等价表示 | P0 先饱和到 fixpoint 再注入 P1，P1 看到的是 P0 收敛后的状态 |

**等价类合并规则**：

```shux
// 当规则触发，等价类合并语义
rewrite apply(lhs_pattern, rhs_pattern, eclass_id) {
    // 1. 匹配 lhs_pattern → 找到 src_eclass
    // 2. 构造 rhs_pattern → 创建/查找 dst_eclass
    // 3. 合并 src_eclass 与 dst_eclass（union-find）
    // 4. 触发下游规则重新匹配（增量饱和）
    // 5. 原始节点保留 → 不丢失信息
}
```

**反向规则安全性**：e-graph 天然支持"等价类扩张"而非"替换"，因此 `x→x+0` 与 `x+0→x` 同时存在不会破坏语义——两者都加入同一等价类，提取阶段按 cost 选 `x`（cost=0）而非 `x+0`（cost=2）。

### 4.8 e-graph 内存管理策略

> e-graph 节点池必须用 Arena 分配——契合 SHUX 内存哲学，且与 §4.6 分块饱和的"用完即释放"模式天然匹配。

**数据结构布局**：

```shux
// e-graph 内存结构（Arena-native）
struct EGraph {
    // 节点池：紧致数组存储，避免碎片
    nodes: Arena<EClassNode>,           // 每个 EClassNode 含多个 ENode（等价表示）
    // 等价类映射：union-find，路径压缩
    uf: UnionFind,                      // EClassId → EClassId (root)
    // 反向索引：模式匹配用
    cons_hash: HashMap<ESymbol, [EClassId]>,
    // 内存预算（节点上限）
    budget: usize,
}

// 单个 ENode（等价类成员）
struct ENode {
    op: Opcode,                         // 操作码
    children: [EClassId],               // 子等价类引用（不是直接子节点）
    // 不存储 cost——提取时动态计算
}
```

**生命周期与释放**：

```
分块 e-graph 生命周期
  │
  ├─ 创建：进入 Region/Function 边界
  │   · arena_alloc 一次性分配节点池
  │   · 预留 budget = 10k 节点空间
  │
  ├─ 饱和：注入规则 + 等价类扩张
  │   · 节点池写满 → 触发 "capped" 提前终止
  │   · 不做增量 GC（饱和阶段开销敏感）
  │
  ├─ 提取：cost function 选最优
  │   · 提取后只保留选中的 IR 子树
  │
  └─ 释放：arena_reset 一次性回收
      · 整个 e-graph 内存块 O(1) 回收
      · 不需要逐节点 free
```

**与 union-find 的协同**：
- union-find 的路径压缩不修改节点池，只修改父指针数组——内存局部性好；
- 等价类合并不复制节点，只更新 uf 映射；
- "陈旧"的 ENode（被合并到其它等价类）不立即回收——保留供模式匹配回溯，arena_reset 时统一清理。

**与 SHUX Arena 的对接**：

| IR 层 Arena 操作 | e-graph 用途 |
|------------------|--------------|
| `region_alloc("egraph_fn_42", budget)` | 进入函数边界时分配节点池 |
| `arena_alloc(egraph_region, sizeof(ENode))` | 新等价类成员分配 |
| `arena_reset(egraph_region)` | 函数饱和+提取完成后一次性回收 |

**全程序级 e-graph（PGO 热点）**：
- 不使用 arena_reset（跨函数生命周期长）；
- 改用增量 GC：标记-清除被取代的等价类成员；
- 节点上限严格控制在 10k（防爆炸）。

### 4.9 SLIR immutable 原则

> **不可变图设计**：SLIR 层的 IR 图是不可变的（immutable）——pass 不修改 Instruction，而是生成新 Graph。这是 LLVM 未来也在走的方向，收益是 Parallel Pass / Incremental Compile / Undo 都会简单很多。

**核心规则**：

```
传统 pass：  Graph → mutate Instruction → 同一 Graph（in-place 修改）
SLIR pass：  Graph_old → pass → Graph_new（旧图保留，新图独立）
```

```shux
// SLIR pass 接口（函数式，输入旧图输出新图）
trait SLIRPass {
    fn run(input: &SLIRGraph) -> SLIRGraph;  // 不修改 input
}

// e-graph 天然 immutable：添加等价类成员不删除旧节点
// 其他 SLIR pass 也遵循此模式：
//   · LICM：生成新的循环外提图，旧循环图保留
//   · CSE：生成新的公共子表达式图，旧图保留
//   · Superoptimizer：生成新的优化序列，旧序列保留
```

**收益**：

| 特性 | mutable IR | immutable SLIR |
|------|:---:|:---:|
| Parallel Pass | ❌（数据竞争） | ✅（多 pass 并行读旧图，各自输出新图） |
| Incremental Compile | ❌（需重建整个图） | ✅（只重跑受影响 pass，旧图复用） |
| Undo / 回退 | ❌（需 checkpoint） | ✅（旧图就是 checkpoint） |
| 调试（pass 间对比） | ❌（图被覆盖） | ✅（保留所有中间版本） |
| 内存 | ✅（原地修改） | ⚠️（多版本，需 GC） |

**内存管理**：
- SLIR 图版本通过 generation ID 索引（`SLIRGraph{gen: u32, ...}`）；
- Incremental Compile 时只保留"最新 + 上一个"两个版本，旧版本 arena_reset；
- Debug 模式可保留全部版本（`--dump-ir=slir-all-gens`）；
- e-graph 本身已天然 immutable（§4.7-4.8），此原则扩展到所有 SLIR pass。

**适用范围**：
- ✅ SLIR 层全部 pass（e-graph / LICM / CSE / Superoptimizer / SoA）；
- ⚠️ SMIR 层部分 pass（内联等结构性变换仍需 mutable，因 SSA 重命名代价高）；
- ❌ Target MIR 层不适用（寄存器分配是高度 mutable 的图染色算法）。

> **工程节奏**：SLIR immutable 是 Phase 3-4 的工程优化目标，不阻塞 Phase 1-2。Phase 3 初期可先用 mutable 实现，Phase 4 稳定后逐步 immutable 化。

---

## 5. 极致优化管道

### 5.1 Superoptimizer 集成方案

> 对热点函数使用搜索技术生成**最优指令序列**，超越传统 tree pattern matching。

**触发条件**：
- PGO 标记的热点函数（执行次数 > 阈值）；
- 函数体 < N 条指令（控制搜索空间，N ≈ 30）。

**搜索空间控制**：

```shux
// Superoptimizer 工作流
fn superoptimize(hot_fn: IRFn, target: TargetMIR) -> IRFn {
    // 1. 从 e-graph 获取等价空间（已饱和）
    let equiv_space = egraph_extract_all(hot_fn);

    // 2. 约束搜索：限制指令数 + 限定可用指令集
    let constraints = SearchConstraints {
        max_insts: 30,
        allowed_opcodes: target.fast_opcodes(),  // 排除昂贵指令
        max_cycles: profile.estimated_cycles(hot_fn),
    };

    // 3. Beam search：广度优先 + cost 剪枝
    let candidates = beam_search(equiv_space, constraints, beam_width=100);

    // 4. 验证等价性（差分测试：候选 vs 原函数）
    let verified = candidates.filter(|c| differential_test(c, hot_fn));

    // 5. 选择 cost 最小的验证通过候选
    return verified.min_by_key(|c| target.estimate_cost(c));
}
```

**与 e-graph 协同**：e-graph 提供等价空间，Superoptimizer 在其中搜索最优。e-graph 做了大部分工作，Superoptimizer 只在热点函数上做"最后一英里"的极致搜索。

### 5.2 SoA/AoS 布局转换 Pass

> 基于访问模式自动进行 **Structure of Arrays ↔ Array of Structures** 转换。

```shux
// SoA 转换 Pass 工作流
fn pass_soa_transform(smir: SMIR) -> SMIR {
    // 1. 访问模式分析
    //    检测：对 []Struct 的循环访问模式
    //    若循环内只访问 .field_a 而不访问 .field_b → SoA 收益
    let access_patterns = analyze_field_access(smir);

    // 2. 收益评估
    //    SoA 收益 = cache_line 利用率提升 + 向量化可行性
    //    SoA 代价 = 结构体重构 + 非连续字段访问退化
    let candidates = access_patterns.filter(|p| soa_benefit(p) > soa_cost(p));

    // 3. 布局转换
    //    []Struct{a, b, c} → SoA{a: []A, b: []B, c: []C}
    //    重写访问：s[i].a → soa.a[i]
    for pattern in candidates {
        rewrite_struct_to_soa(smir, pattern);
    }

    // 4. 契约验证：转换后 pre/post condition 不变
    verify_contract_equivalence(smir);
}
```

**适用场景**：x-neuron 的 1k 结点对象池、内核 PCB 数组、SIMD 向量化前置。

### 5.3 寄存器分配策略

> 基于 region 的 Graph Coloring + 热度感知 spilling。

```shux
// 寄存器分配 Pass（Target MIR 层）
fn pass_reg_alloc(mir: TargetMIR, target: Target) -> TargetMIR {
    // 1. 构建干涉图（Interference Graph）
    //    节点 = SSA 虚拟寄存器，边 = 同时活跃的寄存器对
    let igraph = build_interference_graph(mir);

    // 2. Region-aware 优化
    //    同一 region 内的 Arena 指针 → 生命周期短 → 优先分配 caller-save 寄存器
    //    跨 region 的长期对象 → 分配 callee-save 寄存器
    annotate_region_info(igraph, mir);

    // 3. 热度感知 Coloring
    //    热点路径上的寄存器 → 优先分配物理寄存器（避免 spill）
    //    冷路径上的寄存器 → 可 spill 到栈
    let assignment = graph_coloring(igraph, target.registers(), {
        priority: hotness_aware,  // 热点优先
    });

    // 4. Spill 决策
    //    热度 < threshold 的寄存器 → spill
    //    Arena 内对象 → spill 到 region 内（arena_reset 统一回收，无需逐对象 free）
    let spilled = spill_low_hotness(assignment, mir);

    // 5. 插入 load/store（spill 补偿）
    insert_spill_code(mir, spilled);
}
```

| 策略 | 适用对象 | 分配目标 |
|------|----------|----------|
| 热点优先 | PGO 标记的热路径变量 | 物理寄存器（避免 spill） |
| Region-aware | Arena 内短期对象 | caller-save 寄存器 |
| 长期对象 | 跨 region 存活变量 | callee-save 寄存器 |
| 冷路径 | 低热度变量 | spill 到栈 / Arena region |

### 5.4 Region-Aware Memory Optimization

- 基于 `region_id` 做精确的 Escape Analysis + Stack Allocation；
- Arena 内对象自动复用内存槽（zero-copy move）；
- `arena_reset` 作为 IR 层显式回收原语，替代逐对象 `free`；
- 跨 region 指针自动标记 `#[noalias]`。

### 5.5 Linear-Driven Optimization

> 基于 SHUX `Linear(T)` 语义，非 Rust borrow checker。

- Linear move 语义驱动 Load/Store 消除（move 后原引用确定性失效）；
- `#[move_consumes]` 契约保证：move 后直接消除原对象的 drop 检查；
- 编译期所有权图验证：move 后不可再访问，IR 层直接消除悬空指针检查。

### 5.6 全程序激进内联 + Specialization

- X ABI 边界允许跨模块内联（C ABI 禁止）；
- 基于 profile + region 信息的多版本生成；
- 泛型 monomorphization + 热点路径特化。

| 热度 | 调用约定 | 策略 |
|------|----------|------|
| 热点 | X ABI 激进约定 | 全寄存器传参 + 最小 callee-save + 内联 |
| 常规 | X ABI 标准约定 | 标准寄存器传参 |
| FFI | C ABI | System V / AAPCS + unsafe |

### 5.7 向量化和 SIMD 优化

- 语言层面 `vector` + autovec 规则直接映射到 IR；
- 自动生成多版本代码（SSE / AVX / NEON / SVE）；
- e-graph 驱动的自动向量化发现（重写规则：`loop{load, op, store}` → `vectorized_loop`）。

### 5.8 微架构感知后端

- 为 Apple M 系列、Zen5、Intel Lunar Lake 等特定 CPU 建模流水线 + 执行端口；
- 指令调度对齐微架构执行端口宽度；
- PGO + BOLT 风格的二进制布局优化。

### 5.9 JIT 热点优化（可选）

> 极致路径，非必须。自举后远期评估。

- 运行时检测热点 → 触发 IR 重新优化 → 热替换代码页；
- 与 External Pass Provider 协同——其生成的优化 Pass 可动态注入 SLIR pipeline；
- 安全约束：JIT 代码页必须 W^X（写时不执行，执行时不写）。

---

## 6. 声明式 Pass Pipeline

### 6.1 Pipeline 配置

```shux
// pass pipeline 配置（声明式）
pipeline {
    // SHIR 层
    pass: [monomorphize, dead_code_elim, contract_extract],

    // SMIR 层
    pass: [inline_xabi, alias_analysis, cse, loop_invariant],

    // SLIR 层（e-graph 驱动）
    pass: [
        egraph_build,
        egraph_rewrite{rules: ["algebra_simplify", "strength_reduction",
                                "linear_optim", "alias_optim"]},
        egraph_extract{cost: inst_cost},
        superoptimize{hot_fns_only: true, max_insts: 30},
        soa_transform{threshold: 0.5},
    ],

    // Target MIR 层
    pass: [reg_alloc{strategy: "region_aware_hotness"},
           isel, schedule, microarch_align],
}
```

### 6.2 动态注入（External Pass Provider 协同）

External Pass Provider（外部 Pass 提供方，如自适应优化层、运行时 profile 反馈系统等）生成的优化 Pass 可通过声明式 pipeline 动态注入：

```shux
// External Pass Provider 生成的新 Pass 注入示例
pipeline {
    // ... 标准 pass ...
    pass: [egraph_rewrite{rules: ["stdlib", "external_generated_pass_42"]}],
}
```

---

## 7. 所有权与内存模型

### 7.1 Region-Aware 内存模型

```
┌─────────────────────────────────────────────┐
│  Region A (Arena: 编译期临时)                 │
│  · lifetime: 函数作用域                       │
│  · 回收: arena_reset (O(1))                  │
│  · 优化: stack allocation + zero-copy move   │
├─────────────────────────────────────────────┤
│  Region B (Arena: 任务级)                    │
│  · lifetime: 任务生命周期                     │
│  · 回收: 任务退出时 arena_reset              │
│  · 优化: region 隔离 → noalias               │
├─────────────────────────────────────────────┤
│  Region C (全局静态)                         │
│  · lifetime: 程序全程                         │
│  · 回收: 不回收                               │
│  · 优化: readonly → CSE / 常量传播            │
└─────────────────────────────────────────────┘
```

### 7.2 所有权转移在 IR 层的编码

```shux
// .x 源码
let a: Linear<String> = string_new("hello");
let b: Linear<String> = a;          // move: a 失效
drop(b);                             // 显式消耗

// SHIR 表示
%1 = linear_move %a                  // 契约: %a consumed, 不可再访问
linear_consume %1                    // 契约: %1 consumed, 无需 drop
// IR 可证明: %a 之后无引用 → 无需 drop check
// IR 可证明: %1 被 consume → 无需 drop check
```

---

## 8. 调用约定与 ABI 设计

### 8.1 多级调用约定

| 级别 | ABI | 适用场景 | 内联 | 安全性 |
|------|-----|----------|------|--------|
| 激进 | X ABI 热点约定 | 热点函数 | ✅ 跨模块内联 | 编译器保证 |
| 标准 | X ABI 标准约定 | 常规 SHUX-to-SHUX | ✅ | 编译器保证 |
| FFI | C ABI | 调用 C 库/系统调用 | ❌ 禁止 | 需 `unsafe` |

### 8.2 与 X ABI 设计的关系

IR 层的 ABI 区分直接映射到 [X ABI 设计分析](file:///home/shu/shux/analysis/X-ABI-设计分析.md) 的决策：

- `extern function`（默认 X ABI）→ `x_abi_call`（可内联）；
- `extern "C"` → `c_abi_call`（FFI 边界，禁止内联，需 `unsafe`）。

---

## 9. 验证与测试策略

### 9.1 解释执行器（早期语义验证）

> **关键策略**：IR 早期阶段先实现**解释器**，快速验证语义正确性，再逐步替换为原生 codegen。

- SHIR 解释器：逐条执行契约指令，验证契约一致性；
- SMIR 解释器：验证 SSA + 所有权图正确性；
- 解释器是 codegen 的"语义 oracle"——codegen 产出必须与解释器结果一致。

### 9.2 Differential Fuzzing + Oracle

- 生成随机 `.x` 程序，同时跑旧 C 后端和新 IR 后端，比对执行结果；
- 对齐 [内核级语言 §11.1](file:///home/shu/shux/analysis/内核级语言.md) 差分测试；
- 三个 oracle：C 后端结果、IR 解释器结果、IR codegen 结果——三者必须一致。

### 9.3 Performance Oracle 门控

- 任何优化 Pass 必须通过 Performance Oracle 验证才有资格合入主线；
- 性能不提升或回归的 Pass 被自动拒绝；
- 基准集对齐 [性能基准测试](file:///home/shu/shux/性能基准测试.md) 四层框架。

### 9.4 分层验证

- `SHIR → SMIR → SLIR → VMIR → Target MIR` 每层都有独立验证器；
- 契约一致性检查：lowering 前后契约必须等价；
- 持续性能回归：每天跑 benchmark suite + 自动 bisector 找回归。

### 9.5 关于形式化证明的决策

> **拒绝 Lean4 / Coq**：自举前不引入外部定理证明器依赖。SHUX 的"证明"靠编译期类型系统保证——`Linear(T)` + Region + X ABI 契约本身就是编译期可验证的形式化系统。

| 方式 | 适用场景 | 决策 |
|------|----------|------|
| 编译期类型系统证明 | Linear move / Region 隔离 / X ABI 安全 | ✅ 采用 |
| 契约一致性检查 | lowering 前后等价 | ✅ 采用 |
| 差分测试 + Fuzzing | 端到端语义正确性 | ✅ 采用 |
| Lean4 / Coq 辅助证明 | 复杂转换规则形式化 | ❌ 拒绝（过度工程） |

---

## 10. 硬件适配层

### 10.1 微架构建模

| 微架构 | 建模内容 |
|--------|----------|
| Apple M 系列 (Firestorm/Icestorm) | 执行端口宽度、ROB 深度、cache 层级 |
| AMD Zen5 | 流水线延迟、分支预测器特性 |
| Intel Lunar Lake | P-core/E-core 调度感知 |

### 10.2 指令调度

- 模仿/超越 LLVM MISched 的指令调度器；
- 基于微架构模型做 port-aware 调度；
- 热点代码集中放置 + icache 友好布局。

### 10.3 可插件化 Cost Model（多维度）

> 静态流水线建模赶不上 CPU 硬件变动（如 Apple M 系列在 iOS/Mac 上的微调）。将硬件成本模型作为**多维度可插件化配置**，通过外部文件定义，无需改动核心 IR 代码。新 CPU（如 M8 / Zen7）发布时只需新增 `.cost.json`，不重编译编译器。

**六大维度**（每个维度独立可配置，可按需启用）：

| 维度 | 消费者 | 影响决策 | 示例 |
|------|--------|----------|------|
| **Instruction Cost** | e-graph 提取 / Superoptimizer | 等价表示选优 | `div: 20` vs `shift+mul: 4` |
| **Register Pressure** | 寄存器分配 / spilling | 内联决策 / spill 优先级 | 高压力时拒绝过度内联 |
| **Cache Hierarchy** | 循环优化 / SoA 决策 | tiling 大小 / SoA vs AoS | L1 128KB → tile 4KB |
| **Branch Prediction** | 分支布局 / unlikely 标记 | fall-through 方向 | 误预测代价 15 cycle |
| **SIMD Capacity** | 向量化决策 | 向量宽度 / 掩码策略 | NEON 128bit vs SVE 2048bit |
| **Pipeline Model** | 指令调度 | port-aware 调度 | ALU 4 端口 / Load 2 端口 |

```shux
// 多维度 Cost Model 配置（JSON/DSL，可独立更新）
// targets/apple_m5.cost.json
{
    "target": "apple_m5_firestorm",
    "version": "1.0",

    // 维度 1：指令成本（e-graph 提取消费）
    "inst_costs": {
        "add": 1,  "sub": 1,  "mul": 3,
        "div": 20, "mod": 22,
        "load": 3, "store": 4,
        "fma": 2,   // M5 有独立 FMA 单元
    },

    // 维度 2：寄存器压力模型（内联 / spill 决策消费）
    "register_pressure": {
        "gp_regs": 16,          // 通用寄存器数
        "fp_regs": 32,          // 浮点/SIMD 寄存器数
        "callee_saved": ["x19-x28", "v8-v15"],
        "spill_cost": 8,        // spill 到栈的代价
        "reload_cost": 6,       // reload 代价
        "inline_pressure_threshold": 0.8,  // 压力超过 80% 拒绝内联
    },

    // 维度 3：Cache 层级（循环 tiling / SoA 决策消费）
    "cache_hierarchy": {
        "l1": {"size_kb": 128, "latency_cycles": 3, "associativity": 8},
        "l2": {"size_kb": 4096, "latency_cycles": 12, "associativity": 16},
        "l3": {"size_kb": 16384, "latency_cycles": 40},
        "tlb_entries": 64,
        "prefetch_distance": 256,   // 软件预取距离（字节）
    },

    // 维度 4：分支预测模型（分支布局消费）
    "branch_model": {
        "mispredict_penalty": 15,   // 误预测代价（cycle）
        "btb_entries": 4096,
        "likely_hint_weight": 0.95, // branch_predict 指令权重
    },

    // 维度 5：SIMD 容量（向量化决策消费）
    "simd_capacity": {
        "vector_width_bits": 128,   // NEON 128bit
        "mask_register": true,
        "gather_scatter": false,    // M5 NEON 无 gather
        "fma_unit": true,
        "permute_cost": 2,
    },

    // 维度 6：流水线端口模型（指令调度消费）
    "pipeline_model": {
        "alu_ports": 4,
        "load_ports": 2,
        "store_ports": 1,
        "fpu_ports": 3,
        "branch_ports": 1,
        "issue_width": 6,           // 每周期发射 6 条
        "rob_size": 384,
    },
}
```

**设计约束**：
- Cost Model 文件与编译器版本解耦——新 CPU 发布时只需新增 `.cost.json`，不需要重新编译编译器；
- **维度可选**：缺失的维度按内置默认值兜底（如不配 `simd_capacity` 则禁用向量化）；
- 内置默认 Cost Model（fallback），完全无配置时按通用 x86_64/ARM64 估算；
- `--target-cost=apple_m5.cost.json` 编译选项指定 Cost Model 文件；
- 与 §4.3 的 `inst_cost` 函数对接——e-graph 提取时消费维度 1；
- 寄存器分配消费维度 2，向量化 pass 消费维度 5，指令调度消费维度 6——**各 Pass 按需读取维度，不耦合全量配置**。

---

## 11. 演进路线图

> **去掉时间估计，只写技术依赖关系**。对齐 SHUX 工程哲学：自举前最小必要，自举后功能扩展。

```
自举完成（当前唯一关键路径）
  │
  ▼
[Phase 0] Contract-Annotated C-Emitter（IR 前置验证）
  · 修改现有 .x → .c 生成器，在 C 代码中输出注释形式的 Contract
  · 提前验证契约完备性，无需先造 IR 后端
  · 输出示例：/* @contract: pre=[region_alive(r1)] post=[linear_consumed(v1)] */
  · 目标：验证 Contract 提取逻辑正确，为 Phase 1 IR 降低风险
  │
  ▼
[Phase 1] SHIR 基础
  · 契约结构体定义（Contract struct + ContractPool 池化 §1.2）
  · Effect 独立子系统（EffectPool §1.7）
  · 核心指令集实现（§3.1 表）
  · .x → SHIR lowering + 契约提取
  · SHIR 解释器（语义验证）
  · 双后端验证：IR → C + IR → asm
  · 所有权图验证优先（Linear move 不可复制 > 常量折叠）
  │
  ▼
[Phase 2] SMIR + 所有权验证
  · SSA 构建 + 所有权图
  · 契约一致性检查（lowering 时三步验证）
  · X ABI 跨模块内联
  · Region-aware alias analysis
  │
  ▼
[Phase 3] SLIR + e-graph
  · e-graph 数据结构实现（§4.8 Arena-native）
  · 重写规则引擎（§4.2 语法）+ 规则冲突解决（§4.7）
  · Cost function + 提取策略（§4.3-4.4）
  · 分层饱和策略（§4.6 函数分块 + region 隔离）
  · 声明式 pipeline 框架
  │
  ▼
[Phase 4] Superoptimizer + 布局优化 + SLIR immutable
  · Superoptimizer 集成（§5.1，热点函数搜索）
  · SoA/AoS 布局转换 pass（§5.2）
  · e-graph 规则集扩充（linear_optim / alias_optim）
  · SLIR immutable 化（§4.9，pass 函数式接口）
  │
  ▼
[Phase 5] VMIR 指令选择（新增）
  · SLIR → VMIR lowering（机器无关运算 → 目标机器指令）
  · 模式匹配 isel（a+b → LEA/ADD/FMA 决策）
  · DAG 依赖图构建 + 早期指令调度
  · 契约物化（Contract → MachineInst 属性）
  · 多目标架构支持（x86_64 / ARM64 初期）
  │
  ▼
[Phase 6] Target MIR + 微架构
  · region-based Coloring 寄存器分配（§5.3）
  · 热度感知 spilling
  · 微架构流水线建模
  · 多维度 Cost Model 集成（§10.3 六维度）
  · PGO + BOLT 布局优化
  │
  ▼
[Phase 7] 极致压榨
  · 自动向量化（e-graph 驱动）
  · External Pass Provider 动态注入
  · 微架构感知指令调度
  · JIT 热点优化（可选）
```

### 11.1 依赖关系

| Phase | 前置依赖 | 核心交付 |
|-------|----------|----------|
| Phase 0 | 自举完成 | Contract-Annotated C-Emitter（契约提取验证） |
| Phase 1 | Phase 0 | 契约指令集 + ContractPool + EffectPool + 解释器 + 所有权图验证 |
| Phase 2 | Phase 1 | 所有权验证 + 内联 + 契约快照 |
| Phase 3 | Phase 2 | e-graph 引擎 + 分层饱和 + 规则冲突解决 + 声明式 pipeline |
| Phase 4 | Phase 3 | Superoptimizer + SoA 转换 + SLIR immutable |
| Phase 5 | Phase 4 | VMIR 指令选择 + DAG 调度 + 多架构 isel |
| Phase 6 | Phase 5 | 寄存器分配 + 微架构 + 多维度 Cost Model |
| Phase 7 | Phase 6 | 向量化 + External Pass Provider 协同 + JIT（可选） |

### 11.2 核心原则

**IR 设计不阻塞自举。** 自举是当前唯一关键路径，IR 是自举后的性能进化路径。自举前维持现有 C 后端 + asm 后端双轨，不引入新 IR 层。

**Architecture Freeze（v4.0 起生效）。** IR 总架构已冻结，不再做设计层重构。剩余 4 项"实现级"问题靠 Benchmark 和实现验证，不改架构：

| 实现级问题 | 性质 | 解决方式 |
|------------|------|----------|
| Contract 进一步压缩（热路径 Cache / Lazy Decode / Arena Allocation） | 性能优化 | 实现时 Benchmark 驱动，不改 Contract Pool 架构 |
| e-graph 默认预算（5k / 10k / 20k） | 参数调优 | Benchmark 决定，不改分层饱和策略 |
| Cost Model 新 CPU 配置（M7 / Zen6 / Zen7 / ARMv9 / RISC-V） | 数据维护 | 新增 `.cost.json`，不改 IR |
| Pass Pipeline 顺序（GVN / LICM / LoopRotate 谁先谁后） | 调度调优 | Benchmark 决定，不改声明式 pipeline 框架 |

> **冻结后允许修改的两种情况**：① 实现时发现某个设计根本写不出来；② Benchmark 证明某个设计性能反而下降。除此之外不再继续 Contract → Contract2 → Contract3 式无限重构。

### 11.3 IR 开发 Checklist

> 每个 Phase 落地前必须完成的"第一步 / 第二步 / 最小交付物"。最小交付物 = 进入下一 Phase 的硬性门槛（gate），不达标不推进。

| Phase | 第一步 | 第二步 | 最小交付物（Gate） |
|-------|--------|--------|--------------------|
| **Phase 0** Contract-Annotated C-Emitter | 修改现有 `.x → .c` 生成器，输出 `/* @contract: pre=[...] post=[...] */` 注释 | 写 Contract 提取验证器：解析 .x AST + 检查 Contract 完备性（覆盖 Linear/Region/ABI） | 编译一段含 `Linear(T)` + Arena 的 .x 程序，C 输出含完整 Contract 注释，验证器 0 报错 |
| **Phase 1** SHIR 基础 | 定义 `Contract` struct + `ContractPool`（§1.2）+ `EffectPool`（§1.7）+ `IRInst` 池化引用（§2.4） | 实现 .x → SHIR lowering，覆盖 §3.1 核心 12 条契约指令 | SHIR 解释器能跑通 fibonacci + arena_alloc/arena_reset 示例，契约一致性 100% 通过 |
| **Phase 2** SMIR + 所有权验证 | SSA 构建（φ 节点 + def-use 链） + 所有权图 | 契约一致性三步检查（§1.3）+ X ABI 跨模块内联 | move-after-use 编译期报错；跨模块 X ABI 调用被内联；C ABI 禁止内联 |
| **Phase 3** SLIR + e-graph | e-graph 数据结构（§4.8：Arena-native + union-find）+ 分层饱和（§4.6 函数分块） | P0 规则集（algebra_simplify + strength_reduction）+ cost function + 提取器 + 规则冲突解决（§4.7） | algebra_simplify 通过差分测试；性能 ≥ 原 C 后端 1.0×（不回归即可） |
| **Phase 4** Superoptimizer + 布局优化 + SLIR immutable | Superoptimizer beam search（§5.1：热点函数 ≤ 30 指令） | SoA/AoS 转换 pass（§5.2）+ P1 规则集（linear_optim / alias_optim）+ SLIR immutable 化（§4.9） | 热点函数 cost 下降 ≥ 5%；SoA 转换在 x-neuron 1k 结点池跑通差分测试；SLIR pass 函数式接口通过 |
| **Phase 5** VMIR 指令选择 | SLIR → VMIR lowering 框架 + `MachineInst` 数据结构（§2.4） | 模式匹配 isel 规则集（x86_64 + ARM64）+ DAG 依赖图 + 早期调度 | 算术表达式 isel 正确率 100%（差分测试）；fibonacci 经 VMIR 生成可执行 .s |
| **Phase 6** Target MIR + 微架构 | region-aware Coloring 寄存器分配（§5.3）+ 热度感知 spilling | 多维度 Cost Model（§10.3：六维度 `.cost.json` 加载器）+ Apple M5 / Zen5 / Lunar Lake 三套配置 | 寄存器 spill 率 ≤ Clang -O2；六维度 Cost Model 文件通过单元测试 |
| **Phase 7** 极致压榨 | 自动向量化 pass（e-graph `loop{load,op,store}` → `vectorized_loop` 规则） | External Pass Provider 动态注入 pipeline（§6.2）+ 微架构感知指令调度 | 向量化覆盖率 ≥ 60%；External Pass Provider 注入的 Pass 通过 Performance Oracle 门控 |

**Checklist 使用规则**：
- 每个 Phase 的"最小交付物"必须有**自动化验证脚本**（差分测试 / Performance Oracle / 单元测试），不允许人工目测通过；
- Phase N 的最小交付物未达标 → 禁止启动 Phase N+1，避免上层 pass 建立在错误的下层 IR 之上；
- 交付物归档到 `analysis/ir-verify/phase<N>/` 目录，含测试输入、输出、性能数据。

---

## 12. 现实预期

### 12.1 可显著超越 C 的领域

- **内存安全子集下的性能**：`Linear(T)` + Arena 提供"零成本安全"，C 需要运行时检查；
- **Arena 密集场景**：O(1) 批量回收 vs C 的逐对象 `free`；
- **X ABI 跨模块内联**：C ABI 禁止跨编译单元内联，X ABI 允许；
- **e-graph 等价优化**：自动发现传统 pass 难以发现的全局最优；
- **契约驱动激进优化**：编译期证明 move/region/noalias，C 只能保守猜测；
- **Superoptimizer**：热点函数搜索最优指令序列，超越 tree pattern matching；
- **SoA 自动转换**：基于访问模式自动优化数据布局，C 需手动重写。

### 12.2 初期可能落后的领域

- 通用计算密集场景（编译器优化成熟度不足）；
- 需要 SIMD 密集的数值计算（向量化 pass 尚未成熟）；
- 需耐心迭代，长期优化投入后稳定领先。

---

## 13. 风险与权衡

> 极致性能不是免费的。本章诚实记录 IR 设计中可能反噬的风险与对应权衡策略，避免"纸上完美、落地翻车"。

### 13.1 e-graph 内存爆炸风险

| 维度 | 风险描述 | 影响范围 |
|------|----------|----------|
| 等价类扩张 | 重写规则组合爆炸：N 条规则可产生指数级等价表示 | SLIR 层 OOM / 编译卡死 |
| 全程序级饱和 | 跨函数 e-graph 节点数失控 | 编译时间从秒级退化到分钟级 |
| 规则互逆振荡 | `x→x+0` 与 `x+0→x` 反复触发 | 饱和不收敛 |

**权衡与缓解**：
- ✅ **分块饱和**（§4.6）：按 Region/Function 边界分块，不一次性全程序饱和；
- ✅ **节点上限**（默认 10k/块）：超限触发 "capped" 提前终止，提取当前最优；
- ✅ **优先级分层**（P0→P1→P2）：每层独立饱和到 fixpoint，避免规则交叉触发；
- ✅ **饱和检测**：等价类不再增长即停，杜绝振荡；
- ⚠️ **接受度**：capped 警告意味着可能错过理论最优——但比 OOM 翻车可接受，编译器日志会提示用户调整 `--egraph-budget`。

### 13.2 编译时间 vs 性能的权衡

| 优化档位 | 编译时间 | 运行时性能 | 适用场景 |
|----------|----------|------------|----------|
| `--opt=0` | 最快（仅 lowering + 基本寄存器分配） | 基线 | 开发期增量编译 |
| `--opt=1` | 中等（SMIR 内联 + CSE + 基本 e-graph P0） | 比 -O0 提升 30-50% | 日常 release |
| `--opt=2` | 慢（全 e-graph 饱和 + Superoptimizer 热点搜索） | 比 -O0 提升 50-80% | 性能关键构建 |
| `--opt=3` | 极慢（全程序 PGO e-graph + JIT 预热） | 接近理论最优 | 基准测试 / 发布版 |

**权衡决策**：
- 默认 `--opt=1`，不阻塞迭代；
- `--opt=2/3` 必须显式开启，CI 上对热点模块使用 `--opt=2`，发布前用 `--opt=3` 重编关键路径；
- Superoptimizer 仅对 PGO 标记且函数体 < 30 指令的热点函数触发，避免全程序搜索；
- **拒绝"为了 1% 性能损失 10× 编译时间"**——Performance Oracle 门控（§9.3）自动拒绝收益不达标的 Pass。

### 13.3 调试复杂度增加的风险

| 风险点 | 描述 | 缓解策略 |
|--------|------|----------|
| IR 层级多 | SHIR → SMIR → SLIR → VMIR → Target MIR 五层，bug 可能跨层传播 | 每层独立验证器（§9.4）+ 差分测试 oracle 对齐 |
| e-graph 提取不可预测 | 同一输入可能因规则集变化提取出不同最优表示 | 提取结果记录到 IR dump，可复现；规则集版本化（git pin） |
| 契约验证失败定位难 | lowering 时 panic，但根因可能在前端 typeck 或契约提取 | panic 信息携带 debug_loc + 契约不一致点详情，不输出"unknown error" |
| Superoptimizer 候选验证假阳性 | 差分测试样本不足 → 错误候选通过验证 | Differential Fuzzing 持续扩充样本；候选必须通过 N≥1000 随机输入 |
| 寄存器分配 spill 决策错误 | 热度信息缺失 → 热点变量被 spill → 性能退化 | 无 PGO 时保守分配（默认热点）；Performance Oracle 自动回归检测 |

**调试基础设施**（必须随 Phase 同步建设）：
- `--dump-ir=shir|smir|slir|mir`：每层 IR 文本 dump；
- `--dump-egraph`：e-graph 等价类图导出（DOT 格式，可可视化）；
- `--dump-pass-trace`：每个 pass 的输入/输出 IR 快照；
- `--verify-contract`：独立契约验证模式，只跑验证不跑优化。

### 13.4 其他风险

| 风险 | 描述 | 缓解 |
|------|------|------|
| **契约误报** | typeck 与 IR 契约提取逻辑不一致 → 正确代码被拒绝 | Phase 0 Contract-Annotated C-Emitter 提前对齐，误报即编译器 bug |
| **Cost Model 配置错误** | `.cost.json` 数据错误 → 优化方向反向 | Cost Model 文件版本化 + 单元测试；fallback 默认模型兜底 |
| **自举路径依赖** | IR 设计错误可能让自举后的编译器无法编译自身 | IR 设计不阻塞自举（§11.2）；自举用现有 C/asm 后端双轨，IR 是自举后增量切换 |
| **External Pass Provider 注入风险** | 动态注入的优化 Pass 可能破坏契约等价 | 注入 Pass 必须通过契约一致性检查 + Performance Oracle 门控，双闸门 |
| **JIT 安全风险** | 运行时代码生成可能被攻击 | W^X 内存保护（§5.9）；JIT 代码页写时不执行；远期才评估，非自举前路径 |

### 13.5 风险治理原则

1. **绝不静默退化**：任何 capped / 降级 / fallback 都必须输出到编译日志，不允许"假装最优"；
2. **门控优先于优化**：Performance Oracle 不通过的 Pass 不进主线，无论理论多漂亮；
3. **可回退设计**：每个激进优化（Superoptimizer / 全程序 e-graph / JIT）都有 `--no-<pass>` 开关，出问题可一键关闭；
4. **诚实标注已知缺陷**：§12.2 "初期可能落后的领域"必须随版本演进更新，不掩盖短板。
