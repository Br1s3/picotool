GCC  = g++
RM   = rm -rf

OTP_EXE ?= otp.cpp
# or no_otp.cpp

OBLIGATOIRE  += \
whereami++.cpp  \
model.cpp       \
elf_file.cpp    \
elf2uf2.cpp     \
bintool.cpp     \
errors.cpp

SRC                  +=\
$(OBLIGATOIRE)         \
data_locs.cpp          \
get_enc_bootloader.cpp \
$(OTP_EXE)             \
main.cpp

CFLAGS              +=\
-Wno-unused-parameter \
-Wno-unused-function  \
-Wno-unused-variable

EXEC = picotool

PICOVERSION = PICOTOOL_VERSION=\"2.3.1\"
SYSTEMVERS = SYSTEM_VERSION=\"host\"
COMPILERINFO = COMPILER_INFO=\"local\"
PICOSUPPORT = SUPPORT_RP2350_A2=1
PICOCODEOTP = CODE_OTP=0

MBEDTLS ?= HAS_MBEDTLS=0
# or HAS_MBEDTLS=1
LIBUSB ?= HAS_LIBUSB=0
# or HAS_LIBUSB=1

.PHONY: install clean

install: $(EXEC)

$(EXEC):
	$(GCC) $(SRC) -o $(EXEC) $(CFLAGS) -D$(PICOVERSION) -D$(SYSTEMVERS) -D$(COMPILERINFO) -D$(PICOSUPPORT) -D$(PICOCODEOTP) -Iinclude

clean:
	$(EXEC)
