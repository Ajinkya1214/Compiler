%{
    #include "bison.tab.h"
    #include<stdlib.h>
    #include<string.h>
    int Adr = 100;
    struct symrec
    {
        char * name;
        int addr;
        struct symrec* next;
    };
    struct symrec* sym_table = NULL;
    struct symrec *putsym ();
    struct symrec *getsym ();

%}

/* regular definition*/
NUM         [0-9]+
VAR         [A-Za-z][A-Za-z0-9]*


%%
    /* pattern action pairs  */
[ ]         {}
{NUM}       {yylval.num = atoi(yytext);return NUM;}
{VAR}       {struct symrec *s; s=getsym(yytext);if(s==0){s = putsym(yytext,VAR);}yylval.ptr = s;return VAR;}
\n|.        {return yytext[0];}

%%

/* the symbol table, a linked list of symbol table records (symrec) */

struct symrec* putsym(char* name, char* typ)
{
    struct symrec* ptr;
    ptr = malloc(sizeof(struct symrec));
    ptr->name = malloc(sizeof(char)*(strlen(name)+1));
    strcpy(ptr->name,name);
    ptr->addr = Adr;
    Adr += 4;
    ptr->next = (struct symrec*)sym_table;
    sym_table = ptr;
    return ptr;
}

struct symrec* getsym(char* name)
{
    struct symrec * temp = sym_table;
    while(temp!=NULL)
    {
        if(strcmp(temp->name,name)==0)return temp;
        temp = temp->next;
    }
    return 0;
}
