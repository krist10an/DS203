# User configuration
TFILE := APP_M251
APP := 1

OBJDIR    := ../../Bin/objects
TARGETDIR := ../../Bin

TARGET := $(TARGETDIR)/$(TFILE)

# Compiler configuration
CROSS   = arm-none-eabi-
CC      =$(CROSS)gcc
CPP     =$(CROSS)g++
OBJCOPY =$(CROSS)objcopy
OBJDUMP =$(CROSS)objdump
LD      =$(CROSS)ld
AS      =$(CROSS)as
SIZE    =$(CROSS)size

OS      ?= linux

# Include source file definitions
include ../common/build.mk
#include ../common/build_ver2.mk

# Include build targets
include ../common/targets.mk
