# `xlang test` 全面单元测试框架设计（`*.test.x`）

> **日期**：2026-07-29  
> **状态**：**分析 / 规格设计（非实现 plan）** — **现在不实现**；自举主航道完成后按阶段落地  
> **用户目标**：实现**全面、强大**的 `xlang test`，直接测 **`tests/**/*.test.x`**（及项目内同约定文件），而不是（或不仅是）转调 shell 脚本  
> **权威交叉**：  
> - 时机：[`自举完成后路线图.md`](自举完成后路线图.md) §3（T0–T3）· P0 基线之后  
> - 现状 CLI：`compiler/src/driver/test.x` · `compiler/src/runtime/rt_run_exec.x` `driver_run_test`  
> - 断言库：`std/test/`（`expect` / `runner_*` / `test_run`）  
> - 产品闸门：`tests/run-all-bstrict.sh`（129）≠ 单元测试框架  
> - 纪律：`AGENTS.md` · skill `xlang-selfhost-product-gate`（G.7 / Ubuntu 金标 / 假绿禁止）

---

## 0. 一句话结论

| 问题 | 结论 |
|------|------|
| **要不要做「`*.test.x` 直接测」？** | **要。** 这是产品化与语言完善的**质量床**，应对标 `cargo test` / `zig test` / `go test` 的「文件即用例」体验。 |
| **现在做吗？** | **不做。** 自举未完成前禁止抢主航道（C 迁移 / 去 pin / 删 Makefile / Cap residual）。 |
| **完成后何时做？** | **P0 钉盘稳住后 → P1 先做 T1 入口统一 → 本框架主体 = T2（可拆 U0–U4 微步）**。 |
| **与 bstrict 关系？** | **互补**：`*.test.x` = 快、语言级、作者日常；bstrict = 产品/链接/平台金标重闸门。终局可用 `xlang test --suite product` **转调** bstrict，但**不得**用单元测试冒充 L4/129。 |

```text
今日：xlang test [script.sh]  →  bash tests/run-all.sh（薄路由）
目标：xlang test              →  发现并编译运行 tests/**/*.test.x
      xlang test path/        →  目录/文件过滤
      xlang test --suite bstrict → （可选）重闸门
```

---

## 1. 今日现状（仓库实测 · 设计前提）

### 1.1 CLI 与驱动

| 项 | 现状 |
|----|------|
| 子命令 | `xlang test` 已挂路由（`main.x` → `driver_cmd_test` → `cmd_test`） |
| 实现权威 | `driver_run_test`（`rt_run_exec.x`）：拼 `cd ROOT && bash SCRIPT`，经 `link_abi_system` |
| 默认脚本 | `tests/run-all.sh`（或 argv 指定相对路径） |
| help 文案 | `Run test script` / `xlang test [script.sh]` — **仍是 shell 语义** |
| **不是** | 发现 `*.test.x`、编译、运行、汇总 pass/fail |

### 1.2 已有「测试」资产（可复用，勿重复造）

| 资产 | 路径 | 能力 | 缺口 |
|------|------|------|------|
| **std.test** | `std/test/test.x` | `expect*`、`runner_case` / `runner_finish`、`test_run(fn)` | 无自动发现；需用例自己 `main` 里调 runner |
| **产品 bstrict** | `tests/run-all-bstrict.sh` 等 | 129 套脚本金标 | 慢、shell 知识、非「语言单元测试」 |
| **零散探针** | `tests/**/*.x` | 大量「手写 main + 返回码」 | 命名不统一，**尚无 `*.test.x` 约定文件** |

### 1.3 关键阻塞：入口文件名里的 `.`（实现前必修）

实测（2026-07-29）：编译 `/tmp/sample.test.x` 时 host-C 生成：

```c
extern int32_t sample.test_main(void);  /* 非法 C 标识符：中间的点 */
```

**根因（归层）**：

