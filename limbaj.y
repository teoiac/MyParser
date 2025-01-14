%{
#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include "ASTNode.h"
#include "SymTable.h"


using namespace std;

extern int yylex();
extern int yydebug;
extern int yylineno;
void yyerror(const char *s);

// Pointer to the current symbol table
SymTable* globalSymTable = new SymTable("global", nullptr, "global"); 
SymTable* currentSymTable = globalSymTable;  // Pointer to the global symbol table

std::vector<ParamInfo> globalParamList;    // Stores all function parameters
std::vector<StatementInfo> globalStatements; // Stores statements

class ASTNode ast;


struct param_list {
    // Add fields as needed
    char* name;
    struct param_list* next;
};



bool isInteger(const std::string& str) {
    try {
        std::stoi(str);
        return true;
    } catch (const std::invalid_argument& ia) {
        return false;
    } catch (const std::out_of_range& oor) {
        return false;
    }
}

bool isFloat(const std::string& str) {
    try {
        std::stof(str);
        return true;
    } catch (const std::invalid_argument& ia) {
        return false;
    } catch (const std::out_of_range& oor) {
        return false;
    }
}

bool isBoolean(const std::string& str) {
    return (str == "true" || str == "false");
}
%}

%union {
    char* string;
    int integer;
    float floater;
    char character;
    int boolean;
    void* pointer; // Generic pointer for custom structures
    struct param_list* param_list;
    struct Node *nod;
    //ASTNode* astNode;
}


%token <string> TYPE ID STRINGVAL
%token <character> CHARVAL
%token <integer> INTVAL BOOLVAL
%token <floater> FLOATVAL
%token ARRAY CLASS BGIN END IF ELSE WHILE  FOR FUNC VOID RETURN PRINT TYPEOF HEART
%token ASSIGN EQL NEQ  MINUS PLUS MULT DIV POW
%token P_OPEN P_CLOSE A_OPEN A_CLOSE B_OPEN B_CLOSE
%token INCREMENT DECREMENT GT GTE LT LTE AND OR NOT DOT

%type <param_list> parameter_list
%type <nod> expression print_statement
%type <nod> boolean_expression
%start program


%left OR
%left AND
%left EQL NEQ
%left LT LTE GT GTE  
%left PLUS MINUS
%left MULT DIV POW
%left NOT
%left A_OPEN A_CLOSE B_OPEN B_CLOSE P_OPEN P_CLOSE


%%

program:
    class_section global_var_section function_section entry_point
    {
         globalSymTable->printTableToFile("complete_symbol_table.txt", true);
    }
    ;

class_section:
    CLASS ID A_OPEN 
    {
        if (globalSymTable->existsVar($2)) {
            yyerror("Class already declared in this scope");
        } else {
            globalSymTable->addClass($2);
            SymTable* classScope = new SymTable($2, globalSymTable, "class");
            currentSymTable = classScope;
        }
    }
    class_body A_CLOSE ';'
    {
        currentSymTable->printTableToFile("symbol_table.txt", true);
        SymTable* oldScope = currentSymTable;
        currentSymTable = currentSymTable->getParent();
        delete oldScope;
    }
    |
    ;
constructor_declaration :
    ID P_OPEN P_CLOSE A_OPEN statement_list A_CLOSE ';'
    {printf("Constructor OKAY\n");}
    |ID P_OPEN parameter_list P_CLOSE A_OPEN statement_list A_CLOSE ';'
    {printf("Constructor OKAY\n");}
    ;
class_body:
    class_body class_member
    | /* empty */  // Permite corp gol
    ;
class_member:
    class_var_declaration
    | function_declaration
    | constructor_declaration
    ;

