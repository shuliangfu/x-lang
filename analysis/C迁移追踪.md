# C → .X 迁移追踪（状态待办地图）

> **用途**：终局债 **状态 only**（✅／🟡／⬜ + 路径／验收／为何开）。  
> **禁止**：tip 流水账、wave／SHA 日记、双端 `/tmp` 日志、「证：…」长叙事。波次流水只写 [`自举进度.md`](自举进度.md) §6。  
> **考古副本**（本波重写前全文）：[`archive/C迁移追踪-流水账归档-20260825.md`](archive/C迁移追踪-流水账归档-20260825.md)  
> **刷新**：2026-08-25 · 钉盘 **`e8176cbe5`**（不随微步升钉）

### 维护约定

1. 做到某一项 → 标 **🟡**；完成 → **✅**；未开 → **⬜**。  
2. 只改状态与必要事实（路径、LOC、验收条件）。  
3. 不要往本文追加「本波完成了什么」段落。  
4. MG／Makefile 叶映射细节见 [`Makefile迁移表.md`](Makefile迁移表.md)。

---

## 0. 仪表盘

| 轨道／债 | 状态 | 事实（短） |
|----------|------|------------|
| 库层 .X 化（阶段 1） | ✅ | 100% |
| Thin 退役（阶段 2） | ✅ | T 18/18 |
| Prove 注册（阶段 3） | ✅ | N 111/111 |
| Cap 能力解锁（阶段 4） | 🟡 | 前排大多闭；3 leave-off ⬜ |
| R2 真迁（阶段 5） | 🟡 | ~120/128（~85%） |
| Mega 拆分 M1–M3（阶段 6） | ✅ | 3/3 |
| Mega 去 pin M4（阶段 7） | 🟡 | 冷链关 pin 5/5；parser seed 物理删／CI 漂移闸 ⬜ |
| Pinned gen 退役（阶段 8） | ✅ | 30/30 FULLY CLOSED |
| 非 gen 产品 C／8.3（glue／ast／BC） | 🟡 | 结构 leave 多 ✅；`pipeline_x` 整 TU 仍 host-cc；from_x 全表策略 ⬜ |
| Cap residual 消灭（阶段 9） | ⬜ | 0/~50；依赖阶段 10 |
| 语言能力 L2（阶段 10） | ⬜ | 0/~20 |
| xbuild／MG（阶段 11） | 🟡 | Makefile 物理删 ✅；核心终局／零 cc CI／editors 仍开 |
| 冷启动零 cc（阶段 12） | 🟡 | LINK／`.s`／门禁大半 ✅；最小 seed／全路径零 cc ⬜ |
| 终局 MG+BC+PC+v2==v3（阶段 13） | 🟡 | MG 文件层 ✅；BC／PC／v2==v3 未终 |
| 产品 L4 钉盘 | ✅ | **`e8176cbe5`**；bstrict 129 |
| BC（自举编译层零 host-cc） | 🟡 | inventory 冻；`pipeline_x` 仍 host-cc mega |
| PC（产品默认 asm／禁默 host-cc） | 🟡 | 去 import→C／FORBID／ALLOW／ld-only ✅；invoke_cc 未删 |
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 须点名；产品 thin-first／inject |
| nest 冻帽 | ✅ 纪律 | **64**；禁本叶抬 65 |
| check 闸门 | ⏸ 暂停 | 自举期 L2／L4 不跑；须点名才 dogfood |

**终局三义**：MG ✅ · BC 🟡 · PC 🟡。

---

## 阶段 0–3 · 已闭

- ✅ **阶段 0** 基建与方法论  
- ✅ **阶段 1** 库层 .X 化  
- ✅ **阶段 2** Thin 退役 T 18/18  
- ✅ **阶段 3** Prove 注册 N 111/111  

---

## 阶段 4 · Cap 能力解锁 🟡

> 大量 dest／dyn／nest17–64／METHOD／STRUCT_LIT 等已闭（细节见归档副本）。下表只留开项。

### 开项

- ⬜ **4.2.8** AST name 槽 128B layout raise — leave-off（honest-fail 已绿；可变长名槽未做）  
- ⬜ **4.2.9** LANG-006 标量 bool→int — **有意保留 soft**（`let x: i32 = true` 合法）  
- ⬜ **4.2.16** `*T[N]` 解析序 — **有意保留 soft**（`*T[N]`＝指针数组；指针到数组写 `*[N]T`）  

### 纪律（非待办编号）

- nest **冻 64**；禁抬 nest 65；禁无界 assemble `parser.x`／`pipeline_abi` mega 当冷路径  

