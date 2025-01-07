#include "symtable.h"
#include <fstream>
using namespace std;
void SymTable::addVar(const string& type, const string& name) {
    if (existsId(name)) {
        throw runtime_error("Duplicate identifier: " + name);
    }
    ids[name] = IdInfo("var", type, name);
}

void SymTable::addFunc(const string& returnType, const string& name, const ParamList& params) {
    if (existsId(name)) {
        throw runtime_error("Duplicate identifier: " + name);
    }
    IdInfo func("func", returnType, name);
    func.params = params;
    ids[name] = func;
}

void SymTable::addClass(const string& name) {
    if (existsId(name)) {
        throw runtime_error("Duplicate identifier: " + name);
    }
    ids[name] = IdInfo("class", name, name); // Assuming class name is its type
}

bool SymTable::existsId(const string& var) {
    return ids.find(var) != ids.end();
}

void SymTable::printVars(ostream& out) {
    for (const auto& v : ids) {
        out << "name: " << v.first << ", type: " << v.second.type;
        if (v.second.idType == "func") {
            out << ", params: (";
            for (size_t i = 0; i < v.second.params.params.size(); ++i) {
                out << v.second.params.params[i].first << " " << v.second.params.params[i].second;
                if (i < v.second.params.params.size() - 1) {
                    out << ", ";
                }
            }
            out << ")";
        }
        out << endl;
    }
}

void SymTable::printTableToFile(const string& filename) {
    ofstream outFile(filename, ios::app); // append to file
    if (outFile.is_open()) {
        outFile << "Symbol Table: " << name << endl;
        printVars(outFile);
        outFile << endl;
        outFile.close();
    } else {
        cerr << "Unable to open file: " << filename << endl;
    }
}