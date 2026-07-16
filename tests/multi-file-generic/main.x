// 跨模块调用：import foo，main 调用 id_i32(42) 应返回 42。
// （泛型 id<T> 跨模块单态化未闭合前，用显式 monomorph 符号验收 import+link。）
const foo = import("foo");
function main(): i32 { return foo.id_i32(42); }
