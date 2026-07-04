// MEM-D1.2：跨模块 struct 工厂 SROA + sum_pair 消费者内联烟测。
const sroa_lib = import("sroa_lib");

function main(): i32 {
  let p: Pair = make_pair(3, 4);
  return sum_pair(p);
}
