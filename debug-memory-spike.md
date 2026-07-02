# [OPEN] Debug Session: memory-spike

## 背景
- 现象：用户反馈最近两次电脑被“连接卡爆/内存撑爆”，怀疑与本次调试过程中运行的命令有关。
- 目标：先确认当前是否存在残留高占用/卡死进程，再定位最可能导致内存飙升的命令形态与防护缺口。

## 当前假设
1. `shux` / `shux_asm` / `shux-c` 的 `-E` 或自举链命令在某些输入上进入超长运行，导致 RSS 持续增长。
2. 外层 `perl -e 'alarm ...'` 已退出，但子进程树存在残留，继续占用 CPU / 内存。
3. `make bootstrap-*` 触发了多个编译/链接子进程并发，短时间内叠加放大了内存峰值。
4. stdout 重定向到 `_gen.c` 时没有及时可见输出，造成“看起来像卡死”，同时大缓冲/大生成放大了内存占用感知。
5. 仍有历史探针或调试命令残留在系统里，未被及时停止。

## 计划
1. 只读检查当前进程、RSS、CPU、父子关系，确认是否有残留高占用进程。
2. 对照最近实际运行过的命令形态，判断哪一类最可能造成峰值内存。
3. 若确认无残留进程，则把风险收敛到“命令模式/防护缺口”，给出后续强约束方案。

## 当前状态
- 已收集首轮运行时证据。

## 首轮证据
- `ps -axo pid,ppid,stat,%cpu,%mem,rss,etime,comm | sort -k6 -nr | head -n 15`
  - 当前高 RSS 主要来自：
    - `com.apple.Virtualization.VirtualMachine`：约 `4479280 KB`（约 4.27 GiB）
    - 多个 `Trae Helper (Renderer/Plugin)`：单个约 `570800 KB` 到 `948512 KB`
    - `Google Chrome` 及其 renderer：单个约 `489744 KB` 到 `643616 KB`
- `ps ... | egrep 'shux|shux_asm|shux-c|perl -e|make bootstrap|cc |clang|ld | Z|defunct'`
  - 未发现残留的 `shux` / `shux_asm` / `shux-c` / `perl -e 'alarm ...'` / `make bootstrap` / `cc/ld` 长跑进程
  - 未发现僵尸进程或 `defunct`
- `memory_pressure | head -n 20`
  - 当前 `Pages free` 较高
  - `Swapins: 0`
  - `Swapouts: 0`
  - `Pages used by compressor: 0`
  - 说明当前系统不处于内存高压或交换抖动状态

## 当前判断
1. 现在没有“我留下的卡死编译进程”在继续吃内存。
2. 当前机器上的持续大内存占用主要来自虚拟机、Trae 多个 helper/renderer、以及 Chrome renderer。
3. 本次调试里最危险的命令形态仍然是 `./shux ... -E > *_gen.c` / `make bootstrap-*` 这类长链，它们可能在运行时制造瞬时峰值并放大总体内存压力，但从当前快照看，峰值进程没有残留到现在。
4. 需要继续约束后续动作：同一时刻只允许一个重命令、必须硬超时、避免并行 bootstrap、避免直接重定向覆盖正式 `_gen.c`。

## 新证据：bootstrap-typeck 不是“纯卡死”，而是配方参数失配
- 以 `8s` 硬超时执行：
  - `./shux src/typeck/typeck.sx -E > /tmp/typeck_probe.out`
  - 结果：`Alarm clock`，退出码 `142`，stdout/stderr 都是 `0B`
- 对照正常生成规则执行：
  - `./shux-c -L .. -L src -L src/lexer -L src/ast -L src/parser src/typeck/typeck.sx -E-extern > /tmp/typeck_probe_extern.out`
  - 结果：退出 `0`，stdout 约 `304289 bytes`
- 再用当前 `./shux` 验证兼容参数：
  - `./shux -L .. -L src -L src/lexer -L src/ast -L src/parser -E -E-extern src/typeck/typeck.sx > /tmp/typeck_probe_target.out`
  - 结果：退出 `0`，stdout 约 `304289 bytes`
- `codegen.sx` 同样成立：
  - `./shux -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -E -E-extern src/codegen/codegen.sx`
  - 结果：退出 `0`，stdout 约 `292323 bytes`

