ZIRCON_PATH := $(abspath ../Zircon)
ZODIAC_PATH := $(abspath ../Zodiac)

COMPILER := $(ZIRCON_PATH)/bin/zirconc.exe
ASSEMBLER := $(ZODIAC_PATH)/bin/zas.exe
LINKER := $(ZODIAC_PATH)/bin/zld.exe
EMULATOR := $(ZODIAC_PATH)/bin/zemu.exe
IMAGER := bin/Imager.exe

default: build

src/Kernel.s: src/Kernel.zir $(wildcard src/*.zir)
	$(COMPILER) $< -o $@ -S -target zodiac -ffreestanding

bin/%.o: src/%.s
	$(ASSEMBLER) $< -o $@

bin/Zenith.bin: bin/Start.o bin/Trap.o bin/Kernel.o bin/End.o
	$(LINKER) $^ -o $@ --format=bin --origin=0x40000000

bin/zirconc.s: $(wildcard $(ZIRCON_PATH)/src/*.zir $(ZIRCON_PATH)/include/*/*.zir $(ZIRCON_PATH)/include/*/*/*.zir $(ZIRCON_PATH)/include/*/*/*/*.zir)
	$(COMPILER) $(ZIRCON_PATH)/src/Main.zir -o $@ -S -target zodiac-unknown-zenith -I$(ZIRCON_PATH) -I$(ZIRCON_PATH)/include

bin/zirconc.o: bin/zirconc.s
	$(ASSEMBLER) $< -o $@

files/zirconc: bin/zirconc.o
	$(LINKER) $< -o $@ --format=exe

define ZODIAC_TOOL
bin/$(1).s: $$(wildcard $(ZODIAC_PATH)/src/$(2)/*.zir $(ZODIAC_PATH)/src/Common/*.zir $(ZIRCON_PATH)/include/std/*/*.zir)
	$$(COMPILER) $(ZODIAC_PATH)/src/$(2)/Main.zir -o $$@ -S -target zodiac-unknown-zenith -I$(ZODIAC_PATH) -I$(ZIRCON_PATH)/include -D$(3)

bin/$(1).o: bin/$(1).s
	$$(ASSEMBLER) $$< -o $$@

files/$(1): bin/$(1).o
	$$(LINKER) $$< -o $$@ --format=exe
endef

$(eval $(call ZODIAC_TOOL,zas,Assembler,ASSEMBLER))
$(eval $(call ZODIAC_TOOL,zld,Linker,LINKER))
$(eval $(call ZODIAC_TOOL,zar,Archiver,ARCHIVER))
$(eval $(call ZODIAC_TOOL,zda,Disassembler,DISASSEMBLER))
$(eval $(call ZODIAC_TOOL,zym,Symbols,SYMBOLS))
$(eval $(call ZODIAC_TOOL,ztr,Strings,STRINGS))

toolchain: files/zirconc files/zas files/zld files/zar files/zda files/zym files/ztr

$(IMAGER): tools/Imager.zir
	$(COMPILER) $< -o $@ -I$(ZIRCON_PATH)/include

bin/Files.bin: $(IMAGER) $(wildcard files/* files/*/* files/*/*/* $(ZIRCON_PATH)/include/*/*.zir $(ZIRCON_PATH)/include/*/*/*.zir $(ZIRCON_PATH)/include/*/*/*/*.zir)
	$< files include=$(ZIRCON_PATH)/include -o $@

build: bin/Zenith.bin bin/Files.bin

emulate: bin/Zenith.bin bin/Files.bin
	$(EMULATOR) $(ZODIAC_PATH)/boot.hex --flash=bin/Zenith.bin --flash=bin/Files.bin@0x200000 --quiet

clean:
	del /Q files\zirconc files\zas files\zld files\zar files\zda files\zym files\ztr src\Kernel.s bin\*
