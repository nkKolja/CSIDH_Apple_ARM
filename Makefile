# Makefile for cross-compilation on LINUX 
# Target processor: aarch64 ARMv8  

OPTIMIZATION = -O3

# Default cross-sompiler 
CC=gcc
CROSS_FLAGS=

# Default value set to non-constant time implementation
ifeq "$(CONSTANT)" "TRUE"
	ifeq "$(FASTLADDER)" "TRUE"
	CONST=-D _CONSTANT_ -D _FASTLADDER_
	else
	CONST=-D _CONSTANT_
	endif
endif

ifeq "$(DEBUG)" "TRUE"
	DEB=-g
endif

CFLAGS= $(DEB) $(OPTIMIZATION) $(CROSS_FLAGS) $(CONST) 

all: test_arith test_csidh

test_arith: arith.c arith_asm.S csidh_api.c rng.c arith_test.c
	$(CC) $(CFLAGS) -o test_arith arith.c arith_asm.S csidh_api.c rng.c arith_test.c

test_csidh: arith.c arith_asm.S csidh_api.c rng.c csidh_test.c
	$(CC) $(CFLAGS) -o test_csidh arith.c arith_asm.S csidh_api.c rng.c csidh_test.c

.PHONY: clean

clean:
	rm test_arith test_csidh




# # Makefile for cross-compilation on LINUX 
# # Target processor: aarch64 ARMv8  

# OPTIMIZATION = -O3

# # Default cross-sompiler 
# CC=gcc
# CROSS_FLAGS=

# # Default value set to non-constant time implementation
# ifeq "$(CONSTANT)" "TRUE"
# 	ifeq "$(FASTLADDER)" "TRUE"
# 	CONST=-D _CONSTANT_ -D _FASTLADDER_
# 	else
# 	CONST=-D _CONSTANT_
# 	endif
# endif

# ifeq "$(DEBUG)" "TRUE"
# 	DEB=-g
# endif

# CFLAGS= -c $(DEB) $(OPTIMIZATION) $(CROSS_FLAGS) $(CONST) 

# CSIDH_OBJECTS=arith.o arith_asm.o csidh_api.o rng.o csidh_test.o
# ARITH_OBJECTS=arith.o arith_asm.o csidh_api.o rng.o arith_test.o

# ARITH_TEST: $(ARITH_OBJECTS)
# 	$(CC) $(CROSS_FLAGS) $(OPTIMIZATION) $(ADDITIONAL_FLAGS) -o ARITH_TEST $(ARITH_OBJECTS) $(TEST_OBJECTS)

# CSIDH_TEST: $(CSIDH_OBJECTS)
# 	$(CC) $(CROSS_FLAGS) $(OPTIMIZATION) $(ADDITIONAL_FLAGS) -o CSIDH_TEST $(CSIDH_OBJECTS) $(TEST_OBJECTS)

# arith.o: arith.c arith.h
# 	$(CC) $(CFLAGS) arith.c

# arith_asm.o: arith_asm.S
# 	$(CC) $(CFLAGS) arith_asm.S

# csidh_api.o: csidh_api.c csidh_api.h
# 	$(CC) $(CFLAGS) csidh_api.c

# rng.o: rng.c rng.h
# 	$(CC) $(CFLAGS) rng.c

# csidh_test.o: csidh_test.c
# 	$(CC) $(CFLAGS) csidh_test.c

# arith_test.o: arith_test.c
# 	$(CC) $(CFLAGS) arith_test.c


# .PHONY: clean

# clean:
# 	rm $(ARITH_OBJECTS) $(CSIDH_OBJECTS) $(TEST_OBJECT) CSIDH_TEST ARITH_TEST
