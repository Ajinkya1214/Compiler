CC := java
BUILD := .build/main

all: build compile run

build:
	mkdir -p .build
	bison -d bison.y
	flex flex.l
	gcc bison.tab.c lex.yy.c -o $(BUILD) -lfl

compile:
	./$(BUILD) <factorial.prog > main.asm

run:
	$(CC) -jar Mars4_5.jar main.asm

clean:
	rm -rf .build *.tab.* *yy* *.asm *.output
