.globl asm_multiply
asm_multiply:
    movl 4(%esp), %eax
    movl 8(%esp), %ecx
    imull %ecx, %eax
    ret
