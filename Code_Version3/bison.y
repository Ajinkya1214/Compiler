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
    char* build_while(struct symrec* ptr,char* b,char* c);
    char* build_for(struct symrec* ptr,char* a, char*b, char* c);
    char * init_func(struct symrec* ptr, struct symrec* var);
    char * build_func(char* code);
    char * build_entire(char* funcs, char* main);
    char* build_if(struct symrec * ptr, char * x, char* stmts);
    char * update_arr(struct symrec * arr, char* x, char* y);
    void getfromarr(char* $$,struct symrec * arr, char* x);
    void addsym(struct symrec * var);
    void swipetable();

    int label = 0 ;
    int count = 0 ;
    int offset = 0;
    struct symrec * symtable = NULL;
    int sp_size = 0;
    int iflabel = 0;
    char* lastpart; 

    
%}

%union
{
    int num;
    struct symrec * ptr;
    char * base;
    char code[1000];
    char id[100];
}


/* This section is for debugging . Generate the parser description file. */
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
%token PRINT
%token STARTDECL
%token ENDDECL
%token DECL
%token IF
%token ELSE
%token RETURN
%type <base> A
%type    prog
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

prog : n {lastpart = malloc(sizeof(char)*5);strcat(lastpart," \n");} funcs MAIN '{' {offset =0;} adecls  stmts '}' n {char* final = build_entire($3,$8);printf("%s",final);}
;
funcs : func funcs {$$ = malloc(sizeof(char)*(strlen($1)+strlen($2))); strcat($$,$1);strcat($$,$2);free($1);free($2);}
| '\n' funcs {$$=malloc(sizeof(char)*(strlen($2)+10));strcpy($$,"\n");strcat($$,$2);}
|  {$$=malloc(sizeof(char)*10);strcpy($$,"\n");}
;
func : y FUNC '(' VAR ')' {addsym($4); char* temp = init_func($2,$4);$1=temp;} '{' stmts '}' '\n'{ $$ = $1;strcat($$,build_func($8)); swipetable(symtable);}
;
adecls : n STARTDECL '\n' decls ENDDECL '\n'
;
decls : decl decls
| n
;
decl : DECL  VAR '[' NUM ']' '\n' {addsym($2);offset+=4*($4-1);}
;
n : '\n' n
| 
;
y : 
;
stmts : stmt stmts {$$= malloc(sizeof(char)*(strlen($1)+strlen($2)+1));strcpy($$,$1);strcat($$,$2);free($1);free($2);}
| stmt {$$ = malloc(sizeof(char)*(strlen($1)+1));strcpy($$,$1);free($1);}
;
stmt : '\n' {$$ = malloc(sizeof(char)*2);strcpy($$,"\n");}
| WHILE '(' VAR '<' x {count=0;} ')' '{' stmts '}' '\n' {addsym($3);$$=build_while($3,$5,$9);}
| FOR '(' INT VAR '=' x ';' VAR '<' x  ';' VAR '+' '+' ')' '{' stmts '}' '\n' {addsym($4);assert(strcmp($4->name,$8->name)==0);assert(strcmp($8->name,$12->name)==0);$$=build_for($4,$6,$10,$17);}
| VAR '=' expr '\n' {addsym($1);$$=malloc(sizeof(char)*(1000));sprintf($$,"%ssw $t0 %d($sp)\n",$3,$1->addr);} 
| PRINT '(' VAR ')' '\n' {addsym($3);$$ = malloc(sizeof(char)*100); sprintf($$,"lw $t0 , %d($sp)\nli $v0 , 1\nmove $a0 , $t0\nsyscall\n",$3->addr);}
| IF '(' VAR '<' x {count=0;} ')' {addsym($3);} '{' stmts '}' '\n' y {$13 = build_if($3,$5,$10);iflabel+=1;} A {char* temp = malloc(sizeof(char)*(strlen($13)+strlen($15)+1));strcat(temp,$13);strcat(temp,$15);free($13);free($15);$$=temp;} 
| RETURN '\n' {$$ = malloc(sizeof(char)*100);sprintf($$,"j restore\n");}
| VAR '[' x {count=0;} ']' '=' expr '\n' {addsym($1); $$ = update_arr($1,$3,$7);}
;
A : ELSE '{' stmts '}' '\n' {$$=malloc(sizeof(char)*(strlen($3)+100));sprintf($$,"%s\nIflabel%d :\n",$3,iflabel);iflabel+=1;}
|   {$$ = malloc(sizeof(char)*100);sprintf($$,"\nIflabel%d :\n",iflabel);iflabel+=1;}
;
expr :  x   {count=0;sprintf($$,"%s\n",$1);}
| x '+' x   {sprintf($$,"%s\n%s\nadd $t0 $t0 $t1\n",$1,$3);}
| x '*' x   {sprintf($$,"%s\n%s\nmul $t0 $t0 $t1\n",$1,$3);}
| x '/' x   {sprintf($$,"%s\n%s\ndiv $t0 $t0 $t1\n",$1,$3);}
| x '-' x   {sprintf($$,"%s\n%s\nsub $t0 $t0 $t1\n",$1,$3);}
| VAR '(' x {count=0;} ')' {addsym($1);sprintf($$,"%s\njal %s\n",$3,$1->name);}
| VAR '[' x {count=0;} ']' {addsym($1);sprintf($$,"%s\nmul $t0 $t0 4\nadd $t0 $t0 %d\nsw $t0 a\nlw $t0 a($sp)\n",$3,$1->addr);}
;
x : VAR {addsym($1);sprintf($$,"lw $t%d, %d($sp)",count,$1->addr);count++,count=count%2;}
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

