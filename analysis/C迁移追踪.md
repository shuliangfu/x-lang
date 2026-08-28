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
| STD-025 env_iter soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`env_iter.x`／cookbook `env_args_iter.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**env-iter soft auto-make FAIL 池空** |
| STD-017 heap_trace soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check＝obs；`trace_stats.x`（含 `XLANG_HEAP_TRACE=1`）／cookbook exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**heap-trace soft auto-make FAIL 池空** |
| STD-020 error_map soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`error_map_smoke.x`／cookbook `error_module_base.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**error-map soft auto-make FAIL 池空** |
| STD-158 error_semantics soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`error_semantics_smoke.x`／cookbook `error_semantic_class.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**error-semantics soft auto-make FAIL 池空** |
| STD-015 set-extend soft→硬绿 | ✅ | TSV 锚对齐产品 overload；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check＝obs；`extend.x`／cookbook exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**set-extend soft auto-make FAIL 池空** |
| STD-112 heap-allocator soft→硬绿 | ✅ | TSV 锚对齐产品 `with_alloc`／`push`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check＝obs；`allocator_vec.x`／cookbook exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**heap-allocator soft auto-make FAIL 池空** |
| STD-129 set-ops soft→硬绿 | ✅ | TSV 锚对齐产品 `union_into`／`intersect_into`／`difference_into`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check＝obs；`ops.x`／cookbook exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**set-ops soft auto-make FAIL 池空** |
| STD-156 context-cookbook soft→硬绿 | ✅ | expand DOC／TSV→archive；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；CTX-01 `context_cancel_deadline.x` exit0 硬失败；拒顶层 DOC 复活；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**context-cookbook soft auto-make FAIL 池空** |
| STD-071 context soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`cancel_smoke.x` exit0 硬失败；check／host-C archaeology＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**context soft auto-make FAIL 池空** |
| STD-155 bytes-arena soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft auto-make xlang-c／soft XLANG fallthrough／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check＝obs；`arena_external.x` exit0 硬失败；化石 `arena_init`→`arena64_init`；报告 `run=`／`obs=`／`skip=`；双端 L2；**bytes-arena soft auto-make FAIL 池空** |
| STD-150 sort-key-cmp soft→硬绿 | ✅ | TSV／archive／README 锚对齐产品 `stable_by_key`／`cmp_key_fn`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C＝obs；`key_stable.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**sort-key soft auto-make FAIL 池空** |
| STD-060 sort-stable-cmp soft→硬绿 | ✅ | TSV／archive 锚对齐产品 `stable`／`cmp`／`cmp_desc_fn`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C＝obs；`stable_i32.x`／`cmp_desc.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**sort-stable soft auto-make FAIL 池空** |
| STD-072 std-bytes soft→硬绿 | ✅ | DOC／TSV 锚对齐产品 `length`＋`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；双端 L2 |
| STD-074 std-datetime soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft auto-make xlang-c／soft XLANG fallthrough／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C＝obs；`roundtrip.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**datetime soft auto-make FAIL 池空** |
| STD-077 std-cli soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`roundtrip.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-011 error-unify soft→硬绿 | ✅ | EXC DOC→`analysis/archive/exc/`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check＝obs；`error_unify_smoke.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**error-unify soft auto-make FAIL 池空** |
| STD-109 base64-stream soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`stream.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**base64-stream soft auto-make FAIL 池空** |
| STD-019 fmt-multi soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`format_multi.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**fmt-multi soft auto-make FAIL 池空** |
| STD-096 dynlib-last-error soft→硬绿 | ✅ | 新 archive DOC／TSV→`## 4. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`last_error.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**dynlib-last-error soft auto-make FAIL 池空** |
| STD-140 path-extreme soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`extreme_clean.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**path-extreme soft auto-make FAIL 池空** |
| STD-055 ffi-cstring soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=`／`safe004=` 报告；显式坏 XLANG／缺 native 硬 die；`cstring_try_new.x` exit0＋SAFE-004 硬（并入 `run=`）；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**ffi-cstring soft auto-make FAIL 池空** |
| STD-053 log-multi-sink soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`level_filter.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**log-multi soft auto-make FAIL 池空** |
| STD-086 std-config soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`layer_smoke.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-119 config-yaml soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`yaml_smoke.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**config-yaml soft fallthrough FAIL 池空** |
| STD-087 std.cache soft→硬绿 | ✅ | formal_mod `mod\|1`＋fk0 k22＋time_os companion；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`lru_pool_smoke.x` exit0 硬失败；C smoke 仅观测；双端 L2 |
| STD-076 std.url soft→硬绿 | ✅ | formal_mod `mod\|1`＋fk0 k23×10；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft auto-make xlang-c／soft XLANG fallthrough／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C＝obs；`roundtrip.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**url soft auto-make FAIL 池空** |
| STD-079 std.security soft→硬绿 | ✅ | formal_mod `mod\|1`＋fk0 k24×16＋crypto／random／CRYPTO_PAIR companion；API 锚 `hkdf`／`err_ok`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C＝obs；`roundtrip.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**security soft auto-make FAIL 池空** |
| STD-080/081 std.option／result soft→硬绿 | ✅ | 烟测 `err.*`＋bool `false`；formal_mod `mod\|0`；plan +2；fk0 k25/k26×11；error companion；闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make xlang-c／soft XLANG fallthrough／`check=` 报告；显式坏 XLANG／缺 native 硬 die；check＝obs；`roundtrip.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**option-result soft auto-make FAIL 池空** |
| STD-035 json-serialize soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`object_array_roundtrip.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**json-serialize soft auto-make FAIL 池空** |
| STD-036 csv-row soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`row_roundtrip.x`＋`main.x` exit0 硬失败；双端 L2 |
| STD-135 datetime-timezone soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`timezone.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**datetime-timezone soft fallthrough FAIL 池空** |
| STD-098 channel-select soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft ensure_std_c_o／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；六路 `select_*.x` exit0 硬失败（run=6）；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**channel-select soft fallthrough FAIL 池空** |
| STD-032 http-methods soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft ensure_std_c_o／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`methods_status.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**http-methods soft fallthrough FAIL 池空** |
| STD-033 http-chunked soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft ensure／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`chunked_keepalive.x` exit0 硬失败；check／bench check＝obs；报告 `run=`／`obs=`／`skip=`；bench→`i08_*`；双端 L2；**http-chunked soft fallthrough FAIL 池空** |
| STD-034 http-https soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft ensure_std_c_o／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`https_smoke.x` exit0 硬失败；check／host-C stub／OpenSSL＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**http-https soft fallthrough FAIL 池空** |
| STD-050 crypto sha512-hmac soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft ensure_std_c_o／soft auto-make／`check=`／`sha512=`／`hmac=`／`mac512=` 报告；显式坏 XLANG／缺 native 硬 die；sha512＋hmac exit0 硬失败（并入 `run=`）；check／mac512＝obs（产品 UNDEF）；报告 `run=`／`obs=`／`skip=`；双端 L2；**crypto-sha512-hmac soft fallthrough FAIL 池空** |
| STD-038 tar-ustar soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`ustar_roundtrip.x`／`main.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；archive `## 5. Gate`；恢复 `MOD_X`／`TAR_X`；双端 L2；**tar-ustar 残 fallthrough FAIL 池空** |
| STD-045 sync-rwlock-condvar soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`／extra CLI `.o`／TSAN ensure；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`rwlock_condvar.x`／`main.x` exit0 硬失败；check／TSAN compile／run／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；archive `## 5. Gate`；双端 L2；**sync-rwlock-condvar 残 fallthrough FAIL 池空** |
| STD-029 net-dns soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft ensure／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`resolve_dns.x`／`main.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**net-dns soft fallthrough FAIL 池空** |
| STD-043 thread-pool soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`pool_roundtrip.x`／`main.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；archive `## 5. Gate`；双端 L2；**thread-pool 残 fallthrough FAIL 池空** |
| STD-091 io-context soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`／CLI extra `.o`；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`context_read_write.x` exit0 硬失败；check／glue archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；无 DOC／TSV（镜像 STD-092）；双端 L2；**io-context 残 fallthrough FAIL 池空** |
| STD-052 backtrace-symbolicate soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`／`ensure_runtime_backtrace_platform_o`／extra CLI `.o`／C gold auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`symbolicate_known.x` exit0 硬失败；check／C gold compile／run／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；archive `## 5. Gate`；双端 L2；**backtrace-symbolicate 残 fallthrough FAIL 池空** |
| STD-124 regex-atomic soft→硬绿 | ✅ | 二过：拒 soft prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／soft auto-make／硬 C smoke 重建；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`atomic_match.x` 能链则硬绿、tip missing `_main`＝obs；check／C smoke compile／run／host-C archaeology＝obs（现成 `.o` only）；archive `## 3. Gate`；父 STD-051 MANIFEST_ONLY 硬委托；报告 `run=`／`obs=`／`skip=`；双端 L2；**regex-atomic 残 prefer-c／ensure FAIL 池空** |
| STD-065 sqlite-exec-deep soft→硬绿 | ✅ | 二过：拒 soft prefer-c／soft SKIP→OK／soft `std_sqlite_build_o`／soft `ensure_std_c_o`／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`exec_tx_roundtrip.x` 能链则硬绿、tip SEGV＝obs；check／C smoke compile／run／host-C archaeology＝obs（现成 `.o` only）；archive `## 4. Gate`；父 STD-057 MANIFEST_ONLY 硬委托；报告 `run=`／`obs=`／`skip=`；双端 L2；**sqlite-exec-deep 残 prefer-c／ensure FAIL 池空** |
| STD-118 trace-hooks soft→硬绿 | ✅ | 二过：拒 soft prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／soft auto-make／C smoke auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`hooks_smoke.x` 能链则硬绿、tip `std_trace_*` UNDEF＝obs；check／C smoke compile／run／host-C archaeology＝obs（现成 `.o` only）；TSV／DOC API 锚对齐 `hook_begin`／`io_read`／`async_drain`；archive `## 3. Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**trace-hooks 残 prefer-c／ensure FAIL 池空** |
| STD-046 atomic-ordering soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`ordering_fence.x`／`main.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；archive `## 5. Gate`；双端 L2；**atomic-ordering 残 fallthrough FAIL 池空** |
| STD-130 random-rng soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=`／`rt=`／`main=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C＝obs；`rng_roundtrip.x`／`main.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`；双端 L2；**random-rng soft auto-make FAIL 池空** |
| json-object-array soft→硬绿 | ✅ | 历史 archive ID＝游标 STD-034（与 http-https STD-034 撞号，tracker 用本名）；DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft ensure_std_c_o／soft auto-make／`check=`／`oa=` 报告；显式坏 XLANG／缺 native 硬 die；`object_array_parse.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`（legacy `oa=` 并入 `run=`）；双端 L2；**json-object-array soft auto-make FAIL 池空** |
| STD-005 std-time soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=`／`main=`／`precision=` 报告；显式坏 XLANG／缺 native 硬 die；`main.x`／`precision_smoke.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**std-time soft auto-make FAIL 池空** |
| STD-028 runtime-panic-hook soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`panic_hook_align.x`／`runtime_ready.x` exit0 硬失败；check／EXC-002＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**runtime-panic soft fallthrough FAIL 池空** |
| STD-016 strview-zc4 soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`view_lifecycle`／`view_subview`／`arena_concat`／`stack_sso` exit0 硬失败；`run-zc4-gate` 观测；报告 `check=`／`life=`／`sub=`／`arena=`／`sso=`／`zc4=`／`skip=`；双端 L2 |
| STD-026 io-fallback soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`fallback_matrix.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**io-fallback soft fallthrough FAIL 池空** |
| STD-007 compress soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；拒 soft `std_compress_try_libs`／soft auto-make／XLANG fallthrough；显式坏 XLANG／缺 native 硬 die；gzip／zstd／legacy 产品 `-o` 成功＝run／UNDEF＝obs；check＝obs；报告 `run=`／`obs=`／`skip=`（退役 `check=`／`gzip=`／`zstd=`／`legacy=`）；双端 L2；**compress 残 try_libs／auto-make FAIL 池空** |
| STD-006 crypto soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；sha256／hmac／mem_eq／rand／main exit0 硬失败；mac 仅观测（产品 UNDEF）；报告 `check=`／`sha256=`／`hmac=`／`mem_eq=`／`rand=`／`main=`／`mac=`／`skip=`；双端 L2 |
| STD-002／001 net-api＋io-api soft→硬绿 | ✅ | DOC→`## 8/7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`run-net`／`run-io` exit0 硬失败；去化石 `addr_to_packed`∈main.x；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**net-api／io-api soft fallthrough FAIL 池空**（io-api 二过 tip `a53b08183`） |
| STD-132 env-platform-encoding soft→硬绿 | ✅ | DOC／TSV→`## 5. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`platform_encoding.x` exit0 硬失败；check／host-C archaeology＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**env-platform soft auto-make FAIL 池空** |
| STD-136 datetime-iana soft→硬绿 | ✅ | DOC／TSV→`## 4. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`iana_dst_smoke.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；禁顶层 DOC 复活；双端 L2；**datetime-iana soft fallthrough FAIL 池空** |
| STD-106 log-rotate-async soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`rotate_async.x` exit0 硬失败；check／host-C＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；禁顶层 DOC 复活；双端 L2；**log-rotate-async 残 fallthrough FAIL 池空** |
| STD-092 net-context soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft ensure_std_c_o／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`context_connect.x` exit0 硬失败；check／glue archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；镜像 STD-091（无 DOC／TSV）；双端 L2；**net-context soft fallthrough FAIL 池空** |
| STD-142 process-xplat soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`xplat_behavior`／`boundary` exit0 硬失败；check／win／pipe＝obs（XT001）；报告 `run=`／`obs=`／`skip=`；双端 L2；**process-xplat soft fallthrough FAIL 池空** |
| STD-027 dynlib-windows soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`open_sym_close`／`main`／`win_path` exit0 硬失败；check／host-C＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**dynlib-windows soft fallthrough FAIL 池空** |
| STD-SIMD-INTRINSIC soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`（拒 xlang-c）；显式坏 XLANG／缺 native asm 硬 die；`intrinsic_binop_dot.x` exit0 硬失败；check＝obs；删顶层双权威 DOC；报告 `run=`／`obs=`／`skip=`；双端 L2；**simd-intrinsic soft fallthrough FAIL 池空** |
| STD-047 simd-shuffle-select soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`（拒 xlang-c）；显式坏 XLANG／缺 native asm 硬 die；`shuffle_select_roundtrip.x` exit0 硬失败；s4 成功并入 `run=`／失败 x86 硬／非硬＝obs；check＝obs；删顶层双权威 DOC；报告 `run=`／`obs=`／`skip=`；双端 L2；**simd-shuffle soft fallthrough FAIL 池空** |
| STD-061 simd-prod soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`（拒 xlang-c）；显式坏 XLANG／缺 native asm 硬 die；`r04_simd_shuffle_select.x` exit0 硬失败；check／perf ratio＝obs；删顶层双权威 DOC；报告 `run=`／`obs=`／`skip=`；双端 L2；**simd-prod soft fallthrough FAIL 池空** |
| STD-153 simd-autovec soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／soft ensure；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`（拒 xlang-c）；显式坏 XLANG／缺 native asm 硬 die；`autovec_strategy.x` exit0 硬失败；check／C（现成 `.o` only）／perf＝obs；删顶层双权威 DOC；报告 `run=`／`obs=`／`skip=`；双端 L2；**simd-autovec soft fallthrough FAIL 池空** |
| STD-021／022 path-fs-windows soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`windows_abs_join`／`windows_path_smoke` exit0 硬失败；check／xplat 委托＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**path-fs-windows soft fallthrough FAIL 池空** |
| STD-152 tar-extended soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`／extra CLI `.o`；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`long_path_dir.x` exit0 硬失败；check／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；archive `## 4. Gate`；双端 L2；**tar-extended 残 fallthrough FAIL 池空** |
| STD-003 fs-crossplatform soft→硬绿 | ✅ | DOC→`## 5. Gate`（§4 仍兼容矩阵）；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=`／`x=` 报告；显式坏 XLANG／缺 native 硬 die；must-policy `.x`／`run-fs.sh` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**fs-crossplatform soft fallthrough FAIL 池空** |
| STD-012 examples soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`hello.x`＋`io_batch_rw.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**examples soft fallthrough FAIL 池空** |
| STD-138 xplat-deep soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；must-policy `.x` exit0 硬失败；check／optional＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**xplat-deep soft fallthrough FAIL 池空** |
| STD-009 http soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft ensure／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`tests/http/main.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；bench→`i08_http_*`；双端 L2；**http 主闸 soft fallthrough FAIL 池空** |
| STD-008 json soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=`／`main=`／`zc=` 报告；显式坏 XLANG／缺 native 硬 die；`main.x` exit0 硬失败；zc＝obs（Darwin `needs_copy` 残；Ubuntu 金标绿）；报告 `run=`／`obs=`／`skip=`；双端 L2；**json soft auto-make FAIL 池空** |
| STD-048 queue-concurrent soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／bootstrap-link／soft `ensure_std_c_o`／C contention auto-make／extra CLI `.o`；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`main.x` exit0 硬失败；check／sync_queue_roundtrip（queue-sync UNDEF）／host-C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；archive `## 4. Gate`；双端 L2；**queue-concurrent 残 fallthrough FAIL 池空** |
| db-kv-arrow soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／soft ensure；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`kv_tick`／`arrow_column`／cookbook exit0 硬失败；check／host-C＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**db-kv-arrow soft fallthrough FAIL 池空** |
| STD-004 async-api soft→硬绿 | ✅ | DOC→`## 10. Gate` honesty；闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft ensure_std_c_o／soft auto-make／`check=`／`switch=`／`imp=`／`drain=`／`coop=` 报告；显式坏 XLANG／缺 native 硬 die；switch＋imp＋drain exit0 硬失败（并入 `run=`）；check／coop＝obs（产品 UNDEF）；报告 `run=`／`obs=`／`skip=`；双端 L2；**async-api soft fallthrough FAIL 池空** |
| STD-137 time-format-timezone soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`format_timezone.x` exit0 硬失败；check／C＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**time-format-timezone soft fallthrough FAIL 池空** |
| STD-133 time-bench-timer soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`bench_timer.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**time-bench-timer soft fallthrough FAIL 池空** |
| STD-160 string-unicode soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`unicode_bridge.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**string-unicode soft fallthrough FAIL 池空** |
| STD-111 sync-lock-diag soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`lock_diag.x` exit0 硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**sync-lock-diag soft fallthrough FAIL 池空** |
| STD-145 test-runner soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`runner_smoke.x` exit0＋报告行硬失败；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**test-runner soft fallthrough FAIL 池空** |
| STD-139 sqlite-stub soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make／soft sqlite-o-stub；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`stub_behavior.x` exit0 硬失败；check／C stub＝obs（现成 stub `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**sqlite-stub soft fallthrough FAIL 池空** |
| STD-049 aes-gcm soft→硬绿 | ✅ | 二过：拒 soft auto-make／XLANG fallthrough／bootstrap-link；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`main.x` exit0 硬失败；check／nist2＝obs（产品 RUN≠0）；报告 `run=`／`obs=`／`skip=`；双端 L2；**aes-gcm 残 auto-make FAIL 池空** |
| STD-123 fs-dirmeta soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／`check=` 报告；显式坏 XLANG／缺 native 硬 die；`dirmeta_roundtrip.x` exit0 硬失败；`DIRENT_D_NAME_OFF` LINUX=19／MACOS=21；拒陈旧 `fs.c`；check／C archaeology＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**fs-dirmeta soft fallthrough FAIL 池空** |
| STD-134 url-ipv6-host soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`ipv6_host.x` exit0 硬失败；check／C＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`；双端 L2；**url-ipv6-host soft fallthrough FAIL 池空** |
| BOOT-029 std-sys soft→硬绿 | ✅ | 二过：拒 soft XLANG fallthrough／soft auto-make；prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；显式坏 XLANG／缺 native 硬 die；`write_stdout` exit0 硬失败（Linux freestanding／Darwin hosted）；check／linux_nr／macos_thin＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**std-sys soft fallthrough FAIL 池空** |
| EXC-004 error-chain soft→硬绿 | ✅ | DOC／TSV→`## 6. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`error_chain_smoke.x` exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| EXC-003 error-code-layer soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；`error_code_layer.x` exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| EXC-006 error-recovery soft→硬绿 | ✅ | DOC／TSV→`## 3. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；recovery suite 30 case exit0 硬失败；报告 `check=`／`run=`／`skip=`；双端 L2 |
| EXC-002 panic/abort soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make；显式坏 XLANG／缺 native 硬 die；check＝obs；矩阵 4×run＋3×hook 产品硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**EXC-002 soft FAIL 池空** |
| STBL-004 import-std-layout soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；check 观测；resolve＋`check_imports.x` exit0 硬失败；报告 `resolve=`／`check=`／`run=`／`skip=`；双端 L2 |
| EXC-005 cli-lsp soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make；显式坏 XLANG／缺 native 硬 die；check＝obs；2× golden compile phrase+kind+line:col 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**EXC-005 soft FAIL 池空** |
| BOOT-015 semantic-smoke soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make；显式坏 XLANG／缺 native 硬 die；check＝obs；vec／map／heap 产品 `-o` 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**boot-015 soft FAIL 池空** |
| BOOT-019 stage2-dogfood soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make／soft bootstrap-link／subset link soft SKIP；显式坏 XLANG／缺 native 硬 die；check＝obs；六条 parser／typeck 产品 `-o` 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**boot-019 soft FAIL 池空** |
| BOOT-014 std-link-contract soft→硬绿 | ✅ | DOC／TSV→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make；显式坏 XLANG／缺 native 硬 die；json always 产品硬绿；on_demand async＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**BOOT-014 soft FAIL 池空** |
| C-07 frontend-parity soft auto-make →硬绿 | ✅ | DOC→archive `## Gate`；拒 soft auto-make xlang-c；REF 须现成 native；CAND prefer asm；收敛 `dod_native_exe`（退役 `c07_native_xlang` 双权威）；显式坏 C07_REF／C07_CAND 硬 die；REF typeck_ok／compile_fail 硬；CAND `-backend c` SEGV／diverge＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**c07 soft auto-make FAIL 池空** |
| io／net／queue soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make xlang-c／soft 默认 xlang／prefer-c／net soft gcc fallback；显式坏 XLANG／缺 native 硬 die；io 9 案／queue main／net main＋udp_batch 产品 `-o` 硬绿；net 保留 ensure_std 族；报告 `run=`／`obs=`／`skip=`；双端 L2；**io＋net＋queue soft auto-make FAIL 池空** |
| STD-077／087／086／036／072 cli／cache／config／csv-row／bytes soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make xlang-c／soft XLANG fallthrough／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `-o` 硬绿（csv-row×2）；check／host-C smoke＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**cli＋cache＋config＋csv-row＋bytes soft auto-make FAIL 池空** |
| STD-080／081 option-result soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make xlang-c／soft XLANG fallthrough／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `roundtrip.x` `-o` 硬绿；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**option-result soft auto-make FAIL 池空**（codec 族仍产品红＝formal_mod／ondemand 缺叶，另案） |
| STD-155／074／076 bytes-arena／datetime／url soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft auto-make xlang-c／soft XLANG fallthrough／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `arena_external`／`roundtrip` `-o` 硬绿；check／host-C archaeology＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**bytes-arena＋datetime＋url soft auto-make FAIL 池空**（encoding-hex／uuid 仍产品 UNDEF／ensure，另案） |
| STD-079／129／112 security／set-ops／heap-allocator soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `roundtrip`／`ops`／`allocator_vec` `-o` 硬绿；cookbook 邻域硬；check／host-C archaeology＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**security＋set-ops＋heap-allocator soft auto-make FAIL 池空** |
| STD-015／017／011 set-extend／heap-trace／error-unify soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make xlang-c／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `extend`／`trace_stats`（含 `XLANG_HEAP_TRACE=1`）／`error_unify_smoke` `-o` 硬绿；cookbook 邻域硬；check＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**set-extend＋heap-trace＋error-unify soft auto-make FAIL 池空** |
| STD-130／150／060 random-rng／sort-key／sort-stable soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `rng_roundtrip`＋`main`／`key_stable`／`stable_i32`＋`cmp_desc` `-o` 硬绿；check／host-C archaeology＝obs（不碰 ensure_std 族）；报告 `run=`／`obs=`／`skip=`；双端 L2；**random-rng＋sort-key＋sort-stable soft auto-make FAIL 池空** |
| STD-005／025／019 time／env-iter／fmt-multi soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `main`＋`precision_smoke`／`env_iter`＋`env_args_iter`／`format_multi` `-o` 硬绿；check＝obs（不碰 ensure_std 族）；报告 `run=`／`obs=`／`skip=`；双端 L2；**time＋env-iter＋fmt-multi soft auto-make FAIL 池空** |
| STD-020／158／071 error-map／error-semantics／context soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `error_map_smoke`＋`error_module_base`／`error_semantics_smoke`＋`error_semantic_class`／`cancel_smoke` `-o` 硬绿；check／host-C archaeology＝obs（不碰 ensure_std 族）；报告 `run=`／`obs=`／`skip=`；双端 L2；**error-map＋error-semantics＋context soft auto-make FAIL 池空** |
| STD-156／132／008 context-cookbook／env-platform／json soft auto-make →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft XLANG fallthrough／soft auto-make／soft ensure_std_c_o／`check=` 报告；显式坏 XLANG／缺 native 硬 die；产品 `context_cancel_deadline`／`platform_encoding`／`json/main` `-o` 硬绿；check／host-C／zc＝obs（不碰 ensure_std 族）；报告 `run=`／`obs=`／`skip=`；双端 L2；**context-cookbook＋env-platform＋json soft auto-make FAIL 池空** |
| BOOT-010 force-stub soft→硬绿 | ✅ | DOC→`## 7. Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；matrix `reg_src` link+run 硬失败（4／4）；`check_only` 观测；报告 `link=`／`skip=`；双端 L2 |
| DOD-CL-S1／S2 soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`；check／warn 观测；`cl_align64` exit64／`cl_arena64` exit0 硬失败；报告 `check=`／`warn=`／`run=`／`skip=`；双端 L2 |
| f03-io soft→硬绿 | ✅ | DOC→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；inventory＋`run-io` 硬失败；报告 `inventory=`／`run=`／`skip=`；双端 L2 |
| STD-037／114 unicode-nfc＋grapheme-case soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 无 dedicated NFC harness／grapheme 仅预编 `unicode.o`＝obs；check＋tip product UNDEF／exit≠0＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**unicode-nfc＋grapheme-case soft FAIL 池空**；STD-082 NFD／NFKC／NFKD API 面缺失＝产品另案 |
| STD-HTTP-H2 http-h2 soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK（无 native／Docker）／prefer-c／soft `ensure_std_c_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 无 dedicated harness（拒 ensure）；check＋tip product UNDEF＝obs；TSV／DOC 锚对齐活 `http2_*.inc`／`http2_*.x`；报告 `run=`／`obs=`／`skip=`；双端 L2；**http-h2 soft FAIL 池空** |
| STD-066 sqlite-query-rows soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft `std_sqlite_build_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 预编 `.o` only＝obs；check＋tip product SEGV＝obs；API 锚对齐 `rows`（拒化石 `query_rows`）；报告 `run=`／`obs=`／`skip=`；双端 L2；**query-rows soft FAIL 池空** |
| STD-067／068／069 next-row＋col_text＋col_blob soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft `std_sqlite_build_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 预编 `.o` only＝obs；check＋tip product SEGV＝obs；API 锚对齐 `begin`／`next_row`／`col`／`end`／`col_text`／`col_blob`；报告 `run=`／`obs=`／`skip=`；双端 L2；**next-row＋col_text＋col_blob soft FAIL 池空** |
| STD-044／151／137 channel-unbounded＋ffi-struct-callback＋sqlite-blob-stream soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft `std_sqlite_build_o`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 预编 `.o` only＝obs；check＋tip product UNDEF／SEGV＝obs；blob API 锚对齐 `col_blob_len`／`col_blob_read`；报告 `run=`／`obs=`／`skip=`；双端 L2；**channel-unbounded＋ffi-struct-callback＋sqlite-blob-stream soft FAIL 池空** |
| STD-039／122／SOCKETIO compress-stream＋unified-stream＋socketio soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `ensure_std_c_o`／soft `std_compress_try_libs`／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 预编 `socketio.o` only＝obs；check＋tip product UNDEF＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**compress-stream＋unified＋socketio soft FAIL 池空** |
| STD-084／070／127 sqlite-pool＋stmt-cache＋encoding-extra soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft `std_sqlite_build_o`／soft ensure／soft auto-make；显式坏 XLANG／缺 native 硬 die；host-C 预编 `.o` only＝obs；check＋tip product SEGV／UNDEF＝obs；TSV／DOC 锚对齐产品 `open`／`acquire`／`bind`；报告 `run=`／`obs=`／`skip=`；双端 L2；**sqlite-pool＋stmt-cache＋encoding-extra soft FAIL 池空** |
| STD-057／051／030 sqlite＋regex＋net-tls soft→硬绿 | ✅ | DOC／TSV→`## Gate`；闸 prefer asm＋`XLANG_LINK_XLANG`；拒 soft SKIP→OK／prefer-c／soft ensure／soft net-o-*；显式坏 XLANG／缺 native 硬 die；host-C 预编 `.o` only＝obs；check＋tip product SEGV／missing-main／typeck＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**sqlite／regex／net-tls soft FAIL 池空** |
| STD-113／126／031 chacha＋ed25519＋net-ws soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／soft `ensure_runtime_*_glue_o`／soft auto-make／check 硬绑／`c=`／`x=`／`accept=`／`frame=`／`typeck=`；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `.o`＝obs；check＋tip product UNDEF＝obs；TSV 锚对齐产品（KEY_LEN／SEED_LEN＝function；chacha `_c`→`chacha20_aead.x`）；archive `## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**chacha＋ed25519＋net-ws soft FAIL 池空** |
| STD-121／058／063／064／103 elf-write＋parse＋deep＋phdr＋sym-rela soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／soft auto-make／check 硬绑／`c=`／`c_smoke=`／`x=`／`phdr_c=`／`deep_c=`；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `std/elf/elf.o`＝obs；check＋tip product `std_elf_*` UNDEF＝obs；archive `## Gate`；TSV script 锚全路径；报告 `run=`／`obs=`／`skip=`；双端 L2；**elf 五闸 soft FAIL 池空** |
| STD-059／149／115 math-fenv＋capability＋special soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／soft auto-make／check 硬绑／`c_smoke=`／`c=`／`x=`／`host=`；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `.o`＝obs；check＋tip product `std_math_*` UNDEF＝obs；archive `## Gate`；TSV script 锚全路径；拒 lib 内 `set -e` 泄漏；报告 `run=`／`obs=`／`skip=`；双端 L2；**math-fenv＋capability＋special soft FAIL 池空** |
| STD-089／088／147 task＋trace＋backtrace-xplat soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／soft auto-make／check 硬绑／`c_smoke=`／`x=`／`quality=`；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `.o`＝obs；check＋tip product／quality UNDEF＝obs；TSV／archive API 锚对齐产品短名；`## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**task＋trace＋backtrace-xplat＋math-fenv＋capability＋special＋elf-write＋parse＋deep＋phdr＋sym-rela soft FAIL 池空** |
| STD-128／116／146 csv-stream＋json-typed＋atomic-widen soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／atomic soft glue ensure／check 硬绑／`c=`／`x=`／`exec=`；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `.o`＝obs；check＋tip product UNDEF＝obs；archive `## Gate` honesty；atomic section→TSV archive；报告 `run=`／`obs=`／`skip=`；双端 L2；**csv-stream＋json-typed＋atomic-widen soft FAIL 池空** |
| STD-041 async-future＋async-context soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 future soft auto-make `future.o\|\|true`＋`c=`／`x=`／`emit=`；退役 context prefer-c／soft SKIP→OK／soft `ensure_std_c_o`（F-07）／check 硬绑；显式坏 XLANG／缺 native 硬 die；host-C 仅预编 `.o`＝obs；check＋tip product `-o` `std_async_*` UNDEF＋emit marker miss＝obs；`-E` 工具失败硬 die；archive Gate honesty；报告 `run=`／`obs=`／`skip=`；双端 L2；**async-future＋async-context soft FAIL 池空** |
| STD-042 async-io-cps soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft auto-make／soft SKIP→OK／check 硬绑／`align=`／`emit=`；显式坏 XLANG／缺 native 硬 die；check＋tip product `-o` `std_async_*` UNDEF＋emit marker miss＝obs；`-E` 工具失败硬 die；archive DOC Gate honesty；报告 `run=`／`obs=`／`skip=`；双端 L2；**async-io-cps soft FAIL 池空** |
| STD-078／117／090 metrics＋schema soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft auto-make／soft SKIP→OK／grep 假绿／`x=`／`c_smoke=`；显式坏 XLANG／缺 native 硬 die；check＋tip product `-o` `std_metrics_*`／`std_trace_*`／`std_schema_*` UNDEF＝obs；host-C 仅预编 `.o`；TSV 锚活面短名；archive DOC Gate honesty；报告 `run=`／`obs=`／`skip=`；双端 L2；**metrics＋metrics-obs＋schema soft FAIL 池空** |
| STD-073／110／139 codec soft prefer-c →硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 prefer-c／soft auto-make／soft SKIP→OK／`check` 硬绑／`x=` 报告；显式坏 XLANG／缺 native 硬 die；check＋tip product `-o` `std_codec_*` UNDEF＝obs；archive DOC Gate honesty；报告 `run=`／`obs=`／`skip=`；双端 L2；**codec＋stream＋buffer-reuse soft FAIL 池空** |
| STD-144 mem-safe soft→硬绿 | ✅ | 闸 prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft prefer-c／soft SKIP→OK／`check` 硬绑／`x=` 报告；显式坏 XLANG／缺 native 硬 die；check＋tip product `-o` `std_mem_*` UNDEF＝obs；删顶层双权威 DOC；报告 `run=`／`obs=`／`skip=`；双端 L2；**mem-safe soft fallthrough FAIL 池空** |
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
| typeck-region soft-skip WARN →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft-skip WARN／prefer-c／soft auto-make／check 绑正负例；核心 region 负例 product `-o` compile_fail 硬绿；正例 typeck-ok＋期望 extern UNDEF＝run；read_ptr escape／mismatch tip＝obs；check CHK002＝obs；archive DOC `## Gate`；收紧 diag 正则（禁裸 `region` 匹配路径）；报告 `run=`／`obs=`／`skip=`；双端 L2；**typeck-region soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；Darwin ub／struct hook＝obs |
| zc2 soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／check 绑；显式坏 XLANG／缺 native 硬 die；gen＋slice 产品 `-o` 硬绿；mmap／view tip＝obs；check＝obs；Windows mmap N/A＝skip；DOC→archive `## Gate`；semantics 退役 NEXT.md＋钩子默认 opt-in；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／typeck-region／zc2 soft FAIL 池空**；zc2 mmap／view tip＝obs；**zc3／zc4／zc5 仍绑 host-c 后置** |
| json／log／math soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／math 硬绑 check；显式坏 XLANG／缺 native 硬 die；三 runner 产品 `-o` main.x 硬绿；math check／host-C smoke＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**json＋log＋math soft FAIL 池空**；Darwin math check＝obs；zc3／zc4／zc5 host-c 后置 |
| type-zero-cost／type-ffi-bridge soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／化石顶层 DOC／`codegen.c`／`loop_i32`；显式坏 XLANG／缺 native 硬 die；DOC→archive/type＋`## Gate`；bench→`r01_`／`m03_`／`r10_`／`a01_*`；live mapping=`type_to_c_repr`；compile／putchar／cstr 产品 `-o` 硬绿；typeck／region check＝obs；bcmp＝skip；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／json＋log＋math／type-zero-cost＋type-ffi-bridge soft FAIL 池空**；Darwin type-zero typeck＝obs；zc3／zc4／zc5 host-c 后置 |
| process／map-vec／core-cmp／fmt／i16 soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／check 硬绑 CHK002／化石 TSV `vec_u64_append_slice`；显式坏 XLANG／缺 native 硬 die；map／vec／cmp／fmt／i16 产品 `-o` 硬绿（vec score=10）；process pipe tip `**u8`＝obs、win 非 Windows＝skip；DOC→archive＋`## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／process＋map-vec＋core-cmp＋fmt＋i16／TST-001＋002＋mem-boundary＋tool-fmt soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；process pipe tip＝obs |
| TST-001／002／mem-boundary／tool-fmt soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／check 硬绑 CHK002／化石顶层 DOC／`codegen.c`；显式坏 XLANG／缺 native 硬 die；fs／string／heap／vec／map／process／fmt hooks 产品硬绿；io tip UNDEF／net tip exit≠0／std_mem_* tip UNDEF＝obs；DOC→archive＋`## Gate`；TSV→archive／`codegen.x`；case 计数→live 非零 `return`；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／process＋map-vec＋core／TST-001＋002＋mem-boundary＋tool-fmt soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；io／net／std_mem_* tip＝obs |
| SAFE-005／006／007 soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／化石顶层 DOC；显式坏 XLANG／缺 native 硬 die；race mutex／atomic 产品 `-o` 硬绿；leak Ubuntu ASAN 硬绿、Darwin skip；crash `std_backtrace_collect_crash_evidence` UNDEF／panic 无 evidence＝obs；DOC→archive/safe＋`## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／TST-001＋002＋mem-boundary＋tool-fmt／SAFE-005＋006＋007 soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；crash UNDEF tip＝obs |
| type-borrow／lint／obs-phase／zc-copy soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／化石顶层 borrow DOC／zc 顶层 DOC+SEM 假锚；显式坏 XLANG／缺 native 硬 die；borrow pos／neg＋lint clean／error 产品 `-o` 硬绿；check 层 warn／info／phase-timing tip miss＝obs；DOC→archive＋`## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／type-zero-cost＋type-ffi-bridge／type-borrow＋lint＋obs-phase＋zc-copy soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
| lang-unsafe soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／soft auto-make／prefer-c／g-ffi `LANG_UNSAFE_SOFT`；显式坏 XLANG／缺 native 硬 die；`run`／product `-o` compile_fail 硬绿；check／hook timeout·fail＝obs；DOC→archive `## Gate`；`gate_run_timeout` 补 Perl 进程组杀；报告 `run=`／`obs=`／`skip=`；双端 L2；**lang-unsafe soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；Darwin ub／struct hook＝obs；typeck-region soft-skip 已收口 |
| comp-riscv64／win-backend／size-attrib soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c；显式坏 XLANG／缺 native 硬 die；riscv64 capable 须非空 `.text/main/ret`；win capable 须 COFF emit；capability／qemu N/A＝skip；空产物硬 die；DOC→archive `## Gate`；报告 `run=`／`skip=`；双端 L2；**comp-riscv64＋win-backend＋size-attrib soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
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
| debug／checklist-fast／rename-verify soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役四闸默认 xlang-c／seed＋soft auto-make／rename check 绑闸＋化石 Makefile 锚；显式坏 XLANG／缺 native 硬 die；debug 三案产品 `-o` 硬绿；checklist FAIL 节＝obs；rename 产品树旧路径收紧＋锚 ensure／compile 脚本、check／harddeps＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／types＋b06＋if-expr＋ternary／debug＋checklist-fast＋rename-verify soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
| types／b06-ast-pool／if-expr／ternary soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役五闸默认 xlang-c＋soft auto-make／soft SKIP→OK／types check 绑闸／pool-limits bootstrap-link 裹 xlang-c；显式坏 XLANG／缺 native 硬 die；types product `-o` overload exit0 硬／check＝obs；b06 活 ABI 锚＋pool-limits 十案硬绿；if-expr／ternary 产品 `-o` 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／bce＋owned＋sroa／types＋b06＋if-expr＋ternary soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
| bce／owned／scope-borrow／sroa／vec-push-arena soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役七闸默认 xlang-c＋soft auto-make／scope-borrow check 绑闸；显式坏 XLANG／缺 native 硬 die；BCE emit＋exit36 硬绿；scope-borrow 产品 `-o` compile_fail；sroa／ctfe 产品 exit7 硬／SROA emit＝obs；owned tip parse／typeck＝obs；vec-push tip exit=5／缺 push_arena＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／autovec／bce＋owned＋scope-borrow＋sroa＋vec-push-arena soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；owned／SROA／MEM-C1 tip 仍产品 obs |
| autovec loop／v2／v3／bce soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役默认 xlang-c＋soft auto-make；显式坏 XLANG／缺 native 硬 die；`-E` emit 非空＋产品 `-o` exit0 硬绿；缺 `xlang_autovec_*`（G-02a retired）／scalar 仍在＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／MEM-alloc＋arena-ASP／autovec soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；autovec helper emit 仍产品 obs |
| MEM allocator／arena-ASP soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役默认 xlang-c＋soft auto-make；显式坏 XLANG／缺 native 硬 die；AL-04 return compile_fail 硬绿；promote＋alias 产品 `-o` exit7 硬绿；escape UNDEF／AL-05 realloc 仍编／#[alloc] typeck／ASP KEEP_C＋escape tip＝obs；拒路径 `tests/typeck` 假匹配；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／lexer-bounds＋link-hardening／MEM-alloc＋arena-ASP soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；MEM-C1 `std_heap_scope_alloc`／AL inject 仍产品 obs |
| lexer-bounds／link-hardening soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役默认 xlang-c＋soft auto-make＋check 绑闸（lexer）／Darwin soft SKIP 无 `run=`／`skip=`；显式坏 XLANG／缺 native 硬 die；long-ident／long-num 产品 `-o` exit0 硬绿；Linux PIE+NX＋exit42 硬绿／非 Linux skip；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／lexer-bounds＋link-hardening／MEM-alloc＋arena-ASP soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
| signed／layout-overflow soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役默认 xlang-c＋soft auto-make＋check 绑闸；显式坏 XLANG／缺 native 硬 die；unsigned_wrap_ok 产品 `-o` exit42 硬绿；layout 委托 repr-c FAIL=1 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／ub＋struct／signed＋layout-ovf soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
| ub／struct-layout soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 prefer `./compiler/xlang`＋bootstrap-link prefer-c／无界 Darwin hang／硬绑 xlang-c `-E`＋`2>&1` 混 stderr；显式坏 XLANG／缺 native 硬 die；UB div_ok／unsigned_wrap／panic 产品 `-o` 硬绿（timeout hang＝obs）；struct product `-o`＋asm `-E` Layout8 硬绿；host-cc static_assert＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／next-yellow／ub＋struct soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
| next-yellow-clear soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 prefer-c／soft SKIP→OK／soft auto-make／check 硬绑／`NEXT.md`＋顶层 DOC 假锚／化石符号锚；显式坏 XLANG／缺 native 硬 die；活符号＋archive DOC＋`## Gate`；product `-o` 8 硬绿；queue／sqlite TLS／debug diag／check＝obs；CORE-018 委托 bitops；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／doc-*／next-yellow soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；queue exit=5／sqlite TLS＝obs |
| doc-* soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 prefer-c／soft SKIP typeck／check 硬绑／顶层 DOC 假锚／化石 xref；phase2-close／memory-safety／cookbook-expand／stdlib-cookbook／doc-07 phase2／phase3；显式坏 XLANG／缺 native 硬 die；product `-o` smoke 硬绿；check／Darwin sqlite SEGV＝obs；DOC→archive＋`## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／typeck-linear＋tst-004／doc-* soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；cookbook check parse＝obs |
| typeck-linear／tst-004 soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 prefer-c／soft auto-make／check 硬绑／顶层 DOC 假锚／化石 needs_o；显式坏 XLANG／缺 native 硬 die；linear 产品 `-o` 四负一正硬绿；tst-004 Ubuntu ASAN 硬绿、Darwin skip；check CHK002＝obs；DOC→archive＋`## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／core-builtin＋mem-intrinsic＋safe-ffi／typeck-linear＋tst-004 soft FAIL 池空**；zc3／zc4／zc5 host-c 后置 |
| core-builtin／mem-intrinsic／safe-ffi soft SKIP→OK →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK／prefer-c／soft auto-make／safe-ffi 顶层 DOC 双权威；显式坏 XLANG／缺 native 硬 die；builtin／mem／ffi 产品 `-o` 硬绿；`__builtin_*` emit undercount＝obs；DOC→archive＋`## Gate`；报告 `run=`／`obs=`／`skip=`；双端 L2；**…／SAFE-005＋006＋007／core-builtin＋mem-intrinsic＋safe-ffi soft FAIL 池空**；zc3／zc4／zc5 host-c 后置；emit tip＝obs |
| boot-std-link／exc-cli／exc-panic soft auto-make →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make（`xlang_compiler_make…\|\|true`）＋显式坏 XLANG 回落其它二进制；显式坏 XLANG／缺 native 硬 die；check＝obs；json always＋2 golden＋7 case 产品硬绿；on_demand async＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**BOOT-014＋EXC-005＋EXC-002 soft FAIL 池空**；Darwin check／async＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置；余 soft：非 ensure tinies／c07 soft auto-make xlang-c |
| boot-015／019 soft auto-make →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make（`xlang_compiler_make…\|\|true`）＋019 soft bootstrap-link wrap＋subset link miss soft SKIP；显式坏 XLANG／缺 native 硬 die；check＝obs；vec／map／heap＋6 smoke 产品 `-o` 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**boot-015＋019 soft FAIL 池空**；Darwin check＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置；余 soft：非 ensure tinies（boot-std-link／exc-* 已收） |
| refresh-xlang-asm soft→硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 local non-Linux soft SKIP→OK（无 `skip=`）＋soft auto-make＋硬绑 `./compiler/xlang`＋硬绑 `xlang check`；显式坏 XLANG／缺 native 硬 die；local Darwin refresh-gate＝`skip=1`（SHARED 烟测仍硬）；Linux／CI `xbuild refresh-gate` 硬；import 产品 `-o` exit0；const_hex `-E` MAGIC；check＝obs；region／linear 子闸硬；报告 `run=`／`obs=`／`skip=`；双端 L2；**refresh-xlang-asm soft FAIL 池空**；Darwin obs=1 skip=1；Ubuntu obs=0；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置；余 soft：非 ensure tinies（boot-015／019 已收） |
| CORE-017／CORE-011 soft auto-make →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK（无 native 仍 gate OK）＋soft auto-make xlang-c＋bootstrap-link 裹 xlang-c；显式坏 XLANG／缺 native 硬 die；check＝obs；volatile_fence／f64_special 产品 `-o` exit0 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**CORE-017＋CORE-011 soft FAIL 池空**；Darwin check＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置；余 soft：非 ensure tinies（refresh-xlang-asm 已收） |
| CORE-002/003／006／STD-131 soft auto-make →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK（无 native 仍 gate OK）＋soft auto-make xlang-c＋bootstrap-link 裹 xlang-c；显式坏 XLANG／缺 native 硬 die；check＝obs；option102／result173、iterator smoke＋cookbook10、find_split exit0 产品 `-o` 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**CORE-002/003＋006＋STD-131 soft FAIL 池空**；Darwin check＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置；余 soft：refresh-xlang-asm／非 ensure tinies（mem-volatile／fmt-f64 已收） |
| CORE-012／007／004 soft auto-make →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft SKIP→OK（无 native 仍 gate OK）＋soft auto-make xlang-c＋bootstrap-link 裹 xlang-c；显式坏 XLANG／缺 native 硬 die；check＝obs；assert_extend／bytes_view＋cookbook／subslice 产品 `-o` 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**CORE-012＋007＋004 soft FAIL 池空**；Darwin check＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置；余 soft：refresh-xlang-asm／非 ensure tinies |
| CORE-001／CORE-016 soft prefer-c →硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 prefer-c（xlang-c 先）＋soft auto-make xlang-c＋无 native soft SKIP→OK；显式坏 XLANG／缺 native 硬 die；check＝obs；generic `-o` exit0／unify 双 smoke exit0 硬绿；报告 `run=`／`obs=`／`skip=`；双端 L2；**CORE-001＋CORE-016 soft FAIL 池空**；Darwin check＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置；余 soft：其它 core-* soft auto-make vestige |
| migrate-x-gen soft→硬绿 | ✅ | 默认 inspect-only gen 标记（拒 soft wipe＋soft auto-make xlang-c）；FORCE 须现成 native xlang-c，经 ensure_migrate_gen＋migrate_x_objs（不先 rm）；stale／缺 `.o` 无 FORCE＝obs；缺 gen／标记 miss＝硬 die；报告 `run=`／`obs=`／`skip=`；双端 L2；**migrate-x-gen soft FAIL 池空**；stale `.o`＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置 |
| x-pipeline／x-multi-file／lsp soft→硬绿 | ✅ | prefer asm＋`XLANG_LINK_XLANG`；退役 soft auto-make bootstrap-pipeline／xlang-x＋soft SKIP→OK（XLANG 置位／缺 `-x -E`／timeout）／lsp `--help` 缺 `--lsp` soft auto-make；显式坏 XLANG／缺 native 硬 die；`-x -E` min＋multi-file `foo_bar`／exit42 硬绿；lsp tip 无 completionProvider／hits=0＝obs；报告 `run=`／`obs=`／`skip=`；双端 L2；**x-pipeline＋x-multi-file＋lsp soft FAIL 池空**；lsp tip＝obs；zc3／zc4／zc5 host-c 后置；ensure_std／fmt-check／brotli／without-c 仍后置 |
| STD soft SKIP 邻域续（其它闸） | 🟡 | soft SKIP 邻域续扫（若仍有 soft die→exit0；**…／codec＋stream＋buffer-reuse／option-result／bytes-arena＋datetime＋url／cli＋cache＋config＋csv-row＋bytes／boot-std-link＋exc-cli＋exc-panic／boot-015＋019／refresh-xlang-asm／CORE-017＋011／CORE-002/003＋006＋STD-131／CORE-012＋007＋004／CORE-001＋016／migrate-x-gen／x-pipeline＋lsp soft FAIL 池空**；余 soft：邻域再扫…／非 ensure tinies（**mem-safe＋codec＋metrics＋schema＋async-io-cps＋async-future＋async-context＋csv-stream＋json-typed＋atomic-widen＋task＋trace＋backtrace-xplat＋math-fenv＋elf五闸＋chacha＋ed25519＋net-ws＋sqlite＋regex＋net-tls＋sqlite-pool＋stmt-cache＋encoding-extra＋channel-unbounded＋ffi-struct-callback＋sqlite-blob-stream＋next-row＋col_text＋col_blob＋query-rows＋http-h2＋unicode-nfc＋grapheme-case＋compress 残 try_libs＋aes-gcm 残 auto-make＋log-rotate-async 残 fallthrough＋io-context 残 fallthrough＋thread-pool 残 fallthrough＋tar-ustar 残 fallthrough＋atomic-ordering 残 fallthrough＋tar-extended 残 fallthrough＋queue-concurrent 残 fallthrough＋sync-rwlock-condvar 残 fallthrough＋backtrace-symbolicate 残 fallthrough＋trace-hooks 残 prefer-c／ensure＋sqlite-exec-deep 残 prefer-c／ensure＋regex-atomic 残 prefer-c／ensure soft FAIL 池空**；tip `std_mem_*`／`std_codec_*`／`std_metrics_*`／`std_schema_*`／`std_async_*`／`std_task_*`／`std_trace_*` UNDEF＝obs）；ensure_std 族；fmt-check／brotli／without-c；encoding-hex／uuid 产品 UNDEF（codec 产品 UNDEF＝obs 已诚实）；read_ptr region tip＝obs；zc2 mmap／view tip＝obs；Darwin math check＝obs；queue exit=5／sqlite TLS／debug diag＝obs；cookbook check parse＝obs；phase3 Darwin sqlite SEGV＝obs…；**zc3／zc4／zc5 仍绑 host-c（xlang-c）后置**；Stage2 SHA256 topology fork 16B 产品残；Ubuntu tip stripped＞8MiB size＝产品 obs；MEM-C1 with_arena emit／`std_heap_scope_alloc`／AL inject／vec run 产品 obs；owned tip parse／typeck＝obs；SROA compound-literal tip＝obs；MEM-A1 single-ptr `restrict` 产品 obs；s2 `pipeline_type_ensure_by_kind_ord`／s3 compile.o stub size／tip live EMIT_HEAVY under 产品 obs；boot-017 tip SLOW／check_fail＝obs；compiler-self graph check-bound＝obs；Darwin net_mixed typeck nan＝obs；http client `std_io_write_stderr_u8_ptr_usize` UNDEF＝obs；wpo-s2 vec fold still-calls＝obs；simd-dot tip under-ratio＝obs；Darwin f32 SoA CG002＝obs；async-1m coop UNDEF＝obs；async-language run／mod＝obs；async-future c／.x／emit-marker＝obs；lifetime check smoke＝obs；option／result check＝obs（Darwin）；abi f32 xmm residual＝obs（含 legacy cvtsd2ss）；dod-s3 soa_cross exit≠10＝obs；typeck-generic tip span 0:0＝obs；obs structured `levelinfo`（缺 `=`）＝obs；c07 CAND `-backend c` SEGV 观测；experimental XP008／T001 观测；WPO_DCE baseline TSV under＝obs；STD uuid／task／trace 等 asm UNDEF 跳；**mem-safe soft→硬绿（tip UNDEF＝obs）**；linux mmap **file** smoke UNDEF 观测残；Darwin `std_sys_read_file_into` UNDEF＝obs；compress-stream／unified-stream 观测残；sqlite stub open／last_error 观测残；aes-gcm host-c／nist2 观测残；queue-sync 观测残；async future／iocps／ctx／lang／atomic-widen 观测残；channel-unbounded／csv-stream／elf-parse／ffi-struct／http-pool／reqresp／h2／context／json-typed／regex／schema／socketio／task／trace／unicode／backtrace-xplat／chacha／ed25519／net-ws tip UNDEF 观测残（闸 soft FAIL 池空）；compress-brotli ld 红跳；test-executable／bench-fuzz 探针 ld UNDEF 跳；**encoding-extra＋sqlite-pool＋stmt-cache soft→硬绿**；**regex＋net-tls＋sqlite soft→硬绿**；**chacha＋ed25519＋net-ws soft→硬绿**；**STD-057／051／030 sqlite＋regex＋net-tls soft→硬绿**；**STD-084／070／127 soft→硬绿**；lang-unsafe（check 后置）；仍跳过产品红／UNDEF）；另残 asm ld `--export-dynamic`（非软）＋by-value `Set_i32`+MEMORY（非软）＋Stage2 SHA256 topology converge（非软） |
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 非软刀默认；优先级到才动；Darwin heat 仍依赖 hybrid thin（禁 mega） |
| LANG-009／010 Option／Result 泛型 STRUCT_LIT | ✅ | 解析 mangle＋具名 lit typeck；闸 run hard |
| CORE-016 多 mono／多 let 字段 load 宽 | ✅ | typeck mono 戳优先于泛型布局 T→8；thin inject |
| CORE-016 Option／Result 泛型↔族 unify | ✅ | named-inst mangle 等式＋let 族 canonicalize；闸 run hard |
| CORE-013 i16／u16 size／align formal | ✅ | labi g1 全表针＋闸 run hard |
| CORE-017 core.mem volatile／fence formal | ✅ | labi_od_core_mem×31＋闸 prefer asm＋product `-o` run hard（soft auto-make／soft SKIP→OK 已退役） |
| CORE-011 core.fmt f64 NaN／Inf／prec | ✅ | 闸 prefer asm＋f64_special product `-o` exit0 run hard（soft auto-make／soft SKIP→OK 已退役） |
| CORE-004 core.slice API formal | ✅ | labi g9×28＋闸 prefer asm＋product `-o` run hard（soft auto-make／soft SKIP→OK 已退役） |
| CORE-006 iterator protocol formal | ✅ | 闸 prefer asm＋smoke／cookbook product `-o` run hard（soft auto-make／soft SKIP→OK 已退役） |
| CORE-007 core.str BytesView formal | ✅ | 闸 prefer asm＋smoke／cookbook product `-o` run hard（soft auto-make／soft SKIP→OK 已退役） |
| CORE-002/003 Option／Result combinators | ✅ | 闸 prefer asm＋option102／result173 product `-o` run hard（soft auto-make／soft SKIP→OK 已退役） |
| STD-131 core.str find／split | ✅ | 闸 prefer asm＋find_split product `-o` exit0 run hard（soft auto-make／soft SKIP→OK 已退役） |
| CORE-012 core.debug assert extend | ✅ | 闸 prefer asm＋assert_extend product `-o` exit0 run hard（soft auto-make／soft SKIP→OK 已退役） |
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
