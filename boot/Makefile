@all:
	nasm -f bin boot.asm -o boot.bin

disasm:
	ndisasm boot.bin

runboot:
	qemu-system-x86_64 -hda boot.bin

clean:
	rm -f boot.bin

