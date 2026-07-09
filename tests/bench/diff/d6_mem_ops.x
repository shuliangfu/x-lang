// d6_mem_ops.x — D6 内存操作差分测试（与 d6_mem_ops.c 同源）
// 同源手写内存操作（不依赖 libc），验证数组下标访问 / 循环填充 / 拷贝正确性
function main(): i32 {
  let acc: u32 = 0;

  // memset 手写：填充 16 字节
  let buf: u8[16] = 0;
  let i: i32 = 0;
  while (i < 16) {
    buf[i] = 0xAB;
    i = i + 1;
  }
  i = 0;
  while (i < 16) {
    acc = acc ^ (buf[i] as u32);
    i = i + 1;
  }

  // memcpy 手写：拷贝 8 字节
  let src: u8[8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let dst: u8[8] = 0;
  i = 0;
  while (i < 8) {
    dst[i] = src[i];
    i = i + 1;
  }
  i = 0;
  while (i < 8) {
    acc = acc ^ (dst[i] as u32);
    i = i + 1;
  }

  // 边界：空循环不访问
  let z: u8[4] = 0;
  i = 0;
  while (i < 0) {
    z[i] = 0xFF;
    i = i + 1;
  }
  i = 0;
  while (i < 4) {
    acc = acc ^ (z[i] as u32);
    i = i + 1;
  }

  return (acc & 0xFF) as i32;
}
