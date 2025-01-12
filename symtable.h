#ifndef SYMTABLE_H
#define SYMTABLE_H

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <fstream>

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
    int indent = 4;
    SymTable(const std::string& name, SymTable* parent = nullptr);

    void addVar(const string& type, const string& name, const string& value = "");
    void addValue(string name, string value);
    void addFunction(const FunctionInfo& funcInfo);
    void addClass(string className);

    bool existsVar(const string& name) const;
    string getVarType(const string& name) const;
    string getVarValue(const string& name) const;
    SymTable* getParent() const { return parent; }

    void printTableToFile(const char* outputFile, bool append) const;

    ~SymTable();
};
#endif //SYMTABLE_H