---

## 阶段 5 · R2 真迁 🟡

- ✅ 已真迁 ~120／128 prove 模块  
- 🟡 余 ~8 仍绑 Cap residual／平台债  

### 待收口

- ⬜ **5.2.2** Darwin stage2 rv／strict multi-def — 平台债  
- ⬜ **5.2.3** host `_impl` 后缀命名 — leave-off  
- ⬜ **5.2.4** Darwin `int64_t main` 硬要求 int — 平台债  
- ⬜ **5.2.5** Windows MSYS2 继承 hybrid 未重跑 — 平台债  
- ⬜ **5.2.6** mac CTFE 常 fold 假绿 — 工程债  
- ⬜ **5.2.7** mac `-dead_strip` 假绿当 Ubuntu 全链已过 — 工程纪律债  

---

## 阶段 6 · Mega 拆分 M1–M3 ✅

- ✅ **6.1** runtime mega 拆分  
- ✅ **6.2** parser thin mega 拆分  
- ✅ **6.3** link_abi mega 拆分  

---

## 阶段 7 · Mega 去 pin（M4）🟡

> 冷链关 pin **5／5**（runtime／typeck／codegen／parser／link_abi）。pin 文件可作考古 egg。

### 已闭（摘要）

- ✅ **7.1** runtime monofile 物理退役；产品拒 monofile  
- ✅ **7.2.3／7.3／7.4.1／7.4.2／7.4.3** 冷链／Stage2 相关验收（细节见归档）  
- ✅ link_abi／typeck／codegen 冷链 prefer `.x`（默认产品 FROM_X 策略按域）  

### 开项

- ⬜ **7.2.1** 关闭 parser pinned seed — `seeds/parser_asm_thin_c.from_x.c`（~21,935 LOC）仍在；目标从 `pthin_*.x` 重建  
- 🟡 **7.2.2** parser_gen 去 pin — **产品冷权威 pin-first**（`XLANG_PARSER_FROM_X=0` 默认；tip assemble 仅显式 `=1`）；手术改须 seed+`.x` 同 commit  
- ⬜ **7.4.4** 双权威禁令验收 — touch `*.x` 须同 commit 禁「只改 seed」；可选 CI pin↔`-E` 漂移闸  

---

## 阶段 8 · Pinned gen 退役 ✅ · 8.3 非 gen 🟡

### 8.1–8.2 gen

- ✅ **8.1** PRODUCT RETIRED **23／23**  
- ✅ **8.2** NON_PRODUCT 正确分类 **7／7**  
- ✅ **合计 30／30 FULLY CLOSED**  

### 8.3 非 gen 产品 C／链接桩 🟡

> 目标：BC＝编译器 TU **不**再被 host-cc 编译。结构／域 leave 多已做；**父项离 host-cc 仍开**。

#### 进行中

- 🟡 **8.3.1** `pipeline_glue` → .x／域 thin — 业务叶多 fold；父项未离 host-cc  
- 🟡 **8.3.2** `ast_pool` → .x — 多域 leave；父项仍 host-cc 入 `pipeline_x`  
- 🟡 **8.3.3** `pipeline_typeck_field_access`／`soa` — 叶 leave ✅；父项因 `pipeline_x` 整 TU 仍 host-cc  
- 🟡 **8.3.6** `seeds/*.from_x.c` 全表退役策略 — 部分产品壳已删；**全表** pin／prove／EMPTY／standalone 策略未终  
- 🟡 **8.3.8** `build_asm/gen_driver/*.c` — 仅剩 `pipeline_gen.c` 构建链残留待确认（产品用 `pipeline_x.o`）  

#### 未开／残

- ⬜ **8.3.6 残** 全表 from_x 退役策略终稿（分类表 + 冷启动不读业务体）  
- ⬜ **8.3.10** `editors/tree-sitter-xlang/` 第三方 .c — 删／submodule／独立 release  
- ⬜ **BC 终局** `pipeline_x` 整 TU 离 host-cc（gen／runtime seed 等在图内）  

#### 已闭（摘要）

- ✅ **8.3.4／8.3.5／8.3.7／8.3.9** 等相关 leave／stubs／孤儿清理（见归档）  
- ✅ glue 壳／typedefs／9×fwd／standalone **deleted**；bc-inventory present product C rows **0**  

---

## 阶段 9 · Cap residual 边界消灭 ⬜

> 原「永久边界」→ **必须消灭**。顺序：9.1 → 9.4／9.5 → 9.2 → 9.3 → 9.6 → 9.7。依赖阶段 10 语言能力。

