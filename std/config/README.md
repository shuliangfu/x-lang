# std.config — 分层配置加载（STD-086）

TOML 扁平 + `[section]` 子集、ENV 前缀、多源 merge、类型化读取。

## API

| API | 说明 |
|-----|------|
| `new` / `free` | 创建/释放配置存储 |
| `load_toml_buf` / `load_toml_file` | 从内存/文件加载 TOML |
| `load_env_prefix` | 加载 `PREFIX*` 环境变量 |
| `merge` | 合并另一 Config（CLI 覆盖层） |
| `set_string` | 显式设置键值 |
| `get_string` / `get_i32` / `get_bool` | 类型化读取 |
| `get_source` / `get_*_meta` | 带来源层 kind + label（TOML/YAML/ENV/CLI） |
| `source_*` | 来源层常量 |

## 分层优先级（v1）

1. `load_toml_file` — 文件基线  
2. `load_env_prefix(..., override=1)` — 环境覆盖  
3. `merge(cli_cfg, override=1)` / `set_string` — CLI 最高  

## Gate

```bash
./tests/run-std-config-gate.sh
```

## 限制（v1）

- TOML：扁平键、`[section]` 一级前缀、**`[a.b]` 嵌套 section**（键为 `a.b.*`）、**`[[array]]` array-of-tables**（键为 `array.0.*`）、字符串/整数/bool  
- YAML：嵌套 section（`db.url`）、**`-` 标量序列**（`items.0`）、**`-` object 序列**（`servers.0.host`）

## Known host-C caveat（刀 11.31 LOCATE）

Current tree `std/config/config.o`：`config_load_toml_buf_c` may return `CFG_OK` while subsequent `get_*` see `CFG_ERR_NOT_FOUND` under minimal C-link stubs. `config_set_string_c` on the same handle still round-trips. Built-in `config_*_smoke_c` return 3 on this `.o`. Do **not** treat Core-example static gate（刀 11.30）as runtime load green. Rebuild of `config.x` historically hits Soft Cap CG002（HOLD；tiphead Prefer §7 勿升）.

