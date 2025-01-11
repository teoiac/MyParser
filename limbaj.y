%{
#include <iostream>
#include "SymTable.h"
extern int yylex();
extern int yylineno;
void yyerror(const char *s);

SymTable* currentSymTable = nullptr; // Pointer to the current symbol table
SymTable* globalSymTable = nullptr;  // Pointer to the global symbol table
%}

%union {
    char* string;
    int integer;
    float floater;
    char character;
    int boolean;
}

%token <string> TYPE ID STRINGVAL
%token <character> CHARVAL
%token <integer> INTVAL BOOLVAL
%token <floater> FLOATVAL
%token ARRAY CLASS BGIN END IF ELSE WHILE STOP FOR FUNC VOID RETURN PRINT TYPEOF HEART
%token ASSIGN EQL NEQ  MINUS PLUS MULT DIV MOD
%token P_OPEN P_CLOSE A_OPEN A_CLOSE B_OPEN B_CLOSE
%token INCREMENT DECREMENT GT GTE LT LTE AND OR NOT DOT

%start program

         

%left OR
%left AND
%left EQL NEQ
%left LT LTE GT GTE  
%left PLUS MINUS
%left MULT DIV MOD
%left NOT
%left A_OPEN A_CLOSE B_OPEN B_CLOSE P_OPEN P_CLOSE


%%

program:
    class_section global_var_section function_section entry_point
    ;

class_section:
    class_section CLASS ID A_OPEN class_body A_CLOSE ';'
    {
        if (globalSymTable->existsVar($3)) {
            yyerror("Class already declared in the global scope");
        } else {
            // Add class to global scope
            globalSymTable->addVar("class", $3, "");

            // Create a new symbol table for the class scope
            SymTable* classSymTable = new SymTable($3, globalSymTable);
            currentSymTable = classSymTable; // Switch to class scope

            printf("Class declared: %s\n", $3);
        }
    }
    | /* empty */
    ;
constructor_declaration :
    ID P_OPEN P_CLOSE A_OPEN statement_list A_CLOSE ';'
    {printf("Constructor OKAY\n");}
    |ID P_OPEN parameter_list P_CLOSE A_OPEN statement_list A_CLOSE ';'
    {printf("Constructor OKAY\n");}
    ;
class_body:
    class_body class_member
    |class_member
    ;
class_member:
    class_var_declaration
    | function_declaration
    | constructor_declaration
    ;

class_var_declaration:
    TYPE ID ';'
    { printf("Class variable declared: %s\n", $2); }
    | ARRAY TYPE ID n_dimensional_array ';'
    { printf("Class array declared\n"); }
    | TYPE assignment_statement
    {
        printf("Class variable declared and assigned\n");
    }
    ;

global_var_section:
    var_declaration_list
    |/*empty*/
    ;
var_declaration_list : 
    var_declaration_list var_declaration
    |var_declaration;

n_dimensional_array:
    n_dimensional_array B_OPEN INTVAL B_CLOSE
    |B_OPEN INTVAL B_CLOSE
    |n_dimensional_array B_OPEN B_CLOSE
    |B_OPEN B_CLOSE
    ;
var_declaration:
    TYPE ID ';'
    { 
        if (currentSymTable->existsVar($2)) {
            yyerror("Variable already declared in this scope");
        } else {
            currentSymTable->addVar($1, $2, "");
            printf("Global variable declared: %s\n", $2);
        }
    }
    
    | ARRAY TYPE ID n_dimensional_array ';'
    { if (currentSymTable->existsVar($3)) {
            yyerror("Array already declared in this scope");
        } else {
            currentSymTable->addVar($2, $3, ""); // Add array with base type
            printf("Global array declared\n");
        } 
    }
    
    | ID ID ';'  // For class object declarations
    { printf("Class object declared: %s -> %s\n", $1, $2); }

    | ID assignment_statement
    { printf("Class object declared and assigned\n"); }
    
    | TYPE assignment_statement
    { printf("Variable declared and assigned\n"); }
    ;


function_section:
    function_section function_declaration
    | /* empty */
    ;

function_declaration:
    FUNC TYPE ID P_OPEN parameter_list P_CLOSE A_OPEN statement_list A_CLOSE
    {
        if (currentSymTable->existsVar($3)) {
            yyerror("Function already declared in this scope");
        } else {
            // Add function to current symbol table
            FunctionInfo funcInfo = { $3, $2, "GLOBAL", false, "" }; // Set function details
            currentSymTable->addFunction(funcInfo);

            // Create a new symbol table for the function scope
            SymTable* functionSymTable = new SymTable($3, currentSymTable);
            currentSymTable = functionSymTable; // Switch to function scope

            printf("Function declared: %s\n", $3);
        }
    }
    ;
parameter_list:
    TYPE ID
    | parameter_list ',' TYPE ID
    ;

//main function
entry_point:
    FUNC VOID HEART P_OPEN P_CLOSE BGIN statement_list END
    { printf("Entry point executed\n"); }
    |FUNC VOID HEART P_OPEN P_CLOSE BGIN END
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
    | field_access
    | if_statement
    | while_statement
    | for_statement
    | return_statement
    | print_statement
    | typeof_statement
    | expression ';'
    | var_declaration
    |prefix_incr_decre ';'
    |postfix_incr_decre ';'   
    ;


