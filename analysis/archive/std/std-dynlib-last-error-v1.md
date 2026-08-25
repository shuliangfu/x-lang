# STD-096：std.dynlib last_error 文本诊断 v1

> 更新时间：2026-08-25  
> 状态：**定版（v1）** · 假权威闸诚实化  
> 关联：`tests/baseline/std-dynlib-last-error.tsv` · STD-027（open/sym/close）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-dynlib-last-error.tsv` |
| 3 | `./tests/run-std-dynlib-last-error-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `last_os_error(buf, cap)` | 复制最近一次 open/sym 失败诊断到 `buf`；返回写入字节数，无内容返回 0 |
| `dynlib_last_error_copy_c` | C 复制权威（`std/dynlib/dynlib.x`） |
| `dynlib_last_error_smoke_c` | C 烟测入口（archaeology；非硬绿） |

失败时 POSIX 侧暴露 `dlerror`；Windows 侧暴露 `GetLastError` 文本（见 STD-027）。

---

## 3. 金样

| 场景 | 期望 |
|------|------|
| `open("/nonexistent/…")` 失败 | 句柄 0 |
| 随后 `last_os_error(buf, 128)` | 返回值 `> 0`，`buf` 非空诊断 |

烟测：`tests/dynlib/last_error.x`（设计成功分 = exit **0**）。

---

## 4. Gate

### 假权威诚实验收（2026-08-25）

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05）；不硬失败。
- 可跑烟测 `tests/dynlib/last_error.x` exit **0** 硬失败；有原生 xlang 时 **禁 soft SKIP**。
- C smoke 仅观测（archaeology host-C；`dynlib.o` 可能拖 process 符号，非硬绿信号）。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。
- 构建入口：`./xbuild`／闸脚本（**拒** `make -C compiler` 复活为活权威）。

```
xlang: [XLANG_STD096_DYNLIB_ERR] status=ok check=0|1 run=1 skip=0
std-dynlib-last-error gate OK
```

- manifest：`tests/baseline/std-dynlib-last-error.tsv`
- 烟测：`tests/dynlib/last_error.x`
- 闸：`tests/run-std-dynlib-last-error-gate.sh`
- lib：`tests/lib/std-dynlib-last-error.sh`

---

## 5. 演进

- 与 STD-027 Windows LoadLibrary 路径诊断联动；UTF-16 路径错误文案细化属 STD-027 v2。
