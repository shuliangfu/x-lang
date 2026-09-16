# STD-118 std.trace 关键路径挂钩 v1

> 更新时间：2026-08-28（honesty residual prefer-c／auto-make／ensure →硬绿）· 原稿 2026-06-18  
> 状态：**定版** · Gate honesty residual prefer-c／auto-make／ensure →硬绿  
> 关联：STD-088（std.trace 主闸已诚实）· F-trace v1/v2（本闸仍观测委托，未开）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-trace-hooks-manifest.tsv` |
| 3 | `./tests/run-std-trace-hooks-gate.sh` |
| 4 | 烟测：`hooks_smoke_ok.c`、`hooks_smoke.x` |

---

## 2. API

产品短名（`std/trace/mod.x`）：

| API | 说明 |
|-----|------|
| `hook_begin` / `hook_end` | 通用子 span 挂钩（化石 `hook_span_begin`／`hook_span_end`） |
| `io_read` / `io_write` | 包装 `std.io` read_ctx／write_ctx（化石 `hook_io_*_ctx`） |
| `net_connect` | 包装 `std.net.connect_ctx_fd`（化石 `hook_net_connect_ctx`） |
| `net_read` | 包装 `std.net.read_ctx`（化石 `hook_net_stream_read_ctx`） |
| `async_drain` | 包装 `std.async.drain`（化石 `hook_async_drain_ctx`） |
| `hooks_smoke` | C 烟测入口包装 |

Context 未附着 trace 时各 hook **透传**底层调用；有 trace 时自动 `start_child` + `end`。

Span 命名：`io.read`、`io.write`、`net.connect`、`net.stream_read`、`async.drain`。

---

## 3. Gate

```bash
./tests/run-std-trace-hooks-gate.sh
```

Honesty residual（2026-08-28）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- 显式坏 `XLANG`／缺 native **硬 die**（拒 XLANG fallthrough／soft auto-make／prefer-c／soft SKIP→OK／soft `ensure_std_c_o` 重建／extra CLI `.o`／C smoke auto-make）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `hooks_smoke.x` 产品 `-o` **能链则硬绿**（`run=`）；tip `std_trace_*`／`std_async_*` UNDEF＝obs（产品债，与 STD-088 同残；拒 soft SKIP→OK）
- Host-C archaeology **仅观测**（现成 `std/trace/trace.o`＋`std/time/time.o`＋`std/random/random.o` only；拒 ensure／auto-make 重建；不传 extra CLI `.o`；C smoke 文件存在仍 TSV 必有，compile/run 非绿）
- 报告行：`run=`／`obs=`／`skip=`（退役 `c=`／`x=` 当硬绿）
- 禁顶层 DOC 复活（live = `analysis/archive/std/`）
- 保留 `## 3. Gate`
- 关键词：STD-118／hook_begin／io_read／async_drain
- TSV／DOC API 锚对齐产品短名（化石 `hook_span_begin`／`hook_io_*_ctx` 已退役）
- F-trace v1/v2 仍观测委托本闸（本刀未开；其 fallthrough＋auto-make 另案）

manifest：`tests/baseline/std-trace-hooks-manifest.tsv`

```
xlang: [XLANG_STD118_TRACE_HOOKS] status=ok run=0|1 obs=0|1|2 skip=0
std-trace-hooks gate OK
```

向量：`tests/baseline/std-trace-hooks-vectors.tsv`。
