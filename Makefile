.PHONY: all clean

DOCKER=docker
DIRS=bin
ASM6809=asm6809
OBJ=ATT.O
WORKDIR=/usr/src/joust
MAKE=make
IMAGE=joust-toolchain:latest

all: clean

bin:
	$(shell mkdir -p $(DIRS))

%.O: src/%.SRC
	$(ASM6809) -B -l bin/$@.LST -o bin/$@ $<

joust: bin $(OBJ)

clean:
	-rm -rf $(DIRS)

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
all: clean
all: COMMAND = make joust
all: command
