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

    /* this value will be used to create new labels whenever a for/while loop is seen*/
    int label = 0 ;


    int count = 0 ;

    int offset = 0;

    /* We will be creating a new global symbol table as the parsing happens. Everytime a new VAR is seen, certain operations are performed on it 
    This mechanism will essentially make sure that each function knows where to store its local variables and where to access them from.*/

    struct symrec * symtable = NULL;

    /* this value will be used to create new labels whenever an if statement is seen */

    int iflabel = 0;

    /* all the jump labels of conditionals will be appended to this lastpart and printed in the last */

    char* lastpart;

    /* some helper variables */
    char* t0;
    char* t1;
    
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
%token INPUT
%type <base> A
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

prog :  funcs MAIN '{' '\n' {offset =0;} adecls  stmts '}' stmts {char* final = build_entire($1,$7);printf("%s",final);}
| MAIN '{' '\n' {offset =0;} adecls  stmts '}' stmts {char* t = malloc(sizeof(char)*10);strcpy(t,"\n");char* final = build_entire(t,$6);printf("%s",final);}
;
funcs : func funcs {$$ = malloc(sizeof(char)*(strlen($1)+strlen($2))); strcat($$,$1);strcat($$,$2);free($1);free($2);}
| func {$$=$1;}
;
func : FUNC '(' VAR ')' { offset =4;t0 = init_func($1,$3);addsym($3);} '{' stmts '}' stmts { $$ = t0;strcat($$,build_func($7)); swipetable(symtable);}
;
adecls : STARTDECL '\n' decls ENDDECL '\n'
|
;
decls : decl decls
| decl
;
decl : DECL  VAR {addsym($2);} '[' NUM ']' '\n' {offset+=4*($5-1);} 
;
stmts : stmt stmts {$$= malloc(sizeof(char)*(strlen($1)+strlen($2)+1));strcpy($$,$1);strcat($$,$2);free($1);free($2);}
| stmt {$$=$1;}
;
stmt : WHILE '(' VAR  {addsym($3);} '<' x {count=0;} ')' '{' stmts '}' {$$=build_while($3,$6,$10);}
| FOR '(' INT VAR {addsym($4);} '=' x ';' VAR '<' x  ';' VAR '+' '+' ')' '{' stmts '}' {assert(strcmp($4->name,$9->name)==0);assert(strcmp($9->name,$13->name)==0);$$=build_for($4,$7,$11,$18);}
| VAR {addsym($1);} '=' expr {$$=malloc(sizeof(char)*(1000));sprintf($$,"%ssw $t0 %d($sp)\n",$4,$1->addr);} 
| PRINT '(' VAR ')' {addsym($3);$$ = malloc(sizeof(char)*100); sprintf($$,"lw $t0 , %d($sp)\nli $v0 , 1\nmove $a0 , $t0\nsyscall\n",$3->addr);}
| IF '(' VAR {addsym($3);} '<' x {count=0;} ')' '{' stmts '}' {t1 = build_if($3,$6,$10);iflabel+=1;} A {char* t2 = malloc(sizeof(char)*(strlen(t1)+strlen($13)+1));strcat(t2,t1);strcat(t2,$13);free(t1);free($13);$$=t2;} 
| RETURN {$$ = malloc(sizeof(char)*100);sprintf($$,"j restore\n");}
| VAR {addsym($1);} '[' x {count=0;} ']' '=' expr {$$ = update_arr($1,$4,$8);}
| '\n' {$$=malloc(sizeof(char)*2);strcpy($$,"\0");}
;
A : '\n' ELSE '{' stmts '}' {$$=malloc(sizeof(char)*(strlen($4)+100));sprintf($$,"%s\nIflabel%d :\n",$4,iflabel);iflabel+=1;}
| '\n' {$$ = malloc(sizeof(char)*100);sprintf($$,"\nIflabel%d :\n",iflabel);iflabel+=1;}
;
expr :  x   {count=0;sprintf($$,"%s\n",$1);}
| INPUT     {count=0;sprintf($$,"\nli $v0 5\nsyscall\nmove $t0 $v0\n");}
| x '+' x   {sprintf($$,"%s\n%s\nadd $t0 $t0 $t1\n",$1,$3);}
| x '*' x   {sprintf($$,"%s\n%s\nmul $t0 $t0 $t1\n",$1,$3);}
| x '/' x   {sprintf($$,"%s\n%s\ndiv $t0 $t0 $t1\n",$1,$3);}
| x '-' x   {sprintf($$,"%s\n%s\nsub $t0 $t0 $t1\n",$1,$3);}
| VAR '(' x {count=0;} ')' {sprintf($$,"%s\njal %s\n",$3,$1->name);}
| VAR {addsym($1);} '[' x {count=0;} ']' {sprintf($$,"%s\nmul $t0 $t0 4\nadd $t4 $t0 %d\nadd $sp $sp $t4\nlw $t0 ($sp)\nsub $sp $sp $t4\n",$4,$1->addr);}
;
x : VAR {addsym($1);sprintf($$,"lw $t%d, %d($sp)",count,$1->addr);count++,count=count%2;}
| NUM {sprintf($$,"li $t%d, %d",count,$1);count++;count=count%2;}
;

