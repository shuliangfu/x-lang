# 阶段 E-04 v23（invoke_ld 薄包装与 -o 后缀迁入 runtime_link_abi）

> **E-04 v23**：合并 `runtime.c` 中 `invoke_ld` / `driver_asm_invoke_ld` 重复逻辑，并将 `-o` 后缀判断迁入 `runtime_link_abi.c/h`。

## v23 完成（✅）

| 符号 | 说明 |
|------|------|
| `shux_output_is_elf_o` | `-o` 是否为 `.o`/`.obj`（写对象而非 `.s`） |
| `shux_output_want_exe` | `-o` 是否表示可执行文件名（非 `.o`/`.obj`/`.s`） |
| `shux_invoke_ld_for_exe` | prepare + `shux_asm_invoke_ld_platform`；freestanding 取自 `driver_freestanding_get` |

`driver_asm_output_want_exe`（compile.x extern）保留为薄转发至 `shux_output_want_exe`。

## 复现

```bash
SHUX_E04_FAIL=1 ./tests/run-e04-runtime-soft-gate.sh
make -C compiler src/runtime_link_abi.o src/runtime_driver_no_c.o
```

## 延后（E-04 v25+）

- `load_one_import` / `run_compiler_c` / pipeline dep 主体继续拆分
- Cygwin 专用 crt0（若需与 MinGW 分轨）
