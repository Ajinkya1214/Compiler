%{
    #include "bison.tab.h"
    #include<stdio.h>
    #include<string.h>
    struct symrec
    {
        char* name;
        int addr;
        struct symrec * next;
    };
    struct symrec *putsym (char*,char*);
    struct symrec *getsym (char*);
    struct symrec * sym_table = NULL;
    int Adr = 100;
%}

NUM          [0-9]+
VAR          [A-Za-z][A-Za-z0-9]*
ARR          "decl"([ ]){VAR}"["{NUM}"]"";"


%%

[ ]             {}
"while"         {return WHILE;}
"startdecl"     {return STARTDECL;}
"enddecl"       {return ENDDECL;}
{NUM}           {yylval.num = atoi(yytext); return NUM;}
{VAR}           {struct symrec *s= getsym(yytext);if(s==0){s=putsym(yytext,"VAR");}yylval.ptr=s; return VAR;}
{ARR}           {struct symrec *s=putsym(yytext,"ARR");yylval.ptr=s;return ARR;}
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

struct symrec * putsym(char* name, char* typ)
{
    if(strcmp(typ,"ARR")==0)
    {
        char name2[100];
        int i = 5; 
        while(yytext[i]!='[')
        {
            name2[i-5]=yytext[i];
            i+=1;
        }
        name2[i-5]='\0';
        i+=1;
        char sz[100];
        int j =0 ;
        while(yytext[i]!=']')
        {
            sz[j]=yytext[i];
            i++;
            j++;
        }
        int siz = atoi(sz);
        struct symrec *ptr;
        ptr = malloc(sizeof(struct symrec));
        ptr->name = malloc(sizeof(char)*(strlen(name2)+1));
        strcpy(ptr->name,name2);
        // printf("%s\n",name2);
        ptr->addr = Adr;
        Adr += siz*4;
        ptr->next = sym_table;
        sym_table = ptr;
        return ptr;
    }

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

// [ ]             {}
// "while"         {return WHILE;}
// "startdecl"     {return STARTDECL;}
// "enddecl"       {return ENDDECL;}
// {NUM}           {yylval.num = atoi(yytext); return NUM;}
// {VAR}           {struct symrec *s= getsym(yytext,"VAR");if(s==0){s=putsym(yytext,"VAR");}yylval.ptr=s; return VAR;}
// {ARR}           {struct symrec *s = getsym(yytext,"ARR"); if(s==0){s=putsym(yytext,"ARR");}yylval.ptr=s;return ARR;}
// \n|.            {return yytext[0];}