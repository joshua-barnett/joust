JOUST_ROM_URL := https://archive.org/download/ArcadeMachinesChampionCollection2/Champion%20Collection%20-%20Arcade%20%28H-L%29.zip/joust.zip
JOUST_ZIP_FILE := joust.zip
JOUST_ROM_DIRECTORY ?= roms
JOUST_ROM_FILES := \
3006-13.1b \
3006-14.2b \
3006-15.3b \
3006-16.4b \
3006-17.5b \
3006-18.6b \
3006-19.7b \
3006-20.8b \
3006-21.9b \
3006-22.10b \
3006-23.11b \
3006-24.12b \
decoder.4 \
decoder.6 \
joust.snd \
joust.sr4 \
joust.sr6 \
joust.sr7 \
joust.sr8 \
joust.sr9 \
joust.sra \
joust.srb \
joust.src \
joust.wr7 \
joust.wra
JOUST_ROM_FILES := $(addprefix $(JOUST_ROM_DIRECTORY)/,$(JOUST_ROM_FILES))
JOUST_ZIP := joust.zip
JOUSTR_ZIP := joustr.zip
JOUSTY_ZIP := jousty.zip
JOUST_ZIPS := $(addprefix $(JOUST_ROM_DIRECTORY)/,$(JOUST_ZIP) $(JOUSTY_ZIP) $(JOUSTR_ZIP))
JOUST_ZIPS := $(JOUST_ZIP) $(JOUSTR_ZIP) $(JOUSTY_ZIP)
ASM6809 := asm6809
BIN_DIRECTORY := bin
SRC_DIRECTORY := src
SRC_EXTENSION := SRC
OBJ_EXTENSION := O
LST_EXTENSION := LST
SRCS := $(wildcard $(SRC_DIRECTORY)/*.$(SRC_EXTENSION))
OBJS := $(patsubst $(SRC_DIRECTORY)/%.$(SRC_EXTENSION),$(BIN_DIRECTORY)/%.$(OBJ_EXTENSION),$(SRCS))
LSTS := $(patsubst $(SRC_DIRECTORY)/%.$(SRC_EXTENSION),$(BIN_DIRECTORY)/%.$(LST_EXTENSION),$(SRCS))

.ONESHELL:

all: $(OBJS) $(LSTS)

$(BIN_DIRECTORY)/%.$(LST_EXTENSION) $(BIN_DIRECTORY)/%.$(OBJ_EXTENSION): $(SRC_DIRECTORY)/%.$(SRC_EXTENSION)
	@mkdir -p $(@D)
	-$(ASM6809) $< --output=$@ --listing=$(@:.$(OBJ_EXTENSION)=.$(LST_EXTENSION))

$(JOUST_ROM_FILES):
	curl \
	--silent \
	--show-error \
	--location \
	--output $(JOUST_ZIP_FILE) \
	$(JOUST_ROM_URL)
	unzip -j -x $(JOUST_ZIP_FILE) -d $(JOUST_ROM_DIRECTORY)
	rm $(JOUST_ZIP_FILE)
	cd $(JOUST_ROM_DIRECTORY)
	sha1sum -c ../roms.sha1sum

$(JOUST_ZIP): $(JOUST_ROM_FILES)
	cd $(JOUST_ROM_DIRECTORY)
	zip \
	$(JOUST_ZIP) \
	3006-22.10b \
	3006-23.11b \
	3006-24.12b \
	3006-13.1b \
	3006-14.2b \
	3006-15.3b \
	3006-16.4b \
	3006-17.5b \
	3006-18.6b \
	3006-19.7b \
	3006-20.8b \
	3006-21.9b \
	joust.snd \
	decoder.4 \
	decoder.6

$(JOUSTY_ZIP): $(JOUST_ROM_FILES)
	cd $(JOUST_ROM_DIRECTORY)
	zip \
	$(JOUSTY_ZIP) \
	joust.wra \
	3006-23.11b \
	3006-24.12b \
	3006-13.1b \
	3006-14.2b \
	3006-15.3b \
	3006-16.4b \
	3006-17.5b \
	3006-18.6b \
	joust.wr7 \
	3006-20.8b \
	3006-21.9b \
	joust.snd \
	decoder.4 \
	decoder.6

$(JOUSTR_ZIP): $(JOUST_ROM_FILES)
	cd $(JOUST_ROM_DIRECTORY)
	zip \
	$(JOUSTR_ZIP) \
	joust.sra \
	joust.srb \
	joust.src \
	3006-13.1b \
	3006-14.2b \
	3006-15.3b \
	joust.sr4 \
	3006-17.5b \
	joust.sr6 \
	joust.sr7 \
	joust.sr8 \
	joust.sr9 \
	joust.snd \
	decoder.4 \
	decoder.6

$(JOUST_ROM_DIRECTORY): $(JOUST_ZIPS)

.PHONY: clean
clean:
	rm -r $(JOUST_ROM_DIRECTORY) $(BIN_DIRECTORY)
