# C → .X 迁移追踪（状态待办地图）

> **用途**：终局债 **状态 only**（✅／🟡／⬜ + 短事实）。  
> **禁止**：tip 流水账、wave／SHA 日记、双端日志。波次流水只写 [`自举进度.md`](自举进度.md) §6。  
> **考古**：[`archive/C迁移追踪-流水账归档-20260919.md`](archive/C迁移追踪-流水账归档-20260919.md) · [20260910](archive/C迁移追踪-流水账归档-20260910.md) · [20260825](archive/C迁移追踪-流水账归档-20260825.md)  
> **刷新**：2026-09-23 · 状态债 · **三端 L2 硬闸已启用** ✅；BC present **0**；AD–AP Cap／diagnostic／pipeline 拼装 ✅；**Class AQ–AT** Cap／driver 剥 ✅；**Class AU** labi prefer 根修 ✅；**Class AV** pipeline／rt_run Cap 剥 ✅（seed＋mega 门闩；pabi leftover 未 FORCE；真减续 🟡）· 钉盘 **`ecdb5cc1e`**（不升）

### 维护约定

1. 做到 → **🟡**；完成 → **✅**；未开 → **⬜**。  
2. ✅ 只留 **编号＋一句话标题**；🟡／⬜ 可加一两句。  
3. **禁止**往本文追加「本波做了什么」／SHA 日记。  
4. MG／Makefile 叶映射 → [`Makefile迁移表.md`](Makefile迁移表.md)。

---

## 0. 仪表盘

| 轨道／债 | 状态 | 事实（短） |
|----------|------|------------|
| 库层 .X 化（阶段 1） | ✅ | 100% |
| Thin 退役（阶段 2） | ✅ | T 18/18 |
| Prove 注册（阶段 3） | ✅ | N 111/111 |
| Cap 能力解锁（阶段 4） | 🟡 | 3 leave-off ⬜ |
| R2 真迁（阶段 5） | 🟡 | ~120/128；余绑平台债 |
| Mega 拆分 M1–M3（阶段 6） | ✅ | 3/3 |
| Mega 去 pin M4（阶段 7） | 🟡 | leftover flatten 完；parser seed 物理删 ⬜；产品 `.inc` 仍 host-cc；P20b zeros 已纯 asm |
| Pinned gen 退役（阶段 8） | ✅ | 30/30 |
| 非 gen 产品 C／8.3 | 🟡 | wave309 壳物理退役（present 0）；产品 `.inc`／from_x／其它 host-cc seed 仍开；AP leftover 拼装＋AS／AT driver_abi Cap 剥已收 |
| Cap residual 消灭（阶段 9） | ✅ | 9.1–9.7 |
| Win PE egg pin | ✅ | egg＠`99b008cc1`；默认 asm **5/5**；FIELD／INDEX／DEREF／`struct_let_init`／`copy_large_struct`／SIMD／`asm_parser_*`／m8_tail／`collect_walk`／`pgo_emit_order_*` override **进 live**（Class S–AC leftover-safe LEGACY g05）；**三端 L2 硬闸已启用** |
| 语言能力 L2（阶段 10） | 🟡 | 主面 ✅；残 NT／MSVC／qemu／Win 实机 |
| xbuild／MG（阶段 11） | 🟡 | Makefile 物理删 ✅；终局／零 cc CI 仍开 |
| 冷启动零 cc（阶段 12） | 🟡 | LINK／`.s` 大半 ✅；全路径零 cc ⬜ |
| 终局 MG+BC+PC+v2==v3（阶段 13） | 🟡 | MG 文件层 ✅；BC／PC／v2==v3 未终 |
| 产品 L4 钉盘 | ✅ | **`ecdb5cc1e`**（升钉默认不做） |
| BC（编译层零 host-cc） | 🟡 | inventory present **0**（Class O）；余量＝map 外 from_x／seed／`.inc`／大户 leftover 真减；Darwin tip **可 prefer labi**（AU；L6／L8 仍 host-cc；AV Cap seed 已剥） |
| PC（产品默认 asm） | 🟡 | 门控已收；`labi_invoke_cc` 未删 |
| `pipeline_abi` mega pure-asm | 🟡 | 已绿 PREFER 面同上。**Class AP** leftover 拼装已收；**Class AV** seed／mega DEBUG Cap 门闩已剥（产品 leftover 同尺寸，禁 FORCE）。真减 host-cc 续。HARD BAN／leftover-first／mega FORCE／`-E` 当修仍禁。 |
| nest 冻帽 | ✅ | **64** |
| check 闸门 | ⏸ | 自举期须点名才 dogfood |