### 9.1 OS 系统调用（P0）

- ⬜ **9.1.1** getenv／setenv／unsetenv／environ  
- ⬜ **9.1.2** stat／access／realpath  
- ⬜ **9.1.3** getcwd／chdir／getpid／getppid  
- ⬜ **9.1.4** execve／waitpid／pipe／spawn／system  
- ⬜ **9.1.5** clock_gettime／nanosleep／gmtime_r／QPC／Sleep  
- ⬜ **9.1.6** getrandom／getentropy／BCryptGenRandom  
- ⬜ **9.1.7** getaddrinfo／WSAStartup／socket／connect／poll／recvmmsg／sendmmsg  
- ⬜ **9.1.8** `_write`／write  
- ⬜ **9.1.9** inline asm syscall（Linux x86_64）  
- ⬜ **9.1.10** opendir／readdir／closedir  
- ⬜ **9.1.11** execinfo／dladdr／DbgHelp／CaptureStackBackTrace  
- ⬜ **9.1.12** sysctl／proc／`#if`  

### 9.2 第三方库（P2）

- ⬜ **9.2.1** mbedtls BIO send／recv  
- ⬜ **9.2.2** zlib deflateInit2_／inflateInit2_  
- ⬜ **9.2.3** ed25519 ref10（.inc 宏）  
- ⬜ **9.2.4** libm `math_*_impl`（32 桥）  
- ⬜ **9.2.5** arrow SIMD kernels  
- ⬜ **9.2.6** sqlite3 C API  

### 9.3 宏展开（P2）

- ⬜ **9.3.1** ed25519 ref10 宏重命名  
- ⬜ **9.3.2** zlib macros `#undef`  
- ⬜ **9.3.3** `#if` host 字面量  
- ⬜ **9.3.4** C11 stdatomic／GCC `__atomic`  
- ⬜ **9.3.5** SIMD intrinsics  

### 9.4 C ABI／fnptr／线程（P1）

- ⬜ **9.4.1** uintptr_t→fnptr cast + indirect call  
- ⬜ **9.4.2** `void*(*)(void*)` C ABI  
- ⬜ **9.4.3** `main` 的 `char**` argv  
- ⬜ **9.4.4** pthread_mutex／cond／create  
- ⬜ **9.4.5** CRITICAL_SECTION／SRWLOCK／CONDITION_VARIABLE／CreateThread／`_beginthreadex`  
- ⬜ **9.4.6** SetThreadAffinityMask／qos_class  

### 9.5 FILE／fprintf／va_list（P1）

- ⬜ **9.5.1** driver_preamble_fputs  
- ⬜ **9.5.2** xlang_target_cpu_print（FILE／fprintf）  
- ⬜ **9.5.3** reportf／va_list  
- ⬜ **9.5.4** vsnprintf + write  

### 9.6 全局／static／巨型数据（P1）

- ⬜ **9.6.1** `u8[N]` 全局／static BSS  
- ⬜ **9.6.2** 巨型字串表数据  
- ⬜ **9.6.3** static 共享状态  

### 9.7 driver_abi 平台层（P3）

- ⬜ **9.7.1** FILE／pctx／host／defines／work 槽  
- ⬜ **9.7.2** lib_roots 槽 + Parsed 填表  
- ⬜ **9.7.3** GAS 行表 + OutBuf append  
- ⬜ **9.7.4** driver_stdio_* + driver_entry_*_slot  
- ⬜ **9.7.5** usage_write + compiled_body  
- ⬜ **9.7.6** driver_run_stack_esc_gate（pthread）  
- ⬜ **9.7.7** driver_run_thread_on_large_stack_pthread  

---

## 阶段 10 · 语言能力补齐（消灭 residual 前提）⬜

### 10.1 syscall／FFI

- ⬜ **10.1.1** Linux x86_64 syscall 内建  
- ⬜ **10.1.2** Linux arm64 syscall 内建  
- ⬜ **10.1.3** Windows NT API 内建  
- ⬜ **10.1.4** raw FFI（`extern "C"` 调用约定）  

### 10.2 inline asm

- ⬜ **10.2.1** x86_64 inline asm  
- ⬜ **10.2.2** arm64 inline asm  
- ⬜ **10.2.3** Windows inline asm／intrinsics  

### 10.3 fnptr

- ⬜ **10.3.1** fnptr 类型表达  
- ⬜ **10.3.2** fnptr cast + indirect call  
- ⬜ **10.3.3** fnptr 作参／返回／字段  

### 10.4–10.7

