ifdef DEV
include joust.mk
else
-include env.mk
include picard.mk
endif
