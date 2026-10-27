.SUFFIXES:

GPP  = g++
GCC  = gcc
RM   = rm -rf


PICOVERSION  = PICOTOOL_VERSION=\"2.3.1\"
SYSTEMVERS   = SYSTEM_VERSION=\"host\"
COMPILERINFO = COMPILER_INFO=\"local\"
PICOSUPPORT  = SUPPORT_RP2350_A2=1
PICOCODEOTP  = CODE_OTP=0

OTPCPP ?= otp.cpp
# or no_otp.cpp

# This macro does not compile yet
MBEDTLS ?= HAS_MBEDTLS=0
# or HAS_MBEDTLS=1

LIBUSB ?= HAS_LIBUSB=1
# or HAS_LIBUSB=1


SNIPPETSRCCPP      += \
whereami++.cpp        \
model.cpp             \
elf_file.cpp          \
elf2uf2.cpp           \
bintool.cpp           \
errors.cpp            \
get_xip_ram_perms.cpp

SNIPPETSRCOBJ  = $(SNIPPETSRCCPP:.cpp=.o)

USBC                 +=\
usb/ff.c               \
usb/ffunicode.c        \
usb/lfs.c              \
usb/lfs_util.c         \
picoboot_connection.c

USBOBJ    = $(USBC:.c=.o)

SRCCPP               +=\
$(SNIPPETSRCCPP)       \
data_locs.cpp          \
get_enc_bootloader.cpp \
$(OTPCPP)


CFLAGS                    +=\
-Wno-unused-parameter       \
-Wno-unused-function        \
-Wno-unused-variable        \
-Iinclude


EXEC = picotool

.PHONY: install clean


ifeq ($(LIBUSB), HAS_LIBUSB=1)
LDFLAGS                     +=\
-lusb-1.0

CFLAGS                      +=\
-I/usr/include/libusb-1.0

SRCCPP                      +=\
picoboot_connection_cxx.cpp

SNIPPETSRCOBJ               +=\
picoboot_connection.o
endif

SRCCPP                      +=\
main.cpp

OBJ                          = $(SRCCPP:.cpp=.o)

ifeq ($(LIBUSB), HAS_LIBUSB=1)
ALLOBJ                       = $(USBOBJ) $(OBJ)
else
ALLOBJ                       = $(OBJ)
endif

install: $(EXEC)

$(EXEC): $(ALLOBJ)
	$(GPP) $^ -o $(EXEC) $(LDFLAGS)

ifeq ($(LIBUSB), HAS_LIBUSB=1)
$(USBOBJ): %.o: %.c
	$(GCC) -std=c11 -c $< -o $@ $(CFLAGS) -D$(LIBUSB)
endif

$(OBJ): %.o: %.cpp
	$(GPP) -c $< -o $@ $(CFLAGS) -D$(PICOVERSION) -D$(SYSTEMVERS) -D$(COMPILERINFO) -D$(PICOSUPPORT) -D$(PICOCODEOTP) -D$(MBEDTLS) -D$(LIBUSB)

clean:
	$(RM) $(EXEC) $(ALLOBJ)
