// 跨模块调用目标：identity（产品轨 C 后端已支持同模块泛型单态；跨模块 id<T> 单态仍在补齐）。
// 本文件提供显式 i32 identity，供 main import 后返回 42。
export function id_i32(x: i32): i32 { return x; }
