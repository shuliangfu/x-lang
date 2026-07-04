#include <stdint.h>
#include <stddef.h>
int asm_asm_codegen_ast(void*a,void*b,void*c,void*d){return -1;}
int asm_asm_codegen_elf_o(void*a,void*b,void*c,void*d,void*e){return -1;}
int io_read_batch_buf(void){return -1;}
int io_write_batch_buf(void){return -1;}
int typeck_lsp_main(void){return -1;}
extern int32_t typeck_preprocess_x_buf(const uint8_t*,ptrdiff_t,uint8_t*,int32_t);
int32_t preprocess_x_buf(const uint8_t*s,ptrdiff_t l,uint8_t*o,int32_t c){return typeck_preprocess_x_buf(s,l,o,c);}
