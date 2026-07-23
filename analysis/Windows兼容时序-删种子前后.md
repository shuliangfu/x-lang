# Windows 兼容时序：删种子前先跑，还是完全自举后再跑？

> **日期**：2026-07-19（同日修订：补「现在就能跑 / 最小门禁 / 禁全量 bstrict」）  
> **类型**：产品 / 平台策略决议（分析 + 推荐执行顺序）  
> **问题**：是否应在**删除种子（完全零 C 自举）之前**完成 Windows 兼容与测试，还是**等 Linux/macOS 完全自举后再**做 Windows？  
> **关联**：[`自举方法.md`](自举方法.md) · [`自举验证.md`](自举验证.md) §8.4 · [`G-02e-physical-zero-c.md`](G-02e-physical-zero-c.md) · [`G-07-selfhost-release.md`](G-07-selfhost-release.md) · [`X-ABI-设计分析.md`](X-ABI-设计分析.md) · skill `xlang-selfhost-product-gate` **G.8**（平台边界）· [`references/platform-boundaries.md`](~/.grok/skills/xlang-selfhost-product-gate/references/platform-boundaries.md)

---

## 0. 一句话结论

**删种子之前，先把 Windows 兼容性跑通（至少 B-hybrid 稳定可用）——更安全、更高效。**  
**不要**等「完全零 C / G 清场」之后再第一次认真碰 Windows；那样会事倍功半，且常伴随痛苦回滚。

| 选项 | 是否采用 |
|------|----------|
| **A. 删种子前先跑通 Windows hybrid（推荐）** | ✅ **默认策略** |
| **B. 完全自举（零 C）后再做 Windows** | ❌ 作主路径；风险高、反馈晚 |
| **C. 等 Windows 100% 完美再删种子** | ❌ 过重；阻塞 G 主线 |

**粒度（阶段 1）**：

| 要 | 不要 |
|----|------|
| **最小 hybrid 门禁**稳定绿（见 §0.1 / §5） | Windows 上跑 **`tests/run-all-bstrict.sh`（~125）** 当验收 |
| 能编能跑简单程序（return-value / hello 级） | Windows **L4 真冷** 当金标 |
| 文档写清 hybrid 探针 | 宣称「Windows 已自举 / 零 C / 三平台金标」 |

**再补一句（执行口径）**：

- **现在就可以跑 Windows**（hybrid 探针），不必等 G / 删种子 / tip 再升 L4。  
- Windows **现阶段 = 最小门禁**，不是 Ubuntu 那套全量产品门。  
- **`run-all-bstrict.sh` 是 Ubuntu（+ mac SHARED）产品轨职责**；**禁止**拿它当 Windows 阶段 1 主验收。

### 0.1 现在就能跑，还是要到某阶段？

| 含义 | 现在？ | 说明 |
|------|--------|------|
| **A. Hybrid 最小门禁**（权威入口见 §5.0） | ✅ **现在就能做** | 有 seed + MSYS2 + 切到 `windows-server` 即可 |
| **B. Hybrid 稳定（阶段 1 DoD）** | ✅ **现在就该推进** | 仍在有种子窗口；与 C5 主线可交错，不抢 G |
| **C. Windows 近 125 / 全量 bstrict** | ❌ 不当目标 | 假红淹没真 ABI 债；偏阶段 2 末～阶段 3 摸底 |
| **D. Windows 零 C / 删种子冷启动** | ❌ 现在不做 | **G 之后（阶段 3）** |

```text
现在 ──────────────────────────────► 删种子(G) ──────► 之后
 │                                      │
 │  【随时可做】最小 hybrid 门禁 / 基线   │  【必须已绿】
 │  【C6·ABI·link 前后必做】同一最小门   │   阶段 1 hybrid
 │  【禁止当 Win 主验收】全量 125 bstrict│
 │                                      │  【之后才做】
 │                                      │   Win 加深 / B-strict
```

