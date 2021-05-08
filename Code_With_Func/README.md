  
How to compile ?
  bison -d bison.y
  flex flex.l
  gcc lex.yy.c bison.tab.c -lfl
  
How to run ?
  ./a.out <strln.prog

Using makefile 
- Run `make`