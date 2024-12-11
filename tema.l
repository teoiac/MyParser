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
"while"     {return WHILE;}
"for"       {return FOR;}

":="        {return ASSIGN;}
"=="        {return EQL;}
"!="        {return NEQ;}

"-"         {return MINUS;}
"+"         {return PLUS;}
"*"         {return MULT;}
"/"         {return DIV;}
"%"         {return MOD;}

"("         {return P_OPEN;}
")"         {return P_CLOSE;}
"{"         {return A_OPEN;}
"}"         {return A_CLOSE;}
"["         {return B_OPEN;}
"]"         {return B_CLOSE;}
"++"        {return INCREMENT;}
"--"        {return DECREMENT;}
">"         {return GT;}
">="        {return GTE}
"<"         {return LT;}
"<="        {return LTE;}
"&&"        {return AND;}
"||"        {return OR;}
"!"         {return NOT;}
"."         {return DOT;}

"true"      { yylval.integer = 1; return BOOLVAL;}
"false"     { yylval.integer = 0; return BOOLVAL;}

"<3"        {return HEART;}

[a-zA-Z][a-zA-Z0-9]*    {yylval.string = strdup(yytext); return ID;}
[1-9][0-9]*             {yylval.integer = atoi(yytext); return INTVAL;} 
[1-9][0-9]*\.[0-9]+     {yylval.floater = atof(yytext); return FLOATVAL;}
0\.[0-9]+               {yylval.floater = atof(yytext); return FLOATVAL;}
\"[^\"]*\"              {yylval.string = strdup(yytext);return STRINGVAL;}
\'[^\']\'               {yylval.character = strdup(yytext);return CHARVAL;}

[ \t] ;
\n          {yylineno++;}
.           {return yytext[0];}
%%
 
