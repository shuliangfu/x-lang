// 测试 extern "C" / extern "X" / extern（默认）ABI 标记语法
// P0a 阶段：语义降级，所有 ABI 都按 C ABI 生成，不改变行为

// 默认 X ABI（无标记）
extern function test_default_abi(a: i32): i32;

// 显式 X ABI
extern "X" function test_x_abi(a: i32): i32;

// C ABI
extern "C" function test_c_abi(a: i32): i32;

function main(): i32 {
  return 0;
}
