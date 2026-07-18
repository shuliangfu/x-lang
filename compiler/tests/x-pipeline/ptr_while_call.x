// ptr_while_call.x — repro typeck_validate while + *Module arg call (arm64 needs ldr x0).
// PLATFORM: SHARED; ARM64 ABI load of x0 is the sensitive path.
const ast = import("ast");

extern function pipeline_module_num_struct_layouts_at(module: *Module): i32;

/**
 * Same loop shape as typeck_validate_struct_layouts_zero_padding condition.
 */
function test_while_call(module: *Module): i32 {
  let li: i32 = 0;
  while (li < pipeline_module_num_struct_layouts_at(module)) {
    li = li + 1;
  }
  return li;
}
