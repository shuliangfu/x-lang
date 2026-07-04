// 边界：仅有条件编译块未闭合，应报 unclosed #if
#if FOO
function main(): i32 { return 1; }
