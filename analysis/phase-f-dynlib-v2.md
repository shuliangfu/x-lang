# 阶段 F-dynlib v2（std.dynlib 逻辑 .sx 下沉）

> **F-dynlib v2 / F-ZC**：open/sym/close 包装、last_error 与烟测在 **`dynlib.sx`**；**`dynlib_os_glue.c` 已删除**；dlopen 在 **`runtime_dynlib_os.c`**（compiler runtime）。

## 变更

| 项 | v1 | v2 / F-ZC |
|----|----|-----|
| open/sym/last_error | `dynlib_glue.c` | **`dynlib.sx`** |
| OS dlopen/LoadLibrary | glue 内联 | **`runtime_dynlib_os.c`** |
| `dynlib.o` | `ld -r` sx + glue | **纯 `.sx`** |

## 符号

- `dynlib_os_*_c` — compiler runtime（POSIX `-ldl` / Win32 API）
- `dynlib_open_c` / `dynlib_last_error_copy_c` — `dynlib.sx`

## 门禁

```bash
SHUX_F_DYNLIB_V2_FAIL=1 ./tests/run-f-dynlib-v2-gate.sh
./tests/run-std-dynlib-windows-gate.sh
./tests/run-std-dynlib-last-error-gate.sh
```

## 下一项

- **Z8** 其它 OS 胶层（`sync/*` 等）
