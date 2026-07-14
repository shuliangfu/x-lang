// L7：private helper 本模块未引用 → check 应 warning unused private
function dead_private_helper(): i32 {
  return 7;
}

function main(): i32 {
  return 0;
}
