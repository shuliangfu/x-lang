# ir/ — XLANG IR（Semantic IR v4.0 Architecture Freeze）

> **架构状态**：Architecture Freeze（v4.0 起）。总架构不再修改，仅允许实现级调整。
> **设计文档**：[analysis/IR核心设计.md](../../../analysis/IR核心设计.md)
> **核心定位**：Semantic IR——把 XLANG 语言语义（Linear / Region / X ABI）直接编码进 IR，并通过 Contract 在 lowering 和优化过程中持续验证。

## 五层 IR 架构

```
.x 源码 → SHIR → SMIR → SLIR → VMIR → Target MIR → .s/.o
```

| 层级 | 目录 | 核心职责 | Phase |
|------|------|----------|-------|
| SHIR | `shir/` | 语义保留 + 契约提取 + 高层结构 | Phase 1 |
| SMIR | `smir/` | SSA + 所有权验证 + X ABI 内联 | Phase 2 |
| SLIR | `slir/` | e-graph 极致优化（immutable） | Phase 3-4 |
| VMIR | `vmir/` | 指令选择（isel） | Phase 5 |
| Target MIR | `mir/` | 寄存器分配 + 微架构对齐 | Phase 6 |

## 目录结构

```
ir/
├── mod.x                        # 模块入口（re-export）
├── contract.x                   # Contract 结构体 + ContractPool（§1.2）
├── effect.x                     # Effect 枚举 + EffectPool（§1.7）
├── inst.x                       # IRInst / Operand / ABIKind / SSAReg（§2.4）
├── opcode.x                     # Opcode 枚举（§3.1 22 条指令）
├── abi.x                        # ABI 调用约定（§8）
├── verify.x                     # 契约验证机制（§1.3 三步检查）
│
├── shir/                        # SHIR 层（语义保留 + 契约提取 + 高层结构）
├── smir/                        # SMIR 层（SSA + 所有权验证）
├── slir/                        # SLIR 层（e-graph 极致优化）
├── vmir/                        # VMIR 层（指令选择）
├── mir/                         # Target MIR 层（寄存器分配 + 微架构）
├── pass/                        # 声明式 Pass Pipeline（§6）
├── target/                      # 硬件适配层（§10）+ Cost Model 配置
├── verify/                      # 验证与测试基础设施（§9）
└── c_emit/                      # Phase 0: Contract-Annotated C-Emitter
```

## 共享基础设施（ir/ 根目录）

| 文件 | 职责 | 设计文档 |
|------|------|----------|
| `contract.x` | Contract 结构体 + ContractPool（池化去重） | §1.2 |
| `effect.x` | Effect 枚举 + EffectPool（独立子系统） | §1.7 |
| `inst.x` | IRInst / Operand / ABIKind / SSAReg | §2.4 |
| `opcode.x` | 22 条核心指令 Opcode 枚举 | §3.1 |
| `abi.x` | X ABI / C ABI 调用约定 | §8 |
| `verify.x` | 契约三步验证（提取 / 前置检查 / 后置传播） | §1.3 |

## 各子目录职责

### shir/ — SHIR 层（Phase 1）
- `lower.x`：.x AST → SHIR lowering + 契约提取
- `interp.x`：SHIR 解释器（语义验证 oracle）
- `verify.x`：SHIR 层独立验证器

### smir/ — SMIR 层（Phase 2）
- `ssa.x`：SSA 构建（φ 节点 + def-use 链）
- `ownership.x`：所有权图（Linear move/borrow 边）
- `inline.x`：X ABI 跨模块内联 + 契约快照（§1.6）
- `alias.x`：Region-aware alias analysis
- `verify.x`：SMIR 层验证器

### slir/ — SLIR 层（Phase 3-4）
- `egraph.x`：e-graph 数据结构（Arena-native，§4.8）
- `rules.x`：重写规则定义（§4.2）
- `cost.x`：Cost function（§4.3）
- `extract.x`：提取策略（§4.4）
- `saturate.x`：分层饱和策略（§4.6 函数分块 + region 隔离）
- `conflict.x`：规则冲突解决（§4.7）
- `superopt.x`：Superoptimizer beam search（§5.1）
- `soa.x`：SoA/AoS 布局转换（§5.2）
- `verify.x`：SLIR 层验证器（含 immutable 检查，§4.9）

### vmir/ — VMIR 层（Phase 5）
- `machine_inst.x`：MachineInst / McOperand 数据结构（§2.4）
- `isel.x`：模式匹配指令选择（a+b → LEA/ADD/FMA）
- `dag.x`：DAG 依赖图构建
- `sched.x`：早期指令调度

### mir/ — Target MIR 层（Phase 6）
- `regalloc.x`：region-aware Coloring 寄存器分配（§5.3）
- `spill.x`：热度感知 spilling
- `sched.x`：最终指令调度
- `microarch.x`：微架构流水线建模 + 执行端口调度

### pass/ — 声明式 Pass Pipeline（Phase 3+）
- `pipeline.x`：声明式 pipeline 框架（§6.1）
- `registry.x`：Pass 注册表 + External Pass Provider 注入接口（§6.2）

### target/ — 硬件适配层（Phase 5+）
- `cost_model.x`：多维度 Cost Model 加载器（§10.3 六维度）
- `x86_64.x`：x86_64 目标描述
- `arm64.x`：ARM64 目标描述
- `costs/`：`.cost.json` 配置文件目录

### verify/ — 验证与测试基础设施（Phase 0+）
- `interp.x`：统一解释器框架（§9.1）
- `diff_test.x`：差分测试框架（§9.2，C 后端 vs IR 后端）
- `perf_oracle.x`：Performance Oracle 门控（§9.3）
- `fuzz.x`：Differential Fuzzing

### c_emit/ — Phase 0: Contract-Annotated C-Emitter
- `contract_annot.x`：Contract 注释生成器（`/* @contract: pre=[...] post=[...] */`）

## 设计约束

- **Architecture Freeze**：总架构不再修改。仅实现时发现不可行或 Benchmark 证明性能退化才允许调整。
- **IR 设计不阻塞自举**：自举前维持现有 C 后端 + asm 后端双轨，IR 是自举后的性能进化路径。
- **Pool 化设计**：Contract / Effect 全部池化去重，IRInst 只存 4 字节 ID。
- **SLIR immutable**：SLIR 层 pass 函数式接口，不改 Instruction，生成新 Graph。
- **文件命名**：简洁命名，无 `ir_` 前缀（因已在 `ir/` 目录下）。

## 流水线位置

```
parser → typeck → ir/shir (lowering) → ir/smir (SSA) → ir/slir (e-graph)
  → ir/vmir (isel) → ir/mir (regalloc) → codegen (.s/.o)
```

当前 codegen（C 后端）在 `codegen/codegen.x`，IR 落地后逐步替换。
