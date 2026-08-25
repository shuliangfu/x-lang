# STD-086 std.config v1

> 更新时间：2026-06-18  
> 状态：**可用** — TOML 子集 + ENV 前缀 + merge + 类型化读取 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-config-manifest.tsv` |
| 3 | `./tests/run-std-config-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `new` / `free` / `clear` | 生命周期 |
| `load_toml_buf` / `load_toml_file` | TOML 子集（扁平 + `[section]`） |
| `load_env_prefix` | 与 `std.env` 集成，剥离前缀 |
| `merge` | file < env < cli 分层覆盖 |
| `set_string` | CLI 层显式设置 |
| `get_string` / `get_i32` / `get_bool` | 类型化取值 + 错误码 |
| `get_source` / `get_i32_meta` / `get_bool_meta` / `get_string_meta` | 类型化取值 + 来源 meta |
| `source_*` | 0=unknown, 1=toml, 2=yaml, 3=env, 4=set（`source_toml` 等） |
| `err_*` | 0 / -1..-5 |

实现：`std/config/mod.x` + `config.x`（F-config v2 逻辑）+ `config_io_glue.c`（文件 IO）；ENV 遍历依赖 `std/env/env.o`。

---

## 3. Gate

Honesty（2026-08-25）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin-arm64 asm→c 静默 remap）。
- `xlang check` **观测**（自举期暂停闸门 2026-08-05）；CHK002 等不得硬红。
- 产品烟测 `layer_smoke.x` **exit 0 硬失败**（有原生 xlang 时禁止 soft SKIP）。
- C smoke（`config_smoke_ok.c`）**仅观测**（archaeology host-C；非硬绿信号）。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。

```bash
./tests/run-std-config-gate.sh
```

```
xlang: [XLANG_STD_CONFIG] status=ok check=0|1 run=1 skip=0
std-config gate OK
```

---

## 4. 后续（非 v1 阻塞）

- YAML 可选后端（STD-119；闸仍偏 xlang-c／C smoke 硬绿＝假权威残债）  
- 嵌套 TOML 表 / 数组  
- 与 `std.cli` flag 自动绑定  

## 5. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | TOML 子集 + ENV + merge + meta + gate |
| v1.1 | 2026-08-25 | soft→硬绿 honesty：prefer asm／check 观测／runnable 硬失败／C smoke 观测 |
