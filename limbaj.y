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
    int boolean;
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

%precedence OR AND
%precedence EQ NEQ
%precedence LT GT LTE GTE
%precedence PLUS MINUS
%precedence MULT DIV MOD
%precedence NOT

%%

program:
    class_section global_var_section function_section entry_point
    ;

class_section:
    class_section CLASS ID A_OPEN class_body A_CLOSE ';'
    { printf("Class declared: %s\n", $3); }
    | /* empty */
    ;

class_body:
    class_body class_member
    | class_member
    ;

class_member:
    type_declaration
    | function_declaration
    ;

global_var_section:
    global_var_section var_declaration
    | var_declaration
    ;

var_declaration:
    TYPE ID ';'                                  
    { printf("Global variable declared: %s\n", $2); }
    | TYPE ID ASSIGN expression ';'                   
    { printf("Global variable declared and assigned: %s = ...\n", $2); }
    | TYPE ID B_OPEN INTVAL B_CLOSE ';'               
    { printf("Global array declared: %s[%d]\n", $2, $4); }
    | TYPE ID B_OPEN INTVAL B_CLOSE ASSIGN expression ';' 
    { printf("Global array declared and assigned: %s[%d] = ...\n", $2, $4); }
    ;

function_section:
    function_section function_declaration
    | /* empty */
    ;

function_declaration:
    FUNC TYPE ID P_OPEN parameter_list P_CLOSE BGIN statement_list END
    { printf("Function declared: %s\n", $3); }
    ;

parameter_list:
    TYPE ID
    | parameter_list ',' TYPE ID
    | /* empty */
    ;

entry_point:
    FUNC VOID HEART P_OPEN P_CLOSE BGIN statement_list END
    { printf("Entry point executed\n"); }
    ;

statement_list:
    statement_list statement
    | statement
    ;

statement:
    assignment_statement
    | object_assignment
    | method_call
    | if_statement
    | while_statement
    | for_statement
    | return_statement
    | print_statement
    | expression ';'
    ;

type_declaration:
    TYPE ID ';'
    { printf("Type declared: %s %s\n", $1, $2); }
    | TYPE ID ASSIGN expression ';'
    { printf("Initialized variable: %s %s = ...\n", $1, $2); }
    | ID ID ';'
    ;

assignment_statement:
    ID ASSIGN expression ';'
    { printf("Assignment: %s = ...\n", $1); }
    | ID B_OPEN expression B_CLOSE ASSIGN expression ';'
    { printf("Array assignment: %s[...] = ...\n", $1); }
    ;

object_assignment:
    ID DOT ID ASSIGN expression ';'
    { printf("Object field assignment: %s.%s = ...\n", $1, $3); }
    ;

method_call:
    ID DOT ID P_OPEN argument_list P_CLOSE ';'
    { printf("Method call: %s.%s(...)\n", $1, $3); }
    ;

argument_list:
    expression
    | argument_list ',' expression
    | /* empty */
    ;

if_statement:
    IF P_OPEN boolean_expression P_CLOSE BGIN statement_list END
    { printf("If condition executed\n"); }
    | IF P_OPEN boolean_expression P_CLOSE BGIN statement_list END ELSE BGIN statement_list END
    { printf("If-Else condition executed\n"); }
    ;

while_statement:
    WHILE P_OPEN boolean_expression P_CLOSE BGIN statement_list END
    { printf("While loop executed\n"); }
    ;

for_statement:
    FOR P_OPEN assignment_statement boolean_expression ';' assignment_statement P_CLOSE BGIN statement_list END
    { printf("For loop executed\n"); }
    ;
return_statement:
    RETURN expression ';'
    { printf("Return statement executed\n"); }
    ;

print_statement:
    PRINT P_OPEN expression P_CLOSE ';'
    { printf("Print statement executed\n"); }
    ;

expression : expression PLUS expression
           | expression MINUS expression
           | expression MULT expression
           | expression DIV expression
           | expression MOD expression
           | ID
           | INTVAL
           | FLOATVAL
           | CHARVAL
           | STRINGVAL
           ;

boolean_expression  : expression GT expression
                    | expression LT expression
                    | expression GTE expression
                    | expression LTE expression
                    | expression EQL expression
                    | expression NEQ expression
                    | boolean_expression AND boolean_expression
                    | boolean_expression OR boolean_expression
                    | NOT boolean_expression
                    | BOOLVAL
                    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

int main() {
    return yyparse();
}