| 波次 / 场景 | Windows？ |
|-------------|-----------|
| C5 类 typeck CTFE、纯语义、非 ABI/link | 可选；本波验收可不跑 |
| **C6 X ABI、布局、调用约定** | **必跑**最小 hybrid 门禁（改前基线 + 改后回归） |
| link ensure / g05 / CRT / 入口 | **必跑** |
| `std.sys` / win32 大改 | **必跑相关子集** |
| 宣称 **G / 删种子** | hybrid 最小门禁 **必须已稳** |
| G 完成后 Win 纯 `.x` | 阶段 3 |

**「现在开跑」≠「现在把主线改成 Windows」**：主线仍可 C5 → C6；Windows 用「基线一次 + ABI 波强制」插入。双系统互斥时，日常 Ubuntu 金标，Windows 单独切换窗口。

### 0.2 金标 vs 探针（两套门，禁止混用）

| 轨道 | 主机 | 门禁 | 放行含义 |
|------|------|------|----------|
| **产品 / 自举金标** | **Ubuntu**（SHARED 加 mac） | **`./tests/run-all-bstrict.sh`**（~125）+ 真冷 L4 | 可写 tip L4 / 产品钉盘 |
| **Windows 探针** | **windows-server / MSYS2** | **最小 hybrid 门禁**（§5.0） | 仅「Win hybrid 可用」；**≠** 自举完成 |

---

## 1. 问题陈述

### 1.1 两种极端时序

| 时序 | 做法 | 直觉卖点 | 隐藏成本 |
|------|------|----------|----------|
| **先删种子，后 Windows** | Linux/macOS 先完成 G（物理零 C / 无 seed 冷启动），再开 Windows 兼容 | 「主线不被平台拖累」 | 种子兜底消失后才发现 ABI / 链接 / `std.sys` / 冷启动差；修债要回滚 seed 叙事或在纯 `.x` 上硬啃平台边 |
| **先 Windows 完美，后删种子** | Windows 全量产品门齐绿才进 G | 「多平台都稳再自举」 | Windows 完整 B-strict 成本高；会无限推迟 G；与「Ubuntu 金标」纪律冲突 |
| **推荐：删种子前 hybrid 先稳，与 G 并行** | seed 仍在时把 Windows **B-hybrid** 跑到「能编能跑简单程序」；Linux/macOS 继续推进零 C；G 后再升 Windows B-strict | 风险可控 + 不阻塞主线 | 须明确「Windows ≠ 自举金标」，文档与 gate 分层 |

### 1.2 当前基线（写文档时的事实）

| 项 | 状态 |
|----|------|
| **自举金标** | **Ubuntu x86_64**；macOS 开发 + 双端 SHARED 验证 |
| **Windows** | 探针主机（`ssh windows-server`）；**非**自举主金标（见 [`自举验证.md`](自举验证.md) §8.4） |
| **冷启动** | 仍依赖 seed / hybrid C；**尚未**宣称完全自举 |
| **Windows 形态** | **B-hybrid**：混合 C seed + `.x` 产品路径；依赖种子较多 |
| **产品 L4 钉盘** | 以 `analysis/自举进度.md` / README 为准（Linux + macOS）；**不包含** Windows L4 宣称 |

**透明声明（对外 / 进度文强制用语）**：

> **Windows 当前为 hybrid 模式；完整零 C / 纯 `.x` 冷启动支持在 G 阶段之后再验收。**  
> 不得把「Windows hybrid 绿」写成「已自举 / 已删种子 / 三平台零 C」。

---

## 2. 为什么建议「删种子之前先跑 Windows」

### 2.1 风险控制（主因）

当前 Windows 仍是 **B-hybrid**，C seed 提供：

- 冷启动与 bootstrap 兜底  
- 部分 runtime / glue / link 行为的已知可工作实现  
- 调试时「对照 C 侧是否一致」的退路  

若 **先彻底删种子（全 `.x` 自举）**，再发现 Windows 上的问题：

