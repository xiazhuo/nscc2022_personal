GCCPREFIX?=mips-mti-elf-

override CFLAGS += -mips32r2 -mno-abicalls -mno-shared -EL -nostdlib -nostdinc -g
override LDFLAGS += -nostdlib -EL -static

CC :=$(GCCPREFIX)gcc
LD      := $(GCCPREFIX)ld
AR      := $(GCCPREFIX)ar
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

SRC   := $(wildcard *.s)
BINS  := $(patsubst %.s, %.bin, $(SRC))

all: $(BINS)

%.bin: %.elf
	$(OBJCOPY) -j .text -O binary $^ $@

%.elf: %.o
	$(LD) $(LDFLAGS) -Ttext 0x80100000 -o $@ $^

%.o: %.s
	$(CC) $(CFLAGS) -x assembler-with-cpp -c -o $@ $^
