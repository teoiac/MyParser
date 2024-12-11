%{
#include <iostream>
#include <vector>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int yylex();
void yyerror(const char * s);
class SymTable* current;
int errorCount = 0;
%}
%union {
     char* string;
}
%token  BGIN END ASSIGN NR 
%token<string> ID TYPE
%start progr
%%
progr :  declarations main {if (errorCount == 0) cout<< "The program is correct!" << endl;}
      ;

declarations : decl           
	      |  declarations decl    
	      ;

decl       :  TYPE ID ';' { 
                              if(!current->existsId($2)) {
                                    current->addVar($1,$2);
                              } else {
                                   errorCount++; 
                                   yyerror("Variable already defined");
                              }
                          }
              | TYPE ID  '(' list_param ')' ';'
           ;

list_param : param
            | list_param ','  param 
            ;
            
param : TYPE ID 
      ; 
      

main : BGIN list END  
     ;
     

list :  statement ';' 
     | list statement ';'
     ;

statement: ID ASSIGN ID
         | ID ASSIGN NR  		 
         | ID '(' call_list ')'
         ;
        
call_list : NR
           | call_list ',' NR
           ;
%%
void yyerror(const char * s){
     cout << "error:" << s << " at line: " << yylineno << endl;
}

int main(int argc, char** argv){
     yyin=fopen(argv[1],"r");
     current = new SymTable("global");
     yyparse();
     cout << "Variables:" <<endl;
     current->printVars();
     delete current;
} 


/*
1) syntax requirments - pana in s12 trebuie facuta analiza sintactica

- declarrare de tip uri si pentru array uri cu n-dimensiuni ?????
- clase : sintaxa pt initializare obiecte
- accessare metode, (.) - java style mai bine
- 
*/