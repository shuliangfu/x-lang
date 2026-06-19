# std.backtrace

调用栈捕获与符号化，对标 Rust `std::backtrace`。

## API

| API | 说明 |
|-----|------|
| `capture(buf, max_frames)` | 将当前栈帧地址写入 `buf`（每帧 `sizeof(void*)` 字节），返回帧数；失败 0 |
| `symbolicate(buf, len, out_ptrs, out_names, max)` | 将 capture 结果符号化；`out_names` 布局 `max × SYM_NAME_LEN`（128）；返回成功解析符号的帧数 |
| `SYM_NAME_LEN` | 符号名每槽字节数（128） |

## 平台说明

| 平台 | capture | symbolicate |
|------|---------|-------------|
| Linux (glibc) | `backtrace()` | `dladdr()` → `dli_sname` |
| macOS | `backtrace()` | `dladdr()` |
| Windows | `CaptureStackBackTrace` | `SymFromAddr` + `UnDecorateSymbolName` |
| musl / 其他 | 0 | 十六进制地址回退 |

无法解析符号时，名称槽写入 `0x…` 十六进制地址（不计入成功帧数）。

## 编译建议

调试构建建议使用 `-g`；Linux 上可选 `-rdynamic` 以便 `dladdr` 解析更多符号。

## Gate

```bash
./tests/run-std-backtrace-symbolicate-gate.sh   # STD-052
./tests/run-std-backtrace-xplat-gate.sh
bash tests/run-backtrace.sh
```

C 金样锚点：`backtrace_gold_anchor_c`（烟测期望符号名含 `gold_anchor`）。
