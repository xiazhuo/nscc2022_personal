@echo off
set PATH=%cd%\python37-32;%cd%\msys\1.0\bin;%cd%\toolchain\bin;%cd%\qemu;%PATH%
cd .\C_code
mips-mti-elf-gcc -mips32r2 -nostdlib -Ttext 0x80000000 -O2 test.c -o test_opt.o
mips-mti-elf-objdump -d test_opt.o > test_opt.asm
call cmd