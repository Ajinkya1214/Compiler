%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h> 
    int  yylex(void);
    void yyerror (char  *);
    struct symrec
    {
        char * name;
        int addr;
        struct symrec* next;
    };
%}


%union 
{
    int num;
    struct symrec* ptr;
    char code[1000];
    char nData[100];
}

%token <num> NUM
%token <ptr> VAR
%type <code> expr
%type <nData> x

%right '='
%left '-' '+'
%left '*' '/'


%%

input : 
| input line
;
line : '\n'
| VAR '=' expr '\n' {printf("%s",$3);printf(" ST %d R0\n",$1->addr);}
;
expr : x   {sprintf($$," LD R0 %s\n",$1);}
| x '+' x  {sprintf($$," LD R0 %s\n LD R1 %s\n ADD R0 R0 R1\n",$1,$3);}
| x '*' x  {sprintf($$," LD R0 %s\n LD R1 %s\n MUL R0 R0 R1\n",$1,$3);}
| x '/' x  {sprintf($$," LD R0 %s\n LD R1 %s\n DIV R0 R0 R1\n",$1,$3);}
| x '-' x  {sprintf($$," LD R0 %s\n LD R1 %s\n SUB R0 R0 R1\n",$1,$3);}
;


x : VAR {sprintf($$,"%d",$1->addr);}
| NUM {sprintf($$,"$%d",$1);}
;

%%

int main()
{
    yyparse();
}

void yyerror (char *s)  /* Called by yyparse on error */
{
  printf ("%s\n", s);
}