char* build_while(struct symrec* ptr,char* x2, char* stmts)
{
    char* $$=malloc(sizeof(char)*(1000));
    sprintf($$,"\nLabel%d : \nlw $t3 %d($sp)\n%s\nbge $t3 $t0 Next%d %sj Label%d\n\nNext%d :",label,ptr->addr,x2,label,stmts,label,label);
    label+=1;
    free(stmts); //release the memory blocked by stmts inside loop
    return $$;
}

char* build_for(struct symrec * ptr,char* a1,char* a2,char* stmts)
{
    char* $$1 = malloc(sizeof(char)*100);
    char* $$2 = malloc(sizeof(char)*(strlen(stmts)+200));
    sprintf($$1,"%s\nmove $t3 $t0\nsw $t3 %d($sp)",a1,ptr->addr);
    sprintf($$2,"\nLabel%d :\nlw $t3 %d($sp)\n%s\nbeq $t3 $t1 Next%d %slw $t3 %d($sp)\nadd $t3 $t3 1\nsw $t3 %d($sp)\nj Label%d\n\nNext%d :",label,ptr->addr,a2,label,stmts,ptr->addr,ptr->addr,label,label);
    char* $$ = malloc(sizeof(char)*(strlen(stmts)+200));
    strcat($$,$$1);
    strcat($$,$$2);
    label+=1;
    free($$1);
    free($$2);
    free(stmts);
    return $$;
}

char* build_if(struct symrec * ptr, char * x, char* stmts)
{
    char* $$ = malloc(sizeof(char)*100);
    sprintf($$,"\nlw $t1 %d($sp)\n%s\nblt $t1 $t0 Iflabel%d\n",ptr->addr,x,iflabel);

    char * temp = malloc(sizeof(char)*(strlen(stmts)+strlen(lastpart)+100));

    char * temp2 =malloc(sizeof(char)*100);
    sprintf(temp2,"\nIflabel%d :\n",iflabel); 

    strcat(temp,lastpart);
    free(lastpart);
    strcat(temp,temp2);
    strcat(temp,stmts);
    free(stmts);
    sprintf(temp2,"j Iflabel%d\n",iflabel+1);
    strcat(temp,temp2);
    free(temp2);
    lastpart = temp;

    return $$;
}


char * init_func(struct symrec* ptr, struct symrec* var)
{
    char* $$ = malloc(sizeof(char)*1000); 
    var->addr = 4;
    var->flag = 1;
    offset =  8;
    sprintf($$,"%s:\nsub $sp, $sp, 20\nsw $ra, 0($sp)\nsw $t0, 4($sp)",ptr->name);
    return $$;
}

char * build_func(char* code)
{
    char * $$ = malloc(sizeof(char)*(strlen(code)+200));
    strcat($$,code);
    strcat($$,"j restore\n");
    return $$;
}

char * build_entire(char* funcs, char* main)
{
    char* temp = malloc(sizeof(char)*(strlen(funcs)+strlen(main)+strlen(lastpart)+200));
    sprintf(temp,".data\na : .word 0\n.text\n\nmain :\n    %sli $v0 , 10\nsyscall\n\n%s",main,funcs);
    strcat(temp,"restore:\n       lw $ra ,0($sp)\n       add $sp, $sp, 20\n       jr $ra\n");
    strcat(temp,lastpart);
    free(lastpart);
    return temp;
}

char * update_arr(struct symrec * arr, char* x, char* y)
{
    char* $$ = malloc(sizeof(char)*(strlen(x)+strlen(y)+200));
    sprintf($$,"%s\nmove $t1 $t0\n%s\nmul $t0 $t0 4\nadd $t0 $t0 %d\nsw $t0 a\nsw $t1 a($sp)\n",y,x,arr->addr);
    return $$;
}


void addsym(struct symrec * var)
{
    if(var->inside == 0)
    {
        var->inside = 1;
        var->flag = 0;
        var->next = symtable;
        symtable = var;
        sp_size+=4;
    }
    if(var->flag == 0){var->addr=offset;offset+=4;var->flag=1;};
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