| 问题类 | 典型表现 | 在「无 seed」时代的代价 |
|--------|----------|-------------------------|
| **ABI** | `extern "C"` 缺失、调用约定、结构体布局、`i64`/`f64` 传参 | 须在纯 `.x` + typeck/codegen 契约上修；无 C 对照难归因 |
| **链接** | MSVC vs MinGW 符号、入口、CRT、dead-strip 差异 | 链接图与 ensure 已按 POSIX 假设固化，回改爆炸半径大 |
| **平台代码** | `win32.sx` / `std.sys` / fs·process·env·net | seed 已删后只能从 `.x` 路径热修，回归环更长 |
| **冷启动** | Windows 上如何生成第一台编译器 | 无 seed 时几乎无路可退；可能被迫 **回滚 seed** 破坏「零 C」叙事 |

**根因纪律对齐**（AGENTS / skill）：平台债应在**仍有权威对照与兜底**时收敛，而不是在终局形态上打补丁。  
删种子 = 拿掉最大兜底；**平台差分应在拿掉之前暴露。**

### 2.2 依赖关系（技术面）

Windows 支持至少咬合四条 SHARED / 平台边界（改任何一条都可能伤 Linux/macOS）：

```text
                    ┌─────────────────────┐
                    │  用户 .x / 产品 -o   │
                    └──────────┬──────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         ▼                     ▼                     ▼
   ABI 契约              平台实现面              链接与冷启动
 (extern "C",          (win32 / std.sys,        (MSVC / MinGW,
  X ABI / C6,           syscall vs Win32 API,    g05 ensure,
  布局与调用约定)       fs/process/env/net)      seed / hybrid)
         │                     │                     │
         └─────────────────────┴─────────────────────┘
                               │
                    删种子后：仅 .x + 二进制 seed 政策
                    无 C 源兜底 → 差分修复成本陡升
```

| 依赖 | 为何要在 seed 仍在时验证 |
|------|---------------------------|
| **ABI（含 C6 X ABI 标注）** | `extern "C"` / 调用约定错误在 MSVC 上往往比 SysV 更早、更惨地爆；hybrid 下可对照 C 目标文件 |
| **平台特定代码** | `std.sys` 分流、`win32` 路径；与 POSIX 双权威风险高，宜早建单一权威 + 平台分支注释（`PLATFORM: WINDOWS`） |
| **链接器行为** | MSVC / MinGW 与 `ld`/`ld64` 对 UNDEF、弱符号、入口的假设不同；**禁止**把 macOS `-dead_strip` 绿当成 Windows 全链已过（同 G.8 精神） |
| **冷启动路径** | hybrid seed 仍是 Windows 上「第一台能干活的编译器」的现实路径；完全零 C 后再设计 Windows 冷启动 = 二次工程 |

### 2.3 实用性（产品与社区）

| 点 | 说明 |
|----|------|
| **多平台目标** | 主金标 Linux/macOS；Windows 为**明确探针 / 扩展面**，不是可有可无的附录 |
| **反馈面** | 国内大量开发者在 Windows；hybrid 能编 hello / 简单 std 即可获得 issue 与贡献 |
| **与主线关系** | Windows hybrid 工作 **不要求** 先完成 G；与 Linux 零 C **可并行**（见 §4） |
| **避免假绿** | Windows 绿 = hybrid 探针绿；**不得**冲淡 Ubuntu L4 + bstrict 的自举话术 |

### 2.4 反方论点与驳回

| 反方 | 驳回 |
|------|------|
| 「Windows 不是金标，先别管」 | 金标是**验收主轴**，不是「永远不做」；探针债拖到无 seed 时代成本最高 |
| 「先零 C 逻辑更干净，平台后贴」 | 平台差分会**反噬** ABI/link/sys 设计；后贴常变成第二套权威 |
| 「Windows 一碰就深坑，拖死 G」 | 所以阶段 1 **只做 hybrid 核心 gate**，不做 100% B-strict（§3） |
| 「双系统不能同时在线，测不动」 | 用固定 **Windows gate 子集** + 大改（尤其 ABI）前排期切换；见 [`自举验证.md`](自举验证.md) |

---

## 3. 推荐执行顺序（三阶段）

### 阶段 1 — **当前推荐 · 优先**（种子仍在 · Windows B-hybrid · **最小门禁**）

**目标**：在现有 seed / hybrid 基础上，Windows 达到 **稳定可用**。  
**口径**：**阶段 1 = 最小 hybrid 门禁跑通并保持不回归**——不是 125，不是零 C。

| 验收（最低） | 说明 |
|--------------|------|
| **权威最小门** | `tests/run-bootstrap-bstrict-windows-gate.sh`（默认 **B-hybrid**）绿（§5.0） |
| 核心冒烟 | return-value 42、win32 write/read；能扩展到 `hello` / 简单 `-o` |
| ABI / 链接主伤 | 阻塞「简单程序」的符号 / 入口 / 调用约定；C6 落 SHARED 权威路径 |
| 文档透明 | README / 进度文：**Windows = hybrid 探针，非零 C 终局** |
| **不做** | Windows 上删种子；**以 `run-all-bstrict` 全量 125 作 Win 验收**；宣称「Windows 已自举」 |

**完成定义（DoD）示例**：

- [ ] `windows-server`（MSYS2）上 **`./tests/run-bootstrap-bstrict-windows-gate.sh`** 绿（记 tip SHA）  
- [ ] （增强，非阻塞首跑）固定扩展名单 **≤20–30** 关键脚本（§5.2）全绿  
- [ ] 已知 blocker 记入 `问题分析文档.md` / 进度文，**禁止** soft-skip 糊绿  
- [ ] **未**把 Windows 全量 `run-all-bstrict` 红项当成「必须先修完才能进 G」

### 阶段 2 — Linux/macOS 推进零 C（G 清场）· Windows 改动跟合并

**目标**：继续推进 **Ubuntu 金标** 上的物理零 C / seed 退役（G）；Windows hybrid 修复合入同一主线，在 Linux/macOS 钉盘后做合并验证。

| 原则 | 说明 |
|------|------|
| **主线** | G 仍以 Ubuntu L4 + 产品 bstrict 为放行 |
| **并行** | Windows hybrid 测通 **不阻塞** G 的 R/M 波次；ABI SHARED 改动须双端（mac + Ubuntu）+ Windows 探针抽样 |
| **合并点** | Linux/macOS 钉盘稳定后，在 Windows 上 **重跑阶段 1 gate**，确认无回归 |

### 阶段 3 — 零 C 自举完成后 · Windows 完整 B-strict

**目标**：在 **G 已达成**（冷启动政策允许无手写 C seed）之后，再做：

- Windows 纯 `.x` / B-strict 路径  
- 更完整的产品矩阵与性能 / 工具链优化  
- （可选）Windows 冷启动与发布叙事  

**此时**再谈「Windows 零 C」才有意义；阶段 1–2 已经把 ABI/sys/链接大雷排掉。

```text
时间 ──────────────────────────────────────────────────────────►

  [阶段 1] Windows B-hybrid 核心 gate
       │         ┌──────────────────────────────┐
       │         │ [阶段 2] Linux/macOS 零 C (G) │
       │         │  + Windows 改动合并验证        │
       ▼         └──────────────┬───────────────┘
  seed 仍在                      │
  兜底可用                       ▼
                        [阶段 3] Windows B-strict / 零 C 验收
                        （种子政策已终局）
```

---

## 4. 并行模型（效率 vs 风险）

| 轨道 | 内容 | 互相阻塞？ |
|------|------|------------|
| **产品 / 自举主线** | Cap · R · M · Ubuntu L4 · bstrict 125 | 主轴 |
| **Windows hybrid** | 核心 gate · ABI/link · `std.sys` win | **默认不阻塞**主线宣称 |
| **SHARED ABI** | C6、`extern "C"`、布局 | **阻塞**：改则 mac + Ubuntu 必验；Windows gate 在大改前后必跑 |

**可并行**：一边推进 Linux/macOS 零 C，一边把 Windows hybrid 测通。  
**不可并行假绿**：用 Windows 未测的 SHARED ABI 改动直接宣称 tip L4 / 可自举。