| 层 | 行为 |
|----|------|
| 产生 | `xlang_entry_lib_name_from_path_impl` 对 basename 只剥末尾 **`.x` / `.su`**，stem 保留 **`sample.test`** |
| 存储 | `entry_module_import_path_mirror` / `current_codegen_prefix_mirror` = `sample.test` + `_` |
| 消费 | codegen 发射 `prefix + main` → `sample.test_main` → **host-cc 失败 BLD001** |

对比：`codegen_import_path_to_c_prefix_into` 对 **import 路径**已会把 `.` → `_`，但 **入口 lib_name 未走同一消毒**。

| 修法（实现期，非本文交付） | 说明 |
|----------------------------|------|
| **权威** | G.7 单点：`xlang_entry_lib_name_from_path_impl`（.x + seed 孪生同 commit） |
| **规则** | stem 中非 `[A-Za-z0-9_]` 一律 `_`（至少 `.` → `_`） |
| **验收** | `foo.test.x` / `a.b.c.x` 均可 `-backend c` 与 `-backend asm` 编过并运行 |
| **注意** | `path` 含 `main`/`parser`/… 子串时的 keyword 短路（现有 strstr 链）— `tests/main/...` 等路径仍可能撞 keyword；设计约定或收紧为 **basename 边界匹配**（实现期另项） |

> **结论**：用户指定的 `*.test.x` **命名是合理产品目标**；实现 runner **之前或同波**必须修入口 stem 消毒，否则框架一上线即假红。

---

## 2. 产品愿景：对标什么

### 2.1 用户故事

```text
# 日常（开发者）
xlang test                          # 默认：仓库/项目下全部 *.test.x
xlang test tests/typeck/            # 只跑目录
xlang test tests/arith.add.test.x   # 单文件
xlang test -k add                   # 路径/名过滤
xlang test -j 8                     # 并行（后期）

# 退出
exit 0  = 全绿
exit 1  = 有失败或编译失败
```

期望输出（示意）：

```text
xlang test: suite=unit root=tests filter=- backend=asm
  PASS  tests/arith/add.test.x  (3ms)
  PASS  tests/typeck/bool_rules.test.x  (12ms)
  FAIL  tests/net/timeout.test.x  (exit=2)
        compile: ok · run: exit 2
──
total=3 pass=2 fail=1 skip=0  time=45ms
```

### 2.2 能力矩阵（「全面 / 强大」拆解）

| 能力 | 优先级 | 说明 |
|------|--------|------|
| **发现** `**/*.test.x` | P0 | 递归；可配置 root |
| **编译+运行** 单文件 | P0 | `main(): i32`，0=过，非 0=败 |
| **汇总报告** | P0 | total/pass/fail/skip + 路径 |
| **过滤** `-k` / 路径参数 | P0 | 子串匹配相对路径 |
| **后端选择** | P0 | 默认与产品一致（终局 asm；过渡可 `c`/`asm` 双跑 opt-in） |
| **失败保留产物** | P1 | 失败时保留 `-E` / 二进制路径，便于归因 |
| **与 std.test 集成** | P1 | 文件内用 `expect_*` / `runner_*`；runner 仍看 **进程退出码** |
| **并行** `-j N` | P2 | 进程级并行；注意 TMPDIR |
| **`#[test]` / 多用例单文件** | P2 | 需反射或注册表；见 §4.3 |
| **JSON/JUnit** | P3 | CI 友好 |
| **coverage** | P3 | 后置 |
| **转调 bstrict** | P1 可选 | `xlang test --suite product` 不替代 L4 |

---

## 3. 文件与约定（规格）

### 3.1 命名

| 约定 | 规则 |
|------|------|
| **单元测试文件** | `*.test.x`（推荐全小写路径段：`tests/<area>/<name>.test.x`） |
| **位置** | 默认发现根：`tests/`；项目模式可读 `xlang.toml [test].roots`（后期） |
| **非测试** | 普通 `tests/foo/main.x`、gate 脚本 **不**被 unit suite 自动收录 |
| **禁止** | 用 `*.test.x` 塞整仓 bstrict 级重链接用例（应走 product suite） |

