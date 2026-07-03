.globl asm_helper
asm_helper:
    movl 4(%esp), %eax
    addl $10, %eax
    ret
