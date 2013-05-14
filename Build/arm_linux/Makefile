# User configuration
TFILE   := APP_M251
APP     := 1
OBJDIR  := ../../Bin

# Include common definitions
include ../common/build.mk

TARGET = $(OBJDIR)/$(TFILE)_$(APP)

SOURCES := $(addprefix ../, $(ASM_SRCS) $(C_SRCS) $(CPP_SRCS))
OBJECTS := $(addsuffix .o, $(basename $(SOURCES)))

# Change path for objects to OBJDIR
OBJECTS := $(addprefix $(patsubst %/,%,$(OBJDIR))/, $(notdir $(OBJECTS)))
DEPENDENCY_FILES := $(OBJECTS:.o=.d)

# Add source input directories to search dir
VPATH   += $(dir $(SOURCES))

# Verify that no duplicate source file name exists
ifneq ($(words $(sort $(OBJECTS))), $(words $(OBJECTS)))
	$(error One or more source file name is not unique)
endif

CROSS=arm-none-eabi-
CC=$(CROSS)gcc
CPP=$(CROSS)g++
OBJCOPY=$(CROSS)objcopy
OBJDUMP=$(CROSS)objdump
LD=$(CROSS)ld
AS=$(CROSS)as
SIZE=$(CROSS)size

# Output commands used if you specify V=1 from command line, otherwise be quiet
ifdef V
	Q=
else
	Q=@
endif

MSG_C    = "CC      $<"
MSG_CXX  = "CXX     $<"
MSG_ASS  = "AS      $<"
MSG_LN   = "LN      $@"
MSG_COPY = "OBJCOPY $< $@"
MSG_RM   = "RM      $(OBJDIR)/*.o,*.d $(TARGET).*"
MSG_SIZE = "SIZE    $@"
MSG_DUMP = "OBJDUMP $@"

all: hex

# Helper targets, to build a specific type of output file without having to know the project target name
elf: $(TARGET).elf
hex: $(TARGET).hex
bin: $(TARGET).bin
lss: $(TARGET).lss

clean:
	@echo $(MSG_RM)
	$(Q)rm -rf $(OBJECTS)
	$(Q)rm -rf $(DEPENDENCY_FILES)
	$(Q)rm -rf $(TARGET).hex
	$(Q)rm -rf $(TARGET).bin
	$(Q)rm -rf $(TARGET).elf

# Targets that are not real files
.PHONY: clean lib elf hex bin lss

# Compile the different source files
# The source depends on makefiles to ensure rebuild if the makefiles are changed
$(OBJDIR)/%.o: %.c $(MAKEFILE_LIST)
	@echo $(MSG_C)
	$(Q)$(CC) $(LINUX_ARM_CFLAGS) $(LINUX_ARM_INCLUDES) -c -o $@ $<

$(OBJDIR)/%.o: %.cpp $(MAKEFILE_LIST)
	@echo $(MSG_CXX)
	$(Q)$(CPP) $(LINUX_ARM_GPPFLAGS) $(LINUX_ARM_INCLUDES) -c -o $@ $<

$(OBJDIR)/%.o: %.S $(MAKEFILE_LIST)
	@echo $(MSG_ASS)
	$(Q)$(CC) $(LINUX_ARM_AFLAGS) -c -o $@ $<

# Link project, saving object files and .elf file if build fails
.PRECIOUS: $(OBJECTS)
.SECONDARY:
%.elf: $(OBJECTS)
	@echo $(MSG_LN)
	$(Q)$(CC) -o $@ $(LINUX_ARM_LDFLAGS) -T ../../Source/HwLayer/ArmM3/lds/app1_linux.lds $+
	@echo $(MSG_SIZE)
	$(Q)$(SIZE) $@

%.bin: %.elf
	@echo $(MSG_COPY)
	$(Q)$(OBJCOPY) -O binary $< $@

%.hex: %.elf
	@echo $(MSG_COPY)
	$(Q)$(OBJCOPY) -O ihex $< $@

# Create assembly listing of ELF file
%.lss: %.elf
	@echo $(MSG_DUMP)
	$(Q)$(OBJDUMP) -h -d -S -z -C $< > $@

# Include build dependency files
-include $(DEPENDENCY_FILES)
