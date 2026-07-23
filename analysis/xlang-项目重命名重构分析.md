# Xlang → Xlang 项目重命名重构分析

> **状态**：分析定稿（**尚未开工改产品码**）  
> **日期**：2026-07-23  
> **背景 tip**：产品 `b4b116f2`（wave237）  
> **重构前 L4 钉盘**：**`a77fc5d90`**（双端 tip L4 真冷 + bstrict **129** 全绿）  
> **git 锚点**：annotated tag **`anchor-pre-xlang-rename`**  
> **官方域名（用户确认）**：**`xlang.dev`**  
> **自举**：本重构**整波闭合且双端 L4 验收绿之前**，**暂停** Cap residual / 自举微波；重构完成后再接 wave238。

---

## 0. 一句话目标

把当前仓库从 **Xlang / xlang / XLANG_*** 品牌与工具链表面，**系统性地收敛为 Xlang / xlang / XLANG_***，文档、源码、二进制命令、配置与对外域名统一到 **xlang / xlang.dev**；并在**不破坏自举金标与 ABI 真链**的前提下，分阶段落地。

**不是**一次 `sed s/xlang/xlang/g`。  
**是**分层地图 + 兼容窗口 + 双端冷验 + 历史归档策略。

---

## 1. 决策基线（已拍板 / 待拍板）

### 1.1 已拍板

| 项 | 值 | 备注 |
|----|-----|------|
| **语言 / 项目品牌** | 中文 **X 语言** · 英文 **X language**（CLI / 包名 / 仓库短名仍小写 `xlang`） | 取代 X language / X 语言 |
| **主域名** | **`xlang.dev`** | 取代规划中的 `xlang.dev` 作为**现行权威** |
| **源文件扩展名** | **保持 `.x`** | 已与品牌「X」一致；改扩展名爆炸半径极大，**本波不做** |
| **诊断码** | **保持 `XP***` / `XT***` / `BLD***` 等** | 与「X 语言」一致；不必改为 `XL***` |
| **自举节奏** | **重构优先；完成后才继续自举** | 用户 2026-07-23 明确 |

### 1.2 建议默认（若无异议按此执行）

| 项 | 建议 | 理由 |
|----|------|------|
| **主 CLI** | `xlang` → **`xlang`** | 产品命令面唯一入口名 |
| **asm 产品二进制** | `xlang_asm` → **`xlang_asm`** | 与现 g05 / bstrict 约定一一对应 |
| **C 前端 / 冷启动** | `xlang-c` → **`xlang-c`**；`bootstrap_xlangc` → **`bootstrap_xlangc`** | 冷启动脚本硬依赖文件名 |
| **其它变体** | `xlang-x` → `xlang-x`；`xlang-seed-phase1` → `xlang-seed-phase1` 等 | 同族一致 |
| **配置文件** | `xlang.toml` → **`xlang.toml`** | 包/工具约定；可过渡期双读 |
| **环境变量前缀** | `XLANG_*` / `XLANG=` → **`XLANG_*` / `XLANG=`** | 测试与 Makefile 大量依赖；过渡期可双认 |
| **构建入口脚本** | `xlang-build.sh` → **`xlang-build.sh`** | 根目录入口 |
| **GitHub 仓库** | `github.com/shuliangfu/shux` → **`…/xlang`**（或保留旧名 redirect） | 需单独操作；可后置 |
| **本机目录** | `…/shu/shux` → **`…/shu/shux`**（可选） | **不进 git**；三机路径要同步改文档与 skill |
| **ABI 符号前缀** | **`xlang_*` → `xlang_*`（产品链全量）** | 见 §3.3；**最贵、必须整波 + 真冷** |
| **兼容别名窗口** | **1 个过渡阶段**（双名可执行 / 双 env 可读） | 防脚本一夜全红；窗口结束后删旧名 |

### 1.3 明确不改或慎改

| 项 | 策略 | 原因 |
|----|------|------|
| **git 历史 / 旧 commit 文案** | **不改写历史** | 禁 force-rewrite；旧 SHA 钉盘文案保留「当时叫 xlang」 |
| **`analysis/archive/**` 历史工单** | **默认不批量改**；文首可加「历史名 Xlang」一行 | 考古可读；避免 500+ 文件噪声 diff |
| **自举进度日归档** | **不回溯改** | 时间线真值 |
| **SIMD 名 `xlangffle`** | **建议改为 `xlangffle` 或中性 `xshuffle`**（产品 API 面） | 现名是 Xlang+shuffle 双关；属 std API，可放 **P2** |
| **测试内核玩具 `xlangos*.x`** | 可改 `xlangos` 或保持示例名 | 非产品 CLI；P2 |
| **诊断 / IR 文档里的「X-ABI」** | **保留 X-** 前缀 | 已是 X 语言契约名，与 xlang 一致 |
| **第三方无关匹配** | 脚本必须**词边界** | 防误伤 `schedule`、路径中的偶然子串 |

### 1.4 域名体系（权威：`xlang.dev`）

> 旧文 `analysis/xlang-生态网站规划.md` 以 **`xlang.dev`** 为纲——**降级为历史规划**；本分析起以 **`xlang.dev`** 为唯一主域。

| 用途 | 主机名 | 优先级 |
|------|--------|--------|
| 官网 / 下载 | `www.xlang.dev` 或 apex `xlang.dev` | P0 |
| 文档 | `docs.xlang.dev` | P0 |
| 博客 / 发布 | `blog.xlang.dev` | P1 |
| Playground | `play.xlang.dev` | P1 |
| 包注册表 | `registry.xlang.dev` | P1（包管理成熟后再重） |
| 仓库说明 / LICENSE | `https://xlang.dev` + GitHub | 与 NOTICE 同步 |

**与旧域关系（若 `xlang.dev` 仍持有）**：

- 短期：DNS 301 → `xlang.dev`（可选，防外链失效）  
- 中期：只维护 `xlang.dev`  
- 文档禁止再写「主域 = xlang.dev」为现行事实  

---

## 2. 现状爆炸半径（量化快照 · 2026-07-23 tip）

> 下列为**粗计量**（含测试日志噪声时会偏大）；决策用数量级，不以个位数验收。

| 维度 | 量级 | 说明 |
|------|------|------|
| 含 `xlang` 字样的**文件数**（排除 build/archive 后） | ~**1.7k+** | `tests` 最多，其次 `compiler`、`editors` |
| 文件名含 `*xlang*` | **200+**（含本机二进制备份、`.dbg`、tests/.out） | **入库应改的 ≪ 本机垃圾**；先清 `.gitignore` 产物 |
| 产品二进制族 | `xlang` / `xlang_asm` / `xlang-c` / `bootstrap_xlangc` / `xlang-x` … | Makefile `TARGET=xlang`；g05 脚本硬编码 |
| 环境变量 `XLANG_*` 出现面 | **极大**（测试矩阵 + L2 thin 宏） | 例：`XLANG_BSTRICT_*`、`XLANG_L2_*_FROM_X`、`XLANG_PARSER_ASM_DEBUG` |
| 宿主变量 `XLANG=` | **数百级**脚本入口 | skill / bstrict / 进度文铁律写法 |
| 链接/运行时符号前缀 `xlang_*` | **数千级引用**（`xlang_sys_` / `xlang_link_` / `xlang_asm_*` / `xlang_panic_*` / `xlang_io_*` …） | **ABI 真链**；改错 = 全量 UNDEF |
| 编辑器 / tree-sitter | `editors/vscode` · `editors/vim` · `editors/tree-sitter-xlang` | 扩展 ID、配置键 `xlang.*` |
| 配置 | `xlang.toml`、`package.name = "xlang"` | 设计超集；编译器尚未全读 |
| 远端 | `origin = github.com/shuliangfu/shux.git` | 仓库改名另步 |
| 外部 skill | `~/.grok/skills/xlang-selfhost-product-gate/` | **不在仓库内**，必须单独迁 |

### 2.1 产品命令面（必须改对的「入口集合」）