%%


int main()
{
    
    #if YYDEBUG == 1
    extern int yydebug;
    yydebug=1;
    #endif  
    lastpart = malloc(sizeof(char)*5);strcpy(lastpart," \n");
    yyparse();
}

void yyerror(char * s)
{
    printf("%s\n",s);
}


/*generates the code for while loop*/
char* build_while(struct symrec* ptr,char* x2, char* stmts)
{
    char* $$=malloc(sizeof(char)*(1000));
    sprintf($$,"\nLabel%d : \nlw $t3 %d($sp)\n%s\nbge $t3 $t0 Next%d\n %sj Label%d\n\nNext%d :",label,ptr->addr,x2,label,stmts,label,label);
    label+=1;
    free(stmts); //release the memory blocked by stmts inside loop
    return $$;
}

/*generates the code for for loop*/
char* build_for(struct symrec * ptr,char* a1,char* a2,char* stmts)
{
    char* $$1 = malloc(sizeof(char)*100);
    char* $$2 = malloc(sizeof(char)*(strlen(stmts)+200));
    sprintf($$1,"%s\nmove $t3 $t0\nsw $t3 %d($sp)",a1,ptr->addr);
    sprintf($$2,"\nLabel%d :\nlw $t3 %d($sp)\n%s\nbeq $t3 $t1 Next%d\n%slw $t3 %d($sp)\nadd $t3 $t3 1\nsw $t3 %d($sp)\nj Label%d\n\nNext%d :",label,ptr->addr,a2,label,stmts,ptr->addr,ptr->addr,label,label);
    char* $$ = malloc(sizeof(char)*(strlen(stmts)+200));
    strcat($$,$$1);
    strcat($$,$$2);
    label+=1;
    free($$1);
    free($$2);
    free(stmts);
    return $$;
}

/*generates the code for if statement*/
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

/* when a function definition is encountered while parsing, this function will decrement the stack pointer and store the return address parameter in the stack*/
char * init_func(struct symrec* ptr, struct symrec* var)
{
    char* $$ = malloc(sizeof(char)*1000); 
    sprintf($$,"%s:\nsub $sp, $sp, 20\nsw $ra, 0($sp)\nsw $t0, 4($sp)",ptr->name);
    return $$;
}

/* this function will generate the code inside the function */
char * build_func(char* code)
{
    char * $$ = malloc(sizeof(char)*(strlen(code)+200));
    strcat($$,code);
    strcat($$,"j restore\n");
    return $$;
}

/* this function merges the code for various functions and the main function into one code */
char * build_entire(char* funcs, char* main)
{
    char* temp = malloc(sizeof(char)*(strlen(funcs)+strlen(main)+strlen(lastpart)+200));
    sprintf(temp,".data\na : .word 0\n.text\n\nmain :\n    %sli $v0 , 10\nsyscall\n\n%s",main,funcs);
    strcat(temp,"restore:\n       lw $ra ,0($sp)\n       add $sp, $sp, 20\n       jr $ra\n");
    strcat(temp,lastpart);
    free(lastpart);
    return temp;
}

/* this function will change the value at particular location of array*/
char * update_arr(struct symrec * arr, char* x, char* y)
{
    char* $$ = malloc(sizeof(char)*(strlen(x)+strlen(y)+200));
    sprintf($$,"%s\nmove $t1 $t0\n%s\nmul $t0 $t0 4\nadd $t4 $t0 %d\nadd $sp $sp $t4\nsw $t1 ($sp)\nsub $sp $sp $t4\n",y,x,arr->addr);
    return $$;
}

/* whenever a symbol s is encountered while the parser was in some function f , if s.insde ==0, then the symbol is new, so it will be added to the symbol table
also its address will be updated to s.addr=offset and s.flag=1. So now while in f, if s is seen again, it can be fetched from a.addr, which is where s has been stored in stack of f*/
void addsym(struct symrec * var)
{
    if(var->inside == 0)
    {
        var->inside = 1;
        var->addr=offset;
        offset+=4;
        var->flag=1;
        var->next = symtable;
        symtable = var;
    }
    if(var->flag == 0){
        var->addr=offset;
        offset+=4;
        var->flag=1;
    }
}

/* everytime a new function defintion is seen, for all the variables present in the symboltable, their flag will be set to 0. So that when they are seen in the new function,
their addr will be updated to the correct offset wrt to the stack of this function*/
void swipetable()
{
    struct symrec * temp = symtable;
    while(temp!= NULL)
    {
        temp->flag = 0;
        temp=temp->next;
    }
}