### 3.2 单文件契约（U0 / 最小可交付）

```x
// tests/arith/add.test.x
// 约定：唯一入口 main；返回 0 通过，非 0 失败。
// 可选：import std.test 使用 expect_*，最后仍以 main 返回值为准。

function main(): i32 {
  if (1 + 1 != 2) {
    return 1;
  }
  return 0;
}
```

| 规则 | 说明 |
|------|------|
| **入口** | 必须有 `main(): i32`（或后续约定 `test_main` + `#[no_mangle]`，**不推荐**第二套） |
| **通过** | 进程 exit code **0** |
| **失败** | 非 0；编译失败计 **FAIL（compile）** |
| **无 stdout 契约** | 允许打印；汇总以退出码为准（避免 CTFE/缓冲假绿） |
| **依赖** | 可用 `import`；`-L` 与产品 `xlang build` 一致 |

### 3.3 与 std.test 的协作（推荐写法）

```x
import std.test;

function main(): i32 {
  test.runner_reset();
  // 逻辑断言
  if (test.expect_eq_i32(1 + 1, 2) != 0) {
    return test.runner_finish(); // 或直接 return 1
  }
  return test.runner_finish(); // fail 数作退出码（若 API 语义如此则对齐文档）
}
```

> **实现期注意**：核对 `runner_finish` 返回值是否 = fail 数；规格要求 **进程退出码 0 iff 全过**。若现 API 不符，G.7 在 `std.test` **补全**，禁止 runner 旁路第二套计数。

### 3.4 多用例单文件（U2+ · 可选进阶）

两种路线（**二选一作权威**，禁止双轨）：

| 路线 | 形态 | 优点 | 缺点 |
|------|------|------|------|
| **A. 进程级多文件** | 一文件一 `main`，目录下多 `.test.x` | 简单、隔离好、与现编译器匹配 | 文件数多 |
| **B. 文件内多 `test_*`** | `function test_add(): i32` + 驱动枚举 | 单文件多 case | 需 **注册/命名约定/弱反射**；今日无稳定反射 |

**推荐**：**先 A（U0–U1）**；B 在 typeck 能稳定列出「导出函数名表」或引入 `#[test]` 属性后再做（U3）。

若走 B，建议约定：

- 仅 `export function test_*(...): i32` 零参；  
- 驱动生成或链接「harness」调用各 `test_*`；  
- 任一非 0 → 文件 FAIL。

---

## 4. CLI 规格（目标态）

```text
xlang test [options] [paths...]

Options（目标；分阶段开放）:
  --suite unit|product|all   默认 unit（*.test.x）
  --backend asm|c            默认跟随产品发布默认
  -k <substr>                只跑相对路径包含 substr 的用例
  -j <N>                     并行度（默认 1）
  --fail-fast                首败即停
  --list                     只列出将跑的文件
  --keep-going               编译失败也继续（默认 keep-going=true 便于汇总）
  --script <path.sh>         兼容旧：跑 bash（过渡期）
  -L <dir>                   与 build 相同
  -h, --help
```

| 参数 paths | 行为 |
|------------|------|
| （空） | 在默认 root（`tests/` 或 toml）下递归 `*.test.x` |
| `foo.test.x` | 只跑该文件 |
| `dir/` | 该目录下递归 `*.test.x` |
| `*.sh` 或 `--script` | **兼容旧 shell**（过渡；文档标明 deprecated 时间表） |

**退出码**：

| code | 含义 |
|------|------|
| 0 | 所列 unit 全过（且 suite=product 时金标也过） |
| 1 | 有 FAIL / 编译失败 / 无匹配用例且配置为失败 |
| 2 | 用法错误 / 无法发现 root |

---

## 5. 架构（实现时的模块落点 · G.7）