**资源约束**（物理机双系统）：

- Ubuntu 与 Windows **不能同时在线**（见 [`自举验证.md`](自举验证.md)）  
- 排期：日常 Ubuntu 金标；**ABI / link / sys 波**预留 Windows 切换窗口  
- commit **仅 macOS**；Windows 只 pull + 测 + 回传日志  

---

## 5. Windows gate（阶段 1 = **最小门禁**）

### 5.0 权威命令（现在就用这个，不要先想 125）

在 **MSYS2 / windows-server**、仓库根（先 `git pull` 对齐 tip；有 seed / 能起 hybrid 链）：

```bash
# 默认 B-hybrid — 阶段 1 日常与 ABI 波前后的标准最小门禁
./tests/run-bootstrap-bstrict-windows-gate.sh

# 可选：显式 Windows B-strict 路径（非阶段 1 日常默认）
# XLANG_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
```

脚本行为摘要（以仓库内注释为准）：

| 模式 | 条件 | 测什么（量级） |
|------|------|----------------|
| **B-hybrid（默认）** | `XLANG_WIN_BSTRICT` 未设或 `0` | `bootstrap-driver-hybrid` → `xlang_asm` + return-value **42** + win32 WriteFile/read 等 |
| **B-strict** | `XLANG_WIN_BSTRICT=1` | `bootstrap-driver-bstrict` + 同上；**仍不是** 125 全量 |
| 非 MSYS2 宿主 | Linux/mac 上执行 | **skip exit 0**（金标由 bstrict-ci / `run-all-bstrict` 承担） |

连接与路径约定：[`自举验证.md`](自举验证.md) §8.4（`ssh windows-server`，`C:\Users\shuliangfu\worker\shu\shux`）。  
**不在 Windows 上自举 seed 当金标路径**；commit 仍只在 macOS。

### 5.0.1 为什么阶段 1 **禁止**拿 `run-all-bstrict.sh` 当 Windows 主验收

| 点 | 说明 |
|----|------|
| **设计目标** | `run-all-bstrict.sh` = 产品轨 **~125** 白名单，默认 `bootstrap-driver-bstrict`，按 **POSIX / Ubuntu 金标** 假设 ensure 大量 `std/*.o`（net/fs/process/thread/…） |
| **Windows 上直接全量** | 大面积「平台未实现 / 链接假设」**假红**，淹没真 ABI·链接债；耗时长、双系统切换 ROI 差 |
| **正确分工** | Ubuntu/mac → `run-all-bstrict`；Windows → **本节省门禁** |
| **阶段 3 例外** | G 完成后可在 Win 上**摸底**跑更大集合；**全绿前不得**写成放行条件或阻塞 G |

```bash
# ❌ 阶段 1 不要把下面当作「Windows 验收通过」的定义
# ./tests/run-all-bstrict.sh

# ✅ Ubuntu / mac 产品门（金标主机上）
# XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh
```

### 5.1 规模与定位

| 项 | 建议 |
|----|------|
| **阶段 1 主验收** | **最小门禁** = §5.0 脚本绿（**不是** 125） |
| **增强集（可选）** | 再扩到 **≤20–30** 个关键脚本（§5.2）；名单未冻结前 **不**阻塞「已跑通最小门」的叙事 |
| **触发** | **现在**可建 tip 基线；**C6 / ABI / link / `std.sys`** 前后**必跑**；阶段 2 合并点；日常非 ABI 波可选 |
| **通过标准** | 本波 tip + hybrid 链；日志落本机 tmp；进度文记 **SHA + 绿/红**（与 L4 pin **分行**） |
| **失败处理** | 根因在产生点（ABI / sys / ensure）；禁止仅 Windows 下游 `if (win)` 糊绿（G.7） |

**「最小门禁」不等于「永远只跑一个 hello」**：首跑与日常 = §5.0；阶段 1 收口可加 20–30；**始终远小于** 产品 125。

### 5.2 建议覆盖面（增强集 · 可随实现裁剪）

