.SUFFIXES:

GPP  = g++
GCC  = gcc
RM   = rm -rf

OTP_EXEC ?= otp.cpp
# or no_otp.cpp
OTP_EXEO ?= otp.o
# or no_otp.o

MBEDTLS ?= HAS_MBEDTLS=0
# or HAS_MBEDTLS=1
LIBUSB ?= HAS_LIBUSB=1
# or HAS_LIBUSB=1

MUSTPICOTOOLC  += \
whereami++.cpp  \
model.cpp       \
elf_file.cpp    \
elf2uf2.cpp     \
bintool.cpp     \
errors.cpp

MUSTPICOTOOLO  = $(MUSTPICOTOOLC:.cpp=.o)

MUSTLIBUSBC    +=\
usb/ff.c         \
usb/lfs.c        \
usb/lfs_util.c


MUSTLIBUSBO    = $(MUSTLIBUSBC:.c=.o)

SRC                  +=\
$(MUSTPICOTOOLC)       \
data_locs.cpp          \
get_enc_bootloader.cpp \
$(OTP_EXEC)


CFLAGS                    +=\
-Wno-unused-parameter       \
-Wno-unused-function        \
-Wno-unused-variable        \
-Iinclude


EXEC = picotool

PICOVERSION  = PICOTOOL_VERSION=\"2.3.1\"
SYSTEMVERS   = SYSTEM_VERSION=\"host\"
COMPILERINFO = COMPILER_INFO=\"local\"
PICOSUPPORT  = SUPPORT_RP2350_A2=1
PICOCODEOTP  = CODE_OTP=0

.PHONY: install clean


ifeq ($(LIBUSB), HAS_LIBUSB=1)
LDFLAGS                     +=\
-lusb-1.0
CFLAGS                      +=\
-I/usr/include/libusb-1.0
SRC                         +=\
picoboot_connection_cxx.cpp   \
main.cpp
OBJ                          = $(SRC:.cpp=.o)
ALLOBJ = $(MUSTLIBUSBO) $(OBJ)
else
SRC                         +=\
main.cpp
OBJ                          = $(SRC:.cpp=.o)
ALLOBJ = $(OBJ)
endif

install: $(EXEC)

$(EXEC): $(ALLOBJ)
	$(GPP) $^ -o $(EXEC) $(LDFLAGS)
	# $(GPP) -Wl,--verbose $^ -o $(EXEC)


ifeq ($(LIBUSB), HAS_LIBUSB=1)
$(MUSTLIBUSBO): usb/%.o: usb/%.c
	$(GCC) -std=c11 -c $< -o $@ $(CFLAGS) -D$(LIBUSB)
endif

# Need to had that to $(MUSTLIBUSBO) when compile the executable !!
picoboot_connection.o: picoboot_connection.c
	$(GCC) -c $< -o $@ $(CFLAGS) -D$(LIBUSB)

$(OBJ): %.o: %.cpp
	$(GPP) -c $< -o $@ $(CFLAGS) -D$(PICOVERSION) -D$(SYSTEMVERS) -D$(COMPILERINFO) -D$(PICOSUPPORT) -D$(PICOCODEOTP) -D$(MBEDTLS) -D$(LIBUSB)

clean:
	$(RM) $(EXEC) $(OBJ) $(MUSTLIBUSBO)
