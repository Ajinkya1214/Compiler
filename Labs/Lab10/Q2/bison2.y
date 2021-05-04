%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    int yylex(void);
    void yyerror(char*);
    struct symrec
    {
        char* name;
        int addr;
        struct symrec * next;
    };
    int label = 0;
    
%}

%union
{
    int num;
    struct symrec * ptr;
    char * base;
    char code[1000];
    char id[100];
}

/* Generate the parser description file. */
%verbose
 /* Enable run-time traces (yydebug). */
%define parse.trace

%token <num> NUM
%token <ptr> VAR
%token <id> WHILE
%type <code> prog
%type <base> stmts
%type <base> stmt
%type <code> expr
%type <id> x


%right '='
%left '-' '+'
%left '*' '/'

%%

prog : stmts {printf("%s",$1);}
;
stmts : stmt stmts {$$= malloc(sizeof(char)*(strlen($1)+strlen($2)+1));strcpy($$,$1);strcat($$,$2);}
| stmt {$$=malloc(sizeof(char)*(strlen($1)+1));strcpy($$,$1);}
|
;
stmt : '\n' {$$ = malloc(sizeof(char)*2);strcpy($$,"\n");}
| WHILE '(' VAR '<' VAR ')' '{' stmts '}' '\n' {$$=malloc(sizeof(char)*(1000));sprintf($$,"Label %d : LD R0 %d\n LD R1 %d\n BLE R0 R1 Next %d\n %s\nNext %d :",label,$3->addr,$5->addr,label,$8,label);label+=1;}
| VAR '=' expr '\n' {$$=malloc(sizeof(char)*(1000));sprintf($$,"%s\n SW R0 %d\n",$3,$1->addr);}
;
expr : x    {sprintf($$," LD R0 %s",$1);}
| x '+' x   {sprintf($$," LD R0 %s\n LD R1 %s\n ADD R0 R0 R1\n",$1,$3);}
| x '-' x   {sprintf($$," LD R0 %s\n LD R1 %s\n SUB R0 R0 R1\n",$1,$3);}
| x '*' x   {sprintf($$," LD R0 %s\n LD R1 %s\n MUL R0 R0 R1\n",$1,$3);}
| x '/' x   {sprintf($$," LD R0 %s\n LD R1 %s\n DIV R0 R0 R1\n",$1,$3);}
;
x : VAR {sprintf($$,"%d",$1->addr);}
| NUM {sprintf($$,"$%d",$1);}
;

%%


int main()
{
    
    /* #if YYDEBUG == 1
    extern int yydebug;
    yydebug=1;
    #endif */ 
    yyparse();
}

void yyerror(char * s)
{
    printf("%s\n",s);
}