**终局三义**：MG ✅ · BC 🟡 · PC 🟡。

---

## 阶段 0–3 · 已闭

- ✅ **阶段 0** 基建与方法论  
- ✅ **阶段 1** 库层 .X 化  
- ✅ **阶段 2** Thin 退役 T 18/18  
- ✅ **阶段 3** Prove 注册 N 111/111  

---

## 阶段 4 · Cap 能力解锁 🟡

### 已闭

- ✅ Cap dest／dyn／nest17–64／METHOD／STRUCT_LIT 等主面  

### 开项

- 🟡 **4.2.8** AST name 槽 128B→256B layout raise（content 127→255）  
- ⬜ **4.2.9** LANG-006 标量 bool→int — 有意保留 soft  
- ⬜ **4.2.16** `*T[N]` 解析序 — 有意保留 soft（`*[N]T`＝指针到数组）  

### 纪律

- nest **冻 64**；禁抬 nest 65；禁无界 assemble mega 当冷路径  

---

## 阶段 5 · R2 真迁 🟡

- ✅ 已真迁 ~120／128 prove 模块  

### 开项

- ⬜ **5.2.2** Darwin stage2 rv／strict multi-def  
- ⬜ **5.2.3** host `_impl` 后缀命名 — leave-off  
- ⬜ **5.2.4** Darwin `int64_t main` 硬要求 int  
- ⬜ **5.2.5** Windows MSYS2 hybrid 未重跑  
- ⬜ **5.2.6** mac CTFE 常 fold 假绿  
- ⬜ **5.2.7** mac `-dead_strip` 假绿当 Ubuntu 全链已过  

---

## 阶段 6 · Mega 拆分 M1–M3 ✅

- ✅ **6.1** runtime mega 拆分  
- ✅ **6.2** parser thin mega 拆分  
- ✅ **6.3** link_abi mega 拆分  

---

## 阶段 7 · Mega 去 pin（M4）🟡

### 已闭

- ✅ **7.1** runtime monofile 物理退役  
- ✅ **7.2.1a** 入口素材 70 件清零  
- ✅ **7.2.1b leftover flatten** unique 0／helpers 0；深链分批覆盖戏停  
- ✅ **7.2.1b Route C／B-minus** P1b–P1g · P2b–P2d · P3b–P3s · P4* · P5* · P6b–P6h · P7b–P7d · P9–P19 · P10–P18（细目见归档）  
- ✅ **7.2.3／7.3／7.4.1／7.4.2／7.4.3** 冷链／Stage2／prefer `.x`  
- ✅ **7.4.4** 双权威闸全家族  
- ✅ **7.4.5–7.4.10** typeck pin 孪生／leftover PE unique 0  

### 开项

- 🟡 **7.2.1b 残** 产品 `.inc` 切片仍 host-cc（glue_tail／冷 rest）；禁再深链分批 eq  
- 🟡 **7.2.2** parser_gen 去 pin — 产品默认 pin-first；`FROM_X=1` 仅显式 assemble  
- ⬜ **7.2.1** parser seed 物理删（依赖 7.2.1b／8.3）  

---

## 阶段 8 · Pinned gen 退役 ✅ · 8.3 非 gen 🟡

### 已闭

- ✅ **8.1** PRODUCT RETIRED 23／23  
- ✅ **8.2** NON_PRODUCT 7／7  
- ✅ **合计 30／30 FULLY CLOSED**  
- ✅ **8.3.4／8.3.5／8.3.7／8.3.9** leave／stubs／孤儿清理  
- ✅ glue 壳／typedefs／standalone deleted；bc-inventory present product C rows **0**  
- ✅ **8.3.6** 死件删除 114 件；三分表定稿（种子保留；`.inc` #else 冷质量待 L4 全 `.x` 冷引导）  

