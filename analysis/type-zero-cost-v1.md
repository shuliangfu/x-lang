# TYPE-005 零成本抽象回归检查 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `run-bcmp-gate.sh`、`TYPE-001/002/003` 对齐  
> 关联：`PERF-001`（Zig 基线）、`ZC-006`（零拷贝语义）、`LANG-003`（泛型单态化）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 检查层 Z1–Z6 |
| 2 | 打开 `tests/baseline/type-zero-cost-bench.tsv` |
| 3 | `./tests/run-type-zero-cost-gate.sh` |
| 4 | `./tests/run-bcmp-gate.sh`（Linux CI 性能对标） |

---

## 2. 检查层 Z1–Z6（zero-cost abstraction）

权威：`tests/baseline/type-zero-cost.tsv`（**6** 条 `layer_*`）。

| 层级 | 抽象 | 零成本机制 | 回归 |
|------|------|------------|------|
| **Z1-linear-abi** | `Linear(T)` | 与 `T` 同布局/ABI；无 drop 表 | `move_ok.sx` + TYPE-001 |
| **Z2-generic-mono** | `id<T>(x)` | 编译期单态化，无 vtable | `generic_id_i32.sx` |
| **Z3-struct-byval** | 小 struct 按值传参 | 栈拷贝 = C struct | `struct_param.sx` B-CMP |
| **Z4-region-zero** | `region` / `[]T<label>` | 标签不进 ABI/runtime | TYPE-002 RFC |
| **Z5-call-depth** | 多层函数调用 | 无额外间接层 | `call_boundary.sx` B-CMP |
| **Z6-mem-hotpath** | 循环 memcpy 热路径 | 无多余用户态 copy | `mem_copy.sx` B-CMP |

**copy 判定（v1）**：

1. **无额外堆分配**：抽象包装不得在热路径引入 malloc。
2. **无隐式深拷贝**：`[]T` slice 赋值共享 `(ptr,len)`，不复制元素（ZC-3）。
3. **性能回归**：P0 microbench 须 **≤ SHUX_PERF_C_O3_RATIO × C -O3**（`run-bcmp-gate.sh`）。

---

## 3. 基准矩阵（bench）

`tests/baseline/type-zero-cost-bench.tsv`（**6** 条 `bench_*`）。

| bench_id | .sx | 对标 | gate |
|----------|-----|------|------|
| `bench_loop` | `loop_i32.sx` | `loop_i32.c` | bcmp |
| `bench_mem` | `mem_copy.sx` | `mem_copy.c` | bcmp |
| `bench_struct` | `struct_param.sx` | `struct_param.c` | bcmp |
| `bench_call` | `call_boundary.sx` | `call_boundary.c` | bcmp |
| `bench_generic` | `generic_id_i32.sx` | — | compile smoke |
| `bench_linear` | `move_ok.sx` | — | typeck smoke |

---

## 4. Golden 用例

| case_id | 验证 | 期望 |
|---------|------|------|
| `case_linear` | `Linear` 无额外字段 | `check` 通过 |
| `case_generic` | 泛型单态化可编译 | `generic_id_i32.sx` |
| `case_region` | region 块正例 | `region_same_ok.sx` |
| `case_loop` | 标量循环 B-CMP 锚点 | `loop_i32.sx` |
| `case_bcmp` | 四件套 B-CMP | `perf baseline OK`（CI） |

---

## 5. 非目标（v1）

- IR 级「拷贝证明」自动分析
- 与 Zig 的 1:1 代码尺寸对比
- 跨模块 LTO 前后的全程序证明

---

## 6. 验证与门禁

```bash
./tests/run-type-zero-cost-gate.sh   # runnable：manifest + zero-cost hooks
./tests/run-type-zero-cost.sh        # typeck/compile 烟测
./tests/run-bcmp-gate.sh             # Linux：≤1.0× C -O3
```

**gate report**：stdout 须含 `type-zero-cost gate OK`；失败打印 `type-zero-cost FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/type-zero-cost-v1.md` |
| manifest | `tests/baseline/type-zero-cost.tsv` |
| bench | `tests/baseline/type-zero-cost-bench.tsv` |

**TYPE-005 状态：定版 ✅**