class_var_declaration:
    TYPE ID ';'
    {  if (currentSymTable->existsVar($2)) {
            yyerror("Variable already declared in this scope");
        } else {
            currentSymTable->addVar($1, $2, "");
             printf("Class variable declared: %s\n", $2); }
    }
    | ARRAY TYPE ID n_dimensional_array ';'
    { 
        if(currentSymTable->existsVar($2))
        {
            yyerror("Variable already declared in this scope");
        } else {
            currentSymTable->addVar("array", $3, "");
             printf("Class array declared\n"); }
        }
       
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
     | TYPE ID ASSIGN expression ';'
    {
        currentSymTable->addVar($1, $2, "expresie");
        printf("Global variable declared: %s with starting value: %s\n", $2, "expresie");
    } 
    | ARRAY TYPE ID n_dimensional_array ';'
    { if (currentSymTable->existsVar($3)) {
            yyerror("Array already declared in this scope");
        } else {
            currentSymTable->addVar("ARRAY", $3, ""); // Add array with base type
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
    FUNC TYPE ID P_OPEN parameter_list P_CLOSE A_OPEN 
    {
        if (currentSymTable->existsVar($3)) {
            yyerror("Function already declared in this scope");
        } else {
            // Collect parameters from globalParamList
            FunctionInfo funcInfo = { $3, $2, currentSymTable->name, false, "", globalParamList };
            currentSymTable->addFunction(funcInfo);

            // Clear globalParamList after usage
            globalParamList.clear();

            // Create a new scope for the function
            SymTable* funcScope = new SymTable($3, currentSymTable, "function");
            currentSymTable = funcScope;

            for(const auto& param : funcInfo.parameters){
                currentSymTable->addVar(param.type, param.name);
            }
        }
    }
    statement_list A_CLOSE
    {
        currentSymTable->printTableToFile("function_symbol_table.txt", true);
        SymTable* oldScope = currentSymTable;
        currentSymTable = currentSymTable->getParent();
        delete oldScope;
    }
    ;

parameter_list:
    TYPE ID
    {
        ParamInfo param = { $1, $2 };       // Create parameter
        globalParamList.push_back(param);  // Add parameter to global list
    }
    | parameter_list ',' TYPE ID
    {
        ParamInfo param = { $3, $4 };      // Create parameter
        globalParamList.push_back(param);  // Add parameter to global list
    }
    ;

//main function
entry_point:
    FUNC VOID HEART P_OPEN P_CLOSE BGIN statement_list END
    { printf("Entry point executed\n"); }
    

statement_list:
    statement_list statement
    { printf("STATEMENT ADAUGAT LA LISTA\n"); }
    |statement
    { printf("Single statement added\n"); }
   ;


statement:
    if_statement
    | while_statement
    | for_statement
    | assignment_statement
    | object_assignment
    | method_call
    | field_access
    | return_statement
    | print_statement
    | typeof_statement
    | expression ';'
    | var_declaration
    | prefix_incr_decre ';'
    | postfix_incr_decre ';'
;



assignment_statement:
    ID ASSIGN STRINGVAL ';'
    {
         if (!currentSymTable->existsVar($1)) {
        string error = "Variable '" + string($1) + "' used without declaration";
        yyerror(error.c_str());
    }
        currentSymTable->addValue($1, $3);
        printf("Assignment: %s = ...\n", $1); 
    }
    |ID ASSIGN INTVAL ';'
    {
         if (!currentSymTable->existsVar($1)) {
        string error = "Variable '" + string($1) + "' used without declaration";
        yyerror(error.c_str());
    }
        currentSymTable->addValue($1, to_string($3));
    }
    |ID ASSIGN FLOATVAL ';'
    {
         if (!currentSymTable->existsVar($1)) {
        string error = "Variable '" + string($1) + "' used without declaration";
        yyerror(error.c_str());
    }
        currentSymTable->addValue($1, to_string($3));
    }
    |ID ASSIGN CHARVAL ';'
    {
         if (!currentSymTable->existsVar($1)) {
        string error = "Variable '" + string($1) + "' used without declaration";
        yyerror(error.c_str());
    }
        currentSymTable->addValue($1, to_string($3));
        printf("ASIGNARE CU CHAR\n");
    }
    | ID n_dimensional_array ASSIGN expression ';'
    {  if (!currentSymTable->existsVar($1)) {
        string error = "Variable '" + string($1) + "' used without declaration";
        yyerror(error.c_str());
    }
        printf("Array assignment: %s[...] = ...\n", $1); }
    | ID ASSIGN method_call
    { if (!currentSymTable->existsVar($1)) {
        string error = "Variable '" + string($1) + "' used without declaration";
        yyerror(error.c_str());
    }
        printf("Assign method call - object\n");}
    ;

object_assignment:
    ID DOT ID ASSIGN expression ';'
    { printf("Object field assignment: %s.%s = ...\n", $1, $3); }
    ;

method_call:
    ID P_OPEN argument_list P_CLOSE ';'
    {
        // Verificăm dacă funcția există
        if (!currentSymTable->existsFunction($1)) {
            string error = "Function '" + string($1) + "' not declared in this scope";
            yyerror(error.c_str());
        } else {
            // Obținem informațiile funcției
            FunctionInfo funcInfo = currentSymTable->getFunctionInfo($1);

            // Verificăm dacă numărul de parametri corespunde
            if (funcInfo.parameters.size() != globalParamList.size()) {
                string error = "Incorrect number of arguments for function '" + string($1) + "'";
                yyerror(error.c_str());
            } else {
                // Verificăm dacă tipurile parametrilor corespund
                for (size_t i = 0; i < globalParamList.size(); ++i) {
                    if (funcInfo.parameters[i].type != globalParamList[i].type) {
                        string error = "Type mismatch for parameter " + to_string(i + 1) +
                                       " in function '" + string($1) + "'";
                        yyerror(error.c_str());
                    }
                }
            }

           
            globalParamList.clear();

            printf("Function '%s' called successfully\n", $1);
        }
    }
    ;

field_access:
    ID DOT ID ';'
    {
        printf("Class member accessed\n");
    }
    ;

argument_list:
    expression
    {
        // Adăugăm tipul expresiei în lista globală de parametri
        ParamInfo param;
        param.type = $1->type; // Setăm tipul
        param.name = "";      // Numele nu este necesar pentru apel
        globalParamList.push_back(param);
    }
    | argument_list ',' expression
    {
        ParamInfo param;
        param.type = $3->type; // Setăm tipul
        param.name = "";      // Numele nu este necesar pentru apel
        globalParamList.push_back(param);
    }
    | /* empty */
    ;

if_statement:
    IF P_OPEN boolean_expression P_CLOSE A_OPEN statement_list 
    {
        // Enter a new scope for the IF block
        SymTable* ifScope = new SymTable("if_block", currentSymTable, "block-if");
        printf("Entering scope: if_block at line %d\n", yylineno);
        currentSymTable = ifScope;
    }
    '#'
    {
        // Exit the IF block scope
        currentSymTable->printTableToFile("symbol_table.txt", true);
        SymTable* oldScope = currentSymTable;
        currentSymTable = currentSymTable->getParent();
        delete oldScope;
        printf("If block parsed and scope exited at line %d\n", yylineno);
    }
    | IF P_OPEN boolean_expression P_CLOSE A_OPEN statement_list 
    {
        // Enter a new scope for the IF block
        SymTable* ifScope = new SymTable("if_block", currentSymTable, "block-if");
        printf("Entering scope: if_block at line %d\n", yylineno);
        currentSymTable = ifScope;
    }
    A_CLOSE ELSE A_OPEN statement_list A_CLOSE
    {
        // Exit the IF block scope
        currentSymTable->printTableToFile("symbol_table.txt", true);

        // Create and manage a new scope for the ELSE block
        SymTable* elseScope = new SymTable("else_block", currentSymTable, "block-else");
        printf("Entering scope: else_block at line %d\n", yylineno);
        currentSymTable = elseScope;

        // Exit the ELSE block scope
        currentSymTable->printTableToFile("symbol_table.txt", true);
        SymTable* oldScope = currentSymTable;
        currentSymTable = currentSymTable->getParent();
        delete oldScope;
        printf("Else block parsed and scope exited at line %d\n", yylineno);
    }
    ;

while_statement:
    WHILE P_OPEN boolean_expression P_CLOSE A_OPEN
    {
         SymTable* whileSymTable = new SymTable("while", currentSymTable, "block - while");
         printf("Entering while-scope at line%d\n", yylineno);
        currentSymTable = whileSymTable; // Switch to block scope
    }
    statement_list A_CLOSE
    { 
        currentSymTable->printTableToFile("symbol_table.txt", true);
        SymTable* oldScope = currentSymTable;
        currentSymTable = currentSymTable->getParent();
        delete oldScope;
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
         currentSymTable->printTableToFile("symbol_table.txt", true);
        // Exit the block scope after the loop
        SymTable* oldScope = currentSymTable;
        currentSymTable = currentSymTable->getParent();
        delete oldScope;
    }
    | FOR P_OPEN assignment_statement boolean_expression ';' postfix_incr_decre P_CLOSE BGIN statement_list END
    {
        // Create a new symbol table for the block scope inside the 'for' loop
        SymTable* blockSymTable = new SymTable("block", currentSymTable);
        currentSymTable = blockSymTable; // Switch to the block scope
         currentSymTable->printTableToFile("symbol_table.txt", true);
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
         currentSymTable->printTableToFile("symbol_table.txt", true);
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
    {
        $$=$3;
       cout << "Eval value: " << ast.evaluateTree() << endl; //ast.printTree(); 
    }
    ;
typeof_statement:
    TYPEOF P_OPEN expression P_CLOSE ';'
    {  
                                cout << "TypeOf value: ";
                                string resultValue = ast.evaluateTree();

                                // Assuming your evaluateTree() function returns a string representation of the result

                                if (isInteger(resultValue)) {
                                    cout << "Integer" << endl;
                                } else if (isFloat(resultValue)) {
                                    cout << "Float" << endl;
                                } else if (isBoolean(resultValue)) {
                                    cout << "Boolean" << endl;
                                } else {
                                    cout << "Unknown" << endl;
                                }

                                ast.printTree();         
                             }
    | TYPEOF P_OPEN boolean_expression P_CLOSE ';'
    {  
                                cout << "TypeOf value: ";
                                string resultValue = ast.evaluateTree();

                                // Assuming your evaluateTree() function returns a string representation of the result

                                if (isInteger(resultValue)) {
                                    cout << "Integer" << endl;
                                } else if (isFloat(resultValue)) {
                                    cout << "Float" << endl;
                                } else if (isBoolean(resultValue)) {
                                    cout << "Boolean" << endl;
                                } else {
                                    cout << "Unknown" << endl;
                                }

                                ast.printTree();         
                             }
    ;

/* statement_typeof: expression {  
                                cout << "TypeOf value: ";
                                string resultValue = ast.evaluateTree();

                                // Assuming your evaluateTree() function returns a string representation of the result

                                if (isInteger(resultValue)) {
                                    cout << "Integer" << endl;
                                } else if (isFloat(resultValue)) {
                                    cout << "Float" << endl;
                                } else if (isBoolean(resultValue)) {
                                    cout << "Boolean" << endl;
                                } else {
                                    cout << "Unknown" << endl;
                                }

                                ast.printTree();         
                             } */
                             ;

// expresii aritmetice
expression:
    expression PLUS expression
    {
        if($1->type=="bool"||$3->type=="bool")
                            {
                                yyerror("Cannot perform mathematical operations on type 'bool'");
                            }
         if($1->type!=$3->type)
                            {
                                string err="Operands have different types! '"+$1->type+"' + '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                        $$ = new Node { $1, $3, "+",$1->type }; 
                        ast.AddNode("+",$1,$3,$1->type);
    }
    | expression MINUS expression
    { 
                        if($1->type=="bool"||$3->type=="bool")
                            { 
                                yyerror("Cannot perform mathematical operations on type 'bool'");
                            }
                        if($1->type!=$3->type) 
                            {
                                string err="Operands have different types! '"+$1->type+"' - '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                        $$ = new Node { $1, $3, "-",$1->type }; 
                        ast.AddNode("-",$1,$3,$1->type);
                    }
    | expression MULT expression
     { 
                        if($1->type=="bool"||$3->type=="bool")  
                            {
                                yyerror("Cannot perform mathematical operations on type 'bool'");
                            }
                        if($1->type!=$3->type)
                            {
                                string err="Operands have different types! '"+$1->type+"' * '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                        $$ = new Node { $1, $3, "*",$1->type }; 
                        ast.AddNode("*",$1,$3,$1->type);
                    }
    | expression DIV expression
     { 
                        if($1->type=="bool"||$3->type=="bool")
                            {
                                yyerror("Cannot perform mathematical operations on type 'bool'");
                            }
                        if($1->type!=$3->type)
                            {   
                                string err="Operands have different types! '"+$1->type+"' / '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                        $$ = new Node { $1, $3, "/",$1->type }; 
                        ast.AddNode("/",$1,$3,$1->type);}
    
    | expression POW expression
   { 
                        if($1->type=="bool"||$3->type=="bool")
                            {
                                yyerror("Cannot perform mathematical operations on type 'bool'");
                            }
                        if($1->type!=$3->type)
                            {
                                string err="Operands have different types! '"+$1->type+"' ^ '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                        $$ = new Node{$1, $3, "^",$1->type}; 
                        ast.AddNode("^",$1,$3,$1->type);
                    }
    | INTVAL
    {
        
                            $$ = new Node{NULL, NULL, to_string($1),"int"}; 
                            ast.AddNode(to_string($1),NULL,NULL,"int");
    }
    | FLOATVAL
    { $$=new Node{NULL,NULL,to_string($1),"float"};
                            ast.AddNode(to_string($1),NULL,NULL,"float"); 
    }
    |BOOLVAL
    {
        $$ = new Node{NULL, NULL, $1 ? "true" : "false", "bool"};
        ast.AddNode($1 ? "true" : "false", NULL, NULL, "bool");
    }
     |ID
    {
        if (!currentSymTable->existsVar($1)) {
            yyerror(("Undeclared variable: " + std::string($1)).c_str());
            $$ = nullptr;  // Handle undeclared variable
        } else {
            // Fetch the type and value of the variable from the symbol table
            std::string varType = currentSymTable->getVarType($1);
            std::string varValue = currentSymTable->getVarValue($1);

            $$ = new Node{NULL, NULL, varValue, varType};  // Create a new node with the value and type
            ast.AddNode(varValue, NULL, NULL, varType);    // Add to AST
        }
    }
    ;



boolean_expression:
    expression GT expression
    { 
                        if($1->type=="bool"||$3->type=="bool")
                        {
                            yyerror("Cannot perform mathematical operations on type 'bool'");
                        }
                        if($1->type!=$3->type)
                        {
                            string err="Operands have different types! '"+$1->type+"' > '"+$3->type+"'";
                            yyerror(err.c_str());
                        }
                        $$ = new Node{$1, $3, ">","bool"}; 
                        ast.AddNode(">",$1,$3,"bool");}
    | expression LT expression
     { 
                        if($1->type=="bool"||$3->type=="bool")
                            {
                                yyerror("Cannot perform mathematical operations on type 'bool'");
                            }
                        if($1->type!=$3->type)
                            { 
                                string err="Operands have different types! '"+$1->type+"' < '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                            $$ = new Node{$1, $3, "<","bool"}; 
                            ast.AddNode("<",$1,$3,"bool");}
    | expression GTE expression
    { 
                        if($1->type=="bool"||$3->type=="bool")
                        {
                            yyerror("Cannot perform mathematical operations on type 'bool'");
                        }
                        if($1->type!=$3->type)
                        {
                            string err="Operands have different types! '"+$1->type+"' >= '"+$3->type+"'";
                            yyerror(err.c_str());
                        }
                        $$ = new Node{$1, $3, ">=","bool"}; 
                        ast.AddNode(">=",$1,$3,"bool");}
    | expression LTE expression
     { 
                        if($1->type=="bool"||$3->type=="bool")
                            { 
                                yyerror("Cannot perform mathematical operations on type 'bool'");
                            }
                        if($1->type!=$3->type)
                            {
                                string err="Operands have different types! '"+$1->type+"' <= '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                            $$ = new Node{$1, $3, "<=","bool"}; 
                            ast.AddNode("<=",$1,$3,"bool");}
    | expression EQL expression
    {
        printf("AM PARSAT == \n");
         { 
                        if($1->type=="bool"||$3->type=="bool")
                        {
                            yyerror("Cannot perform mathematical operations on type 'bool'");
                        }
                        if($1->type!=$3->type)
                        {
                            string err="Operands have different types! '"+$1->type+"' == '"+$3->type+"'";
                            yyerror(err.c_str());
                        }
                        $$ = new Node{$1, $3, "==","bool"}; 
                        ast.AddNode("==",$1,$3,"bool");
                    }
    }
    | expression NEQ expression
     { 
                        if($1->type=="bool"||$3->type=="bool")
                        {
                            yyerror("Cannot perform mathematical operations on type 'bool'");
                        }
                        if($1->type!=$3->type)
                        {
                            string err="Operands have different types! '"+$1->type+"' != '"+$3->type+"'";
                            yyerror(err.c_str());
                        }
                        $$ = new Node{$1, $3, "!=","bool"}; 
                        ast.AddNode("!=",$1,$3,"bool");}
    | boolean_expression AND boolean_expression
    {
                        if($1->type=="int"||$1->type=="float"||$3->type=="int"||$3->type=="float")
                            {
                                string err="Operation && only supports bool operands ! '"+$1->type+"' && '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                            $$ = new Node{$1, $3,"&&",$1->type}; 
                            ast.AddNode("&&",$1,$3,$1->type);
                    }
    | boolean_expression OR boolean_expression
     {
                         if($1->type=="int"||$1->type=="float"||$3->type=="int"||$3->type=="float")
                            {
                                string err="Operation || only supports bool operands ! '"+$1->type+"' || '"+$3->type+"'";
                                yyerror(err.c_str());
                            }
                            $$ = new Node{$1, $3,"||",$1->type}; 
                            ast.AddNode("||",$1,$3,$1->type);
                    }
    | NOT boolean_expression
    {
                        if($2->type=="int"||$2->type=="float")
                            {
                                string err="Operation ! only supports bool operand! !'"+$2->type+"''";
                                yyerror(err.c_str());
                            }
                            $$ = new Node{$2, NULL,"!",$2->type}; 
                            ast.AddNode("!",$2,NULL,$2->type); }
    | INTVAL
    {
        
                            $$ = new Node{NULL, NULL, to_string($1),"int"}; 
                            ast.AddNode(to_string($1),NULL,NULL,"int");
    }
    | FLOATVAL
    { $$=new Node{NULL,NULL,to_string($1),"float"};
                            ast.AddNode(to_string($1),NULL,NULL,"float"); 
    }
    |BOOLVAL
    {
        $$ = new Node{NULL, NULL, $1 ? "true" : "false", "bool"};
        ast.AddNode($1 ? "true" : "false", NULL, NULL, "bool");
    }
     |ID
    {
        if (!currentSymTable->existsVar($1)) {
            yyerror(("Undeclared variable: " + std::string($1)).c_str());
            $$ = nullptr;  // Handle undeclared variable
        } else {
            // Fetch the type and value of the variable from the symbol table
            std::string varType = currentSymTable->getVarType($1);
            std::string varValue = currentSymTable->getVarValue($1);

            $$ = new Node{NULL, NULL, varValue, varType};  // Create a new node with the value and type
            ast.AddNode(varValue, NULL, NULL, varType);    // Add to AST
        }
    }
    ;


%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

int main() {
    
    if (yyparse() == 0) {
        printf("Parsing completed successfully.\n");
        globalSymTable->printTableToFile("complete_symbol_table.txt", false);
    } else {
        printf("Parsing failed.\n");
    }

    // Cleanup symbol tables
    delete globalSymTable;

    // Clear global lists
    globalParamList.clear();
    globalStatements.clear();

    return 0;
}
