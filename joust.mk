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
ZIP_EXTENSION := zip
BIN_EXTENSION := bin
JOUST := joust
JOUSTR := joustr
JOUSTY := jousty
JOUST_VERSIONS := $(JOUST) $(JOUSTR) $(JOUSTY)
JOUST_PATHS := $(addprefix $(JOUST_ROM_DIRECTORY)/,$(JOUST_VERSIONS))
JOUST_ZIPS := $(addsuffix .$(ZIP_EXTENSION),$(JOUST_PATHS))
JOUST_BINS := $(addsuffix .$(BIN_EXTENSION),$(JOUST_PATHS))
ASM6809 := asm6809
CACHE_DIRECTORY := cache
BIN_DIRECTORY := bin
SRC_DIRECTORY := src/original
SRC_EXTENSION := SRC
OBJ_EXTENSION := O
LST_EXTENSION := LST
SRCS := $(wildcard $(SRC_DIRECTORY)/*.$(SRC_EXTENSION))
OBJS := $(patsubst $(SRC_DIRECTORY)/%.$(SRC_EXTENSION),$(BIN_DIRECTORY)/%.$(OBJ_EXTENSION),$(SRCS))
LSTS := $(patsubst $(SRC_DIRECTORY)/%.$(SRC_EXTENSION),$(BIN_DIRECTORY)/%.$(LST_EXTENSION),$(SRCS))

.ONESHELL:

.PHONY: all
all: $(if $(filter 1,$(shell sha1sum -cs $(CACHE_DIRECTORY)/$(SRC_DIRECTORY).sha1sum ; echo $$?)),$(CACHE_DIRECTORY) $(OBJS) $(LSTS))

$(BIN_DIRECTORY)/%.$(LST_EXTENSION) $(BIN_DIRECTORY)/%.$(OBJ_EXTENSION): $(SRC_DIRECTORY)/%.$(SRC_EXTENSION)
	mkdir -p $(@D)
	$(ASM6809) $< --output=$@ --listing=$(@:.$(OBJ_EXTENSION)=.$(LST_EXTENSION)) || true

$(JOUST_ROM_FILES):
	curl \
	--silent \
	--show-error \
	--location \
	--output $(JOUST_ZIP_FILE) \
	$(JOUST_ROM_URL)
	unzip -j -x $(JOUST_ZIP_FILE) -d $(JOUST_ROM_DIRECTORY)
	rm $(JOUST_ZIP_FILE)
	sha1sum -c roms.sha1sum

$(JOUST_ROM_DIRECTORY)/$(JOUST).$(ZIP_EXTENSION): $(JOUST_ROM_FILES)
	zip \
	$@ \
	$(addprefix $(JOUST_ROM_DIRECTORY)/,\
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
	decoder.6)

$(JOUST_ROM_DIRECTORY)/$(JOUST).$(BIN_EXTENSION): $(JOUST_ROM_FILES)
	cat \
	$(addprefix $(JOUST_ROM_DIRECTORY)/,\
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
	decoder.6) > $@

$(JOUST_ROM_DIRECTORY)/$(JOUSTY).$(ZIP_EXTENSION): $(JOUST_ROM_FILES)
	zip \
	$@ \
	$(addprefix $(JOUST_ROM_DIRECTORY)/,\
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
	decoder.6)

$(JOUST_ROM_DIRECTORY)/$(JOUSTY).$(BIN_EXTENSION): $(JOUST_ROM_FILES)
	cat \
	$(addprefix $(JOUST_ROM_DIRECTORY)/,\
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
	decoder.6) > $@

$(JOUST_ROM_DIRECTORY)/$(JOUSTR).$(ZIP_EXTENSION): $(JOUST_ROM_FILES)
	zip \
	$@ \
	$(addprefix $(JOUST_ROM_DIRECTORY)/,\
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
	decoder.6)

$(JOUST_ROM_DIRECTORY)/$(JOUSTR).$(BIN_EXTENSION): $(JOUST_ROM_FILES)
	cat \
	$(addprefix $(JOUST_ROM_DIRECTORY)/,\
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
	decoder.6) > $@

$(JOUST_ROM_DIRECTORY): $(JOUST_ZIPS) $(JOUST_BINS)

.PHONY: clean-%
clean-%:
	rm -rf $*

$(JOUST_ROM_DIRECTORY).sha1sum: $(JOUST_ROM_FILES)
$(JOUST_ROM_DIRECTORY).sha1sum: clean-$(JOUST_ROM_DIRECTORY).sha1sum
	sha1sum $(addprefix $(JOUST_ROM_DIRECTORY)/,3006-*.?b decoder.* joust.s* joust.w*) > $(JOUST_ROM_DIRECTORY).sha1sum

$(CACHE_DIRECTORY)/$(SRC_DIRECTORY).sha1sum: clean-$(CACHE_DIRECTORY)
	mkdir -p cache
	sha1sum $(addprefix $(SRC_DIRECTORY)/,*) > $(CACHE_DIRECTORY)/$(notdir $(SRC_DIRECTORY)).sha1sum

$(CACHE_DIRECTORY): $(CACHE_DIRECTORY)/$(SRC_DIRECTORY).sha1sum

.PHONY: clean
clean: clean-$(BIN_DIRECTORY)
clean: clean-$(CACHE_DIRECTORY)
clean: clean-$(JOUST_ROM_DIRECTORY)
