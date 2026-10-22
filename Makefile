ZIRCON_PATH := $(abspath ../Zircon)
ZODIAC_PATH := $(abspath ../Zodiac)

COMPILER := $(ZIRCON_PATH)/bin/zirconc.exe
ASSEMBLER := $(ZODIAC_PATH)/bin/zas.exe
LINKER := $(ZODIAC_PATH)/bin/zld.exe
EMULATOR := $(ZODIAC_PATH)/bin/zemu.exe

default: build

src/Kernel.s: src/Kernel.zir
	$(COMPILER) $< -o $@ -S -target zodiac

bin/%.o: src/%.s
	$(ASSEMBLER) $< -o $@

bin/Zenith.bin: bin/Start.o bin/Kernel.o bin/End.o
	$(LINKER) $^ -o $@ --format=bin --origin=0x40000000

build: bin/Zenith.bin

emulate: bin/Zenith.bin
	$(EMULATOR) $(ZODIAC_PATH)/boot.hex --flash=$<

clean:
	del /Q src\Kernel.s bin\*.o bin\*.bin