```text
xlang test
    │
    ▼
driver_cmd_test / cmd_test          （路由，薄）
    │
    ├─ suite=unit ──► unit_test_runner（新权威，建议 .x）
    │                     │
    │                     ├─ discover *.test.x
    │                     ├─ for each: compile (reuse build/run path) + exec
    │                     └─ report summary
    │
    └─ suite=product / --script ──► 现有 driver_run_test shell 路径（过渡）
```

| 模块 | 职责 | 禁止 |
|------|------|------|
| **unit_test_runner** | 发现、调度、汇总 | 内嵌第二套 codegen |
| **compile/run** | 复用 `driver_run_compiler_*` / `xlang build` 同路径 | 私自 `gcc` 多链 |
| **std.test** | 断言与进程内 runner | 替代进程级发现 |
| **shell bstrict** | 产品金标 | 默认 `xlang test` 静默变成全量 129 |

**发现实现选项（实现期择一）**：

| 方案 | 做法 | 评价 |
|------|------|------|
| **S1** | runner 内 `find`/`opendir`（POSIX） | 快落地；PLATFORM 注释 LINUX/MACOS；Windows 另桥 |
| **S2** | 纯 .x + `std.fs` 遍历 | 更干净；依赖 fs API 稳定 |
| **S3** | 清单文件 `tests/unit.list` | 可控但易漏；仅作 optional |

推荐：**S1 过渡 → S2 收敛**；清单仅 opt-in。

---

## 6. 分阶段落地（U0–U4 · 对应路线图 T 阶）

> **现在：0 实现。** 下表供自举完成后排期。

| 阶段 | 名称 | 交付 | 前置 | 验收 |
|------|------|------|------|------|
| **U0** | 入口 stem 消毒 | `foo.test.x` 可编可跑 | 无 | 双端 `-backend c/asm` 探针绿 |
| **U1** | **最小 unit suite** | 发现 `tests/**/*.test.x` + 串行编译运行 + 汇总；`xlang test` **默认 unit** | U0 | 仓库内 ≥3 个示例 `.test.x` 全绿；help 更新 |
| **U2** | 过滤与体验 | `-k`、paths、`--list`、`--fail-fast`、失败保留路径 | U1 | 文档五分钟教程可抄 |
| **U3** | std.test 深集成 + 可选多 case | 官方模板；文档；（可选）`test_*` 多用例 | U2 + assert API 稳定 | 示例用 expect 无手写 if 海 |
| **U4** | 并行 / JSON / toml | `-j`、JUnit、`[test]` | U3；xbuild 协同 | CI 模板 |

与 [`自举完成后路线图.md`](自举完成后路线图.md) 对齐：

| 路线图 | 本框架 |
|--------|--------|
| T0 现状 shell | 今日 |
| T1 产品入口 | **可先** `xlang test --suite product` 包 bstrict；**与 U1 可同波或紧挨** |
| T2 工程内建 | **= U1–U3 主体** |
| T3 生态级 | **≈ U4** |

**建议顺序（完成后）**：

```text
P0 基线 → U0 stem 修 → U1 默认 *.test.x →（可选 T1 product 包装）→ U2 过滤 → U3 std.test → U4 并行/报告
```

---

## 7. 与 bstrict / L4 / 假绿纪律

| 套件 | 用途 | 何时跑 |
|------|------|--------|
| **unit `*.test.x`** | 语言语义、小逻辑、快回归 | 每 commit / 每 PR 默认 |
| **产品矩阵** rv/option/hello | 发布面最小 | 动产品面 |
| **bstrict 129** | 全产品脚本金标 | 整波 / 日终 / 谈自举 |
| **L4 真冷** | 全擦 .o + 重链 | 整波收口 / SHARED 大改 |

**禁止**：

- 只跑 unit 绿就写「产品 L4 绿」  
- unit 用例里 `system("make")` 或私自多链  
- 为让 unit 绿而改 bstrict 期望 / soft-skip typeck  

---