```text
用户/Agent 日常触达
  xlang              ← 原 xlang（g05 主链产物之一）
  xlang_asm          ← 原 xlang_asm（产品 XLANG/XLANG 默认）
  xlang-c            ← 原 xlang-c
  bootstrap_xlangc   ← 原 bootstrap_xlangc
  xlang-build.sh     ← 原 xlang-build.sh
  xlang.toml         ← 原 xlang.toml
  XLANG=...          ← 原 XLANG=
  XLANG_*            ← 原 XLANG_*
```

### 2.2 内部实现面（改则必双端 L4）

```text
runtime / link / freestanding
  xlang_sys_{read,write,open,...}
  xlang_link_obj_needs_undef_sym*
  xlang_panic_*
  xlang_asm_ld_*
  xlang_freestanding_*
  include/xlang_*.h
  seeds 内嵌同名字符串门控（UNDEF 表）
```

任一符号只改一半 → Ubuntu 金标立刻红。

---

## 3. 分层模型（禁止混层大爆炸）

按**风险与可回滚性**分四层。**下层未绿，禁止宣称整库已 xlang 化。**

```text
L-Brand   文档品牌、README、域名、NOTICE、进度文叙事
L-CLI     二进制名、脚本入口、Makefile TARGET、测试宿主 XLANG=
L-Env     XLANG_* → XLANG_*（含 L2 thin 宏名）
L-ABI     xlang_* 链接符号 / 头文件 / seed 字符串门控
```

| 层 | 是否动 seed pin | 验收 | 建议波次 |
|----|-----------------|------|----------|
| **L-Brand** | 否 | 文档自检；无编译 | R0 |
| **L-CLI** | 否（仅产物名） | 双端 L2→收口 L4：g05 出 `xlang_asm` + 矩阵 + bstrict | R1 |
| **L-Env** | 多数否；个别 `-D` 宏要进编译 | 同上；脚本全量 | R1 后半或 R2 |
| **L-ABI** | **是**（.x + seed + glue **同 commit 族**） | **强制双端 L4 + 全量 bstrict** | R3（独立大波） |

### 3.1 L-Brand：文档与域名

**改**：

- `README.md` / `README_zh-CN.md` / `CONTRIBUTING.md` / `HOW_TO_TEST.md` / `AGENTS.md`  
- `docs/**` 活文档  
- `analysis/` **活**文档（进度、方法、步骤、验证、本分析）  
- `NOTICE` / `LICENSE*` 项目 URL → `https://xlang.dev` + 新 GitHub（若已改）  
- VSCode/Vim **用户可见**字符串  
- 旧 `xlang-生态网站规划.md`：文首加 **superseded by xlang.dev**，或迁 archive 并留跳转

**不改**：

- `analysis/archive/**` 正文批量  
- 日归档进度里的历史「xlang_asm」字样（可保留；或仅在索引说明「旧称」）

### 3.2 L-CLI：二进制与构建入口

**权威映射表（强制一致）**

| 旧 | 新 |
|----|-----|
| `compiler/xlang` | `compiler/xlang` |
| `compiler/xlang_asm` | `compiler/xlang_asm` |
| `compiler/xlang-c` | `compiler/xlang-c` |
| `compiler/bootstrap_xlangc` | `compiler/bootstrap_xlangc` |
| `compiler/xlang-x` | `compiler/xlang-x` |
| `xlang-build.sh` | `xlang-build.sh` |
| `scripts/xlang_compile_std_module.sh` 等 | `xlang_compile_std_module.sh`（或保留脚本名、仅内改调用——**推荐文件名也改**） |
| `compiler/scripts/g05_build_xlang_asm.sh` | `g05_build_xlang_asm.sh` |
| `tests/lib/p0-gate-xlang.sh` 等 | `p0-gate-xlang.sh` |
| `TARGET = xlang` | `TARGET = xlang` |

**Makefile / g05 / bstrict** 是 R1 核心：任何遗漏 `./xlang_asm` 硬编码 = 假绿或直接失败。

