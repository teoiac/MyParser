# Custom Programming Language

This project implements a custom programming language with syntax, semantic analysis, and expression evaluation using Abstract Syntax Trees (AST). The language includes type declarations, function definitions, control structures, symbol tables, and error handling.

## Features

### 1. Syntax Requirements
- **Type Declarations**: Supports `int`, `float`, `char`, `string`, `bool`, and array types.
- **Classes**:
  - Allow initialization and use of objects.
  - Provide syntax for accessing fields and methods.
  - Can only be defined in the global scope.
- **Variable and Function Definitions**.
- **Control Statements**: `if`, `for`, `while`.
- **Assignment Statements**: `left_value = expression` where `left_value` can be an identifier or array element.
- **Expressions**: Arithmetic and boolean expressions with `true` and `false` values.
- **Function Calls**: Support for expressions, function calls, and identifiers as parameters.
- **Predefined Functions**:
  - `Print(expr)`: Evaluates and prints `expr`.
  - `TypeOf(expr)`: Prints the type of `expr`.
- **Program Structure**:
  1. Class definitions.
  2. Global variables.
  3. Function definitions.
  4. Main function (entry point).

### 2. Symbol Tables
- Maintains scopes for variables and functions:
  - **Global Scope**: Covers entire program.
  - **Block Scope**: Introduced by `if`, `for`, `while`.
  - **Function Scope**: Introduced by function definitions.
  - **Class Scope**: Introduced by class definitions.
- Implemented using `SymTable` class with a pointer to parent scope.
- Stores information about variables, functions, and classes.
- Symbol tables are printed to a separate file after parsing.

### 3. Semantic Analysis
- Ensures:
  - Variables/functions are defined before use.
  - No duplicate variable declarations in the same scope.
  - Operands in an expression have the same type (no implicit casting).
  - Left and right sides of an assignment have the same type.
  - Function call arguments match function definition.
- Provides detailed error messages with line numbers.

### 4. AST-Based Expression Evaluation
- **AST Representation**:
  - Single node for literals, identifiers, function calls, etc.
  - Operator nodes with left/right subtrees for binary expressions.
  - Unary operator nodes with a single subtree.
- **Evaluation**:
  - If the root is a literal, return its value.
  - If the root is an identifier, fetch value from the symbol table.
  - Otherwise, recursively evaluate subtrees and apply operations.
- **Usage**:
  - `Print(expr)`: Evaluates `expr` and prints value and type.
  - `TypeOf(expr)`: Prints type of `expr`.
  - Evaluates right-hand side expressions in assignments.

## Example Program
```c
class exemplu {
  int a;
  int b;
  func int interschimbare(int c, int d) {
    int z;
    z:=3;
    if(z == 3)
    {
      z:=4;
      int g;
    #
  }
};


int y;
bool z;

func int add(int a, int b) {
    return a + b;
}

func int sub(int m, int n)
{
  return m-n;
}

func void main() begin
int i;
for(i:=1;i<=10;i++)
   begin
      x++;
      int l;
   end
   int x;
  add(1, 2);
 int q;
  q:=2;
  array int k[12][32][4];
  int j;
  j:=4;
  bool v;
  bool w;
  v :=true;
  w:=false;
  TypeOf(j+3);
  TypeOf(q>j);
  Print(v);
  Print(j/2+q-7);
end
```
