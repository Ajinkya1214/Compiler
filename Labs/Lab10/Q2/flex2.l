%{
    #include "bison2.tab.h"
    #include<stdio.h>
    #include<string.h>
    struct symrec
    {
        char* name;
        int addr;
        struct symrec * next;
    };
    struct symrec *putsym (char*);
    struct symrec *getsym (char*);
    struct symrec * sym_table = NULL;
    int Adr = 100;
%}

keywords    "while"
NUM          [0-9]+
VAR          [A-Za-z][A-Za-z0-9]*


%%

[ ]             {}
{keywords}      {return WHILE;}
{NUM}           {yylval.num = atoi(yytext); return NUM;}
{VAR}           {struct symrec *s= getsym(yytext);if(s==0){s=putsym(yytext);}yylval.ptr=s; return VAR;}
\n|.            {return yytext[0];}


%%


// int main(int argc, char ** argv)
// {
//     argv++; argc--;
//     if (argc > 0)
//     {
//         yyin = fopen(argv[0],"r");
//     }
//     else
//     {
//         yyin = stdin;
//     }
//     yylex();
//     return 0;
// }

// int yywrap()
// {
//     return 0;
// }

struct symrec * putsym(char* name)
{
    struct symrec *ptr;
    ptr = malloc(sizeof(struct symrec));
    ptr->name = malloc(sizeof(char)*(strlen(name)+1));
    strcpy(ptr->name,name);
    ptr->addr = Adr;
    Adr += 4;
    ptr->next = sym_table;
    sym_table = ptr;
    return ptr;
}

struct symrec * getsym(char* name)
{
    struct symrec *temp = sym_table;
    while(temp!=NULL)
    {
        if(strcmp(temp->name,name)==0)return temp;
        temp = temp->next;
    }
    return 0;
}




// [ ]             {}
// {keywords}      {printf("keywords: %s\n",yytext);}
// {NUM}           {printf("NUM: %s\n",yytext);}
// {VAR}           {printf("VAR: %s\n",yytext);}
// \n|.            {printf("other: %c\n",yytext[0]);} 