- ⬜ **10.4.1** atomic_load／store／cas  
- ⬜ **10.4.2** 内存屏障内建  
- ⬜ **10.5.1** x86 AVX／SSE 内建  
- ⬜ **10.5.2** ARM SVE／NEON 内建  
- ⬜ **10.6.1** Linux futex／clone／mmap 栈  
- ⬜ **10.6.2** Windows CreateThread／WaitForSingleObject  
- ⬜ **10.6.3** 互斥锁／条件变量／信号量  
- ⬜ **10.7.1** va_list + va_start／arg／end  
- ⬜ **10.7.2** .x 自实现 vsnprintf  

---

## 阶段 11 · xbuild + Makefile 退役（MG）🟡

### 已闭（摘要）

- ✅ **11.2.2** `./xbuild l4`  
- ✅ **11.2.3／11.2.5／11.4.1／11.4.3／11.4.6** 等相关编排入口  
- ✅ **11.3／11.3.1** Makefile **物理删除**；catalog 单权威；bootstrap 0 make  

### 11.1 核心 · 进行中／终局 ⬜

- 🟡 **11.1.1** 依赖图分析 — 库存多 ✅；⬜ 终局：import 扫描 + 增量图（依赖 11.1.2；叶→11.3.1）  
- 🟡 **11.1.2** 编译调度 — ⬜ 终局：`.x` import 增量图 + 并行；冷叶不经 make pattern  
- 🟡 **11.1.3** 平台处理 — ⬜ 终局：UNAME 叶 pattern 全吞；禁第二套 uname 矩阵  
- 🟡 **11.1.4** 链接 — ⬜ 终局：Windows PE pure-ld；无 residual `CC -o`／FORCE_CC 收敛  
- 🟡 **11.1.5** `build.x` 策略源 — ⬜ 终局：DAG-as-data 替代 C build_runtime 步表  
- 🟡 **11.1.6** 吞并 g05 — ⬜ 终局：xbuild 内建或单一 `scripts/g05` 族  

### 11.2 编排开项

- ⬜ **11.2.1** stage1→2→3 编排 + 自动 v2==v3  
- ⬜ **11.2.4** Windows／MSYS2 本地 xbuild 入口（CI 已 `./xbuild compiler-all`）  

### 11.3 删 Makefile 残

- ⬜ **11.3.3** 删除／归档其它 make 碎片（含 tree-sitter Makefile 等）  
- ⬜ **11.3.4** 「无 make + 无 cc」CI 闸门  

### 11.4–11.6

- 🟡 **11.4.5** `tests/docker/linux-dev.Dockerfile` — 仍装 `gcc`／`make`（卸包装＝阶段 12）  
- 🟡 **11.5.1** `bench/**/*.c` — 策略已裁定（`tests/HOST_CC_POLICY.md`）；卸 cc→12  
- 🟡 **11.5.2** `tests/std-*/*.c` — 同上  
- 🟡 **11.5.3** `tests/abi|leak|safe|kernel/*.c` — 同上  
- 🟡 **11.5.4** `tests/probes/**/*.c` — 同上  
- ⬜ **11.6.1** `editors/tree-sitter-xlang/` 第三方 grammar  

全量叶映射 → [`Makefile迁移表.md`](Makefile迁移表.md)。

---

## 阶段 12 · 冷启动零 cc 🟡

### 已闭（摘要）

- ✅ LINK 全零 cc · `.s` COMPILE 零 cc · stub weak `.s` · `forbid_host_cc`  
- ✅ STRING_LIT／module const／empty `[]`／emit／lsp_diag CG002 等相关根修  
- ✅ `pure_asm_x_to_o` · Darwin mangling · prefer 族／硬闸 strip／ALLOW_TREE 地图  
- ✅ labi／rt／R3／B1–B3／COMPILE residual 13／13 等 hybrid 地图（产品默认仍可 `-E`；mega 硬禁）  

### 开项

- 🟡 **12.0.5** asm backend 模块覆盖 — prefer 绿多；**`pipeline_abi` mega 仍硬禁**；COMPILE 仍可 `$CC -c`  
- ⬜ **12.1.1** 手写 asm seed（或极简二进制）  
- ⬜ **12.1.2** seed 产出 xlang_v1（无需 `-E`→cc）  
- ⬜ **12.1.3** 与 pin 退役衔接（冷输入＝`.x` + 最小 seed）  
- 🟡 **12.2.1** 零 cc 验证 — LINK／`.s` 可零；⬜ **全路径**零 `execve(cc)`（COMPILE residual）  
- ⬜ **12.2.2** 双端冷启动验证（零 cc 闭环；钉盘 L4 仍含 host-cc COMPILE）  
- 🟡 **12.2.3** 产品默认后端 — 默认 asm／FORBID／ALLOW／ld-only 已收敛；`labi_invoke_cc` 未删  

