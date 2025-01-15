#ifndef SYMTABLE_H
#define SYMTABLE_H

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <fstream>
#include "ASTNode.h"

using namespace std;

struct ParamInfo {
    string type;
    string name;
};

struct StatementInfo {
    string type;
    string name;
    bool isVariable = false;
};

struct FunctionInfo {
    string name;
    string returnType;
    string scope;
    bool isMethod;
    string className;
    vector<ParamInfo> parameters;
};

struct VarInfo {
    string type;
    string name;
    string value;
};

class SymTable {  
public:
    vector<VarInfo> vars;
    vector<FunctionInfo> functions;
    vector<std::string> classes;
    string name;
     SymTable* parent;
    string scope;
   
    int indent = 4;
    SymTable(const std::string& name, SymTable* parent = nullptr, const std::string& scope = "global");

    void addVar(const string& type, const string& name, const string& value = "");
    void addValue(string name, string value);
    void addFunction(const FunctionInfo& funcInfo);
    void addClass(string className);
    bool existsFunction(const std::string& functionName) const {
    for (const auto& func : functions) {
        if (func.name == functionName) return true;
    }
    return parent ? parent->existsFunction(functionName) : false;
};
    FunctionInfo getFunctionInfo(const std::string& functionName) const {
    for (const auto& func : functions) {
        if (func.name == functionName) return func;
    }
    if (parent) return parent->getFunctionInfo(functionName);

    throw std::runtime_error("Function '" + functionName + "' not found in symbol table.");
};
    bool existsVar(const string& name) const;
    string getVarType(const string& name) const;
    string getVarValue(const string& name) const;
    SymTable* getParent() const { return parent; }
    string TypeOf(const char* arg);

    void printTableToFile(const char* outputFile, bool append) const;

    ~SymTable();
};
#endif //SYMTABLE_H