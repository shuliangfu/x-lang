# compiler/include/ — C 头文件

当编译器用 **C** 实现时，本目录存放 **.h 头文件**。

- **用途**：声明 lexer、parser、ast、typeck、ir、codegen、driver 等模块的对外接口，供 `src/` 下 .c 文件包含。
- **E-05 v1/v2 inventory**：默认 bootstrap 仍 active 的头见 `tests/baseline/e05-include-inventory.tsv`；C 前端 API 头 **文件保留**、默认 `runtime_driver_no_c.o` **不 `#include`**（E-05 v2）。
- **自举后**：若编译器全部改为 .sx，本目录可废弃或仅保留与 C 互操作相关的少量头文件（E-05 v2+ FFI/ABI）。

若使用 C++，也可将 .h 放在此处或与 src 按模块分目录对应。
