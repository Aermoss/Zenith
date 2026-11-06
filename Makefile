ZIRCON_PATH := $(abspath ../Zircon)
SVAROG_PATH := $(abspath ../Svarog)

COMPILER := $(ZIRCON_PATH)/bin/zirconc.exe
ASSEMBLER := $(SVAROG_PATH)/bin/svarog-as.exe
LINKER := $(SVAROG_PATH)/bin/svarog-ld.exe
EMULATOR := $(SVAROG_PATH)/bin/svarog-emu.exe
IMAGER := bin/Imager.exe

default: build

src/Kernel.s: src/Kernel.zir $(wildcard src/*.zir)
	$(COMPILER) $< -o $@ -S -target svarog -ffreestanding

bin/%.o: src/%.s
	$(ASSEMBLER) $< -o $@

bin/Triglav.bin: bin/Start.o bin/Trap.o bin/Kernel.o bin/End.o
	$(LINKER) $^ -o $@ --format=bin --origin=0x40000000

bin/zirconc.s: $(wildcard $(ZIRCON_PATH)/src/*.zir $(ZIRCON_PATH)/include/*/*.zir $(ZIRCON_PATH)/include/*/*/*.zir $(ZIRCON_PATH)/include/*/*/*/*.zir)
	$(COMPILER) $(ZIRCON_PATH)/src/Main.zir -o $@ -S -target svarog-unknown-triglav -I$(ZIRCON_PATH) -I$(ZIRCON_PATH)/include

bin/zirconc.o: bin/zirconc.s
	$(ASSEMBLER) $< -o $@

files/zirconc: bin/zirconc.o
	$(LINKER) $< -o $@ --format=exe

define SVAROG_TOOL
bin/$(1).s: $$(wildcard $(SVAROG_PATH)/src/$(2)/*.zir $(SVAROG_PATH)/src/Common/*.zir $(ZIRCON_PATH)/include/std/*/*.zir)
	$$(COMPILER) $(SVAROG_PATH)/src/$(2)/Main.zir -o $$@ -S -target svarog-unknown-triglav -I$(SVAROG_PATH) -I$(ZIRCON_PATH)/include -D$(3)

bin/$(1).o: bin/$(1).s
	$$(ASSEMBLER) $$< -o $$@

files/$(1): bin/$(1).o
	$$(LINKER) $$< -o $$@ --format=exe
endef

$(eval $(call SVAROG_TOOL,svarog-as,Assembler,ASSEMBLER))
$(eval $(call SVAROG_TOOL,svarog-ld,Linker,LINKER))
$(eval $(call SVAROG_TOOL,svarog-ar,Archiver,ARCHIVER))
$(eval $(call SVAROG_TOOL,svarog-objdump,Disassembler,DISASSEMBLER))
$(eval $(call SVAROG_TOOL,svarog-nm,Symbols,SYMBOLS))
$(eval $(call SVAROG_TOOL,svarog-strings,Strings,STRINGS))

toolchain: files/zirconc files/svarog-as files/svarog-ld files/svarog-ar files/svarog-objdump files/svarog-nm files/svarog-strings

$(IMAGER): tools/Imager.zir
	$(COMPILER) $< -o $@ -I$(ZIRCON_PATH)/include

bin/Files.bin: $(IMAGER) $(wildcard files/* files/*/* files/*/*/* $(ZIRCON_PATH)/include/*/*.zir $(ZIRCON_PATH)/include/*/*/*.zir $(ZIRCON_PATH)/include/*/*/*/*.zir)
	$< files include=$(ZIRCON_PATH)/include -o $@

build: bin/Triglav.bin bin/Files.bin

emulate: bin/Triglav.bin bin/Files.bin
	$(EMULATOR) $(SVAROG_PATH)/boot.hex --flash=bin/Triglav.bin --flash=bin/Files.bin@0x200000 --quiet

clean:
	del /Q files\zirconc files\svarog-as files\svarog-ld files\svarog-ar files\svarog-objdump files\svarog-nm files\svarog-strings src\Kernel.s bin\*
