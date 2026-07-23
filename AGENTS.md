# Xlang 项目协作准则

## 核心原则：根源治理

1. **所有 bug 必须从根源解决，禁止打补丁。**
   - Bug 必须回溯到 IR 发射器 / 前端 typeck / 内存分配器等真正的产生点
   - 禁止在热路径或下游消费端做 symptom-level 修补
   - 修复前必须理解完整数据流：谁产生、谁存储、谁消费

2. **上帝视角分析：先建问题地图，再动手。**
   - 遇到问题先从全局视角分析根因，而不是从当前报错点就近修补
   - 理清数据流和模块边界，确认修复点应该在系统的哪一层
   - 一个问题如果在不同模块有多个表现，说明根因在更底层
   - **防「修这里坏那里」**（强制细则见 skill  
     `~/.grok/skills/xlang-selfhost-product-gate/SKILL.md` → **「上帝视角纪律」**；  
     现场地图见 `analysis/问题分析文档.md` §0.17 / §0.18）：
     - 动手前五问：产生 / 存储 / 消费 / 同模式爆炸半径 / 最小回归集
     - **一条债一层一个 commit**；禁止批量改 std、改测试期望、soft-skip 糊绿顶编译器债
     - seed 与 `.x` / glue 副本同 commit；改后 Ubuntu 重建对应 `.o` + g05
     - 探针 + 邻域矩阵绿后才扩全量 bstrict

3. **禁止功能重复实现。**
   - 同一功能只能有一个权威实现；**同一功能的方法不得在多处实现**
   - 如果发现两处代码做同样的事，必须合并为单一实现
   - **全面分析后再动手**：弄清语义与落层 → 全库检索 → 再决定扩旧或新建
   - **有则补全**：方法已存在则在权威上**补充完整**（参数/表项/门控/边界），禁止半残权威旁再开第二套
   - **无才新增**：检索确认确实不存在（含近义名、seed/glue 副本）后才允许写新方法
   - **禁止随便打补丁**：禁止下游/热路径 `if (特例)` 糊绿；回到产生点权威修全
   - 特别注意：codegen 前缀解析、类型名解析、符号映射、overload 评分、link 门控等只能有一个权威路径
   - **细则（强制）**见 skill  
     `~/.grok/skills/xlang-selfhost-product-gate/SKILL.md` → **G.7**（决策树 G.7.0 + 铁律 + 检索清单 + 合入自检）

4. **禁止制造双权威。**
   - `.x` 一套、seed C 一套、文档硬编码再一套 = 三权威 = 必然漂移
   - 所有 ABI 面、类型前缀、符号名只能收敛，不能复制
   - seed 与 `.x` / glue 镜像若必须并存：**同 commit 同语义**，禁止长期分叉

5. **平台边界必须标注（macOS / Ubuntu / Windows / 共用）。**
   - 代码中凡平台分支、ABI、链接差异、seed pin、syscall 差异，注释写清  
     `PLATFORM: SHARED | POSIX | LINUX|UBUNTU | MACOS|DARWIN | WINDOWS`
   - **SHARED** 改动：macOS 与 Ubuntu **双端**验证；谈自举前双端冷编译 + 全量 `run-all-bstrict`
   - **禁止**把 macOS `-dead_strip` 下的绿当成 Linux 全链已过（UNDEF 常只在 Ubuntu 暴露）
   - **禁止**无注释的跨平台假设（修 A 打坏 B）
   - 细则见 skill  
     `~/.grok/skills/xlang-selfhost-product-gate/SKILL.md` → **G.8**  
     与 `references/platform-boundaries.md`

6. **`.x` 源码注释：详细、英文、覆盖每个方法与复杂逻辑（2026-07-16 起）。**
   - 写/改 **任何 `.x`**：每个 `function` / `export function` 必须有**详细英文 docblock**（用途、参数、返回值、契约/容量/空指针、必要时 `PLATFORM` / `#[no_mangle]` 原因）
   - **所有复杂逻辑**（多步算法、缓冲/cap、unsafe/FFI、平台分支、错误路径、非显然分支）必须在体内或紧邻处写**详细英文注释**
   - **从现在起禁止在 `.x` 新增中文注释**；触碰旧中文 docblock 且改行为时，同 commit 改为英文
   - 进度文档 / commit message / 对话可用中文；**源码注释以英文为准**
   - 细则见 skill  
     `~/.grok/skills/xlang-selfhost-product-gate/SKILL.md` → **G.9**  
     与 `references/x-english-comments.md`

## 执行纪律

- 每次修改前先读相关代码，理解上下文（含该块是哪一平台 / 是否 SHARED）
- 修改后必须在真实环境验证（Ubuntu x86_64 为金标准；SHARED 另加 macOS）
- **真冷测（L4，谈自举 / 结案默认）**：
  - **删除** `compiler` / `std` / `core` 下**全部** `.o`（禁止只删「相关」`.o` 冒充冷测）
  - **删除并本波重编** `xlang` / `xlang_asm` / `xlang-c` / `bootstrap_xlangc`
  - 再 `bootstrap-driver-seed` + g05 → 产品矩阵 → `XLANG_BSTRICT_SKIP_BUILD=1` 全量 bstrict
  - 旧 `.o` / 旧二进制会藏 ensure/链接/std 入链等隐性错误；细则见 skill  
    `~/.grok/skills/xlang-selfhost-product-gate/SKILL.md` §3 与 `references/true-cold-test.md`
- 日常探针可用 L2/L3；**宣称冷测绿 / 可自举必须 L4**
- **验证节奏（防 14 号假绿）**：日常微步 = **日常真测**（本波二进制 + 探针/矩阵）；**真冷全测**以 **整体功能 / 一波 Cap·R·M 收口** 为主闸门，**日终兜底**（当天动过产品面却未 L4）；禁止每微 commit 全量 L4，禁止只靠晚上、白天工程轨假绿。细则：`analysis/自举方法.md` §0.2 · skill §3.3
- 修改 `pipeline_glue.c` 或 `ast_pool.c` 后需在 Ubuntu 重建 `pipeline_x.o`
- 修改 `pipeline_glue_strict_minimal` seed 后重建 `build_asm/pipeline_glue_strict_minimal.o` + g05
