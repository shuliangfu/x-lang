// M-3 负例：实参域与形参域不一致
extern function slice_src(): i32[];
function take_ra(x: i32[]<ra>): i32 { return 0; }

function main(): i32 {
  region rb {
    let s: i32[]<rb> = unsafe { slice_src() };
    take_ra(s);
  }
  return 0;
}
