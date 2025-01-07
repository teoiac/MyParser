#ifndef SYMTABLE_H
#define SYMTABLE_H

#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <stdexcept> // for exception handling

using namespace std;

// Simplified ParamList (you can expand this later)
class ParamList {
public:
    vector<pair<string, string>> params; // (type, name)
};

class IdInfo {
public:
    string idType; // "var", "func", "class"
    string type;
    string name;
    ParamList params; // for functions
    IdInfo() {}
    IdInfo(const string& idType, const string& type, const string& name) : idType(idType), type(type), name(name) {}
};

class SymTable {
    map<string, IdInfo> ids;
    string name;
    SymTable* parent; // pointer la scop
public:
    SymTable(const string& name, SymTable* parent = nullptr) : name(name), parent(parent) {}
    bool existsId(const string& s);
    void addVar(const string& type, const string& name);
    void addFunc(const string& returnType, const string& name, const ParamList& params);
    void addClass(const string& name);
    void printVars(ostream& out); //Added ostream for flexibility
    void printTableToFile(const string& filename);
    ~SymTable() {} 
    SymTable* getParent() const { return parent; } // getter parinte
};

#endif