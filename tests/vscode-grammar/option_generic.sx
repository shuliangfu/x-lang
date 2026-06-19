// TOOL-009 golden：Option<T> / Result<T,E> 泛型类型高亮
const option = import("core.option");
const result = import("core.result");

function demo(): i32 {
  let o: Option<i32> = Option<i32>.none();
  let r: Result<i32, i32> = Result<i32, i32>.ok(1);
  return o.is_some() ? 1 : r.unwrap_or(0);
}
