.PHONY: all clean

DOCKER=docker
DIRS=bin
ASM6809=asm6809
VASM6800=vasm6800_oldstyle
VASM6809=vasm6809_oldstyle
WORKDIR=/usr/src/joust
MAKE=make
IMAGE=joust-toolchain:latest

OBJ=ATT.O

clean:
	-rm -rf $(DIRS)

bin: clean
	$(shell mkdir -p $(DIRS))

# %.O: src/%.SRC
# 	$(ASM6809) --bin --listing=bin/$@.LST --output=bin/$@ $<

# http://sun.hasenbraten.de/vasm/release/vasm.html
# -Fbin     | Simple binary output
# -autoexp  | Automatically export all non-local symbols, making them visible to other modules during linking.
# -ast      | Allow the asterisk (*) for starting comments in the first column. This disables the possibility to set the code origin with *=addr in the first column.
# -unsshift | The shift-right operator (>>) treats the value to shift as unsigned, which has the effect that only 0-bits are inserted on the left side. The number of bits in a value depend on the target address type (refer to the appropriate cpu module documentation).
# -i        | Ignore everything after a blank in the operand field and treat it as a comment. This option is only available when the backend does not separate its operands with blanks as well.
# -ldots    | Allow dots (.) within all identifiers.
%.O: src/%.SRC
	$(VASM6809) -Fbin -autoexp -ast -unsshift -i -ldots $< -L bin/$@.LST -o bin/$@

joust: clean bin $(OBJ)

.PHONY:
.ONESHELL:
build:
	$(DOCKER) build \
	--tag \
	$(IMAGE) \
	.

.PHONY:
.ONESHELL:
command: build
	$(DOCKER) run \
	--rm \
	--tty \
	--interactive \
	--workdir $(WORKDIR) \
	--volume $(PWD):$(WORKDIR) \
	$(IMAGE) \
	$(COMMAND)

.PHONY:
.ONESHELL:
shell: COMMAND = bash
shell: command

.PHONY:
.ONESHELL:
all: COMMAND = make joust
all: command
