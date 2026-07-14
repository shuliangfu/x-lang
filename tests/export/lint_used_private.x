// L7：private 被 main 调用 → 不应报 unused
function live_private_helper(): i32 {
  return 3;
}

function main(): i32 {
  return live_private_helper();
}