### 开项

- ✅ **8.3.1** `pipeline_glue`／fwd／standalone 壳物理退役（Class O；inventory present 0）  
- ✅ **8.3.2** `ast_pool`／typedefs 壳物理退役（Class O；inventory present 0）  
- 🟡 **8.3.3** field_access／soa — 叶 leave ✅；父项随冷孪生  
- 🟡 **8.3.8** `build_asm/gen_driver/*.c` — `pipeline_gen.c` 残留  
- ⬜ **8.3.10** `editors/tree-sitter-xlang/` 第三方 .c  
- ⬜ **BC 终局** 冷孪生整 TU 离 host-cc  

---

## 阶段 9 · Cap residual 边界消灭 ✅

- ✅ **9.1** OS 系统调用 9.1.1–9.1.12  
- ✅ **9.2** 第三方库勘正／standing（zlib／sqlite／libm／mbedtls／arrow／ed25519）  
- ✅ **9.3** 宏／host lit／atomic／SIMD 桥 standing  
- ✅ **9.4** C ABI／fnptr／argv／线程  
- ✅ **9.5** FILE／fprintf／va_list／fdprint／有界读  
- ✅ **9.6** 全局／static／modlet／字串池／RELA  
- ✅ **9.7** driver_abi 平台层 9.7.1–9.7.7  

> standing C＝系统库／语言极限（有意不迁）。细节见归档。

---

## 阶段 10 · 语言能力补齐 🟡

### 已闭

- ✅ **10.1.1／10.1.2** Linux x86_64／arm64 syscall 内建  
- ✅ **10.2.1** x86_64 inline asm slice0–16  
- ✅ **10.3.1–10.3.3** fnptr 类型／cast／间接 call／作参返回字段  
- ✅ **10.4.1／10.4.2** atomic＋内存屏障  
- ✅ **10.5.1／10.5.2** AVX／SSE／NEON／SVE  
- ✅ **10.6.1／10.6.3** Linux／Darwin 线程＋全平台 sync Cap  
- ✅ **10.7.1** va_list POSIX／host-C 单实例（MSVC 残）  
- ✅ **10.7.2** Cap vsnprintf slice0–21（纯 .x fmt／MSVC 残）  

### 开项

- ⬜ **10.1.3** Windows NT API 内建 — 暂缓  
- 🟡 **10.1.4** raw FFI — slice1–2 ✅；残 NT→10.1.3  
- 🟡 **10.2.2** arm64 inline asm — slice0–3 ✅；残 qemu  
- 🟡 **10.2.3** Windows inline asm — slice0–1 ✅；残 MSYS Win 运行时  
- 🟡 **10.6.2** Windows CreateThread — 源码＋gate ✅；残 MSYS／Win 实机  
- 🟡 **10.7.1 残** MSVC va  
- 🟡 **10.7.2 残** 纯 .x fmt · MSVC  

---

## 阶段 11 · xbuild + Makefile 退役（MG）🟡

### 已闭

- ✅ **11.2.2** `./xbuild l4`  
- ✅ **11.2.3／11.2.5／11.4.1／11.4.3／11.4.6** 编排入口  
- ✅ **11.3／11.3.1** Makefile 物理删除；catalog 单权威；bootstrap 0 make  

### 开项

- 🟡 **11.1.1–11.1.6** 依赖图／调度／平台／链接／`build.x`／吞并 g05 — 终局未完  
- ⬜ **11.2.1** stage1→2→3 编排 + 自动 v2==v3  
- ✅ **11.2.4** Windows／MSYS2：冷底座（g05＋crt0）✅；PE egg＋B-hybrid ✅；默认 asm **5/5**＠`89d99eb0c`；**三端 L2 硬闸已启用**＠`7edba47f4`（L4 真冷仍经理另派）  
- ⬜ **11.3.3** 其它 make 碎片（含 tree-sitter）  
- ⬜ **11.3.4** 「无 make + 无 cc」CI 闸门  
- 🟡 **11.4.5** docker 仍装 gcc／make  
- 🟡 **11.5.1–11.5.4** bench／tests 宿主 `.c` 策略（卸 cc→阶段 12）  
- ⬜ **11.6.1** `editors/tree-sitter-xlang/`  

