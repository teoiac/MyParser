#ifndef SYMTABLE_H
#define SYMTABLE_H

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <fstream>

struct ParamInfo {
    std::string type;
    std::string name;
};

struct FunctionInfo {
    std::string name;
    std::string returnType;
    std::string scope;
    bool isMethod;
    std::string className;
    std::vector<ParamInfo> parameters;
};



struct IdInfo {
    std::string type;
    std::string name;
    std::string value;
};

class SymTable {
    std::vector<IdInfo> vars;
    std::vector<FunctionInfo> functions;
    std::vector<std::string> classes;
   
public:
    std::string name;
    SymTable* parent;
    int indent = 4;
    SymTable(const std::string& name, SymTable* parent = nullptr);

    void addVar(const std::string& type, const std::string& name, const std::string& value = "");
    void addFunction(const FunctionInfo& funcInfo);
    void addClass(std::string className);

    bool existsVar(const std::string& name) const;
    std::string getVarType(const std::string& name) const;
    std::string getVarValue(const std::string& name) const;

    void printTableToFile(const char* outputFile) const;

    ~SymTable();
};
#endif //SYMTABLE_H
