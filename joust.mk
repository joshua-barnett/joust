JOUST_ROM_URL := https://archive.org/download/ArcadeMachinesChampionCollection2/Champion%20Collection%20-%20Arcade%20%28H-L%29.zip/joust.zip
JOUST_ZIP_FILE := joust.zip
JOUST_ROM_DIRECTORY ?= rom
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

.ONESHELL:

default: $(JOUST_ROM_FILES)

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
	sha256sum -c ../rom.sha256sum

.PHONY: clean
clean:
	rm -r $(JOUST_ROM_DIRECTORY)