---

## 阶段 12 · 冷启动零 cc 🟡

### 已闭

- ✅ LINK 全零 cc · `.s` COMPILE 零 cc · stub weak · `forbid_host_cc`  
- ✅ prefer 族／硬闸／ALLOW_TREE 地图  

### 开项

- 🟡 **12.0.5** asm backend 覆盖 — **`pipeline_abi` mega 仍硬禁**  
- ⬜ **12.1.1** 手写 asm seed（或极简二进制）  
- ⬜ **12.1.2** seed 产出 xlang_v1（无需 `-E`→cc）  
- ⬜ **12.1.3** 与 pin 退役衔接  
- 🟡 **12.2.1** 零 cc 验证 — ⬜ **全路径**零 `execve(cc)`  
- ⬜ **12.2.2** 双端冷启动验证（零 cc 闭环）  
- 🟡 **12.2.3** 产品默认后端 — `labi_invoke_cc` 未删  

---

## 阶段 13 · 终局 🟡

### 已闭

- ✅ **13.1.1** 前置闸门定义  
- ✅ **13.1.3** 阶段 9 residual 勘正收口  

### 开项

- ⬜ **13.1.2** 阶段 8 gen + 8.3／BC 完成（gen ✅；8.3／BC 未终）  
- ⬜ **13.1.4** v2 == v3 语义自举  
- ⬜ **13.1.5** D-03 bit-identical（可选）  
- ⬜ **13.2.1** 双端 L4 真冷 + 129 bstrict（**零 make · 零 host-cc**）  
- 🟡 **13.2.2** Makefile 物理删除验收 — 文件层 ✅；调用面／host-cc residual 🟡  
- ⬜ **13.2.3** 零 cc 三义验收（MG+BC+PC）  
- 🟡 **13.2.4** `labi_invoke_cc`／`-backend c` 退役或隔离  
- ⬜ **13.3.1** 物理删 seed 业务体  
- ⬜ **13.3.2** 宣布自举完成  

---

## 产品软残

| 项 | 状态 | 备注 |
|----|------|------|
| STD／CORE／gate soft SKIP 邻域 | 🟡 | 主池多空；余见归档 |
| `pipeline_abi` mega pure-asm | 🟡 | 已绿 PREFER：add_defs／param_ptr_slot／unused_hints／asm_expr helpers／`asm_wpo_thin`／`wpo_dump` helpers／`asm_locals`；Darwin COMMON lea／F7 data_len sidecar。**AP** Darwin leftover 拼装半刀已收。HARD BAN 面仍开。leftover-first 非主刀。mega FORCE 禁。禁 `-E` 当修。 |
| nest 冻 64 | ✅ | — |

---

## 附录

| 项 | 值 |
|----|-----|
| 产品 L4 放行钉盘 | **`ecdb5cc1e`** |
| bstrict | 129 |
| 升钉条件 | 用户点名 L4／谈自举；禁止微步升钉 |

### 推荐推进序

1. **主刀 M2**（[`自举效率方法-M2主链.md`](自举效率方法-M2主链.md)）：**Class F–AO** 已收（AO＝diagnostic ASM_FUNC_TRACE／Cap parse-step 剥）。HARD BAN 禁分类主刀。**三端 L2 硬闸仍启用**。下一刀＝下一产品梯真减 host-cc（diagnostic Cap 已薄；可转大户）。禁 leftover-first；禁 `-E` 当修；禁盲 FORCE mega；禁升钉。
2. 🟡 **7.2.1b 残**＋**8.3 冷孪生** — 产品 `.inc` 仍 host-cc；禁再深链分批 eq  
3. ⬜ **7.2.1／7.2.2** parser seed 物理删／去 pin  
4. 🟡 **阶段 10** 残（NT／MSVC／qemu／Win 实机）  
5. ⬜ **阶段 12–13** 最小 seed · 全路径零 cc · v2==v3 · 公告  

> 完成一步只改对应 `⬜`→`🟡`→`✅`。不要在本文写 tip／wave／日志路径。