**过渡策略（推荐）**：

1. **R1a**：构建**主产物**改为 `xlang*`；同时 `ln -sf xlang_asm xlang_asm`（或安装双名）仅限过渡。  
2. **R1b**：全库脚本改认 `xlang*`；删除对 `xlang*` 二进制的依赖。  
3. **R1c**：去掉兼容 symlink；`run-no-legacy-xlang-gate` 类测试改为 `run-no-legacy-oldname-gate`。

### 3.3 L-Env：环境变量与 `-D` 宏

| 旧模式 | 新模式 | 备注 |
|--------|--------|------|
| `XLANG=./compiler/xlang_asm` | `XLANG=./compiler/xlang_asm` | skill / 进度文模板全改 |
| `XLANG_BSTRICT_SKIP_BUILD` | `XLANG_BSTRICT_SKIP_BUILD` | bstrict 入口 |
| `XLANG_L2_*_FROM_X` | `XLANG_L2_*_FROM_X` | hybrid 冷种子开关；**与 seed `#ifndef` 同改** |
| `XLANG_PARSER_ASM_DEBUG` 等产品 getenv | `XLANG_PARSER_ASM_DEBUG` 等 | **行为变更**：旧环境名失效；文档写迁移表 |
| `XLANG_WEAK` / 头文件宏 | `XLANG_WEAK` | include 与种子 |

**过渡**：解析层可 **先读 `XLANG_*`，未设再回落 `XLANG_*`**（仅 R1–R2）；R3 后删除回落，避免永久双权威。

### 3.4 L-ABI：链接符号与公开 C 名

这是**唯一必须与自举/seed 钉盘同生共死**的层。

**原则（G.7 / 双权威禁令）**：

- `.x` 导出、`seeds/*.c`、`pipeline_glue*`、`runtime_*`、`include/xlang_*.h` **同波同语义**  
- freestanding UNDEF 表里的**字符串字面量**（如 `"xlang_sys_write"`）必须与定义符号一致  
- **禁止**只改 `.x` 不改 seed，或只改 Linux seed 不改调用方  

**命名规则建议**：

```text
xlang_<rest>  →  xlang_<rest>
XLANG_<REST>  →  XLANG_<REST>
文件 xlang_foo.h → xlang_foo.h
```

**例外 / 讨论点**：

| 符号族 | 建议 |
|--------|------|
| `xlang_sys_*` | 必改 `xlang_sys_*`（std / freestanding 核心） |
| `xlang_asm_*`（大量 ld/codegen 内部） | 随 L-ABI 整波改；或内部可逐步 `xlang_asm_*` |
| `link_abi_*`（已无 xlang 前缀） | **保持** |
| `std_*` / `core_*` | **不改**（非品牌前缀） |
| `process_xlang_argc_get` 类 | 改 `process_xlang_argc_get` 或中性 `process_host_argc_get`（若想减弱品牌耦合） |

**验收**：双端 **L4 全擦** + 产品矩阵 + **全量 bstrict**；`nm` 抽检无残留必需的 `U xlang_` 产品路径（过渡期除外）。

---

## 4. 仓库外与基础设施

| 位置 | 动作 |
|------|------|
| **GitHub repo** | Settings → Rename → `xlang`；确认 Pages/Actions/secrets；旧 URL GitHub 会 redirect |
| **git remote** | 三机 `git remote set-url origin …/xlang.git` |
| **本机路径** | mac `/Users/…/shu/shux`；Ubuntu `/home/…/shu/shux`；Windows 同构；**skill 路径表同步** |
| **SSH 文档** | skill「环境与跨机同步」全文替换目录名与二进制名 |
| **`~/.grok/skills/xlang-selfhost-product-gate/`** | 目录可改名 `xlang-selfhost-product-gate`；内容全量替换；**Agents.md 交叉引用** |
| **Cursor / VSCode 用户设置** | `xlang.serverPath` → `xlang.serverPath`（扩展发布 major） |
| **CI** | `.github/workflows/*`、未跟踪的 `pr-check.yml` 一并改 |
| **Docker / devcontainer** | 镜像名与路径 |
| **域名 DNS** | `xlang.dev` 及子域；旧 `xlang.dev` 可选 301 |

