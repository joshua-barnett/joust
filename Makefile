.PHONY: all clean

DIRS=bin
ASM6809=./asm6809/src/asm6809
OBJ=ATT.o

all: clean

bin:
	$(shell mkdir -p $(DIRS))

%.o: src/%.SRC
	$(ASM6809) -B -l $<.lst -o bin/$@ $<

joust: bin $(OBJ)

clean:
	-rm bin/*.o
	-rm bin/*.lst
