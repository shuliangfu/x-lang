# STD-124：std.regex 原子分组 `(?>...)` v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STD-099 占有型量词、STD-063 分组

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 |
| 2 | `tests/baseline/std-regex-atomic-manifest.tsv` |
| 3 | `./tests/run-std-regex-atomic-gate.sh` |
| 4 | 烟测：`tests/regex/atomic_match.sx` |

---

## 2. 原子分组（v1）

| 语法 | 说明 |
|------|------|
| `(?>...)` | 非捕获原子组；组内匹配成功后禁止回溯 |
| `(?` 非 `>` | 编译失败 |

**语义**：组内 `atomic_nest>0` 时 `*`/`+`/`?` 按占有型处理。

**烟测向量**：`(a+)a` 匹配 `aaa`；`(?>(a+))a` 失败（组内 `a+` 吞掉全部 `a` 后无法匹配尾 `a`）。

---

## 3. Gate

```bash
./tests/run-std-regex-atomic-gate.sh
```

```
shux: [SHUX_STD124_REGEX_ATOMIC] status=ok c=1 su=1 skip=0
std-regex-atomic gate OK
```
