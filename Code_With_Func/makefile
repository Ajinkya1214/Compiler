all: bison flex compile run 

bison:
	bison -d bison.y

flex:
	flex flex.l

compile:
	gcc lex.yy.c bison.tab.c -lfl

run:
	./a.out <strln.prog

clean:
	rm a.out lex.yy.c bison.tab.c