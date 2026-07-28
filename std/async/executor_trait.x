// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// executor_trait.x — Executor trait 空接口骨架（全面异步架构 T* 准备）
//
// WHY: 当前任务执行绑死 xlang_async_task_submit C ABI，无可注入 Executor 抽象，
//      阻塞 T2（可注入执行模型）。本文件为自举后全面异步架构预留扩展点。
//
// INVARIANT: 自举期只加 trait 定义，不强制后端实现，不改链接默认，不删现有 C ABI。
//            产品链仍走 xlang_async_* C ABI。
//
// ASM/PERF: 无（纯接口骨架，无代码生成）。
//
// PLATFORM: SHARED — 执行器后端必须实现此 trait。
//
// 关联文档：analysis/async-io-trait-RFC.md §2.3 · analysis/全面异步架构-分析与准备.md §4.1

// Executor — 可注入的任务执行能力面（T* 阶段 2 落地）。
//
// 后端：
//   - 当前 scheduler_glue（C seed，过渡期）
//   - 未来 pure .x scheduler（R2 完成后）
//   - TestExecutor（单线程同步，测试隔离）
//
// 与 std.task.TaskGroup 的关系：
//   - TaskGroup 是结构化并发容器（面向用户）
//   - Executor 是任务执行能力面（面向执行模型）
//   - T* 阶段 3：TaskGroup 与 Executor.spawn 默认合一
//
// 迁移路径：见 analysis/async-io-trait-RFC.md §3
export trait Executor {
  // spawn — 提交任务，返回 Future handle（>0）。
  // 当前: 走 xlang_async_task_submit C ABI（过渡期）。
  // T*: 走 trait 静态分发（依赖 L-trait）。
  // PLATFORM: SHARED — 执行器后端必须实现。
  function spawn(self, fn_handle: i64, arg_handle: i64): i64;

  // block_on — 阻塞当前线程直到 future 就绪。
  // ThreadedIo: 阻塞等待。
  // EventedIo: 跑事件循环。
  // PLATFORM: SHARED — 执行器后端必须实现。
  function block_on(self, future: i64): i32;

  // yield_now — 让出当前执行流（协作式调度）。
  // PLATFORM: SHARED — 执行器后端必须实现。
  function yield_now(self): i32;

  // task_count — 当前任务数（用于 shutdown 等待）。
  // PLATFORM: SHARED — 执行器后端必须实现。
  function task_count(self): i32;
}

// 模块锚点（确保 .o 非空，不改链接默认）
export function executor_trait_module_anchor(): i32 { return 0; }
