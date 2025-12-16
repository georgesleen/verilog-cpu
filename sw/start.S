.section .text
.globl _start
_start:
        la sp, _stack_top
        call main
1: j 1b

.section .bss
.space 1024
_stack_top:
