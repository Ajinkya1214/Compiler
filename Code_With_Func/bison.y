%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<assert.h>
    struct symrec
    {
        char* name;
        int addr;
        int flag;
        int inside;
        struct symrec * next;
    };

    int yylex(void);
    void yyerror(char*);
    char* build_while(char* a,char* b,char* c);
    char* build_for(char* a, char*b, char* c);
    char * init_func(struct symrec* ptr, struct symrec* var);
    char * build_func(char* code);
    char * build_entire(char* funcs, char* main);
    void addsym(struct symrec * var);
    void swipetable();

    int label = 0 ;
    int count = 0 ;
    int offset = 0;
    struct symrec * symtable = NULL;

    
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
%token <ptr> FUNC
%token <id> MAIN
// %type   prog
%type <base> stmts
%type <base> stmt
%type <code> expr
%type <base> funcs
%type <base> func
%type <id> x
%type <base> y


%right '='
%left '-' '+'
%left '*' '/'

%%

prog : funcs MAIN '{' {offset =0;} stmts '}' n {char* final = build_entire($1,$5);printf("%s",final);}
| '\n' prog
| '\n'
;

n : '\n' n
| 
;

funcs : func funcs {$$ = malloc(sizeof(char)*(strlen($1)+strlen($2))); strcat($$,$1);strcat($$,$2);free($1);free($2);}
| '\n' funcs {$$=malloc(sizeof(char)*(strlen($2)+100));strcpy($$,"\n");strcat($$,$2);}
| '\n' {$$=malloc(sizeof(char)*10);strcat($$,"\n");}
;

func : y FUNC '(' VAR ')' {addsym($4); char* temp = init_func($2,$4);$1=temp;} '{' stmts '}' '\n'{ $$ = $1;strcat($$,build_func($8)); swipetable(symtable);}
;

y : 
;

stmts : stmt stmts {$$= malloc(sizeof(char)*(strlen($1)+strlen($2)+1));strcpy($$,$1);strcat($$,$2);free($1);free($2);}
| stmt {$$ = malloc(sizeof(char)*(strlen($1)+1));strcpy($$,$1);free($1);}
;

stmt : '\n' {$$ = malloc(sizeof(char)*2);strcpy($$,"\n");}
| WHILE '(' x '<' x ')' '{' stmts '}' '\n' {$$=build_while($3,$5,$8);}
| FOR '(' INT VAR '=' x ';' VAR '<' x  ';' VAR '+' '+' ')' '{' stmts '}' '\n' {assert(strcmp($4->name,$8->name)==0);assert(strcmp($8->name,$12->name)==0);$$=build_for($6,$10,$17);}
| VAR '=' expr '\n' {addsym($1);if($1->flag==0){$1->addr=offset;$1->flag=1;offset+=4;}$$=malloc(sizeof(char)*(1000));sprintf($$,"%ssw $t0 %d($sp)\n",$3,$1->addr);}
;

expr : x   {sprintf($$,"%s\n",$1);count=0;}
| x '+' x  {sprintf($$,"%s\n%s\nadd $t0 $t0 $t1\n",$1,$3);}
| x '*' x  {sprintf($$,"%s\n%s\nmul $t0 $t0 $t1\n",$1,$3);}
| x '/' x  {sprintf($$,"%s\n%s\ndiv $t0 $t0 $t1\n",$1,$3);}
| x '-' x  {sprintf($$,"%s\n%s\nsub $t0 $t0 $t1\n",$1,$3);}
| VAR '(' x ')' {sprintf($$,"%s\njal %s\n",$3,$1->name);}
;

x : VAR {addsym($1);if($1->flag == 0){$1->addr=offset;offset+=4;$1->flag=1;}sprintf($$,"lw $t%d, %d($sp)",count,$1->addr);count++,count=count%2;}
| NUM {sprintf($$,"li $t%d, %d",count,$1);count++;count=count%2;}
;

%%


int main()
{
    
    /* #if YYDEBUG == 1
    extern int yydebug;
    yydebug=1;
    #endif  */
    yyparse();
}

void yyerror(char * s)
{
    printf("%s\n",s);
}

char* build_while(char* x1,char* x2, char* stmts)
{
    char* $$=malloc(sizeof(char)*(1000));
    FILE *fptr;
    fptr = fopen("output.txt","a");
    sprintf($$,"\nLabel%d : \n%s\n%s\nble $t0 $t1 Next%d %sj Label%d\n\nNext%d :",label,x1,x2,label,stmts,label,label);
    fprintf(fptr,"\nLabel%d : \n%s\n%s\nble $t0 $t1 Next%d %sj Label%d\n\nNext%d :",label,x1,x2,label,stmts,label,label);
    label+=1;
    free(stmts); //release the memory blocked by stmts inside loop
    fclose(fptr);
    return $$;
}

char* build_for(char* a1,char* a2,char* stmts)
{
    char* $$1 = malloc(sizeof(char)*100);
    char* $$2 = malloc(sizeof(char)*(strlen(stmts)+100));
    FILE *fptr;
    fptr = fopen("output.txt","a");
    sprintf($$1,"%s\n",a1);
    fprintf(fptr,"%s\n",a1);
    sprintf($$2,"\nLabel%d : \n%s\nbeq $t0 $t1 Next%d %sadd $t0 $t0 1\nj Label%d\n\nNext%d :",label,a2,label,stmts,label,label);
    fprintf(fptr,"\nLabel%d : \n%s\nbeq $t0 $t1 Next%d %sadd $t0 $t0 1\nj Label%d\n\nNext%d :",label,a2,label,stmts,label,label);
    char* $$ = malloc(sizeof(char)*(strlen(stmts)+200));
    strcat($$,$$1);
    strcat($$,$$2);
    label+=1;
    free($$1);
    free($$2);
    free(stmts);
    fclose(fptr);
    return $$;
}

char * init_func(struct symrec* ptr, struct symrec* var)
{
    char* $$ = malloc(sizeof(char)*1000); 
    var->addr = 4;
    var->flag = 1;
    offset =  8;
    FILE *fptr;
    fptr = fopen("output.txt","a");
    sprintf($$,".global %s\n%s:\nsub $sp, $sp, 12\nsw $ra, 0($sp)\nsw $t0, 4($sp)",ptr->name,ptr->name);
    fprintf(fptr,".global %s\n%s:\nsub $sp, $sp, 12\nsw $ra, 0($sp)\nsw $t0, 4($sp)",ptr->name,ptr->name);
    fclose(fptr);
    return $$;
}

char * build_func(char* code)
{
    char * $$ = malloc(sizeof(char)*(strlen(code)+200));
    strcat($$,code);
    strcat($$,"restore:\n       lw $ra ,0($sp)\n       add $sp, $sp, 12\n       jr $ra");
    return $$;
}

char * build_entire(char* funcs, char* main)
{
    char* temp = malloc(sizeof(char)*(strlen(funcs)+strlen(main)+100));
    FILE *fptr;
    fptr = fopen("output.txt","a");
    sprintf(temp,".global main\nmain :\n    %s\n\n%s",main,funcs);
    fprintf(fptr,".global main\nmain :\n    %s\n\n%s",main,funcs);
    fclose(fptr);
    return temp;
}

void addsym(struct symrec * var)
{
    if(var->inside == 0)
    {
        var->inside = 1;
        var->flag = 0;
        var->next = symtable;
        symtable = var;
    }
}

void swipetable()
{
    struct symrec * temp = symtable;
    while(temp!= NULL)
    {
        temp->flag = 0;
        temp=temp->next;
    }
}
