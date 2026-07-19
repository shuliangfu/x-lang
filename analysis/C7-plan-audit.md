# C7 plan 瘦身 audit（2026-07-19）

> **性质**：工程债 · P3 · 非阻塞 · docs-only audit（不涉及代码改动）
> **前置钉盘**：`305cfbe1`（C6 X ABI P0b 波 2 升钉）
> **候选来源**：`.trae/documents/cap-candidates-2026-07-19.md` §C7
> **铁律锚点**：`AGENTS.md`（根源 / G.7 / G.8 / G.9）· God-View First

## 0. 摘要：候选描述 vs 实际调查

`.trae/documents/cap-candidates-2026-07-19.md` §C7 候选描述：

- bstrict 套件冗余脚本合并（如多个 run-lang-*.sh 合并）
- skip 列表精简（W3 fast 跳过的 102 个脚本去重）

**实际调查结论**（God-View First 全库扫描）：

| 候选描述 | 实际调查 | 差距 |
|----------|----------|------|
| bstrict 套件冗余脚本合并 | 125 白名单内**无冗余**（所有 16 个 *-gate.sh 都是 ONLY-GATE；3 对候选对都有独立测试目标） | 描述与实际不符 |
| skip 列表精简（102 个去重） | W3 fast 23 项 ⊆ 125 白名单（性能子集，非冗余）；125 - 23 = 102 个被跳过的都在白名单内（金标，不能去重） | "skip 列表"语义不明 |
| 估时 0.5d | 真正瘦身需重构合并边界 case 到白名单脚本，工作量 > 0.5d | 估时偏小 |

**核心发现**：C7 候选描述与实际调查有差距。125 白名单内无冗余可裁剪；752 非白名单中 8 个完全无引用，但其中 7 个测试的边界 case **不被任何白名单脚本覆盖** → 删除会丢失覆盖，不是冗余。

## 1. 问题地图（881 vs 125 vs 23 vs 752）

```
tests/run-*.sh 总数:        881
├── 125 白名单（产品金标，run-all-bstrict.sh BSTRICT_SCRIPTS）
│   └── 23 W3 fast 子集（lib/w3-bstrict-fast.sh should_run case）
│       └── 23 项 ⊆ 125 白名单（包含关系，非冗余）
└── 752 非白名单（不在 BSTRICT_SCRIPTS）
    ├── 599 gate 脚本（*-gate.sh，manifest 完整性检查）
    ├── 94 other（杂项）
    ├── 24 perf（性能）
    ├── 10 compiler-internal（编译器内部）
    ├── 8 boot/bootstrap（启动/自举）
    ├── 5 lang（语言特性）
    ├── 3 safe（安全）
    ├── 3 engineering（工程）
    ├── 2 meta-meta-gate（gate-gate 套娃，有意命名）
    ├── 2 numbered-historical（数字编号历史）
    ├── 1 observability
    └── 1 documentation
```

## 2. 752 非白名单分类

### 2.1 gate 脚本 599 个（占 80%）

每对 gate + 非 gate 都有独立测试目标：
- **gate 版本**：检查 manifest 完整性（文档/层级/案例数 ≥ MIN）+ 调用非 gate 版本
- **非 gate 版本**：实际跑功能测试

**示例**（`run-lang-abi-stability-gate.sh` vs `run-lang-abi-stability.sh`）：
- gate 版本：检查 LANG-005 ABI 稳定 manifest（layers ≥ 6, cases ≥ 2, levels ≥ 6）+ 最后调用 `./tests/run-lang-abi-stability.sh`
- 非 gate 版本：跑 ABI layout (cc) + 可选 f32 xmm 测试

→ **不是冗余**，是 meta-gate + 功能测试的分层结构。合并需重构。

### 2.2 meta-meta-gate 2 个（gate-gate 套娃，有意命名）

- `run-eng-quality-gate-gate.sh`：ENG-002 质量门禁 manifest 完整性检查
- `run-lang-feature-gate-gate.sh`：LANG-001 feature gate manifest 完整性检查

→ **不是异常命名**，是有意的"门禁的门禁"（meta-meta-gate）模式。

### 2.3 8 个完全无引用 dead code 候选（详见 §3）

## 3. 8 个完全无引用 dead code 候选

### 3.1 静态 + 动态扫描结论

- **静态扫描**：grep -rnF 在 tests/ + compiler/Makefile + analysis/ 下查 .sh / .md / Makefile / .tsv / .py 引用 → 0 命中
- **动态调用扫描**：查 `bash ./tests/$s` / `chmod +x tests/$s` / `source tests/$s` / `. tests/$s` 模式 → 0 命中
- **git history**：7 个最后改动 `2bafa8d16` 2026-07-04 批量重命名 `.sx→.x`；1 个（run-fmt-unary-gate.sh）`ec51e8f04` 2026-07-05 批量更新 → **15 天未触碰**

### 3.2 8 个脚本清单 + 覆盖分析

