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

$(IMAGER): tools/Imager.zir
	$(COMPILER) $< -o $@ -I$(ZIRCON_PATH)/include -lucrt

bin/Files.bin: $(IMAGER) $(wildcard files/* files/*/* files/*/*/* $(ZIRCON_PATH)/include/*/*.zir $(ZIRCON_PATH)/include/*/*/*.zir $(ZIRCON_PATH)/include/*/*/*/*.zir)
	$< files include=$(ZIRCON_PATH)/include -o $@

build: bin/Zenith.bin bin/Files.bin

emulate: bin/Zenith.bin bin/Files.bin
	$(EMULATOR) $(ZODIAC_PATH)/boot.hex --flash=bin/Zenith.bin --flash=bin/Files.bin@0x200000 --quiet

clean:
	del /Q files\zirconc src\Kernel.s bin\*
