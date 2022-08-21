@echo off
set PATH=%cd%\python37-32;%cd%\msys\1.0\bin;%cd%\toolchain\bin;%cd%\qemu;%PATH%
cd .\C_code
mips-mti-elf-gcc -mips32r2 -nostdlib -S test.c
mips-mti-elf-gcc -EL -mips32r2 -nostdlib -Ttext 0x80000000 -I include test.s -o test.elf
mips-mti-elf-objcopy -j .text -O binary test.elf test.bin
mips-mti-elf-objdump -d test.elf > test.asm
call cmd