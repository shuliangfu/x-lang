// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// io_trait.x — Io trait 空接口骨架（全面异步架构 T* 准备）
//
// WHY: 当前执行模型绑死 runtime_scheduler_glue（C seed），无可注入 Io 抽象，
//      阻塞 T2（可注入执行模型）。本文件为自举后全面异步架构预留扩展点。
//
// INVARIANT: 自举期只加 trait 定义，不强制后端实现，不改链接默认，不删现有 C ABI。
//            产品链仍走 xlang_io_* / xlang_async_* C ABI。
//
// ASM/PERF: 无（纯接口骨架，无代码生成）。
//
// PLATFORM: SHARED — 三端后端（ThreadedIo/EventedIo/TestIo）必须实现此 trait。
//
// 关联文档：analysis/async-io-trait-RFC.md · analysis/全面异步架构-分析与准备.md §4.1

// Io — 可注入的 I/O 能力面（T* 阶段 2 落地）。
//
// 后端：
//   - ThreadedIo：同步 syscall（read/write/poll），内部阻塞
//   - EventedIo：io_uring / kqueue / IOCP，事件驱动
//   - TestIo：录制/回放，测试隔离
//
// 与 Reader/Writer trait 的关系：
//   - Reader/Writer 是字节流适配（面向用户）
//   - Io 是后端能力面（面向执行模型）
//
// 迁移路径：见 analysis/async-io-trait-RFC.md §3
export trait Io {
  // read — 读字节到 buf，返回读取字节数（≤0 为错误/超时）。
  // cancel: ctx cancel 时返回 IO_CTX_MS_CANCELLED（见 std.io.IO_CTX_MS_CANCELLED）。
  // PLATFORM: SHARED — 三端后端必须实现。
  function read(self, handle: usize, buf: *u8, len: usize, timeout_ms: u32): i32;

  // write — 从 buf 写字节，返回写入字节数（≤0 为错误/超时）。
  // PLATFORM: SHARED — 三端后端必须实现。
  function write(self, handle: usize, buf: *u8, len: usize, timeout_ms: u32): i32;

  // read_async — 提交异步读，返回 Future handle（>0）。
  // ThreadedIo: 内部同步读后 complete future。
  // EventedIo: 提交到 io_uring/kqueue/IOCP，complete 在事件循环。
  // PLATFORM: SHARED — 三端后端必须实现。
  function read_async(self, handle: usize, buf: *u8, len: usize): i64;

  // write_async — 提交异步写，返回 Future handle（>0）。
  // PLATFORM: SHARED — 三端后端必须实现。
  function write_async(self, handle: usize, buf: *u8, len: usize): i64;

  // poll_completions — 轮询完成事件，返回完成数。
  // ThreadedIo: 立即返回 0（无异步）。
  // EventedIo: 调用 io_uring_enter/kevent/GetQueuedCompletionStatus。
  // PLATFORM: SHARED — 三端后端必须实现。
  function poll_completions(self, timeout_ms: u32): u32;

  // cancel — 中止 in-flight Io 操作（cancel 契约）。
  // 返回 0=成功，<0=错误。
  // PLATFORM: SHARED — 三端后端必须实现。
  function cancel(self, handle: usize): i32;

  // sleep — 挂起当前执行流。
  // ThreadedIo: 阻塞 nanosleep。
  // EventedIo: 挂起帧，timer 事件唤醒。
  // TestIo: 立即返回。
  // PLATFORM: SHARED — 三端后端必须实现。
  function sleep(self, ns: u64): i32;
}

// 模块锚点（确保 .o 非空，不改链接默认）
export function io_trait_module_anchor(): i32 { return 0; }