---

## 5. 推荐实施路线（可执行波次）

> **总原则**：一条债一层一个 commit 族；**先入口后 ABI**；每层有绿才进下层。  
> **自举 Cap residual 在 R0 起冻结**，至 **R3 双端 L4 绿** 再恢复。

### R0 — 冻结与地图（0.5～1 天）

1. 进度文写明：**自举暂停 · xlang 重命名工程开始**  
2. 本分析入库；`analysis/README.md` 挂链  
3. 冻结规则：  
   - 禁止新的 `xlang_*` API / 新 `XLANG_*` env（特殊：bugfix 可临时用旧名，但须登记迁出）  
   - 禁止大范围无关自举微波与重命名搅同一 commit  
4. 清点**入库** `*xlang*` 文件清单（排除 `tests/.out`、本机 `compiler/xlang_asm.*` 备份）  
5. 确认 `xlang.dev` DNS / 证书归属（可与代码并行）

**出口**：地图 + 冻结；无产品二进制改名要求。

### R1 — CLI + 构建 + 测试宿主（主痛点）

**目标**：人与脚本默认使用 `xlang` / `xlang_asm` / `XLANG=`。

1. `compiler/Makefile`：`TARGET`、`XLANG_C`→`XLANG_C` 等  
2. `g05_*` / `bootstrap_*` / `xlang-build.sh` → xlang 族  
3. `tests/run-all-bstrict.sh` 及 `tests/lib/*`  
4. 根 `Makefile` / `build.sh` / `build.x` 中的命令字符串  
5. 过渡 symlink（可选）  
6. **mac L2 + Ubuntu L2**：g05 → 矩阵 → 抽样 bstrict  
7. 收口：**双端 L4 + 全量 bstrict** → 新钉盘（命名切换钉）

**出口**：`XLANG=./compiler/xlang_asm` 为唯一推荐写法；旧二进制名仅兼容或已删。

### R2 — Env / 配置 / 编辑器 / 文档品牌

1. `XLANG_*` → `XLANG_*`（脚本 + seed `#ifndef` + getenv 名）  
2. `xlang.toml` → `xlang.toml`（双读一个版本）  
3. VSCode：`publisher`/`name`/`xlang.*` 配置键 → `xlang.*`（**semver major**）  
4. Vim ftdetect/syntax 目录名  
5. tree-sitter 包名（可后置若绑定复杂）  
6. README / docs / AGENTS / skill 全量品牌与域名 **xlang.dev**  
7. 诊断文案里的 “Xlang” → “Xlang”

**出口**：新 clone 按 README 只用 xlang 名能走通；双读可开始标 deprecated。

### R3 — ABI 符号全量（最重）

1. 全库符号重命名表（生成脚本 + review，禁止盲 sed）  
2. `include/xlang_*.h` → `xlang_*.h`  
3. std/core/compiler `.x` + **全部相关 seeds** 同批  
4. freestanding / link UNDEF 字符串表  
5. **禁止**与 Cap residual 业务逻辑混提  
6. **强制**：双端 **L4 真冷** + 全量 bstrict + 抽检 `nm`  
7. 升产品钉盘；删除 env/符号兼容层（若有）

**出口**：产品链 `nm` 主路径无 `xlang_` 必达符号；文档 ABI 表更新。

### R4 — 仓库 / 路径 / 生态收尾

1. GitHub rename + remote  
2. 三机目录 `xlang` → `xlang`（文档与 skill）  
3. skill 目录改名  
4. 网站 `xlang.dev` 上线占位  
5. 旧域名 301（可选）  
6. `analysis/xlang-*.md` 活文档改名或文首转向  
7. **恢复自举**：接 wave238 Cap residual（进度文写「xlang 树继续」）

### 明确不做的「伪完整」

