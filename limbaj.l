%{
#include "ASTNode.h"
#include "SymTable.h"
#include "limbaj.tab.h"
#include <iostream>
%}

%option noyywrap
%option noinput nounput



%%
"int"|"float"|"char"|"string"|"bool" {yylval.string= strdup(yytext); return TYPE;}
"array"     {return ARRAY;}
"class"     {return CLASS;}
"begin"     {return BGIN;}
"end"       {return END;}
"if"        {return IF;}
"else"      {return ELSE;}
"while"     {return WHILE;}
"for"       {return FOR;}
"func"      {return FUNC;}
"void"      {return VOID;}
"return"    {return RETURN;}
"Print"     {return PRINT;}
"TypeOf"    {return TYPEOF;}
":="        {return ASSIGN;}
"=="        {return EQL;}
"!="        {return NEQ;}
"-"         {return MINUS;}
"+"         {return PLUS;}
"*"         {return MULT;}
"/"         {return DIV;}
"^"         {return POW;}

"("         {return P_OPEN;}
")"         {return P_CLOSE;}
"{"         {return A_OPEN;}
"}"         {return A_CLOSE;}
"["         {return B_OPEN;}
"]"         {return B_CLOSE;}
"++"        {return INCREMENT;}
"--"        {return DECREMENT;}
">"         {return GT;}
">="        {return GTE;}
"<"         {return LT;}
"<="        {return LTE;}
"&&"        {return AND;}
"||"        {return OR;}
"!"         {return NOT;}
"."         {return DOT;}

"true"      { yylval.integer = 1; return BOOLVAL;}
"false"     { yylval.integer = 0; return BOOLVAL;}

"main"        {return HEART;}

[a-zA-Z_][a-zA-Z0-9_]*  {yylval.string = strdup(yytext); return ID;}
[0-9]+                  {yylval.integer = atoi(yytext); return INTVAL;} 
[0-9]*\.[0-9]+          {yylval.floater = atof(yytext); return FLOATVAL;}
\"[^\"]*\"              {yylval.string = strdup(yytext); return STRINGVAL;}
\'([^\\\'])\'           { yylval.character = yytext[1]; return CHARVAL; }

[ \t]                   ;
\n                      {yylineno++;}
.                       {return yytext[0];}
%%
