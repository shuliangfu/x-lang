// 跨模块泛型调用：import foo，main 调用 id<i32>(42) 应返回 42
const foo = import("foo");
function main(): i32 { return id<i32>(42); }
