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
| L6 unused-hint | ✅ | `pipeline_typeck_unused_binding_hints`＋thin；闸 hard（无 soft SKIP） |
| WPO_DUMP_CALLGRAPH | ✅ | `pipeline_typeck_wpo_dump_callgraph`＋thin；S1／comp-wpo 闸 hard（无 soft SKIP） |
| async_net_fs unique UNDEF | ✅ | labi async 针 ×4＋formal_surface → `xlang_async_net_fs_smoke_c`；Ubuntu gold cookbook／L2 |
| net_tcp_pool 真 create | ✅ | net_merge 编入 tcp_pool.x＋强别名；labi net 针 ×32；Ubuntu gold cookbook／smoke／L2 |
| zc_arena_concat T001 | ✅ | `string_view_concat_arena(*heap.Arena64)`＋`heap.arena64_alloc`；Ubuntu gold 成功分 8／L2 |
| view_lifecycle discard `_` | ✅ | typeck one_let／one_const 豁免精确 `"_"` redecl；Ubuntu／Darwin `view_lifecycle` run=0／L2 |
| print_any JSON println | ✅ | typeck fmt-any 放行＋asm schema emit＋`std_fmt_json_*_schema`／`u8_slc` stubs；fmt-std 纳 print_any；双端 L2 |
| u8_slc fat-pointer ABI | ✅ | io stubs `std_fmt_*_u8_slc(const XlangSliceU8 *)` 对齐 TYPE_SLICE 形参权威；fmt-std 纳 print_u8_slc；双端 L2 |
| host-C STRUCT_LIT mono 标签统一 | ✅ | 外层 joiner `__`→`_`（≡ typeck named-inst）；`Box_i32` 单权威；函数 mono 仍 `__`；双端 L2 |
| TYPE_SLICE i32[] print_any schema A@ | ✅ | fat `A@OFF` JSON；u8[] 仍 u8_slc mid；fmt-std 内容硬闸；双端 L2 |
| ArrowColumnMem 32B pack／db_kv_arrow | ✅ | `data_owned` 挪入 calloc(1,32) 头内；SIMD twin 同 commit；cookbook 8／8＋smoke；双端 L2 |
| STD-025 env_iter soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；runnable／cookbook exit0 硬失败；双端 L2 |
| STD-017 heap_trace soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；runnable／cookbook exit0 硬失败；双端 L2 |
| STD-020 error_map soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；runnable／cookbook exit0 硬失败；双端 L2 |
| STD-158 error_semantics soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；runnable／cookbook exit0 硬失败；双端 L2 |
| STD-015 set-extend soft→硬绿 | ✅ | TSV 锚对齐产品 overload；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；runnable／cookbook exit0 硬失败；双端 L2 |
| STD-112 heap-allocator soft→硬绿 | ✅ | TSV 锚对齐产品 `with_alloc`／`push`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；runnable／cookbook exit0 硬失败；双端 L2 |
| STD-129 set-ops soft→硬绿 | ✅ | TSV 锚对齐产品 `union_into`／`intersect_into`／`difference_into`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；runnable／cookbook exit0 硬失败；`ops.x` 避 by-value+栈数组 helper；双端 L2 |
| STD-156 context-cookbook soft→硬绿 | ✅ | expand DOC／TSV→archive；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；CTX-01 exit0 硬失败；拒顶层 DOC 复活；双端 L2 |
| STD-071 context soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`cancel_smoke.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-155 bytes-arena soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`arena_external.x` exit0 硬失败；化石 `arena_init`→`arena64_init`；双端 L2 |
| STD-150 sort-key-cmp soft→硬绿 | ✅ | TSV／archive／README 锚对齐产品 `stable_by_key`／`cmp_key_fn`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`key_stable.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-060 sort-stable-cmp soft→硬绿 | ✅ | TSV／archive 锚对齐产品 `stable`／`cmp`／`cmp_desc_fn`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`stable_i32.x`／`cmp_desc.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-072 std-bytes soft→硬绿 | ✅ | DOC／TSV 锚对齐产品 `length`＋`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；双端 L2 |
| STD-074 std-datetime soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-077 std-cli soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-011 error-unify soft→硬绿 | ✅ | EXC DOC→`analysis/archive/exc/`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`error_unify_smoke.x` exit0 硬失败；双端 L2 |
| STD-109 base64-stream soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`stream.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-019 fmt-multi soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`format_multi.x` exit0 硬失败；双端 L2 |
| STD-096 dynlib-last-error soft→硬绿 | ✅ | 新 archive DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`last_error.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-140 path-extreme soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`extreme_clean.x` exit0 硬失败；双端 L2 |
| STD-055 ffi-cstring soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`cstring_try_new.x` exit0 硬失败；SAFE-004 硬；C smoke 仅观测；双端 L2 |
| STD-053 log-multi-sink soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`level_filter.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-086 std-config soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`layer_smoke.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-119 config-yaml soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`yaml_smoke.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-087 std.cache soft→硬绿 | ✅ | formal_mod `mod\|1`＋fk0 k22＋time_os companion；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`lru_pool_smoke.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-076 std.url soft→硬绿 | ✅ | formal_mod `mod\|1`＋fk0 k23×10；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-079 std.security soft→硬绿 | ✅ | formal_mod `mod\|1`＋fk0 k24×16＋crypto／random／CRYPTO_PAIR companion；API 锚 `hkdf`／`err_ok`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-080/081 std.option／result soft→硬绿 | ✅ | 烟测 `err.*`＋bool `false`；formal_mod `mod\|0`；plan +2；fk0 k25/k26×11；error companion；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；双端 L2 |
| STD-035 json-serialize soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`object_array_roundtrip.x` exit0 硬失败；双端 L2 |
| STD-036 csv-row soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`row_roundtrip.x`＋`main.x` exit0 硬失败；双端 L2 |
| STD-135 datetime-timezone soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`timezone.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-098 channel-select soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；六路 `select_*.x` exit0 硬失败；双端 L2 |
| STD-032 http-methods soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`methods_status.x` exit0 硬失败；DOC／TSV→`## 4. Gate`；双端 L2 |
| STD-033 http-chunked soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`chunked_keepalive.x` exit0 硬失败；bench→`i08_*`；双端 L2 |
| STD-034 http-https soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`https_smoke.x` exit0 硬失败；C/OpenSSL 仅观测；双端 L2 |
| STD-050 crypto sha512-hmac soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；sha512＋hmac exit0 硬失败；mac512 仅观测（产品 UNDEF）；双端 L2 |
| STD-038 tar-ustar soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`ustar_roundtrip.x`／`main.x` exit0 硬失败；恢复 `MOD_X`／`TAR_X`；双端 L2 |
| STD-045 sync-rwlock-condvar soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；API 锚对齐产品 `new_rwlock`／`wait`／`notify_*`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`rwlock_condvar.x`／`main.x` exit0 硬失败；TSAN 可选；双端 L2 |
| STD-029 net-dns soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`resolve_dns.x`／`main.x` exit0 硬失败；双端 L2 |
| STD-043 thread-pool soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；API 锚对齐产品 `set_name_self`／`start`／`submit`／`drain`／`stop`／`pending`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`pool_roundtrip.x`／`main.x` exit0 硬失败；双端 L2 |
| STD-091 io-context soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`context_read_write.x` exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-052 backtrace-symbolicate soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；smoke_c→seed；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；format_hex 按字节；C gold＋`.x` exit0 硬失败（`.x` 接受 hex 名槽）；报告 `check=`／`c_gold=`／`x=`／`skip=`；双端 L2 |
| STD-046 atomic-ordering soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`ordering_fence.x`／`main.x` exit0 硬失败；报告 `check=`／`fence=`／`main=`／`skip=`；双端 L2 |
| STD-130 random-rng soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`rng_roundtrip.x`／`main.x` exit0 硬失败；C smoke 仅观测；报告 `check=`／`rt=`／`main=`／`skip=`；双端 L2 |
| json-object-array soft→硬绿 | ✅ | 历史 archive ID＝游标 STD-034（与 http-https STD-034 撞号，tracker 用本名）；DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`object_array_parse.x` exit0 硬失败；修复 `MOD_X` 被覆盖；报告 `check=`／`oa=`／`skip=`；双端 L2 |
| STD-005 std-time soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`main.x`／`precision_smoke.x` exit0 硬失败；报告 `check=`／`main=`／`precision=`／`skip=`；双端 L2 |
| STD-028 runtime-panic-hook soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`panic_hook_align.x`／`runtime_ready.x` exit0 硬失败；EXC-002 观测；弱锚 `XLANG_WEAK`；EXC RFC live=`archive/exc/`；报告 `check=`／`hook=`／`ready=`／`exc=`／`skip=`；双端 L2 |
| STD-016 strview-zc4 soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`view_lifecycle`／`view_subview`／`arena_concat`／`stack_sso` exit0 硬失败；`run-zc4-gate` 观测；报告 `check=`／`life=`／`sub=`／`arena=`／`sso=`／`zc4=`／`skip=`；双端 L2 |
| STD-026 io-fallback soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；权威改锚 `backend.x`／`sync.x`／`win32.x`（`io.c` 退役）；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`fallback_matrix` exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-007 compress soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；gzip／zstd／legacy（`main.x`）exit0 硬失败；报告 `check=`／`gzip=`／`zstd=`／`legacy=`／`skip=`；双端 L2 |
| STD-006 crypto soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；sha256／hmac／mem_eq／rand／main exit0 硬失败；mac 仅观测（产品 UNDEF）；报告 `check=`／`sha256=`／`hmac=`／`mem_eq=`／`rand=`／`main=`／`mac=`／`skip=`；双端 L2 |
| STD-002／001 net-api＋io-api soft→硬绿 | ✅ | DOC→`## 8/7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`run-net`／`run-io` exit0 硬失败；去化石 `addr_to_packed`∈main.x；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-132 env-platform-encoding soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`platform_encoding.x` exit0 硬失败；C smoke 仅观测；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-136 datetime-iana soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`iana_dst_smoke.x` exit0 硬失败；C smoke 仅观测；报告 `check=`／`run=`／`skip=`；禁顶层 DOC 复活；双端 L2 |
| STD-106 log-rotate-async soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`rotate_async.x` exit0 硬失败；C smoke 仅观测；报告 `check=`／`run=`／`skip=`；禁顶层 DOC 复活；双端 L2 |
| STD-092 net-context soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`context_connect.x` exit0 硬失败；报告 `check=`／`run=`／`skip=`；镜像 STD-091（无 DOC／TSV）；双端 L2 |
| STD-142 process-xplat soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`xplat_behavior.x`／`boundary.x` exit0 硬失败；win／pipe 仅观测（XT001）；修 section 化石路径；报告 `check=`／`xplat=`／`boundary=`／`skip=`；双端 L2 |
| STD-027 dynlib-windows soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`open_sym_close.x`／`main.x`／`win_path.x` exit0 硬失败；win_path C 仅观测；报告 `check=`／`osc=`／`null=`／`win_path=`／`skip=`；双端 L2 |
| STD-SIMD-INTRINSIC soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`intrinsic_binop_dot.x` exit0 硬失败；smoke helper 不再吞 run≠0；报告 `check=`／`x=`／`skip=`；双端 L2 |
| STD-047 simd-shuffle-select soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；DOC 补 `select_lane`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`shuffle_select_roundtrip.x` exit0 硬失败；s4 x86 硬／其它观测；报告 `check=`／`shuffle=`／`select=`／`s4=`／`skip=`；双端 L2 |
| STD-061 simd-prod soft→硬绿 | ✅ | DOC→`## 3. Gate`；对齐 `stub/Xlang`＋`r04_simd_shuffle_select`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；manifest hard；perf soft；报告 `check=`／`bench=`／`skip=`／`ratio=`；双端 L2 |
| STD-153 simd-autovec soft→硬绿 | ✅ | DOC→`## 4. Gate`；对齐 `recommend_path`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`autovec_strategy.x` exit0 硬失败；C／perf soft；section 单权威 archive DOC；报告 `check=`／`c=`／`x=`／`perf=`／`skip=`；双端 L2 |
| STD-021／022 path-fs-windows soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`windows_abs_join.x`／`windows_path_smoke.x` exit0 硬失败；xplat 委托仅观测；报告 `check=`／`path=`／`fs=`／`skip=`；双端 L2 |
| STD-152 tar-extended soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check／C 观测；`long_path_dir.x` exit0 硬失败；TSV section 对齐 DOC；报告 `check=`／`c=`／`x=`／`skip=`；双端 L2 |
| STD-003 fs-crossplatform soft→硬绿 | ✅ | DOC→`## 5. Gate`（§4 仍兼容矩阵）；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；must-policy `.x`／`run-fs.sh` exit0 硬失败；无 native FAIL；报告 `check=`／`x=`／`skip=`；双端 L2 |
| STD-012 examples soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`hello.x`／`io_batch_rw.x` exit0 硬失败；无 native FAIL；报告 `check=`／`x=`／`skip=`；cookbook xref→archive；双端 L2 |
| STD-138 xplat-deep soft→硬绿 | ✅ | DOC→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；must `.x` exit0 硬失败；无 native FAIL；修 `n_cases`；`deep_boundary` `// case 1..6`；报告 `check=`／`x=`／`skip=`；双端 L2 |
| STD-009 http soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`main.x` exit0 硬失败；无 native FAIL；bench→`i08_http_*`；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-008 json soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`main.x` exit0 硬失败；`zc` 观测（Darwin `needs_copy` 残；Ubuntu 金标绿）；无 native FAIL；报告 `check=`／`main=`／`zc=`／`skip=`；双端 L2 |
| STD-048 queue-concurrent soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`main.x`（`Queue_i32`）exit0 硬失败；`sync_queue_roundtrip`／C contention 观测（queue-sync UNDEF）；API 锚→`length`／`sync_smoke`；无 native FAIL；报告 `check=`／`main=`／`sync=`／`c=`／`skip=`；双端 L2 |
| db-kv-arrow soft→硬绿 | ✅ | 新 archive DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`kv_tick_smoke`／`arrow_column_smoke`／cookbook `db_kv_arrow` exit0 硬失败；C smoke 观测；无 native FAIL；报告 `check=`／`kv=`／`arrow=`／`cb=`／`c=`／`skip=`；双端 L2 |
| STD-004 async-api soft→硬绿 | ✅ | DOC→`## 10. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`i06_async_switch`／cookbook `async_mod_import`／`async_drain_idle` exit0 硬失败；coop／1m 观测（`coop_pingpong` UNDEF）；无 native FAIL；报告 `check=`／`switch=`／`imp=`／`drain=`／`coop=`／`skip=`；双端 L2 |
| STD-137 time-format-timezone soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`format_timezone.x` exit0 硬失败；C smoke 观测；无 native FAIL；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-133 time-bench-timer soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`bench_timer.x` exit0 硬失败；TSV 锚→产品短名 `start`／`reset`／`elapsed_*`／`lap_ns`；无 native FAIL；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-160 string-unicode soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`unicode_bridge.x` exit0 硬失败；锚→`string_view_case_fold`／`string_view_is_valid_utf8`（去化石 `unicode_case_fold_buf_c`）；无 native FAIL；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-111 sync-lock-diag soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`lock_diag.x` exit0 硬失败；去化石 `## 4. 验证与门禁`；无 native FAIL；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-145 test-runner soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`runner_smoke.x` exit0＋报告行硬失败；根修 `TST_LIT_SUMMARY`／case-line `mid`／bench `pfx` 缺 NUL；无 native FAIL；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-139 sqlite-stub soft→硬绿 | ✅ | DOC／TSV 锚→产品 `is_available`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；smoke soft-scope `is_available`＋stub `backend_name` exit0 硬失败；C stub 观测；STRUCT_LIT B1；stub open／last_error 产品残（非软）；报告 `check=`／`run=`／`stub_c=`／`skip=`；双端 L2 |
| STD-049 aes-gcm soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`main.x` exit0 硬失败；nist2 观测（产品 RUN≠0）；无 native FAIL；报告 `check=`／`main=`／`nist2=`／`skip=`；双端 L2 |
| STD-123 fs-dirmeta soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`dirmeta_roundtrip.x` exit0 硬失败；`DIRENT_D_NAME_OFF` LINUX=19／MACOS=21；拒陈旧 `fs.o`；C smoke 观测；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STD-134 url-ipv6-host soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`ipv6_host.x` exit0 硬失败；`AF_INET6` LINUX=10／MACOS=30／WINDOWS=23（url＋net ipv6／dns）；C smoke 观测；报告 `check=`／`run=`／`skip=`；双端 L2 |
| BOOT-029 std-sys soft→硬绿 | ✅ | DOC→`## 3. Gate`＋补 `## 8` FreeBSD；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`write_stdout` exit0 硬失败（Linux freestanding／Darwin hosted）；thin `macos_write_*` 观测（labi needle 缺 mod 层）；报告 `check=`／`run=`／`skip=`；双端 L2 |
| EXC-004 error-chain soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`error_chain_smoke.x` exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| EXC-003 error-code-layer soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`error_code_layer.x` exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| EXC-006 error-recovery soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；recovery suite 30 case exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| EXC-002 panic/abort soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；矩阵 4×run＋3×hook 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| STBL-004 import-std-layout soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；resolve＋`check_imports.x` exit0 硬失败；报告 `resolve=`／`check=`／`run=`／`skip=`；双端 L2 |
| EXC-005 cli-lsp soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；2× golden compile phrase+kind+line:col 硬失败；报告 `check=`／`compile=`／`skip=`；双端 L2 |
| BOOT-015 semantic-smoke soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；vec／map／heap link+run 硬失败；报告 `check=`／`link=`／`skip=`；双端 L2 |
| BOOT-019 stage2-dogfood soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；六条 parser／typeck link+run 硬失败；报告 `check=`／`link=`／`skip=`；双端 L2 |
| BOOT-014 std-link-contract soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；json always 烟测硬失败；on_demand 观测；报告 `always=`／`on_demand=`／`smoke=`／`skip=`；双端 L2 |
| BOOT-010 force-stub soft→硬绿 | ✅ | DOC→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；matrix `reg_src` link+run 硬失败（4／4）；`check_only` 观测；报告 `link=`／`skip=`；双端 L2 |
| DOD-CL-S1／S2 soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check／warn 观测；`cl_align64` exit64／`cl_arena64` exit0 硬失败；报告 `check=`／`warn=`／`run=`／`skip=`；双端 L2 |
| f03-io soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；inventory＋`run-io` 硬失败；报告 `inventory=`／`run=`／`skip=`；双端 L2 |
| f03-heap-ops soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；inventory＋`run-heap` 硬失败；卸 mem-safe／`check` 子闸；报告 `inventory=`／`run=`／`skip=`；双端 L2 |
| f03-heap-libc soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；inventory＋`run-heap`＋STD-017 heap-trace 硬失败；报告 `inventory=`／`run=`／`trace=`／`skip=`；双端 L2 |
| f03-fs soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；inventory＋`run-fs`＋STD-123 dirmeta＋STD-003 xplat 硬失败；dirmeta 只禁 `fs.c`（勿禁正式 `fs.o`）；报告 `inventory=`／`run=`／`dirmeta=`／`xplat=`／`skip=`；双端 L2 |
| f03-core soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；四子闸（heap-ops／heap-libc／fs／io）＋inventory 硬失败；退役 soft CORE／PRODUCT_FAIL；报告 `heap_ops=`／`heap_libc=`／`fs=`／`io=`／`inventory=`／`skip=`；双端 L2 |
| f07 soft→硬绿 | ✅ | DOC v1／v2→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋forbidden＋f06＋f03-core 硬失败；退役 soft `XLANG_F07_NO_CC_MIGRATED_FAIL`；报告 `static=`／`forbidden=`／`f06=`／`f03_core=`／`skip=`；双端 L2 |
| f06 soft→硬绿 | ✅ | DOC v1／v2→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋link_abi＋bootstrap＋stage2＋contract 硬失败；退役 soft `XLANG_F06_RUNTIME_CLEANUP_FAIL`；报告 `static=`／`link_abi=`／`bootstrap=`／`stage2=`／`contract=`／`skip=`；双端 L2 |
| f02 soft→硬绿 | ✅ | DOC v1／v2→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；mmap／win32 static＋inventory＋B-17／B-18 硬失败；Linux mmap 烟测观测（`std_sys_mmap_*` UNDEF）；退役 soft F02／F02_WIN32／LINUX_MMAP_FILE FAIL；B-17 针→`export function exit(`；报告 `static=`／`inventory=`／`linux=`／`b17=`／`b18=`／`skip=`；双端 L2 |
| f04-compress soft→硬绿 | ✅ | DOC v4／v5／v7→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；gzip／zlib／zstd static＋inventory＋STD-007 硬失败；stream／bz_stream 观测（产品红）；退役 soft F04_COMPRESS_{GZIP,ZLIB,ZSTD}_FAIL；报告 `static=`／`inventory=`／`compress=`／`stream=`／`bz_stream=`／`skip=`；双端 L2；brotli ld 仍跳 |
| f05 soft→硬绿 | ✅ | DOC v1～v4→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；arrow／kv／sqlite／closure static＋inventory＋kv-arrow／sqlite manifest 硬失败；host-c nm/cc 退役；stub open／last_error 观测；退役 soft F05_DB_*_FAIL；报告 `arrow=`／`kv=`／`sqlite=`／`kv_arrow=`／`sqlite_m=`／`inventory=`／`skip=`；双端 L2 |
| f04-crypto soft→硬绿 | ✅ | DOC v16～v19／v21→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋inventory＋STD-006 manifest 硬失败；host-c smoke 观测；活权威＝xbuild／mk／compile_std；v18→`chacha20_aead.x`；v19 不开 ed25519 check 子闸；退役 soft F04_CRYPTO_*_FAIL；报告 `v16=`／`v17=`／`v18=`／`v19=`／`crypto=`／`inventory=`／`smoke=`／`skip=`；双端 L2 |
| e-soft／c0x／f-phase soft→硬绿 | ✅ | e03-lexer DOC→`## Gate`＋mk LINK_O＋`.c` absent；e-soft／c0x／e0x／f-phase 硬 die；退役 soft `*_FAIL`；报告 `manifest=`／`e01=`／`e02=`／`e03_lexer=`／`c06=`／`c09=`／`c03=`／`c04=`／`skip=`；双端 L2 |
| f08／f10／f11／f12／inventory soft→硬绿 | ✅ | DOC→`## Gate`；硬 die；inventory 基线→8＋低于基线亦硬失败；d06 双语活针；f11 g-ffi5 默认 SKIP_LANG_UNSAFE；f-phase F-09 MANIFEST_ONLY＋9／9；退役 soft F08／F10／F11／F12／D05／D06／NHC／inventory FAIL；报告 `doc=`／`core_zero=`／`inventory=`／`wiring=`／`d04=`／`d05=`／`e_soft=`／`f09=`／`gffi5=`／`d06=`／`ok=`／`skip=`；双端 L2 |
| f04-net soft→硬绿 | ✅ | DOC v1～v15→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋inventory 硬失败；TLS／WS／check 观测；活权威＝xbuild／mk／ensure／archaeology／labi；v11→`addr.x`；v14 去 `_real`；退役 soft F04_NET_*_FAIL；报告 `v14=`／`dns=`／`tcp_pool=`／`tls_stub=`／`ws=`／`static=`／`inventory=`／`skip=`；双端 L2 |
| f-de-c 语法孤儿＋string／base64／random／time／process／encoding soft→硬绿 | ✅ | 修 orphan Makefile `die/fi`；DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；encoding-extra／hex 观测跳；de-c-batch 硬 die＋`bash -n`；退役 soft F_*_V1_FAIL／DE_C_BATCH_FAIL；报告 `static=`／`ensure=`／`stream=`／`rng=`／`time=`／`xplat=`／`hex=`／`extra=`／`ok=`／`skip=`；双端 L2 |
| f-path／uuid／sort／math soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；path／sort 硬委托 STD 子闸；uuid manifest 硬＋全量 smoke 观测；math special／fenv 观测；math TSV 补 doc／gate；退役 soft F_{PATH,UUID,SORT,MATH}_V1_FAIL；报告 `static=`／`ensure=`／`extreme=`／`win=`／`stable=`／`key=`／`manifest=`／`smoke=`／`special=`／`fenv=`／`skip=`；双端 L2 |
| f-cli／env／url／hash soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；cli／env／url 硬委托 STD 子闸；hash hasher／xxhash／default 观测；退役 soft F_{CLI,ENV,URL,HASH}_V1_FAIL；报告 `static=`／`ensure=`／`cli=`／`iter=`／`plat=`／`url=`／`ipv6=`／`hasher=`／`xxhash=`／`default=`／`skip=`；双端 L2 |
| f-log／queue／tar／sync soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；log／queue／tar／sync 硬委托 STD 子闸；含 sync-lock-diag-v2；退役 soft F_{LOG,QUEUE,TAR,SYNC}_V1_FAIL／SYNC_LOCK_DIAG_V2_FAIL；报告 `static=`／`ensure=`／`multi=`／`rotate=`／`queue=`／`ustar=`／`ext=`／`diag=`／`rwlock=`／`v2=`／`skip=`；双端 L2 |
| f-thread／async／atomic／cache soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure＋glue 硬失败；thread／async-api／atomic-ordering／cache 硬委托；async future／iocps／ctx／lang＋atomic widen 观测；退役 soft F_{THREAD,ASYNC,ATOMIC,CACHE}_V1_FAIL；报告 `static=`／`ensure=`／`glue=`／`pool=`／`api=`／`future=`／`iocps=`／`ctx=`／`lang=`／`ordering=`／`widen=`／`cache=`／`skip=`；双端 L2 |
| f-channel／config／context／csv soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure＋glue 硬失败；channel-select／config／yaml／context／csv-row 硬委托；channel-unbounded／csv-stream 观测；退役 soft F_{CHANNEL,CONFIG,CONTEXT,CSV}_V1_FAIL；报告 `static=`／`ensure=`／`glue=`／`select=`／`unbounded=`／`cfg=`／`yaml=`／`ctx=`／`row=`／`stream=`／`skip=`；双端 L2 |
| f-datetime／dynlib／elf／ffi soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；datetime／iana／dynlib-windows／last-error／ffi-cstring 硬委托；elf-parse／ffi-struct 观测；退役 soft F_{DATETIME,DYNLIB,ELF,FFI}_V1_FAIL；报告 `static=`／`ensure=`／`dt=`／`iana=`／`win=`／`err=`／`parse=`／`cstr=`／`struct=`／`skip=`；双端 L2 |
| f-http／json／regex／runtime soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure＋glue 硬失败；http／chunked／methods／https＋json／oa／serialize＋panic-hook 硬委托；http pool／reqresp／h2／context＋json typed＋regex 观测；退役 soft F_{HTTP,JSON,REGEX,RUNTIME}_V1_FAIL；报告 `static=`／`ensure=`／`glue=`／`http=`／`chunked=`／`methods=`／`https=`／`pool=`／`reqresp=`／`h2=`／`ctx=`／`json=`／`oa=`／`ser=`／`typed=`／`regex=`／`panic=`／`skip=`；双端 L2 |
| f-schema／security／simd／socketio soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；security 硬委托 STD-079；simd 硬委托 autovec／prod／intrinsic／shuffle；schema／socketio STD 观测；退役 soft F_{SCHEMA,SECURITY,SIMD,SOCKETIO}_V1_FAIL；报告 `static=`／`ensure=`／`schema=`／`sec=`／`autovec=`／`prod=`／`intr=`／`shuffle=`／`sio=`／`skip=`；双端 L2 |
| f-task／test／trace／unicode／backtrace soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；test 硬委托 STD-145；backtrace 硬委托 STD-052；task／trace／hooks／unicode nfc／gc／xplat 观测；退役 soft F_{TASK,TEST,TRACE,UNICODE,BACKTRACE}_V1_FAIL；报告 `static=`／`ensure=`／`task=`／`runner=`／`trace=`／`hooks=`／`nfc=`／`gc=`／`sym=`／`xplat=`／`skip=`；双端 L2 |
| f-crypto v1 soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；硬委托 F-04 closure＋STD-049 aes-gcm＋STD-050 sha512-hmac；chacha／ed25519 观测；退役 soft `XLANG_F_CRYPTO_V1_FAIL`；报告 `static=`／`ensure=`／`f04=`／`aes=`／`sha512=`／`chacha=`／`ed25519=`／`skip=`；双端 L2；**f-* v1 soft FAIL 池空** |
| f-cache／queue／tar／config v2 soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；硬委托 STD-087／048／038／152／086／119；queue 针→runtime_queue_contention；退役 soft `XLANG_F_{CACHE,QUEUE,TAR,CONFIG}_V2_FAIL`；报告 `static=`／`ensure=`／`cache=`／`queue=`／`ustar=`／`ext=`／`cfg=`／`yaml=`／`skip=`；双端 L2；**余 f-v2 soft FAIL＝16** |
| f-context／datetime／url／dynlib v2 soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；硬委托 STD-071／074／135／136／076／134／027／096；退役 soft `XLANG_F_{CONTEXT,DATETIME,URL,DYNLIB}_V2_FAIL`；报告 `static=`／`ensure=`／`ctx=`／`dt=`／`tz=`／`iana=`／`url=`／`ipv6=`／`win=`／`err=`／`skip=`；双端 L2；**余 f-v2 soft FAIL＝12** |
| f-elf／hash／json／regex v2 soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；json 硬委托 STD-008／oa／serialize；typed／elf-parse／deep／hasher／xxhash／default／regex／atomic 观测；退役 soft `XLANG_F_{ELF,HASH,JSON,REGEX}_V2_FAIL`；报告 `static=`／`ensure=`／`parse=`／`deep=`／`hasher=`／`xxhash=`／`default=`／`json=`／`oa=`／`ser=`／`typed=`／`regex=`／`atomic=`／`skip=`；双端 L2；**余 f-v2 soft FAIL＝8** |
| f-schema／socketio／task／unicode v2 soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；schema／sio／task／nfc／gc 观测；unicode static 对齐真短名 export（化石 `_c` 针假绿已揭）；退役 soft `XLANG_F_{SCHEMA,SOCKETIO,TASK,UNICODE}_V2_FAIL`；报告 `static=`／`ensure=`／`schema=`／`sio=`／`task=`／`nfc=`／`gc=`／`skip=`；双端 L2；**余 f-v2 soft FAIL＝4** |
| f-async-future／backtrace／test／trace v2 soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；static＋ensure 硬失败；test 硬委托 STD-145；backtrace 硬委托 STD-052；backtrace static 对齐 F-ZC runtime seed（化石 `.x` 针假绿已揭）；future／trace／hooks／xplat 观测；退役 soft `XLANG_F_{ASYNC_FUTURE,BACKTRACE,TEST,TRACE}_V2_FAIL`；报告 `static=`／`ensure=`／`future=`／`sym=`／`xplat=`／`runner=`／`trace=`／`hooks=`／`skip=`；双端 L2；**f-v2 soft FAIL 池空** |
| nolibc family soft→硬绿 | ✅ | DOC→`## Gate`；硬 die；prefer asm；n07-v2 拒 Makefile＋0-make；v3 smoke shared ensure＋验叶；TSV→xlang-build／build_xlang_asm；退役 soft `XLANG_NOLIBC_*_FAIL`；fs live 观测兜底；双端 L2；Ubuntu socket／heap／fs／v3／聚合 live |
| f09 product soft WARN→硬绿 | ✅ | 硬委托 crypto／net／db／path／uuid／sort／g02f／e-soft；退役 soft `XLANG_F09_PRODUCT_FAIL`；停再导出 child `*_FAIL`；DOC `## Gate`；报告 `audit=`／`inventory=`／`crypto=`／`net=`／`db=`／`path=`／`g02f=`／`uuid=`／`sort=`／`e_soft=`／`skip=`；f92／f11 仍 MANIFEST_ONLY；双端 L2；**f09 soft FAIL 池空** |
| e03-v3 coldstart soft→硬绿 | ✅ | DOC→archive＋`## Gate`；拒顶层 DOC／Makefile；活权威 mk／G-02a／G-06；硬委托 C-06；退役 soft `XLANG_E03_V3_FAIL`；报告 `doc=`／`g06=`／`seed=`／`mk=`／`c06=`／`skip=`；双端 L2；**e03-v3 soft FAIL 池空** |
| f04 brotli soft→硬绿 | ✅ | DOC→archive＋`## Gate`；拒顶层 DOC／Makefile；活权威 lib.x／mod.x＋TSV；硬委托 STD-125／compress／F-01；退役 soft `XLANG_F04_COMPRESS_BROTLI_FAIL`；报告 `doc=`／`lib=`／`mod=`／`absent_c=`／`manifest=`／`std125=`／`compress=`／`inv=`／`skip=`；双端 L2；**f04-brotli soft FAIL 池空**；产品 brotli ld 仍 tip 跳 |
| g-ffi5 soft→硬绿 | ✅ | DOC→archive＋`## Gate`；拒顶层 DOC／Makefile；活权威 allowlist／§8 baseline＋硬委托 wrap；退役 soft `XLANG_G_FFI5_FAIL`；release-ci 默认 SKIP lang-unsafe（check 暂停）；f11 RUNTIME→`RUN_LANG_UNSAFE`；报告 `doc=`／`allow=`／`baseline=`／`bare=`／`freeze=`／`wrap=`／`skip=`；双端 L2；**g-ffi5 soft FAIL 池空**；lang-unsafe／check 后置 |
| platform B-19／B-21 soft→硬绿 | ✅ | DOC→archive＋`## Gate`；prefer asm＋`XLANG_LINK_XLANG`；facade 活面 write／read／mmap／exit／close；B-19 write_stdout 硬绿（Linux freestanding／Darwin hosted）；B-21 host-arch FreeBSD triple 硬绿、foreign ISA 观测；退役 soft `XLANG_SYS_PLATFORM_WRITE_FAIL`／`XLANG_FREEBSD_PLATFORM_FAIL`；报告 `doc=`／`facade=`／`run=`／`manifest=`／`triple=`／`foreign=`／`host_run=`／`skip=`；双端 L2；**platform soft FAIL 池空** |
| parser FAIL:-0 soft→硬绿 | ✅ | phase／boot-024／eng DOC→`## Gate`；九闸硬 die＋DOC 先于 Darwin；权威 `cc_inc_tu`＋stdio／stdlib；experimental XP008／T001＝obs；mega-sweep 绝对体积 drift＝obs、unexpected emit 硬；退役 soft `XLANG_PARSER_*_FAIL`；报告 `seed=`／`sym=`／`text=`／`baseline=`／`minimal=`／`stub=`／`obs=`／`drift=`／`skip=`；双端 L2；**parser soft FAIL 池空**；禁 mega promote |
| second-pass soft→硬绿 | ✅ | phase／eng DOC→`## Gate$`；退役 soft `XLANG_PARSER_SECOND_PASS_FAIL`；硬 die＝compile／empty／unexpected-U／`__text`／combined；stretch／baseline under＝obs；nm 白名单族前缀（`ast_*`／`lexer_*`／`std_fs_*`／`memcpy`…）；WPO_DCE `MIN_TEXT`＝2048（combined 仍≥125KiB）；报告 `text=`／`combined=`／`nm=`／`obs=`／`skip=`；双端 L2；Ubuntu light／heavy／wpo＝0；**second-pass soft FAIL 池空**；禁 mega promote |
| B-01／B-02／B-03 cfg+repr soft→硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft `XLANG_CFG_*_FAIL`／`XLANG_REPR_C_ATTR_SKIP_FAIL`；硬 die 缺编译器／源；B-02 同 arch 跨 OS 硬、跨 arch host-ld＝obs；报告 `run=`／`os=`／`obs=`／`skip=`；bstrict-ci 去 FAIL=1；双端 L2；**B-01／B-02／B-03 soft FAIL 池空** |
| sys/mmap/win32 FAIL:-0 soft→硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft `XLANG_{SYS_READ,MACOS_MMAP*,LINUX_SYSCALL/OPEN*/MMAP_INVOKE,WIN32_*}_FAIL`；硬 die 缺编译器／源；Linux freestanding syscall／open／openat／mmap-invoke／sys-read 硬绿；Darwin macos-mmap 硬绿；sys-read／macos-mmap-file Darwin `std_sys_read_file_into` UNDEF＝obs；win32 非 Windows N/A；报告 `run=`／`obs=`／`skip=`；bstrict-ci／b04／windows 去 FAIL=1；双端 L2；**sys-mmap-win32 soft FAIL 池空**；linux mmap **file**／Darwin read_file_into 仍产品 obs |
| simd-dot／simd-shuffle／dod-soa FAIL soft→硬绿 | ✅ | prefer asm；退役 soft `XLANG_{SIMD_DOT,SIMD_SS,DOD_SOA}_FAIL:-0` 静默 OK＋soft SKIP→OK；under-ratio／nan／f32 CG／L1-over＝obs（FAIL=1 仍硬）；Darwin arm64 SSE C 基线 N/A＝skip；Mach-O `_main`；bench→`r03_dod_*`；cache-miss DOC→archive `## Gate`；sysctl stdout 不污染 L1 pct；报告 `run=`／`obs=`／`skip=`；双端 L2；**simd-dot＋simd-shuffle＋dod-soa soft FAIL 池空**；simd-dot tip under-ratio＝obs；Darwin f32 SoA CG002＝obs |
| syscall-batch／regex-match／string-arena／zig-strategy FAIL soft→硬绿 | ✅ | prefer asm；退役 soft `XLANG_{SYSCALL_BATCH,REGEX_PERF,ZIG_STRATEGY,STRING_ARENA}_FAIL:-0` 静默 OK＋soft SKIP→OK／soft auto-make／偏 xlang-c；over-cap／under-ratio／behind／strace exit≠expect／compile-fail＝obs（FAIL=1 仍硬）；bench→`i01_`／`i05_`／`i07_`／`r08_`／`r01_`／`m03_`／`r10_`／`a01_`／`i03_`；DOC→archive `## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**syscall-batch＋regex-match＋string-arena＋zig-strategy soft FAIL 池空**；regex tip under-ratio＝obs；syscall-batch tip strace exit≠expect＝obs；zig-strategy tip behind／compile＝obs；zc3／zc4／zc5 host-c 后置 |
| flamegraph／weekly／p1（+sqlite／phase3）FAIL soft→硬绿 | ✅ | prefer asm；退役 soft SKIP→OK／soft auto-make／prefer-c／顶层 DOC 假锚／grep-SKIP 吞子硬红；flamegraph smoke→`loop_i32_compile`＋fossil `r01_`／archive xref；P1 `HARD=0` 默认（pre-push `XLANG_PERF_P1_HARD=1`）；over-cap／partial Top-N／check residual＝obs；weekly 入口显式坏 XLANG 硬 die；报告 `run=`／`obs=`／`skip=`；io-zig／net-zig 已硬绿确认；双端 L2；**io-zig＋net-zig＋flamegraph＋weekly＋p1 soft FAIL 池空**；sqlite tip check residual＝obs；flamegraph tip no-perf skip＝obs；zc3／zc4／zc5 host-c 后置 |
| comp-riscv64／win-backend／size-attrib soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c；显式坏 XLANG／缺 native 硬 die；riscv64 capable 须非空 `.text/main/ret`；win capable 须 COFF emit；capability／qemu N/A＝skip；空产物硬 die；DOC→archive `## Gate`；报告 `run=`／`skip=`；双端 L2；**comp-riscv64＋win-backend＋size-attrib soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置） |
| comp-isel／regalloc／incr soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c；显式坏 XLANG／缺 native 硬 die；DOC→archive `## Gate`；incr check／ratio over-cap／phase-timing＝obs（`INCR_COMPILE_FAIL=1` 仍硬）；化石 `bench/loop_i32.x`→`examples/hello.x`；非 arm64 block_var disasm＝skip；报告 `run=`／`obs=`／`skip=`；双端 L2；**comp-isel＋regalloc＋incr soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置） |
| al06／wpo-full／s4／stretch／strict-link／stage2 soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK；显式坏 XLANG／缺 native 硬 die；al06 Darwin CHK002＝obs／Ubuntu check 硬绿；stretch tip＜3%＝obs（`STRETCH_FAIL=1` 仍硬）；full-chain tip chain／link／glue＝obs（`FULL_CHAIN_HARD=1` 仍硬）；strict-link Ubuntu 硬绿／Darwin FAIL=0 obs；stage2 退役假 Darwin N/A（默认 skip＋`FORCE=1`）；报告 `run=`／`obs=`／`skip=`；双端 L2；**al06＋wpo-full＋s4＋stretch＋strict-link＋stage2 soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置） |
| bootstrap-c6／typeck-generic／sys-mod-cfg／obs soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make；显式坏 XLANG／缺 native 硬 die；DOC→archive `## Gate`；obs smoke 链 tip `runtime_link_abi_user_env.o`／`runtime_process_argv.o`；tip span 0:0／structured `levelinfo`＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**bootstrap-c6＋typeck-generic＋sys-mod-cfg＋obs soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置）；al06／wpo-full／stage2 邻域另议 |
| dod-s2／dod-s3／abi-f32-xmm soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／check 硬红（CHK002）／Darwin 静默 OK；显式坏 XLANG／缺 native 硬 die；Darwin xmm／dod-s3 N/A＝skip；soa_cross exit≠10／legacy cvtsd2ss＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**dod-s2＋dod-s3＋abi-f32-xmm soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置） |
| simd-s1‥s4＋dod-s1 soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／显式坏 XLANG 回落；s4 退役 force `-backend c`（BLD001）；Darwin s3 N/A／dod-s1 f32 N/A＝skip；HW miss 非 STRICT＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**simd-s1‥s4＋dod-s1 soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置） |
| codegen-regression soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make；显式坏 XLANG／缺 native 硬 die；DOC→archive `## Gate`；化石 bench→`r01_`／`m03_`／`r10_`／`a01_`；hook 产品残／Darwin SIGKILL＝obs；报告 `run=`／`hook=`／`obs=`／`skip=`；双端 L2；**codegen-regression soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置） |
| lang-option-generic／lang-result-generic／lang-const-eval／lang-abi-stability soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c；显式坏 XLANG／缺 native 硬 die；DOC→archive `## Gate`；option／result check／f32 xmm residual＝obs；报告 `run=`／`obs=`／`layout=`／`f32=`／`skip=`；双端 L2；**lang-option-generic＋lang-result-generic＋lang-const-eval＋lang-abi-stability soft FAIL 池空**；option／result check＝obs（Darwin）；abi f32 residual＝obs；zc3／zc4／zc5 host-c 后置；lang-unsafe（check 后置） |
| lang-generic／lang-trait／lang-lifetime／async-language／async-future soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／force-xlang-c multi-file；显式坏 XLANG／缺 native 硬 die；DOC→archive `## Gate`；lifetime check／async run·mod·c·.x·emit-marker＝obs；报告 `run=`／`multi=`／`neg=`／`obs=`／`c=`／`x=`／`emit=`／`skip=`；双端 L2；**lang-generic＋lang-trait＋lang-lifetime＋async-language＋async-future soft FAIL 池空**；async-language run／mod＝obs；async-future c／.x／emit-marker＝obs；lifetime check smoke＝obs；zc3／zc4／zc5 host-c 后置 |
| lang-feature／lang-import／std-async-1m soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／force-xlang-c LINK／silent asm→c；显式坏 XLANG／缺 native 硬 die；DOC→archive `## Gate`；1m 矩阵→`i06_*`；coop_pingpong UNDEF＝obs；报告 `run=`／`hooks=`／`edition=`／`obs=`／`skip=`；双端 L2；**lang-feature＋lang-import＋std-async-1m soft FAIL 池空**；async-1m coop UNDEF＝obs；zc3／zc4／zc5 host-c 后置 |
| tool-*/typeck-hotpath soft SKIP→OK →硬绿 | ✅ | prefer asm；退役 soft SKIP→OK／prefer-c；显式坏 XLANG／缺 native 硬 die；DOC→archive `## Gate`；LSP 无 `--lsp`＝skip=1；region／linear／wpo-optin tip miss＝obs；报告 `run=`／`hooks=`／`obs=`／`skip=`；双端 L2；**tool-*＋typeck-hotpath soft FAIL 池空**；LSP tip 无 `--lsp` skip＝obs；typeck-hotpath region／linear／wpo-optin＝obs；zc3／zc4／zc5 host-c 后置 |
| alloc-hotspot／net-zc FAIL soft→硬绿 | ✅ | DOC→archive＋`## Gate`；prefer asm；拒 soft auto-make／显式坏 XLANG 回落；退役 soft `XLANG_{ALLOC_HOTSPOT,NET_ZC}_FAIL:-0` 静默 OK＋soft SKIP→OK；超 cap／zc≥ref／compile-fail／`with_arena_vec` exit≠0＝obs（FAIL=1 仍硬）；Darwin／无 perf＝skip；bench→`r08_`／`i03_`／`i04_`／`tests/mem/`；`grep -c` 无匹配权威计数修；报告 `run=`／`obs=`／`skip=`；双端 L2；**alloc-hotspot＋net-zc soft FAIL 池空**；MEM-C1 with_arena exit＝obs；zc3／zc4／zc5 host-c 后置 |
| compile-dogfood／wpo-s2／p0-matrix FAIL_ON soft→硬绿 | ✅ | DOC→archive＋`## Gate`；prefer asm；拒 soft auto-make／显式坏 XLANG 回落；退役 soft `FAIL_ON_{COMPILE,WPO_S2,C_O2}_*:-0` 静默 OK＋soft SKIP→OK＋p0 FAIL=1 stub；超 cap／check_fail／vs_c>1／compile-fail／vec fold still-calls＝obs（FAIL=1 仍硬）；Darwin wpo N/A＝skip；bench→`a04_wpo_*`；报告 `run=`／`obs=`／`skip=`；双端 L2；**compile-dogfood＋wpo-s2＋p0-matrix soft FAIL 池空**；wpo-s2 vec fold still-calls＝obs |
| http／async／iocp／baseline FAIL_ON soft→硬绿 | ✅ | DOC→archive＋`## Gate`；prefer asm；拒 soft auto-make／显式坏 XLANG 回落；退役 soft `FAIL_ON_{HTTP,ASYNC,IOCP,ZIG,C_O3}_*:-0` 静默 OK＋soft SKIP→OK；超 cap／慢于 Zig|C-O3／http client `std_io_write_stderr_*` UNDEF＝obs（FAIL=1 仍硬）；iocp 非 Windows＝skip；bench→`i06_`／`r01_`／`m03_`／`r10_`／`a01_`；server 链产品 `runtime_http_glue.o`；报告 `run=`／`obs=`／`skip=`；双端 L2；**http＋async＋iocp＋baseline soft FAIL 池空**；http stderr UNDEF＝obs |
| net／io／coldstart FAIL_ON soft→硬绿 | ✅ | DOC→archive＋`## Gate`；prefer asm；拒 soft auto-make／显式坏 XLANG 回落；退役 soft `FAIL_ON_{NET,IO,COLDSTART}_*:-0` 静默 OK＋soft SKIP→OK；超 cap／Zig 慢／nan＝obs（FAIL=1 仍硬）；bench→`i0N_*`＋`zig-perf.tsv`；报告 `run=`／`obs=`／`skip=`；双端 L2；**net＋io＋coldstart soft FAIL 池空**；Darwin net_mixed typeck nan＝obs |
| xlang-asm-text + compiler-self soft→硬绿 | ✅ | 退役 soft `FAIL_ON_WPO_XLANG_ASM_TEXT`／`FAIL_ON_WPO_COMPILER_SELF_TEXT:-0` under-min FAIL→OK＋缺 `xlang_asm` soft SKIP→OK；under-min＝obs（FAIL=1 仍硬）；Darwin asm-text N/A＝skip；compiler-self graph 绑 `xlang-c check`＝obs（check 暂停，继续 asm proxy）；报告 `run=`／`obs=`／`skip=`；双端 L2；**xlang-asm-text+compiler-self soft FAIL 池空**；graph check-bound 仍产品／check obs |
| size + WPO DCE text soft→硬绿 | ✅ | 退役 soft `XLANG_SIZE_FAIL:-0` 静默 WARN＋缺 `xlang_asm` soft SKIP→OK；退役 soft `XLANG_PERF_FAIL_ON_WPO_DCE_TEXT:-0` under-min OK＋缺编译器／compile soft SKIP→OK；超 cap／under-min＝obs（FAIL=1 仍硬）；报告 `run=`／`obs=`／`skip=`；eng-quality 仍强制 size advisory；双端 L2；**size+WPO DCE text soft FAIL 池空**；Ubuntu tip stripped＞8MiB＝产品 obs |
| WPO reach soft→硬绿 | ✅ | 退役 soft `XLANG_WPO_*_REACH_FAIL`＋缺 `.o` soft SKIP→OK；父 o-gate 硬委托 reach（禁 force :-0）；pipeline soft size overage＝obs；报告 `run=`／`exports=`／`obs=`／`skip=`；双端 L2；**WPO reach soft FAIL 池空**；Darwin pipeline_wpo soft size 仍产品 obs |
| boot-017 FAIL_ON_REGRESSION soft→硬绿 | ✅ | 退役 soft `XLANG_BOOT017_FAIL_ON_REGRESSION:-0`；prefer asm；拒 soft auto-make；缺编译器 runner 硬 die／gate skip=1；check 失败／SLOW＝obs；基线补 `core.assert`／`std.debug`；报告 `run=`／`obs=`／`skip=`／`slow=`；双端 L2；**boot-017 soft FAIL 池空**；tip SLOW／check_fail 仍产品／check obs |
| s2／s3 FAIL_ON_EMIT_HEAVY／REGRESSION soft→硬绿 | ✅ | 退役 soft `FAIL_ON_EMIT_HEAVY`／`FAIL_ON_REGRESSION`；缺编译器硬 die；Darwin skip；tip live under／compile-fail＝obs；既有 build_asm 闸硬绿；pipeline stub＝obs；check 观测；ci／pre-push 去 FAIL=1；报告 `run=`／`obs=`／`skip=`；双端 L2；**FAIL_ON_EMIT_HEAVY／FAIL_ON_REGRESSION soft FAIL 池空**；tip live EMIT_HEAVY under／pipeline stub／ensure_by_kind_ord／s3 compile.o stub 仍产品 obs |
| s2／s3 parity FAIL:-0 soft→硬绿 | ✅ | 退役 soft `XLANG_S{2,3}_FAIL_ON_PARITY`；Linux x86_64 硬 die 缺 .o／under／unexpected；Darwin stub skip／link 符号硬＋compile.o size＝obs；nm 可选 `_`；mega→`typeck_*`；glue 白名单扩 tip；`ensure_by_kind_ord`＝obs；ci 去 FAIL=1；报告 `run=`／`obs=`／`skip=`；双端 L2；**s2／s3 parity soft FAIL 池空**；ensure_by_kind_ord／s3 compile.o stub 仍产品 obs |
| b31／noalias／with-arena-vec／typeck-bisect FAIL:-0 soft→硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft `XLANG_B31_FAIL`／`XLANG_NOALIAS_GATE_FAIL`／`XLANG_WITH_ARENA_VEC_GATE_FAIL`／`XLANG_TYPECK_PARSE_BISECT_FAIL`；B-31 Linux freestanding hello 硬绿／Darwin static+skip；DOC `## Gate`；MEM-A1 missing restrict／MEM-C1 vec run≠0／KEEP_C＝obs；A-11 bisect probe under 硬／Darwin N/A；bstrict 去 bisect `|| true`；双端 L2；**b31／noalias／with-arena-vec／typeck-bisect soft FAIL 池空**；MEM-A1 restrict／MEM-C1 vec 仍产品 obs |
| scope-alloc／alloc-inject／typeck-parse／wpo-glue FAIL:-0 soft→硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft `XLANG_{SCOPE_ALLOC,ALLOC_INJECT}_GATE_FAIL`／`XLANG_{TYPECK_PARSE_COUNT,WPO_STRICT_GLUE_TEXT}_FAIL`；硬 die 缺编译器／源／`pipeline_wpo.o`；fixture→`default_allocator.x`／`scope_allocator.x`；with_arena smoke 硬跑；emit／scope UNDEF／AL inject＝obs；typeck metric／wpo growth Ubuntu 硬绿／Darwin N/A；bstrict／a09／wpo-full 去 FAIL=1；双端 L2；**scope-alloc／alloc-inject／typeck-parse／wpo-glue soft FAIL 池空**；MEM-C1 codegen／`std_heap_scope_alloc`／AL inject 仍产品 obs |
| prefer-c／archaeology soft→硬绿（zero-c-track＋closure-e-extern） | ✅ | DOC→`## Gate`；zero-c 硬 die＋inventory 硬委托；closure prefer-asm 探针硬要求 NO_C_FRONTEND／BLD001 refuse；退役 soft `XLANG_F_{STD_ZERO_C,CLOSURE}_FAIL`；`-E-extern`＋cc 批退役；报告 `c=`／`h=`／`new=`／`gone=`／`inv=`／`strict=`／`refuse=`／`mods=`／`skip=`；双端 L2；**f soft FAIL 池空** |
| archaeology e-extern family soft→硬绿（c04／pipeline／lexer／parser／import） | ✅ | DOC `phase-c-c04-v1`→`## Gate`；G.7 单权威 `tests/lib/prefer-asm-e-extern-refuse.sh`；五闸＋closure prefer-asm 硬要求 BLD001／NO_C_FRONTEND refuse；退役 soft `XLANG_{PIPELINE,LEXER,PARSER,E_EXTERN_IMPORT}_*_FAIL`＋c04 SKIP-when-NO_C；`-E-extern`＋cc／check 批退役；报告 `refuse=`／`subs=`／`noperl=`／`skip=`；双端 L2；**e-extern／c04 soft FAIL 池空** |
| soft SKIP 邻域 soft→硬绿（e06／c07／c08／b20／d01／a12） | ✅ | DOC→archive＋`## Gate`；拒顶层 DOC／Makefile 复活；e06 活权威 `bootstrap_driver_bstrict.sh`＋`./xbuild`；c07 REF 硬＋CAND `-backend c` 观测；c08／b20／d01／a12 硬 die；退役 soft `XLANG_{E06,C07,C08,B20,D01,A12}_*_FAIL`；报告 `doc=`／`ref=`／`obs=`／`parity=`／`ok=`／`undef=`／`skip=`；双端 L2；**e06／c07／c08／b20／d01／a12 soft FAIL 池空** |
| Stage2 family d02／d03／d04 soft→硬绿 | ✅ | DOC→`## Gate$`；拒 Makefile；活权威 verify／bootstrap_verify／hash-gate；d03 有 bin 则 STRICT SHA256；d02／d04 Darwin static+skip；退役 soft `XLANG_D0{2,3,4}_FAIL`；报告 `doc=`／`static=`／`live=`／`hash=`／`matrix=`／`cases_ok=`／`skip=`；双端 L2；Ubuntu d04 10／10；**d02／d03／d04 soft FAIL 池空**；Stage2 SHA256 16B topology fork＝产品残（诚实红） |
| STD soft SKIP 邻域续（其它闸） | 🟡 | soft SKIP 邻域续扫（若仍有 soft die→exit0；**…／comp-isel＋regalloc＋incr／comp-riscv64＋win-backend＋size-attrib soft FAIL 池空**；余 soft：lang-unsafe（check 后置）／邻域再扫…；**zc3／zc4／zc5 仍绑 host-c（xlang-c）后置**；Stage2 SHA256 topology fork 16B 产品残；Ubuntu tip stripped＞8MiB size＝产品 obs；MEM-C1 with_arena emit／`std_heap_scope_alloc`／AL inject／vec run 产品 obs；MEM-A1 single-ptr `restrict` 产品 obs；s2 `pipeline_type_ensure_by_kind_ord`／s3 compile.o stub size／tip live EMIT_HEAVY under 产品 obs；boot-017 tip SLOW／check_fail＝obs；compiler-self graph check-bound＝obs；Darwin net_mixed typeck nan＝obs；http client `std_io_write_stderr_u8_ptr_usize` UNDEF＝obs；wpo-s2 vec fold still-calls＝obs；simd-dot tip under-ratio＝obs；Darwin f32 SoA CG002＝obs；async-1m coop UNDEF＝obs；async-language run／mod＝obs；async-future c／.x／emit-marker＝obs；lifetime check smoke＝obs；option／result check＝obs（Darwin）；abi f32 xmm residual＝obs（含 legacy cvtsd2ss）；dod-s3 soa_cross exit≠10＝obs；typeck-generic tip span 0:0＝obs；obs structured `levelinfo`（缺 `=`）＝obs；c07 CAND `-backend c` SEGV 观测；experimental XP008／T001 观测；WPO_DCE baseline TSV under＝obs；STD uuid／task／mem-safe／trace 等 asm UNDEF 跳；linux mmap **file** smoke UNDEF 观测残；Darwin `std_sys_read_file_into` UNDEF＝obs；compress-stream／unified-stream 观测残；sqlite stub open／last_error 观测残；aes-gcm host-c／nist2 观测残；queue-sync 观测残；async future／iocps／ctx／lang／atomic-widen 观测残；channel-unbounded／csv-stream／elf-parse／ffi-struct／http-pool／reqresp／h2／context／json-typed／regex／schema／socketio／task／trace／unicode／backtrace-xplat／chacha／ed25519 观测残；compress-brotli ld 红跳；test-executable／bench-fuzz 探针 ld UNDEF 跳；encoding-extra／regex／net-tls 仍跳；lang-unsafe（check 后置）；仍跳过产品红／UNDEF）；另残 asm ld `--export-dynamic`（非软）＋by-value `Set_i32`+MEMORY（非软）＋Stage2 SHA256 topology converge（非软） |
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 非软刀默认；优先级到才动；Darwin heat 仍依赖 hybrid thin（禁 mega） |
| LANG-009／010 Option／Result 泛型 STRUCT_LIT | ✅ | 解析 mangle＋具名 lit typeck；闸 run hard |
| CORE-016 多 mono／多 let 字段 load 宽 | ✅ | typeck mono 戳优先于泛型布局 T→8；thin inject |
| CORE-016 Option／Result 泛型↔族 unify | ✅ | named-inst mangle 等式＋let 族 canonicalize；闸 run hard |
| CORE-013 i16／u16 size／align formal | ✅ | labi g1 全表针＋闸 run hard |
| CORE-017 core.mem volatile／fence formal | ✅ | labi_od_core_mem×31＋闸 run hard |
| CORE-004 core.slice API formal | ✅ | labi g9×28＋闸 run hard |
| CORE-006 iterator protocol formal | ✅ | 闸 prefer asm＋smoke／cookbook run hard |
| CORE-007 core.str BytesView formal | ✅ | 闸 prefer asm＋smoke／cookbook run hard |
| CORE-002/003 Option／Result combinators | ✅ | 闸 prefer asm＋option102／result173 run hard |
| STD-131 core.str find／split | ✅ | 闸 prefer asm＋find_split exit0 run hard（无 Darwin soft SKIP） |
| CORE-012 core.debug assert extend | ✅ | 闸 prefer asm＋assert_extend exit0 run hard（无 Darwin soft SKIP） |
| CORE／lang runnable soft SKIP | ✅ | 余例已空（本类收口） |
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
