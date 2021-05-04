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
    int count = 0;
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
| VAR '=' expr '\n' {printf("%s",$3);printf(" sw $t0 %d($t8)\n",$1->addr);}
;
expr : x   {sprintf($$," %s\n",$1);}
| x '+' x  {sprintf($$," %s\n %s\n ADD $t0 $t0 $t1\n",$1,$3);}
| x '*' x  {sprintf($$," %s\n %s\n MUL $t0 $t0 $t1\n",$1,$3);}
| x '/' x  {sprintf($$," %s\n %s\n DIV $t0 $t0 $t1\n",$1,$3);}
| x '-' x  {sprintf($$," %s\n %s\n SUB $t0 $t0 $t1\n",$1,$3);}
;


x : VAR {sprintf($$,"lw $t%d,%d($t8)",count,$1->addr);count++,count=count%2;}
| NUM {sprintf($$,"li $t%d, %d",count,$1);count++;count=count%2;}
;

%%

int main()
{
    printf(" .data\n");
    printf(" .text\n");
    printf(" li $t8,268500992\n");
    yyparse();
}

void yyerror (char *s)  /* Called by yyparse on error */
{
  printf ("%s\n", s);
}
