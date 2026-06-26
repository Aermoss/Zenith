default: prepare run

bin/Boot.o: src/Boot.s
	zirconc -target aarch64-none-elf -c $< -o $@

bin/Kernel.o: src/Kernel.zir
	zirconc -target aarch64-none-elf -ffreestanding -c $< -o $@ -O0

bin/Kernel.elf: bin/Boot.o bin/Kernel.o
	ld.lld -T Linker.ld $^ -o $@

	qemu-system-aarch64 -machine virt -cpu cortex-a57 -kernel $< -nographic
run: bin/Kernel.elf

prepare:
	if not exist bin mkdir bin

clean:
	if exist bin rmdir /s /q bin
