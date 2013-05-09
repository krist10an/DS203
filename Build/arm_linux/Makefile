TFILE := APP_M251
APP := 1

BASE_DIR := ../..
SRC_DIR := $(BASE_DIR)/Source

include ../common/build.mk

OBJY := $(addprefix ../, $(ASM_SRCS:.S=.o) $(C_SRCS:.c=.o) $(CPP_SRCS:.cpp=.o))

CROSS=arm-none-eabi-
CC=$(CROSS)gcc
CPP=$(CROSS)g++
OBJCOPY=$(CROSS)objcopy
LD=$(CROSS)ld
AS=$(CROSS)as
SIZE=$(CROSS)size

all: $(TFILE).hex

.PHONY: clean

clean:
	rm -rf *.o
	rm -rf *.d
	rm -rf *.hex
	rm -rf *.bin
	rm -rf *.elf

.SECONDARY:

%.o: %.c
	$(CC) $(LINUX_ARM_CFLAGS) $(LINUX_ARM_INCLUDES) -c -o $(notdir $@) $<

%.o: %.cpp
	$(CPP) $(LINUX_ARM_GPPFLAGS) $(LINUX_ARM_INCLUDES) -c -o $(notdir $@) $<

%.o: %.S
	$(CC) $(LINUX_ARM_AFLAGS) -c -o $(notdir $@) $<

%.elf: $(OBJY)
	$(CC) -o $@ $(LINUX_ARM_LDFLAGS) -T $(SRC_DIR)/HwLayer/ArmM3/lds/app1_linux.lds $(notdir $(OBJY))
	$(SIZE) $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@
