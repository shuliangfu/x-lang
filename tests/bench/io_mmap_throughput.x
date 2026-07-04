// io_mmap_throughput.x — I/O 基线：大文件 mmap 顺序扫描（与 run-perf-io.sh 配套）
// 数据文件由脚本生成：tests/bench/.io_mmap_bench_tmp（默认 16MiB）
const fs = import("std.fs");

function main(): i32 {
  // 路径 "tests/bench/.io_mmap_bench_tmp"（NUL 结尾，相对仓库根 cwd）
  let path: u8[31] =
  [116, 101, 115, 116, 115, 47, 98, 101, 110, 99, 104, 47, 46, 105, 111, 95, 109, 109, 97, 112, 95,
  98, 101, 110, 99, 104, 95,
  116, 109, 112, 0];
  let size: usize = 0;
  let ptr: *u8 = fs.mmap_ro(&path[0], &size);
  if (ptr == 0) { return 1; }
  let i: usize = 0;
  let sum: i32 = 0;
  while (i < size) {
    sum = sum + (ptr[i] as i32);
    i = i + 1;
  }
  let r: i32 = fs.munmap(ptr, size);
  if (r != 0) { return 2; }
  return sum & 255;
}
