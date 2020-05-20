CC = g++
CFLAGS = -Wall -m64

all: main.o x86.o
	$(CC) $(CFLAGS) -o result main.o x86.o -lglut -lGLU -lGL

x86.o: x86_function.s
	nasm -f elf64 -o x86.o x86_function.s

main.o: main.cpp
	$(CC) $(CFLAGS) -c -o main.o main.cpp

clean:
	rm -f *.o
