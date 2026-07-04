// LANG-006：逻辑与/或折叠
function main(): i32 {
  const V: i32 = (1 && 0) || (1 && 1);
  return V;
}
