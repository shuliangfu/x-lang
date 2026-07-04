// 条件编译：#if target_os == "..." 与 #[cfg] 对齐（Linux=41 / macOS=42 / 其他=43）
#if target_os == "linux"
function main(): i32 { return 41; }
#elseif target_os == "macos"
function main(): i32 { return 42; }
#else
function main(): i32 { return 43; }
#endif
