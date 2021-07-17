@all:
	mkdir -p bin
	nasm -f bin boot/boot.asm -o bin/boot.bin


disasm:
	ndisasm bin/boot.bin

run:
	qemu-system-x86_64 -hda bin/boot.bin

clean:
	rm -f bin/boot.bin

