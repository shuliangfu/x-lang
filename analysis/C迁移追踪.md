# C → .X 迁移追踪（自举全程待办地图）

> **创建**：2026-07-29  
> **状态刷新**：2026-08-24 · **Ubuntu Stage2 hash STRICT 真定点 ✅**（同配方 `asm_only_strict` gen1＋稳定 `atoi_stub_tu.c`；SHA256=`0ae06666…` match／bytes=5760344 @ `1ac895e51`；拓扑收敛 tip `3532df206`）· **Stage2 hash 假 fixed-point 诚实刀 ✅**（ROUND2 禁 sync＋`gen1_for_hash`；先诚实红再收敛）· **Stage2 pipeline `__text=0B` ✅**（G.7 `runtime_pipeline_abi`；Darwin Step2 真 `asm_only_strict` @ `881283463`）· **Darwin Stage2 stubs filt ✅**（ar→MH_OBJECT＋`filter_o_export`；三项 UNDEF 清 @ `dc555af5b`）· **Stage2 bstrict E2E／standalone seed skip ✅** @ `a6e8e05c0` · **Stage2 X E2E 诚实门禁 ✅**（产品 NO_C／G-02a；probe soft-skip；REQUIRE 硬失败；Step5 ALLOW_HOST_CC；双端 soft g05＋L2 **5／5** @ `9a2ff18d2`）· **零 make 门禁 post_ship ✅**（MF-absent；leaf／ensure 地板对齐 mk；双端 soft g05＋L2 **5／5**＋gate OK @ `5042669b0`）· **tests 深层裸 make → shell／xbuild ✅**（a09／g06／compress／perf／wpo-docker；hub `compress-o-*` no-op＋`sqlite-o-stub`；双端 soft g05＋L2 **5／5** @ `54ace50f0`）· **tests 残裸 make → shell／xbuild ✅**（`run-l1-relink-fast` 0-make＋b20 `xlang_compiler_make`＋f-* die／相关 echo；双端 soft g05＋L2 **5／5** @ `bae2b6e82`）· **Stage2 X dogfood 链接卫生 ✅**（`g05_relink_env` MAIN_LINK／DUP／USER_ASM 面；`filter_o_export --omit-sym`；撤 Darwin 硬编码 crt0／multiply_defined／裸 exported_symbols_list；双端 soft g05＋L2 **5／5** @ `33b33fc7f`）· **错误文案 make→shell／xbuild ✅**（烟雾未闭合引号＋SKIP 死 make 重入；12 脚本 hint；双端 soft g05＋L2 **5／5** @ `ba750a280`）· **build_xlang_asm VIA_MAKE 残留 ✅**（解 MF 门控 try-heat／migrate：lsp／gen-x-driver／typeck companions；双端 soft g05＋L2 **5／5** @ `49b867a63`）· **verify-selfhost-stage2 0-make ✅**（死 `make`→`bootstrap_driver_seed`／`build_seed_asm_host`／`ensure_host_cc_seed_o`；截断 `cc -o` 撤；`build_xlang_asm` 文案→`bootstrap_driver_*.sh`；双端 soft g05＋L2 **5／5** @ `7eaead5d6`）· **experimental／strict 考古 0-make ✅**（死 MF-gated `make`→`try-heat`／`migrate_x_objs`／`driver_leaf`／`g05 --no-sync`；`ensure_parser` 无 MF 早退修；双端 soft g05＋L2 **5／5** @ `a662586f5`）· **seed／g05／strict_glue 考古 0-make ✅**（死 `make`→`clean_compiler`＋`bootstrap_driver_seed`／`bootstrap_driver_bstrict`／`legacy_xlang_c_link`／`try-heat pipeline_x`；双端 soft g05＋L2 **5／5** @ `a75e9f76b`）· **capture／link_abi_only 考古 0-make ✅**（死 `make`→`ensure try-r3-cold`／`try-labi-prefer`／`try-r1`／`legacy_xlang_c_link`；双端 soft g05＋L2 **5／5** @ `ede1ccde2`）· **asm_seed_full -E 失败恢复阶梯 ✅**（pin／已有 partial／source fallback 先于陈旧 `asm_full_gen` cc；双端 L2 **0**×60 err @ `ea1ad5dac`）· **g05 stubs scan → catalog ✅**（撤硬编退役 `pipeline_glue_standalone.o`；双端 soft g05 **0** nm＋L2 **5／5** @ `1d3ced647`）· **Ubuntu tip L4 金标再核 ✅**（SHARED `_std_core_ld_r`→`pure_ld_partial_merge` @ `ce0a41772`；remaining_o=0＋矩阵 **5／5**＋process **OK**＋bstrict **129**／wall **13m39s**）· **Darwin tip L4＋process_merge ✅** · **Darwin 冷矩阵 CG002 ✅**（prefer libtool `.o` archive ≤2 员 `-force_load`；弱 stub 不再盖强 `asm_asm_codegen_elf_o`）· **sat L4 身份 Ubuntu 金标 ✅**（tip `d1cc0d5dd`；PREFER=0 不盖 prefer；labi≈480496／pabi≈1746928）· **fmt 冷 egg auto host-C／g05 stage2 ✅** · **Darwin filter `-arch`＋ar ✅** · **ALLOW ensure 再瘦库存空 ✅**（无 path-nonempty always-push sit-red）· **Darwin `__common` align 软警 ✅**（Mach-O COMMON `n_desc` GET_COMM_ALIGN；fmt 4MiB paths）· **fmt pure-asm format ✅** · **dest extras dest-PTR stamp ✅**（嵌套 extra lit CG002→7）· **Darwin ld minos 26 vs 11 ✅**（host-cc `-mmacosx-version-min=11.0` 对齐 `macho.x`；hello `-o` 三行警告消）· 钉盘仍 **`e8176cbe5`** · leftover unique UNDEF 产品 `-o`（cli／csv／http／vec／io stubs／labi 针／g9／g14／g15／g21／g22／need_sys／heap_api／g0 string／std.bytes g23／std.datetime fk0 k20／std.db.sqlite fk10／std.net need_net ensure／**std.db.kv／arrow formal_mod**／**std.async formal_mod c_face**）已闭 · leftover unique UNDEF 扫描类已空 · nest 64 冻帽 · dest leftover 族续 · **leftover extra peels PARAM PTR-elem ndims≥1 `**[2][]T`／`**[2]*T` leftover mismatch T001 ✅**（`dyn_add_ptr_ptr_arr_slice.x`／`dyn_add_ptr_ptr_arr_ptr.x` 双端 extra ADDR_OF of typed dest／host-C **7** · leftover mismatch T001） · **dest extras dest-PARAM extra STAR PTR-elem ndims＝0 `***T` dest-stamp ✅**（`dyn_add_ptr_ptr_ptr.x` 双端 extra ADDR_OF of typed dest／host-C **7**） · **dest extras dest-PARAM extra empty `[]` PTR-elem ndims＝0 `**[]T` dest-stamp ✅**（`dyn_add_ptr_ptr_slice.x` 双端 extra ADDR_OF of typed dest／host-C **7**） · **dest extras dest-RET extra empty `[]` PTR-elem ndims＝0 `**[]T` dest-stamp ✅**（`dyn_ret_ptr_ptr_slice.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra STAR PTR-elem ndims＝0 `***T` dest-stamp ✅**（`dyn_ret_ptr_ptr_ptr.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra STAR SLICE-elem ndims＝−2 `*[][]*T` dest-stamp ✅**（`dyn_ret_ptr_slice_slice_ptr.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra STAR SLICE-elem ndims＝0 `*[]*T` dest-stamp ✅**（`dyn_ret_ptr_slice_ptr.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra STAR SLICE-elem `*[][2]*T` dest-stamp ✅**（`dyn_ret_ptr_slice_arr_ptr.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra empty `[]` SLICE-elem `*[][2][]T` dest-stamp ✅**（`dyn_ret_ptr_slice_arr_slice.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra empty `[]` PTR-elem `**[2][]T` dest-stamp ✅**（`dyn_ret_ptr_ptr_arr_slice.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra STAR PTR-elem `**[2]*T` dest-stamp ✅**（`dyn_ret_ptr_ptr_arr_ptr.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET extra STAR `*[2]*T` dest-stamp ✅**（`dyn_ret_ptr_arr_ptr.x` 双端 assign-only／host-C **7**） · **dest extras dest-RET PTR-to-ARRAY extra empty `[]` `*[2][]T` dest-stamp ✅**（`dyn_ret_ptr_arr_slice.x` 双端 assign-only／host-C **7**） · **PTR-outer extra empty `[]` `*[][2][]T` dest-stamp ✅**（`dyn_add_ptr_slice_arr_slice.x` 双端 asm／host-C **7**） · **PTR-outer extra STAR `*[][2]*T` dest-stamp ✅**（`dyn_add_ptr_slice_arr_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of PTR extra empty `[]` `[2]*[2][]T` dest-stamp ✅**（`dyn_add_arr_ptr_arr_slice.x` 双端 asm／host-C **6**） · **PTR-elem＋PTR-outer extra empty `[]` `**[2][]T` dest-stamp ✅**（`dyn_add_ptr_ptr_arr_slice.x` 双端 asm／host-C **7**） · **PTR-elem＋PTR-outer extra `**[2]*T` dest-stamp ✅**（`dyn_add_ptr_ptr_arr_ptr.x` 双端 asm／host-C **7**） · **PTR-outer extra wrap extra PTR `*[2][]*T` dest-stamp ✅**（`dyn_add_ptr_arr_slice_ptr.x` 双端 asm／host-C **7**） · **PTR-outer extra `*[2]*T` dest-stamp ✅**（`dyn_add_ptr_arr_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of PTR extra `[2]*[2]*T` dest-stamp ✅**（`dyn_add_arr_ptr_arr_ptr.x` 双端 asm／host-C **6**） · **dest extras dest-SLICE of SLICE extra wrap `[][][2][]T` dest-stamp ✅**（`dyn_add_slice_slice_arr_slice.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of SLICE extra wrap extra `[2][][2][][]T` dest-stamp ✅**（`dyn_add_arr_slice_arr_slice_slice.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of SLICE extra wrap `[2][][2][]T` dest-stamp ✅**（`dyn_add_arr_slice_arr_slice.x` 双端 asm／host-C **7**） · **dest extras dest-SLICE of PTR extra `[]*[2]*T` dest-stamp ✅**（`dyn_add_slice_ptr_arr_ptr.x` 双端 asm／host-C **7**） · **Ubuntu pipeline_abi thin inject first-wins ✅**（ELF `$CC -r -Wl,--allow-multiple-definition` · reent／arrcopy inject **OK** · 单 T · 双端矩阵 **5/5**） · **Darwin prefer hybrid merge ✅**（labi prefer **473640** · 假 clang **clang_hits=0** · 双端矩阵 **5/5**） · **Linux hosted 产品 `-o` ld-only ✅**（假 gcc **clang_hits=0** · argv[0]＝`ld` · 双端矩阵 **5/5**） · **Darwin 产品 `-o` ld-only ✅**（假 clang **clang_hits=0** · 双端矩阵 **5/5**） · **host-C `[][2][]T` 嵌套 GNU static ✅**（`dyn_add_slice_arr_slice.x` 双端真 host-C／asm **7**） · **host-C `[2]*[2]i32` INDEX ✅**（`dyn_add_arr_ptr_arr.x` 双端真 host-C／asm **6**） · **host-C suffix NAMED／PTR／SLICE ✅**（`dyn_add_named.x`／`dyn_add_ptr.x`／`dyn_add_slice.x` 双端真 host-C／asm **7**） · **w189 *T param home／PTR-outer `*[N][]T` ✅**（`dyn_add_ptr.x`／`dyn_add_ptr_arr_slice.x` 双端 asm／host-C **7**）；**dest extras dest-PTR stamp ✅**（`dyn_add_ptr_arr_slice_lit.x` nested `&[[2],[4]]` CG002→**7**） · **dest extras dest-SLICE of ARRAY extra `[][2][]*T` dest-stamp ✅**（`dyn_add_slice_arr_slice_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-SLICE of SLICE extra `[][][2]*T` dest-stamp ✅**（`dyn_add_slice_slice_arr_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of SLICE extra `[2][][2]*T` dest-stamp ✅**（`dyn_add_arr_slice_arr_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of SLICE extra `[2][][]*T` dest-stamp ✅**（`dyn_add_arr_slice_slice_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-SLICE of PTR extra `[]*[2][]T` dest-stamp ✅**（`dyn_add_slice_ptr_arr_slice.x` 双端 asm／host-C **7**） · **dest extras dest-SLICE of SLICE extra `[][][]*T` dest-stamp ✅**（`dyn_add_slice_slice_slice_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-SLICE of SLICE extra `[][][2]T` dest-stamp＋布局 ✅**（`dyn_add_slice_slice_arr.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of SLICE extra `[2][][2]T` dest-stamp ✅**（`dyn_add_arr_slice_arr.x` 双端 asm／host-C **7**） · **dest extras dest-SLICE of SLICE extra `[][]*T` dest-stamp ✅**（`dyn_add_slice_slice_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of SLICE extra `[2][]*T` dest-stamp ✅**（`dyn_add_arr_slice_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of ARRAY extra `[2][2][]T` flatten ✅**（`dyn_add_arr_arr_slice.x` 双端 asm／host-C **8**） · **dest extras dest-SLICE of ARRAY extra `[][2]*T` dest-stamp ✅**（`dyn_add_slice_arr_ptr.x` 双端 asm／host-C **7**） · **dest extras dest-SLICE of ARRAY extra `[][2][]T` dest-stamp ✅**（`dyn_add_slice_arr_slice.x` 双端 asm／host-C **7**） · **dest extras dest-ARRAY of SLICE `[2][][]T` dest-stamp ✅**（`dyn_add_arr_slice_slice.x` 双端 asm／host-C **6**） · **dest extras dest-ARRAY of PTR `[2]*[][]T` dest-stamp ✅**（`dyn_add_arr_ptr_slice_slice.x` 双端 asm／host-C **6**） · **dest extras dest-SLICE of PTR `[]*[][]T` dest-stamp ✅**（`dyn_add_slice_ptr_slice_slice.x` 双端 asm／host-C **7**） · **dest-SLICE extra `[][][][]T` dest-stamp ✅**（`dyn_add_slice_slice_slice_slice.x` 双端 asm／host-C **7**） · **dest-SLICE extra `[][][]T` dest-stamp ✅**（`dyn_add_slice_slice_slice.x` 双端 asm／host-C **7**） · **类型位只留 trait 名一条路径 ✅**（`let x: Clone = a`；`dyn Trait` **P013**；`dyn_type_implicit.x` asm／host-C **7**） · g05／ensure parser 冷路径 **pin-first** · **4.2.2 pin-seed 体方法 resolve 闭** · **impl for Type 探针恢复** · **pin-seed `[N]T→[]T` typeck 双权威闭**（ret／asg **42**）· **pin-seed STRUCT_LIT nest dest-stamp 双权威闭**（host-C 无 `(struct )`）· **4.2.4 bare ret-only／phantom／bound n_tp=0 闭** · **4.2.5 multi mono 闭** · **4.2.7 nested reent 闭** · **TYPE_DYN／vtable F1–F6 ✅** · **F7 asm dyn dispatch ✅** · **check_only 512B COMMON 误指 ✅** · **F7 邻域 builtin for-type coerce ✅** · **F7 带参 dispatch ✅** · **host-C wrapper 转发 extras ✅** · **F7 x86 SSE extras ✅** · **F7 f32 FLOAT_LIT stamp ✅** · **host-C f32 调用点类型化 ✅** · **F7 dyn stack extras ✅** · **host-C nparams>6 ✅**（`dyn_add_stack.x` 双端 host-C／asm **7**；wrapper rdi＝data 未改）· **ARM64 wrapper x0 拷栈 ✅**（`dyn_add_stack8.x` 双端 asm／host-C **7**；sit-red Darwin run＝5）· **skip-trait 前缀 `[N]T` extra ✅**（`dyn_add_arr1.x` 双端 asm／host-C **7**；sit-red T001 impl match）· **host-C `[K][N]T` extra ✅**（`dyn_add_arr2.x` 双端 asm／host-C **11**；sit-red host-C **219**）· **dyn `[]i32` ARRAY_LIT extra ✅**（`dyn_add_slice.x` 双端 asm／host-C **7**；sit-red asm **1**／host-C **139**）· **host-C ret `[2]i32`／`[]i32` ✅**（`dyn_ret_arr.x`／`dyn_ret_slice.x` 双端 asm／host-C **7**；sit-red host-C **XP003**）· **host-C dyn ret NAMED／`*i32` ✅**（`dyn_ret_named.x`／`dyn_ret_ptr.x` 双端 asm／host-C **7**；sit-red host-C void-cast）· **dyn NAMED extra STRUCT_LIT ✅**（`dyn_add_named.x` 双端 asm／host-C **7**；sit-red host-C `(struct )`／asm **162**）· **dyn ret NAMED 叶子 `*T`／`[]T`／`[N]T` ✅**（`dyn_ret_ptr_named.x`／`dyn_ret_slice_named.x` 双端 asm／host-C **7** · `dyn_ret_arr_named.x` **5**；sit-red host-C void-cast）· **dyn `[]Pair` extra dest-stamp ✅**（`dyn_add_slice_named.x` 双端 asm／host-C **7**；sit-red asm **139**／host-C `(uint8_t[]){(struct )}`）· **dyn ret `[K][N]T` ndims ✅**（`dyn_ret_arr2.x` 双端 compile **0**；sit-red XT001 expected `[2][2]i32` found `[2]i32`）· **host-C `[K][N]T` ret emit ✅**（`dyn_ret_arr2.x` 双端 host-C **10**；sit-red Ubuntu `int32_t **` 类型错／mac 假绿 10）· **asm dest `[K][N]T` 拷贝 ✅**（`dyn_ret_arr2.x` 双端 asm／host-C **10**；sit-red run＝3 具名局部同）· **dest-ARRAY `[2]Pair` extra dest-stamp ✅**（`dyn_add_arr_named.x` 双端 asm／host-C **7**；sit-red host-C `(uint8_t[]){(struct )}`）· **UFCS extras dest-ARRAY／dest-SLICE STRUCT_LIT dest-stamp ✅**（`ufcs_add_arr_named.x`／`ufcs_add_slice_named.x` 双端 asm／host-C **7**；sit-red `(struct )`／asm run＝3）· **dest-SLICE extra `[][2]i32` dest-stamp ✅**（`dyn_add_slice_arr.x` 双端 asm／host-C **7**；sit-red asm **1**／host-C **139**）· **dest-ARRAY extra `[2][]i32` dest-stamp ✅**（`dyn_add_arr_slice.x` 双端 asm／host-C **7**；sit-red asm **139**／host-C **133**）· **dyn ret `*[2]i32` dest-stamp ✅**（`dyn_ret_ptr_arr.x` 双端 asm／host-C **7**；sit-red host-C void-cast／`int32_t (*)[2] getpa`）· **host-C `[]*i32` type_to_c_repr 标签 ✅**（`slice_of_ptr_let.x` 双端 asm／host-C **7**；sit-red `struct xlang_slice_int32_t *`）· **dest-SLICE extra `[]*i32` dest-stamp ✅**（`dyn_add_slice_ptr.x` Ubuntu asm／host-C **7** · mac host-C **7**；sit-red host-C **133**；mac asm INDEX 仍 CG002）· **asm binop `unsafe { e }` peel ✅**（`dyn_add_slice_ptr.x` 双端 asm／host-C **7** · 具名 `x + unsafe { *q }` **3** · `[2]*i32` 双 DEREF **7**；sit-red mac ARM64 CG002）· **dest-ARRAY extra `[2][]Pair` dest-stamp ✅**（`dyn_add_arr_slice_named.x` 双端 asm／host-C **7**；sit-red dyn extra **139**／`(uint8_t[]){(struct )}`）· **dest-SLICE extra `[][2]Pair` dest-stamp＋布局 ✅**（`dyn_add_slice_arr_named.x` 双端 asm／host-C **7**；sit-red dyn extra **139**／host-C BLD001）· **dest-SLICE extra `[]*Pair` dest-stamp ✅**（`dyn_add_slice_ptr_named.x` 双端 asm／host-C **7**；sit-red dyn extra **139**／host-C panic）· **dest-SLICE extra `[][]i32`／`[][]Pair` dest-stamp ✅**（`dyn_add_slice_slice.x`／`dyn_add_slice_slice_named.x` 双端 asm／host-C **7**；sit-red dyn extra **139**／`(uint8_t[]){(uint8_t[]){(struct )}}`）· **dest ret `*[2]Pair` dest-stamp ✅**（`dyn_ret_ptr_arr_named.x` 双端 asm／host-C **7**；sit-red Ubuntu void-cast／mac 假绿 7）· **dest-SLICE extra `[]*[N]T` dest-stamp＋emit ✅**（`dyn_add_slice_ptr_arr.x` 双端 asm／host-C **7**；sit-red dyn typeck `expected *i32, found *[2]i32`／具名 host-C BLD001）· **dest-SLICE extra `[]*[]i32` dest-stamp ✅**（`dyn_add_slice_ptr_slice.x` 双端 host-C **7** · mac asm **7**；sit-red skip-trait elem_kind＝−1／dyn INDEX **139**／**134**；Ubuntu asm INDEX 仍 **134** 另债）· 只改勾选与事实，无波次流水  

> **审计补全**：2026-07-29（对照仓库实况：非 gen 产品 C / 零 cc 三义 / G-05·build.x 半路径 / Makefile 删除关键路径）  
> **终局目标**（**用户硬指标**）：**去掉 Makefile** 为主闸门，并收口 **零 cc/gcc/clang + v2==v3**。  
>   即：日常与冷启动编排 **不再依赖 `make` / `compiler/Makefile` / 顶层 `Makefile`**；编译器自举链与产品默认路径 **不再 exec 外部 C 编译器**。  
> **用途**：全面列出 C 逻辑迁移到 .X 的所有步骤，按自举顺序排列。  
> **状态标记（唯一进度记法）**：  
> - ⬜ 未开始  
> - 🟡 **进行中**（做到哪一项就把哪一项标黄）  
> - ✅ **已完成**（该项做完直接打绿勾）  
> **路线**：路线 A（纯 .x + 内建能力重写）— 详见「路线选择」章节。  
> **方法**：[自举方法.md](自举方法.md)（Cap / R / L / M）+ Track L2（语言能力）+ Track X（xbuild）+ Track C0（冷启动零 cc）+ Track MG（Makefile 退役）  
> **进度数字 / 波次流水**：[自举进度.md](自举进度.md) · skill `xlang-selfhost-product-gate` · Makefile 映射：[Makefile迁移表.md](Makefile迁移表.md)  
> **先→后时序（换 IDE）**：[自举时序.md](自举时序.md)（执行序 S0–S8；与本文阶段号对照见时序 §5）  
> **维护约定（强制）**：  
> 1. 本文 **只** 维护 **待办勾选 / 状态表 / 债地图**（✅ / 🟡 / ⬜ + 必要事实：路径、LOC、验收条件）。  
> 2. **禁止** 在本文写波次号、波次 changelog、「waveN 做了 X」流水账。  
> 3. 波次叙事、tip SHA 演进、commit 序列 **只写 [自举进度.md](自举进度.md)**。  
> 4. 做到某一项 → 标 🟡；该项完成 → 改 ✅；不要追加「完成波次」段落。  
> **权威钉盘**（与 [自举进度.md](自举进度.md) 同步）：**`e8176cbe5`**（产品 L4 放行；MG 物理删 Makefile 仍有效；前 `f7424ae47` · `e364f4a37` · `d79a368b2`；2026-08-23 双端 L4＋bstrict 129 升钉）。

---

## 0. 总览仪表盘

| 维度 | 状态 | 数据 |
|------|------|------|
| **库层（std+core）.x 化** | ✅ 100% | 178 文件 / 75,007 行 .x · 0 行 .c |
| **Thin 退役（T）** | ✅ 18/18 | 18 号结案 |
| **Prove 注册（N）** | ✅ 111/111 IDENTICAL | MODULES 数组实际 128 条（17 条后期新增未计入 KPI） |
| **R2 真迁退役** | 🟡 ~85% | 128 prove 模块中 ~120 已 R2；Cap residual 待消灭 ~8 模块 |
| **Mega 拆分（M1-M3）** | ✅ 3/3 mega 拆分完成 | runtime 24/24 · parser 21/21 · link_abi 11/11 切片 |
| **Mega 去 pin（M4）** | ✅ **5/5** | runtime monofile **物理退役 ✅**（7.1.1）；**typeck 冷链关 pin ✅**（7.4.1）；**codegen 冷链关 pin ✅**（7.4.2 · `.x` assemble）；**parser 冷链关 pin ✅**（7.2.2 · 默认 FROM_X=1）；**link_abi 冷链关 pin ✅**（7.3.1 · 默认 FROM_X=1；12 labi_*.x 切片）。五域冷链全闭。 |
| **Pinned gen.c 退役** | ✅ **⭐ 30/30 FULLY CLOSED** | Track L 退役 **23/23 PRODUCT RETIRED = 100%**（wave327-332 Batch3 全闭）：wave1035 前 13 + wave327 lsp_diag_gen+lsp_gen + wave328 pipeline_gen+driver_gen+preprocess_gen+lexer_gen + wave329 parser+typeck+codegen（cold-seed rung）+ wave331 ast_gen2（cold-seed pin）。NON_PRODUCT 7 正确分类（wave332 `is_product_denominator()` 单权威）：TEST×2 + STAGE×2 + EXTRACT_ONLY×1 + DELETED_ORPHAN×2。HALF=0；PINNED 产品=0。 |
| **非 gen 产品 C（glue/ast 池）** | 🟢 | 阶段 8.3 **结构／域 map 收口**（**2026-08-08 wave309**）：glue 壳／typedefs／9×fwd／standalone **deleted**；product pure-ld **无** pipeline mega。**bc-inventory 诚实**：present residual product C rows **0**（ROWS=128）；`./xbuild bc-inventory --check` 绿。**pipeline.x residual** leave ✅。**8.3.1～8.3.7 结构／域 leave ✅**；**8.3.6 🟡** 仅全表 from_x 退役策略仍 ⬜；**8.3.8／8.3.10 ⬜**；**8.3.9 ✅**。日常 L2 矩阵 G.7 单权威 `./xbuild l2-matrix`。**BC 终局（零 host-cc 编编译器）仍 ⬜**（gen／runtime seed 等在 8.3 图外） |
| **Cap 能力解锁** | 🟡 | 4.2.1–4.2.3／dest-SLICE 族／dest-in-rbx 族／INDEX dest ARRAY_LIT／runtime-index dest ARRAY_LIT／INDEX dest ARRAY_LIT 非 VAR 基／FIELD dest ARRAY_LIT／dest-in-rbx ARRAY_LIT of ARRAY_LIT／dest-in-rbx ARRAY_LIT n>1／dest-in-rbx STRUCT_LIT 场 ARRAY_LIT／STRUCT_LIT 场 ARRAY_LIT 嵌套 STRUCT_LIT／dest-in-rbx CALL／dest-in-rbx ARRAY_LIT of CALL／dest-in-rbx IF／IF dest 双臂 STRUCT_LIT（帧 dest）／dest-in-rbx IF of STRUCT_LIT／dest-in-rbx IF of ARRAY_LIT／dest-in-rbx IF extra arm stmts／dest-in-rbx IF extra arm loops／dest-in-rbx IF extra arm region／dest-in-rbx IF dest wrapped in unsafe／dest-in-rbx IF extra arm labeled／dest-in-rbx MATCH／dest-in-rbx IF of MATCH／dest-in-rbx MATCH field-bind／帧 dest 16B MATCH field-bind／大 main 后段 let dest 名空／匿名 match／匿名 enum／裸 enum／nest 17–64（**冻帽 64**）／SIMD dest／METHOD binop2／STRUCT_LIT dest／dest extra-arm 末尾 `{ fields }` host-C **已闭**／dest extra-arm `unsafe {…}; dest` ASI **已闭**／dest extra-arm `region {…}; dest` ASI **已闭**／parse_into 函数体 `region {}; return` 同模式 ASI **已闭**／with_arena extra-arm dest typeck 逃逸 **已闭**／dest extra-arm SIMD Wrap dest-in-rbx＋with_arena emit **已闭**／dest extra-arm SIMD host-C `-E` 头 `i32x4_t` **已闭**／dest extra-arm SIMD 叠 MATCH＋IF＋field-bind＋无分号 `with_arena` dest **已闭**／dest extra-arm `defer { k=1 }; dest` emit **已闭**／dest extra-arm extra wrap `{ { let t; dest } }` host-C **已闭**／dest-from-region dest-region-body defer **已闭**／dest-from-region intermediate-region defer **已闭**（asm leftover 54）／host-C dest-from-region intermediate stmt-expr 末值 **已闭**／host-C dest-from-region 叠中间层 last-wins **已闭**／host-C dest-from-region wrapping＋dest-region-body last-wins **已闭**／dest wrap IF dest **已闭**。 **开项**：~~TYPE_DYN 后期~~ → ✅（F1–F6 闭）· F7 asm dyn dispatch ✅ · **check_only 512B COMMON 误指 ✅** · **F7 邻域 builtin coerce ✅** · **F7 带参 dispatch ✅** · **host-C wrapper extras ✅** · **F7 x86 SSE extras ✅** · **F7 f32 FLOAT_LIT stamp ✅** · **host-C f32 调用点类型化 ✅**（`dyn_add_f32.x` 双端 host-C／asm **7**）· **F7 dyn stack extras ✅** · **host-C nparams>6 ✅**（`dyn_add_stack.x` 双端 host-C／asm **7**）· **ARM64 wrapper x0 拷栈 ✅**（`dyn_add_stack8.x` 双端 asm／host-C **7**）· **skip-trait 前缀 `[N]T` extra ✅**（`dyn_add_arr1.x` 双端 asm／host-C **7**）· **host-C `[K][N]T` extra ✅**（`dyn_add_arr2.x` 双端 asm／host-C **11**）· **dyn `[]i32` ARRAY_LIT extra ✅**（`dyn_add_slice.x` 双端 asm／host-C **7**）· **host-C ret `[2]i32`／`[]i32` ✅**（`dyn_ret_arr.x`／`dyn_ret_slice.x` 双端 asm／host-C **7**）· **host-C dyn ret NAMED／`*i32` ✅**（`dyn_ret_named.x`／`dyn_ret_ptr.x` 双端 asm／host-C **7**）· **dyn NAMED extra STRUCT_LIT ✅**（`dyn_add_named.x` 双端 asm／host-C **7**）· **dyn ret NAMED 叶子 `*T`／`[]T`／`[N]T` ✅**（`dyn_ret_ptr_named.x`／`dyn_ret_slice_named.x` 双端 asm／host-C **7** · `dyn_ret_arr_named.x` **5**）· **dyn `[]Pair` extra dest-stamp ✅**（`dyn_add_slice_named.x` 双端 asm／host-C **7**）· **dyn ret `[K][N]T` ndims ✅**（`dyn_ret_arr2.x` 双端 compile **0**）· **host-C `[K][N]T` ret emit ✅**（`dyn_ret_arr2.x` 双端 host-C **10**）· **asm dest `[K][N]T` 拷贝 ✅**（`dyn_ret_arr2.x` 双端 asm／host-C **10**）· **dest-ARRAY `[2]Pair` extra dest-stamp ✅**（`dyn_add_arr_named.x` 双端 asm／host-C **7**）· **UFCS extras dest-ARRAY／dest-SLICE STRUCT_LIT dest-stamp ✅**（`ufcs_add_arr_named.x`／`ufcs_add_slice_named.x` 双端 asm／host-C **7**）· **dest-SLICE extra `[][2]i32` dest-stamp ✅**（`dyn_add_slice_arr.x` 双端 asm／host-C **7**）· **dest-ARRAY extra `[2][]i32` dest-stamp ✅**（`dyn_add_arr_slice.x` 双端 asm／host-C **7**）· **host-C `[]*i32` type_to_c_repr 标签 ✅**（`slice_of_ptr_let.x` 双端 asm／host-C **7**）· **dest-SLICE extra `[]*i32` dest-stamp ✅**（`dyn_add_slice_ptr.x` Ubuntu asm／host-C **7** · mac host-C **7**）· **asm binop `unsafe { e }` peel ✅**（`dyn_add_slice_ptr.x` 双端 asm／host-C **7**）· **dest-ARRAY extra `[2][]Pair` dest-stamp ✅**（`dyn_add_arr_slice_named.x` 双端 asm／host-C **7**）· **dest-SLICE extra `[][2]Pair` dest-stamp＋布局 ✅**（`dyn_add_slice_arr_named.x` 双端 asm／host-C **7**）· **dest-SLICE extra `[]*Pair` dest-stamp ✅**（`dyn_add_slice_ptr_named.x` 双端 asm／host-C **7**）· **dest-SLICE extra `[][]i32`／`[][]Pair` dest-stamp ✅**（`dyn_add_slice_slice.x`／`dyn_add_slice_slice_named.x` 双端 asm／host-C **7**）· **dest ret `*[2]Pair` dest-stamp ✅**（`dyn_ret_ptr_arr_named.x` 双端 asm／host-C **7**）· **dest-SLICE extra `[]*[N]T` dest-stamp＋emit ✅**（`dyn_add_slice_ptr_arr.x` 双端 asm／host-C **7**）· **w189 *T param home／PTR-outer `*[N][]T` ✅**（`dyn_add_ptr.x`／`dyn_add_ptr_arr_slice.x` 双端 asm／host-C **7**）；**host-C suffix NAMED／PTR／SLICE ✅**（`dyn_add_named.x`／`dyn_add_ptr.x`／`dyn_add_slice.x` 双端真 host-C／asm **7**）；**4.2.4 闭**；4.2.5／**4.2.7 已闭**；full12 装产品链须点名＋Ubuntu。dest extra-arm 末尾 `{ fields }` host-C **已闭**。dest extra-arm `unsafe {…}; dest` ASI **已闭**。dest extra-arm `region {…}; dest` ASI **已闭**。L0 `-E` getcwd **已闭**。emit_header `h[88]` 超额初始化 **已闭**（`u8[83]`）。sat 盖 prefer **已开路由**（`try-r1` → `ensure_labi_prefer_one`；sat 形态 427280 Darwin 5/5；mega 318600 活身份）。ARM64 prologue **已存 x19**；param_home **已跳过 x19 槽**。 **禁** try_inline mega／`enc_add_rax_rbx` 64 位／`enc_store_rax_to_rbx_offset` /8／本叶抬 nest 65／全量 assemble parser.x |
| **产品 L4 放行** | ✅ 钉盘／🟡 tip | 钉盘 **`e8176cbe5`**（2026-08-23 升钉 · 前 `f7424ae47` · `e364f4a37`）· Makefile 物理删除 + 双端 L4 真冷 + bstrict 129（al06 入口 typeck）。tip＝钉盘 **`e8176cbe5`** |
| **Cap residual 边界消灭** | ⬜ 0/~50 | 原「永久边界」降级为「必须消灭」；按路线 A 逐个消灭 |
| **语言能力补齐（L2）** | ⬜ 0/~20 | syscall/FFI/inline asm/fnptr/va_list/线程原语 全部待补 |
| **Makefile 退役 / xbuild** | ✅ **MG 已完成** | **Makefile 已物理删除**（根 + compiler/）· bootstrap 0 make · catalog 单权威（mk/*.mk）· 阶段 11.3.1 ✅ |
| **根脚本 / tools / docker / CI 去 make+cc** | 🟡 | 11.2.5/11.4.3/11.2.3/**11.2.2** `./xbuild l4`/11.1.6/11.3/11.3.1/11.4.1/11.4.6 ✅ · 11.1.1–5/11.4.5 🟡 · 零 cc 仍 ⬜ |
| **tests/ 对照 C 处理策略** | 🟡 | 11.5.1–4 **策略已裁定**（`tests/HOST_CC_POLICY.md`）；改写 .x / 卸 cc 属阶段 12 |
| **冷启动零 cc 链** | 🟡 | **LINK 全零 cc ✅** · **`.s` COMPILE 零 cc ✅** · **stub weak `.s` ✅** · **forbid_host_cc ✅** · **STRING_LIT ✅** · **module const binop ✅** · **empty `[]`／emit／lsp_diag CG002 ✅** · **`pure_asm_x_to_o` helper ✅** · **Darwin mangling ✅** · **`rt_*` pure_asm 23/23 ✅** · **hybrid pure-asm opt-in ✅** · **`PREFER_ASM_O_ONLY` 真 L2 地图 ✅** · **i32 VAR/call-ret/binop sxtw ✅** · **call-arg 栈序 ✅** · **INDEX `**T` 双剥皮闭 ✅** · **typeck_selfhost ndef 误判闭 ✅** · **`ONLY=` IN_NO_C 含 `rt_run_asm_backend` 真 L2 5/5 ✅** · **fixed-array bounds 无 U panic ✅** · **div/mod host-E 对等无 U panic ✅** · **labi pure_asm 12/12 ✅** · **labi full12 hybrid 双端 5/5 ✅** · **labi-only pure-asm 产品默认双端 ✅**（`PREFER_ASM_O_LABI` 默认 1 · mac+Ubuntu 5/5）· **COMPILE residual pure_asm 13/13 ✅** · **L2-asm hybrid pure-asm 3/3 ✅** · **tcpu pure-asm hybrid 装链 ✅** · **ldpc pure-asm hybrid 装链 ✅**（objcopy --weaken 闭 multidef×3）· **other-l2 WEAK pure-asm hybrid 4/4 ✅**（含 fmt · seed `xlang_fmt_*` XLANG_WEAK）· **async pure-asm hybrid 3/3 双端 ✅** · **R3 pure-asm hybrid 9/9 双端 5/5**（ptr+int scale1 + opaque reject · Ubuntu pin soft recover + gold）· **rt pure-asm hybrid 双端 5/5 ✅**（call-ret harvest · ONLY=rcp＋full multi-slice · Ubuntu 金标 @ `3ad10a0ae`）· **B1／B2／B3 pure-asm hybrid 双端 5/5 ✅** · **SEED_SLICE 不并 no_c** · **prefer 族 pure-asm 产品默认 ✅**（LABI/RT/G05）· **树级 PREFER 硬闸 strip ✅**（无 `ALLOW_TREE` 则 strip ambient · family=0 关泄漏）· **ALLOW_TREE 地图 bisect ✅**（full hybrid／re-leak 双端 5/5 · 拒默认化）· 最小 seed ⬜ · COMPILE residual 仍需 `$CC`（pipeline_abi mega 等） |
| **终局：无 Makefile + 零 cc + v2==v3** | 🟡 | MG ✅ · BC 🟡 · PC 🟡（去 import→C／FORBID／ALLOW ✅；Darwin 产品 `-o` ld-only ✅；Linux hosted 产品 `-o` ld-only ✅；Ubuntu pipeline_abi thin inject first-wins ✅）；见 §0.1 三义；阶段 13 |

### 0.1 终局三义（禁止混谈「零 cc」）

去掉 Makefile 与「零 cc」常被混为一谈。**自举终局须同时满足下列三层**（缺一层仍不能宣称终局）：

| 层 | 含义 | 今日状态 | 失败时的假绿 |
|----|------|----------|--------------|
| **MG · 编排层** | 不依赖 `make` / `compiler/Makefile` / 顶层 `Makefile` 完成 build / L4 / bootstrap | ✅ Makefile 物理删除 · bootstrap 0 make · catalog 单权威（mk/*.mk）· 双端 L4 绿 | 只删入口 Makefile、实现层仍 `make -C compiler` |
| **BC · 自举编译层** | 编译器自身 TU **不**再被 host `cc/gcc/clang` 编译（.x→纯 asm `.o` 或等价） | 🟡 已开（inventory 冻结；**glue 叶已 fold、ast_pool 续迁**；`pipeline_x` 仍 host-cc mega-TU） | seed 用 xlang `-E` 出 C 再交给 gcc |
| **PC · 产品默认后端** | 用户程序默认 **`-backend asm`**（或纯自研目标）；**不**默认 emit C 再 `exec` host-cc；`labi_invoke_cc*` 退役或仅 opt-in | 🟡 **去 import→C ✅** · **seed `__APPLE__` exe→C ✅** · **`Result_*` 短名 ✅** · **Arena64 shell 死别名 ✅** · **formal 短标签 residual 扫描关 ✅** · **静默 generic→C 移除 ✅** · **`FORBID_HOST_CC` ✅** · **`ALLOW_HOST_CC` experimental 默认拒 ✅** · **`invoke_cc_host_cc_spawn_gate` 入口早闸 ✅** · **impl 顶闸 isolate ensure／argv ✅** · **Darwin 产品 `-o` ld-only ✅**（禁 clang driver） · **Linux hosted 产品 `-o` ld-only ✅**（禁 gcc driver） · **Ubuntu pipeline_abi thin inject first-wins ✅** | 显式 `-backend c` + ALLOW=1 仍可调 gcc；BC 编编译器仍 host-cc COMPILE |

> **用户主目标对齐**：以 **去掉 Makefile（MG）** 为终局叙事主闸门；MG 物理删除的**前置**是 BC 足够小（glue/gen 可被 xbuild 用 xlang 编）且编排逻辑迁到 xbuild / g05 已覆盖的 shell·.x。  
> **禁止**：只完成 MG 包装层、底层仍 `make`；或只宣称 v2==v3 而 Makefile 仍是冷启动权威。

### 0.2 删 Makefile 关键路径（依赖 DAG · 顺序不可跳）

```text
[阶段 10 语言能力 L2] ──► [阶段 9 residual 消灭] ──┐
                                                    ├─► [阶段 8.3 glue/ast 池 .x 化]
[阶段 7 M4 mega 去 pin] ──► [阶段 8 gen.c 退役] ───┤
                                                    ├─► [阶段 11.0–11.2 xbuild 吃掉 Makefile 规则]
[现有 G-05 / build.x / xlang-build.sh] ────────────┘
                                                    │
                                                    ▼
                              [11.3 物理删 Makefile] + [12 冷启动零 cc] + [13 v2==v3]
```

| 顺序陷阱 | 说明 |
|----------|------|
| 先删 Makefile、glue 仍 40k C | xbuild 只能 `cc -c pipeline_glue.c` → **BC 未满足** |
| 先写满 xbuild、仍 pin seed | 编排绿但双权威 / 冷启动仍读 `*_gen.c` |
| 只迁顶层 Makefile | 根 `Makefile` 已是薄包装；**真正权威在 `compiler/Makefile`** |
| 忽略 tests/CI `make` | 产品入口无 make，gate 脚本仍 make → 终局叙事假绿 |

---

## 阶段 0：基建与方法论（已完成）

✅ **0.1 自举方法论确立**（Cap/R/L/M 四轨）2026-07-14

✅ **0.2 工程轨 vs 产品轨分清**（禁止工程轨绿当自举完成）2026-07-15

✅ **0.3 日常真测 vs 真冷全测节奏**（L2/L3 日常 · L4 整波收口）2026-07-16

✅ **0.3b 每步自举先 `xlang check` 再 L2**（skill §3.3.0 · 自举验证 §4.0）2026-08-04

✅ **0.4 双端验证纪律**（macOS 开发 + Ubuntu 金标）

✅ **0.5 git 锚点机制**（每波前建 tag，可秒级回退）

✅ **0.6 产品闸门 skill**（`xlang-selfhost-product-gate`）


---

## 阶段 1：库层 .X 化（已完成 · 100%）

### 1.1 std/ 标准库

✅ **1.1.1 std/ 全目录 .x 化** 166 文件 / 72,941 行 .x · 0 行 .c

✅ **1.1.2 std/io/**

✅ **1.1.3 std/fmt/**

✅ **1.1.4 std/string/**

✅ **1.1.5 std/sync/**

✅ **1.1.6 std/result/**

✅ **1.1.7 std/option/**

✅ **1.1.8 std/crypto/**

✅ **1.1.9 std/net/**

✅ **1.1.10 std/其余子目录**


### 1.2 core/ 核心库

✅ **1.2.1 core/ 全目录 .x 化** 12 文件 / 2,066 行 .x · 0 行 .c

✅ **1.2.2 core/fmt**

✅ **1.2.3 core/result**

✅ **1.2.4 core/其余**


---

## 阶段 2：Thin 退役 Track T（已完成 · 18/18）

> **定义**：hybrid 模块 thin 切片 prove IDENTICAL，构建切换至 thin.x。
> **结案**：18/18 ✅

✅ **2.1 T-001 ~ T-018 全部 thin 退役** 18 号结案

✅ **2.2 T 降为维护指标**（不占前排）


---

## 阶段 3：Prove 注册 Track N（已完成 · 111/111）

> **定义**：prove_module_selfhost.sh nm IDENTICAL 验证。
> **KPI**：N=111/111 IDENTICAL ✅（28 日 wave539–575 扩至）
> **注意**：MODULES 数组实际 128 条；17 条后期新增未计入 KPI。

### 3.1 driver 组（11 条）

✅ **3.1.1 fmt** Track L 退役

✅ **3.1.2 check** Track L 退役（archaeology）

✅ **3.1.3 test** Track L 退役（archaeology）

✅ **3.1.4 build** Track L 退役（archaeology）

✅ **3.1.5 run** Track L 退役（archaeology）

✅ **3.1.6 compile** R2 真迁（Track L 退役）

✅ **3.1.7 emit** R2 真迁（Track L 退役）

✅ **3.1.8 lsp_io_std_heap** Track L 退役叶子

✅ **3.1.9 target_cpu_flags** R2 DIRECT（wave559）

✅ **3.1.10 fmt_check_cmd** R2 mixed（wave565）

✅ **3.1.11 fmt_check** R2 thin + Cap residual pure 深迁


### 3.2 lexer 组（1 条）

✅ **3.2.1 token** prove 锁 nm 面


### 3.3 lsp 组（4 条）

✅ **3.3.1 lsp_diag_pipeline_sizes**

✅ **3.3.2 lsp_diag_stubs_no_c** R2 DIRECT（wave557）

✅ **3.3.3 lsp_diag_pipeline_ctx** R2 thin+rest（wave561）

✅ **3.3.4 lsp_io_std_heap**（见 driver 组）


### 3.4 runtime 组 — labi_* 切片（12 条，link_abi mega）

✅ **3.4.1 labi_path_pure** R2 full（L0）

✅ **3.4.2 labi_diag_pure** R2 full（L1）

✅ **3.4.3 labi_host_lit** R2 full（L2）

✅ **3.4.4 labi_path_io** R2 full（L3 · Cap: stat/realpath 🔒）

✅ **3.4.5 labi_ensure_list** R2 full（L4）

✅ **3.4.6 labi_invoke_cc_list** R2 full（L5 · Cap: getenv 🔒）

✅ **3.4.7 labi_invoke_ld_list** R2 full（L6 · Cap: spawn/ld 🔒）

✅ **3.4.8 labi_freestanding_list** R2 full（L7）

✅ **3.4.9 labi_std_list** R2 full（L8）

✅ **3.4.10 labi_ondemand_list** R2 full（L8b）

✅ **3.4.11 labi_ondemand_heavy** R2 full（L8b heavy）

✅ **3.4.12 labi_gates** R2 full（L9）


### 3.5 runtime 组 — rt_* 切片（23 条，runtime mega）

✅ **3.5.1 rt_dispatch_thin** R2 thin+rest（wave561）

✅ **3.5.2 rt_dispatch_impl** R2 full

✅ **3.5.3 rt_asm_stub** R2 full

✅ **3.5.4 rt_fmt_one** R2 full

✅ **3.5.5 rt_pipeline_elf_diag** R2 full

✅ **3.5.6 rt_run_x_emit** R2 full

✅ **3.5.7 rt_parse_diag** R2 full

✅ **3.5.8 rt_diag_errno** R2 full

✅ **3.5.9 rt_fs_open** R2 full

✅ **3.5.10 rt_arena_buf** R2 full（Cap-global-bss 🔒）

✅ **3.5.11 rt_preamble** R2 full（Cap-giant-string 🔒）

✅ **3.5.12 rt_stack** R2 full（Cap-fn-ptr 🔒）

✅ **3.5.13 rt_lib_root** R2 full

✅ **3.5.14 rt_emit_flags** R2 full

✅ **3.5.15 rt_emit_state** R2 full（Cap-global-bss 🔒）

✅ **3.5.16 rt_content** R2 full

✅ **3.5.17 rt_util** R2 full

✅ **3.5.18 rt_argv** R2 full

✅ **3.5.19 rt_entry** R2 full

✅ **3.5.20 rt_compile** R2 full

✅ **3.5.21 rt_run_exec** R2 full

✅ **3.5.22 rt_run_asm_backend** R2 full

✅ **3.5.23 rt_run_compiler_parsed** R2 full


### 3.6 asm 组 — runtime_* 切片（41 条，asm OS 桥）

✅ **3.6.1 runtime_time_os** R2 thin+rest（Cap: clock_gettime 🔒）

✅ **3.6.2 runtime_path_fast** R2 DIRECT

✅ **3.6.3 runtime_dynlib_os** R2 thin+rest（Cap: dlopen 🔒）

✅ **3.6.4 runtime_panic** R2 thin+rest

✅ **3.6.5 runtime_panic_arm64** R2 thin+rest

✅ **3.6.6 runtime_process_argv** R2 thin+rest

✅ **3.6.7 runtime_test_fn_invoke** R2 thin+rest（Cap: fnptr 🔒）

✅ **3.6.8 runtime_net_workers** R2 thin+rest（Cap: fnptr 🔒）

✅ **3.6.9 runtime_compress_zlib_glue** R2 thin+rest（Cap: zlib.h 🔒）

✅ **3.6.10 runtime_arrow_simd_glue** R2 thin+rest（Cap: SIMD 🔒）

✅ **3.6.11 runtime_random_fill** R2 thin+rest wave544（Cap: getrandom 🔒）

✅ **3.6.12 runtime_tls_mbedtls_bio** R2 thin+rest wave544（Cap: mbedtls 🔒）

✅ **3.6.13 runtime_ed25519_ref10_glue** R2 thin+rest wave544（Cap: .inc 宏 🔒）

✅ **3.6.14 runtime_net_udp_batch** R2 thin+rest wave545

✅ **3.6.15 runtime_net_sock_fast** R2 thin+rest wave545

✅ **3.6.16 runtime_net_dns_fast** R2 thin+rest wave545（Cap: getaddrinfo 🔒）

✅ **3.6.17 runtime_net_ipv6_fast** R2 thin+rest wave545

✅ **3.6.18 runtime_net_addr_fast** R2 thin+rest wave546

✅ **3.6.19 runtime_slice_glue** R2 DIRECT wave546

✅ **3.6.20 runtime_crypto_inc_glue** R2 thin+rest wave547

✅ **3.6.21 runtime_sync_lock_diag_tls** R2 mixed wave547

✅ **3.6.22 runtime_std_runtime_fast** R2 DIRECT wave548

✅ **3.6.23 runtime_atomic_glue** R2 thin+rest wave548（Cap: stdatomic 🔒）

✅ **3.6.24 runtime_asm_build** R2 thin wave549（Cap: char** argv 🔒）

✅ **3.6.25 runtime_asm_io_stubs** R2 thin+rest wave549（Cap: syscall 🔒）

✅ **3.6.26 runtime_string_fast** R2 DIRECT wave549

✅ **3.6.27 runtime_net_io_batch_fast** R2 thin+rest wave550

✅ **3.6.28 runtime_env_os** R2 thin+rest wave550（Cap: getenv 🔒）

✅ **3.6.29 runtime_http_glue** R2 mixed wave551

✅ **3.6.30 runtime_queue_contention** R2 mixed wave551（Cap: pthread 🔒）

✅ **3.6.31 runtime_backtrace_platform** R2 thin+rest wave552（Cap: execinfo 🔒）

✅ **3.6.32 runtime_sync_os** R2 thin+rest wave552（Cap: pthread 🔒）

✅ **3.6.33 runtime_channel_glue** R2 thin+rest wave553（Cap: pthread 🔒）

✅ **3.6.34 runtime_log_os** R2 mixed wave553（Cap: write 🔒）

✅ **3.6.35 runtime_scheduler_glue** R2 mixed wave554

✅ **3.6.36 runtime_process_os_glue** R2 thin+rest wave554（Cap: execve 🔒）

✅ **3.6.37 runtime_thread_glue** R2 thin+rest wave555（Cap: pthread 🔒）

✅ **3.6.38 runtime_math_libm** R2 mixed wave564（Cap: libm 🔒）

✅ **3.6.39 runtime_lsp_glue** R2 mixed wave566

✅ **3.6.40 runtime_kv_mmap_glue**（未在 prove 注册）

✅ **3.6.41 runtime_ast_glue / runtime_lexer_glue / runtime_sqlite_glue**（未在 prove 注册）


### 3.7 asm 组 — backend/simd/parser 切片

✅ **3.7.1 asm_backend_compat_stubs** R2 DIRECT wave555

✅ **3.7.2 bootstrap_nostdlib_stubs** R2 mixed wave556

✅ **3.7.3 backend_seed_mega_fallback** R2 DIRECT wave556

✅ **3.7.4 parser_asm_parse_expr_link** R2 thin+rest wave557

✅ **3.7.5 user_asm_seed_bridge** R2 mixed wave558

✅ **3.7.6 parser_asm_thin_c** R2 mixed wave560

✅ **3.7.7 simd_loop_thin** R2 mixed wave563

✅ **3.7.8 simd_enc_thin** R2 mixed wave568

✅ **3.7.9 simd_loop** R2 full

✅ **3.7.10 simd_enc** R2 full

✅ **3.7.11 backend_enc_dispatch_thin** R2 thin full wave574

✅ **3.7.12 backend_enc_dispatch** R2 full

✅ **3.7.13 backend_arch_emit_dispatch_thin** R2 mixed wave567

✅ **3.7.14 backend_arch_emit_dispatch** R2 full

✅ **3.7.15 backend_try_inline_dispatch_thin** R2 mixed wave566

✅ **3.7.16 backend_try_inline_dispatch** R2 full

✅ **3.7.17 backend_call_dispatch_thin** R2 mixed wave567

✅ **3.7.18 backend_call_dispatch** R2 full

✅ **3.7.19 backend_x86_64_enc_c** R2 mixed wave570

✅ **3.7.20 async_asm_pool** R2 full


### 3.8 src 根组（15 条）

✅ **3.8.1 runtime_io_abi** R2 full（Cap: mmap/fstat 🔒）

✅ **3.8.2 runtime_driver_diagnostic_thin** R2 thin + Cap residual pure

✅ **3.8.3 runtime_driver_abi_thin** R2 thin + pure 深迁

✅ **3.8.4 runtime_driver_strict_glue_stubs** R2 mixed wave560

✅ **3.8.5 runtime_driver_strict_glue_thin** R2 mixed wave568

✅ **3.8.6 runtime_driver_abi** R2 mixed wave569

✅ **3.8.7 diag_thin** R2 mixed wave569

✅ **3.8.8 diag** R2 mixed wave571

✅ **3.8.9 runtime** R2 mixed wave572（mega 主名）

✅ **3.8.10 runtime_link_abi** R2 mixed wave573（mega 主名）

✅ **3.8.11 runtime_pipeline_abi** R2 full wave575

✅ **3.8.12 runtime_heap_user** R2 DIRECT wave559

✅ **3.8.13 build_runtime** R2 thin+rest wave558

✅ **3.8.14 x_seed_bridge** R2 mixed wave562

✅ **3.8.15 seed_link_compat** R2 mixed wave562


### 3.9 async 组（2 条）

✅ **3.9.1 async_liveness** R2 pure + Cap residual pure

✅ **3.9.2 async_cps_codegen** R2 pure + Cap residual pure


---

## 阶段 4：Cap 能力解锁 Track Cap（进行中）

> **定义**：一类语言/编译器能力缺口，阻塞 ≥2 模块真迁。一次修，多 rest 可真迁。

### 4.1 已闭合的 Cap 波次

✅ **4.1.1 Cap-empty-str**（空串字面量 typeck/codegen）

✅ **4.1.2 Cap-string-pool**（串池 >64 封顶）

✅ **4.1.3 Cap-global-bss**（u8[N] 全局/static BSS）

✅ **4.1.4 Cap-va-reportf**（reportf / va_list **深路径子集**已闭）wave6 — **注意**：完整 va_list 语言能力仍见阶段 **10.7**；libc `vsnprintf` 桥仍见 **9.5.3/9.5.4**

✅ **4.1.5 Cap-regen-sync**（.x 改了 pin/patch 未同源）

✅ **4.1.6 Cap-fn-ptr**（函数指针类型表达）部分（driver_run_stack_esc_gate 仍 🔒）

✅ **4.1.7 Cap-giant-string**（巨型字串数据）rt_preamble

✅ **4.1.8 wave668 fs lit-left ptr cmp**（freestanding null==p / 0==p 假绿）wave669

✅ **4.1.9 wave677 bool→i32 算术提升**（binop/unary 假绿）wave677

✅ **4.1.10 wave311 i32→u64 widen**（true widen hole）

✅ **4.1.11 wave311 i32→u8 窄存储**（var init/assign/return）wave712 验证已闭

✅ **4.1.12 wave421 impl Trait for T 缺方法**（false-green）wave421

✅ **4.1.13 wave450 零值参泛型 mono**（phantom T）wave450

✅ **4.1.14 wave459 host-C aggregate as cast**（compound literal / GNU stmt-expr）wave459-462

✅ **4.1.15 wave406 dual same-call 形参别名**（callee 静态 __xlang_al）wave406

✅ **4.1.16 wave284 标识符 >63 字节 honest-fail**（sticky overflow）wave284

✅ **4.1.17 wave707-709 match struct 模式链**（field bind + lit guard + wildcard + 显式 guard）wave710 tip L4

✅ **4.1.18 wave711 freestanding match field bind**（fs asm backend 4-arm 全组合）wave711 验证已闭

✅ **4.1.19 wave698 host-C 八层 scalar / 七层 NAMED fat**（nested slice 布局）wave698

✅ **4.1.20 wave677 LANG-007 unsafe block 诊断**（*T 解引用 + extern 调用须 unsafe）


### 4.2 当前前排 Cap 待办

✅ **4.2.1 untyped `self` 形参 skip** 已收 @ **`008810f07`**

  - 产品 free／inherent `function m(self)`：**P011**（wave676 live C 已硬拒；wave493 非标准）
  - trait 默认 `function get(self): T {…}`：hoist 仅开 `parser_allow_bare_self`，commit 盖 for-type（seed ≡ skip_tl wave477）
  - parser.x 无条件豁免改为同门（防下次 assemble 假绿 skip）
  - LANG-006 标量 bool→int 保留不动

✅ **4.2.2 trait bounds / dyn Trait** dyn／impl 类型位 ✅ @ **`7bfff4e6b`**（impl 级 bound ✅ @ **`7e2e9aac9`** · struct 级 ✅ @ **`377bd8d74`** · 体方法 ✅ @ **`10bfd56f4`** · PLUS ✅ @ **`fe000ba3a`** · **pin-seed 体方法 resolve 闭** 2026-08-17）

  - 调用点 `function foo<T: Trait>` 已 T001（既有 scan+check）
  - **`T: Clone + Default` PLUS**：同 pos 多 trait 已硬查（A 缺第二／第三 trait → T001）
  - **泛型体 `T: Clone` 下 `x.clone()`**：typeck 放行；Self／T 返盖 receiver；codegen C6 调 impl（run=7 非 identity）
  - **struct 级 `Foo<T: Clone>`**：scan 认 TOKEN_STRUCT；类型位 `Foo<B>` T001；`Foo<T>` 签名跳过；PLUS 同 pos
  - **impl 级 `impl<T: Clone> Foo<T>`**：scan 认 TOKEN_IMPL；peek for-type 后同表（名=for-type）；`impl Foo<T: Clone>`／`impl<T: Clone> Clone for Foo<T>` 同 T001；`skip_one_impl` 跳过尖括号
  - **dyn／impl 类型位**：type_ref 剥 TOKEN_IMPL；类型位 trait 名 wrap TYPE_DYN（`take(x: Clone)`／let／`*Clone`／返／`impl Clone`）。**不要**写 `dyn Trait`（P013 sticky，禁 unused take 静默丢）
  - **类型位 trait 名免写 `dyn`**（2026-08-20）：已注册 skip-trait 名 `let x: Clone = a` wrap TYPE_DYN fat（G.7 单 allocator）。验收：`dyn_type_implicit.x` 双端 asm／host-C **7**
  - **去掉 `dyn` 前缀路径**（2026-08-20）：type_ref 不再 peel wrap；`dyn`＋后续类型 **P013**。验收：`dyn_type_dyn_rejected.x` compile≠0／stderr P013；implicit／type／let／ptr 仍 **7**
  - **dest-SLICE extra `[][][]T` dest-stamp**（2026-08-20）：skip-trait keep SLICE＋ndims＝−2＋impl-match extra peel＋dest extras 第三 wrap。验收：`dyn_add_slice_slice_slice.x` 双端 asm／host-C **7**
  - **pin-seed 双权威闭**（2026-08-17）：4.2.2 体方法只写 `typeck.x` 时 pin-first migrate 假红 LANG-004；seed `typeck_gen.linux` 补 `typeck_method_call_resolve_generic_bound`＋method_call 调用点（≡ typeck.x；G.7）
  - **impl for Type 探针恢复**（2026-08-17）：`6c9773729` 值位置 named STRUCT_LIT 改写误剥 `impl Trait for A {`→`for {`；33 处 tests 恢复 for-type（**非**放宽值位置 `Type{fields}`）
  - ✅ TYPE_DYN／vtable（F1–F6 全闭：TYPE_DYN 基座 → concrete coerce → vtable 间接调用 → per-impl 静态化 → PTR wrapper → builtin for-type 静态化）
  - ✅ F7 asm dyn dispatch（双端 L2）：ELF `.data`／`.rela.data`（shndx 4；r_type=200→`R_X86_64_64`）＋ x86 `lea r64,[rip+disp32]` PC32（禁 `.text` movabs）＋ x86 fat vtable home `slot_off-8`（rbp-down；ARM64 仍 `+8`）。产品叶 `backend_enc_dispatch`／`backend_call_dispatch` 走 cold seed（nm 闸）。验收：call_ok／ptr_for／multi **7／7／9** · 无 TEXTREL
  - ✅ F7 邻域 builtin for-type coerce（双端 L2）：产生点 `pipeline_asm_try_emit_dyn_coerce_let` 补 `codegen_builtin_type_name_into`（G.7 单权威，禁第二套 map）；rvalue INT_LIT emit＋`glue_sysv_spill`＋LEA；VAR LEA；wrapper rdi／x0＝data 未改。验收：`dyn_builtin.x`／VAR **7** · F7 回归 7／7／9 · 矩阵 5/5
  - ✅ F7 带参 dispatch（双端 L2）：产生点 `pipeline_asm_emit_method_call_elf_c` `dep_idx==-2` 补 extras→GP 1..5（`emit_expr_elf_for_call_args`＋spill／load；禁 `glue_emit_one_call_arg` 因 slot≠func）；wrapper rdi／x0＝data 未改（trampoline 只碰 self）。验收：`dyn_add.x` **7** · F7 回归 7／7／9 · builtin **7** · 矩阵 5/5
  - ✅ host-C wrapper 转发 extras（双端 L2）：产生点 `codegen_emit_vtable_wrapper_def` 补 impl 形参 1..5（`emit_type`＋`aN` 转发；TYPE_SLICE 指针 ABI 同 `emit_func`）；首参仍 `void* data`。验收：`dyn_add.x` host-C／asm **7** · F7 回归 7／7／9 · builtin **7** · 矩阵 5/5
  - ✅ F7 x86 SSE extras（双端 L2）：产生点同上 `dep_idx==-2` 曾把 f64 extras 塞 rsi；x86 `param_home` 读 xmm0 → Ubuntu run＝4／mix＝5。G.7 补全 `glue_arg_ref_is_sse_float_c`（≡ UFCS leave）；**仅 ta==0** 走 xmm（ARM64 本地 impl 仍 GP-in）。验收：`dyn_add_f64.x` asm／host-C **7** · i32 extras **7** · F7 回归 7／7／9 · 矩阵 5/5
  - ✅ F7 f32 FLOAT_LIT stamp（双端 L2）：产生点 `typeck_check_expr_method_call` TYPE_DYN 早退不访 extras；`func_ix`＝slot 不能走 `typeck_stamp_resolved_args_float_lit`。G.7 补 `xlang_skip_trait_method_param_kind_c`（registry `method_param_kinds` 已有）；dyn 路径 `check_expr`＋`typeck_coerce_init_float_lit_to_decl`（extra i→param i＋1）；`glue_arg_ref_is_f64_width_c` 先认 stamp。验收：`dyn_add_f32.x` 双端 asm **7** · f64／i32 **7** · F7 回归 7／7／9 · 矩阵 5/5
  - ✅ host-C f32 dyn 调用点类型化（双端 L2）：产生点 F3 调用点 `(*)(void*, …)` 默认提升 f32→f64；wrapper 已是 `(void* data, float a1)`。G.7 补 `codegen_emit_dyn_host_c_fn_ptr_suffix`（registry `param_kind` extra i→param i＋1；NAMED／PTR／SLICE 仍 `…`）。验收：`dyn_add_f32.x` 双端 host-C／asm **7** · `-E` `(void*, float)`
  - ✅ F7 dyn stack extras（双端 L2）：产生点 `dep_idx==-2` `nargs>5` CG002，且 wrapper `prologue+call` 错位 impl `[rbp+16]`。G.7 补全既有 dyn extras＋wrapper（`glue_asm_call_reg_max`；溢出 extras x86 push／ARM64 `[sp]`；wrapper 拷入栈再 `call` impl）。wrapper rdi＝data 未改。验收：`dyn_add_stack.x` 双端 asm **7**
  - ✅ host-C nparams>6（双端 L2）：产生点 `codegen_emit_vtable_wrapper_def` `nparams>6` 硬拒 → host-C `dyn_add_stack` XP003。循环已发 `aN`。G.7 抬安全帽 96（≡ asm extras）；禁第二套 dispatcher。首参仍 `void* data`。验收：`dyn_add_stack.x` 双端 host-C／asm **7** · `-E` `(void* data, int32_t a1..a6)`
  - ✅ ARM64 wrapper x0 拷栈（双端 L2）：产生点 `pipeline_asm_emit_vtable_wrapper_def` ARM64 `load_x29_pos` 写 x0（rax 兼 arg0），by-value deref 后 self.v＝末栈 extra。G.7 拷前存 `[x29,#24]`、拷后恢复；禁 `mov_rax_to_rbx`（兼写 x1）。x86 rdi≠rax 未改。验收：`dyn_add_stack8.x` 双端 asm／host-C **7**（sit-red Darwin run＝5）
  - ✅ skip-trait 前缀 `[N]T` extra（双端 L2）：产生点 `param_slice_need_rb`／`ret_slice_need_rb` 见 INT 即 bail，trait `[2]i32` 停在 SLICE、impl TYPE_ARRAY → T001。G.7 补全既有扫描器（孪 wave436 `*[N]T`：`]`＝`[]T`、INT＝`[N]T`／`[N][M]T`）；`skip_tl`＋seed parse 孪同 commit。验收：`dyn_add_arr1.x` 双端 asm／host-C **7**；`[2][2]i32`／`[]i32` **7**
  - ✅ host-C `[K][N]T` extra（双端 L2）：产生点 wrapper `emit_type` → `int32_t ** a1`，ARRAY_LIT else → `(E *[]){(E[]){…}}`；impl 已是 `int32_t (*p)[2]`。sit-red `dyn_add_arr2` host-C **219**。G.7 补全既有 wrapper（`emit_c_ptr_to_fixed_array_decl`）＋ARRAY_LIT else（`(E[][N]){{…}}`）；禁第二套 wrapper／第二套 ARRAY_LIT 发射。首参仍 `void* data`。验收：`dyn_add_arr2.x` 双端 asm／host-C **11** · `-E` `int32_t (*a1)[2]`／`(int32_t[][2]){{1, 2}, {3, 4}}`
  - ✅ dyn `[]i32` ARRAY_LIT extra（双端 L2）：产生点 `typeck_check_expr_method_call` TYPE_DYN extras 只盖 FLOAT_LIT，ARRAY_LIT 停在 TYPE_ARRAY；host-C `emit_call_arg_slice_abi`／asm `emit_expr_elf_for_call_args` 只在 dest-SLICE 包 fat。sit-red `x.sums([2,4])` asm **1**／host-C **139**（具名局部／UFCS 已 7）。G.7 补 `xlang_skip_trait_method_param_elem_kind_c`（registry `method_param_elem_kinds` 已有）＋既有 extras 循环复用 `typeck_coerce_init_slice_from_array`。禁第二套 ARRAY_LIT 发射。首参仍 `void* data`。验收：`dyn_add_slice.x` 双端 asm／host-C **7** · `-E` `__xlang_sp` dest-SLICE wrap
  - ✅ host-C ret `[2]i32`／`[]i32`（双端 L2）：产生点 wrapper `emit_type_kind(ARRAY／SLICE)` 返 −1 → XP003；typeck 跳过 kind 10／11 使调用点转型成 void。G.7 补全既有 wrapper（`emit_type(impl ret)`）＋`xlang_skip_trait_method_ret_elem_kind_c`／`ret_array_size`＋dyn ret `find_or_alloc_*` stamp＋调用点 `emit_type`。禁第二套 wrapper。首参仍 `void* data`。验收：`dyn_ret_arr.x`／`dyn_ret_slice.x` 双端 asm／host-C **7** · `-E` `static int32_t * wrap(void* data)`／`static struct xlang_slice_int32_t wrap(void* data)`
  - ✅ host-C dyn ret NAMED／`*i32`（双端 L2）：产生点 typeck TYPE_DYN 跳过 kind 8／9 使调用点 `emit_type_kind(VOID)`；wrapper 已 `emit_type(impl ret)`。sit-red `struct Pair r = (void)call`／`int32_t *p = (void)call`。G.7 补 `xlang_skip_trait_method_ret_name_into_c`（registry `method_ret_names` 已有）＋dyn ret `find_or_alloc_named`／`find_or_alloc_ptr` stamp＋调用点有 type_ref 即 `emit_type`。禁第二套 wrapper。首参仍 `void* data`。验收：`dyn_ret_named.x`／`dyn_ret_ptr.x` 双端 asm／host-C **7** · `-E` `((struct Pair(*)(void*))…)`／`((int32_t *(*)(void*))…)`
  - ✅ dyn NAMED extra STRUCT_LIT（双端 L2）：产生点 typeck TYPE_DYN extras 只盖 FLOAT_LIT／dest-SLICE，匿名 `{a:2,b:4}` 无名；host-C 发 `(struct )`，asm 场布局 miss。sit-red host-C 编译失败／asm **162**（具名局部已 7；wrapper 已 `struct Pair a1`）。G.7 补 `xlang_skip_trait_method_param_name_into_c`（registry `method_param_names` 已有）＋既有 extras 循环复用 `find_or_alloc_named`＋`typeck_coerce_init_struct_lit_to_decl`。禁第二套 STRUCT_LIT stamp。首参仍 `void* data`。验收：`dyn_add_named.x` 双端 asm／host-C **7** · `-E` `(struct Pair){.a=2,.b=4}`
  - ✅ dyn ret NAMED 叶子 `*T`／`[]T`／`[N]T`（双端 L2）：产生点 typeck TYPE_DYN ret 跳过 elem kind 8，`*Pair`／`[]Pair`／`[2]Pair` 无 type_ref → host-C void-cast。registry `method_ret_names` 已有 `Pair`。sit-red `struct Pair *p = (void)call`／`slice_Pair = (void)call`／memcpy void（asm dest-let 已 7／5）。G.7 补全既有 dyn ret 块（`ret_name`＋`find_or_alloc_named` 再 wrap ptr／slice／array）。禁第二套 resolve。首参仍 `void* data`。验收：`dyn_ret_ptr_named.x`／`dyn_ret_slice_named.x` 双端 asm／host-C **7** · `dyn_ret_arr_named.x` **5** · `-E` `((struct Pair *(*)(void*))…)`／`((struct xlang_slice_Pair(*)(void*))…)`
  - ✅ dyn `[]Pair` extra dest-stamp（双端 L2）：产生点 typeck TYPE_DYN dest-SLICE extras 跳过 elem kind 8，`[{a:2,b:4}]` 停在 nameless STRUCT_LIT 的 TYPE_ARRAY；registry `method_param_names` 已有 `Pair`。sit-red asm **139**／host-C `(uint8_t[]){(struct )}`（具名局部已 7）。G.7 补全既有 dest-SLICE extras（`param_name`＋`find_or_alloc_named` 再 wrap slice＋`typeck_coerce_init_expr_to_decl`）。禁第二套 dest-SLICE／ARRAY_LIT／STRUCT_LIT stamp。首参仍 `void* data`。验收：`dyn_add_slice_named.x` 双端 asm／host-C **7** · `-E` `__xlang_sp`＋`(struct Pair){.a=2,.b=4}`
  - ✅ dyn ret `[K][N]T` ndims（双端 L2）：产生点 typeck TYPE_DYN ret ARRAY 只用 `ret_array_size`（外层 N）→ `[2][2]i32` 建成 `[2]i32`。registry `method_ret_array_ndims`／`dims` 已有。sit-red 双端 XT001。G.7 补 `xlang_skip_trait_method_ret_array_ndims_c`／`ret_array_dim_c`＋既有 dyn ret ARRAY 块由内向外 wrap。禁第二套 resolve。首参仍 `void* data`。验收：`dyn_ret_arr2.x` 双端 compile **0** · `-E` `int32_t r[2][2]`
  - ✅ host-C `[K][N]T` ret emit（双端 L2）：产生点 `emit_type` 连剥 ARRAY 两次 → `int32_t **`，return wrap 发 `static int32_t * __xlang_ar[2]`＋`int32_t ** rp = t`。sit-red Ubuntu `-Wincompatible-pointer-types`／mac clang 假绿 10（具名局部同）。G.7 补全既有 `emit_type` 衰减（多层 ARRAY 只留一个 `E *`）＋既有 return wrap（`static E __xlang_ar[K][N]` memcpy／brace，返 `(E*)ar`）。禁第二套 return 发射。首参仍 `void* data`。验收：`dyn_ret_arr2.x` 双端 host-C **10** · `-E` `int32_t * get22`＋`static int32_t __xlang_ar[2][2]` memcpy
  - ✅ asm dest `[K][N]T` 拷贝（双端 L2）：产生点 `glue_struct_lit_store_fixed_array_field`／return Path B0 把 elem 交给 `glue_index_elem_byte_sz`，再剥一层成叶子 4B，dest／COMMON 只拷第一行。sit-red 双端具名 `let r=t`／dest-CALL／`dyn_ret_arr2` run＝3（ARRAY_LIT 本地已 10）。G.7 复用既有 `glue_array_lit_force_esz_from_elem_type`（TYPE_ARRAY→`glue_fixed_array_total_bytes`；孪 4.2.7 nested SLICE）。thin inject 无 mega `-E`。禁第二套 memcpy。首参仍 `void* data`。验收：`dyn_ret_arr2.x` 双端 asm／host-C **10** · 具名 copy／ret **10**
  - ✅ dest-ARRAY `[2]Pair` extra dest-stamp（双端 L2）：产生点 typeck TYPE_DYN extras 跳过 dest-ARRAY（pk＝10），`[{a:2,b:3},{a:4,b:4}]` 停在 nameless STRUCT_LIT 的 TYPE_ARRAY；registry `method_param_names`／`param_array_ndims`／dims 已有。sit-red host-C `(uint8_t[]){(struct )}`（asm 已 7；具名局部已 7；UFCS extras 另产）。G.7 补 `xlang_skip_trait_method_param_array_ndims_c`／`param_array_dim_c`＋既有 extras 循环复用 `find_or_alloc_named`／`find_or_alloc_array`＋`typeck_coerce_init_expr_to_decl`。禁第二套 ARRAY_LIT／STRUCT_LIT stamp。首参仍 `void* data`。验收：`dyn_add_arr_named.x` 双端 asm／host-C **7** · `-E` `(struct Pair[]){(struct Pair){…}}`
  - ✅ UFCS extras dest-ARRAY／dest-SLICE STRUCT_LIT dest-stamp（双端 L2）：产生点 UFCS extras／`typeck_check_call_arg_types` 只走 `array_vector`，`[{a:2,b:3},{a:4,b:4}]` 外层 ARRAY／SLICE 已盖、STRUCT_LIT 场无名。sit-red host-C `(struct Pair[]){(struct )}`／asm run＝3（第一场）；dest-SLICE asm 2／host-C 18；CALL extras 同产 run＝3（具名局部已 6；dyn dest-ARRAY 已 7）。G.7 补既有 extras 循环复用 `typeck_coerce_array_lit_struct_elems_to_decl`＋dest-NAMED `typeck_coerce_init_struct_lit_to_decl`。禁第二套 STRUCT_LIT stamp。首参仍 `void* data`。验收：`ufcs_add_arr_named.x`／`ufcs_add_slice_named.x` 双端 asm／host-C **7** · CALL dest-ARRAY **6** · dest-NAMED UFCS **7** · `-E` `(struct Pair[]){(struct Pair){…}}`
  - ✅ dest-SLICE extra `[][2]i32` dest-stamp（双端 L2）：产生点 typeck TYPE_DYN dest-SLICE extras 跳过 elem kind 10，`[[2,4]]` 停在 TYPE_ARRAY of ARRAY；registry `param_elem_elem_kinds`／`param_elem_array_ndims`／dims 已有。sit-red asm **1**／host-C **139**（具名局部／UFCS 已 6／7）。G.7 补 `xlang_skip_trait_method_param_elem_elem_kind_c`／`elem_array_ndims`／dim accessor＋既有 dest-SLICE extras wrap ARRAY 再 wrap slice＋`typeck_coerce_init_expr_to_decl`。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_arr.x` 双端 asm／host-C **7** · `-E` `__xlang_sp`＋`int32_t __xlang_al[][2]={{2,4}}`
  - ✅ dest-ARRAY extra `[2][]i32` dest-stamp（双端 L2）：产生点 skip-trait `param_prefix_arr_need_size` 在 `[N][` 后只认 INT，`[2][]i32` bail，dest-ARRAY extras 再跳过 elem kind 11，`[[2,3],[1,4]]` 停在 TYPE_ARRAY of ARRAY。sit-red asm **139**／host-C **133**（具名局部／UFCS 已 7；`-E` `(int32_t[][2])` 塞进 slice*）。G.7 补全既有扫描器（`]`＝SLICE elem，叶走 `param_elem_elem_pending`）＋既有 dest-ARRAY extras wrap slice 再 wrap ARRAY＋`typeck_coerce_init_expr_to_decl`。禁第二套 dest-ARRAY stamp。首参仍 `void* data`。验收：`dyn_add_arr_slice.x` 双端 asm／host-C **7** · `-E` `(struct xlang_slice_int32_t[]){__xlang_al}`
  - ✅ dyn ret `*[2]i32` dest-stamp（双端 L2）：产生点 typeck TYPE_DYN ret PTR 跳过 elem kind 10，`*[2]i32` 无 type_ref → host-C void-cast；盖戳后 `emit_type` 发抽象 `E (*)[N]` 在函数名前（非法 C），Ubuntu gcc 再拒 `return &self.p`（`E (*)[N]`）赋给剥成 `E *` 的返回。registry `ret_elem_elem_kinds`／`ret_elem_array_ndims`／dims 已有。G.7 补 `ret_elem_elem_kind`／`ret_elem_array_ndims`／dim accessor＋既有 dyn ret PTR 块 wrap ARRAY 再 wrap ptr＋`emit_type` 剥成首元 `E *`（≡ `[N]T` ret ABI）＋let-init `(E (*)[N])` 转型＋return `(E *)` 转型。禁第二套 resolve。首参仍 `void* data`。验收：`dyn_ret_ptr_arr.x` 双端 asm／host-C **7** · `-E` `int32_t * getpa`＋`return (int32_t *)&self.p`＋`int32_t (*p)[2] = (int32_t (*)[2])…`
  - ✅ dest extras dest-RET PTR-to-ARRAY extra empty `[]` `*[2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `*[N]`（elem＝ARRAY、PTR 外层、ndims≥1）走 wave438 置 elem_kind＝−1，leaf T 未 commit，leftover 跳过 eek＝−1；dest extras dest-RET wrap-once dest-stamps `*[2]i32`（typed let `*[2][]i32` T001）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝ARRAY／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE wrap 在未用槽 dims[ndims]（1＝`*[2][]T`；2＝`*[2][][]T`；0＝无 extra wrap＝`*[2]i32`）。判别 vs dest extras dest-ARRAY of PTR extra empty `[]` `[2]*[2][]T`／dest extras dest-SLICE of ARRAY extra `[][2][]T`（同未用槽）是 PTR ret vs ARRAY vs SLICE 外层。消费＝leftover PTR vs eek＝ARRAY 非 T001（walk 先剥 ARRAY 再 extra SLICE）；dest extras dest-RET wrap extra SLICE of leaf extra times then ARRAY inner-first then wrap ptr。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover，`*[2]i32` identity INDEX 亦 139）。G.7 补既有 ret extra empty `[]` 扫描器（ARRAY 元；PTR 外层；keep ARRAY；extra SLICE 进 dims[ndims]）＋leftover extra SLICE peels＋dest extras dest-RET extra SLICE wraps（pin typeck 孪）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_arr_slice.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · `-E` `struct xlang_slice_int32_t (*p)[2]`＋wrapper `void* data`
  - ✅ dest extras dest-RET extra STAR `*[2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `*[N]`（elem＝ARRAY、PTR 外层、ndims≥1）走 token_to_type_kind＝−1 再 want_ret＝0，leaf T 未 commit，leftover 跳过 eek＝−1；dest extras dest-RET wrap-once dest-stamps `*[2]i32`（typed let `*[2]*i32` T001；Darwin dest-stamp via the local＝假绿）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝ARRAY／eek＝leaf／ndims≥1／dims[0]＝N／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`*[2]*T`；2＝`*[2]**T`；0＝无 extra PTR＝`*[2]i32`／`*[2][]T`）／extra SLICE 仍 dims[ndims]（两槽＝`*[2][]*T`）。判别 vs dest extras dest-RET extra empty `[]` `*[2][]T`（同未用槽族）是 extra PTR vs extra SLICE。消费＝leftover PTR vs eek＝ARRAY 非 T001（walk 先剥 ARRAY 再 extra SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then extra SLICE then ARRAY inner-first then wrap ptr。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover，`*[2]i32` identity INDEX 亦 139）。G.7 补既有 ret extra STAR unused-slot 扫描器（ARRAY 元；PTR 外层；keep ARRAY；extra PTR 进 dims[ndims+1]）＋leftover extra PTR peels＋dest extras dest-RET extra PTR wraps（pin typeck 孪）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_arr_ptr.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · `-E` `int32_t * (*p)[2]`＋wrapper `void* data`
  - ✅ dest extras dest-RET extra STAR PTR-elem `**[2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `**`（elem＝PTR、PTR 外层）走 token_to_type_kind＝−1 再 ret_elem_suffix_pending（elem_kind＝−1）；after `**[N]` wave434 *T[N] lift leftover PTR vs ARRAY T001；dest extras dest-RET wrap-once dest-stamps `**[2]i32`（typed let `**[2]*i32` T001）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／dims[0]＝N／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`**[2]*T`；2＝`**[2]**T`；0＝无 extra PTR＝`**[2]i32`／`**[2][]T`）／extra SLICE 仍 dims[ndims]（两槽＝`**[2][]*T`）。判别 vs dest extras dest-RET extra STAR ARRAY-elem `*[2]*T`（同未用槽族）是 PTR vs ARRAY 元。消费＝leftover PTR vs eek＝PTR 非 T001（walk 先剥 leftover PTR 再 ARRAY 再 extra SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then extra SLICE then ARRAY inner-first then wrap PTR then wrap outer ptr。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret_elem_pending STAR（store PTR）＋既有 ret extra STAR unused-slot 扫描器（PTR 元；PTR 外层；keep PTR；extra PTR 进 dims[ndims+1]）＋leftover extra ARRAY peels＋dest extras dest-RET extra PTR wraps（pin typeck 孪）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_ptr_arr_ptr.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · `-E` `int32_t * * * p`＋wrapper `void* data`
  - ✅ dest extras dest-RET extra empty `[]` PTR-elem `**[2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `**[N]`（elem＝PTR、PTR 外层）只认 ARRAY 元，PTR 元走 wave438 置 elem_kind＝−1，leftover 跳过 eek＝−1（dest-stamp via the local of typed dest 双端假绿；impl `**[2]i32` vs trait `**[2][]i32` compile＝0）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE wrap 在未用槽 dims[ndims]（1＝`**[2][]T`；2＝`**[2][][]T`；0＝无 extra wrap＝`**[2]i32`／`**[2]*T`）／extra PTR 仍 dims[ndims+1]（两槽＝`**[2][]*T`）。判别 vs dest extras dest-RET extra empty `[]` ARRAY-elem `*[2][]T`（同未用槽族）是 PTR vs ARRAY 元。消费＝leftover PTR vs eek＝PTR 非 T001（walk 先剥 leftover PTR 再 ARRAY 再 extra SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then extra SLICE then ARRAY inner-first then wrap PTR then wrap outer ptr（消费已活；pin 未孪）。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret extra empty `[]` unused-slot 扫描器（ARRAY 或 PTR 元；PTR 外层；keep PTR；extra SLICE 进 dims[ndims]）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_ptr_arr_slice.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · leftover mismatch T001 · `-E` `struct xlang_slice_int32_t * * p`＋wrapper `void* data`
  - ✅ dest extras dest-RET extra empty `[]` SLICE-elem `*[][2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `*[][N]`（elem＝SLICE、PTR 外层）只认 ARRAY 或 PTR 元，SLICE 元走 wave438 置 elem_kind＝−1，leftover 跳过 eek＝−1（dest-stamp via the local of typed dest 双端假绿；impl `*[][2]i32` vs trait `*[][2][]i32` compile＝0）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE wrap 在未用槽 dims[ndims+1]（1＝`*[][2][]T`；2＝`*[][2][][]T`；0＝无 extra wrap＝`*[][2]i32`／`*[][2]*T`）／extra PTR 仍 dims[ndims]（两槽＝`*[][2][]*T`）。判别 vs dest extras dest-RET extra empty `[]` ARRAY-elem `*[2][]T`／PTR-elem `**[2][]T`（同未用槽族）是 SLICE vs ARRAY vs PTR 元。消费＝leftover PTR vs eek＝SLICE 非 T001（walk 先剥 leftover SLICE 再 extra ARRAY 再 extra SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then extra SLICE then ARRAY inner-first then wrap SLICE then wrap outer ptr（pin typeck 孪）。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret extra empty `[]` unused-slot 扫描器（SLICE 元；PTR 外层；keep SLICE；extra SLICE 进 dims[ndims+1]）＋leftover extra ARRAY／SLICE peels＋dest extras dest-RET wrap rek3＝11。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_slice_arr_slice.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · leftover mismatch T001 · `-E` `struct xlang_slice_xlang_arr2_xlang_slice_int32_t * p`＋wrapper `void* data`
  - ✅ dest extras dest-RET extra STAR SLICE-elem `*[][2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `*[][N]`（elem＝SLICE、PTR 外层）走 token_to_type_kind＝−1 再 want_ret＝0，leaf T 未 commit，leftover 跳过 eek＝−1（dest extras dest-RET wrap rek3＝11 dest-stamps `*[][2]i32` 故 typed let `*[][2]*i32` T001；dest-stamp via the local of typed dest 双端假绿；impl `*[][2]i32` vs trait `*[][2]*i32` compile＝0）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／dims[0]＝N／extra PTR wrap 在未用槽 dims[ndims]（1＝`*[][2]*T`；2＝`*[][2]**T`；0＝无 extra PTR＝`*[][2]i32`／`*[][2][]T`）／extra SLICE 仍 dims[ndims+1]（两槽＝`*[][2][]*T`）。判别 vs dest extras dest-RET extra STAR ARRAY-elem `*[2]*T`／PTR-elem `**[2]*T`（同未用槽族；ARRAY／PTR extra PTR 在 dims[ndims+1]）是 SLICE vs ARRAY vs PTR 元。消费＝leftover PTR vs eek＝SLICE 非 T001（walk 先剥 leftover SLICE 再 extra ARRAY 再 extra SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then extra SLICE then ARRAY inner-first then wrap SLICE then wrap outer ptr（消费已活；pin 未孪）。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret extra STAR unused-slot 扫描器（SLICE 元；PTR 外层；keep SLICE；extra PTR 进 dims[ndims]）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_slice_arr_ptr.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · leftover mismatch T001 · `-E` `struct xlang_slice_xlang_arr2_int32_t_p * p` typed-cast＋wrapper `void* data`
  - ✅ dest extras dest-RET extra STAR SLICE-elem ndims＝0 `*[]*T` dest-stamp（双端 L2）：产生点 extra STAR after `*[]`（elem＝SLICE、PTR 外层、ndims＝0）走 `nd>0` 失败再 elem_kind＝−1 leftover 跳过 eek＝−1（dest extras dest-RET wrap rek3＝11 dest-stamps `*[]i32` 故 typed let `*[]*i32` T001；dest-stamp via the local of typed dest 双端假绿；impl `*[]i32` vs trait `*[]*i32` compile＝0）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims＝0／extra PTR wrap 在未用槽 dims[0]（1＝`*[]*T`；2＝`*[]**T`；0＝无 extra PTR＝`*[]i32`）。判别 vs dest extras dest-RET extra STAR SLICE-elem ndims≥1 `*[][2]*T`（extra PTR 在 dims[ndims]）是 ndims＝0 vs ndims≥1。消费＝leftover PTR vs eek＝SLICE 非 T001（walk 先剥 leftover SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then wrap SLICE then wrap outer ptr（pin typeck 孪）。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret extra STAR unused-slot 扫描器（SLICE 元；PTR 外层；ndims＝0 extra PTR 进 dims[0]）＋leftover eend＝0 extra PTR peels＋dest extras dest-RET wrap rek3＝11 extra PTR when ndims＝0。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_slice_ptr.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · leftover mismatch T001 · `-E` `struct xlang_slice_int32_t_p * p` typed-cast＋wrapper `void* data`
  - ✅ dest extras dest-RET extra STAR SLICE-elem ndims＝−2 `*[][]*T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `*[]`（elem＝SLICE、PTR 外层、ndims＝0）走 `nd>0` 失败再 elem_kind＝−1 leftover 跳过 eek＝−1（dest extras dest-RET wrap rek3＝11 dest-stamps `*[]i32` 故 typed let `*[][]*i32` T001；dest-stamp via the local of typed dest 双端假绿；impl `*[][]i32` vs trait `*[][]*i32` compile＝0）。存储＝elem＝SLICE／eek＝leaf／ndims＝−2／extra SLICE wrap 在 dims[0]（0 表 1＝`*[][]T`；2＝`*[][][]T`）／extra PTR wrap 在未用槽 dims[1]（1＝`*[][]*T`；2＝`*[][]**T`；0＝无 extra PTR＝`*[][]T`）。判别 vs dest extras dest-RET extra STAR SLICE-elem ndims＝0 `*[]*T`（extra PTR 在 dims[0]）／ndims≥1 `*[][2]*T`（extra PTR 在 dims[ndims]）是 ndims＝−2 vs ndims＝0 vs ndims≥1。消费＝leftover PTR vs eek＝SLICE 非 T001（walk 先剥 leftover SLICE 再 extra SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then extra SLICE then wrap SLICE then wrap outer ptr（pin typeck 孪）。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret extra empty `[]` unused-slot 扫描器（SLICE 元；PTR 外层；ndims≤0 → ndims＝−2）＋ret extra STAR unused-slot 扫描器（ndims＝−2 extra PTR 进 dims[1]）＋leftover eend＝−2 extra SLICE then extra PTR peels＋dest extras dest-RET wrap rek3＝11 extra PTR／SLICE when ndims＝−2。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_slice_slice_ptr.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · leftover mismatch T001 · `-E` `struct xlang_slice_xlang_slice_int32_t_p * p` typed-cast＋wrapper `void* data`
  - ✅ dest extras dest-RET extra STAR PTR-elem ndims＝0 `***T` dest-stamp（双端 L2）：产生点 extra STAR after `**`（elem＝PTR、PTR 外层、ndims＝0）走 `nd>0` 失败再 elem_kind＝−1 leftover 跳过 eek＝−1（dest extras dest-RET wrap rek3＝9 dest-stamps `**i32` 故 typed let `***i32` T001；dest-stamp via the local of typed dest 双端假绿；impl `**i32` vs trait `***i32` compile＝0）。存储＝elem＝PTR／eek＝leaf／ndims＝0／extra PTR wrap 在未用槽 dims[1]（1＝`***T`；2＝`****T`；0＝无 extra PTR＝`**T`；extra SLICE 仍 dims[0]＝`**[]T` 下叶）。判别 vs dest extras dest-RET extra STAR PTR-elem ndims≥1 `**[2]*T`（extra PTR 在 dims[ndims+1]）是 ndims＝0 vs ndims≥1；vs extra STAR SLICE-elem ndims＝0 `*[]*T`（extra PTR 在 dims[0]）是 PTR vs SLICE 元。消费＝leftover PTR vs eek＝PTR 非 T001（walk 先剥 leftover PTR 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then wrap PTR then wrap outer ptr（pin typeck 孪）。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret extra STAR unused-slot 扫描器（PTR 元；PTR 外层；ndims＝0 extra PTR 进 dims[1]）＋leftover eend＝0 extra PTR peels＋dest extras dest-RET wrap rek3＝9 extra PTR when ndims＝0。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_ptr_ptr.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · leftover mismatch T001 · `-E` `int32_t * * * p` typed-cast＋wrapper `void* data`
  - ✅ dest extras dest-RET extra empty `[]` PTR-elem ndims＝0 `**[]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `**`（elem＝PTR、PTR 外层、ndims＝0）走 `nd>0` 失败再 elem_kind＝−1 leftover 跳过 eek＝−1（dest extras dest-RET wrap rek3＝9 dest-stamps `**i32` 故 typed let `**[]i32` T001；dest-stamp via the local of typed dest 双端假绿；impl `**i32` vs trait `**[]i32` compile＝0）。存储＝elem＝PTR／eek＝leaf／ndims＝0／extra SLICE wrap 在未用槽 dims[0]（1＝`**[]T`；2＝`**[][]T`；0＝无 extra SLICE＝`**T`／`***T`；extra PTR 仍 dims[1]；两槽＝`**[]*T`）。判别 vs dest extras dest-RET extra empty `[]` PTR-elem ndims≥1 `**[2][]T`（extra SLICE 在 dims[ndims]）是 ndims＝0 vs ndims≥1；vs extra STAR PTR-elem ndims＝0 `***T`（extra PTR 在 dims[1]）是 extra SLICE vs extra PTR。消费＝leftover PTR vs eek＝PTR 非 T001（walk 先剥 leftover PTR 再 extra SLICE 再 extra PTR）；dest extras dest-RET wrap extra PTR of leaf extra times then extra SLICE then wrap PTR then wrap outer ptr（pin typeck 孪）。Assign-only：impl 返 `&self.p` of by-value self（dangling — 禁 INDEX；dest extras dest-RET PTR-to-ARRAY identity INDEX 是既有 emit leftover）。G.7 补既有 ret extra empty `[]` unused-slot 扫描器（PTR 元；PTR 外层；ndims＝0 extra SLICE 进 dims[0]）＋leftover eend＝0 extra SLICE peels＋dest extras dest-RET wrap rek3＝9 extra SLICE when ndims＝0。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_ret_ptr_ptr_slice.x` 双端 assign-only／host-C **7** · extra wrap COUNT＝2 assign-only **7** · leftover mismatch T001 · `-E` `struct xlang_slice_int32_t * * p` typed-cast＋wrapper `void* data`
  - ✅ dest extras dest-PARAM extra empty `[]` PTR-elem ndims＝0 `**[]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `**`（elem＝PTR、PTR 外层、ndims＝0）先被 ndims＝−2 PTR-to-SLICE 哨兵截走（0 表 1）再 leftover 跳过 eek＝−1（extra ADDR_OF of typed dest dest-stamps via the formal＝leftover skip 假绿；leftover mismatch impl `**i32` vs trait `**[]i32` compile＝0 run＝1）。存储＝elem＝PTR／eek＝leaf／ndims＝0／extra SLICE wrap 在未用槽 dims[0]（1＝`**[]T`；2＝`**[][]T`；0＝无 extra SLICE＝`**T`／`***T`；extra PTR 仍 dims[1]；两槽＝`**[]*T`）。判别 vs PARAM extra empty `[]` PTR-elem ndims≥1 `**[2][]T`（extra SLICE 在 dims[ndims]）是 ndims＝0 vs ndims≥1；vs PARAM extra STAR PTR-elem ndims＝0 `***T`（extra PTR 在 dims[1]；仍延期）是 extra SLICE vs extra PTR。消费＝leftover PTR vs eek＝PTR 非 T001（walk 先剥 leftover PTR 再 extra SLICE 再 extra PTR when ndims＝0）；extra ADDR_OF of typed `*[]i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 PARAM extra empty `[]` unused-slot 扫描器（PTR 元；PTR 外层；ndims＝0 extra SLICE 进 dims[0]）＋leftover eand＝0 extra SLICE peels＋ndims＝−2 哨兵排除 PTR-elem＋PTR 外层。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_ptr_slice.x` 双端 extra ADDR_OF of typed dest／host-C **7** · extra wrap COUNT＝2 **7** · leftover mismatch T001 · `-E` `struct xlang_slice_int32_t * * p`＋wrapper `void* data`
  - ✅ dest extras dest-PARAM extra STAR PTR-elem ndims＝0 `***T` dest-stamp（双端 L2）：产生点 extra STAR after `**`（elem＝PTR、PTR 外层、ndims＝0）走 `nd>0` 失败再 elem_kind＝−1 leftover 跳过 eek＝−1（extra ADDR_OF of typed dest dest-stamps via the formal＝leftover skip 假绿；leftover mismatch impl `**i32` vs trait `***i32` compile＝0 run＝7 leftover skip so leftover never compares）。存储＝elem＝PTR／eek＝leaf／ndims＝0／extra PTR wrap 在未用槽 dims[1]（1＝`***T`；2＝`****T`；0＝无 extra PTR＝`**T`／`**[]T`；extra SLICE 仍 dims[0]；两槽＝`**[]*T`）。判别 vs PARAM extra STAR PTR-elem ndims≥1 `**[2]*T`（extra PTR 在 dims[ndims+1]）是 ndims＝0 vs ndims≥1；vs PARAM extra empty `[]` PTR-elem ndims＝0 `**[]T`（extra SLICE 在 dims[0]；已闭）是 extra PTR vs extra SLICE。消费＝leftover PTR vs eek＝PTR 非 T001（walk 先剥 leftover PTR 再 extra SLICE 再 extra PTR when ndims＝0；leftover extra PTR peels 已活）；extra ADDR_OF of typed `**i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 PARAM extra STAR unused-slot 扫描器（PTR 元；PTR 外层；ndims＝0 extra PTR 进 dims[1]）＋leftover eand＝0 extra PTR peels（已活）＋PARAM dim accessor nd＝0 dim_ix＝1。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_ptr_ptr.x` 双端 extra ADDR_OF of typed dest／host-C **7** · extra wrap COUNT＝2 **7** · leftover mismatch T001 · `-E` `int32_t * * * p`＋wrapper `void* data`
  - ✅ leftover extra peels PARAM PTR-elem ndims≥1 `**[2][]T`／`**[2]*T` leftover mismatch T001（双端 L2）：产生点 leftover PTR vs eek＝PTR 匹配后 eand≥1 不剥 extra ARRAY／SLICE／PTR（leftover extras never compared＝leftover skip 假绿；impl `**[2]i32` vs trait `**[2][]i32` compile＝0 run＝2 leftover skip；impl `**[2]i32` vs trait `**[2]*i32` compile＝0 run＝98 leftover skip）。存储已齐（elem＝PTR／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE 在 dims[ndims]／extra PTR 在 dims[ndims+1]）。消费＝leftover PTR vs eek＝PTR 非 T001 须先剥 leftover PTR 再 ARRAY 再 extra SLICE 再 extra PTR（RET 孪已活）。G.7 补既有 leftover eek＝PTR eand≥1 extra ARRAY then extra SLICE then extra PTR peels。leftover extra SLICE peels leftover eek＝PTR eand＝−2（`[]*[]T`／`[]*[][]T`）**已闭**（8／21 PARAM＋RET）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_ptr_arr_slice.x`／`dyn_add_ptr_ptr_arr_ptr.x` 双端 extra ADDR_OF of typed dest／host-C **7** · extra wrap COUNT＝2 **7** · leftover mismatch T001 · leftover ARRAY size T001 · dual-slot leftover extra STAR mismatch T001 · `-E` `struct xlang_slice_int32_t * * p`＋wrapper `void* data`
  - ✅ host-C `[]*i32` type_to_c_repr 标签（双端 L2）：产生点 `pipeline_codegen_type_to_c_repr` TYPE_SLICE 把 `int32_t *` 原样拷进标签 → `struct xlang_slice_int32_t *`（指针当类型名）。sit-red 具名局部／UFCS／dyn 皆 host-C 编译失败（asm let-only 已 7）。G.7 补 SLICE 标签清洗（`*`→`_p`，孪 ARRAY）＋既有 `codegen_emit_slice_of_fixed_array_layouts` 发 PTR 元 `{ E **data }`；产品 hybrid 抽 seed 体 thin inject（禁 mega `-E`）。禁第二套 type_to_c。首参仍 `void* data`。验收：`slice_of_ptr_let.x` 双端 asm／host-C **7** · `-E` `struct xlang_slice_int32_t_p { int32_t **data }`
  - ✅ dest-SLICE extra `[]*i32` dest-stamp（双端 L2）：产生点 skip-trait `[]` 后 STAR 走 `token_to_type_kind`（不认 STAR）elem_kind＝−1，dest extras 再跳过 kind 9，`[&n,&m]` 停在 TYPE_ARRAY of PTR。sit-red dyn host-C **133**（`(int32_t *[])` 塞进 fat slice*；UFCS／具名已 7；assign-only 假绿）。G.7 补全既有扫描器（STAR＝PTR 元，叶走 `param_elem_elem_pending`）＋既有 dest-SLICE extras wrap ptr 再 wrap slice＋`typeck_coerce_init_expr_to_decl`。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_ptr.x` Ubuntu asm／host-C **7** · mac host-C **7** · `-E` `__xlang_sp`＋`int32_t * __xlang_al`
  - ✅ asm binop `unsafe { e }` peel（双端 L2）：产生点 `glue_try_binop_load_operand` 对 EXPR_BLOCK 返 −2，`unsafe { e }` 主表达式是 wrapper＋stmt_order kind 6（region 池），emit_expr(BLOCK) 在 ARM64 rax 帧 spill 后 CG002。sit-red mac `dyn_add_slice_ptr`／`x + unsafe { *q }` CG002（INDEX-only／`0 + unsafe { *q }`／裸 `unsafe { return x + *q }` 已绿；Ubuntu x86 假绿）。G.7 补 load_operand／clobber 剥透明 BLOCK（kind 6 内 `final_expr`；孪 dest-in-rbx／await／AS）。禁第二套 DEREF 发射。blkpeel-thin inject（禁 mega `-E`）。首参仍 `void* data`。验收：`dyn_add_slice_ptr.x` 双端 asm／host-C **7** · 具名 `x + unsafe { *q }` **3** · `[2]*i32` 双 DEREF **7**
  - ✅ dest-ARRAY extra `[2][]Pair` dest-stamp（双端 L2）：产生点 dest extras dest-ARRAY-of-SLICE 跳过 elem_elem kind 8，`[[{a:2,b:3}],[{a:4,b:4}]]` 停在 nameless STRUCT_LIT 的 TYPE_ARRAY。registry `elem_kind`＝SLICE／`elem_elem_kind`＝NAMED／`param_name`＝Pair 已有。sit-red dyn extra asm／host-C **139**（`(uint8_t[]){(struct )}`；具名／UFCS 已 7；`[2][]i32` 已闭）。G.7 补既有 dest-ARRAY-of-SLICE reconstruct（`param_name` wrap named 再 wrap slice＋`typeck_coerce_init_expr_to_decl`）。禁第二套 dest-ARRAY stamp。首参仍 `void* data`。验收：`dyn_add_arr_slice_named.x` 双端 asm／host-C **7** · `-E` `(struct xlang_slice_Pair[]){__xlang_al+(struct Pair)}`
  - ✅ dest-SLICE extra `[][2]Pair` dest-stamp＋布局（双端 L2）：产生点 dest extras dest-SLICE-of-ARRAY 跳过 elem_elem kind 8，`[[{a:2,b:4}]]` 停在 nameless STRUCT_LIT 的 TYPE_ARRAY；host-C `codegen_emit_slice_of_fixed_array_layouts` 在 prologue 发 `struct Pair (*data)[2]` 先于 `struct Pair`。registry `elem_elem_kind`＝NAMED／`param_name`＝Pair 已有。sit-red dyn extra asm **139**／host-C `(struct )`＋BLD001（具名／UFCS asm 已 7）。G.7 补既有 dest-SLICE-of-ARRAY reconstruct（`param_name` wrap named 再 wrap ARRAY／slice＋`typeck_coerce_init_expr_to_decl`）＋既有 layout walker 挪到 struct 定义后。禁第二套 dest-SLICE stamp／第二套 layout walker。首参仍 `void* data`。验收：`dyn_add_slice_arr_named.x` 双端 asm／host-C **7** · `-E` `struct Pair` 先于 `xlang_slice_xlang_arr2_Pair`＋`__xlang_sp`＋`(struct Pair)`
  - ✅ dest-SLICE extra `[]*Pair` dest-stamp（双端 L2）：产生点 dest extras dest-SLICE-of-PTR 跳过 elem_elem kind 8，`[&n]` 停在 TYPE_ARRAY of PTR（无 dest-SLICE stamp）。registry `elem_kind`＝PTR／`elem_elem_kind`＝NAMED／`param_name`＝Pair 已有。sit-red dyn extra asm **139**／host-C `(struct Pair *[]){&n}` 塞进 wrapper `struct xlang_slice_Pair_p *`（panic: 0；具名／UFCS／`[2]*Pair` 已 7）。G.7 补既有 dest-SLICE-of-PTR reconstruct（`param_name` wrap named 再 wrap ptr／slice＋`typeck_coerce_init_expr_to_decl`）。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_ptr_named.x` 双端 asm／host-C **7** · `-E` `__xlang_sp`＋`struct Pair * __xlang_al[1]`
  - ✅ dest-SLICE extra `[][]i32`／`[][]Pair` dest-stamp（双端 L2）：产生点 dest extras dest-SLICE 跳过 elem kind 11，`[[2,4]]` 停在 TYPE_ARRAY of ARRAY（无 dest-SLICE stamp）。registry `elem_kind`＝SLICE／`elem_elem_kind`＝leaf／`param_name`（扫描器已有）。sit-red dyn extra asm／host-C **139**（`[][]Pair` host-C `(uint8_t[]){(uint8_t[]){(struct )}}`；具名局部已 7）。G.7 补既有 dest-SLICE extras（wrap slice of leaf 再 wrap slice＋`param_name` NAMED＋`typeck_coerce_init_expr_to_decl`）。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_slice.x`／`dyn_add_slice_slice_named.x` 双端 asm／host-C **7** · `-E` `__xlang_sp`＋内层 fat
  - ✅ dest ret `*[2]Pair` dest-stamp（双端 L2）：产生点 dest ret PTR-to-ARRAY 跳过 elem_elem kind 8，`dyn_ret_ty`＝0，调用点 `(void(*)(void*))`。registry `ret_name`＝Pair／`ret_elem_array` ndims／dims（wave438 已有）。sit-red Ubuntu host-C `invalid use of void expression`（mac clang dest-cast of void 假绿 7；asm 已 7）。G.7 补既有 dest ret PTR-to-ARRAY（`ret_name` wrap named 再既有 ARRAY wrap＋wrap ptr）。禁第二套 dest-ret resolve。首参仍 `void* data`。验收：`dyn_ret_ptr_arr_named.x` 双端 asm／host-C **7** · `-E` `(struct Pair *(*)(void*))`＋dest `(struct Pair (*)[2])`
  - ✅ dest-SLICE extra `[]*[N]T` dest-stamp＋emit（双端 L2）：产生点 dest extras dest-SLICE-of-PTR 忽略 `elem_array_ndims`，`[]*[2]i32` 建成 `[]*i32`（typeck `expected *i32, found *[2]i32`）；具名已 dest-stamp，host-C 布局把 ARRAY 标签当 C 类型（`xlang_arr2_int32_t **data`）且 ARRAY_LIT 发 `int32_t * al[]` vs `int32_t (*)[2]`。registry `elem_kind`＝PTR／eek＝leaf／ndims／dims 已有。G.7 补既有 dest extras dest-SLICE-of-PTR（ndims wrap ARRAY 再既有 wrap ptr／slice）＋既有 layout walker PTR-to-ARRAY（`emit_c_ptr_to_fixed_array_decl` 名 `(*data)` → `E (*(*data))[N]`）＋dest-SLICE ARRAY_LIT（`E (*__xlang_al[n])[N]`）。禁第二套 dest-SLICE stamp／layout walker。首参仍 `void* data`。验收：`dyn_add_slice_ptr_arr.x` 双端 asm／host-C **7** · 具名 lets **7** · `-E` `int32_t (*(*data))[2]`＋`static int32_t (*__xlang_al[1])[2]`
  - ✅ dest-SLICE extra `[]*[]i32` dest-stamp（双端 L2）：产生点 skip-trait `[]*` 后 `[` `]` 走 wave434 把 elem_kind 置 −1，dest extras dest-SLICE-of-PTR 不入。sit-red dyn INDEX **139**／**134**（assign-only 假绿 7；具名／UFCS 已 dest-stamp）。G.7 补既有扫描器（keep PTR，ndims＝−2 表 SLICE pointee，accessor 无效仍 −1；叶走 eek）＋既有 dest extras dest-SLICE-of-PTR（ndims＝−2 wrap SLICE 再既有 wrap ptr／slice＋`typeck_coerce_init_expr_to_decl`）。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_ptr_slice.x` 双端 host-C **7** · mac asm **7** · `-E` `__xlang_sp`＋`struct xlang_slice_int32_t * __xlang_al[1]`。Ubuntu asm INDEX of `[]*[]i32` 仍 **134**（具名 let 同红，非 dest extras）
  - ✅ dest-SLICE extra `[][][]T` dest-stamp（双端 L2）：产生点 skip-trait `[][]` 后 `[` `]` 走 wave434 把 elem_kind 置 −1，dest extras dest-SLICE-of-SLICE 不入；只存 ndims＝−2 无 impl-match extra peel 会 T001（pipeline pelem＝SLICE，registry eek＝leaf）。sit-red dyn INDEX **139**（具名／UFCS 已 dest-stamp 7）。G.7 补既有扫描器（keep SLICE｜PTR，ndims＝−2 表 extra SLICE wrap，与 `[]*[]T` 同哨兵，判别是 elem_kind；叶走 eek）＋既有 SLICE-of-SLICE walk extra peel＋既有 dest extras dest-SLICE-of-SLICE（ndims＝−2 第三 wrap＋`typeck_coerce_init_expr_to_decl`）。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_slice_slice.x` 双端 asm／host-C **7**
  - ✅ dest-SLICE extra `[][][][]T` dest-stamp（双端 L2）：产生点 skip-trait `[][][]` 后再 `[` `]` 把 ndims＝−2 再写一遍（extra wrap 仍 1）；impl-match 只 peel 一次，pipeline pelem 仍是 SLICE vs eek＝leaf → T001（dyn／具名同红；UFCS／模块函数已 7／6）。G.7 补既有扫描器（extra wrap 计数进 dims[0]：0 表 1＝三层、2＝四层；禁 −3）＋既有 SLICE-of-SLICE walk extra peels＋既有 dest extras dest-SLICE-of-SLICE extra wraps＋ndims＝−2 时 dim accessor。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_slice_slice_slice.x` 双端 asm／host-C **7** · `-E` 四层 dest-SLICE wrap
  - ✅ dest extras dest-SLICE of PTR `[]*[][]T` dest-stamp（双端 L2）：产生点 skip-trait `[]*` 后再空 `[]` 把 ndims＝−2 再写一遍（increment 只认 elem＝SLICE，extra wrap 仍 1）；dest extras dest-SLICE-of-PTR 只 wrap 一次 → dest 是 `[]*[]i32` 不是 `[]*[][]i32`。sit-red dyn extra compile＝0 run＝1 panic：0（具名／UFCS／模块函数已 dest-stamp 7；assign-only 假绿 7）。G.7 补既有扫描器 extra wrap 计数（PTR 也 increment dims[0]：0 表 1＝`[]*[]T`、2＝`[]*[][]T`；禁 −3）＋既有 dest extras dest-SLICE-of-PTR extra wraps（dim accessor）。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_ptr_slice_slice.x` 双端 asm／host-C **7** · `-E` `__xlang_sp`＋`struct xlang_slice_xlang_slice_int32_t *`
  - ✅ dest extras dest-ARRAY of PTR `[2]*[][]T` dest-stamp（双端 L2）：产生点 ARRAY＋PTR impl-match 对 ndims＝−2 只 peel 一次（pelem 仍是 SLICE vs eek＝leaf）→ T001；dest extras dest-ARRAY-of-PTR 只 wrap 一次 → dest 会是 `[2]*[]i32` 不是 `[2]*[][]i32`。sit-red dyn extra T001（具名／UFCS／模块函数已 dest-stamp 7；邻域 `[2]*[]i32` 已 6；assign-only 假绿 7）。扫描器 extra wrap 计数已覆盖 PTR。G.7 补既有 ARRAY＋PTR walk extra peels（孪 SLICE-of-SLICE：0 表 1＝`[2]*[]T`、2＝`[2]*[][]T`；禁 −3）＋既有 dest extras dest-ARRAY-of-PTR extra wraps（dim accessor）。禁第二套 dest-ARRAY stamp。首参仍 `void* data`。验收：`dyn_add_arr_ptr_slice_slice.x` 双端 asm／host-C **6** · `-E` `(struct xlang_slice_xlang_slice_int32_t *[]){&(r0), &(r1)}`＋wrapper `void* data`
  - ✅ dest extras dest-ARRAY of SLICE `[2][][]T` dest-stamp（双端 L2）：产生点 dest extras dest-ARRAY-of-SLICE 只 wrap 一次 → dest 是 `[2][]i32` 不是 `[2][][]i32`；嵌套 ARRAY_LIT `[[[2, 4]], [[3, 5]]]` 停在 `(int32_t[][1][2])` → 139。sit-red dyn extra 嵌套 lit **139**（具名／UFCS／模块函数 typed lets 已 dest-stamp 6；邻域 `[2][]i32` 已 7；impl-match 已在 SLICE 层匹配，非 T001）。扫描器 extra wrap 计数已覆盖 SLICE elem。G.7 补既有 dest extras dest-ARRAY-of-SLICE extra wraps（dim accessor：0 表 1＝`[2][][]T`、2＝`[2][][][]T`；禁 −3）。禁第二套 dest-ARRAY stamp／impl-match extra peels。首参仍 `void* data`。验收：`dyn_add_arr_slice_slice.x` 双端 asm／host-C **6** · `-E` `(struct xlang_slice_xlang_slice_int32_t[]){…__xlang_al…}`＋wrapper `void* data`
  - ✅ dest extras dest-SLICE of ARRAY extra `[][2][]T` dest-stamp（双端 L2）：产生点 dest extras dest-SLICE-of-ARRAY 只 wrap 一次（或 store 置 elem_kind＝−1 跳过 dest extras）→ dest 是 `[][2]i32` 不是 `[][2][]i32`；嵌套 ARRAY_LIT `[[[2], [4]]]` 停在未 stamp → 139。sit-red dyn extra 嵌套 lit **139**（具名／UFCS／模块函数已 dest-stamp 6／7；邻域 `[][2]i32` 已 7）。ndims＝−2 会冲掉 ARRAY dim（禁 −3／新字段）。存储＝elem＝ARRAY／eek＝leaf／ndims＝1／dims[0]＝2／extra wrap 在未用槽 dims[ndims]（1＝`[][2][]T`；0＝无 extra＝`[][2]i32`）。G.7 补既有扫描器（keep ARRAY；extra wrap 进 dims[ndims]；outer 须 SLICE）＋既有 ARRAY walk extra peels＋既有 dest extras dest-SLICE-of-ARRAY extra wraps＋dim accessor dim_ix＝ndims。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_arr_slice.x` 双端 asm／host-C **7** · `-E` `struct xlang_slice_xlang_arr2_xlang_slice_int32_t`＋`__xlang_al[][2]`＋wrapper `void* data`
  - ✅ dest extras dest-SLICE of ARRAY extra `[][2]*T` dest-stamp（双端 L2）：产生点 extra STAR after ARRAY 走 token_to_type_kind＝−1 再 want_param_ty＝0，eek 未捕获；impl-match leftover PTR vs eeek＝−1 → T001。sit-red dyn／具名／UFCS **T001**（模块函数／assign 已 dest-stamp 6；邻域 `[][2]i32`／`[]*[2]i32`／`[2]*i32` 已 7）。ndims＝−2 会冲掉 ARRAY dim（禁 −3／新字段）。存储＝elem＝ARRAY／eek＝leaf／ndims＝1／dims[0]＝2／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`[][2]*T`；0＝无 extra PTR＝`[][2]i32`；extra SLICE 仍 dims[ndims]）。G.7 补既有扫描器（keep ARRAY；extra PTR 进 dims[ndims+1]；outer 须 SLICE）＋既有 ARRAY walk extra PTR peels＋既有 dest extras dest-SLICE-of-ARRAY extra PTR wraps＋dim accessor dim_ix＝ndims+1。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_arr_ptr.x` 双端 asm／host-C **7** · `-E` `struct xlang_slice_xlang_arr2_int32_t_p`＋`int32_t * (*data)[2]`＋`__xlang_al[1][2]`＋wrapper `void* data`
  - ✅ dest extras dest-ARRAY of ARRAY extra `[2][2][]T` flatten（双端 L2）：产生点 asm flatten 把 dest-ARRAY of ARRAY of SLICE 写成 i32 叶子；dest extras dest-ARRAY wrap 已 dest-stamp（host-C 嵌套 lit 已 8）。sit-red dyn／具名／UFCS／模块函数 asm **139**；asg asm **1**。存储＝ARRAY ndims＝2 dims＝[2,2] elem＝SLICE eek＝leaf（已正确）。G.7 补既有 `pipeline_asm_emit_array_lit_flat_elf_c`（mega＋seed＋arrcopy thin 同符号：dest elem 直接是 SLICE 则逐格 `glue_emit_slice_from_array_let_init`，与 dest-ARRAY extra `[2][]i32` 同写入器；禁 −3／第二套 flatten）。首参仍 `void* data`。验收：`dyn_add_arr_arr_slice.x` 双端 asm／host-C **8** · 具名／asg **8**
  - ✅ dest extras dest-ARRAY of SLICE extra `[2][]*T` dest-stamp（双端 L2）：产生点 dest extras dest-ARRAY-of-SLICE 只 wrap 一次 → dest 是 `[2][]i32` 不是 `[2][]*i32`；extra STAR after `[N][]` 走 token_to_type_kind＝−1（eek 未捕获）但 impl-match 已在 SLICE 层匹配（非 T001）。sit-red dyn extra 嵌套 lit **139**（具名／UFCS／typed lets 已 dest-stamp 6／7；邻域 `[2][]i32`／`[2][][]i32`／`[][2]*i32`／`[2]*i32` 已 7／6／7／7）。ndims＝−2 是 extra SLICE（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims＝0／extra PTR wrap 在未用槽 dims[0]（1＝`[2][]*T`；0＝无 extra PTR＝`[2][]i32`）。G.7 补既有扫描器（keep SLICE；extra PTR 进 dims[0]；outer 须 ARRAY 故 `[][]*T` dest-SLICE-of-SLICE extra PTR 仍延期）＋既有 dest extras dest-ARRAY-of-SLICE extra PTR wraps＋dim accessor ndims＝0 dim_ix＝0。禁第二套 dest-ARRAY stamp／impl-match extra PTR peels。首参仍 `void* data`。验收：`dyn_add_arr_slice_ptr.x` 双端 asm／host-C **7** · `-E` `struct xlang_slice_int32_t_p`＋`int32_t * *data`＋`__xlang_al[2]`＋wrapper `void* data`
  - ✅ dest extras dest-SLICE of SLICE extra `[][]*T` dest-stamp（双端 L2）：产生点 dest extras dest-SLICE-of-SLICE 只 wrap 两次 → dest 是 `[][]i32` 不是 `[][]*i32`；extra STAR after `[][]` 原先只认 ARRAY 外层（`[2][]*T`），eek 未捕获故 dest extras 跳过 extra PTR（具名／UFCS 已 dest-stamp 7）。只存 leaf 会 T001（impl-match leftover PTR vs eeek＝leaf）。sit-red dyn extra 嵌套 lit **139**（typed lets 曾 139；邻域 `[][]i32`／`[2][]*i32`／`[][2]*i32`／`[]*i32`／`[][][]i32` 已 7）。ndims＝−2 是 extra SLICE（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims＝0／extra PTR wrap 在未用槽 dims[0]（1＝`[][]*T`；0＝无 extra PTR＝`[][]i32`）。G.7 补既有扫描器（keep SLICE；extra PTR 进 dims[0]；ARRAY 或 SLICE 外层）＋既有 SLICE-of-SLICE walk extra PTR peels leftover PTR＋既有 dest extras dest-SLICE-of-SLICE extra PTR wraps＋dim accessor ndims＝0 dim_ix＝0。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_slice_ptr.x` 双端 asm／host-C **7** · `-E` `struct xlang_slice_xlang_slice_int32_t_p`＋`int32_t * *data`＋wrapper `void* data`
  - ✅ dest extras dest-ARRAY of SLICE extra `[2][][2]T` dest-stamp（双端 L2）：产生点 dest extras dest-ARRAY-of-SLICE 只 wrap 一次 → dest 是 `[2][]i32` 不是 `[2][][2]i32`；嵌套 ARRAY_LIT `[[[2, 3]], [[1, 4]]]` 停在未 stamp → 139。sit-red dyn extra 嵌套 lit **139**（具名／UFCS／asg／typed lets 已 dest-stamp 7；邻域 `[2][]i32`／`[][2]i32`／`[2][][]i32`／`[2][]*i32` 已 7／7／6／7）。impl-match leftover SLICE vs eek＝SLICE 非 T001。ndims＝−2 是 extra SLICE；ndims＝0 dims[0] 是 extra PTR（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／dims[0]＝M（wave437 pending LBRACKET 已收集 inner ARRAY）。G.7 补既有 dest extras dest-ARRAY-of-SLICE extra ARRAY wraps（inner-first then wrap SLICE then ARRAY）。禁第二套 dest-ARRAY stamp／impl-match extra ARRAY peels。首参仍 `void* data`。验收：`dyn_add_arr_slice_arr.x` 双端 asm／host-C **7** · extra wrap `[2][][2][2]i32` **7** · `-E` `struct xlang_slice_xlang_arr2_int32_t`＋`int32_t (*data)[2]`＋`__xlang_al[][2]`＋wrapper `void* data`。host-C suffix 仍 `(*)(void*, …)` 完备／host-C `[2]*[2]i32` INDEX 完备／host-C `[][2][]T` 嵌套 GNU static 完备／`[][][]*T` ndims＝−2 extra STAR 仍延期／`[]*[2][]T` 延期
  - ✅ dest extras dest-SLICE of SLICE extra `[][][2]T` dest-stamp＋布局（双端 L2）：产生点 impl-match leftover ARRAY vs eeek＝leaf → T001；dest extras dest-SLICE-of-SLICE 只 wrap 两次 → dest 是 `[][]i32` 不是 `[][][2]i32`；host-C 缺 `struct xlang_slice_xlang_slice_xlang_arr2_int32_t`。sit-red dyn extra **T001**（具名／UFCS／modfn／asg 已 dest-stamp 7／7／6／6；邻域 `[][]i32`／`[2][][2]i32`／`[][2]i32`／`[][]*i32`／`[][][]i32` 已 7）。ndims＝−2 是 extra SLICE；ndims＝0 dims[0] 是 extra PTR（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／dims[0]＝M（wave437 pending LBRACKET 已收集 inner ARRAY）。G.7 补既有 SLICE-of-SLICE walk extra ARRAY peels leftover ARRAY＋既有 dest extras dest-SLICE-of-SLICE extra ARRAY wraps（inner-first then wrap SLICE twice）＋既有 `codegen_emit_slice_of_fixed_array_layouts`（SLICE-of-SLICE 链触 ARRAY／PTR 才发外层 fat；标量 `[][]T` 仍 nest table；同 walker 补 `[][]*T` 外层 `_p` fat）。禁第二套 dest-SLICE stamp／第二套 layout walker。首参仍 `void* data`。验收：`dyn_add_slice_slice_arr.x` 双端 asm／host-C **7** · extra wrap `[][][2][2]i32` **7** · `[][]*T` host-C **7** · `-E` `struct xlang_slice_xlang_slice_xlang_arr2_int32_t`＋inner `int32_t (*data)[2]`＋`__xlang_al[][2]`＋wrapper `void* data`
  - ✅ dest extras dest-SLICE of SLICE extra `[][][]*T` dest-stamp（双端 L2）：产生点 extra STAR after `[][][]`（ndims＝−2）置 elem_kind＝−1，dest extras dest-SLICE-of-SLICE 不入 → 嵌套 ARRAY_LIT **139**；只存 leaf 会 T001（leftover PTR vs eeek＝leaf after extra SLICE peels）。sit-red dyn extra **139**（具名／UFCS／modfn／asg 已 dest-stamp 7；邻域 `[][]*i32`／`[][][]i32`／`[][][][]i32`／`[][][2]i32`／`[2][]*i32` 已 7）。ndims＝−2 dims[0] 是 extra SLICE（禁 −3／复用 dims[0]）。存储＝elem＝SLICE／eek＝leaf／ndims＝−2／extra PTR wrap 在未用槽 dims[1]（1＝`[][][]*T`；0＝无 extra PTR＝`[][][]T`）。G.7 补既有扫描器（keep SLICE；extra PTR 进 dims[1]；outer 须 SLICE 故 `[2][][]*T` 仍延期）＋既有 SLICE-of-SLICE walk extra PTR peels leftover PTR＋既有 dest extras dest-SLICE-of-SLICE extra PTR wraps＋dim accessor ndims＝−2 dim_ix＝1。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_slice_slice_ptr.x` 双端 asm／host-C **7** · extra wrap `[][][][]*i32` **7** · `-E` `struct xlang_slice_xlang_slice_xlang_slice_int32_t_p`＋inner `int32_t * *data`＋wrapper `void* data`
  - ✅ dest extras dest-SLICE of PTR extra `[]*[2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `[]*[N]` 走 token_to_type_kind＝−1 再 want_param_ty＝0，leaf T 未 commit，COMMA／RPAREN wave434 `*T[N]` lift 把 kind 改成 ARRAY。sit-red 具名／dyn extra **T001** leftover SLICE vs ARRAY（dest extras wrap-once dest-stamps `[]*[2]i32`；ADDR_OF of typed `[2]*i32` 另 139）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`[]*[2]*T`；0＝无 extra PTR＝`[]*[2]i32`；extra SLICE 仍 dims[ndims]；`[]*[2][]*T` 两槽可同时置）。与 dest extras dest-SLICE of ARRAY extra `[][2]*T` 同未用槽（判别是 elem_kind PTR vs ARRAY）。消费＝dest extras wrap PTR of leaf extra times then extra SLICE then ARRAY then wrap PTR then outer SLICE。SLICE-outer PTR-elem impl-match leftover PTR vs eek＝PTR 非 T001。outer 须 SLICE 故 `*[N]*T` 仍延期。G.7 补既有扫描器（keep PTR；extra PTR 进 dims[ndims+1]）＋既有 dest extras dest-SLICE-of-PTR extra PTR wraps＋dim accessor dim_ix＝ndims+1。禁第二套 dest-SLICE stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_slice_ptr_arr_ptr.x` 双端 asm／host-C **7** · 具名／UFCS **7** · extra wrap `[]*[2][]*T` **7** · `-E` `struct xlang_slice_xlang_arr2_int32_t_p_p`＋inner `int32_t * (*(*data))[2]`＋wrapper `void* data`
  - ✅ dest extras dest-SLICE of PTR extra `[]*[2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `[]*` then `[N]` 置 elem_kind＝−1，dest extras dest-SLICE-of-PTR 不 extra-wrap SLICE after ARRAY → ADDR_OF of typed `[2][]i32` **run＝1 panic**（host-C **133**）。sit-red dyn extra **1**（具名／UFCS／modfn／asg 已 dest-stamp 7／7／6／7；邻域 `[]*[2]i32`／`[][2][]i32`／`[]*[]i32`／`[]*[][]i32` 已 7）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／extra SLICE wrap 在未用槽 dims[ndims]（1＝`[]*[2][]T`；2＝`[]*[2][][]T`；0＝无 extra＝`[]*[2]i32`）。与 dest extras dest-SLICE-of-ARRAY extra `[][2][]T` 同未用槽（判别是 elem_kind PTR vs ARRAY）。G.7 补既有扫描器（keep PTR；extra wrap 进 dims[ndims]；ARRAY 或 PTR elem；outer 须 SLICE 故 `*[N][]T` 仍延期；ndims＝−2 第一支不在 ndims＞0 时抢走 extra wrap）＋既有 dest extras dest-SLICE-of-PTR extra SLICE wraps＋dim accessor dim_ix＝ndims。禁第二套 dest-SLICE stamp／impl-match extra peels（SLICE-outer PTR-elem 不 walk leftover SLICE，非 T001）。首参仍 `void* data`。验收：`dyn_add_slice_ptr_arr_slice.x` 双端 asm／host-C **7** · extra wrap `[]*[2][][]i32` **7** · `-E` `struct xlang_slice_xlang_arr2_xlang_slice_int32_t_p`＋`struct xlang_slice_int32_t (*(*data))[2]`＋wrapper `void* data`
  - ✅ dest extras dest-ARRAY of SLICE extra `[2][][]*T` dest-stamp（双端 L2）：产生点 extra STAR after `[N][][]`（ndims＝−2、ARRAY 外层）置 elem_kind＝−1，dest extras dest-ARRAY-of-SLICE 不 extra-wrap PTR after extra SLICE wraps → dest 是 `[2][][]i32` 不是 `[2][][]*i32`；嵌套 ARRAY_LIT **139**。sit-red dyn extra **139**（host-C **133**；具名／UFCS／modfn／asg／lets 已 dest-stamp 7／7／6／7／7；邻域 `[2][]*i32`／`[2][][]i32`／`[][][]*i32`／`[][]*i32`／`[2][][2]i32` 已 7／6／7／7／7）。ndims＝−2 dims[0] 是 extra SLICE（禁 −3／复用 dims[0]）。存储＝elem＝SLICE／eek＝leaf／ndims＝−2／extra PTR wrap 在未用槽 dims[1]（1＝`[2][][]*T`；0＝无 extra PTR＝`[2][][]T`；与 `[][][]*T` 同编码；判别是 ARRAY vs SLICE 外层）。G.7 补既有扫描器（ndims＝−2 extra STAR 认 ARRAY 或 SLICE 外层；keep SLICE；extra PTR 进 dims[1]）＋既有 dest extras dest-ARRAY-of-SLICE extra PTR wraps＋dim accessor ndims＝−2 dim_ix＝1。禁第二套 dest-ARRAY stamp／impl-match extra PTR peels（ARRAY leftover SLICE vs eek＝SLICE，非 T001）。首参仍 `void* data`。验收：`dyn_add_arr_slice_slice_ptr.x` 双端 asm／host-C **7** · extra wrap `[2][][][]*i32` **7** · `-E` `struct xlang_slice_xlang_slice_int32_t_p[]`＋inner `int32_t *`＋wrapper `void* data`
  - ✅ dest extras dest-ARRAY of SLICE extra wrap `[2][][2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `[N][][M]`（elem＝SLICE、ARRAY 外层、ndims≥1）走 wave434 置 elem_kind＝−1，dest extras 跳过。sit-red dyn extra 嵌套 lit **139**（具名／UFCS 已 dest-stamp 7）。ndims＝−2 会冲掉 `[M]`（禁 −3／复用 dims[0..ndims−1]）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／extra SLICE wrap 在未用槽 dims[ndims+1]（1＝`[2][][2][]T`；2＝`[2][][2][][]T`；0＝无 extra wrap＝`[2][][2]T`）。extra PTR of `[2][][2]*T` 仍 dims[ndims]（不重开）。消费＝dest extras wrap extra SLICE of leaf extra times then wrap ARRAY inner-first then wrap SLICE then ARRAY。ARRAY leftover SLICE vs eek＝SLICE 非 T001。`[][][2][]T` 已闭。G.7 补既有扫描器（keep SLICE；extra SLICE 进 dims[ndims+1]；先 commit pending dims）＋既有 dest extras dest-ARRAY-of-SLICE extra SLICE wraps＋dim accessor dim_ix＝ndims+1。禁第二套 dest-ARRAY stamp／impl-match extra SLICE peels。首参仍 `void* data`。验收：`dyn_add_arr_slice_arr_slice.x` 双端 asm／host-C **7** · 具名／UFCS **7** · `-E` `struct xlang_slice_xlang_arr2_xlang_slice_int32_t`＋inner `struct xlang_slice_int32_t (*data)[2]`＋`__xlang_al[1][2]`＋wrapper `void* data`。extra wrap extra `[2][][2][][]T` 已闭（正确最内层 `[[2]]`）
  - ✅ dest extras dest-ARRAY of SLICE extra wrap extra `[2][][2][][]T` dest-stamp（双端 L2）：上叶 COUNT＝2 存储／消费已在（dims[ndims+1] extra SLICE wrap）。sit-red extra lit **139**／具名 **195** 是探针最内层 lit 写成 `[2]`（i32）而 dest 要 `[][]i32`（typeck mismatch＋SIGSEGV）。正确最内层 `[[2]]`。G.7 不另开 dest-ARRAY stamp／禁 −3／assemble mega／assemble parser.x。`[][][2][]T` 已闭。首参仍 `void* data`。验收：`dyn_add_arr_slice_arr_slice_slice.x` 双端 asm／host-C **7** · 具名／UFCS **7** · `-E` `struct xlang_slice_xlang_arr2_xlang_slice_xlang_slice_int32_t`＋inner `struct xlang_slice_xlang_slice_int32_t (*data)[2]`＋`__xlang_al[1][2]`＋wrapper `void* data`
  - ✅ dest extras dest-SLICE of SLICE extra wrap `[][][2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `[][][M]`（elem＝SLICE、SLICE 外层、ndims≥1）走 wave434 置 elem_kind＝−1，dest extras 跳过。sit-red dyn extra compile＝0 run＝1 panic（extra 停在 `int32_t[][1][2][1]`；具名／UFCS 已 dest-stamp 7）。store-only 无 impl-match extra SLICE peels 是 T001 leftover SLICE vs eeek＝leaf after extra ARRAY peels。ndims＝−2 会冲掉 `[M]`（禁 −3／复用 dims[0..ndims−1]）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／extra SLICE wrap 在未用槽 dims[ndims+1]（1＝`[][][2][]T`；2＝`[][][2][][]T`；0＝无 extra wrap＝`[][][2]T`）。extra PTR of `[][][2]*T` 仍 dims[ndims]（不重开）。消费＝dest extras wrap extra SLICE of leaf extra times then wrap ARRAY inner-first then wrap SLICE twice；impl-match extra SLICE peels leftover SLICE after extra ARRAY peels（before extra PTR）。G.7 补既有扫描器（ARRAY 或 SLICE 外层；keep SLICE；extra SLICE 进 dims[ndims+1]；先 commit pending dims）＋既有 SLICE-of-SLICE walk extra SLICE peels＋既有 dest extras dest-SLICE-of-SLICE extra SLICE wraps＋dim accessor dim_ix＝ndims+1。禁第二套 dest-SLICE stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_slice_slice_arr_slice.x` 双端 asm／host-C **7** · 具名／UFCS **7** · extra wrap extra COUNT＝2 `[][][2][][]T` **7** · extra PTR `[][][2][]*T` unsafe **7** · `-E` `struct xlang_slice_xlang_slice_xlang_arr2_xlang_slice_int32_t`＋inner `struct xlang_slice_int32_t (*data)[2]`＋`__xlang_al[1][2]`＋wrapper `void* data`
  - ✅ dest extras dest-ARRAY of PTR extra `[2]*[2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `[K]*[N]`（elem＝PTR、ARRAY 外层、ndims≥1）只认 SLICE 外层，ARRAY 外层走 token_to_type_kind＝−1 再 want_param_ty＝0，leaf T 未 commit。sit-red extra／具名／UFCS **T001** leftover PTR vs eeek＝−1；store-only 无 ARRAY leftover extra PTR peels 是 leftover PTR vs eeek＝leaf after extra ARRAY peels。dest extras dest-ARRAY-of-PTR wrap-once dest-stamps `[2]*[2]i32`。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`[2]*[2]*T`；0＝无 extra PTR＝`[2]*[2]i32`；extra SLICE 仍 dims[ndims]；`[2]*[2][]*T` 两槽可同时置）。消费＝dest extras wrap extra PTR of leaf extra times then extra SLICE then ARRAY inner-first then wrap PTR then outer ARRAY；ARRAY leftover extra PTR peels leftover PTR after extra ARRAY peels（after extra SLICE）。判别 vs dest extras dest-SLICE of PTR extra `[]*[2]*T`（同未用槽）是 ARRAY vs SLICE 外层。PTR-outer `*[N]*T` 已闭（另叶）。G.7 补既有扫描器（ARRAY 或 SLICE 外层；keep PTR；extra PTR 进 dims[ndims+1]）＋既有 ARRAY leftover PTR walk extra PTR peels＋既有 dest extras dest-ARRAY-of-PTR extra PTR wraps＋dim accessor dim_ix＝ndims+1。禁第二套 dest-ARRAY stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_arr_ptr_arr_ptr.x` 双端 asm／host-C **6** · 具名／UFCS **6** · extra wrap extra PTR COUNT＝2 `[2]*[2]**T` **6** · extra wrap extra PTR `[2]*[2][]*T` unsafe **6** · `-E` `int32_t * (**p)[2]`＋wrapper `void* data`
  - ✅ PTR-outer extra empty `[]` `*[][2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `*[][N]`（elem＝SLICE、PTR 外层、ndims≥1）只认 ARRAY／SLICE 外层，PTR 外层走 wave434 置 elem_kind＝−1，leaf T 未 commit，leftover 跳过 eek＝−1（extra／具名 ADDR_OF of typed `[][2][]i32` dest-stamp via the formal＝假绿；嵌套 extra lit dest extras dest-PTR 仍禁 → CG002）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE wrap 在未用槽 dims[ndims+1]（1＝`*[][2][]T`；2＝`*[][2][][]T`；0＝无 extra wrap＝`*[][2]i32`／`*[][2]*T`）／extra PTR 仍 dims[ndims]（两槽＝`*[][2][]*T`）。判别 vs dest extras dest-ARRAY of SLICE extra wrap `[2][][2][]T`／dest extras dest-SLICE of SLICE extra wrap `[][][2][]T`（同未用槽）是 PTR vs ARRAY vs SLICE 外层。消费＝leftover PTR vs eek＝SLICE 非 T001（walk 先剥 leftover SLICE 再 extra ARRAY 再 extra SLICE 再 extra PTR）；extra ADDR_OF of typed `[][2][]i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 extra empty `[]` 扫描器（SLICE 元；ARRAY 或 SLICE 或 PTR 外层；keep SLICE；extra SLICE 进 dims[ndims+1]）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_slice_arr_slice.x` 双端 asm／host-C **7** · 具名／UFCS **7** · extra wrap COUNT＝2 `*[][2][][]T` **7** · `-E` `struct xlang_slice_xlang_arr2_xlang_slice_int32_t *`＋inner `struct xlang_slice_int32_t (*data)[2]`＋wrapper `void* data`
  - ✅ PTR-outer extra STAR `*[][2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `*[][N]`（elem＝SLICE、PTR 外层、ndims≥1）只认 ARRAY／SLICE 外层，PTR 外层走 token_to_type_kind＝−1 再 want_param_ty＝0，leaf T 未 commit，param_elem_dim_n 仍活，COMMA／RPAREN wave434 `*T[N]` lift 把 kind 改成 ARRAY。sit-red extra／具名／UFCS **T001** leftover PTR vs ARRAY。`*[]*T` leftover 跳过 eek＝−1（extra ADDR_OF of typed `[]*i32` dest-stamp via the formal＝假绿）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／dims[0]＝M／extra PTR wrap 在未用槽 dims[ndims]（1＝`*[][2]*T`；2＝`*[][2]**T`；0＝无 extra PTR＝`*[][2]i32`；extra SLICE 仍 dims[ndims+1]）。判别 vs dest extras dest-ARRAY of SLICE extra `[2][][2]*T`／dest extras dest-SLICE of SLICE extra `[][][2]*T`（同未用槽）是 PTR vs ARRAY vs SLICE 外层。消费＝leftover PTR vs eek＝SLICE 非 T001（walk 先剥 leftover SLICE 再 extra ARRAY 再 extra PTR）；extra ADDR_OF of typed `[][2]*i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 extra STAR 扫描器（SLICE 元；ARRAY 或 SLICE 或 PTR 外层；keep SLICE；extra PTR 进 dims[ndims]）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_slice_arr_ptr.x` 双端 asm／host-C **7** · 具名／UFCS **7** · extra wrap COUNT＝2 `*[][2]**T` **7** · `-E` `struct xlang_slice_xlang_arr2_int32_t_p *`＋inner `int32_t * (*data)[2]`＋wrapper `void* data`
  - ✅ dest extras dest-ARRAY of PTR extra empty `[]` `[2]*[2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `[K]*[N]`（elem＝PTR、ARRAY 外层、ndims≥1）只认 SLICE／PTR 外层，PTR 元＋ARRAY 外层走 wave434 置 elem_kind＝−1，leaf T 未 commit，leftover 跳过 eek＝−1（extra ADDR_OF of typed `[2][]i32` dest-stamp via the formal＝假绿；嵌套 ARRAY_LIT dest extras wrap-once dest-stamps `[2]*[2]i32` → CG002）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE wrap 在未用槽 dims[ndims]（1＝`[2]*[2][]T`；2＝`[2]*[2][][]T`；0＝无 extra＝`[2]*[2]i32`／`[2]*[2]*T`）／extra PTR 仍 dims[ndims+1]（两槽＝`[2]*[2][]*T`）。判别 vs dest extras dest-SLICE of PTR extra `[]*[2][]T`／PTR-elem＋PTR-outer `**[2][]T`（同未用槽）是 ARRAY vs SLICE vs PTR 外层。消费＝leftover PTR vs eek＝PTR 非 T001；extra ADDR_OF of typed `[2][]i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）；dest extras dest-ARRAY-of-PTR extra SLICE wraps 已活。G.7 补既有 extra empty `[]` 扫描器（PTR 元；ARRAY 或 SLICE 或 PTR 外层；keep PTR；extra SLICE 进 dims[ndims]）。禁 −3／第二套 dest-ARRAY stamp／dest extras dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_arr_ptr_arr_slice.x` 双端 asm／host-C **6** · 具名／UFCS **6** · extra wrap COUNT＝2 `[2]*[2][][]T` **6** · extra wrap extra PTR `[2]*[2][]*T` **6** · `-E` `struct xlang_slice_int32_t (**p)[2]`＋wrapper `void* data`
  - ✅ PTR-elem＋PTR-outer extra empty `[]` `**[2][]T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `**[N]`（elem＝PTR、PTR 外层、ndims≥1）只认 ARRAY／SLICE 外层或 ARRAY 元 PTR 外层，PTR 元＋PTR 外层走 wave434 置 elem_kind＝−1，leaf T 未 commit，leftover 跳过 eek＝−1（extra／具名 dest-stamp via the formal＝假绿）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE wrap 在未用槽 dims[ndims]（1＝`**[2][]T`；2＝`**[2][][]T`；0＝无 extra＝`**[2]i32`／`**[2]*T`）／extra PTR 仍 dims[ndims+1]（两槽＝`**[2][]*T`）。判别 vs dest extras dest-SLICE of PTR extra `[]*[2][]T`／PTR-outer `*[2][]T`（同未用槽）是 PTR vs SLICE 外层及 PTR vs ARRAY 元。消费＝leftover PTR vs eek＝PTR 非 T001；extra ADDR_OF of typed `*[2][]i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 extra empty `[]` 扫描器（ARRAY 或 PTR 元；SLICE 或 PTR 外层；keep PTR；extra SLICE 进 dims[ndims]）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_ptr_arr_slice.x` 双端 asm／host-C **7** · 具名／UFCS named A **7** · extra wrap COUNT＝2 `**[2][][]T` **7** · extra wrap extra PTR `**[2][]*T` **7** · `-E` `struct xlang_slice_int32_t * * p`＋wrapper `void* data`
  - ✅ PTR-elem＋PTR-outer extra `**[2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `**[N]`（elem＝PTR、PTR 外层、ndims≥1）只认 ARRAY 或 SLICE 外层，PTR 外层走 token_to_type_kind＝−1 再 want_param_ty＝0，leaf T 未 commit，COMMA／RPAREN wave434 `*T[N]` lift 把 kind 改成 ARRAY。sit-red extra／具名／UFCS **T001** leftover PTR vs ARRAY。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝PTR／eek＝leaf／ndims≥1／dims[0]＝N／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`**[2]*T`；0＝无 extra PTR＝`**[2]i32`；extra SLICE 仍 dims[ndims]；`**[2][]*T` 两槽可同时置）。判别 vs dest extras dest-ARRAY of PTR extra `[2]*[2]*T`／dest extras dest-SLICE of PTR extra `[]*[2]*T`（同未用槽）是 PTR vs ARRAY vs SLICE 外层。消费＝leftover PTR vs eek＝PTR 非 T001；extra ADDR_OF of typed `*[2]*i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 extra STAR 扫描器（PTR 元；ARRAY 或 SLICE 或 PTR 外层；keep PTR；extra PTR 进 dims[ndims+1]）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_ptr_arr_ptr.x` 双端 asm／host-C **7** · 具名／UFCS **7** · extra wrap extra PTR COUNT＝2 `**[2]**T` **7** · extra wrap extra SLICE `**[2][]*T` **7** · `-E` `int32_t * * * p`＋wrapper `void* data`。extra empty `[]` PTR-elem＋PTR-outer `**[2][]T` 已闭
  - ✅ PTR-outer extra wrap extra PTR `*[2][]*T` dest-stamp（双端 L2）：产生点 extra empty `[]` after `*[N]`（elem＝ARRAY、PTR 外层、ndims≥1）只认 SLICE 外层，PTR 外层走 wave434 置 elem_kind＝−1（leaf T 未 commit；leftover walk 跳过 eek＝−1＝假绿）。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝ARRAY／eek＝leaf／ndims≥1／dims[0]＝N／extra SLICE wrap 在未用槽 dims[ndims]（1＝`*[2][]T`／`*[2][]*T`；0＝无 extra SLICE＝`*[2]i32`／`*[2]*T`）／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`*[2]*T`／`*[2][]*T`；0＝无 extra PTR＝`*[2]i32`／`*[2][]T`；两槽＝`*[2][]*T`）。判别 vs dest extras dest-SLICE of ARRAY extra `[][2][]T`／`[][2][]*T`（同未用槽）是 PTR vs SLICE 外层。消费＝ARRAY leftover extra SLICE peels leftover SLICE after extra ARRAY peels then extra PTR peels leftover PTR（PTR-or-SLICE 外层 walk 已剥两槽）；extra ADDR_OF of typed `[2][]*i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 extra empty `[]` 扫描器（ARRAY 元；SLICE 或 PTR 外层；keep ARRAY；extra SLICE 进 dims[ndims]）＋既有 extra STAR unused-slot＋既有 ARRAY leftover extra SLICE-then-PTR peels。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_arr_slice_ptr.x` 双端 asm／host-C **7** · 具名／UFCS **7** · extra wrap extra COUNT＝2 `*[2][][]*T` **7** · `-E` `struct xlang_slice_int32_t_p (*p)[2]`＋wrapper `void* data`
  - ✅ PTR-outer extra `*[2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `*[N]`（elem＝ARRAY、PTR 外层、ndims≥1）只认 SLICE 外层，PTR 外层走 token_to_type_kind＝−1 再 want_param_ty＝0，leaf T 未 commit，param_elem_dim_n 仍活，COMMA／RPAREN wave434 *T[N] lift 把 kind 改成 ARRAY。sit-red extra／具名／UFCS **T001** leftover PTR vs ARRAY／leftover PTR vs eeek＝−1。ndims＝−2 会冲掉 `[N]`（禁 −3／新字段）。存储＝elem＝ARRAY／eek＝leaf／ndims≥1／dims[0]＝N／extra PTR wrap 在未用槽 dims[ndims+1]（1＝`*[2]*T`；0＝无 extra PTR＝`*[2]i32`；extra SLICE 仍 dims[ndims]；`*[2][]*T` 两槽可同时置）。判别 vs dest extras dest-SLICE of ARRAY extra `[][2]*T`（同未用槽）是 PTR vs SLICE 外层。消费＝ARRAY leftover extra PTR peels leftover PTR after extra ARRAY peels（PTR-or-SLICE 外层 walk 已剥 dims[ndims+1]）；extra ADDR_OF of typed `[2]*i32` dest-stamps via the formal（无 dest extras dest-PTR stamp）。G.7 补既有 extra STAR 扫描器（ARRAY 元；SLICE 或 PTR 外层；keep ARRAY；extra PTR 进 dims[ndims+1]；先 commit pending dims 防 wave434 lift）＋既有 ARRAY leftover extra PTR peels＋dim accessor dim_ix＝ndims+1。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega。首参仍 `void* data`。验收：`dyn_add_ptr_arr_ptr.x` 双端 asm／host-C **7** · 具名／UFCS **7** · extra wrap extra PTR COUNT＝2 `*[2]**T` **7** · extra wrap extra PTR `*[2][]*T` 已闭 · `-E` `int32_t * (*p)[2]`＋wrapper `void* data`
  - ✅ fmt pure-asm format 残（双端 L2）：产生点 `pipeline_asm_modlet_load_to_rax` lea 进 rbx／x1 再 ldr，cmp 左侧停 rbx／x1 → `i >= g_fmt_file_list_n[0]` 比 `(&n)>=n` 恒真 → `fmt_file_list_at` 总 NULL → `driver_fmt_one_file` 未调用（`.data` 烤针后仍 `--check`／write no-op）。存储＝modlet COMMON／`.data`。消费＝pure-asm `fmt_check_cmd_thin`。G.7 补 load_to_rax lea_rax＋`ldr/[rax]`（array 只 lea；store 仍 lea_rbx）；seed cold 孪；撤 ALLOW skip（产品默认 pure-asm；`XLANG_FMT_DENY_PURE_ASM=1` 回落）。禁空针特例／assemble parser.x／pipeline_abi mega。验收：产品 prefer dirty `--check`＝1／write＝0／clean＝0 · at `adrp x0`＋`cmp x1,x0` · 邻域 lib_tu **42**／dyn **7** · 矩阵 **5／5**。soft：pure-asm fmt 4MiB paths COMMON 入链时 Darwin `__common` align 软警 → **本波已闭**。
  - ✅ Darwin `__common` align 软警／Mach-O COMMON `n_desc` GET_COMM_ALIGN（Darwin L2；SHARED seed 孪）：产生点 `pipeline_macho_write_o_to_buf_c` COMMON 只写 `N_UNDF|N_EXT`＋`n_value=size`，`n_desc` 对齐位＝0；Apple ld 对大 COMMON 按 size 推 `__DATA,__common` 段对齐到 **0x8000**（段上限 0x4000）→ g05／产品链警告。存储＝`g_pipe_elf_sym_common_align` 已有（ELF `st_value` 用；Mach-O 漏写）。消费＝pure-asm fmt `g_fmt_file_list_paths` 4MiB COMMON。G.7 补 Mach-O COMMON 写 `n_desc` GET_COMM_ALIGN＝log2（floor 8／cap 2^14）；seed cold 孪。禁 `-w`／禁改 COMMON→`.data` 烤 4MiB／禁 pipeline_abi mega／升钉。验收：g05 **0** common align · thin `n_desc=0x400` · fmt dirty／write／clean **1／0／0** · lib_tu **42**／dyn **7** · 矩阵 **5／5**。leftover extra SLICE peels `[]*[]T` **已闭**（8／21 PARAM＋RET；候选列表过期已清）。
  - ✅ g05 Darwin `-multiply_defined` obsolete ＋ `__DATA,__common` 对齐（Darwin L2；SHARED seed）：产生点①`pure_ld_multidef_flags`／`g05_relink_env` `_ASM_GLUE_DUP_LDFLAGS` 仍传废弃 `-multiply_defined suppress`（Apple ld 每波警告；新 ld 可 `path=suppress`）；②`seeds/rt_arena_buf.from_x.c` tentative COMMON `driver_arena_static[128MiB]`（＋`driver_module_static[2MiB]`）使终链 `__DATA,__common`≈130MiB 段对齐要 0x8000＞段上限 0x4000。sit-red 每次 `g05_prepare_and_relink` 两警告。存储＝G05_CFLAGS／pure-ld argv＋seed BSS。消费＝Darwin g05 自链。G.7 有则补全 Darwin multidef→空（同 experimental_bootstrap；Linux 仍 `--allow-multiple-definition` 供 thin inject）＋大数组／`g_lsp_state_buf` `={0}` 强制 defined zerofill（`.o` 仍小）。禁 `-w`／禁抬 macho／禁搅 fmt／dest extras／pipeline_abi mega／升钉。验收：g05 **0** multiply_defined／**0** common align · 矩阵 **5／5** · hello **0**。heat：`rm src/runtime/rt_arena_buf.o`＋`lsp_diag_pipeline_ctx.o`＋g05。钉盘仍 **`e8176cbe5`**。
  - ✅ asm 库 TU `.data` 非空 ARRAY_LIT（双端 L2）：产生点模块非空 ARRAY_LIT 进 SHN_COMMON／Mach-O `__common`（永远 BSS 0）；非零只在 hoist 入口 `pipeline_asm_modlet_seed_nonzero_inits_elf_c` 播种；库 TU 无 main／不进第一非 extern 体 → 针全 0。sit-red 产品曾靠 `pure_asm_x_to_o` 跳过 `fmt_check_cmd_thin.x` 回落 host-C `want_decl_init`。存储＝modlet cell bit29＝`.data` 已烤；F7 `g_pipe_elf_data_buf`（64KiB）。消费＝LEA 同名 Lxml_*。G.7 补既有 prepare（ne>0 且拟合 → bake；空 `[]` 仍 COMMON；过大回落 COMMON＋seed）＋Mach-O 段名 `__const`→`__data`（可变计数器可写；`__const` 终链 RO → SIGBUS）＋`append_data_zeros`／`data_poke_u8`＋seed 孪同 commit；`seed_nonzero` 跳过 bit29。fmt skip 仍留（pure-asm format 残另刀；针已烤仍 `--check`／write no-op）。禁搅 g05 multiply_defined／dest extras／pipeline_abi mega。验收：`lib_tu_modlet_data.x` Darwin asm／host-C **42** · `.o` `__DATA,__data`＝`ABC\\0`＋`10,32` · 邻域 const_module_nonmain／mut_slice **42** · dyn_call_ok **7** · fmt host-C dirty **1** · 矩阵 **5／5**。Ubuntu 同波。
  - ✅ dest extras dest-PTR stamp nested extra lit `&[[2],[4]]` of `*[2][]i32`（双端 L2）：产生点 TYPE_DYN extras 缺 dyn_pk＝9 PTR-to-ARRAY 重建，ARRAY_LIT 停在 wrap-once `[2][1]i32`；asm `pipeline_asm_emit_addr_of_elf_c` 只认 VAR／INDEX／FIELD／DEREF，ARRAY_LIT → −99 CG002 `.Lf0_1`。sit-red `dyn_add_ptr_arr_slice_lit.x` asm CG002／host-C wrap-once（具名 ADDR_OF of typed `[2][]i32` 已 7）。存储＝param_elem_kind＝ARRAY／eek＝leaf／elem_array ndims≥1／dims[0]＝N／extra SLICE 在 dims[ndims]／extra PTR 在 dims[ndims+1]。消费＝剥 ADDR_OF 后 coerce 操作数 ARRAY_LIT 为 PTR 元再 stamp ADDR_OF；ADDR_OF emit 复用 `pipeline_asm_emit_array_lit_elf_c`（temp＋lea→rax）。判别 vs dest extras dest-ARRAY of SLICE extra `[2][]i32`（无 ADDR_OF）是 PTR wrap。G.7 补既有 PARAM extras（孪 dest extras dest-RET PTR-to-ARRAY extra empty `[]`）＋既有 ADDR_OF emit（`.x`／seed／thin first-wins 同 commit）。禁 −3／第二套 dest-PTR stamp／assemble parser.x／pipeline_abi mega／搅 dest extras dest-SLICE wrap of ARRAY_LIT（具名 XT001）／asm `.data`／g05 multiply_defined。首参仍 `void* data`。验收：`dyn_add_ptr_arr_slice_lit.x` Darwin asm／host-C **7** · `-E` `struct xlang_slice_int32_t (*)[2]`＋fat rows · 邻域 `dyn_add_ptr_arr_slice`／`dyn_add_ptr`／`dyn_add_arr_slice` **7** · 矩阵 **5／5**。Ubuntu 同波。
  - ✅ dest extras dest-ARRAY of SLICE extra `[2][][2]*T` dest-stamp（双端 L2）：产生点 extra STAR after `[N][][M]`（ndims≥1、ARRAY 外层）置 elem_kind＝−1，dest extras dest-ARRAY-of-SLICE 不 extra-wrap PTR after extra ARRAY wraps → dest 是 `[2][][2]i32` 不是 `[2][][2]*i32`；嵌套 ARRAY_LIT **139**。sit-red dyn extra **139**（host-C **133**；具名／UFCS／lets 已 dest-stamp 6／7／7；邻域 `[2][][2]i32`／`[2][]*i32`／`[][2]*i32`／`[2][][]*i32`／`[][][2]i32` 已 7）。ndims≥1 dims[0..ndims−1] 是 inner ARRAY（禁 −3／复用 dims[0]）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／extra PTR wrap 在未用槽 dims[ndims]（1＝`[2][][2]*T`；0＝无 extra PTR＝`[2][][2]T`；与 dest extras dest-SLICE of ARRAY extra `[][2][]T` 同未用槽；判别是 elem_kind SLICE vs ARRAY）。extra STAR 须先 commit pending LBRACKET dims。G.7 补既有扫描器（ndims≥1 extra STAR keep SLICE；extra PTR 进 dims[ndims]；先 commit pending dims）＋既有 dest extras dest-ARRAY-of-SLICE extra PTR wraps＋dim accessor dim_ix＝ndims。禁第二套 dest-ARRAY stamp／impl-match extra PTR peels（ARRAY leftover SLICE vs eek＝SLICE，非 T001）。首参仍 `void* data`。验收：`dyn_add_arr_slice_arr_ptr.x` 双端 asm／host-C **7** · extra wrap `[2][][2][2]*i32` **7** · `-E` `struct xlang_slice_xlang_arr2_int32_t_p`＋`int32_t * (*data)[2]`＋`__xlang_al[1][2]`＋wrapper `void* data`。host-C suffix 仍 `(*)(void*, …)` 完备／host-C `[2]*[2]i32` INDEX 完备／host-C `[][2][]T` 嵌套 GNU static 完备／`[][][2]*T` 仍 T001 延期／`*[N][]T` PTR-outer 仍延期
  - ✅ dest extras dest-SLICE of SLICE extra `[][][2]*T` dest-stamp（双端 L2）：产生点 dest extras dest-SLICE-of-SLICE wrap ARRAY of leaf then wrap SLICE twice → dest 是 `[][][2]i32` 不是 `[][][2]*i32`；impl-match leftover PTR vs eeek＝leaf after extra ARRAY peels → T001。sit-red dyn extra／lets **T001**（具名／UFCS 已 dest-stamp 6／7；邻域 `[][][2]i32`／`[2][][2]*i32`／`[][]*i32`／`[][2]*i32`／`[2][][2]i32` 已 7）。ndims≥1 dims[0..ndims−1] 是 inner ARRAY（禁 −3／复用 dims[0]）。存储＝elem＝SLICE／eek＝leaf／ndims≥1／extra PTR wrap 在未用槽 dims[ndims]（1＝`[][][2]*T`；0＝无 extra PTR＝`[][][2]T`；与 dest extras dest-SLICE of ARRAY extra `[][2][]T` 及 dest extras dest-ARRAY of SLICE extra `[2][][2]*T` 同未用槽；判别是 elem_kind SLICE vs ARRAY 及 SLICE vs ARRAY 外层）。extra STAR 已完整（ARRAY-or-SLICE）。G.7 补既有 SLICE-of-SLICE walk extra PTR peels leftover PTR after extra ARRAY peels＋既有 dest extras dest-SLICE-of-SLICE extra PTR wraps＋dim accessor dim_ix＝ndims。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_slice_arr_ptr.x` 双端 asm／host-C **7** · extra wrap `[][][2][2]*i32` **7** · `-E` `struct xlang_slice_xlang_slice_xlang_arr2_int32_t_p`＋inner `int32_t * (*data)[2]`＋`__xlang_al[1][2]`＋wrapper `void* data`。host-C suffix 仍 `(*)(void*, …)` 完备／host-C `[2]*[2]i32` INDEX 完备／host-C `[][2][]T` 嵌套 GNU static 完备／`*[N][]T` PTR-outer 仍延期
  - ✅ dest extras dest-SLICE of ARRAY extra `[][2][]*T` dest-stamp（双端 L2）：产生点 impl-match ARRAY leftover 先剥 extra PTR 再剥 extra SLICE → leftover SLICE-of-PTR of `[][2][]*T` vs PTR → T001。sit-red dyn extra／UFCS／lets **T001**（具名已 dest-stamp 7；邻域 `[][2][]i32`／`[][2]*i32`／`[][][2]*i32`／`[][2]i32`／`[2][][2]*i32` 已 7）。ndims≥1 dims[0..ndims−1] 是 ARRAY dim（禁 −3）。存储＝elem＝ARRAY／eek＝leaf／ndims≥1／extra SLICE 在未用槽 dims[ndims]／extra PTR 在未用槽 dims[ndims+1]（两槽可同时置；1＝`[][2][]*T`；extra SLICE-only＝`[][2][]T`；extra PTR-only＝`[][2]*T`）。extra STAR／extra empty `[]` 已完整。dest extras dest-SLICE-of-ARRAY 已 wrap PTR of leaf then extra SLICE then ARRAY then outer SLICE。G.7 补既有 ARRAY leftover walk peel 顺序（先 extra SLICE 后 extra PTR，与 dest extras wrap 对偶）。禁第二套 dest-SLICE stamp。首参仍 `void* data`。验收：`dyn_add_slice_arr_slice_ptr.x` 双端 asm／host-C **7** · extra wrap `[][2][][]*i32` **7** · `-E` `struct xlang_slice_xlang_arr2_xlang_slice_int32_t_p`＋inner `struct xlang_slice_int32_t_p (*data)[2]`＋`__xlang_al[1][2]`＋wrapper `void* data`。host-C suffix 仍 `(*)(void*, …)` 完备／host-C `[2]*[2]i32` INDEX 完备／host-C `[][2][]T` 嵌套 GNU static 完备
  - ✅ w189 *T param home／PTR-outer `*[N][]T`（双端 L2）：产生点 `w189_stack_off_is_emit_param_ptr_slot` 用 `(off−8)/8` 把 by-value NAMED self 槽 16 错当成 param 1；extra 是 TYPE_PTR 时 `self.v` 把 v＝1 当指针再解 → 139。sit-red dyn extra `*i32`／`*[2][]i32`／具名 `(self: A, p: *i32)` **139**（无 `self.v` 已 7；dest-SLICE extra＋`self.v` 已 7，kind 11 不进 helper）。存储＝`fill_param_slots` param 0 从 16 起再 +8（或 +width）。消费＝`glue_enc_local_slot_ptr_or_addr` lea by-value NAMED。G.7 补既有 w189 walk（与 fill_param_slots 同槽）。thin inject `glue_local_var_slot_needs_ptr_load_elf_c`（禁 mega `-E`）。禁 −3／第二套 mapper。首参仍 `void* data`。验收：`dyn_add_ptr.x`／`dyn_add_ptr_arr_slice.x` 双端 asm／host-C **7** · 具名 **7** · `*[2]i32` **7**
  - ✅ host-C suffix NAMED／PTR／SLICE extras（双端 L2）：产生点 `codegen_emit_dyn_host_c_fn_ptr_suffix` 只给标量 `param_kind` 打类型，NAMED／PTR／SLICE／ARRAY 仍 `, ...)`；Darwin AAPCS64 把 extra 放栈、wrapper 从 x1 读。sit-red 真 host-C `dyn_add_named`／`dyn_add_ptr`／`dyn_add_slice` **98／153／95**（i32 extra 已 7；Darwin `--backend c -o` 假绿 asm 39KiB；Ubuntu SysV GP extra 常假绿同寄存器）。存储＝dest-stamp extra `type_ref`。消费＝wrapper 已 `emit_type`／named-array／SLICE `*`。G.7 补既有 suffix（`emit_type`＋抽象 `emit_c_ptr_to_fixed_array_decl`＋SLICE `*`；标量仍 registry）。LINEAR／VECTOR 仍 `…`。禁第二套 suffix。首参仍 `void* data`。pin seed 考古孪同 commit。验收：`dyn_add_named.x`／`dyn_add_ptr.x`／`dyn_add_slice.x` 双端真 host-C／asm **7** · `-E` `(void*, struct Pair)`／`(void*, int32_t *)`／`(void*, struct xlang_slice_int32_t *)`。host-C `[2]*[2]i32` INDEX 完备已闭／host-C `[][2][]T` 嵌套 GNU static 完备已闭
  - ✅ host-C `[2]*[2]i32` INDEX named-array（双端 L2）：产生点 `type_uses_named_array_decl` 只认 `*[N]T`／`[K][N]T`，`[2]*[2]i32` 走 emit_type 剥成 `int32_t **`；INDEX `(*((p)[0]))[0]` 语法本对，`*(p[0])` 是标量。sit-red 真 host-C `dyn_add_arr_ptr_arr` cc fail（asm 已 6；Darwin `--backend c -o` 假绿 asm 39KiB）。存储＝dest-stamp extra `type_ref`。消费＝emit_func／wrapper／suffix／ARRAY_LIT。G.7 补既有 named-array（ARRAY of PTR-to-ARRAY → `E (**name)[N]`）＋ARRAY_LIT `(E (*[])[N])`。`[K]*T` 仍 `E **`。禁第二套 INDEX emit。首参仍 `void* data`。pin seed 考古孪同 commit。验收：`dyn_add_arr_ptr_arr.x` 双端真 host-C／asm **6** · 具名 **5** · `-E` `int32_t (**p)[2]`／`(void*, int32_t (**)[2])`／`(int32_t (*[])[2]){&r0,&r1}`。host-C `[][2][]T` 嵌套 GNU static 完备已闭
  - ✅ host-C `[][2][]T` 嵌套 GNU static（双端 L2）：产生点 dest-SLICE of ARRAY extra 把 `codegen_array_lit_tree_is_const`（叶子 LIT）当成 C 静态初值，`emit_braced` 把 ARRAY-of-SLICE 行打成 GNU stmt-expr，`static E al[][N]={{stmt-expr}}` BLD001。sit-red 真 host-C `dyn_add_slice_arr_slice` cc fail（asm 已 7；Darwin `--backend c -o` 假绿 asm 39KiB）。存储＝ARRAY_LIT dest-stamp。消费＝host cc 静态初值。G.7 补既有 wave341 memcpy（ARRAY elem＝TYPE_SLICE → `static E al[n][N]; memcpy`）。禁拓宽 `tree_is_const`（文件作用域 dest-SLICE 仍要叶子 LIT＝1）／第二套 ARRAY_LIT emit。`[][N]i32` 仍 `{{lits}}`。首参仍 `void* data`。pin 无 dest-SLICE-of-ARRAY `al[][N]` 路径（既有考古；产品 FROM_X）。验收：`dyn_add_slice_arr_slice.x` 双端真 host-C／asm **7** · `-E` `static struct xlang_slice_int32_t __xlang_al[1][2]; memcpy((void*)(__xlang_al[0]), …)` · 无 `__xlang_al[][2]=` · slice_arr 仍 `{{2, 4}}` **7**
  - ✅ Darwin 产品 `-o` ld-only（双端 L2）：产生点 `xlang_asm_invoke_ld_platform` Darwin 先 spawn clang 当链接器（用户 emit 已是 asm；invoke_cc 已 ALLOW 闸）。sit-red PATH 假 clang → `FAKE_CC_SPAWN`／无 syslibroot 时 `ld failed`。存储＝ld argv。消费＝产品 `-o`。G.7 补既有 Darwin ld 回退（`-syslibroot`／`-dynamic`／`-arch`／`-dead_strip`／`-e _main`／`-lSystem`；SDK＝SDKROOT 或 Xcode／CLT 路径；禁 clang 回退／第二套 linker）。首参仍 `void* data`。验收：mac 假 clang **clang_hits=0** · rv／hello／opt／si／f32／add／sas／apa **42／0／102／0／0／7／7／6** · rv size **16792** · `-backend c` 无 ALLOW **host-cc-requires-allow** · 双端矩阵 **5/5**
  - ✅ Linux hosted 产品 `-o` ld-only（双端 L2）：产生点 `xlang_asm_invoke_ld_platform` Linux hosted 用 gcc 当链接器（crt／pie；用户 emit 已是 asm；invoke_cc 已 ALLOW 闸；Darwin ld-only 已闭）。sit-red PATH 假 gcc → `FAKE_CC_SPAWN`；裸 `ld -e main` 缺 glibc `_start` 历史 SIGSEGV。存储＝ld argv。消费＝产品 `-o`。G.7 补既有 ld（`Scrt1`／`crti`／`crtn`／`-dynamic-linker`／`-pie`／`-z noexecstack,relro,now`／`--gc-sections`；禁 gcc 回退／第二套 linker／`-e main`）。首参仍 `void* data`。验收：Ubuntu 假 gcc **clang_hits=0** ld_hits＝8 · DEBUG argv[0]＝`ld` · rv／hello／opt／si／f32／add／sas／apa **42／0／102／0／0／7／7／6** · hello size **27488** · `-backend c` 无 ALLOW **host-cc-requires-allow** · 双端矩阵 **5/5** · mac Darwin 假 clang **clang_hits=0** 无回归
  - ✅ **check_only 512B COMMON 误指**（双端 L2）：产生点 `pipeline_asm_modlet_prepare_and_emit_elf_c` 曾发 `Lxlang_ml_<idx>`；SHN_COMMON／Mach-O `__common` 按名合并取最大 → Ubuntu `driver_check_only_flag_slot` LEA `Lxlang_ml_0`（size 512）头字＝源长。权威补全：`Lxml_<fnv32(name||idx)><fnv32(let-set)>`（`.x`＋seed）。验收：双 TU 探针 size **4**／**512** 异名；产品矩阵 5/5；dyn 7／7／9

✅ **4.2.3 八层+ nested slice fat 布局 / 深 lit typeck** 布局 1..16 ✅ @ **`028959695`** · 深 lit ✅ @ **`89e611150`**

  - wave698 闭 8 层 scalar / 7 层 NAMED
  - **fat 布局**：`codegen_emit_slice_fat_one` 循环 1..16（piecewise，破 `u8[256]` 墙）；scalar 9..16 走 `XLANG_SLICE_LAYOUTS_N16`；named companion 同顶
  - **深 lit typeck**：`typeck_coerce_array_lit_elem_types_to_decl` 递归 peel 认 TYPE_SLICE（原仅 TYPE_ARRAY）；`[][]i32 = [[1,2]]`／`[2][]i32`／`[][][]i32`／return／assign／named／INDEX `x[0][1]=32`；elem `[N]T` 复用 `typeck_coerce_init_slice_from_array`；`[[true]]` 仍 T001（expected i32 found bool）
  - 余（已闭 host-C type_to_c_repr＋`[2][]i32` 行 brace＋asm INDEX）：`[][2]i32` @ **`243c07be1`**／`[2][]i32` @ **`8f4983405`**／asm INDEX @ **`a403bc41e`**；另层：nslvar host-C；nest>16 soft

✅ **4.2.3 体 const nested slice parse** ✅ @ **`05069be34`**（parser.x **`adde4a343`**）

  - 现场：`const x: [][]i32 = [[1,2]]`／`[][][]`／`[2][]` 体绑定 P001 no functions；1 层 `const []i32 = [10,32]` 与顶层 const 已绿
  - **根修**：`parse_body_lets_into` compound `[..]` 再解析去掉 `is_let` 门；const 走既有 `parse_body_let_bracket_compound_init_ref`＋`append_const`
  - **禁全量 assemble**：tip `-E` parser.x 丢 `generic_bound_scan`（hello／option 红）；只手术补 last-good `parser_gen.c`＋seed
  - 证：const／const1／const3／const_arr 三端 **70／42／73／71**
  - 余（已闭 parse＋asm fat＋const whitelist＋asm 聚合 emit＋host-C 多 const＋asm／host-C `[][2]i32`＋host-C `[2][]i32` 行 brace＋asm INDEX）：`[lit] as T` @ **`8f4983405`**／asm INDEX @ **`a403bc41e`**；另层：nslvar host-C

✅ **4.2.4 bare 泛型 ret-only／phantom 推断** **闭**（2026-08-17）

  - **ambient 原语 expected**：`let a: i32 = mk_default()`／`return mk_default()`／`as_t(42)`／`i64` → asm／host **绿**；host-C `mk_default__i32`
  - **pure phantom**：`unit_t()`／`forty_two()` bare（ret 与 formals 无 free T）→ asm **42**；host-C bare `unit_t()`（codegen wave450）
  - **根修（G.7 有则补全）**：`typeck_try_infer_generic_call_from_args` ① ret-only fully concrete expected ② pure-phantom 路径；`typeck_generic_call_fixup_resolved_type` bare stamp。权威 `typeck.x`＋seed `typeck_gen.linux` 同 commit
  - 值参回归：`id(42)` **42**；turbofish **42**；dual phantom＋ambient **42**
  - **bound n_tp=0 槽空 闭**（2026-08-17）：pure-phantom／concrete formals 无 free-T 时 `check_inferred` 仍调 `xlang_generic_bound_check_type_args_c(nargs=0)`；decl 有 `T: Trait` → T001「requires type arguments to satisfy trait bounds」；无 bound 的 `unit_t()` 仍 **42**；`unit_bound<A>()` **42**；`unit_bound<NoClone>()` 仍 not-impl。权威 skip_tl `parser_asm_skip_tl_slice.inc` 同 commit

✅ **4.2.5 多 T 组合共享 bare link name** **闭**（2026-08-17 诚实复测）

  - wave444+ mono mangle：`id<i32>`／`id<i64>` 同 main → emit `id__i32` 等；asm／host **42**
  - 零参 `unit_t<A>()+unit_t<B>()` 同 ret i32 亦 **42**
  - **struct multi mono 亦绿**（非 soft）：`id_s<A>({ n: 10 })`／`id_s<B>({ n: 32 })` → host-C `id_s__A`／`id_s__B` · asm／`-E` **42**
  - 历史假 soft：探针写 **named** `id_s<A>(A { n: … })` → typeck 拒 named STRUCT_LIT（docs/04 权威「只写 `{ fields }`」；诊断 expected `{ fields }, found A`）— **非** bare-link／struct mono 债
  - 原「共用一个 C 函数」标量组合 **已非** leave-off 主因；本条 **关**

✅ **4.2.6 泛型方法 let-binding 接收者推断** 核查闭 ✅ @ **`75119a170`**（wave445 C6 已落地）

  - `let y: T = x; return y.clone()` 三端 **7**（非 identity）
  - 权威仍 wave445 `codegen.x` C6 local-let 扫 `current_block_ref`；本波只登记关闭

✅ **4.2.7 TYPE_SLICE call-arg 真递归 / 无堆重入 last-wins** **闭**（2026-08-17）

  - dual same-call `take2([1,2],[6,7])` asm／host **7**；nest ARRAY_LIT `take([[1,2]])` **3**
  - flat CALL return dual `take2(mk(1),mk(2))` **11**；triple／seq／walk_let 同绿
  - **嵌套 `[][]T` CALL return** 根修：`glue_slice_let_reent_deep_copy_after_dual_gp_elf_c` esz 必须量 **ty_ref**（SLICE stride），禁 peel 后再量（peel 后 `[]i32` 得 4 非 fat **16**）→ let／call-arg 内层 length 错／panic
  - let 帧：`use_frame=1` 且 esz>8 时 max_payload 收 **8KiB**（禁 16KiB 撑破 arm64 帧 → SEGV）
  - 证：asm `let a=mk(); a[0][0]+a[0][1]` **42**；`take(mk())` **3**；`take2(mk(1),mk(2))` 嵌套 **7**；flat 回归 **7／11／23**
  - G.7 权威：`runtime_pipeline_abi.x` pure leave；mega 全量 prefer `-E` 仍重 → thin 叶 `runtime_pipeline_abi_reent_deep_copy_thin.x` 同体 + ensure first-wins inject（禁第二套算法）
  - 余（后期）：真堆物化／超 max_n cap；**非**本叶 soft

⬜ **4.2.8 AST name 槽 128 字节 layout raise** leave-off

  - wave284 honest-fail 已绿；布局升维（fixed name[128] → 可变长度）仍 leave-off

⬜ **4.2.9 LANG-006 标量 bool→int 保留** **有意保留 soft**

  - `let x: i32 = true` 仍合法；显式保留的语言契约，非 bug

✅ **4.2.10 `take(W.xs)` f32[2]→[]f32 call-arg** score array→slice ✅ @ **`eed0261a9`**

  - 现场：wave649 已能 emit fat（VAR／FIELD 见 TYPE_ARRAY）；其后 call-arg 硬分把 `[N]T` vs `[]T` 打成 T001，emit 走不到
  - **根修**：`typeck_overload_arg_param_score` ak=10／pk=11 等元返 100；**禁止 stamp** `resolved_type_ref`（emit 要 TYPE_ARRAY 才物化 `{.data,.length}`）
  - 证：`take(W{}.xs)`／`take(mk().xs)`／`take(w.xs)`／`take(a)` f32＋i32 · asm／host-C／fs **42**；`[2]bool`→`[]i32` 仍 T001
  - 余（已闭）：return／assign `[N]T→[]T` @ **`c652eee5c`**；INDEX call-arg @ **`5350f61ac`**

✅ **4.2.11 `i64[]` call-arg fs** 核查闭 ✅ @ **`eed0261a9`**（wave622 已闭）

  - 现场：`take([10,32])` 对 `[]i64`／`[]i32`／`[]u8`／`[]f64` 三端 idx1=32·sum=42；let→take 同
  - 权威仍 wave622 formal force_esz；本波只登记关闭

✅ **4.2.12 fs multi-method mangle** 核查闭 ✅ @ **`8680599ba`**（wave683 已闭）

  - 现场：`p.get() + p.add(10)` 三端 32；其后 soft 不再列
  - 本波只登记关闭

✅ **4.2.13 dup_func first-wins** 核查闭 ✅ @ **`8680599ba`**（wave681 已闭）

  - 现场：无参 redef first-wins run=1；有参 `foo(40)` first-wins run=41
  - 本波只登记关闭

✅ **4.2.14 bare type-param field** 核查闭 ✅ @ **`8680599ba`**（wave684 已闭）

  - 现场：`Box<T>.v` take **42**；`b.nope` **T001** field_unknown 硬失败
  - 本波只登记关闭

✅ **4.2.15 impl method on INDEX ≤16B** ✅ @ **`8680599ba`**

  - 来源：wave635 soft 项
  - 现场：4B／8B／slice／trait／bound `a[i].method()` 三端本绿；12B Trip／16B Quad METHOD／let／take asm 垃圾（指针当首 8B）
  - **根修**：`pipeline_asm_emit_index_elf_c` 9–16B 复用 `pipeline_asm_deref_struct16_rax_ptr_elf_c`（*addr→rax+rdx dual-GP）
  - **禁**：扩冻结 classifier（ko≠48）；全量 assemble pipeline_abi mega（seed rest 活体）
  - 证：`index_method`／`_trip`／`_quad` 三端 **0**；FIELD `a[1].v` 仍 **32**
  - 余（已闭）：>16B INDEX MEMORY @ **`ec82327bb`**

✅ **>16B INDEX MEMORY consume** ✅ @ **`ec82327bb`**

  - 来源：4.2.15 余叶（emit_index esz>16 留址正确）
  - 现场：Wide `a[1].last` 本绿；`take(a[1])` 返 0（f32-xmm 默认 CALL 栈 emit+push 指针）；`let`／`return` 同层
  - **根修**：push／store INDEX 复用 FIELD lvalue 拷循环；store_retval memcpy 48\|\|49\|\|47；return Path A2 sret memcpy；**默认 f32-xmm CALL 栈**走同一 push
  - **禁**：扩冻结 classifier；emit_index 内 memcpy；全量 assemble pipeline_abi mega
  - 证：`index_method_wide` 三端 **0**（Ubuntu x86 @ **`ec82327bb`**；Darwin ARM64 consume 见下）
  - 余（已闭 Darwin ARM64 consume）：见 **ARM64 >16B INDEX MEMORY consume**

✅ **return／assign `[N]T→[]T` emit wrap** ✅ @ **`c652eee5c`** · **pin-seed typeck 双权威闭** 2026-08-17 @ **`da7230bc7`**

  - 来源：4.2.10 余叶（let／call-arg 已绿；return／assign 仍 T001）
  - 现场：`return a`／`return w.xs`／`return W{}.xs`／`s = a`／`s = w.xs` typeck T001
  - **根修**：`typeck_array_to_slice_ok` 不 stamp；host-C return durable memcpy＋fat；assign 同帧 fat；asm return Path B0 COMMON＋dual-GP；assign 复用 `glue_emit_slice_from_array_let_init`
  - **pin-seed 双权威闭**（2026-08-17）：`typeck_array_to_slice_ok` 只进 `typeck.x` 时 pin-first migrate 假红 expected []i32 found [2]i32；seed 补谓词＋return／assign／as 调用点；匿名 STRUCT_LIT 基 join reverse-infer（`{ xs:… }.xs` found `?`→layout）
  - **禁**：stamp `resolved_type_ref` 为 TYPE_SLICE；全量 assemble parser.x／pipeline_abi mega
  - 证：`ret_array_as_slice`／`asg_array_as_slice` 三端 **42**；`[2]bool→[]i32` 仍 **T001**；双端 pin-seed L2 @ **`da7230bc7`**

⬜ **4.2.16 `*T[N]` 解析序** **有意保留 soft**（设计决策）

  - 来源：wave635 soft + wave636 描述
  - 决策：`*T[N]` = array-of-pointers（C 式故意）；pointer-to-array 写 `*[N]T`
  - 类似 4.2.9 LANG-006，属显式保留的语言契约，非 bug

✅ **4.2.17 `fixed return S24[2]`** ✅ @ **`51eee33cc`**

  - 来源：wave632 soft 项（ARRAY_LIT durable／let-from-CALL 已绿；`return s` 未闭）
  - 现场：`return s`／`return w.xs`（S24[2] VAR／FIELD）asm SEGV；host-C 110；`return [S24…]`／`let s=mk()`／`return lit()` 本绿
  - **根修**：Path B0 dest TYPE_ARRAY 同 COMMON 拷后 rax=E*；keep esz>8（wave632；同层 `[]S24`）；dest SLICE 仍 pack length
  - **禁**：stamp；全量 assemble pipeline_abi mega；动 seed return 冷体
  - 证：`ret_fixed_s24` asm／host-C **110**（lit／var／call／field／`[]S24`）

✅ **4.2.18 未知 arg_ty／param_raw≤0** 核查闭 ✅ @ **`51eee33cc`**（wave676 已闭）

  - 现场：定义侧 `function bad(x)`／缺 `): Type` 已 **P011**；无产品入口再造 untyped formal
  - typeck `param_raw<=0` 仍 defensive skip（不是第二套 score）
  - 证：`untyped_formal`／`untyped_formal_noret` **P011**

✅ **`[lit] as T` parse_expr** ✅ @ **`d334d0460`**（parse `55078c1f3`）

  - 现场：`let/const [10,32] as []i32` 原 P001（as_suffix 半残表拒 `[`）
  - **根修**：`as` 后一律 `parser_asm_parse_type_ref_for_arena_into_slice_c`；typeck 认 `[N]T as []T`＋同型 ARRAY／SLICE；ARRAY_LIT 盖印 SLICE；host-C EXPR_AS 聚合 identity
  - **禁**：全量 assemble parser.x／pipeline_abi mega
  - 证：`lit_as_slice`／`lit_as_array` host-C **42**；`5 as i32` 仍 42

✅ **asm `[lit] as []T` fat／`as [N]T`** ✅ @ **`e62e132e6`**

  - 现场：let／return `[10,32] as []i32` asm compile 0 run=1（length≠2）；`as [2]i32` CG002
  - **根修**：`glue_peel_as_array_slice_ascription_c` 剥 ARRAY／SLICE 目标的 EXPR_AS，既有 ARRAY_LIT／VAR／FIELD fat 与 fixed-store 开火
  - **禁**：改 fat 布局／Path B0 dest；全量 assemble pipeline_abi mega
  - 证：`lit_as_slice`／`lit_as_array` 三端 **42**；`5 as i32` 仍 42
  - 余（勿并本叶）：const 聚合 emit；`[][2]i32` INDEX 发射

✅ **const EXPR_AS whitelist** ✅ @ **`5ab4464c2`**

  - 现场：`const n = 5 as i32`／`const s = [10,32] as []i32` T001 const-expr（fold 已认 EXPR_AS）
  - **根修**：`typeck_is_const_expr_ref_impl` 递归 `as_operand`；镜像 post_E_fixup 叶 twin
  - **禁**：pin typeck_gen seed；全量 assemble parser.x／pipeline_abi mega
  - 证：`lit_as_const` 三端 **42**（标量）；`const … as []T` compile 0（T001 闭）
  - 余（勿并本叶）：const 聚合 emit（裸 `const s: []i32 = [10,32]` 读 length 亦 run=2）；`[][2]i32` INDEX 发射

✅ **const 聚合 emit（asm）** ✅ @ **`6767ea638`**（docs **`760bdce4c`**）

  - 现场：裸／`as` `const s: []i32 = [10,32]` 读 length run=2；`const a: [2]i32` a[0] run=5（T001 已闭）
  - **根修**：`pipeline_asm_emit_block_inits_elf_c`／`pipeline_asm_emit_block_body_sync_elf` const 循环复用 `glue_emit_slice_from_array_let_init_elf_c`＋`glue_emit_fixed_array_type_let_init_elf_c`；seed 冷 twin 同 commit
  - **禁**：改 whitelist／peel／fat 布局；全量 assemble pipeline_abi mega；host-C const 声明改写（stmt_order 第二枚起漏 decl 是另层）
  - 证：`const_agg_init`／`lit_as_const` **asm 42**
  - 余（勿并本叶）：host-C 多 const 声明（第二枚起 BLD001）；`[][2]i32` INDEX 发射

✅ **host-C 多 const 声明** ✅ @ **`9b6bdfde5`**

  - 现场：prefix `const n` 入 stmt_order；mid-body `const m`／嵌套块 `const k` 进池但不记 kind=0 → emit_block 漏 decl（lac／cai BLD001）
  - **根修（G.7 有则补全）**：onefunc／parse_block mid-body 补 kind=0；`append_block_lets_from_res` 拷 const；手术补 last-good parser_gen／seed（**禁** tip `-E` 全量 assemble）
  - **禁**：改 codegen emit_block 消费端；全量 assemble parser.x／pipeline_abi mega；再动 whitelist／peel／const 聚合 asm emit
  - 证：`lit_as_const`／`const_agg_init` 三端 **42**（`-E` 有 n／m／k）
  - 余（已闭 asm INDEX）：`[][2]i32` @ **`50cdc1f53`**；另层：host-C type_to_c_repr

✅ **`[][2]i32` INDEX 发射（asm）** ✅ @ **`50cdc1f53`**

  - 现场：`let x: [][2]i32 = [[10,32],[1,2]]; return x[0][1]` asm compile 0 run=254（指针低 8 位）；`x[1][0]` 240；host-C BLD001（`xlang_slice_int32_t`＋`int32_t *al[2]`）
  - **根修（G.7 有则补全）**：产生点＝durable ARRAY_LIT。`glue_array_lit_force_esz_from_elem_type_c` TYPE_ARRAY→`glue_fixed_array_total_bytes_c`；durable `etk==10`（含 esz==8）走 `glue_emit_fixed_array_type_let_init`＋COMMON memcpy，不再把行当标量指针存。seed 冷 twin 同 commit
  - **禁**：改 emit_index（留址＋内层 load 本正确）；全量 assemble pipeline_abi mega
  - 证：`slice_of_arr_idx` asm **42**（INDEX／mid／take／VAR 行／`[][3]i32`）
  - 余（已闭 host-C type_to_c_repr＋`[2][]i32` 行 brace＋asm INDEX）：`[][2]i32` @ **`243c07be1`**／`[2][]i32` @ **`8f4983405`**／asm INDEX @ **`a403bc41e`**；另层：nslvar host-C；nest>16 soft

✅ **host-C `[][2]i32` type_to_c_repr** ✅ @ **`243c07be1`**

  - 现场：`let x: [][2]i32 = [[10,32],[1,2]]; return x[0][1]` host-C BLD001（`struct xlang_slice_int32_t`＋`int32_t *al[]`；`(x).data[0]` 成 i32）
  - **根修（G.7 有则补全）**：产生点＝`pipeline_codegen_type_to_c_repr` TYPE_ARRAY 剥叶。改发 `xlang_arr<N>_<elem>`；`codegen_emit_slice_of_fixed_array_layouts` 发 `E (*data)[N]`；ARRAY_LIT 耐久 `E al[][N]`／memcpy 行。seed 冷 twin 同 commit
  - **禁**：改 emit_index／emit_type ARRAY 形参衰减；全量 assemble parser.x／pipeline_abi mega；再动 asm durable 行拷
  - 证：`slice_of_arr_idx` 三端 **42**（INDEX／mid／take／VAR 行／`[][3]i32`）
  - 余（已闭行 brace＋asm INDEX）：host-C `[2][]i32` @ **`8f4983405`**／asm INDEX @ **`a403bc41e`**；另层：nslvar host-C；nest>16 soft

✅ **host-C `[2][]i32` ARRAY-of-SLICE 行 brace** ✅ @ **`8f4983405`**

  - 现场：`let x: [2][]i32 = [[1,2],[3,4]]` host-C BLD001（`struct xlang_slice_int32_t x[2] = {{1,2},{3,4}}`）
  - **根修（G.7 有则补全）**：产生点＝`emit_braced_array_lit_init` 对内层 ARRAY_LIT 一律递归 brace。dest／elem TYPE_SLICE 复用 emit_expr 耐久 slice；TYPE_ARRAY 行仍递归 brace
  - **禁**：改 emit_index／type_to_c_repr／emit_type ARRAY 衰减；全量 assemble parser.x／pipeline_abi mega
  - 证：`nested_slice_lit_arr`／`nested_slice_const_arr` host-C **71**（INDEX 消费；`-E` 有 `__xlang_al`＋`.data`／`.length`）
  - 余（已闭 asm INDEX）：@ **`a403bc41e`**；另层：nslvar host-C（已闭 @ **`86c3e7ee0`**）／asm nslvar INDEX（已闭 @ **`4e26d1f3f`**）；nest>16 soft

✅ **asm `[2][]i32` INDEX** ✅ @ **`a403bc41e`**

  - 现场：`let x: [2][]i32 = [[1,2],[3,4]]; return x[0][0]+…` asm SEGV 139（先前 `return 71` 假绿）
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_vector_let_init` `has_nested` flatten 成 i32。dest elem TYPE_SLICE 不 flatten；行复用 `glue_emit_slice_from_array_let_init`（`block_ref=0`）；同层 force_esz／durable 16B 行（nslidx rdx 垃圾长度）／`glue_fixed_array_total_bytes`／`pipe_local_slot_bytes_mod` 认 16
  - **禁**：改 emit_index／host-C brace／type_to_c_repr；全量 assemble parser.x／pipeline_abi mega
  - 证：`nested_slice_lit_arr`／`nested_slice_const_arr` 三端 **71**；nslidx **32**×5
  - 余（已闭 host-C nslvar）：@ **`86c3e7ee0`**；另层：asm nslvar INDEX；nest>16 soft

✅ **host-C nslvar VAR-into-slice** ✅ @ **`86c3e7ee0`**

  - 现场：`let a:[2]i32=[1,2]; let x:[][]i32=[a]` host-C BLD001（`__xlang_al[0]=a`）
  - **根修（G.7 有则补全）**：产生点＝ARRAY_LIT 非 const 填充。`try_emit_slice_init_from_array_var` 发 `(T[]){.data,.length}`（赋值合法）；同层扫 const／parent；填充 dest-elem TYPE_SLICE 复用 helper
  - **禁**：改 emit_index／glue／type_to_c_repr；全量 assemble parser.x／pipeline_abi mega
  - 证：`nested_slice_lit_var` host-C／xlang-c **78**（INDEX 消费；`-E` 有 typed fat）
  - 余（已闭 asm nslvar INDEX）：@ **`4e26d1f3f`**；nest>16 soft

✅ **asm nslvar INDEX** ✅ @ **`4e26d1f3f`**

  - 现场：`let a:[2]i32=[1,2]; let x:[][]i32=[a]; return x[0][0]+x[0][1]+75` asm 134／偶发 139（先前 `return 78` 假绿）
  - **根修（G.7 有则补全）**：产生点＝durable ARRAY_LIT 行调 `glue_emit_slice_from_array_let_init` `block_ref=0`，VAR 路径直接 return 0 再 `emit_expr` 写垃圾 fat。typeck 把行 stamp 成 TYPE_SLICE，N 不在 `resolved_type_ref`。补全同一 helper：prior-let 未中则 `pipeline_block_resolve_var_type_ref`（const＋parent）从 scope／func body 取 decl N
  - **禁**：改 emit_index／host-C fill／type_to_c_repr；全量 assemble parser.x／pipeline_abi mega
  - 证：`nested_slice_lit_var` 三端 **78**；同层 `nested_slice_const_var`／`nested_slice_parent_var` 三端 **78**
  - 余（已闭 host-C dest-SLICE wrap）：@ **`75119a170`**；另层：asm CALL 行；nest>16 soft

✅ **host-C dest-SLICE 行 wrap** ✅ @ **`75119a170`**

  - 现场：`[2][]i32=[a,[3,4]]` host BLD001（`{a, (slice){…}}` 把下一行当 `.length`）；`[][]i32=[mk()]` host BLD001（`__xlang_al[0]=mk()` E*→slice）
  - **根修（G.7 有则补全）**：产生点＝`emit_braced_array_lit_init`／`try_emit_slice_init_from_array_var`。helper 补 CALL／METHOD_CALL（同模块 callee 返 TYPE_ARRAY 取 N；`.data=mk()`）；`emit_braced` dest-SLICE 行复用 helper。权威 `codegen.x`（FROM_X assemble）
  - **禁**：改 emit_index／glue／type_to_c_repr；全量 assemble parser.x／pipeline_abi mega
  - 证：`nested_slice_lit_arr_var` 三端 **71**；`nested_slice_lit_call`／`_method` host **78**；`nested_slice_lit_arr_call` host **71**
  - 余（已闭 asm dest-SLICE CALL 行）：@ **`454042047`**；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **asm dest-SLICE CALL 行** ✅ @ **`454042047`**

  - 现场：`[][]i32=[mk()]` asm 134；METHOD `[w.xs()]` 偶发 134；`[2][]i32=[mk(),[3,4]]` 同洞
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_slice_from_array_let_init` `else return 0`。补 CALL＝48／METHOD_CALL＝49：同模块 callee 返 TYPE_ARRAY 取 N；emit_expr 按 callee ABI 留 rax=E*（ARRAY 返 8B），再 wrap `{data,length=N}`。dep 模块 return type_ref 另层。权威 `runtime_pipeline_abi.x`（prefer thin+rest；禁 mega）
  - **禁**：改 emit_index／host-C wrap／type_to_c_repr；全量 assemble parser.x／pipeline_abi mega
  - 证：`nested_slice_lit_call`／`_method` 三端 **78**；`nested_slice_lit_arr_call` 三端 **71**；`let s:[]i32=mk()` **42**
  - 余（已闭 dep 模块 CALL dest-SLICE）：@ **`baf8bbae2`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **dep 模块 CALL dest-SLICE** ✅ @ **`baf8bbae2`**

  - 现场：`[][]i32=[dep.mk()]` 同模块 CALL 已绿；`resolved_dep_index>=0` 时 helper `lea_rc<0`／`dep_ix<0` 跳过 → asm 垃圾 length／host-C 无 wrap
  - **根修（G.7 有则补全）**：产生点＝同一 helper。asm：map callee 返 TYPE_ARRAY 进 caller arena，失败则读 dep arena `array_size`（type_ref 属 arena 本地，≡ wave196）。host-C：`pipeline_dep_ctx_module_at`＋`arena_at` 读 N。权威 `runtime_pipeline_abi.x`＋`codegen.x`
  - **禁**：改 emit_index／type_to_c_repr／parser assemble／pipeline_abi mega
  - 证：`nested_slice_lit_call_dep` 三端 **78**（`-E` `.data=dep.mk(),.length=2`）；`_arr_call_dep` 三端 **71**；`let s:[]i32=dep.mk()` 三端 **43**
  - 余（已闭 dest-SLICE INDEX 行）：@ **`72af1f5a0`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **dest-SLICE INDEX 行** ✅ @ **`72af1f5a0`**（let CALL wrap **`72af1f5a0`**）

  - 现场：`let s:[]i32=a[i]`／`[][]i32=[a[1]]`／`[2][]i32=[a[1],[5,6]]`／`[][2]i32` 的 `a[1]` helper 跳过 INDEX＝47 → asm 垃圾 length／host-C BLD001。typeck stamp 成 TYPE_SLICE 藏 N；emit_index 会当 16B fat（stride 16，`a[1]` 错槽）
  - **根修（G.7 有则补全）**：产生点＝同一 helper。N＋esz 取自基元 TYPE_ARRAY；asm `glue_emit_index_eff_addr_scaled`（禁 emit_index／lvalue）；host-C `.data=a[i]`（C 衰减）。同波 slcdep host-C：wave409 reent 见 CALL dest-SLICE 一律 `__xlang_sp=mk()`；门控 callee 真返 TYPE_SLICE 才 reent，`[N]T` 走 try_emit
  - **禁**：改 emit_index／type_to_c_repr／parser assemble／pipeline_abi mega
  - 证：`nested_slice_let_idx` 三端 **42**（`-E` `.data=(a)[0],.length=2`）；`_lit_idx_row` **82**；`_lit_arr_idx` **78**；`_let_sai_idx` **47**；`_let_call`／`_let_call_dep` **43**（`-E` `.data=dep.mk(),.length=2`；las 真 SLICE 仍 `__xlang_sp=from_let()`）
  - 余（已闭 INDEX [N]T→[]T call-arg）：@ **`5350f61ac`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **INDEX [N]T→[]T call-arg** ✅ @ **`5350f61ac`**

  - 现场：`take(a[0])`／`take(a[1])` 对 `[2][2]i32` 双端 run=34（length≠2）；`take(a as [2]i32)` SEGV。4.2.10 `take(a)`／`take(w.xs)` 已绿
  - **根修（G.7 有则补全）**：产生点＝`emit_call_arg_slice_abi`／`pipeline_asm_emit_expr_elf_for_call_args` 只认 VAR／FIELD／CALL／METHOD。补 INDEX＝47：N＋esz 取自 INDEX TYPE_ARRAY 或基元；asm scaled lea（禁 emit_index）；host-C `.data=a[i]`。同波剥 ARRAY／SLICE ascription
  - **禁**：stamp SLICE；改 dest-SLICE let helper／emit_index／type_to_c_repr；全量 assemble parser.x／pipeline_abi mega
  - 证：`take_index_slice` 双端 **42**（`-E` `.data=(a)[0],.length=2`／`take(b as [2]i32)` peel）
  - 余（已闭 dest-SLICE let 非 VAR FIELD 基）：@ **`94aaf1368`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **dest-SLICE let 非 VAR FIELD 基** ✅ @ **`94aaf1368`**（memcpy C 字节 **`94aaf1368`**）

  - 现场：`let s:[]i32 = W{}.xs`／`mk().xs`／`rows[i].xs` try_emit 只认 VAR 基 → C 数组赋进 slice（run=1／SEGV）；asm `glue_field_access_field_type_ref` 只走 VAR 布局，dest-SLICE stamp 藏 N
  - **根修（G.7 有则补全）**：产生点＝同一 dest-SLICE helper。N 取自基 TYPE_NAMED 布局（VAR／STRUCT_LIT／CALL／INDEX／DEREF）。host-C：STRUCT_LIT／INDEX 视图 `((base).field)`（compound 块期）；CALL／METHOD memcpy 进 `__xlang_fbN`。asm lea 已由 `glue_try_index` 物化
  - **禁**：改 emit_index／type_to_c_repr／parser assemble／pipeline_abi mega
  - 证：`nested_slice_let_field` 双端 **42**（`-E` `W{}.xs` 视图／`memcpy(...,(mk()).xs,sizeof(__xlang_fb0)); __xlang_fb0`／`((rows)[1]).xs`）
  - 余（已闭 dest-SLICE return／assign INDEX）：@ **`e681baf93`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；const INDEX whitelist

✅ **dest-SLICE return／assign INDEX** ✅ @ **`e681baf93`**

  - 现场：`return a[0]` 作 `[2]i32` 已绿；作 `[]i32` Path B0 只认 VAR／FIELD → 长度未装（run=1／SEGV）；`s = a[1]` assign 门同跳过；host-C wrap 已耐久，但 emit_type 剥 `[2][2]i32` 形参成 `int32_t **` → memcpy SEGV
  - **根修（G.7 有则补全）**：产生点＝Path B0／assign 门补 INDEX＝47（lea `glue_emit_index_eff_addr_scaled`；N 取自 resolved TYPE_ARRAY，不 stamp）；`emit_c_ptr_to_fixed_array_decl` 认 ARRAY-of-ARRAY（`E (*name)[N]`；proto＋def）
  - **禁**：改 emit_index／type_to_c_repr／parser assemble／pipeline_abi mega；const INDEX whitelist（typeck 另层）
  - 证：`ret_index_array_param` 双端 **42**（`-E` `int32_t (*a)[2]`／`memcpy(...,(a)[0])`／`u=(a)[1]`）
  - 余（已闭 const INDEX whitelist）：@ **`7a6035edb`**；已闭 host-C dest-SLICE const INDEX wrap @ **`da2cc2b90`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **const INDEX whitelist** ✅ @ **`7a6035edb`**

  - 现场：`const s:[]i32 = a[1]`／`const r:[2]i32 = a[0]`／`const n:i32 = b[1]` T001 const-expr
  - **根修（G.7 有则补全）**：产生点＝`typeck_is_const_expr_ref_impl`。INDEX＝47 当且仅当 base＋index 皆 const-expr（let 基仍拒）；fold 递归子树不盖 i32 印；镜像 post_E_fixup 叶 twin
  - **禁**：pin typeck_gen seed；dest-SLICE emit；parser assemble／pipeline_abi mega
  - 证：`const_index_slice` asm／xlang-c **42**
  - 余（已闭 host-C dest-SLICE const INDEX wrap）：@ **`da2cc2b90`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **host-C dest-SLICE const INDEX wrap** ✅ @ **`da2cc2b90`**

  - 现场：`const s:[]i32 = a[1]`／`[[1,2],[10,32]][0]`／`a[k]` typeck 已绿；host-C emit_block kind＝0 只 `emit_expr` → `s=(a)[1]` 指针赋进 slice 结构（BLD001）。asm 已绿
  - **根修（G.7 有则补全）**：产生点＝同一 `try_emit_slice_init_from_array_var`。const 声明复用（INDEX／VAR／FIELD／CALL；`let_idx=num_lets`）。dest-ARRAY／标量仍 `emit_expr`
  - **禁**：pin codegen_gen seed；parser assemble／pipeline_abi mega；emit_index／type_to_c_repr
  - 证：`const_index_slice` 三端 **42**（`-E` `.data=(a)[1],.length=2`／ARRAY_LIT INDEX／`a[k]`／`v=b`）
  - 余（已闭 host-C 模块级 dest-SLICE const wrap）：@ **`8e64e35b5`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；asm 模块级 dest-SLICE const CG002

✅ **host-C 模块级 dest-SLICE const wrap** ✅ @ **`8e64e35b5`**

  - 现场：`const s:[]i32 = A[1]`／`const v:[]i32 = B`／`let m:[]i32 = B` typeck 已绿；host-C 顶层只 `emit_expr` → `static const T s = (A)[1]`（指针进 slice 结构，C static BLD001）。块级 dest-SLICE const 已绿
  - **根修（G.7 有则补全）**：产生点＝`codegen_x_ast` 顶层 dest-SLICE。INDEX 复用 `try_emit`（N 取基元／行 TYPE_ARRAY）；VAR／init_globals 用模块表回退发 `{.data=B,.length=N}`（禁给 try_emit 加第 8 参，cis host ABI 回退）。权威 `codegen.x`（FROM_X）
  - **禁**：pin codegen_gen seed；parser assemble／pipeline_abi mega；emit_index／type_to_c_repr
  - 证：`const_module_slice` host **42**（`-E` `.data=(A)[1],.length=2`／`v=.data=B`／`m=` 同）；`const_index_slice` host／asm **42**
  - 余（已闭 asm 模块级 dest-SLICE const hoist）：@ **`4e40dec2a`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **asm 模块级 dest-SLICE const hoist** ✅ @ **`4e40dec2a`**

  - 现场：`const s:[]i32 = A[1]`／`v=B` typeck＋host-C 已绿；asm CG002（code_len=12）。hoist 把全部 TYPE_ARRAY／ARRAY_LIT 当 COMMON 跳过，prepare 又跳过 is_const → 无 home
  - **根修（G.7 有则补全）**：产生点＝`pipeline_module_hoist_top_level_lets_into_main` 只跳过可变 COMMON；const TYPE_ARRAY 进 main 栈槽。dest-SLICE INDEX 从 hoist／模块表回退 N（基 VAR 常无 stamp）。权威 `runtime_pipeline_abi.x`（prefer thin+rest）；seed 冷 twin 同 commit
  - **禁**：pin；parser assemble；pipeline_abi mega 真开；emit_index；host-C try_emit 第 8 参
  - 证：`const_module_slice` 三端 **42**；`const_index_slice` 双端 **42**
  - 余（已闭 host-C 模块级 dest-SLICE ARRAY_LIT）：@ **`3673b4149`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；非 main 读模块 const 数组；dest-SLICE 可变 COMMON LEA

✅ **host-C 模块级 dest-SLICE ARRAY_LIT** ✅ @ **`3673b4149`**

  - 现场：`const t:[]i32=[10,32]` typeck＋asm 已绿；host-C 顶层 `try_emit` 不认 ARRAY_LIT → `emit_expr` statement-expr `({ static ... })` 非法 C static（BLD001）
  - **根修（G.7 有则补全）**：产生点＝`codegen_x_ast` 顶层 dest-SLICE 回退。const 树发 `{.data=(E[]){…},.length=N}`／`[][N]T` 用 `emit_local_fixed_array_*`（文件作用域 compound 是 address constant）。**禁**把 ARRAY_LIT 塞进 `try_emit`（`init_globals` 也 `block_ref=0`，函数作用域 compound 会悬空）
  - **禁**：pin codegen_gen seed；parser assemble／pipeline_abi mega；try_emit 第 8 参；asm hoist
  - 证：`const_module_slice` 三端 **42**（`-E` `t=.data=(int32_t[]){10, 32},.length=2`）
  - 余（已闭 host-C 模块 dest-SLICE `[][]T` ARRAY_LIT）：@ **`de5a9bcc4`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；非 main 读模块 const 数组；dest-SLICE 可变 COMMON LEA；asm 模块 dest-SLICE `[][]T` INDEX

✅ **host-C 模块 dest-SLICE `[][]T` ARRAY_LIT** ✅ @ **`de5a9bcc4`**

  - 现场：`const ns:[][]i32=[[10,32],[1,2]]`／`const na:[2][]i32=…` typeck＋标量 ARRAY_LIT wrap 已绿；上波闸 `al_ek!=11`，`emit_braced` 行走 statement-expr（非法 C static BLD001）
  - **根修（G.7 有则补全）**：产生点＝同一顶层 dest-SLICE wrap。抽 `emit_file_scope_dest_slice_array_lit`：SLICE 元递归发 `(E){.data=(leaf[]){…},.length=n}`；`[N][]T` 行同模式。**禁** ARRAY_LIT 进 `try_emit`（`init_globals` `block_ref=0` 会悬空）
  - **禁**：pin codegen_gen seed；parser assemble／pipeline_abi mega；try_emit 第 8 参；asm hoist／emit_index
  - 证：`const_module_nested_slice` host-C **42**（`-E` 嵌套 `.data=(int32_t[]){10, 32},.length=2`／`na[2]` 同行 wrap）；`const_module_slice` 三端 **42**
  - 余（已闭 asm 模块 dest-SLICE `[][]T` INDEX）：@ **`38be061a4`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；非 main 读模块 const 数组；dest-SLICE 可变 COMMON LEA

✅ **asm 模块 dest-SLICE `[][]T` INDEX** ✅ @ **`38be061a4`**

  - 现场：`const ns:[][]i32=[[10,32],[1,2]]` host-C 已绿；asm `ns.length==2` 但 `ns[0].length` **15**。函数作用域同形 `x[0].length` 已 42
  - **根修（G.7 有则补全）**：产生点＝durable 用 ARRAY_LIT 推断元（模块未经 check_block 盖 dest TYPE_SLICE）把 `[N]T` 行 memcpy 成 16B。`glue_asm_emit_array_lit_durable_ptr_rax` 收 dest 元；TYPE_SLICE 行走既有 fat COMMON。seed 冷 twin 同参。权威 `runtime_pipeline_abi.x`（prefer thin+rest）
  - **禁**：pin；parser assemble／pipeline_abi mega 真开；try_emit 第 8 参；ARRAY_LIT 进 try_emit；emit_index
  - 证：`const_module_nested_slice` 三端 **42**；`const_module_slice` 三端 **42**；nslidx **32**；slcidx／nsf **42**
  - 余（已闭 dest-SLICE 可变 COMMON LEA）：@ **`387d8425b`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；非 main 读模块 const 数组；host-C 函数作用域 dest-SLICE 模块 VAR

✅ **dest-SLICE 可变 COMMON LEA** ✅ @ **`387d8425b`**

  - 现场：`let A:[2]i32=[10,32]`／`let m:[]i32=A`／`let r:[]i32=Rows[1]` typeck＋host-C 模块级 wrap 已绿；asm LEA COMMON 但 BSS 全 0（`s[0]`／`r[0]` 读 0）
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_modlet_seed_nonzero_inits` 只写标量 imm。ARRAY_LIT LIT（含一层 `[K][N]T` 行）写入 COMMON；`glue_emit_slice` VAR 优先 `modlet` LEA（禁误用栈槽）。权威 `runtime_pipeline_abi.x`（prefer thin+rest）
  - **禁**：hoist 可变 TYPE_ARRAY；`try_emit` 第 8 参；ARRAY_LIT 进 `try_emit`；pin；parser assemble／pipeline_abi mega 真开
  - 证：`const_module_mut_slice` 三端 **42**；`const_module_slice`／`const_module_nested_slice`／`const_index_slice` 双端 **42**
  - 余（已闭 非 main 读模块 const 数组）：@ **`c06f206ef`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；host-C 函数作用域 dest-SLICE 模块 VAR

✅ **非 main 读模块 const 数组** ✅ @ **`c06f206ef`**

  - 现场：`const A:[2]i32=[10,32]`／`const B:[2][2]i32` 只 hoist 进 main；prepare 跳过 is_const → helper INDEX CG002（code_len=12）
  - **根修（G.7 有则补全）**：产生点＝prepare 整表跳 const。const TYPE_ARRAY＋ARRAY_LIT（元非 SLICE）走同一 COMMON；hoist 不再拷；`seed_nonzero` 写 LIT。const `[N][]T`（元 TYPE_SLICE）仍 hoist＋durable（cmns na fat 行）。权威 `runtime_pipeline_abi.x`（prefer thin+rest）
  - **禁**：hoist dest-SLICE const；`try_emit` 第 8 参；ARRAY_LIT 进 `try_emit`；pin；parser assemble／pipeline_abi mega 真开
  - 证：`const_module_nonmain` 三端 **42**；`const_module_slice`／`const_module_nested_slice`／`const_module_mut_slice`／`const_index_slice` 双端 **42**
  - 余（已闭 host-C 函数作用域 dest-SLICE 模块 VAR）：@ **`ec28e1f0f`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；函数作用域 const dest-SLICE 模块 VAR（typeck T001）

✅ **host-C 函数作用域 dest-SLICE 模块 VAR** ✅ @ **`ec28e1f0f`**

  - 现场：helper `let s:[]i32=A`（A 模块 TYPE_ARRAY）typeck 绿；host-C 发 `s=A`（数组进 slice 结构体 BLD001）。`try_emit` 只扫块／父块；体内加模块走查／第 8 参／helper 调用曾打爆 cis／nslvar 槽位
  - **根修（G.7 有则补全）**：产生点＝调用方 try_emit＝0 回退。文件作用域／init_globals 已有同走查抽成 `try_emit_dest_slice_from_module_array_var`；`emit_block` let／const／行 wrap／dep init 转调。**禁**再开 `try_emit` 体／第 8 参／ARRAY_LIT 进 `try_emit`
  - 禁：pin codegen_gen seed；parser assemble／pipeline_abi mega 真开
  - 证：`const_module_fn_slice` 三端 **42**（`-E` `{.data=A,.length=2}`／`[][]T=[A]` 同行 wrap）；cis／cms／cmnm／cmms／cmns 双端 **42**；host nslvar／nslpvar／nslcvar 金丝雀绿
  - 余（已闭 函数作用域 const dest-SLICE 模块 VAR）：@ **`ff65af43c`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；import 模块 const FIELD emit

✅ **函数作用域 const dest-SLICE 模块 VAR（typeck T001）** ✅ @ **`ff65af43c`**

  - 现场：`const s:[]i32=A`／`const x:[][]i32=[A]`／`const n:i32=A[1]` T001 const-expr（A 模块 const TYPE_ARRAY）
  - **根修（G.7 有则补全）**：产生点＝`typeck_is_const_expr_ref_impl` VAR 只扫块内名。`const_names!=NULL` 时复用 `pipeline_module_top_level_name_is_const`；C-static-init／pure-lit fold 仍 `NULL` 拒 VAR；可变模块 let 仍拒。镜像 post_E_fixup 叶 twin。权威 `typeck_cap_residual.from_x.c`（FROM_X assemble）
  - **禁**：pin typeck_gen seed；第二套 const-expr 检查；parser assemble／pipeline_abi mega 真开
  - 证：`const_module_fn_slice` wrap_cdecl 三端 **42**（`-E` `{.data=A,.length=2}`）；cis／cms／cmnm／cmms／cmns 双端 **42**；host nslvar／nslpvar／nslcvar 金丝雀绿
  - 余（已闭 import 模块 const FIELD typeck）：@ **`41bc131c7`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；import 模块 const FIELD emit

✅ **import 模块 const FIELD（typeck T001＋caller arena 盖印）** ✅ @ **`41bc131c7`**

  - 现场：`const n:i32=dep.K` T001（FIELD 只认 enum）；`let s:[]i32=dep.A` 盖成 i32（dep arena type_ref 不可移植）
  - **根修（G.7 有则补全）**：产生点＝白名单 FIELD＋`typeck_field_import_binding` 盖印。`const_names!=NULL` 时复用 Path A／B 只认 const 谓词；typed const 走既有 `get_dep_return_type_in_caller_arena`。C-static-init／fold 仍拒非 enum FIELD。裸 import const 仍拒。镜像 post_E twin。权威 `typeck_cap_residual.from_x.c`＋`typeck.x`（FROM_X assemble）
  - **禁**：pin typeck_gen seed；第二套 const-expr 检查；parser assemble／pipeline_abi mega 真开
  - 证：`const_import_module_slice` `-E` `n=K`；cis／cms／cmnm／cmms／cmns／cmfs 双端 **42**；slcdep／slclet **43**；矩阵 **5/5**
  - 余（已闭 import 模块 const FIELD emit host-C）：@ **`3b70c5327`**；另层：import 模块 const FIELD asm CG002；pipeline_abi `nf>0` 闸；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **import 模块 const FIELD emit（host-C INT_LIT＋dest-SLICE）** ✅ @ **`3b70c5327`**

  - 现场：`const n:i32=dep.K` host-C `n=K` 未声明（caller arena 读 dep `init_ref`）；dest-SLICE `dep.A` 发 C 成员 `dep.A`；`(T[]){…}` 行赋值悬空 → wrap_row 33
  - **根修（G.7 有则补全）**：产生点＝`emit_import_module_const_field`。INT_LIT／ARRAY_LIT 走 `pipeline_dep_ctx_arena_at`；ARRAY_LIT 发 durable `__xlang_icN`。try_emit FIELD 缺 N 时 return 0；`try_emit_dest_slice_from_import_const_field` `.data` 转调同一权威。权威 `codegen.x`（FROM_X assemble）
  - **禁**：`try_emit` 第 8 参；ARRAY_LIT 进 `try_emit`；体内模块走查；pin codegen_gen seed；parser assemble／pipeline_abi mega 真开
  - 证：`const_import_module_slice` host **42**（`-E` `n=10`／`{.data=({static T __xlang_icN[]={10,32};icN;}),.length=2}`）；cis／cms／cmnm／cmms／cmns／cmfs 双端 **42**；nslidx **32**；slcidx 行 **82**；nslvar **78**；矩阵 **5/5**
  - 余（已闭 import 模块 const FIELD asm）：@ **`ba5581e06`**；另层：pipeline_abi `nf>0` 闸；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **import 模块 const FIELD asm（dep-arena INT_LIT＋durable ARRAY_LIT）** ✅ @ **`ba5581e06`**

  - 现场：`dep.K`／`dep.A` asm CG002（code_len=12）。FIELD 基是 import 绑定 TYPE_NAMED，field_access／glue_emit_slice／glue_try_index 当结构体成员
  - **根修（G.7 有则补全）**：产生点＝asm FIELD 三消费端。`glue_emit_import_module_const_field_to_rax` 孪 host-C `emit_import_module_const_field`：import kind=1 绑定＋dep 顶层 const；INT_LIT／ARRAY_LIT 走 `pipeline_dep_ctx_arena_at`；INT_LIT mov imm；ARRAY_LIT durable（consts-only dep 不共编）。权威 `runtime_pipeline_abi.x`（prefer thin+rest）
  - **禁**：pipeline_abi mega 真开；`nf>0` 闸本叶；`try_emit` 第 8 参；ARRAY_LIT 进 `try_emit`；pin codegen_gen seed；parser assemble
  - 证：`const_import_module_slice` 双端 **42**；cis／cms／cmnm／cmms／cmns／cmfs 双端 **42**；nslidx **32**；slcidx 行 **82**；nslvar **78**；矩阵 **5/5**
  - 余（已闭 pipeline_abi `nf>0` 闸）：@ **`7e028d01a`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **pipeline_abi `nf>0` 闸（host-C consts-only dep 共编）** ✅ @ **`7e028d01a`**

  - 现场：`run_x_pipeline_codegen_one_dep_emit` 仅 `nf>0` 才调 `codegen_x_ast`；纯 const dep（`num_funcs==0`）不共编；`codegen_x_ast` emit_n phantom 死代码
  - **根修（G.7 有则补全）**：产生点＝同一 driver 闸。host-C：`nf>0` 或 `pipe_mod_get_num_top_level_lets>0` 则共编（file-static `A`／`K`）。asm 仍 `nf>0`：`asm_asm_codegen_ast` hoist 进 main，无函数 dep 无 main。权威 `runtime_pipeline_abi.x`＋seed 同 commit（prefer thin+rest；禁 mega）
  - **禁**：pipeline_abi mega 真开；`try_emit` 第 8 参；ARRAY_LIT 进 `try_emit`；动 codegen.x／pin
  - 证：`const_import_module_slice` `-E` `#undef K`／`static const int32_t K=10`／`#undef A`／`static const int32_t A[2]={10,32}`；双端 **42**；cis／cms／cmnm／cmms／cmns／cmfs 双端 **42**；nslidx **32**；slcidx 行 **82**；nslvar **78**；矩阵 **5/5**
  - 余（已闭 typeck 模块顶层 let 走查）：@ **`e9b02797c`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **typeck 模块顶层 let／const 初值走查** ✅ @ **`e9b02797c`**

  - 现场：`typeck_x_ast` 只走函数体；模块 `const x:i32=foo()`／`const x:i32=[1,2]`／`let x:i32=[1,2]` 假绿（asm run=42／BLD001 UNDEF）
  - **根修（G.7 有则补全）**：产生点＝无模块 let 初值走查。`typeck_x_ast_impl`／`library` 在 check_all_funcs 前走 `typeck_x_ast_check_top_level_lets`；const 复用同一白名单（`typeck_expr_is_const_with_module_consts`＝`const_names!=NULL` 调既有 impl）；check_expr＋coerce。权威 `typeck.x`＋residual（FROM_X assemble）
  - **禁**：第二套 const-expr 检查；fold import FIELD／module VAR 为 i32；pin typeck_gen seed；parser assemble／pipeline_abi mega 真开
  - 证：`module_const_call` **T001** const-expr；`module_const_badty`／`module_let_badty` **T001** expected i32 found `[2]i32`；cms／cmfs／cis／cims／cmnm／cmms／cmns 双端 **42**；host cms／cims／cis／cmfs **42**；矩阵 **5/5**
  - 余（已闭 asm INDEX-on-METHOD／CALL SIMD）：@ **`1f8560578`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **asm INDEX-on-METHOD／CALL SIMD** ✅ @ **`1f8560578`**

  - 现场：`simd.add(...)[0]`／`add4(...)[0]` asm SEGV 139（let-then `r[0]` 已绿；host-C `add(...)[0]` 本绿）
  - **根修（G.7 有则补全）**：产生点＝`glue_try_index_var_or_field_base_to_rax` 只认 VAR／FIELD，CALL／METHOD 回退 `emit_expr` 把 SIMD 值当指针。SIMD CALL／METHOD 复用 `glue_emit_struct_type_let_init` 泄到 next_offset 再 LEA（极性≡ assign STRUCT／CALL rhs）。TYPE_ARRAY／SLICE CALL 仍 -2（rax 已是 E*／fat.data）。权威 `runtime_pipeline_abi.x`（prefer thin+rest；seed stub 仍 -2）
  - **禁**：pipeline_abi mega 真开；`try_emit` 第 8 参；ARRAY_LIT 进 `try_emit`；动 emit_index／pin／codegen.x
  - 证：`index_on_method` 双端 **0**（const＋non-const METHOD／CALL）；v4i／i32m／i32c **0**；cims／cms／cis 双端 **42**；slcidx **42**；nslidx **32**；nslvar **78**；矩阵 **5/5**
  - 余（已闭 assign INDEX-on-METHOD rbx 孪）：@ **`492b5a8b1`**；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **assign INDEX-on-METHOD rbx 孪** ✅ @ **`492b5a8b1`**

  - 现场：rax 孪已泄 SIMD CALL／METHOD；rbx 孪仍 -2。有用 assign-from（`x=add4(...)[0]`／`arr[i]=add4(...)[0]`／`arr[add4(...)[0]]=k`）走 fallback 已绿；写临时量 `id4(...)[0]=k` host-C 非 lvalue。契约：assign rhs 占 rax。
  - **根修（G.7 有则补全）**：产生点＝`glue_try_index_var_or_field_base_to_rbx` 只认 VAR／FIELD。SIMD CALL／METHOD 转调 rax 孪（spill+LEA）再 mov→rbx；push/pop 保 rhs。TYPE_ARRAY／SLICE CALL 仍 -2。权威 `runtime_pipeline_abi.x`（prefer thin+rest；seed stub 仍 -2）
  - **禁**：pipeline_abi mega 真开；`try_emit` 第 8 参；ARRAY_LIT 进 `try_emit`；动 emit_index／pin／codegen.x；写 CALL SIMD 临时量当双端探针
  - 证：`assign_index_on_method` 双端 **0**；iom 双端 **0**；v4i／i32m／i32c **0**；cims／cms／cis 双端 **42**；slcidx **42**；nslidx **32**；nslvar **78**；tidx **42**；sai **47**；mcc **T001**；矩阵 **5/5**
  - 余（已闭 import METHOD 标量 f32 xmm）：见下；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；AAPCS64 s0–s7

✅ **import METHOD 标量 f32 xmm extras** ✅

  - 现场：s2 `simd.select_lane(1.0, 3.0, 4.0)` asm run=7（host-C 0；i32 extras 本绿）。`.x` METHOD extras 只走 GP／MEMORY；seed `_impl` 已有 SSE
  - **根修（G.7 有则补全）**：产生点＝`.x` import METHOD＋UFCS leave 分类。补 `glue_arg_ref_is_sse_float_c`／`glue_arg_ref_is_f64_width_c`（≡ seed static）；xmm 槽＋movd／movq。ta==0 only（≡ seed）
  - **禁**：pipeline_abi mega；`try_emit` 第 8 参；动 emit_index／pin／classifier；新开第二套 packer
  - 证：`import_method_f32_xmm`／s2 Ubuntu **0**；iom／aiom **0**；矩阵 **5/5**
  - 余（已闭 AAPCS64 import METHOD f32 s0–s7）：见下；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **AAPCS64 import METHOD 标量 f32 extras（s0–s7）** ✅ @ **`320a81d0c`**

  - 现场：mac imf32／s2 `select_lane(1.0,3.0,4.0)` asm 7（host-C 0；Ubuntu xmm 本绿）
  - **根修（G.7 有则补全）**：产生点＝encoder `mov_eax_to_xmm` ta!=0 回 −1；METHOD `is_sse` 闸 ta==0。补 `fmov sK,w0`／`w0,sK`／`dK,x0`／`x0,dK`；import METHOD extras 开 ta==1；call 后 harvest s0／d0。形参 f32 压过 FLOAT_LIT 默认 f64。**禁**开 UFCS／CALL packer／param home
  - 权威 encoder seed＋`.x`＋`backend_call_dispatch.x`（prefer thin+rest）
  - 证：mac imf32 **0**（`fmov s0–s2`＋`fmov w0,s0`）；Ubuntu imf32／s2 **0**；iom／aiom **0**；矩阵 **5/5**
  - 余（已闭本地 f32 CALL 形参 4B 槽）：见下；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **本地 f32 CALL 形参 4B 槽** ✅ @ **`acf69ab57`**

  - 现场：s2 `fill4(1.0)` asm 10；`add1`／identity／var-pass 红；host-C 0。callee `return x` 发 `fmov d0,x0; fcvt s0,d0`
  - **根修（G.7 有则补全）**：产生点＝`glue_load_f32_var_slot_to_rax_elf_c` 只 ta==0 走 4B。`f32en` 开时 caller 已把原生 f32 位放进 x0（`call_abi_widen_f64=0`）；ta==1 误当 f64 再 `cvtsd2ss`。开 ta==0／1 4B lane。rbx 孪转调。**禁**开 UFCS／CALL packer／param home／s0 harvest
  - 权威 `runtime_pipeline_abi.x`（prefer thin+rest；seed 冷 stub −1）
  - 证：mac lf32／s2／imf32 **0**（`idf` 无 `fcvt`）；Ubuntu lf32／s2／imf32／iom／aiom **0**；矩阵 **5/5**
  - 余（已闭 Vec4f 逐 lane addss＋AAPCS64 极性）：见下；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **Vec4f 逐 lane addss＋AAPCS64 极性** ✅

  - 现场：`let c:Vec4f=a+b` mac asm lane0＝11、lane1+ 红；host-C 0。x86 HW addps 可藏。
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_vector_lane_scalar_binop` 整数 ADD＋load `base-lane*esz`。复用 scalar addss／subss／mulss；lane 槽 ta==1 `base+lane*esz`（≡ INDEX assign）。**禁**开 METHOD binop2 名字表。
  - 权威 `runtime_pipeline_abi.x`（prefer thin+rest）
  - 证：mac v4a／s2／lf32／iom **0** · Ubuntu v4a／s2／lf32／iom／aiom **0** · 矩阵 **5/5** @ **`c160fb4ae`**
  - 余（已闭 Vec4f 逐 lane divss）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **Vec4f 逐 lane divss** ✅ @ **`11bc90275`**

  - 现场：`let c:Vec4f=a/b` mac asm run=1（c[0]）；host-C 0。addss／subss／mulss 已绿，`/` 仍走整数 idiv。
  - **根修（G.7 有则补全）**：产生点＝`glue_apply_vector_lane_f32_binop` 只认 ko=4／5／6。复用既有 scalar `backend_enc_divss_rax_rbx_arch`（thin 含 AAPCS64 fdiv）；快／慢路径开 ko=7；f32 `/0` 走 IEEE Inf／NaN，禁整数 #DE 闸（0.0f 位＝0）。**禁**开 METHOD binop2／UFCS／CALL packer；**禁**再加 late export-extern（divss 早前面已在）。
  - 权威 `runtime_pipeline_abi.x`（prefer thin+rest；seed 活孪）
  - 探针 `tests/boundary/vec4f_div.x`
  - 证：mac v4d／v4a／s2／lf32／iom／vadd／imf32 **0** · Ubuntu v4d／v4a／s2／lf32／iom／aiom／vadd／imf32 **0** · 矩阵 **5/5**
  - 余（已闭 i32x4 `/` 后 lane）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **i32x4 `/` 后 lane AAPCS64 4B LDRSW** ✅ @ **`4ac03565b`**

  - 现场：`let c:i32x4=a/b` mac asm run=3（c[2]≠5；lane0／1 绿）；host-C 0；Ubuntu 0。`+`／`*`／`%` 后 lane与标量 `/` 本绿。
  - **根修（G.7 有则补全）**：产生点＝thin `backend_enc_load_rbp_lane_to_rax/rbx` ta==1 忽略 esz，发 `ldr x0`／`ldr x1`。seed idiv 是 64 位 `sdiv x0,x0,x1`（i64 `/` 要用，**禁**改成 32 位）。lane0 的 8／2 与 12／3 碰巧同商＝4；lane2 的 `(20|4<<32)/(4|2<<32)`＝2。复用／补全 `arm64_enc_load_w0_from_rbp_c` 为正向 LDRSW（wave616 正极性；旧体 LDUR −off 半残）；加 w1 孪（≡ x86 eax32／ebx32）。
  - 权威 `backend_enc_dispatch_thin.x`＋seed 同 commit（prefer thin+rest）
  - 探针 `tests/boundary/i32x4_div.x`
  - 证：mac i32d／v4d／v4a／lf32／iom／imf32／vadd **0** · Ubuntu i32d／v4d／v4a／lf32／iom／aiom／imf32／vadd **0** · 矩阵 **5/5**
  - 余（已闭 INDEX 负 i32 比宽）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **INDEX 负 i32 比宽 AAPCS64 LDRSW** ✅ @ **`0e42fa8c5`**

  - 现场：`let a:[2]i32=[0-5,4]; if (a[0] != 0-5)` mac asm run=3；i32x4 负 lane 比 −5 run=6；标量 var／call-ret 本绿；host-C 0。dump：`ldr w0,[x0]` 后再 `cmp x1,x0` 对 64 位 `movk` −5。
  - **根修（G.7 有则补全）**：产生点＝thin `backend_enc_load_i32_indirect_to_rax_arch` ta==1 发 `ldr w0`（零扩展）。x86 已 movl＋CDQE。ARM64 改 `LDRSW x0,[x0]`（0xB9800000；≡ 上波 lane LDRSW 族）。**禁**改 `load_32_from_rax`（f32 位／无符号 32 仍零扩展）；**禁**改 64 位 idiv；**禁**开 METHOD binop2。
  - 权威 `backend_enc_dispatch_thin.x`＋seed 同 commit（prefer thin+rest）
  - 探针 `tests/boundary/i32_index_neg_cmp.x`
  - 证：mac inc／i32d／v4d／v4a／lf32／iom／aiom／imf32 **0** · Ubuntu inc／i32d／v4d／v4a／lf32／iom／aiom／imf32 **0** · 矩阵 **5/5**
  - 余（已闭 i64 大字面量比宽）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **i64 大字面量比宽（2^32 跳 i32-imm）** ✅ @ **`94481923c`**

  - 现场：`let a:i64=4294967296; if (a != 4294967296)` mac asm run=1；`a+4294967296` run=3；host-C 0；let／`==0`／i32max 本绿。dump：`mov w0,#0`／`movl $0` 对 64 位 cmp。
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_cmp_expr_lit_i32_at` 对任意 INT_LIT 截 `int_val`（2^32 低 32＝0）。复用 `glue_binop_expr_is_wide_int_lit`，宽 lit 回 0，调用方走 emit_expr（`mov_imm64`）。seed `cmp_expr_lit_i32_seed` 同 commit。**禁**改 `load_32_from_rax`／64 位 idiv；**禁**开 METHOD binop2。
  - 权威 `runtime_pipeline_abi.x`（prefer thin+rest）
  - 探针 `tests/boundary/i64_lit_cmp.x`
  - 证：mac i64c／incn／i32d／v4d／v4a／lf32／iom／aiom／imf32 **0** · Ubuntu i64c／incn／i32d／v4d／v4a／lf32／iom／aiom／imf32 **0** · 矩阵 **5/5**
  - 余（已闭 STRUCT_LIT bool／u8 填充）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **STRUCT_LIT bool／u8 填充存宽** ✅ @ **`7fcc8a02d`**

  - 现场：Darwin 矩阵 option=254（`return -2`）。inlined `Option { is_some:false }` `strb` 留 3B pad，`is_some`／`unwrap` `ldr w` 当 Some
  - **根修**：`glue_struct_lit_field_store_sz` — bool／u8 到下一字段／结构尾 gap≥4 则存 4。权威 `runtime_pipeline_abi.x`＋seed
  - 证：双端矩阵 **5/5** opt=102
  - 余（已闭 typeck FIELD overload）：见下

✅ **typeck 导入限定 FIELD 末段 concrete（overload）** ✅ @ **`565e105b3`**

  - 现场：`heap.alloc(h.al, n)` T001 expected `*u8` found `*u64`。`typeck_named_is_module_concrete` 精确比 layout 名，`heap.Allocator`≠`Allocator` 当自由 T → ambient `*u8` 盖 FIELD → first_idx `alloc(i32):*u64`
  - **根修**：末段名 ≡ `typeck_field_layout_named` 去点。权威 `typeck.x`（assemble；禁改 typeck_gen pin／first_idx）
  - 证：`-E` 发 `alloc_Allocator_usize(((h).al))` · `run-vec` 0 · 矩阵 **5/5**
  - 余（已闭 asm FIELD 16B）：见下

✅ **asm FIELD 16B 实参 ARM64 dual-GP** ✅ @ **`2dfbf7157`**

  - 现场：`heap.alloc(h.al, n)`／同模 16B `take(h.a)` Darwin `-o` CG002。4B／8B FIELD 与 16B let-bind VAR 本绿
  - **根修**：`backend_enc_load_qword_*_arch` ta==1 发 `ldr x0,[x1]`／`ldr x1,[x1,#8]`。权威 `backend_enc_dispatch.x`＋seed／thin／surface
  - **禁**批补其余 `ta!=0` 桩
  - 证：`field_struct16_arg`=42 · `field_alloc` `-o`=0 · 矩阵 **5/5**
  - 余（已闭 heap Arena64 FFI）：见下

✅ **heap `Arena64` FFI 转型** ✅ @ **`1f1aff751`**

  - 现场：`alloc(al, n)` 把 `al.arena`（`*Arena64`）裸传 `heap_arena64_alloc_c(*LibcArena64)` → standalone `-E` T001／XP003。同文件 `arena64_init`／`alloc`／`deinit` 已转型
  - **根修**：bump 路径补同一 `as *heap_libc.LibcArena64`。**禁**改 typeck 把异名结构当兼容
  - 证：`-E std/heap/mod.x` typeck OK · `field_alloc`／`run-vec` 0 · 矩阵 **5/5**
  - 余（已闭 dest 影子 x19）：见下

✅ **用户 `-o` integer div0 panic** ✅ @ **`2c8489304`**

  - 现场：Stage 12.0.5 掏空 `pipeline_asm_emit_divisor_zero_check_rbx_elf_c`；Ubuntu `idiv #0` SIGFPE 假绿；Darwin `sdiv #0` 得 0
  - **根修**：用户 `-o` 恢复 test+jne+CALL `xlang_panic_`；`XLANG_PREFER_ASM_O=1` 仍 no-op
  - 证：`run-ub`／`run-lang-unsafe` `div_zero` panic · 矩阵 **5/5** · **钉盘 L4 已证**
  - 余（已闭 ARM64 add_imm SUB）：见下

✅ **ARM64 add_imm 负数发 SUB** ✅ @ **`2ea18960c`**

  - 现场：slice hi-guard `add_imm_to_rbx(-1)` 后 `jge`；encoder `left<0→0` 无 SUB → `bounds_slice` unexpected exit 0
  - **根修**：`arm64_enc_add_rd_rn_imm_chunks` 负数按 4095 块发 SUB。权威 seed＋`arch/arm64_enc.x`
  - 证：反汇编 `sub x1,#1` · `bounds_slice` rc=1 · **钉盘 L4 已证**
  - 余（已闭 extra-.o has_obj）：见下

✅ **extra-.o has_obj 去重（invoke_cc／asm ld／sat mega）** ✅ @ **`f7424ae47`**

  - 现场：`xlang-c -o` 链同一 `runtime_atomic_glue.o`／`time_os.o` 两次 → Darwin ld duplicate symbol。C 路径只 strcmp；asm 路径 Track-L 丢 `if (has_obj())`；L4 sat `try-r1` 编 mega `#ifndef` 旧体盖 prefer `.x`
  - **根修**：`link_abi_asm_ld_argv_has_obj`（string＋realpath）补进 `push_existing`／`append_user_extra` prefer `.x`／sat mega 冷体
  - **禁**改 `run-std-io-context-gate.sh`
  - 证：带 extra／不带 extra／gate 0 · **钉盘双端 L4 io-context 绿**
  - 残：sat 路由 **已开**（`try-r1` → `ensure_labi_prefer_one`）。**Darwin prefer hybrid merge ✅**（F7 双 `LC_SEGMENT` → Apple `ld -r` 拒 → `libtool -static`；labi **473640**）。**Ubuntu pipeline_abi thin inject first-wins ✅**（`$CC -r -Wl,--allow-multiple-definition`；reent／arrcopy inject **OK**；ELF **1739904** 单 T）。Ubuntu ELF prefer **477800**。L0 `-E` `getcwd` **已闭**。emit_header `h[88]` 超额初始化 **已闭**（`u8[83]`）。dest extra-arm 末尾 `{ fields }` host-C **已闭**。dest extra-arm `unsafe {…}; dest` ASI **已闭**。dest extra-arm `region {…}; dest` ASI **已闭**。parse_into 函数体 `region {}; return` 同模式 ASI **已闭**。`push_stable` prefer 已调权威 `has_obj`。

✅ **Darwin `default_alloc` dest 影子 x19（跨 16B CALL）** ✅ @ **`6b42ab1b2`**

  - 现场：rewrite `bl _std_heap_default_alloc` 后 dest 在 x1，16B 返回写 x1 → `str x0,[x1=0]` SIGSEGV。改 try_inline mega `.x`：Ubuntu 同 TU `-E` 编译器 139（已退）
  - **根修**：小叶 encoder — `mov_rax_to_rbx` 兼 `mov x19,x0`；`store(sz>=16)` 走 `[x19]`＋hi `[x19+8]`。权威 `arch/arm64_enc.x`＋seed
  - **禁**再改 try_inline mega `.x`；INDEX／sz<16 仍走 x1
  - 证：`default_alloc_method` Darwin 0（`mov x19; bl; str [x19]`）· 双端矩阵 **5/5** · **日常 L2 不升钉**
  - 余（已闭 dest-SLICE INDEX fat ARM64 dual-GP）：见下；另层：METHOD binop2 仍 CALL-only（本地 CALL `add(a,b)` 已 0）；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19（X-to-X dest-across-call 残）

✅ **asm dest-SLICE INDEX fat ARM64 dual-GP** ✅

  - 现场：`let x:[][]i32=[a]`／`[mk()]`／`[w.xs()]` Darwin `x[0][0]` panic（length=0）。`pipeline_asm_emit_index` rtk==11 手写 `arg_reg(2)`：x86 rdx＝dual-GP 高半；ARM64 第 3 参 x2，随后 `store_rdx` 写 x1（hi-guard `length-1`）
  - **根修（G.7 有则补全）**：TYPE_SLICE fat 复用同一 `pipeline_asm_deref_struct16_rax_ptr_elf_c`（`*addr → rax+rdx/x1` ≡ 9–16B named）。权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble／pure-asm mega；**禁**改 `arg_reg(2)` 真 3 参（memcpy x2）
  - 证：nslvar／nslcall／nslmethod／nslcall_dep／nslcvar／nslpvar **78** · nslarr／nslarr_call／nslarr_call_dep **71** · nsllet_call **43** · nslfield／nslidx／tidx **42** · nslidx_row **82** · nslsai **47** · 矩阵 **5/5** · dest 邻域 default_alloc／field_struct16／field_alloc **0／42／0**
  - 余（已闭 ARM64 >16B INDEX MEMORY consume）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；shuffle 8-lane leftover；ARM64 prologue 未存 x19

✅ **ARM64 >16B INDEX MEMORY consume** ✅

  - 现场：`index_method_wide` Darwin CG002 139。`let w=a[1]` 走 `glue_copy_large_struct_from_rax_ptr` `ta!=0` 拒；`a[1].last()`／`take_w(a[1])` prefer `.x` 把 INDEX 指针当 20B（is_mem=2 lea／`str x0,[sp]`），callee `param_home` 读栈三字
  - **根修（G.7 有则补全）**：`glue_copy` 收 ta==1（≡ sret memcpy：src@x1 n@x2 dest@x0 last）；UFCS／`emit_call_args` ARM64 MEMORY 收回 seed wave603／606（`store_memory_by_value_to_sp`）。权威 `runtime_pipeline_abi.x` prefer thin+rest＋`backend_call_dispatch.x`。**禁** emit_index 内 memcpy；**禁**改 import METHOD is_mem=2（host-C AAPCS64 指针）；**禁** try_inline mega
  - 证：mac method／take／let／ret／`index_method_wide` **0** · Ubuntu 金标 `index_method_wide` **0** · 邻域 da／fs16／fa／idx／trip／quad **0／42／0／0／0／0** · 矩阵 **5/5** · **日常 L2 不升钉**
  - 余（勿并本叶）：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；shuffle 8-lane leftover；ARM64 prologue 未存 x19

✅ **Darwin import METHOD host-C f32 返回 s0→w0** ✅

  - 现场：`simd.hsum([1,2,3,4])` Darwin ≠10。本地同体 `hsum`／`simd.add`／lane INDEX 本绿。host-C `_std_simd_hsum` 把 f32 放 `s0`；Darwin 活 seed 只 `str x0`
  - **根修（G.7 有则补全）**：prefer `.x` import METHOD 已有 `rk==14` `fmov w0,s0`。补进 seed METHOD＋同模式 import-binding／whole-import CALL。权威 `backend_call_dispatch.from_x.c`（Darwin try-heat／r3-prefer 活 seed）。**禁**把 f32 收进共享 `glue_asm_harvest`（本地 X callee 仍 GP）
  - 证：mac hsum lit／let／`array_lit_vec4f_import`／xlang-c **0** · Ubuntu 金标 official **0** · `import_method_f32_xmm` Ubuntu **0**／Darwin 仍 7 · 邻域 da／fs16／fa／imw／nslvar **0／42／0／0／78** · 矩阵 **5/5** · **日常 L2 不升钉**
  - 余（已闭 Darwin 活 seed extras s0–s7）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；shuffle 8-lane leftover；ARM64 prologue 未存 x19

✅ **Darwin 活 seed import METHOD f32 extras s0–s7** ✅

  - 现场：`import_method_f32_xmm` `select_lane(1.0,3.0,4.0)` Darwin 7。i32 import／本地 f32 本绿。收获 `fmov w0,s0` 已在；caller 把 extras 放 x0／x1／x2，host-C 读 s0–s2
  - **根修（G.7 有则补全）**：prefer `.x` import METHOD 已 `ta==0||ta==1` SSE 分类（@ **`320a81d0c`** encoder＋prefer）。Darwin 活 seed `is_sse=(ta==0)?…:0` 把 ARM64 extras 当 GP。补同一闸 `ta==0||ta==1`。权威 `backend_call_dispatch.from_x.c`（try-heat／r3-prefer 活 seed）。**禁**开 UFCS extras（本地 X callee 仍 GP）；**禁** try_inline mega
  - 证：mac `select_lane` f32／i32／local／official／xlang-c **0**（反汇编 `fmov s2; s1; s0; bl; fmov w0,s0`）· 邻域 vec4f／local_f32／i32x4／da／fs16／fa／imw／idx／nslvar **0／0／0／0／42／0／0／0／78** · 矩阵 **5/5** · Ubuntu 金标 imf／vec4f／lf32／i32x4／da／fs16／fa／imw／nslvar **0／0／0／0／0／42／0／0／78** · 矩阵 **5/5** · **日常 L2 不升钉**
  - 余（已闭 ARM64 INDEX 非 1/4/8 步长 64 位 scale1）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；shuffle 8-lane leftover；ARM64 prologue 未存 x19

✅ **ARM64 INDEX 非 1/4/8 步长 64 位 scale1** ✅

  - 现场：`Particle[8]`（12B AoS）／`f32_soa_sum_*` Darwin 139。展开字面量／`One[8]`（×4 LSL）本绿。`mul w1,w1,#12` 后 `add w0,w1,w0` 截断栈指针
  - **根修（G.7 有则补全）**：`glue_emit_index_rax_plus_rbx_scaled` 非 1/4/8 在 `mul_imm` 后走同一 `rax_plus_rbx_scale1`（≡ Stage 12.0.5 ptr+int／esz==1）。同模式 SoA dyn index。权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**改 `enc_add_rax_rbx`（u32 回绕）；**禁** try_inline／全量 assemble
  - 证：p3／p8／soa8／one8／u32wrap **3／8／8／8／0**（`add x0,x0,x1`）· peel／strip／varn **8／10／12** · `index_struct12_loop` **8** · 邻域 da／fs16／fa／imw／nslvar **0／42／0／0／78** · 矩阵 **5/5** · Ubuntu 金标 `index_struct12_loop` **8** · peel／strip／varn **8／10／12** · 邻域同上 · 矩阵 **5/5** · **日常 L2 不升钉**
  - 余（已闭 ARM64 Vec8i shuffle 高半 slot+16）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；Vec4f select 值验；ARM64 prologue 未存 x19

✅ **ARM64 Vec8i shuffle 高半 slot+16** ✅

  - 现场：`shuffle_select_roundtrip` `r8[4]≠7` Darwin／xlang-c 6。identity `r[4]≠4`＝24。high-copy／lane-scalar 本绿。反汇编 half1 `ld1 [x29]`（`slot-16` 被 `lea_rbp` 钳 0）
  - **根修（G.7 有则补全）**：`simd_arm64_rbp_lea_off_128half` 改 `slot+half*16`（≡ ARM64 低端 home／INDEX `[base+lane*esz]`）。权威 `simd_enc.x`／thin／seed 冷孪。**禁**改 mega inliner／try_inline
  - 证：iso／id／hi／`shuffle_vec8i_highhalf` **0**（half1 `add #src+16`）· 4-lane shuffle 仍过 · 邻域 da／fs16／fa／imw／nslvar **0／42／0／0／78** · 矩阵 **5/5** · Ubuntu 金标 `shuffle_vec8i_highhalf` **0** · `shuffle_select_roundtrip` **0** · 邻域同上 · 矩阵 **5/5** · **日常 L2 不升钉**
  - 余（已闭 ARM64 Vec4f select fcmgt 后 BSL）：见下；另层：METHOD binop2 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **ARM64 Vec4f select fcmgt 后 BSL** ✅

  - 现场：`shuffle_select_roundtrip` Darwin／xlang-c 7（`s4[0]≠2.0`）。`sel4_only`／`sel4_local` 同 7。dump `s4[0]` 既非 2.0／0.5／1.0／0.0（99）。all-a／all-b 亦红。Vec8i select 本绿。反汇编 `fcmgt.4s v3, v0, #0.0` 后 `bit.16b v3, v1, v2`
  - **根修（G.7 有则补全）**：i32 路径已用 `BSL Vd,Vn,Vm`＝`(Vd AND Vn) OR (~Vd AND Vm)`（dest=谓词，n=a，m=b）。f32 误用 `BIT`＝`(Vm AND Vn) OR (~Vm AND Vd)`，把 b 当谓词。权威 `simd_arm64_select_128_rbp` 改发同一 BSL 字 `0x6e621c23`。`simd_enc.x`＋seed／surface 冷孪。**禁**改 mega inliner／try_inline
  - 证：mac iso／dump／all-a／all-b／local／`select_vec4f`／`shuffle_select_roundtrip`／xlang-c **0**（反汇编 `fcmgt; bsl v3,v1,v2`）· 邻域 da／fs16／fa／imw／nslvar／imf／vec4f／is12／sv8 **0／42／0／0／78／0／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `select_vec4f`／`shuffle_select_roundtrip` **0** · 邻域同上 · 矩阵 **5/5**（try_inline 仍 seed 57672；simd_enc prefer thin+rest 68808）· **日常 L2 不升钉**
  - 余（已闭 METHOD binop2 UFCS let-init）：见下；另层：nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **METHOD binop2 UFCS let-init** ✅

  - 现场：`let c:i32x4=a.add4(b)` Darwin `c[1]=0`（lane0=11）。CALL `add4(a,b)` 已 0。官方 `array_lit_i32x4_method` 只比 lane0 假绿。反汇编 METHOD 走 `bl _add4`：caller 只传前 8B，callee `add w` 只加 lane0
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_simd_try_inline_binop2_call_elf_c` 只认 CALL=48。METHOD=49 UFCS `nargs==1`：名走 `method_call_name_*`，arg0=base／arg1=extra[0]，同一 body fold（nparams==2，p0 binop p1）。**禁** add／sub／mul 名字表（会抢 import METHOD／INDEX-on-METHOD）
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble／try_inline mega／改 callee 体／x19 序言
  - 证：mac `vec_add4_method_inline`／xlang-c **0**（反汇编 4×`ldrsw; add w; str` 无 `bl _add4`）· Vec8i METHOD let **0** · CALL／iom／imf／sel4／sv8／da／fs16／fa／imw／nslvar／is12 **0／0／0／0／0／0／42／0／0／78／8** · 矩阵 **5/5** · Ubuntu 金标 `vec_add4_method_inline`／xlang-c **0** · 邻域同上 · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1615104）· **日常 L2 不升钉**
  - 余（已闭 VAR assign 16B CALL dual-GP）：见下；另层：import `simd.add` METHOD extras=2 仍 CALL emit；METHOD 向量 assign 仍 CALL-only；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **VAR assign 16B CALL dual-GP** ✅

  - 现场：`y = id16(x)`／`z = outer(x)` Darwin `y.b=0`（exit 2）。`let y = id16(x)` 已 0。反汇编 callee 已 `x0+x1`；caller `bl` 后只 `str x0,[y]`
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_assign_elf_c` VAR 存：SLICE／f32 有专案，else 只 `store_rax`。权威已是 `glue_store_retval_pair_to_rbp_elf_c`（let-init）。VAR else 改走同一 helper。**禁**改序言／x19／try_inline／METHOD 向量 assign
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 证：mac `struct16_assign_call`／xlang-c **0**（反汇编 `str x0; str x1`）· pair／nested／let **0** · vam／da／fs16／sel4／sv8／is12／nslvar **0／0／42／0／0／8／78** · 矩阵 **5/5** · Ubuntu 金标 `struct16_assign_call`／xlang-c **0** · 邻域同上 · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1615176）· **日常 L2 不升钉**
  - 余（已闭 METHOD 向量 assign let-init reuse）：见下；另层：import extras=2 CALL emit 值绿；nest>16 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **METHOD 向量 assign let-init reuse** ✅ @ **`3f70bd34d`**

  - 现场：非 let `d = a.add4(b)` Darwin 12（`d[1]≠22`）。`let c = a.add4(b)` 已 0。反汇编走 `bl _add4`：callee 只加 lane0
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_assign_elf_c` VAR 在 TYPE_ARRAY／SLICE 已复用 let-init，TYPE_VECTOR 跌进 CALL＋dual-GP。权威已是 `glue_emit_vector_type_let_init_elf_c`（splat／select／shuffle／fma3／binop2）。VAR 补同一 sibling。**禁**第二条 inliner／改 callee 体／x19 序言／try_inline
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 证：mac `vec_add4_method_assign`／xlang-c **0**（反汇编 lane `add w` 无 `bl _add4`）· vam／vac／s16／sel4／sv8／iom／imf／da／fs16／is12／nslvar／imw **0／0／0／0／0／0／0／0／42／8／78／0** · 矩阵 **5/5** · Ubuntu 金标 `vec_add4_method_assign`／xlang-c **0** · 邻域同上 · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1615392）· **日常 L2 不升钉**
  - 余（已闭 host-C nest 17 fat）：见下；另层：import extras=2 CALL emit 值绿；nest>18 soft；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **host-C nest 17 fat（nest>16 soft 第一层）**

  - 现场：17 层 `[]…[]i32`／`[]…[]Cell` 未用形参 `-E` 发 17 层 tag，header 只到 16 → host-cc `struct` 函数作用域可见性／conflicting types。asm `-o` 本绿（未用形参）
  - **根修（G.7 有则补全）**：同一 `codegen_emit_slice_fat_one`／`codegen_emit_scalar_slice_nests`／companion／`emit_header` 墙 16→17；第三闸 `XLANG_SLICE_LAYOUTS_N17`。**禁**抬到 24（`type_to_c_repr` `u8[256]` 12×24 溢出 XP003）；**禁**改 pipeline_abi／seed emit_header u8[256]／driver_preamble N=224
  - 权威 `codegen.x`（FROM_X assemble → `codegen_x.o`）。pin `codegen_gen.linux.x86_64.c` 不改
  - 证：mac `nested_slice17`／`nested_named17` asm **70／75** · `-E`+host-cc **0** · ALLOW `-backend c` **70／75** · n16／named16／n8／n9／named8／named7／nslvar **60／65／40／50／55／45／78** · 矩阵 **5/5** · Ubuntu 金标 n17／named17 asm **70／75** · `-E`+cc **0** · ALLOW c **70／75** · 邻域同上 · 矩阵 **5/5**（try_inline 仍 seed 57672；codegen_x.o FROM_X 447944）· **日常 L2 不升钉**
  - 余（已闭 host-C nest 18 fat）：见下；另层：nest>18 soft（19–20 仍进 256；nest 21 溢出）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **host-C nest 18 fat（nest>17 soft 下一层）** ✅ @ **`fdcaec69f`**

  - 现场：18 层 `[]…[]i32`／`[]…[]Cell` 未用形参 `-E` 发 230 字节 tag（仍进 `type_to_c_repr` 256），header 只到 17 → host-cc conflicting incomplete types。asm `-o` 本绿（未用形参 80／85）
  - **根修（G.7 有则补全）**：同一 emitter／companion／`emit_header` 墙 17→18；第四闸 `XLANG_SLICE_LAYOUTS_N18`。**禁**抬到 21（i32 tag 266 溢出 256）；**禁**改 pipeline_abi／seed emit_header u8[256]／driver_preamble N=224
  - 权威 `codegen.x`（FROM_X assemble → `codegen_x.o`）。pin `codegen_gen.linux.x86_64.c` 不改
  - 证：mac `nested_slice18`／`nested_named18` asm **80／85** · `-E`+host-cc **0** · ALLOW `-backend c` **80／85** · n17／named17／n16／named16／n8／n9／named8／named7／nslvar **70／75／60／65／40／50／55／45／78** · 矩阵 **5/5** · Ubuntu 金标 n18／named18 asm **80／85** · `-E`+cc **0** · ALLOW c **80／85** · 邻域同上 · 矩阵 **5/5**（try_inline 仍 seed 57672；codegen_x.o FROM_X 448616）· **日常 L2 不升钉**
  - 余（已闭 host-C nest 19 fat）：见下；另层：nest>19 soft（20 仍进 256；nest 21 溢出）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **host-C nest 19 fat（nest>18 soft 下一层）** ✅ @ **`acb0c2b1a`**

  - 现场：19 层 `[]…[]i32`／`[]…[]Cell` 未用形参 `-E` 发 242 字节 tag（仍进 `type_to_c_repr` 256），header 只到 18 → host-cc conflicting incomplete types。asm `-o` 本绿（未用形参 90／95）
  - **根修（G.7 有则补全）**：同一 emitter／companion／`emit_header` 墙 18→19；第五闸 `XLANG_SLICE_LAYOUTS_N19`。**禁**抬到 21（i32 tag 266 溢出 256）；**禁**改 pipeline_abi／seed emit_header u8[256]／driver_preamble N=224
  - 权威 `codegen.x`（FROM_X assemble → `codegen_x.o`）。pin `codegen_gen.linux.x86_64.c` 不改
  - 证：mac `nested_slice19`／`nested_named19` asm **90／95** · `-E`+host-cc **0** · ALLOW `-backend c` **90／95** · n18／named18／n17／named17／n16／named16／n8／n9／named8／named7／nslvar **80／85／70／75／60／65／40／50／55／45／78** · 矩阵 **5/5** · Ubuntu 金标 n19／named19 asm **90／95** · `-E`+cc **0** · ALLOW c **90／95** · 邻域同上 · 矩阵 **5/5**（try_inline 仍 seed 57672；codegen_x.o FROM_X 449296）· **日常 L2 不升钉**
  - 余（已闭 host-C nest 20 fat）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **host-C nest 20 fat（nest>19 soft 下一层）** ✅ @ **`0797a8a6c`**

  - 闸：`tests/boundary/nested_slice20.x` 100／`nested_named20.x` 105

✅ **host-C nest 21 fat（nest>20 soft 下一层）** ✅ @ **`53cb64f70`**

  - 闸：`tests/boundary/nested_slice21.x` 110／`nested_named21.x` 115（`type_to_c_repr` scratch 384）

✅ **host-C nest 22 fat（nest>21 soft 下一层）** ✅ @ **`6dbc6fe44`**

  - 闸：`tests/boundary/nested_slice22.x` 120／`nested_named22.x` 125（`type_to_c_repr` scratch 384；tag=278）

✅ **host-C nest 23 fat（nest>22 soft 下一层）** ✅ @ **`a6bc3686a`**

  - 闸：`tests/boundary/nested_slice23.x` 130／`nested_named23.x` 135（`type_to_c_repr` scratch 384；tag=290）

✅ **host-C nest 24 fat（nest>23 soft 下一层）** ✅ @ **`ca82bdd74`**

  - 闸：`tests/boundary/nested_slice24.x` 140／`nested_named24.x` 145（`type_to_c_repr` scratch 384；tag=302）

✅ **host-C nest 25 fat（nest>24 soft 下一层）** ✅ @ **`2b8c62ab6`**

  - 闸：`tests/boundary/nested_slice25.x` 150／`nested_named25.x` 155（`type_to_c_repr` scratch 384；tag=314）

✅ **host-C nest 26 fat（nest>25 soft 下一层）** ✅ @ **`3a5a976b2`**

  - 闸：`tests/boundary/nested_slice26.x` 160／`nested_named26.x` 165（`type_to_c_repr` scratch 384；tag=326）

✅ **host-C nest 27 fat（nest>26 soft 下一层）** ✅ @ **`f8c681f72`**

  - 闸：`tests/boundary/nested_slice27.x` 170／`nested_named27.x` 175（`type_to_c_repr` scratch 384；tag=338）

✅ **host-C nest 28 fat（nest>27 soft 下一层）** ✅ @ **`8d44384db`**

  - 闸：`tests/boundary/nested_slice28.x` 180／`nested_named28.x` 185（`type_to_c_repr` scratch 384；tag=350）

✅ **host-C nest 29 fat（nest>28 soft 下一层）** ✅ @ **`adfcbbf49`**

  - 闸：`tests/boundary/nested_slice29.x` 190／`nested_named29.x` 195（`type_to_c_repr` scratch 384；tag=362）

✅ **host-C nest 30 fat（nest>29 soft 下一层）** ✅ @ **`bdb0a32eb`**

  - 闸：`tests/boundary/nested_slice30.x` 200／`nested_named30.x` 205（`type_to_c_repr` scratch 384；tag=374）

✅ **host-C nest 31 fat（nest>30 加宽 scratch 512）** ✅ @ **`c1b1c9434`**

  - 闸：`tests/boundary/nested_slice31.x` 210／`nested_named31.x` 215（`type_to_c_repr` scratch 512；tag=386）

✅ **host-C nest 32 fat（nest>31 soft 下一层）** ✅ @ **`57c291a0c`**

  - 闸：`tests/boundary/nested_slice32.x` 220／`nested_named32.x` 225（`type_to_c_repr` scratch 512；tag=398）

✅ **host-C nest 33 fat（nest>32 soft 下一层）** ✅ @ **`afc954f51`**

  - 闸：`tests/boundary/nested_slice33.x` 230／`nested_named33.x` 235（`type_to_c_repr` scratch 512；tag=410）

✅ **host-C nest 34 fat（nest>33 soft 下一层）** ✅ @ **`5bb880f29`**

  - 闸：`tests/boundary/nested_slice34.x` 240／`nested_named34.x` 245（`type_to_c_repr` scratch 512；tag=422）

✅ **host-C nest 35 fat（nest>34 soft 下一层）** ✅ @ **`21f2200c5`**

  - 闸：`tests/boundary/nested_slice35.x` 250／`nested_named35.x` 255（`type_to_c_repr` scratch 512；tag=434）

✅ **host-C nest 36 fat（nest>35 soft 下一层）** ✅ @ **`91ef79032`**

  - 闸：`tests/boundary/nested_slice36.x` 36／`nested_named36.x` 46（`type_to_c_repr` scratch 512；tag=446；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 37 fat（nest>36 soft 下一层）** ✅ @ **`4c6bb66ba`**

  - 闸：`tests/boundary/nested_slice37.x` 37／`nested_named37.x` 47（`type_to_c_repr` scratch 512；tag=458；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 38 fat（nest>37 soft 下一层）** ✅ @ **`291a61d61`**

  - 闸：`tests/boundary/nested_slice38.x` 38／`nested_named38.x` 48（`type_to_c_repr` scratch 512；tag=470；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 39 fat（nest>38 soft 下一层）** ✅ @ **`bd45230a9`**

  - 闸：`tests/boundary/nested_slice39.x` 39／`nested_named39.x` 49（`type_to_c_repr` scratch 512；tag=482；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 40 fat（nest>39 soft 下一层）** ✅ @ **`994c02d1c`**

  - 闸：`tests/boundary/nested_slice40.x` 40／`nested_named40.x` 50（`type_to_c_repr` scratch 512；tag=494；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 41 fat（nest>40 soft 下一层）** ✅ @ **`a12c0aa25`**

  - 闸：`tests/boundary/nested_slice41.x` 41／`nested_named41.x` 51（`type_to_c_repr` scratch 512；tag=506；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 42 fat（nest>41 加宽 scratch 640）** ✅ @ **`58e48faff`**

  - 闸：`tests/boundary/nested_slice42.x` 42／`nested_named42.x` 52（`type_to_c_repr` scratch 640；tag=518；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 43 fat（nest>42 soft 下一层）** ✅ @ **`ce0ac6301`**

  - 闸：`tests/boundary/nested_slice43.x` 43／`nested_named43.x` 53（`type_to_c_repr` scratch 640；tag=530；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 44 fat（nest>43 soft 下一层）** ✅ @ **`19befd5bc`**

  - 闸：`tests/boundary/nested_slice44.x` 44／`nested_named44.x` 54（`type_to_c_repr` scratch 640；tag=542；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 45 fat（nest>44 soft 下一层）** ✅ @ **`e55156ff3`**

  - 闸：`tests/boundary/nested_slice45.x` 45／`nested_named45.x` 55（`type_to_c_repr` scratch 640；tag=554；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 46 fat（nest>45 soft 下一层）** ✅ @ **`5b1f3084d`**

  - 闸：`tests/boundary/nested_slice46.x` 46／`nested_named46.x` 56（`type_to_c_repr` scratch 640；tag=566；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 47 fat（nest>46 soft 下一层）** ✅ @ **`91c01e115`**

  - 闸：`tests/boundary/nested_slice47.x` 47／`nested_named47.x` 57（`type_to_c_repr` scratch 640；tag=578；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 48 fat（nest>47 soft 下一层）** ✅ @ **`7b6028009`**

  - 闸：`tests/boundary/nested_slice48.x` 48／`nested_named48.x` 58（`type_to_c_repr` scratch 640；tag=590；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 49 fat（nest>48 soft 下一层）** ✅ @ **`1cc8405f4`**

  - 闸：`tests/boundary/nested_slice49.x` 49／`nested_named49.x` 59（`type_to_c_repr` scratch 640；tag=602；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 50 fat（nest>49 soft 下一层）** ✅ @ **`fb2e8b2d7`**

  - 闸：`tests/boundary/nested_slice50.x` 50／`nested_named50.x` 60（`type_to_c_repr` scratch 640；tag=614；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 51 fat（nest>50 soft 下一层）** ✅ @ **`6576958cc`**

  - 闸：`tests/boundary/nested_slice51.x` 51／`nested_named51.x` 61（`type_to_c_repr` scratch 640；tag=626；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 52 fat（nest>51 soft 下一层）** ✅ @ **`14ed3d469`**

  - 闸：`tests/boundary/nested_slice52.x` 52／`nested_named52.x` 62（`type_to_c_repr` scratch 640；tag=638；0..255，nest×10+10 会绕 8-bit）

✅ **host-C nest 64 fat 冻帽（nest>52 一叶跳到 64）** ✅ @ **`ac8948541`**

  - 现场：用户点名测到 64（52 不上不下）。nest 53 tag=650 溢 640；nest 63 tag=770 溢 768；nest 64 tag=782
  - **根修（G.7 有则补全）**：同一 emitter／companion／`emit_header`：墙 52→64；第三十九闸 `XLANG_SLICE_LAYOUTS_N64` 一次发 53..64；scratch 640→896
  - 闸：`tests/boundary/nested_slice64.x` 64／`nested_named64.x` 74（`type_to_c_repr` scratch 896；tag=782；0..255，nest×10+10 会绕 8-bit）
  - **冻帽 64**：勿再一叶一层；邻域 17–52 仍回归
  - 余：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **VAR assign >16B CALL sret（MEMORY dest-across-call）** ✅ @ **`34fdd01d7`**

  - 现场：`y = id32(x)`／`id24` Darwin SIGBUS 138。`let y = id32(x)` 已 0（lea dest→x8 再 CALL）。assign 走 CALL 再 `memcpy(y,*rax)`，未装 AAPCS64 x8／SysV rdi sret
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_assign_elf_c` VAR 在 TYPE_ARRAY／VECTOR 已复用 let-init，TYPE_NAMED 跌进 emit rhs＋`store_retval_pair` memcpy。权威已是 `glue_emit_struct_type_let_init_elf_c`（>16B lea slot→x8／rdi 再 CALL）。VAR 补同一 sibling（`ltk_pre==8`）。**禁**第二条 memcpy／x19 序言／try_inline／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 证：mac `struct_mem_assign_call`／xlang-c **0**（反汇编 `lea y; mov x8,x0; bl _id32` 无 caller memcpy）· s16／vam／vama／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_assign_call`／xlang-c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1615616）· **日常 L2 不升钉**
  - 余（已闭 VAR copy >16B）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **VAR copy >16B（slot-to-slot memcpy）** ✅ @ **`ea369e2c9`**

  - 现场：`y = x`／`let y = x` 32B／24B Darwin 2（只写了 y.a）。16B VAR copy 已绿（dual-GP）。host-C 已 0。反汇编 `ldr x0,[x]; str x0,[y]` 无 memcpy
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_struct_type_let_init` 只认 STRUCT_LIT／CALL／METHOD，VAR 返 -2，fall-through 只存 rax。权威已是 `glue_copy_large_struct_from_rax_ptr`（CALL／INDEX `*rax`→slot）。VAR 补 `lea src` 再同一 memcpy。**禁**扩 `store_retval_pair` 的 CALL／METHOD／INDEX 闸（VAR `emit_expr` 是值不是指针）；**禁**第二条 memcpy／x19／try_inline／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 证：mac `struct_mem_copy`／xlang-c **0**（反汇编 `lea x; mov x2,#32; lea y; bl memcpy`）· smac／s16／vam／vama／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_copy`／xlang-c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1616160）· **日常 L2 不升钉**
  - 余（已闭 FIELD dest TYPE_NAMED let-init reuse field_off==0）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19；FIELD dest field_off≠0；嵌套 sret

✅ **FIELD dest TYPE_NAMED let-init reuse（field_off==0）** ✅ @ **`4b2ee745e`**／typed 极性 **`006117bef`**／闸收口 **`7557ce640`**

  - 现场：`h.s = x`／`h.s = id16(x)` Darwin 2；`h.s = id32(x)` Darwin SIGBUS 138。VAR 槽 assign／copy 已绿。host-C 已 0。反汇编旧路径 `store_rax_to_rbx_offset` 只写 rax
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_assign_elf_c` FIELD 本地 VAR 基。权威已是 `glue_emit_struct_type_let_init`（dest＝`var_off+typed layout off`）。16B VAR −2 再 `store_retval_pair`。**禁**第二条 memcpy／x19／try_inline／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/struct_mem_field_assign.x` 期望 0（16B copy／CALL · 24B copy · 32B copy／CALL · STRUCT_LIT；**field_off==0**）
  - 证：mac `struct_mem_field_assign`／xlang-c **0**（反汇编 `lea dest; mov x8; bl _id32`）· smc／smac／s16／vam／vama／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_field_assign`／ALLOW c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1617160）· **日常 L2 不升钉**
  - 余（已闭嵌套 MEMORY sret dest 保存／恢复）：见下；另层：FIELD dest field_off≠0（x86 `effective_offset` stored −8，`Prefixed.s` dest=start−8）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **嵌套 MEMORY sret dest 保存／恢复** ✅ @ **`5f11667aa`**

  - 现场：`y = id32(id32(x))`／`let y = id32(id32(x))` Darwin RUN 1（y 全 0）。单层 `y = id32(x)` 已 0。16B 嵌套 dual-GP 已 0。反汇编外层 `lea y→x8` 后内层 `lea temp→x8`，外层 `bl` 仍写 temp
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_store_memory_by_value_to_sp`／`pipeline_asm_push_sysv_memory_by_value` 嵌套 CALL 枝装内层 dest 盖掉外层 x8／rdi。权威已是同一 MEMORY-by-value 物化。补 8B 槽保存／恢复 incoming dest（ARM64 `mov x8,x0`＋store；SysV `mov rdi,rax`＋store）。递归安全。**禁** x19／try_inline／nest 21／field_off≠0
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪（stub）。**禁**全量 assemble
  - 闸：`tests/boundary/struct_mem_nested_sret.x` 期望 0（24B 嵌套 · 32B assign／let · 32B 三层）
  - 证：mac `struct_mem_nested_sret`／xlang-c **0**（反汇编 `mov x8,x0` 保存再恢复）· smfa／smac／smc／s16／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_nested_sret`／ALLOW c **0** · 邻域同上＋n19 **90** · Prefixed leftover **20**（另层）· 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1617680）· **日常 L2 不升钉**
  - 余（已闭 FIELD dest field_off≠0 frame-mag）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **FIELD dest field_off≠0 frame-mag** ✅ @ **`364400973`**

  - 现场：`Prefixed { tag, s }` `h.s = q` Ubuntu 20（tag 被盖）。Darwin 已 0。反汇编 `lea -0x80`＝start−8，memcpy 32B 写到 tag。typed layout 已是 +8，不是 stored −8 查找失败
  - **根修（G.7 有则补全）**：产生点＝FIELD dest `off = var_off + field_off`（仅 ARM64 低端）。x86 高端 home 是正 magnitude：`0x78+8=0x80` → `lea -0x80`。权威已是 `glue_struct_field_frame_mag_c`（FIELD-as-source／wave652：arm64 `base+foff`，x86 `base-foff`）。**禁** polarity-flip stored −8／x19／try_inline／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/struct_mem_field_assign.x` 期望 0（含 Prefixed copy／CALL）
  - 证：mac `struct_mem_field_assign`／xlang-c **0** · smns／smac／smc／s16／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_field_assign`／ALLOW c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1617728）· **日常 L2 不升钉**
  - 余（已闭 FIELD-chain dest 走 VAR 根 let-init）：见下；另层：指针／INDEX FIELD dest；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **FIELD-chain dest 走 VAR 根 let-init** ✅ @ **`892da2d63`**

  - 现场：`w.h.s = q` Darwin 2；`id32` SIGBUS 138；`id16` 2。一层 `h.s` 已绿。push/pop 只写 rax
  - **根修（G.7 有则补全）**：产生点＝FIELD dest 只认立即 VAR 基。权威已是 let-init＋`glue_struct_field_frame_mag_c`。沿 FIELD 链走到 VAR 根，逐级 fold mag，同一 let-init。指针／INDEX 根仍 push/pop。**禁**第二条 memcpy／x19／try_inline／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/struct_mem_field_chain_assign.x` 期望 0（16B CALL · 32B copy／CALL · Prefixed 链）
  - 证：mac `struct_mem_field_chain_assign`／xlang-c **0** · smfa／smns／smac／smc／s16／da／fs16／n20／nslvar **0／0／0／0／0／0／42／100／78** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_field_chain_assign`／ALLOW c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1618264）· **日常 L2 不升钉**
  - 余（已闭指针／INDEX FIELD dest dest-in-rbx let-init）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **指针／INDEX FIELD dest dest-in-rbx let-init** ✅ @ **`0191b041f`**

  - 现场：`p.s = q`／`id32`／`id16` Darwin 139（VAR 根 mag 把 `*T` 当槽）；`arr[0].s` 2／138／2（push/pop 只写 rax）。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_assign_elf_c` FIELD 只对 TYPE_NAMED VAR 做 frame-mag。`*T` 根／中链 `*T` 闸 mag；`chain_n==1` 亦须 hit。权威已是 let-init。指针／INDEX TYPE_NAMED dest＝`lvalue` 后 `glue_emit_struct_type_let_init` DEST_IN_RBX=−3：>16B CALL dest→x8／rdi；16B dual-GP x19／rbx；VAR memcpy dest-in-rbx。**禁** nest 21／try_inline／x19 序言
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/struct_mem_ptr_index_field_assign.x` 期望 0（指针 16B CALL／32B copy／CALL／Prefixed／中链 `w.p.s` · INDEX 16B CALL／32B copy／CALL）
  - 证：mac `struct_mem_ptr_index_field_assign`／xlang-c **0** · smfca／smfa／smns／smac／smc／s16／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_ptr_index_field_assign`／ALLOW c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1620904）· **日常 L2 不升钉**
  - 余（已闭 INDEX dest 16B CALL dest-in-rbx let-init）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **INDEX dest 16B CALL dest-in-rbx let-init** ✅ @ **`e6ee90f8d`**

  - 现场：`arr[0] = id16(x)` Darwin 3（`.b` leftover）；dump=1（a=1 b=0）；`xs[0] = id16(x)` 3。32B INDEX CALL／16B INDEX copy 已 0。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝INDEX assign bulk CALL `glue_emit_struct_type_let_init(..., let_ty_ref=0)` → `store_retval_pair` 只写 rax。权威已是 dest-in-rbx let-init。TYPE_NAMED INDEX dest＝scaled lea 后同一 DEST_IN_RBX=−3：16B CALL dual-GP；>16B CALL dest→x8／rdi；16B VAR 仍 −2 走 bulk。**禁** nest 21／try_inline／x19 序言
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/struct_mem_index_assign.x` 期望 0（16B CALL／copy · slice 16B CALL · 32B CALL）
  - 证：mac `struct_mem_index_assign`／xlang-c／ALLOW c **0** · dump **201** · smpifa／smfca／smfa／smns／smac／smc／s16／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_index_assign`／ALLOW c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1621712）· **日常 L2 不升钉**
  - 余（已闭 DEREF dest TYPE_NAMED dest-in-rbx let-init）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **DEREF dest TYPE_NAMED dest-in-rbx let-init** ✅ @ **`27dc92146`**

  - 现场：`unsafe { *p = src }`／`id16`／`id32`／`id24`／`id32(id32)`／STRUCT_LIT Darwin 2／2／138／138／138／1（16B leftover／>16B SIGBUS）。裸 `*p =` 无 unsafe 会把整函数 parse 丢掉（非本叶）。host-C 已 0。标量 `*p = 42` 已 42
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_assign_elf_c` DEREF 只 `store_rax_to_rbx_indirect`。权威已是 dest-in-rbx let-init。TYPE_NAMED DEREF dest＝lvalue 后同一 DEST_IN_RBX=−3。dest-in-rbx VAR 9–16B 走 `glue_copy`（`deref_struct16` 会盖 dest／x19）。标量仍 store_rax。**禁** nest 21／try_inline／x19 序言
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/struct_mem_deref_assign.x` 期望 0（16B CALL／copy · 24B CALL · 32B CALL／copy／嵌套／STRUCT_LIT）
  - 证：mac `struct_mem_deref_assign`／xlang-c／ALLOW c **0** · smia／smpifa／smfca／smfa／smns／smac／smc／s16／da／fs16／n20／nslvar／imw／is12／sel4 **0／0／0／0／0／0／0／0／0／42／100／78／0／8／0** · 矩阵 **5/5** · Ubuntu 金标 `struct_mem_deref_assign`／ALLOW c **0** · 邻域同上＋n19 **90** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer thin+rest 1622608）· **日常 L2 不升钉**
  - 余（已闭 DEREF dest SLICE／ARRAY／VECTOR／DEREF rvalue／VECTOR CALL dest）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **DEREF dest SLICE／ARRAY／VECTOR dest-in-rbx** ✅ @ **`457a58c7b`**／x86 SLICE CALL rax+rdx @ **`8696f5916`**

  - 现场：`*p=s`／`take`／`[2]i32`／`i32x4` VAR Darwin 1／1／2／2。host-C 已 0
  - **根修（G.7 有则补全）**：DEREF dest 扩到 SLICE=11／VECTOR=13／ARRAY=10；VAR glue_copy dest-in-rbx；ARRAY CALL E*；x86 SLICE CALL 存 rax+rdx。**禁** nest 21／try_inline／x19 序言
  - 闸：`tests/boundary/struct_mem_deref_agg_assign.x` 期望 0
  - 证：双端 smdaa／ALLOW c **0** · 矩阵 **5/5** · **日常 L2 不升钉**

✅ **DEREF rvalue `y=*p` deref_struct16／>16B memcpy** ✅ @ **`a2948244b`**

  - 现场：`y=*p` 16B／let／32B／SLICE Darwin 2／2／2／1。host-C 已 0
  - **根修（G.7 有则补全）**：`pipeline_asm_emit_deref_elf_c` 9–16B／SLICE 走 deref_struct16；>16B 留指针＋let-init memcpy
  - 闸：`tests/boundary/struct_mem_deref_rvalue.x` 期望 0
  - 证：双端 smdrv／ALLOW c **0** · 矩阵 **5/5** · **日常 L2 不升钉**

✅ **VECTOR CALL dest dest-in-rbx let-init＋x86 高位 home** ✅ @ **`5e4f282cf`**／**`97548e68d`**

  - 现场：`*p=add4(a,b)` Darwin 2（callee 只 lane0）；VAR `d=add4` 已 0。let-init temp 后 Ubuntu 139：increment-after dest 盖 `q`，temp lane2 盖 dest，`memcpy(33)` SIGSEGV
  - **根修（G.7 有则补全）**：dest-in-rbx 复用 `glue_emit_vector_type_let_init` 到 temp 再 memcpy。槽分配同 `asm_local_slot_reg_offset`：ARM64 `home=cur`，x86 `home=cur+sz`。**禁** x19 序言／try_inline／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/vec_add4_deref_assign.x` 期望 0（add4＋sub4 dest-in-rbx CALL）
  - 证：双端 vada／xlang-c／ALLOW c **0** · 反汇编 dest `-0x70`／temp `-0x80` · vam／vama／smdaa／smdrv／smda／smia／smpifa／smfa／da／s16／sel4／fs16／n20／nslvar **0／0／0／0／0／0／0／0／0／0／0／42／100／78** · 矩阵 **5/5**（try_inline 仍 seed 57672；pipeline_abi prefer Darwin 1371680／Ubuntu 1626296）· **日常 L2 不升钉**
  - 余（已闭 SIMD named size_simple＝lanes*esz）：见下；另层：FIELD／INDEX dest VECTOR CALL；嵌套 `idv(add4)`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **SIMD named `size_simple`＝lanes*esz（idv 16B dual-GP）** ✅ @ **`b76bb2466`**

  - 现场：`let c = idv(a)` Darwin 13（`c[2]` leftover）。callee 只 `str x0`／`ret x0`。host-C 已 0。`add4(a,b)` 内联已 0
  - **根修（G.7 有则补全）**：产生点＝`glue_type_size_simple` TYPE_NAMED 无 layout 回 4。formal／return／call-arg／retval 当 1 GP。权威已是 `glue_vector_type_lanes_esz_c`。miss 路径复用 lanes*esz（16B dual-GP／32B sret）。**禁** i32x4 名表／try_inline／x19 序言／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/vec_id_call.x` 期望 0（idv 四 lane）
  - 证：双端 vic／xlang-c／ALLOW c **0** · wrap_add／id8 **0** · vam／vama／vada／smdaa／smdrv／smda／smia／smpifa／smfa／da／s16／sel4／fs16／n20／nslvar **0／0／0／0／0／0／0／0／0／0／0／0／42／100／78** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1371888／Ubuntu 1626528）· **日常 L2 不升钉**
  - 余（已闭 FIELD dest VECTOR CALL）：见下；另层：INDEX dest VECTOR CALL（Darwin 139）；嵌套 `idv(add4)`（Darwin 20）；FIELD-as-receiver `h.v.sub4`（Darwin 22）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **FIELD dest VECTOR CALL let-init** ✅ @ **`4c4c82411`**

  - 现场：`h.v = add4(a,b)` Darwin 20（lane1 leftover）。copy `h.v = a` 已 0。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝FIELD dest frame-mag 后只走 TYPE_NAMED struct let-init／16B dual-GP store of a real CALL。callee 只 `add w0`。权威已是 `glue_emit_vector_type_let_init`（VAR assign sibling）。frame-mag dest 复用同一 let-init。**禁** dest-in-rbx lea rbp−3／try_inline／x19 序言／nest 21／FIELD-as-receiver
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/vec_add4_field_assign.x` 期望 0（copy／CALL／METHOD VAR receiver 四 lane）
  - 证：双端 vafa／xlang-c／ALLOW c **0** · vam／vama／vada／vic／smfa／smfca／s16 **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1371976／Ubuntu 1626664）· **日常 L2 不升钉**
  - 余（已闭 ARRAY_LIT SIMD VAR）：见下；另层：INDEX dest VECTOR CALL（Darwin 139）；嵌套 `arr[0][0]`（Darwin 139）；嵌套 `idv(add4)`（Darwin 20）；FIELD-as-receiver `h.v.sub4`（Darwin 22）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **ARRAY_LIT SIMD VAR let-init** ✅ @ **`7ed90f9e7`**

  - 现场：`let arr:[2]i32x4 = [z, z]` Darwin 139（ctor 无读亦 139）。`arr[0]=add4` 探针的 139 是 ctor，不是 INDEX dest。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_vector_let_init`／`emit_array_lit_force_esz` SIMD VAR 元走 scalar `emit_expr`。16B VAR dual-GP 冲 dest-in-x1，`str [x1]` 写 NULL。权威已是 `glue_emit_vector_type_let_init`（FIELD dest VECTOR CALL sibling）。真实 frame home 复用同一 let-init。**禁** dest-in-rbx／try_inline／x19 序言／nest 21／INDEX dest
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/vec_array_lit_var.x` 期望 0（`[z,z]`／`[1]i32x4=[a]`／`[a,b]` 的 `arr[0]` 四 lane；不 INDEX `arr[1]`／不嵌套 `arr[0][0]`）
  - 证：双端 valv／xlang-c／ALLOW c **0** · vafa／vic／vada／vama／s16／smfa／sel4 **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1372328／Ubuntu 1627000）· **日常 L2 不升钉**
  - 余（勿并本叶）：INDEX dest VECTOR CALL（已闭）；嵌套 `arr[0][0]`（Darwin 174）；嵌套 `idv(add4)`（Darwin 20）；FIELD-as-receiver `h.v.sub4`（Darwin 22）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **INDEX dest VECTOR CALL let-init** ✅ @ **`6141c91e2`**

  - 现场：ctor `[z,z]` 已绿后 `arr[0] = add4(a,b)`／`a.add4(b)` Darwin **2**（lane1 leftover）。copy `arr[0] = a` 已 0。host-C 已 0。先前 Darwin 139 是 ctor，不是 dest
  - **根修（G.7 有则补全）**：产生点＝INDEX dest dest-in-rbx + struct let-init −2 后真 CALL。callee 只 `add w0`。权威已是 `glue_emit_vector_type_let_init`（FIELD dest VECTOR CALL sibling）。VAR+lit 真实 frame dest 复用同一 let-init。**禁** dest-in-rbx −3（lea rbp−3）／try_inline／x19 序言／nest 21／slice dest／嵌套 `arr[0][0]`
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest＋seed 冷孪。**禁**全量 assemble
  - 闸：`tests/boundary/vec_add4_index_assign.x` 期望 0（copy／CALL／METHOD VAR+lit `arr[0]` 四 lane；不 INDEX `arr[1]`／不嵌套 `arr[0][0]`／不 slice dest）
  - 证：双端 vaia／xlang-c／ALLOW c **0** · valv／vafa／vic／vada／vama／s16／smfa／sel4 **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1373032／Ubuntu 1627864）· **日常 L2 不升钉**
  - 余（勿并本叶）：嵌套 `arr[0][0]`（已闭）；嵌套 `idv(add4)`（Darwin 20）；FIELD-as-receiver `h.v.sub4`（Darwin 22）；第二份 SIMD ARRAY_LIT 盖 dest（x86）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **嵌套 INDEX rvalue `arr[0][0]`** ✅ @ **`345a51463`**

  - 现场：`return arr[0][0]` Darwin **174**。`let t=arr[0]; t[0]`／`a[0]` 已 1。host-C 已 1。ctor `[1]i32x4=[a]; arr[0][0]` 同 174
  - **根修（G.7 有则补全）**：产生点＝`glue_try_index_var_or_field_base_to_rax` 不认 INDEX 基，emit_expr rvalue deref_struct16，rax 是 packed lanes。外层当指针 load。权威已是 FIELD-over-INDEX 的 scaled lea。INDEX=47 复用同一 lea（不 load）。rbx 孪复用 rax helper（push/pop）。**禁** dest-in-rbx／try_inline／x19 序言／nest 21／嵌套 `idv(add4)`
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest（seed stub 仍 −2，pure leave）。**禁**全量 assemble
  - 闸：`tests/boundary/vec_index_nested.x` 期望 0（dest＋`arr[0][0..3]`＋`a[0]`＋split `let t`；不并第二份 `[1]i32x4` — Ubuntu 盖 dest leftover）
  - 证：双端 vin／xlang-c／ALLOW c **0** · vaia／valv／vafa／vic **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1373272／Ubuntu 1628200）· **日常 L2 不升钉**
  - 余（勿并本叶）：嵌套 `idv(add4)`（已闭）；FIELD-as-receiver `h.v.sub4`；`return idv(add4)[i]` emit_expr；第二份 SIMD ARRAY_LIT 盖 dest（x86 `t[0]=3`）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **嵌套 identity CALL `idv(add4)` let-init** ✅ @ **`24d7d4b2a`**

  - 现场：`let c = idv(add4(a,b))` Darwin **2**（lane1 leftover）。拆开 `let t=add4; let c=idv(t)` 已 0。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝vector let-init 的 CALL 链只 inliner splat／select／shuffle／fma3／binop2。idv 是 1 参 `return p0`，binop2 不认，落到真 CALL；内层 add4 真 CALL 只 lane0。权威已是 `glue_emit_vector_type_let_init`。补 `glue_fold_func_returns_param0`＋`try_inline_identity_call` 剥 identity，对 arg0 再 let-init（add4 走 binop2）。**禁** FIELD-as-receiver／return `idv(add4)[i]`／try_inline mega／x19 序言／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_idv_add4_nested.x` 期望 0（嵌套 let＋拆开 let 四 lane）
  - 证：双端 via／xlang-c／ALLOW c **0** · vin／vaia／valv／vafa／vic **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1374600／Ubuntu 1629752）· **日常 L2 不升钉**
  - 余（勿并本叶）：FIELD-as-receiver `h.v.sub4`（已闭）；`return idv(add4)[i]` emit_expr；第二份 SIMD ARRAY_LIT 盖 dest（x86）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **FIELD-as-receiver `h.v.sub4` lane stack-off** ✅ @ **`617b1f739`**

  - 现场：`h.v = h.v.add4(b)` Darwin **22**（lane1 leftover）。拆开 `let t=h.v; t=t.add4(b)` 已 0。host-C 已 0。FIELD dest VAR 接收者已闭
  - **根修（G.7 有则补全）**：产生点＝`glue_vector_var_lane_stack_off` `ko!=3` 直接 −1，binop2 落到真 CALL，callee 只 lane0。权威已是同一 lane stack-off。depth-1 FIELD（VAR 基、非 *T／enum／chain）折 `glue_struct_field_frame_mag_c` 再走原 lane 极性。operand lane load 复用该 off。**禁** FIELD-chain／return `idv(add4)[i]`／try_inline mega／x19 序言／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_add4_field_recv.x` 期望 0（METHOD add／sub＋CALL `add4(h.v,b)` 四 lane）
  - 证：双端 vafr／xlang-c／ALLOW c **0** · vafa／via／vin／vaia／valv／vama／vami／vic **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1375320／Ubuntu 1630560）· **日常 L2 不升钉**
  - 余（勿并本叶）：`return idv(add4)[i]` emit_expr（已闭）；第二份 SIMD ARRAY_LIT 盖 dest（x86）；FIELD-chain `w.h.v.sub4`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **`return idv(add4)[i]` emit_expr 走 vector let-init** ✅ @ **`66e6e848d`**

  - 现场：`return idv(add4(a,b))[1]` Darwin **0**（假绿；host-C **22**）。`return add4(a,b)[1]` 同 0。`let c=idv(add4); return c[1]` 已 22
  - **根修（G.7 有则补全）**：产生点＝INDEX 基 SIMD CALL 走 `glue_emit_struct_type_let_init` 真 CALL，callee 只 lane0。权威已是 `glue_emit_vector_type_let_init`（identity 剥＋binop2）。INDEX 基 spill 先试 vector let-init，−2 再 struct。vector dest 写 dest+i*esz，与后续 lea+idx*esz 一致。**禁** FIELD-chain／第二份 ARRAY_LIT／try_inline mega／x19 序言／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_idv_add4_index.x` 期望 0（idv INDEX／add4 INDEX／return helper 四 lane）
  - 证：双端 vai／xlang-c／ALLOW c **0** · via／vafr／vafa／vin／vaia／valv／vama／vami／vic **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1375408／Ubuntu 1630680）· **日常 L2 不升钉**
  - 余（勿并本叶）：第二份 SIMD ARRAY_LIT 盖 dest（x86 `t[0]=3`）；FIELD-chain `w.h.v.sub4`（已闭）；prefixed SIMD dest（`tag+Holder`）；FIELD-chain SIMD INDEX `w.h.v[i]`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **FIELD-chain `w.h.v.sub4` lane stack-off** ✅ @ **`e6dd1a86b`**

  - 现场：`w.h.v = w.h.v.add4(b)` Darwin **22**（lane1 leftover）。拆开 `let t=w.h.v; t=t.add4(b)` 已 0。host-C 已 0。depth-1 `h.v.sub4` 已闭
  - **根修（G.7 有则补全）**：产生点＝`glue_vector_var_lane_stack_off` `base_ko!=3` 直接 −1，binop2 落到真 CALL，callee 只 lane0。权威已是同一 lane stack-off＋dest FIELD-chain mag walk。沿链（max 16）走到 value-VAR 根，折同一 `glue_struct_field_frame_mag_c`。let-init FIELD／链源复用 `vector_var_copy` 逐 lane（观察 `let t=w.h.v` 曾 8B struct 落）。**禁** prefixed SIMD dest／`w.h.v[i]` INDEX／try_inline mega／x19 序言／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_add4_field_chain.x` 期望 0（METHOD add／sub＋CALL `add4(w.h.v,b)` 四 lane；观察走 let-init 拷）
  - 证：双端 vafc／xlang-c／ALLOW c **0** · vafr／vafa／vai／via／vin／vaia／valv／vama／vami／smfc **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1376096／Ubuntu 1631904）· **日常 L2 不升钉**
  - 余（勿并本叶）：第二份 SIMD ARRAY_LIT 盖 dest（已闭）；prefixed SIMD dest（`tag+Holder` field_off≠0）；FIELD-chain SIMD INDEX `w.h.v[i]`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **第二份 SIMD ARRAY_LIT 盖 dest（x86 `[N]i32x4` 槽位）** ✅ @ **`4b0fc890d`**

  - 现场：dest `arr[0]=a` 后再 `let one:[1]i32x4=[a]`，Ubuntu `t[0]=3`（a[2]）。Darwin ARM64 低端假绿。host-C 本绿
  - **根修（G.7 有则补全）**：产生点＝`pipe_local_slot_bytes_mod` TYPE_ARRAY 把 TYPE_NAMED 当 8B，`[2]i32x4`＝16、`[1]i32x4`＝8；16B 写从 8B 高位 home 盖 dest。权威已是 `glue_fixed_array_total_bytes_c`／`glue_type_size_simple`（lanes*esz）。槽位／temp／ARRAY_LIT fallback 同补。**禁** i32x4 名表／try_inline mega／x19 序言／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_array_lit_after_dest.x` 期望 0（dest＋第二份 ARRAY_LIT 四 lane＋`one[0]`）
  - 证：双端 vald／xlang-c／ALLOW c **0** · n2lit Ubuntu 3→0 · vin／valv／vaia／vafc／vafr／vai／via／vama／vami **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1376616／Ubuntu 1632536）· **日常 L2 不升钉**
  - 余（勿并本叶）：prefixed SIMD dest（`tag+Holder` field_off≠0）（已闭）；FIELD-chain SIMD INDEX `w.h.v[i]`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **prefixed SIMD dest（`tag+Holder` field_off≠0）** ✅ @ **`149df550f`**

  - 现场：`Prefixed { tag: 7, v: z }` Darwin tag=1／exit 70。retag 后再 dest 已 0。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝`glue_type_align_simple` TYPE_NAMED SIMD miss 回 4，compute 把 v 排在 +4；16B dest-in-x19 store `offset/8=0` 盖 tag。权威已是 `glue_type_size_simple` lanes*esz。align miss／store_sz 9–16／STRUCT_LIT SIMD 场复用 vector let-init 同补。**禁** i32x4 名表／try_inline mega／x19 序言／nest 21／`w.h.v[i]`
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_prefixed_simd_dest.x` 期望 0（STRUCT_LIT tag＋四 lane＋dest copy／CALL／METHOD＋`tag+Holder` dest）
  - 证：双端 vpsd／xlang-c／ALLOW c **0** · tagonly Darwin 1→7 · vald／vafc／vafr／vai／via／vin／vaia／valv／vama／vami／smfa **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1376928／Ubuntu 1632872）· **日常 L2 不升钉**
  - 余（勿并本叶）：FIELD-chain SIMD INDEX `w.h.v[i]`（已闭）；dest `w.h.v[i]=`；typeck T001 `return`／`let` INDEX；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **FIELD-chain SIMD INDEX `w.h.v[i]`** ✅ @ **`b69a33a51`**

  - 现场：`if (w.h.v[0] != 1)` Darwin **10**／dump2 **99**（垃圾；非 138）。`let t: i32x4 = w.h.v; t[i]` 已 0。depth-1 `h.v[i]` 已 0。host-C 已 0。`return w.h.v[1]`／`let x: i32 = w.h.v[0]` typeck T001（subscript base）未折
  - **根修（G.7 有则补全）**：产生点＝`glue_try_index_var_or_field_base_to_rax` FIELD 只认 VAR／DEREF／INDEX 基，`base_ko==44` 落到 call_fa（只认 CALL／METHOD／STRUCT_LIT 根）→ −2 → emit_expr rvalue 把 packed lanes 当指针。权威已是 `pipeline_asm_emit_lvalue_eff_addr` 走链 lea＋field_off。rbx 孪复用 rax helper。**禁** typeck T001／dest `w.h.v[i]=`／try_inline mega／x19 序言／nest 21
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_field_chain_index.x` 期望 0（`if (w.h.v[i] != …)` 四 lane；不 `return`／`let` INDEX）
  - 证：双端 vfci／xlang-c／ALLOW c **0** · nchain_idx Darwin 10→0 · dump2 99→1 · vafc／vafr／vpsd／vald／vai／via／vin／vaia／valv／vama／vafa **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1377304／Ubuntu 1633352）· **日常 L2 不升钉**
  - 余（勿并本叶）：dest `w.h.v[i]=`（已绿，rvalue 叶带过）；typeck T001 `return`／`let` INDEX（已闭）；Holder 拷 `let h=w.h`（已闭）；STRUCT_LIT `Wrap { h: inner }` ARM64 16B（已闭）；dest-in-rbx FIELD 源；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **dest `w.h.v[i]=`** ✅（rvalue 叶 `b69a33a51` 带过；本叶闸 @ **`dbe877df1`**）

  - 现场：dest 全 lane／depth-1／ptr／prefixed／nest `arr[0][2]=`／var idx／CALL rhs Darwin 已 0。host-C 已 0。emit 走同一 try_index rbx 孪，无新产生点
  - 闸：`tests/boundary/vec_field_index_return.x` dest 段期望 0
  - 余（勿并本叶）：typeck T001（已闭）；Holder 拷 `let h=w.h`（已闭）；STRUCT_LIT `Wrap { h: inner }`（已闭）；dest-in-rbx FIELD 源；nest>20；sat／x19 序言

✅ **typeck 不盖 SIMD FIELD ambient** ✅ @ **`dbe877df1`**

  - 现场：`return h.v[1]`／`let x: i32 = w.h.v[1]` T001（subscript base）。`return a[1]`／`if (w.h.v[i])`／dest 已 0。`return h.v` 假绿 RUN=1（lane0）
  - **根修（G.7 有则补全）**：产生点＝`typeck_field_apply_ambient_for_type_param` 把 i32x4 当自由 T（`named_is_module_concrete` 只走 struct／enum 表）。权威已是 `typeck_vector_lanes_of_type`。lanes>0 不盖 ambient。**禁**放宽 typeck 闸／try_inline／x19／nest 21
  - 权威 `typeck.x` assemble → `typeck_x.o`。**禁**改 pin `typeck_gen.linux.x86_64.c`
  - 闸：`tests/boundary/vec_field_index_return.x` 期望 0（dest＋`return w.h.v[i]`＋`let x = w.h.v[i]` 四 lane）
  - 证：双端 vfir／xlang-c／ALLOW c **0** · nret_depth1 2 · `return h.v` 现 T001 错配 · vfci／vafc／vafr／vpsd／vald／vai／via／vin／vaia／valv／vama／vafa **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1377304／Ubuntu 1633352；typeck_x Darwin 317120／Ubuntu 384232）· **日常 L2 不升钉**
  - 余（勿并本叶）：Holder 拷 `let h=w.h`（已闭）；STRUCT_LIT `Wrap { h: inner }` ARM64 16B（已闭）；dest-in-rbx FIELD 源；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **Holder 拷 `let h=w.h`** ✅ @ **`d1a80c50a`**

  - 现场：dest 后 `let h: Holder = w.h`／`h = w.h` 双端 0。VAR `let h2 = h` 已 0。`take(w.h)` 16B 实参已 0。`let t: i32x4 = w.h.v` 已 0。STRUCT_LIT `Wrap { h: inner }` 双端 0（ARM64 dual-GP 16B field store 已闭 @ **`7ddacf3a3`**）
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_struct_type_let_init` 只认 VAR／DEREF，FIELD 落到 emit_expr 只装 8B。权威已是同一 let-init。FIELD 9–16B frame：lvalue lea＋deref_struct16＋store_retval_pair（memcpy 拒 frame ≤16）。>16B frame 走 VAR memcpy 孪。dest-in-rbx FIELD 仍 −2（lvalue／deref 盖 dest／x19）。**禁**改 emit_expr FIELD／try_inline／x19／nest 21／STRUCT_LIT 16B ARM64 store
  - 权威 `runtime_pipeline_abi.x` prefer thin+rest。**禁**全量 assemble
  - 闸：`tests/boundary/vec_field_index_return.x` 期望 0（dest＋return／let INDEX＋`let h=w.h`＋assign＋`ret_depth1` 四 lane）
  - 证：双端 vfir／xlang-c **0** · nhold_afterdest／asg_dest Darwin 30→0 · vfci／vpsd／vald／vafc／vafr／vai／via／vin／vaia／valv／vama／vada **0** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1377848／Ubuntu 1633936）· **日常 L2 不升钉**
  - 余（勿并本叶）：dest-in-rbx FIELD 源（已闭）；ARRAY_LIT 16B named VAR（已闭）；INDEX 基 FIELD dest-in-rbx（已闭）；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **dest-in-rbx FIELD 源 `*p = w.h`** ✅ @ **`ed9855203`**

  - 现场：`unsafe { *p = w.h }` Darwin 30（`dst.v[2]` leftover）。FIELD-on-VAR lvalue 只动 rax。Ubuntu x86 rbx callee-saved 常假绿
  - **根修（G.7 有则补全）**：产生点＝dest-in-rbx FIELD 返 −2，emit_expr 只装 8B。权威已是同一 let-init。FIELD-on-VAR lvalue lea 后 glue_copy dest-in-rbx。**禁** deref_struct16（盖 dest／x19）／改 FIELD emit_expr／降 frame dest ≤16 memcpy
  - 闸：`tests/boundary/vec_field_index_return.x` dest-in-rbx 段 16／26／36／46
  - 证：双端 vfir／xlang-c／nhold_ptr_field **0** · 矩阵 **5/5** · **日常 L2 不升钉**

✅ **ARRAY_LIT 16B named VAR `[w]`** ✅ @ **`b7b46ae27`**

  - 现场：`[w]`／`[inner]` Darwin 139。VAR 9–16B frame dest 返 −2，emit_expr dual-GP 冲 dest-in-x1，store 打 NULL
  - **根修（G.7 有则补全）**：权威已是同一 let-init FIELD 9–16B frame。VAR 9–16B frame：lea src＋deref_struct16＋store_retval_pair。8B dest-in-rbx 仍 memcpy。**禁**降 frame dest ≤16 memcpy／改 FIELD emit_expr／enc_store /8
  - 闸：`tests/boundary/vec_field_index_return.x` `[w]` 17／27／37／47 · `[h]` 18／28／38／48
  - 证：双端 vfir／xlang-c／nhold_arr_var_elem／nhold_hold_arr **0** · 矩阵 **5/5** · **日常 L2 不升钉**

✅ **INDEX 基 FIELD dest-in-rbx `*p = arr[i].h`** ✅ @ **`1c14db3e7`**

  - 现场：变址 `*p = arr[i].h` Ubuntu 139；字面量 `arr[0].h` 双端 0。Darwin x19 dest-shadow 假绿。var-index／slice lvalue 用 rbx
  - **根修（G.7 有则补全）**：权威已是 dest-in-rbx FIELD memcpy。复用 binop INDEX-clobber 检测＋VECTOR CALL dest 溢栈极性（ARM64 home=cur，x86 home=cur+8）。先停 dest 再停 src 址，恢复 dest 到 rbx，再 glue_copy dest-in-rbx
  - 闸：`tests/boundary/vec_field_index_return.x` INDEX 基 19／29／39／49
  - 证：双端 vfir／xlang-c／nhold_idx_field2 Ubuntu 139→0 · 邻域绿 · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1378880／Ubuntu 1635264）· **日常 L2 不升钉**
  - 余（已闭 dest-in-rbx INDEX 整元素）：见下；另层：nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **dest-in-rbx INDEX 整元素 `*p = arr[i]`** ✅ @ **`b96a7f9bf`**

  - 现场：`unsafe { *p = arr[i] }`（`p: *Wrap`）Darwin **12**（`dst.h.v[2]` leftover）。`*p = arr[i].h`／`arr[0] = w`／`arr[i] = w` 已 0。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_struct_type_let_init` 只认 FIELD(44)，INDEX(47) 返 −2，emit_expr 只装 8B。权威已是同一 dest-in-rbx FIELD 路径。INDEX／INDEX 基 FIELD 共用 lvalue＋park dest（var-index 用 rbx）＋memcpy dest-in-rbx。frame dest 9–16B INDEX 复用 deref_struct16＋store_retval_pair
  - 闸：`tests/boundary/vec_field_index_return.x` dest-in-rbx INDEX 整元素 60／61／62／63
  - 证：双端 vfir／xlang-c／nhold_idx_ptr Darwin 12→0 · 邻域绿 · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1378896／Ubuntu 1635264）· **日常 L2 不升钉**
  - 余（已闭 dest-in-rbx DEREF 源）：见下；另层：STRUCT_LIT FIELD 源 `Wrap { h: w.h }`；dest-in-rbx ARRAY_LIT `*p = [w]`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **dest-in-rbx DEREF 源 `*p = *q`** ✅ @ **`97636e07d`**

  - 现场：`unsafe { *p = *q }`（16B Holder／Wrap）Darwin **30**（`dst.v[2]` leftover）。`*p = w.h`／`*p = arr[i]`／`*p = (*q).h`／frame dest `y = *p` 已 0。host-C 已 0
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_struct_type_let_init` DEREF(52) 9–16B 返 −2，emit_deref dual-GP 后 dest 再 lea 盖 hi。权威已是同一 dest-in-rbx FIELD／INDEX 路径。DEREF 并入 lvalue（操作数指针）＋park dest（DEREF-of-INDEX 用 rbx）＋memcpy dest-in-rbx。clobber 检测补 DEREF 走操作数。删独立 >16B DEREF 块（同路径已覆盖）
  - 闸：`tests/boundary/vec_field_index_return.x` dest-in-rbx DEREF 源 70／71／72／73
  - 证：双端 vfir／xlang-c／nhold_deref_src Darwin 30→0 · smda／smdrv **0** · 邻域绿 · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1378616／Ubuntu 1634952）· **日常 L2 不升钉**
  - 余（已闭 STRUCT_LIT FIELD 源）：见下；另层：dest-in-rbx ARRAY_LIT `*p = [w]`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **STRUCT_LIT FIELD 源 `Wrap { h: w.h }`** ✅ @ **`e7ad55d98`**

  - 现场：`let w2 = Wrap { h: w.h }` Darwin **30**（`w2.h.v[2]` leftover）。VAR 场 `Wrap { h: inner }` 已 0。dest-in-rbx `*p = Wrap { h: w.h }` 同产生点 Darwin 30
  - **根修（G.7 有则补全）**：产生点＝`pipeline_asm_emit_struct_lit_fields` 对 16B 场走 emit_expr；FIELD／INDEX emit_expr 只装 8B，dual-GP spill 的 hi 是垃圾。权威已是同一 `glue_emit_struct_type_let_init`（dest-in-rbx FIELD／INDEX／DEREF）。frame dest 写 nest_slot；sret／dest-in-rbx 写 frame temp 再 chunk-copy 到 dest+foff（嵌套 STRUCT_LIT sret 孪）。**禁**改 FIELD emit_expr／enc_store /8
  - 闸：`tests/boundary/vec_field_index_return.x` STRUCT_LIT FIELD 源 80／81／82／83；dest-in-rbx STRUCT_LIT 84／85／86／87
  - 证：双端 vfir／xlang-c／nhold_slit_field Darwin 30→0 · nhold_slit_ptr_field Darwin 30→0 · 邻域绿 · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1379624／Ubuntu 1635952）· **日常 L2 不升钉**
  - 余（已闭值位置只认 `{ fields }`）：见下；另层：dest-in-rbx ARRAY_LIT `*p = [w]`；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **值位置只认 `{ fields }`（禁 `Type { fields }`）** ✅ @ **`6c9773729`**

  - 现场：`let inner: Holder = Holder { v: a }` 冗余类型名，AI 双写。语言约定：类型只写在 dest
  - **根修（G.7 有则补全）**：产生点＝`typeck_check_expr_struct_lit` 值 STRUCT_LIT `name_len>0` 拒。call-arg 匿名补同一 `typeck_coerce_init_struct_lit_to_decl`（形参 dest）。match 模式 `{ fields } =>` 类型来自主语（`Type { fields } =>` 仍接受）。源树值位置改写成 `{ fields }`（**未**改 try_inline mega／**未** assemble parser）
  - 闸：`tests/boundary/struct_lit_anon_only.x` 期望 typeck 拒；`let x: T = { }`／`take({ })` 绿
  - 证：双端矩阵 **5/5** · vfir／msd／bare **0** · named 拒 `expected { fields }, found Point` · try_inline 仍 seed 72264／57672 · typeck_x Darwin 317352／Ubuntu 384664 · **日常 L2 不升钉**
  - 余（已闭 dest-in-rbx ARRAY_LIT）：见下；另层：nest>20；sat／x19 序言

✅ **dest-in-rbx ARRAY_LIT `*p = [w]`** ✅ @ **`2046f5a15`**

  - 现场：`unsafe { *p = [w] }`（`p: *[1]Wrap`）Darwin **10**（payload 指针当元素）。frame `[w]`／`*p = w`／`*p = { h: w.h }` 已 0
  - **根修（G.7 有则补全）**：产生点＝DEREF dest TYPE_ARRAY 走 `glue_emit_struct_type_let_init`（ARRAY_LIT → −2）再 `store_rax` 8B。权威已是同一 `glue_emit_fixed_array_type_let_init`。DEST_IN_RBX=-3：`[w]` 逐元素复用 dest-in-rbx struct let-init（`*p = w` 孪）。**禁** emit 时开 array temp（大 main 出红区 139）／lea rbp-3／改 enc_store /8
  - 闸：`tests/boundary/vec_field_index_return.x` dest-in-rbx ARRAY_LIT 90／91／92／93
  - 证：双端 vfir／xlang-c／nhold_arrlit_ptr Darwin 10→0 · smda／smdrv／da／vald **0** · fs16 **42** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1381000／Ubuntu 1637456）· **日常 L2 不升钉**
  - 余（已闭 dest-in-rbx ARRAY_LIT of FIELD）：见下；另层：匿名 match 模式；nest>20（21 须加宽 scratch）；TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；sat 盖 prefer；ARM64 prologue 未存 x19

✅ **dest-in-rbx ARRAY_LIT of FIELD `*p = [w.h]`** ✅ @ **`fb6ad71f4`**

  - 现场：`unsafe { *p = [w.h] }`（`p: *[1]Holder`）官方 vfir Darwin **96**（`dst[0].v[2]` leftover）。`*p = [w]`／`*p = w.h` 已 0。host-C 已 0。小 isolate 仍 12（与 `*p = w.h` 小文件同一类 Holder 尺寸）
  - **根修（G.7 有则补全）**：产生点＝dest-in-rbx ARRAY_LIT 逐元素 dest-in-rbx struct let-init 对 FIELD 返 −2（数组元类型 size&lt;9），再 emit_expr FIELD 8B + store 16 垃圾 hi。权威已是 dest-in-rbx FIELD memcpy。补 named_layout dest 宽；FIELD／INDEX／DEREF −2 回退走 lvalue + glue_copy dest-in-rbx esz。**禁** emit_expr 9B+ named 元／改 FIELD emit_expr／enc_store /8
  - 闸：`tests/boundary/vec_field_index_return.x` dest-in-rbx ARRAY_LIT of FIELD 94／95／96／97
  - 证：双端 vfir／xlang-c **0** · smd／smdrv／vald **0** · fs16 **42** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1381264／Ubuntu 1637688）· **日常 L2 不升钉**
  - 余（已闭 INDEX dest ARRAY_LIT）：见下；另层：dest-in-rbx ARRAY VAR；dest-in-rbx 嵌套 STRUCT_LIT；`return [w]`；匿名 match；nest>20；sat／x19 序言

✅ **INDEX dest ARRAY_LIT `rows[0] = [w]`** ✅ @ **`3e53921df`**

  - 现场：`rows[0] = [w]`（`rows: [1][1]Wrap`）isolate Darwin **10**（payload 指针）。官方大 `main()` 第一刀 dest-in-rbx after INDEX lea **139**；帧槽 let-init 掉进 `vector_let_init` 同样 139。host-C 已 0。`*p = [w]` 已 0
  - **根修（G.7 有则补全）**：产生点＝INDEX dest 只认 TYPE_NAMED／VECTOR／STRUCT_LIT，ARRAY_LIT 走 emit_expr 8B 指针。权威已是 dest-in-rbx ARRAY_LIT。从基剥 dest 类型（勿信 INDEX 盖外层 `[1][1]Wrap`），lea rbp dest，再 dest-in-rbx `glue_emit_fixed_array_type_let_init`。**禁** INDEX-lea dest-in-rbx 先手／vector_let_init −3／emit 时开 array temp／enc_store /8
  - 闸：`tests/boundary/vec_field_index_return.x` INDEX dest ARRAY_LIT 98／99／100／101
  - 证：双端 vfir／xlang-c **0** · smd／smdrv／vald **0** · fs16 **42** · 矩阵 **5/5**（try_inline 仍 seed 72264／57672；pipeline_abi prefer Darwin 1382104／Ubuntu 1638792）· **日常 L2 不升钉**
  - 余（已闭 dest-in-rbx ARRAY VAR／嵌套 STRUCT_LIT／大 main 后段 let dest 名空／匿名 match）：见下；另层：nest>20；sat／x19 序言

✅ **dest-in-rbx ARRAY VAR `*p = src`** ✅ @ **`25092c1c2`**

  - 闸：`tests/boundary/vec_field_index_return.x` dest-in-rbx ARRAY VAR 102／103／104／105

✅ **dest-in-rbx 嵌套 STRUCT_LIT `*p = { h: { v: a } }`** ✅ @ **`25092c1c2`**

  - 闸：`tests/boundary/vec_field_index_return.x` dest-in-rbx 嵌套 STRUCT_LIT 106／107／108／109（`dest_nest_slit` helper）

✅ **`return [w]`** ✅ @ **`cb045487e`**（isolate 已绿；本叶闸）

  - 闸：`tests/boundary/vec_field_index_return.x` `ret_arr` 110／111／112／113

✅ **ARRAY_LIT dest 嵌套 STRUCT_LIT `return [{ h: { v: a } }]`／`*p = [{ h: { v: a } }]`** ✅ @ **`cb045487e`**

  - 闸：`tests/boundary/vec_field_index_return.x` `ret_arr_nest` 114／115／116／117；`dest_arr_nest_slit` 118／119／120／121

✅ **runtime-index dest ARRAY_LIT `rows[i] = [w]`** ✅ @ **`0ae458c3f`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_rtidx_arrlit` 122／123／124／125

✅ **INDEX dest ARRAY_LIT 非 VAR 基 `rh.rows[0] = [w]`／`grid[0][i] = [w]`** ✅ @ **`b8a768624`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_novar_idx_arrlit` 126–141

✅ **FIELD dest ARRAY_LIT `bag.one = [w]`** ✅ @ **`edb84643d`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_field_arrlit` 142–145

✅ **dest-in-rbx ARRAY_LIT of ARRAY_LIT `*p = [[w]]`** ✅ @ **`0764d8517`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_arrlit2` 146–157（含 FIELD `rh.rows = [[w]]`／INDEX `grid[0] = [[w]]`）

✅ **dest-in-rbx ARRAY_LIT n>1 `*p = [w, w]`** ✅ @ **`59da19b88`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_arrlit_n2` 158–169（含 FIELD `bag.two = [w, w]`／INDEX `grid[0] = [w, w]`）

✅ **dest-in-rbx STRUCT_LIT 场 ARRAY_LIT `*p = { one: [w] }`** ✅ @ **`b57d4a558`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_slit_arrlit` 170–181（含 n>1 `{ two: [w, w] }`／ARRAY VAR `{ two: src }`／sret `return { two: [w, w] }`）

✅ **STRUCT_LIT 场 ARRAY_LIT 嵌套 STRUCT_LIT `{ one: [{ h: { v: a } }] }`** ✅ @ **`7cfc6e352`** · **pin-seed 双权威闭** 2026-08-17 @ **`b59d77fc3`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_slit_arrlit_nest` 182–197（含 n>1 `{ two: [{…},{…}] }`／frame dest `let bag: Bag = { one: [{…}] }`／sret `return { one: [{…}] }`）
  - **pin-seed 双权威闭**（2026-08-17）：typeck.x 匿名 dest backfill 后 field_inits 只进 assemble；pin 早 return → host-C `(struct )`。seed 补 `typeck_coerce_array_lit_struct_elems_to_decl`＋`coerce_init_struct_lit` nest＋field_inits 调用点＋`check_expr_struct_lit` 匿名 ensure／field_inits（≡ typeck.x）
  - 证：isolate nest／slit 双端 asm／host-C **0**；`{ h:{v:a} }` host-C `(struct Holder)`

✅ **dest-in-rbx CALL `*p = dest_mk_w(a)`／dest-in-rbx ARRAY_LIT of CALL `*p = [dest_mk_w(a)]`** ✅ @ **`ee0c5de29`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_arrlit_call` 198–217（含 n>1／FIELD dest／INDEX dest／frame dest／STRUCT_LIT 场 ARRAY_LIT of CALL）

✅ **dest-in-rbx IF `*p = if (c) { w } else { y }`** ✅ @ **`b12586f41`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 218–233（含 false arm／FIELD dest／CALL arm）

✅ **IF dest 双臂 STRUCT_LIT（帧 dest `let r = if (c) { { h: { v: a } } } else { { h: { v: b } } }`）** ✅ @ **`37f873c8e`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 234–237

✅ **dest-in-rbx IF of STRUCT_LIT `*p = if (c) { { h: { v: a } } } else { y }`** ✅ @ **`e3f3f3d5f`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 238–249（含双臂 STRUCT_LIT／false arm STRUCT_LIT）

✅ **大 main 后段 let dest 名空**

  - 闸：`tests/boundary/vec_field_index_return.x` `main` dest9（`let dst9: Wrap = { h: inner }`）；`-E` 不得 `(struct )`

✅ **匿名 match `{ fields } =>`** ✅ @ **`bb35bfe9c`**

  - 闸：`tests/typeck/match_struct_anon.x`（bind／lit／wild／guard；named `Point { x, y }` 邻域仍绿）

✅ **dest-in-rbx IF of ARRAY_LIT `*p = if (c) { [w] } else { [y] }`** ✅ @ **`283acc79b`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 250–257（含 false arm）

✅ **dest-in-rbx IF extra arm stmts（nso>1）`*p = if (c) { let t: T = a; { dest } }`** ✅ @ **`d701c5d37`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 258–269（then／false 臂 let／assign）

✅ **dest-in-rbx MATCH `*p = match tag { 1 => w; _ => y }`** ✅ @ **`83d69b4f5`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_match_dest` 274–291（含 false arm／STRUCT_LIT／FIELD／CALL／ARRAY_LIT）／`dest_if_dest` 270–273 dest-in-rbx IF of MATCH

✅ **dest-in-rbx IF extra arm loops `*p = if (c) { while/for/if-stmt; { dest } }`** ✅ @ **`e824fec54`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 292–299（then／false while／if-stmt／for）

✅ **dest-in-rbx IF extra arm region `*p = if (c) { unsafe { k = 1 }; { dest } }`** ✅ @ **`9377c3c17`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 300–303（then／false unsafe）

✅ **dest-in-rbx IF dest wrapped in unsafe `*p = if (c) { unsafe { { dest } } }`** ✅ @ **`c14b2c37f`**

  - 闸：`tests/boundary/dest_if_region_wrap.x`（then／false dest-region dest；leftover 80–83）

✅ **dest-in-rbx IF extra arm labeled `*p = if (c) { goto L; L: k = 1; dest }`** ✅ @ **`1bd000752`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_if_dest` 84–87（then／false `goto`＋`L:`＋assign；8-bit leftover）

✅ **dest-in-rbx MATCH field-bind `*ph = match w { Wrap { h } => h }`** ✅ @ **`c30f11681`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_match_dest` 88–95（named／anon `=> h`／`{ h: h }`；8-bit leftover）

✅ **匿名 enum `.Variant =>`** ✅ @ **`1bd9cafc0`**

  - 闸：`tests/typeck/match_enum_anon.x`（dest-typed `.Green`／`.Red`／`_`＋named `Color.Green` 邻域）

✅ **裸 enum `Variant =>`** ✅ @ **`42cb45eff`**

  - 闸：`tests/typeck/match_enum_anon.x` `classify_bare`（dest-typed `Green`／`Red`／`_`）

✅ **帧 dest 16B MATCH field-bind `let r: Holder = match w { Wrap { h } => h }`** ✅ @ **`62ef1cbaa`**

  - 闸：`tests/boundary/vec_field_index_return.x` `dest_match_dest` 96–99（`let rf: Holder`／`let rf2: Wrap`；8-bit leftover）

✅ **dest extra-arm 末尾 `{ fields }` host-C**（parse_block `{` 一律嵌套块）

  - 现场：`*p = if (c) { let t: i32 = 1; { h: { v: a } } }`／MATCH 同形。asm **0**（16B Wrap≡i32x4 偶绿）。host-C `void` 赋 `struct Wrap`（GNU stmt-expr 末句是 `(void)(labeled block)`／`h:` 标签）
  - **根修**：`parser_parse_block_into` `TOKEN_LBRACE` 补同一 LBRACE 歧义：IDENT 后 `:`／`,`／`}` → 落入既有 `parse_expr`（primary glue 已认 STRUCT_LIT），末句盖 `final_expr`。`{ let … }`／`{ unsafe … }`／`{ { … } }` 仍嵌套块（mega 无 `;`）
  - 手术补 last-good `parser_gen.c`＋seed＋`parser.x` 同 commit；**禁**全量 assemble parser.x（tip `-E` 丢 `generic_bound_scan`）
  - 闸：isolate `if_let_slit`／`match_region_semi` host-C 复合字面量＋run **0**；官方 `dest_if_dest`／`dest_match_dest` asm **0**

✅ **dest extra-arm `unsafe { … }; dest` 可选分号 ASI**（parse_block IDENT-unsafe 后 `;` 当 expr → P001）

  - 现场：`*p = match tag { 1 => { unsafe { k = 1 }; { h: { v: a } } } }`／IF 同形／field-bind `{ unsafe { k = 1 }; h }`。无 `;` 的 dest_if extra-arm region **已绿**。整函数 P001 no functions
  - **根修**：`parser_parse_block_into_with_scratch` IDENT-unsafe 补同一可选 `;`＋`stmt_tok_ready`（≡ wave655 return ASI）。无 `;` 时 `r` 已是下一 stmt head。**禁** realign（会二次 skip dest）
  - 手术补 last-good `parser_gen.c`＋seed＋`parser.x` 同 commit；**禁**全量 assemble parser.x
  - 闸：`tests/boundary/dest_match_region_semi.x` isolate／asm／host-C／xlang-c **0**；官方 wrap／vfir **0**

✅ **dest extra-arm `region { … }; dest` 可选分号 ASI**（parse_block TOKEN_REGION／with_arena／defer 后 `;` 当 expr → P001）

  - 现场：`*p = match tag { 1 => { region foo { k = 1 }; { h: { v: a } } } }`／IF 同形／field-bind `{ region baz { k = 1 }; h }`。无 `;` 的 region dest **已绿**。整函数 P001 no functions
  - **根修**：`parser_parse_block_into_with_scratch` TOKEN_REGION／TOKEN_WITH_ARENA／TOKEN_DEFER 补同一可选 `;`＋`stmt_tok_ready`（≡ IDENT-unsafe／wave655）。去掉 realign（会二次 skip dest）
  - 手术补 last-good `parser_gen.c`＋seed＋`parser.x` 同 commit；**禁**全量 assemble parser.x
  - 闸：`tests/boundary/dest_region_semi.x` isolate／asm／host-C／xlang-c **0**；官方 wrap／vfir／dms **0**
  - 余（勿并本叶）：parse_into 函数体 `region {}; return` 同模式 ASI **已闭**（下条）；with_arena extra-arm dest typeck 逃逸 **已闭**；dest extra-arm SIMD 叠两条 `with_arena` dest **已闭**

✅ **parse_into 函数体 `region {}; return` 同模式 ASI**（onefunc TOKEN_REGION／with_arena／defer 后 `;` 当 expr → P001）

  - 现场：`region foo { k = 1 }; return k`／`with_arena(64) { … }; return`／`defer { 0 }; return`。无 `;` 的 `region { k = 1 } return` **已绿**。整函数 P001 no functions
  - **根修**：`parse_into` TOKEN_REGION／TOKEN_WITH_ARENA／TOKEN_DEFER 补同一可选 `;`＋`stmt_tok_ready`（≡ parse_block／IDENT-unsafe／wave655）。无 `;` 时 `r` 已是下一 stmt head。**禁** realign
  - 手术补 last-good `parser_gen.c`＋seed＋`parser.x` 同 commit；**禁**全量 assemble parser.x
  - 闸：`tests/boundary/fn_region_semi.x` isolate／asm／host-C／xlang-c **0**；dest wrap／dms／ifrw **0**
  - 余（勿并本叶）：with_arena extra-arm dest typeck 逃逸 **已闭**（下条）；dest extra-arm SIMD 叠两条 `with_arena` dest **已闭**

✅ **with_arena extra-arm dest typeck 逃逸**（AL-04 assign 把外层标量 `k = 1` 一律当 allocator region escape → XT001）

  - 现场：`*p = match tag { 1 => { with_arena(64) { k = 1 }; { dest } } }`／函数体 `with_arena(64) { k = 1 }; return k`。parse 已绿。整函数 XT001
  - **根修**：`typeck_check_allocator_region_assign` 补全与 return 闸同一刀：EXPR_LIT RHS 非 Allocator 值则放行；LHS resolved／let 类型已知且非 Allocator 则放行；Allocator 外写仍拒。负例 `allocator_assign_escape.x` 改为写 `heap.Allocator`
  - assemble `typeck.x`（产品 7.4.1 冷链）；**禁** assemble parser.x
  - 闸：`tests/boundary/dest_wa_semi.x` i32 dest isolate／asm／xlang-c **0**；fn_wa_semi host-C＋asm＋xlang-c **1**；assign／return 负例仍拒
  - 余（勿并本叶）：SIMD Wrap dest-in-rbx＋with_arena Ubuntu 139 **已闭**（下条）；dest extra-arm SIMD 叠两条 `with_arena` dest **已闭**

✅ **dest extra-arm SIMD Wrap dest-in-rbx＋with_arena emit**（Ubuntu SIGSEGV 139；Darwin dest-shadow 偶绿）

  - 现场：`*p = match tag { 1 => { with_arena(64) { k = 1 }; { h: { v: a } } } }`。region extra-arm dest-in-rbx **已绿**；i32 dest＋with_arena **已绿**。dest_spill（x86 高位）与 reserved wa 槽重叠，`heap_arena_init_c` 砸 dest 指针
  - **根修（G.7 有则补全）**：产生点＝`glue_wa_scope_alloc_off_c` 无视 dest-in-rbx 已推的 `next_offset`。权威已是同一 alloc。x86 高位 dest 存在 `rbp-cur`，Arena64 从 `rbp-off` 起 24B；`off==cur` 砸 dest（`memcpy` dest=NULL）。`off < cur+24` 则 `off=cur+24`。seed 孪。prefer thin+rest pipeline_abi；**禁** mega assemble
  - 闸：`tests/boundary/dest_wa_semi.x` SIMD dest isolate／asm／xlang-c **0**
  - 余（已闭 dest extra-arm SIMD host-C `-E`）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；dest extra-arm SIMD 叠两条 `with_arena` dest **已闭**

✅ **dest extra-arm SIMD host-C `-E` 头 `i32x4_t`**（裸 `-E`+cc `unknown type name i32x4_t`，级联未声明 `a`）

  - 现场：`dest_wa_semi`／`dest_region_semi` 裸 `-E`+cc 红。`xlang-c`／`-o` 已绿（rt_preamble §10 已有 typedef）。`emit_vector_c_type_out` 发 `i32x4_t` 名，头未 typedef
  - **根修（G.7 有则补全）**：产生点＝`codegen_x_ast_emit_header`。补同一权威：`codegen_emit_vector_typedefs`（`XLANG_VECTOR_TYPES`，与 rt_preamble §10 同套 i32／u32／f32 ×4／8／16）。rt_preamble 既有槽折入同一 guard（**不**加 N=224 行）。**禁** seed emit_header u8[256]；**禁** assemble parser／pipeline_abi mega
  - 闸：`dest_wa_semi`／`dest_region_semi`／`dest_match_region_semi`／`dest_if_region_wrap` 裸 `-E`+cc **0**；asm／xlang-c／`-o` **0**
  - 余（已闭 dest extra-arm SIMD 叠两条 `with_arena` dest）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **dest extra-arm SIMD 叠 MATCH＋IF＋field-bind＋无分号 `with_arena` dest**（旧 Darwin 139；官方闸曾收成单条 MATCH）

  - 现场：同一 `main` 叠 MATCH＋IF 两条 `with_arena` dest 曾 Darwin 139。单条 MATCH／IF extra-arm 本绿。上波 `glue_wa_scope_alloc_off_c` `off>=cur+24` 后叠两条双端已 0（dest_spill／Arena64，不是 onefunc sidecar 容量）
  - **根修（G.7 有则补全）**：产生点已在同一 alloc。本叶补同一官方闸 `tests/boundary/dest_wa_semi.x`：极性＝`dest_region_semi`／`dest_match_region_semi`（MATCH＋IF＋field-bind＋无分号 twin）。**禁**新建第二闸。**禁** assemble parser／pipeline_abi mega
  - 闸：`dest_wa_semi` isolate／asm／host-C／xlang-c **0**
  - 余（已闭 dest extra-arm `defer { k=1 }; dest`）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；dest extra-arm extra wrap `{ { let t; dest } }` host-C **已闭**

✅ **dest extra-arm `defer { k=1 }; dest` emit**（asm leftover 71；host-C 0）

  - 现场：`*p = match tag { 1 => { defer { k = 1 }; { dest } } }`／IF 同形。parse 已绿（TOKEN_DEFER 可选 `;`）。host-C **0**。asm／xlang-c dest 对、k 未写
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_if_arm_dest_in_rbx_elf_c`。parse_block TOKEN_DEFER 只 `append_defer`（不进 stmt_order）。前缀 so_k 2..7 看不见。帧 dest extra defer 本绿（body_sync 调 `glue_emit_run_language_defers_elf`）。补同一 helper：剥 extra-arm 后、dest emit 前跑 extra-arm defer 池；再 restore dest（defer 体砸 rbx／x19）。prefer thin+rest pipeline_abi；**禁** mega assemble
  - 闸：`tests/boundary/dest_region_semi.x` 补 MATCH＋IF＋field-bind＋无分号 dest extra-arm defer isolate／asm／host-C／xlang-c **0**
  - 余（已闭 dest extra-arm extra wrap `{ { let t; dest } }`）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off；dest-from-region dest-region-body defer

✅ **dest extra-arm extra wrap `{ { let t; dest } }` host-C**（asm leftover 偶绿；host-C `void` 赋结构体）

  - 现场：`*p = match tag { 1 => { { let t: i32 = 1; { dest } } } }`／IF 同形／`{ { dest } }` extra wrap STRUCT_LIT。`{ let t; dest }` 无 extra wrap 已绿。asm／xlang-c dest-in-rbx 剥 BLOCK 偶绿。host-C GNU stmt-expr 末句 `(void)({...})`
  - **根修（G.7 有则补全）**：产生点＝`parse_block` TOKEN_LBRACE 嵌套块一律 wrap EXPR_BLOCK＋append expr_stmt、不盖 final_expr。补同一权威：嵌套块后 peek `}` 或 `;` 再 `}` → 升 `final_expr`（≡ trailing STRUCT_LIT）。中段 `{ let } next_stmt` 仍 expr_stmt。手术 last-good `parser_gen.c`＋seed＋`parser.x`；**禁** assemble parser.x
  - 闸：`tests/boundary/dest_region_semi.x` 补 MATCH＋IF＋field-bind＋无分号 dest extra-arm extra wrap isolate／asm／host-C／xlang-c **0**
  - 余（已闭 dest-from-region dest-region-body defer）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **dest-from-region dest-region-body defer**（asm leftover 53；host-C 0）

  - 现场：`*p = match tag { 1 => { with_arena(64) { defer { k = 1 }; { dest } } } }`／IF 同形／field-bind 同形。dest extra-arm defer 已绿。host-C 内联 `(k=1)` **0**。asm／xlang-c dest 对、k 未写
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_if_arm_dest_in_rbx_elf_c`。dest-from-region 把 br 换成 dest region body；`defer_br` 仍是 extra-arm MATCH／IF 块（空 defer 池）。补同一 helper：剥后先跑 dest region body 的 `glue_emit_run_language_defers_elf`，再跑 extra-arm，再 restore dest（defer 体砸 rbx／x19）。prefer thin+rest pipeline_abi；**禁** mega assemble
  - 闸：`tests/boundary/dest_region_semi.x` 补 MATCH＋IF＋field-bind＋无分号 dest-from-region dest-region-body defer leftover 100–111 isolate／asm／host-C／xlang-c **0**
  - 余（已闭 dest-from-region intermediate-region defer asm leftover 54）：见下；已闭 host-C dest-from-region intermediate stmt-expr 末值；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **dest-from-region intermediate-region defer**（asm leftover 54；host-C stmt-expr 已闭另叶）

  - 现场：`*p = match tag { 1 => { unsafe { defer { m = 1 }; with_arena(64) { dest } } } }` dest 对、m 未写 leftover **54**。dest-from-region dest-region-body defer 已绿。host-C GNU stmt-expr 末值 `(m=1)` 赋 `struct Wrap`（codegen emit_block 先发 dest-from-region 前缀再跑中间层 defer）
  - **根修（G.7 有则补全）**：产生点＝`glue_emit_if_arm_dest_in_rbx_elf_c`。二次及以后 dest-from-region 剥层覆盖 br；只跑 dest region＋extra-arm defer 池。补同一 helper：旧 dest-from-region body 入栈；剥后 dest region → 中间层 LIFO → extra-arm，再 restore dest。prefer thin+rest pipeline_abi；**禁** mega assemble
  - 闸：官方 `dest_region_semi` leftover 112+ 等 host-C 叶（已闭见下）。isolate asm／xlang-c **0**；dest_region／dwa／dms／ifrw 仍 **0**
  - 余（已闭 host-C dest-from-region intermediate stmt-expr 末值）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **host-C dest-from-region intermediate stmt-expr 末值**（GNU `(m=1)` 赋 Wrap）

  - 现场：`*p = match tag { 1 => { unsafe { defer { m = 1 }; with_arena(64) { dest } } } }` asm／xlang-c **0**。host-C `-E`+cc：GNU stmt-expr 末值 `(m=1)` 赋 `struct Wrap`（ternary 与 `y` 类型也不合）
  - **根修（G.7 有则补全）**：产生点＝`codegen.x emit_block`。dest-from-region 最后 so_k==6 是 dest（无 final_expr）；`emit_run_defers` 在 dest 之后跑，末值变成 defer。补同一权威：无 final_expr 且末条 so_k==6 时先跑 wrapping defer，再发 dest。assemble codegen.x；**禁** mega／assemble parser.x
  - 闸：`tests/boundary/dest_fromreg_mid_semi.x` MATCH＋IF＋field-bind＋无分号 leftover 112–123 isolate／asm／host-C／xlang-c **0**。`dest_region_semi` 大 main 叠 112+ Ubuntu dest-park **139**（另文件；70–111 仍 0）
  - 余（已闭 host-C dest-from-region 叠中间层 last-wins）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **host-C dest-from-region 叠中间层 last-wins**（FIFO k=2 vs dest-in-rbx LIFO k=1）

  - 现场：`*p = match tag { 1 => { unsafe { defer { k = 1 }; region { defer { k = 2 }; with_arena dest } } } }` dest 对。host-C leftover **53**（k=2，外层先 hoist）。asm／xlang-c **0**（k=1，dest-region → 中间层 LIFO → extra-arm）
  - **根修（G.7 有则补全）**：产生点＝`codegen.x emit_block`。叠 dest-from-region 末条 so_k==6 先 hoist 本层 wrapping（FIFO）。补同一权威：先 hoist 末 dest wrapping（内层）、再本层 wrapping（外层），dest emit skip-wrap 防二次跑；dest 仍 GNU stmt-expr 末值。assemble codegen.x；**禁** mega／assemble parser.x
  - 闸：`tests/boundary/dest_fromreg_stack_semi.x` MATCH＋IF＋field-bind＋无分号 leftover 124–135 isolate／asm／host-C／xlang-c **0**。勿叠 dest_fromreg_mid／dest_region 大 main
  - 余（已闭 host-C dest-from-region wrapping＋dest-region-body last-wins）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **host-C dest-from-region wrapping＋dest-region-body last-wins**（dest-region-body k=2 二次跑）

  - 现场：`*p = match tag { 1 => { unsafe { defer { k = 1 }; with_arena { defer { k = 2 }; dest } } } }` dest 对。host-C leftover **138**（k=2；C 为 k=2、k=1、k=2、dest）。asm／xlang-c **0**（k=1 LIFO）。叠中间层 last-wins 已绿；本叶无中间 named region
  - **根修（G.7 有则补全）**：产生点＝`codegen.x emit_block` stmt_order==0 fallback。dest-region-body 常只有 defer 池＋final_expr dest；wrapping 已 hoist dest-region-body 再 wrapping，skip-wrap 只盖 stmt_order>0 末 dest。补同一权威：fallback `emit_run_defers` 也认 skip-wrap，dest 仍 GNU 末值。assemble codegen.x；**禁** mega／assemble parser.x
  - 闸：`tests/boundary/dest_fromreg_body_semi.x` MATCH＋IF＋field-bind＋无分号 leftover 136–147 isolate／asm／host-C／xlang-c **0**。勿叠 dest_fromreg_stack／mid／dest_region 大 main
  - 余（已闭 dest wrap IF dest）：见下；另层：TYPE_DYN／vtable ✅；4.2.4–5／4.2.7 leave-off

✅ **dest wrap IF dest**（MATCH extra-arm last dest 是 IF dest）

  - 现场：`*p = match tag { 1 => { if (c) { dest } else { y } }; _ => y }` 顶层 `*p = if` 已绿。host-C void 赋 Wrap（MATCH 臂 GNU stmt-expr 末句是 C `if`）。asm／xlang-c CG002 `.Lf0_2` offset=-1
  - **根修（G.7 有则补全）**：产生点＝`parse_block` TOKEN_IF。TOKEN_MATCH 末值已升 `final_expr`；TOKEN_IF 一律 `parse_if_stmt_into`＋if-stmt。补同一权威：末 dest（`}` 或 `;` 再 `}`）复用既有 `parse_if_expr_into`（≡ `*p = if`）；中段 `if { k = 1 }; dest` 仍 if-stmt；`parse_if_expr_into` 失败回落 if-stmt。手术 last-good `parser_gen.c`＋seed＋`parser.x`；**禁** assemble parser.x
  - 闸：`tests/boundary/dest_match_if_semi.x` MATCH＋IF＋field-bind＋无分号 leftover 148–155 isolate／asm／host-C／xlang-c **0**。勿叠 dest_fromreg_*／dest_region 大 main
  - 邻域再探绿：else-if last dest（ifwrapelif／ifwrapelif2／ifwrapeliffb）· 嵌套 MATCH dest（nestmatch）三端 **0**；无 else 的 IF 末 dest 仍语言契约（`parse_if_expr_into` 失败回落 if-stmt）
  - **dest leftover 族已尽**（禁再叠 last-wins／dest-park 139）
  - 余（勿并本叶）：TYPE_DYN／vtable ✅（dyn 非 KW；类型位已 parse；host-C `struct Clone` incomplete＝fat-ptr／对象分发后期，非薄 emit）；4.2.4–5／4.2.7 leave-off

---


## 阶段 5：R2 真迁退役 Track R（大部分完成）

> **定义**：产品构建路径上，该 TU 业务符号全部来自 .x→.o，不再依赖 hybrid rest 同名 C 体。
> **判据**：rest 中该业务符号不再 `#ifndef` 提供 C 体；rest seed 可空/可删宏。

### 5.1 已完成 R2 真迁的模块（~120/128）

> 详见阶段 3 的 128 prove 模块列表。其中 ~120 个已 R2 真迁（rest 业务 H=0），仅保留 Cap residual _impl 桥或 marker。

✅ **5.1.1 全部 labi_* 切片（12 个）R2 full**

✅ **5.1.2 全部 rt_* 切片（23 个）R2 full**

✅ **5.1.3 全部 runtime_* asm 切片（41 个）R2 thin+rest / DIRECT**

✅ **5.1.4 全部 backend/simd 切片（20 个）R2 mixed/full**

✅ **5.1.5 src 根组（15 个）R2 mixed/full**

✅ **5.1.6 async 组（2 个）R2 pure**

✅ **5.1.7 driver 组（11 个）R2 / Track L 退役**

✅ **5.1.8 lsp 组（4 个）R2**

✅ **5.1.9 lexer 组（1 个）prove 锁**


### 5.2 R2 待收口项

✅ **5.2.1 wave445 SHARED ABI mono 字段 tip L4 收口**

  - 日常 L2 已过；**双端 L4 真冷绿 @ `d79a368b2`**（mac 35m42s · Ubuntu 11m36s · bstrict 129 · 2026-08-10 升钉）
  - wave445 SHARED ABI mono 字段已含入 d79a368b2 钉盘 L4 验证范围

⬜ **5.2.2 Darwin stage2 rv / strict multi-def** 平台债

  - macOS stage2 riscv 与 strict 多重定义路径

⬜ **5.2.3 host `_impl` 后缀命名** leave-off

  - host-C 路径的 `_impl` 后缀命名（与 R2 真迁相关）

⬜ **5.2.4 Darwin `int64_t main` 硬要求 int** 平台债

  - 来源：wave623 soft 项
  - macOS 平台硬性要求 main 返回 int，与 int64_t 冲突
  - 未在任何后续 wave 中明确关闭

⬜ **5.2.5 Windows MSYS2 继承 hybrid 未重跑** 平台债

  - 来源：自举进度.md 双端/平台表
  - Windows MSYS2 仍继承 hybrid，本波未重跑
  - 需补做 Windows 双端 L4 验证

⬜ **5.2.6 mac CTFE 常 fold 假绿** 工程债

  - 来源：wave620/645/646/647/648 反复出现
  - mac 上 pure-asm 路径 CTFE 折叠常导致假绿，掩盖真问题
  - 需治本或列入长期约束

⬜ **5.2.7 mac `-dead_strip` 假绿当 Ubuntu 全链已过** 工程纪律债

  - 来源：自举进度.md §7 禁止清单
  - 禁止把 mac `-dead_strip` 假绿当 Ubuntu 全链已过
  - 需列入长期约束文档

---

## 阶段 6：Mega 拆分 Track M1-M3（已完成 · 3/3）

> **定义**：M1 该 mega 源能被当前编译器 typeck / -E 消费；M2 regen *_x.o 替换 pinned .o smoke 绿；M3 Stage2 / D-03。

### 6.1 runtime mega 拆分（RFC: G-02f-P2-runtime-mega）

✅ **6.1.1 R0–R10 全部落地** 11 册

✅ **6.1.2 19 个 rest sub-slice 落地**（详见 3.5 rt_* 切片）

✅ **6.1.3 f-317 里程碑** product rest 业务 T 符号 = 0

✅ **6.1.4 切片完成度** 24/24

✅ **6.1.5 rest 仅 marker + Cap residual**（R7/R8 OS/pthread 等 **原**标 🔒；归阶段 9 **必须消灭**，非永久 seed 边界）


### 6.2 parser thin mega 拆分（RFC: G-02f-P2-parser-thin-mega）

✅ **6.2.1 P0–P9 原计划落地** 10 册

✅ **6.2.2 P10–P20 扩展落地** 11 册（f-318–f-329）

✅ **6.2.3 f-329 P20 foundation** rest T=0

✅ **6.2.4 f-330 omit empty rest** 全产品切片齐时跳过 mega rest cc -c

✅ **6.2.5 24 个 pthin_*.x 切片**

✅ **6.2.6 切片完成度** 21/21


### 6.3 link_abi mega 拆分（RFC: G-02f-P2-link-abi-mega）

✅ **6.3.1 L0–L9 全部落地** 10 册

✅ **6.3.2 L8b ondemand 拆分**（f-272）

✅ **6.3.3 f-277 里程碑** link_abi L0–L9 十册 hybrid 齐

✅ **6.3.4 12 个 labi_*.x 切片**

✅ **6.3.5 切片完成度** 11/11

✅ **6.3.6 L3+ 含 stat/spawn/cc/ld** 历史曾标 🔒 薄门闩；**invoke_cc/ld 本体归阶段 9/12–13 必须消灭或 opt-in 隔离**（删 Makefile 后产品默认不得再 `exec` host-cc）


---

## 阶段 7：Mega 去 pin Track M4（**冷链关 pin 5/5 ✅** · 物理删 parser seed／CI 漂移闸仍 ⬜）

> **定义**：M4 关 pin / 空 patch；冷启动可从「上一代 xlang -E」或 **纯 .x 产品路径**重建。  
> **当前**：runtime monofile 物理退役 ✅；typeck／codegen／parser／link_abi **冷链** prefer `.x` assemble ✅（默认 FROM_X=1；pin 仅考古 egg）。parser seed 文件仍在（7.2.1 ⬜）；`runtime_link_abi_gen.c` 不存在（7.3.2 vacuous ✅）；7.4.4 CI 漂移闸 ⬜。  
> **补遗**：前端 **typeck / codegen** 亦是 pin 权威（产品链 `typeck_x.o` / `codegen_x.o` 常来自 pin seed），原 0/3 仪表盘漏计，现计 **5** 项。

### 7.1 runtime mega 去 pin

✅ **7.1.1 关闭 runtime pinned seed**

  - 当前：`seeds/runtime.from_x.c` **已物理删除**（wave321 · ~8,187 LOC）
  - 产品／R1 冷 map：`runtime_driver_no_c.o`＝multi-slice only；`runtime.o`／`runtime_x.o`／`runtime_driver.o`＝no_c multi-slice **alias**
  - prefer omit ✅（wave318）· cold multi-slice omit ✅（wave319）· product 拒 monofile ✅（wave320／7.1.2）· **物理 rm ✅（wave321）**

✅ **7.1.2 runtime_driver_no_c.o 产品链去 pin**

  - 当前：产品 PREFER=0/1 → 切片 `cc -r` only（omit empty rest）；**默认硬拒** monofile；monofile 文件已不在树（wave321）
  - 目标：产品 .o 全部来自切片／.x — **已达标**

✅ **7.1.3 M3 Stage2 / D-03 验证**

  - Stage2 行为一致（xlang_asm / xlang_asm2 编 return-value exit=42 双端对齐）
  - Stage2 SHA256 金标准 match（`0f8b72c2a184670cb9d76a7b41f224f13504906daacaa2ed0a61d6dab4725c17`）
  - M4 5/5 全 ✅（runtime 7.1 / typeck 7.4.1 / codegen 7.4.2 / parser 7.2 / link_abi 7.3 冷链全闭）


### 7.2 parser mega 去 pin

⬜ **7.2.1 关闭 parser pinned seed**

  - 当前：seeds/parser_asm_thin_c.from_x.c（~21,935 LOC）仍是冷启动 seed
  - 目标：冷启动可从 pthin_*.x 重建

🟡 **7.2.2 parser_gen.c 去 pin**（wave325 曾关 pin；**残差回退 pin 权威**）

  - 基建仍在：`scripts/assemble_parser_gen_from_x.py`（tip `-E` + bare→`parser_*` + rename + demangle + scrub）
  - **产品冷权威（2026-08-17）**：`seeds/parser_gen.linux.x86_64.c` **pin-first**
    - `ensure_migrate_gen` 默认 **`XLANG_PARSER_FROM_X=0`**
    - g05 缺 `parser_x.o` 时 **强制 cp pin** 再 `cc`；**禁**默认 tip assemble
    - tip assemble 仅 **`XLANG_PARSER_FROM_X=1`** 显式 opt-in
  - 根因：tip `-E` parser.x 丢 surgical seed 叶（generic_bound_scan／dest IF last-dest／region ASI…）→ host-C `return (struct ){` 等假绿脚枪
  - 手术改 parser 仍须 **seed + parser.x 同 commit**；**禁**全量 assemble parser.x 当冷路径
  - 验收：mac 毒 gen + `rm parser_x.o` → g05 pin-first · 矩阵 5/5 · dest 闸 0；Ubuntu 同测

✅ **7.2.3 M3 Stage2 / D-03 验证**

  - Stage2 行为一致 + SHA256 match（见 7.1.3）
  - parser 7.2.2：wave325 关 pin 后 **残差 pin-first 回退**（见上）


### 7.3 link_abi mega 去 pin

✅ **7.3.1 关闭 link_abi pinned seed**

  - 当前（wave326）：**默认 FROM_X=1**（labi_*.x 切片权威）；`seeds/runtime_link_abi.from_x.c` + 12 `seeds/labi_*.from_x.c` **仅考古 egg**
  - 基建：`ensure_host_cc_seed_o.sh try-labi-prefer`（wave765 已就位）＝12 labi_*.x 切片 prefer → 单切片 .o → `$CC -r -nostdlib` 合并；失败切片 fallback seed；mega seed rest 用 `-D XLANG_LABI_*_FROM_X` 条件编译
  - 门控：`XLANG_LINK_ABI_FROM_X=1` 默认（wave326 加）；`XLANG_LINK_ABI_ALLOW_PIN=1`（真冷 egg 回退）；兼容 `XLANG_G05_PREFER_X_O` legacy
  - 验收：双端 L2 绿（macOS arm64 + Ubuntu x86_64 gold @ ubuntu-remote-server）；FORCE rebuild runtime_link_abi.o：L2/L3/L8/L9 prefer .x，其余 cold seed fallback，纯合并通过；pure-ld + `./xbuild l2-matrix` 5/5
  - 达标：默认 FROM_X=1 且双端 L2 绿；pin 仅考古 egg — **已达标**

✅ **7.3.2 runtime_link_abi_gen.c 去 pin**（独立 pin 不存在 · vacuous）

  - 树内无 `seeds/runtime_link_abi_gen.c`
  - 冷／考古 twin 仅 `seeds/runtime_link_abi.from_x.c` + 12 `labi_*.from_x.c`（7.3.1 已关 pin）

✅ **7.3.3 M3 Stage2 / D-03 验证**

  - Stage2 行为一致 + SHA256 match（见 7.1.3）
  - link_abi 7.3.1 关 pin ✅（wave326 · 12 labi_*.x 默认 FROM_X=1 · pin 仅考古 egg）


### 7.4 前端 mega 去 pin（typeck / codegen · 原文档漏项）

> **为何独立成 7.4**：M1–M3 历史只拆 runtime/parser/link_abi 三 mega；但产品 L4 链上 **`typeck_gen.c` / `codegen_gen.c` pin** 与 `.x` 双权威问题同等严重（改 `.x` 不改 seed = 假绿）。删 Makefile 前必须可「上一代 xlang 直接编 typeck.x/codegen.x」而不读 pin。

✅ **7.4.1 typeck 去 pin**

  - 产品权威：`src/typeck/typeck.x` + companions assemble（`scripts/assemble_typeck_gen_from_x.py`）
  - 冷链：`ensure_migrate_gen.sh typeck` / g05 cold **prefer tip `-E` assemble**；`seeds/typeck_gen.linux.x86_64.c` **仅考古／true-cold egg**（无 -E 二进制时）
  - 组装层：① module-prefix rename bare→`typeck_*` ② Cap residual ③ mangle alias ④ short-face inject；**禁**盲 tip `-E` 覆盖
  - 证据：hide pin seed 后 ensure 仍 assemble OK；pure-ld + `./xbuild l2-matrix` 5/5
  - 残：companion 逐步 fold 进 `.x`（非 pin twin 权威）

✅ **7.4.2 codegen 去 pin**

  - 产品权威：`src/codegen/codegen.x` + Cap residual assemble（`scripts/assemble_codegen_gen_from_x.py`）
  - 冷链：`ensure_migrate_gen.sh codegen` / g05 cold **prefer tip `-E` assemble**；`seeds/codegen_gen.linux.x86_64.c` **仅考古／true-cold egg**
  - 组装层：① `CodegenOutBuf`→`codegen_CodegenOutBuf` ② bare→`codegen_*` ③ X-mangle demangle（含 call sites）④ Cap residual（host BSS／slice_let／pipeline scratch+loop）
  - 根修（`.x`）：emit_expr 未闭合注释 + orphan TRY_PROPAGATE 注释 + T001（bool!=0／enum.kind==lit）+ buf wrapper 发射长度 off-by-one（`_bu` 截断）
  - 证据：hide pin seed 后 ensure assemble OK；pure-ld + `./xbuild l2-matrix` 5/5
  - 残：companion 逐步 fold 进 `.x`（非 pin twin 权威）；parser／link_abi **冷链关 pin已闭**（7.2.2／7.3.1）；parser seed 物理删仍 7.2.1

✅ **7.4.3 lexer / preprocess / pipeline 去 pin 对齐**

  - **wave338 双端 8/8 PREFER_X_O 全通**（pipeline wave335 + post_E_fixup wave336-337 + wave338 dedup/double-prefix/typedef 前移）
  - pipeline.x wave335 ✅（删 6 死 import · -E 46.62s→0.02s · 2331× 加速）
  - ast/lexer/parser/typeck/codegen wave336-337 ✅（post_E_fixup forward-decl + typedef 前移 + 条件 append）
  - wave338 ✅（dedup_colliding_definitions + double-prefix alias + per-leaf alarm）
  - **8/10 复验**（formal_mod 波 `d79a368b2` 后）：wave338 三缺口全修复确认 — macOS ast_gen2（双前缀消除）+ macOS driver_x（双定义消除）由 formal_mod per-symbol bare rename 修；Ubuntu codegen_x（37.3s < 60s alarm）由 wave338 per-leaf override 覆盖。双端 PREFER_X_O 8/8 真验证 ✅ · 双端 L2 5/5 绿 @ `d9e9ce5aa`

  - 与阶段 8.2.2 / 8.2.10 / 8.2.11 联动；前端「能自 regen」再谈删 Makefile 冷启动规则
  - **pipeline.x wave335 ✅（根源修复 · 去 pin 对齐首胜）**：pipeline.x 本就是**纯 extern 签名头模块**（658 LOC = 162 `export extern function` 声明 + 0 带体函数）——所有实现都在 runtime_pipeline_abi.x。
    - **G.7 违规发现**（wave334 诊断基础上进一步验证）：6 个大 import（ast/lexer/parser/typeck/codegen/asm_backend）**全是死 import**！逐模块 grep 单词出现次数 = 1（仅 import 行本身）；typeck 的 3 次里 2 次是 docblock 注释单词。实际 pipeline.x 没用到任何这些模块的符号！
    - **根因删除（根源修复非打补丁）**：6 个大 import 直接物理删（0 import 保留）。源码头部加 24 行详细英文 docblock（G.9 rule），说明 wave335 前死 import 背景 + -E 病态成本 + G.7 SINGLE AUTHORITY FIX 证明。
    - **性能验证（2331× 加速！）**：pipeline.x -E 46.62s / 795,931 B → **0.02s / 32,964 B**（100% 行为等价，只是 -E 不再无意义 transitively 展开 parser 12176 LOC + typeck 19542 LOC + codegen 21922 LOC + ast/lexer/asm_backend + 50K+ LOC O(n²) transitive declaration 叠乘）。
    - **Track L 对齐**：driver_leaf ensure pipeline_x.o **打 PREFER_X_O banner**（不 fallback cold seed！）——之前「超时」假象就是死 import 拖垮。
    - **零回归验证（** **G.8 SHARED 双端闭环** **）**：
      - **macOS arm64**：`./xbuild relink` pure-ld 58 objs OK；`./xbuild l2-matrix` pass=5 fail=0 rv42/opt102/hello0/si0/f32 @ `867e1e64d`
      - **Ubuntu x86_64（金标）**：`ssh ubuntu-remote-server` → `/home/shuliangfu/worker/xlang/x-lang` git ff 到 `867e1e64d` → `XLANG=./compiler/xlang_asm ./xbuild l2-matrix` **pass=5 fail=0**（SHA=867e1e64d Linux-x86_64；rv42 run=42 / opt102 run=102 / si0 run=0 / hello stdout 含 Hello / f32 run=0；build=0 ×5）
    - PLATFORM: SHARED（纯声明模块，无平台分支；死 import 清理跨平台等价）。
  - **wave334（2026-08-09）根因诊断基础**（上帝视角分析 · 实测数据）：
    - **问题表象**：wave327-331 Track L 退役的 6 项前端（parser/typeck/codegen/lexer/pipeline + ast_gen2）中，**仅 preprocess PREFER_X_O 真走通**；其余 5 项均 fallback cold-seed egg。commit message 记「PREFER_X_O 超时」是**误判**（alarm 30s 阈值非根因）。
    - **pipeline 已 wave335 根源修复**；其余 4 项（ast/lexer/parser/typeck/codegen）真根因：`xlang -E` 单 TU 展开后，CC 编译 -E 输出报 **跨模块引用未声明**（C99 禁止隐式函数声明 + use-of-undeclared-identifier 硬 error）：
      | .x 文件 | LOC | -E 耗时 | 30s alarm | CC 失败原因 |
      |---------|-----|---------|-----------|-------------|
      | preprocess.x | 1003 | 0.14s | ✅ | **无**（PREFER_X_O 通）|
      | pipeline.x | 658 | **✅ wave335 已修**（0.02s）| ✅ | **✅ wave335 根源修复**：删 6 死 import |
      | ast.x | 1393 | 0.15s | ✅ | **✅ wave336-337 post_E_fixup 修**（forward-decl + typedef 前移）；✅ 8/10 复验 formal_mod 修 codegen 命名 bug（双前缀消除） |
      | lexer.x | 4724 | 4.01s | ✅ | **✅ wave336-337 post_E_fixup 修**（forward-decl + typedef 前移）|
      | parser.x | 12176 | 16.52s | ✅ | **✅ wave336-337 post_E_fixup 修**（forward-decl + scrub init_globals）|
      | typeck.x | 19542 | 7.07s | ✅ | **✅ wave336-337 post_E_fixup 修**（forward-decl + 条件 append 5 body + static helper + 4 externs）|
      | codegen.x | 21922 | 26.94s | ✅ 临界 | **✅ wave336-337 post_E_fixup 修**（macOS 30.6s · Ubuntu 37.3s · 60s alarm override 覆盖）|
    - **根因归类（剩余 4 项）**：
      1. **-E 生成器跨模块函数引用无 extern 声明**（影响 4 项）：-E 单 TU 展开不引入跨模块函数的 extern 声明 → CC `-Wimplicit-function-declaration` error（C99 禁止）。影响：ast.x / typeck.x / codegen.x / lexer.x。
      2. **-E 生成器 init_globals 收集逻辑 bug**（影响 1 项 · src/codegen/codegen.x）：`init_globals()` 函数收集**所有模块**的 BSS 赋值（`g_lexer_unclosed_bc = 0;` 等），但 -E 输出只声明**当前模块**的 BSS 定义（`static int g_foo = 0;`）→ 跨模块 BSS 引用未声明 → CC `use-of-undeclared-identifier` 硬 error。影响：parser.x。
    - **自举循环依赖**：修 -E 生成器需动 src/codegen/codegen.x → 需重新生成 codegen_gen.c → 但 codegen_gen.c 已 Track L 退役（cold-seed egg fallback）→ 生成 egg 需 -E 走通 → PREFER_X_O 需 -E 输出自洽。
    - **修复路线图（剩余 4 项 · 5 步 · 禁止打补丁 · 根源治理）**：
      - **Step 1**：修 src/codegen/codegen.x 的 `init_globals` 生成逻辑 → 只收集当前模块 BSS 赋值（不跨模块收集）
      - **Step 2**：修 -E 生成器的跨模块函数引用 → 输出 extern 声明（或让 -E 输出 `#include` 跨模块头文件）
      - **Step 3**：✅ 完成（wave335 pipeline.x 去 pin 对齐首胜）
      - **Step 4**：打破自举循环（旧 xlang_asm -E → 手动修补 C 输出 → 编译新版 xlang_asm_new → 重新生成 cold-seed egg）
      - **Step 5**：验证 4 项 PREFER_X_O 真走通 → cold-seed egg 降级为纯考古 fallback
    - **当前状态**：pipeline wave335 已✅；剩余 ast/lexer/parser/typeck/codegen 4 项未启动；修复需中大工程（动 codegen.x + 打破自举循环）。
  - **wave336-337（2026-08-09）post_E_fixup 根修 + 条件 append + typedef 前移**（双端验证 · typeck_x.o PREFER_X_O 通）：
    - **wave336 根修：post_E_fixup 条件 append（G.7 有则补全）**
      - **问题**：wave335 `--append-typeck-bodies` 总是追加 5 个 body + 1 static helper + 4 externs；但 xlang-seed-phase1（macOS cold-start binary）的 -E 输出已含 5 个 body → redefinition error → PREFER_X_O 失败。
      - **根修**：`append_typeck_missing_bodies()` 改为**条件追加**——检查每个 body/static/extern 是否已在 src 中，已存在则跳过。`_has_body()` / `_has_static()` / `_has_extern()` 三个检测器，精确匹配 `name(...)\s*{`（body 定义）、`static ... name(`（static helper）、`extern ... name(`（extern 声明）。
      - **效果**：旧 xlang binary（缺 5 body）→ 追加 5 body + helper + externs；新 xlang-seed-phase1（已有 5 body）→ 0 追加，纯 no-op。G.7 有则补全铁律。
    - **wave337 根修：post_E_fixup typedef 前移（targeted hoisting）**
      - **问题**：forward-decl 注入在文件顶部，但 `fs_iovec_buf_t` 等typedef 在 -E 输出第 532 行才定义 → forward-decl 第 178 行报 `unknown type name 'fs_iovec_buf_t'`。
      - **根修**：`inject_forward_decls()` 加 Phase 0——扫描所有 `typedef struct Tag name;`（incomplete-struct typedef），只前移**函数签名中实际引用**的 typedef（`_needed_typedef_names` 集合过滤）。跳过 struct-body typedef（`typedef struct { ... } name;`）避免与系统头 SIMD 类型冲突。
      - **效果**：pipeline_x.o / preprocess_x.o / lexer_x.o / typeck_x.o / codegen_x.o / parser_x.o 全部 PREFER_X_O 通过（6/8 macOS）。
    - **双端验证（G.8 SHARED）**：
      - **macOS arm64**（xlang-seed-phase1 binary）：6/8 PREFER_X_O（pipeline/preprocess/lexer/typeck/codegen/parser ✅；ast_gen2 + driver_x 是 xlang-seed-phase1 codegen 回归——ast_gen2 命名不一致 `ast_ast_arena_block_get` vs `ast_arena_block_get`；driver_x `main_run_compiler_c` 双定义）。mac L2 5/5 ✅。
      - **Ubuntu x86_64**（金标 · xlang binary）：7/8 PREFER_X_O（pipeline/preprocess/lexer/typeck/parser/ast_gen2/driver_x ✅；codegen_x 是 30s alarm 超时——`_e_rc=142` SIGALRM）。Ubuntu L2 5/5 ✅（rv42/opt102/hello0/si0/f32）。
      - **typeck_x.o PREFER_X_O 双端都通过** ✅ — 根修验证完成。
    - **剩余失败分类（非 post_E_fixup 问题 · 8/10 复验全修复 ✅）**：
      - ✅ macOS ast_gen2.o：xlang-seed-phase1 -E 双前缀 `ast_ast_arena_block_get` → formal_mod 波 `d79a368b2` per-symbol bare rename 修 → tip -E `ast_arena_block_get` ×13（0 双前缀）→ PREFER_X_O exit=0。
      - ✅ macOS driver_x.o：xlang-seed-phase1 -E `main_run_compiler_c` 双定义 → formal_mod 修 codegen 重复输出 → PREFER_X_O exit=0。
      - ✅ Ubuntu codegen_x.o：30s alarm `_e_rc=142` SIGALRM → wave338 per-leaf 60s override → Ubuntu 实测 37.3s < 60s → PREFER_X_O exit=0。
    - PLATFORM: SHARED（post_E_fixup 条件 append + typedef 前移跨平台行为等价；typeck_x.o 双端 PREFER_X_O 通过）。

⬜ **7.4.4 双权威禁令验收**

  - 合入闸门：任意 touch `*.x` 产品面 → 同 commit 无「只改 seed」；CI 可 diff pin 与 `-E` 漂移（可选）


---

## 阶段 8：Pinned gen.c 退役（**⭐ 30/30 FULLY CLOSED · wave327-332 Batch3 收**）

> **定义**：compiler/ 顶层的 *_gen.c 是 pinned 生成器，产品链权威。Track L 退役 = 构建改用 *_x.o，pinned gen 仅考古。
>
> **wave332 收口**：分母口径统一（`is_product_denominator()` 单权威 whitelist，G.7 禁止双口径漂移）。30-baseline 全部正确分类：
> - **PRODUCT chain 23/23 RETIRED = 100%**（19 现存 catalog/bespoke + 4 已删物理 RETIRED）
> - **NON_PRODUCT 7 正确分类 never-product-chain**（TEST×2 + STAGE×2 + EXTRACT_ONLY×1 + DELETED_ORPHAN×2）
> - 详见 [自举进度.md §6 wave332](自举进度.md) + [阶段8高效退役分析.md §0.2](阶段8高效退役分析.md)

### 8.1 已退役的 pinned gen.c（**23 个 PRODUCT RETIRED** · wave327-332 全闭）

> 产品链 PREFER_X_O；工作区考古 gen 生产体 = `ensure_archaeology_gen.sh`；
> 冷启动 fallback = `seeds/*.linux.x86_64.c` 考古 cold-seed egg（G.7 单拷贝语义）

✅ **8.1.1 lsp_io_std_heap_gen.c** Track L 退役（构建用 lsp_io_std_heap_x.o；考古 shell）

✅ **8.1.2 driver_fmt_gen.c** Track L 退役（构建用 driver_fmt_x.o；考古 shell）

✅ **8.1.3 driver_check_gen.c** Track L 退役（archaeology shell）

✅ **8.1.4 driver_test_gen.c** Track L 退役（archaeology shell）

✅ **8.1.5 driver_build_gen.c** Track L 退役（archaeology shell）

✅ **8.1.6 driver_run_gen.c** Track L 退役（archaeology shell）

✅ **8.1.7 driver_emit_gen.c** Track L 退役（构建用 driver_emit_x.o；考古 shell）

✅ **8.1.8 driver_compile_gen.c** R2 真迁（构建用 driver_compile_x.o；考古 shell）

✅ **8.1.9 lsp_io_gen.c** Track L 退役 wave1036（构建用 lsp_io_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_lsp_pipeline_gen.sh`；6 个级联符号重命名复刻 historic -D flags）

✅ **8.1.10 build_gen.c** Track L 退役 wave1038（构建用 `../build.x` via `./xlang -x -E` 生成；考古 `seeds/build_gen.c`；最小文件优先策略）

✅ **8.1.11 build_runner_gen.c** Track L 退役 wave1039（构建用 `../build_runner.x` via `./xlang -x -E` 生成；考古 `seeds/build_runner_gen.c`；根源修复：9 处 extern 调用包裹 `unsafe{}` + `entry` 加 `#[no_mangle] export`）

✅ **8.1.12 build_runtime_x_gen.c** Track L 退役 wave1040（构建用 `../build_runtime_x.x` via `./xlang -x -E` 生成；考古 `seeds/build_runtime_x_gen.c`；根源修复：15 处 `build_exec_system` extern 调用用 `unsafe{}` 表达式形式包裹 + `copy_path`/`append_lit` 加 `#[no_mangle]`；build_*_gen 三件套全退役）

✅ **8.1.13 cfg_eval_gen.c** Track L 退役 wave1041（bespoke ladder · `try-cfg-eval-ladder` in `ensure_host_cc_seed_o.sh`；`src/lexer/cfg_eval.x` via `-E-extern -L ..` → `cfg_eval_x.o` → `ld -r` with `cfg_eval_link_alias.from_x.c` → `cfg_eval.o`；考古 `seeds/cfg_eval_gen.linux.x86_64.c`；G.7 单权威：catalog 不支持 ld -r alias merge，保留 bespoke ladder；`audit_gen_retirement.sh` 添加 Bespoke ladder-retired 识别段）

✅ **8.1.14 lsp_diag_gen.c** Track L 退役 wave327（构建用 lsp_diag_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_lsp_pipeline_gen.sh`；PREFER_X_O 通 → cold seed fallback；cold-seed pin `seeds/lsp_diag_gen.linux.x86_64.c`）

✅ **8.1.15 lsp_gen.c** Track L 退役 wave327（构建用 lsp_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_lsp_pipeline_gen.sh`；PREFER_X_O 通；cold-seed pin `seeds/lsp_gen.linux.x86_64.c`；wave316 monofile dual WEAK 已 extern-only）

✅ **8.1.16 pipeline_gen.c** Track L 退役 wave328（构建用 pipeline_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_lsp_pipeline_gen.sh`；PREFER_X_O 超时 → cold seed fallback；wave316 sole dual `io_register_buffers_buf_c` WEAK→extern-only；wave310 re-pin 对齐 tip residual shell）

✅ **8.1.17 driver_gen.c** Track L 退役 wave328（构建用 driver_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_driver_gen.sh`；MAIN_X_DEPS freshness + `fix_driver_gen_duplicate_main`；PREFER_X_O 失败 → cold seed fallback）

✅ **8.1.18 preprocess_gen.c** Track L 退役 wave328（构建用 preprocess_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_driver_gen.sh`；**PREFER_X_O 真走通**（src/preprocess/preprocess.x → -E → .o），无 cold seed 需求）

✅ **8.1.19 lexer_gen.c** Track L 退役 wave328（构建用 lexer_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_migrate_gen.sh`；专用 cold-seed rung `_try_frontend_track_l_cold_seed()`：prologue 8 POSIX 头 + sed strip malloc/free/calloc extern → 编 `seeds/lexer_gen.linux.x86_64.c`；**根因修复** lexer_gen.c 隐式声明 `lexer_next` C99 错误 + PREFER_X_O 与 parser_x.o `token_is_eof` duplicate 双 bug）

✅ **8.1.20 parser_gen.c** Track L 退役 wave329（构建用 parser_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_parser_gen.sh`；专用 cold-seed rung `_try_frontend_track_l_cold_seed()` 编 `seeds/parser_gen.linux.x86_64.c`；PREFER_X_O 超时（src/parser/parser.x 大 -E）→ cold seed；wave312 monofile dual 29× WEAK 已 extern-only 保留 1× weak）

✅ **8.1.21 typeck_gen.c** Track L 退役 wave329（构建用 typeck_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_typeck_gen.sh` + `assemble_typeck_gen_from_x.py` 冷链 prefer assemble；专用 cold-seed rung 编 `seeds/typeck_gen.linux.x86_64.c`；M4 7.4.1 冷链关 pin；wave312 monofile dual WEAK 已 extern-only；live STRONG＝`runtime_pipeline_abi`）

✅ **8.1.22 codegen_gen.c** Track L 退役 wave329（构建用 codegen_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_codegen_gen.sh` + `assemble_codegen_gen_from_x.py` 冷链 prefer assemble；专用 cold-seed rung 编 `seeds/codegen_gen.linux.x86_64.c`；M4 7.4.2 冷链关 pin；wave312 monofile dual WEAK 已 extern-only；pin 为 assemble 快照）

✅ **8.1.23 ast_gen2.c** Track L 退役 wave331（构建用 ast_gen2.o via `driver_leaf_x_to_o.sh` catalog；考古 `seeds/ast_gen2.linux.x86_64.c` 单拷贝语义 G.7 banner；**根因修复** 缺考古 cold-seed pin → driver_leaf PREFER_X_O 超时 → fallback gen.c HALF；补 seed pin 后 cold-seed rung 直接 `cc -c` → return 0；HALF 1→0；634 LOC；95 symbols × 13.8KB .o）


### 8.2 NON_PRODUCT（never-product-chain · 已正确分类 · 7 项）

> **wave332 收口**：`is_product_denominator()` 单权威 whitelist（G.7 禁止双口径漂移）。
> 以下 7 项**不计入 PRODUCT 分母**（never compiled/linked in product xlang/xlang-c chain），
> 保留在仓内或已物理删除均非 Track L 退役对象。

⚪ **8.2.1 ~~parser_gen.c~~** → 见 8.1.20（wave329 Track L 退役）

⚪ **8.2.2 ~~lexer_gen.c~~** → 见 8.1.19（wave328 Track L 退役）

⚪ **8.2.3 ~~ast_gen2.c~~** → 见 8.1.23（wave331 Track L 退役）

⚪ **8.2.4 ~~typeck_gen.c~~** → 见 8.1.21（wave329 Track L 退役）

⚪ **8.2.5 ~~codegen_gen.c~~** → 见 8.1.22（wave329 Track L 退役）

⚪ **8.2.6 ~~lsp_diag_gen.c~~** → 见 8.1.14（wave327 Track L 退役）

✅ **8.2.7 ~~lsp_io_gen.c~~** 已退役 → 见 8.1.9（wave1036）

⚪ **8.2.8 ~~lsp_gen.c~~** → 见 8.1.15（wave327 Track L 退役）

⚪ **8.2.9 ~~driver_gen.c~~** → 见 8.1.17（wave328 Track L 退役）

⚪ **8.2.10 ~~preprocess_gen.c~~** → 见 8.1.18（wave328 Track L 退役）

⚪ **8.2.11 ~~pipeline_gen.c~~** → 见 8.1.16（wave328 Track L 退役）

🔵 **8.2.12 token_gen.c** NON_PRODUCT STAGE（19 LOC · `seeds/token_gen.linux.x86_64.c`）

  - token：src/lexer/token.x（prove 锁 nm 面 · 见 3.2.1）
  - **wave332 分类**：stage1 verify-only（`verify-selfhost-stage1` 每次重新生成；never compiled/linked in product xlang/xlang-c chain）

💀 **8.2.13 ~~ast_gen.c~~** NON_PRODUCT DEAD_ORPHAN（已 wave330 物理删）

  - AST 池 v1：src/ast/ast.x
  - **wave330 物理删**：808 LOC stage1 orphan（零编译/链引用；ensure_ast_gen2.sh 只管 ast_gen2；grep `ast_gen` 子串命中 ensure_owner 是误判）
  - 与 ast_gen2.c 并存非「双版本」（G.7 不违规）：ast_gen.c 是 stage1 v1 孤儿，ast_gen2.c 是 v2 产品权威

✅ **8.2.14 ~~build_gen.c~~** 已退役 → 见 8.1.10（wave1038）

✅ **8.2.15 ~~build_runner_gen.c~~** 已退役 → 见 8.1.11（wave1039）

✅ **8.2.16 ~~build_runtime_x_gen.c~~** 已退役 → 见 8.1.12（wave1040）

✅ **8.2.17 ~~cfg_eval_gen.c~~** 已退役 → 见 8.1.13（wave1041 bespoke ladder）

🔵 **8.2.18 lsp_gen_full.c** NON_PRODUCT EXTRACT_ONLY（1072 行 · 非 *_gen.c 命名）

  - lsp 完整版变体
  - **wave332 分类**：`extract_lsp_gen_seeds.sh` 提取 lsp_gen / lsp_io_gen 考古 pin 的**种子源**；文件本身**不编译不链接**；never in product chain；保留作为提取源（不能删）

🔵 **8.2.19 token_gen2.c** NON_PRODUCT STAGE（466 行 · gen2 变体）

  - token v2：与 token_gen.c 并存
  - **wave332 分类**：stage2 verify artifact（never compiled/linked in product chain）

💀 **8.2.20 ~~lexer_gen2.c~~** NON_PRODUCT DEAD_ORPHAN（已早删）

  - gen2 变体占位空文件
  - **wave332 分类**：stage1 orphan 早删（never tracked in product chain）

🔵 **8.2.21 parser_gen_test.c** NON_PRODUCT TEST（5383 行 · 测试用 pinned）

  - parser 测试生成器
  - **wave332 分类**：pure-test harness（never compiled/linked in product xlang/xlang-c chain）

🔵 **8.2.22 typeck_gen_test.c** NON_PRODUCT TEST（249 行 · 测试用 pinned）

  - typeck 测试生成器
  - **wave332 分类**：pure-test harness（never compiled/linked in product xlang/xlang-c chain）

### 8.3 非 gen 产品 C / 链接桩（原文档大漏 · **删 Makefile 体积主债**）

> **定义**：不叫 `*_gen.c`，但 **产品链 / bootstrap-driver-seed / g05** 仍 `$(CC) -c` 的 C 体与符号桩。  
> **规模（2026-07-29 初测）**：glue+ast_pool 系曾 **~60k LOC**。  
> **规模（2026-08-04 刷新）**：`pipeline_glue.c` **~3.4k** + `ast_pool.c` **~0.18k** host 壳 + 已抽出 domain 叶合计仍大（同 TU `#include` 入 `pipeline_x`，**仍 host-cc**）；不离 host-cc 则 **BC 终局未达成**。  
> **G.7**：glue 与 typeck.x / codegen.x 禁止长期双权威；迁时同 commit 收敛。  
> **地图用途**：动 8.3 前先查消费方，禁止只改一端。  
> **勾选语义**：域 thin「已抽出」= ✅ 子项；**整项 8.3.x 离 host-cc** 才把父项改 ✅。

#### 8.3 体积地图（主债文件 · 2026-08-04 实测 LOC）

| 文件（compiler/） | LOC | 角色 | 状态 |
|-------------------|-----|------|------|
| `pipeline_glue.c` | **0（deleted）** | 产品 mega glue 壳 | ✅ **wave309 structure floor leave**（0 body · product pure-ld 无 mega · 文件删） |
| `pipeline_glue_early_fwd.c` | **0（deleted）** | glue early fwd | ✅ wave309 leave |
| `pipeline_glue_mid_fwd.c` | **0（deleted）** | glue mid fwd | ✅ wave309 leave |
| `pipeline_glue_backend_fwd.c` | **0（deleted）** | glue backend fwd | ✅ wave309 leave |
| `pipeline_glue_typeck_fwd.c` | **0（deleted）** | glue typeck fwd | ✅ wave309 leave |
| `pipeline_glue_typeck_mid_fwd.c` | **0（deleted）** | glue typeck mid fwd | ✅ wave309 leave |
| `pipeline_glue_emit_fwd.c` | **0（deleted）** | glue emit fwd | ✅ wave309 leave |
| `pipeline_glue_emit_block_fwd.c` | **0（deleted）** | glue emit block fwd | ✅ wave309 leave |
| `pipeline_glue_emit_lea_fwd.c` | **0（deleted）** | glue emit lea fwd | ✅ wave309 leave |
| `pipeline_glue_emit_mid_fwd.c` | **0（deleted）** | glue emit mid fwd | ✅ wave309 leave |
| `pipeline_glue_statics.c` | 0 | glue emit/typeck Cap residual pure-owned leave (wave261) | ✅ host-cc leave；末两 Cap 桥 glue_asm_ctx_set_scope_block／bind_module_dep_from_ctx＝runtime_pipeline_abi pure；BSS 时代 wave221–224 已收；early_fwd 仅 pure face extern |
| `pipeline_typeck_ctfe.c` | 0 | typeck CTFE Cap residual retired (wave255) | ✅ host-cc leave；权威 typeck_x.o thin→typeck_* |
| `pipeline_typeck_assign.c` | 0 | typeck assign Cap residual retired (wave256) | ✅ host-cc leave；权威 typeck_x.o thin→typeck_check_expr_assign／typeck_diag_* |
| `pipeline_typeck_orch.c` | **0（deleted）** | typeck orch 域 Cap residual thin | ✅ **seed ALWAYS leave**（wave285 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS（thin typeck_x_ast*_c + layout glue）；pure 拥有 soft_suppress／dep_ctx／dep_prerun 强符号；host 叶已删；present **27**（LOC−mega）；**双端 L2 绿** |
| `pipeline_typeck_check_expr.c` | **0（deleted）** | typeck check_expr 域 Cap residual thin | ✅ **seed ALWAYS leave**（wave286 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS（dispatch + match BSS + thin faces）；typeck.x 拥有 live typeck_check_expr_*；host 叶已删；present **27**（LOC−mega）；**双端 L2 绿** |
| `pipeline_parser_result.c` | **0（deleted）** | parser result copy/lex/slice Cap residual | ✅ **seed ALWAYS leave**（wave287 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS（slice／lex／result-copy faces + product LE layouts）；host 叶已删；present **27**（LOC−mega；ROWS 123→124）；**双端 L2 绿** |
| `pipeline_asm_label_format.c` | **0（deleted）** | asm label format Cap residual（format_u32／i32 + emit_next_label + format_label_id） | ✅ **seed ALWAYS leave**（wave288 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；deps ctx_layout + label_mod_scope_active；dual-export ban（pipeline_abi T · pipeline_x U）；host 叶已删；present **27**（LOC−mega；ROWS 124→125）；**双端 L2 绿** |
| `pipeline_codegen_outbuf.c` | **0（deleted）** | C-backend CodegenOutBuf append + float_lit + try_propagate | ✅ **seed ALWAYS leave**（wave289 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS（append_bytes／cstr + float_lit + try_propagate）；slice_init 权威＝codegen_x.o（OMIT_X_DUP；不进 ALWAYS）；strict_minimal float_lit 副本已删；dual-export ban（pipeline_abi T · pipeline_x 无 T）；host 叶已删；present **27**（LOC−mega；ROWS 125→126）；**双端 L2 绿** |
| `pipeline_asm_codegen_mega_body.c` | **0（deleted）** | asm codegen mega_body 主循环（ctx_reset_for_func + ast_to_elf_mega_body） | ✅ **seed ALWAYS leave**（wave290 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS（WPO／PGO emit 序 + LE AsmFuncCtx 全 overlay + Elf e_machine／reloc 偏移）；dual-export ban（pipeline_abi T · pipeline_x 无 T）；host 叶已删；present **27**（LOC−mega；ROWS 126→127）；**双端 L2 绿** |
| `pipeline_elf_codegen_forwarders.c` | **0（deleted）** | elf/codegen prefix rename shims（18）+ sizeof_elf_ctx | ✅ **seed ALWAYS leave**（wave291 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS（platform.elf／codegen／pipeline rename + LP64 fixed sizeof）；pure ELF + codegen_x 未前缀 callee；dual-export ban（pipeline_abi T · pipeline_x 无 T）；host 叶已删；present **27**（LOC−mega；ROWS 127→128）；**双端 L2 绿** |
| `pipeline_typeck_coerce_init.c` | 0 | typeck coerce-init Cap residual retired (wave258) | ✅ host-cc leave；权威 typeck_x.o thin→coerce／type_refs／widen／ret_coerce／int_lit／assign-kind；float_bits → ast_pool_arena |
| `pipeline_typeck_method_call.c` | 0 | typeck method_call Cap residual retired (wave260) | ✅ host-cc leave；Cap faces typeck_x.o：method_call_c／apply_call_resolve／import thin；call-resolve + METHOD_CALL accessors＝ast_pool_expr_sidecar |
| `pipeline_typeck_check_block.c` | 0 | typeck check_block Cap residual retired (wave259) | ✅ host-cc leave；权威 typeck_x.o：ctx／depth／linear／has_implicit／check_block*_c Cap + pure BSS；walker＝`typeck_check_block*` |
| `pipeline_typeck_region_assign.c` | 0 | typeck region/escape Cap residual retired (wave257) | ✅ host-cc leave；权威 typeck_x.o thin→typeck_check_slice／return／stack_escape／scope_borrow／allocator／call_slice |
| `pipeline_asm_emit_unary.c` | ~279 | asm ELF unary emit（NEG/LOGNOT/BITNOT + sxt/jz） | ✅ wave133 pure-owned leave；live＝runtime_pipeline_abi pure |
| `pipeline_asm_emit_as.c` | **0（leave）** | asm ELF as/await/try/float-lit emit（is_await／is_x_as／await_sync／try／float_lit／array_scalar／as_elf） | ✅ wave138 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删；float_bits＋glue_arena Cap residual in ast_pool_arena |
| `pipeline_asm_emit_modlet.c` | **0（leave）** | asm ELF modlet COMMON cell emit（table + load/store/prepare/seed/register） | ✅ wave139 pure-owned leave；live＝runtime_pipeline_abi pure bag BSS；seed cold twin under #ifndef FROM_X；host 叶已删 |
| `pipeline_asm_emit_return.c` | **0（leave）** | asm ELF EXPR_RETURN emit（slice escape + impl + sret + float promote + return_expr/lit） | ✅ **pure-owned leave**（wave144 · 2026-08-05）；live＝runtime_pipeline_abi pure；Cap residual expr_rec+float_widen+enc slot+dual-gp+type_size+spills；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_logand.c` | ~102 | asm ELF LOGAND/LOGOR short-circuit emit 切片 | ✅ wave128 pure-owned leave；live＝runtime_pipeline_abi pure；host 叶已删 |
| `pipeline_asm_emit_block_body.c` | **0（leave）** | asm ELF block body sync emit（defer + body_sync + accessors） | ✅ wave153 pure-owned leave（0 absent）；live＝runtime_pipeline_abi pure；Cap residual spill live/Chaitin BSS + set_scope + ctx_reset；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_block_if_stmt.c` | ~106 | asm ELF block-level if-stmt emit（then-first jz）切片 | ✅ wave129 pure-owned leave；live＝runtime_pipeline_abi pure；host 叶已删 |
| `pipeline_asm_emit_async_cps.c` | ~240 | asm ELF async/CPS emit（entry/end/await/phase_reset + bag） | ✅ wave131 pure-owned leave；live＝runtime_pipeline_abi pure bag BSS；host 叶已删 |
| `pipeline_asm_emit_wpo_mono.c` | ~235 | WPO-S2 mono thunk bag + emit（reset/register/thunks） | ✅ wave130 pure-owned leave；live＝runtime_pipeline_abi pure bag BSS；host 叶已删 |
| `pipeline_asm_emit_block_inits.c` | 0 | asm ELF block const/let init emit 切片 | ✅ wave145 pure-owned leave（0 absent） |
| `pipeline_asm_emit_assign.c` | **0（leave）** | asm ELF EXPR_ASSIGN emit（lhs f32 + rhs + assign_rhs_to_rax + assign_elf + field_assign_pair + body_expr_stmt_at） | ✅ wave142 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删 |
| `pipeline_asm_emit_array_lit.c` | **0（leave）** | asm ELF EXPR_ARRAY_LIT emit（elem_sz + empty + force_esz + durable + temp_bytes + elem_type_ref） | ✅ **pure-owned leave**（wave143 · 2026-08-05）；live＝runtime_pipeline_abi pure；Cap residual leaf/flat vector_let static→extern；**al_nc_seq_take pure wave219**；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_index.c` | **0（leave）** | asm ELF INDEX/ADDR_OF/DEREF + esz | ✅ wave140 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删 |
| `pipeline_asm_emit_match.c` | **0（leave）** | asm ELF MATCH／EXPR_IF emit（arm cmp+jeq + if jz）切片 | ✅ wave134 pure-owned leave；live＝runtime_pipeline_abi pure（match_elf + expr_if_elf + subject BSS）；host 叶已删 |
| `pipeline_asm_emit_x86_enc_helpers.c` | **0（leave）** | x86_64 fold micro-encoders（27 glue_enc_x86_* + lcg_xor body） | ✅ wave135 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删；fold_count_up_while 经 extern 调 pure |
| `pipeline_asm_emit_fold_primitives.c` | **0（leave）** | fold pattern detectors（13 glue_fold_*/glue_is_assign_*） | ✅ wave136 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删；fold_count_up_while 经 extern 调 pure；Cap residual pool + as/param helpers |
| `pipeline_asm_emit_panic.c` | **0（leave）** | asm ELF PANIC／int div-zero face（xlang_panic_call + panic_elf + div0） | ✅ **pure-owned leave**（wave127 · 2026-08-05）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_field_access.c` | **0（leave）** | asm ELF FIELD_ACCESS emit（layout_by_name + call_arg + call_base + var + fast + layout/offset + enum/soa）切片 | ✅ wave151 pure-owned leave（0 absent）；live＝runtime_pipeline_abi pure；Cap residual struct_lit layout index/compute + call_args dual-GP/pass_addr + soa addr；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_expr_rec.c` | **0（leave）** | asm ELF expr recursion + fast（lit_i32 + rec + emit_expr_elf_c + fast + match field-var） | ✅ wave152 pure-owned leave（0 absent）；live＝runtime_pipeline_abi pure；Cap residual pool accessors→`ast_pool_expr_sidecar` + int→IEEE pack；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_binop.c` | **0（leave）** | asm ELF EXPR_BINOP emit（arith/bitwise/shift + residual scalar/ptr/add + try_binop load/placement）切片 | ✅ wave149 pure-owned leave（0 absent）；live＝runtime_pipeline_abi pure；Cap residual spill cache accessors + f32 VAR load + field_access_fast；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_cmp.c` | **0（leave）** | asm ELF relational CMP emit（eq/ne/lt/le/gt/ge + enum RHS + f32/f64/int finish） | ✅ wave137 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删；field_access 经 pure typekind |
| `pipeline_asm_emit_call_args.c` | **0（leave）** | asm ELF CALL-arg emit（named_struct + resolve + f32 slot + lea + dual-GP + named layout + for_call_args）切片 | ✅ wave218 host-cc leave（0 absent）；wave190–217 pure leave 后 prototype-only shell 已删；live＝runtime_pipeline_abi pure |
| `pipeline_asm_emit_struct_lit.c` | **0（leave）** | asm ELF STRUCT_LIT emit（field_store_sz + rehome + fields + layout registry + typeck warn）切片 | ✅ wave154 pure-owned leave（0 absent）；live＝runtime_pipeline_abi pure；Cap residual soa/type_size_from_layout + dual_gp/named_layout + enc + diagnostics；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_vector_let.c` | 0 | asm ELF vector_let／fixed-array field store 切片 | ✅ wave146 pure-owned leave（0 absent） |
| `pipeline_asm_emit_vector_simd.c` | 0 | asm ELF SIMD vector lane／shuffle／select／fma emit domain 切片 | ✅ wave148 pure-owned leave（0 absent）；live＝runtime_pipeline_abi pure；Cap residual enc＋simd_enc＋CTFE typeck 调用 pure faces |
| `pipeline_asm_emit_struct_let.c` | ~215 | asm ELF struct let-init（struct_let_init + type_let_init + sret shift）切片 | ✅ wave132 pure-owned leave；live＝runtime_pipeline_abi pure；host 叶已删 |
| `pipeline_asm_emit_index_helpers.c` | **0（leave）** | asm ELF INDEX residual helpers（extern pure faces）切片 | ✅ wave218 host-cc leave（0 absent）；wave178–209 pure 后 prototype shell 已删；live＝runtime_pipeline_abi pure |
| `pipeline_asm_emit_spill.c` | **0（leave）** | asm ELF 7.3 live／Chaitin Cap residual | ✅ wave218 host-cc leave（0 absent）；wave156–215 pure 后 prototype shell 已删；live＝runtime_pipeline_abi pure |
| `pipeline_asm_emit_index_eff_addr.c` | 0 | asm ELF INDEX eff-addr（scaled＋bounds＋base／public faces）切片 | ✅ wave147 pure-owned leave（0 absent）；live＝runtime_pipeline_abi pure；Cap residual try_index forest static→extern |
| `ast_pool.c` | **0（deleted）** | AST 池 host 壳 | ✅ wave309 structure floor leave |
| `pipeline_asm_emit_heavy_env.c` | 0（absent） | EMIT_HEAVY 阈值／env／path／whitelist／prefix | ✅ pure-owned leave（runtime_pipeline_abi pure；Cap residual top_level_let／expr／driver_get；parser_emit_heavy 保留 typedef） |
| `pipeline_backend_asm_wrapper.c` | ~96 | M8-tail `asm_codegen_ast`／`to_elf` 薄包装 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_scratch_bufs.c` | **absent** | codegen path/prefix scratch 缓冲池 | ✅ **host-cc leave**（2026-08-05）：live 面在 codegen_x.o（seed）；文件 absent |
| `ast_pool_module_import.c` | **0（leave）** | module ImportEntry Cap residual pure-owned leave (wave263) | ✅ host-cc leave；权威 runtime_pipeline_abi pure multi-module map（wave110）+ faces；seed cold twins under #ifndef FROM_X；same-TU pure face decls |
| `ast_pool_struct_layout.c` | **0（leave）** | module StructLayout Cap residual pure-owned leave (wave266) | ✅ host-cc leave；权威 runtime_pipeline_abi pure multi-module map + fields/tp + sizing faces；seed cold twins under #ifndef FROM_X；same-TU pure face decls |
| `ast_pool_top_level.c` | **0（leave）** | module TopLevelLetEntry Cap residual pure-owned leave (wave265) | ✅ host-cc leave；权威 runtime_pipeline_abi pure multi-module map + faces + hoist／sum；seed cold twins under #ifndef FROM_X；same-TU pure face decls；prepend_lets Cap non-static |
| `ast_pool_type_alias.c` | **0（leave）** | module TypeAliasEntry Cap residual pure-owned leave (wave262) | ✅ host-cc leave；权威 runtime_pipeline_abi pure multi-module map + faces；lifecycle reset／release 钩 pure；seed cold twins under #ifndef FROM_X |
| `ast_pool_expr_sidecar.c` | **0（deleted）** | expr (+ type-pos) var-len sidecar 切片 | ✅ **seed ALWAYS leave**（wave278 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；host 叶已删；present **32→31**；**mac L2 绿** |
| `ast_pool_module_enum.c` | **0（leave）** | module ModuleEnumEntry Cap residual pure-owned leave (wave264) | ✅ host-cc leave；权威 runtime_pipeline_abi pure multi-module map + faces + try_mark；seed cold twins under #ifndef FROM_X；same-TU pure face decls |
| `ast_pool_onefunc.c` | **0（deleted）** | OneFunc sidecar + fill_from_onefunc residual | ✅ **seed ALWAYS leave**（wave281 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；host 叶已删；present **29→28**；**双端 L2 绿** |
| `ast_pool_dep_ctx.c` | **~0** | PipelineDepCtx Cap pure leave wave272（bodies runtime_pipeline_abi；DepCtxSidecar pure BSS） | ✅ **absent** pure leave · inventory present **36**（wave273 后） |
| `ast_pool_module_func.c` | **0（deleted）** | module Func cold accessors + param sidecar residual | ✅ **seed ALWAYS leave**（wave280 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；host 叶已删；present **30→29**；**双端 L2 绿** |
| `ast_pool_arena.c` | **0（deleted）** | ASTArena main-pool cold accessors 切片 | ✅ **pure-owned leave**（wave276 · 2026-08-08）；live＝runtime_pipeline_abi pure ptr/alloc/write/init + seed always-C by-value get/set_copy/float；cold twins under #ifndef FROM_X；host 叶已删；dual-export ban；present **34→33**；**双端 L2 绿** |
| `ast_pool_block.c` | **0（deleted）** | block append/region/defer/loop/labeled/getters/parent/resolve/stmt_order residual | ✅ **seed ALWAYS leave**（wave277 · 2026-08-08）；live＝runtime_pipeline_abi.from_x WAVE277 ALWAYS；host 叶已删；present **33→32**；**双端 L2 绿** |
| `pipeline_typeck_field_access.c` | **~218** | field_access **全 thin**（同 TU 入 glue） | 🟡 **已抽出**；**.x 权威收口**（含 bare-import-const）；仍 host-cc |
| `pipeline_typeck_soa.c` | **~82** | typeck SOA **全 thin**（extern + fill/soa_index 转调） | 🟡 **已抽出**；**.x 权威收口**；仍 host-cc |
| `pipeline_elf_write_o.c` | **0（leave）** | ELF64 ET_REL + Mach-O MH_OBJECT `.o` writers | ✅ wave273 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删 |
| `pipeline_elf_ctx.c` | **0（leave）** | ELF/Mach-O codegen ctx accessors + PGO-Lite + reloc/label/patch/shndx/common sidecar | ✅ wave273 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删 |
| `pipeline_codegen_type_to_c.c` | **0（deleted）** | TypeKind/VECTOR → C type name repr（type_kind_copy/append + vector_type_copy + type_to_c_repr） | ✅ **pure-owned leave**（2026-08-05 wave109）；live＝`runtime_pipeline_abi` pure；seed cold twin under #ifndef FROM_X；host-cc 叶已删；struct_emit 改调 public type_to_c_repr |
| `pipeline_codegen_skip_force.c` | **0（deleted）** | codegen skip/force/override/path 谓词 | ✅ **pure-owned leave**（2026-08-05 wave108）；live＝`runtime_pipeline_abi` pure；seed cold twin under #ifndef FROM_X；host-cc 叶已删 |
| `pipeline_codegen_struct_emit.c` | **~243** | C co-emit struct tag + outbuf append + struct field emit（struct_tag_try_claim + out_append_* + emit_struct_field_*） | 🟡 **已抽出**（8.3.2 wave1250）；仍 host-cc 入 `pipeline_x` |
| `pipeline_codegen_residual.c` | **0（deleted）** | codegen residual name/predicate + io.core/driver symbol rewrite | ✅ **pure-owned leave**（2026-08-05 wave107）；live＝`runtime_pipeline_abi` pure；seed cold twin under #ifndef FROM_X；host-cc 叶已删 |
| `pipeline_asm_wpo.c` | **0（deleted）** | asm WPO v0 DCE + PGO-Lite reach/emit order（AsmWpoReachState + reach BFS + PGO hot/depth + should_emit_func + emit_order） | ✅ **pure-owned leave**（wave274 · 2026-08-08）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host-cc 叶已删；dual-export ban；present **36→35**；**双端 L2 绿** |
| `pipeline_asm_selfhost.c` | **0（leave）** | asm module self-host classification（num_defined_funcs/defined_func_ordinal + is_backend/typeck/pipeline/main_driver/driver_compile/parser/parser_emit_heavy/ast/compiler · 9 谓词全） | ✅ **pure-owned leave**（wave115 · 2026-08-05）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；残差 skip/wpo/heavy 经 extern |
| `pipeline_asm_thin_delegate.c` | **0（leave）** | asm M8-tail thin delegate 查表（AsmBackendThinDelegateRow + k_asm_backend／k_asm_pipeline／k_asm_parser／k_asm_driver／k_asm_typeck_thin_delegate + backend／pipeline／driver／typeck_m8_tail_thin_delegate_c_name · 五表全） | ✅ **pure-owned leave**（wave116 · 2026-08-05）；live＝runtime_pipeline_abi pure（4 accessor inline-literal unroll + asm_thin_delegate_emit helper）；k_asm_parser 表＋2 consumer 整体迁 pipeline_asm_parser_emit_heavy.c；asm_env_entry_emit_heavy 去 static 供 pure extern；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_heavy_safe_helper.c` | **0（leave）** | asm EMIT_HEAVY 第二遍 per-module 分类器（typeck／pipeline／driver_compile_safe_helper + skip_heavy_backend_m8/helper_keep + skip_heavy_backend_m8_tail_thin_keep／typeck_helper_keep／backend_mega_entry／typeck_mega_entry · 9 fn · skip_heavy 全集） | ✅ **pure-owned leave**（wave117 · 2026-08-05）；live＝runtime_pipeline_abi pure（9 fn 名匹配 inline 链，0 字段访问；3 C 宏 generator 展开）；pipeline_module_func_name_has_prefix_at 去 static 供 pure extern；seed cold twin under #ifndef FROM_X；skip_dispatch 经 extern 重连 |
| `pipeline_asm_parser_emit_heavy.c` | **0（leave）** | asm parser EMIT_HEAVY 域（slot/bisect/debug + mega_skip + force_stub + safe_helper + thin_delegate/m8_tail + resolve_call + callee_local） | ✅ **pure-owned leave**（wave120 · 2026-08-05）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_diag.c` | **absent** | asm 诊断域（已删） | ✅ **host-cc leave**（2026-08-05）：pure-complete start_func_skip + BODY/FUNC_TRACE；live＝runtime_pipeline_abi；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_skip_dispatch.c` | **0（leave）** | asm 桩化/skip dispatch 域（asm_empty_text_stub_label + asm_skip_heavy_module_func_body · 2 fn） | ✅ **pure-owned leave**（wave118 · 2026-08-05）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；set_pipeline_ctx BSS 同迁 pure；残差 env／parser_heavy 经 Cap residual |
| `pipeline_resolve_path.c` | **0（deleted）** | import 路径解析／CodegenOutBuf.len 读写 | ✅ **pure-owned leave**（2026-08-05 wave105）；live＝`runtime_pipeline_abi` pure（path_append_*_c／probe／flat／off-sidecar／codegen_out_buf_*／resolve_path_x_impl_c|_c）；seed cold twin under #ifndef FROM_X；host-cc 叶已删 |
| `pipeline_emit_sidecar.c` | **0** | emit sidecar 状态域（driver_emit_lib_root_* + asm_qual_sym_layer_*） | ✅ **host-cc leave 2026-08-05** live＝runtime_pipeline_abi pure 固定容量 BSS；file absent；bc residual **103** |
| `pipeline_preprocess_if.c` | **absent** | preprocess #if 嵌套栈 cold GrowVec twin（已删） | ✅ **host-cc leave**（2026-08-05）：pure-owned WEAK cold delete-only；live 面 runtime_pipeline_abi 固定 i32[32]；strict companion 自 pure `.o` partial-export |
| `pipeline_typeck_slots.c` | **absent** | typeck scratch/call-resolve/overload/layout-metrics BSS 访问器 | ✅ **host-cc leave**（2026-08-05）：live 面在 typeck_x.o（seed）；文件 absent |
| `pipeline_codegen_dep.c` | **~504** | codegen dep 编排域（run_x_pipeline_codegen_one_dep_emit／entry_emit／one_dep_c／deps_c／entry_c + debug_dump_std_heap_trace + dep 路径填充 + 去重/mono arena） | 🟡 **已抽出**（8.3.2）；extern 本块内声明；无先于 include 的调用方；仍 host-cc 入 `pipeline_x` |
| `pipeline_lsp_diag.c` | **absent** | LSP 诊断 C glue（typeck_after_load／parse_entry／parse_typeck + large-stack） | ✅ **host-cc leave**（2026-08-05）：live＝runtime_pipeline_abi pure；文件 absent；parse_orch `_impl_c` 仍转调 pure 面 |
| `pipeline_import_bind.c` | **absent** | fs 读 + import bind/sync（已删） | ✅ **host-cc leave**（2026-08-05）：pure-complete remaining strong + pure-owned WEAK delete-only；live＝runtime_pipeline_abi；seed cold twin under #ifndef FROM_X |
| `pipeline_parse_typeck_dispatch.c` | **~465** | parse entry + typeck 分派 + import load 域（parse_scalars + should_skip_x_typeck + parse_into_with_init_*_scalars + parse_apply/set_main + typeck_parsed/entry_module_c + realign_ndep + load_import_resolve_read／load_one_import_slot／load_and_sync_direct_import_deps_c + 共享 extern 头） | 🟡 **已抽出**（8.3.2）；公共符号 + XLANG_WEAK + static scalars；无先于 include 调用方；仍 host-cc 入 `pipeline_x` |
| `pipeline_run_x_pipeline.c` | **0（deleted）** | run_x_pipeline 核心编排骨域（last_rc／typeck_fail／parse／typecheck emit／const-buf face） | ✅ **pure-owned leave**（2026-08-05 wave106）；live＝`runtime_pipeline_abi` pure；seed cold twin under #ifndef FROM_X；host-cc 叶已删 |
| `pipeline_loop_glue.c` | **absent** | 有界循环谓词 + dep prepare glue 域 | ✅ **host-cc leave**（2026-08-05）：live 面在 codegen_x.o（seed）；文件 absent |
| `ast_pool_lifecycle.c` | **0（deleted）** | ast 池生命周期/reset/release 域 | ✅ **seed ALWAYS leave**（wave279 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；module_func 收纳 static helpers；host 叶已删；present **31→30**；**双端 L2 绿** |
| `pipeline_asm_emit_with_arena.c` | **0（leave）** | with_arena scope stack-arena emit（active/top_off + begin_func/alloc/push/pop + init/deinit） | ✅ **pure-owned leave**（wave122 · 2026-08-05）；live＝runtime_pipeline_abi pure；arm64 init 参数序根修；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_var_decl.c` | **0（leave）** | asm ELF VAR type-ref + lazy block-let append | ✅ **pure-owned leave**（wave124 · 2026-08-05）；live＝runtime_pipeline_abi pure；Cap residual emit context + local/slot；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_ctx_layout.c` | **0（leave）** | AsmFuncCtx layout cast (identity) | ✅ **pure-owned leave**（wave125 · 2026-08-05）；live＝runtime_pipeline_abi pure；**typedef 仍 pipeline_glue.c 壳**（residual C ly->field）；seed cold twin under #ifndef FROM_X |
| `pipeline_asm_emit_next_offset.c` | **0（leave）** | asm_func_ctx next_offset align + bump after array-lit / let-init（same-TU 域） | ✅ **pure-owned leave**（wave126 · 2026-08-05）；live＝runtime_pipeline_abi pure；Cap residual `glue_array_temp_bytes_for_let_init`（array_lit static→extern）；seed cold twin under #ifndef FROM_X；inventory 未单列（同 TU #include） |
| `pipeline_asm_emit_lea_common.c` | **0（leave）** | asm ELF COMMON label lea + arm64 sret mov（lea rax/rbx rip_x86 + adrp_arm64 + mov x0↔x8） | ✅ **pure-owned leave**（wave123 · 2026-08-05）；live＝runtime_pipeline_abi pure；array_lit static→extern；seed cold twin under #ifndef FROM_X |
| `pipeline_lint_meta.c` | **0（leave）** | pipeline lint + module metadata glue 域（XLANG_VISIBILITY + L7 unused-private + module_num_funcs／main／reset／strict_parse） | ✅ **pure-owned leave**（wave121 · 2026-08-05）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X |
| `pipeline_grow_vec.c` | **~0** | GrowVec pure-owned leave wave271（bodies runtime_pipeline_abi；typedef in ast_pool_typedefs） | ✅ **absent** pure leave · inventory present **36**（wave273 后） |
| `ast_pool_typedefs.c` | **0（deleted）** | AST pool typedef 域 | ✅ wave309 structure floor leave |
| `ast_pool_ptr_at.c` | **0（deleted）** | core pointer accessors（static block_at／module_layout_at／module_import_at） | ✅ **dead leave wave298**（domain leave 后零 residual 调用方；block Cap＝`w277_block_at`；host 叶已删；present **15→14**；**双端 L2 绿**） |
| `ast_pool_sidecar_pool.c` | **0（deleted）** | sidecar 池管理域（MAX_*_SIDECARS + g_arena/module/onefunc 全局 + sidecar_get/free） | ✅ **pure-owned leave**（wave275 · 2026-08-08）；live＝runtime_pipeline_abi pure BSS `g_pipe_*_sc_blob` + get/free；seed cold twin under #ifndef FROM_X；host 叶已删；dual-export ban；present **35→34**；**双端 L2 绿** |
| `pipeline_asm_codegen_mega_body.c` | **0（deleted）** | asm codegen mega_body 主循环 | ✅ **seed ALWAYS leave**（见上表 8.3.2 行） |
| `pipeline_parse_orch.c` | **0（deleted）** | parse/load/typeck 编排 | ✅ **seed ALWAYS leave**（wave284 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；host 叶已删；present **27**（LOC−mega）；**双端 L2 绿** |
| `pipeline_typeck_orch.c` | **0（deleted）** | typeck orch Cap residual thin | ✅ **seed ALWAYS leave**（wave285 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；host 叶已删；present **27**（LOC−mega）；**双端 L2 绿** |
| `pipeline_ast_forwarders.c` | **0（deleted）** | ast_pipeline_* rename shims | ✅ **seed ALWAYS leave**（wave283 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；host 叶已删；present **27**（LOC−mega）；**双端 L2 绿** |
| `pipeline_elf_codegen_forwarders.c` | **0（deleted）** | elf/codegen 前缀 forwarder | ✅ **seed ALWAYS leave**（host 叶已删；present **27** LOC−mega；**双端 L2 绿**） |
| `pipeline_asm_emit_context.c` | **0（leave）** | asm emit context set/get + frame/param/local slots | ✅ wave141 pure-owned leave；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；host 叶已删 |
| `ast_pool_bootstrap_glue.c` | **0（deleted）** | 冷启动 ast 桥 residual | ✅ **seed ALWAYS leave**（wave282 · 2026-08-08）；live＝runtime_pipeline_abi seed ALWAYS；host 叶已删；present **28→27**；**双端 L2 绿**；**pipeline_x mega 首刀／8.3.4** |
| `pipeline_bootstrap_orchestration.c` | **0（deleted）** | 编排 host 占位（5 行 seed include） | ✅ **host wrapper leave**（产品 ensure 直编 seed → `.o`；host 叶已删；present **27→26**；**双端 L2 绿**；**8.3.4 残收口**） |
| `pipeline_glue_strict_minimal`（seed → 产品链） | **0（deleted）** | 产品 seed 壳 | ✅ **shell retire**（0 T 后物理删 seed；产品 g05 摘链／停 ensure；inventory absent；present **14→13**；**双端 L2 绿**） |
| bare link alias / stubs 族 | 小 | 5× seed host wrappers **deleted**；cold `_stubs.c`／`xlang_x_stubs.c`／`_x_stubs2.c` **deleted**（权威 `seeds/x_stubs.from_x.c`；B4 GEN_C_TO_O 4 叶）；`typeck_asm_bare_link_alias` host **deleted**（权威 `seeds/typeck_asm_bare_link_alias.from_x.c`）；scripts stubs host **deleted**（权威 `seeds/asm_text_stub.from_x.c` + `asm_xlang_lsp_diag_stub.from_x.c`） | ✅ **8.3.5 + 8.3.7 host leave**（产品／ensure seed-only；G05 不链 scripts host） |

#### 8.3 消费方地图（谁还拉 glue · 迁时必同改）

| 消费方 | 如何引用 | 风险 |
|--------|----------|------|
| `compiler/mk/x_source_deps.mk` `PIPELINE_X_DEPS` | glue + 8.3.1 切片（含 …／spill／call_args；block_body pure leave）+ `ast_pool` + 11× ast_pool domain slices + bootstrap glue | 改源必重编 pipeline_x |
| g05 / standalone seed 链 | standalone seed + glue + types.inc | weak 孪生与主链分叉 |
| `g05_ensure_relink_prereqs.sh` | mtime vs pipeline_x / standalone；切片 STALE | 产品热路径仍 host-cc 重编 |
| `pipeline_gen.c` / `-E` runtime 路径 | 入口 pipeline.x 时追加 glue 到 stdout | 与 gen 双权威风险 |
| `seeds/pipeline_glue_standalone.from_x.c` | 与 glue 并列产品链 | seed 与 .c 须同 commit |
| `build_asm/gen_driver/*.c`（10） | g05 + partial 脚本 | 物理在 compiler/ 外，易漏计 |
| bare alias / stubs `.c` | 链接安静桩 | 终局由 .x `#[no_mangle]` 取代 |

🟡 **8.3.1 `pipeline_glue.c` → .x（或按域切 thin + 唯一权威）**

  - 爆炸半径：几乎所有 typeck/codegen/asm 产品路径
  - 验收（父项 ✅ 条件）：产品链不再 host-cc 编 glue mega-TU；Ubuntu L4 + 129
  - **进度（2026-08-04）**：glue 文件 **~3.4k**；**业务 static 叶基本 fold 完**（残留 mainly `#include` + 极薄 wrapper）；**父项仍 🟡**（未离 host-cc）
  - ✅ CTFE 域 thin：`pipeline_typeck_ctfe.c`（const whitelist + fold 生产者）自 glue 同 TU `#include` 抽出
  - ✅ assign 域 thin：`pipeline_typeck_assign.c`（lit i16/u16 收窄 + `check_expr_assign` 生产者）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` / g05 STALE / inventory 已收
  - ✅ coerce_init 域 thin：`pipeline_typeck_coerce_init.c`（lit/float/enum/call/array｜vector/int binop/struct/slice + `coerce_init_expr_to_decl` 分发）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 23→24 / g05 STALE / inventory 已收
  - ✅ method_call 域 thin：`pipeline_typeck_method_call.c`（weak method_call + pattern-unify/mono-map/subst + generic UFCS）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 24→25 / g05 STALE / inventory 已收
  - ✅ check_block 域 thin：`pipeline_typeck_check_block.c`（block_impl ctx + loop/unsafe depth + check_block_impl_c + weak fallback + check_block_c + as_loop_body）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 25→26 / g05 STALE / inventory 已收
  - ✅ region-assign 域 thin：`pipeline_typeck_region_assign.c`（M-3 slice region + return slice + WPO-S3 stack-escape assign + MEM-A3 scope-borrow + MEM-C1 with_arena/allocator region）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 26→27 / g05 STALE / inventory 已收
  - ✅ asm unary emit 域 thin：`pipeline_asm_emit_unary.c`（NEG/LOGNOT/BITNOT + sxt/jz）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 27→28 / g05 STALE / inventory 已收
  - ✅ asm as/await/try/float-lit emit 域 thin：`pipeline_asm_emit_as.c` 自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 28→29 / g05 STALE / inventory 已收
  - ✅ asm return emit 域 thin：`pipeline_asm_emit_return.c`（slice escape finder + return_impl ~633 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 29→30 / g05 STALE / inventory 已收
  - ✅ asm logand·logor emit 域 thin：`pipeline_asm_emit_logand.c`（LOGAND/LOGOR short-circuit ~102 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 30→31 / g05 STALE / inventory 已收
  - ✅ asm block body sync emit 域 thin：`pipeline_asm_emit_block_body.c`（defer mask + body_sync + backend accessors ~809 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 31→32 / g05 STALE / inventory 已收
  - ✅ asm block-level if-stmt emit 域 thin：`pipeline_asm_emit_block_if_stmt.c`（then-first + jz / else / done + live merge ~106 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 32→33 / g05 STALE / inventory 已收
  - ✅ asm block const/let init emit 域 thin：`pipeline_asm_emit_block_inits.c`（const+let · VECTOR/SLICE/fixed-array/struct · empty dual-GP ~171 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 33→34 / g05 STALE / inventory 已收
  - ✅ asm EXPR_ASSIGN emit 域 thin：`pipeline_asm_emit_assign.c`（lhs f32 + rhs + assign_elf · FIELD/INDEX/VAR/DEREF · slice dual-GP / fixed-array / STRUCT_LIT index / esz>8 bulk · ~556 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 45→46 / g05 STALE / inventory 已收（wave995）
  - ✅ asm EXPR_ARRAY_LIT emit 域 thin：`pipeline_asm_emit_array_lit.c`（elem_byte_sz + empty + emit/force_esz · nested flat / SLICE dual-GP / >8B STRUCT / may_clobber re-lea · ~335 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 46→47 / g05 STALE / inventory 已收（wave996）
  - ✅ asm INDEX／ADDR_OF／DEREF emit 域 thin：`pipeline_asm_emit_index.c`（index_elem_byte_sz + emit_index + addr_of + deref · multi-dim／SLICE dual-GP／lea-slot／TYPE_ARRAY leave · ~434 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 47→48 / g05 STALE / inventory 已收（wave997）
  - ✅ asm MATCH／EXPR_IF emit 域 thin：`pipeline_asm_emit_match.c`（match_elf + expr_if_elf · arm cmp+jeq／wildcard join／RETURN skip · cond jz then／else · ~179 LOC）自 glue 同 TU `#include` 抽出；CALL／METHOD_CALL 仍 seed；`PIPELINE_X_DEPS` COUNT 48→49 / g05 STALE / inventory 已收（wave998）
  - ✅ asm PANIC／div-zero face thin：`pipeline_asm_emit_panic.c`（xlang_panic_call + panic_elf + panic_int_div_zero + divisor_zero_check_rbx · ~121 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 49→50 / g05 STALE / inventory 已收（wave999）
  - ✅ asm FIELD_ACCESS emit domain thin：`pipeline_asm_emit_field_access.c`（layout_by_name + call_arg struct／agg + call_base rvalue + var_field_access + field_access_elf_fast · ~583 LOC body）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 50→51 / g05 STALE / inventory 已收（wave1000）
  - ✅ asm BINOP emit domain thin：`pipeline_asm_emit_binop.c`（add／sub／mul／div／mod／and／bitwise／shift + unsigned／64bit + nested rax／rbx helpers · ~857 LOC body）自 glue 同 TU `#include` 抽出；panic include 前置；`PIPELINE_X_DEPS` COUNT 51→52 / g05 STALE / inventory 已收（wave1001）
  - ✅ asm relational CMP emit domain thin：`pipeline_asm_emit_cmp.c`（emit_cmp_elf + enum RHS tag + 64bit/rex + f32/f64/int finish · ~278 LOC body）自 glue 同 TU `#include` 抽出；typekind_variant_tag 仍 glue（field_access 共享）；`PIPELINE_X_DEPS` COUNT 52→53 / g05 STALE / inventory 已收（wave1002）
  - ✅ asm CALL-arg emit domain thin：`pipeline_asm_emit_call_args.c`（lea_not_load + dual-GP load_var + named layout size + pass_addr + for_call_args · ~792 LOC body／~831 file）自 glue 同 TU `#include` 抽出；resolve_* 仍 glue（leaf VAR 共享）；CALL／METHOD_CALL 仍 seed；`PIPELINE_X_DEPS` COUNT 53→54 / g05 STALE / inventory 已收（wave1003）
  - ✅ asm STRUCT_LIT emit domain thin：`pipeline_asm_emit_struct_lit.c`（field_store_sz + public wrapper + DEST_IN_RBX/rehome + fields + struct_lit_elf · ~444 LOC body／~484 file）自 glue 同 TU `#include` 抽出；store_fixed_array_field／vector_let 本波后进 vector_let 叶；`PIPELINE_X_DEPS` COUNT 54→55 / g05 STALE / inventory 已收（wave1004）
  - ✅ asm vector_let／fixed-array field store domain thin：`pipeline_asm_emit_vector_let.c`（leaf_elem_byte_sz + array_lit_flat + vector_let_init + field_frame_mag + store_fixed_array_field · ~645 LOC body／~686 file）自 glue 同 TU `#include` 抽出；glue_emit_fixed_array_type_let_init 仍 glue 薄包装；SIMD lane 仍 glue；`PIPELINE_X_DEPS` COUNT 55→56 / g05 STALE / inventory 已收（wave1005）
  - ✅ glue 静态叶迁移基本收口：剩余 static 为跨域基础设施（ctx_layout／arena accessor／var stack off／type kind 映射等），不宜再硬拆；业务 leaf 已 fold；文件 ~3.4k 多为 `#include`
  - ✅ asm mega_body 主循环域 thin：`pipeline_asm_codegen_mega_body.c`
  - ✅ asm loop_labels／slice_init／float_lit／region／call_slice_region／fill_soa／fill_array_lit 等续 fold（同 TU 入既有域文件）
  - ✅ dead fn + 冗余 fwd decl 清理（glue／ast_pool 零 caller 符号）
  - ✅ `#if 0` 死代码块物理删除（glue）
  - 🟡 仍 host-cc 编入 `pipeline_x`（未 .x 化 / 未离 host-cc）— **域 thin 子项 ✅ ≠ 父项 BC 完成**

🟡 **8.3.2 `ast_pool.c` → .x / 已有 ast.x 权威收敛**

  - MatchArm / GrowVec / module sidecar 与 parser pin 同生命周期
  - 验收（父项 ✅ 条件）：ast_pool 业务体不再 host-cc；与 ast.x 单权威
  - **进度（2026-08-04）**：core **~5.4k**；多域 thin 已切 + **ELF/Mach-O write 已切出** + **ELF ctx 已切出** + **type-to-c 已切出** + **skip/force 已切出** + **struct emit 已切出** + **codegen residual 已切出** + **asm locals/slot_bytes/block_tree/ctx_loop 已切出** + **WPO v0 DCE 已切出** + **self-host classification 已切出** + **M8-tail thin delegate 已切出** + **EMIT_HEAVY safe-helper 已切出** + **parser EMIT_HEAVY 已切出**；残余 core
  - ✅ module_import 域 thin：`ast_pool_module_import.c`（XLANG_WEAK ImportEntry cold twins ~208 LOC）自 `ast_pool.c` 同 TU `#include` 抽出；COUNT 34→35
  - ✅ module_import host-cc leave（wave263）：live＝runtime_pipeline_abi pure multi-module ImportEntry map（wave110）；seed cold twin under #ifndef FROM_X；file absent；same-TU pure face decls
  - ✅ struct_layout 域 thin：`ast_pool_struct_layout.c`（`pipeline_module_struct_layout_*` + num + type_param meta ~365 LOC）同 TU 抽出；COUNT 35→36 / g05 STALE / inventory 已收
  - ✅ top_level 域 thin：`ast_pool_top_level.c`（`pipeline_module_top_level_let_*` ~113 LOC）同 TU 抽出；COUNT 36→37 / g05 STALE / inventory 已收
  - ✅ type_alias 域 thin：`ast_pool_type_alias.c`（`pipeline_module_type_alias_*` + `num_type_aliases_at` ~80 LOC body）同 TU 抽出；COUNT 37→38 / g05 STALE / inventory 已收
  - ✅ type_alias host-cc leave（wave262）：live＝runtime_pipeline_abi pure multi-module TypeAliasEntry map；seed cold twin under #ifndef FROM_X；file absent
  - ✅ expr_sidecar 域 thin：`ast_pool_expr_sidecar.c`（call/method/match/struct_lit/array_lit + type_type_arg ~620 LOC body）同 TU 抽出；COUNT 38→39 / g05 STALE / inventory 已收
  - ✅ module_enum 域 thin：`ast_pool_module_enum.c`（`pipeline_module_enum_*` + expr/codegen enum field-access mark ~336 LOC body）同 TU 抽出；COUNT 39→40 / g05 STALE / inventory 已收
  - ✅ module_enum host-cc leave（wave264）：live＝runtime_pipeline_abi pure multi-module ModuleEnumEntry map（33932B LE）+ try_mark faces；seed cold twin under #ifndef FROM_X；file absent；same-TU pure face decls；present 47→46
  - ✅ top_level host-cc leave（wave265）：live＝runtime_pipeline_abi pure multi-module TopLevelLetEntry map（148B LE）+ name_is_const／hoist／hoist_target／sum_stack；seed cold twin under #ifndef FROM_X；file absent；same-TU pure face decls；prepend_lets Cap residual non-static；present 46→45
  - ✅ onefunc 域 thin：`ast_pool_onefunc.c`（const/let/param/call/while/for + copy_sidecar ~522 LOC body；`grow_vec_copy_append` 上提 core）同 TU 抽出；COUNT 40→41 / g05 STALE / inventory 已收
  - ✅ dep_ctx 域 thin→**pure leave wave272**：`ast_pool_dep_ctx.c` absent（`pipeline_dep_ctx_*`／`pipeline_ctx_lib_root_*`／`pipeline_dep_ctx_sidecar_release` · DepCtxSidecar pure BSS）；g05 STALE／inventory absent；live→runtime_pipeline_abi pure；sidecar_pool 不再挂 DepCtx 表；present **39→38**
  - ✅ module_func 域 thin：`ast_pool_module_func.c`（module Func alloc/flags/params/name_equal/byte + arena_func param_write/copy_slot · ~409 LOC body；static helpers + visibility/L7 + glue name/body 仍 core）同 TU 抽出；COUNT 42→43 / g05 STALE / inventory 已收
  - ✅ module_func 域 thin→**seed ALWAYS leave wave280**：`ast_pool_module_func.c` **absent**（pipeline_module_func_*／arena_func param_write|copy_slot／asm+arch_arm64 forwarders）；live＝runtime_pipeline_abi seed ALWAYS；typedef Cap face decls；g05 STALE／inventory absent；present **30→29**；**双端 L2 绿**（mac + Ubuntu `ubuntu-remote-server` @ `06b0ff801`）
  - ✅ lifecycle 域 thin→**seed ALWAYS leave wave279**：`ast_pool_lifecycle.c` **absent**（block_on_alloc／module|arena reset|release／drop_bodies／onefunc reset|release）；live＝runtime_pipeline_abi seed ALWAYS；module_func residual 收纳 static helpers；typedef Cap face decls；g05 STALE／inventory absent；present **31→30**；**双端 L2 绿**（mac + Ubuntu）
  - ✅ expr_sidecar 域 thin→**seed ALWAYS leave wave278**：`ast_pool_expr_sidecar.c` **absent**（call/method/match/struct_lit/array_lit + type_arg + Expr field Cap）；live＝runtime_pipeline_abi seed ALWAYS；typedef Cap face decls；FIELD_ACCESS=44；g05 STALE／inventory absent；present **32→31**；**双端 L2 绿**（mac + Ubuntu）
  - ✅ block 域 thin→**seed ALWAYS leave wave277**：`ast_pool_block.c` **absent**（append/getters/patch/resolve/stmt_order fixup）；live＝runtime_pipeline_abi seed ALWAYS；typedef Cap face decls；pure fixup 空 stub→export-extern；dual-export ban；g05 STALE／inventory absent；present **33→32**；**双端 L2 绿**（mac + Ubuntu `ubuntu-remote-server` @ `5a927c3c3`）
  - ✅ arena 域 thin→**pure leave wave276**：`ast_pool_arena.c` **absent**（ptr/alloc/caps/num_types/write_*/parser_library_init/fill_u8/init pure；by-value get/set_copy + float IEEE = seed always-C）；live＝runtime_pipeline_abi；typedef Cap face decls；dual-export ban；g05 STALE／inventory absent；present **34→33**；**双端 L2 绿**（mac + Ubuntu `ubuntu-remote-server` @ `1dfda4b5b`）
  - ✅ block 域 thin：`ast_pool_block.c`（block_pool_append_pos + append const/let/if/region/with_arena/unsafe/defer + region/defer accessors · ~297 LOC body）同 TU 抽出；COUNT 44→45 / g05 STALE / inventory 已收
  - ✅ block residual 有则补全：同文件迁入 append expr_stmt/stmt_order/while/for/labeled + static block_*_at + while/for/labeled/const/let/if/expr/stmt_order getters（~438 LOC；file ~763）；COUNT 仍 45；onefunc fill/resolve residual 仍 core
  - ✅ block parent／resolve residual 有则补全：同文件迁入 parent patch + resolve_var_type_ref／name_binding／local_redecl／find_var（~359 LOC；file ~1140）；COUNT 仍 45；`pipeline_arena_expr_ptr`；fill_* residual 仍 core
  - ✅ onefunc fill residual 有则补全：`ast_pool_onefunc.c` 迁入 defer/labeled/if/region/stmt_order + fill_*（defers/labeled/regions/ifs/stmt_order/expr_stmts/whiles/fors）（~438 LOC；file ~986）；COUNT 仍 45；module_top_level_name_is_const + stmt_order rebuild 仍 core（wave991）
  - ✅ stmt_order rebuild residual 有则补全：`ast_pool_block.c` insert/fixup/sparse_ifs/module_fixup（~299 LOC；file ~1439）；COUNT 仍 45；name_is_const + hoist 仍 core（wave992）
  - ✅ top_level name_is_const／hoist residual 有则补全：`ast_pool_top_level.c` 迁入 name_is_const + hoist_top_level_lets_into_main（~115 LOC；file ~249）；COUNT 仍 45；block 后 include 可见 static prepend_lets（wave993）
  - ✅ top_level hoist_target／sum residual 有则补全：`ast_pool_top_level.c` 迁入 `pipeline_asm_hoist_target_func_index` + `pipeline_asm_sum_module_top_level_lets_stack`（~77 LOC；file ~326）；COUNT 仍 45；modlet／slot helpers 仍 glue extern（wave994）
  - ✅ ELF/Mach-O `.o` writers 域 thin：`pipeline_elf_write_o.c`（standard + PGO ELF + macho + `platform_macho_write_macho_o_to_buf` · ~1.6k）；g05 STALE／inventory／`PIPELINE_X_DEPS` 已收
  - ✅ ELF ctx 域 thin→**pure leave wave273**：`pipeline_elf_ctx.c`＋`pipeline_elf_write_o.c` **absent**（ctx accessors＋PGO/Mach-O/ELF writers＋BSS sidecars）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；dual-export ban（pipeline_abi T · pipeline_x U）；g05 STALE／inventory absent；present **38→36**；**双端 L2 绿**（mac + Ubuntu `ubuntu-remote-server` @ `87291d0b2`）
  - ✅ codegen type-to-c 域 **pure-owned leave**：`pipeline_codegen_type_to_c.c` **deleted**（type_kind_copy/append + vector_type_copy + type_to_c_repr）；live＝`runtime_pipeline_abi` pure（wave109 2026-08-05）；seed cold twin under #ifndef FROM_X；struct_emit 改调 public type_to_c_repr；bc residual **99→98**
  - ✅ codegen skip/force 域 **pure-owned leave**：`pipeline_codegen_skip_force.c` **deleted**（call_num_args_override + is_std_io_driver_bridge + path_is_std_io_* + dep_skip_* + should_skip_emit_* + entry_is_lsp_* + force_param_*）；live＝`runtime_pipeline_abi` pure（wave108）；seed cold twin under #ifndef FROM_X
  - ✅ codegen struct emit 域 thin：`pipeline_codegen_struct_emit.c`（c_file_prologue_done + struct_tag_try_claim + out_append_bytes/byte/format_int + emit_struct_field_type_inner/type/decl · ~230 LOC body）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1250）
  - ✅ codegen residual 域 **pure-owned leave**：`pipeline_codegen_residual.c` **deleted**（use_buf_wrapper + skip_emit_extern_io_batch_buf + should_skip_emit_func_by_name + emit_seed_mega_enabled + is_submit_batch_buf_call + should_skip_emit_func_core_read_ptr + asm_io_core_extern_callee_sym + io_driver_buf_call_sym + std_io_fixed_fd_emit_impl）；live＝`runtime_pipeline_abi` pure（wave107 2026-08-05）；seed cold twin under #ifndef FROM_X；bc residual **101→100**
  - ✅ asm locals + block slot sidecar 域 thin→**pure leave wave267**：`pipeline_asm_locals.c` absent（AsmLocalSlotEntry／AsmLocalsSidecar／AsmBlockSlotSidecar + sidecar_get + asm_ctx_local_reset/count/append/name_len/name_byte_at/name_copy64/offset_at/find_offset + pipeline_asm_local_offset_c + asm_ctx_block_slot_reset/set/get · ~280 LOC body）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1252）· **host-cc leave wave267** live→runtime_pipeline_abi pure；file absent
  - ✅ asm slot bytes + ensure_block_locals 域 thin→**pure leave wave268**：`pipeline_asm_slot_bytes.c` absent（asm_slot_bytes_named_in_mod + asm_fixed_array_total_bytes_mod + asm_ctx_module_ref + asm_local_slot_bytes_mod + asm_local_slot_bytes + asm_ctx_ensure_block_locals · ~445 LOC body）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1253）· **host-cc leave wave268** live→runtime_pipeline_abi pure；file absent
  - ✅ type pool Cap residual thin→**pure leave wave270**：`ast_pool_type.c` absent（pipeline_type_named_name_into／region_label_*／set_region_label／find_or_alloc_slice｜ptr｜named｜compound／kind_ord／elem／array_size／set_elem／ensure／init_* · ~416 LOC body）；g05 STALE／inventory absent；live→runtime_pipeline_abi pure；Cap residual pipeline_arena_type_ptr／alloc 仍 arena；file absent
  - ✅ asm block tree traversal + frame sizing 域 thin→**pure leave wave269**：`pipeline_asm_block_tree.c` absent（asm_block_tree_push_* + asm_sum_block_local_slot_bytes + asm_count_block_stack_slots + asm_fixed_array_temp_bytes + asm_sum_block_array_temp_bytes + asm_sum_block_wa_temp_bytes + asm_ctx_fill_locals_block_tree · ~317 LOC body）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1254）· **host-cc leave wave269** live→runtime_pipeline_abi pure；file absent
  - ✅ asm ctx loop + block emit cont 域 **pure-owned leave**：`pipeline_asm_ctx_loop.c` **deleted**（asm_ctx_loop_* + asm_be_cont_*）；live＝`runtime_pipeline_abi` pure 固定容量表（wave114 2026-08-05）；seed cold twin under #ifndef FROM_X；bc residual **94→93**
  - ✅ asm WPO v0 DCE + PGO-Lite reach/emit order 域 thin→**pure leave wave274**：`pipeline_asm_wpo.c` **absent**（reach clear／compute／should_emit／pgo emit_order／is_hot + BSS graph／PGO）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；dual-export ban（pipeline_abi T · pipeline_x U）；g05 STALE／inventory absent；present **36→35**；**双端 L2 绿**（mac + Ubuntu `ubuntu-remote-server` @ `8e277d8bc`）
  - ✅ sidecar 池管理域 thin→**pure leave wave275**：`ast_pool_sidecar_pool.c` **absent**（arena／module／onefunc `*_sidecar_get|free` + BSS tables LE 816／432／944 · cap 512／512／1024）；live＝runtime_pipeline_abi pure；seed cold twin under #ifndef FROM_X；lifecycle free-by-key；typedef Cap face decls；dual-export ban；g05 STALE／inventory absent；present **35→34**；**双端 L2 绿**（mac + Ubuntu `ubuntu-remote-server` @ `545073438`）
  - ✅ asm module self-host classification 域 thin：`pipeline_asm_selfhost.c`（asm_module_num_defined_funcs/defined_func_ordinal + is_backend/typeck/pipeline/main_driver/driver_compile/parser/parser_emit_heavy/ast/compiler · 9 谓词全 · ~280 LOC body）；is_ast/is_compiler 谓词后补入（无新文件、无构建系统改动）；前向声明保留 host TU；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ asm M8-tail thin delegate 域 thin：`pipeline_asm_thin_delegate.c`（AsmBackendThinDelegateRow + k_asm_backend／k_asm_pipeline／k_asm_parser／k_asm_driver／k_asm_typeck_thin_delegate + asm_backend／asm_pipeline／asm_driver／asm_typeck_m8_tail_thin_delegate_c_name · ~320 LOC body · 五表全）；k_asm_parser 表迁出、asm_parser_m8_tail_thin_delegate_c_name 仍留 ast_pool parser_emit_heavy 域（同 TU static 可见）；driver/typeck 表后补入（无新文件、无构建系统改动）；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ asm EMIT_HEAVY env／path／whitelist 域 thin → **pure-owned leave**：`pipeline_asm_emit_heavy_env.c` **absent**；live＝`runtime_pipeline_abi` pure（env gates／abort_lo_hi／path／whitelist／orchestration_extern_only／name_has_prefix／top_level_const_lit）；Cap residual top_level_let／expr／driver_get；typedef 迁 parser_emit_heavy
  - ✅ asm EMIT_HEAVY safe-helper 域 thin：`pipeline_asm_emit_heavy_safe_helper.c`（asm_typeck／pipeline／driver_compile_emit_heavy_safe_helper + asm_skip_heavy_backend_m8/helper_keep + asm_skip_heavy_backend_m8_tail_thin_keep／typeck_helper_keep／backend_mega_entry／typeck_mega_entry · 9 fn · ~653 LOC body · skip_heavy 全集）；共用 static pipeline_module_func_name_has_prefix_at 在 emit_heavy_env 域（多域共用）；asm_module_is_*_selfhost 经 selfhost include 可见；4 skip_heavy 入口分类器后补入；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ asm parser EMIT_HEAVY 域 thin → **pure-owned leave**：`pipeline_asm_parser_emit_heavy.c` **absent**；live＝`runtime_pipeline_abi` pure（dbg/bisect/slot/mega/force_stub/safe 216/thin 116/m8/resolve/callee）；seed cold twin under #ifndef FROM_X
  - ✅ asm 诊断域 thin：`pipeline_asm_diag.c`（asm_diag_start_func_skip + asm_diag_trace_func_body／body_ref／emit_phase／func_idx + asm_diag_trace_func wrapper · 6 fn · ~96 LOC body）；自 ast_pool 两处合抽（尾部 5 fn + Block B 的 comment+fwd decl+wrapper）；wrapper 置于 func_idx 定义之后，Block B 前向声明随之移除（无其他调用方）；依赖 link_abi_getenv／asm_env_build_skip_typeck（Block B 先于 include）／block_at；全公共符号；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ asm skip/stub dispatch 域 thin：`pipeline_asm_skip_dispatch.c`（asm_empty_text_stub_label 空桩 FNV-1a 标签 + asm_skip_heavy_module_func_body 中央 dispatch · 2 fn · ~302 LOC body）；自 ast_pool L4740-5041 两连续函数同 TU 抽出（#include 于 parser_emit_heavy 后、diag 前）；37 callee 均先于此定义（selfhost 谓词／skip_heavy 分类器／parser_emit_heavy 分类器／asm_count_block_stack_slots／asm_env_*／ASM_HEAVY_BODY_SLOT_THRESHOLD／g_asm_skip_pipeline_ctx／pipeline_dep_ctx_*）；公共符号，调用方经 glue 前向声明或在此 include 之后；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ asm_ctx_fill_locals_block_tree 折入 block_tree 域：自 ast_pool 折入 `pipeline_asm_block_tree.c`（block tree 遍历填 locals · 33 行）；callee asm_block_tree_push_* 已在此文件、asm_ctx_ensure_block_locals 在 slot_bytes.c 先于 include；无新文件、无构建改动；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ import 路径解析/fs 读 glue 域 thin：`pipeline_resolve_path.c`（path_append_from_buf_256/512 + path_append_import_path + resolve_path_import_has_dot/probe/last_off/lib_root_prefix/entry_dir_prefix + flat_import_build/probe + resolve_path_x_impl_c/x_c dispatch + CodegenOutBuf len/set + std_fs extern · ~16 fn · ~364 LOC body）；自 ast_pool L2016-2379 同 TU 抽出（dep_ctx include 后），#include 位置不变；依赖 dep_ctx 访问器（先于 include），resolve_path_x/copy_lib_root 经 extern/前向声明；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ scratch/slots 3 子域批量 thin：① `pipeline_emit_sidecar.c`（driver_emit_lib_root_* + asm_qual_sym_layer_* · ~203）；② `pipeline_preprocess_if.c`（preprocess_if_stack_* GrowVec cold fallback XLANG_WEAK · ~74）；③ `pipeline_typeck_slots.c`（typeck_named/scratch64 + call_resolve/overload 槽 + integer_widen_ok + binop_arith_infer_type_c + struct_layout_metrics + layout 槽 · ~354） · **host-cc leave 2026-08-05** live BSS→typeck_x.o；file absent。自 ast_pool L3387-4019 同 TU 批量抽出（elf_ctx 前），位置不变；依赖 GrowVec／DriverEmitSidecar／arena 均先于 include；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ codegen dep 编排域 thin：`pipeline_codegen_dep.c`（run_x_pipeline_codegen_one_dep_emit／entry_emit／one_dep_c／deps_c／entry_c + pipeline_debug_dump_std_heap_trace_call + dep 路径填充 + pipeline_dep_ctx_has_earlier_same_import_path 去重 + g_codegen_entry_arena_for_mono · ~504 LOC body）；自 ast_pool L2820-3323 同 TU 抽出；extern（asm_asm_codegen_ast／codegen_codegen_x_ast／driver_diagnostic_*／codegen_dep_skip_x_bootstrap_partial）本块内声明；ast_pool 内无先于 include 的调用方；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ LSP 诊断 C glue 域 thin：`pipeline_lsp_diag.c`（…）；**host-cc leave 2026-08-05**：文件 absent；live＝`runtime_pipeline_abi` pure（typeck_after_load／parse_entry／parse_typeck + Cap-fn-ptr large-stack thread_fn；seed cold twin under #ifndef FROM_X）；parse_orch `_impl_c` 转调 pure 面
  - ✅ fs 读 + import bind/sync 域 thin：`pipeline_import_bind.c`（read_file_x_impl_c／_c／read_fd_into_loaded_buf + dep_ctx_preprocess_len_get + preprocess_loaded_into_ctx + bind_import_dep_buffers + try_bind_seeded_import + sync_one_dep_slot · ~138 LOC body · XLANG_WEAK cold twin）；自 ast_pool L2018-2155 同 TU 抽出（resolve_path 后）；依赖 dep_ctx + driver_dep + xlang_read_file_into_path（先于 include）；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ parse entry + typeck 分派 + import load 域 thin：`pipeline_parse_typeck_dispatch.c`（g_pipeline_parse_scalars + accessors + should_skip_x_typeck + parse_fail_diag + parse_into_with_init_*_scalars + parse_apply_main/set_main_from_buf + typeck_parsed_module_c／entry_module_c + realign_ndep + load_import_resolve_read／load_one_import_slot／load_and_sync_direct_import_deps_c + 共享 extern 头 · ~465 LOC body）；自 ast_pool L2020-2484 同 TU 抽出（import_bind 后）；公共符号 + XLANG_WEAK + static scalars；无先于 include 调用方；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ run_x_pipeline 核心 + loop glue 域 thin（**编排骨全分解**）：① `pipeline_run_x_pipeline.c`（typecheck_entry_c + last_rc get/store + typeck_fail/null_return + load_deps_after_parse + typecheck_after_load + parse_entry_do_parse + typecheck_entry_emit · ~118 LOC；#include 于 parse_typeck_dispatch 后、codegen_dep 前；无 codegen_dep 前向引用）；② `pipeline_loop_glue.c`（loop_should_continue_ndep/imports/lib_root + index_at_or_beyond_* + load_and_sync_set_ndep + codegen_one_dep_prepare · ~60 LOC；#include 于 codegen_dep 后）；同 TU 抽出，位置不变；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ ast_pool lifecycle/reset/release 域 thin：`ast_pool_lifecycle.c`（sidecar entry 访问器 module_func_at + copy_func_params + module_func_param_entry／arena_func_param_entry + module_layout_field_entry + 池生命周期 block_on_alloc + module/arena reset/release + drop_bodies_for_check + onefunc reset/release · ~463 LOC）；藏于 ast_pool.c type.c／module_func.c include 间隙（L1067-1529）同 TU 抽出；依赖 sidecar 全局 + GrowVec（先于 include）；ast_pool_block_on_alloc 经 L1052 前向声明；无 module_func.c 前向引用；g05 STALE／`PIPELINE_X_DEPS` 已收
  - ✅ pipeline lint + module metadata 域 thin → **pure-owned leave**：`pipeline_lint_meta.c` **absent**；live＝`runtime_pipeline_abi` pure（visibility + L7 + module header glue）；seed cold twin under #ifndef FROM_X
  - ✅ GrowVec 叶域 thin→**pure leave wave271**：`pipeline_grow_vec.c` absent（grow_vec_init／free／ensure／at／push／copy_append · GrowVec LE 32B · POSIX mmap large）；typedef+extern 留 ast_pool_typedefs；live→runtime_pipeline_abi pure；g05 STALE／inventory absent；present **40→39**
  - ✅ early typedef 域 thin：`ast_pool_typedefs.c`（pool macros + entry/sidecar typedefs · ~315 LOC）；同 TU #include 于 grow_vec 后、sidecar_pool 前；host 保留 AST_POOL_GROW／INIT_CAP 于 grow_vec 之前（grow_vec 依赖）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1278）
  - ✅ core ptr_at 访问器 thin→**dead leave wave298**：`ast_pool_ptr_at.c` **absent**（domain pure／seed ALWAYS leave 后零 residual 调用方；block Cap＝`w277_block_at`）；g05 STALE／`PIPELINE_X_DEPS`／inventory absent；present **15→14**；**双端 L2 绿**
  - ✅ sidecar 池管理域 thin：`ast_pool_sidecar_pool.c`（MAX_*_SIDECARS + g_arena_sc／g_module_sc／g_onefunc_sc／g_driver_emit_sc／g_xlang_depctx_sc + sidecar_get/ensure/free + pipeline_dep_ctx_sidecar_release · ~478 LOC）；自 ast_pool L334-811 同 TU 抽出（typedefs 后）；g_xlang_depctx_sc／depctx_sidecar_get 非静态（pure crt0 embed）；static 全局对 lifecycle.c 可见；g05 STALE／`PIPELINE_X_DEPS` 已收
  - 🟡 仍 host-cc 编入 `pipeline_x`（未 .x 化 / 未离 host-cc）— **域 thin 子项 ✅ ≠ 父项 BC 完成**
  - ✅ asm struct let-init domain thin：`pipeline_asm_emit_struct_let.c`（struct_let_init + glue_emit_struct_type_let_init + sret reg shift · ~176 LOC body／~215 file）自 glue 同 TU `#include` 抽出；store_retval／type_size 仍 glue；`PIPELINE_X_DEPS` COUNT 57→58 / g05 STALE / inventory 已收（wave1007）
  - ✅ asm INDEX residual helpers domain thin：`pipeline_asm_emit_index_helpers.c`（module_from_ctx + param/local slot + field_type_ref + fixed_array_total_bytes + index_elem_byte_sz_from_type_ref + try_index forest + soa_index_field_addr + lvalue_eff_addr · ~2988 LOC body／~3038 file）自 glue 同 TU `#include` 抽出；eff_addr_scaled／assign finish_store／bulk_mem_copy／Chaitin spill 仍 glue；`PIPELINE_X_DEPS` COUNT 58→59 / g05 STALE / inventory 已收（wave1008）
  - ✅ asm 7.3 live／Chaitin spill／bulk_mem／index-assign residual thin：`pipeline_asm_emit_spill.c`（live_fwd + CFG phi + color + bulk_mem_copy_spills + index_assign_finish_store + index scratch／binop_stack_spill methods · ~2487 LOC body／~2532 file）自 glue 同 TU `#include` 抽出；CAP statics 仍 index_helpers；eff_addr_scaled 仍 glue；`PIPELINE_X_DEPS` COUNT 59→60 / g05 STALE / inventory 已收（wave1009）
  - ✅ asm INDEX effective-address scaled domain thin：`pipeline_asm_emit_index_eff_addr.c`（rax_plus_rbx_scaled + bounds_guard + rvalue_slice_once + eff_addr_scaled · ~653 LOC body／~697 file）自 glue 同 TU `#include` 抽出；try_index 仍 index_helpers；face 仍 index／assign；`PIPELINE_X_DEPS` COUNT 60→61 / g05 STALE / inventory 已收（wave1010）
  - ✅ asm expr recursion dispatcher domain thin：`pipeline_asm_emit_expr_rec.c`（lit_i32 + emit_expr_elf_rec · ~139 LOC body／~179 file）自 glue 同 TU `#include` 抽出；face 仍各域叶；slow 仍 backend residual；`PIPELINE_X_DEPS` COUNT 61→62 / g05 STALE / inventory 已收（wave1011）
  - ✅ asm INDEX eff-addr base twins + public faces 有则补全：`pipeline_asm_emit_index_eff_addr.c` 迁入 local_slot_text + base_{elf,text} + public index_eff_addr_{elf,text}（~198 LOC；file ~697→~895）；COUNT 仍 62；lvalue_eff_addr_text 仍 glue residual；ELF lvalue 仍 index_helpers（wave1012）
  - ✅ asm lvalue_eff_addr_text 有则补全：`pipeline_asm_emit_index_helpers.c` 迁入 `pipeline_asm_emit_lvalue_eff_addr_text_c`（~77 LOC；file ~3039→~3135）；与 ELF twin 同叶；local_slot_text 仍 index_eff_addr（同 TU static 前向）；COUNT 仍 62；glue ~20.7k→~21.1k（wave1013）
  - ✅ asm thin ELF public faces 有则补全：return／unary／as／spill 叶迁入 `pipeline_asm_emit_{return,neg,lognot,bitnot,as,break,continue}_elf_c`（~40 LOC 自 glue；COUNT 仍 62；glue ~21.1k）（wave1014）
  - ✅ asm binop residual 有则补全：`pipeline_asm_emit_binop.c` 迁入 scalar f32／f64／ptr arith／add_rax_rbx（~306 LOC 自 glue；file ~1221；COUNT 仍 62；glue ~20.8k）（wave1015）
  - ✅ asm assign_rhs_to_rax 有则补全：`pipeline_asm_emit_assign.c` 迁入 `glue_emit_assign_rhs_to_rax_elf_c`（~89 LOC；file ~678；COUNT 仍 62；glue ~20.7k）（wave1016）
  - ✅ asm type_named_struct 有则补全：`pipeline_asm_emit_call_args.c` 迁入 `glue_type_ref_is_named_struct_layout_elf_c`（~30 LOC；file ~876；COUNT 仍 62；glue ~20.7k）（wave1017）
  - ✅ asm try_binop residual 有则补全：`pipeline_asm_emit_binop.c` 迁入 as_needs + load_operand／clobber／preserve／commutative／left_rax／cmp（~740 LOC；file ~1976；COUNT 仍 62；glue ~19.9k）（wave1018）
  - ✅ asm emit_expr_elf_fast + emit_expr_elf_c 有则补全：`pipeline_asm_emit_expr_rec.c` 迁入 fast／c（~212 LOC；file ~404；COUNT 仍 62；glue ~19.6k；include 迁 field_access 后）（wave1020）
  - ✅ asm array_lit durable + force_esz 有则补全：`pipeline_asm_emit_array_lit.c` 迁入 durable_ptr／force_esz_from_elem（~390 LOC；file ~779；COUNT 仍 62；glue ~19.2k）（wave1021）
  - ✅ asm call_arg resolve + f32 VAR slot 有则补全：`pipeline_asm_emit_call_args.c` 迁入 resolve_anon／resolve_var_stack_off + load_f32_var_slot_{rax,rbx} + unusable／append_at_offset／var_is_param（~160 LOC；file ~1052；COUNT 仍 62；glue ~19.8k；var_decl + lazy_append wave1023 已迁出共享叶）（wave1019）
  - ✅ asm slice reent deep-copy 有则补全：`pipeline_asm_emit_call_args.c` 迁入 `glue_slice_let_reent_deep_copy_after_dual_gp_elf_c`（~400 LOC；file ~1458；COUNT 仍 62；glue ~18.8k）（wave1022）
  - ✅ asm var_decl + lazy_append G.7 共享叶 fold：新建 `pipeline_asm_emit_var_decl.c`（~125 LOC；`glue_var_decl_type_ref_elf_c` ~30 + `glue_lazy_append_block_let_local` ~25 自 glue residual）；glue 66 行定义体 → 9 行 #include；COUNT 仍 62（同 TU #include 不增 .o）；glue ~18.8k→~18.7k；被 7 切片共享（call_args/binop/assign/unary/expr_rec/block_inits/block_body）（wave1023）
  - ✅ asm slice dual-GP helpers + slice_from_array G.7 同叶 fold：`pipeline_asm_emit_block_inits.c` 迁入 `glue_slice_dual_gp_length_off_c`（~5 LOC）+ `glue_slice_dual_gp_bump_past_home_c`（~14 LOC）+ `glue_emit_slice_from_array_let_init_elf_c`（~150 LOC 自 glue residual；file ~171→~402）；COUNT 仍 62；glue ~18.7k→~18.5k；被 block_inits + call_args（slice_let_reent_deep_copy）共享（length_off 早期 fwd 保留供 call_args）（wave1024）
  - ✅ asm sret return path helpers G.7 同叶 fold：`pipeline_asm_emit_return.c` 迁入 `glue_emit_sret_memcpy_rbx_to_home_elf_c` + `glue_emit_sret_return_from_var_elf_c` + `glue_copy_large_struct_from_rax_ptr_elf_c`（~103 LOC body 自 glue residual；file ~643→~772）；COUNT 仍 62；glue ~18.5k→~18.4k；被 return + struct_lit（sret_memcpy）+ struct_let（copy_large_struct via store_retval_pair）共享（glue 1989-1993 fwd 保留；新增 glue_enc_local_slot_ptr_or_addr_rbx_elf_c fwd——index_helpers 在 return 之后 #include）（wave1025）
  - ✅ asm field_access layout/offset helpers G.7 同叶 fold：`pipeline_asm_emit_field_access.c` 迁入 `glue_dep_layout_field_offset_by_name_c` + `glue_field_layout_offset_for_{var_base,base}_field` + `glue_field_access_effective_offset_c` + `pipeline_expr_field_access_layout_offset` + `glue_field_access_load_bytes_for_type_ref` + `pipeline_expr_field_access_load_byte_sz`（~395 LOC body 自 glue residual；file ~632→~1025）；COUNT 仍 62；glue ~18.4k→~18.0k；被 field_access + index_helpers／assign／index_eff_addr／vector_let 共享（glue 1726-1727 public fwd 保留；2500 static fwd 保留；新增 typeck_get_field_offset_from_layout_deps／pipeline_dep_ctx_ndep／pipeline_dep_ctx_module_at extern）（wave1026）
  - 🟡 下一域候选（父项仍 🟡）：asm_module_is_compiler_selfhost 大谓词／asm_empty_text_stub_label／EMIT_HEAVY dispatch 编排主体；或 8.3.3 field_access 权威收敛

🟡 **8.3.3 `pipeline_typeck_field_access.c` / `pipeline_typeck_soa.c` 并入 typeck 权威**

  - 验收（父项 ✅）：field resolve 唯一权威在 typeck.x；C 叶仅 thin 或删
  - ✅ 文件已抽出同 TU：`pipeline_typeck_field_access.c` ~1.6k · `pipeline_typeck_soa.c` ~355（仍 host-cc）
  - ✅ `typeck_soa_array_storage_size_glue` 已从 C bypass 迁到 typeck.x 权威
  - ✅ `typeck_soa_find_layout_idx_by_name` → typeck.x（tip `72addb527`）
  - ✅ `typeck_soa_col_base_for_field` → typeck.x（用 typeck_x_type_align/size 替 glue_type_*；C 仅 extern）
  - ✅ `typeck_soa_find_layout_module_and_idx` → typeck.x（WPO dep 池按名查 layout；C 仅 extern；消费 `pipeline_asm_emit_dep_pipe_c`）
  - ✅ `typeck_soa_field_soa_index` → typeck.x（`arr[i].field` col_base+stride；stride=`typeck_x_type_size` 非 glue；C thin `pipeline_typeck_field_soa_index_c` 转调）
  - ✅ `typeck_soa_fill_field_access_for_asm_emit` → typeck.x（fill 编排：STRUCT_LIT ensure + DOD-CL align inherit + sync offsets + var type backfill + FIELD_ACCESS SoA/AoS stamp）；C thin `pipeline_fill_soa_field_access_for_asm_emit` 转调；4 个 glue static 升 link 面供 typeck_x.o 调用
  - ✅ `typeck_field_slice` → typeck.x（ARRAY/VECTOR `.length`→usize；SLICE `.length`/@8 + `.data`→*elem/@0）；C thin `pipeline_typeck_field_slice_c` 转调
  - ✅ `typeck_field_name_fallback` → typeck.x（CodegenOutBuf.data→u8[8M]；inline u8[64]／i32[16]；scalar heuristic）；C thin `pipeline_typeck_field_name_fallback_c` 转调
  - ✅ `typeck_field_lexer_fallback` → typeck.x（`typeck_field_access_lexer_wrapper_fallback` + EXPR_VAR formal hop）；C thin `pipeline_typeck_field_lexer_fallback_c` 转调
  - ✅ `typeck_field_prebind` → typeck.x（未绑 VAR base → TYPE_NAMED 同名预绑定；形参名跳过）；C thin `pipeline_typeck_field_prebind_c` 转调
  - ✅ `typeck_field_layout_named` → typeck.x（alias peel + PTR/NAMED layout + 用户 enum 返 2 + TypeKind 变体 + `mod.T` 去前缀 + layout deps offset/type + TokenKind.TOKEN_EOF）；C thin `pipeline_typeck_field_layout_named_c` 转调
  - ✅ `typeck_field_known_ptr` → typeck.x（`*ASTArena`／`*Module` 硬编码 SoA 字段 + 偏移／数组类型；`driver_diagnostic_typeck_ptr_field`）；C thin `pipeline_typeck_field_known_ptr_types_c` 转调
  - ✅ `typeck_field_import_binding` → typeck.x（import binding／const-import sugar：dep 函数返回类型 + 顶层 const + enum 类型名；`typeck_dep_top_level_const_match` + `typeck_field_import_try_dep_enum_type` 同叶；裸 import-const 诊断共用 const_match）；C thin `pipeline_typeck_field_import_binding_resolve_c` 转调
  - ✅ `typeck_check_expr_field_access` 主编排 → typeck.x（prebind → import_binding → reverse_infer → check_expr base → SoA → known_ptr／layout／slice → name/lexer fallback → mono wrapper → ambient wrapper → unknown_hard_fail）；`typeck_field_reverse_infer_base_type` + `typeck_field_apply_mono_type_arg` + `typeck_field_apply_ambient_for_type_param` 同叶；C thin `pipeline_typeck_check_expr_field_access_c` 转调
  - ✅ `typeck_mono_field_type_from_base` → typeck.x（G.7 mono；STRUCT_LIT coerce 共用）；C thin `pipeline_typeck_mono_field_type_from_base_c`
  - ✅ `typeck_named_is_module_concrete` → typeck.x（local+dep struct/enum；wave1220 P4）；C thin `pipeline_typeck_named_is_module_concrete_c`（strict_minimal 仍转调）
  - ✅ `typeck_field_unknown_hard_fail` → typeck.x（wave674/684/702 gate；enum-no-variant）；C thin `pipeline_typeck_field_unknown_hard_fail_c`
  - ✅ `typeck_reject_bare_import_const` → typeck.x（G.7 与 `typeck_check_expr_var` 共用；`find_import_const_dep_index` + `import_const_binding_hint_at` + `driver_diagnostic_typeck_import_const_must_be_qualified`；C thin `pipeline_typeck_reject_bare_import_const_c`；field_access ~334→~218 全 thin）
  - ✅ `typeck_check_expr_var` match subject field hop → typeck.x（G.7 对齐 C `pipeline_typeck_check_expr_var_c` wave703：`pipeline_typeck_match_subject_field_type_c`；闭合 `match_struct_destructure`／bind／classify 产品 XT001）
  - ✅ pure-asm MATCH field-bind → `pipeline_asm_emit_match_elf_c` set `pipeline_codegen_match_*` subject + VAR fast `glue_try_emit_match_subject_field_var_elf_c`（G.7 对齐 host-C wave707；闭合 Ubuntu pure `match_struct_bind` CG002）
  - ✅ pure-asm MATCH arm guards → `pipeline_asm_emit_match_elf_c` 顺序 first-match + `pipeline_expr_match_arm_guard_ref`（G.7 对齐 host-C wave708；闭合 pure field-lit 多臂／`match_guard`；wild+guard jz／lit re-emit+jne）
  - ✅ **host-cc leave（2026-08-05）**：`pipeline_typeck_field_access.c`／`pipeline_typeck_soa.c` **物理删除**；不再 `#include` 入 `pipeline_x`；`PIPELINE_X_DEPS`／g05 STALE 摘除；bc-inventory **absent**（present residual **111**）。产品调用 `typeck_*`／`typeck_soa_*`／`typeck_reject_bare_import_const`；strict_minimal 四 `pipeline_*_c` thin 面在 **typeck_x.o**（typeck.x + seed 同 commit）。
  - 🟡 父项 8.3.3 仍 🟡 仅因 **BC 终局 = pipeline_x 整 TU 离 host-cc 仍 ⬜**（本叶已 leave；mega 其它切片仍 host-cc）

✅ **8.3.4 bootstrap glue / orchestration 折叠进 8.3.1–8.3.2 或删**

  - ✅ `ast_pool_bootstrap_glue.c` **seed ALWAYS leave**（host 叶已删；present 28→27；双端 L2 绿；pipeline_x mega 首刀）
  - ✅ `pipeline_bootstrap_orchestration.c` **host wrapper leave**（seed-only `.o`；present 27→26；双端 L2 绿）

✅ **8.3.5 链接桩 / bare alias 退役**

  - ✅ 5× seed host wrappers leave：`ast_asm_bare_link_alias.c` · `backend_asm_bare_link_alias.c` · `backend_asm_strict_fallback_alias.c` · `x_frontend_link_alias.c` · `typeck_c_module_stubs.c`（产品 ensure 直编 seed → `.o`；host 叶已删；present **26→21**；双端 L2 绿）
  - ✅ cold host duals leave：`_stubs.c` · `xlang_x_stubs.c`（权威 `seeds/x_stubs.from_x.c`；`build_and_test_x` seed-only；present **21→19**；双端 L2 绿）
  - ✅ `_x_stubs2.c` dead dual leave（G05／stage2 均不链；B4 GEN_C_TO_O **5→4**；present **19→18**；双端 L2 绿）
  - ✅ `typeck_asm_bare_link_alias` host leave（权威 `seeds/typeck_asm_bare_link_alias.from_x.c`；gen／ensure seed-only；G05 本不链；present **18→17**；双端 L2 绿）
  - ✅ 残 scripts stubs 经 **8.3.7** host leave 闭（present **17→15**）
  - 目标：符号面由 .x `#[no_mangle]` / 单一 mangle 权威提供，无「为让 ld 安静」的永久 C 桩

🟡 **8.3.6 `seeds/*.from_x.c` 全表退役策略**

  - 今日 **~328** 个 seeds `.c`：分 **产品 pin** / **prove surface** / **EMPTY surface**
  - 终局：冷启动不读 from_x 业务体；surface 仅考古或生成物不入库（策略二选一写清）
  - ✅ **strict_minimal 产品 shell**：dual-export WEAK／parse_commit／overload leave 后 0 T → **seed 物理删除 + 产品 g05 摘链**（inventory absent · present **13**；**双端 L2 绿**）
  - ✅ **pipeline.x dual-export thin leave（wave305）**：5 faces（`parse_into_buf`／`resolve_path_probe_dot`／`resolve_path_x`／`read_file_x`／`lsp_diag_parse_typeck_buf`）export-extern → **runtime_pipeline_abi pure／seed**；pipeline_x host-cc T 39→34；present **13** 地板；**双端 L2 绿**
  - ✅ **pipeline.x resolve residual pure leave（wave306）**：try_*／path_append／has_dot → pure；T 34→27；**双端 L2 绿**
  - ✅ **pipeline.x run_x／thin residual pure leave（wave307）**：should_skip／load_*／typeck_*／run_x orch／lsp residual thin → pure（thin→Cap + `run_x_pipeline_impl` orch）；T 27→**2**；soft residual Cap-struct `parse_into_with_init_buf`；present **13** 地板；**双端 L2 绿**
  - ✅ **Cap-struct residual seed ALWAYS leave（wave308）**：`pipeline_parse_into_with_init_buf` → seed ALWAYS thin→impl_c；pure 仍 scalars／impl_rc；pipeline_x T **2→1**（残 gen stub `io_register`）；present **13** 地板；**双端 L2 绿**
  - ⬜ 残：全表 from_x 退役策略未终（pin／prove／EMPTY／standalone 等仍在）；glue 壳／typedefs／9×fwd／standalone

✅ **8.3.7 scripts 下 asm stub C host leave**

  - ✅ host `compiler/scripts/asm_text_stub.c` · `asm_xlang_lsp_diag_stub.c` **deleted**（wave297 · 2026-08-08）
  - 权威：`seeds/asm_text_stub.from_x.c` + `seeds/asm_xlang_lsp_diag_stub.from_x.c`；build_xlang_asm／strict_glue／experimental ensure seed-only .o
  - present **17→15**；双端 L2 绿；G05 产品路径本不 host-cc 这两叶
  - 注：`scripts/asm_text_stub.s` 仍为 asm 回退占位（非 C residual）

🟡 **8.3.8 `build_asm/gen_driver/*.c`（原 10 个 · 物理在 compiler/ 外）**

  - `build_asm/gen_driver/pipeline_gen.c` · `lsp_io_gen.c` · `driver_check.c` · `preprocess_gen.c` · `driver_fmt.c` · `lsp_gen.c` · `lsp_io_std_heap_gen.c` · `driver_gen.c` · `driver_test.c`
  - **2026-08-10 实测**：`build_asm/gen_driver/` 下仅剩 `pipeline_gen.c`（1 个 .c）+ 4 个 _x.o 产物；其余 8 个 .c 已被 Track L 退役替换为 _x.o（见 8.1.9–8.1.20）
  - 🟡 `pipeline_gen.c` 仍作构建链产物残留（8.1.16 已 Track L 退役，构建用 pipeline_x.o）；需确认 g05/partial 是否仍引用此 .c 体

✅ **8.3.9 `analysis/_debug_io_ctx_gen.c` 孤儿 .c**

  - 本就在 `analysis/*` gitignore 下（仅 `*.md` 入库）；本地调试残留已 rm
  - 机检：`bc_host_cc_product_inventory.sh --check` 断言 **absent** + 禁 `_debug_*_gen.c` 再出现

⬜ **8.3.10 `editors/tree-sitter-xlang/` 第三方 .c**

  - `editors/tree-sitter-xlang/src/parser.c` · `bindings/python/tree_sitter_xlang/binding.c` 等
  - 第三方 tree-sitter grammar，自带 Makefile + binding.gyp + Cargo.toml(cc crate)
  - 与 xlang 自举链无关，但物理存在于仓库；终局需决定：删除 / git submodule / 独立 release


---

## 阶段 9：Cap residual 边界消灭（路线 A · 必须消除）

> **定义**：OS 系统调用 / 第三方库头依赖 / 宏展开 / C ABI 限制，当前 Xlang 无法表达，以 .c 形式残留。
> **性质变更**（2026-07-29）：原标记为「永久边界 🔒 不可迁」，现**降级为必须消灭的边界 ⬜**。
> **原因**：自举终局目标升级为「零 Makefile + 零 cc/gcc」（见阶段 13），只要这些 residual 还以 .c 源文件形式存在，就必然需要 cc/gcc 来编译它们。因此必须通过路线 A（语言能力补齐 + 纯 .x 重写）逐个消灭。
> **消灭顺序**：syscall 层（9.1）→ 文件/网络/线程（9.4/9.5）→ 第三方库 glue（9.2）→ 宏展开（9.3）→ 数据布局（9.6）→ driver_abi 平台层（9.7）。
> **前置**：阶段 10 语言能力补齐（syscall / raw FFI / inline asm / fnptr / va_list / 线程原语）是消灭这些 residual 的前提。

### 9.1 OS 系统调用类（消灭优先级 P0 · 最底层）

> **消灭路径**：为 Xlang 增加 syscall 内建（Linux x86_64 / arm64 syscall 号 + Windows NT API），用 .x 直接发 syscall，不再经 libc 包装。
> **依赖**：阶段 10.1 syscall / raw FFI。

⬜ **9.1.1 getenv / setenv / unsetenv / environ**
  - labi_invoke_cc/ld
  - labi_diag
  - rt_entry
  - runtime_env_os
  - runtime_scheduler_glue
  - parser_asm_parse_expr_link

⬜ **9.1.2 stat / access / realpath**
  - labi_path_io
  - labi_ensure_list
  - labi_freestanding_list
  - labi_invoke_ld_list
  - fmt_check

⬜ **9.1.3 getcwd / chdir / getpid / getppid**
  - runtime_process_os_glue
  - labi_invoke_ld_list

⬜ **9.1.4 execve / waitpid / pipe / spawn / system**
  - runtime_process_os_glue
  - labi_invoke_ld_list
  - labi_diag_pure
  - rt_entry

⬜ **9.1.5 clock_gettime / nanosleep / gmtime_r / QPC / Sleep**
  - runtime_time_os

⬜ **9.1.6 getrandom / getentropy / BCryptGenRandom**
  - runtime_random_fill

⬜ **9.1.7 getaddrinfo / WSAStartup / socket / connect / poll / recvmmsg / sendmmsg**
  - runtime_net_*
  - runtime_http_glue

⬜ **9.1.8 _write / write**
  - runtime_log_os

⬜ **9.1.9 inline asm syscall（Linux x86_64）**
  - runtime_asm_io_stubs

⬜ **9.1.10 opendir / readdir / closedir**
  - fmt_check

⬜ **9.1.11 execinfo / dladdr / DbgHelp / CaptureStackBackTrace**
  - runtime_backtrace_platform

⬜ **9.1.12 sysctl / proc/#if**
  - target_cpu_pure

### 9.2 第三方库依赖（消灭优先级 P2 · 自实现子集或桥接）

> **消灭路径**：能纯 .x 重写的重写（如 ed25519 / 部分libm）；不能重写的放弃或自实现子集；TLS / zlib 等大库走 .x 绑定层 + 预置二进制 .a（但不再走 cc 编译源码）。
> **依赖**：阶段 10.1 syscall / raw FFI · 阶段 10.2 inline asm（SIMD）。

⬜ **9.2.1 mbedtls BIO send/recv**（需 #include <mbedtls/ssl.h>）
  - runtime_tls_mbedtls_bio

⬜ **9.2.2 zlib deflateInit2_ / inflateInit2_**（需 #include <zlib.h> + #undef macros）
  - runtime_compress_zlib_glue

⬜ **9.2.3 ed25519 ref10 实现**（8 个 .inc 文件宏展开）
  - runtime_ed25519_ref10_glue

⬜ **9.2.4 libm math_*_impl**（32 个 libm 函数桥）
  - runtime_math_libm

⬜ **9.2.5 arrow SIMD kernels**（需 C target attributes）
  - runtime_arrow_simd_glue

⬜ **9.2.6 sqlite3**（sqlite3 C API）
  - runtime_sqlite_glue

### 9.3 宏展开类（消灭优先级 P2 · .x 内建替代）

> **消灭路径**：stdatomic → .x 原子内建；SIMD intrinsics → .x SIMD 内建；ed25519/zlib 宏 → .x 模板/过程化展开。
> **依赖**：阶段 10.2 inline asm · 阶段 10.4 原子内建 · 阶段 10.5 SIMD 内建。

⬜ **9.3.1 ed25519 ref10 宏重命名**
  - 8 个 .inc 经宏发射 _impl_c

⬜ **9.3.2 zlib macros #undef**
  - rest #include + #undef + call real

⬜ **9.3.3 #if host 字面量**
  - labi_host_lit
  - target_cpu_pure
  - runtime_panic_arm64

⬜ **9.3.4 C11 stdatomic / GCC __atomic intrinsics**
  - runtime_atomic_glue（30 个原子操作）

⬜ **9.3.5 SIMD intrinsics**
  - runtime_arrow_simd_glue（ARM SVE / x86 AVX）

### 9.4 C ABI / fnptr 表达限制（消灭优先级 P1 · 平台线程原语）

> **消灭路径**：fnptr → 阶段 10.3 完整 fnptr 支持；pthread/Win32 → 阶段 10.6 平台线程原语内建（.x 直接调 syscall/NT API）。
> **依赖**：阶段 10.3 fnptr · 阶段 10.6 线程原语。

⬜ **9.4.1 uintptr_t → fnptr cast + indirect call**
  - runtime_test_fn_invoke

⬜ **9.4.2 void*(*)(void*) C ABI**
  - runtime_net_workers

⬜ **9.4.3 main() char** argv
  - runtime_asm_build

⬜ **9.4.4 pthread_mutex_t / pthread_cond_t / pthread_create**
  - runtime_sync_os
  - runtime_channel_glue
  - runtime_queue_contention
  - runtime_thread_glue
  - runtime_sync_lock_diag_tls

⬜ **9.4.5 CRITICAL_SECTION / SRWLOCK / CONDITION_VARIABLE / CreateThread / _beginthreadex**
  - 同 9.4.4 Windows 侧

⬜ **9.4.6 SetThreadAffinityMask / qos_class**
  - runtime_thread_glue

### 9.5 FILE* / fprintf / fputs / va_list（消灭优先级 P1 · va_list + 格式化）

> **消灭路径**：FILE* → .x 自己的 I/O 流（基于 syscall write）；va_list → 阶段 10.7 可变参数内建；vsnprintf → .x 自实现格式化器。
> **依赖**：阶段 10.1 syscall · 阶段 10.7 va_list。

⬜ **9.5.1 driver_preamble_fputs（G.7）**
  - async_liveness
  - async_cps_codegen

⬜ **9.5.2 xlang_target_cpu_print（FILE/fprintf）**
  - target_cpu_pure

⬜ **9.5.3 reportf / va_list**
  - diagnostic 深路径

⬜ **9.5.4 vsnprintf + write**
  - bootstrap_nostdlib_stubs

### 9.6 全局/static BSS / 巨型字串数据（消灭优先级 P1 · Cap 已部分闭）

> **消灭路径**：Cap-global-bss / Cap-giant-string 已部分闭合（见 4.1.3 / 4.1.7）；剩余用 .x 全局数据表达。
> **依赖**：Cap-global-bss / Cap-giant-string 完全闭合。

⬜ **9.6.1 u8[N] 全局/static BSS**（Cap-global-bss）
  - rt_arena_buf
  - rt_emit_state

⬜ **9.6.2 巨型字串表数据**（Cap-giant-string）
  - rt_preamble

⬜ **9.6.3 static 共享状态**
  - 各 mega rest 切片

### 9.7 driver_abi 平台层集中点（消灭优先级 P3 · 最上层）

> **消灭路径**：driver_abi 平台槽位全部用 .x 表达；FILE/pctx/host/defines/work 槽 → .x 结构体；GAS 行表 → .x OutBuf。
> **依赖**：阶段 9.1-9.6 全部消灭后，此层自然消失。

⬜ **9.7.1 FILE/pctx/host/defines/work 槽**
  - rt_run_asm_backend
  - rt_run_compiler_parsed
  - rt_run_x_emit
  - rt_dispatch_impl
  - rt_asm_stub

⬜ **9.7.2 lib_roots 槽 + Parsed 填表**
  - rt_dispatch_impl

⬜ **9.7.3 GAS 行表 + OutBuf append**
  - rt_asm_stub

⬜ **9.7.4 driver_stdio_* + driver_entry_*_slot**
  - rt_entry

⬜ **9.7.5 usage_write + compiled_body**
  - rt_run_exec

⬜ **9.7.6 driver_run_stack_esc_gate**（pthread）
  - rt_stack

⬜ **9.7.7 driver_run_thread_on_large_stack_pthread**
  - rt_stack

---

## 路线选择：零 Makefile + 零 cc/gcc 的实现路径

> **背景**（2026-07-29）：自举终局目标从「v2==v3 + 无 pin」升级为「零 Makefile + 零外部 C 编译器」。阶段 9 的 residual C 只要以 .c 源文件形式存在，就必然需要 cc/gcc 编译。因此必须选定一条路线彻底消灭 .c 源文件依赖。

### 路线对比

| 路线 | 做法 | 优点 | 缺点 | 是否采用 |
|------|------|------|------|----------|
| **A · 纯 .x + 内建能力重写** | 为 Xlang 增加 syscall / FFI / inline asm / fnptr / va_list / 线程原语内建；阶段 9 全部用 .x 重写或自实现子集；纯 .x 写 xbuild 替代 Makefile | 最干净；真正零 cc；终局最纯 | 工作量大；需补语言底层能力 | ✅ **采用** |
| B · 预置二进制 blob | residual C 提前编译成 .o/.a；运行时只链接；冷启动仍需一次 cc | 工作量小 | 严格说 cc 仍参与过；不够纯；跨平台二进制管理复杂 | ❌ 不采用 |
| C · Xlang 实现 C 编译器前端 | 在 Xlang 里写一个足够用的 C 编译器 | 可兼容遗留 C 代码 | 工作量巨大；几乎再做一个编译器 | ❌ 不采用 |

### 路线 A 落地顺序

```
1. 更新追踪文档（本文）— 删 Makefile + 零 cc 三义 + 8.3 glue 债入图 ✅（本审计）
2. 语言能力补齐（阶段 10）— syscall / raw FFI / inline asm / fnptr / va_list / 线程原语
3. 消灭阶段 9 residual + 阶段 8.3 glue/ast 池 — 从底向上
4. 阶段 7/8 去 pin + gen 退役 — 前端 typeck/codegen 与三 mega
5. xbuild 吃掉 Makefile（阶段 11.0 可与 2–4 并行：先搬编排、后断 cc）
6. 冷启动路径重设计（阶段 12）— 最小 seed → xlang → xbuild → 完整产品
7. 终局验证（阶段 13）— 物理删 Makefile + 零 cc 三义 + v2==v3
```

### 与「已有半路径」的关系（禁止从零幻想）

| 已有资产 | 路径 | 今日角色 | 终局角色 |
|----------|------|----------|----------|
| 顶层 `Makefile` | 仓库根 | **薄包装** → `./xlang-build.sh` | **删除** |
| `compiler/Makefile` | ~3445 行 | **实现层权威**：.o 规则 / bootstrap / CI 历史目标 | **删除**（规则迁 xbuild） |
| `xlang-build.sh` | 根 | G-05 用户入口 | 可保留为 xbuild 的 shell shim 或删 |
| `scripts/g05_*.sh` | compiler/scripts | **产品 relink 编排已在 shell**（注释写明 Makefile 不参与产品路径） | 由 xbuild 调用或 .x 重写 |
| `build.x` | 仓库根 | **策略稿**（what/order）；实现大量 “See implementation” | 填实为 xbuild 策略源 |
| `compiler/src/driver/build.x` | driver | build 子命令相关 | 与 xbuild 合并为单一权威 |
| `build_tool` / seeds/build_* | 历史 | 仍可能 `make xlang_asm` 兜底 | 断 make 依赖 |

---

## 阶段 10：语言能力补齐 Track L2（路线 A 前置 · 消灭 residual 的前提）

> **定义**：为 Xlang 增加底层能力，使其能表达 OS 系统调用 / inline asm / 函数指针 / 可变参数 / 平台线程原语。
> **性质**：这是消灭阶段 9 residual 的**前提**。没有这些能力，阶段 9 的 .c 无法用 .x 重写。
> **优先级**：P0（最高）— 阻塞所有阶段 9 消灭工作。

### 10.1 syscall / raw FFI 内建

⬜ **10.1.1 Linux x86_64 syscall 内建**

  - 支持 `syscall(nr, args...)` 直接发系统调用
  - 覆盖：read/write/open/close/stat/mmap/munmap/exit/getpid/...

⬜ **10.1.2 Linux arm64 syscall 内建**

  - 同上，arm64 syscall 号表

⬜ **10.1.3 Windows NT API 内建**

  - NtCreateFile / NtWriteFile / NtReadFile / NtClose / NtQuerySystemTime...
  - 或经 ntdll.dll 符号绑定

⬜ **10.1.4 raw FFI（ extern "C" 调用约定）**

  - 支持 .x 直接声明 extern 符号 + 调用（不需 .c 桥）
  - 覆盖：dlsym 加载 / 函数指针 cast / 平台 ABI

### 10.2 inline asm 内建

⬜ **10.2.1 x86_64 inline asm**

  - 支持 `asm!("syscall", in("rax") nr, in("rdi") a0, ...)` 语法
  - 覆盖：syscall 指令 / cpuid / rdtsc / mfence / barrier

⬜ **10.2.2 arm64 inline asm**

  - 同上，arm64 指令

⬜ **10.2.3 Windows inline asm（或等价 intrinsics）**

  - Windows 不支持 inline asm（MSVC），用 intrinsic 或纯 asm 文件替代

### 10.3 函数指针完整支持

⬜ **10.3.1 fnptr 类型表达**

  - `let f: fn(i32) -> i32` 类型完整支持
  - 与 Cap-fn-ptr（4.1.6）合并收口

⬜ **10.3.2 fnptr cast + indirect call**

  - `uintptr_t → fnptr` cast 合法化
  - 间接调用 `(*f)(args)`

⬜ **10.3.3 fnptr 作为参数 / 返回值 / 结构体字段**

  - 全场景支持（C ABI 兼容）

### 10.4 原子操作内建

⬜ **10.4.1 atomic_load / atomic_store / atomic_cas**

  - .x 原子内建，替代 C11 stdatomic / GCC __atomic

⬜ **10.4.2 内存屏障内建**

  - acquire / release / seq_cst 语义

### 10.5 SIMD 内建

⬜ **10.5.1 x86 AVX / SSE 内建**

  - .x SIMD 向量类型 + 内建操作

⬜ **10.5.2 ARM SVE / NEON 内建**

  - 同上，arm64

### 10.6 平台线程原语内建

⬜ **10.6.1 Linux futex / clone / mmap 栈**

  - .x 直接调 syscall 实现线程，不经 libpthread

⬜ **10.6.2 Windows CreateThread / WaitForSingleObject**

  - .x 直接调 NT API

⬜ **10.6.3 互斥锁 / 条件变量 / 信号量**

  - 基于 10.6.1/10.6.2 实现 .x 线程原语

### 10.7 可变参数 va_list 内建

⬜ **10.7.1 va_list 类型 + va_start / va_arg / va_end**

  - .x 可变参数支持
  - 用于 reportf / vsnprintf / 诊断深路径

⬜ **10.7.2 .x 自实现 vsnprintf**

  - 替代 libc vsnprintf

---

## 阶段 11：xbuild + Makefile 退役 Track MG（**用户终局主闸门**）

> **定义**：用 **xbuild（纯 .x + 必要极薄 shim）** 接管依赖分析、编译、链接、自举 stage、L4/bstrict 编排，**物理删除 Makefile**。  
> **前置（硬）**：阶段 8.3 glue/ast 与阶段 7/8 pin **不必 100% 完成才允许启动 11.0**；但 **11.3 物理删除** 前必须 BC 层不再强制 `$(CC) -c` 业务 C。  
> **目标入口**：`xbuild build` / `xbuild test` / `xbuild bootstrap` / `xbuild cold-test` 替代 `make` / `make -C compiler …`。  
> **既有半路径**：`./xbuild`→`xlang-build.sh` · `g05_*.sh` · `build.x`（策略）· 根 Makefile **help-only** — **禁止再开第三套编排**。

### 11.0 Makefile 瘦身（可与阶段 7–10 **并行** · 早启动）

> **目的**：在 residual C 仍存在时，先把「编排权威」从 Makefile 挪走，避免终局时一次性改 3445 行。

✅ **11.0.1 盘点 `compiler/Makefile` 规则 → 迁移表**（2026-07-29）

  - 分类：冷启动 bootstrap / `*_x.o` / seed pin cp / g05 已覆盖 / 测试·prove / Windows / 死规则
  - 产出：**[`analysis/Makefile迁移表.md`](Makefile迁移表.md)**（288 唯一目标 · 类 A–O）+ 本文附录 E 摘要
  - xbuild 拟目标命名已挂表；迁移完成定义见迁移表 §0

✅ **11.0.2 产品路径 0-make 验收**（静态 ✅ · class-G filtered ✅ · PATH 探针 ✅）

  - 在 **不** `make -C compiler` 的前提下：仅 `xlang-build.sh` / g05 完成 `xlang`/`xlang_asm` 链 + 矩阵
  - **静态闸门**：`tests/run-product-path-zero-make-gate.sh`（allowlist 冻结 g05 日常 `make`；**post_ship MF-absent** thin-call→shell／catalog；防回退）
  - pipeline filtered → shell；其余 partial-filter + 共用 `filter_o_export_against_deps.sh`；g05_ensure Darwin trio 纯 shell
  - 运行时 PATH 探针：`tests/run-product-path-zero-make-path-probe.sh` — shadow make/gmake；help + g05_relink_env + ensure/prepare 须 **0-exec** make
  - **仍非日常 0-make**：FULL=1→make bstrict（g05 白名单）；嵌套 `tests/run-all-*.sh` / ensure 内 make（11.2.3）

✅ **11.0.3 冷启动路径减 make**（§5b 全 🟢；叶清单→mk）

  - ✅ 类 G 全 4 filtered.o = 纯 shell；冷启动 `$(MAKE)` **白名单**：[Makefile迁移表.md](Makefile迁移表.md) §5b
  - ✅ 编排 / 链接 / rebuild / host-stubs / check-abi / asm-host → shell 权威；Makefile 薄叶子 + export
  - ✅ 叶清单 / 组合体定义 → `compiler/mk/*.mk`（G.7 单权威；catalog 18 keys）
  - ✅ FULL=1 / 冷路径编排已 shell；**Makefile 已物理删除** — 不再经 make 白名单叶
  - ✅ `tests/lib/compiler-make.sh` **0-make** 分发（formal_mod / std_x / try-heat / bootstrap / g05）；formal_std + net-tls ensure 命令串 → bash hub（.x + seed）

✅ **11.0.4 根 Makefile 只保留 help → xbuild → 已物理删除**

  - ✅ OBJS 叶 + 组合体 → `compiler/mk/*.mk`；`export-obj-catalog` + `driver_seed_obj_catalog.sh`（禁 shell 双清单）
  - ✅ **`./xbuild`** 薄转调 **`xlang-build.sh`**（G.7 同体）；根 Makefile 已物理删除
  - ✅ compiler/Makefile 编排权威 → catalog/shell/g05；**文件已 git rm**

### 11.1 核心功能

🟡 **11.1.1 依赖图分析**

  - 扫描 .x import / seed 输入 / 平台条件；增量重编
  - 对齐 code-review-graph 思路可选，但 **权威在 xbuild**
  - ✅ 编排 DAG **库存** — `compiler/docs/BUILD_DAG.md` + `product_build_dag.sh` dump/`--check`；`./xbuild product-dag`；产品日路径 + 冷启动节点/owner；G.7 禁第二套列表（仍 mk/catalog）
  - ✅ `DRIVER_SEED_PREREQS` **边满足** → `driver_seed_ensure_prereqs.sh`（catalog 列表 + glue companion）
  - ⬜ 终局：import 扫描 + 增量图执行（依赖 11.1.2）；叶 pattern residual → 11.3.1

🟡 **11.1.2 编译调度（.x → .o）**

  - 默认 **asm backend**（BC 终局）；过渡期允许显式 `host-cc` 仅编 **白名单 residual C**（清单来自 8.3/9，逐步清空）
  - 并行：线程原语（10.6）就绪前可用进程池 / 外部 ninja 过渡（**过渡须标 temporary**）
  - ✅ 编排图 **schedule 执行** — `product` / `refresh` / `cold` 命名调度；`--dry-run` / `--run`；`run` 只转调既有 shell 体（G.7 禁双路径）
  - ✅ cold 调度首节点 `cold_ensure_prereqs`；live outer 内嵌 shell ensure
  - ⬜ 终局：.x import 增量图 + 并行；冷启动叶不经 make pattern（与 11.3 同闸）

🟡 **11.1.3 平台处理**

  - Linux / macOS / Windows 路径·ABI·seed 选择
  - 替代历史 Makefile `UNAME` / Alpine 等
  - ✅ 权威 `compiler/docs/PLATFORM_LINKER.md` + `host_platform_linker.sh`；`./xbuild host-platform`
  - ✅ 叶 UNAME residual 类 **R2** 已在 `LEAF_PATTERN_RESIDUAL.md` 命名
  - ⬜ 终局：UNAME 叶 pattern 全吞（与 11.3.1 同闸）；禁 shell 第二套 uname 矩阵

🟡 **11.1.4 链接器调用**

  - 直接调 `ld` / `lld` / `link.exe`（syscall 或 raw FFI / 过渡 `posix_spawn`）
  - **禁止**默认 `$(CC) -o` 当链接器（避免偷偷拉 cc）
  - ✅ 策略库存 — prefer `xlang_asm_invoke_ld_platform` + direct ld；命名 residual `SEED_LINK_CC -o`；`./xbuild linker-policy`
  - ✅ cold / g05 product **pure-ld**（`pure_ld_shared.sh`）；eligible 路径 hard fail on pure miss；named CC residual only `FORCE_CC` / ineligible
  - ⬜ 终局：Windows PE pure-ld · 无任何 residual `CC -o`（含 FORCE_CC 逃生口收敛）

🟡 **11.1.5 填实 `build.x` 策略源**

  - ✅ 根 `build.x` 英文策略图（产品/冷启动/残余叶/xbuild 目标映射）；三函数 ABI 保持 pin-compatible
  - ✅ `build.x` §F 挂 BUILD_DAG / product-dag / schedule / ensure_prereqs / host-platform / linker-policy
  - ⬜ 终局：DAG-as-data 替代 C build_runtime 步表（依赖 11.1.1–4 执行层）

🟡 **11.1.6 吞并 g05 脚本族**

  - `g05_ensure_relink_prereqs` / `g05_relink_env` / `g05_relink_xlang` / `g05_prepare_and_relink` / `build_xlang_asm.sh`
  - ✅ `./xbuild ensure|link-env|link-product|link-product-asm` 直调 g05 shell（**零 make**）
  - ✅ `run_compiler_make` 与 tests hub 合体 → `tests/lib/compiler-make.sh`（G.7 单体）
  - ✅ `refresh_xlang_asm_gate.sh` / `migrate_x_objs.sh` / `ensure_migrate_gen.sh` / `lexer-gen` / `driver-gen` / `lsp-gen` / `pipeline-gen` / `archaeology-gen` 唯一体 + `./xbuild` 入口
  - ⬜ 终局：xbuild 内建或单一 `scripts/g05` 族；无 make 间接调用 / seed prereq 图（与 11.3 同闸）

### 11.2 自举 stage + 测试/CI 编排

⬜ **11.2.1 stage1 → stage2 → stage3 编排**

  - seed_xlang → xlang_v1 → xlang_v2 → xlang_v3；自动 v2==v3

✅ **11.2.2 L4 真冷全测集成**

  - 权威：`./xbuild l4`（别名 `l4-cold`／`true-cold`／`product-l4`）→ `compiler/scripts/product_l4_true_cold.sh`
  - 全擦 `compiler|std|core` `.o` + 删产品二进制 → seed pin → `bootstrap-driver-seed` → g05 → 矩阵 → `XLANG_BSTRICT_SKIP_BUILD=1` 全量 bstrict
  - 钉盘双端 L4 + bstrict 129 ✅ @ **`f7424ae47`**（mac 63m38s · Ubuntu 24m45s）
  - 残：COMPILE 仍 host-cc（零 cc 属阶段 12／13.2.1）；**不跑** `xlang check`

✅ **11.2.3 prove / bstrict / gate 脚本去 make**

  - `tests/**/*.sh`（含 `tests/lib/*.sh` · `bench/**/*.sh` · `tests/docker/*`）中 `make -C compiler` 清零或改为 `xbuild` / `xlang_compiler_make`
  - ✅ `tests/lib/compiler-make.sh` 单入口 `xlang_compiler_make`；tests/lib **0** raw `make -C`（hub 外）；`XLANG_COMPILER_DIR` 支持 nolibc
  - ✅ `tests/run-*.sh` **0** raw `make -C`（~456 脚本 → hub）；图仍 Makefile 至 11.3
  - ✅ 全仓 `tests/**/*.sh` 0 raw make -C（bench 本无 make -C，vacuous close）；CLI 模式供 xbuild 共用 hub
  - docker CI 外层 / 11.2.5 workflow ✅

⬜ **11.2.4 Windows 入口**

  - 非金标但终局须有 xbuild 路径（MSYS2）；禁止「只 Linux 删了 Makefile」
  - 🟡 CI Windows job 已 `./xbuild compiler-all`；本地 MSYS2 入口仍待 11.2.4

✅ **11.2.5 `.github/workflows/*.yml` CI 去 make/cc（外层）**

  - `ci.yml` / `ci-nightly.yml` / `selfhost-stage2.yml` / `release.yml`：构建入口 → `./xbuild compiler-all` / `bootstrap-driver-seed` / `compiler-make` / shell `clean`
  - `bootstrap-seeds-capture.yml`：无 `make -C`（仅装 gmake 包）
  - 实现层仍经 `xlang-build.sh`→`run_compiler_make` 触 Makefile 图（至 11.3）；guest 仍装 host-cc/make（零 cc 属 12）

### 11.3 Makefile 物理删除（**终局硬指标** · ✅ 已完成）

✅ **11.3 residual · prereq 边吞并 → 物理删 Makefile**

  - ✅ `driver_seed_ensure_prereqs.sh`：catalog 展开 `DRIVER_SEED_PREREQS` + glue companion；`--dry-run` / `--check` / `--run`
  - ✅ `bootstrap_driver_seed.sh` step 0 调 ensure；历史 Makefile 薄 phony 已删除
  - ✅ `./xbuild driver-seed-prereqs`；cold dry-run 印 `PREREQ=` 边
  - ✅ 叶 pattern / host-cc residual → shell ensure + **Makefile 物理删除**
  - ✅ R1–R6 叶路径（host-cc seed / UNAME stamp / thin+rest / rebuild / CI / pure-ld）→ catalog + shell
  - ✅ g05 prefer 族 / pure-ld 与 cold 同体（无 silent CC fallback）

✅ **11.3.1 路径 · 叶 pattern residual + 物理删除**

**状态**（波次流水只写 `自举进度.md` · 本文件只保留 ✅/🟡/⬜）：

- ✅ 权威图：`compiler/docs/LEAF_PATTERN_RESIDUAL.md`
- ✅ 机检：`leaf_pattern_residual.sh` / `phys_del_makefile_gate.sh` **post_ship**（MF 缺席绿、无 stderr 噪声、无「unexpected early delete」假文案）
- ✅ R1 host-cc seed · R2 UNAME stamp · R3 thin+rest · R4 rebuild pattern bodies · R5 CI all · R6→11.1.4
- ✅ B1–B7 命名桶 + phys-del prep + Windows gate + dual-end verify
- ✅ R4 / B 桶列表 → `mk/*.mk` + catalog/shell ensure（bootstrap 默认冷路径 0 make）
- ✅ **B7 residual endgame · physical delete / 删 Makefile**
  - ✅ lists/thin 收口 · Windows tip 复证 · Mac/Ubuntu L4 · 用户授权 → **已 ship 物理删体**
  - ✅ heat / STATUS / TREE_ARMED / delete-body honesty / std_x·formal_mod·bags→mk / FORCE thin / 全 phony shell-primary
- ✅ **物理删 `compiler/Makefile`**

✅ **11.3.1 删除 `compiler/Makefile`**

  - ✅ 迁移表有主 shell/catalog；R1–R5 / B1–B7 / heat / preflight / gates / dual L4
  - ✅ `xlang-build.sh` bootstrap → 直调 `bootstrap_driver_seed.sh`；host_stubs catalog
  - ✅ **物理删除** 根 + `compiler/Makefile`；ensure CFLAGS → catalog；钉盘 `77b334842`
  - ✅ post-delete residual（0-make hub · gate/leaf post_ship · catalog bags · ensure_* `--check`）
  - ✅ BC 库存机检：`bc_host_cc_product_inventory.sh` / `./xbuild bc-inventory --check` · 8.3.1 ctfe+assign+coerce_init+method_call+check_block · 8.3.9 孤儿 absent
  - 🟡 8.3/7/8 residual C **仍在**（host-cc 编；MG 编排层已独立完成，BC 层另计）
  - 验收 grep：
    ```
    rg -n 'make -C compiler|compiler/Makefile|\bmake\s+-C|\$\(MAKE\)' \
       tests scripts tools editors .github analysis build.sh xlang-build.sh
    ```

✅ **11.3.2 删除仓库根 `Makefile`**

  - 入口：`./xbuild` 或 `./xlang-build.sh` → xbuild（根 Makefile 已不存在）

⬜ **11.3.3 删除/归档其它 make 碎片**

  - 子目录 Makefile（`editors/tree-sitter-xlang/Makefile` 等）
  - 生成 compile_commands 对 make 的依赖等

⬜ **11.3.4 「无 make + 无 cc」CI 闸门**

  - `PATH` 无 make **且** cc/gcc/clang 被 stub 拒绝时，xbuild cold-test + 129 仍绿
  - 验收 grep（同时搜 make 和 cc）：
    ```
    rg -n 'make -C compiler|compiler/Makefile|\bmake\s+-C|\$\(MAKE\)' \
       tests scripts tools editors .github analysis build.sh xlang-build.sh
    rg -n '\bcc\b|\bgcc\b|\bclang\b|\$\(CC\)' \
       tests scripts tools editors .github analysis build.sh xlang-build.sh
    ```
    仅考古或第三方（tree-sitter）

### 11.4 根脚本 / tools / docker 去 make+cc（**原文档大漏**）

> **背景**：阶段 11.0–11.3 只点 Makefile 与 tests/，**漏了根脚本、tools/、scripts/、docker/ 中的 make/cc 调用**。这些是「零 cc 链」的硬障碍。

✅ **11.4.1 `build.sh`（根目录）薄转发 `./xbuild`**

  - 旧体：直接 `cc` 链 `build_tool`（双权威 + 已坏变量 `$LINK_SHU`）
  - 现体：默认 `./xbuild build`；参数透传任意 xbuild 目标；**0× host-cc**
  - host-cc residual 仅 `compiler/scripts/build_tool.sh`（至阶段 12）

✅ **11.4.2 `xlang-build.sh` 产品路径 0× make -C；CI hub 单点**

  - 产品目标（build/clean/test*/bootstrap-* 烟测）已 shell
  - ✅ `bootstrap-driver-seed` **不再**经 `run_compiler_make` → 直调 `bootstrap_driver_seed.sh`
  - ✅ `run_compiler_make` / `tests/lib/compiler-make.sh` **0-make** 分发（无 make -C）；`compiler_all_ci` 直 g05 + ensure_xlang_c
  - 外层 `./xbuild compiler-make <args…>` 目标名不变

✅ **11.4.3 `scripts/docker-ci-local.sh` 外层 0× `make -C`**

  - 全矩阵段 → `./xbuild clean|compiler-all|test_*|bootstrap-*|compiler-make …`
  - 与 11.2.5 同入口；guest 仍需 build-essential（零 cc 属 12）

✅ **11.4.4 `tools/verify-xlang-migration.sh` 提示 → xbuild**

🟡 **11.4.5 `tests/docker/linux-dev.Dockerfile`（入口文档）**

  - ✅ `XLANG_PREFERRED_ENTRY=./xbuild` + `org.xlang.entry` label
  - ⬜ 仍装 `gcc make`（build_tool / seed / bench 差分 residual；**卸包装 = 阶段 12**）

✅ **11.4.6 `tests/lib/delete-one-c-file.sh` → `./xbuild`**

  - host + Docker 回归：`./xbuild bootstrap-driver-bstrict`（无 raw `make -C`）
  - bare ubuntu guest 仍可 apt residual gcc/make（至阶段 12）
### 11.5 tests/ 对照 C 文件处理策略（**零 cc 终局下的归属**）

> **背景**：`tests/` 下有 ~200 个 .c 文件（bench/、std-*/、abi/、leak/、safe/、kernel/），当前需 host cc 编译做对照/smoke。阶段 8.3 只管 compiler/ 内 residual C，**完全没覆盖 tests/ 下的对照 C**。零 cc 终局下必须决定它们的归属。

🟡 **11.5.1 `bench/**/*.c`（~50 个）对照基准 C**

  - `loop_i32.c` · `mem_copy.c` · `simd_dot.c` · `struct_param.c` · `call_boundary.c` · `zero_copy_sendfile*.c` · `regex_match_*.c` · `http_bench_server.c` · `net_*.c` · `io_*.c` · `async_*.c` · `diff/d1_int_arith.c` ~ `d6_mem_ops.c`
  - **策略裁定**：**永久 host-cc 白名单（仅差分/对照基准）** — 不进产品路径、不进 g05、不经 `./xbuild all`；与 `.x` 对照测时由 bench 脚本显式 `cc`（标 temporary residual 至阶段 12 零 cc 终局复审）。优先路径：有 `.x` 孪生则产品侧只编 `.x`；裸 `.c` 不强制本波改写
  - 权威清单：`tests/HOST_CC_POLICY.md` §11.5.1

🟡 **11.5.2 `tests/std-*/*.c`（50 个）std 模块 smoke 测试 C**

  - `tests/std-sqlite/*_ok.c` · `tests/std-elf/*_ok.c` · `tests/std-crypto/*_smoke*.c` · `tests/std-math/*` · `tests/std-config/*` · `tests/std-uuid/*` · `tests/std-ffi/*` · `tests/std-trace/*` · `tests/std-context/*` · `tests/std-base64/*` · `tests/std-tar/*` · `tests/std-task/*` · `tests/std-log/*` · …
  - 被 `tests/lib/std-*.sh` 用 host cc 链接 **已编好的** `std/**/*.o`
  - **策略裁定**：**永久 host-cc 白名单（C smoke harness only）** — 不进 g05 / `./xbuild all` / 产品编译器链接；产品绿以 bstrict / `.x` 闸门为准；改写为 `.x` 属阶段 12 复审，不挡 11.3
  - 权威清单：`tests/HOST_CC_POLICY.md` §11.5.2（50 路径 + 闸门 floor ≥40）

🟡 **11.5.3 `tests/abi|leak|safe|kernel/*.c` 探针 C**

  - `tests/abi/layout_abi.c` · `tests/leak/leak_probe.c`（cc -fsanitize=address）· `tests/safe/race_probe.c` · `tests/kernel/freestanding_stubs.c`
  - **策略裁定**：**永久 host-cc 白名单（ABI / sanitizer / freestanding 探针）** — 依赖 host 工具链能力；不进产品链；权威见 `tests/HOST_CC_POLICY.md` §11.5.3

🟡 **11.5.4 `tests/probes/**/*.c` prove/seed 工具产物**

  - `seed_optional/*/optional_gen.c` · `prove_x_o/*/{*.gen.c,*.raw.c,*.seed.probe.c,*.merged.probe.c,thin.c}` · `bootstrap-parser/{csv_core,json_core}_gen_probe*.c`
  - **策略裁定**：**非产品 residual 类** — 工具/生成物；多数不入库；随 prove→xbuild 收缩；禁止扩成产品 host-cc 债。权威：`tests/HOST_CC_POLICY.md` §11.5.4

### 11.6 editors/ 与文档去 make（**用户指南同步**）

⬜ **11.6.1 `editors/tree-sitter-xlang/` 第三方 grammar**

  - 自带 Makefile + binding.gyp + Cargo.toml(cc crate) + bindings/rust/build.rs
  - 策略：git submodule / 独立 release / 删除（与 xlang 自举链解耦）

✅ **11.6.2 `editors/vscode/` 用户提示语**

  - package.nls.* · l10n.bundle.* · src/lspClient.ts · README · editors/LSP接入.md
  - 全部改为 `./xbuild bootstrap-driver-seed`（Makefile 已删）

✅ **11.6.3 `README.md` / `README_zh-CN.md` 用户指南**

  - 首次/日常/贡献入口 → `./xbuild build-tool|first-time|build|full|bootstrap-driver-seed|compiler-make`
  - MG 状态改为 Makefile **已删**；钉盘摘要对齐 `77b334842`


---

## 阶段 12：冷启动路径重设计（零 cc 链 · BC 层）

> **定义**：从最小 seed 到完整产品，**不出现 host cc/gcc/clang**（§0.1 BC + 编排 MG）。  
> **前置**：阶段 10 + 阶段 9 + 阶段 8.3 足够；阶段 11 xbuild 可驱动冷启动。  
> **目标**：`最小 seed → xlang → xbuild → 完整产品`。  
> **探针纪律**：asm 扩覆盖 **每文件 timeout**；禁止无界扫描 mega（如 `runtime_pipeline_abi.x`）。

### 12.0 零 cc 基建（编排 + 门禁 + emit 根修 · 进行中）

✅ **12.0.1 LINK 零 host-cc**

  - 权威：`pure_ld_try_link`（final）+ `pure_ld_partial_merge`（`ld -r`）  
  - L4 链步 + g05 final 可 `XLANG_ZERO_CC_LD=1` 走 pure-ld  
  - flag 未设时 `$CC -r`／`$CC -o` 零回归

✅ **12.0.2 `.s` COMPILE 零 host-cc**

  - 权威：`pure_as_compile`（`XLANG_ZERO_CC_AS=1` → `as -o`）  
  - ensure／g05／build 路径上 panic／f64_bits／crt0 等 `.s` 全覆盖  
  - stub：`emit_asm_text_stub_o` 运行时 weak `.s`（非 `.c` stub）

✅ **12.0.3 `forbid_host_cc` 门禁**

  - `compiler/scripts/forbid_host_cc.sh` · wrapper 覆盖 `$CC`  
  - `build_xlang_asm`／`ensure_host_cc_seed_o`／g05 系列 source  
  - `XLANG_FORBID_HOST_CC=1` 硬拦；`LOG_ONLY` 可审计（COMPILE 主体仍为 X-emit temp C + seed `.from_x.c`）

✅ **12.0.4 asm STRING_LIT 空串／长度 cap（CG002 根修）**

  - 权威：`backend_call_dispatch.x` + seed／surface 同语义  
  - `slen==0`（`""`）合法；上限 **126**（x86 short-jmp + NUL；旧 seed 错 cap 63）  
  - 验收：`diag.x`／`runtime_driver_diagnostic.x`／`runtime_driver_abi_thin.x` `-backend asm -c` rc=0  
  - 路径：`glue_asm_emit_jmp_skip_string_then_lea`／`glue_asm_emit_string_lit_ptr_rax_elf_c`／fmt string-lit import

✅ **12.0.6 module const 嵌套 binop 左结合 load（CG002 根修）**

  - 权威：`glue_try_binop_load_operand_elf_c`（`runtime_pipeline_abi` seed + `.x`）  
  - 无 stack slot 的 `export const`：`asm_module_top_level_const_lit_i32` → imm 写入 rax／rbx（对齐 emit_expr_fast）  
  - 闭合：非首函数 `((A+B)+C)`／`W\|C\|T` 左结合路径；`src/runtime/rt_fs_open.x` rc=0  
  - 探针纪律：每文件 timeout；禁无界扫 mega

✅ **12.0.7 empty STRUCT_LIT 数组字段 `[]` + emit／lsp_diag CG002**

  - 权威：`glue_struct_lit_store_fixed_array_field_elf_c`（`.x` + seed）— 空 ARRAY_LIT ≡ 零初始化（≤1024 逐元；>1024 接受不爆破）  
  - `lsp_diag.x`：修复 `lsp_build_semantic_tokens_response` 尾部 stub／`*/` 源损坏（表象 `copy_bytes` fail）  
  - `emit.x` `run_x_emit_x`：巨型 `PipelineDepCtx`／`CodegenOutBuf` 不用 `data: []` STRUCT_LIT；标量 lit + uninit/`length=`  
  - 验收：`empty8`／`lsp_diag.x`／`emit.x` `-backend asm -c` rc=0；L2 5/5

🟡 **12.0.5 asm backend 模块覆盖（`.x`→`.o` 直出替 `-E`+`$CC -c`）**

  - 目标：g05／ensure 中 COMPILE 对象逐步走 `xlang -backend asm -c module.x -o module.o`  
  - **G.7 权威 helper**：`pure_asm_x_to_o`（`compiler/scripts/pure_ld_shared.sh`）— 需 ambient `XLANG_PREFER_ASM_O=1`；`*.o` 暂存；拒 U `xlang_panic`／裸 `__error`  
  - **Darwin call mangling ✅**：`macho_leading_underscore` 对 C 名**一律** prepend `_` → `__error`→`___error`  
  - **pure_asm 覆盖（mac）**：`rt_*.x` **23/23** ✅；hybrid thin **18/18**；labi **12/12** ✅（fixed-array bounds 对等闭）  
  - **产品 hybrid pure-asm 默认 ✅（2026-08-12 用户授权）**：`labi_prefer`／`rt_prefer`／`g05_try` 均 scoped 默认 pure-asm（`PREFER_ASM_O_{LABI,RT,G05}` 默认 1；子 shell 设 PREFER_ASM；逃逸 `=0`）· pipeline_abi mega 硬禁 · G.7 单权威 `pure_asm_x_to_o`
  - **树级 PREFER 硬闸 ✅（2026-08-12）**：G.7 `xlang_strip_tree_prefer_asm_unless_allowed`（ensure／g05 入口）· 无 `XLANG_ALLOW_TREE_PREFER_ASM=1` 则 strip 环境级 `PREFER_ASM_O=1` · family=0 时 prefer try 再 `unset PREFER`（逃逸不被 ambient 顶回）· 地图／bisect 须显式 ALLOW_TREE
  - **ALLOW_TREE 树级 PREFER 地图 bisect ✅（2026-08-12）**：仅 `ALLOW_TREE=1` 保留 ambient PREFER · **B2** full hybrid force labi + soft g05 双端矩阵 **5/5**（mac link 384k／Ubuntu 450k）· **C** family=0 无 ALLOW → strip + cold（mac 306k／Ubuntu 317k）· **D** family=0+ALLOW re-leak → pure 装链 + 矩阵 **5/5**（有意诊断路径）· **E** 产品默认恢复 **5/5** · **拒默认化**树级 PREFER（prefer 族已默认 pure-asm；pipeline_abi mega 仍硬禁）· 日志 mac `/tmp/xlang_allow_tree_map2_mac_20260812_154317.log` · Ubuntu `/tmp/ubu_allow_tree_map_20260812_155648.log`
  - **pipeline_abi mega pure-asm 硬禁收口 ✅（2026-08-12）**：G.7 三层——①`pure_asm_x_to_o` basename `runtime_pipeline_abi.x` **秒拒** ②`ensure_pipeline_abi_prefer_one` 强制 `XLANG_PREFER_ASM_O_RT=0`（产品 thin 永不进 pure_asm）③`pure_asm_emit_with_timeout` 默认 90s hang guard（`XLANG_PURE_ASM_TIMEOUT_SEC`）。hybrid 仍 -E thin+rest；双端 L2 5/5 @ tip `af5e621e6`  
  - **typeck 墙钟瘦身 ✅（2026-08-12）**：prim BSS + compound G.7 thin→`pipeline_type_find_or_alloc_compound` + stmt_order 迭代 · mac **361s→60s**／Ubuntu **75s**（hang 闭；emit rc=0）  
  - **pipeline_abi mega pure-asm 产品装链 residual**：hang 非根因；pure-asm .o U `xlang_driver_*_opaque`（-E prologue only）→ product basename skip + RT=0 hybrid thin（禁白跑 pure 再 hybrid）  

  - **Ubuntu pipeline_abi thin inject first-wins ✅（2026-08-20）**：产品默认 `$CC -r` 补 `-Wl,--allow-multiple-definition`（G.7 `pure_ld_partial_merge`；ZERO_CC 已直传 ld）。sit-red leftover 强符号 → inject restore-base。证：Ubuntu reent／arrcopy inject **OK** ELF 单 T · 矩阵 **5/5** · Darwin libtool 无回归
  - 下一刀候选（本域）：pipeline_abi mega 仍硬禁／Darwin tip 真冷 L4 再核。**Darwin 冷矩阵 CG002 ✅**（`pure_ld_darwin_force_load_prefer_archives`）· **sat L4 身份 Ubuntu ✅** · **ALLOW ensure 再瘦库存空 ✅**（无 path-nonempty always-push sit-red）。leftover extra peels PARAM PTR-elem ndims≥1 `**[2][]T`／`**[2]*T` leftover mismatch T001 已闭；extra empty `[]`／extra STAR unused-slot ARRAY／SLICE／PTR 元 × 外层 PARAM 与 RET 已齐；leftover extra SLICE peels leftover eek＝PTR eand＝−2（`[]*[]T`／`[]*[][]T`）**已闭**（8／21 PARAM＋RET）；dest extras dest-PTR stamp ✅；asm 库 TU `.data` ✅；g05 Darwin `-multiply_defined`／`__DATA,__common` ✅；fmt pure-asm format ✅；Darwin `__common` align 软警 ✅（Mach-O COMMON `n_desc` GET_COMM_ALIGN）
  - **单 slice 二分 harness ✅**：`XLANG_PREFER_ASM_O_ONLY`（G.7 `pure_asm_x_to_o` allow-list）  
  - **INDEX `**T` 双剥皮闭 ✅**（`pipeline_asm_index_elem_byte_sz_c` pure+seed）  
  - **真 L2 地图（prefer + soft g05_relink + matrix）**：  
    - **IN_NO_C GREEN**：`rt_util`／`rt_run_x_emit`／**`rt_content`**／**`rt_run_compiler_parsed`**／**`rt_emit_flags`**／**`rt_dispatch_impl`**／**`rt_lib_root`**／**`rt_run_asm_backend`**（及早前若干 real thin）  
    - **VACUOUS**：`rt_run_exec`（seed 冷）· **SEED_SLICE 外链**（`preamble`／`stack`／`arena_buf`／`emit_state`／`parse_diag`）→ `ONLY=` **不改** `runtime_driver_no_c.o`  
  - **`rt_content` 根因钉（已闭）**：①i32 VAR load sxtw ✅ · ②AAPCS64 9 参 stack-before-GP ✅ → **`ONLY=rt_content` 5/5**  
  - **`rt_run_compiler_parsed` 根因钉（已闭 · 再闭 2026-08-12）**：①frame spill sum walk **ASSIGN 28..38** ✅ · ②i32 call-ret harvest sxtw/zxt（seed）✅ · ③i32 binop add/sub/mul 后 sxtw ✅ · ④**pure `.x` `glue_asm_emit_call_with_cleanup` 补 harvest** ✅（产品半残无 sxtw → try_c `rc==-2` 假失败 shell 254；`glue_asm_harvest_call_ret_to_gpr_c` 权威）→ **`ONLY=rt_run_compiler_parsed` 真 L2 5/5** · **full multi-slice hybrid mac 5/5**  
  - **`rt_emit_flags` 根因钉（已闭）**：`pipeline_asm_index_elem_byte_sz_c` 对 base PTR **双剥皮**（pre-peel + glue 再 peel）→ `**u8` esz=1 · `argv[i]` scale1+ldrb SEGV；改单 peel 传 base `tr` + fallback 调 glue · seed 孪 ✅ → **`ONLY=rt_emit_flags` 真 L2 5/5**  
  - **`rt_dispatch_impl`／`rt_lib_root`（连带闭）**：前序 ABI 刀后复探 **真 L2 5/5**（无本波新代码）  
  - **`rt_run_asm_backend` 根因钉（已闭）**：`asm_module_is_typeck_selfhost` 裸 ndef 误判 + coarse raw `func_index` → pure-asm 全 ret0 stub → 静默 rc=0 无 bin；删 ndef-only + defined ordinal · seed 孪 ✅ → **`ONLY=rt_run_asm_backend` 真 L2 5/5**  
  - **labi FAIL_ABI 根因钉（已闭）**：`glue_emit_index_bounds_guard_elf_c` fixed non-lit 变下标曾 U `xlang_panic_`（host -E 无）；改 skip fixed non-lit · slice/lit OOB 仍 panic · seed 孪 ✅ → **labi pure_asm 12/12**  
  - **labi hybrid 真 L2 地图 ✅**（`try-labi-prefer` + soft g05 + matrix + restore；矩阵须 hybrid 本波 `xlang`）：  
    - 历史：`ONLY=__none__` **5/5** · 早期全量 12 层 pure-asm **0/5 SEGV**（pre residual ABI）  
    - **GREEN×12 pure-asm ONLY（tip `18318d0d4` 再验）**：12／12 单 slice 全 **5/5**（含原 RED ensure／invoke_*／freestanding／ondemand_heavy）  
    - **full12 pure-asm hybrid mac 再验 5/5 ✅（2026-08-12）** · restore -E **5/5**  
  - **path_pure hybrid 闭（历史）**：`glue_emit_binop_add` is_64bit → scale1 64-bit ADD  
  - **path_pure hybrid 再闭 ✅（2026-08-12 · param_home 窄整数 AAPCS）**：  
    - 根因：`labi_suffix_eq2` pure-asm 形参 `str xN` 保留高位垃圾 → suffix 匹配失败 → ld 吃 `.x` 源 BLD001  
    - 修：`glue_enc_canonicalize_param_in_rax_elf_c` + arm64 `mov Xn→X0` · param_home／f32-xmm 轨 · VAR-vs-lit cmp 走 load_var  
    - **mac ONLY=labi_path_pure hybrid L2 5/5** · restore -E 5/5 · 日志 `/tmp/xlang_pp_fix_*.log`  
  - **ensure_list hybrid 闭**：`asm_ctx_local_find_offset_scoped` 限本块（历史）· tip 再验 **5/5**（param_home 后）  
  - **invoke_cc_list hybrid 闭**：modlet `cell_size` bit30=TYPE_ARRAY LEA（历史）· tip 再验 **5/5**  
  - **ondemand_heavy hybrid 闭**：连带 residual 刀后 mac／Ubuntu hybrid **5/5** · tip 再验 **5/5**  
  - **full12 pure-asm hybrid 问题地图 ✅（历史 2026-08-11 · tip `1a66374b1` · 钉盘 `e364f4a37`）**：  
    - pure_asm 独立验 **12/12** 双端  
    - mac **14 combo** 全 **5/5**（ctrl／res1–4／green8／g8+grow／halfA／halfB／full12）· `/tmp/xlang_labi_full_prefer_map_20260811_215629.log`  
    - Ubuntu 金标 full12 hybrid **5/5** + restore baseline **5/5**  
    - **产品默认仍 -E**（`PREFER_ASM_O` 禁默认；全树／pipeline_abi pure-asm 泄漏仍禁）  
  - **full12 pure-asm hybrid tip 再验绿 ✅（2026-08-12 · tip `18318d0d4` · mac）**：  
    - 相对授权图 tip `662b5fbfe` RED×6／full12 0/5：path_pure param_home + residual ABI 后 **单 slice RED×0** · full12 matrix **5/5**  
    - link_abi≈380k · xlang≈4.6M · 日志 `/tmp/xlang_labi_full12_reauth_*.log`／`/tmp/xlang_labi_red_reprobe_*.log`  
    - **Ubuntu 金标 full12 5/5 ✅**（@ tip `6b6fcdd0c` · `/tmp/ubu_labi_full12_hybrid_6b6fcdd0c_20260812_020712.log`）  
  - **labi-only pure-asm 产品默认化 ✅（2026-08-12 · 用户明示授权 · tip 再验）**：  
    - 实现：`labi_prefer_try_x_to_o` 子 shell scoped `XLANG_PREFER_ASM_O=1` 当 `XLANG_PREFER_ASM_O_LABI` 默认 **1**；G.7 单权威 `pure_asm_x_to_o`  
    - **禁**树级 `PREFER_ASM_O=1` 默认 · **禁** pipeline_abi mega pure-asm  
    - 逃逸：`XLANG_PREFER_ASM_O_LABI=0` → labi 层 historic -E+$CC（ambient PREFER_ASM 仍可强制 pure）  
    - **mac L2 ✅**：初落地 link_abi **383928** · tip 再验 **384032** · hybrid matrix **5/5**（`/tmp/xlang_labi_default_pure_asm_5d44fa3eb_*.log`／`/tmp/xlang_labi_default_auth_mac_full12.log`）  
    - **Ubuntu 金标 ✅**：初落地 link_abi **448744** · tip **`6b15edd46`** 再验 **449920** · matrix **5/5**（`/tmp/ubu_labi_default_pure_asm_8d48a1d78_*.log`／`/tmp/ubu_labi_auth_B_full.log`）  
    - 历史授权图（tip `662b5fbfe` RED×6）：path_pure param_home + residual ABI 后已闭；full12 双端 5/5 后用户授权落地；半截 g05／坏 `xlang_asm` 会假 SEGV（先 LABI=0 冷 seed 恢复）  
 
  - **prefer 族 pure-asm 产品默认化 ✅（2026-08-12 · 用户明示授权 rt／async／R3／l2-asm…）**：  
    - 实现：`rt_prefer_try_x_to_o` → `XLANG_PREFER_ASM_O_RT` 默认 **1**（覆盖 try-rt／r3／async／l2-asm／tcpu／ldpc／other-l2／B1–B3 共用 harness）；`g05_try_x_to_o` → `XLANG_PREFER_ASM_O_G05` 默认 **1**；均子 shell scoped · G.7 单权威 `pure_asm_x_to_o`  
    - **禁**树级 `PREFER_ASM_O=1` 默认 · **禁** pipeline_abi mega pure-asm（硬禁）  
    - 逃逸：`PREFER_ASM_O_{RT,G05}=0`  
    - **mac L2 ✅**：RT=0 escape no_c=**131616** · default pure no_c=**186664** SIZE_PROOF · async×3／l2-asm×3／r3 sample · soft g05 · matrix **5/5**（`/tmp/xlang_prefer_default_v2_039d60d23_*.log`）  
    - **Ubuntu 金标 ✅** @ tip `3ac15006a`：escape no_c=**180504** · default pure no_c=**248224** SIZE_PROOF · soft g05 · matrix **5/5**（`/tmp/ubu_prefer_default_pure_asm_3ac15006a_*.log`）
  - **B1／B2／B3 pure-asm hybrid 双端 5/5 ✅**：mac 前序 · Ubuntu @ `5d44fa3eb` prefer+soft g05+matrix+restore 全绿（`/tmp/ubu_b1b2b3_pure_asm_hybrid_true_5d44fa3eb_20260812_084234.log`）  
  - **pipeline_abi mega pure-asm 问题地图 + 硬禁 ✅ 双端**：独立 pure-asm **TIMEOUT 180s** · 硬禁后 BAN wall=0s · labi pure 仍绿 · PREFER_ASM hybrid -E prefer 不挂 · mac matrix 5/5 · **Ubuntu** BAN 0s + matrix 5/5（`/tmp/ubu_pabi_hardban_20260812_104117.log`）  


  - **COMPILE residual prefer 薄叶 pure_asm 问题地图 ✅（2026-08-11 · tip `6a814b52c`）**：  
    - 对象 13 叶（l2asm×3 · tcpu×2 · ldpc · async×3 · ol2×4）；**禁** `runtime_pipeline_abi.x` mega pure-asm  
    - pure_asm **9/13 双端 OK**（初图）：l2asm 全 · tcpu 全 · ldpc · `async_asm_pool` · `seed_link_compat` · `strict_glue_thin`  
    - **FAIL×4（初图）**：`async_liveness`／`async_cps_codegen`／`runtime_lsp_glue` U `xlang_panic_` · `fmt_check_cmd_thin` CG002  
    - **L2-asm 真 hybrid 装链** pure-asm thin+rest **3/3 ✅**（`user_asm` merge residual 闭）  
  - **FAIL_ABI_panic×3 根修 ✅（2026-08-11）**：  
    - 根因：pure-asm `pipeline_asm_emit_divisor_zero_check_rbx_elf_c` 对 `/` `%` 插 CALL `xlang_panic_`；host -E 为 0 panic（C UB）  
    - 修：权威 no-op + seed cold twin 同 commit（对标 fixed-array bounds host-E 对等）  
    - 复验 pure_asm residual **12/13**（闭 al／ac／rl；仅 `fmt_check_cmd_thin` CG002）  
    - 日志 mac `/tmp/xlang_compile_residual_after_div0.log` · `/tmp/xlang_div0_matrix.log`  
  - **fmt_check_cmd_thin CG002 根修 ✅（2026-08-11）**：  
    - 根因：modlet `cell_sz>1MiB` skip → `g_fmt_file_list_paths` 4MiB 未 COMMON → `fmt_file_list_at` LEA 失败  
    - 修：G.7 护栏 **1MiB→8MiB**（`runtime_pipeline_abi.x` + seed twin）  
    - 复验 pure_asm residual **13/13** · matrix **5/5** · 日志 `/tmp/xlang_compile_residual_after_fmt_cg002.log`  
  - **tcpu／ldpc hybrid 装链地图 ✅（2026-08-11）**：  
    - 配方：`PREFER_ASM_O=1`+`FORCE try-target-cpu-prefer`／`try-ldpc-prefer` → unset PREFER → soft g05 pure-ld → matrix → restore  
    - **tcpu pure-asm thin+rest 真装链 ✅**（flags.x pure-asm · `Lxlang_ml` · soft g05 保留 · matrix **5/5**）  
    - **ldpc hybrid ✅（WEAK -E thin 与 pure-asm weak polish）**：`G05_X_O_WEAK=1` · pure_asm 现经 objcopy `--weaken` 对齐 -E 契约 · thin+rest · pure-ld · matrix **5/5**  
    - **ldpc pure-asm hybrid residual ✅ 闭**：根修 `pure_asm_apply_weak_polish`（缺 objcopy 则 fallthrough -E）；`nmedit` 不能 weak pure-asm  
    - ensure 头注释更新 · **产品默认仍 -E**  
    - 日志 mac `/tmp/xlang_ldpc_pure_asm_hybrid_true_final_*.log` · Ubuntu 金标复验 `/tmp/ubu_ldpc_pure_asm_hybrid_1218796d0_*.log`（ELF `W` ×3 · matrix 5/5 · restore 5/5）  
  - **other-l2 WEAK pure-asm hybrid 地图 ✅（2026-08-12 · tip `1218796d0`）**：  
    - 对象 4 叶（`try-other-l2-prefer`）：`seed_link_compat`（WEAK_FUNCS×6）／`strict_glue`／`fmt_check_cmd_driver`／`lsp_diag`（`runtime_lsp_glue`）  
    - pure_asm+WEAK polish 探针 mac 全绿（llvm-objcopy `--weaken`／named）  
    - **mac hybrid**（地图波）：slc／strict／lsp **5/5** · **fmt pure-ld FAIL** U `xlang_fmt_*`  
    - **Ubuntu 金标 hybrid**（地图波）：四叶 **全 5/5** 含 fmt（常 fallthrough -E）· restore **5/5**  
    - 日志 mac `/tmp/xlang_ol2_weak_pure_asm_hybrid_true_*.log` · Ubuntu `/tmp/ubu_ol2_weak_pure_asm_hybrid_1218796d0_*.log`  
  - **fmt pure-asm hybrid residual ✅ 闭（2026-08-12）**：  
    - 根修 G.7：`fmt_check_cmd.from_x.c` 常驻导出 `XLANG_WEAK xlang_fmt_{opendir,closedir,access,readdir_name}`（cold＋FROM_X rest；对等 prologue static inline 语义；Win32 opendir 宏）  
    - 辅：`pure_asm_find_objcopy` 用 `command grep`／`/usr/bin/grep` 防 shell shadow  
    - **mac** pure-asm thin+rest · soft g05 pure-ld · matrix **5/5** · restore -E **5/5**  
    - **产品默认仍 -E**  
  - **async pure-asm hybrid 装链 ✅ 双端 3/3（2026-08-12 · tip `190ab4eb3`）**：  
    - 配方：`PREFER_ASM_O=1`+`HOST_CC_SEED_FORCE=1` FORCE `try-async-prefer` ×3 → unset → soft g05 pure-ld → matrix → rm restore -E → matrix  
    - pure_asm 独立 **3/3**（div0 FAIL_ABI residual 已闭；无 U panic）  
    - **mac** hybrid thin+rest **58976／45528／16216** · matrix **5/5** · restore -E **41632／28856／11160** · **5/5**  
    - **Ubuntu 金标** hybrid **81752／57336／22256** · pure-ld 60 · matrix **5/5** · restore **52080／33016／14472** · **5/5**  
    - 日志 mac `/tmp/xlang_async_pure_asm_hybrid_*.log` · Ubuntu `/tmp/ubu_async_pure_asm_hybrid_190ab4eb3_20260812_022411.log`  
    - ensure 头注释钉 Stage12.0.5 pure-asm hybrid 双端闭 · **产品默认仍 -E**  
  - **labi full12 hybrid 双端 5/5 ✅（2026-08-12）** · **labi-only pure-asm 默认已授权并落地**（`PREFER_ASM_O_LABI` 默认 1）  
  - **labi full12 默认 pure-asm tip 再验 5/5 ✅（2026-08-12 · tip `6b15edd46` · 用户再明示授权）**：  
    - 无树级 `PREFER_ASM_O` · LABI=1 · FORCE try-labi-prefer · L0..L9+L8b+L8c prefer `.x` · soft g05 · matrix **5/5**  
    - **mac** link_abi **384032** · matrix **5/5**（`/tmp/xlang_labi_default_auth_mac_full12.log`）  
    - **Ubuntu 金标** link_abi **449920** · matrix **5/5**（`/tmp/ubu_labi_auth_B_full.log`；半截 relink 须先 LABI=0 冷 seed 恢复）  
    - 逃逸 `LABI=0`；**禁**树级 PREFER 默认 · **禁** pipeline_abi mega pure-asm  
 
  - **rt pure-asm hybrid 地图（mac · 2026-08-12）✅ 闭**：  
    - 配方：`PREFER_ASM_O=1`+`HOST_CC_SEED_FORCE=1` FORCE `try-rt-prefer` → unset PREFER → pure-ld（`set -a; eval g05_relink_env`）→ 仓根 hello／matrix → restore -E  
    - pure_asm 独立 **23/23** OK · 发射器 **baseline_E**（禁 hybrid 自污染）· hello 从仓根  
    - **半量／pair 历史地图**：halfB／q3／`ONLY=rt_run_compiler_parsed` 曾 RED（hello rc=254）；根因 = pure `emit_call_with_cleanup` 无 harvest  
    - **根修 ✅**：`glue_asm_harvest_call_ret_to_gpr_c` + pure cleanup 后 harvest · seed／surface 孪  
    - **ONLY=rt_run_compiler_parsed hybrid mac 5/5**（no_c≈141480）· **full multi-slice hybrid mac 5/5**（no_c≈186664）· restore -E **5/5**  
    - 日志 `/tmp/xlang_rcp_harvest_verify_*.log` · `/tmp/xlang_rt_full_after_harvest_*.log` · 前序 half/pair `/tmp/xlang_rt_half_bisect_v2_*.log`  
    - **产品默认仍 -E** · **Ubuntu 金标 5/5 ✅**（tip `3ad10a0ae` · ONLY=rcp no_c=191120 · full no_c=248224 · restore 180504 · `/tmp/ubu_rt_pure_asm_hybrid_3ad10a0ae_20260812_080629.log`）  
  - **B1–B3 pure-asm hybrid 地图（mac · 2026-08-12 · tip `7ca063e81`）✅**：  
    - 配方同 residual：`PREFER_ASM_O=1`+FORCE prefer → unset → soft g05 → matrix → restore -E  
    - **B1** `try-runtime-os-prefer` ×23：prefer pure-asm **23/23** · hybrid matrix **5/5** · restore **5/5**（多叶不在 pure-ld 58；装链探针绿）  
    - **B2** `try-std-core-prefer` ×5（path／runtime／slice／process／net）：prefer **5/5** · hybrid **5/5** · restore **5/5**  
    - **B3** `try-lsp-sat-prefer` ×2（sizes_nostub／stubs_no_c）：prefer **2/2** · hybrid **5/5** · restore **5/5**  
    - 日志 `/tmp/xlang_b1b2b3_pure_asm_hybrid_7ca063e81_20260812_054531.log`  
    - **产品默认仍 -E** · pipeline_abi mega 仍禁 pure-asm  
  - 下一步：用户明示后 labi-only PREFER 授权 · pipeline_abi mega 仍禁 pure-asm · 其它 Stage12 COMPILE residual





  - 未完成前冷构建仍会 `$CC -c` 编译 seed／X-emit C

### 12.1 最小 seed 设计

⬜ **12.1.1 手写 asm seed（或极简二进制）**

  - 不依赖 cc 编译的 seed
  - 选项 A：手写 x86_64/arm64 asm，经 **xlang 自带 assembler** 装配
  - 选项 B：预置极简二进制（版本钉死、可复现下载/校验）

⬜ **12.1.2 seed 能产出 xlang_v1（无需 -E→cc）**

  - 优先：seed **直接** asm-codegen 出 v1  
  - 若过渡仍 `-E`：生成物不得经 host-cc（与终局 BC 冲突 → 仅临时）

⬜ **12.1.3 与 pin 退役衔接**

  - 冷启动输入是 **`.x` + 最小 seed**，不是 `seeds/*_gen.linux*.c` 业务体

### 12.2 链路验证

🟡 **12.2.1 零 cc 验证（BC+PC）**

  - LINK／`.s` 路径可零 cc（见 12.0.1–12.0.2）；**全路径零 `execve(cc)` 仍 ⬜**（COMPILE 164 级 residual）  
  - 可选：`XLANG_FORBID_HOST_CC=1` 运行时硬失败（已实现；默认关闭）  
  - 终局验收：`strace`／`dtruss` 产品冷启动无 `cc|gcc|clang`

⬜ **12.2.2 双端冷启动验证**

  - macOS + Ubuntu；Windows 探针按 G.8  
  - 钉盘 L4 仍含 host-cc COMPILE；零 cc 冷启动双端闭环待 12.0.5 覆盖足够后做

🟡 **12.2.3 产品默认后端**（2026-08-12 · 去 import→C + seed APPLE 收敛后）

  - CLI 文案默认偏 asm；**运行时**：`driver_want_asm_emit_to_file` 默认 1，除非 argv 含 `-backend c`
  - **产品 live**：有 import 默认亦 **asm**（`compile.x`／`rt_dispatch_impl` 去 import→C ✅）；仅 generic 降级／显式 `-backend c`／check-only 走 C
  - **尺寸证（mac L2 后 APPLE 收敛）**：DEF rv／option／hello／si **size＝ASM** · 显式 C 更小 · run 42／102／0／0 · 矩阵 5/5
  - **seed `__APPLE__` exe→C**：✅ 已删冷孪 force（`rt_dispatch_impl.from_x.c` + `rt_run_compiler_parsed.from_x.c`）；与 pure `.x` G.7 对齐；历史 CG002 债已闭
  - **codegen mono `Result_*` 短名**：✅ `emit_type` 将 bare `Result_i32`／`Result_u8` → `struct core_result_Result_*`（同 Option_*）；formal shell `#define` 别名已删
  - **Arena64 formal shell 死别名**：✅ 删 `#define heap_libc_Arena64 std_heap_libc_LibcArena64`（`xlang_compile_std_module`／`xlang_compile_std_string_o`）；tip `-E` short  count=0；全名 `std_heap_libc_LibcArena64`／`std_heap_Arena64`
  - **静默 generic→C**：✅ 已删（`compile.x`／`rt_dispatch_impl`／`rt_run_compiler_parsed` + seed/surface／driver_compile pin）；产品 C 仅 opt-in
  - **`XLANG_FORBID_HOST_CC`**：✅ ensure／g05 **构建闸** + **产品 spawn 闸**（env 精确 `"1"`；`LOG_ONLY=1` 静默放行）
  - **`XLANG_ALLOW_HOST_CC`**：✅ **experimental 默认拒 spawn**（env 精确 `"1"` 才允许；`host-cc-requires-allow`；FORBID 优先于 ALLOW）
  - **`invoke_cc_host_cc_spawn_gate`**：✅ G.7 单权威（FORBID+ALLOW）；`invoke_cc_run_cc_argv` 转调；**`xlang_invoke_cc` 入口早拒**跳过 `impl` ensure／argv（deny 路径瘦身）
  - **monofile 冷孪／surface 早闸收敛**：✅ `runtime_link_abi.from_x.c` 冷面／monofile `.x`／`runtime_link_abi_surface` ≡ `labi_gates`（deny 不进 ensure／argv；产品 live 仍 L9 pure）
  - **`xlang_invoke_cc_impl` ensure／argv 再隔离**：✅ residual **顶部**再调同 gate（先于 argv／early_needs／ensure-push／need-gated TLS）；直调 impl 亦不可 ensure；三层：入口／impl／spawn
  - **ALLOW ensure need 门后移**：✅ `ensure_std_net_o_auto_tls` **不再**入口无条件调用；need scan 后仅 `need_flags[5]`（net）+ include_root；`XLANG_MINIMAL_CC_LINK` 跳过 ensure-push **且**不跑 TLS ensure（≡ time_os on-demand）
  - **ALLOW ensure 再瘦库存空**：✅ 2026-08-23 再扫 `labi_invoke_cc_list` ensure-push＝need 门控；无 path-nonempty always-push sit-red（heap 已 ondemand）
  - **ALLOW heap always-push 再瘦**：✅ `invoke_cc_append_std_ensure_push_front` **不再** path 非空即推 `heap.o`；G.7 单权威 `invoke_cc_append_heap_f06_ondemand`（nm argv + use_line + provides + page_mmap）；`.x` + seed twins + surface 同 commit
  - **ALLOW early_needs rtr 与 need 对齐**：✅ 全量 ALLOW 下 `invoke_cc_append_early_needs` **不再** freestanding 扫／推 random／time／runtime；权威仅 ensure-push front `need_flags[8/7/4]`；MINIMAL 保留 freestanding rtr（ensure-push 跳过）
  - **formal shell 短标签 residual 扫描**：✅ 矩阵 5 源 tip `-E` Result_／Option_／Arena residual=0；硬编码 type `#define` 别名已无（Result_／Arena64 已闭）；动态 bare→pref 别名机仍服务 formal_mod 体
  - **ALLOW_TREE 树级 PREFER 地图 bisect**：✅ 仅 `ALLOW_TREE` 保留 ambient · B2 full hybrid／D family=0 re-leak 双端 5/5 · **拒默认化**树级 PREFER
  - **Darwin 产品 `-o` ld-only**：✅ 跳过 clang driver；`ld -syslibroot -dynamic -arch -dead_strip -e _main`（SDKROOT／Xcode／CLT；禁 clang 回退）
  - **Linux hosted 产品 `-o` ld-only**：✅ 跳过 gcc driver；`ld`＋glibc `Scrt1`／`crti`／`crtn`＋`-dynamic-linker`＋`-pie`／`-z`（禁 gcc 回退／`-e main`）
  - **Darwin prefer hybrid merge**：✅ F7 双 `LC_SEGMENT` 使 Apple `ld -r` 拒；`pure_ld_partial_merge` Darwin `-r` 失败则 `libtool -static`
  - **Ubuntu pipeline_abi thin inject first-wins**：✅ 产品默认 `$CC -r` 包 `pure_ld_multidef_flags` 为 `-Wl,--allow-multiple-definition`（ZERO_CC 已直传 ld）；reent／arrcopy overlay leftover 单 T ELF
  - 下一刀候选：①pipeline_abi mega 仍硬禁 · ②Darwin tip 真冷 L4 再核。**Darwin 冷矩阵 CG002 ✅** · **sat L4 身份 Ubuntu ✅** · **ALLOW ensure 再瘦库存空 ✅**。leftover extra peels PARAM PTR-elem ndims≥1 `**[2][]T`／`**[2]*T` leftover mismatch T001 已闭；extra empty `[]`／extra STAR unused-slot ARRAY／SLICE／PTR 元 × 外层 PARAM 与 RET 已齐；leftover extra SLICE peels leftover eek＝PTR eand＝−2（`[]*[]T`／`[]*[][]T`）**已闭**（8／21）；dest extras dest-PTR stamp ✅；asm 库 TU `.data` ✅；fmt pure-asm format ✅；Darwin `__common` align 软警 ✅


---

## 阶段 13：终局 — 自举完成（**无 Makefile** + 零 cc 三义 + v2==v3）

> **定义**：  
> 1. **MG**：仓库无 Makefile 权威，xbuild 为唯一编排入口；  
> 2. **BC/PC**：自举与默认产品路径零 host-cc；  
> 3. **语义**：`xlang_v2 == xlang_v3`（及可选 D-03）；  
> 4. **无 pin 糊弄**：阶段 7/8/8.3 完成。  
> **前置**：阶段 7–12。  
> **节奏**：整波 Cap/R/M 收口 → L4；日终兜底见 skill §3.3。

### 13.1 语义自举验证

✅ **13.1.1 阶段 7 M4 完成**（含 7.4 typeck/codegen）

  - M4 5/5 全 ✅：runtime 7.1 · parser 7.2 · link_abi 7.3 · typeck 7.4.1 · codegen 7.4.2
  - Stage2 行为一致 + SHA256 match（见 7.1.3）
  - PREFER_X_O 双端 8/8 wave338 ✅（见 7.4.3）

⬜ **13.1.2 阶段 8 gen + 8.3 glue/ast/桩 完成**

⬜ **13.1.3 阶段 9 residual 全部消灭**

⬜ **13.1.4 v2 == v3 语义自举验证**

  ```
  seed_xlang  …  →  xlang_v1   （无 host-cc）
  xlang_v1    …  →  xlang_v2
  xlang_v2    …  →  xlang_v3
  assert xlang_v2 == xlang_v3
  ```

⬜ **13.1.5 D-03 bit-identical 验证（可选更强）**

### 13.2 零 Makefile / 零 cc 验证（**主验收**）

⬜ **13.2.1 双端 L4 真冷 + 129 bstrict（xbuild 驱动 · 零 make · 零 host-cc）**

🟡 **13.2.2 Makefile 物理删除验收**（文件层 ✅ · 零 make 调用面 🟡）

  - ✅ `test ! -e Makefile && test ! -e compiler/Makefile`
  - ✅ 产品入口 / 文档 / labi hint → `./xbuild`（无 make -C）
  - ✅ ensure 阶梯 / gen / tests / link bags shell-primary + catalog bag（MF 缺席绿）
  - ✅ `bc_host_cc_product_inventory.sh` / `./xbuild bc-inventory --check` · 8.3.9 孤儿 absent
  - 🟡 仍有 host-cc residual C（BC/PC 未闭）；逃生口 env 仍可能调 make

⬜ **13.2.3 零 cc 三义验收**（§0.1 MG+BC+PC）

  - strace 无 make/cc/gcc/clang（或 make 仅用户 PATH 偶然存在但从未被调用）

🟡 **13.2.4 labi_invoke_cc / `-backend c` 退役或隔离**

  - 产品默认不 exec host-cc；历史 C 后端进 experimental 或删除
  - **2026-08-12 地图（刷新）**：import 默认 **asm** · 静默 generic→C **已删** · seed APPLE exe→C **已删**；**`ALLOW_HOST_CC=1` experimental 才 spawn**（显式 `-backend c` alone 不足）· **`FORBID_HOST_CC=1` 硬挡**；**`invoke_cc_host_cc_spawn_gate` 入口早闸 + impl 顶闸 + spawn 再检**（deny 不 ensure／argv；**monofile 冷孪／surface ≡ labi_gates**）· ALLOW 后 **`ensure_std_net` need_net 后移**（MINIMAL 不 ensure TLS）· invoke_cc_impl 本体仍服务 ALLOW 后的 C 链 · 未删除

### 13.3 收尾

⬜ **13.3.1 物理删 seed 业务体（考古归档）**

  - pin/from_x 业务 C 出主链；最小 seed 单独归档

⬜ **13.3.2 宣布自举完成**

  - 公告：**Xlang 自举完成 — 无 Makefile + 零 host-cc + v2==v3**
  - **完成后主线**见 [`自举完成后功能完善及优化时序表.md`](自举完成后功能完善及优化时序表.md)（P0 基线 → P1 CLI/`xlang test` T1 → P2 语言/优化/std/**toml Core**/**IR 旁路** → P3 DX → P4 生态）


---

## 附录 A：代码量分布（快照 · 文档创建时；审计后补 glue 列）

| 维度 | .x 行数 | .c 行数 | 备注 |
|------|---------|---------|------|
| std/ + core/（库） | 75,007 | 0 | 100% ✅ |
| compiler/src/（产品源） | 176,729 | — | — |
| compiler/ 非 seed .c（含 gen+glue） | — | 372,826* | *原统计；**含** glue 巨头 |
| 其中 glue/ast 池系（2026-07-29 实测） | — | **~60,574** | pipeline_glue+ast_pool+field_access+soa+bootstrap 等 |
| compiler/seeds/ .c | — | 209,657 | ~329 文件 |
| **全项目 .x vs 全 .c** | **251,736** | **582,483** | **~30.2% .x** |

> 终局看的不是 .x 占比，而是 **BC 层是否还有必须 host-cc 的 .c** 与 **是否还有 Makefile 权威**。

## 附录 B：三大 mega rest 规模

| mega | rest LOC | 切片数 | 状态 |
|------|----------|--------|------|
| parser_asm_thin_c | ~21,935 | 21/21 ✅ | 拆分完成 · 冷链关 pin ✅（7.2.2）· 物理删 seed ⬜（7.2.1） |
| runtime | ~7,320 | 24/24 ✅ | 拆分完成 · 去 pin ✅（7.1.1 物理删） |
| runtime_link_abi | ~6,920 | 11/11 ✅ | 拆分完成 · 冷链关 pin ✅（7.3.1）· 无独立 gen pin ✅（7.3.2 vacuous） |

另：**typeck / codegen pin** 见阶段 7.4（非本表三 mega，但是删 Makefile 同级债）。

## 附录 C：当前 L4 钉盘状态

| 项 | 值 |
|---|---|
| 钉盘 SHA | **`f7424ae47`**（双端 L4 真冷 + bstrict 129 · 2026-08-15 升钉） |
| 前钉 SHA | `e364f4a37` · `d79a368b2` · `77b334842` |
| 上次 L4 日期 | 2026-08-15 |
| 双端 bstrict 数 | **129**（钉盘双端绿；mac `/tmp/xlang_l4_Darwin_f7424ae47.log` · Ubuntu `/tmp/xlang_l4_Linux_f7424ae47.log`） |
| mac 产品链 | ✅ L4 remaining_o=0 · 矩阵 5/5 · wall=63m38s |
| Ubuntu L4（金标） | ✅ L4 remaining_o=0 · 矩阵 5/5 · wall=24m45s |
| 工程轨 KPI | T 18/18 · N 111/111 IDENTICAL |
| MG | ✅ 根 + `compiler/Makefile` 已物理删除 |
| git 锚点 / 波次流水 | 见 `自举进度.md` |

## 附录 D：综合迁移进度（终局 = **无 Makefile** + 零 cc 三义）

```
旧终局（v2==v3 + 无 pin）≈ 74.5%（历史权重）

新终局权重（MG 物理删后）：
  库+T+N+R2+M拆分+Cap≈         0.40 × ~88%  → ~35%
  阶段 7/8 gen 去 pin            0.10 × ~95%  → ~9.5% （M4 冷链 5/5 · Stage 8 30/30；parser seed 物理删／7.4.4 仍 ⬜）
  阶段 8.3 glue/ast（新）        0.12 × ~5%   → ~0.6%  （CTFE 域已切；整体仍 🟡）
  阶段 9 residual                0.12 × 0%    → 0%
  阶段 10 语言 L2                0.10 × 0%    → 0%
  阶段 11 Makefile 退役/xbuild   0.12 × ~96%  → ~11.5% （**MG 文件删除 ✅**；0-make hub ✅；11.2.2 L4 ✅）
  阶段 12–13 冷启动+终局验收     0.04 × ~10%  → ~0.4% （13.2.2 文件层 ✅；零 cc / v2==v3 ⬜）
                                 合计 ≈ 56–58%
```

**综合迁移进度（修订）：约 56–58%**  
MG **编排层** ✅。BC 🟡（库存机检 + CTFE/assign 域已切）。PC 🟡（去 import→C／FORBID／ALLOW 已闭；默认仍可 host-cc）。剩余主债：**8.3 glue 续切** · **PC／BC 零 cc** · 阶段 12 冷启动 · sat 盖 prefer · Cap leave-off。

剩余工作优先级（MG 已闭后）：

1. ✅ **post-delete residual** — 0-make hub · gate post_ship · catalog bags · ensure_host_cc --check  
2. 🟡 **BC + 阶段 8.3**（库存 ✅ · 8.3.1 四十九刀（+array_lit durable／slice reent／**var_decl+lazy_append 共享叶**／**slice dual-GP+slice_from_array 同叶**／**sret return path 同叶**／**field_access layout/offset 同叶**／**lea/arm64 sret helpers 同叶**／**async CPS emit domain 同叶**／**x86 micro-encoders 同叶**／**with_arena scope domain 同叶**／**cmp cc helpers 同叶**／**empty struct check 同叶**／**TokenKind variant tag 同叶**／**float bits lo/hi 同叶**／**struct_lit field offset/type_ref 同叶**／**block_final_expr 同叶**／**array_let_empty_init 同叶**／**struct_layout_compute_field_offset 同叶**／**func_param_agg_byte_size 同叶**／**func_return_byte_size 同叶**／**func_param_home_width 同叶**／**call_return_byte_size 同叶**）+ index_eff／emit_expr fast／call_arg／try_binop 有则补全 ✅ · **8.3.2 …+top_level residual ✅** · 8.3.9 ✅ · **当前：8.3.3 两叶 host-cc leave ✅ · 8.3.1 leaf residual / pipeline_x mega 仍 host-cc**）
3. ✅ **阶段 7.4 + 8.2** typeck/codegen/parser／link_abi **冷链关 pin**（物理删 parser seed 7.2.1／7.4.4 CI 漂移闸仍 ⬜）
4. ⬜ **阶段 10 → 9** 语言能力 + residual 消灭  
5. ⬜ **阶段 12–13** 冷启动零 cc 三义 + v2==v3 + 公告  

## 附录 E：compiler/Makefile 迁移表（摘要 · 全量见独立文档）

> **全量权威清单**（11.0.1）：[`analysis/Makefile迁移表.md`](Makefile迁移表.md)  
> 每完成一行迁移到 xbuild，在迁移表「迁移状态」列改 ✅，并回写本摘要若影响仪表盘。

| 类 | 主题 | 条数（约） | 今日落点 | xbuild 拟目标 | 状态 |
|----|------|------------|----------|---------------|------|
| **I** | g05 / relink / build-tool 入口 | 9 | `./xbuild`→g05 shell | `xbuild link-product` | 🟢 产品入口 |
| **H** | bootstrap / 产品二进制 phony | 34 | 冷=Makefile 图；日常 g05 | `xbuild bootstrap` / `link-product` | 🟡 编排 shell + mk 清单 |
| **D** | 前端 `*_x.o` | 20 | g05 热路径 + Makefile pin | `xbuild frontend` | 🟡 |
| **E** | `compiler/src` 宿主 .o | 59 | g05 ensure cc | `xbuild runtime-src` | 🟡 |
| **F** | `runtime_*` residual .o | 31 | g05 ensure | `xbuild residual-c` | 🟡 → 阶段 9 |
| **C** | glue / pipeline_x / strict_minimal | 3 | Makefile + g05 cc | `xbuild glue` | ⬜ 体积主债 8.3（地图已落） |
| **B** | pinned `*_gen.c` | 18 | g05 assemble／考古 egg | `xbuild pin-gen` | 🟡 冷链关 pin ✅（7.4/8.2）；egg 仍在 |
| **A** | std/core 模块 .o | 65 | 部分 shell / g05 | `xbuild std` | 🟡 |
| **G** | `build_asm/*_filtered.o` | 4 | 全 4 🟢 shell | `xbuild build-asm-filter` | ✅ 产品+Makefile 同调 |
| **J** | test / check / verify | 12 | shell + tests hub | `xbuild test` / `cold-test` | ✅ 11.2.3 tests/** hub |
| **K** | seed 工具 | 4 | Makefile | `xbuild seed-tools` | ⬜ 11.0.3 |
| **L** | std 变体 stub | 10 | Makefile | `xbuild std-variant` | ⬜ |
| **M** | clean / compile_commands / legacy | 6 | make / 考古 | util 或 🗑 | 🟡 |
| **N/O** | link alias / 未分类 | ~14 | g05 / 待确认 | stubs 或 🗑 | ⬜ |
| **Σ** | | **~288** | | | 盘点 ✅ 迁移 ⬜ |


---

> **使用方式**：每完成一步，将本文对应待办 `⬜`→`✅`/`🟡` 并保持状态表准确。  
> **波次叙事 / 变更记录**：只写 [`自举进度.md`](自举进度.md)（本文不设 changelog）。  
> **删 Makefile 自检**：动构建系统前先更新附录 E；宣称「无 Makefile」前跑 13.2.2–13.2.4。
