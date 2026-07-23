# STD-047 std.simd shuffle/select 矢量化实装

## 1. 阅读路径

本文档描述 std.simd 模块中 Vec4f shuffle 与 Vec8i select 的 lane-scalar 实装方案。
XLANG_SIMD_HW 检测硬件 SIMD 可用性；不可用时退化为标量 lane 循环。

## 2. 双层实现

每个 SIMD 操作提供两条路径：
- lane-scalar：逐 lane 标量循环（v[mask[0]], v[mask[1]], ...），不依赖硬件 SIMD
- HW path：当 XLANG_SIMD_HW 可用时走原生 SIMD 指令

## 3. API 语义

- vec4f_shuffle：4-lane f32 shuffle，mask 为 i32[4]
- vec8i_select：8-lane i32 select，按 mask 逐 lane 选择 a/b

## 4. 门禁

gate 脚本验证 mod.x 含 lane-scalar 实装（v[mask[0]]）与 select_lane helper（vec8i_select_lane）。
