# Generate code, user performance analysis
TARGET := riscv64-unknown-linux-gnu-
CC := $(TARGET)gcc
LD := $(TARGET)gcc

PARAMS = sphincs-shake-128s
THASH = robust

CFLAGS := -fPIC -O3 -fno-builtin-printf -fno-builtin-memcmp -fvisibility=hidden -fdata-sections -ffunction-sections
LDFLAGS := -fdata-sections -ffunction-sections

CFLAGS := $(CFLAGS) -Wall -Werror -Wno-nonnull  -Wno-unused-function -g
LDFLAGS := $(LDFLAGS) -Wl,-static -Wl,--gc-sections

CFLAGS := $(CFLAGS) -I c -I c/ref -I tests/sphincsplus/optimization

SOURCES_DIR = ref

SOURCES = \
	c/$(SOURCES_DIR)/address.c \
	c/$(SOURCES_DIR)/merkle.c \
	c/$(SOURCES_DIR)/wots.c \
	c/$(SOURCES_DIR)/wotsx1.c \
	c/$(SOURCES_DIR)/utils.c \
	c/$(SOURCES_DIR)/utilsx1.c \
	c/$(SOURCES_DIR)/fors.c \
	c/$(SOURCES_DIR)/sign.c \
	c/$(SOURCES_DIR)/randombytes.c \
	c/ckb-sphincsplus.c

HEADERS = \
	c/$(SOURCES_DIR)/params.h \
	c/$(SOURCES_DIR)/address.h \
	c/$(SOURCES_DIR)/merkle.h \
	c/$(SOURCES_DIR)/wots.h \
	c/$(SOURCES_DIR)/wotsx1.h \
	c/$(SOURCES_DIR)/utils.h \
	c/$(SOURCES_DIR)/utilsx1.h \
	c/$(SOURCES_DIR)/fors.h \
	c/$(SOURCES_DIR)/api.h \
	c/$(SOURCES_DIR)/hash.h \
	c/$(SOURCES_DIR)/thash.h \
	c/$(SOURCES_DIR)/randombytes.h \
	c/ckb-sphincsplus.h

ifneq (,$(findstring shake,$(PARAMS)))
	SOURCES += \
		c/$(SOURCES_DIR)/fips202.c \
		c/$(SOURCES_DIR)/hash_shake.c \
		c/$(SOURCES_DIR)/thash_shake_$(THASH).c \
		c/$(SOURCES_DIR)/risc-v-asm/riscv_keccak_f1600_bin.S
	HEADERS += \
		c/$(SOURCES_DIR)/fips202.h
endif
ifneq (,$(findstring haraka,$(PARAMS)))
	SOURCES += \
		c/$(SOURCES_DIR)/haraka.c \
		c/$(SOURCES_DIR)/hash_haraka.c \
		c/$(SOURCES_DIR)/thash_haraka_$(THASH).c
	HEADERS += \
		c/$(SOURCES_DIR)/haraka.h
endif
ifneq (,$(findstring sha2,$(PARAMS)))
	SOURCES += \
		c/$(SOURCES_DIR)/sha2.c \
		c/$(SOURCES_DIR)/hash_sha2.c \
		c/$(SOURCES_DIR)/thash_sha2_$(THASH).c
	HEADERS += \
		c/$(SOURCES_DIR)/sha2.h
endif

CFLAGS := $(CFLAGS) -DPARAMS=$(PARAMS) -DCKB_DECLARATION_ONLY -DCKB_C_STDLIB_PRINTF

CKB_CFLAGS := $(CFLAGS) -nostdinc -nostartfiles -nostdlib -Wno-nonnull-compare -DCKB_VM -I deps/ckb-c-stdlib/libc -I deps/ckb-c-stdlib -I build/

all: build/verify

BUILDER_DOCKER := nervos/ckb-riscv-gnu-toolchain@sha256:aae8a3f79705f67d505d1f1d5ddc694a4fd537ed1c7e9622420a470d59ba2ec3

all-via-docker: gen_verify_info
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make -f tests/sphincsplus/optimization/Makefile build/verify"

build/gen_verify_info: tests/sphincsplus/optimization/gen_verify_info.c $(SOURCES) $(HEADERS)
	mkdir -p build
	gcc $(CFLAGS) -fsanitize=address -fsanitize=undefined -o $@ $(SOURCES) $<

gen_verify_info: build/gen_verify_info
	./build/gen_verify_info

build/verify: tests/sphincsplus/optimization/sphincsplus_verify.c $(SOURCES) $(HEADERS)
	$(CC) $(CKB_CFLAGS) -o $@ $(SOURCES) $<

gen_pporf: build/verify
	ckb-debugger --bin build/verify --max-cycles 100000000000000 --pprof build/out.tmp

clean:
	rm -rf build/*