---

## 阶段 13 · 终局 🟡

### 13.1 语义

- ✅ **13.1.1** 前置闸门定义（见归档／方法文）  
- ⬜ **13.1.2** 阶段 8 gen + 8.3 glue／ast／桩完成（gen ✅；8.3／BC 未终）  
- ⬜ **13.1.3** 阶段 9 residual 全部消灭  
- ⬜ **13.1.4** v2 == v3 语义自举  
- ⬜ **13.1.5** D-03 bit-identical（可选）  

### 13.2 零 Makefile／零 cc

- ⬜ **13.2.1** 双端 L4 真冷 + 129 bstrict（xbuild · **零 make · 零 host-cc**）  
- 🟡 **13.2.2** Makefile 物理删除验收 — 文件层 ✅；零 make 调用面／host-cc residual 🟡  
- ⬜ **13.2.3** 零 cc 三义验收（MG+BC+PC）  
- 🟡 **13.2.4** `labi_invoke_cc`／`-backend c` 退役或隔离 — 门控已收；本体未删  

### 13.3 收尾

- ⬜ **13.3.1** 物理删 seed 业务体（考古归档）  
- ⬜ **13.3.2** 宣布自举完成  

---

## 产品软残（非阶段编号 · 日常软刀池）

> 流水与证据在 [`自举进度.md`](自举进度.md)。此处只勾选。

| 项 | 状态 | 备注 |
|----|------|------|
| L6 unused-hint | ⬜ 自主择优 | check 闸仍暂停；优先级到则开（无需点名） |
| WPO_DUMP_CALLGRAPH | ⬜ 自主择优 | 产品 dump；优先级到则开（可涉 mega） |
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 非软刀默认；优先级到才动 |
| LANG-009／010 Option／Result 泛型 STRUCT_LIT | ✅ | 解析 mangle＋具名 lit typeck；闸 run hard |
| CORE-016 多 mono／多 let 字段 load 宽 | ✅ | typeck mono 戳优先于泛型布局 T→8；thin inject |
| CORE-016 Option／Result 泛型↔族 unify | ✅ | named-inst mangle 等式＋let 族 canonicalize；闸 run hard |
| CORE-013 i16／u16 size／align formal | ✅ | labi g1 全表针＋闸 run hard |
| CORE-017 core.mem volatile／fence formal | ✅ | labi_od_core_mem×31＋闸 run hard |
| CORE-004 core.slice API formal | ✅ | labi g9×28＋闸 run hard |
| CORE-006 iterator protocol formal | ✅ | 闸 prefer asm＋smoke／cookbook run hard |
| CORE-007 core.str BytesView formal | ✅ | 闸 prefer asm＋smoke／cookbook run hard |
| CORE／lang runnable soft SKIP | 🟡 | 余例：002／STD-131／012 |
| nest 冻 64 | ✅ 纪律 | — |
| 钉盘 `e8176cbe5` | ✅ | 不随微步升钉 |

---

## 附录 · 钉盘与映射

### 钉盘

| 项 | 值 |
|----|-----|
| 产品 L4 放行钉盘 | **`e8176cbe5`** |
| bstrict | 129 |
| 升钉条件 | 用户点名 L4／谈自举；禁止微步升钉 |

### Makefile 桶（摘要）

| 桶 | 状态 |
|----|------|
| MG 编排／物理删 Makefile | ✅ |
| H／D／E／F／B／A／M 等执行桶 | 🟡 见 [`Makefile迁移表.md`](Makefile迁移表.md) |
| C glue／pipeline_x · K seed-tools · L std-variant · N/O alias | ⬜／🟡 同上 |

### 推荐推进序（非流水）

1. 日常软刀／PC 底盘（非 mega；须点名才动 check／mega）  
2. 🟡 **BC + 8.3**（`pipeline_x` 离 host-cc · from_x 全表策略）  
3. ⬜ **7.2.1／7.4.4** parser seed 物理删／双权威闸  
4. ⬜ **阶段 10 → 9** 语言能力 + residual 消灭  
5. ⬜ **阶段 12–13** 最小 seed · 全路径零 cc · v2==v3 · 公告  

---

> **使用**：完成一步只改对应 `⬜`→`🟡`→`✅`。不要在本文写 tip／wave／日志路径。
