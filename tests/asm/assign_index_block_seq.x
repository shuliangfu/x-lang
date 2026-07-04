function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let j: i32 = 2;
  arr[1] = arr[j];
  arr[0] = arr[1];
  return arr[0] + arr[1] + arr[2];
}