## 结论更新
1. `bootstrap-typeck` / `bootstrap-codegen` 的旧配方缺少 `-L` 与 `-E-extern`，会落到错误的 `-E` 使用形态。
2. 这条旧配方既可能表现为超时无输出，也可能表现为 `0` 退出但产物为空，因此会误导为“卡死”。
3. 进一步核对 `Makefile` 与二进制后确认：默认 `$(TARGET)=shux` 是 `SHUX_NO_C_FRONTEND` 的小二进制（约 `346K`），而 `$(SHUX_C)=shux-c` 才是带 C frontend 的完整生成器（约 `3.8M`）。
4. 因此 `bootstrap-typeck` / `bootstrap-codegen` 不能拿 `./shux` 来跑 `-E -E-extern` 生成链，必须显式依赖并使用 `./shux-c`。
5. 已将 `compiler/Makefile` 中两个 bootstrap 目标改为：
   - 依赖 `$(SHUX_C)`
   - 使用 `./$(SHUX_C)` 生成 `typeck_gen.c` / `codegen_gen.c`
   - 保留临时文件原子替换，避免失败时污染正式生成物
6. 继续向前验证后，`bootstrap-typeck` 已越过生成链，新的停点前推到链接阶段。
7. `nm -u typeck_sx.o` 证据显示仅缺 4 个符号：
   - `typeck_scratch64_slot`
   - `typeck_soa_array_storage_size_glue`
   - `typeck_sx_type_align_from_layout_glue`
   - `typeck_sx_type_size_from_layout_glue`
8. provider 已确认：
   - `src/ast_pool_l5_bridge.o` 提供 `typeck_scratch64_slot`
   - `build_asm/pipeline_glue_strict_minimal.o` 提供其余 3 个 layout/soa glue
9. 因此又将两个 bootstrap 目标的链接阶段最小补齐为：
   - 依赖 `$(AST_POOL_L5_BRIDGE_O)` 与 `build_asm/pipeline_glue_strict_minimal.o`
   - 最终 `cc -o $(TARGET)` 时显式把这两个 provider 对象带入

## 最新停点
- `bootstrap-typeck` 继续前推后，最小补 provider 仍不足，新的未定义显示它实际需要的是更完整的 seed/pipeline link base，而不是散补若干对象。
- 已确认：
  - `pipeline_sx.o` 导出
    - `pipeline_type_region_label_len_at`
    - `pipeline_typeck_set_active_ctx_c`
    - `pipeline_typeck_func_body_has_implicit_return_tail_c`
    - `pipeline_typeck_ptr_for_addr_of_operand_c`
    - `typeck_soa_array_storage_size_glue`
    - `typeck_sx_type_size_from_layout_glue`
    - `typeck_sx_type_align_from_layout_glue`
  - `typeck_sx_link_alias.o` 导出
    - `typeck_typeck_sx_ast`
    - `typeck_typeck_sx_ast_library`
    - 弱版 `pipeline_typeck_set_active_ctx_c`
    - 弱版 `pipeline_typeck_ptr_for_addr_of_operand_c`
- `Makefile` 现有 `DRIVER_SEED_OBJS` / `DRIVER_SEED_LINK_BASE` 已经包含：
  - `parser_sx.o lexer_sx.o lexer_sx_link_alias.o typeck_sx.o codegen_sx.o typeck_sx_link_alias.o codegen_sx_link_alias.o`
  - `$(AST_POOL_L5_BRIDGE_O)`
  - 并配套 `pipeline_sx.o` / `pipeline_bootstrap_orchestration.o`

## 下一步建议
1. 不再继续给 `bootstrap-typeck` 散补零碎 provider。
2. 直接把 `bootstrap-typeck` / `bootstrap-codegen` 的最终链接阶段改为复用成熟的 `seed-compatible` link base（至少要纳入 `pipeline_sx.o + typeck_sx_link_alias.o + DRIVER_SEED_OBJS` 这一套闭环）。
3. 继续保持 `15s` 以内硬超时，避免扩大机器负担。

## 新证据：下一真实停点已前推到 bootstrap-driver-seed
- 在 `15s` 硬超时下执行：
  - `perl -e 'alarm shift; exec @ARGV' 15 /usr/bin/time -l make SHUX_SKIP_SEED_SMOKE=1 bootstrap-driver-seed`
  - 现象：命令已经越过 `bootstrap-typeck` / `bootstrap-codegen`，进入 `bootstrap-driver-seed` 的 phase1 link 与 `build-seed-asm-host` 阶段；日志中可见：
    - `bootstrap-driver-seed: phase1 link (+ USER_ASM dispatch/bridge + seed partial) ...`
    - `bootstrap-driver-seed: build-seed-asm-host via shux-seed-phase1 ...`
  - 但在 `15s` 预算内仍未完成全部 prerequisite rebuild，外层 `alarm` 触发，未见 `bootstrap-driver-seed OK`
- 用更轻量的状态确认：
  - `perl -e 'alarm shift; exec @ARGV' 5 make -q SHUX_SKIP_SEED_SMOKE=1 bootstrap-driver-seed`
  - 结果：`RC=1`