| 桶 | 示例能力 | 优先级 |
|----|----------|--------|
| **已有最小门（P0 已覆盖）** | hybrid 起 `xlang_asm`、return-value 42、win32 write/read | **必达** |
| **驱动 / 输出** | `hello`、`void main`、简单 `xlang run` / `-o` | P0 扩展 |
| **语言最小** | 控制流、struct、基础调用 | P0 扩展 |
| **std 最小** | 打印、基础容器、简单 fs/env（按已实现面） | P0–P1 |
| **链接 / 符号** | 无致命 UNDEF；入口正确 | P0 |
| **ABI 敏感** | i64、简单 extern C（贴 C6） | 动 ABI 时 P0 |
| **明确不做（阶段 1）** | 全量 `run-all-bstrict`、freestanding 全矩阵、完整 net/tls、Stage2 自举、Windows L4 钉盘 | 阶段 3 或单独立项 |

名单落地后可写：

- `tests/` manifest（如 `tests/windows-hybrid-gate.list`）或扩展现有 runner  
- [`自举验证.md`](自举验证.md) §8.4 与本文 §5.0 保持同一权威命令  
- [`自举进度.md`](自举进度.md) 仪表盘单列 **Windows hybrid**（与 L4 pin 分行）

### 5.3 与现有纪律的对齐

| 纪律 | Windows 含义 |
|------|----------------|
| **Ubuntu 金标** | 自举 / 删种子放行仍只看 Ubuntu（+ SHARED 时 macOS）+ **`run-all-bstrict` 125** |
| **Windows 探针** | 只认 **最小 hybrid 门禁**；绿 ≠ 自举完成 |
| **真冷 L4** | **不**要求 Windows 做与 Ubuntu 同级 L4 才完成阶段 1 |
| **双权威禁止** | seed 与 `.x` / glue 同语义同 commit；禁止 Win 专用第二套 ABI 名 |
| **PLATFORM 标注** | 凡 Win 分支注释 `PLATFORM: WINDOWS`；SHARED 改动写清双端 + 探针义务 |
| **一条债一层一 commit** | Win 链接债与 Linux UNDEF 债分开 commit，禁止「顺手改测试期望」糊绿 |

---

## 6. 决策矩阵（快速查阅）

| 场景 | 是否先动 Windows | 说明 |
|------|------------------|------|
| 日常 pure 工程轨 / 文档 | 否 | 不阻塞 |
| 产品 Cap 仅 POSIX 语义、不动 ABI | 否（可选抽样） | 主线 Ubuntu；**不**要求 Win 跑 125 |
| **任意空窗建基线** | **建议跑一次 §5.0** | 现在即可；最小门禁 |
| **C6 / extern C / 布局 / 调用约定** | **是 · §5.0 必跑** | 阶段 1 核心价值 |
| **link ensure / g05 / 入口 / CRT** | **是 · §5.0** | 链接器差分 |
| **`std.sys` / fs / process / env** | **是（相关子集）** | 平台实现面 |
| **Win 上 `run-all-bstrict` 当验收** | **否（阶段 1）** | 见 §5.0.1；金标在 Ubuntu |
| **宣称删种子 / G 完成** | hybrid 最小门 **应已稳**；完整 Win 零 C 后置 | 阶段 2→3 |
| **对外「支持 Windows」营销** | 仅 hybrid DoD 达成后 | 用语见 §1.2 |

---

## 7. 风险登记（若违反本决议）

| ID | 风险 | 后果 | 缓解 |
|----|------|------|------|
| W-R1 | 先删种子再首测 Windows | 回滚 seed、双权威、进度叙事崩 | **禁止**；坚持阶段 1 先做 |
| W-R2 | 追求 Windows 100% / 125 全绿再进 G | G 无限延期 | 阶段 1 只 **最小 hybrid 门禁**；禁 Win 上 `run-all-bstrict` 当放行 |
| W-R3 | SHARED ABI 改完只测 mac | Windows / Linux 潜伏 UNDEF | G.8 + 大改触发 §5.0 gate |
| W-R4 | 把 Windows hybrid 绿写成自举完成 | 14 号式假绿 | 进度文分轨；透明声明；§0.2 |
| W-R5 | Win 专用下游补丁 | 双实现、长期漂移 | 权威路径一次修全（G.7） |
| W-R6 | 阶段 1 首测就上 125 全量 | 假红淹没、无法归因 | **只用** `run-bootstrap-bstrict-windows-gate.sh` |

