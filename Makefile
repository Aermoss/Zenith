ZIRCON_PATH := $(abspath ../Zircon)
ZODIAC_PATH := $(abspath ../Zodiac)

COMPILER := $(ZIRCON_PATH)/bin/zirconc.exe
ASSEMBLER := $(ZODIAC_PATH)/bin/zas.exe
LINKER := $(ZODIAC_PATH)/bin/zld.exe
EMULATOR := $(ZODIAC_PATH)/bin/zemu.exe
IMAGER := bin/Imager.exe

default: build

src/Kernel.s: src/Kernel.zir $(wildcard src/*.zir)
	$(COMPILER) $< -o $@ -S -target zodiac

bin/%.o: src/%.s
	$(ASSEMBLER) $< -o $@

bin/Zenith.bin: bin/Start.o bin/Trap.o bin/Kernel.o bin/End.o
	$(LINKER) $^ -o $@ --format=bin --origin=0x40000000

$(IMAGER): tools/Imager.zir
	$(COMPILER) $< -o $@ -I$(ZIRCON_PATH)/include -lucrt

bin/Files.bin: $(IMAGER) $(wildcard files/* files/*/* files/*/*/*)
	$(IMAGER) files -o $@

build: bin/Zenith.bin bin/Files.bin

emulate: bin/Zenith.bin bin/Files.bin
	$(EMULATOR) $(ZODIAC_PATH)/boot.hex --flash=bin/Zenith.bin --flash=bin/Files.bin@0x200000 --quiet

clean:
	del /Q src\Kernel.s bin\*.o bin\*.bin bin\*.exe
