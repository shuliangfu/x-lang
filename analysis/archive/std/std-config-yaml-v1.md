# STD-119 std.config YAML 可选后端 v1

> 更新时间：2026-08-25  
> 状态：**可用** — 扁平 + 缩进 section YAML 子集 + gate honesty

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

Gate honesty（2026-08-25 soft→硬绿；对齐 STD-086）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin-arm64 asm→c 静默 remap）。
- `xlang check` **观测**（自举期暂停闸门 2026-08-05）；CHK002 等不得硬红。
- 产品烟测 `yaml_smoke.x` **exit 0 硬失败**（有原生 xlang 时禁止 soft SKIP）。
- C smoke（`yaml_smoke_ok.c`）**仅观测**（archaeology host-C；非硬绿信号）。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。

```bash
./tests/run-std-config-yaml-gate.sh
```

```
xlang: [XLANG_STD119_CONFIG_YAML] status=ok check=0|1 run=1 skip=0
std-config-yaml gate OK
```

向量：`tests/baseline/std-config-yaml-vectors.tsv`。

---

## 4. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | YAML 子集 + gate（曾偏 xlang-c／C smoke 硬绿＝假权威） |
| v1.1 | 2026-08-25 | soft→硬绿 honesty：prefer asm／check 观测／runnable 硬失败／C smoke 观测 |
