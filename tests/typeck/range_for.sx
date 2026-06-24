// LOOP-02：范围 for — for (i : start .. end) desugar 为 let + C for（半开区间 [start, end)）

function sum_range(n: i32): i32 {
  let total: i32 = 0;
  for (i : 0 .. n) {
    total = total + i;
  }
  return total;
}

function nested_sum(): i32 {
  let acc: i32 = 0;
  for (outer : 1 .. 4) {
    for (inner : 0 .. outer) {
      acc = acc + 1;
    }
  }
  return acc;
}

function main(): i32 {
  if (sum_range(5) != 10) {
    return 1;
  }
  if (nested_sum() != 6) {
    return 2;
  }
  return 0;
}
