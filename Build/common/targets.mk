# Build system for DS203
#
# Usage:
#  Use: "make -j"  for paralell build (warning: compiler warnings might not be in logical order)
#  Use: "make V=1" for verbose build
#
# Build targets:
#  all   - Build application
#  lss   - Build application and generate assembly listing file
#  clean - Remove object files and binaries

# Output commands used if you specify V=1 from command line, otherwise be quiet
ifdef V
	Q=
else
	Q=@
endif

# Sanity check input parameters
TARGET     ?=$(error Required parameter TARGET missing)
TARGETDIR  ?=$(error Required parameter TARGETDIR missing)
OBJDIR     ?=$(error Required parameter OBJDIR missing)
LINKERFILE ?=$(error Required parameter LINKERFILE missing)
ASM_SRCS   ?=$(error Required parameter ASM_SRCS missing)
C_SRCS     ?=$(error Required parameter C_SRCS missing)
CPP_SRCS   ?=$(error Required parameter CPP_SRCS missing)
OS         ?=$(error Required parameter OS missing)


# Messages
MSG_C    = "CC      $<"
MSG_CXX  = "CXX     $<"
MSG_ASS  = "AS      $<"
MSG_LN   = "LN      $@"
MSG_COPY = "OBJCOPY $< $@"
MSG_RM   = "RM      $(OBJDIR)/*.o,*.d $(TARGET).*"
MSG_SIZE = "SIZE    $@"
MSG_DUMP = "OBJDUMP $@"
MSG_MKDIR= "MKDIR   $@"

# Generate list of source files and objects
# Need to add a ../ to be compatible with build.mk
SOURCES := $(addprefix ../, $(ASM_SRCS) $(C_SRCS) $(CPP_SRCS))
OBJECTS := $(addsuffix .o, $(basename $(SOURCES)))

# Remove path for objects and use OBJDIR instead
OBJECTS := $(addprefix $(patsubst %/,%,$(OBJDIR))/, $(notdir $(OBJECTS)))
DEPENDENCY_FILES := $(OBJECTS:.o=.d)

# Add source input directories to search dir
VPATH   += $(dir $(SOURCES))

# Verify that no duplicate source file name exists
ifneq ($(words $(sort $(OBJECTS))), $(words $(OBJECTS)))
	$(error One or more source file name is not unique)
endif

all: folders hex

# Helper targets, to build a specific type of output file without having to know the project target name
elf: $(TARGET).elf
hex: $(TARGET).hex
bin: $(TARGET).bin
lss: $(TARGET).lss

clean:
	@echo $(MSG_RM)
	$(Q)rm -rf $(OBJDIR)/*.o
	$(Q)rm -rf $(OBJDIR)/*.d
	$(Q)rm -rf $(TARGET).*

# Generate output folders if they don't exist
folders: $(TARGETDIR) $(OBJDIR)

$(OBJDIR):
	@echo $(MSG_MKDIR)
ifeq ($(OS), windows)
	$(Q)mkdir $(subst /,\\,$@)
else
	$(Q)mkdir -p $@
endif

$(TARGETDIR):
	@echo $(MSG_MKDIR)
ifeq ($(OS), windows)
	$(Q)mkdir $(subst /,\\,$@)
else
	$(Q)mkdir -p $@
endif

# Targets that are not real files
.PHONY: clean lib elf hex bin lss folders

# Compile the different source files
# The source depends on makefiles to ensure rebuild if the makefiles are changed
$(OBJDIR)/%.o: %.c $(MAKEFILE_LIST)
	@echo $(MSG_C)
	$(Q)$(CC) $(LINUX_ARM_CFLAGS) $(LINUX_ARM_INCLUDES) -MMD -c -o $@ $<

$(OBJDIR)/%.o: %.cpp $(MAKEFILE_LIST)
	@echo $(MSG_CXX)
	$(Q)$(CPP) $(LINUX_ARM_GPPFLAGS) $(LINUX_ARM_INCLUDES) -MMD -c -o $@ $<

$(OBJDIR)/%.o: %.S $(MAKEFILE_LIST)
	@echo $(MSG_ASS)
	$(Q)$(CC) $(LINUX_ARM_AFLAGS) -MMD -c -o $@ $<

# Link project, preserving object files and .elf file if build fails
# Add linker search path (-L) for object folder and linker file folder
# Remove BIOS.o from the linker list, since that is referred to in the linkerscript
.PRECIOUS: $(OBJECTS)
.SECONDARY:
%.elf: $(OBJECTS)
	@echo $(MSG_LN)
	$(Q)$(CC) -o $@ $(LINUX_ARM_LDFLAGS) -T $(LINKERFILE) -L $(dir $(LINKERFILE)) -L $(OBJDIR) $(filter-out %BIOS.o, $+)

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

# Disable built-in rules:
.SUFFIXES:
