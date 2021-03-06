%{
    #include "bison.tab.h"
    #include "table.h"
    #include<stdio.h>
    #include<string.h>
    
%}

NUM          [0-9]+
VAR          [A-Za-z][A-Za-z0-9]*
MAIN         "def main()"
FUNC         "def "{VAR}

%%


[ ]             {}  
"while"         {return WHILE;}
"for"           {return FOR;}
"if"            {return IF;}
"else"          {return ELSE;}    
"int"           {return INT;}   
"print"         {return PRINT;}
"return"        {return RETURN;}  
"startdecl"     {return STARTDECL;}
"enddecl"       {return ENDDECL;}
"decl"          {return DECL;}
{MAIN}          {return MAIN;}
{FUNC}          {char* fname= getname(yytext);struct symrec *s= getsym(fname); if(s==0){s=putsym(fname,"FUNC");}yylval.ptr=s;return FUNC;}  /* put a symbol corresponding to the function name*/
{NUM}           {yylval.num = atoi(yytext); return NUM;}
{VAR}           {struct symrec *s= getsym(yytext);if(s==0){s=putsym(yytext,"VAR");}yylval.ptr=s; return VAR;}
\n|[{}();]|"+"|"-"|"*"|"/"|"="|"<"|"["|"]"            {return yytext[0];}  



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




// [ ]                             {}
// "while"                         {printf("WHILE: %s\n",yytext);}
// "for"                           {printf("FOR: %s\n",yytext);}
// "if"                            {printf("IF: %s\n",yytext);}
// "else"                          {printf("ELSE: %s\n",yytext);}    
// "int"                           {printf("INT: %s\n",yytext);}   
// "print"                         {printf("PRINT: %s\n",yytext);}
// "return"                        {printf("RETURN: %s\n",yytext);}  
// "startdecl"                     {printf("STARTDECL: %s\n",yytext);}
// "enddecl"                       {printf("ENDDECL: %s\n",yytext);}
// "decl"                          {printf("DECL: %s\n",yytext);}
// {MAIN}                          {printf("MAIN: %s\n",yytext);}
// {FUNC}                          {char* x = getname(yytext);printf("%s\nFUNC: %s\n",x,yytext);}
// {NUM}                           {printf("NUM: %s\n",yytext);}
// {VAR}                           {printf("VAR: %s\n",yytext);}
// \n|[{}();]|"+"|"-"|"*"|"/"|"="|"<"|"["|"]"      {printf("other: %s\n",yytext);}  

// [ ]             {}  
// "while"         {return WHILE;}
// "for"           {return FOR;}
// "if"            {return IF;}
// "else"          {return ELSE;}    
// "int"           {return INT;}   
// "print"         {return PRINT;}
// "return"        {return RETURN;}  
// "startdecl"     {return STARTDECL;}
// "enddecl"       {return ENDDECL;}
// "decl"          {return DECL;}
// {MAIN}          {return MAIN;}
// {FUNC}          {char* fname= getname(yytext);struct symrec *s= getsym(fname); if(s==0){s=putsym(fname,"FUNC");}yylval.ptr=s;return FUNC;}  /* put a symbol corresponding to the function name*/
// {NUM}           {yylval.num = atoi(yytext); return NUM;}
// {VAR}           {struct symrec *s= getsym(yytext);if(s==0){s=putsym(yytext,"VAR");}yylval.ptr=s; return VAR;}
// \n|[{}();]|"+"|"-"|"*"|"/"|"="|"<"|"["|"]"            {return yytext[0];}  
