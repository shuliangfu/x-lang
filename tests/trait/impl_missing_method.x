// impl 缺少 trait 声明的方法，应报 missing method
trait Twice { function twice(self): i32; function triple(self): i32; }
impl Twice for i32 {
  function twice(self: i32): i32 { return self * 2; }
}
function main(): i32 { return 0; }
