# STD-008 std.json 零拷贝解析接口 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ZC-006`、`ZC-004`（StrView）、`STD-012`（`ex_json`）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4（零拷贝语义、大对象模式、拷贝回退） |
| 2 | 打开 `std/json/mod.sx` 看 `parse_string_view` |
| 3 | `./tests/run-std-json-gate.sh` |
| 4 | 大 JSON 留在 `read_ptr` / `mmap` 缓冲内，用 view 读字段 |

---

## 2. 零拷贝语义

| API | userland 拷贝 | 说明 |
|-----|---------------|------|
| `parse_number` | **0** | 单遍扫描输入 `ptr`，结果写入标量 |
| `parse_null` / `parse_bool` | **0** | 原地匹配字面量 |
| `parse_string_view` | **0** | 无 `\\` 转义时，返回 **输入缓冲内部** 指针 |
| `parse_string` | **1** | 含转义或调用方需要独立缓冲时使用 |
| `append_*` / `escape_string` | 写入调用方 `buf` | 生成路径，非解析 |

**`parse_string_view` 契约**

- 成功：返回 `ptr+1`（跳过开头 `"`），`out_len` 为内容长度，`consumed` 含闭合引号。
- 含转义：返回 `0`，`out_len == json_view_needs_copy()`（**-2**）→ 改用 `parse_string`。
- 语法错误：返回 `0`，`out_len == -1`。

与 ZC-006 一致：**能 view 不 copy**；转义是唯一强制拷贝触发点（v1）。

---

## 3. 大对象解析模式

典型流程（**large object**，无额外堆拷贝读字符串字段）：

```
read_ptr / fs_mmap_ro  →  大缓冲 buf[len]
       ↓
parse_string_view(&buf[i], remain, &flen, &consumed)
       ↓
StrView = string_view(vp, flen)   // 与 std.string ZC-4 衔接
```

| 场景 | 推荐 API |
|------|----------|
| HTTP body / 配置文件 ≥64KiB | 缓冲内 `parse_string_view` |
| 含 `\\n` `\\uXXXX` 的 JSON 字符串 | `parse_string` 拷贝到栈/arena |
| 数字 / bool / null | 任意 `parse_*`（已零拷贝） |

权威 manifest：`tests/baseline/std-json-manifest.tsv`。

---

## 4. 拷贝回退路径

```su
let vp: *u8 = parse_string_view(ptr, len, &flen, &consumed);
if (vp != 0 as *u8) {
  let v: StrView = string_view(vp, flen);  // zero copy
} else if (flen == json_view_needs_copy()) {
  let n: i32 = parse_string(ptr, len, stack_buf, cap, &consumed);  // copy path
}
```

---

## 5. API 面（10 函数）

解析（读）：

- `parse_number`、`parse_null`、`parse_bool`
- `parse_string_view`（zero copy）、`parse_string`（copy）
- `json_view_needs_copy`

生成（写）：

- `escape_string`、`append_null`、`append_bool`、`append_number`

实现：`std/json/mod.sx` + `json_parse_string_view_c` in `std/json/json.c`。

---

## 6. 验证与门禁

```bash
./tests/run-std-json-gate.sh
./tests/run-json.sh   # runnable 回归
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/std-json-zc-v1.md` |
| manifest | `tests/baseline/std-json-manifest.tsv` |
| 库 | `tests/lib/std-json.sh` |
| 门禁 | `tests/run-std-json-gate.sh` |
| 烟测 | `tests/json/main.sx`、`tests/json/zc_parse_string_view.sx` |
| ZC 交叉 | `tests/baseline/zc-semantics.tsv` |

**STD-008 状态：定版 ✅**