| 脚本 | 行数 | 测试目标 | 白名单覆盖脚本 | 覆盖关键字命中数 | 删除安全性 |
|------|------|----------|----------------|------------------|-----------|
| run-core-assert.sh | 15 | core.assert + core.debug alias | run-builtin.sh | assert: 0 | 🔴 丢失 |
| run-fmt-unary-gate.sh | 83 | fmt 一元负号 -1 / 二元减法 a-1 格式化 | run-fmt.sh / run-fmt-cmd.sh / run-fmt-std.sh | unary/负号/minus/return -1: 0 | 🔴 丢失 |
| run-io-driver-process.sh | 24 | std.io 链路 + std.process spawn | run-process.sh | spawn: 7 | 🟡 可能覆盖 |
| run-perf-simd-shuxffle-select.sh | 101 | SIMD shuffle select 性能 | run-asm-vector-var.sh | simd: 0 | 🔴 丢失 |
| run-std-debug.sh | 12 | std.debug stderr + assert 重导出 | run-debug.sh | stderr: 0 | 🔴 丢失 |
| run-std-io-context-gate.sh | 91 | std.io context gate | run-io.sh | context: 0 | 🔴 丢失 |
| run-std-net-context-gate.sh | 90 | std.net context gate | run-net.sh | context: 0 | 🔴 丢失 |
| run-std-simd-shuxffle-select-gate.sh | 167 | std SIMD shuffle select gate | run-asm-vector-var.sh | simd: 0 | 🔴 丢失 |

### 3.3 关键结论

**8 个无引用脚本中 7 个测试的边界 case 不被任何白名单脚本覆盖**（只有 run-io-driver-process.sh 的 spawn 可能被 run-process.sh 覆盖）。

→ **"无引用" ≠ "冗余"**。这些是**历史遗留的边界 case 测试**，未被纳入 125 白名单但仍有价值。删除会丢失 7 个边界覆盖。

## 4. 30+ 对成对 gate + 非 gate（合并候选）

非白名单中 30+ 对成对存在（如 `run-lang-abi-stability-gate.sh` ↔ `run-lang-abi-stability.sh`）。

**合并可行性**：低。每对都有独立测试目标（meta-gate + 功能测试），合并需重构 manifest 检查逻辑嵌入功能测试脚本，工作量 > 1d/对。

## 5. 3 种裁剪路径 + 风险评估

### 路径 A（保守 · 扩容）：把 7 个边界 case 纳入白名单

- **操作**：把 8 个无引用脚本中 7 个（除 run-io-driver-process.sh，因 spawn 可能被覆盖）加入 `tests/run-all-bstrict.sh` BSTRICT_SCRIPTS 数组
- **风险**：低（只增不减，不破坏现有覆盖）
- **工作量**：~1d（需验证每个脚本在产品 shux_asm 下能通过 + L4 双端验证）
- **代价**：125 → 132 白名单（与"瘦身"目标相反）
- **副作用**：套件数增加，L4 跑时间变长

### 路径 B（激进 · 删除）：删除 8 个无引用脚本

- **操作**：`rm tests/run-core-assert.sh tests/run-fmt-unary-gate.sh tests/run-io-driver-process.sh tests/run-perf-simd-shuxffle-select.sh tests/run-std-debug.sh tests/run-std-io-context-gate.sh tests/run-std-net-context-gate.sh tests/run-std-simd-shuxffle-select-gate.sh`
- **风险**：高（丢失 7 个边界 case 覆盖；fmt 一元负号、SIMD shuffle、context gate 等）
- **工作量**：~0.5d（删除 + L2 验证 125 白名单不受影响）
- **代价**：丢失测试覆盖，违反根源治理（边界 case 应纳入白名单而非删除）
- **副作用**：未来若一元负号格式化回归，无测试守门

### 路径 C（重构 · 合并）：把 7 个边界 case 合并到对应白名单脚本

- **操作**：如把 run-fmt-unary-gate.sh 的一元负号 case 合并到 run-fmt.sh；run-std-debug.sh 的 stderr case 合并到 run-debug.sh；等等
- **风险**：中（重构现有白名单脚本，需重新验证）
- **工作量**：~3-5d（7 个 case × 重构 + 验证）
- **代价**：白名单脚本变长，但套件数减少
- **副作用**：符合"瘦身"目标，但工作量远超 0.5d 估时

### 推荐路径

**推荐路径 C（重构合并）**，但工作量超 0.5d 估时，需用户确认是否：
- (a) 接受工作量调整为 3-5d，按路径 C 推进
- (b) 接受路径 A 扩容（125 → 132），保留所有边界覆盖
- (c) 接受路径 B 删除（丢失 7 个边界覆盖）
- (d) 暂缓 C7，转其他候选（如 shux-x 5GB 方案 B / Cap C9 排期 / C6 P0b 波 3 std/ 标注）

### 实际执行结果（2026-07-19 · 用户选路径 C 后）