assignment_statement:
    ID ASSIGN expression ';'
    { printf("Assignment: %s = ...\n", $1); }
    | ID n_dimensional_array ASSIGN expression ';'
    { printf("Array assignment: %s[...] = ...\n", $1); }
    | ID ASSIGN method_call
    {printf("Assign method call - object\n");}
    ;

object_assignment:
    ID DOT ID ASSIGN expression ';'
    { printf("Object field assignment: %s.%s = ...\n", $1, $3); }
    ;

method_call:
    ID DOT ID P_OPEN argument_list P_CLOSE ';'
    { printf("Method call: %s.%s(...)\n", $1, $3); }
    ;
field_access:
    ID DOT ID ';'
    {
        printf("Class member accessed\n");
    }
    ;

argument_list:
    expression
    | argument_list ',' expression
    | /* empty */
    ;

if_statement:
    IF P_OPEN boolean_expression P_CLOSE A_OPEN
    {
        // Create a new symbol table for the block scope
        SymTable* ifSymTable = new SymTable("if", currentSymTable);
        currentSymTable = ifSymTable; // Switch to block scope
    }
    statement_list
    A_CLOSE
    {
        // Exit block scope
        currentSymTable = currentSymTable->parent;
        printf("If condition executed\n");
    }
    | IF P_OPEN boolean_expression P_CLOSE A_OPEN statement_list A_CLOSE ELSE A_OPEN statement_list A_CLOSE
    { printf("If-Else condition executed\n"); }
    ;
//un fel de break pt loop
stop_statement:
    STOP
    {printf("Exit while loop\n");}
    ;

while_statement:
    WHILE P_OPEN boolean_expression P_CLOSE BGIN 
    {
         SymTable* whileSymTable = new SymTable("while", currentSymTable);
        currentSymTable = whileSymTable; // Switch to block scope
    }
    statement_list END
    { 
        currentSymTable = currentSymTable->parent;
        printf("While loop executed\n"); }
    ;
prefix_incr_decre:
    ID INCREMENT
    |ID DECREMENT
    ;
postfix_incr_decre:
    INCREMENT ID
    |DECREMENT ID
    ;

for_statement:
    FOR P_OPEN assignment_statement boolean_expression ';' prefix_incr_decre P_CLOSE BGIN statement_list END
    {
        // Create a new symbol table for the block scope inside the 'for' loop
        SymTable* forSymTable = new SymTable("for", currentSymTable);
        currentSymTable = forSymTable; // Switch to the block scope

        // Execute the statements inside the 'for' loop
        printf("For loop executed\n");

        // Exit the block scope after the loop
        currentSymTable = currentSymTable->parent;
    }
    | FOR P_OPEN assignment_statement boolean_expression ';' postfix_incr_decre P_CLOSE BGIN statement_list END
    {
        // Create a new symbol table for the block scope inside the 'for' loop
        SymTable* blockSymTable = new SymTable("block", currentSymTable);
        currentSymTable = blockSymTable; // Switch to the block scope

        // Execute the statements inside the 'for' loop
        printf("For loop executed\n");

        // Exit the block scope after the loop
        currentSymTable = currentSymTable->parent;
    }
    | FOR P_OPEN assignment_statement boolean_expression ';' ID ASSIGN expression P_CLOSE BGIN statement_list END
    {
        // Create a new symbol table for the block scope inside the 'for' loop
        SymTable* blockSymTable = new SymTable("block", currentSymTable);
        currentSymTable = blockSymTable; // Switch to the block scope

        // Execute the statements inside the 'for' loop
        printf("For loop executed\n");

        // Exit the block scope after the loop
        currentSymTable = currentSymTable->parent;
    }
    ;

return_statement:
    RETURN expression ';'
    { printf("Return statement executed\n"); }
    ;

print_statement:
    PRINT P_OPEN expression P_CLOSE ';'
    { printf("Print statement executed\n"); }
    ;

typeof_statement:
    TYPEOF P_OPEN expression P_CLOSE ';'
    {
        printf("TYPEOF Statement executed\n");
    }
    ;

// expresii aritmetice
expression:
     expression PLUS expression
    | expression MINUS expression 
    | expression MULT expression
    | expression DIV expression
    | expression MOD expression
   // | expression AND expression
   // | expression OR expression
    //| NOT expression
    | P_OPEN expression P_CLOSE
    | ID
   // | ID B_OPEN expression B_CLOSE
    | INTVAL
    | FLOATVAL
    | STRINGVAL
    | BOOLVAL
    | CHARVAL
    | stop_statement
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
    globalSymTable = new SymTable("global", nullptr); // Initialize the global symbol table
    currentSymTable = globalSymTable;       
    if (yyparse() == 0) {
        globalSymTable->printTableToFile("symbol_table.txt");
    }
    delete globalSymTable; // Cleanup
    return 0;
}
