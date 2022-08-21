@echo off
set PATH=%cd%\python37-32;%cd%\msys\1.0\bin;%cd%\toolchain\bin;%cd%\qemu;%PATH%
cd .\testbin
mips-mti-elf-gcc -EL -mips32r2 -nostdlib -Ttext 0x80000000 -I include test.S -o test.elf
mips-mti-elf-objcopy -j .text -O binary test.elf test.bin
mips-mti-elf-objdump -d test.elf > test.asm
call cmd