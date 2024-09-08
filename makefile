RM=rm -rf
CC=gcc
DEST=/usr

ifeq ($(shell uname -s),Linux)
    CC=gcc
    CP=cp
    DEST=/usr
else ifeq ($(shell uname -s),Darwin)
    CC=gcc-14
    CP=gcp
    DEST=/usr/local
else
    $(error 'OS not supported!')
endif

C_SRCS=$(shell find . -iname "*.c" | tr '\n' ' ')
H_SRCS=$(shell find . -iname "*.h" | tr '\n' ' ')

OBJS=$(C_SRCS:./%.c=release/%.o)

# Clean and compile .so
all: release/libcspecs.so

create-dirs:
	mkdir -p release/cspecs/

release/libcspecs.so: create-dirs $(OBJS)
	$(CC) -shared -o "release/libcspecs.so" $(OBJS)

release/cspecs/%.o: cspecs/%.c
	$(CC) -c -fmessage-length=0 -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"

release/cspecs/collections/%.o: cspecs/collections/%.c
	$(CC) -c -fmessage-length=0 -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"

# Add debug parameters and compile
debug: CC += -DDEBUG -g
debug: all

# Clean release files
clean:
	$(RM) release

install: all
	$(CP) -u release/libcspecs.so $(DEST)/lib
	$(CP) --parents -u $(H_SRCS) $(DEST)/include

uninstall:
	rm -f $(DEST)/lib/libcspecs.so
	rm -rf $(DEST)/include/cspecs

.PHONY: all create-dirs clean install uninstall
