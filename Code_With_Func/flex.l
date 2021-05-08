%{
    #include "bison.tab.h"
    #include<stdio.h>
    #include<string.h>
    struct symrec
    {
        char* name;
        int addr;
        // int flag ;
        struct symrec * next;
    };
    struct symrec *putsym (char*,char*);
    struct symrec *getsym (char*);
    char* getname(char* x);
    struct symrec * sym_table = NULL;
    int Adr = 100;
%}

NUM          [0-9]+
VAR          [A-Za-z][A-Za-z0-9]*
MAIN         "def main()"
FUNC         "def "{VAR}

%%

[ ]             {}   
{MAIN}          {return MAIN;}
{FUNC}          {char* fname= getname(yytext);struct symrec *s= getsym(fname); if(s==0){s=putsym(fname,"FUNC");}yylval.ptr=s;return FUNC;}  /* put a symbol corresponding to the function name*/
{NUM}           {yylval.num = atoi(yytext); return NUM;}
{VAR}           {struct symrec *s= getsym(yytext);if(s==0){s=putsym(yytext,"VAR");}yylval.ptr=s; return VAR;}
\n|[{}();]|"+"|"-"|"*"|"/"|"="|"<"            {return yytext[0];}  


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

char* getname( char* x)
{
    char* a = malloc(sizeof(char)*20);
    int i = 4;
    int j = 0;
    while(i<strlen(x))
    {
        a[j] = x[i];
        i++;j++;
    }
    a[j] ='\0';
    return a;

}

struct symrec * putsym(char* name, char* typ)
{
    struct symrec *ptr;
    ptr = malloc(sizeof(struct symrec));

    ptr->next = sym_table;
    sym_table = ptr;

    ptr->name = malloc(sizeof(char)*(strlen(name)+1));
    strcpy(ptr->name,name);
    // if(strcmp(typ,"FUNC")==0)
    // {
    //     ptr->flag = 1;
    //     return ptr;
    // }
    ptr->addr = Adr;
    Adr += 4;
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
// {MAIN}                          {printf("MAIN: %s\n",yytext);}
// {FUNC}                          {char* x = getname(yytext);printf("%s\nFUNC: %s\n",x,yytext);}
// {NUM}                           {printf("NUM: %s\n",yytext);}
// {VAR}                           {printf("VAR: %s\n",yytext);}
// \n|[{}();]|"+"|"-"|"*"|"/"|"="|"<"      {printf("other: %s\n",yytext);}  

// [ ]             {}   
// {MAIN}          {return MAIN;}
// {FUNC}          {char* fname= getname(yytext);struct symrec *s= getsym(fname); if(s==0){s=putsym(yytext,"FUNC");}return FUNC;}  /* put a symbol corresponding to the function name*/
// {NUM}           {yylval.num = atoi(yytext); return NUM;}
// {VAR}           {struct symrec *s= getsym(yytext);if(s==0){s=putsym(yytext,"VAR");}yylval.ptr=s; return VAR;}
// \n|[{}();]|"+"|"-"|"*"|"/"|"="|"<"            {return yytext[0];}    
