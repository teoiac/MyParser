%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();
extern int yylineno;
void yyerror(const char *s);

%}

%union {
    char *string;
    int integer;
    float floater;
    char character;
}

%token <string> TYPE ID STRINGVAL
%token <character> CHARVAL
%token <integer> INTVAL BOOLVAL
%token <floater> FLOATVAL
%token ARRAY CLASS BGIN END IF ELSE WHILE FOR FUNC VOID RETURN PRINT TYPEOF HEART
%token ASSIGN EQL NEQ EQ MINUS PLUS MULT DIV MOD
%token P_OPEN P_CLOSE A_OPEN A_CLOSE B_OPEN B_CLOSE
%token INCREMENT DECREMENT GT GTE LT LTE AND OR NOT DOT

%start program

%%

program:
    declaration_list
;

declaration_list:
    declaration_list declaration
    | declaration
;

declaration:
    type_declaration
    | function_declaration
    | class_declaration
    | statement
;

type_declaration:
    TYPE ID ';'
    { printf("Type declaration: %s\n", $2); }
;

function_declaration:
    FUNC TYPE ID P_OPEN parameter_list P_CLOSE BGIN statement_list END
    { printf("Function declaration: %s\n", $3); }
;

parameter_list:
    TYPE ID
    | parameter_list ',' TYPE ID
    | /* empty */
;

class_declaration:
    CLASS ID A_OPEN class_body A_CLOSE
    { printf("Class declaration: %s\n", $2); }
;

class_body:
    class_body class_member
    | class_member
;

class_member:
    type_declaration
    | function_declaration
;

statement_list:
    statement_list statement
    | statement
;

statement:
    assignment_statement
    | if_statement
    | while_statement
    | for_statement
    | return_statement
    | print_statement
;

assignment_statement:
    ID ASSIGN expression ';'
    { printf("Assignment: %s\n", $1); }
;

if_statement:
    IF P_OPEN expression P_CLOSE BGIN statement_list END
    { printf("If statement\n"); }
;

while_statement:
    WHILE P_OPEN expression P_CLOSE BGIN statement_list END
    { printf("While loop\n"); }
;

for_statement:
    FOR P_OPEN assignment_statement expression ';' assignment_statement P_CLOSE BGIN statement_list END
    { printf("For loop\n"); }
;

return_statement:
    RETURN expression ';'
    { printf("Return statement\n"); }
;

print_statement:
    PRINT P_OPEN expression P_CLOSE ';'
    { printf("Print statement\n"); }
;

expression:
    INTVAL
    | FLOATVAL
    | STRINGVAL
    | BOOLVAL
    | ID
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

int main() {
    return yyparse();
}
