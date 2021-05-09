CC := java
BUILD := .build/main

all: build compile run

build:
	mkdir -p .build
	flex flex.l
	bison -d bison.y
	gcc bison.tab.c lex.yy.c -o $(BUILD) -lfl

compile:
	./$(BUILD) <strln_with_input.prog > main.asm

run:
	$(CC) -jar Mars4_5.jar main.asm

clean:
	rm -rf .build *.tab.* *yy* *.asm *.output
