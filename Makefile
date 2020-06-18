all: clean game


game: ass3.o drones.o printer.o scheduler.o target.o
	gcc -m32 -Wall -g ass3.o drones.o printer.o scheduler.o target.o -o game

ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o 
drone.o: drones.s
	nasm -f elf drone.s -o drons.o
printer.o: printer.s
	nasm -f elf printer.s -o printer.o
scheduler.o: scheduler.s
	nasm -f elf scheduler.s -o scheduler.o
target.o: target.s
	nasm -f elf target.s -o target.o

.PHONY: clean

clean: 
	rm -f  *.o game 