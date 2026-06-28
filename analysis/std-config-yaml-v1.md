# STD-119 std.config YAML 可选后端 v1

> 更新时间：2026-06-18  
> 状态：**可用** — 扁平 + 缩进 section YAML 子集 + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-config-yaml-manifest.tsv` |
| 3 | `./tests/run-std-config-yaml-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `backend_toml` / `backend_yaml` | 后端标识 |
| `load_yaml_buf` / `load_yaml_file` | YAML 加载（与 TOML 共享键空间） |
| `yaml_smoke` | C 烟测入口 |

YAML v1 子集：`key: value`、`#` 注释、缩进 section（`db:` + `  url: …` → `db.url`）、引号字符串与 bool/number。

与 TOML 相同：`get_string` / `get_i32` / `get_bool` / `merge` 可直接复用。

---

## 3. Gate

```
shux: [SHUX_STD119_CONFIG_YAML] status=ok c=1 sx=1 skip=0
std-config-yaml gate OK
```

向量：`tests/baseline/std-config-yaml-vectors.tsv`。