用户选择路径 C（重构合并）。实际执行 2/8 完成，剩余 6 个阻塞：

| 脚本 | 状态 | 阻塞原因 |
|------|------|----------|
| run-core-assert.sh | ✅ 合并到 run-debug.sh（commit `bedb40ca`） | — |
| run-io-driver-process.sh | ✅ 直接删除（hello.x 被 run-hello.sh 覆盖 + spawn_wait.x 被 run-process.sh L84 覆盖） | — |
| run-std-debug.sh | 🔴 阻塞 | **副产品发现 std.debug bug**：`println` 返回 `io.write_stderr` 字节数（11），而 `tests/std-debug/main.x` 期望 `a == 0`；语义不匹配导致 ec=1。bug 超出 C7 范围。 |
| run-fmt-unary-gate.sh | 🔴 阻塞 | **副产品发现 fmt 命令 bug**：`return -i` 被错误格式化为 `return - i`（一元负号被加空格）；`return -1` 同样被错误格式化。shux_asm + shux-c 都有此 bug（同一二进制）。bug 超出 C7 范围。 |
| run-perf-simd-shuxffle-select.sh | 🟡 类型不匹配 | STD-061 perf 对比（shuffle/select 生产 vs 标量桩基线），不适合合并到功能测试脚本 run-asm-vector-var.sh。 |
| run-std-simd-shuxffle-select-gate.sh | 🟡 类型不匹配 | STD-047 manifest 完整性 gate，不适合合并到功能测试脚本。 |
| run-std-io-context-gate.sh | 🟡 类型不匹配 | STD-091 std.io ↔ std.context 联动 gate，与 run-io.sh 功能测试类型不同。 |
| run-std-net-context-gate.sh | 🟡 类型不匹配 | STD-092 std.net ↔ std.context 联动 gate，与 run-net.sh 功能测试类型不同。 |

**路径 C 真实可行性**：2/8 完成（1 合并 + 1 删除）。剩余 6 个中 2 个有 bug（需先修 bug）、4 个是 gate/perf 类型不匹配（需调整合并策略或转路径 A 纳入白名单）。

**副产品发现的 bug（需单独修复，超出 C7 范围）**：
1. **std.debug.println 返回值语义 bug**：`println(ptr: *u8, len: i32)` 返回 `io.write_stderr` 的返回值（字节数），而非 0/1（成功/失败）。导致 `tests/std-debug/main.x` 的 `a == 0` 检查失败。修复方向：要么 println 返回 0/1（改实现），要么 main.x 改为 `a >= 0`（改测试）。
2. **fmt 命令一元负号 bug**：`return -i` / `return -1` 被错误格式化为 `return - i` / `return - 1`（一元负号后加空格）。但 `let a: i32 = -1;` 和 `neg(-1)` 的 -1 保持紧贴（正确）。修复方向：fmt 命令的 unary minus 识别逻辑漏了 `return` 上下文。

## 6. 建议下一步

鉴于 C7 路径 C 实际执行 2/8 完成，剩余 6 个阻塞（2 bug + 4 类型不匹配），**建议**：

- (a) 接受当前进度（2/8），C7 本波收口，剩余 6 个转后续波次（需先修 2 个 bug + 评估 4 个 gate/perf 合并策略）
- (b) 调整路径：剩余 4 个 gate/perf 转路径 A（纳入白名单扩容 125→129），保留覆盖但与瘦身相反
- (c) 修复 2 个 bug 后继续路径 C（std.debug + fmt unary 修复，工作量另计）
- (d) 暂缓 C7，转其他候选

**当前 PoC 已 commit** `bedb40ca`（run-core-assert.sh → run-debug.sh 合并 + audit 文档）。本波 C7 可在此收口。

## 7. 验证清单（路径选定后执行）

- [ ] 用户确认裁剪路径（A/B/C/d）
- [ ] 按选定路径执行代码改动
- [ ] L2 双端 bstrict 验证（125 白名单仍绿）
- [ ] 若路径 A/C：L4 双端真冷 + 升钉（套件数变化属产品边界）
- [ ] 若路径 B：L2 验证（删除非白名单脚本，不触发 L4）
- [ ] 更新 `自举进度.md` §3 前排 #4 + §6 变更记录
- [ ] 更新 `当前进度.md` §下一波前排 #2
- [ ] commit message 用英文（遵循 git-commit-message.md）

## 8. 相关文档

- [cap-candidates-2026-07-19.md](../.trae/documents/cap-candidates-2026-07-19.md) §C7（候选来源）
- [自举进度.md](自举进度.md) §3 前排 #4（C7 plan 瘦身）
- [当前进度.md](当前进度.md) §下一波前排 #2（C7 plan 瘦身）
- [自举方法.md](自举方法.md)（Cap/R/L/M）
- [AGENTS.md](../AGENTS.md)（根源 / G.7 / G.8 / G.9）
- skill `shux-selfhost-product-gate`（L4 / 双端 / 假绿禁止）
