// M-3 负例：不同域 slice 传入带域形参
extern function slice_src(): i32[];
function take_ra(x: i32[]<ra>): i32 { return 0; }

function main(): i32 {
  let s: i32[]<rb> = unsafe { slice_src() };
  take_ra(s);
  return 0;
}
