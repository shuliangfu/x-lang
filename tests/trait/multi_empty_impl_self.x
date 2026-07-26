// wave492: TWO impls with default i32 method - the multi-impl scenario
trait Counter {
  function get(self): Self;
  function value(self): i32 {
    return 42;
  }
}

struct Dog { val: i32, }
struct Cat { val: i32, }

impl Counter for Dog {
  function get(self: Dog): Dog {
    return Dog { val: self.val };
  }
}

impl Counter for Cat {
  function get(self: Cat): Cat {
    return Cat { val: self.val };
  }
}

function main(): i32 {
  let d: Dog = Dog { val: 10 };
  let c: Cat = Cat { val: 20 };
  return 42;
}