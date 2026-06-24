# STD-140：std.path 极端路径规范化向量 v1

> 状态：**定版（v1）**  
> 关联：`NEXT.md` std.path「复杂路径规范化策略」、`STD-021` Windows 路径

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-140 | 极端 `path_clean` / `path_resolve` / extension 向量 + 烟测 + gate |

覆盖连续斜杠、尾随 `/`、`.`/`..` 组合、混合 `\`、非 dotdot 多点段、隐藏文件扩展名、双扩展 stem 等边界。

---

## 2. v1 行为备忘（非 POSIX 完整 Clean）

| 场景 | 输入示例 | v1 输出 | 说明 |
|------|----------|---------|------|
| 连续斜杠 | `//a///b` | `/a/b` | 折叠重复分隔符 |
| 尾随斜杠 | `/foo/bar/` | `/foo/bar` | 去掉末尾 `/` |
| 相对 dot 消段 | `foo/./bar/../baz` | `foo//baz` | pop 后可能留双 `/`（已知 v1  artifact） |
| 根上卷 | `/..` | `/` | 保留根 |
| 混合分隔符 | `a\\b` | `a/b` | 解析认 `\`，输出用 `path_sep()` |
| 四点段 | `x/..../y` | `x/..../y` | 非 `..` token，保留 |
| 隐藏文件 | `.gitignore` | ext len 0 | `path_extension` |
| 双扩展 | `file.tar.gz` | stem+ext 一次扫描 | `path_extension_and_stem` |

演进：消除 `foo//baz` 双分隔符；leading `..` 保留语义与 Go `Clean` 对齐。

---

## 3. 向量与烟测

- 注册表：`tests/baseline/std-path-extreme.tsv`
- 烟测：`tests/path/extreme_clean.sx`
- 门禁：`./tests/run-std-path-extreme-gate.sh`

---

## 4. Gate

```
shux: [SHUX_STD140_PATH_EXTREME] status=ok sx=1 skip=0
std-path-extreme gate OK
```