---

## 8. 操作清单（给执行者 / AI）

1. **现在（任意空窗）**：切 `windows-server` / MSYS2，`git pull` tip → 跑 **`./tests/run-bootstrap-bstrict-windows-gate.sh`** → 记 SHA + 绿/红（建立基线）。  
2. **不要**：在 Windows 上把 **`./tests/run-all-bstrict.sh`** 当作阶段 1 通过条件。  
3. **持续**：Linux/macOS 主线（C5 / Cap / 零 C）按 Cap/R/M；**不**等 Windows B-strict / 125。  
4. **ABI 波（C6 等）**：mac + Ubuntu 产品验证（含需要时的 `run-all-bstrict`）→ 切换 Windows 跑 **§5.0** → 再宣称 SHARED 安全。  
5. **增强（可选）**：冻结 ≤20–30 扩展名单；写入 manifest + [`自举验证.md`](自举验证.md) §8.4。  
6. **文档**：`自举进度.md` 单列 Windows hybrid；用语「hybrid 探针；零 C 在 G 后」。  
7. **G 完成点**：重跑 §5.0；再单独立项阶段 3 加深 / B-strict。  
8. **禁止**：Ubuntu/Windows 上 `git commit`；scp 日志回 mac 再提交；旧 stage1 冒充产品二进制。

---

## 9. 与相邻文档的边界

| 文档 | 分工 |
|------|------|
| 本文 | **时序决议**：何时做 Windows、做到哪一档、与删种子的关系 |
| [`自举方法.md`](自举方法.md) / [`自举步骤.md`](自举步骤.md) | 自举方法论与操作模板（金标 Ubuntu） |
| [`自举验证.md`](自举验证.md) §8.4 | Windows 主机连接与验证命令落点 |
| [`G-02e-physical-zero-c.md`](G-02e-physical-zero-c.md) / G-07 | 删 C / 发布门禁；**不**被 Windows 阶段 3 绑死才能开始 G |
| [`X-ABI-设计分析.md`](X-ABI-设计分析.md) | ABI 权威设计；C6 与 Windows 探针的输入 |
| [`零libc产品策略.md`](零libc产品策略.md) | Linux freestanding / 零 libc；Windows 另轨，勿混验收 |

---

## 10. 结论复述

| 问题 | 答案 |
|------|------|
| 删种子前先跑 Windows？ | **是（hybrid 稳定即可）** |
| 等完全自举后再跑 Windows？ | **否（作主策略）**；完整 B-strict 可放在 G **之后**（阶段 3） |
| 要 Windows 100% 才删种子？ | **否**；避免阻塞 G |
| **现在就能跑吗？** | **能**——最小 hybrid 门禁；不必等 G / 升钉 |
| **Windows 是不是只要最小门禁？** | **阶段 1：是**（§5.0）；可扩 ≤20–30，**不是** 125 |
| **要不要 Win 上跑 `run-all-bstrict`？** | **阶段 1：不要**（当主验收）；那是 Ubuntu/mac 金标 |
| 权威最小命令 | `./tests/run-bootstrap-bstrict-windows-gate.sh`（MSYS2，默认 hybrid） |
| 能否与零 C 并行？ | **能**；SHARED ABI 时必须带 Windows **最小** gate |
| 一句话 | **删种子前把 Windows hybrid 最小门禁跑通；用探针门，不用 125 金标门；完全自举后再大修 Windows 会事倍功半。** |

---

*决议状态：推荐采用（2026-07-19）；同日修订 §0.1–0.2 / §5.0（最小门禁与禁全量 bstrict）。扩展名单落地时只增 §5.2 / 验证文命令，无需推翻 §0。*