## 8. 示例目录布局（目标）

```text
tests/
  README.md                 # 说明：unit=*.test.x；gates=run-*.sh
  unit/                     # 可选：纯 unit 根（若不想与旧 main.x 混）
    smoke/
      add.test.x
      return_zero.test.x
  typeck/
    bool_arith.test.x       # 从旧探针迁/复制
  run-all-bstrict.sh        # 仍在；由 --suite product 调用
  run-all.sh                # 过渡
```

迁移策略：

1. **新建** `*.test.x` 写新用例；  
2. 旧 `tests/foo/main.x` **不强制**改名；重要语义逐步 **复制**为 `.test.x` 再收旧路径；  
3. 禁止一波批量改名破坏 bstrict 路径。

---

## 9. 风险与开放问题

| # | 风险 / 问题 | 倾向决策 |
|---|-------------|----------|
| 1 | 入口 stem 含 `.` | **U0 必修**（§1.3） |
| 2 | path 撞 keyword（含 `main`） | 收紧 keyword 匹配或测试路径避讳 `main` 段 |
| 3 | 默认后端 asm vs c | 终局 asm；过渡双端金标至少一端；mac/Ubuntu 文档写清 |
| 4 | 并行 TMP 冲突 | 每用例独立 tmp 目录 + pid |
| 5 | 与 `xlang run` 重复 | test = 发现+汇总；单文件可内部调 run 路径 |
| 6 | Windows | PLATFORM: 先 POSIX 金标；Windows 后挂 |
| 7 | 无 main 的库式 test | U3 再议；U1 强制 main |
| 8 | 改默认 `xlang test` 破坏旧脚本用户 | 过渡期：`--script` 兼容；changelog 写迁移；或默认 unit 且 `XLANG_TEST_DEFAULT=script` 逃生阀 |

---

## 10. 非目标（明确不做）

| 非目标 | 原因 |
|--------|------|
| 替换 L4 / 全量 bstrict | 金标层级不同 |
| 实现期在本文交付代码 | 用户要求先文档；自举优先 |
| 一次上齐 `#[test]`+并行+coverage | 爆炸半径过大 |
| 在测试框架里修语言债 soft-skip | G.3 假修禁止 |

---

## 11. 实现期检查清单（开工时用）

- [ ] U0：`foo.test.x` 编过（c + asm）  
- [ ] G.7：写清权威符号（lib_name_impl / runner / cmd_test）  
- [ ] seed / `.x` 同 commit（若动 pin 面）  
- [ ] 示例 ≥3 个 `.test.x` 入库  
- [ ] help / `driver/README` / 用户教程更新  
- [ ] 双端（至少 Ubuntu 金标 + mac 冒烟）  
- [ ] 文档写清 unit vs product suite  
- [ ] 未把 bstrict 退出码语义静默改掉  

---

## 12. 与相关文档的索引更新建议

| 文档 | 建议 |
|------|------|
| `自举完成后路线图.md` §3.4 | T2 行指向本文；写明「`*.test.x` 规格见 xlang-test-单元测试框架设计」 |
| `XLANG 命令行.md` | 实现后改 test 用法 |
| `compiler/src/driver/README.md` | 实现后改 test 行 |
| `std/test/README.md` | 增加「与 xlang test 文件约定」交叉链接 |

---

## 13. 变更记录

| 日期 | 变更 |
|------|------|
| 2026-07-29 | 初版：全面分析 `xlang test` + `*.test.x` 规格；记录入口 stem `.` 阻塞；U0–U4 分期；明确**现在不实现** |

---

> **给排期的一句话**：自举完成并 P0 钉死后，**先修 `*.test.x` 可编（U0），再让 `xlang test` 默认跑 `tests/**/*.test.x`（U1）**——这就是「全面强大的 xlang test」的最小正确骨架；再叠过滤、std.test、并行与报告。  
> **现在**：只维护本文与路线图交叉引用；**实现 PR 未授权前不开工。**
