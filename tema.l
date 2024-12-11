%{
#include <stdio.h>
#include "limbaj.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool" {yylval.string = strdup(yytext);return TYPE;} //duplicare caracter cu caracter cu strdup
"begin"     {return BGIN;}
"end"       {return END;}
"if"        {return IF;}
"else"      {return ELSE;}
""
[a-zA-Z][a-zA-Z0-9]* {yylval.string = strdup(yytext); return ID;}

":="        {return ASSIGN;}
"-"         {return MINUS;}
"+"         {return PLUS;}
"/"         {return DIV;}
"%"         {return MOD;}
"="         {return EGAL;}
"("         {return P_DESCHISA;}
")"         {return P_INCHISA;}
"++"        {return INCREMENTARE;}
""
[0-9]+      {return NR;}
[ \t] ;
\n          {yylineno++;}
.           {return yytext[0];}

 