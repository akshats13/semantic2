%{
#include "y.tab.h"
int yylex();
void yyerror(char *s);
%}
%%
"void"                      {return VOID;}
"int argc, char *argv"      {return ARGCS;}
"include"                   {return INCLUDE;}
"int"                       {return INT;}
"float"                     {return FLOAT;}
"char"                      {return CHAR;}
"main"                      {return MAIN;}
[_a-zA-Z][_a-zA-Z0-9]*      {yylval.c = yytext; return id;}
[0-9]+                      {yylval.c = yytext; return numeric;}
[-+]?[0-9]*\.?[0-9]+        {yylval.c = yytext; return floating;}
[ \t]                       {ECHO;}
[\b]                        {;}
[-+*/%=#<>.{}();]           {return yytext[0];}
[']                         {return QUOTE;}
.                           {ECHO;}
%%
int yywrap() {return 1;}