| 伪完整 | 问题 |
|--------|------|
| 只改 README 仍交付 `xlang_asm` | 命令面未重构 |
| 只改二进制不改 `XLANG=` | 测试与 skill 双权威 |
| 只改 `.x` 符号不改 seed | 自举/冷启动必炸 |
| 巨型单 commit 含 Cap + rename | 无法归因；违反一条债一层 |
| 改 git 历史洗掉 xlang | 钉盘与审计失效 |

---

## 6. 机械执行工具策略

### 6.1 推荐流程

```text
1) 生成清单（rg + find），人工分桶：Brand / CLI / Env / ABI / Skip
2) 每桶用「有词边界」的替换；ABI 用符号表驱动，不用全文盲替换
3) 二进制与脚本：先改「产生名字」的 Makefile/g05，再改「消费名字」的 tests
4) 每层编译验证；R3 必须 L4
5) 提交信息前缀：rename(xlang): …  便于日后 bisect
```

### 6.2 危险替换（禁止直接全局）

| 模式 | 风险 |
|------|------|
| `s/xlang/xlang/g` 无边界 | 误伤注释英语词、路径、基线 tsv、SIMD 双关、历史 SHA 说明 |
| 改 `tests/baseline/*.tsv` 未重跑 | 假红/假绿 |
| 改 seed 不全量 | Ubuntu UNDEF |
| 只在 mac 验 L-CLI | g05 路径差、dead_strip 藏问题 |

### 6.3 建议保留的「允许出现 xlang 的地方」

- git log / 旧 tag / 旧钉盘叙述中的历史名  
- `analysis/archive/**`  
- 迁移说明：「formerly Xlang」  
- 第三方镜像未更新前的 redirect 文档  

---

## 7. 验收矩阵（重命名专用）

### 7.1 R1/R2 最低

```bash
# 名称以落地后为准
export XLANG=./compiler/xlang_asm
$XLANG -o /tmp/rv tests/return-value/main.x && /tmp/rv   # 42
$XLANG -o /tmp/opt tests/option/main.x
$XLANG -o /tmp/hello examples/hello.x && /tmp/hello
# 旧名应失败或仅兼容层提示
```

### 7.2 R3 / 整波收口

| 检查 | 标准 |
|------|------|
| 构建级别 | **L4** 全擦 `compiler|std|core` `.o` + 重链全部产品二进制 |
| 平台 | **mac + Ubuntu**（SHARED） |
| bstrict | `XLANG_BSTRICT_SKIP_BUILD=1` 全量套件绿（现行钉盘套件数对齐进度文） |
| 符号 | 产品路径无意外 `U xlang_*`；关键 `xlang_sys_*` 有定义 |
| 文档 | README / skill / AGENTS 无「现行命令仍是 xlang」 |
| 域名 | 对外链接主推 **https://xlang.dev** |

### 7.3 回归纪律（继承自举 skill）

- 不在 Ubuntu 上 commit  
- mac→Ubuntu **只 git**  
- 一条债一层；rename 波次内**不**夹带 Cap residual 行为变化  
- 谈「可继续自举」= R3 双端 L4 已绿 + 进度钉盘已更新  

---

## 8. 工作量与风险粗估

| 波次 | 工作量（量级） | 主风险 |
|------|----------------|--------|
| R0 | 0.5 人日 | 冻结执行不严，边改边自举 |
| R1 | 2～4 人日 | 脚本漏网；bstrict 入口仍找 `xlang_asm` |
| R2 | 2～3 人日 | env 宏与 seed `#ifndef` 不一致；编辑器破坏 |
| R3 | 3～7 人日 | ABI 漏符号；seed 双权威；全量 bstrict 时长 |
| R4 | 1～2 人日 | 三机路径/skill 漂移 |

**总日历**：全职专注约 **1.5～3 周**（含双端 L4 排队与修漏网）；并行 DNS/GitHub 可缩短体感时间。

**最大风险排序**：

1. L-ABI 漏改字符串门控 → 大面积 UNDEF  
2. 测试脚本双名并存过久 → 假绿（测到旧二进制）  
3. skill / 本机路径未改 → Agent 继续写 xlang  
4. 与自举业务混 commit → 无法回滚归因  

