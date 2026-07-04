function main(): i32 {
  region wa {
    if (1 != 0) { return 1; }
    if (2 != 0) { return 2; }
    if (3 != 0) { return 3; }
    if (4 != 0) { return 4; }
    if (5 != 0) { return 5; }
  }
  return 0;
}