- 结论：
  1. `bootstrap-driver-seed` 仍是当前真实活跃停点，目标尚未收口。
  2. 现阶段不需要再回头怀疑 `bootstrap-typeck` / `bootstrap-codegen`；它们已经通过，新的时间预算主要消耗在 driver seed 链。
  3. 后续若继续前推，应优先把 `bootstrap-driver-seed` 再细分成更短的只读探针或阶段性目标，而不是直接放宽超时去重跑整条链。

## 新证据：driver-seed 预算主要被 pipeline_gen 伪目标链吃掉
- 对 `bootstrap-driver-seed` 做 `make -n` 后，发现 `build-seed-asm-host` 本体并不重；真正会拉起整段 legacy `shux-c` 强制重编的是：
  - `build_asm/seed_host/asm_full_link_stubs.o`
  - `-> pipeline_sx.o`
  - `-> pipeline_gen.c`
  - `-> bootstrap-pipeline`
  - `-> legacy-shux-c-ready`
  - `-> make -B SHUX_LEGACY_C_FRONTEND=1 shux-c`
- 关键静态证据：
  1. `build-seed-asm-host` 自身的 dry-run 只有：
     - `chmod +x scripts/build_seed_asm_host.sh`
     - `./scripts/build_seed_asm_host.sh`
  2. 但 `make -n build_asm/seed_host/asm_full_link_stubs.o` 会直接展开：
     - `./scripts/select_bootstrap_shuxc.sh`
     - `cp -f bootstrap_shuxc shux-c`
     - `make -B SHUX_LEGACY_C_FRONTEND=1 shux-c`
     - 随后才进入 `bootstrap-pipeline` 的 pinned `pipeline_gen.c` 路径
  3. `Makefile` 当前写法是：
     - `pipeline_gen.c: bootstrap-pipeline`
     - `bootstrap-pipeline` 同时被列入 `LEGACY_SHUX_C_READY_TARGETS`
- 判断：
  1. 即使 `pipeline_gen.c` 已存在且走 pinned 分支，凡是经 `pipeline_sx.o` 间接依赖到 `pipeline_gen.c` 的目标，仍会先跑一遍 `bootstrap-pipeline` 这条伪目标链。
  2. 这条伪目标链又会无条件触发一次 legacy `shux-c` 的 `-B` 强刷，因此在 Darwin 安全模式下形成“明明没重生 `pipeline_gen.c`，却反复重编 `shux-c`”的额外成本。
  3. 当前更像是 Makefile 依赖建模问题，而不是 `build_seed_asm_host.sh` 自身在 Darwin 上真的跑了重型 `asm_seed_full.sx -E`。

## 新证据：driver/bstrict 链已在 15s 预算内打通
- 本轮继续沿活跃链把无意义的 legacy `shux-c` 强刷从 `driver_gen.c`、`lsp_*_gen.c`、`driver_*_gen.c`、`preprocess_gen.c`、`ast_gen2.c`、`parser_gen.c`、`lexer_gen.c`、`typeck_gen.c`、`codegen_gen.c`、`cfg_eval.o` 等 pinned 目标上移除，做法与 `pipeline_gen.c` 一致：仅在真正 fallback 到 `shux-c -E/-E-extern` 重生时才显式 `make -B SHUX_LEGACY_C_FRONTEND=1 shux-c`。
- 同时修复了 `build_shux_asm.sh` strict link 中两组真实重复符号：
  - `build_asm/backend_x86_64_enc_c.o` vs `build_asm/seed_host/asm_backend_partial.o`
  - `build_asm/backend_seed_mega_fallback.o` vs `build_asm/seed_host/asm_backend_partial.o`
- 运行时证据：
  - `perl -e 'alarm shift; exec @ARGV' 15 make bootstrap-driver-bstrict >/tmp/bootstrap-driver-bstrict.log 2>&1`
  - 日志尾部已稳定出现：
    - `info: build_shux_asm: shux_asm strict OK (...)`
    - `info: build_shux_asm: B-strict OK - LINK_MODE=asm_only_strict, no pipeline_sx.o in final link`
    - `info: build_shux_asm: M11 OK - full_asm topology + asm_only_strict ...`
    - `shux_asm_postlink_smoke: OK ./shux_asm (-c + -backend c -o exit=42)`
    - `relink-shux OK (shux-c synced)`
    - `refresh-shux-asm-gate OK (shux_asm <- seed+migrate-sx-objs)`
    - `bootstrap-driver-bstrict OK (shux_asm -> shux, release default B-strict)`
- 当前判断：
  1. 当前 `bootstrap-driver-seed` / `bootstrap-driver-bstrict` 已不再是活跃阻塞点。
  2. 这轮根修证明，Darwin 下 driver/bstrict 预算的主要风险不是单个巨慢命令，而是 Makefile / 脚本中的 pinned 目标被时间戳或伪目标检查反复拉起。
  3. 后续若继续前推，应从 `bootstrap-driver-bstrict` 之后的新活跃链继续拆，而不是回头扩大超时重跑旧停点。
