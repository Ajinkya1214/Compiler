%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<assert.h>
    struct symrec
    {
        char* name;
        int addr;
        struct symrec * next;
    };

    int yylex(void);
    void yyerror(char*);
    char* build_while(char* a,char* b,char* c);
    char* build_for(char* a, char*b, char* c);
    char * init_func(char* name, struct symrec* var);
    char * build_func(char* code);


    int label = 0 ;
    int count = 0 ;
    int offset = 8;

    
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
%token <id> FOR
%token <id> INT
%token <id> FUNC
%token <id> MAIN
%type    prog
%type <base> stmts
%type <base> stmt
%type <code> expr
%type <base> funcs
%type <base> func
%type <id> x


%right '='
%left '-' '+'
%left '*' '/'

%%

prog : funcs MAIN '{' stmts '}' '\n' {printf("%s",$1);}
| '\n' prog
| '\n'
;

funcs : func funcs {$$ = malloc(sizeof(char)*(strlen($1)+strlen($2))); strcat($$,$1);strcat($$,$2);free($1);free($2);}
|
;

func : FUNC '(' VAR ')' {char* temp = init_func($1,$3);temp=$1;} '{' stmts '}' '\n'{ $$ = $1;strcat($$,build_func($7));}
;
stmts : stmt stmts {$$= malloc(sizeof(char)*(strlen($1)+strlen($2)+1));strcpy($$,$1);strcat($$,$2);free($1);free($2);}
|  
;

stmt : '\n' {$$ = malloc(sizeof(char)*2);strcpy($$,"\n");}
| WHILE '(' x '<' x ')' '{' stmts '}' '\n' {$$=build_while($3,$5,$8);}
| FOR '(' INT VAR '=' x ';' VAR '<' x  ';' VAR '+' '+' ')' '{' stmts '}' '\n' {assert($4->addr==$8->addr);assert($8->addr==$12->addr);$$=build_for($6,$10,$17);}
| VAR '=' expr '\n' {$$=malloc(sizeof(char)*(1000));sprintf($$,"%s\nsw $t0 %d($sp)\n",$3,$1->addr);}
;
expr : x   {sprintf($$," %s\n",$1);}
| x '+' x  {sprintf($$," %s\n %s\n ADD $t0 $t0 $t1\n",$1,$3);}
| x '*' x  {sprintf($$," %s\n %s\n MUL $t0 $t0 $t1\n",$1,$3);}
| x '/' x  {sprintf($$," %s\n %s\n DIV $t0 $t0 $t1\n",$1,$3);}
| x '-' x  {sprintf($$," %s\n %s\n SUB $t0 $t0 $t1\n",$1,$3);}
;
x : VAR {$1->addr=offset; offset+=4 ;sprintf($$,"lw $t%d,%d(sp)",count,$1->addr);count++,count=count%2;}
| NUM {sprintf($$,"li $t%d, %d",count,$1);count++;count=count%2;}
;

%%


int main()
{
    
    #if YYDEBUG == 1
    extern int yydebug;
    yydebug=1;
    #endif  
    yyparse();
}

void yyerror(char * s)
{
    printf("%s\n",s);
}

char* build_while(char* x1,char* x2, char* stmts)
{
    char* $$=malloc(sizeof(char)*(1000));
    sprintf($$,"\nLabel%d : \n%s\n%s\nble $t0 $t1 Next%d %s j Label%d\n\nNext%d :",label,x1,x2,label,stmts,label,label);
    label+=1;
    free(stmts); //release the memory blocked by stmts inside loop
    return $$;
}

char* build_for(char* a1,char* a2,char* stmts)
{
    char* $$1 = malloc(sizeof(char)*100);
    char* $$2 = malloc(sizeof(char)*(strlen(stmts)+100));
    sprintf($$1,"LD R0 %s\n",a1);
    sprintf($$2,"\nLabel%d :\nLD R1 %s\nBE R0 R1 Next%d %sADD R0 R0 $1\nj Label%d\n\nNext%d :",label,a2,label,stmts,label,label);
    char* $$ = malloc(sizeof(char)*(strlen(stmts)+200));
    strcat($$,$$1);
    strcat($$,$$2);
    label+=1;
    free($$1);
    free($$2);
    free(stmts);
    return $$;
}

char * init_func(char* name, struct symrec* var)
{
    char* $$ = malloc(sizeof(char)*1000); 
    sprintf($$,".global %s\n%s:\n        lw $t0, %d($sp)\nsub $sp, $sp, 12\nsw $ra, 0($sp)\nsw $t0, 4($sp)",name,name,var->addr);
    var->addr=4;
    offset=8;
    return $$;
}

char * build_func(char* code)
{
    char * $$ = malloc(sizeof(char)*(strlen(code)+200));
    strcat($$,code);
    strcat($$,"restore:\n       lw $ra ,0($sp)\nadd %sp, $sp,8\njr $ra");
    return $$;
}