---

## 9. 与当前自举状态的衔接

| 项 | 值 |
|----|-----|
| 暂停点 | wave237 已闭；原下一波 Cap residual **冻结** |
| 钉盘 | 仍认 **`d6648bee4`** 直至 R1/R3 重命名验收升钉 |
| 恢复自举条件 | **R3 双端 L4 + bstrict 绿**（至少 R1 完成且进度宣布「命令面已 xlang」后，**不建议**半套 xlang 名继续 Cap） |
| 恢复后第一波 | 原 wave238 清单（resolve 池 `_impl` / seed residual getenv / system `_impl`…）在 **xlang 树**上继续 |
| 进度文 | R0 起 `当前进度.md` / `自举进度.md` 抬头改为 Xlang，并写「重命名工程中」 |

---

## 10. 待用户确认的少数分叉（有默认）

若无回复，**按 §1.2 默认执行**。

1. **GitHub 仓库是否改名 `xlang`？** 默认：是（R4）。  
2. **本机目录是否从 `…/xlang` 改为 `…/xlang`？** 默认：是（R4，与文档一致）。  
3. **ABI 是否必须本轮改完？** 默认：**要**（用户要求源码也全部 xlang）；若中途资源不够，可 **R1+R2 先交付命令面**，但不得宣称「重构完成」。  
4. **`xlangffle` 是否本轮改？** 默认：R2/R3 顺手改为 `xlangffle` 或 `xshuffle`。  
5. **旧域 `xlang.dev`？** 默认：文档降级；DNS 可选 301 → `xlang.dev`。  
6. **兼容窗口长度？** 默认：R1 起 ≤1～2 周双名，R3 后删除。

---

## 11. 建议的「第一刀」提交序列（开工时照抄）

```text
commit 1  docs(xlang): 分析定稿 + 进度冻结自举 + README 域名 xlang.dev 声明（未改二进制）
commit 2  build(xlang): Makefile/g05 产物改名为 xlang*（兼容 symlink）
commit 3  test(xlang): bstrict/lib 宿主 XLANG= + 路径
commit 4  chore(xlang): 根脚本 xlang-build → xlang-build；清理入口
commit 5  rename(xlang): 双端 L2 修漏网
commit 6  release(xlang): 双端 L4 bstrict → 升钉（CLI 层）
… later …
commit N  abi(xlang): xlang_* → xlang_* 符号整波
commit N+1 release(xlang): 双端 L4 → ABI 钉盘
commit N+2 chore: GitHub/path/skill/域名收尾；恢复自举前排
```

---

## 12. 结论

1. **品牌与域名**：项目重构为 **Xlang**，对外主域 **`xlang.dev`**；旧 `xlang.dev` 规划不再作为权威。  
2. **扩展名 `.x` 与诊断 `XP*`** 保持，与 Xlang 一致。  
3. **必须分层**：Brand → CLI → Env → ABI；ABI 最贵，须 seed 同波与双端 L4。  
4. **禁止**全局盲 sed；**禁止**与自举 Cap 业务搅单。  
5. **自举暂停至重构验收完成**；完成后在 xlang 命名下继续 residual。  
6. **仓库外**（skill、三机路径、GitHub、DNS）与仓库内同等重要，漏一则 Agent/金标仍说 xlang。

---

## 13. 相关文档

| 文档 | 关系 |
|------|------|
| 本文 | **重命名权威分析** |
| `analysis/xlang-生态网站规划.md` | 历史（xlang.dev）；以本文域名节为准 |
| `analysis/自举方法.md` / `自举步骤.md` / `自举验证.md` | 验收纪律继承；命令名随 R1 改 |
| `AGENTS.md` · skill `xlang-selfhost-product-gate` | R2/R4 必须同步改名与路径 |
| `README.md` | R0/R2 品牌与 `xlang.dev` |

---

*文档结束。确认 §10 分叉（或默认）后，从 R0 开工；完成 R3 验收前不恢复 Cap residual 自举微波。*
