##
# Snake
#
# @file
# @version 1.0

all:run

BIN=bin
EXEC=$(BIN)/snake
SRC=src

bin_dir:
	mkdir -p $(BIN)

build:bin_dir $(SRC)
	odin build $(SRC) -out:$(EXEC)

run:build
	./$(EXEC)

# end
