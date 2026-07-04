# [OPEN] Debug Session: check-command-hang

## 背景
- 现象：执行 `./compiler/shux check std` 后，已经输出 `std/io/stubs.x` 的 `typeck error[T001]`，但进程没有自行退出，需要手动 `^C`。
- 期望：一旦 `check` 已经确定失败并输出错误，主进程应尽快返回非零退出码，而不是继续挂住。

## 当前假设
1. `check std` 在打印首个 import/typeck 失败后，仍继续等待未回收的 worker / pipeline 子任务，导致主线程卡在 join/wait 路径。
2. 错误已经上报，但目录批量检查路径没有把“import 失败”转成全局终止条件，后续仍在递归遍历 `std/`。
3. 某个诊断/汇总阶段在错误后等待额外输入或阻塞管道，导致 stderr 已输出但进程未退出。
4. `std` 目录模式与单文件 `check` 走了不同收尾路径；单文件能退出，目录批量模式在失败时遗漏 cleanup / exit。
5. 主进程其实已经准备退出，但被残留子进程或 `waitpid` 路径卡住，表现成前台命令不返回。

## 计划
1. 在硬超时保护下复现 `./compiler/shux check std`，抓取退出码、日志尾部与卡住时的进程树。
2. 对比单文件坏例子与目录模式，确认是目录调度层还是底层 import/typeck 层不退出。
3. 仅在拿到运行时证据后，再做最小插桩定位阻塞点。

## 首轮证据
- 单文件坏例子：
  - `perl -e 'alarm shift; exec @ARGV' 12 ./compiler/shux check std/io/stubs.x`
  - 结果：`RC=1`，打印 `std/io/stubs.x:54` 的 `typeck error[T001]` 后立刻退出。
- 目录模式：
  - `perl -e 'alarm shift; exec @ARGV' 12 /bin/sh -c './compiler/shux check std >... 2>...'`
  - 结果：stderr 很快就稳定在 7 行，同样已经打印：
    - `typeck error[T001]: return expression type mismatch ...`
    - `typeck error: typeck failed for import 'std.io.stubs' ...`
  - 但主进程未退出，`12s` 后被外层 `alarm` 杀死，前台 `shux` 仍在运行。
- 进程/采样证据：
  - 挂住时 `ps` 显示前台真实存在 `./compiler/shux check std`，CPU 约 `95%~99%`，不是空等 shell。
  - `sample` 栈显示主线程在：
    - `main_entry -> driver_cmd_check -> driver_run_compiler_check -> check_one_file -> fmt_check_invoke_compile`
    - 主线程 `pthread_join`
    - 工作线程落在 `pipeline_typeck_x_stack_escape_gate_from_src_c -> parser_parse_into_buf -> parser_parse_one_function_impl`
  - 说明报错后它仍在继续做编译/解析工作，而不是已经准备退出却卡在 stderr flush。
- `--fail-fast` 对照：
  - `perl -e 'alarm shift; exec @ARGV' 12 ./compiler/shux check --fail-fast std`
  - 结果：`RC=1`，打印同样错误后立即退出。

## 当前判断
1. 当前现象不是“报错后死锁不退出”，而是 `check 目录` 默认没有 fail-fast，首个文件失败后仍继续检查后续文件。
2. 单文件模式与目录模式行为不同：单文件天然只跑一个文件，所以会立刻退出；目录模式默认继续遍历 `s_n_files`。
3. 运行时采样表明挂住时仍在 parser/typeck 工作线程中忙碌，不是 shell 或 stderr 卡死。
4. 若用户期望“只要首个错误就立即返回”，现有 CLI 默认行为与该期望不一致；`--fail-fast` 已经能证明所需语义存在。
